// 이월 — 일 마감 실효 수량을 다음 세션 대상으로(계절 밖 D6) · 계절 분할 진행(D8). 03 §5-3-1 v2.38 · §5-4 v2.38 ·
// 04 §3-1 ③ ④ v2.38 · 설계 13 §8 R33 D6 · D8 · R39 T2~T4.
//
// 🔴 계절 밖(B · C · POT · 입금)은 첫 세션 포함 **총 3세션**까지 — 그래도 남으면 버리고 P1 · 다음 월말 판정이 흡수한다.
//    지정가는 매일 다시 매긴다(초안기가 그날 시세로).
// 🔴 계절 분할(`SEAS-A-IN` · `SEAS-A-OUT`)은 이월하지 않는다 — 다음 분할 날의 몫이 «앞날 계획 합 · 체결 합»으로 정해지고
//    마지막 날 «목표 − 누적 체결»이 남은 것을 모은다(`splitDay`).
// 🔴 이월 의도도 NR-1 1~9 를 처음부터 탄다 — 결정 id = `{논리 id}@{다음 집행일}`(날마다 새 키).

import 'package:domain_contracts/domain_contracts.dart';

import '../risk/limits.dart';
import 'order_draft.dart';
import 'split_execution.dart';

/// 계절 밖 이월의 세션 상한(첫 세션 포함 — D6).
const int kCarrySessionLimit = 3;

/// 실효된 의도 하나(이월 후보 · R39 T2).
class ExpiredIntent {
  /// 후보를 만든다.
  const ExpiredIntent({
    required this.intentId,
    required this.logicalDecisionId,
    required this.strategyId,
    required this.symbol,
    required this.side,
    required this.expiredQty,
    required this.sessionsUsed,
  });

  /// 의도 id.
  final String intentId;

  /// 논리 id(decision_id 의 `@` 앞 — 순매매 결합 id 그대로).
  final String logicalDecisionId;

  /// strategy_id · 종목.
  final String strategyId, symbol;

  /// 방향.
  final OrderSide side;

  /// 실효 수량(주문 − 누적 체결 − 취소 확인).
  final int expiredQty;

  /// 그 (논리 id · 전략 · 종목)에 의도를 낸 서로 다른 집행일 수(이번 날 포함).
  final int sessionsUsed;

  /// 계절 분할 결정인가(이월하지 않는다 — 순매매 결합 id 의 한 조각이라도 계절이면 계절이다).
  bool get isSeasonal => logicalDecisionId
      .split('+')
      .any(
        (String p) => p.startsWith('SEAS-A-IN-') || p.startsWith('SEAS-A-OUT-'),
      );
}

/// decision_id(`{논리 id}@{집행일}`)의 논리 id — `@` 가 없으면 ArgumentError.
String logicalIdOf(String decisionId) {
  final int at = decisionId.indexOf('@');
  if (at < 1) {
    throw ArgumentError.value(
      decisionId,
      'decisionId',
      '`{논리 id}@{집행일}` 꼴이 아니다',
    );
  }
  return decisionId.substring(0, at);
}

/// 이월 계획 결과.
class CarryPlan {
  /// 결과를 만든다.
  const CarryPlan({
    required this.targets,
    required this.dropped,
    required this.seasonal,
  });

  /// 다음 세션 대상(초안기 입력).
  final List<OrderTarget> targets;

  /// 세션 상한을 다 써 버린 것(P1 · 다음 월말이 흡수).
  final List<ExpiredIntent> dropped;

  /// 계절 분할 — 이월하지 않고 분할 규칙이 맡는다.
  final List<ExpiredIntent> seasonal;
}

/// 실효 → 다음 세션 대상(R39 T3 · 순수). [instruments] 에 없는 종목은 개별주(fail-closed).
CarryPlan planCarryOver(
  Iterable<ExpiredIntent> expired, {
  Map<String, InstrumentKind> instruments = const <String, InstrumentKind>{},
}) {
  final List<OrderTarget> targets = <OrderTarget>[];
  final List<ExpiredIntent> dropped = <ExpiredIntent>[];
  final List<ExpiredIntent> seasonal = <ExpiredIntent>[];
  for (final ExpiredIntent e in expired) {
    if (e.expiredQty < 1) continue;
    if (e.isSeasonal) {
      seasonal.add(e);
    } else if (e.sessionsUsed >= kCarrySessionLimit) {
      dropped.add(e);
    } else {
      targets.add(
        OrderTarget(
          logicalDecisionId: e.logicalDecisionId,
          strategyId: e.strategyId,
          symbol: e.symbol,
          side: e.side,
          sizing: ShareSizing(e.expiredQty),
          instrument: instruments[e.symbol] ?? InstrumentKind.stock,
        ),
      );
    }
  }
  return CarryPlan(targets: targets, dropped: dropped, seasonal: seasonal);
}

/// 계절 분할의 앞날 진행(R39 T4) — 그 논리 id 의 앞 집행일 의도 수량 합 · 체결 합.
class SplitProgress {
  /// 진행을 만든다.
  const SplitProgress({required this.planned, required this.filled});

  /// 앞날에 낸 수량 합(SKIPPED · 1~5단계 거부 제외).
  final int planned;

  /// 앞날에 체결된 수량 합.
  final int filled;
}

/// 이월 원장 포트(R39 T2 · T4) — 구현 = data_sync `SqliteOrderLedger`.
abstract interface class CarryLedger {
  /// 그 집행일의 EXPIRED 의도(실효 수량 · 사용 세션 포함).
  Future<List<ExpiredIntent>> expiredIntents(TradeDate tradeDate);

  /// [logicalDecisionId] 의 [before] 앞 집행일 진행.
  Future<SplitProgress> splitProgress(
    String logicalDecisionId, {
    required String strategyId,
    required String symbol,
    required TradeDate before,
  });
}

/// 오늘의 계절 분할 몫 — 원장 진행을 `splitDay` 에 넣는다(R39 T4).
///
/// 🟡 «앞날 계획»은 실제 낸 수량이다(예수금 축소로 줄면 앞이 덜 무거워진다 — 마지막 날이 메운다).
/// 🔴 앞날 낸 수량이 목표를 넘으면 `splitDay` 의 ArgumentError(원장이 틀렸다).
Future<SplitDay> seasonalShareToday(
  CarryLedger ledger, {
  required String logicalDecisionId,
  required String strategyId,
  required String symbol,
  required int target,
  required List<TradeDate> executionDays,
  required TradeDate today,
}) async {
  final int dayIndex = executionDays.indexOf(today);
  if (dayIndex < 0) {
    throw ArgumentError.value(today, 'today', '분할 집행일이 아니다');
  }
  final SplitProgress p = await ledger.splitProgress(
    logicalDecisionId,
    strategyId: strategyId,
    symbol: symbol,
    before: today,
  );
  return splitDay(
    target: target,
    days: executionDays.length,
    dayIndex: dayIndex,
    plannedBefore: dayIndex == 0 ? 0 : p.planned,
    filledBefore: dayIndex == 0 ? 0 : p.filled,
  );
}
