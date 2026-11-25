// 🆕 E11l2b — 읽기 모델 행 빌더 · push 클라이언트 · 시크릿 관문 시험(설계 13 §8 R256 · 01 §8 미결 222 ⓒⓓⓔ).
//
// ① 22표 — 계약 표본 DTO 로 행 하나씩(열 ⊆ 계약 · 키 non-null · 제외 키 0 · 덮는 칸 0)
// ② 뷰어 판 — 보유 배분 금액 = 가림 글자 · 안내 글자 = 생산자 값 없으면 거부 ③ 스탬프 · 펼침(v1.28 allocation_*) · DTO 밖 열
// ④ 거부 — 모드 다름 · 첫 결속 없음 · 모르는 list_code ⑤ 클라이언트 — 인자 4 · 성공 · 거부 · 꼴 · 401 재시도 · 5xx · 시크릿 차단(망 0).
// 🆕 미결 242(설계 13 §8 R275 · 01 §48 K339~K341) ⑥ 목록 열 — 요구 0 · 그 표 목록 열만 · 차례 = 1 이상 정수 · null · 봉투 빈 문장 2 ·
// 표본 행에 차례 · 프리셋 · 봉투 문장을 실어 PGlite 덤프가 실제로 넣어 본다.
// 🔵 AAQ_DUMP_ROWS=<파일> 이면 22표 행을 JSON 으로 써서 PGlite 하네스(tool/pglite/read_models_harness.mjs 넷째 인자)가 실제로 push 한다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart' show HoldingsTexts;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

Map<String, Object?> _env(String path) =>
    jsonDecode(File('../domain_contracts/fixtures/$path').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _row0(String path) =>
    (_env(path)['rows']! as List<Object?>).first! as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_env(path)['rows']! as List<Object?>).cast<Map<String, Object?>>();

RunMode _mode(Object? wire) =>
    RunMode.values.firstWhere((RunMode m) => m.wire == wire);

/// 표 이름 → 표본 입력(계약 표본 DTO 를 디코드 → 인코드 — 키 집합 = 생성 코드의 `toJson`).
Map<String, ReadModelRowInput> _samples() {
  final Map<String, Object?> journal = TradeJournalEntry.fromJson(
    _row0('journal_30.json'),
  ).toJson();
  final Map<String, Object?> holding = HoldingRow.fromJson(
    _row0('holdings_6.json'),
  ).toJson();
  final Map<String, Object?> series = PerformanceSeries.fromJson(
    _row0('m7/m7_perf_yearly.json'),
  ).toJson();
  final Map<String, Object?> point =
      (series['points']! as List<Object?>).first! as Map<String, Object?>;
  final Map<String, Object?> rebalance = RebalanceEvent.fromJson(
    _row0('rebalance_6.json'),
  ).toJson();
  final Map<String, Object?> safety = SafetyState.fromJson(
    _row0('safety_states.json'),
  ).toJson();
  const RunMode live = RunMode.live;
  return <String, ReadModelRowInput>{
    'rm_journal': ReadModelRowInput(
      mode: _mode(journal['mode']),
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{'TradeJournalEntry': journal},
      list: const <String, Object?>{'timeline_rank': 1},
    ),
    'rm_holding': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{'HoldingRow': holding},
      extras: <String, Object?>{
        'trade_date': (holding['as_of']! as Map<String, Object?>)['trade_date'],
      },
    ),
    'rm_performance_point': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{'PerfPoint': point},
      extras: <String, Object?>{
        'metric': series['metric'],
        'granularity': series['granularity'],
        'cumulative': series['cumulative'],
      },
      list: const <String, Object?>{'series_rank': 1},
    ),
    'rm_performance_series': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{'PerformanceSeries': series},
    ),
    'rm_rebalance_event': ReadModelRowInput(
      mode: _mode(rebalance['mode']),
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'RebalanceEvent': rebalance,
        'JournalRebalanceScope': JournalRebalanceScope.fromJson(
          _row0('m6/journal_rebalance_scope_1.json'),
        ).toJson(),
      },
      list: const <String, Object?>{'events_rank': 1},
    ),
    'rm_alert': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'AlertItem': AlertItem.fromJson(_row0('alerts_12.json')).toJson(),
      },
      list: const <String, Object?>{'inbox_rank': 1},
    ),
    'rm_safety_state': ReadModelRowInput(
      mode: _mode(safety['mode']),
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{'SafetyState': safety},
    ),
    'rm_config_view': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'FeatureFlags': const FeatureFlags(
          satelliteEnabled: true,
          webViewerEnabled: true,
          calendarEnabled: false,
          runMode: RunMode.live,
          operatingMode: OperatingMode.autoTrade,
          configHash: 'cfg_fake_0000000000000000',
        ).toJson(),
        'ContributionSetting': ContributionSetting.fromJson(
          _row0('m9/contribution_setting_default.json'),
        ).toJson(),
        'AllocationEditorVm': AllocationEditorVm.fromJson(
          _row0('m9/allocation_editor.json'),
        ).toJson(),
      },
      extras: <String, Object?>{
        'sleeve_catalog': <Object?>[
          for (final Map<String, Object?> r in _rows('sleeve_catalog_4.json'))
            SleeveCatalogEntry.fromJson(r).toJson(),
        ],
      },
      list: <String, Object?>{
        'range_presets': <Object?>[
          for (final Map<String, Object?> r in _rows('range_presets_4.json'))
            DateRange.fromJson(r).toJson(),
        ],
      },
    ),
    'rm_advice': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'AdviceItem': AdviceItem.fromJson(_row0('m6/advice_12.json')).toJson(),
      },
      viewer: const <String, Object?>{
        'sizing_label': '계좌 잔고의 정해진 비중만큼',
        'progress_label': '아직 기록이 없습니다',
      },
    ),
    'rm_advice_summary': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'AdviceInboxSummary': AdviceInboxSummary.fromJson(
          _env('m6/advice_12.json')['summary']! as Map<String, Object?>,
        ).toJson(),
      },
    ),
    'rm_monthly_report': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'MonthlyReport': MonthlyReport.fromJson(
          _row0('m7/m7_monthly_2026_08.json'),
        ).toJson(),
      },
    ),
    'rm_report_archive': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'ReportArchiveVm': ReportArchiveVm.fromJson(
          _row0('m7/m7_report_archive_18.json'),
        ).toJson(),
      },
    ),
    'rm_ledger_diff': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'LedgerDiffRow': LedgerDiffRow.fromJson(_row0('ledger_diffs_4.json'))
            .toJson(),
      },
    ),
    'rm_sleeve_allocation': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'SleeveAllocationVm': SleeveAllocationVm.fromJson(
          _row0('m6/allocation_in_band.json'),
        ).toJson(),
      },
    ),
    'rm_perf_context': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'DrawdownContextVm': DrawdownContextVm.fromJson(
          _row0('m7/m7_dd_context_normal.json'),
        ).toJson(),
        'ContributionVm': ContributionVm.fromJson(
          _row0('m7/m7_contrib_3sleeve.json'),
        ).toJson(),
      },
      extras: const <String, Object?>{
        'range_preset_code': 'P12M',
        'is_default': true,
      },
    ),
    'rm_disclosure_view': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'DisclosureGateVm': DisclosureGateVm.fromJson(
          _row0('m7/m7_disclosure_gate.json'),
        ).toJson(),
      },
    ),
    'rm_ops_summary': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'OpsDailySummary': OpsDailySummary.fromJson(
          _row0('m8/ops_home_normal.json'),
        ).toJson(),
      },
      extras: <String, Object?>{
        'rhythm': <Object?>[
          for (final Map<String, Object?> r in _rows('m8/ops_rhythm_rows.json'))
            OpsRhythmRow.fromJson(r).toJson(),
        ],
      },
    ),
    'rm_ledger_trust': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'LedgerTrustBadge': LedgerTrustBadge.fromJson(
          _row0('m7/ledger_trust_4.json'),
        ).toJson(),
      },
    ),
    'rm_execution_gap': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'ExecutionGapResult': ExecutionGapResult.fromJson(
          _row0('m7/execution_gap_1.json'),
        ).toJson(),
      },
      extras: const <String, Object?>{'yyyy_mm': '2026-08', 'is_default': true},
    ),
    'rm_blind_review': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'BlindReviewCard': BlindReviewCard.fromJson(
          _row0('m6/blind_review_queue_3.json'),
        ).toJson(),
      },
    ),
    'rm_watchdog': ReadModelRowInput(
      mode: live,
      rowVersion: 1,
      dtos: <String, Map<String, Object?>>{
        'WatchdogBoardVm': WatchdogBoardVm.fromJson(
          _row0('m8/watchdog_delayed.json'),
        ).toJson(),
      },
    ),
  };
}

Map<String, List<Map<String, Object?>>> _allRows() {
  final Map<String, ReadModelRowInput> s = _samples();
  final Map<String, List<Map<String, Object?>>> out =
      <String, List<Map<String, Object?>>>{};
  for (final ReadModelTable t in ReadModelTables.all) {
    if (t == ReadModelTables.listEnvelope) {
      out[t.name] = <Map<String, Object?>>[
        listEnvelopeRow(
          mode: RunMode.live,
          rowVersion: 1,
          listCode: ReadModelListCodes.journalWatchTimeline,
          asOf: _env('journal_30.json')['as_of']! as Map<String, Object?>,
          emptyKind: EmptyKind.noData,
          filteredEmptyLabel: '조건에 맞는 기록이 없습니다',
          scopeEmptyLabel: '이 회차에 묶인 기록이 없습니다',
        ),
      ];
      continue;
    }
    out[t.name] = <Map<String, Object?>>[readModelRow(t, s[t.name]!)];
  }
  return out;
}

// ── 클라이언트 받침 ─────────────────────────────────────────────────────────
final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
String _access(int n) => 'acc-${'A' * 10}-$n';

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

class _Rig {
  _Rig()
    : vault = MemorySecretVault(<String, String>{
        'supabase.project_url': _url,
        'supabase.publishable_key': _pub,
        'supabase.refresh_token': 'ref-${'R' * 12}',
      });

  final MemorySecretVault vault;
  final List<http.Request> rpc = <http.Request>[];
  int tokenN = 0;
  late http.Response Function(int i) reply;

  late final http.Client net = MockClient((http.Request r) async {
    if (r.url.path.startsWith('/auth/')) {
      return http.Response(
        jsonEncode(<String, Object?>{
          'access_token': _access(++tokenN),
          'expires_in': 3600,
          'refresh_token': 'ref-${'R' * 12}-$tokenN',
          'user': <String, Object?>{'id': 'uid-1'},
        }),
        200,
      );
    }
    rpc.add(r);
    return reply(rpc.length - 1);
  });
  late final SupabaseReadModelPush client = SupabaseReadModelPush(
    net,
    vault,
    SupabaseAuth(net, vault, clock: _Clock(DateTime.utc(2026, 12, 8, 9))),
  );
}

http.Response _answer(Object? code, Object? epoch, Object? a, Object? s) =>
    http.Response(
      jsonEncode(<Object>[
        <String, Object?>{
          'code': code,
          'epoch': epoch,
          'accepted': a,
          'skipped': s,
        },
      ]),
      200,
    );

void main() {
  group('① 22표 행', () {
    test('계약 표본 DTO → 행 — 열 ⊆ 계약 · 키 non-null · 덮는 칸 0 · 22표 전부', () {
      final Map<String, List<Map<String, Object?>>> all = _allRows();
      expect(
        all.keys.toList(),
        ReadModelTables.all.map((ReadModelTable t) => t.name).toList(),
      );
      for (final ReadModelTable t in ReadModelTables.all) {
        final Map<String, Object?> row = all[t.name]!.single;
        final Set<String> cols = <String>{
          for (final ReadModelColumn c in ReadModelPushColumns.all) c.name,
          for (final ReadModelColumn c in t.columns) c.name,
        };
        expect(cols.containsAll(row.keys), isTrue, reason: t.name);
        for (final String k in t.keyColumns) {
          expect(row[k], isNotNull, reason: '${t.name}.$k');
        }
        expect(row.containsKey('lease_epoch'), isFalse, reason: t.name);
        expect(row.containsKey('pushed_at'), isFalse, reason: t.name);
        expect(row['row_version'], 1);
        // 결속 열이 실제로 실렸다(빈 행 0).
        expect(
          row.length,
          greaterThan(t.keyColumns.length + 1),
          reason: t.name,
        );
      }
      final String? out = Platform.environment['AAQ_DUMP_ROWS'];
      if (out != null && out.isNotEmpty) {
        File(out).writeAsStringSync(jsonEncode(all));
      }
    });

    test('제외 키 0 — A6 · 손익 · 폰 전용 링크 · 시리즈 점', () {
      final Map<String, List<Map<String, Object?>>> all = _allRows();
      for (final String k in <String>[
        'symbol',
        'symbol_label',
        'side',
        'side_label',
        'quantity',
        'price_band',
        'recorded_quantity',
        'prefill_quantity_text',
        'prefill_quantity_label',
        'actions',
      ]) {
        expect(all['rm_advice']!.single.containsKey(k), isFalse, reason: k);
      }
      expect(all['rm_holding']!.single.containsKey('pnl'), isFalse);
      expect(all['rm_ledger_diff']!.single.containsKey('action_link'), isFalse);
      expect(
        all['rm_advice_summary']!.single.containsKey('manual_entry_link'),
        isFalse,
      );
      expect(
        all['rm_performance_series']!.single.containsKey('points'),
        isFalse,
      );
      expect(
        all['rm_rebalance_event']!.single.containsKey(
          'scope_rebalance_event_id',
        ),
        isFalse,
      );
      expect(all['rm_rebalance_event']!.single['scope_label'], isNotNull);
    });
  });

  group('② 뷰어 판', () {
    test('보유 배분 금액 = 가림 글자(행마다) · 비율 칸 그대로', () {
      final Map<String, Object?> row =
          _allRows()['rm_sleeve_allocation']!.single;
      final List<Object?> rows = row['rows']! as List<Object?>;
      expect(rows, isNotEmpty);
      for (final Object? r in rows) {
        final Map<String, Object?> m = r! as Map<String, Object?>;
        expect(m['deployed_text'], HoldingsTexts.hidden);
        expect(m['parking_text'], HoldingsTexts.hidden);
        expect(m.containsKey('deployed_pct_text'), isTrue);
      }
      expect(kReadModelViewerMaskText, HoldingsTexts.hidden);
    });

    test('안내 글자 = 생산자 뷰어 판 값 · 없으면 행을 만들지 않는다', () {
      final ReadModelRowInput s = _samples()['rm_advice']!;
      expect(
        () => readModelRow(
          ReadModelTables.advice,
          ReadModelRowInput(mode: s.mode, rowVersion: 1, dtos: s.dtos),
        ),
        throwsA(isA<ReadModelRowError>()),
      );
      final Map<String, Object?> row = readModelRow(ReadModelTables.advice, s);
      expect(row['sizing_label'], s.viewer['sizing_label']);
      expect(row['progress_label'], s.viewer['progress_label']);
    });
  });

  group('③ 스탬프 · 펼침 · DTO 밖 열', () {
    test('rm_config_view — 버전 스탬프 = 계약 상수 · v1.28 allocation_* 7 · contribution_* · sleeve_catalog', () {
      final Map<String, Object?> row = _allRows()['rm_config_view']!.single;
      expect(row['schema_version'], schemaVersion);
      expect(row['hash_format_version'], hashFormatVersion);
      expect(row['contract_version'], contractVersion);
      expect(row.keys, containsAll(AllocationReadModelColumns.all));
      expect(row.containsKey('allocation_current'), isFalse);
      expect(row['contribution_amount_text'], isNotNull);
      expect(row['sleeve_catalog'], isA<List<Object?>>());
      expect(row['operating_mode'], OperatingMode.autoTrade.wire);
      expect(
        () => readModelRow(
          ReadModelTables.configView,
          ReadModelRowInput(
            mode: RunMode.live,
            rowVersion: 1,
            dtos: _samples()['rm_config_view']!.dtos,
            extras: <String, Object?>{
              ..._samples()['rm_config_view']!.extras,
              'contract_version': '0.0.0',
            },
          ),
        ),
        throwsA(isA<ReadModelRowError>()),
        reason: '스탬프는 부르는 쪽이 주지 않는다',
      );
    });

    test('DTO 밖 열 = 계약 그대로(빠짐 · 남는 칸 = 거부)', () {
      final ReadModelRowInput s = _samples()['rm_execution_gap']!;
      expect(
        () => readModelRow(
          ReadModelTables.executionGap,
          ReadModelRowInput(
            mode: s.mode,
            rowVersion: 1,
            dtos: s.dtos,
            extras: const <String, Object?>{'yyyy_mm': '2026-08'},
          ),
        ),
        throwsA(isA<ReadModelRowError>()),
      );
      expect(
        () => readModelRow(
          ReadModelTables.executionGap,
          ReadModelRowInput(
            mode: s.mode,
            rowVersion: 1,
            dtos: s.dtos,
            extras: <String, Object?>{...s.extras, 'extra': 1},
          ),
        ),
        throwsA(isA<ReadModelRowError>()),
      );
    });
  });

  group('④ 거부', () {
    test('🆕 E11l2c-3(R268) 대등 결속(rm_perf_context) = 하나 이상 · 주 DTO 표 = 첫 결속 필수 그대로', () {
      final ReadModelRowInput s = _samples()['rm_perf_context']!;
      ReadModelRowInput only(String dto) => ReadModelRowInput(
        mode: s.mode,
        rowVersion: 1,
        dtos: <String, Map<String, Object?>>{dto: s.dtos[dto]!},
        extras: s.extras,
      );
      final Map<String, Object?> c = readModelRow(
        ReadModelTables.perfContext,
        only('ContributionVm'),
      );
      expect(c['contribution_period_label'], isNotNull);
      expect(c.containsKey('drawdown_period_label'), isFalse);
      final Map<String, Object?> d = readModelRow(
        ReadModelTables.perfContext,
        only('DrawdownContextVm'),
      );
      expect(d['drawdown_period_label'], isNotNull);
      expect(d.containsKey('contribution_period_label'), isFalse);
      expect(
        () => readModelRow(
          ReadModelTables.perfContext,
          ReadModelRowInput(mode: s.mode, rowVersion: 1, extras: s.extras),
        ),
        throwsA(isA<ReadModelRowError>()),
      );
      final ReadModelRowInput e = _samples()['rm_rebalance_event']!;
      expect(
        () => readModelRow(
          ReadModelTables.rebalanceEvent,
          ReadModelRowInput(
            mode: e.mode,
            rowVersion: 1,
            dtos: <String, Map<String, Object?>>{
              'JournalRebalanceScope': <String, Object?>{'label': 'x'},
            },
          ),
        ),
        throwsA(isA<ReadModelRowError>()),
        reason: '주 DTO 없이 둘째 결속만 = 거부',
      );
    });

    test('모드 다름 · 첫 결속 없음 · 모르는 list_code', () {
      final ReadModelRowInput s = _samples()['rm_journal']!;
      final RunMode other = RunMode.values.firstWhere(
        (RunMode m) => m != s.mode,
      );
      expect(
        () => readModelRow(
          ReadModelTables.journal,
          ReadModelRowInput(mode: other, rowVersion: 1, dtos: s.dtos),
        ),
        throwsA(isA<ReadModelRowError>()),
      );
      expect(
        () => readModelRow(
          ReadModelTables.journal,
          ReadModelRowInput(mode: s.mode, rowVersion: 1),
        ),
        throwsA(isA<ReadModelRowError>()),
      );
      expect(
        () => listEnvelopeRow(
          mode: RunMode.live,
          rowVersion: 1,
          listCode: 'X.y',
          asOf: const <String, Object?>{},
          emptyKind: EmptyKind.noData,
        ),
        throwsA(isA<ReadModelRowError>()),
      );
      // 키 칸 null = 거부(DTO 밖 키 · DTO 안 키 둘 다).
      final ReadModelRowInput g = _samples()['rm_execution_gap']!;
      expect(
        () => readModelRow(
          ReadModelTables.executionGap,
          ReadModelRowInput(
            mode: g.mode,
            rowVersion: 1,
            dtos: g.dtos,
            extras: <String, Object?>{...g.extras, 'yyyy_mm': null},
          ),
        ),
        throwsA(isA<ReadModelRowError>()),
      );
      final ReadModelRowInput a = _samples()['rm_alert']!;
      expect(
        () => readModelRow(
          ReadModelTables.alert,
          ReadModelRowInput(
            mode: a.mode,
            rowVersion: 1,
            dtos: <String, Map<String, Object?>>{
              'AlertItem': <String, Object?>{
                ...a.dtos['AlertItem']!,
                'alert_id': null,
              },
            },
          ),
        ),
        throwsA(isA<ReadModelRowError>()),
      );
      expect(readModelTableNamed('rm_watchdog'), ReadModelTables.watchdog);
      expect(readModelTableNamed('app_device'), isNull);
      expect(ReadModelRowError('rm_x', '이유').toString(), isNot(contains('{')));
    });
  });

  group('⑥ 목록 열(미결 242 · K339~K341)', () {
    test('요구 0 · 그 표 목록 열만 · 차례 = 1 이상 정수 또는 null · 봉투 빈 문장 2 · 프리셋 jsonb', () {
      final Map<String, ReadModelRowInput> s = _samples();
      final Map<String, List<Map<String, Object?>>> all = _allRows();
      expect(all['rm_journal']!.single['timeline_rank'], 1);
      expect(all['rm_alert']!.single['inbox_rank'], 1);
      expect(all['rm_performance_point']!.single['series_rank'], 1);
      expect(all['rm_rebalance_event']!.single['events_rank'], 1);
      expect(all['rm_config_view']!.single['range_presets'], hasLength(4));
      final Map<String, Object?> env = all['rm_list_envelope']!.single;
      expect(env['filtered_empty_label'], '조건에 맞는 기록이 없습니다');
      expect(env['scope_empty_label'], '이 회차에 묶인 기록이 없습니다');
      // 요구 0 — 목록 열 없이도 행(서버 null = 그 목록 밖).
      final ReadModelRowInput a = s['rm_alert']!;
      ReadModelRowInput alert(Map<String, Object?> list) => ReadModelRowInput(
        mode: a.mode,
        rowVersion: 1,
        dtos: a.dtos,
        list: list,
      );
      expect(
        readModelRow(
          ReadModelTables.alert,
          alert(const <String, Object?>{}),
        ).containsKey('inbox_rank'),
        isFalse,
      );
      expect(
        readModelRow(
          ReadModelTables.alert,
          alert(const <String, Object?>{'inbox_rank': null}),
        )['inbox_rank'],
        isNull,
      );
      // 거부 — 다른 표 목록 열 · 목록 열 아닌 열 · 0 · 음수 · 글자 · 실수.
      for (final Map<String, Object?> bad in <Map<String, Object?>>[
        <String, Object?>{'timeline_rank': 1},
        <String, Object?>{'alert_id': 'x'},
        <String, Object?>{'inbox_rank': 0},
        <String, Object?>{'inbox_rank': -2},
        <String, Object?>{'inbox_rank': '1'},
        <String, Object?>{'inbox_rank': 1.0},
      ]) {
        expect(
          () => readModelRow(ReadModelTables.alert, alert(bad)),
          throwsA(isA<ReadModelRowError>()),
          reason: '$bad',
        );
      }
      // 판만 바꾼 사본도 목록 열을 잇는다.
      expect(
        alert(const <String, Object?>{'inbox_rank': 7}).withRowVersion(9).list,
        <String, Object?>{'inbox_rank': 7},
      );
      // 봉투 문장 없음 = 두 열 null(그 목록에 그 문장 없음).
      final Map<String, Object?> bare = listEnvelopeRow(
        mode: RunMode.live,
        rowVersion: 1,
        listCode: ReadModelListCodes.ledgerWatchOpenDiffs,
        asOf: const <String, Object?>{},
        emptyKind: EmptyKind.noData,
      );
      expect(bare['filtered_empty_label'], isNull);
      expect(bare['scope_empty_label'], isNull);
    });
  });

  group('⑤ 클라이언트', () {
    test('인자 4 = 계약 · 성공 한 행 · 경로 rpc/rm_push', () async {
      final _Rig rig = _Rig()..reply = (int i) => _answer(null, 7, 1, 0);
      final List<Map<String, Object?>> rows = _allRows()['rm_watchdog']!;
      final ReadModelPushResult r = await rig.client.push(
        deviceId: 'dev-a',
        epoch: 7,
        table: ReadModelTables.watchdog,
        rows: rows,
      );
      expect(r.ok, isTrue);
      expect((r.epoch, r.accepted, r.skipped), (7, 1, 0));
      expect(
        rig.rpc.single.url.path,
        '/rest/v1/rpc/${ReadModelPushRpcNames.push}',
      );
      final Map<String, Object?> body =
          jsonDecode(rig.rpc.single.body) as Map<String, Object?>;
      expect(body.keys.toSet(), ReadModelPushRpcParams.values);
      expect(body[ReadModelPushRpcParams.table], 'rm_watchdog');
      expect(body[ReadModelPushRpcParams.epoch], 7);
      expect(rig.rpc.single.headers['authorization'], startsWith('Bearer '));
      expect(r.toString(), isNot(contains('acc-')));
    });

    test('거부 4 = 그 코드 · 0/0 · 모르는 코드 · 꼴 = badResponse', () async {
      for (final String code in kReadModelPushCodes) {
        final _Rig rig = _Rig()..reply = (int i) => _answer(code, 7, 0, 0);
        final ReadModelPushResult r = await rig.client.push(
          deviceId: 'd',
          epoch: 7,
          table: ReadModelTables.alert,
          rows: const <Map<String, Object?>>[],
        );
        expect(r.code, code);
        expect(r.ok, isFalse);
      }
      expect(kReadModelPushCodes, hasLength(4));
      for (final http.Response bad in <http.Response>[
        _answer('LEASE_HELD_BY_OTHER', 7, 0, 0),
        _answer(null, null, 1, 0),
        _answer('LEASE_LOST', 7, 1, 0),
        _answer(null, 7, -1, 0),
        http.Response('[]', 200),
        http.Response('nope', 200),
      ]) {
        final _Rig rig = _Rig()..reply = (int i) => bad;
        final ReadModelPushResult r = await rig.client.push(
          deviceId: 'd',
          epoch: 7,
          table: ReadModelTables.alert,
          rows: const <Map<String, Object?>>[],
        );
        expect(r.failure, ReadModelPushFailure.badResponse, reason: bad.body);
      }
    });

    test('401 → 토큰 새로 받아 한 번 더 · 5xx = server · 404 = badResponse', () async {
      final _Rig rig = _Rig()
        ..reply = (int i) =>
            i == 0 ? http.Response('', 401) : _answer(null, 7, 0, 1);
      final ReadModelPushResult r = await rig.client.push(
        deviceId: 'd',
        epoch: 7,
        table: ReadModelTables.alert,
        rows: const <Map<String, Object?>>[],
      );
      expect(r.ok, isTrue);
      expect(rig.rpc, hasLength(2));
      expect(
        rig.rpc.last.headers['authorization'],
        isNot(rig.rpc.first.headers['authorization']),
      );
      final _Rig s = _Rig()..reply = (int i) => http.Response('', 503);
      expect(
        (await s.client.push(
          deviceId: 'd',
          epoch: 7,
          table: ReadModelTables.alert,
          rows: const <Map<String, Object?>>[],
        )).failure,
        ReadModelPushFailure.server,
      );
      final _Rig n = _Rig()..reply = (int i) => http.Response('', 404);
      expect(
        (await n.client.push(
          deviceId: 'd',
          epoch: 7,
          table: ReadModelTables.alert,
          rows: const <Map<String, Object?>>[],
        )).failure,
        ReadModelPushFailure.badResponse,
      );
    });

    test(
      '시크릿 관문 — 금고 값 · 토큰 꼴이 행에 있으면 망 0 · 찾은 수만 · 연결 칸 없음 = config',
      () async {
        final Map<String, Object?> leaked = <String, Object?>{
          ..._allRows()['rm_alert']!.single,
          'body_text': '복사 실수 $_pub',
        };
        final _Rig rig = _Rig()..reply = (int i) => _answer(null, 7, 1, 0);
        final ReadModelPushResult r = await rig.client.push(
          deviceId: 'd',
          epoch: 7,
          table: ReadModelTables.alert,
          rows: <Map<String, Object?>>[leaked],
        );
        expect(r.failure, ReadModelPushFailure.secretBlocked);
        expect(r.secretFindings, greaterThan(0));
        expect(rig.rpc, isEmpty);
        expect(r.toString(), isNot(contains(_pub)));
        final Map<String, Object?> bearer = <String, Object?>{
          ..._allRows()['rm_alert']!.single,
          'action_line': 'Bearer ${'x' * 30}',
        };
        final _Rig rig2 = _Rig()..reply = (int i) => _answer(null, 7, 1, 0);
        expect(
          (await rig2.client.push(
            deviceId: 'd',
            epoch: 7,
            table: ReadModelTables.alert,
            rows: <Map<String, Object?>>[bearer],
          )).failure,
          ReadModelPushFailure.secretBlocked,
        );
        expect(rig2.rpc, isEmpty);
        final _Rig empty = _Rig();
        await empty.vault.delete(SupabaseSecretIds.projectUrl);
        empty.reply = (int i) => _answer(null, 7, 1, 0);
        expect(
          (await empty.client.push(
            deviceId: 'd',
            epoch: 7,
            table: ReadModelTables.alert,
            rows: const <Map<String, Object?>>[],
          )).failure,
          ReadModelPushFailure.config,
        );
        expect(empty.rpc, isEmpty);
      },
    );

    test('22표 표본 행 = 시크릿 관문 통과(헛경보 0)', () async {
      final _Rig rig = _Rig()..reply = (int i) => _answer(null, 7, 1, 0);
      for (final MapEntry<String, List<Map<String, Object?>>> e
          in _allRows().entries) {
        final ReadModelPushResult r = await rig.client.push(
          deviceId: 'd',
          epoch: 7,
          table: readModelTableNamed(e.key)!,
          rows: e.value,
        );
        expect(r.ok, isTrue, reason: '${e.key} $r');
      }
      expect(rig.rpc, hasLength(22));
    });
  });
}
