// 🆕 E11l2c-2 — 읽기 모델 push 원천 배선 · 깨어남 뒤 실행(설계 13 §8 R264 · 01 §8 미결 241 ⓐ ⓒ · 06 M4-1).
//
// 🔵 원천 = 화면과 같은 창구(루트 컨테이너의 공급자) · 한 번 = 각 창구의 지금 값 하나(`first` · 상한 [kReadModelSourceWait]) →
//    data_sync `ReadModelPushJob`(판 · 나눠 보내기 · 상태) → `SupabaseReadModelPush`(시크릿 관문).
// 🔴 E11l2c-2 = 매개 없는 창구 12표 + 봉투 4목록(안전 · 설정 보기 · 공시 게이트 · 신뢰 · 워치독 · 홈 + 리듬 · 배분 · 알림 · 원장 차이 ·
//    보관함 · blind 큐 · 회차 + 범위) · 🆕 E11l2c-3(R268) = 매개 5표 — 매개 값 = 뷰어가 고르는 값 그대로:
//    성과 시리즈 + 점 = 화면이 고르는 조합 12(지표 2 × 주기 3(주별 = 화면 0 · 원천 없음) × 누적 2 · 엔진 기본 구간) ·
//    월간 리포트 = 보관함에서 열리는 달(`route` 있는 행 — 안내 모드 · 옛 모의 달 = 0) · 성과 맥락 = 기간 프리셋마다 기여
//    (이번 달 = 셸 기본 구간 `contributionDefaultRange`) + 드로다운 엔진 기본(운용 전체) = 가장 넓은 프리셋 행(`is_default`) ·
//    일지 = 가장 넓은 프리셋 · 상한 [kReadModelJournalLimit] + 봉투.
//    매개 값 하나의 원천 실패 = 그 값만 뺀다(폰 화면도 그 값은 오류 · 표는 OK — 첫 마감 전 기여처럼 고칠 수 없는 지연을 LAG 로 띄우지 않는다).
//    원천 없는 표(보유 행 · 안내 셋 · 이행 갭) = 보내지 않는다.
// 🔴 리스 = 이 기기 id + 그 원장의 SUPABASE epoch(0 = 안 보낸다 — 모의 내부 · 첫 클레임 전) · 겹침 0(앞 push 가 끝나기 전 깨어남 = 건너뜀).
// 🔴 행의 mode = 화면 상태의 실행 모드(`flags.runMode`) — DTO 의 mode 와 다르면 빌더가 그 표를 거부한다(PUSH_FAILED).
// 🆕 미결 243 ⓒ(설계 13 §8 R273) — 사람이 볼 실패 = K344 P1 경보(낸 곳 `shared_push` · op_push 와 공용 · 한국 날 · 코드마다 한 건).
// 🆕 미결 242(설계 13 §8 R275 · 01 §48 K339~K341) — 목록 열 채우기:
//    ⓐ 차례 열 = 그 창구 **기본 호출**(필터 · 구간 인자 없음)의 엔진 차례 그대로 · 1부터 · 상한 없이 — 일지 `timeline_rank`
//       (전 기간 · 무필터 · 🔴 R268 D5 상한 2000 걷음) · 회차 `events_rank` · 알림 `inbox_rank`(min 없음) · 원장 차이
//       `open_diffs_rank`(상한 50 없이 — operator 판 [OperatorReadModelRepos.allDiffs]) · blind `queue_rank` · 시리즈 점
//       `series_rank`(그 시리즈 기본 구간의 점 차례 · 엔진 차례 = 날짜 오름차순).
//       원천 없는 표(보유 `holdings_rank` · 안내 `inbox_rank` · `history_rank`) = 보내지 않으니 열도 0.
//    ⓑ 목록에서 빠진 행(시간으로 빠짐 포함) = data_sync push 일이 직전 소속(로컬)으로 차례 null 을 다시 보낸다 — 여기서는
//       원천을 못 읽은 범위만 알린다(`unread` · 실패 시리즈 조합 · 프리셋 0 일지).
//    ⓒ 봉투 `filtered_empty_label` · `scope_empty_label` = 일지만(`JournalTexts.filteredEmpty` · `rebalanceEmpty`).
//    ⓓ `rm_config_view.range_presets` = 기간 프리셋 엔진 차례(`DateRange.toJson()`) · 못 읽음 = 그 열만 null(배분 열과 같다).

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show JournalTexts, contributionDefaultRange, kContributionDefaultPreset;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_journal/ui_journal.dart'
    show journalLedgerRepositoryProvider;
import 'package:ui_shell/ui_shell.dart'
    show shellAlertRepositoryProvider, shellConfigRepositoryProvider;

import 'operator_ops_summary.dart' show OperatorLedgerTrustRepository;
import 'operator_runtime.dart';
import 'operator_shell.dart';
import 'operator_view.dart';

/// 창구 값 하나를 기다리는 상한(넘으면 그 표 = 다음 깨어남에 다시).
const Duration kReadModelSourceWait = Duration(seconds: 10);

/// 🆕 E11l2c-3 — 성과 시리즈 조합(화면 `S7-2` 가 고르는 값 그대로 · 주별 = 화면 0 · 원천 없음).
final List<(PerfMetric, PerfGranularity, bool)> kReadModelSeriesCombos =
    List<(PerfMetric, PerfGranularity, bool)>.unmodifiable(
      <(PerfMetric, PerfGranularity, bool)>[
        for (final PerfMetric m in PerfMetric.values)
          for (final PerfGranularity g in <PerfGranularity>[
            PerfGranularity.daily,
            PerfGranularity.monthly,
            PerfGranularity.yearly,
          ])
            for (final bool c in <bool>[true, false]) (m, g, c),
      ],
    );

/// 🆕 미결 242(R275 · K339 «상한 없이») — 목록 창구 `limit` 인자에 넣는 «상한 없음»(일지 연 ~934건 — 닿을 일 없는 끝값) ·
/// R268 D5 의 일지 상한 2000 을 걷는다(차례 열 = 기본 호출의 차례 전부 · 뷰어 limit+1).
const int kReadModelUncappedLimit = 1 << 31;

/// push 원천 창구 묶음(화면과 같은 인스턴스).
class OperatorReadModelRepos {
  /// 만든다.
  const OperatorReadModelRepos({
    required this.config,
    required this.settings,
    required this.safety,
    required this.performance,
    required this.ledgerTrust,
    required this.opsStatus,
    required this.opsSummary,
    required this.holdings,
    required this.alerts,
    required this.ledger,
    required this.journal,
    required this.rebalance,
    this.allDiffs,
  });

  /// 플래그 · 월 납입 · 슬리브.
  final ConfigRepository config;

  /// 배분 편집.
  final SettingsRepository settings;

  /// 안전 상태.
  final SafetyRepository safety;

  /// 공시 게이트 · 보관함.
  final PerformanceRepository performance;

  /// 신뢰 등급.
  final LedgerTrustRepository ledgerTrust;

  /// 워치독.
  final OpsStatusRepository opsStatus;

  /// 홈 오늘 · 리듬.
  final OpsSummaryRepository opsSummary;

  /// 배분 막대.
  final HoldingsRepository holdings;

  /// 알림.
  final AlertRepository alerts;

  /// 원장 차이.
  final LedgerRepository ledger;

  /// blind 큐 · 회차 범위.
  final JournalRepository journal;

  /// 회차.
  final RebalanceRepository rebalance;

  /// 🆕 미결 242(R275) — 원장 차이 목록 전부(화면 창구 상한 50 없이 · operator 판 `SqliteLedgerRepository.recentDiffsAll`) ·
  /// null = [ledger] 창구 그대로.
  final ListResult<LedgerDiffRow> Function()? allDiffs;
}

/// 루트 컨테이너 → 창구 묶음(`operatorShellOverrides` 가 깐 것 그대로).
OperatorReadModelRepos operatorReadModelReposOf(ProviderContainer c) {
  final LedgerRepository ledger = c.read(journalLedgerRepositoryProvider);
  return OperatorReadModelRepos(
    config: c.read(shellConfigRepositoryProvider),
    settings: c.read(operatorSettingsRepositoryProvider),
    safety: c.read(operatorSafetyProvider),
    performance: c.read(operatorPerformanceProvider),
    ledgerTrust: OperatorLedgerTrustRepository(
      selfReport: c.read(operatorSelfReportProvider),
    ),
    opsStatus: c.read(operatorOpsStatusProvider),
    opsSummary: c.read(operatorOpsSummaryProvider),
    holdings: c.read(operatorHoldingsProvider),
    alerts: c.read(shellAlertRepositoryProvider),
    ledger: ledger,
    journal: c.read(operatorJournalProvider),
    rebalance: c.read(operatorRebalanceProvider),
    allDiffs: ledger is SqliteLedgerRepository ? ledger.recentDiffsAll : null,
  );
}

ReadModelEnvelopeDraft _env<T>(
  RunMode mode,
  String code,
  ListResult<T> r, {
  String? filteredEmptyLabel,
  String? scopeEmptyLabel,
}) => ReadModelEnvelopeDraft(
  mode: mode,
  listCode: code,
  asOf: r.asOf.toJson(),
  emptyKind: r.emptyKind,
  emptyLabel: r.emptyLabel,
  filteredEmptyLabel: filteredEmptyLabel,
  scopeEmptyLabel: scopeEmptyLabel,
);

/// 🆕 미결 242(R275) — 차례 열 값 하나(목록 차례 [i] = 0부터 → 1부터).
Map<String, Object?> _rank(String column, int i) => <String, Object?>{
  column: i + 1,
};

/// 🆕 미결 242(R275) — 한 번 읽은 시리즈 · 못 읽은 조합.
typedef _SeriesRead = ({
  List<PerformanceSeries> series,
  List<(PerfMetric, PerfGranularity, bool)> failed,
});

/// 매개 값 하나 — 실패(오류 · 상한) = null(그 값만 뺀다).
Future<T?> _orSkip<T>(Future<T> f) async {
  try {
    return await f;
  } on Object {
    return null;
  }
}

/// 가장 넓은 프리셋(시작이 가장 이른 · 같으면 뒤 — 프리셋 코드 없는 = 사용자 지정 · 뺀다).
DateRange? _widest(List<DateRange> presets) {
  DateRange? best;
  for (final DateRange p in presets) {
    if (p.presetCode == null) continue;
    if (best == null || p.from.yyyyMmDd.compareTo(best.from.yyyyMmDd) <= 0) {
      best = p;
    }
  }
  return best;
}

/// 표 이름 → 원천(매개 없는 12표 · 🆕 매개 5표 · 봉투 = 회차 · 원장 차이 · blind 큐 · 리듬 · 🆕 일지).
Map<String, ReadModelSnapshotSource> operatorReadModelSources(
  OperatorReadModelRepos r, {
  required RunMode mode,
  required DateTime Function() nowUtc,
  Duration wait = kReadModelSourceWait,
}) {
  Future<T> one<T>(Stream<T> s) => s.first.timeout(wait);
  Future<_SeriesRead>? seriesMemo;
  // 시리즈 + 점 두 표가 한 번 읽은 시리즈를 같이 쓴다(조합마다 한 번 · 차례대로).
  Future<_SeriesRead> allSeries() => seriesMemo ??= () async {
    final List<PerformanceSeries> out = <PerformanceSeries>[];
    final List<(PerfMetric, PerfGranularity, bool)> failed =
        <(PerfMetric, PerfGranularity, bool)>[];
    for (final (PerfMetric m, PerfGranularity g, bool c)
        in kReadModelSeriesCombos) {
      final PerformanceSeries? s = await _orSkip(
        r.performance
            .series(metric: m, granularity: g, cumulative: c)
            .timeout(wait),
      );
      if (s != null) {
        out.add(s);
      } else {
        failed.add((m, g, c));
      }
    }
    return (series: out, failed: failed);
  }();
  ReadModelRowInput row(
    Map<String, Map<String, Object?>> dtos, {
    Map<String, Object?> extras = const <String, Object?>{},
    Map<String, Object?> list = const <String, Object?>{},
  }) => ReadModelRowInput(
    mode: mode,
    rowVersion: 0,
    dtos: dtos,
    extras: extras,
    list: list,
  );
  return <String, ReadModelSnapshotSource>{
    ReadModelTables.rebalanceEvent.name: () async {
      final ListResult<RebalanceEvent> ev = await one(
        r.rebalance.watchEvents(),
      );
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          for (final (int i, RebalanceEvent e) in ev.rows.indexed)
            row(<String, Map<String, Object?>>{
              'RebalanceEvent': e.toJson(),
              if (await one(r.journal.watchRebalanceScope(e.eventId))
                  case final JournalRebalanceScope s)
                'JournalRebalanceScope': s.toJson(),
            }, list: _rank('events_rank', i)),
        ],
        envelopes: <ReadModelEnvelopeDraft>[
          _env(mode, ReadModelListCodes.rebalanceWatchEvents, ev),
        ],
      );
    },
    ReadModelTables.alert.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        for (final (int i, AlertItem a) in (await one(
          r.alerts.watchInbox(),
        )).indexed)
          row(<String, Map<String, Object?>>{
            'AlertItem': a.toJson(),
          }, list: _rank('inbox_rank', i)),
      ],
    ),
    ReadModelTables.safetyState.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        row(<String, Map<String, Object?>>{
          'SafetyState': (await one(r.safety.watchState())).toJson(),
        }),
      ],
    ),
    ReadModelTables.configView.name: () async {
      Map<String, Object?>? allocation;
      try {
        allocation = (await one(r.settings.watchAllocationEditor())).toJson();
      } on Object {
        allocation = null; // 운영 설정을 못 읽음 — 배분 열만 비운다(뷰어 = 그 부분 «못 읽음»).
      }
      // 🆕 미결 242 ⓓ(K341) — 기간 프리셋 엔진 차례 · 못 읽음 = 그 열만 null(아직 안 채움과 같다).
      final List<DateRange>? presets = await _orSkip(
        one(r.config.watchRangePresets()),
      );
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          row(
            <String, Map<String, Object?>>{
              'FeatureFlags': (await one(r.config.watchFlags())).toJson(),
              'ContributionSetting': (await one(
                r.config.watchContributionSetting(),
              )).toJson(),
              'AllocationEditorVm': ?allocation,
            },
            extras: <String, Object?>{
              'sleeve_catalog': <Object?>[
                for (final SleeveCatalogEntry s in await one(
                  r.config.watchSleeves(),
                ))
                  s.toJson(),
              ],
            },
            list: <String, Object?>{
              'range_presets': presets == null
                  ? null
                  : <Object?>[for (final DateRange p in presets) p.toJson()],
            },
          ),
        ],
      );
    },
    ReadModelTables.reportArchive.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        row(<String, Map<String, Object?>>{
          'ReportArchiveVm': (await r.performance.reportArchive().timeout(wait))
              .toJson(),
        }),
      ],
    ),
    ReadModelTables.ledgerDiff.name: () async {
      final ListResult<LedgerDiffRow> d =
          r.allDiffs?.call() ?? await one(r.ledger.watchOpenDiffs());
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          for (final (int i, LedgerDiffRow x) in d.rows.indexed)
            row(<String, Map<String, Object?>>{
              'LedgerDiffRow': x.toJson(),
            }, list: _rank('open_diffs_rank', i)),
        ],
        envelopes: <ReadModelEnvelopeDraft>[
          _env(mode, ReadModelListCodes.ledgerWatchOpenDiffs, d),
        ],
      );
    },
    ReadModelTables.sleeveAllocation.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        row(<String, Map<String, Object?>>{
          'SleeveAllocationVm': (await one(r.holdings.watchAllocation()))
              .toJson(),
        }),
      ],
    ),
    ReadModelTables.disclosureView.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        row(<String, Map<String, Object?>>{
          'DisclosureGateVm': (await one(r.performance.watchDisclosureGate()))
              .toJson(),
        }),
      ],
    ),
    ReadModelTables.opsSummary.name: () async {
      final ListResult<OpsRhythmRow> rhythm = await one(
        r.opsSummary.watchRhythm(),
      );
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          row(
            <String, Map<String, Object?>>{
              'OpsDailySummary': (await one(r.opsSummary.watchToday()))
                  .toJson(),
            },
            extras: <String, Object?>{
              'rhythm': <Object?>[
                for (final OpsRhythmRow x in rhythm.rows) x.toJson(),
              ],
            },
          ),
        ],
        envelopes: <ReadModelEnvelopeDraft>[
          _env(mode, ReadModelListCodes.opsStatusWatchRhythm, rhythm),
        ],
      );
    },
    ReadModelTables.ledgerTrust.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        row(<String, Map<String, Object?>>{
          'LedgerTrustBadge': (await one(r.ledgerTrust.watchGrade())).toJson(),
        }),
      ],
    ),
    ReadModelTables.blindReview.name: () async {
      final ListResult<BlindReviewCard> q = await one(
        r.journal.watchBlindReviewQueue(mode: mode),
      );
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          for (final (int i, BlindReviewCard c) in q.rows.indexed)
            row(<String, Map<String, Object?>>{
              'BlindReviewCard': c.toJson(),
            }, list: _rank('queue_rank', i)),
        ],
        envelopes: <ReadModelEnvelopeDraft>[
          _env(mode, ReadModelListCodes.journalWatchBlindReviewQueue, q),
        ],
      );
    },
    ReadModelTables.watchdog.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        row(<String, Map<String, Object?>>{
          'WatchdogBoardVm': (await one(r.opsStatus.watchWatchdog())).toJson(),
        }),
      ],
    ),
    // ───── 🆕 E11l2c-3(R268) — 매개 5표 ─────
    ReadModelTables.performanceSeries.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        for (final PerformanceSeries s in (await allSeries()).series)
          row(<String, Map<String, Object?>>{'PerformanceSeries': s.toJson()}),
      ],
    ),
    // 🆕 미결 242 ⓔ — 점 차례 = 그 시리즈 기본 구간의 엔진 차례(날짜 오름차순) · 구간 밖 옛 점 = push 일이 null 로 ·
    // 이번에 못 읽은 조합 = `unread`(그 조합의 옛 점 차례는 그대로 둔다).
    ReadModelTables.performancePoint.name: () async {
      final _SeriesRead s = await allSeries();
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          for (final PerformanceSeries x in s.series)
            for (final (int i, PerfPoint p) in x.points.indexed)
              row(
                <String, Map<String, Object?>>{'PerfPoint': p.toJson()},
                extras: <String, Object?>{
                  'metric': x.metric.wire,
                  'granularity': x.granularity.wire,
                  'cumulative': x.cumulative,
                },
                list: _rank('series_rank', i),
              ),
        ],
        unread: <Map<String, Object?>>[
          for (final (PerfMetric m, PerfGranularity g, bool c) in s.failed)
            <String, Object?>{
              'metric': m.wire,
              'granularity': g.wire,
              'cumulative': c,
            },
        ],
      );
    },
    ReadModelTables.monthlyReport.name: () async {
      final ReportArchiveVm archive = await r.performance
          .reportArchive()
          .timeout(wait);
      final List<ReadModelRowInput> rows = <ReadModelRowInput>[];
      for (final ReportArchiveRow a in archive.rows) {
        if (a.route == null) continue; // 열리지 않는 달(안내 모드 · 옛 모의 달) = 원천 없음
        final MonthlyReport? m = await _orSkip(
          r.performance.monthlyReport(a.yyyyMm).timeout(wait),
        );
        if (m != null) {
          rows.add(
            row(<String, Map<String, Object?>>{'MonthlyReport': m.toJson()}),
          );
        }
      }
      return ReadModelSnapshot(rows: rows);
    },
    ReadModelTables.perfContext.name: () async {
      final List<DateRange> presets = await one(r.config.watchRangePresets());
      final DateRange? whole = _widest(presets);
      final DrawdownContextVm? dd = await _orSkip(
        r.performance.drawdownContext().timeout(wait),
      );
      final List<ReadModelRowInput> rows = <ReadModelRowInput>[];
      for (final DateRange p in presets) {
        final String? code = p.presetCode;
        if (code == null) continue;
        // 이번 달 = 셸이 넘기는 기본 구간(같은 코드 · 폰 기본 화면과 같은 값).
        final DateRange range = code == kContributionDefaultPreset
            ? contributionDefaultRange(nowUtc())
            : p;
        final ContributionVm? c = await _orSkip(
          r.performance.contribution(range: range).timeout(wait),
        );
        final bool isDefault = identical(p, whole);
        if (c == null && !(isDefault && dd != null)) continue;
        rows.add(
          row(
            <String, Map<String, Object?>>{
              'ContributionVm': ?c?.toJson(),
              if (isDefault) 'DrawdownContextVm': ?dd?.toJson(),
            },
            extras: <String, Object?>{
              'range_preset_code': code,
              'is_default': isDefault,
            },
          ),
        );
      }
      return ReadModelSnapshot(rows: rows);
    },
    ReadModelTables.journal.name: () async {
      final DateRange? whole = _widest(await one(r.config.watchRangePresets()));
      if (whole == null) {
        // 프리셋 0 = 원천 없음 — 직전 소속 차례를 지우지 않는다(표 전체 = 못 읽음).
        return const ReadModelSnapshot(
          unread: <Map<String, Object?>>[<String, Object?>{}],
        );
      }
      // 🆕 미결 242 ⓐ — 기본 호출(무필터 · 전 기간) · 상한 없이 → 차례 = 엔진 차례 그대로.
      final ListResult<TradeJournalEntry> j = await one(
        r.journal.watchTimeline(
          range: whole,
          mode: mode,
          limit: kReadModelUncappedLimit,
        ),
      );
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          for (final (int i, TradeJournalEntry e) in j.rows.indexed)
            row(<String, Map<String, Object?>>{
              'TradeJournalEntry': e.toJson(),
            }, list: _rank('timeline_rank', i)),
        ],
        envelopes: <ReadModelEnvelopeDraft>[
          // 🆕 미결 242 ⓒ(K340) — 엔진 빈 문장 차례 = 회차 필터 → 전체 빔(`empty_label`) → 필터.
          _env(
            mode,
            ReadModelListCodes.journalWatchTimeline,
            j,
            filteredEmptyLabel: JournalTexts.filteredEmpty,
            scopeEmptyLabel: JournalTexts.rebalanceEmpty,
          ),
        ],
      );
    },
  };
}

/// 🆕 한 번 push(화면 상태 · 리스 · 포트가 다 있을 때만 · 없으면 null).
Future<ReadModelPushReport?> runOperatorReadModelPush({
  required OperatorRuntime rt,
  required OperatorReadModelRepos repos,
  Duration wait = kReadModelSourceWait,
}) async {
  final ReadModelPusher? pusher = rt.readModelPusher;
  final OperatorView? v = rt.view.value;
  if (pusher == null || v == null) return null;
  final RunMode mode = v.flags.runMode;
  final int epoch = SqliteLeaseGate(v.db, mode: mode, clock: rt.clock).epoch();
  final ReadModelPushReport report = await ReadModelPushJob(
    pusher: pusher,
    status: SqliteReadModelPushStatus(v.db),
    sources: operatorReadModelSources(
      repos,
      mode: mode,
      nowUtc: rt.clock.nowUtc,
      wait: wait,
    ),
    nowUtc: rt.clock.nowUtc,
    mode: mode,
  ).run(deviceId: rt.deviceId, epoch: epoch);
  final Set<String> alerts = sharedPushAlertCodes(readModels: report.tables);
  if (alerts.isNotEmpty) {
    await SqliteAlertSink(
      v.db,
      clock: rt.clock,
    ).emit(kSharedPushAlertSource, alerts);
  }
  return report;
}
