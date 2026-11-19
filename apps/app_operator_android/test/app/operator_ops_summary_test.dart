// E11p3d-2b 홈 오늘 요약 · 운영 리듬 operator 판(설계 13 §8 R133) — 실 SQLite(엔진 원장) · 실제 시간.

import 'dart:async';

import 'package:app_operator_android/app/operator_ops_summary.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show ListResult, OperatingMode, OpsDailySummary, OpsRhythmRow;
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late OperatorRuntime rt;

  setUp(() {
    // 한국 2026-12-22 09:30 — 12월 마지막 세션 다음 = 2027-01-04(1월 첫 세션).
    clock = FakeClock(kst(2026, 12, 22, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
    rt = OperatorRuntime(files: files, clock: clock);
  });
  tearDown(() => files.close());

  Future<OperatorView> ready() async {
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    final OperatorView v = operatorViewOf(
      await bootEngine(files, clock: clock),
      files,
    )!;
    rt.view.value = v;
    return v;
  }

  void failedJob(String rid) => files.sim.execute(
    'INSERT INTO job_run (rid, check_name, session_day, started_at, finished_at, status) '
    "VALUES (?, 'sim-auto-kr_order', '2026-12-22', ?, ?, 'FAILED')",
    <Object?>[
      rid,
      clock.nowUtc().toIso8601String(),
      clock.nowUtc().toIso8601String(),
    ],
  );

  Future<void> until(bool Function() ok) async {
    for (int i = 0; i < 200 && !ok(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(ok(), true);
  }

  test('🔴 화면 상태 없음(온보딩 전) = 오류 · 지어내지 않는다', () async {
    final OperatorOpsSummaryRepository r = OperatorOpsSummaryRepository(rt);
    await expectLater(r.watchToday(), emitsError(isA<StateError>()));
    await expectLater(r.watchRhythm(), emitsError(isA<StateError>()));
  });

  test('🔴 준비 = 화면 상태 원장의 오늘 요약(엔진 문장) · 리듬 앞 ≤3 = upcoming', () async {
    await ready();
    final OperatorOpsSummaryRepository r = OperatorOpsSummaryRepository(rt);
    final OpsDailySummary s = await r.watchToday().first;
    expect(s.todayOrdersText, '오늘 주문 0건');
    expect(s.todayErrorsText, '오늘 오류 0건');
    expect(s.signalMatchText, '신호 일치 판정 보류');
    expect(s.streakText, '규칙 준수 판정 보류');
    // 신뢰 시각 = 아직 없음(Supabase 리스 전) → 엔진 문장.
    expect(s.discretionBudgetText, '재량 예산 — 신뢰 시각 확인 중');
    expect(s.nextRebalanceDDayText, 'D-13');
    final ListResult<OpsRhythmRow> rhythm = await r.watchRhythm().first;
    expect(s.upcoming, rhythm.rows.take(3).toList());
    expect(rhythm.rows.map((OpsRhythmRow x) => x.code).toList(), <String>[
      'MONTHLY_REBALANCE',
      'MONTHLY_CONTRIBUTION',
    ]);
  });

  test('🔴 잡 실패가 기록되면 다시 낸다(같은 연결)', () async {
    await ready();
    final List<OpsDailySummary> got = <OpsDailySummary>[];
    final StreamSubscription<OpsDailySummary> sub =
        OperatorOpsSummaryRepository(rt).watchToday().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    failedJob('r1');
    await until(() => got.last.todayErrorsText == '오늘 오류 1건');
  });

  test('🔴 날이 바뀌면 주기마다 다시 계산(D-day 넘어감) · 같은 값은 다시 내지 않는다', () async {
    await ready();
    final List<OpsDailySummary> got = <OpsDailySummary>[];
    final StreamSubscription<OpsDailySummary> sub =
        OperatorOpsSummaryRepository(
          rt,
          tick: const Duration(milliseconds: 20),
        ).watchToday().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(got, hasLength(1));
    clock.now = clock.now.add(const Duration(days: 1));
    await until(() => got.last.nextRebalanceDDayText == 'D-12');
  });

  test('🔴 원천 없는 셋(안내 요약 · 슬리브 비중 · 실사 배지) = «원천 없음» 오류(지어내지 않는다)', () async {
    await expectLater(
      const OperatorAdviceRepository().watchSummary(),
      emitsError(isA<UnsupportedError>()),
    );
    await expectLater(
      OperatorHoldingsRepository(
        rt,
        hasBody: (String _) => true,
      ).watchAllocation(),
      emitsError(isA<UnsupportedError>()),
    );
    await expectLater(
      const OperatorLedgerTrustRepository().watchGrade(),
      emitsError(isA<UnsupportedError>()),
    );
    await expectLater(
      const OperatorAdviceRepository().findById('x'),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
