// E11p3b-2 — KIS 현재가 → 초안 시세 · 현재가(설계 13 §8 R91).

import 'package:broker_gateway/broker_gateway.dart';
import 'package:core_engine/core_engine.dart' show DraftQuote;
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

KisPrice _p({
  double price = 17450,
  String? base = '17400',
  String? tick = '5',
  String? up = '22620',
  String? low = '12180',
  bool? halted = false,
}) => KisPrice(
  price: price,
  basePrice: base == null ? null : _d(base),
  tickSize: tick == null ? null : _d(tick),
  upperLimit: up == null ? null : _d(up),
  lowerLimit: low == null ? null : _d(low),
  halted: halted,
);

void main() {
  test('🔴 기준가 → 직전 종가 · 호가 · 상하한 그대로', () {
    final DraftQuote q = draftQuoteOf(_p())!;
    expect(q.previousClose, _d('17400'));
    expect(q.tickSize, _d('5'));
    expect(q.upperLimit, _d('22620'));
    expect(q.lowerLimit, _d('12180'));
  });

  test('🔴 정지 · 정지 모름 · 칸 하나라도 없음 = 시세 없음(fail-closed)', () {
    expect(draftQuoteOf(_p(halted: true)), isNull);
    expect(draftQuoteOf(_p(halted: null)), isNull);
    expect(draftQuoteOf(_p(base: null)), isNull);
    expect(draftQuoteOf(_p(tick: null)), isNull);
    expect(draftQuoteOf(_p(up: null)), isNull);
    expect(draftQuoteOf(_p(low: null)), isNull);
  });

  test('값이 앞뒤가 안 맞으면 그대로 넘긴다(초안기가 QUOTE_INVALID 로 가른다)', () {
    final DraftQuote q = draftQuoteOf(_p(low: '30000'))!;
    expect(q.isValid, false);
  });

  test('🔴 현재가 — 정지 · 0 이하 · 유한하지 않음 = null · 정지 모름은 값 그대로', () async {
    Future<Decimal?> run(KisPrice p) =>
        kisCurrentPrice((String _) async => p)('133690');
    expect(await run(_p()), _d('17450'));
    expect(await run(_p(halted: null)), _d('17450'));
    expect(await run(_p(halted: true)), isNull);
    expect(await run(_p(price: 0)), isNull);
    expect(await run(_p(price: double.nan)), isNull);
  });

  test('현재가 조회 실패는 그대로 던진다', () async {
    await expectLater(
      kisCurrentPrice((String _) async => throw StateError('망'))('133690'),
      throwsStateError,
    );
  });
}
