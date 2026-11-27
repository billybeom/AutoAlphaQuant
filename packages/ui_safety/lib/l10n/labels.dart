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

  // ── M5-1 킬스위치(06 M5-1 · 01 §34 K146~K151 · 설계 13 §8 R178) ──
  // 🔴 상태 · 버튼 · 경로 · 취소 보고 · 폼 문항 · 고지 글자 = 엔진(VM) · 결과 = 접수증 `stateLabel` 원문 — 여기는 칸 머리 · 제출 버튼만.

  /// 킬스위치를 읽지 못했다(원천 오류 — 꺼짐과 다르다).
  static const String killSwitchReadFailed = '킬스위치 상태를 읽지 못했습니다.';

  /// 2번 감정 칸.
  static const String killEmotion = '감정';

  /// 2번 강도 칸.
  static const String killIntensity = '강도';

  /// 2번 수면 칸.
  static const String killSleepHours = '수면 시간';

  /// 3번 «해당 없음».
  static const String killScenarioNone = '해당 없음';

  /// 기록 제출 버튼.
  static const String killRecordSubmit = '기록 마치기';

  // ── M5-2 재개 게이트(06 M5-2 · 01 §30 K37 · 설계 13 §8 R180) ──
  // 🔴 문항 · 재생 · 답 · 게이지 · 막힘 · 결과 글자 = 엔진 — 여기는 칸 머리 · 확인 버튼 · 서약 머리 · 읽기 실패만.

  /// 게이트를 읽지 못했다.
  static const String resumeGateReadFailed = '재개 게이트를 읽지 못했습니다.';

  /// 1번 칸.
  static const String resumeNowRule = '지금 규칙';

  /// 7번 사전 필드 3.
  static const String resumeRationale = '사전 근거';
  static const String resumeExpected = '예상 결과';
  static const String resumeRuleCited = '인용한 규칙';

  /// 한 문항 확인(제출).
  static const String resumeConfirm = '확인';

  /// 서약 재생 머리.
  static const String resumePledgeTitle = '내가 쓴 서약';

  // ── 🆕 M5-5 차단 보드(설계 13 §8 R185) — 칸 이름 · 실패 문장만(머리 · 행 · 게이지 · 사다리 글자 = 엔진) ──

  /// 보드를 읽지 못했다(원천 오류 — «막힌 것 없음»과 다르다).
  static const String blockBoardReadFailed = '차단 보드를 읽지 못했습니다.';

  /// 읽기 실패에도 남는 킬스위치 진입(끄는 길은 언제나 — 목적지 = 계약 `killSwitchLink` 와 같은 화면).
  static const String blockBoardKillFallback = '킬스위치 화면 열기';

  /// 해제 진행 머리.
  static const String blockBoardGauges = '해제 진행';

  /// 사다리 머리.
  static const String blockBoardLadder = '서킷브레이커 사다리';

  /// 사다리 지금 단 표지(색만으로 말하지 않는다).
  static const String blockBoardLadderNow = '지금 단계';

  /// 사다리 칸 이름.
  static const String blockBoardLadderTrigger = '들어가는 조건';
  static const String blockBoardLadderRelease = '풀리는 조건';
  static const String blockBoardLadderAction = '조치';

  // ── 🆕 X2 재개 리포트 · 게이트(설계 13 §8 R186) — 칸 이름 · 실패 문장만(머리 · 줄 · 사유 · 버튼 글자 = 엔진) ──

  /// 리포트를 읽지 못했다(원천 오류 — «재개한 적 없음»과 다르다).
  static const String resumeReportReadFailed = '재개 리포트를 읽지 못했습니다.';

  /// 게이트를 읽지 못했다.
  static const String x2GateReadFailed = '재개 화면을 읽지 못했습니다.';

  /// 리포트 항목 머리.
  static const String resumeReportItems = '계획별 결과';

  /// 리포트 복구 불가 자료 머리.
  static const String resumeReportGaps = '복구 불가 자료';

  // ── 🆕 M5-9 규칙 변경 게이트 «첫 승인 최소판»(설계 13 §8 R188 · v1.26 K179 — 폼 입력 머리 · 확인 · 골든 영향 두 버튼 = 카드 정적
  //    라벨) — 머리 · 후보 · 큐 · 결과 글자 = 엔진 ──

  /// 게이트를 읽지 못했다.
  static const String ruleChangeReadFailed = '규칙 변경 화면을 읽지 못했습니다.';

  /// 요청 폼 칸(사람 글 5 — 원문 · 화면 검증 0).
  static const String ruleChangeReason = '사유';
  static const String ruleChangeRollback = '되돌리는 방법';
  static const String ruleChangeRationale = '실행 전 근거';
  static const String ruleChangeExpected = '기대 결과';
  static const String ruleChangeRuleCited = '근거 규칙';

  /// 폼 제출.
  static const String ruleChangeConfirm = '확인';

  /// 승인 폼 — 골든파일 영향(두 버튼) · 승인자 · 제3자 통지.
  static const String ruleChangeGolden = '골든파일 영향';
  static const String ruleChangeGoldenYes = '영향 있음';
  static const String ruleChangeGoldenNo = '영향 없음';
  static const String ruleChangeApprover = '승인자';
  static const String ruleChangeThirdParty = '제3자에게 알렸습니다';

  // ── 🆕 M5-5 RECON 해제 폼(설계 13 §8 R189 · v1.26 K181 — 폼 입력 머리 · 확인 = 카드 정적 라벨) — 선택지 · 고지 · 결과 글자 = 엔진 ──

  /// 폼 여는 버튼(행 안 · 다시 누르면 닫힌다).
  static const String reconClearOpen = '원인 코드 고르기';

  /// 원인 코드 고르기 머리(선택지 글자 = 엔진).
  static const String reconClearOrigin = '원인 코드';

  /// 사전 저널 세 칸(원문 · 화면 검증 0).
  static const String reconClearRationale = '실행 전 근거';
  static const String reconClearExpected = '기대 결과';
  static const String reconClearRuleCited = '근거 규칙';

  /// 폼 제출.
  static const String reconClearConfirm = '확인';

  // ── 🆕 M5-11 simToAuto 위저드 · `handoverStatus`(설계 13 §8 R191 · v1.26 K167~K176) — 읽기 실패만
  //    (머리 · 경로 · 단계 · 시각 · 체험 · 링크 · 버튼 · 결과 글자 = 엔진 · 제출 자체 실패 = [submitNotAccepted]) ──

  /// 위저드를 읽지 못했다(원천 오류 — «전제 밖»과 다르다).
  static const String handoverWizardReadFailed = '실전 전환 화면을 읽지 못했습니다.';

  // ── 🆕 X1 기기 이전(E16j-b · 01 §42) — 읽기 실패 · 칸 이름만(머리 · 단계 · 상태 · 줄 · 버튼 · 시각 · 해시 · 결과 = 엔진 ·
  //    제출 자체 실패 = [submitNotAccepted]) ──

  /// 이전 화면을 읽지 못했다.
  static const String x1ReadFailed = '기기 이전 화면을 읽지 못했습니다.';

  /// 단계 칸 이름.
  static const String x1Steps = '단계';

  /// 재발급 칸 이름.
  static const String x1Reissue = '다시 받을 키';

  // ── 🆕 X5 정정 마법사(설계 13 §8 R227 · 01 §41 K247~K263) — 칸 머리 · 버튼만
  //    (머리 · 근거 · 원인 칩 · 단계 · 시각 · 후보 · 동작 · 결과 글자 = 엔진 · 제출 자체 실패 = [submitNotAccepted]) ──

  /// 마법사를 읽지 못했다(원천 오류).
  static const String repairReadFailed = '정정 마법사를 읽지 못했습니다.';

  /// 탐지 근거 머리.
  static const String repairDiff = '탐지 근거';

  /// 원인 고르기 머리(칩 글자 = 엔진).
  static const String repairOrigin = '원인';

  /// 마찰 단계 머리.
  static const String repairStages = '마찰 단계';

  /// 사전 저널 세 칸(원문 · 화면 검증 0).
  static const String repairJournalRationale = '실행 전 근거';
  static const String repairJournalExpected = '기대 결과';
  static const String repairJournalRuleCited = '근거 규칙';

  /// 저널 제출.
  static const String repairJournalSubmit = '저널 남기기';

  /// 정정 폼 머리 · 고칠 체결 머리.
  static const String repairCorrection = '정정';
  static const String repairFill = '고칠 체결';

  /// 무효로 하기(끄면 네 칸을 다시 적는다).
  static const String repairVoid = '무효로 하기';

  /// 다시 적는 네 칸(원문 · 화면 검증 0).
  static const String repairQuantity = '수량';
  static const String repairPrice = '가격';
  static const String repairCommission = '수수료';
  static const String repairTax = '세금';

  /// 정정 제출.
  static const String repairCorrectSubmit = '정정 실행';

  /// 🆕 R282 — `M5-4` postmortem 화면을 못 읽음(정적 · 원천 오류).
  static const String postmortemReadFailed = 'postmortem 화면을 읽지 못했습니다.';
}
