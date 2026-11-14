// KIS 자격증명 금고 칸(E11p3b-4 · 설계 13 §8 R95).
//
// 🔵 잡는 것: ① 칸 이름 넷 · 세트 표기 ② 읽기 = 있음 · 없음(하나라도) · 꼴 아님 · 못 엶은 던진다
//    ③ 쓰기 = 지운 뒤 쓴다(끊겨도 섞인 세트 없음) · 다른 환경 키 거절 ④ 모드 → 세트 · 기동 판정
//    ⑤ 문자열에 값 0 ⑥ 시크릿 스캔 · 가림이 값을 그대로 찾는다.

import 'package:broker_gateway/broker_gateway.dart';
import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:test/test.dart';

final String _appKey = 'fakePaperAppKey${'A' * 21}';
final String _secret = 'fakePaperSecret${'Z' * 165}';
const String _account = '50123456';

KisCredentials _creds({
  KisEnvironment env = KisEnvironment.mock,
  String? appKey,
  String account = _account,
  String product = '01',
}) => KisCredentials(
  environment: env,
  appKey: appKey ?? _appKey,
  appSecret: _secret,
  accountNo: account,
  productCode: product,
);

Map<String, String> _stored({String account = _account}) => <String, String>{
  'kis.paper.app_key': _appKey,
  'kis.paper.app_secret': _secret,
  'kis.paper.account_no': account,
  'kis.paper.product_code': '01',
};

/// 쓰기만 실패(지우기는 된다) — 쓰기 단계 끊김.
class _WriteOnlyFail extends MemorySecretVault {
  _WriteOnlyFail(this.failing);

  final String failing;

  @override
  Future<void> write(SecretId id, String value) async {
    if (id.value == failing) throw const SecretVaultError('쓰기 실패(주입)');
    return super.write(id, value);
  }
}

void main() {
  test('🔴 칸 이름 넷 · 표기 = KIS_PAPER · 모의 환경', () {
    final KisCredentialSlots s = KisCredentialSlots.of(KisKeySet.paper);
    expect(s.all.map((SecretId x) => x.value), <String>[
      'kis.paper.app_key',
      'kis.paper.app_secret',
      'kis.paper.account_no',
      'kis.paper.product_code',
    ]);
    expect(KisKeySet.paper.wire, 'KIS_PAPER');
    expect(KisKeySet.paper.environment, KisEnvironment.mock);
  });

  group('읽기', () {
    test('🔴 넷 다 있다 = 모의 자격증명', () async {
      final KisCredentialRead r = await readKisCredentials(
        MemorySecretVault(_stored()),
        KisKeySet.paper,
      );
      final KisCredentials c = (r as KisCredentialsStored).credentials;
      expect(c.environment, KisEnvironment.mock);
      expect(c.appKey, _appKey);
      expect(c.appSecret, _secret);
      expect(c.accountNo, _account);
      expect(c.productCode, '01');
    });

    test('빈 금고 = 없음(넷 다 · 읽는 차례)', () async {
      final KisCredentialRead r = await readKisCredentials(
        MemorySecretVault(),
        KisKeySet.paper,
      );
      expect(
        (r as KisCredentialsMissing).missing.map((SecretId x) => x.value),
        <String>[
          'kis.paper.app_key',
          'kis.paper.app_secret',
          'kis.paper.account_no',
          'kis.paper.product_code',
        ],
      );
    });

    test('🔴 하나라도 없거나 비면 세트 전체가 없다(섞어 쓰지 않는다)', () async {
      final Map<String, String> m = _stored()..remove('kis.paper.app_secret');
      m['kis.paper.product_code'] = '';
      final KisCredentialRead r = await readKisCredentials(
        MemorySecretVault(m),
        KisKeySet.paper,
      );
      expect(
        (r as KisCredentialsMissing).missing.map((SecretId x) => x.value),
        <String>['kis.paper.app_secret', 'kis.paper.product_code'],
      );
    });

    test('🔴 꼴 아님 = 사유만(값 0)', () async {
      final KisCredentialRead r = await readKisCredentials(
        MemorySecretVault(_stored(account: '5012345X')),
        KisKeySet.paper,
      );
      final String reason = (r as KisCredentialsMalformed).reason;
      expect(reason, startsWith('KIS_PAPER: '));
      expect(reason, contains('계좌번호'));
      expect(reason.contains('5012345X'), false);
      expect(r.toString().contains('5012345X'), false);
    });

    test('🔴 못 엶 = 던진다(«없음»으로 바꾸지 않는다)', () async {
      final MemorySecretVault v = MemorySecretVault(_stored())
        ..failReadsOf.add('kis.paper.account_no');
      await expectLater(
        readKisCredentials(v, KisKeySet.paper),
        throwsA(isA<SecretVaultError>()),
      );
    });
  });

  group('쓰기 · 지우기', () {
    test('🔴 쓰면 읽힌다 · 차례 = 넷 다 지운 뒤 넷 다 쓴다(앱키 마지막)', () async {
      final MemorySecretVault v = MemorySecretVault();
      await storeKisCredentials(v, KisKeySet.paper, _creds());
      expect(v.calls, <String>[
        'delete:kis.paper.app_key',
        'delete:kis.paper.app_secret',
        'delete:kis.paper.account_no',
        'delete:kis.paper.product_code',
        'write:kis.paper.account_no',
        'write:kis.paper.product_code',
        'write:kis.paper.app_secret',
        'write:kis.paper.app_key',
      ]);
      expect(
        await readKisCredentials(v, KisKeySet.paper),
        isA<KisCredentialsStored>(),
      );
    });

    test('🔴 덮어쓰기가 도중에 끊기면 «없음» — 옛 앱키 + 새 시크릿 같은 섞인 세트가 없다', () async {
      final MemorySecretVault v = MemorySecretVault(_stored())
        ..failWritesTo.add('kis.paper.app_key');
      await expectLater(
        storeKisCredentials(
          v,
          KisKeySet.paper,
          _creds(appKey: 'fakeNewAppKey${'B' * 23}'),
        ),
        throwsA(isA<SecretVaultError>()),
      );
      // 앱키 지우기부터 실패 — 아무 칸도 바뀌지 않았다(옛 세트 그대로).
      expect(v.peek('kis.paper.app_key'), _appKey);
      expect(v.peek('kis.paper.app_secret'), _secret);

      final MemorySecretVault w = MemorySecretVault(_stored())
        ..failWritesTo.add('kis.paper.app_secret');
      await expectLater(
        storeKisCredentials(w, KisKeySet.paper, _creds()),
        throwsA(isA<SecretVaultError>()),
      );
      // 앱키는 지웠고 시크릿 지우기에서 끊김 → 읽으면 «없음».
      expect(
        await readKisCredentials(w, KisKeySet.paper),
        isA<KisCredentialsMissing>(),
      );
    });

    test('쓰기 단계에서 끊겨도 «없음»', () async {
      final _WriteOnlyFail v = _WriteOnlyFail('kis.paper.app_secret');
      await expectLater(
        storeKisCredentials(v, KisKeySet.paper, _creds()),
        throwsA(isA<SecretVaultError>()),
      );
      expect(v.peek('kis.paper.account_no'), _account);
      expect(
        await readKisCredentials(v, KisKeySet.paper),
        isA<KisCredentialsMissing>(),
      );
    });

    test('🔴 실전 키를 모의 칸에 = KisGuardError · 칸을 건드리지 않는다', () async {
      final MemorySecretVault v = MemorySecretVault(_stored());
      await expectLater(
        storeKisCredentials(
          v,
          KisKeySet.paper,
          _creds(env: KisEnvironment.live),
        ),
        throwsA(isA<KisGuardError>()),
      );
      expect(v.calls, isEmpty);
    });

    test('지우기 = 넷 다 · 없어도 성공', () async {
      final MemorySecretVault v = MemorySecretVault(_stored());
      await deleteKisCredentials(v, KisKeySet.paper);
      expect(await v.ids(), isEmpty);
      await deleteKisCredentials(v, KisKeySet.paper);
    });
  });

  group('모드 → 세트 · 기동 판정', () {
    test('🔴 SIM 계열 = 모의 세트 · live = 아직 없음', () {
      expect(kisKeySetFor(RunMode.simInternal), KisKeySet.paper);
      expect(kisKeySetFor(RunMode.simBroker), KisKeySet.paper);
      expect(kisKeySetFor(RunMode.live), isNull);
    });

    test('🔴 세트 환경 = 모드 환경(모든 모드)', () {
      for (final RunMode m in RunMode.values) {
        expect(kisKeySetFits(m), true, reason: m.name);
        final KisKeySet? set = kisKeySetFor(m);
        if (set != null) {
          expect(set.environment, kisEnvironmentFor(m), reason: m.name);
        }
      }
    });

    test('🔴 대응이 틀리면(live → 모의 세트) 기동 판정 = 어긋남', () {
      KisKeySet? wrong(RunMode m) => KisKeySet.paper;
      expect(kisKeySetFits(RunMode.live, setFor: wrong), false);
      expect(kisKeySetFits(RunMode.simInternal, setFor: wrong), true);
      expect(kisKeySetFits(RunMode.live, setFor: (RunMode m) => null), true);
    });

    test('읽은 모의 자격증명은 SIM 모드에 맞고 live 에는 맞지 않는다', () async {
      final KisCredentials c = ((await readKisCredentials(
        MemorySecretVault(_stored()),
        KisKeySet.paper,
      )) as KisCredentialsStored).credentials;
      expect(kisCredentialsFit(c, RunMode.simInternal), true);
      expect(kisCredentialsFit(c, RunMode.simBroker), true);
      expect(kisCredentialsFit(c, RunMode.live), false);
    });
  });

  test('🔴 문자열 · 결과에 값 0', () async {
    final KisCredentialRead r = await readKisCredentials(
      MemorySecretVault(_stored()),
      KisKeySet.paper,
    );
    for (final String s in <String>[
      r.toString(),
      KisCredentialsMissing(KisCredentialSlots.of(KisKeySet.paper).all)
          .toString(),
    ]) {
      expect(s.contains(_appKey), false);
      expect(s.contains(_secret), false);
      expect(s.contains(_account), false);
    }
  });

  test('🔴 스캔 · 가림이 금고 값을 하나씩 찾는다(계좌 8자리 포함 · 상품코드 무시)', () async {
    final MemorySecretVault v = MemorySecretVault();
    await storeKisCredentials(v, KisKeySet.paper, _creds());
    final List<String> values = await readAllSecretValues(v);
    expect(values, containsAll(<String>[_appKey, _secret, _account]));
    final String leaked = 'GET ?appkey=$_appKey&CANO=$_account&ACNT_PRDT_CD=01';
    expect(
      redactSecrets(leaked, values),
      'GET ?appkey=$kRedacted&CANO=$kRedacted&ACNT_PRDT_CD=01',
    );
  });
}
