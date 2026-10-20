// GV-9 멱등키(05 §GV-9 · AC-B09) · GV-13 decision_id 형식 부분(05 §GV-13 · AC-S13) — 04 §3-2.
//
// 정답지 = 05 v1.22 본문 블록 원문(vectors/SOURCES.md).
// 🔵 GV-13 의 «submit_order 호출 횟수 · order_intents 행 수 · reserve_intent 결과»는 주문 의도 예약과
//    모의 브로커가 있어야 재는 값이라 주문 경로(E10)에서 시험한다. 여기서는 decision_id 문자열과
//    서로 다른 id·멱등키 개수만 본다.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

String _key(Map<String, Object?> input) => idempotencyKey(
  market: asString(input['market']),
  account: asString(input['account']),
  symbol: asString(input['symbol']),
  side: asString(input['side']),
  decisionId: asString(input['decision_id']),
);

void main() {
  group('GV-9 멱등키 — 원문 형식 · SHA-256', () {
    final Map<String, Object?> v = loadVector('gv09_idempotency_key.json');
    test('정확 일치 필드가 이 시험이 보는 둘(원문 · 키)이다', () {
      expect(asStringList(v['exact_fields']), <String>[
        'expected_raw',
        'expected_key',
      ]);
    });
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      final Map<String, Object?> input = asObject(c['input']);
      test(asString(c['expected_raw']), () {
        expect(
          idempotencyRaw(
            market: asString(input['market']),
            account: asString(input['account']),
            symbol: asString(input['symbol']),
            side: asString(input['side']),
            decisionId: asString(input['decision_id']),
          ),
          asString(c['expected_raw']),
        );
        expect(_key(input), asString(c['expected_key']));
      });
    }

    test('불변식 — 결정론 · side 만 달라도 · decision_id 만 달라도 다른 해시 · 길이 64', () {
      final Map<String, Object?> base = asObject(
        asObjectList(v['cases']).first['input'],
      );
      expect(_key(base), _key(base));
      expect(
        _key(<String, Object?>{...base, 'side': 'SELL'}),
        isNot(_key(base)),
      );
      expect(
        _key(<String, Object?>{...base, 'decision_id': 'A-REBAL-2026-08-05'}),
        isNot(_key(base)),
      );
      expect(_key(base), hasLength(64));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(_key(base)), isTrue);
    });
  });

  group('GV-13 decision_id — 시각·TIER 없음 · strategy_id 포함(형식 부분)', () {
    final Map<String, Object?> v = loadVector('gv13_decision_id.json');
    final Map<String, Object?> setup = asObject(v['setup']);
    final TradeDate day = TradeDate(asString(setup['trade_date']));
    final String symbol = asString(setup['symbol']);

    String keyOf(String decisionId) => idempotencyKey(
      market: asString(setup['market']),
      account: asString(setup['account']),
      symbol: symbol,
      side: asString(setup['side']),
      decisionId: decisionId,
    );

    Map<String, Object?> expectedOf(String id) => asObject(
      asObjectList(v['cases'])
          .firstWhere((Map<String, Object?> c) => c['id'] == id)['expected'],
    );

    test('v1 같은 날 4번 감시해도 id·멱등키는 하나', () {
      final List<String> ids = <String>[
        for (int i = 0; i < 4; i++)
          DecisionIds.exit(asString(setup['strategy_id']), symbol, day),
      ];
      final Map<String, Object?> e = expectedOf('v1');
      expect(ids.first, asString(e['decision_id']));
      expect(ids.toSet(), hasLength(asInt(e['distinct_decision_ids'])));
      expect(
        ids.map(keyOf).toSet(),
        hasLength(asInt(e['distinct_idempotency_keys'])),
      );
    });

    test('v2 TIER 1.5 · 1B 가 이어 걸려도 id 는 하나 — 생성기에 TIER 인자가 없다', () {
      final Set<String> ids = <String>{
        DecisionIds.exit(asString(setup['strategy_id']), symbol, day),
        DecisionIds.exit(asString(setup['strategy_id']), symbol, day),
      };
      expect(ids, hasLength(asInt(expectedOf('v2')['distinct_decision_ids'])));
    });

    test('v3 두 전략이 같은 종목을 청산하면 id·멱등키가 둘', () {
      final List<String> ids = <String>[
        DecisionIds.exit('satellite_kr', symbol, day),
        DecisionIds.exit('sleeve_a_kr', symbol, day),
      ];
      final Map<String, Object?> e = expectedOf('v3');
      expect(ids.toSet(), hasLength(asInt(e['distinct_decision_ids'])));
      expect(
        ids.map(keyOf).toSet(),
        hasLength(asInt(e['distinct_idempotency_keys'])),
      );
    });

    test('v4 월간 새틀라이트 교체는 날짜 하나로 정해진다', () {
      expect(
        DecisionIds.satelliteRotation(day),
        asString(expectedOf('v4')['decision_id']),
      );
    });
  });
}
