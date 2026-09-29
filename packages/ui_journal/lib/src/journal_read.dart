// lib/src/journal_read.dart
//
// J-3R 사전 저널 읽기 뷰 — 🆕 계약 v1.2 (01 §12-2).
//
// 🔴 이 파일은 배럴(lib/ui_journal.dart)에 export 된다 — iOS 빌드 포함.
// 🔴 DraftStore·DraftKey·DraftRecord·DraftKind·입력 DTO 이름 0(C-35 ⑥).
// 🔴 안전 상태 구독 0(설계 §2-16 (1) «J-3R 에는 적용하지 않는다»).
// 🔴 선택지 목록으로 라벨 찾기 0(ruleCitedLabel 은 엔진이 준다).
// 🔴 본문 원문 자르기·substring·maxLines·trim 0.
// 🔴 시각 포맷 0(writtenAtText 그대로).
// 🔴 링크 조립 0(decisionLink 는 엔진이 준다 — AppLinkOpener.open 만).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/journal_common.dart';
import 'timeline.dart';

// ── Data provider ─────────────────────────────────────────────────────────────

/// J-3R 사전 저널 읽기 프로바이더.
///
/// 🔴 데이터 프로바이더: throw 기본값 금지.
final journalReadProvider = StreamProvider.family<DecisionJournalVm, String>(
  (Ref ref, String decisionId) => ref
      .watch(journalTimelineRepositoryProvider)
      .watchDecisionJournal(decisionId),
);

// ── Widgets ───────────────────────────────────────────────────────────────────

/// J-3R 사전 저널 읽기 본문 — 끼워 넣기·라우트 양쪽에서 재사용.
///
/// [showAsOfHeader] = false → J-3 executed 자리에 끼워 넣을 때(헤더·신선도 배너 생략).
/// [showAsOfHeader] = true → [JournalReadView](라우트 본문).
///
/// 🔴 Scaffold·AppBar·SafeArea 없음(01 §9).
/// 🔴 스크롤 없음(끼워 넣기용) — 라우트는 [JournalReadView] 가 ListView 한 겹을 더한다.
class JournalReadContent extends ConsumerWidget {
  const JournalReadContent({
    super.key,
    required this.decisionId,
    this.showAsOfHeader = true,
  });

  final String decisionId;

  /// J-3 executed 자리 = false · JournalReadView = true.
  final bool showAsOfHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DecisionJournalVm> readAsync = ref.watch(
      journalReadProvider(decisionId),
    );

    return readAsync.when(
      loading: () => const Card(
        // 🔴 JournalSkeleton(ListView) 금지 — J-3 ListView 안에서 중첩 오류
        key: Key('j3r-loading'),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SizedBox(height: 132),
      ),
      error: (Object e, _) => JournalErrorView(
        lastAsOfLabel: readAsync.valueOrNull?.asOf.label,
        onRetry: () => ref.invalidate(journalReadProvider(decisionId)),
      ),
      data: (DecisionJournalVm vm) {
        final bool isStale = vm.asOf.observedAt
            .add(vm.asOf.staleAfter)
            .isBefore(ref.watch(journalClockProvider).nowUtc());
        final DecisionJournalBody? body = vm.body;
        final LinkAction? link = vm.decisionLink;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (showAsOfHeader) JournalAsOfHeader(asOf: vm.asOf),
            if (showAsOfHeader && isStale) JournalStaleBanner(asOf: vm.asOf),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(vm.journalStateLabel, key: const Key('j3r-state')),
            ),
            if (body != null)
              Padding(
                key: const Key('j3r-body'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(body.writtenAtText, key: const Key('j3r-written-at')),
                    const Text(JournalLabels.draftRuleCited),
                    Text(body.ruleCitedLabel),
                    const Text(JournalLabels.draftRationale),
                    // 🔴 maxLines·overflow·trim 없음
                    Text(body.rationaleBefore),
                    const Text(JournalLabels.draftExpected),
                    Text(body.expectedOutcome),
                    if (body.note != null) ...<Widget>[
                      const Text(JournalLabels.draftNote),
                      Text(body.note!),
                    ],
                  ],
                ),
              ),
            if (link != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: OutlinedButton(
                  key: const Key('j3r-link-decision'),
                  onPressed: () =>
                      ref.read(journalLinkOpenerProvider).open(link.deepLink),
                  child: Text(link.label),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// J-3R 사전 저널 읽기 뷰 — 라우트 `journalRead` 본문.
///
/// [JournalReadContent] 를 ListView 한 겹으로 감싼 것.
class JournalReadView extends StatelessWidget {
  const JournalReadView({super.key, required this.decisionId});

  final String decisionId;

  @override
  Widget build(BuildContext context) =>
      ListView(children: <Widget>[JournalReadContent(decisionId: decisionId)]);
}
