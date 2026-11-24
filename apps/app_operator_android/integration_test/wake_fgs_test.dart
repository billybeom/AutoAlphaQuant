// 🆕 리뷰 3차 H1(설계 13 §8 R261 · 01 §8 미결 235) 에뮬레이터 확인 — 실제 호스트(Kotlin FGS · 알람 줄)에서 화면 동작 뒤 깨어남:
//   ① 모의 운영 원장 + 호스트 시작 → 깨어남 → FGS «정상» ② 킬스위치 발동(명령 API) → 다음 알람 없이 FGS = 킬스위치(BLOCKED)
//   ③ 기록 확인(신뢰 시각 모름 = 거부) → 깨어남 0 · FGS 그대로.
//
// 🔴 로컬 실측용(CI 밖 — 기기가 있어야 돈다) · 키 · 계좌 0 · 바깥 망 0(회차 0 — 모드 시작 = 지금).
// 실행: `flutter test integration_test/wake_fgs_test.dart -d emulator-5554` · 표지 `IT_H1_*` 마다 6초 멈춘다(바깥에서
//   `adb shell dumpsys notification --noredact` 로 FGS 글자를 읽는 자리).

import 'dart:io';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:data_sync/data_sync.dart' show ModeAxis, SqliteModeStore;
import 'package:domain_contracts/domain_contracts.dart'
    show
        CommandState,
        ExecPolicy,
        KillActivationReason,
        KillActivationScope,
        KillChecklistSubmission,
        LedgerFile,
        OperatingMode,
        RunMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void _mark(String m) {
  // ignore: avoid_print
  print(m);
}

Future<void> _pause(String marker) async {
  _mark(marker);
  await Future<void>.delayed(const Duration(seconds: 6));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('🔴 킬스위치 발동 → FGS 가 다음 알람 없이 바뀐다 · 거부 = 깨어남 0', () async {
    final AndroidOps ops = AndroidOps();
    final String dir = '${(await ops.paths()).noBackup}/r261_it';
    if (Directory(dir).existsSync()) Directory(dir).deleteSync(recursive: true);
    const SystemClock clock = SystemClock();
    final LedgerFiles files = LedgerFiles.open(dir, clock: clock);
    try {
      // 모의 운영 원장(온보딩 커밋의 모드 몫 — 시험 받침 `writeSimMode` 와 같은 꼴).
      expect(
        SqliteModeStore(files.sim, LedgerFile.sim, clock: clock).record(
          axis: ModeAxis.runMode,
          runMode: RunMode.simInternal,
          execPolicy: ExecPolicy.execute,
          operatingMode: OperatingMode.autoTrade,
          handoverSessionValid: false,
          decisionId: 'D-IT-R261',
        ),
        isNull,
      );
      final String now = clock.nowUtc().toIso8601String();
      files.sim.execute(
        'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
        <Object?>[OperatingMode.autoTrade.wire, now, now],
      );
      final OperatorRuntime rt = OperatorRuntime(
        files: files,
        clock: clock,
        deviceId: await deviceIdOrNull(ops),
      );
      int wakes = 0;
      rt.view.addListener(() => wakes++);
      final OperatorEngineHost? host = await startOperatorPlatform(runtime: rt);
      expect(host, isNotNull);
      await rt.wakeNow();
      expect(rt.view.value?.flags.runMode, RunMode.simInternal);
      _mark('IT_H1_VIEW ${rt.view.value?.flags.runMode.wire} wakes=$wakes');
      await _pause('IT_H1_FGS_OK');

      final OperatorCommandApi api = OperatorCommandApi(rt);
      final int before = wakes;
      expect((await api.activateKillSwitch()).state, CommandState.executed);
      // 같은 줄 — 한 번 더 넣으면 발동 뒤 깨어남이 끝난 뒤에 끝난다(다음 알람을 기다리지 않는다).
      await host!.wakeNow();
      expect(wakes, greaterThan(before));
      _mark('IT_H1_WAKES after-kill=${wakes - before}');
      await _pause('IT_H1_FGS_BLOCKED');

      final int beforeReject = wakes;
      final CommandState rejected = (await api.confirmKillChecklist(
        const KillChecklistSubmission(
          ruleAction: '규칙대로 신규 진입을 멈춘다',
          reasonKind: KillActivationReason.rule,
          scenarioId: 'W3',
          resumeCondition: '체결 오류 0',
          scope: KillActivationScope.newEntriesOnly,
          openOrdersQueried: true,
          openOrdersCancelled: true,
          remainingCountZero: true,
          note: '한 줄',
        ),
      )).state;
      expect(rejected, CommandState.rejected, reason: '신뢰 시각 모름 = 거부');
      await host.wakeNow();
      expect(wakes - beforeReject, 1, reason: '거부 = 명령 깨어남 0(위 한 번은 시험이 넣은 것)');
      await _pause('IT_H1_FGS_STILL_BLOCKED');
    } finally {
      files.close();
      Directory(dir).deleteSync(recursive: true);
    }
  });
}
