// 🆕 미결 243 ⓒ — 공유 계층 push 경보 갈래 시험(설계 13 §8 R273 · 계약 K344 · K372).
//
// ① 사람이 볼 실패만 → 두 코드(시크릿 차단 = SECRET_BLOCKED · 그 밖 = REJECTED) · LAG · notTried · OK = 0
// ② 🔴 두 push 가 «사람이 볼 실패»로 가르는 사유 전부 = 갈래가 있다(새 거부 · 실패 갈래가 늘면 여기서 걸린다)
// ③ 낸 곳 하나 — 두 push 가 같은 날 같은 코드를 내도 알림 한 건(dedupe) · 다른 날 = 새 건 · 등급 = P1(엔진 표).

import 'dart:io';

import 'package:core_engine/core_engine.dart' show alertLevelOf;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

void main() {
  test('① 사람이 볼 실패만 · 시크릿 = SECRET_BLOCKED · 그 밖 = REJECTED · LAG · notTried · OK = 0', () {
    ReadModelTablePush rm(ReadModelPushOutcome o, [String? reason]) =>
        ReadModelTablePush('rm_alert', o, reason: reason);
    OpsTablePush op(OpsPushOutcome o, [String? reason]) =>
        OpsTablePush('resume_run_mirror', o, reason: reason);
    expect(sharedPushAlertCodes(), isEmpty);
    expect(
      sharedPushAlertCodes(
        readModels: <ReadModelTablePush>[
          rm(ReadModelPushOutcome.ok),
          rm(ReadModelPushOutcome.lag, 'network'),
          rm(ReadModelPushOutcome.lag, 'LEASE_LOST'),
          rm(ReadModelPushOutcome.notTried),
        ],
        ops: <OpsTablePush>[
          op(OpsPushOutcome.ok),
          op(OpsPushOutcome.lag, 'server'),
          op(OpsPushOutcome.notTried),
        ],
      ),
      isEmpty,
    );
    expect(
      sharedPushAlertCodes(
        readModels: <ReadModelTablePush>[
          rm(ReadModelPushOutcome.failed, 'secretBlocked'),
        ],
      ),
      <String>{AlertCodes.readModelPushSecretBlocked},
    );
    expect(
      sharedPushAlertCodes(
        ops: <OpsTablePush>[op(OpsPushOutcome.failed, 'OPS_PUSH_ROWS_INVALID')],
      ),
      <String>{AlertCodes.readModelPushRejected},
    );
    expect(
      sharedPushAlertCodes(
        readModels: <ReadModelTablePush>[
          rm(ReadModelPushOutcome.failed, 'ROW:모드 다름'),
        ],
        ops: <OpsTablePush>[op(OpsPushOutcome.failed, 'secretBlocked')],
      ),
      AlertCodes.readModelPush,
    );
    expect(kSharedPushAlertSource, 'shared_push');
  });

  test('② 🔴 사람이 볼 실패 사유 전부 = 갈래 있음 · 두 push 의 시크릿 갈래 글자 같음', () {
    expect(
      ReadModelPushFailure.secretBlocked.name,
      OpsPushFailure.secretBlocked.name,
    );
    // rm_push: 서버 고유 거부 · 클라이언트 실패 중 failed 로 가는 것.
    for (final String r in <String>{
      ...ReadModelPushResultCodes.values,
      ...OpsPushResultCodes.values,
      ReadModelPushFailure.badResponse.name,
      OpsPushFailure.badResponse.name,
      'ROW:x',
    }) {
      expect(
        sharedPushAlertCodeOf(r),
        AlertCodes.readModelPushRejected,
        reason: r,
      );
    }
    for (final OpsPushFailure f in OpsPushFailure.values) {
      final bool human = isOpsPushFailure(OpsPushResult.failed(f));
      if (!human) continue;
      expect(
        AlertCodes.readModelPush,
        contains(sharedPushAlertCodeOf(f.name)),
        reason: f.name,
      );
    }
    expect(
      sharedPushAlertCodeOf(OpsPushFailure.secretBlocked.name),
      AlertCodes.readModelPushSecretBlocked,
    );
    for (final String c in AlertCodes.readModelPush) {
      expect(alertLevelOf(c), AlertLevel.p1, reason: c);
    }
  });

  test('③ 낸 곳 하나 — 같은 날 같은 코드 = 한 건 · 다른 날 = 새 건', () async {
    final Directory dir = Directory.systemTemp.createTempSync('aaq_spa_');
    final DateTime t0 = DateTime.utc(2026, 12, 22, 0, 30); // 한국 09:30
    final _Clock clock = _Clock(t0);
    final Database db = openLocalLedger(
      dir.path,
      RunMode.live,
      clock: () => t0,
    );
    addTearDown(() {
      db.close();
      dir.deleteSync(recursive: true);
    });
    final SqliteAlertSink sink = SqliteAlertSink(db, clock: clock);
    int n() =>
        db.select('SELECT COUNT(*) AS n FROM alert_event').single['n'] as int;
    // rm_push 보고 · op_push 보고가 같은 날 같은 원인으로 둘 다 거부.
    await sink.emit(
      kSharedPushAlertSource,
      sharedPushAlertCodes(
        readModels: <ReadModelTablePush>[
          const ReadModelTablePush(
            'rm_watchdog',
            ReadModelPushOutcome.failed,
            reason: 'READ_MODEL_TABLE_UNKNOWN',
          ),
        ],
      ),
    );
    clock.at = t0.add(const Duration(hours: 3));
    await sink.emit(
      kSharedPushAlertSource,
      sharedPushAlertCodes(
        ops: <OpsTablePush>[
          const OpsTablePush(
            'ledger_stamp',
            OpsPushOutcome.failed,
            reason: 'OPS_PUSH_TABLE_UNKNOWN',
          ),
        ],
      ),
    );
    expect(n(), 1);
    clock.at = t0.add(const Duration(days: 1));
    await sink.emit(kSharedPushAlertSource, <String>{
      AlertCodes.readModelPushRejected,
    });
    expect(n(), 2);
  });
}
