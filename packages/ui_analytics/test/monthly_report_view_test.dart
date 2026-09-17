// packages/ui_analytics/test/monthly_report_view_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

class FixedTestClock implements Clock {
  FixedTestClock(this._fixedUtc);
  final DateTime _fixedUtc;

  @override
  DateTime nowUtc() => _fixedUtc;
}

class FakePerformanceRepository implements PerformanceRepository {
  FakePerformanceRepository({required this.report});
  final MonthlyReport report;

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) async => report;

  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    required DateRange range,
  }) =>
      throw UnimplementedError();

  @override
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear}) =>
      throw UnimplementedError();

  @override
  Future<ReportArchiveVm> reportArchive() => throw UnimplementedError();

  @override
  Stream<DisclosureGateVm> watchDisclosureGate() => throw UnimplementedError();

  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) =>
      throw UnimplementedError();

  @override
  Future<ContributionVm> contribution({required DateRange range}) =>
      throw UnimplementedError();

  @override
  Future<AnnualReviewVm> annualReview({required String year}) =>
      throw UnimplementedError();
}

class FakeSafetyRepository implements SafetyRepository {
  FakeSafetyRepository({required this.state});
  final SafetyState state;

  @override
  Stream<SafetyState> watchState() => Stream.value(state);
}

void main() {
  final testAsOf = AsOf(
    observedAt: DateTime.parse('2026-08-31T09:00:00Z'),
    tradeDate: const TradeDate('2026-08-31'),
    source: AsOfSource.localSqlite,
    staleAfter: const Duration(hours: 24),
    label: '잔고 기준 2026-08-31 종가',
    staleReasonCode: 'BATCH_MISSING',
    staleLabel: '엔진이 1거래일 멈춰 있습니다',
  );

  final testTrust = const LedgerTrustBadge(
    grade: LedgerTrustGrade.reconciled,
    level: UiLevel.ok,
    label: '원장 대사 통과',
    consequenceLine: '브로커 잔고 대사 0오차 확인됨',
  );

  final testItems = List.generate(
    13,
    (index) => ReportItem(
      code: 'ITEM_${index + 1}',
      order: index + 1,
      sectionCode: 'SEC_${String.fromCharCode(65 + (index ~/ 2))}',
      title: '항목 ${index + 1}',
      valueText: '값 ${index + 1}',
      noteText: '주석 ${index + 1}',
    ),
  );

  final testReport = MonthlyReport(
    yyyyMm: '2026-08',
    items: testItems,
    goalLine: '계획 경로 대비 유지',
    disclosureViewCountText: '이번 달 탐색 열람 2회',
    trust: testTrust,
    asOf: testAsOf,
    backdateFootnote: '전월 소급 정정 1건이 반영되었습니다',
  );

  final testSafetyState = SafetyState(
    breakerLevel: BreakerLevel.normal,
    breakerLabel: '정상',
    drawdown: 0.05,
    activeFlags: const [],
    killSwitch: const KillSwitchView(active: false, stateLabel: '비활성'),
    stoppedReleaseEligible: false,
    releaseProgress: const [],
    alertBlockSatEntry: false,
    rampLevel: RampLevel.l1,
    mode: RunMode.live,
    asOf: testAsOf,
  );

  testWidgets('S7-1 정상 렌더: 13항목 고정 배열과 헤더 및 각주가 온전히 표시된다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsClockProvider.overrideWithValue(
            FixedTestClock(DateTime.parse('2026-08-31T12:00:00Z')),
          ),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(report: testReport),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(state: testSafetyState),
          ),
        ],
        child: const MaterialApp(
          home: MonthlyReportScreen(yyyyMm: '2026-08'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 13개 항목 모두 순서대로 렌더링되었는지 확인
    for (int i = 1; i <= 13; i++) {
      expect(find.text('항목 $i'), findsOneWidget);
      expect(find.text('값 $i'), findsOneWidget);
    }

    // 신뢰 등급 라벨 및 헤더 고지 확인
    expect(find.text('원장 대사 통과'), findsOneWidget);
    expect(find.text('전월 소급 정정 1건이 반영되었습니다'), findsOneWidget);

    // 열람 횟수 및 목표 경로
    expect(find.text('이번 달 탐색 열람 2회'), findsOneWidget);
    expect(find.text('계획 경로 대비 유지'), findsOneWidget);
  });

  testWidgets('S7-1 차단 상태: LEDGER_INTEGRITY 활성 시 수치가 마스킹된다', (tester) async {
    final blockedSafetyState = testSafetyState.copyWith(
      activeFlags: [
        BlockFlag(
          flagId: FlagIds.ledgerIntegrity,
          label: '원장 체인 단절',
          setAt: DateTime.parse('2026-08-31T10:00:00Z'),
          clearRoute: ClearRoute.wizardOnly,
          clearInstruction: '정정 마법사를 실행하십시오',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsClockProvider.overrideWithValue(
            FixedTestClock(DateTime.parse('2026-08-31T12:00:00Z')),
          ),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(report: testReport),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(state: blockedSafetyState),
          ),
        ],
        child: const MaterialApp(
          home: MonthlyReportScreen(yyyyMm: '2026-08'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 차단 배너 노출 확인
    expect(find.textContaining('원장 체인 단절'), findsOneWidget);

    // 수치가 *** 마스킹되었는지 확인 (값 1 등의 본문 텍스트 부재)
    expect(find.text('값 1'), findsNothing);
    expect(find.text(AnalyticsLabels.maskedIntegrity), findsNWidgets(13));
  });

  testWidgets('S7-1 신선도 검사: staleAfter 초과 시 오래된 데이터 배너가 뜬다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsClockProvider.overrideWithValue(
            // observedAt + 24시간을 초과한 시각
            FixedTestClock(DateTime.parse('2026-09-02T10:00:00Z')),
          ),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(report: testReport),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(state: testSafetyState),
          ),
        ],
        child: const MaterialApp(
          home: MonthlyReportScreen(yyyyMm: '2026-08'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
    expect(find.text('엔진이 1거래일 멈춰 있습니다'), findsOneWidget);
  });
}
