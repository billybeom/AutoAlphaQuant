// 분할 집행 규약 중 GV-30 이 직접 보지 않는 것 — anchor 검사 · 시즌 경계 · 입력 거부 · 마지막 날 몫(03 §5-3-1 v2.38).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden/calendar_fixture.dart';

SplitDay _day(int i, {int target = 10, int planned = 0, int filled = 0}) =>
    splitDay(
      target: target,
      days: 3,
      dayIndex: i,
      plannedBefore: planned,
      filledBefore: filled,
    );

void main() {
  final ExchangeCalendar kr = frozenCalendar(Market.kr);

  group('집행일', () {
    test('anchor 가 그 달 마지막 세션이 아니면 거절한다', () {
      expect(
        () => seasonalExecutionDays(kr, const TradeDate('2026-10-29'), 3),
        throwsArgumentError,
      );
    });

    test('휴장 말일 달은 거래소 기준 마지막 세션이 anchor 다(2026-12-31 휴장 → 12-30)', () {
      expect(
        seasonalExecutionDays(kr, const TradeDate('2026-12-30'), 3),
        const <TradeDate>[
          TradeDate('2026-12-28'),
          TradeDate('2026-12-29'),
          TradeDate('2026-12-30'),
        ],
      );
    });

    test('집행일이 달을 넘으면 StateError(시즌 경계 — 05 GV-30)', () {
      expect(
        () => seasonalExecutionDays(kr, const TradeDate('2026-10-30'), 30),
        throwsStateError,
      );
    });

    test('days < 1 은 거절한다', () {
      expect(
        () => seasonalExecutionDays(kr, const TradeDate('2026-10-30'), 0),
        throwsArgumentError,
      );
    });
  });

  group('하루 몫', () {
    test('마지막 날은 목표 − 누적 체결 · 시장가 — 앞날 계획과 무관하다', () {
      final SplitDay d = _day(2, planned: 7, filled: 0);
      expect(d.quantity, 10);
      expect(d.marketOrder, isTrue);
    });

    test('중간 날에는 미체결분을 더하지 않는다(v2.38 · e4 의 2일차 = 3, 4·5 가 아니다)', () {
      final SplitDay d = _day(1, planned: 4, filled: 2);
      expect(d.quantity, 3);
      expect(d.marketOrder, isFalse);
    });

    test('목표 0 이면 매일 0', () {
      expect(_day(0, target: 0).quantity, 0);
      expect(_day(2, target: 0).quantity, 0);
    });

    test('앞뒤가 안 맞는 입력은 거절한다', () {
      expect(() => _day(3), throwsArgumentError);
      expect(() => _day(-1), throwsArgumentError);
      expect(() => _day(0, planned: 1), throwsArgumentError);
      expect(() => _day(1, planned: 4, filled: 5), throwsArgumentError);
      expect(() => _day(1, planned: 11), throwsArgumentError);
      expect(() => _day(0, target: -1), throwsArgumentError);
      expect(
        () => splitDay(
          target: 1,
          days: 0,
          dayIndex: 0,
          plannedBefore: 0,
          filledBefore: 0,
        ),
        throwsArgumentError,
      );
    });

    test('하루짜리 분할 = 첫날이 마지막 날(전량 · 시장가)', () {
      final SplitDay d = splitDay(
        target: 7,
        days: 1,
        dayIndex: 0,
        plannedBefore: 0,
        filledBefore: 0,
      );
      expect(d.quantity, 7);
      expect(d.marketOrder, isTrue);
    });
  });
}
