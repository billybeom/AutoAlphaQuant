// 실입금 등록 접수증 판정 — C-38 ⑨. 01 §7 표 · §14-7 · §20.
//
// 왜 여기 있는가(설계 13 §8 R22 D14 · E7b0): 같은 판정을 **픽스처**(계약 테스트 c38)와 **실엔진 접수증**
//   (core_engine 등록 처리 시험 · E7b2)에 똑같이 건다 — `what_if_rules.dart` 와 같은 이유다.
// 🔴 `lib/` 의 화면 코드에서 import 하지 않는다(`testing.dart` 머리).
// 🔴 함수는 판정만 한다 — 위반 문장 목록을 돌려주고 빈 목록 = 통과.
// 🔴 픽스처 전용 단언(행 순서 · 상태 집합)은 계약 테스트에 남는다 — 실엔진 접수증 한 건은 한 상태다.

import '../../domain_contracts.dart';

/// C-38 ⑨ — 행이 있다 · 전 행 kind = `DEPOSIT_REGISTER` · 사유 코드가 필요한 상태(`rejected`)는
/// `deposit_register_reject` 사전의 코드를 싣고, 그 밖의 상태는 사유 코드를 싣지 않는다.
List<String> depositReceiptViolations(
  String where,
  List<CommandReceipt> rows,
) => <String>[
  if (rows.isEmpty) '$where — 행이 없다',
  for (final (int i, CommandReceipt r) in rows.indexed) ...<String>[
    if (r.kind != CommandKind.depositRegister)
      '$where rows[$i] — kind ${r.kind.wire} ≠ DEPOSIT_REGISTER',
    if (CommandStateMachine.requiresRejectReasonCode(r.state) &&
        !ContractCodes.isRegisteredIn(
          'deposit_register_reject',
          r.rejectReasonCode ?? '',
        ))
      '$where rows[$i] — 거부 사유 ${r.rejectReasonCode} 가 deposit_register_reject 사전에 없다',
    if (!CommandStateMachine.requiresRejectReasonCode(r.state) &&
        r.rejectReasonCode != null)
      '$where rows[$i] — ${r.state.wire} 인데 거부 사유 ${r.rejectReasonCode} 가 실렸다',
  ],
];
