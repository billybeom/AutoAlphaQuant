// M5-8 서약 operator 판 — 읽기 창구(`PledgeRepository`) · 안전 동작(`SafetyActions` — 지금 = 서약만)(E11p4h · 설계 13 §8
// R157 · 01 §30 K6 · K31 · K32 · 엔진 R67 Z1 · Z2).
//
// 🔴 원장 = sim 파일(온보딩 ② 와 같은 갈래 — 마무리 사실 `pledged` 도 여기서 읽는다).
// 🔴 쓰기 = 엔진 `SqlitePledgeStore.writeFirst` · `edit`(같은 원장 · 한 트랜잭션 · `command_inbox` 멱등) · 결과 = 엔진
//    `pledgeActionResultOf`(등급 · 문장) — 앱이 문장을 짓지 않는다.
// 🔴 첫 판 저널 id = 명령 id(R67 Z1) · 편집 저널 id = 제출 그대로(사전 저널 원천 = 01 §8 미결 185 · 없으면 엔진 거부).
// 🔴 신뢰 시각 = `OperatorRuntime.trusted`(E11k 전 = 모름 → 엔진 `TRUSTED_TIME_UNKNOWN`).
// 🔴 서약 밖 안전 동작(재개 · STOPPED 결정 · 사후 검토 · 규칙 변경 · 재량 조정 · `run`) = operator 구현 전(오류 — 지어내지 않는다).

import 'dart:math';

import 'package:core_engine/core_engine.dart'
    show
        KillSwitchRecord,
        ResumeChecklist,
        ResumeItemAnswer,
        ResumeReadiness,
        ResumeReadinessKind,
        issueKillCommand,
        killResumeItemAnswerOf,
        killResumeResultOf,
        newCommandId,
        pledgeActionResultOf,
        pledgeSubmissionDigest,
        pledgeVmOf,
        resumeReadinessOf;
import 'package:data_sync/data_sync.dart'
    show
        KillCommandResult,
        PledgeResult,
        SqliteKillSwitchStore,
        SqlitePledgeStore,
        readKillSwitchRecord,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart';

import 'operator_kill_switch.dart' show OperatorKillResumeDraft;
import 'operator_runtime.dart';
import 'operator_view.dart';

SqlitePledgeStore _store(OperatorRuntime rt) =>
    SqlitePledgeStore(rt.files.sim, clock: rt.clock, trusted: rt.trusted);

/// 서약 읽기(operator) — `pledge` 표가 바뀔 때마다 다시 낸다.
class OperatorPledgeRepository implements PledgeRepository {
  /// 만든다.
  OperatorPledgeRepository(this._rt);

  final OperatorRuntime _rt;

  @override
  Stream<PledgeVm> watchPledge() => watchLedgerQuery<PledgeVm>(
    _rt.files.sim,
    const <String>{'pledge'},
    () => pledgeVmOf(
      current: _store(_rt).currentPledge(),
      trustedNowUtc: _rt.trusted.trustedNowUtc(),
      nowUtc: _rt.clock.nowUtc(),
    ),
  );
}

/// 안전 동작(operator) — 지금 = 서약 첫 판 · 편집.
class OperatorSafetyActions implements SafetyActions {
  /// 만든다 — [random] = 명령 id 원천(기본 = `Random.secure()`).
  OperatorSafetyActions(
    this._rt, {
    Random? random,
    OperatorKillResumeDraft? draft,
  }) : _random = random ?? Random.secure(),
       draft = draft ?? OperatorKillResumeDraft();

  /// 🆕 R180 — 재개판 초안(게이트 읽기와 같은 인스턴스).
  final OperatorKillResumeDraft draft;

  final OperatorRuntime _rt;
  final Random _random;

  /// 이 인스턴스가 낸 동작의 결과(동작 id → 결과).
  final Map<String, SafetyActionResult> _done = <String, SafetyActionResult>{};

  static Future<SafetyActionResult> _none(String what) =>
      Future<SafetyActionResult>.error(
        UnsupportedError('$what: operator 구현 없음(R157)'),
      );

  @override
  Future<SafetyActionResult> runPledge(PledgeSubmission submission) async {
    final SafetyActionId id = submission.id;
    if (id != SafetyActionId.pledgeWrite && id != SafetyActionId.pledgeEdit) {
      throw ArgumentError.value(id, 'id', '서약 동작이 아니다');
    }
    final String commandId = newCommandId(_random);
    final String digest = pledgeSubmissionDigest(submission);
    final SqlitePledgeStore store = _store(_rt);
    final PledgeResult r = id == SafetyActionId.pledgeWrite
        ? store.writeFirst(
            commandId: commandId,
            payloadDigest: digest,
            sentences: submission.sentences,
            decisionId: commandId,
          )
        : store.edit(
            commandId: commandId,
            payloadDigest: digest,
            sentences: submission.sentences,
            decisionId: submission.decisionId ?? '',
          );
    if (!r.executed && r.reasonCode == null) {
      throw StateError('서약: 엔진이 사유 없이 거부했다');
    }
    final SafetyActionResult out = pledgeActionResultOf(
      actionRunId: commandId,
      id: id,
      reasonCode: r.executed ? null : r.reasonCode,
    );
    _done[commandId] = out;
    return out;
  }

  /// 이 인스턴스가 낸 동작만 — 폰 안에서 바로 끝나므로 결과 하나(모르는 id = 오류).
  @override
  Stream<SafetyActionResult> watch(String actionRunId) {
    final SafetyActionResult? r = _done[actionRunId];
    return r == null
        ? Stream<SafetyActionResult>.error(
            StateError('안전 동작 $actionRunId: 이 기기에서 낸 동작이 아님'),
          )
        : Stream<SafetyActionResult>.value(r);
  }

  @override
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  }) => _none('run(${id.wire})');

  /// 🆕 E11q-b1b(R180) — 재개판 한 문항(K36): ① 재개 준비(엔진 차례 그대로 — 꺼짐 · 확인 전 · 시각 모름 · 대기) ·
  /// ② 생체 = 구현 0(서약 선례 · 운영 등급 공통 관문 밖) · ③ 엔진 `ResumeChecklist.accept`(순차 · 빈칸 · 4번 미충족) ·
  /// ④ 7번 통과 = 엔진 `resume()` 한 트랜잭션(해제 · 저널 id `KS-RES-<명령 id>`) · 1번 제출 = 초안을 비우고 처음부터 ·
  /// 결과 글자 = 엔진(`killResumeResultOf`) · 결과 id = 늘 `killSwitchResume`.
  @override
  Future<SafetyActionResult> runKillResumeItem(
    KillResumeItemSubmission submission,
  ) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('재개: 화면 상태 없음(온보딩 전)');
    final ({String commandId, String nonce, String payloadDigest}) c =
        issueKillCommand(payload: submission.toJson(), random: _random);
    final String run = c.commandId;
    SafetyActionResult keep(SafetyActionResult r) => _done[run] = r;
    final KillSwitchRecord rec = readKillSwitchRecord(v.db);
    final ResumeReadiness ready = resumeReadinessOf(
      rec,
      _rt.trusted.trustedNowUtc(),
    );
    final String? gate = switch (ready.kind) {
      ResumeReadinessKind.inactive => 'KILL_SWITCH_NOT_ACTIVE',
      ResumeReadinessKind.checklistNotConfirmed =>
        'RESUME_CHECKLIST_NOT_CONFIRMED',
      ResumeReadinessKind.trustedTimeUnknown => 'RESUME_TRUSTED_TIME_UNKNOWN',
      ResumeReadinessKind.waiting => 'RESUME_TOO_SOON',
      ResumeReadinessKind.ready => null,
    };
    if (gate != null) {
      return keep(
        killResumeResultOf(actionRunId: run, code: gate, etaUtc: ready.etaUtc),
      );
    }
    if (submission.itemNo == 1) draft.value = ResumeChecklist.empty;
    final ResumeItemAnswer a = killResumeItemAnswerOf(
      submission,
      journalDecisionId: 'KS-RES-$run',
    );
    final (ResumeChecklist? next, String? code) = draft.value.accept(a);
    if (code != null) {
      return keep(
        killResumeResultOf(
          actionRunId: run,
          code: code,
          submittedItemNo: submission.itemNo,
          nextItemNo: draft.value.next,
        ),
      );
    }
    if (next!.conditionUnmet) {
      draft.value = next;
      return keep(
        killResumeResultOf(actionRunId: run, code: 'RESUME_CONDITION_UNMET'),
      );
    }
    if (!next.complete) {
      draft.value = next;
      return keep(
        killResumeResultOf(actionRunId: run, acceptedItemNo: submission.itemNo),
      );
    }
    final KillCommandResult r = SqliteKillSwitchStore(
      v.db,
      clock: _rt.clock,
      trusted: _rt.trusted,
    ).resume(commandId: run, payloadDigest: c.payloadDigest, checklist: next);
    if (r.executed) {
      draft.value = ResumeChecklist.empty;
      return keep(killResumeResultOf(actionRunId: run, done: true));
    }
    return keep(
      killResumeResultOf(
        actionRunId: run,
        code: r.reasonCode,
        submittedItemNo: 7,
        nextItemNo: 7,
      ),
    );
  }

  @override
  Future<SafetyActionResult> runStoppedDecision(
    StoppedDecisionSubmission submission,
  ) => _none('runStoppedDecision');

  @override
  Future<SafetyActionResult> runPostmortem(PostmortemSubmission submission) =>
      _none('runPostmortem');

  @override
  Future<SafetyActionResult> runRuleChangeApproval(
    RuleChangeApprovalSubmission submission,
  ) => _none('runRuleChangeApproval');

  @override
  Future<SafetyActionResult> runDiscretionAdjust(
    DiscretionAdjustSubmission submission,
  ) => _none('runDiscretionAdjust');

  /// 🆕 계약 v1.26(01 §35 · K178) — 규칙 변경 요청(첫 승인 포함). 실물 = 카드 E11q-c0(엔진 «저널 함께 쓰기» 판 뒤).
  @override
  Future<SafetyActionResult> runRuleChangeRequest(
    RuleChangeRequestSubmission submission,
  ) => _none('runRuleChangeRequest');

  /// 🆕 계약 v1.26(01 §35 · K181) — RECON 해제. 실물 = 카드 E11q-c4(b3 보드 뒤).
  @override
  Future<SafetyActionResult> runReconClear(ReconClearSubmission submission) =>
      _none('runReconClear');
}
