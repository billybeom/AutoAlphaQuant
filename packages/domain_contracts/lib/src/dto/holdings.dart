// packages/domain_contracts/lib/src/dto/holdings.dart
//
// 01 §2-3 «HoldingRow — 보유현황 1행»(M6, 요구 3) + m2-8 D-7(`MomentumPanel`)
// · E-8(`StopLineNormalized`) · 인벤토리 §3-3 · §3-14(영역 B).
//
// 🔴 결정 8 — `HoldingPnl` 은 `watchHoldings(includePnl: true)` 일 때만 채워진다.
//    홈·알림·위젯·일지 타임라인에 이 타입을 렌더하면 §7 C-6 실패.
// 🔴 X7 D7 — 파생은 `positions` 만 읽는다. `external_holding`(= `scope == external`)의
//    표시 UNION 은 `HoldingsRepository` **한 곳**에서만 만든다(C-23).

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';

part 'holdings.freezed.dart';
part 'holdings.g.dart';

/// 보유현황 1행(01 §2-3).
///
/// 🔵 슬리브 목록은 A / B / C 3칸이다(v2.31 P0S) — 목록의 정본은 `SleeveCatalogEntry` 다.
@freezed
abstract class HoldingRow with _$HoldingRow {
  const factory HoldingRow({
    required String symbol,
    required String symbolLabel,
    required SleeveId sleeve,

    /// "연금저축" — 🔴 계좌 전체번호 금지
    required String accountAlias,
    required int quantity,

    /// 매수가
    @DecimalStringConverter() required Decimal avgPrice,
    @TradeDateConverter() required TradeDate entryDate,

    /// `positions.entry_decision_id`
    required DecisionRef entryDecision,

    /// 매수 사유
    required List<ReasonChip> entryReasons,

    /// SMA 트랜치 진행
    required List<TrancheStep> smaTranches,

    /// 국면·진입 게이트 배지
    required List<GateBadge> gates,

    /// 손절선(트레일링·절대)
    StopLine? stopLine,

    /// 🔵 v2.31: 개별주 소멸 — 거의 항상 null
    MomentumPanel? momentum,

    /// 🔴 기본 접힘(결정 8)
    @Default(null) HoldingPnl? pnl,

    /// 🆕 X7 — managed / external
    required HoldingScope scope,

    /// "시스템 밖 자산(수동) — 비중 계산에서 빠집니다" — 엔진 생성
    required String scopeLabel,
    required AsOf asOf,
  }) = _HoldingRow;

  factory HoldingRow.fromJson(Map<String, dynamic> json) =>
      _$HoldingRowFromJson(json);
}

/// SMA 트랜치 1단계(01 §2-3).
@freezed
abstract class TrancheStep with _$TrancheStep {
  const factory TrancheStep({
    required int stepNo,
    required bool filled,

    /// "1/3 진입 (SMA200 상회)" — 엔진 생성
    required String label,
    @TradeDateConverter() TradeDate? filledOn,
  }) = _TrancheStep;

  factory TrancheStep.fromJson(Map<String, dynamic> json) =>
      _$TrancheStepFromJson(json);
}

/// 손절선(01 §2-3).
@freezed
abstract class StopLine with _$StopLine {
  const factory StopLine({
    /// TIER 1B
    @DecimalStringConverter() Decimal? absoluteStop,

    /// TIER 2 (단조 비감소)
    @DecimalStringConverter() Decimal? trailStop,

    /// TIER 1A ⚠️ 1차 릴리스에서 항상 null
    @DecimalStringConverter() Decimal? customStop,
    @DecimalStringConverter() Decimal? highWaterMark,

    /// "트레일링 −2.5×ATR(20)" — 엔진 생성
    required String label,
  }) = _StopLine;

  factory StopLine.fromJson(Map<String, dynamic> json) =>
      _$StopLineFromJson(json);
}

/// 🔴 결정 8 — 종목 손익은 **별도 optional 필드**다. 기본 접힘, 손익 정렬 미제공.
@freezed
abstract class HoldingPnl with _$HoldingPnl {
  const factory HoldingPnl({
    @DecimalStringConverter() required Decimal unrealizedPnl,
    required double pnlPct,

    /// "전일 종가 기준" — 엔진 생성
    required String disclosureNote,
  }) = _HoldingPnl;

  factory HoldingPnl.fromJson(Map<String, dynamic> json) =>
      _$HoldingPnlFromJson(json);
}

/// 모멘텀 패널 — `holding_signal_daily` 컬럼 1:1 (m2-8 D-7).
///
/// 🔵 v2.31 P0S 에서 **거의 항상 null** 이다(개별주 소멸).
@freezed
abstract class MomentumPanel with _$MomentumPanel {
  const factory MomentumPanel({
    /// `holding_signal_daily.momentum_12_1`(01 §6-1 배치 A) —
    /// 🔴 컬럼명이 `momentum_12_1` 이라 자동 snake 변환(`momentum121`)과 갈린다.
    @JsonKey(name: 'momentum_12_1') double? momentum121,
    @JsonKey(name: 'rs_rank') int? rsRank,
    @JsonKey(name: 'template_passed') bool? templatePassed,

    /// `failed_conditions`(JSON) — 🔴 문구는 엔진 생성
    required List<ReasonChip> failedConditions,
    required String label,
  }) = _MomentumPanel;

  factory MomentumPanel.fromJson(Map<String, dynamic> json) =>
      _$MomentumPanelFromJson(json);
}

/// 손절선 표시 정규화판(02 §8-1 · m2-8 E-8).
///
/// 🔴 `StopLine`(01 §2-3)을 **대체하지 않는다** — 표시용 정규화 1행이다.
/// 🔴 `levelText` 가 표시의 정본이고 `level` 은 정렬·대조용이다.
@freezed
abstract class StopLineNormalized with _$StopLineNormalized {
  const factory StopLineNormalized({
    /// 'TIER_1A' · 'TIER_1B' · 'TIER_2' (코드 목록은 영역 E 의 사전)
    required String tierCode,
    required String tierLabel,
    @DecimalStringConverter() Decimal? level,
    required String levelText,
    required bool isActive,
    required String basisLabel,
  }) = _StopLineNormalized;

  factory StopLineNormalized.fromJson(Map<String, dynamic> json) =>
      _$StopLineNormalizedFromJson(json);
}
