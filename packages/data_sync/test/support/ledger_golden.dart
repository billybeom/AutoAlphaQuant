// X5-1 골든(`core_engine/test/golden/vectors/ledger_hash_v1.json` — Python 독립 구현)을 원장에 싣는 시험 도우미(E11h1 · E11h2).
import 'dart:convert';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// 골든 전체.
final Map<String, dynamic> ledgerGolden = jsonDecode(
  File('../core_engine/test/golden/vectors/ledger_hash_v1.json')
      .readAsStringSync(),
) as Map<String, dynamic>;

/// 목록 → 지도 목록.
List<Map<String, dynamic>> goldenMaps(Object? v) =>
    (v! as List<dynamic>).cast<Map<String, dynamic>>();

/// 골든의 날들.
List<Map<String, dynamic>> get goldenDays => goldenMaps(ledgerGolden['days']);

/// 값 표기 `{"i"|"d"|"s": …}` · null → Dart 값.
Object? goldenValue(Object? v) {
  if (v == null) return null;
  final MapEntry<String, dynamic> e =
      (v as Map<String, dynamic>).entries.single;
  return switch (e.key) {
    'i' => e.value as int,
    'd' => double.parse(e.value as String),
    's' => e.value as String,
    _ => throw StateError(e.key),
  };
}

/// 고정 투영 밖 칸(NOT NULL)을 채운다.
const Map<String, Map<String, Object?>> _extra = <String, Map<String, Object?>>{
  'order_intents': <String, Object?>{
    'status': 'SUBMITTED',
    'error_message': null,
    'updated_at': '2026-11-04T00:10:01.000Z',
  },
};

/// 한 행을 넣는다(투영 밖 NOT NULL 칸은 채운다).
void insertLedgerRow(Database db, String table, Map<String, Object?> row) {
  final Map<String, Object?> all = <String, Object?>{...row, ...?_extra[table]};
  db.execute(
    'INSERT INTO $table(${all.keys.join(', ')}) VALUES (${List<String>.filled(all.length, '?').join(', ')})',
    all.values.toList(),
  );
}

/// 골든 행 전부를 원장에(부모 먼저).
void loadLedgerGolden(Database db) {
  for (final Map<String, dynamic> day in goldenDays) {
    final Map<String, dynamic> rows = day['rows'] as Map<String, dynamic>;
    final List<String> order = <String>[
      for (final String t in rows.keys)
        if (t != 'self_report_line') t,
      if (rows.containsKey('self_report_line')) 'self_report_line',
    ];
    for (final String t in order) {
      for (final Map<String, dynamic> r in goldenMaps(rows[t])) {
        insertLedgerRow(db, t, <String, Object?>{
          for (final MapEntry<String, dynamic> e in r.entries)
            e.key: goldenValue(e.value),
        });
      }
    }
  }
}
