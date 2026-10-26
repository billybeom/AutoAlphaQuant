// lib/src/routing/shell_router.dart
//
// ShellRouteMatch · matchShellRoute() · ShellGuard · shellGuardFor() ·
// ShellLinkOpener · shellLinkOpenerProvider · ShellRouteBody · ShellLinkPage.
//
// 🔴 lib 에 scheme 리터럴 0 — AppLinkSchemes.* · AppRoutes.* 사용.
// 🔴 AppRoutes.isRegistered 0 — matchShellRoute 가 같은 규칙으로 직접 맞춘다.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/shell_common.dart';
import '../shell_providers.dart';

// ── Route match ────────────────────────────────────────────────────────────────

/// matchShellRoute 결과.
class ShellRouteMatch {
  const ShellRouteMatch({required this.pattern, required this.params});

  final String pattern;
  final Map<String, String> params;
}

/// AppRoutes.all 순서대로 첫 일치를 찾는다.
///
/// 🔴 세그먼트 수가 다르면 다음. 조각이 콜론으로 시작하면 파라미터(빈 값이나 물음표·샵 포함 시 불일치).
///    고정 조각 = 같아야. 첫 일치 반환.
ShellRouteMatch? matchShellRoute(String link) {
  final List<String> l = link.split('/');
  for (final String pattern in AppRoutes.all) {
    final List<String> p = pattern.split('/');
    if (p.length != l.length) {
      continue;
    }
    final Map<String, String> params = <String, String>{};
    bool ok = true;
    for (int i = 0; i < p.length; i++) {
      if (p[i].startsWith(':')) {
        final String seg = l[i];
        if (seg.isEmpty || seg.contains('?') || seg.contains('#')) {
          ok = false;
          break;
        }
        params[p[i].substring(1)] = seg;
      } else if (p[i] != l[i]) {
        ok = false;
        break;
      }
    }
    if (ok) {
      return ShellRouteMatch(pattern: pattern, params: params);
    }
  }
  return null;
}

// ── Guard ──────────────────────────────────────────────────────────────────────

/// 셸 라우트 가드 5값.
enum ShellGuard { open, phoneOnly, webAbsent, advisoryOnly, draftReadOnly }

// advisory 전용 3 패턴 (androidOperator 에서만)
const Set<String> _kAdvisoryWrite = <String>{
  AppRoutes.adviceFill,
  AppRoutes.adviceSkip,
  AppRoutes.ledgerSelfReport,
};

// iOS viewer 폰 전용 5 패턴
const Set<String> _kPhoneOnlyIos = <String>{
  AppRoutes.adviceFill,
  AppRoutes.adviceSkip,
  AppRoutes.ledgerSelfReport,
  AppRoutes.ledgerRepairs,
  AppRoutes.planDeposit,
};

// 웹 폰 전용 2 패턴
const Set<String> _kPhoneOnlyWeb = <String>{
  AppRoutes.ledgerRepairs,
  AppRoutes.planDeposit,
};

// 웹 absent 17 패턴 (ui_journal 라우트)
const Set<String> _kJournalRoutes = <String>{
  AppRoutes.journalTimeline,
  AppRoutes.journalDecision,
  AppRoutes.journalDraft,
  AppRoutes.journalRead,
  AppRoutes.journalRebalance,
  AppRoutes.journalBlindReview,
  AppRoutes.journalUnknownBoard,
  AppRoutes.holdingsOverview,
  AppRoutes.holdingsDetail,
  AppRoutes.holdingsAllocation,
  AppRoutes.adviceInbox,
  AppRoutes.adviceDetail,
  AppRoutes.adviceFill,
  AppRoutes.adviceSkip,
  AppRoutes.adviceHistory,
  AppRoutes.ledgerSelfReport,
  AppRoutes.ledgerDiffs,
};

/// 패턴 · 플랫폼 · 운영 모드(null = 플래그 미수신)로 가드를 고른다.
ShellGuard shellGuardFor(
  String pattern,
  ShellPlatform platform,
  OperatingMode? operatingMode,
) {
  return switch (platform) {
    ShellPlatform.androidOperator => _androidGuard(pattern, operatingMode),
    ShellPlatform.iosViewer => _iosGuard(pattern),
    ShellPlatform.web => _webGuard(pattern),
  };
}

ShellGuard _androidGuard(String pattern, OperatingMode? operatingMode) {
  if (_kAdvisoryWrite.contains(pattern)) {
    return switch (operatingMode) {
      OperatingMode.advisory => ShellGuard.open,
      OperatingMode.autoTrade => ShellGuard.advisoryOnly,
      null => ShellGuard.advisoryOnly,
    };
  }
  return ShellGuard.open;
}

ShellGuard _iosGuard(String pattern) {
  if (pattern == AppRoutes.journalDraft) {
    return ShellGuard.draftReadOnly;
  }
  if (_kPhoneOnlyIos.contains(pattern)) {
    return ShellGuard.phoneOnly;
  }
  return ShellGuard.open;
}

ShellGuard _webGuard(String pattern) {
  if (_kPhoneOnlyWeb.contains(pattern)) {
    return ShellGuard.phoneOnly;
  }
  if (_kJournalRoutes.contains(pattern)) {
    return ShellGuard.webAbsent;
  }
  return ShellGuard.open;
}

// ── Link opener ────────────────────────────────────────────────────────────────

/// AppLinkOpener 구현 — Navigator push/pop + 홈 복귀.
class ShellLinkOpener implements AppLinkOpener {
  const ShellLinkOpener({required this.navigatorKey, required this.onHome});

  final GlobalKey<NavigatorState> navigatorKey;
  final VoidCallback onHome;

  @override
  void open(String link) {
    final NavigatorState? nav = navigatorKey.currentState;
    if (nav == null) {
      return;
    }
    // 동작 링크 back — isRegistered·match 보다 먼저 처리.
    if (link == AppNavActions.back) {
      if (nav.canPop()) {
        nav.pop();
      } else {
        onHome();
      }
      return;
    }
    // 그 밖 — 늘 새 화면 push.
    unawaited(
      nav.push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext c) => ShellLinkPage(link: link),
        ),
      ),
    );
  }
}

final Provider<AppLinkOpener> shellLinkOpenerProvider = Provider<AppLinkOpener>(
  (Ref ref) {
    final GlobalKey<NavigatorState> key = ref.watch(shellNavigatorKeyProvider);
    return ShellLinkOpener(
      navigatorKey: key,
      onHome: () {
        ref.read(shellTabIndexProvider.notifier).state = 0;
      },
    );
  },
);

// ── ShellRouteBody ─────────────────────────────────────────────────────────────

/// 링크 하나를 받아 가드 + 레지스트리로 본문을 고른다.
class ShellRouteBody extends ConsumerWidget {
  const ShellRouteBody({super.key, required this.link});

  final String link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. handbook 스킴 → 자리표시자
    if (link.startsWith('${AppLinkSchemes.handbook}://')) {
      return const ShellPlaceholder(key: Key('s01-handbook-slot'));
    }

    // 2. 라우트 일치 확인
    final ShellRouteMatch? m = matchShellRoute(link);
    if (m == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            ShellLabels.unknownLink,
            key: const Key('s01-unknown-link'),
          ),
        ),
      );
    }

    // 3. 가드 적용
    final ShellGuard g = shellGuardFor(
      m.pattern,
      ref.watch(shellPlatformProvider),
      ref.watch(shellFlagsProvider).valueOrNull?.operatingMode,
    );
    final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);

    Widget bodyOf(String pattern) {
      final ShellBodyBuilder? b = bodies.byPattern[pattern];
      if (b == null) {
        return const ShellPlaceholder(key: Key('s01-placeholder'));
      }
      return KeyedSubtree(key: ValueKey<String>(link), child: b(m.params));
    }

    return switch (g) {
      ShellGuard.open => bodyOf(m.pattern),
      ShellGuard.phoneOnly => _GuardNotice(ShellLabels.phoneOnly),
      ShellGuard.webAbsent => _GuardNotice(ShellLabels.webAbsent),
      ShellGuard.advisoryOnly => _GuardNotice(ShellLabels.advisoryOnly),
      ShellGuard.draftReadOnly => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              ShellLabels.journalDraftPhoneOnly,
              key: const Key('s01-guard'),
            ),
          ),
          Expanded(child: bodyOf(AppRoutes.journalRead)),
        ],
      ),
    };
  }
}

/// 가드 안내 위젯 (phoneOnly / webAbsent / advisoryOnly).
class _GuardNotice extends StatelessWidget {
  const _GuardNotice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, key: const Key('s01-guard')),
      ),
    );
  }
}

// ── ShellLinkPage ──────────────────────────────────────────────────────────────

/// Navigator.push 로 열리는 링크 화면 — 접두 제목만(화면 이름 없음).
class ShellLinkPage extends ConsumerWidget {
  const ShellLinkPage({super.key, required this.link});

  final String link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title = shellTitle(
      ref.watch(shellFlagsProvider).valueOrNull,
      null,
    );
    return Scaffold(
      appBar: AppBar(
        title: title.isEmpty ? null : Text(title, key: const Key('s01-title')),
      ),
      body: ShellRouteBody(link: link),
    );
  }
}
