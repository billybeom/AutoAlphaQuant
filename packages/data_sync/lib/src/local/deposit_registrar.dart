// M3-4 실입금 등록 — 한 트랜잭션 기록기(설계 13 §8 R22 D5·D6·D11 · 01 §20-3 · E7b2).
//
// 🔴 기록 = 한 트랜잭션(`BEGIN IMMEDIATE`): `decision_log`(DEPOSIT · `DEPOSIT_REGISTERED`) + 계좌별 `cash_flow` +
//    `UPDATE plan_snapshot SET consumed_by_decision_id = ? WHERE … IS NULL`(계획 하나에 등록 하나를 DB 가 강제) +
//    `command_inbox` 1행. 중간에 하나라도 실패하면 전부 되돌린다(부분 기록 0).
// 🔴 거부 = `command_inbox` 1행만(원장·바인딩 쓰기 0) · 보류(원장 무결성) = 쓰기 0 — 수송이 다시 건넨다.
// 🔴 같은 `command_id` 를 다시 받으면(수송 재전달) 새로 판정하지 않고 감사 기록의 결과를 돌려준다 — 같은 명령이
//    두 번 기록되지 않는다.
// 🔴 판정은 core_engine `judgeDepositRegistration`(순수) — 이 파일은 읽기·쓰기만 한다.
// 🔴 🆕 E7b3 한도 재검사(R22 D13) — 남은 한도 = 연 한도 − 연금 납입 누계(D7 · 같은 트랜잭션 안에서 원장을 읽는다 ·
//    처리 시점 KST 연도 · 시스템 밖 신고값은 트랜잭션 전에 포트에서). 상태 공급자의 `pensionUsedThisYear` 는 쓰지 않는다
//    — 등록 순간의 정본은 원장이다(두 등록이 같은 한도를 두 번 쓰지 못한다).
// 🔴 `decision_log.mode` = 연 파일의 [RunMode] — 잘못 연 파일이면 CHECK 가 즉시 실패한다(fail-closed).
// 🔵 수송 맥락(`run_mode`·`operating_mode`·`lease_epoch`)은 X7 명령에만 실린다 — 입금 등록은 NULL(01 §4-2).
// 🔵 주문(파킹 매수)·안내·`rebalance_event` 는 쓰지 않는다(R22 D11 — E10·E18).

import 'package:core_engine/core_engine.dart'
    show
        DepositCashRow,
        DepositLedgerEntry,
        DepositPlanSnapshot,
        DepositRegisterCommand,
        DepositRegisterExecuted,
        DepositRegisterHeld,
        DepositRegisterOutcome,
        DepositRegisterRejected,
        NoPensionDeclaration,
        PensionDeclarationSource,
        WhatIfConfig,
        WhatIfState,
        WhatIfStateSource,
        depositReceipt,
        judgeDepositRegistration,
        kstYear,
        pensionUsedInYear;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, CommandKind, CommandReceipt, CommandState, RunMode, TradeDate;
import 'package:sqlite3/sqlite3.dart';

import 'deposit_ledger.dart';
import 'plan_snapshot_store.dart';

/// 로컬 원장 파일 하나에 실입금 등록을 기록한다.
final class SqliteDepositRegistrar {
  SqliteDepositRegistrar(
    this._db, {
    required this.mode,
    required this.state,
    required this.clock,
    WhatIfConfig? config,
    this.declarations = const NoPensionDeclaration(),
  }) : config = config ?? WhatIfConfig.defaults,
       _plans = SqlitePlanSnapshotStore(_db),
       _ledger = SqliteDepositLedger(_db);

  final Database _db;
  final SqlitePlanSnapshotStore _plans;
  final SqliteDepositLedger _ledger;

  /// 연금 연 납입한도(`pensionAnnualLimit`).
  final WhatIfConfig config;

  /// 시스템 밖 연금 납입 신고값(D7 · 기본 0 — §8 미결 112).
  final PensionDeclarationSource declarations;

  /// 이 파일의 실행 모드(`decision_log.mode`).
  final RunMode mode;

  /// 등록 판정이 읽는 상태(플래그 · KR 달력).
  final WhatIfStateSource state;

  /// 엔진 시각(`created_at` · `recorded_at` · `ingested_at`).
  final Clock clock;

  /// [command] 를 판정하고 기록한다 — 접수증을 돌려준다. 인프라 실패(달력 없음 · DB 오류)는 `Future` 에러.
  Future<CommandReceipt> register(DepositRegisterCommand command) async {
    final WhatIfState s = await state.load();
    final DateTime nowUtc = clock.nowUtc().toUtc();
    final String now = nowUtc.toIso8601String();
    // 🆕 R260(리뷰 3차 F-5) — 연금 한도의 «그해» = 명령 요청 시각(신뢰 시각)의 KST 연도(기기 시계 연도 아님 · 만료 판정과 같은 축).
    final int year = kstYear(command.requestedAt);
    // 신고값(원) — 트랜잭션 전에 포트에서 읽는다(트랜잭션 안에서는 await 하지 않는다 · 금액 타입은 core 의 것).
    final declared = await declarations.declaredOutside(year);
    _db.execute('BEGIN IMMEDIATE');
    try {
      final CommandReceipt? replay = _replay(command);
      if (replay != null) {
        _db.execute('COMMIT');
        return replay;
      }
      final DepositPlanSnapshot? snapshot = _plans.readSnapshot(command.planId);
      final String? pensionAlias = snapshot?.inputs.pensionAlias;
      final DepositRegisterOutcome outcome = judgeDepositRegistration(
        command: command,
        snapshot: snapshot,
        state: s,
        // 🆕 R260(리뷰 3차 F-1) — 앱 안 모의 = 등록 순간 현금이 생긴다 → 이미 쓴 마감 평가 뒤로(실전 · 브로커 모의 = 옛 규칙).
        snapshotThrough: mode == RunMode.simInternal
            ? _snapshotThrough()
            : null,
        pensionRemaining: pensionAlias == null
            ? config.pensionAnnualLimit
            : config.pensionAnnualLimit -
                  pensionUsedInYear(
                    _ledger.cashRows(pensionAlias),
                    pensionAlias: pensionAlias,
                    year: year,
                    declaredOutside: declared,
                  ),
      );
      switch (outcome) {
        case DepositRegisterHeld():
          _db.execute('ROLLBACK');
          return depositReceipt(command, outcome);
        case DepositRegisterRejected():
          _inbox(command, outcome, now, decisionId: null);
        case DepositRegisterExecuted(:final DepositLedgerEntry entry):
          _decision(entry, now);
          for (final DepositCashRow r in entry.cash) {
            _cash(entry, r, now);
          }
          _bind(entry);
          _inbox(command, outcome, now, decisionId: entry.decisionId);
      }
      _db.execute('COMMIT');
      return depositReceipt(command, outcome);
    } catch (_) {
      if (!_db.autocommit) _db.execute('ROLLBACK');
      rethrow;
    }
  }

  /// 🆕 R260(리뷰 3차 F-1) — 이미 쓴 마감 평가(`equity_snapshot`)의 마지막 날(없으면 null).
  TradeDate? _snapshotThrough() {
    final Object? d = _db
        .select('SELECT MAX(trade_date) AS d FROM equity_snapshot')
        .first['d'];
    return d == null ? null : TradeDate(d as String);
  }

  /// 이미 받은 명령이면 그때의 결과.
  CommandReceipt? _replay(DepositRegisterCommand c) {
    final ResultSet rows = _db.select(
      'SELECT kind, state, state_label, reject_reason_code FROM command_inbox '
      'WHERE command_id = ?',
      <Object>[c.commandId],
    );
    if (rows.isEmpty) return null;
    final Row r = rows.single;
    if (r['kind'] != CommandKind.depositRegister.wire) {
      throw StateError('${c.commandId} — 다른 명령(${r['kind']})의 id 다');
    }
    return CommandReceipt(
      commandId: c.commandId,
      kind: CommandKind.depositRegister,
      state: CommandState.values.firstWhere(
        (CommandState v) => v.wire == r['state'],
      ),
      stateLabel: r['state_label'] as String,
      requestedAt: c.requestedAt,
      expiresAt: c.expiresAt,
      nonce: c.nonce,
      issuedByDeviceId: c.issuedByDeviceId,
      rejectReasonCode: r['reject_reason_code'] as String?,
    );
  }

  void _decision(DepositLedgerEntry e, String now) {
    _db.execute(
      'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, '
      'reason, reason_code, config_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object>[
        e.decisionId,
        now,
        e.tradeDate.yyyyMmDd,
        mode.wire,
        'DEPOSIT',
        e.strategyId,
        e.reason,
        e.reasonCode,
        e.configHash,
      ],
    );
  }

  void _cash(DepositLedgerEntry e, DepositCashRow r, String now) {
    _db.execute(
      'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, '
      "account_alias) VALUES (?, ?, ?, 'KRW', 'DEPOSIT', ?, ?, ?)",
      <Object?>[
        r.flowId,
        e.tradeDate.yyyyMmDd,
        r.amount.toDouble(),
        e.planId,
        now,
        r.accountAlias,
      ],
    );
  }

  void _bind(DepositLedgerEntry e) {
    _db.execute(
      'UPDATE plan_snapshot SET consumed_by_decision_id = ? '
      'WHERE plan_id = ? AND consumed_by_decision_id IS NULL',
      <Object>[e.decisionId, e.planId],
    );
    if (_db.updatedRows != 1) {
      throw StateError('${e.planId} — 바인딩 영향 행 ${_db.updatedRows}(1 이어야 한다)');
    }
  }

  void _inbox(
    DepositRegisterCommand c,
    DepositRegisterOutcome o,
    String now, {
    required String? decisionId,
  }) {
    _db.execute(
      'INSERT INTO command_inbox (command_id, kind, ingested_at, state, state_label, '
      'reject_reason_code, decision_id, payload_digest) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        c.commandId,
        CommandKind.depositRegister.wire,
        now,
        o.state.wire,
        o.stateLabel,
        switch (o) {
          DepositRegisterRejected(:final String code) => code,
          DepositRegisterExecuted() || DepositRegisterHeld() => null,
        },
        decisionId,
        c.payloadDigest,
      ],
    );
  }
}
