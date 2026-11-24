// 시험 도우미 — 계약 표본 → 결속 DTO 표본 JSON · push 쪽 행 흉내(C-69 ④ ⑥ 꼴 · 구현과 따로 적는다).
//
// 🔴 표본 = `domain_contracts/fixtures/**` 의 봉투 `rows` 원소 + 봉투 머리 객체 — `X.fromJson` 이 읽고 다시 낸 키가
//    원문 키와 같을 때만 X 의 표본(등록부 없이 고른다 · 고른 것 = 그 DTO 로 손실 없이 읽히는 인스턴스).
// 🔴 행 흉내는 이 파일이 계약 상수(접두 · 제외 · 펼침 · DTO 밖 열)만 보고 짓는다 — `read_model_rows.dart` 를 부르지 않는다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';

/// 계약 표본 폴더(패키지 뿌리에서).
const String fixturesDir = '../domain_contracts/fixtures';

/// DTO 하나의 `fromJson` / `toJson` 짝.
final class Codec {
  Codec(this.name, this._from, this._to);

  /// 계약 타입 이름.
  final String name;
  final Object Function(Map<String, dynamic>) _from;
  final Map<String, dynamic> Function(Object) _to;

  /// JSON → DTO.
  Object decode(Map<String, Object?> j) => _from(j);

  /// DTO → JSON.
  Map<String, dynamic> encode(Object v) => _to(v);
}

Codec _c<T extends Object>(
  String name,
  T Function(Map<String, dynamic>) from,
  Map<String, dynamic> Function(T) to,
) => Codec(name, from, (Object v) => to(v as T));

/// 결속 DTO 25 + 펼침 · DTO 밖 목록 열 원소.
final Map<String, Codec> codecs = <String, Codec>{
  for (final Codec c in <Codec>[
    _c(
      'TradeJournalEntry',
      TradeJournalEntry.fromJson,
      (TradeJournalEntry v) => v.toJson(),
    ),
    _c('HoldingRow', HoldingRow.fromJson, (HoldingRow v) => v.toJson()),
    _c('PerfPoint', PerfPoint.fromJson, (PerfPoint v) => v.toJson()),
    _c(
      'PerformanceSeries',
      PerformanceSeries.fromJson,
      (PerformanceSeries v) => v.toJson(),
    ),
    _c(
      'RebalanceEvent',
      RebalanceEvent.fromJson,
      (RebalanceEvent v) => v.toJson(),
    ),
    _c(
      'JournalRebalanceScope',
      JournalRebalanceScope.fromJson,
      (JournalRebalanceScope v) => v.toJson(),
    ),
    _c('AlertItem', AlertItem.fromJson, (AlertItem v) => v.toJson()),
    _c('SafetyState', SafetyState.fromJson, (SafetyState v) => v.toJson()),
    _c('FeatureFlags', FeatureFlags.fromJson, (FeatureFlags v) => v.toJson()),
    _c(
      'ContributionSetting',
      ContributionSetting.fromJson,
      (ContributionSetting v) => v.toJson(),
    ),
    _c(
      'AllocationEditorVm',
      AllocationEditorVm.fromJson,
      (AllocationEditorVm v) => v.toJson(),
    ),
    _c(
      'AllocationProfileCard',
      AllocationProfileCard.fromJson,
      (AllocationProfileCard v) => v.toJson(),
    ),
    _c('AdviceItem', AdviceItem.fromJson, (AdviceItem v) => v.toJson()),
    _c(
      'AdviceInboxSummary',
      AdviceInboxSummary.fromJson,
      (AdviceInboxSummary v) => v.toJson(),
    ),
    _c(
      'MonthlyReport',
      MonthlyReport.fromJson,
      (MonthlyReport v) => v.toJson(),
    ),
    _c(
      'ReportArchiveVm',
      ReportArchiveVm.fromJson,
      (ReportArchiveVm v) => v.toJson(),
    ),
    _c(
      'LedgerDiffRow',
      LedgerDiffRow.fromJson,
      (LedgerDiffRow v) => v.toJson(),
    ),
    _c(
      'SleeveAllocationVm',
      SleeveAllocationVm.fromJson,
      (SleeveAllocationVm v) => v.toJson(),
    ),
    _c(
      'DrawdownContextVm',
      DrawdownContextVm.fromJson,
      (DrawdownContextVm v) => v.toJson(),
    ),
    _c(
      'ContributionVm',
      ContributionVm.fromJson,
      (ContributionVm v) => v.toJson(),
    ),
    _c(
      'DisclosureGateVm',
      DisclosureGateVm.fromJson,
      (DisclosureGateVm v) => v.toJson(),
    ),
    _c(
      'OpsDailySummary',
      OpsDailySummary.fromJson,
      (OpsDailySummary v) => v.toJson(),
    ),
    _c(
      'LedgerTrustBadge',
      LedgerTrustBadge.fromJson,
      (LedgerTrustBadge v) => v.toJson(),
    ),
    _c(
      'ExecutionGapResult',
      ExecutionGapResult.fromJson,
      (ExecutionGapResult v) => v.toJson(),
    ),
    _c(
      'BlindReviewCard',
      BlindReviewCard.fromJson,
      (BlindReviewCard v) => v.toJson(),
    ),
    _c(
      'WatchdogBoardVm',
      WatchdogBoardVm.fromJson,
      (WatchdogBoardVm v) => v.toJson(),
    ),
    _c(
      'SleeveCatalogEntry',
      SleeveCatalogEntry.fromJson,
      (SleeveCatalogEntry v) => v.toJson(),
    ),
    _c('OpsRhythmRow', OpsRhythmRow.fromJson, (OpsRhythmRow v) => v.toJson()),
  ])
    c.name: c,
};

Map<String, List<Map<String, dynamic>>>? _cache;

/// DTO 이름 → 표본 JSON(디코드 → 인코드 · 키 = 생성 코드의 `toJson`).
Map<String, List<Map<String, dynamic>>> samples() => _cache ??= _collect();

Map<String, List<Map<String, dynamic>>> _collect() {
  final Map<String, List<Map<String, dynamic>>> out =
      <String, List<Map<String, dynamic>>>{
        for (final String n in codecs.keys) n: <Map<String, dynamic>>[],
      };
  final List<File> files =
      Directory(fixturesDir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.json'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));
  for (final File f in files) {
    final Object? env = jsonDecode(f.readAsStringSync());
    if (env is! Map<String, Object?>) continue;
    final List<Map<String, Object?>> cands = <Map<String, Object?>>[
      if (env['rows'] case final List<Object?> rows)
        for (final Object? r in rows)
          if (r is Map<String, Object?>) r,
      for (final MapEntry<String, Object?> e in env.entries)
        if (e.key != 'meta' &&
            e.key != 'as_of' &&
            e.value is Map<String, Object?>)
          e.value! as Map<String, Object?>,
    ];
    for (final Map<String, Object?> j in cands) {
      codecs.forEach((String name, Codec c) {
        if (name == 'PerfPoint' || name == 'AllocationProfileCard') return;
        final Map<String, dynamic>? s = _exact(c, j);
        if (s != null) out[name]!.add(s);
      });
    }
  }
  for (final Map<String, dynamic> s in out['PerformanceSeries']!) {
    for (final Object? p in s['points']! as List<Object?>) {
      out['PerfPoint']!.add(
        codecs['PerfPoint']!.encode(
          codecs['PerfPoint']!.decode(p! as Map<String, Object?>),
        ),
      );
    }
  }
  for (final Map<String, dynamic> s in out['AllocationEditorVm']!) {
    out['AllocationProfileCard']!.add(
      _roundTrip(
        codecs['AllocationProfileCard']!,
        s['current']! as Map<String, Object?>,
      ),
    );
  }
  for (final RunMode m in RunMode.values) {
    for (final OperatingMode o in OperatingMode.values) {
      out['FeatureFlags']!.add(
        FeatureFlags(
          satelliteEnabled: m == RunMode.live,
          webViewerEnabled: o == OperatingMode.advisory,
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

Map<String, dynamic> _roundTrip(Codec c, Map<String, Object?> j) =>
    jsonDecode(jsonEncode(c.encode(c.decode(j)))) as Map<String, dynamic>;

/// 원문 키 ⊆ 다시 낸 키 · 원문에 없는 키 = null 값(표본이 null 칸을 적지 않은 것)일 때만 X 의 표본.
Map<String, dynamic>? _exact(Codec c, Map<String, Object?> j) {
  try {
    final Map<String, dynamic> s = _roundTrip(c, j);
    if (!s.keys.toSet().containsAll(j.keys)) return null;
    for (final String k in s.keys) {
      if (!j.containsKey(k) && s[k] != null) return null;
    }
    return s;
  } on Object {
    return null;
  }
}

/// DTO 밖 열 흉내 값(K308 — 출처 글자의 꼴 · 와이어 그대로).
Object? extraValue(String table, String column) => switch (column) {
  'trade_date' => '2026-11-20',
  'metric' => PerfMetric.twr.wire,
  'granularity' => PerfGranularity.daily.wire,
  'cumulative' => true,
  'sleeve_catalog' => samples()['SleeveCatalogEntry'],
  'schema_version' => schemaVersion,
  'hash_format_version' => hashFormatVersion,
  'contract_version' => contractVersion,
  'range_preset_code' => 'LAST_3M',
  'is_default' => true,
  'yyyy_mm' => '2026-10',
  'rhythm' => samples()['OpsRhythmRow'],
  _ => throw StateError('$table.$column: 흉내 값 없음'),
};

/// push 쪽 행 흉내 — [bySample] = 결속 DTO 이름 → 그 결속 표본(없는 결속 = 그 DTO 첫 표본).
///
/// 🔴 행 키 = 규칙 5조 4칸 ∪ 표 열(정확히) — 다르면 [StateError](흉내가 계약 표와 어긋남).
Map<String, Object?> rowOf(
  ReadModelTable table, {
  Map<String, Map<String, dynamic>> bySample =
      const <String, Map<String, dynamic>>{},
}) {
  final Map<String, Object?> row = <String, Object?>{
    'row_version': 3,
    'lease_epoch': 2,
    'pushed_at': '2026-11-24T00:00:00.000Z',
    'mode': RunMode.live.wire,
  };
  for (final ReadModelBinding b in table.bindings) {
    final Map<String, dynamic> s = bySample[b.dto] ?? samples()[b.dto]!.first;
    final Set<String> ex = <String>{
      for (final ReadModelExclusion e in b.excluded) e.key,
    };
    s.forEach((String k, dynamic v) {
      if (ex.contains(k)) return;
      if (b.flatten.containsKey(k)) {
        (v as Map<String, dynamic>).forEach((String sk, dynamic sv) {
          row['${b.prefix}$sk'] = sv;
        });
        return;
      }
      row['${b.prefix}$k'] = v;
    });
  }
  for (final ReadModelExtraColumn e in table.extraColumns) {
    row[e.name] = extraValue(table.name, e.name);
  }
  // 🆕 계약 v1.39(01 §48 K339) — 목록 열 = 엔진이 채우기 전(null · 결속 밖 · push 빌더 비요구).
  for (final ReadModelListColumn l in table.listColumns) {
    row[l.name] = null;
  }
  final Set<String> want = <String>{
    for (final ReadModelColumn c in ReadModelPushColumns.all) c.name,
    for (final ReadModelColumn c in table.columns) c.name,
  };
  final Set<String> got = row.keys.toSet();
  if (got.length != want.length || !got.containsAll(want)) {
    throw StateError(
      '${table.name}: 흉내 행 키 어긋남 — 남음 ${got.difference(want)} · 빠짐 ${want.difference(got)}',
    );
  }
  return jsonDecode(jsonEncode(row)) as Map<String, Object?>;
}

/// 뷰어가 받아야 할 DTO JSON — 표본에서 제외 키만 뷰어 판 값으로(C-69 ⑥).
Map<String, dynamic> viewerExpected(
  ReadModelBinding b,
  Map<String, dynamic> sample,
  Map<String, Object?> row,
) {
  final Map<String, dynamic> out = Map<String, dynamic>.of(sample);
  for (final ReadModelExclusion e in b.excluded) {
    out[e.key] = switch (e.viewerValue) {
      'null' => null,
      '[]' => <Object?>[],
      final String col => row[col],
    };
  }
  return out;
}

/// 키 차례와 무관한 JSON 글자(맵 키 정렬).
String canonical(Object? v) => jsonEncode(_sorted(v));

Object? _sorted(Object? v) => switch (v) {
  final Map<String, Object?> m => <String, Object?>{
    for (final String k in m.keys.toList()..sort()) k: _sorted(m[k]),
  },
  final List<Object?> l => <Object?>[for (final Object? e in l) _sorted(e)],
  _ => v,
};
