// 정적 UI 라벨 — 이 파일이 ui_safety에서 한글 문자열 리터럴이 허용되는
// **유일한 자리**다(01 §1-5 · C-5).
//
// 여기 두는 것: 데이터가 바뀌어도 글자가 그대로인 것.
//   예: '닫기' · '다음' · '이전'
//
// 🔴 안전 화면은 특히 엄격하다. 차단 사유·해제 절차 안내·게이지 설명·재개
//    판정 문구는 **전부 엔진 문자열**이다 — BlockFlag.clearInstruction ·
//    SafetyState.breakerLabel · ResumeReport.headline · modeLabel ·
//    LedgerDiffRow.deltaLabel.
//    플래그마다 해제 경로가 다르므로 문구도 달라야 한다(경보 피로 방지 규칙).
//    여기에 절차 문장을 적는 순간 그 문장이 규칙보다 뒤처진다.
//
// 아직 비어 있다. 화면을 만들면서 실제로 필요한 상수만 추가한다.

/// ui_safety의 정적 UI 라벨 모음. 인스턴스를 만들지 않는다.
abstract final class SafetyLabels {
  // 예: static const String close = '닫기';
}
