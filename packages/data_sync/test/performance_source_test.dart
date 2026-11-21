// E11q-q5b — M7 S7-2 시리즈 · S7-2G 게이트 · 열람 기록 원장 원천(설계 13 §8 R223) — 실 SQLite(모의 원장).
//
// 🔴 시리즈 = 계층 B 와 같은 점(입출금 = 수익 아님) → 엔진 · 무결성 = `LEDGER_INTEGRITY` 깃발 · 열람 기록 = `command_inbox` 한 행 ·
//    집계 = 접수 시각의 한국 달 · 무결성 점검 중 = 보류 행(집계에 든다).

import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
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

bool _weekday(String ymd) =>
    DateTime.parse('${ymd}T00:00:00Z').weekday <= DateTime.friday;

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('r221_');
    clock = _Clock(DateTime.utc(2026, 8, 5, 9)); // 한국 08-05 18:00
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => clock.at);
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqlitePerformanceSource src() => SqlitePerformanceSource(db, clock: clock);

  void snap(String day, double equity) => db.execute(
    'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
    "VALUES (?, ?, ?, 0, ?, 0, 'SIM_INTERNAL')",
    <Object?>[day, equity, equity, equity],
  );

  void deposit(String day, double amount) => db.execute(
    'INSERT INTO cash_flow(flow_id, trade_date, kind, amount, currency, note) '
    "VALUES (?, ?, 'DEPOSIT', ?, 'KRW', 'it')",
    <Object?>['f-$day', day, amount],
  );

  void integrity() => db.execute(
    "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-08-05T00:00:00.000Z', 'x')",
  );

  DisclosureViewCommand cmd(int seed) => DisclosureViewCommand.issue(
    event: DisclosureViewEvent(
      surfaceCode: DisclosureSurfaceCodes.performanceExplore,
      viewedAt: clock.at,
    ),
    deviceId: 'dev',
    nowUtc: clock.at,
    random: Random(seed),
  );

  CommandReceipt view(int seed) => src().record(
    cmd(seed),
    runMode: RunMode.simInternal,
    operatingMode: OperatingMode.autoTrade,
    leaseEpoch: 3,
  );

  PerformanceSeries daily() => src().series(
    metric: PerfMetric.twr,
    granularity: PerfGranularity.daily,
    cumulative: true,
    isSession: _weekday,
  );

  group('시리즈', () {
    test('원장 스냅숏 → 엔진과 같은 값 · 입금 = 수익 아님 · 열람 수 = 같은 원장', () {
      snap('2026-08-03', 100);
      snap('2026-08-04', 150);
      deposit('2026-08-04', 50);
      snap('2026-08-05', 153);
      view(1);
      final PerformanceSeries s = daily();
      expect(s.points.map((PerfPoint p) => p.valueText).toList(), <String>[
        '0.00%',
        '0.00%',
        '2.00%',
      ]);
      expect(
        s,
        performanceSeriesOf(
          metric: PerfMetric.twr,
          granularity: PerfGranularity.daily,
          cumulative: true,
          equity: tierBSeries(db, '2026-08-05'),
          isSession: _weekday,
          nowUtc: clock.at,
          viewCountThisMonth: 1,
          integrityHidden: false,
        ),
      );
      expect(s.disclosure.viewCountThisMonth, 1);
    });

    test('스냅숏 0 = 문장 카드 · 무결성 점검 중 = 가림', () {
      expect(daily().unavailableLabel, PerfSeriesTexts.noSnapshot);
      snap('2026-08-03', 100);
      snap('2026-08-04', 101);
      expect(daily().points, hasLength(2));
      integrity();
      final PerformanceSeries masked = daily();
      expect(masked.points, isEmpty);
      expect(masked.unavailableLabel, PerfSeriesTexts.integrityMasked);
    });
  });

  group('게이트 · 열람 기록', () {
    test('0회 = 열림 · 마찰 0 → 기록 2건 = «2번» · 기록 고지 · 행 = 종류 · 상태 · 맥락 · 지문', () {
      expect(
        src().gate(),
        disclosureGateVmOf(
          viewCountThisMonth: 0,
          integrityHidden: false,
          nowUtc: clock.at,
        ),
      );
      final CommandReceipt a = view(1);
      final CommandReceipt b = view(2);
      expect(a.state, CommandState.executed);
      expect(a.stateLabel, DisclosureGateTexts.recorded);
      expect(a.commandId, isNot(b.commandId));
      final DisclosureGateVm g = src().gate();
      expect(g.viewCountText, '이번 달 2번 열어 보셨습니다');
      expect(g.frictionLine, DisclosureGateTexts.friction);
      final Row r = db.select(
        'SELECT * FROM command_inbox WHERE command_id = ?',
        <Object?>[a.commandId],
      ).single;
      expect(r['kind'], 'DISCLOSURE_VIEW');
      expect(r['state'], 'EXECUTED');
      expect(r['state_label'], DisclosureGateTexts.recorded);
      expect(r['run_mode'], 'SIM_INTERNAL');
      expect(r['operating_mode'], 'AUTO_TRADE');
      expect(r['lease_epoch'], 3);
      expect(r['payload_digest'], cmd(1).payloadDigest);
    });

    test('집계 = 접수 시각의 한국 달 — 달이 바뀌면 0부터 · 다른 종류 명령은 세지 않는다', () {
      view(1);
      db.execute(
        'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, payload_digest) '
        "VALUES ('x', 'ALERT_ACK', ?, 'EXECUTED', '실행됨', 'd')",
        <Object?>[clock.at.toIso8601String()],
      );
      expect(src().disclosureViews('2026-08'), 1);
      clock.at = DateTime.utc(2026, 8, 31, 15); // 한국 09-01 00:00
      view(2);
      expect(src().disclosureViews('2026-08'), 1);
      expect(src().disclosureViews('2026-09'), 1);
      expect(src().gate().viewCountText, '이번 달 1번 열어 보셨습니다');
    });

    test('무결성 점검 중 = 게이트 닫힘 · 기록 = 보류 행(집계에 든다)', () {
      integrity();
      final DisclosureGateVm g = src().gate();
      expect(g.gateOpen, isFalse);
      expect(g.headline, DisclosureGateTexts.closedHeadline);
      final CommandReceipt h = view(1);
      expect(h.state, CommandState.heldForIntegrity);
      expect(h.stateLabel, DisclosureGateTexts.held);
      expect(
        db.select('SELECT state FROM command_inbox').single['state'],
        'HELD_FOR_INTEGRITY',
      );
      expect(src().disclosureViews('2026-08'), 1);
    });

    test('감시 표 = 시리즈 · 게이트 원천 다섯', () {
      expect(SqlitePerformanceSource.watchedTables, <String>{
        'equity_snapshot',
        'cash_flow',
        'decision_log',
        'command_inbox',
        'trading_block',
      });
    });
  });
}
