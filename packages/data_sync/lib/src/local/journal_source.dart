// 🆕 E11q-q4a — M6 매매일지 «읽기» 원천(operator · J-1 타임라인 · 필터 · 배지 · J-2 · J-3R · 회차 범위 · 기간 프리셋 ·
// 슬리브 목록 · S7-6b 회차 ↔ 주문 묶음).
//
// 🔴 셈 · 글자 = 엔진(`journalTimelineOf` …) · 여기는 원장 원문만 모은다(금액 = 글자 · 01 §1-1 · q1 꼴).
// 🔴 행 = `order_intents`(KR) · 브로커 주문 · 체결(브로커 주문을 거친 것 — 수기 체결 = 안내 갈래 · 이 판 밖) ·
//    결정 = `decision_log` · 저널 = `decision_journal` · 회차 = `rebalance_event` + 묶는 논리 id
//    (월말 = 그 달 계획 스냅샷(재개 child 포함)의 대상 · 계절 = 판정 결정 · POT 청산).
// 🔴 가림 = 서 있는 차단(`LEDGER_INTEGRITY` · `RECON_MISMATCH` — q1 과 같은 읽기).
// 🔴 원장 한 파일 = 그 파일의 행 전부(파일이 모드 경계 · 01 §9-1) — 모드 인자로 거르지 않는다(01 §8 미결 89).

import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        JournalDecisionFact,
        JournalEventFact,
        JournalFacts,
        JournalFillFact,
        JournalIntentFact,
        JournalNoteFact,
        JournalOrderFact,
        WhatIfConfig,
        decisionDetailVmOf,
        decisionJournalVmOf,
        journalEventIdOf,
        journalFilterCatalogOf,
        journalRangePresetsOf,
        journalRebalanceScopeOf,
        journalSleeveCatalogOf,
        journalTimelineBadgesOf,
        journalTimelineOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        DateRange,
        DecisionDetailVm,
        DecisionJournalVm,
        FillOrigin,
        FlagIds,
        JournalFilterCatalog,
        JournalRebalanceScope,
        JournalStatus,
        JournalTimelineBadge,
        ListResult,
        RunMode,
        SleeveCatalogEntry,
        SleeveId,
        TradeDate,
        TradeJournalEntry;
import 'package:sqlite3/sqlite3.dart';

/// 매매일지 읽기(동기 — 화면 흐름이 원장 변경 · 주기마다 다시 부른다).
class SqliteJournalSource {
  /// 만든다 — [accountLabels] = 계좌 별칭 → 표시 이름(사람 결정 · 없으면 별칭) · [hasBody] = 조립 앱 등록 화면.
  SqliteJournalSource(
    this._db, {
    required this._clock,
    required this._kr,
    required this._runMode,
    required Map<String, String> accountLabels,
    required this._hasBody,
    WhatIfConfig? config,
  }) : _labels = accountLabels,
       _config = config ?? WhatIfConfig.defaults;

  final Database _db;
  final Clock _clock;
  final ExchangeCalendar _kr;
  final RunMode _runMode;
  final Map<String, String> _labels;
  final bool Function(String route) _hasBody;
  final WhatIfConfig _config;

  /// 다시 낼 표(행 · 결정 · 저널 · 회차 묶음 · 가림).
  static const Set<String> watchedTables = <String>{
    'order_intents',
    'broker_orders',
    'executions',
    'decision_log',
    'decision_journal',
    'rebalance_event',
    'plan_snapshot',
    'trading_block',
  };

  /// 기간 프리셋이 다시 낼 표(원장 첫 날).
  static const Set<String> presetTables = <String>{'order_intents'};

  /// J-1 타임라인 봉투.
  ListResult<TradeJournalEntry> timeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    int limit = 100,
  }) => journalTimelineOf(
    facts(),
    range: range,
    sleeve: sleeve,
    symbol: symbol,
    status: status,
    origin: origin,
    rebalanceEventId: rebalanceEventId,
    limit: limit,
  );

  /// J-1 필터 카탈로그.
  JournalFilterCatalog filterCatalog() => journalFilterCatalogOf(facts());

  /// J-1 상단 배지.
  List<JournalTimelineBadge> badges() => journalTimelineBadgesOf(facts());

  /// J-2 거래 상세(모르는 결정 = 엔진 실패).
  DecisionDetailVm decisionDetail(String decisionId) =>
      decisionDetailVmOf(facts(), decisionId);

  /// J-3R 사전 저널 읽기(모르는 결정 = 엔진 실패).
  DecisionJournalVm decisionJournal(String decisionId) =>
      decisionJournalVmOf(facts(), decisionId);

  /// J-1 회차 범위(모르는 회차 = null).
  JournalRebalanceScope? rebalanceScope(String rebalanceEventId) =>
      journalRebalanceScopeOf(facts(), rebalanceEventId);

  /// 조회 기간 프리셋(거래일 달력 · 전체 = 원장 첫 의도 날부터).
  List<DateRange> rangePresets() =>
      journalRangePresetsFromLedger(_db, kr: _kr, nowUtc: _clock.nowUtc());

  /// 슬리브 목록(설정 이름표 · 원장 무관).
  List<SleeveCatalogEntry> sleeves() => journalSleeveCatalogOf(_config);

  /// 회차 id → 묶인 의도 id(원장 순 — S7-6b «이 회차의 주문 n건» · `orderIntentIds`).
  Map<String, List<String>> intentIdsByEvent() => journalIntentIdsByEvent(_db);

  /// 엔진 사실.
  JournalFacts facts() {
    final Set<String> flags = <String>{
      for (final Row r in _db.select(
        'SELECT flag_id FROM trading_block WHERE cleared_at IS NULL AND flag_id IN (?, ?)',
        <Object?>[FlagIds.ledgerIntegrity, FlagIds.reconMismatch],
      ))
        r['flag_id'] as String,
    };
    return JournalFacts(
      runMode: _runMode,
      intents: journalIntentFactsOf(_db),
      decisions: <String, JournalDecisionFact>{
        for (final Row r in _db.select(
          'SELECT decision_id, created_at, trade_date, kind, reason, reason_code, rule_cited, '
          'parent_decision_id, journal_id, config_hash FROM decision_log',
        ))
          r['decision_id'] as String: JournalDecisionFact(
            decisionId: r['decision_id'] as String,
            createdAt: _utc(r['created_at'] as String),
            tradeDate: TradeDate(r['trade_date'] as String),
            kindWire: r['kind'] as String,
            reasonCode: r['reason_code'] as String,
            reason: r['reason'] as String,
            configHash: r['config_hash'] as String,
            ruleCited: r['rule_cited'] as String?,
            parentDecisionId: r['parent_decision_id'] as String?,
            journalId: r['journal_id'] as String?,
          ),
      },
      events: journalEventFactsOf(_db),
      notes: <String, JournalNoteFact>{
        for (final Row r in _db.select(
          'SELECT journal_id, created_at, is_deviation, kind, rationale_before, expected_outcome, '
          'rule_cited, note FROM decision_journal',
        ))
          r['journal_id'] as String: JournalNoteFact(
            journalId: r['journal_id'] as String,
            createdAt: _utc(r['created_at'] as String),
            isDeviation: (r['is_deviation'] as int) != 0,
            kind: r['kind'] as String?,
            rationaleBefore: r['rationale_before'] as String?,
            expectedOutcome: r['expected_outcome'] as String?,
            ruleCited: r['rule_cited'] as String?,
            note: r['note'] as String?,
          ),
      },
      nowUtc: _clock.nowUtc(),
      kr: _kr,
      accountLabelOf: (String alias) => _labels[alias] ?? alias,
      hasBody: _hasBody,
      integrityHidden: flags.contains(FlagIds.ledgerIntegrity),
      reconSuspect: flags.contains(FlagIds.reconMismatch),
      config: _config,
    );
  }
}

/// 조회 기간 프리셋 — 거래일 달력 · 전체 = 원장 첫 KR 의도 날부터(없으면 끝 날 · 엔진 규칙). 다시 낼 표 =
/// [SqliteJournalSource.presetTables].
List<DateRange> journalRangePresetsFromLedger(
  Database db, {
  required ExchangeCalendar kr,
  required DateTime nowUtc,
}) => journalRangePresetsOf(
  kr: kr,
  nowUtc: nowUtc,
  firstLedgerDay:
      db
              .select(
                "SELECT MIN(trade_date) AS d FROM order_intents WHERE market = 'KR'",
              )
              .first['d']
          as String?,
);

/// 원장 KR 주문 의도 · 브로커 주문 · 체결(원장 순 — 정렬 = 엔진).
List<JournalIntentFact> journalIntentFactsOf(Database db) {
  final Map<String, List<JournalOrderFact>> orders =
      <String, List<JournalOrderFact>>{};
  for (final Row r in db.select(
    'SELECT broker_order_no, intent_id, submitted_at FROM broker_orders '
    'ORDER BY submitted_at, broker_order_no',
  )) {
    (orders[r['intent_id'] as String] ??= <JournalOrderFact>[]).add(
      JournalOrderFact(
        brokerOrderNo: r['broker_order_no'] as String,
        submittedAt: _utc(r['submitted_at'] as String),
      ),
    );
  }
  final Map<String, List<JournalFillFact>> fills =
      <String, List<JournalFillFact>>{};
  for (final Row r in db.select(
    'SELECT b.intent_id, e.execution_id, e.broker_order_no, e.executed_at, e.authored_at, e.quantity, '
    'e.price, e.commission, e.tax, e.fill_origin, e.fill_kind, e.cost_source, e.advice_id, '
    'e.backdate_trading_days, e.price_range_source_date FROM executions e '
    'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
    'ORDER BY e.executed_at, e.execution_id',
  )) {
    (fills[r['intent_id'] as String] ??= <JournalFillFact>[]).add(
      JournalFillFact(
        executionId: r['execution_id'] as String,
        brokerOrderNo: r['broker_order_no'] as String?,
        executedAt: _utc(r['executed_at'] as String),
        authoredAt: switch (r['authored_at']) {
          final String a => _utc(a),
          _ => null,
        },
        quantity: r['quantity'] as int,
        priceText: _num(r['price']),
        commissionText: _num(r['commission']),
        taxText: _num(r['tax']),
        originWire: r['fill_origin'] as String,
        kindWire: r['fill_kind'] as String,
        costSourceWire: r['cost_source'] as String,
        adviceId: r['advice_id'] as String?,
        backdateTradingDays: r['backdate_trading_days'] as int,
        priceRangeSourceDate: switch (r['price_range_source_date']) {
          final String d => TradeDate(d),
          _ => null,
        },
      ),
    );
  }
  return <JournalIntentFact>[
    for (final Row r in db.select(
      'SELECT intent_id, decision_id, created_at, updated_at, trade_date, mode, account, strategy_id, '
      'symbol, side, quantity, limit_price, status, config_hash, error_message FROM order_intents '
      "WHERE market = 'KR' ORDER BY created_at, intent_id",
    ))
      JournalIntentFact(
        intentId: r['intent_id'] as String,
        decisionId: r['decision_id'] as String,
        createdAt: _utc(r['created_at'] as String),
        updatedAt: _utc(r['updated_at'] as String),
        tradeDate: TradeDate(r['trade_date'] as String),
        modeWire: r['mode'] as String,
        account: r['account'] as String,
        strategyId: r['strategy_id'] as String,
        symbol: r['symbol'] as String,
        sideWire: r['side'] as String,
        quantity: r['quantity'] as int,
        statusWire: r['status'] as String,
        configHash: r['config_hash'] as String,
        limitPriceText: switch (r['limit_price']) {
          final num p => _num(p),
          _ => null,
        },
        errorMessage: r['error_message'] as String?,
        orders: orders[r['intent_id'] as String] ?? const <JournalOrderFact>[],
        fills: fills[r['intent_id'] as String] ?? const <JournalFillFact>[],
      ),
  ];
}

/// 원장 리밸런싱 회차 + 묶는 논리 id — 월말 = 그 달 계획(`REBAL-{M}` · 재개 child `REBAL-{M}#RESUME-*`)의 대상 ·
/// 계절 = 판정 결정 + POT 청산(판정이 청산을 말할 때).
List<JournalEventFact> journalEventFactsOf(Database db) {
  final Map<String, Set<String>> planTargets = <String, Set<String>>{};
  for (final Row r in db.select(
    "SELECT plan_id, outputs FROM plan_snapshot WHERE kind = 'REBALANCE' AND plan_id LIKE 'REBAL-%'",
  )) {
    final String id = r['plan_id'] as String;
    final int hash = id.indexOf('#');
    final String base = hash < 0 ? id : id.substring(0, hash);
    final Object? out = jsonDecode(r['outputs'] as String);
    final Object? targets = out is Map<String, Object?> ? out['targets'] : null;
    final Set<String> set = planTargets[base] ??= <String>{};
    if (targets is List<Object?>) {
      for (final Object? t in targets) {
        final Object? l = t is Map<String, Object?>
            ? t['logical_decision_id']
            : null;
        if (l is String) set.add(l);
      }
    }
  }
  return <JournalEventFact>[
    for (final Row r in db.select(
      'SELECT event_id, trade_date, kind, decision_id, trigger_snapshot FROM rebalance_event '
      'ORDER BY trade_date, event_id',
    ))
      _event(r, planTargets),
  ];
}

JournalEventFact _event(Row r, Map<String, Set<String>> planTargets) {
  final String kind = r['kind'] as String;
  final String day = r['trade_date'] as String;
  final String decision = r['decision_id'] as String;
  final Object? raw = jsonDecode(r['trigger_snapshot'] as String);
  final Map<String, Object?> trigger = raw is Map<String, Object?>
      ? raw
      : const <String, Object?>{};
  final Set<String> logical = <String>{decision};
  switch (kind) {
    case 'MONTHLY_REGULAR':
      logical.addAll(planTargets['REBAL-$day'] ?? const <String>{});
    case 'SEASONAL':
      final Object? anchor = trigger['anchor'];
      if (trigger['liquidate_pot'] == true && anchor is String) {
        logical.add('POT-LIQ-$anchor');
      }
  }
  return JournalEventFact(
    eventId: r['event_id'] as String,
    tradeDate: TradeDate(day),
    kindWire: kind,
    decisionId: decision,
    logicalIds: logical,
    trigger: trigger,
  );
}

/// 회차 id → 묶인 의도 id(엔진 묶음 · 원장 순).
Map<String, List<String>> journalIntentIdsByEvent(Database db) {
  final List<JournalEventFact> events = journalEventFactsOf(db);
  final Map<String, List<String>> out = <String, List<String>>{};
  if (events.isEmpty) return out;
  for (final Row r in db.select(
    "SELECT intent_id, decision_id FROM order_intents WHERE market = 'KR' ORDER BY created_at, intent_id",
  )) {
    final String? e = journalEventIdOf(r['decision_id'] as String, events);
    if (e != null) (out[e] ??= <String>[]).add(r['intent_id'] as String);
  }
  return out;
}

DateTime _utc(String iso) => DateTime.parse(iso).toUtc();

/// 원장 실수 → 글자(`38250.0` → `38250` · 소수는 그대로).
String _num(Object? v) {
  if (v is int) return v.toString();
  if (v is double) {
    if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
    return v.toString();
  }
  throw StateError('원장 숫자가 아니다: $v');
}
