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
// 🆕 R210(나눔 ⓒ) — D3 = 자동매매의 규칙 이행(03_운영 §3-5 이탈률) — «규칙대로» = 그 달 원장 `decision_log` 매매 규칙
//    결정(ENTRY · EXIT · REBALANCE) · «재량» = 그 달 이탈 저널(`decision_journal.is_deviation = 1` — 규칙 이탈은 이탈 저널을
//    남긴다 · SAF-408) · 이행률 = 규칙대로 ÷ 전체(내림 — 이탈 1건이면 100% 가 되지 않는다). 안내 모드(X7)의 이행 갭 = 다음 창.
// 🆕 R214(나눔 ⓓ) — D1 = 원장 `regime_score_daily.direction_state` 의 그 달 전환 수([MonthlyRegimeFacts]) · G1 = TWR
//    시리즈의 관측 길이(표본 글자 두 갈래 — 한 달 미만 = 거래일 · 그 뒤 = 개월) · G2 = 홈과 같은 `SafetyState.rampLevel`
//    (E1 과 같은 안전 상태 한 장). B1 벤치마크(지수 시계열 · 구성 정의 없음) · F1 2×2(01 §8 미결 98) = 원천 0 그대로.
// 🔴 나머지 2칸(B1 · F1) = 원천이 생기는 창마다 타입 있는 입력 하나씩(설계 13 §8 R199 나눔표) — 지금은 받는 칸이 없다(호출자가 글자를
//    밀어 넣는 길 0 · 글자 = 엔진).
// 🔴 미생성 = 읽기 경로 몫(생성일 규칙 미정 · 미결 40 — ⓔ-4) — 이 빌더는 «마감된 달» 한 갈래만 짓는다
//    (생성 날 < 월말 세션 = 실패). 마감된 달을 다시 짓지 않는 것(03 §3 금지 ③ · G-97)도 읽기 경로 · 저장의 몫이다.
// 🔴 세후 = 월간에 없다(03 §3 · `afterTax` null).
// 🆕 R231(미결 209 ⓔ-2 · ⓔ-5) — ① 신뢰 배지 = 자동 매매의 그 달 마감 시점 브로커 대사([monthlyLedgerTrustOf] · 마지막 대사 결과 ·
//    표본 `m7_monthly_2026_08` · `_masked_recon` 글자 · 현금 축 = 관측만이라 «수량·현금» 대신 «수량» — 과장 금지) ② 가림 둘 =
//    무결성 점검 중([monthlyReportIntegrityMaskedOf] · 표본 `_masked_integrity` 꼴 그대로) · 대사 어긋남(배지 DRIFTING → D2 퍼센트
//    «?» + 표본 메모) ③ 「자세히」 = 값이 있는 칸 · 본문이 있는 화면만([hasBody] — C1 · C2 → `S7-3` · D3 → `S7-10` 그 달 · K1)
//    — 값이 없는 칸(«산출 불가»)에서 상세 화면으로 보내지 않는다 ④ 읽을 때 짓기 판정([monthlyReportReadinessOf] — 닫힌 달 ·
//    개시 달부터).
// 🆕 R238(E11q-q5d) — 목표 줄 · 「목표 경로 보기」 = 목표 경로 판정([GoalVerdict] · `goalPathOf` 와 같은 셈 — 읽기 경로가 준다):
//    유보 = 표본 `m7_monthly_gap` · 앞섬 = `_2026_08` · 유지 · 이탈 = 목표 경로 판정 문장 · 판정 없음(null) = 유보 줄 · 링크 0.
//    링크 = 판정이 있고 본문이 있을 때 · 대사 어긋남(DRIFTING)이면 부재(표본 `_masked_recon` — 가림 달 = 버튼 부재).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AllocationBasis,
        AppRoutes,
        AsOf,
        AsOfSource,
        BlockFlag,
        FlagIds,
        LedgerTrustBadge,
        LedgerTrustGrade,
        MonthlyReport,
        RampLevel,
        ReportItem,
        SafetyState,
        SleeveId,
        SleeveWeight,
        TradeDate,
        UiLevel;

import '../orders/reconcile.dart' show ReconAction;
import '../safety/discretion.dart' show DiscretionBudget, discretionBudgetOf;
import 'goal_path_view.dart' show GoalPathTexts, GoalVerdict;
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

  /// 목표 경로 판정 보류(표본 `m7_monthly_gap`).
  static const String goalWithheld = '목표 경로 대비 판정을 보류합니다.';

  /// 🆕 R238 — 목표 줄(판정 갈래마다 · 유보 = [goalWithheld] · 앞섬 = 표본 `_2026_08` · 유지 · 이탈 = 목표 경로 판정 문장).
  static String goalLine(GoalVerdict? v) => switch (v) {
    null || GoalVerdict.withheld => goalWithheld,
    GoalVerdict.ahead => GoalPathTexts.reportAhead,
    GoalVerdict.onTrack => GoalPathTexts.onTrack,
    GoalVerdict.offTrack => GoalPathTexts.offTrack,
  };

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

  /// 🆕 R210 — 규칙 이행 «규칙대로 21건 · 재량 1건»(표본 `m7_monthly_2026_08` D3 꼴) · 이행률 조각 = [executionRate].
  static String executionCounts(int rule, int deviation) =>
      '규칙대로 $rule건 · 재량 $deviation건';

  /// 🆕 R210 — «이행률 95%»(표본 꼴 · 내림).
  static String executionRate(int pct) => '이행률 $pct%';

  /// 🆕 R214 — 국면 전환 «이번 달 1회»(표본).
  static String regimeSwitches(int n) => '이번 달 $n회';

  /// 🆕 R214 — 국면 메모 «국면을 판정할 수 없던 날 2일».
  static String regimeUnknownDays(int n) => '국면을 판정할 수 없던 날 $n일';

  /// 🆕 R214 — 표본 고지(한 달 이상) «관측 표본은 24개월입니다. 이 길이로는 규칙의 우열을 가릴 수 없습니다.»(표본 글자).
  static String sampleMonths(int months) =>
      '관측 표본은 $months개월입니다. 이 길이로는 규칙의 우열을 가릴 수 없습니다.';

  /// 🆕 R214 — 표본 고지(한 달 미만) «관측 표본은 21거래일입니다. 이 길이로는 아무것도 판정할 수 없습니다.»(표본 글자).
  static String sampleDays(int days) =>
      '관측 표본은 $days거래일입니다. 이 길이로는 아무것도 판정할 수 없습니다.';

  /// 🆕 R214 — 운영 램프 «운영 램프 L3»(표본).
  static String opsRamp(RampLevel l) => '운영 램프 ${l.name.toUpperCase()}';

  /// 🆕 R231 — «산출 불가» 글자 머리(값이 없는 칸 — 「자세히」 링크를 달지 않는다).
  static const String notComputedHead = '산출 불가';

  /// 🆕 R231 — 무결성 점검 중 칸(표본 `m7_monthly_masked_integrity`).
  static const String integrityHidden = '숨김 — 원장 무결성 점검 중';

  /// 🆕 R231 — 무결성 점검 중 목표 줄(표본).
  static const String integrityGoal = '원장 무결성 점검이 끝날 때까지 표시하지 않습니다.';

  /// 🆕 R231 — 대사 어긋남 D2 메모(표본 `m7_monthly_masked_recon`).
  static const String allocationUnsettled = '브로커 원장과 어긋난 종목이 있어 비중이 미확정입니다.';
}

/// 🆕 R231 — 월간 리포트 머리 신뢰 배지 글자(자동 매매 · 브로커 대사 · 표본에 있는 것은 글자 그대로).
abstract final class MonthlyTrustTexts {
  /// 대사 완료(표본 `m7_monthly_2026_08` 라벨).
  static const String reconciledLabel = '대사 완료';

  /// 🔴 표본 «브로커 원장과 수량·현금이 맞습니다.» 대신 — 대사의 현금 축은 관측만(`reconcile.dart` 머리 · 결제일 모델 전).
  static const String reconciledLine = '브로커 원장과 수량이 맞습니다. 현금은 아직 대조하지 않습니다.';

  /// 어긋남(표본 `m7_monthly_masked_recon`).
  static const String driftingLabel = '어긋남 확인 중';

  /// 어긋남 결과 줄(표본).
  static const String driftingLine = '브로커 원장과 수량이 어긋난 종목이 있습니다.';

  /// 확인 불가(표본 `ledger_trust_4` 라벨).
  static const String unverifiableLabel = '확인 불가';

  /// 🆕 그 달 마감까지 브로커 대사 0.
  static const String noReconLine = '그 달 마감까지 브로커 대사 기록이 없습니다.';

  /// 🆕 마지막 대사 = 대조 못 한 계좌 있음(`UNAVAILABLE`).
  static const String reconUnavailableLine = '마지막 대사에서 대조하지 못한 계좌가 있습니다.';

  /// 무결성 점검 중(표본 `m7_monthly_masked_integrity` 라벨).
  static const String integrityLabel = '검증 불가';

  /// 무결성 점검 중 결과 줄(표본).
  static const String integrityLine = '원장을 믿을 수 없어 수치를 숨겼습니다.';
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

/// 🆕 R214 — D1 원천.
class MonthlyRegimeFacts {
  /// 만든다.
  const MonthlyRegimeFacts({
    required this.previousState,
    required this.monthStates,
  });

  /// 앞 달 마지막으로 판정된 국면(BULL · NEUTRAL · BEAR — 없으면 null = 첫 판정은 전환이 아니다).
  final String? previousState;

  /// 그 달 `regime_score_daily.direction_state`(날짜 순 · UNKNOWN · null = 판정 못 한 날 — 앞 판정 그대로 잇는다).
  final List<String?> monthStates;
}

const Set<String> _kRegimeKnown = <String>{'BULL', 'NEUTRAL', 'BEAR'};

/// 🔴 D1 (값 · 메모) — 판정된 날끼리 이웃한 상태가 다르면 전환 1회(판정 못 한 날은 건너뛴다) · 빈 달 = 실패.
(String, String?) _regimeItemOf(MonthlyRegimeFacts f) {
  final String? prev = f.previousState;
  if (prev != null && !_kRegimeKnown.contains(prev)) {
    throw ArgumentError.value(
      prev,
      'regime',
      '앞 달 국면이 BULL · NEUTRAL · BEAR 가 아니다',
    );
  }
  if (f.monthStates.isEmpty) {
    throw ArgumentError.value(0, 'regime', '그 달 국면 기록 없음 — regime 을 비울 것');
  }
  String? last = prev;
  int switches = 0;
  int unknown = 0;
  for (final String? st in f.monthStates) {
    if (st == null || st == 'UNKNOWN') {
      unknown++;
      continue;
    }
    if (!_kRegimeKnown.contains(st)) {
      throw ArgumentError.value(st, 'regime', 'direction_state 밖');
    }
    if (last != null && st != last) switches++;
    last = st;
  }
  return (
    MonthlyReportTexts.regimeSwitches(switches),
    unknown > 0 ? MonthlyReportTexts.regimeUnknownDays(unknown) : null,
  );
}

/// 🆕 R210 — D3 원천(그 달 · 거래일 기준).
class MonthlyExecutionFacts {
  /// 만든다.
  const MonthlyExecutionFacts({
    required this.decisionKinds,
    required this.deviationJournals,
  });

  /// 그 달 `decision_log.kind` 전부(행마다) — 02 CHECK 밖 = 실패.
  final List<String> decisionKinds;

  /// 그 달 `decision_journal.is_deviation = 1` 행 수(음수 = 실패).
  final int deviationJournals;
}

/// `decision_log.kind` 전부(02 CHECK).
const Set<String> _kDecisionKinds = <String>{
  'ENTRY',
  'EXIT',
  'REBALANCE',
  'DEPOSIT',
  'WITHDRAWAL',
  'SAFETY',
  'RESUME',
  'LEDGER_FIX',
  'MANUAL',
};

/// 매매 규칙 결정(엔진 규칙이 낸 매매) — 입출금 · 안전 · 재개 · 원장 고침 · 사람 등록(MANUAL)은 이행 셈 밖.
const Set<String> _kRuleKinds = <String>{'ENTRY', 'EXIT', 'REBALANCE'};

/// 🔴 D3 (값 · 메모) — «규칙대로 N건 · 재량 M건 · 이행률 P%» · 전체 0 = 이행률 조각 없음.
(String, String?) _executionItemOf(MonthlyExecutionFacts f) {
  int rule = 0;
  for (final String k in f.decisionKinds) {
    if (!_kDecisionKinds.contains(k)) {
      throw ArgumentError.value(k, 'execution', 'decision_log.kind 밖');
    }
    if (_kRuleKinds.contains(k)) rule++;
  }
  final int dev = f.deviationJournals;
  if (dev < 0) {
    throw ArgumentError.value(dev, 'execution', '이탈 저널 수 음수');
  }
  final String counts = MonthlyReportTexts.executionCounts(rule, dev);
  final int total = rule + dev;
  return (
    total == 0
        ? counts
        : '$counts · ${MonthlyReportTexts.executionRate(rule * 100 ~/ total)}',
    null,
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
  // 🆕 R214 — G1 = 개시 날 → 월말 길이(한 달 미만 = 관측 거래일 수 · 그 뒤 = 개월 내림 — C2 와 같은 환산).
  final int span = _daysBetween(opened, monthEnd);
  final (String, String?) sample = (
    span < MonthlyReportTexts.monthDays
        ? MonthlyReportTexts.sampleDays(pts.length)
        : MonthlyReportTexts.sampleMonths(
            (span / MonthlyReportTexts.monthDays).floor(),
          ),
    null,
  );
  if (missing > 0) {
    return <MonthlyReportSlot, (String, String?)>{
      MonthlyReportSlot.sampleNotice: sample,
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
    MonthlyReportSlot.sampleNotice: sample,
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
/// 🆕 R231 — [unsettled] = 그 달 마감 시점 대사 어긋남 → 퍼센트마다 «?»(표본 `m7_monthly_masked_recon` 꼴).
String monthlyAllocationValueOf(
  List<SleeveWeight> weights, {
  bool unsettled = false,
}) {
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
    parts.add(
      '${w.sleeve.wire} ${(w.weight * 100).toStringAsFixed(1)}%${unsettled ? '?' : ''}',
    );
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

/// 머리 검사(달 꼴 · 월말 세션 · 생성 날 ≥ 월말 · 열람 수 ≥ 0) — 생성 날(한국) 글자.
String _checkedGenerated(
  String yyyyMm,
  TradeDate monthEnd,
  DateTime generatedAtUtc,
  int disclosureViewCount,
) {
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
  return generated;
}

AsOf _reportAsOf(DateTime generatedAtUtc, TradeDate monthEnd) => AsOf(
  observedAt: generatedAtUtc.toUtc(),
  tradeDate: monthEnd,
  source: AsOfSource.localSqlite,
  staleAfter: kMonthlyReportStaleAfter,
  label: MonthlyReportTexts.asOfLabel(monthEnd.yyyyMmDd),
);

/// 값이 있는 칸인가(«산출 불가» 아님).
bool _computed((String, String?)? v) =>
    v != null && !v.$1.startsWith(MonthlyReportTexts.notComputedHead);

/// 🔴 마감된 달의 월간 리포트를 짓는다 — 13칸 고정 · 원천이 있는 칸(A1 · A2 · C1 · C2 · D1 · D2 · D3 · D4 · E1 · G1 · G2)만 ·
/// 나머지(B1 · F1) = «산출 불가».
///
/// [monthEnd] = 그 달 마지막 KR 세션(기준일) · [generatedAtUtc] = 생성 시각(한국 날 < [monthEnd] = 미생성 → [ArgumentError]) ·
/// [trust] = 그 달 마감 시점 원장 신뢰 등급(읽기 경로가 준다 — 스트림의 «지금» 등급이 아니다 · 03 §3) ·
/// [disclosureViewCount] = 그 달 탐색 열람 수(명령 집계 · 음수 = [ArgumentError]) ·
/// [allocation] null · 빈 목록 = D2 값 «산출 불가» · [exposureTally] null = D2 메모 없음(달이 다르면 [ArgumentError]) ·
/// 🆕 [equity] null = A1 · A2 · C1 · C2 «산출 불가»(R205) · 🆕 [discretionUseDates] null = D4 · [strategy] null = E1
/// «산출 불가»(R208) · 🆕 [execution] null = D3 «산출 불가»(R210 · 안내 모드 = 이행 갭 창 전까지 null) ·
/// 🆕 [regime] null = D1 «산출 불가» · G1 = [equity] 를 따른다 · G2 = [strategy] 의 안전 상태를 따른다(R214) ·
/// 🆕 R231 [hasBody] = 조립 앱에 그 라우트(패턴)의 본문이 있나 — null = 「자세히」 0 · 값이 있는 C1 · C2 → `S7-3` ·
/// D3 → `S7-10` 그 달(K1) · [trust] 가 DRIFTING 이면 D2 값 퍼센트마다 «?» + 메모 머리(표본 `m7_monthly_masked_recon`).
/// 🆕 R238 [goal] = 그 달 목표 경로 판정(null = 판정 없음 → 유보 줄 · 링크 0) · 「목표 경로 보기」 = [goal] non-null ·
/// `S7-9` 본문 · [trust] ≠ DRIFTING 일 때 그 달 `aaq://report/goal/<달>`.
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
  MonthlyExecutionFacts? execution,
  MonthlyRegimeFacts? regime,
  String? backdateFootnote,
  bool Function(String route)? hasBody,
  GoalVerdict? goal,
}) {
  final String generated = _checkedGenerated(
    yyyyMm,
    monthEnd,
    generatedAtUtc,
    disclosureViewCount,
  );
  final String end = monthEnd.yyyyMmDd;
  if (exposureTally != null && exposureTally.month != yyyyMm) {
    throw ArgumentError.value(
      exposureTally.month,
      'exposureTally',
      '$yyyyMm 의 집계가 아니다',
    );
  }
  final List<SleeveWeight>? w = allocation;
  final bool unsettled =
      trust.grade == LedgerTrustGrade.drifting && w != null && w.isNotEmpty;
  final String allocationValue = w == null || w.isEmpty
      ? MonthlyReportTexts.notComputed
      : monthlyAllocationValueOf(w, unsettled: unsettled);
  final String? exposureNote = exposureTally == null
      ? null
      : monthlyExposureNoteOf(exposureTally);
  final String? allocationNote = unsettled
      ? <String>[
          MonthlyReportTexts.allocationUnsettled,
          if (exposureNote != null) exposureNote,
        ].join(' ')
      : exposureNote;
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
        if (strategy != null)
          MonthlyReportSlot.opsRamp: (
            MonthlyReportTexts.opsRamp(strategy.safety.rampLevel),
            null,
          ),
        if (regime != null)
          MonthlyReportSlot.regimeSwitches: _regimeItemOf(regime),
        if (execution != null)
          MonthlyReportSlot.execution: _executionItemOf(execution),
      };
  bool open(String route) => hasBody?.call(route) ?? false;
  final Map<MonthlyReportSlot, String> links = <MonthlyReportSlot, String>{
    if (open(AppRoutes.performanceDrawdown))
      for (final MonthlyReportSlot s in <MonthlyReportSlot>[
        MonthlyReportSlot.maxDrawdown,
        MonthlyReportSlot.timeUnderWater,
      ])
        if (_computed(filled[s])) s: AppRoutes.performanceDrawdown,
    if (open(AppRoutes.ledgerExecutionGapMonth) &&
        _computed(filled[MonthlyReportSlot.execution]))
      MonthlyReportSlot.execution: AppRoutes.ledgerExecutionGapMonth
          .replaceFirst(':yyyyMm', yyyyMm),
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
          detailDeepLink: links[s],
        ),
    ]),
    goalLine: MonthlyReportTexts.goalLine(goal),
    disclosureViewCountText: MonthlyReportTexts.disclosureViews(
      disclosureViewCount,
    ),
    trust: trust,
    asOf: _reportAsOf(generatedAtUtc, monthEnd),
    backdateFootnote: backdateFootnote,
    generatedAtText: MonthlyReportTexts.generatedAt(generated),
    configHash: configHash,
    goalDeepLink:
        goal != null &&
            trust.grade != LedgerTrustGrade.drifting &&
            open(AppRoutes.reportGoalPath)
        ? AppRoutes.reportGoalPath.replaceFirst(':yyyyMm', yyyyMm)
        : null,
  );
}

/// 🆕 R231 — 원장 무결성 점검 중(`LEDGER_INTEGRITY` 깃발 · 01 §2-10)의 월간 리포트 — 표본 `m7_monthly_masked_integrity` 꼴 그대로:
/// 13칸 «숨김 — 원장 무결성 점검 중»(메모 · 링크 0) · 목표 줄 · 배지 UNVERIFIABLE · BLOCKED(«검증 불가» · X5 정정 마법사 =
/// 본문이 있을 때) · 열람 수 = 그대로(보류 행도 열람이다 — R223 S7). 머리 검사 = [monthlyReportOf] 와 같다.
MonthlyReport monthlyReportIntegrityMaskedOf({
  required String yyyyMm,
  required TradeDate monthEnd,
  required DateTime generatedAtUtc,
  required String configHash,
  required int disclosureViewCount,
  bool Function(String route)? hasBody,
}) {
  final String generated = _checkedGenerated(
    yyyyMm,
    monthEnd,
    generatedAtUtc,
    disclosureViewCount,
  );
  return MonthlyReport(
    yyyyMm: yyyyMm,
    items: List<ReportItem>.unmodifiable(<ReportItem>[
      for (final MonthlyReportSlot s in MonthlyReportSlot.values)
        ReportItem(
          code: s.code,
          order: s.order,
          sectionCode: s.sectionCode,
          title: s.title,
          valueText: MonthlyReportTexts.integrityHidden,
        ),
    ]),
    goalLine: MonthlyReportTexts.integrityGoal,
    disclosureViewCountText: MonthlyReportTexts.disclosureViews(
      disclosureViewCount,
    ),
    trust: LedgerTrustBadge(
      grade: LedgerTrustGrade.unverifiable,
      level: UiLevel.blocked,
      label: MonthlyTrustTexts.integrityLabel,
      consequenceLine: MonthlyTrustTexts.integrityLine,
      actionDeepLink: (hasBody?.call(AppRoutes.x5RepairWizard) ?? false)
          ? AppRoutes.x5RepairWizard
          : null,
    ),
    asOf: _reportAsOf(generatedAtUtc, monthEnd),
    generatedAtText: MonthlyReportTexts.generatedAt(generated),
    configHash: configHash,
  );
}

/// 🆕 R231 — 자동 매매의 그 달 마감 시점 원장 신뢰 배지(미결 209 ⓔ-2 · 03 §3 «리포트 = 그 달 마감 시점»).
///
/// [checks] = 브로커 대사 원장(`reconciliation_log` 의 브로커 대사 행 · 해제 행 제외) 시각 순 — 실행 시각의 한국 날 ≤ [monthEnd]
/// 만 본다(append-only → 다시 지어도 같은 배지). 🔴 등급 = **그 달 마지막 대사의 결과**:
/// BLOCKED = DRIFTING · WATCH(표본 `m7_monthly_masked_recon` 글자 · 차단 보드 = 본문이 있을 때) ·
/// MATCHED · TRANSIENT(재대사에서 사라짐) = RECONCILED · OK(표본 라벨 · 결과 줄 = 현금 축 관측만) ·
/// UNAVAILABLE · 대사 0 = UNVERIFIABLE · WATCH(자동 매매에서 주문을 막는 결과가 아니다 — 표본 BLOCKED 는 안내 모드 청산 안내를
/// 비우는 결과). [LedgerTrustBadge.lastVerifiedOn] = 마지막 MATCHED · TRANSIENT 의 한국 날(없으면 null).
/// 시각 순이 아니면 [ArgumentError].
LedgerTrustBadge monthlyLedgerTrustOf({
  required List<(DateTime, ReconAction)> checks,
  required TradeDate monthEnd,
  bool Function(String route)? hasBody,
}) {
  final String end = monthEnd.yyyyMmDd;
  if (!_ymd.hasMatch(end)) {
    throw ArgumentError.value(end, 'monthEnd', 'YYYY-MM-DD 가 아니다');
  }
  return reconLedgerTrustOf(
    checks: checks,
    throughDay: end,
    noReconLine: MonthlyTrustTexts.noReconLine,
    hasBody: hasBody,
  );
}

/// 🆕 E11q-q6c — 브로커 대사 결과 → 원장 신뢰 배지(한 판정 · as-of 만 다르다): 월간 리포트 = 그 달 마감([monthlyLedgerTrustOf]) ·
/// 지금 등급(`LedgerTrustRepository.watchGrade` · 자동 매매) = 지금까지([throughDay] null = 전부).
///
/// 갈래 · 글자 = [monthlyLedgerTrustOf] 그대로 — 다른 것은 대사 0 줄([noReconLine] · 그 달 마감까지 / 아직)뿐이다.
/// [throughDay] = 실행 시각의 한국 날 상한(포함). 시각 순이 아니면 [ArgumentError].
LedgerTrustBadge reconLedgerTrustOf({
  required List<(DateTime, ReconAction)> checks,
  required String? throughDay,
  required String noReconLine,
  bool Function(String route)? hasBody,
}) {
  DateTime? prev;
  ReconAction? last;
  String? verified;
  for (final (DateTime at, ReconAction a) in checks) {
    if (prev != null && at.isBefore(prev)) {
      throw ArgumentError.value(at, 'checks', '대사가 시각 순이 아니다');
    }
    prev = at;
    final String day = kstDateText(at);
    if (throughDay != null && day.compareTo(throughDay) > 0) continue;
    last = a;
    if (a == ReconAction.matched || a == ReconAction.transient) verified = day;
  }
  final TradeDate? on = verified == null ? null : TradeDate(verified);
  return switch (last) {
    ReconAction.blocked => LedgerTrustBadge(
      grade: LedgerTrustGrade.drifting,
      level: UiLevel.watch,
      label: MonthlyTrustTexts.driftingLabel,
      consequenceLine: MonthlyTrustTexts.driftingLine,
      lastVerifiedOn: on,
      actionDeepLink: (hasBody?.call(AppRoutes.m5BlockBoard) ?? false)
          ? AppRoutes.m5BlockBoard
          : null,
    ),
    ReconAction.matched || ReconAction.transient => LedgerTrustBadge(
      grade: LedgerTrustGrade.reconciled,
      level: UiLevel.ok,
      label: MonthlyTrustTexts.reconciledLabel,
      consequenceLine: MonthlyTrustTexts.reconciledLine,
      lastVerifiedOn: on,
    ),
    ReconAction.unavailable || null => LedgerTrustBadge(
      grade: LedgerTrustGrade.unverifiable,
      level: UiLevel.watch,
      label: MonthlyTrustTexts.unverifiableLabel,
      consequenceLine: last == null
          ? noReconLine
          : MonthlyTrustTexts.reconUnavailableLine,
      lastVerifiedOn: on,
    ),
  };
}

/// 🆕 R231 — 읽을 때 짓는 월간 리포트의 갈래(저장 0 — 스냅숏 · 미생성 문장 = ⓔ-4).
enum MonthlyReportReadiness {
  /// 닫힌 달(한국 오늘 > 월말 세션) · 개시 달부터 — 짓는다.
  closed,

  /// 아직 닫히지 않은 달(오늘 ≤ 월말 세션 · 미래 달) — 미생성 문장 = ⓔ-4(생성일 규칙 · 미결 40).
  pending,

  /// 개시 전 달 · 개시 0 — 그 달의 리포트는 없다(지어내지 않는다).
  beforeOpening,
}

/// 🆕 R231 — [yyyyMm] 을 지금 지을 수 있나 — [openingDate] = 개시 날(`openingCashTradeDate` · null = 개시 0) ·
/// [monthEnd] = 그 달 마지막 KR 세션. 🔴 닫힘 = 한국 오늘 > 월말 세션(월말 세션 날 = 마감 평가 전일 수 있다 — 결측으로 잘못
/// 말하지 않는다). 개시 판정이 먼저(개시 0 이면 미래 달도 «개시 전»).
MonthlyReportReadiness monthlyReportReadinessOf({
  required String yyyyMm,
  required TradeDate monthEnd,
  required String? openingDate,
  required DateTime nowUtc,
}) {
  if (!_yyyyMm.hasMatch(yyyyMm)) {
    throw ArgumentError.value(yyyyMm, 'yyyyMm', 'YYYY-MM 이 아니다');
  }
  final String end = monthEnd.yyyyMmDd;
  if (end.length != 10 || !end.startsWith('$yyyyMm-')) {
    throw ArgumentError.value(end, 'monthEnd', '$yyyyMm 의 날이 아니다');
  }
  final String? o = openingDate;
  if (o != null && !_ymd.hasMatch(o)) {
    throw ArgumentError.value(o, 'openingDate', 'YYYY-MM-DD 가 아니다');
  }
  if (o == null || yyyyMm.compareTo(o.substring(0, 7)) < 0) {
    return MonthlyReportReadiness.beforeOpening;
  }
  if (kstDateText(nowUtc).compareTo(end) <= 0) {
    return MonthlyReportReadiness.pending;
  }
  return MonthlyReportReadiness.closed;
}
