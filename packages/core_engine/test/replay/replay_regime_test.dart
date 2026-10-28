// E6b 재현 국면 — 앱 코드의 국면 파이프라인이 참조 엔진(백테스트6)과 같은 값을 내는가.
//
// 정답지 = `fixtures/regime_parity.json`(tool/export_replay_regime.py — 참조 엔진 regime.py 를 그대로 돌린 산출).
// 🆕 E8d1(설계 13 §8 R28 K7) — 같은 검사를 V6a(`dist_days` = ^GSPC 종가 + SPY 거래량 · 창 결측 규칙)로 한 번 더 —
//    정답지 `fixtures/regime_parity_v6a.json`(같은 도구 `--dist-volume spy`).
// 🔵 원지표(백분위 전)는 이동평균 합산 순서가 달라 끝자리가 다를 수 있다 → 표본 값을 상대 1e-12 로 본다.
//    정규화 이후(순위 기반)는 비트 해시로 본다.
// 🔴 FSM 은 03 방식(R9)이라 첫 유효 봉 뒤 9봉(1985-11-14~26)만 참조 엔진과 다르다 — 그 뒤는 상태·나이·추세성
//    모두 같아야 한다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'parity_hash.dart';
import 'replay_market.dart';
import 'replay_regime.dart';

void main() {
  group(
    '골든 — ^GSPC 거래량',
    () => _parity(
      'test/replay/fixtures/regime_parity.json',
      DistVolumeSource.gspcIndex,
    ),
  );
  group(
    '🆕 V6a — SPY 거래량(R28)',
    () => _parity(
      'test/replay/fixtures/regime_parity_v6a.json',
      DistVolumeSource.spyEtf,
    ),
  );
}

void _parity(String path, DistVolumeSource dv) {
  final Map<String, Object?> want =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  Map<String, Object?> obj(Object? o) => o! as Map<String, Object?>;
  int nans(List<double?> v) =>
      v.where((double? x) => x == null || x.isNaN).length;
  double? py(String s) => s == 'nan' ? null : double.parse(s);

  final ReplayRegime g = ReplayRegime.build(distVolume: dv);
  final Map<String, int> pos = <String, int>{
    for (int i = 0; i < g.calendar.length; i++) g.calendar[i]: i,
  };

  test('달력 = 전체 US 세션', () {
    final Map<String, Object?> c = obj(want['calendar']);
    expect(g.calendar, hasLength(c['n']));
    expect(g.calendar.first, c['first']);
    expect(g.calendar.last, c['last']);
  });

  group('원지표 13개 — 결측 수 일치 · 표본 상대 1e-12', () {
    for (final MapEntry<String, Object?> e in obj(want['raw']).entries) {
      test(e.key, () {
        final List<double?> got = g.raw[e.key]!;
        expect(nans(got), obj(e.value)['nan'], reason: '결측');
        for (final MapEntry<String, Object?> s in obj(
          obj(e.value)['samples'],
        ).entries) {
          final double? w = py(s.value! as String);
          final double? v = got[pos[s.key]!];
          if (w == null) {
            expect(v == null || v.isNaN, isTrue, reason: s.key);
          } else {
            expect(
              v,
              closeTo(w, 1e-12 * (w.abs() > 1 ? w.abs() : 1)),
              reason: s.key,
            );
          }
        }
      });
    }
  });

  group('정규화 13개 — 비트 일치', () {
    for (final MapEntry<String, Object?> e in obj(want['normalized']).entries) {
      test(e.key, () {
        final List<double?> got = g.normalized[e.key]!;
        expect(nans(got), obj(e.value)['nan']);
        expect(floatHash(got), obj(e.value)['sha256']);
      });
    }
  });

  group('방향 스코어 — 카테고리 5개 · 방향 비트 일치', () {
    for (final MapEntry<String, Object?> e in obj(want['categories']).entries) {
      test(e.key, () {
        final RegimeCategory c = RegimeCategory.values.firstWhere(
          (RegimeCategory x) => x.name == e.key,
        );
        expect(
          floatHash(<double?>[
            for (final DirectionScore d in g.direction) d.categories[c],
          ]),
          e.value,
        );
      });
    }
    test('direction', () {
      final List<double?> got = <double?>[
        for (final DirectionScore d in g.direction) d.direction,
      ];
      expect(nans(got), obj(want['direction'])['nan']);
      expect(floatHash(got), obj(want['direction'])['sha256']);
    });
  });

  group('추세성 — 세 부분 · 스코어 비트 일치', () {
    for (final MapEntry<String, Object?> e in obj(
      want['trendiness_parts'],
    ).entries) {
      test(
        e.key,
        () => expect(floatHash(g.trendinessPartScores[e.key]!), e.value),
      );
    }
    test('trendiness', () {
      expect(nans(g.trendiness), obj(want['trendiness'])['nan']);
      expect(floatHash(g.trendiness), obj(want['trendiness'])['sha256']);
    });
  });

  group('FSM — 03 방식(R9) · 1985-11-27 이후 참조 엔진과 같다', () {
    final Map<String, Object?> f = obj(want['fsm']);
    final int from = pos[f['compare_from']! as String]!;
    test('데이터 부족 봉 수 · 첫 유효 봉', () {
      expect(
        g.fsm
            .where((RegimeDay d) => d.status == RegimeStatus.insufficientData)
            .length,
        f['insufficient_days'],
      );
      final int firstOk = g.fsm.indexWhere(
        (RegimeDay d) => d.status == RegimeStatus.ok,
      );
      expect(g.calendar[firstOk], f['first_ok']);
    });
    test('상태 · 나이 · 추세성(비교 시작일부터)', () {
      final List<RegimeDay> tail = g.fsm.sublist(from);
      expect(
        lineHash(tail.map((RegimeDay d) => d.directionState.code)),
        f['state_from_sha256'],
      );
      expect(
        lineHash(tail.map((RegimeDay d) => d.barsInState)),
        f['bars_from_sha256'],
      );
      expect(
        lineHash(tail.map((RegimeDay d) => d.trendState.code)),
        f['trend_from_sha256'],
      );
    });
    test('첫 유효 봉 뒤 9봉 — 참조 엔진 NEUTRAL(내부 상태 유지) · 03 UNKNOWN(나이는 1부터 셈)', () {
      final Map<String, Object?> early = obj(f['early']);
      int k = 0;
      for (final MapEntry<String, Object?> e in early.entries) {
        final RegimeDay d = g.fsm[pos[e.key]!];
        final List<Object?> eng = e.value! as List<Object?>;
        if (e.key == f['compare_from']) {
          expect(d.directionState.code, eng[0], reason: e.key);
          expect(d.barsInState, eng[1], reason: e.key);
        } else {
          expect(eng[0], 'NEUTRAL', reason: e.key);
          expect(d.directionState, DirectionState.unknown, reason: e.key);
          expect(d.barsInState, eng[1], reason: '${e.key} 나이는 같게 센다');
          k++;
        }
      }
      expect(k, 9);
    });
    test('상태 분포 = 참조 엔진에서 9봉만 NEUTRAL → UNKNOWN', () {
      final Map<String, Object?> counts = obj(f['state_counts']);
      final Map<String, int> got = <String, int>{};
      for (final RegimeDay d in g.fsm) {
        got[d.directionState.code] = (got[d.directionState.code] ?? 0) + 1;
      }
      expect(got['BULL'], counts['BULL']);
      expect(got['BEAR'], counts['BEAR']);
      expect(got['NEUTRAL'], (counts['NEUTRAL']! as int) - 9);
      expect(got['UNKNOWN'], (counts['UNKNOWN']! as int) + 9);
    });
    test('2000~2026 KR 월말 상태 = 정답지', () {
      final ReplayMarket m = ReplayMarket.build();
      final DatedSeries code = DatedSeries(g.calendar, <double>[
        for (final RegimeDay d in g.fsm) d.directionState.index.toDouble(),
      ]);
      final Map<String, int> got = <String, int>{};
      for (final String d in m.krMonthEnds) {
        final int p = code.lastAtOrBefore(d);
        final String s = p < 0 ? 'UNKNOWN' : g.fsm[p].directionState.code;
        got[s] = (got[s] ?? 0) + 1;
      }
      expect(got, obj(f['kr_month_end_counts_2000_2026']));
    });
  });

  group('KOSDAQ 추세 점수(tskr) — 비트 일치', () {
    final Map<String, Object?> t = obj(want['tskr']);
    test('달력', () {
      expect(g.kosdaqCalendar, hasLength(obj(t['calendar'])['n']));
      expect(g.kosdaqCalendar.first, obj(t['calendar'])['first']);
    });
    for (final MapEntry<String, Object?> e in obj(t['parts']).entries) {
      test(e.key, () => expect(floatHash(g.tskrParts[e.key]!), e.value));
    }
    test('tskr', () {
      expect(nans(g.tskr), t['nan']);
      expect(floatHash(g.tskr), t['sha256']);
      final Map<String, int> kp = <String, int>{
        for (int i = 0; i < g.kosdaqCalendar.length; i++)
          g.kosdaqCalendar[i]: i,
      };
      for (final MapEntry<String, Object?> s in obj(t['samples']).entries) {
        final double? w = py(s.value! as String);
        final double? v = g.tskr[kp[s.key]!];
        expect(v, w, reason: s.key);
      }
    });
  });
}
