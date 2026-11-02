// GV-30 계절성 분할 집행(AC-B23 · e1~e4) — 03 §5-3-1 v2.10 · v2.38 · 06 M1-9b.
//
// 정답지(vectors/SOURCES.md): 05 §GV-30 코드 블록 원문. `filled` 가 없는 케이스는 계획대로 전량 체결된다고 본다
// (블록 검산 «잔량 66 → 33» 이 그 가정이다). e4 의 `filled` 는 1·2일차 체결 수량이다.
// 🔴 e4 해석(v2.38 · 설계 13 §8 R33 D8): 중간 날 = 계획 잔량 기준 ceil · 마지막 날 = 목표 − 누적 체결.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'calendar_fixture.dart';
import 'golden_vectors.dart';

void main() {
  final Map<String, Object?> gv30 = loadVector('gv30_split_execution.json');
  final int days = asInt(asObject(gv30['config'])['execution_days']);

  test('집행일 = anchor 포함 거꾸로 3세션(동결 XKRX 달력) — 정답지 sessions 와 같다', () {
    final List<TradeDate> got = seasonalExecutionDays(
      frozenCalendar(Market.kr),
      TradeDate(asString(gv30['anchor_date'])),
      days,
    );
    expect(
      got.map((TradeDate d) => d.yyyyMmDd).toList(),
      asStringList(gv30['sessions']),
    );
  });

  group('GV-30 일별 수량 (4)', () {
    for (final Map<String, Object?> c in asObjectList(gv30['cases'])) {
      final Map<String, Object?> e = asObject(c['expected']);
      test('${asString(c['id'])} — ${e['note'] ?? asString(c['symbol'])}', () {
        final int target = asInt(c['target_qty']);
        final List<int>? filled = c['filled'] == null
            ? null
            : (c['filled']! as List<Object?>).map(asInt).toList();
        final List<int> daily = <int>[];
        final List<bool> market = <bool>[];
        int planned = 0;
        int filledSum = 0;
        for (int i = 0; i < days; i++) {
          final SplitDay d = splitDay(
            target: target,
            days: days,
            dayIndex: i,
            plannedBefore: planned,
            filledBefore: filledSum,
          );
          daily.add(d.quantity);
          market.add(d.marketOrder);
          planned += d.quantity;
          if (i < days - 1) {
            filledSum += filled == null ? d.quantity : filled[i];
          }
        }
        expect(daily, (e['daily_qty']! as List<Object?>).map(asInt).toList());
        // 마지막 날만 시장가(v2.38 D7).
        expect(market, <bool>[false, false, true]);
      });
    }
  });
}
