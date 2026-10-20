// E6d 재현 — 참조 엔진(백테스트6) S7(P0S 정본) 26년 실행의 원장 934행 · 일별 6,900행 전체가 같은가.
//
// 정답지 = `fixtures/s7_engine.json.gz`(tool/export_replay_engine.py — N2 골든 생성기의 S7 과 같은 설정).
// 🔴 어긋나면 «첫 갈림» 한 곳만 알린다 — 그 뒤는 연쇄로 갈리므로 첫 지점이 원인이다(설계 13 §8 R1).

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'replay_engine.dart';
import 'replay_market.dart';
import 'replay_regime.dart';

void main() {
  final Map<String, Object?> want = jsonDecode(
    utf8.decode(
      gzip.decode(
        File('test/replay/fixtures/s7_engine.json.gz').readAsBytesSync(),
      ),
    ),
  ) as Map<String, Object?>;
  final List<List<Object?>> wantLedger = <List<Object?>>[
    for (final Object? r in want['ledger']! as List<Object?>)
      r! as List<Object?>,
  ];
  final Map<String, Object?> wd = want['daily']! as Map<String, Object?>;
  final List<Object?> wDates = wd['date']! as List<Object?>;

  final ReplayEngine e = ReplayEngine(
    ReplayMarket.build(),
    ReplayRegime.build(),
  )..run();

  String? firstLedgerDiff() {
    final int n = e.ledger.length < wantLedger.length
        ? e.ledger.length
        : wantLedger.length;
    for (int k = 0; k < n; k++) {
      final List<Object?> w = wantLedger[k];
      final LedgerRow g = e.ledger[k];
      final List<Object?> got = <Object?>[
        g.date,
        g.sleeve,
        g.symbol,
        g.side,
        g.qty,
        g.price,
        g.gross,
        g.cost,
        g.event, //
        g.dirState, g.breaker,
      ];
      for (int c = 0; c < got.length; c++) {
        final Object? a = got[c];
        final Object? b = w[c];
        final bool same = a is double ? b is num && a == b.toDouble() : a == b;
        if (!same) return '원장 [$k] 칸 $c: Dart $a ↔ 엔진 $b · 행 Dart $got · 엔진 $w';
      }
    }
    if (e.ledger.length != wantLedger.length) {
      return '원장 길이 Dart ${e.ledger.length} ↔ 엔진 ${wantLedger.length}';
    }
    return null;
  }

  String? firstDailyDiff() {
    if (e.daily.length != wDates.length) {
      return '일별 길이 Dart ${e.daily.length} ↔ 엔진 ${wDates.length}';
    }
    for (int k = 0; k < wDates.length; k++) {
      final DailyRow g = e.daily[k];
      if (g.date != wDates[k]) return '일별 [$k] 날짜 ${g.date} ↔ ${wDates[k]}';
      for (final String col in g.values.keys) {
        final Object? w = (wd[col]! as List<Object?>)[k];
        final double v = g.values[col]!;
        final bool same = w == null ? v.isNaN : v == (w as num).toDouble();
        if (!same) return '일별 ${g.date} $col: Dart $v ↔ 엔진 $w';
      }
      if (g.breaker != (wd['breaker']! as List<Object?>)[k]) {
        return '일별 ${g.date} 브레이커';
      }
      if (g.dirState != (wd['dir_state']! as List<Object?>)[k]) {
        return '일별 ${g.date} 방향';
      }
    }
    return null;
  }

  test('원장 934행 — 모든 칸 비트 일치(첫 갈림 없음)', () {
    expect(firstLedgerDiff(), isNull);
    expect(e.ledger, hasLength(934));
  });

  test('원장 비용 합계 = 24,289,863원(골든)', () {
    double sum = 0.0;
    for (final LedgerRow r in e.ledger) {
      sum += r.cost;
    }
    expect(sum.round(), 24289863);
  });

  test('일별 6,900행 — 11열 · 브레이커 · 방향 비트 일치(첫 갈림 없음)', () {
    expect(firstDailyDiff(), isNull);
  });
}
