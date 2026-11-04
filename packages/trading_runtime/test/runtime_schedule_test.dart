// 잡 표 · 다음 발화 · 놓친 발화 · 3분법 · rid · FGS 문구(설계 13 §8 R43 B2~B9).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final ExchangeCalendar _us = frozenExchangeCalendar(Market.us);
final JobCalendars _cals = JobCalendars(kr: _kr, us: _us);

/// [ymd] 의 KST 시각(UTC 값).
DateTime _kst(String ymd, int h, int m) =>
    DateTime.parse('${ymd}T00:00:00Z').add(Duration(hours: h - 9, minutes: m));

JobSpec _s(String job) => jobSpecOf(job);

class _Beat implements JobHeartbeat {
  final List<(PingStatus, String?, String?)> pings =
      <(PingStatus, String?, String?)>[];

  @override
  Future<void> ping(
    String check,
    PingStatus status, {
    String? note,
    String? rid,
  }) async => pings.add((status, note, rid));
}

class _NoAlerts implements AlertSink {
  @override
  Future<void> emit(String check, Set<String> codes) async {}
}

void main() {
  group('잡 표(R43 B2 · B3 · 00_SPEC §6-4)', () {
    test('이름 · 시각 · 주기 · 늦은 끝', () {
      expect(
        kJobTable.map((JobSpec s) => (s.job, s.kstTime, s.cadence)),
        <(String, Duration, JobCadence)>[
          ('daily_reconcile', const Duration(hours: 7), JobCadence.krWeekday),
          (
            'kr_order',
            const Duration(hours: 9, minutes: 10),
            JobCadence.krWeekday,
          ),
          (
            'kr_order_close',
            const Duration(hours: 15, minutes: 45),
            JobCadence.krWeekday,
          ),
          (
            'daily_data',
            const Duration(hours: 18, minutes: 30),
            JobCadence.krWeekday,
          ),
          ('daily_signal', const Duration(hours: 20), JobCadence.krWeekday),
          (
            'equity_snapshot',
            const Duration(hours: 20, minutes: 30),
            JobCadence.krWeekday,
          ),
          ('seasonal_a', const Duration(hours: 8), JobCadence.krWeekday),
          (
            'monthly_rebalance',
            const Duration(hours: 8),
            JobCadence.krAfterMonthEnd,
          ),
          (
            'us_data',
            const Duration(hours: 7, minutes: 30),
            JobCadence.usNextKstDay,
          ),
        ],
      );
      expect(_s('kr_order').lateUntilKst, const Duration(hours: 15));
      expect(_s('kr_order').lateUntilKst, kKrOrderCutoffKst);
      expect(_s('daily_reconcile').lateUntilKst, kKrOrderEarliestKst);
      expect(
        _s('equity_snapshot').lateUntilKst,
        const Duration(hours: 23, minutes: 59),
      );
      expect(_s('daily_data').lateUntilKst, isNull);
      expect(_s('monthly_rebalance').lateUntilKst, const Duration(hours: 15));
      expect(
        _s('seasonal_a').lateUntilKst,
        const Duration(hours: 9, minutes: 5),
      );
      expect(_s('seasonal_a').lateUntilKst, kKrOrderEarliestKst);
      expect(
        kJobTable.map((JobSpec s) => (s.job, s.grace.inMinutes)),
        <(String, int)>[
          ('daily_reconcile', 120),
          ('kr_order', 60),
          ('kr_order_close', 60),
          ('daily_data', 120),
          ('daily_signal', 60),
          ('equity_snapshot', 60),
          ('seasonal_a', 60),
          ('monthly_rebalance', 60),
          ('us_data', 120),
        ],
      );
      expect(() => jobSpecOf('dart_ingest'), throwsArgumentError);
    });
  });

  group('다음 발화(R43 B4)', () {
    test('KR 평일 — 수 10:00 뒤 = 목 09:10 · 금 10:00 뒤 = 월 09:10 · 같은 시각은 다음', () {
      JobOccurrence o = nextOccurrence(
        _s('kr_order'),
        _cals,
        _kst('2026-11-04', 10, 0),
      );
      expect(
        (o.fireDay, o.scheduledUtc),
        (const TradeDate('2026-11-05'), _kst('2026-11-05', 9, 10)),
      );
      o = nextOccurrence(_s('kr_order'), _cals, _kst('2026-11-06', 10, 0));
      expect(o.fireDay, const TradeDate('2026-11-09'));
      o = nextOccurrence(_s('kr_order'), _cals, _kst('2026-11-05', 9, 10));
      expect(o.fireDay, const TradeDate('2026-11-06'));
      o = nextOccurrence(_s('kr_order'), _cals, _kst('2026-11-05', 9, 9));
      expect(o.fireDay, const TradeDate('2026-11-05'));
      expect(o.sessionDay, o.fireDay);
      expect(o.holiday, isFalse);
    });

    test('🔴 평일 공휴일도 발화한다(«휴장» 핑) — 2026-12-25(금)', () {
      expect(_kr.isSession(const TradeDate('2026-12-25')), isFalse);
      final JobOccurrence o = nextOccurrence(
        _s('daily_data'),
        _cals,
        _kst('2026-12-24', 19, 0),
      );
      expect(o.fireDay, const TradeDate('2026-12-25'));
      expect(o.holiday, isTrue);
      expect(
        occurrenceOn(
          _s('kr_order'),
          const TradeDate('2026-12-25'),
          _cals,
        ).holiday,
        isTrue,
      );
    });

    test(
      '🆕 월말 잡 = 마지막 KR 세션의 다음 KR 세션 08:00 · 세션일 = 그 월말 · 휴장 회차 없음(R48 P1)',
      () {
        final JobOccurrence o = nextOccurrence(
          _s('monthly_rebalance'),
          _cals,
          _kst('2026-11-04', 10, 0),
        );
        // 2026-11-30(월) = 11월 마지막 KR 세션 → 12-01(화) 08:00.
        expect(o.sessionDay.yyyyMmDd, '2026-11-30');
        expect(_kr.isLastSessionOfMonth(o.sessionDay), isTrue);
        expect(o.fireDay.yyyyMmDd, '2026-12-01');
        expect(o.scheduledUtc, _kst('2026-12-01', 8, 0));
        expect(o.lateUntilUtc, _kst('2026-12-01', 15, 0));
        expect(o.holiday, isFalse);
        final JobOccurrence next = nextOccurrence(
          _s('monthly_rebalance'),
          _cals,
          o.scheduledUtc,
        );
        // 12월 마지막 KR 세션(12-30 수) → 다음 KR 세션 = 2027-01-04(월 · 1-1 휴장 · 주말).
        expect(next.sessionDay.yyyyMmDd, '2026-12-30');
        expect(next.fireDay.yyyyMmDd, '2027-01-04');
        for (final String d in <String>[
          '2026-11-30',
          '2026-12-02',
          '2026-12-31',
        ]) {
          expect(
            () => occurrenceOn(_s('monthly_rebalance'), TradeDate(d), _cals),
            throwsArgumentError,
            reason: d,
          );
        }
      },
    );

    test('us_data = XNYS 세션 d → (d+1) 07:30 KST · 화~토 · 세션일 = 앞 날', () {
      JobOccurrence o = nextOccurrence(
        _s('us_data'),
        _cals,
        _kst('2026-11-06', 8, 0),
      );
      expect(
        (o.fireDay, o.sessionDay, o.holiday),
        (const TradeDate('2026-11-07'), const TradeDate('2026-11-06'), false),
      );
      o = nextOccurrence(_s('us_data'), _cals, _kst('2026-11-07', 8, 0));
      expect(
        (o.fireDay, o.sessionDay),
        (const TradeDate('2026-11-10'), const TradeDate('2026-11-09')),
      );
      // 추수감사절(목) — 금 KST 발화 · 휴장.
      o = occurrenceOn(_s('us_data'), const TradeDate('2026-11-27'), _cals);
      expect((o.sessionDay, o.holiday), (const TradeDate('2026-11-26'), true));
      expect(
        () => occurrenceOn(_s('us_data'), const TradeDate('2026-11-09'), _cals),
        throwsArgumentError,
      );
    });

    test('🔴 DST(미국 11-01 해제) 앞뒤로 같은 KST 시각 — 22:30 UTC 고정', () {
      final DateTime before = occurrenceOn(
        _s('us_data'),
        const TradeDate('2026-10-31'),
        _cals,
      ).scheduledUtc;
      final DateTime after = occurrenceOn(
        _s('us_data'),
        const TradeDate('2026-11-07'),
        _cals,
      ).scheduledUtc;
      expect(before, DateTime.utc(2026, 10, 30, 22, 30));
      expect(after, DateTime.utc(2026, 11, 6, 22, 30));
    });

    test('늦은 끝 — 지정 = 그날 그 시각 · 없음 = 다음 회차 · 범위 밖 = StateError', () {
      final JobOccurrence k = occurrenceOn(
        _s('kr_order'),
        const TradeDate('2026-11-04'),
        _cals,
      );
      expect(k.lateUntilUtc, _kst('2026-11-04', 15, 0));
      expect(k.deadlineUtc, _kst('2026-11-04', 10, 10));
      final JobOccurrence d = occurrenceOn(
        _s('daily_data'),
        const TradeDate('2026-11-06'),
        _cals,
      );
      expect(d.lateUntilUtc, _kst('2026-11-09', 18, 30));
      expect(
        () => nextOccurrence(_s('kr_order'), _cals, DateTime.utc(2099, 1, 5)),
        throwsStateError,
      );
    });

    test('구간 회차 — 한 주(월~일) KR 평일 5 · us_data 5', () {
      final DateTime from = _kst('2026-11-08', 23, 0);
      final DateTime to = _kst('2026-11-15', 23, 0);
      expect(occurrencesBetween(_s('kr_order'), _cals, from, to), hasLength(5));
      expect(
        occurrencesBetween(
          _s('us_data'),
          _cals,
          from,
          to,
        ).map((JobOccurrence o) => o.fireDay.yyyyMmDd),
        <String>[
          '2026-11-10',
          '2026-11-11',
          '2026-11-12',
          '2026-11-13',
          '2026-11-14',
        ],
      );
      // 구간 = (from, to] — 시작 시각의 회차는 빼고 끝 시각의 회차는 넣는다.
      expect(
        occurrencesBetween(
          _s('kr_order'),
          _cals,
          _kst('2026-11-09', 9, 10),
          _kst('2026-11-10', 9, 10),
        ).map((JobOccurrence o) => o.fireDay.yyyyMmDd),
        <String>['2026-11-10'],
      );
    });
  });

  group('놓친 발화(R43 B5)', () {
    test('수 06:00 → 16:30 깨어남 — 대사 돌았음 · us_data = 지금 · 주문 = 놓침(15:00 지남) · 마감 = 지금', () {
      final JobOccurrence recon = occurrenceOn(
        _s('daily_reconcile'),
        const TradeDate('2026-11-04'),
        _cals,
      );
      final List<WakeDecision> w = wakeDecisions(
        specs: kJobTable,
        cals: _cals,
        sinceUtc: _kst('2026-11-04', 6, 0),
        nowUtc: _kst('2026-11-04', 16, 30),
        ran: <JobOccurrence>{recon},
      );
      expect(
        w.map((WakeDecision d) => (d.occurrence.spec.job, d.action)),
        <(String, WakeAction)>[
          ('daily_reconcile', WakeAction.done),
          // 07:30 us_data — 늦은 끝 = 다음 회차(목 07:30) 앞이라 지금 돌린다.
          ('us_data', WakeAction.runNow),
          // 🆕 08:00 seasonal_a — 늦은 끝 09:05 지남(그날 판정은 놓침 · 워치독 실패로 보인다).
          ('seasonal_a', WakeAction.missed),
          ('kr_order', WakeAction.missed),
          ('kr_order_close', WakeAction.runNow),
        ],
      );
    });

    test('늦은 끝 경계 — 14:59 = 지금 돌림 · 15:00 = 놓침', () {
      for (final (int m, WakeAction a) in <(int, WakeAction)>[
        (59, WakeAction.runNow),
      ]) {
        final List<WakeDecision> w = wakeDecisions(
          specs: <JobSpec>[_s('kr_order')],
          cals: _cals,
          sinceUtc: _kst('2026-11-04', 6, 0),
          nowUtc: _kst('2026-11-04', 14, m),
          ran: const <JobOccurrence>{},
        );
        expect(w.single.action, a);
      }
      final List<WakeDecision> w = wakeDecisions(
        specs: <JobSpec>[_s('kr_order')],
        cals: _cals,
        sinceUtc: _kst('2026-11-04', 6, 0),
        nowUtc: _kst('2026-11-04', 15, 0),
        ran: const <JobOccurrence>{},
      );
      expect(w.single.action, WakeAction.missed);
    });

    test('같은 시각 회차는 잡 이름 순 · 회차 같음 = (잡 · 발화 날)', () {
      final JobOccurrence a = occurrenceOn(
        _s('kr_order'),
        const TradeDate('2026-11-04'),
        _cals,
      );
      final JobOccurrence b = nextOccurrence(
        _s('kr_order'),
        _cals,
        _kst('2026-11-04', 9, 0),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), 'kr_order@2026-11-04');
      final List<WakeDecision> w = wakeDecisions(
        specs: <JobSpec>[_s('us_data'), _s('daily_reconcile')],
        cals: _cals,
        sinceUtc: _kst('2026-11-03', 23, 0),
        nowUtc: _kst('2026-11-04', 8, 0),
        ran: const <JobOccurrence>{},
      );
      expect(w.map((WakeDecision d) => d.occurrence.spec.job), <String>[
        'daily_reconcile',
        'us_data',
      ]);
    });
  });

  group('3분법(R43 B6 · 04 §7 W-01)', () {
    final JobOccurrence o = occurrenceOn(
      _s('daily_reconcile'),
      const TradeDate('2026-11-04'),
      _cals,
    );
    final DateTime deadline = o.deadlineUtc; // 09:00 KST

    WatchdogVerdict j(
      OccurrenceRecord? r,
      DateTime now, {
      bool paused = false,
      Duration? grace,
    }) => judgeOccurrence(
      occurrence: o,
      record: r,
      nowUtc: now,
      paused: paused,
      grace: grace,
    );

    test('유예 전 = 아직(ok) · 유예 지나 성공 없음 = 실패(blocked)', () {
      expect(j(null, deadline).state, WatchdogState.pending);
      expect(
        j(null, deadline.add(const Duration(seconds: 1))).state,
        WatchdogState.failed,
      );
      expect(WatchdogState.pending.level, UiLevel.ok);
      expect(WatchdogState.failed.level, UiLevel.blocked);
    });

    test('유예 안 성공 = 성공 · 넘겨 성공 = 지연(watch · 넘긴 만큼) — 🔴 지연을 실패로 칠하지 않는다', () {
      expect(
        j(OccurrenceRecord(succeededUtc: deadline), deadline).state,
        WatchdogState.success,
      );
      final WatchdogVerdict late = j(
        OccurrenceRecord(
          succeededUtc: deadline.add(const Duration(minutes: 28)),
        ),
        deadline.add(const Duration(hours: 1)),
      );
      expect(
        (late.state, late.lateBy, late.state.level),
        (WatchdogState.late, const Duration(minutes: 28), UiLevel.watch),
      );
    });

    test('fail 핑 = 실패 · 실패 뒤 성공 = 성공 쪽 · 성공 뒤 실패 = 실패', () {
      final DateTime t = o.scheduledUtc.add(const Duration(minutes: 5));
      expect(j(OccurrenceRecord(failedUtc: t), t).state, WatchdogState.failed);
      expect(
        j(
          OccurrenceRecord(
            failedUtc: t,
            succeededUtc: t.add(const Duration(minutes: 1)),
          ),
          t,
        ).state,
        WatchdogState.success,
      );
      expect(
        j(
          OccurrenceRecord(
            succeededUtc: t,
            failedUtc: t.add(const Duration(minutes: 1)),
          ),
          t,
        ).state,
        WatchdogState.failed,
      );
    });

    test('휴장 성공 핑 = holiday(ok) · 일시정지 = paused(info · 무엇보다 먼저) · 유예 덮어쓰기', () {
      expect(
        j(
          OccurrenceRecord(succeededUtc: o.scheduledUtc, holidayPing: true),
          deadline,
        ).state,
        WatchdogState.holiday,
      );
      expect(WatchdogState.holiday.level, UiLevel.ok);
      final WatchdogVerdict p = j(
        null,
        deadline.add(const Duration(days: 1)),
        paused: true,
      );
      expect((p.state, p.state.level), (WatchdogState.paused, UiLevel.info));
      expect(
        j(
          OccurrenceRecord(
            succeededUtc: o.scheduledUtc.add(const Duration(minutes: 30)),
          ),
          deadline,
          grace: const Duration(minutes: 10),
        ).state,
        WatchdogState.late,
      );
    });
  });

  group('rid · 시장별 달력(R43 B7)', () {
    test('rid = 결정적 UUID 꼴 · 체크 · 시각이 다르면 다르다', () {
      final String a = runIdFor(
        'live-auto-kr_order',
        _kst('2026-11-04', 9, 10),
      );
      expect(a, runIdFor('live-auto-kr_order', _kst('2026-11-04', 9, 10)));
      expect(
        a,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-8[0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(
        a,
        isNot(runIdFor('live-auto-kr_order', _kst('2026-11-05', 9, 10))),
      );
      expect(
        a,
        isNot(runIdFor('sim-auto-kr_order', _kst('2026-11-04', 9, 10))),
      );
    });

    test('start · 끝 핑이 같은 rid · JobRun 에도 같은 값', () async {
      final _Beat beat = _Beat();
      final JobRun<int> r = await runJob<int>(
        check: 'live-auto-daily_data',
        heartbeat: beat,
        alerts: _NoAlerts(),
        calendar: _kr,
        nowUtc: _kst('2026-11-04', 18, 30),
        body: (TradeDate d) async => const JobBody<int>(1),
      );
      expect(
        beat.pings.map(((PingStatus, String?, String?) p) => p.$1),
        <PingStatus>[PingStatus.start, PingStatus.success],
      );
      expect(
        beat.pings.map(((PingStatus, String?, String?) p) => p.$3).toSet(),
        <String>{r.rid},
      );
      expect(
        r.rid,
        runIdFor('live-auto-daily_data', _kst('2026-11-04', 18, 30)),
      );
    });

    test(
      'us_data — XNYS 달력 · 세션일 = KST 날 − 1: 토 KST = 금 세션 · 추수감사절 다음 금 = 휴장',
      () async {
        TradeDate usDay(DateTime now) {
          final DateTime k = now
              .toUtc()
              .add(const Duration(hours: 9))
              .subtract(const Duration(days: 1));
          String two(int n) => n.toString().padLeft(2, '0');
          return TradeDate('${k.year}-${two(k.month)}-${two(k.day)}');
        }

        Future<JobRun<int>> run(DateTime now, _Beat beat) => runJob<int>(
          check: 'live-auto-us_data',
          heartbeat: beat,
          alerts: _NoAlerts(),
          calendar: _us,
          nowUtc: now,
          sessionDayOf: usDay,
          body: (TradeDate d) async => JobBody<int>(d.yyyyMmDd.length),
        );
        final _Beat b1 = _Beat();
        final JobRun<int> sat = await run(_kst('2026-11-07', 7, 30), b1);
        expect(
          (sat.status, sat.sessionDay),
          (JobStatus.success, const TradeDate('2026-11-06')),
        );
        final _Beat b2 = _Beat();
        final JobRun<int> fri = await run(_kst('2026-11-27', 7, 30), b2);
        expect(
          (fri.status, fri.sessionDay),
          (JobStatus.holiday, const TradeDate('2026-11-26')),
        );
        expect(b2.pings.single.$2, '휴장');
      },
    );
  });

  group('FGS 문구(R43 B8 · 04 §5-6 F-01)', () {
    final DateTime recon = _kst('2026-11-04', 9, 12);

    test(
      '정상 = 완성 문자열 1개 «정상 · 마지막 대사 09:12 · 다음 리밸런싱 D-6» · ops_status · 탭 = 워치독',
      () {
        final FgsNotice n = buildFgsNotice(
          FgsStatus(
            level: UiLevel.ok,
            lastReconAtUtc: recon,
            nextRebalanceInSessions: 6,
          ),
        );
        expect(n.text, '정상 · 마지막 대사 09:12 · 다음 리밸런싱 D-6');
        expect(
          (n.channel, n.channel.id, n.level, n.link),
          (
            FgsChannel.opsStatus,
            'ops_status',
            UiLevel.ok,
            AppRoutes.opsWatchdog,
          ),
        );
        expect(
          buildFgsNotice(const FgsStatus(level: UiLevel.ok)).text,
          '정상 · 대사 전',
        );
        expect(
          buildFgsNotice(
            FgsStatus(
              level: UiLevel.ok,
              lastReconAtUtc: recon,
              nextRebalanceInSessions: 0,
            ),
          ).text,
          '정상 · 마지막 대사 09:12 · 오늘 리밸런싱',
        );
      },
    );

    test('이상 = «{엔진 문구} · 마지막 대사 HH:mm» · 탭 = 알림함 · 문구 없으면 ArgumentError', () {
      final FgsNotice n = buildFgsNotice(
        FgsStatus(
          level: UiLevel.act,
          headline: '대사 불일치 — 주문 멈춤',
          lastReconAtUtc: recon,
        ),
      );
      expect(n.text, '대사 불일치 — 주문 멈춤 · 마지막 대사 09:12');
      expect(
        (n.channel, n.link),
        (FgsChannel.opsStatus, AppRoutes.alertsInbox),
      );
      expect(
        () => buildFgsNotice(const FgsStatus(level: UiLevel.watch)),
        throwsArgumentError,
      );
      expect(
        () => buildFgsNotice(
          const FgsStatus(level: UiLevel.blocked, headline: ' '),
        ),
        throwsArgumentError,
      );
      expect(
        () => buildFgsNotice(
          const FgsStatus(level: UiLevel.ok, nextRebalanceInSessions: -1),
        ),
        throwsArgumentError,
      );
    });

    test('🔴 P0 = ops_p0 채널 · 탭 = 그 알림 상세(id 는 인코딩)', () {
      final FgsNotice n = buildFgsNotice(
        const FgsStatus(
          level: UiLevel.blocked,
          headline: '결과 불명 주문',
          p0AlertId: 'al/1',
        ),
      );
      expect((n.channel, n.channel.id), (FgsChannel.opsP0, 'ops_p0'));
      expect(n.link, 'aaq://alerts/detail/al%2F1');
    });

    test('🔴 재발행 = 전이 때만 · 손익 문자 0', () {
      final FgsNotice a = buildFgsNotice(
        FgsStatus(
          level: UiLevel.ok,
          lastReconAtUtc: recon,
          nextRebalanceInSessions: 6,
        ),
      );
      final FgsNotice same = buildFgsNotice(
        FgsStatus(
          level: UiLevel.ok,
          lastReconAtUtc: recon,
          nextRebalanceInSessions: 6,
        ),
      );
      expect(shouldRepostFgs(null, a), isTrue);
      expect(shouldRepostFgs(a, same), isFalse);
      expect(a == same && a.hashCode == same.hashCode, isTrue);
      expect(
        shouldRepostFgs(
          a,
          buildFgsNotice(
            FgsStatus(
              level: UiLevel.ok,
              lastReconAtUtc: recon,
              nextRebalanceInSessions: 5,
            ),
          ),
        ),
        isTrue,
      );
      expect(
        shouldRepostFgs(
          a,
          buildFgsNotice(
            FgsStatus(
              level: UiLevel.watch,
              headline: '지연',
              lastReconAtUtc: recon,
            ),
          ),
        ),
        isTrue,
      );
      // 문구 · 레벨 · 채널이 같아도 링크만 바뀌면 다시 띄운다.
      const FgsNotice linkA = FgsNotice(
        channel: FgsChannel.opsStatus,
        text: '정상',
        level: UiLevel.ok,
        link: AppRoutes.opsWatchdog,
      );
      const FgsNotice linkB = FgsNotice(
        channel: FgsChannel.opsStatus,
        text: '정상',
        level: UiLevel.ok,
        link: AppRoutes.alertsInbox,
      );
      expect(shouldRepostFgs(linkA, linkB), isTrue);
      for (final String banned in <String>['원', '%', '손익', '수익']) {
        expect(a.text.contains(banned), isFalse, reason: banned);
      }
    });
  });
}
