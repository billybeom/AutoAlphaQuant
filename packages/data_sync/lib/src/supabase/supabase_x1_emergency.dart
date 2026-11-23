// X1-3 ① 비상 시작 — 새 복구 카드 발급 · 종이 확인 · 기기 행 등록 · `lease_revoke`(E16t3c · 설계 13 §8 R244 · 01 §8 미결 218 ⓒ ·
// 06 X1-3 · 08 그림 9-2 · O-04 ⑤ 첫 클레임 흐름 `SupabaseFirstClaim` R229 선례).
//
// 🔴 차례: ① 비상 화면의 복구 코드 자리가 서면 새 복구 코드를 발급(`Random.secure()` · 메모리 하나 — 서버가 회수와 같은 트랜잭션에서
//    옛 해시를 이 해시로 바꾼다) ② 사람이 새 코드를 종이에 옮겨 적고 종이를 보고 다시 입력 → 해시 대조(평문 비교 0) ③ «비상 복구 시작»
//    = 종이의 (옛) 복구 코드(평문 · 이 호출에만) + 새 해시 → 기기 행 등록(201 · 409) → `lease_revoke` ④ 얻음 = sim 원장에 회수 한 판
//    (서버 REVOKED 시각 · epoch · 새 해시) · 새 평문을 버린다 / 서버 거부 = 거부 행(감사) · 새 카드 그대로(종이 유효 — 다시 하면 같은 해시)
//    / 망 · 서버 · 인증 = 기록 0 · 새 카드 그대로.
// 🔴 응답을 잃었는데 서버는 바꿨다면(드묾) 옛 코드는 «맞지 않음»이 된다 — 그때 유효한 것은 방금 적은 새 종이다(같은 흐름을 그 코드로 다시).
// 🔴 평문 = [IssuedRecoveryCode] 하나 · 원장 · 금고 · 로그 · `toString` 0 · 앱이 죽으면 사라진다(새 카드).
// 🔴 이 폰에 live 원장이 있으면 부르지 않는다(부르는 쪽 · 화면 = `X1_LIVE_EXISTS`) · 이미 회수한 판이 있으면 `X1_RUN_EXISTS`.

import 'dart:async';
import 'dart:math' show Random;

import 'package:core_engine/core_engine.dart'
    show
        kOperatorDeviceLabel,
        newCommandId,
        recoveryCardIssueLines,
        x1EmergencyRunIdOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        LeaseRpcResultCodes,
        SupabaseAuthResultCodes,
        SupabaseTimeResultCodes,
        X1JournalResultCodes;
import 'package:sqlite3/sqlite3.dart';

import '../migration/x1_emergency_store.dart';
import 'supabase_lease.dart';
import 'supabase_recovery_code.dart';

/// 비상 시작 흐름(이 기기 · 프로세스에 하나 — 발급한 새 카드를 쥔다).
class SupabaseX1Emergency {
  /// 만든다 — [_sim] = sim 원장(늘 열림 · 기록 행) · [random] = 코드 · 소금 · 명령 id 원천(기본 `Random.secure()`).
  SupabaseX1Emergency(
    this._rpc,
    this._sim, {
    required this.deviceId,
    required this._clock,
    this.platform = 'android',
    Random? random,
  }) : _random = random ?? Random.secure();

  final SupabaseLeaseRpc _rpc;
  final Database _sim;
  final Clock _clock;
  final Random _random;

  /// 이 기기 id(`app_device.device_id`).
  final String deviceId;

  /// `app_device.platform`.
  final String platform;

  IssuedRecoveryCode? _card;
  bool _confirmed = false;
  Future<String?>? _inFlight;

  SqliteX1EmergencyStore get _store => SqliteX1EmergencyStore(_sim);

  /// 🔴 새 카드 줄 — 처음 부를 때 발급(메모리) · 같은 프로세스에선 같은 카드 · 이미 회수한 판이 있으면 빈 목록.
  List<String> cardLines() {
    if (_store.latest() != null) return const <String>[];
    final IssuedRecoveryCode c = _card ??= issueRecoveryCode(_random);
    return recoveryCardIssueLines(c.code);
  }

  /// 🔴 새 카드 종이 확인 — 종이를 보고 다시 입력한 코드가 맞나(해시 대조 · 맞으면 시작할 수 있다).
  bool confirmCard(String typed) {
    final IssuedRecoveryCode? c = _card;
    _confirmed = c != null && recoveryCodeMatches(typed, c.hash);
    return _confirmed;
  }

  /// 새 카드를 종이로 확인했나.
  bool get cardConfirmed => _card != null && _confirmed;

  /// 🔴 비상 시작 — [recoveryCode] = 종이의 (옛) 복구 코드(평문 · 이 호출에만) · [decisionId] = 비상 선언 결정 ·
  /// 거부 = 계약 글자(서버 · 연결 · 인증 · 전송) · 시작 = null. 겹쳐 누름 = 한 번.
  Future<String?> start({
    required String recoveryCode,
    required String decisionId,
  }) => _inFlight ??= _start(
    recoveryCode,
    decisionId,
  ).whenComplete(() => _inFlight = null);

  Future<String?> _start(String recoveryCode, String decisionId) async {
    if (decisionId.trim().isEmpty) {
      throw ArgumentError.value(decisionId, 'decisionId', '비울 수 없다');
    }
    if (_store.latest() != null) return X1JournalResultCodes.runExists;
    final IssuedRecoveryCode? c = _card;
    if (c == null || !_confirmed) {
      return LeaseRpcResultCodes.recoveryCodeRequired;
    }
    if (normalizeRecoveryCode(recoveryCode).isEmpty) {
      return LeaseRpcResultCodes.recoveryCodeInvalid;
    }
    final LeaseRpcFailure? reg = await _rpc.registerDevice(
      deviceId: deviceId,
      label: kOperatorDeviceLabel,
      platform: platform,
    );
    if (reg != null) return failureCodeOf(reg);
    final LeaseRpcResult res = await _rpc.revoke(
      deviceId: deviceId,
      recoveryCode: recoveryCode,
      newRecoveryCodeHash: c.hash,
    );
    final LeaseRpcFailure? f = res.failure;
    if (f != null) return failureCodeOf(f);
    final String? code = res.code;
    if (code != null) {
      _store.recordRejected(
        commandId: newCommandId(_random),
        code: code,
        newCodeHash: c.hash,
        atUtc: res.expiresAtUtc ?? _clock.nowUtc(),
      );
      return code;
    }
    final int? epoch = res.epoch;
    final DateTime? revokedAt = res.expiresAtUtc;
    // 성공인데 epoch · 즉시 만료 시각이 없다 = 꼴 아님(기록 0 — 펜싱 끝을 셀 수 없다).
    if (epoch == null || epoch < 1 || revokedAt == null) {
      return SupabaseTimeResultCodes.badResponse;
    }
    _store.recordRevoked(
      runId: x1EmergencyRunIdOf(revokedAt, _store.nextSeq(revokedAt)),
      decisionId: decisionId,
      operatorEpoch: epoch,
      revokedAtUtc: revokedAt,
      newCodeHash: c.hash,
    );
    // 🔴 서버가 새 해시를 쥐었다 — 평문을 버린다(이제 종이에만).
    _card = null;
    _confirmed = false;
    return null;
  }

  /// 답을 못 받은 까닭 → 계약 글자(전송 = 시각 글자 한 벌 · 로그인 없음 = 인증 글자).
  static String failureCodeOf(LeaseRpcFailure f) => switch (f) {
    LeaseRpcFailure.config => SupabaseTimeResultCodes.notConfigured,
    LeaseRpcFailure.notSignedIn => SupabaseAuthResultCodes.notSignedIn,
    LeaseRpcFailure.unauthorized => SupabaseTimeResultCodes.unauthorized,
    LeaseRpcFailure.server => SupabaseTimeResultCodes.server,
    LeaseRpcFailure.badResponse => SupabaseTimeResultCodes.badResponse,
    LeaseRpcFailure.network => SupabaseTimeResultCodes.network,
  };

  @override
  String toString() => 'SupabaseX1Emergency(…)';
}
