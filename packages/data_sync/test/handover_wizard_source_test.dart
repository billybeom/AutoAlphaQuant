// 🆕 E11q-c1 — M5-11 simToAuto 위저드 원천(모의 파일 + 실전 파일 → 엔진 VM · 설계 13 §8 R191 · 미결 207 ⓓ).
//
// 🔴 원장 원문만 모은다 — 모드 · 운영 방식 · 체험 · 고름 · 킬스위치 · 차단 · 승인 지문(모의) · 세션 · 확정 행(실전) ·
//    판정 시각 = 신뢰 시각(모름 = 엔진 «시각을 확인할 수 없어») · 실전 파일 없음 = 세션 0 · 확정 0.

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HandoverCommitted,
        HandoverWizardTexts,
        LiveObservationConfig,
        Market,
        P0sStrategyIds,
        SimLedgerFate,
        SimToAutoCodes,
        TrustedClock,
        frozenExchangeCalendar,
        kHandoverSessionTtl;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

String _iso(DateTime t) => t.toUtc().toIso8601String();

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final LiveObservationConfig _two = LiveObservationConfig(
  requiredTradingDays: 2,
);

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

final DateTime _t0 = _k('2027-01-12', 12);

void main() {
  late Directory dir;
  late Database sim;
  Database? live;
  late _Clock clock;
  late _Trusted trusted;
  late String hash;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_hws_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    live = null;
    hash = SqliteConfigVersionStore(
      sim,
      clock: clock,
    ).register(<String, Object?>{'p0s': true, 'v': 1});
  });

  tearDown(() {
    sim.close();
    live?.close();
    dir.deleteSync(recursive: true);
  });

  Database openLive() =>
      live ??= openLocalLedger(dir.path, RunMode.live, clock: () => _t0);

  void simStarted({OperatingMode op = OperatingMode.autoTrade}) {
    sim.execute(
      'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
      <Object?>[op.wire, _iso(_t0), _iso(_t0)],
    );
    SqliteModeStore(sim, LedgerFile.sim, clock: clock).record(
      axis: ModeAxis.runMode,
      runMode: RunMode.simInternal,
      execPolicy: ExecPolicy.execute,
      operatingMode: op,
      handoverSessionValid: false,
      decisionId: 'D-SIM',
    );
  }

  void session(String id, DateTime opened, {String? code, DateTime? closed}) =>
      openLive().execute(
        'INSERT INTO handover_session (handover_session_id, kind, path, device_id, lease_epoch, '
        'opened_at, expires_at, closed_at, close_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          id,
          'WIZARD_M5_11',
          'SIM_TO_AUTO',
          'dev-0',
          0,
          _iso(opened),
          _iso(opened.add(kHandoverSessionTtl)),
          closed == null ? null : _iso(closed),
          code,
        ],
      );

  SqliteHandoverWizardSource src({
    bool? golden = true,
    bool? keys = true,
    String? current,
    bool noCurrent = false,
    bool canAct = true,
    String? locked,
  }) => SqliteHandoverWizardSource(
    sim: sim,
    live: live,
    clock: clock,
    trusted: trusted,
    kr: _kr,
    observation: _two,
    goldenVectorPassed: golden,
    liveKeysVerified: keys,
    accountByStrategy: _accounts,
    currentConfigHash: noCurrent ? null : (current ?? hash),
    canAct: canAct,
    lockedLabel: locked,
  );

  test('🔴 모의 파일만 — 실전 파일을 sim 자리에 넣으면 StateError', () {
    final Database l = openLive();
    expect(
      () => SqliteHandoverWizardSource(
        sim: l,
        live: null,
        clock: clock,
        trusted: trusted,
        kr: _kr,
        observation: _two,
        goldenVectorPassed: true,
        liveKeysVerified: true,
        accountByStrategy: _accounts,
        currentConfigHash: hash,
        canAct: true,
      ),
      throwsStateError,
    );
  });

  test('전제 밖(모드 행 0 · 안내 운영) = 단계 0 · 머리 = 엔진 전제 문장', () {
    HandoverWizardVm vm = src().wizard();
    expect((vm.rows.length, vm.reasonCode), (0, SimToAutoCodes.notSimAuto));
    simStarted(op: OperatingMode.advisory);
    vm = src().wizard();
    expect((vm.rows.length, vm.level), (0, UiLevel.info));
  });

  test('모의 자동 매매 · 고르기 전 — 체험 미완 = S1 막힘 · 판정 입력 = 원장 원문', () {
    simStarted();
    final SqliteHandoverWizardSource s = src(golden: null, keys: null);
    final HandoverWizardVm vm = s.wizard();
    expect(vm.rows, hasLength(7));
    expect(vm.reasonCode, SimToAutoCodes.trialIncomplete);
    expect(vm.trial, isNotNull);
    expect(vm.rows[1].link?.deepLink, AppRoutes.settingsDiagnostics);
    expect(vm.rows[2].link?.deepLink, AppRoutes.settingsCredentials);
    expect(s.fate(), isNull);
    expect(s.session(), isNull);
    expect(s.committed(), isNull);
    expect(s.trial().started, isTrue);
  });

  test('S5 고름 = 모의 파일 최신 행 · 킬스위치 · 차단 플래그(DST 제외) = 판정 입력', () {
    simStarted();
    expect(
      SqliteSimLedgerFateStore(
        sim,
        clock: clock,
      ).choose(SimLedgerFate.discard, configHash: hash),
      isNull,
    );
    sim.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>[FlagIds.dstWeek, _iso(_t0), 'dst'],
    );
    final SqliteHandoverWizardSource s = src();
    expect(s.fate(), SimLedgerFate.discard);
    expect(s.facts(trustedNowUtc: _t0, session: null).blockingFlags, isEmpty);
    sim.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>['RECON_MISMATCH', _iso(_t0), 'x'],
    );
    expect(
      src().facts(trustedNowUtc: _t0, session: null).blockingFlags,
      <String>['RECON_MISMATCH'],
    );
    expect(src().wizard().reasonCode, SimToAutoCodes.safetyBlock);
  });

  test('킬스위치 켜짐 = 판정 입력(모의 파일 `kill_switch_state`)', () {
    simStarted();
    expect(
      src().facts(trustedNowUtc: _t0, session: null).killSwitchActive,
      isFalse,
    );
    sim.execute(
      "INSERT INTO kill_switch_state (id, activated_at, activated_by) VALUES (1, ?, 'app')",
      <Object?>[_iso(_t0)],
    );
    expect(
      src().facts(trustedNowUtc: _t0, session: null).killSwitchActive,
      isTrue,
    );
    expect(src().wizard().reasonCode, SimToAutoCodes.safetyBlock);
  });

  test(
    '🔴 실전 파일 세션 — 냉각 중 = 취소(세션 id = args) · 시각 모름 = WATCH · 판정 시각 = 신뢰 시각',
    () {
      simStarted();
      session('HS-1', _k('2027-01-12', 10));
      final SqliteHandoverWizardSource s = src();
      expect(s.session()?.sessionId, 'HS-1');
      HandoverWizardVm vm = s.wizard();
      expect(vm.reasonCode, isNot(SimToAutoCodes.notSimAuto));
      final HandoverWizardStepRow s7 = vm.rows[6];
      expect(s7.step.blockedReasonCode, SimToAutoCodes.cooling);
      expect(s7.actions.single.id, SettingsActionId.handoverSessionCancel);
      expect(s7.actions.single.args, <String, String>{
        'handover_session_id': 'HS-1',
      });
      expect(
        vm.coolingText,
        HandoverWizardTexts.coolingEnds(_k('2027-01-13', 10)),
      );
      // 기기 시계가 아무리 흘러도 신뢰 시각이 판정한다.
      clock.at = _k('2027-01-20', 10);
      trusted.at = null;
      vm = src().wizard();
      expect(
        vm.rows[6].step.blockedReasonCode,
        SimToAutoCodes.trustedTimeUnavailable,
      );
      expect(vm.rows[6].level, UiLevel.watch);
      expect(vm.asOf.observedAt, _k('2027-01-20', 10));
    },
  );

  test('닫힌 세션 = 세션 0 · S6 = 생체 확인 전 · S7 동작 0', () {
    simStarted();
    session(
      'HS-0',
      _k('2027-01-10', 10),
      code: 'CANCELLED',
      closed: _k('2027-01-10', 11),
    );
    expect(src().session(), isNull);
    final HandoverWizardVm vm = src().wizard();
    expect(vm.rows[5].step.state, GateState.unknown);
    expect(vm.rows[6].actions, isEmpty);
    expect(vm.coolingText, isNull);
  });

  test('🔴 SAF-405 — 지금 지문이 승인 지문일 때만 고지 0 · 승인 0 · 다른 지문 · 지문 없음 = 고지', () {
    simStarted();
    expect(src().configApproved(), isFalse);
    expect(src().wizard().noticeText, HandoverWizardTexts.configNotApproved);
    sim.execute(
      'UPDATE config_versions SET approved = 1 WHERE config_hash = ?',
      <Object?>[hash],
    );
    expect(src().configApproved(), isTrue);
    expect(src().wizard().noticeText, isNull);
    expect(src(current: 'other').configApproved(), isFalse);
    expect(src(noCurrent: true).configApproved(), isFalse);
    expect(src(current: '  ').configApproved(), isFalse);
  });

  test('🔴 확정 뒤(실전 RUN_MODE 행) = doneLabel · 확정 세션 시각 · 동작 0', () {
    simStarted();
    session(
      'HS-2',
      _k('2027-01-11', 10),
      code: 'COMMITTED',
      closed: _k('2027-01-12', 11),
    );
    final SqliteHandoverWizardSource s0 = src();
    expect(s0.committed(), isNull);
    SqliteModeStore(openLive(), LedgerFile.live, clock: clock).record(
      axis: ModeAxis.runMode,
      runMode: RunMode.live,
      execPolicy: ExecPolicy.dryRun,
      operatingMode: OperatingMode.autoTrade,
      handoverSessionValid: false,
      decisionId: 'D-LIVE',
    );
    final HandoverCommitted? c = src().committed();
    expect(
      (c?.openedAtUtc, c?.committedAtUtc),
      (_k('2027-01-11', 10), _k('2027-01-12', 11)),
    );
    final HandoverWizardVm vm = src().wizard();
    expect(vm.doneLabel, HandoverWizardTexts.done);
    expect(vm.rows, hasLength(7));
    expect(
      vm.rows.every((HandoverWizardStepRow r) => r.actions.isEmpty),
      isTrue,
    );
  });

  test('확정 행만 있고 확정 세션 0 = 시각 없는 확정 본문', () {
    SqliteModeStore(openLive(), LedgerFile.live, clock: clock).record(
      axis: ModeAxis.runMode,
      runMode: RunMode.live,
      execPolicy: ExecPolicy.dryRun,
      operatingMode: OperatingMode.autoTrade,
      handoverSessionValid: false,
      decisionId: 'D-LIVE',
    );
    final HandoverCommitted? c = src().committed();
    expect((c?.openedAtUtc, c?.committedAtUtc), (null, null));
  });

  test('쓰기 창구 없음 · 잠김 = 동작 0 · 잠김 글자 그대로', () {
    simStarted();
    for (final HandoverWizardVm vm in <HandoverWizardVm>[
      src(canAct: false).wizard(),
      src(locked: '보기만').wizard(),
    ]) {
      expect(
        vm.rows.every((HandoverWizardStepRow r) => r.actions.isEmpty),
        isTrue,
      );
    }
    expect(src(locked: '보기만').wizard().lockedLabel, '보기만');
  });

  test('세션 시각에 시차가 없으면 FormatException(모르는 시각을 바꾸지 않는다)', () {
    SqliteModeStore(openLive(), LedgerFile.live, clock: clock).record(
      axis: ModeAxis.runMode,
      runMode: RunMode.live,
      execPolicy: ExecPolicy.dryRun,
      operatingMode: OperatingMode.autoTrade,
      handoverSessionValid: false,
      decisionId: 'D-LIVE',
    );
    live!.execute(
      'INSERT INTO handover_session (handover_session_id, kind, path, device_id, lease_epoch, '
      "opened_at, expires_at, closed_at, close_code) VALUES ('HS-9', 'WIZARD_M5_11', 'SIM_TO_AUTO', "
      "'d', 0, '2027-01-11T01:00:00', '2027-01-13T01:00:00Z', '2027-01-12T02:00:00Z', 'COMMITTED')",
    );
    expect(() => src().committed(), throwsFormatException);
  });

  test('다시 낼 표 — 모의 · 실전', () {
    expect(
      SqliteHandoverWizardSource.simTables,
      containsAll(<String>[
        'mode_transition',
        'decision_log',
        'trading_block',
        'kill_switch_state',
        'config_versions',
      ]),
    );
    expect(SqliteHandoverWizardSource.liveTables, <String>{
      'handover_session',
      'mode_transition',
    });
  });
}
