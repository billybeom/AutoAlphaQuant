// 일봉 시세 수집 — 원천 포트 → `daily_prices`·`market_series` + `fetch_log` (+ 실패·빠진 세션이면 `data_gap`)
// (설계 13 §8 R30 N1~N10 · R29 L8·L11 · R28 K5 · E8d2b · FR-111 · FR-112).
//
// 🔴 원천을 모른다 — core_engine 포트([DailyQuoteFeed])만 부른다. KIS 구현(broker_gateway `KisQuoteFeed`)을 이 수집기에
//    넣는 것은 잡(E11)이다(01 §1-1 · N1·N2).
// 🔴 **끝난 세션만** 저장한다(L11 · N3) — 받는 창의 끝 = [lastFinishedSession] · 그 뒤 날짜 행은 버리고 수만 센다
//    (미국 장중에 받은 마지막 행은 확정 종가가 아니었다).
// 🔴 받는 창 = 마지막 저장일(포함 — 하루 겹쳐 대조) ~ 끝난 세션(N4 · E8c 와 같음) · 이미 최신이면 부르지 않는다(기록 없음) ·
//    국면 대상은 시드가 없으면 [StateError](R23 D9) · KR 계획 종목은 첫 창 = 끝난 세션 − [kKrFirstBackfillDays].
// 🔴 끝내 실패 = `fetch_log` FAILED + `data_gap`(KR = `prices` · US·계열 = `macro` · MISSING_ROW · recoverable) — P1 알림은
//    잡(E11)이 [QuoteCollectResult.failed] 를 보고 낸다. 한 대상의 실패가 다른 대상을 막지 않는다(N7).
// 🔴 빠진 세션 = 받은 창에서 동결 달력은 세션인데 저장 뒤에도 행이 없는 날 → 하루짜리 MISSING_ROW(N8) — KR 은
//    `recordKrVerdict` 와 같은 `gap_id` 라 계획 판정이 같은 날을 다시 적어도 한 행이다. 첫 수집은 받은 가장 이른 날 앞을
//    보지 않는다(상장 전 · 원천 이력 밖).
// 🔵 VIX·VIX3M 은 여기서 받지 않는다 — KIS 지수 코드 미실측 → FRED 가 대신 받는다([MacroCollector.standIns] · N5).

import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show
        DailyQuoteFeed,
        DataGapCause,
        ExchangeCalendar,
        Market,
        PriceAdjust,
        QuoteBar,
        QuoteFeedDown,
        QuoteFetch,
        QuoteKind,
        frozenExchangeCalendar,
        lastFinishedSession,
        plusDays;
import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock, TradeDate;
import 'package:sqlite3/sqlite3.dart';

import 'fetch_log.dart';
import 'gap_store.dart';
import 'macro_collector.dart' show kSeriesRequestKind;
import 'market_ids.dart';
import 'market_store.dart';

/// 수집 기록의 요청 종류 — KR 일봉·지수.
const String kKrDailyRequestKind = 'KR_DAILY';

/// 수집 기록의 요청 종류 — US 일봉·지수.
const String kUsDailyRequestKind = 'US_DAILY';

/// KR 계획 종목의 첫 창(달력일 · N4) — 시드가 없다.
const int kKrFirstBackfillDays = 400;

/// 어디에 쌓나.
enum QuoteSink {
  /// `daily_prices` 원 일봉(지수 · 미국 종목 `MODP=0`).
  bars,

  /// `daily_prices` KR 종목 — `close` = 수정 · `close_unadj` = 원(두 번 받아 날짜로 맞춘다 · L8).
  krBars,

  /// `market_series` 수정종가(`MODP=1`).
  adjSeries,
}

/// 수집 대상 하나.
class QuoteTarget {
  const QuoteTarget({
    required this.key,
    required this.market,
    required this.symbol,
    required this.kind,
    required this.sink,
    required this.needsSeed,
  });

  /// KR 계획 종목(시드 없음 · 첫 창 = [kKrFirstBackfillDays]).
  const QuoteTarget.krPlan(String code)
    : this(
        key: code,
        market: Market.kr,
        symbol: code,
        kind: QuoteKind.stock,
        sink: QuoteSink.krBars,
        needsSeed: false,
      );

  /// 기록 이름 — `daily_prices` 는 심볼 · `market_series` 는 계열 이름.
  final String key;
  final Market market;

  /// 원천에 묻는 저장 이름.
  final String symbol;
  final QuoteKind kind;
  final QuoteSink sink;

  /// 시드가 있어야 도는가(국면 대상 · R23 D9).
  final bool needsSeed;

  /// 수집 기록의 요청 종류(N6).
  String get requestKind => sink == QuoteSink.adjSeries
      ? kSeriesRequestKind
      : market == Market.kr
      ? kKrDailyRequestKind
      : kUsDailyRequestKind;

  /// 결측 기록의 묶음(N7).
  GapDataset get gapDataset =>
      market == Market.kr ? GapDataset.prices : GapDataset.macro;
}

/// 국면 대상 5(N5) — `^GSPC` · `SPY` 일봉 · `SPY_ADJ` · `RSP_ADJ` · `KQ11`.
const List<QuoteTarget> kRegimeQuoteTargets = <QuoteTarget>[
  QuoteTarget(
    key: MarketSymbols.gspc,
    market: Market.us,
    symbol: MarketSymbols.gspc,
    kind: QuoteKind.stockIndex,
    sink: QuoteSink.bars,
    needsSeed: true,
  ),
  QuoteTarget(
    key: MarketSymbols.spy,
    market: Market.us,
    symbol: MarketSymbols.spy,
    kind: QuoteKind.stock,
    sink: QuoteSink.bars,
    needsSeed: true,
  ),
  QuoteTarget(
    key: MarketSeriesIds.spyAdjClose,
    market: Market.us,
    symbol: MarketSymbols.spy,
    kind: QuoteKind.stock,
    sink: QuoteSink.adjSeries,
    needsSeed: true,
  ),
  QuoteTarget(
    key: MarketSeriesIds.rspAdjClose,
    market: Market.us,
    symbol: 'RSP',
    kind: QuoteKind.stock,
    sink: QuoteSink.adjSeries,
    needsSeed: true,
  ),
  QuoteTarget(
    key: MarketSymbols.kosdaq,
    market: Market.kr,
    symbol: MarketSymbols.kosdaq,
    kind: QuoteKind.stockIndex,
    sink: QuoteSink.bars,
    needsSeed: true,
  ),
];

/// 대상 하나의 수집 결과.
class QuoteCollectResult {
  const QuoteCollectResult({
    required this.key,
    required this.from,
    required this.to,
    this.outcome,
    this.fetchId,
    this.write,
    this.droppedUnfinished = 0,
    this.gapIds = const <String>[],
    this.detail,
  });

  final String key;

  /// 받는 창(둘 다 포함).
  final String from, to;

  /// 기록 결과 — null = 이미 최신(부르지 않았다 · 기록 없음).
  final FetchOutcome? outcome;
  final String? fetchId;

  /// 쓰기 결과(실패·최신이면 null) — 거부에는 값이 모자란 행도 든다.
  final WriteCount? write;

  /// 끝난 세션 뒤라 버린 행 수(L11).
  final int droppedUnfinished;

  /// 기록한 결측 id(실패 1 · 빠진 세션마다 1).
  final List<String> gapIds;

  /// 수집 기록에 남긴 문장.
  final String? detail;

  /// 이미 최신이라 부르지 않았다.
  bool get upToDate => outcome == null;

  /// 끝내 받지 못했다(잡이 P1 을 낸다).
  bool get failed => outcome == FetchOutcome.failed;
}

/// 일봉 원천에서 받아 원장에 쌓는다.
class QuoteCollector {
  QuoteCollector(
    this._db, {
    required this._feed,
    required this._clock,
    ExchangeCalendar? kr,
    ExchangeCalendar? us,
    this.krFirstBackfillDays = kKrFirstBackfillDays,
  }) : _kr = kr ?? frozenExchangeCalendar(Market.kr),
       _us = us ?? frozenExchangeCalendar(Market.us);

  final Database _db;
  final DailyQuoteFeed _feed;
  final Clock _clock;
  final ExchangeCalendar _kr, _us;

  /// KR 계획 종목의 첫 창(달력일).
  final int krFirstBackfillDays;

  /// 국면 대상 5 + KR 계획 종목 [krSymbols](순서대로 · 하나의 실패가 다음을 막지 않는다).
  Future<List<QuoteCollectResult>> collect({
    List<String> krSymbols = const <String>[],
  }) async => <QuoteCollectResult>[
    for (final QuoteTarget t in <QuoteTarget>[
      ...kRegimeQuoteTargets,
      for (final String s in krSymbols) QuoteTarget.krPlan(s),
    ])
      await collectOne(t),
  ];

  /// 대상 하나.
  Future<QuoteCollectResult> collectOne(QuoteTarget t) async {
    final ExchangeCalendar cal = t.market == Market.kr ? _kr : _us;
    final String to = lastFinishedSession(cal, _clock.nowUtc());
    final SqliteMarketStore store = SqliteMarketStore(_db);
    final String? last = t.sink == QuoteSink.adjSeries
        ? store.lastSeriesDate(t.key)
        : store.lastBarDate(t.market.code, t.symbol);
    if (last == null && t.needsSeed) {
      throw StateError('${t.key} — 시드가 없다(시드 먼저 · R23 D9)');
    }
    final String from = last ?? plusDays(to, -krFirstBackfillDays);
    if (last != null && last.compareTo(to) >= 0) {
      return QuoteCollectResult(key: t.key, from: from, to: to);
    }
    final List<QuoteFetch> got = <QuoteFetch>[];
    try {
      for (final PriceAdjust a in switch (t.sink) {
        QuoteSink.bars => const <PriceAdjust>[PriceAdjust.raw],
        QuoteSink.krBars => const <PriceAdjust>[
          PriceAdjust.adjusted,
          PriceAdjust.raw,
        ],
        QuoteSink.adjSeries => const <PriceAdjust>[PriceAdjust.adjusted],
      }) {
        got.add(
          await _feed.daily(
            market: t.market,
            symbol: t.symbol,
            kind: t.kind,
            adjust: a,
            from: from,
            to: to,
          ),
        );
      }
    } on QuoteFeedDown catch (e) {
      final int before = got.fold(0, (int n, QuoteFetch f) => n + f.attempts);
      return _failed(
        t,
        last: last,
        from: from,
        to: to,
        error: e,
        before: before,
      );
    }
    return _store(t, store, cal, last: last, from: from, to: to, got: got);
  }

  QuoteCollectResult _store(
    QuoteTarget t,
    SqliteMarketStore store,
    ExchangeCalendar cal, {
    required String? last,
    required String from,
    required String to,
    required List<QuoteFetch> got,
  }) {
    final String at = _clock.nowUtc().toIso8601String();
    final String id = _fetchId(t, at);
    bool inWindow(QuoteBar b) =>
        b.date.compareTo(from) >= 0 && b.date.compareTo(to) <= 0;
    final List<QuoteBar> main = got.first.bars;
    final int dropped = main
        .where((QuoteBar b) => b.date.compareTo(to) > 0)
        .length;
    final List<QuoteBar> kept = main.where(inWindow).toList();
    final Map<String, double> raw = <String, double>{
      if (t.sink == QuoteSink.krBars)
        for (final QuoteBar b in got[1].bars)
          if (inWindow(b)) b.date: b.close,
    };
    final int attempts = got.fold(0, (int n, QuoteFetch f) => n + f.attempts);
    final List<String> pages = <String>[
      for (final QuoteFetch f in got) ...f.pageBodies,
    ];
    return inLedgerTransaction(_db, () {
      final WriteCount w = _write(t, store, kept, raw, fetchedAt: at);
      final List<String> gaps = _missingSessions(
        t,
        store,
        cal,
        start: last == null
            ? (kept.isEmpty ? null : kept.first.date)
            : plusDays(last, 1),
        to: to,
        detectedAt: at,
      );
      final String detail = <String>[
        '${t.key} $from~$to',
        '새 ${w.inserted} · 겹침 같음 ${w.overlapSame} · 개정 ${w.overlapRevised}(고치지 않음)',
        if (w.rejected.isNotEmpty) '거부 ${w.rejected.length}',
        if (dropped > 0) '장중 제외 $dropped',
        if (gaps.isNotEmpty) '빠진 세션 ${gaps.length}',
        '시도 $attempts',
      ].join(' · ');
      final FetchOutcome outcome = w.inserted > 0
          ? FetchOutcome.ok
          : FetchOutcome.empty;
      SqliteFetchLog(_db).record(
        FetchRecord(
          fetchId: id,
          source: _feed.source,
          requestKind: t.requestKind,
          asOf: to,
          rowCount: w.inserted,
          bodySha256: pages.isEmpty
              ? null
              : sha256.convert(utf8.encode(pages.join())).toString(),
          fetchedAt: at,
          outcome: outcome,
          detail: detail,
        ),
      );
      return QuoteCollectResult(
        key: t.key,
        from: from,
        to: to,
        outcome: outcome,
        fetchId: id,
        write: w,
        droppedUnfinished: dropped,
        gapIds: gaps,
        detail: detail,
      );
    });
  }

  WriteCount _write(
    QuoteTarget t,
    SqliteMarketStore store,
    List<QuoteBar> bars,
    Map<String, double> raw, {
    required String fetchedAt,
  }) {
    if (t.sink == QuoteSink.adjSeries) {
      return store.insertSeries(
        t.key,
        <SeriesObs>[for (final QuoteBar b in bars) SeriesObs(b.date, b.close)],
        source: _feed.source,
        fetchedAt: fetchedAt,
      );
    }
    // 🔴 값이 모자란 행(시고저·거래량 없음 · 거래량이 정수 아님)은 쓰지 않는다 — 0 으로 채우지 않는다(N9).
    final List<String> short = <String>[];
    final List<PriceBar> rows = <PriceBar>[];
    for (final QuoteBar b in bars) {
      final double? o = b.open, h = b.high, l = b.low, v = b.volume;
      if (o == null ||
          h == null ||
          l == null ||
          v == null ||
          v != v.roundToDouble()) {
        short.add(b.date);
        continue;
      }
      rows.add(
        PriceBar(
          tradeDate: b.date,
          open: o,
          high: h,
          low: l,
          close: b.close,
          volume: v.toInt(),
          closeUnadj: raw[b.date],
          tradeValue: b.tradeValue,
        ),
      );
    }
    final WriteCount w = store.insertBars(
      t.market.code,
      t.symbol,
      rows,
      source: _feed.source,
      fetchedAt: fetchedAt,
    );
    return WriteCount(
      inserted: w.inserted,
      overlapSame: w.overlapSame,
      overlapRevised: w.overlapRevised,
      rejected: <String>[...short, ...w.rejected]..sort(),
    );
  }

  /// [start]~[to] 의 세션 중 저장 뒤에도 행이 없는 날마다 하루짜리 결측(N8). [start] = null 이면 보지 않는다.
  List<String> _missingSessions(
    QuoteTarget t,
    SqliteMarketStore store,
    ExchangeCalendar cal, {
    required String? start,
    required String to,
    required String detectedAt,
  }) {
    if (start == null || start.compareTo(to) > 0) return const <String>[];
    final Set<String> have = t.sink == QuoteSink.adjSeries
        ? store.seriesDates(t.key, from: start, to: to)
        : store.barDates(t.market.code, t.symbol, from: start, to: to);
    final SqliteGapStore gaps = SqliteGapStore(_db);
    return <String>[
      for (String d = start; d.compareTo(to) <= 0; d = plusDays(d, 1))
        if (cal.isSession(TradeDate(d)) && !have.contains(d))
          gaps.record(
            dataset: t.gapDataset,
            key: t.key,
            fromDate: d,
            toDate: d,
            cause: DataGapCause.missingRow,
            detectedAt: detectedAt,
          ),
    ];
  }

  QuoteCollectResult _failed(
    QuoteTarget t, {
    required String? last,
    required String from,
    required String to,
    required QuoteFeedDown error,
    required int before,
  }) {
    final String at = _clock.nowUtc().toIso8601String();
    final String id = _fetchId(t, at);
    final String gapFrom = last == null ? from : plusDays(last, 1);
    final String detail =
        '${t.key} $from~$to — 받지 못함: ${error.reason} · 시도 ${before + error.attempts}';
    return inLedgerTransaction(_db, () {
      SqliteFetchLog(_db).record(
        FetchRecord(
          fetchId: id,
          source: _feed.source,
          requestKind: t.requestKind,
          asOf: to,
          rowCount: 0,
          fetchedAt: at,
          outcome: FetchOutcome.failed,
          detail: detail,
        ),
      );
      final String gap = SqliteGapStore(_db).record(
        dataset: t.gapDataset,
        key: t.key,
        fromDate: gapFrom,
        toDate: to.compareTo(gapFrom) < 0 ? gapFrom : to,
        cause: DataGapCause.missingRow,
        detectedAt: at,
      );
      return QuoteCollectResult(
        key: t.key,
        from: from,
        to: to,
        outcome: FetchOutcome.failed,
        fetchId: id,
        gapIds: <String>[gap],
        detail: detail,
      );
    });
  }

  String _fetchId(QuoteTarget t, String at) =>
      '${_feed.source.wire}:${t.requestKind}:${t.key}:$at';
}
