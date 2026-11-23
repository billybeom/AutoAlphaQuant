// 🆕 E11-viewer-223(01 §8 미결 223 ⓑ · 계약 v1.36 §45 K310) — 목록 창구 = 행 표 + `rm_list_envelope` 그 `list_code` 행.
//
// 🔴 빈 목록에도 봉투가 와야 한다(01 §2-1 · 계약 3조 ③) — 봉투 행이 없으면 던진다(빈 상태를 지어내지 않는다).
// 🔴 `hasMore` = 뷰어 조회(limit+1 · 01 §4-1 · 열 0) — 행은 «받은 차례 그대로»(차례는 조회가 정한다 · 이 파일은
//    다시 정렬 · 거르기 · 세기를 하지 않는다).
// 🔴 필터 빈 문장 갈래 — 봉투 = 그 창구의 «무필터» 값(push 빌더 E11l2 가 같은 규칙으로 싣는다 · 미결 222 ⓒ 넘김).
//    필터가 걸린 조회가 비었을 때: 봉투 `empty_label` 이 있으면(= 목록 전체가 빔) 그 글자 · 없으면 null —
//    «조건에 맞는 기록이 없습니다» 같은 필터 빈 문장은 엔진 글자라 뷰어가 짓지 않는다(열 = 계약 창 대기 · 미결 223 꼬리).

import 'package:domain_contracts/domain_contracts.dart'
    show AsOf, EmptyKind, ListResult, ReadModelListCodes, ReadModelTables;

import 'read_model_rows.dart' show ReadModelRow, decodeReadModelJson;

/// `rm_list_envelope` 한 행(K310).
final class ReadModelListEnvelope {
  /// 봉투를 만든다.
  const ReadModelListEnvelope({
    required this.listCode,
    required this.asOf,
    required this.emptyKind,
    required this.emptyLabel,
  });

  /// 목록 창구 이름(`ReadModelListCodes`).
  final String listCode;

  /// `ListResult.asOf`.
  final AsOf asOf;

  /// `ListResult.emptyKind`.
  final EmptyKind emptyKind;

  /// `ListResult.emptyLabel`(엔진 · 없으면 null).
  final String? emptyLabel;
}

/// `rm_list_envelope` 행 → 봉투. 🔴 [listCode] 와 행의 `list_code` 가 다르거나 꼴이 틀리면 [FormatException].
ReadModelListEnvelope listEnvelopeOfRow(
  ReadModelRow row, {
  required String listCode,
}) {
  final String t = ReadModelTables.listEnvelope.name;
  if (!ReadModelListCodes.all.contains(listCode)) {
    throw ArgumentError.value(listCode, 'listCode', '계약 목록 창구 아님');
  }
  for (final String col in <String>[
    'list_code',
    'as_of',
    'empty_kind',
    'empty_label',
  ]) {
    if (!row.containsKey(col)) {
      throw FormatException('$t: 열 $col 없음');
    }
  }
  if (row['list_code'] != listCode) {
    throw FormatException('$t: list_code ${row['list_code']} ≠ $listCode');
  }
  final Object? asOf = row['as_of'];
  if (asOf is! Map<String, Object?>) {
    throw FormatException('$t: as_of 객체 아님');
  }
  final Object? kind = row['empty_kind'];
  EmptyKind? emptyKind;
  for (final EmptyKind k in EmptyKind.values) {
    if (k.wire == kind) emptyKind = k;
  }
  if (emptyKind == null) {
    throw FormatException('$t: empty_kind $kind 모름');
  }
  final Object? label = row['empty_label'];
  if (label != null && label is! String) {
    throw FormatException('$t: empty_label 글자 아님');
  }
  return ReadModelListEnvelope(
    listCode: listCode,
    asOf: decodeReadModelJson('$t.as_of', asOf, AsOf.fromJson),
    emptyKind: emptyKind,
    emptyLabel: label as String?,
  );
}

/// 행(받은 차례 · limit+1 까지 조회한 것) + 봉투 → `ListResult`(K310 · 01 §4-1).
///
/// - [limit] = 창구 인자(null = 목록 전부를 받았다 — jsonb 목록 열 · `hasMore` false).
/// - [filtered] = 봉투의 무필터 기준 밖 조건(기간 · 슬리브 · 종목 · 상태 · 출처 · 회차)이 걸린 조회.
/// 🔴 [envelope] 가 없으면 [FormatException](빈 목록에도 봉투가 와야 한다).
ListResult<T> listResultOf<T>({
  required List<T> fetched,
  required ReadModelListEnvelope? envelope,
  required String listCode,
  int? limit,
  bool filtered = false,
}) {
  if (envelope == null) {
    throw FormatException(
      '${ReadModelTables.listEnvelope.name}: $listCode 봉투 행 없음',
    );
  }
  if (envelope.listCode != listCode) {
    throw FormatException(
      '${ReadModelTables.listEnvelope.name}: 봉투 ${envelope.listCode} ≠ $listCode',
    );
  }
  if (limit != null && limit < 0) {
    throw ArgumentError.value(limit, 'limit', '0 이상이어야 한다');
  }
  final bool hasMore = limit != null && fetched.length > limit;
  final List<T> rows = hasMore
      ? fetched.take(limit).toList(growable: false)
      : List<T>.unmodifiable(fetched);
  return ListResult<T>(
    rows: rows,
    asOf: envelope.asOf,
    emptyKind: envelope.emptyKind,
    emptyLabel: filtered && rows.isNotEmpty ? null : envelope.emptyLabel,
    hasMore: hasMore,
  );
}
