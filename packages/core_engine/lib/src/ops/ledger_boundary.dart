// X5-5 X1 과의 경계 판정(순수 · 설계 13 §8 R112 E16a · 06 :290 · 지도 e16-map D2 · D4).
//
// 🔴 나쁜 쪽이 이긴다 — 파일 → PRAGMA → 스탬프 사슬 → 아카이브 관계 → 내용 → 형식 판 → CLEAN.
// 🔴 X1 = 원장 파일 자체를 믿을 수 없다(열리지 않음 · PRAGMA · 스탬프 사슬 끊김 · 아카이브 앞섬 · 갈라짐)
//    → 비상 경로 «안내까지만» · 자동 기동 0 · 이 파일에는 기동 · 복원 · 리스 조작 멤버가 없다.
// 🔴 X5 = 파일은 믿되 지난 기록이 스탬프와 다르다 → 정정 마법사(원인을 사람이 고른다).
// 🔴 아카이브 AHEAD = RESTORE_ROLLBACK(06 :290) = 파생 쪽 FORK(06 :289)와 같은 관측(D4).

import 'package:domain_contracts/domain_contracts.dart'
    show AppRoutes, OriginCodes, RepairRoute;

import 'derived_sync.dart' show DerivedRelation;
import 'ledger_integrity.dart'
    show LedgerIntegrityReason, LedgerIntegrityVerdict;

/// 경계 사유.
enum BoundaryReason {
  /// 원장 파일이 열리지 않았다.
  dbOpenFailed('DB_OPEN_FAILED'),

  /// `PRAGMA integrity_check` 가 ok 가 아니다.
  sqliteIntegrity('SQLITE_INTEGRITY'),

  /// 스탬프 사슬이 끊겼다(DATE_GAP · CHAIN_BROKEN).
  stampChainBroken('STAMP_CHAIN_BROKEN'),

  /// 정본이 아카이브보다 과거(아카이브 AHEAD).
  restoreRollback('RESTORE_ROLLBACK'),

  /// 아카이브와 갈라졌다(DIVERGED · EPOCH_AHEAD).
  archiveDiverged('ARCHIVE_DIVERGED'),

  /// 지난 기록이 스탬프와 다르다(DAY_HASH_MISMATCH · ROWS_BEFORE_FIRST_STAMP · ATTRIBUTION).
  contentMismatch('CONTENT_MISMATCH'),

  /// 스탬프 형식 판이 다르다.
  formatVersion('FORMAT_VERSION'),

  /// 깨끗하다.
  clean('CLEAN');

  const BoundaryReason(this.wire);

  /// 글자.
  final String wire;
}

/// 경계 길.
enum BoundaryPath {
  /// 할 일 없음.
  none,

  /// X5 정정 마법사.
  x5Repair,

  /// X1 비상 경로(안내까지만).
  x1Emergency,
}

/// X1 안내 문장.
const String kBoundaryX1Headline =
    '원장 파일을 믿을 수 없습니다 — 기기 이전(비상 경로)으로 검증된 백업을 복원해야 합니다. '
    '자동으로 다시 켜지 않습니다.';

/// 경계 판정 — 🔴 안내 재료만(기동 · 복원 · 리스 조작 0).
class LedgerBoundaryVerdict {
  const LedgerBoundaryVerdict._({
    required this.path,
    required this.reason,
    required this.originCandidates,
    required this.firstBadDate,
    required this.headline,
    required this.route,
    required this.guideLink,
  });

  /// 길.
  final BoundaryPath path;

  /// 사유.
  final BoundaryReason reason;

  /// 원인 후보(파일 · PRAGMA = 빈 목록 — diff 없이 플래그 사유만).
  final List<String> originCandidates;

  /// 처음 어긋난 날(모름 = null).
  final String? firstBadDate;

  /// 엔진 문장(CLEAN = 빈 글자).
  final String headline;

  /// 정정 경로(CLEAN = null).
  final RepairRoute? route;

  /// 안내 링크(CLEAN = null).
  final String? guideLink;
}

LedgerBoundaryVerdict _x1(
  BoundaryReason reason,
  List<String> candidates,
  String? firstBadDate,
) => LedgerBoundaryVerdict._(
  path: BoundaryPath.x1Emergency,
  reason: reason,
  originCandidates: List<String>.unmodifiable(candidates),
  firstBadDate: firstBadDate,
  headline: kBoundaryX1Headline,
  route: RepairRoute.x1Emergency,
  guideLink: AppRoutes.x1MigrationEmergency,
);

LedgerBoundaryVerdict _x5(
  BoundaryReason reason,
  List<String> candidates,
  String? firstBadDate,
  String cause,
) => LedgerBoundaryVerdict._(
  path: BoundaryPath.x5Repair,
  reason: reason,
  originCandidates: List<String>.unmodifiable(candidates),
  firstBadDate: firstBadDate,
  headline:
      '지난 기록이 스탬프와 다릅니다(${firstBadDate ?? '날 모름'} · $cause) — '
      '정정 마법사에서 원인을 고르십시오.',
  route: RepairRoute.approval,
  guideLink: AppRoutes.x5RepairWizard,
);

/// 🔴 X1 경계 판정 — 나쁜 쪽이 이긴다.
///
/// [dbOpened] = 원장 파일이 열렸나 · [integrity] = `verifyLedgerChain` 결과(열렸는데 null = [ArgumentError])
/// · [archiveRelation] = 아카이브 체크포인트 ↔ 정본 관계(모름 = null).
LedgerBoundaryVerdict ledgerBoundaryOf({
  required bool dbOpened,
  LedgerIntegrityVerdict? integrity,
  DerivedRelation? archiveRelation,
}) {
  if (!dbOpened) {
    return _x1(BoundaryReason.dbOpenFailed, const <String>[], null);
  }
  if (integrity == null) {
    throw ArgumentError.notNull('integrity');
  }
  final LedgerIntegrityReason? r = integrity.reason;
  final String? bad = integrity.firstBadDate;
  if (r == LedgerIntegrityReason.sqliteIntegrity) {
    return _x1(BoundaryReason.sqliteIntegrity, const <String>[], bad);
  }
  if (r == LedgerIntegrityReason.dateGap ||
      r == LedgerIntegrityReason.chainBroken) {
    return _x1(BoundaryReason.stampChainBroken, const <String>[
      OriginCodes.chainBroken,
    ], bad);
  }
  if (archiveRelation == DerivedRelation.ahead) {
    return _x1(BoundaryReason.restoreRollback, const <String>[
      OriginCodes.restoreRollback,
    ], null);
  }
  if (archiveRelation == DerivedRelation.diverged ||
      archiveRelation == DerivedRelation.epochAhead) {
    return _x1(BoundaryReason.archiveDiverged, const <String>[
      OriginCodes.chainBroken,
    ], null);
  }
  if (r == LedgerIntegrityReason.dayHashMismatch ||
      r == LedgerIntegrityReason.rowsBeforeFirstStamp ||
      r == LedgerIntegrityReason.attribution) {
    return _x5(
      BoundaryReason.contentMismatch,
      const <String>[OriginCodes.chainBroken, OriginCodes.dbError],
      bad,
      r!.code,
    );
  }
  if (r == LedgerIntegrityReason.formatVersion) {
    return _x5(
      BoundaryReason.formatVersion,
      const <String>[OriginCodes.schemaSkew],
      bad,
      r!.code,
    );
  }
  return const LedgerBoundaryVerdict._(
    path: BoundaryPath.none,
    reason: BoundaryReason.clean,
    originCandidates: <String>[],
    firstBadDate: null,
    headline: '',
    route: null,
    guideLink: null,
  );
}
