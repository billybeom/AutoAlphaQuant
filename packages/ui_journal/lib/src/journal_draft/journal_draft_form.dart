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
import '../journal_read.dart';
import '../timeline.dart';

// ── Injection providers ────────────────────────────────────────────────────────

/// J-3 명령 API 주입 프로바이더 — 애플리케이션 컴포지션 루트가 공급한다.
///
/// 🔴 주입 프로바이더: throw 기본값(데이터 프로바이더와 다름 — 규칙 10).
/// 🔴 탭·제출 콜백 안에서 ref.read 만 — build 에서 watch·read 금지.
final journalCommandApiProvider = Provider<CommandApi>(
  (Ref ref) => throw UnimplementedError('journalCommandApiProvider'),
);

/// J-3 초안 포트 주입 프로바이더 — 애플리케이션 컴포지션 루트가 공급한다(operator 앱 전용).
///
/// 🔴 주입 프로바이더: throw 기본값(데이터 프로바이더와 다름 — 규칙 10).
/// 🔴 initState·콜백 안에서 ref.read 만 — build 에서 watch·read 금지.
/// 🔴 FutureProvider(.family) 로 감싸지 않는다(autoDispose 0 → 재진입 때 캐시된 옛 초안).
final journalDraftStoreProvider = Provider<DraftStore>(
  (Ref ref) => throw UnimplementedError('journalDraftStoreProvider'),
);

// ── Data provider ─────────────────────────────────────────────────────────────

/// J-3 폼 스펙 — `JournalRepository.draftFormSpec(decisionId)`.
///
/// 🔴 데이터 프로바이더: throw 기본값 금지.
final journalDraftFormSpecProvider =
    FutureProvider.family<JournalDraftFormSpec, String>(
      (Ref ref, String decisionId) => ref
          .watch(journalTimelineRepositoryProvider)
          .draftFormSpec(decisionId),
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

  // ── Draft store state ──────────────────────────────────────────────────────
  late final DraftKey _draftKey = DraftKey(
    kind: DraftKind.journalDraft,
    targetId: widget.decisionId,
  );
  bool _restoreDone = false;
  bool _applyingRestore = false;
  bool _awaitingReceipt = false;
  bool _resubscribeFailed = false;
  bool _submitNotAccepted = false;
  bool _draftCleared = false;
  String? _pendingRuleCode;
  String? _commandId;
  DraftRecord? _lastPersisted;

  @override
  void initState() {
    super.initState();
    _rationaleCtrl.addListener(_onInputChanged);
    _expectedCtrl.addListener(_onInputChanged);
    _noteCtrl.addListener(_onInputChanged);
    unawaited(_restore());
  }

  void _onInputChanged() {
    setState(() {});
    _persist();
  }

  @override
  void dispose() {
    _cmdSub?.cancel();
    _rationaleCtrl.dispose();
    _expectedCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Draft store helpers ────────────────────────────────────────────────────

  void _report(Object e, StackTrace st) => FlutterError.reportError(
    FlutterErrorDetails(exception: e, stack: st, library: 'ui_journal'),
    // 🔴 입력값을 싣지 않는다
  );

  /// 포트 호출 감싸기 — 동기 throw(미주입 throw 기본값·계약을 어긴 구현)도 onError 로 모은다.
  void _port(Future<void> Function(DraftStore s) call) => unawaited(
    Future<void>.sync(() => call(ref.read(journalDraftStoreProvider))).then<void>(
      (_) {},
      onError: _report,
    ),
  );

  Future<void> _restore() async {
    DraftRecord? r;
    try {
      r = await ref.read(journalDraftStoreProvider).load(_draftKey);
    } catch (e, st) {
      _report(e, st);
    }
    if (!mounted) return;
    final JournalDraftInput? j = r?.journal;
    // 복원값(없으면 빈 본문)을 «직전 저장»으로 둔다 — 포커스·선택만으로는 save 가 나가지 않는다.
    _lastPersisted = r ?? DraftRecord(key: _draftKey, journal: const JournalDraftInput());
    _applyingRestore = true;
    if (j != null) {
      _rationaleCtrl.text = j.rationaleBefore;
      _expectedCtrl.text = j.expectedOutcome;
      _noteCtrl.text = j.note;
      _pendingRuleCode = j.ruleCited;
    }
    _applyingRestore = false;
    setState(() {
      _commandId = r?.lastCommandId;
      _awaitingReceipt = _commandId != null;
      _restoreDone = true;
    });
    if (_commandId != null) {
      _subscribe(_commandId!);
    }
  }

  void _persist() {
    if (!_restoreDone || _applyingRestore) return;
    final DraftRecord record = DraftRecord(
      key: _draftKey,
      journal: JournalDraftInput(
        rationaleBefore: _rationaleCtrl.text,
        expectedOutcome: _expectedCtrl.text,
        ruleCited: _effectiveRule(null)?.code ?? _pendingRuleCode,
        note: _noteCtrl.text,
      ),
      lastCommandId: _commandId,
    );
    if (record == _lastPersisted) return;
    _lastPersisted = record;
    _port((DraftStore s) => s.save(record));
  }

  void _applyReceipt(CommandReceipt r) {
    if (!mounted) return;
    setState(() {
      _receipt = r;
      _awaitingReceipt = false;
      _resubscribeFailed = false;
    });
    if (r.state == CommandState.executed && !_draftCleared) {
      _draftCleared = true;
      _port((DraftStore s) => s.clear(_draftKey)); // 🔴 clear 를 부르는 곳은 여기 하나(C17)
    }
  }

  void _subscribe(String commandId) {
    unawaited(_cmdSub?.cancel() ?? Future<void>.value());
    _cmdSub = ref.read(journalCommandApiProvider).watchCommand(commandId).listen(
      _applyReceipt,
      onError: (Object e, StackTrace st) {
        _report(e, st);
        if (mounted && _awaitingReceipt) {
          setState(() => _resubscribeFailed = true);
        }
        // 접수증이 이미 있으면 마지막 접수증 유지(51 ③)
      },
      onDone: () {
        // 첫 접수증 없이 끝나면 = 에러와 같다(영구 잠금 탈출구 · 01 §12-4)
        if (mounted && _awaitingReceipt) {
          setState(() => _resubscribeFailed = true);
        }
      },
    );
  }

  void _resubscribe() {
    setState(() => _resubscribeFailed = false);
    _subscribe(_commandId!);
  }

  // ── Rule helpers ──────────────────────────────────────────────────────────

  ReasonOption? _effectiveRule(JournalDraftFormSpec? spec) {
    if (_selectedRule != null) return _selectedRule;
    if (spec == null || _pendingRuleCode == null) return null;
    return spec.ruleCitedOptions
        .where((ReasonOption o) => o.code == _pendingRuleCode)
        .firstOrNull;
  }

  // ── Submit logic ───────────────────────────────────────────────────────────

  bool _canSubmit(JournalDraftFormSpec spec) {
    if (_receipt != null) {
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
          return false;
        case CommandState.rejected:
        case CommandState.expired:
          break;
      }
    }
    final ReasonOption? rule = _effectiveRule(spec);
    if (rule == null) return false;
    if (_rationaleCtrl.text.trim().length < spec.rationaleMinChars) {
      return false;
    }
    if (_expectedCtrl.text.trim().isEmpty) return false;
    if (rule.requiresNote && _noteCtrl.text.trim().isEmpty) {
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
      CommandState.rejected ||
      CommandState.expired ||
      CommandState.executed => false,
    };
  }

  bool _isExecuted() {
    return _receipt?.state == CommandState.executed;
  }

  Future<void> _submit(JournalDraftFormSpec spec) async {
    final ReasonOption rule = _effectiveRule(spec)!;
    final String note = _noteCtrl.text.trim().isEmpty ? '' : _noteCtrl.text;
    final JournalDraft draft = JournalDraft(
      decisionId: spec.decisionId,
      rationaleBefore: _rationaleCtrl.text,
      expectedOutcome: _expectedCtrl.text,
      ruleCited: rule.code,
      note: note.isEmpty ? null : note,
    );

    setState(() {
      _submitting = true;
      _submitNotAccepted = false;
    });
    final CommandReceipt initial;
    try {
      initial = await ref.read(journalCommandApiProvider).submitJournalDraft(draft);
    } catch (e, st) {
      // 01 §4-2 · §8 미결 51 ① (J3_questions Q1) · ④ = §12-3
      _report(e, st);
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitNotAccepted = true;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _commandId = initial.commandId;
    });
    // 순서: 연결 저장 → 반영(executed 면 clear) → 구독
    _persist();
    _applyReceipt(initial);
    _subscribe(initial.commandId);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final AsyncValue<JournalDraftFormSpec> specAsync = ref.watch(
      journalDraftFormSpecProvider(widget.decisionId),
    );

    // 복원 게이트 — 복원이 끝날 때까지 스켈레톤
    if (!_restoreDone) return const JournalSkeleton();

    return specAsync.when(
      loading: () => const JournalSkeleton(),
      error: (Object e, _) => JournalErrorView(
        lastAsOfLabel: specAsync.valueOrNull?.asOf.label,
        onRetry: () =>
            ref.invalidate(journalDraftFormSpecProvider(widget.decisionId)),
      ),
      data: (JournalDraftFormSpec spec) {
        final Clock clock = ref.watch(journalClockProvider);
        final bool isStale = spec.asOf.observedAt
            .add(spec.asOf.staleAfter)
            .isBefore(clock.nowUtc());

        // Safety state
        final SafetyState? safety = ref
            .watch(journalSafetyStateProvider)
            .valueOrNull;
        final List<BlockFlag> blockingFlags =
            safety?.activeFlags
                .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
                .toList() ??
            <BlockFlag>[];
        final List<BlockFlag> markerFlags =
            safety?.activeFlags
                .where((BlockFlag f) => FlagIds.markerOnly.contains(f.flagId))
                .toList() ??
            <BlockFlag>[];

        final bool locked = _isLocked() || _awaitingReceipt;
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

            // ── Deviation badge (G9 — DecoratedBox, no fade/ellipsis) ─────────
            if (spec.deviation.isDeviation)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(spec.deviation.label),
                  ),
                ),
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
              // executed: 입력 영역 자리에 읽기 본문(끼워 넣기 · asOf 헤더 생략)
              JournalReadContent(
                decisionId: widget.decisionId,
                showAsOfHeader: false,
              )
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
                  value: _effectiveRule(spec),
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
                      : (ReasonOption? v) {
                          setState(() {
                            _selectedRule = v;
                            _pendingRuleCode = null;
                          });
                          _persist();
                        },
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

              // ── submitNotAccepted 1줄 (01 §12-3) ─────────────────────────
              if (_submitNotAccepted)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Text(
                    JournalLabels.submitNotAccepted,
                    key: const Key('j3-submit-not-accepted'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              // ── 재구독 «다시 시도» 또는 제출 버튼 ───────────────────────
              if (_resubscribeFailed)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextButton(
                    key: const Key('j3-resubscribe'),
                    onPressed: _resubscribe,
                    child: const Text(JournalLabels.retry),
                  ),
                )
              else if (!locked)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: FilledButton(
                    onPressed: (!_submitting && _canSubmit(spec))
                        ? () => _submit(spec)
                        : null,
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
