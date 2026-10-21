// M3-1 ⓐ — 입금 미리보기 금액 입력 판정(`WhatIfApi.simulateDeposit({amountInput})` · 01 §14-3 · C-38 ①).
//
// 🔴 화면은 **입력칸 글자 그대로** 넘긴다 — 자르기·쉼표 제거·숫자 검사를 화면이 하지 않는다(01 §14-3).
// 🔵 문법(설계 13 §8 R18 D-2 · 발주자 2026-10-21): 앞뒤 공백과 ASCII 쉼표만 지우고 **원 단위 양의 정수**만 받는다.
//    빈칸 · 숫자 아님(«10만» · «100000원» · «1e5» · 전각 숫자 · 소수 · «+») · 0 · 음수 · 범위 밖을 거부한다.
//    쉼표 자리는 보지 않는다(«1,0000» 도 1만으로 읽는다 — 사람이 친 쉼표를 고치라고 하지 않는다).
// 🔴 거부 문장은 엔진이 만든다 — 기본 문장 «금액을 원 단위 숫자로 입력해 주세요.»(픽스처 `m7_deposit_plan_input_rejected`).

import 'package:decimal/decimal.dart';

import 'what_if_config.dart';
import 'what_if_text.dart';

/// 금액 입력 판정 결과 — 받아들인 금액([amount]) 또는 거부 문장([rejectedText]) 중 정확히 하나.
class AmountInput {
  const AmountInput._(this.amount, this.rejectedText);

  /// 받아들인 금액(원).
  final Decimal? amount;

  /// 거부 문장(엔진 생성 · 화면은 그대로 그린다).
  final String? rejectedText;
}

/// 빈칸.
const String kAmountBlankText = '금액을 입력해 주세요.';

/// 숫자 아님(픽스처 문장).
const String kAmountNotNumberText = '금액을 원 단위 숫자로 입력해 주세요.';

/// 0 · 음수.
const String kAmountNotPositiveText = '0원보다 큰 금액을 입력해 주세요.';

final RegExp _digits = RegExp(r'^[0-9]+$');
final RegExp _negative = RegExp(r'^-[0-9]+$');

/// [input](입력칸 글자 그대로)을 판정한다.
AmountInput parseAmountInput(String input, WhatIfConfig cfg) {
  final String s = input.trim().replaceAll(',', '');
  if (s.isEmpty) return const AmountInput._(null, kAmountBlankText);
  if (_negative.hasMatch(s)) {
    return const AmountInput._(null, kAmountNotPositiveText);
  }
  if (!_digits.hasMatch(s)) {
    return const AmountInput._(null, kAmountNotNumberText);
  }
  final Decimal v = Decimal.parse(s);
  if (v == Decimal.zero) {
    return const AmountInput._(null, kAmountNotPositiveText);
  }
  if (v < cfg.depositMin || v > cfg.depositMax) {
    return AmountInput._(
      null,
      '${wonText(cfg.depositMin)}부터 ${wonText(cfg.depositMax)}까지 입력할 수 있습니다.',
    );
  }
  return AmountInput._(v, null);
}
