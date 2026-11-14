// operator 플랫폼 기동(E11p2 · 설계 e11p-map P9 · P11).
//
// `main()` 이 한 번 부른다 — 화면이 먼저 떴든 알람 · 부팅으로 FGS 가 먼저 엔진을 만들었든 같은 엔진 · 같은 `main()` 이다.
// 🔴 엔진 상태를 아직 모르면 FGS 알림 문구를 띄우지 않는다(«정상»을 지어내지 않는다 — Kotlin 이 앱 이름만 띄운다).
//    상태 문구는 p3b(엔진 상태 함수) 뒤 `fgs.show` 로 넣는다.
// 🆕 E11p3a(설계 e11p-map Q0 · Q1 · Q8) — 깨어남 = 엔진 조립 뿌리(`OperatorEngine.wake`). 엔진은 **처음 깨어날 때**
//    조립한다(폴더 · 원장) — 조립이 실패해도 호스트(알람 · FGS)는 이미 서 있고, 다음 깨어남에 다시 조립한다.
// 🆕 E11p3b-4(설계 13 §8 R95) — 기동 판정 «자격증명 환경» = 모드가 고르는 KIS 키 세트의 환경(`kisKeySetFits`).
// 🆕 E11p3c-1(설계 13 §8 R97) — 실물 잡 부품(`JobParts`): KIS 일봉 원천(금고 키 → 클라이언트 하나) · FRED · OFR · 국면 지문.
// 🆕 E11p3c-4(설계 13 §8 R102) — 깨어남이 끝나면 엔진 상태를 FGS 에 띄운다(호스트 `fgs.show` · 전이 때만 다시 띄움).
// 🆕 E11p3d-1(설계 13 §8 R104) — 화면과 엔진이 원장 하나를 함께 쓴다(`OperatorRuntime`) · 깨어남 보고 → 화면 상태.

import 'dart:io' show Platform;

import 'package:broker_gateway/broker_gateway.dart'
    show KisQuoteFeed, KisQuotes, kisKeySetFits;
import 'package:core_engine/core_engine.dart'
    show Market, frozenExchangeCalendar, p0sRegimeConfigHash;
import 'package:data_sync/data_sync.dart'
    show FredClient, HealthchecksClient, OfrClient;
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:trading_runtime/trading_runtime.dart'
    show FgsStatus, JobCalendars;

import '../app/operator_runtime.dart';
import '../app/secure_screen.dart' show SecureScreen;
import '../engine/data_job_runners.dart' show JobParts;
import '../engine/engine_boot.dart' show BootInputs;
import '../engine/job_runners.dart' show JobContext, composeJobRunners;
import '../engine/kis_sessions.dart';
import '../engine/ledger_files.dart';
import '../engine/operator_engine.dart';
import '../engine/seed_loader.dart';
import '../engine/system_clock.dart';
import 'android_ops.dart';
import 'android_secret_vault.dart';
import 'engine_host.dart';
import 'operator_channels.dart';

/// 플랫폼을 띄운다 — Android 가 아니면 null(시험 · 다른 타깃).
Future<OperatorEngineHost?> startOperatorPlatform({
  WakeHandler? onWake,
  void Function(String link)? onLink,
  OperatorRuntime? runtime,
}) async {
  if (!Platform.isAndroid) return null;
  final AndroidOps ops = AndroidOps();
  final JobCalendars cals = JobCalendars(
    kr: frozenExchangeCalendar(Market.kr),
    us: frozenExchangeCalendar(Market.us),
  );
  late final OperatorEngineHost host;
  host = OperatorEngineHost(
    ops: ops,
    calendars: cals,
    channelNames: kOpsChannelNames,
    onWake:
        onWake ??
        engineWakeHandler(
          ops: ops,
          calendars: cals,
          fgs: (FgsStatus s) => host.fgs.show(s),
          runtime: runtime,
        ),
    onLink: onLink,
  );
  await host.start();
  return host;
}

/// 깨어남 → 엔진(처음 깨어날 때 조립 · 실패하면 다음 깨어남에 다시).
WakeHandler engineWakeHandler({
  required AndroidOps ops,
  required JobCalendars calendars,
  FgsSink? fgs,
  OperatorRuntime? runtime,
}) {
  OperatorEngine? engine;
  return (WakeEvent _) async {
    final OperatorEngine e = engine ??= await _assemble(
      ops,
      calendars,
      fgs,
      runtime,
    );
    final EngineWakeReport r = await e.wake();
    runtime?.onWake(r);
  };
}

Future<OperatorEngine> _assemble(
  AndroidOps ops,
  JobCalendars cals,
  FgsSink? fgs,
  OperatorRuntime? runtime,
) async {
  // 🔴 화면과 같은 원장(실행 묶음이 있으면 그 연결) — 없으면 엔진이 연다(시험 · 화면 없는 조립).
  final String? dir = runtime == null ? (await ops.paths()).engineDir : null;
  const SystemClock clock = SystemClock();
  final http.Client net = http.Client();
  final AndroidSecretVault vault = AndroidSecretVault();
  final JobParts parts = operatorJobParts(
    KisSessions(vault: vault, http: net),
    net,
  );
  return OperatorEngine(
    openFiles: () => runtime?.files ?? LedgerFiles.open(dir!, clock: clock),
    calendars: cals,
    heartbeat: HealthchecksClient(net, vault),
    bootInputs: kOperatorBootInputs,
    runners: (JobContext c) => composeJobRunners(c, parts: parts),
    seed: () => loadSeedAssets(rootBundle),
    fgs: fgs,
  );
}

/// 조립 앱의 기동 판정 입력 — 🔴 자격증명 환경 = 모드가 고르는 키 세트의 환경(R95 · SIM = 모의 세트만).
/// 승인(SAF-405) · 실키 검증은 아직 빈 입력(live = 거부 · `LIVE_AWAITING_KEYS` · p3c · 계약 창 뒤).
const BootInputs kOperatorBootInputs = BootInputs(
  credentialEnvironmentOk: kisKeySetFits,
);

/// 조립 앱의 실물 잡 부품(R97) — 일봉 원천 = 모드 세트의 KIS 클라이언트(하나) · FRED 는 키 없이 CSV.
JobParts operatorJobParts(KisSessions kis, http.Client net) => JobParts(
  quoteFeed: (RunMode mode) async => KisQuoteFeed(await kis.clientFor(mode)),
  priceFetch: (RunMode mode) async =>
      KisQuotes(await kis.clientFor(mode)).domesticPrice,
  fred: FredClient(net),
  ofr: OfrClient(net),
  regimeConfigHash: p0sRegimeConfigHash(),
);

/// 🔴 화면 · 엔진 공용 실행 묶음을 연다 — Android 가 아니거나 폴더를 못 얻으면 null(엔진은 깨어날 때 다시 시도한다).
Future<OperatorRuntime?> openOperatorRuntime() async {
  if (!Platform.isAndroid) return null;
  try {
    const SystemClock clock = SystemClock();
    final AndroidOps ops = AndroidOps();
    final String dir = (await ops.paths()).engineDir;
    return OperatorRuntime(
      files: LedgerFiles.open(dir, clock: clock),
      clock: clock,
      secure: SecureScreen(ops.setSecure),
      openExternal: ops.openExternalUrl,
    );
  } on Object {
    return null;
  }
}
