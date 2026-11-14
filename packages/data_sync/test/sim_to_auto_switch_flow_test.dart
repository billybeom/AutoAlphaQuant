// 🆕 E15f4b2 — simToAuto 전환 흐름 끝까지(가짜 감시 + 실물 저장: 세션 → 커밋 → 마감 → 옛 멈춤 · 설계 13 §8 R106).

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
        P0sStrategyIds,
        RemoteCheck,
        RemoteCheckStatus,
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

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;
  late _Trusted trusted;
  late String sessionId;
  late FakeWatchdogRemote remote;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15f4b2_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _opened);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _opened);
    clock = _Clock(_commitAt);
    trusted = _Trusted(_opened);
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
    sim.close();
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
            configHash: 'cfg',
            lease: _lease,
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
