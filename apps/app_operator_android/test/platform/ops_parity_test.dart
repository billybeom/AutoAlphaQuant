// E11p2 · P6 · P7 · P10 · P11 — Dart ↔ Kotlin · 매니페스트 글자 대조(CI 는 Gradle 을 돌리지 않는다).

import 'dart:io';

import 'package:app_operator_android/platform/platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_runtime/trading_runtime.dart' show FgsChannel;

const String _kt =
    'android/app/src/main/kotlin/com/billybeom/autoalphaquant/operator';

String _read(String p) => File(p).readAsStringSync().replaceAll(_crlf, '\n');

final RegExp _crlf = RegExp(r'\r\n');

String _ktConst(String src, String name) {
  final RegExpMatch? m = RegExp('const val $name = "([^"]*)"').firstMatch(src);
  expect(m, isNotNull, reason: 'Kotlin 상수 $name');
  return m!.group(1)!;
}

void main() {
  test('운영 채널 이름 · FGS 채널 id 가 Kotlin 과 같다', () {
    expect(
      _ktConst(_read('$_kt/ops/OpsChannel.kt'), 'OPS'),
      OperatorChannelNames.ops,
    );
    final String n = _read('$_kt/ops/OpsNotifications.kt');
    expect(_ktConst(n, 'STATUS'), FgsChannel.opsStatus.id);
    expect(_ktConst(n, 'P0'), FgsChannel.opsP0.id);
    expect(
      kOpsChannelNames.keys,
      unorderedEquals(FgsChannel.values.map((FgsChannel c) => c.id)),
    );
  });

  test('깨어남 까닭 글자가 Kotlin 과 같다', () {
    final String r = _read('$_kt/ops/Receivers.kt');
    final Map<String, WakeReason> want = <String, WakeReason>{
      'ALARM': WakeReason.alarm,
      'BOOT': WakeReason.boot,
      'PACKAGE_REPLACED': WakeReason.packageReplaced,
      'TIME_SET': WakeReason.timeSet,
      'TIMEZONE': WakeReason.timezone,
      'START': WakeReason.start,
    };
    for (final MapEntry<String, WakeReason> e in want.entries) {
      expect(_ktConst(r, e.key), e.value.wire, reason: e.key);
    }
  });

  test('Kotlin 이 받는 메서드 이름 = Dart 가 부르는 이름', () {
    final String c = _read('$_kt/ops/OpsChannel.kt');
    for (final String m in <String>[
      'ensureChannels',
      'postFgs',
      'startService',
      'arm',
      'diagnose',
      'ready',
      'idle',
      'paths',
      'takeLaunchLink',
    ]) {
      expect(c, contains('"$m" ->'), reason: m);
    }
    for (final String m in <String>['onWake', 'onLink']) {
      expect(c, contains('invokeMethod("$m"'), reason: m);
    }
  });

  test('paths 응답 키 = Dart 가 읽는 키 · 엔진 원장은 noBackupFilesDir(백업 차단 이중)', () {
    final String c = _read('$_kt/ops/OpsChannel.kt');
    expect(c, contains('"files" to ctx.filesDir.absolutePath'));
    expect(c, contains('"noBackup" to ctx.noBackupFilesDir.absolutePath'));
  });

  test(
    '🔴 FGS 를 올리기 전에 채널부터(에뮬레이터 실측 결함 · Bad notification for startForeground)',
    () {
      final String svc = _read('$_kt/ops/EngineService.kt');
      final int ensure = svc.indexOf('OpsNotifications.ensureExisting(this)');
      final int start = svc.indexOf('startForeground(');
      expect(ensure, greaterThan(0));
      expect(ensure, lessThan(start));
      expect(
        _read('$_kt/ops/OpsChannel.kt'),
        contains('OpsNotifications.ensureExisting(ctx)'),
      );
    },
  );

  group('🔴 매니페스트', () {
    final String m = _read('android/app/src/main/AndroidManifest.xml');

    test('FGS = specialUse(+ 설명) · 내보내지 않음', () {
      expect(m, contains('android:name=".ops.EngineService"'));
      expect(m, contains('android:foregroundServiceType="specialUse"'));
      expect(m, contains('android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE'));
      expect(m, isNot(contains('foregroundServiceType="dataSync"')));
    });

    test(
      '권한 — FGS · specialUse · 알림 · 부팅 · 정확 알람(USE + SCHEDULE≤32) · wakelock',
      () {
        for (final String p in <String>[
          'android.permission.FOREGROUND_SERVICE"',
          'android.permission.FOREGROUND_SERVICE_SPECIAL_USE"',
          'android.permission.POST_NOTIFICATIONS"',
          'android.permission.RECEIVE_BOOT_COMPLETED"',
          'android.permission.USE_EXACT_ALARM"',
          'android.permission.WAKE_LOCK"',
        ]) {
          expect(m, contains(p), reason: p);
        }
        expect(
          m,
          contains(
            'android.permission.SCHEDULE_EXACT_ALARM"\n        android:maxSdkVersion="32"',
          ),
        );
      },
    );

    test('수신기 — 알람 = 내보내지 않음 · 부팅 = 4 action · 웹에서 여는 BROWSABLE 0', () {
      expect(
        m,
        contains(
          'android:name=".ops.AlarmReceiver"\n            android:exported="false"',
        ),
      );
      for (final String a in <String>[
        'android.intent.action.BOOT_COMPLETED',
        'android.intent.action.MY_PACKAGE_REPLACED',
        'android.intent.action.TIME_SET',
        'android.intent.action.TIMEZONE_CHANGED',
      ]) {
        expect(m, contains(a), reason: a);
      }
      expect(m, isNot(contains('BROWSABLE')));
    });
  });

  test('🔴 Kotlin 은 상태 문장을 짓지 않는다(한글 문자열 리터럴 0)', () {
    final RegExp hangulLiteral = RegExp(r'"[^"\n]*[가-힣][^"\n]*"');
    for (final FileSystemEntity f in Directory('$_kt/ops').listSync()) {
      if (f is! File || !f.path.endsWith('.kt')) continue;
      final String body = f
          .readAsLinesSync()
          .where(
            (String l) =>
                !l.trimLeft().startsWith('//') &&
                !l.trimLeft().startsWith('*') &&
                !l.trimLeft().startsWith('/**'),
          )
          .join('\n');
      expect(hangulLiteral.hasMatch(body), isFalse, reason: f.path);
    }
  });
}
