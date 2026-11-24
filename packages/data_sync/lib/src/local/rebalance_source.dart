// 🆕 E11q2 — 리밸런싱 회차 읽기 · What-if 상태 원천(operator · 설계 13 §8 R173 · 나눔 계획 R169 q2 · q3 공유).
//
// 🔴 셈 = 엔진(`rebalanceEventsVmOf` · `whatIfStateFromLedger`) · 여기는 원장 원문만 모은다(금액 = 글자 · 01 §1-1).
// 🔴 회차 = `rebalance_event` 그대로(월말 잡 · 계절 A 잡이 쓴 행) · 월말 회차 집행일 = 다음 KR 세션(월말 잡과 같은 셈).
// 🔴 미리보기 상태 = 월말 잡과 같은 입력: 보유 현황 장부(현금 포함 · H6-1 과 한 장부) · 연금 누계(`SqliteDepositLedger`) ·
//    회차 번호(마지막 월말 계획 + 1) · 국면(`monthEndRegimeAt` — 기준일 이하 마지막 행 · 🔴 미리보기는 국면을 다시 계산 ·
//    저장하지 않는다) · 달마다 마지막 수정 종가 · 다음 세션 유무. 차단 플래그 = 안전 읽기 모델(주입) · 복구 = 재개 상태.
// 🔴 운영 설정이 없으면(개시 전) 계산하지 않는다 — 실패(Future 에러 = «계산을 못 했다» · 지어낸 0원 장부로 초안을 내지 않는다).

import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HoldingsOverviewFacts,
        P0sOpsConfig,
        P0sStrategyIds,
        RebalanceEventFact,
        WhatIfAccounts,
        WhatIfConfig,
        WhatIfState,
        WhatIfStateSource,
        kstDateText,
        monthlyLastCloses,
        nextRegularRebalance,
        rebalanceEventVmOf,
        rebalanceEventsVmOf,
        whatIfStateFromLedger;
import 'package:domain_contracts/domain_contracts.dart'
    show BlockFlag, Clock, ListResult, RebalanceEvent, TradeDate;
import 'package:sqlite3/sqlite3.dart';

import '../jobs/monthly_rebalance_job.dart'
    show SqliteRebalancePlanStore, monthEndRegimeAt;
import '../market/market_store.dart' show PriceBar, SqliteMarketStore;
import 'deposit_ledger.dart' show SqliteDepositLedger;
import 'holdings_overview_source.dart' show SqliteHoldingsOverviewSource;
import 'journal_source.dart' show journalIntentIdsByEvent;
import 'ops_config_source.dart' show OpsConfigReady, OpsConfigUnavailable;
import 'resume_status.dart' show SqliteResumeStatus;

/// 리밸런싱 읽기(동기 — 화면 흐름이 원장 변경 · 주기마다 다시 부른다) · 미리보기 상태.
class SqliteRebalanceSource {
  /// 만든다 — [holdings] = 보유 현황 원천(같은 장부) · [activeFlags] = 지금 서 있는 차단(안전 읽기 모델) ·
  /// [hasBody] = 조립 앱 등록 화면.
  SqliteRebalanceSource(
    this._db, {
    required this._clock,
    required this._kr,
    required this._us,
    required this._holdings,
    required this._activeFlags,
    required this._hasBody,
    WhatIfConfig? config,
  }) : _config = config ?? WhatIfConfig.defaults;

  final Database _db;
  final Clock _clock;
  final ExchangeCalendar _kr;
  final ExchangeCalendar _us;
  final SqliteHoldingsOverviewSource _holdings;
  final List<BlockFlag> Function() _activeFlags;
  final bool Function(String route) _hasBody;
  final WhatIfConfig _config;

  /// 회차 목록 · 회차 1건을 다시 낼 표.
  static const Set<String> watchedTables = <String>{
    'rebalance_event',
    'daily_prices',
    // 🆕 E11q-q4a — «이 회차의 주문 n건»(회차 ↔ 주문 묶음).
    'order_intents',
    'plan_snapshot',
  };

  /// `S7-6a` 회차 목록(엔진 정렬 · 시간 역순).
  ListResult<RebalanceEvent> events() => rebalanceEventsVmOf(
    _facts(),
    nowUtc: _clock.nowUtc(),
    dataDate: _dataDate(),
    hasBody: _hasBody,
    config: _config,
  );

  /// `S7-6b` 회차 1건(목록과 같은 행 · 모르는 id = 엔진 실패).
  RebalanceEvent event(String eventId) => rebalanceEventVmOf(
    _facts(),
    eventId,
    nowUtc: _clock.nowUtc(),
    dataDate: _dataDate(),
    hasBody: _hasBody,
    config: _config,
  );

  /// 미리보기 상태(월말 잡과 같은 입력) — 개시 전(운영 설정 없음) = [OpsConfigUnavailable] ·
  /// 🆕 R265(리뷰 3차 A-1) 설정 = 보유 원천과 같은 원장 · 같은 모드(실전 원장 = 실전 개시 판).
  WhatIfState whatIfState() {
    final P0sOpsConfig cfg = switch (_holdings.currentOpsConfig()) {
      OpsConfigReady(config: final P0sOpsConfig c) => c,
      final OpsConfigUnavailable u => throw u,
    };
    final HoldingsOverviewFacts facts = _holdings.facts(needCash: true);
    final String day = facts.closeDate.yyyyMmDd;
    final String judged =
        nextRegularRebalance(_kr, facts.closeDate)?.judgment.yyyyMmDd ?? day;
    final (String, Map<String, Object?>)? prev = SqliteRebalancePlanStore(_db)
        .lastBefore(judged);
    final SqliteMarketStore market = SqliteMarketStore(_db);
    final String month = day.substring(0, 7);
    return whatIfStateFromLedger(
      facts: facts,
      pensionRows: SqliteDepositLedger(_db).cashRows(cfg.pensionAlias),
      monthIndex: prev == null ? 1 : (prev.$2['month_index']! as int) + 1,
      regimeState: monthEndRegimeAt(_db, day).$1,
      monthlyCloses: <String, List<double>>{
        for (final (String s, _) in _config.monthEnd.bAssets)
          s: monthlyLastCloses(<(String, double)>[
            for (final PriceBar b in market.readBars('KR', s))
              (b.tradeDate, b.close),
          ], month),
      },
      hasNextKrSession: _hasNext(_kr, day),
      hasNextUsSession: _hasNext(_us, day),
      configHash: cfg.configHash,
      activeFlags: _activeFlags(),
      recovery: SqliteResumeStatus(_db, kr: _kr).recoveryActive(),
      accounts: WhatIfAccounts(
        pensionAlias: cfg.pensionAlias,
        generalAlias: cfg.human.accountByStrategy[P0sStrategyIds.sleeveC],
      ),
      krCalendar: _kr,
      unknownSymbols: <String>{
        for (final Row r in _db.select(
          "SELECT DISTINCT symbol FROM order_intents WHERE market = 'KR' AND status = 'UNKNOWN'",
        ))
          r['symbol'] as String,
      },
    );
  }

  List<RebalanceEventFact> _facts() {
    // 🆕 E11q-q4a — 회차 ↔ 주문 의도 = 일지와 같은 묶음(«이 회차의 주문 n건» · 일지 행 수와 같은 셈).
    final Map<String, List<String>> intents = journalIntentIdsByEvent(_db);
    return <RebalanceEventFact>[
      for (final Row r in _db.select(
        'SELECT event_id, trade_date, mode, kind, trigger_snapshot, weights_before, weights_after, '
        'config_hash, created_at FROM rebalance_event',
      ))
        RebalanceEventFact(
          eventId: r['event_id'] as String,
          tradeDate: TradeDate(r['trade_date'] as String),
          modeWire: r['mode'] as String,
          kindWire: r['kind'] as String,
          configHash: r['config_hash'] as String,
          trigger: jsonDecode(
            r['trigger_snapshot'] as String,
          ) as Map<String, Object?>,
          weightsBefore: _weights(r['weights_before'] as String),
          weightsAfter: _weights(r['weights_after'] as String),
          createdAt: r['created_at'] as String,
          executionDate: r['kind'] == 'MONTHLY_REGULAR'
              ? _nextKr(r['trade_date'] as String)
              : null,
          journalIntentIds:
              intents[r['event_id'] as String] ?? const <String>[],
        ),
    ];
  }

  static Map<String, double> _weights(String json) =>
      storedRebalanceWeightsOf(json);

  String? _nextKr(String day) {
    try {
      return _kr.nextSession(TradeDate(day)).yyyyMmDd;
    } on StateError {
      return null;
    }
  }

  static bool _hasNext(ExchangeCalendar cal, String day) {
    try {
      cal.nextSession(TradeDate(day));
      return true;
    } on StateError {
      return false;
    }
  }

  TradeDate _dataDate() {
    final String? d =
        _db
                .select(
                  "SELECT MAX(trade_date) AS d FROM daily_prices WHERE market = 'KR'",
                )
                .first['d']
            as String?;
    return TradeDate(d ?? kstDateText(_clock.nowUtc()));
  }
}

/// `WhatIfStateSource` 어댑터(엔진 `EngineWhatIfApi` 가 읽는다 · R18 D-4 «실데이터 어댑터»).
class SqliteWhatIfStateSource implements WhatIfStateSource {
  /// 만든다.
  SqliteWhatIfStateSource(this._source);

  final SqliteRebalanceSource _source;

  @override
  Future<WhatIfState> load() => Future<WhatIfState>(_source.whatIfState);
}

/// 저장한 비중 JSON `[{sleeve, weight}]` → 맵(비중 없는 행 = 엔진이 실패한다 · 여기서 0 을 채우지 않는다).
/// 🆕 미결 209 ⓔ-1(R218) — 공개: 월간 리포트 원천도 같은 읽기.
Map<String, double> storedRebalanceWeightsOf(String json) => <String, double>{
  for (final Object? e in jsonDecode(json) as List<Object?>)
    if (e case {'sleeve': final String s, 'weight': final num w})
      s: w.toDouble(),
};
