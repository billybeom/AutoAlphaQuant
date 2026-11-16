// X1-4 갭 재구성 계획(순수 · 설계 13 §8 R124 I1~I8 · 06 :266 · 청사진 X1 :418 · 08 그림 9-2 · SPEC v2.42 ④ · v2.45 ③).
//
// 🔴 갭 창 = [백업 authored 날 · 복구 날 − 1](한국 날) · KR 세션만 — 그 창의 브로커 기록은 KIS 가 정본.
// 🔴 원장에 없는 브로커 체결 = 복구 행(합성 의도 · 브로커 주문 · 체결 `BROKER_RECOVERED`) — authored = 복구 시각이라
//    지난 날의 day_hash 는 그대로다.
// 🔴 «봇 전용 계좌» 위반 = 복원 보유 + 갭 체결 ≠ 브로커 보유 · 중간 음수 · 전략 대응 없음 → 재개 막힘.
// 🔴 전략 내부 상태는 복원값 대신 다시 센다 · 브레이커는 완화하지 않는다 · 갭 날 평가는 보간하지 않는다.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, ResumeMode, TradeDate;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar;
import '../ops/ledger_views.dart' show kstDateText;
import '../orders/fills.dart'
    show
        DailyFillRow,
        averageFillPrice,
        brokerOrderNoOf,
        executionIdOf,
        recordedFillJson;
import '../orders/order_ports.dart' show IntentStatus;
import '../resume/resume_gap.dart' show ResumeLadder, resumeModeOf;
import '../risk/breaker.dart' show BreakerLevel;

final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');

DateTime _date(String d) {
  if (!_day.hasMatch(d)) throw ArgumentError.value(d, 'date', '날 꼴');
  return DateTime.parse('${d}T00:00:00Z');
}

String _text(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 복구 사유 코드(`order_intents.error_message` · 계약 등재 = E16i 전 문자열).
const String kX1RecoveredReason = 'X1_RECOVERED';

/// 갭 창(양 끝 포함 · 한국 날).
class GapWindow {
  const GapWindow._(this.fromDate, this.toDate);

  /// 첫 날(백업 authored 날).
  final String fromDate;

  /// 끝 날(복구 날 − 1).
  final String toDate;
}

/// 🔴 갭 창 — 백업 날 ≥ 복구 날 = null(빈 창).
GapWindow? gapWindowOf({
  required String backupAuthoredDate,
  required DateTime recoveryAtUtc,
}) {
  final DateTime from = _date(backupAuthoredDate);
  final DateTime recovery = _date(kstDateText(recoveryAtUtc));
  if (!from.isBefore(recovery)) return null;
  return GapWindow._(
    backupAuthoredDate,
    _text(recovery.subtract(const Duration(days: 1))),
  );
}

/// 갭 창의 KR 세션(조회할 주문일 · 날 차례).
List<TradeDate> gapSessionsOf(GapWindow w, ExchangeCalendar kr) {
  final List<TradeDate> out = <TradeDate>[];
  DateTime d = _date(w.fromDate);
  final DateTime end = _date(w.toDate);
  while (!d.isAfter(end)) {
    final TradeDate t = TradeDate(_text(d));
    if (kr.isSession(t)) out.add(t);
    d = d.add(const Duration(days: 1));
  }
  return out;
}

/// 🔴 백업 갭(달력일) = 복구 날 − 백업 날(음수 = 0).
int backupGapDaysOf({
  required String backupAuthoredDate,
  required DateTime recoveryAtUtc,
}) {
  final int d = _date(kstDateText(recoveryAtUtc))
      .difference(_date(backupAuthoredDate))
      .inDays;
  return d < 0 ? 0 : d;
}

/// 갭 재개 모드 — 세션 갭 · 백업 갭을 `resumeModeOf` 그대로(백업 갭 ≥ 기준 = RECOVERY_FULL).
ResumeMode gapResumeModeOf({
  required int gapSessions,
  required String backupAuthoredDate,
  required DateTime recoveryAtUtc,
  required ResumeLadder ladder,
}) => resumeModeOf(
  gapSessions: gapSessions,
  backupGapDays: backupGapDaysOf(
    backupAuthoredDate: backupAuthoredDate,
    recoveryAtUtc: recoveryAtUtc,
  ),
  ladder: ladder,
);

/// 🔴 복구 대상 — 취소 행 · 누적 체결 0 · 원장(복원)에 있는 번호를 빼고 · 같은 번호는 한 번(마지막 행).
List<DailyFillRow> gapFillsToRecover(
  Iterable<DailyFillRow> rows, {
  required Set<String> knownBrokerOrderNos,
}) {
  final Map<String, DailyFillRow> byNo = <String, DailyFillRow>{};
  for (final DailyFillRow r in rows) {
    if (r.isCancelRow || r.cumFilledQty <= 0) continue;
    final String no = brokerOrderNoOf(r.orderDate, r.odno);
    if (knownBrokerOrderNos.contains(no)) continue;
    byNo[no] = r;
  }
  final List<String> keys = byNo.keys.toList()..sort();
  return <DailyFillRow>[for (final String k in keys) byNo[k]!];
}

/// 🔴 복구 의도의 종결 상태 — 체결 동기와 같은 규칙(누적 = 주문 = FILLED · 잔량 0 ∧ 취소 확인 = CANCELLED · 그 밖 = EXPIRED).
IntentStatus recoveredStatusOf(DailyFillRow r) {
  if (r.cumFilledQty == r.orderQty) return IntentStatus.filled;
  if (r.remainingQty == 0 && r.cancelConfirmedQty > 0) {
    return IntentStatus.cancelled;
  }
  return IntentStatus.expired;
}

/// 복구 행 한 묶음(합성 의도 · 브로커 주문 · 체결 — 쓰기 재료).
class RecoveredFillPlan {
  const RecoveredFillPlan._({
    required this.intentId,
    required this.idempotencyKey,
    required this.tradeDate,
    required this.account,
    required this.strategyId,
    required this.symbol,
    required this.side,
    required this.orderQuantity,
    required this.limitPrice,
    required this.status,
    required this.decisionId,
    required this.configHash,
    required this.createdAtUtc,
    required this.brokerOrderNo,
    required this.submittedAtUtc,
    required this.filledQty,
    required this.remainingQty,
    required this.rawResponse,
    required this.executionId,
    required this.executionPrice,
  });

  /// 의도 id(`rcv-{주문일}:{ODNO}`).
  final String intentId;

  /// 멱등 키(sha256 16진 64).
  final String idempotencyKey;

  /// 주문일.
  final TradeDate tradeDate;

  /// 계좌.
  final String account;

  /// 전략.
  final String strategyId;

  /// 종목.
  final String symbol;

  /// 방향.
  final OrderSide side;

  /// 주문 수량.
  final int orderQuantity;

  /// 주문 단가(없음 = 시장가).
  final Decimal? limitPrice;

  /// 종결 상태.
  final IntentStatus status;

  /// 결정(`{비상 선언 결정}@{주문일}`).
  final String decisionId;

  /// 지금 판 config_hash.
  final String configHash;

  /// 생성 = 복구 시각(🔴 해시 축 · 체결 authored 도 이 값).
  final DateTime createdAtUtc;

  /// 브로커 주문 번호(`{주문일}:{ODNO}`).
  final String brokerOrderNo;

  /// 제출 = 주문일 + 주문 시각(한국 · 없으면 주문일 09:00).
  final DateTime submittedAtUtc;

  /// 누적 체결 수량.
  final int filledQty;

  /// 잔량.
  final int remainingQty;

  /// 브로커 원문(`recordedFillJson` — 뒤 대사가 읽는다).
  final String rawResponse;

  /// 체결 id(`{번호}#{누적}`).
  final String executionId;

  /// 체결 가격(누적 금액 ÷ 누적 수량 — 체결 동기와 같은 `averageFillPrice`).
  final double executionPrice;

  /// 체결 원천.
  String get fillOrigin => 'BROKER_RECOVERED';

  /// 사유 코드.
  String get reasonCode => kX1RecoveredReason;
}

DateTime _submittedAt(DailyFillRow r) {
  final String t = r.orderTime ?? '090000';
  final String hh = t.length >= 6 ? t.substring(0, 2) : '09';
  final String mm = t.length >= 6 ? t.substring(2, 4) : '00';
  final String ss = t.length >= 6 ? t.substring(4, 6) : '00';
  return DateTime.parse('${r.orderDate.yyyyMmDd}T$hh:$mm:$ss+09:00').toUtc();
}

/// 🔴 복구 행 계획 — 결정 · config_hash · 전략은 호출자(대응 없음은 [gapViolationsOf] 가 먼저 막는다).
RecoveredFillPlan recoveredFillPlanOf(
  DailyFillRow r, {
  required String account,
  required String strategyId,
  required String declarationDecisionId,
  required String configHash,
  required DateTime recoveryAtUtc,
}) {
  if (r.isCancelRow || r.cumFilledQty <= 0) {
    throw ArgumentError('취소 행 · 체결 0 은 복구 대상이 아니다: ${r.odno}');
  }
  if (declarationDecisionId.trim().isEmpty || configHash.isEmpty) {
    throw ArgumentError('결정 · config_hash 는 비울 수 없다');
  }
  final String no = brokerOrderNoOf(r.orderDate, r.odno);
  final DateTime at = recoveryAtUtc.toUtc();
  return RecoveredFillPlan._(
    intentId: 'rcv-$no',
    idempotencyKey: sha256
        .convert(utf8.encode('$kX1RecoveredReason|$no'))
        .toString(),
    tradeDate: r.orderDate,
    account: account,
    strategyId: strategyId,
    symbol: r.symbol,
    side: r.side,
    orderQuantity: r.orderQty,
    limitPrice: r.orderPrice,
    status: recoveredStatusOf(r),
    decisionId: '$declarationDecisionId@${r.orderDate.yyyyMmDd}',
    configHash: configHash,
    createdAtUtc: at,
    brokerOrderNo: no,
    submittedAtUtc: _submittedAt(r),
    filledQty: r.cumFilledQty,
    remainingQty: r.remainingQty,
    rawResponse: recordedFillJson(r, at),
    executionId: executionIdOf(no, r.cumFilledQty),
    executionPrice: averageFillPrice(r)!,
  );
}

/// «봇 전용 계좌» 위반 종류.
enum GapViolationKind {
  /// 복원 보유 + 갭 체결 ≠ 브로커 보유.
  mismatch('GAP_HOLDING_MISMATCH'),

  /// 보유보다 많이 팔았다(중간 음수).
  oversold('GAP_OVERSOLD'),

  /// 전략 대응이 없다(복구 의도를 지을 수 없다).
  unmapped('GAP_UNMAPPED_STRATEGY');

  const GapViolationKind(this.wire);

  /// 글자.
  final String wire;
}

/// 위반 한 건.
class GapViolation {
  const GapViolation(this.kind, this.symbol, {this.ledgerAfter, this.broker});

  /// 종류.
  final GapViolationKind kind;

  /// 종목.
  final String symbol;

  /// 복원 + 갭 체결 수량(대응 없음 = null).
  final int? ledgerAfter;

  /// 브로커 보유(대응 없음 = null).
  final int? broker;
}

/// 🔴 한 계좌의 위반 — 전략 대응 없음 → 날 · 시각 차례로 더해 중간 음수 → 끝 수량 ≠ 브로커(종목 차례).
List<GapViolation> gapViolationsOf({
  required Map<String, int> restoredHoldings,
  required Iterable<DailyFillRow> recovered,
  required Map<String, int> brokerHoldings,
  required bool Function(String symbol) strategyMapped,
}) {
  final List<GapViolation> out = <GapViolation>[];
  final List<DailyFillRow> fills = recovered.toList()
    ..sort((DailyFillRow a, DailyFillRow b) {
      final int d = a.orderDate.yyyyMmDd.compareTo(b.orderDate.yyyyMmDd);
      if (d != 0) return d;
      final int t = (a.orderTime ?? '').compareTo(b.orderTime ?? '');
      return t != 0 ? t : a.odno.compareTo(b.odno);
    });
  final Set<String> unmapped = <String>{
    for (final DailyFillRow f in fills)
      if (!strategyMapped(f.symbol)) f.symbol,
  };
  for (final String s in unmapped.toList()..sort()) {
    out.add(GapViolation(GapViolationKind.unmapped, s));
  }
  final Map<String, int> running = <String, int>{...restoredHoldings};
  final Set<String> oversold = <String>{};
  for (final DailyFillRow f in fills) {
    final int q = f.side == OrderSide.buy ? f.cumFilledQty : -f.cumFilledQty;
    final int next = (running[f.symbol] ?? 0) + q;
    running[f.symbol] = next;
    if (next < 0) oversold.add(f.symbol);
  }
  final Set<String> symbols = <String>{...running.keys, ...brokerHoldings.keys};
  for (final String s in symbols.toList()..sort()) {
    final int mine = running[s] ?? 0;
    final int theirs = brokerHoldings[s] ?? 0;
    if (oversold.contains(s)) {
      out.add(
        GapViolation(
          GapViolationKind.oversold,
          s,
          ledgerAfter: mine,
          broker: theirs,
        ),
      );
    } else if (mine != theirs) {
      out.add(
        GapViolation(
          GapViolationKind.mismatch,
          s,
          ledgerAfter: mine,
          broker: theirs,
        ),
      );
    }
  }
  return out;
}

/// 다시 셀 것(차례 · 🔴 복원값을 믿지 않는다).
enum GapRecompute {
  /// 포지션(체결에서).
  positions,

  /// 전략 상태.
  strategyState,

  /// 램프.
  ramp,

  /// 브레이커 재생(완화 0 — [conservativeBreakerLevel]).
  breakerReplay,

  /// 갭 날 국면 행(`source = BACKFILL`).
  regimeBackfill,
}

/// 재구성 차례.
const List<GapRecompute> kGapRecomputeOrder = GapRecompute.values;

/// 🔴 재개 때 브레이커 = 갭 전 레벨과 재생 레벨 중 무거운 쪽(완화 0).
BreakerLevel conservativeBreakerLevel(
  BreakerLevel beforeGap,
  BreakerLevel replayed,
) => replayed.index > beforeGap.index ? replayed : beforeGap;

/// 복구 봉인 코드(계약 등재 = E16i 전 문자열).
abstract final class RecoverySealCodes {
  /// 갭 재구성이 끝나지 않았다.
  static const String inProgress = 'X1_RECOVERY_IN_PROGRESS';

  /// RECOVERY_FULL — 사람의 R-01 «잔고 승계 새 시작»까지 안전 정지.
  static const String full = 'X1_RECOVERY_FULL';
}

/// 🔴 복구 봉인 — 재구성 전 · RECOVERY_FULL = 주문 거부 · 그 밖 = null(RECOVERY_DRY 는 dryRun 이 주문 0 을 보장).
String? recoveryOrderSealCode({
  required bool gapRebuildDone,
  required ResumeMode mode,
}) {
  if (!gapRebuildDone) return RecoverySealCodes.inProgress;
  if (mode == ResumeMode.recoveryFull) return RecoverySealCodes.full;
  return null;
}
