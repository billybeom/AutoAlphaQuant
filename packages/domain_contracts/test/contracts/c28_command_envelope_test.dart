// C-28 (01 §7 · §5-2 · §5-3 · §10-8) — 명령 봉투 맥락 + 접수증 상태 전이.
//
// 「`simInternal × advisory` 에서 발행한 기록 명령을 `live × advisory` 런타임이
// 소비한다」의 실측은 엔진·`data_sync` 가 선행한다(인벤토리 §9 C-28 = 🟡).
// 정적 스캔분(뷰모델·화면 계층에서 `CommandContext` 생성 0건)은 `ui_*` 선행이다.
//
// 🔴 이 패키지 안에서 지킬 수 있는 것:
//    ① `CommandReceipt` 상태 전이 표가 `CommandState` **전수**를 덮는가(§5-2)
//    ② 보류 4상태가 TTL 을 소비하지 않고 `received` 로만 되돌아오는가 — 🔴 보류는
//       거부가 아니다. 보류가 만료로 둔갑하면 「명령은 사실을 잃지 않는다」가 깨진다
//    ③ X7 명령 인자 8종이 **전량** 봉투 맥락을 싣는가(A10)

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const CommandContext _context = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.advisory,
  leaseEpoch: 7,
  deviceId: 'dev_fake_0001',
);

void main() {
  group('C-28 X7 명령 봉투 맥락 (01 §7 · §5-2)', () {
    test('C-28 ① 전이 표가 CommandState 전수를 덮는다 (§5-2)', () {
      expect(
        CommandStateMachine.transitions.keys.toSet(),
        CommandState.values.toSet(),
        reason: '상태가 늘었는데 전이 표가 따라오지 않았다 — §5-2 를 먼저 고칠 것.',
      );
      for (final Set<CommandState> targets
          in CommandStateMachine.transitions.values) {
        for (final CommandState target in targets) {
          expect(CommandState.values, contains(target));
        }
      }
    });

    test('C-28 ② 종단 3상태에서 나가는 화살표가 없다', () {
      expect(CommandStateMachine.terminal, <CommandState>{
        CommandState.executed,
        CommandState.rejected,
        CommandState.expired,
      });
      for (final CommandState state in CommandStateMachine.terminal) {
        expect(
          CommandStateMachine.transitions[state],
          isEmpty,
          reason: state.wire,
        );
        expect(CommandStateMachine.isTerminal(state), isTrue);
        for (final CommandState to in CommandState.values) {
          expect(
            CommandStateMachine.allows(state, to),
            isFalse,
            reason: '${state.wire} → ${to.wire} 가 열렸다.',
          );
        }
      }
    });

    test('C-28 ③ 보류 4상태는 TTL 을 소비하지 않고 received 로만 돌아온다', () {
      expect(CommandStateMachine.hold, <CommandState>{
        CommandState.staleContext,
        CommandState.heldForIntegrity,
        CommandState.pendingLeaseConfirm,
        CommandState.noOperator,
      });
      for (final CommandState state in CommandStateMachine.hold) {
        expect(
          CommandStateMachine.consumesTtl(state),
          isFalse,
          reason: '${state.wire} 가 TTL 을 소비하면 보류가 만료로 둔갑한다.',
        );
        expect(CommandStateMachine.transitions[state], <CommandState>{
          CommandState.received,
        }, reason: '${state.wire} — 보류는 거부가 아니다.');
        expect(CommandStateMachine.isTerminal(state), isFalse);
      }
      for (final CommandState state in CommandState.values.where(
        (CommandState s) => !CommandStateMachine.hold.contains(s),
      )) {
        expect(
          CommandStateMachine.consumesTtl(state),
          isTrue,
          reason: state.wire,
        );
      }
    });

    test('C-28 ④ 맥락 불일치의 도착점은 rejected 가 아니라 staleContext 다 (A10)', () {
      // 🔴 「정당한 사실의 유실」을 막는 것이 이 상태의 존재 이유다.
      expect(
        CommandStateMachine.allows(
          CommandState.received,
          CommandState.staleContext,
        ),
        isTrue,
      );
      expect(
        CommandStateMachine.allows(
          CommandState.requested,
          CommandState.staleContext,
        ),
        isTrue,
      );
      expect(
        CommandStateMachine.isTerminal(CommandState.staleContext),
        isFalse,
      );
    });

    test('C-28 ⑤ rejectReasonCode 가 필수인 상태는 rejected 하나다 (§5-2)', () {
      for (final CommandState state in CommandState.values) {
        expect(
          CommandStateMachine.requiresRejectReasonCode(state),
          state == CommandState.rejected,
          reason: state.wire,
        );
      }

      final CommandReceipt receipt = CommandReceipt(
        commandId: 'cmd_0001',
        kind: CommandKind.manualFillRecord,
        state: CommandState.rejected,
        stateLabel: '거부됨 — 지정가 밖',
        requestedAt: DateTime.utc(2026, 8, 31, 22),
        expiresAt: DateTime.utc(2026, 9, 1, 22),
        nonce: 'nc_0001',
        issuedByDeviceId: 'dev_fake_0001',
        rejectReasonCode: AdviceRejectCodes.priceOutOfRange,
      );
      expect(receipt.rejectReasonCode, isNotNull);
      expect(CommandReceipt.fromJson(receipt.toJson()), receipt);
    });

    test('C-28 ⑥ X7 명령 인자 9종이 전량 봉투 맥락을 싣는다 (A10 · §5-3 · 🆕 v1.12 +AdviceDeferConfirm)', () {
      final List<Map<String, dynamic>> payloads = <Map<String, dynamic>>[
        ManualFillRecord(
          tradeDate: const TradeDate('2026-08-31'),
          symbol: '069500',
          side: OrderSide.buy,
          quantity: 12,
          price: Decimal.parse('38250'),
          accountAlias: '연금저축',
          offHourTrade: false,
          duplicateAck: false,
          prefilledFields: const <String>[],
          context: _context,
        ).toJson(),
        ManualFillAmendment(
          targetFillId: 'mf_0002',
          replacement: ManualFillPatchable(
            tradeDate: const TradeDate('2026-08-31'),
            quantity: 11,
            price: Decimal.parse('17510'),
            accountAlias: '연금저축',
            offHourTrade: false,
          ),
          reasonCode: 'TYPO',
          note: '수량 오기',
          context: _context,
        ).toJson(),
        const ManualFillVoid(
          targetFillId: 'mf_0002',
          reasonCode: 'TYPO',
          note: '없던 일',
          context: _context,
        ).toJson(),
        const AdviceSkip(
          adviceId: 'ad_0001',
          reason: AdviceSkipReason.brokerIssue,
          context: _context,
        ).toJson(),
        SelfReportBalance(
          asOfTradeDate: const TradeDate('2026-08-31'),
          purpose: SelfReportPurpose.simOpening,
          sessionStartedAt: DateTime.utc(2026, 8, 31, 22),
          lines: const <SelfReportLine>[],
          cashKrw: Decimal.parse('2000000'),
          accountAlias: '연금저축',
          declaredComplete: true,
          context: _context,
        ).toJson(),
        const AlertAck(alertId: 'al_0001', context: _context).toJson(),
        KillChecklistAck(
          safetyEventId: 'se_0001',
          openOrdersQueried: true,
          openOrdersCancelled: true,
          remainingCountZero: true,
          queriedAt: DateTime.utc(2026, 8, 31, 22),
          note: '전량 취소 확인',
          context: _context,
        ).toJson(),
        // 🆕 v1.12(01 §21 · K14 ⓐ) — 만료 확인 카드 「내일 다시」 와이어(맥락은 구현이 붙인다).
        const AdviceDeferConfirm(
          adviceId: 'ad_0010',
          context: _context,
        ).toJson(),
      ];

      for (final Map<String, dynamic> payload in payloads) {
        expect(
          payload['context'],
          isA<Map<String, dynamic>>(),
          reason: '봉투 맥락이 없으면 소비 시점 런타임이 맥락을 정한다(§5-3).',
        );
        // 🔴 payload 는 기기를 다시 말하지 않는다 — `deviceId` 는 맥락으로 옮겨졌다.
        expect(payload.containsKey('device_id'), isFalse);
        // 🔴 멱등은 봉투가 보장한다(A9).
        expect(payload.containsKey('idempotency_key'), isFalse);
      }
    });

    test('C-28 ⑦ CommandContext 4필드가 전부 필수다 (§5-3)', () {
      final Map<String, dynamic> json = _context.toJson();
      expect(json.keys.toSet(), <String>{
        'run_mode',
        'operating_mode',
        'lease_epoch',
        'device_id',
      });
      expect(CommandContext.fromJson(json), _context);
    });

    test(
      'C-28 ⑧ 맥락 불일치 소비 — ledger.sqlite 쓰기 0건 · staleContext 도착',
      () {},
      skip: '엔진 소비 경로와 data_sync 가 선행한다(인벤토리 §9 C-28 = 🟡).',
    );

    test(
      'C-28 ⑨ 뷰모델·화면 계층에서 CommandContext 를 생성하는 코드 0건 (G-19)',
      () {},
      skip:
          '🆕 v1.12(01 §21) — C-46 ⑳ 가 맡는다(X7 폼 3·읽기 화면 소스 스캔 `CommandContext`·와이어 생성자 0). '
          '화면은 제출 DTO 만 만든다(K4).',
    );
  });
}
