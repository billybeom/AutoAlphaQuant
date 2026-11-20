// `monthly_rebalance` 본체 · 계획 보관 · 오늘의 대상(설계 13 §8 R48 P1~P10 · 🆕 06 M1-28 둘째 몫).
//
// 🔴 발화 = 월 마지막 KR 세션의 **다음 KR 세션 08:00**(발주자 결정 2026-11-04) — 판정은 월말 종가 + 그날 미국 종가까지 본다(골든과 같다).
//    그래서 이 잡이 먼저 국면을 다시 계산 · 덧붙이고, 월말 미국 세션 값이 아직 없으면 **계획 없이 실패**한다(fail-closed).
// 🔴 저장은 한 트랜잭션이다 — `plan_snapshot`(REBALANCE) · `rebalance_event`(MONTHLY_REGULAR) · `decision_log`(REBALANCE).
//    같은 월말 계획이 이미 있으면 아무것도 바꾸지 않고 그것을 보고한다(멱등 — 다시 돌려도 안전).
// 🔴 POT 현금 = 체결에서 다시 센다(🆕 E11f3 · R49 Q6 — `potCashFlowsSinceLiquidation`) · 예약 원화 = 0(S7).
// 🔴 계층 B 판정(E11g)은 저장 뒤에 건다 — 이 판에는 자리만 있다.
// 🆕 E13d1 — 월말 이하 마지막 스냅숏이 STOPPED 면 계획 행 0(SPEC v2.40 04 §2 «리밸런싱 모두 중단» · R60 B2) ·
//    계층 B 판정은 그대로 · 🔴 `exposureMultiplier` 를 곱하지 않는다(곱하면 B · C 가 팔린다 = 청산).
// 🆕 E3d-3 — SAF-306 과세연도 금융소득 단계(04 §1 Level 3 v2.46 · [P0sIncomeWarnSetup] 을 넘길 때만) — 과세계좌의 해외 ETF
//    브로커 체결(처음부터 · 평균 단가) + 살아 있는 분배금 → 이달 말 누계 · 과세연도 첫 초과 월 = 알림 1건(보고 `alerts`).
//    계획 · 계층 B 와 무관하게 세 길(새로 · 이미 있음 · STOPPED) 모두 보고에 싣는다 · 셈 실패 = «계측 불가» 한 줄 · 알림 0.

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../local/deposit_ledger.dart';
import '../local/planned_work_store.dart'
    show monthlyPlanOneLine, plannedWorkIdOf, registerPlannedWork;
import '../local/position_replay_sql.dart'
    show kLedgerFillColumnsSql, ledgerFillRowOf;
import '../market/market_store.dart';
import '../market/regime_store.dart';
import 'daily_jobs.dart';
import 'seasonal_a_job.dart' show potCashFlowsSinceLiquidation;
import 'tier_b_step.dart';

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

/// 🆕 E14d2a(R76 Q4) — 결정 id → 월말 계획 id. 원 = `MONTH-END-{M}` → `REBAL-{M}` · 재개 child =
/// `PW-MONTH-END-{M}#RESUME-{T}` → `REBAL-{M}#RESUME-{T}` · 모르는 꼴 = null.
String? rebalancePlanIdOfDecision(String decisionId) {
  const String child = 'PW-MONTH-END-';
  const String original = 'MONTH-END-';
  if (decisionId.startsWith(child)) {
    return 'REBAL-${decisionId.substring(child.length)}';
  }
  if (decisionId.startsWith(original)) {
    return 'REBAL-${decisionId.substring(original.length)}';
  }
  return null;
}

/// 🆕 E14d2a(R76 Q1) — 재개 child 계획 id.
String resumeRebalancePlanIdOf(String monthEnd, String today) =>
    '${rebalancePlanIdOf(monthEnd)}#RESUME-$today';

/// 🆕 E14d2a(R76 Q1) — child 논리 id(원 계획의 «낸 적 있음»에 막히지 않게 · `@` · `+` 없음).
String resumeLogicalIdOf(String logicalDecisionId, String today) =>
    '$logicalDecisionId#R$today';

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
    this.tierB,
    this.skippedReason,
    this.incomeWarn,
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

  /// 🆕 E11g — 계층 B 판정 단계(R50 · 계획 저장 뒤).
  final TierBStepReport? tierB;

  /// 🆕 E13d1 — 계획을 만들지 않은 까닭(STOPPED = `BREAKER_STOPPED` · 만들었으면 null).
  final String? skippedReason;

  /// 🆕 E3d-3 — SAF-306 과세연도 금융소득 단계(단계를 켜지 않았으면 null).
  final P0sIncomeWarnStep? incomeWarn;

  @override
  Set<String> get alerts => <String>{...?incomeWarn?.alerts};

  @override
  String toString() =>
      'MonthlyRebalanceReport($planId · ${created ? '새로' : '이미 있음'} · 대상 ${targets.length} · 집행 $executionDay · $tierB'
      '${incomeWarn == null ? '' : ' · 306 ${incomeWarn!.unavailable ?? (incomeWarn!.exceeded ? '넘음' : '안 넘음')}'})';
}

List<Map<String, Object?>> _weightsJson(Map<String, double> w) =>
    <Map<String, Object?>>[
      for (final String k in <String>['A', 'B', 'C', 'POT'])
        <String, Object?>{'sleeve': k, 'weight': w[k]},
    ];

/// [day] 의 국면(같은 날짜 포함 as-of) — (방향 상태 · 쓴 행의 날짜). OK 가 아니거나 UNKNOWN = 상태 null.
/// 🆕 E11q2 — 월말 잡과 리밸런싱 미리보기(R173)가 같은 함수를 쓴다.
(DirectionState?, String?) monthEndRegimeAt(Database db, String day) {
  final ResultSet rs = db.select(
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

  /// 가장 최근 계획의 (as-of · 만료 · 출력)(없으면 null) — 🆕 E14d2a 동률 차례 = 계산 시각 · 계획 id(R76 Q2).
  (String, String, Map<String, Object?>)? latest() {
    final ResultSet rs = _db.select(
      "SELECT as_of_trade_date, expires_at, outputs FROM plan_snapshot WHERE kind = 'REBALANCE' "
      'ORDER BY as_of_trade_date DESC, computed_at DESC, plan_id DESC LIMIT 1',
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

/// 이미 낸 대상인가 — 멱등키와 같은 축(논리 id@집행일 · 종목 · 방향 · 04 §3-2). 🔴 논리 id 만으로 보지 않는다 —
/// 한 논리 id 에 대상이 여럿이다(예 `C-REBAL-{월말}` = 채권 · 금).
bool planTargetIssued(Database db, OrderTarget t) => db.select(
  'SELECT 1 FROM order_intents WHERE substr(decision_id, 1, ?) = ? AND symbol = ? AND side = ? LIMIT 1',
  <Object?>[
    t.logicalDecisionId.length + 1,
    '${t.logicalDecisionId}@',
    t.symbol,
    t.side.wire,
  ],
).isNotEmpty;

/// 🆕 E14c2(R74 M4) — 계획의 대상 가운데 아직 낸 적 없는 것(`StoredPlanTargetSource` · 평시 정리가 같은 축).
List<OrderTarget> unissuedPlanTargets(
  Database db,
  Map<String, Object?> outputs,
) => <OrderTarget>[
  for (final OrderTarget x in _targetsOf(outputs))
    if (!planTargetIssued(db, x)) x,
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
    this._tierBCard = p0sTierBCard,
    this._incomeWarn,
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
  final TierBCard? Function() _tierBCard;
  final P0sIncomeWarnSetup? _incomeWarn;

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

  (DirectionState?, String?) _regimeAt(String day) =>
      monthEndRegimeAt(_db, day);

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

  /// 계층 B 단계(R50 T1 · T8) — 실패 = [MonthlyRebalanceError](계획은 그대로 · 다시 돌리면 판정만).
  /// 월말 **이하** 마지막 스냅숏의 레벨(없으면 NORMAL).
  BreakerLevel _breakerAt(String monthEnd) {
    final ResultSet rs = _db.select(
      'SELECT breaker_level FROM equity_snapshot WHERE trade_date <= ? ORDER BY trade_date DESC LIMIT 1',
      <Object?>[monthEnd],
    );
    return rs.isEmpty
        ? BreakerLevel.normal
        : BreakerLevel.fromCode(rs.first['breaker_level'] as String);
  }

  TierBStepReport _tierB(TradeDate monthEnd) {
    try {
      return TierBStep(_db, clock: _clock, card: _tierBCard).run(monthEnd);
    } on TierBError catch (e) {
      throw MonthlyRebalanceError('계층 B: ${e.reason}');
    }
  }

  /// 🆕 E3d-3 — SAF-306 단계(켜지 않았으면 null). 과세계좌([P0sIncomeWarnSetup.taxableAccountAlias])의
  /// 해외 ETF 브로커 체결(종목별 · 입력 차례 · 처음부터 — 수기 체결은 포지션 재생과 같이 빠진다) · 살아 있는 분배금
  /// (`ledger_event` DISTRIBUTION 원 행 중 되돌려지지 않은 것 · 세전).
  P0sIncomeWarnStep? _incomeStep(String monthEnd) {
    final P0sIncomeWarnSetup? s = _incomeWarn;
    if (s == null) return null;
    final String month = monthEnd.substring(0, 7);
    final List<String> symbols = s.taxableSymbols.toList()..sort();
    final String marks = List<String>.filled(symbols.length, '?').join(', ');
    final Map<String, List<LedgerFillRow>> fills =
        <String, List<LedgerFillRow>>{};
    final List<P0sDistribution> dist = <P0sDistribution>[];
    try {
      for (final Row r in _db.select(
        'SELECT i.symbol AS fill_symbol, $kLedgerFillColumnsSql FROM executions e '
        'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
        'JOIN order_intents i ON i.intent_id = b.intent_id '
        "WHERE i.market = 'KR' AND i.account = ? AND i.symbol IN ($marks) ORDER BY e.rowid",
        <Object?>[s.taxableAccountAlias, ...symbols],
      )) {
        (fills[r['fill_symbol'] as String] ??= <LedgerFillRow>[]).add(
          ledgerFillRowOf(r),
        );
      }
      for (final Row r in _db.select(
        'SELECT l.effective_date, l.symbol, l.amount_krw FROM ledger_event l '
        "WHERE l.kind = 'DISTRIBUTION' AND l.entry_kind = 'ORIGINAL' AND l.account_alias = ? "
        'AND l.symbol IS NOT NULL AND l.amount_krw IS NOT NULL AND NOT EXISTS ('
        "SELECT 1 FROM ledger_event v WHERE v.entry_kind = 'REVERSAL' AND v.reverses_event_id = l.event_id) "
        'ORDER BY l.effective_date, l.event_id',
        <Object?>[s.taxableAccountAlias],
      )) {
        dist.add(
          P0sDistribution.fromLedger(
            effectiveDate: r['effective_date'] as String,
            symbol: r['symbol'] as String,
            amountKrw: (r['amount_krw'] as num).toDouble(),
          ),
        );
      }
    } on ArgumentError catch (e) {
      return P0sIncomeWarnStep(
        month: month,
        ytd: null,
        previousYtd: null,
        exceeded: false,
        unavailable: '금융소득 — 원장 행: ${e.message}',
        alerts: const <String>[],
      );
    }
    return p0sMonthlyIncomeWarnStep(
      month: month,
      fillsBySymbol: fills,
      distributions: dist,
      setup: s,
    );
  }

  MonthlyRebalanceReport _report(
    String monthEnd,
    Map<String, Object?> o, {
    required bool created,
    required TierBStepReport tierB,
    required P0sIncomeWarnStep? incomeWarn,
  }) => MonthlyRebalanceReport(
    planId: rebalancePlanIdOf(monthEnd),
    created: created,
    monthEnd: monthEnd,
    executionDay: o['execution_day']! as String,
    targets: _targetsOf(o),
    sleeveBHeld: o['sleeve_b_held'] == true,
    monthIndex: o['month_index']! as int,
    tierB: tierB,
    incomeWarn: incomeWarn,
  );

  /// 🆕 E14d2a(R76 Q1 · 🔴 발주자 결정 2026-11-13 «M 의 판정 + T 의 금액») — 낡은 월말 계획 [monthEnd] 의 재개일
  /// [today] child. 판정 입력(국면 · 브레이커 · 램프 달 · 월 종가 · 다음 세션 유무)은 원 계획(M) 그대로 · 보유 · 현금 ·
  /// 평가 종가 = T 앞 마지막 세션. 대상 수를 돌려준다(0 = 할 일 없음 · 아무것도 쓰지 않음).
  ///
  /// child 계획 `REBAL-{M}#RESUME-{T}`(as-of = T · 만료 = 원 계획 · 집행 = T · 논리 id = `{원}#R{T}`) + child
  /// `planned_work`(부모 = [parentWorkId]) = 한 트랜잭션 · 같은 날 다시 = 있는 child 그대로. 실패 = 예외(실행기가 센다).
  Future<int> replanAsOf(
    TradeDate monthEnd,
    TradeDate today, {
    required String parentWorkId,
    required String childDecisionId,
    required TradeDate dueBy,
  }) async {
    final String d = monthEnd.yyyyMmDd;
    final String t = today.yyyyMmDd;
    final String childPlanId = resumeRebalancePlanIdOf(d, t);
    final ResultSet have = _db.select(
      'SELECT outputs FROM plan_snapshot WHERE plan_id = ?',
      <Object?>[childPlanId],
    );
    if (have.isNotEmpty) {
      return _targetsOf(
        jsonDecode(have.first['outputs'] as String) as Map<String, Object?>,
      ).length;
    }
    final ResultSet orig = _db.select(
      "SELECT expires_at, outputs FROM plan_snapshot WHERE kind = 'REBALANCE' AND plan_id = ?",
      <Object?>[rebalancePlanIdOf(d)],
    );
    if (orig.isEmpty) {
      throw StateError('원 계획 없음: ${rebalancePlanIdOf(d)}');
    }
    final String expires = orig.first['expires_at'] as String;
    final Map<String, Object?> original =
        jsonDecode(orig.first['outputs'] as String) as Map<String, Object?>;
    final int monthIndex = original['month_index']! as int;
    final String valuation = _kr.nthSessionBefore(today, 1).yyyyMmDd;
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
    final (DirectionState?, String?) regime = _regimeAt(d);
    final MonthEndRun run;
    try {
      run = await computeMonthEndRun(
        monthEnd: monthEnd,
        holdings: held,
        closeTexts: _closeTexts(valuation, <String>{
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
    final List<OrderTarget> targets = <OrderTarget>[
      for (final OrderTarget x in run.targets)
        orderTargetFromJson(<String, Object?>{
          ...orderTargetToJson(x),
          'logical_decision_id': resumeLogicalIdOf(x.logicalDecisionId, t),
        }),
    ];
    if (targets.isEmpty) return 0;
    final String now = _clock.nowUtc().toIso8601String();
    final String outputsJson = jsonEncode(<String, Object?>{
      'targets': <Object?>[
        for (final OrderTarget x in targets) orderTargetToJson(x),
      ],
      'execution_day': t,
      'month_index': monthIndex,
      'sleeve_b_held': run.plan.sleeveBHeld,
      'weights_before': _weightsJson(run.weightsBefore),
      'weights_after': _weightsJson(run.weightsAfter),
      'actions': <Object?>[
        for (final MonthEndAction a in run.plan.actions)
          monthEndActionToJson(a),
      ],
      'after': monthEndStateToJson(run.plan.after),
      'decision_id': childDecisionId,
      'resume_of': rebalancePlanIdOf(d),
      'valuation_day': valuation,
    });
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO plan_snapshot(plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, config_hash) '
        "VALUES (?, 'REBALANCE', ?, ?, ?, ?, ?, ?)",
        <Object?>[
          childPlanId,
          now,
          t,
          expires,
          jsonEncode(<String, Object?>{
            ...monthEndStateToJson(run.state),
            'monthly_closes': monthly,
          }),
          outputsJson,
          _configHash,
        ],
      );
      registerPlannedWork(
        _db,
        kind: ResumeWorkKinds.monthlyPlan,
        decisionId: childDecisionId,
        dueBy: dueBy,
        oneLine: '${monthlyPlanOneLine(d)} · 재개 재판정',
        payloadJson: outputsJson,
        createdAtUtc: now,
        parentWorkId: parentWorkId,
      );
    });
    return targets.length;
  }

  /// [monthEnd](월 마지막 KR 세션)의 계획을 만든다 — 실패면 [MonthlyRebalanceError](아무것도 쓰지 않음).
  Future<MonthlyRebalanceReport> run(TradeDate monthEnd) async {
    final String d = monthEnd.yyyyMmDd;
    if (!_kr.isLastSessionOfMonth(monthEnd)) {
      throw ArgumentError.value(d, 'monthEnd', '월 마지막 KR 세션이 아니다');
    }
    final P0sIncomeWarnStep? income = _incomeStep(d);
    final SqliteRebalancePlanStore plans = SqliteRebalancePlanStore(_db);
    final Map<String, Object?>? existing = plans.outputsOf(d);
    if (existing != null) {
      return _report(
        d,
        existing,
        created: false,
        tierB: _tierB(monthEnd),
        incomeWarn: income,
      );
    }
    if (_breakerAt(d) == BreakerLevel.stopped) {
      return MonthlyRebalanceReport(
        planId: rebalancePlanIdOf(d),
        created: false,
        monthEnd: d,
        executionDay: _kr.nextSession(monthEnd).yyyyMmDd,
        targets: const <OrderTarget>[],
        sleeveBHeld: false,
        monthIndex: 0,
        tierB: _tierB(monthEnd),
        skippedReason: kBreakerStoppedAlertCode,
        incomeWarn: income,
      );
    }

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
    final String expires = _nextJudgementDay(d);
    final String outputsJson = jsonEncode(outputs);
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO plan_snapshot(plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, config_hash) '
        "VALUES (?, 'REBALANCE', ?, ?, ?, ?, ?, ?)",
        <Object?>[
          rebalancePlanIdOf(d),
          now,
          d,
          expires,
          jsonEncode(<String, Object?>{
            ...monthEndStateToJson(state),
            'monthly_closes': monthly,
          }),
          outputsJson,
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
      // 🆕 E14c2(R74 M1 · M2) — 같은 트랜잭션에 `planned_work` 1행 · 낼 수 있는 마지막 세션 = 다음 판정 날의 앞 세션.
      registerPlannedWork(
        _db,
        kind: ResumeWorkKinds.monthlyPlan,
        decisionId: decisionId,
        dueBy: _kr.nthSessionBefore(TradeDate(expires), 1),
        oneLine: monthlyPlanOneLine(d),
        payloadJson: outputsJson,
        createdAtUtc: now,
      );
    });
    // 🆕 E11g — 계층 B 판정(저장 뒤 · 실패해도 계획은 남는다 → 다시 돌리면 판정만 · R50 T1 · T8).
    return _report(
      d,
      outputs,
      created: true,
      tierB: _tierB(monthEnd),
      incomeWarn: income,
    );
  }
}

/// `TargetSource` 구현(R48 P8) — 가장 최근 월말 계획 하나 · 집행 첫날 ≤ 오늘 < 만료 · 아직 낸 적 없는 대상만
/// (논리 id@집행일 · 종목 · 방향 — 멱등키 축).
class StoredPlanTargetSource implements TargetSource {
  /// 출처를 만든다.
  StoredPlanTargetSource(this._db);

  final Database _db;

  @override
  Future<List<OrderTarget>> targetsFor(TradeDate today) async {
    final (String, String, Map<String, Object?>)? p = SqliteRebalancePlanStore(
      _db,
    ).latest();
    if (p == null) return const <OrderTarget>[];
    final (String asOf, String expires, Map<String, Object?> o) = p;
    final String t = today.yyyyMmDd;
    final String exec = o['execution_day']! as String;
    if (t.compareTo(exec) < 0 || t.compareTo(expires) >= 0) {
      return const <OrderTarget>[];
    }
    // 🆕 E14d2a(R76 Q2) — 🔴 낡은 계획 차단: 그 계획의 `planned_work` 가 PLANNED 일 때만(없으면 = 옛 계획 · 지금처럼).
    final String decision =
        o['decision_id'] as String? ?? monthEndDecisionIdOf(asOf);
    final ResultSet w = _db.select(
      'SELECT state FROM planned_work WHERE work_id = ?',
      <Object?>[plannedWorkIdOf(decision)],
    );
    if (w.isNotEmpty && w.first['state'] != 'PLANNED') {
      return const <OrderTarget>[];
    }
    return unissuedPlanTargets(_db, o);
  }
}
