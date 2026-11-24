// 🆕 E11q1 — M6 H6-1 보유 현황 읽기(operator · 설계 13 §8 R171 · 나눔 계획 R169 q1) · 🆕 E11q1b H6-2 상세 · H6-3 배분(R172).
//
// 🔴 셈 = 엔진(`holdingsOverviewVmOf` — 회계 = 월말 계획기 원천) · 여기는 원장 원문만 모은다(금액 = 글자 · 01 §1-1 ·
//    월말 잡 `closeTexts` · `potCashText` 꼴).
// 🔴 보유 = `positions`(KR · 수량 > 0) · 진입 결정 = `entry_decision_id` → 같은 전략 · 종목의 첫 매수 의도(의도 id · 설정 지문) ·
//    결정을 못 찾으면 엔진이 실패한다(행을 지어내지 않는다).
// 🔴 현금 = 모의(SIM_INTERNAL)만 — 계좌마다 가상 현금(브로커와 같은 셈 `simOrderableCashOf`)의 합 · 다른 모드 = 원천 없음
//    (실계좌 현금 = 트랙 C).
// 🔴 기준일 = 보유 종목마다 마지막 원가 종가(`close_unadj`)의 가장 이른 날(보수 — 모든 종목이 같은 날로 평가된다) ·
//    종가 = 그날 이전 마지막 원가 종가(월말 잡 평가와 같은 열) · 보유 0 = KR 마지막 봉 날 · 봉도 없으면 오늘(한국).
// 🔴 B 트랜치 = 기준일까지 달마다 마지막 종가(`close` · 월말 잡과 같은 열) → 월말 계획기 함수 · 다음 판정일 = 다음 정기
//    리밸런싱 판정일(KR 달력).
// 🔴 가림 = 서 있는 차단 — `LEDGER_INTEGRITY` = «숨김» · `RECON_MISMATCH` = «?» · 🆕 E11q-q6 `L-3` 실사 세션(그 폰) = «숨김».
// 🔴 계좌 = 확정 운영 설정(`currentP0sOpsConfig` — 잡이 현금을 셀 때 쓰는 그 별칭 · 🆕 R265 이 원장의 모드로) · 표시 이름 = 사람
//    결정 표(없으면 별칭 그대로).
// 🆕 리뷰 3차 E-1(미결 231 ⓒ · 설계 13 §8 R265 · K206) — 보유 0 의 H6-3 배분이 «개시 전» 빈 상태가 되는 것은 개시 결정이 없을
//    때(`OPS_CONFIG_NO_OPENING`) 하나뿐 — 판이 바뀜 · 미등재 · 내용 꼴 오류는 그 사유를 던진다(읽은 것처럼 보이지 않는다).

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HoldingPositionFact,
        HoldingsOverviewFacts,
        P0sOpsConfig,
        WhatIfConfig,
        bTrancheSignalsOf,
        holdingDetailVmOf,
        holdingsOverviewVmOf,
        kstDateText,
        monthlyLastCloses,
        nextRegularRebalance,
        potCashOf,
        sleeveAllocationVmOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        DecisionRef,
        FlagIds,
        HoldingDetailVm,
        HoldingsOverviewVm,
        RunMode,
        SleeveAllocationVm,
        TradeDate;
import 'package:sqlite3/sqlite3.dart';

import '../jobs/seasonal_a_job.dart' show potCashFlowsSinceLiquidation;
import 'ops_config_source.dart'
    show
        OpsConfigCodes,
        OpsConfigRead,
        OpsConfigReady,
        OpsConfigUnavailable,
        currentP0sOpsConfig;
import 'sim_ledger_view.dart' show SqliteSimLedgerView;

/// 보유 현황 원천이 없다(모의 밖 · 실계좌 현금 = 트랙 C).
class HoldingsSourceUnavailable implements Exception {
  /// 만든다.
  const HoldingsSourceUnavailable(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'HoldingsSourceUnavailable($reason)';
}

/// H6-1 보유 현황 읽기(동기 — 화면 흐름이 원장 변경 · 주기마다 다시 부른다).
class SqliteHoldingsOverviewSource {
  /// 만든다 — [accountLabels] = 계좌 별칭 → 표시 이름(사람 결정 · 없으면 별칭) · [hasBody] = 조립 앱 등록 화면.
  SqliteHoldingsOverviewSource(
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

  /// 다시 낼 표.
  static const Set<String> watchedTables = <String>{
    'positions',
    'order_intents',
    'broker_orders',
    'executions',
    'cash_flow',
    'daily_prices',
    'trading_block',
    'rebalance_event',
    'decision_log',
    'config_versions',
  };

  /// H6-1 보유 현황 VM — [includePnl] = 종목 손익 펼침.
  HoldingsOverviewVm overview({bool includePnl = false}) =>
      holdingsOverviewVmOf(facts(), includePnl: includePnl);

  /// 🆕 R172 — H6-2 종목 상세 VM(없는 보유 = 엔진 실패).
  HoldingDetailVm detail(String holdingId, {bool includePnl = false}) =>
      holdingDetailVmOf(facts(), holdingId, includePnl: includePnl);

  /// 🆕 R265(리뷰 3차 A-1) — 이 원장의 지금 설정(원장 모드의 개시 판 · 리밸런싱 미리보기가 같은 원천을 쓴다).
  OpsConfigRead currentOpsConfig() => currentP0sOpsConfig(_db, _runMode);

  /// 🆕 R172 — H6-3 슬리브 배분 VM(보유 0 이어도 현금을 센다 · 개시 전 = 빈 상태 · 🆕 R265 그 밖 설정 못 읽음 = 그 사유를 던진다).
  SleeveAllocationVm allocation() =>
      sleeveAllocationVmOf(facts(needCash: true));

  /// 엔진 사실 — [needCash] = 보유가 없어도 현금을 센다(H6-3 · 개시 설정이 있을 때만 · 개시 결정 없음 = 0 = 개시 전 ·
  /// 🆕 R265 그 밖 설정 못 읽음 = [OpsConfigUnavailable]).
  HoldingsOverviewFacts facts({bool needCash = false}) {
    final DateTime now = _clock.nowUtc();
    final TradeDate today = TradeDate(kstDateText(now));
    final List<HoldingPositionFact> positions = _positions();
    final bool empty = positions.isEmpty;
    final P0sOpsConfig? cfg = !empty
        ? _opsConfig()
        : (needCash ? _opsConfigOrNull() : null);
    final Map<String, String> cashTexts = cfg == null
        ? const <String, String>{}
        : _cashTexts(cfg);
    final TradeDate closeDate = _closeDate(positions, today);
    final Set<String> symbols = <String>{
      for (final HoldingPositionFact p in positions) p.symbol,
      for (final (String s, _) in _config.monthEnd.bAssets) s,
      _config.parkingSymbol,
      _config.monthEnd.cBondSymbol,
      _config.monthEnd.cGoldSymbol,
    };
    final String month = closeDate.yyyyMmDd.substring(0, 7);
    final Set<String> flags = _activeFlags();
    return HoldingsOverviewFacts.ledger(
      positions: positions,
      closeTexts: <String, String>{
        for (final String s in symbols.toList()..sort())
          if (_closeOnOrBefore(s, closeDate.yyyyMmDd) case final String c) s: c,
      },
      closeDate: closeDate,
      cashTexts: cashTexts,
      potCashText: cfg == null
          ? '0'
          : potCashOf(potCashFlowsSinceLiquidation(_db)).toString(),
      config: _config,
      accountAliasOf: (String strategy) {
        final String? alias = cfg?.human.accountByStrategy[strategy];
        if (alias == null) return strategy;
        return _labels[alias] ?? alias;
      },
      bTranches: bTrancheSignalsOf(<String, List<double>>{
        for (final (String s, _) in _config.monthEnd.bAssets)
          s: monthlyLastCloses(_adjustedBars(s, closeDate.yyyyMmDd), month),
      }, _config),
      nextTrancheDate: nextRegularRebalance(_kr, today)?.judgment,
      integrityHidden:
          flags.contains(FlagIds.ledgerIntegrity) || _selfReportSessionOpen(),
      reconSuspect: flags.contains(FlagIds.reconMismatch),
      hasBody: _hasBody,
      nowUtc: now,
      fillCounts: _fillCounts(),
    );
  }

  /// (전략, 종목) → 원 체결 건수(브로커 · 가상 체결 — 수기 체결은 주문 없음 = 세지 않는다 · REVERSAL · 정정 제외).
  Map<(String, String), int> _fillCounts() => <(String, String), int>{
    for (final Row r in _db.select(
      'SELECT i.strategy_id, i.symbol, COUNT(*) AS n FROM executions e '
      'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
      'JOIN order_intents i ON i.intent_id = b.intent_id '
      "WHERE i.market = 'KR' AND e.fill_kind = 'ORIGINAL' GROUP BY i.strategy_id, i.symbol",
    ))
      (r['strategy_id'] as String, r['symbol'] as String): r['n'] as int,
  };

  /// 🔴 R265(E-1) — null = 개시 결정 없음(개시 전) 하나뿐 · 판이 바뀜 · 미등재 · 꼴 오류 = 던진다(K206).
  P0sOpsConfig? _opsConfigOrNull() => switch (currentOpsConfig()) {
    OpsConfigReady(config: final P0sOpsConfig cfg) => cfg,
    OpsConfigUnavailable(code: OpsConfigCodes.noOpening) => null,
    final OpsConfigUnavailable u => throw u,
  };

  List<HoldingPositionFact> _positions() => <HoldingPositionFact>[
    for (final Row r in _db.select(
      'SELECT p.strategy_id, p.symbol, p.quantity, p.avg_price, p.entry_date, p.entry_decision_id, '
      'i.intent_id, i.config_hash FROM positions p LEFT JOIN order_intents i ON i.intent_id = ('
      'SELECT j.intent_id FROM order_intents j WHERE j.decision_id = p.entry_decision_id '
      "AND j.strategy_id = p.strategy_id AND j.symbol = p.symbol AND j.side = 'BUY' "
      'ORDER BY j.intent_id LIMIT 1) '
      "WHERE p.market = 'KR' AND p.quantity > 0 ORDER BY p.strategy_id, p.symbol",
    ))
      HoldingPositionFact.ledger(
        strategyId: r['strategy_id'] as String,
        symbol: r['symbol'] as String,
        quantity: r['quantity'] as int,
        avgPrice: (r['avg_price'] as num).toDouble(),
        entryDate: TradeDate(r['entry_date'] as String),
        entryDecision: switch ((
          r['entry_decision_id'] as String?,
          r['config_hash'] as String?,
        )) {
          (final String d, final String hash) => DecisionRef(
            decisionId: d,
            intentId: r['intent_id'] as String?,
            configHash: hash,
          ),
          _ => null,
        },
      ),
  ];

  P0sOpsConfig _opsConfig() {
    final OpsConfigRead r = currentOpsConfig();
    switch (r) {
      case OpsConfigReady(config: final P0sOpsConfig cfg):
        return cfg;
      case OpsConfigUnavailable():
        throw r;
    }
  }

  Map<String, String> _cashTexts(P0sOpsConfig cfg) {
    switch (_runMode) {
      case RunMode.simInternal:
        break;
      case RunMode.simBroker:
      case RunMode.live:
        throw HoldingsSourceUnavailable('현금 원천 없음: ${_runMode.wire}');
    }
    final Map<String, Set<String>> strategiesOf = <String, Set<String>>{};
    cfg.human.accountByStrategy.forEach((String strategy, String alias) {
      (strategiesOf[alias] ??= <String>{}).add(strategy);
    });
    return <String, String>{
      for (final MapEntry<String, Set<String>> e in strategiesOf.entries)
        e.key: SqliteSimLedgerView(
          _db,
          account: e.key,
          strategies: e.value,
          clock: _clock,
        ).orderableCashTextNow(),
    };
  }

  TradeDate _closeDate(List<HoldingPositionFact> positions, TradeDate today) {
    String? day;
    if (positions.isEmpty) {
      day =
          _db
                  .select(
                    "SELECT MAX(trade_date) AS d FROM daily_prices WHERE market = 'KR'",
                  )
                  .first['d']
              as String?;
    } else {
      for (final String s in <String>{
        for (final HoldingPositionFact p in positions) p.symbol,
      }) {
        final String? last =
            _db.select(
                  "SELECT MAX(trade_date) AS d FROM daily_prices WHERE market = 'KR' AND symbol = ? "
                  'AND close_unadj > 0',
                  <Object?>[s],
                ).first['d']
                as String?;
        // 봉 없는 보유 = 기준일을 오늘로 두고 엔진이 «종가 없음»으로 실패한다(지어내지 않는다).
        if (last == null) return today;
        if (day == null || last.compareTo(day) < 0) day = last;
      }
    }
    return day == null ? today : TradeDate(day);
  }

  String? _closeOnOrBefore(String symbol, String day) {
    final ResultSet rs = _db.select(
      "SELECT close_unadj FROM daily_prices WHERE market = 'KR' AND symbol = ? AND trade_date <= ? "
      'AND close_unadj > 0 ORDER BY trade_date DESC LIMIT 1',
      <Object?>[symbol, day],
    );
    final Object? v = rs.isEmpty ? null : rs.first['close_unadj'];
    return v is num ? v.toString() : null;
  }

  List<(String, double)> _adjustedBars(String symbol, String upTo) =>
      <(String, double)>[
        for (final Row r in _db.select(
          "SELECT trade_date, close FROM daily_prices WHERE market = 'KR' AND symbol = ? AND trade_date <= ? "
          'ORDER BY trade_date',
          <Object?>[symbol, upTo],
        ))
          (r['trade_date'] as String, (r['close'] as num).toDouble()),
      ];

  Set<String> _activeFlags() => <String>{
    for (final Row r in _db.select(
      'SELECT flag_id FROM trading_block WHERE cleared_at IS NULL AND flag_id IN (?, ?)',
      <Object?>[FlagIds.ledgerIntegrity, FlagIds.reconMismatch],
    ))
      r['flag_id'] as String,
  };
}
