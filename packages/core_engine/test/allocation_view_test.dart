// 미결 192 — M9 S04 배분 화면 첫 판(보기 전용) VM · `rm_config_view` S04 열(설계 13 §8 R190).
//
// ✅ E11q-s04a(설계 13 §8 R211) — 엔진이 계약 v1.28 `AllocationEditorVm` 을 직접 낸다(엔진 지역 타입 0) · 계약 표본
//    (`m9/allocation_editor*`)과 대조 · 행 코드 = 계약 `AllocationRowCodes` 차례 · 열 이름 = 계약 `AllocationReadModelColumns` ·
//    운영 경로 = 설정 필수 입구 `allocationEditorVmOfConfig`(K206).
// 🔴 값 = 운영 설정 객체(정본 P0S) · 같은 값의 다른 원천(What-if 목표 비중 · S01 카드 · 온보딩 정직 기대 줄)과 두 벌 0.
// 🔴 첫 판에 없는 것 = 칸 · 글자 0(프리셋 · 슬라이더 · 미리보기 · 적용 · 옛 판 수치).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

/// 2026-11-20 18:30 KST(= 계약 표본 `m9/allocation_editor` 의 `as_of.observed_at`).
final DateTime _now = DateTime.utc(2026, 11, 20, 9, 30);

const String _fx = '../domain_contracts/fixtures/m9';

/// 계약 표본 봉투의 VM 한 행.
AllocationEditorVm _fixture(String file) {
  final Map<String, Object?> env =
      jsonDecode(File('$_fx/$file').readAsStringSync()) as Map<String, Object?>;
  final List<Object?> rows = env['rows']! as List<Object?>;
  return AllocationEditorVm.fromJson(rows.single! as Map<String, Object?>);
}

P0sHumanInputs _human() => P0sHumanInputs(
  aSymbol: '999990',
  accountByStrategy: <String, String>{
    P0sStrategyIds.sleeveA: 'acct_x',
    P0sStrategyIds.sleeveB: 'acct_pension',
    P0sStrategyIds.sleeveC: 'acct_general',
    P0sStrategyIds.pot: 'acct_x',
  },
);

Map<String, Map<String, Object?>> _rowsByCode(AllocationEditorVm v) =>
    <String, Map<String, Object?>>{
      for (final AllocationReadOnlySection s in v.sections)
        for (final AllocationReadOnlyRow r in s.rows)
          r.code: <String, Object?>{
            'section': s.title,
            'label': r.label,
            'value': r.valueText,
            'note': r.noteText,
          },
    };

List<String> _allTexts(AllocationEditorVm v) => <String>[
  v.current.label,
  v.current.weightsText,
  v.current.backtestText,
  v.current.honestNoteText,
  for (final AllocationReadOnlySection s in v.sections) ...<String>[
    s.title,
    for (final AllocationReadOnlyRow r in s.rows) ...<String>[
      r.label,
      r.valueText,
      ?r.noteText,
    ],
  ],
  ...v.changePathLines,
  v.asOf.label,
];

/// 정본 월말 설정에서 몇 칸만 바꾼다(나머지 = 정본 그대로).
MonthEndConfig _monthEnd({
  Decimal? allocB,
  Decimal? coreBand,
  int? rampMonths,
  Decimal? maxGoldPctOfTotal,
  Decimal? cRelativeBand,
}) {
  final MonthEndConfig m = p0sMonthEndConfig();
  return MonthEndConfig(
    allocB: allocB ?? m.allocB,
    coreBand: coreBand ?? m.coreBand,
    rampMonths: rampMonths ?? m.rampMonths,
    bAssets: m.bAssets,
    lookbackMonths: m.lookbackMonths,
    assist: m.assist,
    cBondSymbol: m.cBondSymbol,
    cGoldSymbol: m.cGoldSymbol,
    cBondWeight: m.cBondWeight,
    cGoldWeight: m.cGoldWeight,
    maxGoldPctOfTotal: maxGoldPctOfTotal ?? m.maxGoldPctOfTotal,
    cRelativeBand: cRelativeBand ?? m.cRelativeBand,
    bOrderThreshold: m.bOrderThreshold,
    cOrderThreshold: m.cOrderThreshold,
    potOrderThreshold: m.potOrderThreshold,
    topupMinFraction: m.topupMinFraction,
    krwUsableFraction: m.krwUsableFraction,
    pensionAnnualLimit: m.pensionAnnualLimit,
    pensionFunding: m.pensionFunding,
    bSellCostRate: m.bSellCostRate,
    cSellCostRate: m.cSellCostRate,
    potCostRate: m.potCostRate,
  );
}

/// [allocationViewColumns] 를 손으로 되읽는다(시험 전용 — 뷰어 판 = `read_model_client` `allocationEditorVmFromColumns`).
AllocationEditorVm _fromColumns(Map<String, Object?> row) => AllocationEditorVm(
  current: AllocationProfileCard(
    label: row[AllocationReadModelColumns.label]! as String,
    weightsText: row[AllocationReadModelColumns.weightsText]! as String,
    backtestText: row[AllocationReadModelColumns.backtestText]! as String,
    honestNoteText: row[AllocationReadModelColumns.honestNoteText]! as String,
  ),
  sections: <AllocationReadOnlySection>[
    for (final Map<String, Object?> s
        in (row[AllocationReadModelColumns.sections]! as List<Object?>)
            .cast<Map<String, Object?>>())
      AllocationReadOnlySection(
        title: s['title']! as String,
        rows: <AllocationReadOnlyRow>[
          for (final Map<String, Object?> r
              in (s['rows']! as List<Object?>).cast<Map<String, Object?>>())
            AllocationReadOnlyRow(
              code: r['code']! as String,
              label: r['label']! as String,
              valueText: r['value_text']! as String,
              noteText: r['note_text'] as String?,
            ),
        ],
      ),
  ],
  changePathLines: <String>[
    for (final Object? l
        in row[AllocationReadModelColumns.changePathLines]! as List<Object?>)
      l! as String,
  ],
  asOf: AsOf.fromJson(
    row[AllocationReadModelColumns.asOf]! as Map<String, Object?>,
  ),
);

void main() {
  test('S04 첫 판 VM = 엔진 글자 표(정본 P0S · 운영 설정 값 · 묶음 셋 · 받은 순서)', () {
    final AllocationEditorVm v = allocationViewOf(nowUtc: _now);
    expect(v.current.label, 'balanced(P0S)');
    expect(v.current.weightsText, 'A 20% · B 42% · C 38%(나머지) · 새틀라이트 0%(꺼짐)');
    expect(
      v.current.backtestText,
      '백테스트 26.6년(2000~2026 · 세금 전) 연 11.13% · 최대 낙폭 −12.60%',
    );
    expect(
      v.current.honestNoteText,
      '백테스트 점추정이며 앞으로의 약속이 아닙니다. '
      '규칙을 지켰을 때의 기대치는 전 계좌 세후 10.2% 안팎(최악 9.7%)입니다.',
    );
    expect(
      v.sections.map((AllocationReadOnlySection s) => s.title).toList(),
      <String>['리밸런싱 밴드', '리스크 한도', '금 상한'],
    );
    expect(
      <List<String>>[
        for (final AllocationReadOnlySection s in v.sections)
          <String>[for (final AllocationReadOnlyRow r in s.rows) r.code],
      ],
      <List<String>>[
        <String>[
          AllocationRowCodes.bandCoreB,
          AllocationRowCodes.bandSleeveC,
          AllocationRowCodes.bandSatellite,
        ],
        <String>[
          AllocationRowCodes.riskDrawdown,
          AllocationRowCodes.riskDailyLoss,
          AllocationRowCodes.riskExposure,
          AllocationRowCodes.riskDefensiveFloor,
          AllocationRowCodes.riskOrderCaps,
        ],
        <String>[
          AllocationRowCodes.goldSleeveCCap,
          AllocationRowCodes.goldTotalMonitor,
        ],
      ],
    );
    final Map<String, Map<String, Object?>> rows = _rowsByCode(v);
    expect(rows[AllocationRowCodes.bandCoreB], <String, Object?>{
      'section': '리밸런싱 밴드',
      'label': '슬리브 B 코어 밴드',
      'value': '목표 42% ± 3%p',
      'note': '월 1회 판정합니다. 밴드를 벗어나면 목표 비중으로 되돌립니다. 처음 6개월 적립 기간에는 판정하지 않습니다.',
    });
    expect(rows[AllocationRowCodes.bandSleeveC], <String, Object?>{
      'section': '리밸런싱 밴드',
      'label': '슬리브 C 안 리밸런싱 문턱',
      'value': '종목 목표의 ±16.7%',
      'note': '채권 · 금이 각자 목표에서 이 폭 안에 있으면 사고팔지 않습니다.',
    });
    expect(rows[AllocationRowCodes.bandSatellite], <String, Object?>{
      'section': '리밸런싱 밴드',
      'label': '새틀라이트 밴드',
      'value': '해당 없음',
      'note': '새틀라이트를 쓰지 않아(0%) 밴드를 판정하지 않습니다.',
    });
    expect(rows[AllocationRowCodes.riskDrawdown], <String, Object?>{
      'section': '리스크 한도',
      'label': '낙폭 단계(서킷브레이커)',
      'value': '경보 −15% · 축소 운용 −20% · 중지 −25% · 정지 −35%',
      'note': '고점 대비 총자산 낙폭 기준입니다.',
    });
    expect(rows[AllocationRowCodes.riskDailyLoss], <String, Object?>{
      'section': '리스크 한도',
      'label': '하루 손실 한도',
      'value': '−3%',
      'note': '그날 손실이 이 선에 닿으면 그날 새 매수를 막습니다.',
    });
    expect(rows[AllocationRowCodes.riskExposure], <String, Object?>{
      'section': '리스크 한도',
      'label': '위험자산 비중 상한',
      'value': '85%',
      'note': '매수 뒤 위험자산 비중이 이 선을 넘으면 그 매수를 막습니다.',
    });
    expect(rows[AllocationRowCodes.riskDefensiveFloor], <String, Object?>{
      'section': '리스크 한도',
      'label': '방어 비중 하한',
      'value': '10%',
      'note': '방어 자산(슬리브 C) 비중이 이 선 밑으로 내려가면 알림을 냅니다. 주문은 막지 않습니다.',
    });
    expect(rows[AllocationRowCodes.riskOrderCaps], <String, Object?>{
      'section': '리스크 한도',
      'label': '주문 한도',
      'value': '하루 60건 · 한 건 2,000만원',
      'note': '넘는 주문은 보내지 않습니다.',
    });
    expect(rows[AllocationRowCodes.goldSleeveCCap], <String, Object?>{
      'section': '금 상한',
      'label': '금 상한 — 슬리브 C 안',
      'value': '총자산의 8%',
      'note': '하드 캡입니다. 넘는 몫은 금 대신 원화 현금성으로 둡니다. 슬리브 B 의 금은 세지 않습니다.',
    });
    expect(rows[AllocationRowCodes.goldTotalMonitor], <String, Object?>{
      'section': '금 상한',
      'label': '금 총비중 감시선',
      'value': '총자산의 20%',
      'note':
          '하드 캡이 아니라 감시선입니다. 슬리브 B 몫까지 합친 금 전체가 이 선을 넘으면 알림을 냅니다. 주문은 막지 않습니다.',
    });
    expect(v.changePathLines, <String>[
      '배분은 이 화면에서 바꾸지 않습니다. 12월 연간 리뷰에서 PC 백테스트 근거로 바꿉니다.',
      '바꾼 설정은 규칙 변경 승인을 거쳐야 쓰입니다(냉각 30일 · 12월 승인 창).',
      '급한 노출 조정은 배분이 아니라 재량 예산으로 합니다(한 번 ±10%p · 12개월에 4회).',
    ]);
    expect(
      v.asOf,
      AsOf(
        observedAt: _now,
        tradeDate: const TradeDate('2026-11-20'),
        source: AsOfSource.localSqlite,
        staleAfter: const Duration(hours: 26),
        label: '설정 기준 2026-11-20 18:30',
      ),
    );
  });

  test('기준 시각 = 한국 날짜 · 분(UTC 자정 앞뒤) · UTC 아닌 입력도 UTC 로', () {
    final AllocationEditorVm v = allocationViewOf(
      nowUtc: DateTime.utc(2026, 11, 20, 15, 5),
    );
    expect(v.asOf.tradeDate, const TradeDate('2026-11-21'));
    expect(v.asOf.label, '설정 기준 2026-11-21 00:05');
    expect(v.asOf.observedAt.isUtc, isTrue);
    final AllocationEditorVm local = allocationViewOf(nowUtc: _now.toLocal());
    expect(local.asOf.observedAt, _now);
    expect(local.asOf.observedAt.isUtc, isTrue);
  });

  test('값은 설정 객체에서 — 월말 · 한도 · 브레이커 · 경고 문턱을 바꾸면 글자가 따라온다(리터럴 0)', () {
    final LimitConfig base = p0sLimitConfig();
    final AllocationEditorVm v = allocationViewOf(
      nowUtc: _now,
      monthEnd: _monthEnd(
        allocB: Decimal.parse('0.50'),
        coreBand: Decimal.parse('0.025'),
        rampMonths: 4,
        maxGoldPctOfTotal: Decimal.parse('0.07'),
        cRelativeBand: Decimal.parse('0.125'),
      ),
      limits: LimitConfig(
        maxNotionalPct: base.maxNotionalPct,
        riskBudgetPct: base.riskBudgetPct,
        satelliteMaxPositions: base.satelliteMaxPositions,
        satelliteMaxPerSector: base.satelliteMaxPerSector,
        maxRiskExposure: 0.8,
        maxLeverage: base.maxLeverage,
        maxPositions: base.maxPositions,
        maxOrdersPerDay: 40,
        maxOrderValueKrw: Decimal.fromInt(15000000),
        maxDailyLossPct: 0.025,
        orderTypeWhitelist: base.orderTypeWhitelist,
      ),
      breaker: BreakerConfig(
        alertDd: -0.12,
        reduceDd: -0.18,
        haltDd: -0.24,
        stopDd: -0.3,
        alertReleaseDd: -0.1,
        reduceReleaseDd: -0.1,
        haltReleaseDd: -0.12,
        recoverHoldBars: 20,
        haltReleaseBullStreak: 3,
        stopReleaseDd: -0.2,
        stopReleaseBullStreak: 5,
      ),
      warn: const P0sWarnConfig(
        minDefensivePct: 0.12,
        goldTotalMonitorPct: 0.18,
        usdBaselinePct: 0.5,
        krwLiquidityFloorPct: 0.01,
      ),
    );
    expect(v.current.weightsText, 'A 20% · B 50% · C 30%(나머지) · 새틀라이트 0%(꺼짐)');
    final Map<String, Map<String, Object?>> rows = _rowsByCode(v);
    expect(rows[AllocationRowCodes.bandCoreB]!['value'], '목표 50% ± 2.5%p');
    expect(
      rows[AllocationRowCodes.bandCoreB]!['note'],
      contains('처음 4개월 적립 기간'),
    );
    expect(rows[AllocationRowCodes.bandSleeveC]!['value'], '종목 목표의 ±12.5%');
    expect(
      rows[AllocationRowCodes.riskDrawdown]!['value'],
      '경보 −12% · 축소 운용 −18% · 중지 −24% · 정지 −30%',
    );
    expect(rows[AllocationRowCodes.riskDailyLoss]!['value'], '−2.5%');
    expect(rows[AllocationRowCodes.riskExposure]!['value'], '80%');
    expect(rows[AllocationRowCodes.riskDefensiveFloor]!['value'], '12%');
    expect(
      rows[AllocationRowCodes.riskOrderCaps]!['value'],
      '하루 40건 · 한 건 1,500만원',
    );
    expect(rows[AllocationRowCodes.goldSleeveCCap]!['value'], '총자산의 7%');
    expect(rows[AllocationRowCodes.goldTotalMonitor]!['value'], '총자산의 18%');
  });

  test('잔여 C(1 − A − B) 음수 = 배분 설정 오류(정규화하지 않는다) · 0 은 받는다', () {
    expect(
      () => allocationViewOf(
        nowUtc: _now,
        monthEnd: _monthEnd(allocB: Decimal.parse('0.81')),
      ),
      throwsArgumentError,
    );
    expect(
      allocationViewOf(
        nowUtc: _now,
        monthEnd: _monthEnd(allocB: Decimal.parse('0.80')),
      ).current.weightsText,
      'A 20% · B 80% · C 0%(나머지) · 새틀라이트 0%(꺼짐)',
    );
  });

  test('같은 값의 다른 원천과 두 벌 0 — What-if 목표 비중 · S01 카드 · 온보딩 정직 기대 · 경고 문턱', () {
    final AllocationEditorVm v = allocationViewOf(nowUtc: _now);
    final Map<SleeveId, Decimal> w = WhatIfConfig.defaults.targetWeights;
    expect(w[SleeveId.a], kP0sAllocA);
    expect(w[SleeveId.b], p0sMonthEndConfig().allocB);
    expect(
      v.current.weightsText,
      'A ${(w[SleeveId.a]! * Decimal.fromInt(100)).toString()}% · '
      'B ${(w[SleeveId.b]! * Decimal.fromInt(100)).toString()}% · '
      'C ${(w[SleeveId.c]! * Decimal.fromInt(100)).toString()}%(나머지) · 새틀라이트 0%(꺼짐)',
    );
    expect(v.current.label, kSettingsAllocationLabel);
    expect(v.current.backtestText, kP0sBacktestText);
    final OnboardingFinishVm finish = onboardingFinishVmOf(
      const OnboardingFinishFacts(
        mode: OperatingMode.autoTrade,
        committed: false,
        pledged: false,
        openingDeclared: false,
      ),
    );
    expect(finish.stages.first.expectationLine, kP0sHonestExpectationLine);
    expect(
      onboardingModeChoiceVmOf(selected: null, committed: false).honestyText,
      startsWith(kP0sHonestExpectationLine),
    );
    expect(v.current.honestNoteText, endsWith(kP0sHonestExpectationLine));
    // 금 두 행의 원천 = 월말 계획기 하드 캡 · 일간 경고 감시선(경고 단계와 같은 객체).
    expect(p0sMonthEndConfig().maxGoldPctOfTotal, Decimal.parse('0.08'));
    expect(p0sWarnConfig().goldTotalMonitorPct, 0.20);
  });

  test(
    '첫 판에 없는 것 — 프리셋 · 옛 판 수치 · 슬라이더 · 미리보기 · 적용 글자 0 · 금 상한 = 두 행(합치지 않는다)',
    () {
      final AllocationEditorVm v = allocationViewOf(nowUtc: _now);
      final String all = _allTexts(v).join('\n');
      for (final String banned in <String>[
        'defensive',
        'aggressive',
        'custom',
        '7.92',
        '8.40',
        '9.22',
        '−10.83',
        '−14.78',
        '−17.26',
        '미리보기',
        '적용하기',
        '평가손익',
        '평가액',
        '수익률',
      ]) {
        expect(all, isNot(contains(banned)), reason: banned);
      }
      final List<AllocationReadOnlyRow> gold = v.sections
          .singleWhere((AllocationReadOnlySection s) => s.title == '금 상한')
          .rows;
      expect(gold, hasLength(2));
      expect(gold.first.valueText, isNot(gold.last.valueText));
      expect(gold.first.noteText, contains('하드 캡입니다'));
      expect(gold.last.noteText, contains('하드 캡이 아니라 감시선'));
      final Set<String> codes = _rowsByCode(v).keys.toSet();
      expect(codes, hasLength(10));
    },
  );

  test('rm_config_view S04 열 — 이름 · JSON 꼴 · 열만으로 같은 VM 을 되짓는다(G-22 상위집합) · 규칙 5조 칸은 push 층', () {
    final AllocationEditorVm v = allocationViewOf(nowUtc: _now);
    final Map<String, Object?> row = allocationViewColumns(v);
    expect(row.keys.toList(), AllocationReadModelColumns.all);
    expect(AllocationReadModelColumns.all, <String>[
      'allocation_label',
      'allocation_weights_text',
      'allocation_backtest_text',
      'allocation_honest_note_text',
      'allocation_sections',
      'allocation_change_path_lines',
      'allocation_as_of',
    ]);
    for (final String k in <String>[
      'row_version',
      'lease_epoch',
      'pushed_at',
      'mode',
      'schema_version',
      'hash_format_version',
      'contract_version',
    ]) {
      expect(row.containsKey(k), isFalse, reason: k);
    }
    // 원격으로 갔다 온 꼴(JSON 문자열 왕복)에서 되짓는다.
    final Map<String, Object?> wire =
        jsonDecode(jsonEncode(row)) as Map<String, Object?>;
    final AllocationEditorVm back = _fromColumns(wire);
    expect(allocationViewColumns(back), wire);
    expect(back.current.label, v.current.label);
    expect(back.current.weightsText, v.current.weightsText);
    expect(back.current.backtestText, v.current.backtestText);
    expect(back.current.honestNoteText, v.current.honestNoteText);
    expect(_rowsByCode(back), _rowsByCode(v));
    expect(
      back.sections.map((AllocationReadOnlySection s) => s.title).toList(),
      v.sections.map((AllocationReadOnlySection s) => s.title).toList(),
    );
    expect(back.changePathLines, v.changePathLines);
    expect(back.asOf, v.asOf);
    // 묶음 JSON 꼴(행 키 4 · 덧붙임 없음 = null 칸으로 싣는다).
    final List<Object?> sections =
        wire[AllocationReadModelColumns.sections]! as List<Object?>;
    final Map<String, Object?> firstRow =
        ((sections.first! as Map<String, Object?>)['rows']! as List<Object?>)
                .first!
            as Map<String, Object?>;
    expect(firstRow.keys.toList(), <String>[
      'code',
      'label',
      'value_text',
      'note_text',
    ]);
    final AllocationEditorVm noNote = AllocationEditorVm(
      current: v.current,
      sections: const <AllocationReadOnlySection>[
        AllocationReadOnlySection(
          title: 't',
          rows: <AllocationReadOnlyRow>[
            AllocationReadOnlyRow(code: 'X', label: 'l', valueText: 'v'),
          ],
        ),
      ],
      changePathLines: const <String>[],
      asOf: v.asOf,
    );
    final Map<String, Object?> nr = jsonDecode(
      jsonEncode(allocationViewColumns(noNote)),
    ) as Map<String, Object?>;
    final Map<String, Object?> only =
        (((nr[AllocationReadModelColumns.sections]! as List<Object?>).first!
                        as Map<String, Object?>)['rows']!
                    as List<Object?>)
                .first!
            as Map<String, Object?>;
    expect(only.containsKey('note_text'), isTrue);
    expect(only['note_text'], isNull);
    expect(_fromColumns(nr).sections.single.rows.single.noteText, isNull);
  });

  test('🆕 표본 대조 — 계약 표본 `m9/allocation_editor` 와 같은 VM(카드 · 묶음 셋 · 행 10 · 바꾸는 길 3 · 기준 시각)', () {
    final AllocationEditorVm fx = _fixture('allocation_editor.json');
    final AllocationEditorVm v = allocationViewOf(nowUtc: fx.asOf.observedAt);
    expect(v, fx);
    expect(v.sections, hasLength(3));
    expect(
      v.sections.map((AllocationReadOnlySection s) => s.rows.length).toList(),
      <int>[3, 5, 2],
    );
    expect(v.changePathLines, hasLength(3));
    // 오래된 판 표본 = 같은 글자 · 기준 시각만 다르다(낡음 판정 = 화면 몫 · VM 글자는 시각과 무관).
    final AllocationEditorVm stale = _fixture('allocation_editor_stale.json');
    expect(stale.copyWith(asOf: fx.asOf), fx);
    expect(
      allocationViewOf(nowUtc: stale.asOf.observedAt).copyWith(asOf: fx.asOf),
      fx,
    );
  });

  test('🆕 사전 · 열 글자 같음 — 행 코드 차례 = 계약 `AllocationRowCodes.ordered` · 열 = `AllocationReadModelColumns.all`', () {
    final AllocationEditorVm v = allocationViewOf(nowUtc: _now);
    final List<String> codes = <String>[
      for (final AllocationReadOnlySection s in v.sections)
        for (final AllocationReadOnlyRow r in s.rows) r.code,
    ];
    expect(codes, AllocationRowCodes.ordered);
    expect(codes.toSet(), AllocationRowCodes.values);
    expect(
      allocationViewColumns(v).keys.toList(),
      AllocationReadModelColumns.all,
    );
    // 묶음 열의 행 = 계약 `AllocationReadOnlyRow.toJson()` 과 같은 키 · 값(덧붙임 있는 행).
    final Map<String, Object?> wire = jsonDecode(
      jsonEncode(allocationViewColumns(v)),
    ) as Map<String, Object?>;
    final List<Object?> sections =
        wire[AllocationReadModelColumns.sections]! as List<Object?>;
    expect(
      sections,
      jsonDecode(
        jsonEncode(<Object?>[
          for (final AllocationReadOnlySection s in v.sections) s.toJson(),
        ]),
      ),
    );
  });

  test('🆕 설정 필수 입구 — 운영 설정 판의 월말 · 한도 · 브레이커로 짓는다(정본 판 = 기본값 갈래와 같은 글자)', () {
    final P0sOpsConfig cfg = P0sOpsConfig.of(_human());
    final AllocationEditorVm v = allocationEditorVmOfConfig(cfg, nowUtc: _now);
    expect(
      v,
      allocationViewOf(
        nowUtc: _now,
        monthEnd: cfg.monthEnd,
        limits: cfg.limits,
        breaker: cfg.breaker,
        warn: p0sWarnConfig(),
      ),
    );
    expect(v, _fixture('allocation_editor.json'));
  });
}
