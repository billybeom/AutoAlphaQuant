// E8b1 — 동결 거래소 캘린더 lib 자산(설계 13 §8 R23 D14 · R24 B2).
//
// 🔵 잡는 것: ① lib 상수 = 원천 JSON(세션 전부 · 범위 · 출처 · 덮어쓰기) ② 생성 파일 머리의 sha256 = 지금 JSON —
//    JSON 을 다시 만들고 lib 를 안 만들면 실패한다 ③ 범위 밖은 «모름»(StateError) ④ 덮어쓰기 휴장일(R15)이 실제로 빠졌다.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden/golden_vectors.dart';

void main() {
  for (final Market m in Market.values) {
    final String file = 'sessions_${m.mic.toLowerCase()}.json';
    group('${m.mic} 동결 표', () {
      final Map<String, Object?> doc = loadVector(file);
      final Map<String, Object?> meta = asObject(doc['meta']);
      final List<String> sessions = asStringList(doc['sessions']);
      final ExchangeCalendar cal = frozenExchangeCalendar(m);
      final FrozenCalendarInfo info = frozenCalendarInfo(m);

      test('lib 세션 = 원천 JSON 세션(전부 · 순서 그대로)', () {
        final List<String> range = asStringList(meta['requested_range']);
        expect(cal.coverageStart, TradeDate(range[0]));
        expect(cal.coverageEnd, TradeDate(range[1]));
        expect(info.sessionCount, sessions.length);
        expect(info.sessionCount, meta['count']);
        // 범위 안 모든 날: lib 판정 = JSON 에 있는가.
        final Set<String> set = sessions.toSet();
        String d = range[0];
        int n = 0;
        while (d.compareTo(range[1]) <= 0) {
          expect(cal.isSession(TradeDate(d)), set.contains(d), reason: d);
          if (set.contains(d)) n++;
          d = plusDays(d, 1);
        }
        expect(n, sessions.length);
      });

      test('출처 · 덮어쓰기 = 원천 JSON', () {
        expect(info.source, meta['source']);
        expect(
          info.closedOverrides,
          asObject(meta['closed_overrides'] ?? <String, Object?>{}),
        );
      });
    });
  }

  test('생성 파일 머리의 sha256 = 지금 원천 JSON(다시 만들지 않으면 실패)', () {
    final String head = File('lib/src/calendar/frozen_sessions.dart')
        .readAsLinesSync()
        .take(6)
        .join('\n');
    for (final String mic in <String>['xkrx', 'xnys']) {
      final String sha = sha256
          .convert(File('$kVectorsDir/sessions_$mic.json').readAsBytesSync())
          .toString();
      expect(head, contains('sessions_$mic.json` sha256 `$sha`'), reason: mic);
    }
  });

  test('범위 밖은 «모름» · 덮어쓰기 휴장일은 세션이 아니다(R15)', () {
    final ExchangeCalendar kr = frozenExchangeCalendar(Market.kr);
    expect(() => kr.isSession(const TradeDate('2028-01-03')), throwsStateError);
    expect(() => kr.isSession(const TradeDate('1999-11-30')), throwsStateError);
    expect(kr.isSession(const TradeDate('2026-06-03')), isFalse);
    expect(kr.isSession(const TradeDate('2026-07-17')), isFalse);
    expect(kr.isSession(const TradeDate('2026-06-02')), isTrue);
    expect(
      frozenCalendarInfo(Market.kr).closedOverrides.keys,
      containsAll(<String>['2026-06-03', '2026-07-17']),
    );
    expect(identical(frozenExchangeCalendar(Market.kr), kr), isTrue);
  });
}
