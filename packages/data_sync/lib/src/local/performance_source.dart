// 🆕 E11q-q5b — M7 `S7-2` 성과 탐색 시리즈 · `S7-2G` 열람 게이트 · 열람 기록의 원장 원천(설계 13 §8 R223) ·
// 🆕 E11q-q5c `S7-3` 드로다운 맥락(같은 점 · R226) · 🆕 E11q-q5c2 `S7-3b` 슬리브 기여(같은 점 + 슬리브 손익 재구성 · R228).
//
// 🔴 시리즈 = 계층 B · 월간 리포트와 같은 점(`tierBSeries` — 개시 뒤 마감 스냅숏 + 그 사이 입출금) → 엔진 `performanceSeriesOf`.
// 🔴 무결성 가림 = `LEDGER_INTEGRITY` 깃발(풀리지 않은 차단) — 보유 · 일지와 같은 판정.
// 🔴 열람 기록 = `command_inbox` 한 행(kind `DISCLOSURE_VIEW` · append-only · 지문만) · 집계 = 접수 시각의 한국 달(G-42 —
//    화면이 넣은 `viewedAt` 아님) · 무결성 점검 중 = «보류됨» 행(보관 — 열람은 일어났다 · 집계에 든다).
// 🔴 기여 = 같은 점 + 지금 KR 보유(`positions`) + KR 브로커 체결(집행일 = 주문 의도의 거래일 · 포지션 재생과 같은 범위) +
//    원가 종가(`close_unadj` — 마감 평가 잡과 같은 열) → 엔진 `contributionVmOf`. 원장 사건(분배금 · 원천징수 · 단주 대금 ·
//    기업행위 · 수기 체결)은 날 · 종류만 넘긴다(귀속 규칙 전 — 엔진이 «산출 불가»로 정직하게).

import 'package:core_engine/core_engine.dart'
    show
        ContributionEvent,
        ContributionEventKind,
        ContributionFill,
        DisclosureViewCommand,
        EquityPoint,
        LedgerHolding,
        contributionVmOf,
        disclosureGateVmOf,
        disclosureMonthOf,
        drawdownContextVmOf,
        kstDateText,
        performanceSeriesOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        CommandKind,
        CommandReceipt,
        ContributionVm,
        DateRange,
        DisclosureGateVm,
        DrawdownContextVm,
        FillKind,
        FlagIds,
        OperatingMode,
        OrderSide,
        PerfGranularity,
        PerfMetric,
        PerformanceSeries,
        RunMode;
import 'package:sqlite3/sqlite3.dart' show Database, Row;

import '../jobs/tier_b_step.dart' show tierBSeries;

/// 원장 무결성 점검 중인가(`LEDGER_INTEGRITY` 풀리지 않은 차단) — 🆕 R231 월간 리포트도 같은 판정.
bool ledgerIntegrityHidden(Database db) => db.select(
  'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
  <Object?>[FlagIds.ledgerIntegrity],
).isNotEmpty;

/// [yyyyMm](한국 달) 열람 기록 수 — 접수 시각 기준(G-42) · 🆕 R231 월간 리포트 «이번 달 n번»도 같은 셈(미결 209 ⓔ-3).
int ledgerDisclosureViewsOf(Database db, String yyyyMm) {
  int n = 0;
  for (final Row r in db.select(
    'SELECT ingested_at FROM command_inbox WHERE kind = ?',
    <Object?>[CommandKind.disclosureView.wire],
  )) {
    final DateTime? at = DateTime.tryParse(r['ingested_at'] as String);
    if (at != null && disclosureMonthOf(at.toUtc()) == yyyyMm) n++;
  }
  return n;
}

/// 성과 탐색 · 열람 게이트 원천(같은 원장 한 파일).
class SqlitePerformanceSource {
  /// 만든다.
  SqlitePerformanceSource(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 시리즈 · 게이트가 읽는 표(원장 변경 감시).
  static const Set<String> watchedTables = <String>{
    'equity_snapshot',
    'cash_flow',
    'decision_log',
    'command_inbox',
    'trading_block',
  };

  /// 개시 뒤 마감 스냅숏(오늘까지).
  List<EquityPoint> equity(String today) => tierBSeries(_db, today);

  /// 원장 무결성 점검 중인가.
  bool integrityHidden() => ledgerIntegrityHidden(_db);

  /// [yyyyMm](한국 달) 열람 기록 수 — 접수 시각 기준.
  int disclosureViews(String yyyyMm) => ledgerDisclosureViewsOf(_db, yyyyMm);

  /// `S7-2G` 게이트.
  DisclosureGateVm gate() {
    final DateTime now = _clock.nowUtc();
    return disclosureGateVmOf(
      viewCountThisMonth: disclosureViews(disclosureMonthOf(now)),
      integrityHidden: integrityHidden(),
      nowUtc: now,
    );
  }

  /// 🆕 E11q-q5c — `S7-3` 드로다운 맥락(같은 점 · 운용 전체) — [isSession] = 한국 세션(결측 셈).
  DrawdownContextVm drawdownContext({
    required bool Function(String ymd) isSession,
  }) {
    final DateTime now = _clock.nowUtc();
    return drawdownContextVmOf(
      equity: equity(kstDateText(now)),
      isSession: isSession,
      nowUtc: now,
      integrityHidden: integrityHidden(),
    );
  }

  /// 🆕 E11q-q5c2 — `S7-3b` 슬리브 기여([range] = 셸이 넘긴 엔진 기본 구간 · 같은 점 + 슬리브 손익 재구성).
  ContributionVm contribution({required DateRange range}) {
    final List<EquityPoint> eq = equity(range.to.yyyyMmDd);
    final String after = eq.isEmpty ? '' : eq.first.date;
    final List<LedgerHolding> held = <LedgerHolding>[
      for (final Row r in _db.select(
        "SELECT strategy_id, symbol, quantity FROM positions WHERE market = 'KR' AND quantity != 0 "
        'ORDER BY strategy_id, symbol',
      ))
        LedgerHolding(
          r['strategy_id'] as String,
          r['symbol'] as String,
          r['quantity'] as int,
        ),
    ];
    final List<ContributionFill> fills = <ContributionFill>[
      for (final Row r in _db.select(
        'SELECT i.strategy_id, i.symbol, i.trade_date, i.side, e.fill_kind, e.quantity, e.price, '
        'e.commission, e.tax FROM executions e '
        'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
        'JOIN order_intents i ON i.intent_id = b.intent_id '
        "WHERE i.market = 'KR' AND i.trade_date > ? ORDER BY i.trade_date, e.rowid",
        <Object?>[after],
      ))
        ContributionFill(
          strategyId: r['strategy_id'] as String,
          symbol: r['symbol'] as String,
          tradeDate: r['trade_date'] as String,
          side: OrderSide.values.firstWhere(
            (OrderSide s) => s.wire == r['side'],
          ),
          kind: FillKind.values.firstWhere(
            (FillKind k) => k.wire == r['fill_kind'],
          ),
          quantity: r['quantity'] as int,
          price: (r['price'] as num).toDouble(),
          commission: (r['commission'] as num).toDouble(),
          tax: (r['tax'] as num).toDouble(),
        ),
    ];
    final Set<String> symbols = <String>{
      for (final LedgerHolding h in held) h.symbol,
      for (final ContributionFill f in fills) f.symbol,
    };
    final Map<String, Map<String, double>> closes =
        <String, Map<String, double>>{};
    for (final String s in symbols.toList()..sort()) {
      for (final Row r in _db.select(
        "SELECT trade_date, close_unadj FROM daily_prices WHERE market = 'KR' AND symbol = ? "
        'AND trade_date >= ? AND trade_date <= ? AND close_unadj > 0',
        <Object?>[s, after, range.to.yyyyMmDd],
      )) {
        (closes[s] ??= <String, double>{})[r['trade_date'] as String] =
            (r['close_unadj'] as num).toDouble();
      }
    }
    return contributionVmOf(
      range: range,
      equity: eq,
      holdingsNow: held,
      fills: fills,
      closes: closes,
      events: _contributionEvents(after),
      nowUtc: _clock.nowUtc(),
      integrityHidden: integrityHidden(),
    );
  }

  /// 귀속 규칙 전 원장 사건([after] 뒤 — 창은 엔진이 거른다).
  List<ContributionEvent> _contributionEvents(
    String after,
  ) => <ContributionEvent>[
    for (final Row r in _db.select(
      'SELECT trade_date, kind FROM cash_flow '
      "WHERE kind IN ('DISTRIBUTION', 'TAX_WITHHELD', 'CASH_IN_LIEU') AND trade_date > ?",
      <Object?>[after],
    ))
      ContributionEvent(r['trade_date'] as String, switch (r['kind']
          as String) {
        'DISTRIBUTION' => ContributionEventKind.distribution,
        'TAX_WITHHELD' => ContributionEventKind.taxWithheld,
        _ => ContributionEventKind.cashInLieu,
      }),
    for (final Row r in _db.select(
      "SELECT effective_date FROM ledger_event WHERE kind = 'CORPORATE_ACTION' AND effective_date > ?",
      <Object?>[after],
    ))
      ContributionEvent(
        r['effective_date'] as String,
        ContributionEventKind.corporateAction,
      ),
    for (final Row r in _db.select(
      "SELECT executed_at FROM executions WHERE fill_origin = 'MANUAL'",
    ))
      ContributionEvent(switch (DateTime.tryParse(r['executed_at'] as String)) {
        final DateTime at => kstDateText(at.toUtc()),
        null => (r['executed_at'] as String).substring(0, 10),
      }, ContributionEventKind.manualFill),
  ];

  /// `S7-2` 시리즈 — [isSession] = 한국 세션.
  PerformanceSeries series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    required bool Function(String ymd) isSession,
  }) {
    final DateTime now = _clock.nowUtc();
    return performanceSeriesOf(
      metric: metric,
      granularity: granularity,
      cumulative: cumulative,
      equity: equity(kstDateText(now)),
      isSession: isSession,
      nowUtc: now,
      viewCountThisMonth: disclosureViews(disclosureMonthOf(now)),
      integrityHidden: integrityHidden(),
    );
  }

  /// 열람 기록 한 행 — 무결성 점검 중 = 보류(보관) · 그 밖 = 기록됨 · 접수증 글자 = 남긴 글자 그대로.
  CommandReceipt record(
    DisclosureViewCommand c, {
    required RunMode runMode,
    required OperatingMode operatingMode,
    int? leaseEpoch,
  }) {
    final CommandReceipt receipt = c.receipt(held: integrityHidden());
    _db.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
      'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
      'VALUES (?, ?, ?, ?, ?, NULL, NULL, ?, ?, ?, ?)',
      <Object?>[
        c.commandId,
        CommandKind.disclosureView.wire,
        _clock.nowUtc().toUtc().toIso8601String(),
        receipt.state.wire,
        receipt.stateLabel,
        runMode.wire,
        operatingMode.wire,
        leaseEpoch,
        c.payloadDigest,
      ],
    );
    return receipt;
  }
}
