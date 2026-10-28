// E8d2a — KIS REST 핵심(설계 13 §8 R29 L2~L5 · M1-8).
//
// 🔵 잡는 것: ① 키 세트와 접속 환경이 다르면 요청 전에 거절(잘못된 키 세트로 실전 전환 차단) ② 토큰 = 한 번 받아 다시
//    쓰기 · 만료 5분 전이면 새로 · 1분 1회 제한은 다시 보내지 않음 ③ 유량 문 간격 ④ 조회 재시도(유량 코드 · 5xx · 연결
//    실패 · 1 → 2 → 4초 · 최대 3회) · 업무 거절은 다시 보내지 않음 · 토큰 무효면 새 토큰으로 1회 ⑤ 오류 문구에 비밀값 없음.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:broker_gateway/broker_gateway.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

class _Clock {
  DateTime t = DateTime.utc(2026, 10, 29, 9);
  final List<Duration> slept = <Duration>[];

  DateTime now() => t;

  Future<void> sleep(Duration d) async {
    slept.add(d);
    t = t.add(d);
  }
}

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
);

const String _token = 'eyFAKE-TOKEN-0123456789abcdefghijklmnopqrstuvwxyz';
final Map<String, Object> _tokenBody = <String, Object>{
  'access_token': _token,
  'access_token_token_expired': '2026-10-30 09:00:00',
  'token_type': 'Bearer',
  'expires_in': 86400,
};
final Map<String, Object> _okBody = <String, Object>{
  'rt_cd': '0',
  'msg_cd': 'MCA00000',
  'msg1': '정상처리 되었습니다.',
  'output': <String, String>{'stck_prpr': '176360'},
};

KisCredentials _mockKeys() => KisCredentials(
  environment: KisEnvironment.mock,
  appKey: 'PSfakeAppKey0123456789abcdef',
  appSecret: 'fakeSecretValue${'Z' * 60}',
  accountNo: '50123456',
);

void main() {
  late _Clock clock;
  late List<http.Request> seen;
  setUp(() {
    clock = _Clock();
    seen = <http.Request>[];
  });

  KisRestClient client(
    Future<http.Response> Function(http.Request r) handler, {
    KisTokenStore? tokens,
    KisCredentials? keys,
    KisEnvironment env = KisEnvironment.mock,
    Duration timeout = const Duration(seconds: 10),
  }) => KisRestClient(
    MockClient((http.Request r) {
      seen.add(r);
      return handler(r);
    }),
    keys ?? _mockKeys(),
    environment: env,
    tokens: tokens,
    now: clock.now,
    sleep: clock.sleep,
    timeout: timeout,
  );

  Future<http.Response> tokenOr(
    http.Request r,
    Future<http.Response> Function() get,
  ) async => r.url.path == '/oauth2/tokenP' ? _json(_tokenBody) : get();

  group('L2 단일 스위치', () {
    test('🔴 모의 키 세트로 실전 환경 클라이언트를 만들면 요청 전에 거절', () {
      expect(
        () => client((_) async => _json(_okBody), env: KisEnvironment.live),
        throwsA(isA<KisGuardError>()),
      );
      expect(seen, isEmpty);
    });

    test('요청은 그 환경의 호스트·포트로만 · 헤더에 tr_id · 계좌번호는 자격증명에만', () async {
      final KisRestClient c = client(
        (http.Request r) => tokenOr(r, () async => _json(_okBody)),
      );
      final KisResponse r = await c.get(
        '/uapi/x',
        'FHKST01010100',
        <String, String>{'A': '1'},
      );
      expect(r.ok, isTrue);
      for (final http.Request q in seen) {
        expect(q.url.host, 'openapivts.koreainvestment.com');
        expect(q.url.port, 29443);
        expect(q.url.scheme, 'https');
      }
      expect(seen.last.headers['tr_id'], 'FHKST01010100');
      expect(seen.last.headers['authorization'], 'Bearer $_token');
      expect(KisEnvironment.live.host, 'openapi.koreainvestment.com');
      expect(_mockKeys().toString(), isNot(contains('fake')));
    });

    test('자격증명 꼴 검사 — 계좌 8자리 · 상품코드 2자리 · 빈 키', () {
      KisCredentials k({
        String acct = '50123456',
        String prdt = '01',
        String key = 'k',
      }) => KisCredentials(
        environment: KisEnvironment.mock,
        appKey: key,
        appSecret: 's',
        accountNo: acct,
        productCode: prdt,
      );
      expect(() => k(acct: '5012345'), throwsArgumentError);
      expect(() => k(prdt: '1'), throwsArgumentError);
      expect(() => k(key: ''), throwsArgumentError);
      expect(k().productCode, '01');
    });
  });

  group('L3 토큰', () {
    test('한 번 받아 다시 쓴다 · 발급 본문 = 앱키·시크릿(서버로만)', () async {
      final KisRestClient c = client(
        (http.Request r) => tokenOr(r, () async => _json(_okBody)),
      );
      await c.get('/uapi/x', 'T', const <String, String>{});
      await c.get('/uapi/x', 'T', const <String, String>{});
      expect(
        seen.where((http.Request r) => r.url.path == '/oauth2/tokenP'),
        hasLength(1),
      );
      final Map<String, Object?> b =
          jsonDecode(seen.first.body) as Map<String, Object?>;
      expect(b['grant_type'], 'client_credentials');
      expect(b['appkey'], _mockKeys().appKey);
    });

    test('만료 5분 전이면 새로 받는다', () async {
      final MemoryKisTokenStore store = MemoryKisTokenStore()
        ..write(
          KisEnvironment.mock,
          KisToken('old', clock.now().add(const Duration(minutes: 4))),
        );
      final KisRestClient c = client(
        (http.Request r) => tokenOr(r, () async => _json(_okBody)),
        tokens: store,
      );
      expect((await c.token()).accessToken, _token);
      store.write(
        KisEnvironment.mock,
        KisToken('keep', clock.now().add(const Duration(minutes: 6))),
      );
      expect((await c.token()).accessToken, 'keep');
    });

    test('🔴 1분 1회 제한(EGW00133) = 다시 보내지 않고 오류', () async {
      final KisRestClient c = client(
        (_) async => _json(<String, Object>{
          'error_code': 'EGW00133',
          'error_description': '접근토큰 발급 잠시 후 다시 시도하세요(1분당 1회)',
        }, 403),
      );
      final Object e = await c.token().then<Object>(
        (_) => 'no',
        onError: (Object e) => e,
      );
      expect(e, isA<KisTokenError>());
      expect((e as KisTokenError).rateLimited, isTrue);
      expect(seen, hasLength(1));
      expect(e.toString(), isNot(contains(_mockKeys().appKey)));
    });

    test('파일 보관 — 환경마다 · 버리기', () {
      final Directory d = Directory.systemTemp.createTempSync('aaq_kis_tok_');
      addTearDown(() => d.deleteSync(recursive: true));
      final FileKisTokenStore f = FileKisTokenStore(File('${d.path}/t.json'));
      expect(f.read(KisEnvironment.mock), isNull);
      f.write(KisEnvironment.mock, KisToken('m', DateTime.utc(2026, 10, 30)));
      f.write(KisEnvironment.live, KisToken('l', DateTime.utc(2026, 10, 31)));
      final FileKisTokenStore g = FileKisTokenStore(File('${d.path}/t.json'));
      expect(g.read(KisEnvironment.mock)!.accessToken, 'm');
      expect(
        g.read(KisEnvironment.live)!.expiresAt,
        DateTime.utc(2026, 10, 31),
      );
      g.clear(KisEnvironment.mock);
      expect(f.read(KisEnvironment.mock), isNull);
      expect(f.read(KisEnvironment.live), isNotNull);
      expect(
        KisToken('secret', DateTime.utc(2026)).toString(),
        isNot(contains('secret')),
      );
    });
  });

  group('L4 유량 문', () {
    test('요청 사이 모의 1.1초 이상(토큰 발급 포함)', () async {
      final List<DateTime> at = <DateTime>[];
      final KisRestClient c = client((http.Request r) {
        at.add(clock.now());
        return tokenOr(r, () async => _json(_okBody));
      });
      for (int i = 0; i < 4; i++) {
        await c.get('/uapi/x', 'T', const <String, String>{});
      }
      expect(at, hasLength(5));
      for (int i = 1; i < at.length; i++) {
        expect(
          at[i].difference(at[i - 1]),
          greaterThanOrEqualTo(KisEnvironment.mock.minInterval),
        );
      }
      expect(c.calls, 5);
    });

    test('겹친 호출도 줄을 선다', () async {
      final KisRateGate g = KisRateGate(
        const Duration(seconds: 1),
        now: clock.now,
        sleep: clock.sleep,
      );
      final List<DateTime> at = <DateTime>[];
      await Future.wait(<Future<void>>[
        for (int i = 0; i < 3; i++) g.pass().then((_) => at.add(clock.now())),
      ]);
      expect(
        at[2].difference(at[0]),
        greaterThanOrEqualTo(const Duration(seconds: 2)),
      );
    });
  });

  group('L5 조회 재시도', () {
    test('유량 초과(EGW00201) → 1초 뒤 다시 → 정상', () async {
      int n = 0;
      final KisRestClient c = client(
        (http.Request r) => tokenOr(r, () async {
          n++;
          return n == 1
              ? _json(<String, String>{
                  'rt_cd': '1',
                  'msg_cd': 'EGW00201',
                  'msg1': '초당 거래건수를 초과하였습니다.',
                }, 500)
              : _json(_okBody);
        }),
      );
      final KisResponse r = await c.get(
        '/uapi/x',
        'T',
        const <String, String>{},
      );
      expect(r.ok, isTrue);
      expect(r.attempts, 2);
      expect(clock.slept, contains(const Duration(seconds: 1)));
    });

    test('업무 거절(EGW02006 · 모의 미지원)은 다시 보내지 않는다', () async {
      final KisRestClient c = client(
        (http.Request r) => tokenOr(
          r,
          () async => _json(<String, String>{
            'rt_cd': '1',
            'msg_cd': 'EGW02006',
            'msg1': '모의투자 TR 이 아닙니다.',
          }, 500),
        ),
      );
      final KisResponse r = await c.get(
        '/uapi/x',
        'T',
        const <String, String>{},
      );
      expect(r.ok, isFalse);
      expect(r.attempts, 1);
      expect(r.msgCd, 'EGW02006');
      expect(r.msg1, '모의투자 TR 이 아닙니다.');
    });

    test('🔴 토큰 무효 → 버리고 새 토큰으로 한 번만', () async {
      int n = 0;
      final MemoryKisTokenStore store = MemoryKisTokenStore();
      final KisRestClient c = client(
        (http.Request r) => tokenOr(r, () async {
          n++;
          return _json(<String, String>{
            'rt_cd': '1',
            'msg_cd': 'EGW00123',
            'msg1': '기간이 만료된 token 입니다.',
          }, 500);
        }),
        tokens: store,
      );
      final KisResponse r = await c.get(
        '/uapi/x',
        'T',
        const <String, String>{},
      );
      expect(n, 2, reason: '처음 + 새 토큰으로 1회');
      expect(r.msgCd, 'EGW00123');
      expect(
        seen.where((http.Request q) => q.url.path == '/oauth2/tokenP'),
        hasLength(2),
      );
    });

    test('5xx 가 이어지면 1 → 2 → 4초 뒤 포기(KisUnavailable · 시도 4)', () async {
      final KisRestClient c = client(
        (http.Request r) => tokenOr(r, () async => http.Response('oops', 503)),
      );
      final Object e = await c
          .get('/uapi/x', 'T', const <String, String>{})
          .then<Object>((_) => 'no', onError: (Object e) => e);
      expect(e, isA<KisUnavailable>());
      expect((e as KisUnavailable).attempts, 4);
      expect(clock.slept, containsAllInOrder(kKisGetBackoff));
    });

    test('연결 실패 · 시간 초과도 다시 보낸다 · 오류에 비밀값 없음', () async {
      int n = 0;
      final KisRestClient c = client(
        (http.Request r) => tokenOr(r, () async {
          n++;
          if (n == 1) throw http.ClientException('boom', r.url);
          if (n == 2) {
            await Future<void>.delayed(const Duration(milliseconds: 200));
          }
          return _json(_okBody);
        }),
        timeout: const Duration(milliseconds: 50),
      );
      final KisResponse r = await c.get('/uapi/x', 'T', <String, String>{
        'CANO': '50123456',
      });
      expect(r.ok, isTrue);
      expect(r.attempts, 3);
      final KisUnavailable u = const KisUnavailable('연결 실패', 4);
      for (final String s in <String>[..._mockKeys().secrets, _token]) {
        expect(u.toString(), isNot(contains(s)));
        expect(
          const KisRejected('T', 500, 'X', 'y').toString(),
          isNot(contains(s)),
        );
      }
    });
  });
}
