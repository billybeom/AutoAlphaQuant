// E11j — 월 납입 운영값(설계 13 §8 R54 J2~J5 · 01 §2-6 G-05 · 02 §2 N-S4-01 · 픽스처 m9/contribution_setting_*).
import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

ContributionParamRow _row(
  int id,
  int amount,
  String changedAt,
  String effectiveFrom, {
  String? run,
}) => ContributionParamRow(
  rowId: id,
  amount: Decimal.fromInt(amount),
  changedAtUtc: DateTime.parse(changedAt),
  effectiveFrom: effectiveFrom,
  actionRunId: run ?? 'run-$id',
);

void main() {
  group('납입 주기(J2 · G-05)', () {
    test('그 달 첫 KR 세션', () {
      expect(firstKrSessionOfMonth(_kr, 2026, 11), '2026-11-02'); // 11-01 = 일
      expect(firstKrSessionOfMonth(_kr, 2026, 10), '2026-10-01');
      expect(
        firstKrSessionOfMonth(_kr, 2027, 1),
        '2027-01-04',
      ); // 1-1 = 휴장 · 1-2 · 3 = 주말
    });

    test('첫 세션 앞 = 그 달 · 당일이나 뒤 = 다음 달 · 해 넘김', () {
      expect(contributionEffectiveFrom(_kr, '2026-11-01'), '2026-11-02');
      expect(contributionEffectiveFrom(_kr, '2026-11-02'), '2026-12-01');
      expect(contributionEffectiveFrom(_kr, '2026-11-15'), '2026-12-01');
      expect(contributionEffectiveFrom(_kr, '2026-10-31'), '2026-11-02');
      expect(contributionEffectiveFrom(_kr, '2026-12-20'), '2027-01-04');
      expect(nextContributionDay(_kr, '2026-11-04'), '2026-12-01');
    });

    test('한국 날짜', () {
      expect(
        contributionKstDay(DateTime.utc(2026, 11, 1, 14, 59)),
        '2026-11-01',
      );
      expect(contributionKstDay(DateTime.utc(2026, 11, 1, 15)), '2026-11-02');
    });
  });

  group('현재 · 예정(J3 · N-S4-01)', () {
    final List<ContributionParamRow> rows = <ContributionParamRow>[
      _row(1, 90000, '2026-09-02T00:00:00Z', '2026-10-01'),
      _row(2, 100000, '2026-09-07T00:00:00Z', '2026-10-01'),
      _row(3, 150000, '2026-11-04T01:00:00Z', '2026-12-01'),
    ];

    test('🔴 effective_from 이 미래인 행 = 예정 · 현재값에 섞지 않는다', () {
      final (ContributionParamRow? cur, ContributionParamRow? pend) =
          splitContributionRows(rows, '2026-11-04');
      expect((cur!.rowId, pend!.rowId), (2, 3));
      final (ContributionParamRow? cur2, ContributionParamRow? pend2) =
          splitContributionRows(rows, '2026-12-01');
      expect(cur2!.rowId, 3);
      expect(pend2, isNull);
    });

    test('적용 개시일 당일 = 현재 · 앞날 = 이전 값', () {
      expect(splitContributionRows(rows, '2026-09-30').$1, isNull);
      expect(splitContributionRows(rows, '2026-10-01').$1!.rowId, 2);
    });

    test('같은 시각이면 row_id 큰 쪽 · 가장 최근 행 = 예정 포함', () {
      final List<ContributionParamRow> tie = <ContributionParamRow>[
        _row(5, 1, '2026-09-07T00:00:00Z', '2026-10-01'),
        _row(4, 2, '2026-09-07T00:00:00Z', '2026-10-01'),
      ];
      expect(splitContributionRows(tie, '2026-11-04').$1!.rowId, 5);
      expect(latestContributionRow(rows)!.rowId, 3);
      expect(latestContributionRow(const <ContributionParamRow>[]), isNull);
    });

    test('현재값보다 먼저 접수된 예정은 이미 덮였다', () {
      final List<ContributionParamRow> odd = <ContributionParamRow>[
        _row(1, 150000, '2026-09-01T00:00:00Z', '2026-12-01'),
        _row(2, 100000, '2026-09-07T00:00:00Z', '2026-10-01'),
      ];
      final (ContributionParamRow? cur, ContributionParamRow? pend) =
          splitContributionRows(odd, '2026-11-04');
      expect(cur!.rowId, 2);
      expect(pend, isNull);
    });
  });

  group('문장(J4 · 픽스처 꼴)', () {
    final ContributionConfig cfg = p0sContributionConfig();

    test('12% 등가 — 같으면 충족 · 모자라면 부족', () {
      expect(
        contributionEquivalentNoteText(Decimal.fromInt(97000), cfg),
        '12% 등가 납입액 대비 충족합니다.',
      );
      expect(
        contributionEquivalentNoteText(Decimal.fromInt(96999), cfg),
        '12% 등가 납입액 대비 부족합니다.',
      );
      expect(
        contributionEquivalentNoteText(Decimal.zero, cfg),
        '12% 등가 납입액 대비 부족합니다.',
      );
    });

    test('연금 한도 3구간 · 0원 = null', () {
      expect(contributionPensionLimitNoteText(Decimal.zero, cfg), isNull);
      expect(
        contributionPensionLimitNoteText(Decimal.fromInt(750000), cfg),
        '월 납입만으로는 연 합산 납입한도에 닿지 않습니다.',
      );
      expect(
        contributionPensionLimitNoteText(Decimal.fromInt(800000), cfg),
        '월 납입을 1년 모으면 960만원으로 세액공제 대상 구간(900만원)을 넘습니다 — 넘는 몫은 공제되지 않습니다.',
      );
      expect(
        contributionPensionLimitNoteText(Decimal.fromInt(1500000), cfg),
        '월 납입을 1년 모으면 1,800만원으로 세액공제 대상 구간(900만원)을 넘습니다 — 넘는 몫은 공제되지 않습니다.',
      );
      expect(
        contributionPensionLimitNoteText(Decimal.fromInt(1600000), cfg),
        '월 납입을 1년 모으면 1,920만원으로 연 합산 납입한도(1,800만원)를 넘습니다 — 넘는 몫은 연금 계좌에 넣을 수 없습니다.',
      );
    });

    final DateTime obs = DateTime.utc(2026, 11, 4, 3);

    test('기록 없음 = 기본값 · 픽스처 문장', () {
      final ContributionSetting s = contributionSettingOf(
        rows: const <ContributionParamRow>[],
        todayKst: '2026-11-04',
        observedAtUtc: obs,
        kr: _kr,
      );
      expect(s.amount, Decimal.fromInt(100000));
      expect(
        (
          s.amountText,
          s.amountInputText,
          s.equivalentNoteText,
          s.appliesFromText,
          s.lastChangedText,
          s.pensionLimitNoteText,
        ),
        (
          '10만원',
          '100000',
          '12% 등가 납입액 대비 충족합니다.',
          '다음 납입 주기(12월 1일)부터 이 금액이 적용됩니다.',
          '변경 기록 없음(기본값)',
          '월 납입만으로는 연 합산 납입한도에 닿지 않습니다.',
        ),
      );
      expect(
        (
          s.asOf.observedAt,
          s.asOf.tradeDate.yyyyMmDd,
          s.asOf.source,
          s.asOf.staleAfter,
          s.asOf.label,
        ),
        (
          obs,
          '2026-11-04',
          AsOfSource.localSqlite,
          const Duration(hours: 26),
          '설정 기준 2026-11-04',
        ),
      );
    });

    test('🔴 예정은 금액에 넣지 않고 문장으로만 · 최근 변경 = 앞 값 → 새 값', () {
      final List<ContributionParamRow> rows = <ContributionParamRow>[
        _row(1, 90000, '2026-09-01T16:00:00Z', '2026-10-01'),
        _row(2, 100000, '2026-09-06T16:00:00Z', '2026-10-01'),
        _row(3, 150000, '2026-11-04T01:00:00Z', '2026-12-01'),
      ];
      final ContributionSetting before = contributionSettingOf(
        rows: rows.sublist(0, 2),
        todayKst: '2026-11-04',
        observedAtUtc: obs,
        kr: _kr,
      );
      expect(before.amountText, '10만원');
      expect(before.lastChangedText, '최근 변경: 2026-09-07 · 9만원 → 10만원');
      final ContributionSetting s = contributionSettingOf(
        rows: rows,
        todayKst: '2026-11-04',
        observedAtUtc: obs,
        kr: _kr,
      );
      expect(s.amount, Decimal.fromInt(100000));
      expect(s.amountInputText, '100000');
      expect(s.appliesFromText, '다음 납입 주기(12월 1일)부터 15만원이 적용됩니다.');
      expect(s.lastChangedText, '최근 변경: 2026-11-04 · 10만원 → 15만원');
      final ContributionSetting after = contributionSettingOf(
        rows: rows,
        todayKst: '2026-12-01',
        observedAtUtc: obs,
        kr: _kr,
      );
      expect(after.amountText, '15만원');
      expect(after.appliesFromText, '다음 납입 주기(1월 4일)부터 이 금액이 적용됩니다.');
    });

    test('첫 기록 = «정함» · 0원 = 부족 · 한도 줄 없음', () {
      final ContributionSetting one = contributionSettingOf(
        rows: <ContributionParamRow>[
          _row(1, 100000, '2026-09-06T16:00:00Z', '2026-10-01'),
        ],
        todayKst: '2026-11-04',
        observedAtUtc: obs,
        kr: _kr,
      );
      expect(one.lastChangedText, '최근 변경: 2026-09-07 · 10만원으로 정함');
      final ContributionSetting firstChange = contributionSettingOf(
        rows: <ContributionParamRow>[
          _row(1, 150000, '2026-09-06T16:00:00Z', '2026-10-01'),
        ],
        todayKst: '2026-11-04',
        observedAtUtc: obs,
        kr: _kr,
      );
      // 첫 기록의 앞 값 = 기본값.
      expect(firstChange.lastChangedText, '최근 변경: 2026-09-07 · 10만원 → 15만원');
      final ContributionSetting zero = contributionSettingOf(
        rows: <ContributionParamRow>[
          _row(1, 0, '2026-09-06T16:00:00Z', '2026-10-01'),
        ],
        todayKst: '2026-11-04',
        observedAtUtc: obs,
        kr: _kr,
      );
      expect((zero.amountText, zero.amountInputText), ('0원', '0'));
      expect(zero.equivalentNoteText, '12% 등가 납입액 대비 부족합니다.');
      expect(zero.pensionLimitNoteText, isNull);
    });
  });

  group('변경 판정(J5)', () {
    final DateTime t = DateTime.utc(2026, 11, 4, 1); // 한국 11-04
    ContributionDecision decide(
      String input, {
      List<ContributionParamRow> rows = const <ContributionParamRow>[],
      DateTime? now,
      bool unknown = false,
      String run = 'run-x',
    }) => decideContributionChange(
      amountInput: input,
      actionRunId: run,
      rows: rows,
      trustedNowUtc: unknown ? null : (now ?? t),
      kr: _kr,
    );

    test('받아들임 — 적용 개시일 · 접수 시각 · 0 허용 · 쉼표', () {
      final ContributionDecision d = decide('150000');
      expect(
        (d.accepted, d.rejected, d.amount, d.effectiveFrom, d.changedAtUtc),
        (true, false, Decimal.fromInt(150000), '2026-12-01', t),
      );
      expect(decide('0').amount, Decimal.zero);
      expect(decide(' 1,0000 ').amount, Decimal.fromInt(10000));
      expect(
        decide('150000', now: DateTime.utc(2026, 11, 1, 14)).effectiveFrom,
        '2026-11-02',
      );
      expect(
        decide('150000', now: DateTime.utc(2026, 11, 1, 15)).effectiveFrom,
        '2026-12-01',
      );
    });

    test('거부 — 코드 · 엔진 문장', () {
      final List<(String, String, String)> cases = <(String, String, String)>[
        ('', ContributionRejectCodes.blank, '금액을 입력해 주세요.'),
        ('   ', ContributionRejectCodes.blank, '금액을 입력해 주세요.'),
        ('-1', ContributionRejectCodes.negative, '0원 이상으로 입력해 주세요.'),
        ('10만', ContributionRejectCodes.notNumber, '금액을 원 단위 숫자로 입력해 주세요.'),
        ('1e5', ContributionRejectCodes.notNumber, '금액을 원 단위 숫자로 입력해 주세요.'),
        ('１００', ContributionRejectCodes.notNumber, '금액을 원 단위 숫자로 입력해 주세요.'),
        ('1.5', ContributionRejectCodes.notNumber, '금액을 원 단위 숫자로 입력해 주세요.'),
        ('+5', ContributionRejectCodes.notNumber, '금액을 원 단위 숫자로 입력해 주세요.'),
        ('1000000001', ContributionRejectCodes.overMax, '10억원까지 입력할 수 있습니다.'),
        ('100000', ContributionRejectCodes.unchanged, '지금 금액과 같습니다.'),
      ];
      for (final (String input, String code, String text) in cases) {
        final ContributionDecision d = decide(input);
        expect(
          (d.rejected, d.accepted, d.reasonCode, d.rejectedText),
          (true, false, code, text),
          reason: input,
        );
      }
      expect(decide('1000000000').accepted, isTrue);
    });

    test('🔴 신뢰 시각 모름 = 거부(입력 검사 뒤)', () {
      final ContributionDecision d = decide('150000', unknown: true);
      expect(d.reasonCode, ContributionRejectCodes.trustedTimeUnknown);
      expect(d.rejectedText, contains('서버 시각'));
      expect(
        decide('x', unknown: true).reasonCode,
        ContributionRejectCodes.notNumber,
      );
    });

    test('바뀌는 게 없음 = 가장 최근 행(예정 포함)과 같음 · 예정을 지금 값으로 되돌리기 = 받아들임', () {
      final List<ContributionParamRow> rows = <ContributionParamRow>[
        _row(1, 100000, '2026-09-07T00:00:00Z', '2026-10-01'),
        _row(2, 150000, '2026-11-03T00:00:00Z', '2026-12-01'),
      ];
      expect(
        decide('150000', rows: rows).reasonCode,
        ContributionRejectCodes.unchanged,
      );
      expect(decide('100000', rows: rows).accepted, isTrue);
    });

    test('🔴 신뢰 시각이 마지막 기록보다 앞서지 않으면 거부(같은 순간 · 되감김)', () {
      final List<ContributionParamRow> rows = <ContributionParamRow>[
        _row(1, 100000, '2026-11-04T01:00:00Z', '2026-12-01'),
      ];
      expect(
        decide('150000', rows: rows).reasonCode,
        ContributionRejectCodes.clockNotAdvanced,
      );
      expect(
        decide(
          '150000',
          rows: rows,
          now: DateTime.utc(2026, 11, 3),
        ).rejectedText,
        '방금 바뀐 기록이 있습니다. 잠시 뒤 다시 시도해 주세요.',
      );
      expect(
        decide(
          '150000',
          rows: rows,
          now: t.add(const Duration(milliseconds: 1)),
        ).accepted,
        isTrue,
      );
    });

    test('같은 회차 재시도 = 이미 있는 행(입력이 달라도)', () {
      final List<ContributionParamRow> rows = <ContributionParamRow>[
        _row(7, 150000, '2026-11-03T00:00:00Z', '2026-12-01', run: 'run-x'),
      ];
      final ContributionDecision d = decide('999', rows: rows);
      expect((d.replay!.rowId, d.accepted, d.rejected), (7, false, false));
    });
  });

  test('저장 칸 → 행 · config', () {
    final ContributionParamRow r = contributionParamRowFromColumns(
      rowId: 3,
      valueText: '150000',
      changedAtText: '2026-11-04T01:00:00.000Z',
      effectiveFrom: '2026-12-01',
      actionRunId: 'run-3',
    );
    expect(
      (r.rowId, r.amount, r.changedAtUtc, r.effectiveFrom, r.actionRunId),
      (
        3,
        Decimal.fromInt(150000),
        DateTime.utc(2026, 11, 4, 1),
        '2026-12-01',
        'run-3',
      ),
    );
    final ContributionConfig c = p0sContributionConfig();
    expect(
      (
        c.defaultAmount,
        c.equivalentAmount,
        c.maxAmount,
        c.pensionAnnualLimit,
        c.taxCreditBand,
      ),
      (
        Decimal.fromInt(100000),
        Decimal.fromInt(97000),
        Decimal.fromInt(1000000000),
        Decimal.fromInt(18000000),
        Decimal.fromInt(9000000),
      ),
    );
  });
}
