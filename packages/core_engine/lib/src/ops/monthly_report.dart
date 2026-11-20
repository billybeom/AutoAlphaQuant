// 🆕 미결 209 — 월간 1페이지 리포트(`S7-1` · 계약 `MonthlyReport`) 엔진 빌더 첫 판: 13항목 고정 칸 · `D2_ALLOCATION` 값 · 메모
// (설계 13 §8 R199 · 앱 01 §8 미결 209 · §36 K192 · K193 · 03 §3 · 04 §1 Level 3 v2.46 «307 월간 보고(초과 일수)»).
//
// 🔴 13항목 = 고정 배열(C-25) — 칸(code · order · section · title)은 [MonthlyReportSlot] 하나가 정한다(표본 `m7/m7_monthly_*`
//    글자 그대로). 결측이어도 칸은 남는다 — 엔진 원천이 아직 없는 칸 = «산출 불가» 한 문장(03 §3 «데이터 부족 = 해당 항목만
//    산출 불가 · 항목 자리는 남긴다»). 항목을 더하거나 빼는 길 0.
// 🔴 이 판이 채우는 칸 = `D2_ALLOCATION` 하나 — 값 = 월말 회계 비중 세 줄(A = POT 포함 · B · C — 회차 화면과 같은 세 줄) ·
//    메모 = E3d-4 월 집계 한 줄(SAF-307 달러 노출 기준선 넘은 날 · 원화 유동성 하한 밑 날 · 계측 없는 날 — 03 §3 «⑦ 아래 달러 비중
//    계측 한 줄 = 부기이지 14번째 항목이 아니다» · 새 계약 칸 0 — K192). 문턱 글자 = 집계가 쓴 문턱(지어내지 않는다).
// 🆕 R205(나눔 ⓐ) — A1 · A2 · C1 · C2 = 계층 B 와 같은 TWR 시리즈([EquityPoint] · 개시 이후 · 입출금 = 외부 흐름 —
//    data_sync `tierBSeries`) + 그 달 KR 세션([MonthlyEquityFacts]). 그 달 결측 세션 = 표본 `m7_monthly_gap` 글자 그대로.
// 🆕 R208(나눔 ⓑ) — D4 = 재량 예산 셈(`discretionBudgetOf` · 월말 기준 · 게이지와 같은 머리 글자) · E1 = 전략 상태
//    (ACTIVE · PROBATION) + 이 달 계층 B 판정 + 홈 · 차단 보드와 같은 `SafetyState` 한 장(킬스위치 · 표식 아닌 차단 플래그).
// 🔴 나머지 6칸 = 원천이 생기는 창마다 타입 있는 입력 하나씩(설계 13 §8 R199 나눔표) — 지금은 받는 칸이 없다(호출자가 글자를
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
        BlockFlag,
        FlagIds,
        LedgerTrustBadge,
        MonthlyReport,
        ReportItem,
        SafetyState,
        SleeveId,
        SleeveWeight,
        TradeDate;

import '../safety/discretion.dart' show DiscretionBudget, discretionBudgetOf;
import 'ledger_views.dart' show kstDateText;
import 'p0s_warn.dart' show P0sExposureTally;
import 'tier_b.dart' show EquityPoint, TierBVerdict, twrIndex;

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

  /// 🆕 R205 — 그 달 결측 세션(표본 `m7_monthly_gap` A1).
  static String missingSessions(int n) => '산출 불가 — $n거래일이 결측입니다';

  /// 🆕 R205 — 결측 구간이 있어 누적 · 낙폭을 내지 않는다(표본 `m7_monthly_gap` A2 · C1 · C2).
  static const String gapInHistory = '산출 불가 — 결측 구간이 있습니다';

  /// 🆕 R205 — C1 메모(표본 `m7_monthly_gap`).
  static const String gapSegmentedNote = '결측 구간이 있어 분절해 표시합니다.';

  /// 🆕 R205 — 결측 날 메모 «8월 20~21일 스냅샷이 없습니다.»(표본) · [runs] = 이어진 결측 세션 묶음(첫 날 · 끝 날).
  static String missingDatesNote(int month, List<(int, int)> runs) {
    final List<String> parts = <String>[
      for (final (int a, int b) in runs) a == b ? '$a일' : '$a~$b일',
    ];
    return '$month월 ${parts.join(' · ')} 스냅샷이 없습니다.';
  }

  /// 🆕 R205 — 가장 긴 물속 기간 «최장 3개월»(표본 · 달 = 일 ÷ [monthDays] 내림 · 1달 미만 · 0 = 따로).
  static String longestUnderWater(int days) => days <= 0
      ? '전고점 아래 구간 없음'
      : days < monthDays
      ? '최장 1개월 미만'
      : '최장 ${(days / monthDays).floor()}개월';

  /// 한 달 = 30.4375일(계층 B TUW 와 같은 환산).
  static const double monthDays = 30.4375;

  /// 🆕 R208 — 재량 예산 값 «12개월 4회 중 1회 사용»(게이지 `discretionBudgetText` 머리와 같은 글자) · 소진 = «소진 — » 앞붙임.
  static String discretionValue(DiscretionBudget b) =>
      '${b.exhausted ? '소진 — ' : ''}12개월 ${b.max}회 중 ${b.used}회 사용';

  /// 🆕 R208 — 재량 메모 «이번 달 1회 사용».
  static String discretionThisMonth(int n) => '이번 달 $n회 사용';

  /// 🆕 R208 — 재량 메모 «다음 회복 2027-08-03»(게이지와 같은 글자).
  static String discretionRecovery(String date) => '다음 회복 $date';

  /// 🆕 R208 — 전략 상태 ACTIVE(표본 `m7_monthly_2026_08` E1 «정상»).
  static const String strategyActive = '정상';

  /// 🆕 R208 — 전략 상태 PROBATION(03_운영 §1-5 상태기계 «보호관찰»).
  static const String strategyProbation = '보호관찰';

  /// 🆕 R208 — 이 달 계층 B 판정 충족 «계층 B B2 충족».
  static String tierBBreached(List<String> codes) =>
      '계층 B ${codes.join(' · ')} 충족';

  /// 🆕 R208 — 킬스위치 켜짐 «킬스위치 작동 중»(상태 글자 = 엔진 `KillSwitchView.stateLabel`).
  static String killSwitch(String stateLabel) => '킬스위치 $stateLabel';

  /// 🆕 R208 — 차단 플래그 없음(표본 `m7_monthly_2026_08` E1).
  static const String noBlockFlags = '차단 플래그 없음';

  /// 🆕 R208 — 차단 플래그 수 «차단 플래그 2개»(이름 = 메모).
  static String blockFlags(int n) => '차단 플래그 $n개';
}

/// 🆕 R205 — A1 · A2 · C1 · C2 원천.
class MonthlyEquityFacts {
  /// 만든다.
  const MonthlyEquityFacts({required this.series, required this.monthSessions});

  /// 월말까지 TWR 시리즈 — 계층 B 와 같은 시리즈(개시 이후 스냅숏 · 날짜 순 · 점마다 앞 점 뒤 ~ 그날 입출금 합).
  final List<EquityPoint> series;

  /// 그 달 KR 세션 전부(날짜 순 · 마지막 = 월말 세션) — 개시 날 이후인데 스냅숏이 없는 세션 = 결측.
  final List<String> monthSessions;
}

/// 🆕 R208 — E1 원천.
class MonthlyStrategyFacts {
  /// 만든다.
  const MonthlyStrategyFacts({
    required this.strategyStates,
    required this.safety,
    this.tierB,
  });

  /// `strategy_state_current.state` 전부(전략마다) — ACTIVE · PROBATION 밖 · 빈 목록 = 실패.
  final List<String> strategyStates;

  /// 홈 · 차단 보드와 같은 안전 상태 한 장(리포트를 짓는 때 = 마감 직후 — 킬스위치 · 차단 플래그).
  final SafetyState safety;

  /// 이 달 계층 B 판정(판정 안 됨 = null — 미판정은 `TIER_B_UNJUDGED` 플래그가 말한다).
  final TierBVerdict? tierB;
}

final RegExp _ymd = RegExp(r'^\d{4}-\d\d-\d\d$');

/// 🔴 D4 (값 · 메모) — 사용 날(한국 날 · 조정 + X7 예산 사건 = 한 목록 D24) 중 월말까지만 · 월말 기준 롤링 12개월.
(String, String?) _discretionItemOf(
  List<String> useDates,
  String yyyyMm,
  String monthEnd,
) {
  for (final String d in useDates) {
    if (!_ymd.hasMatch(d)) {
      throw ArgumentError.value(d, 'discretionUseDates', 'YYYY-MM-DD 가 아니다');
    }
  }
  final List<String> upTo = <String>[
    for (final String d in useDates)
      if (d.compareTo(monthEnd) <= 0) d,
  ];
  final DiscretionBudget b = discretionBudgetOf(upTo, monthEnd);
  final int thisMonth = upTo
      .where((String d) => d.startsWith('$yyyyMm-'))
      .length;
  final List<String> note = <String>[
    if (thisMonth > 0) MonthlyReportTexts.discretionThisMonth(thisMonth),
    if (b.nextRecoveryDate != null)
      MonthlyReportTexts.discretionRecovery(b.nextRecoveryDate!),
  ];
  return (
    MonthlyReportTexts.discretionValue(b),
    note.isEmpty ? null : note.join(' · '),
  );
}

/// 🔴 E1 (값 · 메모) — «정상 · 차단 플래그 없음»(표본) 꼴 · 표식 플래그(`FlagIds.markerOnly`)는 홈 블록 3 · 보드처럼 거른다 ·
/// 메모 = 차단 플래그 이름(엔진 차례 그대로).
(String, String?) _strategyItemOf(MonthlyStrategyFacts f) {
  if (f.strategyStates.isEmpty) {
    throw ArgumentError.value(0, 'strategy', '전략 상태 없음');
  }
  bool probation = false;
  for (final String st in f.strategyStates) {
    if (st == 'PROBATION') {
      probation = true;
    } else if (st != 'ACTIVE') {
      throw ArgumentError.value(st, 'strategy', 'ACTIVE · PROBATION 밖의 상태');
    }
  }
  final TierBVerdict? v = f.tierB;
  final List<String> codes = <String>[
    if (v != null && v.b1) 'B1',
    if (v != null && v.b2) 'B2',
    if (v != null && v.b3) 'B3',
  ];
  final List<BlockFlag> flags = <BlockFlag>[
    for (final BlockFlag x in f.safety.activeFlags)
      if (!FlagIds.markerOnly.contains(x.flagId)) x,
  ];
  final String value = <String>[
    probation
        ? MonthlyReportTexts.strategyProbation
        : MonthlyReportTexts.strategyActive,
    if (codes.isNotEmpty) MonthlyReportTexts.tierBBreached(codes),
    if (f.safety.killSwitch.active)
      MonthlyReportTexts.killSwitch(f.safety.killSwitch.stateLabel),
    flags.isEmpty
        ? MonthlyReportTexts.noBlockFlags
        : MonthlyReportTexts.blockFlags(flags.length),
  ].join(' · ');
  return (
    value,
    flags.isEmpty ? null : flags.map((BlockFlag x) => x.label).join(' · '),
  );
}

/// 같은 높이 허용(계층 B 최고점 판정과 같은 상대 오차 — 곱셈 누적 오차로 회복을 놓치지 않는다).
const double _kPeakTolerance = 1e-9;

/// «+0.67%» · «−1.20%» · «0.00%»(소수 둘 · 반올림 뒤 0 = 부호 없음).
String _signedPct2(double r) {
  final String v = (r.abs() * 100).toStringAsFixed(2);
  if (v == '0.00') return '0.00%';
  return '${r > 0 ? '+' : '−'}$v%';
}

/// «−6.4%» · «0.0%»(소수 하나 · 낙폭 ≤ 0).
String _ddPct1(double dd) {
  final String v = (dd.abs() * 100).toStringAsFixed(1);
  return v == '0.0' ? '0.0%' : '−$v%';
}

int _daysBetween(String a, String b) =>
    DateTime.parse('${b}T00:00:00Z')
        .difference(DateTime.parse('${a}T00:00:00Z'))
        .inDays;

/// 🔴 A1 · A2 · C1 · C2 의 (값 · 메모).
///
/// 결측(그 달 세션 중 개시 날 이후 스냅숏 없는 날) = 표본 `m7_monthly_gap` 글자 · 앞 달 결측은 이번 달 값을 막지 않는다
/// (TWR 은 결측을 건너 흐름을 합한 다음 점으로 잇는다 · 마감된 달은 다시 짓지 않는다).
/// 값 = 개시 이후 TWR 지수 — A1 = 앞 달 마지막 점(개시가 이 달이면 첫 점) → 월말 · A2 = 첫 점 → 월말 ·
/// C1 = 최대 낙폭 · C2 = 가장 긴 물속 기간(전고점 날 → 회복 날 · 진행 중이면 월말까지).
Map<MonthlyReportSlot, (String, String?)> _equityItemsOf(
  MonthlyEquityFacts f,
  String yyyyMm,
  String monthEnd,
) {
  final List<EquityPoint> pts = f.series;
  if (pts.isEmpty) {
    throw ArgumentError.value(0, 'equity', '시리즈 없음 — equity 를 비울 것');
  }
  for (int k = 0; k < pts.length; k++) {
    if (k > 0 && pts[k - 1].date.compareTo(pts[k].date) >= 0) {
      throw ArgumentError.value(pts[k].date, 'equity', '시리즈가 날짜 순이 아니다');
    }
    if (pts[k].date.compareTo(monthEnd) > 0) {
      throw ArgumentError.value(pts[k].date, 'equity', '월말 $monthEnd 뒤의 점');
    }
  }
  final List<String> ss = f.monthSessions;
  if (ss.isEmpty || ss.last != monthEnd) {
    throw ArgumentError.value(
      ss.length,
      'equity',
      '세션 목록 끝이 월말 $monthEnd 이 아니다',
    );
  }
  for (int k = 0; k < ss.length; k++) {
    if (ss[k].length != 10 || !ss[k].startsWith('$yyyyMm-')) {
      throw ArgumentError.value(ss[k], 'equity', '$yyyyMm 밖의 세션');
    }
    if (k > 0 && ss[k - 1].compareTo(ss[k]) >= 0) {
      throw ArgumentError.value(ss[k], 'equity', '세션이 날짜 순이 아니다');
    }
  }
  final Set<String> have = <String>{for (final EquityPoint p in pts) p.date};
  final String opened = pts.first.date;
  final List<(int, int)> runs = <(int, int)>[];
  int missing = 0;
  int? runStart;
  int runEnd = 0;
  for (final String s in ss) {
    final int day = int.parse(s.substring(8, 10));
    if (s.compareTo(opened) >= 0 && !have.contains(s)) {
      missing++;
      runStart ??= day;
      runEnd = day;
    } else if (runStart != null) {
      runs.add((runStart, runEnd));
      runStart = null;
    }
  }
  if (runStart != null) runs.add((runStart, runEnd));
  if (missing > 0) {
    return <MonthlyReportSlot, (String, String?)>{
      MonthlyReportSlot.periodReturn: (
        MonthlyReportTexts.missingSessions(missing),
        MonthlyReportTexts.missingDatesNote(
          int.parse(yyyyMm.substring(5, 7)),
          runs,
        ),
      ),
      MonthlyReportSlot.cumulativeReturn: (
        MonthlyReportTexts.gapInHistory,
        null,
      ),
      MonthlyReportSlot.maxDrawdown: (
        MonthlyReportTexts.gapInHistory,
        MonthlyReportTexts.gapSegmentedNote,
      ),
      MonthlyReportSlot.timeUnderWater: (MonthlyReportTexts.gapInHistory, null),
    };
  }
  final int end = pts.length - 1; // 결측 0 → 마지막 점 = 월말 세션
  int base = 0;
  for (int k = 0; k <= end; k++) {
    if (pts[k].date.compareTo('$yyyyMm-01') < 0) base = k;
  }
  final List<double> idx = twrIndex(pts);
  double mdd = 0;
  int longest = 0;
  int peak = 0;
  bool under = false;
  for (int k = 1; k <= end; k++) {
    if (idx[k] >= idx[peak] * (1 - _kPeakTolerance)) {
      if (under) {
        final int d = _daysBetween(pts[peak].date, pts[k].date);
        if (d > longest) longest = d;
        under = false;
      }
      peak = k;
    } else {
      under = true;
      final double dd = idx[k] / idx[peak] - 1;
      if (dd < mdd) mdd = dd;
    }
  }
  if (under) {
    final int d = _daysBetween(pts[peak].date, pts[end].date);
    if (d > longest) longest = d;
  }
  return <MonthlyReportSlot, (String, String?)>{
    MonthlyReportSlot.periodReturn: (
      _signedPct2(idx[end] / idx[base] - 1),
      null,
    ),
    MonthlyReportSlot.cumulativeReturn: (_signedPct2(idx[end] - 1), null),
    MonthlyReportSlot.maxDrawdown: (_ddPct1(mdd), null),
    MonthlyReportSlot.timeUnderWater: (
      MonthlyReportTexts.longestUnderWater(longest),
      null,
    ),
  };
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

/// 🔴 마감된 달의 월간 리포트를 짓는다 — 13칸 고정 · 원천이 있는 칸(A1 · A2 · C1 · C2 · D2 · D4 · E1)만 · 나머지 = «산출 불가».
///
/// [monthEnd] = 그 달 마지막 KR 세션(기준일) · [generatedAtUtc] = 생성 시각(한국 날 < [monthEnd] = 미생성 → [ArgumentError]) ·
/// [trust] = 그 달 마감 시점 원장 신뢰 등급(읽기 경로가 준다 — 스트림의 «지금» 등급이 아니다 · 03 §3) ·
/// [disclosureViewCount] = 그 달 탐색 열람 수(명령 집계 · 음수 = [ArgumentError]) ·
/// [allocation] null · 빈 목록 = D2 값 «산출 불가» · [exposureTally] null = D2 메모 없음(달이 다르면 [ArgumentError]) ·
/// 🆕 [equity] null = A1 · A2 · C1 · C2 «산출 불가»(R205) · 🆕 [discretionUseDates] null = D4 · [strategy] null = E1
/// «산출 불가»(R208).
MonthlyReport monthlyReportOf({
  required String yyyyMm,
  required TradeDate monthEnd,
  required DateTime generatedAtUtc,
  required String configHash,
  required LedgerTrustBadge trust,
  required int disclosureViewCount,
  List<SleeveWeight>? allocation,
  P0sExposureTally? exposureTally,
  MonthlyEquityFacts? equity,
  List<String>? discretionUseDates,
  MonthlyStrategyFacts? strategy,
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
  final Map<MonthlyReportSlot, (String, String?)> filled =
      <MonthlyReportSlot, (String, String?)>{
        if (equity != null) ..._equityItemsOf(equity, yyyyMm, end),
        MonthlyReportSlot.allocation: (allocationValue, allocationNote),
        if (discretionUseDates != null)
          MonthlyReportSlot.discretionBudget: _discretionItemOf(
            discretionUseDates,
            yyyyMm,
            end,
          ),
        if (strategy != null)
          MonthlyReportSlot.strategyState: _strategyItemOf(strategy),
      };
  return MonthlyReport(
    yyyyMm: yyyyMm,
    items: List<ReportItem>.unmodifiable(<ReportItem>[
      for (final MonthlyReportSlot s in MonthlyReportSlot.values)
        ReportItem(
          code: s.code,
          order: s.order,
          sectionCode: s.sectionCode,
          title: s.title,
          valueText: filled[s]?.$1 ?? MonthlyReportTexts.notComputed,
          noteText: filled[s]?.$2,
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
