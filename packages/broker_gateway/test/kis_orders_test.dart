// E10d — KIS 국내 주문(설계 13 §8 R37 Y1~Y10 · 04 §3-3 v2.38 · 07 §6-3 · 05 F-14b).
//
// 🔵 F-14b S01~S13 = 파일럿5 하네스(`08_파일럿/파일럿5/harness/f14b_harness.py`)의 시나리오를 Dart `MockClient` 로 옮겼다 —
//    관측점은 **주문 엔드포인트로 보낸 요청 수**(토큰 발급 제외)와 백오프 잠 열이다. S13(연결 실패)은 v2.38 정합으로
//    1회 · 결과 불명(하네스 수용 범위 1~4회 안).
// 🔵 픽스처 = 07 §6-3 실응답(`fixtures/kis/orders/`) — 가림 자리표시를 숫자로 바꿔 읽는다(파일은 그대로).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:broker_gateway/broker_gateway.dart';
import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

/// 픽스처 본문 — `<주문번호#n>` → 10자리 · `<지점#n>` → 5자리 숫자.
String _fixtureText(String name) => File('test/fixtures/kis/orders/$name')
    .readAsStringSync()
    .replaceAllMapped(
      RegExp(r'<주문번호#(\d+)>'),
      (Match m) => m.group(1)!.padLeft(10, '0'),
    )
    .replaceAllMapped(
      RegExp(r'<지점#(\d+)>'),
      (Match m) => m.group(1)!.padLeft(5, '0'),
    );

Map<String, Object?> _fixture(String name) =>
    jsonDecode(_fixtureText(name)) as Map<String, Object?>;

http.Response _json(
  Object body, [
  int status = 200,
  Map<String, String> headers = const <String, String>{},
]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: <String, String>{
    'content-type': 'application/json; charset=utf-8',
    ...headers,
  },
);

Map<String, Object> _tokenBody(int n) => <String, Object>{
  'access_token': 'eyFAKE-TOKEN-$n',
  'token_type': 'Bearer',
  'expires_in': 86400,
};

Map<String, Object> _okOrder([String odno = '0000000008']) => <String, Object>{
  'rt_cd': '0',
  'msg_cd': '40600000',
  'msg1': '모의투자 매수주문이 완료 되었습니다.',
  'output': <String, String>{
    'KRX_FWDG_ORD_ORGNO': '00001',
    'ODNO': odno,
    'ORD_TMD': '112314',
  },
};

Map<String, Object> _codeBody(String code) => <String, Object>{
  'rt_cd': '1',
  'msg_cd': code,
  'msg1': '거절($code)',
};

KisCredentials _keys([KisEnvironment env = KisEnvironment.mock]) =>
    KisCredentials(
      environment: env,
      appKey: 'PSfakeAppKey0123456789abcdef',
      appSecret: 'fakeSecretValue${'Z' * 60}',
      accountNo: '50123456',
    );

/// 주문 시험 묶음 — 토큰 발급 · 주문 · 조회 요청을 따로 센다.
class _Rig {
  _Rig(
    this.order, {
    this.get,
    KisEnvironment env = KisEnvironment.mock,
    Duration timeout = const Duration(seconds: 10),
    DateTime? now,
  }) {
    client = KisRestClient(
      MockClient((http.Request r) async {
        if (r.url.path == '/oauth2/tokenP') {
          tokenCalls++;
          return _json(_tokenBody(tokenCalls));
        }
        if (r.method == 'POST') {
          posts.add(r);
          return order(r, posts.length - 1);
        }
        gets.add(r);
        final Future<http.Response> Function(http.Request, int)? g = get;
        if (g == null) throw StateError('GET 각본 없음');
        return g(r, gets.length - 1);
      }),
      _keys(env),
      environment: env,
      gate: KisRateGate(Duration.zero, sleep: (Duration d) async {}),
      sleep: (Duration d) async => sleeps.add(d.inMilliseconds / 1000),
      timeout: timeout,
    );
    broker = KisOrderBroker(
      client,
      now: () => now ?? DateTime.utc(2026, 11, 2, 0, 10),
    );
  }

  final Future<http.Response> Function(http.Request r, int i) order;
  final Future<http.Response> Function(http.Request r, int i)? get;
  late final KisRestClient client;
  late final KisOrderBroker broker;
  final List<http.Request> posts = <http.Request>[];
  final List<http.Request> gets = <http.Request>[];
  final List<double> sleeps = <double>[];
  int tokenCalls = 0;
}

const BrokerOrderRequest _buy = BrokerOrderRequest(
  symbol: '133690',
  side: OrderSide.buy,
  quantity: 1,
  orderType: OrderTypes.limit,
  limitPrice: null, // 지정가인데 가격이 없다 — 보내기 전 거절 시험용
);

BrokerOrderRequest _buyAt(String price, {OrderSide side = OrderSide.buy}) =>
    BrokerOrderRequest(
      symbol: _buy.symbol,
      side: side,
      quantity: 1,
      orderType: OrderTypes.limit,
      limitPrice: Decimal.parse(price),
    );

/// F-14b 시나리오 한 줄의 응답(하네스 `KisScriptHandler` 꼴).
Future<http.Response> _step(List<Object> step) async {
  switch (step) {
    case <Object>['ok']:
      return _json(_okOrder());
    case <Object>['status', final int status, final String code]:
      return _json(_codeBody(code), status);
    case <Object>['rtcd1', final String code]:
      return _json(_codeBody(code));
    case <Object>['egw']:
      return _json(_codeBody('EGW00215'), 500);
    case <Object>['badjson']:
      return http.Response('<html>gateway</html>', 200);
    case <Object>['exc', 'ReadTimeout']:
      return Completer<http.Response>().future; // 시간 초과까지 답이 없다
    case <Object>['exc', 'RemoteProtocolError']:
      throw http.ClientException(
        'Connection closed before full header was received',
      );
    case <Object>['exc', 'ConnectTimeout']:
      throw const SocketException('Connection timed out');
  }
  throw StateError('모르는 각본: $step');
}

void main() {
  group('F-14b S01~S13 — 주문 전송 수 · 결과(04 §3-3 v2.38)', () {
    // (id, 각본(마지막 줄이 되풀이된다), 주문 전송 수, 결과, 잠 열, 401 뒤 토큰 재발급)
    final List<(String, List<List<Object>>, int, String, List<double>?, bool)>
    cases = <(String, List<List<Object>>, int, String, List<double>?, bool)>[
      (
        'S01 정상 접수',
        <List<Object>>[
          <Object>['ok'],
        ],
        1,
        'OK',
        null,
        false,
      ),
      (
        'S02 5xx(IGW99999) = 불명 · 무재시도',
        <List<Object>>[
          <Object>['status', 500, 'IGW99999'],
        ],
        1,
        'UNKNOWN',
        null,
        false,
      ),
      (
        'S03 ReadTimeout = 불명 · 무재시도',
        <List<Object>>[
          <Object>['exc', 'ReadTimeout'],
        ],
        1,
        'UNKNOWN',
        null,
        false,
      ),
      (
        'S04 전송 뒤 끊김 = 불명 · 무재시도',
        <List<Object>>[
          <Object>['exc', 'RemoteProtocolError'],
        ],
        1,
        'UNKNOWN',
        null,
        false,
      ),
      (
        'S05 200 + 비JSON = 불명 · 무재시도',
        <List<Object>>[
          <Object>['badjson'],
        ],
        1,
        'UNKNOWN',
        null,
        false,
      ),
      (
        'S06 4xx 명시 거절',
        <List<Object>>[
          <Object>['status', 400, 'APBK0919'],
        ],
        1,
        'REJECTED',
        null,
        false,
      ),
      (
        'S07 200 + rt_cd=1 명시 거절',
        <List<Object>>[
          <Object>['rtcd1', 'APBK0919'],
        ],
        1,
        'REJECTED',
        null,
        false,
      ),
      (
        'S08 EGW00215 소진 = 4회 · 1→2→4s · 거절',
        <List<Object>>[
          <Object>['egw'],
        ],
        4,
        'REJECTED',
        <double>[1, 2, 4],
        false,
      ),
      (
        'S09 EGW00215 뒤 성공 = 2회',
        <List<Object>>[
          <Object>['egw'],
          <Object>['ok'],
        ],
        2,
        'OK',
        <double>[1],
        false,
      ),
      (
        'S10 EGW00215 뒤 ReadTimeout = 즉시 불명',
        <List<Object>>[
          <Object>['egw'],
          <Object>['exc', 'ReadTimeout'],
        ],
        2,
        'UNKNOWN',
        null,
        false,
      ),
      (
        'S11 401 → 재발급 → 성공 = 2회',
        <List<Object>>[
          <Object>['status', 401, 'EGW00121'],
          <Object>['ok'],
        ],
        2,
        'OK',
        null,
        true,
      ),
      (
        'S12 401 지속 = 2회 · 거절',
        <List<Object>>[
          <Object>['status', 401, 'EGW00121'],
        ],
        2,
        'REJECTED',
        null,
        true,
      ),
      (
        'S13 연결 실패 = 1회 · 불명(v2.38 정합)',
        <List<Object>>[
          <Object>['exc', 'ConnectTimeout'],
        ],
        1,
        'UNKNOWN',
        null,
        false,
      ),
    ];
    for (final (
          String id,
          List<List<Object>> script,
          int sends,
          String outcome,
          List<double>? sleeps,
          bool reissue,
        )
        in cases) {
      test(id, () async {
        final _Rig rig = _Rig(
          (http.Request r, int i) =>
              _step(script[i < script.length ? i : script.length - 1]),
          timeout: const Duration(milliseconds: 50),
        );
        String got;
        try {
          final BrokerSubmitResult res = await rig.broker.submit(
            _buyAt('138655'),
          );
          got = switch (res) {
            BrokerAccepted() => 'OK',
            BrokerRejected() => 'REJECTED',
          };
        } on OrderOutcomeUnknown {
          got = 'UNKNOWN';
        }
        expect(got, outcome);
        expect(rig.posts, hasLength(sends), reason: '주문 전송 수');
        if (sleeps != null) expect(rig.sleeps, sleeps);
        if (reissue) expect(rig.tokenCalls, 2, reason: '401 뒤 토큰 재발급');
      });
    }
  });

  group('주문 POST 분류의 나머지 칸', () {
    test(
      'HTTP 500 + JSON EGW02006(서버에 없는 TR)은 명시 거절 — 실험 278 post 예약주문',
      () async {
        final _Rig rig = _Rig(
          (http.Request r, int i) async =>
              _json(_fixture('post_resv_order.json'), 500),
        );
        final BrokerSubmitResult res = await rig.broker.submit(
          _buyAt('138655'),
        );
        expect(
          res,
          isA<BrokerRejected>().having(
            (BrokerRejected b) => b.code,
            'code',
            'EGW02006',
          ),
        );
        expect(rig.posts, hasLength(1));
      },
    );

    test('장 마감 뒤 지정가 = 40580000 거절(실험 278 post)', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async =>
            _json(_fixture('post_order_buy_post.json')),
      );
      final BrokerSubmitResult res = await rig.broker.submit(_buyAt('138655'));
      expect(
        res,
        isA<BrokerRejected>().having(
          (BrokerRejected b) => b.code,
          'code',
          '40580000',
        ),
      );
    });

    test('토큰을 못 받으면 보내기 전이라 거절(TOKEN) · 주문 0', () async {
      final KisRestClient client = KisRestClient(
        MockClient(
          (http.Request r) async => r.url.path == '/oauth2/tokenP'
              ? _json(<String, String>{
                  'error_code': 'EGW00133',
                  'error_description': '1분 1회',
                }, 403)
              : throw StateError('주문이 나가면 안 된다'),
        ),
        _keys(),
        environment: KisEnvironment.mock,
        gate: KisRateGate(Duration.zero, sleep: (Duration d) async {}),
      );
      final BrokerSubmitResult res = await KisOrderBroker(client)
          .submit(_buyAt('138655'));
      expect(
        res,
        isA<BrokerRejected>().having(
          (BrokerRejected b) => b.code,
          'code',
          'TOKEN',
        ),
      );
    });

    test('4xx 비JSON = 거절 HTTP_4xx · 401 비JSON = 토큰 재발급 1회 뒤 거절', () async {
      _Rig rig = _Rig(
        (http.Request r, int i) async => http.Response('nope', 403),
      );
      expect(
        await rig.broker.submit(_buyAt('138655')),
        isA<BrokerRejected>().having(
          (BrokerRejected b) => b.code,
          'code',
          'HTTP_403',
        ),
      );
      rig = _Rig(
        (http.Request r, int i) async => http.Response('unauthorized', 401),
      );
      expect(
        await rig.broker.submit(_buyAt('138655')),
        isA<BrokerRejected>().having(
          (BrokerRejected b) => b.code,
          'code',
          'HTTP_401',
        ),
      );
      expect(rig.posts, hasLength(2));
      expect(rig.tokenCalls, 2);
    });

    test('200 JSON 인데 rt_cd 가 없으면 불명 · 접수인데 ODNO 가 없으면 불명', () async {
      // rt_cd 만 없고 ODNO 는 있다 — 접수로 읽으면 안 된다.
      _Rig rig = _Rig(
        (http.Request r, int i) async => _json(<String, Object>{
          'msg_cd': '40600000',
          'output': <String, String>{'ODNO': '0000000008'},
        }),
      );
      await expectLater(
        rig.broker.submit(_buyAt('138655')),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      rig = _Rig(
        (http.Request r, int i) async => _json(<String, Object>{
          'rt_cd': '0',
          'msg_cd': '40600000',
          'output': <String, String>{},
        }),
      );
      await expectLater(
        rig.broker.submit(_buyAt('138655')),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
    });
  });

  group('요청 꼴 — 경로 · TR · 본문(R37 Y3 · Y4)', () {
    test('주문일 = KST 날짜 — UTC 로는 전날인 장전 08:30 접수도 그날 주문이다(R37 Y8)', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async => _json(_okOrder()),
        now: DateTime.utc(2026, 10, 29, 23, 30), // KST 10-30 08:30
      );
      expect(
        await rig.broker.submit(_buyAt('138655')),
        isA<BrokerAccepted>().having(
          (BrokerAccepted a) => a.orderDate,
          'orderDate',
          const TradeDate('2026-10-30'),
        ),
      );
    });

    test(
      '모의 매수 = order-cash · VTTC0012U · 실험 278 본문 · 주문일 = KST 날짜 · ODNO = 응답',
      () async {
        final _Rig rig = _Rig(
          (http.Request r, int i) async =>
              _json(_fixture('open_order_buy_e2-buy.json')),
        );
        final BrokerSubmitResult res = await rig.broker.submit(
          _buyAt('175050'),
        );
        final http.Request p = rig.posts.single;
        expect(p.url.host, 'openapivts.koreainvestment.com');
        expect(p.url.path, KisOrderPaths.orderCash);
        expect(p.headers['tr_id'], 'VTTC0012U');
        expect(jsonDecode(p.body), <String, String>{
          'CANO': '50123456',
          'ACNT_PRDT_CD': '01',
          'PDNO': '133690',
          'ORD_DVSN': '00',
          'ORD_QTY': '1',
          'ORD_UNPR': '175050',
        });
        expect(
          res,
          isA<BrokerAccepted>()
              .having((BrokerAccepted a) => a.odno, 'odno', '0000000008')
              .having(
                (BrokerAccepted a) => a.orderDate,
                'orderDate',
                const TradeDate('2026-11-02'),
              ),
        );
      },
    );

    test('매도 = VTTC0011U · 실전 환경이면 TTTC 와 실전 호스트', () async {
      _Rig rig = _Rig(
        (http.Request r, int i) async =>
            _json(_fixture('open_order_sell_e2-sell.json')),
      );
      await rig.broker.submit(_buyAt('171580', side: OrderSide.sell));
      expect(rig.posts.single.headers['tr_id'], 'VTTC0011U');
      rig = _Rig(
        (http.Request r, int i) async => _json(_okOrder()),
        env: KisEnvironment.live,
      );
      await rig.broker.submit(_buyAt('171580'));
      expect(rig.posts.single.headers['tr_id'], 'TTTC0012U');
      expect(rig.posts.single.url.host, 'openapi.koreainvestment.com');
      expect(KisTr.of(KisEnvironment.live).sell, 'TTTC0011U');
      expect(KisTr.of(KisEnvironment.mock).dailyFills, 'VTTC0081R');
    });

    test('시장가 = ORD_DVSN 01 · ORD_UNPR 0 · 잘못된 가격 · 수량은 보내기 전에 거절', () async {
      final _Rig rig = _Rig((http.Request r, int i) async => _json(_okOrder()));
      await rig.broker.submit(
        const BrokerOrderRequest(
          symbol: '133690',
          side: OrderSide.buy,
          quantity: 3,
          orderType: OrderTypes.market,
          limitPrice: null,
        ),
      );
      final Map<String, Object?> b =
          jsonDecode(rig.posts.single.body) as Map<String, Object?>;
      expect(b['ORD_DVSN'], '01');
      expect(b['ORD_UNPR'], '0');
      expect(b['ORD_QTY'], '3');
      for (final BrokerOrderRequest bad in <BrokerOrderRequest>[
        _buy, // 지정가인데 가격 없음
        BrokerOrderRequest(
          symbol: '1',
          side: OrderSide.buy,
          quantity: 1,
          orderType: OrderTypes.limit,
          limitPrice: Decimal.parse('100.5'),
        ),
        BrokerOrderRequest(
          symbol: '1',
          side: OrderSide.buy,
          quantity: 1,
          orderType: OrderTypes.market,
          limitPrice: Decimal.parse('100'),
        ),
        BrokerOrderRequest(
          symbol: '1',
          side: OrderSide.buy,
          quantity: 0,
          orderType: OrderTypes.limit,
          limitPrice: Decimal.parse('100'),
        ),
        BrokerOrderRequest(
          symbol: '1',
          side: OrderSide.buy,
          quantity: 1,
          orderType: 'STOP',
          limitPrice: Decimal.parse('100'),
        ),
      ]) {
        await expectLater(
          rig.broker.submit(bad),
          throwsArgumentError,
          reason: bad.toString(),
        );
      }
      expect(rig.posts, hasLength(1));
    });
  });

  group('취소 — 지점은 그날 체결조회에서(R37 Y5)', () {
    test(
      '원주문 행의 지점으로 order-rvsecncl · VTTC0013U · 취소 = 새 주문번호(실험 7)',
      () async {
        final _Rig rig = _Rig(
          (http.Request r, int i) async =>
              _json(_fixture('open_cancel_e7-1.json')),
          get: (http.Request r, int i) async =>
              _json(_fixture('open_ccld_after_e7.json')),
        );
        final BrokerSubmitResult res = await rig.broker.cancel(
          '2026-10-29:0000000005',
        );
        expect(rig.gets.single.url.queryParameters['INQR_STRT_DT'], '20261029');
        final http.Request p = rig.posts.single;
        expect(p.url.path, KisOrderPaths.reviseCancel);
        expect(p.headers['tr_id'], 'VTTC0013U');
        final Map<String, Object?> b =
            jsonDecode(p.body) as Map<String, Object?>;
        expect(b['KRX_FWDG_ORD_ORGNO'], '00001');
        expect(b['ORGN_ODNO'], '0000000005');
        expect(b['RVSE_CNCL_DVSN_CD'], '02');
        expect(b['QTY_ALL_ORD_YN'], 'Y');
        expect(
          res,
          isA<BrokerAccepted>().having(
            (BrokerAccepted a) => a.odno,
            'odno',
            '0000000002',
          ),
        );
      },
    );

    test('체결조회에 원주문 행이 없으면(취소 행만 같은 번호여도) 보내지 않고 ORDER_NOT_FOUND', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async => throw StateError('취소가 나가면 안 된다'),
        get: (http.Request r, int i) async =>
            _json(_fixture('open_ccld_after_e7.json')),
      );
      for (final String no in <String>[
        '2026-10-29:0000000099',
        '2026-10-29:0000000006',
      ]) {
        expect(
          await rig.broker.cancel(no),
          isA<BrokerRejected>().having(
            (BrokerRejected b) => b.code,
            'code',
            'ORDER_NOT_FOUND',
          ),
        );
      }
      expect(rig.posts, isEmpty);
    });

    test('지난 날 주문 취소 = 서버가 40320000 으로 거절(실험 8 next)', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async =>
            _json(_fixture('next_cancel_next-prevday.json')),
        get: (http.Request r, int i) async =>
            _json(_fixture('next_ccld_next_prevday.json')),
      );
      final Map<String, Object?> prev = _fixture('next_ccld_next_prevday.json');
      final List<Map<String, Object?>> prevRows =
          (prev['output1']! as List<Object?>).cast<Map<String, Object?>>();
      final String kept =
          prevRows.firstWhere(
                (Map<String, Object?> r) =>
                    r['cncl_yn'] == 'N' && r['rmn_qty'] == '1',
              )['odno']!
              as String;
      expect(
        await rig.broker.cancel('2026-10-29:$kept'),
        isA<BrokerRejected>().having(
          (BrokerRejected b) => b.code,
          'code',
          '40320000',
        ),
      );
    });

    test('꼴이 틀린 주문번호는 거절(ArgumentError)', () async {
      final _Rig rig = _Rig((http.Request r, int i) async => _json(_okOrder()));
      await expectLater(rig.broker.cancel('0000000005'), throwsArgumentError);
    });
  });

  group('일별주문체결조회 해석(R37 Y6 · 02 BrokerDailyFill · 07 §6-3)', () {
    test('원주문 행 · 취소 행 · 누적 체결 · 지점', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async => _json(_okOrder()),
        get: (http.Request r, int i) async =>
            _json(_fixture('open_ccld_after_e7.json')),
      );
      final List<DailyFillRow> rows = await rig.broker.dailyFills(
        const TradeDate('2026-10-29'),
      );
      expect(rows, hasLength(6));
      final DailyFillRow cancel = rows.first;
      expect(cancel.isCancelRow, isTrue);
      expect(cancel.originalOdno, '0000000005');
      final DailyFillRow orig = rows[1];
      expect(orig.isCancelRow, isFalse);
      expect(orig.side, OrderSide.buy);
      expect(orig.orderDate, const TradeDate('2026-10-29'));
      expect(orig.brokerOrderNo, '2026-10-29:0000000005');
      expect(orig.cancelConfirmedQty, 1);
      expect(orig.remainingQty, 0);
      expect(orig.cumFilledQty, 0);
      final Map<String, String> q = rig.gets.single.url.queryParameters;
      expect(q['INQR_END_DT'], '20261029');
      expect(q['PDNO'], '');
      expect(rig.gets.single.headers['tr_id'], 'VTTC0081R');
    });

    test('체결된 매수 · 매도 행 → 체결 델타(R31 키) — 실험 2', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async => _json(_okOrder()),
        get: (http.Request r, int i) async =>
            _json(_fixture('next_ccld_next_prevday.json')),
      );
      final List<DailyFillRow> rows = await rig.broker.dailyFills(
        const TradeDate('2026-10-29'),
      );
      final List<FillDelta> deltas = fillDeltas(
        rows,
        const <String, RecordedFill>{},
      );
      expect(
        deltas.map((FillDelta f) => (f.side, f.quantity)).toSet(),
        <(OrderSide, int)>{(OrderSide.buy, 1), (OrderSide.sell, 1)},
      );
      expect(
        deltas.every((FillDelta f) => f.executionId.endsWith('#1')),
        isTrue,
      );
      // 남긴 주문 = 지난 날 행의 잔여 1(마감 실효로 읽는다 — R32 O4).
      expect(
        rows.where((DailyFillRow r) => !r.isCancelRow && r.remainingQty == 1),
        hasLength(1),
      );
    });

    test(
      '이어받기 — tr_cont M · ctx_area_nk100 이 있으면 다음 쪽(tr_cont N) · 없으면 끝',
      () async {
        final Map<String, Object?> page = _fixture('open_ccld_after_e7.json');
        final _Rig rig = _Rig(
          (http.Request r, int i) async => _json(_okOrder()),
          get: (http.Request r, int i) async => i == 0
              ? _json(
                  <String, Object?>{
                    ...page,
                    'ctx_area_fk100': 'FK1',
                    'ctx_area_nk100': 'NK1',
                  },
                  200,
                  <String, String>{'tr_cont': 'M'},
                )
              : _json(page, 200, <String, String>{'tr_cont': 'D'}),
        );
        final List<DailyFillRow> rows = await rig.broker.dailyFills(
          const TradeDate('2026-10-29'),
        );
        expect(rows, hasLength(12));
        expect(rig.gets, hasLength(2));
        expect(rig.gets[1].headers['tr_cont'], 'N');
        expect(rig.gets[1].url.queryParameters['CTX_AREA_NK100'], 'NK1');
        expect(rig.gets[1].url.queryParameters['CTX_AREA_FK100'], 'FK1');
      },
    );

    test('이어받기가 끝나지 않으면 10쪽에서 KisUnavailable · 조회 거절은 KisRejected', () async {
      final Map<String, Object?> page = <String, Object?>{
        ..._fixture('open_ccld_after_e7.json'),
        'ctx_area_nk100': 'NK',
      };
      _Rig rig = _Rig(
        (http.Request r, int i) async => _json(_okOrder()),
        get: (http.Request r, int i) async =>
            _json(page, 200, <String, String>{'tr_cont': 'F'}),
      );
      await expectLater(
        rig.broker.dailyFills(const TradeDate('2026-10-29')),
        throwsA(isA<KisUnavailable>()),
      );
      expect(rig.gets, hasLength(kKisFillPageLimit));
      rig = _Rig(
        (http.Request r, int i) async => _json(_okOrder()),
        get: (http.Request r, int i) async => _json(_codeBody('APBK0013')),
      );
      await expectLater(
        rig.broker.dailyFills(const TradeDate('2026-10-29')),
        throwsA(isA<KisRejected>()),
      );
    });

    test('모르는 매도매수 구분 · 빠진 칸 · 날짜 꼴은 FormatException(지어내지 않는다)', () {
      final Map<String, Object?> row = Map<String, Object?>.of(
        (_fixture('open_ccld_after_e7.json')['output1']! as List<Object?>)
                .first!
            as Map<String, Object?>,
      );
      expect(parseKisFillRow(row).row.symbol, '133690');
      expect(
        () =>
            parseKisFillRow(<String, Object?>{...row, 'sll_buy_dvsn_cd': '03'}),
        throwsFormatException,
      );
      expect(
        () =>
            parseKisFillRow(<String, Object?>{...row}..remove('tot_ccld_qty')),
        throwsFormatException,
      );
      expect(
        () =>
            parseKisFillRow(<String, Object?>{...row, 'ord_dt': '2026-10-29'}),
        throwsFormatException,
      );
      expect(kisDate('20261030'), const TradeDate('2026-10-30'));
      expect(kisYmd(const TradeDate('2026-10-30')), '20261030');
    });
  });

  group('예수금(R37 Y7)', () {
    Map<String, Object?> balance(String? prvs) => <String, Object?>{
      'rt_cd': '0',
      'msg_cd': '20310000',
      'output1': <Object?>[],
      'output2': <Object?>[
        <String, String>{
          'dnca_tot_amt': '10000000',
          'prvs_rcdl_excc_amt': ?prvs,
        },
      ],
    };

    test('잔고 output2[0].prvs_rcdl_excc_amt · VTTC8434R · 음수 = 0', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async => _json(_okOrder()),
        get: (http.Request r, int i) async => _json(balance('9500000')),
      );
      expect(await rig.broker.orderableCashKrw(), Decimal.parse('9500000'));
      expect(rig.gets.single.headers['tr_id'], 'VTTC8434R');
      expect(rig.gets.single.url.path, KisOrderPaths.balance);
      expect(parseKisOrderableCash(balance('-1200')), Decimal.zero);
    });

    test('칸이 없거나 숫자가 아니면 FormatException · 조회 거절은 KisRejected', () async {
      expect(() => parseKisOrderableCash(balance(null)), throwsFormatException);
      expect(
        () => parseKisOrderableCash(balance('abc')),
        throwsFormatException,
      );
      expect(
        () => parseKisOrderableCash(<String, Object?>{'output2': <Object?>[]}),
        throwsFormatException,
      );
      final _Rig rig = _Rig(
        (http.Request r, int i) async => _json(_okOrder()),
        get: (http.Request r, int i) async => _json(_codeBody('APBK0013')),
      );
      await expectLater(
        rig.broker.orderableCashKrw(),
        throwsA(isA<KisRejected>()),
      );
    });
  });

  test('현재가 — 기준가 · 호가 · 상하한 · 거래정지(R37 Y1)', () {
    final Map<String, Object?> body = jsonDecode(
      File('test/fixtures/kis/kr_price_133690.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final KisPrice p = parseKisPrice(body);
    expect(p.basePrice, Decimal.parse('171025'));
    expect(p.tickSize, Decimal.parse('5'));
    expect(p.upperLimit, Decimal.parse('222330'));
    expect(p.lowerLimit, Decimal.parse('119720'));
    expect(p.halted, isFalse);
  });

  group('순서기 한 바퀴 — KisOrderBroker 가 core OrderBroker 로 붙는다', () {
    OrderIntentDraft draft() => OrderIntentDraft(
      executionDate: const TradeDate('2026-11-02'),
      account: 'pension',
      strategyId: P0sStrategyIds.sleeveB,
      symbol: '133690',
      side: OrderSide.buy,
      quantity: 1,
      orderType: OrderTypes.limit,
      limitPrice: Decimal.parse('175050'),
      sizingPrice: Decimal.parse('175050'),
      logicalDecisionId: 'B-SMA-2026-10-30',
      decisionId: 'B-SMA-2026-10-30@2026-11-02',
      instrument: InstrumentKind.etf,
    );
    final LimitConfig limits = LimitConfig(
      maxNotionalPct: 0.05,
      riskBudgetPct: 0.0035,
      satelliteMaxPositions: 8,
      satelliteMaxPerSector: 3,
      maxRiskExposure: 0.85,
      maxLeverage: 1.0,
      maxPositions: 30,
      maxOrdersPerDay: 60,
      maxOrderValueKrw: Decimal.parse('20000000'),
      maxDailyLossPct: 0.03,
      orderTypeWhitelist: const <String>{OrderTypes.limit, OrderTypes.market},
    );
    final LimitState state = LimitState(
      totalEquity: Decimal.parse('100000000'),
      ordersToday: null,
      riskExposureAfter: 0.5,
      leverageAfter: 0.9,
      positionsAfter: 5,
      satellitePositionsAfter: null,
      satelliteSectorCountAfter: null,
      satelliteAllocation: null,
      satelliteExposure: null,
      satelliteDeployedBefore: null,
      dailyPnlPct: 0,
      fxRateUsdKrw: null,
      strategyRegistered: null,
      tradingBlocked: null,
      journalMissing: null,
      tierBUnjudged: null,
    );
    ExecutionContext ctx(FakeOrderLedger ledger, OrderBroker broker) =>
        ExecutionContext(
          ledger: ledger,
          broker: broker,
          limitConfig: limits,
          execPolicy: ExecPolicy.execute,
          operatingMode: OperatingMode.autoTrade,
          configHash: 'cfg-test',
        );

    test('접수 → SUBMITTED · broker_order_no = {주문일}:{ODNO}', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async =>
            _json(_fixture('open_order_buy_e2-buy.json')),
      );
      final FakeOrderLedger ledger = FakeOrderLedger(
        registeredStrategies: <String>{P0sStrategyIds.sleeveB},
      );
      final ExecutionOutcome o = await executeIntent(
        draft(),
        state,
        ctx(ledger, rig.broker),
      );
      expect(o.status, ExecutionStatus.submitted);
      expect(o.brokerOrderNo, '2026-11-02:0000000008');
      expect(rig.posts, hasLength(1));
    });

    test('시간 초과 → UNKNOWN · 주문 전송 1회(NR-2)', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 50),
      );
      final FakeOrderLedger ledger = FakeOrderLedger(
        registeredStrategies: <String>{P0sStrategyIds.sleeveB},
      );
      await expectLater(
        executeIntent(draft(), state, ctx(ledger, rig.broker)),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      expect(ledger.records.values.single.status, IntentStatus.unknown);
      expect(rig.posts, hasLength(1));
    });
  });

  group('🆕 E10g 잔고 — 대사 포트(BrokerBalanceSource · R41 J1~J9)', () {
    /// 실응답(2026-11-04 01:07 · 보유 0주)에 시험이 보유 행을 넣는다(J2 — 합성 파일은 두지 않는다).
    Map<String, Object?> withRows(
      List<Map<String, String>> rows, {
      String nk = '',
      String fk = '',
      String? cash,
    }) {
      final Map<String, Object?> b = _fixture('balance_balance.json');
      final List<Object?> o2 = b['output2']! as List<Object?>;
      return <String, Object?>{
        ...b,
        'output1': rows,
        'ctx_area_nk100': nk,
        'ctx_area_fk100': fk,
        if (cash != null)
          'output2': <Object?>[
            <String, Object?>{
              ...o2.first! as Map<String, Object?>,
              'dnca_tot_amt': cash,
            },
          ],
      };
    }

    _Rig rigOf(
      Future<http.Response> Function(http.Request r, int i) get, {
      KisEnvironment env = KisEnvironment.mock,
    }) => _Rig(
      (http.Request r, int i) async => _json(_okOrder()),
      get: get,
      env: env,
    );

    test('실응답(보유 0주) — 보유 없음 · 관측 현금 = dnca_tot_amt · 예수금 = prvs_rcdl_excc_amt(R37 Y7 실측) · 요청 인자', () async {
      final _Rig rig = rigOf(
        (http.Request r, int i) async =>
            _json(_fixture('balance_balance.json')),
      );
      final BrokerBalance b = await rig.broker.balance();
      expect(b.holdings, isEmpty);
      expect(b.cashKrw, Decimal.parse('49999965'));
      expect(await rig.broker.orderableCashKrw(), Decimal.parse('49999965'));
      final http.Request q = rig.gets.first;
      expect(q.url.path, KisOrderPaths.balance);
      expect(q.headers['tr_id'], 'VTTC8434R');
      expect(q.url.queryParameters, <String, String>{
        'CANO': '50123456',
        'ACNT_PRDT_CD': q.url.queryParameters['ACNT_PRDT_CD']!,
        'AFHR_FLPR_YN': 'N',
        'OFL_YN': '',
        'INQR_DVSN': '02',
        'UNPR_DVSN': '01',
        'FUND_STTL_ICLD_YN': 'N',
        'FNCG_AMT_AUTO_RDPT_YN': 'N',
        'PRCS_DVSN': '00',
        'CTX_AREA_FK100': '',
        'CTX_AREA_NK100': '',
      });
      expect(rig.gets, hasLength(2));
      expect(rig.posts, isEmpty);
    });

    test('보유 행 — 종목마다 합 · 0주는 넣지 않는다 · 대문자 칸도 읽는다', () async {
      final _Rig rig = rigOf(
        (http.Request r, int i) async => _json(
          withRows(<Map<String, String>>[
            <String, String>{'pdno': '133690', 'hldg_qty': '3'},
            <String, String>{'PDNO': '411060', 'HLDG_QTY': '2'},
            <String, String>{'pdno': '133690', 'hldg_qty': '2'},
            <String, String>{'pdno': '069500', 'hldg_qty': '0'},
          ]),
        ),
      );
      expect((await rig.broker.balance()).holdings, <String, int>{
        '133690': 5,
        '411060': 2,
      });
    });

    test('보유 행의 빠진 칸 · 정수 아님 · 음수 · 객체 아님 = FormatException(지어내지 않는다)', () {
      for (final List<Object?> rows in <List<Object?>>[
        <Object?>[
          <String, String>{'hldg_qty': '1'},
        ],
        <Object?>[
          <String, String>{'pdno': '133690'},
        ],
        <Object?>[
          <String, String>{'pdno': '133690', 'hldg_qty': '1.5'},
        ],
        <Object?>[
          <String, String>{'pdno': '133690', 'hldg_qty': '-1'},
        ],
        <Object?>[
          <String, String>{'pdno': ' ', 'hldg_qty': '1'},
        ],
        <Object?>['133690'],
      ]) {
        expect(
          () => parseKisHoldings(rows),
          throwsFormatException,
          reason: '$rows',
        );
      }
      expect(parseKisHoldings(const <Object?>[]), isEmpty);
    });

    test('관측 현금 — 칸 없음 · 숫자 아님 · output2 없음 = null(관측만이라 막지 않는다)', () {
      expect(
        parseKisObservedCash(
          withRows(const <Map<String, String>>[], cash: 'abc'),
        ),
        isNull,
      );
      expect(
        parseKisObservedCash(<String, Object?>{'output2': <Object?>[]}),
        isNull,
      );
      expect(parseKisObservedCash(<String, Object?>{}), isNull);
      expect(
        parseKisObservedCash(<String, Object?>{
          'output2': <Object?>[
            <String, String>{'nass_amt': '1'},
          ],
        }),
        isNull,
      );
      expect(
        parseKisObservedCash(<String, Object?>{
          'output2': <String, String>{'dnca_tot_amt': '7'},
        }),
        Decimal.parse('7'),
      );
    });

    test('이어받기 — tr_cont M · nk 가 있으면 다음 쪽(tr_cont N · FK · NK) · 행을 모은다 · 현금 = 첫 쪽', () async {
      final _Rig rig = rigOf(
        (http.Request r, int i) async => i == 0
            ? _json(
                withRows(
                  <Map<String, String>>[
                    <String, String>{'pdno': '133690', 'hldg_qty': '3'},
                  ],
                  nk: 'NK1',
                  fk: 'FK1',
                ),
                200,
                <String, String>{'tr_cont': 'M'},
              )
            : _json(
                withRows(<Map<String, String>>[
                  <String, String>{'pdno': '133690', 'hldg_qty': '2'},
                ], cash: '1'),
                200,
                <String, String>{'tr_cont': 'D'},
              ),
      );
      final BrokerBalance b = await rig.broker.balance();
      expect(b.holdings, <String, int>{'133690': 5});
      expect(b.cashKrw, Decimal.parse('49999965'));
      expect(rig.gets, hasLength(2));
      expect(rig.gets[0].headers['tr_cont'] ?? '', '');
      expect(rig.gets[1].headers['tr_cont'], 'N');
      expect(rig.gets[1].url.queryParameters['CTX_AREA_NK100'], 'NK1');
      expect(rig.gets[1].url.queryParameters['CTX_AREA_FK100'], 'FK1');
    });

    test('tr_cont F 도 다음 쪽 · nk 가 비면 끝 · 10쪽 상한 = KisUnavailable · 거절 = KisRejected', () async {
      _Rig rig = rigOf(
        (http.Request r, int i) async => _json(
          withRows(const <Map<String, String>>[]),
          200,
          <String, String>{'tr_cont': 'F'},
        ),
      );
      expect((await rig.broker.balance()).holdings, isEmpty);
      expect(rig.gets, hasLength(1));
      rig = rigOf(
        (http.Request r, int i) async => _json(
          withRows(const <Map<String, String>>[], nk: 'NK'),
          200,
          <String, String>{'tr_cont': 'F'},
        ),
      );
      await expectLater(rig.broker.balance(), throwsA(isA<KisUnavailable>()));
      expect(rig.gets, hasLength(kKisBalancePageLimit));
      rig = rigOf(
        (http.Request r, int i) async => _json(_codeBody('APBK0013')),
      );
      await expectLater(rig.broker.balance(), throwsA(isA<KisRejected>()));
    });

    test('실전 환경 = TTTC8434R(TR 은 환경에서만 나온다)', () async {
      final _Rig rig = rigOf(
        (http.Request r, int i) async =>
            _json(_fixture('balance_balance.json')),
        env: KisEnvironment.live,
      );
      await rig.broker.balance();
      expect(rig.gets.single.headers['tr_id'], 'TTTC8434R');
    });

    test('대사 경로 — KIS 브로커(잔고 + 체결조회)로 runReconciliation: 일치 = MATCHED · 원장이 더 많으면 재대사 뒤 BLOCKED', () async {
      final Map<String, Object?> noFills = <String, Object?>{
        'rt_cd': '0',
        'msg_cd': '20310000',
        'output1': <Object?>[],
        'output2': <String, Object?>{},
        'ctx_area_fk100': '',
        'ctx_area_nk100': '',
      };
      final _Rig rig = rigOf(
        (http.Request r, int i) async => r.url.path == KisOrderPaths.balance
            ? _json(
                withRows(<Map<String, String>>[
                  <String, String>{'pdno': '133690', 'hldg_qty': '5'},
                ]),
              )
            : _json(noFills),
      );
      final FakeOrderLedger ledger = FakeOrderLedger();
      ledger.positions[(P0sStrategyIds.sleeveB, '133690')] = 5;
      Future<ReconReport> run() => runReconciliation(
        ledger: ledger,
        brokers: <String, OrderBroker>{'pension': rig.broker},
        balances: <String, BrokerBalanceSource>{'pension': rig.broker},
        accountByStrategy: const <String, String>{
          P0sStrategyIds.sleeveB: 'pension',
        },
        tradeDate: const TradeDate('2026-11-04'),
        nowUtc: () => DateTime.utc(2026, 11, 4, 6, 45),
        sleep: (Duration d) async {},
      );
      ReconReport r = await run();
      expect(r.action, ReconAction.matched);
      expect(r.cashKrw['pension'], Decimal.parse('49999965'));
      ledger.positions[(P0sStrategyIds.sleeveB, '133690')] = 7;
      r = await run();
      expect(r.action, ReconAction.blocked);
      expect((r.blocking.single.ledger, r.blocking.single.broker), (7, 5));
      expect(rig.posts, isEmpty);
    });
  });
}
