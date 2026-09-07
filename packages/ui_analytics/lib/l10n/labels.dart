// 정적 UI 라벨 — 이 파일이 ui_analytics에서 한글 문자열 리터럴이 허용되는
// **유일한 자리**다(01 §1-5 · C-5).
//
// 여기 두는 것: 데이터가 바뀌어도 글자가 그대로인 것.
//   예: '닫기' · '기간' · '누적' · '슬리브' · 탭 이름
//
// 🔴 여기 두면 안 되는 것: 상태를 설명하는 문장. 구간 사유·표본 크기 고지·
//    미리보기 고지·빈 상태는 전부 엔진이 DTO 필드로 준다 — PerfSegment.label ·
//    PerfDisclosure · previewNotice · emptyLabel · disclosureNote.
//
// 🔴 판단 기준: 데이터가 바뀌어도 글자가 같으면 정적 라벨, 데이터·상태에 따라
//    달라지면 사유 문구다. 분기로 고르는 것은 정적 라벨이 아니라 **생성**이다.
//
// 아직 비어 있다. 화면을 만들면서 실제로 필요한 상수만 추가한다.

/// ui_analytics의 정적 UI 라벨 모음. 인스턴스를 만들지 않는다.
abstract final class AnalyticsLabels {
  // 예: static const String close = '닫기';
}
