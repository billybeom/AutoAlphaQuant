// GV-1 방향 스코어 — 카테고리 재정규화(05 §GV-1 · AC-B01 서브케이스 7) · 03 §1-1.
//
// 정답지: 05 v1.22 본문 JSON 블록 5개 원문(vectors/SOURCES.md).
// 🔴 파일럿1 `GV-1_regime_categories.json` 은 쓰지 않는다 — 1c 의 BREADTH 가 v1.5 가
//    «판별력 0» 으로 고친 옛 값(60.0)이고 1e 가 없다.
// 허용오차: 1a~1d 블록에는 값이 없어 03 §0-4 «스코어 1e-4» 를 쓴다(1e 블록과 같은 값).

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

const double _scoreTolerance = 1e-4; // 03 §0-4

/// `category_scores` 객체 → 카테고리 점수 맵(null = 제외).
Map<RegimeCategory, double?> _scores(Object? json) => <RegimeCategory, double?>{
  for (final MapEntry<String, Object?> e in asObject(json).entries)
    RegimeCategory.fromCode(e.key): e.value == null ? null : asDouble(e.value),
};

void main() {
  for (final (String id, String file) in <(String, String)>[
    ('1a', 'gv01a_all_valid.json'),
    ('1b', 'gv01b_two_missing.json'),
  ]) {
    test('GV-$id 유효 카테고리의 단순 평균', () {
      final Map<String, Object?> v = loadVector(file);
      final DirectionScore r = directionFromCategoryScores(
        _scores(asObject(v['input'])['category_scores']),
      );
      expect(r.status, RegimeStatus.ok);
      expect(
        r.direction,
        closeTo(
          asDouble(asObject(v['expected'])['direction']),
          _scoreTolerance,
        ),
        reason: '결측 카테고리에 50점을 넣으면 56.0 이 나온다(GV-1b) — 오답',
      );
    });
  }

  test('GV-1c 카테고리 안 지표가 50% 미달이면 그 카테고리를 뺀다', () {
    final Map<String, Object?> v = loadVector('gv01c_category_exclusion.json');
    final Map<String, Object?> input = asObject(v['input']);
    final Map<String, Object?> defined = asObject(
      input['category_definitions'],
    );
    final Map<String, Object?> available = asObject(
      input['available_indicators'],
    );
    final Map<String, Object?> means = asObject(input['indicator_means']);
    // 벡터는 지표 수와 평균만 준다 — 평균이 같은 지표 n개로 펼쳐 집계 함수에 넣는다(05 §GV-1c 📌).
    final DirectionScore r = aggregateDirection(
      <RegimeCategory, CategoryInput>{
        for (final String code in defined.keys)
          RegimeCategory.fromCode(code): CategoryInput(
            definedCount: asInt(defined[code]),
            available: List<IndicatorScore>.filled(
              asInt(available[code]),
              IndicatorScore(asDouble(means[code])),
            ),
          ),
      },
      minValidRatio: 0.5,
    ); // 설정 키 regime.category_min_valid_ratio 기본값(05 §GV-1c)
    final Map<String, Object?> expected = asObject(v['expected']);
    expect(
      r.excluded.map((RegimeCategory c) => c.code).toList(),
      asStringList(expected['excluded_categories']),
    );
    expect(
      r.direction,
      closeTo(asDouble(expected['direction']), _scoreTolerance),
      reason: '50% 임계를 빠뜨리면 (80+90+40)/3 = 70.0 이 나온다',
    );
  });

  test('GV-1d 전 카테고리 결측 → INSUFFICIENT_DATA · 방향 null', () {
    final Map<String, Object?> v = loadVector('gv01d_all_missing.json');
    final DirectionScore r = directionFromCategoryScores(
      _scores(asObject(v['input'])['category_scores']),
    );
    final Map<String, Object?> expected = asObject(v['expected']);
    expect(r.status.code, asString(expected['status']));
    expect(r.direction, isNull);
    expect(expected['direction'], isNull);
  });

  group('GV-1e 0.0 은 결측이 아니다', () {
    final Map<String, Object?> v = loadVector('gv01e_zero_is_not_missing.json');
    final double tolerance = asDouble(v['tolerance']);
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      test('GV-1${asString(c['id'])}', () {
        final DirectionScore r = directionFromCategoryScores(
          _scores(asObject(c['input'])['category_scores']),
        );
        final Map<String, Object?> expected = asObject(c['expected']);
        expect(r.status.code, asString(expected['status']));
        expect(
          r.direction,
          closeTo(asDouble(expected['direction']), tolerance),
        );
      });
    }
  });
}
