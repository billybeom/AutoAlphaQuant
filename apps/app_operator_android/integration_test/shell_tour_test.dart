// E11p3d-5f 에뮬레이터 종합 확인(설계 13 §8 R140) — 실제 앱 셸에서 홈(H-01) → 더보기 = 설정 홈(S01) → 연결(S07) → H-03.
// 🆕 E11p3d-5h(R146) — + 기기 · 접근(S06 · 실제 기기 id · 설정 홈 «기기·접근» 카드로 들어간다).
// 🆕 E11p3d-5i(R151) — + 계좌 · 매핑(S03 · 설정 홈 «계좌·매핑» 카드 · 운영 설정 전 = 슬리브 미지정).
// 🆕 E11q1(R171) — + M6 H6-1 보유 현황(보유 0 = 빈 문장 → 연습 보유를 원장에 넣으면 같은 화면에 카드가 선다).
// 🆕 E11q1b(R172) — + H6-3 슬리브 배분 · H6-2 종목 상세(같은 연습 보유).
// 🆕 E11q-q4a — + M6 일지 읽기 J-1 · J-2 · J-3R · S7-6b «이 회차의 주문 n건» → J-1 회차 조건(연습 일지 묶음).
// 🆕 E11q-q4b — + J-5 미해소 보드(연습 UNKNOWN 의도 1 → 카드 → «찾지 못함» 거부로 풀면 같은 화면이 빈 문장).
// 🆕 E11q-q5e(R231) — + M7 S7-1 월간 리포트(지난달 · 배지 «대사 완료» · 「자세히」 → S7-3).
// 🆕 E11q-d1 — + M8 문서(D-02 런북 목록 → 상세 · D-03 긴급 카드 · B-01 핸드북 목차 → B-02 슬리브 B 쪽 · 맨 끝).
//
// 🔴 로컬 실측용(CI 밖 — 기기가 있어야 돈다) · 키 · 계좌 0(금고를 읽기만 · 쓰지 않는다) · 바깥 망 0(healthchecks 읽기 키 없음 = 망에 가지 않는다).
// 실행: `flutter test integration_test/shell_tour_test.dart -d emulator-5554` · 표지 `IT_*` 마다 4초 멈춘다(캡처 자리).

import 'dart:io';

import 'package:app_operator_android/app/operator_golden.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operations_loader.dart'
    show loadOperationsConfig;
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/platform/human_inputs_loader.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart'
    show
        P0sHumanInputs,
        P0sOpsConfig,
        MonthlyTrustTexts,
        P0sStrategyIds,
        contributionDefaultRange,
        kstDateText;
import 'package:data_sync/data_sync.dart'
    show
        HealthchecksClient,
        ModeAxis,
        SqliteConfigVersionStore,
        SqliteModeStore,
        krMonthEndOf,
        krMonthSessionsOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        DecisionReasonCodes,
        ExecPolicy,
        LedgerFile,
        OperatingMode,
        RunMode,
        TradeDate;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:ui_analytics/planner.dart' show DepositPlannerScreen;
import 'package:ui_analytics/ui_analytics.dart'
    show
        AnnualReviewScreen,
        ContributionScreen,
        DrawdownContextScreen,
        ExecutionGapScreen,
        MonthlyReportScreen,
        PerformanceExploreScreen,
        RebalanceEventScreen,
        RebalancePreviewScreen,
        RebalanceTimelineScreen;
import 'package:ui_journal/ui_journal.dart'
    show
        HoldingDetail,
        HoldingsAllocation,
        HoldingsOverview,
        JournalDecisionDetail,
        JournalReadView,
        JournalTimeline,
        JournalUnknownBoard;
import 'package:ui_safety/ui_safety.dart'
    show
        BlockBoardScreen,
        KillResumeGateScreen,
        KillSwitchScreen,
        ResumeGateScreen,
        HandoverWizardScreen,
        ResumeReportScreen,
        RepairWizardScreen,
        RuleChangeGateScreen,
        X1PlanWizardScreen,
        X1RecoveryScreen;
import 'package:ui_settings/ui_settings.dart'
    show
        AnnualReviewEntry,
        Accounts,
        Connections,
        Devices,
        Diagnostics,
        MonthlyContribution,
        SettingsHome;
import 'package:ui_shell/ui_shell.dart'
    show
        DeviceRiskBoard,
        EmergencyStopCard,
        HandbookContents,
        HandbookPageView,
        OpsHome,
        RunbookDetail,
        RunbookList,
        ShellRoot,
        shellLinkOpenerProvider;

void _mark(String m) {
  // ignore: avoid_print
  print(m);
}

/// 화면 하나에 멈춘다 — 보이는 글자를 찍고(`IT_TEXT`) · 표지를 찍고 · 바깥 캡처가 따라오게 기다린다.
Future<void> _at(WidgetTester tester, Finder screen, String marker) async {
  for (final Element e
      in find.descendant(of: screen, matching: find.byType(Text)).evaluate()) {
    final String? t = (e.widget as Text).data;
    if (t != null) _mark('IT_TEXT $marker $t');
  }
  _mark(marker);
  final DateTime end = DateTime.now().add(const Duration(seconds: 4));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

Future<void> _until(WidgetTester tester, Finder f) async {
  final DateTime end = DateTime.now().add(const Duration(seconds: 20));
  while (f.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('기다린 위젯이 안 나타났다: $f');
    }
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  await tester.pump();
}

/// 🆕 R220 — 위젯이 사라질 때까지(뒤로 간 화면의 전환이 끝날 때까지 — 앞 화면은 아래에 늘 남아 있다).
Future<void> _gone(WidgetTester tester, Finder f) async {
  final DateTime end = DateTime.now().add(const Duration(seconds: 20));
  while (f.evaluate().isNotEmpty) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('사라지길 기다린 위젯이 남았다: $f');
    }
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  await tester.pump();
}

/// 🆕 R173 — 연습 리밸런싱 회차 1행(월말 잡이 쓰는 꼴 · 모의 원장 · 비중 = 합성 둥근 값).
void _seedPracticeRebalance(Database db) => db.execute(
  'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
  "weights_before, weights_after, config_hash, created_at) VALUES ('REB-MONTHLY-IT', '2026-10-30', ?, "
  "'MONTHLY_REGULAR', 'MONTH-END-IT', '{\"targets\":2,\"sleeve_b_held\":false}', ?, ?, 'cfg_it', "
  "'2026-11-02T00:00:00Z')",
  <Object?>[
    RunMode.simInternal.wire,
    '[{"sleeve":"A","weight":0.19},{"sleeve":"B","weight":0.47},'
        '{"sleeve":"C","weight":0.30},{"sleeve":"POT","weight":0.04}]',
    '[{"sleeve":"A","weight":0.19},{"sleeve":"B","weight":0.42},'
        '{"sleeve":"C","weight":0.35},{"sleeve":"POT","weight":0.04}]',
  ],
);

/// 🆕 E11q-q4a — 연습 일지 묶음(연습 회차 `REB-MONTHLY-IT` 의 계획 대상 1 · 그 논리 id 의 의도 1 · 가상 체결 1 ·
/// 회차 판정 결정 1 — 모의 원장 · 합성 값 · 실키 0 · 바깥 망 0).
void _seedPracticeJournal(Database db, OperatorRuntime rt) {
  final String now = rt.clock.nowUtc().toIso8601String();
  final String day = kstDateText(rt.clock.nowUtc());
  final String account =
      rt.humanDecision!.inputs.accountByStrategy[P0sStrategyIds.sleeveB]!;
  db.execute(
    'INSERT INTO plan_snapshot (plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, '
    "config_hash) VALUES ('REBAL-2026-10-30', 'REBALANCE', ?, '2026-10-30', '2026-11-03', '{}', ?, 'cfg_it')",
    <Object?>[
      now,
      // 월말 잡이 쓰는 꼴(회차 번호 · 집행일 — 납입 플래너가 «지난 계획의 회차 번호»를 읽는다) · 만료 = 지난 날
      // (주문 대상 원천이 이 연습 계획으로 주문을 내지 않게).
      '{"targets":[{"logical_decision_id":"B-SMA-2026-10-30"}],'
          '"execution_day":"2026-11-02","month_index":1}',
    ],
  );
  db.execute(
    'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
    "reason_code, config_hash) VALUES ('MONTH-END-IT', ?, '2026-10-30', ?, 'REBALANCE', ?, "
    "'월말 정기 리밸런싱 — 대상 2건(연습)', 'MONTHLY_REGULAR', 'cfg_it')",
    <Object?>[now, RunMode.simInternal.wire, P0sStrategyIds.deposit],
  );
  db.execute(
    'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
    'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
    "updated_at, mode) VALUES ('IT-RB', 'IT-K-RB', ?, ?, 'KR', ?, ?, ?, '133690', 'BUY', 'LIMIT', 3, "
    "120000, 'FILLED', 'cfg_it', ?, ?)",
    <Object?>[
      now,
      day,
      account,
      P0sStrategyIds.sleeveB,
      'B-SMA-2026-10-30@$day',
      now,
      RunMode.simInternal.wire,
    ],
  );
  db.execute(
    'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status, filled_qty, remaining_qty) '
    "VALUES (?, 'IT-RB', ?, 'FILLED', 3, 0)",
    <Object?>['$day:IT0001', now],
  );
  db.execute(
    'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, commission, tax, '
    "authored_at, fill_origin, cost_source) VALUES (?, ?, ?, 3, 120000, 54, 0, ?, 'SIMULATED', 'ESTIMATED')",
    <Object?>['$day:IT0001#3', '$day:IT0001', now, now],
  );
}

/// 🆕 R171 — 연습 보유(모의 원장 · 실키 0 · 계좌 번호 0 · 바깥 망 0): 개시 판(설정 해시) + 가상 초기금 + 보유 4 + 그날 봉.
///
/// 온보딩이 이미 확정된 원장이라 `declareSimOpening` 대신 같은 두 행(개시 결정 · 입금)을 직접 쓴다.
void _seedPracticeHoldings(Database db, OperatorRuntime rt) {
  final P0sHumanInputs inputs = rt.humanDecision!.inputs;
  final String hash = SqliteConfigVersionStore(
    db,
    clock: rt.clock,
  ).register(P0sOpsConfig.of(inputs).content());
  final String now = rt.clock.nowUtc().toIso8601String();
  final String day = kstDateText(rt.clock.nowUtc());
  db.execute(
    'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, '
    'reason, reason_code, config_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      'D-IT-OPEN',
      now,
      day,
      RunMode.simInternal.wire,
      'MANUAL',
      P0sStrategyIds.deposit,
      '연습 개시(에뮬레이터 둘러보기)',
      DecisionReasonCodes.simOpeningBalance,
      hash,
    ],
  );
  db.execute(
    'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, account_alias) '
    "VALUES ('IT-CASH', ?, 2000000, 'KRW', 'DEPOSIT', 'IT', ?, ?)",
    <Object?>[day, now, inputs.accountByStrategy[P0sStrategyIds.sleeveC]],
  );
  for (final (String strategy, String symbol, int qty, int px)
      in <(String, String, int, int)>[
        (P0sStrategyIds.sleeveA, inputs.aSymbol, 100, 10000),
        (P0sStrategyIds.sleeveB, '133690', 30, 120000),
        (P0sStrategyIds.sleeveB, '214980', 10, 100000),
        (P0sStrategyIds.sleeveC, '0085P0', 50, 10000),
      ]) {
    db.execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
      'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
      "updated_at, mode) VALUES (?, ?, ?, ?, 'KR', ?, ?, ?, ?, 'BUY', 'LIMIT', ?, ?, 'FILLED', ?, ?, ?)",
      <Object?>[
        'IT-$symbol',
        'IT-K-$symbol',
        now,
        day,
        inputs.accountByStrategy[strategy],
        strategy,
        'D-IT-$symbol',
        symbol,
        qty,
        px,
        hash,
        now,
        RunMode.simInternal.wire,
      ],
    );
    db.execute(
      'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at, '
      "entry_decision_id) VALUES ('KR', ?, ?, ?, ?, ?, ?, ?)",
      <Object?>[symbol, strategy, qty, px, day, now, 'D-IT-$symbol'],
    );
    db.execute(
      'INSERT OR REPLACE INTO daily_prices (trade_date, market, symbol, open, high, low, close, '
      "close_unadj, volume) VALUES (?, 'KR', ?, ?, ?, ?, ?, ?, 0)",
      <Object?>[day, symbol, px, px, px, px, px],
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('🔴 셸 종합 — 홈 → 더보기(설정 홈) → 연결 → 기기 리스크', (
    WidgetTester tester,
  ) async {
    const SystemClock clock = SystemClock();
    final AndroidOps ops = AndroidOps();
    final Directory dir = Directory.systemTemp.createTempSync('aaq_it_tour_');
    final LedgerFiles files = LedgerFiles.open(dir.path, clock: clock);
    final OperatorRuntime rt = OperatorRuntime(
      files: files,
      clock: clock,
      secure: SecureScreen(ops.setSecure),
      vault: AndroidSecretVault(),
      watchdogRemote: HealthchecksClient(http.Client(), AndroidSecretVault()),
      deviceProbe: () => ops.deviceRisk(clock.nowUtc()),
      deviceId: await ops.deviceId(),
      // 🆕 R154 — 실린 사람 값 자산(발주자 결정 R153) → S03 = 정한 대응표 «모의 개시 전».
      humanDecision: await loadP0sHumanDecision(rootBundle),
      // 🆕 R167 — 설정 동작(S10 실행 버튼) · 골든 기기 실행기(실제 엔진 패키지 자산 · 실제 isolate).
      kisHttp: http.Client(),
      golden: OperatorGolden(rootBundle.loadString, clock: clock),
      // 🆕 E11q-q4a — M5-11 위저드 관찰 일수(앱 기동과 같은 운영 설정 자산 · R191 단계가 이것 없이 «읽지 못했습니다»로 멈췄다).
      liveObservation: (await loadOperationsConfig(rootBundle)).liveObservation,
    );
    // 온보딩 확정 + 모의 모드 행을 먼저 둔다 → 루트 = 셸.
    files.sim.execute(
      'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
      <Object?>[
        OperatingMode.autoTrade.wire,
        clock.nowUtc().toIso8601String(),
        clock.nowUtc().toIso8601String(),
      ],
    );
    expect(
      SqliteModeStore(files.sim, LedgerFile.sim, clock: clock).record(
        axis: ModeAxis.runMode,
        runMode: RunMode.simInternal,
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        handoverSessionValid: false,
        decisionId: 'D-IT-TOUR',
      ),
      isNull,
    );
    rt.view.value = operatorViewOf(
      await bootEngine(files, clock: clock),
      files,
    );
    final ProviderContainer container = ProviderContainer(
      overrides: operatorShellOverrides(rt),
    );
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AutoAlphaQuantOperatorApp(shell: true),
        ),
      );
      await _until(tester, find.byType(ShellRoot));
      await _until(tester, find.text('오늘 주문 0건'));
      await _at(tester, find.byType(OpsHome), 'IT_HOME');

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('s01-tabs')),
          matching: find.text('더보기'),
        ),
      );
      await _until(tester, find.text('모의 · 내부 가상 체결 · 자동 매매'));
      final Finder home = find.byType(SettingsHome);
      expect(
        find.descendant(of: home, matching: find.text('연결')),
        findsOneWidget,
      );
      await _at(tester, home, 'IT_S01');

      await tester.tap(find.descendant(of: home, matching: find.text('연결')));
      await _until(tester, find.text('증권사 연결(모의투자)'));
      final Finder conn = find.byType(Connections);
      expect(
        find.descendant(of: conn, matching: find.text('생존 신호(healthchecks)')),
        findsOneWidget,
      );
      await _at(tester, conn, 'IT_S07');

      // S06 — 설정 홈 «기기·접근» 카드(본문 등록 → 카드 · 탭이 저절로 선다).
      await tester.pageBack();
      await _until(tester, find.text('기기·접근'));
      await tester.tap(find.descendant(of: home, matching: find.text('기기·접근')));
      await _until(tester, find.text('연결된 조회 전용 기기가 없습니다.'));
      await _at(tester, find.byType(Devices), 'IT_S06');

      // S03 — 설정 홈 «계좌·매핑» 카드.
      await tester.pageBack();
      await _until(tester, find.text('계좌·매핑'));
      await tester.tap(find.descendant(of: home, matching: find.text('계좌·매핑')));
      await _until(tester, find.text('슬리브 A'));
      expect(find.text('모의 개시 전 — 시작하면 이 계좌로 운영합니다.'), findsNWidgets(3));
      await _at(tester, find.byType(Accounts), 'IT_S03');

      // 🆕 R160 — S10 진단(설정 홈 «진단» 카드) · 🆕 R167 골든 = 실제 자산으로 전량 실행 → «통과 · 전량 통과».
      await tester.pageBack();
      await _until(tester, find.text('진단'));
      await tester.ensureVisible(
        find.descendant(of: home, matching: find.text('진단')),
      );
      await tester.tap(find.descendant(of: home, matching: find.text('진단')));
      await _until(tester, find.text('아직 실행하지 않았습니다'));
      await tester.tap(find.byKey(const Key('m9s10-golden-run')));
      await _until(tester, find.text('전량 통과'));
      expect(find.text('통과'), findsWidgets);
      expect(find.textContaining('마지막 실행 '), findsWidgets);
      await _at(tester, find.byType(Diagnostics), 'IT_S10');

      // 🆕 R168 — S12 12월 연간 리뷰 목차(신뢰 시각 전 = «확인하지 못했습니다» · 목차 = 등록된 M7 화면만 — 🆕 R173 회차 목록 · 🆕 R220 S7-7 · S7-10).
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.settingsAnnualReview);
      await _until(tester, find.textContaining('연간 점검 창을 확인하지 못했습니다'));
      expect(find.textContaining('년 연간 리뷰'), findsWidgets);
      await _at(tester, find.byType(AnnualReviewEntry), 'IT_S12');
      // 🆕 R220 — 목차 행 → M7 S7-7 연간 리뷰(같은 해 · 같은 «모름» 글자 · 세후 참고치) · S7-10 이행 갭(자동 매매 = 해당 없음).
      await tester.tap(
        find.descendant(
          of: find.byType(AnnualReviewEntry),
          matching: find.text('한 해의 결과 — 연간 리뷰'),
        ),
      );
      await _until(tester, find.byType(AnnualReviewScreen));
      await _until(
        tester,
        find.descendant(
          of: find.byType(AnnualReviewScreen),
          matching: find.textContaining('연간 점검 창을 확인하지 못했습니다'),
        ),
      );
      await _at(tester, find.byType(AnnualReviewScreen), 'IT_S77');
      await tester.pageBack();
      await _gone(tester, find.byType(AnnualReviewScreen));
      await tester.tap(
        find.descendant(
          of: find.byType(AnnualReviewEntry),
          matching: find.text('이행 갭'),
        ),
      );
      await _until(
        tester,
        find.text('자동 매매 구간이라 안내 이행 리포트가 없습니다. 지난 안내 구간의 리포트는 그대로 남습니다.'),
      );
      await _at(tester, find.byType(ExecutionGapScreen), 'IT_S710');
      await tester.pageBack();
      await _gone(tester, find.byType(ExecutionGapScreen));
      await tester.pageBack();
      await _gone(tester, find.byType(AnnualReviewEntry));

      // 🆕 R223 — S7-2 성과 탐색: 게이트(이번 달 열람 수 · 마찰) → 「그래도 보기」 = 원장 열람 기록 1행 → 같은 위젯 안 본문
      //    (기록 줄 = 엔진 접수증 글자 · 시리즈 또는 엔진 문장 카드).
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.performanceExplore);
      await _until(tester, find.byKey(const Key('s72g-continue')));
      await _at(tester, find.byType(PerformanceExploreScreen), 'IT_S72G');
      await tester.ensureVisible(find.byKey(const Key('s72g-continue')));
      await tester.tap(find.byKey(const Key('s72g-continue')));
      await _until(tester, find.byKey(const Key('s72-record-line')));
      await _until(tester, find.byKey(const Key('s72-asof')));
      expect(
        files.sim
            .select(
              "SELECT COUNT(*) AS n FROM command_inbox WHERE kind = 'DISCLOSURE_VIEW'",
            )
            .first['n'],
        1,
      );
      await _at(tester, find.byType(PerformanceExploreScreen), 'IT_S72');
      await tester.pageBack();
      await _gone(tester, find.byType(PerformanceExploreScreen));

      // 🆕 R171 — M6 H6-1 보유 현황 · 보유 0 = 엔진 빈 문장 → 연습 보유를 넣으면(원장 변경) 같은 화면에 카드 A · B · C.
      container.read(shellLinkOpenerProvider).open(AppRoutes.holdingsOverview);
      await _until(tester, find.textContaining('보유 종목이 없습니다'));
      await _at(tester, find.byType(HoldingsOverview), 'IT_H61');
      _seedPracticeHoldings(files.sim, rt);
      await _until(tester, find.text('B · 해외 지수·금 ETF'));
      expect(find.textContaining('잔고 기준 '), findsWidgets);
      await _at(tester, find.byType(HoldingsOverview), 'IT_H61B');
      await tester.pageBack();

      // 🆕 R172 — H6-3 배분(다섯 행 · 하단 다음 리밸런싱) · H6-2 상세(같은 보유 행 · 매수 결정 링크 · 손절선 없음).
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.holdingsAllocation);
      await _until(tester, find.text('원화 현금 대기'));
      await _at(tester, find.byType(HoldingsAllocation), 'IT_H63');
      await tester.pageBack();
      container
          .read(shellLinkOpenerProvider)
          .open('aaq://holdings/detail/h_${P0sStrategyIds.sleeveB}_133690');
      await _until(tester, find.text('매수 결정 보기'));
      await _at(tester, find.byType(HoldingDetail), 'IT_H62');
      await tester.pageBack();

      // 🆕 R173 — M7 S7-6a 회차 목록(0 = 엔진 빈 문장 → 연습 회차 1행을 넣으면 같은 화면에 행) · S7-6b 상세 ·
      //    S7-6c 다음 리밸런싱 + 지금 기준 초안(원장 상태 → 엔진 · 버튼 = 예정이 있을 때만).
      container.read(shellLinkOpenerProvider).open(AppRoutes.rebalanceHistory);
      await _until(tester, find.text('아직 리밸런싱 회차가 없습니다'));
      _seedPracticeRebalance(files.sim);
      await _until(tester, find.text('월간 정기'));
      await _at(tester, find.byType(RebalanceTimelineScreen), 'IT_R76A');
      await tester.pageBack();
      container
          .read(shellLinkOpenerProvider)
          .open('aaq://rebalance/event/REB-MONTHLY-IT');
      await _until(tester, find.byKey(const Key('s76b-before')));
      await _at(tester, find.byType(RebalanceEventScreen), 'IT_R76B');
      await tester.pageBack();
      container.read(shellLinkOpenerProvider).open(AppRoutes.rebalancePreview);
      await _until(tester, find.byKey(const Key('s76c-asof')));
      final Finder draftButton = find.byKey(const Key('s76c-preview-button'));
      if (draftButton.evaluate().isNotEmpty) {
        await tester.tap(draftButton);
        await _until(
          tester,
          find.byWidgetPredicate(
            (Widget w) =>
                w.key == const Key('s76c-draft') ||
                w.key == const Key('s76c-blocked') ||
                w.key == const Key('s76c-notice'),
          ),
        );
      }
      await _at(tester, find.byType(RebalancePreviewScreen), 'IT_R76C');
      await tester.pageBack();

      // 🆕 E11q-q4a — M6 일지 읽기: J-1(연습 보유 의도 + 연습 회차 의도 1 · 모의 배지) → J-2(체인 6단계) → J-3R(미작성) →
      //    S7-6b «이 회차의 주문 1건» → J-1 회차 조건(칩 = 회차 글자 · 씨앗 기간).
      _seedPracticeJournal(files.sim, rt);
      container.read(shellLinkOpenerProvider).open(AppRoutes.journalTimeline);
      await _until(tester, find.textContaining('133690'));
      await _at(tester, find.byType(JournalTimeline).last, 'IT_J1');
      await tester.pageBack();
      container
          .read(shellLinkOpenerProvider)
          .open(
            'aaq://journal/decision/B-SMA-2026-10-30@${kstDateText(rt.clock.nowUtc())}',
          );
      await _until(tester, find.text('브로커 주문'));
      expect(find.text('3주 전량 체결'), findsWidgets);
      await _at(tester, find.byType(JournalDecisionDetail), 'IT_J2');
      await tester.pageBack();
      container
          .read(shellLinkOpenerProvider)
          .open(
            'aaq://journal/read/B-SMA-2026-10-30@${kstDateText(rt.clock.nowUtc())}',
          );
      await _until(tester, find.text('저널 미작성'));
      await _at(tester, find.byType(JournalReadView), 'IT_J3R');
      await tester.pageBack();
      container
          .read(shellLinkOpenerProvider)
          .open('aaq://rebalance/event/REB-MONTHLY-IT');
      await _until(tester, find.text('이 회차의 주문 1건'));
      await _at(tester, find.byType(RebalanceEventScreen), 'IT_R76B_J');
      await tester.ensureVisible(find.text('이 회차의 주문 1건'));
      await tester.tap(find.text('이 회차의 주문 1건'));
      await _until(tester, find.textContaining('2026-10-30 월간 정기 회차'));
      await _at(tester, find.byType(JournalTimeline).last, 'IT_J1R');
      await tester.pageBack();
      await tester.pageBack();

      // 🆕 E11q-q4b — J-5 미해소 보드: 연습 UNKNOWN 의도 1(합성 · 모의 원장) → 카드 · 4단계 → 해소(«찾지 못함» 거부 —
      //    해소 잡이 쓰는 꼴) → 같은 화면이 빈 문장. 뒤 단계에 UNKNOWN 을 남기지 않는다.
      files.sim.execute(
        'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
        'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
        "updated_at, mode) VALUES ('IT-UK', 'IT-K-UK', ?, ?, 'KR', ?, ?, ?, '0085P0', 'BUY', 'LIMIT', 5, "
        "10000, 'UNKNOWN', 'cfg_it', ?, ?)",
        <Object?>[
          rt.clock.nowUtc().toIso8601String(),
          kstDateText(rt.clock.nowUtc()),
          rt.humanDecision!.inputs.accountByStrategy[P0sStrategyIds.sleeveC],
          P0sStrategyIds.sleeveC,
          'C-REBAL-IT@${kstDateText(rt.clock.nowUtc())}',
          rt.clock.nowUtc().toIso8601String(),
          RunMode.simInternal.wire,
        ],
      );
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.journalUnknownBoard);
      await _until(tester, find.text('이 종목의 신규 주문이 막혀 있습니다'));
      await _at(tester, find.byType(JournalUnknownBoard), 'IT_J5');
      files.sim.execute(
        "UPDATE order_intents SET status = 'REJECTED', error_message = 'UNKNOWN_NOT_FOUND: 연습' "
        "WHERE intent_id = 'IT-UK'",
      );
      await _until(tester, find.text('미해소 건이 없습니다'));
      await _at(tester, find.byType(JournalUnknownBoard), 'IT_J5E');
      await tester.pageBack();

      // 🆕 R174 — S7-4 납입 플래너(금액 → 엔진 미리보기) · S13 월 납입(바꾸기 = 신뢰 시각 모름 → 엔진 거부 문장 · 쓰기 0).
      container.read(shellLinkOpenerProvider).open(AppRoutes.planDeposit);
      await _until(tester, find.byKey(const Key('s74-amount-field')));
      await tester.enterText(
        find.byKey(const Key('s74-amount-field')),
        '300000',
      );
      await tester.ensureVisible(find.byKey(const Key('s74-calculate')));
      await tester.tap(find.byKey(const Key('s74-calculate')));
      await _until(
        tester,
        find.byWidgetPredicate(
          (Widget w) =>
              w.key == const Key('s74-list-allocation') ||
              w.key == const Key('s74-blocked-card') ||
              w.key == const Key('s74-input-rejected'),
        ),
      );
      await _at(tester, find.byType(DepositPlannerScreen), 'IT_S74');
      await tester.pageBack();
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.settingsContribution);
      await _until(tester, find.byKey(const Key('m9s13-setting')));
      if (find.byKey(const Key('m9s13-change')).evaluate().isNotEmpty) {
        await tester.enterText(find.byKey(const Key('m9s13-input')), '200000');
        await tester.ensureVisible(find.byKey(const Key('m9s13-change')));
        await tester.tap(find.byKey(const Key('m9s13-change')));
        await _until(tester, find.byKey(const Key('m9s13-result')));
      }
      await _at(tester, find.byType(MonthlyContribution), 'IT_S13');
      await tester.pageBack();

      // 🆕 R178 — M5-1 킬스위치: 꺼짐(버튼 · 경로 3) → 버튼 한 번 = 발동(확인 대화 0 · 모의 원장) → 취소 보고 · 기록 폼 →
      //    기록 제출 = 신뢰 시각 모름 → 엔진 거부 접수증(48h 는 아직 세지 않는다 · E11k 전).
      // 🆕 R182 — 셸 킬스위치 자리(홈 앱바 끝): 꺼짐 = 발동 버튼(화면과 같은 위젯 · 다른 Key · 한 줄 말줄임).
      //    (다시 돌린 원장이 이미 켜짐이면 칩 — 아래 M5-1 단계와 같은 방어.)
      await _until(
        tester,
        find.byWidgetPredicate(
          (Widget w) =>
              w.key == const Key('ks-slot-activate') ||
              w.key == const Key('ks-slot-active'),
        ),
      );
      await _at(tester, find.byKey(const Key('s01-kill-slot')), 'IT_KS0');

      container.read(shellLinkOpenerProvider).open(AppRoutes.m5KillSwitch);
      await _until(tester, find.text('킬스위치 꺼짐'));
      await _at(tester, find.byType(KillSwitchScreen), 'IT_M51A');
      if (find.byKey(const Key('m51-activate')).evaluate().isNotEmpty) {
        await tester.tap(find.byKey(const Key('m51-activate')));
        await _until(tester, find.byKey(const Key('m51-form')));
        expect(find.byType(AlertDialog), findsNothing);
        await _at(tester, find.byType(KillSwitchScreen), 'IT_M51B');
        // 탭 먼저(선택 칩 · 확인 칸) — 글자 입력 뒤에는 화상 키보드가 화면을 가려 탭이 빗나간다.
        Future<void> tapKey(String k) async {
          await tester.ensureVisible(find.byKey(Key(k)));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.tap(find.byKey(Key(k)));
          await tester.pump(const Duration(milliseconds: 300));
        }

        await tapKey('m51-choice-2-규칙');
        await tapKey('m51-choice-5-신규 진입 차단만');
        for (final String k in <String>[
          'm51-ack-queried',
          'm51-ack-cancelled',
          'm51-ack-zero',
        ]) {
          await tapKey(k);
        }
        for (final (String k, String v) in <(String, String)>[
          ('m51-rule-action', '규칙대로 신규 진입을 멈춘다'),
          ('m51-scenario', 'W3'),
          ('m51-resume-condition', '체결 오류 0'),
          ('m51-note', '연습'),
        ]) {
          await tester.ensureVisible(find.byKey(Key(k)));
          await tester.enterText(find.byKey(Key(k)), v);
          await tester.pump(const Duration(milliseconds: 200));
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump(const Duration(milliseconds: 800));
        // 🔧 R195 — 버튼이 화면 맨 아래(하단 탭 아래)에 걸리면 탭이 빗나간다 → 가운데로 올린 뒤 누른다.
        await Scrollable.ensureVisible(
          tester.element(find.byKey(const Key('m51-record-submit'))),
          alignment: 0.5,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.byKey(const Key('m51-record-submit')));
        await _until(tester, find.byKey(const Key('m51-record-receipt')));
        await _at(tester, find.byType(KillSwitchScreen), 'IT_M51C');
      }
      await tester.pageBack();

      // 🆕 R182 — 발동 뒤 홈 앱바 자리 = 상태 칩(원장 변경 → 다시 냄 · 누르면 M5-1).
      await _until(tester, find.byKey(const Key('ks-slot-active')));
      expect(find.byKey(const Key('ks-slot-activate')), findsNothing);
      await _at(tester, find.byKey(const Key('s01-kill-slot')), 'IT_KS1');

      // 🆕 R180 — M5-2 재개 게이트: 켜짐 · 기록 전(신뢰 시각이 없어 기록이 거부됐다) = 막힘 문장 · 받을 문항 0 · 7문항 표.
      container.read(shellLinkOpenerProvider).open(AppRoutes.m5ReleaseGate);
      await _until(tester, find.byKey(const Key('m52-root')));
      expect(find.byKey(const Key('m52-confirm')), findsNothing);
      await _at(tester, find.byType(KillResumeGateScreen), 'IT_M52');
      await tester.pageBack();

      // 🆕 R185 — M5-5 차단 보드(홈 블록 1 · 3 · 알림 목적지 — 홈 탭 진입은 앱 위젯 시험 몫 · 여기는 더보기 탭 위 링크):
      //    켜진 킬스위치 행(엔진 글자 · 선 시각 · 해제 성격) · 킬스위치 진입 · 사다리(지금 단 = 정상 표지).
      container.read(shellLinkOpenerProvider).open(AppRoutes.m5BlockBoard);
      await _until(tester, find.byKey(const Key('m55-row-KILL_SWITCH')));
      expect(find.byKey(const Key('m55-kill')), findsOneWidget);
      await _at(tester, find.byType(BlockBoardScreen), 'IT_M55A');
      await tester.ensureVisible(find.byKey(const Key('m55-ladder-NORMAL')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('m55-ladder-now')), findsOneWidget);
      await _at(tester, find.byType(BlockBoardScreen), 'IT_M55B');
      await tester.pageBack();

      // 🆕 R186 — X2 재개 게이트 → 리포트 링크(모의 원장 = 재개 회차 0 → 엔진 빈 문장 · 계절 3택 버튼 0 = b2b 전).
      container.read(shellLinkOpenerProvider).open(AppRoutes.x2ResumeGate);
      await _until(tester, find.byKey(const Key('x2g-root')));
      expect(
        find.descendant(
          of: find.byType(ResumeGateScreen),
          matching: find.byType(OutlinedButton),
        ),
        findsNothing,
      );
      await _at(tester, find.byType(ResumeGateScreen), 'IT_X2G');
      await tester.tap(find.byKey(const Key('x2g-report')));
      await _until(tester, find.byKey(const Key('x2r-root')));
      await _at(tester, find.byType(ResumeReportScreen), 'IT_X2R');
      // 전환이 끝나야 아래 화면이 무대 밖으로 간다(뒤로 버튼이 하나).
      await tester.pump(const Duration(seconds: 1));
      await tester.pageBack();
      await tester.pump(const Duration(seconds: 1));
      await tester.pageBack();
      await tester.pump(const Duration(seconds: 1));

      // 🆕 R188 — M5-9 규칙 변경 게이트 «첫 승인 최소판»: 후보가 서 있으면 첫 승인 요청 1회 → (E11k 전) 엔진
      //    `TRUSTED_TIME_UNKNOWN` 원문(우회 0) · 후보가 없으면(설정 미등재) 엔진 머리만.
      container.read(shellLinkOpenerProvider).open(AppRoutes.m5RuleChangeGate);
      await _until(tester, find.byKey(const Key('m59-root')));
      await _at(tester, find.byType(RuleChangeGateScreen), 'IT_M59A');
      final Finder reqOpen = find.byWidgetPredicate(
        (Widget w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('m59-req-open-'),
      );
      if (reqOpen.evaluate().isNotEmpty) {
        await tester.tap(reqOpen.first);
        await tester.pump(const Duration(milliseconds: 300));
        for (final (String k, String v) in <(String, String)>[
          ('m59-reason', '첫 승인'),
          ('m59-rollback', '이전 설정으로'),
          ('m59-rationale', '모의 체험 결과'),
          ('m59-expected', '실전 기동 조건'),
          ('m59-rule', '03 §6-4'),
        ]) {
          await tester.ensureVisible(find.byKey(Key(k)));
          await tester.enterText(find.byKey(Key(k)), v);
          await tester.pump(const Duration(milliseconds: 200));
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump(const Duration(milliseconds: 800));
        await tester.ensureVisible(find.byKey(const Key('m59-req-submit')));
        await tester.tap(find.byKey(const Key('m59-req-submit')));
        await _until(tester, find.textContaining('TRUSTED_TIME_UNKNOWN'));
        await _at(tester, find.byType(RuleChangeGateScreen), 'IT_M59B');
      }
      await tester.pump(const Duration(seconds: 1));
      await tester.pageBack();
      await tester.pump(const Duration(seconds: 1));

      // 🆕 R191 — M5-11 simToAuto 위저드(엔진 머리 · 단계 · 엔진이 준 버튼만) · `handoverStatus` = 같은 본문(K173).
      for (final (String route, String shot) in <(String, String)>[
        (AppRoutes.m5HandoverWizard, 'IT_M511A'),
        (AppRoutes.handoverStatus, 'IT_M511B'),
      ]) {
        container.read(shellLinkOpenerProvider).open(route);
        await _until(tester, find.byKey(const Key('m511-root')));
        await _at(tester, find.byType(HandoverWizardScreen), shot);
        await tester.pump(const Duration(seconds: 1));
        await tester.pageBack();
        await tester.pump(const Duration(seconds: 1));
      }

      // 🆕 E16j-b — X1 기기 이전 셋(모의 원장 = 옛 폰 엔진 `X1_LIVE_ONLY` 문장 · 버튼 0 · 새 폰 = live 원장 없음 → 막힘 문장 · 버튼 0).
      for (final (String route, Type screen, String root, String shot)
          in <(String, Type, String, String)>[
            (AppRoutes.x1Migration, X1PlanWizardScreen, 'x1p-root', 'IT_X1P'),
            (AppRoutes.x1MigrationPlan, X1RecoveryScreen, 'x1r-root', 'IT_X1R'),
            (
              AppRoutes.x1MigrationEmergency,
              X1RecoveryScreen,
              'x1r-root',
              'IT_X1E',
            ),
          ]) {
        container.read(shellLinkOpenerProvider).open(route);
        await _until(tester, find.byKey(Key(root)));
        expect(
          find.descendant(
            of: find.byType(screen),
            matching: find.byWidgetPredicate(
              (Widget w) => w is OutlinedButton || w is FilledButton,
            ),
          ),
          findsNothing,
        );
        await _at(tester, find.byType(screen), shot);
        await tester.pump(const Duration(seconds: 1));
        await tester.pageBack();
        await tester.pump(const Duration(seconds: 1));
      }

      container.read(shellLinkOpenerProvider).open(AppRoutes.opsDeviceRisk);
      await _until(tester, find.textContaining('남은 공간'));
      await _at(tester, find.byType(DeviceRiskBoard), 'IT_H03');

      // 🆕 E16j-a(R227) — X5 정정 마법사 허브 · 대상(모의 원장 = 열린 차이 0 · 무결성 표시 0 → 빈 허브 · 모르는 대상 = 끝 문장 · 동작 0).
      for (final (String link, String shot) in <(String, String)>[
        (AppRoutes.x5RepairWizard, 'IT_X5H'),
        ('aaq://x5/repair-wizard/ld-none', 'IT_X5T'),
      ]) {
        container.read(shellLinkOpenerProvider).open(link);
        await _until(tester, find.byKey(const Key('x5-headline')));
        expect(find.byKey(const Key('x5-do-nothing')), findsNothing);
        expect(find.byKey(const Key('x5-stage-0')), findsNothing);
        await _at(tester, find.byType(RepairWizardScreen), shot);
        await tester.pump(const Duration(seconds: 1));
        await tester.pageBack();
        await tester.pump(const Duration(seconds: 1));
      }

      // 🆕 R226 — S7-3 드로다운(맨 끝 — 연습 마감 스냅숏이 앞 단계에 섞이지 않게): 연습 개시 = 오늘이라 개시 이전 = 성과 밖 →
      //    오늘 마감 스냅숏 하나 → 엔진 문장 셋(낙폭 0 · 전고점 아래 구간 없음) · 기준 줄.
      final String d0 = kstDateText(rt.clock.nowUtc());
      files.sim.execute(
        'INSERT OR IGNORE INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, '
        "high_water_mark, drawdown, mode) VALUES (?, 10000000, 10000000, 0, 10000000, 0, 'SIM_INTERNAL')",
        <Object?>[d0],
      );
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.performanceDrawdown);
      await _until(tester, find.textContaining('최대 낙폭 0.0%'));
      expect(find.textContaining('현재 낙폭 0.0%'), findsWidgets);
      expect(find.textContaining('드로다운 기준 $d0'), findsWidgets);
      await _at(tester, find.byType(DrawdownContextScreen), 'IT_S73');

      // 🆕 R228 — S7-3b 슬리브 기여(같은 오늘 마감 하나 = 개시 날만 → 구간 0): 구간 = 엔진 기본(이번 달) · 행 셋 · 기준 줄.
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.performanceContribution);
      await _until(tester, find.textContaining('기여 분해 기준 $d0'));
      expect(
        find.text(contributionDefaultRange(rt.clock.nowUtc()).label!),
        findsWidgets,
      );
      expect(find.text('C · 방어 자산'), findsWidgets);
      await _at(tester, find.byType(ContributionScreen), 'IT_S73B');

      // 🆕 R231 — S7-1 월간 리포트(맨 끝 — 연습 개시를 지난달 첫 세션으로 옮긴다: 지난달 세션마다 마감 스냅숏 · 월말 대사
      //    MATCHED 1) → 닫힌 달 = 원장 리포트 · 배지 «대사 완료» · 「자세히」(C1 최대 낙폭) → S7-3 드로다운.
      final int y = int.parse(d0.substring(0, 4));
      final int mo = int.parse(d0.substring(5, 7));
      final String prev = mo == 1
          ? '${y - 1}-12'
          : '$y-${(mo - 1).toString().padLeft(2, '0')}';
      final TradeDate prevEnd = krMonthEndOf(rt.calendars.kr, prev);
      final List<String> prevSessions = krMonthSessionsOf(
        rt.calendars.kr,
        prevEnd,
      );
      files.sim.execute(
        'UPDATE cash_flow SET trade_date = ? WHERE note IN (?, ?)',
        <Object?>[
          prevSessions.first,
          DecisionReasonCodes.simOpeningBalance,
          DecisionReasonCodes.openingBalance,
        ],
      );
      files.sim.execute(
        'INSERT OR IGNORE INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, '
        "account_alias) VALUES ('IT-OPEN-S71', ?, 10000000, 'KRW', 'DEPOSIT', ?, ?, NULL)",
        <Object?>[
          prevSessions.first,
          DecisionReasonCodes.simOpeningBalance,
          rt.clock.nowUtc().toIso8601String(),
        ],
      );
      for (final String d in prevSessions) {
        files.sim.execute(
          'INSERT OR IGNORE INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, '
          "high_water_mark, drawdown, mode) VALUES (?, 10000000, 10000000, 0, 10000000, 0, 'SIM_INTERNAL')",
          <Object?>[d],
        );
      }
      final String reconAt = DateTime.parse(
        '${prevEnd.yyyyMmDd}T07:05:00+09:00',
      ).toUtc().toIso8601String();
      files.sim.execute(
        'INSERT OR IGNORE INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
        "VALUES (?, ?, 1, '{}', 'MATCHED')",
        <Object?>['rc-$reconAt#1', reconAt],
      );
      container.read(shellLinkOpenerProvider).open('aaq://report/$prev');
      await _until(tester, find.text('리포트 기준 ${prevEnd.yyyyMmDd}'));
      expect(find.text(MonthlyTrustTexts.reconciledLabel), findsWidgets);
      expect(find.text('$d0 생성'), findsWidgets);
      await _at(tester, find.byType(MonthlyReportScreen), 'IT_S71');
      final Finder c1 = find.descendant(
        of: find.ancestor(of: find.text('최대 낙폭'), matching: find.byType(Card)),
        matching: find.widgetWithText(TextButton, '자세히'),
      );
      await tester.ensureVisible(c1);
      await tester.tap(c1);
      await _until(tester, find.textContaining('드로다운 기준'));
      expect(find.byType(DrawdownContextScreen), findsOneWidget);
      await _at(tester, find.byType(DrawdownContextScreen), 'IT_S71_DD');

      // 🆕 E11q-d1 — M8 문서 다섯 길(엔진 원고 번들 · 원장 0): 런북 목록 여섯 행 → 상세(host-lost 단계) · 긴급 카드(인쇄 자리 부재) ·
      //    핸드북 목차(원고 없는 장 = 준비 중) → 슬리브 B 쪽(별칭 · live 값 원천 0 = 블록 뺌).
      container.read(shellLinkOpenerProvider).open(AppRoutes.opsRunbooks);
      await _until(tester, find.byKey(const Key('d02-list-row-5')));
      await _at(tester, find.byType(RunbookList), 'IT_D02');
      await tester.tap(find.text('운영 폰을 잃어버렸거나 고장 났을 때'));
      await _until(tester, find.byKey(const Key('d02-intro')));
      await _at(tester, find.byType(RunbookDetail), 'IT_D02D');
      container.read(shellLinkOpenerProvider).open(AppRoutes.opsEmergencyCard);
      await _until(tester, find.byKey(const Key('d03-notice')));
      expect(find.byKey(const Key('d03-print')), findsNothing);
      await _at(tester, find.byType(EmergencyStopCard), 'IT_D03');
      container.read(shellLinkOpenerProvider).open(AppRoutes.handbookIndex);
      // 목록은 게으르게 짓는다 — 화면 밖 항목은 아직 없다(첫 항목 · 슬리브 B 자식이 서면 충분).
      await _until(tester, find.byKey(const Key('b01-entry-0')));
      expect(find.text('슬리브 B — 해외 지수·금 ETF'), findsOneWidget);
      await _at(tester, find.byType(HandbookContents), 'IT_B01');
      await tester.tap(find.text('슬리브 B — 해외 지수·금 ETF'));
      await _until(tester, find.byKey(const Key('b02-title')));
      expect(find.byKey(const Key('b02-asof')), findsNothing);
      await _at(tester, find.byType(HandbookPageView), 'IT_B02');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      files.close();
      dir.deleteSync(recursive: true);
    }
    _mark('IT_DONE');
  });
}
