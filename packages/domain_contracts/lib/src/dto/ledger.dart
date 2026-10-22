// packages/domain_contracts/lib/src/dto/ledger.dart
//
// 01 §2-9 «LedgerDiffRow — X5 정합 검사» + m2-8 E-9(`LedgerRepairRow`)
// · 인벤토리 §3-6 · §3-14(영역 B).
//
// 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도
//    주문을 막지 않는다** — 화면이 «매매 중단»으로 읽히는 문구를 만들지 않는다.
// 🔴 대조 보드의 칸 수는 모드와 무관하게 **5 고정**이고 `applicable == false` 인 칸은
//    «점검 안 함»으로 그린다(빈칸·통과로 그리지 않는다).
// 🆕 계약 v1.12(01 §21 · R5 선행 · K25 · K26) — `L-1`·`L-2` 표시 계약: 짝 라벨·원인 후보 칩·표시 시각·조치 링크 ·
//    정정 행의 방향 색·대상 글자·체인 스탬프·결정 링크. 원값은 색·아이콘 exhaustive switch(C-12)와 들여쓰기
//    (`supersedes != null`)에만 쓰고 표시는 `*Label`·`*Text`·칩·링크뿐이다(C-47 ⑦).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ledger.dart';
import '../enums/ui.dart';
import '../primitives/money.dart';
import 'common.dart';

part 'ledger.freezed.dart';
part 'ledger.g.dart';

/// 정합 검사 1행(01 §2-9).
/// 🆕 v1.12 — `L-1` 이 그리는 것은 `*Label`·`*Text`·칩·링크뿐 · 원값(`pair`·`axis`·`severity`·`status`·`route`)은
///    색·아이콘 exhaustive switch 에만(C-12) · 원값 표시 허용 = `evidenceHash`(그대로)·`authoredDate.yyyyMmDd`(날짜 예외 —
///    v1.8 E4) · `candidateOriginCodes`·`diffId` = 🔴 ui 미참조(C-47 ⑦) · 🔵 폰 «브로커 근거 원문» = v1 부재(해시만 ·
///    두 플랫폼 같음 · K26).
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
    /// 🔴 ui 미참조(v1.12) — 표시는 [candidateOrigins].
    required List<String> candidateOriginCodes,
    required DiffStatus status,
    required RepairRoute route,

    /// 🔴 브로커 근거 원문은 로컬 전용 — 외부엔 해시만
    required String evidenceHash,

    /// 🆕 X7(C15 · G-27) — 🔴 «해당 없음»과 «일치»를 가르는 값.
    /// 저장 컬럼은 01 §6-6 배치 F 의 `ledger_diff.applicable` 이다.
    required bool applicable,

    // ── 🆕 계약 v1.12(01 §21 · K26) ─────────────────────────────────────────────
    /// "브로커 대조" — `DiagnosticCell.label`(`m8/recon_board_diff`) 과 같은 사전(C-47 ②).
    required String pairLabel,

    /// "수량" · "체결 건" · "현금" · "체인 해시".
    required String axisLabel,

    /// "주문 차단" · "관측 항목 — 주문을 막지 않습니다"(02 §5-1 상태).
    required String severityLabel,

    /// "열림" · "해소됨 · 2026-08-29" · "받아들임 · 2026-08-30"(🔴 accepted = resolved 와 같은 비중 · 02 §5-1).
    required String statusLabel,

    /// "자동 재동기화" · "승인 필요" · "X1 비상".
    required String routeLabel,

    /// 원인 후보 — 열람만(선택 UI·자유 서술 금지) · 칩 탭 = `detailDeepLink`(핸드북) · 받은 순서
    /// (== [candidateOriginCodes] 순서 · C-47 ②).
    required List<ReasonChip> candidateOrigins,

    /// 근거 카드 "탐지 2026-08-28 09:00" — 엔진.
    required String detectedAtText,

    /// 조치 1개(엔진이 고른다): `route == approval` ∧ 폰 = «정정하기» → `aaq://x5/repair-wizard` ·
    /// `pair == canonSelfReport` ∧ 폰 = «다시 실사하기» → `aaq://ledger/self-report/<yyyy-MM>/<별칭>`(02 §5-1 X7 추가 · K26) ·
    /// `SelfReportResult.diffs` 안 = null · 그 밖·뷰어 = null(부재). 해소(`M5-13`) = `SelfReportResult.resolveLink`.
    LinkAction? actionLink,
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
/// 🆕 v1.12(01 §21 · K24 · K25) — `L-2` 1행. 🔴 순서 = 엔진(시간 역순 묶음 · 정정의 정정은 그 원본 **바로 뒤** ·
///    02 §5-2 «원본 아래 계단식») · 들여쓰기 = `supersedes != null` 여부만(화면이 묶지 않는다) · 기존 [label](재계산
///    고지 · C-29)·[directionLabel] 은 그린다 · 원값(`appliedAt`·`directionCode`·`originCode`·`decisionId`·
///    `recomputedFrom`·`diffId`·`repairId`)은 ui 미참조.
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

    // ── 🆕 계약 v1.12(01 §21 · K25) ─────────────────────────────────────────────
    /// "2026-08-24 11:02 적용" — 엔진.
    required String appliedAtText,

    /// 방향 배지 색(파생 재생성 = 자동 / 정본 정정 = 승인) — 🔴 화면이 `directionCode` 를 비교하지 않는다.
    required ChipTone directionTone,

    /// 원인 코드의 글자(01 §3-4) — 🔴 해설 생성 금지(02 §5-2).
    required String originLabel,

    /// "069500 수량 120 → 123주" · `LEDGER_INTEGRITY` = "숨김"(엔진 · 02 §5-2 상태).
    required String targetText,

    /// → `J-2`(`aaq://journal/decision/<decisionId>`) · null = 결정 없음. 저널(`J-3R`) 링크 = v1 부재(01 §8 미결 121).
    LinkAction? decisionLink,

    /// "이후 정정됨" — non-null ⇔ 뒤 행 하나가 이 행을 `supersedes` 한다(엔진).
    String? supersededLabel,

    /// 체인 스탬프 축약("chn_7f3a…c2" — `chain_hash` 의 축약 · 🔴 `evidenceHash` 와 다른 값 · 엔진) — 표시·복사.
    required String chainStampText,
  }) = _LedgerRepairRow;

  factory LedgerRepairRow.fromJson(Map<String, dynamic> json) =>
      _$LedgerRepairRowFromJson(json);
}
