// `monthly_rebalance` 본체 · 계획 보관 · 오늘의 대상(설계 13 §8 R48 P1~P10 · 🆕 06 M1-28 둘째 몫).
//
// 🔴 발화 = 월 마지막 KR 세션의 **다음 KR 세션 08:00**(발주자 결정 2026-11-04) — 판정은 월말 종가 + 그날 미국 종가까지 본다(골든과 같다).
//    그래서 이 잡이 먼저 국면을 다시 계산 · 덧붙이고, 월말 미국 세션 값이 아직 없으면 **계획 없이 실패**한다(fail-closed).
// 🔴 저장은 한 트랜잭션이다 — `plan_snapshot`(REBALANCE) · `rebalance_event`(MONTHLY_REGULAR) · `decision_log`(REBALANCE).
//    같은 월말 계획이 이미 있으면 아무것도 바꾸지 않고 그것을 보고한다(멱등 — 다시 돌려도 안전).
// 🔴 POT 현금 = 체결에서 다시 센다(🆕 E11f3 · R49 Q6 — `potCashFlowsSinceLiquidation`) · 예약 원화 = 0(S7).
// 🔴 계층 B 판정(E11g)은 저장 뒤에 건다 — 이 판에는 자리만 있다.

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../local/deposit_ledger.dart';
import '../market/market_store.dart';
import '../market/regime_store.dart';
import 'daily_jobs.dart';
import 'seasonal_a_job.dart' show potCashFlowsSinceLiquidation;

/// 월말 계획 실패 — 🔴 사유 = 종목 · 계좌 별칭 · 날짜만(금액 0). 아무것도 쓰지 않았다.
class MonthlyRebalanceError implements Exception {
  /// 실패를 만든다.
  const MonthlyRebalanceError(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'MonthlyRebalanceError($reason)';
}

/// 월말 계획 id.
String rebalancePlanIdOf(String monthEnd) => 'REBAL-$monthEnd';

/// 월말 결정 id.
String monthEndDecisionIdOf(String monthEnd) => 'MONTH-END-$monthEnd';

/// `monthly_rebalance` 보고.
class MonthlyRebalanceReport implements DailyJobReport {
  /// 보고를 만든다.
  const MonthlyRebalanceReport({
    required this.planId,
    required this.created,
    required this.monthEnd,
    required this.executionDay,
    required this.targets,
    required this.sleeveBHeld,
    required this.monthIndex,
  });

  /// 계획 id.
  final String planId;

  /// 이번에 만들었나(false = 이미 있던 것).
  final bool created;

  /// 판정한 월말.
  final String monthEnd;

  /// 집행 첫날.
  final String executionDay;

  /// 주문 대상.
  final List<OrderTarget> targets;

  /// B 보류(국면 모름).
  final bool sleeveBHeld;

  /// 램프 달.
  final int monthIndex;

  @override
  Set<String> get alerts => const <String>{};

  @override
  String toString() =>
      'MonthlyRebalanceReport($planId · ${created ? '새로' : '이미 있음'} · 대상 ${targets.length} · 집행 $executionDay)';
}

List<Map<String, Object?>> _weightsJson(Map<String, double> w) =>
    <Map<String, Object?>>[
      for (final String k in <String>['A', 'B', 'C', 'POT'])
        <String, Object?>{'sleeve': k, 'weight': w[k]},
    ];

/// 월말 계획 저장소(`plan_snapshot` REBALANCE · R48 P7).
class SqliteRebalancePlanStore {
  /// 저장소를 만든다.
  SqliteRebalancePlanStore(this._db);

  final Database _db;

  /// [monthEnd] 의 계획 출력(없으면 null).
  Map<String, Object?>? outputsOf(String monthEnd) {
    final ResultSet rs = _db.select(
      "SELECT outputs FROM plan_snapshot WHERE kind = 'REBALANCE' AND plan_id = ?",
      <Object?>[rebalancePlanIdOf(monthEnd)],
    );
    return rs.isEmpty
        ? null
        : jsonDecode(rs.first['outputs'] as String) as Map<String, Object?>;
  }

  /// [before] 앞 마지막 계획의 (월말 · 출력)(없으면 null).
  (String, Map<String, Object?>)? lastBefore(String before) {
    final ResultSet rs = _db.select(
      "SELECT as_of_trade_date, outputs FROM plan_snapshot WHERE kind = 'REBALANCE' "
      'AND as_of_trade_date < ? ORDER BY as_of_trade_date DESC LIMIT 1',
      <Object?>[before],
    );
    if (rs.isEmpty) return null;
    return (
      rs.first['as_of_trade_date'] as String,
      jsonDecode(rs.first['outputs'] as String) as Map<String, Object?>,
    );
  }

  /// 가장 최근 계획의 (월말 · 만료 · 출력)(없으면 null).
  (String, String, Map<String, Object?>)? latest() {
    final ResultSet rs = _db.select(
      "SELECT as_of_trade_date, expires_at, outputs FROM plan_snapshot WHERE kind = 'REBALANCE' "
      'ORDER BY as_of_trade_date DESC LIMIT 1',
    );
    if (rs.isEmpty) return null;
    return (
      rs.first['as_of_trade_date'] as String,
      rs.first['expires_at'] as String,
      jsonDecode(rs.first['outputs'] as String) as Map<String, Object?>,
    );
  }
}

List<OrderTarget> _targetsOf(Map<String, Object?> outputs) => <OrderTarget>[
  for (final Object? t
      in (outputs['targets'] as List<Object?>? ?? const <Object?>[]))
    orderTargetFromJson(t! as Map<String, Object?>),
];

/// `monthly_rebalance`(월말 다음 KR 세션 08:00 · R48).
class MonthlyRebalanceJob {
  /// 잡을 만든다 — [cash] = 계좌 별칭 → 브로커(D+2) · [pensionAlias] = 연금 계좌 별칭 ·
  /// [regimeConfigHash] = 국면 설정 지문 · [configHash] = 계획 설정 지문.
  MonthlyRebalanceJob(
    this._db, {
    required this._mode,
    required this._kr,
    required this._us,
    required this._clock,
    required Map<String, OrderBroker> cash,
    required this._holdings,
    required this._pensionAlias,
    required this._regimeConfigHash,
    required this._configHash,
    String pensionDeclaredOutsideText = '0',
    MonthEndConfig? config,
    this._parkingSymbol = kP0sParkingSymbol,
  }) : _cash = Map<String, OrderBroker>.unmodifiable(cash),
       _pensionOutside = pensionDeclaredOutsideText,
       _config = config ?? p0sMonthEndConfig() {
    if (cash.isEmpty) throw ArgumentError('현금 계좌가 없다');
  }

  final Database _db;
  final RunMode _mode;
  final ExchangeCalendar _kr;
  final ExchangeCalendar _us;
  final Clock _clock;
  final Map<String, OrderBroker> _cash;
  final Future<List<LedgerHolding>> Function() _holdings;
  final String _pensionAlias;
  final String _regimeConfigHash;
  final String _configHash;
  final String _pensionOutside;
  final MonthEndConfig _config;
  final String _parkingSymbol;

  List<String> get _planSymbols => <String>{
    for (final (String s, _) in _config.bAssets) s,
    _config.cBondSymbol,
    _config.cGoldSymbol,
    _parkingSymbol,
  }.toList()..sort();

  Map<String, String> _closeTexts(String day, Iterable<String> symbols) {
    final Map<String, String> out = <String, String>{};
    for (final String s in symbols) {
      final ResultSet rs = _db.select(
        "SELECT close_unadj FROM daily_prices WHERE market = 'KR' AND symbol = ? AND trade_date = ?",
        <Object?>[s, day],
      );
      final Object? v = rs.isEmpty ? null : rs.first['close_unadj'];
      if (v is num && v > 0) out[s] = v.toString();
    }
    return out;
  }

  /// [day] 의 국면(같은 날짜 포함 as-of) — (방향 상태 · 쓴 행의 날짜). OK 가 아니거나 UNKNOWN = 상태 null.
  (DirectionState?, String?) _regimeAt(String day) {
    final ResultSet rs = _db.select(
      'SELECT trade_date, status, direction_state FROM regime_score_daily WHERE trade_date <= ? '
      'ORDER BY trade_date DESC LIMIT 1',
      <Object?>[day],
    );
    if (rs.isEmpty) return (null, null);
    final String date = rs.first['trade_date'] as String;
    if (rs.first['status'] != 'OK') return (null, date);
    final Object? st = rs.first['direction_state'];
    for (final DirectionState d in DirectionState.values) {
      if (d.code == st) return (d, date);
    }
    return (null, date);
  }

  bool _hasNext(ExchangeCalendar cal, String day) {
    try {
      cal.nextSession(TradeDate(day));
      return true;
    } on StateError {
      return false;
    }
  }

  /// [monthEnd] 다음 달 월말의 다음 KR 세션(만료 = 다음 판정 날).
  String _nextJudgementDay(String monthEnd) {
    TradeDate d = _kr.nextSession(TradeDate(monthEnd));
    while (!_kr.isLastSessionOfMonth(d)) {
      d = _kr.nextSession(d);
    }
    return _kr.nextSession(d).yyyyMmDd;
  }

  MonthlyRebalanceReport _report(
    String monthEnd,
    Map<String, Object?> o, {
    required bool created,
  }) => MonthlyRebalanceReport(
    planId: rebalancePlanIdOf(monthEnd),
    created: created,
    monthEnd: monthEnd,
    executionDay: o['execution_day']! as String,
    targets: _targetsOf(o),
    sleeveBHeld: o['sleeve_b_held'] == true,
    monthIndex: o['month_index']! as int,
  );

  /// [monthEnd](월 마지막 KR 세션)의 계획을 만든다 — 실패면 [MonthlyRebalanceError](아무것도 쓰지 않음).
  Future<MonthlyRebalanceReport> run(TradeDate monthEnd) async {
    final String d = monthEnd.yyyyMmDd;
    if (!_kr.isLastSessionOfMonth(monthEnd)) {
      throw ArgumentError.value(d, 'monthEnd', '월 마지막 KR 세션이 아니다');
    }
    final SqliteRebalancePlanStore plans = SqliteRebalancePlanStore(_db);
    final Map<String, Object?>? existing = plans.outputsOf(d);
    if (existing != null) return _report(d, existing, created: false);

    // P3 — 국면을 다시 계산 · 덧붙이고 월말 미국 세션 값이 들어왔는지 본다.
    await DailySignalJob(_db, configHash: _regimeConfigHash).run(monthEnd);
    final String? lastUs = SqliteRegimeStore(_db).lastDate();
    if (lastUs == null || !monthEndRegimeReady(d, lastUs, _us)) {
      throw MonthlyRebalanceError('월말 국면 준비 안 됨: $d');
    }

    final List<LedgerHolding> held = await _holdings();
    final String month = d.substring(0, 7);
    final SqliteMarketStore market = SqliteMarketStore(_db);
    final Map<String, List<double>> monthly = <String, List<double>>{
      for (final (String s, _) in _config.bAssets)
        s: monthlyLastCloses(<(String, double)>[
          for (final PriceBar b in market.readBars('KR', s))
            (b.tradeDate, b.close),
        ], month),
    };
    final (String, Map<String, Object?>)? prev = plans.lastBefore(d);
    final int monthIndex = prev == null
        ? 1
        : (prev.$2['month_index']! as int) + 1;
    final (DirectionState?, String?) regime = _regimeAt(d);
    final MonthEndRun run;
    try {
      run = await computeMonthEndRun(
        monthEnd: monthEnd,
        holdings: held,
        closeTexts: _closeTexts(d, <String>{
          ..._planSymbols,
          for (final LedgerHolding h in held) h.symbol,
        }),
        cashAccounts: _cash,
        pensionRows: SqliteDepositLedger(_db).cashRows(_pensionAlias),
        pensionAlias: _pensionAlias,
        pensionOutsideText: _pensionOutside,
        potCashText: potCashOf(potCashFlowsSinceLiquidation(_db)).toString(),
        monthIndex: monthIndex,
        regimeState: regime.$1,
        monthlyCloses: monthly,
        hasNextKrSession: _hasNext(_kr, d),
        hasNextUsSession: _hasNext(_us, d),
        config: _config,
        parkingSymbol: _parkingSymbol,
        instruments: <String, InstrumentKind>{
          for (final String s in _planSymbols) s: InstrumentKind.etf,
        },
      );
    } on MonthEndInputError catch (e) {
      throw MonthlyRebalanceError(e.reason);
    }
    final MonthEndState state = run.state;
    final MonthEndPlan plan = run.plan;
    final List<OrderTarget> targets = run.targets;
    final String execution = _kr.nextSession(monthEnd).yyyyMmDd;
    final String now = _clock.nowUtc().toIso8601String();
    final Map<String, double> before = run.weightsBefore;
    final Map<String, double> after = run.weightsAfter;
    final Map<String, Object?> outputs = <String, Object?>{
      'targets': <Object?>[
        for (final OrderTarget t in targets) orderTargetToJson(t),
      ],
      'execution_day': execution,
      'month_index': monthIndex,
      'sleeve_b_held': plan.sleeveBHeld,
      'weights_before': _weightsJson(before),
      'weights_after': _weightsJson(after),
      'actions': <Object?>[
        for (final MonthEndAction a in plan.actions) monthEndActionToJson(a),
      ],
      'after': monthEndStateToJson(plan.after),
    };
    final String decisionId = monthEndDecisionIdOf(d);
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO plan_snapshot(plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, config_hash) '
        "VALUES (?, 'REBALANCE', ?, ?, ?, ?, ?, ?)",
        <Object?>[
          rebalancePlanIdOf(d),
          now,
          d,
          _nextJudgementDay(d),
          jsonEncode(<String, Object?>{
            ...monthEndStateToJson(state),
            'monthly_closes': monthly,
          }),
          jsonEncode(outputs),
          _configHash,
        ],
      );
      _db.execute(
        'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
        "weights_before, weights_after, config_hash, created_at) VALUES (?, ?, ?, 'MONTHLY_REGULAR', ?, ?, ?, ?, ?, ?)",
        <Object?>[
          'REB-MONTHLY-$d',
          d,
          _mode.wire,
          decisionId,
          jsonEncode(<String, Object?>{
            'regime_state': state.regimeState?.code,
            'regime_ref': regime.$2,
            'regime_last_us_date': lastUs,
            'month_index': monthIndex,
            'sleeve_b_held': plan.sleeveBHeld,
            'targets': targets.length,
          }),
          jsonEncode(_weightsJson(before)),
          jsonEncode(_weightsJson(after)),
          _configHash,
          now,
        ],
      );
      _db.execute(
        'INSERT INTO decision_log(decision_id, created_at, trade_date, mode, kind, strategy_id, reason, reason_code, '
        "regime_ref, config_hash) VALUES (?, ?, ?, ?, 'REBALANCE', ?, ?, 'MONTHLY_REGULAR', ?, ?)",
        <Object?>[
          decisionId,
          now,
          d,
          _mode.wire,
          P0sStrategyIds.deposit,
          '월말 정기 리밸런싱 — 대상 ${targets.length}건 · 집행 $execution',
          regime.$2,
          _configHash,
        ],
      );
    });
    // 🔵 E11g — 계층 B 판정은 여기(저장 뒤)에 건다.
    return _report(d, outputs, created: true);
  }
}

/// `TargetSource` 구현(R48 P8) — 가장 최근 월말 계획 하나 · 집행 첫날 ≤ 오늘 < 만료 · 아직 낸 적 없는 대상만
/// (논리 id@집행일 · 종목 · 방향 — 멱등키 축).
class StoredPlanTargetSource implements TargetSource {
  /// 출처를 만든다.
  StoredPlanTargetSource(this._db);

  final Database _db;

  /// 이미 낸 대상인가 — 멱등키와 같은 축(논리 id@집행일 · 종목 · 방향 · 04 §3-2). 🔴 논리 id 만으로 보지 않는다 —
  /// 한 논리 id 에 대상이 여럿이다(예 `C-REBAL-{월말}` = 채권 · 금).
  bool _issued(OrderTarget t) => _db.select(
    'SELECT 1 FROM order_intents WHERE substr(decision_id, 1, ?) = ? AND symbol = ? AND side = ? LIMIT 1',
    <Object?>[
      t.logicalDecisionId.length + 1,
      '${t.logicalDecisionId}@',
      t.symbol,
      t.side.wire,
    ],
  ).isNotEmpty;

  @override
  Future<List<OrderTarget>> targetsFor(TradeDate today) async {
    final (String, String, Map<String, Object?>)? p = SqliteRebalancePlanStore(
      _db,
    ).latest();
    if (p == null) return const <OrderTarget>[];
    final (String _, String expires, Map<String, Object?> o) = p;
    final String t = today.yyyyMmDd;
    final String exec = o['execution_day']! as String;
    if (t.compareTo(exec) < 0 || t.compareTo(expires) >= 0) {
      return const <OrderTarget>[];
    }
    return <OrderTarget>[
      for (final OrderTarget x in _targetsOf(o))
        if (!_issued(x)) x,
    ];
  }
}
