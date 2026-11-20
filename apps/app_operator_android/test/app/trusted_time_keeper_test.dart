// E11k-a — 앞 화면 신뢰 시각 갱신기(설계 13 §8 R197 T7).
//
// 🔵 잡는 것: ① 앞으로 옴 = 바로 한 번 재고 주기 하나(겹쳐 켜지 않는다) ② 주기마다 잰다 ③ 뒤로 감(hidden · paused · detached)
//    = 주기를 끈다 ④ inactive(생체 확인 창) = 그대로 ⑤ 기본 주기 2분(기준점 기한 10분 안).

import 'dart:async';

import 'package:app_operator_android/app/trusted_time_keeper.dart';
import 'package:core_engine/core_engine.dart' show kTrustedTimeMaxAge;
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart';

class _FakeTimer implements Timer {
  _FakeTimer(this.every, this.onTick);
  final Duration every;
  final void Function(Timer) onTick;
  bool cancelled = false;

  void fire() => onTick(this);

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;
}

class _Rig {
  int refreshed = 0;
  final List<_FakeTimer> timers = <_FakeTimer>[];

  late final TrustedTimeKeeper keeper = TrustedTimeKeeper(
    () async {
      refreshed++;
      return true;
    },
    periodic: (Duration every, void Function(Timer) tick) {
      final _FakeTimer t = _FakeTimer(every, tick);
      timers.add(t);
      return t;
    },
  );
}

void main() {
  test('기본 주기 = 2분 · 기준점 기한(10분)보다 짧다', () {
    final TrustedTimeKeeper k = TrustedTimeKeeper(() async => true);
    expect(k.every, const Duration(minutes: 2));
    expect(k.every < kTrustedTimeMaxAge, isTrue);
    expect(k.running, isFalse);
  });

  test('앞으로 옴 = 바로 한 번 · 주기 하나 · 주기마다 잰다', () {
    final _Rig r = _Rig();
    r.keeper.start();
    expect(r.refreshed, 1);
    expect(r.timers, hasLength(1));
    expect(r.timers.single.every, const Duration(minutes: 2));
    expect(r.keeper.running, isTrue);
    r.timers.single.fire();
    r.timers.single.fire();
    expect(r.refreshed, 3);
  });

  test('🔴 다시 앞으로 와도 주기를 겹쳐 켜지 않는다(재기는 한다)', () {
    final _Rig r = _Rig();
    r.keeper.onLifecycle(AppLifecycleState.resumed);
    r.keeper.onLifecycle(AppLifecycleState.resumed);
    expect(r.refreshed, 2);
    expect(r.timers, hasLength(1));
  });

  for (final AppLifecycleState s in <AppLifecycleState>[
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.detached,
  ]) {
    test('🔴 ${s.name} = 주기를 끈다 · 앞으로 오면 새로 켠다', () {
      final _Rig r = _Rig();
      r.keeper.start();
      r.keeper.onLifecycle(s);
      expect(r.timers.single.cancelled, isTrue);
      expect(r.keeper.running, isFalse);
      expect(r.refreshed, 1);
      r.keeper.onLifecycle(AppLifecycleState.resumed);
      expect(r.timers, hasLength(2));
      expect(r.timers.last.cancelled, isFalse);
      expect(r.refreshed, 2);
    });
  }

  test('inactive(생체 확인 창) = 그대로 — 재지도 끄지도 않는다', () {
    final _Rig r = _Rig();
    r.keeper.start();
    r.keeper.onLifecycle(AppLifecycleState.inactive);
    expect(r.refreshed, 1);
    expect(r.timers.single.cancelled, isFalse);
    expect(r.keeper.running, isTrue);
  });

  test('꺼진 채 끄기 = 아무 일 없음', () {
    final _Rig r = _Rig();
    r.keeper.stop();
    expect(r.timers, isEmpty);
    expect(r.refreshed, 0);
  });
}
