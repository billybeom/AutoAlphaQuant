// C-48 시세·지표 데이터 계약 — 01 §22 · 설계 13 §8 R23 D7·D8 · R24 B4·B5 · R25 G1~G4(🆕 계약 v1.14 · E8a).
//
// 정의: 「시세·지표가 어디서 왔는지(원천)와 언제 받았는지가 행마다 남고, 종가만 있는 계열은 따로 담기며, 결측의 사유는
//        계약 사전의 글자로만 기록된다」.
//   ① `MarketDataSource` 6값(SEED_BUNDLE · KIS · FRED · FRED_CSV · OFR · MANUAL) — 배치 G 의 `source` CHECK 와 같다(C-15 축 +3).
//   ② `GapReasonCodes` += 시세 결측 5종 — `data_gap.reason_code` 가 쓰는 사전(엔진 `DataGapCause` 와 같은 글자 · core 시험).
//   ③ 배치 G DDL — `market_series` PK(series_id, obs_date) · 값 NOT NULL(결측 = 행 없음) · `fetch_log` 결과 3값 · 원문 칸 없음 ·
//      `mode` 칸 없음(파일이 경계) · `daily_prices` += source·fetched_at · `regime_score_daily.source` = 신호 표와 같은 LIVE·BACKFILL.

import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

String _batchG() =>
    File('${ddlDir.path}/batch_g_market_data.sql').readAsStringSync();

String _table(String sql, String name) {
  final int a = sql.indexOf('CREATE TABLE IF NOT EXISTS $name (');
  expect(a, greaterThanOrEqualTo(0), reason: '$name 표가 없다');
  return sql.substring(a, sql.indexOf(');', a));
}

Set<String> _check(String file, String table, String column) => <String>{
  for (final CheckConstraint c in parseCheckConstraints(
    File('${ddlDir.path}/$file'),
  ))
    if (c.table == table && c.column == column) ...c.values,
};

void main() {
  group('C-48 시세·지표 데이터(v1.14)', () {
    test('C-48 ① 원천 6값 — 순서·글자', () {
      expect(
        MarketDataSource.values.map((MarketDataSource s) => s.wire),
        <String>['SEED_BUNDLE', 'KIS', 'FRED', 'FRED_CSV', 'OFR', 'MANUAL'],
      );
      for (final (String table, String column) in <(String, String)>[
        ('market_series', 'source'),
        ('fetch_log', 'source'),
        ('daily_prices', 'source'),
      ]) {
        expect(_check('batch_g_market_data.sql', table, column), <String>{
          for (final MarketDataSource s in MarketDataSource.values) s.wire,
        }, reason: '$table.$column');
      }
    });

    test('C-48 ② 결측 사유 5종이 data_gap 사전에 있다', () {
      expect(
        GapReasonCodes.values,
        containsAll(<String>[
          'MISSING_ROW',
          'NON_POSITIVE_PRICE',
          'NEGATIVE_VOLUME',
          'PRICE_JUMP',
          'CALENDAR_SUSPECT',
        ]),
      );
      // 🔵 v1.22(01 §31 · K66) — +SIM_BAR_MISSING(모의 가상 체결 봉 공백 · 시세 결측 5 와 다른 갈래) → 9.
      expect(GapReasonCodes.values, hasLength(9));
      expect(ContractCodes.byDomain['gap_reason_code'], GapReasonCodes.values);
    });

    test('C-48 ③ 배치 G DDL — 표 꼴 · 원문 칸 없음 · mode 칸 없음 · 기존 표엔 칸만 더한다', () {
      final String g = _batchG();
      final String series = _table(g, 'market_series');
      expect(series, contains('PRIMARY KEY (series_id, obs_date)'));
      expect(
        RegExp(
          r'^\s+value\s+REAL\s+NOT NULL',
          multiLine: true,
        ).hasMatch(series),
        isTrue,
        reason: '결측은 «행 없음» — 값 NULL 을 저장하지 않는다(R25 G2)',
      );
      final String log = _table(g, 'fetch_log');
      expect(
        _check('batch_g_market_data.sql', 'fetch_log', 'outcome'),
        <String>{'OK', 'EMPTY', 'FAILED'},
      );
      expect(log, contains('body_sha256'));
      expect(
        RegExp(
          r'^\s+(body|raw|response|payload)\s',
          multiLine: true,
        ).hasMatch(log),
        isFalse,
        reason: '응답 원문은 저장하지 않는다(sha256 만 · R23 D7)',
      );
      for (final String t in <String>[series, log]) {
        expect(
          RegExp(r'^\s+mode\s', multiLine: true).hasMatch(t),
          isFalse,
          reason: '시세는 실계좌·모의가 같다 — 파일이 경계(R20 Q1)',
        );
      }
      expect(g, contains('ALTER TABLE daily_prices ADD COLUMN source TEXT'));
      expect(
        g,
        contains('ALTER TABLE daily_prices ADD COLUMN fetched_at TEXT'),
      );
      expect(
        _check('batch_g_market_data.sql', 'regime_score_daily', 'source'),
        _check('batch_a_decision_mode.sql', 'holding_signal_daily', 'source'),
        reason: '갭일 국면 행 = 신호 표와 같은 LIVE·BACKFILL(X2-4)',
      );
      expect(
        g,
        isNot(contains('CREATE TABLE IF NOT EXISTS daily_prices')),
        reason: '02 기본 표는 다시 만들지 않는다',
      );
    });
  });
}
