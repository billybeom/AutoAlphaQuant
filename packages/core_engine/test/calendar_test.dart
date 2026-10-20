// 캘린더·멱등키 규약 중 정답지가 직접 보지 않는 것 — fail-closed 범위 · 입력 거부 · n번째 세션.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden/calendar_fixture.dart';
import 'golden/golden_vectors.dart';

ExchangeCalendar _tiny() => ExchangeCalendar(
  market: Market.kr,
  sessions: <TradeDate>[
    const TradeDate('2026-01-29'),
    const TradeDate('2026-01-30'),
    const TradeDate('2026-02-02'),
  ],
  coverageStart: const TradeDate('2026-01-29'),
  coverageEnd: const TradeDate('2026-02-02'),
);

void main() {
  group('범위 밖은 «휴장»이 아니라 «모름»', () {
    test('범위 밖 날짜는 판정하지 않는다', () {
      expect(
        () => _tiny().isSession(const TradeDate('2026-02-03')),
        throwsStateError,
      );
      expect(
        () => _tiny().isSession(const TradeDate('2026-01-28')),
        throwsStateError,
      );
    });

    test('범위가 그 달 말일까지 닿지 않으면 «월 마지막 세션»을 말하지 않는다', () {
      // 2026-02-02 가 목록의 마지막 세션이지만 범위는 02-02 에서 끝난다 — 2월 말을 모른다.
      expect(
        () => _tiny().isLastSessionOfMonth(const TradeDate('2026-02-02')),
        throwsStateError,
      );
    });

    test('범위 안 다음 세션이 없으면 n번째 세션도 없다', () {
      expect(
        () => _tiny().nthSessionAfter(const TradeDate('2026-01-30'), 2),
        throwsStateError,
      );
    });
  });

  group('입력 거부', () {
    test('형식이 틀리거나 없는 날짜·겹친 세션·범위 밖 세션', () {
      expect(
        () => _tiny().isSession(const TradeDate('2026-1-29')),
        throwsArgumentError,
      );
      expect(
        () => _tiny().isSession(const TradeDate('2026-02-30')),
        throwsArgumentError,
      );
      expect(
        () => ExchangeCalendar(
          market: Market.kr,
          sessions: <TradeDate>[
            const TradeDate('2026-01-29'),
            const TradeDate('2026-01-29'),
          ],
          coverageStart: const TradeDate('2026-01-29'),
          coverageEnd: const TradeDate('2026-01-30'),
        ),
        throwsArgumentError,
      );
      expect(
        () => ExchangeCalendar(
          market: Market.kr,
          sessions: <TradeDate>[const TradeDate('2026-03-02')],
          coverageStart: const TradeDate('2026-01-29'),
          coverageEnd: const TradeDate('2026-01-30'),
        ),
        throwsArgumentError,
      );
    });

    test('멱등키 — 시장·방향 값과 구분자 `|`·공백을 거부한다', () {
      String key({
        String market = 'KR',
        String side = 'BUY',
        String symbol = '005930',
      }) => idempotencyKey(
        market: market,
        account: '12345678',
        symbol: symbol,
        side: side,
        decisionId: 'A-REBAL-2026-08-04',
      );
      expect(() => key(market: 'JP'), throwsArgumentError);
      expect(() => key(side: 'buy'), throwsArgumentError);
      expect(() => key(symbol: '005|930'), throwsArgumentError);
      expect(() => key(symbol: '005 930'), throwsArgumentError);
      expect(
        () => DecisionIds.exit('', '005930', const TradeDate('2026-09-10')),
        throwsArgumentError,
      );
    });
  });

  group('동결 표의 임시휴장 덮어쓰기(설계 13 §8 R15)', () {
    final ExchangeCalendar krx = frozenCalendar(Market.kr);
    test('2026-06-03 지방선거일 · 07-17 제헌절은 휴장(거래소 2026-05-20 공지)', () {
      expect(krx.isSession(const TradeDate('2026-06-03')), isFalse);
      expect(krx.isSession(const TradeDate('2026-07-17')), isFalse);
      expect(
        krx.nextSession(const TradeDate('2026-06-02')),
        const TradeDate('2026-06-04'),
      );
      expect(
        krx.nextSession(const TradeDate('2026-07-16')),
        const TradeDate('2026-07-20'),
      );
    });
    test('덮어쓰기 근거가 표 머리에 남아 있다', () {
      final Map<String, Object?> meta = asObject(
        loadVector('sessions_xkrx.json')['meta'],
      );
      expect(asObject(meta['closed_overrides']).keys, <String>[
        '2026-06-03',
        '2026-07-17',
      ]);
    });
  });

  group('n번째 세션 뒤(03 §4-3 nth_session_after)', () {
    final ExchangeCalendar kr = frozenCalendar(Market.kr);

    test('같은 날은 세지 않는다 — 다음 세션 = 1번째', () {
      expect(
        kr.nextSession(const TradeDate('2026-01-29')),
        const TradeDate('2026-01-30'),
      );
      expect(
        kr.nextSession(const TradeDate('2026-01-30')),
        const TradeDate('2026-02-02'),
      );
    });

    test('2026-09-10 뒤 20거래일 = 2026-10-14(05 §GV-14 검산표)', () {
      expect(
        kr.nthSessionAfter(const TradeDate('2026-09-10'), 20),
        const TradeDate('2026-10-14'),
      );
    });

    test('휴장일에서 시작해도 그 뒤 첫 세션부터 센다', () {
      expect(
        kr.nextSession(const TradeDate('2026-12-31')),
        const TradeDate('2027-01-04'),
      );
    });
  });
}
