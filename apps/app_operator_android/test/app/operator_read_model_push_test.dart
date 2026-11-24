// 🆕 E11l2c-2 — 읽기 모델 push 원천 배선 · 깨어남 뒤 실행 시험(설계 13 §8 R264 · 01 §8 미결 241 ⓐ ⓒ).
//
// ① 원천 = 이 판 12표(정확히) ② 계약 표본 창구 값 → push 일 → 12표 + 봉투 전부 OK · 행이 빌더를 통과 · 봉투 4목록
// ③ 실행 = 포트 · 화면 상태 · 리스가 다 있을 때만(없으면 null · epoch 0 = noLease · 호출 0) ④ 깨어남 뒤 = 겹침 0 · 던지지 않는다
// ⑤ 창구 값이 오지 않음 = 그 표만 LAG(상한).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_operator_android/app/operator_read_model_push.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operator_engine.dart'
    show EngineWakeReport;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

Map<String, Object?> _env(String p) => jsonDecode(
  File('../../packages/domain_contracts/fixtures/$p').readAsStringSync(),
) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String p) =>
    (_env(p)['rows']! as List<Object?>).cast<Map<String, Object?>>();

ListResult<T> _list<T>(
  String p,
  T Function(Map<String, Object?>) f, {
  bool Function(T)? where,
}) {
  final Map<String, Object?> e = _env(p);
  final List<T> rows = <T>[for (final Map<String, Object?> r in _rows(p)) f(r)];
  return ListResult<T>(
    rows: where == null ? rows : rows.where(where).toList(),
    asOf: AsOf.fromJson(e['as_of']! as Map<String, Object?>),
    emptyKind: EmptyKind.values.firstWhere(
      (EmptyKind k) => k.wire == e['empty_kind'],
    ),
    emptyLabel: e['empty_label'] as String?,
    hasMore: e['has_more']! as bool,
  );
}

class _Config extends UnimplementedConfigRepository {
  _Config();
  @override
  Stream<FeatureFlags> watchFlags() => Stream<FeatureFlags>.value(
    const FeatureFlags(
      satelliteEnabled: true,
      webViewerEnabled: true,
      calendarEnabled: false,
      runMode: RunMode.live,
      operatingMode: OperatingMode.autoTrade,
      configHash: 'cfg_fake_0000000000000000',
    ),
  );
  @override
  Stream<ContributionSetting> watchContributionSetting() =>
      Stream<ContributionSetting>.value(
        ContributionSetting.fromJson(
          _rows('m9/contribution_setting_default.json').first,
        ),
      );
  @override
  Stream<List<SleeveCatalogEntry>> watchSleeves() =>
      Stream<List<SleeveCatalogEntry>>.value(<SleeveCatalogEntry>[
        for (final Map<String, Object?> r in _rows('sleeve_catalog_4.json'))
          SleeveCatalogEntry.fromJson(r),
      ]);
}

class _Settings extends UnimplementedSettingsRepository {
  _Settings({this.fail = false});
  final bool fail;
  @override
  Stream<AllocationEditorVm> watchAllocationEditor() => fail
      ? Stream<AllocationEditorVm>.error(StateError('운영 설정 없음'))
      : Stream<AllocationEditorVm>.value(
          AllocationEditorVm.fromJson(_rows('m9/allocation_editor.json').first),
        );
}

class _Safety extends UnimplementedSafetyRepository {
  _Safety();
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(
    SafetyState.fromJson(
      _rows('safety_states.json')
          .firstWhere((Map<String, Object?> r) => r['mode'] == 'LIVE'),
    ),
  );
}

class _Performance extends UnimplementedPerformanceRepository {
  _Performance();
  @override
  Stream<DisclosureGateVm> watchDisclosureGate() =>
      Stream<DisclosureGateVm>.value(
        DisclosureGateVm.fromJson(_rows('m7/m7_disclosure_gate.json').first),
      );
  @override
  Future<ReportArchiveVm> reportArchive() async =>
      ReportArchiveVm.fromJson(_rows('m7/m7_report_archive_18.json').first);
}

class _Trust extends UnimplementedLedgerTrustRepository {
  _Trust();
  @override
  Stream<LedgerTrustBadge> watchGrade() => Stream<LedgerTrustBadge>.value(
    LedgerTrustBadge.fromJson(_rows('m7/ledger_trust_4.json').first),
  );
}

class _OpsStatus extends UnimplementedOpsStatusRepository {
  _OpsStatus({this.silent = false});
  final bool silent;
  @override
  Stream<WatchdogBoardVm> watchWatchdog() => silent
      ? StreamController<WatchdogBoardVm>()
            .stream // 값도 끝도 오지 않는다
      : Stream<WatchdogBoardVm>.value(
          WatchdogBoardVm.fromJson(_rows('m8/watchdog_delayed.json').first),
        );
}

class _OpsSummary extends UnimplementedOpsSummaryRepository {
  _OpsSummary();
  @override
  Stream<OpsDailySummary> watchToday() => Stream<OpsDailySummary>.value(
    OpsDailySummary.fromJson(_rows('m8/ops_home_normal.json').first),
  );
  @override
  Stream<ListResult<OpsRhythmRow>> watchRhythm() =>
      Stream<ListResult<OpsRhythmRow>>.value(
        _list('m8/ops_rhythm_rows.json', OpsRhythmRow.fromJson),
      );
}

class _Holdings extends UnimplementedHoldingsRepository {
  _Holdings();
  @override
  Stream<SleeveAllocationVm> watchAllocation() =>
      Stream<SleeveAllocationVm>.value(
        SleeveAllocationVm.fromJson(_rows('m6/allocation_in_band.json').first),
      );
}

class _Alerts extends UnimplementedAlertRepository {
  _Alerts();
  @override
  Stream<List<AlertItem>> watchInbox({AlertLevel? min}) =>
      Stream<List<AlertItem>>.value(<AlertItem>[
        for (final Map<String, Object?> r in _rows('alerts_12.json'))
          AlertItem.fromJson(r),
      ]);
}

class _Ledger extends UnimplementedLedgerRepository {
  _Ledger();
  @override
  Stream<ListResult<LedgerDiffRow>> watchOpenDiffs() =>
      Stream<ListResult<LedgerDiffRow>>.value(
        _list('ledger_diffs_4.json', LedgerDiffRow.fromJson),
      );
}

/// blind 큐를 부른 실행 모드(원천이 화면 상태의 모드를 넘기는지).
final List<RunMode> _blindModes = <RunMode>[];

class _Journal extends UnimplementedJournalRepository {
  _Journal();
  @override
  Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({
    RunMode mode = RunMode.live,
  }) {
    _blindModes.add(mode);
    return Stream<ListResult<BlindReviewCard>>.value(
      _list('m6/blind_review_queue_3.json', BlindReviewCard.fromJson),
    );
  }

  @override
  Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId) =>
      Stream<JournalRebalanceScope?>.value(
        rebalanceEventId ==
                're_20260803_01' // 표본 범위의 회차
            ? JournalRebalanceScope.fromJson(
                _rows('m6/journal_rebalance_scope_1.json').first,
              )
            : null,
      );
}

class _Rebalance extends UnimplementedRebalanceRepository {
  _Rebalance();
  @override
  Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range}) =>
      Stream<ListResult<RebalanceEvent>>.value(
        _list(
          'rebalance_6.json',
          RebalanceEvent.fromJson,
          where: (RebalanceEvent e) => e.mode == RunMode.live,
        ),
      );
}

OperatorReadModelRepos _repos({
  bool allocationFails = false,
  bool watchdogSilent = false,
}) => OperatorReadModelRepos(
  config: _Config(),
  settings: _Settings(fail: allocationFails),
  safety: _Safety(),
  performance: _Performance(),
  ledgerTrust: _Trust(),
  opsStatus: _OpsStatus(silent: watchdogSilent),
  opsSummary: _OpsSummary(),
  holdings: _Holdings(),
  alerts: _Alerts(),
  ledger: _Ledger(),
  journal: _Journal(),
  rebalance: _Rebalance(),
);

class _Pusher implements ReadModelPusher {
  final List<(String, List<Map<String, Object?>>)> calls =
      <(String, List<Map<String, Object?>>)>[];
  @override
  Future<ReadModelPushResult> push({
    required String deviceId,
    required int epoch,
    required ReadModelTable table,
    required List<Map<String, Object?>> rows,
  }) async {
    calls.add((table.name, rows));
    return ReadModelPushResult.answered(
      code: null,
      epoch: epoch,
      accepted: rows.length,
      skipped: 0,
    );
  }
}

const Set<String> _thisBoard = <String>{
  'rm_rebalance_event',
  'rm_alert',
  'rm_safety_state',
  'rm_config_view',
  'rm_report_archive',
  'rm_ledger_diff',
  'rm_sleeve_allocation',
  'rm_disclosure_view',
  'rm_ops_summary',
  'rm_ledger_trust',
  'rm_blind_review',
  'rm_watchdog',
};

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;
  setUp(() => clock = FakeClock(kst(2026, 12, 22, 9, 30)));

  void claim(Database db, int epoch) => db.execute(
    'INSERT INTO sync_state(target, status, operator_epoch, updated_at) VALUES (?, ?, ?, ?)',
    <Object?>[kLeaseSyncTarget, 'OK', epoch, clock.nowUtc().toIso8601String()],
  );

  test('① 원천 = 이 판의 표 정확히(일지 · 성과 · 월간 · 맥락 · 보유 · 안내 · 이행 갭 = 0)', () {
    final Set<String> got = operatorReadModelSources(
      _repos(),
      mode: RunMode.live,
    ).keys.toSet();
    expect(got, _thisBoard);
    expect(got, hasLength(12));
    for (final String later in <String>[
      'rm_journal',
      'rm_performance_point',
      'rm_performance_series',
      'rm_monthly_report',
      'rm_perf_context',
      'rm_holding',
      'rm_advice',
      'rm_advice_summary',
      'rm_execution_gap',
    ]) {
      expect(got, isNot(contains(later)));
    }
  });

  test(
    '② 계약 표본 창구 값 → push 일 → 표 + 봉투 전부 OK · 봉투 4목록 · 회차 범위 있는 행만 scope_',
    () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      final _Pusher p = _Pusher();
      final ReadModelPushReport rep = await ReadModelPushJob(
        pusher: p,
        status: SqliteReadModelPushStatus(f.sim),
        sources: operatorReadModelSources(_repos(), mode: RunMode.live),
        nowUtc: clock.nowUtc,
      ).run(deviceId: 'dev-a', epoch: 2);
      expect(rep.failed, isEmpty, reason: rep.tables.toString());
      expect(
        rep.tables.every(
          (ReadModelTablePush t) => t.outcome == ReadModelPushOutcome.ok,
        ),
        isTrue,
        reason: rep.tables.toString(),
      );
      expect(p.calls.map((c) => c.$1).toSet(), <String>{
        ..._thisBoard,
        'rm_list_envelope',
      });
      final List<Map<String, Object?>> env = p.calls
          .firstWhere((c) => c.$1 == 'rm_list_envelope')
          .$2;
      expect(
        env.map((Map<String, Object?> r) => r['list_code']).toSet(),
        <Object?>{
          ReadModelListCodes.rebalanceWatchEvents,
          ReadModelListCodes.ledgerWatchOpenDiffs,
          ReadModelListCodes.journalWatchBlindReviewQueue,
          ReadModelListCodes.opsStatusWatchRhythm,
        },
      );
      final List<Map<String, Object?>> ev = p.calls
          .firstWhere((c) => c.$1 == 'rm_rebalance_event')
          .$2;
      expect(
        ev.singleWhere(
          (Map<String, Object?> r) => r['scope_label'] != null,
        )['event_id'],
        're_20260803_01',
      );
      expect(
        ev.where((Map<String, Object?> r) => r['scope_label'] != null),
        isNotEmpty,
      );
      expect(
        ev.where((Map<String, Object?> r) => r['scope_label'] == null),
        isNotEmpty,
      );
      final Map<String, Object?> cfg = p.calls
          .firstWhere((c) => c.$1 == 'rm_config_view')
          .$2
          .single;
      expect(cfg['contract_version'], contractVersion);
      expect(cfg['sleeve_catalog'], isA<List<Object?>>());
      expect(cfg['allocation_label'], isNotNull);
    },
  );

  test('② 배분 편집을 못 읽음 = 설정 보기는 가되 배분 열만 비움', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final _Pusher p = _Pusher();
    final ReadModelPushReport rep = await ReadModelPushJob(
      pusher: p,
      status: SqliteReadModelPushStatus(f.sim),
      sources: operatorReadModelSources(
        _repos(allocationFails: true),
        mode: RunMode.live,
      ),
      nowUtc: clock.nowUtc,
    ).run(deviceId: 'dev-a', epoch: 2);
    expect(rep.failed, isEmpty);
    final Map<String, Object?> cfg = p.calls
        .firstWhere((c) => c.$1 == 'rm_config_view')
        .$2
        .single;
    expect(cfg.containsKey('allocation_label'), isFalse);
    expect(cfg['operating_mode'], OperatingMode.autoTrade.wire);
  });

  test('⑤ 창구 값이 오지 않음 = 그 표만 LAG(상한) · 나머지 OK', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final ReadModelPushReport rep = await ReadModelPushJob(
      pusher: _Pusher(),
      status: SqliteReadModelPushStatus(f.sim),
      sources: operatorReadModelSources(
        _repos(watchdogSilent: true),
        mode: RunMode.live,
        wait: const Duration(milliseconds: 50),
      ),
      nowUtc: clock.nowUtc,
    ).run(deviceId: 'dev-a', epoch: 2);
    final ReadModelTablePush w = rep.tables.firstWhere(
      (ReadModelTablePush t) => t.table == 'rm_watchdog',
    );
    expect(w.outcome, ReadModelPushOutcome.lag);
    expect(w.reason, startsWith('SOURCE:'));
    final List<ReadModelTablePush> ok = rep.tables
        .where((ReadModelTablePush t) => t.outcome == ReadModelPushOutcome.ok)
        .toList();
    expect(ok, hasLength(12)); // 워치독 뺀 11표 + 봉투
  });

  test('③ 실행 = 포트 · 화면 상태 · 리스가 다 있을 때만', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final _Pusher p = _Pusher();
    final OperatorRuntime none = OperatorRuntime(files: f, clock: clock);
    expect(
      await runOperatorReadModelPush(rt: none, repos: _repos()),
      isNull,
      reason: '포트 · 화면 상태 없음',
    );
    final OperatorRuntime rt = OperatorRuntime(
      files: f,
      clock: clock,
      readModelPusher: p,
      deviceId: 'dev-a',
    );
    expect(
      await runOperatorReadModelPush(rt: rt, repos: _repos()),
      isNull,
      reason: '화면 상태 없음',
    );
    // 화면 상태 = 실전 파일(행 mode = 화면 상태의 실행 모드 · 표본 = LIVE 행).
    final OperatorView v = OperatorView(
      db: f.sim,
      flags: const FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.live,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg_test',
      ),
    );
    rt.view.value = v;
    final ReadModelPushReport? noLease = await runOperatorReadModelPush(
      rt: rt,
      repos: _repos(),
    );
    expect(noLease!.noLease, isTrue, reason: 'SUPABASE epoch 0');
    expect(p.calls, isEmpty);
    claim(v.db, 2);
    none.view.value = v;
    expect(
      await runOperatorReadModelPush(rt: none, repos: _repos()),
      isNull,
      reason: '포트 없음(화면 상태 · 리스는 있음)',
    );
    final ReadModelPushReport? rep = await runOperatorReadModelPush(
      rt: rt,
      repos: _repos(),
      wait: const Duration(seconds: 2),
    );
    expect(rep!.noLease, isFalse);
    expect(rep.failed, isEmpty, reason: '행 mode = 화면 상태(live) — 다르면 빌더가 거부');
    expect(p.calls.map((c) => c.$1).toSet(), <String>{
      ..._thisBoard,
      'rm_list_envelope',
    });
    expect(
      SqliteReadModelPushStatus(v.db).row('rm_watchdog'),
      isNotNull,
      reason: '상태 = 화면 상태의 원장',
    );
    expect(p.calls.first.$2.first['row_version'], greaterThan(2 << 40));
    expect(p.calls.first.$2.first['mode'], RunMode.live.wire);
  });

  test('③ 화면 상태가 모의 내부 = 행 mode 도 모의(LIVE 표본 = 빌더 거부 · 지어내지 않는다)', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final _Pusher p = _Pusher();
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final OperatorRuntime rt = OperatorRuntime(
      files: f,
      clock: clock,
      readModelPusher: p,
      deviceId: 'dev-a',
    );
    rt.view.value = operatorViewOf(await bootEngine(f, clock: clock), f);
    expect(rt.view.value!.flags.runMode, RunMode.simInternal);
    claim(rt.view.value!.db, 2);
    final ReadModelPushReport? rep = await runOperatorReadModelPush(
      rt: rt,
      repos: _repos(),
    );
    expect(rep!.failed.map((ReadModelTablePush t) => t.table).toSet(), <String>{
      'rm_safety_state',
      'rm_rebalance_event',
    }, reason: 'DTO mode = LIVE ≠ SIM_INTERNAL');
    expect(p.calls.map((c) => c.$1), isNot(contains('rm_safety_state')));
    expect(
      _blindModes.last,
      RunMode.simInternal,
      reason: 'blind 큐 = 화면 상태의 모드로 읽는다',
    );
  });

  test('④ 깨어남 뒤 push = 겹침 0 · 던지지 않는다 · 안 달았으면 0', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final OperatorRuntime rt = OperatorRuntime(files: f, clock: clock);
    await rt.pushReadModelsOnce(); // 안 달음 = 그냥 끝
    int runs = 0;
    final Completer<void> gate = Completer<void>();
    rt.attachReadModelPush(() async {
      runs++;
      await gate.future;
      throw StateError('망');
    });
    final Future<void> a = rt.pushReadModelsOnce();
    await rt.pushReadModelsOnce(); // 앞 push 가 도는 중 = 건너뜀
    expect(runs, 1);
    gate.complete();
    await a; // 던지지 않는다
    await rt.pushReadModelsOnce();
    expect(runs, 2, reason: '끝난 뒤에는 다시 돈다');
  });

  test('④ 깨어남 = 화면 상태를 먼저 정하고 그 뒤 push 한 번(새 화면 상태로)', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final OperatorRuntime rt = OperatorRuntime(files: f, clock: clock);
    final List<RunMode?> seen = <RunMode?>[];
    rt.attachReadModelPush(() async => seen.add(rt.view.value?.flags.runMode));
    rt.onWake(EngineWakeReport(boot: await bootEngine(f, clock: clock)));
    await Future<void>.delayed(Duration.zero);
    expect(seen, <RunMode?>[RunMode.simInternal]);
  });
}
