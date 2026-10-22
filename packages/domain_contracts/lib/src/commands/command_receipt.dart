// 01 §4-2 · §5-2 — 명령 접수증.
//
// 🔴 반환값은 «요청 접수»이지 «집행 완료»가 아니다. 화면은 `state` 를 스스로 낙관
//    갱신하지 않는다 — 「요청됨」과 「집행됨」의 구별이 이 계약의 목적이다.
//    🔴 X7 에서는 이것이 표류 인지의 출발점이다: 「기록 버튼을 눌렀다」와 「원장에 들어갔다」는
//    다른 사건이다.
// 🔴 멱등은 봉투가 보장한다(`command_id` + `unique(kind, nonce)`) — payload 에
//    `idempotencyKey` 를 두지 않는다(A9).
// 🔴 표시 문구는 `stateLabel` 하나다. 화면이 `state` 를 보고 문장을 조합하지 않는다(§1-5).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/command.dart';

part 'command_receipt.freezed.dart';
part 'command_receipt.g.dart';

/// 명령 1건의 접수 상태.
@freezed
abstract class CommandReceipt with _$CommandReceipt {
  const factory CommandReceipt({
    required String commandId,
    required CommandKind kind,
    required CommandState state,

    /// 「요청됨 — 엔진 수신 대기」 — 🔴 엔진 생성 문자열.
    /// 🔴 `CommandState.noOperator` 의 문구는 **M2 가 사전 공급한 고정 카탈로그**에서
    ///    고른 값이 실려 온다(§10-8) — 앱이 상태를 조합해 문장을 만들지 않는다.
    required String stateLabel,
    required DateTime requestedAt,

    /// TTL. 🔴 **보류 4상태는 TTL 을 소비하지 않는다**(`CommandStateMachine.consumesTtl`).
    required DateTime expiresAt,
    required String nonce,
    required String issuedByDeviceId,

    /// 🔴 `state == CommandState.rejected` 이면 필수다(§5-2 ·
    ///    `CommandStateMachine.requiresRejectReasonCode`).
    ///    🔴 **거부는 초안을 지우지 않는다**(C17) — 초안 삭제는 `executed` 수신 시에만.
    String? rejectReasonCode,

    /// 🆕 v1.12(01 §21 · K20) — 거부 뒤 엔진이 실은 «재제출 선택지» 1개(B5 시간외·단주 · A9 중복 확인).
    /// `state == rejected` 일 때만 · [retryLabel] 과 짝 · 값 = `AdviceRetryCodes`. 🔴 X7 기록 명령 전용(01 §21).
    /// 🔴 화면은 [retryCode] 를 해석하지 않는다 — [retryLabel] 버튼 → 제출 DTO `retryCodes` 에 더한다.
    String? retryCode,

    /// "시간외·단주 신고로 다시 제출" — 엔진.
    String? retryLabel,
  }) = _CommandReceipt;

  factory CommandReceipt.fromJson(Map<String, dynamic> json) =>
      _$CommandReceiptFromJson(json);
}
