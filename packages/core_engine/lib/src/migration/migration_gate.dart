// X1-5 검증 블록 → LIVE 재개 게이트(순수 · 설계 13 §8 R119 C7 · C8 · 06 :267 · 청사진 X1 :418 · SPEC v2.45 04 §3-1 ③).
//
// 🔴 차례 = 골든 자가검사 → 대사 0 → UNKNOWN 0 → 미체결 0 → 관찰 n/m → 체크리스트 → 생체(나쁜 것이 먼저 말한다).
// 🔴 실패 기본값 = 매매 없는 안전 정지 그대로 — 이 게이트에는 롤백 · 옛 폰 재승격 상태가 없다.
// 🔴 관찰 일수 = 설정(계획 · 비상 — M1-22 키와 별개 · lib 리터럴 0) · 일수 세기는 호출자(E16h).

import 'package:domain_contracts/domain_contracts.dart'
    show X1GateReasonCodes, X1GateStateCodes;

import 'migration_plan.dart' show MigrationKind;

/// 재개 게이트 관찰 일수(값 = 02 §4 `operations.migration.observation_trading_days` — 잠정 · ⬜ 발주자 확정).
class MigrationObservationConfig {
  /// 만든다 — 1 미만 = [ArgumentError].
  MigrationObservationConfig({
    required this.planTradingDays,
    required this.emergencyTradingDays,
  }) {
    if (planTradingDays < 1) {
      throw ArgumentError.value(planTradingDays, 'planTradingDays', '1 이상');
    }
    if (emergencyTradingDays < 1) {
      throw ArgumentError.value(
        emergencyTradingDays,
        'emergencyTradingDays',
        '1 이상',
      );
    }
  }

  /// 계획 교체 관찰 거래일.
  final int planTradingDays;

  /// 비상 관찰 거래일.
  final int emergencyTradingDays;

  /// 갈래별 관찰 거래일.
  int requiredFor(MigrationKind kind) => switch (kind) {
    MigrationKind.plan => planTradingDays,
    MigrationKind.emergency => emergencyTradingDays,
  };
}

/// 게이트 상태 — 🔴 넷뿐(롤백 · 재승격 0).
enum MigrationGateState {
  /// 막힘(매매 없는 안전 정지 그대로).
  blocked(X1GateStateCodes.blocked),

  /// 관찰 중(dryRun).
  observing(X1GateStateCodes.observing),

  /// 승인 대기(체크리스트 → 생체).
  awaitingApproval(X1GateStateCodes.awaitingApproval),

  /// 통과(LIVE 재개 가능).
  passed(X1GateStateCodes.passed);

  const MigrationGateState(this.wire);

  /// 글자.
  final String wire;
}

/// 게이트 사유 코드(글자 = 계약 `X1GateReasonCodes` 참조 · 미결 212).
abstract final class MigrationGateCodes {
  /// 골든 자가검사 아직.
  static const String goldenNotRun = X1GateReasonCodes.goldenNotRun;

  /// 골든 자가검사 실패.
  static const String goldenFailed = X1GateReasonCodes.goldenFailed;

  /// 대사 0오차 아님.
  static const String reconNotZero = X1GateReasonCodes.reconNotZero;

  /// UNKNOWN 남음.
  static const String unknownOrders = X1GateReasonCodes.unknownOrders;

  /// 미체결 남음.
  static const String openOrders = X1GateReasonCodes.openOrders;

  /// 관찰 중.
  static const String observing = X1GateReasonCodes.observing;

  /// 체크리스트 확인 대기.
  static const String checklistPending = X1GateReasonCodes.checklistPending;

  /// 생체 확인 대기.
  static const String biometricPending = X1GateReasonCodes.biometricPending;
}

/// 게이트 사실(엔진 · 저장 · 화면이 모은다).
class MigrationGateFacts {
  /// 만든다 — 음수 = [ArgumentError].
  MigrationGateFacts({
    required this.goldenPassed,
    required this.reconMismatches,
    required this.unknownOrders,
    required this.openOrders,
    required this.observedTradingDays,
    required this.checklistConfirmed,
    required this.biometricConfirmed,
  }) {
    for (final (String n, int v) in <(String, int)>[
      ('reconMismatches', reconMismatches),
      ('unknownOrders', unknownOrders),
      ('openOrders', openOrders),
      ('observedTradingDays', observedTradingDays),
    ]) {
      if (v < 0) throw ArgumentError.value(v, n, '음수');
    }
  }

  /// 골든 자가검사(null = 아직 · 실행기 = E11o).
  final bool? goldenPassed;

  /// 마지막 대사 불일치 수.
  final int reconMismatches;

  /// UNKNOWN 주문 수.
  final int unknownOrders;

  /// 미체결 주문 수.
  final int openOrders;

  /// 연속 깨끗한 관찰 거래일.
  final int observedTradingDays;

  /// 체크리스트 확인(2단계 승인 1).
  final bool checklistConfirmed;

  /// 생체 확인(2단계 승인 2).
  final bool biometricConfirmed;
}

/// 게이트 판정.
class MigrationGateVerdict {
  const MigrationGateVerdict._(
    this.state,
    this.code,
    this.observedTradingDays,
    this.requiredTradingDays,
  );

  /// 상태.
  final MigrationGateState state;

  /// 사유(통과 = null).
  final String? code;

  /// 관찰한 거래일(상한 = 필요 일수).
  final int observedTradingDays;

  /// 필요한 거래일.
  final int requiredTradingDays;
}

/// 🔴 LIVE 재개 게이트 — 나쁜 것이 먼저 · 관찰이 차야 승인 · 체크리스트 뒤 생체.
MigrationGateVerdict migrationGateOf(
  MigrationGateFacts f, {
  required MigrationKind kind,
  required MigrationObservationConfig config,
}) {
  final int m = config.requiredFor(kind);
  final int n = f.observedTradingDays > m ? m : f.observedTradingDays;
  MigrationGateVerdict v(MigrationGateState s, String? c) =>
      MigrationGateVerdict._(s, c, n, m);
  if (f.goldenPassed == null) {
    return v(MigrationGateState.blocked, MigrationGateCodes.goldenNotRun);
  }
  if (f.goldenPassed == false) {
    return v(MigrationGateState.blocked, MigrationGateCodes.goldenFailed);
  }
  if (f.reconMismatches > 0) {
    return v(MigrationGateState.blocked, MigrationGateCodes.reconNotZero);
  }
  if (f.unknownOrders > 0) {
    return v(MigrationGateState.blocked, MigrationGateCodes.unknownOrders);
  }
  if (f.openOrders > 0) {
    return v(MigrationGateState.blocked, MigrationGateCodes.openOrders);
  }
  if (f.observedTradingDays < m) {
    return v(MigrationGateState.observing, MigrationGateCodes.observing);
  }
  if (!f.checklistConfirmed) {
    return v(
      MigrationGateState.awaitingApproval,
      MigrationGateCodes.checklistPending,
    );
  }
  if (!f.biometricConfirmed) {
    return v(
      MigrationGateState.awaitingApproval,
      MigrationGateCodes.biometricPending,
    );
  }
  return v(MigrationGateState.passed, null);
}
