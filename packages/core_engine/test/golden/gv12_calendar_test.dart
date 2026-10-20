// GV-12 거래일 판정 · GV-12c 월 마지막 세션 음성 케이스(05 §GV-12 · AC-B12 중 12·12c) · 03 §4-3.
//
// 정답지 = 05 v1.22 본문 블록 원문 · 세션 데이터 = exchange_calendars 4.13.2 동결 표(vectors/SOURCES.md).
// 🔴 MIC(XKRX·XNYS) → market(KR·US) 변환은 01 §1 `MIC` 상수 그대로(05 §GV-12 v1.5).
// 🔵 GV-12b(미국 주문의 ET 거래일)는 P0S 에 미국 주문이 없어 보류(설계 13 §7 P-2).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'calendar_fixture.dart';
import 'golden_vectors.dart';

void main() {
  final Map<Market, ExchangeCalendar> calendars = <Market, ExchangeCalendar>{
    for (final Market m in Market.values) m: frozenCalendar(m),
  };

  group('GV-12 거래일 판정', () {
    final Map<String, Object?> v = loadVector('gv12_trading_day.json');
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      final String date = asString(c['date']);
      final String mic = asString(c['calendar']);
      test('$mic $date', () {
        final ExchangeCalendar cal = calendars[Market.fromMic(mic)]!;
        final Map<String, Object?> e = asObject(c['expected']);
        expect(cal.isSession(TradeDate(date)), e['is_session']);
        if (e.containsKey('is_last_session_of_month')) {
          expect(
            cal.isLastSessionOfMonth(TradeDate(date)),
            e['is_last_session_of_month'],
          );
        }
      });
    }
  });

  group('GV-12c 월 마지막 세션 — 달력 말일이 아니라 거래소 기준', () {
    final Map<String, Object?> v = loadVector(
      'gv12c_last_session_negative.json',
    );
    final ExchangeCalendar cal =
        calendars[Market.values.firstWhere(
          (Market m) => m.code == asString(v['market']),
        )]!;
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      final String date = asString(c['date']);
      test(date, () {
        final Map<String, Object?> e = asObject(c['expected']);
        expect(cal.isSession(TradeDate(date)), e['is_session']);
        expect(
          cal.isLastSessionOfMonth(TradeDate(date)),
          e['is_last_session_of_month'],
        );
      });
    }
  });

  test('세션 표의 머리말이 생성기·버전·건수를 밝힌다', () {
    for (final Market m in Market.values) {
      final Map<String, Object?> meta = asObject(
        loadVector('sessions_${m.mic.toLowerCase()}.json')['meta'],
      );
      expect(meta['calendar'], m.mic);
      expect(asString(meta['source']), startsWith('exchange_calendars '));
      expect(
        asInt(meta['count']),
        asStringList(
          loadVector('sessions_${m.mic.toLowerCase()}.json')['sessions'],
        ).length,
      );
    }
  });
}
