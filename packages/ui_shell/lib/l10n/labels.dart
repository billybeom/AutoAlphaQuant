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
}
