// 아카이브 레이아웃 · `checkpoint.json` · 백업 나이(설계 13 §8 R52 A1~A5 · 01 §6-7 · 06 M4-5 · 04 M8 `BACKUP_STALE`).
//
// 🔴 한 줄 = R51 H3 정규 행 — day_hash 입력의 «표 이름 · 탭» 뒤 부분과 바이트가 같다 → 파일만으로 day_hash 를 다시 센다.
// 🔴 체크포인트 = 7키 단일 객체 · 정규 JSON + LF · 매 묶음마다 덮어쓴다(이력 = git).

import 'ledger_hash.dart';

/// 백업이 오래됐다고 보는 나이(04 M8 알림표 · 06 M4-5 시험 = 26h).
const Duration kBackupStaleAfter = Duration(hours: 26);

/// 실전 = `archive` · 모의 계열 = `sim`(01 §6-7 · §9-2 격리).
String archivePrefix({required bool sim}) => sim ? 'sim' : 'archive';

/// 날 폴더 `{접두}/{yyyy}/{yyyy-mm-dd}`.
String archiveDayDir(String prefix, String day) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(day)) {
    throw ArgumentError.value(day, 'day', 'YYYY-MM-DD 가 아니다');
  }
  return '$prefix/${day.substring(0, 4)}/$day';
}

/// 표 파일 `{접두}/{yyyy}/{yyyy-mm-dd}/{table}.jsonl`.
String archiveTablePath(String prefix, String day, String table) =>
    '${archiveDayDir(prefix, day)}/$table.jsonl';

/// 체크포인트 `{접두}/checkpoint.json`.
String archiveCheckpointPath(String prefix) => '$prefix/checkpoint.json';

/// 표 파일 내용 — 정규 줄을 UTF-8 바이트 순으로 · 줄마다 LF(빈 목록 = 파일을 쓰지 않는다 → 부르는 쪽).
String archiveFileContent(List<String> lines) {
  if (lines.isEmpty) throw ArgumentError('빈 표는 파일을 쓰지 않는다');
  final StringBuffer b = StringBuffer();
  for (final String l in sortCanonicalLines(lines)) {
    b
      ..write(l)
      ..write('\n');
  }
  return b.toString();
}

/// 표 파일 내용 → 정규 줄(끝 LF 필수 · 빈 줄 = 실패).
List<String> archiveFileLines(String content) {
  if (content.isEmpty || !content.endsWith('\n')) {
    throw const LedgerHashError('아카이브 파일 끝이 LF 가 아니다');
  }
  final List<String> lines = content
      .substring(0, content.length - 1)
      .split('\n');
  if (lines.any((String l) => l.isEmpty)) {
    throw const LedgerHashError('아카이브 파일에 빈 줄');
  }
  return lines;
}

/// 파일들(표 → 내용)로 다시 센 day_hash(canonGithub 의 재료 · R52 A2).
String dayHashFromArchive(Map<String, String> contentsByTable) =>
    dayHashOf(<String, List<String>>{
      for (final MapEntry<String, String> e in contentsByTable.entries)
        e.key: archiveFileLines(e.value),
    });

/// `checkpoint.json`(01 §6-7 · R52 A4).
class ArchiveCheckpoint {
  /// 체크포인트를 만든다.
  const ArchiveCheckpoint({
    required this.schemaVersion,
    required this.hashFormatVersion,
    required this.authoredDate,
    required this.chainHash,
    required this.operatorEpoch,
    required this.writerDeviceId,
    required this.committedAt,
  });

  /// 정규 JSON 을 읽는다 — 7키가 정확히 있어야 하고 형식이 맞아야 한다.
  factory ArchiveCheckpoint.parse(String text) {
    final ArchiveCheckpoint c = _parse(text);
    if (c.toCanonicalJson() != text) {
      throw const LedgerHashError('체크포인트가 정규 표기가 아니다');
    }
    return c;
  }

  /// 스키마 판(계약 `schemaVersion`).
  final int schemaVersion;

  /// 직렬화 판(계약 `hashFormatVersion`).
  final int hashFormatVersion;

  /// 마지막으로 쓴 날.
  final String authoredDate;

  /// 그 날 체인.
  final String chainHash;

  /// 운영자 epoch(리스 E11k 전 = 0).
  final int operatorEpoch;

  /// 쓴 기기.
  final String writerDeviceId;

  /// 묶음을 봉인한 시각(ISO-8601 UTC).
  final String committedAt;

  /// 정규 JSON + LF.
  String toCanonicalJson() =>
      '${canonicalRow(<String, Object?>{'schema_version': schemaVersion, 'hash_format_version': hashFormatVersion, 'authored_date': authoredDate, 'chain_hash': chainHash, 'operator_epoch': operatorEpoch, 'writer_device_id': writerDeviceId, 'committed_at': committedAt}, _keys)}\n';

  static const List<String> _keys = <String>[
    'schema_version',
    'hash_format_version',
    'authored_date',
    'chain_hash',
    'operator_epoch',
    'writer_device_id',
    'committed_at',
  ];

  static ArchiveCheckpoint _parse(String text) {
    final RegExp re = RegExp(
      r'^\{"authored_date":"(\d{4}-\d{2}-\d{2})","chain_hash":"([0-9a-f]{64})",'
      r'"committed_at":"([^"\\]+)","hash_format_version":(\d+),"operator_epoch":(\d+),'
      r'"schema_version":(\d+),"writer_device_id":"([^"\\]+)"\}\n$',
    );
    final RegExpMatch? m = re.firstMatch(text);
    if (m == null) throw const LedgerHashError('체크포인트를 읽을 수 없다');
    return ArchiveCheckpoint(
      schemaVersion: int.parse(m.group(6)!),
      hashFormatVersion: int.parse(m.group(4)!),
      authoredDate: m.group(1)!,
      chainHash: m.group(2)!,
      operatorEpoch: int.parse(m.group(5)!),
      writerDeviceId: m.group(7)!,
      committedAt: m.group(3)!,
    );
  }
}

/// 백업 나이(R52 A5).
class BackupAge {
  /// 나이를 만든다.
  const BackupAge(this.age);

  /// 나이.
  final Duration age;

  /// 26h 초과 = `BACKUP_STALE`.
  bool get stale => age > kBackupStaleAfter;
}

/// 백업 나이 = 지금 − 마지막 원격 성공(없으면 첫 스탬프 시각) · 스탬프 0 = null(백업할 것이 없다).
BackupAge? backupAgeOf({
  required DateTime nowUtc,
  required DateTime? lastRemoteOkAtUtc,
  required DateTime? firstStampAtUtc,
}) {
  if (firstStampAtUtc == null) return null;
  final DateTime from = lastRemoteOkAtUtc ?? firstStampAtUtc;
  return BackupAge(nowUtc.toUtc().difference(from.toUtc()));
}
