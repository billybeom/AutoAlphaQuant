// E11m-a — 회차 앞 명령 소비 조립(설계 13 §8 R274 · R272 Y5) — 실 SQLite · 가짜 포트.
//
// 지키는 것: 포트 · 원격 원천 하나라도 없으면 갈고리 0 · 모의 내부 = 소비 0(당김 0 · 리스 판정 0) · 원격 모드 = 그 원장의 SUPABASE 세대 ·
// 리스 = 원격 판정(주문 잡과 같은 `operatorLeaseGate`) · 리스 판정이 던짐 = 모름.

import 'package:app_operator_android/engine/command_wiring.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/fgs_status_source.dart'
    show UnknownTrustedClock;
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operator_engine.dart'
    show CommandConsumeHook;
import 'package:core_engine/core_engine.dart' show LeaseGate, LeaseVerdict;
import 'package:data_sync/data_sync.dart'
    show
        CommandConsumeReport,
        CommandConsumeStop,
        CommandOpenReader,
        CommandOpenResult,
        OpsPushResult,
        OpsPusher;
import 'package:domain_contracts/domain_contracts.dart'
    show CommandReadLimits, ExecPolicy, LedgerFile, OperatingMode, RunMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'support.dart';

class _Reader implements CommandOpenReader {
  int calls = 0;
  @override
  Future<CommandOpenResult> open({
    int limit = CommandReadLimits.openMax,
  }) async {
    calls++;
    return const CommandOpenResult.rows(<Map<String, Object?>>[]);
  }
}

class _Pusher implements OpsPusher {
  @override
  Future<OpsPushResult> push({
    required String deviceId,
    required int epoch,
    required String table,
    required List<Map<String, Object?>> rows,
  }) async => OpsPushResult.answered(
    code: null,
    epoch: epoch,
    accepted: rows.length,
    skipped: 0,
  );
}

class _Remote implements LeaseGate {
  _Remote(this.verdict);
  final LeaseVerdict? verdict;
  int checks = 0;
  @override
  Future<LeaseVerdict> check() async {
    checks++;
    final LeaseVerdict? v = verdict;
    if (v == null) throw StateError('remote');
    return v;
  }
}

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late _Reader reader;
  setUp(() {
    clock = FakeClock(kst(2026, 12, 8, 9, 0));
    files = openFiles(tempLedgerDir(), clock);
    reader = _Reader();
  });
  tearDown(() => files.close());

  EngineReady ready(Database db, RunMode mode) => EngineReady(
    db: db,
    file: LedgerFile.sim,
    runMode: mode,
    operatingMode: OperatingMode.autoTrade,
    execPolicy: ExecPolicy.execute,
    holds: const <String>{},
    repaired: false,
  );

  CommandConsumeHook? hook({
    CommandOpenReader? r,
    OpsPusher? p,
    LeaseGate? Function(Database db)? remote,
    String? device = 'op-1',
  }) => commandConsumeHookOf(
    reader: r,
    pusher: p,
    leaseRemote: remote,
    deviceId: device,
    trusted: const UnknownTrustedClock(),
    clock: clock,
    calendars: calendars(),
  );

  void epoch(Database db, int e) => db.execute(
    "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, 'OK', ?, 'u0')",
    <Object?>[e],
  );

  test('포트 · 원격 원천 하나라도 없으면 갈고리 0', () {
    LeaseGate? of(Database _) => _Remote(LeaseVerdict.valid);
    expect(hook(p: _Pusher(), remote: of), isNull);
    expect(hook(r: reader, remote: of), isNull);
    expect(hook(r: reader, p: _Pusher()), isNull);
    expect(hook(r: reader, p: _Pusher(), remote: of), isNotNull);
  });

  test('🔴 모의 내부 = 소비 0(당김 0 · 리스 판정 0 · 보고 null = 막음 0)', () async {
    final _Remote remote = _Remote(LeaseVerdict.valid);
    epoch(files.sim, 3);
    final CommandConsumeReport? r = await hook(
      r: reader,
      p: _Pusher(),
      remote: (Database _) => remote,
    )!(ready(files.sim, RunMode.simInternal));
    expect((r, reader.calls, remote.checks), (null, 0, 0));
  });

  test(
    '원격 모드 = 그 원장의 SUPABASE 세대 · 원격 리스 판정 · 쥠 = 당김 · 세대 0 = 당김 전 멈춤',
    () async {
      final _Remote remote = _Remote(LeaseVerdict.valid);
      final CommandConsumeHook h = hook(
        r: reader,
        p: _Pusher(),
        remote: (Database _) => remote,
      )!;
      final CommandConsumeReport? none = await h(
        ready(files.sim, RunMode.live),
      );
      expect((none!.stop, reader.calls), (CommandConsumeStop.noEpoch, 0));
      epoch(files.sim, 3);
      final CommandConsumeReport? ok = await h(ready(files.sim, RunMode.live));
      expect((ok!.stop, reader.calls, remote.checks), (null, 1, 1));
    },
  );

  test('원격 리스 판정이 던짐 = 모름(당김 0 · 막음 0)', () async {
    epoch(files.sim, 3);
    final CommandConsumeReport? r = await hook(
      r: reader,
      p: _Pusher(),
      remote: (Database _) => _Remote(null),
    )!(ready(files.sim, RunMode.simBroker));
    expect(
      (r!.stop, r.blocksOrders, reader.calls),
      (CommandConsumeStop.leaseUnknown, false, 0),
    );
  });
}
