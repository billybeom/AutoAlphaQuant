// 🆕 E16j-a — X5 정정 마법사 읽기 창구 operator 판(설계 13 §8 R227 · 01 §41 K249 · 01 §8 미결 217 ⓔ).
//
// 🔴 화면 상태의 원장 → data_sync 원천(`SqliteRepairWizardSource`) → 엔진 VM(`repairWizardVmOf`) · 원장 변경(diff · 차단 · 개입 ·
//    저널 · 스탬프 · 체결 · 정정 · 재량) · 주기마다 다시 낸다(냉각 · 실행 창 = 신뢰 시각이 흐른다) · 같은 값 = 다시 내지 않음.
// 🔴 쓰기 창구 = 폰의 안전 동작 한 인스턴스(늘 주입 · 잠김 = 미결 169 · 지금 조립 = 쓰기 가능) · 링크 = 레지스트리에 본문이 있을 때만.
// 🔴 서약 문장(2단계 재생) = sim 원장(서약 갈래 · R157) · 아카이브 관계 = 일일 아카이브 잡(E11n) 전 = 모름(null).
// 🔴 신뢰 시각 = 런타임 시계(E11k 전 = 모름 → 단계 동작 0 — 엔진).
// 🔴 쓰기(`OperatorRepairActions` — 안전 동작 창구가 부른다) = 엔진 data_sync 그대로 · 결과 글자 = 엔진 `repairWizardResultOf`:
//    단계 = `SqliteInterventionStore.advance` · 3단계 저널 = `writeJournalStage`(저널 id = `JIV-<명령 id>`) · 아무것도 안 하기 =
//    `acceptWithSession` · 정정 = 원문 파싱(엔진) → 대상의 열린 세션 → 실행 창 안이면 직전 재대사(런타임 `freshRecon` · 못 하면
//    «잠시 뒤 다시») → `correctFill`(정정 id = `RPR-<명령 id>` · 체인 상한 = 운영 설정 `operations.amend_chain_max` — 🆕 미결 220 ⓑ ·
//    못 읽음 = 정정 0(오류 · 증권사 0 · 지어내지 않음)) · 새 기준점 = 지금 무결성 대상과 같을 때만
//    `applyBaseline`(정정 id = `RBL-<명령 id>` · 해제자 = 기기 별칭 · 아카이브 관계 = 모름) · 다른 정정 중(`LedgerFixBusy`) = «잠시 뒤 다시».
// 🔴 생체 = 구현 0(운영 등급 공통 관문 = 미결 169 · 서약 · RECON 해제 선례).

import 'package:core_engine/core_engine.dart'
    show
        InterventionOutcome,
        KillSwitchScreenTexts,
        RepairInputCodes,
        RepairRunHold,
        StoredLedgerDiff,
        integrityTargetIdOf,
        interventionExecutable,
        parseRepairAmounts,
        repairWizardResultOf;
import 'package:data_sync/data_sync.dart'
    show
        BaselineResult,
        FillCorrectionResult,
        FillRestatement,
        InterventionStepResult,
        LedgerFixBusy,
        SqliteInterventionStore,
        SqliteLedgerRepairStore,
        SqlitePledgeStore,
        SqliteRepairWizardSource,
        interventionSessionOf,
        storedLedgerDiffs,
        watchLedgerQuery,
        x5OpenSessionIdOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        InterventionJournalSubmission,
        InterventionResultCodes,
        InterventionStepOutcome,
        RepairBaselineSubmission,
        RepairCorrectSubmission,
        RepairResultCodes,
        RepairWizardRepository,
        RepairWizardVm,
        SafetyActionId,
        SafetyActionResult;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// X5 정정 마법사 읽기(operator).
class OperatorRepairWizardRepository implements RepairWizardRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [writable] = 쓰기 창구가 있고 잠김이 아닌가 ·
  /// [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorRepairWizardRepository(
    this._rt, {
    required this.hasBody,
    this.writable = true,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 쓰기 창구가 있고 잠김이 아닌가.
  final bool writable;

  /// 다시 읽는 주기.
  final Duration tick;

  SqliteRepairWizardSource _src(OperatorView v) => SqliteRepairWizardSource(
    v.db,
    clock: _rt.clock,
    trusted: _rt.trusted,
    writable: writable,
    hasBody: hasBody,
    pledgeLines: () => SqlitePledgeStore(
      _rt.files.sim,
      clock: _rt.clock,
      trusted: _rt.trusted,
    ).pledgeLines(),
  );

  @override
  Stream<RepairWizardVm> watchRepair({String? targetId}) {
    RepairWizardVm read(OperatorView v) => _src(v).vm(targetId: targetId);
    return followView<RepairWizardVm>(
      view: _rt.view,
      changes: (OperatorView v) => watchLedgerQuery<RepairWizardVm>(
        v.db,
        SqliteRepairWizardSource.watchedTables,
        () => read(v),
      ),
      now: read,
      tick: tick,
      noView: () => StateError('정정 마법사: 화면 상태 없음(온보딩 전)'),
    );
  }
}

/// 🆕 E16j-a — X5 정정 마법사 쓰기(안전 동작 창구가 명령 id · 요약을 짓고 부른다).
class OperatorRepairActions {
  /// 만든다.
  OperatorRepairActions(this._rt);

  final OperatorRuntime _rt;

  OperatorView _view(String what) {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('$what: 화면 상태 없음(온보딩 전)');
    return v;
  }

  /// `interventionStep{session_id, stage, outcome, decision_id?}` — 엔진이 완성한 args 그대로.
  SafetyActionResult step(String run, String digest, Map<String, String> args) {
    final String? sid = args['session_id'];
    final int? stage = int.tryParse(args['stage'] ?? '');
    final InterventionStepOutcome? outcome = InterventionStepOutcome.values
        .where((InterventionStepOutcome o) => o.wire == args['outcome'])
        .firstOrNull;
    if (sid == null || sid.trim().isEmpty || stage == null || outcome == null) {
      throw ArgumentError.value(
        args,
        'args',
        'session_id · stage · outcome 필요',
      );
    }
    final OperatorView v = _view('개입 단계');
    final InterventionStepResult r =
        SqliteInterventionStore(
          v.db,
          clock: _rt.clock,
          trusted: _rt.trusted,
        ).advance(
          commandId: run,
          payloadDigest: digest,
          sessionId: sid,
          stage: stage,
          outcome: InterventionOutcome.fromWire(outcome.wire),
          decisionId: args['decision_id'],
        );
    if (!r.executed && r.reasonCode == null) {
      throw StateError('개입 단계: 엔진이 사유 없이 거부했다');
    }
    return repairWizardResultOf(
      id: SafetyActionId.interventionStep,
      actionRunId: run,
      code: r.executed ? null : r.reasonCode,
      step: outcome,
    );
  }

  /// `repairAccept{diff_id}` — 이 diff 의 마법사 세션 DO_NOTHING + ACCEPTED.
  SafetyActionResult accept(String run, Map<String, String> args) {
    final String? diffId = args['diff_id'];
    if (diffId == null || diffId.trim().isEmpty) {
      throw ArgumentError.value(args, 'args', 'diff_id 필요');
    }
    final OperatorView v = _view('아무것도 안 하기');
    return repairWizardResultOf(
      id: SafetyActionId.repairAccept,
      actionRunId: run,
      code: SqliteLedgerRepairStore(
        v.db,
        trusted: _rt.trusted,
      ).acceptWithSession(diffId),
    );
  }

  /// 3단계 사전 저널(살아 있는 세션 하나에 · 저널 id = `JIV-<명령 id>`).
  SafetyActionResult journal(
    String run,
    String digest,
    InterventionJournalSubmission s,
  ) {
    final OperatorView v = _view('사전 저널');
    final InterventionStepResult r =
        SqliteInterventionStore(
          v.db,
          clock: _rt.clock,
          trusted: _rt.trusted,
        ).writeJournalStage(
          commandId: run,
          payloadDigest: digest,
          journalId: 'JIV-$run',
          rationaleBefore: s.rationaleBefore,
          expectedOutcome: s.expectedOutcome,
          ruleCited: s.ruleCited,
        );
    if (!r.executed && r.reasonCode == null) {
      throw StateError('사전 저널: 엔진이 사유 없이 거부했다');
    }
    return repairWizardResultOf(
      id: SafetyActionId.interventionJournal,
      actionRunId: run,
      code: r.executed ? null : r.reasonCode,
    );
  }

  /// 정본 정정(diff 갈래 · 5단계 = 이 커밋).
  Future<SafetyActionResult> correct(
    String run,
    RepairCorrectSubmission s,
  ) async {
    SafetyActionResult out({String? code, RepairRunHold? hold}) =>
        repairWizardResultOf(
          id: SafetyActionId.repairCorrect,
          actionRunId: run,
          code: code,
          hold: hold,
        );
    final OperatorView v = _view('정정');
    final ({int quantity, double price, double commission, double tax})?
    amounts = s.voidFill
        ? null
        : parseRepairAmounts(
            quantityText: s.quantityText,
            priceText: s.priceText,
            commissionText: s.commissionText,
            taxText: s.taxText,
          );
    if (!s.voidFill && amounts == null) {
      return out(code: RepairInputCodes.amountInvalid);
    }
    final String? sid = x5OpenSessionIdOf(v.db, s.targetId);
    if (sid == null) return out(code: InterventionResultCodes.outOfOrder);
    // 🆕 미결 220 ⓑ — 체인 상한 = 운영 설정(X5 · X7 공용 키) · 못 읽음 = 정정 0(증권사에 가기 전 · 지어내지 않음).
    final int? chainLimit = _rt.operations?.amendChainMax;
    if (chainLimit == null) {
      throw StateError('정정: 운영 설정 없음(operations.amend_chain_max)');
    }
    Iterable<String> fresh = const <String>[];
    // 실행 창 안일 때만 증권사에 간다(아니면 커밋 관문이 개입 코드로 거부한다 — 망 0).
    if (interventionExecutable(
      interventionSessionOf(v.db, sid),
      _rt.trusted.trustedNowUtc()?.toUtc(),
    )) {
      final StoredLedgerDiff? d = storedLedgerDiffs(v.db)
          .where((StoredLedgerDiff x) => x.diffId == s.targetId)
          .firstOrNull;
      if (d != null) {
        final Set<String>? ids = await _rt.freshRecon?.call(v, d.authoredDate);
        if (ids == null) return out(hold: RepairRunHold.reconUnavailable);
        fresh = ids;
      }
    }
    try {
      final FillCorrectionResult r =
          SqliteLedgerRepairStore(v.db, trusted: _rt.trusted).correctFill(
            repairId: 'RPR-$run',
            diffId: s.targetId,
            freshDiffIds: fresh,
            fillId: s.fillRef,
            sessionId: sid,
            originCode: s.originCode,
            chainLimit: chainLimit,
            restatement: amounts == null
                ? null
                : FillRestatement(
                    quantity: amounts.quantity,
                    price: amounts.price,
                    commission: amounts.commission,
                    tax: amounts.tax,
                  ),
          );
      if (!r.applied && r.rejectCode == null) {
        throw StateError('정정: 엔진이 사유 없이 거부했다');
      }
      return out(code: r.applied ? null : r.rejectCode);
    } on LedgerFixBusy {
      return out(hold: RepairRunHold.busy);
    }
  }

  /// 새 기준점(무결성 갈래 · 5단계 = 이 커밋).
  SafetyActionResult baseline(String run, RepairBaselineSubmission s) {
    SafetyActionResult out({String? code, RepairRunHold? hold}) =>
        repairWizardResultOf(
          id: SafetyActionId.repairBaseline,
          actionRunId: run,
          code: code,
          hold: hold,
        );
    final OperatorView v = _view('새 기준점');
    final String? sid = x5OpenSessionIdOf(v.db, s.targetId);
    if (sid == null) return out(code: InterventionResultCodes.outOfOrder);
    // 🔴 지금 무결성 대상과 다르면(판정이 바뀌었다) 처음부터 — 다른 날 · 사유로 다시 쓰지 않는다.
    final String? li = integrityTargetIdOf(
      SqliteRepairWizardSource(
        v.db,
        clock: _rt.clock,
        trusted: _rt.trusted,
        writable: true,
        hasBody: (String _) => false,
      ).facts(),
    );
    if (li != null && li != s.targetId) {
      return out(code: RepairResultCodes.deltaChanged);
    }
    try {
      final BaselineResult r =
          SqliteLedgerRepairStore(v.db, trusted: _rt.trusted).applyBaseline(
            repairId: 'RBL-$run',
            sessionId: sid,
            originCode: s.originCode,
            clearedBy: KillSwitchScreenTexts.operatorPhone,
          );
      if (!r.applied && r.rejectCode == null) {
        throw StateError('새 기준점: 엔진이 사유 없이 거부했다');
      }
      return out(code: r.applied ? null : r.rejectCode);
    } on LedgerFixBusy {
      return out(hold: RepairRunHold.busy);
    }
  }
}
