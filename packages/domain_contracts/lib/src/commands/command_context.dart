// 01 §4-2(A10) · §5-3 — 명령 봉투의 **실행 맥락**.
//
// 🔴 명령은 Supabase 에 INSERT 되고 엔진이 **나중에** 소비하므로, «어느 맥락에 적용할
//    명령인가»가 명령 안에 있어야 한다. 없으면 소비 시점 런타임이 정하고, 모드가 그 사이
//    바뀌면 모의 체결이 `ledger.sqlite` 에 들어가 §9-5 ④(파일 분리가 경계)가 무너진다.
//
// 🔴 **`context` 를 채우는 것은 화면이 아니라 `CommandApi` 구현이다**(G-19). 화면은
//    `ManualFillRecord` 등을 만들 때 이 필드를 비운 형태로 넘기고, 런타임 값
//    (`runMode`·`operatingMode`·`leaseEpoch`·`deviceId`)은 **폰 구현체가 실어 준다**.
//    🔴 뷰모델·화면 계층에서 `CommandContext` 를 생성하는 코드가 **0건**인 것을 C-28 이 검사한다.
//
// 🔴 소비 규칙 — 발행 시점 맥락으로 판정하고, 소비 시점 런타임과 다르면 **거부하지 않고
//    `CommandState.staleContext`**. 단 **`runMode` 불일치는 예외 없이 거부**한다
//    (파일 경계는 협상 대상이 아니다).
//
// ⏸ H-6 — 기존 5종(`journalDraft` 등)에도 이 필드를 붙일지는 M2-8 물음(§8-21)이며
//    「붙인다」가 권고 확정이다. ⏸ 사유 = `command_queue` 3컬럼이 전 명령에 걸리므로
//    **배치 D 와 같은 창**이어야 성립한다 → 이 회차의 코드는 **X7 8종에만** 붙인다.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';

part 'command_context.freezed.dart';
part 'command_context.g.dart';

/// 명령 발행 시점의 실행 맥락.
@freezed
abstract class CommandContext with _$CommandContext {
  const factory CommandContext({
    /// 🔴 발행 시점 값.
    required RunMode runMode,

    /// 🔴 발행 시점 값.
    required OperatingMode operatingMode,

    /// 🔴 발행 시점 X1 리스 epoch.
    required int leaseEpoch,
    required String deviceId,
  }) = _CommandContext;

  factory CommandContext.fromJson(Map<String, dynamic> json) =>
      _$CommandContextFromJson(json);
}
