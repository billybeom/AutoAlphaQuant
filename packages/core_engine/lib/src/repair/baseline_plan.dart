// X5-3 새 기준점(재스탬프) 계획(순수 · 설계 13 §8 R121 F8 · 지도 e16-map D2 · SPEC v2.45 04 §3-1 ④).
//
// 🔴 경계(X5-5)가 X5 일 때만 — X1 조건이면 거부(비상 경로).
// 🔴 원인 = {CHAIN_BROKEN · SCHEMA_SKEW · DB_ERROR} ∩ 경계 후보 · 결정 필수 · 첫 어긋난 날 필수.
// 🔴 `diff_id` = 합성 `li-` id(`ledger_diff` 행이 없다 — FK 없음) · 근거 해시 = 옛 스탬프 JSON 의 `evidenceHashOf`.
//    새 체인은 그 날 이후를 다시 쓴 뒤 data_sync(E16f)가 채운다.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show BaselineResultCodes;

import '../ops/ledger_boundary.dart' show BoundaryPath, LedgerBoundaryVerdict;
import '../ops/ledger_integrity.dart' show StoredDayStamp;
import '../ops/ledger_views.dart' show evidenceHashOf;
import 'repair_plan.dart'
    show
        LedgerRepairPlanRow,
        RepairCodes,
        RepairDirection,
        kBaselineOriginCodes;

/// 새 기준점 거부 코드 — 🆕 E16j-a(01 §8 미결 212 ① repair 몫) 계약 사전 `BaselineResultCodes`(01 §38 · v1.30) 참조.
abstract final class BaselineCodes {
  /// 경계가 X5 가 아니다(X1 비상 경로 · 또는 깨끗함).
  static const String notX5 = BaselineResultCodes.notX5;

  /// 첫 어긋난 날을 모른다.
  static const String firstBadDateUnknown =
      BaselineResultCodes.firstBadDateUnknown;
}

/// 무결성 diff id — `li-` + sha256(`LEDGER_INTEGRITY|날|사유`) 앞 24(합성 · 행 없음).
String integrityDiffIdOf(String firstBadDate, String reasonWire) =>
    'li-${sha256.convert(utf8.encode('LEDGER_INTEGRITY|$firstBadDate|$reasonWire')).toString().substring(0, 24)}';

/// 옛 스탬프 근거 JSON(그 날 이후 · 날 차례 · 🔴 로컬 전용).
String oldStampsEvidenceJson(Iterable<StoredDayStamp> stamps, String fromDate) {
  final List<StoredDayStamp> s =
      stamps
          .where((StoredDayStamp x) => x.authoredDate.compareTo(fromDate) >= 0)
          .toList()
        ..sort(
          (StoredDayStamp a, StoredDayStamp b) =>
              a.authoredDate.compareTo(b.authoredDate),
        );
  return jsonEncode(<Object?>[
    for (final StoredDayStamp x in s)
      <String, Object?>{
        'date': x.authoredDate,
        'day_hash': x.dayHash,
        'chain_hash': x.chainHash,
        'format': x.hashFormatVersion,
      },
  ]);
}

/// 새 기준점 판정 — 거부 코드(경계 → 날 → 결정 → 원인 차례) · 통과 = null.
String? baselineRejectCode(
  LedgerBoundaryVerdict boundary, {
  required String? decisionId,
  required String originCode,
}) {
  if (boundary.path != BoundaryPath.x5Repair) return BaselineCodes.notX5;
  if (boundary.firstBadDate == null) return BaselineCodes.firstBadDateUnknown;
  if (decisionId == null || decisionId.trim().isEmpty) {
    return RepairCodes.decisionRequired;
  }
  if (!kBaselineOriginCodes.contains(originCode) ||
      !boundary.originCandidates.contains(originCode)) {
    return RepairCodes.originNotAllowed;
  }
  return null;
}

/// 🔴 새 기준점 계획 — `ledger_repair`(CANON_CORRECT) + 상세(다시 셀 첫 날 · 옛 스탬프) · 거부면 [StateError].
///
/// [chainHash] 는 비운다(다시 쓴 뒤 data_sync 가 채운다).
LedgerRepairPlanRow baselinePlanOf(
  LedgerBoundaryVerdict boundary, {
  required String repairId,
  required String? decisionId,
  required String originCode,
  required String reasonWire,
  required Iterable<StoredDayStamp> stamps,
  required DateTime appliedAtUtc,
}) {
  final String? reject = baselineRejectCode(
    boundary,
    decisionId: decisionId,
    originCode: originCode,
  );
  if (reject != null) throw StateError('새 기준점을 세울 수 없다: $reject');
  final String from = boundary.firstBadDate!;
  final String evidence = oldStampsEvidenceJson(stamps, from);
  return LedgerRepairPlanRow(
    repairId: repairId,
    diffId: integrityDiffIdOf(from, reasonWire),
    direction: RepairDirection.canonCorrect,
    originCode: originCode,
    evidenceHash: evidenceHashOf(evidence),
    appliedAtUtc: appliedAtUtc,
    decisionId: decisionId,
    recomputedFrom: from,
    evidenceJson: evidence,
  );
}
