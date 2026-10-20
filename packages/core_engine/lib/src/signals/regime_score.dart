// 방향 스코어 — 카테고리 집계와 재정규화(`06_시스템설계/03_알고리즘.md` §1-1 · 05 GV-1).
//
// 참조 구현 = `09_백테스트/백테스트6/engine/regime.py` `direction_score`.
// 🔴 카테고리 **안**은 가중 평균(살아 있는 지표의 weight 만 분모에), 카테고리 **사이**는
//    유효 카테고리의 단순 평균이다. 제외된 카테고리에 50점(중립)을 넣지 않는다(GV-1b).
// 🔴 결측 판정은 null 비교다 — 0.0 은 유효한 값이다(03 §0-2 · GV-1e).
// 🔴 `enabled: false` 카테고리는 호출자가 아예 넘기지 않는다 — 여기 들어온 카테고리만
//    점수·제외 목록의 대상이다(03 §1-1 확정 사항).
// 🔵 지표 원값 → 백분위(`pit_percentile` 756봉)·부호 정렬·이진 지표 100/0 변환은 다음 블록
//    몫이다. 여기는 이미 0~100 으로 정렬된 지표 점수를 받는다.

/// 방향 카테고리(03 §1-1 순회 순서). `code` 는 저장·골든 표기다.
enum RegimeCategory {
  /// 추세.
  trend('TREND'),

  /// 시장 폭.
  breadth('BREADTH'),

  /// 변동성.
  volatility('VOLATILITY'),

  /// 신용.
  credit('CREDIT'),

  /// 거시.
  macro('MACRO');

  const RegimeCategory(this.code);

  /// 저장·골든 표기.
  final String code;

  /// [code] 에서 되돌린다. 모르는 값이면 [ArgumentError].
  static RegimeCategory fromCode(String code) =>
      RegimeCategory.values.firstWhere(
        (RegimeCategory c) => c.code == code,
        orElse: () =>
            throw ArgumentError.value(code, 'code', 'RegimeCategory 가 아니다'),
      );
}

/// 국면 판정 상태(03 §1-1). `code` 는 저장·골든 표기다.
enum RegimeStatus {
  /// 판정함.
  ok('OK'),

  /// 유효 카테고리(또는 추세성 지표)가 모자라 판정하지 못함 — 방향 상태 UNKNOWN · 익스포저 0.
  insufficientData('INSUFFICIENT_DATA');

  const RegimeStatus(this.code);

  /// 저장·골든 표기.
  final String code;
}

/// 살아 있는 지표 하나의 점수(0~100 · 이미 부호 정렬됨)와 가중치.
class IndicatorScore {
  /// 지표 점수를 만든다. 가중치 기본값 1.0 은 03 §1-1 «weight 키가 없으면 1.0» 이다.
  const IndicatorScore(this.score, {this.weight = 1.0});

  /// 0~100 점수.
  final double score;

  /// 카테고리 안 가중치.
  final double weight;
}

/// 카테고리 하나의 입력.
class CategoryInput {
  /// 입력을 만든다.
  const CategoryInput({required this.definedCount, required this.available});

  /// 정의된 지표 수 = `len(config.regime.categories.<cat>.indicators)`(03 §1-1).
  final int definedCount;

  /// 오늘 값이 있는 지표들(결측은 넣지 않는다).
  final List<IndicatorScore> available;
}

/// 방향 스코어 집계 결과.
class DirectionScore {
  /// 결과를 만든다 — 직접 부르지 말고 집계 함수를 쓴다.
  const DirectionScore({
    required this.status,
    required this.direction,
    required this.categories,
    required this.excluded,
  });

  /// 판정 상태.
  final RegimeStatus status;

  /// 방향 스코어 — [status] 가 INSUFFICIENT_DATA 면 null.
  final double? direction;

  /// 유효 카테고리 점수(카테고리 순서).
  final Map<RegimeCategory, double> categories;

  /// 유효 지표가 모자라 제외된 카테고리(카테고리 순서).
  final List<RegimeCategory> excluded;
}

/// 카테고리 점수 — 살아 있는 지표가 `ceil(minValidRatio × definedCount)` 개보다 적으면 null(제외).
double? categoryScore(CategoryInput input, {required double minValidRatio}) {
  if (input.definedCount < 0) {
    throw ArgumentError.value(input.definedCount, 'definedCount', '0 이상');
  }
  if (minValidRatio.isNaN || minValidRatio < 0 || minValidRatio > 1) {
    throw ArgumentError.value(minValidRatio, 'minValidRatio', '0~1 이어야 한다');
  }
  // 참조 구현과 같은 식 — 비율 × 정의 수를 double 로 곱한 뒤 올린다.
  final int need = (minValidRatio * input.definedCount).ceil();
  if (input.available.length < need) return null;
  double weightSum = 0;
  double weighted = 0;
  for (final IndicatorScore s in input.available) {
    weightSum += s.weight;
    weighted += s.score * s.weight;
  }
  if (!(weightSum > 0)) return null; // 참조 구현 `.where(wsum > 0)`
  return weighted / weightSum;
}

/// 카테고리별 입력에서 방향 스코어까지(03 §1-1 1단계).
DirectionScore aggregateDirection(
  Map<RegimeCategory, CategoryInput> categories, {
  required double minValidRatio,
}) {
  final Map<RegimeCategory, double?> scores = <RegimeCategory, double?>{
    for (final RegimeCategory c in RegimeCategory.values)
      if (categories.containsKey(c))
        c: categoryScore(categories[c]!, minValidRatio: minValidRatio),
  };
  return directionFromCategoryScores(scores);
}

/// 카테고리 점수(null = 제외)에서 방향 스코어 — 유효 카테고리의 단순 평균.
///
/// 유효 카테고리가 하나도 없으면 INSUFFICIENT_DATA(GV-1d). 합은 카테고리 순서로 더한다.
DirectionScore directionFromCategoryScores(
  Map<RegimeCategory, double?> categoryScores,
) {
  final Map<RegimeCategory, double> valid = <RegimeCategory, double>{};
  final List<RegimeCategory> excluded = <RegimeCategory>[];
  for (final RegimeCategory c in RegimeCategory.values) {
    if (!categoryScores.containsKey(c)) continue; // 꺼진 카테고리 — 어디에도 넣지 않는다
    final double? score = categoryScores[c];
    if (score == null || score.isNaN) {
      excluded.add(c);
    } else {
      valid[c] = score;
    }
  }
  if (valid.isEmpty) {
    return DirectionScore(
      status: RegimeStatus.insufficientData,
      direction: null,
      categories: valid,
      excluded: excluded,
    );
  }
  double sum = 0;
  for (final double v in valid.values) {
    sum += v;
  }
  return DirectionScore(
    status: RegimeStatus.ok,
    direction: sum / valid.length,
    categories: valid,
    excluded: excluded,
  );
}
