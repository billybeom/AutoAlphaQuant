// 동결 세션 표 → [ExchangeCalendar].
//
// 🔵 E8b1(설계 13 §8 R24 B2 · R23 D14) — 시험도 앱이 싣는 lib 자산(`frozenExchangeCalendar`)을 쓴다. lib 자산이 원천
//    JSON(vectors/sessions_x*.json · tool/gen_exchange_sessions.py)과 같은지는 `test/frozen_calendar_test.dart` 가 본다.

import 'package:core_engine/core_engine.dart';

/// [market] 의 동결 세션 표로 만든 캘린더. 범위 = 생성기가 요청한 범위(양 끝 포함).
ExchangeCalendar frozenCalendar(Market market) =>
    frozenExchangeCalendar(market);
