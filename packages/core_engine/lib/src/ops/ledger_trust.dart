// E11q-q6c — X7 원장 신뢰 등급 사다리(투자 안내 = 실사 갭) · 실사 예정 · 기한 표식 판정(앱 계약 01 §2-11 · §3-5 · 02 §2-2 ·
// §3-10 · 04 §2-1 블록 9b · §5-1b · 06 X7-3 · 설계 13 §8 R240).
//
// 🔴 수치 원천 = 문서 셋뿐: 기한 = 마지막 실사 기준일 + 60일(D+60 — 06 X7-3 · 04 9b) · 재고지 = 기한 15일 전(D-15 — 01 §3-5
//    `SELF_AUDIT_DUE` 행) · 주기 = 월 1회(00 원장 실사 · 04 §5-1b · `AlertCodes.selfAuditDue` · 01 §8 미결 118 = 권고대로 월).
//    그 밖의 강등 문턱(미처리 갭 n거래일 · 롤링 n회 · «3거래일째» 어긋남)은 문서에 숫자가 없다 → 짓지 않는다(계약 창 · 발주자
//    수치 대기 — 이 판의 투자 안내 사다리 = 실사 갭 한 카운터).
// 🔴 실사 갭 = 마지막 실사 «기준일»부터 한국 오늘까지의 달력 일수(06 X7-3 «경과일» · 확인 날 = 기준일 — R234) · 오늘 = 신뢰
//    시각(E11k-a 관문 — 부르는 쪽이 모르면 판정하지 않는다 · 기기 시계로 대신하지 않는다).
// 🔴 그 달 실사가 «남은 것»이 되는 때 = 그 달 기준일(마지막 KR 세션) 종가 확정(KR 18:00 — R234 세션 여는 판정과 같은 문턱).
// 🔴 차단은 실사의 «부재»에만(A12) — 실사 1회(차이가 있어도)면 갭이 그 기준일부터 다시 센다. 차이의 해소 = `M5-13`(다른 축 ·
//    `ADVICE_LEDGER_UNVERIFIED`). 실사 기록이 없는 계좌 = 셀 기준이 없다(개시 실사 = `M5-10` 단계 2 몫) → 표식 0.
// 🔴 반복 알림 금지(02 §2-2) — `SELF_AUDIT_DUE` 알림 = 표식이 서는 때 1회 + D-15 재고지 1회. 기한을 넘기면 표식이 바뀔 뿐
//    알림 코드는 없다(04 §5-1b) · 하향 알림(`LEDGER_TRUST_DOWNGRADE`) 글자는 표본이 «자가 보고로 내려옴» 한 갈래뿐이라 내지 않는다.
// 🔴 자동 매매 = 브로커 대사 결과 한 판정([reconLedgerTrustOf] — 월간 리포트와 같은 함수 · as-of 만 «지금»).

import 'package:domain_contracts/domain_contracts.dart';

import '../calendar/exchange_calendar.dart';
import '../data/quote_feed.dart' show lastFinishedSession;
import 'ledger_views.dart' show kstDateText;
import 'self_report.dart'
    show
        SelfReportTrustTexts,
        selfReportAsOfOf,
        selfReportLinkOf,
        selfReportTrustBadgeOf;

/// 실사 기한(일) — 마지막 실사 기준일 + 60일(D+60 · 06 X7-3 · 04 §2-1 9b).
const int kSelfAuditOverdueDays = 60;

/// 재고지(일) — 기한 15일 전(D-15 · 01 §3-5 `SELF_AUDIT_DUE` 행).
const int kSelfAuditRenoticeDays = 15;

/// 실사 표식 · 알림의 낸 곳(`alert_event.source` · `trading_block.cleared_by` 꼬리).
const String kSelfAuditCheck = 'self_audit';

/// 원장 신뢰 배지 글자(표본에 있는 것은 글자 그대로).
abstract final class LedgerTrustTexts {
  /// 실사 예정(표본 `m7/ledger_trust_self_audit_due`).
  static String dueLine(int gapDays) =>
      '마지막 실사 후 $gapDays일 경과 — 이번 달 실사 1회로 등급이 유지됩니다';

  /// 실사 기한 초과(01 §2-11 `consequenceLine` · 02 §2-2 `SELF_AUDIT_OVERDUE` 행의 예 글자).
  static String overdueLine(int gapDays) =>
      '마지막 실사 후 $gapDays일 경과 — 실사 1회로 회복됩니다';

  /// 어긋나는 중(표본 `m7/ledger_trust_4` 셋째 행 라벨).
  static const String driftingLabel = '어긋나는 중';

  /// 회복 길(표본 `m7/ledger_trust_4` 셋째 행).
  static const String driftingUpgradeHint = '실사를 마치면 등급이 회복됩니다.';

  /// 🆕 자동 매매 · 지금까지 브로커 대사 0(월간 «그 달 마감까지» 의 «지금» 판).
  static const String noReconNowLine = '아직 브로커 대사 기록이 없습니다.';
}

/// 실사 갭 단계(차례 = 무거운 쪽이 뒤 — 계좌 여럿이면 가장 무거운 계좌).
enum SelfAuditStage {
  /// 실사 기록이 없다 — 셀 기준이 없다(표식 0 · 개시 실사 = `M5-10` 단계 2).
  noAnchor,

  /// 닫힌 달의 실사까지 끝났다.
  current,

  /// 닫힌 달의 실사가 남았다 — 표식 `SELF_AUDIT_DUE`(차단 아님) · 알림 1회.
  due,

  /// 기한 15일 전부터(D-15 재고지 — 알림 1회 더).
  renotice,

  /// 기한(D+60)을 넘겼다 — `SELF_AUDIT_OVERDUE`(신규 진입 안내 중단 · 실사 1회로 풀린다).
  overdue,
}

/// 실사 갭 판정(가장 무거운 계좌 하나).
class SelfAuditVerdict {
  /// 만든다.
  const SelfAuditVerdict({
    required this.stage,
    this.accountAlias,
    this.yyyyMm,
    this.lastVerifiedOn,
    this.gapDays,
  });

  /// 단계.
  final SelfAuditStage stage;

  /// 대상 계좌(실사 기록이 있는 계좌 가운데 가장 무거운 · 같으면 갭이 긴 · 같으면 계좌 차례 앞).
  final String? accountAlias;

  /// 실사할 달 = 가장 최근 닫힌 달(`due` 이상 · 달력 밖 = null).
  final String? yyyyMm;

  /// 그 계좌의 마지막 실사 기준일.
  final TradeDate? lastVerifiedOn;

  /// 실사 갭(달력 일수).
  final int? gapDays;

  /// 그 달 · 그 계좌 `L-3` 링크(없으면 null — 달을 모르거나 별칭에 `/` `?` `#`).
  String? get link => yyyyMm == null || accountAlias == null
      ? null
      : selfReportLinkOf(yyyyMm!, accountAlias!);
}

int _daysBetween(String a, String b) =>
    DateTime.parse('${b}T00:00:00Z')
        .difference(DateTime.parse('${a}T00:00:00Z'))
        .inDays;

String _prevMonth(String yyyyMm) {
  final int y = int.parse(yyyyMm.substring(0, 4));
  final int m = int.parse(yyyyMm.substring(5, 7));
  final DateTime p = DateTime.utc(y, m - 1);
  return '${p.year.toString().padLeft(4, '0')}-${p.month.toString().padLeft(2, '0')}';
}

/// 가장 최근 닫힌 달과 그 기준일 — 기준일 종가 확정(KR 18:00) 뒤에 닫힌다 · 달력 밖 = null.
(String, TradeDate)? selfAuditClosedMonthOf(
  DateTime trustedNowUtc,
  ExchangeCalendar kr,
) {
  final String finished;
  try {
    finished = lastFinishedSession(kr, trustedNowUtc);
  } on StateError {
    return null;
  }
  final String m = finished.substring(0, 7);
  final TradeDate? asOf = selfReportAsOfOf(m, kr);
  if (asOf != null && asOf.yyyyMmDd == finished) return (m, asOf);
  final String pm = _prevMonth(m);
  final TradeDate? prev = selfReportAsOfOf(pm, kr);
  return prev == null ? null : (pm, prev);
}

/// 🔴 실사 갭 판정(06 X7-3) — [accounts] = 계좌 차례(`selfReportAccountsOf`) · [lastVerified] = 계좌 → 마지막 정기 실사 기준일 ·
/// [trustedNowUtc] = 신뢰 시각(기기 시계 금지). 단계 = 갭 ≥ 60 → 기한 초과 / 닫힌 달 실사가 남음 ∧ 갭 ≥ 45 → 재고지 /
/// 남음 → 예정 / 아니면 기한 안. 실사 기록이 없는 계좌는 보지 않는다(전부 없으면 `noAnchor`).
SelfAuditVerdict selfAuditVerdictOf({
  required List<String> accounts,
  required Map<String, TradeDate> lastVerified,
  required DateTime trustedNowUtc,
  required ExchangeCalendar kr,
}) {
  final (String, TradeDate)? closed = selfAuditClosedMonthOf(trustedNowUtc, kr);
  final String today = kstDateText(trustedNowUtc);
  SelfAuditVerdict best = const SelfAuditVerdict(
    stage: SelfAuditStage.noAnchor,
  );
  for (final String alias in accounts) {
    final TradeDate? last = lastVerified[alias];
    if (last == null) continue;
    final int gap = _daysBetween(last.yyyyMmDd, today);
    final bool owed =
        closed != null && last.yyyyMmDd.compareTo(closed.$2.yyyyMmDd) < 0;
    final SelfAuditStage s = gap >= kSelfAuditOverdueDays
        ? SelfAuditStage.overdue
        : !owed
        ? SelfAuditStage.current
        : gap >= kSelfAuditOverdueDays - kSelfAuditRenoticeDays
        ? SelfAuditStage.renotice
        : SelfAuditStage.due;
    final bool heavier =
        best.stage == SelfAuditStage.noAnchor ||
        s.index > best.stage.index ||
        (s.index == best.stage.index && gap > best.gapDays!);
    if (!heavier) continue;
    best = SelfAuditVerdict(
      stage: s,
      accountAlias: alias,
      yyyyMm: s.index >= SelfAuditStage.due.index ? closed?.$1 : null,
      lastVerifiedOn: last,
      gapDays: gap,
    );
  }
  return best;
}

/// 재고지가 시작되는 때(기한 15일 전 날의 한국 0시 · UTC) — 기록이 없으면 null.
DateTime? selfAuditRenoticeStartUtc(SelfAuditVerdict v) {
  final TradeDate? last = v.lastVerifiedOn;
  if (last == null) return null;
  return DateTime.parse('${last.yyyyMmDd}T00:00:00Z')
      .add(const Duration(days: kSelfAuditOverdueDays - kSelfAuditRenoticeDays))
      .subtract(const Duration(hours: 9));
}

/// 🔴 투자 안내의 지금 신뢰 배지 — 실사 경로의 상한 = `SELF_REPORTED`(실패가 아니라 정상 운영 상태):
/// 기한 안 · 기록 없음 = 실사 VM 과 같은 배지([selfReportTrustBadgeOf] · 링크 0) / 예정 · 재고지 = 표본
/// `ledger_trust_self_audit_due`(INFO · «등급이 유지됩니다» · 그 달 · 그 계좌 `L-3`) / 기한 초과 = `DRIFTING` · ACT
/// («실사 1회로 회복됩니다» — 01 §2-11 예 글자 · 표본 `ledger_trust_4` 셋째 행 라벨 · 회복 길 · 링크 = 그 달 · 그 계좌 `L-3`).
LedgerTrustBadge selfAuditTrustBadgeOf(SelfAuditVerdict v) => switch (v.stage) {
  SelfAuditStage.noAnchor ||
  SelfAuditStage.current => selfReportTrustBadgeOf(v.lastVerifiedOn),
  SelfAuditStage.due || SelfAuditStage.renotice => LedgerTrustBadge(
    grade: LedgerTrustGrade.selfReported,
    level: UiLevel.info,
    label: SelfReportTrustTexts.label,
    consequenceLine: LedgerTrustTexts.dueLine(v.gapDays!),
    upgradeHint: SelfReportTrustTexts.upgradeHint,
    lastVerifiedOn: v.lastVerifiedOn,
    actionDeepLink: v.link,
  ),
  SelfAuditStage.overdue => LedgerTrustBadge(
    grade: LedgerTrustGrade.drifting,
    level: UiLevel.act,
    label: LedgerTrustTexts.driftingLabel,
    consequenceLine: LedgerTrustTexts.overdueLine(v.gapDays!),
    upgradeHint: LedgerTrustTexts.driftingUpgradeHint,
    lastVerifiedOn: v.lastVerifiedOn,
    actionDeepLink: v.link,
  ),
};

/// 실사 표식의 `trading_block.reason` 꼴 = 그 달 · 그 계좌 `L-3` 링크(해제 · 알림 목적지의 원천).
final RegExp _l3Link = RegExp(
  r'^aaq://ledger/self-report/\d{4}-(?:0[1-9]|1[0-2])/[^/?#]+$',
);

/// 실사 표식 reason → `L-3` 링크(꼴이 아니면 null — 목적지를 짓지 않는다).
String? selfAuditLinkOfReason(String? reason) =>
    reason != null && _l3Link.hasMatch(reason) ? reason : null;

/// 실사 표식 reason(링크가 없으면 그 까닭 글자 — `trading_block.reason` NOT NULL).
String selfAuditReasonOf(SelfAuditVerdict v) =>
    v.link ?? '원장 실사 기한(목적지 없음 · ${v.yyyyMm ?? '달 모름'})';

/// 실사 표식 · 알림 계획.
class SelfAuditFlagPlan {
  /// 만든다.
  const SelfAuditFlagPlan({
    required this.due,
    required this.overdue,
    required this.alert,
    this.reason,
  });

  /// `SELF_AUDIT_DUE` 가 서 있어야 하나.
  final bool due;

  /// `SELF_AUDIT_OVERDUE` 가 서 있어야 하나.
  final bool overdue;

  /// `SELF_AUDIT_DUE` 알림 1건을 내나.
  final bool alert;

  /// 서 있을 때의 reason([selfAuditReasonOf]).
  final String? reason;
}

/// 🔴 표식 · 알림 계획(반복 알림 금지) — [verdict] null = 투자 안내가 아니다(둘 다 내림) · [dueActive] = 지금
/// `SELF_AUDIT_DUE` 가 서 있나 · [alertedSinceRenotice] = 재고지 시작([selfAuditRenoticeStartUtc]) 뒤 `SELF_AUDIT_DUE` 알림이
/// 있었나. 예정 · 재고지 = DUE 만 · 알림 = 새로 설 때 1회 + 재고지 1회 / 기한 초과 = OVERDUE 만(DUE → OVERDUE · 알림 0) /
/// 그 밖 = 둘 다 내림.
SelfAuditFlagPlan selfAuditFlagPlanOf({
  required SelfAuditVerdict? verdict,
  required bool dueActive,
  required bool alertedSinceRenotice,
}) {
  final SelfAuditVerdict? v = verdict;
  if (v == null || v.stage.index < SelfAuditStage.due.index) {
    return const SelfAuditFlagPlan(due: false, overdue: false, alert: false);
  }
  if (v.stage == SelfAuditStage.overdue) {
    return SelfAuditFlagPlan(
      due: false,
      overdue: true,
      alert: false,
      reason: selfAuditReasonOf(v),
    );
  }
  return SelfAuditFlagPlan(
    due: true,
    overdue: false,
    alert:
        !dueActive ||
        (v.stage == SelfAuditStage.renotice && !alertedSinceRenotice),
    reason: selfAuditReasonOf(v),
  );
}
