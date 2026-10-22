// 01 §2-11 — X7 투자 안내 뷰모델(안내 · 폼 선택지).
//
// 🔴 계산 산출물이므로 화면이 만들지 않는다(경계 규칙 ①).
// 🔴 금액 필드는 «가격»뿐이고 평가액·손익은 타입에 없다(결정 8).
// 🔴 A7 — `AdviceItem` 에 `mode`·`operatingMode` 필드를 두지 않는다. 모드가 표시에
//    영향을 주는 자리는 셸의 띠 하나뿐이고 그것은 `FeatureFlags` 가 담당한다.
// 🔴 §10-7 — viewer 판은 종목·수량·가격이 **오지 않는다**(A6 마스킹 · C-27).
// 🆕 계약 v1.12(01 §21 · R5 선행) — 버튼·카드의 목적지는 데이터로 온다(`AdviceAction.deepLink` ·
//    `AdviceItem.detailDeepLink` · K5) · 만료 확인 카드·수량 채우기·회수 문장·방향 글자 · 요약의 현금 고지·
//    «미확인 만료 n건»·안내 밖 기록 링크 · 폼 사양의 방향·거래일 선택지·`A-4` 문구·제출 차단 문장(K13~K22 · K37 ·
//    K39) · 🆕 `SideOption`·`TradeDateOption`. 🔴 새 이름은 쓰기 동사 접두를 피한다(C-7 `_writeVerb` · G57).
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/order.dart';
import '../enums/sleeve.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';
import 'ledger_trust.dart';

part 'advice.freezed.dart';
part 'advice.g.dart';

/// 01 §2-11 — 안내 1건.
/// 🔴 `kind == noAction` 이면 폰 판에서도 `symbol`·`quantity`·`side` 가 null 이고
///    `suppressed == true` · `suppressedLabel` 필수 · `actions` 는 빈 목록이다(G-08).
/// 🆕 v1.12(01 §21) — 🔴 `status`(저장값)·`closeReasonCode` = ui 미참조 · `effectiveStatus` 는 02 §8-14 의
///    «배지·정렬» 몫이지만 v1.12 는 배지 = `statusLabel`·`statusTone` · 정렬 = 엔진(K13 — 확인 카드 → `isUrgent`
///    → 나머지)이라 화면 분기 0(C-18 (d) · C-46 ⑱) · `onHold`·`suppressed` = 짝 글자(`holdReasonLabel`·
///    `suppressedLabel`)의 null 여부로만.
@freezed
abstract class AdviceItem with _$AdviceItem {
  const factory AdviceItem({
    required String adviceId,
    required String batchId,
    required AdviceKind kind,

    /// 안내가 겨냥한 거래일.
    @TradeDateConverter() required TradeDate tradeDate,
    required DateTime issuedAt,

    /// 🔴 거래일 달력. 화면이 D-day 를 세지 않는다.
    @TradeDateConverter() required TradeDate validUntilDate,

    /// "오늘 장 마감까지 · D-0" — 엔진 생성.
    required String validityLabel,

    /// 계열 표시용 — viewer 도 본다.
    required SleeveId sleeve,

    /// "3분할 중 2회차 · 12주" — 엔진 생성.
    /// 🔴 `unverifiable`·`drifting` 등급의 청산 안내는 수량 대신 «보유 전량» 계열
    ///    표현이 오며, 바뀌는 것은 라벨뿐이고 `quantity` 는 엔진이 아는 최선의
    ///    원장값으로 채운다(G-85).
    required String sizingLabel,

    /// "12주 중 7주 기록됨" — 엔진 생성.
    /// 🔴 viewer 판은 `phoneOnlyLabel` 과 같은 고정 문장이다(G-21).
    required String progressLabel,

    /// 진입 사유 / 청산 티어 — 🔴 최소 1개.
    required List<ReasonChip> reasons,

    /// 🔴 저장값. 화면은 배지·정렬에도 이것을 쓰지 않는다.
    required AdviceStatus status,

    /// 🔴 만료는 UPDATE 가 아니라 **파생 판정**이다(A4). 화면이 쓰는 유일한 값.
    required AdviceStatus effectiveStatus,
    required String statusLabel,
    required ChipTone statusTone,

    /// 🔴 A8 — 버튼의 유일한 근거. 상태를 조합해 버튼을 판정하지 않는다.
    /// 🆕 v1.12(K5) — 엔진은 RECORD·SKIP 만 싣는다(DETAIL 0 — 상세 = [detailDeepLink]) · viewer 판 = **빈 목록**
    ///    (K6 · 01 §6-4 rm_advice) · 배치 결측(`AdviceInboxSummary.staleLabel` non-null) = RECORD 만(K41).
    required List<AdviceAction> actions,

    /// 🔴 A1 — «안내와 다름»은 명령 집행 후 엔진이 **사후** 재발행으로 싣는다.
    required List<ReasonChip> recordedDeviationChips,

    /// 🔴 손절 계열 — 알림 등급의 근거. 화면은 배지만 그린다.
    required bool isUrgent,

    /// 선행 미이행이면 보류.
    required bool onHold,

    /// decision_log 체인 — 자동 모드와 **같은 타입**.
    required DecisionRef decision,

    /// 🔴 엔진이 안내를 낼 수 없는 상태.
    required bool suppressed,

    /// 🔴 G-86 — 만료 확인 카드의 「내일 다시」 노출 여부. **엔진 판정**이며
    ///    화면이 «몇 번 미뤘나»를 세지 않는다(저장 정본은
    ///    `advice_transition(cause_code='DEFER_CONFIRM')` 행의 존재 자체다).
    required bool deferAvailable,
    required AsOf asOf,

    /// 🔴 viewer 판은 null(A6) · `kind == noAction` 이면 폰 판도 null(G-08).
    String? symbol,
    String? symbolLabel,

    /// "종목·수량은 운영 폰에서 확인합니다" — 엔진 생성.
    String? phoneOnlyLabel,
    OrderSide? side,
    int? quantity,

    /// 🔴 viewer 판은 null · null 이면 라벨이 그 사실을 말한다.
    AdvicePriceBand? priceBand,

    /// 지금까지 기록된 합 — 🔴 화면이 더하지 않는다.
    /// 🔴 viewer 판은 null(0 을 채우면 「0주 기록됨」이라는 거짓이 된다 · G-22).
    int? recordedQuantity,

    /// skipped·expired·superseded·revoked 의 사유 코드.
    String? closeReasonCode,

    /// 🔴 조달 순서 의존(`PENSION_FUNDING` · X2 «매도 먼저»).
    String? dependsOnAdviceId,
    String? holdReasonLabel,

    /// "연금저축" — 🔴 계좌 전체번호 금지.
    String? accountAlias,

    /// "골든벡터 재검증 실패 — 오늘은 아무것도 하지 마십시오" 계열.
    String? suppressedLabel,

    // ── 🆕 계약 v1.12(01 §21 · R5 선행) ──────────────────────────────────────────
    /// 카드 탭 → `A-2`(`aaq://advice/detail/<adviceId>` — 엔진 완성 · K5). 🔴 전 플랫폼(뷰어 포함).
    required String detailDeepLink,

    /// "매수" — 🔴 viewer 판·`kind == noAction` 은 null([side] 와 같이 비운다 · §10-7 · K16).
    String? sideLabel,

    /// non-null ⇔ `A-1` 상단 **만료 확인 카드**로 그린다("혹시 이미 매매하셨나요?" — 엔진 · K13).
    /// 🔴 엔진이 고른다: `effectiveStatus == expired` · 미분류 · X2 일괄 만료 아님 · **최대 3장** · 목록 **맨 앞**(02 §3-6 C16).
    /// 🔴 확인 카드 밖의 미분류 만료는 `watchInbox` 행에 **오지 않는다** — `AdviceInboxSummary.overdueUnrecordedLink` 1줄과
    ///    `watchHistory` 에만 있다. 확인 카드의 [actions] == [RECORD, SKIP](순서까지).
    String? expiredConfirmLabel,

    /// → `J-2`(`aaq://journal/decision/<decision.decisionId>` — 엔진 완성 · K18). `A-2` 「결정 당시 스냅샷」 = 이 링크 1개 ·
    /// 뷰어 non-null(`journalDecision` = 전 플랫폼 목적지 · K6).
    LinkAction? decisionLink,

    /// `A-3` 「안내 수량 채우기」 — 입력칸에 넣을 원문("200"). 🔴 [prefillQuantityLabel] 과 둘 다 null 이거나 둘 다 non-null ·
    ///    폰 판 · `effectiveStatus ∈ {open, partial}` 만(엔진 · K19). 누르면 `ManualFillInput.prefilledFields` 에
    ///    `ManualFillPrefillFields.quantity` 를 더한다(A1 · 02 §3-8).
    String? prefillQuantityText,

    /// "안내 수량(200주) 채우기" — 엔진.
    String? prefillQuantityLabel,

    /// non-null ⇔ [closeReasonCode] non-null — 닫힌 사유의 엔진 문장(회수 = «사람 잘못이 아닙니다» 계열 · B8 · K39).
    String? closeReasonLabel,
  }) = _AdviceItem;

  factory AdviceItem.fromJson(Map<String, dynamic> json) =>
      _$AdviceItemFromJson(json);
}

/// 01 §2-11 A8 — 화면은 이 목록을 «순서대로 그리기»만 한다. 없으면 버튼을
/// 만들지 않는다. 🔴 `status`·`effectiveStatus`·`onHold`·`suppressed` 를 조합해
/// 버튼을 판정하지 않는다(조합이 7×2×2×4다).
/// 🆕 v1.12(01 §21 · K5) — 버튼의 목적지는 데이터로 온다(01 §11-1 규칙 ③). 🔴 엔진은 RECORD·SKIP 만 싣는다
///    (DETAIL 0 — 상세 = [AdviceItem.detailDeepLink]) · viewer 판 `actions` = 빈 목록(01 §6-4 · K6).
@freezed
abstract class AdviceAction with _$AdviceAction {
  const factory AdviceAction({
    /// 🔴 ui 미참조(v1.12) — 버튼 = [label] + [deepLink].
    required AdviceActionId actionId,

    /// 엔진 생성.
    required String label,
    required bool enabled,

    /// 엔진 생성 — `enabled == false` 일 때만.
    String? disabledReasonLabel,

    /// 🆕 v1.12 — RECORD → `aaq://advice/fill/<adviceId>` · SKIP → `aaq://advice/skip/<adviceId>`(엔진 완성).
    /// `enabled == false` 여도 있다(누르면 열지 않을 뿐).
    required String deepLink,
  }) = _AdviceAction;

  factory AdviceAction.fromJson(Map<String, dynamic> json) =>
      _$AdviceActionFromJson(json);
}

/// 01 §2-11 — 지정가 밴드. 🔴 `reference` 가 이행 갭의 기준가다.
@freezed
abstract class AdvicePriceBand with _$AdvicePriceBand {
  const factory AdvicePriceBand({
    @DecimalStringConverter() required Decimal low,
    @DecimalStringConverter() required Decimal high,
    @DecimalStringConverter() required Decimal reference,

    /// "38,100 ~ 38,400 지정가" — 엔진 생성.
    required String label,
  }) = _AdvicePriceBand;

  factory AdvicePriceBand.fromJson(Map<String, dynamic> json) =>
      _$AdvicePriceBandFromJson(json);
}

/// 01 §2-11 — 홈 한 줄·알림 앵커·`A-1` 헤더가 **같은 값**을 본다. 🔴 손익 필드 없음.
/// 🔴 `openCount == 0` 이면 홈 블록·배지를 렌더하지 않는다(C14·D16). 예외는 둘 —
///    `hasSuppressedNotice == true` 와 `handoverCoolingActive == true`.
@freezed
abstract class AdviceInboxSummary with _$AdviceInboxSummary {
  const factory AdviceInboxSummary({
    required String batchId,
    @TradeDateConverter() required TradeDate tradeDate,

    /// G-08 정의 — `effectiveStatus ∈ {open, partial}` 이고 `suppressed == false`
    /// 인 안내의 수. `onHold == true` 는 세고 `suppressed == true` 는 세지 않는다.
    /// 🔴 화면이 이 정의를 재구현하지 않는다(목록 길이로 세지 않는다).
    required int openCount,
    required int dueTodayCount,

    /// 🔴 C14 의 예외 ① — 「오늘은 아무것도 하지 마십시오」는 무소식이 아니다.
    required bool hasSuppressedNotice,

    /// 🔴 표류의 선행 지표(만료 미확인 건수).
    required int overdueUnrecordedCount,

    /// "9월 7일 매매 안내 3건 · 미기록 1건" — 엔진 생성.
    required String headline,

    /// 🔴 색의 근거. 값의 부호로 고르지 않는다.
    required UiLevel level,

    /// 🔴 C14 의 예외 ② — 전환 냉각 24h 창(N-1). 화면이 위저드 상태·
    ///    `handover_session` 을 직접 읽어 배너를 만들지 않는다.
    required bool handoverCoolingActive,
    required LedgerTrustBadge trust,
    required AsOf asOf,
    String? dueSoonLabel,

    /// 🔴 A4 — 엔진이 멈추면 안내의 유효성을 보증하지 않는다.
    /// 🆕 v1.12(K41) — [staleLabel] non-null ⇒ 전 행 `actions` ⊆ {RECORD}(엔진 의무 · 02 §3-6 «`A-3` 기록 경로는
    ///    살아 있다») · 킬스위치 = [headline] 에 «신규 안내 중단» 문장 + 행 `statusTone`(엔진 · 화면은 킬스위치를 읽지 않는다).
    String? staleReasonCode,
    String? staleLabel,
    String? handoverCoolingLabel,

    // ── 🆕 계약 v1.12(01 §21) ────────────────────────────────────────────────────
    /// `A-1` 상단 ② 현금 추정 고지(02 §3-6 · K15). null = 부재.
    CashEstimateNotice? cashNotice,

    /// «미확인 만료 n건» 1줄(라벨 = 엔진 · → `aaq://advice/history` · K13 · K38).
    /// null ⇔ 확인 카드 밖 미분류 만료 0(= [overdueUnrecordedCount] 가 확인 카드 수를 넘지 않는다).
    LinkAction? overdueUnrecordedLink,

    /// 하단 「안내에 없는 매매를 기록합니다」(→ `aaq://m5/intervention` · `M5-6` · K17). 뷰어·autoTrade = null.
    LinkAction? manualEntryLink,

    /// 그 링크 앞 엔진 문구("이 기록은 안내 밖 매매로 남고 재량 예산 4회 중 1회를 씁니다"). [manualEntryLink] 와 짝.
    String? manualEntryNoticeText,
  }) = _AdviceInboxSummary;

  factory AdviceInboxSummary.fromJson(Map<String, dynamic> json) =>
      _$AdviceInboxSummaryFromJson(json);
}

/// 01 §2-11 — 수기 체결 기록 폼 규격(`A-3`).
/// 🔴 A16 — 창구는 **Stream** 이며 신선도 초과면 화면이 폼을 열지 않는다.
/// 🔴 A3 — `amendReasons`·`voidReasons` 는 여기 **없다**(정정·무효는 `M5-12` 소유).
/// 🔴 B5 — 시간외·단주 힌트도 **없다**(검증 강도를 사람이 고르지 않는다 — 재제출 선택지는
///    `CommandReceipt.retryCode`·`retryLabel` 로 거부 뒤에만 온다 · 🆕 v1.12 K20).
/// 🆕 v1.12(01 §21 · K37) — 🔴 [minTradeDate]·[maxTradeDate]·[nonTradingDates]·[quantityMax] = ui 미참조(엔진·구현
///    검증용 · 수량 상한 초과 = 구현 `INPUT_INVALID`) · 화면은 [sides]·[tradeDateOptions] 를 그대로 고르게 한다.
@freezed
abstract class ManualFillFormSpec with _$ManualFillFormSpec {
  const factory ManualFillFormSpec({
    /// 매핑된 종목만 — 🔴 자유 티커 입력 금지.
    required List<SymbolOption> symbols,

    /// 별칭만.
    required List<AccountOption> accounts,
    required List<ReasonOption> skipReasons,
    @TradeDateConverter() required TradeDate minTradeDate,
    @TradeDateConverter() required TradeDate maxTradeDate,

    /// 🔴 「토·일 제외」 근사는 임시공휴일에 틀린다.
    @TradeDateConverter() required List<TradeDate> nonTradingDates,

    /// "1주당 원화. 세금·수수료는 비워 두면 추정합니다" — 엔진 생성.
    required String priceHintLabel,

    /// 오입력 방어(0 하나 더 찍기).
    required int quantityMax,

    /// "원본은 지워지지 않습니다" — 엔진 생성.
    required String appendOnlyNotice,
    required AsOf asOf,

    // ── 🆕 계약 v1.12(01 §21 · K37 · K21) ─────────────────────────────────────────
    /// `A-3` 방향 선택지("매수"·"매도"). 선택 = `option.side` 그대로(화면이 `OrderSide.*` 를 적지 않는다).
    required List<SideOption> sides,

    /// 고를 수 있는 거래일(엔진이 [minTradeDate]~[maxTradeDate] 에서 휴장일을 뺀다 · 받은 순서). 선택 = `option.date` 그대로.
    required List<TradeDateOption> tradeDateOptions,

    /// `A-4` 제출 전 엔진 문구 1줄("이 안내는 오늘로 닫히고, 다음 배치는 지금 보유 상태로 다시 계산합니다" · 02 §3-9).
    required String skipNoticeText,

    /// non-null = 제출 **부재** + 이 문장(`LEDGER_FIX` 등 · K21). 🔴 화면이 `SafetyState` 로 끄지 않는다.
    String? blockedText,

    /// 폼 고유 배너 1(킬스위치·HALT 중 «시스템 정지 중의 개입으로 남습니다»(B9) · `LEDGER_INTEGRITY` 격리 고지(B18)).
    /// 🔴 §2-2 안전 배너(`BlockFlag`)와 겹치지 않는다 — 그것은 `journalSafetyStateProvider` + `JournalSafetyBanners` 가 그린다.
    String? bannerText,
  }) = _ManualFillFormSpec;

  factory ManualFillFormSpec.fromJson(Map<String, dynamic> json) =>
      _$ManualFillFormSpecFromJson(json);
}

/// 01 §2-11 · m2-8 H-4 — 폼 선택지 3형제 ①.
@freezed
abstract class SymbolOption with _$SymbolOption {
  const factory SymbolOption({
    required String symbol,
    required String label,
    required SleeveId sleeve,
  }) = _SymbolOption;

  factory SymbolOption.fromJson(Map<String, dynamic> json) =>
      _$SymbolOptionFromJson(json);
}

/// 01 §2-11 · m2-8 H-4 — 폼 선택지 3형제 ②. 🔴 계좌 전체번호 금지.
@freezed
abstract class AccountOption with _$AccountOption {
  const factory AccountOption({required String alias, required String label}) =
      _AccountOption;

  factory AccountOption.fromJson(Map<String, dynamic> json) =>
      _$AccountOptionFromJson(json);
}

/// 🆕 v1.12(01 §21 · K37) — `A-3` 방향 선택지. 선례 `SymbolOption{symbol, label}`·`AccountOption{alias, label}`
/// («선택지 = 값 + 글자»).
@freezed
abstract class SideOption with _$SideOption {
  const factory SideOption({required OrderSide side, required String label}) =
      _SideOption;

  factory SideOption.fromJson(Map<String, dynamic> json) =>
      _$SideOptionFromJson(json);
}

/// 🆕 v1.12(01 §21 · K37) — 거래일 선택지("8/28(금)" — 엔진). 🔴 화면은 날짜를 만들거나 비교하지 않는다
/// (`DateTime.parse`·서식·`showDatePicker` 0 · C-46 ⑲).
@freezed
abstract class TradeDateOption with _$TradeDateOption {
  const factory TradeDateOption({
    @TradeDateConverter() required TradeDate date,
    required String label,
  }) = _TradeDateOption;

  factory TradeDateOption.fromJson(Map<String, dynamic> json) =>
      _$TradeDateOptionFromJson(json);
}

/// 01 §2-11 · m2-8 H-4 — 폼 선택지 3형제 ③.
/// ⏸ m2-8 H-5 — `J-3` 의 `rule_cited` 목록과 **통합한다**(같은 타입을 쓴다).
///    통합 여부 자체는 §8-20 · D19 의 선행 미결이며, 통합 전까지 사유 목록이 두
///    벌이 되어 한쪽만 갱신되는 사고를 막는 것이 이 결정의 이유다.
@freezed
abstract class ReasonOption with _$ReasonOption {
  const factory ReasonOption({
    required String code,
    required String label,

    /// 🔴 예산 코드 2종은 1줄 메모가 필수다(§3-8 `SKIP_NOTE_REQUIRED`).
    /// 🆕 v1.12(K22) — 정본 = 02 §3-9 표(예산 2종만 true · 나머지 1탭) — 옛 주석 «`other` 계열·» 삭제.
    required bool requiresNote,

    /// 🆕 v1.12(01 §21 · K12) — non-null = 명령 없이 이 링크로 push(`A-4` 예산 코드 2종 → `aaq://m5/intervention`).
    /// null = 1탭 제출(`skipAdvice`). 🔵 `J-3` `ruleCitedOptions` 는 늘 null.
    String? deepLink,
  }) = _ReasonOption;

  factory ReasonOption.fromJson(Map<String, dynamic> json) =>
      _$ReasonOptionFromJson(json);
}
