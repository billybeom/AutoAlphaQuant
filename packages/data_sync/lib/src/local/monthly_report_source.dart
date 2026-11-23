// 🆕 미결 209 ⓔ-1 — 월간 리포트(`S7-1`) 원천: 원장 원문 → 칸마다 엔진 입력 → `monthlyReportOf`
// (설계 13 §8 R218 · 앱 01 §8 미결 209 · 앞 판 R199 · R205 · R208 · R210 · R217).
//
// 🔴 셈 · 글자 = 엔진(`monthlyReportOf` · 칸마다 입력 타입) · 여기는 원장을 모으기만 한다(지어낸 행 0).
// 🔴 원장 한 파일 = 그 파일의 행 전부(파일이 모드 경계 · 01 §9-1) — 모드로 거르지 않는다.
// 🔴 칸마다 원천: A1 · A2 · C1 · C2 · G1 = 계층 B 와 같은 TWR 시리즈(`tierBSeries`) + 그 달 KR 세션 · D2 값 = 그 달 월말
//    정기 회차의 앞 비중 · D2 메모 = 월 잡과 같은 노출 집계([ledgerExposureTallyOf]) · D4 = 재량 사용 날 · E1 · G2 = 전략 상태 +
//    안전 상태 + 그 달 계층 B 판정 · D3 = 그 달 `decision_log` 종류 + 이탈 저널 수 · D1 = 그 달 `regime_score_daily`.
// 🔴 원천 0 = 호출자 인자로 남긴다: 원장 신뢰 배지(생산자 0) · 탐색 열람 수(`DISCLOSURE_VIEW` 저장 0) · 설정 지문 · 생성 시각 ·
//    소급 각주. 🔴 스냅숏 저장(마감된 달 재계산 금지 · G-97) · 미생성 · 가림(01 §2-10) = 다음 조각 — 이 원천은 부를 때마다
//    원장에서 다시 모은다.
// 🆕 R231(미결 209 ⓔ-2 · ⓔ-3 · ⓔ-5) — [SqliteMonthlyReportSource.reportOnRead] = 읽을 때 짓기(저장 0): 닫힌 달 · 개시 달부터
//    (엔진 [monthlyReportReadinessOf] — 그 밖 = 실패) · 신뢰 배지 = 브로커 대사 원장([brokerReconChecksOf] → 엔진
//    [monthlyLedgerTrustOf] · 그 달 마감 시점) · 열람 수 = 탐색 게이트와 같은 셈([ledgerDisclosureViewsOf]) · 무결성 점검 중 =
//    엔진 가림 꼴([monthlyReportIntegrityMaskedOf]) · 생성 시각 = 지금(지금 지었다 — 정직) · 「자세히」 = 본문이 있는 화면만.
//    🔵 ⓔ-4 남김 = 스냅숏 저장(`rm_monthly_report` · G-97) · 미생성 문장(생성일 규칙 · 미결 40) · 아카이브(S7-1b) · 소급 각주.
// 🆕 R238(E11q-q5d) — `S7-9` 목표 경로 원천([ledgerGoalPathOutcomeOf] · [ledgerGoalPathOnRead]) = 같은 마감 평가 시리즈
//    (`tierBSeries`) + 월 납입 설정 기록(`operating_param_log` · [contributionRowsOf]) + KR 달력 → 엔진 `goalPathOf` ·
//    월간 리포트 목표 줄 · 「목표 경로 보기」 = 같은 판정(리포트를 지을 때 한 번 — 두 벌로 갈리지 않는다).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../jobs/daily_jobs.dart' show SqliteEquitySnapshotStore;
import '../jobs/tier_b_step.dart' show tierBSeries;
import 'deposit_ledger.dart' show openingCashTradeDate;
import 'operating_param_store.dart' show contributionRowsOf;
import 'performance_source.dart'
    show ledgerDisclosureViewsOf, ledgerIntegrityHidden;
import 'position_replay_sql.dart' show krSignedFillsAfter;
import 'rebalance_source.dart' show storedRebalanceWeightsOf;

final RegExp _yyyyMm = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

/// [yyyyMm] 의 마지막 KR 세션(달력) — 달 첫날부터 걸어 그 달의 마지막 세션. 달력이 덮지 않으면 [StateError].
TradeDate krMonthEndOf(ExchangeCalendar kr, String yyyyMm) {
  if (!_yyyyMm.hasMatch(yyyyMm)) {
    throw ArgumentError.value(yyyyMm, 'yyyyMm', 'YYYY-MM 이 아니다');
  }
  TradeDate d = TradeDate('$yyyyMm-01');
  if (!kr.isSession(d)) d = kr.nextSession(d);
  if (!d.yyyyMmDd.startsWith('$yyyyMm-')) {
    throw StateError('$yyyyMm 에 KR 세션이 없다');
  }
  while (!kr.isLastSessionOfMonth(d)) {
    d = kr.nextSession(d);
  }
  return d;
}

/// [monthEnd] 달의 KR 세션 전부(날짜 순 · 달력 범위 시작이면 거기서 멈춘다).
List<String> krMonthSessionsOf(ExchangeCalendar kr, TradeDate monthEnd) {
  final String month = monthEnd.yyyyMmDd.substring(0, 7);
  final List<String> sessions = <String>[monthEnd.yyyyMmDd];
  TradeDate d = monthEnd;
  while (true) {
    final TradeDate p;
    try {
      p = kr.nthSessionBefore(d, 1);
    } on StateError {
      break; // 달력 범위 시작 — 그 앞 세션은 모른다
    }
    if (!p.yyyyMmDd.startsWith('$month-')) break;
    sessions.insert(0, p.yyyyMmDd);
    d = p;
  }
  return sessions;
}

/// 그날 KR 저장 종가(수정 전) 글자 — 없거나 0 이하 = 뺀다(지어내지 않는다).
Map<String, String> ledgerCloseTextsOf(
  Database db,
  String day,
  Iterable<String> symbols,
) {
  final Map<String, String> out = <String, String>{};
  for (final String s in symbols) {
    final ResultSet rs = db.select(
      "SELECT close_unadj FROM daily_prices WHERE market = 'KR' AND symbol = ? AND trade_date = ?",
      <Object?>[s, day],
    );
    final Object? v = rs.isEmpty ? null : rs.first['close_unadj'];
    if (v is num && v > 0) out[s] = v.toString();
  }
  return out;
}

/// 🔴 E3d-4 월 집계 — 월 잡과 월간 리포트가 같은 함수(04 §1 Level 3 v2.46 · R176 «저장 0 · 재계산»):
/// [monthEnd] 달 KR 세션마다 그날 보유 = [held] − 그 뒤 집행일의 체결([holdingsBeforeFills]) · 종가 = 그날 저장 종가 · 현금 = 그날
/// 평가 행. 평가 행 없음 · 원장 재생 실패 · 종가 없음 = 그날 계측 없음(까닭) · 알림 0.
P0sExposureTally ledgerExposureTallyOf(
  Database db, {
  required RunMode mode,
  required ExchangeCalendar kr,
  required TradeDate monthEnd,
  required List<LedgerHolding> held,
  required P0sWarnSetup setup,
}) {
  final SqliteEquitySnapshotStore store = SqliteEquitySnapshotStore(
    db,
    mode: mode,
  );
  P0sTallyDay day(String d) {
    final EquitySnapshotRow? row = store.at(d);
    if (row == null) return (date: d, inputs: null, reason: '평가 행 없음');
    try {
      final List<LedgerHolding> before = holdingsBeforeFills(
        held,
        krSignedFillsAfter(db, d),
      );
      return (
        date: d,
        inputs: P0sWarnInputs.fromTexts(
          holdings: before,
          closeTexts: ledgerCloseTextsOf(db, d, <String>{
            for (final LedgerHolding h in before) h.symbol,
          }),
          cashKrw: row.cashKrw,
        ),
        reason: null,
      );
    } on RiskCheckUnavailable catch (e) {
      return (date: d, inputs: null, reason: e.message);
    }
  }

  return p0sMonthlyExposureTally(
    month: monthEnd.yyyyMmDd.substring(0, 7),
    days: <P0sTallyDay>[
      for (final String d in krMonthSessionsOf(kr, monthEnd)) day(d),
    ],
    setup: setup,
  );
}

/// 🆕 R231 — 브로커 대사 원장(`reconciliation_log` 의 `rc-` 행 · 해제 행 `rc-clear-` 제외) → (시각 · 결과) 시각 순.
/// 🔴 순서 = 시각 값(글자 정렬은 소수 초 자릿수가 다르면 틀린다) · 같은 시각 = 기록 id 순 · 결과 글자가 [ReconAction] 밖 =
/// [StateError](지어내지 않는다).
List<(DateTime, ReconAction)> brokerReconChecksOf(Database db) {
  final List<(DateTime, ReconAction, int)> rows =
      <(DateTime, ReconAction, int)>[
        for (final (int i, Row r)
            in db
                .select(
                  "SELECT run_at, action_taken FROM reconciliation_log WHERE recon_id GLOB 'rc-*' "
                  "AND recon_id NOT GLOB 'rc-clear-*' ORDER BY recon_id",
                )
                .indexed)
          (
            DateTime.parse(r['run_at'] as String).toUtc(),
            ReconAction.values.firstWhere(
              (ReconAction a) => a.code == r['action_taken'],
              orElse: () => throw StateError(
                'reconciliation_log 대사 결과 밖: ${r['action_taken']}',
              ),
            ),
            i,
          ),
      ];
  rows.sort(
    ((DateTime, ReconAction, int) a, (DateTime, ReconAction, int) b) =>
        a.$1 == b.$1 ? a.$3.compareTo(b.$3) : a.$1.compareTo(b.$1),
  );
  return <(DateTime, ReconAction)>[
    for (final (DateTime at, ReconAction a, int _) in rows) (at, a),
  ];
}

/// 월간 리포트 칸마다 엔진 입력(원장에서 모은 것 — null = 그 칸 원천 없음 → «산출 불가»).
class MonthlyReportInputs {
  /// 만든다.
  const MonthlyReportInputs({
    required this.yyyyMm,
    required this.monthEnd,
    required this.equity,
    required this.allocation,
    required this.exposureTally,
    required this.discretionUseDates,
    required this.strategy,
    required this.execution,
    required this.regime,
  });

  /// 달(YYYY-MM).
  final String yyyyMm;

  /// 그 달 마지막 KR 세션.
  final TradeDate monthEnd;

  /// A1 · A2 · C1 · C2 · G1(스냅숏 0 = null).
  final MonthlyEquityFacts? equity;

  /// D2 값 — 그 달 월말 정기 회차의 앞 비중 세 줄(회차 없음 · 저장 비중 없음 = null).
  final List<SleeveWeight>? allocation;

  /// D2 메모(집계 설정 없음 = null).
  final P0sExposureTally? exposureTally;

  /// D4 — 재량 사용 날 전부(엔진이 월말까지 거른다).
  final List<String> discretionUseDates;

  /// E1 · G2(전략 행 0 = null).
  final MonthlyStrategyFacts? strategy;

  /// D3.
  final MonthlyExecutionFacts execution;

  /// D1(그 달 국면 행 0 = null).
  final MonthlyRegimeFacts? regime;
}

/// 🆕 미결 209 ⓔ-1 — 월간 리포트 원천(원장 한 파일).
class SqliteMonthlyReportSource {
  /// 만든다 — [holdings] = 지금 보유(월 잡과 같은 원천) · [safety] = 안전 상태 한 장(홈 · 차단 보드와 같은 것) ·
  /// [discretionUseDates] = 재량 사용 날(`SqliteDiscretionStore.useDates`) · [exposure] null = D2 메모 없음 ·
  /// [config] = 비중 목표 · 밴드(없으면 정본).
  SqliteMonthlyReportSource(
    this._db, {
    required this._mode,
    required this._kr,
    required this._holdings,
    required this._safety,
    required this._discretionUseDates,
    this._exposure,
    WhatIfConfig? config,
  }) : _config = config ?? WhatIfConfig.defaults;

  final Database _db;
  final RunMode _mode;
  final ExchangeCalendar _kr;
  final Future<List<LedgerHolding>> Function() _holdings;
  final SafetyState Function() _safety;
  final List<String> Function() _discretionUseDates;
  final P0sWarnSetup? _exposure;
  final WhatIfConfig _config;

  /// [yyyyMm] 의 칸마다 엔진 입력을 원장에서 모은다.
  Future<MonthlyReportInputs> inputs(String yyyyMm) async {
    final TradeDate monthEnd = krMonthEndOf(_kr, yyyyMm);
    final String end = monthEnd.yyyyMmDd;
    final String first = '$yyyyMm-01';
    final List<EquityPoint> series = tierBSeries(_db, end);
    final P0sWarnSetup? setup = _exposure;
    return MonthlyReportInputs(
      yyyyMm: yyyyMm,
      monthEnd: monthEnd,
      equity: series.isEmpty
          ? null
          : MonthlyEquityFacts(
              series: series,
              monthSessions: krMonthSessionsOf(_kr, monthEnd),
            ),
      allocation: _allocation(end),
      exposureTally: setup == null
          ? null
          : ledgerExposureTallyOf(
              _db,
              mode: _mode,
              kr: _kr,
              monthEnd: monthEnd,
              held: await _holdings(),
              setup: setup,
            ),
      discretionUseDates: _discretionUseDates(),
      strategy: _strategy(yyyyMm),
      execution: MonthlyExecutionFacts(
        decisionKinds: <String>[
          for (final Row r in _db.select(
            'SELECT kind FROM decision_log WHERE trade_date >= ? AND trade_date <= ? '
            'ORDER BY trade_date, decision_id',
            <Object?>[first, end],
          ))
            r['kind'] as String,
        ],
        deviationJournals:
            _db.select(
                  'SELECT COUNT(*) AS n FROM decision_journal WHERE is_deviation = 1 '
                  'AND trade_date >= ? AND trade_date <= ?',
                  <Object?>[first, end],
                ).first['n']
                as int,
      ),
      regime: _regime(first, end),
    );
  }

  /// 월간 리포트 — 원천 0 인 머리 값([trust] · [disclosureViewCount] · [configHash] · [backdateFootnote])은 부르는 쪽이 준다 ·
  /// 🆕 R231 [hasBody] = 「자세히」 목적지 본문(null = 링크 0).
  Future<MonthlyReport> monthlyReport(
    String yyyyMm, {
    required DateTime generatedAtUtc,
    required String configHash,
    required LedgerTrustBadge trust,
    required int disclosureViewCount,
    String? backdateFootnote,
    bool Function(String route)? hasBody,
  }) async {
    final MonthlyReportInputs i = await inputs(yyyyMm);
    // 🆕 R238 — 목표 줄 · 링크 = 같은 시리즈의 목표 경로 판정(스냅숏 0 = 유보).
    final GoalVerdict goal = ledgerGoalPathOutcomeOf(
      _db,
      kr: _kr,
      yyyyMm: yyyyMm,
      monthEnd: i.monthEnd,
      nowUtc: generatedAtUtc,
      series: i.equity?.series ?? const <EquityPoint>[],
    ).verdict;
    return monthlyReportOf(
      yyyyMm: yyyyMm,
      monthEnd: i.monthEnd,
      generatedAtUtc: generatedAtUtc,
      configHash: configHash,
      trust: trust,
      disclosureViewCount: disclosureViewCount,
      allocation: i.allocation,
      exposureTally: i.exposureTally,
      equity: i.equity,
      discretionUseDates: i.discretionUseDates,
      strategy: i.strategy,
      execution: i.execution,
      regime: i.regime,
      backdateFootnote: backdateFootnote,
      hasBody: hasBody,
      goal: goal,
    );
  }

  /// 🆕 R231 — 읽을 때 짓는 월간 리포트(저장 0 · 자동 매매 — 신뢰 배지 = 브로커 대사).
  ///
  /// [nowUtc] = 생성 시각(지금 지었다) · [configHash] = 지금 설정 지문(못 얻으면 빈 글자) · [hasBody] = 「자세히」 · 배지 링크 목적지.
  /// 🔴 아직 닫히지 않은 달 = [UnsupportedError](미생성 문장 = ⓔ-4) · 개시 전 달 = [StateError](지어내지 않는다) ·
  /// 달 꼴 · 달력 밖 = [krMonthEndOf] 의 실패 그대로.
  Future<MonthlyReport> reportOnRead(
    String yyyyMm, {
    required DateTime nowUtc,
    required String configHash,
    bool Function(String route)? hasBody,
  }) async {
    final TradeDate monthEnd = krMonthEndOf(_kr, yyyyMm);
    switch (monthlyReportReadinessOf(
      yyyyMm: yyyyMm,
      monthEnd: monthEnd,
      openingDate: openingCashTradeDate(_db),
      nowUtc: nowUtc,
    )) {
      case MonthlyReportReadiness.pending:
        throw UnsupportedError(
          '월간 리포트 $yyyyMm: 미생성 — 아직 닫히지 않은 달(미생성 문장 = 209 ⓔ-4)',
        );
      case MonthlyReportReadiness.beforeOpening:
        throw StateError('월간 리포트 $yyyyMm: 개시 전 달 — 리포트 없음');
      case MonthlyReportReadiness.closed:
        break;
    }
    final int views = ledgerDisclosureViewsOf(_db, yyyyMm);
    if (ledgerIntegrityHidden(_db)) {
      return monthlyReportIntegrityMaskedOf(
        yyyyMm: yyyyMm,
        monthEnd: monthEnd,
        generatedAtUtc: nowUtc,
        configHash: configHash,
        disclosureViewCount: views,
        hasBody: hasBody,
      );
    }
    return monthlyReport(
      yyyyMm,
      generatedAtUtc: nowUtc,
      configHash: configHash,
      trust: monthlyLedgerTrustOf(
        checks: brokerReconChecksOf(_db),
        monthEnd: monthEnd,
        hasBody: hasBody,
      ),
      disclosureViewCount: views,
      hasBody: hasBody,
    );
  }

  /// 그 달 월말 정기 회차(거래일 = 월말 세션 · 마지막 기록)의 앞 비중 → 세 줄 · 없음 = null.
  List<SleeveWeight>? _allocation(String monthEnd) {
    final ResultSet rs = _db.select(
      "SELECT weights_before FROM rebalance_event WHERE kind = 'MONTHLY_REGULAR' AND trade_date = ? "
      'ORDER BY created_at DESC, event_id DESC LIMIT 1',
      <Object?>[monthEnd],
    );
    if (rs.isEmpty) return null;
    final Map<String, double> w = storedRebalanceWeightsOf(
      rs.first['weights_before'] as String,
    );
    return w.isEmpty ? null : rebalanceWeightLinesOf(w, _config);
  }

  /// 전략 상태 전부 · 안전 상태 · 그 달 계층 B 판정(전략마다 같은 판정 — D7 ① · 하나라도 충족 = 충족) · 전략 0 = null.
  MonthlyStrategyFacts? _strategy(String yyyyMm) {
    final List<String> states = <String>[
      for (final Row r in _db.select(
        'SELECT state FROM strategy_state_current ORDER BY strategy_id',
      ))
        r['state'] as String,
    ];
    if (states.isEmpty) return null;
    final ResultSet j = _db.select(
      'SELECT MAX(b1_breached) AS b1, MAX(b2_breached) AS b2, MAX(b3_breached) AS b3, COUNT(*) AS n '
      'FROM tier_b_judgement WHERE judged_month = ?',
      <Object?>[yyyyMm],
    );
    final Row r = j.first;
    return MonthlyStrategyFacts(
      strategyStates: states,
      safety: _safety(),
      tierB: (r['n'] as int) == 0
          ? null
          : TierBVerdict(b1: r['b1'] == 1, b2: r['b2'] == 1, b3: r['b3'] == 1),
    );
  }

  /// 그 달 국면(판정 OK 인 날만 상태 · 나머지 = null) · 앞 달 마지막 판정 · 그 달 행 0 = null.
  MonthlyRegimeFacts? _regime(String first, String end) {
    final List<String?> month = <String?>[
      for (final Row r in _db.select(
        "SELECT CASE WHEN status = 'OK' THEN direction_state END AS s FROM regime_score_daily "
        'WHERE trade_date >= ? AND trade_date <= ? ORDER BY trade_date',
        <Object?>[first, end],
      ))
        r['s'] as String?,
    ];
    if (month.isEmpty) return null;
    final ResultSet p = _db.select(
      "SELECT direction_state FROM regime_score_daily WHERE trade_date < ? AND status = 'OK' "
      "AND direction_state IN ('BULL', 'NEUTRAL', 'BEAR') ORDER BY trade_date DESC LIMIT 1",
      <Object?>[first],
    );
    return MonthlyRegimeFacts(
      previousState: p.isEmpty ? null : p.first['direction_state'] as String,
      monthStates: month,
    );
  }
}

/// 🆕 R238 — [yyyyMm] 목표 경로(엔진 `goalPathOf`) — [series] null = 원장에서 다시 모은다(`tierBSeries` · 월말까지) ·
/// 월 납입 = `operating_param_log` 기록(없으면 [config] 기본값) · 판정 머리 검사 없음(읽기 경로 · 리포트가 정한다).
GoalPathOutcome ledgerGoalPathOutcomeOf(
  Database db, {
  required ExchangeCalendar kr,
  required String yyyyMm,
  required TradeDate monthEnd,
  required DateTime nowUtc,
  List<EquityPoint>? series,
  ContributionConfig? config,
}) => goalPathOf(
  yyyyMm: yyyyMm,
  monthEnd: monthEnd,
  equity: series ?? tierBSeries(db, monthEnd.yyyyMmDd),
  isSession: (String d) => kr.isSession(TradeDate(d)),
  contributionRows: contributionRowsOf(db),
  contributionConfig: config ?? p0sContributionConfig(),
  nowUtc: nowUtc,
);

/// 🆕 R238 — 읽을 때 짓는 `S7-9` 목표 경로(저장 0 · [nowUtc] = 읽은 시각).
///
/// 🔴 월간 리포트와 같은 판정: 아직 닫히지 않은 달 = [UnsupportedError] · 개시 전 달 = [StateError](지어내지 않는다) ·
/// 원장 무결성 점검 중 = [StateError](숫자 가림 — 가림 표본 없음 · R226 드로다운 선례 · 리포트 링크도 부재) ·
/// 달 꼴 · 달력 밖 = [krMonthEndOf] 의 실패 그대로.
GoalPathVm ledgerGoalPathOnRead(
  Database db, {
  required ExchangeCalendar kr,
  required String yyyyMm,
  required DateTime nowUtc,
}) {
  final TradeDate monthEnd = krMonthEndOf(kr, yyyyMm);
  switch (monthlyReportReadinessOf(
    yyyyMm: yyyyMm,
    monthEnd: monthEnd,
    openingDate: openingCashTradeDate(db),
    nowUtc: nowUtc,
  )) {
    case MonthlyReportReadiness.pending:
      throw UnsupportedError('목표 경로 $yyyyMm: 아직 닫히지 않은 달(월간 리포트 미생성)');
    case MonthlyReportReadiness.beforeOpening:
      throw StateError('목표 경로 $yyyyMm: 개시 전 달 — 경로 없음');
    case MonthlyReportReadiness.closed:
      break;
  }
  if (ledgerIntegrityHidden(db)) {
    throw StateError('목표 경로 $yyyyMm: 원장 무결성 점검 중 — 숫자를 보여 주지 않는다');
  }
  return ledgerGoalPathOutcomeOf(
    db,
    kr: kr,
    yyyyMm: yyyyMm,
    monthEnd: monthEnd,
    nowUtc: nowUtc,
  ).vm;
}
