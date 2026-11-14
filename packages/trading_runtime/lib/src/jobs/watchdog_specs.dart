// 바깥 감시 체크 스펙 — 잡 표(kJobTable) → healthchecks 생성 꼴(설계 13 §8 R105 AJ5 · 04 §5-2 2축 접두).
//
// 🔴 잡 표의 주기 · 시각 · 유예만 쓴다(새 숫자 0) · cron 은 KST(tz `Asia/Seoul`) · 평일 공휴일도 발화한다(«휴장» 성공 핑).
// 🔴 `monthly_rebalance`(월말 다음 세션)는 공휴일에 따라 움직여 cron 으로 쓸 수 없다 — 스펙에서 뺀다
//    (근본안 = 평일 08:00 «할 일 없음» 핑 = SPEC v2.45 후보) · `engine_alive` 도 뺀다(⬜ 주기 숫자 · 핑 코드 없음).

import 'package:core_engine/core_engine.dart'
    show WatchdogCheckSpec, watchdogCheckName, watchdogCheckPrefix;
import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode;

import 'job_schedule.dart' show JobCadence, JobSpec, kJobTable;

/// 감시 스펙에서 뺀 잡 → 까닭(R105 AJ5).
const Map<String, String> kWatchdogSpecExcluded = <String, String>{
  'monthly_rebalance': '월말 다음 KR 세션은 공휴일에 따라 움직여 cron 으로 쓸 수 없다 — 평일 08:00 «할 일 없음» 핑 안 = SPEC v2.45 후보',
};

/// 잡 줄의 cron(KST · 분 시 * * 요일) — 월말 다음 세션 = [ArgumentError].
String watchdogCronOf(JobSpec s) {
  final int h = s.kstTime.inHours;
  final int m = s.kstTime.inMinutes % 60;
  final String days = switch (s.cadence) {
    JobCadence.krWeekday => '1-5',
    JobCadence.usNextKstDay => '2-6',
    JobCadence.krAfterMonthEnd => throw ArgumentError.value(
      s.job,
      'job',
      kWatchdogSpecExcluded[s.job] ?? 'cron 으로 쓸 수 없는 주기',
    ),
  };
  return '$m $h * * $days';
}

/// [run] × [op] 축의 감시 체크 스펙(잡 표 순 · 뺀 잡 제외) — [graceOverride] = 잡 → 유예(02 §4 `operations.watchdog_grace_minutes`).
List<WatchdogCheckSpec> watchdogCheckSpecsFor(
  RunMode run,
  OperatingMode op, {
  Map<String, Duration> graceOverride = const <String, Duration>{},
}) => <WatchdogCheckSpec>[
  for (final JobSpec s in kJobTable)
    if (s.cadence != JobCadence.krAfterMonthEnd)
      WatchdogCheckSpec(
        slug: watchdogCheckName(run, op, s.job),
        grace: graceOverride[s.job] ?? s.grace,
        cron: watchdogCronOf(s),
        tags: watchdogCheckPrefix(run, op).split('-'),
      ),
];
