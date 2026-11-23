// C-69 읽기 모델 열 표(D15) — 01 §45
// (🆕 계약 v1.36 · 발주자 위임 2026-11-14 — 권고대로 · K303~K316 · 13 R230 L2).
//
// 정의: 「`rm_*` 표 22 · 열 = 결속 DTO `toJson()` 최상위 키(접두 · 제외 · 펼침 한 겹) + DTO 밖 열 + 규칙 5조 4칸 ·
//        형 = 와이어 그대로 · 뷰어 = 행 → `X.fromJson` 한 번 · A6 · 손익 열 0 · RLS = select 전용 · `app_device` 조인」.
//   ① 판 · 표본 ② 표 22 ③ 규칙 5조 · 키 ④ G-22 열 대조(옛 글자 정정 포함) ⑤ 형 ⑥ 뷰어 왕복 ⑦ 목록 봉투
//   ⑧ 금지 열 · 뷰어 판 ⑨ v1.28 · G-44 · 버전 스탬프 호환 ⑩ RLS ⑪ 창구 실재.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_fixture_registry.dart';
import 'c00_support.dart';

/// 표본에 없는 결속 DTO 의 코덱(시험이 짓는 인스턴스 · 키 집합만 본다).
final Map<String, DtoCodec<Object>> _extraCodecs = <String, DtoCodec<Object>>{
  'PerfPoint': DtoCodec<PerfPoint>(
    'PerfPoint',
    PerfPoint.fromJson,
    (PerfPoint v) => v.toJson(),
  ),
  'FeatureFlags': DtoCodec<FeatureFlags>(
    'FeatureFlags',
    FeatureFlags.fromJson,
    (FeatureFlags v) => v.toJson(),
  ),
  'AllocationProfileCard': DtoCodec<AllocationProfileCard>(
    'AllocationProfileCard',
    AllocationProfileCard.fromJson,
    (AllocationProfileCard v) => v.toJson(),
  ),
};

DtoCodec<Object>? _codecOf(String dto) {
  final DtoCodec<Object>? extra = _extraCodecs[dto];
  if (extra != null) return extra;
  for (final FixtureBinding b in fixtureBindings.values) {
    if (b.rows.typeName == dto) return b.rows;
    for (final DtoCodec<Object> c in b.extras.values) {
      if (c.typeName == dto) return c;
    }
  }
  return null;
}

/// 그 DTO 의 표본 JSON 전부(디코드 → 인코드 — 키 집합 = 생성 코드의 `toJson`).
List<Map<String, dynamic>> _samples(String dto) {
  final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
  final DtoCodec<Object> codec = _codecOf(dto)!;
  if (dto == 'PerfPoint') {
    for (final Map<String, dynamic> s in _samples('PerformanceSeries')) {
      for (final Object? p in s['points']! as List<Object?>) {
        out.add(codec.encode(codec.decode(p! as Map<String, Object?>)));
      }
    }
    return out;
  }
  if (dto == 'AllocationProfileCard') {
    for (final Map<String, dynamic> s in _samples('AllocationEditorVm')) {
      out.add(
        codec.encode(codec.decode(s['current']! as Map<String, Object?>)),
      );
    }
    return out;
  }
  if (dto == 'FeatureFlags') {
    for (final RunMode m in RunMode.values) {
      for (final OperatingMode o in OperatingMode.values) {
        out.add(
          FeatureFlags(
            satelliteEnabled: true,
            webViewerEnabled: false,
            calendarEnabled: false,
            runMode: m,
            operatingMode: o,
            configHash: 'cfg_fake_0000000000000000',
          ).toJson(),
        );
      }
    }
    return out;
  }
  fixtureBindings.forEach((String path, FixtureBinding b) {
    final Map<String, Object?> env =
        jsonDecode(readFixture(path)) as Map<String, Object?>;
    if (b.rows.typeName == dto) {
      for (final Object? r in env['rows']! as List<Object?>) {
        out.add(codec.encode(codec.decode(r! as Map<String, Object?>)));
      }
    }
    b.extras.forEach((String key, DtoCodec<Object> c) {
      if (c.typeName == dto && env[key] is Map<String, Object?>) {
        out.add(codec.encode(codec.decode(env[key]! as Map<String, Object?>)));
      }
    });
  });
  return out;
}

/// 결속 하나가 내는 열 이름(접두 · 제외 · 펼침 · `mode` = 규칙 5조 칸과 한 열).
List<String> _bindingColumns(ReadModelBinding b) {
  final Set<String> ex = b.excluded
      .map((ReadModelExclusion e) => e.key)
      .toSet();
  final List<String> out = <String>[];
  for (final String k in _samples(b.dto).first.keys) {
    if (ex.contains(k)) continue;
    final String? sub = b.flatten[k];
    if (sub != null) {
      out.addAll(_samples(sub).first.keys.map((String s) => '${b.prefix}$s'));
      continue;
    }
    if (b.prefix.isEmpty && k == 'mode') continue;
    out.add('${b.prefix}$k');
  }
  return out;
}

/// DTO JSON → 그 결속의 행 칸(push 쪽).
Map<String, Object?> _toRow(ReadModelBinding b, Map<String, dynamic> json) {
  final Set<String> ex = b.excluded
      .map((ReadModelExclusion e) => e.key)
      .toSet();
  final Map<String, Object?> row = <String, Object?>{};
  json.forEach((String k, dynamic v) {
    if (ex.contains(k)) return;
    final String? sub = b.flatten[k];
    if (sub != null) {
      (v as Map<String, dynamic>).forEach((String sk, dynamic sv) {
        row['${b.prefix}$sk'] = sv;
      });
      return;
    }
    row['${b.prefix}$k'] = v;
  });
  return row;
}

/// 행 → 그 결속의 DTO JSON(뷰어 쪽 · 접두 떼기 · 다시 묶기 · 뷰어 판 값).
Map<String, Object?> _fromRow(
  ReadModelBinding b,
  Map<String, Object?> row,
  List<String> subKeys,
) {
  final Map<String, Object?> json = <String, Object?>{};
  row.forEach((String col, Object? v) {
    if (!col.startsWith(b.prefix)) return;
    json[col.substring(b.prefix.length)] = v;
  });
  b.flatten.forEach((String k, String sub) {
    json[k] = <String, Object?>{
      for (final String sk in subKeys) sk: json.remove(sk),
    };
  });
  for (final ReadModelExclusion e in b.excluded) {
    json[e.key] = switch (e.viewerValue) {
      'null' => null,
      '[]' => <Object?>[],
      final String col => row[col] ?? row['${b.prefix}$col'],
    };
  }
  return json;
}

ReadModelColumnType _wireType(Object v) {
  if (v is String) return ReadModelColumnType.text;
  if (v is int) return ReadModelColumnType.bigint;
  if (v is double) return ReadModelColumnType.doublePrecision;
  if (v is bool) return ReadModelColumnType.boolean;
  return ReadModelColumnType.jsonb;
}

const Map<String, String> _tableNames = <String, String>{
  'rm_journal': 'J-1 일지',
  'rm_holding': 'H6 보유',
  'rm_performance_point': 'S7-2 점',
  'rm_performance_series': 'S7-2 시리즈',
  'rm_rebalance_event': 'M7 회차',
  'rm_alert': 'N-01 알림',
  'rm_safety_state': '안전 상태',
  'rm_config_view': '설정 보기',
  'rm_advice': 'A-1 안내',
  'rm_advice_summary': 'A-1 요약',
  'rm_monthly_report': 'S7-1 리포트',
  'rm_report_archive': 'S7-1b 목록',
  'rm_ledger_diff': 'L-1 차이',
  'rm_sleeve_allocation': 'H6-3 배분',
  'rm_perf_context': 'S7-3 맥락',
  'rm_disclosure_view': 'S7-2G 게이트',
  'rm_ops_summary': 'H-01 요약',
  'rm_ledger_trust': 'X7 신뢰',
  'rm_execution_gap': 'S7-10 이행 갭',
  'rm_blind_review': 'J-4 blind',
  'rm_watchdog': 'W-01 워치독',
  'rm_list_envelope': '목록 봉투',
};

String _repoSources() =>
    dartSourcesIn(Directory('${libDir.path}/src/repositories'))
        .map((File f) => stripComments(f.readAsStringSync()))
        .join('\n');

void main() {
  group('C-69 읽기 모델 열 표 (01 §45)', () {
    // 🔵 v1.37(01 §46) — 판 글자 · 표본 수 고정 = 최신 창 시험(C-70 ①)만 · 여기는 판 무관.
    test('C-69 ① 판 · 표본 — 1.36.0 이상 · 표본 393 이상(목록 = 디스크)', () {
      expect(contractVersion.compareTo('1.36.0'), greaterThanOrEqualTo(0));
      expect(FixturePaths.all.length, greaterThanOrEqualTo(393));
      expect(allFixtureFilesOnDisk().length, FixturePaths.all.length);
    });

    test('C-69 ② 표 22 — 이름 · 차례 · `rm_` 접두 · 유일', () {
      final List<String> names = ReadModelTables.all
          .map((ReadModelTable t) => t.name)
          .toList();
      expect(names, _tableNames.keys.toList());
      expect(names.toSet(), hasLength(22));
      for (final String n in names) {
        expect(n, startsWith('rm_'));
      }
    });

    test('C-69 ③ 규칙 5조 4칸 · 키 첫 칸 = mode · 키 ⊆ 열 · 열 유일', () {
      expect(
        ReadModelPushColumns.all.map((ReadModelColumn c) => (c.name, c.type)),
        <(String, ReadModelColumnType)>[
          ('row_version', ReadModelColumnType.bigint),
          ('lease_epoch', ReadModelColumnType.bigint),
          ('pushed_at', ReadModelColumnType.timestamptz),
          ('mode', ReadModelColumnType.text),
        ],
      );
      expect(
        ReadModelPushColumns.mode.checkValues,
        unorderedEquals(RunMode.values.map((RunMode m) => m.wire)),
      );
      final Set<String> push = ReadModelPushColumns.all
          .map((ReadModelColumn c) => c.name)
          .toSet();
      for (final ReadModelTable t in ReadModelTables.all) {
        final List<String> cols = t.columns
            .map((ReadModelColumn c) => c.name)
            .toList();
        expect(cols.toSet(), hasLength(cols.length), reason: t.name);
        expect(cols.toSet().intersection(push), isEmpty, reason: t.name);
        expect(t.keyColumns.first, 'mode', reason: t.name);
        for (final String k in t.keyColumns.skip(1)) {
          expect(cols, contains(k), reason: '${t.name} 키 $k');
        }
        expect(
          t.keyColumns.toSet(),
          hasLength(t.keyColumns.length),
          reason: t.name,
        );
        for (final ReadModelColumn c in t.columns) {
          expect(
            c.type,
            isNot(ReadModelColumnType.timestamptz),
            reason: '${t.name}.${c.name} — timestamptz = 규칙 5조 pushed_at 만',
          );
          if (c.checkValues.isNotEmpty) {
            expect('${t.name}.${c.name}', 'rm_config_view.operating_mode');
          }
        }
      }
    });

    test('C-69 ④ G-22 — 열 = 결속 toJson 키(접두 · 제외 · 펼침) ∪ DTO 밖 열 · 옛 글자 정정', () {
      for (final ReadModelTable t in ReadModelTables.all) {
        final List<String> expected = <String>[
          ...t.extraColumns
              .where((ReadModelExtraColumn x) => t.keyColumns.contains(x.name))
              .map((ReadModelExtraColumn x) => x.name),
          for (final ReadModelBinding b in t.bindings) ..._bindingColumns(b),
          ...t.extraColumns
              .where((ReadModelExtraColumn x) => !t.keyColumns.contains(x.name))
              .map((ReadModelExtraColumn x) => x.name),
        ];
        expect(
          t.columns.map((ReadModelColumn c) => c.name).toList(),
          expected,
          reason: '${t.name} — 열 차례 = 키 DTO 밖 → 결속(toJson 차례) → 나머지 DTO 밖',
        );
        for (final ReadModelBinding b in t.bindings) {
          final Set<String> keys = _samples(b.dto).first.keys.toSet();
          for (final ReadModelExclusion e in b.excluded) {
            expect(keys, contains(e.key), reason: '${t.name} 제외 ${e.key}');
            expect(e.reason, isNotEmpty);
          }
          for (final String k in b.flatten.keys) {
            expect(keys, contains(k), reason: '${t.name} 펼침 $k');
          }
          if (b != t.bindings.first) {
            expect(b.prefix, isNotEmpty, reason: '${t.name} 둘째 결속 = 접두(K306)');
          }
        }
      }
      // 펼친 옛 글자 → DTO 키(13 R230 ② · K304).
      List<String> cols(ReadModelTable t) =>
          t.columns.map((ReadModelColumn c) => c.name).toList();
      expect(cols(ReadModelTables.journal), contains('backdate'));
      expect(
        cols(ReadModelTables.journal),
        isNot(
          anyOf(
            contains('backdate_trading_days'),
            contains('is_backdated'),
            contains('price_range_source_date'),
          ),
        ),
      );
      expect(
        cols(ReadModelTables.advice),
        containsAll(<String>['reasons', 'decision']),
      );
      expect(
        cols(ReadModelTables.advice),
        isNot(anyOf(contains('reason_chips'), contains('decision_id'))),
      );
      expect(
        cols(ReadModelTables.adviceSummary),
        containsAll(<String>['trust', 'handover_cooling_active']),
      );
      expect(
        cols(ReadModelTables.adviceSummary)
            .where((String c) => c.startsWith('trust_')),
        isEmpty,
      );
      expect(
        cols(ReadModelTables.monthlyReport),
        contains('disclosure_view_count_text'),
      );
      expect(
        cols(ReadModelTables.monthlyReport),
        isNot(contains('disclosure_view_count')),
      );
      expect(cols(ReadModelTables.performancePoint), contains('date'));
      expect(
        cols(ReadModelTables.performancePoint),
        isNot(contains('trade_date')),
      );
    });

    test('C-69 ⑤ 형 — 와이어 그대로(표본 비null 값 · 정수만인 실수 칸 허용)', () {
      int checked = 0;
      for (final ReadModelTable t in ReadModelTables.all) {
        final Map<String, ReadModelColumnType> types =
            <String, ReadModelColumnType>{
              for (final ReadModelColumn c in t.columns) c.name: c.type,
            };
        for (final ReadModelBinding b in t.bindings) {
          for (final Map<String, dynamic> s in _samples(b.dto)) {
            _toRow(b, s).forEach((String col, Object? v) {
              if (v == null || col == 'mode') return;
              final ReadModelColumnType want = types[col]!;
              final ReadModelColumnType got = _wireType(v);
              final bool ok =
                  got == want ||
                  (want == ReadModelColumnType.doublePrecision &&
                      got == ReadModelColumnType.bigint);
              expect(
                ok,
                isTrue,
                reason: '${t.name}.$col = ${want.sql} · 표본 ${got.sql}',
              );
              checked++;
            });
          }
        }
      }
      expect(checked, greaterThan(1000));
      final Map<String, ReadModelColumnType> cfg =
          <String, ReadModelColumnType>{
            for (final ReadModelColumn c in ReadModelTables.configView.columns)
              c.name: c.type,
          };
      expect(cfg['sleeve_catalog'], ReadModelColumnType.jsonb);
      expect(
        ReadModelTables.listEnvelope.columns.map(
          (ReadModelColumn c) => (c.name, c.type),
        ),
        <(String, ReadModelColumnType)>[
          ('list_code', ReadModelColumnType.text),
          ('as_of', ReadModelColumnType.jsonb),
          ('empty_kind', ReadModelColumnType.text),
          ('empty_label', ReadModelColumnType.text),
        ],
      );
    });

    test(
      'C-69 ⑥ 뷰어 왕복 — 행 → 접두 떼기 · 다시 묶기 · 뷰어 판 값 → fromJson 한 번 · 남은 키 같음',
      () {
        int n = 0;
        for (final ReadModelTable t in ReadModelTables.all) {
          for (final ReadModelBinding b in t.bindings) {
            final DtoCodec<Object> codec = _codecOf(b.dto)!;
            final List<String> subKeys = <String>[
              for (final String sub in b.flatten.values)
                ..._samples(sub).first.keys,
            ];
            for (final Map<String, dynamic> s in _samples(b.dto)) {
              final Map<String, Object?> row = <String, Object?>{
                ...t.bindings.first == b
                    ? <String, Object?>{}
                    : _toRow(
                        t.bindings.first,
                        _samples(t.bindings.first.dto).first,
                      ),
                ..._toRow(b, s),
              };
              final Map<String, Object?> back = _fromRow(b, row, subKeys);
              final Map<String, dynamic> again = codec.encode(
                codec.decode(back),
              );
              final Set<String> ex = b.excluded
                  .map((ReadModelExclusion e) => e.key)
                  .toSet();
              for (final String k in s.keys) {
                if (ex.contains(k)) continue;
                expect(
                  jsonEncode(again[k]),
                  jsonEncode(s[k]),
                  reason: '${t.name} ${b.dto}.$k',
                );
              }
              n++;
            }
          }
        }
        expect(n, greaterThan(200));
      },
    );

    test(
      'C-69 ⑦ 목록 봉투 — 표 · 창구 = ListResult · 사전 = 표들의 목록 창구 합 · has_more 열 0',
      () {
        final List<String> fromTables = <String>[
          for (final ReadModelTable t in ReadModelTables.all) ...t.listCodes,
        ];
        expect(ReadModelListCodes.all, fromTables);
        expect(
          ReadModelListCodes.all.toSet(),
          hasLength(ReadModelListCodes.all.length),
        );
        final String src = _repoSources();
        for (final String code in ReadModelListCodes.all) {
          final String method = code.split('.').last;
          final RegExp decl = RegExp('Stream<ListResult<\\w+>>\\s+$method\\(');
          expect(decl.hasMatch(src), isTrue, reason: '$code = ListResult 창구');
        }
        final List<String> env = ReadModelTables.listEnvelope.columns
            .map((ReadModelColumn c) => c.name)
            .toList();
        expect(env, isNot(anyOf(contains('has_more'), contains('rows'))));
        expect(ReadModelTables.listEnvelope.bindings, isEmpty);
        expect(ReadModelTables.listEnvelope.keyColumns, <String>[
          'mode',
          'list_code',
        ]);
      },
    );

    test('C-69 ⑧ 금지 열 — A6 · 손익 · 폰 전용 링크 0 · 뷰어 판 열 실재', () {
      final Set<String> advice = ReadModelTables.advice.columns
          .map((ReadModelColumn c) => c.name)
          .toSet();
      const Set<String> a6 = <String>{
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
      };
      expect(advice.intersection(a6), isEmpty);
      for (final ReadModelTable t in ReadModelTables.all) {
        for (final ReadModelColumn c in t.columns) {
          expect(
            c.name,
            isNot(startsWith('pnl')),
            reason: '${t.name} — 손익 원장 금지(규칙 5조 ⑤)',
          );
        }
      }
      expect(
        ReadModelTables.ledgerDiff.columns.map((ReadModelColumn c) => c.name),
        isNot(contains('action_link')),
      );
      expect(
        ReadModelTables.adviceSummary.columns.map(
          (ReadModelColumn c) => c.name,
        ),
        isNot(
          anyOf(
            contains('manual_entry_link'),
            contains('manual_entry_notice_text'),
          ),
        ),
      );
      for (final ReadModelTable t in ReadModelTables.all) {
        final Set<String> cols = t.columns
            .map((ReadModelColumn c) => c.name)
            .toSet();
        for (final ReadModelViewerVariant v in t.viewerVariants) {
          expect(v.rule, isNotEmpty);
          if (v.keyPath.contains('[].')) {
            final List<String> p = v.keyPath.split('[].');
            expect(cols, contains(p.first), reason: '${t.name} ${v.keyPath}');
            final Map<String, dynamic> s = _samples(t.bindings.single.dto)
                .firstWhere(
                  (Map<String, dynamic> m) =>
                      (m[p.first] as List<Object?>).isNotEmpty,
                );
            expect(
              ((s[p.first] as List<Object?>).first! as Map<String, Object?>)
                  .keys,
              contains(p.last),
              reason: '${t.name} ${v.keyPath}',
            );
          } else {
            expect(cols, contains(v.keyPath), reason: '${t.name} ${v.keyPath}');
          }
        }
      }
      expect(
        ReadModelTables.sleeveAllocation.viewerVariants.map(
          (ReadModelViewerVariant v) => v.keyPath,
        ),
        <String>['rows[].deployed_text', 'rows[].parking_text'],
      );
    });

    test('C-69 ⑨ v1.28 배분 7열 · G-44 월 납입 · 버전 스탬프 · operating_mode check', () {
      final List<String> cfg = ReadModelTables.configView.columns
          .map((ReadModelColumn c) => c.name)
          .toList();
      final List<int> idx = AllocationReadModelColumns.all
          .map(cfg.indexOf)
          .toList();
      expect(idx, everyElement(greaterThanOrEqualTo(0)));
      expect(idx, orderedEquals(<int>[...idx]..sort()));
      expect(
        cfg,
        containsAll(<String>[
          'operating_mode',
          'contribution_amount',
          'contribution_amount_text',
          'contribution_equivalent_note_text',
          'contribution_applies_from_text',
          'contribution_last_changed_text',
          'contribution_pension_limit_note_text',
          'contribution_amount_input_text',
          'contribution_as_of',
          'sleeve_catalog',
        ]),
      );
      final Map<String, ReadModelColumn> byName = <String, ReadModelColumn>{
        for (final ReadModelColumn c in ReadModelTables.configView.columns)
          c.name: c,
      };
      expect(byName['schema_version']!.type, ReadModelColumnType.bigint);
      expect(byName['hash_format_version']!.type, ReadModelColumnType.bigint);
      expect(byName['contract_version']!.type, ReadModelColumnType.text);
      expect(
        byName['operating_mode']!.checkValues,
        unorderedEquals(OperatingMode.values.map((OperatingMode m) => m.wire)),
      );
    });

    test('C-69 ⑩ RLS — select 전용 · app_device ACTIVE 조인 · JWT 클레임 0', () {
      expect(ReadModelRls.selectRole, 'authenticated');
      expect(ReadModelRls.selectPolicyName('rm_journal'), 'rm_journal_select');
      expect(ReadModelRls.selectUsing, contains('app_device'));
      expect(ReadModelRls.selectUsing, contains('auth.uid()'));
      expect(ReadModelRls.selectUsing, contains("d.status = 'ACTIVE'"));
      expect(ReadModelRls.selectUsing.toLowerCase(), isNot(contains('jwt')));
      expect(ReadModelRls.selectUsing.toLowerCase(), isNot(contains('true')));
    });

    test('C-69 ⑪ 창구 실재 — feeds «저장소.메서드» 가 계약 저장소에 있다 · DTO 밖 열 출처', () {
      final String src = _repoSources();
      for (final ReadModelTable t in ReadModelTables.all) {
        for (final ReadModelBinding b in t.bindings) {
          for (final String f in b.feeds) {
            final List<String> p = f.split('.');
            expect(
              RegExp('interface class ${p.first}\\b').hasMatch(src),
              isTrue,
              reason: '${t.name} $f 저장소',
            );
            expect(
              RegExp('\\b${p.last}\\(').hasMatch(src),
              isTrue,
              reason: '${t.name} $f',
            );
          }
        }
        for (final ReadModelExtraColumn x in t.extraColumns) {
          expect(x.source, isNotEmpty, reason: '${t.name}.${x.name}');
        }
      }
    });
  });
}
