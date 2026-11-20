// E11q-c1 — M5-11 simToAuto 위저드 operator 판(설계 13 §8 R191 · 01 §35 K167~K176 · 미결 207) — 실 SQLite(sim · live 원장).
//
// 🔴 읽기 = 모의 파일(+ 실전 파일) → 엔진 VM · 동작 뒤 다시 낸다 · 동작 4 = 엔진 저장 · 결과 = 엔진 글자 ·
//    세션 시작 = 생체 → 엔진 사전 판정 → 통과 뒤에만 실전 파일 · 신뢰 시각 모름 = `SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE`(쓰기 0) ·
//    확정 = 엔진 1단계 관문(조회 포트 0 → 쓰기 0) · args 꼴이 틀리면 [ArgumentError].

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_operator_android/app/operator_handover.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show
        KisCredentials,
        KisEnvironment,
        KisKeySet,
        KisRateGate,
        KisRestClient,
        KisTokenStore,
        deleteKisCredentials,
        storeKisCredentials;
import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        HandoverSessionCodes,
        HandoverWizardTexts,
        JobRunEntry,
        JobRunStatus,
        LiveObservationConfig,
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
        RuleChangeType,
        SimToAutoCodes,
        SimToAutoCommitCodes,
        TierBCard,
        TrustedClock,
        WatchdogRemote,
        kHandoverCancelledHeadline,
        kNoApprovedConfig,
        kSimToAutoWatchdogPrepareFailed,
        kSimToAutoWatchdogPrepareFailedHeadline,
        simToAutoCommitHeadline;
import 'package:core_engine/testing.dart'
    show FakeWatchdogRemote, MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        SqliteConfigVersionStore,
        SqliteJobRunLog,
        SqliteCredentialRegistry,
        SqliteOnboardingStore,
        SqliteRuleChangeStore;
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' show MockClient;
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

String _iso(DateTime t) => t.toUtc().toIso8601String();

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

final P0sHumanInputs _inputs = P0sHumanInputs(
  aSymbol: '229200',
  accountByStrategy: _accounts,
);

/// 12-22 ~ 01-07 = 10세션(12-25 · 12-31 · 01-01 휴장).
const List<String> _ten = <String>[
  '2026-12-22',
  '2026-12-23',
  '2026-12-24',
  '2026-12-28',
  '2026-12-29',
  '2026-12-30',
  '2027-01-04',
  '2027-01-05',
  '2027-01-06',
  '2027-01-07',
];

/// 판정 = 01-08(금) 12:00.
final DateTime _now = _k('2027-01-08', 12);

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;
  late String hash;

  Database sim() => files.sim;

  /// SAF-405 첫 승인(규칙 변경 요청 → 냉각 30일 → 승인 · 엔진 저장) — 신뢰 시각을 돌려 놓는다.
  void approveConfig() {
    final DateTime? keep = trusted.at;
    final SqliteRuleChangeStore rc = SqliteRuleChangeStore(
      sim(),
      clock: clock,
      trusted: trusted,
    );
    trusted.at = _k('2026-12-01', 9);
    expect(
      rc
          .requestWithJournal(
            commandId: 'rq-1',
            payloadDigest: 'dg',
            changeType: RuleChangeType.strategyRule,
            hashBefore: kNoApprovedConfig,
            hashAfter: hash,
            reason: '첫 승인',
            rollbackMethod: '이전 설정으로',
            journalId: 'J-RC1',
            rationaleBefore: '모의 체험 결과',
            expectedOutcome: '실전 기동 조건',
            ruleCited: '04 §1 SAF-405',
          )
          .executed,
      isTrue,
    );
    trusted.at = _k('2027-01-02', 9);
    expect(
      rc
          .approve(
            commandId: 'ap-1',
            payloadDigest: 'dg',
            requestId: 'RC-J-RC1',
            goldenChanged: false,
            approver: '본인',
            thirdPartyNotified: true,
          )
          .executed,
      isTrue,
    );
    trusted.at = keep;
  }

  /// 온보딩(운영 방식 · 모의 개시 · 드라이런 시작) → 체험 5항목 기록 — 엔진이 «체험 완료»로 판정할 원 기록.
  Future<void> trialDone() async {
    clock.now = _k('2026-12-21', 15, 30);
    final SqliteOnboardingStore s = SqliteOnboardingStore(sim(), clock: clock);
    expect(s.selectOperatingMode(OperatingMode.autoTrade).ok, isTrue);
    expect(
      s
          .declareSimOpening(
            SelfReportBalance(
              asOfTradeDate: const TradeDate('2026-12-21'),
              purpose: SelfReportPurpose.simOpening,
              sessionStartedAt: clock.nowUtc(),
              lines: const <SelfReportLine>[],
              cashKrw: Decimal.parse('10000000'),
              accountAlias: 'general',
              declaredComplete: true,
              context: const CommandContext(
                runMode: RunMode.simInternal,
                operatingMode: OperatingMode.autoTrade,
                leaseEpoch: 0,
                deviceId: 'dev-1',
              ),
            ),
            accountByStrategy: _accounts,
            configHash: hash,
          )
          .ok,
      isTrue,
    );
    expect(
      s
          .dryRunStart(
            card: const TierBCard(
              b1R12mFloor: -0.15,
              b2DdFloor: -0.34,
              b3TuwMonths: 31,
            ),
          )
          .ok,
      isTrue,
    );
    for (final String d in _ten) {
      await SqliteJobRunLog(sim()).record(
        JobRunEntry(
          rid: 'sim-auto-kr_order-$d-SUCCESS',
          checkName: 'sim-auto-kr_order',
          sessionDay: TradeDate(d),
          startedAtUtc: _k(d, 9, 10),
          finishedAtUtc: _k(d, 9, 11),
          status: JobRunStatus.success,
        ),
      );
    }
    sim().execute(
      'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
      "VALUES ('RR-1', ?, ?, 1, 'NORMAL', 'R8', '{}', NULL)",
      <Object?>[_iso(_k('2026-12-24', 7)), _iso(_k('2026-12-24', 7, 5))],
    );
    for (final (String id, String kind, DateTime at)
        in <(String, String, DateTime)>[
          ('K1', 'ACTIVATED', _k('2026-12-24', 10)),
          ('K2', 'CHECKLIST_CONFIRMED', _k('2026-12-24', 10, 5)),
          ('K3', 'RESUMED', _k('2026-12-28', 11)),
        ]) {
      sim().execute(
        'INSERT INTO kill_switch_event (event_id, occurred_at, kind, channel, decision_id, summary) '
        "VALUES (?, ?, ?, 'app', ?, '{}')",
        <Object?>[id, _iso(at), kind, kind == 'ACTIVATED' ? null : 'D-$id'],
      );
    }
    sim().execute(
      'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
      "weights_before, weights_after, config_hash, created_at) VALUES ('R1', '2026-12-30', 'SIM_INTERNAL', "
      "'MONTHLY_REGULAR', 'D-R1', '{}', '[]', '[]', ?, ?)",
      <Object?>[hash, _iso(_k('2027-01-04', 8))],
    );
    clock.now = _now;
  }

  setUp(() {
    clock = FakeClock(_now);
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(_now);
    hash = SqliteConfigVersionStore(
      files.sim,
      clock: clock,
    ).register(P0sOpsConfig.of(_inputs).content());
  });
  tearDown(() => files.close());

  bool liveFile() =>
      File('${files.directory}/${LedgerFile.live.fileName}').existsSync();

  OperatorRuntime rt({
    bool withTrusted = true,
    bool observation = true,
    Future<BiometricOutcome> Function()? bio,
    bool noBio = false,
    String? device = 'dev-1',
    MemorySecretVault? vault,
    WatchdogRemote? remote,
  }) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      trusted: withTrusted ? trusted : null,
      deviceId: device,
      vault: vault,
      watchdogRemote: remote,
      biometricSign: noBio ? null : (bio ?? () async => BiometricOutcome.ok),
      liveObservation: observation
          ? LiveObservationConfig(requiredTradingDays: 2)
          : null,
    );
    r.view.value = OperatorView(
      db: files.sim,
      flags: FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        configHash: hash,
      ),
    );
    return r;
  }

  OperatorHandover handover(OperatorRuntime r, {bool? keys = true}) =>
      OperatorHandover(
        r,
        goldenPassed: () => true,
        liveKeysVerified: () => keys,
      );

  Future<HandoverWizardVm> wizard(
    OperatorHandover h,
    OperatorRuntime r, {
    bool canAct = true,
  }) => OperatorHandoverRepository(r, h, canAct: canAct).watchWizard().first;

  test('관찰 설정 없음 = 오류(지어내지 않는다) · 화면 상태 없음 = 오류', () async {
    final OperatorRuntime r = rt(observation: false);
    await expectLater(
      OperatorHandoverRepository(
        r,
        handover(r),
        canAct: true,
      ).watchWizard().first,
      throwsA(isA<StateError>()),
    );
    final OperatorRuntime r2 = rt()..view.value = null;
    await expectLater(
      OperatorHandoverRepository(
        r2,
        handover(r2),
        canAct: true,
      ).watchWizard().first,
      throwsA(isA<StateError>()),
    );
  });

  test('기본 원천 — 실전 키 = 아직 · 골든 = 기록 없음 → S2 · S3 «아직 확인 전» · 시작 0', () async {
    await trialDone();
    final OperatorRuntime r = rt();
    final HandoverWizardVm vm = await wizard(OperatorHandover(r), r);
    expect(vm.rows[1].step.stateLabel, '아직 확인 전');
    expect(vm.rows[2].step.stateLabel, '아직 확인 전');
    expect(vm.rows[5].actions, isEmpty);
    expect(vm.rows[2].link?.deepLink, AppRoutes.settingsCredentials);
  });

  test('🆕 R196(207 ⓑ) S3 = 대응표가 쓰는 세트의 조회 검증 기록(모의 파일) — 다 OK 통과 · 거절 = 막힘 · 대응표 밖 세트 = 판정 밖', () async {
    await trialDone();
    final OperatorRuntime r = rt();
    final OperatorHandover h = OperatorHandover(r, goldenPassed: () => true);
    final SqliteCredentialRegistry reg = SqliteCredentialRegistry(
      sim(),
      clock: clock,
    );
    void rec(String alias, String kind, {required bool passed}) =>
        reg.recordVerification(
          alias: alias,
          kind: kind,
          keystoreRef: alias.replaceAll('_', '.'),
          passed: passed,
        );
    // 이 시험의 대응표 = 위탁 · 연금저축뿐 → 필요한 세트 = KIS_LIVE 하나(ISA 기록은 판정 밖).
    HandoverWizardVm vm = await wizard(h, r);
    expect(vm.rows[2].step.stateLabel, '아직 확인 전');
    rec('kis_isa', 'KIS_ISA', passed: true);
    vm = await wizard(h, r);
    expect(vm.rows[2].step.stateLabel, '아직 확인 전');
    rec('kis_live', 'KIS_LIVE', passed: true);
    vm = await wizard(h, r);
    expect(
      (vm.rows[2].step.state, vm.rows[2].step.stateLabel, vm.rows[2].link),
      (GateState.pass, '실전 키 조회 확인', null),
    );
    rec('kis_live', 'KIS_LIVE', passed: false);
    vm = await wizard(h, r);
    expect(
      (vm.rows[2].step.state, vm.rows[2].step.blockedReasonCode),
      (GateState.block, SimToAutoCodes.liveKeysFailed),
    );
    expect(vm.rows[2].link?.deepLink, AppRoutes.settingsCredentials);
  });

  test(
    'S5 고르기 → 모의 원장 → 다시 낸 VM 에 시작 자리 · 결과 = 엔진 글자 · args 꼴 틀림 = ArgumentError',
    () async {
      await trialDone();
      final OperatorRuntime r = rt();
      final OperatorHandover h = handover(r);
      HandoverWizardVm vm = await wizard(h, r);
      expect(vm.rows[4].actions, hasLength(2));
      expect(vm.rows[5].actions, isEmpty);
      expect(vm.noticeText, HandoverWizardTexts.configNotApproved);
      final ActionResult res = await h.run(
        SettingsActionId.handoverSimLedgerFate,
        vm.rows[4].actions.first.args,
      );
      expect(
        (res.level, res.reasonCode, res.headline),
        (UiLevel.ok, null, HandoverWizardTexts.fateKept),
      );
      vm = await wizard(h, r);
      expect(vm.rows[4].step.state, GateState.pass);
      expect(vm.rows[4].actions, isEmpty);
      expect(
        vm.rows[5].actions.single.id,
        SettingsActionId.handoverSessionStart,
      );
      expect(
        () => h.run(
          SettingsActionId.handoverSimLedgerFate,
          const <String, String>{'fate': 'MAYBE'},
        ),
        throwsArgumentError,
      );
      expect(
        () => h.run(
          SettingsActionId.handoverSimLedgerFate,
          const <String, String>{'fate': 'KEEP', 'x': 'y'},
        ),
        throwsArgumentError,
      );
      expect(
        () =>
            h.run(SettingsActionId.selftestGoldenRun, const <String, String>{}),
        throwsArgumentError,
      );
    },
  );

  Future<OperatorHandover> chosen(
    OperatorRuntime r, {
    bool? keys = true,
  }) async {
    await trialDone();
    final OperatorHandover h = handover(r, keys: keys);
    await h.run(SettingsActionId.handoverSimLedgerFate, const <String, String>{
      'fate': 'KEEP',
    });
    return h;
  }

  const Map<String, String> start = <String, String>{'path': 'SIM_TO_AUTO'};

  for (final (String name, Future<BiometricOutcome> Function()? bio)
      in <(String, Future<BiometricOutcome> Function()?)>[
        ('생체 창구 없음', null),
        ('취소', () async => BiometricOutcome.canceled),
        ('할 수 없음', () async => BiometricOutcome.unavailable),
      ]) {
    test('🔴 시작 — $name = BIOMETRIC_UNAVAILABLE · 실전 파일 0', () async {
      final OperatorRuntime r = rt(noBio: bio == null, bio: bio);
      final OperatorHandover h = await chosen(r);
      final ActionResult res = await h.run(
        SettingsActionId.handoverSessionStart,
        start,
      );
      expect(
        (res.reasonCode, res.level),
        (HandoverSessionCodes.biometricUnavailable, UiLevel.blocked),
      );
      expect(liveFile(), isFalse);
    });
  }

  test('🔴 시작 — 신뢰 시각 모름 = 결과 원문 거부 · 실전 파일 0(K176 · 우회 0)', () async {
    final OperatorRuntime r = rt(withTrusted: false);
    final OperatorHandover h = await chosen(r);
    final ActionResult res = await h.run(
      SettingsActionId.handoverSessionStart,
      start,
    );
    expect(
      (res.reasonCode, res.level, res.headline),
      (
        SimToAutoCodes.trustedTimeUnavailable,
        UiLevel.watch,
        '시각을 확인할 수 없어 전환을 시작하지 않았습니다.',
      ),
    );
    expect(liveFile(), isFalse);
  });

  test(
    '시작 — 앞 단계(실전 키 «아직») = 단계 id 거부 · 실전 파일 0 · path 꼴 틀림 = ArgumentError',
    () async {
      final OperatorRuntime r = rt();
      final OperatorHandover h = await chosen(r, keys: null);
      final ActionResult res = await h.run(
        SettingsActionId.handoverSessionStart,
        start,
      );
      expect((res.reasonCode, res.level), ('SIM_TO_AUTO_S3', UiLevel.act));
      expect(liveFile(), isFalse);
      expect(
        () => h.run(
          SettingsActionId.handoverSessionStart,
          const <String, String>{'path': 'FRESH_AUTO'},
        ),
        throwsArgumentError,
      );
    },
  );

  test('시작 — 기기 id 없음 = StateError(사전 판정 통과 뒤 · 실전 파일 0)', () async {
    final OperatorRuntime r = rt(device: null);
    final OperatorHandover h = await chosen(r);
    await expectLater(
      h.run(SettingsActionId.handoverSessionStart, start),
      throwsA(isA<StateError>()),
    );
    expect(liveFile(), isFalse);
  });

  test('🔴 시작 성공 → 실전 파일 · 세션 1 → 냉각 VM(취소 · 시각 글자) → 확정 = 관문 거부(쓰기 0) → 취소 → 다시 시작 자리', () async {
    final OperatorRuntime r = rt();
    final OperatorHandover h = await chosen(r);
    expect(liveFile(), isFalse);
    final ActionResult res = await h.run(
      SettingsActionId.handoverSessionStart,
      start,
    );
    expect((res.reasonCode, res.level), (null, UiLevel.ok));
    expect(res.headline, startsWith('생체 확인 완료 — 24시간 냉각 뒤 2027-01-09 12:00부터'));
    expect(liveFile(), isTrue);
    final Database live = files.liveIfExists()!;
    final List<Map<String, Object?>> rows = <Map<String, Object?>>[
      for (final r in live.select(
        'SELECT handover_session_id, device_id, closed_at FROM handover_session',
      ))
        <String, Object?>{...r},
    ];
    expect(rows, hasLength(1));
    expect(
      (rows.single['device_id'], rows.single['closed_at']),
      ('dev-1', null),
    );
    final String sid = rows.single['handover_session_id']! as String;

    HandoverWizardVm vm = await wizard(h, r);
    expect(vm.rows[5].step.state, GateState.pass);
    expect(vm.rows[5].actions, isEmpty);
    expect(vm.rows[6].step.blockedReasonCode, SimToAutoCodes.cooling);
    expect(vm.rows[6].actions.single.args, <String, String>{
      'handover_session_id': sid,
    });
    expect(
      vm.coolingText,
      HandoverWizardTexts.coolingEnds(_k('2027-01-09', 12)),
    );

    // 확정 — 승인 config 없음 = `…_CONFIG_NOT_APPROVED`(R192 · SAF-405) → 첫 승인(요청 → 냉각 30일 → 승인) 뒤 고지 0 →
    //    냉각 중 = 재판정 거부 · 냉각 뒤 = 계좌 조회 0 → `…_ACCOUNT_PROBE_MISSING`(조회 포트 = 207 ⓖ) · 쓰기 0.
    final ActionResult na = await h.run(
      SettingsActionId.handoverCommit,
      <String, String>{'handover_session_id': sid},
    );
    expect(
      (na.reasonCode, na.level, na.headline),
      (
        SimToAutoCommitCodes.configNotApproved,
        UiLevel.blocked,
        simToAutoCommitHeadline(SimToAutoCommitCodes.configNotApproved),
      ),
    );
    expect(vm.noticeText, HandoverWizardTexts.configNotApproved);
    approveConfig();
    expect((await wizard(h, r)).noticeText, isNull);
    final ActionResult c = await h.run(
      SettingsActionId.handoverCommit,
      <String, String>{'handover_session_id': sid},
    );
    expect(
      (c.reasonCode, c.level, c.headline, c.handoffRoute),
      (
        SimToAutoCodes.cooling,
        UiLevel.watch,
        simToAutoCommitHeadline(SimToAutoCodes.cooling),
        null,
      ),
    );
    trusted.at = _k('2027-01-09', 13);
    final ActionResult p = await h.run(
      SettingsActionId.handoverCommit,
      <String, String>{'handover_session_id': sid},
    );
    expect(
      (p.reasonCode, p.level, p.handoffRoute),
      (SimToAutoCommitCodes.probeMissing, UiLevel.blocked, null),
    );
    expect(
      live.select('SELECT COUNT(*) AS n FROM mode_transition').first['n'],
      0,
    );
    expect(
      live.select('SELECT closed_at FROM handover_session').single['closed_at'],
      isNull,
    );
    trusted.at = _now;

    final ActionResult x = await h.run(
      SettingsActionId.handoverSessionCancel,
      <String, String>{'handover_session_id': sid},
    );
    expect((x.reasonCode, x.headline), (null, kHandoverCancelledHeadline));
    vm = await wizard(h, r);
    expect(vm.rows[6].actions, isEmpty);
    expect(vm.rows[5].actions.single.label, HandoverWizardTexts.start);
    // 같은 세션 다시 취소 = 닫힌 세션.
    final ActionResult again = await h.run(
      SettingsActionId.handoverSessionCancel,
      <String, String>{'handover_session_id': sid},
    );
    expect(
      (again.reasonCode, again.level),
      (HandoverSessionCodes.sessionInvalid, UiLevel.info),
    );
  });

  test('확정 — 신뢰 시각 모름 = 시각 거부 · 실전 파일 없음 · 세션 없음 = 세션 거부 · 쓰기 0', () async {
    final OperatorRuntime r = rt(withTrusted: false);
    final OperatorHandover h = await chosen(r);
    final ActionResult t = await h.run(
      SettingsActionId.handoverCommit,
      const <String, String>{'handover_session_id': 'HS-X'},
    );
    expect(t.reasonCode, SimToAutoCodes.trustedTimeUnavailable);
    final OperatorRuntime r2 = rt();
    final ActionResult s = await handover(r2).run(
      SettingsActionId.handoverCommit,
      const <String, String>{'handover_session_id': 'HS-X'},
    );
    expect(
      (s.reasonCode, s.level),
      (HandoverSessionCodes.sessionInvalid, UiLevel.info),
    );
    expect(liveFile(), isFalse);
    expect(
      () =>
          handover(r2)
              .run(SettingsActionId.handoverCommit, const <String, String>{}),
      throwsArgumentError,
    );
  });

  test('취소 — 실전 파일 없음 = HANDOVER_SESSION_INVALID(만들지 않는다)', () async {
    final OperatorRuntime r = rt();
    final ActionResult x = await handover(r).run(
      SettingsActionId.handoverSessionCancel,
      const <String, String>{'handover_session_id': 'HS-X'},
    );
    expect(x.reasonCode, HandoverSessionCodes.sessionInvalid);
    expect(liveFile(), isFalse);
  });

  test('쓰기 창구 없음 = 행 동작 0 · 동작 뒤 흐름이 다시 낸다', () async {
    await trialDone();
    final OperatorRuntime r = rt();
    final OperatorHandover h = handover(r);
    expect(
      (await wizard(
        h,
        r,
        canAct: false,
      )).rows.every((HandoverWizardStepRow x) => x.actions.isEmpty),
      isTrue,
    );
    final List<HandoverWizardVm> seen = <HandoverWizardVm>[];
    final StreamSubscription<HandoverWizardVm> sub = OperatorHandoverRepository(
      r,
      h,
      canAct: true,
      tick: const Duration(hours: 1),
    ).watchWizard().listen(seen.add);
    for (int i = 0; i < 300 && seen.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(seen.last.rows[4].actions, hasLength(2));
    await h.run(SettingsActionId.handoverSimLedgerFate, const <String, String>{
      'fate': 'DISCARD',
    });
    for (int i = 0; i < 300 && seen.last.rows[4].actions.isNotEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(seen.last.rows[4].step.stateLabel, '모의 기록을 지웁니다');
    await sub.cancel();
  });

  test('설정 동작 인스턴스 — handover 4 = 위저드 판으로 · 결과를 watch 로 다시 준다 · 판 없음 = UnsupportedError', () async {
    await trialDone();
    final OperatorRuntime r = rt();
    SettingsActions acts({OperatorHandover? h}) => OperatorSettingsActions(
      secrets: SecretHandoff(),
      vault: MemorySecretVault(),
      clientOf: (KisCredentials c) => KisRestClient(
        MockClient((http.Request _) async => http.Response('{}', 500)),
        c,
        environment: c.environment,
      ),
      clock: clock,
      handover: h,
    );
    final SettingsActions a = acts(h: handover(r));
    final ActionResult res = await a.run(
      SettingsActionId.handoverSimLedgerFate,
      args: const <String, String>{'fate': 'KEEP'},
    );
    expect(await a.watch(res.actionRunId).first, res);
    await expectLater(
      acts().run(
        SettingsActionId.handoverSimLedgerFate,
        args: const <String, String>{'fate': 'KEEP'},
      ),
      throwsA(isA<UnsupportedError>()),
    );
    for (final SettingsActionId id in kOperatorHandoverActions) {
      expect(id.wire, startsWith('HANDOVER_'));
    }
    expect(kOperatorHandoverActions, hasLength(4));
  });

  group('🆕 R202(207 ⓖ) 확정 배선 — 관문(조회 0) → 실전 조회(조회만) → 관문 → 오케스트레이터', () {
    late MemorySecretVault vault;
    late FakeWatchdogRemote remote;
    late List<http.Request> reqs;
    late int holdings;

    http.Response json(Object body) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      200,
      headers: <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );

    KisRestClient client(KisCredentials c, KisTokenStore t) => KisRestClient(
      MockClient((http.Request r) async {
        reqs.add(r);
        if (r.url.path == '/oauth2/tokenP') {
          return json(<String, Object>{
            'access_token': 'eyFAKE-TOKEN',
            'token_type': 'Bearer',
            'expires_in': 86400,
          });
        }
        if (r.url.path.endsWith('/inquire-daily-ccld')) {
          return json(<String, Object>{'rt_cd': '0', 'output1': <Object>[]});
        }
        return json(<String, Object>{
          'rt_cd': '0',
          'output1': <Object>[
            for (int i = 0; i < holdings; i++)
              <String, String>{'pdno': '00000$i', 'hldg_qty': '3'},
          ],
          'output2': <Object>[
            <String, String>{
              'prvs_rcdl_excc_amt': '1000000',
              'dnca_tot_amt': '1000000',
            },
          ],
        });
      }),
      c,
      environment: c.environment,
      tokens: t,
      sleep: (_) async {},
      gate: KisRateGate(Duration.zero, sleep: (_) async {}),
    );

    setUp(() async {
      vault = MemorySecretVault();
      remote = FakeWatchdogRemote();
      reqs = <http.Request>[];
      holdings = 0;
      await storeKisCredentials(
        vault,
        KisKeySet.live,
        KisCredentials(
          environment: KisEnvironment.live,
          appKey: 'PSTESTAPPKEY0000000000001',
          appSecret: 'TESTSECRETVALUEabcdefghijklmnop9876',
          accountNo: '87654321',
        ),
      );
    });

    /// 세션 열고 냉각 뒤(01-09 13:00)까지 — 승인 config 는 [approve] 일 때만.
    Future<(OperatorHandover, String)> opened({
      bool approve = true,
      bool withRemote = true,
    }) async {
      final OperatorRuntime r = rt(
        vault: vault,
        remote: withRemote ? remote : null,
      );
      await trialDone();
      final OperatorHandover h = OperatorHandover(
        r,
        goldenPassed: () => true,
        liveKeysVerified: () => true,
        clientOf: client,
      );
      await h.run(
        SettingsActionId.handoverSimLedgerFate,
        const <String, String>{'fate': 'KEEP'},
      );
      if (approve) approveConfig();
      final ActionResult s0 = await h.run(
        SettingsActionId.handoverSessionStart,
        const <String, String>{'path': 'SIM_TO_AUTO'},
      );
      expect(s0.reasonCode, isNull);
      final String sid =
          files
                  .liveIfExists()!
                  .select('SELECT handover_session_id FROM handover_session')
                  .single
                  .values
                  .single!
              as String;
      trusted.at = _k('2027-01-09', 13);
      return (h, sid);
    }

    int liveRuns() =>
        files
                .liveIfExists()!
                .select(
                  "SELECT COUNT(*) AS n FROM mode_transition WHERE axis = 'RUN_MODE'",
                )
                .first['n']!
            as int;

    test('🔴 통과 = 새 감시 체크 → 실전 커밋(live × dryRun) → 모의 CLOSE → 운영 화면으로 · 조회 TR 만 · 토큰 1회 · 연금저축 = 상품코드 22', () async {
      final (OperatorHandover h, String sid) = await opened();
      final ActionResult r = await h.run(
        SettingsActionId.handoverCommit,
        <String, String>{'handover_session_id': sid},
      );
      expect(
        (r.reasonCode, r.level, r.handoffRoute),
        (null, UiLevel.ok, AppRoutes.settingsOperations),
      );
      expect(r.headline, startsWith('실전 자동 매매로 옮겼습니다 — 계좌 2곳'));
      expect(liveRuns(), 1);
      expect(
        files
            .liveIfExists()!
            .select(
              "SELECT exec_policy FROM mode_transition WHERE axis = 'RUN_MODE'",
            )
            .single
            .values
            .single,
        'DRY_RUN',
      );
      expect(
        files.sim
            .select(
              "SELECT COUNT(*) AS n FROM mode_transition WHERE axis = 'CLOSE'",
            )
            .first['n'],
        1,
      );
      expect(
        remote.calls.where((String c) => c.startsWith('ensure:live-auto-')),
        isNotEmpty,
      );
      // 🔴 조회만 — 주문 · 정정 · 취소 TR 0 · 토큰 = 같은 앱키 한 번.
      final Set<String?> trs = <String?>{
        for (final http.Request q in reqs) q.headers['tr_id'],
      }..remove(null);
      expect(trs, <String>{'TTTC8434R', 'TTTC0081R'});
      final List<http.Request> tokens = reqs
          .where((http.Request q) => q.url.path == '/oauth2/tokenP')
          .toList();
      expect(tokens, hasLength(1));
      final Set<String?> products = reqs
          .where((http.Request q) => q.url.path.endsWith('/inquire-balance'))
          .map((http.Request q) => q.url.queryParameters['ACNT_PRDT_CD'])
          .toSet();
      expect(products, <String>{'01', '22'});
      expect(
        <String>{for (final http.Request q in reqs) q.url.host},
        <String>{'openapi.koreainvestment.com'},
      );
    });

    test('🔴 보유가 있으면 = 관문 거부 원문 · 바깥 감시 0 · 실전 쓰기 0', () async {
      holdings = 1;
      final (OperatorHandover h, String sid) = await opened();
      final ActionResult r = await h.run(
        SettingsActionId.handoverCommit,
        <String, String>{'handover_session_id': sid},
      );
      expect(
        (r.reasonCode, r.headline),
        (
          SimToAutoCommitCodes.holdingsNotZero,
          simToAutoCommitHeadline(SimToAutoCommitCodes.holdingsNotZero),
        ),
      );
      expect(remote.calls, isEmpty);
      expect(liveRuns(), 0);
    });

    test('🔴 승인 config 없음 = 조회 · 감시 전에 거부(네트워크 0)', () async {
      final (OperatorHandover h, String sid) = await opened(approve: false);
      final ActionResult r = await h.run(
        SettingsActionId.handoverCommit,
        <String, String>{'handover_session_id': sid},
      );
      expect(r.reasonCode, SimToAutoCommitCodes.configNotApproved);
      expect(reqs, isEmpty);
      expect(remote.calls, isEmpty);
    });

    test(
      '감시 원격 없음 = 준비 실패 원문(쓰기 0) · 금고에 키 없음 = 조회 0 → PROBE_MISSING',
      () async {
        final (OperatorHandover h, String sid) = await opened(
          withRemote: false,
        );
        final ActionResult r = await h.run(
          SettingsActionId.handoverCommit,
          <String, String>{'handover_session_id': sid},
        );
        expect(
          (r.reasonCode, r.headline),
          (
            kSimToAutoWatchdogPrepareFailed,
            kSimToAutoWatchdogPrepareFailedHeadline,
          ),
        );
        expect(liveRuns(), 0);
        await deleteKisCredentials(vault, KisKeySet.live);
        reqs.clear();
        final ActionResult m = await h.run(
          SettingsActionId.handoverCommit,
          <String, String>{'handover_session_id': sid},
        );
        expect(m.reasonCode, SimToAutoCommitCodes.probeMissing);
        expect(reqs, isEmpty);
      },
    );

    test('바깥 감시 준비가 실패하면 = 커밋 0 · 엔진 원문', () async {
      remote.failOn[('ensure', '*')] = Exception('down');
      final (OperatorHandover h, String sid) = await opened();
      final ActionResult r = await h.run(
        SettingsActionId.handoverCommit,
        <String, String>{'handover_session_id': sid},
      );
      expect(r.reasonCode, kSimToAutoWatchdogPrepareFailed);
      expect(liveRuns(), 0);
    });
  });
}
