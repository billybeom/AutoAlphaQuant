// 01 §4-2 · §5-2 — `CommandReceipt` 상태기계를 **선언 표**로 옮긴 것.
//
// 🔴 이 파일은 «판정»이 아니라 «문서의 전이 표»다. 문구를 고르거나 상태를 만들어 내지
//    않는다 — 표시 문구의 유일한 출처는 `CommandReceipt.stateLabel` 이고(§1-5), 상태를
//    바꾸는 주체는 엔진·Supabase RPC 다. 여기 있는 것은 **순수 함수 4개**뿐이고 소비처는
//    ⓐ 계약 회귀 테스트(§7) ⓑ `data_sync` 구현체의 자기 점검이다.
//
// 🔴 화면(`ui_*`)이 이 표로 분기해 문장을 만들면 §1-5 위반이다.
//
// 01 §5-2 원문 다이어그램:
//
//   requested ──▶ received ──┬──▶ executed        (종단)
//                            ├──▶ rejected        (종단 · rejectReasonCode 필수)
//                            └──▶ expired         (종단 · 서버 expires_at)
//   requested/received ──┬──▶ staleContext        ┐
//                        ├──▶ heldForIntegrity    ├ 🔴 보류 3(+1)상태 — TTL 을 소비하지 않는다
//                        ├──▶ pendingLeaseConfirm ┘   재확인·인수·복구 후 received 로 되돌아온다
//                        └──▶ noOperator          — 소비할 엔진이 없는 창(X1 이전·비상 TTL 대기)
//
// 🔴 **보류는 거부가 아니다.** 무결성 차단·리스 만료·오프라인·맥락 불일치에서 기록 명령을
//    거부하지 않고 보류한다 — 명령은 ⓐ 기기 로컬 내구 큐(암호화·재부팅 생존·**만료 없음**)에
//    먼저 쌓이고 ⓑ 네트워크가 되면 `command_queue` 에 INSERT 된다.
//
// ⚠️ 이름 주의 — `CommandStateMachine` 과 그 멤버 이름은 `docs/m2-8_naming.md` 에 없는
//    **영역 D 작성 이름**이다(전이 표를 코드로 옮기라는 이번 회차 지시의 산물). 계약 타입이
//    아니라 표의 접근자이므로 이름 확정 창에서 바꿔도 DTO·픽스처·DDL 은 흔들리지 않는다.

import '../enums/command.dart';

/// 01 §5-2 전이 표 · 그 표에서 바로 읽히는 술어들.
abstract final class CommandStateMachine {
  /// 🔴 표를 넓히려면 §5-2 원문을 먼저 고친다 — 코드가 문서를 앞지르지 않는다.
  static const Map<CommandState, Set<CommandState>> transitions =
      <CommandState, Set<CommandState>>{
        CommandState.requested: <CommandState>{
          CommandState.received,
          CommandState.staleContext,
          CommandState.heldForIntegrity,
          CommandState.pendingLeaseConfirm,
          CommandState.noOperator,
        },
        CommandState.received: <CommandState>{
          CommandState.executed,
          CommandState.rejected,
          CommandState.expired,
          CommandState.staleContext,
          CommandState.heldForIntegrity,
          CommandState.pendingLeaseConfirm,
          CommandState.noOperator,
        },
        // 🔴 보류 4상태는 «재확인·인수·복구» 뒤 `received` 로 되돌아온다.
        CommandState.staleContext: <CommandState>{CommandState.received},
        CommandState.heldForIntegrity: <CommandState>{CommandState.received},
        CommandState.pendingLeaseConfirm: <CommandState>{CommandState.received},
        CommandState.noOperator: <CommandState>{CommandState.received},
        // 🔴 종단 3상태에서 나가는 화살표는 없다.
        CommandState.executed: <CommandState>{},
        CommandState.rejected: <CommandState>{},
        CommandState.expired: <CommandState>{},
      };

  /// 종단 3상태 — 어떤 경로로도 되살아나지 않는다.
  static const Set<CommandState> terminal = <CommandState>{
    CommandState.executed,
    CommandState.rejected,
    CommandState.expired,
  };

  /// 보류 4상태 — 🔴 **TTL 을 소비하지 않는다**(§5-2).
  static const Set<CommandState> hold = <CommandState>{
    CommandState.staleContext,
    CommandState.heldForIntegrity,
    CommandState.pendingLeaseConfirm,
    CommandState.noOperator,
  };

  /// `from → to` 가 §5-2 표에 있는 화살표인가.
  static bool allows(CommandState from, CommandState to) =>
      transitions[from]?.contains(to) ?? false;

  /// 종단 상태인가.
  static bool isTerminal(CommandState state) => terminal.contains(state);

  /// TTL(`CommandReceipt.expiresAt`)을 소비하는 상태인가.
  /// 🔴 보류 4상태는 `false` — 보류가 만료로 둔갑하면 「명령은 사실을 잃지 않는다」가 깨진다.
  static bool consumesTtl(CommandState state) => !hold.contains(state);

  /// `CommandReceipt.rejectReasonCode` 가 필수인 상태인가(§5-2 「종단 · rejectReasonCode 필수」).
  static bool requiresRejectReasonCode(CommandState state) =>
      state == CommandState.rejected;
}
