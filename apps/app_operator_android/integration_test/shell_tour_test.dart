// E11p3d-5f 에뮬레이터 종합 확인(설계 13 §8 R140) — 실제 앱 셸에서 홈(H-01) → 더보기 = 설정 홈(S01) → 연결(S07) → H-03.
// 🆕 E11p3d-5h(R146) — + 기기 · 접근(S06 · 실제 기기 id · 설정 홈 «기기·접근» 카드로 들어간다).
// 🆕 E11p3d-5i(R151) — + 계좌 · 매핑(S03 · 설정 홈 «계좌·매핑» 카드 · 운영 설정 전 = 슬리브 미지정).
// 🆕 E11q1(R171) — + M6 H6-1 보유 현황(보유 0 = 빈 문장 → 연습 보유를 원장에 넣으면 같은 화면에 카드가 선다).
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
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/platform/human_inputs_loader.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart'
    show P0sHumanInputs, P0sOpsConfig, P0sStrategyIds, kstDateText;
import 'package:data_sync/data_sync.dart'
    show
        HealthchecksClient,
        ModeAxis,
        SqliteConfigVersionStore,
        SqliteModeStore;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        DecisionReasonCodes,
        ExecPolicy,
        LedgerFile,
        OperatingMode,
        RunMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:ui_journal/ui_journal.dart' show HoldingsOverview;
import 'package:ui_settings/ui_settings.dart'
    show
        AnnualReviewEntry,
        Accounts,
        Connections,
        Devices,
        Diagnostics,
        SettingsHome;
import 'package:ui_shell/ui_shell.dart'
    show DeviceRiskBoard, OpsHome, ShellRoot, shellLinkOpenerProvider;

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

      // 🆕 R168 — S12 12월 연간 리뷰 목차(신뢰 시각 전 = «확인하지 못했습니다» · 목차 = 등록된 M7 화면 0).
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.settingsAnnualReview);
      await _until(tester, find.textContaining('연간 점검 창을 확인하지 못했습니다'));
      expect(find.textContaining('년 연간 리뷰'), findsWidgets);
      await _at(tester, find.byType(AnnualReviewEntry), 'IT_S12');
      await tester.pageBack();

      // 🆕 R171 — M6 H6-1 보유 현황 · 보유 0 = 엔진 빈 문장 → 연습 보유를 넣으면(원장 변경) 같은 화면에 카드 A · B · C.
      container.read(shellLinkOpenerProvider).open(AppRoutes.holdingsOverview);
      await _until(tester, find.textContaining('보유 종목이 없습니다'));
      await _at(tester, find.byType(HoldingsOverview), 'IT_H61');
      _seedPracticeHoldings(files.sim, rt);
      await _until(tester, find.text('B · 해외 지수·금 ETF'));
      expect(find.textContaining('잔고 기준 '), findsWidgets);
      await _at(tester, find.byType(HoldingsOverview), 'IT_H61B');
      await tester.pageBack();

      container.read(shellLinkOpenerProvider).open(AppRoutes.opsDeviceRisk);
      await _until(tester, find.textContaining('남은 공간'));
      await _at(tester, find.byType(DeviceRiskBoard), 'IT_H03');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      files.close();
      dir.deleteSync(recursive: true);
    }
    _mark('IT_DONE');
  });
}
