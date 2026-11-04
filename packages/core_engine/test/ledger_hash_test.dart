// E11h1 — X5-1 정규 직렬화 · day_hash · 체인(설계 13 §8 R51 H1~H9).
//
// 🔵 골든 = `tool/make_ledger_hash_golden.py`(Python 독립 구현)가 만든 `golden/vectors/ledger_hash_v1.json` — Dart 가 비트 일치로 재현한다.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

List<Map<String, dynamic>> _maps(Object? v) =>
    (v! as List<dynamic>).cast<Map<String, dynamic>>();

Object? _decode(Object? v) {
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

LedgerHashTable _table(String name) =>
    kLedgerHashPopulationV1.firstWhere((LedgerHashTable t) => t.table == name);

void main() {
  final Map<String, dynamic> golden = jsonDecode(
    File('test/golden/vectors/ledger_hash_v1.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  group('골든(Python 독립 구현)', () {
    test('모집단 순서 · 시작값 · 형식 판', () {
      expect(<String>[
        for (final LedgerHashTable t in kLedgerHashPopulationV1) t.table,
      ], (golden['population'] as List<dynamic>).cast<String>());
      expect(kChainGenesis, golden['genesis']);
      expect(golden['hash_format_version'], 1);
    });

    test('실수 정규 표기', () {
      for (final Map<String, dynamic> d in _maps(golden['doubles'])) {
        expect(
          canonicalDouble(double.parse(d['value'] as String)),
          d['canonical'],
          reason: d['value'] as String,
        );
      }
    });

    test('문자열 정규 표기', () {
      for (final Map<String, dynamic> s in _maps(golden['strings'])) {
        expect(canonicalString(s['value'] as String), s['canonical']);
      }
    });

    test('귀속 날(한국 날짜)', () {
      for (final Map<String, dynamic> a in _maps(golden['axes'])) {
        expect(
          authoredKstDate(a['value'], where: 't'),
          a['kst_date'],
          reason: a['value'] as String,
        );
      }
    });

    test('빈 날 = 빈 입력의 해시', () {
      expect(
        dayHashOf(const <String, List<String>>{}),
        golden['empty_day_hash'],
      );
      expect(dayHashInput(const <String, List<String>>{}), '');
    });

    test('날마다 정규 줄 · day_hash · row_counts · 체인 · 축약', () {
      String prev = kChainGenesis;
      for (final Map<String, dynamic> day in _maps(golden['days'])) {
        final Map<String, List<String>> lines = <String, List<String>>{};
        (day['rows'] as Map<String, dynamic>).forEach((String t, dynamic rows) {
          final LedgerHashTable spec = _table(t);
          for (final Map<String, dynamic> r in _maps(rows)) {
            final Map<String, Object?> row = <String, Object?>{
              for (final MapEntry<String, dynamic> e in r.entries)
                e.key: _decode(e.value),
            };
            // 골든 행 = 고정 투영 칸 전부.
            expect(row.keys.toSet(), spec.columns.toSet(), reason: t);
            (lines[t] ??= <String>[]).add(canonicalRow(row, spec.columns));
          }
        });
        final Map<String, dynamic> want = day['lines'] as Map<String, dynamic>;
        expect(lines.keys.toSet(), want.keys.toSet());
        for (final String t in lines.keys) {
          expect(
            sortCanonicalLines(lines[t]!),
            (want[t] as List<dynamic>).cast<String>(),
            reason: '${day['date']} $t',
          );
        }
        final String dh = dayHashOf(lines);
        expect(dh, day['day_hash'], reason: day['date'] as String);
        expect(rowCountsJson(lines), day['row_counts']);
        prev = chainHashOf(prev, dh);
        expect(prev, day['chain_hash']);
      }
      final Map<String, dynamic> stamp =
          golden['stamp'] as Map<String, dynamic>;
      expect(prev, stamp['chain']);
      expect(chainStampText(prev), stamp['display']);
      expect(chainCarryText(prev), stamp['carry']);
    });
  });

  group('정규 표기 경계', () {
    test('실수 — 무한 · NaN = 실패 · −0 = 0.0', () {
      for (final double v in <double>[
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(() => canonicalDouble(v), throwsA(isA<LedgerHashError>()));
      }
      expect(canonicalDouble(-0.0), '0.0');
      expect(canonicalDouble(-1e21), '-1000000000000000000000.0');
      expect(canonicalDouble(-1.5e-7), '-0.00000015');
      expect(canonicalDouble(25e-1), '2.5');
    });

    test('값 — 정수 · 실수 · 문자열 · null 만', () {
      expect(canonicalValue(null), 'null');
      expect(canonicalValue(-3), '-3');
      expect(canonicalValue(3.0), '3.0');
      expect(canonicalValue('a'), '"a"');
      for (final Object v in <Object>[
        true,
        <int>[1],
        DateTime(2026),
      ]) {
        expect(() => canonicalValue(v), throwsA(isA<LedgerHashError>()));
      }
    });

    test('행 — 이름 순 · 목록 밖 칸은 안 본다 · 목록 칸이 없으면 실패', () {
      expect(
        canonicalRow(
          <String, Object?>{'b': 1, 'a': null, 'z': 'x'},
          <String>['b', 'a'],
        ),
        '{"a":null,"b":1}',
      );
      expect(
        () => canonicalRow(<String, Object?>{'a': 1}, <String>['a', 'b']),
        throwsA(
          isA<LedgerHashError>().having(
            (LedgerHashError e) => e.reason,
            'reason',
            '칸 없음: b',
          ),
        ),
      );
    });

    test('줄 정렬 = UTF-8 바이트 순(UTF-16 순과 다른 자리)', () {
      // U+FFFF = EF BF BF · U+1F534 = F0 9F 94 B4 — UTF-16 으로는 🔴(D83D) 가 앞이다.
      const String ffff = '\u{FFFF}';
      expect(sortCanonicalLines(<String>['🔴', ffff, 'ab', 'a']), <String>[
        'a',
        'ab', // 앞부분이 같으면 짧은 쪽이 앞
        ffff,
        '🔴',
      ]);
    });

    test('day_hash 입력 — 모집단 순서 · 표 이름 · 탭 · 줄바꿈 · 모집단 밖 표 = 실패', () {
      expect(
        dayHashInput(<String, List<String>>{
          'ledger_event': <String>['{"x":1}'],
          'executions': <String>['{"b":1}', '{"a":1}'],
        }),
        'executions\t{"a":1}\nexecutions\t{"b":1}\nledger_event\t{"x":1}\n',
      );
      expect(
        () => dayHashInput(<String, List<String>>{
          'equity_snapshot': <String>['{}'],
        }),
        throwsA(isA<LedgerHashError>()),
      );
    });

    test('체인 — 소문자 16진 64자만', () {
      final String day = dayHashOf(const <String, List<String>>{});
      expect(chainHashOf(kChainGenesis, day), hasLength(64));
      for (final (String a, String b) in <(String, String)>[
        ('0' * 63, day),
        (kChainGenesis, day.toUpperCase()),
        (kChainGenesis, '${day.substring(1)}g'),
      ]) {
        expect(() => chainHashOf(a, b), throwsArgumentError);
      }
      expect(() => chainStampText('abc'), throwsArgumentError);
      expect(() => chainCarryText('abc'), throwsArgumentError);
    });

    test('row_counts = 전 모집단 표 · 0 포함', () {
      final String j = rowCountsJson(<String, List<String>>{
        'cash_flow': <String>['{}', '{}'],
      });
      final Map<String, dynamic> m = jsonDecode(j) as Map<String, dynamic>;
      expect(m, hasLength(16));
      expect(m['cash_flow'], 2);
      expect(m['executions'], 0);
    });

    test('귀속 날 — NULL · 시간대 없음 · 날짜만 · 7자리 소수 · 쓰레기 = 실패', () {
      expect(
        () => authoredKstDate(null, where: 'cash_flow F-1'),
        throwsA(
          isA<LedgerHashError>().having(
            (LedgerHashError e) => e.reason,
            'reason',
            'cash_flow F-1: 기록 시각 없음',
          ),
        ),
      );
      for (final Object v in <Object>[
        '2026-11-02T10:00:00',
        '2026-11-02',
        '2026-11-02T10:00:00.1234567Z',
        't',
        '2026-11-02 10:00:00Z',
        '2026-11-02T10:00:00+0900',
        3,
      ]) {
        expect(
          () => authoredKstDate(v, where: 'x'),
          throwsA(isA<LedgerHashError>()),
          reason: '$v',
        );
      }
    });
  });

  group('모집단 v1(R51 H1 · H2)', () {
    test('16표 · 축 · 제외 칸 · 부모 축', () {
      expect(kLedgerHashPopulationV1, hasLength(16));
      final Map<String, (String, List<String>)> m =
          <String, (String, List<String>)>{
            for (final LedgerHashTable t in kLedgerHashPopulationV1)
              t.table: (t.axis, t.excluded),
          };
      expect(m['cash_flow']!.$1, 'recorded_at');
      expect(m['cash_flow']!.$2, isEmpty);
      expect(m['order_intents']!.$2, <String>[
        'status',
        'error_message',
        'updated_at',
      ]);
      expect(m['advice']!.$2, <String>[
        'status',
        'close_reason_code',
        'superseded_by',
      ]);
      expect(m['external_holding']!.$2, <String>['released_at']);
      expect(m['handover_session']!.$2, <String>['closed_at', 'close_code']);
      expect(m['operating_param_log']!.$2, <String>['superseded_by']);
      final LedgerHashTable line = _table('self_report_line');
      expect(
        (line.axis, line.parentTable, line.parentKey),
        ('reported_at', 'self_report_balance', 'report_id'),
      );
      for (final LedgerHashTable t in kLedgerHashPopulationV1) {
        expect(
          t.columns.toSet().intersection(t.excluded.toSet()),
          isEmpty,
          reason: t.table,
        );
        expect(t.columns.toSet(), hasLength(t.columns.length), reason: t.table);
        if (t.parentTable == null) {
          expect(t.columns, contains(t.axis), reason: t.table);
        }
      }
      // 🔴 판정 사전 필드는 해시 안(사후 수정 = 변조).
      expect(
        _table('decision_journal').columns,
        containsAll(<String>[
          'rationale_before',
          'expected_outcome',
          'rule_cited',
        ]),
      );
    });
  });
}
