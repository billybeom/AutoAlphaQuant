// 화면이 보는 엔진 상태(E11p3d-1 · 설계 13 §8 R104 · 앱 04 §2 셸 · 01 §2 `FeatureFlags`).
//
// 🔴 화면은 엔진이 고른 원장을 본다 — 마지막 깨어남의 기동 판정(준비 · 거부)이 정한 파일 · 모드. 온보딩 미완이면
//    아직 모른다(null — 셸은 플래그를 기다린다 · 첫 실행 판정 = M4-11 ② 뒤 조각).
// 🔴 엔진과 화면은 **같은 연결**을 쓴다(`LedgerFiles` 하나) — 읽기 모델의 갱신(`db.updates`)은 같은 연결의 쓰기만 본다.
// 🔵 플래그 고정값(R104): 위성 = 꺼짐(P0S 정본 v2.31 = 위성 0) · 웹 뷰어 = 꺼짐(Q-D 미결) · 캘린더 = 꺼짐(X4 미구현) ·
//    설정 지문 = 지금 설정(모의 개시 판 · R99) — 못 얻으면 빈 글자(지어내지 않는다).

import 'package:data_sync/data_sync.dart'
    show OpsConfigRead, OpsConfigReady, currentP0sOpsConfig;
import 'package:domain_contracts/domain_contracts.dart'
    show FeatureFlags, OperatingMode, RunMode;
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/engine_boot.dart'
    show EngineBoot, EngineOnboardingIncomplete, EngineReady, EngineRejected;
import '../engine/ledger_files.dart';

/// 화면이 보는 상태.
class OperatorView {
  /// 만든다.
  const OperatorView({
    required this.db,
    required this.flags,
    this.holds = const <String>{},
    this.rejected = const <String>[],
  });

  /// 화면이 읽는 원장(엔진과 같은 연결).
  final Database db;

  /// 셸 플래그.
  final FeatureFlags flags;

  /// 🆕 미결 220 ⓓ(계약 v1.35 §44 K295) — 기동은 하되 배치를 멈추는 hold(마지막 깨어남의 기동 판정 `EngineReady.holds` ·
  /// 거부 · 온보딩 = 0 · 안전 상태 `holds` · `holdLabels` 원천 — 다음 깨어남에 다시 판정한다).
  final Set<String> holds;

  /// 🆕 E11q-s05(R252) — 마지막 깨어남의 기동 판정이 거부했으면 그 사유(엔진 차례 그대로 · 빈 = 기동함) — `S05` 엔진 제어 줄의 원천
  /// (FGS 알림 `fgsStatusForRejected` 와 같은 코드 · 다음 깨어남에 다시 판정한다).
  final List<String> rejected;
}

/// 🔴 기동 판정 → 화면 상태(온보딩 미완 = null).
OperatorView? operatorViewOf(EngineBoot boot, LedgerFiles files) {
  switch (boot) {
    case EngineOnboardingIncomplete():
      return null;
    case EngineReady():
      return _view(
        boot.db,
        boot.runMode,
        boot.operatingMode,
        holds: boot.holds,
      );
    case EngineRejected():
      final Database? db = boot.runMode == RunMode.live
          ? files.liveIfExists()
          : files.sim;
      return _view(
        db ?? files.sim,
        boot.runMode,
        boot.operatingMode,
        rejected: boot.triggered,
      );
  }
}

OperatorView _view(
  Database db,
  RunMode runMode,
  OperatingMode operating, {
  Set<String> holds = const <String>{},
  List<String> rejected = const <String>[],
}) {
  final OpsConfigRead cfg = currentP0sOpsConfig(db);
  return OperatorView(
    db: db,
    holds: Set<String>.unmodifiable(holds),
    rejected: List<String>.unmodifiable(rejected),
    flags: FeatureFlags(
      satelliteEnabled: false,
      webViewerEnabled: false,
      calendarEnabled: false,
      runMode: runMode,
      operatingMode: operating,
      configHash: cfg is OpsConfigReady ? cfg.configHash : '',
    ),
  );
}
