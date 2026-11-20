// E11p3d-5c 설정 · 온보딩 «동작» operator 판 — 키 검증 1단(설계 13 §8 R118). 값 = 연습 값만(실키 0) · KIS = 가짜 HTTP.

import 'dart:async';
import 'dart:convert';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show
        KisCredentialRead,
        KisCredentials,
        KisCredentialsMissing,
        KisCredentialsStored,
        KisEnvironment,
        KisKeySet,
        KisRateGate,
        KisRestClient,
        readKisCredentials,
        storeKisCredentials;
import 'package:core_engine/core_engine.dart'
    show
        CredentialHealthRecord,
        OnboardingStepFact,
        P0sHumanInputs,
        kOnboardingDryRunRolledBackText,
        kOnboardingDryRunStartedText,
        kOnboardingModeCommittedText,
        kOnboardingModeSelectedText;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        P0sHumanDecision,
        SqliteOnboardingProgressStore,
        SqliteOnboardingStore,
        credentialRecordsOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        BrokerRawCodes,
        CommandReceipt,
        CommandState,
        OnboardingResultCodes,
        OperatingMode,
        SelfReportInput,
        SelfReportPurpose,
        SelfReportSubmission,
        SettingsActionId,
        StepState,
        UiLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

const String _key = 'PSTESTAPPKEY0000000000001';
const String _secret = 'TESTSECRETVALUEabcdefghijklmnop9876';

class _Src implements KisDraftSource {
  KisCredentials? value;
  int cleared = 0;
  @override
  KisCredentials? current() => value;
  @override
  void clear() {
    cleared++;
    value = null;
  }
}

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
);

void main() {
  late MemorySecretVault vault;
  late SecretHandoff handoff;
  late _Src src;
  late List<String> paths;
  late http.Response Function() token;
  late http.Response Function() balance;
  late OperatorSettingsActions acts;

  setUp(() {
    vault = MemorySecretVault();
    handoff = SecretHandoff();
    src = _Src()
      ..value = KisCredentials(
        environment: KisEnvironment.mock,
        appKey: _key,
        appSecret: _secret,
        accountNo: '12345678',
        productCode: '01',
      );
    handoff.attach(KisKeySet.paper, src);
    paths = <String>[];
    token = () => _json(<String, Object>{
      'access_token': 'eyFAKE-TOKEN',
      'token_type': 'Bearer',
      'expires_in': 86400,
    });
    balance = () => _json(<String, Object>{
      'rt_cd': '0',
      'msg_cd': '20310000',
      'msg1': '모의투자 조회가 완료되었습니다.',
      'output1': <Object>[],
      'output2': <Object>[
        <String, String>{'prvs_rcdl_excc_amt': '10000000'},
      ],
    });
    final MockClient net = MockClient((http.Request r) async {
      paths.add(r.url.path);
      return r.url.path == '/oauth2/tokenP' ? token() : balance();
    });
    acts = OperatorSettingsActions(
      secrets: handoff,
      vault: vault,
      clientOf: (KisCredentials c) => KisRestClient(
        net,
        c,
        environment: c.environment,
        sleep: (_) async {},
        gate: KisRateGate(Duration.zero, sleep: (_) async {}),
      ),
      clock: FakeClock(kst(2026, 12, 22, 9, 30)),
    );
  });

  Future<ActionResult> verify([String kind = 'KIS_PAPER']) => acts.run(
    SettingsActionId.credentialVerify,
    args: <String, String>{'kind': kind},
  );

  Future<bool> stored() async {
    final KisCredentialRead r = await readKisCredentials(
      vault,
      KisKeySet.paper,
    );
    return r is KisCredentialsStored;
  }

  test('🔴 통과 = 토큰 → 잔고 → 금고 저장 → 칸 비움 · 결과 = 엔진 문구', () async {
    final ActionResult r = await verify();
    expect(r.level, UiLevel.ok);
    expect(r.headline, CredentialVerifyText.saved);
    expect(r.reasonCode, isNull);
    expect(r.retryable, false);
    expect(paths.first, '/oauth2/tokenP');
    expect(paths, hasLength(2));
    final KisCredentialRead read = await readKisCredentials(
      vault,
      KisKeySet.paper,
    );
    expect(read, isA<KisCredentialsStored>());
    final KisCredentials c = (read as KisCredentialsStored).credentials;
    expect(c.appKey, _key);
    expect(c.accountNo, '12345678');
    expect(src.cleared, 1);
    expect(await acts.watch(r.actionRunId).single, r);
  });

  test('🔴 칸 없음 · 덜 참(금고에도 키 없음) = 다른 문구(조치가 다르다) · 서버 0 · 금고 쓰기 0', () async {
    src.value = null;
    final ActionResult half = await verify();
    expect(half.level, UiLevel.act);
    expect(half.headline, CredentialVerifyText.incomplete);
    handoff.detach(KisKeySet.paper, src);
    final ActionResult none = await verify();
    expect(none.level, UiLevel.blocked);
    expect(none.headline, CredentialVerifyText.noField);
    expect(paths, isEmpty);
    expect(vault.calls.where((String c) => !c.startsWith('read:')), isEmpty);
  });

  test(
    '🔴 새 값 없음 + 금고에 키 = «다시 검증»(금고 키 · 저장 0 · 칸 비움 0 · 표본 문장) · 거절 = 키 거절',
    () async {
      await storeKisCredentials(vault, KisKeySet.paper, src.value!);
      final int writes = vault.calls
          .where((String c) => c.startsWith('write:'))
          .length;
      // 칸이 화면에 있지만 덜 참 → 금고 키로.
      src.value = null;
      final ActionResult again = await verify();
      expect(
        (again.level, again.headline, again.reasonCode),
        (UiLevel.info, CredentialVerifyText.reverified, null),
      );
      expect(paths, <String>['/oauth2/tokenP', paths.last]);
      expect(
        vault.calls.where((String c) => c.startsWith('write:')).length,
        writes,
      );
      expect(src.cleared, 0);
      // 칸이 화면에 없어도 금고 키로.
      handoff.detach(KisKeySet.paper, src);
      paths.clear();
      token = () => _json(<String, String>{
        'error_code': 'EGW00103',
        'error_description': '유효하지 않은 AppKey입니다.',
      }, 403);
      final ActionResult bad = await verify();
      expect(bad.headline, CredentialVerifyText.keyRejected);
      expect(bad.reasonCode, OnboardingResultCodes.credentialRejected);
    },
  );

  test(
    '🔴 앱키 거절 = CREDENTIAL_REJECTED · 다시 시도 없음 · 잔고 · 저장 0 · 칸 그대로',
    () async {
      token = () => _json(<String, String>{
        'error_code': 'EGW00103',
        'error_description': '유효하지 않은 AppKey입니다.',
      }, 403);
      final ActionResult r = await verify();
      expect(r.headline, CredentialVerifyText.keyRejected);
      expect(r.reasonCode, OnboardingResultCodes.credentialRejected);
      expect(r.retryable, false);
      expect(paths, <String>['/oauth2/tokenP']);
      expect(await stored(), false);
      expect(src.cleared, 0);
    },
  );

  test('🔴 토큰 1분 1회 = 원문 코드 · 다시 시도 가능', () async {
    token = () => _json(<String, String>{
      'error_code': 'EGW00133',
      'error_description': '접근토큰 발급 잠시 후 다시 시도하세요(1분당 1회)',
    }, 403);
    final ActionResult r = await verify();
    expect(r.level, UiLevel.blocked);
    expect(r.headline, CredentialVerifyText.rateLimited);
    expect(r.reasonCode, BrokerRawCodes.kisTokenRateLimited);
    expect(r.retryable, true);
    expect(await stored(), false);
  });

  test('🔴 닿지 못함 = 다시 시도 가능 · 저장 0', () async {
    token = () => throw http.ClientException('연결 실패');
    final ActionResult r = await verify();
    expect(r.headline, CredentialVerifyText.unreachable);
    expect(r.reasonCode, isNull);
    expect(r.retryable, true);
    expect(await stored(), false);
  });

  test('🔴 계좌 거절(잔고 업무 거절) = CREDENTIAL_REJECTED · 저장 0', () async {
    balance = () => _json(<String, String>{
      'rt_cd': '1',
      'msg_cd': 'OPSQ2000',
      'msg1': 'ERROR : INPUT_FIELD_NAME CANO',
    });
    final ActionResult r = await verify();
    expect(r.headline, CredentialVerifyText.accountRejected);
    expect(r.reasonCode, OnboardingResultCodes.credentialRejected);
    expect(r.retryable, false);
    expect(await stored(), false);
    expect(src.cleared, 0);
  });

  test('🔴 응답을 읽지 못함 = 다시 시도 가능 · 저장 0', () async {
    balance = () =>
        _json(<String, Object>{'rt_cd': '0', 'output1': <Object>[]});
    final ActionResult r = await verify();
    expect(r.headline, CredentialVerifyText.unreadable);
    expect(r.retryable, true);
    expect(await stored(), false);
  });

  test('🔴 금고 저장 실패 = 다시 시도 가능 · 칸 그대로', () async {
    vault.failWritesTo.add('kis.paper.app_secret');
    final ActionResult r = await verify();
    expect(r.headline, CredentialVerifyText.saveFailed);
    expect(r.retryable, true);
    expect(src.cleared, 0);
  });

  test('🔴 진행 중 두 번 누름 = 한 번 발급 · 같은 결과', () async {
    final Completer<void> gate = Completer<void>();
    final http.Response Function() t0 = token;
    final MockClient slow = MockClient((http.Request r) async {
      paths.add(r.url.path);
      if (r.url.path == '/oauth2/tokenP') {
        await gate.future;
        return t0();
      }
      return balance();
    });
    acts = OperatorSettingsActions(
      secrets: handoff,
      vault: vault,
      clientOf: (KisCredentials c) => KisRestClient(
        slow,
        c,
        environment: c.environment,
        sleep: (_) async {},
        gate: KisRateGate(Duration.zero, sleep: (_) async {}),
      ),
      clock: FakeClock(kst(2026, 12, 22, 9, 30)),
    );
    final Future<ActionResult> a = verify();
    final Future<ActionResult> b = verify();
    gate.complete();
    final List<ActionResult> both = await Future.wait(<Future<ActionResult>>[
      a,
      b,
    ]);
    expect(identical(both[0], both[1]), true);
    expect(paths.where((String p) => p == '/oauth2/tokenP'), hasLength(1));
    // 끝난 뒤 다시 누르면 새로 한다(칸이 비었고 금고에 키 = «다시 검증» · R129).
    expect((await verify()).headline, CredentialVerifyText.reverified);
  });

  test('🔴 아직 없는 세트 = 막힘 문구 · args 꼴 위반 = 오류 · 다른 동작 = 구현 없음', () async {
    // 🆕 R196 — 실전 · ISA 는 이제 엔진 세트 · 대사 전용 = 아직 없는 세트.
    final ActionResult live = await verify('KIS_RECONCILE');
    expect(live.headline, CredentialVerifyText.setNotYet);
    expect(paths, isEmpty);
    await expectLater(
      acts.run(SettingsActionId.credentialVerify),
      throwsArgumentError,
    );
    await expectLater(
      acts.run(
        SettingsActionId.credentialVerify,
        args: <String, String>{'kind': 'KIS_PAPER', 'app_key': _key},
      ),
      throwsArgumentError,
    );
    await expectLater(
      acts.run(SettingsActionId.runtimeEngineStart),
      throwsUnsupportedError,
    );
    await expectLater(acts.watch('ar_unknown'), emitsError(isA<StateError>()));
    expect(
      await readKisCredentials(vault, KisKeySet.paper),
      isA<KisCredentialsMissing>(),
    );
  });

  group('🆕 온보딩(R125) — 운영 방식 선택 · 키 검증 → 진척', () {
    late LedgerFiles files;
    late FakeClock clock;
    late MockClient net;
    late OperatorSettingsActions withSim;

    setUp(() {
      clock = FakeClock(kst(2026, 12, 1, 9, 0));
      files = openFiles(tempLedgerDir(), clock);
      net = MockClient((http.Request r) async {
        paths.add(r.url.path);
        return r.url.path == '/oauth2/tokenP' ? token() : balance();
      });
      withSim = OperatorSettingsActions(
        secrets: handoff,
        vault: vault,
        clientOf: (KisCredentials c) => KisRestClient(
          net,
          c,
          environment: c.environment,
          sleep: (_) async {},
          gate: KisRateGate(Duration.zero, sleep: (_) async {}),
        ),
        clock: clock,
        sim: files.sim,
      );
    });
    tearDown(() => files.close());

    Map<String, OnboardingStepFact> progress() =>
        SqliteOnboardingProgressStore(files.sim, clock: clock).facts();

    Future<ActionResult> select(String wire) => withSim.run(
      SettingsActionId.onboardingOperatingModeSelect,
      args: <String, String>{'operating_mode': wire},
    );

    test(
      '🔴 선택 = sim 파일 기록 · 표본 문장 · 다시 고르기 = 덮어씀 · 확정 뒤 = 거부(표본 문장 · 코드)',
      () async {
        final ActionResult a = await select('ADVISORY');
        expect(
          (a.level, a.headline, a.reasonCode),
          (UiLevel.ok, kOnboardingModeSelectedText, null),
        );
        final SqliteOnboardingStore st = SqliteOnboardingStore(
          files.sim,
          clock: clock,
        );
        expect(st.choice()?.operatingMode, OperatingMode.advisory);
        expect((await select('AUTO_TRADE')).level, UiLevel.ok);
        expect(st.choice()?.operatingMode, OperatingMode.autoTrade);
        files.sim.execute(
          'UPDATE onboarding_choice SET committed_at = ? WHERE id = 1',
          <Object?>[clock.nowUtc().toIso8601String()],
        );
        final ActionResult c = await select('ADVISORY');
        expect(
          (c.level, c.headline, c.reasonCode),
          (
            UiLevel.blocked,
            kOnboardingModeCommittedText,
            OnboardingResultCodes.choiceCommitted,
          ),
        );
        expect(st.choice()?.operatingMode, OperatingMode.autoTrade);
      },
    );

    test('🔴 args 꼴 위반 = 오류 · sim 없는 조립 = 구현 없음', () async {
      await expectLater(select('MANUAL'), throwsArgumentError);
      await expectLater(
        withSim.run(SettingsActionId.onboardingOperatingModeSelect),
        throwsArgumentError,
      );
      await expectLater(
        withSim.run(
          SettingsActionId.onboardingOperatingModeSelect,
          args: <String, String>{'operating_mode': 'ADVISORY', 'x': '1'},
        ),
        throwsArgumentError,
      );
      await expectLater(
        acts.run(
          SettingsActionId.onboardingOperatingModeSelect,
          args: <String, String>{'operating_mode': 'ADVISORY'},
        ),
        throwsUnsupportedError,
      );
    });

    test('🔴 키 검증 통과 = o_02 VERIFIED · 거절 = FAILED CREDENTIAL_REJECTED · 닿지 못함 = 기록 없음', () async {
      token = () => throw http.ClientException('연결 실패');
      await withSim.run(
        SettingsActionId.credentialVerify,
        args: <String, String>{'kind': 'KIS_PAPER'},
      );
      expect(progress(), isEmpty);
      token = () => _json(<String, String>{
        'error_code': 'EGW00103',
        'error_description': '유효하지 않은 AppKey입니다.',
      }, 403);
      await withSim.run(
        SettingsActionId.credentialVerify,
        args: <String, String>{'kind': 'KIS_PAPER'},
      );
      expect(progress()['o_02']?.state, StepState.failed);
      expect(
        progress()['o_02']?.failureReasonCode,
        OnboardingResultCodes.credentialRejected,
      );
      token = () => _json(<String, Object>{
        'access_token': 'eyFAKE-TOKEN',
        'token_type': 'Bearer',
        'expires_in': 86400,
      });
      final ActionResult ok = await withSim.run(
        SettingsActionId.credentialVerify,
        args: <String, String>{'kind': 'KIS_PAPER'},
      );
      expect(ok.level, UiLevel.ok);
      expect(progress()['o_02']?.state, StepState.verified);
      expect(progress()['o_02']?.failureReasonCode, isNull);
    });

    test('🔴 모의 운영 시작(R127) = 엔진 dryRunStart — 앞 조건 거부 = 엔진 문장 · 코드 그대로(바뀐 것 없음) · args = {} · sim 없음 = 구현 없음', () async {
      await select('AUTO_TRADE');
      final ActionResult r = await withSim.run(
        SettingsActionId.onboardingDryRunStart,
      );
      expect(r.level, UiLevel.blocked);
      expect(r.reasonCode, isNotNull);
      expect(r.reasonCode, isNot(OnboardingResultCodes.dryRunStartRolledBack));
      expect(r.headline, isNot(kOnboardingDryRunRolledBackText));
      expect(
        SqliteOnboardingStore(files.sim, clock: clock).choice()?.committed,
        false,
      );
      await expectLater(
        withSim.run(
          SettingsActionId.onboardingDryRunStart,
          args: <String, String>{'x': '1'},
        ),
        throwsArgumentError,
      );
      await expectLater(
        acts.run(SettingsActionId.onboardingDryRunStart),
        throwsUnsupportedError,
      );
    });

    test(
      '🆕 R158 — 확정 계층 B 카드 = 모의 개시(가상 초기금) 뒤 «DRY_RUN 시작» 이 커밋된다',
      () async {
        await select('AUTO_TRADE');
        final CommandReceipt opened =
            await OperatorCommandApi(
              OperatorRuntime(
                files: files,
                clock: clock,
                deviceId: '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e',
                humanDecision: P0sHumanDecision(
                  inputs: P0sHumanInputs(
                    aSymbol: '229200',
                    accountByStrategy: const <String, String>{
                      'P0S_A': 'isa',
                      'P0S_B': 'pension',
                      'P0S_C': 'general',
                      'P0S_POT': 'isa',
                    },
                  ),
                  accountLabels: const <String, String>{
                    'isa': 'ISA',
                    'pension': '연금저축',
                    'general': '일반 위탁',
                  },
                  decisionRef: 'R153',
                ),
              ),
            ).submitSelfReportBalance(
              const SelfReportSubmission(
                purpose: SelfReportPurpose.simOpening,
                input: SelfReportInput(cashKrwText: '10,000,000'),
                declaredComplete: true,
              ),
            );
        expect(opened.state, CommandState.executed, reason: opened.stateLabel);
        final ActionResult r = await withSim.run(
          SettingsActionId.onboardingDryRunStart,
        );
        expect(r.level, UiLevel.ok, reason: r.headline);
        expect(r.reasonCode, isNull);
        expect(r.headline, kOnboardingDryRunStartedText);
        expect(
          SqliteOnboardingStore(files.sim, clock: clock).choice()?.committed,
          isTrue,
        );
      },
    );

    test('🆕 R160 — S10 무결성 자가진단 = 엔진 정본 자가 대조 · 결과 = 엔진 문장 · 기록 1행 · args = {} · 원장 없음 = 오류', () async {
      Database? book = files.sim;
      final OperatorSettingsActions withBook = OperatorSettingsActions(
        secrets: handoff,
        vault: vault,
        clientOf: (KisCredentials c) =>
            KisRestClient(net, c, environment: c.environment),
        clock: clock,
        sim: files.sim,
        ledger: () => book,
      );
      final ActionResult r = await withBook.run(
        SettingsActionId.selftestIntegrityRun,
      );
      expect(r.id, SettingsActionId.selftestIntegrityRun);
      expect(r.level, UiLevel.ok, reason: r.headline);
      expect(r.headline, '정본 자가 대조가 일치합니다.');
      expect(r.reasonCode, isNull);
      expect(
        files.sim
            .select(
              "SELECT COUNT(*) AS n FROM reconciliation_log WHERE action_taken = 'INTEGRITY_OK'",
            )
            .first['n'],
        1,
      );
      expect(await withBook.watch(r.actionRunId).first, r);
      await expectLater(
        withBook.run(
          SettingsActionId.selftestIntegrityRun,
          args: <String, String>{'x': '1'},
        ),
        throwsArgumentError,
      );
      book = null;
      await expectLater(
        withBook.run(SettingsActionId.selftestIntegrityRun),
        throwsStateError,
      );
      await expectLater(
        withSim.run(SettingsActionId.selftestIntegrityRun),
        throwsUnsupportedError,
      );
    });

    test('🔴 금고 키 «다시 검증»(R129) 통과도 o_02 VERIFIED 로 적는다', () async {
      await storeKisCredentials(vault, KisKeySet.paper, src.value!);
      handoff.detach(KisKeySet.paper, src);
      final ActionResult r = await withSim.run(
        SettingsActionId.credentialVerify,
        args: <String, String>{'kind': 'KIS_PAPER'},
      );
      expect(r.headline, CredentialVerifyText.reverified);
      expect(progress()['o_02']?.state, StepState.verified);
    });

    test('🔴 계좌 거절도 FAILED CREDENTIAL_REJECTED', () async {
      balance = () => _json(<String, String>{
        'rt_cd': '1',
        'msg_cd': 'OPSQ2000',
        'msg1': 'ERROR : INPUT_FIELD_NAME CANO',
      });
      await withSim.run(
        SettingsActionId.credentialVerify,
        args: <String, String>{'kind': 'KIS_PAPER'},
      );
      expect(progress()['o_02']?.state, StepState.failed);
    });
  });

  group('🆕 R196(207 ⓑ) — 실전 세트 검증 = 조회만 · 실전 서버 · 키 검증 기록(지금 원장)', () {
    late LedgerFiles files;
    late List<Uri> urls;
    late List<String?> trs;
    late _Src liveSrc;
    late OperatorSettingsActions withLedger;
    late bool ledgerOn;

    setUp(() {
      files = openFiles(tempLedgerDir(), FakeClock(kst(2026, 12, 22, 9, 30)));
      urls = <Uri>[];
      trs = <String?>[];
      ledgerOn = true;
      liveSrc = _Src()
        ..value = KisCredentials(
          environment: KisEnvironment.live,
          appKey: _key,
          appSecret: _secret,
          accountNo: '87654321',
          productCode: '01',
        );
      handoff.attach(KisKeySet.live, liveSrc);
      final MockClient net = MockClient((http.Request r) async {
        urls.add(r.url);
        trs.add(r.headers['tr_id']);
        return r.url.path == '/oauth2/tokenP' ? token() : balance();
      });
      withLedger = OperatorSettingsActions(
        secrets: handoff,
        vault: vault,
        clientOf: (KisCredentials c) => KisRestClient(
          net,
          c,
          environment: c.environment,
          sleep: (_) async {},
          gate: KisRateGate(Duration.zero, sleep: (_) async {}),
        ),
        clock: FakeClock(kst(2026, 12, 22, 9, 30)),
        ledger: () => ledgerOn ? files.sim : null,
      );
    });
    tearDown(() => files.close());

    Future<ActionResult> live([String kind = 'KIS_LIVE']) => withLedger.run(
      SettingsActionId.credentialVerify,
      args: <String, String>{'kind': kind},
    );

    List<String> registry() => <String>[
      for (final CredentialHealthRecord r in credentialRecordsOf(files.sim))
        '${r.kind}:${r.health}',
    ];

    test('🔴 통과 = 실전 서버 · 실전 잔고 TR(조회만) · 저장 · 기록 OK(kis_live)', () async {
      final ActionResult r = await live();
      expect((r.headline, r.reasonCode), (CredentialVerifyText.saved, null));
      expect(
        <String>{for (final Uri u in urls) u.host},
        <String>{'openapi.koreainvestment.com'},
      );
      expect(
        <String>[for (final Uri u in urls) u.path],
        <String>[
          '/oauth2/tokenP',
          '/uapi/domestic-stock/v1/trading/inquire-balance',
        ],
      );
      expect(trs.last, 'TTTC8434R');
      expect(
        await readKisCredentials(vault, KisKeySet.live),
        isA<KisCredentialsStored>(),
      );
      expect(registry(), <String>['KIS_LIVE:OK']);
      expect(
        files.sim
            .select('SELECT alias, keystore_ref FROM credential_registry')
            .single
            .values,
        <Object?>['kis_live', 'kis.live'],
      );
    });

    test('🔴 계좌 거절 = 실전 글자 · 기록 INVALID · 저장 0 · ISA = kis_isa', () async {
      balance = () => _json(<String, String>{
        'rt_cd': '1',
        'msg_cd': 'OPSQ2000',
        'msg1': 'ERROR : INPUT_FIELD_NAME CANO',
      });
      final _Src isaSrc = _Src()
        ..value = KisCredentials(
          environment: KisEnvironment.live,
          appKey: _key,
          appSecret: _secret,
          accountNo: '11223344',
          productCode: '01',
        );
      handoff.attach(KisKeySet.isa, isaSrc);
      final ActionResult r = await live('KIS_ISA');
      expect(
        (r.headline, r.reasonCode),
        (
          CredentialVerifyText.accountRejectedLive,
          OnboardingResultCodes.credentialRejected,
        ),
      );
      expect(registry(), <String>['KIS_ISA:INVALID']);
      expect(
        await readKisCredentials(vault, KisKeySet.isa),
        isA<KisCredentialsMissing>(),
      );
      expect(
        files.sim.select('SELECT alias FROM credential_registry').single.values,
        <Object?>['kis_isa'],
      );
    });

    test('실전 서버에 닿지 못함 · 응답을 읽지 못함 = 실전 글자 · 기록 0', () async {
      token = () => throw http.ClientException('연결 실패');
      expect((await live()).headline, CredentialVerifyText.unreachableLive);
      token = () => _json(<String, Object>{
        'access_token': 'eyFAKE-TOKEN',
        'token_type': 'Bearer',
        'expires_in': 86400,
      });
      balance = () =>
          _json(<String, Object>{'rt_cd': '0', 'output1': <Object>[]});
      expect((await live()).headline, CredentialVerifyText.unreadableLive);
      expect(registry(), isEmpty);
    });

    test('토큰 거절 = 기록 INVALID · 화면 원장 없음 = 기록 0(결과 글자는 그대로)', () async {
      token = () => _json(<String, String>{
        'error_description': '유효하지 않은 AppKey입니다.',
        'error_code': 'EGW00103',
      }, 403);
      ledgerOn = false;
      expect((await live()).headline, CredentialVerifyText.keyRejected);
      expect(registry(), isEmpty);
      ledgerOn = true;
      expect((await live()).headline, CredentialVerifyText.keyRejected);
      expect(registry(), <String>['KIS_LIVE:INVALID']);
    });

    test('금고 키 다시 검증(칸 비움) = 기록 OK · 모의 세트 검증 = 기록 0', () async {
      expect((await live()).headline, CredentialVerifyText.saved);
      liveSrc.value = null;
      expect((await live()).headline, CredentialVerifyText.reverified);
      expect(registry(), <String>['KIS_LIVE:OK']);
      final ActionResult p = await withLedger.run(
        SettingsActionId.credentialVerify,
        args: const <String, String>{'kind': 'KIS_PAPER'},
      );
      expect(p.headline, CredentialVerifyText.saved);
      expect(registry(), <String>['KIS_LIVE:OK']);
    });
  });
}
