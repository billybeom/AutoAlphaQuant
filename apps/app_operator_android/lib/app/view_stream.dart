// 화면 상태를 따라가는 읽기 흐름 — operator 읽기 원천 공용(E11p3d-3c · 설계 13 §8 R120 · R113 에서 뽑아냄).
//
// 🔴 낸다 = 들을 때 · 원천이 바뀔 때([changes] — 같은 연결 `db.updates`) · [tick] 마다(시간만 흐르는 몫 — 달이 바뀌어
//    예정 값이 지금 값이 되는 일 · 해제 카운트다운 등) · 화면 상태가 바뀔 때(다시 구독 · 마지막 값 비움 — 오류 뒤 같은 값도 다시 낸다).
//    바뀐 값만.
// 🔴 화면 상태가 없으면(온보딩 전) [noView] 오류 — 지어내지 않는다.

import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;

import 'operator_view.dart';

/// 화면 상태를 따라가는 흐름.
Stream<T> followView<T>({
  required ValueListenable<OperatorView?> view,
  required Stream<T> Function(OperatorView v) changes,
  required T Function(OperatorView v) now,
  required Duration tick,
  required Object Function() noView,
}) {
  late final StreamController<T> c;
  StreamSubscription<T>? sub;
  Timer? timer;
  T? last;
  bool has = false;

  void put(T value) {
    if (c.isClosed || (has && value == last)) return;
    has = true;
    last = value;
    c.add(value);
  }

  void fail(Object e, StackTrace st) {
    if (!c.isClosed) c.addError(e, st);
  }

  void follow() {
    unawaited(sub?.cancel());
    sub = null;
    has = false;
    last = null;
    final OperatorView? v = view.value;
    if (v == null) {
      fail(noView(), StackTrace.current);
      return;
    }
    sub = changes(v).listen(put, onError: fail);
  }

  void onTick() {
    final OperatorView? v = view.value;
    if (v == null) return;
    try {
      put(now(v));
    } on Object catch (e, st) {
      fail(e, st);
    }
  }

  c = StreamController<T>(
    onListen: () {
      view.addListener(follow);
      timer = Timer.periodic(tick, (_) => onTick());
      follow();
    },
    onCancel: () async {
      view.removeListener(follow);
      timer?.cancel();
      await sub?.cancel();
      await c.close();
    },
  );
  return c.stream;
}
