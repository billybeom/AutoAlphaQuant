// 성과 시리즈 픽스처 읽기 보조 — C-10(⑤⑥⑦) · C-36 공용(🆕 계약 v1.3 · 01 §13-12) ·
// 🆕 v1.4 목표 경로 행(`GoalPathVm` — C-10 편입 · C-39 · 01 §14-10).
//
// 🔴 이 파일에는 **테스트가 없다**(`_test.dart` 접미가 없다). 판정도 하지 않는다 —
//    「어느 값이 맞는가」는 각 C-n 파일에 있다. 여기는 ① 성과 시리즈 행을 **모양으로 찾고**
//    ② 메모리 안에서 **망가뜨린 사본**을 만드는 일만 한다.
// 🔴 픽스처 **파일을 고치지 않는다** — 사본은 `jsonDecode(jsonEncode(...))` 로 뜬 뒤 고친다.
//    그래서 «검사가 늘 참인가»를 디스크에 손대지 않고 확인할 수 있다.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';

import '../c00_support.dart';

/// 계약 v1.3 이 아는 성과 시리즈 픽스처(8건 · 시리즈 9행).
///
/// 🔴 검사는 이 목록이 아니라 [allPerfSeriesRows] 가 **모양으로 찾은 것**을 본다 —
///    새 성과 픽스처가 들어오면 목록을 고치지 않아도 검사를 받는다.
///    이 목록은 «찾은 것이 줄지 않았는가»(입력 없는 검사 방지)를 보는 바닥이다.
const List<String> knownPerfSeriesFixtures = <String>[
  FixturePaths.performance24m,
  FixturePaths.m7M7PerfDailyGap,
  FixturePaths.m7M7PerfDailyManual,
  FixturePaths.m7M7PerfMaskedIntegrity,
  FixturePaths.m7M7PerfMonthlyPeriod,
  FixturePaths.m7M7PerfMonthlySimSplit,
  FixturePaths.m7M7PerfUnavailableGap,
  FixturePaths.m7M7PerfYearly,
];

/// 성과 시리즈 1행(픽스처 경로 · 행 순번 · 원문 JSON).
class PerfSeriesRow {
  const PerfSeriesRow(this.path, this.index, this.json);

  final String path;
  final int index;

  /// 행 원문. 🔴 고치지 않는다 — 고칠 때는 [mutated] 로 사본을 뜬다.
  final Map<String, Object?> json;

  /// 실패 메시지에 쓰는 자리 표시.
  String get where => '$path rows[$index]';

  PerformanceSeries get series => PerformanceSeries.fromJson(json);

  /// 원문을 깊게 복사해 [edit] 로 고친 뒤 DTO 로 읽는다(원문·파일 무변경).
  PerformanceSeries mutated(void Function(Map<String, Object?> json) edit) {
    final Map<String, Object?> copy = deepCopyJson(json);
    edit(copy);
    return PerformanceSeries.fromJson(copy);
  }
}

/// 전 픽스처에서 성과 시리즈 행을 **모양으로** 찾는다.
///
/// 모양 = `metric` · `granularity` · `points` · `segments` 키를 모두 가진 행.
/// (`m7_goal_path_*`(`GoalPathVm`)은 🆕 v1.4 부터 `points` 대신 `planned`·`actual` 두 목록이고
/// `metric` 이 없다 — 이 모양에 잡히지 않는다. 목표 경로 행은 [allGoalPathRows] 가 찾고
/// C-10(편입)·C-39 가 검사한다.)
List<PerfSeriesRow> allPerfSeriesRows() {
  final List<PerfSeriesRow> out = <PerfSeriesRow>[];
  for (final String path in FixturePaths.all) {
    final List<Map<String, Object?>> rows = decodeEnvelope(readFixture(path))
        .rows;
    for (int i = 0; i < rows.length; i++) {
      final Map<String, Object?> row = rows[i];
      if (row.containsKey('metric') &&
          row.containsKey('granularity') &&
          row.containsKey('points') &&
          row.containsKey('segments')) {
        out.add(PerfSeriesRow(path, i, row));
      }
    }
  }
  return out;
}

/// 🆕 v1.4(01 §14-10) — 계약 v1.4 가 아는 목표 경로 픽스처(4건 · 행 4 · 유지·이탈·유보·실전 조건).
///
/// 🔴 [knownPerfSeriesFixtures] 와 같은 뜻의 바닥이다 — 검사는 [allGoalPathRows] 가 모양으로 찾은 것을 본다.
const List<String> knownGoalPathFixtures = <String>[
  FixturePaths.m7M7GoalPathOn,
  FixturePaths.m7M7GoalPathOff,
  FixturePaths.m7M7GoalPathHold,
  FixturePaths.m7M7GoalPathRealworld,
];

/// 🆕 v1.4 — 목표 경로 1행(`GoalPathVm` · 픽스처 경로 · 행 순번 · 원문 JSON).
class GoalPathRow {
  const GoalPathRow(this.path, this.index, this.json);

  final String path;
  final int index;

  /// 행 원문. 🔴 고치지 않는다 — 고칠 때는 [mutated] 로 사본을 뜬다.
  final Map<String, Object?> json;

  /// 실패 메시지에 쓰는 자리 표시.
  String get where => '$path rows[$index]';

  GoalPathVm get vm => GoalPathVm.fromJson(json);

  /// 원문을 깊게 복사해 [edit] 로 고친 뒤 DTO 로 읽는다(원문·파일 무변경).
  GoalPathVm mutated(void Function(Map<String, Object?> json) edit) {
    final Map<String, Object?> copy = deepCopyJson(json);
    edit(copy);
    return GoalPathVm.fromJson(copy);
  }
}

/// 🆕 v1.4 — 전 픽스처에서 목표 경로 행을 **모양으로** 찾는다.
///
/// 모양 = `planned` · `actual` · `y_ticks` · `segments` 키를 모두 가진 행.
List<GoalPathRow> allGoalPathRows() {
  final List<GoalPathRow> out = <GoalPathRow>[];
  for (final String path in FixturePaths.all) {
    final List<Map<String, Object?>> rows = decodeEnvelope(readFixture(path))
        .rows;
    for (int i = 0; i < rows.length; i++) {
      final Map<String, Object?> row = rows[i];
      if (row.containsKey('planned') &&
          row.containsKey('actual') &&
          row.containsKey('y_ticks') &&
          row.containsKey('segments')) {
        out.add(GoalPathRow(path, i, row));
      }
    }
  }
  return out;
}

/// 🆕 v1.4 — 픽스처 한 건의 [index] 번째 목표 경로 행.
GoalPathRow goalPathRow(String path, {int index = 0}) =>
    GoalPathRow(path, index, decodeEnvelope(readFixture(path)).rows[index]);

/// 픽스처 한 건의 [index] 번째 성과 시리즈 행.
PerfSeriesRow perfSeriesRow(String path, {int index = 0}) =>
    PerfSeriesRow(path, index, decodeEnvelope(readFixture(path)).rows[index]);

/// JSON 객체의 깊은 사본.
Map<String, Object?> deepCopyJson(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

/// `json[key]` 를 객체 목록으로 읽는다(사본을 고칠 때 쓴다 — 고치면 원 목록이 바뀐다).
List<Map<String, Object?>> jsonObjects(Map<String, Object?> json, String key) =>
    (json[key]! as List<Object?>).cast<Map<String, Object?>>();

/// 점이 구간의 정규 범위 `[startNormalized, endNormalized]` 안에 있는가.
///
/// 🔴 v1.3 — 화면은 구간의 `from`·`to` 를 점의 날짜와 비교하지 않는다(01 §13-3).
///    띠와 점의 짝은 정규 자리로 본다.
bool inBand(PerfSegment seg, PerfPoint p) =>
    seg.startNormalized <= p.xNormalized && p.xNormalized <= seg.endNormalized;

/// 점의 날짜가 구간의 `[from, to]` 안에 있는가(엔진 쪽 사실 — C-36 ⑥ 이 둘을 견준다).
bool inDateRange(PerfSegment seg, PerfPoint p) =>
    seg.from.yyyyMmDd.compareTo(p.date.yyyyMmDd) <= 0 &&
    seg.to.yyyyMmDd.compareTo(p.date.yyyyMmDd) >= 0;
