// 🆕 E11q-q5c2 — M7 `S7-3b` 슬리브 기여 분해 VM(설계 13 §8 R228 · 03 §8 · 01 §8 미결 45 · 표본 `m7/m7_contrib_*`).
//
// 🔴 원천 = 계층 B · 드로다운 · 성과 탐색과 같은 TWR 지수(`twrIndex` — 입출금 = 수익 아님 · 개시 이전 = 성과 밖) + 슬리브별 손익
//    재구성(그날 보유 = 지금 보유 − 그 뒤 체결 · 평가 = 그날 원가 종가 `close_unadj` — 마감 평가 잡과 같은 평가 ·
//    체결 현금 = 금액 · 수수료 · 세금 · REVERSAL = 반대 부호). 지금 원장 한 파일.
// 🔴 기여(연결) = Σ_k I_{k−1} × 손익_{s,k} ÷ E_{k−1}(I = TWR 지수 · E = 마감 평가액) — 손익이 슬리브 손익뿐이면 행의 합 = 그 기간
//    TWR(복리 잔차 0). 슬리브 밖 손익이 있으면 합 ≠ TWR 이고 화면은 잔차를 채우지 않는다(03 §8).
// 🔴 슬리브 = A(POT 포함 — 회계 소속 · 보유 현황과 같은 규칙) · B · C 차례 · 행 제목 = 입금 계획과 같은 글자(`WhatIfConfig`).
// 🔴 기간 = 받은 구간 · 시작 기준 = 구간 앞 마지막 마감 평가(없으면 구간 안 첫 마감 = 개시) · 끝 = 구간 안 마지막 마감.
//    기본 구간(라우트 인자 0 — 셸이 넘긴다) = [contributionDefaultRange] = 이번 달(한국) 1일 ~ 오늘(발주자 위임 — 권고대로).
// 🔴 산출 불가(표본 partial 꼴 · 지어내지 않는다): 그 슬리브 보유 종목의 마감 종가 결측 · 보유 재구성 음수 = 그 슬리브 ·
//    구간 안 마감 0 · 귀속 못 하는 전략 · 귀속 규칙 전 원장 사건(분배금 · 원천징수 · 단주 대금 · 기업행위 · 수기 체결) = 전 행.
//    나머지 행을 100% 로 다시 맞추지 않는다.
// 🔴 막대(normalized) = 가장 큰 |기여| 대비(두 자리) — 몫 눈금(합 = 1)은 결측 행이 있으면 «나머지를 100% 로 맞추는» 셈이 된다 ·
//    표본 3sleeve 의 0.31 · 0.52 · 0.17 은 몫 눈금이다(다른 눈금 — 글자는 같다).
// 🔴 무결성 점검 중 · 마감 평가 0 · 구간이 첫 마감 전 = 실패(이 타입에 빈 상태 칸이 없다 — 드로다운과 같은 규칙).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        ContributionRow,
        ContributionVm,
        DateRange,
        FillKind,
        OrderSide,
        SleeveId,
        TradeDate;

import '../orders/order_draft.dart' show P0sStrategyIds;
import '../orders/reconcile.dart' show LedgerHolding;
import '../whatif/what_if_config.dart' show WhatIfConfig;
import 'ledger_views.dart' show kstDateText;
import 'tier_b.dart' show EquityPoint, twrIndex;

/// 기여 분해 기준 유효 시간(표본 93600초 = 26시간).
const Duration kContributionStaleAfter = Duration(hours: 26);

/// 기본 구간 프리셋 식별자(이번 달 1일 ~ 오늘 · 한국).
const String kContributionDefaultPreset = 'THIS_MONTH';

/// 기여 재구성의 체결 한 행 — KR 브로커 체결 · 집행일 = 주문 의도의 거래일(포지션 재생과 같은 범위).
class ContributionFill {
  /// 만든다.
  const ContributionFill({
    required this.strategyId,
    required this.symbol,
    required this.tradeDate,
    required this.side,
    required this.kind,
    required this.quantity,
    required this.price,
    this.commission = 0,
    this.tax = 0,
  });

  /// `order_intents.strategy_id`.
  final String strategyId;

  /// 종목.
  final String symbol;

  /// 집행일(`order_intents.trade_date`).
  final String tradeDate;

  /// 매수 · 매도.
  final OrderSide side;

  /// 원 체결 · 상쇄 · 재기록.
  final FillKind kind;

  /// 저장 수량(양수).
  final int quantity;

  /// 체결가 · 수수료 · 세금(저장 양수).
  final double price, commission, tax;

  int get _sign => kind == FillKind.reversal ? -1 : 1;

  /// 보유 변화 — 매수 + · 매도 − · REVERSAL 반대.
  int get holdingDelta =>
      _sign * (side == OrderSide.buy ? quantity : -quantity);

  /// 현금 효과 — 매수 −금액 · 매도 +금액 · 수수료 · 세금 − · REVERSAL 반대.
  double get cash =>
      _sign *
      ((side == OrderSide.buy ? -1 : 1) * quantity * price - commission - tax);
}

/// 귀속 규칙 전 원장 사건 종류(🆕 — 슬리브에 나눌 규칙이 정해지기 전에는 전 행 «산출 불가»).
enum ContributionEventKind {
  /// 분배금(`cash_flow` DISTRIBUTION).
  distribution('분배금'),

  /// 원천징수(TAX_WITHHELD).
  taxWithheld('원천징수'),

  /// 병합 단주 대금(CASH_IN_LIEU).
  cashInLieu('단주 대금'),

  /// 기업행위(분할 · 병합 — 보유 재구성이 그날을 건너지 못한다).
  corporateAction('기업행위'),

  /// 수기 체결(브로커 주문 없음 — 포지션 재생 밖).
  manualFill('수기 체결');

  const ContributionEventKind(this.label);

  /// 사유 글자.
  final String label;
}

/// 원장 사건 한 건(한국 날 · 종류).
class ContributionEvent {
  /// 만든다.
  const ContributionEvent(this.date, this.kind);

  /// `YYYY-MM-DD`(한국).
  final String date;

  /// 종류.
  final ContributionEventKind kind;
}

/// `S7-3b` 글자(표본 그대로 · 🆕 = 표본 밖 상태).
abstract final class ContributionTexts {
  /// 전 행 산출 — 산식 주석(표본 3sleeve).
  static const String methodFull = '슬리브 기여는 엔진이 분해합니다. 화면이 더하거나 나누지 않습니다.';

  /// 산출 불가 행이 있을 때 — 산식 주석(표본 partial).
  static const String methodPartial =
      '산출할 수 없는 슬리브는 비워 둡니다. 나머지를 100%로 다시 맞추지 않습니다.';

  /// 환율 주석(표본 — B = 환노출 비헤지 · 환율 기여 분리 규약은 03 §17 미결 4).
  static const String fxNote = '환헤지를 하지 않으므로 원화 환산 결과에 환율이 섞여 있습니다.';

  /// 산출 불가 행의 값 글자.
  static const String unavailableValue = '산출 불가';

  /// 산출 불가 사유 한 줄(표본 꼴).
  static String unavailable(String reason) => '$reason — 이 슬리브는 산출할 수 없습니다';

  /// 마감 종가 결측.
  static String priceGap(String days) => '$days 가격 결측';

  /// 🆕 구간 안 마감 평가 0(시작 기준만 있다).
  static const String noCloseYet = '이 기간 마감 평가 아직 없음';

  /// 🆕 귀속 규칙 전 원장 사건.
  static String event(String day, ContributionEventKind kind) =>
      '${dayText(day)} ${kind.label} 기록(슬리브 귀속 전)';

  /// 🆕 귀속 못 하는 전략.
  static String unknownStrategy(String id) => '$id 전략 기록(슬리브 귀속 불가)';

  /// 🆕 보유 재구성 음수.
  static String holdingMismatch(String day) => '${dayText(day)} 보유 수량 재구성 불일치';

  /// 기간 이름 — 1일부터 같은 달 = «2026년 8월» · 그 밖 = 두 날.
  static String period(String from, String to) =>
      from.substring(0, 7) == to.substring(0, 7) && from.endsWith('-01')
      ? '${int.parse(from.substring(0, 4))}년 ${int.parse(from.substring(5, 7))}월'
      : '$from ~ $to';

  /// 기준.
  static String asOfLabel(String day) => '기여 분해 기준 $day';

  /// «8월 12일».
  static String dayText(String ymd) =>
      '${int.parse(ymd.substring(5, 7))}월 ${int.parse(ymd.substring(8, 10))}일';

  /// 이어진 결측 날 — 같은 날 «8월 12일» · 같은 달 «8월 12~14일» · 달이 다르면 «8월 31일~9월 1일».
  static String dayRun(String a, String b) {
    if (a == b) return dayText(a);
    if (a.substring(0, 7) == b.substring(0, 7)) {
      return '${int.parse(a.substring(5, 7))}월 '
          '${int.parse(a.substring(8, 10))}~${int.parse(b.substring(8, 10))}일';
    }
    return '${dayText(a)}~${dayText(b)}';
  }

  /// 기여 글자 — «+0.42%p» · «−0.23%p» · 0 = «0.00%p».
  static String pct(double c) {
    final double v = c * 100;
    final String s = v.abs().toStringAsFixed(2);
    if (s == '0.00') return '0.00%p';
    return '${v > 0 ? '+' : '−'}$s%p';
  }
}

/// 🔴 기본 구간 — 이번 달(한국) 1일 ~ 오늘 · 이름 = «2026년 11월»(셸이 라우트 인자 없이 넘긴다).
DateRange contributionDefaultRange(DateTime nowUtc) {
  final String today = kstDateText(nowUtc);
  final String first = '${today.substring(0, 8)}01';
  return DateRange(
    from: TradeDate(first),
    to: TradeDate(today),
    presetCode: kContributionDefaultPreset,
    label: ContributionTexts.period(first, today),
    isDefault: true,
  );
}

/// 슬리브 → 그 슬리브의 전략(A = A + POT).
const Map<SleeveId, Set<String>> _sleeveStrategies = <SleeveId, Set<String>>{
  SleeveId.a: <String>{P0sStrategyIds.sleeveA, P0sStrategyIds.pot},
  SleeveId.b: <String>{P0sStrategyIds.sleeveB},
  SleeveId.c: <String>{P0sStrategyIds.sleeveC},
};

SleeveId? _sleeveOf(String strategyId) {
  for (final MapEntry<SleeveId, Set<String>> e in _sleeveStrategies.entries) {
    if (e.value.contains(strategyId)) return e.key;
  }
  return null;
}

/// 🔴 `S7-3b` VM — [equity] = 개시 뒤 마감 평가(날짜 순 · 흐름 포함 · `tierBSeries`) · [holdingsNow] = 지금 KR 보유 ·
/// [fills] = KR 브로커 체결(시작 기준 뒤 집행분이면 충분 — 더 있어도 거른다) · [closes] = 종목 → 날 → 원가 종가 ·
/// [events] = 귀속 규칙 전 원장 사건 · [integrityHidden] = 원장 무결성 점검 중(실패).
ContributionVm contributionVmOf({
  required DateRange range,
  required List<EquityPoint> equity,
  required List<LedgerHolding> holdingsNow,
  required List<ContributionFill> fills,
  required Map<String, Map<String, double>> closes,
  List<ContributionEvent> events = const <ContributionEvent>[],
  required DateTime nowUtc,
  required bool integrityHidden,
  Map<SleeveId, String>? sleeveLabels,
}) {
  if (integrityHidden) {
    throw StateError('기여: 원장 무결성 점검 중에는 보여 주지 않습니다');
  }
  final String from = range.from.yyyyMmDd;
  final String to = range.to.yyyyMmDd;
  if (from.compareTo(to) > 0) {
    throw ArgumentError.value('$from ~ $to', 'range', '시작이 끝보다 뒤다');
  }
  if (equity.isEmpty) {
    throw StateError('기여: 마감 평가액 기록 없음(운용 첫 마감 전)');
  }
  for (int k = 1; k < equity.length; k++) {
    if (equity[k - 1].date.compareTo(equity[k].date) >= 0) {
      throw ArgumentError.value(equity[k].date, 'equity', '날짜 순이 아니다');
    }
  }
  int base = 0;
  int end = -1;
  for (int k = 0; k < equity.length; k++) {
    if (equity[k].date.compareTo(from) < 0) base = k;
    if (equity[k].date.compareTo(to) <= 0) end = k;
  }
  if (end < 0) {
    throw StateError('기여: 구간이 운용 첫 마감 전($from ~ $to)');
  }
  final List<EquityPoint> pts = equity.sublist(base, end + 1);
  final List<String> days = <String>[for (final EquityPoint p in pts) p.date];
  final String first = days.first;
  final String last = days.last;

  // 전 행 사유 — 구간 안 마감 0 · 귀속 못 하는 전략 · 귀속 규칙 전 원장 사건.
  String? allReason;
  if (days.length == 1 && first.compareTo(from) < 0) {
    allReason = ContributionTexts.noCloseYet;
  }
  final List<ContributionFill> after = <ContributionFill>[
    for (final ContributionFill f in fills)
      if (f.tradeDate.compareTo(first) > 0) f,
  ];
  if (allReason == null) {
    final List<String> unknown = <String>{
      for (final LedgerHolding h in holdingsNow)
        if (h.quantity != 0 && _sleeveOf(h.strategyId) == null) h.strategyId,
      for (final ContributionFill f in after)
        if (_sleeveOf(f.strategyId) == null) f.strategyId,
    }.toList()..sort();
    if (unknown.isNotEmpty) {
      allReason = ContributionTexts.unknownStrategy(unknown.first);
    }
  }
  if (allReason == null) {
    final List<ContributionEvent> hit =
        <ContributionEvent>[
          for (final ContributionEvent e in events)
            if (e.date.compareTo(first) > 0 &&
                (e.kind == ContributionEventKind.corporateAction ||
                    e.date.compareTo(last) <= 0))
              e,
        ]..sort(
          (ContributionEvent a, ContributionEvent b) =>
              a.date.compareTo(b.date),
        );
    if (hit.isNotEmpty) {
      allReason = ContributionTexts.event(hit.first.date, hit.first.kind);
    }
  }

  final Map<SleeveId, String> labels =
      sleeveLabels ?? WhatIfConfig.defaults.sleeveLabels;
  final Map<SleeveId, double> value = <SleeveId, double>{};
  final Map<SleeveId, String> reason = <SleeveId, String>{};
  if (allReason != null) {
    for (final SleeveId s in _sleeveStrategies.keys) {
      reason[s] = allReason;
    }
  } else {
    final List<double> idx = twrIndex(pts);
    for (final SleeveId s in _sleeveStrategies.keys) {
      final Set<String> mine = _sleeveStrategies[s]!;
      final List<double> mv = List<double>.filled(days.length, 0);
      final List<int> gaps = <int>[];
      String? mismatch;
      for (int k = 0; k < days.length && mismatch == null; k++) {
        // 그날 보유 = 지금 − 그날 뒤 체결.
        final Map<String, int> q = <String, int>{};
        for (final LedgerHolding h in holdingsNow) {
          if (mine.contains(h.strategyId)) {
            q[h.symbol] = (q[h.symbol] ?? 0) + h.quantity;
          }
        }
        for (final ContributionFill f in after) {
          if (mine.contains(f.strategyId) &&
              f.tradeDate.compareTo(days[k]) > 0) {
            q[f.symbol] = (q[f.symbol] ?? 0) - f.holdingDelta;
          }
        }
        bool gap = false;
        for (final MapEntry<String, int> e in q.entries) {
          if (e.value < 0) {
            mismatch = days[k];
            break;
          }
          if (e.value == 0) continue;
          final double? c = closes[e.key]?[days[k]];
          if (c == null) {
            gap = true;
          } else {
            mv[k] += e.value * c;
          }
        }
        if (gap) gaps.add(k);
      }
      if (mismatch != null) {
        reason[s] = ContributionTexts.holdingMismatch(mismatch);
        continue;
      }
      if (gaps.isNotEmpty) {
        reason[s] = ContributionTexts.priceGap(_gapText(days, gaps));
        continue;
      }
      double c = 0;
      for (int k = 1; k < days.length; k++) {
        final double prev = pts[k - 1].equity;
        if (prev <= 0) continue;
        double cash = 0;
        for (final ContributionFill f in after) {
          if (mine.contains(f.strategyId) &&
              f.tradeDate.compareTo(days[k - 1]) > 0 &&
              f.tradeDate.compareTo(days[k]) <= 0) {
            cash += f.cash;
          }
        }
        c += idx[k - 1] * (mv[k] - mv[k - 1] + cash) / prev;
      }
      value[s] = c;
    }
  }

  double peak = 0;
  for (final double v in value.values) {
    if (v.abs() > peak) peak = v.abs();
  }
  final List<ContributionRow> rows = <ContributionRow>[
    for (final SleeveId s in _sleeveStrategies.keys)
      if (reason[s] case final String why)
        ContributionRow(
          sleeve: s,
          label: labels[s] ?? s.wire,
          contributionText: ContributionTexts.unavailableValue,
          normalized: 0,
          unavailableLabel: ContributionTexts.unavailable(why),
        )
      else
        ContributionRow(
          sleeve: s,
          label: labels[s] ?? s.wire,
          contributionText: ContributionTexts.pct(value[s]!),
          normalized: peak == 0
              ? 0
              : ((value[s]!.abs() / peak) * 100).round() / 100,
        ),
  ];
  return ContributionVm(
    periodLabel: ContributionTexts.period(from, to),
    rows: rows,
    methodNoteText: reason.isEmpty
        ? ContributionTexts.methodFull
        : ContributionTexts.methodPartial,
    fxNoteText: ContributionTexts.fxNote,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(last),
      source: AsOfSource.localSqlite,
      staleAfter: kContributionStaleAfter,
      label: ContributionTexts.asOfLabel(last),
    ),
  );
}

/// 결측 점(차례 번호) → «8월 12~14일» · 둘 이상 이어짐이면 «첫 이어짐 외 n일».
String _gapText(List<String> days, List<int> gaps) {
  int j = 0;
  while (j + 1 < gaps.length && gaps[j + 1] == gaps[j] + 1) {
    j++;
  }
  final String run = ContributionTexts.dayRun(days[gaps.first], days[gaps[j]]);
  final int rest = gaps.length - (j + 1);
  return rest > 0 ? '$run 외 $rest일' : run;
}
