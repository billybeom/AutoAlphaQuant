// 주문 경로 포트 — 브로커 · 원장 · 안내. 설계 13 §8 R33 D12 · R35 V2~V4 · 04 §3-1 · §3-3 · 01 §6 `KISBroker` · `Store`.
//
// 🔴 core_engine 은 포트만 안다. 구현 = broker_gateway `KisOrderBroker`(E10d) · data_sync `SqliteOrderLedger`(E10c) ·
//    안내 = E18. 배선(`kr_order` 잡)은 E11. broker_gateway 와 data_sync 는 서로를 모른다(01 §1-1 — E8d2b 선례).
// 🔴 [OrderLedger.insertIntent] 가 돌아오면 그 행은 **커밋됐다**(04 §3-1 6.5 · AC-S04) — 브로커 호출 시점에 별도
//    커넥션에서 보여야 한다. 그 증명은 구현 쪽 시험(E10c — 파일 SQLite + 둘째 연결)이 한다.
// 🔴 결과 불명(시간 초과 · 연결 끊김 · 파싱 실패 · 5xx)은 [OrderOutcomeUnknown] 이다 — 재시도 금지(NR-2 · 04 §3-3 v2.38).
//    분명한 거절은 [BrokerRejected] 로 돌려준다(예외 아님).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'fills.dart';
import 'order_draft.dart';

/// `order_intents.status`(02 §2-4 v2.38 CHECK) — 🔴 새 값을 만들지 않는다(04 §1 v1.5 표). 계약 밖(R33 D11).
enum IntentStatus {
  /// 6단계 INSERT 직후(브로커 호출 전).
  reserved('RESERVED'),

  /// 7단계 — 제출 직전.
  submitting('SUBMITTING'),

  /// 접수.
  submitted('SUBMITTED'),

  /// 전량 체결.
  filled('FILLED'),

  /// 부분 체결.
  partial('PARTIAL'),

  /// 취소 확정.
  cancelled('CANCELLED'),

  /// 거부(1~5단계 · 브로커 거절).
  rejected('REJECTED'),

  /// 결과 불명 — 해소 전까지 그 (시장 · 종목 · 전략)의 새 의도를 막는다(2.5단계).
  unknown('UNKNOWN'),

  /// DRY_RUN · 수량 0 등.
  skipped('SKIPPED'),

  /// 일 마감 실효(취소 아님 — 04 §3-1 ③ v2.38).
  expired('EXPIRED');

  const IntentStatus(this.code);

  /// DDL 표기.
  final String code;
}

/// 주문이 나갔는지 알 수 없다 — 🔴 재주문 금지 · 조회로 확인한 뒤에만 다음 조치(01 §1 · NR-2).
class OrderOutcomeUnknown implements Exception {
  /// 예외를 만든다.
  const OrderOutcomeUnknown(this.message, {this.intentId});

  /// 사유.
  final String message;

  /// 그 의도(원장에 UNKNOWN 으로 남았다 — 기록에 실패했으면 메시지가 말한다).
  final String? intentId;

  @override
  String toString() => 'OrderOutcomeUnknown(${intentId ?? '-'}): $message';
}

/// 브로커에 보내는 주문 — 계좌는 브로커 한 벌의 것이다(R33 D18).
class BrokerOrderRequest {
  /// 요청을 만든다.
  const BrokerOrderRequest({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.orderType,
    required this.limitPrice,
  });

  /// 종목.
  final String symbol;

  /// 방향.
  final OrderSide side;

  /// 수량(≥ 1).
  final int quantity;

  /// [OrderTypes] 값 — KIS `ORD_DVSN` 대응은 broker_gateway(R33 D19).
  final String orderType;

  /// 지정가(시장가면 null).
  final Decimal? limitPrice;

  @override
  String toString() =>
      '$symbol ${side.wire} $quantity $orderType ${limitPrice ?? '-'}';
}

/// 제출 · 취소 결과(결과 불명은 예외다).
sealed class BrokerSubmitResult {
  const BrokerSubmitResult();
}

/// 접수 — KIS 주문 응답 `output.ODNO` 와 주문일.
final class BrokerAccepted extends BrokerSubmitResult {
  /// 접수 결과.
  const BrokerAccepted({required this.odno, required this.orderDate});

  /// 주문번호 원문.
  final String odno;

  /// 주문일(KR 거래일).
  final TradeDate orderDate;
}

/// 분명한 거절(HTTP 200 + `rt_cd ≠ 0` · 4xx JSON · 500 + `EGW02006` · 유량 · 토큰 재시도 소진 — 04 §3-3 v2.38).
final class BrokerRejected extends BrokerSubmitResult {
  /// 거절 결과.
  const BrokerRejected({required this.code, required this.message});

  /// 브로커 코드(예 `40580000`).
  final String code;

  /// 브로커 메시지.
  final String message;
}

/// 브로커 포트 — 계좌 하나에 한 벌(R33 D18 · R35 V2).
abstract interface class OrderBroker {
  /// 주문 제출(NR-1 8단계). 결과 불명이면 [OrderOutcomeUnknown] — 🔴 안에서 다시 보내지 않는다.
  Future<BrokerSubmitResult> submit(BrokerOrderRequest request);

  /// 주문 취소(`{주문일}:{ODNO}` — 킬스위치 M5-1 이 부른다 · R33 D26).
  Future<BrokerSubmitResult> cancel(String brokerOrderNo);

  /// 일별주문체결조회(조회 GET — 재시도는 R29 L5). 취소 행도 함께 온다.
  Future<List<DailyFillRow>> dailyFills(TradeDate orderDate);

  /// 매수에 쓸 수 있는 예수금(원 · 04 §3-4 v2.38 — 칸 이름은 E10d 실응답으로).
  Future<Decimal> orderableCashKrw();
}

/// `order_intents` 한 행의 값(02 §2-4) — 시각 칸은 원장이 채운다(04 §3-1 v1.5).
class IntentRow {
  /// 행을 만든다.
  const IntentRow({
    required this.intentId,
    required this.idempotencyKey,
    required this.tradeDate,
    required this.market,
    required this.account,
    required this.strategyId,
    required this.decisionId,
    required this.symbol,
    required this.side,
    required this.orderType,
    required this.quantity,
    required this.limitPrice,
    required this.status,
    required this.errorMessage,
    required this.configHash,
    required this.execPolicy,
    required this.operatingMode,
  });

  /// 초안에서 만든다 — [quantity] 를 주면 그 수량(한도 축소 · 예수금 축소)으로 쓴다.
  factory IntentRow.fromDraft(
    OrderIntentDraft draft, {
    required IntentStatus status,
    required String configHash,
    required ExecPolicy execPolicy,
    required OperatingMode operatingMode,
    String? errorMessage,
    int? quantity,
  }) {
    final String key = draft.idempotencyKey;
    return IntentRow(
      intentId: intentIdFor(key),
      idempotencyKey: key,
      tradeDate: draft.executionDate,
      market: draft.market,
      account: draft.account,
      strategyId: draft.strategyId,
      decisionId: draft.decisionId,
      symbol: draft.symbol,
      side: draft.side,
      orderType: draft.orderType,
      quantity: quantity ?? draft.quantity,
      limitPrice: draft.limitPrice,
      status: status,
      errorMessage: errorMessage,
      configHash: configHash,
      execPolicy: execPolicy,
      operatingMode: operatingMode,
    );
  }

  /// `intent_id`(결정적 — [intentIdFor]).
  final String intentId;

  /// 멱등키(UNIQUE).
  final String idempotencyKey;

  /// 집행일.
  final TradeDate tradeDate;

  /// 시장.
  final String market;

  /// 계좌 별칭.
  final String account;

  /// strategy_id.
  final String strategyId;

  /// `{논리 id}@{집행일}`.
  final String decisionId;

  /// 종목.
  final String symbol;

  /// 방향.
  final OrderSide side;

  /// 주문 유형.
  final String orderType;

  /// 수량.
  final int quantity;

  /// 지정가.
  final Decimal? limitPrice;

  /// INSERT 때 상태(RESERVED · 1~5단계 거부면 REJECTED · 축소 0주면 SKIPPED).
  final IntentStatus status;

  /// 사유(04 §1 v1.5 표 꼴).
  final String? errorMessage;

  /// config_hash.
  final String configHash;

  /// `dry_run`(1 ⇔ DRY_RUN).
  final ExecPolicy execPolicy;

  /// `operating_mode`(배치 F).
  final OperatingMode operatingMode;
}

final RegExp _hex64 = RegExp(r'^[0-9a-f]{64}$');

/// `intent_id` = `oi-` + 멱등키 앞 24자(R35 V4) — 같은 키 = 같은 id · UUID 를 쓰지 않는다.
String intentIdFor(String idempotencyKey) {
  if (!_hex64.hasMatch(idempotencyKey)) {
    throw ArgumentError.value(
      idempotencyKey,
      'idempotencyKey',
      '64자 16진 소문자가 아니다',
    );
  }
  return 'oi-${idempotencyKey.substring(0, 24)}';
}

/// 원장 포트(R35 V3) — 구현 = data_sync `SqliteOrderLedger`(E10c). 읽기가 실패하면 예외를 던진다(기본값 금지).
abstract interface class OrderLedger {
  /// 1단계 — `kill_switch_state` 활성 행이 있는가(R33 D26).
  Future<bool> killSwitchActive();

  /// 2단계 — `trading_block` 활성 행 가운데 묶음 플래그(04 §3-1 ① 판정 SQL).
  Future<Set<String>> activeBlockFlags();

  /// 2.5단계 — 그 (시장 · 종목 · 전략)에 UNKNOWN 의도가 있는가(방향 · 날 무관 · R33 D25).
  Future<bool> hasUnresolvedUnknown(
    String market,
    String symbol,
    String strategyId,
  );

  /// 3단계 — 전략 상태가 등록돼 있는가(SAF-406).
  Future<bool> strategyRegistered(String strategyId);

  /// SAF-401 — 그날 7단계(SUBMITTING)에 들어선 의도 수(R33 D22).
  Future<int> ordersToday(TradeDate tradeDate);

  /// SAF-408 판정 SQL(주문 경로에서 직접 — SF-01) — 🔴 `JOURNAL_MISSING` 플래그를 자동 설정 · 해제하고 판정을 돌려준다
  /// (사람 해제 경로 없음 · 2단계 앞에서 부른다 — R36 W9).
  Future<bool> journalMissing();

  /// SAF-410 판정 SQL([tradeDate] 의 전월 판정 · 월말 뒤 3거래일 유예 — 04 §1 v2.15 · v2.38 D20) — `TIER_B_UNJUDGED`
  /// 플래그를 자동 설정 · 해제하고 판정을 돌려준다.
  Future<bool> tierBUnjudged(TradeDate tradeDate);

  /// 6단계 INSERT — 멱등키 UNIQUE 충돌이면 false(이미 처리된 의도). 🔴 돌아오면 커밋됐다(6.5).
  Future<bool> insertIntent(IntentRow row);

  /// 7단계 — SUBMITTING(+ 커밋).
  Future<void> markSubmitting(String intentId);

  /// 9단계 접수 — SUBMITTED + `broker_orders` 행(`{주문일}:{ODNO}`).
  Future<void> markSubmitted(String intentId, String brokerOrderNo);

  /// 9단계 거절 — REJECTED(7단계를 지난 거절 — orders_today 에 센다 · R33 D22).
  Future<void> markBrokerRejected(String intentId, String message);

  /// 결과 불명 — UNKNOWN.
  Future<void> markUnknown(String intentId, String message);

  /// RESERVED → SKIPPED(DRY_RUN).
  Future<void> markSkipped(String intentId, String message);
}

/// 안내 모드(ADVISORY)의 받는 쪽 — 6.5 COMMIT 뒤 한 곳(04 §3-1 ② · 01 §10-4). 구현 = E18(`advice` 행).
abstract interface class AdviceSink {
  /// 커밋된 의도를 안내로 넘긴다.
  Future<void> publish(IntentRow row);
}
