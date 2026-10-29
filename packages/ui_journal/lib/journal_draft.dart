// lib/journal_draft.dart — operator 앱 전용 · iOS·웹 앱은 import 하지 않는다(docs/TARGETS.md T-3).
//
// 🔴 이 배럴은 lib/ui_journal.dart 에 포함되지 않는다.
//    lib/ 의 다른 파일(배럴·timeline.dart·decision_detail.dart·unknown_board.dart·common/)이
//    이 파일 또는 src/journal_draft/ 를 import 하지 않는다.
//    방향은 journal_draft → 배럴 쪽 파일만 허용(전이로 iOS 빌드에 들어가지 않게).

export 'src/journal_draft/advice_skip_form.dart';
export 'src/journal_draft/journal_draft_form.dart';
