// E6c 재현 장부 — 참조 엔진(백테스트6 `engine/backtest.py`)의 P0S 일별 루프를 같은 연산 순서의 double 로 옮긴다.
//
// 🔴 정본은 참조 엔진 코드다(이식 지도 §3·§4). 수량·현금 갱신식, 원장 비용 «보고» 식, 1원 문턱, 같은 날 주문의
//    쌓인 순서(매도 먼저로 정렬하지 않는다)를 그대로 둔다 — 골든(원장 934행 · 비용 24,289,863원)이 그 동작의 실측이다.
// 🔴 앱(lib)의 Decimal 함수는 쓰지 않는다 — 재현은 파이썬 float 연산 순서가 기준이다(지도 §9 권고).
//    규칙 판정(B 트랜치 하한·BEAR 차감)은 lib 와 같은 식이지만 평균은 numpy 짝 합산이라 여기서 따로 계산한다.
// 🔵 E6c 범위: 보유비용 · 평가 · 브레이커 · 체결(B·C) · 램프 · B 트랜치 · C 리밸런싱 · 스냅숏.
//    E6d 몫(계절 A · POT · 코어 밴드 · 조달)에 닿으면 [UnimplementedError] — [ReplayEngine.run] 의 `until` 로 구간을 끊는다.

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
  static const double bSmaFloor = 1.0 / 3;
  static const double bAssistCut = 2.0 / 3;
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
  static const bool pensionFunding = true;
  static const double coreBand = 0.03;
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

/// 일별 기록 한 행(`_snapshot` 중 대조하는 열).
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

const Map<String, int> _levelOrder = <String, int>{
  'NORMAL': 0,
  'ALERT': 1,
  'REDUCED': 2,
  'HALTED': 3,
  'STOPPED': 4,
};

/// numpy `np.mean` — 짝 합산(n ≤ 128: 누산기 8개) ÷ n. 20만 배열로 비트 일치 확인(2026-10-21).
double npMean(List<double> a) {
  final int n = a.length;
  double sum;
  if (n < 8) {
    sum = 0.0;
    for (final double x in a) {
      sum += x;
    }
  } else if (n <= 128) {
    final List<double> r = a.sublist(0, 8);
    int i = 8;
    for (; i < n - (n % 8); i += 8) {
      for (int j = 0; j < 8; j++) {
        r[j] += a[i + j];
      }
    }
    sum = ((r[0] + r[1]) + (r[2] + r[3])) + ((r[4] + r[5]) + (r[6] + r[7]));
    for (; i < n; i++) {
      sum += a[i];
    }
  } else {
    throw UnimplementedError('np.mean 짝 합산 n > 128 은 쓰지 않는다');
  }
  return sum / n;
}

/// 참조 엔진 P0S 일별 루프.
class ReplayEngine {
  ReplayEngine(this.m, ReplayRegime regime) {
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
    _krSet = m.kr.toSet();
    _usSet = m.us.toSet();
    for (int i = 0; i < m.allDays.length; i++) {
      _dayPos[m.allDays[i]] = i;
    }
  }

  final ReplayMarket m;
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

  // ── 계절(E6d) ─────────────────────────────────────────────────────────
  void _seasonal(int i, String d, String state) {
    // E6c: A 진입·청산 · POT 는 E6d 몫. 2000-12-21 첫 A 진입 전에는 F1 보류 이벤트만 생긴다(원장 행 없음).
    if (aUnits != 0.0 || potCashUnits != 0.0) {
      throw UnimplementedError('계절 A · POT — E6d ($d)');
    }
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
    if (_potValue(i) > 1.0) throw UnimplementedError('POT 리밸런싱 — E6d ($d)');
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
    if (!P0sConfig.pensionFunding) return;
    final double left =
        P0sConfig.pensionAnnualLimit - (pensionUsed[_year(d)] ?? 0.0);
    final double quota = left > 0.0 ? left : 0.0;
    final double want = need < quota ? need : quota;
    final double short = want - (avail > 0.0 ? avail : 0.0);
    if (short <= 1.0) return;
    throw UnimplementedError('연금 납입 조달(_take_krw) — E6d ($d)');
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

  void _sleeveBSignal(int i, String d, double eq, String state) {
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
        if (P0sConfig.bSmaFloor > 0) {
          ratio = ratio > P0sConfig.bSmaFloor ? ratio : P0sConfig.bSmaFloor;
        }
        // 참조 엔진: assist 블록은 방향 스코어가 유한할 때만(`if assist and np.isfinite(score)`).
        if (_fin(_regScore[i]) && state == P0sConfig.bAssistCutState) {
          final double x = ratio - P0sConfig.bAssistCut;
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
        },
        level,
        state,
      ),
    );
    return eq;
  }
}
