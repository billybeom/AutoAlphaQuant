// packages/domain_contracts/lib/src/dto/holdings.dart
//
// 01 §2-3 «HoldingRow — 보유현황 1행»(M6, 요구 3) + m2-8 D-7(`MomentumPanel`)
// · E-8(`StopLineNormalized`) · 인벤토리 §3-3 · §3-14(영역 B).
//
// 🔴 결정 8 — `HoldingPnl` 은 `watchHoldings(includePnl: true)` 일 때만 채워진다.
//    홈·알림·위젯·일지 타임라인에 이 타입을 렌더하면 §7 C-6 실패.
// 🔴 X7 D7 — 파생은 `positions` 만 읽는다. `external_holding`(= `scope == external`)의
//    표시 UNION 은 `HoldingsRepository` **한 곳**에서만 만든다(C-23).
// 🆕 v1.8(01 §17 · R4 선행) — `HoldingRow` +7 · `HoldingPnl` +2 · 화면 VM 4(`HoldingsOverviewVm`·
//    `HoldingsSleeveCard`·`HoldingsExternalSection` = `H6-1` · `HoldingDetailVm` = `H6-2`).

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';
import 'journal.dart';
import 'ledger_trust.dart';
import 'rebalance.dart';

part 'holdings.freezed.dart';
part 'holdings.g.dart';

/// 보유현황 1행(01 §2-3). 🆕 v1.8(01 §17) — 키 1 · 표시 문자열 4 · 칩 2 · 링크 1.
///
/// 🔴 v1.8 부터 `H6-1`·`H6-2` 가 그리는 것은 `*Text`·`*Label`·칩·배지뿐이다 — 원값
///    (`quantity`·`avgPrice`·`stopLine`·`pnl.unrealizedPnl`·`pnl.pnlPct`)과 키(`symbol`·`sleeve`·
///    `entryDecision`·`scope`)는 **ui 미참조**(C-44 ⑮). 가림(`RECON_MISMATCH` «?» · `LEDGER_INTEGRITY` «숨김»)은
///    엔진이 문자열 안에서 끝낸다(01 §11-2) — 화면은 `activeFlags` 로 값을 바꾸지 않는다.
/// 🔴 `H6-1` 목록(`HoldingsOverviewVm`)의 행은 늘 `scope == managed` 다 — 시스템 밖 자산은
///    `HoldingsExternalSection.rows`(`ExternalHoldingRow`)로 온다(K14).
@freezed
abstract class HoldingRow with _$HoldingRow {
  const factory HoldingRow({
    required String symbol, // 🔴 ui 미참조(C-44) — 표시는 [symbolLabel]
    required String symbolLabel,
    required SleeveId sleeve, // 🔴 ui 미참조 — 카드 자리는 엔진이 정한다
    /// "연금저축" — 🔴 계좌 전체번호 금지
    required String accountAlias,
    required int quantity, // 🔴 ui 미참조 — 표시는 [quantityText]
    /// 매수가 — 🔴 ui 미참조 — 표시는 [avgPriceText]
    @DecimalStringConverter() required Decimal avgPrice,

    /// 표시 = `entryDate.yyyyMmDd` 그대로(예외 1개 — `RebalanceEvent.tradeDate` 선례 · 날짜는 가림 대상 아님).
    @TradeDateConverter() required TradeDate entryDate,

    /// `positions.entry_decision_id` — 🔴 ui 미참조 — 이동은 `HoldingDetailVm.entryDecisionLink`
    required DecisionRef entryDecision,
    required List<ReasonChip> entryReasons,

    /// SMA 트랜치 진행 — 🆕 v1.8 표본 규칙: 슬리브 B 행에만 온다(P 회차 · 그 밖 = 빈 목록).
    required List<TrancheStep> smaTranches,
    required List<GateBadge> gates,

    /// 🔴 ui 미참조(v1.8) — 표시는 `HoldingDetailVm.stopLines`(글자 행 · 01 §17 · K3).
    StopLine? stopLine,

    /// 🔵 v2.31: 개별주 소멸 — 거의 항상 null · null 이면 모멘텀 패널 **부재**
    MomentumPanel? momentum,

    /// 🔴 기본 접힘(결정 8) · `includePnl: true` 일 때만 · 뷰어는 늘 null(K15)
    @Default(null) HoldingPnl? pnl,
    required HoldingScope scope, // 🔴 ui 미참조(H6)
    required String scopeLabel, // 🔴 ui 미참조(H6) — 시스템 밖 섹션 고지는 `HoldingsExternalSection.noticeText`
    required AsOf asOf,

    // ── 🆕 계약 v1.8(01 §17 · R4 선행) ─────────────────────────────────────
    /// 보유 1건의 키 — 엔진이 `positions (market, symbol, strategy_id)` 를 묶은 불투명 id.
    /// 🔴 표시 금지 · Key 문자열에도 넣지 않는다(Key = 순번 — C-44 ⑮ · §6) · 라우트 파라미터·family 키 전용. 같은 종목이 B 와 POT 에 함께 있을 수 있다 —
    ///    화면이 종목 코드로 행을 찾지 않는다.
    required String holdingId,

    /// "212주" · RECON 대상 "212주?" · INTEGRITY "숨김" — 천 단위·단위까지 엔진 완성.
    required String quantityText,

    /// "38,410원" · 가림 같은 규칙.
    required String avgPriceText,

    /// "비중 4.1%" — 회계 기준 총자산 대비(엔진 생성) · 가림 같은 규칙 · 🔴 화면이 비중을 계산·합산하지 않는다.
    required String weightText,

    /// "반영 대기 +12주"(02 §2-1 갈래 C — `H6-*` 의 칩 원천 · E15) — null = 칩 부재. 🔴 화면이 수량에 더하지 않는다.
    /// 가림 = 엔진: `LEDGER_INTEGRITY`(·`L-3` 세션) = null(칩 부재) · `RECON_MISMATCH` 대상 행 = 끝 «?»(C-44 ③).
    String? pendingText,

    /// "POT 서브북 · A 하위(연금저축)" — null = 칩 부재. POT 행을 A 카드에 넣는 것은 엔진이다(K17 ✅).
    String? subBookLabel,

    /// → `H6-2`(`aaq://holdings/detail/<holdingId>` — 엔진 완성). null = 행 탭 반응 없음.
    /// 🔴 `H6-2` 안에서는 쓰지 않는다(자기 자신 — `TradeJournalEntry.detailDeepLink` 규약).
    String? detailDeepLink,
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

/// 🔴 결정 8 — 종목 손익은 **별도 optional 필드**다. 기본 접힘, 손익 정렬·합계 미제공.
/// 🆕 v1.8 — 표시 문자열 2(원값 2 는 ui 미참조 · C-44 ⑮).
@freezed
abstract class HoldingPnl with _$HoldingPnl {
  const factory HoldingPnl({
    @DecimalStringConverter() required Decimal unrealizedPnl, // 🔴 ui 미참조
    required double pnlPct, // 🔴 ui 미참조
    /// "전일 종가 기준 · 평가 손익" — 엔진 생성 · 🔴 늘 함께 그린다(02 §2-3) · 열람 기록 문구 금지(결정 ⑤).
    required String disclosureNote,

    /// 🆕 v1.8 — "+158,420원" · INTEGRITY "숨김".
    required String pnlText,

    /// 🆕 v1.8 — "+1.93%" · INTEGRITY "숨김".
    required String pnlPctText,
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

/// 🆕 v1.8 — `H6-1` 보유현황 한 화면의 전부(01 §17). 창구 = `HoldingsRepository.watchHoldingsOverview`.
///
/// 🔴 카드 수 = [cards] 의 길이다 — 화면이 3 을 적지 않는다. 위성 플래그가 켜지면 엔진이 카드를 싣는다
///    (화면은 `FeatureFlags` 를 읽지 않는다 · C-44 ⑱).
/// 🔴 화면은 카드·행·섹션을 **받은 순서 그대로** 그린다 — 정렬(슬리브 → 비중 내림차순)·묶기·떼기는 엔진.
/// 🔴 합계(수량·비중·평가액·손익) 줄은 없다 — 만들지 않는다(02 §4-1 금지 ①③).
@freezed
abstract class HoldingsOverviewVm with _$HoldingsOverviewVm {
  const factory HoldingsOverviewVm({
    required List<HoldingsSleeveCard> cards,

    /// 시스템 밖 자산 섹션 — null = 섹션 **부재**(빈 섹션 금지).
    HoldingsExternalSection? external,

    /// 「비중 보기」 → `H6-3`(`aaq://holdings/allocation`). null = 버튼 부재.
    LinkAction? allocationLink,

    /// 종목 손익 펼침 토글 글자 — null = 토글 **부재**(뷰어 · K15). 펼침 = `includePnl: true` 재구독(02 §2-3).
    String? pnlToggleLabel,

    /// non-null ⇔ [cards] 가 빈 목록 — 화면은 이 문장**만** 그린다(다음 트랜치 안내도 이 안에 · 02 §4-1 P 회차).
    /// 🔴 «없음» 전용 — «모름»(첫 동기화 전·로컬 DB 미도착)에는 엔진이 값을 내지 않거나 스트림 에러로 준다(01 §11-10 · K26).
    String? emptyLabel,

    /// 헤더 기준일 고지 = `asOf.label` 그대로("잔고 기준 2026-08-31 종가 · 엔진은 일 1회 배치" — 02 §2-1 갈래 B).
    required AsOf asOf,
  }) = _HoldingsOverviewVm;

  factory HoldingsOverviewVm.fromJson(Map<String, dynamic> json) =>
      _$HoldingsOverviewVmFromJson(json);
}

/// 🆕 v1.8 — `H6-1` 슬리브 카드 1장.
@freezed
abstract class HoldingsSleeveCard with _$HoldingsSleeveCard {
  const factory HoldingsSleeveCard({
    required SleeveId sleeve, // 🔴 ui 미참조(C-44) — Key 는 카드 순번
    /// "A · 국내 지수 ETF" — 엔진 생성(`SleeveCatalogEntry.label` 과 같은 사전).
    required String titleText,

    /// 카드 머리 — 같은 화면의 `H6-3` 행과 **같은 값**(C-44 ⑥). 머리 큰 글자 = `allocation.sleeveWeight?.label`,
    /// 상태 = `bandStateLabel`(색 = `bandState`) · `sleeveWeight == null` 이면 `bandNoteText` 만(K27 권고상 A·C 카드가 이 갈래).
    required SleeveAllocationRow allocation,

    /// 펼침 = 종목 행 — 받은 순서(엔진 = 비중 내림차순 · POT 행은 A 카드 펼침 안 맨 끝 · `subBookLabel` 상시 동반 — K17 ✅).
    required List<HoldingRow> rows,

    /// non-null ⇔ [rows] 가 빈 목록 — "이 슬리브에 보유 종목이 없습니다".
    String? rowsEmptyText,
  }) = _HoldingsSleeveCard;

  factory HoldingsSleeveCard.fromJson(Map<String, dynamic> json) =>
      _$HoldingsSleeveCardFromJson(json);
}

/// 🆕 v1.8 — `H6-1` 시스템 밖 자산(수동) 섹션(02 §4-1 X7 · §8 행 15 — v1 = 접힘 섹션 + 고지 상시).
/// 🔴 관리 대상과 합계를 합치지 않는다(D7 · C-23) — 이 섹션에는 비중이 없다.
@freezed
abstract class HoldingsExternalSection with _$HoldingsExternalSection {
  const factory HoldingsExternalSection({
    /// "시스템 밖 자산(수동)" — 엔진 생성.
    required String titleText,

    /// "비중 계산에서 빠집니다" — 🔴 접혀 있어도 늘 그린다.
    required String noticeText,

    /// "대사 미확인" 배너 — null = 배너 부재(조건 = 엔진).
    String? bannerText,

    /// 받은 순서 · 비지 않는다(빈 섹션이면 [HoldingsOverviewVm.external] 이 null).
    required List<ExternalHoldingRow> rows,
  }) = _HoldingsExternalSection;

  factory HoldingsExternalSection.fromJson(Map<String, dynamic> json) =>
      _$HoldingsExternalSectionFromJson(json);
}

/// 🆕 v1.8 — `H6-2` 종목 상세 한 화면의 전부(01 §17). 창구 = `watchHoldingDetail(holdingId)`.
///
/// 🔴 손절까지 남은 폭·%를 화면이 계산하지 않는다 — v1 은 [stopLines] 글자 행만(K3 · 게이지 = 미결 104).
/// 🔴 화면은 `watchTimeline` 으로 이력을 조립하지 않는다 — 이력은 [recentEntries] 로 온다(K19).
@freezed
abstract class HoldingDetailVm with _$HoldingDetailVm {
  const factory HoldingDetailVm({
    /// 같은 `holdingId` 의 `H6-1` 행과 같은 값(손익 제외 — C-44 ④).
    required HoldingRow holding,

    /// "B · 해외 지수·금 ETF" — 엔진 생성.
    required String sleeveLabel,

    /// 「매수 결정 보기」 → `J-2`(`aaq://journal/decision/<id>` — 엔진 완성). 🔴 **늘 있다**(02 `H6-2` 수용 (c)
    /// «`entryDecision` 링크가 항상 동작» · K16 ⓔ) — `HoldingRow.entryDecision` 이 required 라 원천이 늘 있다.
    required LinkAction entryDecisionLink,

    /// 손절선 글자 행 — 받은 순서 · `levelText`·`tierLabel`·`basisLabel` 만 그린다(`level`·`tierCode` ui 미참조).
    /// 🔴 비었으면 [noStopLineText] 하나(0행 ⇔ non-null).
    required List<StopLineNormalized> stopLines,

    /// "이 슬리브는 개별 손절선을 쓰지 않습니다 — 리밸런싱 규칙으로 관리"(02 §4-2 «문구 M2»).
    String? noStopLineText,

    /// 이 보유의 최근 체결 — 엔진이 고르고 자른다(시간 역순 · 같은 `holdingId`) · 행 탭 = 행의 `detailDeepLink`(J-2).
    required List<TradeJournalEntry> recentEntries,

    /// non-null ⇔ [recentEntries] 가 빈 목록.
    String? recentEmptyLabel,

    /// [HoldingsOverviewVm.pnlToggleLabel] 과 같은 규칙(null = 토글 부재 · K15).
    String? pnlToggleLabel,
    required AsOf asOf,
  }) = _HoldingDetailVm;

  factory HoldingDetailVm.fromJson(Map<String, dynamic> json) =>
      _$HoldingDetailVmFromJson(json);
}
