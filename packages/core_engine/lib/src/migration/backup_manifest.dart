// X1-2 백업 매니페스트 · 복원 판정 합성(순수 · 설계 13 §8 R135 P2 · P5 · P8 · SPEC v2.45 04 §3-1 ⑧).
//
// 🔴 매니페스트 = SPEC ⑧ 7키 그대로 · 정규 JSON(키 사전 차례 · 끝 줄바꿈 = 체크포인트와 같은 꼴) ·
//    읽기 = 다시 쓴 글자가 같아야 한다(아니면 거부) · 시각 칸 없음(시각은 저널 행이 가진다).
// 🔴 복원 판정 = 나쁜 쪽 먼저: sha → 열기 → 파일 꼴(live · schema) → `PRAGMA integrity_check` → 체인 →
//    매니페스트 ↔ 스냅숏 머리 → 아카이브 관계(IN_SYNC 만 — SPEC ⑧ «같음만», EMPTY · BEHIND 도 거부).
// 🔴 앞이 실패하면 뒤 사실은 묻지 않는다(사본을 더 읽지 않는다) · 탐침 없음 = 열 수 없음.

import '../ops/derived_sync.dart' show DerivedRelation;
import '../ops/ledger_hash.dart' show canonicalRow;
import '../ops/ledger_integrity.dart'
    show LedgerIntegrityVerdict, StoredDayStamp;
import 'migration_plan.dart' show MigrationStartCodes;

final RegExp _hex64 = RegExp(r'^[0-9a-f]{64}$');
final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');

// 따옴표 · 역빗금 · 제어 문자 · 비 ASCII 밖(정규 표기가 이스케이프 없이 그대로 되읽히는 글자만).
final RegExp _writer = RegExp(r'^[\x20\x21\x23-\x5b\x5d-\x7e]+$');

/// 매니페스트 키(SPEC ⑧ 7키 · 정규 차례).
const List<String> kBackupManifestKeys = <String>[
  'authored_date',
  'chain_hash',
  'hash_format_version',
  'operator_epoch',
  'schema_version',
  'sha256',
  'writer_device_id',
];

/// 스냅숏 거부 코드(계약 등재 = E16i 전 문자열).
abstract final class SnapshotCodes {
  /// 스탬프가 없다 — 체인 · 날을 지어내지 않는다.
  static const String noStamp = 'SNAPSHOT_NO_STAMP';

  /// 그 이름의 매니페스트가 이미 있다(덮지 않는다).
  static const String exists = 'SNAPSHOT_EXISTS';
}

/// 백업 매니페스트(SPEC ⑧).
final class BackupManifest {
  /// 만든다 — 꼴이 틀리면 [ArgumentError].
  BackupManifest({
    required this.sha256,
    required this.chainHash,
    required this.authoredDate,
    required this.schemaVersion,
    required this.hashFormatVersion,
    required this.operatorEpoch,
    required this.writerDeviceId,
  }) {
    if (!_hex64.hasMatch(sha256)) {
      throw ArgumentError.value(sha256.length, 'sha256', '16진 64');
    }
    if (!_hex64.hasMatch(chainHash)) {
      throw ArgumentError.value(chainHash.length, 'chainHash', '16진 64');
    }
    if (!_day.hasMatch(authoredDate)) {
      throw ArgumentError.value(authoredDate, 'authoredDate', '날 꼴');
    }
    if (schemaVersion < 1) {
      throw ArgumentError.value(schemaVersion, 'schemaVersion', '1 이상');
    }
    if (hashFormatVersion < 1) {
      throw ArgumentError.value(hashFormatVersion, 'hashFormatVersion', '1 이상');
    }
    if (operatorEpoch < 0) {
      throw ArgumentError.value(operatorEpoch, 'operatorEpoch', '음수');
    }
    if (!_writer.hasMatch(writerDeviceId)) {
      throw ArgumentError.value(
        writerDeviceId,
        'writerDeviceId',
        '인쇄 가능한 ASCII',
      );
    }
  }

  /// 정규 글자에서 읽는다 — 다시 쓴 글자가 같지 않으면 [FormatException].
  factory BackupManifest.parse(String text) {
    final RegExpMatch? m = _re.firstMatch(text);
    if (m == null) throw const FormatException('매니페스트를 읽을 수 없다');
    final BackupManifest b;
    try {
      b = BackupManifest(
        sha256: m.group(6)!,
        chainHash: m.group(2)!,
        authoredDate: m.group(1)!,
        schemaVersion: int.parse(m.group(5)!),
        hashFormatVersion: int.parse(m.group(3)!),
        operatorEpoch: int.parse(m.group(4)!),
        writerDeviceId: m.group(7)!,
      );
    } on ArgumentError catch (e) {
      throw FormatException('매니페스트 값이 틀렸다: ${e.message}');
    }
    if (b.toCanonicalJson() != text) {
      throw const FormatException('매니페스트가 정규 표기가 아니다');
    }
    return b;
  }

  static final RegExp _re = RegExp(
    r'^\{"authored_date":"([^"]*)","chain_hash":"([^"]*)",'
    r'"hash_format_version":(\d+),"operator_epoch":(\d+),"schema_version":(\d+),'
    r'"sha256":"([^"]*)","writer_device_id":"([^"\\]*)"\}\n$',
  );

  /// 스냅숏 파일 바이트의 sha256(16진 64).
  final String sha256;

  /// 스냅숏 마지막 스탬프의 체인.
  final String chainHash;

  /// 스냅숏 마지막 스탬프 날.
  final String authoredDate;

  /// 스냅숏 `schema_version`.
  final int schemaVersion;

  /// 스탬프 해시 판.
  final int hashFormatVersion;

  /// 만든 기기의 epoch.
  final int operatorEpoch;

  /// 만든 기기.
  final String writerDeviceId;

  /// 정규 JSON(키 사전 차례 · 끝 줄바꿈).
  String toCanonicalJson() =>
      '${canonicalRow(<String, Object?>{'authored_date': authoredDate, 'chain_hash': chainHash, 'hash_format_version': hashFormatVersion, 'operator_epoch': operatorEpoch, 'schema_version': schemaVersion, 'sha256': sha256, 'writer_device_id': writerDeviceId}, kBackupManifestKeys)}\n';
}

/// 복원 거부 사유(차례 = 판정 차례).
enum RestoreReason {
  /// 바이트 sha256 이 매니페스트와 다르다.
  shaMismatch('RESTORE_SHA_MISMATCH'),

  /// 사본을 열거나 읽지 못했다.
  unreadable('RESTORE_UNREADABLE'),

  /// live 원장 파일이 아니다.
  notLive(MigrationStartCodes.liveOnly),

  /// `schema_version` 이 이 앱과 다르다.
  schemaSkew('RESTORE_SCHEMA_SKEW'),

  /// `PRAGMA integrity_check` 가 ok 가 아니다.
  sqliteIntegrity('RESTORE_SQLITE_INTEGRITY'),

  /// 스탬프 체인 자가 대조 실패.
  chainInvalid('RESTORE_CHAIN_INVALID'),

  /// 매니페스트가 스냅숏 머리(마지막 스탬프 · schema)와 다르다.
  manifestMismatch('RESTORE_MANIFEST_MISMATCH'),

  /// 아카이브 체크포인트와 같지 않다(SPEC ⑧ — 같음만).
  rollback('RESTORE_ROLLBACK');

  const RestoreReason(this.wire);

  /// 코드.
  final String wire;
}

/// 스냅숏 사본 탐침 — 판정이 차례대로 묻는다(앞이 실패하면 뒤는 묻지 않는다).
abstract interface class SnapshotProbe {
  /// `application_id` = live 원장.
  bool get live;

  /// `schema_version` 최댓값(표 · 행 없음 = 0).
  int get schemaVersion;

  /// `PRAGMA integrity_check` 결과 줄.
  List<String> get sqliteIntegrity;

  /// 스탬프 체인 자가 대조.
  LedgerIntegrityVerdict get chain;

  /// 마지막 스탬프(없으면 null).
  StoredDayStamp? get head;

  /// 아카이브 체크포인트 ↔ 스냅숏 정본 체인(epoch = [operatorEpoch]).
  DerivedRelation archiveRelation(int operatorEpoch);
}

/// 복원 판정.
final class RestoreVerdict {
  /// 통과.
  const RestoreVerdict.ok()
    : reason = null,
      chain = null,
      archiveRelation = null;

  /// 거부.
  const RestoreVerdict.failed(
    RestoreReason this.reason, {
    this.chain,
    this.archiveRelation,
  });

  /// 거부 사유(통과 = null).
  final RestoreReason? reason;

  /// 체인 거부면 그 판정(사유 · 첫 날).
  final LedgerIntegrityVerdict? chain;

  /// 아카이브 거부면 그 관계.
  final DerivedRelation? archiveRelation;

  /// 통과했나.
  bool get ok => reason == null;

  /// 거부 코드(통과 = null).
  String? get code => reason?.wire;

  /// 저널 `detail_json` 재료(금액 · 시크릿 0).
  Map<String, Object?> toDetail() => <String, Object?>{
    'ok': ok,
    'reason': reason?.wire,
    'chain_reason': chain?.reason?.code,
    'first_bad_date': chain?.firstBadDate,
    'archive_relation': archiveRelation?.wire,
  };
}

/// 🔴 복원 판정 합성 — [sha256] = 읽은 바이트의 해시 · [probe] = 같은 바이트의 사본(null = 열 수 없음) ·
/// [appSchemaVersion] = 이 앱의 `schema_version`.
RestoreVerdict restoreVerdictOf({
  required BackupManifest manifest,
  required String sha256,
  required SnapshotProbe? probe,
  required int appSchemaVersion,
}) {
  if (sha256 != manifest.sha256) {
    return const RestoreVerdict.failed(RestoreReason.shaMismatch);
  }
  if (probe == null) {
    return const RestoreVerdict.failed(RestoreReason.unreadable);
  }
  if (!probe.live) return const RestoreVerdict.failed(RestoreReason.notLive);
  final int schema = probe.schemaVersion;
  if (schema != appSchemaVersion) {
    return const RestoreVerdict.failed(RestoreReason.schemaSkew);
  }
  final List<String> pragma = probe.sqliteIntegrity;
  if (pragma.length != 1 || pragma.single != 'ok') {
    return const RestoreVerdict.failed(RestoreReason.sqliteIntegrity);
  }
  final LedgerIntegrityVerdict chain = probe.chain;
  if (!chain.ok) {
    return RestoreVerdict.failed(RestoreReason.chainInvalid, chain: chain);
  }
  final StoredDayStamp? head = probe.head;
  if (head == null ||
      head.authoredDate != manifest.authoredDate ||
      head.chainHash != manifest.chainHash ||
      head.hashFormatVersion != manifest.hashFormatVersion ||
      schema != manifest.schemaVersion) {
    return const RestoreVerdict.failed(RestoreReason.manifestMismatch);
  }
  final DerivedRelation relation = probe.archiveRelation(
    manifest.operatorEpoch,
  );
  if (relation != DerivedRelation.inSync) {
    return RestoreVerdict.failed(
      RestoreReason.rollback,
      archiveRelation: relation,
    );
  }
  return const RestoreVerdict.ok();
}
