// simToAuto 5단계 «모의 기록 보관 · 지움» 고름 저장(앱 05 :510 S5 · 01 :3397 · 설계 13 §8 R98 AG2).
//
// 🔴 모의 파일만(실전 파일 = [StateError] — `SqliteModeStore` 의 식별 검사).
// 🔴 append-only — `decision_log` MANUAL `SIM_LEDGER_KEEP` · `SIM_LEDGER_DISCARD` · 가장 늦은 행이 이긴다.
//    냉각 24h 동안 앱을 다시 켜도 고름이 남고, 2단계(f3b)가 이 값을 읽어 지움을 마저 한다.
// 🔴 닫힌 모의 파일 = 거부(커밋 뒤에는 고를 수 없다) · 스키마 0줄.
// 🆕 리뷰 3차 H2-02(미결 231 ⓑ · 설계 13 §8 R265) — 결정의 설정 지문 = 이 트랜잭션 안에서 읽은 모의 파일의 지금 설정
//    (`currentP0sOpsConfig(sim, 지금 모의 모드)` · 호출자가 넘기지 않는다) · 못 읽음 = `SIM_LEDGER_FATE_CONFIG_UNAVAILABLE`(쓰기 0).

import 'package:core_engine/core_engine.dart'
    show
        ModeRowFacts,
        P0sStrategyIds,
        SimLedgerFate,
        SimToAutoCodes,
        SimToAutoCommitCodes,
        kstDateText,
        simLedgerFateDecisionId,
        simLedgerFateOfReasonCode,
        simLedgerFateReasonCode;
import 'package:domain_contracts/domain_contracts.dart' show Clock, LedgerFile;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'mode_store.dart' show SqliteModeStore;
import 'ops_config_source.dart'
    show OpsConfigRead, OpsConfigReady, currentP0sOpsConfig;

/// S5 고름 저장(R98 AG2).
class SqliteSimLedgerFateStore {
  /// 저장을 만든다 — 🔴 [db] 가 모의 파일이 아니면 [StateError].
  SqliteSimLedgerFateStore(this._db, {required this._clock})
    : _mode = SqliteModeStore(_db, LedgerFile.sim, clock: _clock);

  final Database _db;
  final Clock _clock;
  final SqliteModeStore _mode;

  /// 지금 고름(없음 = null) — 가장 늦은 행.
  SimLedgerFate? current() {
    for (final Row r in _db.select(
      "SELECT reason_code FROM decision_log WHERE kind = 'MANUAL' AND reason_code IN (?, ?) "
      'ORDER BY created_at DESC, decision_id DESC',
      <Object?>[
        simLedgerFateReasonCode(SimLedgerFate.keep),
        simLedgerFateReasonCode(SimLedgerFate.discard),
      ],
    )) {
      return simLedgerFateOfReasonCode(r['reason_code'] as String);
    }
    return null;
  }

  /// 고른다 — 성공 = null · 닫힌 모의 파일 = `SIM_LEDGER_FATE_SIM_CLOSED` · 모의 모드 행 없음 = `SIM_TO_AUTO_NOT_SIM_AUTO` ·
  /// 🆕 R265 지금 설정 못 읽음 = `SIM_LEDGER_FATE_CONFIG_UNAVAILABLE`(쓰기 0).
  String? choose(SimLedgerFate fate) => inLedgerTransaction(_db, () {
    if (_mode.closed()) return SimToAutoCommitCodes.simClosed;
    final ModeRowFacts? c = _mode.current();
    if (c == null) return SimToAutoCodes.notSimAuto;
    final OpsConfigRead cfg = currentP0sOpsConfig(_db, c.runMode);
    if (cfg is! OpsConfigReady) {
      return SimToAutoCommitCodes.fateConfigUnavailable;
    }
    final DateTime now = _clock.nowUtc().toUtc();
    final int seq =
        (_db.select(
              'SELECT COUNT(*) AS n FROM decision_log WHERE reason_code IN (?, ?)',
              <Object?>[
                simLedgerFateReasonCode(SimLedgerFate.keep),
                simLedgerFateReasonCode(SimLedgerFate.discard),
              ],
            ).first['n']!
            as int) +
        1;
    _db.execute(
      'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, '
      'reason, reason_code, config_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        simLedgerFateDecisionId(now, seq),
        now.toIso8601String(),
        kstDateText(now),
        c.runMode.wire,
        'MANUAL',
        P0sStrategyIds.deposit,
        fate == SimLedgerFate.keep
            ? '모의 기록 처리 — 앱 밖 보관본으로 남김'
            : '모의 기록 처리 — 실전 전환 뒤 지움',
        simLedgerFateReasonCode(fate),
        cfg.configHash,
      ],
    );
    return null;
  });
}
