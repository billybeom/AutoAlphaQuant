// E11p3d-4a 명령 API operator 판 — 알림 수신 확인(설계 13 §8 R147) — 실 SQLite(엔진 원장) · 엔진 `SqliteAlertSink`.

import 'dart:math';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        AlertAckCommand,
        P0sHumanInputs,
        P0sOpsConfig,
        SimOpeningCodes,
        alertInboxOf,
        kSimOpeningCashBlank,
        kSimOpeningCashMalformed;
import 'package:data_sync/data_sync.dart'
    show
        OpsConfigReady,
        P0sHumanDecision,
        SqliteAlertSink,
        SqliteOnboardingStore,
        currentP0sOpsConfig,
        storedAlerts;
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
    // 🆕 R178 — 킬스위치 발동 · 기록 = 구현(`operator_kill_switch_test`).
    await expectLater(
      api.deferAdviceConfirm('a'),
      throwsA(isA<UnsupportedError>()),
    );
    // 🆕 R174 — 실입금 등록 = 구현(신뢰 시각 관문 · `operator_contribution_test`).
  });

  group('🆕 R155 모의 개시 가상 초기금(submitSelfReportBalance · simOpening)', () {
    const Map<String, String> accounts = <String, String>{
      'P0S_A': 'isa',
      'P0S_B': 'pension',
      'P0S_C': 'general',
      'P0S_POT': 'isa',
    };
    final P0sHumanDecision human = P0sHumanDecision(
      inputs: P0sHumanInputs(aSymbol: '229200', accountByStrategy: accounts),
      accountLabels: const <String, String>{
        'isa': 'ISA',
        'pension': '연금저축',
        'general': '일반 위탁',
      },
      decisionRef: 'R153',
    );

    OperatorCommandApi api({String? deviceId = _dev, bool withHuman = true}) =>
        OperatorCommandApi(
          OperatorRuntime(
            files: files,
            clock: clock,
            deviceId: deviceId,
            humanDecision: withHuman ? human : null,
          ),
          random: Random(11),
        );

    void choose([OperatingMode m = OperatingMode.autoTrade]) => expect(
      SqliteOnboardingStore(files.sim, clock: clock).selectOperatingMode(m).ok,
      isTrue,
    );

    SelfReportSubmission sub(
      String cash, {
      SelfReportPurpose purpose = SelfReportPurpose.simOpening,
    }) => SelfReportSubmission(
      purpose: purpose,
      input: SelfReportInput(cashKrwText: cash),
      declaredComplete: true,
    );

    int n(String sql, [List<Object?> args = const <Object?>[]]) =>
        files.sim.select(sql, args).first['n'] as int;
    int openings() => n(
      'SELECT COUNT(*) AS n FROM decision_log WHERE reason_code = ?',
      <Object?>[DecisionReasonCodes.simOpeningBalance],
    );
    int configs() => n('SELECT COUNT(*) AS n FROM config_versions');
    int flows() => n(
      'SELECT COUNT(*) AS n FROM cash_flow WHERE note = ?',
      <Object?>[DecisionReasonCodes.simOpeningBalance],
    );

    test('🔴 선언 = 엔진 실행 · 지금 설정 = 발주자 결정 판 · 계좌별 입금 · 접수증 = 엔진 문구 · watchCommand 같은 값', () async {
      choose();
      final OperatorCommandApi a = api();
      final CommandReceipt r = await a.submitSelfReportBalance(
        sub('10,000,000'),
      );
      expect(r.state, CommandState.executed, reason: r.stateLabel);
      expect(r.kind, CommandKind.selfReportBalance);
      expect(r.issuedByDeviceId, _dev);
      expect(r.rejectReasonCode, isNull);
      expect(r.stateLabel, '가상 초기금 10,000,000원을 계좌 3곳에 나눠 넣었습니다.');
      expect(openings(), 1);
      final OpsConfigReady cfg =
          currentP0sOpsConfig(files.sim) as OpsConfigReady;
      expect(cfg.configHash, P0sOpsConfig.of(human.inputs).configHash);
      expect(cfg.config.aSymbol, '229200');
      expect(cfg.config.human.accountByStrategy, accounts);
      final List<(String, num)> rows = <(String, num)>[
        for (final row in files.sim.select(
          'SELECT account_alias, amount FROM cash_flow WHERE note = ? '
          'ORDER BY account_alias',
          <Object?>[DecisionReasonCodes.simOpeningBalance],
        ))
          (row['account_alias'] as String, row['amount'] as num),
      ];
      expect(
        <String>[for (final (String a, num _) in rows) a],
        <String>['general', 'isa', 'pension'],
      );
      expect(rows.fold<num>(0, (num s, (String, num) e) => s + e.$2), 10000000);
      expect(await a.watchCommand(r.commandId).toList(), <CommandReceipt>[r]);
    });

    test('🔴 원문 틀림 = 큐 적재 없이 INPUT_INVALID · 어느 칸인지 · 아무것도 안 씀 · watchCommand ④ 거부 1값', () async {
      choose();
      final OperatorCommandApi a = api();
      final int before = configs();
      final CommandReceipt blank = await a.submitSelfReportBalance(sub(' '));
      expect(blank.state, CommandState.rejected);
      expect(blank.rejectReasonCode, AdviceRejectCodes.inputInvalid);
      expect(blank.stateLabel, kSimOpeningCashBlank);
      final CommandReceipt bad = await a.submitSelfReportBalance(sub('1만'));
      expect(bad.rejectReasonCode, AdviceRejectCodes.inputInvalid);
      expect(bad.stateLabel, kSimOpeningCashMalformed);
      expect(bad.commandId, isNot(blank.commandId));
      expect(openings(), 0);
      expect(flows(), 0);
      expect(configs(), before);
      expect(await a.watchCommand(blank.commandId).toList(), <CommandReceipt>[
        blank,
      ]);
    });

    test('🔴 금액 규칙 = 엔진 거부(0 이하 · 원 미만) · 판 등재는 먼저(같은 지문 1행) · 다시 내면 실행 · 두 번째 = 이미 선언', () async {
      choose();
      final OperatorCommandApi a = api();
      final int before = configs();
      final CommandReceipt zero = await a.submitSelfReportBalance(sub('0'));
      expect(zero.state, CommandState.rejected);
      expect(zero.rejectReasonCode, SimOpeningCodes.notPositive);
      expect(zero.stateLabel, '가상 초기금은 0원보다 커야 합니다.');
      final CommandReceipt frac = await a.submitSelfReportBalance(
        sub('1000.5'),
      );
      expect(frac.rejectReasonCode, SimOpeningCodes.notWholeWon);
      expect(openings(), 0);
      expect(configs(), before + 1);
      final CommandReceipt ok = await a.submitSelfReportBalance(sub('5000000'));
      expect(ok.state, CommandState.executed, reason: ok.stateLabel);
      expect(configs(), before + 1);
      final CommandReceipt again = await a.submitSelfReportBalance(
        sub('5000000'),
      );
      expect(again.rejectReasonCode, SimOpeningCodes.alreadyDeclared);
      expect(openings(), 1);
    });

    test(
      '🔴 운영 방식 고르기 전 · 사람 값 원천 없음 = 엔진 문구로 거부 · 판 등재 0(맥락 · 설정을 지어내지 않는다)',
      () async {
        final int before = configs();
        final CommandReceipt noChoice = await api().submitSelfReportBalance(
          sub('1000000'),
        );
        expect(noChoice.rejectReasonCode, SimOpeningCodes.choiceMissing);
        expect(noChoice.stateLabel, '운영 방식을 먼저 골라 주세요.');
        choose();
        final CommandReceipt noHuman = await api(withHuman: false)
            .submitSelfReportBalance(sub('1000000'));
        expect(noHuman.rejectReasonCode, SimOpeningCodes.accountUnmapped);
        expect(noHuman.stateLabel, '전략의 계좌 대응이 비어 있어 가상 초기금을 나눌 수 없습니다.');
        expect(configs(), before);
        expect(openings(), 0);
      },
    );

    test('🔴 투자 안내 갈래 = 엔진 거부(E18) · 정기 실사 = 구현 전 · 기기 id 없음 = 오류', () async {
      choose(OperatingMode.advisory);
      final CommandReceipt adv = await api().submitSelfReportBalance(
        sub('1000000'),
      );
      expect(adv.rejectReasonCode, SimOpeningCodes.advisoryNotReady);
      await expectLater(
        api().submitSelfReportBalance(
          sub('1000000', purpose: SelfReportPurpose.periodicAudit),
        ),
        throwsA(isA<UnsupportedError>()),
      );
      await expectLater(
        api(deviceId: null).submitSelfReportBalance(sub('1000000')),
        throwsA(isA<StateError>()),
      );
      expect(openings(), 0);
    });

    test('🔴 기준일 = 입금 기준일 규칙(D10) — 주말 선언 = 다음 KR 거래일', () async {
      clock.now = kst(2026, 11, 21, 10, 0);
      choose();
      final CommandReceipt r = await api().submitSelfReportBalance(
        sub('3000000'),
      );
      expect(r.state, CommandState.executed, reason: r.stateLabel);
      final String day = const TradeDate('2026-11-23').yyyyMmDd;
      expect(
        files.sim.select(
          'SELECT decision_id FROM decision_log WHERE reason_code = ?',
          <Object?>[DecisionReasonCodes.simOpeningBalance],
        ).first['decision_id'],
        'SIMOPEN-$day',
      );
      expect(
        n(
          'SELECT COUNT(*) AS n FROM cash_flow WHERE note = ? AND trade_date = ?',
          <Object?>[DecisionReasonCodes.simOpeningBalance, day],
        ),
        3,
      );
    });
  });
}
