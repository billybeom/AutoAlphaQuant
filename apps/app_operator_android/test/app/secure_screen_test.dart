// E11p3d-5 캡처 막기 · 바깥 링크(설계 13 §8 R107).

import 'package:app_operator_android/app/secure_screen.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AppLinkOpener, AppRoutes;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart' show ShellBodyBuilder, ShellRouteBodies;

class _Opener implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

void main() {
  late List<bool> sets;
  late SecureScreen screen;

  setUp(() {
    sets = <bool>[];
    screen = SecureScreen((bool on) async => sets.add(on));
  });

  group('겹침 세기', () {
    test('🔴 첫 진입에 켜고 마지막 이탈에 끈다 · 0 에서 더 나가지 않는다', () async {
      await screen.enter();
      await screen.enter();
      expect(sets, <bool>[true]);
      await screen.exit();
      expect(sets, <bool>[true]);
      expect(screen.depth, 1);
      await screen.exit();
      expect(sets, <bool>[true, false]);
      await screen.exit();
      expect(sets, <bool>[true, false]);
      expect(screen.depth, 0);
      await screen.enter();
      expect(sets, <bool>[true, false, true]);
    });
  });

  testWidgets('🔴 SecureScope = 서 있는 동안 켜짐 · 사라지면 꺼짐', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SecureScope(screen: screen, child: const Text('x')),
      ),
    );
    expect(sets, <bool>[true]);
    await tester.pumpWidget(
      const Directionality(textDirection: TextDirection.ltr, child: Text('y')),
    );
    expect(sets, <bool>[true, false]);
  });

  group('본문 레지스트리 감싸기', () {
    Widget plain(Map<String, String> _) => const Text('plain');
    Widget home(BuildContext _) => const Text('home');

    test('🔴 캡처 막기 라우트 = 감쌈 · 그 밖 = 그대로 · 홈 그대로', () {
      final ShellRouteBodies b = secureRouteBodies(
        ShellRouteBodies(<String, ShellBodyBuilder>{
          AppRoutes.settingsCredentials: plain,
          AppRoutes.alertsInbox: plain,
        }, home: home),
        screen,
      );
      expect(
        b.byPattern[AppRoutes.settingsCredentials]!(const <String, String>{}),
        isA<SecureScope>(),
      );
      expect(
        b.byPattern[AppRoutes.alertsInbox]!(const <String, String>{}),
        isA<Text>(),
      );
      expect(identical(b.home, home), true);
    });

    test('캡처 막기 라우트 다섯(S02 · S06 · V-01 · X1 계획 · X1 비상)', () {
      expect(kSecureRoutePatterns, <String>{
        AppRoutes.settingsCredentials,
        AppRoutes.settingsDevices,
        AppRoutes.onboardingPairing,
        AppRoutes.x1MigrationPlan,
        AppRoutes.x1MigrationEmergency,
      });
    });
  });

  group('링크 열기', () {
    test('🔴 https = 바깥 · 앱 링크 = 셸', () async {
      final _Opener inner = _Opener();
      final List<String> outside = <String>[];
      final OperatorLinkOpener o = OperatorLinkOpener(
        inner: inner,
        external: (String u) async {
          outside.add(u);
          return true;
        },
      );
      o.open('https://healthchecks.io');
      o.open(AppRoutes.alertsInbox);
      o.open('http://insecure.example');
      await Future<void>.delayed(Duration.zero);
      expect(outside, <String>['https://healthchecks.io']);
      expect(inner.opened, <String>[
        AppRoutes.alertsInbox,
        'http://insecure.example',
      ]);
    });
  });
}
