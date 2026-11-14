// E11p · P13 ② — 실 Android Keystore 로 도는 시험(에뮬레이터 · 폰 · 로컬만 · CI 밖).
//
//   flutter test integration_test/keystore_test.dart -d <기기>
//
// 🔴 실키 · 실값을 쓰지 않는다 — 시험 칸 이름은 `e11p.it.` 접두이고 끝에 지운다.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// 앱 전용 폴더(시험이 같은 프로세스라 dart:io 로 닿는다).
const String _noBackup =
    '/data/user/0/com.billybeom.autoalphaquant.operator/no_backup';

Uint8List _b(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final AndroidSealedBox box = AndroidSealedBox();
  final AndroidSecretVault vault = AndroidSecretVault();
  final SecretId a = SecretId('e11p.it.a');
  final SecretId b = SecretId('e11p.it.b');

  tearDownAll(() async {
    for (final SecretId id in await vault.ids()) {
      if (id.value.startsWith('e11p.it.')) await vault.delete(id);
    }
  });

  // 🔴 06 M4-9 게이트 «재부팅 생존» — 앞 실행이 남긴 봉함 · 칸을 이번 실행(새 프로세스 · 재부팅 뒤)이 연다.
  //    처음 실행은 남기기만 한다(로그 `CROSS: 남김`) · 두 번째부터 연다(`CROSS: 열림`).
  //    실측 순서: 실행 → `adb reboot` → 부팅 끝 → 실행.
  testWidgets('🔴 다시 뜬 프로세스 · 재부팅 뒤에도 앞 실행의 봉함 · 칸이 열린다', (_) async {
    final File mark = File('$_noBackup/e11p_it_cross.bin');
    final SecretId c = SecretId('e11p.cross.c');
    if (mark.existsSync()) {
      expect(
        await box.open(mark.readAsBytesSync(), aad: 'e11p-cross'),
        _b('cross-plain'),
      );
      expect(await vault.read(c), 'cross-value');
      debugPrint('CROSS: 열림');
    } else {
      debugPrint('CROSS: 남김');
    }
    mark.writeAsBytesSync(await box.seal(_b('cross-plain'), aad: 'e11p-cross'));
    await vault.write(c, 'cross-value');
  });

  group('봉함(DekSealedBox)', () {
    final Uint8List plain = _b('{"draft":"연습 값 1"}');
    const String aad = 'v1|LIVE|draft|k1';

    testWidgets('왕복 · 봉투 꼴(판 1 · nonce 12 · 태그 16)', (_) async {
      final Uint8List s = await box.seal(plain, aad: aad);
      expect(s.length, 1 + 12 + plain.length + 16);
      expect(s[0], 1);
      expect(await box.open(s, aad: aad), plain);
    });

    testWidgets('같은 평문도 봉투가 매번 다르다(nonce 무작위)', (_) async {
      final Uint8List s1 = await box.seal(plain, aad: aad);
      final Uint8List s2 = await box.seal(plain, aad: aad);
      expect(s1, isNot(equals(s2)));
    });

    testWidgets('🔴 aad · 변조 · 잘림 · 판 · 빈 값 = null(던지지 않는다)', (_) async {
      final Uint8List s = await box.seal(plain, aad: aad);
      expect(await box.open(s, aad: 'v1|SIM|draft|k1'), isNull);
      final Uint8List flipped = Uint8List.fromList(s)..[20] ^= 0x01;
      expect(await box.open(flipped, aad: aad), isNull);
      expect(
        await box.open(Uint8List.sublistView(s, 0, s.length - 1), aad: aad),
        isNull,
      );
      final Uint8List v2 = Uint8List.fromList(s)..[0] = 2;
      expect(await box.open(v2, aad: aad), isNull);
      expect(await box.open(Uint8List(0), aad: aad), isNull);
    });

    testWidgets('🔴 DEK 파일은 no_backup 에 · 평문 DEK 가 아니다', (_) async {
      await box.seal(plain, aad: aad);
      final File f = File('$_noBackup/aaq_dek_v1.bin');
      expect(f.existsSync(), isTrue);
      expect(f.lengthSync(), 1 + 12 + 32 + 16); // 감싼 DEK(32) 봉투
    });
  });

  group('금고(KeystoreVault)', () {
    testWidgets('없음 = null · 쓰기 · 읽기 · 덮어쓰기 · 목록 · 지우기', (_) async {
      expect(await vault.read(a), isNull);
      await vault.write(a, '연습-값-α');
      await vault.write(b, 'v-b');
      expect(await vault.read(a), '연습-값-α');
      await vault.write(a, '연습-값-β');
      expect(await vault.read(a), '연습-값-β');
      expect(await vault.ids(), containsAll(<SecretId>[a, b]));
      await vault.delete(a);
      expect(await vault.read(a), isNull);
      expect(await vault.ids(), isNot(contains(a)));
      await vault.delete(a); // 없어도 성공
    });

    testWidgets('🔴 칸 파일에 평문이 없다', (_) async {
      await vault.write(a, 'PLAINTEXT-MARKER-e11p');
      final List<int> raw = File('$_noBackup/aaq_vault/e11p.it.a.bin')
          .readAsBytesSync();
      expect(
        latin1.decode(raw, allowInvalid: true),
        isNot(contains('PLAINTEXT-MARKER')),
      );
    });

    testWidgets('🔴 칸을 다른 이름으로 옮겨 붙이면 못 엶 = 오류(null 이 아니다)', (_) async {
      await vault.write(a, 'v-a');
      final File src = File('$_noBackup/aaq_vault/e11p.it.a.bin');
      src.copySync('$_noBackup/aaq_vault/e11p.it.b.bin');
      await expectLater(
        vault.read(b),
        throwsA(
          isA<SecretVaultError>()
              .having(
                (SecretVaultError e) => e.message,
                'message',
                contains('읽을 수 없다'),
              )
              .having(
                (SecretVaultError e) => e.message,
                'no value',
                isNot(contains('v-a')),
              ),
        ),
      );
      // 시크릿 스캔 목록도 조용히 줄지 않는다.
      await expectLater(
        readAllSecretValues(vault),
        throwsA(isA<SecretVaultError>()),
      );
      await vault.delete(b);
    });

    testWidgets('🔴 깨진 칸 = 오류 · 꼴 아닌 파일 이름은 목록에 없다', (_) async {
      File('$_noBackup/aaq_vault/e11p.it.a.bin')
          .writeAsBytesSync(<int>[1, 2, 3]);
      await expectLater(vault.read(a), throwsA(isA<SecretVaultError>()));
      File('$_noBackup/aaq_vault/Bad Name.bin').writeAsBytesSync(<int>[1]);
      expect(
        (await vault.ids()).map((SecretId i) => i.value),
        isNot(contains('Bad Name')),
      );
      File('$_noBackup/aaq_vault/Bad Name.bin').deleteSync();
      await vault.delete(a);
    });
  });
}
