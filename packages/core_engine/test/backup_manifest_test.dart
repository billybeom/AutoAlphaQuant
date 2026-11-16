// E16g2 — 백업 매니페스트 · 복원 판정 합성(설계 13 §8 R135 P2 · P5 · P8 · SPEC v2.45 04 §3-1 ⑧).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show OriginCodes;
import 'package:test/test.dart';

final String _sha = 'a' * 64;
final String _chain = 'b' * 64;

BackupManifest _m({
  String? sha256,
  String? chainHash,
  String authoredDate = '2026-11-16',
  int schemaVersion = 1,
  int hashFormatVersion = 1,
  int operatorEpoch = 3,
  String writerDeviceId = 'dev-old',
}) => BackupManifest(
  sha256: sha256 ?? _sha,
  chainHash: chainHash ?? _chain,
  authoredDate: authoredDate,
  schemaVersion: schemaVersion,
  hashFormatVersion: hashFormatVersion,
  operatorEpoch: operatorEpoch,
  writerDeviceId: writerDeviceId,
);

const String _canon =
    '{"authored_date":"2026-11-16","chain_hash":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",'
    '"hash_format_version":1,"operator_epoch":3,"schema_version":1,'
    '"sha256":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",'
    '"writer_device_id":"dev-old"}\n';

/// 판정이 묻는 차례를 적는 가짜 탐침.
class _Probe implements SnapshotProbe {
  _Probe({
    this.liveValue = true,
    this.schema = 1,
    this.pragma = const <String>['ok'],
    LedgerIntegrityVerdict? chainValue,
    this.headValue,
    this.relation = DerivedRelation.inSync,
    bool noHead = false,
  }) : chainValue =
           chainValue ??
           const LedgerIntegrityVerdict.ok(
             daysChecked: 1,
             checkedThrough: '2026-11-16',
           ) {
    if (!noHead) {
      headValue ??= StoredDayStamp(
        authoredDate: '2026-11-16',
        dayHash: 'c' * 64,
        chainHash: _chain,
        hashFormatVersion: 1,
      );
    }
  }

  final bool liveValue;
  final int schema;
  final List<String> pragma;
  final LedgerIntegrityVerdict chainValue;
  StoredDayStamp? headValue;
  final DerivedRelation relation;
  final List<String> asked = <String>[];
  int? epochAsked;

  @override
  bool get live {
    asked.add('live');
    return liveValue;
  }

  @override
  int get schemaVersion {
    asked.add('schema');
    return schema;
  }

  @override
  List<String> get sqliteIntegrity {
    asked.add('pragma');
    return pragma;
  }

  @override
  LedgerIntegrityVerdict get chain {
    asked.add('chain');
    return chainValue;
  }

  @override
  StoredDayStamp? get head {
    asked.add('head');
    return headValue;
  }

  @override
  DerivedRelation archiveRelation(int operatorEpoch) {
    asked.add('archive');
    epochAsked = operatorEpoch;
    return relation;
  }
}

RestoreVerdict _v(
  _Probe? p, {
  BackupManifest? manifest,
  String? sha256,
  int app = 1,
}) => restoreVerdictOf(
  manifest: manifest ?? _m(),
  sha256: sha256 ?? _sha,
  probe: p,
  appSchemaVersion: app,
);

void main() {
  group('BackupManifest — SPEC ⑧ 7키 · 정규 JSON', () {
    test('키 = SPEC ⑧ 7개 · 사전 차례', () {
      expect(kBackupManifestKeys, <String>[
        'authored_date',
        'chain_hash',
        'hash_format_version',
        'operator_epoch',
        'schema_version',
        'sha256',
        'writer_device_id',
      ]);
      expect(
        kBackupManifestKeys,
        orderedEquals(<String>[...kBackupManifestKeys]..sort()),
      );
    });

    test('정규 글자 · 되읽기', () {
      expect(_m().toCanonicalJson(), _canon);
      final BackupManifest b = BackupManifest.parse(_canon);
      expect(b.sha256, _sha);
      expect(b.chainHash, _chain);
      expect(b.authoredDate, '2026-11-16');
      expect(b.schemaVersion, 1);
      expect(b.hashFormatVersion, 1);
      expect(b.operatorEpoch, 3);
      expect(b.writerDeviceId, 'dev-old');
      expect(b.toCanonicalJson(), _canon);
    });

    test('정규 표기가 아니면 거부(공백 · 줄바꿈 없음 · 키 차례 · 앞 0)', () {
      for (final String bad in <String>[
        _canon.replaceFirst(',', ', '),
        _canon.substring(0, _canon.length - 1),
        '$_canon\n',
        _canon.replaceFirst('"operator_epoch":3', '"operator_epoch":03'),
        '{"chain_hash":"${'b' * 64}","authored_date":"2026-11-16",'
            '"hash_format_version":1,"operator_epoch":3,"schema_version":1,'
            '"sha256":"$_sha","writer_device_id":"dev-old"}\n',
        '',
      ]) {
        expect(
          () => BackupManifest.parse(bad),
          throwsA(isA<FormatException>()),
          reason: bad,
        );
      }
    });

    test('값이 틀리면 되읽기 = FormatException(ArgumentError 아님)', () {
      for (final String bad in <String>[
        _canon.replaceFirst(_sha, 'A' * 64),
        _canon.replaceFirst(_chain, 'b' * 63),
        _canon.replaceFirst('2026-11-16', '2026-1-16'),
        _canon.replaceFirst('"schema_version":1', '"schema_version":0'),
        _canon.replaceFirst(
          '"hash_format_version":1',
          '"hash_format_version":0',
        ),
        _canon.replaceFirst('dev-old', ''),
      ]) {
        expect(
          () => BackupManifest.parse(bad),
          throwsA(isA<FormatException>()),
          reason: bad,
        );
      }
    });

    test('만들 때 꼴 검사', () {
      expect(() => _m(sha256: 'a' * 63), throwsArgumentError);
      expect(() => _m(sha256: 'g' * 64), throwsArgumentError);
      expect(() => _m(chainHash: 'B' * 64), throwsArgumentError);
      expect(() => _m(authoredDate: '20261116'), throwsArgumentError);
      expect(() => _m(schemaVersion: 0), throwsArgumentError);
      expect(() => _m(hashFormatVersion: 0), throwsArgumentError);
      expect(() => _m(operatorEpoch: -1), throwsArgumentError);
      expect(() => _m(writerDeviceId: ''), throwsArgumentError);
      expect(() => _m(writerDeviceId: 'a"b'), throwsArgumentError);
      expect(() => _m(writerDeviceId: r'a\b'), throwsArgumentError);
      expect(() => _m(writerDeviceId: 'a\nb'), throwsArgumentError);
      expect(() => _m(writerDeviceId: '기기'), throwsArgumentError);
      expect(_m(operatorEpoch: 0).operatorEpoch, 0);
      expect(_m(writerDeviceId: 'dev 1~').writerDeviceId, 'dev 1~');
    });
  });

  group('RestoreReason — 코드', () {
    test('차례 · 글자', () {
      expect(RestoreReason.values.map((RestoreReason r) => r.wire), <String>[
        'RESTORE_SHA_MISMATCH',
        'RESTORE_UNREADABLE',
        'X1_LIVE_ONLY',
        'RESTORE_SCHEMA_SKEW',
        'RESTORE_SQLITE_INTEGRITY',
        'RESTORE_CHAIN_INVALID',
        'RESTORE_MANIFEST_MISMATCH',
        'RESTORE_ROLLBACK',
      ]);
      expect(RestoreReason.notLive.wire, MigrationStartCodes.liveOnly);
      expect(RestoreReason.rollback.wire, OriginCodes.restoreRollback);
      expect(SnapshotCodes.noStamp, 'SNAPSHOT_NO_STAMP');
      expect(SnapshotCodes.exists, 'SNAPSHOT_EXISTS');
    });
  });

  group('restoreVerdictOf — 나쁜 쪽 먼저 · 앞이 실패하면 뒤는 묻지 않는다', () {
    test('모두 통과 = ok · 차례대로 다 묻는다 · epoch = 매니페스트', () {
      final _Probe p = _Probe();
      final RestoreVerdict v = _v(p, manifest: _m(operatorEpoch: 7));
      expect(v.ok, isTrue);
      expect(v.code, isNull);
      expect(v.reason, isNull);
      expect(p.asked, <String>[
        'live',
        'schema',
        'pragma',
        'chain',
        'head',
        'archive',
      ]);
      expect(p.epochAsked, 7);
    });

    test('① sha 다름 = 탐침을 묻지 않는다', () {
      final _Probe p = _Probe();
      final RestoreVerdict v = _v(p, sha256: 'd' * 64);
      expect(v.reason, RestoreReason.shaMismatch);
      expect(v.code, 'RESTORE_SHA_MISMATCH');
      expect(p.asked, isEmpty);
      expect(_v(null, sha256: 'd' * 64).reason, RestoreReason.shaMismatch);
    });

    test('② 탐침 없음 = 읽을 수 없음', () {
      expect(_v(null).reason, RestoreReason.unreadable);
    });

    test('③ live 아님 = X1_LIVE_ONLY', () {
      final _Probe p = _Probe(liveValue: false);
      final RestoreVerdict v = _v(p);
      expect(v.reason, RestoreReason.notLive);
      expect(v.code, 'X1_LIVE_ONLY');
      expect(p.asked, <String>['live']);
    });

    test('③ schema ≠ 앱 = SCHEMA_SKEW', () {
      final _Probe p = _Probe(schema: 2);
      expect(_v(p).reason, RestoreReason.schemaSkew);
      expect(p.asked, <String>['live', 'schema']);
      final _Probe q = _Probe(schema: 0);
      expect(_v(q).reason, RestoreReason.schemaSkew);
      final _Probe r = _Probe(schema: 2);
      expect(_v(r, app: 2, manifest: _m(schemaVersion: 2)).ok, isTrue);
    });

    test('④ PRAGMA ≠ [ok] = SQLITE_INTEGRITY', () {
      for (final List<String> bad in <List<String>>[
        <String>[],
        <String>['bad'],
        <String>['ok', 'ok'],
        <String>['ok', 'row 3 missing'],
      ]) {
        final _Probe p = _Probe(pragma: bad);
        expect(_v(p).reason, RestoreReason.sqliteIntegrity, reason: '$bad');
        expect(p.asked, <String>['live', 'schema', 'pragma']);
      }
    });

    test('⑤ 체인 실패 = CHAIN_INVALID · 판정이 실린다', () {
      const LedgerIntegrityVerdict bad = LedgerIntegrityVerdict.failed(
        LedgerIntegrityReason.chainBroken,
        firstBadDate: '2026-11-10',
        daysChecked: 4,
      );
      final _Probe p = _Probe(chainValue: bad);
      final RestoreVerdict v = _v(p);
      expect(v.reason, RestoreReason.chainInvalid);
      expect(v.chain, same(bad));
      expect(v.archiveRelation, isNull);
      expect(p.asked, <String>['live', 'schema', 'pragma', 'chain']);
      expect(v.toDetail(), <String, Object?>{
        'ok': false,
        'reason': 'RESTORE_CHAIN_INVALID',
        'chain_reason': 'CHAIN_BROKEN',
        'first_bad_date': '2026-11-10',
        'archive_relation': null,
      });
    });

    test('⑥ 매니페스트 ↔ 머리 다름 = MANIFEST_MISMATCH · 아카이브를 묻지 않는다', () {
      StoredDayStamp h({
        String date = '2026-11-16',
        String? chain,
        int version = 1,
      }) => StoredDayStamp(
        authoredDate: date,
        dayHash: 'c' * 64,
        chainHash: chain ?? _chain,
        hashFormatVersion: version,
      );
      final List<_Probe> probes = <_Probe>[
        _Probe(noHead: true),
        _Probe(headValue: h(date: '2026-11-15')),
        _Probe(headValue: h(chain: 'e' * 64)),
        _Probe(headValue: h(version: 2)),
      ];
      for (final _Probe p in probes) {
        expect(_v(p).reason, RestoreReason.manifestMismatch);
        expect(p.asked, <String>['live', 'schema', 'pragma', 'chain', 'head']);
      }
      // schema = 앱과 같지만 매니페스트와 다르다.
      final _Probe s = _Probe(schema: 1);
      expect(
        _v(s, manifest: _m(schemaVersion: 2)).reason,
        RestoreReason.manifestMismatch,
      );
    });

    test(
      '⑦ 아카이브 관계 ≠ IN_SYNC = RESTORE_ROLLBACK(EMPTY · BEHIND 도) · 관계가 실린다',
      () {
        for (final DerivedRelation r in DerivedRelation.values) {
          if (r == DerivedRelation.inSync) continue;
          final _Probe p = _Probe(relation: r);
          final RestoreVerdict v = _v(p);
          expect(v.reason, RestoreReason.rollback, reason: r.wire);
          expect(v.code, 'RESTORE_ROLLBACK');
          expect(v.archiveRelation, r);
          expect(v.chain, isNull);
          expect(v.toDetail()['archive_relation'], r.wire);
        }
      },
    );

    test('toDetail — 통과', () {
      expect(const RestoreVerdict.ok().toDetail(), <String, Object?>{
        'ok': true,
        'reason': null,
        'chain_reason': null,
        'first_bad_date': null,
        'archive_relation': null,
      });
    });
  });
}
