// 🆕 E11q-q5c — M7 `S7-3` 드로다운 · TUW 맥락 VM(설계 13 §8 R226 · 03 §7 · 01 §8 미결 44 · 표본 `m7/m7_dd_context_*`).
//
// 🔴 원천 = 계층 B · 월간 리포트 · 성과 탐색과 같은 TWR 지수(`twrIndex` — 입출금 = 수익 아님 · 개시 이전 = 성과 밖) · 지금 원장 한 파일.
// 🔴 셈 = 월간 리포트 C1 · C2 와 같은 규칙(고점 허용 오차 1e-9 · 낙폭 = 지수 ÷ 그때까지의 고점 − 1 · 최장 회복 기간 = 고점 날 → 회복 날
//    달력 일수 · 진행 중이면 마지막 점까지 · 한 달 = 30.4375일 내림) · 글자 꼴 = 표본(«현재 낙폭 −2.1%» · «최대 낙폭 −6.4%» ·
//    «회복까지 걸린 최장 기간 3개월»).
// 🔴 기본 구간(인자 없음) = 운용 전체(첫 스냅숏 ~ 마지막 스냅숏) · 이름 = «최근 n개월»(두 날이 걸친 달 수).
// 🔴 결측 = 있는 스냅숏으로 잇는다(끊긴 날 안의 저점은 모른다) — 최대 낙폭 문장 끝에 «(결측 n거래일 제외)» 를 붙인다(🆕 · 발주자 위임 —
//    권고대로 · 월간 리포트는 «그 달» 결측 = 산출 불가지만 전체 기간에 같은 규칙을 쓰면 하루 결측이 영영 산출 불가가 된다).
// 🔴 게이지 = 현재 낙폭 ÷ 최대 낙폭(0~1 · 두 자리) — 최대 낙폭 0 = 0. 참조 구간 · 단서 = 엔진 원천 0 → null(지어내지 않는다).
// 🔴 무결성 점검 중 · 스냅숏 0 = 실패(이 타입에 빈 상태 칸이 없다 — «표본 부족» = 미결 44) · 임의 구간 = 원천 없음.

import 'package:domain_contracts/domain_contracts.dart'
    show AsOf, AsOfSource, DrawdownContextVm, TradeDate;

import 'monthly_report.dart' show MonthlyReportTexts;
import 'tier_b.dart' show EquityPoint, twrIndex;

/// 드로다운 기준 유효 시간(표본 93600초 = 26시간).
const Duration kDrawdownContextStaleAfter = Duration(hours: 26);

const double _kPeakTolerance = 1e-9;

/// `S7-3` 글자(표본 그대로 · 🆕 = 표본 밖 상태).
abstract final class DrawdownContextTexts {
  /// 기본 구간 이름.
  static String period(int months) => '최근 $months개월';

  /// 현재 낙폭.
  static String current(String pct) => '현재 낙폭 $pct';

  /// 최대 낙폭 — [missing] > 0 = 🆕 결측 고지.
  static String max(String pct, int missing) =>
      missing > 0 ? '최대 낙폭 $pct (결측 $missing거래일 제외)' : '최대 낙폭 $pct';

  /// 최장 회복 기간(일수 → 달 · 월간 리포트와 같은 환산).
  static String tuw(int days) => days <= 0
      ? '전고점 아래로 내려간 적이 없습니다'
      : days < MonthlyReportTexts.monthDays
      ? '회복까지 걸린 최장 기간 1개월 미만'
      : '회복까지 걸린 최장 기간 ${(days / MonthlyReportTexts.monthDays).floor()}개월';

  /// 기준.
  static String asOfLabel(String day) => '드로다운 기준 $day';
}

/// 낙폭 → «−6.4%» · 0 = «0.0%»(월간 리포트 C1 과 같은 꼴).
String _ddPct1(double dd) {
  final String v = (dd.abs() * 100).toStringAsFixed(1);
  return v == '0.0' ? '0.0%' : '−$v%';
}

int _daysBetween(String a, String b) =>
    DateTime.parse('${b}T00:00:00Z')
        .difference(DateTime.parse('${a}T00:00:00Z'))
        .inDays;

String _shift(String ymd, int days) {
  final DateTime d = DateTime.parse('${ymd}T00:00:00Z')
      .add(Duration(days: days));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// 🔴 `S7-3` VM — [equity] = 개시 뒤 마감 스냅숏(날짜 순 · 흐름 포함) · [isSession] = 한국 세션(결측 셈) ·
/// [integrityHidden] = 원장 무결성 점검 중(실패) · 스냅숏 0 = 실패.
DrawdownContextVm drawdownContextVmOf({
  required List<EquityPoint> equity,
  required bool Function(String ymd) isSession,
  required DateTime nowUtc,
  required bool integrityHidden,
}) {
  if (integrityHidden) {
    throw StateError('드로다운: 원장 무결성 점검 중에는 보여 주지 않습니다');
  }
  if (equity.isEmpty) {
    throw StateError('드로다운: 마감 평가액 기록 없음(운용 첫 마감 전)');
  }
  for (int k = 1; k < equity.length; k++) {
    if (equity[k - 1].date.compareTo(equity[k].date) >= 0) {
      throw ArgumentError.value(equity[k].date, 'equity', '날짜 순이 아니다');
    }
  }
  final List<double> idx = twrIndex(equity);
  final int end = equity.length - 1;
  double mdd = 0;
  int longest = 0;
  int peak = 0;
  bool under = false;
  for (int k = 1; k <= end; k++) {
    if (idx[k] >= idx[peak] * (1 - _kPeakTolerance)) {
      if (under) {
        final int d = _daysBetween(equity[peak].date, equity[k].date);
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
    final int d = _daysBetween(equity[peak].date, equity[end].date);
    if (d > longest) longest = d;
  }
  final double current = under ? idx[end] / idx[peak] - 1 : 0;

  // 결측 = 첫 스냅숏 ~ 마지막 스냅숏 사이 스냅숏 없는 한국 세션.
  final Set<String> have = <String>{for (final EquityPoint p in equity) p.date};
  int missing = 0;
  for (
    String d = equity.first.date;
    d.compareTo(equity[end].date) <= 0;
    d = _shift(d, 1)
  ) {
    if (isSession(d) && !have.contains(d)) missing++;
  }

  final String first = equity.first.date;
  final String last = equity[end].date;
  final int months =
      (int.parse(last.substring(0, 4)) * 12 + int.parse(last.substring(5, 7))) -
      (int.parse(first.substring(0, 4)) * 12 +
          int.parse(first.substring(5, 7))) +
      1;
  final double norm = mdd == 0
      ? 0
      : ((current / mdd).clamp(0.0, 1.0) * 100).round() / 100;
  return DrawdownContextVm(
    periodLabel: DrawdownContextTexts.period(months),
    currentDdText: DrawdownContextTexts.current(_ddPct1(current)),
    maxDdText: DrawdownContextTexts.max(_ddPct1(mdd), missing),
    tuwText: DrawdownContextTexts.tuw(longest),
    ddNormalized: norm,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(last),
      source: AsOfSource.localSqlite,
      staleAfter: kDrawdownContextStaleAfter,
      label: DrawdownContextTexts.asOfLabel(last),
    ),
  );
}
