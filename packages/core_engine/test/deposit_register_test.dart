// E7b2 — 실입금 등록 판정(순수 · 설계 13 §8 R22 D4·D5·D6·D9·D10 · 01 §20).
//
// 🔵 잡는 것: ① 판정 순서 = `DepositRegisterRejectCodes.precedence`(보류는 «이미 등록» 다음) ② 대조·정정·만료의 문장 =
//    `depositRegisterBlockedText`(화면 문장과 거부 코드가 엇갈리지 않는다) ③ 만료 = 명령 `requested_at`(D9) ④ 금액은
//    스냅샷 · 계좌는 스냅샷 매핑 · 기준일은 등록 시점의 KR 거래일(D6·D10) ⑤ 접수증에 C-38 ⑨ 판정.

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

BlockFlag _flag(String id) => BlockFlag.fromJson(<String, Object?>{
  'flag_id': id,
  'label': '$id 플래그',
  'set_at': '2026-08-28T01:00:00Z',
  'clear_route': 'WIZARD_ONLY',
  'clear_instruction': '해소 안내',
});

/// 2026-08-31(월) ~ 09-08(화) — 09-05·06 주말.
final ExchangeCalendar _kr = ExchangeCalendar(
  market: Market.kr,
  sessions: <TradeDate>[
    for (final String d in <String>[
      '2026-08-31',
      '2026-09-01',
      '2026-09-02',
      '2026-09-03',
      '2026-09-04',
      '2026-09-07',
      '2026-09-08',
    ])
      TradeDate(d),
  ],
  coverageStart: const TradeDate('2026-08-31'),
  coverageEnd: const TradeDate('2026-09-08'),
);

WhatIfState _state({
  List<BlockFlag> flags = const <BlockFlag>[],
  String? generalAlias = '일반',
  bool calendar = true,
}) => WhatIfState(
  asOfTradeDate: const TradeDate('2026-08-31'),
  configHash: 'cfg_test',
  activeFlags: flags,
  recovery: false,
  accounts: WhatIfAccounts(pensionAlias: '연금저축', generalAlias: generalAlias),
  pensionUsedThisYear: _d('4200000'),
  observedAt: DateTime.utc(2026, 8, 31, 9),
  source: AsOfSource.localSqlite,
  // 목표 비중(A 20 · B 42 · C 38) 그대로 — 입금이 세 슬리브로 나뉘어 두 계좌 행이 다 생긴다.
  sleeveValues: <SleeveId, Decimal>{
    SleeveId.a: _d('4000000'),
    SleeveId.b: _d('8400000'),
    SleeveId.c: _d('7600000'),
  },
  prices: <String, Decimal>{'214980': _d('104235')},
  krCalendar: calendar ? _kr : null,
);

class _Fixed implements WhatIfStateSource {
  _Fixed(this.s);
  final WhatIfState s;
  @override
  Future<WhatIfState> load() async => s;
}

class _Clock implements Clock {
  _Clock(this.t);
  final DateTime t;
  @override
  DateTime nowUtc() => t;
}

final DateTime _t0 = DateTime.utc(2026, 8, 31, 21, 5); // KST 09-01 06:05

Future<DepositPlanSnapshot> _snapshot({String? generalAlias = '일반'}) async {
  final InMemoryPlanSnapshotStore store = InMemoryPlanSnapshotStore();
  final WhatIfState s = _state(generalAlias: generalAlias);
  final DepositPlan plan = (await EngineWhatIfApi(
    source: _Fixed(s),
    store: store,
    clock: _Clock(_t0),
  ).simulateDeposit(amountInput: '1000000')).plan!;
  return DepositPlanSnapshot(plan: plan, inputs: PlanInputs.of(s));
}

DepositRegisterCommand _command(String planId, {DateTime? at}) =>
    DepositRegisterCommand(
      commandId: 'cmd_20260901_0051',
      planId: planId,
      requestedAt: at ?? DateTime.utc(2026, 9, 1, 1),
      expiresAt: (at ?? DateTime.utc(2026, 9, 1, 1)).add(
        const Duration(minutes: 30),
      ),
      nonce: 'n_7c3e1a9f2b64',
      issuedByDeviceId: 'dev_operator_01',
    );

String? _code(DepositRegisterOutcome o) =>
    o is DepositRegisterRejected ? o.code : null;

void main() {
  test(
    '판정 순서 = precedence — 하나씩 풀면 없음 → 이미 등록 → 보류 → 대조 → 정정 → 만료 → 기록',
    () async {
      final DepositPlanSnapshot snap = await _snapshot();
      final DepositRegisterCommand late = _command(
        snap.plan.planId,
        at: snap.plan.expiresAt,
      );
      final DepositPlanSnapshot consumed = DepositPlanSnapshot(
        plan: snap.plan,
        inputs: snap.inputs,
        consumedByDecisionId: 'DEP-x',
      );
      final List<String> all = <String>[
        FlagIds.ledgerIntegrity,
        FlagIds.reconMismatch,
        FlagIds.ledgerFix,
      ];
      final List<Object?> seen = <Object?>[
        _code(
          judgeDepositRegistration(
            command: late,
            snapshot: null,
            state: _state(flags: all.map(_flag).toList()),
          ),
        ),
        _code(
          judgeDepositRegistration(
            command: late,
            snapshot: consumed,
            state: _state(flags: all.map(_flag).toList()),
          ),
        ),
        for (int i = 0; i <= all.length; i++)
          switch (judgeDepositRegistration(
            command: late,
            snapshot: snap,
            state: _state(flags: all.skip(i).map(_flag).toList()),
          )) {
            DepositRegisterRejected(:final String code) => code,
            DepositRegisterHeld() => 'HELD',
            DepositRegisterExecuted() => 'EXECUTED',
          },
        judgeDepositRegistration(
          command: _command(snap.plan.planId),
          snapshot: snap,
          state: _state(),
        ).state,
      ];
      expect(seen, <Object?>[
        DepositRegisterRejectCodes.planNotFound,
        DepositRegisterRejectCodes.planAlreadyRegistered,
        'HELD',
        DepositRegisterRejectCodes.reconPending,
        DepositRegisterRejectCodes.ledgerFixPending,
        DepositRegisterRejectCodes.planExpired,
        CommandState.executed,
      ]);
      // 거부 코드의 순서가 계약의 판정 순서와 같다(한도는 E7b3).
      expect(<Object?>[
        seen[0],
        seen[1],
        seen[3],
        seen[4],
        seen[5],
      ], DepositRegisterRejectCodes.precedence.sublist(0, 5));
    },
  );

  test('대조·정정·만료 문장 = 화면의 registerBlockedText(엇갈리지 않는다)', () async {
    final DepositPlanSnapshot snap = await _snapshot();
    for (final bool expired in <bool>[false, true]) {
      for (final List<String> flags in <List<String>>[
        <String>[],
        <String>[FlagIds.reconMismatch],
        <String>[FlagIds.ledgerFix],
        <String>[FlagIds.reconMismatch, FlagIds.ledgerFix],
      ]) {
        final WhatIfState s = _state(flags: flags.map(_flag).toList());
        final DepositRegisterOutcome o = judgeDepositRegistration(
          command: _command(
            snap.plan.planId,
            at: expired ? snap.plan.expiresAt : DateTime.utc(2026, 9, 1, 1),
          ),
          snapshot: snap,
          state: s,
        );
        final String? screen = depositRegisterBlockedText(s, expired: expired);
        expect(
          o is DepositRegisterRejected ? o.text : null,
          screen,
          reason: '$flags · expired=$expired',
        );
      }
    }
  });

  test('만료 = 명령의 requested_at — 만료 1초 전에 누른 등록은 기록한다(D9)', () async {
    final DepositPlanSnapshot snap = await _snapshot();
    final DateTime justBefore = snap.plan.expiresAt.subtract(
      const Duration(seconds: 1),
    );
    expect(
      judgeDepositRegistration(
        command: _command(snap.plan.planId, at: justBefore),
        snapshot: snap,
        state: _state(),
      ),
      isA<DepositRegisterExecuted>(),
    );
    expect(
      _code(
        judgeDepositRegistration(
          command: _command(snap.plan.planId, at: snap.plan.expiresAt),
          snapshot: snap,
          state: _state(),
        ),
      ),
      DepositRegisterRejectCodes.planExpired,
    );
  });

  test('기록 값 — 금액은 스냅샷 · B 몫 → 연금 · 나머지 → 일반 · 합 = 입금액 · id 는 계획에서', () async {
    final DepositPlanSnapshot snap = await _snapshot();
    final DepositLedgerEntry e = (judgeDepositRegistration(
      command: _command(snap.plan.planId),
      snapshot: snap,
      state: _state(),
    ) as DepositRegisterExecuted).entry;
    final Decimal bShare = snap.plan.allocations
        .where((SleeveAllocation a) => a.sleeve == SleeveId.b)
        .single
        .amount;
    expect(e.decisionId, 'DEP-${snap.plan.planId}');
    expect(e.strategyId, kDepositStrategyId);
    expect(e.reasonCode, DecisionReasonCodes.depositRegistered);
    expect(e.configHash, snap.plan.configHash);
    expect(
      e.cash.map(
        (DepositCashRow r) => '${r.flowId}|${r.accountAlias}|${r.amount}',
      ),
      <String>[
        'DEP-${snap.plan.planId}-PENSION|연금저축|$bShare',
        'DEP-${snap.plan.planId}-GENERAL|일반|${snap.plan.depositAmount - bShare}',
      ],
    );
    expect(
      e.cash.fold(Decimal.zero, (Decimal s, DepositCashRow r) => s + r.amount),
      snap.plan.depositAmount,
    );
    expect(e.reason, contains(snap.plan.planId));
    expect(e.reason, contains(wonText(snap.plan.depositAmount)));
  });

  test('일반 계좌 미지정이면 그 행의 별칭은 null(지어내지 않는다)', () async {
    final DepositPlanSnapshot snap = await _snapshot(generalAlias: null);
    final DepositLedgerEntry e = depositLedgerEntry(
      snap,
      const TradeDate('2026-09-01'),
    );
    expect(e.cash.last.accountAlias, isNull);
    expect(e.reason, contains('계좌 미지정'));
  });

  test('기준일 = 등록 시점의 KST 날짜 · 휴장이면 다음 KR 거래일 · 달력 밖·없음은 에러', () async {
    expect(
      depositTradeDate(DateTime.utc(2026, 9, 1, 14, 59), _kr),
      const TradeDate('2026-09-01'),
    );
    expect(
      depositTradeDate(DateTime.utc(2026, 9, 1, 15), _kr),
      const TradeDate('2026-09-02'),
      reason: 'UTC 15:00 = KST 다음 날 00:00',
    );
    expect(
      depositTradeDate(DateTime.utc(2026, 9, 5, 3), _kr),
      const TradeDate('2026-09-07'),
      reason: '토요일 → 월요일',
    );
    expect(
      () => depositTradeDate(DateTime.utc(2026, 9, 9, 3), _kr),
      throwsStateError,
    );
    final DepositPlanSnapshot snap = await _snapshot();
    expect(
      () => judgeDepositRegistration(
        command: _command(snap.plan.planId),
        snapshot: snap,
        state: _state(calendar: false),
      ),
      throwsStateError,
    );
    // 거부·보류 갈래는 달력이 없어도 판정한다(기준일이 필요 없다).
    expect(
      _code(
        judgeDepositRegistration(
          command: _command(snap.plan.planId),
          snapshot: null,
          state: _state(calendar: false),
        ),
      ),
      DepositRegisterRejectCodes.planNotFound,
    );
  });

  test('접수증 — 전 갈래가 C-38 ⑨ 판정을 통과 · 거부만 사유 코드 · 다른 계획 id 는 없음', () async {
    final DepositPlanSnapshot snap = await _snapshot();
    final DepositRegisterCommand c = _command(snap.plan.planId);
    final List<CommandReceipt> receipts = <CommandReceipt>[
      for (final DepositRegisterOutcome o in <DepositRegisterOutcome>[
        judgeDepositRegistration(command: c, snapshot: snap, state: _state()),
        judgeDepositRegistration(
          command: c,
          snapshot: snap,
          state: _state(flags: <BlockFlag>[_flag(FlagIds.ledgerIntegrity)]),
        ),
        judgeDepositRegistration(
          command: _command('pl_20260901_99'),
          snapshot: snap,
          state: _state(),
        ),
      ])
        depositReceipt(c, o),
    ];
    expect(depositReceiptViolations('engine', receipts), isEmpty);
    expect(receipts.map((CommandReceipt r) => r.state), <CommandState>[
      CommandState.executed,
      CommandState.heldForIntegrity,
      CommandState.rejected,
    ]);
    expect(receipts[0].stateLabel, DepositRegisterTexts.executed);
    expect(receipts[1].stateLabel, DepositRegisterTexts.held);
    expect(
      receipts[2].rejectReasonCode,
      DepositRegisterRejectCodes.planNotFound,
    );
    expect(
      receipts[2].stateLabel,
      startsWith(DepositRegisterTexts.rejectedHead),
    );
  });

  test('payload_digest = DepositRegistration JSON 의 SHA-256(원문 재저장 금지)', () {
    final DepositRegisterCommand c = _command('pl_20260901_01');
    expect(
      c.payloadDigest,
      sha256.convert(utf8.encode('{"plan_id":"pl_20260901_01"}')).toString(),
    );
    expect(_command('pl_20260901_02').payloadDigest, isNot(c.payloadDigest));
  });
}
