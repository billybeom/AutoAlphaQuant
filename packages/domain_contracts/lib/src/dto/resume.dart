// packages/domain_contracts/lib/src/dto/resume.dart
//
// 01 §2-7 «PlannedWorkSummary · ResumeReport — X2 재개» + m2-8 D-4·D-5·D-6
// · 인벤토리 §3-4 · §3-14(영역 B).
//
// 🔴 재개 리포트는 **M5 소유 화면**이다(안전·마찰) — 다른 AI 는 이 DTO 를 읽을 수는
//    있으나 원본 화면을 렌더하지 않는다(01 §2-10 소유 표 · §7 C-7).
// 🔴 **손익 필드 없음**(청사진 X2 화면 · 결정 8).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall(🆕 v1.22 · K47 «1.22.0 VM 이 쓴다»)
import '../enums/resume.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart'; // LinkAction

part 'resume.freezed.dart';
part 'resume.g.dart';

/// Supabase 미러 목록 1행(01 §2-7).
///
/// 🔴 계획 **원문이 아니라** digest + 한 줄 요약뿐이다(X2 원칙 ②).
@freezed
abstract class PlannedWorkSummary with _$PlannedWorkSummary {
  const factory PlannedWorkSummary({
    required String workId,

    /// sha256 앞 12자
    required String digest,

    /// "10월말 슬리브 A 진입 게이트 판정" — 엔진 생성
    required String oneLine,
    @TradeDateConverter() required TradeDate dueBy,
    required PlannedWorkState state,
    required String stateLabel,
    required int rowVersion,
    required int leaseEpoch,
  }) = _PlannedWorkSummary;

  factory PlannedWorkSummary.fromJson(Map<String, dynamic> json) =>
      _$PlannedWorkSummaryFromJson(json);
}

/// 재개 리포트(01 §2-7).
///
/// 🔴 손익 필드 없음. 🔴 «램프»라는 낱말은 접두 없이 쓰지 않는다
///    («운영 램프» / «초기 진입» — 01 §2-6 말미 · M2-3 추가 검사).
@freezed
abstract class ResumeReport with _$ResumeReport {
  const factory ResumeReport({
    required String resumeRunId,
    required DateTime startedAt,
    DateTime? finishedAt,
    required int gapTradingDays,
    required ResumeMode mode,

    /// "7거래일 미실행 — RECOVERY_DRY" — 엔진 생성
    required String modeLabel,
    required ResumePhase phase,

    /// 실행/만료/대체/차단/복구불가
    required ResumeCounts counts,

    /// 항목별 계획 vs 재판정 vs 사유
    required List<ResumeItem> items,
    required List<DataGapRow> unrecoverableGaps,

    /// "7거래일 미실행: 실행 4 / 만료 3 / 대체 2 / 차단 1 / 복구 불가 2" — 엔진 생성
    required String headline,
  }) = _ResumeReport;

  factory ResumeReport.fromJson(Map<String, dynamic> json) =>
      _$ResumeReportFromJson(json);
}

/// 재개 집계 — `resume_run.counts` JSON 키 그대로(01 §6-3 · m2-8 D-4).
///
/// 🔴 화면이 합계를 만들지 않는다 — 표시 문장은 `ResumeReport.headline` 이다.
@freezed
abstract class ResumeCounts with _$ResumeCounts {
  const factory ResumeCounts({
    required int executed,
    required int expired,
    required int superseded,
    required int blocked,
    required int unrecoverable,
  }) = _ResumeCounts;

  factory ResumeCounts.fromJson(Map<String, dynamic> json) =>
      _$ResumeCountsFromJson(json);
}

/// 재개 항목 1행 — 계획 vs 재판정 vs 사유(01 §2-7 · m2-8 D-5).
///
/// `verdictCode` 5종은 영역 E 의 `labels/verdict_codes.dart` 가 정본이다(01 §3-3).
@freezed
abstract class ResumeItem with _$ResumeItem {
  const factory ResumeItem({
    required String workId,
    required String oneLine,

    /// 계획 시점의 한 줄 — 엔진 생성
    required String plannedLine,

    /// 재판정 결과의 한 줄 — 엔진 생성
    required String reevaluatedLine,
    required String verdictCode,
    required String verdictLabel,
  }) = _ResumeItem;

  factory ResumeItem.fromJson(Map<String, dynamic> json) =>
      _$ResumeItemFromJson(json);
}

/// 복구 불가 데이터 공백 1행 — `data_gap` 표 컬럼 1:1 + `label`(m2-8 D-6).
@freezed
abstract class DataGapRow with _$DataGapRow {
  const factory DataGapRow({
    required String gapId,
    required String dataset,
    @TradeDateConverter() required TradeDate from,
    @TradeDateConverter() required TradeDate to,
    required bool recoverable,
    required String reasonCode,

    /// "2026-08-24~08-28 일봉 없음 — 복구 불가" — 엔진 생성
    required String label,
  }) = _DataGapRow;

  factory DataGapRow.fromJson(Map<String, dynamic> json) =>
      _$DataGapRowFromJson(json);
}

/// 🆕 v1.22(01 §31 · K64) — X2 재개 게이트 한 화면(`x2ResumeGate` · 창구 = `ResumeGateRepository.watchGate()` · 🔒 `ui_safety`).
/// 🔴 머리·줄 = 엔진 `resume_text.dart` 문장 그대로 · 화면이 D+n · 모드 · 멈춤 사유를 계산하지 않는다.
/// 🔴 [lockedLabel] non-null ⇒ 모든 행 `actions` 빈(보기만 · 운영 등급 생체 축소 — 01 §8 미결 169).
@freezed
abstract class ResumeGateVm with _$ResumeGateVm {
  const factory ResumeGateVm({
    /// 엔진 `resumeHeadline`(집계 한 줄 + 멈춤 꼬리).
    required String headline,

    /// 엔진 `resumeModeLabel`(«n거래일 미실행 — 이름»).
    required String modeLabel,
    required UiLevel level,
    required List<ResumeGateRow> rows,

    /// 재개 리포트 링크(엔진 완성 · 목적지 = `AppRoutes.x2ResumeReport` · null = 버튼 부재).
    LinkAction? reportLink,
    String? lockedLabel,
    required AsOf asOf,
  }) = _ResumeGateVm;

  factory ResumeGateVm.fromJson(Map<String, dynamic> json) =>
      _$ResumeGateVmFromJson(json);
}
// JSON 키: headline · mode_label · level · rows · report_link · locked_label · as_of

/// 게이트 한 행 — 계획 한 건이 왜 서 있나(+ 사람이 고를 것).
@freezed
abstract class ResumeGateRow with _$ResumeGateRow {
  const factory ResumeGateRow({
    /// 🔴 화면은 읽지 않는다(시험 · 키 전용 — 호출 args 의 `work_id` 와 같다).
    required String workId,

    /// 엔진 생성 요약(`planned_work.one_line`).
    required String oneLine,

    /// ∈ `ResumeItemReasonCodes`(🔴 화면 분기 0).
    required String reasonCode,

    /// 엔진 `resumeReevaluatedLine` 글자.
    required String reasonLabel,
    required UiLevel level,

    /// 고를 것 — 계절 진입(`HUMAN_DECISION`)이면 엔진이 완성한 3택(`seasonalWindowChoice`) · 그 밖 빈.
    @Default(<SafetyActionCall>[]) List<SafetyActionCall> actions,
  }) = _ResumeGateRow;

  factory ResumeGateRow.fromJson(Map<String, dynamic> json) =>
      _$ResumeGateRowFromJson(json);
}
// JSON 키: work_id · one_line · reason_code · reason_label · level · actions
