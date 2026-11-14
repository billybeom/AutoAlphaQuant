// 🆕 E15e1 — M1-22 관찰 판정 입력(실전 파일 원 기록 읽기 · 설계 13 §8 R89 AC2~AC5).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        JobRunEntry,
        JobRunStatus,
        LiveObservationBlock,
        LiveObservationConfig,
        LiveObservationFacts,
        LiveObservationReport,
        Market,
        frozenExchangeCalendar,
        judgeLiveObservation;
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

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

String _iso(DateTime t) => t.toUtc().toIso8601String();

final DateTime _commit = _k('2027-01-12', 15);
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15e1_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _commit);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _commit);
    clock = _Clock(_commit);
  });

  tearDown(() {
    live.close();
    sim.close();
    dir.deleteSync(recursive: true);
  });

  SqliteModeStore modes() =>
      SqliteModeStore(live, LedgerFile.live, clock: clock);

  void commitDryRun() => expect(
    modes().record(
      axis: ModeAxis.runMode,
      runMode: RunMode.live,
      execPolicy: ExecPolicy.dryRun,
      operatingMode: OperatingMode.autoTrade,
      handoverSessionValid: false,
      decisionId: 'D-LIVE',
    ),
    isNull,
  );

  Future<void> batch(
    String day, {
    String check = 'live-auto',
    String job = 'kr_order',
    JobRunStatus status = JobRunStatus.success,
  }) => SqliteJobRunLog(live).record(
    JobRunEntry(
      rid: '$check-$job-$day-${status.wire}',
      checkName: '$check-$job',
      sessionDay: TradeDate(day),
      startedAtUtc: _k(day, 9, 10),
      finishedAtUtc: _k(day, 9, 11),
      status: status,
    ),
  );

  void recon(String id, DateTime at, {required bool matched}) => live.execute(
    'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
    "VALUES (?, ?, ?, '[]', 'NONE')",
    <Object?>[id, _iso(at), matched ? 1 : 0],
  );

  void flag(String id) => live.execute(
    'INSERT INTO trading_block (flag_id, set_at, reason) '
    "VALUES (?, '2027-01-14T01:00:00Z', 'r')",
    <Object?>[id],
  );

  void unknownIntent(String id, String status) => live.execute(
    'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
    "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
    "'2027-01-13', 'KR', 'pension', 'P0S_B', 'B@2027-01-13', '133690', 'BUY', 'LIMIT', 1, ?, 'c', 'x', 'LIVE')",
    <Object?>[id, 'k-$id', status],
  );

  LiveObservationReport judge() => judgeLiveObservation(
    SqliteLiveObservationFacts(live, clock: clock).read(),
    kr: _kr,
    config: LiveObservationConfig(requiredTradingDays: 2),
  );

  test('🔴 실전 파일만 — 모의 원장으로는 만들지 않는다', () {
    expect(
      () => SqliteLiveObservationFacts(sim, clock: clock),
      throwsA(isA<StateError>()),
    );
  });

  test('커밋 전 = 모드 없음 · 관찰 중 아님', () async {
    final LiveObservationFacts f = await SqliteLiveObservationFacts(
      live,
      clock: clock,
    ).facts();
    expect(f.runMode, isNull);
    expect(f.execPolicy, isNull);
    expect(f.currentSinceUtc, isNull);
    expect(
      judgeLiveObservation(
        f,
        kr: _kr,
        config: LiveObservationConfig(requiredTradingDays: 2),
      ).observing,
      isFalse,
    );
  });

  test('원 기록 읽기 — 현재 행 · live-auto-kr_order 만 · rc- 만 · UNKNOWN · 킬스위치 · DST_WEEK 제외', () async {
    commitDryRun();
    await batch('2027-01-13');
    await batch('2027-01-14', status: JobRunStatus.late);
    await batch('2027-01-15', status: JobRunStatus.failed);
    await batch('2027-01-15', check: 'live-advisory');
    await batch('2027-01-15', check: 'sim-auto');
    await batch('2027-01-15', job: 'close');
    recon('rc-1', _k('2027-01-13', 9, 20), matched: true);
    recon('rc-clear-1', _k('2027-01-13', 9, 30), matched: false);
    recon('li-1', _k('2027-01-13', 9, 40), matched: false);
    unknownIntent('i1', 'UNKNOWN');
    unknownIntent('i2', 'SUBMITTED');
    flag(FlagIds.dstWeek);
    flag('RECON_MISMATCH');
    live.execute(
      "INSERT INTO kill_switch_state (id, activated_at, activated_by) VALUES (1, ?, 'app')",
      <Object?>[_iso(_k('2027-01-14', 10))],
    );
    final LiveObservationFacts f = SqliteLiveObservationFacts(
      live,
      clock: clock,
    ).read();
    expect(f.runMode, RunMode.live);
    expect(f.execPolicy, ExecPolicy.dryRun);
    expect(f.currentSinceUtc, _commit);
    expect(
      <(String, bool)>[for (final r in f.runs) (r.sessionDay, r.succeeded)],
      <(String, bool)>[
        ('2027-01-13', true),
        ('2027-01-14', true),
        ('2027-01-15', false),
      ],
    );
    expect(f.runs.first.startedAtUtc, _k('2027-01-13', 9, 10));
    expect(f.recons, hasLength(1));
    expect(f.recons.single.matched, isTrue);
    expect(f.recons.single.runAtUtc, _k('2027-01-13', 9, 20));
    expect(f.unknownOrders, 1);
    expect(f.killSwitchActive, isTrue);
    expect(f.blockingFlags, <String>['RECON_MISMATCH']);
  });

  test('시각에 시차가 없으면 FormatException', () {
    commitDryRun();
    live.execute(
      'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
      "VALUES ('rc-x', '2027-01-13T00:20:00', 1, '[]', 'NONE')",
    );
    expect(
      () => SqliteLiveObservationFacts(live, clock: clock).read(),
      throwsFormatException,
    );
  });

  test('갈래 A — 01-12 커밋 → 무결 이틀 → 승격 가능 · 막힘 · 승격 행 뒤 = 관찰 끝', () async {
    commitDryRun();
    for (final String d in <String>['2027-01-13', '2027-01-14']) {
      await batch(d);
      recon('rc-$d', _k(d, 9, 20), matched: true);
    }
    clock.at = _k('2027-01-13', 18);
    expect(judge().promotionLabel, '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)');
    clock.at = _k('2027-01-14', 18);
    final LiveObservationReport ok = judge();
    expect(ok.promotionAvailable, isTrue);
    expect(ok.vm!.progressText, '무결 거래일 2/2');

    unknownIntent('i1', 'UNKNOWN');
    expect(judge().block, LiveObservationBlock.unknownOrders);
    live.execute(
      "UPDATE order_intents SET status = 'FILLED' WHERE intent_id = 'i1'",
    );
    expect(judge().promotionAvailable, isTrue);

    // 승격(E15e2 가 쓸 행) — 현재 행 = live × execute → 관찰 끝.
    clock.at = _k('2027-01-14', 19);
    expect(
      modes().record(
        axis: ModeAxis.execPolicy,
        runMode: RunMode.live,
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        handoverSessionValid: false,
        decisionId: 'D-PROMO',
      ),
      isNull,
    );
    final LiveObservationReport after = judge();
    expect(after.observing, isFalse);
    expect(after.vm, isNull);
  });
}
