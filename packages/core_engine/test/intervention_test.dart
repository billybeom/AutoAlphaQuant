// E13f2 — 수동 개입 5단계 상태기계(설계 13 §8 R65).
//
// 🔵 잡는 것: ① 상태 = 행에서(차례 · 닫힘 · 냉각 끝 · 실행 창 · 저널) · 끊긴 행 = 오류
//    ② 판정 차례(신뢰 시각 → 닫힘 → 차례 → 한 세션 → 결과) ③ 🔴 아무것도 안 하기 · 중단 = 요건 0(냉각 · 만료 · 저널 무관)
//    ④ 냉각 경계(= 끝 통과) ⑤ 실행 창 경계(= 끝 만료) · 4단계도 만료 ⑥ 5단계 = 같은 저널
//    ⑦ 저널 연결 7갈래(예산 소진 = 메모) ⑧ 문지기 ⑨ 결과 저장 값.
import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 11, 5);

InterventionStep _p(int stage, DateTime at, {String? id}) => InterventionStep(
  stage: stage,
  occurredAtUtc: at,
  outcome: InterventionOutcome.passed,
  decisionId: id,
);

/// 1~n 단계 통과(3단계 = 저널 J · t0 + 1h).
InterventionState _passedTo(int n, {String sid = 's1'}) =>
    interventionStateOf(sid, <InterventionStep>[
      for (int i = 1; i <= n; i++)
        _p(
          i,
          i <= 3
              ? _t0.add(Duration(hours: i - 1))
              : _t0.add(const Duration(hours: 30)),
          id: i == 3 || i == 5 ? 'J' : null,
        ),
    ])!;

String? _code(
  InterventionState? s,
  int stage, {
  InterventionOutcome outcome = InterventionOutcome.passed,
  DateTime? now,
  bool other = false,
  bool journal = true,
  String? decisionId = 'J',
  bool unknownTime = false,
}) => interventionRejectCode(
  session: s,
  otherLiveSession: other,
  stage: stage,
  outcome: outcome,
  nowUtc: unknownTime ? null : (now ?? _t0.add(const Duration(hours: 30))),
  journalLinked: journal,
  decisionId: decisionId,
);

InterventionJournalFacts _j({
  bool dev = true,
  String? before = '근거',
  String? expected = '기대',
  String? rule = 'RULE_DISCRETION_BUDGET',
  String? note,
  bool used = false,
}) => InterventionJournalFacts(
  isDeviation: dev,
  rationaleBefore: before,
  expectedOutcome: expected,
  ruleCited: rule,
  note: note,
  alreadyUsed: used,
);

void main() {
  test('상태 = 행에서 — 차례 · 다음 단계 · 냉각 끝 · 실행 창 · 저널', () {
    expect(interventionStateOf('s', const <InterventionStep>[]), isNull);
    final InterventionState two = _passedTo(2);
    expect(
      (two.closed, two.nextStage, two.coolingEndsAtUtc, two.journalId),
      (false, 3, null, null),
    );
    expect(two.executeWindowEndsAtUtc, isNull);
    final InterventionState three = _passedTo(3);
    expect(three.coolingEndsAtUtc, _t0.add(const Duration(hours: 26)));
    expect(three.executeWindowEndsAtUtc, _t0.add(const Duration(hours: 50)));
    expect((three.journalId, three.nextStage), ('J', 4));
    final InterventionState five = _passedTo(5);
    expect(
      (five.closed, five.closedOutcome, five.nextStage),
      (true, InterventionOutcome.passed, null),
    );
    // 행 차례가 섞여 들어와도 단계 차례로.
    final InterventionState shuffled = interventionStateOf(
      's',
      <InterventionStep>[_p(2, _t0), _p(1, _t0)],
    )!;
    expect(shuffled.steps.map((InterventionStep s) => s.stage), <int>[1, 2]);
    expect(() => shuffled.steps.add(_p(3, _t0)), throwsUnsupportedError);
  });

  test('🔴 끊긴 행 · 닫힌 뒤 행 = 오류', () {
    expect(
      () =>
          interventionStateOf('s', <InterventionStep>[_p(1, _t0), _p(3, _t0)]),
      throwsStateError,
    );
    expect(
      () => interventionStateOf('s', <InterventionStep>[_p(2, _t0)]),
      throwsStateError,
    );
    expect(
      () => interventionStateOf('s', <InterventionStep>[
        InterventionStep(
          stage: 1,
          occurredAtUtc: _t0,
          outcome: InterventionOutcome.doNothing,
        ),
        _p(2, _t0),
      ]),
      throwsStateError,
    );
  });

  test('닫기 = 아무것도 안 하기 · 중단 — 그 단계에서 닫힌다 · 3단계 중단이면 냉각 없음', () {
    final InterventionState s = interventionStateOf('s', <InterventionStep>[
      _p(1, _t0),
      _p(2, _t0),
      InterventionStep(
        stage: 3,
        occurredAtUtc: _t0,
        outcome: InterventionOutcome.abandoned,
        decisionId: 'J',
      ),
    ])!;
    expect(
      (s.closed, s.closedOutcome, s.nextStage, s.coolingEndsAtUtc),
      (true, InterventionOutcome.abandoned, null, null),
    );
    expect(s.journalId, isNull);
    expect(s.liveAt(_t0), isFalse);
  });

  test('판정 차례 — 신뢰 시각 → 닫힘 → 차례 → 한 세션', () {
    expect(_code(null, 1, unknownTime: true), 'TRUSTED_TIME_UNKNOWN');
    expect(_code(_passedTo(5), 6, unknownTime: true), 'TRUSTED_TIME_UNKNOWN');
    expect(_code(_passedTo(5), 6), 'INTERVENTION_CLOSED');
    expect(_code(null, 2), 'INTERVENTION_STAGE_OUT_OF_ORDER');
    expect(_code(null, 0), 'INTERVENTION_STAGE_OUT_OF_ORDER');
    expect(_code(_passedTo(2), 2), 'INTERVENTION_STAGE_OUT_OF_ORDER');
    expect(_code(_passedTo(2), 4), 'INTERVENTION_STAGE_OUT_OF_ORDER');
    expect(_code(null, 1, other: true), 'INTERVENTION_SESSION_OPEN');
    expect(
      _code(null, 1, other: true, outcome: InterventionOutcome.doNothing),
      'INTERVENTION_SESSION_OPEN',
    );
    // 다른 세션이 살아 있어도 이미 연 세션의 다음 단계는 막지 않는다.
    expect(_code(_passedTo(1), 2, other: true), isNull);
    expect(_code(null, 1), isNull);
  });

  test('🔴 아무것도 안 하기 · 중단 = 요건 0 — 냉각 중 · 만료 뒤 · 저널 없음 · 다른 저널', () {
    for (final InterventionOutcome o in <InterventionOutcome>[
      InterventionOutcome.doNothing,
      InterventionOutcome.abandoned,
    ]) {
      expect(_code(_passedTo(2), 3, outcome: o, journal: false), isNull);
      expect(
        _code(
          _passedTo(3),
          4,
          outcome: o,
          now: _t0.add(const Duration(hours: 3)),
        ),
        isNull,
      );
      expect(
        _code(
          _passedTo(4),
          5,
          outcome: o,
          now: _t0.add(const Duration(days: 9)),
        ),
        isNull,
      );
      expect(_code(_passedTo(4), 5, outcome: o, decisionId: null), isNull);
    }
  });

  test('3단계 통과 = 저널 연결', () {
    expect(
      _code(_passedTo(2), 3, journal: false),
      'INTERVENTION_JOURNAL_MISSING',
    );
    expect(_code(_passedTo(2), 3), isNull);
  });

  test('4단계 냉각 경계 — 끝 1µs 전 = 냉각 · 끝 = 통과', () {
    final InterventionState s = _passedTo(3);
    final DateTime end = s.coolingEndsAtUtc!;
    expect(
      _code(s, 4, now: end.subtract(const Duration(microseconds: 1))),
      'INTERVENTION_COOLING',
    );
    expect(_code(s, 4, now: end), isNull);
    expect(_code(s, 4, now: _t0), 'INTERVENTION_COOLING');
  });

  test('🔴 실행 창 경계 — 끝 1µs 전 = 통과 · 끝 = 만료 · 4단계도 만료', () {
    final InterventionState four = _passedTo(4);
    final DateTime end = four.executeWindowEndsAtUtc!;
    final DateTime before = end.subtract(const Duration(microseconds: 1));
    expect(_code(four, 5, now: before), isNull);
    expect(_code(four, 5, now: end), 'INTERVENTION_EXPIRED');
    expect(_code(_passedTo(3), 4, now: end), 'INTERVENTION_EXPIRED');
    expect((four.expiredAt(before), four.expiredAt(end)), (false, true));
    expect((four.liveAt(before), four.liveAt(end)), (true, false));
    // 닫힌 세션은 만료가 아니다(살아 있지도 않다).
    final InterventionState five = _passedTo(5);
    expect((five.expiredAt(end), five.liveAt(_t0)), (false, false));
    // 3단계 전 = 만료 없음.
    expect(_passedTo(2).expiredAt(_t0.add(const Duration(days: 400))), isFalse);
  });

  test('🔴 5단계 통과 = 3단계와 같은 저널', () {
    final InterventionState s = _passedTo(4);
    expect(_code(s, 5, decisionId: 'K'), 'INTERVENTION_JOURNAL_MISSING');
    expect(_code(s, 5, decisionId: null), 'INTERVENTION_JOURNAL_MISSING');
    expect(_code(s, 5), isNull);
  });

  test('🔴 저널 연결 7갈래 — 예산 소진 = 메모(정식 4필드)', () {
    expect(interventionJournalLinked(_j(), budgetExhausted: false), isTrue);
    expect(interventionJournalLinked(null, budgetExhausted: false), isFalse);
    expect(
      interventionJournalLinked(_j(dev: false), budgetExhausted: false),
      isFalse,
    );
    expect(
      interventionJournalLinked(_j(before: ' '), budgetExhausted: false),
      isFalse,
    );
    expect(
      interventionJournalLinked(_j(expected: null), budgetExhausted: false),
      isFalse,
    );
    expect(
      interventionJournalLinked(_j(rule: ''), budgetExhausted: false),
      isFalse,
    );
    expect(
      interventionJournalLinked(_j(used: true), budgetExhausted: false),
      isFalse,
    );
    expect(interventionJournalLinked(_j(), budgetExhausted: true), isFalse);
    expect(
      interventionJournalLinked(_j(note: '  '), budgetExhausted: true),
      isFalse,
    );
    expect(
      interventionJournalLinked(_j(note: '메모'), budgetExhausted: true),
      isTrue,
    );
  });

  test('문지기 = 4단계 통과 ∧ 5단계 전 ∧ 만료 전 ∧ 신뢰 시각 앎', () {
    final InterventionState four = _passedTo(4);
    final DateTime end = four.executeWindowEndsAtUtc!;
    expect(
      interventionExecutable(four, _t0.add(const Duration(hours: 30))),
      isTrue,
    );
    expect(interventionExecutable(four, end), isFalse);
    expect(interventionExecutable(four, null), isFalse);
    expect(
      interventionExecutable(_passedTo(3), _t0.add(const Duration(hours: 30))),
      isFalse,
    );
    expect(interventionExecutable(_passedTo(5), _t0), isFalse);
    expect(interventionExecutable(null, _t0), isFalse);
  });

  test('결과 저장 값 · 상수', () {
    expect(
      InterventionOutcome.values.map((InterventionOutcome o) => o.wire),
      <String>['PASSED', 'DO_NOTHING', 'ABANDONED'],
    );
    expect(
      InterventionOutcome.fromWire('DO_NOTHING'),
      InterventionOutcome.doNothing,
    );
    expect(() => InterventionOutcome.fromWire('SKIP'), throwsFormatException);
    expect(
      (kInterventionCooling, kInterventionExecuteWindow),
      (const Duration(hours: 24), const Duration(hours: 24)),
    );
    expect(
      (kInterventionStages, kJournalStage, kCoolingStage, kExecuteStage),
      (5, 3, 4, 5),
    );
  });
}
