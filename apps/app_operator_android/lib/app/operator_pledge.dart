// M5-8 서약 operator 판 — 읽기 창구(`PledgeRepository`) · 안전 동작(`SafetyActions` — 지금 = 서약만)(E11p4h · 설계 13 §8
// R157 · 01 §30 K6 · K31 · K32 · 엔진 R67 Z1 · Z2).
//
// 🔴 원장 = 화면 원장(🆕 리뷰 3차 H1-6 · 설계 13 §8 R265 · 미결 231 ⓓ) — 화면 상태 없음(온보딩 ② · 마무리 사실 `pledged`) = 모의 파일 ·
//    실전 전환 뒤 = 실전 파일(커밋이 서약 전 판 · 편집 저널을 옮긴다 · 12월 창 편집이 같은 원장의 J-3 저널을 찾는다).
// 🔴 쓰기 = 엔진 `SqlitePledgeStore.writeFirst` · `edit`(같은 원장 · 한 트랜잭션 · `command_inbox` 멱등) · 결과 = 엔진
//    `pledgeActionResultOf`(등급 · 문장) — 앱이 문장을 짓지 않는다.
// 🔴 첫 판 저널 id = 명령 id(R67 Z1) · 편집 저널 id = 제출 그대로(사전 저널 원천 = 01 §8 미결 185 · 없으면 엔진 거부).
// 🔴 신뢰 시각 = `OperatorRuntime.trusted`(E11k 전 = 모름 → 엔진 `TRUSTED_TIME_UNKNOWN`).
// 🔴 서약 밖 안전 동작 — 재개판(R180) · 규칙 변경 요청 · 승인 · 취소(R188 — `run` 은 `ruleChangeCancel` 만) · 🆕 RECON 해제(R189 ·
//    `runReconClear` — `run(reconClear)` = ArgumentError) = 구현 · STOPPED 결정 · 사후 검토 · 재량 조정 = operator 구현 전(오류 — 지어내지
//    않는다).
// 🆕 E16j-a(R227 · 01 §41 K252~K256 · 미결 217) — X5 정정 마법사: `run(interventionStep)` · `run(repairAccept)` · `runInterventionJournal` ·
//    `runRepairCorrect` · `runRepairBaseline` = 구현(`OperatorRepairActions` — 같은 원장 · 결과 글자 = 엔진).
// 🆕 리뷰 3차 H1-3(설계 13 §8 R261 · 01 §8 미결 235 ⓒ) — 안전 상태를 바꾼 동작(재개 · RECON 해제 · 정정 · 개입 · 기기 이전) 뒤 엔진
//    깨어남 한 번(`OperatorRuntime.wakeNow` · 기다리지 않는다) — FGS 상시 알림이 다음 알람까지 옛 상태로 남지 않게(04 §5-6).

import 'dart:async';
import 'dart:math';

import 'package:core_engine/core_engine.dart'
    show
        KillSwitchRecord,
        KillSwitchScreenTexts,
        ResumeChecklist,
        ResumeItemAnswer,
        ResumeReadiness,
        ResumeReadinessKind,
        RuleChangeCandidate,
        RuleChangeCodes,
        SeasonalWindowChoice,
        issueKillCommand,
        kstDateText,
        killResumeItemAnswerOf,
        killResumeResultOf,
        newCommandId,
        pledgeActionResultOf,
        pledgeSubmissionDigest,
        pledgeVmOf,
        reconClearActionResultOf,
        resumeReadinessOf,
        ruleChangeActionResultOf,
        seasonalChoiceResultOf;
import 'package:data_sync/data_sync.dart'
    show
        KillCommandResult,
        PledgeResult,
        ReconClearWriteResult,
        RuleChangeResult,
        SqliteOrderLedger,
        SqliteRuleChangeStore,
        SqliteSeasonalChoice,
        SqliteKillSwitchStore,
        SqlitePledgeStore,
        readKillSwitchRecord,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'operator_kill_switch.dart' show OperatorKillResumeDraft;
import 'operator_migration.dart' show OperatorMigrationActions, kX1ActionIds;
import 'operator_repair.dart' show OperatorRepairActions;
import 'operator_rule_change.dart' show operatorRuleChangeGateSourceOf;
import 'operator_runtime.dart';
import 'operator_view.dart';

/// 🆕 R265(H1-6) — 서약 원장 = 화면 원장(화면 상태 없음 = 모의 파일).
Database _pledgeDb(OperatorRuntime rt) => rt.view.value?.db ?? rt.files.sim;

SqlitePledgeStore _store(OperatorRuntime rt, [Database? db]) =>
    SqlitePledgeStore(
      db ?? _pledgeDb(rt),
      clock: rt.clock,
      trusted: rt.trusted,
    );

/// 서약 읽기(operator) — `pledge` 표가 바뀔 때마다 · 🆕 R265 화면 원장이 바뀔 때마다(실전 전환) 다시 낸다.
class OperatorPledgeRepository implements PledgeRepository {
  /// 만든다.
  OperatorPledgeRepository(this._rt);

  final OperatorRuntime _rt;

  Stream<PledgeVm> _watch(Database db) => watchLedgerQuery<PledgeVm>(
    db,
    const <String>{'pledge'},
    () => pledgeVmOf(
      current: _store(_rt, db).currentPledge(),
      trustedNowUtc: _rt.trusted.trustedNowUtc(),
      nowUtc: _rt.clock.nowUtc(),
    ),
  );

  @override
  Stream<PledgeVm> watchPledge() {
    late final StreamController<PledgeVm> c;
    StreamSubscription<PledgeVm>? sub;
    Database? on;

    void follow() {
      final Database db = _pledgeDb(_rt);
      if (identical(db, on) || c.isClosed) return;
      on = db;
      unawaited(sub?.cancel());
      sub = _watch(db).listen(c.add, onError: c.addError);
    }

    c = StreamController<PledgeVm>(
      onListen: () {
        follow();
        _rt.view.addListener(follow);
      },
      onCancel: () async {
        _rt.view.removeListener(follow);
        await sub?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }
}

/// 안전 동작(operator) — 지금 = 서약 첫 판 · 편집.
class OperatorSafetyActions implements SafetyActions {
  /// 만든다 — [random] = 명령 id 원천(기본 = `Random.secure()`).
  OperatorSafetyActions(
    this._rt, {
    Random? random,
    OperatorKillResumeDraft? draft,
  }) : _random = random ?? Random.secure(),
       draft = draft ?? OperatorKillResumeDraft() {
    _x1 = OperatorMigrationActions(_rt, _random);
  }

  /// 🆕 E16j-b — X1 기기 이전 동작 6(`run` 화이트리스트 · K273).
  late final OperatorMigrationActions _x1;

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

  /// 🆕 리뷰 3차 H1-3(R261) — 받아들여진(사유 코드 없음 · «다시 시도» 아님) 안전 동작 뒤 엔진 깨어남 한 번(기다리지 않는다) ·
  /// 거부 · 다시 시도(바뀐 것 없음) = 0.
  SafetyActionResult _woke(SafetyActionResult r) {
    if (r.reasonCode == null && !r.retryable) unawaited(_rt.wakeNow());
    return r;
  }

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

  /// 🆕 E11q-c0(R188) — `run` = 규칙 변경 취소(`ruleChangeCancel{request_id}` — 행의 `cancel` 그대로) · 🆕 E11q-b2b(R195) 계절
  /// 3택(`seasonalWindowChoice{work_id, choice}` — 게이트 행의 동작 그대로)만 연다 · 그 밖 id = 그대로 구현 전(오류 — 지어내지
  /// 않는다) · 🆕 R189 `reconClear` = 화이트리스트 밖(계약 K181) → ArgumentError(`runReconClear` 로).
  @override
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  }) async {
    if (id == SafetyActionId.reconClear) {
      throw ArgumentError.value(id, 'id', 'RECON 해제 = runReconClear(K181)');
    }
    // 🆕 E16j-b — X1 id 6 = 기기 이전 동작(결과 글자 = 엔진 · 막힌 동작 = 오류).
    if (kX1ActionIds.contains(id)) {
      final SafetyActionResult r = await _x1.run(id, args);
      return _done[r.actionRunId] = _woke(r);
    }
    if (id == SafetyActionId.seasonalWindowChoice) return _seasonalChoice(args);
    // 🆕 E16j-a(R227) — 개입 단계 · 아무것도 안 하기 = 엔진이 완성한 args 그대로(명령 id = 킬스위치 명령과 같은 꼴).
    if (id == SafetyActionId.interventionStep ||
        id == SafetyActionId.repairAccept) {
      final ({String commandId, String nonce, String payloadDigest}) c =
          issueKillCommand(payload: args, random: _random);
      final OperatorRepairActions repair = OperatorRepairActions(_rt);
      return _done[c.commandId] = _woke(
        id == SafetyActionId.interventionStep
            ? repair.step(c.commandId, c.payloadDigest, args)
            : repair.accept(c.commandId, args),
      );
    }
    if (id != SafetyActionId.ruleChangeCancel) return _none('run(${id.wire})');
    final String? requestId = args['request_id'];
    if (requestId == null || requestId.trim().isEmpty) {
      throw ArgumentError.value(args, 'args', 'request_id 없음');
    }
    final (OperatorView v, String run, String digest) = _safetyCommand(args);
    final RuleChangeResult r = _ruleChangeStore(v)
        .cancel(commandId: run, payloadDigest: digest, requestId: requestId);
    return _ruleChangeDone(SafetyActionId.ruleChangeCancel, run, r);
  }

  /// 🆕 E11q-b2b(R195 · K54) — 계절 A 진입 3택: 엔진 `SqliteSeasonalChoice.apply`(재개 실행기와 같은 판정 · 같은 원장 · 결정 id =
  /// 구현 `SEA-<명령 id>`) · 오늘 = 기기 시각의 한국 날짜(재개 실행기 선례) · 생체 = 구현 0(미결 169) · 결과 글자 = 엔진.
  Future<SafetyActionResult> _seasonalChoice(Map<String, String> args) async {
    final String? workId = args['work_id'];
    final SeasonalEntryChoice? choice = SeasonalEntryChoice.values
        .where((SeasonalEntryChoice c) => c.wire == args['choice'])
        .firstOrNull;
    if (workId == null || workId.trim().isEmpty || choice == null) {
      throw ArgumentError.value(args, 'args', 'work_id · choice 필요');
    }
    final (OperatorView v, String run, String _) = _safetyCommand(args);
    final String? code =
        await SqliteSeasonalChoice(
          v.db,
          runMode: v.flags.runMode,
          operatingMode: v.flags.operatingMode,
          clock: _rt.clock,
          ledger: SqliteOrderLedger(
            v.db,
            mode: v.flags.runMode,
            clock: _rt.clock,
            kr: _rt.calendars.kr,
          ),
        ).apply(
          workId: workId,
          choice: SeasonalWindowChoice.values.byName(choice.name),
          decisionId: 'SEA-$run',
          today: TradeDate(kstDateText(_rt.clock.nowUtc())),
        );
    return _done[run] = seasonalChoiceResultOf(actionRunId: run, code: code);
  }

  /// 안전 명령 봉투(명령 id · 페이로드 요약 — 킬스위치 명령과 같은 꼴) · 화면 상태 없음 = 오류.
  (OperatorView, String, String) _safetyCommand(Map<String, Object?> payload) {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('규칙 변경: 화면 상태 없음(온보딩 전)');
    final ({String commandId, String nonce, String payloadDigest}) c =
        issueKillCommand(payload: payload, random: _random);
    return (v, c.commandId, c.payloadDigest);
  }

  SqliteRuleChangeStore _ruleChangeStore(OperatorView v) =>
      SqliteRuleChangeStore(v.db, clock: _rt.clock, trusted: _rt.trusted);

  SafetyActionResult _ruleChangeDone(
    SafetyActionId id,
    String run,
    RuleChangeResult r,
  ) => _done[run] = ruleChangeActionResultOf(
    id: id,
    actionRunId: run,
    code: r.executed ? null : r.reasonCode,
  );

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
      // 🆕 R261 — 재개(해제) = 상태 전이 → 깨어남 한 번(FGS BLOCKED → 그 뒤 상태).
      unawaited(_rt.wakeNow());
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

  /// 🆕 E16j-a(R227 · 01 §41 K255 · 미결 217 ⓐⓒⓓ) — X5 정본 정정: 원문 파싱(엔진) → 대상의 열린 세션 → 직전 재대사 → 정정 커밋(5단계).
  @override
  Future<SafetyActionResult> runRepairCorrect(
    RepairCorrectSubmission submission,
  ) async {
    final ({String commandId, String nonce, String payloadDigest}) c =
        issueKillCommand(payload: submission.toJson(), random: _random);
    return _done[c.commandId] = _woke(
      await OperatorRepairActions(_rt).correct(c.commandId, submission),
    );
  }

  /// 🆕 E16j-a(R227 · 01 §41 K256 · 미결 217 ⓐ) — X5 새 기준점(무결성 갈래 · 5단계 커밋).
  @override
  Future<SafetyActionResult> runRepairBaseline(
    RepairBaselineSubmission submission,
  ) async {
    final ({String commandId, String nonce, String payloadDigest}) c =
        issueKillCommand(payload: submission.toJson(), random: _random);
    return _done[c.commandId] = _woke(
      OperatorRepairActions(_rt).baseline(c.commandId, submission),
    );
  }

  /// 🆕 E16j-a(R227 · 01 §41 K252 · 미결 217 ⓖ) — 개입 3단계 사전 저널(살아 있는 세션 · 저널 + 단계 한 트랜잭션).
  @override
  Future<SafetyActionResult> runInterventionJournal(
    InterventionJournalSubmission submission,
  ) async {
    final ({String commandId, String nonce, String payloadDigest}) c =
        issueKillCommand(payload: submission.toJson(), random: _random);
    return _done[c.commandId] = _woke(
      OperatorRepairActions(_rt)
          .journal(c.commandId, c.payloadDigest, submission),
    );
  }

  /// 🆕 E11q-c0(R188) — 규칙 변경 승인(v1.22 꼴 · 판정 = 엔진 `approve` — 냉각 30일 · 창 · DD · 신뢰 시각 · 사람 칸 · 제3자) ·
  /// 생체 = 구현 0(서약 · 재개판 선례 · 운영 등급 공통 관문 = 미결 169) · 결과 글자 = 엔진.
  @override
  Future<SafetyActionResult> runRuleChangeApproval(
    RuleChangeApprovalSubmission submission,
  ) async {
    final (OperatorView v, String run, String digest) = _safetyCommand(
      submission.toJson(),
    );
    final RuleChangeResult r = _ruleChangeStore(v).approve(
      commandId: run,
      payloadDigest: digest,
      requestId: submission.requestId,
      goldenChanged: submission.goldenChanged,
      approver: submission.approver,
      thirdPartyNotified: submission.thirdPartyNotified,
    );
    return _ruleChangeDone(SafetyActionId.ruleChangeApprove, run, r);
  }

  @override
  Future<SafetyActionResult> runDiscretionAdjust(
    DiscretionAdjustSubmission submission,
  ) => _none('runDiscretionAdjust');

  /// 🆕 E11q-c0(R188 · 01 §35 K178 · K180) — 규칙 변경 요청(첫 승인) — ① 후보를 같은 원천으로 다시 셈해 제출 `candidateId` 와
  /// 맞춰 본다(다르면 `RULE_CHANGE_BASE_STALE` — 유형 · 해시는 엔진 후보에서만) ② 엔진 «저널 함께 쓰기» 판(요청 + 사전 저널 한
  /// 트랜잭션 · 저널 id = `JRC-<명령 id>`) · 신뢰 시각 모름 = 엔진 `TRUSTED_TIME_UNKNOWN` 원문(우회 0 · K176) · 결과 글자 = 엔진.
  @override
  Future<SafetyActionResult> runRuleChangeRequest(
    RuleChangeRequestSubmission submission,
  ) async {
    final (OperatorView v, String run, String digest) = _safetyCommand(
      submission.toJson(),
    );
    final RuleChangeCandidate? cand = operatorRuleChangeGateSourceOf(
      _rt,
      v,
    ).candidate();
    if (cand == null || cand.candidateId != submission.candidateId) {
      return _done[run] = ruleChangeActionResultOf(
        id: SafetyActionId.ruleChangeRequest,
        actionRunId: run,
        code: RuleChangeCodes.baseStale,
      );
    }
    final RuleChangeResult r = _ruleChangeStore(v).requestWithJournal(
      commandId: run,
      payloadDigest: digest,
      changeType: cand.changeType,
      hashBefore: cand.hashBefore,
      hashAfter: cand.hashAfter,
      reason: submission.reason,
      rollbackMethod: submission.rollbackMethod,
      journalId: 'JRC-$run',
      rationaleBefore: submission.rationaleBefore,
      expectedOutcome: submission.expectedOutcome,
      ruleCited: submission.ruleCited,
    );
    return _ruleChangeDone(SafetyActionId.ruleChangeRequest, run, r);
  }

  /// 🆕 E11q-c4(R189 · 01 §35 K180~K182 · 미결 206 RECON 몫) — RECON 해제: 엔진 «저널 함께 쓰기» 판(사전 저널 `RECON_CLEAR` + 해제 +
  /// 명령 행 한 트랜잭션 · 저널 id = `JRCL-<명령 id>` · 판정 = 엔진 — 막힘 없음 · 선택지 밖 원인 코드 · 저널 세 칸 · id 겹침) ·
  /// `clearedBy` = 기기 별칭 «운영 폰»(R178 발동 선례 · 기기 id 원문 0) · 신뢰 시각 비의존(시각 = 기기 시계) · 생체 = 구현 0(미결 169) ·
  /// 원장 = 화면 상태의 원장(보드가 읽는 파일) · 결과 글자 = 엔진(`reconClearActionResultOf`).
  @override
  Future<SafetyActionResult> runReconClear(
    ReconClearSubmission submission,
  ) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('RECON 해제: 화면 상태 없음(온보딩 전)');
    final ({String commandId, String nonce, String payloadDigest}) c =
        issueKillCommand(payload: submission.toJson(), random: _random);
    final String run = c.commandId;
    final ReconClearWriteResult r =
        SqliteOrderLedger(
          v.db,
          mode: v.flags.runMode,
          clock: _rt.clock,
          kr: _rt.calendars.kr,
        ).clearReconWithJournal(
          commandId: run,
          payloadDigest: c.payloadDigest,
          originCode: submission.originCode,
          journalId: 'JRCL-$run',
          clearedBy: KillSwitchScreenTexts.operatorPhone,
          rationaleBefore: submission.rationaleBefore,
          expectedOutcome: submission.expectedOutcome,
          ruleCited: submission.ruleCited,
        );
    if (!r.executed && r.reasonCode == null) {
      throw StateError('RECON 해제: 엔진이 사유 없이 거부했다');
    }
    // 🆕 R261 — 해제 = 차단 플래그 전이 → 깨어남 한 번(FGS ACT → 그 뒤 상태).
    if (r.executed) unawaited(_rt.wakeNow());
    return _done[run] = reconClearActionResultOf(
      actionRunId: run,
      code: r.executed ? null : r.reasonCode,
    );
  }
}
