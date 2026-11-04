// 잡 표 · 회차 · 다음 발화 · 놓친 발화(설계 13 §8 R43 B2~B5 · 00_SPEC §6-4 · 04 §4-2 · 06 M1-11 의 계산 몫).
//
// 🔴 KR 잡은 **평일마다** 발화한다 — 바깥 워치독(healthchecks)은 평일 스케줄을 보므로, 평일 공휴일에도 «휴장» 성공 핑을
//    보내야 결측으로 울지 않는다(M1-12). 세션인지는 발화 때 `runJob` 이 달력으로 가린다.
// 🔴 `us_data` = XNYS 세션 d 를 (d+1) 07:30 KST 에 받는다(D10) — 미국 마감(EDT 05:00 · EST 06:00 KST) 뒤라 DST 에 깨지지 않는다.
//    그래서 KST 화~토에 발화하고, 세션일 = KST 날 − 1.
// 🔴 월말 잡은 그 달 마지막 KR 세션에만 발화한다.
// 🔵 유예(데드라인 예산)는 잠정값이다 — 폰 실측 뒤 config(02 §4 `operations.watchdog_grace_minutes`)가 덮는다(D11).

import 'package:core_engine/core_engine.dart' show ExchangeCalendar;
import 'package:domain_contracts/domain_contracts.dart';

import 'job_contract.dart';

/// 발화 주기.
enum JobCadence {
  /// KST 평일(월~금) — 세션 판정은 발화 때.
  krWeekday,

  /// 그 달 마지막 KR 세션의 **다음 KR 세션**(R48 P1 — 월말 판정 = 그날 미국 종가 포함 · 세션일 = 그 월말).
  krAfterMonthEnd,

  /// KST 화~토 — 세션일 = 앞 날(XNYS 세션 d).
  usNextKstDay,
}

/// 잡 한 줄(R43 B2 · B3).
class JobSpec {
  /// 잡을 만든다.
  const JobSpec({
    required this.job,
    required this.cadence,
    required this.kstTime,
    required this.grace,
    this.lateUntilKst,
  });

  /// 잡 이름.
  final String job;

  /// 주기.
  final JobCadence cadence;

  /// 발화 시각(KST 하루 중).
  final Duration kstTime;

  /// 유예(데드라인 예산 · 잠정).
  final Duration grace;

  /// 늦게라도 돌릴 수 있는 끝(발화 KST 날의 시각) — null = 다음 회차 앞까지.
  final Duration? lateUntilKst;
}

/// 잡 표(R43 B2 · B3 · 00_SPEC §6-4 v2.38) — 🟡 유예 = 잠정(04 §5-2 서버 전제값).
const List<JobSpec> kJobTable = <JobSpec>[
  JobSpec(
    job: 'daily_reconcile',
    cadence: JobCadence.krWeekday,
    kstTime: Duration(hours: 7),
    grace: Duration(hours: 2),
    // 09:05 뒤면 오전 배치의 배치 직후 대사가 덮는다.
    lateUntilKst: Duration(hours: 9, minutes: 5),
  ),
  JobSpec(
    job: 'kr_order',
    cadence: JobCadence.krWeekday,
    kstTime: Duration(hours: 9, minutes: 10),
    grace: Duration(minutes: 60),
    lateUntilKst: Duration(hours: 15),
  ),
  JobSpec(
    job: 'kr_order_close',
    cadence: JobCadence.krWeekday,
    kstTime: Duration(hours: 15, minutes: 45),
    grace: Duration(minutes: 60),
    lateUntilKst: Duration(hours: 23, minutes: 59),
  ),
  JobSpec(
    job: 'daily_data',
    cadence: JobCadence.krWeekday,
    kstTime: Duration(hours: 18, minutes: 30),
    grace: Duration(hours: 2),
  ),
  JobSpec(
    job: 'daily_signal',
    cadence: JobCadence.krWeekday,
    kstTime: Duration(hours: 20),
    grace: Duration(hours: 1),
  ),
  JobSpec(
    job: 'equity_snapshot',
    cadence: JobCadence.krWeekday,
    kstTime: Duration(hours: 20, minutes: 30),
    grace: Duration(hours: 1),
    // 🔴 소급 불가 — 그날 안에만.
    lateUntilKst: Duration(hours: 23, minutes: 59),
  ),
  // 🆕 E11f3(R49 Q1 · 발주자 결정 2026-11-04) — 계절 A 판정. 매 KR 평일 08:00 · 판정 날(그 달 마지막 3 KR 세션의
  //    첫날)에만 움직인다 · 늦은 끝 09:05(`kr_order` 시작 앞) · 🔴 SPEC 잡 표 추가 = v2.39 창.
  JobSpec(
    job: 'seasonal_a',
    cadence: JobCadence.krWeekday,
    kstTime: Duration(hours: 8),
    grace: Duration(hours: 1),
    lateUntilKst: Duration(hours: 9, minutes: 5),
  ),
  // 🆕 E11f2(R48 P1 · 발주자 결정 2026-11-04) — 월말 다음 KR 세션 08:00 · 그날 미국 종가까지 본 판정(골든과 같다) ·
  //    유예 1시간(`kr_order` 09:10 앞) · 늦은 끝 15:00(`kr_order` 끝) — 넘기면 워치독 실패 · 사람.
  //    🔴 SPEC 잡 표 문언(«월 마지막 거래일»)은 v2.39 창.
  JobSpec(
    job: 'monthly_rebalance',
    cadence: JobCadence.krAfterMonthEnd,
    kstTime: Duration(hours: 8),
    grace: Duration(hours: 1),
    lateUntilKst: Duration(hours: 15),
  ),
  JobSpec(
    job: 'us_data',
    cadence: JobCadence.usNextKstDay,
    kstTime: Duration(hours: 7, minutes: 30),
    grace: Duration(hours: 2),
  ),
];

/// [job] 의 잡 줄 — 없으면 ArgumentError(지어내지 않는다).
JobSpec jobSpecOf(String job) {
  for (final JobSpec s in kJobTable) {
    if (s.job == job) return s;
  }
  throw ArgumentError.value(job, 'job', '잡 표에 없다');
}

/// 잡이 쓰는 달력 둘.
class JobCalendars {
  /// 달력을 묶는다.
  const JobCalendars({required this.kr, required this.us});

  /// KR(XKRX).
  final ExchangeCalendar kr;

  /// US(XNYS).
  final ExchangeCalendar us;

  /// [spec] 의 시장 달력.
  ExchangeCalendar of(JobSpec spec) =>
      spec.cadence == JobCadence.usNextKstDay ? us : kr;
}

/// 회차 하나 — (잡 · 발화 KST 날).
class JobOccurrence {
  /// 회차를 만든다.
  const JobOccurrence({
    required this.spec,
    required this.fireDay,
    required this.sessionDay,
    required this.scheduledUtc,
    required this.lateUntilUtc,
    required this.holiday,
  });

  /// 잡 줄.
  final JobSpec spec;

  /// 발화 KST 날.
  final TradeDate fireDay;

  /// 다루는 세션일(US = 앞 날).
  final TradeDate sessionDay;

  /// 예정 시각.
  final DateTime scheduledUtc;

  /// 늦게라도 돌릴 수 있는 끝(그 시각 앞까지).
  final DateTime lateUntilUtc;

  /// 휴장 회차인가(«휴장» 성공 핑을 기대한다).
  final bool holiday;

  /// 유예 끝.
  DateTime get deadlineUtc => scheduledUtc.add(spec.grace);

  @override
  bool operator ==(Object other) =>
      other is JobOccurrence &&
      other.spec.job == spec.job &&
      other.fireDay == fireDay;

  @override
  int get hashCode => Object.hash(spec.job, fireDay);

  @override
  String toString() => '${spec.job}@${fireDay.yyyyMmDd}';
}

TradeDate _addDays(TradeDate d, int n) {
  final DateTime t = DateTime.parse('${d.yyyyMmDd}T00:00:00Z')
      .add(Duration(days: n));
  String two(int v) => v.toString().padLeft(2, '0');
  return TradeDate('${t.year}-${two(t.month)}-${two(t.day)}');
}

DateTime _kstAt(TradeDate day, Duration at) =>
    DateTime.parse('${day.yyyyMmDd}T00:00:00Z')
        .add(at)
        .subtract(const Duration(hours: 9));

int _weekday(TradeDate d) => DateTime.parse('${d.yyyyMmDd}T00:00:00Z').weekday;

/// [fireDay] 가 [spec] 의 발화 날인가.
bool _fires(JobSpec spec, TradeDate fireDay, JobCalendars cals) =>
    switch (spec.cadence) {
      JobCadence.krWeekday => _weekday(fireDay) <= DateTime.friday,
      JobCadence.krAfterMonthEnd =>
        cals.kr.isSession(fireDay) &&
            cals.kr.isLastSessionOfMonth(cals.kr.nthSessionBefore(fireDay, 1)),
      JobCadence.usNextKstDay =>
        _weekday(fireDay) >= DateTime.tuesday &&
            _weekday(fireDay) <= DateTime.saturday,
    };

JobOccurrence _build(JobSpec spec, TradeDate fireDay, JobCalendars cals) {
  final TradeDate session = switch (spec.cadence) {
    JobCadence.usNextKstDay => _addDays(fireDay, -1),
    JobCadence.krAfterMonthEnd => cals.kr.nthSessionBefore(fireDay, 1),
    JobCadence.krWeekday => fireDay,
  };
  final DateTime scheduled = _kstAt(fireDay, spec.kstTime);
  final Duration? late = spec.lateUntilKst;
  return JobOccurrence(
    spec: spec,
    fireDay: fireDay,
    sessionDay: session,
    scheduledUtc: scheduled,
    lateUntilUtc: late != null
        ? _kstAt(fireDay, late)
        : _nextFireAfter(spec, cals, scheduled),
    holiday: !cals.of(spec).isSession(session),
  );
}

DateTime _nextFireAfter(JobSpec spec, JobCalendars cals, DateTime afterUtc) {
  TradeDate d = kstDateOf(afterUtc);
  for (int i = 0; i < 400; i++) {
    if (_fires(spec, d, cals) && _kstAt(d, spec.kstTime).isAfter(afterUtc)) {
      return _kstAt(d, spec.kstTime);
    }
    d = _addDays(d, 1);
  }
  throw StateError('${spec.job}: 400일 안에 발화 날이 없다');
}

/// [fireDay] 의 회차 — 발화 날이 아니면 ArgumentError · 달력 범위 밖 = StateError.
JobOccurrence occurrenceOn(JobSpec spec, TradeDate fireDay, JobCalendars cals) {
  if (!_fires(spec, fireDay, cals)) {
    throw ArgumentError.value(fireDay, 'fireDay', '${spec.job} 의 발화 날이 아니다');
  }
  return _build(spec, fireDay, cals);
}

/// [afterUtc] 뒤(같은 시각 제외) 첫 회차(R43 B4) — 알람 계획의 입력.
JobOccurrence nextOccurrence(
  JobSpec spec,
  JobCalendars cals,
  DateTime afterUtc,
) {
  final DateTime at = _nextFireAfter(spec, cals, afterUtc);
  return _build(spec, kstDateOf(at), cals);
}

/// ([fromUtc], [toUtc]] 안의 회차(예정 시각 순).
List<JobOccurrence> occurrencesBetween(
  JobSpec spec,
  JobCalendars cals,
  DateTime fromUtc,
  DateTime toUtc,
) {
  final List<JobOccurrence> out = <JobOccurrence>[];
  DateTime cursor = fromUtc;
  while (true) {
    final JobOccurrence o = nextOccurrence(spec, cals, cursor);
    if (o.scheduledUtc.isAfter(toUtc)) return out;
    out.add(o);
    cursor = o.scheduledUtc;
  }
}

/// 깨어났을 때 회차 하나를 어떻게 하나(R43 B5).
enum WakeAction {
  /// 이미 돌았다.
  done,

  /// 늦은 끝 안 — 지금 돌린다.
  runNow,

  /// 늦은 끝을 지났다 — 돌리지 않는다(재개 X2 가 다룬다).
  missed,
}

/// 회차 판정.
class WakeDecision {
  /// 판정을 만든다.
  const WakeDecision(this.occurrence, this.action);

  /// 회차.
  final JobOccurrence occurrence;

  /// 할 일.
  final WakeAction action;
}

/// 깨어났을 때(부팅 · 알람 · Doze 뒤) — [sinceUtc] 뒤 [nowUtc] 까지 예정된 회차마다 할 일(R43 B5).
///
/// [ran] = 이미 돈 회차(잡 · 발화 날). 판정만 한다 — 돌리는 것은 부르는 쪽.
List<WakeDecision> wakeDecisions({
  required Iterable<JobSpec> specs,
  required JobCalendars cals,
  required DateTime sinceUtc,
  required DateTime nowUtc,
  required Set<JobOccurrence> ran,
}) {
  final List<WakeDecision> out = <WakeDecision>[];
  for (final JobSpec s in specs) {
    for (final JobOccurrence o in occurrencesBetween(
      s,
      cals,
      sinceUtc,
      nowUtc,
    )) {
      final WakeAction a = ran.contains(o)
          ? WakeAction.done
          : nowUtc.isBefore(o.lateUntilUtc)
          ? WakeAction.runNow
          : WakeAction.missed;
      out.add(WakeDecision(o, a));
    }
  }
  out.sort((WakeDecision a, WakeDecision b) {
    final int c = a.occurrence.scheduledUtc.compareTo(
      b.occurrence.scheduledUtc,
    );
    return c != 0 ? c : a.occurrence.spec.job.compareTo(b.occurrence.spec.job);
  });
  return out;
}
