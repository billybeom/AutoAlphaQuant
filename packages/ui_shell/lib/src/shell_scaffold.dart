// lib/src/shell_scaffold.dart
//
// ShellRoot · ShellBandOverlay · (private) _ShellNavigator · _PhoneHome ·
// _JournalTab · _WebFrame · _WebBody · _shellAlertsProvider.
//
// 🔴 도는 곳: Scaffold·AppBar·SafeArea·Navigator·MaterialPageRoute 소유(셸 몫).
// 🔴 본문 위젯(ui_journal 등) import 없음 — ShellRouteBodies 레지스트리로만.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/shell_common.dart';
import 'incident/incident_banner.dart';
import 'routing/shell_router.dart';
import 'shell_providers.dart';

// ── Alerts provider ────────────────────────────────────────────────────────────

final StreamProvider<List<AlertItem>> _shellAlertsProvider =
    StreamProvider<List<AlertItem>>(
      (Ref ref) => ref.watch(shellAlertRepositoryProvider).watchInbox(),
    );

// ── Helpers ────────────────────────────────────────────────────────────────────

const List<String> _tabLabels = <String>[
  ShellLabels.tabHome,
  ShellLabels.tabJournal,
  ShellLabels.tabHoldings,
  ShellLabels.tabPlan,
  ShellLabels.tabMore,
];

const List<String> _sideLabels = <String>[
  ShellLabels.sideHome,
  ShellLabels.sideJournal,
  ShellLabels.sideHoldings,
  ShellLabels.sideReports,
  ShellLabels.sideHandbook,
];

// ── ShellRoot ──────────────────────────────────────────────────────────────────

/// 셸 루트 — 플랫폼에 따라 폰 또는 웹 레이아웃을 고른다.
class ShellRoot extends ConsumerWidget {
  const ShellRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FeatureFlags> a = ref.watch(shellFlagsProvider);
    final FeatureFlags? f = a.valueOrNull;

    if (f != null) {
      return switch (ref.watch(shellPlatformProvider)) {
        ShellPlatform.androidOperator ||
        ShellPlatform.iosViewer => const _ShellNavigator(home: _PhoneHome()),
        ShellPlatform.web => const _WebFrame(
          child: _ShellNavigator(home: _WebBody()),
        ),
      };
    }
    if (a.hasError) {
      return ShellErrorView(
        key: const Key('s01-fail'),
        onRetry: () => ref.invalidate(shellFlagsProvider),
      );
    }
    return const ShellSkeleton(key: Key('s01-loading'));
  }
}

// ── Navigator ──────────────────────────────────────────────────────────────────

class _ShellNavigator extends ConsumerWidget {
  const _ShellNavigator({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Navigator(
      key: ref.watch(shellNavigatorKeyProvider),
      onGenerateRoute: (RouteSettings s) =>
          MaterialPageRoute<void>(builder: (BuildContext c) => home),
    );
  }
}

// ── Phone home ─────────────────────────────────────────────────────────────────

class _PhoneHome extends ConsumerWidget {
  const _PhoneHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(shellTabIndexProvider);
    final FeatureFlags? flags = ref.watch(shellFlagsProvider).valueOrNull;
    final bool p0 =
        ref
            .watch(_shellAlertsProvider)
            .valueOrNull
            ?.any(
              (AlertItem a) => a.level == AlertLevel.p0 && a.ack?.acked != true,
            ) ??
        false;
    final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shellTitle(flags, _tabLabels[index]),
          key: const Key('s01-title'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const IncidentBannerSlot(),
          Expanded(
            child: IndexedStack(
              index: index,
              children: <Widget>[
                _homeOf(bodies),
                const _JournalTab(),
                const ShellRouteBody(link: AppRoutes.holdingsOverview),
                const ShellPlaceholder(key: Key('s01-plan-slot')),
                const ShellPlaceholder(key: Key('s01-more-slot')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        key: const Key('s01-tabs'),
        selectedIndex: index,
        onDestinationSelected: (int i) {
          ref.read(shellTabIndexProvider.notifier).state = i;
        },
        destinations: <Widget>[
          NavigationDestination(
            icon: p0
                ? const Badge(
                    key: Key('s01-p0-dot'),
                    child: Icon(Icons.home_outlined),
                  )
                : const Icon(Icons.home_outlined),
            label: ShellLabels.tabHome,
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: ShellLabels.tabJournal,
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: ShellLabels.tabHoldings,
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            label: ShellLabels.tabPlan,
          ),
          const NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: ShellLabels.tabMore,
          ),
        ],
      ),
    );
  }

  Widget _homeOf(ShellRouteBodies b) {
    final WidgetBuilder? h = b.home;
    if (h == null) {
      return const ShellPlaceholder(key: Key('s01-home-slot'));
    }
    return Builder(builder: h);
  }
}

// ── Journal tab ────────────────────────────────────────────────────────────────

class _JournalTab extends ConsumerStatefulWidget {
  const _JournalTab();

  @override
  ConsumerState<_JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends ConsumerState<_JournalTab> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final FeatureFlags? flags = ref.watch(shellFlagsProvider).valueOrNull;
    final bool advisory = switch (flags?.operatingMode) {
      OperatingMode.advisory => true,
      OperatingMode.autoTrade => false,
      null => false,
    };

    if (!advisory) {
      return const ShellRouteBody(link: AppRoutes.journalTimeline);
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SegmentedButton<int>(
            key: const Key('s01-segment'),
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(
                value: 0,
                label: Text(ShellLabels.segmentAdvice),
              ),
              ButtonSegment<int>(
                value: 1,
                label: Text(ShellLabels.segmentRecord),
              ),
            ],
            selected: <int>{_segment},
            onSelectionChanged: (Set<int> s) {
              setState(() {
                _segment = s.first;
              });
            },
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _segment,
            children: const <Widget>[
              ShellRouteBody(link: AppRoutes.adviceInbox),
              ShellRouteBody(link: AppRoutes.journalTimeline),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Web frame (S-02) ───────────────────────────────────────────────────────────

class _WebFrame extends ConsumerWidget {
  const _WebFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(shellTabIndexProvider);
    final FeatureFlags? flags = ref.watch(shellFlagsProvider).valueOrNull;
    final List<String> modes = flags == null
        ? const <String>[]
        : shellModeLabels(flags);

    return Material(
      child: Row(
        children: <Widget>[
          SizedBox(
            key: const Key('s02-sidebar'),
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Chip(
                    key: const Key('s02-view-only'),
                    label: const Text(ShellLabels.viewOnly),
                  ),
                ),
                if (modes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      key: const Key('s02-mode-chips'),
                      spacing: 8,
                      children: <Widget>[
                        for (final String m in modes) Chip(label: Text(m)),
                      ],
                    ),
                  ),
                for (final (int i, String label) in _sideLabels.indexed)
                  ListTile(
                    key: ValueKey<String>('s02-item-$i'),
                    selected: i == index,
                    title: Text(label),
                    onTap: () {
                      ref
                          .read(shellNavigatorKeyProvider)
                          .currentState
                          ?.popUntil((Route<dynamic> r) => r.isFirst);
                      ref.read(shellTabIndexProvider.notifier).state = i;
                    },
                  ),
                const Spacer(),
                const SizedBox(key: Key('s02-kill-slot'), height: 56),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Web body ───────────────────────────────────────────────────────────────────

class _WebBody extends ConsumerWidget {
  const _WebBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(shellTabIndexProvider);
    final FeatureFlags? flags = ref.watch(shellFlagsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shellTitle(flags, _sideLabels[index]),
          key: const Key('s01-title'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const IncidentBannerSlot(),
          Expanded(
            child: IndexedStack(
              index: index,
              children: <Widget>[
                _homeOf(ref.watch(shellRouteBodiesProvider)),
                const ShellRouteBody(link: AppRoutes.journalTimeline),
                const ShellRouteBody(link: AppRoutes.holdingsOverview),
                const ShellRouteBody(link: AppRoutes.reportArchive),
                const ShellPlaceholder(key: Key('s02-handbook-slot')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeOf(ShellRouteBodies b) {
    final WidgetBuilder? h = b.home;
    if (h == null) {
      return const ShellPlaceholder(key: Key('s01-home-slot'));
    }
    return Builder(builder: h);
  }
}

// ── ShellBandOverlay ───────────────────────────────────────────────────────────

/// MaterialApp.builder 용 — 화면 바깥에 모의투자·안내 띠를 쌓는다.
///
/// 🔴 높이 예약 0(01 §9-4) · 띠 1개 · 칩 ≤ 2.
class ShellBandOverlay extends ConsumerWidget {
  const ShellBandOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeatureFlags? flags = ref.watch(shellFlagsProvider).valueOrNull;
    if (flags == null) {
      return child;
    }
    final List<String> labels = shellModeLabels(flags);
    if (labels.isEmpty) {
      return child;
    }
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color tone = flags.runMode.isSim
        ? cs.tertiaryContainer
        : cs.primaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Material(
          key: const Key('s01-band'),
          color: tone,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final (int i, String l) in labels.indexed)
                    Chip(
                      key: ValueKey<String>('s01-band-chip-$i'),
                      label: Text(l),
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
