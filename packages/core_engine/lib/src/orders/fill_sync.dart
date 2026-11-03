// 체결 동기화 · 일 마감 — 체결조회 → 체결 기록 · 실효(EXPIRED) · 다음 날 가드.
// 04 §3-1 ③ v2.38 · 02 §3-2 v2.38 · 설계 13 §8 R31 · R32 O3 · O4 · R33 D4 · R38 Z1~Z9.
//
// 🔴 판정은 원주문 행으로 한다(취소 행 거름 — 07 §6-3). 체결 키 = R31 (a) 누적수량 — 같은 누적은 행을 만들지 않는다.
// 🔴 일 마감(15:40 KST 뒤)에만 실효를 쓴다 — 잔여 > 0 인 원주문은 `EXPIRED`(취소가 아니다 · 취소 호출도 없다).
//    장중 동기화(D10 «매도 → 체결조회»)는 같은 길을 타되 실효를 쓰지 않는다.
// 🔴 일 마감 조회가 실패하면 이월하지 않는다 — 열린 의도를 UNKNOWN 으로 보낸다(04 §3-1 ③ ⑥). 접수했는데 조회에 원주문
//    행이 없어도 UNKNOWN 이다(조용히 넘기지 않는다).
// 🔵 이월(다음 날 의도) · UNKNOWN 해소는 E10e2 몫이다 — 여기는 실효 목록을 돌려줄 뿐이다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../decimal_rules.dart';
import 'fills.dart';
import 'order_ports.dart';

/// 브로커 주문이 있는 열린 의도(SUBMITTED · PARTIAL).
class OpenIntent {
  /// 의도를 만든다.
  const OpenIntent({
    required this.intentId,
    required this.brokerOrderNo,
    required this.tradeDate,
    required this.market,
    required this.account,
    required this.strategyId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.decisionId,
    required this.status,
  });

  /// 의도 id.
  final String intentId;

  /// `{주문일}:{ODNO}`.
  final String brokerOrderNo;

  /// 집행일.
  final TradeDate tradeDate;

  /// 시장 · 계좌 별칭 · strategy_id · 종목.
  final String market, account, strategyId, symbol;

  /// 방향.
  final OrderSide side;

  /// 주문 수량.
  final int quantity;

  /// decision_id.
  final String decisionId;

  /// 지금 상태(SUBMITTED · PARTIAL).
  final IntentStatus status;
}

/// 체결 비용률(R38 Z5) — 수수료율 · 매도세율(P0S = 국내 ETF = 0).
class FillCostRates {
  /// 비용률을 만든다.
  const FillCostRates({
    required this.commissionRate,
    required this.sellTaxRate,
  });

  /// 수수료율(02 §4 `costs.kr.commission_rate`).
  final double commissionRate;

  /// 매도세율(ETF 0 · 개별주 0.2%).
  final double sellTaxRate;
}

/// 체결 한 행의 추정 비용(`cost_source = ESTIMATED` · R33 D4).
({Decimal commission, Decimal tax}) estimateFillCost(
  FillDelta d,
  FillCostRates rates,
) {
  final Decimal notional = multiply(Decimal.fromInt(d.quantity), d.price);
  return (
    commission: multiply(notional, promoteRatio(rates.commissionRate)),
    tax: d.side == OrderSide.sell
        ? multiply(notional, promoteRatio(rates.sellTaxRate))
        : Decimal.zero,
  );
}

/// 의도 하나의 판정 — 새 체결 · 새 상태.
class FillVerdict {
  /// 판정을 만든다.
  const FillVerdict({
    required this.intent,
    required this.row,
    required this.deltas,
    required this.status,
    required this.expiredQty,
    required this.message,
  });

  /// 의도.
  final OpenIntent intent;

  /// 원주문 행(없으면 null — [status] = UNKNOWN).
  final DailyFillRow? row;

  /// 새 체결 행.
  final List<FillDelta> deltas;

  /// 새 상태.
  final IntentStatus status;

  /// 실효 수량(EXPIRED 일 때 · 이월 입력 — E10e2).
  final int expiredQty;

  /// 사유(EXPIRED · CANCELLED · UNKNOWN).
  final String? message;

  /// 원장에 쓸 것이 있는가.
  bool get changed => deltas.isNotEmpty || status != intent.status;
}

/// 체결조회 행 + 열린 의도 + 기록된 누적 → 판정(R38 Z3 · 순수).
///
/// [dayEnd] = 일 마감(실효를 쓴다) · false = 장중 동기화. 🔴 누적이 주문 수량을 넘으면 StateError(앞뒤가 안 맞는 응답).
List<FillVerdict> reconcileFills({
  required List<OpenIntent> intents,
  required List<DailyFillRow> rows,
  required Map<String, RecordedFill> recorded,
  required bool dayEnd,
}) {
  final Map<String, DailyFillRow> byNo = <String, DailyFillRow>{};
  for (final DailyFillRow r in rows) {
    if (r.isCancelRow) continue;
    if (byNo.containsKey(r.brokerOrderNo)) {
      throw StateError('같은 주문번호 원주문 행이 둘이다: ${r.brokerOrderNo}');
    }
    byNo[r.brokerOrderNo] = r;
  }
  final List<FillVerdict> out = <FillVerdict>[];
  for (final OpenIntent it in intents) {
    final DailyFillRow? row = byNo[it.brokerOrderNo];
    if (row == null) {
      // 장중에는 조회 지연일 수 있다 — 일 마감에만 결과 불명으로 본다.
      if (dayEnd) {
        out.add(
          FillVerdict(
            intent: it,
            row: null,
            deltas: const <FillDelta>[],
            status: IntentStatus.unknown,
            expiredQty: 0,
            message: 'ORDER_MISSING: 체결조회에 원주문 행이 없다(${it.brokerOrderNo})',
          ),
        );
      }
      continue;
    }
    if (row.cumFilledQty > it.quantity) {
      throw StateError('누적 체결이 주문 수량을 넘는다: ${it.brokerOrderNo}');
    }
    final List<FillDelta> deltas = fillDeltas(
      <DailyFillRow>[row],
      <String, RecordedFill>{
        if (recorded[it.brokerOrderNo] case final RecordedFill r)
          it.brokerOrderNo: r,
      },
    );
    final int cum = row.cumFilledQty;
    IntentStatus status = it.status;
    int expired = 0;
    String? message;
    if (cum == it.quantity) {
      status = IntentStatus.filled;
    } else if (dayEnd && row.remainingQty > 0) {
      // 🔴 마감 실효 — 취소가 아니다(04 §3-1 ③ v2.38).
      status = IntentStatus.expired;
      expired = row.remainingQty;
      message = 'EXPIRED: 마감 실효 $expired주';
    } else if (row.remainingQty == 0 && row.cancelConfirmedQty > 0) {
      status = IntentStatus.cancelled;
      message = 'CANCELLED: 취소 확인 ${row.cancelConfirmedQty}주';
    } else if (dayEnd) {
      // 잔여 0 · 취소 0 인데 덜 체결 — 남은 몫은 실효로 읽는다(이월 입력).
      status = IntentStatus.expired;
      expired = it.quantity - cum - row.cancelConfirmedQty;
      if (expired < 0) expired = 0;
      message = 'EXPIRED: 마감 실효 $expired주';
    } else if (cum > 0) {
      status = IntentStatus.partial;
    }
    out.add(
      FillVerdict(
        intent: it,
        row: row,
        deltas: deltas,
        status: status,
        expiredQty: expired,
        message: message,
      ),
    );
  }
  return out;
}

/// 원장에 쓸 체결 적용 한 벌(한 트랜잭션 · R38 Z4~Z6 · Z9).
class FillApplication {
  /// 적용을 만든다.
  const FillApplication({
    required this.verdict,
    required this.costs,
    required this.seenAtUtc,
  });

  /// 판정(원주문 행 있음).
  final FillVerdict verdict;

  /// 체결 행마다 추정 비용([FillVerdict.deltas] 와 같은 순서).
  final List<({Decimal commission, Decimal tax})> costs;

  /// 조회 시각(실행 행 `executed_at` · `authored_at`).
  final DateTime seenAtUtc;
}

/// 체결 원장 포트(R38 Z2) — 구현 = data_sync `SqliteOrderLedger`.
abstract interface class FillLedger {
  /// 그 집행일의 열린 의도(SUBMITTED · PARTIAL · 브로커 주문 있음).
  Future<List<OpenIntent>> openIntents(TradeDate tradeDate);

  /// 그 주문에 대해 기록한 누적(아직 없으면 null).
  Future<RecordedFill?> recordedFill(String brokerOrderNo);

  /// 체결 행 · 브로커 주문 누적 · 포지션 · 의도 상태를 **한 트랜잭션**으로 쓴다.
  Future<void> applyFill(FillApplication application);

  /// 열린 의도를 UNKNOWN 으로(일 마감 조회 실패 · 원주문 행 없음).
  Future<void> markUnresolved(String intentId, String message);
}

/// 동기화 결과.
class FillSyncReport {
  /// 결과를 만든다.
  const FillSyncReport({
    required this.applied,
    required this.unresolved,
    required this.unavailableAccounts,
  });

  /// 원장에 쓴 판정.
  final List<FillVerdict> applied;

  /// UNKNOWN 으로 보낸 의도와 사유.
  final List<(OpenIntent, String)> unresolved;

  /// 체결조회를 못 한 계좌(별칭).
  final List<String> unavailableAccounts;

  /// 실효된 의도(이월 입력 — E10e2).
  List<FillVerdict> get expired => <FillVerdict>[
    for (final FillVerdict v in applied)
      if (v.status == IntentStatus.expired) v,
  ];
}

/// 일 마감 확인 시각(KST) — 장 마감 15:30 뒤 여유 10분(R32 O3).
const Duration kDayEndCheckAfterKst = Duration(hours: 15, minutes: 40);

/// 체결 동기화 — 계좌마다 그날 체결조회 → 판정 → 적용(R38 Z7). [dayEnd] 면 [nowUtc] 가 [tradeDate] 15:40 KST 뒤여야 한다.
Future<FillSyncReport> runFillSync({
  required FillLedger ledger,
  required Map<String, OrderBroker> brokers,
  required TradeDate tradeDate,
  required DateTime nowUtc,
  required bool dayEnd,
  required FillCostRates costs,
}) async {
  if (dayEnd) {
    final DateTime checkAfter = DateTime.parse(
      '${tradeDate.yyyyMmDd}T00:00:00Z',
    ).add(kDayEndCheckAfterKst).subtract(const Duration(hours: 9));
    if (nowUtc.toUtc().isBefore(checkAfter)) {
      throw StateError('일 마감 확인은 ${tradeDate.yyyyMmDd} 15:40 KST 뒤에만 한다');
    }
  }
  final List<OpenIntent> open = await ledger.openIntents(tradeDate);
  final Map<String, List<OpenIntent>> byAccount = <String, List<OpenIntent>>{};
  for (final OpenIntent it in open) {
    (byAccount[it.account] ??= <OpenIntent>[]).add(it);
  }
  final List<FillVerdict> applied = <FillVerdict>[];
  final List<(OpenIntent, String)> unresolved = <(OpenIntent, String)>[];
  final List<String> unavailable = <String>[];
  final List<String> accounts = byAccount.keys.toList()..sort();
  for (final String account in accounts) {
    final List<OpenIntent> intents = byAccount[account]!;
    final OrderBroker? broker = brokers[account];
    List<DailyFillRow>? rows;
    String? failure;
    if (broker == null) {
      failure = '계좌 $account 의 브로커가 없다';
    } else {
      try {
        rows = await broker.dailyFills(tradeDate);
      } on Object catch (e) {
        failure = '체결조회 실패 — $e';
      }
    }
    if (rows == null) {
      unavailable.add(account);
      if (dayEnd) {
        // 🔴 확인 못 한 의도는 이월하지 않는다 — UNKNOWN 경로(04 §3-1 ③ ⑥).
        for (final OpenIntent it in intents) {
          final String message = 'DAY_END_UNAVAILABLE: $failure';
          await ledger.markUnresolved(it.intentId, message);
          unresolved.add((it, message));
        }
      }
      continue;
    }
    final Map<String, RecordedFill> recorded = <String, RecordedFill>{};
    for (final OpenIntent it in intents) {
      final RecordedFill? r = await ledger.recordedFill(it.brokerOrderNo);
      if (r != null) recorded[it.brokerOrderNo] = r;
    }
    for (final FillVerdict v in reconcileFills(
      intents: intents,
      rows: rows,
      recorded: recorded,
      dayEnd: dayEnd,
    )) {
      if (v.row == null) {
        await ledger.markUnresolved(v.intent.intentId, v.message!);
        unresolved.add((v.intent, v.message!));
        continue;
      }
      if (!v.changed) continue;
      await ledger.applyFill(
        FillApplication(
          verdict: v,
          costs: <({Decimal commission, Decimal tax})>[
            for (final FillDelta d in v.deltas) estimateFillCost(d, costs),
          ],
          seenAtUtc: nowUtc.toUtc(),
        ),
      );
      applied.add(v);
    }
  }
  return FillSyncReport(
    applied: applied,
    unresolved: unresolved,
    unavailableAccounts: unavailable,
  );
}

/// 다음 날 가드(04 §3-1 ③ ⑤ · R38 Z8) — 오늘 조회에 보인 **지난 날** 원주문 행.
List<DailyFillRow> staleOrderRows(List<DailyFillRow> rows, TradeDate today) =>
    <DailyFillRow>[
      for (final DailyFillRow r in rows)
        if (!r.isCancelRow && r.orderDate != today) r,
    ];
