// X1-4 새 폰 복구 저널(설계 13 §8 R137 N2~N4 · N9 · N11 · SPEC v2.45 04 §3-1 ③ · 앱 06 X1-4).
//
// 🔴 같은 `migration_run` · `migration_step`(role NEW_DEVICE) · append-only · 단계 = core `RecoveryStep`.
// 🔴 시작 = core 차례(live → 안내 모드 → 결정 → 신뢰 시각) → epoch 이 매니페스트보다 커야 → 이 파일에 이 기기 복구가
//    이미 있으면 거부(복원은 파일을 바꿔 끼우므로 다시 복원하면 저널도 새로 시작한다) · 한 트랜잭션에 run + RESTORED.
// 🔴 RESTORED detail = 매니페스트 정규 글자 그대로(다시 읽어 `BackupManifest.parse`) · 검증(E16g2)은 부르는 쪽(E16t).
// 🔴 복구 시각 = RESTORED 행 시각(고정) · 백업 갭 = core `backupGapDaysOf`(매니페스트 날 · 복구 시각).
// 🔴 「마지막 복구」 = 이 기기 · NEW_DEVICE · 시작 시각 · rowid 차례.

import 'dart:convert' show jsonEncode;

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show LedgerFile, OperatingMode, RunMode, X1RecoveryResultCodes;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'migration_journal_store.dart' show MigrationStoreCodes;

/// 복구 거부 코드(글자 = 계약 `X1RecoveryResultCodes` 참조 · 미결 212).
abstract final class RecoveryCodes {
  /// 복원(RESTORED) 기록이 없다.
  static const String notRestored = X1RecoveryResultCodes.notRestored;

  /// 새 epoch 이 매니페스트 epoch 보다 크지 않다.
  static const String epochNotAdvanced = X1RecoveryResultCodes.epochNotAdvanced;
}

/// 복구 한 판(이 기기의 마지막 복구).
class RecoveryRun {
  /// 만든다.
  const RecoveryRun({
    required this.runId,
    required this.kind,
    required this.operatorEpoch,
    required this.decisionId,
    required this.manifest,
    required this.restoredAtUtc,
    required this.gapRebuiltAtUtc,
  });

  /// 이전 id.
  final String runId;

  /// 갈래.
  final MigrationKind kind;

  /// 새 epoch.
  final int operatorEpoch;

  /// 결정(계획 = 확인 결정 · 비상 = 선언 결정).
  final String? decisionId;

  /// 복원한 스냅숏의 매니페스트.
  final BackupManifest manifest;

  /// 🔴 복구 시각(RESTORED 행 시각 · 고정).
  final DateTime restoredAtUtc;

  /// 갭 재구성 끝 시각(아직 = null).
  final DateTime? gapRebuiltAtUtc;

  /// 갭 재구성이 끝났나.
  bool get gapRebuilt => gapRebuiltAtUtc != null;

  /// 🔴 백업 갭(달력일) — 매니페스트 날 ~ 복구 날.
  int get backupGapDays => backupGapDaysOf(
    backupAuthoredDate: manifest.authoredDate,
    recoveryAtUtc: restoredAtUtc,
  );
}

/// 🔴 이 기기의 마지막 복구(없으면 null) — RESTORED 없는 복구 = 깨진 저널([StateError]).
RecoveryRun? latestRecoveryOf(Database db, String deviceId) {
  final ResultSet run = db.select(
    'SELECT run_id, kind, operator_epoch, decision_id FROM migration_run '
    "WHERE device_id = ? AND role = 'NEW_DEVICE' "
    'ORDER BY started_at DESC, rowid DESC LIMIT 1',
    <Object?>[deviceId],
  );
  if (run.isEmpty) return null;
  final Row r = run.single;
  final String id = r['run_id'] as String;
  final Map<String, Row> done = <String, Row>{
    for (final Row s in db.select(
      "SELECT step, detail_json, at FROM migration_step WHERE run_id = ? AND state = 'DONE'",
      <Object?>[id],
    ))
      s['step'] as String: s,
  };
  final Row? restored = done[RecoveryStep.restored.wire];
  if (restored == null) throw StateError('복구 $id 에 RESTORED 가 없다');
  final Row? rebuilt = done[RecoveryStep.gapRebuilt.wire];
  return RecoveryRun(
    runId: id,
    kind: MigrationKind.values.firstWhere(
      (MigrationKind k) => k.wire == r['kind'],
    ),
    operatorEpoch: r['operator_epoch'] as int,
    decisionId: r['decision_id'] as String?,
    manifest: BackupManifest.parse(restored['detail_json'] as String),
    restoredAtUtc: DateTime.parse(restored['at'] as String).toUtc(),
    gapRebuiltAtUtc: rebuilt == null
        ? null
        : DateTime.parse(rebuilt['at'] as String).toUtc(),
  );
}

/// 🔴 재개(E14) 의 백업 갭 원천 — 복구 없음 = null(축 빠짐).
int? recoveryBackupGapDaysOf(Database db, String deviceId) =>
    latestRecoveryOf(db, deviceId)?.backupGapDays;

/// 🔴 발주 봉인 원천(core `recoveryOrderSealCode` 의 `gapRebuildDone`) — 복구 없음 = true(복구 중이 아니다).
bool gapRebuildDoneOf(Database db, String deviceId) =>
    latestRecoveryOf(db, deviceId)?.gapRebuilt ?? true;

/// 🔴 GAP_REBUILT DONE 1행(바깥 트랜잭션 안 · 다시 = 쓰기 0).
void recordGapRebuilt(
  Database db,
  String runId,
  DateTime atUtc,
  Map<String, Object?> detail,
) {
  if (db.autocommit) throw StateError('recordGapRebuilt 는 트랜잭션 안에서만');
  db.execute(
    'INSERT OR IGNORE INTO migration_step (run_id, step, state, detail_json, at) '
    "VALUES (?, ?, 'DONE', ?, ?)",
    <Object?>[
      runId,
      RecoveryStep.gapRebuilt.wire,
      jsonEncode(detail),
      atUtc.toUtc().toIso8601String(),
    ],
  );
}

/// 새 폰 복구 저널(복원한 live 원장).
class SqliteRecoveryJournal {
  /// 만든다.
  SqliteRecoveryJournal(
    this._db, {
    required this.deviceId,
    required this._trusted,
  }) : isLive =
           _db.select('PRAGMA application_id').first.values.first ==
           LedgerFile.live.applicationId;

  final Database _db;
  final TrustedClock _trusted;

  /// 이 기기(새 폰).
  final String deviceId;

  /// live 원장인가(`application_id`).
  final bool isLive;

  /// 마지막 복구.
  RecoveryRun? latest() => latestRecoveryOf(_db, deviceId);

  /// 🔴 복구 시작 — 거부 = core 차례 → epoch → 이미 있음 · 통과 = 한 트랜잭션에 run + RESTORED.
  ({String? runId, String? rejectCode}) start({
    required MigrationKind kind,
    required OperatingMode operatingMode,
    required String? decisionId,
    required int operatorEpoch,
    required BackupManifest manifest,
  }) {
    final DateTime? now = _trusted.trustedNowUtc();
    final String? reject = migrationStartRejectCode(
      kind: kind,
      runMode: isLive ? RunMode.live : RunMode.simInternal,
      operatingMode: operatingMode,
      decisionId: decisionId,
      trustedNowUtc: now,
    );
    if (reject != null) return (runId: null, rejectCode: reject);
    if (operatorEpoch <= manifest.operatorEpoch) {
      return (runId: null, rejectCode: RecoveryCodes.epochNotAdvanced);
    }
    return inLedgerTransaction(_db, () {
      if (_db.select(
        "SELECT 1 FROM migration_run WHERE device_id = ? AND role = 'NEW_DEVICE'",
        <Object?>[deviceId],
      ).isNotEmpty) {
        return (runId: null, rejectCode: MigrationStoreCodes.runExists);
      }
      final int seq =
          (_db.select(
                'SELECT COUNT(*) AS n FROM migration_run WHERE run_id LIKE ?',
                <Object?>['mig-${kstDateText(now!)}-%'],
              ).single['n']
              as int) +
          1;
      final String id = migrationRunIdOf(now, seq);
      final String at = now.toIso8601String();
      _db.execute(
        'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          id,
          kind.wire,
          MigrationRole.newDevice.wire,
          deviceId,
          operatorEpoch,
          decisionId,
          at,
        ],
      );
      _db.execute(
        'INSERT INTO migration_step (run_id, step, state, detail_json, at) '
        "VALUES (?, ?, 'DONE', ?, ?)",
        <Object?>[
          id,
          RecoveryStep.restored.wire,
          manifest.toCanonicalJson(),
          at,
        ],
      );
      return (runId: id, rejectCode: null);
    });
  }
}
