// 🆕 E11q-q5a — M7 `S7-7` 연간 리뷰 VM · `S7-10` 이행 갭 결과(설계 13 §8 R220 · 나눔 계획 R169 q5 · 01 §15-4 ·
// 표본 `m7/m7_annual_*` · `m7/execution_gap_*` · `m7/aftertax_ladder_1`).
//
// 🔴 연도 · 창 · 첫 해 = S12 목차와 **같은 함수**(`annualReviewYearOf` — 신뢰 시각 한국 12월 = 열림 · 그 밖 = 지난해 ·
//    운영 첫 해 앞 = 첫 해 = 그해) — 목차가 말한 해와 본문의 해가 어긋나지 않는다(K24).
//    신뢰 시각 모름 = 창 «모름»(S12 와 같은 글자 · 코드 `UNKNOWN` = 표본 밖 · OPEN 을 지어내지 않는다).
// 🔴 섹션 = 창 상태별 엔진 문장(표본 글자 그대로 · 수치 0 — 한 해의 결과 수치는 탐색 · 리포트 화면 몫) ·
//    A 행 링크 = 탐색 화면 본문이 등록됐을 때만(S01 원칙 · 첫 해 = 링크 0 = 표본).
// 🔴 세후 = 골든 참고치(`golden_p0s.json` `aftertax_full_S7` · 실계좌 산출 아님 — 사다리 `isReferenceOnly`) ·
//    본문 갈래 = POT 비과세(SAF-309 = POT 주문은 등록 절세계좌로만 — 일반계좌 · 확인 불가 = 실주문 거부) ·
//    반사실 = 일반계좌 종합과세 38.5%(표본 짝). 세후 창구는 이 VM 하나(K25 — `S7-7` 은 `afterTaxLadder` 를 부르지 않는다).
// 🔴 이행 갭 = 안내 이행 리포트(X7) — 자동 매매 = «해당 없음» 문장 · 운용 전(모드 모름) = «발행된 안내 0» 문장 ·
//    안내 모드 = 산출 원천 없음 오류(X7 산출 조각 전 · 지어내지 않는다).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AfterTaxLadder,
        AnnualReviewSection,
        AnnualReviewVm,
        AppRoutes,
        AsOf,
        AsOfSource,
        EmptyKind,
        ExecutionGapResult,
        OperatingMode,
        TaxLadderBranch,
        TradeDate;

import '../whatif/after_tax.dart' show AfterTaxFull;
import '../whatif/after_tax_ladder.dart' show buildAfterTaxLadder;
import 'annual_review_index.dart'
    show
        AnnualReviewTexts,
        AnnualReviewWindow,
        annualReviewYearOf,
        kAnnualReviewStaleAfter;
import 'ledger_views.dart' show kstDateText;

/// 창 상태 코드(`AnnualReviewVm.windowStateCode` — 화면 미참조 C-42).
abstract final class AnnualReviewCodes {
  /// 그해 12월 창(표본 `m7_annual_2026`).
  static const String open = 'OPEN';

  /// 창 밖 · 지난 연도(표본 `m7_annual_offwindow`).
  static const String closed = 'CLOSED';

  /// 운영 첫 해(표본 `m7_annual_first_year`).
  static const String firstYear = 'FIRST_YEAR';

  /// 🆕 신뢰 시각 모름(표본 밖 — S12 의 넷째 상태와 같은 글자).
  static const String unknown = 'UNKNOWN';
}

/// `S7-7` · `S7-10` 글자(표본 그대로).
abstract final class AnnualReviewVmTexts {
  /// 연간 리뷰 기준(S12 와 같은 글자).
  static String asOfLabel(String day) => '연간 점검 기준 $day';

  /// 세후 사다리 기준(표본 `aftertax_ladder_1`).
  static String afterTaxAsOfLabel(String day) => '세후 사다리 기준 $day';

  /// 이행 갭 기준(표본).
  static String gapAsOfLabel(String day) => '이행 갭 기준 $day';

  /// 자동 매매 구간 — 해당 없음(표본 `execution_gap_not_applicable`).
  static const String gapNotApplicable =
      '자동 매매 구간이라 안내 이행 리포트가 없습니다. 지난 안내 구간의 리포트는 그대로 남습니다.';

  /// 발행된 안내 0(표본 `execution_gap_empty`).
  static const String gapNoData = '이 기간에는 발행된 안내가 없습니다.';
}

/// 섹션 한 줄(코드 · 제목 · 문장 · 탐색 링크 자리).
typedef _Section = (
  String code,
  String title,
  List<String> lines,
  bool explore,
);

/// 첫 해 섹션(표본 `m7_annual_first_year` 차례 · 글자 그대로 · 링크 0).
const List<_Section> _firstYearSections = <_Section>[
  (
    'A_RETURNS',
    '한 해의 결과',
    <String>['첫 해라 비교할 지난해가 없습니다.', '표본이 짧아 우열을 가릴 수 없습니다.'],
    false,
  ),
  ('B_AFTERTAX', '세후 사다리', <String>['첫 산출입니다. 참조용입니다.'], false),
  ('C_EXECUTION', '이행 갭', <String>['첫 해 기록을 그대로 둡니다.'], false),
  ('D_RULES', '규칙 점검', <String>['첫 해에는 규칙을 바꾸지 않습니다.'], false),
];

/// 열림 · 닫힘 섹션(표본 `m7_annual_2026` · `m7_annual_offwindow` — 두 표본의 섹션이 같다).
const List<_Section> _yearSections = <_Section>[
  (
    'A_RETURNS',
    '한 해의 결과',
    <String>['연간 수익률과 벤치마크를 나란히 봅니다.', '표본은 여전히 짧습니다.'],
    true,
  ),
  (
    'B_AFTERTAX',
    '세후 사다리',
    <String>['세후는 연 1회만 산출합니다.', '월간 리포트에는 세후를 싣지 않습니다.'],
    false,
  ),
  ('C_EXECUTION', '이행 갭', <String>['못 한 것과 안 한 것을 갈라 봅니다.'], false),
  ('D_RULES', '규칙 점검', <String>['바꾸지 않은 것도 기록입니다.'], false),
];

final RegExp _yearForm = RegExp(r'^\d{4}$');
final RegExp _monthForm = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

/// 🔴 `S7-7` 연간 리뷰 VM — [year] == null = 엔진 기본 연도(S12 와 같은 함수) · 다른 연도 = 운영 첫 해부터 기본 연도
/// 앞까지의 끝난 해만(닫힘) · 그 밖 = 실패(지어내지 않는다) · [trustedNowUtc] = 창 판정(모르면 «모름») ·
/// [nowUtc] = 기준 줄(기기 시각) · [firstOperatingYear] = 운영을 시작한 해(모르면 운영 전 = 첫 해) ·
/// [configHash] = 세후 사다리 판 지문 · [afterTax] = 세후 계산(없으면 P0S 골든 참고치).
AnnualReviewVm annualReviewVmOf({
  required DateTime? trustedNowUtc,
  required DateTime nowUtc,
  required int? firstOperatingYear,
  required String configHash,
  required bool Function(String route) hasBody,
  String? year,
  AfterTaxFull? afterTax,
}) {
  final ({int year, bool firstYear, AnnualReviewWindow window}) d =
      annualReviewYearOf(
        trustedNowUtc: trustedNowUtc,
        nowUtc: nowUtc,
        firstOperatingYear: firstOperatingYear,
      );
  if (year != null && !_yearForm.hasMatch(year)) {
    throw ArgumentError.value(year, 'year', '연도 꼴(yyyy) 아님');
  }
  final int y = year == null ? d.year : int.parse(year);
  final bool current = y == d.year;
  if (!current) {
    final int? first = firstOperatingYear;
    if (d.firstYear || first == null || y < first || y > d.year) {
      throw StateError('연간 리뷰 연도 밖: $y(끝난 해 = ${first ?? '-'}~${d.year - 1})');
    }
  }
  final String code = !current
      ? AnnualReviewCodes.closed
      : switch (d.window) {
          AnnualReviewWindow.open => AnnualReviewCodes.open,
          AnnualReviewWindow.unknown => AnnualReviewCodes.unknown,
          AnnualReviewWindow.closed =>
            d.firstYear
                ? AnnualReviewCodes.firstYear
                : AnnualReviewCodes.closed,
        };
  final bool firstYearBody = current && d.firstYear;
  final bool exploreOn = hasBody(AppRoutes.performanceExplore);
  final String day = kstDateText(nowUtc);
  final AfterTaxFull full = afterTax ?? p0sAfterTaxFullS7();
  final AsOf ladderAsOf = _asOf(
    nowUtc,
    AnnualReviewVmTexts.afterTaxAsOfLabel(day),
  );
  AfterTaxLadder ladder(TaxLadderBranch b) =>
      buildAfterTaxLadder(full, b, asOf: ladderAsOf, configHash: configHash);
  return AnnualReviewVm(
    year: '$y',
    yearLabel: AnnualReviewTexts.yearLabel(y),
    windowStateCode: code,
    windowStateLabel: switch (code) {
      AnnualReviewCodes.open => AnnualReviewTexts.open,
      AnnualReviewCodes.unknown => AnnualReviewTexts.unknown,
      AnnualReviewCodes.firstYear => AnnualReviewTexts.firstYear,
      _ => AnnualReviewTexts.closed,
    },
    sections: <AnnualReviewSection>[
      for (final (String c, String title, List<String> lines, bool explore)
          in firstYearBody ? _firstYearSections : _yearSections)
        AnnualReviewSection(
          code: c,
          title: title,
          lines: lines,
          route: explore && exploreOn ? AppRoutes.performanceExplore : null,
        ),
    ],
    asOf: _asOf(nowUtc, AnnualReviewVmTexts.asOfLabel(day)),
    afterTax: ladder(TaxLadderBranch.specPotTaxFree),
    afterTaxCounterfactual: ladder(TaxLadderBranch.cfPotTaxableComp38),
  );
}

/// 🔴 `S7-10` 이행 갭 결과 — [mode] = 지금 운영 방식(null = 운용 전) · [yyyyMm] = 받은 달(꼴만 본다 · null = 기본 달).
/// 자동 매매 = 해당 없음 문장 · 운용 전 = 발행된 안내 0 문장 · 안내 모드 = 산출 원천 없음(X7 조각 전) 실패.
ExecutionGapResult executionGapResultOf({
  required OperatingMode? mode,
  required DateTime nowUtc,
  String? yyyyMm,
}) {
  if (yyyyMm != null && !_monthForm.hasMatch(yyyyMm)) {
    throw ArgumentError.value(yyyyMm, 'yyyyMm', '달 꼴(yyyy-MM) 아님');
  }
  final AsOf asOf = _asOf(
    nowUtc,
    AnnualReviewVmTexts.gapAsOfLabel(kstDateText(nowUtc)),
  );
  return switch (mode) {
    OperatingMode.autoTrade => ExecutionGapResult(
      emptyKind: EmptyKind.notApplicable,
      emptyLabel: AnnualReviewVmTexts.gapNotApplicable,
      asOf: asOf,
    ),
    null => ExecutionGapResult(
      emptyKind: EmptyKind.noData,
      emptyLabel: AnnualReviewVmTexts.gapNoData,
      asOf: asOf,
    ),
    OperatingMode.advisory => throw StateError('안내 이행 갭: 산출 원천 없음(X7 산출 조각 전)'),
  };
}

AsOf _asOf(DateTime nowUtc, String label) => AsOf(
  observedAt: nowUtc.toUtc(),
  tradeDate: TradeDate(kstDateText(nowUtc)),
  source: AsOfSource.localSqlite,
  staleAfter: kAnnualReviewStaleAfter,
  label: label,
);

/// P0S 세후 골든 참고치(`golden_p0s.json` `aftertax_full_S7` 그대로).
AfterTaxFull p0sAfterTaxFullS7() =>
    AfterTaxFull.fromGoldenJson(kP0sAfterTaxFullS7Golden);

/// 🔴 `golden_p0s.json` `aftertax_full_S7` 의 사본(골든 파일은 엔진 자산이 아니다 — 자산 목록 = 실행기 몫) ·
/// `annual_review_view_test` 가 파일과 값 하나 다르지 않은지 대조한다.
const Map<String, Object?> kP0sAfterTaxFullS7Golden = <String, Object?>{
  'spec_pot_taxfree': <String, Object?>{
    'pretax': <String, Object?>{'cagr_pct': 11.1331, 'end_mult': 16.5951},
    'after_pot': <String, Object?>{'cagr_pct': 11.1331, 'end_mult': 16.5951},
    'after_pot_c': <String, Object?>{'cagr_pct': 10.9629, 'end_mult': 15.932},
    'wd_5p5': <String, Object?>{'cagr_pct': 10.8532, 'end_mult': 15.5181},
    'wd_5p5_refund_nominal': <String, Object?>{
      'cagr_pct': 10.8677,
      'end_mult': 15.5722,
    },
    'wd_5p5_refund_reinvested': <String, Object?>{
      'cagr_pct': 10.9973,
      'end_mult': 16.0639,
    },
    'wd_16p5': <String, Object?>{'cagr_pct': 10.6251, 'end_mult': 14.6904},
    'wd_16p5_refund_nominal': <String, Object?>{
      'cagr_pct': 10.6404,
      'end_mult': 14.7445,
    },
    'wd_16p5_refund_reinvested': <String, Object?>{
      'cagr_pct': 10.7769,
      'end_mult': 15.2362,
    },
    'refund_reinvested_krw': 54574244,
  },
  'cf_pot_taxable_comp26': <String, Object?>{
    'pretax': <String, Object?>{'cagr_pct': 11.1331, 'end_mult': 16.5951},
    'after_pot': <String, Object?>{'cagr_pct': 10.8548, 'end_mult': 15.524},
    'after_pot_c': <String, Object?>{'cagr_pct': 10.625, 'end_mult': 14.6898},
    'wd_5p5': <String, Object?>{'cagr_pct': 10.5062, 'end_mult': 14.276},
    'wd_5p5_refund_nominal': <String, Object?>{
      'cagr_pct': 10.5219,
      'end_mult': 14.33,
    },
    'wd_5p5_refund_reinvested': <String, Object?>{
      'cagr_pct': 10.6505,
      'end_mult': 14.7804,
    },
    'wd_16p5': <String, Object?>{'cagr_pct': 10.2585, 'end_mult': 13.4482},
    'wd_16p5_refund_nominal': <String, Object?>{
      'cagr_pct': 10.2751,
      'end_mult': 13.5023,
    },
    'wd_16p5_refund_reinvested': <String, Object?>{
      'cagr_pct': 10.4112,
      'end_mult': 13.9527,
    },
    'refund_reinvested_krw': 50447271,
  },
  'cf_pot_taxable_comp38': <String, Object?>{
    'pretax': <String, Object?>{'cagr_pct': 11.1331, 'end_mult': 16.5951},
    'after_pot': <String, Object?>{'cagr_pct': 10.8548, 'end_mult': 15.524},
    'after_pot_c': <String, Object?>{'cagr_pct': 10.5616, 'end_mult': 14.4676},
    'wd_5p5': <String, Object?>{'cagr_pct': 10.4411, 'end_mult': 14.0537},
    'wd_5p5_refund_nominal': <String, Object?>{
      'cagr_pct': 10.457,
      'end_mult': 14.1078,
    },
    'wd_5p5_refund_reinvested': <String, Object?>{
      'cagr_pct': 10.5854,
      'end_mult': 14.5506,
    },
    'wd_16p5': <String, Object?>{'cagr_pct': 10.1895, 'end_mult': 13.226},
    'wd_16p5_refund_nominal': <String, Object?>{
      'cagr_pct': 10.2064,
      'end_mult': 13.2801,
    },
    'wd_16p5_refund_reinvested': <String, Object?>{
      'cagr_pct': 10.3423,
      'end_mult': 13.7229,
    },
    'refund_reinvested_krw': 49692846,
  },
  'cf_pot_taxable_flat': <String, Object?>{
    'pretax': <String, Object?>{'cagr_pct': 11.1331, 'end_mult': 16.5951},
    'after_pot': <String, Object?>{'cagr_pct': 10.8548, 'end_mult': 15.524},
    'after_pot_c': <String, Object?>{'cagr_pct': 10.6824, 'end_mult': 14.894},
    'wd_5p5': <String, Object?>{'cagr_pct': 10.5652, 'end_mult': 14.4801},
    'wd_5p5_refund_nominal': <String, Object?>{
      'cagr_pct': 10.5807,
      'end_mult': 14.5342,
    },
    'wd_5p5_refund_reinvested': <String, Object?>{
      'cagr_pct': 10.7095,
      'end_mult': 14.9915,
    },
    'wd_16p5': <String, Object?>{'cagr_pct': 10.3209, 'end_mult': 13.6524},
    'wd_16p5_refund_nominal': <String, Object?>{
      'cagr_pct': 10.3373,
      'end_mult': 13.7065,
    },
    'wd_16p5_refund_reinvested': <String, Object?>{
      'cagr_pct': 10.4735,
      'end_mult': 14.1638,
    },
    'refund_reinvested_krw': 51140205,
  },
  'inputs': <String, Object?>{
    'pension_end_krw': 786402793,
    'pension_end_B_only_krw': 739500103,
    'pension_share_pct': 47.39,
    'contrib_total_krw': 74913873,
    'credited_krw': 40974409,
    'non_credited_krw': 33939464,
    'refund_nominal_krw': 5408622,
    'taxable_pension_krw': 752463329,
    'pot_gains_krw': 282319696,
    'c_gains_krw': 99189969,
    'years_over_2000man': 6,
    'max_year_gain_krw': 81422188,
  },
  'assumption':
      '(가) 정본 = POT 절세계좌(매매차익세 0) · C 국내상장 해외 ETF 일반계좌 15.4%(건별 이익, 손실 통산 없음) · '
      'A 국내 ETF 비과세 · B 연금계좌 종료 시점 인출세 5.5%(연금 수령) / 16.5%(분리과세), 과세 대상 = 잔고(B + 재분류 파킹) '
      '− 세액공제 미수령 원금(명목) · 환급 = 공제대상 납입 × 13.2% (명목 합산 하한 / 다음 해 5월부터 재투자 상한). '
      '(나) 반사실 = POT 일반계좌 15.4% + 연 실현이익 2,000만 초과분 종합과세(26.4%/38.5%). «정직 기대»(F회차)는 '
      '여기에 낙관 감액 0.47%p(계절 게이트 ×0.5 0.26 + KOSDAQ150 프록시 0.21)를 더 뺀 값이며 인출세를 포함하지 '
      '않는 옛 라벨을 대체한다.',
};
