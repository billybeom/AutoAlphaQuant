// 🆕 계약 v1.41(01 §50 · K367 · 13 §8 R272 Y3 ⓔ · Y7 · 00_README §8-4 ㊵) — 뷰어 명령 4종의 TTL(`command_queue.expires_at` = 낸 시각 + 이 값).
//
// 🔴 누가 쓰나 = 뷰어 `CommandApi` 구현(E11m-b · PostgREST INSERT 의 `expires_at`) — 뷰어는 운영 설정(`operations.record_command_ttl_days`)을
//    읽지 못해 계약 상수로 둔다. 운영 폰이 내는 명령(X7 · 입금 등록 · 알림 확인 등)의 TTL = 엔진 · 운영 설정 몫(여기 밖 · [of] = null).
// 🔴 서버 상한 0(R272 Y3 ⓔ) — `command_insert_viewer` 는 `expires_at > now()` 만 본다 · 만료 판정 = 소비기(E11m-a)가 `expires_at` 으로.
// 🔴 뷰어 명령은 늦게 닿아 손해 보는 것이 없다 — 만료는 안전이 아니라 **사실 손실**이다(㊵ 결). 그래서 짧게 두지 않는다:
//    킬스위치 = 늦게 닿아도 멈춤(안전 쪽) · 만료되면 «요청됨»이 침묵한다(G-26 가장 위험한 오인) · 소비 주체가 없는 창이 길어도 살아남게 30일.
//    저널 초안 · blind 리뷰 점수 · 열람 이벤트 = 사람이 남긴 사실 · ㊵ 기록 계열과 같은 14일.
// 🔴 화면 · 표본은 이 값을 글자로 적지 않는다(C-32 결 — 남은 시간 글자는 엔진이 짓는다).

import '../enums/command.dart';

/// 뷰어 명령 4종 TTL.
abstract final class ViewerCommandTtl {
  /// `KILL_SWITCH_ACTIVATE`.
  static const Duration killSwitchActivate = Duration(days: 30);

  /// `JOURNAL_DRAFT`.
  static const Duration journalDraft = Duration(days: 14);

  /// `BLIND_REVIEW_SCORE`.
  static const Duration blindReviewScore = Duration(days: 14);

  /// `DISCLOSURE_VIEW`.
  static const Duration disclosureView = Duration(days: 14);

  /// 뷰어가 낼 수 있는 종류 = 배치 D `command_insert_viewer` 화이트리스트 4종(차례 그대로 · C-74 대조).
  static const List<CommandKind> kinds = <CommandKind>[
    CommandKind.killSwitchActivate,
    CommandKind.journalDraft,
    CommandKind.blindReviewScore,
    CommandKind.disclosureView,
  ];

  /// 종류 → TTL · 뷰어 4종 밖 = null(운영 폰 명령 = 엔진 · 운영 설정).
  static Duration? of(CommandKind k) => switch (k) {
    CommandKind.killSwitchActivate => killSwitchActivate,
    CommandKind.journalDraft => journalDraft,
    CommandKind.blindReviewScore => blindReviewScore,
    CommandKind.disclosureView => disclosureView,
    // 운영 폰 명령 — 전수 나열(C-12 · 새 종류 = 컴파일 실패 → 뷰어 허용 여부를 정하고 더한다).
    CommandKind.depositRegister ||
    CommandKind.manualFillRecord ||
    CommandKind.manualFillAmend ||
    CommandKind.manualFillVoid ||
    CommandKind.adviceSkip ||
    CommandKind.selfReportBalance ||
    CommandKind.alertAck ||
    CommandKind.killChecklistConfirm ||
    CommandKind.ledgerEventRecord ||
    CommandKind.adviceDeferConfirm => null,
  };
}
