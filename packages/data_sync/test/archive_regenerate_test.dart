// E16f3b — X5-4 아카이브 REBASED 재생성(설계 13 §8 R131 M1~M9).
//
// 🔵 잡는 것: ① 새 기준점 뒤 이어 쓰기 = «체크포인트가 체인과 다르다» → 재생성 = 첫 날 ~ 마지막 스탬프 다시 대조 ·
//    다른 바이트만 덮어씀 · 🔴 행이 빠진 표의 옛 파일 지움 · 파일로 다시 센 day_hash = 스탬프 · 체크포인트 마지막 · 첫 날 앞은 그대로
//    ② 거부(체크포인트 없음 · 첫 날 > 체크포인트 · 스탬프 없음 · 형식 판 · 원장 ≠ 스탬프) = 아무것도 안 씀
//    ③ 정정 행(DERIVED_RESYNC · ARCHIVE_DAYS · 결정 없음 · 다시 돌려도 한 행) · REBASED diff RESOLVED · 오늘 횟수
//    ④ 잡 = 리스 유효 ∧ 상한 안 → 다시 씀 · 리스 없음 = 미룸 LEASE_NOT_VALID · 상한 = 미룸 DAILY_CAP · 상한 0 = 오류.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart' show sha256;
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

// 2026-11-04T21:30Z = 한국 11-05 06:30 — 11-04 까지 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 21, 30);
const String _p = 'archive';

void main() {
  late Directory dir;
  late Directory root;
  late Database db;
  late _Clock clock;
  late SqliteDerivedSyncStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_rgn_');
    root = Directory('${dir.path}/repo')..createSync();
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteDerivedSyncStore(db);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  LedgerArchiveWriter writer() => LedgerArchiveWriter(
    db,
    root: root.path,
    mode: RunMode.live,
    clock: clock,
    writerDeviceId: 'dev-1',
    operatorEpoch: 0,
  );

  List<String> tree() => <String>[
    for (final FileSystemEntity e in root.listSync(recursive: true))
      if (e is File)
        e.path.substring(root.path.length + 1).replaceAll(r'\', '/'),
  ]..sort();

  Map<String, String> bytes() => <String, String>{
    for (final String rel in tree())
      rel: File('${root.path}/$rel').readAsStringSync(),
  };

  Map<String, String> stamps() => <String, String>{
    for (final Row r in db.select(
      'SELECT authored_date, day_hash FROM ledger_daily_hash ORDER BY authored_date',
    ))
      r['authored_date'] as String: r['day_hash'] as String,
  };

  /// 파일만으로 다시 센 그 날 day_hash.
  String dayHashOfFiles(String day) {
    final Directory d = Directory('${root.path}/${archiveDayDir(_p, day)}');
    final Map<String, String> byTable = <String, String>{
      if (d.existsSync())
        for (final FileSystemEntity e in d.listSync())
          if (e is File && e.path.endsWith('.jsonl'))
            e.uri.pathSegments.last.replaceAll('.jsonl', ''): e
                .readAsStringSync(),
    };
    return dayHashFromArchive(byTable);
  }

  /// 무결성 검사 → 새 기준점(신뢰 시각 = 지금).
  void baseline() {
    expect(LedgerIntegrityCheck(db, clock: clock).run().verdict.ok, isFalse);
    // 🆕 E16j-a — 커밋 = 개입 세션 5단계(결정 = 세션 저널).
    seedExecutableSession(
      db,
      'x5:li-base:1',
      nowUtc: clock.at,
      journalId: 'dec-x5',
    );
    final BaselineResult b =
        SqliteLedgerRepairStore(db, trusted: _Trusted(clock.at)).applyBaseline(
          repairId: 'rp-base',
          sessionId: 'x5:li-base:1',
          originCode: OriginCodes.chainBroken,
          clearedBy: 'operator',
        );
    expect(b.applied, isTrue);
  }

  /// 골든 · 11-04 까지 스탬프 · 아카이브.
  void archived() {
    loadLedgerGolden(db);
    LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
    writer().archiveStamped();
  }

  group('LedgerArchiveWriter.regenerateFrom', () {
    test('🔴 행이 다른 날로 옮겨감 → 새 기준점 → 재생성 = 옛 표 파일 지움 · 새 파일 · day_hash 일치 · 이어 쓰기 다시 됨', () {
      archived();
      expect(
        File(
          '${root.path}/${archiveTablePath(_p, '2026-11-02', 'decision_log')}',
        ).existsSync(),
        isTrue,
      );
      db.execute(
        "UPDATE decision_log SET created_at = '2026-11-04T05:00:00Z' WHERE decision_id = 'D-1'",
      );
      baseline();
      expect(
        () => writer().archiveStamped(),
        throwsA(isA<LedgerArchiveError>()),
        reason: '새 기준점 뒤 이어 쓰기는 체크포인트에서 멈춘다',
      );
      // jsonl 이 아닌 파일은 표가 아니다 — 지우지 않는다.
      final File stray = File(
        '${root.path}/${archiveDayDir(_p, '2026-11-02')}/README.txt',
      )..writeAsStringSync('메모');
      final Map<String, String> before = bytes();
      final LedgerArchiveReport r = writer().regenerateFrom('2026-11-02');
      expect(stray.existsSync(), isTrue);
      expect(r.days, <String>['2026-11-02', '2026-11-03', '2026-11-04']);
      expect(r.filesDeleted, <String>[
        archiveTablePath(_p, '2026-11-02', 'decision_log'),
      ]);
      expect(
        r.filesWritten,
        contains(archiveTablePath(_p, '2026-11-04', 'decision_log')),
      );
      // 바뀌지 않은 파일은 다시 쓰지 않는다.
      for (final String rel in r.filesWritten) {
        expect(before[rel], isNot(bytes()[rel]), reason: rel);
      }
      final Map<String, String> s = stamps();
      for (final MapEntry<String, String> e in s.entries) {
        expect(dayHashOfFiles(e.key), e.value, reason: e.key);
      }
      final String head =
          db
                  .select(
                    "SELECT chain_hash FROM ledger_daily_hash WHERE authored_date = '2026-11-04'",
                  )
                  .single['chain_hash']
              as String;
      expect(
        (r.checkpoint!.authoredDate, r.checkpoint!.chainHash),
        ('2026-11-04', head),
      );
      expect(writer().readCheckpoint()!.chainHash, head);
      expect(writer().archiveStamped().days, isEmpty);
      expect(
        store.archiveView(writer(), operatorEpoch: 0).relation,
        DerivedRelation.inSync,
      );
      // 다시 돌려도 같다(멱등) — 쓰기 · 지우기 0.
      final LedgerArchiveReport again = writer().regenerateFrom('2026-11-02');
      expect(again.filesWritten, isEmpty);
      expect(again.filesDeleted, isEmpty);
    });

    test('첫 날 앞 날 파일은 그대로 · 그 날 다른 파일만 다시 쓴다', () {
      archived();
      db.execute(
        'UPDATE executions SET tax = tax + 1 WHERE execution_id = '
        '(SELECT execution_id FROM executions ORDER BY authored_at DESC LIMIT 1)',
      );
      baseline();
      final Map<String, String> before = bytes();
      final LedgerArchiveReport r = writer().regenerateFrom('2026-11-04');
      expect(r.days, <String>['2026-11-04']);
      expect(r.filesWritten, <String>[
        archiveTablePath(_p, '2026-11-04', 'executions'),
      ]);
      expect(r.filesDeleted, isEmpty);
      final Map<String, String> after = bytes();
      for (final String rel in before.keys) {
        if (rel.startsWith('archive/2026/2026-11-02') ||
            rel.startsWith('archive/2026/2026-11-03')) {
          expect(after[rel], before[rel], reason: rel);
        }
      }
      expect(dayHashOfFiles('2026-11-04'), stamps()['2026-11-04']);
    });

    group('🔴 거부 = 아무것도 안 씀', () {
      test('체크포인트 없음', () {
        loadLedgerGolden(db);
        LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
        expect(
          () => writer().regenerateFrom('2026-11-02'),
          throwsA(isA<LedgerArchiveError>()),
        );
        expect(tree(), isEmpty);
      });
      test('첫 날 > 체크포인트 날 · 다시 쓸 스탬프 없음', () {
        archived();
        final Map<String, String> before = bytes();
        expect(
          () => writer().regenerateFrom('2026-11-05'),
          throwsA(
            isA<LedgerArchiveError>().having(
              (LedgerArchiveError e) => e.reason,
              'reason',
              contains('체크포인트 날'),
            ),
          ),
        );
        db.execute(
          "DELETE FROM ledger_daily_hash WHERE authored_date >= '2026-11-04'",
        );
        expect(
          () => writer().regenerateFrom('2026-11-04'),
          throwsA(
            isA<LedgerArchiveError>().having(
              (LedgerArchiveError e) => e.reason,
              'reason',
              contains('스탬프가 없다'),
            ),
          ),
        );
        expect(bytes(), before);
      });
      test('원장 ≠ 스탬프 · 형식 판 다름', () {
        archived();
        db.execute(
          "UPDATE decision_log SET created_at = '2026-11-04T05:00:00Z' WHERE decision_id = 'D-1'",
        );
        baseline();
        final Map<String, String> before = bytes();
        db.execute(
          "UPDATE decision_log SET reason = reason || '.' WHERE decision_id = 'D-1'",
        );
        expect(
          () => writer().regenerateFrom('2026-11-02'),
          throwsA(
            isA<LedgerArchiveError>().having(
              (LedgerArchiveError e) => e.reason,
              'reason',
              contains('원장이 스탬프와 다르다'),
            ),
          ),
        );
        expect(bytes(), before);
        db.execute(
          "UPDATE decision_log SET reason = substr(reason, 1, length(reason) - 1) WHERE decision_id = 'D-1'",
        );
        db.execute(
          "UPDATE ledger_daily_hash SET hash_format_version = 99 WHERE authored_date = '2026-11-03'",
        );
        expect(
          () => writer().regenerateFrom('2026-11-02'),
          throwsA(
            isA<LedgerArchiveError>().having(
              (LedgerArchiveError e) => e.reason,
              'reason',
              contains('형식 판'),
            ),
          ),
        );
        expect(bytes(), before);
      });
    });
  });

  group('재생성 기록', () {
    late DerivedView rebased;
    setUp(() {
      loadLedgerGolden(db);
      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
      rebased = (
        canon: CanonChain(
          stamps: storedDayStampsOf(db),
          operatorEpoch: 0,
          baselines: const <ChainBaseline>[
            ChainBaseline(fromDate: '2026-11-02', decisionId: 'dec'),
          ],
        ),
        derived: DerivedStamp(
          authoredDate: '2026-11-04',
          chainHash: 'a' * 64,
          operatorEpoch: 0,
        ),
        relation: DerivedRelation.rebased,
      );
    });

    test('🔴 DERIVED_RESYNC · ARCHIVE_DAYS · 결정 없음 · diff 넣고 RESOLVED · 다시 돌려도 한 행 · 문장', () {
      final DerivedChainDiff d = derivedChainDiffOf(
        DerivedTarget.github,
        rebased.relation,
        rebased.canon,
        rebased.derived,
      )!;
      final String head = 'b' * 64;
      final LedgerRepairPlanRow row = store.recordArchiveResync(
        DerivedTarget.github,
        rebased,
        fromDate: '2026-11-02',
        days: 3,
        chainHash: head,
        atUtc: _t0,
      );
      expect(
        row.repairId,
        archiveResyncRepairIdOf(DerivedTarget.github, '2026-11-02', head),
      );
      expect(
        row.repairId,
        'rs-${sha256.convert(utf8.encode('GITHUB|2026-11-02|$head')).toString().substring(0, 24)}',
      );
      expect(row.repairId, startsWith('rs-'));
      expect(row.repairId, hasLength(27));
      final Row r = db.select('SELECT * FROM ledger_repair').single;
      expect(
        <Object?>[
          r['repair_id'],
          r['diff_id'],
          r['direction'],
          r['origin_code'],
          r['decision_id'],
          r['evidence_hash'],
          r['supersedes'],
          r['applied_at'],
        ],
        <Object?>[
          row.repairId,
          d.diffId,
          'DERIVED_RESYNC',
          'CHAIN_BROKEN',
          null,
          evidenceHashOf(d.deltaJson),
          null,
          _t0.toIso8601String(),
        ],
      );
      final Row det = db.select('SELECT * FROM ledger_repair_detail').single;
      expect(
        <Object?>[
          det['recomputed_from'],
          det['chain_hash'],
          det['target_json'],
          det['evidence_json'],
        ],
        <Object?>[
          '2026-11-02',
          head,
          '{"kind":"ARCHIVE_DAYS","count":3}',
          d.deltaJson,
        ],
      );
      final Row diff = db.select('SELECT * FROM ledger_diff').single;
      expect(
        (diff['diff_id'], diff['status'], diff['origin_code']),
        (d.diffId, 'RESOLVED', 'CHAIN_BROKEN'),
      );
      store.recordArchiveResync(
        DerivedTarget.github,
        rebased,
        fromDate: '2026-11-02',
        days: 3,
        chainHash: head,
        atUtc: _t0.add(const Duration(minutes: 5)),
      );
      expect(db.select('SELECT * FROM ledger_repair'), hasLength(1));
      expect(db.select('SELECT * FROM ledger_repair_detail'), hasLength(1));
      final StoredLedgerRepair s = storedLedgerRepairs(db).single;
      expect(repairLabelOf(s), '아카이브 3일을 다시 썼습니다 · 2026-11-02부터 재계산');
    });

    test('이미 OPEN 인 REBASED diff 를 RESOLVED 로', () {
      expect(store.recordRebased(DerivedTarget.github, rebased, _t0), isTrue);
      store.recordArchiveResync(
        DerivedTarget.github,
        rebased,
        fromDate: '2026-11-02',
        days: 1,
        chainHash: 'c' * 64,
        atUtc: _t0,
      );
      expect(
        db.select('SELECT status FROM ledger_diff').single['status'],
        'RESOLVED',
      );
    });

    test('REBASED 아님 · 날 수 음수 = ArgumentError · 쓰기 0', () {
      final DerivedView empty = store.archiveView(writer(), operatorEpoch: 0);
      expect(
        () => store.recordArchiveResync(
          DerivedTarget.github,
          empty,
          fromDate: '2026-11-02',
          days: 1,
          chainHash: 'c' * 64,
          atUtc: _t0,
        ),
        throwsArgumentError,
      );
      expect(
        () => store.recordArchiveResync(
          DerivedTarget.github,
          rebased,
          fromDate: '2026-11-02',
          days: -1,
          chainHash: 'c' * 64,
          atUtc: _t0,
        ),
        throwsArgumentError,
      );
      expect(db.select('SELECT * FROM ledger_repair'), isEmpty);
      expect(db.select('SELECT * FROM ledger_diff'), isEmpty);
    });

    test('오늘 횟수 = 한국 날 DERIVED_RESYNC × ARCHIVE_DAYS 만', () {
      // _t0 = 한국 11-05 06:30.
      store.recordArchiveResync(
        DerivedTarget.github,
        rebased,
        fromDate: '2026-11-02',
        days: 1,
        chainHash: 'c' * 64,
        atUtc: _t0,
      );
      void raw(String id, String direction, String kind, String at) {
        db.execute(
          'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, '
          "evidence_hash, supersedes, applied_at) VALUES (?, 'x', ?, 'CHAIN_BROKEN', 'd', 'ev_x', NULL, ?)",
          <Object?>[id, direction, at],
        );
        db.execute(
          'INSERT INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, evidence_json) '
          'VALUES (?, NULL, ?, ?, NULL)',
          <Object?>[
            id,
            kChainGenesis,
            jsonEncode(<String, Object?>{'kind': kind, 'count': 1}),
          ],
        );
      }

      raw(
        'r-mirror',
        'DERIVED_RESYNC',
        'MIRROR_EXEC_ROWS',
        _t0.toIso8601String(),
      );
      raw('r-canon', 'CANON_CORRECT', 'ARCHIVE_DAYS', _t0.toIso8601String());
      // 한국 11-05 08:59 = UTC 11-04 23:59 · 한국 11-06 00:00 = UTC 11-05 15:00.
      raw(
        'r-same',
        'DERIVED_RESYNC',
        'ARCHIVE_DAYS',
        '2026-11-04T23:59:00.000Z',
      );
      raw(
        'r-next',
        'DERIVED_RESYNC',
        'ARCHIVE_DAYS',
        '2026-11-05T15:00:00.000Z',
      );
      expect(store.archiveResyncsOn('2026-11-05'), 2);
      expect(store.archiveResyncsOn('2026-11-06'), 1);
      expect(store.archiveResyncsOn('2026-11-04'), 0);
    });
  });

  group('잡 배선', () {
    DailyArchiveJob job({int cap = 3}) => DailyArchiveJob(
      db,
      clock: clock,
      root: root.path,
      mode: RunMode.live,
      writerDeviceId: 'dev-1',
      operatorEpoch: 0,
      derivedResyncDailyCap: cap,
    );

    /// 골든 · 잡 1회(11-04 까지 아카이브) → 행 옮김 → 다음 날(무결성 불일치) → 새 기준점.
    void rebasedSetup() {
      loadLedgerGolden(db);
      job().run();
      db.execute(
        "UPDATE decision_log SET created_at = '2026-11-04T05:00:00Z' WHERE decision_id = 'D-1'",
      );
      clock.at = _t0.add(const Duration(days: 1));
      expect(job().run().skipped, ArchiveSkip.integrity);
      baseline();
    }

    test('상한 0 = ArgumentError', () {
      expect(() => job(cap: 0), throwsArgumentError);
    });

    test('🔴 리스 유효 = 다시 씀 · 정정 행 · diff 해소 · 다음 회차는 평시', () {
      rebasedSetup();
      final DailyArchiveReport r = job().run(lease: LeaseVerdict.valid);
      expect(
        (r.skipped, r.relation, r.hold, r.forkRaised),
        (null, DerivedRelation.rebased, null, false),
      );
      expect(r.archived, <String>[
        '2026-11-02',
        '2026-11-03',
        '2026-11-04',
        '2026-11-05',
      ]);
      expect(r.resync!.recomputedFrom, '2026-11-02');
      expect(r.resync!.targetJson, '{"kind":"ARCHIVE_DAYS","count":4}');
      expect(r.toString(), contains('아카이브 다시 씀 4'));
      expect(r.alerts, isNot(contains(kDerivedForkAlertCode)));
      expect(
        db
            .select(
              "SELECT status FROM ledger_diff WHERE pair = 'CANON_GITHUB'",
            )
            .single['status'],
        'RESOLVED',
      );
      for (final MapEntry<String, String> e in stamps().entries) {
        expect(dayHashOfFiles(e.key), e.value, reason: e.key);
      }
      expect(store.archiveResyncsOn(kstDateText(clock.at)), 1);
      clock.at = clock.at.add(const Duration(days: 1));
      final DailyArchiveReport next = job().run(lease: LeaseVerdict.valid);
      expect(
        (next.skipped, next.relation, next.resync),
        (null, DerivedRelation.behind, null),
      );
      expect(next.archived, <String>['2026-11-06']);
    });

    test('리스 없음(기본 UNKNOWN) = 미룸 LEASE_NOT_VALID · 관측 diff OPEN · 파일 그대로', () {
      rebasedSetup();
      final List<String> before = tree();
      final DailyArchiveReport r = job().run();
      expect(
        (r.skipped, r.hold, r.resync),
        (ArchiveSkip.rebased, DerivedHoldReason.leaseNotValid, null),
      );
      expect(r.archived, isEmpty);
      expect(r.toString(), contains('건너뜀 REBASED 대기 LEASE_NOT_VALID'));
      expect(tree(), before);
      expect(
        db.select('SELECT status FROM ledger_diff').single['status'],
        'OPEN',
      );
      expect(
        job().run(lease: LeaseVerdict.invalid).hold,
        DerivedHoldReason.leaseNotValid,
      );
    });

    test('하루 상한 = 미룸 DAILY_CAP', () {
      rebasedSetup();
      db.execute(
        'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, '
        "evidence_hash, supersedes, applied_at) VALUES ('r-today', 'x', 'DERIVED_RESYNC', 'CHAIN_BROKEN', NULL, 'ev_x', NULL, ?)",
        <Object?>[clock.at.toIso8601String()],
      );
      db.execute(
        'INSERT INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, evidence_json) '
        "VALUES ('r-today', NULL, ?, '{\"kind\":\"ARCHIVE_DAYS\",\"count\":1}', NULL)",
        <Object?>[kChainGenesis],
      );
      final DailyArchiveReport r = job(cap: 1).run(lease: LeaseVerdict.valid);
      expect(
        (r.skipped, r.hold),
        (ArchiveSkip.rebased, DerivedHoldReason.dailyCap),
      );
      expect(job(cap: 2).run(lease: LeaseVerdict.valid).resync, isNotNull);
    });
  });
}
