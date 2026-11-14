// 01 §29 · 🆕 계약 v1.20(R7 선행 · K19~K21 · 발주자 위임 2026-11-14 — 권고대로) — M9 `S03` 계좌 연동·슬리브↔계좌 매핑.
//
// 🔴 계좌 전체번호·계좌 종류 코드·별칭 키는 어떤 칸에도 오지 않는다 — 번호 = 엔진 마스킹 글자(`maskAccount` «****1234» · SAF-906) ·
//    종류 = 글자(`kindLabel`) · 별칭 = 엔진이 완성한 호출의 args 안에만(`accountMapSleeve{sleeve, account_alias}`).
// 🔴 칸 수 = 받은 [AccountMappingVm.mappings] 길이(P0S = A·B·C 3행 · POT 행 0 — A 행의 [SleeveMappingRow.subbookLine]) ·
//    선택지 = 엔진이 미리 판정해 싣는다(SAF-309 막힘 = [AccountMappingOption.blockedText] · 영향 = [AccountMappingOption.impacts]) ·
//    확인 = 화면 안 펼침(시트·다이얼로그 0 · K18) · «확인» = [AccountMappingOption.selectAction] run 1회(엔진이 안에서 드라이런 · SAF-309 재확인 뒤
//    원자 저장 — pending 0 · K19).
// 🔴 화면이 계좌 종류로 절세 여부를 판정하지 않는다 · 세후 갈래를 계산·전달하지 않는다 · 금액 0.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'onboarding.dart'; // SettingsActionCall 의 원형(freezed copyWith 가 `$OnboardingActionCopyWith` 를 본다 — ops.dart 선례)
import 'settings.dart'; // SettingsActionCall

part 'accounts.freezed.dart';
part 'accounts.g.dart';

/// 🆕 v1.20 — `S03` VM(창구 = `SettingsRepository.watchAccountMapping()` · 폰 전용).
@freezed
abstract class AccountMappingVm with _$AccountMappingVm {
  const factory AccountMappingVm({
    /// 계좌 목록 — 받은 차례 · 1행 이상(엔진 의무 · K29). DC·IRP = «시스템 밖 자산(수동)» 배지 행(매핑 선택지에는 엔진이 넣지 않는다).
    required List<AccountRow> accounts,

    /// 슬리브 칸 — 받은 길이·차례(🔴 칸 수 상수 0 · POT 행 0 · K20).
    required List<SleeveMappingRow> mappings,

    /// 전체 검증(`accountVerifyMapping{}` · 잔고 드라이런). null = 버튼 부재.
    SettingsActionCall? verifyAction,

    /// 운영 등급 생체 축소(non-null = 보기만). 🔴 엔진 의무 = [verifyAction] null · 모든 선택지 `selectAction` null · `impacts` 빈(K35).
    String? lockedLabel,
    required AsOf asOf,
  }) = _AccountMappingVm;

  factory AccountMappingVm.fromJson(Map<String, dynamic> json) =>
      _$AccountMappingVmFromJson(json);
}
// JSON 키: accounts · mappings · verify_action · locked_label · as_of

/// 🆕 v1.20 — 계좌 1행.
@freezed
abstract class AccountRow with _$AccountRow {
  const factory AccountRow({
    /// «연금저축» — 엔진(사람 별칭 글자).
    required String label,

    /// «연금저축 22» · «ISA 중개형» · «퇴직연금 DC» — 엔진 글자(🔴 종류 코드 칸 0 — 화면이 종류로 판정하지 못하게).
    required String kindLabel,

    /// 엔진 마스킹 글자(«****4821») — 🔴 화면이 자르거나 다시 가리지 않는다.
    required String maskedNumberText,

    /// 잔고 드라이런 배지 한 줄. null = 줄 없음.
    String? checkText,

    /// «시스템 밖 자산(수동)» 류 배지. null = 배지 부재.
    String? badgeText,
    required UiLevel level,
  }) = _AccountRow;

  factory AccountRow.fromJson(Map<String, dynamic> json) =>
      _$AccountRowFromJson(json);
}
// JSON 키: label · kind_label · masked_number_text · check_text · badge_text · level

/// 🆕 v1.20 — 슬리브 칸 1행.
@freezed
abstract class SleeveMappingRow with _$SleeveMappingRow {
  const factory SleeveMappingRow({
    /// «슬리브 A» — 엔진.
    required String sleeveLabel,

    /// 지금 연결된 계좌 글자. null = 미지정(그 사실의 글자 = [statusLine]).
    String? accountLabel,

    /// A 행의 POT 서브북 한 줄(«POT 서브북도 이 계좌에서 운용합니다») — 🔴 4번째 칸 아님. null = 줄 없음.
    String? subbookLine,

    /// 상태 한 줄(미지정 · 잔고 확인 실패 등) — 엔진. null = 줄 없음(정상).
    String? statusLine,
    required UiLevel level,

    /// 선택지 — 받은 차례(지금 계좌 = `selected` · 막힌 선택지 = `blockedText`).
    required List<AccountMappingOption> options,
  }) = _SleeveMappingRow;

  factory SleeveMappingRow.fromJson(Map<String, dynamic> json) =>
      _$SleeveMappingRowFromJson(json);
}
// JSON 키: sleeve_label · account_label · subbook_line · status_line · level · options

/// 🆕 v1.20 — 계좌 선택지 1개(`NotifyChannelOption` 꼴 · 🔴 기본 선택을 화면이 정하지 않는다).
/// 🔵 이름 = `AccountMappingOption`(설계서 이름표 #13 의 «AccountOption» 은 v1.12 `dto/advice.dart` `AccountOption{alias, label}`
///    (`ManualFillFormSpec.accounts`)과 겹쳐 배럴 export 가 모호해진다 — 구현 실측 · K39 · 발주자 위임 2026-11-14 — 권고대로).
@freezed
abstract class AccountMappingOption with _$AccountMappingOption {
  const factory AccountMappingOption({
    /// «ISA · ****7730» — 엔진.
    required String label,

    /// 지금 연결된 계좌(행마다 많아야 1 · 엔진 의무).
    required bool selected,

    /// 펼침 확인에 보일 «이 변경이 영향을 주는 것» 줄 — 엔진. 🔴 [selectAction] non-null ⇔ 비지 않음.
    @Default(<String>[]) List<String> impacts,

    /// SAF-309 등 미리 판정한 막힘 사유 — 엔진 글자. 🔴 non-null ⇒ [selectAction] null.
    String? blockedText,

    /// 엔진이 완성한 `accountMapSleeve{sleeve, account_alias}`. null = 고를 수 없음(지금 계좌 · 막힘 · 잠김).
    SettingsActionCall? selectAction,
  }) = _AccountOption;

  factory AccountMappingOption.fromJson(Map<String, dynamic> json) =>
      _$AccountOptionFromJson(json);
}
// JSON 키: label · selected · impacts · blocked_text · select_action
