// 🆕 E11l2b — 읽기 모델 행 빌더(순수 · 설계 13 §8 R256 · 01 §8 미결 222 ⓒ ⓓ · 01 §45 · §47 · 06 M4-1).
//
// 🔵 입력 = 결속 DTO 의 `toJson()`(타입 이름 → 와이어 JSON) + DTO 밖 열 + 뷰어 판 값 · 출력 = `rm_push` 의 `p_rows` 한 칸.
//    열 이름 · 접두 · 제외 · 펼침 · 키는 계약 `ReadModelTables` 에서만 읽는다(이 파일이 짓는 열 0).
// 🔴 `lease_epoch` · `pushed_at` 은 싣지 않는다 — 서버(`rm_push`)가 인자 epoch · `now()` 로 덮는다(01 §47 K332).
// 🔴 제외 키(A6 · 손익 · 폰 전용 링크)는 행에 나가지 않는다 — 열이 없으니 실을 수도 없다(K307).
// 🔴 뷰어 판 열(K309): ⓐ 중첩 경로(`rows[].deployed_text` …) = 빌더가 엔진 가림 글자(`HoldingsTexts.hidden` · 금액 0)로 덮는다
//    ⓑ 바로 열(`rm_advice` `sizing_label` · `progress_label`) = 생산자가 뷰어 판 값을 [ReadModelRowInput.viewer] 로 줘야 한다 —
//    없으면 행을 만들지 않는다(폰 판 글자가 뷰어로 새지 않게 · 기본값 0).
// 🔴 `rm_config_view` 버전 스탬프 3 = 빌더가 계약 상수로 채운다(규칙 5조 ⑥ «push 마다 함께» · 부르는 쪽이 주지 않는다).

import 'package:core_engine/core_engine.dart' show HoldingsTexts;
import 'package:domain_contracts/domain_contracts.dart'
    show
        EmptyKind,
        ReadModelBinding,
        ReadModelColumn,
        ReadModelExclusion,
        ReadModelExtraColumn,
        ReadModelListCodes,
        ReadModelPushColumns,
        ReadModelTable,
        ReadModelTables,
        ReadModelViewerVariant,
        RunMode,
        contractVersion,
        hashFormatVersion,
        schemaVersion;

/// 뷰어 판 중첩 경로를 덮는 가림 글자(엔진 · 금액 0 — 04 §2-6).
const String kReadModelViewerMaskText = HoldingsTexts.hidden;

/// `rm_config_view` 에서 빌더가 채우는 DTO 밖 열(버전 스탬프 3).
const Set<String> kReadModelStampColumns = <String>{
  'schema_version',
  'hash_format_version',
  'contract_version',
};

/// 행 하나의 입력.
class ReadModelRowInput {
  /// 만든다.
  const ReadModelRowInput({
    required this.mode,
    required this.rowVersion,
    this.dtos = const <String, Map<String, Object?>>{},
    this.extras = const <String, Object?>{},
    this.viewer = const <String, Object?>{},
  });

  /// 행의 모드(규칙 5조 ① · 키 첫 칸).
  final RunMode mode;

  /// 행 판(규칙 5조 ② — 큰 쪽만 반영).
  final int rowVersion;

  /// 결속 DTO 타입 이름 → `toJson()`(첫 결속 = 필수 · 둘째부터 = 없으면 그 열들 null ·
  /// 🆕 E11l2c-3(R268) 결속이 모두 접두를 가진 표(대등 결속 — `rm_perf_context` 드로다운 · 기여) = 하나 이상).
  final Map<String, Map<String, Object?>> dtos;

  /// DTO 밖 열(버전 스탬프 제외 — 빌더가 채운다).
  final Map<String, Object?> extras;

  /// 바로 열 뷰어 판 값(열 이름 → 값 · `rm_advice` `sizing_label` · `progress_label`).
  final Map<String, Object?> viewer;

  /// 🆕 E11l2c(R263) — 판만 바꾼 사본(원천은 판을 모른다 · push 일이 붙인다).
  ReadModelRowInput withRowVersion(int v) => ReadModelRowInput(
    mode: mode,
    rowVersion: v,
    dtos: dtos,
    extras: extras,
    viewer: viewer,
  );
}

/// 행을 만들 수 없다(🔴 값 · 발췌 없음 — 표 · 칸 · 사유만).
class ReadModelRowError implements Exception {
  /// 만든다.
  const ReadModelRowError(this.table, this.reason);

  /// 표 이름.
  final String table;

  /// 사유.
  final String reason;

  @override
  String toString() => 'ReadModelRowError($table: $reason)';
}

/// 표 이름 → 계약 표(모르는 이름 = null).
ReadModelTable? readModelTableNamed(String name) {
  for (final ReadModelTable t in ReadModelTables.all) {
    if (t.name == name) return t;
  }
  return null;
}

/// [t] 의 행 하나(`rm_push` `p_rows` 의 한 칸 · 열 이름 → 와이어 값).
Map<String, Object?> readModelRow(ReadModelTable t, ReadModelRowInput input) {
  final Map<String, Object?> row = <String, Object?>{
    ReadModelPushColumns.rowVersion.name: input.rowVersion,
    ReadModelPushColumns.mode.name: input.mode.wire,
  };
  // 🆕 E11l2c-3(R268) — 첫 결속에 접두가 없음 = 표의 주 DTO(필수) · 모두 접두 = 대등 결속(하나 이상 · 나머지 열 null).
  final bool peers =
      t.bindings.isNotEmpty &&
      t.bindings.every((ReadModelBinding b) => b.prefix.isNotEmpty);
  if (peers &&
      !t.bindings.any((ReadModelBinding b) => input.dtos[b.dto] != null)) {
    throw ReadModelRowError(t.name, '대등 결속 DTO 하나도 없음');
  }
  for (final ReadModelBinding b in t.bindings) {
    final Map<String, Object?>? json = input.dtos[b.dto];
    if (json == null) {
      if (!peers && b == t.bindings.first) {
        throw ReadModelRowError(t.name, '첫 결속 ${b.dto} 없음');
      }
      continue;
    }
    final Set<String> excluded = <String>{
      for (final ReadModelExclusion e in b.excluded) e.key,
    };
    json.forEach((String k, Object? v) {
      if (excluded.contains(k)) return;
      if (b.prefix.isEmpty && k == ReadModelPushColumns.mode.name) {
        if (v != input.mode.wire) {
          throw ReadModelRowError(t.name, '${b.dto}.mode ≠ 행 mode');
        }
        return;
      }
      if (b.flatten.containsKey(k)) {
        if (v is! Map<String, Object?>) {
          throw ReadModelRowError(t.name, '${b.dto}.$k 펼칠 객체 아님');
        }
        v.forEach((String sk, Object? sv) => row['${b.prefix}$sk'] = sv);
        return;
      }
      row['${b.prefix}$k'] = v;
    });
  }
  final Set<String> wantExtras = <String>{
    for (final ReadModelExtraColumn x in t.extraColumns) x.name,
  };
  final Set<String> stamps = t.name == ReadModelTables.configView.name
      ? kReadModelStampColumns
      : const <String>{};
  final Set<String> needExtras = wantExtras.difference(stamps);
  if (!input.extras.keys.toSet().containsAll(needExtras) ||
      !needExtras.containsAll(input.extras.keys)) {
    throw ReadModelRowError(t.name, 'DTO 밖 열 = ${needExtras.toList()..sort()}');
  }
  row.addAll(input.extras);
  if (stamps.isNotEmpty) {
    row['schema_version'] = schemaVersion;
    row['hash_format_version'] = hashFormatVersion;
    row['contract_version'] = contractVersion;
  }
  for (final ReadModelViewerVariant v in t.viewerVariants) {
    if (v.keyPath.contains('[].')) {
      final List<String> p = v.keyPath.split('[].');
      final Object? list = row[p.first];
      if (list is List<Object?>) {
        row[p.first] = <Object?>[
          for (final Object? e in list)
            if (e is Map<String, Object?>)
              <String, Object?>{...e, p.last: kReadModelViewerMaskText}
            else
              e,
        ];
      }
      continue;
    }
    if (!input.viewer.containsKey(v.keyPath)) {
      throw ReadModelRowError(t.name, '뷰어 판 값 없음 ${v.keyPath}');
    }
    row[v.keyPath] = input.viewer[v.keyPath];
  }
  final Set<String> cols = <String>{
    for (final ReadModelColumn c in ReadModelPushColumns.all) c.name,
    for (final ReadModelColumn c in t.columns) c.name,
  };
  for (final String k in row.keys) {
    if (!cols.contains(k)) throw ReadModelRowError(t.name, '열 밖 칸 $k');
  }
  for (final String k in t.keyColumns) {
    if (row[k] == null) throw ReadModelRowError(t.name, '키 $k 없음');
  }
  return row;
}

/// 목록 봉투 행(`rm_list_envelope` · 01 §45 K310) — [asOf] = `AsOf.toJson()`.
Map<String, Object?> listEnvelopeRow({
  required RunMode mode,
  required int rowVersion,
  required String listCode,
  required Map<String, Object?> asOf,
  required EmptyKind emptyKind,
  String? emptyLabel,
}) {
  if (!ReadModelListCodes.all.contains(listCode)) {
    throw ReadModelRowError(ReadModelTables.listEnvelope.name, '모르는 list_code');
  }
  return readModelRow(
    ReadModelTables.listEnvelope,
    ReadModelRowInput(
      mode: mode,
      rowVersion: rowVersion,
      extras: <String, Object?>{
        'list_code': listCode,
        'as_of': asOf,
        'empty_kind': emptyKind.wire,
        'empty_label': emptyLabel,
      },
    ),
  );
}
