// E13f1 — 재량 예산 SAF-409 판정 · 예산 셈 · 게이지 문장(설계 13 §8 R64 W2 · W3 · W6 · W7).
//
// 🔵 잡는 것: ① 창 첫날 = 연 −1 같은 월·일(포함) · 2월 29일 ② 회복일(평일 · 2월 29일 · 연말)
//    ③ 조정폭 경계 · NaN · 무한 = 상한 밖 ④ 사유 전부 · 오름차순 ⑤ 저널 연결 6갈래
//    ⑥ 예산(사용 0 · 2 · 4 · 6 — X7 초과) · 다음 회복일의 차례 ⑦ 게이지 문장 4갈래 ⑧ 형식 오류.
import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

DiscretionJournalFacts _j({
  String? kind = 'DISCRETION',
  String? before = '근거',
  String? expected = '기대',
  String? rule = 'RULE_DISCRETION_BUDGET',
  bool used = false,
}) => DiscretionJournalFacts(
  kind: kind,
  rationaleBefore: before,
  expectedOutcome: expected,
  ruleCited: rule,
  alreadyUsed: used,
);

void main() {
  test('창 첫날 = 연 −1 같은 월·일 · 경계일 포함 · 2월 29일 = 3월 1일처럼', () {
    expect(discretionWindowStart('2026-08-24'), '2025-08-24');
    expect(discretionWindowStart('2028-02-29'), '2027-02-29');
    expect(
      rollingDiscretionUses(<String>[
        '2025-08-23',
        '2025-08-24',
        '2026-08-24',
      ], '2026-08-24'),
      2,
    );
    // 오늘 2029-02-28: 창 첫날 2028-02-28 → 2028-02-29 사용은 든다 · 3월 1일: 창 첫날 2028-03-01 → 빠진다.
    expect(rollingDiscretionUses(<String>['2028-02-29'], '2029-02-28'), 1);
    expect(rollingDiscretionUses(<String>['2028-02-29'], '2029-03-01'), 0);
  });

  test('회복일 = 창에서 빠지는 첫날 — 평일 · 2월 29일 · 연말', () {
    expect(discretionRecoveryDate('2025-08-24'), '2026-08-25');
    expect(discretionRecoveryDate('2028-02-29'), '2029-03-01');
    expect(discretionRecoveryDate('2025-12-31'), '2027-01-01');
    expect(discretionRecoveryDate('2027-02-28'), '2028-02-29');
    for (final String u in <String>['2025-08-24', '2028-02-29', '2025-12-31']) {
      final String r = discretionRecoveryDate(u);
      expect(rollingDiscretionUses(<String>[u], r), 0, reason: u);
    }
    expect(rollingDiscretionUses(<String>['2025-08-24'], '2026-08-24'), 1);
  });

  test('조정폭 — ±0.10 통과 · 넘으면 거부 · NaN · 무한 = 상한 밖', () {
    DiscretionJudgement j(double d) => judgeDiscretion(
      deltaPct: d,
      journalLinked: true,
      priorUseDates: const <String>[],
      today: '2026-08-24',
    );
    expect(j(0.10).applies, isTrue);
    expect(j(-0.10).applies, isTrue);
    for (final double d in <double>[
      0.1001,
      -0.1001,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(j(d).rejectReasons, <String>['DELTA_EXCEEDED'], reason: '$d');
    }
  });

  test('🔴 사유 = 전부 · 오름차순(넣는 차례와 달라도)', () {
    final DiscretionJudgement j = judgeDiscretion(
      deltaPct: 0.2,
      journalLinked: false,
      priorUseDates: const <String>[
        '2026-01-01',
        '2026-02-01',
        '2026-03-01',
        '2026-04-01',
      ],
      today: '2026-08-24',
    );
    expect(j.rejectReasons, <String>[
      'COUNT_EXCEEDED',
      'DELTA_EXCEEDED',
      'JOURNAL_MISSING',
    ]);
    expect(j.rolling12mCount, 4);
    expect(() => j.rejectReasons.add('X'), throwsUnsupportedError);
  });

  test('🔴 저널 연결 = 행 · DISCRETION · 사전 3필드 · 한 번만', () {
    expect(discretionJournalLinked(_j()), isTrue);
    expect(discretionJournalLinked(null), isFalse);
    expect(discretionJournalLinked(_j(kind: 'KILL_SWITCH_RESUME')), isFalse);
    expect(discretionJournalLinked(_j(kind: null)), isFalse);
    expect(discretionJournalLinked(_j(before: '  ')), isFalse);
    expect(discretionJournalLinked(_j(expected: null)), isFalse);
    expect(discretionJournalLinked(_j(rule: '')), isFalse);
    expect(discretionJournalLinked(_j(used: true)), isFalse);
  });

  test('예산 — 사용 0 · 2 · 4 · 6(X7 초과) · 다음 회복일 = 남은 횟수가 느는 날', () {
    final DiscretionBudget zero = discretionBudgetOf(const <String>[
      '2025-01-01',
    ], '2026-08-24');
    expect(
      (zero.used, zero.remaining, zero.exhausted, zero.nextRecoveryDate),
      (0, 4, false, null),
    );
    final DiscretionBudget two = discretionBudgetOf(const <String>[
      '2026-05-20',
      '2025-10-01',
    ], '2026-08-24');
    expect(
      (two.used, two.remaining, two.exhausted, two.nextRecoveryDate),
      (2, 2, false, '2026-10-02'),
    );
    final DiscretionBudget four = discretionBudgetOf(const <String>[
      '2026-06-15',
      '2025-11-10',
      '2026-03-01',
      '2025-12-05',
    ], '2026-08-24');
    expect(
      (four.used, four.remaining, four.exhausted, four.nextRecoveryDate),
      (4, 0, true, '2026-11-11'),
    );
    // 6회 = 셋이 빠져야 1회가 남는다 → 셋째로 오래된 사용의 회복일.
    final DiscretionBudget six = discretionBudgetOf(const <String>[
      '2026-06-15',
      '2025-11-10',
      '2026-03-01',
      '2025-12-05',
      '2026-07-01',
      '2026-08-01',
    ], '2026-08-24');
    expect(
      (six.used, six.remaining, six.exhausted, six.nextRecoveryDate),
      (6, 0, true, '2027-03-02'),
    );
    expect(six.max, 4);
    // 창 첫날 사용 = 든다(판정 셈과 같은 경계) · 하루 전 = 빠진다.
    final DiscretionBudget edge = discretionBudgetOf(const <String>[
      '2025-08-24',
      '2025-08-23',
    ], '2026-08-24');
    expect((edge.used, edge.nextRecoveryDate), (1, '2026-08-25'));
  });

  test('게이지 문장 — 사용 0 · 사용 · 소진 · 신뢰 시각 모름', () {
    expect(
      discretionBudgetText(discretionBudgetOf(const <String>[], '2026-08-24')),
      '재량 예산 12개월 4회 중 0회 사용',
    );
    expect(
      discretionBudgetText(
        discretionBudgetOf(const <String>['2025-10-01'], '2026-08-24'),
      ),
      '재량 예산 12개월 4회 중 1회 사용 · 다음 회복 2026-10-02',
    );
    expect(
      discretionBudgetText(
        discretionBudgetOf(const <String>[
          '2025-11-10',
          '2025-12-05',
          '2026-03-01',
          '2026-06-15',
        ], '2026-08-24'),
      ),
      '재량 예산 소진 — 12개월 4회 중 4회 사용 · 다음 회복 2026-11-11',
    );
    expect(discretionBudgetText(null), '재량 예산 — 신뢰 시각 확인 중');
  });

  test('형식 오류 = 던진다(지어내지 않는다)', () {
    expect(() => discretionWindowStart('2026-8-24'), throwsFormatException);
    expect(() => discretionWindowStart('2026-08-24T00'), throwsFormatException);
    expect(() => discretionRecoveryDate('20260824'), throwsFormatException);
  });

  test('상수 = 04 §1 SAF-409 표', () {
    expect((kDiscretionMaxDelta, kDiscretionMaxUses), (0.10, 4));
    expect(kDiscretionJournalKind, 'DISCRETION');
  });
}
