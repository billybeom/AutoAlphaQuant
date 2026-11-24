// E11q-s05 — M9 S05 잡 행 · 다음 잡 한 줄(설계 13 §8 R252 · 01 §28 K12).

import 'package:core_engine/core_engine.dart'
    show
        JobRunEntry,
        JobRunStatus,
        Market,
        frozenExchangeCalendar,
        watchdogCheckName;
import 'package:domain_contracts/domain_contracts.dart'
    show JobRow, OperatingMode, RunMode, TradeDate, UiLevel;
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
  // 2026-11-24(화) 19:00 KST.
  final DateTime now = _kst(2026, 11, 24, 19, 0);

  List<JobRow> rows(
    Map<String, List<JobRunEntry>> log, {
    DateTime? notBefore,
  }) => operationsJobRowsOf(
    entriesOf: (String job) => log[job] ?? const <JobRunEntry>[],
    nowUtc: now,
    notBeforeUtc: notBefore,
  );

  JobRow row(List<JobRow> rs, String job) =>
      rs.singleWhere((JobRow r) => r.label == kJobWatchdogLabels[job]);

  test('🔴 행 = 잡 표 전부 · 잡 표 차례 · 이름표 = 감시 보드와 같은 글자 · 회차 0 = NONE · INFO', () {
    final List<JobRow> rs = rows(const <String, List<JobRunEntry>>{});
    expect(rs.map((JobRow r) => r.label).toList(), <String>[
      for (final JobSpec s in kJobTable) kJobWatchdogLabels[s.job]!,
    ]);
    for (final JobRow r in rs) {
      expect(
        (r.statusCode, r.stateLabel, r.level, r.lastRunText, r.detailLine),
        ('NONE', '아직 없음', UiLevel.info, '아직 돈 적 없음', null),
      );
    }
  });

  test('🔴 일정 글자 = 잡 표 주기 · 시각 · 유예(새 숫자 0 · 표본 꼴)', () {
    final List<JobRow> rs = rows(const <String, List<JobRunEntry>>{});
    expect(row(rs, 'kr_order').scheduleText, '평일 09:10 · 유예 1시간');
    expect(row(rs, 'daily_reconcile').scheduleText, '평일 07:00 · 유예 2시간');
    expect(
      row(rs, 'monthly_rebalance').scheduleText,
      '월말 다음 거래일 08:00 · 유예 1시간',
    );
    expect(row(rs, 'us_data').scheduleText, '미국 거래일 다음 날 07:30 · 유예 2시간');
    expect(
      operationsScheduleTextOf(
        jobSpecOf('kr_order'),
        grace: const Duration(minutes: 45),
      ),
      '평일 09:10 · 유예 45분',
    );
  });

  test('🔴 상태 = 마지막 job_run(끝 시각) · 짝 SUCCESS ok · LATE watch · FAILED act + 한 줄 · HOLIDAY info', () {
    final List<JobRow> rs = rows(<String, List<JobRunEntry>>{
      'daily_reconcile': <JobRunEntry>[
        _e(
          'daily_reconcile',
          '2026-11-23',
          JobRunStatus.failed,
          _kst(2026, 11, 23, 9, 1),
        ),
        _e(
          'daily_reconcile',
          '2026-11-24',
          JobRunStatus.success,
          _kst(2026, 11, 24, 7, 2),
        ),
      ],
      'kr_order': <JobRunEntry>[
        _e(
          'kr_order',
          '2026-11-24',
          JobRunStatus.late,
          _kst(2026, 11, 24, 10, 31),
        ),
      ],
      'daily_data': <JobRunEntry>[
        _e(
          'daily_data',
          '2026-11-20',
          JobRunStatus.failed,
          _kst(2026, 11, 20, 18, 30),
        ),
      ],
      'us_data': <JobRunEntry>[
        _e(
          'us_data',
          '2026-11-23',
          JobRunStatus.holiday,
          _kst(2026, 11, 24, 7, 30),
        ),
      ],
    });
    final JobRow a = row(rs, 'daily_reconcile');
    expect(
      (a.statusCode, a.stateLabel, a.level, a.lastRunText),
      ('SUCCESS', '성공', UiLevel.ok, '오늘 07:02 끝남'),
    );
    final JobRow b = row(rs, 'kr_order');
    expect(
      (b.statusCode, b.stateLabel, b.level, b.lastRunText),
      ('LATE', '지연 — 성공', UiLevel.watch, '오늘 10:31 끝남'),
    );
    final JobRow c = row(rs, 'daily_data');
    expect(
      (c.statusCode, c.stateLabel, c.level, c.lastRunText, c.detailLine),
      (
        'FAILED',
        '실패',
        UiLevel.act,
        '11월 20일 18:30 실패',
        OperationsJobTexts.failedDetail,
      ),
    );
    final JobRow d = row(rs, 'us_data');
    expect(
      (d.statusCode, d.stateLabel, d.level, d.lastRunText),
      ('HOLIDAY', '휴장', UiLevel.info, '오늘 07:30 — 휴장이라 본체를 돌리지 않았습니다'),
    );
  });

  test('🔴 모드 시작 앞 기록 = 보지 않는다(새 모드 = 회차 0)', () {
    final List<JobRow> rs = rows(<String, List<JobRunEntry>>{
      'kr_order': <JobRunEntry>[
        _e(
          'kr_order',
          '2026-11-20',
          JobRunStatus.success,
          _kst(2026, 11, 20, 9, 12),
        ),
      ],
    }, notBefore: _kst(2026, 11, 21, 0, 0));
    expect(row(rs, 'kr_order').statusCode, 'NONE');
  });

  test('🔴 다음 잡 = 지금 뒤 가장 이른 예정 회차(«오늘 · 내일 · M월 d일» + 이름표)', () {
    expect(
      operationsNextJobTextOf(calendars: cals, nowUtc: now),
      '오늘 20:00 ${kJobWatchdogLabels['daily_signal']}',
    );
    expect(
      operationsNextJobTextOf(
        calendars: cals,
        nowUtc: _kst(2026, 11, 24, 23, 0),
      ),
      '내일 07:00 ${kJobWatchdogLabels['daily_reconcile']}',
    );
    expect(operationsWhenText(_kst(2026, 12, 3, 8, 5), now), '12월 3일 08:05');
  });
}
