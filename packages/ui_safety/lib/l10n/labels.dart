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
// 화면을 만들면서 실제로 필요한 상수만 추가한다.

/// ui_safety의 정적 UI 라벨 모음. 인스턴스를 만들지 않는다.
abstract final class SafetyLabels {
  // ── M5-14 가상 초기금(O-04 ⑥ 자동 매매 갈래 · 06 M5-14 · 설계 13 §8 R156) ──
  // 🔴 결과 문장(넣었다 · 거부 사유)은 접수증 `stateLabel` 그대로다(엔진) — 여기 두지 않는다.

  /// 제목.
  static const String simOpeningCashTitle = '가상 초기금';

  /// 칸 위 한 줄(무엇을 적는 칸인가 — 절차 문장 아님).
  static const String simOpeningCashNote =
      '모의투자를 시작할 가상의 금액입니다 — 실제 돈은 움직이지 않습니다.';

  /// 금액 칸 이름.
  static const String simOpeningCashField = '금액(원)';

  /// 제출 버튼.
  static const String simOpeningCashSubmit = '가상 초기금 넣기';

  /// 제출 자체가 실패했다(접수증 없음 — 거부와 다르다).
  static const String submitNotAccepted = '제출하지 못했습니다 — 잠시 뒤 다시 눌러 주세요.';

  // ── M5-8 본인 서약 3문장(O-04 ② 슬롯 `PLEDGE_WRITE` · 06 M5-8 · 설계 13 §8 R157) ──
  // 🔴 예시 문장 · 힌트를 두지 않는다(본인이 쓴 문장이라는 것이 이 장치의 전부 — 04 §9-5 ②).
  // 🔴 결과 문장(저장했다 · 거부 사유)은 `SafetyActionResult.headline` 그대로다(엔진).

  /// 첫째 칸 이름.
  static const String pledgeSentence1 = '첫째 문장';

  /// 둘째 칸 이름.
  static const String pledgeSentence2 = '둘째 문장';

  /// 셋째 칸 이름.
  static const String pledgeSentence3 = '셋째 문장';

  /// 저장 버튼.
  static const String pledgeSave = '서약 저장';

  /// 서약을 읽지 못했다(원천 오류 — 빈 서약과 다르다).
  static const String pledgeReadFailed = '서약을 읽지 못했습니다.';
}
