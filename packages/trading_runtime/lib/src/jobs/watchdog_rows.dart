// 워치독 보드 행 재료(E11p3d-2 · 설계 13 §8 R109 · R45 C7 · 06 M1-12 · 앱 04 §7 `W-01`).
//
// 🔴 행 = 바깥 감시 체크와 같은 집합(`watchdogCheckSpecsFor` — 잡 표 순 · 월말 다음 세션 잡 제외) — 바깥 대조가 «체크 없음»으로
//    거짓 경고를 내지 않게.
// 🔴 판정 = 지금까지 온 **마지막 회차** 하나(예정 ≤ 지금 · 14일 안 · 모드 시작 뒤) × 그 세션일의 `job_run` 기록(E11b 3분법).
//    모드 시작 앞 회차는 판정하지 않는다(돌릴 일이 없었다 · R94 첫 회차 하한과 같은 축).
// 🔴 이름표 = 엔진 문구(잡 → 한국어 이름 · 표본 `m8/watchdog_*.json` 꼴) — 새 잡이 생기면 이 표에 없으면 시험이 막는다.

import 'package:core_engine/core_engine.dart'
    show JobRunEntry, JobRunStatus, WatchdogCheckSpec, watchdogCheckName;
import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode, TradeDate;

import 'job_schedule.dart';
import 'watchdog_board.dart' show WatchdogBoardInput;
import 'watchdog_judge.dart' show OccurrenceRecord, judgeOccurrence;
import 'watchdog_specs.dart' show watchdogCheckSpecsFor;

/// 🔴 잡 → 보드 이름표(엔진 문구 · R109).
const Map<String, String> kJobWatchdogLabels = <String, String>{
  'daily_reconcile': '대사 배치',
  'us_data': '미국 시세 수집',
  'seasonal_a': '계절 판정',
  'monthly_rebalance': '월말 계획',
  'kr_order': '주문 배치',
  'kr_order_close': '체결 확인 배치',
  'daily_data': '국내 시세 수집',
  'daily_signal': '국면 계산',
  'equity_snapshot': '평가 스냅숏',
};

/// 보드가 보는 과거 폭(깨어남 판정과 같은 14일).
const Duration kWatchdogBoardLookback = Duration(days: 14);

/// 🔴 [sessionDay] 회차의 로컬 기록 — 그 세션일의 `job_run` 줄에서(없으면 null).
OccurrenceRecord? occurrenceRecordOf(
  Iterable<JobRunEntry> entries,
  TradeDate sessionDay,
) {
  DateTime? ok, fail;
  bool holiday = false;
  for (final JobRunEntry e in entries) {
    if (e.sessionDay != sessionDay) continue;
    final DateTime t = e.finishedAtUtc.toUtc();
    final bool success = e.status.succeeded || e.status == JobRunStatus.holiday;
    if (success) {
      if (ok == null || t.isAfter(ok)) {
        ok = t;
        holiday = e.status == JobRunStatus.holiday;
      }
    } else if (fail == null || t.isAfter(fail)) {
      fail = t;
    }
  }
  if (ok == null && fail == null) return null;
  return OccurrenceRecord(
    succeededUtc: ok,
    failedUtc: fail,
    holidayPing: holiday,
  );
}

/// 🔴 보드 행 재료 — [run] × [op] 의 감시 체크마다 마지막 회차 판정 하나.
///
/// [entriesOf] = 잡 → 그 잡의 `job_run` 줄 · [notBeforeUtc] = 모드 시작(앞 회차 = 판정 안 함 · 행에서 뺀다) ·
/// [graceOverride] = 잡 → 유예(config).
List<WatchdogBoardInput> watchdogBoardInputsFor({
  required RunMode run,
  required OperatingMode op,
  required JobCalendars calendars,
  required DateTime nowUtc,
  required List<JobRunEntry> Function(String job) entriesOf,
  DateTime? notBeforeUtc,
  Map<String, Duration> graceOverride = const <String, Duration>{},
}) {
  final Set<String> slugs = <String>{
    for (final WatchdogCheckSpec c in watchdogCheckSpecsFor(
      run,
      op,
      graceOverride: graceOverride,
    ))
      c.slug,
  };
  final DateTime from = nowUtc.subtract(kWatchdogBoardLookback);
  final List<WatchdogBoardInput> out = <WatchdogBoardInput>[];
  for (final JobSpec s in kJobTable) {
    final String slug = watchdogCheckName(run, op, s.job);
    if (!slugs.contains(slug)) continue;
    final List<JobOccurrence> due = <JobOccurrence>[
      for (final JobOccurrence o in occurrencesBetween(
        s,
        calendars,
        from,
        nowUtc,
      ))
        if (!o.scheduledUtc.isAfter(nowUtc) &&
            (notBeforeUtc == null || !o.scheduledUtc.isBefore(notBeforeUtc)))
          o,
    ];
    if (due.isEmpty) continue;
    final JobOccurrence last = due.last;
    final Duration grace = graceOverride[s.job] ?? s.grace;
    final OccurrenceRecord? record = occurrenceRecordOf(
      entriesOf(s.job),
      last.sessionDay,
    );
    out.add(
      WatchdogBoardInput(
        label: kJobWatchdogLabels[s.job] ?? s.job,
        slug: slug,
        verdict: judgeOccurrence(
          occurrence: last,
          record: record,
          nowUtc: nowUtc,
          grace: grace,
        ),
        grace: grace,
        record: record,
      ),
    );
  }
  return out;
}
