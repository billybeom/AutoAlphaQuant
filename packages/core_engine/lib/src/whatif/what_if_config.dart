// M3-1 What-if 설정 — 설계 13 §8 R18 D-2 · D-5(발주자 2026-10-21 · 추천안).
//
// 🔴 기본값은 문서에 적힌 값이다 — 02 §4 에 `what_if.*` · `pension.*` 키가 생길 때까지(06 개정 창) 이 객체가
//    그 자리를 맡는다. 값은 화면에 내려보내지 않는다(범위·만료는 엔진 문장으로만 — 06 M3-1 · M3-2 ⓐ).
// 🔴 월 납입 **운영값**(M3-6)은 여기 없다 — 전략 `config_hash` 밖의 운영 파라미터다.

import 'package:decimal/decimal.dart';

/// What-if 미리보기 설정.
class WhatIfConfig {
  const WhatIfConfig({
    required this.planTtl,
    required this.pensionAnnualLimit,
    required this.taxCreditBand,
    required this.depositMin,
    required this.depositMax,
  });

  /// 계획 스냅샷 유효기한 — 계산 시각 + 이 값(06 M3-2 ⓐ «현행 픽스처 관행 = +24h»).
  final Duration planTtl;

  /// 연금저축 + IRP 합산 연 납입한도(03 §2-7-1 · 원).
  final Decimal pensionAnnualLimit;

  /// 세액공제 대상 납입 구간(연금저축 600 + IRP 300 · `exp/tax_lib.py` `CREDIT_CAP` · 원).
  final Decimal taxCreditBand;

  /// 입금 미리보기 금액 하한 · 상한(원 · D-2 — 0 · 음수는 따로 거부한다).
  final Decimal depositMin, depositMax;

  /// 문서 값 기본판(D-5).
  static final WhatIfConfig defaults = WhatIfConfig(
    planTtl: const Duration(hours: 24),
    pensionAnnualLimit: Decimal.fromInt(18000000),
    taxCreditBand: Decimal.fromInt(9000000),
    depositMin: Decimal.one,
    depositMax: Decimal.fromInt(1000000000),
  );
}
