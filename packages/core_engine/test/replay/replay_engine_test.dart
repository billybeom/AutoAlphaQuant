// E6c 재현 장부 — 참조 엔진(백테스트6) S7 실행의 원장·일별 기록이 첫 A 거래(2000-12-21) 직전까지 같은가.
//
// 정답지 = `fixtures/s7_engine.json.gz`(tool/export_replay_engine.py — N2 골든 생성기의 S7 과 같은 설정).
// 🔵 E6c 구간 = 2000-01-03 ~ 2000-12-20: 램프 3 · B 트랜치 7 · C 리밸런싱 3 행. 그 뒤 계절 A · POT · 코어 밴드 ·
//    조달은 E6d 몫이다.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'replay_engine.dart';
import 'replay_market.dart';
import 'replay_regime.dart';

const String _until = '2000-12-20';

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
      if (((r! as List<Object?>)[0]! as String).compareTo(_until) <= 0)
        r as List<Object?>,
  ];
  final Map<String, Object?> wd = want['daily']! as Map<String, Object?>;
  final List<String> wDates = <String>[
    for (final Object? d in wd['date']! as List<Object?>) d! as String,
  ];

  final ReplayEngine e = ReplayEngine(
    ReplayMarket.build(),
    ReplayRegime.build(),
  )..run(until: _until);

  test('정답지 = 골든(원장 934행 · 비용 24,289,863원)', () {
    final Map<String, Object?> meta = want['meta']! as Map<String, Object?>;
    expect(meta['n_ledger'], 934);
    expect((meta['cost_krw_sum']! as num).toDouble().round(), 24289863);
  });

  test('원장 — 2000-12-20 까지 13행 · 행마다 모든 칸이 비트 일치', () {
    expect(wantLedger, hasLength(13));
    expect(e.ledger, hasLength(wantLedger.length));
    for (int k = 0; k < wantLedger.length; k++) {
      final List<Object?> w = wantLedger[k];
      final LedgerRow g = e.ledger[k];
      final String at = '[$k] ${w[0]} ${w[1]} ${w[2]} ${w[3]}';
      expect(
        <Object>[
          g.date,
          g.sleeve,
          g.symbol,
          g.side,
          g.event,
          g.dirState,
          g.breaker,
        ],
        <Object?>[w[0], w[1], w[2], w[3], w[8], w[9], w[10]],
        reason: at,
      );
      expect(g.qty, (w[4]! as num).toDouble(), reason: '$at qty');
      expect(g.price, (w[5]! as num).toDouble(), reason: '$at price');
      expect(g.gross, (w[6]! as num).toDouble(), reason: '$at gross');
      expect(g.cost, (w[7]! as num).toDouble(), reason: '$at cost');
    }
  });

  test('일별 기록 — 2000-12-20 까지 날마다 11열 비트 일치 · 브레이커 · 방향 상태', () {
    final int n = wDates.indexWhere((String d) => d.compareTo(_until) > 0);
    expect(e.daily, hasLength(n));
    for (int k = 0; k < n; k++) {
      final DailyRow g = e.daily[k];
      expect(g.date, wDates[k]);
      for (final String col in <String>[
        'equity',
        'A',
        'B',
        'C',
        'c_krw',
        'c_park_c',
        'c_iei',
        'c_iau',
        'b_park',
        'pot',
        'dd', //
      ]) {
        final Object? w = (wd[col]! as List<Object?>)[k];
        expect(
          g.values[col],
          w == null ? isNaN : (w as num).toDouble(),
          reason: '${g.date} $col',
        );
      }
      expect(g.breaker, (wd['breaker']! as List<Object?>)[k], reason: g.date);
      expect(
        g.dirState,
        (wd['dir_state']! as List<Object?>)[k],
        reason: g.date,
      );
    }
  });

  test('numpy 평균 = 8개 누산기 짝 합산 ÷ n(왼쪽 합과 끝자리가 갈린다)', () {
    // numpy 2.5.4 실측: 이 10개의 np.mean = 3.5409999999999995 · 왼쪽 합 ÷ 10 = 3.5410000000000004.
    const List<double> a = <double>[
      0.7,
      5.5,
      9.9,
      0.3,
      2.3,
      5.5,
      0.01,
      5.5,
      0.2,
      5.5,
    ];
    expect(npMean(a), 3.5409999999999995);
    double left = 0.0;
    for (final double x in a) {
      left += x;
    }
    expect(left / 10, 3.5410000000000004);
    // n = 16 이면 누산기마다 두 번째 블록을 더한다: r_j = a_j + a_{8+j}.
    final List<double> b = <double>[
      for (int k = 0; k < 16; k++) a[k % 10] * (k + 1),
    ];
    final List<double> r = <double>[
      for (int j = 0; j < 8; j++) b[j] + b[8 + j],
    ];
    final double tree =
        ((r[0] + r[1]) + (r[2] + r[3])) + ((r[4] + r[5]) + (r[6] + r[7]));
    expect(npMean(b), tree / 16);
    // n < 8 은 0 부터 차례로.
    expect(npMean(<double>[1, 2, 3]), 2.0);
  });
}
