// 정적 UI 라벨 — 이 파일이 ui_shell에서 한글 문자열 리터럴이 허용되는
// **유일한 자리**다(01 §1-5 · C-5).
//
// 여기 두는 것: 데이터가 바뀌어도 글자가 그대로인 것.
//   예: 탭 이름 · '닫기' · '다시 시도' · '건너뛰기' · '알림'
//
// 🔴 여기 두면 안 되는 것: 상태를 설명하는 문장. 알림 제목·본문·«지금 할 일»
//    한 줄·차단 사유·단계 설명은 전부 엔진이 DTO 필드로 준다 — AlertItem.title ·
//    bodyText · actionLine · BlockFlag.clearInstruction · OnboardingStep.whyLine ·
//    estimatedText · verificationLabel.
//
// 🔴 «약 20분» 같은 소요 시간도 화면이 Duration을 포맷해 만들지 않는다.
//    estimatedText가 그 자리다(01 §1-3 · §2-10).
//
// 아직 비어 있다. 화면을 만들면서 실제로 필요한 상수만 추가한다.

/// ui_shell의 정적 UI 라벨 모음. 인스턴스를 만들지 않는다.
abstract final class ShellLabels {
  // 예: static const String close = '닫기';

  // ── 🆕 R13a — S-01·S-02 셸 · H-02 운영 리듬 ──────────────────────────────

  // 탭 이름
  static const String tabHome = '홈';
  static const String tabJournal = '일지';
  static const String tabHoldings = '보유';
  static const String tabPlan = '계획';
  static const String tabMore = '더보기';

  // 접두·띠
  static const String simPrefix = '모의투자';
  static const String advisoryPrefix = '투자 안내';
  static const String prefixSeparator = ' · ';

  // 일지 탭 세그먼트
  static const String segmentAdvice = '안내';
  static const String segmentRecord = '기록';

  // 웹 사이드바
  static const String viewOnly = '조회 전용';
  static const String sideHome = '운영 홈';
  static const String sideJournal = '매매일지';
  static const String sideHoldings = '보유현황';
  static const String sideReports = '리포트·분석';
  static const String sideHandbook = '핸드북';

  // 가드 안내
  static const String phoneOnly = '폰에서만 쓸 수 있습니다';
  static const String journalDraftPhoneOnly = '사전 저널은 Android 운영 기기에서만 작성합니다';
  static const String webAbsent = '웹에서는 아직 열 수 없습니다';
  static const String advisoryOnly = '투자 안내 모드에서만 열 수 있습니다';
  static const String unknownLink = '등록되지 않은 링크입니다';

  // 공통
  static const String staleBannerTitle = '오래된 데이터';
  static const String retry = '다시 시도';

  // H-02 운영 리듬 열 머리
  static const String rhythmColumnItem = '항목';
  static const String rhythmColumnNext = '다음 발생';

  // ── 🆕 R13b — H-01 운영 홈 ──────────────────────────────────────────────────
  static const String homeReconTitle = '기록 대조';
  static const String homeUpcomingTitle = '다음 예정';
  static const String homeMore = '더 보기';
  static const String homeSelfAuditAction = '실사하기';
  static const String homeDeployed = '투자분';
  static const String homeParking = '파킹';

  // ── 🆕 R14a — N-01·N-02 알림 ──────────────────────────────────────────────
  static const String alertsP0Only = 'P0만 보기';
  static const String alertsAck = '확인했습니다';
  static const String alertsEvidence = '근거 보기';
  static const String alertsAckNotAccepted = '접수되지 않았습니다';

  // ── 🆕 R15a — O-00·O-00b 온보딩 ──────────────────────────────────────────
  static const String onboardingNext = '다음';
  static const String onboardingNotAccepted = '접수되지 않았습니다';
}
