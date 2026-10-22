// M3-1 차단 표 — 미리보기를 계산할지·등록을 막을지(06 M3-1 ⓑ D21 · v1.6 ⓐ H64 · 01 §14-3 · §15-4).
//
// 🔵 설계 13 §8 R18(발주자 2026-10-21 · 추천안):
//    D-3 차단이 입력 거부보다 먼저(입력과 무관한 상태라 글자를 고쳐도 소용없다) · 등록 불가 사유가 둘 이상이면
//        RECON_MISMATCH > LEDGER_FIX > 만료 하나만.
//    D-10 차단 플래그에 해소 링크(`clearDeepLink`)가 있으면 그것을 버튼으로 준다(H64 조문 — LEDGER_INTEGRITY 의
//        복구 위저드 포함). 입금 미리보기도 같은 규칙이다(D21 «필요하면 blockedAction»).
// 🔴 차단끼리 겹치면 하나만 말한다 — 원장 무결성 > 복구 모드 > 재개 미완 > (입금) 계좌 매핑 미완 · (리밸런싱) 예정 없음.
// 🔴 06 표에 없는 플래그(JOURNAL_MISSING · DST_WEEK · X7 계열 등)는 미리보기에 영향을 주지 않는다.
// 🔴 문장은 엔진이 만든다 — 픽스처에 있는 문장은 글자 그대로(`m7_deposit_plan_blocked` · `_funding` · `_expired` ·
//    `m7_rebalance_preview_blocked` · `m7_next_rebalance_none`), 없는 것(복구 모드 · 매핑 미완 · 원장 정정 · 리밸런싱
//    경고 · 복구 위저드 버튼)은 같은 꼴로 지었다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'amount_input.dart';
import 'what_if_config.dart';
import 'what_if_state.dart';

/// 입금 미리보기 차단 문장.
abstract final class DepositGateTexts {
  static const String integrity = '원장 무결성 점검 중에는 미리보기를 계산하지 않습니다.';
  static const String recovery =
      '복구 모드에서는 미리보기를 계산하지 않습니다. 복구가 끝난 뒤 다시 계산해 주세요.';
  static const String resume =
      '재개 점검이 끝나지 않아 미리보기를 계산하지 않습니다. 재개 리포트를 먼저 확인해 주세요.';
  static const String mapping = '슬리브 B 의 연금저축 계좌가 지정되지 않아 미리보기를 계산하지 않습니다.';
  static const String registerRecon =
      '브로커 잔고 대조가 끝나지 않아 이 계획으로는 입금을 등록할 수 없습니다.';
  static const String registerLedgerFix =
      '원장 정정이 끝나지 않아 이 계획으로는 입금을 등록할 수 없습니다.';
  static const String registerExpired =
      '이 계획은 만료되어 실입금을 등록할 수 없습니다. 다시 계산해 새 계획을 받아 주세요.';

  /// 🆕 E7b3(R22 D13 · 06 M3-2 ⓒ «금액 범위») — 그사이 남은 연금 납입 한도가 계획의 B 몫보다 작아졌다.
  static const String registerPensionQuota =
      '연금 납입 한도가 그사이 줄어 이 계획의 연금 몫을 넣을 수 없습니다. 다시 계산해 새 계획을 받아 주세요.';
}

/// 리밸런싱 미리보기 차단·경고 문장.
abstract final class RebalanceGateTexts {
  static const String noPlannedDate = '예정된 리밸런싱 회차가 아직 없습니다.';
  static const String integrity = '원장 무결성 점검 중에는 리밸런싱 초안을 계산하지 않습니다.';
  static const String recovery =
      '복구 모드에서는 리밸런싱 초안을 계산하지 않습니다. 복구가 끝난 뒤 다시 확인해 주세요.';
  static const String resume =
      '재개 점검이 끝나지 않아 초안을 계산하지 않습니다. 재개 리포트를 먼저 확인해 주세요.';
  static const String warnRecon = '브로커 잔고 대조가 끝나지 않아 초안의 수량이 실제 잔고와 다를 수 있습니다.';
  static const String warnLedgerFix = '원장 정정이 끝나지 않아 초안의 수량이 실제 잔고와 다를 수 있습니다.';
}

/// 차단 버튼 이름(플래그별) — 목적지는 그 플래그의 `clearDeepLink`.
const Map<String, String> kGateButtonLabels = <String, String>{
  FlagIds.resumeIncomplete: '재개 리포트 보기',
  FlagIds.ledgerIntegrity: '복구 위저드 열기',
};

/// 관문 판정 — 차단이면 [blockedText](+ [blockedAction]) · 아니면 계획에 실을 [warningLines] · [registerBlockedText].
class WhatIfGate {
  const WhatIfGate({
    this.blockedText,
    this.blockedAction,
    this.warningLines = const <String>[],
    this.registerBlockedText,
  });

  final String? blockedText;
  final LinkAction? blockedAction;
  final List<String> warningLines;

  /// 입금 계획 등록 불가 문장(만료 제외 — 만료는 [depositRegisterBlockedText] 가 시각과 함께 본다).
  final String? registerBlockedText;

  bool get blocked => blockedText != null;
}

LinkAction? _button(BlockFlag? f) {
  final String? link = f?.clearDeepLink;
  final String? label = f == null ? null : kGateButtonLabels[f.flagId];
  return link == null || label == null
      ? null
      : LinkAction(label: label, deepLink: link);
}

/// 입금 미리보기 관문(D21).
WhatIfGate depositGate(WhatIfState s) {
  final BlockFlag? integrity = s.flag(FlagIds.ledgerIntegrity);
  if (integrity != null) {
    return WhatIfGate(
      blockedText: DepositGateTexts.integrity,
      blockedAction: _button(integrity),
    );
  }
  if (s.recovery) {
    return const WhatIfGate(blockedText: DepositGateTexts.recovery);
  }
  final BlockFlag? resume = s.flag(FlagIds.resumeIncomplete);
  if (resume != null) {
    return WhatIfGate(
      blockedText: DepositGateTexts.resume,
      blockedAction: _button(resume),
    );
  }
  if (s.accounts.pensionAlias == null) {
    return const WhatIfGate(blockedText: DepositGateTexts.mapping);
  }
  // 새 계획은 B 몫을 남은 한도로 자르므로 한도 부족이 생기지 않는다(deposit_plan.dart).
  return WhatIfGate(
    registerBlockedText: depositRegisterBlockedText(
      s,
      expired: false,
      quotaShort: false,
    ),
  );
}

/// 입금 계획 등록 불가 문장 — RECON_MISMATCH > LEDGER_FIX > 만료 > 연금 한도(D-3 · 🆕 E7b3 R22 D13) · 없으면 null(등록 버튼).
/// [quotaShort] = 지금 남은 연금 납입 한도 < 계획의 B 몫.
String? depositRegisterBlockedText(
  WhatIfState s, {
  required bool expired,
  required bool quotaShort,
}) {
  if (s.flag(FlagIds.reconMismatch) != null) {
    return DepositGateTexts.registerRecon;
  }
  if (s.flag(FlagIds.ledgerFix) != null) {
    return DepositGateTexts.registerLedgerFix;
  }
  if (expired) return DepositGateTexts.registerExpired;
  return quotaShort ? DepositGateTexts.registerPensionQuota : null;
}

/// 리밸런싱 미리보기 관문(H64) — [hasPlannedDate] = 다음 정기 회차가 있는가.
WhatIfGate rebalanceGate(WhatIfState s, {required bool hasPlannedDate}) {
  final BlockFlag? integrity = s.flag(FlagIds.ledgerIntegrity);
  if (integrity != null) {
    return WhatIfGate(
      blockedText: RebalanceGateTexts.integrity,
      blockedAction: _button(integrity),
    );
  }
  if (s.recovery) {
    return const WhatIfGate(blockedText: RebalanceGateTexts.recovery);
  }
  final BlockFlag? resume = s.flag(FlagIds.resumeIncomplete);
  if (resume != null) {
    return WhatIfGate(
      blockedText: RebalanceGateTexts.resume,
      blockedAction: _button(resume),
    );
  }
  if (!hasPlannedDate) {
    return const WhatIfGate(blockedText: RebalanceGateTexts.noPlannedDate);
  }
  return WhatIfGate(
    warningLines: <String>[
      if (s.flag(FlagIds.reconMismatch) != null) RebalanceGateTexts.warnRecon,
      if (s.flag(FlagIds.ledgerFix) != null) RebalanceGateTexts.warnLedgerFix,
    ],
  );
}

/// 입금 미리보기 앞단 — 차단이나 입력 거부면 [stop](결과 그대로) · 아니면 받아들인 [amount] 와 [gate].
class DepositPreflight {
  const DepositPreflight._(this.stop, this.amount, this.gate);

  /// 계산하지 않고 돌려줄 결과(차단 또는 입력 거부 — 정확히 한 갈래 · C-38 ①).
  final DepositPreviewResult? stop;
  final Decimal? amount;
  final WhatIfGate gate;
}

/// [amountInput](입력칸 글자 그대로)과 상태로 앞단을 판정한다 — 차단 먼저(D-3).
DepositPreflight depositPreflight(
  WhatIfState s,
  String amountInput,
  WhatIfConfig cfg,
) {
  final WhatIfGate gate = depositGate(s);
  if (gate.blocked) {
    return DepositPreflight._(
      DepositPreviewResult(
        blockedText: gate.blockedText,
        blockedAction: gate.blockedAction,
      ),
      null,
      gate,
    );
  }
  final AmountInput a = parseAmountInput(amountInput, cfg);
  if (a.rejectedText != null) {
    return DepositPreflight._(
      DepositPreviewResult(inputRejectedText: a.rejectedText),
      null,
      gate,
    );
  }
  return DepositPreflight._(null, a.amount, gate);
}

/// 리밸런싱 미리보기 앞단 — 차단이면 결과(정확히 한 갈래 · C-41 ①) · 아니면 null.
RebalancePreviewResult? rebalancePreflight(
  WhatIfState s, {
  required bool hasPlannedDate,
}) {
  final WhatIfGate gate = rebalanceGate(s, hasPlannedDate: hasPlannedDate);
  return gate.blocked
      ? RebalancePreviewResult(
          blockedText: gate.blockedText,
          blockedAction: gate.blockedAction,
        )
      : null;
}
