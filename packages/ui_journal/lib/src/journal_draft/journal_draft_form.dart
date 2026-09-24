// lib/src/journal_draft/journal_draft_form.dart
//
// J-3 사전 저널 폼 — 폰(operator) 전용(docs/TARGETS.md T-3).
//
// 🔴 이 파일은 lib/journal_draft.dart 배럴에만 export 된다.
//    배럴(lib/ui_journal.dart)·다른 lib/ 파일에서 import 하지 않는다(방향 제한).
// 🔴 저장 패키지·파일 쓰기·재시작 생존 금지(재시작 생존 = R2b).
// 🔴 kIsWeb·Platform.* 금지.
// 🔴 FlagIds.ledgerFix 포함 — 어떤 플래그로도 제출 버튼 끄기 금지.
// 🔴 rejectReasonCode 표시·분기 금지.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/journal_common.dart';
import '../timeline.dart';

// ── Injection provider ────────────────────────────────────────────────────────

/// J-3 명령 API 주입 프로바이더 — 애플리케이션 컴포지션 루트가 공급한다.
///
/// 🔴 주입 프로바이더: throw 기본값(데이터 프로바이더와 다름 — 규칙 10).
/// 🔴 탭·제출 콜백 안에서 ref.read 만 — build 에서 watch·read 금지.
final journalCommandApiProvider = Provider<CommandApi>(
  (Ref ref) => throw UnimplementedError('journalCommandApiProvider'),
);

// ── Data provider ─────────────────────────────────────────────────────────────

/// J-3 폼 스펙 — `JournalRepository.draftFormSpec(decisionId)`.
///
/// 🔴 데이터 프로바이더: throw 기본값 금지.
final journalDraftFormSpecProvider =
    FutureProvider.family<JournalDraftFormSpec, String>(
      (Ref ref, String decisionId) =>
          ref.watch(journalTimelineRepositoryProvider).draftFormSpec(
            decisionId,
          ),
    );

// ── Public widget ─────────────────────────────────────────────────────────────

/// J-3 사전 저널 폼 — Scaffold·AppBar·SafeArea 없음(01 §9).
///
/// [decisionId] 는 셸이 라우트 파라미터에서 꺼내 생성자로 넘긴다.
class JournalDraftForm extends ConsumerStatefulWidget {
  const JournalDraftForm({super.key, required this.decisionId});

  final String decisionId;

  @override
  ConsumerState<JournalDraftForm> createState() => _JournalDraftFormState();
}

class _JournalDraftFormState extends ConsumerState<JournalDraftForm> {
  // ── Input state (only alive while screen is alive) ─────────────────────────
  final TextEditingController _rationaleCtrl = TextEditingController();
  final TextEditingController _expectedCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  ReasonOption? _selectedRule;

  // ── Command state ──────────────────────────────────────────────────────────
  CommandReceipt? _receipt;
  StreamSubscription<CommandReceipt>? _cmdSub;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rationaleCtrl.addListener(_onInputChanged);
    _expectedCtrl.addListener(_onInputChanged);
    _noteCtrl.addListener(_onInputChanged);
  }

  void _onInputChanged() => setState(() {});

  @override
  void dispose() {
    _cmdSub?.cancel();
    _rationaleCtrl.dispose();
    _expectedCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Submit logic ───────────────────────────────────────────────────────────

  bool _canSubmit(JournalDraftFormSpec spec) {
    if (_receipt != null) {
      // executed → no submit button at all; locked states → no submit
      final CommandState st = _receipt!.state;
      switch (st) {
        case CommandState.executed:
          return false;
        case CommandState.requested:
        case CommandState.received:
        case CommandState.staleContext:
        case CommandState.heldForIntegrity:
        case CommandState.pendingLeaseConfirm:
        case CommandState.noOperator:
          // locked — button absent
          return false;
        case CommandState.rejected:
        case CommandState.expired:
          // re-editable → fall through to normal check
          break;
      }
    }
    if (_selectedRule == null) return false;
    if (_rationaleCtrl.text.length < spec.rationaleMinChars) return false;
    if (_expectedCtrl.text.trim().isEmpty) return false;
    if (_selectedRule!.requiresNote && _noteCtrl.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool _isLocked() {
    if (_receipt == null) return false;
    return switch (_receipt!.state) {
      CommandState.requested ||
      CommandState.received ||
      CommandState.staleContext ||
      CommandState.heldForIntegrity ||
      CommandState.pendingLeaseConfirm ||
      CommandState.noOperator => true,
      _ => false,
    };
  }

  bool _isExecuted() {
    return _receipt?.state == CommandState.executed;
  }

  Future<void> _submit(JournalDraftFormSpec spec) async {
    final ReasonOption rule = _selectedRule!;
    final String note = _noteCtrl.text.trim().isEmpty ? '' : _noteCtrl.text;
    final JournalDraft draft = JournalDraft(
      decisionId: spec.decisionId,
      rationaleBefore: _rationaleCtrl.text,
      expectedOutcome: _expectedCtrl.text,
      ruleCited: rule.code,
      note: note.isEmpty ? null : note,
    );

    setState(() => _submitting = true);
    try {
      final CommandReceipt initial = await ref
          .read(journalCommandApiProvider)
          .submitJournalDraft(draft);
      if (!mounted) return;
      setState(() {
        _receipt = initial;
        _submitting = false;
      });
      // Watch command stream
      unawaited(_cmdSub?.cancel() ?? Future<void>.value());
      _cmdSub = ref
          .read(journalCommandApiProvider)
          .watchCommand(initial.commandId)
          .listen((CommandReceipt r) {
            if (!mounted) return;
            setState(() => _receipt = r);
          });
    } catch (_) {
      // On Future error: keep inputs, restore pre-submit state (추측 — J3_questions Q1)
      if (!mounted) return;
      setState(() {
        _submitting = false;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final AsyncValue<JournalDraftFormSpec> specAsync = ref.watch(
      journalDraftFormSpecProvider(widget.decisionId),
    );

    return specAsync.when(
      loading: () => const JournalSkeleton(),
      error: (Object e, _) => JournalErrorView(
        onRetry: () =>
            ref.invalidate(journalDraftFormSpecProvider(widget.decisionId)),
      ),
      data: (JournalDraftFormSpec spec) {
        final Clock clock = ref.watch(journalClockProvider);
        final bool isStale = spec.asOf.observedAt
            .add(spec.asOf.staleAfter)
            .isBefore(clock.nowUtc());

        // Safety state
        final SafetyState? safety =
            ref.watch(journalSafetyStateProvider).valueOrNull;
        final List<BlockFlag> blockingFlags =
            safety?.activeFlags
                .where(
                  (BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId),
                )
                .toList() ??
            <BlockFlag>[];
        final List<BlockFlag> markerFlags =
            safety?.activeFlags
                .where(
                  (BlockFlag f) => FlagIds.markerOnly.contains(f.flagId),
                )
                .toList() ??
            <BlockFlag>[];

        final bool locked = _isLocked();
        final bool executed = _isExecuted();

        return ListView(
          children: <Widget>[
            // ── As-of header ─────────────────────────────────────────────────
            JournalAsOfHeader(asOf: spec.asOf),
            if (isStale) JournalStaleBanner(asOf: spec.asOf),

            // ── Safety flags ─────────────────────────────────────────────────
            if (blockingFlags.isNotEmpty)
              JournalBlockingFlags(flags: blockingFlags),
            if (markerFlags.isNotEmpty) JournalMarkerChips(flags: markerFlags),

            // ── Deviation badge ───────────────────────────────────────────────
            if (spec.deviation.isDeviation)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Chip(label: Text(spec.deviation.label)),
              ),

            // ── Pledge block (pledgeLines >= 1) ───────────────────────────────
            if (spec.pledgeLines.isNotEmpty)
              Padding(
                key: const Key('j3-pledge-block'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: spec.pledgeLines
                      .map(Text.new)
                      .toList(growable: false),
                ),
              ),

            // ── Context chips ─────────────────────────────────────────────────
            if (spec.contextChips.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: spec.contextChips
                      .map((ReasonChip c) => JournalReasonChip(chip: c))
                      .toList(growable: false),
                ),
              ),

            // ── Command state label (shown when receipt present) ───────────────
            if (_receipt != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(_receipt!.stateLabel),
              ),

            // ── noticeLine ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(spec.noticeLine),
            ),

            // ── Input area or executed state ──────────────────────────────────
            if (executed)
              // executed: hide input area, show stateLabel
              const SizedBox.shrink()
            else ...<Widget>[
              // ── Rationale ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _rationaleCtrl,
                  enabled: !locked && !_submitting,
                  decoration: const InputDecoration(
                    labelText: JournalLabels.draftRationale,
                  ),
                  minLines: 3,
                  maxLines: 6,
                ),
              ),

              // ── Expected outcome ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _expectedCtrl,
                  enabled: !locked && !_submitting,
                  decoration: const InputDecoration(
                    labelText: JournalLabels.draftExpected,
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
              ),

              // ── Rule cited dropdown ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButton<ReasonOption>(
                  isExpanded: true,
                  value: _selectedRule,
                  hint: const Text(JournalLabels.draftRuleCited),
                  items: spec.ruleCitedOptions
                      .map(
                        (ReasonOption o) => DropdownMenuItem<ReasonOption>(
                          value: o,
                          child: Text(o.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (locked || _submitting)
                      ? null
                      : (ReasonOption? v) =>
                          setState(() => _selectedRule = v),
                ),
              ),

              // ── Note (visible always; required depends on requiresNote) ───
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _noteCtrl,
                  enabled: !locked && !_submitting,
                  decoration: const InputDecoration(
                    labelText: JournalLabels.draftNote,
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
              ),

              // ── Submit button ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: FilledButton(
                  onPressed: _canSubmit(spec) ? () => _submit(spec) : null,
                  child: const Text(JournalLabels.draftSubmit),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
