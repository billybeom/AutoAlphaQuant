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
// 🆕 E11k-a(설계 13 §8 R197 T6) — 신뢰 시각 = Supabase 서버 시각 기준점 하나(`operatorTrustedClock`) — 화면 · 엔진이 같이 쓰고,
//    깨어날 때마다 한 번 잰다. 금고에 연결 칸(o_07 ②)이 없으면 망에 가지 않고 늘 «모름»(지금과 같다).
// 🆕 E11k-e3(설계 13 §8 R229) — 리스 RPC 클라이언트 · O-04 ⑤ 첫 클레임 흐름 · 원격 리스 원천을 실행 묶음에 하나씩 — 엔진은 실행 묶음의
//    원천을 그대로 쓴다(같은 로그인 세션 · 같은 첫 클레임 기록) · 기기 id 가 없으면 셋 다 없음(⑤ 원천 없음 · 원격 0 = 지금과 같다).
// 🆕 리뷰 3차 H1(설계 13 §8 R261) — 호스트가 서면 실행 묶음에 깨어남 창구(`host.wakeNow`)를 단다 · FGS 상태 = 이 기기 id 의 표시 hold 포함.

import 'dart:io' show Platform;

import 'package:broker_gateway/broker_gateway.dart'
    show KisOrderBroker, KisQuoteFeed, KisQuotes, kisKeySetFits;
import 'package:core_engine/core_engine.dart'
    show
        AnchoredTrustedClock,
        LiveObservationConfig,
        Market,
        OperationsConfig,
        SecretVault,
        TrustedClock,
        frozenExchangeCalendar,
        p0sRegimeConfigHash;
import 'package:data_sync/data_sync.dart'
    show
        FredClient,
        HealthchecksClient,
        OfrClient,
        P0sHumanDecision,
        SupabaseAuth,
        SupabaseDeviceLedger,
        SupabaseFirstClaim,
        SupabaseLeaseGate,
        SupabaseLeaseRpc,
        SupabaseServerTime,
        SupabaseX1Emergency;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, RunMode, TradeDate;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart'
    show FgsStatus, JobCalendars;

import '../app/operator_golden.dart' show OperatorGolden;
import '../app/operator_onboarding.dart' show OnboardingProbe;
import '../app/operator_runtime.dart';
import '../app/operator_view.dart' show OperatorView;
import '../app/secure_screen.dart' show SecureScreen;
import '../engine/data_job_runners.dart' show JobParts;
import '../engine/engine_boot.dart' show BootInputs, registryLiveKeysVerified;
import '../engine/fgs_status_source.dart' show UnknownTrustedClock;
import '../engine/job_runners.dart' show JobContext, composeJobRunners;
import '../engine/kis_sessions.dart';
import '../engine/lease_wiring.dart' show LeaseRemoteOf;
import '../engine/ledger_files.dart';
import '../engine/operations_loader.dart' show loadOperationsConfig;
import '../engine/operator_engine.dart';
import '../engine/repair_recon.dart' show operatorFreshReconIds;
import '../engine/seed_loader.dart';
import '../engine/system_clock.dart';
import 'android_ops.dart';
import 'android_secret_vault.dart';
import 'engine_host.dart';
import 'human_inputs_loader.dart' show loadP0sHumanDecision;
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
  // 🆕 리뷰 3차 H1(R261) — 화면 동작 뒤 깨어남 창구 = 이 호스트의 줄(알람 깨어남과 한 줄).
  runtime?.attachWake(host.wakeNow);
  return host;
}

/// 깨어남 → 엔진(처음 깨어날 때 조립 · 실패하면 다음 깨어남에 다시).
///
/// 🆕 E11k-a(R197 T6) — 신뢰 시각 = 실행 묶음의 것(화면과 하나) · 묶음이 없으면(엔진만 뜬 프로세스) [trusted] · 그것도
/// 없으면 여기서 하나 만든다. 깨어날 때마다 조립 · 잡 앞에서 한 번 잰다(잠든 사이 기준점이 낡았다 · 실패 = 모름 그대로).
WakeHandler engineWakeHandler({
  required AndroidOps ops,
  required JobCalendars calendars,
  FgsSink? fgs,
  OperatorRuntime? runtime,
  AnchoredTrustedClock? trusted,
}) {
  OperatorEngine? engine;
  final TrustedClock clock;
  final Future<bool> Function()? refresh;
  if (runtime != null) {
    clock = runtime.trusted;
    refresh = runtime.refreshTrusted;
  } else {
    final AnchoredTrustedClock own =
        trusted ??
        operatorTrustedClock(http: http.Client(), vault: AndroidSecretVault());
    clock = own;
    refresh = own.refresh;
  }
  return (WakeEvent event) async {
    if (refresh != null) await refresh();
    final OperatorEngine e = engine ??= await _assemble(
      ops,
      calendars,
      fgs,
      runtime,
      clock,
    );
    final ({bool booting, String? bootId}) b = wakeBootOf(event);
    final EngineWakeReport r = await e.wake(
      booting: b.booting,
      bootId: b.bootId,
    );
    runtime?.onWake(r);
  };
}

Future<OperatorEngine> _assemble(
  AndroidOps ops,
  JobCalendars cals,
  FgsSink? fgs,
  OperatorRuntime? runtime,
  TrustedClock trusted,
) async {
  // 🔴 화면과 같은 원장(실행 묶음이 있으면 그 연결) — 없으면 엔진이 연다(시험 · 화면 없는 조립).
  final String? dir = runtime == null ? (await ops.paths()).engineDir : null;
  const SystemClock clock = SystemClock();
  final http.Client net = http.Client();
  final AndroidSecretVault vault = AndroidSecretVault();
  // 🆕 E16t2b(R144 X1) — 이 기기 id = 실행 묶음의 값(화면과 같은 값) · 없으면 플랫폼에서(못 얻으면 null = X1 끼울 자리 꺼짐).
  final String? deviceId = runtime != null
      ? runtime.deviceId
      : await deviceIdOrNull(ops);
  final HealthchecksClient watch = HealthchecksClient(net, vault);
  final JobParts parts = operatorJobParts(
    KisSessions(vault: vault, http: net),
    net,
  );
  return OperatorEngine(
    openFiles: () => runtime?.files ?? LedgerFiles.open(dir!, clock: clock),
    calendars: cals,
    heartbeat: watch,
    // 🆕 E16t3b(R149 AA5) — 같은 감시 클라이언트 = 창 재개 · 운영 설정 = data_sync 자산(SPEC 02 §4).
    watchdog: watch,
    operations: await loadOperationsConfig(rootBundle),
    // 🆕 R229 — 원격 리스 원천 = 실행 묶음의 것(화면과 같은 세션 · 첫 클레임 기록).
    bootInputs: operatorBootInputs(
      deviceId: deviceId,
      trusted: trusted,
      leaseRemote: runtime?.leaseRemote,
    ),
    runners: (JobContext c) => composeJobRunners(c, parts: parts),
    seed: () => loadSeedAssets(rootBundle),
    fgs: fgs,
  );
}

/// 조립 앱의 기동 판정 입력 — 🔴 자격증명 환경 = 모드가 고르는 키 세트의 환경(R95 · SIM = 모의 세트만).
/// 승인(SAF-405) = 🆕 R192 기본 실물(`startupConfigApprovalOf` — 원장 개시 판의 `approved`) · 🆕 R196 실키 검증 = 그 원장의
/// 키 검증 기록(`registryLiveKeysVerified` — 없음 · 거절 = `LIVE_AWAITING_KEYS` hold).
const BootInputs kOperatorBootInputs = BootInputs(
  credentialEnvironmentOk: kisKeySetFits,
  // 🆕 R196(207 ⓑ) — 실키 검증 = 그 원장의 키 검증 기록(P0S 실전 세트 둘 다 통과).
  liveKeysVerified: registryLiveKeysVerified,
);

/// 🆕 E16t2b(R144 X2) — 조립 앱의 기동 입력 + 이 기기 id(null = X1 끼울 자리 꺼짐 · 그 밖 = [kOperatorBootInputs] 와 같다) ·
/// 🆕 E11k-a(R197) [trusted] = 신뢰 시각(기본 = 모름) · 🆕 E11k-e3(R229) [leaseRemote] = 원격 리스 원천(없음 = 실물 전).
BootInputs operatorBootInputs({
  String? deviceId,
  TrustedClock trusted = const UnknownTrustedClock(),
  LeaseRemoteOf? leaseRemote,
}) => BootInputs(
  credentialEnvironmentOk: kisKeySetFits,
  liveKeysVerified: registryLiveKeysVerified,
  deviceId: deviceId,
  trusted: trusted,
  leaseRemote: leaseRemote,
);

/// 🆕 E11k-e3(R229) — 첫 클레임 흐름 · 원격 리스 원천(기기 id 없음 = 둘 다 null) — [sim] = 온보딩 원장(첫 클레임 기록) ·
/// 🔴 원격 판정의 «쥔 epoch» = 그 원장 행 · 없으면 첫 클레임 기록(같은 흐름 객체).
({SupabaseFirstClaim? firstClaim, LeaseRemoteOf? leaseRemote})
operatorLeaseParts({
  required SupabaseLeaseRpc rpc,
  required Database sim,
  required String? deviceId,
  required Clock clock,
}) {
  if (deviceId == null) return (firstClaim: null, leaseRemote: null);
  final SupabaseFirstClaim flow = SupabaseFirstClaim(
    rpc,
    sim,
    deviceId: deviceId,
    clock: clock,
  );
  return (
    firstClaim: flow,
    leaseRemote: (Database db) => SupabaseLeaseGate(
      rpc,
      db,
      deviceId: deviceId,
      clock: clock,
      claimedEpoch: flow.claimedEpoch,
    ),
  );
}

/// 🆕 E16t3c(R244) — X1-3 비상 시작 흐름(기기 id 없음 = null) — [sim] = 늘 열린 원장(회수 · 재발급 기록) · [rpc] = 첫 클레임과 같은 것.
SupabaseX1Emergency? operatorX1Emergency({
  required SupabaseLeaseRpc rpc,
  required Database sim,
  required String? deviceId,
  required Clock clock,
}) => deviceId == null
    ? null
    : SupabaseX1Emergency(rpc, sim, deviceId: deviceId, clock: clock);

/// 🆕 E11k-a(R197 T6) — 조립 앱의 신뢰 시각(Supabase 서버 시각 기준점 · 연결 칸 = [vault] · 없으면 망에 가지 않고 모름).
AnchoredTrustedClock operatorTrustedClock({
  required http.Client http,
  required SecretVault vault,
  Clock wall = const SystemClock(),
}) => AnchoredTrustedClock(source: SupabaseServerTime(http, vault), wall: wall);

/// 🆕 E16t3b(R149 AA6) — 깨어남 → (부팅인가 · 부팅 id) — 부팅(`WakeReason.boot`)만 · id = `boot-{울린 ms}`.
({bool booting, String? bootId}) wakeBootOf(WakeEvent e) =>
    e.reason == WakeReason.boot
    ? (booting: true, bootId: 'boot-${e.firedAtUtc.millisecondsSinceEpoch}')
    : (booting: false, bootId: null);

/// 🆕 E16t2b(R144 X3) — 이 기기 id(못 얻으면 null — 화면 · 엔진은 그대로 서고 기기 id 를 쓰는 칸만 꺼진다).
Future<String?> deviceIdOrNull(AndroidOps ops) async {
  try {
    return await ops.deviceId();
  } on Object {
    return null;
  }
}

/// 조립 앱의 실물 잡 부품(R97) — 일봉 원천 = 모드 세트의 KIS 클라이언트(하나) · FRED 는 키 없이 CSV ·
/// 🆕 E11q-c1d(R207 · 실전 개시) 실전 계좌 브로커 = 별칭 → 세트의 KIS 계좌 클라이언트(같은 앱키 = 유량 문 · 토큰 하나).
JobParts operatorJobParts(KisSessions kis, http.Client net) => JobParts(
  quoteFeed: (RunMode mode) async => KisQuoteFeed(await kis.clientFor(mode)),
  priceFetch: (RunMode mode) async =>
      KisQuotes(await kis.clientFor(mode)).domesticPrice,
  fred: FredClient(net),
  ofr: OfrClient(net),
  regimeConfigHash: p0sRegimeConfigHash(),
  liveAccountBroker: (String alias) async =>
      KisOrderBroker(await kis.liveAccountClient(alias)),
);

/// 🔴 화면 · 엔진 공용 실행 묶음을 연다 — Android 가 아니거나 폴더를 못 얻으면 null(엔진은 깨어날 때 다시 시도한다).
Future<OperatorRuntime?> openOperatorRuntime() async {
  if (!Platform.isAndroid) return null;
  try {
    const SystemClock clock = SystemClock();
    final AndroidOps ops = AndroidOps();
    final String dir = (await ops.paths()).engineDir;
    // 🆕 R154 — 발주자가 정한 사람 값(자산 · 못 읽으면 null — 화면은 선다 · 실린 자산 = data_sync 시험이 지킨다).
    P0sHumanDecision? human;
    try {
      human = await loadP0sHumanDecision(rootBundle);
    } on Object {
      human = null;
    }
    // 🆕 R142 — 이 기기 id(못 얻으면 null — 화면은 그대로 선다 · 기기 id 를 쓰는 칸만 «없음»).
    final String? deviceId = await deviceIdOrNull(ops);
    // 🆕 R191 — M5-11 위저드 관찰 일수(운영 설정 자산 · 못 읽으면 null — 위저드만 «운영 설정 없음»).
    // 🆕 E16j-b — 같은 운영 설정을 실행 묶음에도 싣는다(X1 관찰 일수 · 재개 사다리).
    LiveObservationConfig? observation;
    OperationsConfig? operations;
    try {
      operations = await loadOperationsConfig(rootBundle);
      observation = operations.liveObservation;
    } on Object {
      observation = null;
      operations = null;
    }
    // 🆕 E11k-a(R197 T6) — 신뢰 시각 하나(화면 · 엔진 공용 · 잼 = 앞 화면 갱신기 · 엔진 깨어남).
    // 🆕 E11k-d2(R216) — Supabase 로그인 · 세션 하나(o_07 ③ · 실측 «로그인됨» · 리스 RPC 의 접근 토큰 원천).
    final SupabaseAuth supabaseAuth = SupabaseAuth(
      http.Client(),
      AndroidSecretVault(),
      clock: clock,
    );
    final AnchoredTrustedClock trusted = operatorTrustedClock(
      http: http.Client(),
      vault: AndroidSecretVault(),
      wall: clock,
    );
    final LedgerFiles files = LedgerFiles.open(dir, clock: clock);
    // 🆕 E11k-e3(R229) — 리스 RPC(같은 로그인 세션) · ⑤ 첫 클레임 · 원격 리스 원천 · 🆕 E16t3c X1-3 비상 시작(같은 RPC).
    final SupabaseLeaseRpc leaseRpc = SupabaseLeaseRpc(
      http.Client(),
      AndroidSecretVault(),
      supabaseAuth,
    );
    final ({SupabaseFirstClaim? firstClaim, LeaseRemoteOf? leaseRemote}) lease =
        operatorLeaseParts(
          rpc: leaseRpc,
          sim: files.sim,
          deviceId: deviceId,
          clock: clock,
        );
    return OperatorRuntime(
      files: files,
      clock: clock,
      secure: SecureScreen(ops.setSecure),
      openExternal: ops.openExternalUrl,
      // 🆕 R109 — 감시 보드의 바깥 대조(읽기 키 = 금고 · 없으면 보드가 «읽지 못했습니다»).
      watchdogRemote: HealthchecksClient(http.Client(), AndroidSecretVault()),
      // 🆕 R118 — 키 검증 1단(통과 = 금고 저장) · 검증 HTTP = 모의 서버만.
      vault: AndroidSecretVault(),
      kisHttp: http.Client(),
      // 🆕 R125 — 온보딩 실측(Android 생존 사실의 두 칸).
      onboardingProbe: () async {
        final SurvivalFacts f = await ops.diagnose();
        return OnboardingProbe(
          notificationsEnabled: f.notificationsEnabled,
          batteryExempt: f.batteryExempt,
          // 🆕 R216 — o_07 ③ 로그인됨(금고 새로고침 토큰 · 망 0).
          supabaseSignedIn: await supabaseAuth.hasSession(),
        );
      },
      // 🆕 R136 — H-03 기기 측정(값만 · 판정 = 엔진).
      deviceProbe: () => ops.deviceRisk(clock.nowUtc()),
      // 🆕 R159 — O-04 ③ 생체 서명(프레임워크 BiometricPrompt).
      biometricSign: ops.biometricSign,
      deviceId: deviceId,
      humanDecision: human,
      // 🆕 R167 — 골든 기기 실행기(자산 = 엔진 패키지 · 읽기 · 실행 = 처음 부를 때 · 백그라운드 isolate).
      golden: OperatorGolden(rootBundle.loadString, clock: clock),
      liveObservation: observation,
      operations: operations,
      trusted: trusted,
      refreshTrusted: trusted.refresh,
      // 🆕 E11k-c(R206) — o_07 ② 연결 확인(붙여 넣은 값으로 서버 시각 1회 · 통과 = 금고).
      supabaseTime: SupabaseServerTime(http.Client(), AndroidSecretVault()),
      supabaseAuth: supabaseAuth,
      firstClaim: lease.firstClaim,
      x1Emergency: operatorX1Emergency(
        rpc: leaseRpc,
        sim: files.sim,
        deviceId: deviceId,
        clock: clock,
      ),
      // 🆕 R248 — R-01 기기 원장 읽기(같은 로그인 세션 · 읽기만).
      deviceLedger: SupabaseDeviceLedger(
        http.Client(),
        AndroidSecretVault(),
        supabaseAuth,
      ),
      leaseRemote: lease.leaseRemote,
      // 🆕 E16j-a(R227 · 미결 217 ⓒ) — 정정 직전 재대사(주문 잡과 같은 브로커 조립 · 쓰기 0 · 못 하면 null).
      freshRecon: (OperatorView v, TradeDate day) => operatorFreshReconIds(
        db: v.db,
        runMode: v.flags.runMode,
        clock: clock,
        calendars: JobCalendars(
          kr: frozenExchangeCalendar(Market.kr),
          us: frozenExchangeCalendar(Market.us),
        ),
        parts: operatorJobParts(
          KisSessions(vault: AndroidSecretVault(), http: http.Client()),
          http.Client(),
        ),
        tradeDate: day,
      ),
    );
  } on Object {
    return null;
  }
}
