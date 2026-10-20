// 동결 세션 표(vectors/sessions_x*.json · tool/gen_exchange_sessions.py) → [ExchangeCalendar].

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'golden_vectors.dart';

/// [market] 의 동결 세션 표로 캘린더를 만든다. 범위 = 생성기가 요청한 범위(양 끝 포함).
ExchangeCalendar frozenCalendar(Market market) {
  final Map<String, Object?> doc = loadVector(
    'sessions_${market.mic.toLowerCase()}.json',
  );
  final Map<String, Object?> meta = asObject(doc['meta']);
  final List<String> range = asStringList(meta['requested_range']);
  return ExchangeCalendar(
    market: market,
    sessions: asStringList(doc['sessions']).map(TradeDate.new),
    coverageStart: TradeDate(range[0]),
    coverageEnd: TradeDate(range[1]),
  );
}
