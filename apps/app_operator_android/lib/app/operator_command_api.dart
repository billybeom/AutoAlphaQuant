// 명령 API operator 판 — 첫 칸 = 알림 수신 확인(E11p3d-4a · 설계 13 §8 R147 · 01 §24 K12 · 앱 04 §5-4 ① · 엔진 R68 H4).
//
// 🔴 맥락(`CommandContext`)은 화면이 아니라 여기서 싣는다(G-19) — 발행 시점 실행 모드 · 운영 방식 · 리스 세대 · 이 기기 id(R142).
// 🔴 실행 = 엔진 `SqliteAlertSink.acknowledge`(같은 원장 · 한 트랜잭션 · `command_inbox` 기록) · 접수증 글자 = 엔진이 남긴
//    `command_inbox.state_label` 그대로(앱이 상태로 문장을 짓지 않는다).
// 🔴 알림 단위 멱등 = 엔진(두 번째 확인 = 효과 0 · executed) · 모르는 id · 사다리 없는 알림 = rejected `INPUT_INVALID`.
// 🔴 이 구현은 알림 화면 주입(`shellAlertCommandApiProvider`)에만 쓴다 — 나머지 명령 = operator 구현 전(오류 · 다른 화면에 주입하지 않는다).
// 🔴 기기 id 가 없으면 주입 자체를 하지 않는다(버튼 부재 — 셸 규약) · 화면 상태 없음(온보딩 전) = 오류.

import 'dart:math';

import 'package:core_engine/core_engine.dart' show AlertAckCommand;
import 'package:data_sync/data_sync.dart'
    show AlertAckResult, SqliteAlertSink, SqliteLeaseGate;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart' show ResultSet;

import 'operator_runtime.dart';
import 'operator_view.dart';

/// 명령 API(operator) — 지금 = 알림 수신 확인만.
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

  @override
  Future<CommandReceipt> activateKillSwitch({
    required String reasonFreeText,
    required String deviceId,
  }) => _none('activateKillSwitch');

  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) =>
      _none('submitJournalDraft');

  @override
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score) =>
      _none('submitBlindReviewScore');

  @override
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event) =>
      _none('recordDisclosureView');

  @override
  Future<CommandReceipt> registerDeposit(DepositRegistration registration) =>
      _none('registerDeposit');

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

  @override
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  ) => _none('submitSelfReportBalance');

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
