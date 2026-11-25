// E11m-a — 회차 앞 명령 소비(설계 13 §8 R274 A5 · R272 Y6) — 실 SQLite · 가짜 핑 · 가짜 소비.
//
// 지키는 것: 소비 = 준비일 때만 · 회차 **앞** · 못 읽음 · 던짐 = 이 깨어남의 주문 잡을 막는 표식(다른 잡은 그대로) · 보고에 실린다.

import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/job_runners.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operator_engine.dart';
import 'package:data_sync/data_sync.dart'
    show CommandConsumeReport, CommandConsumeStop, CommandOpenFailure;
import 'package:domain_contracts/domain_contracts.dart' show OperatingMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_runtime/trading_runtime.dart' show JobOccurrence;

import 'support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late RecordingHeartbeat hb;
  late List<LedgerFiles> toClose;
  late List<String> seq;
  late List<JobContext> contexts;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 1, 8, 30));
    hb = RecordingHeartbeat();
    toClose = <LedgerFiles>[];
    seq = <String>[];
    contexts = <JobContext>[];
  });
  tearDown(() {
    for (final LedgerFiles f in toClose) {
      f.close();
    }
  });

  OperatorEngine engine(CommandConsumeHook? hook) {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    toClose.add(f);
    return OperatorEngine(
      openFiles: () => f,
      calendars: calendars(),
      heartbeat: hb,
      clock: clock,
      runners: (JobContext c) {
        contexts.add(c);
        return <String, JobRunner>{
          for (final MapEntry<String, JobRunner> e in composeJobRunners(
            c,
          ).entries)
            e.key: (JobOccurrence o) {
              seq.add('run:${e.key}');
              return e.value(o);
            },
        };
      },
      commands: hook,
    );
  }

  Future<void> ready(OperatorEngine e) async {
    await e.wake(); // 원장을 연다.
    final DateTime now = clock.now;
    clock.now = now.subtract(const Duration(days: 10));
    writeSimMode(e.files!.sim, clock, committed: OperatingMode.autoTrade);
    clock.now = now;
  }

  test('온보딩 전 = 소비 0(준비일 때만)', () async {
    int calls = 0;
    final OperatorEngine e = engine((EngineReady _) async {
      calls++;
      return null;
    });
    final EngineWakeReport r = await e.wake();
    expect(r.boot, isA<EngineOnboardingIncomplete>());
    expect((calls, r.commands, r.commandsError), (0, null, null));
  });

  test('🔴 준비 = 소비가 회차보다 먼저 · 당겨서 다 봄 = 막음 0 · 보고에 실림', () async {
    const CommandConsumeReport ok = CommandConsumeReport(
      pulled: 2,
      executed: 1,
    );
    late EngineReady seen;
    final OperatorEngine e = engine((EngineReady r) async {
      seen = r;
      seq.add('consume');
      return ok;
    });
    await ready(e);
    seq.clear();
    contexts.clear();
    final EngineWakeReport r = await e.wake();
    expect(seq.first, 'consume');
    expect(seq.where((String s) => s.startsWith('run:')), isNotEmpty);
    expect(identical(seen.db, e.files!.sim), isTrue);
    expect(
      (r.commands, r.ordersBlockedByCommands, contexts.single.commandsBlocked),
      (ok, false, false),
    );
  });

  test('🔴 리스는 쥐었는데 명령 표를 못 읽음 = 주문 잡 막음 표식 · 회차는 그대로 돈다', () async {
    final OperatorEngine e = engine(
      (EngineReady _) async => const CommandConsumeReport(
        stop: CommandConsumeStop.pullFailed,
        pullFailure: CommandOpenFailure.network,
      ),
    );
    await ready(e);
    contexts.clear();
    seq.clear();
    final EngineWakeReport r = await e.wake();
    expect(
      (r.ordersBlockedByCommands, contexts.single.commandsBlocked),
      (true, true),
    );
    expect(r.runs, isNotEmpty);
  });

  test('🔴 소비가 던짐 = 모름 쪽(막음 표식 · 보고에 던진 것) · 깨어남은 끝까지', () async {
    final OperatorEngine e = engine(
      (EngineReady _) async => throw StateError('consume'),
    );
    await ready(e);
    contexts.clear();
    final EngineWakeReport r = await e.wake();
    expect(r.commandsError, isA<StateError>());
    expect(
      (r.ordersBlockedByCommands, contexts.single.commandsBlocked),
      (true, true),
    );
    expect(r.runs, isNotEmpty);
  });

  test('소비 자리 아님(null 보고 · 갈고리 없음) = 막음 0', () async {
    for (final CommandConsumeHook? hook in <CommandConsumeHook?>[
      (EngineReady _) async => null,
      null,
    ]) {
      final OperatorEngine e = engine(hook);
      await ready(e);
      contexts.clear();
      final EngineWakeReport r = await e.wake();
      expect((r.commands, r.ordersBlockedByCommands), (null, false));
      expect(contexts.single.commandsBlocked, isFalse);
    }
  });

  test('리스 거부 · 모름 · 기기 없음 보고 = 주문 막음 0(주문 잡이 자기 리스 판정으로 막는다)', () async {
    for (final CommandConsumeStop stop in <CommandConsumeStop>[
      CommandConsumeStop.noDevice,
      CommandConsumeStop.noEpoch,
      CommandConsumeStop.leaseNotHeld,
      CommandConsumeStop.leaseUnknown,
    ]) {
      final OperatorEngine e = engine(
        (EngineReady _) async => CommandConsumeReport(stop: stop),
      );
      await ready(e);
      contexts.clear();
      final EngineWakeReport r = await e.wake();
      expect(r.ordersBlockedByCommands, isFalse, reason: stop.name);
      expect(contexts.single.commandsBlocked, isFalse, reason: stop.name);
    }
  });
}
