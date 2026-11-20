// E11q-c1 — M5-11 simToAuto 위저드 VM · S1 체험 카드 · 동작 결과 글자(설계 13 §8 R191 · 01 §35 K167~K176 · 미결 207 ⓓ).
//
// 🔴 표본 `m5/handover_wizard_*` 와 머리 · 수준 · 코드 · 단계 · 행 수준 · 동작(id · args · 글자) · 시각 글자가 같다(«(합성)» 표지 제외) ·
//    표본과 다른 두 곳 = 엔진 규칙(링크 = 막힘 · 아직 단계만 — `s3_blocked` 의 PASS 단계 링크 2 · 확정 뒤 단계 글자 — 모의 원문 대신
//    «마침» · 생체 · 확정 시각) · 결과 표본 `m5/handover_sim_to_auto_action_results` 수준 · 글자 같음 · 단계별 허용 동작(C-60 ③).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final LiveObservationConfig _two = LiveObservationConfig(
  requiredTradingDays: 2,
);

List<Map<String, Object?>> _rows(String f) => <Map<String, Object?>>[
  for (final Object? r
      in (jsonDecode(
            File('../domain_contracts/fixtures/m5/$f.json').readAsStringSync(),
          ) as Map<String, Object?>)['rows']!
          as List<Object?>)
    r! as Map<String, Object?>,
];

HandoverWizardVm _fx(String name) =>
    HandoverWizardVm.fromJson(_rows('handover_wizard_$name').single);

String _plain(String s) => s.replaceFirst('(합성) ', '');
String? _plainOr(String? s) => s == null ? null : _plain(s);

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

const SimTrialReport _done = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: true,
  needsWarning: false,
  counters: SimTrialCounters.zero,
  headline: '체험 5항목을 모두 채웠습니다.',
);

/// 표본 `trial_incomplete` 의 체험(남은 항목 2 · 소프트 ② 아직).
const SimTrialReport _open = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[
    SimTrialItemResult(
      SimTrialItem.twoTradingWeeks,
      SimTrialItemState.open,
      '연속 정상 배치 6/10세션',
    ),
    SimTrialItemResult(
      SimTrialItem.monthEndRebalance,
      SimTrialItemState.openWarn,
      '아직 없음 — 다음 정기 리밸런싱 2026-09-01 08:00 · 건너뛰면 경고 후 진행',
    ),
    SimTrialItemResult(
      SimTrialItem.reconciliation,
      SimTrialItemState.autoPassed,
      '내부 가상 체결 — 브로커 대사 없음(자동 통과)',
    ),
    SimTrialItemResult(
      SimTrialItem.resume,
      SimTrialItemState.passed,
      '재개 1회 끝남',
    ),
    SimTrialItemResult(
      SimTrialItem.killSwitch,
      SimTrialItemState.open,
      '아직 없음',
    ),
  ],
  complete: false,
  needsWarning: true,
  counters: SimTrialCounters(
    trialDays: 9,
    batches: 6,
    rebalances: 0,
    alerts: 2,
    interventions: 0,
  ),
  headline: '모의 체험 진행 중 — 남은 항목 2개',
);

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

const String _sid = 'hs_s2a_0111';

SimToAutoFacts _facts({
  DateTime? now,
  RunMode? sim = RunMode.simInternal,
  OperatingMode? op = OperatingMode.autoTrade,
  SimTrialReport trial = _done,
  bool? golden = true,
  bool? keys = true,
  SimLedgerFate? fate = SimLedgerFate.keep,
  DateTime? opened,
  bool kill = false,
}) => SimToAutoFacts(
  trustedNowUtc: now,
  simRunMode: sim,
  simClosed: false,
  operatingMode: op,
  trial: trial,
  goldenVectorPassed: golden,
  liveKeysVerified: keys,
  accountByStrategy: _accounts,
  fate: fate,
  sessionOpenedAtUtc: opened,
  killSwitchActive: kill,
  blockingFlags: const <String>[],
);

HandoverWizardVm _vm(
  SimToAutoFacts f, {
  required DateTime observed,
  String? sessionId,
  bool approved = true,
  bool canAct = true,
  String? locked,
  HandoverCommitted? committed,
}) => handoverWizardVmOf(
  report: judgeSimToAuto(f, kr: _kr, observation: _two),
  trial: f.trial,
  fate: f.fate,
  sessionId: sessionId,
  configApproved: approved,
  canAct: canAct,
  observedAtUtc: observed,
  lockedLabel: locked,
  committed: committed,
);

/// 표본과 비교(글자 = «(합성)» 뗌) — [links] 거짓 = 링크 비교 밖 · [stepLabels] 거짓 = 단계 글자 비교 밖.
void _same(
  HandoverWizardVm vm,
  HandoverWizardVm fx, {
  bool links = true,
  bool stepLabels = true,
}) {
  expect(
    (vm.headline, vm.level, vm.reasonCode, vm.pathLabel),
    (_plain(fx.headline), fx.level, fx.reasonCode, fx.pathLabel),
  );
  expect(
    (
      vm.coolingText,
      vm.deadlineText,
      vm.windowText,
      vm.noticeText,
      vm.doneLabel,
      vm.lockedLabel,
    ),
    (
      _plainOr(fx.coolingText),
      _plainOr(fx.deadlineText),
      _plainOr(fx.windowText),
      _plainOr(fx.noticeText),
      _plainOr(fx.doneLabel),
      _plainOr(fx.lockedLabel),
    ),
  );
  expect(vm.trial, fx.trial);
  expect(vm.asOf, fx.asOf);
  expect(vm.rows.length, fx.rows.length);
  for (final (int i, HandoverWizardStepRow r) in fx.rows.indexed) {
    final HandoverWizardStepRow g = vm.rows[i];
    if (stepLabels) {
      expect(g.step, r.step, reason: 'step $i');
    } else {
      expect(
        (g.step.stepId, g.step.order, g.step.title, g.step.state),
        (r.step.stepId, r.step.order, r.step.title, r.step.state),
      );
    }
    expect(g.level, r.level, reason: 'level $i');
    if (links) {
      expect(g.link?.deepLink, r.link?.deepLink, reason: 'link $i');
      expect(g.link?.label, _plainOr(r.link?.label), reason: 'link $i');
    }
    expect(g.actions.length, r.actions.length, reason: 'actions $i');
    for (final (int j, SettingsActionCall a) in r.actions.indexed) {
      expect((g.actions[j].id, g.actions[j].label), (a.id, _plain(a.label)));
      expect(g.actions[j].args, a.args);
    }
  }
}

/// 🔴 C-60 ③ — 단계별 허용 동작 · 세션 id = args · 확정 = S7 PASS ∧ 막힘 0 · 잠김 · 확정됨 = 0.
void _allowed(HandoverWizardVm vm) {
  const Map<String, Set<SettingsActionId>>
  allow = <String, Set<SettingsActionId>>{
    'SIM_TO_AUTO_S2': <SettingsActionId>{SettingsActionId.selftestGoldenRun},
    'SIM_TO_AUTO_S5': <SettingsActionId>{
      SettingsActionId.handoverSimLedgerFate,
    },
    'SIM_TO_AUTO_S6': <SettingsActionId>{SettingsActionId.handoverSessionStart},
    'SIM_TO_AUTO_S7': <SettingsActionId>{
      SettingsActionId.handoverSessionCancel,
      SettingsActionId.handoverCommit,
    },
  };
  expect(<int>{0, 7}.contains(vm.rows.length), isTrue);
  for (final HandoverWizardStepRow r in vm.rows) {
    if (vm.lockedLabel != null || vm.doneLabel != null) {
      expect(r.actions, isEmpty);
    }
    for (final SettingsActionCall a in r.actions) {
      expect(
        allow[r.step.stepId]?.contains(a.id),
        isTrue,
        reason: '${r.step.stepId} ${a.id}',
      );
      if (a.id == SettingsActionId.handoverCommit) {
        expect(r.step.state, GateState.pass);
        expect(vm.reasonCode, isNull);
      }
      if (a.id == SettingsActionId.handoverCommit ||
          a.id == SettingsActionId.handoverSessionCancel) {
        expect(a.args.keys, <String>['handover_session_id']);
      }
    }
  }
}

void main() {
  group('위저드 = 표본', () {
    test('trial_incomplete — S1 막힘 · 체험 카드 5항목 · S2 · S3 아직 = 링크 · 동작 0', () {
      final HandoverWizardVm vm = _vm(
        _facts(
          now: _k('2026-12-28', 12),
          trial: _open,
          golden: null,
          keys: null,
          fate: null,
        ),
        observed: _k('2026-12-28', 12),
      );
      _same(vm, _fx('trial_incomplete'));
      _allowed(vm);
    });

    test('s3_blocked — S3 막힘 = 링크(엔진 규칙: 통과 단계 링크 0 · 표본 PASS 링크 2 와 다름)', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-08', 12), keys: false, fate: null),
        observed: _k('2027-01-08', 12),
      );
      final HandoverWizardVm fx = _fx('s3_blocked');
      _same(vm, fx, links: false);
      expect(
        <String?>[
          for (final HandoverWizardStepRow r in vm.rows) r.link?.deepLink,
        ],
        <String?>[
          null,
          null,
          AppRoutes.settingsCredentials,
          null,
          null,
          null,
          null,
        ],
      );
      expect(vm.rows[2].link?.label, _plain(fx.rows[2].link!.label));
      _allowed(vm);
    });

    test('fate_pending — S5 고르기 2(KEEP · DISCARD · 세션 전)', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-08', 12), fate: null),
        observed: _k('2027-01-08', 12),
      );
      _same(vm, _fx('fate_pending'));
      _allowed(vm);
    });

    test('start_ready — S6 시작 1 · 승인 config 없음 = 고지', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-08', 12)),
        observed: _k('2027-01-08', 12),
        approved: false,
      );
      _same(vm, _fx('start_ready'));
      _allowed(vm);
    });

    test('cooling — S7 냉각 = WATCH · 시각 글자 2 · 취소 1(세션 id = args)', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-11', 15), opened: _k('2027-01-11', 10)),
        observed: _k('2027-01-11', 15),
        sessionId: _sid,
      );
      _same(vm, _fx('cooling'));
      _allowed(vm);
    });

    test('commit_ready — 확정 · 취소 · 창 글자 · 머리 OK', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-12', 12), opened: _k('2027-01-11', 10)),
        observed: _k('2027-01-12', 12),
        sessionId: _sid,
      );
      _same(vm, _fx('commit_ready'));
      _allowed(vm);
    });

    test('window_blocked — 7 통과 · 커밋 창 막힘 = 확정 0 · 취소 1', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-28', 12), opened: _k('2027-01-27', 11)),
        observed: _k('2027-01-28', 12),
        sessionId: _sid,
      );
      _same(vm, _fx('window_blocked'));
      _allowed(vm);
    });

    test('expired — 기한 지남 = S6 다시 시작 · 시각 글자 0 · S7 동작 0', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-10', 12), opened: _k('2027-01-08', 10)),
        observed: _k('2027-01-10', 12),
        sessionId: _sid,
      );
      _same(vm, _fx('expired'));
      _allowed(vm);
    });

    test(
      '🔴 time_unknown — 세션 뒤 신뢰 시각 모름 = WATCH · 취소 자리 그대로 · 확정 0(K176)',
      () {
        final HandoverWizardVm vm = _vm(
          _facts(opened: _k('2027-01-11', 10)),
          observed: _k('2027-01-11', 15),
          sessionId: _sid,
        );
        _same(vm, _fx('time_unknown'));
        _allowed(vm);
      },
    );

    test('not_applicable — 전제 밖 = 단계 0 · 머리만', () {
      for (final SimToAutoFacts f in <SimToAutoFacts>[
        _facts(now: _k('2026-12-20', 12), sim: null),
        _facts(now: _k('2026-12-20', 12), op: OperatingMode.advisory),
      ]) {
        final HandoverWizardVm vm = _vm(f, observed: _k('2026-12-20', 12));
        _same(vm, _fx('not_applicable'));
        _allowed(vm);
      }
    });

    test('committed — 확정 뒤 = doneLabel · 7 통과 · 동작 0(단계 글자 = 엔진 «마침» · 생체 · 확정 시각)', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-12', 13), sim: null),
        observed: _k('2027-01-12', 13),
        committed: HandoverCommitted(
          openedAtUtc: _k('2027-01-11', 10),
          committedAtUtc: _k('2027-01-12', 12, 30),
        ),
      );
      _same(vm, _fx('committed'), stepLabels: false);
      expect(
        <String>[
          for (final HandoverWizardStepRow r in vm.rows) r.step.stateLabel,
        ],
        <String>[
          '마침',
          '마침',
          '마침',
          '마침',
          '마침',
          '생체 확인 2027-01-11 10:00',
          '확정 2027-01-12 12:30',
        ],
      );
      expect(
        _vm(
          _facts(sim: null),
          observed: _k('2027-01-12', 13),
          committed: const HandoverCommitted(),
        ).rows.map((HandoverWizardStepRow r) => r.step.stateLabel).toSet(),
        <String>{'마침'},
      );
      _allowed(vm);
    });

    test('🔴 locked — 잠김 = 모든 행 동작 0(글자 · 시각 · 창은 그대로)', () {
      final HandoverWizardVm fx = _fx('locked');
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-12', 12), opened: _k('2027-01-11', 10)),
        observed: _k('2027-01-12', 12),
        sessionId: _sid,
        locked: fx.lockedLabel,
      );
      _same(vm, fx);
      _allowed(vm);
    });
  });

  group('판정', () {
    test('🔴 쓰기 창구 없음 = 모든 동작 0 · 링크 · 글자 그대로', () {
      for (final (SimToAutoFacts f, String? sid) in <(SimToAutoFacts, String?)>[
        (_facts(now: _k('2027-01-08', 12), fate: null), null),
        (_facts(now: _k('2027-01-08', 12)), null),
        (_facts(now: _k('2027-01-12', 12), opened: _k('2027-01-11', 10)), _sid),
      ]) {
        final HandoverWizardVm on = _vm(
          f,
          observed: _k('2027-01-08', 12),
          sessionId: sid,
        );
        final HandoverWizardVm off = _vm(
          f,
          observed: _k('2027-01-08', 12),
          sessionId: sid,
          canAct: false,
        );
        expect(
          on.rows.any((HandoverWizardStepRow r) => r.actions.isNotEmpty),
          isTrue,
        );
        expect(
          off.rows.every((HandoverWizardStepRow r) => r.actions.isEmpty),
          isTrue,
        );
        expect(off.headline, on.headline);
      }
    });

    test('S5 = 고른 뒤 · 세션 뒤 · 앞 단계 막힘 = 고르기 0', () {
      HandoverWizardStepRow s5(SimToAutoFacts f, {String? sid}) =>
          _vm(f, observed: _k('2027-01-08', 12), sessionId: sid).rows[4];
      expect(
        s5(_facts(now: _k('2027-01-08', 12), fate: null)).actions,
        hasLength(2),
      );
      expect(s5(_facts(now: _k('2027-01-08', 12))).actions, isEmpty);
      expect(
        s5(_facts(now: _k('2027-01-08', 12), fate: null, golden: false))
            .actions,
        isEmpty,
      );
      expect(
        s5(_facts(now: _k('2027-01-08', 12), fate: null, keys: null)).actions,
        isEmpty,
      );
      // 🔴 세션 뒤 = 고르기 0(고름 원천이 비어 보여도 · 5단계는 세션 전 동작).
      expect(
        s5(
          _facts(
            now: _k('2027-01-11', 15),
            fate: null,
            opened: _k('2027-01-11', 10),
          ),
          sid: _sid,
        ).actions,
        isEmpty,
      );
    });

    test('S6 = 앞 단계(1~5) 통과 ∧ 세션 없음 · 세션 살아 있으면 0 · 기한 지남 = «다시»', () {
      HandoverWizardStepRow s6(SimToAutoFacts f, {String? sid}) =>
          _vm(f, observed: _k('2027-01-11', 15), sessionId: sid).rows[5];
      expect(
        s6(_facts(now: _k('2027-01-11', 15), fate: null)).actions,
        isEmpty,
      );
      expect(
        s6(_facts(now: _k('2027-01-11', 15))).actions.single.label,
        HandoverWizardTexts.start,
      );
      expect(
        s6(
          _facts(now: _k('2027-01-11', 15), opened: _k('2027-01-11', 10)),
          sid: _sid,
        ).actions,
        isEmpty,
      );
      expect(
        s6(
          _facts(now: _k('2027-01-13', 11), opened: _k('2027-01-11', 10)),
          sid: _sid,
        ).actions.single.label,
        HandoverWizardTexts.restart,
      );
    });

    test('S1 경고 후 진행 = 행 WATCH · 체험 카드 · 확정 가능 머리는 그대로', () {
      const SimTrialReport warn = SimTrialReport(
        started: true,
        items: <SimTrialItemResult>[],
        complete: true,
        needsWarning: true,
        counters: SimTrialCounters.zero,
        headline: '체험 항목을 채웠습니다 — 월말 리밸런싱은 아직이라 경고 후 진행합니다.',
      );
      final HandoverWizardVm vm = _vm(
        _facts(
          now: _k('2027-01-12', 12),
          opened: _k('2027-01-11', 10),
          trial: warn,
        ),
        observed: _k('2027-01-12', 12),
        sessionId: _sid,
      );
      expect(vm.rows.first.level, UiLevel.watch);
      expect(vm.trial?.headline, warn.headline);
      expect(vm.level, UiLevel.ok);
      final HandoverWizardVm plain = _vm(
        _facts(now: _k('2027-01-12', 12), opened: _k('2027-01-11', 10)),
        observed: _k('2027-01-12', 12),
        sessionId: _sid,
      );
      expect((plain.rows.first.level, plain.trial), (UiLevel.ok, null));
    });

    test('킬스위치 · 차단 = 머리 BLOCKED · 시작 자리는 남는다(결과로 거부 · K176 결)', () {
      final HandoverWizardVm vm = _vm(
        _facts(now: _k('2027-01-08', 12), kill: true),
        observed: _k('2027-01-08', 12),
      );
      expect(vm.level, UiLevel.blocked);
      expect(vm.reasonCode, SimToAutoCodes.safetyBlock);
      expect(
        vm.rows[5].actions.single.id,
        SettingsActionId.handoverSessionStart,
      );
    });

    test('머리 수준 짝 — 코드 → 수준', () {
      expect(
        handoverWizardLevelOf(
          judgeSimToAuto(
            _facts(now: _k('2027-01-12', 12), opened: _k('2027-01-11', 10)),
            kr: _kr,
            observation: _two,
          ),
        ),
        UiLevel.ok,
      );
      expect(
        handoverWizardLevelOf(
          judgeSimToAuto(
            _facts(now: _k('2027-01-08', 12), golden: null),
            kr: _kr,
            observation: _two,
          ),
        ),
        UiLevel.info,
      );
      expect(
        handoverWizardLevelOf(
          judgeSimToAuto(
            _facts(now: _k('2027-01-08', 12), golden: false),
            kr: _kr,
            observation: _two,
          ),
        ),
        UiLevel.blocked,
      );
      expect(
        handoverWizardLevelOf(
          judgeSimToAuto(_facts(sim: null), kr: _kr, observation: _two),
        ),
        UiLevel.info,
      );
    });

    test('체험 카드 = 엔진 판정 그대로 · 상태 짝(C-53 ⑨)', () {
      expect(simTrialCardOf(_open), _fx('trial_incomplete').trial);
      expect(
        <UiLevel>[
          for (final SimTrialItemState s in SimTrialItemState.values)
            simTrialStateLevel(s),
        ],
        <UiLevel>[UiLevel.ok, UiLevel.ok, UiLevel.watch, UiLevel.info],
      );
    });
  });

  group('결과 = 표본', () {
    final List<ActionResult> fx = <ActionResult>[
      for (final Map<String, Object?> r in _rows(
        'handover_sim_to_auto_action_results',
      ))
        ActionResult.fromJson(r),
    ];

    test('수준 짝 — 표본 20행', () {
      for (final ActionResult r in fx) {
        expect(
          handoverResultLevel(r.reasonCode),
          r.level,
          reason: r.actionRunId,
        );
        final ActionResult got = handoverActionResultOf(
          id: r.id,
          actionRunId: r.actionRunId,
          code: r.reasonCode,
          headline: r.headline,
        );
        expect(
          (got.level, got.handoffRoute, got.retryable),
          (r.level, r.handoffRoute, r.retryable),
        );
      }
    });

    test('글자 — 고름 · 시작 · 취소 · 확정 = 엔진 문장', () {
      for (final ActionResult r in fx) {
        final String? c = r.reasonCode;
        final String? want = switch (r.id) {
          SettingsActionId.handoverSimLedgerFate => simLedgerFateResultText(
            SimLedgerFate.keep,
            c,
          ),
          SettingsActionId.handoverSessionStart =>
            c == null
                ? handoverSessionHeadline(
                    null,
                    openedAtUtc: _k('2026-12-09', 11),
                  )
                : handoverSessionHeadline(c),
          SettingsActionId.handoverSessionCancel =>
            c == null ? kHandoverCancelledHeadline : handoverSessionHeadline(c),
          SettingsActionId.handoverCommit =>
            c == kSimToAutoWatchdogPrepareFailed || c == kSimToAutoCommitUnknown
                ? null
                : simToAutoCommitHeadline(c),
          _ => fail('모르는 id ${r.id}'),
        };
        if (want != null) {
          expect(want, _plain(r.headline), reason: r.actionRunId);
        }
      }
      expect(
        simLedgerFateResultText(SimLedgerFate.discard, null),
        HandoverWizardTexts.fateDiscarded,
      );
    });

    test('🔴 확정 성공만 settingsOperations 로 넘긴다(K175) · 거부 = null', () {
      expect(
        handoverActionResultOf(
          id: SettingsActionId.handoverCommit,
          actionRunId: 'a',
          code: null,
          headline: 'h',
        ).handoffRoute,
        AppRoutes.settingsOperations,
      );
      expect(
        handoverActionResultOf(
          id: SettingsActionId.handoverSessionStart,
          actionRunId: 'a',
          code: null,
          headline: 'h',
        ).handoffRoute,
        isNull,
      );
      expect(
        handoverActionResultOf(
          id: SettingsActionId.handoverCommit,
          actionRunId: 'a',
          code: SimToAutoCommitCodes.probeMissing,
          headline: 'h',
        ).handoffRoute,
        isNull,
      );
    });

    test('결과 코드 사전 — 계약 사전의 모든 값에 수준이 선다(BLOCKED 기본 · 알려진 몫 짝)', () {
      expect(
        handoverResultLevel(SimToAutoCodes.trustedTimeUnavailable),
        UiLevel.watch,
      );
      expect(handoverResultLevel(SimToAutoCodes.commitWindow), UiLevel.watch);
      expect(handoverResultLevel(SimToAutoCodes.accountUnmapped), UiLevel.act);
      expect(
        handoverResultLevel(SimToAutoCodes.goldenVectorFailed),
        UiLevel.act,
      );
      expect(handoverResultLevel(SimToAutoCodes.trialIncomplete), UiLevel.act);
      expect(
        handoverResultLevel(SimToAutoCodes.sessionExpired),
        UiLevel.blocked,
      );
      expect(
        handoverResultLevel(SimToAutoCommitCodes.probeMissing),
        UiLevel.blocked,
      );
      expect(handoverResultLevel('SIM_TO_AUTO_S2'), UiLevel.act);
    });
  });
}
