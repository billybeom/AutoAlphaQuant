// 일일 대사 — 브로커 ↔ 원장(04 §3-5 · v2.33 X5 «정본 중심 별» 5쌍 · 4축 · 06 M1-10 · X5-2 · 설계 13 §8 R40 A1~A10).
//
// 🔴 이 판은 `CANON_BROKER` 한 쌍이다. 수량 축 · 체결 축(R31 누적수량 행 단위)만 차단 후보이고, 현금 축은 관측만 한다
//    (`cash_flow` 에 계좌 칸이 없어 계좌별 원장 현금을 셀 수 없다 · 결제일 모델 전 = 04 v2.33).
// 🔴 차단 승격 = **재대사 1회 뒤에도 같은 값으로 남은 것만**(04 v2.33 · 06 M1-10). 재대사에서 사라진 것 = 일시(로그만).
// 🔴 대사는 플래그를 **풀지 않는다** — 일치해도. 해제는 사람만(`clearRecon` · 04 §3-5 ①~④).
// 🔴 자동 수정 없음 — 어느 쪽이 맞는지 시스템은 모른다(04 §3-5). positions · executions 를 고치지 않는다.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../safety/incident.dart' show SafetyIncident, manualOrderIncidentOf;
import 'fills.dart';
import 'order_ports.dart';

/// 재대사 전 기다림(R40 A6 · 🟡 실전 키 때 재고).
const Duration kReconRecheckDelay = Duration(seconds: 30);

/// 해제 원인 코드(R40 A8) — 브로커 계열 6 + X7 6. 파생 7 은 주문을 막지 않으니 해제 사유가 아니다.
final Set<String> kReconClearOriginCodes = <String>{
  for (final String c in OriginCodes.writable)
    if (!OriginCodes.derived.contains(c)) c,
};

/// 브로커 계좌의 잔고(R40 A2).
class BrokerBalance {
  /// 잔고를 만든다.
  const BrokerBalance({required this.holdings, required this.cashKrw});

  /// 종목 → 보유 수량(0 은 넣지 않아도 된다).
  final Map<String, int> holdings;

  /// 예수금(원 · 관측만 — 모르면 null).
  final Decimal? cashKrw;
}

/// 잔고 포트(R40 A2) — 계좌 한 벌. 🟡 KIS 구현 = E10g(실응답 픽스처 뒤).
abstract interface class BrokerBalanceSource {
  /// 지금 잔고.
  Future<BrokerBalance> balance();
}

/// 원장 KR 보유 한 행(`positions`).
class LedgerHolding {
  /// 행을 만든다.
  const LedgerHolding(this.strategyId, this.symbol, this.quantity);

  /// strategy_id · 종목.
  final String strategyId, symbol;

  /// 수량.
  final int quantity;
}

/// 원장의 그날 브로커 주문 하나와 그 체결 합(`broker_orders` + `executions`).
class LedgerOrderFill {
  /// 행을 만든다.
  const LedgerOrderFill({
    required this.brokerOrderNo,
    required this.account,
    required this.symbol,
    required this.filledQty,
  });

  /// `{주문일}:{ODNO}`.
  final String brokerOrderNo;

  /// 계좌 별칭 · 종목.
  final String account, symbol;

  /// Σ executions.quantity.
  final int filledQty;
}

/// 어긋남의 종류(R40 A3 · A4).
enum ReconKind {
  /// 보유 수량이 다르다.
  quantity('QTY', LedgerAxis.quantity),

  /// 계좌를 모르는 전략의 보유(fail-closed).
  unmappedStrategy('UNMAPPED_STRATEGY', LedgerAxis.quantity),

  /// 원장에 없는 브로커 주문의 체결(수동 주문 후보).
  unknownOrder('UNKNOWN_ORDER', LedgerAxis.executionRow),

  /// 원장 체결 합 ≠ 브로커 누적.
  fillCount('FILL_COUNT', LedgerAxis.executionRow),

  /// 원장에는 체결이 있는데 브로커 행이 없다.
  ghostFill('GHOST_FILL', LedgerAxis.executionRow);

  const ReconKind(this.code, this.axis);

  /// delta JSON 의 표기.
  final String code;

  /// 축.
  final LedgerAxis axis;
}

/// 어긋남 하나.
class ReconDiff {
  /// 어긋남을 만든다.
  const ReconDiff({
    required this.account,
    required this.kind,
    required this.key,
    required this.ledger,
    required this.broker,
  });

  /// 계좌 별칭(맵에 없는 전략이면 strategy_id 앞에 `?`).
  final String account;

  /// 종류.
  final ReconKind kind;

  /// 종목 또는 주문번호.
  final String key;

  /// 원장 값 · 브로커 값(수량).
  final int ledger, broker;

  /// 축.
  LedgerAxis get axis => kind.axis;

  /// 같은 어긋남인가(계좌 · 종류 · 열쇠 · 두 값 — 재대사 잔존 판정).
  String get identity =>
      '${axis.wire}|$account|${kind.code}|$key|$ledger|$broker';

  /// 후보 원인 코드(화면 · 해제 안내용).
  List<String> get candidateOriginCodes => switch (kind) {
    ReconKind.unknownOrder => <String>[
      OriginCodes.manualOrder,
      OriginCodes.fillLag,
    ],
    ReconKind.ghostFill => <String>[
      OriginCodes.dbError,
      OriginCodes.brokerError,
    ],
    ReconKind.unmappedStrategy => <String>[OriginCodes.dbError],
    _ => <String>[
      OriginCodes.fillLag,
      OriginCodes.manualOrder,
      OriginCodes.corporateAction,
      OriginCodes.dbError,
    ],
  };

  /// delta JSON(`ledger_diff.delta`).
  String get deltaJson => jsonEncode(<String, Object?>{
    'account': account,
    'kind': kind.code,
    'key': key,
    'ledger': ledger,
    'broker': broker,
    'candidates': candidateOriginCodes,
  });

  /// 엔진 문장(`ledger_diff.delta_label`).
  String get label => switch (kind) {
    ReconKind.quantity => '$account · $key 보유 — 원장 $ledger주 · 브로커 $broker주',
    ReconKind.unmappedStrategy => '$key 보유 $ledger주 — 계좌를 모르는 전략(설정 맵에 없다)',
    ReconKind.unknownOrder => '$account · 원장에 없는 주문 $key 체결 $broker주',
    ReconKind.fillCount => '$account · 주문 $key 체결 — 원장 $ledger주 · 브로커 $broker주',
    ReconKind.ghostFill => '$account · 주문 $key 체결 $ledger주 — 브로커 조회에 없다',
  };

  /// JSON(로그용).
  Map<String, Object?> toJson() => <String, Object?>{
    'axis': axis.wire,
    'account': account,
    'kind': kind.code,
    'key': key,
    'ledger': ledger,
    'broker': broker,
  };
}

/// `ledger_diff.diff_id` — 내용 해시(같은 날 같은 어긋남 = 같은 id · R40 A7).
String ledgerDiffIdOf(TradeDate tradeDate, ReconDiff d) =>
    'ld-${sha256.convert(utf8.encode('${LedgerPair.canonBroker.wire}|${tradeDate.yyyyMmDd}|${d.identity}')).toString().substring(0, 24)}';

/// 계좌 하나의 대사(순수 · R40 A3 · A4). [holdings] = 그 계좌로 모인 원장 보유 · [fills] = 그 계좌의 그날 원장 주문.
List<ReconDiff> reconcileAccount({
  required String account,
  required BrokerBalance balance,
  required List<DailyFillRow> rows,
  required List<LedgerHolding> holdings,
  required List<LedgerOrderFill> fills,
}) {
  final List<ReconDiff> out = <ReconDiff>[];
  // 수량 축 — 종목마다 원장 합 ↔ 브로커.
  final Map<String, int> ledgerQty = <String, int>{};
  for (final LedgerHolding h in holdings) {
    ledgerQty[h.symbol] = (ledgerQty[h.symbol] ?? 0) + h.quantity;
  }
  final List<String> symbols = <String>{
    ...ledgerQty.keys,
    ...balance.holdings.keys,
  }.toList()..sort();
  for (final String s in symbols) {
    final int l = ledgerQty[s] ?? 0;
    final int b = balance.holdings[s] ?? 0;
    if (l != b) {
      out.add(
        ReconDiff(
          account: account,
          kind: ReconKind.quantity,
          key: s,
          ledger: l,
          broker: b,
        ),
      );
    }
  }
  // 체결 축 — 원주문 행(취소 행 제외) ↔ 원장 주문별 체결 합.
  final Map<String, LedgerOrderFill> byNo = <String, LedgerOrderFill>{
    for (final LedgerOrderFill f in fills) f.brokerOrderNo: f,
  };
  final Set<String> seen = <String>{};
  final List<DailyFillRow> originals =
      rows.where((DailyFillRow r) => !r.isCancelRow).toList()..sort(
        (DailyFillRow a, DailyFillRow b) =>
            a.brokerOrderNo.compareTo(b.brokerOrderNo),
      );
  for (final DailyFillRow r in originals) {
    final String no = r.brokerOrderNo;
    if (!seen.add(no)) {
      throw StateError('체결조회에 같은 원주문 행이 둘이다: $no');
    }
    final LedgerOrderFill? f = byNo[no];
    if (f == null) {
      if (r.cumFilledQty > 0) {
        out.add(
          ReconDiff(
            account: account,
            kind: ReconKind.unknownOrder,
            key: no,
            ledger: 0,
            broker: r.cumFilledQty,
          ),
        );
      }
      continue;
    }
    if (f.filledQty != r.cumFilledQty) {
      out.add(
        ReconDiff(
          account: account,
          kind: ReconKind.fillCount,
          key: no,
          ledger: f.filledQty,
          broker: r.cumFilledQty,
        ),
      );
    }
  }
  final List<LedgerOrderFill> ledgerOnly =
      fills
          .where(
            (LedgerOrderFill f) =>
                f.filledQty > 0 && !seen.contains(f.brokerOrderNo),
          )
          .toList()
        ..sort(
          (LedgerOrderFill a, LedgerOrderFill b) =>
              a.brokerOrderNo.compareTo(b.brokerOrderNo),
        );
  for (final LedgerOrderFill f in ledgerOnly) {
    out.add(
      ReconDiff(
        account: account,
        kind: ReconKind.ghostFill,
        key: f.brokerOrderNo,
        ledger: f.filledQty,
        broker: 0,
      ),
    );
  }
  return out;
}

/// 대사 기록의 결론(`reconciliation_log.action_taken`).
enum ReconAction {
  /// 모두 맞다.
  matched('MATCHED'),

  /// 첫 판 어긋남이 재대사에서 사라졌다(로그만).
  transient('TRANSIENT'),

  /// 재대사 뒤에도 남았다 — 차단.
  blocked('BLOCKED'),

  /// 어긋남은 없지만 대사 못 한 계좌가 있다.
  unavailable('UNAVAILABLE');

  const ReconAction(this.code);

  /// 저장 표기.
  final String code;
}

/// 원장에 남길 대사 한 판(R40 A7).
class ReconRecord {
  /// 기록을 만든다.
  const ReconRecord({
    required this.runAtUtc,
    required this.tradeDate,
    required this.action,
    required this.blocking,
    required this.discrepanciesJson,
  });

  /// 실행 시각.
  final DateTime runAtUtc;

  /// 집행일(`ledger_diff.authored_date`).
  final TradeDate tradeDate;

  /// 결론.
  final ReconAction action;

  /// 차단 어긋남(ledger_diff OPEN 행 · 비지 않으면 RECON_MISMATCH).
  final List<ReconDiff> blocking;

  /// `reconciliation_log.discrepancies`.
  final String discrepanciesJson;

  /// `reconciliation_log.matched`.
  bool get matched => action == ReconAction.matched;
}

/// 해제 한 건(R40 A8).
class ReconClearance {
  /// 해제를 만든다.
  const ReconClearance({
    required this.originCode,
    required this.decisionId,
    required this.clearedBy,
    required this.clearedAtUtc,
    this.incident,
  });

  /// 원인 코드 · 저널 id · 해제한 사람.
  final String originCode, decisionId, clearedBy;

  /// 해제 시각.
  final DateTime clearedAtUtc;

  /// 🆕 E13e2 — MANUAL_ORDER 면 같은 트랜잭션에 여는 SEV2(R63 V1 · 그 밖 null).
  final SafetyIncident? incident;
}

/// 대사 원장 포트(R40 A2) — 구현 = data_sync `SqliteOrderLedger`.
abstract interface class ReconLedger {
  /// KR 보유 전부(`positions` · market = KR).
  Future<List<LedgerHolding>> krHoldings();

  /// [tradeDate] 의도의 브로커 주문과 체결 합.
  Future<List<LedgerOrderFill>> orderFills(TradeDate tradeDate);

  /// 대사 한 판을 한 트랜잭션으로 남기고 매긴 `recon_id` 를 돌려준다 — 로그 + 차단 행 + (차단이면) 플래그.
  /// 🔴 플래그를 풀지 않는다. 🔴 id 는 원장이 매긴다(같은 시각 두 판도 겹치지 않게 — 시각 + 일련).
  Future<String> recordReconciliation(ReconRecord record);

  /// RECON_MISMATCH 가 서 있는가.
  Future<bool> reconBlocked();

  /// [decisionId] 가 `kind = 'RECON_CLEAR'` 저널인가.
  Future<bool> reconClearJournalExists(String decisionId);

  /// 해제 — 플래그 · OPEN 차단 행 RESOLVED · 해제 로그를 한 트랜잭션.
  Future<void> clearReconBlock(ReconClearance clearance);
}

/// 대사 결과.
class ReconReport {
  /// 결과를 만든다.
  const ReconReport({
    required this.reconId,
    required this.action,
    required this.blocking,
    required this.transient,
    required this.unavailable,
    required this.cashKrw,
    required this.rechecked,
  });

  /// `recon_id`.
  final String reconId;

  /// 결론.
  final ReconAction action;

  /// 재대사 뒤에도 남은 것(차단).
  final List<ReconDiff> blocking;

  /// 첫 판에만 · 재대사에만 보인 것(로그만).
  final List<ReconDiff> transient;

  /// 대사 못 한 계좌(조회 실패 · 브로커 없음).
  final List<String> unavailable;

  /// 계좌 → 브로커 예수금(관측만 · R40 A5).
  final Map<String, Decimal?> cashKrw;

  /// 재대사를 했는가.
  final bool rechecked;

  /// 알림 코드(P0 `RECON_MISMATCH` — 발송 = E11).
  Set<String> get alertCodes => <String>{
    if (blocking.isNotEmpty) AlertCodes.reconMismatch,
  };
}

class _Pass {
  _Pass(this.diffs, this.unavailable, this.cash);

  final List<ReconDiff> diffs;
  final List<String> unavailable;
  final Map<String, Decimal?> cash;
}

Future<_Pass> _pass({
  required ReconLedger ledger,
  required Map<String, OrderBroker> brokers,
  required Map<String, BrokerBalanceSource> balances,
  required Map<String, String> accountByStrategy,
  required TradeDate tradeDate,
}) async {
  final List<LedgerHolding> holdings = await ledger.krHoldings();
  final List<LedgerOrderFill> fills = await ledger.orderFills(tradeDate);
  final List<ReconDiff> diffs = <ReconDiff>[];
  final Map<String, List<LedgerHolding>> byAccount =
      <String, List<LedgerHolding>>{};
  for (final LedgerHolding h in holdings) {
    final String? account = accountByStrategy[h.strategyId];
    if (account == null) {
      if (h.quantity != 0) {
        diffs.add(
          ReconDiff(
            account: '?${h.strategyId}',
            kind: ReconKind.unmappedStrategy,
            key: h.symbol,
            ledger: h.quantity,
            broker: 0,
          ),
        );
      }
      continue;
    }
    (byAccount[account] ??= <LedgerHolding>[]).add(h);
  }
  final List<String> accounts = <String>{
    ...accountByStrategy.values,
    ...balances.keys,
  }.toList()..sort();
  final List<String> unavailable = <String>[];
  final Map<String, Decimal?> cash = <String, Decimal?>{};
  for (final String account in accounts) {
    final OrderBroker? broker = brokers[account];
    final BrokerBalanceSource? source = balances[account];
    BrokerBalance balance;
    List<DailyFillRow> rows;
    try {
      if (broker == null || source == null) {
        throw StateError('계좌 $account 의 브로커가 없다');
      }
      balance = await source.balance();
      rows = await broker.dailyFills(tradeDate);
    } on Object {
      unavailable.add(account);
      continue;
    }
    cash[account] = balance.cashKrw;
    diffs.addAll(
      reconcileAccount(
        account: account,
        balance: balance,
        rows: rows,
        holdings: byAccount[account] ?? const <LedgerHolding>[],
        fills: <LedgerOrderFill>[
          for (final LedgerOrderFill f in fills)
            if (f.account == account) f,
        ],
      ),
    );
  }
  return _Pass(diffs, unavailable, cash);
}

/// 일일 대사 실행(R40 A6 · A7) — 장 시작 전 1회 + 주문 배치 직후(배선 = E11).
///
/// 첫 판에 어긋남이 있으면 [recheckDelay] 뒤 한 번 더 읽고, 두 판에 같은 값으로 남은 것만 차단한다.
Future<ReconReport> runReconciliation({
  required ReconLedger ledger,
  required Map<String, OrderBroker> brokers,
  required Map<String, BrokerBalanceSource> balances,
  required Map<String, String> accountByStrategy,
  required TradeDate tradeDate,
  required DateTime Function() nowUtc,
  Duration recheckDelay = kReconRecheckDelay,
  Future<void> Function(Duration) sleep = _sleep,
}) async {
  final DateTime started = nowUtc().toUtc();
  Future<_Pass> once() => _pass(
    ledger: ledger,
    brokers: brokers,
    balances: balances,
    accountByStrategy: accountByStrategy,
    tradeDate: tradeDate,
  );
  final _Pass first = await once();
  _Pass? second;
  List<ReconDiff> blocking = const <ReconDiff>[];
  List<ReconDiff> transient = const <ReconDiff>[];
  if (first.diffs.isNotEmpty) {
    await sleep(recheckDelay);
    second = await once();
    final Set<String> again = <String>{
      for (final ReconDiff d in second.diffs) d.identity,
    };
    final Set<String> before = <String>{
      for (final ReconDiff d in first.diffs) d.identity,
    };
    blocking = <ReconDiff>[
      for (final ReconDiff d in first.diffs)
        if (again.contains(d.identity)) d,
    ];
    transient = <ReconDiff>[
      for (final ReconDiff d in first.diffs)
        if (!again.contains(d.identity)) d,
      for (final ReconDiff d in second.diffs)
        if (!before.contains(d.identity)) d,
    ];
  }
  final _Pass last = second ?? first;
  final List<String> unavailable = <String>{
    ...first.unavailable,
    ...last.unavailable,
  }.toList()..sort();
  final ReconAction action = blocking.isNotEmpty
      ? ReconAction.blocked
      : transient.isNotEmpty
      ? ReconAction.transient
      : unavailable.isNotEmpty
      ? ReconAction.unavailable
      : ReconAction.matched;
  final String json = jsonEncode(<String, Object?>{
    'trade_date': tradeDate.yyyyMmDd,
    'first': <Object?>[for (final ReconDiff d in first.diffs) d.toJson()],
    if (second != null)
      'recheck': <Object?>[for (final ReconDiff d in second.diffs) d.toJson()],
    'unavailable': unavailable,
    'cash_krw_observed': <String, Object?>{
      for (final MapEntry<String, Decimal?> e in last.cash.entries)
        e.key: e.value?.toString(),
    },
  });
  final String reconId = await ledger.recordReconciliation(
    ReconRecord(
      runAtUtc: started,
      tradeDate: tradeDate,
      action: action,
      blocking: blocking,
      discrepanciesJson: json,
    ),
  );
  return ReconReport(
    reconId: reconId,
    action: action,
    blocking: blocking,
    transient: transient,
    unavailable: unavailable,
    cashKrw: last.cash,
    rechecked: second != null,
  );
}

Future<void> _sleep(Duration d) => Future<void>.delayed(d);

/// 해제에 저널이 없다(04 §3-5 ③ · v2.15 공통 예외).
class JournalRequired implements Exception {
  /// 예외를 만든다.
  const JournalRequired(this.message);

  /// 사유.
  final String message;

  @override
  String toString() => 'JournalRequired: $message';
}

/// 해제 전제가 모자란다(04 §3-5 ①②④ · 4차 SF-06).
class RecheckRequired implements Exception {
  /// 예외를 만든다.
  const RecheckRequired(this.message);

  /// 사유.
  final String message;

  @override
  String toString() => 'RecheckRequired: $message';
}

/// 해제 결과.
class ReconClearOutcome {
  /// 결과를 만든다.
  const ReconClearOutcome({
    required this.originCode,
    required this.postmortemDueUtc,
  });

  /// 원인 코드.
  final String originCode;

  /// MANUAL_ORDER 면 SEV2 postmortem 기한(여는 것은 E13) · 그 밖 null.
  final DateTime? postmortemDueUtc;
}

/// RECON_MISMATCH 해제(04 §3-5 ①~④ fail-closed · R40 A8) — 텔레그램 `/clear_recon` · 앱 해제의 유일한 길.
Future<ReconClearOutcome> clearRecon(
  ReconLedger ledger, {
  required String originCode,
  required String decisionId,
  required String clearedBy,
  required DateTime nowUtc,
}) async {
  if (decisionId.trim().isEmpty ||
      !await ledger.reconClearJournalExists(decisionId)) {
    throw JournalRequired('대사 해제 저널(kind = RECON_CLEAR)이 없다: «$decisionId»');
  }
  if (!kReconClearOriginCodes.contains(originCode)) {
    throw RecheckRequired('원인 코드가 열거형 밖이다: «$originCode»');
  }
  if (clearedBy.trim().isEmpty) {
    throw ArgumentError.value(clearedBy, 'clearedBy', '비었다');
  }
  if (!await ledger.reconBlocked()) {
    throw StateError('RECON_MISMATCH 가 서 있지 않다');
  }
  final DateTime at = nowUtc.toUtc();
  // 🆕 E13e2 — 04 §3-5 ④ «MANUAL_ORDER 면 SEV2 postmortem(7일)을 함께 연다» = 해제와 같은 트랜잭션(R63 V1).
  final SafetyIncident? incident = originCode == OriginCodes.manualOrder
      ? manualOrderIncidentOf(decisionId: decisionId, clearedAtUtc: at)
      : null;
  await ledger.clearReconBlock(
    ReconClearance(
      originCode: originCode,
      decisionId: decisionId,
      clearedBy: clearedBy,
      clearedAtUtc: at,
      incident: incident,
    ),
  );
  return ReconClearOutcome(
    originCode: originCode,
    postmortemDueUtc: incident?.dueAtUtc,
  );
}
