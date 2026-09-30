// 01 §4-1(G-07) · §2-6 — M9 설정 뷰모델과 월 납입 운영값.
//
// 🔴 **월 추가 납입 운영값을 화면(`ui_*/lib` · `labels.dart` 포함)·계약 코드에 상수로 적지
//    않는다**(C-32 · 🆕 v1.4 문구 통일 01 §14-13). 픽스처는 **폐기값만** 금지이고 금액 예시값은
//    하나를 쓴다(`fixture_conventions_test.dart` 머리 주석).
//    읽기 창구는 `ConfigRepository.watchContributionSetting()` **하나**이고 변경
//    창구는 `SettingsActions`(운영 등급 · `settingsContributionUpdate` ⏸)다.
// 🔴 화면이 `금액 × 12` 를 계산하지 않는다 — 한도 판정은 엔진 단일 소스다.
// 🔴 **최소·최대·0 허용 여부를 필드로 내려보내지 않는다** — 범위 판정은 저장
//    명령의 `ActionResult.headline`·`reasonCode` 로만 돌아온다(그래야 「저장 버튼
//    비활성」이라는 **화면의 판정**이 생기지 않는다).
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/converters.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

/// 01 §4-1 G-07 — 월 납입 운영 파라미터의 읽기 창구가 내려주는 값.
/// 🔴 `amount`·`amountText` 는 «지금 유효한 값»이다(N-S4-01) — 접수됐으나 아직
///    시작되지 않은 변경은 `appliesFromText` 가 **문장으로만** 알린다. 예정 금액을
///    `amount` 에 넣지 않는다.
/// 🔴 🆕 v1.4 — `amount` 는 엔진·명령 쪽 원값이다. 플래너 입력칸의 초기 글자는
///    [amountInputText] 이다(01 §14 · D4).
/// 🔴 설정 문장(`amountText`·`equivalentNoteText`·`appliesFromText`·`pensionLimitNoteText`)은
///    **설정값 기준 설명**이지 플래너에 입력한 금액 기준 판정이 아니다.
@freezed
abstract class ContributionSetting with _$ContributionSetting {
  const factory ContributionSetting({
    /// 🔴 ui 미참조(C-38 ⑩) — 엔진·명령 쪽 원값. 입력칸 초기 글자는 [amountInputText].
    @DecimalStringConverter() required Decimal amount,

    /// 표시 문자열 — 엔진 생성.
    required String amountText,

    /// 🆕 v1.4 — 플래너 스텝 ① 입력칸의 **초기 글자 전용**(엔진이 만든 숫자 글자).
    /// 🔴 입력칸은 스트림의 **첫 값만** 채운다 — 이후 값은 편집 중인 입력을 덮지 않는다.
    /// 🔴 화면이 `amount.toString()` 으로 대신 만들지 않는다(표시 자릿수는 컨버터의 일이 아니다 ·
    ///    `money.dart`).
    required String amountInputText,

    /// 12%-등가 참고 + 「충족/부족」 한 줄 — 엔진 생성.
    required String equivalentNoteText,

    /// 「다음 납입 주기」 문구 — 엔진 생성(§2-6 `contribution_day` 규칙).
    required String appliesFromText,

    /// 「최근 변경: …」 한 줄 — 엔진 생성(G-101).
    required String lastChangedText,
    required AsOf asOf,

    /// 연 한도·세액공제 구간과의 관계 한 줄 — 엔진 생성(G-102).
    /// 🔴 null 이면 화면이 이 줄을 **그리지 않는다**.
    String? pensionLimitNoteText,
  }) = _ContributionSetting;

  factory ContributionSetting.fromJson(Map<String, dynamic> json) =>
      _$ContributionSettingFromJson(json);
}

/// m2-8 G-11 — 05 `S05` 월 납입 운영값 카드.
/// 🔴 `ContributionSetting` 의 **1:1 투영**이며 `editable` 하나만 런타임 값이다
///    (`SettingsActions` 주입 여부 — 뷰어에서는 false 가 아니라 **카드 부재**).
/// 🔴 **필드를 이어 붙여 문장을 만들지 않는다.** 투영을 늘리는 것은 허용된다
///    (엔진 문자열 필드가 늘면 여기도 **같은 이름으로** 는다 · N-S4-03).
/// 🔴 03 §8 `S7-3b` 의 `ContributionVm`(슬리브 기여 분해)과 **다른 타입**이며
///    이름을 재사용하지 않는다(N-01).
@freezed
abstract class MonthlyContributionVm with _$MonthlyContributionVm {
  const factory MonthlyContributionVm({
    required String amountText,

    /// 🆕 v1.4 — `ContributionSetting.amountInputText` 의 투영(N-S4-03 · 같은 이름).
    required String amountInputText,
    required String equivalentNoteText,
    required String appliesFromText,
    required String lastChangedText,
    required bool editable,
    String? pensionLimitNoteText,
  }) = _MonthlyContributionVm;

  factory MonthlyContributionVm.fromJson(Map<String, dynamic> json) =>
      _$MonthlyContributionVmFromJson(json);
}

/// m2-8 G-5 — 설정 홈(05 `S01`).
@freezed
abstract class SettingsHomeVm with _$SettingsHomeVm {
  const factory SettingsHomeVm({required List<SettingsCard> cards}) =
      _SettingsHomeVm;

  factory SettingsHomeVm.fromJson(Map<String, dynamic> json) =>
      _$SettingsHomeVmFromJson(json);
}

/// m2-8 G-5 — 설정 카드 1장.
/// 🔴 `actionAvailable == false` 는 «비활성»이 아니라 **카드 부재**로 그린다.
@freezed
abstract class SettingsCard with _$SettingsCard {
  const factory SettingsCard({
    required String code,
    required String title,

    /// 🔴 색의 근거. 값의 부호로 고르지 않는다.
    required UiLevel level,
    required bool actionAvailable,
    String? statusLabel,
    String? route,
  }) = _SettingsCard;

  factory SettingsCard.fromJson(Map<String, dynamic> json) =>
      _$SettingsCardFromJson(json);
}

/// m2-8 G-6 — 증권사 키 관리(05 `S02`).
/// 🔴 값은 어떤 필드로도 오지 않는다 — `credential_registry` 는 별칭·상태만 싣는다.
@freezed
abstract class CredentialListVm with _$CredentialListVm {
  const factory CredentialListVm({required List<CredentialCardVm> cards}) =
      _CredentialListVm;

  factory CredentialListVm.fromJson(Map<String, dynamic> json) =>
      _$CredentialListVmFromJson(json);
}

/// m2-8 G-6 — 키 카드 1장. `kind` 에는 X7 의 `KIS_RECONCILE` 이 포함된다.
/// 🔴 `CredentialUse` 는 브로커 속성이 아니라 **앱 측 런타임 봉인 선언**이다.
@freezed
abstract class CredentialCardVm with _$CredentialCardVm {
  const factory CredentialCardVm({
    required String alias,
    required String kind,
    required String kindLabel,
    required String healthCode,
    required String healthLabel,
    required CredentialUse usage,
    required String usageLabel,

    /// 만료 고지 — 엔진 생성. 🔴 화면이 남은 일수를 세지 않는다.
    String? expiresText,
  }) = _CredentialCardVm;

  factory CredentialCardVm.fromJson(Map<String, dynamic> json) =>
      _$CredentialCardVmFromJson(json);
}
