// 🆕 E15f4a — 커밋 직전 계좌 조회 어댑터(브로커 포트 → LiveAccountProbe · 설계 13 §8 R103 AI6).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const TradeDate _today = TradeDate('2027-01-13');
final DateTime _at = DateTime.utc(2027, 1, 13, 1, 58);

DailyFillRow _row(String odno, {bool cancel = false, TradeDate day = _today}) =>
    DailyFillRow(
      orderDate: day,
      odno: odno,
      isCancelRow: cancel,
      symbol: '133690',
      side: OrderSide.buy,
      orderQty: 5,
      cumFilledQty: 0,
      cumFilledAmount: Decimal.zero,
      remainingQty: 5,
    );

Future<LiveAccountProbe?> _probe(FakeOrderBroker b) => probeLiveAccount(
  alias: 'general',
  accountMark: 'mark-general',
  broker: b,
  today: _today,
  fetchedAtUtc: _at,
);

void main() {
  test(
    '보유 = 수량 > 0 종목 수 · 예수금 = D+2 원 단위 내림 · 오늘 행 수(취소 행 포함) · 조회 시각 = 준 값',
    () async {
      final FakeOrderBroker b = FakeOrderBroker(
        cashKrw: Decimal.parse('1200000.9'),
        fills: <String, List<DailyFillRow>>{
          '2027-01-13': <DailyFillRow>[_row('1'), _row('2', cancel: true)],
          '2027-01-12': <DailyFillRow>[_row('3')],
        },
      );
      b.holdings.addAll(<String, int>{'133690': 0, '360750': 3, '069500': 1});
      final LiveAccountProbe p = (await _probe(b))!;
      expect(p.alias, 'general');
      // 🆕 R262(A-2) — 계좌 표지 = 부른 쪽이 준 값 그대로.
      expect(p.accountMark, 'mark-general');
      expect(p.holdingsCount, 2);
      expect(p.orderableCashKrw, 1200000);
      expect(p.activityToday, 2);
      expect(p.fetchedAtUtc, _at);
    },
  );

  test('비어 있는 계좌 = 보유 0 · 활동 0', () async {
    final LiveAccountProbe p = (await _probe(
      FakeOrderBroker(cashKrw: Decimal.fromInt(500000)),
    ))!;
    expect(
      (p.holdingsCount, p.orderableCashKrw, p.activityToday),
      (0, 500000, 0),
    );
  });

  test('음수 예수금은 그대로 내림(게이트가 «모름»으로 막는다)', () async {
    final LiveAccountProbe p = (await _probe(
      FakeOrderBroker(cashKrw: Decimal.parse('-0.5')),
    ))!;
    expect(p.orderableCashKrw, -1);
  });

  test('조회 하나라도 예외 = null(그 계좌 조회 없음)', () async {
    final FakeOrderBroker a = FakeOrderBroker()..balanceError = StateError('x');
    expect(await _probe(a), isNull);
    expect(await _probe(FakeOrderBroker(cashError: Exception('y'))), isNull);
    expect(await _probe(FakeOrderBroker(fillsError: Exception('z'))), isNull);
  });
}
