// E11p3b-2 — KIS 초안 시세 어댑터(설계 13 §8 R91).

import 'package:broker_gateway/broker_gateway.dart' show KisPrice;
import 'package:core_engine/core_engine.dart' show DraftQuote;
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

KisPrice _ok(String base) => KisPrice(
  price: 1,
  basePrice: Decimal.parse(base),
  tickSize: Decimal.parse('5'),
  upperLimit: Decimal.parse('99995'),
  lowerLimit: Decimal.parse('5'),
  halted: false,
);

void main() {
  test('🔴 종목 차례대로 한 번씩 · 정지 종목은 빠진다(초안기가 사유로 남긴다)', () async {
    final List<String> asked = <String>[];
    final KisDraftQuotes q = KisDraftQuotes((String s) async {
      asked.add(s);
      return s == '411060'
          ? KisPrice(
              price: 1,
              basePrice: Decimal.parse('9000'),
              tickSize: Decimal.parse('5'),
              upperLimit: Decimal.parse('11700'),
              lowerLimit: Decimal.parse('6300'),
              halted: true,
            )
          : _ok(s == '133690' ? '174180' : '100');
    });
    final Map<String, DraftQuote> m = await q.quotesFor(<String>{
      '411060',
      '214980',
      '133690',
    });
    expect(asked, <String>['133690', '214980', '411060']);
    expect(m.keys.toSet(), <String>{'133690', '214980'});
    expect(m['133690']!.previousClose, Decimal.parse('174180'));
  });

  test('🔴 조회 실패 = 배치 전체 실패(일부만 빠진 채 나가지 않는다)', () async {
    final KisDraftQuotes q = KisDraftQuotes((String s) async {
      if (s == '214980') throw StateError('KIS 오류');
      return _ok('100');
    });
    await expectLater(
      q.quotesFor(<String>{'133690', '214980'}),
      throwsStateError,
    );
  });

  test('빈 요청 = 빈 결과 · 조회 0', () async {
    int n = 0;
    final KisDraftQuotes q = KisDraftQuotes((String s) async {
      n++;
      return _ok('100');
    });
    expect(await q.quotesFor(<String>{}), isEmpty);
    expect(n, 0);
  });
}
