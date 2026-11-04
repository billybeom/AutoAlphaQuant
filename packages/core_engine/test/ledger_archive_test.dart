// E11h2 — 아카이브 레이아웃 · checkpoint.json · 백업 나이(설계 13 §8 R52 A1~A5).
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

const String _chain =
    'e73f1bfa5d4628025b7f4ec4626b756624cc2e3670fa0acbd671273440c6d8c9';

ArchiveCheckpoint _cp({String device = 'dev-1', int epoch = 0}) =>
    ArchiveCheckpoint(
      schemaVersion: 1,
      hashFormatVersion: 1,
      authoredDate: '2026-11-04',
      chainHash: _chain,
      operatorEpoch: epoch,
      writerDeviceId: device,
      committedAt: '2026-11-04T21:30:00.000Z',
    );

void main() {
  group('경로(R52 A1)', () {
    test('실전 = archive · 모의 = sim · 날 · 표 · 체크포인트', () {
      expect(archivePrefix(sim: false), 'archive');
      expect(archivePrefix(sim: true), 'sim');
      expect(archiveDayDir('archive', '2026-11-02'), 'archive/2026/2026-11-02');
      expect(
        archiveTablePath('sim', '2027-01-04', 'cash_flow'),
        'sim/2027/2027-01-04/cash_flow.jsonl',
      );
      expect(archiveCheckpointPath('archive'), 'archive/checkpoint.json');
      expect(() => archiveDayDir('archive', '2026-11-2'), throwsArgumentError);
    });
  });

  group('표 파일(R52 A2)', () {
    test('정렬 · 줄마다 LF · 왕복 · 빈 표 = 파일 없음', () {
      expect(
        archiveFileContent(<String>['{"b":1}', '{"a":1}']),
        '{"a":1}\n{"b":1}\n',
      );
      expect(archiveFileLines('{"a":1}\n{"b":1}\n'), <String>[
        '{"a":1}',
        '{"b":1}',
      ]);
      expect(() => archiveFileContent(const <String>[]), throwsArgumentError);
    });

    test('끝 LF 없음 · 빈 내용 · 빈 줄 = 실패', () {
      for (final String c in <String>['{"a":1}', '', '{"a":1}\n\n', '\n']) {
        expect(
          () => archiveFileLines(c),
          throwsA(isA<LedgerHashError>()),
          reason: jsonEncode(c),
        );
      }
    });

    test('🔵 파일만으로 다시 센 day_hash = 골든(빈 날 = 파일 없음)', () {
      final Map<String, dynamic> golden = jsonDecode(
        File('test/golden/vectors/ledger_hash_v1.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      for (final Map<String, dynamic> day
          in (golden['days'] as List<dynamic>).cast<Map<String, dynamic>>()) {
        final Map<String, String> files = <String, String>{
          for (final MapEntry<String, dynamic> e
              in (day['lines'] as Map<String, dynamic>).entries)
            e.key: archiveFileContent(
              (e.value as List<dynamic>).cast<String>(),
            ),
        };
        expect(
          dayHashFromArchive(files),
          day['day_hash'],
          reason: day['date'] as String,
        );
      }
      expect(
        dayHashFromArchive(const <String, String>{}),
        golden['empty_day_hash'],
      );
    });
  });

  group('체크포인트(R52 A4)', () {
    test('7키 · 이름 순 · 정규 JSON + LF · 왕복', () {
      final String j = _cp().toCanonicalJson();
      expect(
        j,
        '{"authored_date":"2026-11-04","chain_hash":"$_chain",'
        '"committed_at":"2026-11-04T21:30:00.000Z","hash_format_version":1,'
        '"operator_epoch":0,"schema_version":1,"writer_device_id":"dev-1"}\n',
      );
      final ArchiveCheckpoint back = ArchiveCheckpoint.parse(j);
      expect(
        (
          back.schemaVersion,
          back.hashFormatVersion,
          back.authoredDate,
          back.chainHash,
          back.operatorEpoch,
          back.writerDeviceId,
          back.committedAt,
        ),
        (1, 1, '2026-11-04', _chain, 0, 'dev-1', '2026-11-04T21:30:00.000Z'),
      );
      expect(
        ArchiveCheckpoint.parse(_cp(epoch: 7).toCanonicalJson()).operatorEpoch,
        7,
      );
    });

    test('정규 꼴이 아니면 실패 — 끝 LF · 공백 · 키 빠짐/더함 · 대문자 16진 · 앞 0 · 이스케이프', () {
      final String ok = _cp().toCanonicalJson();
      final List<String> bad = <String>[
        ok.trimRight(),
        ok.replaceFirst(':', ': '),
        ok.replaceFirst(',"operator_epoch":0', ''),
        ok.replaceFirst('}', ',"x":1}'),
        ok.replaceFirst(_chain, _chain.toUpperCase()),
        ok.replaceFirst('"operator_epoch":0', '"operator_epoch":00'),
        _cp(device: 'a\tb').toCanonicalJson(),
        '$ok\n',
      ];
      for (final String b in bad) {
        expect(
          () => ArchiveCheckpoint.parse(b),
          throwsA(isA<LedgerHashError>()),
          reason: jsonEncode(b),
        );
      }
    });
  });

  group('백업 나이(R52 A5)', () {
    final DateTime now = DateTime.utc(2026, 11, 6, 12);

    test('스탬프 0 = 판정 없음', () {
      expect(
        backupAgeOf(
          nowUtc: now,
          lastRemoteOkAtUtc: null,
          firstStampAtUtc: null,
        ),
        isNull,
      );
      expect(
        backupAgeOf(
          nowUtc: now,
          lastRemoteOkAtUtc: now.subtract(const Duration(hours: 1)),
          firstStampAtUtc: null,
        ),
        isNull,
      );
    });

    test('원격 성공이 있으면 그때부터 · 없으면 첫 스탬프부터', () {
      final DateTime first = now.subtract(const Duration(days: 3));
      expect(
        backupAgeOf(
          nowUtc: now,
          lastRemoteOkAtUtc: now.subtract(const Duration(hours: 2)),
          firstStampAtUtc: first,
        )!.age,
        const Duration(hours: 2),
      );
      expect(
        backupAgeOf(
          nowUtc: now,
          lastRemoteOkAtUtc: null,
          firstStampAtUtc: first,
        )!.age,
        const Duration(days: 3),
      );
    });

    test('26h 경계 — 같으면 아님 · 넘으면 BACKUP_STALE', () {
      expect(kBackupStaleAfter, const Duration(hours: 26));
      BackupAge at(Duration d) => backupAgeOf(
        nowUtc: now,
        lastRemoteOkAtUtc: now.subtract(d),
        firstStampAtUtc: now.subtract(const Duration(days: 9)),
      )!;
      expect(at(const Duration(hours: 26)).stale, isFalse);
      expect(at(const Duration(hours: 26, microseconds: 1)).stale, isTrue);
      expect(at(const Duration(hours: 1)).stale, isFalse);
    });
  });
}
