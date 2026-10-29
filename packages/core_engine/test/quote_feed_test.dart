// E8d2b — 끝난 세션(설계 13 §8 R30 N3 · R29 L11).
//
// 🔵 잡는 것: ① KR 세션 d = d 18:00 KST 부터 확정(17:59:59 = 아직) ② US 세션 d = d+1 07:00 KST 부터(06:59:59 = 아직)
//    ③ 주말·휴장은 그 앞 세션 ④ 동결 달력 범위 밖 = StateError(지어내지 않는다).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

/// KST 벽시계 → UTC.
DateTime _kst(int y, int m, int d, int h, [int min = 0, int s = 0]) =>
    DateTime.utc(y, m, d, h, min, s).subtract(const Duration(hours: 9));

void main() {
  final ExchangeCalendar kr = frozenExchangeCalendar(Market.kr);
  final ExchangeCalendar us = frozenExchangeCalendar(Market.us);

  group('KR — d 18:00 KST', () {
    test('17:59:59 는 전 세션 · 18:00 은 그날', () {
      expect(kr.isSession(const TradeDate('2026-10-29')), isTrue);
      expect(kr.isSession(const TradeDate('2026-10-28')), isTrue);
      expect(
        lastFinishedSession(kr, _kst(2026, 10, 29, 17, 59, 59)),
        '2026-10-28',
      );
      expect(lastFinishedSession(kr, _kst(2026, 10, 29, 18)), '2026-10-29');
      expect(
        lastFinishedSession(kr, _kst(2026, 10, 29, 23, 59, 59)),
        '2026-10-29',
      );
    });

    test('주말 — 토요일·월요일 아침 = 금요일', () {
      expect(lastFinishedSession(kr, _kst(2026, 10, 31, 12)), '2026-10-30');
      expect(lastFinishedSession(kr, _kst(2026, 11, 2, 10)), '2026-10-30');
    });

    test('휴장(성탄절) 20:00 = 그 앞 세션', () {
      expect(kr.isSession(const TradeDate('2026-12-25')), isFalse);
      expect(lastFinishedSession(kr, _kst(2026, 12, 25, 20)), '2026-12-24');
    });
  });

  group('US — d+1 07:00 KST', () {
    test('06:59:59 는 그 전 세션 · 07:00 은 전날 세션', () {
      expect(us.isSession(const TradeDate('2026-10-28')), isTrue);
      expect(
        lastFinishedSession(us, _kst(2026, 10, 29, 6, 59, 59)),
        '2026-10-27',
      );
      expect(lastFinishedSession(us, _kst(2026, 10, 29, 7)), '2026-10-28');
      expect(lastFinishedSession(us, _kst(2026, 10, 29, 20)), '2026-10-28');
    });

    test('주말 — KST 토·월 아침 = 미국 금요일', () {
      expect(lastFinishedSession(us, _kst(2026, 10, 31, 8)), '2026-10-30');
      expect(lastFinishedSession(us, _kst(2026, 11, 2, 8)), '2026-10-30');
    });

    test('휴장(추수감사절) 다음 날 아침 = 그 앞 세션', () {
      expect(us.isSession(const TradeDate('2026-11-26')), isFalse);
      expect(lastFinishedSession(us, _kst(2026, 11, 27, 8)), '2026-11-25');
    });

    test('UTC 가 아닌 시각도 같은 순간으로 본다', () {
      final DateTime local = _kst(2026, 10, 29, 7).toLocal();
      expect(lastFinishedSession(us, local), '2026-10-28');
    });
  });

  group('lastSessionAtOrBefore', () {
    test('세션이면 그날 · 아니면 그 앞', () {
      expect(lastSessionAtOrBefore(kr, '2026-10-30'), '2026-10-30');
      expect(lastSessionAtOrBefore(kr, '2026-11-01'), '2026-10-30');
    });

    test('동결 달력 범위 밖 = StateError', () {
      expect(
        () => lastFinishedSession(kr, _kst(2028, 1, 5, 20)),
        throwsStateError,
      );
      expect(() => lastSessionAtOrBefore(us, '2028-01-03'), throwsStateError);
    });
  });
}
