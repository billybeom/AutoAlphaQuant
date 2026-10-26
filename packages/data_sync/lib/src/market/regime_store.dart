// 국면 행 저장 — `regime_score_daily`(FR-201 · 설계 13 §8 R23 D7 · R25 G2 · R26 H4 · E8c).
//
// 🔴 `trade_date` = 국면 달력(^GSPC 세션)의 날짜다 — KR 판정일로 옮기는 것은 읽는 쪽(`alignAsOfInclusive` · D13 (c)).
// 🔴 덧붙이기만 한다 — 이미 있는 날은 고치지 않는다(같은 입력이면 같은 값 · 다른 값이면 원천이 바뀐 것이라 조용히
//    덮지 않는다). `source` = LIVE(그날 계산) · BACKFILL(갭일을 나중에 다시 계산 — X2-4 · `holding_signal_daily` 와 같은 두 값).
// 🔵 카테고리 점수 NULL = 제외됨 · `excluded_categories` = 제외된 카테고리 코드의 JSON 배열(없으면 `[]`).

import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show DirectionScore, RegimeCategory, RegimeComputation, RegimeDay;
import 'package:sqlite3/sqlite3.dart';

/// `regime_score_daily.source`.
enum RegimeRowSource {
  /// 그날 계산.
  live('LIVE'),

  /// 갭일을 나중에 다시 계산.
  backfill('BACKFILL');

  const RegimeRowSource(this.wire);

  /// 기록 값.
  final String wire;
}

/// 로컬 원장 파일의 국면 행.
final class SqliteRegimeStore {
  SqliteRegimeStore(this._db);

  final Database _db;

  /// [c] 의 [fromDate] 이후(포함) 날을 덧붙인다 — 새로 쓴 행 수.
  int writeComputation(
    RegimeComputation c, {
    required String fromDate,
    required RegimeRowSource source,
    required String configHash,
  }) {
    final PreparedStatement ins = _db.prepare(
      'INSERT INTO regime_score_daily (trade_date, status, direction_score, trendiness_score, '
      'direction_state, bars_in_state, exposure, cat_trend, cat_breadth, cat_volatility, '
      'cat_credit, cat_macro, excluded_categories, config_hash, source) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
      'ON CONFLICT (trade_date) DO NOTHING',
    );
    int inserted = 0;
    try {
      for (int t = 0; t < c.calendar.length; t++) {
        if (c.calendar[t].compareTo(fromDate) < 0) continue;
        final DirectionScore d = c.direction[t];
        final RegimeDay f = c.fsm[t];
        ins.execute(<Object?>[
          c.calendar[t],
          f.status.code,
          _finite(d.direction),
          _finite(c.trendiness[t]),
          f.directionState.code,
          f.barsInState,
          f.exposure,
          for (final RegimeCategory k in RegimeCategory.values)
            _finite(d.categories[k]),
          jsonEncode(<String>[
            for (final RegimeCategory k in d.excluded) k.code,
          ]),
          configHash,
          source.wire,
        ]);
        inserted += _db.updatedRows;
      }
    } finally {
      ins.close();
    }
    return inserted;
  }

  /// 마지막 날(없으면 null).
  String? lastDate() =>
      _db
              .select('SELECT MAX(trade_date) AS d FROM regime_score_daily')
              .first['d']
          as String?;

  /// [tradeDate] 의 행(없으면 null) — 칸 이름 → 값.
  Map<String, Object?>? row(String tradeDate) {
    final ResultSet rs = _db.select(
      'SELECT * FROM regime_score_daily WHERE trade_date = ?',
      <Object>[tradeDate],
    );
    return rs.isEmpty
        ? null
        : <String, Object?>{
            for (final String col in rs.columnNames) col: rs.first[col],
          };
  }
}

double? _finite(double? v) => v == null || v.isNaN ? null : v;
