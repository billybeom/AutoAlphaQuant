// 🆕 E15f4b1 — 감시 포트 순수 몫(체크 이름 · 접두 · 멈춤 규칙 · 생성 꼴) + 가짜(설계 13 §8 R105 AJ1~AJ7).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

RemoteCheck _c(String slug, [RemoteCheckStatus s = RemoteCheckStatus.up]) =>
    RemoteCheck(slug: slug, status: s);

void main() {
  test('이름 · 접두 — 2축 넷 · 접두 읽기(알려진 넷만)', () {
    expect(
      watchdogCheckPrefix(RunMode.simInternal, OperatingMode.autoTrade),
      'sim-auto',
    );
    expect(
      watchdogCheckPrefix(RunMode.simBroker, OperatingMode.advisory),
      'sim-advisory',
    );
    expect(
      watchdogCheckPrefix(RunMode.live, OperatingMode.autoTrade),
      'live-auto',
    );
    expect(
      watchdogCheckPrefix(RunMode.live, OperatingMode.advisory),
      'live-advisory',
    );
    expect(
      watchdogCheckName(RunMode.live, OperatingMode.autoTrade, 'kr_order'),
      'live-auto-kr_order',
    );
    expect(kWatchdogPrefixes, <String>{
      'sim-auto',
      'sim-advisory',
      'live-auto',
      'live-advisory',
    });
    expect(watchdogPrefixOf('sim-auto-engine_alive'), 'sim-auto');
    expect(watchdogPrefixOf('live-advisory-kr-order-x'), 'live-advisory');
    expect(watchdogPrefixOf('engine_alive'), isNull);
    expect(watchdogPrefixOf('sim-auto'), isNull);
    expect(watchdogPrefixOf('mock-auto-x'), isNull);
    expect(watchdogPrefixOf('backup-age-x'), isNull);
  });

  test(
    '🔴 멈춤 규칙 — 유지보수 창 = 엔진 생존만 거절 · 모드 전환 = 새 접두 있고 옛 접두 체크만(엔진 생존 포함)',
    () {
      const PauseReason mw = PauseReason.maintenanceWindow;
      const PauseReason ms = PauseReason.modeSwitchCommit;
      // 유지보수 창.
      expect(pausePermitted('live-auto-daily_data', mw), isTrue);
      expect(pausePermitted('live-auto-engine_alive', mw), isFalse);
      expect(pausePermitted('engine_alive', mw), isFalse);
      expect(pausePermitted('backup_age', mw), isTrue);
      expect(
        pausePermitted('live-auto-engine_alive', mw, toPrefix: 'sim-auto'),
        isFalse,
      );
      // 모드 전환 — 새 접두 없음 · 모르는 접두 = 전부 거절.
      expect(pausePermitted('sim-auto-kr_order', ms), isFalse);
      expect(
        pausePermitted('sim-auto-kr_order', ms, toPrefix: 'nope-x'),
        isFalse,
      );
      // 옛 접두 = 허용(엔진 생존 포함).
      expect(
        pausePermitted('sim-auto-kr_order', ms, toPrefix: 'live-auto'),
        isTrue,
      );
      expect(
        pausePermitted('sim-auto-engine_alive', ms, toPrefix: 'live-auto'),
        isTrue,
      );
      expect(
        pausePermitted('sim-advisory-engine_alive', ms, toPrefix: 'sim-auto'),
        isTrue,
      );
      // 새 접두 = 거절 · 접두 없음 = 거절.
      expect(
        pausePermitted('live-auto-kr_order', ms, toPrefix: 'live-auto'),
        isFalse,
      );
      expect(
        pausePermitted('live-auto-engine_alive', ms, toPrefix: 'live-auto'),
        isFalse,
      );
      expect(
        pausePermitted('engine_alive', ms, toPrefix: 'live-auto'),
        isFalse,
      );
      expect(pausePermitted('backup_age', ms, toPrefix: 'live-auto'), isFalse);
    },
  );

  test(
    '생성 꼴 — cron · timeout 정확히 하나 · 60초 이상 · 이름 = 슬러그 · tz 기본 Asia/Seoul',
    () {
      final WatchdogCheckSpec s = WatchdogCheckSpec(
        slug: 'live-auto-kr_order',
        grace: const Duration(minutes: 60),
        cron: '10 9 * * 1-5',
        tags: const <String>['live', 'auto'],
      );
      expect(s.name, 'live-auto-kr_order');
      expect(s.tz, 'Asia/Seoul');
      expect(s.timeout, isNull);
      WatchdogCheckSpec make({
        String? cron,
        Duration? timeout,
        Duration grace = const Duration(minutes: 5),
      }) => WatchdogCheckSpec(
        slug: 'x-y-z',
        grace: grace,
        cron: cron,
        timeout: timeout,
      );
      expect(make, throwsArgumentError);
      expect(
        () => make(cron: '* * * * *', timeout: const Duration(hours: 1)),
        throwsArgumentError,
      );
      expect(
        () => make(cron: '* * * * *', grace: const Duration(seconds: 59)),
        throwsArgumentError,
      );
      expect(
        () => make(timeout: const Duration(seconds: 59)),
        throwsArgumentError,
      );
      expect(
        make(timeout: const Duration(seconds: 60)).timeout,
        const Duration(seconds: 60),
      );
      expect(
        make(cron: '* * * * *', grace: const Duration(seconds: 60)).grace,
        const Duration(seconds: 60),
      );
    },
  );

  group('FakeWatchdogRemote', () {
    WatchdogCheckSpec spec(String slug) => WatchdogCheckSpec(
      slug: slug,
      grace: const Duration(hours: 1),
      cron: '0 8 * * 1-5',
    );

    test('생성 = 새로 · 고침(상태 유지) · 상한 · 호출 기록', () async {
      final FakeWatchdogRemote r = FakeWatchdogRemote(
        limit: 2,
        initial: <RemoteCheck>[
          _c('sim-auto-kr_order', RemoteCheckStatus.paused),
        ],
      );
      final EnsuredCheck a = await r.ensure(spec('live-auto-kr_order'));
      expect(
        (a.outcome, a.check.status),
        (EnsureOutcome.created, RemoteCheckStatus.fresh),
      );
      final EnsuredCheck b = await r.ensure(spec('sim-auto-kr_order'));
      expect(
        (b.outcome, b.check.status),
        (EnsureOutcome.updated, RemoteCheckStatus.paused),
      );
      await expectLater(
        r.ensure(spec('live-auto-daily_data')),
        throwsStateError,
      );
      expect(r.calls, <String>[
        'ensure:live-auto-kr_order',
        'ensure:sim-auto-kr_order',
        'ensure:live-auto-daily_data',
      ]);
    });

    test(
      '멈춤 = 실물과 같은 규칙(거절이면 상태 그대로) · 재개 = new · 이미 켜짐 = false · 실패 주입',
      () async {
        final FakeWatchdogRemote r = FakeWatchdogRemote(
          initial: <RemoteCheck>[
            _c('sim-auto-engine_alive'),
            _c('live-auto-kr_order'),
          ],
        );
        await expectLater(
          r.pause(
            'sim-auto-engine_alive',
            reason: PauseReason.maintenanceWindow,
          ),
          throwsStateError,
        );
        expect(r.store['sim-auto-engine_alive']!.status, RemoteCheckStatus.up);
        await r.pause(
          'sim-auto-engine_alive',
          reason: PauseReason.modeSwitchCommit,
          toPrefix: 'live-auto',
        );
        expect(
          r.store['sim-auto-engine_alive']!.status,
          RemoteCheckStatus.paused,
        );
        expect(
          await r.resume(
            'sim-auto-engine_alive',
            reason: PauseReason.modeSwitchCommit,
          ),
          isTrue,
        );
        expect(
          r.store['sim-auto-engine_alive']!.status,
          RemoteCheckStatus.fresh,
        );
        expect(
          await r.resume(
            'live-auto-kr_order',
            reason: PauseReason.modeSwitchCommit,
          ),
          isFalse,
        );
        r.failOn[('pause', '*')] = Exception('boom');
        await expectLater(
          r.pause(
            'sim-auto-engine_alive',
            reason: PauseReason.modeSwitchCommit,
            toPrefix: 'live-auto',
          ),
          throwsException,
        );
        r.failOn[('checks', '*')] = Exception('x');
        await expectLater(r.checks(), throwsException);
        await expectLater(
          r.resume('nope-x-y', reason: PauseReason.modeSwitchCommit),
          throwsStateError,
        );
      },
    );
  });
}
