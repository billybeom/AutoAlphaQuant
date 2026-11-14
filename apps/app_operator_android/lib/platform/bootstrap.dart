// operator 플랫폼 기동(E11p2 · 설계 e11p-map P9 · P11).
//
// `main()` 이 한 번 부른다 — 화면이 먼저 떴든 알람 · 부팅으로 FGS 가 먼저 엔진을 만들었든 같은 엔진 · 같은 `main()` 이다.
// 🔴 엔진 상태를 아직 모르면 FGS 알림 문구를 띄우지 않는다(«정상»을 지어내지 않는다 — Kotlin 이 앱 이름만 띄운다).
//    상태 문구 · 실제 잡 실행은 E11p3 조립이 [WakeHandler] · `fgs.show` 로 넣는다.

import 'dart:io' show Platform;

import 'package:core_engine/core_engine.dart'
    show Market, frozenExchangeCalendar;
import 'package:trading_runtime/trading_runtime.dart' show JobCalendars;

import 'android_ops.dart';
import 'engine_host.dart';
import 'operator_channels.dart';

/// 플랫폼을 띄운다 — Android 가 아니면 null(시험 · 다른 타깃).
Future<OperatorEngineHost?> startOperatorPlatform({
  WakeHandler? onWake,
  void Function(String link)? onLink,
}) async {
  if (!Platform.isAndroid) return null;
  final OperatorEngineHost host = OperatorEngineHost(
    ops: AndroidOps(),
    calendars: JobCalendars(
      kr: frozenExchangeCalendar(Market.kr),
      us: frozenExchangeCalendar(Market.us),
    ),
    channelNames: kOpsChannelNames,
    onWake: onWake,
    onLink: onLink,
  );
  await host.start();
  return host;
}
