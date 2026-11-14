// operator 플랫폼 기동(E11p2 · 설계 e11p-map P9 · P11).
//
// `main()` 이 한 번 부른다 — 화면이 먼저 떴든 알람 · 부팅으로 FGS 가 먼저 엔진을 만들었든 같은 엔진 · 같은 `main()` 이다.
// 🔴 엔진 상태를 아직 모르면 FGS 알림 문구를 띄우지 않는다(«정상»을 지어내지 않는다 — Kotlin 이 앱 이름만 띄운다).
//    상태 문구는 p3b(엔진 상태 함수) 뒤 `fgs.show` 로 넣는다.
// 🆕 E11p3a(설계 e11p-map Q0 · Q1 · Q8) — 깨어남 = 엔진 조립 뿌리(`OperatorEngine.wake`). 엔진은 **처음 깨어날 때**
//    조립한다(폴더 · 원장) — 조립이 실패해도 호스트(알람 · FGS)는 이미 서 있고, 다음 깨어남에 다시 조립한다.

import 'dart:io' show Platform;

import 'package:core_engine/core_engine.dart'
    show Market, frozenExchangeCalendar;
import 'package:data_sync/data_sync.dart' show HealthchecksClient;
import 'package:http/http.dart' as http;
import 'package:trading_runtime/trading_runtime.dart' show JobCalendars;

import '../engine/ledger_files.dart';
import '../engine/operator_engine.dart';
import '../engine/system_clock.dart';
import 'android_ops.dart';
import 'android_secret_vault.dart';
import 'engine_host.dart';
import 'operator_channels.dart';

/// 플랫폼을 띄운다 — Android 가 아니면 null(시험 · 다른 타깃).
Future<OperatorEngineHost?> startOperatorPlatform({
  WakeHandler? onWake,
  void Function(String link)? onLink,
}) async {
  if (!Platform.isAndroid) return null;
  final AndroidOps ops = AndroidOps();
  final JobCalendars cals = JobCalendars(
    kr: frozenExchangeCalendar(Market.kr),
    us: frozenExchangeCalendar(Market.us),
  );
  final OperatorEngineHost host = OperatorEngineHost(
    ops: ops,
    calendars: cals,
    channelNames: kOpsChannelNames,
    onWake: onWake ?? engineWakeHandler(ops: ops, calendars: cals),
    onLink: onLink,
  );
  await host.start();
  return host;
}

/// 깨어남 → 엔진(처음 깨어날 때 조립 · 실패하면 다음 깨어남에 다시).
WakeHandler engineWakeHandler({
  required AndroidOps ops,
  required JobCalendars calendars,
}) {
  OperatorEngine? engine;
  return (WakeEvent _) async {
    final OperatorEngine e = engine ??= await _assemble(ops, calendars);
    await e.wake();
  };
}

Future<OperatorEngine> _assemble(AndroidOps ops, JobCalendars cals) async {
  final String dir = (await ops.paths()).engineDir;
  const SystemClock clock = SystemClock();
  return OperatorEngine(
    openFiles: () => LedgerFiles.open(dir, clock: clock),
    calendars: cals,
    heartbeat: HealthchecksClient(http.Client(), AndroidSecretVault()),
  );
}
