// E11o-d — 골든 기기 실행기 operator 판(설계 13 §8 R167) — 실제 벡터 파일(엔진 패키지 자산) · 실 SQLite.
//
// 🔴 자산 = 엔진 pubspec 이 싣는 실행기 선언 파일 그대로(디스크에서 읽어 rootBundle 대신 넘긴다).
// 🔴 S10 카드 · 동작 결과 · O-04 ④ 사실 · 칸 = 엔진 글자 · 기록 = `reconciliation_log` `gv-` 1행.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_operator_android/app/operator_biometric.dart';
import 'package:app_operator_android/app/operator_golden.dart';
import 'package:app_operator_android/app/operator_onboarding.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/app/operator_settings_repository.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/safety/golden_selftest_field.dart';
import 'package:broker_gateway/broker_gateway.dart' show KisRestClient;
import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        GoldenBundle,
        GoldenRecordView,
        GoldenRunResult,
        GoldenSelfTestTexts,
        TrustedClock,
        kDeviceGoldenSuite,
        kGoldenFailed,
        kGoldenOk;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show SqliteOnboardingStore, SqlitePledgeStore;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/widgets.dart' show SizedBox, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';
const String _vectors = '../../packages/core_engine/test/golden/vectors';

class _Trusted implements TrustedClock {
  const _Trusted(this.at);
  final DateTime at;
  @override
  DateTime? trustedNowUtc() => at;
}

final _Trusted _trusted = _Trusted(DateTime.utc(2026, 11, 19, 0, 30));

/// rootBundle 대신 — 자산 열쇠 → 엔진 패키지의 같은 파일.
Future<String> _disk(String key) async {
  const String prefix = 'packages/core_engine/test/golden/vectors/';
  expect(key, startsWith(prefix));
  return File('$_vectors/${key.substring(prefix.length)}').readAsString();
}

Future<void> until(bool Function() ok) async {
  for (int i = 0; i < 500 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue);
}

OperatorView viewOf(Database db) => OperatorView(
  db: db,
  flags: const FeatureFlags(
    satelliteEnabled: false,
    webViewerEnabled: false,
    calendarEnabled: false,
    runMode: RunMode.simInternal,
    operatingMode: OperatingMode.autoTrade,
    configHash: 'cfg_test',
  ),
);

int _goldenRows(Database db) =>
    db
            .select(
              "SELECT COUNT(*) AS n FROM reconciliation_log WHERE recon_id GLOB 'gv-*'",
            )
            .single['n']
        as int;

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 19, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  final GoldenBundle disk = GoldenBundle(<String, String>{
    for (final String n in kDeviceGoldenSuite.files)
      n: File('$_vectors/$n').readAsStringSync(),
  });

  group('OperatorGolden', () {
    test('🔴 실행기 = «전량» · 자산 = 선언 파일 · 지문 · 전체 수 = 엔진 셈', () async {
      expect(kDeviceGoldenSuite.complete, isTrue);
      final OperatorGolden g = OperatorGolden(_disk, clock: clock);
      final GoldenPrepared p = await g.prepare();
      expect(p.files.keys.toSet(), kDeviceGoldenSuite.files);
      expect(p.digest, disk.digest);
      expect(p.total, kDeviceGoldenSuite.caseCount(disk));
      expect(g.prepared, same(p));
      expect(await g.prepare(), same(p), reason: '한 번만 읽는다');
    });

    test('🔴 백그라운드 isolate 실행 = 전량 통과 · 기록 1행(gv- · GOLDEN_OK · 결과 JSON) · 실행 중 표시', () async {
      final OperatorGolden g = OperatorGolden(_disk, clock: clock);
      final List<bool> seen = <bool>[];
      g.running.addListener(() => seen.add(g.running.value));
      final GoldenRunResult r = await g.run(files.sim);
      expect(r.allPassed, isTrue);
      expect(r.total, kDeviceGoldenSuite.caseCount(disk));
      expect(seen, <bool>[true, false]);
      final row = files.sim
          .select(
            "SELECT recon_id, run_at, matched, discrepancies, action_taken FROM reconciliation_log WHERE recon_id GLOB 'gv-*'",
          )
          .single;
      expect(row['action_taken'], kGoldenOk);
      expect(row['matched'], 1);
      expect(
        row['recon_id'],
        startsWith('gv-${clock.nowUtc().toUtc().toIso8601String()}#1'),
      );
      final Map<String, Object?> j =
          jsonDecode(row['discrepancies'] as String) as Map<String, Object?>;
      expect(j['digest'], disk.digest);
      expect(j['passed'], r.total);
      expect(j['failed'], isEmpty);
      final GoldenRecordView? last = OperatorGolden.lastRecord(files.sim);
      expect(last?.ok, isTrue);
      expect(last?.digest, disk.digest);
    });

    test('같은 실행이 진행 중이면 같은 결과(한 번 실행 · 한 행) · 결과 문장 = 엔진', () async {
      final OperatorGolden g = OperatorGolden(
        _disk,
        clock: clock,
        isolate: false,
      );
      final Future<GoldenRunResult> a = g.run(files.sim);
      final Future<GoldenRunResult> b = g.run(files.sim);
      expect(identical(await a, await b), isTrue);
      expect(_goldenRows(files.sim), 1);
      expect(await g.runHeadline(files.sim), GoldenSelfTestTexts.okHeadline);
      expect(_goldenRows(files.sim), 2);
    });

    test('자산을 못 읽으면 던지고 다음에 다시 읽는다 · 기록 0', () async {
      bool broken = true;
      final OperatorGolden g = OperatorGolden(
        (String k) async {
          if (broken) throw StateError('자산 없음');
          return _disk(k);
        },
        clock: clock,
        isolate: false,
      );
      await expectLater(g.prepare(), throwsStateError);
      expect(g.prepared, isNull);
      await expectLater(g.run(files.sim), throwsStateError);
      expect(_goldenRows(files.sim), 0);
      broken = false;
      expect((await g.prepare()).digest, disk.digest);
    });

    test(
      '다른 기록(rc- · li-)은 골든 기록으로 읽지 않는다 · 더 늦어도 골든 기록을 읽는다 · 꼴 틀린 골든 행 = 없음',
      () async {
        files.sim.execute(
          'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) VALUES '
          "('rc-2026-11-19T00:00:00.000Z#1', '2026-11-19T00:00:00.000Z', 1, '{}', 'MATCHED'), "
          "('li-2026-11-19T00:00:01.000Z#1', '2026-11-19T00:00:01.000Z', 1, '{}', 'INTEGRITY_OK')",
        );
        expect(OperatorGolden.lastRecord(files.sim), isNull);
        // 골든 기록(지금 시각 = 위 행들보다 이르다) 뒤에 더 늦은 다른 기록이 있어도 골든 기록을 읽는다.
        await OperatorGolden(
          _disk,
          clock: FakeClock(DateTime.utc(2026, 11, 18)),
          isolate: false,
        ).run(files.sim);
        expect(OperatorGolden.lastRecord(files.sim)?.ok, isTrue);
        files.sim.execute(
          'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) VALUES '
          "('gv-2026-11-19T00:00:02.000Z#1', '2026-11-19T00:00:02.000Z', 1, '{', 'GOLDEN_OK')",
        );
        expect(OperatorGolden.lastRecord(files.sim), isNull);
      },
    );
  });

  group('S10', () {
    OperatorRuntime rt({bool golden = true}) => OperatorRuntime(
      files: files,
      clock: clock,
      vault: MemorySecretVault(),
      kisHttp: http.Client(),
      golden: golden
          ? OperatorGolden(_disk, clock: clock, isolate: false)
          : null,
    )..view.value = viewOf(files.sim);

    OperatorSettingsActions actions(OperatorRuntime r) =>
        OperatorSettingsActions(
          secrets: r.secrets,
          vault: r.vault!,
          clientOf: (c) =>
              KisRestClient(r.kisHttp!, c, environment: c.environment),
          clock: clock,
          ledger: () => r.view.value?.db,
          golden: r.golden,
        );

    test('🔴 정답지 하나가 어긋난 자산 = 결과 ACT · 기록 GOLDEN_FAILED(matched 0) · 카드 «불일치» · «통과 n/전체 m»', () async {
      // GV-3 첫 케이스 기대값만 바꾼 자산(앱이 실은 묶음이 깨진 경우 — 통과를 지어내지 않는다).
      Future<String> bent(String key) async {
        final String text = await _disk(key);
        return key.endsWith('/gv03_exposure_gate.json')
            ? text.replaceFirst(
                '"expected_exposure": 1.0',
                '"expected_exposure": 0.9',
              )
            : text;
      }

      final OperatorRuntime r = OperatorRuntime(
        files: files,
        clock: clock,
        vault: MemorySecretVault(),
        kisHttp: http.Client(),
        golden: OperatorGolden(bent, clock: clock, isolate: false),
      )..view.value = viewOf(files.sim);
      final ActionResult res = await actions(r)
          .run(SettingsActionId.selftestGoldenRun);
      expect(res.level, UiLevel.act);
      expect(res.headline, GoldenSelfTestTexts.actHeadline);
      expect(res.reasonCode, isNull);
      final row = files.sim
          .select(
            "SELECT matched, action_taken, discrepancies FROM reconciliation_log WHERE recon_id GLOB 'gv-*'",
          )
          .single;
      expect(row['action_taken'], kGoldenFailed);
      expect(row['matched'], 0);
      final List<Object?> failed =
          (jsonDecode(row['discrepancies'] as String)
                  as Map<String, Object?>)['failed']!
              as List<Object?>;
      expect(failed, hasLength(1));
      expect(failed.single, startsWith('GV-3 '));
      final DiagnosticsScreenVm vm = await OperatorSettingsRepository(r)
          .diagnosticsScreen();
      final int m = kDeviceGoldenSuite.caseCount(disk);
      expect(vm.golden.statusLabel, GoldenSelfTestTexts.failed);
      expect(vm.golden.level, UiLevel.act);
      expect(vm.golden.summaryText, '통과 ${m - 1}/전체 $m');
    });

    test('🔴 골든 없음(플랫폼 밖) = 판정 보류 · 버튼 부재 · 동작 = 구현 없음', () async {
      final OperatorRuntime r = rt(golden: false);
      final DiagnosticsScreenVm vm = await OperatorSettingsRepository(r)
          .diagnosticsScreen();
      expect(vm.golden.statusLabel, GoldenSelfTestTexts.pending);
      expect(vm.golden.runAction, isNull);
      await expectLater(
        actions(r).run(SettingsActionId.selftestGoldenRun),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('🔴 기록 없음 = «아직 실행하지 않았습니다» + 버튼 → 실행 = 엔진 결과 문장 · 화면 원장에 기록 → «통과» · «전량 통과» · 마지막 실행 · 스트림이 다시 낸다', () async {
      final OperatorRuntime r = rt();
      final List<DiagnosticsScreenVm> got = <DiagnosticsScreenVm>[];
      final StreamSubscription<DiagnosticsScreenVm> sub =
          OperatorSettingsRepository(r)
              .watchDiagnosticsScreen()
              .listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(got.last.golden.statusLabel, GoldenSelfTestTexts.never);
      final SettingsActionCall? call = got.last.golden.runAction;
      expect(call?.id, SettingsActionId.selftestGoldenRun);
      expect(call?.args, isEmpty);
      await expectLater(
        actions(r).run(
          SettingsActionId.selftestGoldenRun,
          args: <String, String>{'x': '1'},
        ),
        throwsArgumentError,
      );
      final ActionResult res = await actions(r)
          .run(SettingsActionId.selftestGoldenRun);
      expect(res.level, UiLevel.ok);
      expect(res.headline, GoldenSelfTestTexts.okHeadline);
      expect(res.reasonCode, isNull);
      expect(_goldenRows(files.sim), 1);
      await until(
        () => got.last.golden.statusLabel == GoldenSelfTestTexts.passed,
      );
      expect(got.last.golden.level, UiLevel.ok);
      expect(got.last.golden.summaryText, GoldenSelfTestTexts.passedSummary);
      expect(got.last.golden.lastRunText, startsWith('마지막 실행 11-19 '));
      expect(got.last.golden.runAction?.id, SettingsActionId.selftestGoldenRun);
      expect(
        got.any(
          (DiagnosticsScreenVm v) =>
              v.golden.statusLabel == GoldenSelfTestTexts.running,
        ),
        isTrue,
        reason: '«실행 중» 도 한 번 낸다(장부 밖 사실)',
      );
    });

    test('화면 상태 없음 = 오류(기록 0)', () async {
      final OperatorRuntime r = rt()..view.value = null;
      await expectLater(
        actions(r).run(SettingsActionId.selftestGoldenRun),
        throwsStateError,
      );
      expect(_goldenRows(files.sim), 0);
    });
  });

  group('O-04 ④', () {
    final List<BiometricOutcome> answers = <BiometricOutcome>[];
    OperatorRuntime rt({bool golden = true}) => OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: _dev,
      trusted: _trusted,
      biometricSign: () async => answers.removeAt(0),
      golden: golden
          ? OperatorGolden(_disk, clock: clock, isolate: false)
          : null,
    );

    void pledgeAndSign() {
      expect(
        SqliteOnboardingStore(
          files.sim,
          clock: clock,
        ).selectOperatingMode(OperatingMode.autoTrade).ok,
        isTrue,
      );
      expect(
        SqlitePledgeStore(files.sim, clock: clock, trusted: _trusted)
            .writeFirst(
              commandId: 'cmd-pledge',
              payloadDigest: 'd',
              sentences: const <String>['가', '나', '다'],
              decisionId: 'cmd-pledge',
            )
            .executed,
        isTrue,
      );
    }

    test(
      '🔴 골든 없음 = ④ 원천 없음(UNKNOWN 게이트 · 칸 없음) · 있으면 «통과 0/전체 m» · ③ 전 = 차례 게이트',
      () async {
        pledgeAndSign();
        final OnboardingFinishVm none = await OperatorOnboardingRepository(
          rt(golden: false),
        ).watchFinish().first;
        expect(none.stages[3].gate?.state, GateState.unknown);
        expect(none.stages[3].slotId, isNull);
        // 첫 방출 = 장부 감시(자산 전 · 원천 없음) → 자산을 읽은 뒤 다시 낸다.
        final OnboardingFinishVm some = await OperatorOnboardingRepository(rt())
            .watchFinish()
            .firstWhere((OnboardingFinishVm v) => v.stages[3].lines.isNotEmpty);
        expect(some.stages[3].lines, <String>[
          '통과 0/전체 ${kDeviceGoldenSuite.caseCount(disk)}',
        ]);
        expect(some.stages[3].slotId, isNull, reason: '③ 이 먼저');
        expect(some.stages[3].gate?.state, isNot(GateState.unknown));
      },
    );

    test(
      '🔴 ③ 뒤 ④ 칸(SELFTEST_RUN) → 칸 실행 = sim 기록 → ④ 확인됨 · 칸 닫힘(실제 시간)',
      () async {
        pledgeAndSign();
        final OperatorRuntime r = rt();
        answers.add(BiometricOutcome.ok);
        await OperatorBiometricSign(r, random: Random(3)).sign();
        final List<OnboardingFinishVm> got = <OnboardingFinishVm>[];
        final StreamSubscription<OnboardingFinishVm> sub =
            OperatorOnboardingRepository(r).watchFinish().listen(got.add);
        addTearDown(sub.cancel);
        await until(() => got.isNotEmpty && got.last.stages[3].slotId != null);
        expect(got.last.stages[2].state, StepState.verified);
        expect(got.last.stages[3].slotId, OnboardingSlotIds.selftestRun);
        final Widget field = operatorSlotBuilder(r)(
          OnboardingSlotIds.selftestRun,
        );
        expect(field, isA<GoldenSelfTestField>());
        expect(
          await (field as GoldenSelfTestField).run(),
          GoldenSelfTestTexts.okHeadline,
        );
        expect(_goldenRows(files.sim), 1);
        await until(() => got.last.stages[3].state == StepState.verified);
        final int m = kDeviceGoldenSuite.caseCount(disk);
        expect(got.last.stages[3].lines, <String>['통과 $m/전체 $m']);
        expect(got.last.stages[3].slotId, isNull);
      },
    );

    test('골든 없음 = ④ 칸 부재(자리 크기 0)', () {
      final Widget w = operatorSlotBuilder(rt(golden: false))(
        OnboardingSlotIds.selftestRun,
      );
      expect(w, isA<SizedBox>());
    });
  });
}
