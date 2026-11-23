// 🆕 E11-viewer-223(01 §8 미결 223 · 지도 D2) — 뷰어가 읽기 모델 표에 닿는 창구 뼈대(네트워크 0).
//
// 🔴 실제 읽기(Supabase 순수 Dart 클라이언트 · RLS select · Realtime)는 이 카드 밖이다 — E11l2(push RPC) 뒤
//    뷰어 앱 착수 카드가 [ReadModelSource] 를 구현한다(설계 13 §8 R250 · 미결 223 꼬리).
// 🔴 조회 = 표 하나 · 같음 조건 · 차례 · 개수뿐 — 표 이름 · 열 이름은 계약 상수 안에서만(모르는 표 · 열 = ArgumentError).
//    조인 · 집계 · 세기는 없다(경계 규칙 ① — 뷰어가 행을 세어 글자를 만들지 않는다).

import 'package:domain_contracts/domain_contracts.dart'
    show ReadModelColumn, ReadModelPushColumns, ReadModelTable;

import 'read_model_rows.dart' show ReadModelRow;

/// 차례 한 칸.
final class ReadModelOrder {
  /// 차례를 만든다.
  const ReadModelOrder(this.column, {this.descending = false});

  /// 열 이름.
  final String column;

  /// 내림차순.
  final bool descending;
}

/// 조회 한 건 — 표 하나.
final class ReadModelQuery {
  /// 조회를 만든다. 🔴 [table] 밖의 열 이름 = [ArgumentError].
  ReadModelQuery(
    this.table, {
    this.equals = const <String, Object?>{},
    this.orderBy = const <ReadModelOrder>[],
    this.limit,
  }) {
    final Set<String> cols = <String>{
      for (final ReadModelColumn c in ReadModelPushColumns.all) c.name,
      for (final ReadModelColumn c in table.columns) c.name,
    };
    for (final String c in <String>[
      ...equals.keys,
      for (final ReadModelOrder o in orderBy) o.column,
    ]) {
      if (!cols.contains(c)) {
        throw ArgumentError.value(c, 'column', '${table.name} 의 열 아님');
      }
    }
    final int? n = limit;
    if (n != null && n < 0) {
      throw ArgumentError.value(n, 'limit', '0 이상이어야 한다');
    }
  }

  /// 표(계약 상수).
  final ReadModelTable table;

  /// 열 = 값(와이어 · null = `is null`).
  final Map<String, Object?> equals;

  /// 차례(빈 = 원천 차례 — 차례가 뜻을 갖는 조회는 반드시 적는다).
  final List<ReadModelOrder> orderBy;

  /// 개수(null = 전부 · 목록 창구 = limit+1).
  final int? limit;
}

/// 그 키의 행이 없다 — push 전이거나 그 키가 아직 없다.
///
/// 🔵 «못 읽음»([FormatException] · 버전 게이트 incompatible)과 다르다: 꼴 판정이 아니라 부재다(화면 = 공용 오류).
final class ReadModelRowMissing implements Exception {
  /// 부재를 만든다.
  const ReadModelRowMissing(this.table, this.key);

  /// 표 이름.
  final String table;

  /// 찾은 키(열 = 값).
  final Map<String, Object?> key;

  @override
  String toString() => 'ReadModelRowMissing: $table $key 행 없음';
}

/// 읽기 모델 원천 — 🔴 구현 = 뷰어 앱 착수 카드(Supabase · E11l2 뒤) · 시험 = 메모리 가짜.
///
/// 🔵 구현 주의(시험 실측) — [watch] 를 `async*` + 변경 스트림 `await for` 로 짜면 구독 취소가 «다음 변경»까지
///    끝나지 않는다(목록 봉투 창구가 두 구독을 함께 끊을 때 멈춤) → `StreamController`(onListen · onCancel)로 짓는다.
abstract interface class ReadModelSource {
  /// 한 번 읽는다(`Future` 창구).
  Future<List<ReadModelRow>> select(ReadModelQuery query);

  /// 구독한다(`Stream` 창구 — 행이 바뀌면 다시 낸다).
  Stream<List<ReadModelRow>> watch(ReadModelQuery query);
}
