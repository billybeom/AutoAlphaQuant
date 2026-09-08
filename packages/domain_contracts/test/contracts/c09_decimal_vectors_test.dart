// C-9 Decimal 규약 벡터 — 01 §7 표 C-9 · §1-2 규약 5조 · 인벤토리 §9(🟢).
//
// 정의: 「GV-8a/8d/8f 를 Dart 로 재현(곱셈 선행·`Decimal.one −`)」.
// 잡는 것: **1 ULP 판정 뒤집힘**.
//
// 정본 벡터: 06_시스템설계/05_수용기준_골든벡터.md §GV-8(공통 설정 account =
//   100,000,000원 · risk_pct = 0.0035 · notional_cap_pct = 0.05 · lot_size = 1).
// 🔴 여기서 «계산» 하는 이유는 계약이 계산하기 때문이 **아니다**(01 §1-4 — 계약에는
//    산술이 없다). Dart 의 `Decimal` 이 파이썬 `Decimal` 과 **같은 답**을 내는지를
//    이식 게이트로 확인하는 것이며(00_SPEC §2 등가성 게이트), 그 답이 갈리면
//    엔진 이식 전체가 서 있는 자리가 무너진다.
// ⚠️ Dart 에서 `Decimal / Decimal` 은 **유리수(Rational)** 를 돌려준다(파이썬처럼
//    28 유효숫자로 반올림하지 않는다). 그래서 나눗셈 선행의 오차는 «비종료 소수를
//    자릿수로 끊는 순간» 또는 «double 로 내려가는 순간» 생긴다 — 아래 8f 가 그 둘을
//    모두 보여 준다.

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

/// GV-8 공통 설정.
final Decimal _accountEquity = Decimal.parse('100000000');
final Decimal _riskPct = Decimal.parse('0.0035');
final Decimal _notionalCapPct = Decimal.parse('0.05');

/// 비종료 소수를 Decimal 로 되돌릴 때 쓰는 자릿수(파이썬 Decimal 문맥의 대응물).
const int _scaleOnInfinite = 20;

/// 이중 상한 사이징 결과(03 §3-4 · GV-8).
class _Sizing {
  const _Sizing({
    required this.quantity,
    required this.binding,
    required this.notionalValue,
    required this.qtyByRisk,
    required this.qtyByNotional,
  });

  final Decimal quantity;
  final String binding;
  final Decimal notionalValue;
  final Decimal qtyByRisk;
  final Decimal qtyByNotional;
}

void main() {
  group('C-9 Decimal 규약 벡터 (01 §7 · GV-8)', () {
    test('C-9 GV-8a 두 상한이 같으면 binding 은 RISK 다(판정이 <= 이므로)', () {
      final _Sizing r = _size(entry: '10000', stop: '9300');
      expect(r.qtyByRisk, Decimal.parse('500'));
      expect(r.qtyByNotional, Decimal.parse('500'));
      expect(r.quantity, Decimal.parse('500'));
      expect(r.binding, 'RISK', reason: '두 값이 같으면 RISK 다(03 §4-1 · GV-8a).');
      expect(r.notionalValue, Decimal.parse('5000000'));
    });

    test('C-9 GV-8b 손절폭이 좁으면 명목 상한이 구해준다', () {
      final _Sizing r = _size(entry: '10000', stop: '9700');
      expect(r.quantity, Decimal.parse('500'));
      expect(r.binding, 'NOTIONAL');
      expect(r.notionalValue, Decimal.parse('5000000'));
      expect(
        r.qtyByRisk.toDouble(),
        closeTo(1166.666667, 1e-6),
        reason: 'min() 을 빠뜨린 구현은 여기서 1166 을 반환한다 — 계좌의 11.66% 다.',
      );
    });

    test('C-9 GV-8c 손절폭이 넓으면 리스크 상한이 작동한다', () {
      final _Sizing r = _size(entry: '10000', stop: '8000');
      expect(r.quantity, Decimal.parse('175'));
      expect(r.binding, 'RISK');
      expect(r.notionalValue, Decimal.parse('1750000'));
    });

    test('C-9 GV-8d 최소 거래단위 내림 — binding 은 NOTIONAL, 명목은 내림 **후** 수량 기준', () {
      final _Sizing r = _size(entry: '33333', stop: '31000', lotSize: 10);
      expect(r.qtyByRisk.toDouble(), closeTo(150.021432, 1e-6));
      expect(r.qtyByNotional.toDouble(), closeTo(150.001500, 1e-6));
      expect(r.binding, 'NOTIONAL');
      expect(r.quantity, Decimal.parse('150'));
      expect(
        r.notionalValue,
        Decimal.parse('4999950'),
        reason:
            '내림 **전** 값을 쓰면 5,000,050 이 되어 SAF-402·명목 상한 판정 입력이 '
            '달라진다(GV-8 기계 채점 블록 검산).',
      );
    });

    test('C-9 GV-8f 결합 순서 — 곱셈 선행이 정본, 나눗셈 선행·double 은 판정을 뒤집는다', () {
      final Decimal riskPerShare =
          Decimal.parse('10000') - Decimal.parse('9300');
      final Decimal notionalQty =
          ((_accountEquity * _notionalCapPct) / Decimal.parse('10000'))
              .toDecimal(scaleOnInfinitePrecision: _scaleOnInfinite);

      // ✅ 곱셈 선행(01 §0 규칙 4 — 정본).
      final Decimal multiplyFirst = ((_accountEquity * _riskPct) / riskPerShare)
          .toDecimal(scaleOnInfinitePrecision: _scaleOnInfinite);
      expect(multiplyFirst, Decimal.parse('500'));
      expect(
        multiplyFirst <= notionalQty,
        isTrue,
        reason: '500 <= 500 → binding = RISK (GV-8a 의 정답).',
      );

      // 🔴 순수 double — 문서가 적은 그대로 500.00000000000006 이 되어 뒤집힌다.
      const double equityD = 100000000;
      const double riskPctD = 0.0035;
      const double rpsD = 700;
      final double divideFirstDouble = equityD * (riskPctD / rpsD);
      expect(
        divideFirstDouble,
        greaterThan(500.0),
        reason:
            '나눗셈 선행을 double 로 하면 500 을 넘겨 binding 이 NOTIONAL 로 뒤집힌다 '
            '— GV-8a 는 완전 동률이라 1 ULP 로 갈린다.',
      );
      expect(divideFirstDouble.toString(), '500.00000000000006');

      // 🔴 Decimal 로 나눗셈을 먼저 하고 자릿수로 끊어도 값이 500 과 달라진다.
      final Decimal divideFirstTruncated =
          (_accountEquity / riskPerShare).toDecimal(
            scaleOnInfinitePrecision: _scaleOnInfinite,
          ) *
          _riskPct;
      expect(
        divideFirstTruncated,
        isNot(Decimal.parse('500')),
        reason: '비종료 소수를 자릿수로 끊은 뒤 곱하면 동률이 깨진다 — 규칙 4 가 막는 것이 이것이다.',
      );
    });

    test('C-9 규약 ⑤ (1 − 비율)은 Decimal 안에서 계산한다', () {
      // 01 §1-2 규약 5조 ⑤ — `entry * (Decimal.one - Decimal.parse('0.07'))`.
      final Decimal entry = Decimal.parse('10000');
      final Decimal stop = entry * (Decimal.one - Decimal.parse('0.07'));
      expect(
        stop,
        Decimal.parse('9300'),
        reason: 'TIER 1B 절대손절 −7.0% 의 기준선이다.',
      );

      // 🔴 같은 식을 double 로 하면 **중간값이 이미 틀린다**.
      //    ⚠️ 10,000 × 0.9299999999999999 는 반올림이 우연히 9300.0 으로 돌아온다 —
      //       「double 로 해도 맞더라」는 이 우연을 일반화한 오독이다. 그래서 검사는
      //       결과가 아니라 **중간값**을 본다.
      expect((1 - 0.07).toString(), '0.9299999999999999');
      expect(
        Decimal.one - Decimal.parse('0.07'),
        Decimal.parse('0.93'),
        reason: 'Decimal 안에서는 중간값이 정확히 0.93 이다.',
      );
    });

    test('C-9 규약 ① 금액 × 비율은 비율을 문자열로 승격한 뒤 곱한다', () {
      const double riskPct = 0.0035;
      // ✅ 정본 — `Decimal.parse(r.toString())`.
      final Decimal promoted = Decimal.parse(riskPct.toString());
      expect(promoted, Decimal.parse('0.0035'));
      expect(_accountEquity * promoted, Decimal.parse('350000'));

      // 🔴 double 을 그대로 태우는 경로는 계약에 없다 — 있으면 여기서 값이 갈린다.
      expect(
        Decimal.parse((0.1 + 0.2).toString()),
        isNot(Decimal.parse('0.3')),
        reason: '0.1 + 0.2 는 double 에서 0.30000000000000004 다 — 승격은 «연산 전»에 한다.',
      );
    });
  });
}

/// 이중 상한 사이징(GV-8). 🔴 곱셈 먼저, 나눗셈 나중 — 01 §1-2 규약 5조 ④.
_Sizing _size({required String entry, required String stop, int lotSize = 1}) {
  final Decimal entryPrice = Decimal.parse(entry);
  final Decimal riskPerShare = entryPrice - Decimal.parse(stop);

  final Decimal qtyByRisk = ((_accountEquity * _riskPct) / riskPerShare)
      .toDecimal(scaleOnInfinitePrecision: _scaleOnInfinite);
  final Decimal qtyByNotional =
      ((_accountEquity * _notionalCapPct) / entryPrice).toDecimal(
        scaleOnInfinitePrecision: _scaleOnInfinite,
      );

  // 🔴 판정은 `<=` 다 — 두 값이 같으면 RISK(03 §4-1 · GV-8a).
  final bool riskBinding = qtyByRisk <= qtyByNotional;
  final Decimal raw = riskBinding ? qtyByRisk : qtyByNotional;

  final Decimal lot = Decimal.fromInt(lotSize);
  final Decimal quantity =
      (raw / lot)
          .toDecimal(scaleOnInfinitePrecision: _scaleOnInfinite)
          .floor() *
      lot;

  return _Sizing(
    quantity: quantity,
    binding: riskBinding ? 'RISK' : 'NOTIONAL',
    // 🔴 명목가는 **lot 내림 후** 수량 기준이다(03 §3-4 검산).
    notionalValue: quantity * entryPrice,
    qtyByRisk: qtyByRisk,
    qtyByNotional: qtyByNotional,
  );
}
