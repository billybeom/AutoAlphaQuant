// E13c1 — 정본 자가 무결성 검사 · `LEDGER_FIX` 뮤텍스(설계 13 §8 R58 C2~C6).
//
// 🔵 잡는 것: ① 스탬프 0 · 일치 = 기록 1행(INTEGRITY_OK) · 플래그 0 ② 뒤늦은 정상 갱신(상태 전이 칸) · 스탬프 뒤 행 = 통과
//    ③ 손으로 고친 지난날 행 · 첫 날 앞 삽입 · 스탬프 날 지움 · 체인 칸 · 형식 판 · 귀속 실패 · PRAGMA 실패 = 불일치 → 같은
//    트랜잭션에서 LEDGER_INTEGRITY · 원장 판정이 본다 ④ 🔴 일치해도 안 풂 · 이미 서 있으면 그대로 · 풀린 뒤 다시 세움
//    ⑤ 한 트랜잭션(플래그 쓰기 실패 = 기록도 없음) ⑥ LEDGER_FIX = 한 트랜잭션 안에서만 · 실패 = 사라짐 · 중첩 · 남은 행 거부 ·
//    다른 연결은 못 본다 · 판정 SQL 밖 ⑦ 일일 아카이브 잡 = 스탬프 뒤 검사 · 불일치면 아카이브 건너뜀.
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

// 2026-11-04T15:00Z = 한국 11-05 00:00 — 골든 날 11-02 ~ 11-04 가 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 15);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_li_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void armed() {
    loadLedgerGolden(db);
    LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
  }

  LedgerIntegrityReport run({List<String> Function(Database)? pragma}) =>
      LedgerIntegrityCheck(db, clock: clock, sqliteIntegrity: pragma).run();

  List<Row> logs() =>
      db.select('SELECT * FROM reconciliation_log ORDER BY recon_id').toList();

  Row? integrityFlag() {
    final ResultSet rs = db.select(
      "SELECT * FROM trading_block WHERE flag_id = 'LEDGER_INTEGRITY'",
    );
    return rs.isEmpty ? null : rs.single;
  }

  (String?, String?, int, String?, bool) shape(LedgerIntegrityReport r) => (
    r.verdict.reason?.code,
    r.verdict.firstBadDate,
    r.verdict.daysChecked,
    r.verdict.checkedThrough,
    r.flagRaised,
  );

  group('LedgerIntegrityCheck(R58 C2~C5)', () {
    test('스탬프 0 = 통과 · 기록 1행', () {
      final LedgerIntegrityReport r = run();
      expect(shape(r), (null, null, 0, null, false));
      expect(r.alerts, isEmpty);
      final Row l = logs().single;
      expect(
        (l['recon_id'], l['matched'], l['action_taken']),
        ('li-${_t0.toIso8601String()}#1', 1, 'INTEGRITY_OK'),
      );
      expect(integrityFlag(), isNull);
    });

    test('일치 = 스탬프한 날 전부 · 기록(날 · 사유 · 날 수) · 플래그 0', () {
      armed();
      final LedgerIntegrityReport r = run();
      expect(shape(r), (null, null, 3, '2026-11-04', false));
      final Row l = logs().single;
      expect(l['recon_id'], r.reconId);
      expect(jsonDecode(l['discrepancies'] as String), <String, Object?>{
        'kind': 'LEDGER_INTEGRITY',
        'ok': true,
        'reason': null,
        'first_bad_date': null,
        'days_checked': 3,
        'checked_through': '2026-11-04',
      });
      expect(integrityFlag(), isNull);
      // 같은 시각 두 번째 = 일련 2.
      expect(run().reconId, 'li-${_t0.toIso8601String()}#2');
    });

    test('🔴 뒤늦은 정상 갱신(상태 전이 칸) · 스탬프 뒤에 생긴 행 = 통과', () {
      armed();
      db.execute(
        "UPDATE order_intents SET status = 'FILLED', error_message = 'x', updated_at = '2026-11-05T01:00:00.000Z'",
      );
      final Row d = db.select('SELECT * FROM decision_log LIMIT 1').single;
      insertLedgerRow(db, 'decision_log', <String, Object?>{
        ...<String, Object?>{for (final String k in d.keys) k: d[k]},
        'decision_id': 'D-LATER',
        'created_at': '2026-11-05T00:30:00.000Z', // 한국 11-05 = 아직 스탬프 전
      });
      expect(run().verdict.ok, isTrue);
    });

    test(
      '🔴 손으로 고친 지난날 행 = 불일치 → 같은 트랜잭션에서 LEDGER_INTEGRITY · 원장 판정이 본다',
      () async {
        armed();
        db.execute(
          "UPDATE decision_log SET reason = reason || '.' WHERE decision_id = 'D-1'",
        );
        final LedgerIntegrityReport r = run();
        expect(shape(r), ('DAY_HASH_MISMATCH', '2026-11-02', 0, null, true));
        expect(r.alerts, <String>{'LEDGER_INTEGRITY_BROKEN'});
        final Row l = logs().single;
        expect((l['matched'], l['action_taken']), (0, 'INTEGRITY_FAILED'));
        final Row f = integrityFlag()!;
        expect(
          (f['set_at'], f['reason'], f['cleared_at']),
          (
            _t0.toIso8601String(),
            '정본 자가 대조 불일치 — 2026-11-02 DAY_HASH_MISMATCH (${r.reconId})',
            null,
          ),
        );
        final SqliteOrderLedger ledger = SqliteOrderLedger(
          db,
          mode: RunMode.live,
          clock: clock,
          kr: frozenExchangeCalendar(Market.kr),
        );
        expect(await ledger.activeBlockFlags(), contains('LEDGER_INTEGRITY'));
      },
    );

    test('🔴 첫 스탬프 앞 날에 행을 넣음 = 소급 삽입', () {
      armed();
      final Row d = db.select('SELECT * FROM decision_log LIMIT 1').single;
      insertLedgerRow(db, 'decision_log', <String, Object?>{
        ...<String, Object?>{for (final String k in d.keys) k: d[k]},
        'decision_id': 'D-OLD',
        'created_at': '2026-10-31T03:00:00.000Z',
      });
      expect(shape(run()), (
        'ROWS_BEFORE_FIRST_STAMP',
        '2026-10-31',
        0,
        null,
        true,
      ));
    });

    test('🔴 스탬프 날 지움 · 체인 칸 고침 · 형식 판 다름', () {
      armed();
      final String chain4 =
          db
                  .select(
                    "SELECT chain_hash FROM ledger_daily_hash WHERE authored_date = '2026-11-04'",
                  )
                  .single['chain_hash']
              as String;
      db.execute(
        "UPDATE ledger_daily_hash SET chain_hash = ? WHERE authored_date = '2026-11-03'",
        <Object?>[chain4],
      );
      expect(shape(run()).$1, 'CHAIN_BROKEN');
      db.execute(
        "DELETE FROM ledger_daily_hash WHERE authored_date = '2026-11-03'",
      );
      expect(shape(run()).$1, 'DATE_GAP');
      db.execute(
        "UPDATE ledger_daily_hash SET hash_format_version = 99 WHERE authored_date = '2026-11-02'",
      );
      expect(shape(run()).$1, 'FORMAT_VERSION');
    });

    test('🔴 귀속 실패(시차 없는 기록 시각) = 불일치(fail-closed)', () {
      armed();
      final Row d = db.select('SELECT * FROM decision_log LIMIT 1').single;
      insertLedgerRow(db, 'decision_log', <String, Object?>{
        ...<String, Object?>{for (final String k in d.keys) k: d[k]},
        'decision_id': 'D-BAD',
        'created_at': '2026-11-03T10:00:00',
      });
      expect(shape(run()), ('ATTRIBUTION', null, 0, null, true));
    });

    test('스탬프 0 이면 귀속을 셀 것도 없다 — 깨진 기록 시각 행이 있어도 통과(스탬퍼가 먼저 실패한다)', () {
      loadLedgerGolden(db);
      final Row d = db.select('SELECT * FROM decision_log LIMIT 1').single;
      insertLedgerRow(db, 'decision_log', <String, Object?>{
        ...<String, Object?>{for (final String k in d.keys) k: d[k]},
        'decision_id': 'D-BAD',
        'created_at': '2026-11-03T10:00:00',
      });
      expect(shape(run()), (null, null, 0, null, false));
      expect(integrityFlag(), isNull);
    });

    test('🔴 PRAGMA integrity_check ≠ ok = 불일치 · 실제 PRAGMA = ok', () {
      expect(sqliteIntegrityLines(db), <String>['ok']);
      armed();
      expect(
        shape(
          run(
            pragma: (_) => <String>[
              '*** in database main ***',
              'row 3 missing',
            ],
          ),
        ).$1,
        'SQLITE_INTEGRITY',
      );
      db.execute(
        "DELETE FROM trading_block WHERE flag_id = 'LEDGER_INTEGRITY'",
      );
      expect(
        shape(run(pragma: (_) => <String>['ok', 'x'])).$1,
        'SQLITE_INTEGRITY',
      );
      db.execute(
        "DELETE FROM trading_block WHERE flag_id = 'LEDGER_INTEGRITY'",
      );
      expect(shape(run(pragma: (_) => <String>[])).$1, 'SQLITE_INTEGRITY');
    });

    test('🔴 일치해도 풀지 않는다 · 이미 서 있으면 그대로 · 풀린 뒤 다시 어긋나면 다시 세운다', () {
      armed();
      db.execute(
        "UPDATE decision_log SET reason = reason || '.' WHERE decision_id = 'D-1'",
      );
      final LedgerIntegrityReport first = run();
      final Row f1 = integrityFlag()!;
      clock.at = _t0.add(const Duration(hours: 1));
      expect(run().flagRaised, isFalse);
      expect(integrityFlag()!.values, f1.values);
      db.execute(
        "UPDATE decision_log SET reason = substr(reason, 1, length(reason) - 1) WHERE decision_id = 'D-1'",
      );
      expect(run().verdict.ok, isTrue);
      expect(integrityFlag()!['cleared_at'], isNull);
      // 해제(E16 몫)를 흉내 낸 뒤 다시 어긋남.
      db.execute(
        "UPDATE trading_block SET cleared_at = '2026-11-05T00:00:00Z', cleared_by = 'x', decision_id = 'J' WHERE flag_id = 'LEDGER_INTEGRITY'",
      );
      db.execute(
        "UPDATE decision_log SET reason = reason || '!' WHERE decision_id = 'D-1'",
      );
      clock.at = _t0.add(const Duration(hours: 2));
      final LedgerIntegrityReport again = run();
      expect(again.flagRaised, isTrue);
      final Row f2 = integrityFlag()!;
      expect(
        (f2['set_at'], f2['cleared_at'], f2['cleared_by'], f2['decision_id']),
        (clock.at.toIso8601String(), null, null, null),
      );
      expect(first.reconId, isNot(again.reconId));
    });

    test('🔴 한 트랜잭션 — 플래그 쓰기가 실패하면 기록도 남지 않는다', () {
      armed();
      db.execute(
        "UPDATE decision_log SET reason = reason || '.' WHERE decision_id = 'D-1'",
      );
      db.execute(
        "CREATE TRIGGER no_flag BEFORE INSERT ON trading_block BEGIN SELECT RAISE(ABORT, 'x'); END",
      );
      expect(run, throwsA(isA<SqliteException>()));
      expect(logs(), isEmpty);
      expect(db.autocommit, isTrue);
    });
  });

  group('withLedgerFix(R58 C6)', () {
    test('한 트랜잭션 안에서만 보인다 · 끝나면 사라진다 · 판정 SQL 밖', () async {
      final SqliteOrderLedger ledger = SqliteOrderLedger(
        db,
        mode: RunMode.live,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
      );
      final Database other = openLocalLedger(
        dir.path,
        RunMode.live,
        clock: () => _t0,
      );
      try {
        late Future<Set<String>> inside;
        final int out = withLedgerFix(
          db,
          reason: 'X5-3 정정',
          atUtc: _t0,
          body: () {
            expect(ledgerFixVisible(db), isTrue);
            expect(ledgerFixVisible(other), isFalse);
            // 판정 SQL 은 부르는 순간 돈다(이 트랜잭션 안의 시야).
            inside = ledger.activeBlockFlags();
            db.execute(
              "INSERT INTO reconciliation_log (recon_id, run_at, matched) VALUES ('fix-1', 't', 1)",
            );
            return 7;
          },
        );
        expect(out, 7);
        expect(await inside, isEmpty);
        expect(ledgerFixVisible(db), isFalse);
        expect(ledgerFixVisible(other), isFalse);
        expect(
          other.select(
            "SELECT 1 FROM reconciliation_log WHERE recon_id = 'fix-1'",
          ),
          hasLength(1),
        );
      } finally {
        other.close();
      }
    });

    test('본문 실패 = 본문 쓰기 · 플래그 함께 되돌림 · 예외 그대로', () {
      expect(
        () => withLedgerFix<void>(
          db,
          reason: 'r',
          atUtc: _t0,
          body: () {
            db.execute(
              "INSERT INTO reconciliation_log (recon_id, run_at, matched) VALUES ('fix-2', 't', 1)",
            );
            throw StateError('boom');
          },
        ),
        throwsStateError,
      );
      expect(ledgerFixVisible(db), isFalse);
      expect(db.select('SELECT * FROM reconciliation_log'), isEmpty);
      expect(db.autocommit, isTrue);
    });

    test('🔴 중첩 · 열린 트랜잭션 · 남은 행 = 거부(본문 안 돎)', () {
      expect(
        () => withLedgerFix<void>(
          db,
          reason: 'outer',
          atUtc: _t0,
          body: () =>
              withLedgerFix<void>(db, reason: 'inner', atUtc: _t0, body: () {}),
        ),
        throwsA(isA<LedgerFixBusy>()),
      );
      expect(ledgerFixVisible(db), isFalse);
      db.execute('BEGIN');
      expect(
        () => withLedgerFix<void>(db, reason: 'r', atUtc: _t0, body: () {}),
        throwsA(isA<LedgerFixBusy>()),
      );
      db.execute('ROLLBACK');
      db.execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_FIX', 't', 'stale')",
      );
      bool ran = false;
      expect(
        () => withLedgerFix<void>(
          db,
          reason: 'r',
          atUtc: _t0,
          body: () => ran = true,
        ),
        throwsA(
          isA<LedgerFixBusy>().having(
            (LedgerFixBusy e) => e.reason,
            'reason',
            contains('남아'),
          ),
        ),
      );
      expect(ran, isFalse);
      expect(
        db
            .select(
              "SELECT reason FROM trading_block WHERE flag_id = 'LEDGER_FIX'",
            )
            .single['reason'],
        'stale',
      );
      expect(db.autocommit, isTrue);
    });
  });
}
