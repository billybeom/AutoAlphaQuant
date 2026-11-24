// 🆕 E11l2c-2 — 읽기 모델 push 원천 배선 · 깨어남 뒤 실행(설계 13 §8 R264 · 01 §8 미결 241 ⓐ ⓒ · 06 M4-1).
//
// 🔵 원천 = 화면과 같은 창구(루트 컨테이너의 공급자) · 한 번 = 각 창구의 지금 값 하나(`first` · 상한 [kReadModelSourceWait]) →
//    data_sync `ReadModelPushJob`(판 · 나눠 보내기 · 상태) → `SupabaseReadModelPush`(시크릿 관문).
// 🔴 이 판 = 매개 없는 창구 12표 + 봉투 4목록(안전 · 설정 보기 · 공시 게이트 · 신뢰 · 워치독 · 홈 + 리듬 · 배분 · 알림 · 원장 차이 · 보관함 ·
//    blind 큐 · 회차 + 범위). 구간 · 조합 · 달을 골라야 하는 표(일지 · 성과 시리즈 · 월간 리포트 · 드로다운/기여)는 E11l2c-3 ·
//    원천 없는 표(보유 행 · 안내 셋 · 이행 갭) = 보내지 않는다.
// 🔴 리스 = 이 기기 id + 그 원장의 SUPABASE epoch(0 = 안 보낸다 — 모의 내부 · 첫 클레임 전) · 겹침 0(앞 push 가 끝나기 전 깨어남 = 건너뜀).
// 🔴 행의 mode = 화면 상태의 실행 모드(`flags.runMode`) — DTO 의 mode 와 다르면 빌더가 그 표를 거부한다(PUSH_FAILED).

import 'dart:async';

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
}

/// 루트 컨테이너 → 창구 묶음(`operatorShellOverrides` 가 깐 것 그대로).
OperatorReadModelRepos operatorReadModelReposOf(ProviderContainer c) =>
    OperatorReadModelRepos(
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
      ledger: c.read(journalLedgerRepositoryProvider),
      journal: c.read(operatorJournalProvider),
      rebalance: c.read(operatorRebalanceProvider),
    );

ReadModelEnvelopeDraft _env<T>(RunMode mode, String code, ListResult<T> r) =>
    ReadModelEnvelopeDraft(
      mode: mode,
      listCode: code,
      asOf: r.asOf.toJson(),
      emptyKind: r.emptyKind,
      emptyLabel: r.emptyLabel,
    );

/// 표 이름 → 원천(이 판 12표 · 봉투 = 회차 · 원장 차이 · blind 큐 · 리듬).
Map<String, ReadModelSnapshotSource> operatorReadModelSources(
  OperatorReadModelRepos r, {
  required RunMode mode,
  Duration wait = kReadModelSourceWait,
}) {
  Future<T> one<T>(Stream<T> s) => s.first.timeout(wait);
  ReadModelRowInput row(
    Map<String, Map<String, Object?>> dtos, {
    Map<String, Object?> extras = const <String, Object?>{},
  }) =>
      ReadModelRowInput(mode: mode, rowVersion: 0, dtos: dtos, extras: extras);
  return <String, ReadModelSnapshotSource>{
    ReadModelTables.rebalanceEvent.name: () async {
      final ListResult<RebalanceEvent> ev = await one(
        r.rebalance.watchEvents(),
      );
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          for (final RebalanceEvent e in ev.rows)
            row(<String, Map<String, Object?>>{
              'RebalanceEvent': e.toJson(),
              if (await one(r.journal.watchRebalanceScope(e.eventId))
                  case final JournalRebalanceScope s)
                'JournalRebalanceScope': s.toJson(),
            }),
        ],
        envelopes: <ReadModelEnvelopeDraft>[
          _env(mode, ReadModelListCodes.rebalanceWatchEvents, ev),
        ],
      );
    },
    ReadModelTables.alert.name: () async => ReadModelSnapshot(
      rows: <ReadModelRowInput>[
        for (final AlertItem a in await one(r.alerts.watchInbox()))
          row(<String, Map<String, Object?>>{'AlertItem': a.toJson()}),
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
      final ListResult<LedgerDiffRow> d = await one(r.ledger.watchOpenDiffs());
      return ReadModelSnapshot(
        rows: <ReadModelRowInput>[
          for (final LedgerDiffRow x in d.rows)
            row(<String, Map<String, Object?>>{'LedgerDiffRow': x.toJson()}),
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
          for (final BlindReviewCard c in q.rows)
            row(<String, Map<String, Object?>>{'BlindReviewCard': c.toJson()}),
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
  return ReadModelPushJob(
    pusher: pusher,
    status: SqliteReadModelPushStatus(v.db),
    sources: operatorReadModelSources(repos, mode: mode, wait: wait),
    nowUtc: rt.clock.nowUtc,
  ).run(deviceId: rt.deviceId, epoch: epoch);
}
