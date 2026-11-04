// E11h1 — `ledger_daily_hash` 스탬프(설계 13 §8 R51 H1 · H2 · H4~H7).
//
// 🔵 잡는 것: ① 스키마 칸 − 고정 투영 = 정확히 상태 전이 칸(live · sim) ② 원장 → 스탬프 = Python 골든 비트 일치
//    ③ 상태 전이 칸은 해시를 안 바꾸고 그 밖 칸은 바꾼다 ④ 달력일 연속 · 첫 날 = 최소 귀속 날 · 이어 쓰기 · 멱등
//    ⑤ 끝나지 않은 날 · 귀속 실패 · 형식 판 다름 = 실패 · 아무것도 안 씀 ⑥ 한 트랜잭션.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'support/ledger_golden.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

// 2026-11-04T15:00Z = 한국 11-05 00:00 — 11-04 까지 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 15);

final Map<String, dynamic> _golden = ledgerGolden;
List<Map<String, dynamic>> _maps(Object? v) => goldenMaps(v);
void _insert(Database db, String table, Map<String, Object?> row) =>
    insertLedgerRow(db, table, row);
void _loadGolden(Database db) => loadLedgerGolden(db);

int _count(Database db, String table) =>
    db.select('SELECT COUNT(*) AS n FROM $table').first['n'] as int;

void main() {
  group('스키마 대조(R51 H2)', () {
    for (final RunMode mode in <RunMode>[RunMode.live, RunMode.simInternal]) {
      test('${mode.name} — 스키마 칸 − 고정 투영 = 정확히 상태 전이 칸', () {
        final Directory dir = Directory.systemTemp.createTempSync('aaq_lh_s_');
        final Database db = openLocalLedger(dir.path, mode);
        try {
          for (final LedgerHashTable t in kLedgerHashPopulationV1) {
            final Set<String> schema = <String>{
              for (final Row r in db.select('PRAGMA table_info(${t.table})'))
                r['name'] as String,
            };
            expect(schema, isNotEmpty, reason: t.table);
            expect(schema.containsAll(t.columns), isTrue, reason: t.table);
            expect(
              schema.difference(t.columns.toSet()),
              t.excluded.toSet(),
              reason: t.table,
            );
            if (t.parentTable != null) {
              final Set<String> parent = <String>{
                for (final Row r in db.select(
                  'PRAGMA table_info(${t.parentTable})',
                ))
                  r['name'] as String,
              };
              expect(parent, containsAll(<String>[t.axis, t.parentKey!]));
            }
          }
        } finally {
          db.close();
          dir.deleteSync(recursive: true);
        }
      });
    }
  });

  late Directory dir;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_lh_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  LedgerHashStamper stamper() => LedgerHashStamper(db, clock: clock);

  group('LedgerHashStamper', () {
    test('🔵 원장 → 스탬프 = Python 골든 비트 일치(빈 날 포함 · 이 날 행 = 한국 날짜 귀속)', () {
      _loadGolden(db);
      final List<LedgerDayStamp> s = stamper().stampThrough('2026-11-04');
      final List<Map<String, dynamic>> days = _maps(_golden['days']);
      expect(
        <String>[for (final LedgerDayStamp d in s) d.authoredDate],
        <String>[
          for (final Map<String, dynamic> d in days) d['date'] as String,
        ],
      );
      for (int k = 0; k < days.length; k++) {
        expect(
          (s[k].dayHash, s[k].chainHash, s[k].rowCounts),
          (days[k]['day_hash'], days[k]['chain_hash'], days[k]['row_counts']),
          reason: days[k]['date'] as String,
        );
      }
      final List<Row> rows = db.select(
        'SELECT * FROM ledger_daily_hash ORDER BY authored_date',
      );
      expect(rows, hasLength(3));
      for (int k = 0; k < rows.length; k++) {
        expect(
          (
            rows[k]['authored_date'],
            rows[k]['day_hash'],
            rows[k]['chain_hash'],
            rows[k]['hash_format_version'],
            rows[k]['row_counts'],
            rows[k]['created_at'],
          ),
          (
            s[k].authoredDate,
            s[k].dayHash,
            s[k].chainHash,
            hashFormatVersion,
            s[k].rowCounts,
            _t0.toIso8601String(),
          ),
        );
      }
      expect(stamper().lastStamp(), (
        '2026-11-04',
        (_golden['stamp'] as Map<String, dynamic>)['chain'],
        1,
      ));
      expect(s.last.toString(), contains('chn_'));
    });

    test('정규 줄 = 골든 줄', () {
      _loadGolden(db);
      final Map<String, Map<String, List<String>>> by = ledgerLinesByDay(db);
      for (final Map<String, dynamic> day in _maps(_golden['days'])) {
        final Map<String, dynamic> want = day['lines'] as Map<String, dynamic>;
        final Map<String, List<String>> got =
            by[day['date']] ?? const <String, List<String>>{};
        expect(got.keys.toSet(), want.keys.toSet());
        for (final String t in want.keys) {
          expect(
            sortCanonicalLines(got[t]!),
            (want[t] as List<dynamic>).cast<String>(),
          );
        }
      }
    });

    test('🔴 상태 전이 칸은 해시를 안 바꾸고 · 그 밖 칸은 바꾼다', () {
      _loadGolden(db);
      String hashOf(String day) => dayHashOf(
        ledgerLinesByDay(db)[day] ?? const <String, List<String>>{},
      );
      final String before = hashOf('2026-11-04');
      db.execute(
        "UPDATE order_intents SET status = 'FILLED', error_message = 'x', updated_at = '2026-11-05T00:00:00.000Z'",
      );
      expect(hashOf('2026-11-04'), before);
      db.execute('UPDATE order_intents SET quantity = 3');
      expect(hashOf('2026-11-04'), isNot(before));

      final String d2 = hashOf('2026-11-02');
      db.execute(
        "UPDATE decision_log SET reason = reason || '.' WHERE decision_id = 'D-1'",
      );
      expect(hashOf('2026-11-02'), isNot(d2));
    });

    test('달력일 연속 · 이어 쓰기 = 앞 체인에서 · 멱등', () {
      _loadGolden(db);
      final List<LedgerDayStamp> first = stamper().stampThrough('2026-11-03');
      expect(first.map((LedgerDayStamp d) => d.authoredDate), <String>[
        '2026-11-02',
        '2026-11-03',
      ]);
      expect(stamper().stampThrough('2026-11-03'), isEmpty);
      expect(stamper().stampThrough('2026-11-01'), isEmpty);
      final List<LedgerDayStamp> next = stamper().stampThrough('2026-11-04');
      expect(next.single.chainHash, _maps(_golden['days'])[2]['chain_hash']);

      clock.at = DateTime.utc(2026, 11, 7, 15); // 한국 11-08
      final List<LedgerDayStamp> later = stamper().stampThrough('2026-11-07');
      expect(later.map((LedgerDayStamp d) => d.authoredDate), <String>[
        '2026-11-05',
        '2026-11-06',
        '2026-11-07',
      ]);
      final String empty = dayHashOf(const <String, List<String>>{});
      String prev = next.single.chainHash;
      for (final LedgerDayStamp d in later) {
        expect(d.dayHash, empty);
        expect(d.chainHash, chainHashOf(prev, empty));
        prev = d.chainHash;
      }
      expect(_count(db, 'ledger_daily_hash'), 6);
    });

    test('행이 하나도 없으면 아무것도 안 쓴다', () {
      expect(stamper().stampThrough('2026-11-04'), isEmpty);
      expect(stamper().lastStamp(), isNull);
    });

    test('첫 날 = 모집단 최소 귀속 날(그 앞 날은 쓰지 않는다)', () {
      _insert(db, 'cash_flow', <String, Object?>{
        'flow_id': 'F-9',
        'trade_date': '2026-11-03',
        'amount': 1.0,
        'currency': 'KRW',
        'kind': 'DEPOSIT',
        'recorded_at': '2026-11-03T01:00:00.000Z',
      });
      final List<LedgerDayStamp> s = stamper().stampThrough('2026-11-04');
      expect(s.map((LedgerDayStamp d) => d.authoredDate), <String>[
        '2026-11-03',
        '2026-11-04',
      ]);
      expect(jsonDecode(s.first.rowCounts), containsPair('cash_flow', 1));
      expect(s.first.chainHash, chainHashOf(kChainGenesis, s.first.dayHash));
    });

    test('🔴 끝나지 않은 날 · 형식 아닌 날짜 = 실패', () {
      _loadGolden(db);
      expect(
        () => stamper().stampThrough('2026-11-05'),
        throwsA(
          isA<LedgerHashError>().having(
            (LedgerHashError e) => e.reason,
            'reason',
            '2026-11-05: 아직 끝나지 않은 날',
          ),
        ),
      );
      expect(() => stamper().stampThrough('2026-11-4'), throwsArgumentError);
      expect(_count(db, 'ledger_daily_hash'), 0);
    });

    test('🔴 귀속 실패 = 아무것도 안 씀 — 기록 시각 NULL · 부모 없는 줄', () {
      _loadGolden(db);
      _insert(db, 'cash_flow', <String, Object?>{
        'flow_id': 'F-NULL',
        'trade_date': '2026-11-03',
        'amount': 1.0,
        'currency': 'KRW',
        'kind': 'DEPOSIT',
      });
      expect(
        () => stamper().stampThrough('2026-11-04'),
        throwsA(
          isA<LedgerHashError>().having(
            (LedgerHashError e) => e.reason,
            'reason',
            'cash_flow F-NULL: 기록 시각 없음',
          ),
        ),
      );
      db.execute("DELETE FROM cash_flow WHERE flow_id = 'F-NULL'");
      _insert(db, 'self_report_line', <String, Object?>{
        'report_id': 'R-ORPHAN',
        'symbol': '069500',
        'quantity': 1,
      });
      expect(
        () => stamper().stampThrough('2026-11-04'),
        throwsA(
          isA<LedgerHashError>().having(
            (LedgerHashError e) => e.reason,
            'reason',
            'self_report_line R-ORPHAN: 기록 시각 없음',
          ),
        ),
      );
      expect(_count(db, 'ledger_daily_hash'), 0);
    });

    test('🔴 마지막 스탬프의 형식 판이 다르면 이어 쓰지 않는다', () {
      _loadGolden(db);
      db.execute(
        "INSERT INTO ledger_daily_hash VALUES ('2026-11-02', ?, ?, 2, '{}', 't')",
        <Object?>[kChainGenesis, kChainGenesis],
      );
      expect(
        () => stamper().stampThrough('2026-11-04'),
        throwsA(
          isA<LedgerHashError>().having(
            (LedgerHashError e) => e.reason,
            'reason',
            '형식 판 다름: 마지막 2 · 지금 1',
          ),
        ),
      );
      expect(_count(db, 'ledger_daily_hash'), 1);
    });

    test('🔴 한 트랜잭션 — 중간 날 쓰기가 실패하면 앞 날도 되돌린다', () {
      _loadGolden(db);
      db.execute(
        'CREATE TEMP TRIGGER aaq_fail BEFORE INSERT ON ledger_daily_hash '
        "WHEN NEW.authored_date = '2026-11-04' BEGIN SELECT RAISE(ABORT, 'boom'); END",
      );
      expect(
        () => stamper().stampThrough('2026-11-04'),
        throwsA(isA<SqliteException>()),
      );
      expect(_count(db, 'ledger_daily_hash'), 0);
    });
  });
}
