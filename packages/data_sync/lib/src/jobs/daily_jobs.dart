// 아침 · 저녁 잡 본체 넷 — `daily_data` · `us_data` · `daily_signal` · `equity_snapshot`(설계 13 §8 R47 F2~F9 · 🆕 06 M1-28 · 01 §10).
//
// 🔴 본체만이다 — 핑 · 휴장 · 예외 → fail 핑은 trading_runtime `runJob` 이 한다. 조립 앱이 `runJob(body: (d) => job.run(d))` 로
//    감싸고 보고의 [DailyJobReport.alerts] 를 `JobBody` 알림으로 넘긴다(trading_runtime ↛ data_sync — R42 S2).
// 🔴 수집 실패는 잡을 실패시키지 않는다 — 나머지를 모으고 P1 `DATA_SOURCE_DOWN` 코드를 싣는다(결측은 `data_gap` 이 말한다).
// 🔴 `equity_snapshot` 은 소급 불가라 **틀린 값을 쓰지 않는다** — 종가 · 현금을 못 얻으면 쓰지 않고 던진다(늦은 끝까지 재시도).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../market/fetch_log.dart' show FetchOutcome;
import '../market/gap_store.dart';
import '../market/macro_collector.dart';
import '../market/market_store.dart';
import '../market/quote_collector.dart';
import '../market/regime_store.dart';

/// 잡 보고 공통 — 넘길 알림 코드.
abstract interface class DailyJobReport {
  /// 엔진이 정한 알림 코드(발송 = 받는 쪽).
  Set<String> get alerts;
}

/// `daily_data` 보고.
class DailyDataReport implements DailyJobReport {
  /// 보고를 만든다.
  const DailyDataReport({required this.results, required this.verdict});

  /// 대상별 수집 결과.
  final List<QuoteCollectResult> results;

  /// KR 하루 판정(계획을 세워도 되나).
  final KrDayVerdict verdict;

  /// 실패한 대상.
  List<String> get failedKeys => <String>[
    for (final QuoteCollectResult r in results)
      if (r.failed) r.key,
  ];

  @override
  Set<String> get alerts => <String>{
    if (failedKeys.isNotEmpty || !verdict.proceed) AlertCodes.dataSourceDown,
  };

  @override
  String toString() =>
      'DailyDataReport(${results.length}대상 · 실패 ${failedKeys.length} · 판정 ${verdict.proceed ? '진행' : '멈춤'})';
}

/// `daily_data`(18:30 KST · R47 F3) — KR 대상만(`KQ11` + 계획 종목) · KR 하루 판정 → `data_gap`.
class DailyDataJob {
  /// 잡을 만든다.
  DailyDataJob(
    this._db, {
    required this._collector,
    required this._kr,
    required this._clock,
    required List<String> krSymbols,
  }) : krSymbols = List<String>.unmodifiable(krSymbols) {
    if (krSymbols.isEmpty) throw ArgumentError('계획 종목이 없다');
  }

  final Database _db;
  final QuoteCollector _collector;
  final ExchangeCalendar _kr;
  final Clock _clock;

  /// 계획 종목.
  final List<String> krSymbols;

  /// 수집 대상(KR 국면 대상 + 계획 종목).
  List<QuoteTarget> get targets => <QuoteTarget>[
    for (final QuoteTarget t in kRegimeQuoteTargets)
      if (t.market == Market.kr) t,
    for (final String s in krSymbols) QuoteTarget.krPlan(s),
  ];

  /// [day](KR 세션) 의 수집 · 판정.
  Future<DailyDataReport> run(TradeDate day) async {
    final List<QuoteCollectResult> results = <QuoteCollectResult>[
      for (final QuoteTarget t in targets) await _one(t),
    ];
    final String prev = _kr.nthSessionBefore(day, 1).yyyyMmDd;
    final KrDayVerdict v = judgeKrPlanDay(
      day,
      krSymbols,
      SqliteMarketStore(_db).krBars(krSymbols, from: prev, to: day.yyyyMmDd),
      _kr,
    );
    SqliteGapStore(_db)
        .recordKrVerdict(v, detectedAt: _clock.nowUtc().toIso8601String());
    return DailyDataReport(results: results, verdict: v);
  }

  Future<QuoteCollectResult> _one(QuoteTarget t) async {
    try {
      return await _collector.collectOne(t);
    } on Object catch (e) {
      return QuoteCollectResult(
        key: t.key,
        from: '',
        to: '',
        outcome: FetchOutcome.failed,
        detail: e.runtimeType.toString(),
      );
    }
  }
}

/// `us_data` 보고.
class UsDataReport implements DailyJobReport {
  /// 보고를 만든다.
  const UsDataReport({
    required this.quotes,
    required this.series,
    this.seriesFailed = false,
  });

  /// US 시세 대상별 결과.
  final List<QuoteCollectResult> quotes;

  /// 매크로 계열별 결과(계열 하나라도 예외면 빈 목록 + [seriesFailed]).
  final List<SeriesCollectResult> series;

  /// 매크로 수집이 통째로 실패했나.
  final bool seriesFailed;

  @override
  Set<String> get alerts => <String>{
    if (seriesFailed ||
        quotes.any((QuoteCollectResult r) => r.failed) ||
        series.any((SeriesCollectResult r) => r.outcome == FetchOutcome.failed))
      AlertCodes.dataSourceDown,
  };

  @override
  String toString() =>
      'UsDataReport(시세 ${quotes.length} · 계열 ${series.length}${seriesFailed ? ' · 계열 실패' : ''})';
}

/// `us_data`(07:30 KST · R47 F4) — US 국면 대상 4 + 매크로(대체 계열 포함).
class UsDataJob {
  /// 잡을 만든다.
  UsDataJob({required this._collector, required this._macro});

  final QuoteCollector _collector;
  final MacroCollector _macro;

  /// 수집 대상(US 국면 대상).
  List<QuoteTarget> get targets => <QuoteTarget>[
    for (final QuoteTarget t in kRegimeQuoteTargets)
      if (t.market == Market.us) t,
  ];

  /// [sessionDay](끝난 XNYS 세션) 의 수집.
  Future<UsDataReport> run(TradeDate sessionDay) async {
    final List<QuoteCollectResult> q = <QuoteCollectResult>[];
    for (final QuoteTarget t in targets) {
      try {
        q.add(await _collector.collectOne(t));
      } on Object catch (e) {
        q.add(
          QuoteCollectResult(
            key: t.key,
            from: '',
            to: '',
            outcome: FetchOutcome.failed,
            detail: e.runtimeType.toString(),
          ),
        );
      }
    }
    List<SeriesCollectResult> s = const <SeriesCollectResult>[];
    bool failed = false;
    try {
      s = await _macro.collect(asOf: sessionDay.yyyyMmDd, withStandIns: true);
    } on Object {
      failed = true;
    }
    return UsDataReport(quotes: q, series: s, seriesFailed: failed);
  }
}

/// `daily_signal` 보고.
class DailySignalReport implements DailyJobReport {
  /// 보고를 만든다.
  const DailySignalReport({
    required this.written,
    required this.lastDate,
    required this.last,
  });

  /// 새로 쓴 행 수(0 = 이미 최신).
  final int written;

  /// 마지막 계산 날짜(US 세션).
  final String? lastDate;

  /// 마지막 날 국면.
  final RegimeDay? last;

  @override
  Set<String> get alerts => const <String>{};

  @override
  String toString() =>
      'DailySignalReport(새 행 $written · 마지막 $lastDate · ${last?.directionState.name ?? '-'})';
}

String _nextDay(String ymd) =>
    DateTime.parse('${ymd}T00:00:00Z')
        .add(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

/// `daily_signal`(20:00 KST · R47 F5) — 저장된 시세 · 계열 → 국면 계산(실시간 신선도 상한) → `regime_score_daily`(덧붙이기만).
class DailySignalJob {
  /// 잡을 만든다 — [configHash] = 국면 설정 지문(부르는 쪽).
  DailySignalJob(this._db, {required this.configHash});

  final Database _db;

  /// 국면 설정 지문.
  final String configHash;

  /// 계산 · 저장.
  Future<DailySignalReport> run(TradeDate _) async {
    final RegimeSources s = SqliteMarketStore(_db).regimeSources();
    final RegimeComputation c = computeRegime(
      s,
      raw: applyFreshnessCaps(s, regimeRawIndicators(s)),
    );
    final SqliteRegimeStore store = SqliteRegimeStore(_db);
    final String? before = store.lastDate();
    final int n = store.writeComputation(
      c,
      fromDate: before == null ? c.calendar.first : _nextDay(before),
      source: RegimeRowSource.live,
      configHash: configHash,
    );
    return DailySignalReport(
      written: n,
      lastDate: c.calendar.isEmpty ? null : c.calendar.last,
      last: c.fsm.isEmpty ? null : c.fsm.last,
    );
  }
}

/// 국면 행(US 세션 날짜 순 · (날짜 · 방향 점수 · 방향 상태)) → 날짜 → (방향 점수 · BULL 인가) — 같은 날짜 포함 as-of(R47 F8 ·
/// R23 D13 ②). 실시간 20:30 KST 에는 그날 미국 세션이 아직 없어 사실상 앞 미국 세션 값이다. 앞에 행이 없으면 (null, false).
(double?, bool) Function(String day) regimeAsOfLookup(
  List<(String, double?, String?)> rows,
) {
  final List<(String, double?, String?)> sorted = rows.toList()
    ..sort(
      ((String, double?, String?) a, (String, double?, String?) b) =>
          a.$1.compareTo(b.$1),
    );
  return (String day) {
    int lo = 0, hi = sorted.length;
    while (lo < hi) {
      final int mid = (lo + hi) >> 1;
      if (sorted[mid].$1.compareTo(day) <= 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    if (lo == 0) return (null, false);
    final (String _, double? score, String? state) = sorted[lo - 1];
    return (score, state == DirectionState.bull.code);
  };
}

/// `equity_snapshot` 저장소(02 `equity_snapshot` · 모드 칸).
class SqliteEquitySnapshotStore {
  /// 저장소를 만든다.
  SqliteEquitySnapshotStore(this._db, {required this.mode});

  final Database _db;

  /// 이 파일의 실행 모드.
  final RunMode mode;

  EquitySnapshotRow _row(Row r) => EquitySnapshotRow(
    tradeDate: r['trade_date'] as String,
    totalEquity: (r['total_equity'] as num).toDouble(),
    cashKrw: (r['cash_krw'] as num).toDouble(),
    cashUsd: (r['cash_usd'] as num).toDouble(),
    fxRate: (r['fx_rate'] as num?)?.toDouble(),
    positionsValue: (r['positions_value'] as num).toDouble(),
    highWaterMark: (r['high_water_mark'] as num).toDouble(),
    drawdown: (r['drawdown'] as num).toDouble(),
    breakerLevel: BreakerLevel.fromCode(r['breaker_level'] as String),
  );

  /// [tradeDate] **앞** 날들의 행(날짜 순).
  List<EquitySnapshotRow> before(String tradeDate) => <EquitySnapshotRow>[
    for (final Row r in _db.select(
      'SELECT * FROM equity_snapshot WHERE trade_date < ? ORDER BY trade_date',
      <Object?>[tradeDate],
    ))
      _row(r),
  ];

  /// 한 날(없으면 null).
  EquitySnapshotRow? at(String tradeDate) {
    final ResultSet rs = _db.select(
      'SELECT * FROM equity_snapshot WHERE trade_date = ?',
      <Object?>[tradeDate],
    );
    return rs.isEmpty ? null : _row(rs.first);
  }

  /// 같은 날 덮어쓴다.
  void upsert(EquitySnapshotRow r) => _db.execute(
    'INSERT OR REPLACE INTO equity_snapshot(trade_date, total_equity, cash_krw, cash_usd, fx_rate, '
    'positions_value, high_water_mark, drawdown, breaker_level, mode) VALUES (?,?,?,?,?,?,?,?,?,?)',
    <Object?>[
      r.tradeDate,
      r.totalEquity,
      r.cashKrw,
      r.cashUsd,
      r.fxRate,
      r.positionsValue,
      r.highWaterMark,
      r.drawdown,
      r.breakerLevel.code,
      mode.wire,
    ],
  );
}

/// `equity_snapshot` 보고.
class EquitySnapshotReport implements DailyJobReport {
  /// 보고를 만든다.
  const EquitySnapshotReport(
    this.row, {
    required this.releaseEligibleToday,
    this.stoppedEnteredToday = false,
    this.incidentId,
  });

  /// 쓴 행.
  final EquitySnapshotRow row;

  /// 오늘 STOPPED 재개 자격 이벤트가 났나(🟡 알림 코드는 계약 창 — 지금은 보고만).
  final bool releaseEligibleToday;

  /// 🆕 E13d1 — 오늘 STOPPED 로 들어섰나(SEV1 을 열었다).
  final bool stoppedEnteredToday;

  /// 🆕 E13d1 — 연 SEV1(`incidents.incident_id`).
  final String? incidentId;

  /// 🆕 E13d1 제안 알림(계약 = E13i1 · R60 B6).
  @override
  Set<String> get alerts => <String>{
    if (stoppedEnteredToday) kBreakerStoppedAlertCode,
    if (releaseEligibleToday) kStoppedReleaseEligibleAlertCode,
  };

  @override
  String toString() => 'EquitySnapshotReport($row)';
}

/// `equity_snapshot`(20:30 KST · 늦은 끝 23:59 · R47 F6~F9).
class EquitySnapshotJob {
  /// 잡을 만든다 — [cash] = 계좌 별칭 → 브로커(현금 = `orderableCashKrw` · D+2).
  EquitySnapshotJob(
    this._db, {
    required Map<String, OrderBroker> cash,
    required this._mode,
    required this._holdings,
    required this._clock,
    this._config,
  }) : _cash = Map<String, OrderBroker>.unmodifiable(cash) {
    if (cash.isEmpty) throw ArgumentError('현금 계좌가 없다');
  }

  final Database _db;
  final Map<String, OrderBroker> _cash;
  final RunMode _mode;
  final Future<List<LedgerHolding>> Function() _holdings;
  final Clock _clock;
  final BreakerConfig? _config;

  /// 🆕 E13d1 — 사람의 STOPPED 재개 날(결정 B `breaker_release` · R60 B3).
  List<String> _releaseDates() => <String>[
    for (final Row r in _db.select(
      'SELECT trade_date FROM breaker_release ORDER BY trade_date',
    ))
      r['trade_date'] as String,
  ];

  Map<String, String> _closeTexts(String day, Iterable<String> symbols) {
    final Map<String, String> out = <String, String>{};
    for (final String s in symbols) {
      final ResultSet rs = _db.select(
        "SELECT close_unadj FROM daily_prices WHERE market = 'KR' AND symbol = ? AND trade_date = ?",
        <Object?>[s, day],
      );
      final Object? v = rs.isEmpty ? null : rs.first['close_unadj'];
      if (v is num) out[s] = v.toString();
    }
    return out;
  }

  (double?, bool) Function(String) _regimeLookup() =>
      regimeAsOfLookup(<(String, double?, String?)>[
        for (final Row r in _db.select(
          'SELECT trade_date, direction_score, direction_state FROM regime_score_daily ORDER BY trade_date',
        ))
          (
            r['trade_date'] as String,
            (r['direction_score'] as num?)?.toDouble(),
            r['direction_state'] as String?,
          ),
      ]);

  /// [day](KR 세션) 의 평가 행을 쓴다 — 실패면 [EquitySnapshotError](쓰지 않음).
  Future<EquitySnapshotReport> run(TradeDate day) async {
    final String d = day.yyyyMmDd;
    final List<LedgerHolding> held = await _holdings();
    final SqliteEquitySnapshotStore store = SqliteEquitySnapshotStore(
      _db,
      mode: _mode,
    );
    final EquitySnapshotStep step = await computeEquitySnapshot(
      tradeDate: d,
      holdings: held,
      closeTexts: _closeTexts(d, <String>{
        for (final LedgerHolding h in held)
          if (h.quantity != 0) h.symbol,
      }),
      cashAccounts: _cash,
      history: store.before(d),
      regimeOf: _regimeLookup(),
      config: _config,
      releaseDates: _releaseDates(),
    );
    final bool entered = step.replay?.stoppedEnteredToday ?? false;
    // 🆕 E13d1 — 스냅숏 + STOPPED 진입 SEV1 = 한 트랜잭션 · 다시 돌려도 1건(R60 B5).
    final StoppedIncident? incident = entered
        ? stoppedIncidentOf(
            tradeDate: d,
            drawdown: step.row.drawdown,
            nowUtc: _clock.nowUtc(),
          )
        : null;
    inLedgerTransaction(_db, () {
      store.upsert(step.row);
      if (incident != null) {
        _db.execute(
          'INSERT OR IGNORE INTO incidents (incident_id, occurred_at, severity, category, description, '
          'resolved_at, postmortem, due_at) VALUES (?, ?, ?, ?, ?, NULL, NULL, ?)',
          <Object?>[
            incident.incidentId,
            incident.occurredAtUtc.toIso8601String(),
            incident.severity,
            incident.category,
            incident.description,
            incident.dueAtUtc.toIso8601String(),
          ],
        );
      }
    });
    return EquitySnapshotReport(
      step.row,
      releaseEligibleToday: step.releaseEligibleToday,
      stoppedEnteredToday: entered,
      incidentId: incident?.incidentId,
    );
  }
}
