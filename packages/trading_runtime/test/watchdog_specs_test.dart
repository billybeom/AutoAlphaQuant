// 🆕 E15f4b1 — 잡 표 → 감시 체크 생성 꼴(설계 13 §8 R105 AJ5).

import 'package:core_engine/core_engine.dart' show WatchdogCheckSpec;
import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode;
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

void main() {
  test('8 잡 = 잡 표 순 · cron(KST 평일 · us_data 화~토) · 표의 유예 · 이름 = 슬러그 · 태그 = 두 축 · 월말 다음 세션 제외', () {
    final List<WatchdogCheckSpec> s = watchdogCheckSpecsFor(
      RunMode.live,
      OperatingMode.autoTrade,
    );
    expect(
      s.map(
        (WatchdogCheckSpec x) => '${x.slug}|${x.cron}|${x.grace.inMinutes}',
      ),
      <String>[
        'live-auto-daily_reconcile|0 7 * * 1-5|120',
        'live-auto-kr_order|10 9 * * 1-5|60',
        'live-auto-kr_order_close|45 15 * * 1-5|60',
        'live-auto-daily_data|30 18 * * 1-5|120',
        'live-auto-daily_signal|0 20 * * 1-5|60',
        'live-auto-equity_snapshot|30 20 * * 1-5|60',
        'live-auto-seasonal_a|0 8 * * 1-5|60',
        'live-auto-us_data|30 7 * * 2-6|120',
      ],
    );
    for (final WatchdogCheckSpec x in s) {
      expect(x.tz, 'Asia/Seoul');
      expect(x.timeout, isNull);
      expect(x.name, x.slug);
      expect(x.tags, <String>['live', 'auto']);
    }
    expect(kWatchdogSpecExcluded.keys, <String>['monthly_rebalance']);
    expect(
      s.any((WatchdogCheckSpec x) => x.slug.endsWith('monthly_rebalance')),
      isFalse,
    );
    expect(
      () => watchdogCronOf(jobSpecOf('monthly_rebalance')),
      throwsArgumentError,
    );
  });

  test('축 = 모드 · 운영 방식 · 유예 덮기는 그 잡만', () {
    final List<WatchdogCheckSpec> s = watchdogCheckSpecsFor(
      RunMode.simInternal,
      OperatingMode.advisory,
      graceOverride: const <String, Duration>{
        'kr_order': Duration(minutes: 30),
      },
    );
    expect(s.first.slug, 'sim-advisory-daily_reconcile');
    expect(s.first.tags, <String>['sim', 'advisory']);
    expect(
      s.firstWhere((WatchdogCheckSpec x) => x.slug.endsWith('-kr_order')).grace,
      const Duration(minutes: 30),
    );
    expect(s.first.grace, const Duration(hours: 2));
    // 이름 함수는 core 에서 온다(같은 값).
    expect(
      watchdogCheckName(RunMode.simInternal, OperatingMode.advisory, 'x'),
      'sim-advisory-x',
    );
  });
}
