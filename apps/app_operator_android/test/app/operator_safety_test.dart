// E11p3d-3b 안전 상태 원천 operator 판(설계 13 §8 R113) — 실 SQLite(엔진 원장) · 바깥 = 없음.

import 'dart:async';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_safety.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show TrustedClock, kSafetyHoldLabels;
import 'package:domain_contracts/domain_contracts.dart'
    show
        BlockFlag,
        FlagIds,
        OperatingMode,
        RunMode,
        SafetyHoldCodes,
        SafetyState;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late OperatorRuntime rt;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 22, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
    rt = OperatorRuntime(files: files, clock: clock);
  });
  tearDown(() => files.close());

  Future<OperatorView> ready() async {
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    final OperatorView v = operatorViewOf(
      await bootEngine(files, clock: clock),
      files,
    )!;
    rt.view.value = v;
    return v;
  }

  void block(String flagId) => files.sim.execute(
    'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
    <Object?>[flagId, clock.nowUtc().toIso8601String(), '시험 차단'],
  );

  Iterable<String> flagIds(SafetyState s) =>
      s.activeFlags.map((BlockFlag f) => f.flagId);

  test('🔴 화면 상태 없음(온보딩 전) = 오류 · 지어내지 않는다', () async {
    final OperatorSafetyRepository r = OperatorSafetyRepository(rt);
    expect(r.state, throwsStateError);
    await expectLater(r.watchState(), emitsError(isA<StateError>()));
  });

  test('🔴 준비 = 화면 상태 원장의 안전 상태(모드 = 그 원장) · 차단 0', () async {
    await ready();
    final SafetyState s = await OperatorSafetyRepository(rt).watchState().first;
    expect(s.mode, RunMode.simInternal);
    expect(s.activeFlags, isEmpty);
  });

  test('🆕 미결 220 ⓓ 기동 hold → 화면 상태 → 안전 상태 holds · holdLabels(같은 차례 · 짝 문장) · 거부 · 모의 = 0', () async {
    final OperatorView sim = await ready();
    expect(sim.holds, isEmpty);
    expect(OperatorSafetyRepository(rt).state().holdLabels, isEmpty);
    final dir = tempLedgerDir();
    final LedgerFiles f = openFiles(dir, clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final Database live = writeLiveMode(dir, clock);
    addTearDown(live.close);
    // 승인 없음 = 기동 거부 → hold 0(거부 배너는 다른 축).
    final OperatorView rejected = operatorViewOf(
      await bootEngine(f, clock: clock),
      f,
    )!;
    expect(rejected.holds, isEmpty);
    // 승인 · 실키 미검증 = 준비 + LIVE_AWAITING_KEYS.
    final OperatorView v = operatorViewOf(
      await bootEngine(
        f,
        clock: clock,
        inputs: BootInputs(approvedOf: (Database _, RunMode m) => 1),
      ),
      f,
    )!;
    expect(v.holds, <String>{SafetyHoldCodes.liveAwaitingKeys});
    final OperatorRuntime liveRt = OperatorRuntime(files: f, clock: clock)
      ..view.value = v;
    final SafetyState s = await OperatorSafetyRepository(liveRt)
        .watchState()
        .first;
    expect(s.holds, <String>[SafetyHoldCodes.liveAwaitingKeys]);
    expect(s.holdLabels, <String>[
      kSafetyHoldLabels[SafetyHoldCodes.liveAwaitingKeys]!,
    ]);
  });

  test('🔴 차단 행이 생기면 다시 낸다(같은 연결)', () async {
    await ready();
    final List<SafetyState> got = <SafetyState>[];
    final StreamSubscription<SafetyState> sub = OperatorSafetyRepository(rt)
        .watchState()
        .listen(got.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(got, hasLength(1));
    block(FlagIds.ledgerIntegrity);
    await pumpEventQueue();
    expect(got.length, 2);
    expect(flagIds(got.last), contains(FlagIds.ledgerIntegrity));
  });

  test('🔴 시간만 흘러도 주기마다 다시 계산 · 같은 값은 다시 내지 않는다', () async {
    await ready();
    final List<SafetyState> got = <SafetyState>[];
    final StreamSubscription<SafetyState> sub = OperatorSafetyRepository(
      rt,
      tick: const Duration(milliseconds: 10),
    ).watchState().listen(got.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(got, hasLength(1));
    clock.now = clock.now.add(const Duration(minutes: 1));
    // 🔴 고정 대기가 아니라 조건 대기(최대 5초) — CI 의 시간 흔들림에 흔들리지 않는다.
    final Stopwatch w = Stopwatch()..start();
    while (got.length < 2 && w.elapsed < const Duration(seconds: 5)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(got, hasLength(2));
    expect(got.last.asOf.observedAt, clock.nowUtc());
  });

  test('🔴 화면 상태가 바뀌면 따라간다(없어짐 = 오류 · 다시 서면 값)', () async {
    final OperatorView v = await ready();
    final List<Object> got = <Object>[];
    final StreamSubscription<SafetyState> sub = OperatorSafetyRepository(rt)
        .watchState()
        .listen(got.add, onError: got.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(got.single, isA<SafetyState>());
    rt.view.value = null;
    await pumpEventQueue();
    expect(got.last, isA<StateError>());
    // 같은 원장 · 같은 값으로 다시 서도 값을 다시 낸다(오류에 갇히지 않는다).
    rt.view.value = v;
    await pumpEventQueue();
    expect(got.last, isA<SafetyState>());
    expect(flagIds(got.last as SafetyState), isEmpty);
    block(FlagIds.ledgerIntegrity);
    await pumpEventQueue();
    expect(flagIds(got.last as SafetyState), contains(FlagIds.ledgerIntegrity));
  });

  test(
    '🆕 E11k-a(R197) 신뢰 시각 = 실행 묶음의 것 — 모름 = «셀 수 없음» · 앎 = 해제 예정 시각',
    () async {
      final OperatorView v = await ready();
      final String at = clock.nowUtc().toIso8601String();
      files.sim.execute(
        'INSERT INTO kill_switch_state(id, activated_at, activated_by, checklist_confirmed_at, '
        'cleared_at, decision_id) VALUES (1, ?, ?, ?, NULL, NULL)',
        <Object?>[at, '시험 기기', at],
      );
      expect(
        OperatorSafetyRepository(rt).state().killSwitch.releaseEtaText,
        '서버 시각을 확인하지 못해 해제 시각을 셀 수 없습니다',
      );
      final OperatorRuntime known = OperatorRuntime(
        files: files,
        clock: clock,
        trusted: _At(clock.nowUtc()),
      )..view.value = v;
      expect(
        OperatorSafetyRepository(known).state().killSwitch.releaseEtaText,
        startsWith('해제 가능 예정 '),
      );
    },
  );
}

class _At implements TrustedClock {
  _At(this.at);
  final DateTime at;
  @override
  DateTime? trustedNowUtc() => at;
}
