// 🆕 E15f4b2 — simToAuto 전환 오케스트레이션(순서 · 보상 · 기동 보정 · 설계 13 §8 R106 AK1~AK7).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:test/test.dart';

RemoteCheck _c(String slug, [RemoteCheckStatus s = RemoteCheckStatus.up]) =>
    RemoteCheck(slug: slug, status: s);

WatchdogCheckSpec _spec(String slug) => WatchdogCheckSpec(
  slug: slug,
  grace: const Duration(hours: 1),
  cron: '10 9 * * 1-5',
);

final List<WatchdogCheckSpec> _newSpecs = <WatchdogCheckSpec>[
  _spec('live-auto-kr_order'),
  _spec('live-auto-daily_data'),
];

FakeWatchdogRemote _remote() => FakeWatchdogRemote(
  initial: <RemoteCheck>[
    _c('sim-auto-kr_order'),
    _c('sim-auto-daily_data'),
    _c('sim-auto-engine_alive'),
    // 지난번 중단된 시도가 남긴 새 접두 체크(멈춰 있음).
    _c('live-auto-daily_data', RemoteCheckStatus.paused),
  ],
);

Future<SimToAutoSwitchResult> _run(
  FakeWatchdogRemote r, {
  SimToAutoSwitchCommit commit = const SimToAutoSwitchCommit.ok(
    'LIVEOPEN-1',
    '실전으로 옮겼습니다.',
  ),
  bool commitThrows = false,
  bool finishThrows = false,
  List<WatchdogCheckSpec>? specs,
  String newPrefix = 'live-auto',
  String oldPrefix = 'sim-auto',
}) => runSimToAutoSwitch(
  remote: r,
  newSpecs: specs ?? _newSpecs,
  newPrefix: newPrefix,
  oldPrefix: oldPrefix,
  commit: () async {
    r.calls.add('commit');
    if (commitThrows) throw StateError('x');
    return commit;
  },
  finish: () async {
    r.calls.add('finish');
    if (finishThrows) throw StateError('y');
  },
);

RemoteCheckStatus _s(FakeWatchdogRemote r, String slug) =>
    r.store[slug]!.status;

void main() {
  test('순서 = 새 체크 생성 · 재개 → 커밋 → 마감 → 옛 접두 멈춤(옛 엔진 생존 포함 · 슬러그 순)', () async {
    final FakeWatchdogRemote r = _remote();
    final SimToAutoSwitchResult x = await _run(r);
    expect(r.calls, <String>[
      'ensure:live-auto-kr_order',
      'ensure:live-auto-daily_data',
      'resume:live-auto-daily_data',
      'commit',
      'finish',
      'checks',
      'pause:sim-auto-daily_data:modeSwitchCommit',
      'pause:sim-auto-engine_alive:modeSwitchCommit',
      'pause:sim-auto-kr_order:modeSwitchCommit',
    ]);
    expect(x.committed, isTrue);
    expect(x.stage, SimToAutoSwitchStage.done);
    expect(x.code, isNull);
    expect(x.decisionId, 'LIVEOPEN-1');
    expect(x.headline, '실전으로 옮겼습니다.');
    expect(x.finishPending, isFalse);
    expect(x.pendingPauses, isEmpty);
    expect(x.oldChecksUnknown, isFalse);
    expect(_s(r, 'live-auto-kr_order'), RemoteCheckStatus.fresh);
    expect(_s(r, 'live-auto-daily_data'), RemoteCheckStatus.fresh);
    for (final String s in <String>[
      'sim-auto-kr_order',
      'sim-auto-daily_data',
      'sim-auto-engine_alive',
    ]) {
      expect(_s(r, s), RemoteCheckStatus.paused, reason: s);
    }
  });

  test('준비 실패 = 커밋 0 · 이번에 재개한 것만 다시 멈춤(옛 접두로 되돌림) · 만든 체크는 둔다', () async {
    final FakeWatchdogRemote r = FakeWatchdogRemote(
      initial: <RemoteCheck>[
        _c('sim-auto-kr_order'),
        _c('live-auto-kr_order', RemoteCheckStatus.paused),
      ],
    );
    r.failOn[('ensure', 'live-auto-daily_data')] = Exception('boom');
    final SimToAutoSwitchResult x = await _run(r);
    expect(x.committed, isFalse);
    expect(x.stage, SimToAutoSwitchStage.prepare);
    expect(x.code, kSimToAutoWatchdogPrepareFailed);
    expect(x.headline, contains('바뀐 것은 없습니다'));
    expect(r.calls, <String>[
      'ensure:live-auto-kr_order',
      'resume:live-auto-kr_order',
      'ensure:live-auto-daily_data',
      'pause:live-auto-kr_order:modeSwitchCommit',
    ]);
    expect(_s(r, 'live-auto-kr_order'), RemoteCheckStatus.paused);
    expect(_s(r, 'sim-auto-kr_order'), RemoteCheckStatus.up);
    // 재개 실패도 준비 실패.
    final FakeWatchdogRemote q = _remote();
    q.failOn[('resume', 'live-auto-daily_data')] = Exception('x');
    final SimToAutoSwitchResult y = await _run(q);
    expect((y.committed, y.code), (false, kSimToAutoWatchdogPrepareFailed));
    expect(q.calls.contains('commit'), isFalse);
    // 새로 만든 체크는 남는다(new = 경보 0).
    expect(q.store['live-auto-kr_order']!.status, RemoteCheckStatus.fresh);
  });

  test('커밋 거부 = 같은 보상 · 코드 · 문구 그대로 · 마감 · 옛 멈춤 0', () async {
    final FakeWatchdogRemote r = _remote();
    final SimToAutoSwitchResult x = await _run(
      r,
      commit: const SimToAutoSwitchCommit.no(
        'HANDOVER_SESSION_INVALID',
        '세션 없음',
      ),
    );
    expect(x.committed, isFalse);
    expect(x.stage, SimToAutoSwitchStage.commit);
    expect(x.code, 'HANDOVER_SESSION_INVALID');
    expect(x.headline, '세션 없음');
    expect(r.calls.last, 'pause:live-auto-daily_data:modeSwitchCommit');
    expect(r.calls.contains('finish'), isFalse);
    expect(_s(r, 'live-auto-daily_data'), RemoteCheckStatus.paused);
    expect(_s(r, 'sim-auto-kr_order'), RemoteCheckStatus.up);
  });

  test('🔴 커밋 콜백이 던짐 = 결과 모름 · 보상하지 않는다(재개한 새 체크 그대로)', () async {
    final FakeWatchdogRemote r = _remote();
    final SimToAutoSwitchResult x = await _run(r, commitThrows: true);
    expect(x.committed, isFalse);
    expect(x.stage, SimToAutoSwitchStage.commit);
    expect(x.code, kSimToAutoCommitUnknown);
    expect(r.calls.last, 'commit');
    expect(_s(r, 'live-auto-daily_data'), RemoteCheckStatus.fresh);
  });

  test('커밋 뒤 마감 실패 · 옛 멈춤 실패 = 커밋 그대로 · 남음으로 알림', () async {
    final FakeWatchdogRemote r = _remote();
    r.failOn[('pause', 'sim-auto-kr_order')] = Exception('x');
    final SimToAutoSwitchResult x = await _run(r, finishThrows: true);
    expect(x.committed, isTrue);
    expect(x.stage, SimToAutoSwitchStage.done);
    expect(x.finishPending, isTrue);
    expect(x.pendingPauses, <String>['sim-auto-kr_order']);
    expect(x.oldChecksUnknown, isFalse);
    expect(
      x.headline,
      '실전으로 옮겼습니다. 모의 기록 정리는 다음 시작 때 마저 합니다. '
      '모의투자 감시 체크 일부를 멈추지 못해 다음 시작 때 다시 멈춥니다.',
    );
    expect(_s(r, 'sim-auto-daily_data'), RemoteCheckStatus.paused);
    // 목록을 못 읽음 = 모름.
    final FakeWatchdogRemote q = _remote();
    q.failOn[('checks', '*')] = Exception('y');
    final SimToAutoSwitchResult y = await _run(q);
    expect((y.committed, y.oldChecksUnknown), (true, true));
    expect(y.pendingPauses, isEmpty);
    expect(y.headline, contains('다시 멈춥니다'));
    expect(y.headline, isNot(contains('정리는')));
  });

  test('인자 — 같은 접두 · 모르는 접두 · 새 접두가 아닌 스펙 = ArgumentError(호출 0)', () async {
    final FakeWatchdogRemote r = _remote();
    await expectLater(_run(r, newPrefix: 'sim-auto'), throwsArgumentError);
    // 같은 접두 — 스펙이 그 접두라도 거절.
    await expectLater(
      _run(
        r,
        newPrefix: 'sim-auto',
        specs: <WatchdogCheckSpec>[_spec('sim-auto-kr_order')],
      ),
      throwsArgumentError,
    );
    await expectLater(_run(r, oldPrefix: 'mock-x'), throwsArgumentError);
    await expectLater(_run(r, newPrefix: 'live-x'), throwsArgumentError);
    await expectLater(
      _run(r, specs: <WatchdogCheckSpec>[_spec('sim-auto-kr_order')]),
      throwsArgumentError,
    );
    expect(r.calls, isEmpty);
  });

  test('기동 보정 — 지금 접두 아닌 · 멈추지 않은 · 알려진 접두만(슬러그 순) · 다시 돌리면 0(멱등)', () async {
    final List<RemoteCheck> all = <RemoteCheck>[
      _c('sim-auto-kr_order'),
      _c('sim-advisory-kr_order', RemoteCheckStatus.fresh),
      _c('sim-auto-daily_data', RemoteCheckStatus.paused),
      _c('live-auto-kr_order'),
      _c('backup_age'),
      _c('engine_alive'),
    ];
    expect(pendingOldModePauses(all, currentPrefix: 'live-auto'), <String>[
      'sim-advisory-kr_order',
      'sim-auto-kr_order',
    ]);
    final FakeWatchdogRemote r = FakeWatchdogRemote(initial: all);
    expect(
      await repairOldModePauses(
        r,
        await r.checks(),
        currentPrefix: 'live-auto',
      ),
      isEmpty,
    );
    expect(
      pendingOldModePauses(await r.checks(), currentPrefix: 'live-auto'),
      isEmpty,
    );
    final FakeWatchdogRemote q = FakeWatchdogRemote(initial: all);
    q.failOn[('pause', 'sim-auto-kr_order')] = Exception('z');
    expect(
      await repairOldModePauses(
        q,
        await q.checks(),
        currentPrefix: 'live-auto',
      ),
      <String>['sim-auto-kr_order'],
    );
  });
}
