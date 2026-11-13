// E14b — `planned_work` 상태기계 · 재개 항목 판정 · 방향 · 허용 · 플래그 해제 · 계절 선택(설계 13 §8 R72 J3~J7).
//
// 🔵 잡는 것: ① 전이 표(같은 상태 · 종단 · PLANNED 로 되돌림 · 기한 뒤 = EXPIRED 만 · 기한 전 EXPIRED 불가 ·
//    DONE = PLANNED 에서만 · 같은 날 = 유효) · 🔴 기한 뒤 DONE = 어떤 출발점에서도 거부 ② 판정 차례 ①~⑦ ·
//    재판정 ⑧ · 판정 결과의 전이가 표에서 허용 ③ 모드별 자동 허용 표 ④ 멈출 사유 차례 · 해제 ⑤ 우선순위 ·
//    매도 먼저 ⑥ 계절 선택 거부 차례 · 건너뛰기는 멈춰도 받음 · 결과
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

const TradeDate _today = TradeDate('2026-11-20');

ResumeWorkItem _item({
  String id = 'pw_1',
  String kind = ResumeWorkKinds.monthlyPlan,
  PlannedWorkState state = PlannedWorkState.planned,
  String due = '2026-11-25',
  ResumeDirection dir = ResumeDirection.rebalance,
  bool sell = false,
}) => ResumeWorkItem(
  workId: id,
  kind: kind,
  oneLine: '11월 정기 리밸런싱',
  state: state,
  plannedOn: const TradeDate('2026-11-02'),
  dueBy: TradeDate(due),
  direction: dir,
  sell: sell,
);

ResumePreconditions _pre({int recon = 0, int unknown = 0, int residual = 0}) =>
    ResumePreconditions(
      reconMismatches: recon,
      unknownOrders: unknown,
      residualOrders: residual,
    );

ResumeItemStep _judge(
  ResumeWorkItem item, {
  ResumeMode mode = ResumeMode.normal,
  bool advisory = false,
  ResumePreconditions? pre,
}) => judgeResumeItem(
  item: item,
  today: _today,
  mode: mode,
  advisory: advisory,
  preconditions: pre ?? _pre(),
);

(PlannedWorkState, String, String) _decided(ResumeItemStep s) {
  final ResumeItemJudgement j = (s as ResumeItemDecided).judgement;
  return (j.nextState, j.verdictCode, j.reasonCode);
}

String? _tr(
  PlannedWorkState from,
  PlannedWorkState to, {
  String due = '2026-11-25',
}) => plannedWorkTransitionRejectCode(
  from: from,
  to: to,
  dueBy: TradeDate(due),
  today: _today,
);

void main() {
  group('상태기계', () {
    test('같은 상태 = 전이 아님 · 종단에서 못 나감 · PLANNED 로 못 돌아감', () {
      for (final PlannedWorkState s in PlannedWorkState.values) {
        expect(_tr(s, s), PlannedWorkCodes.unchanged, reason: s.wire);
      }
      for (final PlannedWorkState t in kPlannedWorkTerminal) {
        for (final PlannedWorkState to in PlannedWorkState.values) {
          if (to == t) continue;
          expect(_tr(t, to), PlannedWorkCodes.terminal, reason: t.wire);
        }
      }
      expect(kPlannedWorkTerminal, hasLength(4));
      expect(kPlannedWorkTerminal, isNot(contains(PlannedWorkState.planned)));
      expect(kPlannedWorkTerminal, isNot(contains(PlannedWorkState.blocked)));
      expect(
        _tr(PlannedWorkState.blocked, PlannedWorkState.planned),
        PlannedWorkCodes.illegal,
      );
    });

    test('기한 전 — 허용 표', () {
      for (final PlannedWorkState to in <PlannedWorkState>[
        PlannedWorkState.reevaluated,
        PlannedWorkState.superseded,
        PlannedWorkState.blocked,
        PlannedWorkState.done,
      ]) {
        expect(_tr(PlannedWorkState.planned, to), isNull, reason: to.wire);
      }
      for (final PlannedWorkState to in <PlannedWorkState>[
        PlannedWorkState.reevaluated,
        PlannedWorkState.superseded,
      ]) {
        expect(_tr(PlannedWorkState.blocked, to), isNull, reason: to.wire);
      }
      expect(
        _tr(PlannedWorkState.blocked, PlannedWorkState.done),
        PlannedWorkCodes.illegal,
      );
      expect(
        _tr(PlannedWorkState.planned, PlannedWorkState.expired),
        PlannedWorkCodes.notDue,
      );
      expect(
        _tr(PlannedWorkState.blocked, PlannedWorkState.expired),
        PlannedWorkCodes.notDue,
      );
    });

    test('같은 날 = 아직 유효(due_by 포함)', () {
      expect(plannedWorkPastDue(dueBy: _today, today: _today), isFalse);
      expect(
        _tr(PlannedWorkState.planned, PlannedWorkState.done, due: '2026-11-20'),
        isNull,
      );
      expect(
        plannedWorkPastDue(dueBy: const TradeDate('2026-11-19'), today: _today),
        isTrue,
      );
    });

    test('🔴 기한 뒤 = EXPIRED 만 · DONE 은 어떤 출발점에서도 거부', () {
      expect(
        _tr(
          PlannedWorkState.planned,
          PlannedWorkState.expired,
          due: '2026-11-19',
        ),
        isNull,
      );
      expect(
        _tr(
          PlannedWorkState.blocked,
          PlannedWorkState.expired,
          due: '2026-11-19',
        ),
        isNull,
      );
      for (final PlannedWorkState from in PlannedWorkState.values) {
        if (from == PlannedWorkState.done) continue;
        expect(
          _tr(from, PlannedWorkState.done, due: '2026-11-19'),
          isNotNull,
          reason: from.wire,
        );
      }
      for (final PlannedWorkState to in <PlannedWorkState>[
        PlannedWorkState.done,
        PlannedWorkState.reevaluated,
        PlannedWorkState.superseded,
        PlannedWorkState.blocked,
      ]) {
        expect(
          _tr(PlannedWorkState.planned, to, due: '2026-11-19'),
          PlannedWorkCodes.pastDue,
          reason: to.wire,
        );
      }
      expect(
        _tr(
          PlannedWorkState.blocked,
          PlannedWorkState.reevaluated,
          due: '2026-11-19',
        ),
        PlannedWorkCodes.pastDue,
      );
    });
  });

  group('항목 판정', () {
    test('① 종단 = 건드리지 않음', () {
      for (final PlannedWorkState s in kPlannedWorkTerminal) {
        expect(
          _judge(
            _item(state: s, due: '2026-11-01'),
            mode: ResumeMode.recoveryFull,
            advisory: true,
          ),
          isA<ResumeItemUntouched>(),
          reason: s.wire,
        );
      }
    });

    test('② 기한 뒤 = EXPIRED(모드 · 안내 · 전제보다 먼저)', () {
      final (PlannedWorkState, String, String) want = (
        PlannedWorkState.expired,
        VerdictCodes.expired,
        ResumeReasonCodes.duePassed,
      );
      expect(_decided(_judge(_item(due: '2026-11-19'))), want);
      expect(
        _decided(
          _judge(
            _item(state: PlannedWorkState.blocked, due: '2026-11-19'),
            mode: ResumeMode.recoveryFull,
            advisory: true,
            pre: _pre(recon: 1),
          ),
        ),
        want,
      );
    });

    test('③ 안내 → ④ FULL · DRY → ⑤ 전제(대사 → UNKNOWN → 잔류)', () {
      (PlannedWorkState, String, String) b(String r) =>
          (PlannedWorkState.blocked, VerdictCodes.blocked, r);
      expect(
        _decided(
          _judge(_item(), mode: ResumeMode.recoveryFull, advisory: true),
        ),
        b(ResumeReasonCodes.advisoryPending),
      );
      expect(
        _decided(
          _judge(_item(), mode: ResumeMode.recoveryFull, pre: _pre(recon: 1)),
        ),
        b(ResumeReasonCodes.safetyStop),
      );
      expect(
        _decided(
          _judge(_item(), mode: ResumeMode.recoveryDry, pre: _pre(recon: 1)),
        ),
        b(ResumeReasonCodes.observing),
      );
      expect(
        _decided(_judge(_item(), pre: _pre(recon: 1, unknown: 1, residual: 1))),
        b(ResumeReasonCodes.reconMismatch),
      );
      expect(
        _decided(_judge(_item(), pre: _pre(unknown: 2, residual: 1))),
        b(ResumeReasonCodes.unknownOrders),
      );
      expect(
        _decided(
          _judge(
            _item(),
            mode: ResumeMode.conservative,
            pre: _pre(residual: 1),
          ),
        ),
        b(ResumeReasonCodes.residualOrders),
      );
    });

    test('⑥ 계절 A 진입 = 사람 결정(보수 모드에서도) · 청산 = 재판정', () {
      final ResumeWorkItem entry = _item(
        kind: ResumeWorkKinds.seasonalWindow,
        dir: ResumeDirection.entry,
      );
      expect(entry.seasonalEntry, isTrue);
      for (final ResumeMode m in <ResumeMode>[
        ResumeMode.normal,
        ResumeMode.conservative,
      ]) {
        expect(_decided(_judge(entry, mode: m)), (
          PlannedWorkState.blocked,
          VerdictCodes.blocked,
          ResumeReasonCodes.humanDecision,
        ), reason: m.wire);
      }
      final ResumeWorkItem exit = _item(
        kind: ResumeWorkKinds.seasonalWindow,
        dir: ResumeDirection.defensive,
        sell: true,
      );
      expect(exit.seasonalEntry, isFalse);
      expect(
        _judge(exit, mode: ResumeMode.conservative),
        isA<ResumeItemNeedsReevaluation>(),
      );
      // 계절 창이 아닌 신규 진입 = 사람 결정 아님.
      expect(
        _item(
          kind: ResumeWorkKinds.carryOver,
          dir: ResumeDirection.entry,
        ).seasonalEntry,
        isFalse,
      );
    });

    test('⑦ 보수 모드 = 정기 리밸런싱 · 신규 진입은 다음 정기 회차 · 방어 · 차단 해소는 재판정', () {
      for (final ResumeDirection d in <ResumeDirection>[
        ResumeDirection.rebalance,
        ResumeDirection.entry,
      ]) {
        expect(_decided(_judge(_item(dir: d), mode: ResumeMode.conservative)), (
          PlannedWorkState.superseded,
          VerdictCodes.superseded,
          ResumeReasonCodes.conservativeDefer,
        ), reason: d.name);
      }
      for (final ResumeDirection d in <ResumeDirection>[
        ResumeDirection.unblock,
        ResumeDirection.defensive,
      ]) {
        expect(
          _judge(_item(dir: d), mode: ResumeMode.conservative),
          isA<ResumeItemNeedsReevaluation>(),
          reason: d.name,
        );
      }
      for (final ResumeDirection d in ResumeDirection.values) {
        expect(
          _judge(_item(dir: d, state: PlannedWorkState.blocked)),
          isA<ResumeItemNeedsReevaluation>(),
          reason: d.name,
        );
      }
    });

    test('⑧ 재판정 — 할 일 있음 = 위임 · 없음 = 대체(원행 REEVALUATED)', () {
      final ResumeItemJudgement yes = reevaluatedJudgement(actionNeeded: true);
      expect(yes.nextState, PlannedWorkState.reevaluated);
      expect(yes.verdictCode, VerdictCodes.executedAsReevaluated);
      expect(yes.reasonCode, ResumeReasonCodes.reevaluated);
      expect(yes.delegates, isTrue);
      final ResumeItemJudgement no = reevaluatedJudgement(actionNeeded: false);
      expect(no.nextState, PlannedWorkState.reevaluated);
      expect(no.verdictCode, VerdictCodes.superseded);
      expect(no.reasonCode, ResumeReasonCodes.reevaluatedEmpty);
      expect(no.delegates, isFalse);
    });

    test('🔴 판정 결과의 전이 = 상태기계가 허용(어떤 입력에서도)', () {
      final List<ResumeItemJudgement> after = <ResumeItemJudgement>[
        reevaluatedJudgement(actionNeeded: true),
        reevaluatedJudgement(actionNeeded: false),
      ];
      for (final PlannedWorkState s in <PlannedWorkState>[
        PlannedWorkState.planned,
        PlannedWorkState.blocked,
      ]) {
        for (final String due in <String>['2026-11-19', '2026-11-20']) {
          for (final ResumeMode m in ResumeMode.values) {
            for (final bool adv in <bool>[false, true]) {
              for (final ResumePreconditions p in <ResumePreconditions>[
                _pre(),
                _pre(unknown: 1),
              ]) {
                for (final ResumeDirection d in ResumeDirection.values) {
                  for (final String kind in <String>[
                    ResumeWorkKinds.monthlyPlan,
                    ResumeWorkKinds.seasonalWindow,
                  ]) {
                    final ResumeItemStep st = _judge(
                      _item(state: s, due: due, dir: d, kind: kind),
                      mode: m,
                      advisory: adv,
                      pre: p,
                    );
                    final List<ResumeItemJudgement> js = switch (st) {
                      ResumeItemDecided(:final ResumeItemJudgement judgement) =>
                        <ResumeItemJudgement>[judgement],
                      ResumeItemNeedsReevaluation() => after,
                      ResumeItemUntouched() => <ResumeItemJudgement>[],
                    };
                    for (final ResumeItemJudgement j in js) {
                      if (j.nextState == s) continue;
                      expect(
                        _tr(s, j.nextState, due: due),
                        isNull,
                        reason: '$s $due $m $adv $d $kind ${j.reasonCode}',
                      );
                    }
                  }
                }
              }
            }
          }
        }
      }
    });
  });

  group('허용 · 멈춤 · 우선순위', () {
    test('모드별 자동 허용 표', () {
      for (final ResumeDirection d in ResumeDirection.values) {
        expect(resumeAutoAllows(ResumeMode.normal, d), isTrue);
        expect(resumeAutoAllows(ResumeMode.recoveryDry, d), isFalse);
        expect(resumeAutoAllows(ResumeMode.recoveryFull, d), isFalse);
      }
      expect(
        ResumeDirection.values
            .where(
              (ResumeDirection d) =>
                  resumeAutoAllows(ResumeMode.conservative, d),
            )
            .toList(),
        <ResumeDirection>[ResumeDirection.unblock, ResumeDirection.defensive],
      );
    });

    test('멈출 사유 차례 · 플래그 해제 = 사유 없을 때만', () {
      String? h(ResumeMode m, {bool adv = false, ResumePreconditions? p}) =>
          resumeHaltReason(mode: m, advisory: adv, preconditions: p ?? _pre());
      expect(h(ResumeMode.normal), isNull);
      expect(h(ResumeMode.conservative), isNull);
      expect(
        h(ResumeMode.normal, adv: true),
        ResumeReasonCodes.advisoryPending,
      );
      expect(
        h(ResumeMode.recoveryFull, adv: true),
        ResumeReasonCodes.advisoryPending,
      );
      expect(
        h(ResumeMode.recoveryFull, p: _pre(recon: 1)),
        ResumeReasonCodes.safetyStop,
      );
      expect(
        h(ResumeMode.recoveryDry, p: _pre(recon: 1)),
        ResumeReasonCodes.observing,
      );
      expect(
        h(ResumeMode.normal, p: _pre(residual: 3)),
        ResumeReasonCodes.residualOrders,
      );
      bool rel(ResumeMode m, {bool adv = false, ResumePreconditions? p}) =>
          resumeReleasesFlag(
            mode: m,
            advisory: adv,
            preconditions: p ?? _pre(),
          );
      expect(rel(ResumeMode.normal), isTrue);
      expect(rel(ResumeMode.conservative), isTrue);
      expect(rel(ResumeMode.recoveryDry), isFalse);
      expect(rel(ResumeMode.recoveryFull), isFalse);
      expect(rel(ResumeMode.normal, adv: true), isFalse);
      expect(rel(ResumeMode.normal, p: _pre(unknown: 1)), isFalse);
    });

    test('전제 — 음수 = 오류 · 성립 = null', () {
      expect(_pre().failureCode, isNull);
      expect(() => _pre(recon: -1), throwsArgumentError);
      expect(() => _pre(unknown: -1), throwsArgumentError);
      expect(() => _pre(residual: -1), throwsArgumentError);
    });

    test('우선순위 = 차단 해소 → 방어 → 정기 리밸런싱 → 신규 진입 · 매도 먼저 · work_id', () {
      final List<ResumeWorkItem> items = <ResumeWorkItem>[
        _item(id: 'e1', dir: ResumeDirection.entry),
        _item(id: 'r2', dir: ResumeDirection.rebalance),
        _item(id: 'r1', dir: ResumeDirection.rebalance),
        _item(id: 'r3', dir: ResumeDirection.rebalance, sell: true),
        _item(id: 'd1', dir: ResumeDirection.defensive, sell: true),
        _item(id: 'u1', dir: ResumeDirection.unblock),
      ];
      expect(
        resumePriorityOrder(items).map((ResumeWorkItem i) => i.workId).toList(),
        <String>['u1', 'd1', 'r3', 'r1', 'r2', 'e1'],
      );
      expect(items.first.workId, 'e1'); // 원본은 그대로
    });
  });

  test('🆕 E14d2b 축소 진입 = 원 목표 × 0.5 내림(발주자 결정) · 음수 = 오류', () {
    expect(kSeasonalReducedEntryRatio, 0.5);
    expect(seasonalReducedShares(200), 100);
    expect(seasonalReducedShares(7), 3);
    expect(seasonalReducedShares(1), 0);
    expect(seasonalReducedShares(0), 0);
    expect(() => seasonalReducedShares(-1), throwsArgumentError);
  });

  group('계절 선택', () {
    final ResumeWorkItem entry = _item(
      kind: ResumeWorkKinds.seasonalWindow,
      dir: ResumeDirection.entry,
      state: PlannedWorkState.blocked,
    );

    String? rej(
      ResumeWorkItem item,
      SeasonalWindowChoice c, {
      String decision = 'dec_1',
      ResumeMode mode = ResumeMode.normal,
      bool adv = false,
      ResumePreconditions? p,
    }) => seasonalChoiceRejectCode(
      item: item,
      choice: c,
      decisionId: decision,
      today: _today,
      mode: mode,
      advisory: adv,
      preconditions: p ?? _pre(),
    );

    test('거부 차례 — decision_id → 진입 아님 → 종단 → 기한 → 멈춤(건너뛰기 빼고)', () {
      expect(
        rej(_item(), SeasonalWindowChoice.skip, decision: ' '),
        SeasonalChoiceCodes.decisionMissing,
      );
      expect(
        rej(_item(), SeasonalWindowChoice.skip),
        SeasonalChoiceCodes.notSeasonalEntry,
      );
      expect(
        rej(
          _item(
            kind: ResumeWorkKinds.seasonalWindow,
            dir: ResumeDirection.entry,
            state: PlannedWorkState.expired,
            due: '2026-11-19',
          ),
          SeasonalWindowChoice.skip,
        ),
        SeasonalChoiceCodes.notPending,
      );
      expect(
        rej(
          _item(
            kind: ResumeWorkKinds.seasonalWindow,
            dir: ResumeDirection.entry,
            due: '2026-11-19',
          ),
          SeasonalWindowChoice.asIs,
        ),
        SeasonalChoiceCodes.pastDue,
      );
      for (final SeasonalWindowChoice c in SeasonalWindowChoice.values) {
        expect(rej(entry, c), isNull, reason: c.name);
      }
      expect(
        rej(entry, SeasonalWindowChoice.skip, mode: ResumeMode.recoveryFull),
        isNull,
      );
      expect(
        rej(entry, SeasonalWindowChoice.reduced, mode: ResumeMode.recoveryFull),
        ResumeReasonCodes.safetyStop,
      );
      expect(
        rej(entry, SeasonalWindowChoice.asIs, p: _pre(unknown: 1)),
        ResumeReasonCodes.unknownOrders,
      );
      expect(
        rej(entry, SeasonalWindowChoice.asIs, adv: true),
        ResumeReasonCodes.advisoryPending,
      );
    });

    test('결과 — 건너뛰기 = 대체 · 축소 · 그대로 = 재판정 위임', () {
      ResumeItemJudgement j(SeasonalWindowChoice c) =>
          seasonalChoiceJudgement(c);
      expect(
        j(SeasonalWindowChoice.skip).nextState,
        PlannedWorkState.superseded,
      );
      expect(j(SeasonalWindowChoice.skip).verdictCode, VerdictCodes.superseded);
      expect(
        j(SeasonalWindowChoice.skip).reasonCode,
        ResumeReasonCodes.humanSkip,
      );
      expect(
        j(SeasonalWindowChoice.reduced).nextState,
        PlannedWorkState.reevaluated,
      );
      expect(j(SeasonalWindowChoice.reduced).delegates, isTrue);
      expect(
        j(SeasonalWindowChoice.reduced).reasonCode,
        ResumeReasonCodes.humanReduced,
      );
      expect(
        j(SeasonalWindowChoice.asIs).nextState,
        PlannedWorkState.reevaluated,
      );
      expect(j(SeasonalWindowChoice.asIs).delegates, isTrue);
      expect(
        j(SeasonalWindowChoice.asIs).reasonCode,
        ResumeReasonCodes.humanAsIs,
      );
      for (final SeasonalWindowChoice c in SeasonalWindowChoice.values) {
        expect(
          _tr(PlannedWorkState.blocked, j(c).nextState),
          isNull,
          reason: c.name,
        );
      }
    });
  });
}
