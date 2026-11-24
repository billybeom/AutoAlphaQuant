// 🆕 E11q-s05 — M9 `S05` 승격(`runtimeLivePromotion{}`) operator 판(설계 13 §8 R252 · 01 §28 K6 · 06 `M1-22` · 미결 169).
//
// 🔴 판정 · 쓰기 = 엔진 저장(data_sync `SqliteLivePromotionStore.promote` — 한 트랜잭션 = 관찰 재판정 + 사전 판정 +
//    `decision_log` MANUAL + `mode_transition` EXEC_POLICY · 실패 = 전부 되돌림) · 결과 글자 = 엔진(`livePromotionActionResultOf`).
// 🔴 생체 1회 = 런타임 생체(M5 게이트 다이얼로그 · `biometricSign` — 확인 없음 = `BIOMETRIC_UNAVAILABLE` · 자동 승격 0).
// 🔴 리스 = 실전 파일 판정(원격 = 조립 앱 원천 · 모름 = 거부 — 엔진 사전 판정 차례) · 세션 = 없음(S05 승격 = args `{}`).
// 🔴 실전 파일이 없거나 관찰 설정이 없으면 = 쓰지 않는다(«관찰 중 아님» 결과 · 지어내지 않는다).

import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        LeaseVerdict,
        LiveObservationConfig,
        LivePromotionCodes,
        livePromotionActionResultOf,
        livePromotionHeadline;
import 'package:data_sync/data_sync.dart'
    show
        LivePromotionOutcome,
        OpsConfigRead,
        OpsConfigReady,
        SqliteLeaseGate,
        SqliteLivePromotionStore,
        currentP0sOpsConfig;
import 'package:domain_contracts/domain_contracts.dart'
    show ActionResult, RunMode;
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/lease_wiring.dart' show operatorLeaseGate;
import 'operator_runtime.dart';

/// `S05` 승격 operator 판.
class OperatorLivePromotion {
  /// 만든다.
  OperatorLivePromotion(this._rt);

  final OperatorRuntime _rt;

  /// 이 조립에서 승격을 받을 수 있나(생체 · 관찰 설정 — 없으면 버튼 부재).
  static bool availableIn(OperatorRuntime rt) =>
      rt.biometricSign != null && rt.liveObservation != null;

  /// 🔴 승격 — args = `{}`(그 밖 = [ArgumentError]).
  Future<ActionResult> run(String actionRunId, Map<String, String> args) async {
    if (args.isNotEmpty) {
      throw ArgumentError('runtimeLivePromotion args = {}');
    }
    final Database? live = _rt.files.liveIfExists();
    final LiveObservationConfig? config = _rt.liveObservation;
    if (live == null || config == null) {
      return livePromotionActionResultOf(
        actionRunId: actionRunId,
        code: LivePromotionCodes.notObserving,
        headline: livePromotionHeadline(LivePromotionCodes.notObserving),
      );
    }
    final Future<BiometricOutcome> Function()? ask = _rt.biometricSign;
    final bool confirmed = ask != null && (await ask()) == BiometricOutcome.ok;
    final SqliteLeaseGate gate = operatorLeaseGate(
      live,
      mode: RunMode.live,
      clock: _rt.clock,
      remote: _rt.leaseRemote,
    );
    final LeaseVerdict lease = await gate.check();
    final OpsConfigRead cfg = currentP0sOpsConfig(live);
    final LivePromotionOutcome o =
        SqliteLivePromotionStore(live, clock: _rt.clock).promote(
          biometricConfirmed: confirmed,
          configHash: cfg is OpsConfigReady ? cfg.configHash : '',
          kr: _rt.calendars.kr,
          config: config,
          lease: lease,
        );
    return livePromotionActionResultOf(
      actionRunId: actionRunId,
      code: o.reasonCode,
      headline: o.headline,
    );
  }
}
