// E16b — X1-2 계획 교체: 시작 판정 · 옛 폰 단계 상태기계 · 단계 완료 조건 · 동결 리스 합성(설계 13 §8 R117).
//
// 🔵 잡는 것: ① 시작 거부 차례(live 만 · 안내 모드 hold · D-03 · 선언 · 신뢰 시각) ② 단계 9 차례 · 실패 가능 = DEMOTED 앞
//    ③ 저널 → 다음 할 일(들어감 · 크래시 재개 · 중단 · 끝) ④ 깨진 저널 = StateError(구멍 · 끝나지 않은 단계 뒤 ·
//    들어가지 않은 끝 · 끝 + 실패 · DEMOTED 뒤 실패 · 다른 이전 · 같은 행 둘) ⑤ 완료 조건(미체결 · UNKNOWN · 대사 · 백업 체인)
//    ⑥ 동결 중 주문 리스 = 무효 · 중단 = 원래 판정.
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _run = 'mig-2026-12-01-1';
final DateTime _t = DateTime.utc(2026, 12, 1, 1);

MigrationStepRow _r(PlanStep s, MigrationStepState st, {String run = _run}) =>
    MigrationStepRow(runId: run, step: s.wire, state: st.wire, atUtc: _t);

/// [upTo] 까지 들어감 + 끝.
List<MigrationStepRow> _doneThrough(PlanStep upTo) => <MigrationStepRow>[
  for (final PlanStep s in PlanStep.values.take(
    upTo.index + 1,
  )) ...<MigrationStepRow>[
    _r(s, MigrationStepState.entered),
    _r(s, MigrationStepState.done),
  ],
];

PlanProgress _p(Iterable<MigrationStepRow> rows) => planProgressOf(_run, rows);

const PlanStepFacts _clean = PlanStepFacts(
  openOrders: 0,
  unknownOrders: 0,
  reconMismatches: 0,
  currentChainHash: 'c1',
  backupChainHash: 'c1',
);

void main() {
  group('시작 판정', () {
    String? start({
      MigrationKind kind = MigrationKind.plan,
      RunMode run = RunMode.live,
      OperatingMode op = OperatingMode.autoTrade,
      String? decision = 'dec-d03',
      DateTime? now,
      bool timeUnknown = false,
    }) => migrationStartRejectCode(
      kind: kind,
      runMode: run,
      operatingMode: op,
      decisionId: decision,
      trustedNowUtc: timeUnknown ? null : (now ?? _t),
    );

    test('🔴 live 가 아니면 X1_LIVE_ONLY(다른 결함보다 먼저)', () {
      for (final RunMode m in <RunMode>[
        RunMode.simInternal,
        RunMode.simBroker,
      ]) {
        expect(
          start(run: m, op: OperatingMode.advisory, decision: null),
          MigrationStartCodes.liveOnly,
        );
      }
    });

    test('🔴 안내 모드 = X1_ADVISORY_PENDING hold', () {
      expect(
        start(op: OperatingMode.advisory, decision: null),
        MigrationStartCodes.advisoryPending,
      );
    });

    test('🔴 D-03 확인 없음 = 계획 교체 시작 거부 · 빈 글자도 · 비상 = 선언 없음', () {
      expect(start(decision: null), MigrationStartCodes.d03NotConfirmed);
      expect(start(decision: '  '), MigrationStartCodes.d03NotConfirmed);
      expect(
        start(kind: MigrationKind.emergency, decision: null),
        MigrationStartCodes.emergencyNotDeclared,
      );
    });

    test('신뢰 시각 모름 = 거부 · 다 갖추면 통과', () {
      expect(start(timeUnknown: true), MigrationStartCodes.trustedTimeUnknown);
      expect(start(), isNull);
      expect(start(kind: MigrationKind.emergency, decision: 'dec-em'), isNull);
    });

    test('이전 id — 한국 날 · 순번 1 이상', () {
      expect(
        migrationRunIdOf(DateTime.utc(2026, 11, 30, 15), 1),
        'mig-2026-12-01-1',
      );
      expect(
        migrationRunIdOf(DateTime.utc(2026, 11, 30, 14, 59), 2),
        'mig-2026-11-30-2',
      );
      expect(() => migrationRunIdOf(_t, 0), throwsArgumentError);
    });
  });

  test('단계 9 차례 · 글자 · 실패 가능 = DEMOTED 앞 넷 · 글자 왕복', () {
    expect(PlanStep.values.map((PlanStep s) => s.wire), <String>[
      'FREEZE',
      'ORDERS_CLEARED',
      'RECON_ZERO',
      'BACKUP_CHECKSUM',
      'DEMOTED',
      'KEYS_DELETED',
      'RETIRED',
      'SERVICE_STOPPED',
      'TICKET_ISSUED',
    ]);
    expect(PlanStep.values.where((PlanStep s) => s.mayFail), <PlanStep>[
      PlanStep.freeze,
      PlanStep.ordersCleared,
      PlanStep.reconZero,
      PlanStep.backupChecksum,
    ]);
    for (final PlanStep s in PlanStep.values) {
      expect(PlanStep.parse(s.wire), s);
    }
    expect(() => PlanStep.parse('D03_CONFIRMED'), throwsFormatException);
    expect(MigrationKind.values.map((MigrationKind k) => k.wire), <String>[
      'PLAN',
      'EMERGENCY',
    ]);
    expect(MigrationRole.values.map((MigrationRole r) => r.wire), <String>[
      'OLD_DEVICE',
      'NEW_DEVICE',
    ]);
  });

  group('저널 → 다음 할 일', () {
    test('빈 저널 = FREEZE 들어감 · 동결 아님', () {
      final PlanProgress p = _p(const <MigrationStepRow>[]);
      expect((planNextOf(p) as PlanEnter).step, PlanStep.freeze);
      expect(p.frozen, isFalse);
      expect(p.pastNoReturn, isFalse);
    });

    test('🔴 들어가고 끝나지 않음 = 크래시 → 같은 단계 재개 · 동결 중', () {
      final PlanProgress p = _p(<MigrationStepRow>[
        _r(PlanStep.freeze, MigrationStepState.entered),
      ]);
      expect((planNextOf(p) as PlanResume).step, PlanStep.freeze);
      expect(p.frozen, isTrue);
    });

    test('끝난 단계 다음 = 다음 단계 들어감', () {
      final PlanProgress p = _p(_doneThrough(PlanStep.reconZero));
      expect((planNextOf(p) as PlanEnter).step, PlanStep.backupChecksum);
      expect(p.isDone(PlanStep.ordersCleared), isTrue);
      expect(p.isDone(PlanStep.backupChecksum), isFalse);
      expect(p.pastNoReturn, isFalse);
    });

    test('🔴 DEMOTED 에서 크래시 = 재개 · 되돌릴 수 없는 점을 넘음', () {
      final PlanProgress p = _p(<MigrationStepRow>[
        ..._doneThrough(PlanStep.backupChecksum),
        _r(PlanStep.demoted, MigrationStepState.entered),
      ]);
      expect((planNextOf(p) as PlanResume).step, PlanStep.demoted);
      expect(p.pastNoReturn, isTrue);
    });

    test('끝까지 = 끝 · 동결 그대로(옛 폰은 다시 매매하지 않는다)', () {
      final PlanProgress p = _p(_doneThrough(PlanStep.ticketIssued));
      expect(planNextOf(p), isA<PlanComplete>());
      expect(p.complete, isTrue);
      expect(p.frozen, isTrue);
    });

    test('🔴 DEMOTED 앞 실패 = 이 이전 중단 · 동결 풀림', () {
      final PlanProgress p = _p(<MigrationStepRow>[
        ..._doneThrough(PlanStep.ordersCleared),
        _r(PlanStep.reconZero, MigrationStepState.entered),
        _r(PlanStep.reconZero, MigrationStepState.failed),
      ]);
      expect((planNextOf(p) as PlanAborted).failedStep, PlanStep.reconZero);
      expect(p.frozen, isFalse);
    });
  });

  group('깨진 저널 = StateError', () {
    void broken(List<MigrationStepRow> rows) =>
        expect(() => _p(rows), throwsStateError);

    test('구멍 — 앞 단계 행 없이 뒤 단계', () {
      broken(<MigrationStepRow>[
        ..._doneThrough(PlanStep.freeze),
        _r(PlanStep.reconZero, MigrationStepState.entered),
      ]);
    });

    test('끝나지 않은 단계 뒤에 행 · 실패 뒤에 행', () {
      broken(<MigrationStepRow>[
        _r(PlanStep.freeze, MigrationStepState.entered),
        _r(PlanStep.ordersCleared, MigrationStepState.entered),
      ]);
      broken(<MigrationStepRow>[
        _r(PlanStep.freeze, MigrationStepState.entered),
        _r(PlanStep.freeze, MigrationStepState.failed),
        _r(PlanStep.ordersCleared, MigrationStepState.entered),
      ]);
    });

    test('들어가지 않은 끝 · 끝과 실패 함께', () {
      broken(<MigrationStepRow>[_r(PlanStep.freeze, MigrationStepState.done)]);
      broken(<MigrationStepRow>[
        _r(PlanStep.freeze, MigrationStepState.entered),
        _r(PlanStep.freeze, MigrationStepState.done),
        _r(PlanStep.freeze, MigrationStepState.failed),
      ]);
    });

    test('🔴 DEMOTED 부터 실패 행 = 깨진 저널(재승격 0)', () {
      for (final PlanStep s in PlanStep.values.where(
        (PlanStep s) => !s.mayFail,
      )) {
        broken(<MigrationStepRow>[
          ..._doneThrough(PlanStep.values[s.index - 1]),
          _r(s, MigrationStepState.entered),
          _r(s, MigrationStepState.failed),
        ]);
      }
    });

    test('다른 이전 행 · 같은 단계 같은 상태 둘', () {
      broken(<MigrationStepRow>[
        _r(PlanStep.freeze, MigrationStepState.entered, run: 'mig-x'),
      ]);
      broken(<MigrationStepRow>[
        _r(PlanStep.freeze, MigrationStepState.entered),
        _r(PlanStep.freeze, MigrationStepState.entered),
      ]);
    });

    test('모르는 단계 · 상태 글자 = FormatException', () {
      expect(
        () => _p(<MigrationStepRow>[
          MigrationStepRow(runId: _run, step: 'X', state: 'ENTERED', atUtc: _t),
        ]),
        throwsFormatException,
      );
      expect(
        () => _p(<MigrationStepRow>[
          MigrationStepRow(runId: _run, step: 'FREEZE', state: 'X', atUtc: _t),
        ]),
        throwsFormatException,
      );
    });
  });

  group('단계 완료 조건', () {
    PlanStepFacts f({
      int open = 0,
      int unknown = 0,
      int recon = 0,
      String? cur = 'c1',
      String? backup = 'c1',
    }) => PlanStepFacts(
      openOrders: open,
      unknownOrders: unknown,
      reconMismatches: recon,
      currentChainHash: cur,
      backupChainHash: backup,
    );

    test('🔴 미체결 · UNKNOWN 0 이어야 ORDERS_CLEARED', () {
      expect(
        planStepBlockCode(PlanStep.ordersCleared, f(open: 1)),
        PlanBlockCodes.openOrders,
      );
      expect(
        planStepBlockCode(PlanStep.ordersCleared, f(unknown: 1)),
        PlanBlockCodes.unknownOrders,
      );
      expect(planStepBlockCode(PlanStep.ordersCleared, _clean), isNull);
    });

    test('🔴 대사 0오차 · 백업 체인 = 지금 체인', () {
      expect(
        planStepBlockCode(PlanStep.reconZero, f(recon: 1)),
        PlanBlockCodes.reconNotZero,
      );
      expect(planStepBlockCode(PlanStep.reconZero, _clean), isNull);
      expect(
        planStepBlockCode(PlanStep.backupChecksum, f(backup: null)),
        PlanBlockCodes.backupMissing,
      );
      expect(
        planStepBlockCode(PlanStep.backupChecksum, f(backup: 'c0')),
        PlanBlockCodes.backupChainMismatch,
      );
      expect(planStepBlockCode(PlanStep.backupChecksum, _clean), isNull);
    });

    test('사실이 필요 없는 단계 = 늘 통과', () {
      final PlanStepFacts dirty = f(
        open: 3,
        unknown: 2,
        recon: 1,
        backup: null,
      );
      for (final PlanStep s in <PlanStep>[
        PlanStep.freeze,
        PlanStep.demoted,
        PlanStep.keysDeleted,
        PlanStep.retired,
        PlanStep.serviceStopped,
        PlanStep.ticketIssued,
      ]) {
        expect(planStepBlockCode(s, dirty), isNull, reason: s.wire);
      }
    });
  });

  test('🔴 동결 중 주문 리스 = 무효 · 이전 없음 · 중단 = 원래 판정', () {
    expect(
      orderLeaseDuringMigration(LeaseVerdict.valid, null),
      LeaseVerdict.valid,
    );
    final PlanProgress frozen = _p(<MigrationStepRow>[
      _r(PlanStep.freeze, MigrationStepState.entered),
    ]);
    expect(
      orderLeaseDuringMigration(LeaseVerdict.valid, frozen),
      LeaseVerdict.invalid,
    );
    expect(
      orderLeaseDuringMigration(LeaseVerdict.unknown, frozen),
      LeaseVerdict.invalid,
    );
    final PlanProgress aborted = _p(<MigrationStepRow>[
      _r(PlanStep.freeze, MigrationStepState.entered),
      _r(PlanStep.freeze, MigrationStepState.failed),
    ]);
    expect(
      orderLeaseDuringMigration(LeaseVerdict.valid, aborted),
      LeaseVerdict.valid,
    );
    expect(
      orderLeaseDuringMigration(
        LeaseVerdict.valid,
        _p(_doneThrough(PlanStep.ticketIssued)),
      ),
      LeaseVerdict.invalid,
    );
  });
}
