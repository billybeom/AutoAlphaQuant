// 스키마 버전 게이트(M4-8 · 04 M8 §2-4 · 계약 `contract_version.dart` G-36 · 설계 13 §8 R53 I4 · 지도 D17).
//
// 🔴 입력 = `rm_config_view` 행의 3필드(`schema_version` · `hash_format_version` · `contract_version`) ·
//    비교 기준 = 이 빌드에 컴파일된 계약 상수.
// 🔴 행을 못 읽으면(표 부재 · RLS 거부 · 칸 빠짐 · 형식 틀림) `ok` 가 아니라 `incompatible` 이다 —
//    잘못 그리는 것보다 안 그리는 것이 안전하다.

import 'package:domain_contracts/domain_contracts.dart'
    show contractVersion, hashFormatVersion, schemaVersion;

/// 게이트 3상(04 M8 §2-4).
enum ReadModelGate {
  /// 정상 렌더.
  ok,

  /// 배너 + 본문(일부 카드 `notApplicable`).
  degraded,

  /// 본문 렌더 중단 · 안내 문구만.
  incompatible,
}

/// 계약 판 `MAJOR.MINOR.PATCH`.
class ContractVersion {
  /// 판을 만든다.
  const ContractVersion(this.major, this.minor, this.patch);

  /// `MAJOR.MINOR.PATCH`(각 칸 = 앞 0 없는 10진) — 그 밖 = null.
  static ContractVersion? tryParse(String s) {
    final RegExpMatch? m = RegExp(r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$')
        .firstMatch(s);
    if (m == null) return null;
    return ContractVersion(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  /// 주 판.
  final int major;

  /// 부 판(추가형).
  final int minor;

  /// 고침 판.
  final int patch;

  @override
  String toString() => '$major.$minor.$patch';
}

/// `rm_config_view` 의 버전 스탬프 3필드.
class ReadModelVersionStamp {
  /// 스탬프를 만든다.
  const ReadModelVersionStamp({
    required this.schemaVersion,
    required this.hashFormatVersion,
    required this.contractVersion,
  });

  /// 행 지도에서 읽는다 — 칸 빠짐 · 형식 틀림 = null(= 못 읽음).
  static ReadModelVersionStamp? fromRow(Map<String, Object?>? row) {
    if (row == null) return null;
    final Object? s = row['schema_version'];
    final Object? h = row['hash_format_version'];
    final Object? c = row['contract_version'];
    if (s is! int || h is! int || c is! String) return null;
    final ContractVersion? v = ContractVersion.tryParse(c);
    if (v == null) return null;
    return ReadModelVersionStamp(
      schemaVersion: s,
      hashFormatVersion: h,
      contractVersion: v,
    );
  }

  /// 로컬 SQLite 스키마 번호.
  final int schemaVersion;

  /// X5-1 정규 직렬화 판.
  final int hashFormatVersion;

  /// 계약 판.
  final ContractVersion contractVersion;
}

/// 이 빌드에 컴파일된 스탬프.
ReadModelVersionStamp compiledVersionStamp() => ReadModelVersionStamp(
  schemaVersion: schemaVersion,
  hashFormatVersion: hashFormatVersion,
  contractVersion: ContractVersion.tryParse(contractVersion)!,
);

/// 게이트 판정(D17) — [remote] = 원격 스탬프(못 읽음 = null) · [local] = 이 빌드(기본 = 컴파일된 값).
ReadModelGate readModelGate(
  ReadModelVersionStamp? remote, {
  ReadModelVersionStamp? local,
}) {
  if (remote == null) return ReadModelGate.incompatible;
  final ReadModelVersionStamp me = local ?? compiledVersionStamp();
  if (remote.schemaVersion != me.schemaVersion) {
    return ReadModelGate.incompatible;
  }
  if (remote.hashFormatVersion != me.hashFormatVersion) {
    return ReadModelGate.incompatible;
  }
  if (remote.contractVersion.major != me.contractVersion.major) {
    return ReadModelGate.incompatible;
  }
  if (remote.contractVersion.minor > me.contractVersion.minor) {
    return ReadModelGate.degraded;
  }
  return ReadModelGate.ok;
}

/// 행 지도에서 곧장 판정한다(못 읽음 = incompatible).
ReadModelGate readModelGateOfRow(Map<String, Object?>? row) =>
    readModelGate(ReadModelVersionStamp.fromRow(row));

/// 🆕 E11-viewer-223(01 §8 미결 223 ⓔ) — 창구가 행을 못 읽었을 때의 게이트.
///
/// 🔴 [FormatException](열 없음 · 형 틀림 · 모르는 와이어 값 — `read_model_rows.dart`)= 스키마가 이 빌드와 어긋남 →
///    `incompatible`(잘못 그리는 것보다 안 그리는 것이 안전하다). 그 밖(행 없음 · 전송)은 게이트를 바꾸지 않는다.
ReadModelGate readModelGateAfter(ReadModelGate gate, Object error) =>
    error is FormatException ? ReadModelGate.incompatible : gate;
