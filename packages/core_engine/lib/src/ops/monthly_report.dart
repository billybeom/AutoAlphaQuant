// 🆕 미결 209 — 월간 1페이지 리포트(`S7-1` · 계약 `MonthlyReport`) 엔진 빌더 첫 판: 13항목 고정 칸 · `D2_ALLOCATION` 값 · 메모
// (설계 13 §8 R199 · 앱 01 §8 미결 209 · §36 K192 · K193 · 03 §3 · 04 §1 Level 3 v2.46 «307 월간 보고(초과 일수)»).
//
// 🔴 13항목 = 고정 배열(C-25) — 칸(code · order · section · title)은 [MonthlyReportSlot] 하나가 정한다(표본 `m7/m7_monthly_*`
//    글자 그대로). 결측이어도 칸은 남는다 — 엔진 원천이 아직 없는 칸 = «산출 불가» 한 문장(03 §3 «데이터 부족 = 해당 항목만
//    산출 불가 · 항목 자리는 남긴다»). 항목을 더하거나 빼는 길 0.
// 🔴 이 판이 채우는 칸 = `D2_ALLOCATION` 하나 — 값 = 월말 회계 비중 세 줄(A = POT 포함 · B · C — 회차 화면과 같은 세 줄) ·
//    메모 = E3d-4 월 집계 한 줄(SAF-307 달러 노출 기준선 넘은 날 · 원화 유동성 하한 밑 날 · 계측 없는 날 — 03 §3 «⑦ 아래 달러 비중
//    계측 한 줄 = 부기이지 14번째 항목이 아니다» · 새 계약 칸 0 — K192). 문턱 글자 = 집계가 쓴 문턱(지어내지 않는다).
// 🔴 나머지 12칸 = 원천이 생기는 창마다 타입 있는 입력 하나씩(설계 13 §8 R199 나눔표) — 지금은 받는 칸이 없다(호출자가 글자를
//    밀어 넣는 길 0 · 글자 = 엔진).
// 🔴 미생성 · 가림(무결성 · 대사) = 읽기 경로 몫(01 §2-10 · 생성일 규칙 미정) — 이 빌더는 «마감된 달» 한 갈래만 짓는다
//    (생성 날 < 월말 세션 = 실패). 마감된 달을 다시 짓지 않는 것(03 §3 금지 ③ · G-97)도 읽기 경로 · 저장의 몫이다.
// 🔴 세후 = 월간에 없다(03 §3 · `afterTax` null) · 목표 경로 엔진 없음 = «판정 보류» 문장 · 버튼 부재 · 「자세히」 링크 0
//    (값이 없는 칸에서 상세 화면으로 보내지 않는다).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AllocationBasis,
        AsOf,
        AsOfSource,
        LedgerTrustBadge,
        MonthlyReport,
        ReportItem,
        SleeveId,
        SleeveWeight,
        TradeDate;

import 'ledger_views.dart' show kstDateText;
import 'p0s_warn.dart' show P0sExposureTally;

/// 월간 리포트 기준 유효 시간(표본 `m7_monthly_*` 93600초).
const Duration kMonthlyReportStaleAfter = Duration(hours: 26);

/// 🔴 13항목 고정 칸 — 선언 순서 = 리포트 순서(order = 1 부터) · 글자 = 표본 `m7/m7_monthly_*` 그대로(C-25).
enum MonthlyReportSlot {
  /// A ① 이번 달 수익률.
  periodReturn('A1_PERIOD_RETURN', 'A', '이번 달 수익률'),

  /// A ② 누적 수익률.
  cumulativeReturn('A2_CUMULATIVE_RETURN', 'A', '누적 수익률'),

  /// B 벤치마크 대비.
  benchmark('B1_BENCHMARK', 'B', '벤치마크 대비'),

  /// C 최대 낙폭.
  maxDrawdown('C1_MAX_DRAWDOWN', 'C', '최대 낙폭'),

  /// C 회복까지 걸린 기간.
  timeUnderWater('C2_TIME_UNDER_WATER', 'C', '회복까지 걸린 기간'),

  /// D 국면 전환 횟수.
  regimeSwitches('D1_REGIME_SWITCHES', 'D', '국면 전환 횟수'),

  /// D 슬리브 배분 현황(🆕 메모 = SAF-307 · 원화 유동성 월 집계).
  allocation('D2_ALLOCATION', 'D', '슬리브 배분 현황'),

  /// D 규칙 이행.
  execution('D3_EXECUTION', 'D', '규칙 이행'),

  /// D 재량 예산 사용.
  discretionBudget('D4_DISCRETION_BUDGET', 'D', '재량 예산 사용'),

  /// E 전략 상태.
  strategyState('E1_STRATEGY_STATE', 'E', '전략 상태'),

  /// F 2×2 채점.
  scoring2x2('F1_SCORING_2X2', 'F', '2×2 채점'),

  /// G 표본 고지.
  sampleNotice('G1_SAMPLE_NOTICE', 'G', '표본 고지'),

  /// G 운영 램프 단계.
  opsRamp('G2_OPS_RAMP', 'G', '운영 램프 단계');

  const MonthlyReportSlot(this.code, this.sectionCode, this.title);

  /// 항목 코드.
  final String code;

  /// 섹션 A~G.
  final String sectionCode;

  /// 제목.
  final String title;

  /// 고정 순서(1~13).
  int get order => index + 1;
}

/// 월간 리포트 글자(엔진 · 표본에 있는 것은 글자 그대로).
abstract final class MonthlyReportTexts {
  /// 엔진 원천이 아직 없는 칸(🆕 R199 — 03 §3 «산출 불가» 꼴).
  static const String notComputed = '산출 불가 — 아직 계산하지 않는 항목입니다';

  /// 목표 경로 판정 보류(표본 `m7_monthly_gap` · 목표 경로 엔진 없음).
  static const String goalWithheld = '목표 경로 대비 판정을 보류합니다.';

  /// «이번 달 2번 열어 보셨습니다»(표본).
  static String disclosureViews(int n) => '이번 달 $n번 열어 보셨습니다';

  /// «2026-09-01 생성»(표본).
  static String generatedAt(String yyyyMmDd) => '$yyyyMmDd 생성';

  /// «리포트 기준 2026-08-31»(표본).
  static String asOfLabel(String yyyyMmDd) => '리포트 기준 $yyyyMmDd';
}

final RegExp _yyyyMm = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

const List<SleeveId> _allocationOrder = <SleeveId>[
  SleeveId.a,
  SleeveId.b,
  SleeveId.c,
];

/// 문턱 비율 → `%` 앞 글자(소수 한 자리 반올림 · 뒤 0 없음 — 0.50 → «50» · 0.025 → «2.5»).
String _thresholdPct(double ratio) =>
    (Decimal.parse(ratio.toString()) * Decimal.fromInt(100))
        .round(scale: 1)
        .toString();

/// `D2_ALLOCATION` 값 — «회계 기준 A 20.0% · B 42.0% · C 32.0%»(표본 꼴 · 엔진 열 병기 0).
///
/// 🔴 [weights] = 월말 회계 비중 세 줄(A = POT 포함 · B · C 순 — 회차 화면과 같은 세 줄). 순서 · 슬리브 · 기준이 다르면
/// [ArgumentError](두 기준을 바꿔 적지 않는다 — 03 §3 금지 ②).
String monthlyAllocationValueOf(List<SleeveWeight> weights) {
  if (weights.length != _allocationOrder.length) {
    throw ArgumentError.value(weights.length, 'weights', 'A · B · C 세 줄이 아니다');
  }
  final List<String> parts = <String>[];
  for (int i = 0; i < weights.length; i++) {
    final SleeveWeight w = weights[i];
    if (w.sleeve != _allocationOrder[i]) {
      throw ArgumentError.value(w.sleeve, 'weights', 'A · B · C 순이 아니다');
    }
    if (w.basis != AllocationBasis.accounting) {
      throw ArgumentError.value(w.basis, 'weights', '회계 기준이 아니다');
    }
    parts.add('${w.sleeve.wire} ${(w.weight * 100).toStringAsFixed(1)}%');
  }
  return '회계 기준 ${parts.join(' · ')}';
}

/// `D2_ALLOCATION` 메모 — «21거래일 중 달러 노출 50% 넘은 날 18일 · 원화 유동성 1% 밑 0일 · 계측 없음 1일».
///
/// 🔴 문턱 = 집계가 쓴 문턱([P0sExposureTally.config]) · 계측 없음 = 0 이어도 적는다(거래일 수에 들어 있다).
/// 거래일 0 = [ArgumentError](집계할 달이 아니다 — 지어내지 않는다).
String monthlyExposureNoteOf(P0sExposureTally t) {
  if (t.tradingDays <= 0) {
    throw ArgumentError.value(t.tradingDays, 'tally', '거래일 0 — 집계할 달이 아니다');
  }
  return '${t.tradingDays}거래일 중 '
      '달러 노출 ${_thresholdPct(t.config.usdBaselinePct)}% 넘은 날 ${t.usdOverDays}일 · '
      '원화 유동성 ${_thresholdPct(t.config.krwLiquidityFloorPct)}% 밑 ${t.krwLowDays}일 · '
      '계측 없음 ${t.unmeasuredDays}일';
}

/// 🔴 마감된 달의 월간 리포트를 짓는다 — 13칸 고정 · `D2_ALLOCATION` 만 원천에서 · 나머지 = «산출 불가».
///
/// [monthEnd] = 그 달 마지막 KR 세션(기준일) · [generatedAtUtc] = 생성 시각(한국 날 < [monthEnd] = 미생성 → [ArgumentError]) ·
/// [trust] = 그 달 마감 시점 원장 신뢰 등급(읽기 경로가 준다 — 스트림의 «지금» 등급이 아니다 · 03 §3) ·
/// [disclosureViewCount] = 그 달 탐색 열람 수(명령 집계 · 음수 = [ArgumentError]) ·
/// [allocation] null · 빈 목록 = D2 값 «산출 불가» · [exposureTally] null = D2 메모 없음(달이 다르면 [ArgumentError]).
MonthlyReport monthlyReportOf({
  required String yyyyMm,
  required TradeDate monthEnd,
  required DateTime generatedAtUtc,
  required String configHash,
  required LedgerTrustBadge trust,
  required int disclosureViewCount,
  List<SleeveWeight>? allocation,
  P0sExposureTally? exposureTally,
  String? backdateFootnote,
}) {
  if (!_yyyyMm.hasMatch(yyyyMm)) {
    throw ArgumentError.value(yyyyMm, 'yyyyMm', 'YYYY-MM 이 아니다');
  }
  final String end = monthEnd.yyyyMmDd;
  if (end.length != 10 || !end.startsWith('$yyyyMm-')) {
    throw ArgumentError.value(end, 'monthEnd', '$yyyyMm 의 날이 아니다');
  }
  final String generated = kstDateText(generatedAtUtc);
  if (generated.compareTo(end) < 0) {
    throw ArgumentError.value(
      generated,
      'generatedAtUtc',
      '월말 세션 $end 전 — 마감 전 달',
    );
  }
  if (disclosureViewCount < 0) {
    throw ArgumentError.value(disclosureViewCount, 'disclosureViewCount', '음수');
  }
  if (exposureTally != null && exposureTally.month != yyyyMm) {
    throw ArgumentError.value(
      exposureTally.month,
      'exposureTally',
      '$yyyyMm 의 집계가 아니다',
    );
  }
  final List<SleeveWeight>? w = allocation;
  final String allocationValue = w == null || w.isEmpty
      ? MonthlyReportTexts.notComputed
      : monthlyAllocationValueOf(w);
  final String? allocationNote = exposureTally == null
      ? null
      : monthlyExposureNoteOf(exposureTally);
  return MonthlyReport(
    yyyyMm: yyyyMm,
    items: List<ReportItem>.unmodifiable(<ReportItem>[
      for (final MonthlyReportSlot s in MonthlyReportSlot.values)
        ReportItem(
          code: s.code,
          order: s.order,
          sectionCode: s.sectionCode,
          title: s.title,
          valueText: s == MonthlyReportSlot.allocation
              ? allocationValue
              : MonthlyReportTexts.notComputed,
          noteText: s == MonthlyReportSlot.allocation ? allocationNote : null,
        ),
    ]),
    goalLine: MonthlyReportTexts.goalWithheld,
    disclosureViewCountText: MonthlyReportTexts.disclosureViews(
      disclosureViewCount,
    ),
    trust: trust,
    asOf: AsOf(
      observedAt: generatedAtUtc.toUtc(),
      tradeDate: monthEnd,
      source: AsOfSource.localSqlite,
      staleAfter: kMonthlyReportStaleAfter,
      label: MonthlyReportTexts.asOfLabel(end),
    ),
    backdateFootnote: backdateFootnote,
    generatedAtText: MonthlyReportTexts.generatedAt(generated),
    configHash: configHash,
  );
}
