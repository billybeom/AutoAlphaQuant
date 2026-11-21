// O-04 ⑤ 복구 카드 발급 · 첫 클레임 명시 흐름(E11k-e3 · 설계 13 §8 R229 · 06 M4-3 · M4-10 · 04 §9-5 ⑤ · R215 E4).
//
// 🔴 운영 리스를 처음 쥐는 길은 이것 하나다 — 원격 판정(`SupabaseLeaseGate`)은 쥔 epoch 0 이면 클레임하지 않는다(자동 클레임 0).
// 🔴 차례: ① ⑤ 가 열리면 카드 줄을 부를 때 복구 코드를 발급(`Random.secure()` · 메모리 하나) ② 사람이 종이에 옮겨 적고 종이를 보고 다시
//    입력 → 해시 대조(평문 비교 0) ③ 맞으면 sim 원장에 «대기» 행(해시만) · 평문을 버린다 ④ 기기 행 등록(201 · 409) ⑤ `lease_claim`
//    (해시 = 첫 클레임 · 서버가 같은 트랜잭션에서 `recovery_secret` 에 해시만) ⑥ 얻음 = «실행됨»(epoch) · 서버 거부 = «거부됨»(그 카드 무효 →
//    새 카드) · 망 · 서버 · 인증 = «대기» 그대로(종이는 유효 · 다시 시도 = 같은 해시).
// 🔴 epoch 1 = 이 해시가 서버에 있다 · epoch > 1 = 계정에 예전 카드가 있다(첫 클레임이 아니면 서버는 해시를 읽지 않는다 — R221 S5).
// 🔴 평문 = [IssuedRecoveryCode] 하나(이 객체 필드)에만 — 원장 · 금고 · 로그 · `toString` 0 · 앱이 죽으면 사라진다(새 카드).

import 'dart:async';
import 'dart:math' show Random;

import 'package:core_engine/core_engine.dart'
    show
        FirstClaimOutcome,
        RecoveryCardTexts,
        kOperatorDeviceLabel,
        newCommandId,
        recoveryCardIssueLines;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, LeaseRpcResultCodes;
import 'package:sqlite3/sqlite3.dart';

import '../local/recovery_card_store.dart';
import 'supabase_lease.dart';
import 'supabase_recovery_code.dart';

/// ⑤ 사실 한 판(🔴 평문 0 — 카드 줄은 [SupabaseFirstClaim.issueLines] 가 따로 낸다).
class RecoveryCardFact {
  /// 만든다.
  const RecoveryCardFact({
    required this.done,
    required this.pending,
    required this.lines,
  });

  /// 끝났나(리스를 얻었다).
  final bool done;

  /// 종이 확인됨 · 서버 등록 남음.
  final bool pending;

  /// 끝 · 대기 줄(엔진 글자 · 코드 0).
  final List<String> lines;
}

/// 첫 클레임 흐름(이 기기 · 프로세스에 하나 — 발급한 카드를 쥔다).
class SupabaseFirstClaim {
  /// 만든다 — [ledger] = sim 원장(온보딩 원장 · 기록 행) · [random] = 코드 · 소금 · 명령 id 원천(기본 `Random.secure()`).
  SupabaseFirstClaim(
    this._rpc,
    this._ledger, {
    required this.deviceId,
    required this._clock,
    this.platform = 'android',
    Random? random,
  }) : _random = random ?? Random.secure();

  final SupabaseLeaseRpc _rpc;
  final Database _ledger;
  final Clock _clock;
  final Random _random;

  /// 이 기기 id(`app_device.device_id`).
  final String deviceId;

  /// `app_device.platform`.
  final String platform;

  IssuedRecoveryCode? _card;
  Future<FirstClaimOutcome>? _inFlight;

  SqliteRecoveryCardStore get _store =>
      SqliteRecoveryCardStore(_ledger, clock: _clock);

  /// 🔴 ⑤ 사실.
  RecoveryCardFact fact() {
    final RecoveryCardRecord? r = _store.latest();
    return switch (r?.state) {
      RecoveryCardState.claimed => RecoveryCardFact(
        done: true,
        pending: false,
        lines: <String>[
          r!.existingCard
              ? RecoveryCardTexts.existingLine
              : RecoveryCardTexts.doneLine,
        ],
      ),
      RecoveryCardState.pending => const RecoveryCardFact(
        done: false,
        pending: true,
        lines: <String>[RecoveryCardTexts.pendingLine],
      ),
      RecoveryCardState.rejected || null => const RecoveryCardFact(
        done: false,
        pending: false,
        lines: <String>[],
      ),
    };
  }

  /// 🔴 열린 ⑤ 의 카드 줄 — 처음 부를 때 발급(메모리) · 같은 프로세스에선 같은 카드 · 끝 · 대기 = 빈 목록.
  List<String> issueLines() {
    final RecoveryCardRecord? r = _store.latest();
    if (r != null && r.state != RecoveryCardState.rejected) {
      return const <String>[];
    }
    final IssuedRecoveryCode c = _card ??= issueRecoveryCode(_random);
    return recoveryCardIssueLines(c.code, reissued: r != null);
  }

  /// 이 기기가 첫 클레임으로 얻은 epoch(원격 판정의 «쥔 epoch» 대체 · 없음 = 0).
  int claimedEpoch() => _store.claimedEpoch();

  /// 🔴 종이를 보고 다시 입력한 코드 확인 → 등록 · 첫 클레임(대기 중이면 [typed] 를 보지 않고 다시 시도).
  Future<FirstClaimOutcome> confirm(String typed) =>
      _inFlight ??= _confirm(typed).whenComplete(() => _inFlight = null);

  /// 🔴 대기 행의 해시로 등록 다시 시도.
  Future<FirstClaimOutcome> retry() => confirm('');

  Future<FirstClaimOutcome> _confirm(String typed) async {
    final RecoveryCardRecord? r = _store.latest();
    if (r != null && r.state == RecoveryCardState.claimed) {
      return FirstClaimOutcome.noCard;
    }
    if (r != null && r.state == RecoveryCardState.pending) {
      return _register(r.hash);
    }
    final IssuedRecoveryCode? c = _card;
    if (c == null) return FirstClaimOutcome.noCard;
    if (!recoveryCodeMatches(typed, c.hash)) return FirstClaimOutcome.mismatch;
    _store.append(
      commandId: newCommandId(_random),
      state: RecoveryCardState.pending,
      hash: c.hash,
    );
    // 🔴 종이가 확인됐다 — 평문을 버린다(이제 해시만 · 원장).
    _card = null;
    return _register(c.hash);
  }

  Future<FirstClaimOutcome> _register(String hash) async {
    final LeaseRpcFailure? reg = await _rpc.registerDevice(
      deviceId: deviceId,
      label: kOperatorDeviceLabel,
      platform: platform,
    );
    if (reg != null) return _failure(reg);
    final LeaseRpcResult res = await _rpc.claim(
      deviceId: deviceId,
      recoveryCodeHash: hash,
    );
    final LeaseRpcFailure? f = res.failure;
    if (f != null) return _failure(f);
    if (res.granted) {
      _store.append(
        commandId: newCommandId(_random),
        state: RecoveryCardState.claimed,
        hash: hash,
        epoch: res.epoch,
      );
      return res.epoch == 1
          ? FirstClaimOutcome.claimed
          : FirstClaimOutcome.existingCard;
    }
    // 서버 거부(계약 글자) — 그 카드는 무효(다음에 새 카드).
    final String code = res.code ?? '';
    _store.append(
      commandId: newCommandId(_random),
      state: RecoveryCardState.rejected,
      hash: hash,
      rejectCode: code,
    );
    return code == LeaseRpcResultCodes.heldByOther
        ? FirstClaimOutcome.heldByOther
        : FirstClaimOutcome.refused;
  }

  static FirstClaimOutcome _failure(LeaseRpcFailure f) => switch (f) {
    LeaseRpcFailure.config ||
    LeaseRpcFailure.notSignedIn => FirstClaimOutcome.notConnected,
    LeaseRpcFailure.unauthorized ||
    LeaseRpcFailure.server ||
    LeaseRpcFailure.badResponse ||
    LeaseRpcFailure.network => FirstClaimOutcome.retryLater,
  };

  @override
  String toString() => 'SupabaseFirstClaim(…)';
}
