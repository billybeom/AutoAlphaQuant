// O-04 ③ 생체 서명 operator 판(E11p4j · 설계 13 §8 R159).
//
// 🔴 서명 = 이 폰의 생체로 ② 서약 지금 판에 서명(지문 = 엔진 `biometricSignDigest` — 판 · 문장 · 기기 id) ·
//    확인되면 엔진 저장소 `SqliteBiometricSignStore` 에 한 번 적는다(sim 원장 · `command_inbox`).
// 🔴 사실(마무리 ③) = 기기 id 없음 → null(원천 없음) · 서약 없음 → false(② 가 먼저) · 판 있음 → 그 지문의 서명 행 있나.
// 🔴 취소 · 할 수 없음 = 적지 않는다 · 결과 문장 = 엔진 · 기기 암호 대체 0(플랫폼 · 05 §63).

import 'dart:math';

import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        BiometricSignTexts,
        Pledge,
        biometricSignDigest,
        biometricSignResultText,
        newCommandId;
import 'package:data_sync/data_sync.dart'
    show SqliteBiometricSignStore, SqlitePledgeStore;

import 'operator_runtime.dart';

/// ③ 생체 서명(operator).
class OperatorBiometricSign {
  /// 만든다 — [random] = 명령 id 원천(기본 = `Random.secure()`).
  OperatorBiometricSign(this._rt, {Random? random})
    : _random = random ?? Random.secure();

  final OperatorRuntime _rt;
  final Random _random;

  Pledge? _pledge() => SqlitePledgeStore(
    _rt.files.sim,
    clock: _rt.clock,
    trusted: _rt.trusted,
  ).currentPledge();

  SqliteBiometricSignStore get _store =>
      SqliteBiometricSignStore(_rt.files.sim, clock: _rt.clock);

  /// 마무리 ③ 사실(null = 원천 없음).
  bool? fact() {
    final String? dev = _rt.deviceId;
    if (dev == null) return null;
    final Pledge? p = _pledge();
    if (p == null) return false;
    return _store.signed(biometricSignDigest(pledge: p, deviceId: dev));
  }

  /// 🔴 서명한다 — 결과 문장(엔진). 확인됐을 때만 적는다.
  Future<String> sign() async {
    final Pledge? p = _pledge();
    if (p == null) return BiometricSignTexts.noPledge;
    final String? dev = _rt.deviceId;
    final Future<BiometricOutcome> Function()? ask = _rt.biometricSign;
    if (dev == null || ask == null) {
      return biometricSignResultText(BiometricOutcome.unavailable);
    }
    final BiometricOutcome o = await ask();
    if (o == BiometricOutcome.ok) {
      _store.record(
        commandId: newCommandId(_random),
        digest: biometricSignDigest(pledge: p, deviceId: dev),
        pledgeId: 'PL-${p.version}',
      );
    }
    return biometricSignResultText(o);
  }
}
