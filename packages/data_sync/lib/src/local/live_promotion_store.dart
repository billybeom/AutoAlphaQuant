// M1-22 승격 커밋 쓰기 — live × autoTrade × dryRun → execute(02 §2-6 · 01 §10-2 G-43 · 설계 13 §8 R91 AD1~AD6).
//
// 🔴 실전 파일만(모의 파일 = [StateError] — `SqliteModeStore` 의 식별 검사).
// 🔴 한 트랜잭션 = 관찰 재판정 + 사전 판정(core `livePromotionReject`) + `decision_log` MANUAL + `mode_transition`
//    EXEC_POLICY · 실패 = 전부 되돌림(`LIVE_PROMOTION_ROLLED_BACK`).
// 🔴 생체는 엔진 밖(호출자 증명) · 자동 승격 0 · 알림 0(AD6) · 세션 닫기는 세션 주인(E15f).

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        LiveObservationConfig,
        LiveObservationFacts,
        LiveObservationReport,
        LivePromotionCodes,
        P0sStrategyIds,
        judgeLiveObservation,
        kLivePromotionReason,
        kLivePromotionReasonCode,
        kstDateText,
        livePromotionDecisionId,
        livePromotionHeadline,
        livePromotionReject;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, ExecPolicy, LedgerFile, OperatingMode, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'live_observation_facts.dart' show SqliteLiveObservationFacts;
import 'mode_store.dart' show ModeAxis, SqliteModeStore;

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

/// 승격 결과.
class LivePromotionOutcome {
  /// 성공.
  const LivePromotionOutcome.ok(String this.decisionId, this.headline)
    : reasonCode = null;

  /// 거부 · 되돌림(아무것도 쓰지 않았다).
  const LivePromotionOutcome.no(String this.reasonCode, this.headline)
    : decisionId = null;

  /// 거부 코드(성공 = null).
  final String? reasonCode;

  /// 승격 결정 id(거부 = null).
  final String? decisionId;

  /// 엔진 문구(화면은 그대로 그린다).
  final String headline;

  /// 성공했나.
  bool get ok => reasonCode == null;
}

/// M1-22 승격 커밋(R91).
class SqliteLivePromotionStore {
  /// 저장을 만든다 — 🔴 [db] 가 실전 파일이 아니면 [StateError].
  SqliteLivePromotionStore(this._db, {required Clock clock})
    : _clock = clock,
      _mode = SqliteModeStore(_db, LedgerFile.live, clock: clock),
      _facts = SqliteLiveObservationFacts(_db, clock: clock);

  final Database _db;
  final Clock _clock;
  final SqliteModeStore _mode;
  final SqliteLiveObservationFacts _facts;

  /// [id] 세션이 열림 ∧ 만료 전인가(시차 없는 시각 = [FormatException]).
  bool _sessionValid(String id, DateTime nowUtc) {
    final ResultSet rs = _db.select(
      'SELECT expires_at, closed_at FROM handover_session WHERE handover_session_id = ?',
      <Object?>[id],
    );
    if (rs.isEmpty || rs.first['closed_at'] != null) return false;
    final Object? v = rs.first['expires_at'];
    if (v is! String || !_offset.hasMatch(v)) {
      throw FormatException('handover_session 시각에 시차가 없다', v);
    }
    return nowUtc.isBefore(DateTime.parse(v).toUtc());
  }

  /// 🔴 승격(AD4 · AD5) — [biometricConfirmed] = 호출자(M5 게이트 대화상자)의 생체 1회 증명.
  LivePromotionOutcome promote({
    required bool biometricConfirmed,
    required String configHash,
    required ExchangeCalendar kr,
    required LiveObservationConfig config,
    String? handoverSessionId,
  }) {
    String? code;
    String? decisionId;
    LiveObservationReport? report;
    try {
      inLedgerTransaction(_db, () {
        final DateTime now = _clock.nowUtc().toUtc();
        final LiveObservationFacts f = _facts.read();
        final LiveObservationReport r = judgeLiveObservation(
          f,
          kr: kr,
          config: config,
        );
        report = r;
        code = livePromotionReject(
          biometricConfirmed: biometricConfirmed,
          sessionValid: handoverSessionId == null
              ? null
              : _sessionValid(handoverSessionId, now),
          runMode: f.runMode,
          execPolicy: f.execPolicy,
          operatingMode: _mode.operatingMode(),
          currentSinceUtc: f.currentSinceUtc,
          nowUtc: now,
          report: r,
        );
        if (code != null) return;
        final String id = livePromotionDecisionId(now);
        _db.execute(
          'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, '
          'reason, reason_code, config_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            id,
            now.toIso8601String(),
            kstDateText(now),
            RunMode.live.wire,
            'MANUAL',
            P0sStrategyIds.deposit,
            kLivePromotionReason,
            kLivePromotionReasonCode,
            configHash,
          ],
        );
        final String? denied = _mode.recordInTransaction(
          axis: ModeAxis.execPolicy,
          runMode: RunMode.live,
          execPolicy: ExecPolicy.execute,
          operatingMode: OperatingMode.autoTrade,
          handoverSessionValid: false,
          decisionId: id,
          handoverSessionId: handoverSessionId,
        );
        if (denied != null) throw StateError('승격 조합 거부: $denied');
        decisionId = id;
      });
    } on SqliteException {
      return LivePromotionOutcome.no(
        LivePromotionCodes.rolledBack,
        livePromotionHeadline(LivePromotionCodes.rolledBack),
      );
    } on StateError {
      return LivePromotionOutcome.no(
        LivePromotionCodes.rolledBack,
        livePromotionHeadline(LivePromotionCodes.rolledBack),
      );
    }
    final String? c = code;
    if (c != null) {
      return LivePromotionOutcome.no(
        c,
        livePromotionHeadline(c, report: report),
      );
    }
    return LivePromotionOutcome.ok(decisionId!, livePromotionHeadline(null));
  }
}
