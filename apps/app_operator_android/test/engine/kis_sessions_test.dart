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
      clientOf:
          (http.Client h, KisCredentials c, KisTokenStore t, KisRateGate g) {
            made.add(c);
            return KisRestClient(
              h,
              c,
              environment: c.environment,
              tokens: t,
              gate: g,
            );
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

  group(
    '🆕 R207 실전 개시 — 모드 세트(KIS_LIVE) · 계좌 별칭 → 세트(연금저축 22) · 앱키 하나 = 유량 문 하나',
    () {
      final String liveKey = 'fakeLiveAppKey${'C' * 22}';
      final String isaKey = 'fakeIsaAppKey${'D' * 23}';
      final String liveSecret = 'fakeLiveSecret${'Y' * 166}';
      const String liveAccount = '87654321';
      const String isaAccount = '76543210';

      Future<void> putLive({bool isa = true}) async {
        await storeKisCredentials(
          vault,
          KisKeySet.live,
          KisCredentials(
            environment: KisEnvironment.live,
            appKey: liveKey,
            appSecret: liveSecret,
            accountNo: liveAccount,
          ),
        );
        if (isa) {
          await storeKisCredentials(
            vault,
            KisKeySet.isa,
            KisCredentials(
              environment: KisEnvironment.live,
              appKey: isaKey,
              appSecret: liveSecret,
              accountNo: isaAccount,
            ),
          );
        } else {
          await deleteKisCredentials(vault, KisKeySet.isa);
        }
      }

      test('별칭 → 키(P0S 대응 · 앞뒤 공백 무시 · 모르는 별칭 = null)', () {
        // 🆕 R262(A-2) — general = 위탁 01 고정(금고 값을 쓰지 않는다).
        expect(liveAccountKeyOf('general'), (
          set: KisKeySet.live,
          productCode: '01',
        ));
        expect(liveAccountKeyOf('pension'), (
          set: KisKeySet.live,
          productCode: '22',
        ));
        expect(liveAccountKeyOf(' isa '), (
          set: KisKeySet.isa,
          productCode: null,
        ));
        expect(liveAccountKeyOf('brokerage'), isNull);
      });

      test('🔴 live 모드 세트 = 실전 종합계좌 세트 · 실전 환경', () async {
        await putLive();
        final KisRestClient m = await s.clientFor(RunMode.live);
        expect(m.environment, KisEnvironment.live);
        expect(made.single.appKey, liveKey);
        expect(made.single.accountNo, liveAccount);
        expect(made.single.productCode, '01');
      });

      test('🔴 general = 모드 세트와 같은 클라이언트 · pension = 상품코드 22 · 같은 앱키 = 같은 유량 문 · isa = 다른 문 · 토큰 금고 한 번', () async {
        await putLive();
        final KisRestClient m = await s.clientFor(RunMode.live);
        final KisRestClient g = await s.liveAccountClient('general');
        final KisRestClient p = await s.liveAccountClient('pension');
        final KisRestClient i = await s.liveAccountClient('isa');
        expect(identical(m, g), true);
        expect(identical(g, p), false);
        expect(identical(g.gate, p.gate), true);
        expect(identical(g.gate, i.gate), false);
        expect(identical(await s.liveAccountClient('pension'), p), true);
        expect(identical(await s.liveAccountClient('general'), g), true);
        expect(
          (p.credentials.accountNo, p.credentials.productCode),
          (liveAccount, '22'),
        );
        expect(
          (i.credentials.appKey, i.credentials.accountNo, i.environment),
          (isaKey, isaAccount, KisEnvironment.live),
        );
        expect(made, hasLength(3));
        final List<String> tokenReads = vault.calls
            .where((String c) => c == 'read:kis.tokens')
            .toList();
        expect(tokenReads, hasLength(1));
      });

      test('🆕 A-2(미결 233 ⓐ) — 실전 칸에 연금저축 상품코드(22)가 저장돼 있어도 general = 위탁 01 · pension = 22 · 두 별칭이 한 계좌로 모이지 않는다', () async {
        await storeKisCredentials(
          vault,
          KisKeySet.live,
          KisCredentials(
            environment: KisEnvironment.live,
            appKey: liveKey,
            appSecret: liveSecret,
            accountNo: liveAccount,
            productCode: '22',
          ),
        );
        final KisRestClient g = await s.liveAccountClient('general');
        final KisRestClient p = await s.liveAccountClient('pension');
        expect(
          (g.credentials.accountNo, g.credentials.productCode),
          (liveAccount, '01'),
        );
        expect(
          (p.credentials.accountNo, p.credentials.productCode),
          (liveAccount, '22'),
        );
        expect(identical(g, p), false);
        // 같은 앱키 = 같은 유량 문(상품코드만 다르다).
        expect(identical(g.gate, p.gate), true);
      });

      test('🔴 모르는 별칭 = KisSessionUnavailable(별칭만) · 금고를 읽지 않는다', () async {
        final Object e = await s
            .liveAccountClient('brokerage')
            .then<Object>((_) => 'ok', onError: (Object e) => e);
        expect(e, isA<KisSessionUnavailable>());
        expect('$e', contains('brokerage'));
        expect(vault.calls, isEmpty);
        expect(made, isEmpty);
      });

      test('🔴 ISA 칸 없음 = KisSessionUnavailable(세트 · 칸 이름만 · 값 0)', () async {
        await putLive(isa: false);
        final Object e = await s
            .liveAccountClient('isa')
            .then<Object>((_) => 'ok', onError: (Object e) => e);
        expect(e, isA<KisSessionUnavailable>());
        expect('$e', contains('KIS_ISA'));
        expect('$e', contains('kis.isa.app_key'));
        for (final String v in <String>[liveKey, liveSecret, liveAccount]) {
          expect('$e'.contains(v), false);
        }
        expect(made, isEmpty);
      });
    },
  );

  test('🔴 금고를 못 열면 그 오류 그대로(«없음»으로 바꾸지 않는다)', () async {
    vault.failReadsOf.add('kis.paper.account_no');
    await expectLater(
      s.clientFor(RunMode.simInternal),
      throwsA(isA<SecretVaultError>()),
    );
  });
}
