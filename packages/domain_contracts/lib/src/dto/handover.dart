// 01 §2-11 — X7 운영 방식 표시와 전환 위저드(`M5-10` 게이트 · `M5-11` 위저드).
//
// 🔴 `OperatingMode` 전환은 `CommandApi` 에 없다 — `SettingsActions` 의
//    `runtimeOperatingModeSwitchRequest` 1종이며 반환 `handoffRoute` 로 위저드에
//    넘긴다(01 §4-3).
// 🔴 엔진의 어떤 안전 강등도 `OperatingMode` 를 건드리지 않는다(§10-1 · C-20).
// 🔒 전환 위저드는 M5 소유 화면이다 — 다른 화면은 읽을 수는 있으나 렌더하지 않는다.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/mode.dart';
import '../enums/sleeve.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart';
import 'ledger_trust.dart';

part 'handover.freezed.dart';
part 'handover.g.dart';

/// 01 §2-11 — M9 `S05` 표시 + M8 `O-00b` 선택 카드가 **같은 타입**을 쓴다.
@freezed
abstract class OperatingModeView with _$OperatingModeView {
  const factory OperatingModeView({
    required OperatingMode current,

    /// "투자 안내(수동 매매)" — 엔진 생성.
    required String label,
    required String explainLine,

    /// `O-00b` 카드 2장 — 🔴 **기본 선택 없음**(«온보딩 미완»은 «자동 매매»가
    /// 아니다 · G-02).
    required List<OperatingModeOption> options,
    required LedgerTrustBadge trust,

    /// 전환 사전 점검 결과.
    required List<GateBadge> switchGates,
  }) = _OperatingModeView;

  factory OperatingModeView.fromJson(Map<String, dynamic> json) =>
      _$OperatingModeViewFromJson(json);
}

/// 01 §2-11 — 선택 카드 1장. 🔴 전부 엔진 문구다.
@freezed
abstract class OperatingModeOption with _$OperatingModeOption {
  const factory OperatingModeOption({
    required OperatingMode mode,
    required String title,
    required String body,
    required String prepLine,
    required String honestyLine,
  }) = _OperatingModeOption;

  factory OperatingModeOption.fromJson(Map<String, dynamic> json) =>
      _$OperatingModeOptionFromJson(json);
}

/// 01 §2-11 — 전환 계획(`M5-11`).
/// 🔴 B13 — `asOf` 는 스냅샷 신선도다. 낡으면 커밋 직전에 되돌린다.
@freezed
abstract class HandoverPlan with _$HandoverPlan {
  const factory HandoverPlan({
    required HandoverPath path,
    required String pathLabel,
    required List<HandoverStep> steps,
    required List<AdoptionPreviewRow> adoptionPreview,
    required AsOf asOf,

    /// 🔴 B12 — **엔진이 갈래를 판정한다**(사고 대응 / 자발적 전환).
    ///    화면은 준 갈래만 표시하고 자체 판정하지 않는다.
    String? handbackBranch,
    String? branchReasonLabel,
  }) = _HandoverPlan;

  factory HandoverPlan.fromJson(Map<String, dynamic> json) =>
      _$HandoverPlanFromJson(json);
}

/// 01 §2-11 — 전환 단계 1행(`OnboardingStep`·`UnknownResolutionStep` 과 같은 모양).
@freezed
abstract class HandoverStep with _$HandoverStep {
  const factory HandoverStep({
    required String stepId,
    required int order,
    required String title,
    required String whyLine,
    required GateState state,
    required String stateLabel,
    String? blockedReasonCode,
  }) = _HandoverStep;

  factory HandoverStep.fromJson(Map<String, dynamic> json) =>
      _$HandoverStepFromJson(json);
}

/// 01 §2-11 — 편입 미리보기 1행.
/// 🔴 G-03 — `disposition` 은 엔진이 준 **현재** 처분(`'ADOPT'`|`'EXTERNAL'`)이며,
///    바꿀 때는 `handoverAdoptionSet` 를 호출한 뒤 **되돌아온 값**을 다시 그린다
///    (낙관 갱신 금지 — 커밋 전 상태를 화면이 소유하지 않는다).
@freezed
abstract class AdoptionPreviewRow with _$AdoptionPreviewRow {
  const factory AdoptionPreviewRow({
    required String symbol,
    required String symbolLabel,
    required int quantity,
    required SleeveId sleeve,

    /// 🔴 처분 제출의 대상 식별자. 티커 문자열로 지목하면 같은 종목이 두 계좌에
    ///    있을 때 조용히 한쪽만 반영된다.
    required String adoptionId,
    required String disposition,

    /// "편입" / "제외(시스템 밖 자산)" — 엔진 생성.
    required String dispositionLabel,
  }) = _AdoptionPreviewRow;

  factory AdoptionPreviewRow.fromJson(Map<String, dynamic> json) =>
      _$AdoptionPreviewRowFromJson(json);
}
