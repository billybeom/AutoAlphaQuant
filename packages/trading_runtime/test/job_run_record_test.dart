// E14c1 — `runJob` 의 `job_run` 기록 · 유예 끝 · 세션일 → 발화 날 · `ran` 원천(설계 13 §8 R73 K2~K5).
//
// 🔵 잡는 것: ① 나가는 길 다섯(성공 · 휴장 · 본체 예외 · 알림 실패 · 달력 밖)마다 1행 · 칸 값 · 마지막 핑 앞
//    ② SUCCESS · LATE 경계(같은 시각 = SUCCESS) · 유예 끝 없음 ③ 🔴 기록 실패 = fail 핑 · FAILED · 보고 남김 ·
//    실패 회차의 기록 실패 = 원래 fail 핑 그대로 ④ 유예 끝 · 발화 날 3갈래 · `ran` → `wakeDecisions` · 오류 2
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final ExchangeCalendar _us = frozenExchangeCalendar(Market.us);
final JobCalendars _cals = JobCalendars(kr: _kr, us: _us);

DateTime _kst(String ymd, int h, int m) =>
    DateTime.parse('${ymd}T00:00:00Z')
        .add(Duration(hours: h, minutes: m))
        .subtract(const Duration(hours: 9));

const String _check = 'live-auto-daily_data';

class _Beat implements JobHeartbeat {
  _Beat(this.log);

  final _Log log;
  final List<(PingStatus, String?)> pings = <(PingStatus, String?)>[];

  @override
  Future<void> ping(
    String check,
    PingStatus status, {
    String? note,
    String? rid,
  }) async {
    pings.add((status, note));
    log.order.add('ping:${status.wire}');
  }
}

class _Log implements JobRunLog {
  final List<JobRunEntry> entries = <JobRunEntry>[];
  final List<String> order = <String>[];
  Exception? throwing;

  @override
  Future<void> record(JobRunEntry entry) async {
    order.add('record:${entry.status.wire}');
    final Exception? t = throwing;
    if (t != null) throw t;
    entries.add(entry);
  }
}

class _Alerts implements AlertSink {
  bool failing = false;

  @override
  Future<void> emit(String check, Set<String> codes) async {
    if (failing) throw StateError('발송 실패');
  }
}

class _Rig {
  final _Log log = _Log();
  late final _Beat beat = _Beat(log);
  final _Alerts alerts = _Alerts();
  DateTime end = _kst('2026-11-04', 18, 40);

  Future<JobRun<int>> run({
    DateTime? now,
    ExchangeCalendar? calendar,
    DateTime? deadline,
    Future<JobBody<int>> Function(TradeDate d)? body,
  }) => runJob<int>(
    check: _check,
    heartbeat: beat,
    alerts: alerts,
    calendar: calendar ?? _kr,
    nowUtc: now ?? _kst('2026-11-04', 18, 30),
    body: body ?? (TradeDate d) async => const JobBody<int>(7),
    runLog: log,
    clockUtc: () => end,
    deadlineUtc: deadline,
  );
}

void main() {
  group('기록(R73 K2)', () {
    test('성공 = 1행(rid · 체크 · 세션일 · 시작 · 끝 · SUCCESS) · 마지막 핑 앞', () async {
      final _Rig rig = _Rig();
      final JobRun<int> r = await rig.run();
      final JobRunEntry e = rig.log.entries.single;
      expect(e.rid, r.rid);
      expect(e.checkName, _check);
      expect(e.sessionDay, const TradeDate('2026-11-04'));
      expect(e.startedAtUtc, _kst('2026-11-04', 18, 30));
      expect(e.finishedAtUtc, _kst('2026-11-04', 18, 40));
      expect(e.status, JobRunStatus.success);
      expect(rig.log.order, <String>[
        'ping:start',
        'record:SUCCESS',
        'ping:success',
      ]);
      expect(r.runLogFailed, isFalse);
    });

    test('유예 끝 — 넘기면 LATE · 같은 시각 = SUCCESS · 없음 = SUCCESS', () async {
      final _Rig a = _Rig();
      await a.run(deadline: _kst('2026-11-04', 18, 39));
      expect(a.log.entries.single.status, JobRunStatus.late);
      final _Rig b = _Rig();
      await b.run(deadline: _kst('2026-11-04', 18, 40));
      expect(b.log.entries.single.status, JobRunStatus.success);
      final _Rig c = _Rig();
      await c.run();
      expect(c.log.entries.single.status, JobRunStatus.success);
      expect(
        successStatusOf(
          finishedAtUtc: _kst('2026-11-04', 18, 40),
          deadlineUtc: _kst('2026-11-04', 18, 39),
        ),
        JobRunStatus.late,
      );
    });

    test('휴장 = HOLIDAY 1행 · 그다음 «휴장» 성공 핑', () async {
      final _Rig rig = _Rig();
      final JobRun<int> r = await rig.run(now: _kst('2026-11-07', 18, 30));
      expect(r.status, JobStatus.holiday);
      expect(rig.log.entries.single.status, JobRunStatus.holiday);
      expect(rig.log.entries.single.sessionDay, const TradeDate('2026-11-07'));
      expect(rig.log.order, <String>['record:HOLIDAY', 'ping:success']);
    });

    test('본체 예외 · 알림 실패 · 달력 밖 = FAILED 1행 · 그다음 fail 핑', () async {
      final _Rig body = _Rig();
      await body.run(body: (TradeDate d) async => throw StateError('본체'));
      expect(body.log.order, <String>[
        'ping:start',
        'record:FAILED',
        'ping:fail',
      ]);
      final _Rig alert = _Rig();
      alert.alerts.failing = true;
      await alert.run(
        body: (TradeDate d) async =>
            const JobBody<int>(1, alerts: <String>{'WATCHDOG_LATE'}),
      );
      expect(alert.log.order, <String>[
        'ping:start',
        'record:FAILED',
        'ping:fail',
      ]);
      final _Rig out = _Rig();
      await out.run(now: DateTime.utc(2099, 1, 5, 9));
      expect(out.log.order, <String>[
        'ping:start',
        'record:FAILED',
        'ping:fail',
      ]);
      expect(out.log.entries.single.sessionDay, const TradeDate('2099-01-05'));
    });
  });

  group('🆕 E14d2b 잡 앞 가드(R77 S2)', () {
    test('세션 = start 핑 뒤 · 본체 앞에 그 세션일로 부른다 · 휴장 = 안 부른다', () async {
      final _Rig rig = _Rig();
      final List<String> order = <String>[];
      final JobRun<int> r = await runJob<int>(
        check: _check,
        heartbeat: rig.beat,
        alerts: rig.alerts,
        calendar: _kr,
        nowUtc: _kst('2026-11-04', 18, 30),
        body: (TradeDate d) async {
          order.add('body');
          return const JobBody<int>(1);
        },
        runLog: rig.log,
        clockUtc: () => rig.end,
        preGuard: (TradeDate d) async => order.add('guard:${d.yyyyMmDd}'),
      );
      expect(r.status, JobStatus.success);
      expect(order, <String>['guard:2026-11-04', 'body']);
      expect(rig.log.order.first, 'ping:start');
      final List<String> holiday = <String>[];
      await runJob<int>(
        check: _check,
        heartbeat: _Rig().beat,
        alerts: rig.alerts,
        calendar: _kr,
        nowUtc: _kst('2026-11-07', 18, 30),
        body: (TradeDate d) async => const JobBody<int>(1),
        runLog: _Log(),
        clockUtc: () => rig.end,
        preGuard: (TradeDate d) async => holiday.add('guard'),
      );
      expect(holiday, isEmpty);
    });

    test('🔴 가드 실패 = FAILED · 본체 0 · 기록 FAILED · fail 핑 «재개 가드 실패»', () async {
      final _Rig rig = _Rig();
      bool ran = false;
      final JobRun<int> r = await runJob<int>(
        check: _check,
        heartbeat: rig.beat,
        alerts: rig.alerts,
        calendar: _kr,
        nowUtc: _kst('2026-11-04', 18, 30),
        body: (TradeDate d) async {
          ran = true;
          return const JobBody<int>(1);
        },
        runLog: rig.log,
        clockUtc: () => rig.end,
        preGuard: (TradeDate d) async => throw StateError('재개 실패'),
      );
      expect((r.status, ran), (JobStatus.failed, false));
      expect(r.error, isA<StateError>());
      expect(rig.log.order, <String>[
        'ping:start',
        'record:FAILED',
        'ping:fail',
      ]);
      expect(rig.beat.pings.last.$2, startsWith('재개 가드 실패 — '));
    });
  });

  group('🔴 기록 실패(R73 K3)', () {
    test('성공 회차 = fail 핑 «실행 기록 실패» · FAILED · 보고 · 알림 남김', () async {
      final _Rig rig = _Rig();
      rig.log.throwing = Exception('디스크');
      final JobRun<int> r = await rig.run(
        body: (TradeDate d) async =>
            const JobBody<int>(9, alerts: <String>{'WATCHDOG_LATE'}),
      );
      expect(r.status, JobStatus.failed);
      expect(r.report, 9);
      expect(r.alerts, <String>{'WATCHDOG_LATE'});
      expect(r.runLogFailed, isTrue);
      expect(r.error, isA<Exception>());
      expect(rig.beat.pings.last.$1, PingStatus.fail);
      expect(rig.beat.pings.last.$2, startsWith('실행 기록 실패 — '));
      expect(rig.log.entries, isEmpty);
    });

    test('휴장 회차 = fail 핑 · FAILED', () async {
      final _Rig rig = _Rig();
      rig.log.throwing = Exception('디스크');
      final JobRun<int> r = await rig.run(now: _kst('2026-11-07', 18, 30));
      expect(r.status, JobStatus.failed);
      expect(r.runLogFailed, isTrue);
      expect(rig.beat.pings.single.$1, PingStatus.fail);
      expect(rig.beat.pings.single.$2, startsWith('실행 기록 실패 — '));
    });

    test('실패 회차의 기록 실패 = 원래 fail 핑 그대로 · 표시만', () async {
      final _Rig rig = _Rig();
      rig.log.throwing = Exception('디스크');
      final JobRun<int> r = await rig.run(
        body: (TradeDate d) async => throw StateError('본체'),
      );
      expect(r.status, JobStatus.failed);
      expect(r.error, isA<StateError>());
      expect(r.runLogFailed, isTrue);
      expect(rig.beat.pings.last.$2, contains('본체'));
    });
  });

  group('유예 끝 · 발화 날 · ran(R73 K4 · K5)', () {
    test('유예 끝 = 예정 + 유예(잠정값)', () {
      expect(
        jobDeadlineUtc(jobSpecOf('kr_order'), const TradeDate('2026-11-04')),
        _kst('2026-11-04', 10, 10),
      );
      expect(
        jobDeadlineUtc(
          jobSpecOf('equity_snapshot'),
          const TradeDate('2026-11-04'),
        ),
        _kst('2026-11-04', 21, 30),
      );
    });

    test('세션일 → 발화 날 — 평일 = 같은 날 · 월말 잡 = 다음 KR 세션 · us_data = +1일', () {
      expect(
        fireDayOfSession(
          jobSpecOf('kr_order'),
          const TradeDate('2026-11-04'),
          _cals,
        ),
        const TradeDate('2026-11-04'),
      );
      expect(
        fireDayOfSession(
          jobSpecOf('monthly_rebalance'),
          const TradeDate('2026-10-30'),
          _cals,
        ),
        const TradeDate('2026-11-02'),
      );
      expect(
        fireDayOfSession(
          jobSpecOf('us_data'),
          const TradeDate('2026-11-06'),
          _cals,
        ),
        const TradeDate('2026-11-07'),
      );
    });

    test('ran → wakeDecisions = 돈 회차는 done · 나머지는 판정 그대로', () {
      final Set<JobOccurrence> ran = ranOccurrences(
        cals: _cals,
        doneSessionsByJob: <String, Iterable<TradeDate>>{
          'kr_order': <TradeDate>[const TradeDate('2026-11-04')],
          'monthly_rebalance': <TradeDate>[const TradeDate('2026-10-30')],
          'us_data': <TradeDate>[const TradeDate('2026-11-06')],
        },
      );
      expect(ran, <JobOccurrence>{
        occurrenceOn(
          jobSpecOf('kr_order'),
          const TradeDate('2026-11-04'),
          _cals,
        ),
        occurrenceOn(
          jobSpecOf('monthly_rebalance'),
          const TradeDate('2026-11-02'),
          _cals,
        ),
        occurrenceOn(
          jobSpecOf('us_data'),
          const TradeDate('2026-11-07'),
          _cals,
        ),
      });
      final List<WakeDecision> w = wakeDecisions(
        specs: <JobSpec>[jobSpecOf('kr_order')],
        cals: _cals,
        sinceUtc: _kst('2026-11-03', 12, 0),
        nowUtc: _kst('2026-11-05', 9, 30),
        ran: ran,
      );
      expect(
        w.map((WakeDecision d) => (d.occurrence.fireDay, d.action)).toList(),
        <(TradeDate, WakeAction)>[
          (const TradeDate('2026-11-04'), WakeAction.done),
          (const TradeDate('2026-11-05'), WakeAction.runNow),
        ],
      );
    });

    test('잡 표에 없는 잡 · 발화 날이 아닌 세션 = 오류(지어내지 않는다)', () {
      expect(
        () => ranOccurrences(
          cals: _cals,
          doneSessionsByJob: <String, Iterable<TradeDate>>{
            'nope': <TradeDate>[const TradeDate('2026-11-04')],
          },
        ),
        throwsArgumentError,
      );
      expect(
        () => ranOccurrences(
          cals: _cals,
          doneSessionsByJob: <String, Iterable<TradeDate>>{
            'monthly_rebalance': <TradeDate>[const TradeDate('2026-11-04')],
          },
        ),
        throwsArgumentError,
      );
    });
  });
}
