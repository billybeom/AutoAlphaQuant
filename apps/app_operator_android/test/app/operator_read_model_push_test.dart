// 🆕 E11l2c-2 — 읽기 모델 push 원천 배선 · 깨어남 뒤 실행 시험(설계 13 §8 R264 · 01 §8 미결 241 ⓐ ⓒ).
//
// ① 원천 = 이 판 12표(정확히) ② 계약 표본 창구 값 → push 일 → 12표 + 봉투 전부 OK · 행이 빌더를 통과 · 봉투 4목록
// ③ 실행 = 포트 · 화면 상태 · 리스가 다 있을 때만(없으면 null · epoch 0 = noLease · 호출 0) ④ 깨어남 뒤 = 겹침 0 · 던지지 않는다
// ⑤ 창구 값이 오지 않음 = 그 표만 LAG(상한).
// 🆕 E11l2c-3(R268) ⑥ 매개 5표 — 매개 값 = 뷰어가 고르는 값(시리즈 조합 12 · 보관함에서 열리는 달 · 프리셋 · 가장 넓은 프리셋 일지) ·
// 값 하나의 원천 실패 = 그 값만 뺀다 · 이번 달 기여 = 셸 기본 구간 · 드로다운 기본 = 가장 넓은 프리셋 행(`is_default`).
// 🆕 미결 242(R275 · K339~K341) ⑧ 목록 열 — 차례 = 기본 호출의 엔진 차례 1부터 · 상한 없이(일지 · 원장 차이 allDiffs) · 프리셋 ·
// 봉투 빈 문장 2(일지만) ⑨ 시리즈 점 D7 — 기본 구간 밖으로 밀린 옛 점 = 차례 null 로 한 번 · 못 읽은 조합 = 그대로.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_operator_android/app/operator_read_model_push.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart'
    show operatorShellOverrides;
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operator_engine.dart'
    show EngineWakeReport;
import 'package:core_engine/core_engine.dart' show JournalTexts;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
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
  @override
  Stream<List<DateRange>> watchRangePresets() =>
      Stream<List<DateRange>>.value(_presets());
}

/// 🆕 미결 242 — 프리셋만 못 읽는 설정 창구.
class _FlakyPresets extends _Config {
  _FlakyPresets();
  @override
  Stream<List<DateRange>> watchRangePresets() =>
      Stream<List<DateRange>>.error(StateError('프리셋 못 읽음'));
}

/// 프리셋만 다른 설정 창구.
class _OnlyPresets extends UnimplementedConfigRepository {
  _OnlyPresets(this.presets);
  final List<DateRange> presets;
  @override
  Stream<List<DateRange>> watchRangePresets() =>
      Stream<List<DateRange>>.value(presets);
}

/// 한 표로 간 행 전부(나눠 보낸 호출을 잇는다).
List<Map<String, Object?>> _rowsOf(_Pusher p, String table) => p.calls
    .where(((String, List<Map<String, Object?>>) c) => c.$1 == table)
    .expand(((String, List<Map<String, Object?>>) c) => c.$2)
    .toList();

String _key(Object? m, Object? g, Object? c) => '$m|$g|$c';

String _keyOf(Map<String, Object?> r) =>
    _key(r['metric'], r['granularity'], r['cumulative']);

List<DateRange> _presets() => <DateRange>[
  for (final Map<String, Object?> r in _rows('range_presets_4.json'))
    DateRange.fromJson(r),
];

/// 성과 창구를 부른 매개(원천이 뷰어가 고르는 값을 그대로 넘기는지).
final List<(PerfMetric, PerfGranularity, bool)> _seriesCalls =
    <(PerfMetric, PerfGranularity, bool)>[];
final List<String> _monthCalls = <String>[];
final List<DateRange> _contribCalls = <DateRange>[];
final List<(DateRange, RunMode, int)> _timelineCalls =
    <(DateRange, RunMode, int)>[];

/// 원천이 실패하는 매개 값 하나씩(그 값만 빠지는지).
const (PerfMetric, PerfGranularity, bool) _badCombo = (
  PerfMetric.mwr,
  PerfGranularity.yearly,
  false,
);
const String _badMonth = '2026-05';
const String _badPreset = 'THIS_YEAR';

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
  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) async {
    _seriesCalls.add((metric, granularity, cumulative));
    if (range != null) throw UnsupportedError('임의 구간');
    if ((metric, granularity, cumulative) == _badCombo) {
      throw StateError('원천 실패');
    }
    return PerformanceSeries.fromJson(
      _rows('m7/m7_perf_monthly_period.json').first,
    ).copyWith(
      metric: metric,
      granularity: granularity,
      cumulative: cumulative,
    );
  }

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) async {
    _monthCalls.add(yyyyMm);
    if (yyyyMm == _badMonth) throw StateError('무결성 점검 중');
    return MonthlyReport.fromJson(_rows('m7/m7_monthly_2026_08.json').first)
        .copyWith(yyyyMm: yyyyMm);
  }

  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) async {
    if (range != null) throw UnsupportedError('임의 구간');
    return DrawdownContextVm.fromJson(
      _rows('m7/m7_dd_context_normal.json').first,
    );
  }

  @override
  Future<ContributionVm> contribution({required DateRange range}) async {
    _contribCalls.add(range);
    if (range.presetCode == _badPreset) throw StateError('첫 마감 전');
    return ContributionVm.fromJson(_rows('m7/m7_contrib_3sleeve.json').first);
  }
}

/// 🆕 미결 242 — 이번에만 실패하는 일별 조합(그 옛 점 차례는 지우지 않는다).
const (PerfMetric, PerfGranularity, bool) _flaky = (
  PerfMetric.twr,
  PerfGranularity.daily,
  true,
);

/// 🆕 미결 242 — 일별 기본 구간이 옮겨 가는 성과 창구(D7 · 앞 두 점이 구간 밖).
class _Shifting extends _Performance {
  _Shifting();
  bool shifted = false;
  bool flakyDown = true;
  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) async {
    if (range != null) throw UnsupportedError('임의 구간');
    if ((metric, granularity, cumulative) == _badCombo) {
      throw StateError('원천 실패');
    }
    if (shifted && flakyDown && (metric, granularity, cumulative) == _flaky) {
      throw StateError('이번만 실패');
    }
    final PerformanceSeries s =
        PerformanceSeries.fromJson(
          _rows('m7/m7_perf_monthly_period.json').first,
        ).copyWith(
          metric: metric,
          granularity: granularity,
          cumulative: cumulative,
        );
    return shifted && granularity == PerfGranularity.daily
        ? s.copyWith(points: s.points.sublist(2))
        : s;
  }
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
  Stream<ListResult<TradeJournalEntry>> watchTimeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    RunMode mode = RunMode.live,
    int limit = 100,
  }) {
    _timelineCalls.add((range, mode, limit));
    return Stream<ListResult<TradeJournalEntry>>.value(
      _list(
        'journal_30.json',
        TradeJournalEntry.fromJson,
        where: (TradeJournalEntry e) => e.mode == mode,
      ),
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
  _Pusher([this.answer]);

  /// 🆕 R273 — 표 이름 → 답(없음 · null = 성공).
  final ReadModelPushResult? Function(String table)? answer;
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
    return answer?.call(table.name) ??
        ReadModelPushResult.answered(
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
  // 🆕 E11l2c-3
  'rm_performance_series',
  'rm_performance_point',
  'rm_monthly_report',
  'rm_perf_context',
  'rm_journal',
};

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;
  setUp(() => clock = FakeClock(kst(2026, 12, 22, 9, 30)));

  void claim(Database db, int epoch) => db.execute(
    'INSERT INTO sync_state(target, status, operator_epoch, updated_at) VALUES (?, ?, ?, ?)',
    <Object?>[kLeaseSyncTarget, 'OK', epoch, clock.nowUtc().toIso8601String()],
  );

  test('① 원천 = 이 판의 표 정확히(원천 없는 보유 · 안내 · 이행 갭 = 0)', () {
    final Set<String> got = operatorReadModelSources(
      _repos(),
      mode: RunMode.live,
      nowUtc: clock.nowUtc,
    ).keys.toSet();
    expect(got, _thisBoard);
    expect(got, hasLength(17));
    for (final String later in <String>[
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
        sources: operatorReadModelSources(
          _repos(),
          mode: RunMode.live,
          nowUtc: clock.nowUtc,
        ),
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
          ReadModelListCodes.journalWatchTimeline,
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
        nowUtc: clock.nowUtc,
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

  test('⑥ 매개 5표 — 뷰어가 고르는 값 그대로 · 값 하나 실패 = 그 값만 뺌 · 이번 달 기여 = 셸 기본 구간 · 드로다운 기본 = 가장 넓은 프리셋 행', () async {
    _seriesCalls.clear();
    _monthCalls.clear();
    _contribCalls.clear();
    _timelineCalls.clear();
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final _Pusher p = _Pusher();
    final ReadModelPushReport rep = await ReadModelPushJob(
      pusher: p,
      status: SqliteReadModelPushStatus(f.sim),
      sources: operatorReadModelSources(
        _repos(),
        mode: RunMode.live,
        nowUtc: clock.nowUtc,
      ),
      nowUtc: clock.nowUtc,
    ).run(deviceId: 'dev-a', epoch: 2);
    expect(rep.failed, isEmpty, reason: rep.tables.toString());
    final List<Map<String, Object?>> series = _rowsOf(
      p,
      'rm_performance_series',
    );
    final List<Map<String, Object?>> points = _rowsOf(
      p,
      'rm_performance_point',
    );

    // 시리즈 — 조합 12(주별 0) · 두 표가 한 번 읽은 것을 같이 쓴다 · 실패 조합 = 시리즈 · 점 둘 다 0.
    expect(kReadModelSeriesCombos, hasLength(12));
    expect(kReadModelSeriesCombos.map((c) => c.$2).toSet(), <PerfGranularity>{
      PerfGranularity.daily,
      PerfGranularity.monthly,
      PerfGranularity.yearly,
    });
    expect(_seriesCalls, kReadModelSeriesCombos, reason: '조합마다 한 번');
    final Set<String> want = kReadModelSeriesCombos
        .where((c) => c != _badCombo)
        .map((c) => _key(c.$1.wire, c.$2.wire, c.$3))
        .toSet();
    expect(series.map(_keyOf).toSet(), want);
    expect(series, hasLength(11));
    expect(series.first.containsKey('points'), isFalse);
    final int perSeries = PerformanceSeries.fromJson(
      _rows('m7/m7_perf_monthly_period.json').first,
    ).points.length;
    expect(points, hasLength(11 * perSeries));
    expect(points.map(_keyOf).toSet(), want);

    // 월간 — 보관함에서 열리는 달만(route 없음 = 0) · 실패 달 = 그 달만 뺌.
    final List<String> routed =
        ReportArchiveVm.fromJson(_rows('m7/m7_report_archive_18.json').first)
            .rows
            .where((ReportArchiveRow a) => a.route != null)
            .map((a) => a.yyyyMm)
            .toList();
    expect(routed.length, lessThan(18), reason: '표본에 route 없는 달이 있다');
    expect(_monthCalls, routed);
    expect(
      _rowsOf(p, 'rm_monthly_report').map((r) => r['yyyy_mm']).toList(),
      routed.where((String m) => m != _badMonth).toList(),
    );

    // 성과 맥락 — 프리셋마다 기여 · 이번 달 = 셸 기본 구간 · 실패 프리셋 = 행 0 · 드로다운 = 가장 넓은 프리셋 행 하나.
    final List<DateRange> presets = _presets();
    final DateRange widest = presets.reduce(
      (DateRange a, DateRange b) =>
          b.from.yyyyMmDd.compareTo(a.from.yyyyMmDd) <= 0 ? b : a,
    );
    expect(
      _contribCalls.map((DateRange r) => r.presetCode).toList(),
      presets.map((DateRange r) => r.presetCode).toList(),
    );
    final DateRange month = _contribCalls.singleWhere(
      (DateRange r) => r.presetCode == 'THIS_MONTH',
    );
    expect(month.from.yyyyMmDd, '2026-12-01', reason: '셸 기본 구간 = 이번 달 1일');
    expect(
      presets.singleWhere((DateRange r) => r.presetCode == 'THIS_MONTH').from,
      isNot(month.from),
      reason: '표본 프리셋과 다른 값이어야 구분된다',
    );
    final List<Map<String, Object?>> ctx = _rowsOf(p, 'rm_perf_context');
    expect(
      ctx.map((r) => r['range_preset_code']).toList(),
      presets
          .map((DateRange r) => r.presetCode)
          .where((String? c) => c != _badPreset)
          .toList(),
    );
    final Map<String, Object?> def = ctx.singleWhere(
      (r) => r['is_default'] == true,
    );
    expect(def['range_preset_code'], widest.presetCode);
    expect(def['drawdown_period_label'], isNotNull);
    expect(def['contribution_period_label'], isNotNull);
    expect(
      ctx
          .where((r) => r['is_default'] == false)
          .where((r) => r.containsKey('drawdown_period_label')),
      isEmpty,
    );

    // 일지 — 가장 넓은 프리셋 · 상한 · 화면 상태 모드 · 봉투.
    expect(_timelineCalls.single, (
      widest,
      RunMode.live,
      kReadModelUncappedLimit,
    ));
    expect(_rowsOf(p, 'rm_journal'), hasLength(29));
  });

  test('⑥ 기여가 실패해도 가장 넓은 프리셋 행은 드로다운으로 간다', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final _Pusher p = _Pusher();
    final OperatorReadModelRepos r = _repos();
    final ReadModelPushReport rep = await ReadModelPushJob(
      pusher: p,
      status: SqliteReadModelPushStatus(f.sim),
      sources: operatorReadModelSources(
        OperatorReadModelRepos(
          config: _OnlyPresets(<DateRange>[
            // 사용자 지정 구간(코드 없음 · 가장 이름) = 행 0 · 가장 넓은 프리셋 후보도 아님.
            DateRange(
              from: const TradeDate('2020-01-02'),
              to: _presets().first.to,
            ),
            _presets().first.copyWith(presetCode: _badPreset),
          ]),
          settings: r.settings,
          safety: r.safety,
          performance: r.performance,
          ledgerTrust: r.ledgerTrust,
          opsStatus: r.opsStatus,
          opsSummary: r.opsSummary,
          holdings: r.holdings,
          alerts: r.alerts,
          ledger: r.ledger,
          journal: r.journal,
          rebalance: r.rebalance,
        ),
        mode: RunMode.live,
        nowUtc: clock.nowUtc,
      ),
      nowUtc: clock.nowUtc,
    ).run(deviceId: 'dev-a', epoch: 2);
    final ReadModelTablePush ctx = rep.tables.singleWhere(
      (ReadModelTablePush t) => t.table == 'rm_perf_context',
    );
    expect(ctx.outcome, ReadModelPushOutcome.ok);
    final List<Map<String, Object?>> rows = _rowsOf(p, 'rm_perf_context');
    expect(rows, hasLength(1), reason: '기여 실패 · 드로다운 성공 = 기본 행은 간다');
    expect(rows.single['is_default'], isTrue);
    expect(rows.single['drawdown_period_label'], isNotNull);
    expect(rows.single.containsKey('contribution_period_label'), isFalse);
  });

  test('⑤ 창구 값이 오지 않음 = 그 표만 LAG(상한) · 나머지 OK', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final ReadModelPushReport rep = await ReadModelPushJob(
      pusher: _Pusher(),
      status: SqliteReadModelPushStatus(f.sim),
      sources: operatorReadModelSources(
        _repos(watchdogSilent: true),
        mode: RunMode.live,
        nowUtc: clock.nowUtc,
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
    expect(ok, hasLength(_thisBoard.length)); // 워치독 뺀 표 + 봉투
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
    expect(
      _timelineCalls.last.$2,
      RunMode.simInternal,
      reason: '일지 = 화면 상태의 모드로 읽는다',
    );
  });

  test('🆕 ⑦ R273 사람이 볼 실패 = K344 P1(시크릿 · 거부 · 낸 곳 shared_push · 한국 날 한 건) · LAG = 0', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final _Pusher p = _Pusher(
      (String t) => switch (t) {
        'rm_watchdog' => const ReadModelPushResult.answered(
          code: 'READ_MODEL_ROWS_INVALID',
          epoch: 2,
          accepted: 0,
          skipped: 0,
        ),
        'rm_alert' => const ReadModelPushResult.failed(
          ReadModelPushFailure.secretBlocked,
          secretFindings: 1,
        ),
        'rm_ledger_trust' => const ReadModelPushResult.failed(
          ReadModelPushFailure.network,
        ),
        _ => null,
      },
    );
    final OperatorRuntime rt = OperatorRuntime(
      files: f,
      clock: clock,
      readModelPusher: p,
      deviceId: 'dev-a',
    );
    rt.view.value = OperatorView(
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
    claim(f.sim, 2);
    List<(Object?, Object?, Object?)> alerts() => <(Object?, Object?, Object?)>[
      for (final row in f.sim.select(
        'SELECT code, level, source FROM alert_event ORDER BY code',
      ))
        (row['code'], row['level'], row['source']),
    ];
    final ReadModelPushReport? rep = await runOperatorReadModelPush(
      rt: rt,
      repos: _repos(),
      wait: const Duration(seconds: 2),
    );
    expect(rep!.failed.map((ReadModelTablePush t) => t.table).toSet(), <String>{
      'rm_watchdog',
      'rm_alert',
    });
    expect(alerts(), <(Object?, Object?, Object?)>[
      (AlertCodes.readModelPushRejected, 'P1', kSharedPushAlertSource),
      (AlertCodes.readModelPushSecretBlocked, 'P1', kSharedPushAlertSource),
    ]);
    await runOperatorReadModelPush(
      rt: rt,
      repos: _repos(),
      wait: const Duration(seconds: 2),
    );
    expect(alerts(), hasLength(2), reason: '같은 한국 날 · 같은 낸 곳 = 새 행 0');
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
  // ───── 🆕 미결 242(설계 13 §8 R275 · 01 §48 K339~K341) ─────

  List<Object?> col(List<Map<String, Object?>> rows, String c) => <Object?>[
    for (final Map<String, Object?> r in rows) r[c],
  ];

  List<int> oneTo(int n) => <int>[for (int i = 1; i <= n; i++) i];

  test(
    '⑧ 목록 열 — 차례 = 기본 호출의 엔진 차례 그대로 · 1부터 · 상한 없이 · 프리셋 · 봉투 빈 문장 2(일지만)',
    () async {
      _timelineCalls.clear();
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      final _Pusher p = _Pusher();
      final ReadModelPushReport rep = await ReadModelPushJob(
        pusher: p,
        status: SqliteReadModelPushStatus(f.sim),
        sources: operatorReadModelSources(
          _repos(),
          mode: RunMode.live,
          nowUtc: clock.nowUtc,
        ),
        nowUtc: clock.nowUtc,
        mode: RunMode.live,
      ).run(deviceId: 'dev-a', epoch: 2);
      expect(rep.failed, isEmpty, reason: rep.tables.toString());

      // 회차 · 알림 · 원장 차이 · blind · 일지 = 창구 차례 그대로 1..n.
      final List<Map<String, Object?>> ev = _rowsOf(p, 'rm_rebalance_event');
      expect(col(ev, 'events_rank'), oneTo(ev.length));
      expect(
        col(ev, 'event_id'),
        _rows('rebalance_6.json')
            .map((Map<String, Object?> r) => r['event_id']),
      );
      final List<Map<String, Object?>> al = _rowsOf(p, 'rm_alert');
      expect(col(al, 'inbox_rank'), oneTo(12));
      expect(
        col(al, 'alert_id'),
        _rows('alerts_12.json').map((Map<String, Object?> r) => r['alert_id']),
      );
      expect(col(_rowsOf(p, 'rm_ledger_diff'), 'open_diffs_rank'), oneTo(4));
      expect(col(_rowsOf(p, 'rm_blind_review'), 'queue_rank'), oneTo(3));
      final List<Map<String, Object?>> jr = _rowsOf(p, 'rm_journal');
      expect(col(jr, 'timeline_rank'), oneTo(jr.length));
      expect(jr, hasLength(29));
      // 일지 = 기본 호출(무필터 · 전 기간) · 상한 없이(R268 D5 2000 걷음).
      expect(_timelineCalls.single.$3, kReadModelUncappedLimit);
      expect(kReadModelUncappedLimit, greaterThan(1 << 30));

      // 시리즈 점 = 시리즈마다 1..점 수(엔진 차례 = 날짜 오름차순).
      final List<Map<String, Object?>> pts = _rowsOf(p, 'rm_performance_point');
      final Map<String, List<Map<String, Object?>>> bySeries =
          <String, List<Map<String, Object?>>>{};
      for (final Map<String, Object?> r in pts) {
        (bySeries[_keyOf(r)] ??= <Map<String, Object?>>[]).add(r);
      }
      expect(bySeries, hasLength(11));
      for (final List<Map<String, Object?>> s in bySeries.values) {
        expect(col(s, 'series_rank'), oneTo(24));
        final List<String> dates = <String>[
          for (final Map<String, Object?> r in s) r['date']! as String,
        ];
        expect(dates, List<String>.of(dates)..sort());
      }

      // 원천 없는 표(보유 · 안내) = 보내지 않으니 차례 열도 0.
      expect(p.calls.map((c) => c.$1), isNot(contains('rm_holding')));
      expect(p.calls.map((c) => c.$1), isNot(contains('rm_advice')));

      // 기간 프리셋 = 엔진 차례 그대로(DateRange.toJson()).
      final Map<String, Object?> cfg = _rowsOf(p, 'rm_config_view').single;
      expect(
        jsonEncode(cfg['range_presets']),
        jsonEncode(<Object?>[for (final DateRange r in _presets()) r.toJson()]),
      );

      // 봉투 — 일지만 빈 문장 2(엔진 글자) · 나머지 null.
      final List<Map<String, Object?>> env = _rowsOf(p, 'rm_list_envelope');
      for (final Map<String, Object?> e in env) {
        final bool journal =
            e['list_code'] == ReadModelListCodes.journalWatchTimeline;
        expect(
          e['filtered_empty_label'],
          journal ? JournalTexts.filteredEmpty : isNull,
          reason: '${e['list_code']}',
        );
        expect(
          e['scope_empty_label'],
          journal ? JournalTexts.rebalanceEmpty : isNull,
          reason: '${e['list_code']}',
        );
      }
      expect(JournalTexts.filteredEmpty, '조건에 맞는 기록이 없습니다');
      expect(JournalTexts.rebalanceEmpty, '이 회차에 묶인 기록이 없습니다');
    },
  );

  test(
    '⑧ 원장 차이 = 상한 없는 판(allDiffs)이 있으면 그것 · 프리셋 못 읽음 = range_presets 만 null',
    () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      final _Pusher p = _Pusher();
      final ListResult<LedgerDiffRow> four = _list(
        'ledger_diffs_4.json',
        LedgerDiffRow.fromJson,
      );
      final List<LedgerDiffRow> many = <LedgerDiffRow>[
        for (int i = 0; i < 60; i++)
          four.rows[i % 4].copyWith(
            diffId: 'all_${i.toString().padLeft(2, '0')}',
          ),
      ];
      final OperatorReadModelRepos r = _repos();
      final ReadModelPushReport rep = await ReadModelPushJob(
        pusher: p,
        status: SqliteReadModelPushStatus(f.sim),
        sources: operatorReadModelSources(
          OperatorReadModelRepos(
            config: _FlakyPresets(),
            settings: r.settings,
            safety: r.safety,
            performance: r.performance,
            ledgerTrust: r.ledgerTrust,
            opsStatus: r.opsStatus,
            opsSummary: r.opsSummary,
            holdings: r.holdings,
            alerts: r.alerts,
            ledger: r.ledger,
            journal: r.journal,
            rebalance: r.rebalance,
            allDiffs: () => ListResult<LedgerDiffRow>(
              rows: many,
              asOf: four.asOf,
              emptyKind: four.emptyKind,
              hasMore: false,
            ),
          ),
          mode: RunMode.live,
          nowUtc: clock.nowUtc,
        ),
        nowUtc: clock.nowUtc,
      ).run(deviceId: 'dev-a', epoch: 2);
      final List<Map<String, Object?>> d = _rowsOf(p, 'rm_ledger_diff');
      expect(d, hasLength(60), reason: '화면 창구 상한 50 없이');
      expect(col(d, 'open_diffs_rank'), oneTo(60));
      expect(col(d, 'diff_id').first, 'all_00');
      final Map<String, Object?> cfg = _rowsOf(p, 'rm_config_view').single;
      expect(
        rep.tables.singleWhere((t) => t.table == 'rm_config_view').outcome,
        ReadModelPushOutcome.ok,
      );
      expect(cfg['range_presets'], isNull);
      expect(cfg['operating_mode'], OperatingMode.autoTrade.wire);
    },
  );

  test('⑧ 조립 배선 — operator 판 원장 저장소 = 상한 없는 판(allDiffs)을 같이 단다', () {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final ProviderContainer c = ProviderContainer(
      overrides: operatorShellOverrides(
        OperatorRuntime(files: f, clock: clock),
      ),
    );
    addTearDown(c.dispose);
    final OperatorReadModelRepos r = operatorReadModelReposOf(c);
    expect(r.ledger, isA<SqliteLedgerRepository>());
    expect(r.allDiffs, isNotNull);
    expect(r.allDiffs!().rows, isEmpty);
    expect(_repos().allDiffs, isNull, reason: '다른 판 = 창구 그대로');
  });

  test('⑨ 시리즈 점 D7 — 기본 구간이 옮겨 가면 밖으로 밀린 옛 점 = 같은 키 · 차례 null 로 한 번 · 못 읽은 조합의 옛 점 = 그대로', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final SqliteReadModelPushStatus st = SqliteReadModelPushStatus(f.sim);
    final _Shifting perf = _Shifting();
    final OperatorReadModelRepos r = _repos();
    OperatorReadModelRepos repos() => OperatorReadModelRepos(
      config: r.config,
      settings: r.settings,
      safety: r.safety,
      performance: perf,
      ledgerTrust: r.ledgerTrust,
      opsStatus: r.opsStatus,
      opsSummary: r.opsSummary,
      holdings: r.holdings,
      alerts: r.alerts,
      ledger: r.ledger,
      journal: r.journal,
      rebalance: r.rebalance,
    );
    Future<_Pusher> push() async {
      final _Pusher p = _Pusher();
      final ReadModelPushReport rep = await ReadModelPushJob(
        pusher: p,
        status: st,
        sources: operatorReadModelSources(
          repos(),
          mode: RunMode.live,
          nowUtc: clock.nowUtc,
        ),
        nowUtc: clock.nowUtc,
        mode: RunMode.live,
      ).run(deviceId: 'dev-a', epoch: 2);
      expect(rep.failed, isEmpty, reason: rep.tables.toString());
      return p;
    }

    final List<Map<String, Object?>> first = _rowsOf(
      await push(),
      'rm_performance_point',
    );
    expect(first, hasLength(11 * 24));
    // 둘째 깨어남 — 일별 기본 구간 = 이번 달(앞 두 점이 밖) · 일별 조합 하나는 이번에 못 읽음.
    perf.shifted = true;
    final List<Map<String, Object?>> second = _rowsOf(
      await push(),
      'rm_performance_point',
    );
    final List<Map<String, Object?>> nulls = <Map<String, Object?>>[
      for (final Map<String, Object?> x in second)
        if (x['series_rank'] == null) x,
    ];
    // 일별 3조합(못 읽은 하나 · 늘 실패하는 연별 하나 빼고) × 밀린 두 점.
    expect(nulls, hasLength(3 * 2));
    expect(nulls.map(_keyOf).toSet(), <String>{
      for (final (PerfMetric, PerfGranularity, bool) c
          in kReadModelSeriesCombos)
        if (c.$2 == PerfGranularity.daily && c != _flaky)
          _key(c.$1.wire, c.$2.wire, c.$3),
    });
    expect(nulls.map((Map<String, Object?> x) => x['date']).toSet(), <Object?>{
      '2024-09-30',
      '2024-10-31',
    });
    expect(
      nulls.every(
        (Map<String, Object?> x) => (x['row_version']! as int) > (2 << 40) + 1,
      ),
      isTrue,
      reason: '큰 판',
    );
    expect(
      second.where(
        (Map<String, Object?> x) =>
            _keyOf(x) == _key(_flaky.$1.wire, _flaky.$2.wire, _flaky.$3),
      ),
      isEmpty,
      reason: '못 읽은 조합 = 그 옛 점 차례를 지우지 않는다',
    );
    // 남은 일별 점 = 1..22 로 다시 매김.
    final List<Object?> daily = <Object?>[
      for (final Map<String, Object?> x in second)
        if (x['series_rank'] != null &&
            _keyOf(x) ==
                _key(PerfMetric.mwr.wire, PerfGranularity.daily.wire, true))
          x['series_rank'],
    ];
    expect(daily, oneTo(22));
    // 셋째 — 못 읽은 조합이 돌아오면 그 옛 두 점만 null · 앞서 null 로 보낸 점은 다시 안 보냄.
    perf.flakyDown = false;
    final List<Map<String, Object?>> third = _rowsOf(
      await push(),
      'rm_performance_point',
    );
    final List<Map<String, Object?>> nulls3 = <Map<String, Object?>>[
      for (final Map<String, Object?> x in third)
        if (x['series_rank'] == null) x,
    ];
    expect(nulls3, hasLength(2));
    expect(nulls3.map(_keyOf).toSet(), <String>{
      _key(_flaky.$1.wire, _flaky.$2.wire, _flaky.$3),
    });
  });
}
