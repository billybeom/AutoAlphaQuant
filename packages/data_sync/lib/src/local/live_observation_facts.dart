// M1-22 관찰 판정 입력 — 실전 파일의 원 기록 읽기(설계 13 §8 R89 AC2~AC5 · core `judgeLiveObservation`).
//
// 🔴 실전 파일만(모의 파일 = [StateError] — `SqliteModeStore` 의 식별 검사).
// 🔴 읽기만 · 판정은 core 하나 · 시각은 파싱해서 비교(ISO 글자 비교 금지).
// 🔴 현재 행 = `SqliteModeStore.current` 와 같은 차례(committed_at · transition_id 내림 · CLOSE 제외).

import 'package:core_engine/core_engine.dart'
    show
        JobRunEntry,
        LiveObservationFacts,
        LiveObservationFactsSource,
        LiveObservationRecon,
        LiveObservationRun,
        kLiveObservationBatchCheck,
        killSwitchActive;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, ExecPolicy, FlagIds, LedgerFile, RunMode;
import 'package:sqlite3/sqlite3.dart';

import 'job_run_store.dart' show SqliteJobRunLog;
import 'kill_switch_store.dart' show readKillSwitchRecord;
import 'mode_store.dart' show SqliteModeStore;

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _at(Object? v, String table) {
  if (v is! String || !_offset.hasMatch(v)) {
    throw FormatException('$table 시각에 시차가 없다', v);
  }
  return DateTime.parse(v).toUtc();
}

/// M1-22 관찰 판정 입력(R89).
class SqliteLiveObservationFacts implements LiveObservationFactsSource {
  /// 입력을 만든다 — 🔴 [db] 가 실전 파일이 아니면 [StateError].
  SqliteLiveObservationFacts(this._db, {required Clock clock})
    : _clock = clock {
    SqliteModeStore(_db, LedgerFile.live, clock: clock);
  }

  final Database _db;
  final Clock _clock;

  /// 지금 읽은 입력(동기).
  LiveObservationFacts read() {
    final ResultSet cur = _db.select(
      "SELECT mode, exec_policy, committed_at FROM mode_transition WHERE axis <> 'CLOSE' "
      'ORDER BY committed_at DESC, transition_id DESC LIMIT 1',
    );
    final Row? c = cur.isEmpty ? null : cur.first;
    return LiveObservationFacts(
      asOfUtc: _clock.nowUtc().toUtc(),
      runMode: c == null
          ? null
          : RunMode.values.firstWhere((RunMode m) => m.wire == c['mode']),
      execPolicy: c == null
          ? null
          : ExecPolicy.values.firstWhere(
              (ExecPolicy e) => e.wire == c['exec_policy'],
            ),
      currentSinceUtc: c == null
          ? null
          : _at(c['committed_at'], 'mode_transition'),
      runs: <LiveObservationRun>[
        for (final JobRunEntry e in SqliteJobRunLog(_db).entriesOf('kr_order'))
          if (e.checkName == kLiveObservationBatchCheck)
            LiveObservationRun(
              e.sessionDay.yyyyMmDd,
              e.startedAtUtc,
              succeeded: e.status.succeeded,
            ),
      ],
      recons: <LiveObservationRecon>[
        for (final Row r in _db.select(
          'SELECT run_at, matched FROM reconciliation_log '
          "WHERE recon_id GLOB 'rc-*' AND recon_id NOT GLOB 'rc-clear-*'",
        ))
          LiveObservationRecon(
            _at(r['run_at'], 'reconciliation_log'),
            matched: r['matched'] == 1,
          ),
      ],
      unknownOrders:
          _db
                  .select(
                    "SELECT COUNT(*) AS n FROM order_intents WHERE status = 'UNKNOWN'",
                  )
                  .first['n']!
              as int,
      killSwitchActive: killSwitchActive(readKillSwitchRecord(_db)),
      blockingFlags: <String>[
        for (final Row r in _db.select(
          'SELECT flag_id FROM trading_block WHERE flag_id <> ? ORDER BY flag_id',
          <Object?>[FlagIds.dstWeek],
        ))
          r['flag_id'] as String,
      ],
    );
  }

  @override
  Future<LiveObservationFacts> facts() async => read();
}
