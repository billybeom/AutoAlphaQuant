// 🆕 E15f3a — simToAuto 2단 커밋 1단계(실전 파일 한 트랜잭션 · 게이트 · 되돌림 · S5 고름 · 커밋 알림 · 설계 13 §8 R98).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HandoverCloseCode,
        HandoverSessionCodes,
        LiveAccountProbe,
        LiveObservationConfig,
        Market,
        P0sStrategyIds,
        SimLedgerFate,
        SimToAutoCodes,
        SimToAutoCommitCodes,
        SimToAutoFacts,
        SimTrialCounters,
        SimTrialItemResult,
        SimTrialReport,
        TrustedClock,
        frozenExchangeCalendar,
        kP0sSeedStrategies;
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

/// 생체 = 01-12(화) 10:00 · 확정 = 01-13 11:00(냉각 끝 뒤 · 기한 전).
final DateTime _opened = _k('2027-01-12', 10);
final DateTime _commitAt = _k('2027-01-13', 11);
final DateTime _device = _k('2027-01-13', 11, 7);

const SimTrialReport _done = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: true,
  needsWarning: false,
  counters: SimTrialCounters.zero,
  headline: '체험 5항목을 모두 채웠습니다.',
);

final SimToAutoFacts _facts = SimToAutoFacts(
  trustedNowUtc: null,
  simRunMode: RunMode.simInternal,
  simClosed: false,
  operatingMode: OperatingMode.autoTrade,
  trial: _done,
  goldenVectorPassed: true,
  liveKeysVerified: true,
  accountByStrategy: const <String, String>{
    P0sStrategyIds.sleeveA: 'general',
    P0sStrategyIds.sleeveB: 'pension',
    P0sStrategyIds.sleeveC: 'general',
    P0sStrategyIds.pot: 'general',
  },
  fate: SimLedgerFate.keep,
  sessionOpenedAtUtc: null,
  killSwitchActive: false,
  blockingFlags: const <String>[],
);

LiveAccountProbe _p(
  String alias, {
  int holdings = 0,
  int? cash,
  int activity = 0,
  DateTime? at,
}) => LiveAccountProbe(
  alias: alias,
  holdingsCount: holdings,
  orderableCashKrw: cash ?? (alias == 'general' ? 1200000 : 500000),
  activityToday: activity,
  fetchedAtUtc: at ?? _commitAt.subtract(const Duration(minutes: 1)),
);

int _n(Database db, String table, [String where = '1=1']) =>
    db.select('SELECT COUNT(*) AS n FROM $table WHERE $where').first['n']!
        as int;

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;
  late _Trusted trusted;
  late SqliteSimToAutoCommitStore store;
  late SqliteHandoverSessionStore sessions;
  late String sessionId;

  SimToAutoCommitOutcome commit({String? id, List<LiveAccountProbe>? probes}) =>
      store.commit(
        sessionId: id ?? sessionId,
        simFacts: _facts,
        kr: _kr,
        observation: _two,
        probes: probes ?? <LiveAccountProbe>[_p('general'), _p('pension')],
        configHash: 'cfg-1',
      );

  int writes() =>
      _n(live, 'decision_log') +
      _n(live, 'cash_flow') +
      _n(live, 'strategy_state_current') +
      _n(live, 'strategy_state_log') +
      _n(live, 'operating_mode_transition') +
      _n(live, 'mode_transition') +
      _n(live, 'alert_event');

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15f3a_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _opened);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _opened);
    clock = _Clock(_device);
    trusted = _Trusted(_opened);
    sessions = SqliteHandoverSessionStore(live, clock: clock, trusted: trusted);
    final HandoverSessionOutcome o = sessions.openSimToAuto(
      biometricConfirmed: true,
      facts: _facts,
      kr: _kr,
      observation: _two,
      deviceId: 'device-1',
      leaseEpoch: 1,
    );
    expect(o.ok, isTrue, reason: o.headline);
    sessionId = o.sessionId!;
    trusted.at = _commitAt;
    store = SqliteSimToAutoCommitStore(live, clock: clock, trusted: trusted);
  });

  tearDown(() {
    live.close();
    sim.close();
    dir.deleteSync(recursive: true);
  });

  test('🔴 실전 파일만 — 모의 파일 = StateError', () {
    expect(
      () => SqliteSimToAutoCommitStore(sim, clock: clock, trusted: trusted),
      throwsStateError,
    );
  });

  test('1단계 — 개시 결정 · 계좌별 입금 · 시딩 4 · 운영 방식 · RUN_MODE · 세션 COMMITTED · 알림(시각 = 신뢰 하나)', () {
    final SimToAutoCommitOutcome o = commit();
    expect(o.ok, isTrue, reason: o.headline);
    expect(o.decisionId, 'LIVEOPEN-20270113-110000');
    expect(
      o.headline,
      '실전 자동 매매로 옮겼습니다 — 계좌 2곳 예수금 1,700,000원으로 개시했습니다. 실전은 주문 없이 관찰부터 시작합니다.',
    );
    final String at = _iso(_commitAt);
    final Row d = live.select('SELECT * FROM decision_log').single;
    expect(d['decision_id'], o.decisionId);
    expect(d['created_at'], at);
    expect(d['trade_date'], '2027-01-13');
    expect(d['mode'], 'LIVE');
    expect(d['kind'], 'MANUAL');
    expect(d['strategy_id'], 'P0S');
    expect(d['reason_code'], 'OPENING_BALANCE');
    expect(d['config_hash'], 'cfg-1');
    final ResultSet cf = live.select(
      'SELECT * FROM cash_flow ORDER BY account_alias',
    );
    expect(cf.map((Row r) => '${r['account_alias']}=${r['amount']}'), <String>[
      'general=1200000.0',
      'pension=500000.0',
    ]);
    for (final Row r in cf) {
      expect(r['kind'], 'DEPOSIT');
      expect(r['note'], 'OPENING_BALANCE');
      expect(r['flow_id'], '${o.decisionId}-${r['account_alias']}');
      expect(r['trade_date'], '2027-01-13');
      expect(r['recorded_at'], at);
    }
    expect(
      live
          .select('SELECT strategy_id, since FROM strategy_state_current')
          .map((Row r) => '${r['strategy_id']}@${r['since']}')
          .toSet(),
      <String>{for (final String s in kP0sSeedStrategies) '$s@2027-01-13'},
    );
    expect(_n(live, 'strategy_state_log', "reason = 'LIVE_OPENING'"), 4);
    final Row om = live
        .select('SELECT * FROM operating_mode_transition')
        .single;
    expect(om['handover_session_id'], sessionId);
    expect(om['from_mode'], 'AUTO_TRADE');
    expect(om['to_mode'], 'AUTO_TRADE');
    expect(om['decision_id'], o.decisionId);
    expect(om['committed_at'], at);
    final SqliteModeStore modes = SqliteModeStore(
      live,
      LedgerFile.live,
      clock: clock,
    );
    expect(modes.current()!.runMode, RunMode.live);
    expect(modes.current()!.execPolicy, ExecPolicy.dryRun);
    expect(modes.operatingMode(), OperatingMode.autoTrade);
    final Row mt = live.select('SELECT * FROM mode_transition').single;
    expect(mt['axis'], 'RUN_MODE');
    expect(mt['handover_session_id'], sessionId);
    expect(mt['decision_id'], o.decisionId);
    expect(mt['committed_at'], at);
    final HandoverSessionRecordView s = HandoverSessionRecordView(
      sessions.session(sessionId)!.closeCode,
      sessions.session(sessionId)!.closedAtUtc,
    );
    expect(s.code, HandoverCloseCode.committed);
    expect(s.at, _commitAt);
    final Row a = live.select('SELECT * FROM alert_event').single;
    expect(a['code'], 'HANDOVER_COMMITTED');
    expect(a['source'], 'handover-commit');
    expect(a['level'], 'P1');
    expect(a['raised_at'], at);
    // 모의 파일은 건드리지 않는다(f3b).
    expect(_n(sim, 'mode_transition'), 0);
    // 다시 = 세션이 닫혔다.
    expect(commit().reasonCode, HandoverSessionCodes.sessionInvalid);
  });

  test('게이트 거부 = 쓰기 0 · 세션 그대로', () {
    void same(String code, SimToAutoCommitOutcome o) {
      expect(o.reasonCode, code);
      expect(writes(), 0);
      expect(sessions.session(sessionId)!.closed, isFalse);
    }

    trusted.at = null;
    same(SimToAutoCodes.trustedTimeUnavailable, commit());
    trusted.at = _k('2027-01-12', 20);
    same(SimToAutoCodes.cooling, commit());
    trusted.at = _commitAt;
    same(HandoverSessionCodes.sessionInvalid, commit(id: 'HS-NONE'));
    same(
      SimToAutoCommitCodes.holdingsNotZero,
      commit(
        probes: <LiveAccountProbe>[_p('general', holdings: 1), _p('pension')],
      ),
    );
    same(
      SimToAutoCommitCodes.snapshotStale,
      commit(
        probes: <LiveAccountProbe>[
          _p('general', at: _commitAt.subtract(const Duration(minutes: 6))),
          _p('pension'),
        ],
      ),
    );
    same(
      SimToAutoCommitCodes.brokerActivityToday,
      commit(
        probes: <LiveAccountProbe>[_p('general'), _p('pension', activity: 1)],
      ),
    );
    same(
      SimToAutoCommitCodes.probeMissing,
      commit(probes: <LiveAccountProbe>[_p('general')]),
    );
    expect(
      commit(probes: <LiveAccountProbe>[_p('general'), _p('pension')]).headline,
      isNot(contains('DRY_RUN')),
    );
  });

  test('이미 커밋(실전 모드 행 있음) = 거부 · 쓰기 0', () {
    SqliteModeStore(live, LedgerFile.live, clock: clock).record(
      axis: ModeAxis.runMode,
      runMode: RunMode.live,
      execPolicy: ExecPolicy.dryRun,
      operatingMode: OperatingMode.autoTrade,
      handoverSessionValid: false,
      decisionId: 'D-OLD',
    );
    final SimToAutoCommitOutcome o = commit();
    expect(o.reasonCode, SimToAutoCommitCodes.alreadyCommitted);
    expect(_n(live, 'decision_log'), 0);
    expect(_n(live, 'mode_transition'), 1);
    expect(sessions.session(sessionId)!.closed, isFalse);
  });

  test('쓰기 실패 = 전부 되돌림 + 세션 ROLLED_BACK(냉각부터 다시)', () {
    // 시딩 PK 가 겹친다 → SQLite 오류.
    live.execute(
      'INSERT INTO strategy_state_current (strategy_id, state, since, capital_cap) VALUES (?, ?, ?, ?)',
      <Object?>[kP0sSeedStrategies.last, 'ACTIVE', '2027-01-01', 1.0],
    );
    final SimToAutoCommitOutcome o = commit();
    expect(o.reasonCode, SimToAutoCommitCodes.rolledBack);
    expect(o.headline, '저장에 실패해 아무것도 바꾸지 않았습니다 — 전환 세션을 닫았으니 처음부터 다시 진행해 주세요.');
    expect(_n(live, 'decision_log'), 0);
    expect(_n(live, 'cash_flow'), 0);
    expect(_n(live, 'strategy_state_log'), 0);
    expect(_n(live, 'strategy_state_current'), 1);
    expect(_n(live, 'operating_mode_transition'), 0);
    expect(_n(live, 'mode_transition'), 0);
    expect(_n(live, 'alert_event'), 0);
    expect(
      sessions.session(sessionId)!.closeCode,
      HandoverCloseCode.rolledBack,
    );
    expect(sessions.session(sessionId)!.closedAtUtc, _commitAt);
  });

  group('emitInTransaction', () {
    test('트랜잭션 밖 = StateError · 모르는 코드 = ArgumentError(쓰기 0) · 빈 집합 = 무시', () {
      final SqliteAlertSink sink = SqliteAlertSink(live, clock: clock);
      expect(
        () => sink.emitInTransaction('x', <String>{'HANDOVER_COMMITTED'}),
        throwsStateError,
      );
      live.execute('BEGIN');
      expect(
        () => sink.emitInTransaction('x', <String>{
          'HANDOVER_COMMITTED',
          'SOMETHING_NEW',
        }),
        throwsArgumentError,
      );
      sink.emitInTransaction('x', <String>{});
      live.execute('COMMIT');
      expect(_n(live, 'alert_event'), 0);
    });
  });

  group('S5 고름 저장(모의 파일)', () {
    late SqliteModeStore simModes;

    setUp(() {
      simModes = SqliteModeStore(sim, LedgerFile.sim, clock: clock);
    });

    test('🔴 모의 파일만 — 실전 파일 = StateError', () {
      expect(
        () => SqliteSimLedgerFateStore(live, clock: clock),
        throwsStateError,
      );
    });

    test('모드 행 없음 = 거부 · 고름 = 최신이 이김(같은 초도 순번) · 닫힌 뒤 = 거부(쓰기 0)', () {
      final SqliteSimLedgerFateStore f = SqliteSimLedgerFateStore(
        sim,
        clock: clock,
      );
      expect(f.current(), isNull);
      expect(
        f.choose(SimLedgerFate.keep, configHash: 'cfg-1'),
        SimToAutoCodes.notSimAuto,
      );
      expect(_n(sim, 'decision_log'), 0);
      simModes.record(
        axis: ModeAxis.runMode,
        runMode: RunMode.simBroker,
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        handoverSessionValid: false,
        decisionId: 'D-SIM',
      );
      expect(f.choose(SimLedgerFate.keep, configHash: 'cfg-1'), isNull);
      expect(f.current(), SimLedgerFate.keep);
      expect(f.choose(SimLedgerFate.discard, configHash: 'cfg-1'), isNull);
      expect(f.current(), SimLedgerFate.discard);
      final ResultSet rows = sim.select(
        'SELECT * FROM decision_log ORDER BY decision_id',
      );
      expect(rows.map((Row r) => r['decision_id']), <String>[
        'SIMFATE-20270113-110700-001',
        'SIMFATE-20270113-110700-002',
      ]);
      expect(rows.first['mode'], 'SIM_BROKER');
      expect(rows.first['kind'], 'MANUAL');
      expect(rows.first['strategy_id'], 'P0S');
      expect(rows.first['reason_code'], 'SIM_LEDGER_KEEP');
      expect(rows.last['reason_code'], 'SIM_LEDGER_DISCARD');
      expect(rows.first['config_hash'], 'cfg-1');
      expect(rows.first['trade_date'], '2027-01-13');
      // 다른 MANUAL 행은 고름이 아니다.
      sim.execute(
        'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, '
        "reason, reason_code, config_hash) VALUES ('Z-LAST', ?, '2027-01-14', 'SIM_BROKER', 'MANUAL', 'P0S', "
        "'x', 'SIM_OPENING_BALANCE', 'c')",
        <Object?>[_iso(_k('2027-01-14', 9))],
      );
      expect(f.current(), SimLedgerFate.discard);
      simModes.close(decisionId: 'D-CLOSE');
      expect(
        f.choose(SimLedgerFate.keep, configHash: 'cfg-1'),
        SimToAutoCommitCodes.simClosed,
      );
      expect(f.current(), SimLedgerFate.discard);
      expect(_n(sim, 'decision_log'), 3);
    });
  });
}

/// 시험용 — 닫힘 코드 · 시각 한 쌍.
class HandoverSessionRecordView {
  /// 쌍을 만든다.
  const HandoverSessionRecordView(this.code, this.at);

  /// 닫힘 코드.
  final HandoverCloseCode? code;

  /// 닫힌 시각.
  final DateTime? at;
}
