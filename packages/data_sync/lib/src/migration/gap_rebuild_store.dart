// X1-4 갭 재구성 적용(설계 13 §8 R137 N5~N10 · SPEC v2.45 04 §3-1 ③ · 앱 06 X1-4 · core `gap_rebuild.dart`).
//
// 🔴 갭 창 = 매니페스트 날 ~ 복구 전날(복구 시각 = RESTORED 행 · 고정) · KR 세션마다 계좌마다 `dailyFills` = 정본.
// 🔴 위반이 하나라도 있으면(전 계좌 먼저 다 센다) = `recordReconciliation`(BLOCKED · diff · `RECON_MISMATCH`) ·
//    복구 행 0 · GAP_REBUILT 0(다시 돌리면 다시 센다).
// 🔴 위반 0 = 한 트랜잭션: 의도 · 브로커 주문 · 체결(`BROKER_RECOVERED` · executed_at = 주문일 주문 시각 ·
//    authored_at = 지금 신뢰 시각 — 지난 day_hash 그대로) · 포지션(복원 포지션을 씨앗으로 둔 재생) · GAP_REBUILT.
// 🔴 종목 → 전략 = 그 계좌 전략 가운데 복원 포지션에 그 종목이 있는 전략 하나 · 없으면 의도 이력 하나 · 그 밖 = 대응 없음.
// 🟡 전략 내부 상태 재계산(브레이커 · DD 기준점 · 램프 · 국면) · 기동 합성 = E16t.

import 'dart:convert' show jsonEncode;

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show FillKind, OperatingMode, OrderSide, TradeDate;
import 'package:sqlite3/sqlite3.dart';

import '../local/order_ledger.dart' show SqliteOrderLedger;
import '../local/position_replay_sql.dart' show writeReplayedPosition;
import '../market/market_store.dart' show inLedgerTransaction;
import 'recovery_journal_store.dart'
    show RecoveryCodes, RecoveryRun, latestRecoveryOf, recordGapRebuilt;

const String _market = 'KR';

// 씨앗 행의 «결정 없음»(포지션 `entry_decision_id` NULL 을 재생에 실어 나른다).
const String _noDecision = '';

/// 갭 재구성 보고.
class GapRebuildReport {
  const GapRebuildReport._({
    this.rejectCode,
    this.alreadyDone = false,
    this.violations = const <String, List<GapViolation>>{},
    this.reconId,
    this.recovered = const <String, List<String>>{},
    this.sessions = 0,
  });

  /// 거부(복원 없음 · 신뢰 시각 모름).
  final String? rejectCode;

  /// 이미 끝났다(브로커를 부르지 않았다).
  final bool alreadyDone;

  /// 계좌 → 위반(있으면 차단 · 복구 행 0).
  final Map<String, List<GapViolation>> violations;

  /// 차단 기록 `reconciliation_log.recon_id`.
  final String? reconId;

  /// 계좌 → 복구한 의도 id.
  final Map<String, List<String>> recovered;

  /// 조회한 KR 세션 수.
  final int sessions;

  /// 막혔나(위반).
  bool get blocked => violations.isNotEmpty;

  /// 끝났나(이번에 · 또는 이미).
  bool get done => rejectCode == null && !blocked;
}

/// 새 폰 갭 재구성(복원한 live 원장).
class SqliteGapRebuild {
  /// 만든다 — [ledger] = 같은 원장(차단 기록 = `recordReconciliation`).
  SqliteGapRebuild(
    this._db, {
    required this.deviceId,
    required this._trusted,
    required this._kr,
    required this._ledger,
  });

  final Database _db;
  final TrustedClock _trusted;
  final ExchangeCalendar _kr;
  final SqliteOrderLedger _ledger;

  /// 이 기기(새 폰).
  final String deviceId;

  /// 🔴 한 번 돈다 — [brokers] = 계좌 → 브로커 · [accountByStrategy] = 전략 → 계좌 ·
  /// [configHash] · [operatingMode] = 복구 의도 칸 · [costs] = 비용 추정.
  Future<GapRebuildReport> run({
    required Map<String, AccountBroker> brokers,
    required Map<String, String> accountByStrategy,
    required String configHash,
    required OperatingMode operatingMode,
    required FillCostRates costs,
  }) async {
    final RecoveryRun? r = latestRecoveryOf(_db, deviceId);
    if (r == null) {
      return const GapRebuildReport._(rejectCode: RecoveryCodes.notRestored);
    }
    if (r.gapRebuilt) return const GapRebuildReport._(alreadyDone: true);
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) {
      return const GapRebuildReport._(
        rejectCode: MigrationStartCodes.trustedTimeUnknown,
      );
    }
    final GapWindow? window = gapWindowOf(
      backupAuthoredDate: r.manifest.authoredDate,
      recoveryAtUtc: r.restoredAtUtc,
    );
    final List<TradeDate> sessions = window == null
        ? const <TradeDate>[]
        : gapSessionsOf(window, _kr);
    final Set<String> known = <String>{
      for (final Row x in _db.select(
        'SELECT broker_order_no FROM broker_orders',
      ))
        x['broker_order_no'] as String,
    };
    final List<String> accounts = brokers.keys.toList()..sort();
    final Map<String, List<DailyFillRow>> toRecover =
        <String, List<DailyFillRow>>{};
    final Map<String, List<GapViolation>> violations =
        <String, List<GapViolation>>{};
    final Map<String, Map<String, int>> restoredBy =
        <String, Map<String, int>>{};
    final Map<String, Map<String, int>> brokerBy = <String, Map<String, int>>{};
    for (final String account in accounts) {
      final AccountBroker broker = brokers[account]!;
      final List<DailyFillRow> rows = <DailyFillRow>[
        for (final TradeDate s in sessions) ...await broker.dailyFills(s),
      ];
      final List<DailyFillRow> recover = gapFillsToRecover(
        rows,
        knownBrokerOrderNos: known,
      );
      final Map<String, int> held = (await broker.balance()).holdings;
      final Map<String, int> restored = _restoredHoldings(
        account,
        accountByStrategy,
      );
      final List<GapViolation> v = gapViolationsOf(
        restoredHoldings: restored,
        recovered: recover,
        brokerHoldings: held,
        strategyMapped: (String s) =>
            _strategyFor(account, s, accountByStrategy) != null,
      );
      toRecover[account] = recover;
      restoredBy[account] = restored;
      brokerBy[account] = held;
      if (v.isNotEmpty) violations[account] = v;
    }
    if (violations.isNotEmpty) {
      final String reconId = await _ledger.recordReconciliation(
        ReconRecord(
          runAtUtc: now,
          tradeDate: TradeDate(kstDateText(now)),
          action: ReconAction.blocked,
          blocking: <ReconDiff>[
            for (final MapEntry<String, List<GapViolation>> e
                in violations.entries)
              for (final GapViolation g in e.value)
                ReconDiff(
                  account: e.key,
                  kind: g.kind == GapViolationKind.unmapped
                      ? ReconKind.unmappedStrategy
                      : ReconKind.quantity,
                  key: g.symbol,
                  ledger: g.ledgerAfter ?? restoredBy[e.key]![g.symbol] ?? 0,
                  broker: g.broker ?? brokerBy[e.key]![g.symbol] ?? 0,
                ),
          ],
          discrepanciesJson: jsonEncode(<String, Object?>{
            'kind': 'X1_GAP_REBUILD',
            'run_id': r.runId,
            'window': window == null
                ? null
                : <String, Object?>{
                    'from': window.fromDate,
                    'to': window.toDate,
                  },
            'violations': <Object?>[
              for (final MapEntry<String, List<GapViolation>> e
                  in violations.entries)
                for (final GapViolation g in e.value)
                  <String, Object?>{
                    'account': e.key,
                    'kind': g.kind.wire,
                    'symbol': g.symbol,
                    'ledger_after': g.ledgerAfter,
                    'broker': g.broker,
                  },
            ],
          }),
        ),
      );
      return GapRebuildReport._(
        violations: violations,
        reconId: reconId,
        sessions: sessions.length,
      );
    }
    final Map<String, List<String>> recovered = inLedgerTransaction(_db, () {
      final Map<String, List<String>> out = <String, List<String>>{};
      final String at = now.toIso8601String();
      for (final String account in accounts) {
        final List<DailyFillRow> rows = _timeOrdered(toRecover[account]!);
        final Map<(String, String), List<RecoveredFillPlan>> byKey =
            <(String, String), List<RecoveredFillPlan>>{};
        for (final DailyFillRow row in rows) {
          final String strategy = _strategyFor(
            account,
            row.symbol,
            accountByStrategy,
          )!;
          final RecoveredFillPlan p = recoveredFillPlanOf(
            row,
            account: account,
            strategyId: strategy,
            declarationDecisionId: r.decisionId!,
            configHash: configHash,
            recoveryAtUtc: now,
          );
          _insertPlan(p, row, operatingMode, costs, at);
          (byKey[(strategy, row.symbol)] ??= <RecoveredFillPlan>[]).add(p);
          (out[account] ??= <String>[]).add(p.intentId);
        }
        for (final MapEntry<(String, String), List<RecoveredFillPlan>> e
            in byKey.entries) {
          _replayPosition(e.key.$1, e.key.$2, e.value, at);
        }
      }
      recordGapRebuilt(_db, r.runId, now, <String, Object?>{
        'from': window?.fromDate,
        'to': window?.toDate,
        'sessions': sessions.length,
        'recovered': <String, Object?>{
          for (final MapEntry<String, List<String>> e in out.entries)
            e.key: e.value.length,
        },
      });
      return out;
    });
    return GapRebuildReport._(recovered: recovered, sessions: sessions.length);
  }

  // 날 · 주문 시각 · 번호 차례(core `gapViolationsOf` 와 같은 차례).
  static List<DailyFillRow> _timeOrdered(List<DailyFillRow> rows) =>
      <DailyFillRow>[...rows]..sort((DailyFillRow a, DailyFillRow b) {
        final int d = a.orderDate.yyyyMmDd.compareTo(b.orderDate.yyyyMmDd);
        if (d != 0) return d;
        final int t = (a.orderTime ?? '').compareTo(b.orderTime ?? '');
        return t != 0 ? t : a.odno.compareTo(b.odno);
      });

  // 그 계좌 전략들의 복원 보유(종목 → 수량 합).
  Map<String, int> _restoredHoldings(
    String account,
    Map<String, String> accountByStrategy,
  ) {
    final Map<String, int> out = <String, int>{};
    for (final Row x in _db.select(
      'SELECT symbol, strategy_id, quantity FROM positions WHERE market = ?',
      <Object?>[_market],
    )) {
      if (accountByStrategy[x['strategy_id']] != account) continue;
      final String s = x['symbol'] as String;
      out[s] = (out[s] ?? 0) + (x['quantity'] as int);
    }
    return out;
  }

  // 🔴 종목 → 전략(하나일 때만 · 지어내지 않는다).
  String? _strategyFor(
    String account,
    String symbol,
    Map<String, String> accountByStrategy,
  ) {
    String? only(Iterable<Row> rows) {
      final Set<String> s = <String>{
        for (final Row x in rows)
          if (accountByStrategy[x['strategy_id']] == account)
            x['strategy_id'] as String,
      };
      return s.length == 1 ? s.single : null;
    }

    final ResultSet held = _db.select(
      'SELECT strategy_id FROM positions WHERE market = ? AND symbol = ? AND quantity > 0',
      <Object?>[_market, symbol],
    );
    final List<Row> mine = <Row>[
      for (final Row x in held)
        if (accountByStrategy[x['strategy_id']] == account) x,
    ];
    if (mine.isNotEmpty) return only(mine);
    return only(
      _db.select(
        'SELECT DISTINCT strategy_id FROM order_intents WHERE market = ? AND symbol = ? AND account = ?',
        <Object?>[_market, symbol, account],
      ),
    );
  }

  void _insertPlan(
    RecoveredFillPlan p,
    DailyFillRow row,
    OperatingMode operatingMode,
    FillCostRates costs,
    String at,
  ) {
    _db.execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, '
      'account, strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, '
      'status, config_hash, dry_run, error_message, updated_at, mode, operating_mode) '
      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, 'LIVE', ?)",
      <Object?>[
        p.intentId,
        p.idempotencyKey,
        p.createdAtUtc.toIso8601String(),
        p.tradeDate.yyyyMmDd,
        _market,
        p.account,
        p.strategyId,
        p.decisionId,
        p.symbol,
        p.side.wire,
        p.limitPrice == null ? 'MARKET' : 'LIMIT',
        p.orderQuantity,
        switch (p.limitPrice) {
          final x? => demoteToDouble(x),
          null => null,
        },
        p.status.code,
        p.configHash,
        p.reasonCode,
        at,
        operatingMode.wire,
      ],
    );
    _db.execute(
      'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status, filled_qty, '
      'remaining_qty, avg_fill_price, raw_response) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        p.brokerOrderNo,
        p.intentId,
        p.submittedAtUtc.toIso8601String(),
        p.status.code,
        p.filledQty,
        p.remainingQty,
        p.executionPrice,
        p.rawResponse,
      ],
    );
    // 금액 타입은 core 의 것(order_ledger 와 같은 꼴).
    final c = estimateFillCost(
      fillDeltas(<DailyFillRow>[row], const <String, RecordedFill>{}).single,
      costs,
    );
    _db.execute(
      'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, '
      'commission, tax, authored_at, fill_origin, cost_source) '
      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ESTIMATED')",
      <Object?>[
        p.executionId,
        p.brokerOrderNo,
        p.submittedAtUtc.toIso8601String(),
        p.filledQty,
        p.executionPrice,
        demoteToDouble(c.commission),
        demoteToDouble(c.tax),
        p.createdAtUtc.toIso8601String(),
        p.fillOrigin,
      ],
    );
  }

  // 🔴 복원 포지션을 씨앗(첫 매수)으로 두고 복구 체결을 차례로 재생 — 음수 = StateError(위반이 먼저 막는다).
  void _replayPosition(
    String strategy,
    String symbol,
    List<RecoveredFillPlan> plans,
    String at,
  ) {
    final List<Object?> key = <Object?>[_market, symbol, strategy];
    final ResultSet pos = _db.select(
      'SELECT quantity, avg_price, entry_date, entry_decision_id FROM positions '
      'WHERE market = ? AND symbol = ? AND strategy_id = ?',
      key,
    );
    final List<LedgerFillRow> fills = <LedgerFillRow>[
      if (pos.isNotEmpty)
        LedgerFillRow(
          executionId: 'seed',
          kind: FillKind.original,
          side: OrderSide.buy,
          quantity: pos.single['quantity'] as int,
          price: (pos.single['avg_price'] as num).toDouble(),
          brokerOrderNo: 'seed',
          tradeDate: pos.single['entry_date'] as String,
          decisionId: pos.single['entry_decision_id'] as String? ?? _noDecision,
        ),
      for (final RecoveredFillPlan p in plans)
        LedgerFillRow(
          executionId: p.executionId,
          kind: FillKind.original,
          side: p.side,
          quantity: p.filledQty,
          price: p.executionPrice,
          brokerOrderNo: p.brokerOrderNo,
          tradeDate: p.tradeDate.yyyyMmDd,
          decisionId: p.decisionId,
        ),
    ];
    final ReplayedPosition? after = replayPositionOf(fills);
    if (after == null) {
      throw StateError('복구 재생이 음수다: $strategy $symbol');
    }
    writeReplayedPosition(
      _db,
      key,
      exists: pos.isNotEmpty,
      p: ReplayedPosition(
        quantity: after.quantity,
        avgPrice: after.avgPrice,
        entryDate: after.entryDate,
        entryDecisionId: after.entryDecisionId == _noDecision
            ? null
            : after.entryDecisionId,
      ),
      iso: at,
    );
  }
}
