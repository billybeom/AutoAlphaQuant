// 골든벡터 GV-16 `pit_percentile` 룩어헤드 · 워밍업(안전 게이트 AC-S11) 판정(E11o-c2 · 설계 13 §8 R165) — 03 §1-6 · NR-9.
//
// 🆕 Dart 로 옮긴 적이 없던 게이트다 — 기기 실행기 «전량» 확인(05 계열 처리 구분표)에서 발견했다(P-2 «엔진 관련 AC-S 게이트»).
// 정답지 = 05 v1.23 §GV-16 코드 블록 원문(`gv16_pit_percentile.json` · vectors/SOURCES.md).
// 🔴 `out[799]` 만 보면 «전 표본 rank 후 마스킹» 오구현과 같다 — `out[755]` · `out[760]` 과 절단 불변식이 본체다(05 §GV-16).
// 🔴 불변식 두 줄은 정답지에 산문으로만 있다 — 그 산문이 이 판정이 옮긴 식과 같은지 먼저 본다(GV-2f 생성식과 같은 방식).

import 'dart:math' as math;

import '../signals/percentile.dart' show pitPercentile;
import 'golden_runner.dart';

const String _generator = 's[i] = sin(i/17.0)*100.0 + i*0.05,  i = 0..799';
const String _truncation =
    'pit_percentile(s)[755:760] == pit_percentile(s[:760])[755:760]  (절대오차 1e-9)';
const String _warmup =
    'len(s) = 40 인 시리즈에서는 pit_percentile(s)가 전부 NaN (유효값 0개)';

/// 05 §GV-16 생성식 — 난수 없음.
List<double?> _series(int count) => <double?>[
  for (int i = 0; i < count; i++) math.sin(i / 17.0) * 100.0 + i * 0.05,
];

/// GV-16 `pit_percentile` — 값 4 · 절단 불변식 · 워밍업 불변식.
class Gv16PitPercentile implements GoldenFamily {
  /// 만든다.
  const Gv16PitPercentile();

  @override
  String get id => 'GV-16';

  @override
  Set<String> get files => const <String>{'gv16_pit_percentile.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> v = b.json('gv16_pit_percentile.json');
    final Map<String, Object?> input = gvObject(v['input']);
    final Map<String, Object?> invariants = gvObject(v['invariants']);
    final double tol = gvDouble(v['tolerance']);
    final int minPeriods = gvInt(input['min_periods']);
    final List<double?> winsor = gvNumList(input['winsor']);
    List<double?> pit(List<double?> s) => pitPercentile(
      s,
      minPeriods: minPeriods,
      lowerQuantile: winsor.first ?? double.nan,
      upperQuantile: winsor.last ?? double.nan,
    );
    List<double?>? full;
    List<double?> fullOnce() => full ??= pit(_series(800));
    final RegExp key = RegExp(r'^out\[(\d+)\]$');

    return <GvCase>[
      GvCase(
        'GV-16 생성식 · 불변식 산문 = 이 판정이 옮긴 식',
        () =>
            (GvProbe()
                  ..same(gvString(input['generator']), _generator, 'generator')
                  ..same(winsor.length, 2, 'winsor')
                  ..same(
                    gvString(invariants['truncation']),
                    _truncation,
                    'truncation',
                  )
                  ..same(gvString(invariants['warmup']), _warmup, 'warmup'))
                .failure,
      ),
      for (final MapEntry<String, Object?> e in gvObject(v['expected']).entries)
        GvCase('GV-16 ${e.key}', () {
          final RegExpMatch? m = key.firstMatch(e.key);
          if (m == null) return '키 꼴이 아니다: ${e.key}';
          final double? got = fullOnce()[int.parse(m.group(1)!)];
          final Object? want = e.value;
          return want == null
              ? (GvProbe()..none(got, '워밍업 구간')).failure
              : (GvProbe()..close(got, gvDouble(want), tol, e.key)).failure;
        }),
      GvCase('GV-16 절단 불변식 — 미래 관측이 과거 값을 바꾸지 않는다', () {
        final List<double?> head = pit(_series(760));
        final GvProbe p = GvProbe();
        for (int i = 755; i < 760; i++) {
          final double? a = fullOnce()[i];
          final double? c = head[i];
          if (a == null || c == null) {
            p.truth(false, '[$i] 결측(전체 $a · 앞 760 $c)');
          } else {
            p.close(a, c, 1e-9, '[$i]');
          }
        }
        return p.failure;
      }),
      GvCase(
        'GV-16 워밍업 불변식 — 40봉이면 전부 결측',
        () =>
            (GvProbe()..truth(
                  pit(_series(40)).every((double? x) => x == null),
                  '40봉 시리즈에 유효값이 있으면 안 된다',
                ))
                .failure,
      ),
    ];
  }
}
