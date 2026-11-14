// E11p3d-2 — 워치독 보드 행 재료(설계 13 §8 R109).

import 'package:core_engine/core_engine.dart'
    show
        JobRunEntry,
        JobRunStatus,
        Market,
        frozenExchangeCalendar,
        watchdogCheckName;
import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode, TradeDate;
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

DateTime _kst(int y, int m, int d, int h, int min) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(hours: 9));

JobRunEntry _e(String job, String day, JobRunStatus st, DateTime finished) =>
    JobRunEntry(
      rid: '$job-$day-${st.name}-${finished.millisecondsSinceEpoch}',
      checkName: watchdogCheckName(
        RunMode.simInternal,
        OperatingMode.autoTrade,
        job,
      ),
      sessionDay: TradeDate(day),
      startedAtUtc: finished.subtract(const Duration(minutes: 1)),
      finishedAtUtc: finished,
      status: st,
    );

void main() {
  final JobCalendars cals = JobCalendars(
    kr: frozenExchangeCalendar(Market.kr),
    us: frozenExchangeCalendar(Market.us),
  );

  List<WatchdogBoardInput> rows(
    DateTime now,
    Map<String, List<JobRunEntry>> log, {
    DateTime? notBefore,
  }) => watchdogBoardInputsFor(
    run: RunMode.simInternal,
    op: OperatingMode.autoTrade,
    calendars: cals,
    nowUtc: now,
    entriesOf: (String job) => log[job] ?? const <JobRunEntry>[],
    notBeforeUtc: notBefore,
  );

  WatchdogBoardInput row(List<WatchdogBoardInput> rs, String job) =>
      rs.singleWhere(
        (WatchdogBoardInput r) => r.label == kJobWatchdogLabels[job],
      );

  test('🔴 이름표 = 잡 표 전부 · 행 = 바깥 체크와 같은 집합(월말 다음 세션 잡 제외) · 잡 표 순', () {
    expect(
      kJobWatchdogLabels.keys.toSet(),
      kJobTable.map((JobSpec s) => s.job).toSet(),
    );
    final List<WatchdogBoardInput> rs = rows(_kst(2026, 12, 22, 21, 0), {});
    expect(rs.map((WatchdogBoardInput r) => r.slug).toList(), <String>[
      for (final s in watchdogCheckSpecsFor(
        RunMode.simInternal,
        OperatingMode.autoTrade,
      ))
        s.slug,
    ]);
    expect(
      rs.any(
        (WatchdogBoardInput r) =>
            r.label == kJobWatchdogLabels['monthly_rebalance'],
      ),
      false,
    );
  });

  test('🔴 월말 다음 세션 잡은 회차가 있어도 행에 없다(바깥 체크가 없다)', () {
    // 12-01 08:00 = 11월 월말 계획 회차(14일 안).
    final List<WatchdogBoardInput> rs = rows(_kst(2026, 12, 3, 9, 0), {});
    expect(
      rs.any(
        (WatchdogBoardInput r) =>
            r.label == kJobWatchdogLabels['monthly_rebalance'],
      ),
      false,
    );
  });

  test('🔴 마지막 회차 판정 — 성공 · 기록 없음 + 유예 지남 = 실패 · 유예 안 = 대기', () {
    final DateTime now = _kst(2026, 12, 22, 9, 30);
    final List<WatchdogBoardInput> rs = rows(now, <String, List<JobRunEntry>>{
      'daily_reconcile': <JobRunEntry>[
        _e(
          'daily_reconcile',
          '2026-12-22',
          JobRunStatus.success,
          _kst(2026, 12, 22, 7, 6),
        ),
      ],
    });
    expect(row(rs, 'daily_reconcile').verdict.state, WatchdogState.success);
    expect(
      row(rs, 'daily_reconcile').record!.succeededUtc,
      _kst(2026, 12, 22, 7, 6),
    );
    // kr_order 09:10 · 유예 60분 → 09:30 = 아직 대기.
    expect(row(rs, 'kr_order').verdict.state, WatchdogState.pending);
    // equity_snapshot 의 마지막 회차 = 전날 20:30(늦은 끝 지남 · 기록 없음) = 실패.
    expect(row(rs, 'equity_snapshot').verdict.state, WatchdogState.failed);
  });

  test('🔴 그 세션일 기록만 본다 · 실패 뒤 성공 = 성공 · 휴장 핑 = 휴장', () {
    final DateTime now = _kst(2026, 12, 22, 12, 0);
    final List<WatchdogBoardInput> rs = rows(now, <String, List<JobRunEntry>>{
      'kr_order': <JobRunEntry>[
        _e(
          'kr_order',
          '2026-12-21',
          JobRunStatus.success,
          _kst(2026, 12, 21, 9, 12),
        ),
        _e(
          'kr_order',
          '2026-12-22',
          JobRunStatus.failed,
          _kst(2026, 12, 22, 9, 11),
        ),
        _e(
          'kr_order',
          '2026-12-22',
          JobRunStatus.success,
          _kst(2026, 12, 22, 9, 40),
        ),
      ],
    });
    final WatchdogBoardInput k = row(rs, 'kr_order');
    expect(k.verdict.state, WatchdogState.success);
    expect(k.record!.failedUtc, _kst(2026, 12, 22, 9, 11));
    // 12-25(금) = KR 휴장 · 휴장 핑.
    final List<WatchdogBoardInput> h = rows(
      _kst(2026, 12, 25, 12, 0),
      <String, List<JobRunEntry>>{
        'kr_order': <JobRunEntry>[
          _e(
            'kr_order',
            '2026-12-25',
            JobRunStatus.holiday,
            _kst(2026, 12, 25, 9, 10),
          ),
        ],
      },
    );
    expect(row(h, 'kr_order').verdict.state, WatchdogState.holiday);
  });

  test('🔴 다른 날 성공은 오늘 회차를 덮지 않는다', () {
    final List<WatchdogBoardInput> rs = rows(
      _kst(2026, 12, 22, 12, 0),
      <String, List<JobRunEntry>>{
        'kr_order': <JobRunEntry>[
          _e(
            'kr_order',
            '2026-12-21',
            JobRunStatus.success,
            _kst(2026, 12, 21, 9, 12),
          ),
        ],
      },
    );
    expect(row(rs, 'kr_order').verdict.state, WatchdogState.failed);
    expect(row(rs, 'kr_order').record, isNull);
  });

  test('🔴 모드 시작 앞 회차는 판정하지 않는다(행에서 뺀다)', () {
    final DateTime now = _kst(2026, 12, 22, 9, 30);
    final List<WatchdogBoardInput> rs = rows(
      now,
      <String, List<JobRunEntry>>{},
      notBefore: _kst(2026, 12, 22, 8, 0),
    );
    // 08:00 부터의 회차 = kr_order(09:10) · seasonal_a(08:00 — 경계 포함) · 대사(07:00) · us_data(07:30) · 전날 저녁 잡 = 빠짐.
    expect(rs.map((WatchdogBoardInput r) => r.label), <String>[
      kJobWatchdogLabels['kr_order']!,
      kJobWatchdogLabels['seasonal_a']!,
    ]);
  });

  test('기록 없음 = null · 지연 성공 = 늦음', () {
    expect(
      occurrenceRecordOf(const <JobRunEntry>[], const TradeDate('2026-12-22')),
      isNull,
    );
    final List<WatchdogBoardInput> rs = rows(
      _kst(2026, 12, 22, 12, 0),
      <String, List<JobRunEntry>>{
        'kr_order': <JobRunEntry>[
          _e(
            'kr_order',
            '2026-12-22',
            JobRunStatus.late,
            _kst(2026, 12, 22, 10, 30),
          ),
        ],
      },
    );
    expect(row(rs, 'kr_order').verdict.state, WatchdogState.late);
  });
}
