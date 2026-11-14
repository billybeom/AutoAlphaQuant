// E11p3b-4 — KIS 모의 자격증명 칸이 실 Android Keystore 금고에서 돈다(에뮬레이터 · 로컬만 · CI 밖 · 설계 13 §8 R95).
//
//   flutter test integration_test/kis_vault_test.dart -d <기기>
//
// 🔴 실키를 쓰지 않는다 — 가짜 값을 넣고 끝에 지운다.
// 🔴 기기에 이미 모의 키 칸이 있으면(발주자 폰) 아무것도 건드리지 않고 건너뛴다 — 시험이 사람이 넣은 키를 지우지 않게.

import 'package:app_operator_android/platform/platform.dart';
import 'package:broker_gateway/broker_gateway.dart';
import 'package:core_engine/core_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final AndroidSecretVault vault = AndroidSecretVault();
  final KisCredentialSlots slots = KisCredentialSlots.of(KisKeySet.paper);
  final KisCredentials fake = KisCredentials(
    environment: KisEnvironment.mock,
    appKey: 'fakePaperAppKey${'A' * 21}',
    appSecret: 'fakePaperSecret${'Z' * 165}',
    accountNo: '50123456',
  );

  testWidgets('🔴 모의 세트 = 쓰면 읽힌다 · 스캔이 값을 본다 · 지우면 없음', (_) async {
    final Set<SecretId> before = await vault.ids();
    if (slots.all.any(before.contains)) {
      markTestSkipped('기기에 모의 키 칸이 있다 — 건드리지 않는다');
      return;
    }
    try {
      expect(
        await readKisCredentials(vault, KisKeySet.paper),
        isA<KisCredentialsMissing>(),
      );
      await storeKisCredentials(vault, KisKeySet.paper, fake);
      final KisCredentials got = ((await readKisCredentials(
        vault,
        KisKeySet.paper,
      )) as KisCredentialsStored).credentials;
      expect(got.environment, KisEnvironment.mock);
      expect(got.appKey, fake.appKey);
      expect(got.appSecret, fake.appSecret);
      expect(got.accountNo, fake.accountNo);
      expect(got.productCode, '01');
      expect(
        await readAllSecretValues(vault),
        containsAll(<String>[fake.appKey, fake.appSecret, fake.accountNo]),
      );
    } finally {
      await deleteKisCredentials(vault, KisKeySet.paper);
    }
    expect(
      await readKisCredentials(vault, KisKeySet.paper),
      isA<KisCredentialsMissing>(),
    );
    expect((await vault.ids()).intersection(slots.all.toSet()), isEmpty);
  });
}
