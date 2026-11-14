// simToAuto 2단 커밋 2단계 · 기동 복구 — 모의 CLOSE · 고름대로 처리 · 닫힌 모의 파일 지우기
// (04 :401 · 01 :3388 · :3397 · 설계 13 §8 R98 AG1 f3b · R100 AH1~AH7).
//
// 🔴 두 파일을 한 트랜잭션에 묶지 않는다 — 실전 커밋(1단계 · WAL 체크포인트 뒤)을 먼저 읽고 모의 파일을 따로 쓴다.
// 🔴 «커밋 직후»와 «기동 복구»가 같은 함수 — 반쯤 끝난 자리에서 다시 불러도 같은 끝에 닿는다(멱등).
// 🔴 지우기는 연결을 닫은 뒤 부르는 쪽이 — 이 함수가 스스로 다시 열어 닫힘 ∧ 고름 지움을 확인한 뒤에만 지운다.
//    실전 파일은 이 길로 지울 수 없다.

import 'dart:io' show File, FileSystemException;

import 'package:core_engine/core_engine.dart'
    show
        ModeRowFacts,
        SimLedgerDeleteResult,
        SimLedgerFate,
        SimLedgerFinish,
        SimLedgerFinishPlan,
        simLedgerFinishOf;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, LedgerFile, RunMode;
import 'package:sqlite3/sqlite3.dart';

import 'ledger_schema.dart' show openLocalLedger;
import 'mode_store.dart' show SqliteModeStore;
import 'sim_ledger_fate_store.dart' show SqliteSimLedgerFateStore;

/// 2단계 결과.
class SimToAutoFinishResult {
  /// 결과를 만든다.
  const SimToAutoFinishResult({
    required this.closeWritten,
    required this.finish,
  });

  /// 이번에 모의 CLOSE 를 썼나.
  final bool closeWritten;

  /// 처리.
  final SimLedgerFinish finish;

  /// 부르는 쪽이 연결을 닫고 [deleteClosedSimLedger] 를 불러야 하나.
  bool get deleteSimFile => finish == SimLedgerFinish.discard;
}

/// 🔴 2단계 · 기동 복구(AH1) — [simDb] = 모의 파일 연결(없으면 null) · 실전 커밋이 없으면 아무것도 쓰지 않는다.
SimToAutoFinishResult finishSimToAuto({
  required Database liveDb,
  required Database? simDb,
  required Clock clock,
}) {
  final ModeRowFacts? live = SqliteModeStore(
    liveDb,
    LedgerFile.live,
    clock: clock,
  ).current();
  final bool liveCommitted = live != null && live.runMode == RunMode.live;
  if (simDb == null) {
    return const SimToAutoFinishResult(
      closeWritten: false,
      finish: SimLedgerFinish.none,
    );
  }
  final SqliteModeStore sim = SqliteModeStore(
    simDb,
    LedgerFile.sim,
    clock: clock,
  );
  final bool closed = sim.closed();
  final SimLedgerFinishPlan plan = simLedgerFinishOf(
    liveCommitted: liveCommitted,
    simHasRows: closed || sim.current() != null,
    simClosed: closed,
    fate: SqliteSimLedgerFateStore(simDb, clock: clock).current(),
  );
  if (plan.closeSim) sim.close(decisionId: live!.decisionId);
  return SimToAutoFinishResult(
    closeWritten: plan.closeSim,
    finish: plan.finish,
  );
}

/// 🔴 닫힌 모의 파일 지우기(AH2) — [directory] 의 모의 파일을 스스로 다시 열어 닫힘 ∧ 고름 지움일 때만
/// 본체 · `-wal` · `-shm` 을 지운다. 부르기 전에 그 파일의 연결을 모두 닫아야 한다.
SimLedgerDeleteResult deleteClosedSimLedger(
  String directory, {
  required Clock clock,
}) {
  final String path = '$directory/${LedgerFile.sim.fileName}';
  if (!File(path).existsSync()) return SimLedgerDeleteResult.missing;
  final Database db = openLocalLedger(
    directory,
    RunMode.simInternal,
    clock: () => clock.nowUtc(),
  );
  final SimLedgerDeleteResult? refuse;
  try {
    refuse = !SqliteModeStore(db, LedgerFile.sim, clock: clock).closed()
        ? SimLedgerDeleteResult.notClosed
        : SqliteSimLedgerFateStore(db, clock: clock).current() !=
              SimLedgerFate.discard
        ? SimLedgerDeleteResult.notDiscard
        : null;
  } finally {
    db.close();
  }
  if (refuse != null) return refuse;
  try {
    for (final String suffix in const <String>['', '-wal', '-shm']) {
      final File f = File('$path$suffix');
      if (f.existsSync()) f.deleteSync();
    }
  } on FileSystemException {
    return SimLedgerDeleteResult.deleteFailed;
  }
  return SimLedgerDeleteResult.deleted;
}
