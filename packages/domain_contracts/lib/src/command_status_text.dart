// 🆕 계약 v1.41(01 §50 · K366 · 01 §10-8 G-26 ⓑ · 13 §8 R272 Y2 ⓔ · Y4 · Y7) — 서버가 판정한 명령 상태 두 개의 고정 글자 카탈로그.
// 🔴 표지 글자 상수라 C-5 사전 대상(`lib/src/labels/`) 밖에 둔다(`ModeMarkerText` · `BiometricPromptText` 선례 · byDomain 0).
// 🔴 누가 쓰나 = 뷰어 `CommandApi` 구현(E11m-b) — `command_status` 가 돌려준 `REQUESTED` · `NO_OPERATOR` 행(`state_label` = null)에
//    이 글자를 골라 `CommandReceipt.stateLabel` 에 싣는다. 화면은 `stateLabel` 만 그린다(§1-5 — 화면이 상태로 문장을 짓지 않는다).
//    그 밖 상태 = 최신 ack 의 엔진 글자(`command_ack.state_label`) 그대로 — 이 카탈로그가 대신하지 않는다([of] = null).
// 🔴 G-26 — «요청됨» 이 «껐다» 로 읽히는 것이 이 설계에서 가장 위험한 오인이다: [requested] 는 «아직 처리 전»을 말하고,
//    [noOperator] 는 받을 기기가 없다는 사실과 지금 할 수 있는 길(증권사 앱에서 직접)을 말한다. 🔴 SQL · 엔진에 같은 글자 0(원천 하나).
// 🔴 금액 · 계좌 · 종목 · 수치 0.

import 'enums/command.dart';

/// 서버 판정 명령 상태 → 고정 글자.
abstract final class CommandStatusText {
  /// `REQUESTED` — 보냄 · 운영 폰 수신 대기(ack 없음 ∧ 유효 리스).
  static const String requested = '보냄 — 운영 폰이 아직 받지 않았습니다(처리 전)';

  /// `NO_OPERATOR` — 유효 리스 없음(X1 이전 창 · 비상 대기 · 운영 폰 꺼짐) ∧ 종단 ack 없음.
  static const String noOperator =
      '받을 기기 없음 — 지금은 이 요청을 처리할 운영 폰이 없습니다. 급하면 증권사 앱에서 직접 미체결 주문을 취소하십시오.';

  /// 서버 판정 상태 → 글자 · 그 밖 상태 = null(최신 ack 의 엔진 글자를 쓴다).
  static String? of(CommandState s) => switch (s) {
    CommandState.requested => requested,
    CommandState.noOperator => noOperator,
    // 최신 ack 의 엔진 글자(`command_ack.state_label`) — 전수 나열(C-12 · 새 상태 = 컴파일 실패).
    CommandState.received ||
    CommandState.executed ||
    CommandState.rejected ||
    CommandState.expired ||
    CommandState.staleContext ||
    CommandState.heldForIntegrity ||
    CommandState.pendingLeaseConfirm => null,
  };
}
