// C-45 ㊲ 원장 사건 — 01 §19 · §7 표 C-45(🆕 계약 v1.10 · 설계 13 §8 R21 · E9a2).
//
// 정의: 「매매가 아닌데 원장을 바꾸는 사실은 명령 1종으로 들어와 사실 표 1개에 쌓이고, 현금 효과는
//   `cash_flow` 한 갈래로 투영되며, TWR 의 외부 흐름은 입금·출금 둘뿐이다」.
// 잡는 것: ① 외부 흐름 판정이 갈라짐(분배금을 외부 유입으로 세면 수익률이 낮게 나온다)
//   ② 거부 사전이 사실을 거부하는 코드를 품음(사실을 거부하면 원장이 거짓이 된다 — R21 L6)
//   ③ 명령·표·코드의 이름이 m2-8 A-15·J-6 과 갈라짐 ④ 인자 DTO 의 왕복·금액 문자열 규약.

import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

CommandContext _context() => const CommandContext(
  runMode: RunMode.live,
  operatingMode: OperatingMode.advisory,
  leaseEpoch: 7,
  deviceId: 'dev_phone_1',
);

void main() {
  group('C-45 ㊲ 원장 사건 (01 §19 · 계약 v1.10)', () {
    test('C-45 ① 외부 흐름은 입금·출금 둘뿐이다(TWR·MWR 판정 창구 하나)', () {
      expect(
        <CashFlowKind>{
          for (final CashFlowKind k in CashFlowKind.values)
            if (k.isExternal) k,
        },
        <CashFlowKind>{CashFlowKind.deposit, CashFlowKind.withdrawal},
        reason: '분배금·원천징수·단주 대금은 수익·비용이다 — 외부 흐름으로 세면 TWR 이 틀린다.',
      );
    });

    test('C-45 ② 이름 — LedgerEventKind 4값 · 명령 LEDGER_EVENT_RECORD(m2-8 A-15 · J-6)', () {
      expect(_wires(LedgerEventKind.values), <String>{
        'WITHDRAWAL',
        'DISTRIBUTION',
        'CORPORATE_ACTION',
        'TAX_WITHHELD',
      });
      expect(CommandKind.ledgerEventRecord.wire, 'LEDGER_EVENT_RECORD');
      expect(_wires(CorporateActionType.values), <String>{
        'SPLIT',
        'REVERSE_SPLIT',
      }, reason: 'v1 기업행위 = 분할·병합만(R21 L5) — 그 밖은 거부 + 실사.');
      // 🔴 CORPORATE_ACTION 은 원인 코드(E9-4 통합)와 같은 낱말이다 — 두 사전이 같은 문자열을 쓴다.
      expect(
        OriginCodes.writable,
        contains(LedgerEventKind.corporateAction.wire),
      );
    });

    test('C-45 ③ 거부 사전 — 8종 · 등재됨 · 사실을 거부하는 코드가 없다', () {
      expect(LedgerEventRejectCodes.values, hasLength(8));
      expect(
        ContractCodes.byDomain['ledger_event_reject'],
        LedgerEventRejectCodes.values,
      );
      for (final String code in LedgerEventRejectCodes.values) {
        expect(
          RegExp(r'(EXCEEDS_CASH|INSUFFICIENT|NOT_IN_LEDGER|CASH_MISMATCH)')
              .hasMatch(code),
          isFalse,
          reason:
              '$code — 추정과 어긋나는 사실은 거부가 아니라 접수 + drifting 이다(R21 L6 · 01 §10-4).',
        );
      }
      // 사유 코드 5종(decision_log.reason_code) — 인출 1 · MANUAL 계열 4.
      expect(
        DecisionReasonCodes.values,
        containsAll(<String>[
          'LEDGER_EVENT_WITHDRAWAL',
          'LEDGER_EVENT_DISTRIBUTION',
          'LEDGER_EVENT_TAX_WITHHELD',
          'LEDGER_EVENT_CORPORATE_ACTION',
          'LEDGER_EVENT_VOID',
        ]),
      );
    });

    test('C-45 ④ LedgerEventRecord 왕복 — 4종 + 무효 · 금액은 문자열', () {
      final List<LedgerEventRecord> samples = <LedgerEventRecord>[
        LedgerEventRecord(
          kind: LedgerEventKind.withdrawal,
          effectiveDate: TradeDate('2026-10-20'),
          accountAlias: '일반',
          amountKrw: Decimal.parse('500000'),
          duplicateAck: false,
          context: _context(),
        ),
        LedgerEventRecord(
          kind: LedgerEventKind.distribution,
          effectiveDate: TradeDate('2026-10-20'),
          accountAlias: '일반',
          symbol: '133690',
          amountKrw: Decimal.parse('12345'),
          taxWithheldKrw: Decimal.parse('1901'),
          duplicateAck: false,
          context: _context(),
        ),
        LedgerEventRecord(
          kind: LedgerEventKind.corporateAction,
          effectiveDate: TradeDate('2026-10-20'),
          accountAlias: '연금저축',
          symbol: '133690',
          actionType: CorporateActionType.split,
          ratioFrom: 1,
          ratioTo: 2,
          duplicateAck: false,
          context: _context(),
        ),
        LedgerEventRecord(
          kind: LedgerEventKind.taxWithheld,
          effectiveDate: TradeDate('2026-10-20'),
          accountAlias: '일반',
          amountKrw: Decimal.parse('120'),
          duplicateAck: true,
          note: '예탁금 이용료 원천징수',
          context: _context(),
        ),
        LedgerEventRecord(
          kind: LedgerEventKind.withdrawal,
          effectiveDate: TradeDate('2026-10-20'),
          accountAlias: '일반',
          voidsEventId: 'le_20261020_01',
          duplicateAck: false,
          context: _context(),
        ),
      ];
      for (final LedgerEventRecord r in samples) {
        final Map<String, dynamic> json =
            jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>;
        expect(LedgerEventRecord.fromJson(json), r);
        for (final String key in <String>[
          'amount_krw',
          'tax_withheld_krw',
          'cash_in_lieu_krw',
        ]) {
          final Object? v = json[key];
          expect(
            v == null || v is String,
            isTrue,
            reason: '$key 는 Decimal 문자열이다(C-4).',
          );
        }
      }
      expect(samples[2].toJson()['action_type'], 'SPLIT');
      expect(samples[0].toJson()['kind'], 'WITHDRAWAL');
    });

    test('C-45 ⑤ DDL — ledger_event 는 역분개 짝을 CHECK 로 묶고 mode 칸이 없다 · cash_flow 는 5값 · 계좌 칸', () {
      final String f = File('${ddlDir.path}/batch_f_x7_advisory.sql')
          .readAsStringSync();
      expect(
        f,
        contains(
          "AND ((entry_kind = 'REVERSAL') = (reverses_event_id IS NOT NULL))",
        ),
        reason: '무효 행은 대상이 있어야 하고 원 행은 대상이 없어야 한다 — 산술 상쇄의 전제.',
      );
      final String table = f.substring(
        f.indexOf('CREATE TABLE IF NOT EXISTS ledger_event'),
        f.indexOf('CREATE INDEX IF NOT EXISTS ix_ledger_event_date'),
      );
      expect(
        RegExp(r'^\s+mode\s', multiLine: true).hasMatch(table),
        isFalse,
        reason: 'mode 칸은 결정 사슬 9표에만 — 원장 사건은 파일이 경계다(R20 Q1).',
      );
      expect(
        table,
        contains('authored_at'),
        reason: 'X5 authored 축 · day_hash 모집단.',
      );
      expect(
        f,
        contains('source_event_id TEXT'),
        reason: '투영 행이 원 사건을 가리킨다(R21 L1).',
      );
      // 🆕 v1.11(E7b0 · 설계 13 §8 R22 D6) — 현금 행의 계좌 축.
      final String cash = f.substring(
        f.indexOf('CREATE TABLE IF NOT EXISTS cash_flow__new'),
        f.indexOf('INSERT INTO cash_flow__new'),
      );
      expect(
        RegExp(r'^\s+account_alias\s+TEXT\b', multiLine: true).hasMatch(cash),
        isTrue,
        reason: '입금은 계좌별 행이다(B 몫 → 연금 · 나머지 → 일반) — 계좌별 현금 대사·연금 납입 누계의 원천.',
      );
    });
  });
}

Set<String> _wires(List<Object> values) => <String>{
  for (final Object v in values)
    switch (v) {
      final LedgerEventKind k => k.wire,
      final CorporateActionType t => t.wire,
      _ => throw ArgumentError('C-45 에 등록되지 않은 열거형: ${v.runtimeType}'),
    },
};
