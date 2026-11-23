// 🆕 미결 209 ⓔ-1 — 월간 리포트 원천: 원장 원문 → 칸마다 엔진 입력 → `monthlyReportOf`(설계 13 §8 R218).
//
// 🔴 셈은 엔진 — 여기는 모으기만 한다: 그 달 범위(첫날 ~ 월말 세션) · 월말 정기 회차의 앞 비중 · 전략 · 계층 B 판정 ·
//    결정 종류 · 이탈 저널 · 국면(판정 OK 만) · 앞 달 마지막 판정 · 집계 = 월 잡과 같은 함수.
// 🆕 R231 — 읽을 때 짓기(`reportOnRead` — 닫힌 달 · 개시 달부터 · 신뢰 배지 = 브로커 대사 원장 · 열람 수 = 접수 한국 달 ·
//    무결성 점검 중 = 가림 꼴) · 대사 원장 읽기(`brokerReconChecksOf`).
// 🆕 R238 — 목표 경로 원천(`ledgerGoalPathOnRead` · 같은 시리즈 + 월 납입 설정 기록 → 엔진 `goalPathOf`) · 월간 리포트 목표 줄 ·
//    「목표 경로 보기」 = 같은 판정.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 7, 31, 23); // 한국 08-01 08:00
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

const LedgerTrustBadge _trust = LedgerTrustBadge(
  grade: LedgerTrustGrade.reconciled,
  level: UiLevel.ok,
  label: '대사 완료',
  consequenceLine: '브로커 원장과 수량·현금이 맞습니다.',
);

SafetyState _safety0() => SafetyState.fromJson(
  ((jsonDecode(
                File('../domain_contracts/fixtures/safety_states.json')
                    .readAsStringSync(),
              ) as Map<String, Object?>)['rows']!
              as List<Object?>)
          .first!
      as Map<String, dynamic>,
); // NORMAL · 플래그 0 · 램프 L3

void main() {
  late Directory dir;
  late Database db;
  int seq = 0;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('r218_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    seq = 0;
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteMonthlyReportSource src({
    List<String> uses = const <String>[],
    P0sWarnSetup? exposure,
  }) => SqliteMonthlyReportSource(
    db,
    mode: RunMode.live,
    kr: _kr,
    holdings: () async => const <LedgerHolding>[],
    safety: _safety0,
    discretionUseDates: () => uses,
    exposure: exposure,
  );

  void snap(String day, double equity) => db.execute(
    'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
    "VALUES (?, ?, ?, 0, ?, 0, 'LIVE')",
    <Object?>[day, equity, equity, equity],
  );

  void event(
    String id,
    String day, {
    String kind = 'MONTHLY_REGULAR',
    String before = '[]',
    String created = '2026-07-31T11:00:00Z',
  }) => db.execute(
    'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
    'weights_before, weights_after, config_hash, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      id,
      day,
      RunMode.live.wire,
      kind,
      'D-$id',
      '{}',
      before,
      '[]',
      'cfg_t',
      created,
    ],
  );

  void decision(String day, String kind) => db.execute(
    'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
    "reason_code, config_hash) VALUES (?, '2026-07-01T00:00:00.000Z', ?, 'LIVE', ?, 'P0S', '결정', 'C', 'cfg')",
    <Object?>['DL-${seq++}', day, kind],
  );

  void journal(String day, int deviation) => db.execute(
    'INSERT INTO decision_journal (journal_id, trade_date, strategy_id, signal_value, action_taken, '
    'is_deviation, rationale_before, expected_outcome, rule_cited, note, created_at) VALUES (?, ?, '
    "'P0S', '{}', '{}', ?, '근거', '기대', '규칙', NULL, '2026-07-01T00:00:00.000Z')",
    <Object?>['J-${seq++}', day, deviation],
  );

  void regime(String day, String? state, {String status = 'OK'}) => db.execute(
    'INSERT INTO regime_score_daily (trade_date, status, direction_state, config_hash) VALUES (?, ?, ?, ?)',
    <Object?>[day, status, state, 'cfg'],
  );

  void strategy(String id, String state) => db.execute(
    'INSERT INTO strategy_state_current(strategy_id, state, since, capital_cap) VALUES (?, ?, ?, 1.0)',
    <Object?>[id, state, '2026-01-02'],
  );

  void tierB(String id, {int b1 = 0, int b2 = 0, int b3 = 0}) => db.execute(
    "INSERT INTO tier_b_judgement VALUES ('2026-07', ?, 't', ?, ?, ?, 0)",
    <Object?>[id, b1, b2, b3],
  );

  ReportItem item(MonthlyReport r, String code) =>
      r.items.singleWhere((ReportItem i) => i.code == code);

  group('달력', () {
    test('🔴 월말 세션 = 그 달 마지막 KR 세션 · 세션 목록 = 그 달 전부(날짜 순)', () {
      final TradeDate end = krMonthEndOf(_kr, '2026-07');
      expect(end.yyyyMmDd, '2026-07-31');
      expect(_kr.isLastSessionOfMonth(end), isTrue);
      final List<String> s = krMonthSessionsOf(_kr, end);
      expect(s.first, startsWith('2026-07-0'));
      expect(s.last, '2026-07-31');
      for (int i = 0; i < s.length; i++) {
        expect(s[i], startsWith('2026-07-'));
        expect(_kr.isSession(TradeDate(s[i])), isTrue);
        if (i > 0) expect(s[i - 1].compareTo(s[i]) < 0, isTrue);
      }
      expect(
        _kr.isSession(_kr.nthSessionBefore(TradeDate(s.first), 1)),
        isTrue,
      );
      expect(
        _kr.nthSessionBefore(TradeDate(s.first), 1).yyyyMmDd,
        startsWith('2026-06-'),
      ); // 그 달 첫 세션 앞 = 앞 달
      final TradeDate may = krMonthEndOf(_kr, '2026-05');
      expect(may.yyyyMmDd, startsWith('2026-05-'));
      expect(_kr.isLastSessionOfMonth(may), isTrue);
      expect(
        () => krMonthEndOf(_kr, '2026-7'),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.name,
            'name',
            'yyyyMm',
          ),
        ),
      ); // 달 꼴 가드(달력 오류가 아니라)
    });
  });

  group('원장 → 엔진 입력', () {
    test('🔴 끝에서 끝 — 원장 한 달 → 리포트 11칸(B1 · F1 = 원천 0)', () async {
      final List<String> july = krMonthSessionsOf(
        _kr,
        const TradeDate('2026-07-31'),
      );
      snap('2026-06-30', 100);
      for (int i = 0; i < july.length; i++) {
        snap(july[i], 100 + i.toDouble());
      }
      event(
        'M-07',
        '2026-07-31',
        before: jsonEncode(<Map<String, Object?>>[
          <String, Object?>{'sleeve': 'A', 'weight': 0.16},
          <String, Object?>{'sleeve': 'POT', 'weight': 0.04},
          <String, Object?>{'sleeve': 'B', 'weight': 0.42},
          <String, Object?>{'sleeve': 'C', 'weight': 0.38},
        ]),
      );
      strategy('P0S_A', 'ACTIVE');
      strategy('P0S_B', 'ACTIVE');
      tierB('P0S_A');
      tierB('P0S_B', b2: 1);
      decision('2026-06-30', 'ENTRY'); // 앞 달 — 안 센다
      decision('2026-07-01', 'REBALANCE');
      decision('2026-07-15', 'ENTRY');
      decision('2026-07-20', 'DEPOSIT');
      decision('2026-07-31', 'EXIT'); // 월말 세션 당일 = 센다
      decision('2026-08-03', 'EXIT'); // 다음 달 — 안 센다
      journal('2026-07-10', 1);
      journal('2026-07-11', 0);
      journal('2026-08-03', 1); // 다음 달
      regime('2026-06-30', 'BEAR');
      regime(july[0], 'BEAR');
      regime(
        july[1],
        'BEAR',
        status: 'INSUFFICIENT_DATA',
      ); // 판정 OK 아님 = 상태 값이 있어도 판정 못 한 날
      regime(july[2], 'BULL');
      regime(july[3], 'BULL');
      regime('2026-08-03', 'BEAR'); // 다음 달
      final MonthlyReport r = await src(uses: const <String>['2026-07-10'])
          .monthlyReport(
            '2026-07',
            generatedAtUtc: _t0,
            configHash: 'cfg_t',
            trust: _trust,
            disclosureViewCount: 3,
          );
      expect(r.yyyyMm, '2026-07');
      expect(r.asOf.tradeDate, const TradeDate('2026-07-31'));
      expect(r.generatedAtText, '2026-08-01 생성');
      expect(r.disclosureViewCountText, '이번 달 3번 열어 보셨습니다');
      final double up = (100 + july.length - 1) / 100 - 1;
      expect(
        item(r, 'A1_PERIOD_RETURN').valueText,
        '+${(up * 100).toStringAsFixed(2)}%',
      );
      expect(
        item(r, 'A2_CUMULATIVE_RETURN').valueText,
        '+${(up * 100).toStringAsFixed(2)}%',
      );
      expect(item(r, 'C1_MAX_DRAWDOWN').valueText, '0.0%');
      expect(item(r, 'C2_TIME_UNDER_WATER').valueText, '전고점 아래 구간 없음');
      expect(item(r, 'D1_REGIME_SWITCHES').valueText, '이번 달 1회');
      expect(item(r, 'D1_REGIME_SWITCHES').noteText, '국면을 판정할 수 없던 날 1일');
      expect(
        item(r, 'D2_ALLOCATION').valueText,
        '회계 기준 A 20.0% · B 42.0% · C 38.0%',
      );
      expect(item(r, 'D2_ALLOCATION').noteText, isNull); // 집계 설정 없음
      expect(item(r, 'D3_EXECUTION').valueText, '규칙대로 3건 · 재량 1건 · 이행률 75%');
      expect(item(r, 'D4_DISCRETION_BUDGET').valueText, '12개월 4회 중 1회 사용');
      expect(
        item(r, 'E1_STRATEGY_STATE').valueText,
        '정상 · 계층 B B2 충족 · 차단 플래그 없음',
      );
      expect(
        item(r, 'G1_SAMPLE_NOTICE').valueText,
        '관측 표본은 1개월입니다. 이 길이로는 규칙의 우열을 가릴 수 없습니다.',
      );
      expect(item(r, 'G2_OPS_RAMP').valueText, '운영 램프 L3');
      for (final String c in <String>['B1_BENCHMARK', 'F1_SCORING_2X2']) {
        expect(item(r, c).valueText, MonthlyReportTexts.notComputed);
      }
    });

    test('빈 원장 = 원천 없는 칸 null · D3 = 0건(«산출 불가» 아님)', () async {
      final MonthlyReportInputs i = await src().inputs('2026-07');
      expect(i.monthEnd, const TradeDate('2026-07-31'));
      expect(i.equity, isNull);
      expect(i.allocation, isNull);
      expect(i.exposureTally, isNull);
      expect(i.strategy, isNull);
      expect(i.regime, isNull);
      expect(i.discretionUseDates, isEmpty);
      expect(i.execution.decisionKinds, isEmpty);
      expect(i.execution.deviationJournals, 0);
      final MonthlyReport r = await src().monthlyReport(
        '2026-07',
        generatedAtUtc: _t0,
        configHash: 'cfg_t',
        trust: _trust,
        disclosureViewCount: 0,
      );
      expect(item(r, 'D3_EXECUTION').valueText, '규칙대로 0건 · 재량 0건');
      expect(
        item(r, 'A1_PERIOD_RETURN').valueText,
        MonthlyReportTexts.notComputed,
      );
      expect(r.items, hasLength(13));
    });

    test(
      '🔴 D2 값 = 월말 세션의 정기 회차 중 마지막 기록(다른 종류 · 다른 날 · 빈 비중 = 안 씀)',
      () async {
        String w(double a) => jsonEncode(<Map<String, Object?>>[
          <String, Object?>{'sleeve': 'A', 'weight': a},
          <String, Object?>{'sleeve': 'POT', 'weight': 0.0},
          <String, Object?>{'sleeve': 'B', 'weight': 0.4},
          <String, Object?>{'sleeve': 'C', 'weight': 0.6 - a},
        ]);
        event(
          'OLD',
          '2026-07-31',
          before: w(0.1),
          created: '2026-07-31T10:00:00Z',
        );
        event(
          'NEW',
          '2026-07-31',
          before: w(0.2),
          created: '2026-07-31T12:00:00Z',
        );
        event(
          'SEAS',
          '2026-07-31',
          kind: 'SEASONAL',
          before: w(0.3),
          created: '2026-07-31T13:00:00Z',
        );
        event(
          'JUN',
          '2026-06-30',
          before: w(0.05),
          created: '2026-08-01T00:00:00Z',
        );
        final List<SleeveWeight>? a = (await src().inputs('2026-07'))
            .allocation;
        expect(a, isNotNull);
        expect(a!.first.weight, closeTo(0.2, 1e-12));
        expect(
          monthlyAllocationValueOf(a),
          '회계 기준 A 20.0% · B 40.0% · C 40.0%',
        );
        db.execute('DELETE FROM rebalance_event');
        event('EMPTY', '2026-07-31');
        expect((await src().inputs('2026-07')).allocation, isNull);
      },
    );

    test('계층 B 판정 없음 = null · 국면 앞 달 = 판정 OK 인 마지막 날', () async {
      strategy('P0S_A', 'PROBATION');
      regime('2026-06-29', 'BULL');
      regime(
        '2026-06-30',
        'NEUTRAL',
        status: 'INSUFFICIENT_DATA',
      ); // 앞 달 = 판정 OK 만
      regime('2026-07-01', 'BEAR');
      final MonthlyReportInputs i = await src().inputs('2026-07');
      expect(i.strategy!.tierB, isNull);
      expect(i.strategy!.strategyStates, <String>['PROBATION']);
      expect(i.regime!.previousState, 'BULL');
      expect(i.regime!.monthStates, <String?>['BEAR']);
    });

    test('🔴 D2 메모 = 월 잡과 같은 집계 함수(설정 줄 때만)', () async {
      final List<String> july = krMonthSessionsOf(
        _kr,
        const TradeDate('2026-07-31'),
      );
      for (final String d in july.skip(1)) {
        snap(d, 1000);
      } // 첫 세션 = 평가 행 없음
      final MonthlyReportInputs i = await src(exposure: P0sWarnSetup())
          .inputs('2026-07');
      final P0sExposureTally t = i.exposureTally!;
      expect(t.month, '2026-07');
      expect(t.tradingDays, july.length);
      expect(t.unmeasured, <(String, String)>[(july.first, '평가 행 없음')]);
      final P0sExposureTally same = ledgerExposureTallyOf(
        db,
        mode: RunMode.live,
        kr: _kr,
        monthEnd: const TradeDate('2026-07-31'),
        held: const <LedgerHolding>[],
        setup: P0sWarnSetup(),
      );
      expect(monthlyExposureNoteOf(t), monthlyExposureNoteOf(same));
      expect(
        monthlyExposureNoteOf(t),
        '${july.length}거래일 중 달러 노출 50% 넘은 날 0일 · 원화 유동성 1% 밑 0일 · 계측 없음 1일',
      );
    });
  });

  group('🆕 읽을 때 짓기(R231 · 209 ⓔ-2 · ⓔ-3)', () {
    bool all(String _) => true;

    void opening(String day) => db.execute(
      'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, account_alias) '
      "VALUES (?, ?, 1000000, 'KRW', 'DEPOSIT', ?, '2026-06-30T00:00:00Z', NULL)",
      <Object?>['OPEN-$day', day, DecisionReasonCodes.openingBalance],
    );

    void recon(String id, String runAt, String action) => db.execute(
      'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
      "VALUES (?, ?, ?, '{}', ?)",
      <Object?>[id, runAt, action == 'MATCHED' ? 1 : 0, action],
    );

    void view(String ingestedAt) => db.execute(
      'INSERT INTO command_inbox (command_id, kind, ingested_at, state, state_label, reject_reason_code, '
      'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
      "VALUES (?, ?, ?, 'EXECUTED', '실행됨', NULL, NULL, NULL, NULL, NULL, 'd')",
      <Object?>['V-${seq++}', CommandKind.disclosureView.wire, ingestedAt],
    );

    void julySnaps() {
      for (final String d in krMonthSessionsOf(
        _kr,
        const TradeDate('2026-07-31'),
      )) {
        snap(d, 100);
      }
    }

    test('🔴 개시 전 = StateError · 닫히지 않은 달 = UnsupportedError(미생성 = ⓔ-4) · 달 꼴 = 엔진 가드', () async {
      await expectLater(
        src().reportOnRead('2026-07', nowUtc: _t0, configHash: 'cfg_t'),
        throwsStateError,
      ); // 개시 0
      opening('2026-07-01');
      await expectLater(
        src().reportOnRead('2026-06', nowUtc: _t0, configHash: 'cfg_t'),
        throwsStateError,
      );
      await expectLater(
        src().reportOnRead('2026-08', nowUtc: _t0, configHash: 'cfg_t'),
        throwsUnsupportedError,
      );
      await expectLater(
        src().reportOnRead(
          '2026-07',
          nowUtc: DateTime.utc(2026, 7, 31, 14, 59), // 한국 07-31 23:59 = 월말 세션 날
          configHash: 'cfg_t',
        ),
        throwsUnsupportedError,
      );
      await expectLater(
        src().reportOnRead('2026-7', nowUtc: _t0, configHash: 'cfg_t'),
        throwsArgumentError,
      );
    });

    test(
      '🔴 닫힌 달 = 원장 리포트 + 신뢰 배지(그 달 마감 시점 대사) + 열람 수(접수 한국 달) · 생성 = 지금',
      () async {
        opening('2026-07-01');
        julySnaps();
        recon(
          'rc-2026-07-31T00:05:00.000Z#1',
          '2026-07-31T00:05:00.000Z',
          'MATCHED',
        );
        recon(
          'rc-clear-2026-07-31T01:00:00.000Z#1',
          '2026-07-31T01:00:00.000Z',
          'CLEARED',
        );
        recon(
          'li-2026-07-31T02:00:00.000Z#1',
          '2026-07-31T02:00:00.000Z',
          'INTEGRITY_MISMATCH',
        );
        recon(
          'rc-2026-07-31T22:05:00.000Z#1',
          '2026-07-31T22:05:00.000Z',
          'BLOCKED',
        ); // 한국 08-01 = 다음 달
        view('2026-07-15T03:00:00.000Z');
        view('2026-07-20T03:00:00.000Z');
        view('2026-07-31T15:30:00.000Z'); // 한국 08-01
        view('2026-06-30T14:59:00.000Z'); // 한국 06-30
        final MonthlyReport r = await src().reportOnRead(
          '2026-07',
          nowUtc: _t0,
          configHash: 'cfg_t',
          hasBody: all,
        );
        expect(r.trust.grade, LedgerTrustGrade.reconciled);
        expect(r.trust.lastVerifiedOn, const TradeDate('2026-07-31'));
        expect(r.trust.consequenceLine, MonthlyTrustTexts.reconciledLine);
        expect(r.disclosureViewCountText, '이번 달 2번 열어 보셨습니다');
        expect(r.generatedAtText, '2026-08-01 생성');
        expect(r.asOf.label, '리포트 기준 2026-07-31');
        expect(r.configHash, 'cfg_t');
        expect(item(r, 'A1_PERIOD_RETURN').valueText, '0.00%');
        expect(
          item(r, 'C1_MAX_DRAWDOWN').detailDeepLink,
          AppRoutes.performanceDrawdown,
        );
        expect(
          item(r, 'D3_EXECUTION').detailDeepLink,
          'aaq://ledger/execution-gap/2026-07',
        );
        expect(
          r,
          await src().monthlyReport(
            '2026-07',
            generatedAtUtc: _t0,
            configHash: 'cfg_t',
            trust: monthlyLedgerTrustOf(
              checks: brokerReconChecksOf(db),
              monthEnd: const TradeDate('2026-07-31'),
              hasBody: all,
            ),
            disclosureViewCount: 2,
            hasBody: all,
          ),
        );
        // 링크 목적지 없음 = 「자세히」 0 · 배지 링크 0.
        final MonthlyReport bare = await src().reportOnRead(
          '2026-07',
          nowUtc: _t0,
          configHash: '',
        );
        for (final ReportItem i in bare.items) {
          expect(i.detailDeepLink, isNull, reason: i.code);
        }
      },
    );

    test('🔴 그 달 마지막 대사 BLOCKED = 어긋남 배지 · D2 표지(월말 회차 비중)', () async {
      opening('2026-07-01');
      julySnaps();
      event(
        'M-07',
        '2026-07-31',
        before: jsonEncode(<Map<String, Object?>>[
          <String, Object?>{'sleeve': 'A', 'weight': 0.16},
          <String, Object?>{'sleeve': 'POT', 'weight': 0.04},
          <String, Object?>{'sleeve': 'B', 'weight': 0.42},
          <String, Object?>{'sleeve': 'C', 'weight': 0.38},
        ]),
      );
      recon(
        'rc-2026-07-30T22:05:00.000Z#1',
        '2026-07-30T22:05:00.000Z',
        'BLOCKED',
      );
      final MonthlyReport r = await src().reportOnRead(
        '2026-07',
        nowUtc: _t0,
        configHash: 'cfg_t',
        hasBody: all,
      );
      expect(r.trust.grade, LedgerTrustGrade.drifting);
      expect(r.trust.actionDeepLink, AppRoutes.m5BlockBoard);
      expect(
        item(r, 'D2_ALLOCATION').valueText,
        '회계 기준 A 20.0%? · B 42.0%? · C 38.0%?',
      );
      expect(
        item(r, 'D2_ALLOCATION').noteText,
        MonthlyReportTexts.allocationUnsettled,
      );
    });

    test('🔴 무결성 점검 중 = 가림 꼴(원장 수치 0) · 열람 수 그대로 · 풀린 깃발 = 보통', () async {
      opening('2026-07-01');
      julySnaps();
      view('2026-07-15T03:00:00.000Z');
      db.execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', ?, '점검')",
        <Object?>['2026-07-31T23:00:00.000Z'],
      );
      final MonthlyReport m = await src().reportOnRead(
        '2026-07',
        nowUtc: _t0,
        configHash: 'cfg_t',
        hasBody: all,
      );
      for (final ReportItem i in m.items) {
        expect(i.valueText, MonthlyReportTexts.integrityHidden, reason: i.code);
        expect(i.detailDeepLink, isNull);
      }
      expect(m.goalLine, MonthlyReportTexts.integrityGoal);
      expect(m.trust.label, MonthlyTrustTexts.integrityLabel);
      expect(m.trust.actionDeepLink, AppRoutes.x5RepairWizard);
      expect(m.disclosureViewCountText, '이번 달 1번 열어 보셨습니다');
      db.execute(
        "UPDATE trading_block SET cleared_at = '2026-08-01T00:00:00.000Z' WHERE flag_id = 'LEDGER_INTEGRITY'",
      );
      final MonthlyReport n = await src().reportOnRead(
        '2026-07',
        nowUtc: _t0,
        configHash: 'cfg_t',
      );
      expect(item(n, 'A1_PERIOD_RETURN').valueText, '0.00%');
    });

    test(
      '🔴 대사 원장 = rc- 행만(해제 · 무결성 · 골든 제외) · 시각 값 순(소수 자릿수 섞여도) · 결과 밖 = 실패',
      () {
        recon(
          'rc-2026-07-31T00:05:00.123456Z#1',
          '2026-07-31T00:05:00.123456Z',
          'MATCHED',
        );
        recon(
          'rc-2026-07-31T00:05:00.123Z#1',
          '2026-07-31T00:05:00.123Z',
          'BLOCKED',
        );
        recon(
          'rc-2026-07-30T00:05:00.000Z#1',
          '2026-07-30T00:05:00.000Z',
          'UNAVAILABLE',
        );
        recon(
          'rc-clear-2026-07-31T01:00:00.000Z#1',
          '2026-07-31T01:00:00.000Z',
          'CLEARED',
        );
        recon(
          'li-2026-07-31T02:00:00.000Z#1',
          '2026-07-31T02:00:00.000Z',
          'INTEGRITY_OK',
        );
        recon(
          'gv-2026-07-31T03:00:00.000Z#1',
          '2026-07-31T03:00:00.000Z',
          'GOLDEN_PASS',
        );
        expect(brokerReconChecksOf(db), <(DateTime, ReconAction)>[
          (DateTime.utc(2026, 7, 30, 0, 5), ReconAction.unavailable),
          (DateTime.utc(2026, 7, 31, 0, 5, 0, 123), ReconAction.blocked),
          (DateTime.utc(2026, 7, 31, 0, 5, 0, 123, 456), ReconAction.matched),
        ]);
        recon(
          'rc-2026-07-31T04:00:00.000Z#1',
          '2026-07-31T04:00:00.000Z',
          'WEIRD',
        );
        expect(() => brokerReconChecksOf(db), throwsStateError);
      },
    );
  });

  group('🆕 목표 경로 원천(R238 · S7-9)', () {
    bool all(String _) => true;

    void opening(String day) => db.execute(
      'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, account_alias) '
      "VALUES (?, ?, 10000000, 'KRW', 'DEPOSIT', ?, '2026-03-31T00:00:00Z', NULL)",
      <Object?>['OPEN-$day', day, DecisionReasonCodes.openingBalance],
    );

    void contribution(String amount, String changedAt, String from) =>
        db.execute(
          'INSERT INTO operating_param_log(param_key, value_text, changed_at, effective_from, action_run_id, device_id) '
          "VALUES (?, ?, ?, ?, 'run-t', 'dev-t')",
          <Object?>[
            OperatingParamKeys.monthlyContribution,
            amount,
            changedAt,
            from,
          ],
        );

    /// 개시 04-01 · 달마다 월말 세션 스냅숏 — [jul] = 7월 말 평가액.
    void ledger({double jul = 11000000}) {
      opening('2026-04-01');
      snap('2026-04-01', 10000000);
      for (final (String m, double v) in <(String, double)>[
        ('2026-04', 10050000),
        ('2026-05', 10200000),
        ('2026-06', 10400000),
        ('2026-07', jul),
      ]) {
        snap(krMonthEndOf(_kr, m).yyyyMmDd, v);
      }
    }

    GoalPathVm read(String m, {DateTime? now}) =>
        ledgerGoalPathOnRead(db, kr: _kr, yyyyMm: m, nowUtc: now ?? _t0);

    test('🔴 개시 전 = StateError · 닫히지 않은 달 = UnsupportedError · 무결성 점검 중 = StateError · 달 꼴 = 실패', () {
      expect(() => read('2026-07'), throwsStateError); // 개시 0
      ledger();
      expect(() => read('2026-03'), throwsStateError);
      expect(() => read('2026-08'), throwsUnsupportedError);
      expect(() => read('2026-7'), throwsArgumentError);
      db.execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', ?, '점검')",
        <Object?>['2026-07-31T23:00:00.000Z'],
      );
      expect(() => read('2026-07'), throwsStateError);
      db.execute(
        "UPDATE trading_block SET cleared_at = '2026-08-01T00:00:00.000Z' WHERE flag_id = 'LEDGER_INTEGRITY'",
      );
      expect(read('2026-07').yyyyMm, '2026-07');
    });

    test(
      '🔴 원장 → 엔진 — 같은 시리즈(tierBSeries) · 월 납입 기록 · KR 달력 = goalPathOf 그대로',
      () {
        ledger();
        contribution('200000', '2026-05-20T01:00:00.000Z', '2026-06-01');
        final GoalPathVm v = read('2026-07');
        final TradeDate end = krMonthEndOf(_kr, '2026-07');
        final GoalPathVm want = goalPathOf(
          yyyyMm: '2026-07',
          monthEnd: end,
          equity: tierBSeries(db, end.yyyyMmDd),
          isSession: (String d) => _kr.isSession(TradeDate(d)),
          contributionRows: contributionRowsOf(db),
          contributionConfig: p0sContributionConfig(),
          nowUtc: _t0,
        ).vm;
        expect(v, want);
        expect(v.actual.first.date, const TradeDate('2026-04-01'));
        expect(v.actual.last.date, end);
        expect(v.actual.last.value, 11000000);
        expect(v.planned.first.value, 10000000);
        // 기록 = 6월부터 20만원(5월 = 기본 10만원) — 기록 없는 판보다 크다.
        db.execute('DELETE FROM operating_param_log');
        expect(
          read('2026-07').planned.last.value,
          lessThan(v.planned.last.value!),
        );
      },
    );

    test(
      '🔴 월간 리포트 목표 줄 · 「목표 경로 보기」 = 같은 판정(앞섬 · 이탈 · 유보) · 대사 어긋남 = 버튼 부재',
      () async {
        ledger();
        MonthlyReport m = await src().reportOnRead(
          '2026-07',
          nowUtc: _t0,
          configHash: 'cfg_t',
          hasBody: all,
        );
        expect(m.goalLine, GoalPathTexts.reportAhead);
        expect(m.goalDeepLink, 'aaq://report/goal/2026-07');
        m = await src().reportOnRead(
          '2026-07',
          nowUtc: _t0,
          configHash: 'cfg_t',
        );
        expect(m.goalDeepLink, isNull); // 본문 없음
        m = await src().reportOnRead(
          '2026-05',
          nowUtc: _t0,
          configHash: 'cfg_t',
          hasBody: all,
        );
        expect(m.goalLine, MonthlyReportTexts.goalWithheld); // 개시 달부터 1개월
        expect(m.goalDeepLink, 'aaq://report/goal/2026-05');
        db.execute(
          'DELETE FROM equity_snapshot WHERE trade_date = ?',
          <Object?>[krMonthEndOf(_kr, '2026-07').yyyyMmDd],
        );
        snap(krMonthEndOf(_kr, '2026-07').yyyyMmDd, 8000000);
        m = await src().reportOnRead(
          '2026-07',
          nowUtc: _t0,
          configHash: 'cfg_t',
          hasBody: all,
        );
        expect(m.goalLine, GoalPathTexts.offTrack);
        expect(read('2026-07').deviationText, GoalPathTexts.deviation);
        final MonthlyReport d = await src().monthlyReport(
          '2026-07',
          generatedAtUtc: _t0,
          configHash: 'cfg_t',
          trust: const LedgerTrustBadge(
            grade: LedgerTrustGrade.drifting,
            level: UiLevel.watch,
            label: '어긋남 확인 중',
            consequenceLine: '어긋남',
          ),
          disclosureViewCount: 0,
          hasBody: all,
        );
        expect(d.goalLine, GoalPathTexts.offTrack);
        expect(d.goalDeepLink, isNull);
      },
    );
  });
}
