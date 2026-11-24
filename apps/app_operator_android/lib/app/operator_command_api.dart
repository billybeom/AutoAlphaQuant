// 명령 API operator 판 — 첫 칸 = 알림 수신 확인(E11p3d-4a · 설계 13 §8 R147 · 01 §24 K12 · 앱 04 §5-4 ① · 엔진 R68 H4).
//
// 🔴 맥락(`CommandContext`)은 화면이 아니라 여기서 싣는다(G-19) — 발행 시점 실행 모드 · 운영 방식 · 리스 세대 · 이 기기 id(R142).
// 🔴 실행 = 엔진 `SqliteAlertSink.acknowledge`(같은 원장 · 한 트랜잭션 · `command_inbox` 기록) · 접수증 글자 = 엔진이 남긴
//    `command_inbox.state_label` 그대로(앱이 상태로 문장을 짓지 않는다).
// 🔴 알림 단위 멱등 = 엔진(두 번째 확인 = 효과 0 · executed) · 모르는 id · 사다리 없는 알림 = rejected `INPUT_INVALID`.
// 🔴 이 구현은 알림 화면 주입(`shellAlertCommandApiProvider`)에만 쓴다 — 나머지 명령 = operator 구현 전(오류 · 다른 화면에 주입하지 않는다).
// 🆕 E11p4f(R155) — 둘째 칸 = 모의 개시 가상 초기금(`submitSelfReportBalance(simOpening)` · 01 §21-3 · 06 M5-14 · X6-5 ⓑ):
//    원문 검사(엔진 `simOpeningWireOf` — 틀리면 큐 적재 없이 `INPUT_INVALID`) → 지금 설정 판 등재(발주자 결정 사람 값 ·
//    R153 · R154) → 엔진 `declareSimOpening`(sim 파일 · 한 트랜잭션) · 접수증 글자 = 엔진 문구 그대로.
//    🆕 R156 화면 주입 = M5-14(`safetySimOpeningCommandApiProvider`).
// 🆕 E11q-q6 — 셋째 칸 = 정기 실사(`submitSelfReportBalance(periodicAudit)` · `L-3` · 01 §21-3 · §21-4): 세션(이 폰) →
//    엔진 원문 검사(`INPUT_INVALID` 칸 글자 · 세션 밖 `SELF_REPORT_OUTSIDE_SESSION`) → 신뢰 시각 · 리스 · 무결성(보관) →
//    원장 한 트랜잭션(실사 · 줄 · `ledger_diff` CANON_SELF_REPORT · `command_inbox`) · 접수증 글자 = 엔진.
// 🔴 기기 id 가 없으면 주입 자체를 하지 않는다(버튼 부재 — 셸 규약) · 화면 상태 없음(온보딩 전) = 오류.
// 🆕 리뷰 3차 H1(설계 13 §8 R261 · 01 §8 미결 235) — 상태 전이를 낸 명령(킬스위치 발동 · 기록 확인 · 알림 확인 · 모의 개시) 뒤 엔진 깨어남
//    한 번(`OperatorRuntime.wakeNow` · 기다리지 않는다) — FGS · 화면 상태가 다음 알람까지 옛 상태로 남지 않게.

import 'dart:async';
import 'dart:math';

import 'package:broker_gateway/broker_gateway.dart' show KisKeySet;
import 'package:core_engine/core_engine.dart'
    show
        AlertAckCommand,
        DisclosureViewCommand,
        P0sOpsConfig,
        SimOpeningCodes,
        SimOpeningCommand,
        SimOpeningInputInvalid,
        SimOpeningWireReady,
        SimOpeningWireResult,
        KillAckAnswers,
        KillActivationAnswers,
        JournalDraftCommand,
        KillSwitchScreenTexts,
        OrderBroker,
        depositTradeDate,
        depositTrustedTimeUnknownReceipt,
        issueDepositRegister,
        issueJournalDraft,
        issueKillCommand,
        killChecklistAnswersOf,
        killCommandReceiptOf,
        simOpeningWireOf;
import 'package:data_sync/data_sync.dart'
    show
        AlertAckResult,
        OnboardingChoice,
        OnboardingOutcome,
        P0sHumanDecision,
        SqliteAlertSink,
        SqliteConfigVersionStore,
        KillCommandResult,
        JournalDraftWriteResult,
        SqliteDepositRegistrar,
        SqliteJournalDraftStore,
        SqliteKillSwitchStore,
        SqliteLeaseGate,
        SqliteOnboardingStore,
        SqlitePerformanceSource,
        SqliteWhatIfStateSource,
        onboardingRejected;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart' show Database, ResultSet;

import 'operator_ops_summary.dart' show operatorRebalanceSourceOf;
import 'operator_runtime.dart';
import 'operator_self_report.dart' show OperatorSelfReport;
import 'operator_view.dart';

/// 명령 API(operator) — 지금 = 알림 수신 확인 · 모의 개시 가상 초기금.
class OperatorCommandApi implements CommandApi {
  /// 만든다 — [random] = 명령 id · nonce 원천(기본 = `Random.secure()`).
  OperatorCommandApi(this._rt, {Random? random, this.selfReport})
    : _random = random ?? Random.secure();

  final OperatorRuntime _rt;
  final Random _random;

  /// 🆕 E11q-q6 — `L-3` 정기 실사(없음 = 정기 실사 구현 없음 · 오류).
  final OperatorSelfReport? selfReport;

  /// 이 인스턴스가 낸 명령의 접수증(명령 id → 접수증).
  final Map<String, CommandReceipt> _issued = <String, CommandReceipt>{};

  static Future<CommandReceipt> _none(String what) =>
      Future<CommandReceipt>.error(
        UnsupportedError('$what: operator 구현 없음(R147)'),
      );

  @override
  Future<CommandReceipt> acknowledgeAlert(String alertId) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) {
      throw StateError('알림 확인: 화면 상태 없음(온보딩 전)');
    }
    final String? deviceId = _rt.deviceId;
    if (deviceId == null) {
      throw StateError('알림 확인: 기기 id 없음');
    }
    final AlertAckCommand c = AlertAckCommand.issue(
      alertId: alertId,
      context: CommandContext(
        runMode: v.flags.runMode,
        operatingMode: v.flags.operatingMode,
        leaseEpoch: SqliteLeaseGate(
          v.db,
          mode: v.flags.runMode,
          clock: _rt.clock,
        ).epoch(),
        deviceId: deviceId,
      ),
      nowUtc: _rt.clock.nowUtc(),
      random: _random,
    );
    final AlertAckResult r = SqliteAlertSink(v.db, clock: _rt.clock)
        .acknowledge(
          commandId: c.commandId,
          payloadDigest: c.payloadDigest,
          alertId: alertId,
        );
    final ResultSet rs = v.db.select(
      'SELECT state_label FROM command_inbox WHERE command_id = ?',
      <Object?>[c.commandId],
    );
    if (rs.isEmpty) {
      throw StateError('알림 확인: 엔진 기록 없음');
    }
    final CommandReceipt receipt = c.receipt(
      executed: r.executed,
      stateLabel: rs.first['state_label'] as String,
      rejectReasonCode: r.reasonCode,
    );
    _issued[c.commandId] = receipt;
    // 🆕 리뷰 3차 H1-3(R261) — 확인 = FGS 의 열린 P0 줄이 바뀌는 전이 → 깨어남 한 번(기다리지 않는다).
    _wakeIf(r.executed);
    return receipt;
  }

  /// 🆕 리뷰 3차 H1(R261 · 미결 235) — 상태를 바꾼 명령 뒤 엔진 깨어남 한 번(화면 상태 · FGS — 다음 알람까지 옛 상태로 두지 않는다 ·
  /// 기다리지 않는다 · 거부 = 전이 아님 → 0).
  void _wakeIf(bool changed) {
    if (changed) unawaited(_rt.wakeNow());
  }

  /// 이 인스턴스가 낸 명령만 — 폰 안에서 바로 끝나므로 마지막 상태 하나(모르는 id = 오류).
  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    final CommandReceipt? r = _issued[commandId];
    return r == null
        ? Stream<CommandReceipt>.error(
            StateError('명령 $commandId: 이 기기에서 낸 명령이 아님'),
          )
        : Stream<CommandReceipt>.value(r);
  }

  // 🆕 계약 v1.25(01 §34 · K149 · K165) — 인자 0(기기·채널 = 이 구현 · 사유 = 발동 뒤 기록) · 행동 = 조립 레인(E11q-b1).
  @override
  Future<CommandReceipt> activateKillSwitch() async {
    // 🆕 E11q-b1a(R178) — 이 폰 로컬 단락(R57 B7): 차단이 먼저(엔진 `activateKillSwitch` — 이미 켜져 있으면 첫 발동 시각 유지) ·
    //    미체결 취소 = 취소 경로를 넘기지 않는다(모의 가상 취소는 원장에 남지 않는다 → 엔진이 `NO_BROKER` 로 «그대로 남습니다» 보고 ·
    //    실계좌 취소 경로 = 트랙 C) · 채널 = app · 접수증 글자 = 엔진. 확인 대화 · 인자 0(K149).
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('킬스위치 발동: 화면 상태 없음(온보딩 전)');
    final String? deviceId = _rt.deviceId;
    if (deviceId == null) throw StateError('킬스위치 발동: 기기 id 없음');
    final ({String commandId, String nonce, String payloadDigest}) c =
        issueKillCommand(payload: const <String, Object?>{}, random: _random);
    final KillCommandResult r =
        await SqliteKillSwitchStore(
          v.db,
          clock: _rt.clock,
          trusted: _rt.trusted,
        ).activateLocal(
          commandId: c.commandId,
          payloadDigest: c.payloadDigest,
          brokers: const <String, OrderBroker>{},
          channel: 'app', // 원장 채널 규약(`kill_switch_event.channel` — app · viewer · web · messenger · file)
          deviceLabel: KillSwitchScreenTexts.operatorPhone,
        );
    final CommandReceipt receipt = killCommandReceiptOf(
      kind: CommandKind.killSwitchActivate,
      commandId: c.commandId,
      nonce: c.nonce,
      requestedAtUtc: _rt.clock.nowUtc(),
      deviceId: deviceId,
      executed: r.executed,
      reasonCode: r.reasonCode,
    );
    _issued[receipt.commandId] = receipt;
    // 🆕 리뷰 3차 H1-3(R261) — 발동 = 상태 전이(04 §5-6 «갱신 = 상태 전이 시») → FGS BLOCKED 를 다음 알람까지 미루지 않는다.
    _wakeIf(r.executed);
    return receipt;
  }

  /// 🆕 미결 220 ⓔ — `J-3` 사전 저널(키 = 저널 id · 갈래 · 판정 · 보관 · 멱등 = 엔진 `SqliteJournalDraftStore` · 화면 상태의 원장 ·
  /// 시각 = 기기 시계 — 신뢰 시각 비의존 K299 · 접수증 글자 = 엔진).
  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('사전 저널: 화면 상태 없음(온보딩 전)');
    final String? deviceId = _rt.deviceId;
    if (deviceId == null) throw StateError('사전 저널: 기기 id 없음');
    final JournalDraftCommand c = issueJournalDraft(
      draft: draft,
      nowUtc: _rt.clock.nowUtc(),
      deviceId: deviceId,
      random: _random,
    );
    final JournalDraftWriteResult r =
        SqliteJournalDraftStore(v.db, clock: _rt.clock).submit(
          commandId: c.commandId,
          payloadDigest: c.payloadDigest,
          draft: draft,
          runMode: v.flags.runMode,
          operatingMode: v.flags.operatingMode,
          leaseEpoch: SqliteLeaseGate(
            v.db,
            mode: v.flags.runMode,
            clock: _rt.clock,
          ).epoch(),
        );
    final CommandReceipt receipt = c.receipt(
      state: r.state,
      stateLabel: r.stateLabel,
      rejectReasonCode: r.rejectCode,
    );
    _issued[c.commandId] = receipt;
    return receipt;
  }

  /// 🆕 E11q-j4 — `J-4` 점수 제출 = 점수 기록 표가 로컬 원장(02 데이터모델 v1)에 없다 → 기록하지 않는다(계약 창 대기 ·
  /// 판정 · 접수증 글자 = 엔진 `blindReviewRejectOf` · `blindReviewStateLabelOf` 준비됨) · 화면 = 접수 실패 1줄(01 §16-6).
  @override
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score) =>
      Future<CommandReceipt>.error(
        UnsupportedError('submitBlindReviewScore: 점수 기록 표 없음(계약 창 대기)'),
      );

  /// 🆕 E11q-q5b(R223) — `S7-2G` 「그래도 보기」 열람 기록(폰 안 · 같은 원장 한 행 · 무결성 점검 중 = 보류 행) ·
  /// 접수증 글자 = 엔진 글자 그대로 · 화면 상태 · 기기 id 가 없으면 실패(게이트에 머문다 · 접수 실패 1줄).
  @override
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('열람 기록: 화면 상태 없음(온보딩 전)');
    final String? deviceId = _rt.deviceId;
    if (deviceId == null) throw StateError('열람 기록: 기기 id 없음');
    final DisclosureViewCommand c = DisclosureViewCommand.issue(
      event: event,
      deviceId: deviceId,
      nowUtc: _rt.clock.nowUtc(),
      random: _random,
    );
    final CommandReceipt receipt =
        SqlitePerformanceSource(v.db, clock: _rt.clock).record(
          c,
          runMode: v.flags.runMode,
          operatingMode: v.flags.operatingMode,
          leaseEpoch: SqliteLeaseGate(
            v.db,
            mode: v.flags.runMode,
            clock: _rt.clock,
          ).epoch(),
        );
    _issued[receipt.commandId] = receipt;
    return receipt;
  }

  /// 🆕 E11q3(R174) — 실입금 등록(폰 전용 · 01 §14-2) — 만료 판정 시각 = **신뢰 시각**(명령 서버 시각 자리 · R22 D9).
  /// 모르면 등록하지 않는다: 원장 · 바인딩 · 감사 쓰기 0 · 엔진 거부 접수증 `TRUSTED_TIME_UNKNOWN`(기기 시계로 대신하지 않는다) ·
  /// 알면 엔진 기록기 `SqliteDepositRegistrar`(한 트랜잭션 · 판정 = `judgeDepositRegistration` · 상태 = 리밸런싱과 같은 원장 어댑터).
  @override
  Future<CommandReceipt> registerDeposit(
    DepositRegistration registration,
  ) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('실입금 등록: 화면 상태 없음(온보딩 전)');
    final String? deviceId = _rt.deviceId;
    if (deviceId == null) throw StateError('실입금 등록: 기기 id 없음');
    final DateTime? trusted = _rt.trusted.trustedNowUtc();
    final CommandReceipt receipt = trusted == null
        ? depositTrustedTimeUnknownReceipt(
            issueDepositRegister(
              planId: registration.planId,
              requestedAtUtc: _rt.clock.nowUtc(),
              deviceId: deviceId,
              random: _random,
            ),
          )
        : await SqliteDepositRegistrar(
            v.db,
            mode: v.flags.runMode,
            state: SqliteWhatIfStateSource(
              operatorRebalanceSourceOf(_rt, v, (String _) => false),
            ),
            clock: _rt.clock,
          ).register(
            issueDepositRegister(
              planId: registration.planId,
              requestedAtUtc: trusted,
              deviceId: deviceId,
              random: _random,
            ),
          );
    _issued[receipt.commandId] = receipt;
    return receipt;
  }

  @override
  Future<CommandReceipt> recordManualFill(ManualFillSubmission submission) =>
      _none('recordManualFill');

  @override
  Future<CommandReceipt> amendManualFill(ManualFillAmendment amendment) =>
      _none('amendManualFill');

  @override
  Future<CommandReceipt> voidManualFill(ManualFillVoid v) =>
      _none('voidManualFill');

  @override
  Future<CommandReceipt> skipAdvice(AdviceSkipSubmission submission) =>
      _none('skipAdvice');

  /// 🆕 R155 — 모의 개시 가상 초기금(자동 매매 갈래) · 🆕 E11q-q6 정기 실사(`periodicAudit` · `L-3` — [selfReport]).
  @override
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  ) async {
    if (submission.purpose != SelfReportPurpose.simOpening) {
      final OperatorSelfReport? sr = selfReport;
      if (sr == null) return _none('submitSelfReportBalance(정기 실사)');
      final CommandReceipt r = sr.submit(submission, random: _random);
      _issued[r.commandId] = r;
      return r;
    }
    final String? deviceId = _rt.deviceId;
    if (deviceId == null) {
      throw StateError('모의 개시: 기기 id 없음');
    }
    final Database db = _rt.files.sim;
    final DateTime now = _rt.clock.nowUtc();
    final SimOpeningCommand c = SimOpeningCommand.issue(
      deviceId: deviceId,
      nowUtc: now,
      random: _random,
    );
    CommandReceipt done(CommandReceipt r) => _issued[c.commandId] = r;
    CommandReceipt outcome(OnboardingOutcome o) => done(
      c.receipt(
        executed: o.ok,
        stateLabel: o.headline,
        rejectReasonCode: o.reasonCode,
      ),
    );
    final SqliteOnboardingStore store = SqliteOnboardingStore(
      db,
      clock: _rt.clock,
    );
    final OnboardingChoice? choice = store.choice();
    if (choice == null) {
      return outcome(onboardingRejected(SimOpeningCodes.choiceMissing));
    }
    final SimOpeningWireResult w = simOpeningWireOf(
      submission,
      asOfTradeDate: depositTradeDate(now, _rt.calendars.kr),
      sessionStartedAt: now,
      accountAlias: KisKeySet.paper.wire,
      context: CommandContext(
        runMode: RunMode.simInternal,
        operatingMode: choice.operatingMode,
        leaseEpoch: SqliteLeaseGate(
          db,
          mode: RunMode.simInternal,
          clock: _rt.clock,
        ).epoch(),
        deviceId: deviceId,
      ),
    );
    final SelfReportBalance wire;
    switch (w) {
      case SimOpeningInputInvalid():
        return done(c.inputInvalid(w.stateLabel));
      case SimOpeningWireReady():
        wire = w.wire;
    }
    final P0sHumanDecision? human = _rt.humanDecision;
    if (human == null) {
      return outcome(onboardingRejected(SimOpeningCodes.accountUnmapped));
    }
    final String configHash = SqliteConfigVersionStore(
      db,
      clock: _rt.clock,
    ).register(P0sOpsConfig.of(human.inputs).content());
    final OnboardingOutcome declared = store.declareSimOpening(
      wire,
      accountByStrategy: human.inputs.accountByStrategy,
      configHash: configHash,
    );
    // 🆕 리뷰 3차 B-U1(R261 · 미결 235 ⓕ) — 개시 판 = 지금 설정 지문(셸 플래그 · M5-9 후보) → 깨어남 한 번(빈 글자로 두지 않는다).
    _wakeIf(declared.ok);
    return outcome(declared);
  }

  @override
  Future<CommandReceipt> confirmKillChecklist(
    KillChecklistSubmission submission,
  ) async {
    // 🆕 E11q-b1a(R178) — 발동 뒤 기록(48h 기준의 유일한 방아쇠) — 원문 → 엔진 답(파싱 실패 · 빈 선택 = 큐 적재 없는
    //    `KILL_CHECKLIST_ITEM_MISSING`) → 엔진 `confirmChecklist`(신뢰 시각 · 켜짐 · 판정 · 새 저널 · 한 트랜잭션 — 신뢰 시각을
    //    모르면 `TRUSTED_TIME_UNKNOWN` · 기기 시계로 대신하지 않는다) · 접수증 글자 = 엔진.
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('킬스위치 기록: 화면 상태 없음(온보딩 전)');
    final String? deviceId = _rt.deviceId;
    if (deviceId == null) throw StateError('킬스위치 기록: 기기 id 없음');
    final ({String commandId, String nonce, String payloadDigest}) c =
        issueKillCommand(payload: submission.toJson(), random: _random);
    final (KillActivationAnswers, KillAckAnswers)? parsed =
        killChecklistAnswersOf(
          submission,
          journalDecisionId: 'KS-CHK-${c.commandId}',
        );
    final KillCommandResult? r = parsed == null
        ? null
        : SqliteKillSwitchStore(
            v.db,
            clock: _rt.clock,
            trusted: _rt.trusted,
          ).confirmChecklist(
            commandId: c.commandId,
            payloadDigest: c.payloadDigest,
            answers: parsed.$1,
            ack: parsed.$2,
          );
    final CommandReceipt receipt = killCommandReceiptOf(
      kind: CommandKind.killChecklistConfirm,
      commandId: c.commandId,
      nonce: c.nonce,
      requestedAtUtc: _rt.clock.nowUtc(),
      deviceId: deviceId,
      executed: r?.executed ?? false,
      reasonCode: r == null ? 'KILL_CHECKLIST_ITEM_MISSING' : r.reasonCode,
    );
    _issued[receipt.commandId] = receipt;
    // 🆕 리뷰 3차 H1-3(R261) — 기록 확인 = 킬스위치 상태 문장(해제 예정)이 바뀌는 전이 → 깨어남 한 번.
    // 🔵 B-03(`r.p0` — 확인 3 ≠ 엔진 미체결 → P0 경보) = 알림 코드 · 등급 행이 계약에 없다 → 계약 창 대기(R261 · 엔진 지역 상수 0).
    _wakeIf(r?.executed ?? false);
    return receipt;
  }

  @override
  Future<CommandReceipt> recordLedgerEvent(LedgerEventRecord record) =>
      _none('recordLedgerEvent');

  @override
  Future<CommandReceipt> deferAdviceConfirm(String adviceId) =>
      _none('deferAdviceConfirm');
}
