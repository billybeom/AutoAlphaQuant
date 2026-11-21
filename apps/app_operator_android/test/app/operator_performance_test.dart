// E11q-q5a — M7 S7-7 연간 리뷰 · S7-10 이행 갭 조립(설계 13 §8 R220) · 🆕 E11q-q5b S7-2 시리즈 · S7-2G 게이트 · 열람 기록(R223)
// — 실 SQLite(sim 원장).
//
// 🔴 연도 · 창 = S12 목차와 같은 원천(신뢰 시각 · 온보딩 확정 해) · 판 지문 = 모의 개시 판(전 = 빈 글자) ·
//    A 행 탐색 링크 = 레지스트리에 본문이 있을 때만 · 이행 갭 운영 방식 = 화면 상태 · 나머지 M7 창구 = «원천 없음».

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_ops_status.dart';
import 'package:app_operator_android/app/operator_performance.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        AnnualReviewCodes,
        AnnualReviewTexts,
        AnnualReviewVmTexts,
        DisclosureGateTexts,
        P0sHumanInputs,
        PerfSeriesTexts,
        TrustedClock;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        OpsConfigReady,
        P0sHumanDecision,
        SqliteOnboardingStore,
        SqlitePerformanceSource,
        currentP0sOpsConfig;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/widgets.dart' show Key, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database, Row;
import 'package:ui_analytics/ui_analytics.dart'
    show
        AnnualReviewScreen,
        DrawdownContextScreen,
        ExecutionGapScreen,
        PerformanceExploreScreen;

import '../engine/support.dart';

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

class _Trusted implements TrustedClock {
  const _Trusted(this.at);
  final DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

bool _all(String _) => true;

OperatorView _viewOf(Database db, OperatingMode mode) => OperatorView(
  db: db,
  flags: FeatureFlags(
    satelliteEnabled: false,
    webViewerEnabled: false,
    calendarEnabled: false,
    runMode: RunMode.simInternal,
    operatingMode: mode,
    configHash: 'cfg_test',
  ),
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 19, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  OperatorRuntime rt({DateTime? trusted, P0sHumanDecision? human}) =>
      OperatorRuntime(
        files: files,
        clock: clock,
        trusted: _Trusted(trusted),
        vault: MemorySecretVault(),
        deviceId: _dev,
        humanDecision: human,
      );

  void commitOnboarding(DateTime at) => files.sim.execute(
    'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
    <Object?>[
      OperatingMode.autoTrade.wire,
      at.toIso8601String(),
      at.toIso8601String(),
    ],
  );

  Future<AnnualReviewVm> annual(
    OperatorRuntime r, {
    bool Function(String) hasBody = _all,
    String? year,
  }) => OperatorPerformanceRepository(
    r,
    hasBody: hasBody,
  ).annualReview(year: year);

  Future<AnnualReviewIndexVm> index(OperatorRuntime r) =>
      OperatorOpsStatusRepository(r, hasBody: _all).watchAnnualReview().first;

  group('S7-7 연간 리뷰', () {
    test('🔴 연도 줄 · 창 글자 = S12 목차와 같다(신뢰 시각 · 온보딩 확정 해 — 네 상태)', () async {
      for (final (DateTime? trusted, DateTime? committed, String code)
          in <(DateTime?, DateTime?, String)>[
            (
              DateTime.utc(2026, 12, 2),
              DateTime.utc(2025, 3, 1),
              AnnualReviewCodes.open,
            ),
            (
              DateTime.utc(2026, 11, 19),
              DateTime.utc(2025, 3, 1),
              AnnualReviewCodes.closed,
            ),
            (
              DateTime.utc(2026, 11, 19),
              DateTime.utc(2026, 1, 5),
              AnnualReviewCodes.firstYear,
            ),
            (null, DateTime.utc(2025, 3, 1), AnnualReviewCodes.unknown),
            (DateTime.utc(2026, 11, 19), null, AnnualReviewCodes.firstYear),
          ]) {
        files.sim.execute('DELETE FROM onboarding_choice');
        if (committed != null) commitOnboarding(committed);
        final OperatorRuntime r = rt(trusted: trusted);
        final AnnualReviewVm vm = await annual(r);
        final AnnualReviewIndexVm idx = await index(r);
        final String why = '$trusted · $committed';
        expect(vm.windowStateCode, code, reason: why);
        expect(vm.yearLabel, idx.yearLabel, reason: why);
        expect(vm.windowStateLabel, idx.windowStateLabel, reason: why);
        expect(vm.asOf.label, '연간 점검 기준 2026-11-19', reason: why);
      }
    });

    test('운영 첫 해 = 온보딩 확정 시각(한국) — 한국 1월 1일 0시 = 그해', () async {
      commitOnboarding(DateTime.utc(2025, 12, 31, 15)); // 한국 2026-01-01 00:00
      final AnnualReviewVm vm = await annual(
        rt(trusted: DateTime.utc(2026, 11, 19)),
      );
      expect(vm.windowStateCode, AnnualReviewCodes.firstYear);
      expect(vm.yearLabel, '2026년 연간 리뷰');
      expect(vm.windowStateLabel, AnnualReviewTexts.firstYear);
    });

    test('🔴 판 지문 = 모의 개시 판 · 개시 전 = 빈 글자 · 세후 = 참고치 두 갈래', () async {
      const Map<String, String> accounts = <String, String>{
        'P0S_A': 'isa',
        'P0S_B': 'pension',
        'P0S_C': 'general',
        'P0S_POT': 'isa',
      };
      final P0sHumanDecision human = P0sHumanDecision(
        inputs: P0sHumanInputs(aSymbol: '229200', accountByStrategy: accounts),
        accountLabels: const <String, String>{
          'isa': 'ISA',
          'pension': '연금저축',
          'general': '일반 위탁',
        },
        decisionRef: 'R153',
      );
      final OperatorRuntime r = rt(
        trusted: DateTime.utc(2026, 11, 19),
        human: human,
      );
      final AnnualReviewVm before = await annual(r);
      expect(before.afterTax!.configHash, '');
      expect(before.afterTax!.branch, TaxLadderBranch.specPotTaxFree);
      expect(
        before.afterTaxCounterfactual!.branch,
        TaxLadderBranch.cfPotTaxableComp38,
      );
      expect(before.afterTax!.isReferenceOnly, isTrue);
      expect(
        before.afterTax!.asOf.label,
        AnnualReviewVmTexts.afterTaxAsOfLabel('2026-11-19'),
      );

      expect(
        SqliteOnboardingStore(
          files.sim,
          clock: clock,
        ).selectOperatingMode(OperatingMode.autoTrade).ok,
        isTrue,
      );
      final CommandReceipt receipt =
          await OperatorCommandApi(
            r,
            random: Random(11),
          ).submitSelfReportBalance(
            SelfReportSubmission(
              purpose: SelfReportPurpose.simOpening,
              input: const SelfReportInput(cashKrwText: '10,000,000'),
              declaredComplete: true,
            ),
          );
      expect(receipt.state, CommandState.executed, reason: receipt.stateLabel);
      final String hash =
          (currentP0sOpsConfig(files.sim) as OpsConfigReady).configHash;
      final AnnualReviewVm after = await annual(r);
      expect(after.afterTax!.configHash, hash);
      expect(after.afterTaxCounterfactual!.configHash, hash);
      expect(hash, isNot(''));
    });

    test(
      '🔴 A 행 탐색 링크 = 지금 레지스트리(🆕 R223 탐색 등록 — 뒤집은 단언) → 탐색 · 등록 안 됨 → 0',
      () async {
        commitOnboarding(DateTime.utc(2025, 3, 1));
        final OperatorRuntime r = rt(trusted: DateTime.utc(2026, 12, 2));
        final AnnualReviewVm now = await annual(
          r,
          hasBody: kOperatorRouteBodies.byPattern.containsKey,
        );
        expect(now.sections.first.route, AppRoutes.performanceExplore);
        final AnnualReviewVm none = await annual(
          r,
          hasBody: (String _) => false,
        );
        expect(
          none.sections.map((AnnualReviewSection s) => s.route).toSet(),
          <String?>{null},
        );
      },
    );

    test('명시 연도 = 엔진에 그대로(끝난 해 · 범위 밖 = 실패)', () async {
      commitOnboarding(DateTime.utc(2024, 3, 1));
      final OperatorRuntime r = rt(trusted: DateTime.utc(2026, 11, 19));
      final AnnualReviewVm vm = await annual(r, year: '2024');
      expect((vm.year, vm.windowStateCode), ('2024', AnnualReviewCodes.closed));
      await expectLater(annual(r, year: '2026'), throwsStateError);
    });

    test('🔴 나머지 M7 창구 = «원천 없음»(지어내지 않는다)', () async {
      final OperatorPerformanceRepository p = OperatorPerformanceRepository(
        rt(),
        hasBody: _all,
      );
      final DateRange range = DateRange(
        from: TradeDate('2026-01-02'),
        to: TradeDate('2026-11-19'),
      );
      for (final Future<Object?> f in <Future<Object?>>[
        p.monthlyReport('2026-10'),
        p.afterTaxLadder(fiscalYear: '2026'),
        p.reportArchive(),
        p.contribution(range: range),
        p.goalPath(yyyyMm: '2026-10'),
      ]) {
        await expectLater(f, throwsA(isA<UnsupportedError>()));
      }
    });
  });

  group('🆕 S7-2 시리즈 · S7-2G 게이트 · 열람 기록(R223)', () {
    void snap(String day, double equity) => files.sim.execute(
      'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
      "VALUES (?, ?, ?, 0, ?, 0, 'SIM_INTERNAL')",
      <Object?>[day, equity, equity, equity],
    );

    DisclosureViewEvent event() => DisclosureViewEvent(
      surfaceCode: DisclosureSurfaceCodes.performanceExplore,
      viewedAt: clock.nowUtc(),
    );

    test(
      '🔴 시리즈 = 화면 상태의 원장 · KR 달력 · 원천과 같은 값 · 화면 상태 없음 / 임의 구간 = 실패',
      () async {
        final OperatorRuntime r = rt();
        final OperatorPerformanceRepository p = OperatorPerformanceRepository(
          r,
          hasBody: _all,
        );
        Future<PerformanceSeries> daily({DateRange? range}) => p.series(
          metric: PerfMetric.twr,
          granularity: PerfGranularity.daily,
          cumulative: true,
          range: range,
        );
        await expectLater(daily(), throwsStateError);
        r.view.value = _viewOf(files.sim, OperatingMode.autoTrade);
        expect((await daily()).unavailableLabel, PerfSeriesTexts.noSnapshot);
        snap('2026-11-13', 100); // 금
        snap('2026-11-16', 100); // 월 — 주말 = 점 아님(KR 달력)
        snap('2026-11-17', 100);
        snap('2026-11-18', 101);
        final PerformanceSeries got = await daily();
        expect(
          got.points
              .map((PerfPoint x) => (x.date.yyyyMmDd, x.valueText))
              .toList(),
          <(String, String)>[
            ('2026-11-13', '0.00%'),
            ('2026-11-16', '0.00%'),
            ('2026-11-17', '0.00%'),
            ('2026-11-18', '1.00%'),
          ],
          reason: '오늘(11-19) = 스냅숏 전 → 점 아님 · 주말 = 세션 아님',
        );
        expect(
          got,
          SqlitePerformanceSource(files.sim, clock: clock).series(
            metric: PerfMetric.twr,
            granularity: PerfGranularity.daily,
            cumulative: true,
            isSession: (String d) => r.calendars.kr.isSession(TradeDate(d)),
          ),
        );
        await expectLater(
          daily(
            range: DateRange(
              from: TradeDate('2026-11-01'),
              to: TradeDate('2026-11-18'),
            ),
          ),
          throwsUnsupportedError,
        );
      },
    );

    test(
      '🔴 게이트 흐름 = 0회 → 「그래도 보기」 기록 → 같은 흐름에서 «1번» · 무결성 = 닫힘 · 화면 상태 없음 = 오류',
      () async {
        final OperatorRuntime r = rt();
        final OperatorPerformanceRepository p = OperatorPerformanceRepository(
          r,
          hasBody: _all,
        );
        await expectLater(p.watchDisclosureGate(), emitsError(isStateError));
        r.view.value = _viewOf(files.sim, OperatingMode.autoTrade);
        final List<DisclosureGateVm> seen = <DisclosureGateVm>[];
        final StreamSubscription<DisclosureGateVm> sub = p
            .watchDisclosureGate()
            .listen(seen.add);
        addTearDown(sub.cancel);
        await pumpEventQueue();
        expect(seen.last.gateOpen, isTrue);
        expect(seen.last.viewCountText, DisclosureGateTexts.noViewsYet);
        expect(seen.last.route, AppRoutes.performanceExplore);
        final CommandReceipt receipt = await OperatorCommandApi(
          r,
          random: Random(7),
        ).recordDisclosureView(event());
        expect(receipt.state, CommandState.executed);
        expect(receipt.stateLabel, DisclosureGateTexts.recorded);
        await Future<void>.delayed(const Duration(milliseconds: 120));
        expect(seen.last.viewCountText, '이번 달 1번 열어 보셨습니다');
        expect(seen.last.frictionLine, DisclosureGateTexts.friction);
        files.sim.execute(
          "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-11-19T00:00:00.000Z', 'x')",
        );
        await Future<void>.delayed(const Duration(milliseconds: 120));
        expect(seen.last.gateOpen, isFalse);
        expect(seen.last.headline, DisclosureGateTexts.closedHeadline);
      },
    );

    test('🔴 열람 기록 — 기기 id · 화면 상태 없음 = 실패(기록 0) · 접수증 = watchCommand · 무결성 = 보류 행', () async {
      final OperatorRuntime noDevice = OperatorRuntime(
        files: files,
        clock: clock,
        trusted: const _Trusted(null),
        vault: MemorySecretVault(),
      )..view.value = _viewOf(files.sim, OperatingMode.autoTrade);
      await expectLater(
        OperatorCommandApi(noDevice).recordDisclosureView(event()),
        throwsStateError,
      );
      final OperatorRuntime r = rt();
      final OperatorCommandApi api = OperatorCommandApi(r, random: Random(9));
      await expectLater(api.recordDisclosureView(event()), throwsStateError);
      expect(
        files.sim.select('SELECT 1 FROM command_inbox'),
        isEmpty,
        reason: '실패 = 기록 0',
      );
      r.view.value = _viewOf(files.sim, OperatingMode.autoTrade);
      final CommandReceipt ok = await api.recordDisclosureView(event());
      await expectLater(api.watchCommand(ok.commandId), emits(ok));
      files.sim.execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-11-19T00:00:00.000Z', 'x')",
      );
      final CommandReceipt held = await api.recordDisclosureView(event());
      expect(held.state, CommandState.heldForIntegrity);
      expect(held.stateLabel, DisclosureGateTexts.held);
      expect(
        files.sim
            .select(
              "SELECT state FROM command_inbox WHERE kind = 'DISCLOSURE_VIEW' ORDER BY rowid",
            )
            .map((Row x) => x['state'])
            .toList(),
        <Object?>['EXECUTED', 'HELD_FOR_INTEGRITY'],
      );
    });
  });

  group('🆕 S7-3 드로다운(R226)', () {
    void snap(String day, double equity) => files.sim.execute(
      'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
      "VALUES (?, ?, ?, 0, ?, 0, 'SIM_INTERNAL')",
      <Object?>[day, equity, equity, equity],
    );

    test('🔴 화면 상태의 원장 · KR 달력(주말 = 결측 아님) · 원천과 같은 값 · 화면 상태 없음 / 임의 구간 / 스냅숏 0 = 실패', () async {
      final OperatorRuntime r = rt();
      final OperatorPerformanceRepository p = OperatorPerformanceRepository(
        r,
        hasBody: _all,
      );
      await expectLater(p.drawdownContext(), throwsStateError);
      r.view.value = _viewOf(files.sim, OperatingMode.autoTrade);
      await expectLater(p.drawdownContext(), throwsStateError);
      snap('2026-11-13', 100); // 금
      snap('2026-11-16', 94); // 월 — 주말 = 세션 아님(결측 고지 0)
      snap('2026-11-18', 97); // 17 결측
      final DrawdownContextVm v = await p.drawdownContext();
      expect(v.maxDdText, '최대 낙폭 −6.0% (결측 1거래일 제외)');
      expect(v.currentDdText, '현재 낙폭 −3.0%');
      expect(
        v,
        SqlitePerformanceSource(files.sim, clock: clock).drawdownContext(
          isSession: (String d) => r.calendars.kr.isSession(TradeDate(d)),
        ),
      );
      await expectLater(
        p.drawdownContext(
          range: DateRange(
            from: TradeDate('2026-11-01'),
            to: TradeDate('2026-11-18'),
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('S7-10 이행 갭', () {
    test('🔴 화면 상태 없음(운용 전) = 발행된 안내 0 · 자동 매매 = 해당 없음 · 안내 = 원천 없음', () async {
      final OperatorRuntime r = rt();
      final OperatorExecutionGapRepository g = OperatorExecutionGapRepository(
        r,
      );
      final ExecutionGapResult none = await g.monthly();
      expect(none.emptyKind, EmptyKind.noData);
      expect(none.emptyLabel, AnnualReviewVmTexts.gapNoData);
      expect(none.report, isNull);
      expect(none.asOf.label, '이행 갭 기준 2026-11-19');

      r.view.value = _viewOf(files.sim, OperatingMode.autoTrade);
      for (final String? m in <String?>[null, '2026-10']) {
        final ExecutionGapResult auto = await g.monthly(yyyyMm: m);
        expect(auto.emptyKind, EmptyKind.notApplicable, reason: m);
        expect(auto.emptyLabel, AnnualReviewVmTexts.gapNotApplicable);
      }
      await expectLater(g.monthly(yyyyMm: '2026-1'), throwsArgumentError);

      r.view.value = _viewOf(files.sim, OperatingMode.advisory);
      await expectLater(g.monthly(), throwsStateError);
      await expectLater(g.watchRolling(), emitsError(isA<UnsupportedError>()));
    });
  });

  group('레지스트리', () {
    test('S7-7 = 연간 리뷰 화면 · S7-10 = 인자 없음 · 그 달 = 같은 위젯(받은 달 · 키)', () {
      expect(
        kOperatorRouteBodies.byPattern[AppRoutes.reportAnnual]!(
          const <String, String>{},
        ),
        isA<AnnualReviewScreen>(),
      );
      final Object plain = kOperatorRouteBodies
          .byPattern[AppRoutes.ledgerExecutionGap]!(const <String, String>{});
      expect(plain, isA<ExecutionGapScreen>());
      expect((plain as ExecutionGapScreen).yyyyMm, isNull);
      final ExecutionGapScreen month =
          kOperatorRouteBodies.byPattern[AppRoutes.ledgerExecutionGapMonth]!(
            const <String, String>{'yyyyMm': '2026-10'},
          ) as ExecutionGapScreen;
      expect(month.yyyyMm, '2026-10');
      expect(month.key, const ValueKey<String>('2026-10') as Key);
      // 🆕 R223 — S7-2 탐색 = 게이트로 시작하는 한 위젯(뒤집은 단언 — R220 = 아직).
      expect(
        kOperatorRouteBodies.byPattern[AppRoutes.performanceExplore]!(
          const <String, String>{},
        ),
        isA<PerformanceExploreScreen>(),
      );
      // 🆕 R226 — S7-3 드로다운 = 엔진 기본 구간(인자 없음).
      final Object dd = kOperatorRouteBodies
          .byPattern[AppRoutes.performanceDrawdown]!(const <String, String>{});
      expect(dd, isA<DrawdownContextScreen>());
      expect((dd as DrawdownContextScreen).range, isNull);
    });
  });
}
