// SAF 경고 한도 판정 — 일간(202 · 208 · 302 · 305 · 307) · 월간(201 · 306) · 리밸런싱(204 · 205)
// (`06_시스템설계/04_안전장치.md` §1 Level 2 · 3 표 · v2.23 «SAF 일간·월간 경고 한도» 블록 · 05 AC-B28 GV-40a · b · c ·
//  03 §3-6 켈리 상한 · 설계 13 §8 R166 · E3c).
//
// 참조 구현 = `08_파일럿/파일럿5/vectors/gv40_gen_vectors.py` 의 `gv40a_daily` · `gv40b_monthly` · `gv40c_rebalance`
// (정답지 `gv40_saf_warn.json` 을 구운 판) — 셈 차례까지 그대로 옮겼다. 경계 케이스(a04 = 0.40 · a05 = 0.30)는 이진 정확
// 값이라 곱 · 합 차례가 달라지면 == 판정이 뒤집힐 수 있다.
//
// 🔴 경계 = 상·하한 포함(== 통과 · 04 §1 표 ≤/≥ · v2.23 블록 «경계 규약»). 발동은 엄격 초과 · 미달일 때만.
// 🔴 조치 = 04 §1 표 «위반 시» 열([kWarnActions]) — 경고 한도는 주문을 막지 않는다(305 를 «주문 거부»로 격상 금지 · 05 적대 변형).
// 🔴 fail-closed(04 §1 · NR-4) — 판정할 수 없으면(분산 0 이하 · 수가 아닌 값 · 행렬 꼴 틀림) [RiskCheckUnavailable].
//    «경고 없음»으로 넘어가지 않는다(NaN 비교는 늘 거짓이라 그대로 두면 경고가 조용히 사라진다).
// 🔵 05 «발주자 대기» 세부 3건 = **참조 생성기 판**(정답지를 만든 판 · 확정되면 벡터 재생성 · 설계 13 §8 R166):
//    ① 208 분모 = 새틀라이트 **부분 공분산**의 오일러 분해(새틀 안 비중 — 202 의 분모 «포트폴리오 위험»과 다르다 · 04 v2.9)
//    ② 205(섹터 초과분 제외) 먼저 → 204(남은 것의 랭크 상위 N) ③ 306 = 과세연도 누계 입력과 비교만(집계 산식은 부르는 쪽).
// 🔵 v2.31 P0S — 201 · 202 · 208 은 «해당 없음(보존)»(새틀 0%). 판정 규칙은 보존한다: 새틀 보유가 없으면(또는 비중이 전부 0)
//    208 은 건너뛰고 202 몫 = 0 이다(참조는 빈 부분행렬에서 «분산 0» 예외를 낸다 — 벡터 밖 입력 · 04 «해당 없음» 쪽을 따름).
//    201 은 새틀이 비활성이면 부르는 쪽이 부르지 않는다(밴드 0.15~0.21 에 0 을 넣으면 발동한다).
// 🔵 SAF-307 조치 = «기록만(P2)»(04 v2.46 · 발주자 확정 2026-11-19 · 설계 13 §8 R175 · R176 — v2.30 재정의의 글자 반영) ·
//    GV-40 a11 · a12 재생성(05 v1.24 · 판정 불변). 옛 정답지(v2.23) = «경고».
// 🔵 운영 배선(일간 · 월간 잡 · 리밸런싱 선정 · 알림 등급)은 이 파일 밖이다 — 여기는 판정 규칙(순수 함수)만.

import 'package:decimal/decimal.dart';

import 'limits.dart' show RiskCheckUnavailable;

/// 경고 한도 SAF 코드(04 §1 표).
abstract final class WarnLimitIds {
  /// 새틀라이트 allocation 밴드(월간).
  static const String satelliteBand = 'SAF-201';

  /// 새틀라이트 위험 기여도(일간 · 분모 = 포트폴리오 위험).
  static const String satelliteRc = 'SAF-202';

  /// 슬리브 A 최대 종목 수(리밸런싱).
  static const String sleeveAMaxPositions = 'SAF-204';

  /// 슬리브 A 섹터 집중도(리밸런싱).
  static const String sleeveASectorCap = 'SAF-205';

  /// 단일 종목 위험 기여도(일간 · 분모 = 새틀라이트 위험).
  static const String singleRc = 'SAF-208';

  /// 방어 슬리브 하한(일간).
  static const String defensiveFloor = 'SAF-302';

  /// 켈리 상한(일간 · 위험자산 ≤ 하프 켈리).
  static const String halfKelly = 'SAF-305';

  /// 연간 금융소득 상한(월간).
  static const String financialIncomeCap = 'SAF-306';

  /// USD 익스포저(일간).
  static const String usdExposure = 'SAF-307';

  /// 금 총자산 비중(일간 · 04 v2.27 · 판정 = `ops/p0s_warn.dart` · E3d-1).
  static const String goldTotal = 'SAF-308';
}

/// 경고 한도 조치(04 §1 표 «위반 시» 열) — 주문 거부는 여기 없다.
enum WarnAction {
  /// 경고 + 다음 리밸런싱에 반영(SAF-202 · 208).
  warnNextRebalance,

  /// 경고(SAF-302 · 305 · 306 · 308).
  warn,

  /// 기록만(P2 — SAF-307 · 04 v2.30 «한도 없음 — 계측» · v2.46).
  record,

  /// 리밸런싱(SAF-201).
  rebalance,

  /// 상위 N 개만(SAF-204).
  topN,

  /// 초과분 제외(SAF-205).
  dropExcess,
}

/// 🔴 SAF ID → 조치(04 §1 표 «위반 시» 열 그대로).
const Map<String, WarnAction> kWarnActions = <String, WarnAction>{
  WarnLimitIds.satelliteBand: WarnAction.rebalance,
  WarnLimitIds.satelliteRc: WarnAction.warnNextRebalance,
  WarnLimitIds.sleeveAMaxPositions: WarnAction.topN,
  WarnLimitIds.sleeveASectorCap: WarnAction.dropExcess,
  WarnLimitIds.singleRc: WarnAction.warnNextRebalance,
  WarnLimitIds.defensiveFloor: WarnAction.warn,
  WarnLimitIds.halfKelly: WarnAction.warn,
  WarnLimitIds.financialIncomeCap: WarnAction.warn,
  WarnLimitIds.usdExposure: WarnAction.record,
  WarnLimitIds.goldTotal: WarnAction.warn,
};

/// 섹터가 없는 종목의 버킷(04 §1 v1.4 — 이 버킷에는 SAF-205 를 걸지 않는다).
const String kUnknownSectorBucket = 'UNKNOWN';

/// 경고 한도 문턱(값은 config 에서 온다 — 02 §4 · 04 §1 표 · 여기서 정하지 않는다).
class WarnLimitConfig {
  /// 만든다.
  const WarnLimitConfig({
    required this.satelliteRcMax,
    required this.singleRcMax,
    required this.minDefensivePct,
    required this.kellyFraction,
    required this.maxUsdExposurePct,
    required this.satelliteBandLow,
    required this.satelliteBandHigh,
    required this.annualFinancialIncomeCapKrw,
    required this.sleeveAMaxPositions,
    required this.sleeveAMaxPerSector,
  });

  /// SAF-202 새틀라이트 RC 상한(포트폴리오 위험 대비).
  final double satelliteRcMax;

  /// SAF-208 단일 종목 RC 상한(새틀라이트 위험 대비).
  final double singleRcMax;

  /// SAF-302 방어 슬리브 하한(`risk.min_defensive_pct`).
  final double minDefensivePct;

  /// SAF-305 켈리 비율(`kelly_fraction` — 하프 켈리 = 0.5 · 03 §3-6).
  final double kellyFraction;

  /// SAF-307 USD 익스포저 기준선(`risk.max_usd_exposure_pct` — 한도 아님 · 초과 일수 계측 기준선 · 04 v2.30).
  final double maxUsdExposurePct;

  /// SAF-201 밴드 아래 끝(포함).
  final double satelliteBandLow;

  /// SAF-201 밴드 위 끝(포함).
  final double satelliteBandHigh;

  /// SAF-306 연간 금융소득 상한(원 · `risk.annual_financial_income_cap_krw`).
  final Decimal annualFinancialIncomeCapKrw;

  /// SAF-204 슬리브 A 최대 종목 수(`sleeve_a.n_positions`).
  final int sleeveAMaxPositions;

  /// SAF-205 슬리브 A 섹터당 최대 종목 수(`sleeve_a.max_per_sector`).
  final int sleeveAMaxPerSector;
}

/// 일간 판정의 보유 한 줄(공분산 행렬의 같은 차례).
class WarnHolding {
  /// 만든다.
  const WarnHolding({
    required this.symbol,
    required this.isSatellite,
    required this.weight,
  });

  /// 종목.
  final String symbol;

  /// 새틀라이트 슬리브인가.
  final bool isSatellite;

  /// 비중.
  final double weight;
}

/// 일간 경고 판정 결과.
class DailyWarnResult {
  /// 만든다.
  const DailyWarnResult({
    required this.triggered,
    required this.actions,
    required this.satelliteRcShareOfPortfolio,
    required this.satelliteInnerRcShares,
    required this.defensivePct,
    required this.kellyLimit,
    required this.riskyExposure,
    required this.usdExposurePct,
  });

  /// 발동 ID(오름차순).
  final List<String> triggered;

  /// 발동 ID → 조치.
  final Map<String, WarnAction> actions;

  /// SAF-202 몫 — 새틀라이트 RC 합 / 포트폴리오 위험.
  final double satelliteRcShareOfPortfolio;

  /// SAF-208 몫 — 새틀라이트 안 종목별 RC 비율(보유 차례 · 새틀 없음 = 빈 것).
  final Map<String, double> satelliteInnerRcShares;

  /// SAF-302 입력.
  final double defensivePct;

  /// SAF-305 하프 켈리 상한((μ − rf) / σ² × 비율).
  final double kellyLimit;

  /// SAF-305 입력(총 위험자산 익스포저).
  final double riskyExposure;

  /// SAF-307 입력.
  final double usdExposurePct;
}

/// 월간 경고 판정 결과.
class MonthlyWarnResult {
  /// 만든다.
  const MonthlyWarnResult({
    required this.triggered,
    required this.actions,
    required this.satelliteAllocPct,
    required this.ytdFinancialIncomeKrw,
  });

  /// 발동 ID(오름차순).
  final List<String> triggered;

  /// 발동 ID → 조치.
  final Map<String, WarnAction> actions;

  /// SAF-201 입력.
  final double satelliteAllocPct;

  /// SAF-306 입력(과세연도 누계 · 원).
  final Decimal ytdFinancialIncomeKrw;
}

/// 슬리브 A 후보 한 줄(`rank_stocks` 산출 — 랭크 오름차순이 위).
class SleeveACandidate {
  /// 만든다.
  const SleeveACandidate({
    required this.symbol,
    required this.rank,
    required this.sector,
  });

  /// 종목.
  final String symbol;

  /// 랭크(작을수록 위).
  final int rank;

  /// 섹터(null = [kUnknownSectorBucket]).
  final String? sector;
}

/// 리밸런싱 경고 판정 결과 — 선정 · 제외.
class SleeveASelection {
  /// 만든다.
  const SleeveASelection({
    required this.triggered,
    required this.actions,
    required this.selected,
    required this.excludedBySectorCap,
    required this.excludedByMaxPositions,
    required this.candidateCount,
  });

  /// 발동 ID(오름차순).
  final List<String> triggered;

  /// 발동 ID → 조치.
  final Map<String, WarnAction> actions;

  /// 선정(랭크 차례).
  final List<String> selected;

  /// SAF-205 로 제외(랭크 차례).
  final List<String> excludedBySectorCap;

  /// SAF-204 로 제외(랭크 차례).
  final List<String> excludedByMaxPositions;

  /// 후보 수.
  final int candidateCount;
}

void _finite(double v, String name) {
  if (!v.isFinite) throw RiskCheckUnavailable('경고 한도 입력이 수가 아님: $name');
}

List<String> _sorted(Iterable<String> ids) => ids.toList()..sort();

Map<String, WarnAction> _actionsOf(List<String> triggered) =>
    <String, WarnAction>{
      for (final String id in triggered) id: kWarnActions[id]!,
    };

/// `Σw` — 행 i 마다 j 차례로 더한다(참조 `_mv`).
List<double> _mv(List<List<double>> cov, List<double> w) {
  final List<double> out = <double>[];
  for (int i = 0; i < w.length; i++) {
    double s = 0;
    for (int j = 0; j < w.length; j++) {
      s += cov[i][j] * w[j];
    }
    out.add(s);
  }
  return out;
}

/// `wᵀΣw`(참조와 같은 차례).
double _quadratic(List<double> w, List<double> sw) {
  double qf = 0;
  for (int i = 0; i < w.length; i++) {
    qf += w[i] * sw[i];
  }
  return qf;
}

/// 04 §1 일간 경고(SAF-202 · 208 · 302 · 305 · 307) — 참조 `gv40a_daily`.
///
/// [covariance] 는 [holdings] 와 같은 차례의 정사각 행렬이다. 판정할 수 없으면 [RiskCheckUnavailable].
DailyWarnResult judgeDailyWarnLimits({
  required List<WarnHolding> holdings,
  required List<List<double>> covariance,
  required double defensivePct,
  required double usdExposurePct,
  required double riskyExposure,
  required double meanReturn,
  required double riskFree,
  required double variance,
  required WarnLimitConfig config,
}) {
  final int n = holdings.length;
  if (n == 0) throw const RiskCheckUnavailable('경고 한도 — 보유 없음');
  if (covariance.length != n ||
      covariance.any((List<double> row) => row.length != n)) {
    throw const RiskCheckUnavailable('경고 한도 — 공분산 행렬 꼴이 보유와 다름');
  }
  for (final WarnHolding h in holdings) {
    _finite(h.weight, 'weight(${h.symbol})');
  }
  for (final List<double> row in covariance) {
    for (final double v in row) {
      _finite(v, 'covariance');
    }
  }
  for (final (String name, double v) in <(String, double)>[
    ('defensive_pct', defensivePct),
    ('usd_exposure_pct', usdExposurePct),
    ('risky_exposure', riskyExposure),
    ('mean_return', meanReturn),
    ('risk_free', riskFree),
    ('variance', variance),
  ]) {
    _finite(v, name);
  }

  final List<String> triggered = <String>[];
  final List<double> w = <double>[
    for (final WarnHolding h in holdings) h.weight,
  ];

  // SAF-202 — 새틀라이트 RC 합 / 포트폴리오 위험(분모 = 전체 wᵀΣw · 나눗셈은 마지막 한 번).
  final List<double> sw = _mv(covariance, w);
  final double qf = _quadratic(w, sw);
  if (!(qf > 0)) {
    throw const RiskCheckUnavailable('경고 한도 — 포트폴리오 분산이 0 이하');
  }
  final List<int> satIdx = <int>[
    for (int i = 0; i < n; i++)
      if (holdings[i].isSatellite) i,
  ];
  double satNumerator = 0;
  for (final int i in satIdx) {
    satNumerator += w[i] * sw[i];
  }
  final double satShare = satNumerator / qf;
  if (satShare > config.satelliteRcMax) {
    triggered.add(WarnLimitIds.satelliteRc);
  }

  // SAF-208 — 🔴 분모 = 새틀라이트 위험(새틀 부분 공분산의 오일러 분해 · 05 대기 ① 참조 생성기 판).
  final Map<String, double> inner = <String, double>{};
  if (satIdx.any((int i) => w[i] != 0)) {
    final List<double> subW = <double>[for (final int i in satIdx) w[i]];
    final List<List<double>> subCov = <List<double>>[
      for (final int i in satIdx)
        <double>[for (final int j in satIdx) covariance[i][j]],
    ];
    final List<double> subSw = _mv(subCov, subW);
    final double subQf = _quadratic(subW, subSw);
    if (!(subQf > 0)) {
      throw const RiskCheckUnavailable('경고 한도 — 새틀라이트 분산이 0 이하');
    }
    for (int k = 0; k < satIdx.length; k++) {
      inner[holdings[satIdx[k]].symbol] = subW[k] * subSw[k] / subQf;
    }
    if (inner.values.any((double s) => s > config.singleRcMax)) {
      triggered.add(WarnLimitIds.singleRc);
    }
  }

  // SAF-302 — 하한 포함(== 통과).
  if (defensivePct < config.minDefensivePct) {
    triggered.add(WarnLimitIds.defensiveFloor);
  }

  // SAF-305 — 03 §3-6: (μ − rf) / σ² × 비율 · 엄격 초과만.
  if (!(variance > 0)) {
    throw const RiskCheckUnavailable('경고 한도 — 켈리 분산이 0 이하');
  }
  final double kellyLimit =
      (meanReturn - riskFree) / variance * config.kellyFraction;
  if (riskyExposure > kellyLimit) {
    triggered.add(WarnLimitIds.halfKelly);
  }

  // SAF-307 — 상한 포함(== 통과).
  if (usdExposurePct > config.maxUsdExposurePct) {
    triggered.add(WarnLimitIds.usdExposure);
  }

  final List<String> ids = _sorted(triggered);
  return DailyWarnResult(
    triggered: List<String>.unmodifiable(ids),
    actions: Map<String, WarnAction>.unmodifiable(_actionsOf(ids)),
    satelliteRcShareOfPortfolio: satShare,
    satelliteInnerRcShares: Map<String, double>.unmodifiable(inner),
    defensivePct: defensivePct,
    kellyLimit: kellyLimit,
    riskyExposure: riskyExposure,
    usdExposurePct: usdExposurePct,
  );
}

/// 🆕 E3d-3 — SAF-306 판정 한 줄(상한 포함 · == 통과). [judgeMonthlyWarnLimits](GV-40b)와 P0S 월간 단계가 같이 쓴다
/// (P0S 는 201 · 202 · 204 · 205 · 208 이 해당 없어 [WarnLimitConfig] 전체를 지을 수 없다 — 판정식을 둘로 만들지 않는다).
bool financialIncomeCapExceeded(Decimal ytdKrw, Decimal capKrw) =>
    ytdKrw > capKrw;

/// 04 §1 월간 경고(SAF-201 · 306) — 참조 `gv40b_monthly`. 밴드 양끝 · 소득 상한 포함(== 통과).
MonthlyWarnResult judgeMonthlyWarnLimits({
  required double satelliteAllocPct,
  required Decimal ytdFinancialIncomeKrw,
  required WarnLimitConfig config,
}) {
  _finite(satelliteAllocPct, 'satellite_alloc_pct');
  final List<String> triggered = <String>[];
  if (satelliteAllocPct < config.satelliteBandLow ||
      satelliteAllocPct > config.satelliteBandHigh) {
    triggered.add(WarnLimitIds.satelliteBand);
  }
  if (financialIncomeCapExceeded(
    ytdFinancialIncomeKrw,
    config.annualFinancialIncomeCapKrw,
  )) {
    triggered.add(WarnLimitIds.financialIncomeCap);
  }
  final List<String> ids = _sorted(triggered);
  return MonthlyWarnResult(
    triggered: List<String>.unmodifiable(ids),
    actions: Map<String, WarnAction>.unmodifiable(_actionsOf(ids)),
    satelliteAllocPct: satelliteAllocPct,
    ytdFinancialIncomeKrw: ytdFinancialIncomeKrw,
  );
}

/// 04 §1 리밸런싱 경고(SAF-204 · 205) — 참조 `gv40c_rebalance`.
///
/// 🔴 205 먼저(같은 섹터 안 랭크 아래부터 제외 · [kUnknownSectorBucket] 은 면제) → 204(남은 것의 랭크 위 N 개).
/// 랭크가 같으면 들어온 차례(참조 `sorted` 는 안정 정렬).
SleeveASelection judgeRebalanceWarnLimits(
  List<SleeveACandidate> candidates, {
  required WarnLimitConfig config,
}) {
  final List<(int, SleeveACandidate)> ranked =
      <(int, SleeveACandidate)>[
        for (int i = 0; i < candidates.length; i++) (i, candidates[i]),
      ]..sort(((int, SleeveACandidate) a, (int, SleeveACandidate) b) {
        final int byRank = a.$2.rank.compareTo(b.$2.rank);
        return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
      });

  final Map<String, int> perSector = <String, int>{};
  final List<String> keep = <String>[];
  final List<String> excluded205 = <String>[];
  for (final (int _, SleeveACandidate c) in ranked) {
    final String bucket = c.sector ?? kUnknownSectorBucket;
    final int count = perSector[bucket] ?? 0;
    if (bucket != kUnknownSectorBucket && count >= config.sleeveAMaxPerSector) {
      excluded205.add(c.symbol);
    } else {
      keep.add(c.symbol);
    }
    perSector[bucket] = count + 1;
  }
  final int cut = keep.length < config.sleeveAMaxPositions
      ? keep.length
      : config.sleeveAMaxPositions;
  final List<String> selected = keep.sublist(0, cut);
  final List<String> excluded204 = keep.sublist(cut);

  final List<String> triggered = <String>[
    if (excluded204.isNotEmpty) WarnLimitIds.sleeveAMaxPositions,
    if (excluded205.isNotEmpty) WarnLimitIds.sleeveASectorCap,
  ];
  final List<String> ids = _sorted(triggered);
  return SleeveASelection(
    triggered: List<String>.unmodifiable(ids),
    actions: Map<String, WarnAction>.unmodifiable(_actionsOf(ids)),
    selected: List<String>.unmodifiable(selected),
    excludedBySectorCap: List<String>.unmodifiable(excluded205),
    excludedByMaxPositions: List<String>.unmodifiable(excluded204),
    candidateCount: candidates.length,
  );
}
