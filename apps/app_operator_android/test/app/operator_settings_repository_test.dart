// E11p3d-5d 설정 읽기 모델 operator 판 — M9 S02 키 목록(설계 13 §8 R129) — 메모리 금고 · 실 SQLite(sim) · 실제 시간(갱신 훅).
// 🆕 E11p3d-5e — M9 S01 설정 홈(R134) — 사실 = 화면 상태 · 키 목록 · 월 납입 운영값 · 레지스트리 본문 유무.

import 'dart:async';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_repository.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisEnvironment, KisKeySet, storeKisCredentials;
import 'package:core_engine/core_engine.dart'
    show P0sHumanInputs, P0sOpsConfig, P0sStrategyIds;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        SqliteConfigVersionStore,
        p0sHumanDecisionFromText,
        SqliteOnboardingProgressStore,
        SqliteOnboardingStore;
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AccountMappingVm,
        AccountRow,
        AppRoutes,
        CommandContext,
        CredentialCardVm,
        CredentialListVm,
        FeatureFlags,
        OnboardingResultCodes,
        OnboardingSlotIds,
        OperatingMode,
        OperatingParamKeys,
        RunMode,
        SettingsCard,
        SettingsGroup,
        SelfReportBalance,
        SelfReportPurpose,
        SettingsHomeVm,
        SleeveMappingRow,
        StepState,
        TradeDate,
        UiLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late MemorySecretVault vault;
  late OperatorRuntime rt;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 1, 9, 0));
    files = openFiles(tempLedgerDir(), clock);
    vault = MemorySecretVault();
    rt = OperatorRuntime(files: files, clock: clock, vault: vault);
  });
  tearDown(() => files.close());

  Future<void> until(bool Function() ok) async {
    final Stopwatch w = Stopwatch()..start();
    while (!ok() && w.elapsed < const Duration(seconds: 5)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  SqliteOnboardingProgressStore progress() =>
      SqliteOnboardingProgressStore(files.sim, clock: clock);

  CredentialCardVm card(CredentialListVm v) => v.cards.single;

  test('🔴 금고 비었음 · 기록 없음 = 미등록(모의 = 필수 · 할 일) · 칸 + «검증 후 저장»', () async {
    final CredentialCardVm c = card(
      await OperatorSettingsRepository(rt).credentials(),
    );
    expect(
      (c.healthCode, c.level, c.requirementLabel),
      ('NOT_REGISTERED', UiLevel.act, '필수'),
    );
    expect(c.credentialSlotId, OnboardingSlotIds.secretKisMock);
    expect(c.verifyAction?.label, '검증 후 저장');
  });

  test('🔴 금고 저장 + o_02 통과 = 정상 · 칸 없음 · «다시 검증» · 마지막 검증 줄(KST)', () async {
    await storeKisCredentials(
      vault,
      KisKeySet.paper,
      KisCredentials(
        environment: KisEnvironment.mock,
        appKey: 'PSTESTAPPKEY0000000000001',
        appSecret: 'TESTSECRETVALUEabcdefghijklmnop9876',
        accountNo: '12345678',
      ),
    );
    progress().record('o_02', StepState.verified);
    final CredentialCardVm c = card(
      await OperatorSettingsRepository(rt).credentials(),
    );
    expect((c.healthCode, c.healthLabel, c.level), ('OK', '정상', UiLevel.ok));
    expect(c.credentialSlotId, isNull);
    expect(c.verifyAction?.label, '다시 검증');
    expect(c.lastVerifiedText, '마지막 검증 12-01 09:00 · 통과');
  });

  test('🔴 거절 기록 → 다시 낸다(진척 표 · 실제 갱신 훅) · 금고 없는 조립 = 저장 안 됨으로 본다', () async {
    final List<CredentialListVm> got = <CredentialListVm>[];
    final StreamSubscription<CredentialListVm> sub = OperatorSettingsRepository(
      rt,
    ).watchCredentials().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(card(got.last).healthCode, 'NOT_REGISTERED');
    progress().record(
      'o_02',
      StepState.failed,
      failureReasonCode: OnboardingResultCodes.credentialRejected,
    );
    await until(() => card(got.last).healthCode == 'INVALID');
    expect(
      card(got.last).lastVerifiedText,
      '마지막 검증 12-01 09:00 · 거절(CREDENTIAL_REJECTED)',
    );
    final CredentialCardVm noVault = card(
      await OperatorSettingsRepository(
        OperatorRuntime(files: files, clock: clock),
      ).credentials(),
    );
    expect(noVault.healthCode, 'INVALID');
  });

  test('🔴 실행 모드 = 화면 상태(없음 = 모의) · 화면 상태가 바뀌면 다시 낸다', () async {
    expect(
      card(await OperatorSettingsRepository(rt).credentials()).requirementLabel,
      '필수',
    );
    final List<CredentialListVm> got = <CredentialListVm>[];
    final StreamSubscription<CredentialListVm> sub = OperatorSettingsRepository(
      rt,
    ).watchCredentials().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    final int n = got.length;
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    clock.now = clock.now.add(const Duration(minutes: 1));
    rt.view.value = operatorViewOf(
      await bootEngine(files, clock: clock),
      files,
    );
    await until(() => got.length > n);
    expect(got.length, greaterThan(n));
  });

  // ── 🆕 R134 — S01 설정 홈 ──────────────────────────────────────────────

  OperatorView viewOf(
    Database db, {
    String hash = 'cfg_test',
    RunMode run = RunMode.simInternal,
    OperatingMode op = OperatingMode.autoTrade,
  }) => OperatorView(
    db: db,
    flags: FeatureFlags(
      satelliteEnabled: false,
      webViewerEnabled: false,
      calendarEnabled: false,
      runMode: run,
      operatingMode: op,
      configHash: hash,
    ),
  );

  void setContribution(Database db, int won) => db.execute(
    'INSERT INTO operating_param_log(param_key, value_text, changed_at, effective_from, action_run_id, device_id) '
    "VALUES (?, ?, ?, '2026-11-01', ?, 'test-device')",
    <Object?>[
      OperatingParamKeys.monthlyContribution,
      '$won',
      clock.nowUtc().toIso8601String(),
      'run-$won',
    ],
  );

  List<String> codes(SettingsHomeVm vm) => <String>[
    for (final SettingsGroup g in vm.groups)
      for (final SettingsCard c in g.cards) c.code,
  ];

  SettingsCard? cardOf(SettingsHomeVm vm, String code) {
    for (final SettingsGroup g in vm.groups) {
      for (final SettingsCard c in g.cards) {
        if (c.code == code) return c;
      }
    }
    return null;
  }

  bool onlyS02(String r) => r == AppRoutes.settingsCredentials;

  test('🔴 설정 홈 — 화면 상태 없음(온보딩 전) = 오류(지어내지 않는다)', () async {
    await expectLater(
      OperatorSettingsRepository(rt).watchHome(),
      emitsError(isA<StateError>()),
    );
  });

  test('🔴 설정 홈 = 엔진 VM — 칩 · 키(금고 비었음 = 미등록 ACT) · 운용 · 월 납입 기본값 · 전략 · 링크 = 본문 있는 화면만', () async {
    rt.view.value = viewOf(files.sim);
    final SettingsHomeVm vm = await OperatorSettingsRepository(
      rt,
      hasBody: onlyS02,
    ).home();
    expect(vm.statusChip.label, '모의 · 내부 가상 체결 · 자동 매매');
    expect(codes(vm), <String>[
      'SET_CREDENTIALS',
      'SET_OPERATIONS',
      'SET_CONTRIBUTION',
      'SET_ALLOCATION',
    ]);
    expect(
      cardOf(vm, 'SET_CREDENTIALS'),
      const SettingsCard(
        code: 'SET_CREDENTIALS',
        title: '증권사 키',
        level: UiLevel.act,
        statusLabel: '모의투자 미등록',
        attentionText: '1',
        route: AppRoutes.settingsCredentials,
      ),
    );
    expect(cardOf(vm, 'SET_OPERATIONS')?.statusLabel, '모의 · 자동 매매');
    expect(cardOf(vm, 'SET_CONTRIBUTION')?.statusLabel, '월 10만원');
    expect(
      (
        cardOf(vm, 'SET_ALLOCATION')?.statusLabel,
        cardOf(vm, 'SET_ALLOCATION')?.level,
      ),
      ('balanced(P0S)', UiLevel.ok),
    );
    expect(vm.asOf.label, '설정 기준 2026-12-01 09:00');
    // 기본 조립(본문 판정 없음) = 링크 0.
    final SettingsHomeVm bare = await OperatorSettingsRepository(rt).home();
    expect(
      bare.groups
          .expand((SettingsGroup g) => g.cards)
          .map((SettingsCard c) => c.route),
      everyElement(isNull),
    );
  });

  test('🔴 운영 설정 지문 없음 = 전략 카드 WATCH · 실전 · 투자 안내 = 칩 «골든벡터 판정 보류»', () async {
    rt.view.value = viewOf(
      files.sim,
      hash: '',
      run: RunMode.live,
      op: OperatingMode.advisory,
    );
    final SettingsHomeVm vm = await OperatorSettingsRepository(rt).home();
    expect(
      (
        cardOf(vm, 'SET_ALLOCATION')?.statusLabel,
        cardOf(vm, 'SET_ALLOCATION')?.level,
      ),
      ('운영 설정을 읽지 못했습니다', UiLevel.watch),
    );
    expect(
      (vm.statusChip.label, vm.statusChip.level),
      ('실전 · 투자 안내 · 골든벡터 판정 보류', UiLevel.watch),
    );
    expect(cardOf(vm, 'SET_OPERATIONS')?.statusLabel, '실전 · 투자 안내');
  });

  test('🔴 월 납입 읽기 실패 = 그 카드만 빠진다(설정 홈 전체를 막지 않는다)', () async {
    rt.view.value = viewOf(files.sim);
    files.sim.execute('DROP TABLE operating_param_log');
    final SettingsHomeVm vm = await OperatorSettingsRepository(rt).home();
    expect(cardOf(vm, 'SET_CONTRIBUTION'), isNull);
    expect(cardOf(vm, 'SET_CREDENTIALS'), isNotNull);
  });

  test(
    '🔴 다시 낸다 — 월 납입 기록(화면 상태 원장) · 키 검증 기록(sim 진척) · 같은 값은 다시 내지 않는다',
    () async {
      rt.view.value = viewOf(files.sim);
      final List<SettingsHomeVm> got = <SettingsHomeVm>[];
      final StreamSubscription<SettingsHomeVm> sub = OperatorSettingsRepository(
        rt,
      ).watchHome().listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(cardOf(got.last, 'SET_CONTRIBUTION')?.statusLabel, '월 10만원');
      setContribution(files.sim, 200000);
      await until(
        () => cardOf(got.last, 'SET_CONTRIBUTION')?.statusLabel == '월 20만원',
      );
      expect(cardOf(got.last, 'SET_CONTRIBUTION')?.statusLabel, '월 20만원');
      progress().record(
        'o_02',
        StepState.failed,
        failureReasonCode: OnboardingResultCodes.credentialRejected,
      );
      await until(
        () => cardOf(got.last, 'SET_CREDENTIALS')?.statusLabel == '모의투자 검증 실패',
      );
      expect(cardOf(got.last, 'SET_CREDENTIALS')?.statusLabel, '모의투자 검증 실패');
      final int n = got.length;
      // 다른 표 · 같은 값 = 다시 내지 않는다.
      progress().record(
        'o_02',
        StepState.failed,
        failureReasonCode: OnboardingResultCodes.credentialRejected,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(got.length, n);
    },
  );

  test('🔴 화면 상태가 바뀌면 월 납입 감시를 새 원장으로 옮긴다', () async {
    rt.view.value = viewOf(files.sim);
    final List<SettingsHomeVm> got = <SettingsHomeVm>[];
    final StreamSubscription<SettingsHomeVm> sub = OperatorSettingsRepository(
      rt,
    ).watchHome().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    final Database live = writeLiveMode(tempLedgerDir(), clock);
    addTearDown(live.close);
    rt.view.value = viewOf(live, run: RunMode.live);
    await until(() => got.last.statusChip.label.startsWith('실전'));
    expect(cardOf(got.last, 'SET_CONTRIBUTION')?.statusLabel, '월 10만원');
    setContribution(live, 300000);
    await until(
      () => cardOf(got.last, 'SET_CONTRIBUTION')?.statusLabel == '월 30만원',
    );
    expect(cardOf(got.last, 'SET_CONTRIBUTION')?.statusLabel, '월 30만원');
  });

  // ── 🆕 R151 — S03 계좌 · 매핑 ───────────────────────────────────────────

  Future<void> storePaper() => storeKisCredentials(
    vault,
    KisKeySet.paper,
    KisCredentials(
      environment: KisEnvironment.mock,
      appKey: 'PSTESTAPPKEY0000000000001',
      appSecret: 'TESTSECRETVALUEabcdefghijklmnop9876',
      accountNo: '12345678',
    ),
  );

  test(
    '🔴 계좌 — 화면 상태 없음 = 오류 · 금고 비었음 = 모의 «등록 전» · 운영 설정 없음 = 슬리브 셋 미지정',
    () async {
      await expectLater(
        OperatorSettingsRepository(rt).accountMapping(),
        throwsA(isA<StateError>()),
      );
      rt.view.value = viewOf(files.sim);
      final AccountMappingVm vm = await OperatorSettingsRepository(rt)
          .accountMapping();
      expect(vm.accounts.single.maskedNumberText, '등록 전');
      expect(vm.accounts.single.level, UiLevel.act);
      expect(
        vm.mappings.map((SleeveMappingRow m) => m.statusLine).toSet(),
        <String>{'미지정 — 이 슬리브의 주문은 내지 않습니다.'},
      );
    },
  );

  test(
    '🔴 계좌 — 금고의 모의 번호 = 엔진 마스킹 · 검증 통과 = 잔고 확인 줄 · 원번호 0 · 검증 기록 → 다시 낸다',
    () async {
      await storePaper();
      rt.view.value = viewOf(files.sim);
      final List<AccountMappingVm> got = <AccountMappingVm>[];
      final StreamSubscription<AccountMappingVm> sub =
          OperatorSettingsRepository(rt).watchAccountMapping().listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      final AccountRow first = got.last.accounts.single;
      expect(first.maskedNumberText, '****5678');
      expect(first.checkText, '모의 서버 잔고 확인 기록 없음');
      // 거절 기록 = 잔고 확인이 아니다(통과만 «잔고 확인»).
      progress().record(
        'o_02',
        StepState.failed,
        failureReasonCode: OnboardingResultCodes.credentialRejected,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(got.last.accounts.single.checkText, '모의 서버 잔고 확인 기록 없음');
      progress().record('o_02', StepState.verified);
      await until(
        () => got.last.accounts.single.checkText == '모의 서버 잔고 확인 12-01 09:00',
      );
      expect(got.last.accounts.single.level, UiLevel.info);
      expect(got.last.toJson().toString().contains('12345678'), isFalse);
    },
  );

  test(
    '🔴 계좌 — 모의 개시 판(운영 설정 등재 + 개시 결정)이 서면 슬리브 = 그 판의 별칭(다시 낸다 · 같은 원장)',
    () async {
      const Map<String, String> accounts = <String, String>{
        P0sStrategyIds.sleeveA: 'general',
        P0sStrategyIds.sleeveB: 'pension',
        P0sStrategyIds.sleeveC: 'general',
        P0sStrategyIds.pot: 'general',
      };
      rt.view.value = viewOf(files.sim);
      final List<AccountMappingVm> got = <AccountMappingVm>[];
      final StreamSubscription<AccountMappingVm> sub =
          OperatorSettingsRepository(rt).watchAccountMapping().listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(got.last.mappings.first.accountLabel, isNull);
      final String hash = SqliteConfigVersionStore(files.sim, clock: clock)
          .register(
            P0sOpsConfig.of(
              P0sHumanInputs(aSymbol: '999990', accountByStrategy: accounts),
            ).content(),
          );
      final SqliteOnboardingStore s = SqliteOnboardingStore(
        files.sim,
        clock: clock,
      );
      expect(s.selectOperatingMode(OperatingMode.autoTrade).ok, true);
      expect(
        s
            .declareSimOpening(
              SelfReportBalance(
                asOfTradeDate: const TradeDate('2026-12-01'),
                purpose: SelfReportPurpose.simOpening,
                sessionStartedAt: clock.now,
                lines: const [],
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
              accountByStrategy: accounts,
              configHash: hash,
            )
            .ok,
        true,
      );
      await until(() => got.last.mappings.first.accountLabel != null);
      expect(
        got.last.mappings
            .map((SleeveMappingRow m) => (m.accountLabel, m.level))
            .toList(),
        <(String?, UiLevel)>[
          ('general', UiLevel.ok),
          ('pension', UiLevel.ok),
          ('general', UiLevel.ok),
        ],
      );
      expect(got.last.mappings.first.subbookLine, 'POT 서브북도 이 계좌에서 운용합니다.');
    },
  );

  test('🔴 R154 — 정한 사람 값(실행 묶음)이 있고 모의 개시 판 없음 = 슬리브 = 그 별칭 표시 글자 · «모의 개시 전» INFO', () async {
    final OperatorRuntime withHuman = OperatorRuntime(
      files: files,
      clock: clock,
      vault: vault,
      humanDecision: p0sHumanDecisionFromText(
        '{"version": 1, "decision": "R153", "sleeve_a_symbol": "229200", '
        '"accounts": {"P0S_A": "isa", "P0S_B": "pension", "P0S_C": "general", "P0S_POT": "isa"}, '
        '"account_labels": {"isa": "ISA", "pension": "연금저축", "general": "일반 위탁"}}',
      ),
    );
    withHuman.view.value = viewOf(files.sim);
    final AccountMappingVm vm = await OperatorSettingsRepository(withHuman)
        .accountMapping();
    expect(
      vm.mappings
          .map((SleeveMappingRow m) => (m.accountLabel, m.level))
          .toList(),
      <(String?, UiLevel)>[
        ('ISA', UiLevel.info),
        ('연금저축', UiLevel.info),
        ('일반 위탁', UiLevel.info),
      ],
    );
    expect(vm.mappings.first.statusLine, '모의 개시 전 — 시작하면 이 계좌로 운영합니다.');
    expect(vm.accounts.map((AccountRow a) => a.label).toList(), <String>[
      'ISA',
      '연금저축',
      '일반 위탁',
      '모의투자',
    ]);
  });

  test('🔴 나머지 창구 = 원천 없음(오류)', () async {
    final OperatorSettingsRepository r = OperatorSettingsRepository(rt);
    await expectLater(r.watchOperations(), emitsError(isA<UnsupportedError>()));
  });
}
