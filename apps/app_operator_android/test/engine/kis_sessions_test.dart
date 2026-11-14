// E11p3c-1 KIS 세션(설계 13 §8 R97) — 금고(가짜) · 클라이언트 만들기 기록(네트워크 0).

import 'package:app_operator_android/engine/kis_sessions.dart';
import 'package:broker_gateway/broker_gateway.dart';
import 'package:core_engine/core_engine.dart' show SecretVaultError;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final String _appKey = 'fakePaperAppKey${'A' * 21}';
final String _secret = 'fakePaperSecret${'Z' * 165}';
const String _account = '50123456';

Map<String, String> _paper({String? appKey}) => <String, String>{
  'kis.paper.app_key': appKey ?? _appKey,
  'kis.paper.app_secret': _secret,
  'kis.paper.account_no': _account,
  'kis.paper.product_code': '01',
};

void main() {
  late MemorySecretVault vault;
  late List<KisCredentials> made;
  late KisSessions s;

  setUp(() {
    vault = MemorySecretVault(_paper());
    made = <KisCredentials>[];
    s = KisSessions(
      vault: vault,
      http: MockClient((http.Request r) async => http.Response('', 500)),
      clientOf: (http.Client h, KisCredentials c, KisTokenStore t) {
        made.add(c);
        return KisRestClient(h, c, environment: c.environment, tokens: t);
      },
    );
  });

  test(
    '🔴 SIM = 모의 세트 클라이언트 · 같은 키면 같은 클라이언트(유량 문 하나) · 토큰 금고는 한 번만 올린다',
    () async {
      final KisRestClient a = await s.clientFor(RunMode.simInternal);
      final KisRestClient b = await s.clientFor(RunMode.simBroker);
      expect(identical(a, b), true);
      expect(a.environment, KisEnvironment.mock);
      expect(made, hasLength(1));
      expect(made.single.appKey, _appKey);
      expect(made.single.accountNo, _account);
      expect(
        vault.calls.where((String c) => c == 'read:kis.tokens'),
        hasLength(1),
      );
    },
  );

  test('🔴 키가 바뀌면(회전) 다음 회차부터 새 클라이언트', () async {
    final KisRestClient a = await s.clientFor(RunMode.simInternal);
    await vault.write(
      KisCredentialSlots.of(KisKeySet.paper).appKey,
      'fakeRotatedKey${'B' * 22}',
    );
    final KisRestClient b = await s.clientFor(RunMode.simInternal);
    expect(identical(a, b), false);
    expect(made, hasLength(2));
    expect(made.last.appKey, 'fakeRotatedKey${'B' * 22}');
    expect(
      vault.calls.where((String c) => c == 'read:kis.tokens'),
      hasLength(1),
    );
  });

  test('🔴 칸이 없으면 = KisSessionUnavailable(칸 이름만 · 값 0)', () async {
    await vault.delete(KisCredentialSlots.of(KisKeySet.paper).appSecret);
    final Object e = await s
        .clientFor(RunMode.simInternal)
        .then<Object>((_) => 'ok', onError: (Object e) => e);
    expect(e, isA<KisSessionUnavailable>());
    expect('$e', contains('KIS_PAPER'));
    expect('$e', contains('kis.paper.app_secret'));
    for (final String v in <String>[_appKey, _secret, _account]) {
      expect('$e'.contains(v), false);
    }
    expect(made, isEmpty);
  });

  test('꼴이 아니면 = KisSessionUnavailable(사유 · 값 0)', () async {
    await vault.write(
      KisCredentialSlots.of(KisKeySet.paper).accountNo,
      '5012345X',
    );
    final Object e = await s
        .clientFor(RunMode.simInternal)
        .then<Object>((_) => 'ok', onError: (Object e) => e);
    expect(e, isA<KisSessionUnavailable>());
    expect('$e', contains('KIS_PAPER: '));
    expect('$e'.contains('5012345X'), false);
  });

  test('🔴 live = 아직 세트 없음 → KisSessionUnavailable · 금고를 읽지 않는다', () async {
    await expectLater(
      s.clientFor(RunMode.live),
      throwsA(isA<KisSessionUnavailable>()),
    );
    expect(vault.calls, isEmpty);
  });

  test('🔴 금고를 못 열면 그 오류 그대로(«없음»으로 바꾸지 않는다)', () async {
    vault.failReadsOf.add('kis.paper.account_no');
    await expectLater(
      s.clientFor(RunMode.simInternal),
      throwsA(isA<SecretVaultError>()),
    );
  });
}
