// E11p3d-5c 설정 · 온보딩 «동작» operator 판 — 키 검증 1단(설계 13 §8 R118). 값 = 연습 값만(실키 0) · KIS = 가짜 HTTP.

import 'dart:async';
import 'dart:convert';

import 'package:app_operator_android/app/operator_settings_actions.dart';
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
        readKisCredentials;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        BrokerRawCodes,
        OnboardingResultCodes,
        SettingsActionId,
        UiLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

  test('🔴 칸 없음 · 덜 참 = 다른 문구(조치가 다르다) · 서버 · 금고 0', () async {
    src.value = null;
    final ActionResult half = await verify();
    expect(half.level, UiLevel.act);
    expect(half.headline, CredentialVerifyText.incomplete);
    handoff.detach(KisKeySet.paper, src);
    final ActionResult none = await verify();
    expect(none.level, UiLevel.blocked);
    expect(none.headline, CredentialVerifyText.noField);
    expect(paths, isEmpty);
    expect(vault.calls, isEmpty);
  });

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
    // 끝난 뒤 다시 누르면 새로 한다(칸이 비었으니 «덜 참»).
    expect((await verify()).headline, CredentialVerifyText.incomplete);
  });

  test('🔴 아직 없는 세트 = 막힘 문구 · args 꼴 위반 = 오류 · 다른 동작 = 구현 없음', () async {
    final ActionResult live = await verify('KIS_LIVE');
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
}
