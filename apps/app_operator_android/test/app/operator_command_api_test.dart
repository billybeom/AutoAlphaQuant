// E11p3d-4a 명령 API operator 판 — 알림 수신 확인(설계 13 §8 R147) — 실 SQLite(엔진 원장) · 엔진 `SqliteAlertSink`.

import 'dart:math';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show AlertAckCommand, alertInboxOf;
import 'package:data_sync/data_sync.dart' show SqliteAlertSink, storedAlerts;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 22, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  Future<OperatorRuntime> ready({String? deviceId = _dev}) async {
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    final OperatorRuntime rt = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: deviceId,
    );
    rt.view.value = operatorViewOf(
      await bootEngine(files, clock: clock),
      files,
    );
    return rt;
  }

  Future<String> raise(String code) async {
    await SqliteAlertSink(
      files.sim,
      clock: clock,
    ).emit('sim-auto-daily_reconcile', <String>{code});
    return alertInboxOf(
      rows: storedAlerts(files.sim),
      nowUtc: clock.nowUtc(),
    ).firstWhere((AlertItem a) => a.code == code).alertId;
  }

  int acks(String alertId) =>
      files.sim.select(
            'SELECT COUNT(*) AS n FROM alert_ack WHERE alert_id = ?',
            <Object?>[alertId],
          ).first['n']
          as int;

  test('🔴 화면 상태 없음 · 기기 id 없음 = 오류(맥락을 지어내지 않는다)', () async {
    await expectLater(
      OperatorCommandApi(
        OperatorRuntime(files: files, clock: clock, deviceId: _dev),
      ).acknowledgeAlert('x'),
      throwsA(isA<StateError>()),
    );
    final OperatorRuntime noId = await ready(deviceId: null);
    await expectLater(
      OperatorCommandApi(noId).acknowledgeAlert('x'),
      throwsA(isA<StateError>()),
    );
  });

  test('🔴 P0(사다리 있음) 확인 = 엔진 실행 · 접수증 = 엔진 글자 · 발행 기기 · alert_ack 1행 · 지문 = 와이어(맥락 포함)', () async {
    final OperatorRuntime rt = await ready();
    final String id = await raise(AlertCodes.reconMismatch);
    final OperatorCommandApi api = OperatorCommandApi(rt, random: Random(3));
    final CommandReceipt r = await api.acknowledgeAlert(id);
    expect(r.kind, CommandKind.alertAck);
    expect(r.state, CommandState.executed);
    expect(r.stateLabel, '실행됨');
    expect(r.issuedByDeviceId, _dev);
    expect(r.rejectReasonCode, isNull);
    expect(r.requestedAt, clock.nowUtc());
    expect(r.expiresAt, clock.nowUtc().add(const Duration(minutes: 30)));
    expect(acks(id), 1);
    // 지문 = 같은 난수로 다시 만든 봉투(발행 맥락 = 모의 · 자동 · 세대 0 · 이 기기)의 지문.
    final AlertAckCommand again = AlertAckCommand.issue(
      alertId: id,
      context: const CommandContext(
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        leaseEpoch: 0,
        deviceId: _dev,
      ),
      nowUtc: clock.nowUtc(),
      random: Random(3),
    );
    expect(again.commandId, r.commandId);
    expect(
      files.sim
          .select(
            'SELECT payload_digest, kind, state FROM command_inbox WHERE command_id = ?',
            <Object?>[r.commandId],
          )
          .first
          .values,
      <Object?>[again.payloadDigest, 'ALERT_ACK', 'EXECUTED'],
    );
    // 알림 화면이 읽는 원장 = 확인됨.
    expect(
      alertInboxOf(
        rows: storedAlerts(files.sim),
        nowUtc: clock.nowUtc(),
      ).firstWhere((AlertItem a) => a.alertId == id).ack?.acked,
      isTrue,
    );
  });

  test('🔴 같은 알림 두 번 확인 = 거부가 아니라 실행(효과 0 · 새 명령 id) · 모르는 id · 사다리 없는 알림 = 거부 INPUT_INVALID', () async {
    final OperatorRuntime rt = await ready();
    final String id = await raise(AlertCodes.reconMismatch);
    final OperatorCommandApi api = OperatorCommandApi(rt);
    final CommandReceipt first = await api.acknowledgeAlert(id);
    final CommandReceipt second = await api.acknowledgeAlert(id);
    expect(second.state, CommandState.executed);
    expect(second.commandId, isNot(first.commandId));
    expect(acks(id), 1);
    final CommandReceipt unknown = await api.acknowledgeAlert('al_nope');
    expect(
      (unknown.state, unknown.rejectReasonCode, unknown.stateLabel),
      (CommandState.rejected, 'INPUT_INVALID', '거부됨 — INPUT_INVALID'),
    );
    final String p2 = await raise(AlertCodes.contributionChanged);
    final CommandReceipt noLadder = await api.acknowledgeAlert(p2);
    expect(noLadder.state, CommandState.rejected);
    expect(acks(p2), 0);
  });

  test('🔴 접수증 따라보기 = 이 인스턴스가 낸 명령만(마지막 상태 하나) · 모르는 id = 오류', () async {
    final OperatorRuntime rt = await ready();
    final String id = await raise(AlertCodes.reconMismatch);
    final OperatorCommandApi api = OperatorCommandApi(rt);
    final CommandReceipt r = await api.acknowledgeAlert(id);
    expect(await api.watchCommand(r.commandId).toList(), <CommandReceipt>[r]);
    await expectLater(api.watchCommand('nope'), emitsError(isA<StateError>()));
    await expectLater(
      OperatorCommandApi(rt).watchCommand(r.commandId),
      emitsError(isA<StateError>()),
    );
  });

  test('🔴 나머지 명령 = operator 구현 전(오류 — 지어내지 않는다)', () async {
    final OperatorCommandApi api = OperatorCommandApi(await ready());
    await expectLater(
      api.activateKillSwitch(reasonFreeText: 'x', deviceId: _dev),
      throwsA(isA<UnsupportedError>()),
    );
    await expectLater(
      api.deferAdviceConfirm('a'),
      throwsA(isA<UnsupportedError>()),
    );
    await expectLater(
      api.registerDeposit(const DepositRegistration(planId: 'p')),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
