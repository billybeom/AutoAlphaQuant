// E6d 재현 — S6 · S7 · 스트레스 3종(delay1 · nogate · nocut) 26년 실행이 참조 엔진(백테스트6)과 같은가.
//
// 정답지 = `fixtures/variants_parity.json`(tool/export_replay_variants.py — N2 골든 생성기와 같은 설정의 실행 해시).
// 🔵 nogate 는 이월 · 연금 납입 조달 · 원화 조달 반복을 검사하는 유일한 실행이다(이식 지도 §3-5).
// 🔵 delay1 · nocut 에는 POT «먼지 행»(전량 매도 뒤 +ULP)이 1~2개 있다 — double 연산 순서 재현으로 같게 나와야 한다.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'parity_hash.dart';
import 'replay_engine.dart';
import 'replay_market.dart';
import 'replay_regime.dart';

void main() {
  final Map<String, Object?> want =
      (jsonDecode(
            File('test/replay/fixtures/variants_parity.json')
                .readAsStringSync(),
          ) as Map<String, Object?>)['variants']!
          as Map<String, Object?>;
  final ReplayMarket market = ReplayMarket.build();
  final ReplayRegime regime = ReplayRegime.build();

  for (final ReplayVariant v in <ReplayVariant>[
    ReplayVariant.s7,
    ReplayVariant.s6,
    ReplayVariant.delay1,
    ReplayVariant.nogate,
    ReplayVariant.nocut,
  ]) {
    test('${v.name} — 원장 행 수 · 문자 칸 · 수 칸 · 비용 · 일별 자산', () {
      final Map<String, Object?> w = want[v.name]! as Map<String, Object?>;
      final ReplayEngine e = ReplayEngine(market, regime, variant: v)..run();
      expect(e.ledger, hasLength(w['n_ledger']), reason: '원장 행 수');
      expect(
        lineHash(<String>[
          for (final LedgerRow r in e.ledger)
            '${r.date}|${r.sleeve}|${r.symbol}|${r.side}|${r.event}|${r.dirState}|${r.breaker}',
        ]),
        w['ledger_text_sha256'],
        reason: '원장 문자 칸',
      );
      final Map<String, Object?> nums =
          w['ledger_num_sha256']! as Map<String, Object?>;
      expect(
        floatHash(e.ledger.map((LedgerRow r) => r.qty)),
        nums['qty'],
        reason: 'qty',
      );
      expect(
        floatHash(e.ledger.map((LedgerRow r) => r.price)),
        nums['price'],
        reason: 'price',
      );
      expect(
        floatHash(e.ledger.map((LedgerRow r) => r.gross)),
        nums['gross_krw'],
        reason: 'gross',
      );
      expect(
        floatHash(e.ledger.map((LedgerRow r) => r.cost)),
        nums['cost_krw'],
        reason: 'cost',
      );
      // pandas `Series.sum` = numpy 짝 합산(bottleneck 없음).
      expect(
        npSum(<double>[for (final LedgerRow r in e.ledger) r.cost]),
        (w['cost_krw_sum']! as num).toDouble(),
        reason: '비용 합계',
      );
      expect(e.daily, hasLength(w['n_daily']));
      expect(
        floatHash(e.daily.map((DailyRow d) => d.values['equity'])),
        w['equity_sha256'],
        reason: '일별 자산',
      );
      expect(
        e.daily.last.values['equity'],
        (w['equity_last']! as num).toDouble(),
      );
    });
  }
}
