// 🆕 E11q-q4a — M6 매매일지 «읽기» VM(J-1 타임라인 · 필터 · 배지 · J-2 거래 상세 · J-3R 사전 저널 읽기 · 회차 범위) ·
// 기간 프리셋 · 슬리브 목록(설계 13 §8 · 나눔 계획 R169 q4a · 01 §2-2 · §12-2 · §15-3 · 02 §3-1~3).
//
// 🔴 일지 행 1 = 주문 의도 1(`order_intents` · 표본 `journal_30` 꼴 — 의도 id · 체결 수량 합 · 마지막 체결) ·
//    J-2 체결 행 1 = 체결 1(`executions` · 표본 `decision_detail_partial` 꼴). 행을 지어내지 않는다 — 원천 없는 상태
//    (이중 발주 차단 `PREVENTED` = 새 의도 행 0 · 원장에 기록 0)는 내지 않는다.
// 🔴 결정 키 = 의도의 `decision_id`(`{논리 id}@{집행일}` · H6-2 «매수 결정 보기» 링크와 같은 키). 한 결정에 의도가 여럿
//    (같은 날 같은 논리 결정의 여러 종목)이면 J-2 머리 = 첫 의도(기록 시각 · 의도 id 순) · 체결 = 그 결정의 체결 전부.
// 🔴 회차 묶음 = 엔진(`journalEventIdOf`) — 의도 논리 id 조각이 회차의 논리 id 묶음(월말 = 계획 스냅샷 대상 ·
//    계절 = 판정 결정 · POT 청산)에 들어 있으면 그 회차. 화면 · `orderIntentIds` 순회 0.
// 🔴 정렬 = 거래일 · 기록 시각 · 의도 id 내림차순(시간 역순 — 화면 정렬 0) · 페이징 = `limit` 하나(봉투 `hasMore`).
// 🔴 가림 = 엔진이 글자 안에서 끝낸다 — `LEDGER_INTEGRITY` = 수량 · 가격 · 비용 «숨김» · `RECON_MISMATCH` = 수량 끝 «?»(01 §2-10 · q1 꼴).
// 🔴 링크 = 조립 앱에 본문이 등록된 화면만(S01 원칙) — 상세 · 회차 · 저널 읽기 · 미해소 보드.
// 🔴 글자 = 계약 표본 문장 그대로(«(합성)»만 뺀다 · 표본 개정 0) · 표본에 없는 갈래(진행 중 · 취소 · 건너뜀 · 거부 머리)는 이 파일의 글자표.
// 🆕 E11q-q4b — J-5 미해소 보드(`unknownBoardVmOf` · UNKNOWN 의도 = 카드 · 4단계 · 경과 = 거래일 달력 · 장기 강조 = 엔진 임계).
// 🔵 운영 폰의 일지 = 엔진이 지금 쓰는 원장 한 파일(모의 기간 = 모의 원장 · 파일이 모드 경계 · 01 §9-1) — 행마다 `mode` 가
//    모의 배지를 말한다. `watchTimeline(mode:)` 인자는 J-1 이 넘기지 않는다(01 §8 미결 89) → 조립 앱이 원장 축을 따른다.
// 🆕 E11q-j4 — J-4 blind 리뷰 대상(`blindReviewTargetsOf` · 06 M1-25 ② ③ · 01 §16 K3 ⓐ ⓑ ⓓ · K4 · K24) · J-1 «리뷰 대기 n건» 배지
//    (n = 대상 수 · 0 = 배지 부재). 카드 · 큐 VM = `blind_review_view.dart`.

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        BackdateStamp,
        ChipTone,
        CostSource,
        DateRange,
        DecisionChainStageCodes,
        DecisionChainStep,
        DecisionDetailVm,
        DecisionJournalBody,
        DecisionJournalVm,
        DecisionRef,
        DecisionSnapshot,
        DeviationBadge,
        EmptyKind,
        FillKind,
        FillOrigin,
        FillOriginOption,
        FillVisibility,
        GateState,
        JournalBadgeCodes,
        JournalFilterCatalog,
        JournalReasonCodes,
        JournalRebalanceScope,
        JournalStatus,
        JournalStatusOption,
        JournalTimelineBadge,
        LinkAction,
        ListResult,
        OrderSide,
        ReasonChip,
        RejectTrace,
        RunMode,
        SafetyCheckLevelCodes,
        SleeveCatalogEntry,
        SleeveId,
        SymbolOption,
        ThresholdCompare,
        TradeDate,
        TradeJournalEntry,
        TriggerSnapshot,
        UnknownBoardVm,
        UnknownResolutionItem,
        UnknownResolutionStageCodes,
        UnknownResolutionStep;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar;
import '../calendar/next_rebalance.dart' show nextRegularExecutionSession;
import '../orders/order_draft.dart' show P0sStrategyIds;
import '../whatif/what_if_config.dart' show WhatIfConfig;
import '../whatif/what_if_text.dart' show commaWonText;
import 'journal_draft.dart' show journalRuleCitedLabelOf;
import 'ledger_views.dart' show kstDateText, kstMinuteText;
import 'monthly_report.dart'
    show MonthlyReportReadiness, monthlyReportReadinessOf;
import 'ops_home.dart' show opsDDayText;
import 'rebalance_events_view.dart' show RebalanceEventTexts;

/// 일지 기준 유효 시간(표본 `stale_after_seconds` 93600 = 26시간).
const Duration kJournalStaleAfter = Duration(hours: 26);

/// 일지 글자(표본에 있는 것은 표본 글자 그대로 · «(합성)» 뺌).
abstract final class JournalTexts {
  /// 매수(표본).
  static const String buy = '매수';

  /// 매도(표본).
  static const String sell = '매도';

  /// 역분개 행 방향(계약 주석 «정정 행은 "역분개"»).
  static const String reversal = '역분개';

  /// 재기재 행 방향.
  static const String restatement = '재기재';

  /// 체결(표본).
  static const String filled = '체결';

  /// 부분 체결(표본).
  static const String partial = '부분 체결';

  /// 확인 필요(표본 · UNKNOWN).
  static const String unknown = '확인 필요';

  /// 거부(표본).
  static const String rejected = '거부';

  /// 이중 발주 차단(표본 필터 선택지 · 원천 없음 — 행 0).
  static const String prevented = '이중 발주 차단';

  /// 상쇄됨(표본 필터 선택지).
  static const String reversed = '상쇄됨';

  /// 재기재됨(표본 필터 선택지).
  static const String restated = '재기재됨';

  /// 마감 실효(표본 `journal_expired_1`).
  static const String expired = '마감 실효 · 다음 거래일로 이월';

  /// 취소.
  static const String cancelled = '취소';

  /// 건너뜀(6.9 직전 재확인 · 리스).
  static const String skipped = '건너뜀';

  /// 🆕 진행 중(예약 · 전송 중 · 접수 — 체결 0 · 계약 열거에 «접수» 값이 없어 `PARTIAL` 축으로 싣는다).
  static const String pending = '접수 — 체결 대기';

  /// 확정(표본).
  static const String settled = '확정';

  /// 반영 대기(표본).
  static const String pendingBatch = '반영 대기';

  /// 확인 대기(표본).
  static const String awaitingConfirm = '확인 대기';

  /// 규칙대로(표본).
  static const String ruleBound = '규칙대로';

  /// 숨김(표본 `journal_masked_integrity`).
  static const String hidden = '숨김';

  /// 브로커 체결(표본).
  static const String originBroker = '브로커 체결';

  /// 수기 기록(표본).
  static const String originManual = '수기 기록';

  /// 모의 체결(표본).
  static const String originSimulated = '모의 체결';

  /// 브로커 복구(표본).
  static const String originRecovered = '브로커 복구';

  /// 브로커 원장(표본 비용 출처).
  static const String costBroker = '브로커 원장';

  /// 직접 입력(표본).
  static const String costUser = '직접 입력';

  /// 추정치(표본).
  static const String costEstimated = '추정치';

  /// 당일 기록(표본).
  static const String sameDay = '당일 기록';

  /// 소급 기록(표본 «1거래일 소급 기록»).
  static String backdated(int days) => '$days거래일 소급 기록';

  /// 빈 일지(표본 `journal_empty` · D-day = 홈과 같은 셈).
  static String empty(String? dDay) => dDay == null
      ? '아직 기록된 거래가 없습니다 · 첫 주문은 리밸런싱일에 나갑니다'
      : '아직 기록된 거래가 없습니다 · 첫 주문은 리밸런싱일에 나갑니다 · 다음 리밸런싱 $dDay';

  /// 모르는 · 기록 없는 회차(표본 `journal_rebalance_unknown`).
  static const String rebalanceEmpty = '이 회차에 묶인 기록이 없습니다';

  /// 🆕 조건에 맞는 행 0(일지 자체는 있음).
  static const String filteredEmpty = '조건에 맞는 기록이 없습니다';

  /// 일지 기준(표본 `journal_filter_catalog` · `decision_detail_*`).
  static String asOfLabel(String day) => '일지 기준 $day';

  /// 저널 기준(표본 `journal_read_*`).
  static String journalAsOfLabel(String day) => '저널 기준 $day';

  /// 확인 중 배지(표본 `journal_badges_2`).
  static String unknownBadge(int n) => '확인 중 $n건';

  /// 🆕 E11q-j4 — 리뷰 대기 배지(표본 `journal_badges_2` 둘째 행).
  static String reviewBadge(int n) => '리뷰 대기 $n건';

  /// 출처 선택지(표본 `journal_filter_catalog`).
  static const String optionBroker = '브로커 체결만';

  /// 출처 선택지(표본).
  static const String optionManual = '수기 기록만';

  /// 출처 선택지(표본).
  static const String optionRecovered = '브로커 복구만';

  /// 🆕 출처 선택지 — 엔진 내부 모의(가상 체결만 나는 원장).
  static const String optionSimulated = '모의 체결만';

  /// 슬리브 POT(표본 `sleeve_catalog_4`).
  static const String sleevePot = 'POT · 납입 대기 자금';

  /// 회차 칩 글자(표본 «2026-08-03 월 납입 배분 회차»).
  static String scopeLabel(String day, String kind) => '$day $kind 회차';

  /// 월 납입 배분(표본 회차 종류 글자).
  static const String depositKind = '월 납입 배분';

  /// 씨앗 기간 글자(표본 «2026-08-03 ~ 2026-08-17»).
  static String rangeLabel(String from, String to) => '$from ~ $to';

  /// S7-6b «이 회차의 주문 n건»(표본 `m7_rebalance_detail_band`).
  static String eventOrders(int n) => '이 회차의 주문 $n건';

  /// 이 회차 보기(표본 J-2).
  static const String rebalanceLink = '이 회차 보기';

  /// 이 결정 보기(표본 J-3R).
  static const String decisionLink = '이 결정 보기';

  /// 원행 보기(J-2 X2 재판정 child).
  static const String parentLink = '원행 보기';

  /// 저널 보기(J-2 → J-3R).
  static const String journalReadLink = '저널 보기';

  /// 🆕 미결 220 ⓖ — 저널 작성(J-2 → J-3 · 표본 `m6/decision_detail_journal_draft_link`).
  static const String journalDraftLink = '저널 작성';

  /// 저널 작성됨(표본).
  static const String journalWritten = '저널 작성됨';

  /// 저널 미작성(표본).
  static const String journalNotWritten = '저널 미작성';

  /// 규칙대로 — 저널 대상 아님(표본 J-2).
  static const String journalNotTarget = '규칙대로 — 저널 대상이 아닙니다';

  /// 저널 본문 작성 시각(표본 «2026-08-31 09:12 작성»).
  static String writtenAt(String kstMinute) => '$kstMinute 작성';

  /// 스냅샷 없음(계약 주석).
  static const String snapshotMissing = '스냅샷 없음(구 버전 기록)';

  /// 잔여(표본 «잔여 40주 미체결»).
  static String remaining(int n) => '잔여 $n주 미체결';

  /// 미해소 고지(표본에서 시각만 뺌 — 확정 배치 시각은 엔진 일정이 정한다).
  static const String pendingNotice = '브로커 결과 확인 중 — 다음 배치에서 조회로 확정됩니다';
}

/// 🆕 E11q-q4b — J-5 미해소 보드 글자(표본 `unknown_board_2` · `unknown_board_empty` · «(18:10)» 뺌 — 엔진 일정에 없는 시각).
abstract final class UnknownBoardTexts {
  /// 빈 보드(표본).
  static const String empty = '미해소 건이 없습니다';

  /// 다음 배치 고지(표본에서 시각만 뺌).
  static const String nextBatch = '다음 배치에서 조회로 확정됩니다';

  /// 효과 한 줄(표본 — NR-1 2.5단계 = 그 종목 · 전략의 새 주문만 막는다).
  static const String effect = '이 종목의 신규 주문이 막혀 있습니다';

  /// 장기 미해소 링크(표본).
  static const String escalation = '장기 미해소 안내 보기';

  /// 경과(표본 «발생 08-21 14:02 · 6영업일 경과»).
  static String elapsed(String mmddHhmm, int sessions) =>
      '발생 $mmddHhmm · $sessions영업일 경과';

  /// 단계 제목 · 까닭(표본).
  static const String recorded = '기록됨';

  /// 표본.
  static const String recordedWhy = '결과를 모르는 주문으로 기록했습니다';

  /// 표본.
  static const String queryPending = '조회 대기';

  /// 표본.
  static const String queryPendingWhy = '다음 배치에서 브로커에 체결 여부를 묻습니다';

  /// 표본.
  static const String brokerConfirmed = '브로커 확인';

  /// 표본.
  static const String brokerConfirmedWhy = '브로커 답으로 체결·미체결을 확정합니다';

  /// 표본.
  static const String resolved = '해소';

  /// 표본.
  static const String resolvedWhy = '원장에 반영하고 이 종목의 주문 차단을 풉니다';

  /// 단계 상태 글자(표본).
  static const String done = '완료';

  /// 표본.
  static const String inProgress = '진행 중';

  /// 표본.
  static const String waiting = '대기';
}

/// 🆕 E11q-q4b — 장기 미해소 강조 임계(발생 뒤 KR 세션 수 · 이 값 이상 = 강조 + M5 안내 링크) — 표본(6 = 아님 · 16 = 강조) 사이 ·
/// 🟡 표시 강조일 뿐 차단 · 주문과 무관(차단 = NR-1 2.5단계가 늘 한다) — 모의 운영 실측으로 다시 본다.
const int kUnknownLongSessions = 10;

/// J-2 체인 단계 글자(표본 `decision_detail_*`).
abstract final class JournalStepTexts {
  /// 신호.
  static const String signal = '신호';

  /// 의도.
  static const String intent = '의도';

  /// 브로커 주문.
  static const String brokerOrder = '브로커 주문';

  /// 체결.
  static const String execution = '체결';

  /// 거래.
  static const String trade = '거래';

  /// 저널.
  static const String journal = '저널';

  /// 완료.
  static const String done = '완료';

  /// 전송됨.
  static const String sent = '전송됨';

  /// 확인 중.
  static const String checking = '확인 중';

  /// 거부.
  static const String rejected = '거부';

  /// 진행되지 않음.
  static const String notRun = '진행되지 않음';

  /// 대기.
  static const String waiting = '대기';

  /// 기록 없음.
  static const String noRecord = '기록 없음';

  /// 대상 아님.
  static const String notTarget = '대상 아님';

  /// 작성됨.
  static const String written = '작성됨';

  /// 미작성.
  static const String notWritten = '미작성';

  /// 의도 한 줄(«의도 i_0006 · 100주 매수»).
  static String intentLine(String id, int qty, String side) =>
      '의도 $id · $qty주 $side';

  /// 주문번호 한 줄(«주문번호 B0006»).
  static String orderLine(String no) => '주문번호 $no';

  /// 전량 체결(«120주 전량 체결»).
  static String allFilled(int qty) => '$qty주 전량 체결';

  /// 여러 번 체결(«3회에 걸쳐 60주 체결»).
  static String filledTimes(int times, int qty) => '$times회에 걸쳐 $qty주 체결';

  /// 원장 반영.
  static const String settledLine = '원장 반영 · 확정';

  /// 다음 배치 반영.
  static const String nextBatch = '다음 배치에서 원장에 반영됩니다';

  /// 브로커 응답 없음.
  static const String noResponse = '브로커 응답을 받지 못했습니다';

  /// 규칙대로 집행.
  static const String ruleFilled = '규칙대로 집행된 거래입니다';

  /// 규칙대로 나간 주문.
  static const String ruleSent = '규칙대로 나간 주문입니다';

  /// 주문이 나가지 않음.
  static const String notSent = '주문이 나가지 않았습니다';
}

/// 원장 주문 의도 한 줄(`order_intents` · 브로커 주문 · 체결).
class JournalIntentFact {
  /// 만든다.
  const JournalIntentFact({
    required this.intentId,
    required this.decisionId,
    required this.createdAt,
    required this.updatedAt,
    required this.tradeDate,
    required this.modeWire,
    required this.account,
    required this.strategyId,
    required this.symbol,
    required this.sideWire,
    required this.quantity,
    required this.statusWire,
    required this.configHash,
    this.limitPriceText,
    this.errorMessage,
    this.orders = const <JournalOrderFact>[],
    this.fills = const <JournalFillFact>[],
  });

  /// 의도 id.
  final String intentId;

  /// 결정 id(`{논리 id}@{집행일}`).
  final String decisionId;

  /// 기록 시각(UTC).
  final DateTime createdAt;

  /// 마지막 상태 변경 시각(UTC).
  final DateTime updatedAt;

  /// 집행일(KR 거래일).
  final TradeDate tradeDate;

  /// 실행 모드 글자.
  final String modeWire;

  /// 계좌 별칭.
  final String account;

  /// 전략 id.
  final String strategyId;

  /// 종목.
  final String symbol;

  /// 방향 글자.
  final String sideWire;

  /// 의도 수량.
  final int quantity;

  /// 의도 상태 글자.
  final String statusWire;

  /// 설정 지문.
  final String configHash;

  /// 지정가(원장 글자 · 시장가 = null).
  final String? limitPriceText;

  /// 거부 · 실효 사유 원문(`error_message`).
  final String? errorMessage;

  /// 브로커 주문(전송 순).
  final List<JournalOrderFact> orders;

  /// 체결(원장 순 — 엔진이 정렬한다).
  final List<JournalFillFact> fills;
}

/// 원장 브로커 주문 한 줄.
class JournalOrderFact {
  /// 만든다.
  const JournalOrderFact({
    required this.brokerOrderNo,
    required this.submittedAt,
  });

  /// 브로커 주문 번호(`{주문일}:{ODNO}`).
  final String brokerOrderNo;

  /// 전송 시각(UTC).
  final DateTime submittedAt;
}

/// 원장 체결 한 줄(`executions`).
class JournalFillFact {
  /// 만든다.
  const JournalFillFact({
    required this.executionId,
    required this.executedAt,
    required this.quantity,
    required this.priceText,
    required this.commissionText,
    required this.taxText,
    required this.originWire,
    required this.kindWire,
    required this.costSourceWire,
    this.brokerOrderNo,
    this.authoredAt,
    this.adviceId,
    this.backdateTradingDays = 0,
    this.priceRangeSourceDate,
  });

  /// 체결 id.
  final String executionId;

  /// 체결 시각(UTC).
  final DateTime executedAt;

  /// 수량.
  final int quantity;

  /// 체결가(원장 글자).
  final String priceText;

  /// 수수료(원장 글자).
  final String commissionText;

  /// 세금(원장 글자).
  final String taxText;

  /// 출처 글자(`fill_origin`).
  final String originWire;

  /// 성격 글자(`fill_kind`).
  final String kindWire;

  /// 비용 출처 글자(`cost_source`).
  final String costSourceWire;

  /// 브로커 주문 번호(수기 = null).
  final String? brokerOrderNo;

  /// 기록 시각(UTC · 없으면 체결 시각).
  final DateTime? authoredAt;

  /// 안내 id.
  final String? adviceId;

  /// 소급 거래일 수.
  final int backdateTradingDays;

  /// 가격 검증 근거일.
  final TradeDate? priceRangeSourceDate;
}

/// 원장 결정 한 줄(`decision_log`).
class JournalDecisionFact {
  /// 만든다.
  const JournalDecisionFact({
    required this.decisionId,
    required this.createdAt,
    required this.tradeDate,
    required this.kindWire,
    required this.reasonCode,
    required this.reason,
    required this.configHash,
    this.ruleCited,
    this.parentDecisionId,
    this.journalId,
  });

  /// 결정 id.
  final String decisionId;

  /// 기록 시각(UTC).
  final DateTime createdAt;

  /// 거래일.
  final TradeDate tradeDate;

  /// 종류 글자(`ENTRY` · `REBALANCE` …).
  final String kindWire;

  /// 사유 코드.
  final String reasonCode;

  /// 사유 문장(엔진이 쓴 글자).
  final String reason;

  /// 설정 지문.
  final String configHash;

  /// 인용 규칙.
  final String? ruleCited;

  /// X2 재판정 원행.
  final String? parentDecisionId;

  /// 사전 저널 id.
  final String? journalId;
}

/// 원장 리밸런싱 회차 한 줄(`rebalance_event` · 묶는 논리 id).
class JournalEventFact {
  /// 만든다.
  const JournalEventFact({
    required this.eventId,
    required this.tradeDate,
    required this.kindWire,
    required this.decisionId,
    required this.logicalIds,
    this.trigger = const <String, Object?>{},
  });

  /// 회차 id.
  final String eventId;

  /// 회차 거래일.
  final TradeDate tradeDate;

  /// 종류 글자.
  final String kindWire;

  /// 회차 결정 id(판정 결정).
  final String decisionId;

  /// 이 회차가 낸 주문의 논리 id — 🔴 판정 결정 id 를 늘 포함한다(월말 = + 계획 대상 · 계절 = + POT 청산).
  final Set<String> logicalIds;

  /// 판정 원값(JSON).
  final Map<String, Object?> trigger;
}

/// 원장 사전 저널 한 줄(`decision_journal`).
class JournalNoteFact {
  /// 만든다.
  const JournalNoteFact({
    required this.journalId,
    required this.createdAt,
    required this.isDeviation,
    this.kind,
    this.rationaleBefore,
    this.expectedOutcome,
    this.ruleCited,
    this.note,
  });

  /// 저널 id.
  final String journalId;

  /// 작성 시각(UTC).
  final DateTime createdAt;

  /// 이탈인가.
  final bool isDeviation;

  /// 종류(`DISCRETION` …).
  final String? kind;

  /// 실행 전 근거.
  final String? rationaleBefore;

  /// 기대 결과.
  final String? expectedOutcome;

  /// 인용 규칙.
  final String? ruleCited;

  /// 메모.
  final String? note;
}

/// 일지 사실 묶음(원장 한 파일).
class JournalFacts {
  /// 만든다 — [accountLabelOf] = 계좌 별칭 → 표시 이름 · [hasBody] = 조립 앱 등록 화면.
  JournalFacts({
    required this.runMode,
    required this.intents,
    required this.decisions,
    required this.events,
    required this.notes,
    required this.nowUtc,
    required this.kr,
    required this.accountLabelOf,
    required this.hasBody,
    this.integrityHidden = false,
    this.reconSuspect = false,
    WhatIfConfig? config,
  }) : config = config ?? WhatIfConfig.defaults;

  /// 이 원장의 실행 모드.
  final RunMode runMode;

  /// 주문 의도(원장 순).
  final List<JournalIntentFact> intents;

  /// 결정(id → 행).
  final Map<String, JournalDecisionFact> decisions;

  /// 리밸런싱 회차.
  final List<JournalEventFact> events;

  /// 사전 저널(id → 행).
  final Map<String, JournalNoteFact> notes;

  /// 지금(UTC).
  final DateTime nowUtc;

  /// 국내 달력.
  final ExchangeCalendar kr;

  /// 계좌 별칭 → 표시 이름.
  final String Function(String alias) accountLabelOf;

  /// 조립 앱 등록 화면.
  final bool Function(String route) hasBody;

  /// `LEDGER_INTEGRITY` — 숫자 글자 «숨김».
  final bool integrityHidden;

  /// `RECON_MISMATCH` — 수량 끝 «?».
  final bool reconSuspect;

  /// 종목 · 슬리브 이름표.
  final WhatIfConfig config;

  /// 오늘(KST).
  String get today => kstDateText(nowUtc);
}

// ── 공개 함수 ────────────────────────────────────────────────────────────────

/// 의도 결정 id(`{논리 id}@{집행일}`) → 묶인 회차 id(없으면 null) — 논리 id 조각이 회차 묶음에 든 첫 회차
/// (회차 = 거래일 · id 오름차순 · 조각 = 정렬 순).
String? journalEventIdOf(String decisionId, List<JournalEventFact> events) {
  final int at = decisionId.indexOf('@');
  final String logical = at < 0 ? decisionId : decisionId.substring(0, at);
  final List<String> parts = logical.split('+')..sort();
  final List<JournalEventFact> sorted = <JournalEventFact>[...events]
    ..sort((JournalEventFact a, JournalEventFact b) {
      final int c = a.tradeDate.yyyyMmDd.compareTo(b.tradeDate.yyyyMmDd);
      return c != 0 ? c : a.eventId.compareTo(b.eventId);
    });
  for (final String p in parts) {
    for (final JournalEventFact e in sorted) {
      if (e.logicalIds.contains(p)) return e.eventId;
    }
  }
  return null;
}

/// 일지 행 전부(시간 역순).
List<TradeJournalEntry> journalEntriesOf(JournalFacts f) {
  final _Book b = _Book(f);
  return <TradeJournalEntry>[
    for (final JournalIntentFact i in b.sortedIntents) b.entry(i),
  ];
}

/// J-1 타임라인 봉투 — 조건(기간 · 슬리브 · 종목 · 상태 · 출처 · 회차) · `limit`.
ListResult<TradeJournalEntry> journalTimelineOf(
  JournalFacts f, {
  required DateRange range,
  SleeveId? sleeve,
  String? symbol,
  JournalStatus? status,
  FillOrigin? origin,
  String? rebalanceEventId,
  int limit = 100,
}) {
  if (limit < 0) throw ArgumentError.value(limit, 'limit', '0 이상이어야 한다');
  final String? eventKey = switch (rebalanceEventId) {
    final String id => journalKeyOf(id),
    null => null,
  };
  final _Book b = _Book(f);
  final List<TradeJournalEntry> all = <TradeJournalEntry>[
    for (final JournalIntentFact i in b.sortedIntents) b.entry(i),
  ];
  final String from = range.from.yyyyMmDd;
  final String to = range.to.yyyyMmDd;
  final List<TradeJournalEntry> hit = <TradeJournalEntry>[
    for (final TradeJournalEntry e in all)
      if (e.tradeDate.yyyyMmDd.compareTo(from) >= 0 &&
          e.tradeDate.yyyyMmDd.compareTo(to) <= 0 &&
          (sleeve == null || e.sleeve == sleeve) &&
          (symbol == null || e.symbol == symbol) &&
          (status == null || e.status == status) &&
          (origin == null || e.fillOrigin == origin) &&
          (eventKey == null || e.rebalanceEventId == eventKey))
        e,
  ];
  final String? emptyLabel = hit.isNotEmpty
      ? null
      : rebalanceEventId != null
      ? JournalTexts.rebalanceEmpty
      : all.isEmpty
      ? JournalTexts.empty(b.nextDDay())
      : JournalTexts.filteredEmpty;
  return ListResult<TradeJournalEntry>(
    rows: hit.take(limit).toList(growable: false),
    asOf: b.asOf,
    emptyKind: EmptyKind.noData,
    emptyLabel: emptyLabel,
    hasMore: hit.length > limit,
  );
}

/// J-1 필터 카탈로그 — 상태(표본 7 · 차례 그대로) · 출처(원장 모드가 낼 수 있는 것) · 종목(일지에 나온 것 ·
/// 슬리브 차례 → 종목 코드).
JournalFilterCatalog journalFilterCatalogOf(JournalFacts f) {
  final _Book b = _Book(f);
  final Map<String, SleeveId> seen = <String, SleeveId>{
    for (final JournalIntentFact i in f.intents)
      i.symbol: _sleeveOf(i.strategyId),
  };
  final List<String> symbols = seen.keys.toList()
    ..sort((String x, String y) {
      final int c = _sleeveOrder(seen[x]!).compareTo(_sleeveOrder(seen[y]!));
      return c != 0 ? c : x.compareTo(y);
    });
  return JournalFilterCatalog(
    statusOptions: const <JournalStatusOption>[
      JournalStatusOption(
        status: JournalStatus.filled,
        label: JournalTexts.filled,
      ),
      JournalStatusOption(
        status: JournalStatus.partial,
        label: JournalTexts.partial,
      ),
      JournalStatusOption(
        status: JournalStatus.unknown,
        label: JournalTexts.unknown,
      ),
      JournalStatusOption(
        status: JournalStatus.rejected,
        label: JournalTexts.rejected,
      ),
      JournalStatusOption(
        status: JournalStatus.prevented,
        label: JournalTexts.prevented,
      ),
      JournalStatusOption(
        status: JournalStatus.reversed,
        label: JournalTexts.reversed,
      ),
      JournalStatusOption(
        status: JournalStatus.restated,
        label: JournalTexts.restated,
      ),
    ],
    originOptions: f.runMode == RunMode.simInternal
        ? const <FillOriginOption>[
            FillOriginOption(
              origin: FillOrigin.simulated,
              label: JournalTexts.optionSimulated,
            ),
          ]
        : const <FillOriginOption>[
            FillOriginOption(
              origin: FillOrigin.broker,
              label: JournalTexts.optionBroker,
            ),
            FillOriginOption(
              origin: FillOrigin.manual,
              label: JournalTexts.optionManual,
            ),
            FillOriginOption(
              origin: FillOrigin.brokerRecovered,
              label: JournalTexts.optionRecovered,
            ),
          ],
    symbolOptions: <SymbolOption>[
      for (final String s in symbols)
        SymbolOption(symbol: s, label: b.symbolLabel(s), sleeve: seen[s]!),
    ],
    asOf: b.asOf,
  );
}

/// J-1 상단 배지 — 미해소(UNKNOWN) 의도가 있을 때만 «확인 중 n건» · 🆕 E11q-j4 blind 리뷰 대상이 있을 때만 «리뷰 대기 n건»
/// (n = [blindReviewTargetsOf] 의 수 = J-4 큐 행 수 — 06 M1-25 ① · 0 = 배지 부재 · «0건» 금지 · 차례 = 표본 `journal_badges_2`).
List<JournalTimelineBadge> journalTimelineBadgesOf(JournalFacts f) {
  final int n = f.intents
      .where((JournalIntentFact i) => i.statusWire == 'UNKNOWN')
      .length;
  final int review = blindReviewTargetsOf(f).length;
  return <JournalTimelineBadge>[
    if (n > 0)
      JournalTimelineBadge(
        badgeCode: JournalBadgeCodes.unknownOpen,
        label: JournalTexts.unknownBadge(n),
        tone: ChipTone.caution,
        deepLink: f.hasBody(AppRoutes.journalUnknownBoard)
            ? AppRoutes.journalUnknownBoard
            : null,
      ),
    if (review > 0)
      JournalTimelineBadge(
        badgeCode: JournalBadgeCodes.blindReviewPending,
        label: JournalTexts.reviewBadge(review),
        tone: ChipTone.neutral,
        deepLink: f.hasBody(AppRoutes.journalBlindReview)
            ? AppRoutes.journalBlindReview
            : null,
      ),
  ];
}

/// 🆕 E11q-j4 — J-4 blind 리뷰 대상 한 건(카드 VM 의 재료 · 엔진 안 사실).
class BlindReviewTarget {
  /// 만든다.
  const BlindReviewTarget({
    required this.decisionId,
    required this.entry,
    required this.note,
    required this.decidedAt,
    this.firstOrderAt,
  });

  /// 결정 키(의도의 `decision_id` · J-2 링크와 같은 키).
  final String decisionId;

  /// 머리 의도(기록 시각 · 의도 id 순 첫 것)의 J-1 일지 행 — 문맥 칩 · 이탈 배지 · 종목 · 방향 · 거래일(C-43 ⑦ⓒ 와 같은 원천).
  final TradeJournalEntry entry;

  /// 작성된 이탈 저널(사전 3칸이 다 찬 것 — K3 ⓓ).
  final JournalNoteFact note;

  /// 결정 시각(UTC — 결정 원천 기록 · 없으면 머리 의도 기록 · 정렬 키 K4).
  final DateTime decidedAt;

  /// 첫 브로커 주문 전송(UTC · 없으면 null — 문항 ⑤ 근거 줄 부재).
  final DateTime? firstOrderAt;
}

/// 🆕 E11q-j4 — J-4 blind 리뷰 대상(06 M1-25 ② ③ · 01 §16 K3 · K4 · K24 · 엔진 규칙 — 화면 판정 0):
/// ⓐ 이탈 결정만(그 결정의 저널 `is_deviation` — 규칙대로 결정 · 저널 없는 결정 제외) ⓑ 그 결정의 달 월간 리포트가 발행된 뒤
/// (같은 판정 = [monthlyReportReadinessOf] 닫힌 달 — 한국 오늘 > 그 달 마지막 KR 세션 · 달력 밖 = 아직) ⓓ 사전 3칸이 다 찬 저널만
/// (`JOURNAL_MISSING` 이 서 있는 결정 = 제외 · J-3 작성 뒤 진입) · K24 = LIVE 원장만(모의 원장 = 0) · 정렬 = 결정 시각 오름차순 · 결정 키.
/// 🔵 K3 ⓒ X7 «안 함» 결정 = 이 원장에 안내 갈래 기록 0(운영 폰 = 자동 매매) → 0 · 채점된 결정 빼기 = 점수 기록 표(계약 창 대기 · 01 §8).
List<BlindReviewTarget> blindReviewTargetsOf(JournalFacts f) {
  if (f.runMode != RunMode.live) return const <BlindReviewTarget>[];
  final _Book b = _Book(f);
  final Set<String> keys = <String>{
    for (final JournalIntentFact i in f.intents) i.decisionId,
  };
  final Map<String, TradeJournalEntry> byIntent = <String, TradeJournalEntry>{
    for (final JournalIntentFact i in f.intents) i.intentId: b.entry(i),
  };
  final List<BlindReviewTarget> out = <BlindReviewTarget>[];
  for (final String key in keys) {
    final JournalNoteFact? note = b.noteOf(key);
    if (note == null || !note.isDeviation || !_written(note)) continue;
    final List<JournalIntentFact> mine = b.intentsOf(key);
    final JournalIntentFact head = mine.first;
    if (!_reportPublished(f, head.tradeDate)) continue;
    final List<DateTime> sent = <DateTime>[
      for (final JournalIntentFact i in mine)
        for (final JournalOrderFact o in i.orders) o.submittedAt,
    ]..sort();
    out.add(
      BlindReviewTarget(
        decisionId: key,
        entry: byIntent[head.intentId]!,
        note: note,
        decidedAt: (b.sourceOf(head)?.createdAt ?? head.createdAt).toUtc(),
        firstOrderAt: sent.isEmpty ? null : sent.first.toUtc(),
      ),
    );
  }
  out.sort((BlindReviewTarget x, BlindReviewTarget y) {
    final int c = x.decidedAt.compareTo(y.decidedAt);
    return c != 0 ? c : x.decisionId.compareTo(y.decisionId);
  });
  return out;
}

/// 그 날의 달 월간 리포트가 발행됐나(= S7-1 이 지을 수 있는 닫힌 달 · 개시 판정은 결정이 있는 달이라 늘 통과) · 달력 밖 = 아직.
bool _reportPublished(JournalFacts f, TradeDate day) {
  final String yyyyMm = day.yyyyMmDd.substring(0, 7);
  final TradeDate end;
  try {
    TradeDate d = TradeDate('$yyyyMm-01');
    if (!f.kr.isSession(d)) d = f.kr.nextSession(d);
    while (!f.kr.isLastSessionOfMonth(d)) {
      d = f.kr.nextSession(d);
    }
    end = d;
  } on StateError {
    return false;
  }
  if (!end.yyyyMmDd.startsWith('$yyyyMm-')) return false;
  return monthlyReportReadinessOf(
        yyyyMm: yyyyMm,
        monthEnd: end,
        openingDate: day.yyyyMmDd,
        nowUtc: f.nowUtc,
      ) ==
      MonthlyReportReadiness.closed;
}

/// J-2 거래 상세 — 모르는 결정 = 실패(잠정 규칙 · 01 §8 미결 50 ③).
DecisionDetailVm decisionDetailVmOf(JournalFacts f, String routeDecisionId) {
  final String decisionId = journalKeyOf(routeDecisionId);
  final _Book b = _Book(f);
  final List<JournalIntentFact> mine = b.intentsOf(decisionId);
  if (mine.isEmpty) throw StateError('결정이 없다: $decisionId');
  final JournalIntentFact head = mine.first;
  final TradeJournalEntry entry = b.entry(head);
  final JournalDecisionFact? src = b.sourceOf(head);
  final JournalNoteFact? note = b.noteOf(decisionId);
  final String? eventId = b.eventIdOf(head);
  final List<TradeJournalEntry> fills = <TradeJournalEntry>[
    for (final (JournalIntentFact i, JournalFillFact x) in b.fillsOf(mine))
      b.fillEntry(i, x),
  ];
  final int ordered = mine.fold(
    0,
    (int a, JournalIntentFact i) => a + i.quantity,
  );
  final int filled = mine.fold(
    0,
    (int a, JournalIntentFact i) => a + _filledQty(i),
  );
  final bool partial = mine.any(
    (JournalIntentFact i) => i.statusWire == 'PARTIAL',
  );
  final bool unknown = mine.any(
    (JournalIntentFact i) => i.statusWire == 'UNKNOWN',
  );
  return DecisionDetailVm(
    entry: entry,
    steps: b.steps(mine, src, note),
    snapshot: src == null ? null : b.snapshot(head, src),
    snapshotMissingLabel: src == null ? JournalTexts.snapshotMissing : null,
    thresholds: const <ThresholdCompare>[],
    rejectTraces: <RejectTrace>[
      for (final JournalIntentFact i in mine)
        if (b.trace(i) case final RejectTrace t) t,
    ],
    fills: fills,
    remainingText: partial && ordered > filled
        ? JournalTexts.remaining(ordered - filled)
        : null,
    pendingNoticeText: unknown ? JournalTexts.pendingNotice : null,
    parentLink: b.decisionLink(src?.parentDecisionId, JournalTexts.parentLink),
    rebalanceLink: eventId != null && f.hasBody(AppRoutes.rebalanceEvent)
        ? LinkAction(
            label: JournalTexts.rebalanceLink,
            deepLink: _route(AppRoutes.rebalanceEvent, eventId),
          )
        : null,
    journalStateLabel: note == null
        ? JournalTexts.journalNotTarget
        : _written(note)
        ? JournalTexts.journalWritten
        : JournalTexts.journalNotWritten,
    // 🆕 미결 220 ⓖ(K296) — 미완성 저널(사전 3칸 중 빈 칸) = «저널 작성» → J-3(키 = 저널 id · 결정 id 를 넣지 않는다).
    journalLink: note == null
        ? null
        : _written(note)
        ? (f.hasBody(AppRoutes.journalRead)
              ? LinkAction(
                  label: JournalTexts.journalReadLink,
                  deepLink: _route(AppRoutes.journalRead, decisionId),
                )
              : null)
        : (f.hasBody(AppRoutes.journalDraft)
              ? LinkAction(
                  label: JournalTexts.journalDraftLink,
                  deepLink: _route(AppRoutes.journalDraft, note.journalId),
                )
              : null),
    asOf: b.asOf,
  );
}

/// 사전 3칸이 다 찼나(SAF-408 판정과 같은 칸 — 하나라도 비면 미완성 · J-3 채우기 갈래).
bool _written(JournalNoteFact n) =>
    n.rationaleBefore != null &&
    n.expectedOutcome != null &&
    n.ruleCited != null;

/// J-3R 사전 저널 읽기 — 결정은 있는데 저널이 없으면 `body == null`(«미작성»도 값) · 모르는 결정 = 실패.
/// 🆕 미결 220 ⓔ(K296) — 키 = 저널 id **먼저**(J-3 executed 뒤 · 안전 저널) · 없으면 결정 id → `decision_log.journal_id` ·
/// 저널 id 로 열리면 «이 결정 보기» = 그 저널이 붙은 결정(주문이 있는)이 있을 때만 · 미완성 저널 = «미작성»(본문 부재) ·
/// 인용 규칙 글자 = 코드면 J-3 선택지 글자 · 원문이면 원문(K300).
DecisionJournalVm decisionJournalVmOf(JournalFacts f, String routeDecisionId) {
  final String key = journalKeyOf(routeDecisionId);
  final _Book b = _Book(f);
  final JournalNoteFact? byJournal = f.notes[key];
  final String? decisionId;
  final JournalNoteFact? note;
  if (byJournal != null) {
    note = byJournal;
    // 그 저널이 붙은 결정 = 주문(의도)의 결정 id 중 `noteOf` 가 이 저널을 주는 것(논리 id 조각 포함 · 같은 길).
    final List<String> owners = <String>{
      for (final JournalIntentFact i in f.intents)
        if (b.noteOf(i.decisionId)?.journalId == key) i.decisionId,
    }.toList()..sort();
    decisionId = owners.firstOrNull;
  } else {
    final bool known =
        b.intentsOf(key).isNotEmpty || f.decisions.containsKey(key);
    if (!known) throw StateError('결정 · 저널이 없다: $key');
    note = b.noteOf(key);
    decisionId = b.intentsOf(key).isEmpty ? null : key;
  }
  final DecisionJournalBody? body = note == null ? null : journalBodyOf(note);
  final AsOf asOf = b.asOfWith(JournalTexts.journalAsOfLabel(f.today));
  return DecisionJournalVm(
    decisionId: key,
    journalStateLabel: body != null
        ? JournalTexts.journalWritten
        : JournalTexts.journalNotWritten,
    body: body,
    decisionLink: b.decisionLink(decisionId, JournalTexts.decisionLink),
    asOf: asOf,
  );
}

/// 사전 저널 본문(J-3R · 🆕 E11q-j4 J-4 카드 — 같은 결정 = 같은 본문 · C-43 ⑦ⓑ) — 미완성(사전 3칸 중 빈 칸) = null(«미작성»).
DecisionJournalBody? journalBodyOf(JournalNoteFact note) => !_written(note)
    ? null
    : DecisionJournalBody(
        writtenAtText: JournalTexts.writtenAt(kstMinuteText(note.createdAt)),
        ruleCitedLabel: journalRuleCitedLabelOf(note.ruleCited),
        rationaleBefore: note.rationaleBefore!,
        expectedOutcome: note.expectedOutcome!,
        note: note.note,
      );

/// J-1 회차 범위 — 모르는 회차 = null(칩 부재 · 같은 id 의 타임라인 = 0행 + 봉투 문장) · 아는 회차 = 칩 글자 +
/// 그 회차에 묶인 행 전부를 덮는 기간(행 0 = 회차 거래일 하루).
JournalRebalanceScope? journalRebalanceScopeOf(
  JournalFacts f,
  String routeEventId,
) {
  final String rebalanceEventId = journalKeyOf(routeEventId);
  JournalEventFact? event;
  for (final JournalEventFact e in f.events) {
    if (e.eventId == rebalanceEventId) event = e;
  }
  if (event == null) return null;
  final _Book b = _Book(f);
  final List<String> days = <String>[
    for (final JournalIntentFact i in f.intents)
      if (b.eventIdOf(i) == rebalanceEventId) i.tradeDate.yyyyMmDd,
  ]..sort();
  final String from = days.isEmpty ? event.tradeDate.yyyyMmDd : days.first;
  final String to = days.isEmpty ? event.tradeDate.yyyyMmDd : days.last;
  return JournalRebalanceScope(
    rebalanceEventId: rebalanceEventId,
    label: JournalTexts.scopeLabel(event.tradeDate.yyyyMmDd, _kindLabel(event)),
    range: DateRange(
      from: TradeDate(from),
      to: TradeDate(to),
      label: JournalTexts.rangeLabel(from, to),
    ),
  );
}

/// S7-6b «이 회차의 주문 n건» — 묶인 일지 행 0 · 목적지 미등록 = null(버튼 부재).
LinkAction? journalTimelineLinkOf(
  String rebalanceEventId,
  int rows, {
  required bool Function(String route) hasBody,
}) => rows == 0 || !hasBody(AppRoutes.journalRebalance)
    ? null
    : LinkAction(
        label: JournalTexts.eventOrders(rows),
        deepLink: _route(AppRoutes.journalRebalance, rebalanceEventId),
      );

/// 조회 기간 프리셋(거래일 달력 M1-6) — 끝 = 오늘(KST)이거나 그 앞 마지막 세션 · 최근 30일(기본) = 30일 전 날이거나
/// 그 앞 세션부터 · 이번 달 · 올해 = 그 첫 세션부터 · 전체 = 원장 첫 날([firstLedgerDay] · 없으면 끝 날)부터.
List<DateRange> journalRangePresetsOf({
  required ExchangeCalendar kr,
  required DateTime nowUtc,
  String? firstLedgerDay,
}) {
  final String today = kstDateText(nowUtc);
  final String to = _onOrBefore(kr, today);
  final DateTime t = DateTime.parse('${to}T00:00:00Z');
  final String back30 = _day(t.subtract(const Duration(days: 30)));
  final String month = _onOrAfter(kr, '${to.substring(0, 7)}-01');
  final String year = _onOrAfter(kr, '${to.substring(0, 4)}-01-01');
  final String first =
      firstLedgerDay == null || firstLedgerDay.compareTo(to) > 0
      ? to
      : firstLedgerDay;
  DateRange r(String from, String code, String label, {bool def = false}) =>
      DateRange(
        from: TradeDate(from.compareTo(to) > 0 ? to : from),
        to: TradeDate(to),
        presetCode: code,
        label: label,
        isDefault: def,
      );
  return <DateRange>[
    r(_onOrBefore(kr, back30), 'LAST_30D', '최근 30일', def: true),
    r(month, 'THIS_MONTH', '이번 달'),
    r(year, 'THIS_YEAR', '올해'),
    r(first, 'ALL', '전체 기간'),
  ];
}

/// 슬리브 목록(P0S — 새틀라이트 행 없음 · POT = A 소속) — 표본 `sleeve_catalog_4` 꼴.
List<SleeveCatalogEntry> journalSleeveCatalogOf(WhatIfConfig config) =>
    <SleeveCatalogEntry>[
      for (final (SleeveId s, int order) in const <(SleeveId, int)>[
        (SleeveId.a, 1),
        (SleeveId.b, 2),
        (SleeveId.c, 3),
      ])
        SleeveCatalogEntry(
          sleeve: s,
          label: config.sleeveLabels[s] ?? '슬리브 ${s.wire}',
          order: order,
        ),
      const SleeveCatalogEntry(
        sleeve: SleeveId.pot,
        label: JournalTexts.sleevePot,
        rollsUpTo: SleeveId.a,
        order: 4,
      ),
    ];

/// 🆕 E11q-q4b — J-5 미해소 보드: 원장 UNKNOWN 의도 = 카드(오래된 것부터) · 4단계(기록됨 완료 · 조회 대기 진행 중 · 나머지 대기 —
/// 해소되면 의도가 UNKNOWN 을 벗어나 카드가 빠진다) · 경과 = 발생(첫 브로커 주문 전송 · 없으면 의도 기록) 뒤 KR 세션 수 ·
/// 장기([kUnknownLongSessions] 이상) = 강조 + 차단 보드 링크(등록됐을 때만) · 비면 엔진 빈 문장.
UnknownBoardVm unknownBoardVmOf(JournalFacts f) {
  final _Book b = _Book(f);
  final List<JournalIntentFact> open =
      <JournalIntentFact>[
        for (final JournalIntentFact i in f.intents)
          if (i.statusWire == 'UNKNOWN') i,
      ]..sort((JournalIntentFact x, JournalIntentFact y) {
        int c = x.tradeDate.yyyyMmDd.compareTo(y.tradeDate.yyyyMmDd);
        if (c != 0) return c;
        c = x.createdAt.compareTo(y.createdAt);
        return c != 0 ? c : x.intentId.compareTo(y.intentId);
      });
  final String today = _onOrBefore(f.kr, f.today);
  return UnknownBoardVm(
    items: <UnknownResolutionItem>[
      for (final JournalIntentFact i in open) _unknownItem(b, i, today),
    ],
    nextBatchNoticeText: open.isEmpty ? null : UnknownBoardTexts.nextBatch,
    emptyLabel: open.isEmpty ? UnknownBoardTexts.empty : null,
    asOf: b.asOf,
  );
}

UnknownResolutionItem _unknownItem(_Book b, JournalIntentFact i, String today) {
  final DateTime at = i.orders.isEmpty
      ? i.createdAt
      : i.orders.first.submittedAt;
  final int n = _sessionsAfter(b.f.kr, i.tradeDate.yyyyMmDd, today);
  final bool long = n >= kUnknownLongSessions;
  return UnknownResolutionItem(
    entry: b.entry(i),
    elapsedText: UnknownBoardTexts.elapsed(kstMinuteText(at).substring(5), n),
    effectLine: UnknownBoardTexts.effect,
    steps: const <UnknownResolutionStep>[
      UnknownResolutionStep(
        stepId: UnknownResolutionStageCodes.recorded,
        order: 1,
        title: UnknownBoardTexts.recorded,
        whyLine: UnknownBoardTexts.recordedWhy,
        state: GateState.pass,
        stateLabel: UnknownBoardTexts.done,
      ),
      UnknownResolutionStep(
        stepId: UnknownResolutionStageCodes.queryPending,
        order: 2,
        title: UnknownBoardTexts.queryPending,
        whyLine: UnknownBoardTexts.queryPendingWhy,
        state: GateState.unknown,
        stateLabel: UnknownBoardTexts.inProgress,
      ),
      UnknownResolutionStep(
        stepId: UnknownResolutionStageCodes.brokerConfirmed,
        order: 3,
        title: UnknownBoardTexts.brokerConfirmed,
        whyLine: UnknownBoardTexts.brokerConfirmedWhy,
        state: GateState.notApplicable,
        stateLabel: UnknownBoardTexts.waiting,
      ),
      UnknownResolutionStep(
        stepId: UnknownResolutionStageCodes.resolved,
        order: 4,
        title: UnknownBoardTexts.resolved,
        whyLine: UnknownBoardTexts.resolvedWhy,
        state: GateState.notApplicable,
        stateLabel: UnknownBoardTexts.waiting,
      ),
    ],
    emphasized: long,
    escalationLink: long && b.f.hasBody(AppRoutes.m5BlockBoard)
        ? const LinkAction(
            label: UnknownBoardTexts.escalation,
            deepLink: AppRoutes.m5BlockBoard,
          )
        : null,
  );
}

/// [from] 뒤(같은 날 제외) [to] 까지의 KR 세션 수(달력 밖 = 그 앞에서 멈춘다 — 지어내지 않는다).
int _sessionsAfter(ExchangeCalendar kr, String from, String to) {
  int n = 0;
  TradeDate d = TradeDate(from);
  while (true) {
    final TradeDate next;
    try {
      next = kr.nextSession(d);
    } on StateError {
      return n;
    }
    if (next.yyyyMmDd.compareTo(to) > 0) return n;
    n++;
    d = next;
  }
}

// ── 내부 ──────────────────────────────────────────────────────────────────────

class _Book {
  _Book(this.f);

  final JournalFacts f;

  late final List<JournalIntentFact> sortedIntents =
      <JournalIntentFact>[...f.intents]
        ..sort((JournalIntentFact a, JournalIntentFact b) {
          int c = b.tradeDate.yyyyMmDd.compareTo(a.tradeDate.yyyyMmDd);
          if (c != 0) return c;
          c = b.createdAt.compareTo(a.createdAt);
          return c != 0 ? c : b.intentId.compareTo(a.intentId);
        });

  late final AsOf asOf = asOfWith(JournalTexts.asOfLabel(f.today));

  AsOf asOfWith(String label) => AsOf(
    observedAt: f.nowUtc.toUtc(),
    tradeDate: TradeDate(f.today),
    source: AsOfSource.localSqlite,
    staleAfter: kJournalStaleAfter,
    label: label,
  );

  String symbolLabel(String s) => f.config.symbolLabels[s] ?? s;

  /// 다음 정기 리밸런싱 D-day(달력 밖 = null).
  String? nextDDay() {
    final String? exec = nextRegularExecutionSession(f.kr, f.nowUtc);
    return exec == null ? null : opsDDayText(f.today, exec);
  }

  /// 한 결정의 의도(기록 시각 · 의도 id 순).
  List<JournalIntentFact> intentsOf(String decisionId) =>
      <JournalIntentFact>[
        for (final JournalIntentFact i in f.intents)
          if (i.decisionId == decisionId) i,
      ]..sort((JournalIntentFact a, JournalIntentFact b) {
        final int c = a.createdAt.compareTo(b.createdAt);
        return c != 0 ? c : a.intentId.compareTo(b.intentId);
      });

  String? eventIdOf(JournalIntentFact i) =>
      journalEventIdOf(i.decisionId, f.events);

  JournalEventFact? eventOf(JournalIntentFact i) {
    final String? id = eventIdOf(i);
    for (final JournalEventFact e in f.events) {
      if (e.eventId == id) return e;
    }
    return null;
  }

  /// 결정 원천 — 묶인 회차의 판정 결정 · 아니면 논리 id(조각 정렬 순) 의 결정 · 아니면 의도 결정 id 그대로.
  JournalDecisionFact? sourceOf(JournalIntentFact i) {
    final JournalDecisionFact? byEvent = switch (eventOf(i)) {
      final JournalEventFact e => f.decisions[e.decisionId],
      null => null,
    };
    if (byEvent != null) return byEvent;
    for (final String p in _logicalParts(i.decisionId)) {
      if (f.decisions[p] case final JournalDecisionFact d) return d;
    }
    return f.decisions[i.decisionId];
  }

  /// 결정의 사전 저널 — 그 결정(또는 논리 id) 행의 `journal_id`.
  JournalNoteFact? noteOf(String decisionId) {
    for (final String id in <String>[
      decisionId,
      ..._logicalParts(decisionId),
    ]) {
      final JournalNoteFact? n = switch (f.decisions[id]?.journalId) {
        final String j => f.notes[j],
        null => null,
      };
      if (n != null) return n;
    }
    return null;
  }

  LinkAction? decisionLink(String? decisionId, String label) =>
      decisionId == null || !f.hasBody(AppRoutes.journalDecision)
      ? null
      : LinkAction(
          label: label,
          deepLink: _route(AppRoutes.journalDecision, decisionId),
        );

  List<(JournalIntentFact, JournalFillFact)> fillsOf(
    List<JournalIntentFact> intents,
  ) =>
      <(JournalIntentFact, JournalFillFact)>[
        for (final JournalIntentFact i in intents)
          for (final JournalFillFact x in i.fills) (i, x),
      ]..sort((
        (JournalIntentFact, JournalFillFact) a,
        (JournalIntentFact, JournalFillFact) b,
      ) {
        final int c = a.$2.executedAt.compareTo(b.$2.executedAt);
        return c != 0 ? c : a.$2.executionId.compareTo(b.$2.executionId);
      });

  // ── 행 ──

  TradeJournalEntry entry(JournalIntentFact i) {
    final List<JournalFillFact> fills = _sortedFills(i);
    final List<JournalFillFact> originals = <JournalFillFact>[
      for (final JournalFillFact x in fills)
        if (x.kindWire == FillKind.original.wire) x,
    ];
    final int qty = originals.isEmpty ? i.quantity : _filledQty(i);
    final Decimal price = originals.isEmpty
        ? _dec(i.limitPriceText ?? '0', 'limit_price')
        : _avgPrice(originals);
    final Decimal commission = _sum(
      fills,
      (JournalFillFact x) => x.commissionText,
    );
    final Decimal tax = _sum(fills, (JournalFillFact x) => x.taxText);
    final JournalStatus status = _status(i);
    final JournalFillFact? last = fills.isEmpty ? null : fills.last;
    final FillOrigin origin = originals.isEmpty
        ? _defaultOrigin()
        : _originOf(originals.first.originWire);
    final CostSource cost = _costOf(fills);
    final String? eventId = eventIdOf(i);
    final JournalDecisionFact? src = sourceOf(i);
    final JournalFillFact? first = originals.isEmpty ? null : originals.first;
    final int backdays = first?.backdateTradingDays ?? 0;
    return TradeJournalEntry(
      entryId: i.intentId,
      mode: _mode(i.modeWire),
      tradeDate: i.tradeDate,
      executedAt: last?.executedAt.toUtc(),
      symbol: i.symbol,
      symbolLabel: symbolLabel(i.symbol),
      sleeve: _sleeveOf(i.strategyId),
      side: _side(i.sideWire),
      sideLabel: _side(i.sideWire) == OrderSide.buy
          ? JournalTexts.buy
          : JournalTexts.sell,
      quantity: qty,
      price: price,
      commission: commission,
      tax: tax,
      quantityText: _qtyText('$qty주'),
      priceText: _hide(
        originals.isEmpty && i.limitPriceText == null
            ? '시장가'
            : commaWonText(price.round()),
      ),
      commissionText: _hide(commaWonText(commission.round())),
      taxText: _hide(commaWonText(tax.round())),
      status: status,
      statusLabel: _statusLabel(i, status),
      statusTone: _statusTone(status, i),
      visibility: _visibility(status),
      visibilityLabel: _visibilityLabel(_visibility(status)),
      reasons: _reasons(i, src),
      decision: DecisionRef(
        decisionId: i.decisionId,
        intentId: i.intentId,
        brokerOrderNo: i.orders.isEmpty ? null : i.orders.last.brokerOrderNo,
        executionId: last?.executionId,
        configHash: i.configHash,
      ),
      deviation: _deviation(noteOf(i.decisionId)),
      accountAlias: f.accountLabelOf(i.account),
      fillOrigin: origin,
      fillKind: FillKind.original,
      adviceId: first?.adviceId,
      backdate: BackdateStamp(
        tradeDate: i.tradeDate,
        authoredAt: (first?.authoredAt ?? first?.executedAt ?? i.createdAt)
            .toUtc(),
        backdateTradingDays: backdays,
        isBackdated: backdays > 0,
        label: backdays > 0
            ? JournalTexts.backdated(backdays)
            : JournalTexts.sameDay,
        priceRangeSourceDate: first?.priceRangeSourceDate ?? i.tradeDate,
        crossesClosedPeriod: false,
      ),
      costSource: cost,
      costSourceLabel: _costLabel(cost),
      originLabel: _originLabel(origin),
      rebalanceEventId: eventId,
      detailDeepLink: f.hasBody(AppRoutes.journalDecision)
          ? _route(AppRoutes.journalDecision, i.decisionId)
          : null,
      asOf: asOf,
    );
  }

  /// J-2 체결 행(체결 1 = 행 1).
  TradeJournalEntry fillEntry(JournalIntentFact i, JournalFillFact x) {
    final TradeJournalEntry base = entry(i);
    final FillKind kind = _kindOf(x.kindWire);
    final FillOrigin origin = _originOf(x.originWire);
    final CostSource cost = _costOf(<JournalFillFact>[x]);
    final Decimal price = _dec(x.priceText, 'price');
    final Decimal commission = _dec(x.commissionText, 'commission');
    final Decimal tax = _dec(x.taxText, 'tax');
    final JournalStatus status = switch (kind) {
      FillKind.original => base.status,
      FillKind.reversal => JournalStatus.reversed,
      FillKind.restatement => JournalStatus.restated,
    };
    final String qty = kind == FillKind.reversal
        ? '−${x.quantity}주'
        : '${x.quantity}주';
    return base.copyWith(
      entryId: x.executionId,
      executedAt: x.executedAt.toUtc(),
      sideLabel: switch (kind) {
        FillKind.original => base.sideLabel,
        FillKind.reversal => JournalTexts.reversal,
        FillKind.restatement => JournalTexts.restatement,
      },
      quantity: x.quantity,
      price: price,
      commission: commission,
      tax: tax,
      quantityText: _qtyText(qty),
      priceText: _hide(commaWonText(price.round())),
      commissionText: _hide(commaWonText(commission.round())),
      taxText: _hide(commaWonText(tax.round())),
      status: status,
      statusLabel: switch (kind) {
        FillKind.original => base.statusLabel,
        FillKind.reversal => JournalTexts.reversed,
        FillKind.restatement => JournalTexts.restated,
      },
      statusTone: kind == FillKind.original
          ? base.statusTone
          : ChipTone.neutral,
      decision: base.decision.copyWith(
        brokerOrderNo: x.brokerOrderNo,
        executionId: x.executionId,
      ),
      fillOrigin: origin,
      fillKind: kind,
      adviceId: x.adviceId,
      costSource: cost,
      costSourceLabel: _costLabel(cost),
      originLabel: _originLabel(origin),
      backdate: base.backdate.copyWith(
        authoredAt: (x.authoredAt ?? x.executedAt).toUtc(),
        backdateTradingDays: x.backdateTradingDays,
        isBackdated: x.backdateTradingDays > 0,
        label: x.backdateTradingDays > 0
            ? JournalTexts.backdated(x.backdateTradingDays)
            : JournalTexts.sameDay,
        priceRangeSourceDate: x.priceRangeSourceDate ?? i.tradeDate,
      ),
    );
  }

  String _hide(String s) => f.integrityHidden ? JournalTexts.hidden : s;

  String _qtyText(String s) =>
      f.integrityHidden ? JournalTexts.hidden : (f.reconSuspect ? '$s?' : s);

  FillOrigin _defaultOrigin() => f.runMode == RunMode.simInternal
      ? FillOrigin.simulated
      : FillOrigin.broker;

  List<ReasonChip> _reasons(JournalIntentFact i, JournalDecisionFact? src) {
    final ReasonChip? why = _statusChip(i);
    if (why != null) return <ReasonChip>[why];
    if (src == null) {
      return const <ReasonChip>[
        ReasonChip(
          code: 'DECISION_UNLINKED',
          label: '결정 기록과 이어지지 않은 주문입니다',
          tone: ChipTone.caution,
        ),
      ];
    }
    return <ReasonChip>[
      ReasonChip(
        code: src.reasonCode,
        label: _decisionChipLabels[src.reasonCode] ?? src.reason,
        tone: ChipTone.neutral,
      ),
    ];
  }

  // ── J-2 ──

  List<DecisionChainStep> steps(
    List<JournalIntentFact> mine,
    JournalDecisionFact? src,
    JournalNoteFact? note,
  ) {
    final JournalIntentFact head = mine.first;
    final List<JournalOrderFact> orders =
        <JournalOrderFact>[for (final JournalIntentFact i in mine) ...i.orders]
          ..sort(
            (JournalOrderFact a, JournalOrderFact b) =>
                a.submittedAt.compareTo(b.submittedAt),
          );
    final List<JournalFillFact> fills = <JournalFillFact>[
      for (final (JournalIntentFact _, JournalFillFact x) in fillsOf(mine)) x,
    ];
    final int ordered = mine.fold(
      0,
      (int a, JournalIntentFact i) => a + i.quantity,
    );
    final int filled = mine.fold(
      0,
      (int a, JournalIntentFact i) => a + _filledQty(i),
    );
    final Set<String> st = <String>{
      for (final JournalIntentFact i in mine) i.statusWire,
    };
    final bool rejectedBefore = mine.every(
      (JournalIntentFact i) =>
          (i.statusWire == 'REJECTED' || i.statusWire == 'SKIPPED') &&
          i.orders.isEmpty,
    );
    final bool unknown = st.contains('UNKNOWN');
    final bool partial =
        st.contains('PARTIAL') || (filled > 0 && filled < ordered);
    final bool allFilled = filled > 0 && filled >= ordered;
    final ReasonChip? why = _statusChip(head);
    String? at(DateTime? t) => t == null ? null : kstMinuteText(t).substring(5);

    final DecisionChainStep signal = src == null
        ? const DecisionChainStep(
            stageCode: DecisionChainStageCodes.signal,
            stageLabel: JournalStepTexts.signal,
            stateLabel: JournalStepTexts.noRecord,
            tone: ChipTone.neutral,
          )
        : DecisionChainStep(
            stageCode: DecisionChainStageCodes.signal,
            stageLabel: JournalStepTexts.signal,
            stateLabel: JournalStepTexts.done,
            tone: ChipTone.neutral,
            occurredAtText: at(src.createdAt),
            detailLines: <String>[src.reason],
          );
    final DecisionChainStep intent = DecisionChainStep(
      stageCode: DecisionChainStageCodes.intent,
      stageLabel: JournalStepTexts.intent,
      stateLabel: JournalStepTexts.done,
      tone: ChipTone.neutral,
      occurredAtText: at(head.createdAt),
      detailLines: <String>[
        for (final JournalIntentFact i in mine)
          JournalStepTexts.intentLine(
            i.intentId,
            i.quantity,
            _side(i.sideWire) == OrderSide.buy
                ? JournalTexts.buy
                : JournalTexts.sell,
          ),
      ],
    );
    final DecisionChainStep order = rejectedBefore
        ? DecisionChainStep(
            stageCode: DecisionChainStageCodes.brokerOrder,
            stageLabel: JournalStepTexts.brokerOrder,
            stateLabel: head.statusWire == 'SKIPPED'
                ? JournalStepTexts.notRun
                : JournalStepTexts.rejected,
            tone: head.statusWire == 'SKIPPED'
                ? ChipTone.neutral
                : ChipTone.blocked,
            occurredAtText: at(head.updatedAt),
            detailLines: <String>[
              if (why != null) ...<String>[why.code, why.label],
            ],
          )
        : orders.isEmpty
        ? const DecisionChainStep(
            stageCode: DecisionChainStageCodes.brokerOrder,
            stageLabel: JournalStepTexts.brokerOrder,
            stateLabel: JournalStepTexts.waiting,
            tone: ChipTone.neutral,
          )
        : DecisionChainStep(
            stageCode: DecisionChainStageCodes.brokerOrder,
            stageLabel: JournalStepTexts.brokerOrder,
            stateLabel: unknown || fills.isEmpty
                ? JournalStepTexts.sent
                : JournalStepTexts.done,
            tone: ChipTone.neutral,
            occurredAtText: at(orders.first.submittedAt),
            detailLines: <String>[
              for (final JournalOrderFact o in orders)
                JournalStepTexts.orderLine(_odno(o.brokerOrderNo)),
            ],
          );
    final DecisionChainStep execution = DecisionChainStep(
      stageCode: DecisionChainStageCodes.execution,
      stageLabel: JournalStepTexts.execution,
      stateLabel: rejectedBefore
          ? JournalStepTexts.notRun
          : unknown
          ? JournalStepTexts.checking
          : allFilled
          ? JournalStepTexts.done
          : partial
          ? JournalTexts.partial
          : st.contains('EXPIRED')
          ? JournalTexts.expired
          : st.contains('CANCELLED')
          ? JournalTexts.cancelled
          : st.contains('REJECTED')
          ? JournalStepTexts.rejected
          : JournalStepTexts.waiting,
      tone: unknown || (partial && !allFilled)
          ? ChipTone.caution
          : (st.contains('REJECTED') && !rejectedBefore
                ? ChipTone.blocked
                : ChipTone.neutral),
      occurredAtText: fills.isEmpty ? null : at(fills.last.executedAt),
      detailLines: <String>[
        if (unknown) JournalStepTexts.noResponse,
        if (!unknown && fills.length == 1 && allFilled)
          JournalStepTexts.allFilled(filled),
        if (!unknown && (fills.length > 1 || (fills.isNotEmpty && !allFilled)))
          JournalStepTexts.filledTimes(fills.length, filled),
        if (!unknown && partial && ordered > filled)
          JournalTexts.remaining(ordered - filled),
        if (!rejectedBefore && why != null && !unknown) why.label,
      ],
    );
    final DecisionChainStep trade = DecisionChainStep(
      stageCode: DecisionChainStageCodes.trade,
      stageLabel: JournalStepTexts.trade,
      stateLabel: allFilled
          ? JournalStepTexts.done
          : partial
          ? JournalTexts.pendingBatch
          : (rejectedBefore || fills.isEmpty) && !unknown && !_inFlight(st)
          ? JournalStepTexts.notRun
          : JournalStepTexts.waiting,
      tone: partial && !allFilled ? ChipTone.caution : ChipTone.neutral,
      detailLines: <String>[
        if (allFilled) JournalStepTexts.settledLine,
        if (partial && !allFilled) JournalStepTexts.nextBatch,
      ],
    );
    final DecisionChainStep journal = note != null
        ? DecisionChainStep(
            stageCode: DecisionChainStageCodes.journal,
            stageLabel: JournalStepTexts.journal,
            stateLabel: JournalStepTexts.written,
            tone: ChipTone.neutral,
            occurredAtText: at(note.createdAt),
          )
        : DecisionChainStep(
            stageCode: DecisionChainStageCodes.journal,
            stageLabel: JournalStepTexts.journal,
            stateLabel: JournalStepTexts.notTarget,
            tone: ChipTone.neutral,
            detailLines: <String>[
              if (fills.isNotEmpty)
                JournalStepTexts.ruleFilled
              else if (rejectedBefore ||
                  st.every((String s) => !_sentStatuses.contains(s)))
                JournalStepTexts.notSent
              else
                JournalStepTexts.ruleSent,
            ],
          );
    return <DecisionChainStep>[
      signal,
      intent,
      order,
      execution,
      trade,
      journal,
    ];
  }

  DecisionSnapshot snapshot(JournalIntentFact head, JournalDecisionFact src) {
    final JournalEventFact? e = eventOf(head);
    return DecisionSnapshot(
      ref: DecisionRef(
        decisionId: head.decisionId,
        parentDecisionId: src.parentDecisionId,
        intentId: head.intentId,
        brokerOrderNo: head.orders.isEmpty
            ? null
            : head.orders.last.brokerOrderNo,
        executionId: head.fills.isEmpty
            ? null
            : _sortedFills(head).last.executionId,
        configHash: head.configHash,
      ),
      tradeDate: src.tradeDate,
      kindLabel: _decisionKindLabels[src.kindWire] ?? src.kindWire,
      reasons: <ReasonChip>[
        ReasonChip(
          code: src.reasonCode,
          label: _decisionChipLabels[src.reasonCode] ?? src.reason,
          tone: ChipTone.neutral,
        ),
      ],
      trigger: TriggerSnapshot(
        configHash: src.configHash,
        rawValues: <String, String>{
          if (e != null)
            for (final MapEntry<String, Object?> m in e.trigger.entries)
              if (m.value != null)
                m.key: m.value is String
                    ? m.value! as String
                    : jsonEncode(m.value),
        },
        summary: src.reason,
      ),
      ruleCited: src.ruleCited,
      summary: src.reason,
    );
  }

  /// 주문 전 검사 거부 추적(브로커에 닿기 전 거부만 · 층 = 사유 머리).
  RejectTrace? trace(JournalIntentFact i) {
    if (i.statusWire != 'REJECTED' || i.orders.isNotEmpty) return null;
    final ReasonChip? why = _statusChip(i);
    if (why == null) return null;
    final String level = _levelOf(why.code);
    return RejectTrace(
      stageCode: level,
      stageLabel: _levelLabels[level]!,
      reasonCode: why.code,
      reasonLabel: why.label,
      occurredAt: i.updatedAt.toUtc(),
      occurredAtText: kstMinuteText(i.updatedAt).substring(5),
    );
  }
}

// ── 상태 · 글자 ──────────────────────────────────────────────────────────────

const Set<String> _sentStatuses = <String>{
  'SUBMITTING',
  'SUBMITTED',
  'FILLED',
  'PARTIAL',
  'UNKNOWN',
  'CANCELLED',
  'EXPIRED',
};

bool _inFlight(Set<String> st) =>
    st.contains('RESERVED') ||
    st.contains('SUBMITTING') ||
    st.contains('SUBMITTED');

JournalStatus _status(JournalIntentFact i) => switch (i.statusWire) {
  'FILLED' => JournalStatus.filled,
  'PARTIAL' => JournalStatus.partial,
  'CANCELLED' => JournalStatus.cancelled,
  'EXPIRED' => JournalStatus.expired,
  'REJECTED' => JournalStatus.rejected,
  'UNKNOWN' => JournalStatus.unknown,
  'SKIPPED' => JournalStatus.skipped,
  // 진행 중(체결 0 · 계약 열거에 «접수» 값이 없다) — 미체결 축(PARTIAL)에 싣고 글자가 말한다.
  'RESERVED' || 'SUBMITTING' || 'SUBMITTED' => JournalStatus.partial,
  final String other => throw StateError('모르는 의도 상태: $other'),
};

String _statusLabel(JournalIntentFact i, JournalStatus s) =>
    _inFlight(<String>{i.statusWire})
    ? JournalTexts.pending
    : switch (s) {
        JournalStatus.filled => JournalTexts.filled,
        JournalStatus.partial => JournalTexts.partial,
        JournalStatus.cancelled => JournalTexts.cancelled,
        JournalStatus.expired => JournalTexts.expired,
        JournalStatus.rejected => JournalTexts.rejected,
        JournalStatus.unknown => JournalTexts.unknown,
        JournalStatus.skipped => JournalTexts.skipped,
        JournalStatus.prevented => JournalTexts.prevented,
        JournalStatus.reversed => JournalTexts.reversed,
        JournalStatus.restated => JournalTexts.restated,
      };

ChipTone _statusTone(JournalStatus s, JournalIntentFact i) =>
    _inFlight(<String>{i.statusWire})
    ? ChipTone.neutral
    : switch (s) {
        JournalStatus.partial || JournalStatus.unknown => ChipTone.caution,
        JournalStatus.rejected => ChipTone.blocked,
        JournalStatus.prevented => ChipTone.prevented,
        JournalStatus.filled ||
        JournalStatus.cancelled ||
        JournalStatus.expired ||
        JournalStatus.skipped ||
        JournalStatus.reversed ||
        JournalStatus.restated => ChipTone.neutral,
      };

FillVisibility _visibility(JournalStatus s) => switch (s) {
  JournalStatus.partial => FillVisibility.pendingBatch,
  JournalStatus.rejected ||
  JournalStatus.unknown ||
  JournalStatus.skipped => FillVisibility.awaitingConfirm,
  JournalStatus.filled ||
  JournalStatus.cancelled ||
  JournalStatus.expired ||
  JournalStatus.prevented ||
  JournalStatus.reversed ||
  JournalStatus.restated => FillVisibility.settled,
};

String _visibilityLabel(FillVisibility v) => switch (v) {
  FillVisibility.settled => JournalTexts.settled,
  FillVisibility.pendingBatch => JournalTexts.pendingBatch,
  FillVisibility.awaitingConfirm => JournalTexts.awaitingConfirm,
};

/// 상태가 말하는 사유(거부 · 건너뜀 · 미해소 · 실효) — 있으면 그 칩 하나(표본 꼴).
ReasonChip? _statusChip(JournalIntentFact i) {
  switch (i.statusWire) {
    case 'UNKNOWN':
      return const ReasonChip(
        code: 'BROKER_ERROR',
        label: '브로커 응답이 확인되지 않았습니다',
        tone: ChipTone.caution,
      );
    case 'EXPIRED':
      return const ReasonChip(
        code: JournalReasonCodes.dayEndExpired,
        label: '장 마감까지 체결되지 않아 다음 거래일 주문으로 넘겼습니다',
        tone: ChipTone.neutral,
      );
    case 'REJECTED' || 'SKIPPED':
      final String msg = i.errorMessage ?? '';
      final String code = _rejectCodeOf(msg);
      return ReasonChip(
        code: code,
        label: _rejectLabels[code] ?? '주문 전 검사에 막혔습니다($code)',
        tone: i.statusWire == 'SKIPPED' ? ChipTone.neutral : ChipTone.blocked,
      );
  }
  return null;
}

/// 거부 원문 → 사유 코드 — `BROKER: ` 접두 = 브로커 거부(모의 브로커 원문 코드는 그대로) · 머리 `:` 앞 · 빈 원문 = 모름.
String _rejectCodeOf(String msg) {
  if (msg.startsWith('BROKER: ')) {
    final String raw = msg.substring(8).split(RegExp(r'[\s:]')).first;
    return _rejectLabels.containsKey(raw) ? raw : 'BROKER_REJECTED';
  }
  final String head = msg.split(':').first.trim();
  return head.isEmpty ? 'REJECT_UNKNOWN' : head;
}

const Map<String, String> _rejectLabels = <String, String>{
  JournalReasonCodes.leaseInvalid: '이 기기에 발주권이 없어 주문을 내지 않았습니다',
  'KILL_SWITCH': '킬스위치가 켜져 있어 주문을 내지 않았습니다',
  'BREAKER_STOPPED': '서킷브레이커 정지로 주문을 내지 않았습니다',
  'UNKNOWN_UNRESOLVED': '확인되지 않은 주문이 남아 있어 주문을 내지 않았습니다',
  'RISK_UNAVAILABLE': '한도를 확인하지 못해 주문을 내지 않았습니다',
  'SAF309_DENY_UNVERIFIED_FAIL_CLOSED': '계좌 검증 전이라 주문을 내지 않았습니다',
  'SIM_INVALID_ORDER': '모의 주문 수량·꼴이 맞지 않아 접수하지 않았습니다',
  'BROKER_REJECTED': '브로커가 주문을 거부했습니다',
  'REJECT_UNKNOWN': '거부 사유가 기록되지 않았습니다',
};

String _levelOf(String code) {
  if (code.startsWith('SAF-1')) return SafetyCheckLevelCodes.level1Position;
  if (code.startsWith('SAF-2')) return SafetyCheckLevelCodes.level2Sleeve;
  if (code.startsWith('SAF-3') || code.startsWith('SAF309')) {
    return SafetyCheckLevelCodes.level3Portfolio;
  }
  return SafetyCheckLevelCodes.level4System;
}

const Map<String, String> _levelLabels = <String, String>{
  SafetyCheckLevelCodes.level1Position: '포지션 리스크 한도',
  SafetyCheckLevelCodes.level2Sleeve: '슬리브 한도·종목 필터',
  SafetyCheckLevelCodes.level3Portfolio: '포트폴리오·세금 게이트',
  SafetyCheckLevelCodes.level4System: '시스템·주문 게이트',
};

/// 결정 사유 칩 글자(표본에 있는 것은 표본 글자 · 없으면 결정 원장의 문장).
const Map<String, String> _decisionChipLabels = <String, String>{
  'MONTHLY_REGULAR': '월간 정기 리밸런싱',
  'REBALANCE_BAND': '밴드 이탈 리밸런싱',
  'DEPOSIT_ROUTING': '월 납입 배분',
  'SEASONAL_ENTRY': '계절 A 진입',
  'F1_ENTRY_LATE': '계절 A 연기 뒤 진입',
  'SEASONAL_EXIT': '계절 A 청산',
};

const Map<String, String> _decisionKindLabels = <String, String>{
  'ENTRY': '진입',
  'EXIT': '청산',
  'REBALANCE': '리밸런싱',
  'DEPOSIT': '월 납입 배분',
  'WITHDRAWAL': '출금',
  'SAFETY': '안전 판정',
  'RESUME': '재개',
  'LEDGER_FIX': '원장 정정',
  'MANUAL': '수기',
};

String _kindLabel(JournalEventFact e) => switch (e.kindWire) {
  'MONTHLY_REGULAR' => RebalanceEventTexts.monthlyRegular,
  'SEASONAL' => RebalanceEventTexts.seasonal,
  'DEPOSIT' => JournalTexts.depositKind,
  final String other => other,
};

DeviationBadge _deviation(JournalNoteFact? n) => n == null || !n.isDeviation
    ? const DeviationBadge(isDeviation: false, label: JournalTexts.ruleBound)
    : DeviationBadge(
        isDeviation: true,
        kindCode: n.kind,
        label: '사전 저널이 있는 이탈',
        journalId: n.journalId,
      );

FillOrigin _originOf(String wire) => FillOrigin.values.firstWhere(
  (FillOrigin o) => o.wire == wire,
  orElse: () => throw StateError('모르는 체결 출처: $wire'),
);

FillKind _kindOf(String wire) => FillKind.values.firstWhere(
  (FillKind k) => k.wire == wire,
  orElse: () => throw StateError('모르는 체결 성격: $wire'),
);

String _originLabel(FillOrigin o) => switch (o) {
  FillOrigin.broker => JournalTexts.originBroker,
  FillOrigin.manual => JournalTexts.originManual,
  FillOrigin.simulated => JournalTexts.originSimulated,
  FillOrigin.brokerRecovered => JournalTexts.originRecovered,
};

/// 비용 출처 — 체결 0 = 추정치(표본) · 하나라도 추정 = 추정치 · 하나라도 직접 입력 = 직접 입력 · 나머지 = 브로커.
CostSource _costOf(List<JournalFillFact> fills) {
  if (fills.isEmpty) return CostSource.estimated;
  final Set<String> w = <String>{
    for (final JournalFillFact x in fills) x.costSourceWire,
  };
  for (final String s in w) {
    if (!CostSource.values.any((CostSource c) => c.wire == s)) {
      throw StateError('모르는 비용 출처: $s');
    }
  }
  if (w.contains(CostSource.estimated.wire)) return CostSource.estimated;
  if (w.contains(CostSource.userEntered.wire)) return CostSource.userEntered;
  return CostSource.broker;
}

String _costLabel(CostSource c) => switch (c) {
  CostSource.broker => JournalTexts.costBroker,
  CostSource.userEntered => JournalTexts.costUser,
  CostSource.estimated => JournalTexts.costEstimated,
};

RunMode _mode(String wire) => RunMode.values.firstWhere(
  (RunMode m) => m.wire == wire,
  orElse: () => throw StateError('모르는 실행 모드: $wire'),
);

OrderSide _side(String wire) => OrderSide.values.firstWhere(
  (OrderSide s) => s.wire == wire,
  orElse: () => throw StateError('모르는 방향: $wire'),
);

SleeveId _sleeveOf(String strategyId) => switch (strategyId) {
  P0sStrategyIds.sleeveA => SleeveId.a,
  P0sStrategyIds.sleeveB => SleeveId.b,
  P0sStrategyIds.sleeveC => SleeveId.c,
  P0sStrategyIds.pot => SleeveId.pot,
  final String other => throw StateError('귀속 불가 전략: $other'),
};

int _sleeveOrder(SleeveId s) => switch (s) {
  SleeveId.a => 1,
  SleeveId.b => 2,
  SleeveId.c => 3,
  SleeveId.pot => 4,
  _ => 5,
};

List<String> _logicalParts(String decisionId) {
  final int at = decisionId.indexOf('@');
  final String logical = at < 0 ? decisionId : decisionId.substring(0, at);
  return logical.split('+')..sort();
}

List<JournalFillFact> _sortedFills(JournalIntentFact i) =>
    <JournalFillFact>[...i.fills]..sort((JournalFillFact a, JournalFillFact b) {
      final int c = a.executedAt.compareTo(b.executedAt);
      return c != 0 ? c : a.executionId.compareTo(b.executionId);
    });

/// 체결 수량 합(원 체결 − 역분개 + 재기재).
int _filledQty(JournalIntentFact i) => i.fills.fold(
  0,
  (int a, JournalFillFact x) =>
      a + (x.kindWire == FillKind.reversal.wire ? -x.quantity : x.quantity),
);

Decimal _avgPrice(List<JournalFillFact> fills) {
  int q = 0;
  Decimal v = Decimal.zero;
  for (final JournalFillFact x in fills) {
    q += x.quantity;
    v += _dec(x.priceText, 'price') * Decimal.fromInt(x.quantity);
  }
  if (q <= 0) throw StateError('체결 수량이 0 이다');
  return (v / Decimal.fromInt(q)).toDecimal(scaleOnInfinitePrecision: 4);
}

Decimal _sum(
  List<JournalFillFact> fills,
  String Function(JournalFillFact) of,
) => fills.fold(
  Decimal.zero,
  (Decimal a, JournalFillFact x) => a + _dec(of(x), 'cost'),
);

Decimal _dec(String text, String what) {
  final Decimal? d = Decimal.tryParse(text);
  if (d == null) throw StateError('$what 글자가 숫자가 아니다: $text');
  return d;
}

/// 🔴 링크 = 패턴 앞 + id(셸 라우터는 `#` · `?` 가 든 조각을 맞추지 않는다 — 재개 child 결정 id `…#R{날}@{날}` 꼴)
/// → `%` · `#` · `?` · `/` 만 퍼센트 꼴로 감싼다(`@` · `+` 는 그대로 — H6-2 링크와 같은 글자).
String _route(String pattern, String id) =>
    '${pattern.split('/:').first}/${id.replaceAll('%', '%25').replaceAll('#', '%23').replaceAll('?', '%3F').replaceAll('/', '%2F')}';

/// 라우트 조각 → 키(링크가 감싼 것을 푼다 · 풀 수 없는 글자 = 그대로).
String journalKeyOf(String routeParam) {
  try {
    return Uri.decodeComponent(routeParam);
  } on ArgumentError {
    return routeParam;
  }
}

/// 브로커 주문 번호의 ODNO(`{주문일}:{ODNO}` 꼴이면 뒤 · 아니면 그대로).
String _odno(String no) {
  final int c = no.indexOf(':');
  return c < 0 ? no : no.substring(c + 1);
}

String _day(DateTime utcMidnight) =>
    utcMidnight.toIso8601String().substring(0, 10);

String _onOrBefore(ExchangeCalendar kr, String day) {
  final TradeDate d = TradeDate(day);
  return kr.isSession(d) ? day : kr.nthSessionBefore(d, 1).yyyyMmDd;
}

String _onOrAfter(ExchangeCalendar kr, String day) {
  final TradeDate d = TradeDate(day);
  return kr.isSession(d) ? day : kr.nextSession(d).yyyyMmDd;
}
