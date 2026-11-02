// decision_id 생성 규칙 · 멱등키 — `06_시스템설계/04_안전장치.md` §3-2 · 05 GV-9 · GV-13(AC-S13) 의 형식 부분.
//
// 🔴 decision_id 는 «논리적 의사결정 단위»다. 시각·UUID·난수·타임스탬프·TIER 를 넣지 않는다 —
//    넣으면 같은 결정이 여러 키를 가져 중복 주문이 나간다(5분 감시면 하루 78건 · 05 GV-13 v1).
//    그래서 아래 생성기는 **그것들을 받을 인자가 아예 없다**. strategy_id 는 반드시 들어간다(v1.5).
// 🔴 {trade_date} 는 해당 시장의 현지 거래일이다(NR-3) — v2.38 부터 표의 `{trade_date}` 는 **판정일**,
//    `{anchor}` 는 그 달 마지막 KR 거래일(계절 분할의 기준일)이다(04 §3-2 v2.38).
// 🔵 v2.38(설계 13 §8 R33 D2 · R12 해소): P0S 형식 7종을 더했다. 표의 값은 **논리 id** 이고, 주문 의도의
//    decision_id 는 [DecisionIds.forExecution] = `{논리 id}@{집행일}` 이다 — 분할 3일·이월이 같은 논리 id 를
//    쓰면 멱등키가 같아 2·3일차가 UNIQUE 에 막힌다. 같은 날 같은 결정의 재실행은 여전히 같은 키다.
// 🔵 «같은 키는 한 번만 발주»(UNIQUE 제약 · 미체결 청산 의도 확인)는 주문 의도 예약의 몫이라 E10 에서 온다.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart';

final RegExp _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// 04 §3-2 의 decision_id 형식(v1.4 6종 + v2.38 P0S 7종). 시각·TIER·일련번호를 받는 인자는 없다.
abstract final class DecisionIds {
  /// 주문 의도의 decision_id — `{논리 id}@{집행일}`(04 §3-2 v2.38). 접미는 날짜뿐이다.
  ///
  /// 이미 접미가 붙은 id(`@` 포함)는 거절한다 — 접미가 두 번 붙으면 같은 결정이 다른 키를 갖는다.
  static String forExecution(String logicalId, TradeDate executionDate) {
    if (_part(logicalId, 'logicalId').contains('@')) {
      throw ArgumentError.value(logicalId, 'logicalId', '이미 집행일 접미가 있다');
    }
    return '$logicalId@${_date(executionDate)}';
  }

  /// 순매매(설계 13 §8 R33 D17)로 합친 의도의 논리 id — 정렬 · 중복 제거 뒤 `+` 로 잇는다(R34 U6).
  ///
  /// 하나뿐이면 그대로다. 같은 입력이면 순서와 무관하게 같은 값이라 같은 날 재실행이 같은 키를 낸다.
  static String combined(Iterable<String> logicalIds) {
    final List<String> ids = <String>{
      for (final String id in logicalIds) _logical(id),
    }.toList()..sort();
    if (ids.isEmpty) throw ArgumentError('논리 id 가 없다');
    return ids.join('+');
  }

  /// 월 납입 배분(입금 · DEPOSIT) — `DEP-{plan_id}`(R12 확정 — 계획 하나에 결정 하나).
  static String deposit(String planId) => 'DEP-${_part(planId, 'planId')}';

  /// 연금 납입 조달(PENSION_FUNDING · 원화 조달) — `FUND-{trade_date}`.
  static String pensionFunding(TradeDate tradeDate) =>
      'FUND-${_date(tradeDate)}';

  /// 슬리브 A 계절 진입 — `SEAS-A-IN-{anchor}`.
  static String seasonalAEntry(TradeDate anchor) =>
      'SEAS-A-IN-${_date(anchor)}';

  /// 슬리브 A 계절 청산 — `SEAS-A-OUT-{anchor}`.
  static String seasonalAExit(TradeDate anchor) =>
      'SEAS-A-OUT-${_date(anchor)}';

  /// POT 서브북 SMA 신호 — `POT-SMA-{trade_date}`.
  static String potSma(TradeDate tradeDate) => 'POT-SMA-${_date(tradeDate)}';

  /// POT 재원 전량 청산(계절 진입 재원) — `POT-LIQ-{anchor}`.
  static String potLiquidation(TradeDate anchor) => 'POT-LIQ-${_date(anchor)}';

  /// 슬리브 C 재구성 리밸런싱 — `C-REBAL-{trade_date}`.
  static String sleeveCRebalance(TradeDate tradeDate) =>
      'C-REBAL-${_date(tradeDate)}';

  /// 반기 리밸런싱(슬리브 A) — `A-REBAL-{trade_date}`.
  static String sleeveARebalance(TradeDate tradeDate) =>
      'A-REBAL-${_date(tradeDate)}';

  /// 월간 새틀라이트 교체 — `S-ROT-{trade_date}`.
  static String satelliteRotation(TradeDate tradeDate) =>
      'S-ROT-${_date(tradeDate)}';

  /// 슬리브 B SMA 신호 — `B-SMA-{trade_date}`.
  static String sleeveBSma(TradeDate tradeDate) => 'B-SMA-${_date(tradeDate)}';

  /// 밴드 리밸런싱 — `BAND-{sleeve}-{trade_date}`.
  static String band(String sleeve, TradeDate tradeDate) =>
      'BAND-${_part(sleeve, 'sleeve')}-${_date(tradeDate)}';

  /// 청산(TIER 무관) — `EXIT-{strategy_id}-{symbol}-{trade_date}`.
  static String exit(String strategyId, String symbol, TradeDate tradeDate) =>
      'EXIT-${_part(strategyId, 'strategyId')}-${_part(symbol, 'symbol')}'
      '-${_date(tradeDate)}';

  /// 서킷브레이커·한도 청산 — `RISK-{strategy_id}-{symbol}-{trade_date}`.
  static String risk(String strategyId, String symbol, TradeDate tradeDate) =>
      'RISK-${_part(strategyId, 'strategyId')}-${_part(symbol, 'symbol')}'
      '-${_date(tradeDate)}';
}

/// 멱등키 원문 — `v1|{market}|{account}|{symbol}|{side}|{decision_id}`(04 §3-2 · 05 GV-9).
String idempotencyRaw({
  required String market,
  required String account,
  required String symbol,
  required String side,
  required String decisionId,
}) {
  if (market != 'KR' && market != 'US') {
    throw ArgumentError.value(market, 'market', 'KR · US 가 아니다');
  }
  if (side != 'BUY' && side != 'SELL') {
    throw ArgumentError.value(side, 'side', 'BUY · SELL 이 아니다');
  }
  return 'v1|$market|${_part(account, 'account')}|${_part(symbol, 'symbol')}'
      '|$side|${_part(decisionId, 'decisionId')}';
}

/// 멱등키 — 원문의 SHA-256(UTF-8) 16진 소문자 64자.
String idempotencyKey({
  required String market,
  required String account,
  required String symbol,
  required String side,
  required String decisionId,
}) => sha256
    .convert(
      utf8.encode(
        idempotencyRaw(
          market: market,
          account: account,
          symbol: symbol,
          side: side,
          decisionId: decisionId,
        ),
      ),
    )
    .toString();

String _date(TradeDate d) {
  if (!_isoDate.hasMatch(d.yyyyMmDd)) {
    throw ArgumentError.value(d.yyyyMmDd, 'tradeDate', 'YYYY-MM-DD 가 아니다');
  }
  return d.yyyyMmDd;
}

/// 논리 id — 구성 요소 규칙에 더해 집행일 접미(`@`)·결합 구분자(`+`)가 없어야 한다.
String _logical(String id) {
  if (_part(id, 'logicalId').contains('@') || id.contains('+')) {
    throw ArgumentError.value(id, 'logicalId', '논리 id 에 @·+ 가 들어 있다');
  }
  return id;
}

/// 구성 요소 — 비었거나 공백·구분자(`|`)가 있으면 거부한다(원문이 모호해진다).
String _part(String value, String name) {
  if (value.isEmpty || value.contains('|') || value.contains(RegExp(r'\s'))) {
    throw ArgumentError.value(value, name, '비었거나 공백·| 가 들어 있다');
  }
  return value;
}
