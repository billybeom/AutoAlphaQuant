// E11k-c — o_07 ② Supabase 연결 확인 operator 판(설계 13 §8 R206 · 계약 v1.29 01 §39).
//
// 🔵 잡는 것: ① 칸 없음 · 빈 칸 = SUPABASE_INPUT_EMPTY · 망 0 · 금고 0 ② 꼴 문제 = 그 코드 · 망 0
//    ③ 통과 = 금고 두 칸 → 칸 비움 → o_07 IN_PROGRESS → 신뢰 시각 1회 → 표본 OK 글자 ④ 망 실패 = 금고 0 · 칸 그대로 · 진척 0 · 잼 0
//    ⑤ 금고 쓰기 실패 = 저장 실패 글자(재시도) ⑥ 🔴 VERIFIED 는 진행 중으로 내리지 않는다 ⑦ 두 번 누름 = 한 번 잼
//    ⑧ 다른 대상 · 서버 시각 없음 = 구현 없음 · args 더 = ArgumentError ⑨ 🔴 결과에 주소 · 키 0.
// 🔴 시험 주소 · 키는 이어 붙여 만든다(저장소에 키 꼴 리터럴 0 · 실 Supabase 호출 0).

import 'dart:async';

import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisRestClient;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show SqliteOnboardingProgressStore, SupabaseServerTime;
import 'package:domain_contracts/domain_contracts.dart'
    show ActionResult, SettingsActionId, StepState, UiLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../engine/support.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
final String _secret = 'sb_${'secret'}_${'K' * 12}${'4' * 10}';
const String _date = 'Tue, 08 Dec 2026 00:00:07 GMT';
const Map<String, String> _args = <String, String>{'target': 'SUPABASE'};

class _Draft implements SupabaseDraftSource {
  _Draft(this.url, this.key);
  String? url;
  String? key;
  int cleared = 0;
  @override
  ({String? url, String? key}) current() => (url: url, key: key);
  @override
  void clear() {
    cleared++;
    url = null;
    key = null;
  }
}

void main() {
  tearDownAll(deleteTempDirs);

  late MemorySecretVault vault;
  late SecretHandoff handoff;
  late _Draft draft;
  late LedgerFiles files;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) respond;
  late int refreshed;
  late Completer<void>? hold;
  late OperatorSettingsActions acts;

  setUp(() {
    vault = MemorySecretVault();
    handoff = SecretHandoff();
    draft = _Draft(_url, _pub);
    handoff.attachSupabase(draft);
    files = openFiles(
      tempLedgerDir(),
      FakeClock(DateTime.utc(2026, 12, 8, 0, 0, 5)),
    );
    requests = <http.Request>[];
    respond = (_) async =>
        http.Response('{}', 200, headers: <String, String>{'date': _date});
    refreshed = 0;
    hold = null;
    acts = OperatorSettingsActions(
      secrets: handoff,
      vault: vault,
      clientOf: (KisCredentials c) => KisRestClient(
        MockClient((_) async => http.Response('', 500)),
        c,
        environment: c.environment,
      ),
      clock: FakeClock(DateTime.utc(2026, 12, 8, 0, 0, 5)),
      sim: files.sim,
      supabaseTime: SupabaseServerTime(
        MockClient((http.Request r) async {
          requests.add(r);
          final Completer<void>? h = hold;
          if (h != null) await h.future;
          return respond(r);
        }),
        vault,
      ),
      refreshTrusted: () async {
        refreshed++;
        return true;
      },
    );
  });
  tearDown(() => files.close());

  StepState? o07() => SqliteOnboardingProgressStore(
    files.sim,
    clock: FakeClock(DateTime.utc(2026, 12, 8)),
  ).lastRecord('o_07')?.state;

  Future<ActionResult> run() =>
      acts.run(SettingsActionId.connectionTest, args: _args);

  test(
    '🔴 통과 = 금고 두 칸 → 칸 비움 → o_07 IN_PROGRESS → 신뢰 시각 1회 → 표본 OK 글자',
    () async {
      final ActionResult r = await run();
      expect(r.id, SettingsActionId.connectionTest);
      expect(r.level, UiLevel.ok);
      expect(r.headline, '서버 시각을 확인했습니다. 로그인과 SQL 단계가 남았습니다.');
      expect(r.reasonCode, isNull);
      expect(r.retryable, isFalse);
      expect(requests, hasLength(1));
      expect(requests.single.url.toString(), '$_url/auth/v1/health');
      expect(vault.peek('supabase.project_url'), _url);
      expect(vault.peek('supabase.publishable_key'), _pub);
      expect(draft.cleared, 1);
      expect(o07(), StepState.inProgress);
      expect(refreshed, 1);
      expect(await acts.watch(r.actionRunId).first, r);
      // 🔴 결과에 주소 · ref · 키 0.
      expect(r.toString(), isNot(contains(_ref)));
      expect(r.toString(), isNot(contains(_pub)));
    },
  );

  test('🔴 칸 없음 = SUPABASE_INPUT_EMPTY · 망 0 · 금고 0 · 진척 0', () async {
    handoff.detachSupabase(draft);
    final ActionResult r = await run();
    expect(r.level, UiLevel.blocked);
    expect(r.reasonCode, 'SUPABASE_INPUT_EMPTY');
    expect(r.headline, '주소와 키를 모두 붙여 넣으십시오.');
    expect(requests, isEmpty);
    expect(vault.calls, isEmpty);
    expect(o07(), isNull);
    expect(refreshed, 0);
  });

  test('🔴 키 한 칸만 = 빈 칸 · 비밀 키 = 거부 코드 · 둘 다 망 0', () async {
    draft.key = null;
    expect((await run()).reasonCode, 'SUPABASE_INPUT_EMPTY');
    draft.key = _secret;
    final ActionResult r = await run();
    expect(r.reasonCode, 'SUPABASE_SECRET_KEY_REJECTED');
    expect(r.retryable, isFalse);
    expect(requests, isEmpty);
    expect(vault.calls, isEmpty);
    expect(draft.cleared, 0);
  });

  test('🔴 망 실패(401) = 금고 0 · 칸 그대로 · 진척 0 · 잼 0', () async {
    respond = (_) async =>
        http.Response('', 401, headers: <String, String>{'date': _date});
    final ActionResult r = await run();
    expect(r.level, UiLevel.blocked);
    expect(r.reasonCode, 'SUPABASE_UNAUTHORIZED');
    expect(r.headline, '키가 거절되었습니다. 설정 화면에서 키를 다시 확인하십시오.');
    expect(vault.calls, isEmpty);
    expect(draft.cleared, 0);
    expect(draft.url, _url);
    expect(o07(), isNull);
    expect(refreshed, 0);
  });

  test('망 끊김 = WATCH · 재시도', () async {
    respond = (_) async => throw http.ClientException('끊김');
    final ActionResult r = await run();
    expect(r.level, UiLevel.watch);
    expect(r.reasonCode, 'SUPABASE_NETWORK');
    expect(r.retryable, isTrue);
  });

  test('🔴 금고 쓰기 실패 = 저장 실패 글자(재시도) · 칸 그대로 · 진척 0 · 잼 0', () async {
    vault.failWritesTo.add('supabase.publishable_key');
    final ActionResult r = await run();
    expect(r.level, UiLevel.blocked);
    expect(r.headline, CredentialVerifyText.saveFailed);
    expect(r.retryable, isTrue);
    expect(draft.cleared, 0);
    expect(o07(), isNull);
    expect(refreshed, 0);
  });

  test('🔴 이미 VERIFIED = 진행 중으로 내리지 않는다(금고 · 잼은 그대로 한다)', () async {
    SqliteOnboardingProgressStore(
      files.sim,
      clock: FakeClock(DateTime.utc(2026, 12, 8)),
    ).record('o_07', StepState.verified);
    expect((await run()).level, UiLevel.ok);
    expect(o07(), StepState.verified);
    expect(refreshed, 1);
    expect(vault.peek('supabase.project_url'), _url);
  });

  test('두 번 누름 = 한 번 잰다 · 같은 결과 · 끝나면 다시 잴 수 있다', () async {
    hold = Completer<void>();
    final Future<ActionResult> a = run();
    final Future<ActionResult> b = run();
    await pumpEventQueue();
    expect(requests, hasLength(1));
    hold!.complete();
    expect(identical(await a, await b), isTrue);
    hold = null;
    draft
      ..url = _url
      ..key = _pub;
    await run();
    expect(requests, hasLength(2));
  });

  test('다른 대상 · 서버 시각 없음 = 구현 없음 · args 더 = ArgumentError', () async {
    await expectLater(
      acts.run(
        SettingsActionId.connectionTest,
        args: const <String, String>{'target': 'GITHUB_ARCHIVE'},
      ),
      throwsA(isA<UnsupportedError>()),
    );
    await expectLater(
      acts.run(
        SettingsActionId.connectionTest,
        args: const <String, String>{'target': 'SUPABASE', 'x': '1'},
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
      bare.run(SettingsActionId.connectionTest, args: _args),
      throwsA(isA<UnsupportedError>()),
    );
    expect(requests, isEmpty);
  });
}
