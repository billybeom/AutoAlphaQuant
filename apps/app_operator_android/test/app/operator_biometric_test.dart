// E11p4j — O-04 ③ 생체 서명 operator 판(설계 13 §8 R159) — 실 SQLite(sim 원장) · 엔진 저장소 · 결과 = 엔진 문장.

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_biometric.dart';
import 'package:app_operator_android/app/operator_onboarding.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        BiometricSignTexts,
        Pledge,
        TrustedClock,
        biometricSignDigest,
        kBiometricSignKind;
import 'package:data_sync/data_sync.dart'
    show SqliteOnboardingStore, SqlitePledgeStore;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

final _Trusted _trusted = _Trusted(DateTime.utc(2026, 11, 19, 0, 30));

class _Trusted implements TrustedClock {
  const _Trusted(this.at);
  final DateTime at;
  @override
  DateTime? trustedNowUtc() => at;
}

Future<void> until(bool Function() ok) async {
  for (int i = 0; i < 300 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue);
}

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late List<BiometricOutcome> answers;
  late int asked;
  late List<BiometricPurpose> purposes;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 19, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
    answers = <BiometricOutcome>[];
    asked = 0;
    purposes = <BiometricPurpose>[];
  });
  tearDown(() => files.close());

  Future<BiometricOutcome> ask(BiometricPurpose p) async {
    asked++;
    purposes.add(p);
    return answers.removeAt(0);
  }

  OperatorRuntime rt({String? deviceId = _dev, bool platform = true}) =>
      OperatorRuntime(
        files: files,
        clock: clock,
        deviceId: deviceId,
        trusted: _trusted,
        biometricSign: platform ? ask : null,
      );

  OperatorBiometricSign bio({String? deviceId = _dev, bool platform = true}) =>
      OperatorBiometricSign(
        rt(deviceId: deviceId, platform: platform),
        random: Random(3),
      );

  Pledge writePledge() {
    final SqlitePledgeStore s = SqlitePledgeStore(
      files.sim,
      clock: clock,
      trusted: _trusted,
    );
    expect(
      s
          .writeFirst(
            commandId: 'cmd-pledge',
            payloadDigest: 'd',
            sentences: const <String>['가', '나', '다'],
            decisionId: 'cmd-pledge',
          )
          .executed,
      isTrue,
    );
    return s.currentPledge()!;
  }

  int signs() =>
      files.sim.select(
            'SELECT COUNT(*) AS n FROM command_inbox WHERE kind = ?',
            <Object?>[kBiometricSignKind],
          ).first['n']
          as int;

  test(
    '🔴 사실 — 기기 id 없음 = null(원천 없음) · 서약 없음 = false · 판 있고 서명 전 = false',
    () {
      expect(bio(deviceId: null).fact(), isNull);
      expect(bio().fact(), isFalse);
      writePledge();
      expect(bio().fact(), isFalse);
      expect(bio(deviceId: null).fact(), isNull);
    },
  );

  test(
    '🔴 서명 = 생체 확인 OK 일 때만 한 번 적는다(지문 = 판 · 문장 · 기기 · 저널 id = 서약 판) · 사실 참',
    () async {
      final Pledge p = writePledge();
      answers = <BiometricOutcome>[BiometricOutcome.ok, BiometricOutcome.ok];
      expect(await bio().sign(), BiometricSignTexts.signed);
      expect(signs(), 1);
      final row = files.sim.select(
        'SELECT decision_id, payload_digest, state FROM command_inbox WHERE kind = ?',
        <Object?>[kBiometricSignKind],
      ).single;
      expect(row['decision_id'], 'PL-1');
      expect(
        row['payload_digest'],
        biometricSignDigest(pledge: p, deviceId: _dev),
      );
      expect(row['state'], 'EXECUTED');
      expect(bio().fact(), isTrue);
      // 다른 기기 = 이 서명이 아니다.
      expect(
        OperatorBiometricSign(rt(deviceId: 'other-device')).fact(),
        isFalse,
      );
      // 두 번째 OK = 효과 0.
      expect(await bio().sign(), BiometricSignTexts.signed);
      expect(signs(), 1);
      // 🆕 미결 243 ⓑ(R276 · K350) — 서약 글자 = 서약 목적에만.
      expect(purposes, <BiometricPurpose>[
        BiometricPurpose.pledgeSign,
        BiometricPurpose.pledgeSign,
      ]);
    },
  );

  test('🔴 취소 · 할 수 없음 = 적지 않는다 · 엔진 문장 · 다시 누를 수 있다', () async {
    writePledge();
    answers = <BiometricOutcome>[
      BiometricOutcome.canceled,
      BiometricOutcome.unavailable,
    ];
    expect(await bio().sign(), BiometricSignTexts.canceled);
    expect(await bio().sign(), BiometricSignTexts.unavailable);
    expect(signs(), 0);
    expect(bio().fact(), isFalse);
  });

  test(
    '🔴 서약 없음 = 생체를 묻지 않는다(② 가 먼저) · 플랫폼 · 기기 id 없음 = 할 수 없음(묻지 않는다)',
    () async {
      expect(await bio().sign(), BiometricSignTexts.noPledge);
      expect(asked, 0);
      writePledge();
      expect(await bio(platform: false).sign(), BiometricSignTexts.unavailable);
      expect(await bio(deviceId: null).sign(), BiometricSignTexts.unavailable);
      expect(asked, 0);
      expect(signs(), 0);
    },
  );

  test(
    '🔴 O-04 ③ — 서약 뒤 칸이 열리고 · 서명하면 확인됨 · 칸 닫힘(실제 시간) · 기기 id 없음 = 원천 없음 게이트',
    () async {
      expect(
        SqliteOnboardingStore(
          files.sim,
          clock: clock,
        ).selectOperatingMode(OperatingMode.autoTrade).ok,
        isTrue,
      );
      writePledge();
      final OnboardingFinishVm noId = await OperatorOnboardingRepository(
        rt(deviceId: null),
      ).watchFinish().first;
      expect(noId.stages[2].slotId, isNull);
      expect(noId.stages[2].gate?.state, GateState.unknown);
      final List<OnboardingFinishVm> got = <OnboardingFinishVm>[];
      final StreamSubscription<OnboardingFinishVm> sub =
          OperatorOnboardingRepository(rt()).watchFinish().listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(got.last.stages[1].state, StepState.verified);
      expect(got.last.stages[2].slotId, OnboardingSlotIds.biometricSign);
      expect(got.last.stages[2].gate, isNull);
      answers = <BiometricOutcome>[BiometricOutcome.ok];
      await bio().sign();
      await until(() => got.last.stages[2].state == StepState.verified);
      expect(got.last.stages[2].slotId, isNull);
    },
  );
}
