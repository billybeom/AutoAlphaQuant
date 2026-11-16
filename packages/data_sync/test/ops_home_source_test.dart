// E11p3d-2b — H-01 오늘 요약 · H-02 운영 리듬 사실 모음(설계 13 §8 R133) — 실 SQLite(로컬 원장 스키마).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show ExchangeCalendar, Market, TrustedClock, frozenExchangeCalendar;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        Clock,
        ListResult,
        OperatingMode,
        OpsDailySummary,
        OpsRhythmRow,
        RunMode,
        TradeDate;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

// 한국 2026-08-31(월말 세션) 09:30.
final DateTime _t0 = DateTime.utc(2026, 8, 31, 0, 30);
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_opshome_');
    clock = _Clock(_t0);
    trusted = _Trusted(null);
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => clock.now);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteOpsHomeSource src({OperatingMode op = OperatingMode.autoTrade}) =>
      SqliteOpsHomeSource(
        db,
        clock: clock,
        trusted: trusted,
        kr: _kr,
        runMode: RunMode.simInternal,
        operatingMode: op,
      );

  int n = 0;
  void intent(String day, String status) {
    n++;
    db.execute(
      'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
      "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
      "?, 'KR', 'main', 'P0S_A', ?, 'A1', 'BUY', 'LIMIT', 30, ?, 'c', 'x', ?)",
      <Object?>[
        'i$n',
        'k$n',
        day,
        'D$n@$day',
        status,
        RunMode.simInternal.wire,
      ],
    );
  }

  void job(String check, String day, String status, String finished) {
    n++;
    db.execute(
      'INSERT INTO job_run (rid, check_name, session_day, started_at, finished_at, status) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>['r$n', check, day, finished, finished, status],
    );
  }

  test('🔴 빈 원장 = 0건 · 0건 · 신뢰 시각 모름 · X2 한 줄 없음 · 기준 = 지금', () {
    final OpsDailySummary s = src().today();
    expect(s.todayOrdersText, '오늘 주문 0건');
    expect(s.todayErrorsText, '오늘 오류 0건');
    expect(s.discretionBudgetText, '재량 예산 — 신뢰 시각 확인 중');
    expect(s.resumeLine, isNull);
    expect(s.asOf.observedAt, _t0);
    expect(s.nextRebalanceDDayText, 'D-1');
  });

  test('🔴 주문 = 오늘(KST 거래일) 7단계를 지난 의도만(SAF-401 셈) · 다른 날 · 예약 · 건너뜀(DRY_RUN) = 안 센다', () {
    intent('2026-08-31', 'SUBMITTED');
    intent('2026-08-31', 'FILLED');
    intent('2026-08-31', 'RESERVED');
    intent('2026-08-31', 'SKIPPED');
    intent('2026-08-28', 'SUBMITTED');
    expect(src().today().todayOrdersText, '오늘 주문 2건');
    expect(
      SqliteOrderLedger(
        db,
        mode: RunMode.simInternal,
        clock: clock,
        kr: _kr,
      ).ordersOn(const TradeDate('2026-08-31')),
      2,
    );
  });

  test('🔴 오류 = 오늘 세션 · 이 모드 접두 · FAILED 만(LATE · 다른 모드 · 어제 = 안 센다)', () {
    job('sim-auto-kr_order', '2026-08-31', 'FAILED', '2026-08-31T00:12:00Z');
    job(
      'sim-auto-daily_reconcile',
      '2026-08-31',
      'LATE',
      '2026-08-31T00:13:00Z',
    );
    job(
      'sim-advisory-kr_order',
      '2026-08-31',
      'FAILED',
      '2026-08-31T00:14:00Z',
    );
    job('live-auto-kr_order', '2026-08-31', 'FAILED', '2026-08-31T00:15:00Z');
    job('sim-auto-kr_order', '2026-08-28', 'FAILED', '2026-08-28T00:12:00Z');
    expect(src().today().todayErrorsText, '오늘 오류 1건');
    expect(src(op: OperatingMode.advisory).today().todayErrorsText, '오늘 오류 1건');
  });

  test('🔴 기준 = 이 모드의 마지막 잡 기록 끝 시각(다른 모드 기록은 안 본다)', () {
    job('sim-auto-kr_order', '2026-08-28', 'SUCCESS', '2026-08-28T00:12:00Z');
    job(
      'sim-advisory-kr_order',
      '2026-08-31',
      'SUCCESS',
      '2026-08-31T00:20:00Z',
    );
    final SqliteOpsHomeSource s = src();
    expect(s.lastActivityUtc(), DateTime.utc(2026, 8, 28, 0, 12));
    expect(s.today().asOf.label, '운영 홈 기준 2026-08-28');
    expect(s.rhythm().asOf.label, '운영 리듬 기준 2026-08-28');
    expect(
      src(op: OperatingMode.advisory).lastActivityUtc(),
      DateTime.utc(2026, 8, 31, 0, 20),
    );
  });

  test('🔴 재량 예산 = 엔진 저장소 셈(신뢰 시각 있으면 12개월 4회 문장)', () {
    trusted.at = _t0;
    expect(src().today().discretionBudgetText, '재량 예산 12개월 4회 중 0회 사용');
  });

  test('🔴 X2 한 줄 = 재개 상태 원천 그대로(마지막 성공 거래일 · 대기 작업)', () {
    job(
      'sim-auto-equity_snapshot',
      '2026-08-27',
      'SUCCESS',
      '2026-08-27T07:00:00Z',
    );
    final OpsDailySummary s = src().today();
    expect(s.resumeLine?.deepLink, AppRoutes.x2ResumeReport);
    expect(
      s.resumeLine?.label,
      SqliteResumeStatus(
        db,
        kr: _kr,
      ).resumeLine(const TradeDate('2026-08-31'))?.label,
    );
  });

  test('🔴 리듬 = 원천 있는 둘 · 오늘 요약 upcoming 과 같은 값', () {
    final SqliteOpsHomeSource s = src();
    final ListResult<OpsRhythmRow> r = s.rhythm();
    expect(r.rows.map((OpsRhythmRow x) => x.code).toList(), <String>[
      'MONTHLY_REBALANCE',
      'MONTHLY_CONTRIBUTION',
    ]);
    expect(s.today().upcoming, r.rows.take(3).toList());
  });

  test('감시 표 = 주문 · 잡 · 재량 · 재개 대기 작업', () {
    expect(SqliteOpsHomeSource.watchedTables, <String>{
      'order_intents',
      'job_run',
      'discretion_adjustment',
      'planned_work',
    });
  });
}
