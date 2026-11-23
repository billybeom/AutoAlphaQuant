// 기동 판정 조립(E11p3a · 설계 e11p-map Q3 · Q4 · 정본 = 01 §9-5 · 04 §3-1 v2.44 ① · R82 W4 · R81 V3).
//
// 🔴 판정은 엔진이 한다 — `bootModeOf` · `repairHalfCommit`(data_sync) · `modeStartupGate`(core). 여기는 차례만 잇는다.
// 🔴 차례: 모드 해석 → 온보딩 미완이면 잡 0 → 반쯤 끝난 커밋 복구 → 운영 방식 → 기동 판정(거부 = 잡 0).
// 🔵 p3a 의 빈 입력(설계 Q3):
//    · approved = 🆕 R192(미결 205 ⓔ · 13 R102 S8 닫음) 실물 — 기본 = data_sync `startupConfigApprovalOf`(그 원장 개시 결정이
//      붙인 판의 `config_versions.approved` · live = simToAuto 커밋이 옮긴 승인 판) · 없음 = null → live 는 SAF-405 로 거부.
//    · 자격증명 환경 = 기본 «어긋남 없음»(없음은 실행기 미조립으로 드러난다) · 🆕 E11p3b-4 조립 앱 = `kisKeySetFits`(R95).
//    · 실키 검증 = 기본 false(live × 자동 매매면 `LIVE_AWAITING_KEYS` hold) · 🆕 R196(207 ⓑ) 조립 앱 = [registryLiveKeysVerified]
//      (그 원장의 키 검증 기록 — P0S 실전 세트 둘 다 통과 · simToAuto 커밋이 모의 파일 기록을 옮긴다).

import 'package:core_engine/core_engine.dart'
    show
        BootMode,
        BootModeOnboardingIncomplete,
        BootModeResolved,
        ModeFacts,
        ModeStartupGate,
        TrustedClock,
        kP0sLiveKeyKindOfAlias,
        liveKeysVerifiedOf,
        modeStartupGate;
import 'package:data_sync/data_sync.dart'
    show
        SqliteModeFacts,
        SqliteModeStore,
        bootModeOf,
        credentialRecordsOf,
        repairHalfCommit,
        startupConfigApprovalOf;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, ExecPolicy, LedgerFile, OperatingMode, RunMode;
import 'package:sqlite3/sqlite3.dart' show Database;

import 'fgs_status_source.dart' show UnknownTrustedClock;
import 'lease_wiring.dart' show LeaseRemoteOf, operatorLeaseGate;
import 'ledger_files.dart';
import 'x1_wiring.dart' show X1Wiring;

/// 기동 판정의 바깥 입력(p3b 가 채운다).
class BootInputs {
  /// 만든다 — 기본값 = p3a 의 안전한 빈 입력(설계 Q3).
  const BootInputs({
    this.approvedOf = startupConfigApprovalOf,
    this.credentialEnvironmentOk = _noMismatch,
    this.liveKeysVerified = _notVerified,
    this.deviceId,
    this.trusted = const UnknownTrustedClock(),
    this.leaseRemote,
  });

  /// 지금 설정의 SAF-405 승인(행 없음 = null) — 기본 = 원장 개시 판의 `config_versions.approved`(R192).
  final int? Function(Database db, RunMode mode) approvedOf;

  /// 자격증명 환경이 모드에 맞나.
  final bool Function(RunMode mode) credentialEnvironmentOk;

  /// 실키 검증을 마쳤나 — 🆕 R196 [db] = 기동이 고른 원장.
  final Future<bool> Function(Database db) liveKeysVerified;

  /// 🆕 E16t2a(R141 V2) — 이 기기 id(null = X1 끼울 자리 꺼짐 · 원천 = E16t2b).
  final String? deviceId;

  /// 🆕 E16t2a — 신뢰 시각(기본 = 모름 · 실물 = E11k).
  final TrustedClock trusted;

  /// 🆕 E11k-e3(R229 F8) — 원격 리스 원천(live · simBroker 만 끼운다 · 없음 = 실물 전과 같다).
  final LeaseRemoteOf? leaseRemote;

  static bool _noMismatch(RunMode mode) => true;
  static Future<bool> _notVerified(Database db) async => false;
}

/// 🆕 R196(미결 207 ⓑ) — 실키 검증 사실(기동 `LIVE_AWAITING_KEYS`) = [db] 의 키 검증 기록에서 P0S 실전 세트(`KIS_LIVE` ·
/// `KIS_ISA`) 가 모두 조회 검증 통과 · 기록 없음 · 거절 = false(hold 그대로) · 🆕 R207 주문 잡의 실키 사실(`order_job_runners`)도
/// 같은 원천(실전 개시).
Future<bool> registryLiveKeysVerified(Database db) async =>
    liveKeysVerifiedOf(
      required: kP0sLiveKeyKindOfAlias.values.toSet(),
      records: credentialRecordsOf(db),
    ) ==
    true;

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
    liveKeysVerified: () => inputs.liveKeysVerified(db),
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
  // 🆕 E16t2a(R141 V2) — X1 거부(기기 id ∧ live 일 때만)를 기동 판정 뒤에 이어 붙인다(겹침 없음).
  final List<String> x1 = X1Wiring.of(
    db,
    runMode: resolved.runMode,
    deviceId: inputs.deviceId,
    trusted: inputs.trusted,
    // 🆕 R229 — 원격 리스 = 조립 앱 원천(live · simBroker 만).
    lease: operatorLeaseGate(
      db,
      mode: resolved.runMode,
      clock: clock,
      remote: inputs.leaseRemote,
    ),
  ).bootRefusals();
  if (!gate.start || x1.isNotEmpty) {
    return EngineRejected(
      runMode: resolved.runMode,
      operatingMode: op,
      triggered: <String>[
        ...gate.triggered,
        for (final String c in x1)
          if (!gate.triggered.contains(c)) c,
      ],
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
