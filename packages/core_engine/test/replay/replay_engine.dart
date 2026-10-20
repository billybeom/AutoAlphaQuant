// E6c 재현 장부 — 참조 엔진(백테스트6 `engine/backtest.py`)의 P0S 일별 루프를 같은 연산 순서의 double 로 옮긴다.
//
// 🔴 정본은 참조 엔진 코드다(이식 지도 §3·§4). 수량·현금 갱신식, 원장 비용 «보고» 식, 1원 문턱, 같은 날 주문의
//    쌓인 순서(매도 먼저로 정렬하지 않는다)를 그대로 둔다 — 골든(원장 934행 · 비용 24,289,863원)이 그 동작의 실측이다.
// 🔴 앱(lib)의 Decimal 함수는 쓰지 않는다 — 재현은 파이썬 float 연산 순서가 기준이다(지도 §9 권고).
//    규칙 판정(B 트랜치 하한·BEAR 차감)은 lib 와 같은 식이지만 평균은 numpy 짝 합산이라 여기서 따로 계산한다.
// 🔵 이식 범위: 보유비용 · 평가 · 브레이커 · 체결(B·C) · 램프 · 코어 밴드 · B 트랜치 · C 리밸런싱 · 스냅숏(E6c) ·
//    계절 A(F1 진입 게이트 · 마지막 3세션 3분할 · 이월 · 마지막 날 잔량 집행) · POT 서브북 · 원화 조달(E6d).
// 🔴 원화 조달(`_take_krw` → `_raise_krw`)은 C 방어자산을 **필요한 만큼** 판다 — 잉여 상한 없음(설계 13 §8 R17 ① 결정).

import 'replay_market.dart';
import 'replay_regime.dart';

/// 참조 엔진 `Config(preset="P0S")` + `ramp_months = 6` 의 값(config.py · P0_PIECES · P0S_PIECES).
abstract final class P0sConfig {
  static const String start = '2000-01-03';
  static const String end = '2026-08-14';
  static const double initialCapital = 100000000.0;
  static const int rampMonths = 6;
  static const double allocA = 0.20;
  static const double allocB = 0.42;
  static const double allocSat = 0.0;
  static const List<(String, double, double)> bAssets =
      <(String, double, double)>[
        ('133690', 0.8, 0.00138),
        ('411060', 0.2, 0.00460),
      ];
  static const List<int> lookbacks = <int>[8, 10, 12];
  static const double parkingEr = 0.00115;
  static const String bAssistCutState = 'BEAR';
  static const double cIeiW = 0.65;
  static const double cIauW = 0.35;
  static const double maxGoldPctOfTotal = 0.08;
  static const double ieiEr = 0.0015;
  static const double iauEr = 0.0025;
  static const double aEtfEr = 0.0045;
  static const double krCommission = 0.00015;
  static const double krSlipEtf = 0.0010;
  static const double krTaxSellEtf = 0.0;
  static const double usCommission = 0.00025;
  static const double usSlippage = 0.0010;
  static const double fxSpreadRoundtrip = 0.0015;
  static const double erMarkup = 1.15;
  static const int tradingDaysPerYear = 252;
  static const double pensionAnnualLimit = 18000000.0;
  static const double coreBand = 0.03;
  // 계절(config.py Seasonality · P0_PIECES)
  static const int entryMonth = 10;
  static const int exitMonth = 4;
  static const int f1EntryDeferMax = 2;
  static const double aEtfSlip = 0.0010;
  static const double satBandHi = 21.0 / 18.0;
  // 브레이커(config.py Breaker)
  static const double ddAlert = -0.15;
  static const double ddReduce = -0.20;
  static const double ddHalt = -0.25;
  static const double ddStop = -0.35;
  static const int recoverHoldBars = 20;
  static const double alertReleaseDd = -0.13;
  static const double reduceReleaseDd = -0.12;
  static const double haltReleaseDd = -0.15;
  static const int haltReleaseBullStreak = 3;
}

/// 골든 생성기(`exp/N2_golden_p0s.py`)의 실행 변형 — 바뀌는 설정만.
class ReplayVariant {
  const ReplayVariant({
    required this.name,
    required this.bSmaFloor,
    required this.assistCut,
    required this.assistDelay,
    required this.f1EntryGateScore,
    required this.pensionFunding,
  });

  /// 이름(정답지 키).
  final String name;

  /// B 트랜치 상시 하한(`b_sma_floor`).
  final double bSmaFloor;

  /// BEAR 차감량 — null = assist 없음(`b_sma_regime_assist = None`).
  final double? assistCut;

  /// assist 지연(직전 월말 상태로 판정).
  final int assistDelay;

  /// F1 진입 게이트 점수(0 = 게이트 없음).
  final double f1EntryGateScore;

  /// v2.32 연금 납입 조달 경로.
  final bool pensionFunding;

  /// S7 = P0S 정본(v2.32).
  static const ReplayVariant s7 = ReplayVariant(
    name: 'S7_P0S',
    bSmaFloor: 1.0 / 3,
    assistCut: 2.0 / 3,
    assistDelay: 0,
    f1EntryGateScore: 60.0,
    pensionFunding: true,
  );

  /// S6 = 흡수처 조각(연금 조달)만 끈 것 — S7 과 같아야 한다.
  static const ReplayVariant s6 = ReplayVariant(
    name: 'S6_P0S_residual',
    bSmaFloor: 1.0 / 3,
    assistCut: 2.0 / 3,
    assistDelay: 0,
    f1EntryGateScore: 60.0,
    pensionFunding: false,
  );

  /// delay1 — BEAR 차감을 직전 KR 월말 상태로.
  static const ReplayVariant delay1 = ReplayVariant(
    name: 'delay1',
    bSmaFloor: 1.0 / 3,
    assistCut: 2.0 / 3,
    assistDelay: 1,
    f1EntryGateScore: 60.0,
    pensionFunding: true,
  );

  /// nogate — 진입 게이트 제거.
  static const ReplayVariant nogate = ReplayVariant(
    name: 'nogate',
    bSmaFloor: 1.0 / 3,
    assistCut: 2.0 / 3,
    assistDelay: 0,
    f1EntryGateScore: 0.0,
    pensionFunding: true,
  );

  /// nocut — 하한·BEAR 차감 모두 제거(순수 3-트랜치).
  static const ReplayVariant nocut = ReplayVariant(
    name: 'nocut',
    bSmaFloor: 0.0,
    assistCut: null,
    assistDelay: 0,
    f1EntryGateScore: 60.0,
    pensionFunding: true,
  );
}

/// 원장 한 행(`_rec`).
class LedgerRow {
  LedgerRow(
    this.date,
    this.sleeve,
    this.symbol,
    this.side,
    this.qty,
    this.price,
    this.gross,
    this.cost,
    this.event,
    this.dirState,
    this.breaker,
  );
  final String date, sleeve, symbol, side, event, dirState, breaker;
  final double qty, price, gross, cost;
}

/// 일별 기록 한 행(`_snapshot` 중 대조하는 열 + N2 골든 생성기가 더하는 금 평가액 `gold_b` · `gold_pot`).
class DailyRow {
  DailyRow(this.date, this.values, this.breaker, this.dirState);
  final String date;
  final Map<String, double> values;
  final String breaker, dirState;
}

class _Order {
  _Order(this.sleeve, this.symbol, this.side, this.amount, this.event);
  final String sleeve, symbol, side, event;
  final double amount;
}

class _Plan {
  _Plan(this.side, this.amount, this.event, this.carryTo);
  final String side, event;
  final double amount;
  final String? carryTo;
}

const Map<String, int> _levelOrder = <String, int>{
  'NORMAL': 0,
  'ALERT': 1,
  'REDUCED': 2,
  'HALTED': 3,
  'STOPPED': 4,
};

/// numpy 짝 합산(`pairwise_sum`) — n < 8 은 0 부터 차례로 · n ≤ 128 은 누산기 8개 · 그보다 크면 반으로 나눠 재귀
/// (반 = n/2 를 8 의 배수로 내림). `np.mean` · pandas `Series.sum`(bottleneck 없음)이 이 값이다.
double npSum(List<double> a, [int start = 0, int? end]) {
  final int stop = end ?? a.length;
  final int n = stop - start;
  if (n < 8) {
    double res = 0.0;
    for (int i = start; i < stop; i++) {
      res += a[i];
    }
    return res;
  }
  if (n <= 128) {
    final List<double> r = a.sublist(start, start + 8);
    int i = 8;
    for (; i < n - (n % 8); i += 8) {
      for (int j = 0; j < 8; j++) {
        r[j] += a[start + i + j];
      }
    }
    double res =
        ((r[0] + r[1]) + (r[2] + r[3])) + ((r[4] + r[5]) + (r[6] + r[7]));
    for (; i < n; i++) {
      res += a[start + i];
    }
    return res;
  }
  int n2 = n ~/ 2;
  n2 -= n2 % 8;
  return npSum(a, start, start + n2) + npSum(a, start + n2, stop);
}

/// numpy `np.mean` = [npSum] ÷ n. 20만 배열로 비트 일치 확인(2026-10-21).
double npMean(List<double> a) => npSum(a) / a.length;

/// 참조 엔진 P0S 일별 루프.
class ReplayEngine {
  ReplayEngine(this.m, ReplayRegime regime, {this.variant = ReplayVariant.s7}) {
    final DatedSeries code = DatedSeries(regime.calendar, <double>[
      for (int i = 0; i < regime.fsm.length; i++) i.toDouble(),
    ]);
    final DatedSeries score = DatedSeries(regime.calendar, <double>[
      for (final d in regime.direction) d.direction ?? double.nan,
    ]).dropNa();
    for (final String d in m.allDays) {
      final int p = code.lastAtOrBefore(d);
      _regState.add(p < 0 ? 'UNKNOWN' : regime.fsm[p].directionState.code);
      final int q = score.lastAtOrBefore(d);
      _regScore.add(q < 0 ? double.nan : score.values[q]);
    }
    final DatedSeries tk = DatedSeries(regime.kosdaqCalendar, <double>[
      for (final double? x in regime.tskr) x ?? double.nan,
    ]).dropNa();
    for (final String d in m.allDays) {
      final int q = tk.lastAtOrBefore(d);
      _tskr.add(q < 0 ? double.nan : tk.values[q]);
    }
    _krSet = m.kr.toSet();
    _usSet = m.us.toSet();
    for (int i = 0; i < m.allDays.length; i++) {
      _dayPos[m.allDays[i]] = i;
    }
  }

  final ReplayMarket m;

  /// 실행 변형(S7 정본 · S6 · 스트레스 3종).
  final ReplayVariant variant;
  (double, String)? _bAssistPrev;
  final List<String> _regState = <String>[];
  final List<double> _regScore = <double>[];
  late final Set<String> _krSet, _usSet;
  final Map<String, int> _dayPos = <String, int>{};

  final List<LedgerRow> ledger = <LedgerRow>[];
  final List<DailyRow> daily = <DailyRow>[];

  // 상태(`run` 머리)
  double aUnits = 0.0;
  final Map<String, double> bUnits = <String, double>{
    for (final (String t, double _, double _) in P0sConfig.bAssets) t: 0.0,
  };
  double bParkUnits = 0.0;
  double bParkCUnits = 0.0;
  double cKrwUnits = 0.0;
  double cIeiUnits = 0.0;
  double cIauUnits = 0.0;
  double cReservedKrw = 0.0;
  double potCashUnits = 0.0;
  final Map<String, double> potBUnits = <String, double>{
    for (final (String t, double _, double _) in P0sConfig.bAssets) t: 0.0,
  };
  final Map<String, List<_Order>> _pending = <String, List<_Order>>{};
  String level = 'NORMAL';
  String? levelSince;
  double? hwm;
  int bullStreak = 0;
  int monthCount = 0;
  double dd = 0.0;
  double? prevEq;
  final Map<int, double> pensionUsed = <int, double>{};
  int f1WaitEntry = 0;
  final Map<String, List<_Plan>> _seasonalPlan = <String, List<_Plan>>{};
  final List<double> _tskr = <double>[];

  double _p(int i, String key) => m.px[key]!.values[i];
  bool _fin(double x) => !x.isNaN && x.isFinite;

  /// 참조 엔진 `run` — [until] 이후 날은 돌지 않는다(그날 포함해 돈다).
  void run({String? until}) {
    cKrwUnits = P0sConfig.initialCapital / _p(0, 'CKRW');
    for (int i = 0; i < m.allDays.length; i++) {
      final String d = m.allDays[i];
      if (until != null && d.compareTo(until) > 0) break;
      _holdingCost(i, d);
      final String state = _regState[i];
      final double eq = _equity(i);
      if (!_fin(eq) || eq <= 0) continue;
      _updateBreaker(
        i,
        d,
        (prevEq != null && prevEq != 0.0) ? prevEq! : eq,
        state,
      );
      final List<_Order>? orders = _pending.remove(d);
      if (orders != null) {
        for (final _Order o in orders) {
          _execute(i, d, o, state);
        }
      }
      if (_krSet.contains(d)) {
        _seasonal(i, d, state);
      }
      if (m.krMonthEnds.contains(d)) _krMonthEnd(i, d, state);
      prevEq = _snapshot(i, d, state);
    }
  }

  // ── 회계 ──────────────────────────────────────────────────────────────
  void _holdingCost(int i, String d) {
    const double mk = P0sConfig.erMarkup;
    const int dpy = P0sConfig.tradingDaysPerYear;
    if (_krSet.contains(d)) {
      for (final (String t, double _, double er) in P0sConfig.bAssets) {
        bUnits[t] = bUnits[t]! * (1.0 - er * mk / dpy);
      }
      bParkUnits *= 1.0 - P0sConfig.parkingEr * mk / dpy;
      bParkCUnits *= 1.0 - P0sConfig.parkingEr * mk / dpy;
      aUnits *= 1.0 - P0sConfig.aEtfEr * mk / dpy;
    }
    if (_usSet.contains(d)) {
      cIeiUnits *= 1.0 - P0sConfig.ieiEr * mk / dpy;
      cIauUnits *= 1.0 - P0sConfig.iauEr * mk / dpy;
    }
  }

  double _potValue(int i) {
    double v = potCashUnits * _p(i, 'CKRW');
    for (final (String t, double _, double _) in P0sConfig.bAssets) {
      final double px = _p(i, t);
      if (_fin(px)) v += potBUnits[t]! * px;
    }
    return v;
  }

  /// `_values` — (A, B, C, SAT).
  (double, double, double, double) _values(int i) {
    final double fx = _p(i, 'fx');
    final double a = aUnits * _p(i, 'A');
    double b = bParkUnits * _p(i, 'PARK');
    for (final (String t, double _, double _) in P0sConfig.bAssets) {
      final double px = _p(i, t);
      if (_fin(px)) b += bUnits[t]! * px;
    }
    final double ck = cKrwUnits * _p(i, 'CKRW') + bParkCUnits * _p(i, 'PARK');
    final double iauPx = _p(i, 'IAU');
    final double cu =
        (cIeiUnits * _p(i, 'IEI') + (_fin(iauPx) ? cIauUnits * iauPx : 0.0)) *
        fx;
    return (a, b, ck + cu + _potValue(i), 0.0);
  }

  double _equity(int i) {
    final (double a, double b, double c, double s) = _values(i);
    return a + b + c + s;
  }

  // ── 서킷브레이커 ─────────────────────────────────────────────────────
  void _updateBreaker(int i, String d, double eq, String state) {
    hwm = hwm == null ? eq : (hwm! > eq ? hwm : eq);
    final double ddNow = eq / hwm! - 1.0;
    dd = ddNow;
    bullStreak = state == 'BULL' ? bullStreak + 1 : 0;
    final String? next = ddNow <= P0sConfig.ddStop
        ? 'STOPPED'
        : ddNow <= P0sConfig.ddHalt
        ? 'HALTED'
        : ddNow <= P0sConfig.ddReduce
        ? 'REDUCED'
        : ddNow <= P0sConfig.ddAlert
        ? 'ALERT'
        : null;
    if (next != null && _levelOrder[next]! > _levelOrder[level]!) {
      level = next;
      levelSince = d;
    } else if (level == 'STOPPED') {
      // 자격 이벤트만(stopped_release_enabled = False) — 레벨 효력 없음.
    } else if (level != 'NORMAL') {
      final int held = i - (_dayPos[levelSince] ?? i);
      if (held >= P0sConfig.recoverHoldBars) {
        if (level == 'HALTED' &&
            ddNow >= P0sConfig.haltReleaseDd &&
            bullStreak >= P0sConfig.haltReleaseBullStreak) {
          level = 'REDUCED';
          levelSince = d;
        } else if (level == 'REDUCED' &&
            ddNow >= P0sConfig.reduceReleaseDd &&
            _fin(_regScore[i]) &&
            _regScore[i] >= 50) {
          level = 'ALERT';
          levelSince = d;
        } else if (level == 'ALERT' && ddNow > P0sConfig.alertReleaseDd) {
          level = 'NORMAL';
          levelSince = d;
        }
      }
    }
  }

  void _rec(
    String d,
    String sleeve,
    String sym,
    String side,
    double qty,
    double price,
    double gross,
    double cost,
    String event,
    String state,
  ) => ledger.add(
    LedgerRow(
      d,
      sleeve,
      sym,
      side,
      qty,
      price,
      gross,
      cost,
      event,
      state,
      level,
    ),
  );

  // ── 체결 ──────────────────────────────────────────────────────────────
  void _execute(int i, String d, _Order o, String state) {
    if (o.sleeve == 'B') {
      _execB(i, d, o, state);
    } else if (o.sleeve == 'C') {
      _execC(i, d, o, state);
    }
  }

  void _execB(int i, String d, _Order o, String state) {
    const double slip = P0sConfig.krSlipEtf;
    const double comm = P0sConfig.krCommission;
    final double px = _p(i, o.symbol);
    if (!_fin(px) || px <= 0 || o.amount <= 0) return;
    double val = o.amount;
    if (o.side == 'BUY') {
      final double cash = bParkUnits * _p(i, 'PARK');
      final double cap = cash / (1 + comm);
      val = val < (cap > 0.0 ? cap : 0.0) ? val : (cap > 0.0 ? cap : 0.0);
      if (val <= 1.0) return;
      bUnits[o.symbol] = bUnits[o.symbol]! + val / (px * (1 + slip));
      bParkUnits -= (val * (1 + comm)) / _p(i, 'PARK');
    } else {
      final double cur = bUnits[o.symbol]! * px;
      val = val < cur ? val : cur;
      if (val <= 1.0) return;
      final double cost = val * (comm + slip + P0sConfig.krTaxSellEtf);
      bUnits[o.symbol] = bUnits[o.symbol]! - val / px;
      bParkUnits += (val - cost) / _p(i, 'PARK');
    }
    final double cost =
        val * (comm + slip + (o.side == 'SELL' ? P0sConfig.krTaxSellEtf : 0.0));
    _rec(d, 'B', o.symbol, o.side, val / px, px, val, cost, o.event, state);
  }

  void _execC(int i, String d, _Order o, String state) {
    final double fx = _p(i, 'fx');
    const double fxs = P0sConfig.fxSpreadRoundtrip / 2.0;
    final double px = o.symbol == 'IEI' ? _p(i, 'IEI') : _p(i, 'IAU');
    if (!_fin(px) || px <= 0 || o.amount <= 0) return;
    final double pxKrw = px * fx;
    final double curUnits = o.symbol == 'IEI' ? cIeiUnits : cIauUnits;
    final double val;
    final double cost;
    if (o.side == 'BUY') {
      final double cash = cKrwUnits * _p(i, 'CKRW') - cReservedKrw;
      final double capRaw = cash / (1 + P0sConfig.usCommission + fxs);
      final double cap = capRaw > 0.0 ? capRaw : 0.0;
      val = o.amount < cap ? o.amount : cap;
      if (val <= 1.0) return;
      cost = val * (P0sConfig.usCommission + P0sConfig.usSlippage + fxs);
      final double units =
          curUnits + val / (pxKrw * (1 + P0sConfig.usSlippage));
      if (o.symbol == 'IEI') {
        cIeiUnits = units;
      } else {
        cIauUnits = units;
      }
      cKrwUnits -= (val * (1 + P0sConfig.usCommission + fxs)) / _p(i, 'CKRW');
    } else {
      final double cur = curUnits * pxKrw;
      val = o.amount < cur ? o.amount : cur;
      if (val <= 1.0) return;
      cost = val * (P0sConfig.usCommission + P0sConfig.usSlippage + fxs);
      final double units = curUnits - val / pxKrw;
      if (o.symbol == 'IEI') {
        cIeiUnits = units;
      } else {
        cIauUnits = units;
      }
      cKrwUnits += (val - cost) / _p(i, 'CKRW');
    }
    _rec(
      d,
      'C',
      o.symbol,
      o.side,
      val / pxKrw,
      pxKrw,
      val,
      cost,
      o.event,
      state,
    );
  }

  // ── 계절 A(E6d) ────────────────────────────────────────────────────
  void _seasonal(int i, String d, String state) {
    _seasonalCheck(i, d, state);
    _seasonalExecute(i, d, state);
  }

  double _ratioA() {
    final double x = monthCount / P0sConfig.rampMonths;
    final double f = P0sConfig.rampMonths <= 0 ? 1.0 : (x < 1.0 ? x : 1.0);
    return P0sConfig.allocA * f;
  }

  void _seasonalCheck(int i, String d, String state) {
    final (int, int)? tail = m.krTail[d];
    if (tail == null || tail.$1 != 0) return; // 마지막 N 세션의 첫날에만 계획한다
    final int start = m.kr.indexOf(d);
    final int stop = start + tail.$2 > m.kr.length
        ? m.kr.length
        : start + tail.$2;
    final List<String> days = m.kr.sublist(start, stop);
    final int prevI = i > 0 ? i - 1 : 0;
    final double eq = _equity(prevI); // 🔴 현재 수량 × 직전 세션 가격(same-bar 제거)
    final double rA = _ratioA();
    double cur = aUnits * _p(i, 'A');
    final int mo = int.parse(d.substring(5, 7));
    final double sc = _tskr[prevI]; // 🔴 직전 세션 KOSDAQ 추세 점수
    double pendingSell() {
      double sum = 0.0;
      for (final _Plan pl in _seasonalPlan[d] ?? const <_Plan>[]) {
        if (pl.side == 'SELL') sum += pl.amount;
      }
      return sum;
    }

    if (f1WaitEntry > 0 && mo != P0sConfig.entryMonth) {
      if (level == 'HALTED' || level == 'STOPPED') return;
      final bool ok = _fin(sc) && sc >= variant.f1EntryGateScore;
      if (!(ok || f1WaitEntry >= P0sConfig.f1EntryDeferMax)) {
        f1WaitEntry += 1; // 보류(F1_ENTRY_DEFER)
        return;
      }
      f1WaitEntry = 0; // 지연 진입(F1_ENTRY_LATE)
      _potLiquidate(i, d, state);
      cReservedKrw = 0.0;
      final double c0 = cur - pendingSell();
      cur = c0 > 0.0 ? c0 : 0.0;
      final double delta = eq * rA - cur;
      if (delta > eq * 0.001) _split(days, 'BUY', delta, 'SEASONAL_ENTRY');
      return;
    }
    if (mo == P0sConfig.entryMonth) {
      if (variant.f1EntryGateScore > 0 &&
          level != 'HALTED' &&
          level != 'STOPPED' &&
          _fin(sc) &&
          sc < variant.f1EntryGateScore) {
        f1WaitEntry = 1; // 🔴 점수가 NaN 이면 보류하지 않고 진입한다(참조 엔진)
        return;
      }
      _potLiquidate(i, d, state);
      cReservedKrw = 0.0;
      final double c0 = cur - pendingSell();
      cur = c0 > 0.0 ? c0 : 0.0;
      if (level == 'HALTED' || level == 'STOPPED') return;
      final double delta = eq * rA - cur;
      if (delta > eq * 0.001) _split(days, 'BUY', delta, 'SEASONAL_ENTRY');
    } else if (mo == P0sConfig.exitMonth && cur > 0) {
      // v2.19 기본 = 전량(partial.enabled false · GV-38) — 3분할 금액은 첫날 가격 기준 원화로 고정.
      _split(days, 'SELL', cur * 1.0, 'SEASONAL_EXIT');
    }
  }

  /// 마지막 3세션 분할 — 미체결은 다음 날로 이월 · 마지막 날 잔량 전량(§5-3-1).
  void _split(List<String> days, String side, double total, String event) {
    double remain = total;
    for (int k = 0; k < days.length; k++) {
      final int left = days.length - k;
      final double amt = left == 1 ? remain : remain / left;
      final String? nxt = k + 1 < days.length ? days[k + 1] : null;
      _seasonalPlan
          .putIfAbsent(days[k], () => <_Plan>[])
          .add(_Plan(side, amt, event, nxt));
      remain -= amt;
    }
  }

  void _seasonalExecute(int i, String d, String state) {
    final List<_Plan>? plans = _seasonalPlan.remove(d);
    if (plans == null || plans.isEmpty) return;
    const double comm = P0sConfig.krCommission;
    const double slip = P0sConfig.aEtfSlip;
    const double tax = P0sConfig.krTaxSellEtf;
    final double pa = _p(i, 'A');
    final double pc = _p(i, 'CKRW');
    for (final _Plan plan in plans) {
      double amt = plan.amount;
      if (amt <= 0) continue;
      if (plan.side == 'BUY') {
        final double want = amt;
        double cash = cKrwUnits * pc;
        if (want * (1 + comm) > cash && plan.carryTo == null) {
          // 🔴 마지막 날 — 잔량 전량 집행. 재원 = C 방어자산을 필요한 만큼(R17 ①).
          _takeKrw(i, d, want * (1 + comm) - cash, state);
          cash = cKrwUnits * pc;
        }
        final double capRaw = cash / (1 + comm);
        final double cap = capRaw > 0.0 ? capRaw : 0.0;
        amt = want < cap ? want : cap;
        if (amt <= 1.0 && plan.carryTo != null) {
          _seasonalPlan
              .putIfAbsent(plan.carryTo!, () => <_Plan>[])
              .add(_Plan(plan.side, want, plan.event, null));
          continue;
        }
        if (amt <= 1.0) continue;
        if (plan.carryTo != null && want - amt > 1.0) {
          _seasonalPlan
              .putIfAbsent(plan.carryTo!, () => <_Plan>[])
              .add(_Plan(plan.side, want - amt, plan.event, null));
        }
        final double cost = amt * (comm + slip); // 보고용(슬리피지는 체결가에)
        aUnits += amt / (pa * (1 + slip));
        cKrwUnits -= (amt * (1 + comm)) / pc;
        final double res = cReservedKrw - amt * (1 + comm);
        cReservedKrw = res > 0.0 ? res : 0.0;
        _rec(
          d,
          'A',
          'KOSDAQ_PROXY',
          'BUY',
          amt / pa,
          pa,
          amt,
          cost,
          plan.event,
          state,
        );
      } else {
        final double have = aUnits * pa;
        amt = amt < have ? amt : have;
        if (amt <= 1.0) continue;
        final double cost = amt * (comm + tax + slip);
        aUnits -= amt / pa;
        cKrwUnits += (amt - cost) / pc;
        _potDeposit(i, d, amt - cost, state); // POT 입금 행이 A 매도 행보다 먼저
        _rec(
          d,
          'A',
          'KOSDAQ_PROXY',
          'SELL',
          amt / pa,
          pa,
          amt,
          cost,
          plan.event,
          state,
        );
      }
    }
  }

  // ── POT 서브북(E6d) ──────────────────────────────────────────────────
  void _potDeposit(int i, String d, double amt0, String state) {
    if (amt0 <= 1.0) return;
    final double pc = _p(i, 'CKRW');
    final double have = cKrwUnits * pc;
    final double haveCap = have > 0.0 ? have : 0.0;
    final double amt = amt0 < haveCap ? amt0 : haveCap;
    if (amt <= 1.0) return;
    cKrwUnits -= amt / pc;
    potCashUnits += amt / pc;
    _rec(d, 'POT', 'CASH', 'IN', amt, 1.0, amt, 0.0, 'D2_POT_IN', state);
  }

  void _potLiquidate(int i, String d, String state) {
    final double pc = _p(i, 'CKRW');
    double proceeds = potCashUnits * pc;
    potCashUnits = 0.0;
    const double rKr = P0sConfig.krCommission + P0sConfig.krSlipEtf;
    for (final (String t, double _, double _) in P0sConfig.bAssets) {
      final double px = _p(i, t);
      // 🔴 1원 문턱 없음 — 전량 매도 뒤 +ULP 가 남으면 여기서 «먼지 행»이 생긴다(R17 ⑥).
      if (!_fin(px) || potBUnits[t]! <= 0) continue;
      final double v = potBUnits[t]! * px;
      potBUnits[t] = 0.0;
      proceeds += v * (1.0 - rKr);
      _rec(d, 'POT', t, 'SELL', v / px, px, v, v * rKr, 'D2_POT_OUT', state);
    }
    if (proceeds > 0) {
      cKrwUnits += proceeds / pc;
      cReservedKrw += proceeds;
      _rec(
        d,
        'POT',
        'CASH',
        'OUT',
        proceeds,
        1.0,
        proceeds,
        0.0,
        'D2_POT_OUT',
        state,
      );
    }
  }

  void _potRebalance(int i, String d, String state) {
    final double base = _potValue(i);
    if (base <= 1.0) return;
    final double pc = _p(i, 'CKRW');
    const double rKr = P0sConfig.krCommission + P0sConfig.krSlipEtf;
    final String monthKey = d.substring(0, 7);
    for (final (String t, double w, double _) in P0sConfig.bAssets) {
      final double px = _p(i, t);
      if (!_fin(px) || px <= 0) continue;
      final DatedSeries me = m.bMonthly[t]!;
      final List<double> mc = <double>[
        for (int k = 0; k < me.length; k++)
          if (me.dates[k].compareTo(monthKey) <= 0) me.values[k],
      ];
      // 🔵 POT 은 기본 3-트랜치만(하한·BEAR 차감 미적용 — d2_pot_assist 꺼짐).
      double ratio = 0.0;
      if (mc.length >= 12) {
        int held = 0;
        for (final int n in P0sConfig.lookbacks) {
          if (mc.last > npMean(mc.sublist(mc.length - n))) held++;
        }
        ratio = held / P0sConfig.lookbacks.length;
      }
      final double tgt = base * w * ratio;
      final double cur = potBUnits[t]! * px;
      final double delta = tgt - cur;
      if (delta.abs() <= base * 0.005) continue;
      if (delta > 0) {
        final double cash = potCashUnits * pc;
        final double capRaw = cash / (1.0 + rKr);
        final double cap = capRaw > 0.0 ? capRaw : 0.0;
        final double buy = delta < cap ? delta : cap;
        if (buy <= 1.0) continue;
        potBUnits[t] = potBUnits[t]! + buy / px;
        potCashUnits -= buy * (1.0 + rKr) / pc;
        _rec(
          d,
          'POT',
          t,
          'BUY',
          buy / px,
          px,
          buy,
          buy * rKr,
          'D2_POT_SMA',
          state,
        );
      } else {
        final double sell = -delta < cur ? -delta : cur;
        if (sell <= 1.0) continue;
        potBUnits[t] = potBUnits[t]! - sell / px;
        potCashUnits += sell * (1.0 - rKr) / pc;
        _rec(
          d,
          'POT',
          t,
          'SELL',
          sell / px,
          px,
          sell,
          sell * rKr,
          'D2_POT_SMA',
          state,
        );
      }
    }
  }

  // ── 원화 조달(E6d) ────────────────────────────────────────────────────
  double _takeKrw(int i, String d, double need, String state) {
    if (need <= 0) return 0.0;
    // ① 새틀라이트 잉여 — P0S 새틀 0 · 현금 0 → 언제나 0(행 없음).
    return need > 1.0 ? _raiseKrw(i, d, need, state) : 0.0;
  }

  /// 슬리브 C 방어자산(금 → 채권)을 팔아 원화를 채운다 — 🔴 필요한 만큼(잉여 상한 없음 · R17 ①).
  double _raiseKrw(int i, String d, double need0, String state) {
    double need = need0;
    final double fx = _p(i, 'fx');
    final double pc = _p(i, 'CKRW');
    const double fxs = P0sConfig.fxSpreadRoundtrip / 2.0;
    double raised = 0.0;
    for (final String sym in <String>['IAU', 'IEI']) {
      if (need <= 0) return raised;
      final double px = _p(i, sym);
      if (!_fin(px) || px <= 0) continue;
      final double units = sym == 'IAU' ? cIauUnits : cIeiUnits;
      final double val = units * px * fx;
      final double gross =
          need / (1 - P0sConfig.usCommission - P0sConfig.usSlippage - fxs);
      final double take = gross < val ? gross : val;
      if (take <= 1.0) continue;
      final double cost =
          take * (P0sConfig.usCommission + P0sConfig.usSlippage + fxs);
      if (sym == 'IAU') {
        cIauUnits = units - take / (px * fx);
      } else {
        cIeiUnits = units - take / (px * fx);
      }
      cKrwUnits += (take - cost) / pc;
      _rec(
        d,
        'C',
        sym,
        'SELL',
        take / (px * fx),
        px * fx,
        take,
        cost,
        'RAISE_KRW',
        state,
      );
      need -= take - cost;
      raised += take - cost;
    }
    return raised;
  }

  // ── 월말 ──────────────────────────────────────────────────────────────
  void _krMonthEnd(int i, String d, String state) {
    monthCount += 1;
    final double eq = _equity(i);
    final double f = P0sConfig.rampMonths <= 0
        ? 1.0
        : (monthCount / P0sConfig.rampMonths < 1.0
              ? monthCount / P0sConfig.rampMonths
              : 1.0);
    final double rB = P0sConfig.allocB * f;
    _sleeveBTopup(i, d, eq, f, rB, state);
    _coreBand(i, d, eq, f, state);
    _sleeveBSignal(i, d, eq, state);
    _sleeveCRebalance(i, d, eq, state);
    _potRebalance(i, d, state);
  }

  void _sleeveBTopup(
    int i,
    String d,
    double eq,
    double f,
    double rB,
    String state,
  ) {
    if (f >= 1.0 && monthCount > P0sConfig.rampMonths) return;
    double cur = bParkUnits * _p(i, 'PARK');
    for (final (String t, double _, double _) in P0sConfig.bAssets) {
      final double px = _p(i, t);
      if (_fin(px)) cur += bUnits[t]! * px;
    }
    final double need = eq * rB - cur;
    if (need <= eq * 0.001) return;
    _pensionPrefund(i, d, need, cKrwUnits * _p(i, 'CKRW') * 0.98);
    final double avail = cKrwUnits * _p(i, 'CKRW') * 0.98;
    _pensionContribute(
      i,
      d,
      need < avail ? need : avail,
      state,
      'RAMP_DEPOSIT',
    );
  }

  int _year(String d) => int.parse(d.substring(0, 4));

  void _pensionPrefund(int i, String d, double need, double avail) {
    if (!variant.pensionFunding) return;
    final double left =
        P0sConfig.pensionAnnualLimit - (pensionUsed[_year(d)] ?? 0.0);
    final double quota = left > 0.0 ? left : 0.0;
    final double want = need < quota ? need : quota;
    final double short = want - (avail > 0.0 ? avail : 0.0);
    if (short <= 1.0) return;
    _takeKrw(i, d, short, _regState[i]);
  }

  double _pensionContribute(
    int i,
    String d,
    double want,
    String state,
    String event,
  ) {
    final double used = pensionUsed[_year(d)] ?? 0.0;
    final double left = P0sConfig.pensionAnnualLimit - used;
    final double quota = left > 0.0 ? left : 0.0;
    final double cash = cKrwUnits * _p(i, 'CKRW');
    double take = want;
    if (quota < take) take = quota;
    final double cashCap = cash > 0.0 ? cash : 0.0;
    if (cashCap < take) take = cashCap;
    if (take <= 1.0) return 0.0;
    cKrwUnits -= take / _p(i, 'CKRW');
    bParkUnits += take / _p(i, 'PARK');
    pensionUsed[_year(d)] = used + take;
    _rec(d, 'XFER', 'C->B', 'MOVE', take, 1.0, take, 0.0, event, state);
    return take;
  }

  void _coreBand(int i, String d, double eq, double f, String state) {
    if (P0sConfig.coreBand <= 0 || f < 1.0) return;
    final (double _, double b, double _, double _) = _values(i);
    final double tgt = eq * P0sConfig.allocB;
    final double pc = _p(i, 'CKRW');
    final double pk = _p(i, 'PARK');
    if (b > eq * (P0sConfig.allocB + P0sConfig.coreBand)) {
      final double need = (b - tgt) * 1.0; // core_band_move_frac = 1.0(전액 자동)
      double park = bParkUnits * pk;
      if (park < need) {
        const double rate =
            P0sConfig.krCommission +
            P0sConfig.krSlipEtf +
            P0sConfig.krTaxSellEtf;
        _liquidateSleeveB(i, d, (need - park) / (1.0 - rate), state);
        park = bParkUnits * pk;
      }
      final double take = need < park ? need : park;
      if (take > 1.0) {
        // 🔴 인출이 아니라 계좌 안 재분류 — 파킹 수량을 «C 로 집계하는 파킹»으로 옮긴다.
        final double units = take / pk;
        bParkUnits -= units;
        bParkCUnits += units;
        _rec(
          d,
          'XFER',
          'B->C(재분류)',
          'MOVE',
          take,
          1.0,
          take,
          0.0,
          'CORE_BAND',
          state,
        );
      }
    } else if (b < eq * (P0sConfig.allocB - P0sConfig.coreBand)) {
      double need = (tgt - b) * 1.0;
      final double parkC = bParkCUnits * pk;
      final double reclaim = need < parkC ? need : parkC;
      if (reclaim > 1.0) {
        // ① 재분류 파킹 환원 — 같은 계좌라 연 한도 무관.
        final double units = reclaim / pk;
        bParkCUnits -= units;
        bParkUnits += units;
        _rec(
          d,
          'XFER',
          'C->B(재분류환원)',
          'MOVE',
          reclaim,
          1.0,
          reclaim,
          0.0,
          'CORE_BAND',
          state,
        );
        need -= reclaim;
      }
      if (need > 1.0) {
        // ② 부족분은 신규 납입(연 1,800만 공용 한도) — v2.32 조달 경로를 먼저 본다.
        double cash = cKrwUnits * pc;
        final double free0 = cash - cReservedKrw;
        _pensionPrefund(i, d, need, free0 > 0.0 ? free0 : 0.0);
        cash = cKrwUnits * pc;
        final double free1 = cash - cReservedKrw;
        final double avail = free1 > 0.0 ? free1 : 0.0;
        _pensionContribute(
          i,
          d,
          need < avail ? need : avail,
          state,
          'CORE_BAND',
        );
      }
    }
  }

  void _liquidateSleeveB(int i, String d, double amount, String state) {
    final Map<String, double> cur = <String, double>{};
    double tot = 0.0;
    for (final (String t, double _, double _) in P0sConfig.bAssets) {
      final double px = _p(i, t);
      final double v = _fin(px) ? bUnits[t]! * px : 0.0;
      cur[t] = v;
      tot += v;
    }
    if (tot <= 0) return;
    for (final (String t, double _, double _) in P0sConfig.bAssets) {
      final double px = _p(i, t);
      if (!_fin(px) || cur[t]! <= 0) continue;
      final double share = amount * cur[t]! / tot;
      final double val = share < cur[t]! ? share : cur[t]!;
      if (val <= 1.0) continue;
      final double cost =
          val *
          (P0sConfig.krCommission +
              P0sConfig.krSlipEtf +
              P0sConfig.krTaxSellEtf);
      bUnits[t] = bUnits[t]! - val / px;
      bParkUnits += (val - cost) / _p(i, 'PARK');
      _rec(
        d,
        'B',
        t,
        'SELL',
        val / px,
        px,
        val,
        cost,
        'SLEEVE_B_FUNDING',
        state,
      );
    }
  }

  void _sleeveBSignal(int i, String d, double eq, String state0) {
    // 국면 보조(assist) — delay ≥ 1 이면 직전 호출의 (점수, 상태)를 쓰고 지금 값을 저장한다(첫 호출은 assist 없음).
    double score = _regScore[i];
    String state = state0;
    bool assistOn = variant.assistCut != null;
    if (assistOn && variant.assistDelay >= 1) {
      final (double, String)? prev = _bAssistPrev;
      _bAssistPrev = (score, state0);
      if (prev == null) {
        assistOn = false;
      } else {
        (score, state) = prev;
      }
    }
    double base = bParkUnits * _p(i, 'PARK');
    final Map<String, double> cur = <String, double>{};
    for (final (String t, double _, double _) in P0sConfig.bAssets) {
      final double px = _p(i, t);
      cur[t] = _fin(px) ? bUnits[t]! * px : 0.0;
      base += cur[t]!;
    }
    if (base <= 0) return;
    final String? nxt = _nextAfter(m.kr, d);
    if (nxt == null) return;
    final String monthKey = d.substring(0, 7);
    for (final (String t, double w, double _) in P0sConfig.bAssets) {
      final DatedSeries me = m.bMonthly[t]!;
      final List<double> mc = <double>[
        for (int k = 0; k < me.length; k++)
          if (me.dates[k].compareTo(monthKey) <= 0) me.values[k],
      ];
      const int need = 12;
      double ratio;
      if (mc.length < need) {
        ratio = 0.0;
      } else {
        int held = 0;
        for (final int n in P0sConfig.lookbacks) {
          if (mc.last > npMean(mc.sublist(mc.length - n))) held++;
        }
        ratio = held / P0sConfig.lookbacks.length;
      }
      if (mc.length >= need) {
        if (variant.bSmaFloor > 0) {
          ratio = ratio > variant.bSmaFloor ? ratio : variant.bSmaFloor;
        }
        // 참조 엔진: assist 블록은 방향 스코어가 유한할 때만(`if assist and np.isfinite(score)`).
        if (assistOn && _fin(score) && state == P0sConfig.bAssistCutState) {
          final double x = ratio - variant.assistCut!;
          ratio = x > 0.0 ? x : 0.0;
        }
      }
      final double tgt = base * w * ratio;
      final double delta = tgt - cur[t]!;
      if (delta.abs() > base * 0.005 && _fin(_p(i, t))) {
        _pending
            .putIfAbsent(nxt, () => <_Order>[])
            .add(
              _Order(
                'B',
                t,
                delta > 0 ? 'BUY' : 'SELL',
                delta.abs(),
                'SLEEVE_B_SMA',
              ),
            );
      }
    }
  }

  void _sleeveCRebalance(int i, String d, double eq, String state) {
    final double fx = _p(i, 'fx');
    final double iauPx = _p(i, 'IAU');
    final double ieiPx = _p(i, 'IEI');
    final double vCashAll = cKrwUnits * _p(i, 'CKRW');
    final double vCashRaw = vCashAll - cReservedKrw;
    final double vCash = vCashRaw > 0.0 ? vCashRaw : 0.0;
    final double vIei = cIeiUnits * ieiPx * fx;
    final double vIau = _fin(iauPx) ? cIauUnits * iauPx * fx : 0.0;
    final double base = vCash + vIei + vIau;
    if (base <= 0) return;
    final double goldCap = eq * P0sConfig.maxGoldPctOfTotal;
    final double tIauRaw = _fin(iauPx) ? base * P0sConfig.cIauW : 0.0;
    final double tIau = tIauRaw < goldCap ? tIauRaw : goldCap;
    final double tIei =
        base * P0sConfig.cIeiW + 0.0; // 흡수 0(gold_cap_excess_to_bond)
    final String? nxt = _nextAfter(m.us, d);
    if (nxt == null) return;
    const double rel = P0sConfig.satBandHi - 1.0; // 새틀 0% — 밴드 상수의 상대 임계
    for (final (String sym, double tgt, double curv)
        in <(String, double, double)>[
          ('IEI', tIei, vIei),
          ('IAU', tIau, vIau),
        ]) {
      final double delta = tgt - curv;
      if (tgt > 0 && delta.abs() <= tgt * rel) continue;
      if (delta.abs() > base * 0.002) {
        _pending
            .putIfAbsent(nxt, () => <_Order>[])
            .add(
              _Order(
                'C',
                sym,
                delta > 0 ? 'BUY' : 'SELL',
                delta.abs(),
                'SLEEVE_C_REBAL',
              ),
            );
      }
    }
  }

  String? _nextAfter(List<String> sessions, String d) {
    int lo = 0;
    int hi = sessions.length;
    while (lo < hi) {
      final int mid = (lo + hi) >> 1;
      if (sessions[mid].compareTo(d) <= 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo < sessions.length ? sessions[lo] : null;
  }

  // ── 기록 ──────────────────────────────────────────────────────────────
  double _snapshot(int i, String d, String state) {
    final (double a, double b, double c, double s) = _values(i);
    final double eq = a + b + c + s;
    final double fx = _p(i, 'fx');
    final double iauPx = _p(i, 'IAU');
    // N2 `GoldTrackBacktest._snapshot` — B · POT 의 금(411060) 평가액(E6e 금 비중).
    final double goldPx = _p(i, '411060');
    daily.add(
      DailyRow(
        d,
        <String, double>{
          'equity': eq,
          'A': a,
          'B': b,
          'C': c,
          'c_krw': cKrwUnits * _p(i, 'CKRW'),
          'c_park_c': bParkCUnits * _p(i, 'PARK'),
          'c_iei': cIeiUnits * _p(i, 'IEI') * fx,
          'c_iau': _fin(iauPx) ? cIauUnits * iauPx * fx : 0.0,
          'b_park': bParkUnits * _p(i, 'PARK'),
          'pot': _potValue(i),
          'dd': dd,
          'gold_b': _fin(goldPx) ? bUnits['411060']! * goldPx : 0.0,
          'gold_pot': _fin(goldPx) ? potBUnits['411060']! * goldPx : 0.0,
        },
        level,
        state,
      ),
    );
    return eq;
  }
}
