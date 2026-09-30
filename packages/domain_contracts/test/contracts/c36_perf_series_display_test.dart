// C-36 성과 시리즈 표시·기하 계약 — 01 §13-1~13-3 · §7 표 C-36(🆕 계약 v1.3).
//
// 정의: 「화면이 **정규값 × 폭·높이** 말고는 아무 산술도 하지 않고 차트와 값 표를 그릴 수 있게,
//        엔진이 보내는 성과 시리즈가 스스로 완결돼 있다」.
//   ①  `xNormalized` 는 0.0~1.0 이고 **엄격히 증가**한다(점이 1개면 0.5).
//   ②  벤치마크가 있으면 본선과 길이·날짜·`xNormalized` 가 같다(값 표가 같은 순번으로 읽는다).
//   ③  `dateText`·`valueText`·`seriesLabel`·`periodLabel` 이 비어 있지 않다.
//   ④  `yTicks`: `normalized` 오름차순 · `label` 비지 않음 · `isBaseline` 많아야 1 · 개수 ≤ 5.
//   ④b 구간은 받은 순서대로이고 서로 겹치지 않는다(앞 구간 end ≤ 뒤 구간 start).
//   ⑤  `unavailableLabel != null ⇔ points 가 비어 있다` · 그때 구간·눈금도 비고 벤치마크는 null ·
//       점이 있으면 그중 하나는 값이 있다.
//   ⑥  구간: `start ≤ end` · «날짜로 덮는 점» == «정규 자리로 덮는 점» · 측정 아닌 구간의 글자.
//   ⑦  ui 스캔: 차트·탐색 파일이 `PerfPoint.value` 를 참조하지 않는다(파일이 아직 없으면 통과) —
//       점으로 읽는 것(`p.value`)과 패턴으로 풀어 읽는 것(`PerfPoint(:value)`) 둘 다.
//   ⑧  ui 스캔: `ui_*/lib` 에 숫자 → 글자 포맷 호출이 없다.
//   ⑨  점은 많아야 60개다(값 표가 받은 순서대로 전부 그린다).
//   ⑩  가림·불가 시리즈의 문장에 `%` 와 소수점 숫자가 없다.
//   ⑪  한 시리즈(본선 + 벤치마크)의 값 있는 점에서 `value` 의 크기 순서 == `yNormalized` 의 크기 순서.
// 🔴 «선을 실제로 끊어 그렸는가»는 렌더 결과다 — `ui_analytics/test/golden/chart_probe.dart`.
// 🔴 검사마다 **망가뜨린 사본**(메모리 안)으로 실패하는 것을 맨 끝 테스트가 고정한다 —
//    검사가 «늘 참»이 되면 그 테스트가 먼저 깨진다.
// 🆕 v1.4 — ⑦ 대상에 S7-9 목표 경로 파일(`lib/src/goal_path/**`·`lib/src/screens/goal_path_screen.dart`)을
//    넣었다(01 §14-11 · C-39 ⑨ 와 정규식 공유). 점·눈금·구간 규칙 본문은 `support/perf_line_rules.dart`
//    로 옮겼다(목표 경로 C-39 와 공용 · 위반 문장 무변경) — 이 파일은 «성과 시리즈 행에 무엇을 거는가»만 적는다.

import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';
import 'support/perf_line_rules.dart';
import 'support/perf_series_rows.dart';

/// ⑨ 엔진 기본 구간의 점 수 상한(01 §13-1) — 정본은 `support/perf_line_rules.dart`.
const int _maxPoints = maxPerfPoints;

/// ⑦ `PerfPoint.value` 참조 — 괄호가 바로 오는 생성자(`Future<void>.value()`·`Stream.value(x)`)와
/// `valueOrNull` 은 통과한다. 🆕 v1.4 — 정본은 `support/perf_line_rules.dart`(C-39 ⑨ 와 공유).
final RegExp _valueRef = perfValueRef;

/// ⑦ 둘째 — 패턴 분해로 읽는 `value`(`final PerfPoint(:value) = p;` · `case PerfPoint(value: final v):`).
/// 점(`.`)이 없어 [_valueRef] 가 못 잡는다. 🆕 v1.4 — 정본은 `support/perf_line_rules.dart`.
final RegExp _valuePattern = perfValuePattern;

/// ⑧ 숫자 → 글자 포맷.
final RegExp _numberFormat = RegExp(
  'toStringAsFixed|toStringAsPrecision|NumberFormat',
);

/// ⑩ 가림 문장에 새면 안 되는 것.
final RegExp _decimalNumber = RegExp(r'\d+\.\d+');

/// ⑪ `value` 두 개를 같다고 보는 차 — 정본은 `support/perf_line_rules.dart`.
const double _sameValue = samePerfValue;

/// ⑦ 의 대상 — `packages/ui_analytics` 기준 상대 경로.
const List<String> _chartDirs = <String>[
  'lib/src/chart/',
  'lib/src/screens/explore/',
  // 🆕 v1.4(01 §14-11 · 설계 D12) — S7-9 목표 경로 차트(본보기 diff 0 복사처).
  'lib/src/goal_path/',
  // 🆕 검토 반영 — S7-9 화면 본문을 `screens/goal_path/` 에 나눠 두어도 본다(C-39 ⑨ 와 같은 대상).
  'lib/src/screens/goal_path/',
];
const List<String> _chartFiles = <String>[
  'lib/src/screens/performance_explore_screen.dart',
  'lib/src/widgets/perf_chart.dart',
  // 🆕 v1.4 — S7-9 공개 위젯 `GoalPathScreen`.
  'lib/src/screens/goal_path_screen.dart',
];

/// [_valueRef] 자체 검증 — 반드시 걸려야 하는 것.
const List<String> _valueRefPositives = <String>[
  'final double? v = p.value;',
  'final double v = points[i].value!;',
  'e.value;',
  // 문자열 보간 안의 참조도 잡는다(스캔은 주석만 지우고 문자열은 남긴다).
  r"Text('${p.value}')",
];

/// [_valueRef] 자체 검증 — 통과해야 하는 것.
const List<String> _valueRefNegatives = <String>[
  'return Future<void>.value();',
  'final x = async.valueOrNull;',
  'yield* Stream<int>.value(1);',
  'Text(p.valueText)',
  'final String t = point.valueText;',
];

/// [_valuePattern] 자체 검증 — 반드시 걸려야 하는 것.
const List<String> _valuePatternPositives = <String>[
  'final PerfPoint(:value) = p;',
  'case PerfPoint(value: final v):',
];

/// [_valuePattern] 자체 검증 — 통과해야 하는 것.
const List<String> _valuePatternNegatives = <String>[
  'PerfPoint(:yNormalized)',
  'case PerfPoint(:valueText, :dateText):',
];

const List<String> _numberFormatPositives = <String>[
  'final s = v.toStringAsFixed(2);',
  'final s = v.toStringAsPrecision(3);',
  "final f = NumberFormat('#,##0.00');",
  r"Text('${(p.yNormalized! * 100).toStringAsFixed(1)}%')",
];

const List<String> _numberFormatNegatives = <String>[
  'Text(p.valueText)',
  'final double dx = p.xNormalized * size.width;',
  'final String s = tick.label;',
];

void main() {
  group('C-36 성과 시리즈 표시·기하 계약 (01 §13 · 계약 v1.3)', () {
    test('C-36 대상 — 성과 픽스처 8건을 빠짐없이 찾았다', () {
      final List<PerfSeriesRow> rows = allPerfSeriesRows();
      final Set<String> found = <String>{
        for (final PerfSeriesRow r in rows) r.path,
      };
      expect(
        found,
        containsAll(knownPerfSeriesFixtures),
        reason: '성과 픽스처가 검사 입력에서 빠졌다 — 입력 없는 검사는 늘 통과한다.',
      );
      expect(rows.length, greaterThanOrEqualTo(9), reason: '시리즈 9행(24m 은 2행).');
      // 모양 3종이 모두 입력에 있다 — 차트 · 벤치마크 · 불가.
      expect(
        rows.where((PerfSeriesRow r) => r.series.points.isNotEmpty),
        isNotEmpty,
      );
      expect(
        rows.where((PerfSeriesRow r) => r.series.benchmark != null),
        isNotEmpty,
      );
      expect(
        rows.where((PerfSeriesRow r) => r.series.unavailableLabel != null),
        hasLength(greaterThanOrEqualTo(2)),
        reason: '불가(재개 갭) · 가림(무결성) 두 표본.',
      );
    });

    test('C-36 ① xNormalized 는 0.0~1.0 이고 엄격히 증가한다(점 1개면 0.5)', () {
      _expectClean(_xViolations);
    });

    test('C-36 ② 벤치마크는 본선과 길이·날짜·xNormalized 가 같다', () {
      _expectClean(_benchmarkViolations);
    });

    test('C-36 ③ 점의 글자와 시리즈 이름·기간 글자가 비어 있지 않다', () {
      _expectClean(_textViolations);
    });

    test('C-36 ④ 눈금은 오름차순 · 글자 있음 · 기준선 많아야 1 · 5개 이하다', () {
      _expectClean(_tickViolations);
    });

    test('C-36 ④b 구간은 받은 순서대로이고 서로 겹치지 않는다', () {
      _expectClean(_segmentOrderViolations);
    });

    test('C-36 ⑤ unavailableLabel 이 있다 ⇔ 점이 없다', () {
      _expectClean(_unavailableViolations);
    });

    test('C-36 ⑥ 구간의 정규 범위가 덮는 점은 날짜가 덮는 점과 같다', () {
      _expectClean(_segmentCoverViolations);
      // 입력 확인 — 측정 아닌 구간 3종이 모두 있다.
      final Set<SegmentKind> kinds = <SegmentKind>{
        for (final PerfSeriesRow r in allPerfSeriesRows())
          for (final PerfSegment seg in r.series.segments) seg.kind,
      };
      expect(kinds, containsAll(SegmentKind.values));
    });

    test('C-36 ⑦ 차트·탐색 파일이 PerfPoint.value 를 참조하지 않는다', () {
      for (final String s in _valueRefPositives) {
        expect(_valueRef.hasMatch(s), isTrue, reason: '양성 스니펫을 못 잡았다: $s');
      }
      for (final String s in _valueRefNegatives) {
        expect(_valueRef.hasMatch(s), isFalse, reason: '음성 스니펫을 잘못 잡았다: $s');
      }
      for (final String s in _valuePatternPositives) {
        expect(_valuePattern.hasMatch(s), isTrue, reason: '양성 스니펫을 못 잡았다: $s');
        // 점이 없는 꼴이다 — 첫째 정규식만으로는 빠져나간다(둘째가 있어야 하는 까닭).
        expect(_valueRef.hasMatch(s), isFalse, reason: s);
      }
      for (final String s in _valuePatternNegatives) {
        expect(
          _valuePattern.hasMatch(s),
          isFalse,
          reason: '음성 스니펫을 잘못 잡았다: $s',
        );
      }
      // 대상 고르기 자체 검증.
      expect(_isChartTarget('lib/src/chart/perf_geometry.dart'), isTrue);
      expect(
        _isChartTarget('lib/src/screens/explore/values_table.dart'),
        isTrue,
      );
      expect(
        _isChartTarget('lib/src/screens/performance_explore_screen.dart'),
        isTrue,
      );
      expect(_isChartTarget('lib/src/widgets/perf_chart.dart'), isTrue);
      // 🆕 v1.4 — S7-9 목표 경로 파일도 대상이다(플래너는 아니다).
      expect(
        _isChartTarget('lib/src/goal_path/goal_path_chart_painter.dart'),
        isTrue,
      );
      expect(_isChartTarget('lib/src/screens/goal_path_screen.dart'), isTrue);
      expect(_isChartTarget('lib/src/planner/planner_providers.dart'), isFalse);
      expect(
        _isChartTarget('lib/src/screens/contribution_screen.dart'),
        isFalse,
      );
      expect(_isChartTarget('lib/src/widgets/stale_banner.dart'), isFalse);
      // 스캔 함수 자체 검증 — 가짜 소스 2건(주석 속 언급은 통과 · 코드는 걸린다).
      expect(
        _scan(<String, String>{
          'a.dart': '// p.value 를 쓰지 않는다\nfinal t = p.valueText;\n',
          'b.dart': 'final v = p.value;\n',
        }, _valueRef),
        <String>['b.dart'],
      );
      expect(
        _scan(<String, String>{
          'a.dart':
              '// PerfPoint(:value) 로 풀지 않는다\n'
              'final PerfPoint(:yNormalized) = p;\n',
          'b.dart': 'final PerfPoint(:value) = p;\n',
          'c.dart':
              'final v = switch (p) {\n  PerfPoint(value: final v) => v,\n};\n',
        }, _valuePattern),
        <String>['b.dart', 'c.dart'],
      );

      final Map<String, String> sources = <String, String>{};
      final Directory root = Directory(
        '${repoRoot.path}/packages/ui_analytics',
      );
      for (final File f in dartSourcesIn(Directory('${root.path}/lib'))) {
        final String rel = _relativeTo(root, f);
        if (_isChartTarget(rel)) {
          sources['packages/ui_analytics/$rel'] = f.readAsStringSync();
        }
      }
      // 🔴 대상 파일이 아직 없으면(R10 카드 전) 통과한다 — 없는 파일로 실패시키지 않는다.
      expect(
        _scan(sources, _valueRef),
        isEmpty,
        reason:
            '`PerfPoint.value` 는 골든 대조·회귀 전용이다. 그래프는 `xNormalized`·`yNormalized`, '
            '글자는 `valueText` 를 쓴다(01 §13-1 · §13-2).',
      );
      expect(
        _scan(sources, _valuePattern),
        isEmpty,
        reason:
            '`PerfPoint` 를 패턴으로 풀어 `value` 를 읽는 것도 같은 금지다'
            '(`PerfPoint(:value)` · `PerfPoint(value: final v)` — 01 §13-2).',
      );
    });

    test('C-36 ⑧ ui_*/lib 에 숫자 → 글자 포맷 호출이 없다', () {
      for (final String s in _numberFormatPositives) {
        expect(_numberFormat.hasMatch(s), isTrue, reason: '양성 스니펫: $s');
      }
      for (final String s in _numberFormatNegatives) {
        expect(_numberFormat.hasMatch(s), isFalse, reason: '음성 스니펫: $s');
      }
      expect(
        _scan(<String, String>{
          'a.dart': '// toStringAsFixed 금지\nText(p.valueText);\n',
          'b.dart': 'Text(v.toStringAsFixed(2));\n',
        }, _numberFormat),
        <String>['b.dart'],
      );

      final Map<String, String> sources = <String, String>{};
      for (final String name in uiPackageNames) {
        final Directory root = Directory('${repoRoot.path}/packages/$name');
        for (final File f in dartSourcesIn(Directory('${root.path}/lib'))) {
          sources['packages/$name/${_relativeTo(root, f)}'] = f
              .readAsStringSync();
        }
      }
      expect(sources, isNotEmpty, reason: '화면 소스를 하나도 못 찾았다 — 경로가 낡았다.');
      expect(
        _scan(sources, _numberFormat),
        isEmpty,
        reason: '표시 글자는 엔진이 만든다 — 화면이 숫자를 포맷하지 않는다(01 §13-2 금지 표).',
      );
    });

    test('C-36 ⑨ 점은 많아야 60개다', () {
      _expectClean(_pointCountViolations);
    });

    test('C-36 ⑩ 가림·불가 시리즈의 문장에 %와 소수점 숫자가 없다', () {
      _expectClean(_maskedTextViolations);
    });

    test('C-36 ⑪ value 의 크기 순서와 yNormalized 의 크기 순서가 같다', () {
      _expectClean(_orderViolations);
      // 입력 확인 — 견줄 점이 있는 시리즈 · 두 선을 한 축에서 견주는 시리즈 · 값이 같은 두 점.
      final List<PerformanceSeries> all = <PerformanceSeries>[
        for (final PerfSeriesRow r in allPerfSeriesRows()) r.series,
      ];
      expect(
        all.where((PerformanceSeries s) => _valued(s).length >= 2),
        hasLength(greaterThanOrEqualTo(7)),
        reason: '견줄 점이 둘 이상인 시리즈 표본이 줄었다.',
      );
      expect(
        all.where(
          (PerformanceSeries s) =>
              s.benchmark != null && _valued(s).length > s.points.length,
        ),
        isNotEmpty,
        reason: '본선과 벤치마크를 한 축에서 견주는 표본이 없다.',
      );
      expect(
        all.any((PerformanceSeries s) {
          final List<_Valued> v = _valued(s);
          for (int i = 1; i < v.length; i++) {
            if ((v[i].value - v[i - 1].value).abs() < _sameValue) {
              return true;
            }
          }
          return false;
        }),
        isTrue,
        reason: '값이 같은 두 점 표본이 없다(«같으면 같다» 갈래가 아무것도 보지 않는다).',
      );
    });

    test('C-36 자체 검증 — 망가뜨린 사본은 검사에 걸린다', () {
      final PerfSeriesRow monthly = perfSeriesRow(FixturePaths.performance24m);
      final PerfSeriesRow daily = perfSeriesRow(FixturePaths.m7M7PerfDailyGap);
      final PerfSeriesRow yearly = perfSeriesRow(FixturePaths.m7M7PerfYearly);
      final PerfSeriesRow period = perfSeriesRow(
        FixturePaths.m7M7PerfMonthlyPeriod,
      );
      final PerfSeriesRow sim = perfSeriesRow(
        FixturePaths.m7M7PerfMonthlySimSplit,
      );
      final PerfSeriesRow gone = perfSeriesRow(
        FixturePaths.m7M7PerfUnavailableGap,
      );
      final PerfSeriesRow masked = perfSeriesRow(
        FixturePaths.m7M7PerfMaskedIntegrity,
      );

      final List<_Mutation> mutations = <_Mutation>[
        // ①
        _Mutation('① 같은 자리 두 점', '크지 않다', _xViolations, daily, (
          Map<String, Object?> j,
        ) {
          final List<Map<String, Object?>> p = jsonObjects(j, 'points');
          p[3]['x_normalized'] = p[2]['x_normalized'];
        }),
        _Mutation('① 뒤로 가는 점', '크지 않다', _xViolations, daily, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'points')[5]['x_normalized'] = 0.01;
        }),
        _Mutation('① 점 1개인데 0.5 가 아니다', '점이 1개면', _xViolations, yearly, (
          Map<String, Object?> j,
        ) {
          final List<Map<String, Object?>> p = jsonObjects(j, 'points');
          p.removeRange(1, p.length);
          p[0]['x_normalized'] = 0.0;
        }),
        // ②
        _Mutation(
          '② 벤치마크 점이 하나 모자란다',
          '벤치마크 점',
          _benchmarkViolations,
          monthly,
          (Map<String, Object?> j) {
            jsonObjects(
              j['benchmark']! as Map<String, Object?>,
              'points',
            ).removeLast();
          },
        ),
        _Mutation('② 벤치마크 자리가 다르다', '[4] x ', _benchmarkViolations, monthly, (
          Map<String, Object?> j,
        ) {
          jsonObjects(
            j['benchmark']! as Map<String, Object?>,
            'points',
          )[4]['x_normalized'] = 0.2;
        }),
        _Mutation('② 벤치마크 날짜가 다르다', '[4] 날짜', _benchmarkViolations, period, (
          Map<String, Object?> j,
        ) {
          jsonObjects(
            j['benchmark']! as Map<String, Object?>,
            'points',
          )[4]['date'] = '2025-01-30';
        }),
        // ③
        _Mutation(
          '③ 빈 날짜 글자',
          'points[0] — date_text',
          _textViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'points')[0]['date_text'] = '';
          },
        ),
        _Mutation(
          '③ 빈 값 글자(결측 점)',
          'points[13] — value_text',
          _textViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'points')[13]['value_text'] = ' ';
          },
        ),
        _Mutation(
          '③ 빈 벤치마크 값 글자',
          'benchmark.points[2] — value_text',
          _textViolations,
          monthly,
          (Map<String, Object?> j) {
            jsonObjects(
              j['benchmark']! as Map<String, Object?>,
              'points',
            )[2]['value_text'] = '';
          },
        ),
        _Mutation('③ 빈 시리즈 이름', 'series_label', _textViolations, daily, (
          Map<String, Object?> j,
        ) {
          j['series_label'] = '';
        }),
        _Mutation('③ 빈 기간 글자(불가 시리즈)', 'period_label', _textViolations, gone, (
          Map<String, Object?> j,
        ) {
          j['period_label'] = '';
        }),
        // ④
        _Mutation('④ 눈금 순서 뒤집힘', '오름차순', _tickViolations, daily, (
          Map<String, Object?> j,
        ) {
          final List<Map<String, Object?>> t = jsonObjects(j, 'y_ticks');
          final Map<String, Object?> first = t.removeAt(0);
          t.add(first);
        }),
        _Mutation('④ 기준선 2개', '기준선', _tickViolations, daily, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'y_ticks')[1]['is_baseline'] = true;
        }),
        _Mutation('④ 빈 눈금 글자', 'y_ticks[1] — label', _tickViolations, daily, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'y_ticks')[1]['label'] = '';
        }),
        _Mutation('④ 눈금 6개', '눈금 6개', _tickViolations, sim, (
          Map<String, Object?> j,
        ) {
          final List<Object?> t = j['y_ticks']! as List<Object?>;
          (t.last! as Map<String, Object?>)['normalized'] = 0.9;
          t.add(<String, Object?>{
            'normalized': 1.0,
            'label': '9%',
            'is_baseline': false,
          });
        }),
        // ④b
        _Mutation(
          '④b 구간 순서 뒤바뀜',
          '받은 순서가 아니다',
          _segmentOrderViolations,
          daily,
          (Map<String, Object?> j) {
            final List<Map<String, Object?>> s = jsonObjects(j, 'segments');
            final Map<String, Object?> first = s.removeAt(0);
            s.add(first);
          },
        ),
        _Mutation('④b 구간 겹침', '겹친다', _segmentOrderViolations, daily, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'segments')[0]['end_normalized'] = 0.7;
        }),
        // ⑤
        _Mutation('⑤ 점이 있는데 불가 문장', '둘은 짝이다', _unavailableViolations, daily, (
          Map<String, Object?> j,
        ) {
          j['unavailable_label'] = '이 기간은 산출할 수 없습니다.';
        }),
        _Mutation('⑤ 점이 없는데 불가 문장 없음', '둘은 짝이다', _unavailableViolations, gone, (
          Map<String, Object?> j,
        ) {
          j.remove('unavailable_label');
        }),
        _Mutation('⑤ 불가인데 눈금이 있다', '불가인데 눈금', _unavailableViolations, masked, (
          Map<String, Object?> j,
        ) {
          j['y_ticks'] = <Object?>[
            <String, Object?>{'normalized': 0.0, 'label': '0%'},
          ];
        }),
        _Mutation('⑤ 불가인데 구간이 있다', '불가인데 구간', _unavailableViolations, gone, (
          Map<String, Object?> j,
        ) {
          j['segments'] = <Object?>[
            <String, Object?>{
              'from': '2026-08-21',
              'to': '2026-08-31',
              'kind': 'UNAVAILABLE',
              'label': '결측',
              'start_normalized': 0.0,
              'end_normalized': 1.0,
            },
          ];
        }),
        _Mutation(
          '⑤ 불가인데 벤치마크가 있다',
          '불가인데 벤치마크',
          _unavailableViolations,
          gone,
          (Map<String, Object?> j) {
            j['benchmark'] = <String, Object?>{
              'label': '비교 기준',
              'points': <Object?>[],
              'composition_note': '구성',
            };
          },
        ),
        _Mutation(
          '⑤ 전 점이 결측인데 불가 문장 없음',
          '값 있는 점이 하나도 없다',
          _unavailableViolations,
          daily,
          (Map<String, Object?> j) {
            for (final Map<String, Object?> p in jsonObjects(j, 'points')) {
              p['y_normalized'] = null;
              p['value'] = null;
            }
          },
        ),
        _Mutation('⑤ 빈 불가 문장', '빈 글자', _unavailableViolations, gone, (
          Map<String, Object?> j,
        ) {
          j['unavailable_label'] = '';
        }),
        // ⑥
        _Mutation(
          '⑥ start > end',
          'start > end',
          _segmentCoverViolations,
          daily,
          (Map<String, Object?> j) {
            final Map<String, Object?> seg = jsonObjects(j, 'segments')[1];
            final Object? start = seg['start_normalized'];
            seg['start_normalized'] = seg['end_normalized'];
            seg['end_normalized'] = start;
          },
        ),
        _Mutation(
          '⑥ 날짜는 한 점 더 덮는데 띠는 그대로',
          '날짜로 덮는 점 [13, 14, 15]',
          _segmentCoverViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'segments')[1]['to'] = '2026-08-24';
          },
        ),
        _Mutation(
          '⑥ 띠가 한 점 덜 덮는다',
          '정규 자리로 덮는 점 [13]',
          _segmentCoverViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'segments')[1]['end_normalized'] = 0.66;
          },
        ),
        _Mutation('⑥ 측정 아닌 구간의 빈 글자', '캡션이 없다', _segmentCoverViolations, sim, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'segments')[0]['label'] = '';
        }),
        // ⑨
        _Mutation('⑨ 점 61개', '점 61개', _pointCountViolations, daily, (
          Map<String, Object?> j,
        ) {
          final List<Object?> p = j['points']! as List<Object?>;
          final Map<String, Object?> last = p.last! as Map<String, Object?>;
          while (p.length < _maxPoints + 1) {
            p.add(Map<String, Object?>.of(last));
          }
        }),
        // ⑩
        _Mutation(
          '⑩ 불가 문장에 %',
          'unavailable_label',
          _maskedTextViolations,
          gone,
          (Map<String, Object?> j) {
            j['unavailable_label'] = '수익률 3% 는 보여 줄 수 없습니다.';
          },
        ),
        _Mutation(
          '⑩ 표본 문장에 소수점 숫자',
          'sample_size_line',
          _maskedTextViolations,
          masked,
          (Map<String, Object?> j) {
            (j['disclosure']! as Map<String, Object?>)['sample_size_line'] =
                '관측 표본의 누적은 11.94 입니다.';
          },
        ),
        // ⑪
        _Mutation(
          '⑪ 값은 더 큰데 세로 자리가 더 낮다',
          'points[5] — value 는 더 큰데',
          _orderViolations,
          monthly,
          (Map<String, Object?> j) {
            // 점 5(value 0.0338)의 자리를 점 4(value 0.0263 · 자리 0.1753)보다 아래로.
            jsonObjects(j, 'points')[5]['y_normalized'] = 0.05;
          },
        ),
        _Mutation(
          '⑪ 값이 같은데 세로 자리가 다르다(벤치마크)',
          'benchmark.points[12] — value 는 같은데',
          _orderViolations,
          period,
          (Map<String, Object?> j) {
            // 벤치마크 점 2·12·23 은 value 가 같다(0.0053 · 자리 0.6325).
            jsonObjects(
              j['benchmark']! as Map<String, Object?>,
              'points',
            )[12]['y_normalized'] = 0.634;
          },
        ),
      ];

      final Set<String> covered = <String>{};
      for (final _Mutation m in mutations) {
        expect(
          m.rule(m.row.where, m.row.series),
          isEmpty,
          reason: '${m.name} — 고치기 전 원본이 이미 걸린다(변이 확인이 뜻을 잃는다).',
        );
        expect(
          m.rule(m.row.where, m.row.mutated(m.edit)),
          contains(contains(m.hit)),
          reason: '${m.name} — 망가뜨렸는데 검사가 통과한다(검사가 늘 참이다).',
        );
        covered.add(m.name.split(' ').first);
      }
      expect(covered, <String>{
        '①',
        '②',
        '③',
        '④',
        '④b',
        '⑤',
        '⑥',
        '⑨',
        '⑩',
        '⑪',
      });
    });
  });
}

/// 검사 1종 — 위반을 문장 목록으로 돌려준다(빈 목록 = 통과).
typedef _Rule = List<String> Function(String where, PerformanceSeries s);

/// 변이 1건(자체 검증용).
class _Mutation {
  const _Mutation(this.name, this.hit, this.rule, this.row, this.edit);

  final String name;

  /// 걸려야 하는 조항의 글자 — 위반 문장 가운데 하나가 이 글자를 담아야 한다
  /// (엉뚱한 조항에 걸려 통과하는 것을 막는다).
  final String hit;
  final _Rule rule;
  final PerfSeriesRow row;
  final void Function(Map<String, Object?> json) edit;
}

void _expectClean(_Rule rule) {
  final List<PerfSeriesRow> rows = allPerfSeriesRows();
  expect(rows, isNotEmpty);
  final List<String> bad = <String>[
    for (final PerfSeriesRow r in rows) ...rule(r.where, r.series),
  ];
  expect(bad, isEmpty, reason: bad.join('\n'));
}

/// 본선과 (있으면) 벤치마크의 점 목록.
Map<String, List<PerfPoint>> _lines(PerformanceSeries s) =>
    <String, List<PerfPoint>>{
      'points': s.points,
      if (s.benchmark != null) 'benchmark.points': s.benchmark!.points,
    };

List<String> _xViolations(String where, PerformanceSeries s) => <String>[
  for (final MapEntry<String, List<PerfPoint>> line in _lines(s).entries)
    ...xLineViolations(where, line.key, line.value),
];

List<String> _benchmarkViolations(String where, PerformanceSeries s) {
  final BenchmarkSeries? b = s.benchmark;
  if (b == null) {
    return const <String>[];
  }
  final List<String> bad = <String>[];
  if (b.points.length != s.points.length) {
    return <String>[
      '$where — 벤치마크 점 ${b.points.length}개 ≠ 본선 ${s.points.length}개',
    ];
  }
  for (int i = 0; i < s.points.length; i++) {
    final PerfPoint main = s.points[i];
    final PerfPoint bench = b.points[i];
    if (main.date.yyyyMmDd != bench.date.yyyyMmDd) {
      bad.add(
        '$where [$i] 날짜 ${bench.date.yyyyMmDd} ≠ 본선 ${main.date.yyyyMmDd}',
      );
    }
    if (main.xNormalized != bench.xNormalized) {
      bad.add('$where [$i] x ${bench.xNormalized} ≠ 본선 ${main.xNormalized}');
    }
  }
  return bad;
}

List<String> _textViolations(String where, PerformanceSeries s) {
  final List<String> bad = <String>[];
  if (s.seriesLabel.trim().isEmpty) {
    bad.add('$where — series_label 이 비었다');
  }
  if (s.periodLabel.trim().isEmpty) {
    bad.add('$where — period_label 이 비었다');
  }
  for (final MapEntry<String, List<PerfPoint>> line in _lines(s).entries) {
    bad.addAll(pointTextViolations(where, line.key, line.value));
  }
  return bad;
}

List<String> _tickViolations(String where, PerformanceSeries s) =>
    tickViolations(where, s.yTicks);

List<String> _segmentOrderViolations(String where, PerformanceSeries s) =>
    segmentOrderViolations(where, s.segments);

List<String> _unavailableViolations(String where, PerformanceSeries s) {
  final List<String> bad = <String>[];
  final String? label = s.unavailableLabel;
  if ((label != null) != s.points.isEmpty) {
    bad.add(
      '$where — unavailable_label ${label == null ? '없음' : '있음'} · '
      '점 ${s.points.length}개(둘은 짝이다)',
    );
  }
  if (label != null) {
    if (label.trim().isEmpty) {
      bad.add('$where — unavailable_label 이 빈 글자다');
    }
    if (s.segments.isNotEmpty) {
      bad.add('$where — 불가인데 구간이 있다');
    }
    if (s.yTicks.isNotEmpty) {
      bad.add('$where — 불가인데 눈금이 있다');
    }
    if (s.benchmark != null) {
      bad.add('$where — 불가인데 벤치마크가 있다');
    }
  }
  if (s.points.isNotEmpty &&
      !s.points.any((PerfPoint p) => p.yNormalized != null)) {
    bad.add('$where — 점이 있는데 값 있는 점이 하나도 없다(불가 문장으로 와야 한다)');
  }
  return bad;
}

List<String> _segmentCoverViolations(String where, PerformanceSeries s) =>
    segmentCoverViolations(where, s.segments, s.points);

List<String> _pointCountViolations(String where, PerformanceSeries s) =>
    <String>[
      for (final MapEntry<String, List<PerfPoint>> line in _lines(s).entries)
        ...pointCountViolations(where, line.key, line.value),
    ];

List<String> _maskedTextViolations(String where, PerformanceSeries s) {
  final String? label = s.unavailableLabel;
  if (label == null) {
    return const <String>[];
  }
  final List<String> bad = <String>[];
  final Map<String, String> texts = <String, String>{
    'unavailable_label': label,
    'sample_size_line': s.disclosure.sampleSizeLine,
  };
  for (final MapEntry<String, String> e in texts.entries) {
    if (e.value.contains('%') || _decimalNumber.hasMatch(e.value)) {
      bad.add('$where ${e.key} — 가린 시리즈의 문장에 수익률 꼴 숫자가 있다: ${e.value}');
    }
  }
  return bad;
}

/// 값 있는 점 1개(⑪) — 정본은 `support/perf_line_rules.dart`.
typedef _Valued = ValuedPerfPoint;

/// 본선 + 벤치마크의 값 있는 점을 `value` 오름차순으로(같으면 받은 순서 그대로).
///
/// 🔴 두 선은 **같은 축**을 쓴다(01 §13-1) — 그래서 한데 모아 견준다.
List<_Valued> _valued(PerformanceSeries s) => valuedPerfPoints(_lines(s));

/// ⑪ `value` 로 줄 세웠을 때 `yNormalized` 가 내려가지 않는다 · `value` 가 같으면 자리도 같다.
///
/// 🔴 산술을 다시 하지 않는다(축을 되짚어 계산하지 않는다) — 순서만 본다. 값 하나를 손으로 고쳐
///    세로 자리와 어긋나면 여기서 걸린다.
List<String> _orderViolations(String where, PerformanceSeries s) =>
    valueOrderViolations(where, _lines(s));

bool _isChartTarget(String rel) =>
    _chartFiles.contains(rel) || _chartDirs.any(rel.startsWith);

/// 주석을 지운 소스에서 [re] 가 걸린 파일 이름(경로 순).
///
/// 🔴 문자열은 남긴다 — `'${p.value}'` 같은 보간 안의 참조가 가장 흔한 위반 꼴이다.
List<String> _scan(Map<String, String> sources, RegExp re) => <String>[
  for (final MapEntry<String, String> e in sources.entries)
    if (re.hasMatch(stripComments(e.value))) e.key,
];

String _relativeTo(Directory root, File f) {
  final String base = root.path.replaceAll(r'\', '/');
  final String p = f.path.replaceAll(r'\', '/');
  return p.startsWith('$base/') ? p.substring(base.length + 1) : p;
}
