// 일일 평가 스냅숏 계산 — 평가 · HWM · 드로다운 · 브레이커 레벨(설계 13 §8 R47 F6~F8 · 02 `equity_snapshot` · 04 §2).
//
// 🔴 순수 계산이다(저장 · 조회 0) — 쓰는 곳 = data_sync `EquitySnapshotJob`.
// 🔴 현금은 D+2 정산 예수금을 받는다(R47 F6 · 실험 278 판 4) — 매수 당일 D+0 예수금은 줄지 않아 보유와 함께 더하면
//    매수액만큼 이중 계상된다. 이 파일은 받은 값을 더할 뿐이고, 어느 칸을 넘길지는 부르는 쪽(브로커 포트 `orderableCashKrw`)이다.
// 🔴 HWM = max(앞 HWM, 오늘 평가) · 드로다운 = 평가 ÷ HWM − 1 — 참조 엔진 `_updateBreaker` 와 같다(입금 보정 없음 🟡 · F7).
// 🔴 브레이커 레벨 = 저장된 역사를 [stepBreaker] 로 처음부터 재생(F8) — 상태(유지 봉 수 · 자격 이벤트)를 따로 두지 않는다.
//    사람의 STOPPED 재개(M5-3)는 아직 기록이 없어 재생에 넣지 않는다.

import 'package:decimal/decimal.dart';

import '../orders/order_ports.dart' show OrderBroker;
import '../orders/reconcile.dart' show LedgerHolding;
import '../risk/breaker.dart';

/// P0S 브레이커 설정(04 §2 — 사다리 −15 · −20 · −25 · −35 · 해제 −13 · −12 · −15 · 유지 20 · bull 3 · STOPPED 자격 −25 · 5).
BreakerConfig p0sBreakerConfig() => BreakerConfig(
  alertDd: -0.15,
  reduceDd: -0.20,
  haltDd: -0.25,
  stopDd: -0.35,
  alertReleaseDd: -0.13,
  reduceReleaseDd: -0.12,
  haltReleaseDd: -0.15,
  recoverHoldBars: 20,
  haltReleaseBullStreak: 3,
  stopReleaseDd: -0.25,
  stopReleaseBullStreak: 5,
);

/// 보유 평가액 — 종목별 수량 합 × 종가. 🔴 수량이 0 이 아닌 종목의 종가가 없으면 StateError(지어내지 않는다).
Decimal positionsValueKrw(
  Iterable<LedgerHolding> holdings,
  Map<String, Decimal> closes,
) {
  final Map<String, int> qty = <String, int>{};
  for (final LedgerHolding h in holdings) {
    qty[h.symbol] = (qty[h.symbol] ?? 0) + h.quantity;
  }
  Decimal v = Decimal.zero;
  final List<String> symbols = qty.keys.toList()..sort();
  for (final String s in symbols) {
    final int q = qty[s]!;
    if (q == 0) continue;
    if (q < 0) throw StateError('보유 수량이 음수다: $s');
    final Decimal? px = closes[s];
    if (px == null) throw StateError('종가가 없다: $s');
    v += px * Decimal.fromInt(q);
  }
  return v;
}

/// 브레이커 재생 입력 하루.
class BreakerDay {
  /// 하루를 만든다.
  const BreakerDay({
    required this.drawdown,
    required this.directionScore,
    required this.bull,
  });

  /// 그날 드로다운(≤ 0).
  final double drawdown;

  /// 그날 방향 점수(없으면 null).
  final double? directionScore;

  /// 그날 방향 상태가 BULL 인가.
  final bool bull;
}

/// 재생 결과.
class BreakerReplay {
  /// 결과를 만든다.
  const BreakerReplay(this.state, {required this.releaseEligibleToday});

  /// 마지막 날 뒤 상태.
  final BreakerState state;

  /// 마지막 날에 STOPPED 재개 자격 이벤트가 났나(에피소드당 1회 — P1 신호 · 레벨 불변).
  final bool releaseEligibleToday;
}

/// [days] 를 처음부터 재생한다(NORMAL · 0 에서 시작 · bull 연속 = 그날까지 이어진 BULL 일 수).
BreakerReplay replayBreaker(List<BreakerDay> days, BreakerConfig config) {
  BreakerState s = const BreakerState(
    level: BreakerLevel.normal,
    barsSinceChange: 0,
  );
  int bull = 0;
  bool eligible = false;
  for (final BreakerDay d in days) {
    bull = d.bull ? bull + 1 : 0;
    final BreakerStep step = stepBreaker(
      s,
      drawdown: d.drawdown,
      directionScore: d.directionScore,
      bullStreak: bull,
      config: config,
    );
    s = step.state;
    eligible = step.releaseEligible;
  }
  return BreakerReplay(s, releaseEligibleToday: eligible);
}

/// 하루 평가 행(02 `equity_snapshot` 꼴).
class EquitySnapshotRow {
  /// 행을 만든다.
  const EquitySnapshotRow({
    required this.tradeDate,
    required this.totalEquity,
    required this.cashKrw,
    required this.positionsValue,
    required this.highWaterMark,
    required this.drawdown,
    required this.breakerLevel,
    this.cashUsd = 0,
    this.fxRate,
  });

  /// KR 거래일 `YYYY-MM-DD`.
  final String tradeDate;

  /// 원화 총평가.
  final double totalEquity;

  /// 원화 현금(D+2).
  final double cashKrw;

  /// 달러 현금(P0S = 0).
  final double cashUsd;

  /// USD/KRW(P0S = null).
  final double? fxRate;

  /// 보유 평가액.
  final double positionsValue;

  /// 고점.
  final double highWaterMark;

  /// 드로다운(≤ 0).
  final double drawdown;

  /// 브레이커 레벨.
  final BreakerLevel breakerLevel;

  @override
  bool operator ==(Object other) =>
      other is EquitySnapshotRow &&
      other.tradeDate == tradeDate &&
      other.totalEquity == totalEquity &&
      other.cashKrw == cashKrw &&
      other.cashUsd == cashUsd &&
      other.fxRate == fxRate &&
      other.positionsValue == positionsValue &&
      other.highWaterMark == highWaterMark &&
      other.drawdown == drawdown &&
      other.breakerLevel == breakerLevel;

  @override
  int get hashCode => Object.hash(
    tradeDate,
    totalEquity,
    cashKrw,
    cashUsd,
    fxRate,
    positionsValue,
    highWaterMark,
    drawdown,
    breakerLevel,
  );

  @override
  String toString() =>
      'EquitySnapshotRow($tradeDate · dd ${drawdown.toStringAsFixed(4)} · ${breakerLevel.code})';
}

/// 오늘 행 계산 결과.
class EquitySnapshotStep {
  /// 결과를 만든다.
  const EquitySnapshotStep(this.row, {required this.releaseEligibleToday});

  /// 오늘 행.
  final EquitySnapshotRow row;

  /// 오늘 STOPPED 재개 자격 이벤트가 났나.
  final bool releaseEligibleToday;
}

/// 오늘 행을 만든다(R47 F6~F8).
///
/// [history] = 오늘 **앞** 날들의 저장된 행(날짜 순) · [regimeOf] = 날짜 → (방향 점수 · BULL 인가)(없으면 (null, false)).
/// 🔴 [history] 에 오늘 이후 날짜가 있으면 ArgumentError(같은 날 다시 돌리면 오늘 행은 빼고 넘긴다).
EquitySnapshotStep nextEquitySnapshot({
  required String tradeDate,
  required Decimal positionsValue,
  required Decimal cashKrw,
  required List<EquitySnapshotRow> history,
  required (double?, bool) Function(String tradeDate) regimeOf,
  BreakerConfig? config,
}) {
  for (int k = 0; k < history.length; k++) {
    if (history[k].tradeDate.compareTo(tradeDate) >= 0) {
      throw ArgumentError('history 에 오늘($tradeDate) 이후 행이 있다');
    }
    if (k > 0 &&
        history[k - 1].tradeDate.compareTo(history[k].tradeDate) >= 0) {
      throw ArgumentError('history 가 날짜 순이 아니다');
    }
  }
  if (cashKrw < Decimal.zero) throw ArgumentError('현금이 음수다');
  final double total = (positionsValue + cashKrw).toDouble();
  final double prevHwm = history.isEmpty ? total : history.last.highWaterMark;
  final double hwm = total > prevHwm ? total : prevHwm;
  final double dd = hwm <= 0 ? 0 : total / hwm - 1;
  final List<BreakerDay> days = <BreakerDay>[
    for (final EquitySnapshotRow r in history)
      _day(r.drawdown, regimeOf(r.tradeDate)),
    _day(dd, regimeOf(tradeDate)),
  ];
  final BreakerReplay b = replayBreaker(days, config ?? p0sBreakerConfig());
  return EquitySnapshotStep(
    EquitySnapshotRow(
      tradeDate: tradeDate,
      totalEquity: total,
      cashKrw: cashKrw.toDouble(),
      positionsValue: positionsValue.toDouble(),
      highWaterMark: hwm,
      drawdown: dd,
      breakerLevel: b.state.level,
    ),
    releaseEligibleToday: b.releaseEligibleToday,
  );
}

BreakerDay _day(double dd, (double?, bool) regime) =>
    BreakerDay(drawdown: dd, directionScore: regime.$1, bull: regime.$2);

/// 평가 실패 — 🔴 쓰지 않는다(소급 불가 행을 틀린 값으로 남기지 않는다 · R47 F6). 사유 = 종목 · 계좌 별칭만(금액 0).
class EquitySnapshotError implements Exception {
  /// 실패를 만든다.
  const EquitySnapshotError(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'EquitySnapshotError($reason)';
}

/// 보유 · 종가 글자 · 계좌 현금으로 오늘 행을 만든다(R47 F6~F8).
///
/// [closeTexts] = 종목 → 원가 종가(저장소 값의 글자) · [cashAccounts] = 계좌 별칭 → 브로커(🔴 `orderableCashKrw` = D+2).
/// 수량이 0 이 아닌 종목의 종가가 없거나 0 이하 · 현금 조회 실패 = [EquitySnapshotError].
Future<EquitySnapshotStep> computeEquitySnapshot({
  required String tradeDate,
  required List<LedgerHolding> holdings,
  required Map<String, String> closeTexts,
  required Map<String, OrderBroker> cashAccounts,
  required List<EquitySnapshotRow> history,
  required (double?, bool) Function(String tradeDate) regimeOf,
  BreakerConfig? config,
}) async {
  if (cashAccounts.isEmpty) throw ArgumentError('현금 계좌가 없다');
  final Map<String, int> qty = <String, int>{};
  for (final LedgerHolding h in holdings) {
    qty[h.symbol] = (qty[h.symbol] ?? 0) + h.quantity;
  }
  final Map<String, Decimal> closes = <String, Decimal>{};
  final List<String> missing = <String>[];
  for (final String sym in qty.keys.toList()..sort()) {
    if (qty[sym] == 0) continue;
    final Decimal? px = Decimal.tryParse(closeTexts[sym] ?? '');
    if (px == null || px <= Decimal.zero) {
      missing.add(sym);
    } else {
      closes[sym] = px;
    }
  }
  if (missing.isNotEmpty) {
    throw EquitySnapshotError('종가 없음: ${missing.join(',')}');
  }
  Decimal cash = Decimal.zero;
  for (final String a in cashAccounts.keys.toList()..sort()) {
    try {
      cash += await cashAccounts[a]!.orderableCashKrw();
    } on Object {
      throw EquitySnapshotError('현금 조회 실패: $a');
    }
  }
  return nextEquitySnapshot(
    tradeDate: tradeDate,
    positionsValue: positionsValueKrw(holdings, closes),
    cashKrw: cash,
    history: history,
    regimeOf: regimeOf,
    config: config,
  );
}
