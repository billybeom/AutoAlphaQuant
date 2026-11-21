// E11k-d2 — o_07 ③ Supabase 로그인 operator 판(설계 13 §8 R216 · 계약 v1.31 01 §40 · 표본 `m8/onboarding_supabase_signin_results`).
//
// 🔵 잡는 것: ① 통과 = 넘김 값으로 로그인 · 새로고침 토큰 금고 · 🔴 칸 비움 · o_07 진행 중 · 표본 OK 글자 ② 🔴 실패도 칸 비움 ·
//    진척 그대로 · 표본 글자(자격 · 과속 · 키 · 서버 · 망) ③ 칸 없음 = 입력 문제(망 0) ④ 금고 쓰기 실패 = 인증 금고 글자
//    ⑤ 🔴 VERIFIED 는 내리지 않는다 ⑥ 두 번 누름 = 한 번 ⑦ args 더 = ArgumentError · Auth 없음 = 구현 없음
//    ⑧ 🔴 연결 칸 없음 = 표본에 없는 실패 → 오류(글자를 짓지 않는다) ⑨ 결과 문자열에 이메일 · 비밀번호 0.
// 🔴 시험 값은 이어 붙여 만든다(실 Supabase 호출 0).

import 'dart:async';
import 'dart:convert';

import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisRestClient;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show SqliteOnboardingProgressStore, SupabaseAuth, SupabaseSecretIds;
import 'package:domain_contracts/domain_contracts.dart'
    show ActionResult, SettingsActionId, StepState, UiLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../engine/support.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
const String _email = 'owner@example.com';
final String _password = 'pw-${'Z' * 16}';

class _Draft implements SupabaseLoginDraftSource {
  _Draft(this.email, this.password);
  String? email;
  String? password;
  int cleared = 0;
  @override
  ({String? email, String? password}) current() =>
      (email: email, password: password);
  @override
  void clear() {
    cleared++;
    email = null;
    password = null;
  }
}

http.Response _tokens() => http.Response(
  jsonEncode(<String, Object?>{
    'access_token': 'acc-${'A' * 10}',
    'expires_in': 3600,
    'refresh_token': 'ref-${'R' * 10}',
    'user': <String, Object?>{'id': 'uid-1'},
  }),
  200,
);

void main() {
  tearDownAll(deleteTempDirs);

  late MemorySecretVault vault;
  late SecretHandoff handoff;
  late _Draft draft;
  late LedgerFiles files;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) respond;
  late Completer<void>? hold;
  late SupabaseAuth auth;
  late OperatorSettingsActions acts;

  setUp(() {
    vault = MemorySecretVault(<String, String>{
      'supabase.project_url': _url,
      'supabase.publishable_key': _pub,
    });
    handoff = SecretHandoff();
    draft = _Draft(_email, _password);
    handoff.attachSupabaseLogin(draft);
    files = openFiles(tempLedgerDir(), FakeClock(DateTime.utc(2026, 12, 8)));
    requests = <http.Request>[];
    respond = (_) async => _tokens();
    hold = null;
    auth = SupabaseAuth(
      MockClient((http.Request r) async {
        requests.add(r);
        final Completer<void>? h = hold;
        if (h != null) await h.future;
        return respond(r);
      }),
      vault,
      clock: FakeClock(DateTime.utc(2026, 12, 8)),
    );
    acts = OperatorSettingsActions(
      secrets: handoff,
      vault: vault,
      clientOf: (KisCredentials c) => KisRestClient(
        MockClient((_) async => http.Response('', 500)),
        c,
        environment: c.environment,
      ),
      clock: FakeClock(DateTime.utc(2026, 12, 8)),
      sim: files.sim,
      supabaseAuth: auth,
    );
  });
  tearDown(() => files.close());

  StepState? o07() => SqliteOnboardingProgressStore(
    files.sim,
    clock: FakeClock(DateTime.utc(2026, 12, 8)),
  ).lastRecord('o_07')?.state;

  Future<ActionResult> run() => acts.run(SettingsActionId.supabaseSignIn);

  test(
    '🔴 통과 = 넘김 값으로 로그인 · 새로고침 토큰 금고 · 칸 비움 · o_07 진행 중 · 표본 OK 글자',
    () async {
      final ActionResult r = await run();
      expect(r.id, SettingsActionId.supabaseSignIn);
      expect(r.level, UiLevel.ok);
      expect(r.headline, '로그인했습니다. SQL 단계가 남았습니다.');
      expect(r.reasonCode, isNull);
      expect(r.retryable, isFalse);
      expect(requests.single.url.queryParameters['grant_type'], 'password');
      expect(jsonDecode(requests.single.body), <String, Object?>{
        'email': _email,
        'password': _password,
      });
      expect(vault.peek('supabase.refresh_token'), isNotNull);
      expect(auth.userId, 'uid-1');
      expect(draft.cleared, 1);
      expect(o07(), StepState.inProgress);
      expect(await acts.watch(r.actionRunId).first, r);
      expect(r.toString(), isNot(contains(_password)));
      expect(r.toString(), isNot(contains(_email)));
    },
  );

  for (final (int code, String reason, UiLevel level, bool retry, String text)
      in <(int, String, UiLevel, bool, String)>[
        (
          400,
          'SUPABASE_CREDENTIALS_REJECTED',
          UiLevel.blocked,
          false,
          '이메일 또는 비밀번호가 맞지 않습니다. 비밀번호 관리자의 값을 다시 확인하십시오.',
        ),
        (
          429,
          'SUPABASE_RATE_LIMITED',
          UiLevel.watch,
          true,
          '시도가 너무 잦습니다. 잠시 뒤 다시 로그인하십시오.',
        ),
        (
          401,
          'SUPABASE_UNAUTHORIZED',
          UiLevel.blocked,
          false,
          '연결 키가 거절되었습니다. 연결 단계를 다시 확인하십시오.',
        ),
        (
          503,
          'SUPABASE_SERVER_ERROR',
          UiLevel.watch,
          true,
          '서버가 응답하지 못했습니다. 잠시 뒤 다시 로그인하십시오.',
        ),
      ]) {
    test('🔴 HTTP $code = $reason · 칸도 비운다 · 진척 그대로 · 금고 0', () async {
      respond = (_) async => http.Response('{"error":"x"}', code);
      final ActionResult r = await run();
      expect(r.reasonCode, reason);
      expect(r.level, level);
      expect(r.retryable, retry);
      expect(r.headline, text);
      expect(draft.cleared, 1);
      expect(o07(), isNull);
      expect(vault.peek('supabase.refresh_token'), isNull);
    });
  }

  test('망 끊김 = SUPABASE_NETWORK(재시도)', () async {
    respond = (_) async => throw http.ClientException('끊김');
    final ActionResult r = await run();
    expect(r.reasonCode, 'SUPABASE_NETWORK');
    expect(r.retryable, isTrue);
  });

  test('칸 없음 · 비밀번호 빔 = SUPABASE_AUTH_INPUT_INVALID · 망 0', () async {
    handoff.detachSupabaseLogin(draft);
    expect((await run()).reasonCode, 'SUPABASE_AUTH_INPUT_INVALID');
    handoff.attachSupabaseLogin(draft);
    draft.password = null;
    final ActionResult r = await run();
    expect(r.reasonCode, 'SUPABASE_AUTH_INPUT_INVALID');
    expect(r.headline, '이메일과 비밀번호를 모두 붙여 넣으십시오.');
    expect(requests, isEmpty);
  });

  test('🔴 금고 쓰기 실패 = SUPABASE_AUTH_VAULT_FAILED(인증 쪽 글자)', () async {
    vault.failWritesTo.add('supabase.refresh_token');
    final ActionResult r = await run();
    expect(r.reasonCode, 'SUPABASE_AUTH_VAULT_FAILED');
    expect(r.headline, '로그인 상태를 이 기기에 저장하지 못했습니다. 다시 로그인하십시오.');
    expect(o07(), isNull);
  });

  test('🔴 이미 VERIFIED = 진행 중으로 내리지 않는다', () async {
    SqliteOnboardingProgressStore(
      files.sim,
      clock: FakeClock(DateTime.utc(2026, 12, 8)),
    ).record('o_07', StepState.verified);
    expect((await run()).level, UiLevel.ok);
    expect(o07(), StepState.verified);
  });

  test('두 번 누름 = 한 번 로그인 · 같은 결과 · 끝나면 다시', () async {
    hold = Completer<void>();
    final Future<ActionResult> a = run();
    final Future<ActionResult> b = run();
    await pumpEventQueue();
    expect(requests, hasLength(1));
    hold!.complete();
    expect(identical(await a, await b), isTrue);
    hold = null;
    draft
      ..email = _email
      ..password = _password;
    await run();
    expect(requests, hasLength(2));
  });

  test('args 더 = ArgumentError · Auth 없음 = 구현 없음', () async {
    await expectLater(
      acts.run(
        SettingsActionId.supabaseSignIn,
        args: const <String, String>{'x': '1'},
      ),
      throwsA(isA<ArgumentError>()),
    );
    final OperatorSettingsActions bare = OperatorSettingsActions(
      secrets: handoff,
      vault: vault,
      clientOf: (KisCredentials c) => KisRestClient(
        MockClient((_) async => http.Response('', 500)),
        c,
        environment: c.environment,
      ),
      clock: FakeClock(DateTime.utc(2026, 12, 8)),
    );
    await expectLater(
      bare.run(SettingsActionId.supabaseSignIn),
      throwsA(isA<UnsupportedError>()),
    );
    expect(requests, isEmpty);
  });

  test('🔴 연결 칸 없음 = 표본에 없는 실패 → 오류(글자를 짓지 않는다) · 칸은 비운다', () async {
    await vault.delete(SupabaseSecretIds.projectUrl);
    await expectLater(run(), throwsA(isA<StateError>()));
    expect(draft.cleared, 1);
    expect(requests, isEmpty);
  });
}
