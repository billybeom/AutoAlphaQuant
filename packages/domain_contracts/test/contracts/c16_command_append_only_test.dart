// C-16 명령 append-only — 01 §7 표 C-16 · §4-2 · §5-2 · 인벤토리 §9(🟡 data_sync 선행).
//
// 정의: 「`CommandApi` 구현이 `command_queue` 에 UPDATE/DELETE 를 호출하지 않는지」.
// 잡는 것: 경계 규칙 ② 우회.
//
// 🟡 «구현이 무엇을 호출하는가» 는 `data_sync` 가 있어야 볼 수 있다. 여기서는 그
//    구현이 애초에 UPDATE/DELETE 를 **부를 수 없게** 하는 계약 쪽 근거를 고정한다 —
//    ① 표면에 갱신·삭제 이름이 없고 ② 상태기계에 되살아나는 화살표가 없으며
//    ③ 정정은 갱신이 아니라 **새 행**(REVERSAL+RESTATEMENT)이다.

import 'dart:convert';
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

    test('C-16 J-3 사전 저널 접수증 — 5상태 · 거부 사유는 journal_draft_reject 사전', () {
      // 🆕 v1.1 R2 준비(2026-09-23) — `m6/journal_draft_receipts_5.json`.
      //    C-5 는 `reject_reason_code` 를 전역으로 조회한다(X7·J-3 두 사전) — 그래서
      //    «어느 사전인가»는 여기서 픽스처 단위로 대조한다(X7 은 위 검사의 advice_reject).
      final List<CommandReceipt> receipts = decodeEnvelope(
        readFixture(FixturePaths.m6JournalDraftReceipts5),
      ).rows.map(CommandReceipt.fromJson).toList();
      expect(receipts, hasLength(5));
      expect(
        receipts.map((CommandReceipt r) => r.state).toSet(),
        <CommandState>{
          CommandState.requested,
          CommandState.executed,
          CommandState.rejected,
          CommandState.expired,
          CommandState.heldForIntegrity,
        },
        reason: '요청·집행·거부·만료·무결성 보류 — J-3 제출 뒤 화면이 받는 5갈래(02 §3-3).',
      );
      for (final CommandReceipt r in receipts) {
        expect(
          r.kind,
          CommandKind.journalDraft,
          reason: '${r.state} — J-3 접수증이다.',
        );
        expect(
          r.stateLabel,
          isNotEmpty,
          reason:
              '${r.state} — 표시 문구(거부 사유 포함)의 유일한 출처는 '
              'stateLabel 이다(§1-5).',
        );
        if (CommandStateMachine.requiresRejectReasonCode(r.state)) {
          expect(
            r.rejectReasonCode,
            isNotNull,
            reason: '§5-2 — rejected 는 rejectReasonCode 필수다.',
          );
          expect(
            ContractCodes.isRegisteredIn(
              'journal_draft_reject',
              r.rejectReasonCode!,
            ),
            isTrue,
            reason:
                'J-3 거부 사유는 X7 사전(advice_reject)이 아니라 '
                'journal_draft_reject 에 있다.',
          );
        } else {
          expect(
            r.rejectReasonCode,
            isNull,
            reason: '${r.state} — 사유 코드는 rejected 행에만 실린다(§5-2).',
          );
        }
        expect(
          r.expiresAt.isAfter(r.requestedAt),
          isTrue,
          reason: '${r.state} — 만료 시각은 요청 시각 뒤다(TTL).',
        );
      }
      expect(
        receipts
            .map(
              (CommandReceipt r) => (r.commandId, r.nonce, r.issuedByDeviceId),
            )
            .toSet(),
        hasLength(1),
        reason:
            '5행은 한 명령(같은 command_id·nonce·기기)의 갈래다 — 테스트가 state 로 '
            '골라 쓰는 전제(fixtures/README · FixturePaths 주석).',
      );
    });

    test(
      'C-16 J-4 blind 리뷰 접수증 — 6행 5상태 · 거부 사유 2종은 blind_review_reject 사전',
      () {
        // 🆕 v1.7(01 §16 · 설계서 §3-1 ⑥ · K11) — `m6/blind_review_receipts_6.json`. J-3 5행 불변식과 같은 꼴 +
        //    거부 2행(사유 2종 모두 — `j4_rejected` = ANSWERS_INVALID · «거부 뒤 결과 도착» = ALREADY_SCORED).
        final List<CommandReceipt> receipts = decodeEnvelope(
          readFixture(FixturePaths.m6BlindReviewReceipts6),
        ).rows.map(CommandReceipt.fromJson).toList();
        expect(receipts, hasLength(6));
        expect(
          receipts.map((CommandReceipt r) => r.state).toSet(),
          <CommandState>{
            CommandState.requested,
            CommandState.heldForIntegrity,
            CommandState.executed,
            CommandState.expired,
            CommandState.rejected,
          },
          reason:
              '전송 대기·무결성 보류·집행·만료·거부 — J-4 제출 뒤 화면이 받는 갈래(02 §3-4 · 그 밖 상태는 '
              'C-12 exhaustive switch 가 맡는다).',
        );
        expect(
          <String?>{
            for (final CommandReceipt r in receipts)
              if (r.state == CommandState.rejected) r.rejectReasonCode,
          },
          BlindReviewRejectCodes.values,
          reason: '거부 2행은 사유 2종을 하나씩 싣는다 — 재제출이 뜻 있는 장면 · 경합(먼저 집행된 채점이 이긴다).',
        );
        for (final CommandReceipt r in receipts) {
          expect(
            r.kind,
            CommandKind.blindReviewScore,
            reason: '${r.state} — J-4 접수증이다.',
          );
          expect(
            r.stateLabel,
            isNotEmpty,
            reason:
                '${r.state} — 표시 문구(거부 사유 포함)의 유일한 출처는 '
                'stateLabel 이다(§1-5).',
          );
          if (CommandStateMachine.requiresRejectReasonCode(r.state)) {
            expect(
              ContractCodes.isRegisteredIn(
                'blind_review_reject',
                r.rejectReasonCode!,
              ),
              isTrue,
              reason: 'J-4 거부 사유는 X7·J-3 사전이 아니라 blind_review_reject 에 있다.',
            );
          } else {
            expect(
              r.rejectReasonCode,
              isNull,
              reason: '${r.state} — 사유 코드는 rejected 행에만 실린다(§5-2).',
            );
          }
          expect(
            r.expiresAt.isAfter(r.requestedAt),
            isTrue,
            reason: '${r.state} — 만료 시각은 요청 시각 뒤다(TTL).',
          );
        }
        expect(
          receipts
              .map(
                (CommandReceipt r) =>
                    (r.commandId, r.nonce, r.issuedByDeviceId),
              )
              .toSet(),
          hasLength(1),
          reason:
              '6행은 한 명령(같은 command_id·nonce·기기)의 갈래다 — 테스트가 행을 골라 쓰는 전제'
              '(fixtures/README · FixturePaths 주석 · copyWith(state:) 0).',
        );
      },
    );

    test('C-16 거부 사유 코드의 사전은 명령 종류(kind)가 정한다 — 전 픽스처', () {
      // 🆕 v1.1 R2 준비(2026-09-23) — C-5 는 `reject_reason_code` 를 **전역**으로 조회한다
      //    (X7·J-3 두 사전이 같은 JSON 키). 그래서 «어느 사전인가»를 픽스처 이름 목록이 아니라
      //    **규칙**으로 여기서 고정한다 — 새 거부 픽스처가 들어와도 이 검사가 사전을 가린다.
      const Map<CommandKind, String> domainByKind = <CommandKind, String>{
        CommandKind.journalDraft: 'journal_draft_reject',
        // 🆕 v1.7(01 §16) — J-4 blind 리뷰 점수 제출.
        CommandKind.blindReviewScore: 'blind_review_reject',
        CommandKind.manualFillRecord: 'advice_reject',
        CommandKind.manualFillAmend: 'advice_reject',
        CommandKind.manualFillVoid: 'advice_reject',
        CommandKind.adviceSkip: 'advice_reject',
        CommandKind.selfReportBalance: 'advice_reject',
        CommandKind.alertAck: 'advice_reject',
        CommandKind.killChecklistConfirm: 'advice_reject',
        // 🆕 v1.10 ㊲ — 원장 사건 기록은 자기 사전을 쓴다(설계 13 §8 R21 L6).
        CommandKind.ledgerEventRecord: 'ledger_event_reject',
        // 🆕 v1.11(E7b0 · 01 §20) — 실입금 등록(`m7_deposit_register_receipts_5` 거부 행).
        CommandKind.depositRegister: 'deposit_register_reject',
        // 🆕 v1.12(01 §21 · K14 ⓐ) — 만료 확인 카드 「내일 다시」(`m6/advice_defer_receipts_3` 거부 행 ·
        //    `DEFER_ALREADY_USED`).
        CommandKind.adviceDeferConfirm: 'advice_reject',
      };
      final Set<String> seen = <String>{};
      for (final String path in FixturePaths.all) {
        _visitMaps(jsonDecode(readFixture(path)), (Map<String, Object?> m) {
          final Object? code = m['reject_reason_code'];
          if (code == null) {
            return;
          }
          seen.add(path);
          final Object? wire = m['kind'];
          CommandKind? kind;
          for (final CommandKind k in CommandKind.values) {
            if (k.wire == wire) {
              kind = k;
            }
          }
          final String? domain = domainByKind[kind];
          expect(
            domain,
            isNotNull,
            reason:
                '$path — kind=$wire 행에 reject_reason_code 가 있는데 그 명령의 거부 '
                '사유 사전이 정해져 있지 않다. 01 §3 에 사전을 먼저 두고 이 표를 넓힌다.',
          );
          expect(code, isA<String>(), reason: '$path — 사유 코드는 문자열이다.');
          expect(
            ContractCodes.isRegisteredIn(domain!, code as String),
            isTrue,
            reason: '$path — $code 는 $wire 의 사전($domain)에 없다.',
          );
        });
      }
      expect(
        seen,
        containsAll(<String>[
          FixturePaths.m6FillRejectedPrice,
          FixturePaths.m6JournalDraftReceipts5,
          FixturePaths.m6BlindReviewReceipts6,
          FixturePaths.m7M7DepositRegisterReceipts5,
        ]),
        reason: '거부 접수증 픽스처를 못 읽었다 — 이 검사가 아무것도 보지 않고 통과하면 안 된다.',
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

/// JSON 트리의 모든 맵(행·중첩 객체)을 [visit] 에 넘긴다.
void _visitMaps(Object? node, void Function(Map<String, Object?> m) visit) {
  if (node is Map<String, Object?>) {
    visit(node);
    for (final Object? v in node.values) {
      _visitMaps(v, visit);
    }
  } else if (node is List<Object?>) {
    for (final Object? v in node) {
      _visitMaps(v, visit);
    }
  }
}

String _interfaceBody(String path, String name) {
  final String code = stripCommentsAndStrings(File(path).readAsStringSync());
  return RegExp(
    'abstract interface class $name \\{(.*?)\\n\\}',
    dotAll: true,
  ).firstMatch(code)!.group(1)!;
}
