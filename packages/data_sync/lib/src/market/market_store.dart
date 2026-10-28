// 시세·지표 저장 — `daily_prices`(OHLCV) · `market_series`(종가만) 쓰기·읽기(설계 13 §8 R23 D7·D8 · R26 H1·H3 · E8c).
//
// 🔴 **덧붙이기만 한다**(R26 H3) — 이미 있는 날짜의 행은 고치지 않는다(시드·첫 수집 값이 그 날의 기록이다 · FRED 의
//    과거 개정은 겹친 날 비교로 세기만 한다 → [WriteCount.overlapRevised]). 국면 이력이 조용히 바뀌지 않는다.
// 🔴 CHECK 를 넘지 못하는 행(종가 ≤ 0 · 거래량 < 0 · 값 NaN)은 쓰지 않고 [WriteCount.rejected] 로 돌려준다
//    (FR-112 — 결측 판정은 core_engine `judgeKrPlanDay` 몫 · 표가 조용히 0 을 담지 않는다).
// 🔴 트랜잭션은 호출자가 연다([inLedgerTransaction]) — 시드·수집이 «쓰기 + 수집 기록»을 한 번에 커밋한다.

import 'package:core_engine/core_engine.dart'
    show DatedSeries, DistVolumeSource, KrBar, RegimeSources, kP0sDistVolume;
import 'package:domain_contracts/domain_contracts.dart' show MarketDataSource;
import 'package:sqlite3/sqlite3.dart';

import 'market_ids.dart';

/// 일봉 한 행(`daily_prices`).
class PriceBar {
  const PriceBar({
    required this.tradeDate,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.closeUnadj,
    this.tradeValue,
    this.marketCap,
  });

  /// `YYYY-MM-DD`(그 시장의 현지 거래일).
  final String tradeDate;
  final double open, high, low;

  /// 수정종가.
  final double close;
  final int volume;

  /// 미조정 종가 · 거래대금 · 시가총액(모르면 null).
  final double? closeUnadj, tradeValue, marketCap;

  bool get _valid =>
      open > 0 && high > 0 && low > 0 && close > 0 && volume >= 0;
}

/// 관측 하나(`market_series`).
class SeriesObs {
  const SeriesObs(this.date, this.value);

  /// 관측일(원천 날짜 그대로).
  final String date;
  final double value;

  @override
  String toString() => '$date=$value';
}

/// 쓰기 결과.
class WriteCount {
  const WriteCount({
    required this.inserted,
    required this.overlapSame,
    required this.overlapRevised,
    required this.rejected,
  });

  /// 새로 쓴 행.
  final int inserted;

  /// 이미 있던 날 — 값이 같음 · 다름(다르면 고치지 않는다).
  final int overlapSame, overlapRevised;

  /// 쓰지 않은 행의 날짜(CHECK 위반 · NaN).
  final List<String> rejected;
}

/// [body] 를 `BEGIN IMMEDIATE … COMMIT` 안에서 돌린다(던지면 ROLLBACK).
T inLedgerTransaction<T>(Database db, T Function() body) {
  db.execute('BEGIN IMMEDIATE');
  try {
    final T out = body();
    db.execute('COMMIT');
    return out;
  } catch (_) {
    db.execute('ROLLBACK');
    rethrow;
  }
}

/// 로컬 원장 파일의 시세·지표.
final class SqliteMarketStore {
  SqliteMarketStore(this._db);

  final Database _db;

  /// [market]·[symbol] 의 일봉을 덧붙인다.
  WriteCount insertBars(
    String market,
    String symbol,
    List<PriceBar> bars, {
    required MarketDataSource source,
    required String fetchedAt,
  }) {
    final PreparedStatement ins = _db.prepare(
      'INSERT INTO daily_prices (trade_date, market, symbol, open, high, low, close, '
      'close_unadj, volume, trade_value, market_cap, source, fetched_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
      'ON CONFLICT (trade_date, market, symbol) DO NOTHING',
    );
    final PreparedStatement old = _db.prepare(
      'SELECT open, high, low, close, volume FROM daily_prices '
      'WHERE trade_date = ? AND market = ? AND symbol = ?',
    );
    int inserted = 0, same = 0, revised = 0;
    final List<String> rejected = <String>[];
    try {
      for (final PriceBar b in bars) {
        if (!b._valid) {
          rejected.add(b.tradeDate);
          continue;
        }
        ins.execute(<Object?>[
          b.tradeDate,
          market,
          symbol,
          b.open,
          b.high,
          b.low,
          b.close,
          b.closeUnadj,
          b.volume,
          b.tradeValue,
          b.marketCap,
          source.wire,
          fetchedAt,
        ]);
        if (_db.updatedRows == 1) {
          inserted++;
          continue;
        }
        final Row r = old.select(<Object>[b.tradeDate, market, symbol]).first;
        final bool eq =
            r['open'] == b.open &&
            r['high'] == b.high &&
            r['low'] == b.low &&
            r['close'] == b.close &&
            r['volume'] == b.volume;
        eq ? same++ : revised++;
      }
    } finally {
      ins.close();
      old.close();
    }
    return WriteCount(
      inserted: inserted,
      overlapSame: same,
      overlapRevised: revised,
      rejected: rejected,
    );
  }

  /// 계열 [seriesId] 에 관측을 덧붙인다.
  WriteCount insertSeries(
    String seriesId,
    List<SeriesObs> obs, {
    required MarketDataSource source,
    required String fetchedAt,
  }) {
    final PreparedStatement ins = _db.prepare(
      'INSERT INTO market_series (series_id, obs_date, value, source, fetched_at) '
      'VALUES (?, ?, ?, ?, ?) ON CONFLICT (series_id, obs_date) DO NOTHING',
    );
    final PreparedStatement old = _db.prepare(
      'SELECT value FROM market_series WHERE series_id = ? AND obs_date = ?',
    );
    int inserted = 0, same = 0, revised = 0;
    final List<String> rejected = <String>[];
    try {
      for (final SeriesObs o in obs) {
        if (!o.value.isFinite) {
          rejected.add(o.date);
          continue;
        }
        ins.execute(<Object?>[
          seriesId,
          o.date,
          o.value,
          source.wire,
          fetchedAt,
        ]);
        if (_db.updatedRows == 1) {
          inserted++;
          continue;
        }
        final Object? v = old.select(<Object>[seriesId, o.date]).first['value'];
        v == o.value ? same++ : revised++;
      }
    } finally {
      ins.close();
      old.close();
    }
    return WriteCount(
      inserted: inserted,
      overlapSame: same,
      overlapRevised: revised,
      rejected: rejected,
    );
  }

  /// [market]·[symbol] 의 마지막 거래일(없으면 null).
  String? lastBarDate(String market, String symbol) =>
      _db.select(
            'SELECT MAX(trade_date) AS d FROM daily_prices WHERE market = ? AND symbol = ?',
            <Object>[market, symbol],
          ).first['d']
          as String?;

  /// 계열 [seriesId] 의 마지막 관측일(없으면 null).
  String? lastSeriesDate(String seriesId) =>
      _db.select(
            'SELECT MAX(obs_date) AS d FROM market_series WHERE series_id = ?',
            <Object>[seriesId],
          ).first['d']
          as String?;

  /// 계열 [seriesId] 전부(날짜 오름차순 · 결측 = 행 없음).
  DatedSeries readSeries(String seriesId) {
    final List<String> d = <String>[];
    final List<double> v = <double>[];
    for (final Row r in _db.select(
      'SELECT obs_date, value FROM market_series WHERE series_id = ? ORDER BY obs_date',
      <Object>[seriesId],
    )) {
      d.add(r['obs_date'] as String);
      v.add((r['value'] as num).toDouble());
    }
    return DatedSeries(d, v);
  }

  /// [market]·[symbol] 의 일봉 전부(날짜 오름차순).
  List<PriceBar> readBars(String market, String symbol) => <PriceBar>[
    for (final Row r in _db.select(
      'SELECT trade_date, open, high, low, close, close_unadj, volume, trade_value, market_cap '
      'FROM daily_prices WHERE market = ? AND symbol = ? ORDER BY trade_date',
      <Object>[market, symbol],
    ))
      PriceBar(
        tradeDate: r['trade_date'] as String,
        open: (r['open'] as num).toDouble(),
        high: (r['high'] as num).toDouble(),
        low: (r['low'] as num).toDouble(),
        close: (r['close'] as num).toDouble(),
        closeUnadj: (r['close_unadj'] as num?)?.toDouble(),
        volume: r['volume'] as int,
        tradeValue: (r['trade_value'] as num?)?.toDouble(),
        marketCap: (r['market_cap'] as num?)?.toDouble(),
      ),
  ];

  /// 국면 원천 한 벌(달력 = 저장된 ^GSPC 세션) — 재현 하네스의 `regimeSourcesFromBundle` 과 같은 꼴.
  /// 🆕 [distVolume] = `dist_days` 거래량(기본 = 실전 P0S [kP0sDistVolume] — SPY · 설계 13 §8 R27 I1 · R28 K2).
  /// 골든 재현을 볼 때만 [DistVolumeSource.gspcIndex] 를 준다.
  RegimeSources regimeSources({DistVolumeSource distVolume = kP0sDistVolume}) {
    final List<PriceBar> us = readBars('US', MarketSymbols.gspc);
    final List<PriceBar> spy = readBars('US', MarketSymbols.spy);
    return RegimeSources(
      usDates: <String>[for (final PriceBar b in us) b.tradeDate],
      usClose: <double?>[for (final PriceBar b in us) b.close],
      usHigh: <double?>[for (final PriceBar b in us) b.high],
      usLow: <double?>[for (final PriceBar b in us) b.low],
      usVolume: <double?>[for (final PriceBar b in us) b.volume.toDouble()],
      spyAdjClose: readSeries(MarketSeriesIds.spyAdjClose),
      spyVolume: DatedSeries(
        <String>[for (final PriceBar b in spy) b.tradeDate],
        <double>[for (final PriceBar b in spy) b.volume.toDouble()],
      ),
      rspAdjClose: readSeries(MarketSeriesIds.rspAdjClose),
      vix: readSeries(MarketSeriesIds.vix),
      vix3m: readSeries(MarketSeriesIds.vix3m),
      ofrFsi: readSeries(MarketSeriesIds.ofrFsi),
      nfci: readSeries(MarketSeriesIds.nfci),
      cfnaiMa3: readSeries(MarketSeriesIds.cfnaiMa3),
      t10y3m: readSeries(MarketSeriesIds.t10y3m),
      sahm: readSeries(MarketSeriesIds.sahm),
      distVolume: distVolume,
    );
  }

  /// KR 종목들의 일봉([from]~[to] 포함) — `judgeKrPlanDay` 의 입력(종목 → 날짜 → 일봉).
  Map<String, Map<String, KrBar>> krBars(
    List<String> symbols, {
    required String from,
    required String to,
  }) {
    final PreparedStatement q = _db.prepare(
      'SELECT trade_date, close, volume FROM daily_prices '
      "WHERE market = 'KR' AND symbol = ? AND trade_date BETWEEN ? AND ? ORDER BY trade_date",
    );
    try {
      return <String, Map<String, KrBar>>{
        for (final String s in symbols)
          s: <String, KrBar>{
            for (final Row r in q.select(<Object>[s, from, to]))
              r['trade_date'] as String: KrBar(
                close: (r['close'] as num).toDouble(),
                volume: (r['volume'] as num).toDouble(),
              ),
          },
      };
    } finally {
      q.close();
    }
  }
}
