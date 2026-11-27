// 🆕 미결 243 ⓐ — `M5-4` 안전 사건 postmortem 목록 + 쓰기 VM · 결과(설계 13 §8 R282 · R243 P4 · 계약 v1.39 K345 ·
// 표본 `m5/postmortem_list_*` · `m5/safety_action_results_e13` postmortem 3).
//
// 🔴 행 = 열린 사건 가운데 postmortem 의무 건(기한 `due_at` 있음 — SEV1 STOPPED · SEV2 수동 주문 · SEV3 선택 · 옛 행 = 빠짐) ·
//    차례 = 배너와 같은 엔진 차례
//    (`compareIncidentUrgency` — 심각도 → 기한 → 연 시각 → id) · 화면은 재정렬 · 거르기 · 세기 0.
// 🔴 한 번만 쓴다 — 쓴 행 = 글 읽기 전용 · 쓰기 칸 null · SEV1 은 써도 열린 채(STOPPED 결정이 닫는다 → «STOPPED 결정으로» 링크 =
//    목적지 본문이 있을 때만) · SEV2 · SEV3 = 쓰면 닫혀 목록에서 빠진다.
// 🔴 기한 = 사건 행의 `due_at`(엔진 상수 SEV1 3일 · SEV2 7일로 연 때 적힘) · 넘김 = `postmortemOverdue`(빈칸 ∧ 기한 < 지금) ·
//    글자만(«기한 09-08 10:12» · «기한이 지났습니다(08-27 09:41)») · 금액 0.
// 🔴 쓰기 칸 = 쓰기 창구가 있을 때만([canWrite] — 뷰어 · 기기 id 없음 = 칸 0).
// 🔴 글자 = 표본 제안 문장 그대로(«(합성) » 머리만 뗌).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        LinkAction,
        PostmortemForm,
        PostmortemListVm,
        PostmortemResultCodes,
        PostmortemRow,
        SafetyActionId,
        SafetyActionResult,
        TradeDate,
        UiLevel;

import '../ops/ledger_views.dart'
    show kReconStaleAfter, kstDateText, kstMinuteText;

import 'block_board.dart' show routePatternOf;
import 'incident.dart' show postmortemOverdue;
import 'incident_banner.dart'
    show
        OpenIncident,
        compareIncidentUrgency,
        incidentCategoryLabelOf,
        incidentLevelOf,
        incidentMinuteText;

/// `M5-4` 글자(엔진 · 표본 제안 문장).
abstract final class PostmortemTexts {
  /// 행 제목 — 분류마다(수동 주문 = 해제 한 번 = 1건).
  static String titleOf(String category) => switch (category) {
    'MANUAL_ORDER' => '수동 주문 1건',
    _ => incidentCategoryLabelOf(category),
  };

  /// «09-01 10:12 발생».
  static String occurred(String mdHm) => '$mdHm 발생';

  /// «기한 09-08 10:12».
  static String due(String mdHm) => '기한 $mdHm';

  /// «기한이 지났습니다(08-27 09:41)».
  static String overdue(String mdHm) => '기한이 지났습니다($mdHm)';

  /// 쓸 차례.
  static const String stateDue = '쓸 차례';

  /// SEV1 을 썼다(열린 채 — STOPPED 결정이 닫는다).
  static const String stateWrittenStopped = '썼습니다 — STOPPED 결정이 닫습니다';

  /// SEV2 · SEV3 를 썼다(같은 트랜잭션에서 닫혀 보통 목록에 남지 않는다).
  static const String stateWritten = '썼습니다';

  /// 쓰기 칸.
  static const String prompt = '무슨 일이 있었고, 다음에는 무엇을 바꾸겠습니까?';
  static const String hint = '원인 · 영향 · 바꿀 것 — 숫자보다 사실을 적습니다';
  static const String notice = '한 번만 씁니다 — 고칠 일은 새 저널로 남깁니다';
  static const String button = 'postmortem 저장';

  /// SEV1 을 쓴 뒤 링크.
  static const String nextLink = 'STOPPED 결정으로';

  /// 머리 — 기한 넘김 n건(넘김이 하나라도 있으면 이 글자).
  static String headlineOverdue(int n) => '기한이 지난 postmortem $n건';

  /// 머리 — 쓸 차례 n건.
  static String headlineDue(int n) => '써야 할 postmortem $n건';

  /// 머리 — 쓸 것이 없다(행 0 · 또는 쓴 행만).
  static const String headlineNone = '써야 할 postmortem 이 없습니다';

  /// 빈 목록.
  static const String empty = '열린 사건 가운데 postmortem 을 쓸 것이 없습니다';

  /// 결과 — 저장.
  static const String saved = '사후 검토를 저장했습니다.';

  /// 결과 — 빈 글.
  static const String blank = '사후 검토 글이 비었습니다.';

  /// 결과 — 이미 있다.
  static const String already = '이 사건의 사후 검토는 이미 있습니다.';

  /// 결과 — 건이 없다(닫혔거나 다른 원장 — 목록을 다시 본다).
  static const String notFound = '이 사건을 찾지 못했습니다. 목록을 다시 확인하십시오.';
}

/// 관측 시각 봉투 — «사건 기준 YYYY-MM-DD HH:mm»(관측 = 기기 시각 · 낡음 = 대사 선례).
AsOf postmortemAsOf(DateTime nowUtc) {
  final DateTime at = nowUtc.toUtc();
  return AsOf(
    observedAt: at,
    tradeDate: TradeDate(kstDateText(at)),
    source: AsOfSource.localSqlite,
    staleAfter: kReconStaleAfter,
    label: '사건 기준 ${kstMinuteText(at)}',
  );
}

/// 열린 사건 → `M5-4` VM — [canWrite] = 쓰기 창구가 있나(없으면 칸 0) · [hasBody] = 링크 목적지 본문이 있나(계약 라우트 패턴).
PostmortemListVm postmortemListVmOf(
  Iterable<OpenIncident> open, {
  required DateTime nowUtc,
  required AsOf asOf,
  required bool canWrite,
  required bool Function(String route) hasBody,
}) {
  final List<OpenIncident> all = <OpenIncident>[
    for (final OpenIncident i in open)
      if (i.postmortemDuty) i,
  ]..sort(compareIncidentUrgency);
  final String? stopped = routePatternOf(AppRoutes.m5StoppedDecision);
  final bool stoppedBody = stopped != null && hasBody(stopped);
  int due = 0, late = 0;
  final List<PostmortemRow> rows = <PostmortemRow>[
    for (final OpenIncident i in all)
      _row(i, nowUtc: nowUtc, canWrite: canWrite, stoppedBody: stoppedBody),
  ];
  for (final PostmortemRow r in rows) {
    if (r.writtenText == null) due++;
    if (r.overdue) late++;
  }
  if (rows.isEmpty) {
    return PostmortemListVm(
      headline: PostmortemTexts.headlineNone,
      level: UiLevel.ok,
      rows: const <PostmortemRow>[],
      emptyLabel: PostmortemTexts.empty,
      asOf: asOf,
    );
  }
  return PostmortemListVm(
    headline: late > 0
        ? PostmortemTexts.headlineOverdue(late)
        : due > 0
        ? PostmortemTexts.headlineDue(due)
        : PostmortemTexts.headlineNone,
    level: due > 0 ? UiLevel.act : UiLevel.info,
    rows: rows,
    asOf: asOf,
  );
}

PostmortemRow _row(
  OpenIncident i, {
  required DateTime nowUtc,
  required bool canWrite,
  required bool stoppedBody,
}) {
  final bool written = i.postmortemWritten;
  final bool overdue = postmortemOverdue(
    dueAtUtc: i.dueAtUtc,
    postmortem: i.postmortem,
    nowUtc: nowUtc,
  );
  final DateTime? dueAt = i.dueAtUtc;
  final bool sev1 = i.severity == 'SEV1';
  return PostmortemRow(
    incidentId: i.incidentId,
    title: PostmortemTexts.titleOf(i.category),
    severityLabel: i.severity,
    level: incidentLevelOf(i.severity),
    occurredText: PostmortemTexts.occurred(incidentMinuteText(i.occurredAtUtc)),
    dueText: written
        ? null
        : overdue
        ? PostmortemTexts.overdue(incidentMinuteText(dueAt!))
        : PostmortemTexts.due(incidentMinuteText(dueAt!)),
    overdue: overdue,
    stateLabel: !written
        ? PostmortemTexts.stateDue
        : sev1
        ? PostmortemTexts.stateWrittenStopped
        : PostmortemTexts.stateWritten,
    writtenText: written ? i.postmortem : null,
    form: !written && canWrite
        ? const PostmortemForm(
            promptText: PostmortemTexts.prompt,
            hintText: PostmortemTexts.hint,
            noticeText: PostmortemTexts.notice,
            buttonLabel: PostmortemTexts.button,
          )
        : null,
    nextLink: written && sev1 && stoppedBody
        ? const LinkAction(
            label: PostmortemTexts.nextLink,
            deepLink: AppRoutes.m5StoppedDecision,
          )
        : null,
  );
}

/// postmortem 결과 — [code] null = 저장 · 글자 = 엔진(표본 제안 문장) · 모르는 코드 = [ArgumentError].
SafetyActionResult postmortemActionResultOf({
  required String actionRunId,
  String? code,
}) {
  final (UiLevel level, String headline) = switch (code) {
    null => (UiLevel.ok, PostmortemTexts.saved),
    PostmortemResultCodes.blank => (UiLevel.act, PostmortemTexts.blank),
    PostmortemResultCodes.alreadyRecorded => (
      UiLevel.info,
      PostmortemTexts.already,
    ),
    PostmortemResultCodes.notFound => (UiLevel.info, PostmortemTexts.notFound),
    final String other => throw ArgumentError.value(
      other,
      'code',
      '모르는 postmortem 거부 코드',
    ),
  };
  return SafetyActionResult(
    actionRunId: actionRunId,
    id: SafetyActionId.postmortemRecord,
    level: level,
    headline: headline,
    reasonCode: code,
    retryable: false,
  );
}
