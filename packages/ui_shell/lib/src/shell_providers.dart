// lib/src/shell_providers.dart
//
// 주입 프로바이더 6 + 셸 상태 3 + 데이터 1(shellFlagsProvider) +
// ShellPlatform · ShellBodyBuilder · ShellRouteBodies · shellModeLabels · shellTitle.
//
// 🔴 autoDispose 0 · 기본값 = throw UnimplementedError.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';

// ── Platform ───────────────────────────────────────────────────────────────────

/// 셸이 도는 자리 — 조립 앱 3종이 하나를 준다(셸 lib 은 플랫폼을 판정하지 않는다).
enum ShellPlatform { androidOperator, iosViewer, web }

// ── Body registry ──────────────────────────────────────────────────────────────

/// 라우트 본문 한 개 — 파라미터 이름 → 값(링크의 그 조각 그대로).
typedef ShellBodyBuilder = Widget Function(Map<String, String> params);

/// 패턴(AppRoutes 의 값) → 본문 + 홈 탭 본문. 조립 앱이 준다 — 셸은 본문 패키지를
/// import 하지 않는다.
class ShellRouteBodies {
  const ShellRouteBodies(this.byPattern, {this.home});

  final Map<String, ShellBodyBuilder> byPattern;

  /// 홈 탭(라우트 없음 · H-01) — null = 빈 자리(ShellPlaceholder · Key s01-home-slot).
  final WidgetBuilder? home;
}

// ── Injection providers ────────────────────────────────────────────────────────

final Provider<ShellPlatform> shellPlatformProvider = Provider<ShellPlatform>(
  (Ref ref) =>
      throw UnimplementedError('shellPlatformProvider must be overridden'),
);

final Provider<ShellRouteBodies> shellRouteBodiesProvider =
    Provider<ShellRouteBodies>(
      (Ref ref) => throw UnimplementedError(
        'shellRouteBodiesProvider must be overridden',
      ),
    );

final Provider<ConfigRepository> shellConfigRepositoryProvider =
    Provider<ConfigRepository>(
      (Ref ref) => throw UnimplementedError(
        'shellConfigRepositoryProvider must be overridden',
      ),
    );

final Provider<AlertRepository> shellAlertRepositoryProvider =
    Provider<AlertRepository>(
      (Ref ref) => throw UnimplementedError(
        'shellAlertRepositoryProvider must be overridden',
      ),
    );

final Provider<OpsSummaryRepository> shellOpsSummaryRepositoryProvider =
    Provider<OpsSummaryRepository>(
      (Ref ref) => throw UnimplementedError(
        'shellOpsSummaryRepositoryProvider must be overridden',
      ),
    );

final Provider<Clock> shellClockProvider = Provider<Clock>(
  (Ref ref) =>
      throw UnimplementedError('shellClockProvider must be overridden'),
);

// ── Shell state providers ──────────────────────────────────────────────────────

final Provider<GlobalKey<NavigatorState>> shellNavigatorKeyProvider =
    Provider<GlobalKey<NavigatorState>>(
      (Ref ref) => GlobalKey<NavigatorState>(),
    );

final StateProvider<int> shellTabIndexProvider = StateProvider<int>(
  (Ref ref) => 0,
);

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<FeatureFlags> shellFlagsProvider =
    StreamProvider<FeatureFlags>(
      (Ref ref) => ref.watch(shellConfigRepositoryProvider).watchFlags(),
    );

// ── Label helpers ──────────────────────────────────────────────────────────────

/// 접두·띠 칩 — 순서 고정(모의 → 안내).
List<String> shellModeLabels(FeatureFlags flags) {
  final String? run = flags.runMode.isSim ? ShellLabels.simPrefix : null;
  final String? op = switch (flags.operatingMode) {
    OperatingMode.autoTrade => null,
    OperatingMode.advisory => ShellLabels.advisoryPrefix,
  };
  return <String>[?run, ?op];
}

/// 앱바 제목 = 접두들 + 제목(없으면 접두만) — 이음 = ShellLabels.prefixSeparator.
String shellTitle(FeatureFlags? flags, String? title) => <String>[
  ...?(flags == null ? null : shellModeLabels(flags)),
  ?title,
].join(ShellLabels.prefixSeparator);
