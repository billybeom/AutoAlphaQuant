// P0S 월간 SAF-306 — 과세연도 금융소득 누계 · 판정 · «과세연도 첫 초과 월» 알림
// (04 §1 Level 3 v2.46 306 행 · §5-3 v2.46 · 설계 13 §8 R175 · 발주자 확정 2026-11-19 · 계획서
// `10_리뷰/2026-11-19_E3d_경고한도_운영배선_계획.md` §3).
//
// 🔴 순수 계산이다(저장 · 조회 0) — 부르는 곳 = E3d-3 월 리밸런싱 잡(`monthly_rebalance` 안 단계).
// 🔴 산식(발주자 확정) = 과세연도(1~12월) 누계 · 일반(과세)계좌의 국내상장 해외 ETF 매도 건별 «양의 실현이익»
//    (평균 단가 · 손실 통산 없음) + 분배금(원천징수 전) · ISA · 연금 계좌 제외 — 세후 성적의 전제 tax_lib
//    `realized_gains`(엔진 `realizedGains`)와 같은 규약에 실제 분배금을 더한 것.
// 🔴 평균 단가 = 그 종목의 처음부터 모든 살아 있는 체결([effectiveFillsOf] — 되돌림 빠짐 · 정정 = 뿌리 차례)로 다시 센다.
//    매수 = 원가 += 수량 × 가 · 매도 = 원가 몫 = 원가 × 매도 수량 ÷ 보유(곱셈 먼저) · 이익 = 매도 수량 × 가 − 원가 몫.
//    수수료 · 세금은 빼지 않는다(이익을 크게 센다 — 경고 쪽으로 기운다).
// 🔴 매도가 보유보다 많다(평균 단가를 모른다) · 체결 링크가 깨졌다 = [RiskCheckUnavailable] → 단계가 «계측 없음 · 알림 0».
// 🔴 판정 = [financialIncomeCapExceeded](GV-40b 와 같은 한 줄 · 상한 포함 == 통과).
// 🔴 알림 = 과세연도 첫 초과 월 1건 — 이달 말까지 누계가 넘고 지난달 말까지 누계(같은 해 · 1월 = 0)는 넘지 않았을 때.
// 🔵 계좌 · 종목 거르기 = 부르는 쪽(과세계좌 = 슬리브 C 의 계좌 별칭 · 종목 = [P0sIncomeWarnSetup.taxableSymbols]).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show OrderSide;

import '../decimal_rules.dart';
import '../portfolio/month_end_plan.dart' show MonthEndConfig;
import '../repair/fill_replay.dart' show LedgerFillRow, effectiveFillsOf;
import '../risk/limits.dart' show RiskCheckUnavailable;
import '../risk/warn_limits.dart' show financialIncomeCapExceeded;
import 'p0s_warn.dart' show kFinancialIncomeAlertCode, p0sExposureMap;

/// SAF-306 연 금융소득 상한(02 §4 `risk.annual_financial_income_cap_krw` · 04 §1 2,000만원 — 여기서 정하지 않는다).
Decimal p0sFinancialIncomeCapKrw() => Decimal.fromInt(20000000);

/// 월간 306 단계 설정(과세계좌 · 해외 ETF 종목 · 상한).
class P0sIncomeWarnSetup {
  /// 만든다 — [taxableAccountAlias] = 일반(과세)계좌 별칭(P0S = 슬리브 C 의 계좌) · [monthEnd] = 운영 설정 슬리브 종목 표
  /// (해외 ETF = B 자산 · C 채권 · C 금 — [p0sExposureMap] 의 해외 기초자산 칸) · [capKrw] 빈 칸 = [p0sFinancialIncomeCapKrw].
  P0sIncomeWarnSetup({
    required this.taxableAccountAlias,
    MonthEndConfig? monthEnd,
    Decimal? capKrw,
  }) : taxableSymbols = Set<String>.unmodifiable(
         p0sExposureMap(monthEnd).usdUnderlyingSymbols,
       ),
       capKrw = capKrw ?? p0sFinancialIncomeCapKrw() {
    if (taxableAccountAlias.isEmpty) {
      throw ArgumentError.value(taxableAccountAlias, 'taxableAccountAlias');
    }
  }

  /// 일반(과세)계좌 별칭.
  final String taxableAccountAlias;

  /// 국내상장 해외 ETF(실현이익 · 분배금을 세는 종목).
  final Set<String> taxableSymbols;

  /// 상한(원).
  final Decimal capKrw;
}

/// 과세계좌 분배금 한 줄(살아 있는 것 · 원천징수 전 원).
class P0sDistribution {
  /// 만든다 — [amountKrw] 0 이하 = [ArgumentError].
  P0sDistribution({
    required this.effectiveDate,
    required this.symbol,
    required this.amountKrw,
  }) {
    if (amountKrw <= Decimal.zero) {
      throw ArgumentError.value(amountKrw, 'amountKrw', '양수');
    }
  }

  /// 원장 열 꼴(`ledger_event.amount_krw` REAL)에서 — 숫자를 글자로 거쳐 Decimal(이진 값을 옮기지 않는다).
  factory P0sDistribution.fromLedger({
    required String effectiveDate,
    required String symbol,
    required double amountKrw,
  }) => P0sDistribution(
    effectiveDate: effectiveDate,
    symbol: symbol,
    amountKrw: promoteRatio(amountKrw),
  );

  /// 지급일(`YYYY-MM-DD`).
  final String effectiveDate;

  /// 종목.
  final String symbol;

  /// 세전 금액(원).
  final Decimal amountKrw;
}

/// 매도 건별 양의 실현이익(거래일 · 원) — [fills] = 한 종목의 원장 체결(입력 차례).
/// 🔴 평균 단가 재생 · 손실 건은 버린다 · 매도 > 보유 · 링크 깨짐 = [RiskCheckUnavailable].
List<(String, Decimal)> positiveRealizedGainsOf(List<LedgerFillRow> fills) {
  final List<LedgerFillRow> live;
  try {
    live = effectiveFillsOf(fills);
  } on StateError catch (e) {
    throw RiskCheckUnavailable('금융소득 — 체결 링크: ${e.message}');
  } on ArgumentError catch (e) {
    throw RiskCheckUnavailable('금융소득 — 체결 링크: ${e.message}');
  }
  int held = 0;
  Decimal cost = Decimal.zero;
  final List<(String, Decimal)> out = <(String, Decimal)>[];
  for (final LedgerFillRow f in live) {
    final Decimal q = Decimal.fromInt(f.quantity);
    final Decimal amount = multiply(q, promoteRatio(f.price));
    if (f.side == OrderSide.buy) {
      held += f.quantity;
      cost += amount;
      continue;
    }
    if (f.quantity > held) {
      throw RiskCheckUnavailable(
        '금융소득 — 평균 단가 모름(매도 ${f.quantity} > 보유 $held · ${f.executionId})',
      );
    }
    final Decimal share = mulDiv(cost, q, Decimal.fromInt(held));
    held -= f.quantity;
    cost = held == 0 ? Decimal.zero : cost - share;
    final Decimal gain = amount - share;
    if (gain > Decimal.zero) out.add((f.tradeDate, gain));
  }
  return out;
}

/// 과세연도 누계(원) — [from] 이상 · [before] 미만 날짜.
class P0sIncomeTally {
  /// 만든다.
  const P0sIncomeTally({
    required this.realizedGainKrw,
    required this.distributionKrw,
  });

  /// 양의 실현이익 합.
  final Decimal realizedGainKrw;

  /// 분배금(세전) 합.
  final Decimal distributionKrw;

  /// 금융소득 누계.
  Decimal get totalKrw => realizedGainKrw + distributionKrw;
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 월간 306 단계 결과.
class P0sIncomeWarnStep {
  /// 만든다.
  const P0sIncomeWarnStep({
    required this.month,
    required this.ytd,
    required this.previousYtd,
    required this.exceeded,
    required this.unavailable,
    required this.alerts,
  });

  /// 판정 달(`YYYY-MM`).
  final String month;

  /// 이달 말까지 누계(셈할 수 없으면 null).
  final P0sIncomeTally? ytd;

  /// 지난달 말까지 누계(같은 해 · 1월 = 0 · 셈할 수 없으면 null).
  final P0sIncomeTally? previousYtd;

  /// 이달 말 누계가 상한을 넘었나(셈할 수 없으면 거짓).
  final bool exceeded;

  /// 셈할 수 없었던 까닭(잡 보고 «계측 불가» 한 줄 · 알림 0).
  final String? unavailable;

  /// 낼 알림(과세연도 첫 초과 월 — 0 또는 1).
  final List<String> alerts;
}

/// 🔴 월간 SAF-306 단계 — [month](`YYYY-MM` · 판정 월말의 달)의 과세연도 누계를 세고 첫 초과 월만 알린다.
///
/// [fillsBySymbol] = 과세계좌의 종목 → 원장 체결(입력 차례 · 처음부터) — [P0sIncomeWarnSetup.taxableSymbols] 밖 종목은 보지 않는다 ·
/// [distributions] = 과세계좌의 살아 있는 분배금(같은 거르기). 셈 실패 = 판정 없음 · 알림 0 · 까닭.
P0sIncomeWarnStep p0sMonthlyIncomeWarnStep({
  required String month,
  required Map<String, List<LedgerFillRow>> fillsBySymbol,
  required List<P0sDistribution> distributions,
  required P0sIncomeWarnSetup setup,
}) {
  final RegExpMatch? m = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(month);
  final int mm = m == null ? 0 : int.parse(m.group(2)!);
  if (m == null || mm < 1 || mm > 12) {
    throw ArgumentError.value(month, 'month', 'YYYY-MM');
  }
  final int year = int.parse(m.group(1)!);
  final String from = '$year-01-01';
  final String monthStart = '$year-${_two(mm)}-01';
  final String nextStart = mm == 12
      ? '${year + 1}-01-01'
      : '$year-${_two(mm + 1)}-01';

  final List<(String, Decimal)> gains = <(String, Decimal)>[];
  try {
    final List<String> symbols =
        fillsBySymbol.keys.where(setup.taxableSymbols.contains).toList()
          ..sort();
    for (final String s in symbols) {
      gains.addAll(positiveRealizedGainsOf(fillsBySymbol[s]!));
    }
  } on RiskCheckUnavailable catch (e) {
    return P0sIncomeWarnStep(
      month: month,
      ytd: null,
      previousYtd: null,
      exceeded: false,
      unavailable: e.message,
      alerts: const <String>[],
    );
  }

  P0sIncomeTally tally(String before) {
    Decimal g = Decimal.zero;
    for (final (String d, Decimal v) in gains) {
      if (d.compareTo(from) >= 0 && d.compareTo(before) < 0) g += v;
    }
    Decimal dist = Decimal.zero;
    for (final P0sDistribution x in distributions) {
      if (!setup.taxableSymbols.contains(x.symbol)) continue;
      final String d = x.effectiveDate;
      if (d.compareTo(from) >= 0 && d.compareTo(before) < 0) {
        dist += x.amountKrw;
      }
    }
    return P0sIncomeTally(realizedGainKrw: g, distributionKrw: dist);
  }

  final P0sIncomeTally now = tally(nextStart);
  final P0sIncomeTally prev = tally(monthStart);
  final bool over = financialIncomeCapExceeded(now.totalKrw, setup.capKrw);
  final bool wasOver = financialIncomeCapExceeded(prev.totalKrw, setup.capKrw);
  return P0sIncomeWarnStep(
    month: month,
    ytd: now,
    previousYtd: prev,
    exceeded: over,
    unavailable: null,
    alerts: List<String>.unmodifiable(<String>[
      if (over && !wasOver) kFinancialIncomeAlertCode,
    ]),
  );
}
