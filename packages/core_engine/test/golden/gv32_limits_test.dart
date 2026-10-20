// GV-32 리스크 한도 + 동시 발동 우선순위(AC-S17 · 안전 게이트) · GV-39 P2 검사 순서 trace(AC-B27)
// · GV-17 입력 누락 fail-closed(AC-S14) — 04 §1 · §1-5.
//
// 정답지(vectors/SOURCES.md): 파일럿4 `saf_vectors.json` 통째 · 파일럿5 `gv39_vectors.json` 통째 ·
// 05 §GV-17 블록 원문. 🔴 GV-32 의 비교는 `violated` 를 정렬한 뒤(05 §GV-32) — 엔진이 이미 정렬해 준다.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';
import 'saf_limits_fixture.dart';

void main() {
  final Map<String, Object?> saf = loadVector('gv32_saf_vectors.json');
  final Map<String, Object?> safMeta = asObject(saf['_meta']);
  final LimitConfig config = configFrom(asObject(safMeta['cfg_risk']));

  /// 한 케이스를 돌려 기대값과 맞춘다. [checkTrace] 면 GV-39 trace 도 본다.
  void runCase(
    Map<String, Object?> meta,
    Map<String, Object?> c, {
    required bool checkTrace,
  }) {
    final LimitIntent intent = intentFrom(
      overlay(asObject(meta['base_intent']), asObject(c['intent'])),
    );
    final LimitState state = stateFrom(
      overlay(asObject(meta['base_state']), asObject(c['state'])),
    );
    final Map<String, Object?> e = asObject(c['expected']);
    final List<String> trace = <String>[];

    if (e['raises'] == 'RiskCheckUnavailable') {
      expect(
        () => checkAllLimits(intent, state, config, trace: trace),
        throwsA(isA<RiskCheckUnavailable>()),
      );
    } else {
      expect(e['raises'], isNull);
      final LimitCheckResult r = checkAllLimits(
        intent,
        state,
        config,
        trace: trace,
      );
      expect(r.status.code, asString(e['status']));
      expect(r.allowed, e['allowed']);
      expect(r.violated, asStringList(e['violated']));
      expect(
        r.adjustedQuantity,
        e['adjusted_qty'] == null ? isNull : asInt(e['adjusted_qty']),
      );
    }
    if (checkTrace) expect(trace, asStringList(e['trace']));
  }

  group('GV-32 한도 판정 · P1~P6 (63)', () {
    for (final Map<String, Object?> c in asObjectList(saf['cases'])) {
      test('${asString(c['id'])} — ${c['note'] ?? ''}', () {
        runCase(safMeta, c, checkTrace: false);
      });
    }
  });

  group('GV-39 P2 검사 순서 trace (15)', () {
    final Map<String, Object?> gv39 = loadVector('gv39_trace_vectors.json');
    final Map<String, Object?> meta = asObject(gv39['_meta']);
    test('정본 순서(L4 → L3 → L2 → L1)를 이어 붙이면 기준선 g00 의 전수 trace 와 같다', () {
      final Map<String, Object?> order = asObject(meta['canonical_order']);
      final List<String> joined = <String>[
        for (final String level in <String>['4', '3', '2', '1'])
          ...asStringList(order[level]),
      ];
      final Map<String, Object?> g00 = asObjectList(gv39['cases']).firstWhere(
        (Map<String, Object?> c) => c['id'] == 'g00_full_scan_baseline',
      );
      expect(joined, hasLength(18));
      expect(joined, asStringList(asObject(g00['expected'])['trace']));
    });
    for (final Map<String, Object?> c in asObjectList(gv39['cases'])) {
      test('${asString(c['id'])} — ${c['note'] ?? ''}', () {
        runCase(meta, c, checkTrace: true);
      });
    }
  });

  group('GV-17 입력 누락은 fail-closed (05 v1.6 블록 — GV-32 상태 이름으로 옮겨 읽음)', () {
    // 🔵 05 GV-17 은 v1.6 상태 모델이다. 이름 대응: orders_today · daily_pnl_pct · fx_rate_usdkrw 는 같고,
    //    reconcile_blocked → trading_blocked(SAF-407). base_cfg.max_orders_per_day 20 을 그대로 쓴다.
    // ⚠️ x3(usd_exposure_pct = null → 거부)은 v2.30 이 SAF-307 을 «한도 없음 — 계측만»으로 바꿔 판정
    //    입력이 아니게 됐다 — 시험하지 않는다(설계 13 §8 R11).
    final Map<String, Object?> gv17 = loadVector('gv17_fail_closed.json');
    final Map<String, Object?> base17 = asObject(gv17['base_state']);
    final LimitConfig config17 = LimitConfig(
      maxNotionalPct: config.maxNotionalPct,
      riskBudgetPct: config.riskBudgetPct,
      satelliteMaxPositions: config.satelliteMaxPositions,
      satelliteMaxPerSector: config.satelliteMaxPerSector,
      maxRiskExposure: config.maxRiskExposure,
      maxLeverage: config.maxLeverage,
      maxPositions: config.maxPositions,
      maxOrdersPerDay: asInt(asObject(gv17['base_cfg'])['max_orders_per_day']),
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

    for (final Map<String, Object?> c in asObjectList(gv17['cases'])) {
      final String id = asString(c['id']);
      if (id == 'x3') continue; // 위 ⚠️
      test('GV-17 $id', () {
        final Map<String, Object?> baseState = overlay(
          asObject(safMeta['base_state']),
          rename(base17),
        );
        final LimitState state = stateFrom(
          overlay(baseState, rename(asObject(c['override']))),
        );
        final LimitIntent intent = intentFrom(
          overlay(asObject(safMeta['base_intent']), <String, Object?>{
            ...asObject(c['intent'] ?? <String, Object?>{}),
            // US 로 바꾸면 단가도 US 기준선(05 GV-32 s00_pass_us)으로 맞춘다.
            if (asObject(c['intent'] ?? <String, Object?>{})['market'] ==
                'US') ...<String, Object?>{
              'limit_price': 100.0,
              'entry_price': 100.0,
              'stop_price': 95.0,
              'quantity': 50,
            },
          }),
        );
        final Map<String, Object?> e = asObject(c['expected']);
        if (e['raises'] == 'RiskCheckUnavailable') {
          expect(
            () => checkAllLimits(intent, state, config17),
            throwsA(isA<RiskCheckUnavailable>()),
          );
        } else {
          final LimitCheckResult r = checkAllLimits(intent, state, config17);
          expect(r.allowed, e['allowed']);
          expect(r.violated, asStringList(e['violated']));
        }
      });
    }
  });
}
