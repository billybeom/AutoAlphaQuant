// 골든벡터 GV-32 리스크 한도 + 동시 발동 우선순위(AC-S17 · 안전 게이트) · GV-39 P2 검사 순서 trace(AC-B27)
// · GV-17 입력 누락 fail-closed(AC-S14) 판정(E11o-c1 · 설계 13 §8 R164) — 04 §1 · §1-5.
//
// 🔴 옛 시험(`test/golden/gv32_limits_test.dart`)과 받침(`saf_limits_fixture.dart`)의 판정 · 읽기를 한 글자도 바꾸지 않고
//    옮겼다(시험 = 폰 같은 판정 · 두 벌 0). 🔴 GV-32 의 비교는 `violated` 를 정렬한 뒤(05 §GV-32) — 엔진이 이미 정렬해 준다.

import 'package:decimal/decimal.dart';

import '../risk/limits.dart'
    show
        InstrumentKind,
        LimitCheckResult,
        LimitConfig,
        LimitIntent,
        LimitSide,
        LimitState,
        RiskCheckUnavailable,
        checkAllLimits;
import 'golden_runner.dart';

// ── 정답지 `base_intent` · `base_state` · `cfg_risk` → 엔진 타입(옛 saf_limits_fixture.dart) ──

Decimal? _decOrNull(Object? v) => v == null ? null : gvDecimal(v);
double? _dblOrNull(Object? v) => v == null ? null : gvDouble(v);
int? _intOrNull(Object? v) => v == null ? null : gvInt(v);
bool? _boolOrNull(Object? v) {
  if (v == null) return null;
  if (v is bool) return v;
  throw FormatException('정답지에서 참·거짓을 기대했다', v);
}

/// 기준 객체 위에 케이스 덮어쓰기를 얹는다(JSON null 도 «값을 지운다»로 덮어쓴다).
Map<String, Object?> _overlay(
  Map<String, Object?> base,
  Map<String, Object?> override,
) => <String, Object?>{...base, ...override};

LimitIntent _intentFrom(Map<String, Object?> j) => LimitIntent(
  side: switch (gvString(j['side'])) {
    'BUY' => LimitSide.buy,
    'SELL' => LimitSide.sell,
    final String s => throw FormatException('모르는 side: $s'),
  },
  isUsMarket: gvString(j['market']) == 'US',
  orderType: gvString(j['order_type']),
  quantity: gvInt(j['quantity']),
  limitPrice: _decOrNull(j['limit_price']),
  entryPrice: _decOrNull(j['entry_price']),
  stopPrice: _decOrNull(j['stop_price']),
  isSatellite: gvString(j['sleeve']) == 'satellite',
  // v2.38(GV-39 17) — 칸이 없으면 개별주(04 §1 «비면 STOCK»). GV-32 63 에는 칸이 없다.
  instrument: switch (j['instrument']) {
    null || 'STOCK' => InstrumentKind.stock,
    'ETF' => InstrumentKind.etf,
    final Object? s => throw FormatException('모르는 instrument: $s'),
  },
);

LimitState _stateFrom(Map<String, Object?> j) => LimitState(
  totalEquity: _decOrNull(j['total_equity']),
  ordersToday: _intOrNull(j['orders_today']),
  riskExposureAfter: _dblOrNull(j['risk_exposure_after']),
  leverageAfter: _dblOrNull(j['leverage_after']),
  positionsAfter: _intOrNull(j['positions_after']),
  satellitePositionsAfter: _intOrNull(j['satellite_positions_after']),
  satelliteSectorCountAfter: _intOrNull(j['satellite_sector_count_after']),
  satelliteAllocation: _decOrNull(j['satellite_allocation']),
  satelliteExposure: _dblOrNull(j['satellite_exposure']),
  satelliteDeployedBefore: _decOrNull(j['satellite_deployed_before']),
  dailyPnlPct: _dblOrNull(j['daily_pnl_pct']),
  fxRateUsdKrw: _decOrNull(j['fx_rate_usdkrw']),
  strategyRegistered: _boolOrNull(j['strategy_registered']),
  tradingBlocked: _boolOrNull(j['trading_blocked']),
  journalMissing: _boolOrNull(j['journal_missing']),
  tierBUnjudged: _boolOrNull(j['tier_b_unjudged']),
);

/// GV-32 `_meta.cfg_risk` → [LimitConfig]. GV-39 는 «파일럿4 와 동일» 기본값이라 같은 값을 쓴다.
LimitConfig _configFrom(Map<String, Object?> cfgRisk) {
  final Map<String, Object?> position = gvObject(cfgRisk['position']);
  final Map<String, Object?> sleeve = gvObject(cfgRisk['sleeve']);
  final Map<String, Object?> portfolio = gvObject(cfgRisk['portfolio']);
  final Map<String, Object?> system = gvObject(cfgRisk['system']);
  return LimitConfig(
    maxNotionalPct: gvDouble(position['max_notional_pct']),
    riskBudgetPct: gvDouble(position['risk_budget_pct']),
    satelliteMaxPositions: gvInt(sleeve['satellite_max_positions']),
    satelliteMaxPerSector: gvInt(sleeve['satellite_max_per_sector']),
    maxRiskExposure: gvDouble(portfolio['max_risk_exposure']),
    maxLeverage: gvDouble(portfolio['max_leverage']),
    maxPositions: gvInt(portfolio['max_positions']),
    maxOrdersPerDay: gvInt(system['max_orders_per_day']),
    maxOrderValueKrw: gvDecimal(system['max_order_value_krw']),
    maxDailyLossPct: gvDouble(system['max_daily_loss_pct']),
    orderTypeWhitelist: gvStringList(system['order_type_whitelist']).toSet(),
  );
}

/// 한 케이스를 돌려 기대값과 맞춘다 — [checkTrace] 면 GV-39 trace 도 본다.
String? _runCase(
  Map<String, Object?> meta,
  Map<String, Object?> c,
  LimitConfig config, {
  required bool checkTrace,
}) {
  final LimitIntent intent = _intentFrom(
    _overlay(gvObject(meta['base_intent']), gvObject(c['intent'])),
  );
  final LimitState state = _stateFrom(
    _overlay(gvObject(meta['base_state']), gvObject(c['state'])),
  );
  final Map<String, Object?> e = gvObject(c['expected']);
  final List<String> trace = <String>[];
  final GvProbe p = GvProbe();
  if (e['raises'] == 'RiskCheckUnavailable') {
    p.throws(
      () => checkAllLimits(intent, state, config, trace: trace),
      (Object x) => x is RiskCheckUnavailable,
      'RiskCheckUnavailable',
    );
  } else {
    p.none(e['raises'], 'raises');
    final LimitCheckResult r = checkAllLimits(
      intent,
      state,
      config,
      trace: trace,
    );
    p
      ..same(r.status.code, gvString(e['status']), 'status')
      ..same(r.allowed, e['allowed'], 'allowed')
      ..same(r.violated, gvStringList(e['violated']), 'violated')
      ..same(
        r.adjustedQuantity,
        e['adjusted_qty'] == null ? null : gvInt(e['adjusted_qty']),
        'adjusted_qty',
      );
  }
  if (checkTrace) p.same(trace, gvStringList(e['trace']), 'trace');
  return p.failure;
}

/// GV-32 한도 판정 P1~P6(63) · GV-39 P2 검사 순서 trace(17 · v2.38) · GV-17 입력 누락 fail-closed.
///
/// 정답지 = 파일럿4 `saf_vectors.json` 통째 · 파일럿5 `gv39_vectors.json` 통째 · 05 §GV-17 블록 원문.
class Gv32Limits implements GoldenFamily {
  /// 만든다.
  const Gv32Limits();

  @override
  String get id => 'GV-32';

  @override
  Set<String> get files => const <String>{
    'gv32_saf_vectors.json',
    'gv39_trace_vectors.json',
    'gv17_fail_closed.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> saf = b.json('gv32_saf_vectors.json');
    final Map<String, Object?> safMeta = gvObject(saf['_meta']);
    final LimitConfig config = _configFrom(gvObject(safMeta['cfg_risk']));

    final Map<String, Object?> gv39 = b.json('gv39_trace_vectors.json');
    final Map<String, Object?> meta39 = gvObject(gv39['_meta']);

    // GV-17 — 05 v1.6 상태 모델 · 이름 대응: orders_today · daily_pnl_pct · fx_rate_usdkrw 는 같고,
    // reconcile_blocked → trading_blocked(SAF-407). base_cfg.max_orders_per_day 20 을 그대로 쓴다.
    // ⚠️ x3(usd_exposure_pct = null → 거부)은 v2.30 이 SAF-307 을 «한도 없음 — 계측만»으로 바꿔 판정 입력이 아니게 됐다
    //    — 판정하지 않는다(설계 13 §8 R11).
    final Map<String, Object?> gv17 = b.json('gv17_fail_closed.json');
    final Map<String, Object?> base17 = gvObject(gv17['base_state']);
    final LimitConfig config17 = LimitConfig(
      maxNotionalPct: config.maxNotionalPct,
      riskBudgetPct: config.riskBudgetPct,
      satelliteMaxPositions: config.satelliteMaxPositions,
      satelliteMaxPerSector: config.satelliteMaxPerSector,
      maxRiskExposure: config.maxRiskExposure,
      maxLeverage: config.maxLeverage,
      maxPositions: config.maxPositions,
      maxOrdersPerDay: gvInt(gvObject(gv17['base_cfg'])['max_orders_per_day']),
      maxOrderValueKrw: config.maxOrderValueKrw,
      maxDailyLossPct: config.maxDailyLossPct,
      orderTypeWhitelist: config.orderTypeWhitelist,
    );
    Map<String, Object?> rename(Map<String, Object?> m) => <String, Object?>{
      for (final MapEntry<String, Object?> e in m.entries)
        if (e.key == 'reconcile_blocked')
          'trading_blocked': e.value
        else if (const <String>{
          'orders_today',
          'daily_pnl_pct',
          'fx_rate_usdkrw',
        }.contains(e.key))
          e.key: e.value,
    };

    return <GvCase>[
      for (final Map<String, Object?> c in gvObjectList(saf['cases']))
        GvCase(
          'GV-32 ${gvString(c['id'])} — ${c['note'] ?? ''}',
          () => _runCase(safMeta, c, config, checkTrace: false),
        ),
      GvCase('GV-39 정본 순서(L4 → L3 → L2 → L1) = 기준선 g00 전수 trace', () {
        final Map<String, Object?> order = gvObject(meta39['canonical_order']);
        final List<String> joined = <String>[
          for (final String level in <String>['4', '3', '2', '1'])
            ...gvStringList(order[level]),
        ];
        final Map<String, Object?> g00 = gvObjectList(gv39['cases']).firstWhere(
          (Map<String, Object?> c) => c['id'] == 'g00_full_scan_baseline',
          orElse: () => throw const FormatException('기준선 g00 이 없다'),
        );
        return (GvProbe()
              ..same(joined.length, 18, '길이')
              ..same(
                joined,
                gvStringList(gvObject(g00['expected'])['trace']),
                'trace',
              ))
            .failure;
      }),
      for (final Map<String, Object?> c in gvObjectList(gv39['cases']))
        GvCase(
          'GV-39 ${gvString(c['id'])} — ${c['note'] ?? ''}',
          () => _runCase(meta39, c, config, checkTrace: true),
        ),
      for (final Map<String, Object?> c in gvObjectList(gv17['cases']))
        if (gvString(c['id']) != 'x3') // 위 ⚠️
          GvCase('GV-17 ${gvString(c['id'])}', () {
            final Map<String, Object?> baseState = _overlay(
              gvObject(safMeta['base_state']),
              rename(base17),
            );
            final LimitState state = _stateFrom(
              _overlay(baseState, rename(gvObject(c['override']))),
            );
            final Map<String, Object?> intentOverride = gvObject(
              c['intent'] ?? <String, Object?>{},
            );
            final LimitIntent intent = _intentFrom(
              _overlay(gvObject(safMeta['base_intent']), <String, Object?>{
                ...intentOverride,
                // US 로 바꾸면 단가도 US 기준선(05 GV-32 s00_pass_us)으로 맞춘다.
                if (intentOverride['market'] == 'US') ...<String, Object?>{
                  'limit_price': 100.0,
                  'entry_price': 100.0,
                  'stop_price': 95.0,
                  'quantity': 50,
                },
              }),
            );
            final Map<String, Object?> e = gvObject(c['expected']);
            if (e['raises'] == 'RiskCheckUnavailable') {
              return (GvProbe()..throws(
                    () => checkAllLimits(intent, state, config17),
                    (Object x) => x is RiskCheckUnavailable,
                    'RiskCheckUnavailable',
                  ))
                  .failure;
            }
            final LimitCheckResult r = checkAllLimits(intent, state, config17);
            return (GvProbe()
                  ..same(r.allowed, e['allowed'], 'allowed')
                  ..same(r.violated, gvStringList(e['violated']), 'violated'))
                .failure;
          }),
    ];
  }
}
