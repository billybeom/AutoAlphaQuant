// 🆕 E11-viewer-223(01 §8 미결 223 ⓐ · 계약 v1.36 §45) — 읽기 모델 22표 행 → 계약 DTO.
//
// 🔴 원천 = 계약 표본(봉투 `rows` · 머리 객체 — 정확 왕복만) · 행 흉내 = 계약 상수만 보고 짓는다(`support/contract_samples.dart`).
// 🔴 못 읽으면 던진다(빈 DTO · 기본 값 0 — K206 뷰어 판): 열 없음 · 형 틀림 · 모르는 와이어 값 = FormatException ·
//    null 칸은 «던지거나 null 그대로» — 기본 값으로 메우는 갈래 0.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:read_model_client/read_model_client.dart';
import 'package:test/test.dart';

import 'support/contract_samples.dart';

Matcher get _fmt => throwsA(isA<FormatException>());

Map<String, dynamic> _enc(ReadModelReader<Object> r, Object v) =>
    jsonDecode(jsonEncode(codecs[r.dto]!.encode(v))) as Map<String, dynamic>;

void main() {
  test('결속 읽개 = 표 상수의 결속 전부(25) · 표 · 결속 차례 · 봉투 표 = 결속 0', () {
    final List<(String, String)> fromTables = <(String, String)>[
      for (final ReadModelTable t in ReadModelTables.all)
        for (final ReadModelBinding b in t.bindings) (t.name, b.dto),
    ];
    expect(<(String, String)>[
      for (final ReadModelReader<Object> r in ReadModelReaders.all)
        (r.table.name, r.dto),
    ], fromTables);
    expect(fromTables, hasLength(25));
    expect(ReadModelTables.listEnvelope.bindings, isEmpty);
    for (final ReadModelReader<Object> r in ReadModelReaders.all) {
      expect(identical(r.binding.dto, r.dto) || r.binding.dto == r.dto, isTrue);
    }
  });

  test('결속 열 = 표 열(규칙 5조 밖) 을 결속끼리 겹침 없이 나눈다 · 남는 것 = DTO 밖 열', () {
    for (final ReadModelTable t in ReadModelTables.all) {
      final List<String> all = <String>[
        for (final ReadModelBinding b in t.bindings)
          ...readModelBindingColumns(t, b),
      ];
      expect(all.toSet(), hasLength(all.length), reason: '${t.name} 겹침');
      final Set<String> rest = <String>{
        for (final ReadModelColumn c in t.columns) c.name,
      }.difference(all.toSet());
      expect(rest, <String>{
        for (final ReadModelExtraColumn e in t.extraColumns) e.name,
      }, reason: t.name);
    }
  });

  test('표본 왕복 — 행(접두 · 펼침 · 제외) → fromRow → 표본(제외 키 = 뷰어 판 값)', () {
    int n = 0;
    for (final ReadModelReader<Object> r in ReadModelReaders.all) {
      final List<Map<String, dynamic>> ss = samples()[r.dto]!;
      expect(ss, isNotEmpty, reason: '${r.dto} 표본 0');
      for (final Map<String, dynamic> s in ss) {
        final Map<String, Object?> row = rowOf(
          r.table,
          bySample: <String, Map<String, dynamic>>{r.dto: s},
        );
        final Map<String, dynamic> got = _enc(r, r.fromRow(row));
        expect(
          canonical(got),
          canonical(viewerExpected(r.binding, s, row)),
          reason: '${r.table.name}(${r.dto})',
        );
        n++;
      }
    }
    expect(n, greaterThan(200));
  });

  test('제외 키 = 뷰어 판 값 — A6 10 · 손익 · 폰 전용 링크 · 회차 id = event_id', () {
    final AdviceItem a = ReadModelReaders.advice.fromRow(
      rowOf(ReadModelTables.advice),
    );
    expect(a.symbol, isNull);
    expect(a.symbolLabel, isNull);
    expect(a.side, isNull);
    expect(a.sideLabel, isNull);
    expect(a.quantity, isNull);
    expect(a.priceBand, isNull);
    expect(a.recordedQuantity, isNull);
    expect(a.prefillQuantityText, isNull);
    expect(a.prefillQuantityLabel, isNull);
    expect(a.actions, isEmpty);
    expect(
      ReadModelReaders.holding.fromRow(rowOf(ReadModelTables.holding)).pnl,
      isNull,
    );
    expect(
      ReadModelReaders.ledgerDiff
          .fromRow(rowOf(ReadModelTables.ledgerDiff))
          .actionLink,
      isNull,
    );
    final AdviceInboxSummary sum = ReadModelReaders.adviceSummary.fromRow(
      rowOf(ReadModelTables.adviceSummary),
    );
    expect(sum.manualEntryLink, isNull);
    expect(sum.manualEntryNoticeText, isNull);
    final Map<String, Object?> ev = rowOf(ReadModelTables.rebalanceEvent);
    expect(
      ReadModelReaders.rebalanceScope.fromRow(ev).rebalanceEventId,
      ev['event_id'],
    );
    expect(
      ReadModelReaders.performanceSeries
          .fromRow(rowOf(ReadModelTables.performanceSeries))
          .points,
      isEmpty,
    );
  });

  test('행에 결속 열이 없으면(키 부재) FormatException — 열마다', () {
    int n = 0;
    for (final ReadModelReader<Object> r in ReadModelReaders.all) {
      final Map<String, Object?> row = rowOf(r.table);
      for (final String col in <String>[
        ...readModelBindingColumns(r.table, r.binding),
        if (r.binding.prefix.isEmpty) 'mode',
      ]) {
        final Map<String, Object?> cut = Map<String, Object?>.of(row)
          ..remove(col);
        expect(
          () => r.fromRow(cut),
          _fmt,
          reason: '${r.table.name}(${r.dto}).$col',
        );
        n++;
      }
    }
    expect(n, greaterThan(290));
  });

  test('null 칸 = 던지거나 null 그대로(기본 값으로 메우지 않는다) — 열마다', () {
    int thrown = 0;
    for (final ReadModelReader<Object> r in ReadModelReaders.all) {
      final Map<String, Object?> row = rowOf(r.table);
      for (final String col in readModelBindingColumns(r.table, r.binding)) {
        final Map<String, Object?> nulled = Map<String, Object?>.of(row)
          ..[col] = null;
        final Object got;
        try {
          got = r.fromRow(nulled);
        } on FormatException {
          thrown++;
          continue;
        }
        final String key = col.substring(r.binding.prefix.length);
        final Map<String, dynamic> j = _enc(r, got);
        final Map<String, dynamic> holder = j.containsKey(key)
            ? j
            : j.values.whereType<Map<String, dynamic>>().firstWhere(
                (Map<String, dynamic> m) => m.containsKey(key),
              );
        final Object? v = holder[key];
        expect(v, isNull, reason: '${r.table.name}(${r.dto}).$col 메움');
      }
    }
    expect(thrown, greaterThan(100));
  });

  test('형 틀림 = FormatException — 값 있는 열마다(글자 ↔ 수)', () {
    int n = 0;
    for (final ReadModelReader<Object> r in ReadModelReaders.all) {
      final Map<String, Object?> row = rowOf(r.table);
      for (final String col in readModelBindingColumns(r.table, r.binding)) {
        final Object? v = row[col];
        if (v == null) continue;
        final Map<String, Object?> bad = Map<String, Object?>.of(row)
          ..[col] = v is String ? 12345 : 'x';
        expect(
          () => r.fromRow(bad),
          _fmt,
          reason: '${r.table.name}(${r.dto}).$col',
        );
        n++;
      }
    }
    expect(n, greaterThan(200));
  });

  test('모르는 와이어 값 · 모르는 mode = FormatException', () {
    final Map<String, Object?> s = rowOf(ReadModelTables.safetyState)
      ..['breaker_level'] = 'NOPE';
    expect(() => ReadModelReaders.safetyState.fromRow(s), _fmt);
    final Map<String, Object?> j = rowOf(ReadModelTables.journal)
      ..['mode'] = 'PAPER';
    expect(() => ReadModelReaders.journalEntry.fromRow(j), _fmt);
    final Map<String, Object?> f = rowOf(ReadModelTables.configView)
      ..['operating_mode'] = 'MANUAL';
    expect(() => ReadModelReaders.featureFlags.fromRow(f), _fmt);
  });

  test('규칙 5조 · 버전 스탬프 · 다른 결속 칸은 결속 JSON 에 들어가지 않는다', () {
    final Map<String, Object?> row = rowOf(ReadModelTables.configView);
    final Map<String, Object?> flags = readModelBindingJson(
      ReadModelTables.configView,
      ReadModelTables.configView.bindings.first,
      row,
    );
    expect(flags.keys.toSet(), <String>{
      'satellite_enabled',
      'web_viewer_enabled',
      'calendar_enabled',
      'run_mode',
      'operating_mode',
      'config_hash',
      'mode',
    });
    final Map<String, Object?> alloc = readModelBindingJson(
      ReadModelTables.configView,
      ReadModelTables.configView.bindings[2],
      row,
    );
    expect(alloc.keys.toSet(), <String>{
      'current',
      'sections',
      'change_path_lines',
      'as_of',
    });
    expect((alloc['current']! as Map<String, Object?>).keys.toSet(), <String>{
      'label',
      'weights_text',
      'backtest_text',
      'honest_note_text',
    });
  });

  test('배분 결속 = v1.28 allocationEditorVmFromColumns 와 같은 VM(표본 전부)', () {
    for (final Map<String, dynamic> s in samples()['AllocationEditorVm']!) {
      final Map<String, Object?> row = rowOf(
        ReadModelTables.configView,
        bySample: <String, Map<String, dynamic>>{'AllocationEditorVm': s},
      );
      expect(
        ReadModelReaders.allocationEditor.fromRow(row),
        allocationEditorVmFromColumns(row),
      );
    }
  });

  test('모르는 펼침 = StateError(계약 새 판 — 뷰어가 따라가야 한다)', () {
    const ReadModelTable t = ReadModelTable(
      name: 'rm_fake',
      keyColumns: <String>['mode'],
      columns: <ReadModelColumn>[
        ReadModelColumn('x_a', ReadModelColumnType.text),
      ],
      bindings: <ReadModelBinding>[
        ReadModelBinding(
          'Fake',
          prefix: 'x_',
          flatten: <String, String>{'a': 'UnknownCard'},
        ),
      ],
    );
    expect(
      () => readModelBindingJson(t, t.bindings.single, <String, Object?>{
        'x_a': 'v',
      }),
      throwsA(isA<StateError>()),
    );
  });

  group('시리즈 + 점', () {
    Map<String, Object?> point(String date, {Object? value = 0.5}) =>
        <String, Object?>{
          ...rowOf(ReadModelTables.performancePoint),
          'date': date,
          'value': value,
        };

    test('점 = `date` 오름차순(받은 차례와 무관) · 결측 점(value null) 그대로', () {
      final PerformanceSeries s = performanceSeriesOfRows(
        rowOf(ReadModelTables.performanceSeries),
        <Map<String, Object?>>[
          point('2026-11-03'),
          point('2026-11-01', value: null),
          point('2026-11-02'),
        ],
      );
      expect(s.points.map((PerfPoint p) => p.date.yyyyMmDd).toList(), <String>[
        '2026-11-01',
        '2026-11-02',
        '2026-11-03',
      ]);
      expect(s.points.first.value, isNull);
    });

    test('다른 시리즈의 점 = FormatException', () {
      for (final (String k, Object v) in <(String, Object)>[
        ('metric', PerfMetric.mwr.wire),
        ('granularity', PerfGranularity.monthly.wire),
        ('cumulative', false),
      ]) {
        expect(
          () => performanceSeriesOfRows(
            rowOf(ReadModelTables.performanceSeries),
            <Map<String, Object?>>[
              <String, Object?>{...point('2026-11-01'), k: v},
            ],
          ),
          _fmt,
          reason: k,
        );
      }
    });
  });

  group('DTO 밖 목록 열', () {
    test('sleeve_catalog · rhythm = 받은 순서 그대로', () {
      final Map<String, Object?> cfg = rowOf(ReadModelTables.configView);
      expect(
        canonical(<Object?>[
          for (final SleeveCatalogEntry e in sleeveCatalogOfRow(cfg))
            e.toJson(),
        ]),
        canonical(cfg['sleeve_catalog']),
      );
      final Map<String, Object?> ops = rowOf(ReadModelTables.opsSummary);
      final List<Object?> reversed = (ops['rhythm']! as List<Object?>).reversed
          .toList();
      expect(
        canonical(<Object?>[
          for (final OpsRhythmRow r in opsRhythmOfRow(<String, Object?>{
            ...ops,
            'rhythm': reversed,
          }))
            r.toJson(),
        ]),
        canonical(reversed),
      );
    });

    test('원소 칸 null = 던지거나 null 그대로(원소 DTO 기본 값으로 메우지 않는다)', () {
      int n = 0;
      for (final (
            String col,
            List<Map<String, dynamic>> Function(Map<String, Object?>) read,
            Map<String, Object?> row,
          )
          in <
            (
              String,
              List<Map<String, dynamic>> Function(Map<String, Object?>),
              Map<String, Object?>,
            )
          >[
            (
              'sleeve_catalog',
              (Map<String, Object?> r) => <Map<String, dynamic>>[
                for (final SleeveCatalogEntry e in sleeveCatalogOfRow(r))
                  e.toJson(),
              ],
              rowOf(ReadModelTables.configView),
            ),
            (
              'rhythm',
              (Map<String, Object?> r) => <Map<String, dynamic>>[
                for (final OpsRhythmRow e in opsRhythmOfRow(r)) e.toJson(),
              ],
              rowOf(ReadModelTables.opsSummary),
            ),
          ]) {
        final Map<String, Object?> first =
            (row[col]! as List<Object?>).first! as Map<String, Object?>;
        for (final String k in first.keys) {
          final Map<String, Object?> bad = <String, Object?>{
            ...row,
            col: <Object?>[
              <String, Object?>{...first, k: null},
            ],
          };
          final List<Map<String, dynamic>> got;
          try {
            got = read(bad);
          } on FormatException {
            n++;
            continue;
          }
          expect(got.single[k], isNull, reason: '$col[0].$k 메움');
        }
      }
      expect(n, greaterThan(3));
    });

    test('열 없음 · 목록 아님 · 원소 객체 아님 · 원소 꼴 틀림 = FormatException', () {
      final Map<String, Object?> cfg = rowOf(ReadModelTables.configView);
      expect(
        () => sleeveCatalogOfRow(
          Map<String, Object?>.of(cfg)..remove('sleeve_catalog'),
        ),
        _fmt,
      );
      expect(
        () => sleeveCatalogOfRow(<String, Object?>{
          ...cfg,
          'sleeve_catalog': null,
        }),
        _fmt,
      );
      expect(
        () => sleeveCatalogOfRow(<String, Object?>{
          ...cfg,
          'sleeve_catalog': <Object?>['x'],
        }),
        _fmt,
      );
      expect(
        () => opsRhythmOfRow(<String, Object?>{
          ...rowOf(ReadModelTables.opsSummary),
          'rhythm': <Object?>[
            <String, Object?>{'code': 1},
          ],
        }),
        _fmt,
      );
    });
  });
}
