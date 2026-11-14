// simToAuto 2단 커밋 1단계 — 실전 파일 한 트랜잭션(02 :692 §2-7 v2.44 ⓑ · 06 :242 · 04 :401 ·
// 설계 13 §8 R93 AE1 f3 · R98 AG3~AG8).
//
// 🔴 실전 파일만(모의 파일 = [StateError] — `SqliteModeStore` 의 식별 검사).
// 🔴 게이트(신뢰 시각 · 세션 · 재판정 · 계좌 조회)를 트랜잭션 안에서 다시 본다 · 거부 = 쓰기 0 · 세션 그대로.
// 🔴 쓰기 = 개시 결정 → 계좌별 입금 → 전략 시딩 4 → 운영 방식 행 → RUN_MODE live × dryRun → 세션 COMMITTED →
//    `HANDOVER_COMMITTED` 알림 · 시각 = 신뢰 시각 하나 · 실패 = 전부 되돌린 뒤 세션 `ROLLED_BACK`(AG6).
// 🔴 두 파일을 한 트랜잭션에 묶지 않는다(01 :3388) — 모의 CLOSE · 지움 · 복구 = f3b(이 저장 뒤 · WAL 체크포인트 뒤).

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HandoverCloseCode,
        HandoverSessionRecord,
        LeaseSnapshot,
        LiveAccountProbe,
        LiveObservationConfig,
        P0sStrategyIds,
        SimToAutoCommitCodes,
        SimToAutoFacts,
        SimToAutoReport,
        TrustedClock,
        judgeSimToAuto,
        kHandoverCommitCheck,
        kLiveOpeningReason,
        kLiveOpeningSeedReason,
        kP0sSeedStrategies,
        kSeedCapitalCap,
        kSeedStrategyState,
        kstDateText,
        liveOpeningCash,
        liveOpeningDecisionId,
        simToAutoCommitHeadline,
        simToAutoCommitReject;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AlertCodes,
        Clock,
        DecisionReasonCodes,
        ExecPolicy,
        LedgerFile,
        OperatingMode,
        RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'alert_store.dart' show SqliteAlertSink;
import 'handover_session_store.dart' show SqliteHandoverSessionStore;
import 'mode_store.dart' show ModeAxis, SqliteModeStore;

class _At implements Clock {
  const _At(this._t);
  final DateTime _t;
  @override
  DateTime nowUtc() => _t;
}

SimToAutoFacts _at(SimToAutoFacts f, DateTime now, DateTime opened) =>
    SimToAutoFacts(
      trustedNowUtc: now,
      simRunMode: f.simRunMode,
      simClosed: f.simClosed,
      operatingMode: f.operatingMode,
      trial: f.trial,
      goldenVectorPassed: f.goldenVectorPassed,
      liveKeysVerified: f.liveKeysVerified,
      accountByStrategy: f.accountByStrategy,
      fate: f.fate,
      sessionOpenedAtUtc: opened,
      killSwitchActive: f.killSwitchActive,
      blockingFlags: f.blockingFlags,
    );

/// 1단계 결과.
class SimToAutoCommitOutcome {
  /// 성공.
  const SimToAutoCommitOutcome.ok(String this.decisionId, this.headline)
    : reasonCode = null;

  /// 거부 · 되돌림.
  const SimToAutoCommitOutcome.no(String this.reasonCode, this.headline)
    : decisionId = null;

  /// 거부 코드(성공 = null).
  final String? reasonCode;

  /// 실전 개시 결정 id(거부 = null).
  final String? decisionId;

  /// 엔진 문구(화면은 그대로 그린다).
  final String headline;

  /// 성공했나.
  bool get ok => reasonCode == null;
}

/// simToAuto 2단 커밋 1단계(R98).
class SqliteSimToAutoCommitStore {
  /// 저장을 만든다 — 🔴 [db] 가 실전 파일이 아니면 [StateError].
  ///
  /// `clock` = 되돌림 뒤 세션 닫는 시각(신뢰 시각이 없을 때) · `trusted` = 게이트 · 모든 쓰기 시각.
  SqliteSimToAutoCommitStore(
    this._db, {
    required this._clock,
    required this._trusted,
  }) : _sessions = SqliteHandoverSessionStore(
         _db,
         clock: _clock,
         trusted: _trusted,
       );

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;
  final SqliteHandoverSessionStore _sessions;

  /// 🔴 실전 개시 1단계 — [simFacts] = 모의 파일 · 포트 · 설정에서 모은 판정 입력(시각 · 세션 칸은 버린다) ·
  /// [probes] = 대응 계좌의 브로커 잔고 조회(5분 안) · [configHash] = 지금 설정의 해시 ·
  /// 🆕 E15f4a [lease] = 운영 중인 파일의 리스 스냅숏(트랜잭션 앞에서 잡는다 · R103 AI3).
  SimToAutoCommitOutcome commit({
    required String sessionId,
    required SimToAutoFacts simFacts,
    required ExchangeCalendar kr,
    required LiveObservationConfig observation,
    required List<LiveAccountProbe> probes,
    required String configHash,
    required LeaseSnapshot lease,
  }) {
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    // 빈 별칭은 재판정 S4(`SIM_TO_AUTO_ACCOUNT_UNMAPPED`)가 먼저 막는다.
    final Set<String> aliases = simFacts.accountByStrategy.values.toSet();
    String? code;
    String? id;
    Map<String, int> cash = const <String, int>{};
    try {
      inLedgerTransaction(_db, () {
        final HandoverSessionRecord? s = _sessions.session(sessionId);
        final int rows =
            _db.select('SELECT COUNT(*) AS n FROM mode_transition').first['n']!
                as int;
        final SimToAutoReport? report = now == null || s == null
            ? null
            : judgeSimToAuto(
                _at(simFacts, now, s.openedAtUtc),
                kr: kr,
                observation: observation,
              );
        code = simToAutoCommitReject(
          trustedNowUtc: now,
          session: s,
          lease: lease,
          liveModeRows: rows,
          report: report,
          aliases: aliases,
          probes: probes,
        );
        if (code != null) return;
        final DateTime at = now!;
        final String d = liveOpeningDecisionId(at);
        final String iso = at.toIso8601String();
        final String day = kstDateText(at);
        cash = liveOpeningCash(probes, aliases);
        _db.execute(
          'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, '
          'reason, reason_code, config_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            d,
            iso,
            day,
            RunMode.live.wire,
            'MANUAL',
            P0sStrategyIds.deposit,
            kLiveOpeningReason,
            DecisionReasonCodes.openingBalance,
            configHash,
          ],
        );
        for (final MapEntry<String, int> e in cash.entries) {
          _db.execute(
            'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, '
            "account_alias) VALUES (?, ?, ?, 'KRW', 'DEPOSIT', ?, ?, ?)",
            <Object?>[
              '$d-${e.key}',
              day,
              e.value.toDouble(),
              DecisionReasonCodes.openingBalance,
              iso,
              e.key,
            ],
          );
        }
        for (final String st in kP0sSeedStrategies) {
          _db.execute(
            'INSERT INTO strategy_state_current (strategy_id, state, since, capital_cap) VALUES (?, ?, ?, ?)',
            <Object?>[st, kSeedStrategyState, day, kSeedCapitalCap],
          );
          _db.execute(
            'INSERT INTO strategy_state_log (log_id, strategy_id, changed_at, from_state, to_state, reason) '
            'VALUES (?, ?, ?, NULL, ?, ?)',
            <Object?>[
              '$d-$st',
              st,
              iso,
              kSeedStrategyState,
              kLiveOpeningSeedReason,
            ],
          );
        }
        _db.execute(
          'INSERT INTO operating_mode_transition (transition_id, handover_session_id, from_mode, to_mode, '
          'decision_id, committed_at) VALUES (?, ?, ?, ?, ?, ?)',
          <Object?>[
            '$d-OM',
            sessionId,
            OperatingMode.autoTrade.wire,
            OperatingMode.autoTrade.wire,
            d,
            iso,
          ],
        );
        final String? denied =
            SqliteModeStore(
              _db,
              LedgerFile.live,
              clock: _At(at),
            ).recordInTransaction(
              axis: ModeAxis.runMode,
              runMode: RunMode.live,
              execPolicy: ExecPolicy.dryRun,
              operatingMode: OperatingMode.autoTrade,
              handoverSessionValid: false,
              decisionId: d,
              handoverSessionId: sessionId,
            );
        if (denied != null) throw StateError('실전 개시 조합 거부: $denied');
        _sessions.closeInTransaction(
          sessionId,
          HandoverCloseCode.committed,
          atUtc: at,
        );
        SqliteAlertSink(_db, clock: _At(at)).emitInTransaction(
          kHandoverCommitCheck,
          const <String>{AlertCodes.handoverCommitted},
        );
        id = d;
      });
    } on SqliteException {
      return _rollBack(sessionId, now);
    } on StateError {
      return _rollBack(sessionId, now);
    }
    final String? c = code;
    if (c != null) {
      return SimToAutoCommitOutcome.no(c, simToAutoCommitHeadline(c));
    }
    // 🔴 AG7 — 실전 커밋을 본 파일에 내려 둔 뒤에야 모의 파일을 건드린다(f3b).
    _db.select('PRAGMA wal_checkpoint(FULL)');
    return SimToAutoCommitOutcome.ok(
      id!,
      simToAutoCommitHeadline(null, cash: cash),
    );
  }

  SimToAutoCommitOutcome _rollBack(String sessionId, DateTime? now) {
    try {
      inLedgerTransaction(_db, () {
        final HandoverSessionRecord? s = _sessions.session(sessionId);
        if (s == null || s.closed) return;
        _sessions.closeInTransaction(
          sessionId,
          HandoverCloseCode.rolledBack,
          atUtc: now ?? _clock.nowUtc().toUtc(),
        );
      });
    } on SqliteException {
      // 세션 닫기도 실패 — 열린 채 두고 만료 정리가 닫는다.
    }
    return SimToAutoCommitOutcome.no(
      SimToAutoCommitCodes.rolledBack,
      simToAutoCommitHeadline(SimToAutoCommitCodes.rolledBack),
    );
  }
}
