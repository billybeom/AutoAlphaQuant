// 시험 도우미 — 메모리 읽기 모델 원천(같음 조건 · 차례 · 개수 · 바뀌면 다시 냄).

import 'dart:async';

import 'package:read_model_client/read_model_client.dart';

/// 메모리 원천.
final class MemorySource implements ReadModelSource {
  final Map<String, List<ReadModelRow>> _tables =
      <String, List<ReadModelRow>>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// 받은 조회(차례대로).
  final List<ReadModelQuery> queries = <ReadModelQuery>[];

  /// 원천 오류(설정 시 모든 읽기가 이 오류 — RLS 거부 · 표 부재 흉내).
  Exception? failure;

  /// 표 행을 통째로 바꾼다.
  void put(String table, List<ReadModelRow> rows) {
    _tables[table] = rows;
    _changes.add(null);
  }

  /// 닫는다.
  Future<void> close() => _changes.close();

  List<ReadModelRow> _run(ReadModelQuery q) {
    queries.add(q);
    final Exception? f = failure;
    if (f != null) throw f;
    final List<ReadModelRow> rows = <ReadModelRow>[
      for (final ReadModelRow r in _tables[q.table.name] ?? <ReadModelRow>[])
        if (q.equals.entries.every(
          (MapEntry<String, Object?> e) => r[e.key] == e.value,
        ))
          r,
    ];
    for (final ReadModelOrder o in q.orderBy.reversed) {
      rows.sort((ReadModelRow a, ReadModelRow b) {
        final int c = (a[o.column]! as Comparable<Object>).compareTo(
          b[o.column]!,
        );
        return o.descending ? -c : c;
      });
    }
    final int? n = q.limit;
    return n == null ? rows : rows.take(n).toList();
  }

  @override
  Future<List<ReadModelRow>> select(ReadModelQuery query) async => _run(query);

  @override
  Stream<List<ReadModelRow>> watch(ReadModelQuery query) {
    late final StreamController<List<ReadModelRow>> out;
    StreamSubscription<void>? changes;
    void push() {
      try {
        out.add(_run(query));
      } on Exception catch (e, st) {
        out.addError(e, st);
      }
    }

    out = StreamController<List<ReadModelRow>>(
      onListen: () {
        push();
        changes = _changes.stream.listen((void _) => push());
      },
      onCancel: () async {
        await changes?.cancel();
        await out.close();
      },
    );
    return out.stream;
  }
}
