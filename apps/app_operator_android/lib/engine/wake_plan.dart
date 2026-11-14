// 깨어남 → 회차 판정 조립(E11p3a · 설계 e11p-map Q5 · 정본 = R43 B5 `wakeDecisions` · R73 K5 `ranOccurrences`).
//
// 🔴 판정은 엔진이 한다(`wakeDecisions`). 여기는 입력만 모은다:
//    · 볼 구간 = 지금 − 14일 ~ 지금(가장 긴 연휴 + 여유 · 판정만 하니 값싸다).
//    · 이미 돈 회차 = `job_run` 의 «돈» 세션(SUCCESS · LATE · HOLIDAY) — **기준점을 따로 저장하지 않는다**(job_run 이 정본).
// 🔴 runNow 만 돌린다(예정 차례). missed = 늦은 끝을 지났다 → 돌리지 않는다(재개 X2 몫).
//    실패한 회차는 «돈» 이 아니므로 늦은 끝 안이면 다음 깨어남에 다시 돈다(엔진 규칙 그대로).

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;
import 'package:trading_runtime/trading_runtime.dart'
    show
        JobCalendars,
        JobOccurrence,
        JobSpec,
        WakeAction,
        WakeDecision,
        kJobTable,
        kstDateOf,
        ranOccurrences,
        wakeDecisions;

/// 볼 구간(설계 Q5).
const Duration kWakeLookback = Duration(days: 14);

/// [job] 의 «돈» 세션일 — [from] 이상(`SqliteJobRunLog.doneSessions`).
typedef DoneSessions = List<TradeDate> Function(String job, TradeDate from);

/// 깨어남 한 번의 계획.
class WakePlan {
  /// 만든다.
  const WakePlan({
    required this.runNow,
    required this.missed,
    required this.done,
  });

  /// 지금 돌릴 회차(예정 차례).
  final List<JobOccurrence> runNow;

  /// 늦은 끝을 지난 회차(돌리지 않는다).
  final List<JobOccurrence> missed;

  /// 이미 돈 회차 수.
  final int done;
}

/// 🔴 깨어났을 때 할 일 — 엔진 판정(`wakeDecisions`)을 셋으로 나눈다.
WakePlan planWake({
  required DateTime nowUtc,
  required JobCalendars cals,
  required DoneSessions doneSessions,
  List<JobSpec> specs = kJobTable,
  Duration lookback = kWakeLookback,
}) {
  final DateTime since = nowUtc.subtract(lookback);
  // 세션일은 발화 날보다 앞설 수 있다(US = 앞 날 · 월말 잡 = 월말) → 한 구간 더 앞에서부터 읽는다.
  final TradeDate from = kstDateOf(since.subtract(lookback));
  final Set<JobOccurrence> ran = ranOccurrences(
    cals: cals,
    doneSessionsByJob: <String, Iterable<TradeDate>>{
      for (final JobSpec s in specs) s.job: doneSessions(s.job, from),
    },
  );
  final List<JobOccurrence> runNow = <JobOccurrence>[];
  final List<JobOccurrence> missed = <JobOccurrence>[];
  int done = 0;
  for (final WakeDecision d in wakeDecisions(
    specs: specs,
    cals: cals,
    sinceUtc: since,
    nowUtc: nowUtc,
    ran: ran,
  )) {
    switch (d.action) {
      case WakeAction.runNow:
        runNow.add(d.occurrence);
      case WakeAction.missed:
        missed.add(d.occurrence);
      case WakeAction.done:
        done++;
    }
  }
  return WakePlan(runNow: runNow, missed: missed, done: done);
}
