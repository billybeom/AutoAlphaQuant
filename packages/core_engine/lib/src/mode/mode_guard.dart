// 모드 조합 가드 · 기동 판정(앱 06 X6-3 · X7-8 · X18 · 01 §10-2 · SPEC v2.44 04 §3-1 v2.44 ①② · 설계 13 §8 R80 D2 · D3 · R81 V1~V5).
//
// 🔴 12칸 판정 = 01 §10-2 **칸별**(허용 6 · 금지 5 · 조건부 1) · 레코드 망라 switch — 축 값이 늘면 컴파일이 깨진다.
// 🔴 판정은 순수 함수 하나 · 강제는 두 자리(기동 판정 · 주문 잡 셋 본체 앞) · 화면은 판정하지 않는다.
// 🔴 `LIVE_AWAITING_KEYS` = hold(기동은 한다 · 배치만 멈춘다) · 자동 매매에서만 · 안내 모드는 키가 없는 것이 정상.
// 🔴 거부 코드는 계약 1.19.0 등재 전까지 엔진 문자열(01 §10-2 · `SafetyHoldCodes` 와 같은 글자).

import 'package:domain_contracts/domain_contracts.dart'
    show ExecPolicy, OperatingMode, RunMode, SafetyHoldCodes;

import '../safety/rule_change.dart' show startupConfigGate;

/// 조합 거부 코드(01 §10-2 · 계약 등재 = 1.19.0).
const String kModeCombinationDenied = 'MODE_COMBINATION_DENIED';

/// 금고 자격증명의 환경 ≠ 실행 모드가 기대하는 환경(02 §4 v2.44 `brokerKindFor`).
const String kCredentialEnvMismatch = 'CREDENTIAL_ENV_MISMATCH';

/// 12칸 한 칸의 판정.
enum ModeCell {
  /// 허용.
  allowed,

  /// 금지.
  denied,

  /// 조건부(#12 — 유효한 `handover_session_id` 가 있을 때만).
  conditional,
}

/// 01 §10-2 칸별 판정(#1~#12).
ModeCell modeCombinationCell(RunMode run, OperatingMode op, ExecPolicy exec) =>
    switch ((run, op, exec)) {
      (RunMode.simInternal, OperatingMode.autoTrade, ExecPolicy.execute) =>
        ModeCell.allowed, // #1
      (RunMode.simInternal, OperatingMode.autoTrade, ExecPolicy.dryRun) =>
        ModeCell.denied, // #2
      (RunMode.simInternal, OperatingMode.advisory, ExecPolicy.execute) =>
        ModeCell.allowed, // #3
      (RunMode.simInternal, OperatingMode.advisory, ExecPolicy.dryRun) =>
        ModeCell.denied, // #4
      (RunMode.simBroker, OperatingMode.autoTrade, ExecPolicy.execute) =>
        ModeCell.allowed, // #5
      (RunMode.simBroker, OperatingMode.autoTrade, ExecPolicy.dryRun) =>
        ModeCell.denied, // #6
      (RunMode.simBroker, OperatingMode.advisory, ExecPolicy.execute) =>
        ModeCell.denied, // #7
      (RunMode.simBroker, OperatingMode.advisory, ExecPolicy.dryRun) =>
        ModeCell.denied, // #8
      (RunMode.live, OperatingMode.autoTrade, ExecPolicy.dryRun) =>
        ModeCell.allowed, // #9
      (RunMode.live, OperatingMode.autoTrade, ExecPolicy.execute) =>
        ModeCell.allowed, // #10
      (RunMode.live, OperatingMode.advisory, ExecPolicy.execute) =>
        ModeCell.allowed, // #11
      (RunMode.live, OperatingMode.advisory, ExecPolicy.dryRun) =>
        ModeCell.conditional, // #12
    };

/// 조합이 허용되나 — 조건부 칸은 [handoverSessionValid] 일 때만.
bool modeCombinationAllowed(
  RunMode run,
  OperatingMode op,
  ExecPolicy exec, {
  required bool handoverSessionValid,
}) => switch (modeCombinationCell(run, op, exec)) {
  ModeCell.allowed => true,
  ModeCell.denied => false,
  ModeCell.conditional => handoverSessionValid,
};

/// 실키 검증 전 hold 가 걸리나(live ∧ 자동 매매 ∧ 미검증 · 01 §9-5 ③).
bool liveAwaitingKeys(
  RunMode run,
  OperatingMode op, {
  required bool liveKeysVerified,
}) => run == RunMode.live && op == OperatingMode.autoTrade && !liveKeysVerified;

/// 기동 판정 결과(04 §3-1 v2.44 ①).
class ModeStartupGate {
  /// 결과를 만든다.
  const ModeStartupGate({
    required this.start,
    required this.triggered,
    required this.holds,
  });

  /// 기동하나(거부 = 잡을 하나도 돌리지 않는다).
  final bool start;

  /// 걸린 거부 사유(차례 = SAF-405 → 조합 → 자격증명 환경).
  final List<String> triggered;

  /// 기동은 하되 배치를 멈추는 hold.
  final Set<String> holds;
}

/// 🔴 기동 판정 — SAF-405 · 모드 조합 · 자격증명 환경을 한 번에 본다(R81 V3).
ModeStartupGate modeStartupGate({
  required RunMode runMode,
  required OperatingMode operatingMode,
  required ExecPolicy execPolicy,
  required bool handoverSessionValid,
  required int? approved,
  required bool credentialEnvironmentOk,
  required bool liveKeysVerified,
}) {
  final List<String> triggered = <String>[
    ...startupConfigGate(runMode: runMode, approved: approved).triggered,
    if (!modeCombinationAllowed(
      runMode,
      operatingMode,
      execPolicy,
      handoverSessionValid: handoverSessionValid,
    ))
      kModeCombinationDenied,
    if (!credentialEnvironmentOk) kCredentialEnvMismatch,
  ];
  return ModeStartupGate(
    start: triggered.isEmpty,
    triggered: triggered,
    holds: <String>{
      if (liveAwaitingKeys(
        runMode,
        operatingMode,
        liveKeysVerified: liveKeysVerified,
      ))
        SafetyHoldCodes.liveAwaitingKeys,
    },
  );
}

/// 🔴 주문 잡 앞 판정(R81 V4) — 거부 코드 · 통과 = null(조합 → hold 차례).
String? orderJobModeReject({
  required RunMode runMode,
  required OperatingMode operatingMode,
  required ExecPolicy execPolicy,
  required ModeFacts facts,
}) {
  if (!modeCombinationAllowed(
    runMode,
    operatingMode,
    execPolicy,
    handoverSessionValid: facts.handoverSessionValid,
  )) {
    return kModeCombinationDenied;
  }
  if (liveAwaitingKeys(
    runMode,
    operatingMode,
    liveKeysVerified: facts.liveKeysVerified,
  )) {
    return SafetyHoldCodes.liveAwaitingKeys;
  }
  return null;
}

/// 판정 입력(정본 = E15b `mode_transition` · 금고 = E11p).
class ModeFacts {
  /// 입력을 만든다.
  const ModeFacts({
    required this.handoverSessionValid,
    required this.liveKeysVerified,
  });

  /// 유효한 게이트 · 위저드 세션 토큰이 있나(#12).
  final bool handoverSessionValid;

  /// 실키가 검증됐나(`LIVE_AWAITING_KEYS`).
  final bool liveKeysVerified;
}

/// 판정 입력 포트(R81 V5 · 🔴 예외 = 거부).
abstract interface class ModeFactsSource {
  /// 지금의 입력.
  Future<ModeFacts> facts();
}

/// 모드 가드가 막았다(그 잡 FAILED · 브로커 0).
class ModeGuardRejected implements Exception {
  /// 거부를 만든다.
  const ModeGuardRejected(this.code);

  /// 거부 코드(`MODE_COMBINATION_DENIED` · `LIVE_AWAITING_KEYS`).
  final String code;

  @override
  String toString() => 'ModeGuardRejected($code)';
}
