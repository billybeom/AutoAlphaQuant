// 🆕 E15f3a — simToAuto 2단 커밋 1단계(실전 파일 한 트랜잭션 · 게이트 · 되돌림 · S5 고름 · 커밋 알림 · 설계 13 §8 R98).
// 🆕 R189(미결 205 ⓒⓓⓔ · 208) — 승인 config · 승인 기록 · 서약 = 실전 파일로(같은 트랜잭션) · 승인 없음 = 거부 · 기동 게이트.

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HandoverCloseCode,
        HandoverSessionCodes,
        LeaseSnapshot,
        LeaseVerdict,
        LiveAccountProbe,
        LiveObservationConfig,
        Market,
        P0sStrategyIds,
        RuleChangeType,
        SimLedgerFate,
        SimToAutoCodes,
        SimToAutoCommitCodes,
        SimToAutoFacts,
        SimTrialCounters,
        SimTrialItemResult,
        SimTrialReport,
        TrustedClock,
        frozenExchangeCalendar,
        kP0sSeedStrategies,
        startupConfigGate;
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

/// 🆕 R189 — 모의 파일에 서약(첫 판 11-25 · 12월 편집 + 저널) · 첫 승인(요청 12-01 → 냉각 30일 → 승인 01-02)을
/// 실물 저장 경로로 쓴다 → 승인 판 지문.
String _seedSim(Database sim, _Clock clock, _Trusted trusted) {
  final String hash = SqliteConfigVersionStore(
    sim,
    clock: clock,
  ).register(<String, Object?>{'spec': 'r189', 'accounts': 'general'});
  // 승인 안 된 다른 판(옮기지 않는다).
  SqliteConfigVersionStore(
    sim,
    clock: clock,
  ).register(<String, Object?>{'spec': 'r189', 'accounts': 'other'});
  final SqlitePledgeStore pledge = SqlitePledgeStore(
    sim,
    clock: clock,
    trusted: trusted,
  );
  trusted.at = _k('2026-11-25', 9);
  expect(
    pledge
        .writeFirst(
          commandId: 'pw-1',
          payloadDigest: 'dg',
          sentences: const <String>['하나', '둘', '셋'],
          decisionId: 'ON-1',
        )
        .executed,
    isTrue,
  );
  sim.execute(
    'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, is_deviation, '
    "rationale_before, expected_outcome, rule_cited, kind, note, created_at) VALUES ('J-PL2', '2026-12-10', 'P0S', "
    "'{}', '{}', 0, '근거', '기대', '03 §6-4', NULL, NULL, '2026-12-10T00:00:00.000Z')",
  );
  trusted.at = _k('2026-12-10', 9);
  expect(
    pledge
        .edit(
          commandId: 'pe-1',
          payloadDigest: 'dg',
          sentences: const <String>['하나', '둘', '넷'],
          decisionId: 'J-PL2',
        )
        .executed,
    isTrue,
  );
  final SqliteRuleChangeStore rc = SqliteRuleChangeStore(
    sim,
    clock: clock,
    trusted: trusted,
  );
  trusted.at = _k('2026-12-01', 9);
  expect(
    rc
        .requestWithJournal(
          commandId: 'rq-1',
          payloadDigest: 'dg',
          changeType: RuleChangeType.strategyRule,
          hashBefore: 'NONE',
          hashAfter: hash,
          reason: '첫 승인',
          rollbackMethod: '모의 판으로',
          journalId: 'J-RC1',
          rationaleBefore: '모의 체험 완료',
          expectedOutcome: '실전 기동',
          ruleCited: '04 §1 SAF-405',
        )
        .executed,
    isTrue,
  );
  trusted.at = _k('2027-01-02', 9);
  expect(
    rc
        .approve(
          commandId: 'ap-1',
          payloadDigest: 'dg',
          requestId: 'RC-J-RC1',
          goldenChanged: false,
          approver: '본인',
          thirdPartyNotified: true,
        )
        .executed,
    isTrue,
  );
  expect(rc.approvedConfigHash(), hash);
  return hash;
}

/// 시험용 — 표 행 전부(열 값 · 차례 고정).
List<List<Object?>> _rows(Database db, String table, String order) =>
    <List<Object?>>[
      for (final Row r in db.select('SELECT * FROM $table ORDER BY $order'))
        r.values,
    ];

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;
  late _Trusted trusted;
  late SqliteSimToAutoCommitStore store;
  late SqliteHandoverSessionStore sessions;
  late String sessionId;
  late String approvedHash;

  SimToAutoCommitOutcome commit({
    String? id,
    List<LiveAccountProbe>? probes,
    LeaseSnapshot lease = const LeaseSnapshot(
      verdict: LeaseVerdict.valid,
      epoch: 1,
      deviceId: 'device-1',
    ),
    String? configHash,
    SimToAutoCarry? carry,
  }) => store.commit(
    sessionId: id ?? sessionId,
    simFacts: _facts,
    kr: _kr,
    observation: _two,
    probes: probes ?? <LiveAccountProbe>[_p('general'), _p('pension')],
    configHash: configHash ?? approvedHash,
    lease: lease,
    carry: carry ?? readSimToAutoCarry(sim),
  );

  int writes() =>
      _n(live, 'decision_log') +
      _n(live, 'cash_flow') +
      _n(live, 'strategy_state_current') +
      _n(live, 'strategy_state_log') +
      _n(live, 'operating_mode_transition') +
      _n(live, 'mode_transition') +
      _n(live, 'alert_event') +
      _n(live, 'config_versions') +
      _n(live, 'rule_change_request') +
      _n(live, 'rule_change_decision') +
      _n(live, 'decision_journal') +
      _n(live, 'pledge');

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15f3a_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _opened);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _opened);
    clock = _Clock(_device);
    trusted = _Trusted(_opened);
    approvedHash = _seedSim(sim, clock, trusted);
    trusted.at = _opened;
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
    expect(d['config_hash'], approvedHash);
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
    // 모의 파일은 건드리지 않는다(f3b · 🆕 R189 옮김 = 읽기만).
    expect(_n(sim, 'mode_transition'), 0);
    expect(_n(sim, 'config_versions', 'approved = 1'), 1);
    expect(_n(sim, 'pledge'), 2);
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
    // 🆕 E15f4a 리스 — 유효 아님 · 세대 다름 · 기기 다름.
    same(
      'LEASE_INVALID',
      commit(
        lease: const LeaseSnapshot(
          verdict: LeaseVerdict.unknown,
          epoch: 1,
          deviceId: 'device-1',
        ),
      ),
    );
    same(
      SimToAutoCommitCodes.leaseMismatch,
      commit(
        lease: const LeaseSnapshot(
          verdict: LeaseVerdict.valid,
          epoch: 2,
          deviceId: 'device-1',
        ),
      ),
    );
    same(
      SimToAutoCommitCodes.leaseMismatch,
      commit(
        lease: const LeaseSnapshot(
          verdict: LeaseVerdict.valid,
          epoch: 1,
          deviceId: 'device-9',
        ),
      ),
    );
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

  test('🆕 R189 승인 config · 승인 기록 · 서약 = 실전 파일로(같은 트랜잭션 · 모의 행 그대로) · 실전 기동 게이트 통과', () {
    expect(
      startupConfigApprovalOf(live, RunMode.live),
      isNull,
      reason: '커밋 전 실전 파일 = 개시 없음 → SAF-405 거부',
    );
    final SimToAutoCommitOutcome o = commit();
    expect(o.ok, isTrue, reason: o.headline);
    // 설정 판 = 승인 판 하나만(승인 안 된 판 · 큐는 옮기지 않는다) · 내용 · 등재 시각 그대로 · approved 1.
    expect(
      _rows(live, 'config_versions', 'config_hash'),
      _rows(sim, 'config_versions WHERE approved = 1', 'config_hash'),
    );
    expect(_n(sim, 'config_versions'), 2);
    expect(_n(live, 'config_versions'), 1);
    // 승인 기록(요청 · 결정 · 요청 저널) · 서약 전 판 · 편집 저널 = 모의 행 그대로.
    for (final (String t, String order) in <(String, String)>[
      ('rule_change_request', 'request_id'),
      ('rule_change_decision', 'request_id'),
      ('decision_journal', 'journal_id'),
      ('pledge', 'version'),
    ]) {
      expect(_rows(live, t, order), _rows(sim, t, order), reason: t);
    }
    expect(
      live
          .select('SELECT journal_id FROM decision_journal ORDER BY journal_id')
          .map((Row r) => r['journal_id']),
      <String>['J-PL2', 'J-RC1'],
    );
    // 🔴 실전 기동 — 개시 결정이 붙인 판 = 옮긴 승인 판 → approved 1 → SAF-405 통과.
    expect(startupConfigApprovalOf(live, RunMode.live), 1);
    expect(
      startupConfigGate(
        runMode: RunMode.live,
        approved: startupConfigApprovalOf(live, RunMode.live),
      ).start,
      isTrue,
    );
    final SqliteRuleChangeStore liveRc = SqliteRuleChangeStore(
      live,
      clock: clock,
      trusted: trusted,
    );
    expect(liveRc.approvedConfigHash(), approvedHash);
    expect(liveRc.startupGate(approvedHash, RunMode.live).start, isTrue);
    expect(liveRc.changelog().single.hashAfter, approvedHash);
    expect(liveRc.queue(), isEmpty);
    // 서약 = 실전 파일에서도 같은 지금 판(208 — DISCARD 가 모의 파일을 지워도 원문이 남는다).
    expect(
      SqlitePledgeStore(
        live,
        clock: clock,
        trusted: trusted,
      ).currentPledge()!.lines,
      <String>['하나', '둘', '넷'],
    );
  });

  test('🆕 R189 승인 config 없음 · 다른 판 승인 · 승인 기록 없는 approved = 거부 CONFIG_NOT_APPROVED · 쓰기 0 · 세션 그대로', () {
    void same(SimToAutoCommitOutcome o) {
      expect(o.reasonCode, SimToAutoCommitCodes.configNotApproved);
      expect(o.headline, contains('규칙 변경 승인'));
      expect(writes(), 0);
      expect(sessions.session(sessionId)!.closed, isFalse);
    }

    same(commit(carry: SimToAutoCarry.none));
    // 지금 설정 ≠ 승인 판.
    final String other =
        sim
                .select(
                  'SELECT config_hash FROM config_versions WHERE approved = 0',
                )
                .single['config_hash']!
            as String;
    same(commit(configHash: other));
    // 승인 기록 없이 approved 만 1(손으로 고친 원장) = 승인 아님.
    sim.execute(
      'UPDATE config_versions SET approved = CASE WHEN config_hash = ? THEN 1 ELSE 0 END',
      <Object?>[other],
    );
    final SimToAutoCarry forged = readSimToAutoCarry(sim);
    expect(forged.approvedConfigHash, isNull);
    expect(forged.of('config_versions'), isEmpty);
    expect(forged.of('pledge'), hasLength(2));
    same(commit(configHash: other, carry: forged));
    // 승인 기록 0(요청 · 결정 없음) · approved 1 = 승인 아님 · 승인 둘 = 원장 규칙 위반(StateError).
    final Directory d2 = Directory.systemTemp.createTempSync('r189_');
    final Database bare = openLocalLedger(
      d2.path,
      RunMode.simInternal,
      clock: () => _opened,
    );
    try {
      bare.execute(
        "INSERT INTO config_versions (config_hash, created_at, content, approved) VALUES ('h', 't', '{}', 1)",
      );
      expect(readSimToAutoCarry(bare).approvedConfigHash, isNull);
      bare.execute(
        "INSERT INTO config_versions (config_hash, created_at, content, approved) VALUES ('h2', 't', '{}', 1)",
      );
      expect(() => readSimToAutoCarry(bare), throwsStateError);
    } finally {
      bare.close();
      d2.deleteSync(recursive: true);
    }
    // 🔴 모의 파일만 읽는다 · 실전 파일 = StateError.
    expect(() => readSimToAutoCarry(live), throwsStateError);
  });

  test(
    '🆕 R189 실전 파일에 같은 지문 · 같은 내용이 이미 있음 = 그대로 두고 승인 1 · 다른 판 승인 = 0(승인 목록 하나)',
    () {
      final Row cfg = sim.select(
        'SELECT content, created_at FROM config_versions WHERE config_hash = ?',
        <Object?>[approvedHash],
      ).single;
      live.execute(
        'INSERT INTO config_versions (config_hash, created_at, content, approved) VALUES (?, ?, ?, 0)',
        <Object?>[approvedHash, cfg['created_at'], cfg['content']],
      );
      live.execute(
        "INSERT INTO config_versions (config_hash, created_at, content, approved) VALUES ('zz', 't', '{}', 1)",
      );
      final SimToAutoCommitOutcome o = commit();
      expect(o.ok, isTrue, reason: o.headline);
      expect(
        live
            .select(
              'SELECT config_hash, approved FROM config_versions ORDER BY config_hash',
            )
            .map((Row r) => '${r['config_hash']}=${r['approved']}'),
        <String>['$approvedHash=1', 'zz=0'],
      );
      expect(startupConfigApprovalOf(live, RunMode.live), 1);
    },
  );

  test('🆕 R189 옮김 충돌(실전 파일에 같은 지문 · 다른 내용) = 전부 되돌림 + 세션 ROLLED_BACK', () {
    live.execute(
      "INSERT INTO config_versions (config_hash, created_at, content, approved) VALUES (?, 't', 'x', 0)",
      <Object?>[approvedHash],
    );
    final SimToAutoCommitOutcome o = commit();
    expect(o.reasonCode, SimToAutoCommitCodes.rolledBack);
    expect(writes(), 1);
    expect(_n(live, 'config_versions', 'approved = 1'), 0);
    expect(
      sessions.session(sessionId)!.closeCode,
      HandoverCloseCode.rolledBack,
    );
    expect(
      () => writeSimToAutoCarryInTransaction(live, readSimToAutoCarry(sim)),
      throwsStateError,
      reason: '트랜잭션 밖',
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
    // 🆕 R189 — 옮긴 행도 되돌린다.
    expect(_n(live, 'config_versions'), 0);
    expect(_n(live, 'rule_change_request'), 0);
    expect(_n(live, 'decision_journal'), 0);
    expect(_n(live, 'pledge'), 0);
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
