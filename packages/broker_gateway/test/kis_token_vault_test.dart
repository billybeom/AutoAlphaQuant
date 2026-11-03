// 토큰 보관 키 · 금고 보관(설계 13 §8 R44 E8 · E9 · 지도 D18 · X11).
//
// 🔵 잡는 것: ① 키 = (환경 · 앱키 지문) — 같은 환경 두 계좌가 서로 덮지 않는다 ② 금고 보관 = 기동 때 올리기 ·
//    쓰기 메모리 즉시 + 금고 비동기(순서 보존) · 쓰기 실패는 던지지 않고 센다 · 깨진 칸 · 읽기 실패 = 빈 것
//    ③ 다음 기동에 금고 토큰을 다시 써서 재발급(알림톡)이 안 난다 ④ 문자열 · 금고에 앱키 값 0.

import 'dart:async';
import 'dart:convert';

import 'package:broker_gateway/broker_gateway.dart';
import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

class _Clock {
  DateTime t = DateTime.utc(2026, 11, 4, 9);

  DateTime now() => t;

  Future<void> sleep(Duration d) async => t = t.add(d);
}

KisCredentials _keys(String appKey, {String account = '50123456'}) =>
    KisCredentials(
      environment: KisEnvironment.mock,
      appKey: appKey,
      appSecret: 'fakeSecretValue${'Z' * 60}',
      accountNo: account,
    );

final KisCredentials _main = _keys('PSmainAppKey0123456789abcdef');
final KisCredentials _isa = _keys(
  'PSisaAppKey00123456789abcdef',
  account: '50999999',
);

/// 발급 요청마다 앱키 끝 4자로 다른 토큰을 준다 · 조회는 정상.
class _Kis {
  final List<String> issuedFor = <String>[];

  http.Client get client => MockClient((http.Request r) async {
    if (r.url.path == '/oauth2/tokenP') {
      final String appKey =
          (jsonDecode(r.body) as Map<String, Object?>)['appkey']! as String;
      issuedFor.add(appKey);
      return http.Response(
        jsonEncode(<String, Object>{
          'access_token':
              'tok-${appKey.substring(appKey.length - 4)}-${issuedFor.length}',
          'token_type': 'Bearer',
          'expires_in': 86400,
        }),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    }
    return http.Response(
      jsonEncode(<String, String>{'rt_cd': '0', 'msg_cd': 'X', 'msg1': 'ok'}),
      200,
      headers: <String, String>{'content-type': 'application/json'},
    );
  });
}

KisRestClient _client(
  _Kis kis,
  KisCredentials c,
  KisTokenStore store,
  _Clock clock,
) => KisRestClient(
  kis.client,
  c,
  environment: KisEnvironment.mock,
  tokens: store,
  now: clock.now,
  sleep: clock.sleep,
);

/// 쓰기를 붙잡아 두는 금고 — 첫 쓰기는 [release] 전까지 끝나지 않는다.
class _HeldVault implements SecretVault {
  final MemorySecretVault inner = MemorySecretVault();
  final Completer<void> release = Completer<void>();
  int _writes = 0;

  @override
  Future<String?> read(SecretId id) => inner.read(id);

  @override
  Future<void> write(SecretId id, String value) async {
    _writes++;
    if (_writes == 1) await release.future;
    await inner.write(id, value);
  }

  @override
  Future<void> delete(SecretId id) => inner.delete(id);

  @override
  Future<Set<SecretId>> ids() => inner.ids();
}

void main() {
  group('보관 키 = (환경 · 앱키 지문)(R44 E8 · X11)', () {
    test('같은 환경 두 앱키 = 다른 키 · 같은 키 세트 = 같은 키 · 문자열에 앱키 값 0', () {
      final KisTokenKey a = KisTokenKey.of(_main);
      final KisTokenKey b = KisTokenKey.of(_isa);
      expect(a == b, isFalse);
      expect(a.slot == b.slot, isFalse);
      expect(KisTokenKey.of(_keys(_main.appKey)), a);
      expect(KisTokenKey.of(_keys(_main.appKey)).hashCode, a.hashCode);
      expect(a.slot, 'mock:${secretFingerprint(_main.appKey)}');
      expect(a.toString(), 'KisTokenKey(${a.slot})');
      expect(a.toString().contains(_main.appKey), isFalse);
      expect(
        const KisTokenKey(KisEnvironment.mock, 'aaaa1111') ==
            const KisTokenKey(KisEnvironment.live, 'aaaa1111'),
        isFalse,
      );
    });

    test('🔴 두 계좌가 한 보관처를 나눠도 서로 덮지 않는다 — 재발급(알림톡) 2회뿐', () async {
      final _Kis kis = _Kis();
      final _Clock clock = _Clock();
      final MemoryKisTokenStore store = MemoryKisTokenStore();
      final KisRestClient m = _client(kis, _main, store, clock);
      final KisRestClient i = _client(kis, _isa, store, clock);
      final String tm = (await m.token()).accessToken;
      final String ti = (await i.token()).accessToken;
      expect(tm == ti, isFalse);
      expect((await m.token()).accessToken, tm);
      expect((await i.token()).accessToken, ti);
      await m.get('/uapi/x', 'T', const <String, String>{});
      await i.get('/uapi/x', 'T', const <String, String>{});
      expect(kis.issuedFor, <String>[_main.appKey, _isa.appKey]);
      expect(m.tokenKey, KisTokenKey.of(_main));
    });
  });

  group('금고 보관 VaultKisTokenStore(R44 E8 · D18)', () {
    final KisTokenKey key = KisTokenKey.of(_main);
    final KisTokenKey other = KisTokenKey.of(_isa);

    test('쓰기 = 메모리 즉시 · flush 뒤 금고 한 칸 · 다음 기동이 그대로 올린다', () async {
      final MemorySecretVault v = MemorySecretVault();
      final VaultKisTokenStore s = await VaultKisTokenStore.load(v);
      expect((s.read(key), s.loadFailed), (null, false));
      s.write(key, KisToken('tok-A', DateTime.utc(2026, 11, 5, 9)));
      expect(s.read(key)!.accessToken, 'tok-A');
      await s.flush();
      expect(VaultKisTokenStore.vaultId.value, 'kis.tokens');
      final String raw = v.peek('kis.tokens')!;
      expect((jsonDecode(raw) as Map<String, Object?>).keys, <String>[
        key.slot,
      ]);
      expect(raw.contains(_main.appKey), isFalse);
      final VaultKisTokenStore again = await VaultKisTokenStore.load(v);
      expect(again.read(key)!.accessToken, 'tok-A');
      expect(again.read(key)!.expiresAt, DateTime.utc(2026, 11, 5, 9));
      expect(again.read(other), isNull);
    });

    test('🔴 순서 보존 — 늦게 끝난 앞 쓰기가 뒤 내용을 덮지 않는다 · 지우기도 순서대로', () async {
      final _HeldVault v = _HeldVault();
      final VaultKisTokenStore s = await VaultKisTokenStore.load(v);
      s.write(key, KisToken('tok-1', DateTime.utc(2026, 11, 5)));
      s.write(key, KisToken('tok-2', DateTime.utc(2026, 11, 5)));
      s.write(other, KisToken('tok-o', DateTime.utc(2026, 11, 5)));
      s.clear(other);
      await Future<void>.delayed(Duration.zero);
      v.release.complete();
      await s.flush();
      // 붙잡힌 앞 쓰기가 (사슬이 없다면) 뒤늦게 끝날 틈을 준다.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final Map<String, Object?> m =
          jsonDecode(v.inner.peek('kis.tokens')!) as Map<String, Object?>;
      expect(m.keys, <String>[key.slot]);
      expect((m[key.slot]! as Map<String, Object?>)['access_token'], 'tok-2');
    });

    test('🔴 금고 쓰기 실패 = 던지지 않는다 · 센다 · 메모리 토큰은 그대로 쓴다', () async {
      final MemorySecretVault v = MemorySecretVault()
        ..failWritesTo.add('kis.tokens');
      final VaultKisTokenStore s = await VaultKisTokenStore.load(v);
      s.write(key, KisToken('tok-A', DateTime.utc(2026, 11, 5)));
      s.clear(other);
      await s.flush();
      expect(s.writeFailures, 2);
      expect(s.read(key)!.accessToken, 'tok-A');
      v.failWritesTo.clear();
      s.write(other, KisToken('tok-O', DateTime.utc(2026, 11, 5)));
      await s.flush();
      expect(s.writeFailures, 2);
      expect(
        (jsonDecode(v.peek('kis.tokens')!) as Map<String, Object?>).keys
            .toSet(),
        <String>{key.slot, other.slot},
      );
    });

    test('기동 때 금고 읽기 실패 · 깨진 칸 · 깨진 행 = 빈 것으로 시작(매매를 막지 않는다)', () async {
      final MemorySecretVault v = MemorySecretVault()
        ..failReadsOf.add('kis.tokens');
      final VaultKisTokenStore s = await VaultKisTokenStore.load(v);
      expect((s.read(key), s.loadFailed), (null, true));
      final MemorySecretVault broken = MemorySecretVault(<String, String>{
        'kis.tokens': '{깨짐',
      });
      expect((await VaultKisTokenStore.load(broken)).loadFailed, isFalse);
      expect((await VaultKisTokenStore.load(broken)).read(key), isNull);
      final MemorySecretVault mixed = MemorySecretVault(<String, String>{
        'kis.tokens': jsonEncode(<String, Object?>{
          key.slot: <String, String>{
            'access_token': 'tok-A',
            'expires_at': '2026-11-05T00:00:00.000Z',
          },
          other.slot: <String, String>{'access_token': 'x'},
          'junk': 3,
        }),
      });
      final VaultKisTokenStore ms = await VaultKisTokenStore.load(mixed);
      expect(ms.read(key)!.accessToken, 'tok-A');
      expect(ms.read(other), isNull);
    });

    test('🔴 다음 기동 = 금고 토큰을 다시 쓴다(재발급 0) · 문자열에 토큰 값 0', () async {
      final _Kis kis = _Kis();
      final _Clock clock = _Clock();
      final MemorySecretVault v = MemorySecretVault();
      final VaultKisTokenStore s1 = await VaultKisTokenStore.load(v);
      final String t1 = (await _client(
        kis,
        _main,
        s1,
        clock,
      ).token()).accessToken;
      await s1.flush();
      clock.t = clock.t.add(const Duration(hours: 3));
      final VaultKisTokenStore s2 = await VaultKisTokenStore.load(v);
      expect((await _client(kis, _main, s2, clock).token()).accessToken, t1);
      expect(kis.issuedFor, hasLength(1));
      expect(s2.toString().contains(t1), isFalse);
      expect(s2.toString(), 'VaultKisTokenStore(1칸 · 쓰기 실패 0)');
      expect(v.calls.join(' ').contains(t1), isFalse);
    });
  });
}
