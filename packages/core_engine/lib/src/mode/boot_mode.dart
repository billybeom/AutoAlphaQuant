// 기동 해석 — 어느 원장 파일 · 어느 조합으로 여나(SPEC v2.44 04 §3-1 v2.44 ① · 02 §2-6 `mode_transition` · 설계 13 §8 R82 W4).
//
// 🔴 live 파일에 행이 있으면 live(그 파일 최신 행) · 없으면 sim 파일 최신 행 · 둘 다 없거나 sim 이 닫혔으면 «온보딩 미완»
//    (자동 매매가 아니다 — G-02). 🔴 자동 강등 없음(live → sim 으로 내려가는 갈래가 없다).
// 🔴 simToAuto 커밋 = 2단(live 행 먼저 → sim CLOSE) — live 행 있음 ∧ sim 안 닫힘 = 반쯤 끝남 → sim CLOSE 를 마저 쓴다.

import 'package:domain_contracts/domain_contracts.dart'
    show ExecPolicy, LedgerFile, RunMode;

/// 한 파일의 현재 모드(최신 비-CLOSE 행).
class ModeRowFacts {
  /// 사실을 만든다.
  const ModeRowFacts({
    required this.runMode,
    required this.execPolicy,
    required this.decisionId,
  });

  /// 실행 모드.
  final RunMode runMode;

  /// 집행 정책.
  final ExecPolicy execPolicy;

  /// 그 전이의 결정.
  final String decisionId;
}

/// 기동 해석 결과.
sealed class BootMode {
  const BootMode();
}

/// 열 파일 · 조합이 정해졌다.
final class BootModeResolved extends BootMode {
  /// 결과를 만든다.
  const BootModeResolved({
    required this.file,
    required this.runMode,
    required this.execPolicy,
    required this.decisionId,
    required this.repairSimClose,
  });

  /// 열 원장 파일.
  final LedgerFile file;

  /// 실행 모드.
  final RunMode runMode;

  /// 집행 정책.
  final ExecPolicy execPolicy;

  /// 그 행의 결정(반쯤 끝난 커밋을 마저 닫을 때 쓴다).
  final String decisionId;

  /// sim 파일 CLOSE 를 마저 써야 하나(2단 커밋 반쯤 끝남).
  final bool repairSimClose;
}

/// «온보딩 미완» — 자동 매매가 아니다(잡을 돌리지 않는다).
final class BootModeOnboardingIncomplete extends BootMode {
  /// 결과를 만든다.
  const BootModeOnboardingIncomplete();
}

/// 🔴 기동 해석(R82 W4) — [live] · [sim] = 각 파일의 현재 행(없으면 null) · [simClosed] = sim 파일 CLOSE 행 있음.
BootMode resolveBootMode({
  required ModeRowFacts? live,
  required ModeRowFacts? sim,
  required bool simClosed,
}) {
  if (live != null) {
    return BootModeResolved(
      file: LedgerFile.live,
      runMode: live.runMode,
      execPolicy: live.execPolicy,
      decisionId: live.decisionId,
      repairSimClose: sim != null && !simClosed,
    );
  }
  if (sim == null || simClosed) return const BootModeOnboardingIncomplete();
  return BootModeResolved(
    file: LedgerFile.sim,
    runMode: sim.runMode,
    execPolicy: sim.execPolicy,
    decisionId: sim.decisionId,
    repairSimClose: false,
  );
}
