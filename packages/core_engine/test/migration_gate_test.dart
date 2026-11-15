// E16c — X1-5 검증 블록 → LIVE 재개 게이트(설계 13 §8 R119 C7 · C8 · 06 :267).
//
// 🔵 잡는 것: ① 차례(골든 아직 · 실패 → 대사 → UNKNOWN → 미체결 → 관찰 → 체크리스트 → 생체) ② 나쁜 것이 먼저 말한다
//    ③ 관찰 = 갈래별 설정(계획 · 비상) · 경계 n = m ④ 상태 넷뿐(롤백 · 재승격 0) ⑤ 설정 · 사실 꼴.
import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

final MigrationObservationConfig _cfg = MigrationObservationConfig(
  planTradingDays: 2,
  emergencyTradingDays: 5,
);

MigrationGateFacts _f({
  bool? golden = true,
  int recon = 0,
  int unknown = 0,
  int open = 0,
  int observed = 5,
  bool checklist = true,
  bool bio = true,
}) => MigrationGateFacts(
  goldenPassed: golden,
  reconMismatches: recon,
  unknownOrders: unknown,
  openOrders: open,
  observedTradingDays: observed,
  checklistConfirmed: checklist,
  biometricConfirmed: bio,
);

MigrationGateVerdict _g(
  MigrationGateFacts f, {
  MigrationKind kind = MigrationKind.emergency,
}) => migrationGateOf(f, kind: kind, config: _cfg);

void main() {
  test('다 갖추면 통과', () {
    final MigrationGateVerdict v = _g(_f());
    expect(
      (v.state, v.code, v.observedTradingDays, v.requiredTradingDays),
      (MigrationGateState.passed, null, 5, 5),
    );
  });

  test('🔴 골든 아직 · 실패 = 막힘(다른 것이 다 나빠도 골든이 먼저)', () {
    final MigrationGateVerdict a = _g(
      _f(golden: null, recon: 3, unknown: 1, open: 1, observed: 0),
    );
    expect(
      (a.state, a.code),
      (MigrationGateState.blocked, MigrationGateCodes.goldenNotRun),
    );
    expect(_g(_f(golden: false)).code, MigrationGateCodes.goldenFailed);
  });

  test('🔴 대사 → UNKNOWN → 미체결 차례로 막힌다', () {
    expect(
      _g(_f(recon: 1, unknown: 1, open: 1)).code,
      MigrationGateCodes.reconNotZero,
    );
    expect(_g(_f(unknown: 1, open: 1)).code, MigrationGateCodes.unknownOrders);
    expect(_g(_f(open: 1)).code, MigrationGateCodes.openOrders);
    expect(_g(_f(open: 1)).state, MigrationGateState.blocked);
  });

  test('🔴 관찰 = 갈래별 — 비상 4/5 = 관찰 중 · 계획 2/2 = 통과 · 상한 = 필요 일수', () {
    final MigrationGateVerdict e = _g(_f(observed: 4));
    expect(
      (e.state, e.code, e.observedTradingDays, e.requiredTradingDays),
      (MigrationGateState.observing, MigrationGateCodes.observing, 4, 5),
    );
    final MigrationGateVerdict p = _g(
      _f(observed: 2),
      kind: MigrationKind.plan,
    );
    expect((p.state, p.requiredTradingDays), (MigrationGateState.passed, 2));
    expect(
      _g(_f(observed: 9), kind: MigrationKind.plan).observedTradingDays,
      2,
    );
    expect(
      _g(_f(observed: 1, checklist: false), kind: MigrationKind.plan).state,
      MigrationGateState.observing,
      reason: '관찰이 차기 전에는 승인 대기가 아니다',
    );
  });

  test('🔴 체크리스트 → 생체 차례로 승인 대기', () {
    final MigrationGateVerdict c = _g(_f(checklist: false, bio: false));
    expect(
      (c.state, c.code),
      (
        MigrationGateState.awaitingApproval,
        MigrationGateCodes.checklistPending,
      ),
    );
    final MigrationGateVerdict b = _g(_f(bio: false));
    expect(
      (b.state, b.code),
      (
        MigrationGateState.awaitingApproval,
        MigrationGateCodes.biometricPending,
      ),
    );
  });

  test('🔴 상태 넷뿐 — 롤백 · 재승격 상태 없음', () {
    expect(
      MigrationGateState.values.map((MigrationGateState s) => s.wire),
      <String>['BLOCKED', 'OBSERVING', 'AWAITING_APPROVAL', 'PASSED'],
    );
  });

  test('설정 · 사실 꼴 — 관찰 0 · 음수 = ArgumentError', () {
    expect(
      () => MigrationObservationConfig(
        planTradingDays: 0,
        emergencyTradingDays: 5,
      ),
      throwsArgumentError,
    );
    expect(
      () => MigrationObservationConfig(
        planTradingDays: 2,
        emergencyTradingDays: 0,
      ),
      throwsArgumentError,
    );
    expect(() => _f(recon: -1), throwsArgumentError);
    expect(() => _f(unknown: -1), throwsArgumentError);
    expect(() => _f(open: -1), throwsArgumentError);
    expect(() => _f(observed: -1), throwsArgumentError);
    expect(_cfg.requiredFor(MigrationKind.plan), 2);
    expect(_cfg.requiredFor(MigrationKind.emergency), 5);
  });
}
