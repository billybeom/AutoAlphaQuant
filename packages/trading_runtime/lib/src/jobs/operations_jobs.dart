// E11q-s05 — M9 `S05` 잡 행 · 다음 잡 한 줄(설계 13 §8 R252 · 앱 01 §28 K12 · 미결 168 `jobs` · `control`).
//
// 🔴 행 = 잡 표(kJobTable) 차례 그대로 · 이름표 = 감시 보드와 같은 엔진 문구(`kJobWatchdogLabels` — 같은 잡 같은 이름).
// 🔴 상태 = 그 잡의 마지막 `job_run` 행(모드 시작 뒤 · 끝 시각 순) — `statusCode` = `job_run.status` 4 + 회차 0 = `NONE`(K12).
//    짝(C-53 ⑩): SUCCESS ⇒ ok · LATE ⇒ watch · HOLIDAY ⇒ info · NONE ⇒ info · FAILED ⇒ act.
// 🔴 유예 = 받은 값(잡 표 · config 덮어쓰기)을 글자로 옮길 뿐 — 새 숫자 0.
// 🔴 놓친 회차(예정이 지났는데 기록 없음)의 판정 = 감시 보드(W-01 · `watchdogBoardInputsFor`) 몫 — 이 행은 기록만 옮긴다.

import 'package:core_engine/core_engine.dart' show JobRunEntry, JobRunStatus;
import 'package:domain_contracts/domain_contracts.dart' show JobRow, UiLevel;

import 'job_schedule.dart';
import 'watchdog_rows.dart' show kJobWatchdogLabels;

/// 잡 행 글자(엔진 정본 · 표본 `m9/operations_*` 꼴).
abstract final class OperationsJobTexts {
  /// 회차 0.
  static const String neverRan = '아직 돈 적 없음';

  /// 실패 한 줄.
  static const String failedDetail = '다음 회차가 다시 돕니다. 이어서 실패하면 감시 보드에서 확인하십시오.';

  /// 상태 글자.
  static String state(JobRunStatus? s) => switch (s) {
    null => '아직 없음',
    JobRunStatus.success => '성공',
    JobRunStatus.late => '지연 — 성공',
    JobRunStatus.failed => '실패',
    JobRunStatus.holiday => '휴장',
  };
}

String _two(int n) => n.toString().padLeft(2, '0');

String _hm(Duration kst) =>
    '${_two(kst.inHours)}:${_two(kst.inMinutes.remainder(60))}';

String _cadence(JobCadence c) => switch (c) {
  JobCadence.krWeekday => '평일',
  JobCadence.krAfterMonthEnd => '월말 다음 거래일',
  JobCadence.usNextKstDay => '미국 거래일 다음 날',
};

String _grace(Duration g) =>
    g.inMinutes % 60 == 0 ? '${g.inHours}시간' : '${g.inMinutes}분';

/// 잡 줄의 일정 글자(«평일 09:10 · 유예 1시간»).
String operationsScheduleTextOf(JobSpec s, {Duration? grace}) =>
    '${_cadence(s.cadence)} ${_hm(s.kstTime)} · 유예 ${_grace(grace ?? s.grace)}';

/// 한국 시각 글자 — 같은 한국 날 = «오늘» · 다음 날 = «내일» · 그 밖 = «M월 d일».
String operationsWhenText(DateTime atUtc, DateTime nowUtc) {
  final DateTime k = atUtc.toUtc().add(const Duration(hours: 9));
  final DateTime n = nowUtc.toUtc().add(const Duration(hours: 9));
  final DateTime kd = DateTime.utc(k.year, k.month, k.day);
  final DateTime nd = DateTime.utc(n.year, n.month, n.day);
  final int days = kd.difference(nd).inDays;
  final String day = days == 0
      ? '오늘'
      : days == 1
      ? '내일'
      : '${k.month}월 ${k.day}일';
  return '$day ${_two(k.hour)}:${_two(k.minute)}';
}

UiLevel _level(JobRunStatus? s) => switch (s) {
  null => UiLevel.info,
  JobRunStatus.success => UiLevel.ok,
  JobRunStatus.late => UiLevel.watch,
  JobRunStatus.failed => UiLevel.act,
  JobRunStatus.holiday => UiLevel.info,
};

/// 🔴 잡 행 — [entriesOf] = 잡 → 그 잡의 `job_run` 줄 · [notBeforeUtc] = 모드 시작(앞 기록 = 보지 않는다) ·
/// [graceOverride] = 잡 → 유예(config).
List<JobRow> operationsJobRowsOf({
  required List<JobRunEntry> Function(String job) entriesOf,
  required DateTime nowUtc,
  DateTime? notBeforeUtc,
  Map<String, Duration> graceOverride = const <String, Duration>{},
}) => <JobRow>[
  for (final JobSpec s in kJobTable)
    _row(s, entriesOf(s.job), nowUtc, notBeforeUtc, graceOverride[s.job]),
];

JobRow _row(
  JobSpec s,
  List<JobRunEntry> entries,
  DateTime nowUtc,
  DateTime? notBeforeUtc,
  Duration? grace,
) {
  JobRunEntry? last;
  for (final JobRunEntry e in entries) {
    if (notBeforeUtc != null && e.finishedAtUtc.isBefore(notBeforeUtc)) {
      continue;
    }
    if (last == null || !e.finishedAtUtc.isBefore(last.finishedAtUtc)) {
      last = e;
    }
  }
  final JobRunStatus? st = last?.status;
  final String? when = last == null
      ? null
      : operationsWhenText(last.finishedAtUtc, nowUtc);
  return JobRow(
    label: kJobWatchdogLabels[s.job] ?? s.job,
    scheduleText: operationsScheduleTextOf(s, grace: grace),
    lastRunText: switch (st) {
      null => OperationsJobTexts.neverRan,
      JobRunStatus.success || JobRunStatus.late => '$when 끝남',
      JobRunStatus.failed => '$when 실패',
      JobRunStatus.holiday => '$when — 휴장이라 본체를 돌리지 않았습니다',
    },
    statusCode: st?.wire ?? 'NONE',
    stateLabel: OperationsJobTexts.state(st),
    level: _level(st),
    detailLine: st == JobRunStatus.failed
        ? OperationsJobTexts.failedDetail
        : null,
  );
}

/// 🔴 다음 잡 한 줄(«오늘 18:30 국내 시세 수집») — 지금 뒤 가장 이른 예정 회차 · 달력 범위 밖 = null(모름).
String? operationsNextJobTextOf({
  required JobCalendars calendars,
  required DateTime nowUtc,
}) {
  JobOccurrence? best;
  for (final JobSpec s in kJobTable) {
    final JobOccurrence o;
    try {
      o = nextOccurrence(s, calendars, nowUtc);
    } on StateError {
      continue;
    } on RangeError {
      continue;
    }
    if (best == null || o.scheduledUtc.isBefore(best.scheduledUtc)) best = o;
  }
  if (best == null) return null;
  final String label = kJobWatchdogLabels[best.spec.job] ?? best.spec.job;
  return '${operationsWhenText(best.scheduledUtc, nowUtc)} $label';
}
