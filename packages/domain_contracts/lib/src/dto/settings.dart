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
// 🆕 계약 v1.18(01 §27 · R6 선행 · 발주자 결정 2026-11-13 Q1~Q4 · K-o~K-q):
//    ① `S01` = 엔진이 묶은 그룹 VM — 그룹 차례(일반 → 운영 → 규칙)·카드 차례·요약 글자·주의 배지 글자 = **엔진** ·
//       화면은 받은 차례 그대로(정렬·세기·묶기 0) · 폰 전용 행은 뷰어 VM 에 엔진이 싣지 않는다(`isViewer` 칸 0).
//    ② 12월 연간 리뷰 카드 = [SettingsHomeVm.annualReviewLink](OPEN 판정 = 엔진 · 화면이 달을 보지 않는다).
//    ③ `actionAvailable` 삭제 — «부재 = 목록에 없음» 한 원칙(K-q).
//    ④ «엔진이 완성한 호출 1개» = [SettingsActionCall](`OnboardingAction` 별칭 · 화면은 id·args 를 그대로 넘긴다).
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/settings.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/converters.dart';
import 'common.dart'; // LinkAction
import 'onboarding.dart'; // OnboardingAction

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

/// 🆕 v1.18(01 §27 · K-d) — 엔진이 완성한 `SettingsActions.run` 호출 1개(M9 공용 이름).
/// 🔴 화면은 [OnboardingAction.id]·[OnboardingAction.args] 를 **그대로** 넘긴다(키·값을 짓지 않는다 · 화이트리스트 =
///    `settings_actions.dart` 머리) · 버튼 글자 = [OnboardingAction.label](엔진). JSON 키 = id · args · label.
typedef SettingsActionCall = OnboardingAction;

/// m2-8 G-5 · 🆕 v1.18 **교체**(01 §27 · K-o) — 설정 홈(05 `S01`).
/// 🔴 [groups] 차례 = 엔진(일반 → 운영 → 규칙 · 빈 그룹은 엔진이 뺀다) · [asOf] = 조회 화면(하단 고지 · 오래됨 = 카드 몫).
@freezed
abstract class SettingsHomeVm with _$SettingsHomeVm {
  const factory SettingsHomeVm({
    /// 엔진 상태 칩(늘 그린다 — «정상 = 무소식» 의 예외 05:43).
    required EngineStatusChip statusChip,

    /// 12월 연간 리뷰 카드 — 창이 OPEN 일 때만 non-null(엔진 판정 · 목적지 = `AppRoutes.settingsAnnualReview`).
    LinkAction? annualReviewLink,
    required List<SettingsGroup> groups,
    required AsOf asOf,
  }) = _SettingsHomeVm;

  factory SettingsHomeVm.fromJson(Map<String, dynamic> json) =>
      _$SettingsHomeVmFromJson(json);
}
// JSON 키: status_chip · annual_review_link · groups · as_of

/// 🆕 v1.18(01 §27 · K-o) — 설정 홈 묶음 1개(05 그림 4).
@freezed
abstract class SettingsGroup with _$SettingsGroup {
  const factory SettingsGroup({
    /// 자물쇠 아이콘·묶음 머리에만(🔴 화면이 등급을 정하지 않는다).
    required SettingTier tier,

    /// 머리 글자 «운영 · 들어갈 때 생체 인증» — 엔진(등급 라벨 포함).
    required String label,

    /// 받은 차례 그대로 · 1장 이상(빈 묶음 = 엔진이 뺀다).
    required List<SettingsCard> cards,
  }) = _SettingsGroup;

  factory SettingsGroup.fromJson(Map<String, dynamic> json) =>
      _$SettingsGroupFromJson(json);
}
// JSON 키: tier · label · cards

/// 🆕 v1.18(01 §27 · K-o) — 엔진 상태 칩. 🔴 손익 성격 글자 0 · «DRY_RUN» 글자 0(G-63) · [level] = 색·아이콘만.
@freezed
abstract class EngineStatusChip with _$EngineStatusChip {
  const factory EngineStatusChip({
    /// «실전 · 관찰 중 · 골든벡터 통과» — 엔진.
    required String label,
    required UiLevel level,

    /// `live × dryRun` 관찰 중일 때만 «승격 가능/불가 + 사유» 한 줄(06 `M1-22`). null = 줄 없음.
    String? promotionLabel,
  }) = _EngineStatusChip;

  factory EngineStatusChip.fromJson(Map<String, dynamic> json) =>
      _$EngineStatusChipFromJson(json);
}
// JSON 키: label · level · promotion_label

/// m2-8 G-5 — 설정 카드 1장. 🆕 v1.18(K-p · K-q) — `actionAvailable` 삭제 · [attentionText] 추가.
/// 🔴 [code] = 엔진 불투명 id(화면 미참조 · Key = 순번) · 행 아이콘 = [level] 상태 아이콘뿐(카테고리 아이콘 사전 0).
/// 🔴 갈 수 없는 카드는 «비활성»이 아니라 **목록에 없다**(엔진이 싣지 않는다).
@freezed
abstract class SettingsCard with _$SettingsCard {
  const factory SettingsCard({
    required String code,
    required String title,

    /// 🔴 색·상태 아이콘의 근거. 값의 부호로 고르지 않는다.
    required UiLevel level,

    /// 현재 상태 한 줄 — 엔진(화면이 조립하지 않는다).
    String? statusLabel,

    /// 🆕 v1.18 — 주의 배지 글자(«1»). null = 배지 부재 · 🔴 int 아님(화면이 하위 항목을 세지 않는다 · `OpsDailySummary` 선례).
    String? attentionText,

    /// 하위 화면 링크(`AppRoutes` M9 묶음). null = 탭 부재.
    String? route,
  }) = _SettingsCard;

  factory SettingsCard.fromJson(Map<String, dynamic> json) =>
      _$SettingsCardFromJson(json);
}
// JSON 키: code · title · level · status_label · attention_text · route

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
