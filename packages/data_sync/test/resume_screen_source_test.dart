// E11q-b2a — X2 재개 화면 원천(설계 13 §8 R186) — 원장 원문 → 엔진 VM.
//
// 🔴 리포트 = 가장 최근 **끝난** 회차 · 게이트 = 가장 최근 회차(열린 회차 포함) · 항목 = 회차 차례(seq) · 집행 예정 항목 = 행 아님 ·
//    `RESUME_INCOMPLETE` 활성 = BLOCKED · 계절 3택 = 고르는 창구가 있을 때만.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 12, 22, 0, 45); // 한국 12-22 09:45

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_x2_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteResumeScreenSource src({bool canChoose = true}) =>
      SqliteResumeScreenSource(
        db,
        clock: clock,
        canChoose: canChoose,
        hasBody: (String r) => r == AppRoutes.x2ResumeReport,
      );

  void run(
    String id, {
    required String started,
    String? finished,
    String mode = 'NORMAL',
    int gap = 2,
    String? headline,
  }) => db.execute(
    'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      id,
      started,
      finished,
      gap,
      mode,
      finished == null ? 'R3' : 'R8',
      jsonEncode(<String, int>{
        'executed': 1,
        'expired': 1,
        'superseded': 0,
        'blocked': 1,
        'unrecoverable': 0,
      }),
      headline,
    ],
  );

  void item(
    String runId,
    int seq,
    String work,
    String reason,
    String verdict,
  ) => db.execute(
    'INSERT INTO resume_item (resume_run_id, work_id, seq, one_line, planned_line, reevaluated_line, '
    'verdict_code, verdict_label, reason_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      runId,
      work,
      seq,
      '$work 한 줄',
      '12월 17일 계획됨',
      '$reason 글자',
      verdict,
      verdict,
      reason,
    ],
  );

  test('회차 0 = 리포트 빈 문장 · 게이트 회차 없음(OK) · 기준', () {
    final ResumeReportVm r = src().report();
    expect((r.report, r.emptyLabel), (null, ResumeScreenTexts.reportEmpty));
    expect(r.asOf.label, '재개 기준 2026-12-22 09:45');
    final ResumeGateVm g = src().gate();
    expect((g.headline, g.level), (ResumeScreenTexts.gateNoRun, UiLevel.ok));
    expect(g.reportLink?.deepLink, AppRoutes.x2ResumeReport);
  });

  test('끝난 회차 — 리포트 = 그 회차 · 게이트 행 = 집행 예정 뺀 항목(회차 차례) · 계절 3택', () {
    run(
      'RR-2026-12-22-1',
      started: '2026-12-22T00:12:00.000Z',
      finished: '2026-12-22T00:41:00.000Z',
      headline: '엔진 머리말',
    );
    item(
      'RR-2026-12-22-1',
      2,
      'w_due',
      ResumeItemReasonCodes.duePassed,
      VerdictCodes.expired,
    );
    item(
      'RR-2026-12-22-1',
      0,
      'w_done',
      ResumeItemReasonCodes.reevaluated,
      VerdictCodes.executedAsReevaluated,
    );
    item(
      'RR-2026-12-22-1',
      1,
      'w_season',
      ResumeItemReasonCodes.humanDecision,
      VerdictCodes.blocked,
    );
    final ResumeReportVm r = src().report();
    expect(r.report!.resumeRunId, 'RR-2026-12-22-1');
    expect((r.periodText, r.phaseLabel), ('12-22 09:12 ~ 09:41', '재개 마침'));
    final ResumeGateVm g = src().gate();
    expect(g.headline, '엔진 머리말');
    expect(g.modeLabel, '2거래일 미실행 — 평상');
    expect(g.level, UiLevel.watch);
    expect(
      <String>[for (final ResumeGateRow x in g.rows) x.workId],
      <String>['w_season', 'w_due'],
    );
    expect(
      g.rows.first.reasonLabel,
      '${ResumeItemReasonCodes.humanDecision} 글자',
    );
    expect(g.rows.first.actions, hasLength(3));
    expect(g.rows.last.actions, isEmpty);
    expect(
      src(canChoose: false).gate().rows.expand((ResumeGateRow x) => x.actions),
      isEmpty,
    );
  });

  test('🔴 게이트 = 가장 최근 회차(열린 회차 포함) · 리포트 = 끝난 회차 · 플래그 활성 = BLOCKED', () {
    run(
      'RR-2026-12-20-1',
      started: '2026-12-20T00:10:00.000Z',
      finished: '2026-12-20T00:30:00.000Z',
      headline: '지난 회차',
    );
    item(
      'RR-2026-12-20-1',
      0,
      'w_old',
      ResumeItemReasonCodes.duePassed,
      VerdictCodes.expired,
    );
    run(
      'RR-2026-12-22-1',
      started: '2026-12-22T00:12:00.000Z',
      mode: 'RECOVERY_DRY',
      gap: 3,
    );
    db.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>[FlagIds.resumeIncomplete, '2026-12-22T00:12:00.000Z', '재개 회차'],
    );
    final ResumeGateVm g = src().gate();
    expect(
      (g.headline, g.modeLabel, g.level, g.rows.length),
      (
        ResumeScreenTexts.gateInProgress,
        '3거래일 미실행 — 복구 관찰',
        UiLevel.blocked,
        0,
      ),
    );
    expect(src().report().report!.resumeRunId, 'RR-2026-12-20-1');
    // 플래그가 풀리면 BLOCKED 가 아니다.
    db.execute(
      'UPDATE trading_block SET cleared_at = ? WHERE flag_id = ?',
      <Object?>['2026-12-22T00:40:00.000Z', FlagIds.resumeIncomplete],
    );
    expect(src().gate().level, UiLevel.ok);
  });

  test('감시 표 = 재개 표 + 차단 플래그', () {
    expect(
      SqliteResumeScreenSource.watchedTables,
      containsAll(<String>[
        ...SqliteResumeRepository.watchedTables,
        'trading_block',
      ]),
    );
  });
}
