// 골든벡터 GV-40a 일간 · GV-40b 월간 · GV-40c 리밸런싱 경고 한도 — AC-B28 27건 판정
// (E3c · 설계 13 §8 R166 · 04 §1 v2.23 블록 · 05 §«v1.14 5차 파일럿 신설 벡터» GV-40 행).
//
// 🔴 한 정본(E11o · R161) — 시험(`test/golden/gv40abc_warn_limits_test.dart`)과 폰이 같은 케이스를 돈다.
// 정답지 = gv40_saf_warn.json(파일럿5 원본 통째 · d · e 몫은 `gv_gates.dart`). 판정은 엔진 `risk/warn_limits.dart`.
// 🔵 문턱 = [_kSaf04] — 정답지를 구운 생성기 `gv40_gen_vectors.py` 의 상수(04 §1 표 · 02 §4 config 값) 그대로. 정답지에 설정이
//    실려 있지 않아 여기 적는다(새 수치 0). 🔵 비교 = 생성기 `differs` 규칙 — 행동(발동 · 조치 · 선정)은 같아야 하고
//    산출 근거 수치(metrics)는 1e-9 안 · 칸 이름 묶음도 같아야 한다.

import 'package:decimal/decimal.dart';

import '../risk/warn_limits.dart';
import 'golden_runner.dart';

const double _kTol = 1e-9;

/// 생성기 상수(RC_SLEEVE_MAX · RC_SINGLE_MAX · DEFENSIVE_MIN · kelly_fraction 기본 · USD_MAX · BAND_LOW/HIGH ·
/// INCOME_CAP_KRW · SLEEVE_A_MAX_N · SECTOR_MAX_A).
final WarnLimitConfig _kSaf04 = WarnLimitConfig(
  satelliteRcMax: 0.40,
  singleRcMax: 0.30,
  minDefensivePct: 0.10,
  kellyFraction: 0.5,
  maxUsdExposurePct: 0.50,
  satelliteBandLow: 0.15,
  satelliteBandHigh: 0.21,
  annualFinancialIncomeCapKrw: Decimal.fromInt(20000000),
  sleeveAMaxPositions: 20,
  sleeveAMaxPerSector: 4,
);

/// 조치 → 정답지 글자(04 §1 표 «위반 시» 열 · 생성기 ACT_*).
String _actionText(WarnAction a) => switch (a) {
  WarnAction.warnNextRebalance => '경고+다음 리밸런싱에 반영',
  WarnAction.warn => '경고',
  WarnAction.record => '기록만(P2)',
  WarnAction.rebalance => '리밸런싱',
  WarnAction.topN => '상위 20개만',
  WarnAction.dropExcess => '초과분 제외',
};

Map<String, String> _actionTexts(Map<String, WarnAction> actions) =>
    <String, String>{
      for (final MapEntry<String, WarnAction> e in actions.entries)
        e.key: _actionText(e.value),
    };

Map<String, String> _expectedActions(Object? value) => <String, String>{
  for (final MapEntry<String, Object?> e in gvObject(value).entries)
    e.key: gvString(e.value),
};

List<String> _ids(List<Map<String, Object?>> cases) => <String>[
  for (final Map<String, Object?> c in cases)
    gvString(c['id']).split(' ').first,
];

GvCase _countCase(
  String id,
  List<Map<String, Object?>> cases,
  List<String> want,
) => GvCase(
  '$id = ${want.length}건(${want.first}~${want.last})',
  () => (GvProbe()..same(_ids(cases), want, 'ids')).failure,
);

List<List<double>> _matrix(Object? value) {
  if (value is List<Object?>) {
    return <List<double>>[
      for (final Object? row in value)
        gvNumList(row).map((double? v) {
          if (v == null) throw const FormatException('공분산에 결측');
          return v;
        }).toList(),
    ];
  }
  throw FormatException('정답지에서 행렬을 기대했다', value);
}

/// GV-40a 일간 a01~a12(SAF-202 · 208 · 302 · 305 · 307).
class Gv40aDailyWarn implements GoldenFamily {
  /// 만든다.
  const Gv40aDailyWarn();

  @override
  String get id => 'GV-40a';

  @override
  Set<String> get files => const <String>{'gv40_saf_warn.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    final List<Map<String, Object?>> cases = gvObjectList(
      b.json('gv40_saf_warn.json')['GV-40a'],
    );
    return <GvCase>[
      _countCase('GV-40a', cases, <String>[
        for (int i = 1; i <= 12; i++) 'a${i.toString().padLeft(2, '0')}',
      ]),
      for (final Map<String, Object?> c in cases)
        GvCase('GV-40a ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Map<String, Object?> exp = gvObject(c['expected']);
          final List<String> symbols = gvStringList(input['symbols']);
          final Map<String, Object?> sleeves = gvObject(input['sleeves']);
          final List<double?> weights = gvNumList(input['weights']);
          if (weights.length != symbols.length || weights.contains(null)) {
            throw const FormatException('비중 꼴이 종목과 다름');
          }
          final DailyWarnResult r = judgeDailyWarnLimits(
            holdings: <WarnHolding>[
              for (int i = 0; i < symbols.length; i++)
                WarnHolding(
                  symbol: symbols[i],
                  isSatellite: gvString(sleeves[symbols[i]]) == 'satellite',
                  weight: weights[i]!,
                ),
            ],
            covariance: _matrix(input['cov']),
            defensivePct: gvDouble(input['defensive_pct']),
            usdExposurePct: gvDouble(input['usd_exposure_pct']),
            riskyExposure: gvDouble(input['risky_exposure']),
            meanReturn: gvDouble(input['mean_return']),
            riskFree: gvDouble(input['risk_free']),
            variance: gvDouble(input['variance']),
            config: _kSaf04,
          );
          final Map<String, Object?> m = gvObject(exp['metrics']);
          final Map<String, Object?> inner = gvObject(m['sat_inner_rc_shares']);
          final GvProbe p = GvProbe()
            ..same(exp.keys.toSet(), <String>{
              'triggered',
              'actions',
              'metrics',
            }, '칸')
            ..same(r.triggered, gvStringList(exp['triggered']), 'triggered')
            ..same(
              _actionTexts(r.actions),
              _expectedActions(exp['actions']),
              'actions',
            )
            ..same(m.keys.toSet(), <String>{
              'sat_rc_share_of_portfolio',
              'sat_inner_rc_shares',
              'defensive_pct',
              'kelly_limit',
              'risky_exposure',
              'usd_exposure_pct',
            }, 'metrics 칸')
            ..close(
              r.satelliteRcShareOfPortfolio,
              gvDouble(m['sat_rc_share_of_portfolio']),
              _kTol,
              'sat_rc_share_of_portfolio',
            )
            ..same(
              r.satelliteInnerRcShares.keys.toList(),
              inner.keys.toList(),
              'sat_inner_rc_shares 종목',
            );
          for (final MapEntry<String, Object?> e in inner.entries) {
            p.close(
              r.satelliteInnerRcShares[e.key],
              gvDouble(e.value),
              _kTol,
              'sat_inner_rc_shares[${e.key}]',
            );
          }
          return (p
                ..close(
                  r.defensivePct,
                  gvDouble(m['defensive_pct']),
                  _kTol,
                  'defensive_pct',
                )
                ..close(
                  r.kellyLimit,
                  gvDouble(m['kelly_limit']),
                  _kTol,
                  'kelly_limit',
                )
                ..close(
                  r.riskyExposure,
                  gvDouble(m['risky_exposure']),
                  _kTol,
                  'risky_exposure',
                )
                ..close(
                  r.usdExposurePct,
                  gvDouble(m['usd_exposure_pct']),
                  _kTol,
                  'usd_exposure_pct',
                ))
              .failure;
        }),
    ];
  }
}

/// GV-40b 월간 b1~b8(SAF-201 · 306).
class Gv40bMonthlyWarn implements GoldenFamily {
  /// 만든다.
  const Gv40bMonthlyWarn();

  @override
  String get id => 'GV-40b';

  @override
  Set<String> get files => const <String>{'gv40_saf_warn.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    final List<Map<String, Object?>> cases = gvObjectList(
      b.json('gv40_saf_warn.json')['GV-40b'],
    );
    return <GvCase>[
      _countCase('GV-40b', cases, <String>[for (int i = 1; i <= 8; i++) 'b$i']),
      for (final Map<String, Object?> c in cases)
        GvCase('GV-40b ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Map<String, Object?> exp = gvObject(c['expected']);
          final MonthlyWarnResult r = judgeMonthlyWarnLimits(
            satelliteAllocPct: gvDouble(input['satellite_alloc_pct']),
            ytdFinancialIncomeKrw: gvDecimal(input['ytd_financial_income_krw']),
            config: _kSaf04,
          );
          final Map<String, Object?> m = gvObject(exp['metrics']);
          return (GvProbe()
                ..same(exp.keys.toSet(), <String>{
                  'triggered',
                  'actions',
                  'metrics',
                }, '칸')
                ..same(r.triggered, gvStringList(exp['triggered']), 'triggered')
                ..same(
                  _actionTexts(r.actions),
                  _expectedActions(exp['actions']),
                  'actions',
                )
                ..same(m.keys.toSet(), <String>{
                  'satellite_alloc_pct',
                  'ytd_financial_income_krw',
                }, 'metrics 칸')
                ..close(
                  r.satelliteAllocPct,
                  gvDouble(m['satellite_alloc_pct']),
                  _kTol,
                  'satellite_alloc_pct',
                )
                ..same(
                  r.ytdFinancialIncomeKrw,
                  gvDecimal(m['ytd_financial_income_krw']),
                  'ytd_financial_income_krw',
                ))
              .failure;
        }),
    ];
  }
}

/// GV-40c 리밸런싱 c1~c7(SAF-204 · 205 — 선정 · 제외 목록까지).
class Gv40cRebalanceWarn implements GoldenFamily {
  /// 만든다.
  const Gv40cRebalanceWarn();

  @override
  String get id => 'GV-40c';

  @override
  Set<String> get files => const <String>{'gv40_saf_warn.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    final List<Map<String, Object?>> cases = gvObjectList(
      b.json('gv40_saf_warn.json')['GV-40c'],
    );
    return <GvCase>[
      _countCase('GV-40c', cases, <String>[for (int i = 1; i <= 7; i++) 'c$i']),
      for (final Map<String, Object?> c in cases)
        GvCase('GV-40c ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Map<String, Object?> exp = gvObject(c['expected']);
          final Object? raw = input['candidates'];
          if (raw is! List<Object?>) {
            throw FormatException('정답지에서 후보 목록을 기대했다', raw);
          }
          final SleeveASelection r = judgeRebalanceWarnLimits(
            <SleeveACandidate>[
              for (final Object? row in raw)
                if (row is List<Object?> && row.length == 3)
                  SleeveACandidate(
                    symbol: gvString(row[0]),
                    rank: gvInt(row[1]),
                    sector: row[2] == null ? null : gvString(row[2]),
                  )
                else
                  throw FormatException('후보 한 줄은 [종목, 랭크, 섹터]', row),
            ],
            config: _kSaf04,
          );
          final Map<String, Object?> m = gvObject(exp['metrics']);
          return (GvProbe()
                ..same(exp.keys.toSet(), <String>{
                  'triggered',
                  'actions',
                  'selected',
                  'excluded_205',
                  'excluded_204',
                  'metrics',
                }, '칸')
                ..same(r.triggered, gvStringList(exp['triggered']), 'triggered')
                ..same(
                  _actionTexts(r.actions),
                  _expectedActions(exp['actions']),
                  'actions',
                )
                ..same(r.selected, gvStringList(exp['selected']), 'selected')
                ..same(
                  r.excludedBySectorCap,
                  gvStringList(exp['excluded_205']),
                  'excluded_205',
                )
                ..same(
                  r.excludedByMaxPositions,
                  gvStringList(exp['excluded_204']),
                  'excluded_204',
                )
                ..same(m.keys.toSet(), <String>{
                  'n_candidates',
                  'n_selected',
                }, 'metrics 칸')
                ..same(
                  r.candidateCount,
                  gvInt(m['n_candidates']),
                  'n_candidates',
                )
                ..same(r.selected.length, gvInt(m['n_selected']), 'n_selected'))
              .failure;
        }),
    ];
  }
}
