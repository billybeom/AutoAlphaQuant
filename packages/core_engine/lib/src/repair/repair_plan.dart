// X5-3 정정 계획 — 기본 선택 · 대상 · «delta 같음» · 방향별 원인 코드 · `ledger_repair` 행 꼴
// (순수 · 설계 13 §8 R121 F3~F5 · 06 :294 · 08 그림 13-2 · SPEC v2.45 04 §3-1 ④).
//
// 🔴 «아무것도 안 하기»는 늘 고를 수 있다 · FILL_LAG 후보 · 현금 축(SETTLE_LAG)이면 그것이 기본.
// 🔴 정정 대상 = 불변 스트림(X5-1 해시 모집단)만 — 재계산 산출물은 엔진이 다시 도출한다.
// 🔴 append 직전 재대사 — 탐지 때 diff 가 그대로 없으면 거부(쓰기 0 · 새 diff 로 다시).
// 🔴 CANON_CORRECT = 결정 필수 · 원인 코드 = 방향별 목록.

import 'package:domain_contracts/domain_contracts.dart'
    show LedgerAxis, LedgerPair, OriginCodes;

import '../ops/ledger_hash.dart' show LedgerHashTable, kLedgerHashPopulationV1;
import '../ops/ledger_views.dart' show StoredLedgerDiff, candidatesOfDelta;
import '../orders/ledger_pairs.dart' show writableOriginCodesFor;

final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final RegExp _hex64 = RegExp(r'^[0-9a-f]{64}$');

/// 정정 방향(02 `ledger_repair.direction` CHECK).
enum RepairDirection {
  /// 파생 재생성(자동).
  derivedResync('DERIVED_RESYNC'),

  /// 정본 정정(승인).
  canonCorrect('CANON_CORRECT');

  const RepairDirection(this.wire);

  /// 저장 글자.
  final String wire;

  /// 저장 글자 → 값(모르면 [FormatException]).
  static RepairDirection parse(String w) => values.firstWhere(
    (RepairDirection d) => d.wire == w,
    orElse: () => throw FormatException('ledger_repair.direction', w),
  );
}

/// 마법사 선택.
enum RepairChoice {
  /// 아무것도 안 하기(`ledger_diff` ACCEPTED).
  doNothing,

  /// 정정한다.
  correct,
}

/// 정정 거부 코드(계약 등재 = E16i 전 문자열).
abstract final class RepairCodes {
  /// 탐지 때 diff 가 재대사에 없다(delta 가 바뀌었다).
  static const String deltaChanged = 'REPAIR_DELTA_CHANGED';

  /// 불변 스트림이 아닌 표.
  static const String targetNotImmutable = 'REPAIR_TARGET_NOT_IMMUTABLE';

  /// 이 방향 · 쌍에 쓸 수 없는 원인 코드.
  static const String originNotAllowed = 'REPAIR_ORIGIN_NOT_ALLOWED';

  /// 정본 정정인데 결정이 없다.
  static const String decisionRequired = 'REPAIR_DECISION_REQUIRED';

  /// 바뀌는 것이 없다.
  static const String noChange = 'REPAIR_NO_CHANGE';

  /// 🆕 E16f2 — 고를 diff 가 OPEN `CANON_BROKER` 가 아니다(R128 K8).
  static const String diffNotOpen = 'REPAIR_DIFF_NOT_OPEN';

  /// 🆕 E16f2 — 브로커 체결이 아니거나 없다(R128 K3).
  static const String fillNotBroker = 'REPAIR_FILL_NOT_BROKER';

  /// 🆕 E16f2 — 주문이 아직 열려 있다(체결 동기가 누적을 다시 센다 · R128 K4).
  static const String orderOpen = 'REPAIR_ORDER_OPEN';

  /// 🆕 E16f2 — 정정 전 재생이 저장 포지션과 다르다(R128 K7).
  static const String positionDrift = 'REPAIR_POSITION_DRIFT';

  /// 🆕 E16f2 — 정정 뒤 포지션이 중간에 음수가 된다(R128 K7).
  static const String positionNegative = 'REPAIR_POSITION_NEGATIVE';
}

/// 🔴 기본 선택 — FILL_LAG 후보 · 현금 축 = 아무것도 안 하기 · 그 밖 = 기본 없음(null · 사람이 고른다).
RepairChoice? defaultRepairChoiceOf(StoredLedgerDiff d) {
  if (d.axis == LedgerAxis.cash) return RepairChoice.doNothing;
  if (candidatesOfDelta(d.delta).contains(OriginCodes.fillLag)) {
    return RepairChoice.doNothing;
  }
  return null;
}

/// 정정할 수 있는 표 = X5-1 해시 모집단.
final Set<String> kRepairableTables = <String>{
  for (final LedgerHashTable t in kLedgerHashPopulationV1) t.table,
};

/// 🔴 [table] 을 정정 대상으로 삼을 수 있나 — 아니면 거부 코드.
String? repairTargetRejectCode(String table) =>
    kRepairableTables.contains(table) ? null : RepairCodes.targetNotImmutable;

/// 🔴 «delta 같음» — 탐지 diff id 가 재대사 diff id 들 가운데 있나(없으면 `REPAIR_DELTA_CHANGED`).
String? repairDeltaRejectCode({
  required String detectedDiffId,
  required Iterable<String> freshDiffIds,
}) => freshDiffIds.contains(detectedDiffId) ? null : RepairCodes.deltaChanged;

/// 새 기준점 원인 코드(04 §3-1 v2.45 ④).
const Set<String> kBaselineOriginCodes = <String>{
  OriginCodes.chainBroken,
  OriginCodes.schemaSkew,
  OriginCodes.dbError,
};

/// 소급 정본 사실이 부르는 파생 재생성 원인 코드.
const Set<String> kResyncCanonOriginCodes = <String>{
  OriginCodes.misrecordedFill,
  OriginCodes.externalCashflow,
  OriginCodes.corporateAction,
};

/// 🔴 방향별 원인 코드 — 정본 정정(대조) = 쌍의 쓰기 목록 − 파생 계열 · 파생 재생성 = 파생 ∪ 소급 정본 사실.
Set<String> repairOriginCodesFor(RepairDirection d, LedgerPair pair) =>
    switch (d) {
      RepairDirection.canonCorrect => writableOriginCodesFor(
        pair,
      ).difference(OriginCodes.derived),
      RepairDirection.derivedResync => <String>{
        ...OriginCodes.derived,
        ...kResyncCanonOriginCodes,
      },
    };

/// `ledger_repair` + `ledger_repair_detail` 한 행(쓰기 재료 · 🔴 append-only).
class LedgerRepairPlanRow {
  /// 만든다 — 꼴이 틀리면 [ArgumentError](CANON_CORRECT 결정 · 자기 자신 대체 · 날 · 체인).
  LedgerRepairPlanRow({
    required this.repairId,
    required this.diffId,
    required this.direction,
    required this.originCode,
    required this.evidenceHash,
    required this.appliedAtUtc,
    this.decisionId,
    this.supersedes,
    this.recomputedFrom,
    this.chainHash,
    this.targetJson,
    this.evidenceJson,
  }) {
    if (repairId.isEmpty || diffId.isEmpty || evidenceHash.isEmpty) {
      throw ArgumentError('repair_id · diff_id · evidence_hash 는 비울 수 없다');
    }
    if (direction == RepairDirection.canonCorrect &&
        (decisionId == null || decisionId!.trim().isEmpty)) {
      throw ArgumentError.value(decisionId, 'decisionId', 'CANON_CORRECT = 필수');
    }
    if (supersedes == repairId) {
      throw ArgumentError.value(supersedes, 'supersedes', '자기 자신');
    }
    if (recomputedFrom != null && !_day.hasMatch(recomputedFrom!)) {
      throw ArgumentError.value(recomputedFrom, 'recomputedFrom', '날 꼴');
    }
    if (chainHash != null && !_hex64.hasMatch(chainHash!)) {
      throw ArgumentError.value(chainHash!.length, 'chainHash', '16진 64');
    }
    if (!appliedAtUtc.isUtc) {
      throw ArgumentError.value(appliedAtUtc, 'appliedAtUtc', 'UTC');
    }
  }

  /// 정정 id.
  final String repairId;

  /// 정정한 diff(새 기준점 = 합성 `li-` id).
  final String diffId;

  /// 방향.
  final RepairDirection direction;

  /// 원인 코드.
  final String originCode;

  /// 근거 해시(밖으로 나가는 것은 이것뿐).
  final String evidenceHash;

  /// 적용 시각.
  final DateTime appliedAtUtc;

  /// 결정(정본 정정 = 필수).
  final String? decisionId;

  /// 대체하는 앞 정정(정정의 정정).
  final String? supersedes;

  /// 다시 센 첫 날(상세).
  final String? recomputedFrom;

  /// 적용 직후 체인(상세).
  final String? chainHash;

  /// 대상(상세 · 금액 0).
  final String? targetJson;

  /// 근거 원문(상세 · 🔴 로컬 전용).
  final String? evidenceJson;
}

/// 🔴 정정 행을 쓸 수 있나 — 원인 코드가 방향 · 쌍 목록 안에 있어야 한다.
String? repairOriginRejectCode(LedgerRepairPlanRow row, LedgerPair pair) =>
    repairOriginCodesFor(row.direction, pair).contains(row.originCode)
    ? null
    : RepairCodes.originNotAllowed;
