// 🆕 E11q3 — M9 S13 월 납입 설정 VM · «바꾸기» 결과(설계 13 §8 R174 · 01 §32 K75~K79 · 표본 `m9/monthly_contribution*` ·
// `m9/contribution_action_results`).
//
// 🔴 VM = `ContributionSetting` 의 1:1 투영(같은 이름 · N-S4-03) + 버튼 글자 — 화면이 필드를 이어 붙이지 않는다.
// 🔴 [canChange] = 조립 앱이 쓰기 창구를 줄 수 있나(이 기기 id 가 있나) — false = 입력칸 · 버튼 부재(`changeLabel` null).
//    판정(빈칸 · 숫자 · 범위 · 같은 금액 · 신뢰 시각 · 같은 순간)은 엔진 `decideContributionChange` 의 몫이고 결과 문장도 그것이다.
// 🔵 생체 «보기만»(`lockedLabel`) = 운영 등급 공통 관문(S09 · S10 · S13) — 이 조각 밖(S10 R160 선례 · 지금 0).

import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        ContributionSetting,
        MonthlyContributionVm,
        SettingsActionId,
        UiLevel;

import 'contribution_setting.dart' show ContributionRejectCodes;

/// S13 글자(표본 그대로 — 표본의 «(합성)» 표지는 뺀다).
abstract final class MonthlyContributionTexts {
  /// 바꾸기 버튼(표본 `monthly_contribution`).
  static const String change = '바꾸기';

  /// 접수(표본 `ar_s13_01`).
  static const String accepted = '새 금액을 접수했습니다. 다음 납입 주기부터 적용됩니다.';
}

/// S13 VM — [canChange] = 쓰기 창구가 있나.
MonthlyContributionVm monthlyContributionVmOf(
  ContributionSetting s, {
  required bool canChange,
}) => MonthlyContributionVm(
  amountText: s.amountText,
  amountInputText: s.amountInputText,
  equivalentNoteText: s.equivalentNoteText,
  appliesFromText: s.appliesFromText,
  lastChangedText: s.lastChangedText,
  editable: canChange,
  pensionLimitNoteText: s.pensionLimitNoteText,
  asOf: s.asOf,
  changeLabel: canChange ? MonthlyContributionTexts.change : null,
);

/// «바꾸기» 결과 — [reasonCode] null = 접수(새 행 · 같은 회차 재시도) · 아니면 엔진 거부 문장 [rejectedText] 그대로.
/// 수준 = 표본(입력 = ACT · 신뢰 시각 = BLOCKED · 같은 순간 = WATCH · 같은 금액 = INFO · 접수 = OK).
ActionResult contributionUpdateResultOf({
  required String actionRunId,
  required String? reasonCode,
  required String? rejectedText,
}) {
  if (reasonCode != null && (rejectedText == null || rejectedText.isEmpty)) {
    throw ArgumentError.value(rejectedText, 'rejectedText', '거부에는 엔진 문장이 있다');
  }
  final UiLevel level = switch (reasonCode) {
    null => UiLevel.ok,
    ContributionRejectCodes.trustedTimeUnknown => UiLevel.blocked,
    ContributionRejectCodes.clockNotAdvanced => UiLevel.watch,
    ContributionRejectCodes.unchanged => UiLevel.info,
    ContributionRejectCodes.blank ||
    ContributionRejectCodes.notNumber ||
    ContributionRejectCodes.negative ||
    ContributionRejectCodes.overMax => UiLevel.act,
    final String other => throw ArgumentError.value(
      other,
      'reasonCode',
      '모르는 월 납입 거부 코드',
    ),
  };
  return ActionResult(
    actionRunId: actionRunId,
    id: SettingsActionId.settingsContributionUpdate,
    level: level,
    headline: reasonCode == null
        ? MonthlyContributionTexts.accepted
        : rejectedText!,
    reasonCode: reasonCode,
    retryable: false,
  );
}
