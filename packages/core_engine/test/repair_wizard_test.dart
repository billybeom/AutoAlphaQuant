// E16j-a — X5 정정 마법사 VM 생산자 · 단계 문구 · 결과 글자 · 원문 파싱(01 §41 K247~K263 · 01 §8 미결 217 ⓑⓓⓔⓗ).
//
// 🔵 잡는 것: ① 계약 표본 7벌 = 엔진 VM(«(합성)» 뗌 · 세션 id · 근거 해시 · `li-` id · 체결 후보 글자 · «그만두기» = 엔진 몫)
//    ② 허브 — X1 경계가 이긴다 · 빈 허브 · 대상 차례 · 같은 글자 = 차이 문장 · 본문 없음 · 무결성 막힘(깨끗 · 날 모름)
//    ③ diff 대상 — 모름 · 끝(해소 · 받아들임) · 정정 대상 아님 · 잠김 · 후보 없음 · 세션 진행 · 다른 세션 · 신뢰 시각 모름 ·
//       냉각 · 실행 창 · 만료 = 새 세션 ④ 무결성 대상 — 표시 없음 · 판정 바뀜 · 실행 창 = 새 기준점 ⑤ C-66 불변식 전수
//    ⑥ 결과 글자 — 합집합 전부 · 모르는 코드 = 실패 · 막힘 = 다시 시도 ⑦ 원문 파싱 ⑧ 세션 id ⑨ 체결 후보 글자.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String rel) =>
    jsonDecode(File('../domain_contracts/fixtures/$rel').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _row(String rel) =>
    (_fixture(rel)['rows'] as List<dynamic>).single as Map<String, dynamic>;

// 표본 관측 = 2026-08-31 18:00 KST.
final DateTime _now = DateTime.utc(2026, 8, 31, 9);

StoredLedgerDiff _diff({
  String id = 'ld_0001',
  DiffStatus status = DiffStatus.open,
  LedgerPair pair = LedgerPair.canonBroker,
  LedgerAxis axis = LedgerAxis.quantity,
  DiffSeverity severity = DiffSeverity.blocking,
  List<String> candidates = const <String>['FILL_LAG', 'MANUAL_ORDER'],
  DateTime? detected,
  String label = '069500 수량이 12주 적습니다',
}) => StoredLedgerDiff(
  diffId: id,
  pair: pair,
  axis: axis,
  authoredDate: const TradeDate('2026-08-28'),
  delta: jsonEncode(<String, Object?>{
    'kind': 'QTY',
    'key': '069500',
    'ledger': 10,
    'broker': 9,
    'candidates': candidates,
  }),
  deltaLabel: label,
  severity: severity,
  status: status,
  detectedAtUtc: detected ?? DateTime.utc(2026, 8, 28),
  applicable: true,
);

const RepairFillCandidate _fill = RepairFillCandidate(
  fillId: 'ex_0001',
  tradeDate: '2026-08-28',
  side: 'BUY',
  symbol: '069500',
  quantity: 10,
  price: 9850,
);

const LedgerIntegrityVerdict _clean = LedgerIntegrityVerdict.ok(
  daysChecked: 3,
  checkedThrough: '2026-08-30',
);

const LedgerIntegrityVerdict _mismatch = LedgerIntegrityVerdict.failed(
  LedgerIntegrityReason.dayHashMismatch,
  firstBadDate: '2026-08-27',
  daysChecked: 3,
);

InterventionStep _s(int stage, DateTime at, [String? decision]) =>
    InterventionStep(
      stage: stage,
      occurredAtUtc: at,
      outcome: InterventionOutcome.passed,
      decisionId: decision,
    );

/// 세션 — [passed] 단계까지 통과(3단계 = 저널 `JIV-1` · 시각 = [journalAt] 기준).
InterventionState _session(
  String id,
  int passed, {
  DateTime? journalAt,
  DateTime? coolPassAt,
  InterventionOutcome? closeWith,
}) {
  final DateTime j = journalAt ?? _now.subtract(const Duration(hours: 25));
  final List<InterventionStep> rows = <InterventionStep>[
    if (passed >= 1) _s(1, j.subtract(const Duration(minutes: 2))),
    if (passed >= 2) _s(2, j.subtract(const Duration(minutes: 1))),
    if (passed >= 3) _s(3, j, 'JIV-1'),
    if (passed >= 4)
      _s(4, coolPassAt ?? _now.subtract(const Duration(minutes: 30))),
    if (closeWith != null)
      InterventionStep(
        stage: passed + 1,
        occurredAtUtc: _now.subtract(const Duration(minutes: 1)),
        outcome: closeWith,
      ),
  ];
  return interventionStateOf(id, rows)!;
}

Map<String, InterventionState> _sessions(List<InterventionState> s) =>
    <String, InterventionState>{
      for (final InterventionState x in s) x.sessionId: x,
    };

bool _allBodies(String _) => true;

RepairWizardFacts _facts({
  List<StoredLedgerDiff> open = const <StoredLedgerDiff>[],
  bool flag = false,
  LedgerIntegrityVerdict integrity = _clean,
  DerivedRelation? archive,
  List<InterventionState> sessions = const <InterventionState>[],
  List<String> pledge = const <String>['서약 하나', '서약 둘', '서약 셋'],
  bool budgetExhausted = false,
  DateTime? trusted,
  bool trustedUnknown = false,
  bool writable = true,
  bool Function(String) hasBody = _allBodies,
  StoredLedgerDiff? target,
  List<RepairFillCandidate> fills = const <RepairFillCandidate>[_fill],
}) => RepairWizardFacts(
  openDiffs: open,
  integrityFlag: flag,
  integrity: integrity,
  archiveRelation: archive,
  sessions: _sessions(sessions),
  pledgeLines: pledge,
  budgetExhausted: budgetExhausted,
  trustedNowUtc: trustedUnknown ? null : (trusted ?? _now),
  nowUtc: _now,
  writable: writable,
  hasBody: hasBody,
  targetDiff: target,
  fills: fills,
);

// ── 표본 정규화 ─────────────────────────────────────────────────────────────

Object? _strip(Object? v) => switch (v) {
  final String s => s.replaceAll('(합성) ', ''),
  final List<dynamic> l => <Object?>[for (final Object? x in l) _strip(x)],
  final Map<String, dynamic> m => <String, Object?>{
    for (final MapEntry<String, dynamic> e in m.entries) e.key: _strip(e.value),
  },
  _ => v,
};

/// 엔진 VM → 표본 꼴(엔진 몫 칸만 표본 값으로 바꾼다 — 나머지는 글자 그대로 대조).
RepairWizardVm _normalized(RepairWizardVm vm, RepairWizardVm fixture) {
  // 세션 id(표본 `iv_0001` · 엔진 `x5:<대상>:<차례>`) · «그만두기» = 엔진 몫(세션이 갇히지 않게).
  final List<RepairStageRow> stages = <RepairStageRow>[
    for (final RepairStageRow st in vm.stages)
      st.copyWith(
        actions: <SafetyActionCall>[
          for (final SafetyActionCall a in st.actions)
            if (a.args['outcome'] != 'ABANDONED')
              a.copyWith(
                args: <String, String>{...a.args, 'session_id': 'iv_0001'},
              ),
        ],
      ),
  ];
  // 근거 해시 = 엔진(delta 해시).
  final LedgerDiffRow? diff = vm.diff == null || fixture.diff == null
      ? vm.diff
      : vm.diff!.copyWith(evidenceHash: fixture.diff!.evidenceHash);
  // 무결성 id = 엔진 합성(`li-` + 해시) · 표본 = `li_0001`.
  final List<LinkAction> links = <LinkAction>[
    for (final LinkAction l in vm.targetLinks)
      l.copyWith(
        deepLink: l.deepLink.replaceAll(RegExp(r'li-[0-9a-f]{24}'), 'li_0001'),
      ),
  ];
  // 체결 후보 글자 = 엔진(날 · 방향 · 종목 · 수량 · 가격 — 계약 칸 주석) · 표본 글자는 합성.
  final RepairCorrectionForm? c = vm.correction;
  final RepairCorrectionForm? fc = fixture.correction;
  final RepairCorrectionForm? correction = c == null || fc == null
      ? c
      : c.copyWith(
          fills: <RepairFillChoice>[
            for (int i = 0; i < c.fills.length; i++)
              i < fc.fills.length
                  ? c.fills[i].copyWith(label: fc.fills[i].label)
                  : c.fills[i],
          ],
        );
  return vm.copyWith(
    stages: stages,
    diff: diff,
    targetLinks: links,
    correction: correction,
  );
}

RepairWizardVm _fixtureVm(String path) =>
    RepairWizardVm.fromJson(_strip(_row(path))! as Map<String, dynamic>);

void _matchesFixture(RepairWizardVm vm, String path) {
  final RepairWizardVm fx = _fixtureVm(path);
  expect(_normalized(vm, fx), fx, reason: path);
}

bool _noActions(RepairWizardVm v) =>
    v.doNothingAction == null &&
    v.correction == null &&
    v.baselineLabel == null &&
    v.stages.every((RepairStageRow r) => r.actions.isEmpty && !r.journalForm);

/// C-66 불변식(엔진이 내는 모든 VM).
void _invariants(RepairWizardVm v, String why) {
  expect(<int>{0, 5}, contains(v.stages.length), reason: why);
  for (int i = 0; i < v.stages.length; i++) {
    if (v.stages[i].journalForm) expect(i, 2, reason: why);
    for (final SafetyActionCall a in v.stages[i].actions) {
      expect(a.id, SafetyActionId.interventionStep, reason: why);
      expect(a.args.keys.toSet(), <String>{
        'session_id',
        'stage',
        'outcome',
      }, reason: why);
      expect(a.args['stage'], '${i + 1}', reason: why);
      expect(a.args['session_id'], startsWith('x5:'), reason: why);
    }
  }
  if (v.targetLinks.isNotEmpty) {
    expect(v.diff, isNull, reason: why);
    expect(v.stages, isEmpty, reason: why);
    expect(v.origins, isEmpty, reason: why);
    expect(_noActions(v), isTrue, reason: why);
    for (final LinkAction l in v.targetLinks) {
      expect(AppRoutes.isRegistered(l.deepLink), isTrue, reason: why);
      expect(l.deepLink, startsWith('aaq://x5/repair-wizard/'), reason: why);
    }
  }
  if (v.diff != null) expect(v.diff!.actionLink, isNull, reason: why);
  if (v.doNothingAction != null) {
    expect(v.doNothingAction!.id, SafetyActionId.repairAccept, reason: why);
    expect(v.doNothingAction!.args.keys, <String>['diff_id'], reason: why);
    expect(v.diff, isNotNull, reason: why);
  }
  expect(v.correction == null || v.baselineLabel == null, isTrue, reason: why);
  if (v.correction != null) {
    expect(v.correction!.fills, isNotEmpty, reason: why);
    expect(v.diff, isNotNull, reason: why);
  }
  if (v.baselineLabel != null) expect(v.diff, isNull, reason: why);
  if (v.lockedLabel != null || v.doneLabel != null || v.x1GuideLink != null) {
    expect(_noActions(v), isTrue, reason: why);
  }
  for (final RepairOriginChoice o in v.origins) {
    expect(OriginCodes.values, contains(o.originCode), reason: why);
  }
  if (v.baselineLabel != null) {
    expect(
      v.origins.map((RepairOriginChoice o) => o.originCode).toSet(),
      everyElement(isIn(kBaselineOriginCodes)),
      reason: why,
    );
  }
  final String? c = v.reasonCode;
  if (c != null) {
    expect(
      <String>{
        ...LedgerBoundaryReasonCodes.values,
        ...RepairResultCodes.values,
        ...BaselineResultCodes.values,
        ...BaselineApplyResultCodes.values,
      },
      contains(c),
      reason: why,
    );
  }
}

void main() {
  group('① 계약 표본 7벌 = 엔진 VM(«(합성)» 뗌)', () {
    test('repair_hub_targets — diff 하나 · 무결성 하나', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          open: <StoredLedgerDiff>[_diff()],
          flag: true,
          integrity: _mismatch,
        ),
      );
      _matchesFixture(vm, FixturePaths.x5RepairHubTargets);
      _invariants(vm, 'hub');
    });

    test('repair_hub_empty', () {
      final RepairWizardVm vm = repairWizardVmOf(_facts());
      _matchesFixture(vm, FixturePaths.x5RepairHubEmpty);
    });

    test('repair_diff_default — FILL_LAG 후보 = 기본 아무것도 안 하기 · 1단계 차례', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(target: _diff()),
        targetId: 'ld_0001',
      );
      _matchesFixture(vm, FixturePaths.x5RepairDiffDefault);
      expect(vm.stages.first.actions.single.args['session_id'], 'x5:ld_0001:1');
      _invariants(vm, 'default');
    });

    test('repair_diff_stage3 — 저널 폼 · 기본 칸은 세션 뒤 false', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          target: _diff(),
          sessions: <InterventionState>[_session('x5:ld_0001:1', 2)],
        ),
        targetId: 'ld_0001',
      );
      _matchesFixture(vm, FixturePaths.x5RepairDiffStage3);
      expect(vm.stages[2].actions.single.args, <String, String>{
        'session_id': 'x5:ld_0001:1',
        'stage': '3',
        'outcome': 'ABANDONED',
      }, reason: '3단계 = 그만두기(엔진 몫 · 세션이 갇히지 않게)');
      _invariants(vm, 'stage3');
    });

    test('repair_diff_ready — 실행 창 · 정정 폼', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          target: _diff(),
          sessions: <InterventionState>[
            _session(
              'x5:ld_0001:1',
              4,
              journalAt: DateTime.utc(2026, 8, 29, 14, 59),
            ),
          ],
        ),
        targetId: 'ld_0001',
      );
      _matchesFixture(vm, FixturePaths.x5RepairDiffReady);
      expect(
        vm.correction!.fills.single,
        const RepairFillChoice(
          fillRef: 'ex_0001',
          label: '08-28 매수 069500 10주 · 9,850원',
        ),
      );
      _invariants(vm, 'ready');
    });

    test('repair_integrity_ready — 새 기준점', () {
      final String li = integrityTargetIdOf(
        _facts(flag: true, integrity: _mismatch),
      )!;
      expect(li, integrityDiffIdOf('2026-08-27', 'DAY_HASH_MISMATCH'));
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          flag: true,
          integrity: _mismatch,
          sessions: <InterventionState>[
            _session(
              x5SessionIdOf(li, 1),
              4,
              journalAt: DateTime.utc(2026, 8, 29, 14, 59),
            ),
          ],
        ),
        targetId: li,
      );
      _matchesFixture(vm, FixturePaths.x5RepairIntegrityReady);
      _invariants(vm, 'integrity');
    });

    test('repair_boundary_x1 — 경계 X1 = 안내 링크만', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          flag: true,
          integrity: const LedgerIntegrityVerdict.failed(
            LedgerIntegrityReason.sqliteIntegrity,
            daysChecked: 0,
          ),
        ),
        targetId: 'ld_0001',
      );
      // 표본 = 파일이 열리지 않음(원천은 열린 원장만 읽는다 — 그 밖 X1 사유로 같은 꼴).
      final RepairWizardVm fx = _fixtureVm(FixturePaths.x5RepairBoundaryX1)
          .copyWith(reasonCode: 'SQLITE_INTEGRITY');
      expect(_normalized(vm, fx), fx);
      _invariants(vm, 'x1');
    });
  });

  group('② 허브', () {
    test('🔴 X1 경계가 허브도 덮는다 · 본문 없으면 안내 링크 0', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          open: <StoredLedgerDiff>[_diff()],
          flag: true,
          integrity: _mismatch,
          archive: DerivedRelation.ahead,
          hasBody: (String r) => r != AppRoutes.x1MigrationEmergency,
        ),
      );
      expect(
        (vm.level, vm.reasonCode, vm.x1GuideLink),
        (UiLevel.blocked, 'RESTORE_ROLLBACK', null),
      );
      expect(vm.targetLinks, isEmpty);
      _invariants(vm, 'x1 hub');
    });

    test('대상 차례 = 탐지 늦은 것 먼저 · 승인 경로만 · 같은 글자 = 차이 문장', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          open: <StoredLedgerDiff>[
            _diff(id: 'ld-a', label: 'A 문장'),
            _diff(id: 'ld-b', label: 'B 문장'),
            _diff(
              id: 'ld-c',
              detected: DateTime.utc(2026, 8, 29),
              label: 'C 문장',
            ),
            _diff(
              id: 'ld-cash',
              axis: LedgerAxis.cash,
              severity: DiffSeverity.observational,
            ),
            _diff(id: 'ld-gh', pair: LedgerPair.canonGithub),
          ],
        ),
      );
      expect(vm.headline, '정정할 대상 3건 — 하나를 고르십시오');
      expect(
        vm.targetLinks.map((LinkAction l) => (l.label, l.deepLink)),
        <(String, String)>[
          ('체결 차이 — 08-29 탐지', 'aaq://x5/repair-wizard/ld-c'),
          ('체결 차이 — 08-28 탐지 · A 문장', 'aaq://x5/repair-wizard/ld-a'),
          ('체결 차이 — 08-28 탐지 · B 문장', 'aaq://x5/repair-wizard/ld-b'),
        ],
      );
      _invariants(vm, 'order');
    });

    test('대상 화면 본문이 없다 = 링크 0 · 말만', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          open: <StoredLedgerDiff>[_diff()],
          hasBody: (String r) => r != AppRoutes.x5RepairTarget,
        ),
      );
      expect(
        (vm.headline, vm.level),
        ('정정할 대상 1건 — 이 앱에서는 열 수 없습니다', UiLevel.watch),
      );
      expect(vm.targetLinks, isEmpty);
      expect(vm.historyLink, isNotNull);
    });

    test('정정 이력 본문 없음 = 이력 링크 0', () {
      expect(
        repairWizardVmOf(
          _facts(hasBody: (String r) => r != AppRoutes.ledgerRepairs),
        ).historyLink,
        isNull,
      );
    });

    test(
      '무결성 표시가 섰는데 대조가 깨끗 = BASELINE_NOT_X5 · 날 모름 = FIRST_BAD_DATE_UNKNOWN',
      () {
        final RepairWizardVm clean = repairWizardVmOf(_facts(flag: true));
        expect(
          (clean.reasonCode, clean.level, clean.doneLabel),
          ('BASELINE_NOT_X5', UiLevel.watch, null),
        );
        expect(clean.targetLinks, isEmpty);
        final RepairWizardVm noDay = repairWizardVmOf(
          _facts(
            flag: true,
            integrity: const LedgerIntegrityVerdict.failed(
              LedgerIntegrityReason.formatVersion,
              daysChecked: 1,
            ),
          ),
        );
        expect(noDay.reasonCode, 'BASELINE_FIRST_BAD_DATE_UNKNOWN');
        // diff 링크가 있으면 막힘은 줄로만.
        final RepairWizardVm both = repairWizardVmOf(
          _facts(open: <StoredLedgerDiff>[_diff()], flag: true),
        );
        expect(both.reasonCode, isNull);
        expect(both.targetLines, <String>[
          RepairWizardTexts.integrityCleanFlag,
        ]);
        _invariants(clean, 'clean');
        _invariants(noDay, 'noDay');
        _invariants(both, 'both');
      },
    );

    test('무결성 표시 없음 = 경계를 보지 않는다(판정이 깨져도 허브 = 빈 판)', () {
      final RepairWizardVm vm = repairWizardVmOf(
        _facts(
          integrity: const LedgerIntegrityVerdict.failed(
            LedgerIntegrityReason.sqliteIntegrity,
            daysChecked: 0,
          ),
        ),
      );
      expect(vm.headline, RepairWizardTexts.hubEmpty);
    });
  });

  group('③ diff 대상', () {
    RepairWizardVm target(RepairWizardFacts f) =>
        repairWizardVmOf(f, targetId: f.targetDiff?.diffId ?? 'ld_0001');

    test('모르는 대상 · 다른 id = 끝 문장(동작 0)', () {
      for (final RepairWizardVm vm in <RepairWizardVm>[
        repairWizardVmOf(_facts(), targetId: 'ld-nope'),
        repairWizardVmOf(_facts(target: _diff()), targetId: 'ld-other'),
        repairWizardVmOf(_facts(), targetId: 'weird'),
      ]) {
        expect(
          (vm.headline, vm.doneLabel),
          (RepairWizardTexts.unknownTarget, RepairWizardTexts.pickAgain),
        );
        _invariants(vm, 'unknown');
      }
    });

    test('끝 — 해소 · 받아들임(근거 행은 남긴다)', () {
      final RepairWizardVm r = target(
        _facts(target: _diff(status: DiffStatus.resolved)),
      );
      expect(
        (r.headline, r.doneLabel),
        (RepairWizardTexts.doneResolved, '해소됨'),
      );
      expect(r.diff, isNotNull);
      final RepairWizardVm a = target(
        _facts(target: _diff(status: DiffStatus.accepted)),
      );
      expect(
        (a.headline, a.doneLabel),
        (RepairWizardTexts.doneAccepted, '받아들임'),
      );
      _invariants(r, 'resolved');
      _invariants(a, 'accepted');
    });

    test('정정 대상 아님 — 관측(현금) · 파생 쌍', () {
      for (final StoredLedgerDiff d in <StoredLedgerDiff>[
        _diff(axis: LedgerAxis.cash, severity: DiffSeverity.observational),
        _diff(pair: LedgerPair.canonSupabase),
      ]) {
        final RepairWizardVm vm = target(_facts(target: d));
        expect(vm.headline, RepairWizardTexts.notRepairable);
        _invariants(vm, 'notRepairable');
      }
    });

    test('잠김 = 동작 0 · 잠김 글자', () {
      final RepairWizardVm vm = target(
        _facts(target: _diff(), writable: false),
      );
      expect(vm.lockedLabel, RepairWizardTexts.locked);
      expect(_noActions(vm), isTrue);
      _invariants(vm, 'locked');
    });

    test('체결 후보 없음 = 마찰 0 · 원인 0 · 아무것도 안 하기만', () {
      final RepairWizardVm def = target(
        _facts(target: _diff(), fills: const <RepairFillCandidate>[]),
      );
      expect(def.stages, isEmpty);
      expect(def.origins, isEmpty);
      expect(def.doNothingAction, isNotNull);
      expect(def.targetLines, <String>[RepairWizardTexts.noFills]);
      expect(def.headline, RepairWizardTexts.diffDefault);
      final RepairWizardVm other = target(
        _facts(
          target: _diff(candidates: const <String>['MANUAL_ORDER']),
          fills: const <RepairFillCandidate>[],
        ),
      );
      expect(
        (other.headline, other.doNothingDefault),
        (RepairWizardTexts.noFills, false),
      );
      expect(other.targetLines, isEmpty);
      _invariants(def, 'noFills');
      _invariants(other, 'noFills2');
    });

    test('기본 없음(FILL_LAG 아님) = ACT · 시작 문장', () {
      final RepairWizardVm vm = target(
        _facts(target: _diff(candidates: const <String>['MANUAL_ORDER'])),
      );
      expect(
        (vm.headline, vm.level, vm.doNothingDefault),
        (RepairWizardTexts.diffStart, UiLevel.act, false),
      );
    });

    test('2단계 = 서약 재생 · 다음 · 그만두기 / 서약 없음 = 문장', () {
      final RepairWizardVm vm = target(
        _facts(
          target: _diff(),
          sessions: <InterventionState>[_session('x5:ld_0001:1', 1)],
        ),
      );
      expect(vm.headline, '정정 마찰 2단계 — 카드 · 서약 다시 읽기');
      expect(vm.stages[1].lines, <String>['서약 하나', '서약 둘', '서약 셋']);
      expect(
        vm.stages[1].actions.map((SafetyActionCall a) => a.args['outcome']),
        <String>['PASSED', 'ABANDONED'],
      );
      final RepairWizardVm none = target(
        _facts(
          target: _diff(),
          pledge: const <String>[],
          sessions: <InterventionState>[_session('x5:ld_0001:1', 1)],
        ),
      );
      expect(none.stages[1].lines, <String>[RepairWizardTexts.noPledge]);
      _invariants(vm, 'stage2');
    });

    test('3단계 — 재량 예산 소진 = 메모 필요 문장', () {
      final RepairWizardVm vm = target(
        _facts(
          target: _diff(),
          budgetExhausted: true,
          sessions: <InterventionState>[_session('x5:ld_0001:1', 2)],
        ),
      );
      expect(vm.stages[2].lines, <String>[
        RepairWizardTexts.journalLine,
        RepairWizardTexts.journalNeedsNote,
      ]);
    });

    test('4단계 — 냉각 중 = 끝 시각 · 그만두기만 / 냉각 끝 = 냉각을 마쳤습니다', () {
      final DateTime j = _now.subtract(const Duration(hours: 2));
      final RepairWizardVm cooling = target(
        _facts(
          target: _diff(),
          sessions: <InterventionState>[
            _session('x5:ld_0001:1', 3, journalAt: j),
          ],
        ),
      );
      final RepairStageRow r4 = cooling.stages[3];
      expect(
        (r4.stateLabel, r4.level),
        (RepairWizardTexts.cooling, UiLevel.watch),
      );
      expect(r4.lines, <String>['09-01 16:00 부터']);
      expect(
        r4.actions.map((SafetyActionCall a) => a.args['outcome']),
        <String>['ABANDONED'],
      );
      final RepairWizardVm cooled = target(
        _facts(
          target: _diff(),
          sessions: <InterventionState>[_session('x5:ld_0001:1', 3)],
        ),
      );
      expect(
        cooled.stages[3].actions.map((SafetyActionCall a) => a.label),
        <String>[RepairWizardTexts.cooled, RepairWizardTexts.abandon],
      );
      _invariants(cooling, 'cooling');
      _invariants(cooled, 'cooled');
    });

    test('🔴 다른 세션이 살아 있다 = 시작 동작 0 · 문장', () {
      final RepairWizardVm vm = target(
        _facts(
          target: _diff(),
          sessions: <InterventionState>[_session('x5:ld-other:1', 2)],
        ),
      );
      expect(vm.stages.first.actions, isEmpty);
      expect(vm.stages.first.lines, contains(RepairWizardTexts.otherSession));
      expect(vm.doNothingAction, isNotNull, reason: '아무것도 안 하기는 늘');
    });

    test('🔴 신뢰 시각 모름 = 단계 동작 0 · 저널 폼 0 · 문장 · 정정 폼 0', () {
      final RepairWizardVm s1 = target(
        _facts(target: _diff(), trustedUnknown: true),
      );
      expect(s1.stages.first.actions, isEmpty);
      expect(s1.stages.first.lines.last, RepairWizardTexts.trustedUnknown);
      final RepairWizardVm s3 = target(
        _facts(
          target: _diff(),
          trustedUnknown: true,
          sessions: <InterventionState>[_session('x5:ld_0001:1', 2)],
        ),
      );
      expect(s3.stages[2].journalForm, isFalse);
      final RepairWizardVm s5 = target(
        _facts(
          target: _diff(),
          trustedUnknown: true,
          sessions: <InterventionState>[_session('x5:ld_0001:1', 4)],
        ),
      );
      expect(
        (s5.correction, s5.stages[4].stateLabel),
        (null, RepairWizardTexts.currentExecute),
      );
      _invariants(s5, 'trusted');
    });

    test('🔴 실행 창이 지난 세션 = 새 세션(차례 +1) · 닫힌 세션도 센다', () {
      final RepairWizardVm vm = target(
        _facts(
          target: _diff(),
          sessions: <InterventionState>[
            _session(
              'x5:ld_0001:1',
              4,
              journalAt: _now.subtract(const Duration(hours: 49)),
              coolPassAt: _now.subtract(const Duration(hours: 24, minutes: 30)),
            ),
            _session(
              'x5:ld_0001:2',
              1,
              closeWith: InterventionOutcome.abandoned,
            ),
          ],
        ),
      );
      expect(vm.stages.first.actions.single.args['session_id'], 'x5:ld_0001:3');
      expect(vm.correction, isNull);
    });
  });

  group('④ 무결성 대상', () {
    test('표시 없음 = 끝 · 판정이 바뀜 = 끝 + 코드', () {
      final RepairWizardVm none = repairWizardVmOf(_facts(), targetId: 'li-x');
      expect(none.doneLabel, RepairWizardTexts.integrityNone);
      final RepairWizardVm changed = repairWizardVmOf(
        _facts(flag: true, integrity: _mismatch),
        targetId: 'li-stale',
      );
      expect(
        (changed.headline, changed.reasonCode, changed.doneLabel),
        (
          RepairWizardTexts.integrityChanged,
          'CONTENT_MISMATCH',
          RepairWizardTexts.pickAgain,
        ),
      );
      final RepairWizardVm clean = repairWizardVmOf(
        _facts(flag: true),
        targetId: 'li-stale',
      );
      expect(clean.reasonCode, 'BASELINE_NOT_X5');
      _invariants(none, 'none');
      _invariants(changed, 'changed');
    });

    test('시작 = 경계 문장 · 원인 = 후보 ∩ 3종 · 잠김', () {
      final RepairWizardFacts f = _facts(
        flag: true,
        integrity: const LedgerIntegrityVerdict.failed(
          LedgerIntegrityReason.formatVersion,
          firstBadDate: '2026-08-20',
          daysChecked: 4,
        ),
      );
      final String li = integrityTargetIdOf(f)!;
      final RepairWizardVm vm = repairWizardVmOf(f, targetId: li);
      expect(
        vm.headline,
        startsWith('지난 기록이 스탬프와 다릅니다(2026-08-20 · FORMAT_VERSION)'),
      );
      expect(vm.origins.map((RepairOriginChoice o) => o.originCode), <String>[
        'SCHEMA_SKEW',
      ]);
      expect(vm.origins.single.label, '스키마 판 어긋남');
      expect(vm.stages.first.lines.first, RepairWizardTexts.ruleIntegrity);
      expect(vm.doNothingAction, isNull);
      final RepairWizardVm locked = repairWizardVmOf(
        _facts(flag: true, integrity: f.integrity, writable: false),
        targetId: li,
      );
      expect(locked.lockedLabel, isNotNull);
      _invariants(vm, 'integrity start');
      _invariants(locked, 'integrity locked');
    });
  });

  group('⑥ 결과 글자', () {
    final Set<String> union = <String>{
      ...RepairResultCodes.values,
      ...BaselineResultCodes.values,
      ...BaselineApplyResultCodes.values,
      AdviceRejectCodes.amendTargetNotActive,
      AdviceRejectCodes.amendSymbolOrSideChange,
      AdviceRejectCodes.amendLimitExceeded,
      ...InterventionResultCodes.values,
      ...SafetyCommonResultCodes.values,
      SettingsResultCodes.biometricUnavailable,
      RepairInputCodes.amountInvalid,
    };
    const List<SafetyActionId> ids = <SafetyActionId>[
      SafetyActionId.repairAccept,
      SafetyActionId.repairCorrect,
      SafetyActionId.repairBaseline,
      SafetyActionId.interventionJournal,
      SafetyActionId.interventionStep,
    ];

    test('합집합 전부 글자 있음 · 코드 원문 · 비지 않음', () {
      for (final SafetyActionId id in ids) {
        for (final String code in union) {
          final SafetyActionResult r = repairWizardResultOf(
            id: id,
            actionRunId: 'run',
            code: code,
          );
          expect((r.id, r.reasonCode, r.retryable), (id, code, false));
          expect(r.headline, isNotEmpty);
          expect(r.level, isNot(UiLevel.ok), reason: code);
        }
      }
    });

    test('표본 결과 11행의 글자 = 엔진(«(합성)» 뗌)', () {
      for (final Map<String, dynamic> fx
          in (_fixture(FixturePaths.x5RepairActionResults)['rows']
                  as List<dynamic>)
              .cast<Map<String, dynamic>>()) {
        final SafetyActionResult want = SafetyActionResult.fromJson(
          _strip(fx)! as Map<String, dynamic>,
        );
        final SafetyActionResult got = repairWizardResultOf(
          id: want.id,
          actionRunId: want.actionRunId,
          code: want.reasonCode,
        );
        expect(got, want, reason: want.actionRunId);
      }
    });

    test('성공 글자 — 동작마다 · 단계 결과마다', () {
      expect(
        <String>[
          for (final InterventionStepOutcome o
              in InterventionStepOutcome.values)
            repairWizardResultOf(
              id: SafetyActionId.interventionStep,
              actionRunId: 'r',
              step: o,
            ).headline,
        ],
        <String>[
          RepairResultTexts.stepPassed,
          RepairResultTexts.stepDoNothing,
          RepairResultTexts.stepAbandoned,
        ],
      );
      expect(
        repairWizardResultOf(
          id: SafetyActionId.repairAccept,
          actionRunId: 'r',
        ).level,
        UiLevel.ok,
      );
    });

    test('막힘(코드 0) = WATCH · 다시 시도 · 코드와 함께 = 실패 · 모르는 코드 · 동작 = 실패', () {
      final SafetyActionResult busy = repairWizardResultOf(
        id: SafetyActionId.repairCorrect,
        actionRunId: 'r',
        hold: RepairRunHold.busy,
      );
      expect(
        (busy.level, busy.reasonCode, busy.retryable, busy.headline),
        (UiLevel.watch, null, true, RepairResultTexts.busy),
      );
      expect(
        repairWizardResultOf(
          id: SafetyActionId.repairCorrect,
          actionRunId: 'r',
          hold: RepairRunHold.reconUnavailable,
        ).headline,
        RepairResultTexts.reconUnavailable,
      );
      expect(
        () => repairWizardResultOf(
          id: SafetyActionId.repairCorrect,
          actionRunId: 'r',
          code: 'REPAIR_NO_CHANGE',
          hold: RepairRunHold.busy,
        ),
        throwsArgumentError,
      );
      expect(
        () => repairWizardResultOf(
          id: SafetyActionId.repairCorrect,
          actionRunId: 'r',
          code: 'REPAIR_UNKNOWN',
        ),
        throwsArgumentError,
      );
      expect(
        () => repairWizardResultOf(
          id: SafetyActionId.reconClear,
          actionRunId: 'r',
        ),
        throwsArgumentError,
      );
    });

    test('같은 코드 · 동작마다 갈리는 글자(저널 차례 · 무결성 판정 바뀜)', () {
      String h(SafetyActionId id, String c) =>
          repairWizardResultOf(id: id, actionRunId: 'r', code: c).headline;
      expect(
        h(
          SafetyActionId.interventionJournal,
          'INTERVENTION_STAGE_OUT_OF_ORDER',
        ),
        '지금은 저널 단계가 아닙니다',
      );
      expect(
        h(SafetyActionId.interventionStep, 'INTERVENTION_STAGE_OUT_OF_ORDER'),
        '지금은 그 단계 차례가 아닙니다',
      );
      expect(
        h(SafetyActionId.repairBaseline, 'REPAIR_DELTA_CHANGED'),
        '무결성 판정이 바뀌었습니다 — 처음부터 다시 보십시오',
      );
    });
  });

  group('⑦ 정정 원문 파싱(ⓓ)', () {
    ({int quantity, double price, double commission, double tax})? p(
      String? q,
      String? pr,
      String? c,
      String? t,
    ) => parseRepairAmounts(
      quantityText: q,
      priceText: pr,
      commissionText: c,
      taxText: t,
    );

    test('읽는다 — 공백 · 천 단위 쉼표 · 소수', () {
      expect(p(' 10 ', '9,850', '0', '12.5'), (
        quantity: 10,
        price: 9850.0,
        commission: 0.0,
        tax: 12.5,
      ));
      expect(p('1,000', '1,234,567.25', '1,500', '0.0'), (
        quantity: 1000,
        price: 1234567.25,
        commission: 1500.0,
        tax: 0.0,
      ));
    });

    test('🔴 못 읽는다 = null(빈칸 · 0 · 음수 · 글자 · 엉뚱한 쉼표 · 소수 수량 · 너무 큼)', () {
      for (final List<String?> bad in <List<String?>>[
        <String?>[null, '1', '0', '0'],
        <String?>['', '1', '0', '0'],
        <String?>['0', '1', '0', '0'],
        <String?>['-1', '1', '0', '0'],
        <String?>['1.5', '1', '0', '0'],
        <String?>['1,2', '1', '0', '0'],
        <String?>['10', '0', '0', '0'],
        <String?>['10', 'abc', '0', '0'],
        <String?>['10', '1', '-1', '0'],
        <String?>['10', '1', '0', null],
        <String?>['10', '1', '0', '1e3'],
        <String?>['99999999999999999999', '1', '0', '0'],
      ]) {
        expect(p(bad[0], bad[1], bad[2], bad[3]), isNull, reason: '$bad');
      }
    });
  });

  group('⑧ 세션 id · ⑨ 후보 글자', () {
    test('세션 id ↔ 대상', () {
      expect(x5SessionIdOf('ld-abc', 2), 'x5:ld-abc:2');
      expect(x5TargetOfSession('x5:ld-abc:2'), 'ld-abc');
      expect(x5TargetOfSession('x5:li-a:b:3'), 'li-a:b');
      expect(x5TargetOfSession('iv_0001'), isNull);
      expect(x5TargetOfSession('x5::1'), isNull);
      expect(() => x5SessionIdOf('ld-abc', 0), throwsArgumentError);
    });

    test('후보 글자 — 매도 · 소수 가격 · 정정본', () {
      expect(
        repairFillLabelOf(
          const RepairFillCandidate(
            fillId: 'f',
            tradeDate: '2026-11-02',
            side: 'SELL',
            symbol: '133690',
            quantity: 3,
            price: 174180.5,
            restated: true,
          ),
        ),
        '11-02 매도 133690 3주 · 174,180.5원 · 정정본',
      );
      expect(repairFillLabelOf(_fill), '08-28 매수 069500 10주 · 9,850원');
    });

    test('체인 상한 = 문서 값 2(01 §10-3 B6)', () {
      expect(kRepairAmendChainLimit, 2);
    });
  });
}
