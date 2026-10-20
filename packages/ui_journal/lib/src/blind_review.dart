import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/journal_common.dart';
import 'timeline.dart';

// ── Injection and data providers ──────────────────────────────────────────────

/// J-4 명령 주입 — 조립 앱 3종이 override 한다(01 §16-8 · 01 §13-9 v1.7 문언).
final journalBlindReviewCommandApiProvider = Provider<CommandApi>(
  (Ref ref) => throw UnimplementedError(
    'journalBlindReviewCommandApiProvider must be overridden',
  ),
);

/// J-4 대기 목록(봉투) — 인자 없이 부른다(K24 · v1.7 = 실전 결정만).
final journalBlindReviewQueueProvider =
    StreamProvider<ListResult<BlindReviewCard>>(
      (Ref ref) =>
          ref.watch(journalTimelineRepositoryProvider).watchBlindReviewQueue(),
    );

/// J-4 고정 카드 1건 — 채점 집행 뒤 같은 스트림에 결과가 실린 값이 온다(02 그림 M6-13).
final journalBlindReviewCardProvider =
    StreamProvider.family<BlindReviewCard, String>(
      (Ref ref, String decisionId) => ref
          .watch(journalTimelineRepositoryProvider)
          .watchBlindReviewCard(decisionId),
    );

// ── Root widget ───────────────────────────────────────────────────────────────

/// J-4 사후 blind 리뷰 — 본문만 그린다(껍데기는 셸 몫).
///
/// 대기 목록의 머리 카드를 고정해 한 건씩 채점한다. 결과 섹션은 카드의
/// `result` 가 null 이 아닐 때만 열린다.
class JournalBlindReview extends ConsumerStatefulWidget {
  const JournalBlindReview({super.key});

  @override
  ConsumerState<JournalBlindReview> createState() => _JournalBlindReviewState();
}

class _JournalBlindReviewState extends ConsumerState<JournalBlindReview> {
  String? _pinnedId;
  final Map<String, BlindReviewChoice> _picked = <String, BlindReviewChoice>{};
  CommandReceipt? _receipt;
  StreamSubscription<CommandReceipt>? _cmdSub;
  bool _submitting = false;
  bool _submitNotAccepted = false;

  @override
  void dispose() {
    unawaited(_cmdSub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final String? pinned = _pinnedId;
    if (pinned == null) {
      final AsyncValue<ListResult<BlindReviewCard>> queueAsync = ref.watch(
        journalBlindReviewQueueProvider,
      );
      return queueAsync.when(
        loading: () => const JournalSkeleton(key: Key('j4-loading')),
        error: (Object error, StackTrace stackTrace) => JournalErrorView(
          key: const Key('j4-fail'),
          lastAsOfLabel: queueAsync.valueOrNull?.asOf.label,
          onRetry: () => ref.invalidate(journalBlindReviewQueueProvider),
        ),
        data: (ListResult<BlindReviewCard> queue) {
          if (queue.rows.isEmpty) {
            return _buildEmpty(queue, clock, safety);
          }
          final String id = queue.rows[0].decisionId;
          _pinnedId = id;
          return _buildPinned(id, clock, safety);
        },
      );
    }
    return _buildPinned(pinned, clock, safety);
  }

  // ── Pinned card branch ──────────────────────────────────────────────────────

  Widget _buildPinned(String id, Clock clock, SafetyState? safety) {
    final AsyncValue<BlindReviewCard> cardAsync = ref.watch(
      journalBlindReviewCardProvider(id),
    );
    return cardAsync.when(
      loading: () => const JournalSkeleton(key: Key('j4-loading')),
      error: (Object error, StackTrace stackTrace) => JournalErrorView(
        key: const Key('j4-fail'),
        lastAsOfLabel: cardAsync.valueOrNull?.asOf.label,
        onRetry: () => ref.invalidate(journalBlindReviewCardProvider(id)),
      ),
      data: (BlindReviewCard card) => _buildCard(card, clock, safety),
    );
  }

  // ── Empty branch ────────────────────────────────────────────────────────────

  Widget _buildEmpty(
    ListResult<BlindReviewCard> queue,
    Clock clock,
    SafetyState? safety,
  ) {
    final bool stale = queue.asOf.observedAt
        .add(queue.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final String? label = switch (queue.emptyKind) {
      EmptyKind.noData => queue.emptyLabel,
      EmptyKind.notApplicable => queue.emptyLabel,
      EmptyKind.notLoaded => queue.asOf.staleLabel,
    };
    return ListView(
      children: <Widget>[
        JournalAsOfHeader(key: const Key('j4-asof'), asOf: queue.asOf),
        if (stale) JournalStaleBanner(asOf: queue.asOf),
        JournalSafetyBanners(safety: safety),
        if (label != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(label, key: const Key('j4-empty')),
          ),
      ],
    );
  }

  // ── Card branch ─────────────────────────────────────────────────────────────

  bool _receiptLocks(CommandReceipt? receipt) {
    if (receipt == null) {
      return false;
    }
    return switch (receipt.state) {
      CommandState.requested => true,
      CommandState.received => true,
      CommandState.staleContext => true,
      CommandState.heldForIntegrity => true,
      CommandState.pendingLeaseConfirm => true,
      CommandState.noOperator => true,
      CommandState.executed => true,
      CommandState.rejected || CommandState.expired => false,
    };
  }

  Widget _buildCard(BlindReviewCard card, Clock clock, SafetyState? safety) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final CommandReceipt? receipt = _receipt;
    final BlindReviewResult? result = card.result;
    final LinkAction? link = result?.decisionLink;
    final DecisionJournalBody? body = card.journal;
    final bool stale = card.asOf.observedAt
        .add(card.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final bool receiptLocks = _receiptLocks(receipt);
    final bool showSubmit = result == null && !receiptLocks;
    final bool locked = result != null || receiptLocks || _submitting;
    final bool allAnswered = card.questions.every(
      (BlindReviewQuestion q) => _picked.containsKey(q.questionId),
    );
    final bool canSubmit = showSubmit && !_submitting && allAnswered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _padded(
          child: Text(
            JournalLabels.blindReviewNotice,
            key: const Key('j4-notice'),
          ),
        ),
        Expanded(
          child: ListView(
            children: <Widget>[
              JournalAsOfHeader(key: const Key('j4-asof'), asOf: card.asOf),
              if (stale) JournalStaleBanner(asOf: card.asOf),
              _padded(child: Text(card.titleText, key: const Key('j4-title'))),
              _padded(
                child: Text(card.promptText, key: const Key('j4-prompt')),
              ),
              JournalSafetyBanners(safety: safety),
              _padded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: <Widget>[
                    for (final (int i, ReasonChip chip)
                        in card.contextChips.indexed)
                      JournalReasonChip(
                        key: ValueKey<String>('j4-chip-$i'),
                        chip: chip,
                      ),
                  ],
                ),
              ),
              _padded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      card.deviation.label,
                      key: const Key('j4-deviation'),
                    ),
                  ),
                ),
              ),
              _padded(
                child: Text(
                  card.journalStateLabel,
                  key: const Key('j4-journal-state'),
                ),
              ),
              if (body != null) _buildJournalBody(body),
              for (final (int i, BlindReviewQuestion q)
                  in card.questions.indexed)
                _buildQuestion(i, q, locked),
              if (receipt != null)
                _padded(
                  child: Text(receipt.stateLabel, key: const Key('j4-receipt')),
                ),
              if (result == null && _submitNotAccepted)
                _padded(
                  child: Text(
                    JournalLabels.submitNotAccepted,
                    key: const Key('j4-submit-not-accepted'),
                    style: TextStyle(color: colors.error),
                  ),
                ),
              if (showSubmit)
                _padded(
                  child: FilledButton(
                    key: const Key('j4-submit'),
                    onPressed: canSubmit
                        ? () {
                            unawaited(_submit(card));
                          }
                        : null,
                    child: const Text(JournalLabels.draftSubmit),
                  ),
                ),
              if (result != null)
                _padded(
                  key: const Key('j4-result'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(result.processScoreText),
                      Text(result.outcomeText),
                      for (final (int k, String line)
                          in result.detailLines.indexed)
                        Text(line, key: ValueKey<String>('j4-result-line-$k')),
                      if (link != null)
                        OutlinedButton(
                          key: const Key('j4-link-decisionLink'),
                          onPressed: () {
                            ref
                                .read(journalLinkOpenerProvider)
                                .open(link.deepLink);
                          },
                          child: Text(link.label),
                        ),
                    ],
                  ),
                ),
              if (result != null)
                _padded(
                  child: FilledButton(
                    key: const Key('j4-next'),
                    onPressed: _next,
                    child: const Text(JournalLabels.blindReviewNext),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJournalBody(DecisionJournalBody body) {
    final String? note = body.note;
    return _padded(
      key: const Key('j4-journal-body'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(body.writtenAtText),
          const Text(JournalLabels.draftRuleCited),
          Text(body.ruleCitedLabel),
          const Text(JournalLabels.draftRationale),
          Text(body.rationaleBefore),
          const Text(JournalLabels.draftExpected),
          Text(body.expectedOutcome),
          if (note != null) const Text(JournalLabels.draftNote),
          if (note != null) Text(note),
        ],
      ),
    );
  }

  Widget _buildQuestion(int i, BlindReviewQuestion q, bool locked) {
    final String? evidence = q.evidenceText;
    return _padded(
      key: ValueKey<String>('j4-question-$i'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(q.text),
          if (evidence != null)
            Text(evidence, key: ValueKey<String>('j4-evidence-$i')),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              for (final (int j, BlindReviewChoice c) in q.choices.indexed)
                ChoiceChip(
                  key: ValueKey<String>('j4-choice-$i-$j'),
                  label: Text(c.label),
                  selected: _picked[q.questionId] == c,
                  onSelected: locked
                      ? null
                      : (bool selected) {
                          setState(() {
                            _picked[q.questionId] = c;
                          });
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Submit and subscribe ────────────────────────────────────────────────────

  Future<void> _submit(BlindReviewCard card) async {
    final BlindReviewScore score = BlindReviewScore(
      decisionId: card.decisionId,
      answers: <String, int>{
        for (final BlindReviewQuestion q in card.questions)
          q.questionId: _picked[q.questionId]!.score,
      },
    );
    setState(() {
      _submitting = true;
      _submitNotAccepted = false;
    });
    final CommandReceipt initial;
    try {
      initial = await ref
          .read(journalBlindReviewCommandApiProvider)
          .submitBlindReviewScore(score);
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitNotAccepted = true;
        });
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      _receipt = initial;
    });
    _subscribe(initial.commandId);
  }

  void _subscribe(String commandId) {
    unawaited(_cmdSub?.cancel() ?? Future<void>.value());
    _cmdSub = ref
        .read(journalBlindReviewCommandApiProvider)
        .watchCommand(commandId)
        .listen((CommandReceipt r) {
          if (mounted) {
            setState(() {
              _receipt = r;
            });
          }
        }, onError: (Object e, StackTrace st) {});
  }

  void _next() {
    unawaited(_cmdSub?.cancel() ?? Future<void>.value());
    _cmdSub = null;
    setState(() {
      _pinnedId = null;
      _picked.clear();
      _receipt = null;
      _submitting = false;
      _submitNotAccepted = false;
    });
  }
}

Widget _padded({Key? key, required Widget child}) => Padding(
  key: key,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  child: child,
);
