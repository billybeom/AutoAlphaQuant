// 성과 선(線) 단언 — C-10(⑤⑥⑦) · C-36(①③④④b⑥⑦⑨⑪) · C-39 공용(🆕 계약 v1.4 · 01 §14-10 · §14-11).
//
// 🔴 이 파일에는 **테스트가 없다**(`_test.dart` 접미가 없다). 여기 있는 것은 «점 목록 하나·눈금 목록
//    하나·구간 목록 하나»를 받아 위반 문장을 돌려주는 **규칙 함수**뿐이다. 어느 행에 어느 규칙을
//    거는가(대상 고르기)와 통과/실패 판정은 각 C-n 파일에 있다.
// 🔴 왜 따로 뺐나: v1.3 까지는 `PerformanceSeries`(점 목록 1 + 벤치마크) 하나만 이 규칙을 받았다.
//    v1.4 의 `GoalPathVm` 은 같은 `PerfPoint`·`PerfAxisTick`·`PerfSegment` 를 **두 목록**
//    (`planned`·`actual`)으로 싣는다 — 같은 뜻의 규칙을 두 벌로 적으면 한쪽이 낡는다(설계 Δ4 «헬퍼 재사용»).
// 🔴 위반 문장은 v1.3 원문 그대로다 — C-10·C-36 의 «망가뜨린 사본» 검사가 그 글자를 찾는다.

import 'package:domain_contracts/domain_contracts.dart';

import 'perf_series_rows.dart';

/// C-36 ⑨ 엔진 기본 구간의 점 수 상한(01 §13-1).
const int maxPerfPoints = 60;

/// C-36 ④ 눈금 수 상한.
const int maxPerfTicks = 5;

/// C-36 ⑪ `value` 두 개를 같다고 보는 차(소수 넷째 자리 반올림의 절반).
const double samePerfValue = 0.00005;

/// C-36 ⑦ · C-39 ⑨ — `PerfPoint.value` 참조. 괄호가 바로 오는 생성자(`Future<void>.value()`·
/// `Stream.value(x)`)와 `valueOrNull` 은 통과한다.
final RegExp perfValueRef = RegExp(r'\.value\b(?!OrNull)(?!\s*\()');

/// C-36 ⑦ · C-39 ⑨ 둘째 — 패턴 분해로 읽는 `value`(`final PerfPoint(:value) = p;` ·
/// `case PerfPoint(value: final v):`). 점(`.`)이 없어 [perfValueRef] 가 못 잡는다.
final RegExp perfValuePattern = RegExp(r'PerfPoint\s*\([^)]*\bvalue\b');

/// C-36 ① `xNormalized` 는 0.0~1.0 이고 엄격히 증가한다(점이 1개면 0.5).
List<String> xLineViolations(String where, String key, List<PerfPoint> points) {
  final List<String> bad = <String>[];
  for (int i = 0; i < points.length; i++) {
    final double x = points[i].xNormalized;
    if (x < 0.0 || x > 1.0) {
      bad.add('$where $key[$i] x=$x — 0.0~1.0 밖');
    }
    if (i > 0 && x <= points[i - 1].xNormalized) {
      bad.add(
        '$where $key[$i] x=$x — 앞 점(${points[i - 1].xNormalized})보다 '
        '크지 않다',
      );
    }
  }
  if (points.length == 1 && points.single.xNormalized != 0.5) {
    bad.add('$where $key — 점이 1개면 0.5 다(지금 ${points.single.xNormalized})');
  }
  return bad;
}

/// C-36 ③ 점의 글자(`dateText`·`valueText`)가 비어 있지 않다(결측 점에도 글자가 온다).
List<String> pointTextViolations(
  String where,
  String key,
  List<PerfPoint> points,
) {
  final List<String> bad = <String>[];
  for (int i = 0; i < points.length; i++) {
    final PerfPoint p = points[i];
    if (p.dateText.trim().isEmpty) {
      bad.add('$where $key[$i] — date_text 가 비었다');
    }
    if (p.valueText.trim().isEmpty) {
      bad.add('$where $key[$i] — value_text 가 비었다(결측 점에도 글자가 온다)');
    }
  }
  return bad;
}

/// C-36 ④ 눈금: 오름차순 · 글자 있음 · 기준선 많아야 1 · [maxPerfTicks] 개 이하.
///
/// 🔴 «기준선 **정확히** 1»이 아니다 — 목표 경로(금액 축)는 기준선이 0개다(설계 단계 ② notes).
List<String> tickViolations(String where, List<PerfAxisTick> ticks) {
  final List<String> bad = <String>[];
  if (ticks.length > maxPerfTicks) {
    bad.add('$where — 눈금 ${ticks.length}개(많아야 $maxPerfTicks)');
  }
  if (ticks.where((PerfAxisTick t) => t.isBaseline).length > 1) {
    bad.add('$where — 기준선 눈금이 둘 이상이다');
  }
  for (int i = 0; i < ticks.length; i++) {
    if (ticks[i].label.trim().isEmpty) {
      bad.add('$where y_ticks[$i] — label 이 비었다');
    }
    if (i > 0 && ticks[i].normalized <= ticks[i - 1].normalized) {
      bad.add('$where y_ticks[$i] — 오름차순이 아니다');
    }
  }
  return bad;
}

/// C-36 ④b 구간은 받은 순서대로이고 서로 겹치지 않는다(앞 구간 end ≤ 뒤 구간 start).
List<String> segmentOrderViolations(String where, List<PerfSegment> segments) {
  final List<String> bad = <String>[];
  for (int i = 1; i < segments.length; i++) {
    final PerfSegment prev = segments[i - 1];
    final PerfSegment cur = segments[i];
    if (cur.startNormalized < prev.startNormalized) {
      bad.add('$where segments[$i] — start 가 앞 구간보다 작다(받은 순서가 아니다)');
    }
    if (prev.endNormalized > cur.startNormalized) {
      bad.add(
        '$where segments[$i] — 앞 구간 end ${prev.endNormalized} > '
        'start ${cur.startNormalized}(겹친다)',
      );
    }
  }
  return bad;
}

/// C-36 ⑥ 구간: `start ≤ end` · «날짜로 덮는 점» == «정규 자리로 덮는 점» · 측정 아닌 구간의 글자.
///
/// [points] 는 구간이 딸린 본선이다(성과 시리즈 = `points` · 목표 경로 = `actual`).
List<String> segmentCoverViolations(
  String where,
  List<PerfSegment> segments,
  List<PerfPoint> points,
) {
  final List<String> bad = <String>[];
  for (int i = 0; i < segments.length; i++) {
    final PerfSegment seg = segments[i];
    if (seg.startNormalized > seg.endNormalized) {
      bad.add('$where segments[$i] — start > end');
    }
    final List<int> byDate = <int>[
      for (int k = 0; k < points.length; k++)
        if (inDateRange(seg, points[k])) k,
    ];
    final List<int> byBand = <int>[
      for (int k = 0; k < points.length; k++)
        if (inBand(seg, points[k])) k,
    ];
    if (byDate.join(',') != byBand.join(',')) {
      bad.add('$where segments[$i] — 날짜로 덮는 점 $byDate ≠ 정규 자리로 덮는 점 $byBand');
    }
    if (seg.kind != SegmentKind.measured && seg.label.trim().isEmpty) {
      bad.add('$where segments[$i] — 측정 아닌 구간의 label 이 비었다(캡션이 없다)');
    }
  }
  return bad;
}

/// C-36 ⑨ 점은 많아야 [maxPerfPoints] 개다.
List<String> pointCountViolations(
  String where,
  String key,
  List<PerfPoint> points,
) => <String>[
  if (points.length > maxPerfPoints)
    '$where $key — 점 ${points.length}개(많아야 $maxPerfPoints)',
];

/// 값 있는 점 1개(C-36 ⑪ — 어느 선의 몇 번째 점인지와 함께).
typedef ValuedPerfPoint = ({String at, double value, double y});

/// 한 축을 쓰는 선들([lines] · `이름 → 점 목록`)의 값 있는 점을 `value` 오름차순으로
/// (같으면 받은 순서 그대로).
///
/// 🔴 선들은 **같은 축**을 쓴다(01 §13-1 · 목표 경로는 §14-11) — 그래서 한데 모아 견준다.
List<ValuedPerfPoint> valuedPerfPoints(Map<String, List<PerfPoint>> lines) {
  final List<ValuedPerfPoint> out = <ValuedPerfPoint>[
    for (final MapEntry<String, List<PerfPoint>> line in lines.entries)
      for (int i = 0; i < line.value.length; i++)
        if (line.value[i].value != null && line.value[i].yNormalized != null)
          (
            at: '${line.key}[$i]',
            value: line.value[i].value!,
            y: line.value[i].yNormalized!,
          ),
  ];
  // 안정 정렬(삽입) — 실패 메시지의 순번이 실행마다 같다.
  for (int i = 1; i < out.length; i++) {
    final ValuedPerfPoint cur = out[i];
    int k = i - 1;
    while (k >= 0 && out[k].value > cur.value) {
      out[k + 1] = out[k];
      k--;
    }
    out[k + 1] = cur;
  }
  return out;
}

/// C-36 ⑪ `value` 로 줄 세웠을 때 `yNormalized` 가 내려가지 않는다 · `value` 가 같으면 자리도 같다.
///
/// 🔴 산술을 다시 하지 않는다(축을 되짚어 계산하지 않는다) — 순서만 본다.
List<String> valueOrderViolations(
  String where,
  Map<String, List<PerfPoint>> lines,
) {
  final List<ValuedPerfPoint> sorted = valuedPerfPoints(lines);
  final List<String> bad = <String>[];
  for (int i = 1; i < sorted.length; i++) {
    final ValuedPerfPoint prev = sorted[i - 1];
    final ValuedPerfPoint cur = sorted[i];
    final bool same = (cur.value - prev.value).abs() < samePerfValue;
    if (same && cur.y != prev.y) {
      bad.add(
        '$where ${cur.at} — value 는 같은데(${cur.value}) 세로 자리가 다르다: '
        '${cur.y} ≠ ${prev.at} 의 ${prev.y}',
      );
    }
    if (!same && cur.y < prev.y) {
      bad.add(
        '$where ${cur.at} — value 는 더 큰데(${cur.value} > ${prev.at} 의 '
        '${prev.value}) 세로 자리가 더 낮다: ${cur.y} < ${prev.y}',
      );
    }
  }
  return bad;
}

/// C-10 ⑤ `value == null ⇔ yNormalized == null`([lines] 의 전 점).
List<String> valuePairViolations(
  String where,
  Map<String, List<PerfPoint>> lines,
) => <String>[
  for (final MapEntry<String, List<PerfPoint>> line in lines.entries)
    for (int i = 0; i < line.value.length; i++)
      if ((line.value[i].value == null) != (line.value[i].yNormalized == null))
        '$where ${line.key}[$i] — value ${line.value[i].value} · '
            'y_normalized ${line.value[i].yNormalized}(둘은 함께 비거나 함께 온다)',
];

/// C-10 ⑥ 결측 점을 덮는 `UNAVAILABLE`·`SIM_EXCLUDED` 띠가 있다.
///
/// [points] 는 구간이 딸린 본선이다(띠는 본선의 구간이다 — 목표 경로는 `actual`).
List<String> gapCoverViolations(
  String where,
  List<PerfSegment> segments,
  String key,
  List<PerfPoint> points,
) {
  final List<PerfSegment> bands = segments
      .where(
        (PerfSegment seg) =>
            seg.kind == SegmentKind.unavailable ||
            seg.kind == SegmentKind.simExcluded,
      )
      .toList();
  return <String>[
    for (int i = 0; i < points.length; i++)
      if (points[i].yNormalized == null &&
          !bands.any((PerfSegment seg) => inBand(seg, points[i])))
        '$where $key[$i] x=${points[i].xNormalized} — 결측인데 덮는 '
            'UNAVAILABLE·SIM_EXCLUDED 띠가 없다(선이 까닭 없이 끊긴다)',
  ];
}

/// C-10 ⑦ 구간 종류와 그 안의 점 — 모의 구간 = 전부 null + 사유 `SIM_EXCLUDED` · 수동 집행 구간 =
/// 전부 값 있음 · 불가 구간 = 전부 null.
///
/// 🔴 [points] 는 **본선**이다. 목표 경로의 계획선(`planned`)에는 걸지 않는다 — 계획선은 갭 띠 안에서도
///    값이 있다(계획선 결측 없음 · C-39 ②).
List<String> segmentKindViolations(
  String where,
  List<PerfSegment> segments,
  String key,
  List<PerfPoint> points,
) {
  final List<String> bad = <String>[];
  for (final PerfSegment seg in segments) {
    for (int i = 0; i < points.length; i++) {
      final PerfPoint p = points[i];
      if (!inBand(seg, p)) {
        continue;
      }
      if (seg.kind == SegmentKind.simExcluded) {
        if (p.value != null || p.yNormalized != null) {
          bad.add('$where $key[$i] — 모의 구간 안인데 값이 있다(합산 제외가 아니다)');
        }
        if (p.gapReasonCode != GapReasonCodes.simExcluded) {
          bad.add('$where $key[$i] — 모의 구간 안인데 사유가 ${p.gapReasonCode} 다');
        }
      }
      if (seg.kind == SegmentKind.manualExecuted &&
          (p.value == null || p.yNormalized == null)) {
        bad.add('$where $key[$i] — 수동 집행 구간 안인데 값이 없다(선이 끊긴다)');
      }
      if (seg.kind == SegmentKind.unavailable &&
          (p.value != null || p.yNormalized != null)) {
        bad.add('$where $key[$i] — 불가 구간 안인데 값이 있다(빗금 띠 위로 선이 지나간다)');
      }
    }
  }
  return bad;
}
