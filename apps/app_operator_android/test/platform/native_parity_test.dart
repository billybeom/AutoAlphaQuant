// E11p · P4 · P5 — Dart ↔ Kotlin · 매니페스트 글자 대조(CI 는 Gradle 을 돌리지 않으므로 글자로 묶는다).
//
// ① 채널 이름 · 오류 코드가 양쪽에서 같은 글자인가 ② 금고 칸 이름 꼴이 Dart `SecretId` 와 같은가
// ③ 🔴 백업 차단(06 M4-9 ⑤ «OS 백업 반출 0») — allowBackup=false · D2D 포함 전 도메인 제외.

import 'dart:io';

import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart';
import 'package:flutter_test/flutter_test.dart';

const String _kt =
    'android/app/src/main/kotlin/com/billybeom/autoalphaquant/operator';

String _read(String path) => File(path).readAsStringSync();

String _ktConst(String src, String name) {
  final RegExpMatch? m = RegExp('const val $name = "([^"]*)"').firstMatch(src);
  expect(m, isNotNull, reason: 'Kotlin 상수 $name 이 없다');
  return m!.group(1)!;
}

void main() {
  test('채널 이름이 Kotlin 과 같다', () {
    final String src = _read('$_kt/OperatorChannels.kt');
    expect(_ktConst(src, 'VAULT'), OperatorChannelNames.vault);
    expect(_ktConst(src, 'SEALED_BOX'), OperatorChannelNames.sealedBox);
    expect(_ktConst(src, 'CODE_BAD_ARGS'), OperatorChannelCodes.badArgs);
    expect(_ktConst(src, 'CODE_SEAL_FAILED'), OperatorChannelCodes.sealFailed);
  });

  test('금고 오류 코드가 Kotlin 과 같다', () {
    final String src = _read('$_kt/security/KeystoreVault.kt');
    expect(_ktConst(src, 'CODE_BAD_ID'), OperatorChannelCodes.badId);
    expect(_ktConst(src, 'CODE_UNREADABLE'), OperatorChannelCodes.unreadable);
    expect(_ktConst(src, 'CODE_UNAVAILABLE'), OperatorChannelCodes.unavailable);
    expect(_ktConst(src, 'CODE_IO'), OperatorChannelCodes.io);
  });

  test('금고 칸 이름 꼴 = Dart SecretId 꼴(경로 넘김 차단)', () {
    final String src = _read('$_kt/security/KeystoreVault.kt');
    final RegExpMatch m = RegExp(r'val ID = Regex\("([^"]*)"\)')
        .firstMatch(src)!;
    final RegExp kt = RegExp(m.group(1)!.replaceAll(r'\\', r'\'));
    for (final String ok in <String>[
      'a',
      'kis.live.app_key',
      'hc-1_x.y',
      'a' * 64,
    ]) {
      expect(kt.hasMatch(ok), isTrue, reason: ok);
      expect(() => SecretId(ok), returnsNormally, reason: ok);
    }
    for (final String bad in <String>[
      '',
      '.a',
      '../x',
      'A',
      'a/b',
      'a' * 65,
      '-a',
    ]) {
      expect(kt.hasMatch(bad), isFalse, reason: bad);
      expect(() => SecretId(bad), throwsArgumentError, reason: bad);
    }
  });

  test('🔴 백업 차단 — allowBackup=false · fullBackupContent=false · dataExtractionRules', () {
    final String m = _read('android/app/src/main/AndroidManifest.xml');
    expect(m, contains('android:allowBackup="false"'));
    expect(m, contains('android:fullBackupContent="false"'));
    expect(
      m,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });

  test('🔴 데이터 추출 규칙 — 클라우드 · 기기 간 이전 둘 다 전 도메인 제외 · include 0', () {
    final String x = _read(
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    );
    expect(x, isNot(contains('<include')));
    const List<String> domains = <String>[
      'root',
      'file',
      'database',
      'sharedpref',
      'external',
      'device_root',
      'device_file',
      'device_database',
      'device_sharedpref',
    ];
    for (final String section in <String>['cloud-backup', 'device-transfer']) {
      final RegExpMatch s = RegExp('<$section>([\\s\\S]*?)</$section>')
          .firstMatch(x)!;
      for (final String d in domains) {
        expect(
          s.group(1),
          contains('<exclude domain="$d" path="." />'),
          reason: '$section · $d',
        );
      }
    }
  });

  test('🔴 비밀 파일은 noBackupFilesDir 에만', () {
    final String ch = _read('$_kt/OperatorChannels.kt');
    expect(ch, contains('noBackupFilesDir, KeystoreVault.DIR'));
    expect(ch, contains('DekSealedBox(app.noBackupFilesDir)'));
    for (final String f in <String>[
      'OperatorChannels.kt',
      'security/DekSealedBox.kt',
      'security/KeystoreVault.kt',
    ]) {
      final String src = _read('$_kt/$f');
      expect(src, isNot(contains('filesDir,')), reason: f);
      expect(src, isNot(contains('getExternal')), reason: f);
      expect(src, isNot(contains('Log.')), reason: '$f — 로그 0');
    }
  });
}
