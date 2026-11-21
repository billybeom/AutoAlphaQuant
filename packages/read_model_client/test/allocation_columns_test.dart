// 🆕 E11q-s04a — S04 배분 `rm_config_view` 7열 → 계약 VM(설계 13 §8 R211 · 01 §8 미결 210 · K206 뷰어 판).
//
// 🔴 원천 = 계약 표본 `m9/allocation_editor*`(엔진이 낸 VM 과 같다 — core `allocation_view_test` 표본 대조) · 열 이름 =
//    `AllocationReadModelColumns` 만(글자 리터럴 0) · 못 읽으면 던진다(빈 VM · 기본 글자 0).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart'
    show
        AllocationEditorVm,
        AllocationReadModelColumns,
        AllocationReadOnlyRow,
        AllocationReadOnlySection;
import 'package:read_model_client/read_model_client.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures/m9';

AllocationEditorVm _fixture(String file) {
  final Map<String, Object?> env =
      jsonDecode(File('$_fx/$file').readAsStringSync()) as Map<String, Object?>;
  final List<Object?> rows = env['rows']! as List<Object?>;
  return AllocationEditorVm.fromJson(rows.single! as Map<String, Object?>);
}

/// 시험 안 도우미 — VM → `rm_config_view` 배분 7열(원격 왕복 꼴 = JSON 문자열을 거친 값 · C-62 ⑩ 꼴).
Map<String, Object?> _columns(AllocationEditorVm v) => jsonDecode(
  jsonEncode(<String, Object?>{
    AllocationReadModelColumns.label: v.current.label,
    AllocationReadModelColumns.weightsText: v.current.weightsText,
    AllocationReadModelColumns.backtestText: v.current.backtestText,
    AllocationReadModelColumns.honestNoteText: v.current.honestNoteText,
    AllocationReadModelColumns.sections: <Object?>[
      for (final AllocationReadOnlySection s in v.sections) s.toJson(),
    ],
    AllocationReadModelColumns.changePathLines: v.changePathLines,
    AllocationReadModelColumns.asOf: v.asOf.toJson(),
  }),
) as Map<String, Object?>;

void main() {
  test('표본 VM → 7열 → 함수 → 같은 VM(정상 · 오래된 판 둘 다)', () {
    for (final String f in <String>[
      'allocation_editor.json',
      'allocation_editor_stale.json',
    ]) {
      final AllocationEditorVm fx = _fixture(f);
      final Map<String, Object?> row = _columns(fx);
      expect(row.keys.toList(), AllocationReadModelColumns.all, reason: f);
      expect(allocationEditorVmFromColumns(row), fx, reason: f);
    }
  });

  test('7열 밖의 칸(규칙 5조 · 버전 스탬프)은 읽지 않는다 — 있어도 같은 VM', () {
    final AllocationEditorVm fx = _fixture('allocation_editor.json');
    final Map<String, Object?> row = <String, Object?>{
      ..._columns(fx),
      'row_version': 7,
      'lease_epoch': 2,
      'mode': 'LIVE',
    };
    expect(allocationEditorVmFromColumns(row), fx);
  });

  test('덧붙임 없는 행 = null 칸이든 키가 없든 noteText null', () {
    final AllocationEditorVm fx = _fixture('allocation_editor.json');
    final AllocationEditorVm one = fx.copyWith(
      sections: const <AllocationReadOnlySection>[
        AllocationReadOnlySection(
          title: 't',
          rows: <AllocationReadOnlyRow>[
            AllocationReadOnlyRow(code: 'X', label: 'l', valueText: 'v'),
          ],
        ),
      ],
    );
    final Map<String, Object?> row = _columns(one);
    expect(allocationEditorVmFromColumns(row), one);
    final Map<String, Object?> firstRow =
        (((row[AllocationReadModelColumns.sections]! as List<Object?>).single!
                        as Map<String, Object?>)['rows']!
                    as List<Object?>)
                .single!
            as Map<String, Object?>;
    firstRow.remove('note_text');
    expect(
      allocationEditorVmFromColumns(row).sections.single.rows.single.noteText,
      isNull,
    );
  });

  test('🔴 열 하나라도 없으면(7가지 각각 · null 포함) 던진다 — 빈 VM · 기본 글자 0', () {
    final Map<String, Object?> full = _columns(
      _fixture('allocation_editor.json'),
    );
    for (final String c in AllocationReadModelColumns.all) {
      final Map<String, Object?> missing = Map<String, Object?>.of(full)
        ..remove(c);
      expect(
        () => allocationEditorVmFromColumns(missing),
        throwsA(isA<FormatException>()),
        reason: '$c 없음',
      );
      final Map<String, Object?> nulled = Map<String, Object?>.of(full)
        ..[c] = null;
      expect(
        () => allocationEditorVmFromColumns(nulled),
        throwsA(isA<FormatException>()),
        reason: '$c null',
      );
    }
  });

  test(
    '🔴 꼴이 틀리면 던진다 — 묶음 · 바꾸는 길이 목록 아님 · 글자 칸이 글자 아님 · 행 칸 빠짐 · 기준 시각 꼴',
    () {
      final Map<String, Object?> full = _columns(
        _fixture('allocation_editor.json'),
      );
      Map<String, Object?> withCol(String c, Object? v) =>
          Map<String, Object?>.of(full)..[c] = v;
      final List<(String, Map<String, Object?>)> bad =
          <(String, Map<String, Object?>)>[
            (
              '묶음 = 객체',
              withCol(AllocationReadModelColumns.sections, <String, Object?>{}),
            ),
            ('묶음 = 글자', withCol(AllocationReadModelColumns.sections, '[]')),
            (
              '바꾸는 길 = 글자',
              withCol(AllocationReadModelColumns.changePathLines, 'x'),
            ),
            (
              '바꾸는 길 안 = 숫자',
              withCol(AllocationReadModelColumns.changePathLines, <Object?>[1]),
            ),
            ('카드 글자 = 숫자', withCol(AllocationReadModelColumns.label, 3)),
            (
              '묶음 안 = 글자',
              withCol(AllocationReadModelColumns.sections, <Object?>['s']),
            ),
            (
              '묶음 rows 없음',
              withCol(AllocationReadModelColumns.sections, <Object?>[
                <String, Object?>{'title': 't'},
              ]),
            ),
            (
              '행 value_text 없음',
              withCol(AllocationReadModelColumns.sections, <Object?>[
                <String, Object?>{
                  'title': 't',
                  'rows': <Object?>[
                    <String, Object?>{'code': 'X', 'label': 'l'},
                  ],
                },
              ]),
            ),
            (
              '행 note_text = 숫자',
              withCol(AllocationReadModelColumns.sections, <Object?>[
                <String, Object?>{
                  'title': 't',
                  'rows': <Object?>[
                    <String, Object?>{
                      'code': 'X',
                      'label': 'l',
                      'value_text': 'v',
                      'note_text': 1,
                    },
                  ],
                },
              ]),
            ),
            ('기준 시각 = 글자', withCol(AllocationReadModelColumns.asOf, 'x')),
            (
              '기준 시각 칸 빠짐',
              withCol(AllocationReadModelColumns.asOf, <String, Object?>{
                'label': 'x',
              }),
            ),
          ];
      for (final (String why, Map<String, Object?> row) in bad) {
        expect(
          () => allocationEditorVmFromColumns(row),
          throwsA(isA<FormatException>()),
          reason: why,
        );
      }
    },
  );
}
