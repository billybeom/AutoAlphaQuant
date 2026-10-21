// 월말 계획기 — 월 마지막 KR 거래일의 정기 조정 한 벌(M1-4 실행 경로의 핵심 · 설계 13 §8 R18 D-14).
//
// 🔴 순서는 참조 엔진(백테스트6 `Backtest._kr_month_end`)이 정본이다 — 골든이 그 동작의 실측이고, 재현 하네스가
//    26년 비트 일치로 옮겨 둔 순서를 Decimal 로 다시 적었다(R17 원칙 «하네스 = 참조 엔진»):
//      ① 램프 납입(처음 `rampMonths` 달 — B 목표 × 진행 비율까지 연금 납입 · v2.32 조달 먼저)
//      ② 코어 밴드(램프가 끝난 달부터 — B 지분 목표 ± band 이탈분 전액 · 03 §5-2 v2.20 · v2.21 · v2.32)
//         · B 초과 → 파킹이 모자라면 B 자산을 비례 매도(비용 그로스업)해 파킹으로 → 같은 계좌 안 재분류(B→C)
//         · B 미달 → 재분류분 환원(한도 무관) → 부족분 신규 납입(연 한도 · A 재진입 재원 보호 · 조달 먼저)
//      ③ 슬리브 B 3-트랜치 신호(하한 → BEAR 차감) → 다음 KR 세션 주문
//      ④ 슬리브 C 리밸런싱(분모 = 예약 밖 원화 + 채권 + 금 · R17 ② · 금 = min(비중 몫, 총자산 × 8%)) → 다음 US 세션 주문
//      ⑤ POT 서브북(기본 3-트랜치만 · 당일 체결)
// 🔴 원화 조달(`_raise_krw`)은 C 방어자산(금 → 채권)을 **필요한 만큼** 판다 — 잉여 상한 없음(R17 ① 결정).
// 🔴 앞 단계의 이동이 뒤 단계의 입력이다 — 단계마다 작업 상태를 고쳐 가며 잰다. 총자산(`totalEquity`)만은
//    참조 엔진처럼 맨 앞에서 한 번 잰 값을 끝까지 쓴다.
// 🔵 비용률은 설정으로 받는다 — 참조 엔진의 C 는 미국 상장(수수료 + 슬리피지 + 환전 편도)이고 실전 C 는 국내상장 ETF
//    다(R17 ⑤ — 값만 다르고 순서는 같다).
// 🔵 이 함수는 값만 낸다(부작용 0) — 실주문(E10) · 미리보기(E7a3-2)가 같은 함수를 쓴다(06 M3-1 «실집행과 동일 코드 경로»).

import 'package:decimal/decimal.dart';

import '../decimal_rules.dart';
import '../signals/regime_states.dart';
import '../signals/sleeve_b_tranche.dart';

/// 월말 계획기 설정(02 §4 · P0S 정본 값).
class MonthEndConfig {
  MonthEndConfig({
    required this.allocB,
    required this.coreBand,
    required this.rampMonths,
    required this.bAssets,
    required this.lookbackMonths,
    required this.assist,
    required this.cBondSymbol,
    required this.cGoldSymbol,
    required this.cBondWeight,
    required this.cGoldWeight,
    required this.maxGoldPctOfTotal,
    required this.cRelativeBand,
    required this.bOrderThreshold,
    required this.cOrderThreshold,
    required this.potOrderThreshold,
    required this.topupMinFraction,
    required this.krwUsableFraction,
    required this.pensionAnnualLimit,
    required this.pensionFunding,
    required this.bSellCostRate,
    required this.cSellCostRate,
    required this.potCostRate,
  });

  /// 슬리브 B 목표 비중.
  final Decimal allocB;

  /// 코어 밴드 폭(목표 ± band · strict).
  final Decimal coreBand;

  /// 램프 달 수(처음 n 달은 B 를 목표 × 진행 비율까지 납입).
  final int rampMonths;

  /// 슬리브 B 자산(코드 · 비중) — POT 서브북도 같은 자산·비중을 쓴다.
  final List<(String, Decimal)> bAssets;

  /// 3-트랜치 룩백(월).
  final List<int> lookbackMonths;

  /// P0S 하한 · BEAR 차감(B 본책 전용 — POT 는 기본 비율만).
  final SleeveBAssist assist;

  /// 슬리브 C 채권 · 금 코드와 비중.
  final String cBondSymbol, cGoldSymbol;
  final Decimal cBondWeight, cGoldWeight;

  /// 금 상한(총자산 대비 · 슬리브 C 한정).
  final Decimal maxGoldPctOfTotal;

  /// C 리밸런싱 상대 밴드 — 목표 대비 이만큼 안이면 넘어간다(참조 엔진 = 새틀 밴드 상수 21/18 − 1).
  final Decimal cRelativeBand;

  /// 주문 문턱(분모 대비) — B 0.5% · C 0.2% · POT 0.5%.
  final Decimal bOrderThreshold, cOrderThreshold, potOrderThreshold;

  /// 램프 납입 문턱(총자산 대비 0.1%).
  final Decimal topupMinFraction;

  /// 램프 납입에 쓸 수 있는 원화 비율(참조 엔진 0.98).
  final Decimal krwUsableFraction;

  /// 연금 합산 연 납입한도(원).
  final Decimal pensionAnnualLimit;

  /// v2.32 연금 납입 조달 경로(납입 전에 C 방어자산을 팔아 원화를 마련) 켜기.
  final bool pensionFunding;

  /// 비용률 — B 매도(수수료 + 슬리피지 + 거래세) · C 매도(조달) · POT 매매.
  final Decimal bSellCostRate, cSellCostRate, potCostRate;
}

/// 계획기 입력 — 그날 종가 평가(원) · 회계 상태.
class MonthEndState {
  const MonthEndState({
    required this.totalEquity,
    required this.bAssets,
    required this.bParking,
    required this.bParkingReclassified,
    required this.krwCash,
    required this.reservedKrw,
    required this.cBond,
    required this.cGold,
    required this.potCash,
    required this.potAssets,
    required this.pensionUsedThisYear,
    required this.monthIndex,
    required this.regimeState,
    required this.monthlyCloses,
    required this.hasNextKrSession,
    required this.hasNextUsSession,
  });

  /// 총자산(A + B + C) — 맨 앞에서 한 번 잰 값.
  final Decimal totalEquity;

  /// 슬리브 B 자산 평가 — null = 그날 가격 없음.
  final Map<String, Decimal?> bAssets;

  /// 연금 계좌 파킹(B 로 집계) · 그중 C 로 재분류한 파킹(같은 계좌).
  final Decimal bParking, bParkingReclassified;

  /// 슬리브 C 원화 현금성 · 그중 A 재진입 예약분.
  final Decimal krwCash, reservedKrw;

  /// 슬리브 C 채권 · 금 평가 — 금 null = 가격 없음.
  final Decimal cBond;
  final Decimal? cGold;

  /// POT 서브북 현금 · 자산(null = 가격 없음).
  final Decimal potCash;
  final Map<String, Decimal?> potAssets;

  /// 올해 연금 합산 납입 누계(원).
  final Decimal pensionUsedThisYear;

  /// 이번이 몇 번째 월말인가(1부터 — 램프 진행 비율).
  final int monthIndex;

  /// BEAR 차감에 쓰는 방향 상태 — 방향 스코어가 없으면 null(차감하지 않는다 · 참조 엔진 `np.isfinite(score)`).
  final DirectionState? regimeState;

  /// 자산별 월봉 종가(오래된 것부터 · 이번 달 포함).
  final Map<String, List<double>> monthlyCloses;

  /// 다음 KR · US 세션이 달력 안에 있는가(없으면 그 주문을 내지 않는다).
  final bool hasNextKrSession, hasNextUsSession;
}

/// 계획 행동의 종류 — 참조 엔진 원장의 사건과 하나씩 짝.
enum MonthEndActionKind {
  /// 램프 연금 납입(원화 → B 파킹 · `RAMP_DEPOSIT`).
  rampContribution,

  /// 코어 밴드 B 초과 — 파킹을 C 로 재분류(`CORE_BAND` · 같은 계좌).
  coreBandReclassify,

  /// 코어 밴드 B 미달 — 재분류분 환원(`CORE_BAND` · 한도 무관).
  coreBandReclaim,

  /// 코어 밴드 B 미달 — 신규 납입(`CORE_BAND` · 연 한도).
  coreBandContribution,

  /// 원화 조달 — C 방어자산 매도(`RAISE_KRW` · 당일).
  raiseKrw,

  /// 코어 밴드 재원 — B 자산 비례 매도(`SLEEVE_B_FUNDING` · 당일).
  sleeveBFundingSell,

  /// POT 서브북 매매(`D2_POT_SMA` · 당일).
  potTrade,

  /// 슬리브 B 신호 주문(`SLEEVE_B_SMA` · 다음 KR 세션).
  sleeveBOrder,

  /// 슬리브 C 리밸런싱 주문(`SLEEVE_C_REBAL` · 다음 US 세션).
  sleeveCOrder,
}

/// 계획 행동 하나 — [amount] = 거래·이체 총액(원) · [cost] = 비용(당일 매매만).
class MonthEndAction {
  MonthEndAction(
    this.kind,
    this.amount, {
    this.symbol,
    this.isBuy,
    Decimal? cost,
  }) : cost = cost ?? Decimal.zero;

  final MonthEndActionKind kind;
  final Decimal amount;

  /// 매매면 종목 코드 · 이체면 null.
  final String? symbol;

  /// 매매면 매수(true)·매도(false) · 이체면 null.
  final bool? isBuy;
  final Decimal cost;

  @override
  String toString() =>
      '${kind.name} ${symbol ?? ''} ${isBuy == null ? '' : (isBuy! ? 'BUY' : 'SELL')} $amount (비용 $cost)';
}

/// 계획 결과 — 행동(실행 순서) + 당일 이동을 반영한 뒤의 상태.
class MonthEndPlan {
  const MonthEndPlan(this.actions, this.after);
  final List<MonthEndAction> actions;
  final MonthEndState after;
}

/// 월말 계획 한 벌을 만든다(값만 — 부작용 0).
MonthEndPlan planMonthEnd(MonthEndState s, MonthEndConfig cfg) =>
    _Planner(s, cfg).run();

final Decimal _one = Decimal.one;

class _Planner {
  _Planner(this.s, this.cfg)
    : bAssets = Map<String, Decimal?>.of(s.bAssets),
      bParking = s.bParking,
      bParkC = s.bParkingReclassified,
      krw = s.krwCash,
      cBond = s.cBond,
      cGold = s.cGold,
      potCash = s.potCash,
      potAssets = Map<String, Decimal?>.of(s.potAssets),
      used = s.pensionUsedThisYear;

  final MonthEndState s;
  final MonthEndConfig cfg;
  final List<MonthEndAction> out = <MonthEndAction>[];

  final Map<String, Decimal?> bAssets;
  Decimal bParking, bParkC, krw, cBond, potCash, used;
  Decimal? cGold;
  final Map<String, Decimal?> potAssets;

  MonthEndPlan run() {
    final Decimal eq = s.totalEquity;
    final Decimal f = cfg.rampMonths <= 0
        ? _one
        : _minD(
            divide(
              Decimal.fromInt(s.monthIndex),
              Decimal.fromInt(cfg.rampMonths),
            ),
            _one,
          );
    _rampTopup(eq, f, cfg.allocB * f);
    _coreBand(eq, f);
    _sleeveB();
    _sleeveC(eq);
    _pot();
    return MonthEndPlan(
      List<MonthEndAction>.unmodifiable(out),
      MonthEndState(
        totalEquity: s.totalEquity,
        bAssets: bAssets,
        bParking: bParking,
        bParkingReclassified: bParkC,
        krwCash: krw,
        reservedKrw: s.reservedKrw,
        cBond: cBond,
        cGold: cGold,
        potCash: potCash,
        potAssets: potAssets,
        pensionUsedThisYear: used,
        monthIndex: s.monthIndex,
        regimeState: s.regimeState,
        monthlyCloses: s.monthlyCloses,
        hasNextKrSession: s.hasNextKrSession,
        hasNextUsSession: s.hasNextUsSession,
      ),
    );
  }

  Decimal get _bValue => bAssets.values.fold(
    bParking,
    (Decimal a, Decimal? v) => v == null ? a : a + v,
  );

  // ① 램프 납입.
  void _rampTopup(Decimal eq, Decimal f, Decimal rB) {
    if (f >= _one && s.monthIndex > cfg.rampMonths) return;
    final Decimal need = eq * rB - _bValue;
    if (need <= eq * cfg.topupMinFraction) return;
    _prefund(need, krw * cfg.krwUsableFraction);
    final Decimal avail = krw * cfg.krwUsableFraction;
    _contribute(_minD(need, avail), MonthEndActionKind.rampContribution);
  }

  // ② 코어 밴드.
  void _coreBand(Decimal eq, Decimal f) {
    if (cfg.coreBand <= Decimal.zero || f < _one) return;
    final Decimal b = _bValue;
    final Decimal tgt = eq * cfg.allocB;
    if (b > eq * (cfg.allocB + cfg.coreBand)) {
      final Decimal need = b - tgt;
      if (bParking < need) {
        _liquidateB(divide(need - bParking, _one - cfg.bSellCostRate));
      }
      final Decimal take = _minD(need, bParking);
      if (take > _one) {
        bParking -= take;
        bParkC += take;
        out.add(MonthEndAction(MonthEndActionKind.coreBandReclassify, take));
      }
    } else if (b < eq * (cfg.allocB - cfg.coreBand)) {
      Decimal need = tgt - b;
      final Decimal reclaim = _minD(need, bParkC);
      if (reclaim > _one) {
        bParkC -= reclaim;
        bParking += reclaim;
        out.add(MonthEndAction(MonthEndActionKind.coreBandReclaim, reclaim));
        need -= reclaim;
      }
      if (need > _one) {
        _prefund(need, _maxD(krw - s.reservedKrw, Decimal.zero));
        final Decimal avail = _maxD(krw - s.reservedKrw, Decimal.zero);
        _contribute(
          _minD(need, avail),
          MonthEndActionKind.coreBandContribution,
        );
      }
    }
  }

  /// B 자산 비례 매도 → 같은 계좌 파킹(코어 밴드 재원).
  void _liquidateB(Decimal amount) {
    final Decimal tot = bAssets.values.fold(
      Decimal.zero,
      (Decimal a, Decimal? v) => v == null ? a : a + v,
    );
    if (tot <= Decimal.zero) return;
    final Map<String, Decimal?> cur = Map<String, Decimal?>.of(bAssets);
    for (final (String t, Decimal _) in cfg.bAssets) {
      final Decimal? v = cur[t];
      if (v == null || v <= Decimal.zero) continue;
      final Decimal share = mulDiv(amount, v, tot);
      final Decimal val = _minD(share, v);
      if (val <= _one) continue;
      final Decimal cost = val * cfg.bSellCostRate;
      bAssets[t] = bAssets[t]! - val;
      bParking += val - cost;
      out.add(
        MonthEndAction(
          MonthEndActionKind.sleeveBFundingSell,
          val,
          symbol: t,
          isBuy: false,
          cost: cost,
        ),
      );
    }
  }

  /// v2.32 조달 — 납입 필요액(한도 안)이 쓸 수 있는 원화보다 크면 그 차이를 C 방어자산 매도로 먼저 마련.
  void _prefund(Decimal need, Decimal avail) {
    if (!cfg.pensionFunding) return;
    final Decimal quota = _maxD(cfg.pensionAnnualLimit - used, Decimal.zero);
    final Decimal want = _minD(need, quota);
    final Decimal short = want - _maxD(avail, Decimal.zero);
    if (short <= _one) return;
    _raiseKrw(short);
  }

  /// C 방어자산(금 → 채권)을 필요한 만큼 판다(R17 ①) — 비용 그로스업.
  void _raiseKrw(Decimal need0) {
    if (need0 <= _one) return;
    Decimal need = need0;
    for (final bool gold in <bool>[true, false]) {
      if (need <= Decimal.zero) return;
      final Decimal? val = gold ? cGold : cBond;
      if (val == null) continue;
      final Decimal gross = divide(need, _one - cfg.cSellCostRate);
      final Decimal take = _minD(gross, val);
      if (take <= _one) continue;
      final Decimal cost = take * cfg.cSellCostRate;
      if (gold) {
        cGold = val - take;
      } else {
        cBond = val - take;
      }
      krw += take - cost;
      out.add(
        MonthEndAction(
          MonthEndActionKind.raiseKrw,
          take,
          symbol: gold ? cfg.cGoldSymbol : cfg.cBondSymbol,
          isBuy: false,
          cost: cost,
        ),
      );
      need -= take - cost;
    }
  }

  /// 연금 납입(원화 → B 파킹) — 남은 한도 · 원화 안에서.
  void _contribute(Decimal want, MonthEndActionKind kind) {
    final Decimal quota = _maxD(cfg.pensionAnnualLimit - used, Decimal.zero);
    Decimal take = _minD(want, quota);
    take = _minD(take, _maxD(krw, Decimal.zero));
    if (take <= _one) return;
    krw -= take;
    bParking += take;
    used += take;
    out.add(MonthEndAction(kind, take));
  }

  // ③ 슬리브 B 3-트랜치 → 다음 KR 세션 주문.
  void _sleeveB() {
    final Decimal base = _bValue;
    if (base <= Decimal.zero || !s.hasNextKrSession) return;
    for (final (String t, Decimal w) in cfg.bAssets) {
      final List<double> mc = s.monthlyCloses[t] ?? const <double>[];
      final double ratio = sleeveBTargetRatioP0(
        mc,
        lookbackMonths: cfg.lookbackMonths,
        assist: cfg.assist,
        regimeState: s.regimeState ?? DirectionState.unknown,
      );
      final Decimal? cur = bAssets[t];
      final Decimal tgt = base * w * promoteRatio(ratio);
      final Decimal delta = tgt - (cur ?? Decimal.zero);
      if (cur != null && delta.abs() > base * cfg.bOrderThreshold) {
        out.add(
          MonthEndAction(
            MonthEndActionKind.sleeveBOrder,
            delta.abs(),
            symbol: t,
            isBuy: delta > Decimal.zero,
          ),
        );
      }
    }
  }

  // ④ 슬리브 C 리밸런싱 → 다음 US 세션 주문.
  void _sleeveC(Decimal eq) {
    final Decimal vCash = _maxD(krw - s.reservedKrw, Decimal.zero);
    final Decimal vGold = cGold ?? Decimal.zero;
    final Decimal base = vCash + cBond + vGold;
    if (base <= Decimal.zero || !s.hasNextUsSession) return;
    final Decimal goldCap = eq * cfg.maxGoldPctOfTotal;
    final Decimal tGold = cGold == null
        ? Decimal.zero
        : _minD(base * cfg.cGoldWeight, goldCap);
    final Decimal tBond = base * cfg.cBondWeight;
    for (final (String sym, Decimal tgt, Decimal cur)
        in <(String, Decimal, Decimal)>[
          (cfg.cBondSymbol, tBond, cBond),
          (cfg.cGoldSymbol, tGold, vGold),
        ]) {
      final Decimal delta = tgt - cur;
      if (tgt > Decimal.zero && delta.abs() <= tgt * cfg.cRelativeBand) {
        continue;
      }
      if (delta.abs() > base * cfg.cOrderThreshold) {
        out.add(
          MonthEndAction(
            MonthEndActionKind.sleeveCOrder,
            delta.abs(),
            symbol: sym,
            isBuy: delta > Decimal.zero,
          ),
        );
      }
    }
  }

  // ⑤ POT 서브북 — 기본 3-트랜치 · 당일 체결.
  void _pot() {
    final Decimal base = potAssets.values.fold(
      potCash,
      (Decimal a, Decimal? v) => v == null ? a : a + v,
    );
    if (base <= _one) return;
    for (final (String t, Decimal w) in cfg.bAssets) {
      final Decimal? cur = potAssets[t];
      if (cur == null) continue;
      final double ratio = sleeveBTargetWeight(
        s.monthlyCloses[t] ?? const <double>[],
        lookbackMonths: cfg.lookbackMonths,
      );
      final Decimal tgt = base * w * promoteRatio(ratio);
      final Decimal delta = tgt - cur;
      if (delta.abs() <= base * cfg.potOrderThreshold) continue;
      if (delta > Decimal.zero) {
        final Decimal cap = _maxD(
          divide(potCash, _one + cfg.potCostRate),
          Decimal.zero,
        );
        final Decimal buy = _minD(delta, cap);
        if (buy <= _one) continue;
        potAssets[t] = cur + buy;
        potCash -= buy * (_one + cfg.potCostRate);
        out.add(
          MonthEndAction(
            MonthEndActionKind.potTrade,
            buy,
            symbol: t,
            isBuy: true,
            cost: buy * cfg.potCostRate,
          ),
        );
      } else {
        final Decimal sell = _minD(-delta, cur);
        if (sell <= _one) continue;
        potAssets[t] = cur - sell;
        potCash += sell * (_one - cfg.potCostRate);
        out.add(
          MonthEndAction(
            MonthEndActionKind.potTrade,
            sell,
            symbol: t,
            isBuy: false,
            cost: sell * cfg.potCostRate,
          ),
        );
      }
    }
  }
}

Decimal _minD(Decimal a, Decimal b) => a < b ? a : b;
Decimal _maxD(Decimal a, Decimal b) => a > b ? a : b;
