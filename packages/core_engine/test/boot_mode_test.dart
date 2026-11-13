// 🆕 E15b — 기동 해석(설계 13 §8 R82 W4 · SPEC v2.44 04 §3-1 v2.44 ①).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const ModeRowFacts _live = ModeRowFacts(
  runMode: RunMode.live,
  execPolicy: ExecPolicy.dryRun,
  decisionId: 'D-LIVE',
);
const ModeRowFacts _sim = ModeRowFacts(
  runMode: RunMode.simBroker,
  execPolicy: ExecPolicy.execute,
  decisionId: 'D-SIM',
);

BootModeResolved _resolved(BootMode m) => m as BootModeResolved;

void main() {
  test('live 행 있음 = live 파일 · 그 행의 조합 · 결정', () {
    final BootModeResolved r = _resolved(
      resolveBootMode(live: _live, sim: null, simClosed: false),
    );
    expect(identical(r.file, LedgerFile.live), isTrue);
    expect(
      (r.runMode, r.execPolicy, r.decisionId, r.repairSimClose),
      (RunMode.live, ExecPolicy.dryRun, 'D-LIVE', false),
    );
  });

  test('🔴 live 행 있음 ∧ sim 안 닫힘 = 반쯤 끝난 커밋 → sim CLOSE 를 마저 · 닫혔으면 아님', () {
    expect(
      _resolved(resolveBootMode(live: _live, sim: _sim, simClosed: false))
          .repairSimClose,
      isTrue,
    );
    final BootModeResolved closed = _resolved(
      resolveBootMode(live: _live, sim: _sim, simClosed: true),
    );
    expect(closed.repairSimClose, isFalse);
    expect(identical(closed.file, LedgerFile.live), isTrue);
  });

  test('live 행 없음 = sim 최신 행 · 복구 없음', () {
    final BootModeResolved r = _resolved(
      resolveBootMode(live: null, sim: _sim, simClosed: false),
    );
    expect(identical(r.file, LedgerFile.sim), isTrue);
    expect(
      (r.runMode, r.execPolicy, r.decisionId, r.repairSimClose),
      (RunMode.simBroker, ExecPolicy.execute, 'D-SIM', false),
    );
  });

  test('🔴 둘 다 없음 · sim 만 닫힘 = 온보딩 미완(자동 매매가 아니다)', () {
    expect(
      resolveBootMode(live: null, sim: null, simClosed: false),
      isA<BootModeOnboardingIncomplete>(),
    );
    expect(
      resolveBootMode(live: null, sim: _sim, simClosed: true),
      isA<BootModeOnboardingIncomplete>(),
    );
    expect(
      resolveBootMode(live: null, sim: null, simClosed: true),
      isA<BootModeOnboardingIncomplete>(),
    );
  });
}
