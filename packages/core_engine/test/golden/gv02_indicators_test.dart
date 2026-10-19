// GV-2 기술 지표 — 05 §GV-2(2a~2f · AC-B02 서브케이스 10) · 03 §0-3·§1-5.
//
// 정답지: 05 v1.22 본문 JSON 블록 7개를 원문 그대로 옮긴 것(vectors/SOURCES.md).
// 🔴 파일럿1 `GV-2_indicators.json` 은 쓰지 않는다 — 2e(BBW)·2f(ADX 값)가 없고 2d 허용오차가
//    05 v1.5 이전 값(1e-6)이다.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  // GV-2a·2b 공통 입력(05 §GV-2b «위와 동일 입력»).
  final Map<String, Object?> gv2a = loadVector('gv02a_atr_wilder.json');
  final Map<String, Object?> input = asObject(gv2a['input']);
  final List<double?> high = asNumList(input['high']);
  final List<double?> low = asNumList(input['low']);
  final List<double?> close = asNumList(input['close']);
  final int period = asInt(input['period']);

  group('GV-2a ATR (Wilder, n=3)', () {
    final Map<String, Object?> expected = asObject(gv2a['expected']);
    final double tolerance = asDouble(gv2a['tolerance']);

    test('TR — 첫 봉은 H−L', () {
      expectSeries(
        trueRange(high, low, close),
        asNumList(expected['tr']),
        tolerance,
      );
    });

    test('ATR — 인덱스 n−1 부터 값 · 첫 값은 SMA · 이후 Wilder 재귀', () {
      expectSeries(
        atr(high, low, close, period),
        asNumList(expected['atr']),
        tolerance,
      );
    });
  });

  test('GV-2b CHOP (n=3) — 인덱스 n−1 부터 값', () {
    final Map<String, Object?> v = loadVector('gv02b_chop.json');
    expectSeries(
      chop(high, low, close, period),
      asNumList(asObject(v['expected'])['chop']),
      asDouble(v['tolerance']),
    );
  });

  test('GV-2c ADX 워밍업 — 149봉이면 전부 결측', () {
    final Map<String, Object?> v = loadVector('gv02c_adx_warmup.json');
    final Map<String, Object?> in2c = asObject(v['input']);
    expect(asObject(v['expected'])['adx'], isNull);
    final int bars = asInt(in2c['bars']);
    final _Bars series = _generatorBars(bars);
    final List<double?> result = adx(
      series.high,
      series.low,
      series.close,
      period: asInt(in2c['period']),
      warmup: 150, // 05 §GV-2c «워밍업 150봉» · 03 §0-3 하드 게이트
    );
    expect(result, hasLength(bars));
    expect(result.every((double? x) => x == null), isTrue);
  });

  test('GV-2d Wilder 평활 한 걸음 — α = 1/n (표준 EMA 2/(n+1) 이 아니다)', () {
    final Map<String, Object?> v = loadVector('gv02d_wilder_rma.json');
    final Map<String, Object?> in2d = asObject(v['input']);
    final double tolerance = asDouble(
      loadVector('gv02d_tolerance.json')['tolerance'],
    );
    expect(
      rmaStep(
        asDouble(in2d['prev_rma']),
        asDouble(in2d['new_value']),
        asInt(in2d['period']),
      ),
      closeTo(asDouble(asObject(v['expected'])['rma']), tolerance),
    );
  });

  test('GV-2e Bollinger BandWidth — ddof = 0', () {
    final Map<String, Object?> v = loadVector('gv02e_bbw.json');
    final Map<String, Object?> in2e = asObject(v['input']);
    expectSeries(
      bbw(
        asNumList(in2e['close']),
        period: asInt(in2e['period']),
        numStd: asDouble(in2e['num_std']),
      ),
      asNumList(asObject(v['expected'])['bbw']),
      asDouble(v['tolerance']),
    );
  });

  group('GV-2f ADX 실제 값 (Wilder α=1/14 · 200봉 결정론 생성식)', () {
    final Map<String, Object?> v = loadVector('gv02f_adx_values.json');
    final Map<String, Object?> in2f = asObject(v['input']);
    final double tolerance = asDouble(v['tolerance']);

    test('생성식이 이 테스트가 옮긴 식과 같다', () {
      expect(
        asString(in2f['generator']),
        'base[i] = 100.0 + 0.10*i + 6.0*abs(((i % 40)/20.0) - 1.0),  i = 0..199',
      );
      expect(asString(in2f['high']), 'base + 1.5');
      expect(asString(in2f['low']), 'base - 1.5');
      expect(asString(in2f['close']), 'base + 0.5');
    });

    final _Bars series = _generatorBars(200);
    final List<double?> result = adx(
      series.high,
      series.low,
      series.close,
      period: asInt(in2f['period']),
      warmup: asInt(in2f['warmup']),
    );
    final RegExp key = RegExp(r'^adx\[(\d+)\]$');
    for (final MapEntry<String, Object?> e in asObject(v['expected']).entries) {
      final int index = int.parse(key.firstMatch(e.key)!.group(1)!);
      test(e.key, () {
        if (e.value == null) {
          expect(result[index], isNull, reason: '워밍업 구간');
        } else {
          expect(result[index], closeTo(asDouble(e.value), tolerance));
        }
      });
    }
  });
}

/// 05 §GV-2f 생성식 — 난수 없음.
_Bars _generatorBars(int count) {
  final List<double> base = <double>[
    for (int i = 0; i < count; i++)
      100.0 + 0.10 * i + 6.0 * (((i % 40) / 20.0) - 1.0).abs(),
  ];
  return _Bars(
    high: <double?>[for (final double b in base) b + 1.5],
    low: <double?>[for (final double b in base) b - 1.5],
    close: <double?>[for (final double b in base) b + 0.5],
  );
}

class _Bars {
  const _Bars({required this.high, required this.low, required this.close});
  final List<double?> high;
  final List<double?> low;
  final List<double?> close;
}
