// 🆕 E11q-s04a(설계 13 §8 R211 · 01 §8 미결 210 의 «함수» 몫) — `rm_config_view` S04 배분 7열 → 계약 `AllocationEditorVm`.
//
// 🔴 열 이름 = 계약 `AllocationReadModelColumns`(엔진 `allocationViewColumns` 가 같은 이름으로 싣는다 · 01 §6-4 · G-22).
// 🔴 못 읽으면 던진다(K206 뷰어 판) — 열이 없거나 꼴이 틀리면 [FormatException]. 빈 VM · 기본 글자 · 빈 목록으로 채우지 않는다
//    («읽은 것처럼» 보이는 갈래 0). 화면은 그 오류를 공용 오류 위젯으로 보인다.
// 🔴 이 패키지는 `domain_contracts` 만 읽는다(core 0 · 축약 타입 0 — 01 §1-1 · tool/check_boundaries.sh [9]).
// 🔵 남은 몫(미결 210): 뷰어 앱 레지스트리 · 뷰어 `SettingsRepository` 구현 · push 층이 7열을 싣는지 — 뷰어 조립 레인.

import 'package:domain_contracts/domain_contracts.dart'
    show
        AllocationEditorVm,
        AllocationProfileCard,
        AllocationReadModelColumns,
        AllocationReadOnlyRow,
        AllocationReadOnlySection,
        AsOf;

/// `rm_config_view` 한 행(모드별 1행)의 S04 배분 7열 → [AllocationEditorVm].
///
/// [row] = 열 이름 → 값(jsonb 열 = JSON 으로 풀린 값). 7열 밖의 칸(규칙 5조 4칸 · 버전 스탬프 등)은 읽지 않는다.
/// 🔴 열이 없거나(null 포함) 꼴이 틀리면 [FormatException].
AllocationEditorVm allocationEditorVmFromColumns(Map<String, Object?> row) {
  return AllocationEditorVm(
    current: AllocationProfileCard(
      label: _text(row, AllocationReadModelColumns.label),
      weightsText: _text(row, AllocationReadModelColumns.weightsText),
      backtestText: _text(row, AllocationReadModelColumns.backtestText),
      honestNoteText: _text(row, AllocationReadModelColumns.honestNoteText),
    ),
    sections: <AllocationReadOnlySection>[
      for (final (int i, Object? s) in _list(
        row,
        AllocationReadModelColumns.sections,
      ).indexed)
        _section(s, '${AllocationReadModelColumns.sections}[$i]'),
    ],
    changePathLines: <String>[
      for (final (int i, Object? l) in _list(
        row,
        AllocationReadModelColumns.changePathLines,
      ).indexed)
        _string(l, '${AllocationReadModelColumns.changePathLines}[$i]'),
    ],
    asOf: _asOf(row),
  );
}

Object _need(Map<String, Object?> row, String column) {
  final Object? v = row[column];
  if (v == null) {
    throw FormatException('배분 열: $column 없음');
  }
  return v;
}

String _string(Object? v, String where) {
  if (v is! String) {
    throw FormatException('배분 열: $where 글자 아님');
  }
  return v;
}

String _text(Map<String, Object?> row, String column) =>
    _string(_need(row, column), column);

List<Object?> _list(Map<String, Object?> row, String column) {
  final Object v = _need(row, column);
  if (v is! List<Object?>) {
    throw FormatException('배분 열: $column 목록 아님');
  }
  return v;
}

Map<String, Object?> _map(Object? v, String where) {
  if (v is! Map<String, Object?>) {
    throw FormatException('배분 열: $where 객체 아님');
  }
  return v;
}

AllocationReadOnlySection _section(Object? s, String where) {
  final Map<String, Object?> m = _map(s, where);
  final Object? rows = m['rows'];
  if (rows is! List<Object?>) {
    throw FormatException('배분 열: $where.rows 목록 아님');
  }
  return AllocationReadOnlySection(
    title: _string(m['title'], '$where.title'),
    rows: <AllocationReadOnlyRow>[
      for (final (int i, Object? r) in rows.indexed) _row(r, '$where.rows[$i]'),
    ],
  );
}

AllocationReadOnlyRow _row(Object? r, String where) {
  final Map<String, Object?> m = _map(r, where);
  final Object? note = m['note_text'];
  if (note != null && note is! String) {
    throw FormatException('배분 열: $where.note_text 글자 아님');
  }
  return AllocationReadOnlyRow(
    code: _string(m['code'], '$where.code'),
    label: _string(m['label'], '$where.label'),
    valueText: _string(m['value_text'], '$where.value_text'),
    noteText: note as String?,
  );
}

AsOf _asOf(Map<String, Object?> row) {
  final Map<String, Object?> m = _map(
    _need(row, AllocationReadModelColumns.asOf),
    AllocationReadModelColumns.asOf,
  );
  try {
    return AsOf.fromJson(m);
  } on FormatException {
    rethrow;
  } on Object catch (e) {
    // 🔴 계약 `AsOf.fromJson` 은 꼴이 틀리면 형 오류를 낸다 — 이 함수의 약속(FormatException 하나)으로 바꿔 낸다.
    throw FormatException('배분 열: ${AllocationReadModelColumns.asOf} 꼴 아님($e)');
  }
}
