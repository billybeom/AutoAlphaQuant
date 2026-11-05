// 일일 평가 스냅숏 계산 — 평가 · HWM · 드로다운 · 브레이커 레벨(설계 13 §8 R47 F6~F8 · 02 `equity_snapshot` · 04 §2).
//
// 🔴 순수 계산이다(저장 · 조회 0) — 쓰는 곳 = data_sync `EquitySnapshotJob`.
// 🔴 현금은 D+2 정산 예수금을 받는다(R47 F6 · 실험 278 판 4) — 매수 당일 D+0 예수금은 줄지 않아 보유와 함께 더하면
//    매수액만큼 이중 계상된다. 이 파일은 받은 값을 더할 뿐이고, 어느 칸을 넘길지는 부르는 쪽(브로커 포트 `orderableCashKrw`)이다.
// 🔴 HWM = max(앞 HWM, 오늘 평가) · 드로다운 = 평가 ÷ HWM − 1 — 참조 엔진 `_updateBreaker` 와 같다(입금 보정 없음 🟡 · F7).
// 🔴 브레이커 레벨 = 저장된 역사를 [stepBreaker] 로 처음부터 재생(F8) — 상태(유지 봉 수 · 자격 이벤트)를 따로 두지 않는다.
// 🆕 E13d1 — 사람의 STOPPED 재개(결정 B · `breaker_release`)만 재생 입력으로 넣는다(SPEC v2.40 04 §2 · R60 B3 · D17):
//    그날 걸음 **뒤** STOPPED 면 HALTED(유지 봉 0) · STOPPED 아닌 날의 재개 행 = 무시(한 에피소드에 한 번).

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
    this.release = false,
  });

  /// 그날 드로다운(≤ 0).
  final double drawdown;

  /// 그날 방향 점수(없으면 null).
  final double? directionScore;

  /// 그날 방향 상태가 BULL 인가.
  final bool bull;

  /// 🆕 E13d1 — 이 날 사람의 STOPPED 재개(결정 B `breaker_release`)가 있나.
  final bool release;
}

/// 재생 결과(🆕 E13d1 — M5-7 게이지 원천 · R60 B4).
class BreakerReplay {
  /// 결과를 만든다.
  const BreakerReplay(
    this.state, {
    required this.releaseEligibleToday,
    this.bullStreak = 0,
    this.lastDrawdown = 0,
    this.stoppedEnteredToday = false,
  });

  /// 마지막 날 뒤 상태.
  final BreakerState state;

  /// 마지막 날에 STOPPED 재개 자격 이벤트가 났나(에피소드당 1회 — P1 신호 · 레벨 불변).
  final bool releaseEligibleToday;

  /// 마지막 날까지 이어진 BULL 일 수.
  final int bullStreak;

  /// 마지막 날 드로다운.
  final double lastDrawdown;

  /// 마지막 날에 STOPPED 로 들어섰나(SEV1 · P0 신호).
  final bool stoppedEnteredToday;

  /// 레벨이 바뀐 뒤 지난 봉 수(유지 봉 · 20거래일 판정).
  int get heldBars => state.barsSinceChange;

  /// 🔴 이번 STOPPED 에피소드 동안 재개 자격이 한 번이라도 났나(지속 값 — 결정 화면의 자격).
  bool get stoppedReleaseEligible =>
      state.level == BreakerLevel.stopped && state.releaseEligibilitySent;
}

/// [days] 를 처음부터 재생한다(NORMAL · 0 에서 시작 · bull 연속 = 그날까지 이어진 BULL 일 수).
BreakerReplay replayBreaker(List<BreakerDay> days, BreakerConfig config) {
  BreakerState s = const BreakerState(
    level: BreakerLevel.normal,
    barsSinceChange: 0,
  );
  int bull = 0;
  bool eligible = false;
  bool entered = false;
  double dd = 0;
  for (final BreakerDay d in days) {
    bull = d.bull ? bull + 1 : 0;
    dd = d.drawdown;
    final BreakerLevel before = s.level;
    final BreakerStep step = stepBreaker(
      s,
      drawdown: d.drawdown,
      directionScore: d.directionScore,
      bullStreak: bull,
      config: config,
    );
    s = step.state;
    eligible = step.releaseEligible;
    entered = before != BreakerLevel.stopped && s.level == BreakerLevel.stopped;
    // 🆕 E13d1 — 사람의 재개는 그날 걸음 뒤(GV-31 s_h5_1 하네스와 같은 차례).
    if (d.release && s.level == BreakerLevel.stopped) {
      s = releaseStoppedToHalted(s);
    }
  }
  return BreakerReplay(
    s,
    releaseEligibleToday: eligible,
    bullStreak: bull,
    lastDrawdown: dd,
    stoppedEnteredToday: entered,
  );
}

/// 🆕 E13d1 제안 알림(계약 = E13i1 · R60 B6) — STOPPED 진입(P0).
const String kBreakerStoppedAlertCode = 'BREAKER_STOPPED';

/// 🆕 E13d1 제안 알림 — STOPPED 재개 자격(P1 · v2.29).
const String kStoppedReleaseEligibleAlertCode = 'STOPPED_RELEASE_ELIGIBLE';

/// STOPPED SEV1 postmortem 기한(03_운영 §6-4b ① · 카드 ⑤ · R60 B5).
const Duration kStoppedPostmortemDue = Duration(days: 3);

/// STOPPED 진입 SEV1 한 건(`incidents` 꼴 · 🔴 금액 0).
class StoppedIncident {
  /// 건을 만든다.
  const StoppedIncident({
    required this.incidentId,
    required this.description,
    required this.occurredAtUtc,
    required this.dueAtUtc,
  });

  /// `SEV1-BREAKER_STOPPED-{그날}` — 같은 날 다시 돌려도 같은 건.
  final String incidentId;

  /// 설명(날 · 낙폭 % · 절차).
  final String description;

  /// 연 시각 · postmortem 기한.
  final DateTime occurredAtUtc, dueAtUtc;

  /// 심각도.
  String get severity => 'SEV1';

  /// 분류.
  String get category => kBreakerStoppedAlertCode;
}

/// STOPPED 진입 날 SEV1 의 id(🆕 E13d2 — 결정이 이 에피소드의 건을 찾는다 · R61 T2).
String stoppedIncidentIdOf(String entryTradeDate) =>
    'SEV1-$kBreakerStoppedAlertCode-$entryTradeDate';

/// STOPPED 진입 날의 SEV1(R60 B5).
StoppedIncident stoppedIncidentOf({
  required String tradeDate,
  required double drawdown,
  required DateTime nowUtc,
}) => StoppedIncident(
  incidentId: stoppedIncidentIdOf(tradeDate),
  description:
      '$tradeDate 드로다운 ${(drawdown * 100).toStringAsFixed(2)}% — STOPPED 진입 · 신규 주문 전면 중단 · '
      '03_운영 §6-4b(postmortem 3일 · 최소 20거래일 대기 · 결정 A/B/C)',
  occurredAtUtc: nowUtc.toUtc(),
  dueAtUtc: nowUtc.toUtc().add(kStoppedPostmortemDue),
);

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
  const EquitySnapshotStep(
    this.row, {
    required this.releaseEligibleToday,
    this.replay,
  });

  /// 오늘 행.
  final EquitySnapshotRow row;

  /// 오늘 STOPPED 재개 자격 이벤트가 났나.
  final bool releaseEligibleToday;

  /// 🆕 E13d1 — 재생 결과(게이지 원천 · STOPPED 진입 판정).
  final BreakerReplay? replay;
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
  List<String> releaseDates = const <String>[],
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
  final BreakerReplay b = replayBreaker(
    _breakerDays(
      <(String, double)>[
        for (final EquitySnapshotRow r in history) (r.tradeDate, r.drawdown),
        (tradeDate, dd),
      ],
      regimeOf,
      releaseDates,
    ),
    config ?? p0sBreakerConfig(),
  );
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
    replay: b,
  );
}

/// 🆕 E13d2 — 저장된 역사를 **지금** 다시 재생한다(R61 T1 · 상태를 따로 두지 않는 F8 그대로) — [rows] = 날짜 순.
BreakerReplay replayStoredBreaker(
  List<EquitySnapshotRow> rows,
  (double?, bool) Function(String tradeDate) regimeOf, {
  List<String> releaseDates = const <String>[],
  BreakerConfig? config,
}) => replayBreaker(
  _breakerDays(
    <(String, double)>[
      for (final EquitySnapshotRow r in rows) (r.tradeDate, r.drawdown),
    ],
    regimeOf,
    releaseDates,
  ),
  config ?? p0sBreakerConfig(),
);

/// (날 · 낙폭) → 재생 입력 — 재개 행마다 그 날짜 **이상**인 첫 재생 날(R60 B3).
List<BreakerDay> _breakerDays(
  List<(String, double)> dayDd,
  (double?, bool) Function(String tradeDate) regimeOf,
  List<String> releaseDates,
) {
  final List<String> dates = <String>[for (final (String d, _) in dayDd) d];
  final Set<int> releaseAt = <int>{
    for (final String r in releaseDates)
      if (_firstOnOrAfter(dates, r) case final int k) k,
  };
  return <BreakerDay>[
    for (final (int k, (String d, double dd)) in dayDd.indexed)
      _day(dd, regimeOf(d), release: releaseAt.contains(k)),
  ];
}

int? _firstOnOrAfter(List<String> dates, String r) {
  for (int k = 0; k < dates.length; k++) {
    if (dates[k].compareTo(r) >= 0) return k;
  }
  return null;
}

BreakerDay _day(double dd, (double?, bool) regime, {bool release = false}) =>
    BreakerDay(
      drawdown: dd,
      directionScore: regime.$1,
      bull: regime.$2,
      release: release,
    );

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
  List<String> releaseDates = const <String>[],
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
    releaseDates: releaseDates,
  );
}
