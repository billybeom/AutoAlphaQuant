// M3-4 입금 원장 읽기 — 연금 납입 누계(D7)의 입력 · «계획 대비 실제»의 앵커(D8)(설계 13 §8 R22 · 01 §20 · E7b3).
//
// 🔴 읽기만 한다. 누계 셈은 core_engine `pensionUsedInYear` 하나 — 등록 기록기(한도 재검사)와 상태 공급자(E11 ·
//    `WhatIfState.pensionUsedThisYear`)가 [SqliteDepositLedger.cashRows] 를 그 함수에 넘긴다(둘이 다르면 미리보기와
//    등록이 서로 다른 한도를 본다).
// 🔴 앵커 = 계획 ↔ 결정 ↔ 현금 행: `plan_snapshot.consumed_by_decision_id` = `decision_log.decision_id` 이고
//    현금 행은 `{decision_id}-PENSION|GENERAL`(R12). 등록 안 된 계획은 빈 목록이다.
// 🔵 금액(REAL → 원)·열거값 해석은 core_engine 의 `fromColumns` 가 한다 — 이 패키지는 금액 타입을 직접 다루지 않는다
//    (01 §1-1 허용 목록 = `sqlite3`).

import 'package:core_engine/core_engine.dart'
    show DepositCashRow, LedgerCashRow;
import 'package:sqlite3/sqlite3.dart';

/// 로컬 원장 파일의 입금 읽기.
final class SqliteDepositLedger {
  SqliteDepositLedger(this._db);

  final Database _db;

  /// 계좌 [accountAlias] 의 현금 행 전부(동기 — 등록 트랜잭션 안에서 await 없이 읽는다).
  List<LedgerCashRow> cashRows(String accountAlias) => <LedgerCashRow>[
    for (final Row r in _db.select(
      'SELECT kind, account_alias, amount, trade_date, recorded_at FROM cash_flow '
      'WHERE account_alias = ?',
      <Object>[accountAlias],
    ))
      LedgerCashRow.fromColumns(
        kind: r['kind'] as String,
        accountAlias: r['account_alias'] as String?,
        amount: r['amount'] as num,
        tradeDate: r['trade_date'] as String,
        recordedAt: r['recorded_at'] as String?,
      ),
  ];

  /// 등록된 계획의 계좌별 기록 금액(D8 앵커 — 계획 ↔ 결정 ↔ 현금 행 조인) · 등록 안 됐으면 빈 목록.
  List<DepositCashRow> registeredCash(String planId) => <DepositCashRow>[
    for (final Row r in _db.select(
      'SELECT c.flow_id, c.account_alias, c.amount FROM plan_snapshot p '
      'JOIN decision_log d ON d.decision_id = p.consumed_by_decision_id '
      "JOIN cash_flow c ON c.flow_id GLOB d.decision_id || '-*' AND c.kind = 'DEPOSIT' "
      'WHERE p.plan_id = ? ORDER BY c.flow_id',
      <Object>[planId],
    ))
      DepositCashRow.fromColumns(
        flowId: r['flow_id'] as String,
        accountAlias: r['account_alias'] as String?,
        amount: r['amount'] as num,
      ),
  ];
}
