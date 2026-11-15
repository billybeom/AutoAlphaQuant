// E16d1 — 역분개 계획(설계 13 §8 R121 F6 · F7 · 01 §10-3).
//
// 🔵 잡는 것: ① 저장 양수 · REVERSAL = 음수 합산 ② 무효 = REVERSAL 하나 ③ 정정 = REVERSAL(원) + RESTATEMENT(새)
//    ④ 종목 · 방향 바뀜 → 체인 상한 → 바뀌는 것 없음 차례 거부 ⑤ 합산 = 새 값.
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

FillSnapshot _f({int depth = 0}) => FillSnapshot(
  fillId: 'ex-1',
  symbol: '069500',
  side: 'BUY',
  quantity: 120,
  price: 35000,
  chainDepth: depth,
);

void main() {
  test('🔴 부호 — 저장은 양수 · REVERSAL 만 음수 · 0 이하 저장 = ArgumentError', () {
    expect(signedFillQuantity(FillKind.reversal, 8), -8);
    expect(signedFillQuantity(FillKind.restatement, 8), 8);
    expect(signedFillQuantity(FillKind.original, 8), 8);
    expect(
      () => signedFillQuantity(FillKind.reversal, -8),
      throwsArgumentError,
    );
    expect(() => signedFillQuantity(FillKind.original, 0), throwsArgumentError);
  });

  test('🔴 무효 = REVERSAL 하나(원 수량 · 원 가격 · reverses) · 합 = 0', () {
    final List<PlannedFillRow> p = voidFillPlan(_f());
    expect(p, hasLength(1));
    expect(
      (
        p.single.kind,
        p.single.quantity,
        p.single.price,
        p.single.reversesFillId,
      ),
      (FillKind.reversal, 120, 35000.0, 'ex-1'),
    );
    expect(p.single.restatesFillId, isNull);
    expect(120 + p.single.signedQuantity, 0);
  });

  test('🔴 정정 = REVERSAL(원) + RESTATEMENT(새) · 합 = 새 수량', () {
    final List<PlannedFillRow> p = amendFillPlan(
      _f(),
      symbol: '069500',
      side: 'BUY',
      quantity: 132,
      price: 35000,
      chainLimit: 2,
    );
    expect(p.map((PlannedFillRow r) => r.kind), <FillKind>[
      FillKind.reversal,
      FillKind.restatement,
    ]);
    expect((p[0].quantity, p[0].reversesFillId), (120, 'ex-1'));
    expect(
      (p[1].quantity, p[1].restatesFillId, p[1].price),
      (132, 'ex-1', 35000.0),
    );
    expect(
      120 + p.fold<int>(0, (int s, PlannedFillRow r) => s + r.signedQuantity),
      132,
    );
  });

  test('🔴 거부 차례 — 종목 · 방향 바뀜 → 체인 상한 → 바뀌는 것 없음', () {
    String? code(
      FillSnapshot f, {
      String symbol = '069500',
      String side = 'BUY',
      int quantity = 132,
      double price = 35000,
    }) => amendFillRejectCode(
      f,
      symbol: symbol,
      side: side,
      quantity: quantity,
      price: price,
      chainLimit: 2,
    );
    expect(
      code(_f(), symbol: '114800'),
      AdviceRejectCodes.amendSymbolOrSideChange,
    );
    expect(code(_f(), side: 'SELL'), AdviceRejectCodes.amendSymbolOrSideChange);
    expect(
      code(_f(depth: 2), side: 'SELL'),
      AdviceRejectCodes.amendSymbolOrSideChange,
      reason: '종목 · 방향이 먼저',
    );
    expect(code(_f(depth: 2)), AdviceRejectCodes.amendLimitExceeded);
    expect(code(_f(depth: 1)), isNull);
    expect(code(_f(), quantity: 120), RepairCodes.noChange);
    expect(code(_f(), quantity: 120, price: 35100), isNull);
    expect(
      () => amendFillPlan(
        _f(depth: 2),
        symbol: '069500',
        side: 'BUY',
        quantity: 132,
        price: 35000,
        chainLimit: 2,
      ),
      throwsStateError,
    );
  });

  test('인자 꼴 — 체인 상한 0 · 새 수량 0 · 스냅숏 0 이하 = ArgumentError', () {
    expect(
      () => amendFillRejectCode(
        _f(),
        symbol: '069500',
        side: 'BUY',
        quantity: 1,
        price: 1,
        chainLimit: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => amendFillPlan(
        _f(),
        symbol: '069500',
        side: 'BUY',
        quantity: 0,
        price: 35000,
        chainLimit: 2,
      ),
      throwsArgumentError,
    );
    expect(
      () => FillSnapshot(
        fillId: 'x',
        symbol: 's',
        side: 'BUY',
        quantity: 0,
        price: 1,
        chainDepth: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => FillSnapshot(
        fillId: 'x',
        symbol: 's',
        side: 'BUY',
        quantity: 1,
        price: 1,
        chainDepth: -1,
      ),
      throwsArgumentError,
    );
  });
}
