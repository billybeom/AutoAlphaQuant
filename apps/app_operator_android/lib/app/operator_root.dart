// operator 앱 루트 — 첫 실행 판정(E11p4b · 설계 13 §8 R125 · 06 M4-11 ② · 01 §8 미결 158).
//
// 🔴 온보딩이 끝나기 전(`onboarding_choice.committed_at` 없음) = 온보딩 내비게이터(첫 화면 = `O-00`) · 끝남 = 셸.
//    셸은 화면 상태(플래그)가 서야 내비게이터를 만든다 — 온보딩 중에는 화면 상태가 없으므로 셸 안에서는 온보딩 라우트를 밀 수 없다.
// 🔴 내비게이터 키 = `shellNavigatorKeyProvider`(조립이 지금 선 쪽 — 온보딩 중 = 온보딩 키 · 뒤 = 셸 키 · R125 K6) —
//    셸 링크 열기 · 딥링크 중계가 그대로 지금 내비게이터로 민다 · 두 내비게이터가 키를 나눠 쓰지 않는다(재부착 0).
// 🔴 판정을 아직 모름(첫 값 전) · 오류 = 셸(그 자체가 뼈대 · 다시 시도) — 판정을 지어내지 않는다.

import 'package:domain_contracts/domain_contracts.dart' show AppRoutes;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_shell/ui_shell.dart'
    show ShellLinkPage, ShellRoot, shellNavigatorKeyProvider;

import 'operator_shell.dart' show operatorOnboardingDoneProvider;

/// operator 앱 루트.
class OperatorRoot extends ConsumerWidget {
  /// 만든다.
  const OperatorRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool? done = ref.watch(operatorOnboardingDoneProvider).valueOrNull;
    if (done == false) return const OnboardingHost();
    return const ShellRoot();
  }
}

/// 온보딩 내비게이터 — 첫 화면 = `O-00`(셸 링크 화면 · 본문 = 조립 레지스트리).
class OnboardingHost extends ConsumerWidget {
  /// 만든다.
  const OnboardingHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Navigator(
    key: ref.watch(shellNavigatorKeyProvider),
    onGenerateInitialRoutes: (NavigatorState _, String _) => <Route<void>>[
      MaterialPageRoute<void>(
        builder: (BuildContext _) =>
            const ShellLinkPage(link: AppRoutes.onboardingStart),
      ),
    ],
  );
}
