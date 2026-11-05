// 🆕 계약 v1.17(01 §26 · R16 선행 · 발주자 결정 2026-11-04 ①~④) — M8 `D-01` 장애 배너 · `D-02` DR 런북 · `D-03` 오프라인 긴급정지 카드.
//
// 🔴 배너 고르기·정렬·최대 1건·원인 해소 = 전부 엔진(04 §6) — 화면은 받은 0/1건을 그린다. 배너 ≠ 알림(배너 = 원인이 남아 있는
//    상태 · 알림 = 사건 · 등급(P0/P1/P2)은 알림에만 있다). 닫기·«다시 보지 않기» 칸이 없다 — 해소되면 데이터에서 사라진다.
// 🔴 문구·조치는 완성돼 온다 — [IncidentKind] 는 아이콘에만 · `UiLevel` 은 색에만(🔴 `ok` 는 배너에 오지 않는다).
// 🔴 asOf 칸이 없다(K20 — 지속 상태 1건 · 절차서 · 안내 · R15 온보딩 꼴 · 04 §2-3 «모든 조회 화면» 의 예외 · 01 §8 미결 148).
// 🔴 런북 원고 = 03_실행 §10-5 여섯 시나리오 · 긴급 카드 원고 = 04_안전장치 §5-5 + 03_실행 §10-5 ⑥ — M2 번들(엔진이 늘 싣는다 ·
//    뷰어도 같은 번들 — 폰이 죽어도 읽힌다 · K3).
// 🔴 런북 «확인» 체크는 화면 로컬 표시다 — 이 계약에 그 상태 칸·명령이 없다(저장 0 · 명령 0 · 그 사실 = [RunbookVm.localCheckNotice]).
//    «지금 실행» 류 단계별 실행 자리도 칸이 없다(01 §8 미결 161 · M5·M9 창) — 이 판 = 부재.
// 🔴 인쇄·PDF = 플랫폼 슬롯([EmergencyCardVm.printSlotId] = `OpsSlotIds` · 위젯 = 조립 앱 06 M4-12) — 04 §2-1 금지 5 의 유일한 예외.
// 🔴 링크 = 데이터(01 §4-4) — [IncidentBanner.actionLink] · [RunbookRow.deepLink] · 화면이 id 로 링크를 짓지 않는다.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/incident.dart';
import '../enums/ui.dart';
import 'common.dart';

part 'incident.freezed.dart';
part 'incident.g.dart';

/// `D-01` 배너 1건(04 §6 · K8).
@freezed
abstract class IncidentBanner with _$IncidentBanner {
  const factory IncidentBanner({
    /// 아이콘 선택에만. 모르는 wire = [IncidentKind.other].
    @JsonKey(unknownEnumValue: IncidentKind.other) required IncidentKind kind,

    /// 색 선택에만(`blocked`·`act`·`watch`·`info` — 🔴 `ok` 는 오지 않는다).
    required UiLevel level,

    /// «증권사 접근 토큰이 만료되었습니다» — 엔진(종류별로 다른 문구 · 04 §6).
    required String title,

    /// 본문 한 문단 — 엔진.
    required String bodyText,

    /// 조치 버튼 0/1(글자 + 목적지 = 엔진 · 예 «연결 설정 열기» → `aaq://settings/credentials`). null = 버튼 부재.
    /// 🔴 칸 이름 `action` 을 쓰지 않는다 — C-50 ⑨ 가 «모든 픽스처의 `action` 키 = `OnboardingAction`» 으로 걷는다(드라이런).
    LinkAction? actionLink,
  }) = _IncidentBanner;

  factory IncidentBanner.fromJson(Map<String, dynamic> json) =>
      _$IncidentBannerFromJson(json);
}
// JSON 키: kind · level · title · body_text · action_link

/// `D-01` VM(K9) — 🔴 **최대 1건**. 여러 건이면 엔진이 정렬해 첫 건을 준다. null = 배너 없음(스트림은 늘 값을 낸다).
@freezed
abstract class IncidentBannerVm with _$IncidentBannerVm {
  const factory IncidentBannerVm({IncidentBanner? banner}) = _IncidentBannerVm;

  factory IncidentBannerVm.fromJson(Map<String, dynamic> json) =>
      _$IncidentBannerVmFromJson(json);
}
// JSON 키: banner

/// `D-02` 목록 1행(K10).
@freezed
abstract class RunbookRow with _$RunbookRow {
  const factory RunbookRow({
    /// «운영 폰을 잃어버렸거나 고장 났을 때» — 엔진(원고).
    required String title,

    /// 한 줄 요약 — 엔진. null = 줄 없음.
    String? summaryText,

    /// 상세 링크(`aaq://ops/runbooks/<runbookId>` · ⑥ = `aaq://ops/emergency-card`) — 엔진 완성 · 🔴 화면은 열기만.
    required String deepLink,
  }) = _RunbookRow;

  factory RunbookRow.fromJson(Map<String, dynamic> json) =>
      _$RunbookRowFromJson(json);
}
// JSON 키: title · summary_text · deep_link

/// `D-02` 목록 VM(K10). 🔴 행 수·차례 = 받은 그대로(6 리터럴 0).
@freezed
abstract class RunbookIndexVm with _$RunbookIndexVm {
  const factory RunbookIndexVm({
    required List<RunbookRow> rows,

    /// 행 0 일 때만 non-null(엔진 문장).
    String? emptyLabel,
  }) = _RunbookIndexVm;

  factory RunbookIndexVm.fromJson(Map<String, dynamic> json) =>
      _$RunbookIndexVmFromJson(json);
}
// JSON 키: rows · empty_label

/// 런북·긴급 카드의 단계 1개(K10). 🔴 번호 = [orderText] 글자(화면이 `i + 1` 로 짓지 않는다 · «2-1.» 꼴도 온다).
@freezed
abstract class RunbookStep with _$RunbookStep {
  const factory RunbookStep({
    /// «1.» · «2-1.» — 엔진.
    required String orderText,

    /// 단계 글자 — 엔진(원고).
    required String text,
  }) = _RunbookStep;

  factory RunbookStep.fromJson(Map<String, dynamic> json) =>
      _$RunbookStepFromJson(json);
}
// JSON 키: order_text · text

/// `D-02` 상세 VM(K10). 🔴 [missingLabel] non-null ⇔ [steps] 0 ∧ [introText] null(모르는 id = 값 · 스트림 에러 아님).
@freezed
abstract class RunbookVm with _$RunbookVm {
  const factory RunbookVm({
    required String title,

    /// 머리 한 문단 — 엔진. null = 없음.
    String? introText,

    /// 번호 단계(받은 차례 그대로).
    required List<RunbookStep> steps,

    /// 하단 고지 «확인 표시는 이 화면에서만 보입니다. 저장되지 않고, 아무것도 실행하지 않습니다.» — 엔진(늘 싣는다).
    required String localCheckNotice,

    /// 모르는·지난 id = 엔진 문장.
    String? missingLabel,
  }) = _RunbookVm;

  factory RunbookVm.fromJson(Map<String, dynamic> json) =>
      _$RunbookVmFromJson(json);
}
// JSON 키: title · intro_text · steps · local_check_notice · missing_label

/// `D-03` 오프라인 긴급정지 카드 VM(K11) — 가족용 한 장(전문 용어 0 · 문안 = 원고).
/// 🔴 계좌번호·앱키·개인 연락처는 이 VM 어디에도 없다(C-14 · C-51 ⑤ · 엔진 원고 검증 게이트).
@freezed
abstract class EmergencyCardVm with _$EmergencyCardVm {
  const factory EmergencyCardVm({
    required String title,

    /// 정지 단계(받은 차례 · `RunbookStep` 재사용).
    required List<RunbookStep> steps,

    /// «한국투자증권 고객센터 1544-5000 · 연락처는 종이에 직접 적어 둡니다» — 엔진(공개 대표번호만).
    required String contactLine,

    /// «이 카드는 인쇄해 종이로 보관하세요. 계좌번호와 앱키는 이 카드에 없습니다.» — 엔진(늘 싣는다).
    required String keepOnPaperNotice,

    /// 인쇄·PDF 슬롯 이름(`OpsSlotIds.emergencyCardPrint`). null = 인쇄 자리 부재(인쇄할 수 없는 빌드).
    String? printSlotId,
  }) = _EmergencyCardVm;

  factory EmergencyCardVm.fromJson(Map<String, dynamic> json) =>
      _$EmergencyCardVmFromJson(json);
}
// JSON 키: title · steps · contact_line · keep_on_paper_notice · print_slot_id
