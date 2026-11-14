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
// 🆕 계약 v1.20(01 §29) — `S02` `CredentialListVm`·`CredentialCardVm` 추가형(색 · 동작 · 슬롯 · 잠김 · asOf · 봉인 · 런북 ·
//    회전 링크 · 키 조각 0 · 1단).
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

/// m2-8 G-6 · 🆕 v1.20 추가형(01 §29 · K1 · K29 · K35) — 증권사 키 관리(05 `S02` · 폰 전용 · 운영 등급).
/// 🔴 값·키 조각(«앞4…뒤4» 포함)은 어떤 필드로도 오지 않는다(K7) — 마스킹 표시는 조립 앱 `SecretField` 안에서만(06 `M4-4`).
/// 🔴 [cards] 장 수·차례 = 엔진(종류·개수 상수 0 · 모드·운영 방식에 따라 엔진이 싣는다) · 1장 이상(엔진 의무 — 필수 세트는
///    미등록이어도 카드가 있다 · 빈 칸 0 — K29).
@freezed
abstract class CredentialListVm with _$CredentialListVm {
  const factory CredentialListVm({
    required List<CredentialCardVm> cards,

    /// 🆕 v1.20 — 모드 봉인 머리 한 줄(SIM 계열 «모의투자 중입니다 — 실전 키의 주문 경로는 봉인돼 있습니다 …» · 01 §9-3). null = 줄 없음.
    String? modeNotice,

    /// 🆕 v1.20 — 키 유출 대응 런북 링크(엔진 완성 · `AppRoutes.opsRunbook` 의 한 값 · 읽기 문서라 잠김에도 남는다). null = 링크 부재.
    LinkAction? leakRunbookLink,

    /// 🆕 v1.20 — 운영 등급 생체 축소 글자(non-null = 보기만). 🔴 엔진 의무 = 이때 모든 카드 [CredentialCardVm.credentialSlotId]·
    /// [CredentialCardVm.verifyAction]·[CredentialCardVm.rotateLink] null — 화면은 이 칸으로 컨트롤을 거르지 않는다(K23 · K35).
    String? lockedLabel,

    /// 🆕 v1.20 — 조회 화면 하단 고지(05 §0-4 · 오래됨 = `staleLabel`).
    required AsOf asOf,
  }) = _CredentialListVm;

  factory CredentialListVm.fromJson(Map<String, dynamic> json) =>
      _$CredentialListVmFromJson(json);
}
// JSON 키: cards · mode_notice · leak_runbook_link · locked_label · as_of

/// m2-8 G-6 · 🆕 v1.20 추가형(01 §29 · K6 · K7 · K10~K12 · K30) — 키 카드 1장. `kind` 에는 X7 의 `KIS_RECONCILE` 이 포함된다.
/// 🔴 `CredentialUse` 는 브로커 속성이 아니라 **앱 측 런타임 봉인 선언**이다.
/// 🔴 화면이 읽는 칸 = [kindLabel]·[healthLabel]·[usageLabel]·[expiresText]·[level]·[lastVerifiedText]·[requirementLabel]·[whyLine]·
///    [sealLabel]·[credentialSlotId](빌더에 그대로)·[verifyAction]·[rotateLink] — [alias]·[kind]·[healthCode]·[usage] 는 화면 미참조.
/// 🔴 키 조각 칸 0(K7) · 저장 동작 칸 0(K6 — 검증 통과 = 구현이 저장하는 1단).
@freezed
abstract class CredentialCardVm with _$CredentialCardVm {
  const factory CredentialCardVm({
    /// 엔진 식별자(`credential_registry.alias` · `kis_live` 꼴) — 🔴 화면 미참조(Key = 순번 · K30).
    required String alias,

    /// `CredentialKindCodes` 값(K8) — 🔴 화면 미참조(분기·아이콘 0).
    required String kind,

    /// 카드 제목 — 엔진(«실전 · 위탁 01 + 연금저축 22»).
    required String kindLabel,

    /// 🔴 화면 미참조 · 사전 밖 축(DDL `credential_registry.health` 5 ∪ `NOT_REGISTERED` — C-5 `_fieldsOutsideDictionary`) · 색 = [level].
    required String healthCode,
    required String healthLabel,

    /// 🔴 화면 미참조(봉인 표시 = [sealLabel] 글자).
    required CredentialUse usage,
    required String usageLabel,

    /// 만료 고지 — 엔진 생성. 🔴 화면이 남은 일수를 세지 않는다.
    String? expiresText,

    /// 🆕 v1.20 — 색·상태 아이콘의 유일한 근거(K11 · advisory 미등록 ≠ 경고 — 엔진이 info 로 싣는다).
    required UiLevel level,

    /// 🆕 v1.20 — 마지막 검증 한 줄(성공·실패 · 원문 코드 포함 가능) — 엔진. null = 줄 없음(미등록).
    String? lastVerifiedText,

    /// 🆕 v1.20 — «필수»·«권장»·«선택» — 엔진 글자(🔴 `StepRequirement` 분기 0).
    String? requirementLabel,

    /// 🆕 v1.20 — 미등록의 결과 한 줄(X7 «원장 신뢰 등급이 자기 보고로 고정됩니다») — 경고 아님. null = 줄 없음.
    String? whyLine,

    /// 🆕 v1.20 — 봉인 배지(«대사 전용 — 주문 경로 봉인됨» · SIM «모의투자 중 — 주문 경로 봉인됨»). 🔴 해제 컨트롤 0.
    String? sealLabel,

    /// 🆕 v1.20 — 시크릿 입력 자리 이름(`SettingsSlotIds` · 모의 = `OnboardingSlotIds.secretKisMock` 재사용 — K8 · K9 · K31).
    /// null = 자리 부재(잠김 포함). 🔴 화면은 이름을 슬롯 빌더에 그대로 넘긴다(분기·상수 0).
    String? credentialSlotId,

    /// 🆕 v1.20 — 엔진이 완성한 `credentialVerify{kind}` 호출(«검증 후 저장» · «다시 검증»). null = 버튼 부재.
    /// 🔴 통과 = 구현이 저장한다(1단 · K6) — 저장 버튼·`credentialRegister` 호출 0.
    SettingsActionCall? verifyAction,

    /// 🆕 v1.20 — 키 회전 마법사 진입(`AppRoutes.m4KeyRotation` · 🔒 06 `M4-4` · K12). null = 링크 부재.
    LinkAction? rotateLink,
  }) = _CredentialCardVm;

  factory CredentialCardVm.fromJson(Map<String, dynamic> json) =>
      _$CredentialCardVmFromJson(json);
}
// JSON 키: alias · kind · kind_label · health_code · health_label · usage · usage_label · expires_text · level ·
//          last_verified_text · requirement_label · why_line · seal_label · credential_slot_id · verify_action · rotate_link
