// 🆕 E11-viewer-223(01 §8 미결 223 · 계약 v1.36 §45) — 뷰어 계약 창구 뼈대(메모리 원천).
//
// 🔴 서는 창구 = 모드별 1행 · 키 한 행 · jsonb 목록 열 · 시리즈 점 · `is_default` 행 · 봉투.
// 🔴 서지 않는 창구 = UnsupportedError(행 차례 · 소속 열 없음 = 계약 창 대기 · 원천 열 0 · 사용자 지정 구간).

import 'dart:async';

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:read_model_client/read_model_client.dart';
import 'package:test/test.dart';

import 'support/contract_samples.dart';
import 'support/memory_source.dart';

/// 봉투 `as_of`(와이어 — 엔진 `AsOf.toJson()` 꼴).
final Map<String, Object?> _asOf = jsonDecode(
  jsonEncode(
    AsOf(
      observedAt: DateTime.utc(2026, 11, 24),
      tradeDate: const TradeDate('2026-11-21'),
      source: AsOfSource.localSqlite,
      staleAfter: const Duration(hours: 26),
      label: '기준 2026-11-21',
    ).toJson(),
  ),
) as Map<String, Object?>;

Matcher get _unsupported => throwsA(isA<UnsupportedError>());

ReadModelRow _row(
  ReadModelTable t, {
  RunMode mode = RunMode.live,
  Map<String, Object?> over = const <String, Object?>{},
}) => <String, Object?>{...rowOf(t), 'mode': mode.wire, ...over};

const DateRange _custom = DateRange(
  from: TradeDate('2026-01-02'),
  to: TradeDate('2026-03-31'),
  label: '사용자 지정',
);

void main() {
  late MemorySource src;
  late ViewerReadModels m;

  setUp(() {
    src = MemorySource();
    m = ViewerReadModels(source: src, mode: RunMode.live);
  });

  tearDown(() => unawaited(src.close()));

  group('모드별 1행 창구 — 그 모드 행 하나 → 계약 DTO', () {
    test('창구 11 = 읽개 fromRow(그 모드 행) · 다른 모드 행 무시', () async {
      final List<
        (
          ReadModelTable,
          Future<Object> Function(),
          Object Function(ReadModelRow),
        )
      >
      cases =
          <
            (
              ReadModelTable,
              Future<Object> Function(),
              Object Function(ReadModelRow),
            )
          >[
            (
              ReadModelTables.safetyState,
              () => m.safety.watchState().first,
              ReadModelReaders.safetyState.fromRow,
            ),
            (
              ReadModelTables.configView,
              () => m.config.watchFlags().first,
              ReadModelReaders.featureFlags.fromRow,
            ),
            (
              ReadModelTables.configView,
              () => m.config.watchContributionSetting().first,
              ReadModelReaders.contributionSetting.fromRow,
            ),
            (
              ReadModelTables.configView,
              () => m.settings.watchAllocationEditor().first,
              ReadModelReaders.allocationEditor.fromRow,
            ),
            (
              ReadModelTables.adviceSummary,
              () => m.advice.watchSummary().first,
              ReadModelReaders.adviceSummary.fromRow,
            ),
            (
              ReadModelTables.sleeveAllocation,
              () => m.holdings.watchAllocation().first,
              ReadModelReaders.sleeveAllocation.fromRow,
            ),
            (
              ReadModelTables.disclosureView,
              () => m.performance.watchDisclosureGate().first,
              ReadModelReaders.disclosureGate.fromRow,
            ),
            (
              ReadModelTables.watchdog,
              () => m.opsStatus.watchWatchdog().first,
              ReadModelReaders.watchdog.fromRow,
            ),
            (
              ReadModelTables.opsSummary,
              () => m.opsSummary.watchToday().first,
              ReadModelReaders.opsDailySummary.fromRow,
            ),
            (
              ReadModelTables.ledgerTrust,
              () => m.ledgerTrust.watchGrade().first,
              ReadModelReaders.ledgerTrust.fromRow,
            ),
            (
              ReadModelTables.reportArchive,
              () => m.performance.reportArchive(),
              ReadModelReaders.reportArchive.fromRow,
            ),
          ];
      for (final (
            ReadModelTable t,
            Future<Object> Function() read,
            Object Function(ReadModelRow) fromRow,
          )
          in cases) {
        final ReadModelRow live = _row(t);
        src.put(t.name, <ReadModelRow>[
          _row(
            t,
            mode: RunMode.simInternal,
            over: <String, Object?>{'as_of': null},
          ),
          live,
        ]);
        expect(await read(), fromRow(live), reason: t.name);
        expect(src.queries.last.equals['mode'], RunMode.live.wire);
      }
    });

    test('watchSleeves = sleeve_catalog 받은 순서', () async {
      final ReadModelRow row = _row(ReadModelTables.configView);
      src.put(ReadModelTables.configView.name, <ReadModelRow>[row]);
      expect(await m.config.watchSleeves().first, sleeveCatalogOfRow(row));
    });

    test(
      '행 없음 = ReadModelRowMissing · 행 둘 = FormatException(고르지 않는다)',
      () async {
        await expectLater(
          m.safety.watchState().first,
          throwsA(isA<ReadModelRowMissing>()),
        );
        src.put(ReadModelTables.safetyState.name, <ReadModelRow>[
          _row(ReadModelTables.safetyState),
          _row(ReadModelTables.safetyState),
        ]);
        await expectLater(
          m.safety.watchState().first,
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('행이 바뀌면 다시 낸다 · 못 읽는 행 = 스트림 FormatException', () async {
      final List<Object> got = <Object>[];
      final StreamSubscription<SafetyState> sub = m.safety.watchState().listen(
        got.add,
        onError: got.add,
      );
      await pumpEventQueue();
      src.put(ReadModelTables.safetyState.name, <ReadModelRow>[
        _row(ReadModelTables.safetyState),
      ]);
      await pumpEventQueue();
      src.put(ReadModelTables.safetyState.name, <ReadModelRow>[
        _row(
          ReadModelTables.safetyState,
          over: <String, Object?>{'breaker_level': 'NOPE'},
        ),
      ]);
      await pumpEventQueue();
      await sub.cancel();
      expect(got.first, isA<ReadModelRowMissing>());
      expect(got[1], isA<SafetyState>());
      expect(got.last, isA<FormatException>());
    });
  });

  group('키 한 행 창구', () {
    test(
      'watchEvent · watchBlindReviewCard · monthlyReport · findById',
      () async {
        final ReadModelRow ev = _row(ReadModelTables.rebalanceEvent);
        src.put(ReadModelTables.rebalanceEvent.name, <ReadModelRow>[
          ev,
          _row(
            ReadModelTables.rebalanceEvent,
            over: <String, Object?>{'event_id': 'other'},
          ),
        ]);
        expect(
          await m.rebalance.watchEvent(ev['event_id']! as String).first,
          ReadModelReaders.rebalanceEvent.fromRow(ev),
        );
        final ReadModelRow br = _row(ReadModelTables.blindReview);
        src.put(ReadModelTables.blindReview.name, <ReadModelRow>[br]);
        expect(
          await m.journal
              .watchBlindReviewCard(br['decision_id']! as String)
              .first,
          ReadModelReaders.blindReview.fromRow(br),
        );
        final ReadModelRow mr = _row(ReadModelTables.monthlyReport);
        src.put(ReadModelTables.monthlyReport.name, <ReadModelRow>[mr]);
        expect(
          await m.performance.monthlyReport(mr['yyyy_mm']! as String),
          ReadModelReaders.monthlyReport.fromRow(mr),
        );
        await expectLater(
          m.performance.monthlyReport('1999-01'),
          throwsA(isA<ReadModelRowMissing>()),
        );
        final ReadModelRow ad = _row(ReadModelTables.advice);
        src.put(ReadModelTables.advice.name, <ReadModelRow>[ad]);
        expect(
          await m.advice.findById(ad['advice_id']! as String),
          ReadModelReaders.advice.fromRow(ad),
        );
        expect(await m.advice.findById('없는-id'), isNull);
      },
    );

    test('watchRebalanceScope — 행 없음 = null · scope 두 칸 null = null · 있으면 scope(id = event_id)', () async {
      final ReadModelRow ev = _row(ReadModelTables.rebalanceEvent);
      final String id = ev['event_id']! as String;
      expect(await m.journal.watchRebalanceScope(id).first, isNull);
      src.put(ReadModelTables.rebalanceEvent.name, <ReadModelRow>[
        <String, Object?>{...ev, 'scope_label': null, 'scope_range': null},
      ]);
      expect(await m.journal.watchRebalanceScope(id).first, isNull);
      src.put(ReadModelTables.rebalanceEvent.name, <ReadModelRow>[ev]);
      final JournalRebalanceScope? s = await m.journal
          .watchRebalanceScope(id)
          .first;
      expect(s, ReadModelReaders.rebalanceScope.fromRow(ev));
      expect(s!.rebalanceEventId, id);
      src.put(ReadModelTables.rebalanceEvent.name, <ReadModelRow>[
        <String, Object?>{...ev, 'scope_range': null},
      ]);
      await expectLater(
        m.journal.watchRebalanceScope(id).first,
        throwsA(isA<FormatException>()),
      );
    });

    test('fillsOfAdvice = 빈 목록(K40 뷰어 판)', () async {
      expect(await m.advice.fillsOfAdvice('a'), isEmpty);
    });
  });

  group('구간 · 기본 행(미결 223 ⓓ)', () {
    void putContext() {
      src.put(ReadModelTables.perfContext.name, <ReadModelRow>[
        _row(
          ReadModelTables.perfContext,
          over: <String, Object?>{
            'range_preset_code': 'LAST_3M',
            'is_default': true,
            'drawdown_period_label': '기본',
          },
        ),
        _row(
          ReadModelTables.perfContext,
          over: <String, Object?>{
            'range_preset_code': 'YTD',
            'is_default': false,
            'drawdown_period_label': '올해',
          },
        ),
      ]);
    }

    test(
      'drawdownContext(null) = is_default 행 · 프리셋 = 그 행 · 사용자 지정 = 불가',
      () async {
        putContext();
        expect((await m.performance.drawdownContext()).periodLabel, '기본');
        expect(
          (await m.performance.drawdownContext(
            range: _custom.copyWith(presetCode: 'YTD'),
          )).periodLabel,
          '올해',
        );
        await expectLater(
          m.performance.drawdownContext(range: _custom),
          _unsupported,
        );
      },
    );

    test('contribution(프리셋) = 그 행 · 사용자 지정 = 불가', () async {
      putContext();
      final ContributionVm vm = await m.performance.contribution(
        range: _custom.copyWith(presetCode: 'YTD'),
      );
      expect(vm, isA<ContributionVm>());
      expect(src.queries.last.equals['range_preset_code'], 'YTD');
      await expectLater(
        m.performance.contribution(range: _custom),
        _unsupported,
      );
    });

    test('executionGap.monthly(null) = is_default 행 · 달 = 그 행', () async {
      src.put(ReadModelTables.executionGap.name, <ReadModelRow>[
        _row(ReadModelTables.executionGap),
        _row(
          ReadModelTables.executionGap,
          over: <String, Object?>{'yyyy_mm': '2026-09', 'is_default': false},
        ),
      ]);
      await m.executionGap.monthly();
      expect(src.queries.last.equals['is_default'], isTrue);
      await m.executionGap.monthly(yyyyMm: '2026-09');
      expect(src.queries.last.equals['yyyy_mm'], '2026-09');
      expect(src.queries.last.equals.containsKey('is_default'), isFalse);
    });

    test('series = 기본 구간 시리즈 + 그 점(date 오름차순) · 구간 지정 = 불가', () async {
      final ReadModelRow head = _row(ReadModelTables.performanceSeries);
      final ReadModelRow p = _row(ReadModelTables.performancePoint);
      src.put(ReadModelTables.performanceSeries.name, <ReadModelRow>[head]);
      src.put(ReadModelTables.performancePoint.name, <ReadModelRow>[
        <String, Object?>{...p, 'date': '2026-11-03'},
        <String, Object?>{...p, 'date': '2026-11-01'},
        <String, Object?>{...p, 'date': '2026-11-02', 'metric': 'MWR'},
      ]);
      final PerformanceSeries s = await m.performance.series(
        metric: PerfMetric.twr,
        granularity: PerfGranularity.daily,
        cumulative: true,
      );
      expect(s.points.map((PerfPoint x) => x.date.yyyyMmDd).toList(), <String>[
        '2026-11-01',
        '2026-11-03',
      ]);
      await expectLater(
        m.performance.series(
          metric: PerfMetric.twr,
          granularity: PerfGranularity.daily,
          cumulative: true,
          range: _custom,
        ),
        _unsupported,
      );
    });
  });

  group('목록 봉투 창구 — watchRhythm', () {
    ReadModelRow env({String? label}) => <String, Object?>{
      'row_version': 1,
      'lease_epoch': 1,
      'pushed_at': '2026-11-24T00:00:00Z',
      'mode': RunMode.live.wire,
      'list_code': ReadModelListCodes.opsStatusWatchRhythm,
      'as_of': _asOf,
      'empty_kind': EmptyKind.noData.wire,
      'empty_label': label,
    };

    test('행 = rhythm(받은 순서 · 전부) · 봉투 = 그 창구 행 · hasMore false', () async {
      final ReadModelRow ops = _row(ReadModelTables.opsSummary);
      src.put(ReadModelTables.opsSummary.name, <ReadModelRow>[ops]);
      src.put(ReadModelTables.listEnvelope.name, <ReadModelRow>[
        <String, Object?>{
          ...env(label: '다른 창구'),
          'list_code': ReadModelListCodes.journalWatchTimeline,
        },
        env(),
      ]);
      final ListResult<OpsRhythmRow> r = await m.opsSummary.watchRhythm().first;
      expect(r.rows, opsRhythmOfRow(ops));
      expect(r.hasMore, isFalse);
      expect(r.emptyLabel, isNull);
      expect(r.asOf.tradeDate.yyyyMmDd, '2026-11-21');
    });

    test('봉투 없음 = FormatException · 봉투가 오면 다시 낸다', () async {
      src.put(ReadModelTables.opsSummary.name, <ReadModelRow>[
        _row(ReadModelTables.opsSummary),
      ]);
      final List<Object> got = <Object>[];
      final StreamSubscription<ListResult<OpsRhythmRow>> sub = m.opsSummary
          .watchRhythm()
          .listen(got.add, onError: got.add);
      await pumpEventQueue();
      src.put(ReadModelTables.listEnvelope.name, <ReadModelRow>[env()]);
      await pumpEventQueue();
      await sub.cancel();
      expect(got.first, isA<FormatException>());
      expect(got.last, isA<ListResult<OpsRhythmRow>>());
    });
  });

  group('서지 않는 창구 = UnsupportedError(빈 값 · 지어낸 차례 0)', () {
    test('행 차례 · 소속 열 없음(계약 창 대기) · 원천 열 0', () async {
      const DateRange r = _custom;
      final List<(String, Future<Object?> Function())>
      cases = <(String, Future<Object?> Function())>[
        ('watchTimeline', () => m.journal.watchTimeline(range: r).first),
        ('findByDecisionId', () => m.journal.findByDecisionId('d')),
        ('chainOf', () => m.journal.chainOf('d')),
        ('fillChain', () => m.journal.fillChain('e')),
        ('watchFilterCatalog', () => m.journal.watchFilterCatalog().first),
        ('watchTimelineBadges', () => m.journal.watchTimelineBadges().first),
        ('watchDecisionDetail', () => m.journal.watchDecisionDetail('d').first),
        ('draftFormSpec', () => m.journal.draftFormSpec('d')),
        ('watchUnknownBoard', () => m.journal.watchUnknownBoard().first),
        (
          'watchDecisionJournal',
          () => m.journal.watchDecisionJournal('d').first,
        ),
        (
          'watchBlindReviewQueue',
          () => m.journal.watchBlindReviewQueue().first,
        ),
        ('watchInbox', () => m.advice.watchInbox().first),
        ('watchHistory', () => m.advice.watchHistory(range: r).first),
        (
          'watchManualFillFormSpec',
          () => m.advice.watchManualFillFormSpec().first,
        ),
        ('watchHoldings', () => m.holdings.watchHoldings().first),
        (
          'watchHoldingsOverview',
          () => m.holdings.watchHoldingsOverview().first,
        ),
        ('watchHoldingDetail', () => m.holdings.watchHoldingDetail('h').first),
        (
          'afterTaxLadder',
          () => m.performance.afterTaxLadder(fiscalYear: '2026'),
        ),
        ('annualReview', () => m.performance.annualReview()),
        ('goalPath', () => m.performance.goalPath(yyyyMm: '2026-10')),
        ('watchEvents', () => m.rebalance.watchEvents().first),
        ('watchNext', () => m.rebalance.watchNext().first),
        ('alerts.watchInbox', () => m.alerts.watchInbox().first),
        ('watchCenter', () => m.alerts.watchCenter(p0Only: false).first),
        ('watchAlert', () => m.alerts.watchAlert('a').first),
        ('watchRangePresets', () => m.config.watchRangePresets().first),
        ('watchHome', () => m.settings.watchHome().first),
        ('watchOperations', () => m.settings.watchOperations().first),
        ('watchCredentials', () => m.settings.watchCredentials().first),
        ('watchAccountMapping', () => m.settings.watchAccountMapping().first),
        ('watchContribution', () => m.settings.watchContribution().first),
        (
          'watchDiagnosticsScreen',
          () => m.settings.watchDiagnosticsScreen().first,
        ),
        ('watchOpenDiffs', () => m.ledger.watchOpenDiffs().first),
        ('watchExternalHoldings', () => m.ledger.watchExternalHoldings().first),
        ('watchRepairs', () => m.ledger.watchRepairs().first),
        ('watchConnections', () => m.opsStatus.watchConnections().first),
        ('watchDeviceAccess', () => m.opsStatus.watchDeviceAccess().first),
        ('watchBackup', () => m.opsStatus.watchBackup().first),
        ('watchDiagnostics', () => m.opsStatus.watchDiagnostics().first),
        ('watchAnnualReview', () => m.opsStatus.watchAnnualReview().first),
        ('watchDeviceRisk', () => m.opsStatus.watchDeviceRisk().first),
        (
          'watchSelfReportSession',
          () => m.ledgerTrust.watchSelfReportSession('2026-10', 'A').first,
        ),
        ('watchRolling', () => m.executionGap.watchRolling().first),
      ];
      for (final (String what, Future<Object?> Function() call) in cases) {
        await expectLater(call(), _unsupported, reason: what);
      }
      expect(cases, hasLength(43));
      expect(src.queries, isEmpty, reason: '서지 않는 창구는 원천을 부르지 않는다');
    });
  });

  group('버전 게이트(M4-8 · 미결 223 ⓔ)', () {
    ReadModelRow stamp({int? schema, String? contract}) => _row(
      ReadModelTables.configView,
      over: <String, Object?>{
        'schema_version': schema ?? schemaVersion,
        'contract_version': contract ?? contractVersion,
      },
    );

    test(
      '그 모드 행의 스탬프 — 같음 ok · minor 큼 degraded · schema 다름 incompatible',
      () async {
        src.put(ReadModelTables.configView.name, <ReadModelRow>[stamp()]);
        expect(await m.watchGate().first, ReadModelGate.ok);
        final ContractVersion me = ContractVersion.tryParse(contractVersion)!;
        src.put(ReadModelTables.configView.name, <ReadModelRow>[
          stamp(contract: '${me.major}.${me.minor + 1}.0'),
        ]);
        expect(await m.watchGate().first, ReadModelGate.degraded);
        src.put(ReadModelTables.configView.name, <ReadModelRow>[
          stamp(schema: schemaVersion + 1),
        ]);
        expect(await m.watchGate().first, ReadModelGate.incompatible);
      },
    );

    test('행 없음 · 행 둘 · 원천 오류(RLS 거부 · 표 부재) = incompatible', () async {
      expect(await m.watchGate().first, ReadModelGate.incompatible);
      src.put(ReadModelTables.configView.name, <ReadModelRow>[
        stamp(),
        stamp(),
      ]);
      expect(await m.watchGate().first, ReadModelGate.incompatible);
      src.failure = const FormatException('rls');
      expect(await m.watchGate().first, ReadModelGate.incompatible);
    });

    test(
      'readModelGateAfter — 못 읽음(FormatException) = incompatible · 그 밖 = 그대로',
      () {
        for (final ReadModelGate g in ReadModelGate.values) {
          expect(
            readModelGateAfter(g, const FormatException('x')),
            ReadModelGate.incompatible,
          );
          expect(
            readModelGateAfter(
              g,
              const ReadModelRowMissing('rm_x', <String, Object?>{}),
            ),
            g,
          );
          expect(readModelGateAfter(g, StateError('net')), g);
        }
      },
    );
  });

  group('조회 — 표 상수 안의 열만', () {
    test(
      '모르는 열 = ArgumentError · 규칙 5조 칸 · 표 열 = 받음 · limit 음수 = ArgumentError',
      () {
        expect(
          () => ReadModelQuery(
            ReadModelTables.safetyState,
            equals: const <String, Object?>{'nope': 1},
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => ReadModelQuery(
            ReadModelTables.safetyState,
            orderBy: const <ReadModelOrder>[ReadModelOrder('event_id')],
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => ReadModelQuery(ReadModelTables.safetyState, limit: -1),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          ReadModelQuery(
            ReadModelTables.safetyState,
            equals: const <String, Object?>{'mode': 'LIVE', 'row_version': 1},
            orderBy: const <ReadModelOrder>[ReadModelOrder('breaker_level')],
            limit: 0,
          ).limit,
          0,
        );
      },
    );
  });
}
