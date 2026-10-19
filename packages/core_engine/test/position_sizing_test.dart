// 사이징 입력 거부 — 03 §3-4 본문 조건 중 골든(GV-8e)이 다루지 않는 둘.
//
// GV-8e 의 거부 4건은 0 나눗셈으로도 우연히 «거부»가 나와 검사 하나가 빠져도
// 통과할 수 있다. 여기서는 나눗셈까지 가지 않으면 통과해 버리는 입력을 쓴다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

SizingResult _size({required String stop, int lotSize = 1}) => sizePosition(
  accountEquity: Decimal.parse('100000000'),
  entryPrice: Decimal.parse('10000'),
  stopPrice: Decimal.parse(stop),
  riskPct: 0.0035,
  notionalCapPct: 0.05,
  lotSize: lotSize,
);

void main() {
  test('손절가 0 은 거부한다(03 §3-4 «stop_price <= 0»)', () {
    expect(() => _size(stop: '0'), throwsArgumentError);
  });

  test('손절가 음수도 거부한다', () {
    expect(() => _size(stop: '-1'), throwsArgumentError);
  });

  test('lot_size 0 은 lot 검사가 거부한다(03 §3-4 «lot_size <= 0»)', () {
    // 검사가 빠져도 뒤의 0 나눗셈이 «우연히» 거부한다 — 그래서 누가 거부했는지 본다.
    expect(
      () => _size(stop: '9300', lotSize: 0),
      throwsA(
        isA<ArgumentError>().having(
          (ArgumentError e) => e.name,
          'name',
          'lotSize',
        ),
      ),
    );
  });

  test('정상 입력은 그대로 통과한다(GV-8a 와 같은 값)', () {
    final SizingResult r = _size(stop: '9300');
    expect(r.quantity, 500);
    expect(r.binding, SizingBinding.risk);
  });
}
