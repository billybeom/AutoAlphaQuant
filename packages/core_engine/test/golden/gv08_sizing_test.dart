// GV-8 이중 상한 사이징 — 05 §GV-8(8a~8f) · 03 §3-4 · 06 M1-1 검증 게이트.
//
// 정답지 둘:
//   gv08_sizing.json        — 파일럿1 원본(8a~8d · 8e 예외 4)
//   gv08_machine_block.json — 05 §GV-8 «기계 채점 블록»(notional_value · exact_fields 포함)
// 🔵 v2.31 P0S 에서 GV-8 은 채점 외(새틀라이트 비활성)지만 Decimal 규약의 게이트다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  group('GV-8 파일럿1 정답지 (gv08_sizing.json)', () {
    final Map<String, Object?> vector = loadVector('gv08_sizing.json');
    final Map<String, Object?> common = asObject(vector['common']);
    final double tolerance = asDouble(vector['tolerance']);

    SizingResult size(Map<String, Object?> c) => sizePosition(
      accountEquity: asDecimal(common['account']),
      entryPrice: asDecimal(c['entry']),
      stopPrice: asDecimal(c['stop']),
      riskPct: asDouble(common['risk_pct']),
      notionalCapPct: asDouble(common['notional_cap_pct']),
      lotSize: asInt(c['lot_size'] ?? common['lot_size']),
    );

    for (final Map<String, Object?> c in asObjectList(vector['cases'])) {
      final String id = asString(c['id']);
      final Map<String, Object?> expected = asObject(c['expected']);
      test('GV-$id 수량·binding·두 상한', () {
        final SizingResult r = size(c);
        expect(r.quantity, asInt(expected['quantity']));
        expect(r.binding.code, asString(expected['binding']));
        expect(
          r.qtyByRisk.toDouble(),
          closeTo(asDouble(expected['qty_by_risk']), tolerance),
        );
        expect(
          r.qtyByNotional.toDouble(),
          closeTo(asDouble(expected['qty_by_notional']), tolerance),
        );
      });
    }

    for (final Map<String, Object?> c in asObjectList(
      vector['exception_cases'],
    )) {
      final String id = asString(c['id']);
      if (c['expect'] == 'ValueError') {
        test('GV-$id 규칙 밖 입력은 거부한다(ValueError ↔ ArgumentError)', () {
          expect(() => size(c), throwsArgumentError);
        });
      } else {
        final Map<String, Object?> expected = asObject(c['expected']);
        test('GV-$id 손절폭 1원 — 명목 상한이 막는다', () {
          final SizingResult r = size(c);
          expect(r.quantity, asInt(expected['quantity']));
          expect(r.binding.code, asString(expected['binding']));
        });
      }
    }
  });

  group('GV-8 기계 채점 블록 (05 §GV-8 · gv08_machine_block.json)', () {
    final Map<String, Object?> vector = loadVector('gv08_machine_block.json');
    final Map<String, Object?> common = asObject(vector['common']);
    final double tolerance = asDouble(vector['tolerance']);

    test('정확 일치 필드 목록이 이 테스트가 보는 셋과 같다', () {
      expect(asStringList(vector['exact_fields']), <String>[
        'quantity',
        'binding',
        'notional_value',
      ]);
    });

    for (final Map<String, Object?> c in asObjectList(vector['cases'])) {
      final String id = asString(c['id']);
      final Map<String, Object?> expected = asObject(c['expected']);
      test('GV-$id 정확 일치(quantity·binding·notional_value) + 근사(두 상한)', () {
        final SizingResult r = sizePosition(
          accountEquity: asDecimal(common['account_equity']),
          entryPrice: asDecimal(c['entry']),
          stopPrice: asDecimal(c['stop']),
          riskPct: asDouble(common['risk_pct']),
          notionalCapPct: asDouble(common['notional_cap_pct']),
          lotSize: asInt(c['lot_size'] ?? common['lot_size']),
        );
        expect(r.quantity, asInt(expected['quantity']));
        expect(r.binding.code, asString(expected['binding']));
        expect(
          r.notionalValue,
          asDecimal(expected['notional_value']),
          reason: '명목가는 lot 내림 **후** 수량 × 진입가다(03 §3-4).',
        );
        expect(
          r.qtyByRisk.toDouble(),
          closeTo(asDouble(expected['qty_by_risk']), tolerance),
        );
        expect(
          r.qtyByNotional.toDouble(),
          closeTo(asDouble(expected['qty_by_notional']), tolerance),
        );
      });
    }
  });

  test('두 정답지가 8a~8d 에서 같은 수량·binding 을 말한다', () {
    Map<String, Map<String, Object?>> byId(String file) =>
        <String, Map<String, Object?>>{
          for (final Map<String, Object?> c in asObjectList(
            loadVector(file)['cases'],
          ))
            asString(c['id']): asObject(c['expected']),
        };
    final Map<String, Map<String, Object?>> pilot = byId('gv08_sizing.json');
    final Map<String, Map<String, Object?>> spec = byId(
      'gv08_machine_block.json',
    );
    expect(pilot.keys.toSet(), spec.keys.toSet());
    for (final String id in spec.keys) {
      expect(
        asInt(pilot[id]!['quantity']),
        asInt(spec[id]!['quantity']),
        reason: id,
      );
      expect(pilot[id]!['binding'], spec[id]!['binding'], reason: id);
    }
  });

  group('GV-8f 결합 순서 — 곱셈 선행이 정본 (05 §GV-8f · 01 §0 규칙 4)', () {
    final Decimal equity = Decimal.parse('100000000');
    final Decimal riskPerShare = Decimal.parse('700');
    final Decimal qtyByNotional = mulDiv(
      equity,
      promoteRatio(0.05),
      Decimal.parse('10000'),
    );

    test('곱셈 선행 = 500 — 동률이라 binding 은 RISK', () {
      final Decimal qtyByRisk = mulDiv(
        equity,
        promoteRatio(0.0035),
        riskPerShare,
      );
      expect(qtyByRisk, Decimal.parse('500'));
      expect(qtyByNotional, Decimal.parse('500'));
      expect(qtyByRisk <= qtyByNotional, isTrue);
    });

    test('나눗셈 선행은 파이썬과 같은 값(500.0000000000000000000000002)으로 뒤집힌다', () {
      // 01 §0 의 파이썬 예시 그대로: (D(100_000_000) / D(700)) * D("0.0035")
      final Decimal divided = divide(equity, riskPerShare);
      expect(divided, Decimal.parse('142857.1428571428571428571429'));
      final Decimal divideFirst = multiply(divided, promoteRatio(0.0035));
      expect(divideFirst, Decimal.parse('500.0000000000000000000000002'));
      expect(
        divideFirst <= qtyByNotional,
        isFalse,
        reason: '나눗셈을 먼저 하면 binding 이 NOTIONAL 로 뒤집힌다 — GV-8a 의 정답은 RISK.',
      );
    });

    test('순수 double 나눗셈 선행도 1 ULP 로 뒤집힌다(500.00000000000006)', () {
      const double divideFirst = 100000000 * (0.0035 / 700);
      expect(divideFirst.toString(), '500.00000000000006');
      expect(divideFirst > 500, isTrue);
    });
  });
}
