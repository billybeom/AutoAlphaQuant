// ui_journal — M6(매매일지·보유현황) 화면 패키지의 배럴.
//
// 🔴 의존은 domain_contracts · Flutter · Riverpod **만**이다(C-3).
// 🔴 화면은 계산하지 않는다 — 수익률·비중·손절선·기여도는 전부 계약이 준 값을
//    표시만 한다. 곱셈·나눗셈·합계·백분율 변환·날짜 차이 계산은 위반이다(C-4).
// 🔴 사유 문구를 만들지 않는다 — 상태를 설명하는 문장은 DTO의 label 계열
//    필드로 온다. 정적 UI 라벨만 lib/l10n/labels.dart에 둔다(C-5).
//
// 아직 비어 있다. 화면 위젯은 lib/src/ 아래로 들어오고 공개할 것만 여기에서
// export 한다.

export 'l10n/labels.dart';
export 'src/advice/advice_card.dart';
export 'src/advice_history.dart';
export 'src/advice_inbox.dart';
export 'src/blind_review.dart';
export 'src/decision_detail.dart';
export 'src/holding_detail.dart';
export 'src/holdings_allocation.dart';
export 'src/holdings_overview.dart';
export 'src/journal_read.dart';
export 'src/ledger_diffs.dart';
export 'src/ledger_repairs.dart';
export 'src/timeline.dart';
export 'src/unknown_board.dart';
