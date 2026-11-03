// lib/src/onboarding/onboarding_start.dart
//
// OnboardingStart — O-00 첫 실행 3갈래 (04 §9-1 · 그림 17 · 계약 v1.16).
//
// 화면은 받은 글자와 null 여부만 본다. 이동은 엔진이 준 링크 하나뿐이다.
// 구독 하나(watchStart). 본문 화면이라 래퍼 없이 부모 높이 안 ListView.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<OnboardingStartVm> _startProvider =
    StreamProvider<OnboardingStartVm>(
      (Ref ref) => ref.watch(shellOnboardingRepositoryProvider).watchStart(),
    );

/// O-00 첫 실행 3갈래.
class OnboardingStart extends ConsumerWidget {
  const OnboardingStart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<OnboardingStartVm> start = ref.watch(_startProvider);

    if (start.hasError) {
      return ShellErrorView(
        key: const Key('o00-fail'),
        onRetry: () => ref.invalidate(_startProvider),
      );
    }

    final OnboardingStartVm? vm = start.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('o00-loading'));
    }

    final OnboardingTrackCard? viewer = vm.viewerTrack;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          key: const Key('o00-headline'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(vm.headline),
        ),
        for (final (int i, OnboardingTrackCard t) in vm.tracks.indexed)
          _TrackCard(index: i, card: t),
        if (viewer != null) _ViewerTrackCard(card: viewer),
      ],
    );
  }
}

class _TrackCard extends ConsumerWidget {
  const _TrackCard({required this.index, required this.card});

  final int index;
  final OnboardingTrackCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? link = card.deepLink;
    return Card(
      key: ValueKey<String>('o00-track-$index'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        onTap: link == null
            ? null
            : () {
                ref.read(shellLinkOpenerProvider).open(link);
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(card.title),
              const SizedBox(height: 4),
              Text(card.estimatedText),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewerTrackCard extends ConsumerWidget {
  const _ViewerTrackCard({required this.card});

  final OnboardingTrackCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? link = card.deepLink;
    return Card(
      key: const Key('o00-viewer'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        onTap: link == null
            ? null
            : () {
                ref.read(shellLinkOpenerProvider).open(link);
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(card.title),
              const SizedBox(height: 4),
              Text(card.estimatedText),
            ],
          ),
        ),
      ),
    );
  }
}
