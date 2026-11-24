// 🆕 E11q-q4a — M6 매매일지 «읽기» 원천(operator · J-1 타임라인 · 필터 · 배지 · J-2 · J-3R · 회차 범위 · 기간 프리셋 ·
// 슬리브 목록 · S7-6b 회차 ↔ 주문 묶음).
//
// 🔴 셈 · 글자 = 엔진(`journalTimelineOf` …) · 여기는 원장 원문만 모은다(금액 = 글자 · 01 §1-1 · q1 꼴).
// 🔴 행 = `order_intents`(KR) · 브로커 주문 · 체결(브로커 주문을 거친 것 — 수기 체결 = 안내 갈래 · 이 판 밖) ·
//    결정 = `decision_log` · 저널 = `decision_journal` · 회차 = `rebalance_event` + 묶는 논리 id
//    (월말 = 그 달 계획 스냅샷(재개 child 포함)의 대상 · 계절 = 판정 결정 · POT 청산).
// 🔴 가림 = 서 있는 차단(`LEDGER_INTEGRITY` · `RECON_MISMATCH` — q1 과 같은 읽기) · 🆕 E11q-q6 `L-3` 실사 세션(그 폰) = «숨김».
// 🔴 원장 한 파일 = 그 파일의 행 전부(파일이 모드 경계 · 01 §9-1) — 모드 인자로 거르지 않는다(01 §8 미결 89).
// 🆕 E11q-j4 — J-4 blind 리뷰 큐 · 카드(같은 사실 · 같은 감시 표 — 대상 = 결정 로그 · 저널 · 의도 · 브로커 주문 ·
//    K24 = 이 원장의 모드가 LIVE 일 때만 · 엔진 `blindReviewQueueOf`).
// 🆕 E11q-j4s(SPEC v2.47 02 §2-6 · §3-3 · 13 §8 R257) — 채점 행(`blind_review_score`) · 결과 셈 재료(되돌림 대상 ·
//    되돌리지 않은 기업 행사 · 의도에 닿지 않는 살아 있는 수기 체결) · 감시 표 += `blind_review_score` · `ledger_event`.

import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        BlindReviewScoreFact,
        JournalCorporateActionFact,
        JournalDecisionFact,
        JournalEventFact,
        JournalFacts,
        JournalFillFact,
        JournalIntentFact,
        JournalNoteFact,
        JournalOrderFact,
        WhatIfConfig,
        blindReviewCardOf,
        blindReviewQueueOf,
        decisionDetailVmOf,
        decisionJournalVmOf,
        journalEventIdOf,
        journalFilterCatalogOf,
        journalRangePresetsOf,
        journalRebalanceScopeOf,
        journalSleeveCatalogOf,
        journalTimelineBadgesOf,
        journalTimelineOf,
        unknownBoardVmOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        BlindReviewCard,
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
        TradeJournalEntry,
        UnknownBoardVm;
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
    bool Function()? selfReportSessionOpen,
  }) : _labels = accountLabels,
       _config = config ?? WhatIfConfig.defaults,
       _selfReportSessionOpen = selfReportSessionOpen ?? _never;

  final Database _db;
  final Clock _clock;
  final ExchangeCalendar _kr;
  final RunMode _runMode;
  final Map<String, String> _labels;
  final bool Function(String route) _hasBody;
  final WhatIfConfig _config;

  /// 🆕 E11q-q6 — `L-3` 실사 세션이 이 폰에서 열려 있나(열린 동안 = `LEDGER_INTEGRITY` 와 같은 «숨김» · K9 · 02 §3-10 G-47).
  final bool Function() _selfReportSessionOpen;

  static bool _never() => false;

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
    // 🆕 E11q-j4s — 채점(큐 이탈 · 카드 결과) · 기업 행사(결과 «셀 수 없음»).
    'blind_review_score',
    'ledger_event',
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

  /// 🆕 E11q-q4b — J-5 미해소 보드(UNKNOWN 의도 · 같은 감시 표).
  UnknownBoardVm unknownBoard() => unknownBoardVmOf(facts());

  /// J-3R 사전 저널 읽기(모르는 결정 = 엔진 실패).
  DecisionJournalVm decisionJournal(String decisionId) =>
      decisionJournalVmOf(facts(), decisionId);

  /// J-1 회차 범위(모르는 회차 = null).
  JournalRebalanceScope? rebalanceScope(String rebalanceEventId) =>
      journalRebalanceScopeOf(facts(), rebalanceEventId);

  /// 🆕 E11q-j4 — J-4 대기 목록(K24 — [mode] · 이 원장 모두 LIVE 일 때만 대상 · 그 밖 = 해당 없음 빈 봉투).
  ListResult<BlindReviewCard> blindReviewQueue({RunMode mode = RunMode.live}) =>
      blindReviewQueueOf(facts(), mode: mode);

  /// 🆕 E11q-j4 — J-4 카드 1건(모르는 · 대상이 아닌 결정 = 엔진 실패).
  BlindReviewCard blindReviewCard(String decisionId) =>
      blindReviewCardOf(facts(), decisionId);

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
      integrityHidden:
          flags.contains(FlagIds.ledgerIntegrity) || _selfReportSessionOpen(),
      reconSuspect: flags.contains(FlagIds.reconMismatch),
      config: _config,
      blindReviewScores: journalBlindReviewScoresOf(_db),
      corporateActions: journalCorporateActionsOf(_db),
      unattributedFills: journalUnattributedFillsOf(_db),
    );
  }
}

/// 🆕 E11q-j4s — blind 리뷰 채점 행(결정 → 행 · SPEC v2.47 02 §2-6).
Map<String, BlindReviewScoreFact> journalBlindReviewScoresOf(Database db) =>
    <String, BlindReviewScoreFact>{
      for (final Row r in db.select(
        'SELECT decision_id, command_id, process_score, scored_at FROM blind_review_score',
      ))
        r['decision_id'] as String: BlindReviewScoreFact(
          decisionId: r['decision_id'] as String,
          commandId: r['command_id'] as String,
          processScore: r['process_score'] as int,
          scoredAt: _utc(r['scored_at'] as String),
        ),
    };

/// 🆕 E11q-j4s — 되돌리지 않은 기업 행사(`ledger_event` `CORPORATE_ACTION` · 원 행 − 되돌린 행 · 효력일 거르기 = 엔진).
List<JournalCorporateActionFact> journalCorporateActionsOf(Database db) =>
    <JournalCorporateActionFact>[
      for (final Row r in db.select(
        "SELECT account_alias, symbol, effective_date FROM ledger_event e WHERE kind = 'CORPORATE_ACTION' "
        "AND entry_kind = 'ORIGINAL' AND symbol IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ledger_event v "
        "WHERE v.entry_kind = 'REVERSAL' AND v.reverses_event_id = e.event_id) ORDER BY effective_date, event_id",
      ))
        JournalCorporateActionFact(
          account: r['account_alias'] as String,
          symbol: r['symbol'] as String,
          effectiveDate: TradeDate(r['effective_date'] as String),
        ),
    ];

/// 🆕 E11q-j4s — 의도에 닿지 않는 살아 있는 수기 체결이 있나(`MANUAL` · 브로커 주문 없음 · 되돌림 아님 · 되돌려지지 않음 —
/// 로트 축을 모른다 → J-4 결과 «셀 수 없음» · SPEC 02 §3-3 ② ⓒ).
bool journalUnattributedFillsOf(Database db) => db
    .select(
      "SELECT 1 FROM executions e WHERE e.broker_order_no IS NULL AND e.fill_kind <> 'REVERSAL' "
      'AND NOT EXISTS (SELECT 1 FROM executions v WHERE v.reverses_fill_id = e.execution_id) LIMIT 1',
    )
    .isNotEmpty;

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
    'e.backdate_trading_days, e.price_range_source_date, e.reverses_fill_id FROM executions e '
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
        reversesFillId: r['reverses_fill_id'] as String?,
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
