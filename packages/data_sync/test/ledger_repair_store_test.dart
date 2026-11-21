// E16f1 — X5 새 기준점 트랜잭션 · 아무것도 안 하기 · 정정 이력 실물(설계 13 §8 R126 J3~J6).
//
// 🔵 잡는 것: ① 손으로 고친 지난날 → 새 기준점 = 그 날 이후 다시 스탬프 · 대조 통과 · 정정 행 + 상세 · 플래그 해제(해제자 · 결정 · 원인)
//    ② 거부(신뢰 시각 · 플래그 없음 · X1 경계 · 결정 · 원인 밖) = 쓰기 0 ③ LEDGER_FIX 는 끝나면 없다 · 다른 정정 중 = Busy
//    ④ 다시 쓴 스탬프로 대조가 다시 통과 · 다음 날 스탬프가 이어진다 ⑤ 아무것도 안 하기 = OPEN → ACCEPTED 그 행만
//    ⑥ watchRepairs = 실물 행 · 상세 없는 행 = 스트림 오류.
//    🆕 E16j-a(01 §8 미결 217 ⓐ · K254) — 커밋 = 개입 세션 5단계(결정 = 3단계 저널 · 차례 밖 = 거부 · 통과 = 5단계 행) ·
//       아무것도 안 하기 = 이 diff 의 마법사 세션 DO_NOTHING + ACCEPTED 한 트랜잭션.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'support/intervention_seed.dart';
import 'support/ledger_golden.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

// 2026-11-04T15:00Z = 한국 11-05 00:00 — 골든 날 11-02 ~ 11-04 가 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 15);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;
  late SqliteLedgerRepairStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_rp_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0.add(const Duration(hours: 1)));
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteLedgerRepairStore(db, trusted: trusted);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  /// 골든 · 스탬프 → 지난날(11-02) 손으로 고침 → 무결성 검사 = LEDGER_INTEGRITY.
  void broken() {
    loadLedgerGolden(db);
    LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
    db.execute(
      "UPDATE decision_log SET reason = reason || '.' WHERE decision_id = 'D-1'",
    );
    final LedgerIntegrityReport r = LedgerIntegrityCheck(
      db,
      clock: clock,
    ).run();
    expect((r.verdict.reason?.code, r.flagRaised), ('DAY_HASH_MISMATCH', true));
  }

  Map<String, String> chains() => <String, String>{
    for (final Row r in db.select(
      'SELECT authored_date, chain_hash FROM ledger_daily_hash ORDER BY authored_date',
    ))
      r['authored_date'] as String: r['chain_hash'] as String,
  };

  Row flag() => db
      .select("SELECT * FROM trading_block WHERE flag_id = 'LEDGER_INTEGRITY'")
      .single;

  int count(String table) =>
      db.select('SELECT count(*) AS n FROM $table').first['n'] as int;

  int sessions = 0;

  /// 새 기준점 — [session] null = 실행 창 안 새 세션을 심고(결정 = [decision]) 그 세션으로 커밋한다.
  BaselineResult apply({
    String decision = 'dec-x5',
    String? session,
    String origin = 'CHAIN_BROKEN',
    DerivedRelation? archive,
  }) {
    final String sid = session ?? 'x5:li-test:${++sessions}';
    if (session == null) {
      seedExecutableSession(
        db,
        sid,
        nowUtc: trusted.at ?? _t0,
        journalId: decision,
      );
    }
    return store.applyBaseline(
      repairId: 'rp-1',
      sessionId: sid,
      originCode: origin,
      clearedBy: 'operator',
      archiveRelation: archive,
    );
  }

  test('🔴 새 기준점 — 그 날 이후 다시 스탬프 · 대조 통과 · 정정 행 + 상세 · 플래그 해제', () {
    broken();
    final Map<String, String> before = chains();
    final BaselineResult r = apply();
    expect(r.applied, isTrue);
    expect(r.rejectCode, isNull);
    final Map<String, String> after = chains();
    expect(after.keys, before.keys, reason: '같은 날들 · 날 연속');
    expect(after['2026-11-02'], isNot(before['2026-11-02']));
    expect(
      LedgerIntegrityCheck(db, clock: clock).run().verdict.ok,
      isTrue,
      reason: '다시 쓴 스탬프로 대조가 통과',
    );
    final Row rp = db.select('SELECT * FROM ledger_repair').single;
    expect(
      (rp['direction'], rp['origin_code'], rp['decision_id'], rp['supersedes']),
      ('CANON_CORRECT', 'CHAIN_BROKEN', 'dec-x5', null),
    );
    expect(rp['diff_id'], integrityDiffIdOf('2026-11-02', 'DAY_HASH_MISMATCH'));
    final Row d = db.select('SELECT * FROM ledger_repair_detail').single;
    expect(
      (d['recomputed_from'], d['chain_hash'], d['target_json']),
      ('2026-11-02', after['2026-11-04'], '{"kind":"LEDGER_INTEGRITY"}'),
    );
    final List<Object?> ev =
        jsonDecode(d['evidence_json'] as String) as List<Object?>;
    expect(
      ev.map((Object? e) => (e! as Map<String, Object?>)['chain_hash']),
      <String?>[
        before['2026-11-02'],
        before['2026-11-03'],
        before['2026-11-04'],
      ],
    );
    expect(rp['evidence_hash'], evidenceHashOf(d['evidence_json'] as String));
    final Row f = flag();
    expect(
      (f['cleared_by'], f['decision_id'], f['origin_code']),
      ('operator', 'dec-x5', 'CHAIN_BROKEN'),
    );
    expect(f['cleared_at'], isNotNull);
    expect(ledgerFixVisible(db), isFalse);
    // 🆕 E16j-a — 5단계 통과(결정 = 세션 저널) 가 같은 커밋에 남는다.
    final Row s5 = db
        .select(
          "SELECT * FROM intervention_step WHERE session_id = 'x5:li-test:1' AND stage = 5",
        )
        .single;
    expect((s5['outcome'], s5['decision_id']), ('PASSED', 'dec-x5'));
  });

  test('🔴 첫 어긋난 날이 뒤쪽(11-04) — 앞 스탬프는 그대로 · 그 날만 앞 체인에서 이어 다시', () {
    loadLedgerGolden(db);
    LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
    db.execute(
      "UPDATE executions SET price = price + 1 WHERE execution_id = 'E-3'",
    );
    final LedgerIntegrityReport li = LedgerIntegrityCheck(
      db,
      clock: clock,
    ).run();
    expect(li.verdict.firstBadDate, '2026-11-04');
    final Map<String, String> before = chains();
    expect(apply().applied, isTrue);
    final Map<String, String> after = chains();
    expect(
      (after['2026-11-02'], after['2026-11-03']),
      (before['2026-11-02'], before['2026-11-03']),
    );
    expect(after['2026-11-04'], isNot(before['2026-11-04']));
    expect(LedgerIntegrityCheck(db, clock: clock).run().verdict.ok, isTrue);
    expect(
      db
          .select('SELECT recomputed_from FROM ledger_repair_detail')
          .single['recomputed_from'],
      '2026-11-04',
    );
  });

  test('다시 쓴 뒤 다음 날 스탬프가 이어진다', () {
    broken();
    apply();
    clock.at = DateTime.utc(2026, 11, 5, 15);
    final List<LedgerDayStamp> next = LedgerHashStamper(
      db,
      clock: clock,
    ).stampThrough('2026-11-05');
    expect(next.single.authoredDate, '2026-11-05');
    expect(LedgerIntegrityCheck(db, clock: clock).run().verdict.ok, isTrue);
  });

  group('🔴 거부 = 쓰기 0', () {
    void nothingWritten(Map<String, String> before) {
      expect(count('ledger_repair'), 0);
      expect(count('ledger_repair_detail'), 0);
      expect(chains(), before);
      expect(flag()['cleared_at'], isNull);
      expect(ledgerFixVisible(db), isFalse);
    }

    test('신뢰 시각 모름', () {
      broken();
      final Map<String, String> before = chains();
      trusted.at = null;
      expect(apply().rejectCode, BaselineStoreCodes.trustedTimeUnknown);
      nothingWritten(before);
    });

    test('X1 경계(아카이브 앞섬) · 결정 없음 · 원인 밖', () {
      broken();
      final Map<String, String> before = chains();
      expect(
        apply(archive: DerivedRelation.ahead).rejectCode,
        BaselineCodes.notX5,
      );
      expect(
        apply(session: 'x5:li-test:none').rejectCode,
        InterventionCodes.outOfOrder,
        reason: '🆕 E16j-a 세션 없음 = 차례 밖(결정 = 세션 저널)',
      );
      expect(
        apply(origin: 'SCHEMA_SKEW').rejectCode,
        RepairCodes.originNotAllowed,
      );
      nothingWritten(before);
    });

    test('LEDGER_INTEGRITY 가 서 있지 않음', () {
      loadLedgerGolden(db);
      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
      expect(apply().rejectCode, BaselineStoreCodes.flagNotSet);
      expect(count('ledger_repair'), 0);
    });

    test('다른 정정 중(남은 LEDGER_FIX 행) = LedgerFixBusy · 쓰기 0', () {
      broken();
      final Map<String, String> before = chains();
      db.execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_FIX', 't', 'x')",
      );
      expect(apply, throwsA(isA<LedgerFixBusy>()));
      db.execute("DELETE FROM trading_block WHERE flag_id = 'LEDGER_FIX'");
      nothingWritten(before);
    });
  });

  group('아무것도 안 하기', () {
    void diff(String id, String status) => db.execute(
      'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, severity, origin_code, '
      "status, detected_at, applicable) VALUES (?, 'CANON_BROKER', 'QUANTITY', '2026-11-04', '{}', '', 'BLOCKING', NULL, ?, 't', 1)",
      <Object?>[id, status],
    );

    test('🔴 OPEN → ACCEPTED 그 행만 · 다시 = false · OPEN 아님 = false', () {
      diff('ld-a', 'OPEN');
      diff('ld-b', 'OPEN');
      diff('ld-c', 'RESOLVED');
      expect(store.acceptDiff('ld-a'), isTrue);
      expect(store.acceptDiff('ld-a'), isFalse);
      expect(store.acceptDiff('ld-c'), isFalse);
      expect(store.acceptDiff('ld-none'), isFalse);
      expect(
        db
            .select('SELECT diff_id, status FROM ledger_diff ORDER BY diff_id')
            .map((Row r) => (r['diff_id'], r['status'])),
        <(Object?, Object?)>[
          ('ld-a', 'ACCEPTED'),
          ('ld-b', 'OPEN'),
          ('ld-c', 'RESOLVED'),
        ],
      );
    });

    // 🆕 E16j-a(계약 v1.32 K254) — 마법사 세션 DO_NOTHING + ACCEPTED 한 트랜잭션.
    List<(Object?, Object?, Object?)> steps() => <(Object?, Object?, Object?)>[
      for (final Row r in db.select(
        'SELECT session_id, stage, outcome FROM intervention_step ORDER BY session_id, stage',
      ))
        (r['session_id'], r['stage'], r['outcome']),
    ];

    test(
      '🆕 세션 없음 = 시각 없이 받아들임 · OPEN CANON_BROKER 아님 = REPAIR_DIFF_NOT_OPEN',
      () {
        diff('ld-a', 'OPEN');
        diff('ld-c', 'RESOLVED');
        trusted.at = null;
        expect(store.acceptWithSession('ld-a'), isNull);
        expect(store.acceptWithSession('ld-a'), 'REPAIR_DIFF_NOT_OPEN');
        expect(store.acceptWithSession('ld-c'), 'REPAIR_DIFF_NOT_OPEN');
        expect(store.acceptWithSession('ld-none'), 'REPAIR_DIFF_NOT_OPEN');
        db.execute(
          "UPDATE ledger_diff SET status = 'OPEN', pair = 'CANON_GITHUB' WHERE diff_id = 'ld-c'",
        );
        expect(store.acceptWithSession('ld-c'), 'REPAIR_DIFF_NOT_OPEN');
        expect(steps(), isEmpty);
      },
    );

    test('🆕 이 diff 의 열린 세션 = 다음 단계 DO_NOTHING(닫힘) · 다른 대상 세션 · 닫힌 세션 그대로', () {
      diff('ld-a', 'OPEN');
      final DateTime t = trusted.at!;
      seedSessionSteps(db, 'x5:ld-a:1', <(int, DateTime, String?)>[
        (1, t.subtract(const Duration(hours: 2)), null),
      ], last: InterventionOutcome.abandoned);
      seedSessionSteps(db, 'x5:ld-a:2', <(int, DateTime, String?)>[
        (1, t.subtract(const Duration(hours: 1)), null),
        (2, t.subtract(const Duration(minutes: 30)), null),
      ]);
      seedSessionSteps(db, 'x5:ld-b:1', <(int, DateTime, String?)>[
        (1, t.subtract(const Duration(hours: 1)), null),
      ]);
      expect(store.acceptWithSession('ld-a'), isNull);
      expect(steps(), <(Object?, Object?, Object?)>[
        ('x5:ld-a:1', 1, 'ABANDONED'),
        ('x5:ld-a:2', 1, 'PASSED'),
        ('x5:ld-a:2', 2, 'PASSED'),
        ('x5:ld-a:2', 3, 'DO_NOTHING'),
        ('x5:ld-b:1', 1, 'PASSED'),
      ]);
      expect(
        db
            .select("SELECT status FROM ledger_diff WHERE diff_id = 'ld-a'")
            .single['status'],
        'ACCEPTED',
      );
    });

    test('🆕 🔴 닫을 세션이 있는데 신뢰 시각 모름 = 거부 · 쓰기 0', () {
      diff('ld-a', 'OPEN');
      seedSessionSteps(db, 'x5:ld-a:1', <(int, DateTime, String?)>[
        (1, trusted.at!, null),
      ]);
      trusted.at = null;
      expect(store.acceptWithSession('ld-a'), 'TRUSTED_TIME_UNKNOWN');
      expect(steps(), <(Object?, Object?, Object?)>[
        ('x5:ld-a:1', 1, 'PASSED'),
      ]);
      expect(
        db
            .select("SELECT status FROM ledger_diff WHERE diff_id = 'ld-a'")
            .single['status'],
        'OPEN',
      );
    });
  });

  group('정정 이력 실물', () {
    test('🔴 새 기준점 행 = 숨김 대상 · 문장 · 체인 축약 · 결정 링크', () async {
      broken();
      apply();
      final SqliteLedgerRepository repo = SqliteLedgerRepository(
        db,
        clock: clock,
      );
      final ListResult<LedgerRepairRow> r = await repo.watchRepairs().first;
      final LedgerRepairRow row = r.rows.single;
      expect(
        (row.repairId, row.targetText, row.label, row.directionCode),
        ('rp-1', '숨김', '새 기준점 선언 · 다시 스탬프 · 2026-11-02부터 재계산', 'CANON_CORRECT'),
      );
      expect(row.chainStampText, chainStampText(chains()['2026-11-04']!));
      expect(row.decisionLink!.deepLink, 'aaq://journal/decision/dec-x5');
      expect((r.emptyLabel, r.hasMore), (null, false));
    });

    test('상한 — 넘으면 자르고 hasMore', () {
      broken();
      apply();
      final SqliteLedgerRepository repo = SqliteLedgerRepository(
        db,
        clock: clock,
      );
      final ListResult<LedgerRepairRow> r = repo.repairs(limit: 0);
      expect((r.rows.length, r.hasMore), (0, true));
      expect(repo.repairs().hasMore, isFalse);
    });

    test('🔴 상세 없는 정정 행 = 스트림 오류', () async {
      db.execute(
        'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, evidence_hash, supersedes, applied_at) '
        "VALUES ('rp', 'd', 'DERIVED_RESYNC', 'PUSH_LAG', NULL, 'ev', NULL, '2026-11-04T00:00:00Z')",
      );
      final SqliteLedgerRepository repo = SqliteLedgerRepository(
        db,
        clock: clock,
      );
      await expectLater(repo.watchRepairs().first, throwsStateError);
    });
  });
}
