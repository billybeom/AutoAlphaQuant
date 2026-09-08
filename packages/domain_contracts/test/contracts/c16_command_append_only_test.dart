// C-16 명령 append-only — 01 §7 표 C-16 · §4-2 · §5-2 · 인벤토리 §9(🟡 data_sync 선행).
//
// 정의: 「`CommandApi` 구현이 `command_queue` 에 UPDATE/DELETE 를 호출하지 않는지」.
// 잡는 것: 경계 규칙 ② 우회.
//
// 🟡 «구현이 무엇을 호출하는가» 는 `data_sync` 가 있어야 볼 수 있다. 여기서는 그
//    구현이 애초에 UPDATE/DELETE 를 **부를 수 없게** 하는 계약 쪽 근거를 고정한다 —
//    ① 표면에 갱신·삭제 이름이 없고 ② 상태기계에 되살아나는 화살표가 없으며
//    ③ 정정은 갱신이 아니라 **새 행**(REVERSAL+RESTATEMENT)이다.

import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 갱신·삭제로 읽히는 이름.
final RegExp _mutatingName = RegExp(
  r'\b(update|delete|patch|edit|remove|modify|overwrite|replace)',
  caseSensitive: false,
);

void main() {
  group('C-16 명령 append-only (01 §7 · §4-2)', () {
    test('C-16 CommandApi 표면에 갱신·삭제 이름이 0건이다', () {
      final String surface = _interfaceBody(
        '${libDir.path}/src/commands/command_api.dart',
        'CommandApi',
      );
      final List<String> methods = RegExp(r'\b(\w+)\s*\(')
          .allMatches(surface)
          .map((RegExpMatch m) => m.group(1)!)
          .toList();
      expect(methods, isNotEmpty, reason: 'CommandApi 표면을 못 읽었다.');
      for (final String name in methods) {
        expect(
          _mutatingName.hasMatch(name),
          isFalse,
          reason:
              'CommandApi.$name — 명령은 쌓기만 한다(01 §4-2). '
              '「고친다」는 amend(상쇄+재기재 2행)로 표현한다.',
        );
      }
      // 🔴 정정 창구는 있어야 한다 — 없으면 사람이 원본을 고치려 든다.
      expect(methods, contains('amendManualFill'));
      expect(methods, contains('voidManualFill'));
    });

    test('C-16 종단 3상태에서 나가는 화살표가 없다', () {
      for (final CommandState state in CommandStateMachine.terminal) {
        expect(
          CommandStateMachine.transitions[state],
          isEmpty,
          reason: '$state — 종단에서 되살아나면 「명령 1건 = 사실 1건」이 깨진다(§5-2).',
        );
        expect(CommandStateMachine.isTerminal(state), isTrue);
        for (final CommandState to in CommandState.values) {
          expect(CommandStateMachine.allows(state, to), isFalse);
        }
      }
    });

    test('C-16 보류 4상태는 received 로만 돌아가고 TTL 을 소비하지 않는다', () {
      for (final CommandState state in CommandStateMachine.hold) {
        expect(
          CommandStateMachine.transitions[state],
          <CommandState>{CommandState.received},
          reason:
              '$state — 보류는 거부가 아니다. 재확인·인수·복구 뒤 received 로 '
              '돌아오는 화살표 하나뿐이다(§5-2).',
        );
        expect(
          CommandStateMachine.consumesTtl(state),
          isFalse,
          reason: '$state — 보류가 만료로 둔갑하면 「명령은 사실을 잃지 않는다」가 깨진다.',
        );
        expect(CommandStateMachine.isTerminal(state), isFalse);
      }
    });

    test('C-16 상태기계 표가 CommandState 전량을 덮는다', () {
      expect(
        CommandStateMachine.transitions.keys.toSet(),
        CommandState.values.toSet(),
        reason:
            '열거값이 늘었는데 표가 그대로면 새 상태의 전이가 «없음»으로 조용히 '
            '읽힌다 — 표를 넓히려면 §5-2 원문을 먼저 고친다.',
      );
      // 표가 가리키는 도착 상태도 전부 실재하는 값이다.
      for (final Set<CommandState> targets
          in CommandStateMachine.transitions.values) {
        for (final CommandState to in targets) {
          expect(CommandState.values, contains(to));
        }
      }
    });

    test('C-16 requested 는 executed 로 바로 가지 않는다(수신을 건너뛰지 않는다)', () {
      expect(
        CommandStateMachine.allows(
          CommandState.requested,
          CommandState.executed,
        ),
        isFalse,
        reason: '§5-2 다이어그램 — requested → received → executed 다.',
      );
      expect(
        CommandStateMachine.allows(
          CommandState.requested,
          CommandState.received,
        ),
        isTrue,
      );
    });

    test('C-16 거부 영수증은 사유 코드를 싣는다', () {
      final CommandReceipt receipt = CommandReceipt.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m6FillRejectedPrice))
            .rows
            .single,
      );
      expect(receipt.state, CommandState.rejected);
      expect(
        CommandStateMachine.requiresRejectReasonCode(receipt.state),
        isTrue,
      );
      expect(
        receipt.rejectReasonCode,
        isNotNull,
        reason: '§5-2 — rejected 는 rejectReasonCode 필수다.',
      );
      expect(
        ContractCodes.isRegisteredIn(
          'advice_reject',
          receipt.rejectReasonCode!,
        ),
        isTrue,
      );
      expect(
        receipt.stateLabel,
        isNotEmpty,
        reason:
            '표시 문구의 유일한 출처는 stateLabel 이다(§1-5) — 화면이 상태로 '
            '문장을 고르지 않는다.',
      );
    });

    test('C-16 정정은 갱신이 아니라 새 행이다(FillKind 3값)', () {
      expect(
        FillKind.values.map((FillKind k) => k.wire).toSet(),
        <String>{'ORIGINAL', 'REVERSAL', 'RESTATEMENT'},
        reason:
            'amend 1회 = REVERSAL + RESTATEMENT **2행**(01 §7 C-21) — '
            '원본을 덮어쓰는 값이 열거형에 아예 없다.',
      );
    });

    test(
      'C-16 data_sync 구현이 command_queue 에 UPDATE/DELETE 를 부르지 않는지',
      () {},
      skip:
          'data_sync 에 구현체가 아직 없다(스텁). 계약 쪽 근거(위 6건)는 «부를 이름이 '
          '없다»까지를 고정하고, SQL 문자열 검사는 구현이 들어오는 PR 에서 채운다.',
    );
  });
}

String _interfaceBody(String path, String name) {
  final String code = stripCommentsAndStrings(File(path).readAsStringSync());
  return RegExp(
    'abstract interface class $name \\{(.*?)\\n\\}',
    dotAll: true,
  ).firstMatch(code)!.group(1)!;
}
