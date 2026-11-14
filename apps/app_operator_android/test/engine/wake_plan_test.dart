// E11p3a 깨어남 → 회차 판정 조립 시험(설계 e11p-map Q5).

import 'package:app_operator_android/engine/wake_plan.dart';
import 'package:domain_contracts/domain_contracts.dart' show TradeDate;
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_runtime/trading_runtime.dart'
    show JobCalendars, JobOccurrence, kJobTable, kstDateOf;

import 'support.dart';

/// 2026-12-01(화) 08:30 KST — 월말 다음 첫 세션 · 월말 잡(세션 = 11-30) · us_data(세션 = 11-30) 늦은 끝 안.
final DateTime _now = kst(2026, 12, 1, 8, 30);

JobOccurrence? _find(List<JobOccurrence> xs, String job, String session) {
  for (final JobOccurrence o in xs) {
    if (o.spec.job == job && o.sessionDay.yyyyMmDd == session) return o;
  }
  return null;
}

void main() {
  final JobCalendars cals = calendars();

  test('돈 회차가 없으면 늦은 끝 안 = runNow · 지난 것 = missed', () {
    final WakePlan p = planWake(
      nowUtc: _now,
      cals: cals,
      doneSessions: (String job, TradeDate from) => const <TradeDate>[],
    );
    expect(_find(p.runNow, 'monthly_rebalance', '2026-11-30'), isNotNull);
    expect(_find(p.runNow, 'us_data', '2026-11-30'), isNotNull);
    expect(_find(p.missed, 'equity_snapshot', '2026-11-30'), isNotNull);
    expect(_find(p.runNow, 'equity_snapshot', '2026-11-30'), isNull);
    expect(p.done, 0);
    // kr_order(09:10)는 아직 예정 전 — 계획에 없다.
    expect(_find(p.runNow, 'kr_order', '2026-12-01'), isNull);
  });

  test('🔴 «돈» 세션은 세션일 기준 — 월말 잡 · us_data(세션 ≠ 발화 날)도 done', () {
    final WakePlan p = planWake(
      nowUtc: _now,
      cals: cals,
      doneSessions: (String job, TradeDate from) => switch (job) {
        'monthly_rebalance' ||
        'us_data' => <TradeDate>[const TradeDate('2026-11-30')],
        _ => const <TradeDate>[],
      },
    );
    expect(_find(p.runNow, 'monthly_rebalance', '2026-11-30'), isNull);
    expect(_find(p.runNow, 'us_data', '2026-11-30'), isNull);
    expect(p.done, 2);
  });

  test('🔴 읽기 시작 = 볼 구간보다 한 구간 앞(세션일이 발화 날보다 앞선다) · 잡 표 전부를 묻는다', () {
    final Map<String, TradeDate> asked = <String, TradeDate>{};
    planWake(
      nowUtc: _now,
      cals: cals,
      doneSessions: (String job, TradeDate from) {
        asked[job] = from;
        return const <TradeDate>[];
      },
    );
    expect(asked.keys.toSet(), kJobTable.map((s) => s.job).toSet());
    for (final TradeDate f in asked.values) {
      expect(f, kstDateOf(_now.subtract(kWakeLookback * 2)));
    }
  });

  test('runNow = 예정 차례(같은 시각 = 잡 이름 차례)', () {
    final WakePlan p = planWake(
      nowUtc: _now,
      cals: cals,
      doneSessions: (String job, TradeDate from) => const <TradeDate>[],
    );
    expect(p.runNow.length, greaterThan(2));
    for (int i = 1; i < p.runNow.length; i++) {
      final JobOccurrence a = p.runNow[i - 1];
      final JobOccurrence b = p.runNow[i];
      expect(
        a.scheduledUtc.isBefore(b.scheduledUtc) ||
            (a.scheduledUtc == b.scheduledUtc &&
                a.spec.job.compareTo(b.spec.job) <= 0),
        true,
        reason: '${a.spec.job}@${a.scheduledUtc} → ${b.spec.job}',
      );
    }
  });

  test('볼 구간 밖(15일 전) 회차는 계획에 없다', () {
    final WakePlan p = planWake(
      nowUtc: _now,
      cals: cals,
      doneSessions: (String job, TradeDate from) => const <TradeDate>[],
    );
    final DateTime edge = _now.subtract(kWakeLookback);
    for (final JobOccurrence o in <JobOccurrence>[...p.runNow, ...p.missed]) {
      expect(o.scheduledUtc.isBefore(edge), false, reason: o.spec.job);
    }
  });
}
