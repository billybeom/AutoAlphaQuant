// E13h2 — 운영 기기 알림 읽기(`SqliteAlertRepository` · 설계 13 §8 R69 I0 · I9).
//
// 🔵 잡는 것: ① 행 읽기 = 확인 시각 · 적힌 단계 수 ② 센터 · 인박스 · 상세가 저장(E13h1 sink · 확인 · 사다리)을 그대로 비춘다
//    ③ 갱신 = 알림 · 확인 · 사다리 쓰기마다 다시 냄 · 다른 표 쓰기 = 안 냄 ④ 모르는 등급 · 오프셋 없는 시각 = 스트림 오류.
import 'dart:async';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show AlertEscalationChannel, StoredAlert;
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

class _Channel implements AlertEscalationChannel {
  @override
  Future<void> escalate({
    required String alertId,
    required String code,
    required int step,
  }) async {}
}

// 한국 2026-11-05 10:00.
final DateTime _t0 = DateTime.utc(2026, 11, 5, 1);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late SqliteAlertSink sink;
  late SqliteAlertRepository repo;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_alr_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    sink = SqliteAlertSink(db, clock: clock);
    repo = SqliteAlertRepository(db, clock: clock);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  test('행 읽기 = 확인 시각 · 적힌 단계 수', () async {
    await sink.emit('kr_order', <String>{'RECON_MISMATCH', 'ORDER_REJECTED'});
    clock.at = _t0.add(const Duration(minutes: 20));
    await sink.escalationTick(_Channel());
    sink.acknowledge(
      commandId: 'a',
      payloadDigest: 'dg',
      alertId: 'AL-2026-11-05-kr_order-RECON_MISMATCH',
    );
    final Map<String, StoredAlert> rows = <String, StoredAlert>{
      for (final StoredAlert a in storedAlerts(db)) a.alertId: a,
    };
    final StoredAlert p0 = rows['AL-2026-11-05-kr_order-RECON_MISMATCH']!;
    expect(
      (p0.level, p0.raisedAtUtc, p0.ackedAtUtc, p0.escalationSteps),
      (AlertLevel.p0, _t0, _t0.add(const Duration(minutes: 20)), 1),
    );
    final StoredAlert p1 = rows['AL-2026-11-05-kr_order-ORDER_REJECTED']!;
    expect(
      (p1.level, p1.ackedAtUtc, p1.escalationSteps),
      (AlertLevel.p1, null, 0),
    );
  });

  test('센터 · 인박스 · 상세 = 저장 그대로 · 갱신마다 다시 냄 · 다른 표 = 안 냄', () async {
    final List<AlertCenterVm> seen = <AlertCenterVm>[];
    final StreamSubscription<AlertCenterVm> sub = repo
        .watchCenter(p0Only: false)
        .listen(seen.add);
    await pumpEventQueue();
    expect(seen.single.emptyLabel, '새 알림이 없습니다. 이상이 생기면 바로 알립니다.');
    await sink.emit('kr_order', <String>{'RECON_MISMATCH', 'WATCHDOG_LATE'});
    await pumpEventQueue();
    expect(seen, hasLength(2));
    final AlertCenterVm c = seen.last;
    expect(c.pinned.single.alertId, 'AL-2026-11-05-kr_order-RECON_MISMATCH');
    expect(c.pinned.single.ack!.stateLabel, '수신 확인 전');
    expect(c.sections.single.headerText, '오늘');
    expect(c.sections.single.rows.single.code, 'WATCHDOG_LATE');
    // 확인 = 다시 냄(글자가 바뀐다).
    sink.acknowledge(
      commandId: 'a',
      payloadDigest: 'dg',
      alertId: 'AL-2026-11-05-kr_order-RECON_MISMATCH',
    );
    await pumpEventQueue();
    expect(seen.last.pinned.single.ack!.stateLabel, '수신 확인함');
    // 알림과 무관한 표 쓰기 = 안 냄.
    final int n = seen.length;
    db.execute(
      "INSERT INTO fx_rates(trade_date, pair, close) VALUES ('2026-11-05', 'USDKRW', 1400)",
    );
    await pumpEventQueue();
    expect(seen, hasLength(n));
    await sub.cancel();

    final List<AlertItem> p0 = await repo.watchInbox(min: AlertLevel.p0).first;
    expect(p0.map((AlertItem i) => i.code), <String>['RECON_MISMATCH']);
    final List<AlertItem> all = await repo.watchInbox().first;
    expect(all.map((AlertItem i) => i.code), <String>[
      'RECON_MISMATCH',
      'WATCHDOG_LATE',
    ]);
    final AlertDetailVm d = await repo
        .watchAlert('AL-2026-11-05-kr_order-WATCHDOG_LATE')
        .first;
    expect(d.item!.title, '잡이 제때 돌지 않았습니다');
    final AlertDetailVm m = await repo.watchAlert('AL-NONE').first;
    expect(
      (m.item, m.missingLabel),
      (null, '이 알림은 더 이상 없습니다. 알림 센터에서 최근 알림을 확인하십시오.'),
    );
    final AlertCenterVm p0Only = await repo.watchCenter(p0Only: true).first;
    expect(p0Only.sections, isEmpty);
    expect(p0Only.pinned, hasLength(1));
  });

  test('사다리 단계 = 다시 냄', () async {
    await sink.emit('kr_order', <String>{'ORDER_OUTCOME_UNKNOWN'});
    final List<AlertCenterVm> seen = <AlertCenterVm>[];
    final StreamSubscription<AlertCenterVm> sub = repo
        .watchCenter(p0Only: true)
        .listen(seen.add);
    await pumpEventQueue();
    clock.at = _t0.add(const Duration(minutes: 15));
    await sink.escalationTick(_Channel());
    await pumpEventQueue();
    expect(seen.last.pinned.single.ack!.stateLabel, '수신 확인 전 · 백업 채널로 보냈습니다');
    await sub.cancel();
  });

  test('🔴 모르는 등급 · 오프셋 없는 시각 = 스트림 오류', () async {
    db.execute('PRAGMA ignore_check_constraints = ON');
    db.execute(
      "INSERT INTO alert_event(alert_id, raised_at, code, level, source, dedupe_key) VALUES ('x', '2026-11-05T00:00:00.000Z', 'RECON_MISMATCH', 'P9', 's', 'k')",
    );
    await expectLater(repo.watchInbox().first, throwsFormatException);
    db.execute("DELETE FROM alert_event WHERE alert_id = 'x'");
    db.execute('PRAGMA ignore_check_constraints = OFF');
    db.execute(
      "INSERT INTO alert_event(alert_id, raised_at, code, level, source, dedupe_key) VALUES ('y', '2026-11-05T00:00:00', 'RECON_MISMATCH', 'P0', 's', 'k2')",
    );
    await expectLater(
      repo.watchCenter(p0Only: false).first,
      throwsFormatException,
    );
  });

  test('다시 낼 표 = 알림 3표 + 🆕 E11q-q6c 실사 표식(목적지)', () {
    expect(SqliteAlertRepository.watchedTables, <String>{
      'alert_event',
      'alert_ack',
      'alert_escalation',
      'trading_block',
    });
  });
}
