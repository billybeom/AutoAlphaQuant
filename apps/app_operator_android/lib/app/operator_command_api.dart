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
//    정기 실사(`periodicAudit` · L-3) = 구현 전(오류) · 🆕 R156 화면 주입 = M5-14(`safetySimOpeningCommandApiProvider`).
// 🔴 기기 id 가 없으면 주입 자체를 하지 않는다(버튼 부재 — 셸 규약) · 화면 상태 없음(온보딩 전) = 오류.

import 'dart:math';

import 'package:broker_gateway/broker_gateway.dart' show KisKeySet;
import 'package:core_engine/core_engine.dart'
    show
        AlertAckCommand,
        P0sOpsConfig,
        SimOpeningCodes,
        SimOpeningCommand,
        SimOpeningInputInvalid,
        SimOpeningWireReady,
        SimOpeningWireResult,
        depositTradeDate,
        depositTrustedTimeUnknownReceipt,
        issueDepositRegister,
        simOpeningWireOf;
import 'package:data_sync/data_sync.dart'
    show
        AlertAckResult,
        OnboardingChoice,
        OnboardingOutcome,
        P0sHumanDecision,
        SqliteAlertSink,
        SqliteConfigVersionStore,
        SqliteDepositRegistrar,
        SqliteLeaseGate,
        SqliteOnboardingStore,
        SqliteWhatIfStateSource,
        onboardingRejected;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart' show Database, ResultSet;

import 'operator_ops_summary.dart' show operatorRebalanceSourceOf;
import 'operator_runtime.dart';
import 'operator_view.dart';

/// 명령 API(operator) — 지금 = 알림 수신 확인 · 모의 개시 가상 초기금.
class OperatorCommandApi implements CommandApi {
  /// 만든다 — [random] = 명령 id · nonce 원천(기본 = `Random.secure()`).
  OperatorCommandApi(this._rt, {Random? random})
    : _random = random ?? Random.secure();

  final OperatorRuntime _rt;
  final Random _random;

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
    return receipt;
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
  Future<CommandReceipt> activateKillSwitch() => _none('activateKillSwitch');

  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) =>
      _none('submitJournalDraft');

  @override
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score) =>
      _none('submitBlindReviewScore');

  @override
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event) =>
      _none('recordDisclosureView');

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

  /// 🆕 R155 — 모의 개시 가상 초기금(자동 매매 갈래) · 정기 실사 = 구현 전.
  @override
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  ) async {
    if (submission.purpose != SelfReportPurpose.simOpening) {
      return _none('submitSelfReportBalance(정기 실사)');
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
    return outcome(
      store.declareSimOpening(
        wire,
        accountByStrategy: human.inputs.accountByStrategy,
        configHash: configHash,
      ),
    );
  }

  @override
  Future<CommandReceipt> confirmKillChecklist(
    KillChecklistSubmission submission,
  ) => _none('confirmKillChecklist');

  @override
  Future<CommandReceipt> recordLedgerEvent(LedgerEventRecord record) =>
      _none('recordLedgerEvent');

  @override
  Future<CommandReceipt> deferAdviceConfirm(String adviceId) =>
      _none('deferAdviceConfirm');
}
