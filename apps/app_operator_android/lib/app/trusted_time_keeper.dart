// 앞 화면 신뢰 시각 갱신(E11k-a · 설계 13 §8 R197 T7).
//
// 🔴 기준점은 10분(`kTrustedTimeMaxAge`)만 믿고, 기기가 잠들면 그 자리에서 낡는다(두 시계 대조) — 그래서 화면이 앞에 있는
//    동안 [every] 마다 다시 잰다. 앞으로 오면(resumed) 바로 한 번 재고 주기를 켠다 · 뒤로 가면(hidden · paused · detached)
//    주기를 끈다(FGS 프로세스가 하루 종일 살아 있어도 뒤에서는 재지 않는다 — 엔진은 깨어날 때 따로 잰다).
// 🔵 inactive(생체 확인 창 · 알림 창이 덮음)는 앞으로 친다 — 서약 서명 도중에 기준점이 끊기지 않게.
// 🔴 갱신 실패 = 아무것도 하지 않는다(옛 기준점이 알아서 낡는다 · 쓰기는 엔진이 `TRUSTED_TIME_UNKNOWN` 으로 거부).

import 'dart:async';

import 'package:flutter/widgets.dart' show AppLifecycleState;

/// 주기 타이머 만들기(시험 = 가짜).
typedef PeriodicTimerFactory = Timer Function(
  Duration every,
  void Function(Timer) tick,
);

Timer _realPeriodic(Duration every, void Function(Timer) tick) =>
    Timer.periodic(every, tick);

/// 앞 화면일 때 신뢰 시각을 주기적으로 다시 잰다.
class TrustedTimeKeeper {
  /// 만든다 — [refresh] = 실행 묶음의 `refreshTrusted` · [every] = 앞 화면 주기.
  TrustedTimeKeeper(
    this._refresh, {
    this.every = const Duration(minutes: 2),
    PeriodicTimerFactory? periodic,
  }) : _periodic = periodic ?? _realPeriodic;

  final Future<bool> Function() _refresh;
  final PeriodicTimerFactory _periodic;
  Timer? _timer;

  /// 앞 화면 주기(기준점 기한 10분보다 넉넉히 짧게).
  final Duration every;

  /// 주기가 켜져 있나.
  bool get running => _timer != null;

  /// 앞으로 왔다 — 바로 한 번 재고 주기를 켠다(이미 켜져 있으면 재기만).
  void start() {
    unawaited(_refresh());
    _timer ??= _periodic(every, (_) => unawaited(_refresh()));
  }

  /// 뒤로 갔다 — 주기를 끈다.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 앱 생명주기 → 켜기 · 끄기.
  void onLifecycle(AppLifecycleState s) {
    switch (s) {
      case AppLifecycleState.resumed:
        start();
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        stop();
    }
  }
}
