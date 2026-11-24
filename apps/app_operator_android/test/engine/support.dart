// E11p3a 시험 받침 — 실 SQLite 원장(임시 폴더) · 가짜 시계 · 핑 기록기.

import 'dart:io';

import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        JobHeartbeat,
        Market,
        P0sOpsConfig,
        PingStatus,
        frozenExchangeCalendar,
        kstDateText;
import 'package:data_sync/data_sync.dart'
    show ModeAxis, SqliteConfigVersionStore, SqliteModeStore, openLocalLedger;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        DecisionReasonCodes,
        ExecPolicy,
        LedgerFile,
        OperatingMode,
        RunMode;
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart' show JobCalendars;

/// 고칠 수 있는 시계.
class FakeClock implements Clock {
  FakeClock(this.now);

  DateTime now;

  @override
  DateTime nowUtc() => now;
}

/// 보낸 핑.
class Ping {
  const Ping(this.check, this.status, this.note, this.rid);

  final String check;
  final PingStatus status;
  final String? note;
  final String? rid;
}

/// 핑을 적어 둔다.
class RecordingHeartbeat implements JobHeartbeat {
  final List<Ping> pings = <Ping>[];

  @override
  Future<void> ping(
    String check,
    PingStatus status, {
    String? note,
    String? rid,
  }) async => pings.add(Ping(check, status, note, rid));
}

/// 동결 달력.
JobCalendars calendars() => JobCalendars(
  kr: frozenExchangeCalendar(Market.kr),
  us: frozenExchangeCalendar(Market.us),
);

/// KST 시각 → UTC.
DateTime kst(int y, int m, int d, int h, int min) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(hours: 9));

/// 임시 원장 폴더(시험 끝에 지운다).
Directory tempLedgerDir() {
  final Directory d = Directory.systemTemp.createTempSync('aaq_e11p3a_');
  addTearDownDelete(d);
  return d;
}

final List<Directory> _toDelete = <Directory>[];

/// 지울 폴더로 적는다.
void addTearDownDelete(Directory d) => _toDelete.add(d);

/// 적어 둔 폴더를 지운다(`tearDownAll`).
void deleteTempDirs() {
  for (final Directory d in _toDelete) {
    try {
      d.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows 가 파일을 아직 잡고 있으면 남긴다(임시 폴더).
    }
  }
  _toDelete.clear();
}

/// 원장 열기(실물) — 시계를 넣는다.
LedgerFiles openFiles(Directory dir, Clock clock) =>
    LedgerFiles.open(dir.path, clock: clock);

/// sim 파일에 모드 행을 쓴다(온보딩 커밋의 모드 몫만).
void writeSimMode(Database sim, Clock clock, {OperatingMode? committed}) {
  final String? denied = SqliteModeStore(sim, LedgerFile.sim, clock: clock)
      .record(
        axis: ModeAxis.runMode,
        runMode: RunMode.simInternal,
        execPolicy: ExecPolicy.execute,
        operatingMode: committed ?? OperatingMode.autoTrade,
        handoverSessionValid: false,
        decisionId: 'D-SIM-OPEN',
      );
  if (denied != null) throw StateError(denied);
  if (committed != null) {
    sim.execute(
      'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
      <Object?>[
        committed.wire,
        clock.nowUtc().toIso8601String(),
        clock.nowUtc().toIso8601String(),
      ],
    );
  }
}

/// live 파일을 만들고 모드 행 · 운영 방식 전이를 쓴다(simToAuto 커밋의 live 몫만 흉내).
Database writeLiveMode(Directory dir, Clock clock) {
  final Database live = openLocalLedger(
    dir.path,
    RunMode.live,
    clock: () => clock.nowUtc(),
  );
  final String? denied = SqliteModeStore(live, LedgerFile.live, clock: clock)
      .record(
        axis: ModeAxis.runMode,
        runMode: RunMode.live,
        execPolicy: ExecPolicy.dryRun,
        operatingMode: OperatingMode.autoTrade,
        handoverSessionValid: true,
        decisionId: 'D-LIVE',
      );
  if (denied != null) throw StateError(denied);
  live.execute(
    'INSERT INTO operating_mode_transition (transition_id, handover_session_id, from_mode, to_mode, decision_id, committed_at) '
    "VALUES ('OT-1', 'HS-1', ?, ?, 'D-LIVE', ?)",
    <Object?>[
      OperatingMode.autoTrade.wire,
      OperatingMode.autoTrade.wire,
      clock.nowUtc().toIso8601String(),
    ],
  );
  return live;
}

/// 🆕 리뷰 3차 A-1(R265) — live 파일에 실전 개시 결정(`OPENING_BALANCE`) + 그 판(승인 1)을 쓴다(simToAuto 커밋이 쓰는 꼴 ·
/// [writeLiveMode] 와 함께 = 커밋의 live 몫 흉내) → 판 지문. 🔴 커밋 → 잡 끝까지 = `operator_handover_test` A-1(실물 커밋).
String writeLiveOpening(Database live, Clock clock, P0sOpsConfig config) {
  final String hash = SqliteConfigVersionStore(
    live,
    clock: clock,
  ).register(config.content());
  live.execute(
    'UPDATE config_versions SET approved = 1 WHERE config_hash = ?',
    <Object?>[hash],
  );
  final DateTime now = clock.nowUtc().toUtc();
  live.execute(
    'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
    "reason_code, config_hash) VALUES ('LIVEOPEN-TEST', ?, ?, 'LIVE', 'MANUAL', 'P0S', '실전 개시(시험)', ?, ?)",
    <Object?>[
      now.toIso8601String(),
      kstDateText(now),
      DecisionReasonCodes.openingBalance,
      hash,
    ],
  );
  return hash;
}
