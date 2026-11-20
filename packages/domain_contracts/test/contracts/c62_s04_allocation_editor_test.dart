// C-62 S04 첫 판 — M9 배분 화면(보기 전용) VM · 창구 · 행 코드 사전 · `rm_config_view` 배분 7열 — 01 §37
// (🆕 계약 v1.28 · 발주자 위임 2026-11-14 — 권고대로 · K196~K207).
//
// 정의: 「S04 첫 판은 `AllocationEditorVm`(지금 배분 카드 1 · 읽기 묶음 셋 · 바꾸는 길 · 기준 시각 — 엔진 `AllocationView` 칸 1:1)을
//        `SettingsRepository.watchAllocationEditor()`(폰 · 뷰어 공통)로 읽는다 · 쓰기 · 판정 · 프리셋 0(193 ⓐ · 194 ⓐ) ·
//        행 코드 = `AllocationRowCodes` · 뷰어 열 = `AllocationReadModelColumns`(G-22 · 열 → VM 왕복)」.
//   ① 표본 키 ② 카드 ③ 묶음 셋 ④ 행 코드 ⑤ 금 두 행 ⑥ 바꾸는 길 ⑦ 보기 전용 ⑧ 사전 ⑨ 열 이름
//   ⑩ 열 → VM 왕복 ⑪ 받침대 ⑫ 포트 경계.
//
// 🔴 픽스처 불변식 + 포트 경계만 본다 — S04 화면 규칙(쓰기 0 · 골든)은 Bob 카드 `R8b-Bob-M9S04` 정적 묶음 몫.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

const List<String> _vms = <String>[
  FixturePaths.m9AllocationEditor,
  FixturePaths.m9AllocationEditorStale,
];

const List<String> _vmKeys = <String>[
  'current',
  'sections',
  'change_path_lines',
  'as_of',
];
const List<String> _cardKeys = <String>[
  'label',
  'weights_text',
  'backtest_text',
  'honest_note_text',
];
const List<String> _sectionKeys = <String>['title', 'rows'];
const List<String> _rowKeys = <String>[
  'code',
  'label',
  'value_text',
  'note_text',
];

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

Map<String, Object?> _vm(String path) =>
    (_env(path)['rows']! as List).cast<Map<String, Object?>>().single;

AllocationEditorVm _typed(String path) =>
    AllocationEditorVm.fromJson(_vm(path));

Iterable<String> _jsonKeys(Object? v) sync* {
  if (v is Map) {
    for (final MapEntry<Object?, Object?> e in v.entries) {
      yield e.key! as String;
      yield* _jsonKeys(e.value);
    }
  } else if (v is List) {
    for (final Object? x in v) {
      yield* _jsonKeys(x);
    }
  }
}

/// 시험 안 도우미 — VM → `rm_config_view` 배분 7열 맵(엔진 `allocationViewColumns` 와 같은 꼴 · jsonb = JSON 값).
Map<String, Object?> _toColumns(AllocationEditorVm v) => <String, Object?>{
  AllocationReadModelColumns.label: v.current.label,
  AllocationReadModelColumns.weightsText: v.current.weightsText,
  AllocationReadModelColumns.backtestText: v.current.backtestText,
  AllocationReadModelColumns.honestNoteText: v.current.honestNoteText,
  AllocationReadModelColumns.sections: jsonDecode(
    jsonEncode(<Object?>[
      for (final AllocationReadOnlySection s in v.sections) s.toJson(),
    ]),
  ),
  AllocationReadModelColumns.changePathLines: <String>[...v.changePathLines],
  AllocationReadModelColumns.asOf: jsonDecode(jsonEncode(v.asOf.toJson())),
};

/// 시험 안 도우미 — 7열 맵 → VM(뷰어 «열 → VM» 함수의 꼴 · 01 §8 미결 210).
AllocationEditorVm _fromColumns(Map<String, Object?> c) => AllocationEditorVm(
  current: AllocationProfileCard(
    label: c[AllocationReadModelColumns.label]! as String,
    weightsText: c[AllocationReadModelColumns.weightsText]! as String,
    backtestText: c[AllocationReadModelColumns.backtestText]! as String,
    honestNoteText: c[AllocationReadModelColumns.honestNoteText]! as String,
  ),
  sections: <AllocationReadOnlySection>[
    for (final Object? s in c[AllocationReadModelColumns.sections]! as List)
      AllocationReadOnlySection.fromJson(s! as Map<String, dynamic>),
  ],
  changePathLines: <String>[
    for (final Object? l
        in c[AllocationReadModelColumns.changePathLines]! as List)
      l! as String,
  ],
  asOf: AsOf.fromJson(
    c[AllocationReadModelColumns.asOf]! as Map<String, dynamic>,
  ),
);

void main() {
  group('C-62 S04 첫 판 — 배분 화면 보기 전용 (01 §37 · 계약 v1.28)', () {
    test('C-62 ① 표본 2 — 1행 VM 봉투 · 키 == toJson(선언 차례) · 왕복 · 봉투 LIVE', () {
      for (final String path in _vms) {
        final Map<String, Object?> env = _env(path);
        expect(
          (env['meta']! as Map<String, Object?>)['mode'],
          'LIVE',
          reason: path,
        );
        final Map<String, Object?> raw = _vm(path);
        expect(raw.keys.toList(), _vmKeys, reason: path);
        final AllocationEditorVm vm = AllocationEditorVm.fromJson(raw);
        expect(vm.toJson().keys.toList(), _vmKeys, reason: path);
        expect(AllocationEditorVm.fromJson(vm.toJson()), vm, reason: path);
        expect(
          (raw['current']! as Map<String, Object?>).keys.toList(),
          _cardKeys,
        );
        expect(vm.current.toJson().keys.toList(), _cardKeys);
        for (final Map<String, Object?> s
            in (raw['sections']! as List).cast<Map<String, Object?>>()) {
          expect(s.keys.toList(), _sectionKeys, reason: path);
          for (final Map<String, Object?> r
              in (s['rows']! as List).cast<Map<String, Object?>>()) {
            expect(r.keys.toList(), _rowKeys, reason: path);
            expect(
              AllocationReadOnlyRow.fromJson(r).toJson().keys.toList(),
              _rowKeys,
            );
          }
        }
      }
    });

    test('C-62 ② 카드 — 4칸 비지 않음 · 정직 기대 줄은 백테스트 줄과 함께', () {
      for (final String path in _vms) {
        final AllocationProfileCard c = _typed(path).current;
        expect(
          <String>[c.label, c.weightsText, c.backtestText, c.honestNoteText],
          everyElement(isNotEmpty),
          reason: path,
        );
        expect(c.honestNoteText, isNot(c.backtestText), reason: path);
      }
    });

    test('C-62 ③ 묶음 셋 — 차례 = 엔진(밴드 · 한도 · 금) · 행 수 3 · 5 · 2 · 머리 비지 않음', () {
      for (final String path in _vms) {
        final AllocationEditorVm vm = _typed(path);
        expect(vm.sections, hasLength(3), reason: path);
        expect(
          vm.sections
              .map((AllocationReadOnlySection s) => s.rows.length)
              .toList(),
          <int>[3, 5, 2],
          reason: path,
        );
        for (final AllocationReadOnlySection s in vm.sections) {
          expect(s.title, isNotEmpty);
        }
      }
    });

    test('C-62 ④ 행 코드 — ∈ 사전 · 유일 · 차례 = 사전 차례 · 이름·값 비지 않음', () {
      for (final String path in _vms) {
        final List<AllocationReadOnlyRow> rows = <AllocationReadOnlyRow>[
          for (final AllocationReadOnlySection s in _typed(path).sections)
            ...s.rows,
        ];
        final List<String> codes = rows
            .map((AllocationReadOnlyRow r) => r.code)
            .toList();
        expect(codes, AllocationRowCodes.ordered, reason: path);
        expect(codes.toSet(), hasLength(codes.length), reason: path);
        for (final AllocationReadOnlyRow r in rows) {
          expect(AllocationRowCodes.values, contains(r.code));
          expect(r.label, isNotEmpty);
          expect(r.valueText, isNotEmpty);
        }
      }
    });

    test('C-62 ⑤ 금 두 행 — C 안 하드 캡 · 총자산 감시선이 따로(합치지 않음) · 같은 묶음', () {
      for (final String path in _vms) {
        final AllocationReadOnlySection gold = _typed(path).sections.last;
        expect(
          gold.rows.map((AllocationReadOnlyRow r) => r.code).toList(),
          <String>[
            AllocationRowCodes.goldSleeveCCap,
            AllocationRowCodes.goldTotalMonitor,
          ],
          reason: path,
        );
        expect(gold.rows.first.valueText, isNot(gold.rows.last.valueText));
      }
    });

    test('C-62 ⑥ 바꾸는 길 — 3줄 · 비지 않음 · 링크 칸 0', () {
      for (final String path in _vms) {
        final AllocationEditorVm vm = _typed(path);
        expect(vm.changePathLines, hasLength(3), reason: path);
        expect(vm.changePathLines, everyElement(isNotEmpty));
        expect(
          _jsonKeys(_vm(path))
              .toSet()
              .intersection(<String>{'deep_link', 'link'}),
          isEmpty,
          reason: path,
        );
      }
    });

    test('C-62 ⑦ 🔴 보기 전용 — 판정·잠김·빈·동작·편집 키 0(표본 · toJson)', () {
      const Set<String> bad = <String>{
        'level',
        'locked_label',
        'empty_label',
        'apply',
        'apply_action',
        'preview',
        'draft',
        'slider',
        'select_action',
        'presets',
        'actions',
      };
      for (final String path in _vms) {
        expect(
          _jsonKeys(_vm(path)).toSet().intersection(bad),
          isEmpty,
          reason: path,
        );
        expect(
          _jsonKeys(_typed(path).toJson()).toSet().intersection(bad),
          isEmpty,
          reason: path,
        );
      }
      expect(_typed(FixturePaths.m9AllocationEditor).asOf.staleLabel, isNull);
      expect(
        _typed(FixturePaths.m9AllocationEditorStale).asOf.staleLabel,
        isNotNull,
      );
      expect(
        (_env(FixturePaths.m9AllocationEditorStale)['as_of']!
                as Map<String, Object?>)
            .containsKey('stale_label'),
        isFalse,
        reason: '낡음 = VM as_of 만(봉투 as_of 0 — m9/backup_stale 선례)',
      );
    });

    test('C-62 ⑧ 사전 — 10 · 차례 목록 == 집합 · byDomain 등재 · 다른 사전과 겹침 0', () {
      expect(AllocationRowCodes.values, hasLength(10));
      expect(AllocationRowCodes.ordered.toSet(), AllocationRowCodes.values);
      expect(
        ContractCodes.byDomain['allocation_row'],
        AllocationRowCodes.values,
      );
      for (final MapEntry<String, Set<String>> e
          in ContractCodes.byDomain.entries) {
        if (e.key == 'allocation_row') continue;
        expect(
          e.value.intersection(AllocationRowCodes.values),
          isEmpty,
          reason: '${e.key} 와 겹친다',
        );
      }
    });

    test(
      'C-62 ⑨ 열 이름 — 7 · 유일 · `allocation_` 접두 · 묶음 jsonb 행 키 == 행 toJson 키',
      () {
        expect(AllocationReadModelColumns.all, hasLength(7));
        expect(AllocationReadModelColumns.all.toSet(), hasLength(7));
        expect(
          AllocationReadModelColumns.all,
          everyElement(startsWith('allocation_')),
        );
        expect(AllocationReadModelColumns.all, <String>[
          'allocation_label',
          'allocation_weights_text',
          'allocation_backtest_text',
          'allocation_honest_note_text',
          'allocation_sections',
          'allocation_change_path_lines',
          'allocation_as_of',
        ]);
        const AllocationReadOnlyRow r = AllocationReadOnlyRow(
          code: AllocationRowCodes.bandCoreB,
          label: 'l',
          valueText: 'v',
        );
        expect(r.toJson().keys.toList(), _rowKeys);
      },
    );

    test('C-62 ⑩ 열 → VM 왕복 — 표본 VM 을 7열로 펴고 다시 지어 같은 VM(G-22 · 열 ⊇ 필수 칸)', () {
      for (final String path in _vms) {
        final AllocationEditorVm vm = _typed(path);
        final Map<String, Object?> cols = _toColumns(vm);
        expect(cols.keys.toList(), AllocationReadModelColumns.all);
        expect(_fromColumns(cols), vm, reason: path);
      }
    });

    test('C-62 ⑪ 받침대 — watchAllocationEditor = 동기 throw · 반환 타입', () {
      expect(
        () => UnimplementedSettingsRepository().watchAllocationEditor(),
        throwsA(isA<UnimplementedError>()),
      );
      final Stream<AllocationEditorVm> Function() w =
          UnimplementedSettingsRepository().watchAllocationEditor;
      expect(w, isNotNull);
    });

    test('C-62 ⑫ 포트 경계 — ui_*(ui_settings 제외)에 새 이름 0 · 표본에 손익·금액 키 0', () {
      final List<RegExp> names = <RegExp>[
        RegExp(r'\bAllocationEditorVm\b'),
        RegExp(r'\bAllocationProfileCard\b'),
        RegExp(r'\bAllocationReadOnlySection\b'),
        RegExp(r'\bAllocationReadOnlyRow\b'),
        RegExp(r'\bAllocationRowCodes\b'),
        RegExp(r'\bAllocationReadModelColumns\b'),
        RegExp(r'\bwatchAllocationEditor\s*\('),
      ];
      final List<String> offenders = <String>[];
      int scanned = 0;
      for (final String name in uiPackageNames) {
        if (name == 'ui_settings') continue;
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) continue;
        for (final File f in dartSourcesIn(lib)) {
          scanned++;
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final RegExp rx in names) {
            if (rx.hasMatch(code)) {
              offenders.add('${shortPath(f)}: ${rx.pattern}');
            }
          }
        }
      }
      expect(scanned, greaterThan(0), reason: 'ui_*/lib 를 못 읽었다');
      expect(
        offenders,
        isEmpty,
        reason: '🔴 S04 화면은 ui_settings 만 그린다(M9 · Bob R8b)',
      );
      const Set<String> money = <String>{
        'amount',
        'cash',
        'pnl',
        'profit',
        'krw',
        'won',
        'balance',
      };
      for (final String path in _vms) {
        expect(
          _jsonKeys(_vm(path)).toSet().intersection(money),
          isEmpty,
          reason: path,
        );
      }
    });
  });
}
