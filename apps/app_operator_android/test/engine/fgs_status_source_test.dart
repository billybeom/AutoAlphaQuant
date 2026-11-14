// E11p3c-4 FGS 상태 원천(설계 13 §8 R102) — 실 SQLite(알림 저장 · 안전 읽기 모델) · 엔진 재료 그대로.

import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/fgs_status_source.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart' show kSaf405;
import 'package:data_sync/data_sync.dart' show SqliteAlertSink;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AckState,
        AlertCodes,
        AlertItem,
        AlertLevel,
        OperatingMode,
        RunMode,
        TradeDate,
        UiLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_runtime/trading_runtime.dart'
    show
        FgsChannel,
        FgsNotice,
        FgsStatus,
        buildFgsNotice,
        sessionsUntilNextRebalance;

import 'support.dart';

AlertItem _alert(
  String id,
  AlertLevel level,
  DateTime at, {
  bool acked = false,
}) => AlertItem(
  alertId: id,
  level: level,
  raisedAt: at,
  code: 'X',
  title: '제목 $id',
  bodyText: '',
  actionLine: '',
  groupedCount: 1,
  ack: AckState(acked: acked, stateLabel: '', escalationStep: 0),
);

void main() {
  tearDownAll(deleteTempDirs);

  group('가장 이른 열린 P0', () {
    final DateTime t = DateTime.utc(2026, 12, 22, 1);

    test('🔴 P0 만 · 수신 확인 전만 · 가장 이른 것(같으면 id 차례)', () {
      expect(earliestOpenP0(<AlertItem>[]), isNull);
      final AlertItem got = earliestOpenP0(<AlertItem>[
        _alert('p1-old', AlertLevel.p1, t.subtract(const Duration(hours: 9))),
        _alert(
          'p0-acked',
          AlertLevel.p0,
          t.subtract(const Duration(hours: 8)),
          acked: true,
        ),
        _alert('p0-b', AlertLevel.p0, t),
        _alert('p0-a', AlertLevel.p0, t),
        _alert('p0-late', AlertLevel.p0, t.add(const Duration(hours: 1))),
      ])!;
      expect(got.alertId, 'p0-a');
    });

    test('수신 확인 칸이 없는 P0 = 열림', () {
      final AlertItem a = AlertItem(
        alertId: 'n',
        level: AlertLevel.p0,
        raisedAt: t,
        code: 'X',
        title: '',
        bodyText: '',
        actionLine: '',
        groupedCount: 1,
      );
      expect(earliestOpenP0(<AlertItem>[a]), same(a));
    });
  });

  group('원장 → FGS 상태', () {
    late FakeClock clock;
    late LedgerFiles files;

    setUp(() {
      clock = FakeClock(kst(2026, 12, 22, 9, 30));
      files = openFiles(tempLedgerDir(), clock);
      writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    });
    tearDown(() => files.close());

    Future<EngineReady> ready() async =>
        (await bootEngine(files, clock: clock)) as EngineReady;

    test('🔴 빈 원장 = 엔진 재료 그대로 · 대사 전 · 다음 리밸런싱 D-n · 문구가 만들어진다', () async {
      final FgsStatus s = fgsStatusForReady(
        await ready(),
        calendars: calendars(),
        clock: clock,
      );
      expect(s.lastReconAtUtc, isNull);
      expect(
        s.nextRebalanceInSessions,
        sessionsUntilNextRebalance(
          calendars().kr,
          const TradeDate('2026-12-22'),
        ),
      );
      expect(s.p0AlertId, isNull);
      final FgsNotice n = buildFgsNotice(s);
      expect(n.text, isNotEmpty);
      expect(n.channel, FgsChannel.opsStatus);
    });

    test('🔴 열린 P0 알림 = ACT · P0 채널 · 탭 = 그 알림', () async {
      await SqliteAlertSink(
        files.sim,
        clock: clock,
      ).emit('sim-auto-daily_reconcile', <String>{AlertCodes.reconMismatch});
      final FgsStatus s = fgsStatusForReady(
        await ready(),
        calendars: calendars(),
        clock: clock,
      );
      expect(s.level.index, greaterThanOrEqualTo(UiLevel.act.index));
      expect(s.p0AlertId, isNotNull);
      expect(buildFgsNotice(s).channel, FgsChannel.opsP0);
    });

    test('🔴 마지막 브로커 대사 시각이 실린다', () async {
      files.sim.execute(
        'INSERT INTO reconciliation_log (recon_id, run_at, matched, action_taken) VALUES (?, ?, 1, ?)',
        <Object?>['rc-2026-12-22', '2026-12-21T22:05:00Z', 'OK'],
      );
      final FgsStatus s = fgsStatusForReady(
        await ready(),
        calendars: calendars(),
        clock: clock,
      );
      expect(s.lastReconAtUtc, DateTime.utc(2026, 12, 21, 22, 5));
    });
  });

  test('🔴 기동 거부 = BLOCKED · 문구 = 엔진 거부 코드 그대로', () {
    final FgsStatus s = fgsStatusForRejected(
      const EngineRejected(
        runMode: RunMode.live,
        triggered: <String>[kSaf405],
        repaired: false,
      ),
    );
    expect(s.level, UiLevel.blocked);
    expect(s.headline, kSaf405);
    expect(buildFgsNotice(s).text, startsWith(kSaf405));
  });
}
