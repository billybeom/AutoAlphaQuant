// FakeBroker — 포트 수준 결정론 가짜 브로커(설계 13 §8 R33 D13 · R35 V9 · 06 G-FB).
//
// 🔴 시험 전용이다. 실키 · 실계좌를 쓰지 않고 응답도 합성값이다. 전송 수준(HTTP 요청 수 · F-14b S01~S13)은
//    broker_gateway `test/` 의 MockClient 가 본다(E10d) — 여기는 «순서기가 포트 응답에 어떻게 반응하는가»만.
// 🔴 각본이 비면 접수한다. 결과 불명 · 그 밖 예외도 각본으로 준다 — 순서기는 둘 다 «나갔는지 모름»으로 받아야 한다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../orders/fills.dart';
import '../orders/order_ports.dart';

/// 제출 각본 한 줄.
sealed class FakeSubmitStep {
  const FakeSubmitStep();
}

/// 접수 — [odno] 가 없으면 일련번호(10자리).
final class FakeAccept extends FakeSubmitStep {
  /// 접수 각본.
  const FakeAccept({this.odno});

  /// 돌려줄 주문번호.
  final String? odno;
}

/// 분명한 거절.
final class FakeReject extends FakeSubmitStep {
  /// 거절 각본.
  const FakeReject(this.code, this.message);

  /// 브로커 코드.
  final String code;

  /// 브로커 메시지.
  final String message;
}

/// 결과 불명([OrderOutcomeUnknown]).
final class FakeUnknown extends FakeSubmitStep {
  /// 결과 불명 각본.
  const FakeUnknown([this.message = '시간 초과(각본)']);

  /// 사유.
  final String message;
}

/// 그 밖의 예외(포트 구현 결함 · 가드 오류 등).
final class FakeThrow extends FakeSubmitStep {
  /// 예외 각본.
  const FakeThrow(this.error);

  /// 던질 예외.
  final Object error;
}

/// 결정론 가짜 브로커 — 계좌 하나.
class FakeOrderBroker implements OrderBroker {
  /// 가짜를 만든다. [cashKrw] = 예수금(기본 1조 원) · [cashError] 를 주면 예수금 조회가 그것을 던진다.
  FakeOrderBroker({
    List<FakeSubmitStep>? script,
    this.orderDate = const TradeDate('2026-11-02'),
    Decimal? cashKrw,
    this.cashError,
    Map<String, List<DailyFillRow>>? fills,
    this.onSubmit,
  }) : script = script ?? <FakeSubmitStep>[],
       cashKrw = cashKrw ?? Decimal.parse('1000000000000'),
       fills = fills ?? <String, List<DailyFillRow>>{};

  /// 남은 제출 각본(앞에서부터 쓴다).
  final List<FakeSubmitStep> script;

  /// 접수 응답의 주문일.
  final TradeDate orderDate;

  /// 예수금.
  Decimal cashKrw;

  /// 예수금 조회가 던질 예외.
  Object? cashError;

  /// 주문일(YYYY-MM-DD) → 체결조회 행.
  final Map<String, List<DailyFillRow>> fills;

  /// 제출 순간 걸이 — 원장에 행이 이미 있는지 보는 데 쓴다(04 §7 `test_intent_before_order`).
  Future<void> Function(BrokerOrderRequest request)? onSubmit;

  /// 받은 제출 요청(순서대로).
  final List<BrokerOrderRequest> submitted = <BrokerOrderRequest>[];

  /// 받은 취소(`{주문일}:{ODNO}`).
  final List<String> cancelled = <String>[];

  /// 예수금 조회 수.
  int cashReads = 0;

  int _seq = 0;

  /// 제출 호출 수(05 GV-13 «`submit_order` 호출 횟수»).
  int get submitCount => submitted.length;

  String _nextOdno() => (++_seq).toString().padLeft(10, '0');

  @override
  Future<BrokerSubmitResult> submit(BrokerOrderRequest request) async {
    submitted.add(request);
    final Future<void> Function(BrokerOrderRequest)? hook = onSubmit;
    if (hook != null) await hook(request);
    final FakeSubmitStep step = script.isEmpty
        ? const FakeAccept()
        : script.removeAt(0);
    return switch (step) {
      FakeAccept(:final String? odno) => BrokerAccepted(
        odno: odno ?? _nextOdno(),
        orderDate: orderDate,
      ),
      FakeReject(:final String code, :final String message) => BrokerRejected(
        code: code,
        message: message,
      ),
      FakeUnknown(:final String message) => throw OrderOutcomeUnknown(message),
      FakeThrow(:final Object error) => Error.throwWithStackTrace(
        error,
        StackTrace.current,
      ),
    };
  }

  @override
  Future<BrokerSubmitResult> cancel(String brokerOrderNo) async {
    cancelled.add(brokerOrderNo);
    // KIS 취소는 새 주문번호를 받는다(07 §6-3).
    return BrokerAccepted(odno: _nextOdno(), orderDate: orderDate);
  }

  @override
  Future<List<DailyFillRow>> dailyFills(TradeDate orderDate) async =>
      List<DailyFillRow>.of(
        fills[orderDate.yyyyMmDd] ?? const <DailyFillRow>[],
      );

  @override
  Future<Decimal> orderableCashKrw() async {
    cashReads++;
    final Object? error = cashError;
    if (error != null) Error.throwWithStackTrace(error, StackTrace.current);
    return cashKrw;
  }
}
