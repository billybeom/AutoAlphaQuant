// C-39 목표 경로 표시·기하 계약 — 01 §14-9 · §14-10 · §14-11 · §7 표 C-39(🆕 계약 v1.4 · 설계 Δ4).
//
// 정의: 「S7-9 목표 경로 화면이 **정규값 × 폭·높이** 말고는 아무 산술도·판정도 하지 않고 두 선(계획·실제)과
//        문장을 그릴 수 있게, 엔진이 보내는 `GoalPathVm` 이 스스로 완결돼 있다」.
//   ① C-36 의 행 단언을 계획선·실제선에 건다(헬퍼 재사용 — `support/perf_line_rules.dart`):
//      정규 가로 자리 0.0~1.0·엄격 증가 · 점 글자 · 점 60개 이하 · 한 축의 값 순서 == 세로 자리 순서 ·
//      `value == null ⇔ yNormalized == null`(C-10 ⑤ · 결측 띠 규약 ⑥⑦ 은 C-10 ⑧ 이 실제선에 건다) ·
//      문장 필드(판정·근거·기간·범례·가정·정직 기대·고지)가 비지 않는다.
//   ② 계획선은 실제선과 길이·date·xNormalized 가 같고, 계획선 결측은 0 이다.
//   ③ `chart_unavailable_label != null ⇔` 네 목록(planned·actual·y_ticks·segments)이 모두 빈 목록 ·
//      그때 `deviation_text == null`.
//   ④ 눈금 ≤ 5 · 오름차순 · 글자 있음 · 기준선 많아야 1(🔴 «정확히 1» 아님 — 금액 축은 기준선 0).
//   ⑤ 구간은 받은 순서·겹침 없음 · 날짜가 덮는 점 == 정규 자리가 덮는 점(실제선 기준).
//   ⑥ 점의 `value_text` 에 `%` 0(달성률 금지) · 실전 조건(realworld) 행 문장에 `1억` 0 ·
//      전 목표 경로 문장에 `최악의 해` 0.
//   ⑦ 월간 리포트의 `goal_deep_link` 는 `aaq://report/goal/<그 행 yyyy_mm>` 이거나 **없다** ·
//      가림·미생성(pending) 픽스처는 없다.
//   ⑧ 저장소(Dart 코드·픽스처)에 `seriesCode`·`GoalPathPoint` 0 — v1.4 에서 폐기된 이름.
//   ⑨ ui 스캔: S7-9 파일(`lib/src/goal_path/**` · `lib/src/screens/goal_path_screen.dart`)이
//      `PerfPoint.value` 를 읽지 않고(C-36 ⑦ 두 정규식 준용) `ConfigRepository` 를 말하지 않는다
//      (03 §17-17 · 01 §14-10). 파일이 아직 없으면(R11b 전) 통과한다.
// 🔴 «선을 실제로 끊어 그렸는가 · 층이 맞는가»는 렌더 결과다 —
//    `ui_analytics/test/golden/chart_probe.dart` 의 `expectGoalPathMatches`(M2 받침대 몫).
// 🔴 검사마다 **망가뜨린 사본**(메모리 안)으로 실패하는 것을 맨 끝 테스트가 고정한다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_fixture_registry.dart';
import 'c00_support.dart';
import 'support/perf_line_rules.dart';
import 'support/perf_series_rows.dart';

/// ⑦ 목표 경로 링크를 **싣지 않는** 월간 리포트(가림 2 · 미생성 1).
const Set<String> _noGoalLinkReports = <String>{
  FixturePaths.m7M7MonthlyMaskedIntegrity,
  FixturePaths.m7M7MonthlyMaskedRecon,
  FixturePaths.m7M7MonthlyPending,
};

/// ⑧ 폐기된 이름(Dart 식별자 · JSON 키).
final RegExp _retiredName = RegExp(
  'seriesCode|series_code|GoalPathPoint|goal_path_point',
);

/// ⑨ `ConfigRepository` 와 그 주입 이름(`…configRepositoryProvider`).
final RegExp _configRepo = RegExp('[Cc]onfigRepository');

/// ⑨ 의 대상 — `packages/ui_analytics` 기준 상대 경로.
const String _goalPathDir = 'lib/src/goal_path/';
const String _goalPathScreen = 'lib/src/screens/goal_path_screen.dart';

/// 🆕 검토 반영 — 화면 본문을 R10 선례(`screens/explore/`)처럼 `screens/goal_path/` 에 나눠 두어도
/// 스캔이 본다(03 §14 ⓐ 는 화면 = `goal_path_screen.dart` · 보조 = `src/goal_path/` 로 못박는다).
const String _goalPathScreensDir = 'lib/src/screens/goal_path/';

/// ⑨ 가드 — 목표 경로 DTO·창구를 말하는 `ui_analytics/lib` 파일은 S7-9 대상 + 이 프로바이더 파일뿐이다
/// (대상 밖 경로에 같은 화면 코드를 두면 ⑨ 가 공허 통과하는 구멍을 막는다).
const String _goalPathProvidersFile =
    'lib/src/providers/analytics_providers.dart';
final RegExp _goalPathMention = RegExp(
  r'\b(GoalPathVm|goalPath|goalPathProvider)\b',
);

void main() {
  group('C-39 목표 경로 표시·기하 계약 (01 §14 · 계약 v1.4)', () {
    test('C-39 대상 — 목표 경로 픽스처 4건과 모양 4종을 빠짐없이 찾았다', () {
      final List<GoalPathRow> rows = allGoalPathRows();
      expect(
        <String>{for (final GoalPathRow r in rows) r.path},
        containsAll(knownGoalPathFixtures),
        reason: '목표 경로 픽스처가 검사 입력에서 빠졌다 — 입력 없는 검사는 늘 통과한다.',
      );
      final List<GoalPathVm> vms = <GoalPathVm>[
        for (final GoalPathRow r in rows) r.vm,
      ];
      expect(
        vms.where((GoalPathVm v) => v.planned.isNotEmpty),
        hasLength(greaterThanOrEqualTo(3)),
        reason: '차트 표본(유지·이탈·실전 조건).',
      );
      expect(
        vms.where((GoalPathVm v) => v.chartUnavailableLabel != null),
        isNotEmpty,
        reason: '판정 유보(차트 대신 문장 카드) 표본.',
      );
      expect(
        vms.where((GoalPathVm v) => v.deviationText != null),
        isNotEmpty,
        reason: '이탈 문장 표본.',
      );
      expect(
        vms.where((GoalPathVm v) => v.segments.isNotEmpty),
        isNotEmpty,
        reason: '갭 띠 표본.',
      );
    });

    test('C-39 ① 두 선에 C-36 의 행 단언이 선다(가로 자리·글자·점 수·값 순서·결측 짝)', () {
      _expectClean(_rowViolations);
    });

    test('C-39 ② 계획선은 실제선과 길이·날짜·가로 자리가 같고 결측이 없다', () {
      _expectClean(_pairViolations);
    });

    test('C-39 ③ chart_unavailable_label 이 있다 ⇔ 네 목록이 모두 비었다', () {
      _expectClean(_unavailableViolations);
    });

    test('C-39 ④ 눈금은 5개 이하 · 오름차순 · 글자 있음 · 기준선 많아야 1', () {
      _expectClean(_tickRule);
    });

    test('C-39 ⑤ 구간은 받은 순서대로 · 겹침 없음 · 날짜와 정규 자리가 같은 점을 덮는다', () {
      _expectClean(_segmentRule);
    });

    test('C-39 ⑥ 값 글자에 % 없음 · 실전 조건 문장에 1억 없음 · 최악의 해 없음', () {
      _expectClean(_textRuleViolations);
    });

    test('C-39 ⑦ 월간 리포트의 목표 경로 링크는 그 달의 경로이거나 없다', () {
      final List<String> reports = <String>[
        for (final MapEntry<String, FixtureBinding> e
            in fixtureBindings.entries)
          if (e.value.rows.typeName == 'MonthlyReport') e.key,
      ];
      expect(
        reports,
        containsAll(_noGoalLinkReports),
        reason: '월간 리포트 픽스처를 못 찾았다 — 등록부가 낡았다.',
      );
      final List<String> bad = <String>[];
      int linked = 0;
      for (final String path in reports) {
        final List<Map<String, Object?>> rows = decodeEnvelope(
          readFixture(path),
        ).rows;
        for (int i = 0; i < rows.length; i++) {
          final List<String> v = _goalLinkViolations(
            '$path rows[$i]',
            rows[i],
            mustBeAbsent: _noGoalLinkReports.contains(path),
          );
          bad.addAll(v);
          if (rows[i]['goal_deep_link'] != null) {
            linked++;
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
      expect(linked, greaterThanOrEqualTo(2), reason: '링크가 실린 월간 리포트 표본이 줄었다.');
    });

    test('C-39 ⑧ 저장소에 seriesCode·GoalPathPoint 가 없다(v1.4 폐기 이름)', () {
      // 자체 검증 — 주석·문자열 속 언급은 통과(폐기 기록은 남겨도 된다), 코드는 걸린다.
      expect(
        _retiredName.hasMatch(
          stripCommentsAndStrings('// GoalPathPoint 는 폐기됐다\nfinal x = 1;\n'),
        ),
        isFalse,
      );
      expect(
        _retiredName.hasMatch(
          stripCommentsAndStrings('final List<GoalPathPoint> p = [];\n'),
        ),
        isTrue,
      );
      expect(_retiredName.hasMatch('{"series_code": "TWR"}'), isTrue);

      final List<String> hits = <String>[];
      int scanned = 0;
      final List<Directory> roots = <Directory>[
        for (final FileSystemEntity e in Directory(
          '${repoRoot.path}/packages',
        ).listSync())
          if (e is Directory) ...<Directory>[
            Directory('${e.path}/lib'),
            Directory('${e.path}/test'),
          ],
        for (final String app in appNames) ...<Directory>[
          Directory('${repoRoot.path}/apps/$app/lib'),
          Directory('${repoRoot.path}/apps/$app/test'),
        ],
      ];
      for (final Directory d in roots) {
        for (final File f in dartSourcesIn(d)) {
          scanned++;
          if (_retiredName.hasMatch(
            stripCommentsAndStrings(f.readAsStringSync()),
          )) {
            hits.add(shortPath(f));
          }
        }
      }
      for (final String path in FixturePaths.all) {
        if (_retiredName.hasMatch(readFixture(path))) {
          hits.add('fixtures/$path');
        }
      }
      expect(scanned, greaterThan(100), reason: 'Dart 소스를 못 읽었다 — 경로가 낡았다.');
      expect(
        hits,
        isEmpty,
        reason:
            '`GoalPathPoint`·`seriesCode` 는 v1.4 에서 폐기됐다 — 목표 경로는 `PerfPoint` 두 목록'
            '(`planned`·`actual`)이다(01 §14-10).',
      );
    });

    test('C-39 ⑨ S7-9 파일이 PerfPoint.value 를 읽지 않고 ConfigRepository 를 말하지 않는다', () {
      // 자체 검증 — 대상 고르기.
      expect(
        _isGoalPathTarget('lib/src/goal_path/goal_path_chart.dart'),
        isTrue,
      );
      expect(_isGoalPathTarget(_goalPathScreen), isTrue);
      expect(
        _isGoalPathTarget('lib/src/screens/goal_path/goal_path_body.dart'),
        isTrue,
      );
      expect(
        _isGoalPathTarget('lib/src/screens/monthly_report_screen.dart'),
        isFalse,
      );
      expect(
        _isGoalPathTarget('lib/src/chart/perf_chart_painter.dart'),
        isFalse,
      );
      // 자체 검증 — 정규식(`.value` 두 정규식은 C-36 ⑦ 이 스니펫으로 이미 검증한다).
      for (final String s in <String>[
        'final ConfigRepository repo = ref.watch(x);',
        'ref.watch(plannerConfigRepositoryProvider)',
        'ref.watch(configRepositoryProvider)',
      ]) {
        expect(_configRepo.hasMatch(s), isTrue, reason: '양성 스니펫: $s');
      }
      for (final String s in <String>[
        'ref.watch(goalPathProvider(yyyyMm))',
        'final String t = vm.startingCapitalAssumptionText;',
      ]) {
        expect(_configRepo.hasMatch(s), isFalse, reason: '음성 스니펫: $s');
      }
      expect(
        _scanGoalPath(<String, String>{
          'a.dart':
              '// ConfigRepository 를 읽지 않는다 · p.value 금지\n'
              'Text(p.valueText);\n',
          'b.dart': 'final v = p.value;\n',
          'c.dart': 'final PerfPoint(:value) = p;\n',
          'd.dart': 'ref.watch(configRepositoryProvider);\n',
        }),
        <String>['b.dart', 'c.dart', 'd.dart'],
      );

      final Map<String, String> sources = <String, String>{};
      final Directory root = Directory(
        '${repoRoot.path}/packages/ui_analytics',
      );
      for (final File f in dartSourcesIn(Directory('${root.path}/lib'))) {
        final String rel = _relativeTo(root, f);
        if (_isGoalPathTarget(rel)) {
          sources['packages/ui_analytics/$rel'] = f.readAsStringSync();
        }
      }
      // 🆕 가드 — 목표 경로 DTO·창구를 말하는 파일은 S7-9 대상 + 프로바이더 파일뿐.
      expect(
        _goalPathMentionsOutside(<String, String>{
          'lib/src/goal_path/a.dart': 'void f(GoalPathVm vm) {}\n',
          _goalPathProvidersFile: 'final goalPathProvider = x; // GoalPathVm\n',
          'lib/src/widgets/goal_path_card.dart': 'void f(GoalPathVm vm) {}\n',
          'lib/src/screens/c.dart': '// GoalPathVm 은 S7-9 만 말한다\n',
        }),
        <String>['lib/src/widgets/goal_path_card.dart'],
      );
      final Map<String, String> all = <String, String>{
        for (final File f in dartSourcesIn(Directory('${root.path}/lib')))
          _relativeTo(root, f): f.readAsStringSync(),
      };
      expect(
        _goalPathMentionsOutside(all),
        isEmpty,
        reason:
            '`GoalPathVm`·`goalPath`·`goalPathProvider` 를 말하는 파일은 `lib/src/goal_path/**`·'
            '`lib/src/screens/goal_path_screen.dart`(·`screens/goal_path/**`)와 프로바이더 파일에만 둔다 — '
            '밖에 두면 ⑨ 스캔이 그 파일을 보지 않는다(03 §14 ⓐ · 01 §14-9).',
      );
      // 🔴 대상 파일이 아직 없으면(R11b 전) 통과한다 — 없는 파일로 실패시키지 않는다.
      expect(
        _scanGoalPath(sources),
        isEmpty,
        reason:
            'S7-9 는 `xNormalized`·`yNormalized`·`valueText` 로 그린다(01 §14-11) — `PerfPoint.value` '
            '는 골든 대조 전용이다. 가정 문장은 `GoalPathVm` 이 싣는다 — `ConfigRepository` 를 읽지 '
            '않는다(03 §17-17 · 01 §14-10).',
      );
    });

    test('C-39 자체 검증 — 망가뜨린 사본은 검사에 걸린다', () {
      final GoalPathRow on = goalPathRow(FixturePaths.m7M7GoalPathOn);
      final GoalPathRow off = goalPathRow(FixturePaths.m7M7GoalPathOff);
      final GoalPathRow hold = goalPathRow(FixturePaths.m7M7GoalPathHold);
      final GoalPathRow real = goalPathRow(FixturePaths.m7M7GoalPathRealworld);

      final List<_Mutation> mutations = <_Mutation>[
        // ①
        _Mutation('① 뒤로 가는 실제선 점', '크지 않다', _rowViolations, on, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'actual')[5]['x_normalized'] = 0.1;
        }),
        _Mutation(
          '① 빈 값 글자(결측 점)',
          'actual[3] — value_text',
          _rowViolations,
          real,
          (Map<String, Object?> j) {
            jsonObjects(j, 'actual')[3]['value_text'] = ' ';
          },
        ),
        _Mutation('① 빈 판정 문장', 'judgement_text', _rowViolations, on, (
          Map<String, Object?> j,
        ) {
          j['judgement_text'] = '';
        }),
        _Mutation('① 값은 더 큰데 자리가 더 낮다', 'value 는 더 큰데', _rowViolations, on, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'planned')[6]['y_normalized'] = 0.1;
        }),
        _Mutation(
          '① 값은 있는데 세로 자리가 없다',
          'y_normalized null',
          _rowViolations,
          on,
          (Map<String, Object?> j) {
            jsonObjects(j, 'actual')[2]['y_normalized'] = null;
          },
        ),
        // ②
        _Mutation('② 실제선 점이 하나 모자란다', '길이', _pairViolations, on, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'actual').removeLast();
        }),
        _Mutation('② 계획선 날짜가 다르다', '[4] 날짜', _pairViolations, off, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'planned')[4]['date'] = '2025-12-30';
        }),
        _Mutation('② 계획선 가로 자리가 다르다', '[2] x', _pairViolations, on, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'planned')[2]['x_normalized'] = 0.3;
        }),
        _Mutation(
          '② 계획선이 갭에서 끊겼다',
          'planned[3] — 계획선 결측',
          _pairViolations,
          real,
          (Map<String, Object?> j) {
            final Map<String, Object?> p = jsonObjects(j, 'planned')[3];
            p['value'] = null;
            p['y_normalized'] = null;
          },
        ),
        // ③
        _Mutation('③ 유보인데 선이 있다', '둘은 짝이다', _unavailableViolations, hold, (
          Map<String, Object?> j,
        ) {
          j['planned'] = deepCopyJson(on.json)['planned'];
        }),
        _Mutation('③ 선이 있는데 유보 문장', '둘은 짝이다', _unavailableViolations, on, (
          Map<String, Object?> j,
        ) {
          j['chart_unavailable_label'] = '관측이 모자라 경로를 그리지 않습니다.';
        }),
        _Mutation(
          '③ 유보인데 이탈 문장',
          'deviation_text',
          _unavailableViolations,
          hold,
          (Map<String, Object?> j) {
            j['deviation_text'] = '계획선보다 아래에 있습니다.';
          },
        ),
        _Mutation('③ 유보인데 눈금이 있다', 'y_ticks', _unavailableViolations, hold, (
          Map<String, Object?> j,
        ) {
          j['y_ticks'] = deepCopyJson(on.json)['y_ticks'];
        }),
        // ④
        _Mutation('④ 눈금 6개', '눈금 6개', _tickRule, on, (Map<String, Object?> j) {
          final List<Object?> t = j['y_ticks']! as List<Object?>;
          t.add(<String, Object?>{'normalized': 1.1, 'label': '2,800만원'});
          t.add(<String, Object?>{'normalized': 1.2, 'label': '3,000만원'});
        }),
        _Mutation('④ 기준선 2개', '기준선', _tickRule, on, (Map<String, Object?> j) {
          final List<Map<String, Object?>> t = jsonObjects(j, 'y_ticks');
          t[0]['is_baseline'] = true;
          t[1]['is_baseline'] = true;
        }),
        // ⑤
        _Mutation(
          '⑤ 띠가 결측 점 하나를 덜 덮는다',
          '정규 자리로 덮는 점 [3]',
          _segmentRule,
          real,
          (Map<String, Object?> j) {
            jsonObjects(j, 'segments')[0]['end_normalized'] = 0.5;
          },
        ),
        _Mutation('⑤ 구간 겹침', '겹친다', _segmentRule, real, (
          Map<String, Object?> j,
        ) {
          final List<Object?> s = j['segments']! as List<Object?>;
          s.add(<String, Object?>{
            'from': '2025-12-01',
            'to': '2026-03-31',
            'kind': 'UNAVAILABLE',
            'label': '결측',
            'start_normalized': 0.6,
            'end_normalized': 0.72,
          });
        }),
        // ⑥
        _Mutation('⑥ 값 글자가 달성률', 'value_text 에 %', _textRuleViolations, on, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'actual')[7]['value_text'] = '계획의 99%';
        }),
        _Mutation('⑥ 실전 조건 문장에 1억', '1억', _textRuleViolations, real, (
          Map<String, Object?> j,
        ) {
          j['starting_capital_assumption_text'] = '1억을 넣은 경로입니다.';
        }),
        _Mutation('⑥ 최악의 해', '최악의 해', _textRuleViolations, off, (
          Map<String, Object?> j,
        ) {
          j['honest_expectation_worst_text'] = '최악의 해에는 손실이 납니다.';
        }),
      ];

      final Set<String> covered = <String>{};
      for (final _Mutation m in mutations) {
        expect(
          m.rule(m.row.path, m.row.where, m.row.vm),
          isEmpty,
          reason: '${m.name} — 고치기 전 원본이 이미 걸린다(변이 확인이 뜻을 잃는다).',
        );
        expect(
          m.rule(m.row.path, m.row.where, m.row.mutated(m.edit)),
          contains(contains(m.hit)),
          reason: '${m.name} — 망가뜨렸는데 검사가 통과한다(검사가 늘 참이다).',
        );
        covered.add(m.name.split(' ').first);
      }
      expect(covered, <String>{'①', '②', '③', '④', '⑤', '⑥'});

      // ⑦ — 원문 행 사본(링크 규칙은 DTO 가 아니라 JSON 키를 본다).
      final Map<String, Object?> linked = decodeEnvelope(
        readFixture(FixturePaths.m7M7Monthly202608),
      ).rows.single;
      final Map<String, Object?> masked = decodeEnvelope(
        readFixture(FixturePaths.m7M7MonthlyMaskedIntegrity),
      ).rows.single;
      expect(_goalLinkViolations('w', linked, mustBeAbsent: false), isEmpty);
      expect(_goalLinkViolations('w', masked, mustBeAbsent: true), isEmpty);
      expect(
        _goalLinkViolations(
          'w',
          deepCopyJson(linked)
            ..['goal_deep_link'] = 'aaq://report/goal/2026-07',
          mustBeAbsent: false,
        ),
        contains(contains('그 달')),
      );
      expect(
        _goalLinkViolations(
          'w',
          deepCopyJson(linked)..['goal_deep_link'] = 'aaq://report/2026-08',
          mustBeAbsent: false,
        ),
        contains(contains('그 달')),
      );
      expect(
        _goalLinkViolations(
          'w',
          deepCopyJson(masked)
            ..['goal_deep_link'] = 'aaq://report/goal/2026-08',
          mustBeAbsent: true,
        ),
        contains(contains('없어야')),
      );
    });
  });
}

/// 검사 1종 — 위반을 문장 목록으로 돌려준다(빈 목록 = 통과).
typedef _Rule = List<String> Function(String path, String where, GoalPathVm v);

/// 변이 1건(자체 검증용 — 픽스처 파일은 고치지 않는다).
class _Mutation {
  const _Mutation(this.name, this.hit, this.rule, this.row, this.edit);

  final String name;

  /// 걸려야 하는 조항의 글자(엉뚱한 조항에 걸려 통과하는 것을 막는다).
  final String hit;
  final _Rule rule;
  final GoalPathRow row;
  final void Function(Map<String, Object?> json) edit;
}

void _expectClean(_Rule rule) {
  final List<GoalPathRow> rows = allGoalPathRows();
  expect(<String>{
    for (final GoalPathRow r in rows) r.path,
  }, containsAll(knownGoalPathFixtures));
  final List<String> bad = <String>[
    for (final GoalPathRow r in rows) ...rule(r.path, r.where, r.vm),
  ];
  expect(bad, isEmpty, reason: bad.join('\n'));
}

/// 두 선(계획 · 실제) — 한 축을 쓴다(01 §14-11).
Map<String, List<PerfPoint>> _lines(GoalPathVm v) => <String, List<PerfPoint>>{
  'planned': v.planned,
  'actual': v.actual,
};

/// 비어서는 안 되는 문장 필드(JSON 키 → 값).
Map<String, String> _sentences(GoalPathVm v) => <String, String>{
  'judgement_text': v.judgementText,
  'basis_text': v.basisText,
  'period_label': v.periodLabel,
  'planned_label': v.plannedLabel,
  'actual_label': v.actualLabel,
  'backtest_basis_text': v.backtestBasisText,
  'starting_capital_assumption_text': v.startingCapitalAssumptionText,
  'honest_expectation_text': v.honestExpectationText,
  'honest_expectation_worst_text': v.honestExpectationWorstText,
  'disclaimer_text': v.disclaimerText,
  'as_of.label': v.asOf.label,
  if (v.deviationText != null) 'deviation_text': v.deviationText!,
};

/// ① C-36 ①③⑨⑪ + C-10 ⑤ + 문장 필드.
List<String> _rowViolations(String path, String where, GoalPathVm v) {
  final List<String> bad = <String>[
    for (final MapEntry<String, List<PerfPoint>> line in _lines(
      v,
    ).entries) ...<String>[
      ...xLineViolations(where, line.key, line.value),
      ...pointTextViolations(where, line.key, line.value),
      ...pointCountViolations(where, line.key, line.value),
    ],
    ...valueOrderViolations(where, _lines(v)),
    ...valuePairViolations(where, _lines(v)),
  ];
  for (final MapEntry<String, String> e in _sentences(v).entries) {
    if (e.value.trim().isEmpty) {
      bad.add('$where — ${e.key} 가 비었다');
    }
  }
  if (v.actual.isNotEmpty &&
      !v.actual.any((PerfPoint p) => p.yNormalized != null)) {
    bad.add('$where — 실제선에 값 있는 점이 하나도 없다(유보 문장으로 와야 한다)');
  }
  return bad;
}

/// ② 계획선 ↔ 실제선.
List<String> _pairViolations(String path, String where, GoalPathVm v) {
  if (v.planned.length != v.actual.length) {
    return <String>[
      '$where — 계획선 ${v.planned.length}점 ≠ 실제선 ${v.actual.length}점(길이가 같아야 한다)',
    ];
  }
  final List<String> bad = <String>[];
  for (int i = 0; i < v.planned.length; i++) {
    final PerfPoint p = v.planned[i];
    final PerfPoint a = v.actual[i];
    if (p.date.yyyyMmDd != a.date.yyyyMmDd) {
      bad.add('$where [$i] 날짜 ${p.date.yyyyMmDd} ≠ 실제선 ${a.date.yyyyMmDd}');
    }
    if (p.xNormalized != a.xNormalized) {
      bad.add('$where [$i] x ${p.xNormalized} ≠ 실제선 ${a.xNormalized}');
    }
    if (p.yNormalized == null || p.value == null) {
      bad.add('$where planned[$i] — 계획선 결측(계획선은 끊기지 않는다)');
    }
  }
  return bad;
}

/// ③ 유보 문장 ⇔ 네 목록이 빈 목록.
List<String> _unavailableViolations(String path, String where, GoalPathVm v) {
  final List<String> bad = <String>[];
  final String? label = v.chartUnavailableLabel;
  final Map<String, int> lists = <String, int>{
    'planned': v.planned.length,
    'actual': v.actual.length,
    'y_ticks': v.yTicks.length,
    'segments': v.segments.length,
  };
  if (label != null) {
    if (label.trim().isEmpty) {
      bad.add('$where — chart_unavailable_label 이 빈 글자다');
    }
    for (final MapEntry<String, int> e in lists.entries) {
      if (e.value != 0) {
        bad.add('$where — 유보 문장이 있는데 ${e.key} 가 ${e.value}개다(둘은 짝이다)');
      }
    }
    if (v.deviationText != null) {
      bad.add('$where — 유보인데 deviation_text 가 있다');
    }
  } else if (v.planned.isEmpty || v.actual.isEmpty) {
    bad.add('$where — 유보 문장이 없는데 선이 비었다(둘은 짝이다)');
  }
  return bad;
}

/// ④ 눈금(C-36 ④ 재사용).
List<String> _tickRule(String path, String where, GoalPathVm v) =>
    tickViolations(where, v.yTicks);

/// ⑤ 구간(C-36 ④b·⑥ 재사용 — 띠는 실제선의 구간이다).
List<String> _segmentRule(String path, String where, GoalPathVm v) => <String>[
  ...segmentOrderViolations(where, v.segments),
  ...segmentCoverViolations(where, v.segments, v.actual),
];

/// ⑥ 글자 규칙.
List<String> _textRuleViolations(String path, String where, GoalPathVm v) {
  final List<String> bad = <String>[];
  for (final MapEntry<String, List<PerfPoint>> line in _lines(v).entries) {
    for (int i = 0; i < line.value.length; i++) {
      if (line.value[i].valueText.contains('%')) {
        bad.add('$where ${line.key}[$i] — value_text 에 % 가 있다(달성률 금지)');
      }
    }
  }
  for (final String t in _allStrings(v)) {
    if (t.contains('최악의 해')) {
      bad.add('$where — 문장에 «최악의 해»가 있다: $t');
    }
    if (path == FixturePaths.m7M7GoalPathRealworld && t.contains('1억')) {
      bad.add('$where — 실전 조건 문장에 «1억»이 있다: $t');
    }
  }
  return bad;
}

/// [v] 의 모든 문자열 값(`경로=값`).
///
/// `toJson` 은 중첩 DTO 를 객체로 남길 수 있다 — 한 번 JSON 으로 왕복해 문자열만 모은다.
List<String> _allStrings(GoalPathVm v) {
  final List<String> out = <String>[];
  walkJson(jsonDecode(jsonEncode(v.toJson())), (
    String jsonPath,
    String key,
    Object? value,
  ) {
    if (value is String) {
      out.add('$jsonPath=$value');
    }
  });
  return out;
}

/// ⑦ 월간 리포트 1행의 `goal_deep_link`.
List<String> _goalLinkViolations(
  String where,
  Map<String, Object?> row, {
  required bool mustBeAbsent,
}) {
  final Object? link = row['goal_deep_link'];
  if (mustBeAbsent) {
    return <String>[
      if (row.containsKey('goal_deep_link'))
        '$where — 가림·미생성 리포트에는 goal_deep_link 가 없어야 한다(지금 $link)',
    ];
  }
  if (link == null) {
    return const <String>[];
  }
  final String expected = 'aaq://report/goal/${row['yyyy_mm']}';
  return <String>[
    if (link != expected)
      '$where — goal_deep_link $link ≠ $expected(그 달의 목표 경로여야 한다)',
    if (link is String && !AppRoutes.isRegistered(link))
      '$where — goal_deep_link $link 가 등록된 목적지가 아니다',
  ];
}

bool _isGoalPathTarget(String rel) =>
    rel == _goalPathScreen ||
    rel.startsWith(_goalPathDir) ||
    rel.startsWith(_goalPathScreensDir);

/// ⑨ 가드 — 주석을 지운 소스가 목표 경로 DTO·창구를 말하는데 S7-9 대상도 프로바이더 파일도 아닌 파일.
List<String> _goalPathMentionsOutside(Map<String, String> sources) => <String>[
  for (final MapEntry<String, String> e in sources.entries)
    if (!_isGoalPathTarget(e.key) &&
        e.key != _goalPathProvidersFile &&
        _goalPathMention.hasMatch(stripComments(e.value)))
      e.key,
];

/// ⑨ 스캔 — `.value` 두 정규식(주석만 지운 소스 · 보간 안 참조까지) + `ConfigRepository`(주석 지운 소스).
List<String> _scanGoalPath(Map<String, String> sources) => <String>[
  for (final MapEntry<String, String> e in sources.entries)
    if (perfValueRef.hasMatch(stripComments(e.value)) ||
        perfValuePattern.hasMatch(stripComments(e.value)) ||
        _configRepo.hasMatch(stripComments(e.value)))
      e.key,
];

String _relativeTo(Directory root, File f) {
  final String base = root.path.replaceAll(r'\', '/');
  final String p = f.path.replaceAll(r'\', '/');
  return p.startsWith('$base/') ? p.substring(base.length + 1) : p;
}
