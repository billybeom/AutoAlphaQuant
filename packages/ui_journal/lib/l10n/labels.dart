// 정적 UI 라벨 — 이 파일이 ui_journal에서 한글 문자열 리터럴이 허용되는
// **유일한 자리**다(01 §1-5 · C-5).
//
// 여기 두는 것: 데이터가 바뀌어도 글자가 그대로인 것.
//   예: '닫기' · '다시 시도' · '필터' · '기간' · '슬리브' · 탭 이름 · '모의' 배지
//
// 🔴 여기 두면 안 되는 것: 상태를 설명하는 문장. 사유·판정·빈 상태·차단 사유는
//    전부 엔진이 DTO 필드로 준다 — label · statusLabel · visibilityLabel ·
//    emptyLabel · actionLine · clearInstruction · disclosureNote.
//    01 §3의 사유 문구를 이 파일에 베껴 적는 것도 위반이다.
//
// 🔴 판단 기준: 데이터가 바뀌어도 글자가 같으면 정적 라벨, 데이터·상태에 따라
//    달라지면 사유 문구다. `if 상태 then '차단됨' else '정상'`처럼 **분기로
//    고르는 것은 정적 라벨이 아니라 생성**이다.
//
// 🔴 짝이 되는 *Label 필드가 없는 열거값을 발견하면, 문구를 지어내지 말고
//    **계약 결함으로 보고**한다(01 §1-5).

/// ui_journal의 정적 UI 라벨 모음. 인스턴스를 만들지 않는다.
abstract final class JournalLabels {
  static const String simulation = '모의';
  static const String retry = '다시 시도';

  /// 오래된 데이터 배너 제목 (A4 · F3).
  static const String staleBannerTitle = '오래된 데이터';

  /// 수수료 필드 이름 (A3 · F6).
  static const String commission = '수수료';

  /// 세금 필드 이름 (A3 · F6).
  static const String tax = '세금';

  // ── 🆕 v1.1 — 필터 UI 정적 라벨 (ⓒ) ───────────────────────────────────────

  /// 필터 버튼 / 바텀시트 제목.
  static const String filter = '필터';

  /// 「전체」 선택지(필터 없음 = 인자 null).
  static const String filterAll = '전체';

  /// 필터 적용 버튼.
  static const String filterApply = '적용';

  /// 필터 초기화 버튼.
  static const String filterReset = '초기화';

  /// 필터 바텀시트 — 기간 섹션 제목.
  static const String filterRange = '기간';

  /// 필터 바텀시트 — 슬리브 섹션 제목.
  static const String filterSleeve = '슬리브';

  /// 필터 바텀시트 — 종목 섹션 제목.
  static const String filterSymbol = '종목';

  /// 필터 바텀시트 — 상태 섹션 제목.
  static const String filterStatus = '상태';

  /// 필터 바텀시트 — 출처 섹션 제목.
  static const String filterOrigin = '출처';

  // ── 🆕 R2 — J-2 거래 상세 ─────────────────────────────────────────────────

  /// 결정 당시 스냅샷 접이식 제목.
  static const String decisionSnapshot = '결정 당시 스냅샷';

  /// 임계값 대조 표 제목.
  static const String thresholdCompare = '트리거 값 vs 사전 등록 임계값';

  /// 거부 추적 접이식 제목.
  static const String rejectTrace = '검사 기록';

  /// configHash 길게 누름 → 클립보드 복사 완료 안내.
  static const String copied = '복사했습니다';

  // ── 🆕 R2 — J-3 사전 저널 폼 ────────────────────────────────────────────

  /// 사전 근거 입력란 레이블.
  static const String draftRationale = '사전 근거';

  /// 기대 결과 입력란 레이블.
  static const String draftExpected = '기대 결과';

  /// 인용 규칙 드롭다운 레이블.
  static const String draftRuleCited = '인용 규칙';

  /// 메모 입력란 레이블.
  static const String draftNote = '메모';

  /// 제출 버튼 레이블.
  static const String draftSubmit = '제출';

  // ── 🆕 R2b — J-3 접수 실패 1줄(01 §12-3) ──────────────────────────────────

  /// 명령 Future 에러 때 제출 버튼 바로 위 1줄(01 §12-3 · 문구 5원칙).
  static const String submitNotAccepted = '제출이 접수되지 않았습니다. 입력은 그대로 있습니다.';
}
