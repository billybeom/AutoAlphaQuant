// packages/domain_contracts/lib/src/dto/ledger.dart
//
// 01 §2-9 «LedgerDiffRow — X5 정합 검사» + m2-8 E-9(`LedgerRepairRow`)
// · 인벤토리 §3-6 · §3-14(영역 B).
//
// 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도
//    주문을 막지 않는다** — 화면이 «매매 중단»으로 읽히는 문구를 만들지 않는다.
// 🔴 대조 보드의 칸 수는 모드와 무관하게 **5 고정**이고 `applicable == false` 인 칸은
//    «점검 안 함»으로 그린다(빈칸·통과로 그리지 않는다).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ledger.dart';
import '../primitives/money.dart';

part 'ledger.freezed.dart';
part 'ledger.g.dart';

/// 정합 검사 1행(01 §2-9).
@freezed
abstract class LedgerDiffRow with _$LedgerDiffRow {
  const factory LedgerDiffRow({
    required String diffId,
    required LedgerPair pair,
    required LedgerAxis axis,
    @TradeDateConverter() required TradeDate authoredDate,

    /// "069500 수량 −3주 (정본 120 / 브로커 123)" — 엔진 생성
    required String deltaLabel,
    required DiffSeverity severity,

    /// 원인 코드 후보(01 §3-4) — 문자열 상수의 정본은 영역 E 의 `labels/origin_codes.dart`
    required List<String> candidateOriginCodes,
    required DiffStatus status,
    required RepairRoute route,

    /// 🔴 브로커 근거 원문은 로컬 전용 — 외부엔 해시만
    required String evidenceHash,

    /// 🆕 X7(C15 · G-27) — 🔴 «해당 없음»과 «일치»를 가르는 값.
    /// 저장 컬럼은 01 §6-6 배치 F 의 `ledger_diff.applicable` 이다.
    required bool applicable,
  }) = _LedgerDiffRow;

  factory LedgerDiffRow.fromJson(Map<String, dynamic> json) =>
      _$LedgerDiffRowFromJson(json);
}

/// 정정 이력 1행 — `ledger_repair`(append-only)의 표시판(02 §8-1 · m2-8 E-9).
///
/// 🔴 `recomputedFrom` 이 C-29(소급 정정 시계열 재계산)의 표시 축이다 —
///    이 값이 있으면 «그 날짜부터 다시 계산됐다»가 보여야 한다.
/// 🔴 `directionCode` 는 `ledger_repair.direction` CHECK 2값
///    (`DERIVED_RESYNC`·`CANON_CORRECT`)이며 화면이 문구를 고르지 않는다.
@freezed
abstract class LedgerRepairRow with _$LedgerRepairRow {
  const factory LedgerRepairRow({
    required String repairId,
    required String diffId,
    required String directionCode,
    required String directionLabel,

    /// 원인 코드(01 §3-4)
    required String originCode,
    String? decisionId,
    required String evidenceHash,

    /// 이 정정이 대체한 앞선 정정 행
    String? supersedes,

    /// 🔴 소급 정정이면 여기부터 시계열을 다시 계산한다(C-29)
    @TradeDateConverter() TradeDate? recomputedFrom,
    required DateTime appliedAt,

    /// "브로커 기준으로 수량 정정 · 2026-08-24부터 재계산" — 엔진 생성
    required String label,
  }) = _LedgerRepairRow;

  factory LedgerRepairRow.fromJson(Map<String, dynamic> json) =>
      _$LedgerRepairRowFromJson(json);
}
