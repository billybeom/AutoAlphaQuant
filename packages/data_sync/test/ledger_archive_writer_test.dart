// E11h2 — JSONL 아카이브 로컬 쓰기 · checkpoint.json · 일일 아카이브 잡 본체(설계 13 §8 R52 A1~A7).
//
// 🔵 잡는 것: ① 경로(실전 archive/ · 모의 sim/) · 줄 = 골든 정규 줄 · 빈 날 = 폴더 없음 ② 파일만으로 다시 센 day_hash = 스탬프
//    ③ 체크포인트 7키 · 마지막에 쓴다 ④ 🔴 재계산 불일치 · 다른 바이트 · 체크포인트 어긋남 · 형식 판 = 실패 · 아무것도 안 씀
//    ⑤ 멱등 · 이어 쓰기 · 끊긴 뒤 다시 ⑥ 잡 = 어제까지 스탬프 → 아카이브 → 백업 나이 26h(`BACKUP_STALE`).
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

// 2026-11-04T21:30Z = 한국 11-05 06:30 — 11-04 까지 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 21, 30);

String _finalChain() =>
    (ledgerGolden['stamp'] as Map<String, dynamic>)['chain'] as String;

void main() {
  late Directory dir;
  late Directory root;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_arc_');
    root = Directory('${dir.path}/repo')..createSync();
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  LedgerArchiveWriter writer({RunMode mode = RunMode.live, Database? on}) =>
      LedgerArchiveWriter(
        on ?? db,
        root: root.path,
        mode: mode,
        clock: clock,
        writerDeviceId: 'dev-1',
        operatorEpoch: 3,
      );

  void stamp(String through) =>
      LedgerHashStamper(db, clock: clock).stampThrough(through);

  File file(String rel) => File('${root.path}/$rel');

  /// 루트 아래 파일 전부(루트 기준 · 정렬).
  List<String> tree() {
    final List<String> out = <String>[
      for (final FileSystemEntity e in root.listSync(recursive: true))
        if (e is File)
          e.path.substring(root.path.length + 1).replaceAll(r'\', '/'),
    ]..sort();
    return out;
  }

  group('LedgerArchiveWriter', () {
    test('🔵 경로 · 줄 = 골든 · 빈 날 = 폴더 없음 · 파일만으로 day_hash · 체크포인트 7키', () {
      loadLedgerGolden(db);
      stamp('2026-11-04');
      final LedgerArchiveReport r = writer().archiveStamped();
      expect(r.days, <String>['2026-11-02', '2026-11-03', '2026-11-04']);
      expect(tree(), <String>[
        'archive/2026/2026-11-02/cash_flow.jsonl',
        'archive/2026/2026-11-02/decision_log.jsonl',
        'archive/2026/2026-11-02/executions.jsonl',
        'archive/2026/2026-11-02/operating_param_log.jsonl',
        'archive/2026/2026-11-02/self_report_balance.jsonl',
        'archive/2026/2026-11-02/self_report_line.jsonl',
        'archive/2026/2026-11-04/executions.jsonl',
        'archive/2026/2026-11-04/order_intents.jsonl',
        'archive/checkpoint.json',
      ]);
      expect(r.filesWritten, hasLength(8));
      expect(
        Directory('${root.path}/archive/2026/2026-11-03').existsSync(),
        isFalse,
      );
      for (final Map<String, dynamic> day in goldenDays) {
        final String d = day['date'] as String;
        final Map<String, String> files = <String, String>{};
        for (final MapEntry<String, dynamic> e
            in (day['lines'] as Map<String, dynamic>).entries) {
          final String content = file(archiveTablePath('archive', d, e.key))
              .readAsStringSync();
          expect(
            archiveFileLines(content),
            (e.value as List<dynamic>).cast<String>(),
          );
          files[e.key] = content;
        }
        expect(dayHashFromArchive(files), day['day_hash'], reason: d);
      }
      final String cp = file('archive/checkpoint.json').readAsStringSync();
      expect(
        cp,
        '{"authored_date":"2026-11-04","chain_hash":"${_finalChain()}",'
        '"committed_at":"${_t0.toIso8601String()}","hash_format_version":1,'
        '"operator_epoch":3,"schema_version":1,"writer_device_id":"dev-1"}\n',
      );
      expect(r.checkpoint!.toCanonicalJson(), cp);
      expect(writer().readCheckpoint()!.chainHash, _finalChain());
      expect(tree().where((String p) => p.endsWith('.tmp')), isEmpty);
    });

    test('모의 계열 = sim/', () {
      final Directory d2 = Directory('${dir.path}/sim')..createSync();
      final Database sim = openLocalLedger(
        d2.path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      try {
        insertLedgerRow(sim, 'cash_flow', <String, Object?>{
          'flow_id': 'F-S',
          'trade_date': '2026-11-03',
          'amount': 1.0,
          'currency': 'KRW',
          'kind': 'DEPOSIT',
          'recorded_at': '2026-11-03T01:00:00.000Z',
        });
        LedgerHashStamper(sim, clock: clock).stampThrough('2026-11-03');
        writer(mode: RunMode.simBroker, on: sim).archiveStamped();
        expect(tree(), <String>[
          'sim/2026/2026-11-03/cash_flow.jsonl',
          'sim/checkpoint.json',
        ]);
      } finally {
        sim.close();
      }
    });

    test('스탬프 0 = 아무것도 안 씀', () {
      loadLedgerGolden(db);
      final LedgerArchiveReport r = writer().archiveStamped();
      expect(r.days, isEmpty);
      expect(r.filesWritten, isEmpty);
      expect(r.checkpoint, isNull);
      expect(tree(), isEmpty);
    });

    test('멱등 · 이어 쓰기 = 체크포인트 뒤 날만', () {
      loadLedgerGolden(db);
      stamp('2026-11-03');
      final LedgerArchiveReport a = writer().archiveStamped();
      expect(a.days, <String>['2026-11-02', '2026-11-03']);
      expect(a.checkpoint!.authoredDate, '2026-11-03');
      final String cp1 = file('archive/checkpoint.json').readAsStringSync();

      clock.at = _t0.add(const Duration(minutes: 5));
      final LedgerArchiveReport again = writer().archiveStamped();
      expect(again.days, isEmpty);
      expect(again.filesWritten, isEmpty);
      expect(again.checkpoint!.authoredDate, '2026-11-03');
      expect(file('archive/checkpoint.json').readAsStringSync(), cp1);

      stamp('2026-11-04');
      final LedgerArchiveReport b = writer().archiveStamped();
      expect(b.days, <String>['2026-11-04']);
      expect(b.filesWritten, <String>[
        'archive/2026/2026-11-04/executions.jsonl',
        'archive/2026/2026-11-04/order_intents.jsonl',
      ]);
      expect(b.checkpoint!.chainHash, _finalChain());
      expect(b.checkpoint!.committedAt, clock.at.toIso8601String());
    });

    test('끊긴 뒤 다시 — 날 파일은 있고 체크포인트가 없으면 같은 바이트는 건너뛰고 체크포인트를 쓴다', () {
      loadLedgerGolden(db);
      stamp('2026-11-04');
      writer().archiveStamped();
      file('archive/checkpoint.json').deleteSync();
      file('archive/2026/2026-11-04/order_intents.jsonl').deleteSync();
      final LedgerArchiveReport r = writer().archiveStamped();
      expect(r.days, hasLength(3));
      expect(r.filesWritten, <String>[
        'archive/2026/2026-11-04/order_intents.jsonl',
      ]);
      expect(writer().readCheckpoint()!.chainHash, _finalChain());
    });

    test('🔴 원장이 스탬프 뒤에 바뀌면 실패 · 아무것도 안 씀', () {
      loadLedgerGolden(db);
      stamp('2026-11-04');
      db.execute(
        "UPDATE executions SET quantity = 9 WHERE execution_id = 'E-3'",
      );
      expect(
        () => writer().archiveStamped(),
        throwsA(
          isA<LedgerArchiveError>().having(
            (LedgerArchiveError e) => e.reason,
            'reason',
            '2026-11-04: 원장이 스탬프와 다르다',
          ),
        ),
      );
      expect(tree(), isEmpty);
    });

    test('🔴 이미 있는 파일이 다른 바이트면 실패 · 앞 날 파일도 쓰지 않는다', () {
      loadLedgerGolden(db);
      stamp('2026-11-04');
      file('archive/2026/2026-11-04/executions.jsonl')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('{"x":1}\n');
      expect(
        () => writer().archiveStamped(),
        throwsA(
          isA<LedgerArchiveError>().having(
            (LedgerArchiveError e) => e.reason,
            'reason',
            '이미 있는 파일과 다르다: archive/2026/2026-11-04/executions.jsonl',
          ),
        ),
      );
      expect(tree(), <String>['archive/2026/2026-11-04/executions.jsonl']);
    });

    test('🔴 잘린 파일(앞부분만 같음)도 다른 바이트다', () {
      loadLedgerGolden(db);
      stamp('2026-11-04');
      final String rel = archiveTablePath(
        'archive',
        '2026-11-02',
        'executions',
      );
      final List<String> lines =
          ((goldenDays.first['lines'] as Map<String, dynamic>)['executions']
                  as List<dynamic>)
              .cast<String>();
      expect(lines, hasLength(2));
      final String first = '${lines.first}\n';
      file(rel)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(first);
      expect(
        () => writer().archiveStamped(),
        throwsA(
          isA<LedgerArchiveError>().having(
            (LedgerArchiveError e) => e.reason,
            'reason',
            '이미 있는 파일과 다르다: $rel',
          ),
        ),
      );
    });

    test('🔴 체크포인트가 체인과 다르거나 · 못 읽으면 실패', () {
      loadLedgerGolden(db);
      stamp('2026-11-04');
      final ArchiveCheckpoint wrong = ArchiveCheckpoint(
        schemaVersion: 1,
        hashFormatVersion: 1,
        authoredDate: '2026-11-02',
        chainHash: kChainGenesis,
        operatorEpoch: 0,
        writerDeviceId: 'dev-1',
        committedAt: 't',
      );
      file('archive/checkpoint.json')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(wrong.toCanonicalJson());
      expect(
        () => writer().archiveStamped(),
        throwsA(
          isA<LedgerArchiveError>().having(
            (LedgerArchiveError e) => e.reason,
            'reason',
            '체크포인트가 체인과 다르다: 2026-11-02',
          ),
        ),
      );
      file('archive/checkpoint.json').writeAsStringSync('{}');
      expect(
        () => writer().archiveStamped(),
        throwsA(
          isA<LedgerArchiveError>().having(
            (LedgerArchiveError e) => e.reason,
            'reason',
            startsWith('체크포인트: '),
          ),
        ),
      );
      // 스탬프에 없는 날을 가리켜도 실패.
      file('archive/checkpoint.json').writeAsStringSync(
        ArchiveCheckpoint(
          schemaVersion: 1,
          hashFormatVersion: 1,
          authoredDate: '2026-10-01',
          chainHash: kChainGenesis,
          operatorEpoch: 0,
          writerDeviceId: 'dev-1',
          committedAt: 't',
        ).toCanonicalJson(),
      );
      expect(
        () => writer().archiveStamped(),
        throwsA(isA<LedgerArchiveError>()),
      );
      expect(tree(), <String>['archive/checkpoint.json']);
    });

    test('🔴 스탬프 형식 판이 다르면 실패', () {
      loadLedgerGolden(db);
      db.execute(
        "INSERT INTO ledger_daily_hash VALUES ('2026-11-02', ?, ?, 2, '{}', 't')",
        <Object?>[kChainGenesis, kChainGenesis],
      );
      expect(
        () => writer().archiveStamped(),
        throwsA(
          isA<LedgerArchiveError>().having(
            (LedgerArchiveError e) => e.reason,
            'reason',
            '2026-11-02: 형식 판 다름',
          ),
        ),
      );
      expect(tree(), isEmpty);
    });
  });

  group('DailyArchiveJob(R52 A5 · A6)', () {
    DailyArchiveJob job() => DailyArchiveJob(
      db,
      clock: clock,
      root: root.path,
      mode: RunMode.live,
      writerDeviceId: 'dev-1',
      operatorEpoch: 0,
    );

    test('어제(한국)까지 스탬프 → 아카이브 → 백업 나이(원격 성공 없음 = 첫 스탬프부터)', () {
      loadLedgerGolden(db);
      final DailyArchiveReport r = job().run();
      expect(r.stamped, <String>['2026-11-02', '2026-11-03', '2026-11-04']);
      expect(r.archived, r.stamped);
      expect(r.backup!.age, Duration.zero);
      expect(r.alerts, isEmpty);
      expect(r.toString(), contains('스탬프 3'));

      // 27시간 뒤 — 원격 성공이 없으니 26h 를 넘었다.
      clock.at = _t0.add(const Duration(hours: 27));
      final DailyArchiveReport later = job().run();
      expect(later.stamped, <String>['2026-11-05']);
      expect(later.archived, <String>['2026-11-05']);
      expect(later.backup!.age, const Duration(hours: 27));
      expect(later.alerts, <String>{AlertCodes.backupStale});
      expect(writer().readCheckpoint()!.authoredDate, '2026-11-05');
    });

    test('원격 성공(sync_state GITHUB)이 있으면 그때부터 센다', () {
      loadLedgerGolden(db);
      job().run();
      clock.at = _t0.add(const Duration(hours: 40));
      db.execute(
        "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('GITHUB', ?, 'OK', 0, ?)",
        <Object?>[
          clock.at.subtract(const Duration(hours: 1)).toIso8601String(),
          clock.at.toIso8601String(),
        ],
      );
      final DailyArchiveReport r = job().run();
      expect(r.backup!.age, const Duration(hours: 1));
      expect(r.alerts, isEmpty);
      db.execute(
        "UPDATE sync_state SET last_ok_at = ? WHERE target = 'GITHUB'",
        <Object?>[
          clock.at.subtract(const Duration(hours: 30)).toIso8601String(),
        ],
      );
      expect(job().run().alerts, <String>{AlertCodes.backupStale});
    });

    test('행이 없으면 스탬프 0 · 백업 판정 없음 · 알림 없음', () {
      final DailyArchiveReport r = job().run();
      expect(r.stamped, isEmpty);
      expect(r.archived, isEmpty);
      expect(r.backup, isNull);
      expect(r.alerts, isEmpty);
      expect(r.toString(), contains('백업 -h'));
      expect(tree(), isEmpty);
    });
  });
}
