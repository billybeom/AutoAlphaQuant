// 🆕 E15f4b2 — simToAuto 전환 흐름 끝까지(가짜 감시 + 실물 저장: 세션 → 커밋 → 마감 → 옛 멈춤 · 설계 13 §8 R106).
// 🆕 R189 — 모의 파일 첫 승인 · 서약 → 커밋이 실전 파일로 옮김 → S5 DISCARD 로 모의 파일을 지워도 실전 기동(SAF-405) · 서약.

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HandoverCloseCode,
        LeaseSnapshot,
        LeaseVerdict,
        LiveAccountProbe,
        LiveObservationConfig,
        Market,
        ModeRowFacts,
        P0sStrategyIds,
        RemoteCheck,
        RemoteCheckStatus,
        RuleChangeType,
        SimLedgerDeleteResult,
        SimLedgerFate,
        SimToAutoCommitCodes,
        SimToAutoFacts,
        SimToAutoSwitchCommit,
        SimToAutoSwitchResult,
        SimToAutoSwitchStage,
        SimTrialCounters,
        SimTrialItemResult,
        SimTrialReport,
        TrustedClock,
        WatchdogCheckSpec,
        frozenExchangeCalendar,
        kSimToAutoWatchdogPrepareFailed,
        modeStartupGate,
        runSimToAutoSwitch;
import 'package:core_engine/testing.dart' show FakeWatchdogRemote;
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

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final LiveObservationConfig _two = LiveObservationConfig(
  requiredTradingDays: 2,
);
final DateTime _opened = _k('2027-01-12', 10);
final DateTime _commitAt = _k('2027-01-13', 11);

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
    P0sStrategyIds.sleeveB: 'general',
    P0sStrategyIds.sleeveC: 'general',
    P0sStrategyIds.pot: 'general',
  },
  fate: SimLedgerFate.keep,
  sessionOpenedAtUtc: null,
  killSwitchActive: false,
  blockingFlags: const <String>[],
);

const LeaseSnapshot _lease = LeaseSnapshot(
  verdict: LeaseVerdict.valid,
  epoch: 1,
  deviceId: 'device-1',
);

WatchdogCheckSpec _spec(String slug) => WatchdogCheckSpec(
  slug: slug,
  grace: const Duration(hours: 1),
  cron: '10 9 * * 1-5',
);

int _n(Database db, String table, [String where = '1=1']) =>
    db.select('SELECT COUNT(*) AS n FROM $table WHERE $where').first['n']!
        as int;

/// 🆕 R189 — 모의 파일에 서약 첫 판 · 첫 승인(요청 12-01 → 냉각 30일 → 승인 01-02)을 실물 경로로 → 승인 판 지문.
String _seedApproval(Database sim, _Clock clock, _Trusted trusted) {
  final String hash = SqliteConfigVersionStore(
    sim,
    clock: clock,
  ).register(<String, Object?>{'spec': 'r189-flow'});
  trusted.at = _k('2026-11-25', 9);
  expect(
    SqlitePledgeStore(sim, clock: clock, trusted: trusted)
        .writeFirst(
          commandId: 'pw-1',
          payloadDigest: 'dg',
          sentences: const <String>['하나', '둘', '셋'],
          decisionId: 'ON-1',
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
  return hash;
}

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late bool simOpen;
  late _Clock clock;
  late _Trusted trusted;
  late String sessionId;
  late String approvedHash;
  late FakeWatchdogRemote remote;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15f4b2_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _opened);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _opened);
    simOpen = true;
    clock = _Clock(_commitAt);
    trusted = _Trusted(_opened);
    approvedHash = _seedApproval(sim, clock, trusted);
    trusted.at = _opened;
    SqliteModeStore(sim, LedgerFile.sim, clock: clock).record(
      axis: ModeAxis.runMode,
      runMode: RunMode.simInternal,
      execPolicy: ExecPolicy.execute,
      operatingMode: OperatingMode.autoTrade,
      handoverSessionValid: false,
      decisionId: 'D-SIM',
    );
    expect(
      SqliteSimLedgerFateStore(
        sim,
        clock: clock,
      ).choose(SimLedgerFate.keep, configHash: 'c'),
      isNull,
    );
    final HandoverSessionOutcome o =
        SqliteHandoverSessionStore(
          live,
          clock: clock,
          trusted: trusted,
        ).openSimToAuto(
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
    remote = FakeWatchdogRemote(
      initial: <RemoteCheck>[
        const RemoteCheck(
          slug: 'sim-auto-kr_order',
          status: RemoteCheckStatus.up,
        ),
        const RemoteCheck(
          slug: 'sim-auto-engine_alive',
          status: RemoteCheckStatus.up,
        ),
      ],
    );
  });

  tearDown(() {
    live.close();
    if (simOpen) sim.close();
    dir.deleteSync(recursive: true);
  });

  Future<SimToAutoSwitchResult> run({int holdings = 0}) => runSimToAutoSwitch(
    remote: remote,
    newSpecs: <WatchdogCheckSpec>[_spec('live-auto-kr_order')],
    newPrefix: 'live-auto',
    oldPrefix: 'sim-auto',
    commit: () async {
      final SimToAutoCommitOutcome c =
          SqliteSimToAutoCommitStore(
            live,
            clock: clock,
            trusted: trusted,
          ).commit(
            sessionId: sessionId,
            simFacts: _facts,
            kr: _kr,
            observation: _two,
            probes: <LiveAccountProbe>[
              LiveAccountProbe(
                alias: 'general',
                holdingsCount: holdings,
                orderableCashKrw: 1000000,
                activityToday: 0,
                fetchedAtUtc: _commitAt.subtract(const Duration(minutes: 1)),
              ),
            ],
            configHash: approvedHash,
            lease: _lease,
            // 🆕 R189 — 커밋 직전에 모의 파일에서 읽는다(쓰기 = 실전 커밋 트랜잭션 안).
            carry: readSimToAutoCarry(sim),
          );
      return c.ok
          ? SimToAutoSwitchCommit.ok(c.decisionId!, c.headline)
          : SimToAutoSwitchCommit.no(c.reasonCode!, c.headline);
    },
    finish: () async {
      finishSimToAuto(liveDb: live, simDb: sim, clock: clock);
    },
  );

  test('끝까지 — 새 체크 → 실전 커밋 → 모의 CLOSE → 옛 체크(엔진 생존 포함) 멈춤', () async {
    final SimToAutoSwitchResult x = await run();
    expect(x.committed, isTrue, reason: x.headline);
    expect(x.stage, SimToAutoSwitchStage.done);
    expect(x.decisionId, 'LIVEOPEN-20270113-110000');
    expect(x.pendingPauses, isEmpty);
    expect(x.finishPending, isFalse);
    expect(_n(live, 'mode_transition', "mode = 'LIVE'"), 1);
    expect(_n(sim, 'mode_transition', "axis = 'CLOSE'"), 1);
    expect(
      SqliteHandoverSessionStore(
        live,
        clock: clock,
        trusted: trusted,
      ).session(sessionId)!.closeCode,
      HandoverCloseCode.committed,
    );
    expect(remote.store['live-auto-kr_order']!.status, RemoteCheckStatus.fresh);
    expect(remote.store['sim-auto-kr_order']!.status, RemoteCheckStatus.paused);
    expect(
      remote.store['sim-auto-engine_alive']!.status,
      RemoteCheckStatus.paused,
    );
  });

  test(
    '🆕 R189 S5 DISCARD — 모의 파일을 지워도 실전 파일에 승인 판 · 승인 기록 · 서약 · 실전 기동 게이트 통과',
    () async {
      expect(
        SqliteSimLedgerFateStore(
          sim,
          clock: clock,
        ).choose(SimLedgerFate.discard, configHash: approvedHash),
        isNull,
      );
      final SimToAutoSwitchResult x = await run();
      expect(x.committed, isTrue, reason: x.headline);
      expect(x.finishPending, isFalse);
      sim.close();
      simOpen = false;
      expect(
        deleteClosedSimLedger(dir.path, clock: clock),
        SimLedgerDeleteResult.deleted,
      );
      expect(
        File('${dir.path}/${LedgerFile.sim.fileName}').existsSync(),
        isFalse,
      );
      // 실전 파일 — 서약 원문 · 승인 판 · 승인 기록이 남는다.
      expect(
        SqlitePledgeStore(
          live,
          clock: clock,
          trusted: trusted,
        ).currentPledge()!.lines,
        <String>['하나', '둘', '셋'],
      );
      final SqliteRuleChangeStore rc = SqliteRuleChangeStore(
        live,
        clock: clock,
        trusted: trusted,
      );
      expect(rc.approvedConfigHash(), approvedHash);
      expect(rc.changelog().single.decisionId, 'J-RC1');
      // 🔴 실전 기동 판정 — SAF-405 통과(조합 = live × dryRun × 자동 매매 · 세션 밖).
      final int? approved = startupConfigApprovalOf(live, RunMode.live);
      expect(approved, 1);
      final ModeRowFacts? row = SqliteModeStore(
        live,
        LedgerFile.live,
        clock: clock,
      ).current();
      expect(
        modeStartupGate(
          runMode: row!.runMode,
          operatingMode: OperatingMode.autoTrade,
          execPolicy: row.execPolicy,
          handoverSessionValid: false,
          approved: approved,
          credentialEnvironmentOk: true,
          liveKeysVerified: true,
        ).triggered,
        isEmpty,
      );
    },
  );

  test('🆕 R189 승인 config 없는 모의 파일 = 커밋 거부 CONFIG_NOT_APPROVED · 실전 쓰기 0 · 옛 체크 그대로 · 마감 0', () async {
    sim.execute('UPDATE config_versions SET approved = 0');
    final SimToAutoSwitchResult x = await run();
    expect((x.committed, x.stage), (false, SimToAutoSwitchStage.commit));
    expect(x.code, SimToAutoCommitCodes.configNotApproved);
    expect(x.headline, contains('규칙 변경 승인'));
    expect(_n(live, 'mode_transition'), 0);
    expect(_n(live, 'config_versions'), 0);
    expect(_n(live, 'pledge'), 0);
    expect(_n(sim, 'mode_transition', "axis = 'CLOSE'"), 0);
    expect(remote.store['sim-auto-kr_order']!.status, RemoteCheckStatus.up);
  });

  test('준비 실패 = 실전 쓰기 0 · 세션 열린 채 · 모의 그대로', () async {
    remote.failOn[('ensure', '*')] = Exception('down');
    final SimToAutoSwitchResult x = await run();
    expect((x.committed, x.code), (false, kSimToAutoWatchdogPrepareFailed));
    expect(_n(live, 'mode_transition'), 0);
    expect(_n(live, 'decision_log'), 0);
    expect(_n(sim, 'mode_transition', "axis = 'CLOSE'"), 0);
    expect(
      SqliteHandoverSessionStore(
        live,
        clock: clock,
        trusted: trusted,
      ).session(sessionId)!.closed,
      isFalse,
    );
    expect(remote.store['sim-auto-kr_order']!.status, RemoteCheckStatus.up);
  });

  test('커밋 게이트 거부(보유 있음) = 그 코드 · 실전 쓰기 0 · 옛 체크 그대로 · 마감 0', () async {
    final SimToAutoSwitchResult x = await run(holdings: 2);
    expect(x.committed, isFalse);
    expect(x.stage, SimToAutoSwitchStage.commit);
    expect(x.code, SimToAutoCommitCodes.holdingsNotZero);
    expect(_n(live, 'mode_transition'), 0);
    expect(_n(sim, 'mode_transition', "axis = 'CLOSE'"), 0);
    expect(remote.store['sim-auto-kr_order']!.status, RemoteCheckStatus.up);
  });
}
