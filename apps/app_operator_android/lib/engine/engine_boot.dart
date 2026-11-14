// 기동 판정 조립(E11p3a · 설계 e11p-map Q3 · Q4 · 정본 = 01 §9-5 · 04 §3-1 v2.44 ① · R82 W4 · R81 V3).
//
// 🔴 판정은 엔진이 한다 — `bootModeOf` · `repairHalfCommit`(data_sync) · `modeStartupGate`(core). 여기는 차례만 잇는다.
// 🔴 차례: 모드 해석 → 온보딩 미완이면 잡 0 → 반쯤 끝난 커밋 복구 → 운영 방식 → 기동 판정(거부 = 잡 0).
// 🔵 p3a 의 빈 입력(설계 Q3):
//    · approved = 설정 지문 원천이 아직 없다(p3b) → 기본 null → live 는 SAF-405 로 거부 · sim 은 무관.
//    · 자격증명 환경 = 기본 «어긋남 없음»(없음은 실행기 미조립으로 드러난다) · 🆕 E11p3b-4 조립 앱 = `kisKeySetFits`(R95).
//    · 실키 검증 = 기본 false(live × 자동 매매면 `LIVE_AWAITING_KEYS` hold).

import 'package:core_engine/core_engine.dart'
    show
        BootMode,
        BootModeOnboardingIncomplete,
        BootModeResolved,
        ModeFacts,
        ModeStartupGate,
        modeStartupGate;
import 'package:data_sync/data_sync.dart'
    show SqliteModeFacts, SqliteModeStore, bootModeOf, repairHalfCommit;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, ExecPolicy, LedgerFile, OperatingMode, RunMode;
import 'package:sqlite3/sqlite3.dart' show Database;

import 'ledger_files.dart';

/// 기동 판정의 바깥 입력(p3b 가 채운다).
class BootInputs {
  /// 만든다 — 기본값 = p3a 의 안전한 빈 입력(설계 Q3).
  const BootInputs({
    this.approvedOf = _noApproval,
    this.credentialEnvironmentOk = _noMismatch,
    this.liveKeysVerified = _notVerified,
  });

  /// 지금 설정의 SAF-405 승인(행 없음 = null).
  final int? Function(Database db, RunMode mode) approvedOf;

  /// 자격증명 환경이 모드에 맞나.
  final bool Function(RunMode mode) credentialEnvironmentOk;

  /// 실키 검증을 마쳤나.
  final Future<bool> Function() liveKeysVerified;

  static int? _noApproval(Database db, RunMode mode) => null;
  static bool _noMismatch(RunMode mode) => true;
  static Future<bool> _notVerified() async => false;
}

/// 기동 판정 결과.
sealed class EngineBoot {
  const EngineBoot();
}

/// 온보딩 미완 — 잡을 하나도 돌리지 않는다.
final class EngineOnboardingIncomplete extends EngineBoot {
  /// 만든다.
  const EngineOnboardingIncomplete({required this.repaired});

  /// 반쯤 끝난 커밋을 고쳤나.
  final bool repaired;
}

/// 기동 거부 — 잡을 하나도 돌리지 않는다.
final class EngineRejected extends EngineBoot {
  /// 만든다.
  const EngineRejected({
    required this.runMode,
    required this.operatingMode,
    required this.triggered,
    required this.repaired,
  });

  /// 해석된 실행 모드.
  final RunMode runMode;

  /// 🆕 E11p3d-1 — 운영 방식(화면 접두 · 플래그).
  final OperatingMode operatingMode;

  /// 걸린 거부 사유(엔진 차례 그대로).
  final List<String> triggered;

  /// 반쯤 끝난 커밋을 고쳤나.
  final bool repaired;
}

/// 기동 — 잡을 돌린다.
final class EngineReady extends EngineBoot {
  /// 만든다.
  const EngineReady({
    required this.db,
    required this.file,
    required this.runMode,
    required this.operatingMode,
    required this.execPolicy,
    required this.holds,
    required this.repaired,
  });

  /// 이 모드의 원장.
  final Database db;

  /// 그 파일.
  final LedgerFile file;

  /// 실행 모드.
  final RunMode runMode;

  /// 운영 방식.
  final OperatingMode operatingMode;

  /// 집행 정책.
  final ExecPolicy execPolicy;

  /// 기동은 하되 배치를 멈추는 hold(주문 잡이 스스로 본다).
  final Set<String> holds;

  /// 반쯤 끝난 커밋을 고쳤나.
  final bool repaired;
}

/// 🔴 기동 판정 — 깨어날 때마다 부른다(설계 Q4 · 모드 전환 뒤 낡은 모드로 돌지 않게).
Future<EngineBoot> bootEngine(
  LedgerFiles files, {
  required Clock clock,
  BootInputs inputs = const BootInputs(),
}) async {
  final SqliteModeStore sim = SqliteModeStore(
    files.sim,
    LedgerFile.sim,
    clock: clock,
  );
  final Database? liveDb = files.liveIfExists();
  final SqliteModeStore? live = liveDb == null
      ? null
      : SqliteModeStore(liveDb, LedgerFile.live, clock: clock);
  final BootMode mode = bootModeOf(live: live, sim: sim);
  final bool repaired = repairHalfCommit(mode, sim);
  final BootModeResolved resolved;
  switch (mode) {
    case BootModeOnboardingIncomplete():
      return EngineOnboardingIncomplete(repaired: repaired);
    case BootModeResolved():
      resolved = mode;
  }
  final bool onLive = resolved.file == LedgerFile.live;
  final Database db = onLive ? liveDb! : files.sim;
  final SqliteModeStore store = onLive ? live! : sim;
  final OperatingMode? op = store.operatingMode();
  if (op == null) return EngineOnboardingIncomplete(repaired: repaired);
  final ModeFacts facts = await SqliteModeFacts(
    db,
    clock: clock,
    liveKeysVerified: inputs.liveKeysVerified,
  ).facts();
  final ModeStartupGate gate = modeStartupGate(
    runMode: resolved.runMode,
    operatingMode: op,
    execPolicy: resolved.execPolicy,
    handoverSessionValid: facts.handoverSessionValid,
    approved: inputs.approvedOf(db, resolved.runMode),
    credentialEnvironmentOk: inputs.credentialEnvironmentOk(resolved.runMode),
    liveKeysVerified: facts.liveKeysVerified,
  );
  if (!gate.start) {
    return EngineRejected(
      runMode: resolved.runMode,
      operatingMode: op,
      triggered: gate.triggered,
      repaired: repaired,
    );
  }
  return EngineReady(
    db: db,
    file: resolved.file,
    runMode: resolved.runMode,
    operatingMode: op,
    execPolicy: resolved.execPolicy,
    holds: gate.holds,
    repaired: repaired,
  );
}
