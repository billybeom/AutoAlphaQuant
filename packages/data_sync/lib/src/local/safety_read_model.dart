// 안전 상태 읽기 operator 판 — `SafetyRepository.watchState`(앱 계약 01 §2-10 · 설계 13 §8 R62 U1~U9).
//
// 🔴 글자 · 차례 · 게이지 = core `safety_text.dart` · 여기는 SQL 로 재료만 모은다.
// 🔴 브레이커 = 최근 스냅숏(주문 경로 1.5 와 같은 원천) · 자격 · 유지 봉 · bull = 저장 역사를 지금 다시 재생(E13d2).
// 🔴 갱신 = 같은 연결 `db.updates`(E13c2 `watchLedgerQuery`) · 시간만 흐를 때의 다시 냄 = 조립 앱의 주기 신호(이 판 밖).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../jobs/daily_jobs.dart' show SqliteEquitySnapshotStore, regimeLookupOf;
import 'kill_switch_store.dart' show readKillSwitchRecord;
import 'ledger_read_model.dart' show watchLedgerQuery;

/// `SafetyRepository` operator 판(R62 U1).
class SqliteSafetyRepository implements SafetyRepository {
  /// 저장소를 만든다 — [mode] = 이 원장 파일의 실행 모드.
  SqliteSafetyRepository(
    this._db, {
    required this._mode,
    required this._clock,
    required this._trusted,
    this._config,
  });

  final Database _db;
  final RunMode _mode;
  final Clock _clock;
  final TrustedClock _trusted;
  final BreakerConfig? _config;

  /// 다시 낼 표(R62 U9).
  static const Set<String> watchedTables = <String>{
    'trading_block',
    'kill_switch_state',
    'equity_snapshot',
    'ramp_state',
    'breaker_release',
    'reconciliation_log',
    'decision_journal',
  };

  /// 지금 값.
  SafetyState state() {
    final List<EquitySnapshotRow> rows = SqliteEquitySnapshotStore(
      _db,
      mode: _mode,
    ).before('9999-12-31');
    final EquitySnapshotRow? last = rows.isEmpty ? null : rows.last;
    final BreakerLevel level = last?.breakerLevel ?? BreakerLevel.normal;
    final double dd = last?.drawdown ?? 0;
    final BreakerReplay replay = replayStoredBreaker(
      rows,
      regimeLookupOf(_db),
      releaseDates: <String>[
        for (final Row r in _db.select(
          'SELECT trade_date FROM breaker_release ORDER BY trade_date',
        ))
          r['trade_date'] as String,
      ],
      config: _config,
    );
    final ResultSet draft = _db.select(
      'SELECT journal_id FROM decision_journal WHERE is_deviation = 1 AND '
      '(rationale_before IS NULL OR expected_outcome IS NULL OR rule_cited IS NULL) '
      'ORDER BY created_at, journal_id LIMIT 1',
    );
    final ResultSet ok = _db.select(
      "SELECT run_at FROM reconciliation_log WHERE action_taken = 'INTEGRITY_OK' "
      'ORDER BY run_at DESC LIMIT 1',
    );
    final List<BlockFlag> flags = blockFlagsOf(
      <StoredBlockFlag>[
        for (final Row r in _db.select(
          'SELECT flag_id, set_at, origin_code FROM trading_block WHERE cleared_at IS NULL',
        ))
          StoredBlockFlag(
            r['flag_id'] as String,
            DateTime.parse(r['set_at'] as String).toUtc(),
            originCode: r['origin_code'] as String?,
          ),
      ],
      journalDraftId: draft.isEmpty
          ? null
          : draft.first['journal_id'] as String,
      lastIntegrityOkUtc: ok.isEmpty
          ? null
          : DateTime.parse(ok.first['run_at'] as String).toUtc(),
    );
    final KillSwitchRecord ks = readKillSwitchRecord(_db);
    final DateTime? trusted = _trusted.trustedNowUtc();
    final ResultSet ramp = _db.select(
      'SELECT level FROM ramp_state WHERE id = 1',
    );
    return safetyStateOf(
      level: level,
      drawdown: dd,
      flags: flags,
      killSwitch: killSwitchViewOf(ks, trusted),
      stoppedReleaseEligible: replay.stoppedReleaseEligible,
      releaseProgress: releaseProgressOf(
        level: level,
        drawdown: dd,
        replay: replay,
        killSwitch: ks,
        trustedNowUtc: trusted,
        config: _config,
      ),
      rampLevel: rampLevelOf(ramp.isEmpty ? null : ramp.first['level'] as int),
      mode: _mode,
      asOf: safetyAsOf(
        lastSnapshotDate: last?.tradeDate,
        nowUtc: _clock.nowUtc(),
      ),
    );
  }

  @override
  Stream<SafetyState> watchState() =>
      watchLedgerQuery(_db, watchedTables, state);
}
