// 실행 모드 → 브로커 · KIS 환경 대응(02 §4 v2.44 `brokerKindFor` · 01 §9-3 키 봉인 · 설계 13 §8 R80 D15 · R81 V6).
//
// 🔴 대응은 망라 switch 하나 — `RunMode` 값이 늘면 컴파일이 깨진다(사람이 두 곳을 고치지 않게).
// 🔴 SIM 갈래(내부 시뮬레이터 · KIS 모의)의 자격증명은 모의 환경뿐이다 — 내부 시뮬레이터도 시세는 모의 앱키로 받는다(㉑).
//    SIM 기동에 실전 자격증명 = 맞지 않음 → 기동 거부(조립 앱이 이 값을 core `modeStartupGate` 에 넘긴다 · E11p).

import 'package:domain_contracts/domain_contracts.dart' show RunMode;

import 'kis_environment.dart';

/// 실행 모드의 주문 상대.
enum BrokerKind {
  /// 엔진 내부 가상 체결(브로커 주문 0 · 04 §3-1 v2.44 ③).
  internalSimulator,

  /// KIS 모의투자 서버.
  kisMock,

  /// KIS 실전.
  kisLive,
}

/// [mode] 의 주문 상대.
BrokerKind brokerKindFor(RunMode mode) => switch (mode) {
  RunMode.simInternal => BrokerKind.internalSimulator,
  RunMode.simBroker => BrokerKind.kisMock,
  RunMode.live => BrokerKind.kisLive,
};

/// [mode] 가 기대하는 KIS 환경(시세 · 주문 · 조회 모두).
KisEnvironment kisEnvironmentFor(RunMode mode) => switch (mode) {
  RunMode.simInternal || RunMode.simBroker => KisEnvironment.mock,
  RunMode.live => KisEnvironment.live,
};

/// 🔴 [credentials] 가 [mode] 에 맞나 — 아니면 기동 거부(`CREDENTIAL_ENV_MISMATCH`).
bool kisCredentialsFit(KisCredentials credentials, RunMode mode) =>
    credentials.environment == kisEnvironmentFor(mode);
