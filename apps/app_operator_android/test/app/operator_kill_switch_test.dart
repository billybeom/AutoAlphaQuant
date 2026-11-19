// E11q-b1a — M5-1 킬스위치 조립(설계 13 §8 R178) — 실 SQLite(sim 원장).
//
// 🔴 발동 = 인자 0 · 이 폰 로컬 단락(취소 경로 없음 → «그대로 남습니다» 보고) · 기록 = 원문 → 엔진(신뢰 시각 모름 = 거부 · 앎 = 48h) ·
//    읽기 = 원장 변경으로 다시 낸다 · 게이트 링크 = 등록 화면만(M5-2 = b1b) · 기기 id 없음 = 명령 실패.

import 'dart:async';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_kill_switch.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show KillCommandTexts, KillSwitchScreenTexts, TrustedClock;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);

  DateTime? at;

  @override
  DateTime? trustedNowUtc() => at;
}

Future<void> until(bool Function() ok) async {
  for (int i = 0; i < 300 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue);
}

const KillChecklistSubmission _ok = KillChecklistSubmission(
  ruleAction: '규칙대로 신규 진입을 멈춘다',
  reasonKind: KillActivationReason.rule,
  scenarioId: 'W3',
  resumeCondition: '체결 오류 0',
  scope: KillActivationScope.newEntriesOnly,
  openOrdersQueried: true,
  openOrdersCancelled: true,
  remainingCountZero: true,
  note: '한 줄',
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 23, 10, 2));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(null);
  });
  tearDown(() => files.close());

  OperatorRuntime rt({String? device = 'dev-1'}) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: device,
      trusted: trusted,
    );
    r.view.value = OperatorView(
      db: files.sim,
      flags: const FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg_test',
      ),
    );
    return r;
  }

  test('🆕 R178 발동 → 켜짐(원장 변경으로 다시 냄) · 기록: 고르지 않음 = 큐 없이 거부 · 신뢰 시각 모름 = 거부 · 앎 = 48h · 게이트 링크 = 미등록 0', () async {
    final OperatorRuntime r = rt();
    final OperatorKillSwitchGateRepository repo =
        OperatorKillSwitchGateRepository(
          r,
          hasBody: kOperatorRouteBodies.byPattern.containsKey,
          tick: const Duration(hours: 1),
        );
    final List<KillSwitchScreenVm> got = <KillSwitchScreenVm>[];
    final StreamSubscription<KillSwitchScreenVm> sub = repo
        .watchKillSwitch()
        .listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(got.last.activateLabel, KillSwitchScreenTexts.activate);
    final OperatorCommandApi api = OperatorCommandApi(r);
    final CommandReceipt on = await api.activateKillSwitch();
    expect(on.state, CommandState.executed);
    expect(on.kind, CommandKind.killSwitchActivate);
    expect(on.stateLabel, KillCommandTexts.activated);
    expect(await api.watchCommand(on.commandId).first, on);
    await until(() => got.last.activateLabel == null);
    expect(got.last.activatedText, '발동 12-23 10:02 · 운영 폰');
    expect(got.last.cancelHeadline, '미체결 주문이 없었습니다.');
    expect(got.last.form, isNotNull);
    expect(
      (await OperatorKillSwitchGateRepository(
        rt(device: null),
        hasBody: kOperatorRouteBodies.byPattern.containsKey,
      ).watchKillSwitch().first).form,
      isNull,
      reason: '기기 id 없음 = 기록 폼 부재(쓰기 창구 없음)',
    );
    final CommandReceipt missing = await api.confirmKillChecklist(
      _ok.copyWith(reasonKind: null),
    );
    expect(missing.rejectReasonCode, 'KILL_CHECKLIST_ITEM_MISSING');
    final CommandReceipt unknown = await api.confirmKillChecklist(_ok);
    expect(unknown.rejectReasonCode, 'TRUSTED_TIME_UNKNOWN');
    expect(
      unknown.stateLabel,
      KillCommandTexts.rejected('TRUSTED_TIME_UNKNOWN'),
    );
    trusted.at = clock.nowUtc().add(const Duration(minutes: 18));
    final CommandReceipt yes = await api.confirmKillChecklist(_ok);
    expect(yes.state, CommandState.executed, reason: yes.stateLabel);
    expect(yes.stateLabel, KillCommandTexts.confirmed);
    await until(() => got.last.form == null);
    expect(got.last.etaText, '해제 가능 예정 12-25 10:20');
    // 🆕 R180 — M5-2 게이트 등록 → 기록 뒤 링크가 선다.
    expect(got.last.gateLink?.deepLink, AppRoutes.m5ReleaseGate);
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.m5KillSwitch),
      true,
    );
  });

  test('🆕 R178 기기 id 없음 = 발동 · 기록 실패(버튼 부재 규약 — 셸 주입 null)', () async {
    final OperatorCommandApi api = OperatorCommandApi(rt(device: null));
    await expectLater(api.activateKillSwitch(), throwsA(isA<StateError>()));
    await expectLater(
      api.confirmKillChecklist(_ok),
      throwsA(isA<StateError>()),
    );
  });
}
