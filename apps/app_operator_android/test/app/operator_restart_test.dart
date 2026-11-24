// R248 — R-01 기존 계정에서 다시 시작 operator 판(`watchRestart` · `reconnectReady` · 로그인 자리 · 라우트) · 실 SQLite(sim 파일) ·
// 실 Supabase 호출 0(MockClient).
//
// 🔵 잡는 것: ① 첫 화면 재시작 링크 = 기기 원장 읽기 조립 있음 ⇔ 링크 ② 로그인 전(연결 전 · 세션 없음) = 로그인 자리 하나 · 망 0
//    ③ 로그인 뒤 = 기기 원장 요약 · 리스 · 분기(구 폰 쥠 = 계획 · 비상 · 갭 ≥ 운영 설정 기준 = 신규 온보딩) ④ 신뢰 시각 모름 =
//    한 번 다시 잰다 ⑤ 이 폰이 쥠 + sim 비상 회수 기록 = 이어 하기 ⑥ 원장 못 읽음 = 모름 ⑦ poke = 다시 읽기(로그인 뒤)
//    ⑧ 앱 안: O-00 링크 → R-01 화면 · 로그인 자리 = 연결 전 ② 칸 + «연결 확인» · 연결 뒤 ③ 칸 + «로그인» · 제출 = 설정 동작 결과 글자.
// 🔴 시험 값은 이어 붙여 만든다.

import 'dart:async';
import 'dart:convert';

import 'package:app_operator_android/app/operator_onboarding.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operations_loader.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/secret/restart_login_slot.dart';
import 'package:app_operator_android/secret/supabase_connect_field.dart'
    show SupabaseConnectField;
import 'package:app_operator_android/secret/supabase_login_field.dart'
    show SupabaseLoginPanel;
import 'package:core_engine/core_engine.dart'
    show
        OperationsConfig,
        RestartFacts,
        RestartTexts,
        TrustedClock,
        onboardingStartVmOf,
        restartVmOf;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        RecoveryCardState,
        SqliteRecoveryCardStore,
        SqliteX1EmergencyStore,
        SupabaseAuth,
        SupabaseDeviceLedger,
        SupabaseSecretIds;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        GateState,
        LinkAction,
        OnboardingStartVm,
        OnboardingTrack,
        RestartVm;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ui_shell/ui_shell.dart'
    show OnboardingRestart, OnboardingStart, shellLinkOpenerProvider;

import '../engine/support.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
const String _uid = '11111111-2222-4333-8444-555555555555';
const String _me = 'dev-new-phone';

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

http.Response _json(Object body) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), 200);

/// Supabase 가짜(토큰 · 기기 표 · 리스 표).
class _Net {
  final List<http.Request> calls = <http.Request>[];
  Object devices = <Object?>[];
  Object lease = <Object?>[];
  int status = 200;
  int tokens = 0;

  late final http.Client client = MockClient((http.Request r) async {
    calls.add(r);
    if (r.url.path.startsWith('/auth/')) {
      tokens++;
      return _json(<String, Object?>{
        'access_token': 'acc-${'A' * 10}-$tokens',
        'expires_in': 3600,
        'refresh_token': 'ref-${'R' * 10}-$tokens',
        'user': <String, Object?>{'id': _uid},
      });
    }
    if (status != 200) return http.Response('', status);
    if (r.url.path == '/rest/v1/app_device') return _json(devices);
    if (r.url.path == '/rest/v1/operator_lease') return _json(lease);
    return http.Response('', 404);
  });
}

Map<String, String> _vault({bool connected = true, bool session = true}) =>
    <String, String>{
      ...connected
          ? <String, String>{
              'supabase.project_url': _url,
              'supabase.publishable_key': _pub,
            }
          : const <String, String>{},
      ...session
          ? <String, String>{'supabase.refresh_token': 'ref-${'R' * 10}-0'}
          : const <String, String>{},
    };

Map<String, Object?> _device(
  String id,
  String label, {
  String status = 'ACTIVE',
  DateTime? seen,
}) => <String, Object?>{
  'device_id': id,
  'label': label,
  'status': status,
  'platform': 'android',
  'last_seen_at': seen?.toIso8601String(),
};

Map<String, Object?> _leaseRow(String id, DateTime exp) => <String, Object?>{
  'device_id': id,
  'epoch': 3,
  'expires_at': exp.toIso8601String(),
};

List<String> _links(RestartVm vm) =>
    vm.branches.map((LinkAction b) => b.deepLink).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDownAll(deleteTempDirs);

  late OperationsConfig ops;
  setUpAll(() async => ops = await loadOperationsConfig(rootBundle));

  late FakeClock clock;
  late LedgerFiles files;
  late _Net net;
  late MemorySecretVault vault;
  late _Trusted trusted;
  int measures = 0;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 8, 9, 0));
    files = openFiles(tempLedgerDir(), clock);
    net = _Net();
    vault = MemorySecretVault(_vault());
    trusted = _Trusted(clock.nowUtc());
    measures = 0;
  });
  tearDown(() => files.close());

  OperatorRuntime runtime({
    bool ledger = true,
    Future<bool> Function()? refresh,
  }) {
    final SupabaseAuth auth = SupabaseAuth(net.client, vault, clock: clock);
    return OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: _me,
      trusted: trusted,
      refreshTrusted: refresh,
      vault: vault,
      kisHttp: net.client,
      supabaseAuth: auth,
      operations: ops,
      deviceLedger: ledger
          ? SupabaseDeviceLedger(net.client, vault, auth)
          : null,
    );
  }

  test(
    '🔴 첫 화면 재시작 링크 = 기기 원장 읽기 조립 있음 ⇔ 링크(operator = 조회 전용 카드 없음)',
    () async {
      final OnboardingStartVm on = await OperatorOnboardingRepository(runtime())
          .watchStart()
          .first;
      expect(on, onboardingStartVmOf(reconnectReady: true, viewerTrack: false));
      expect(
        on.tracks
            .singleWhere((c) => c.track == OnboardingTrack.reconnect)
            .deepLink,
        AppRoutes.onboardingRestart,
      );
      expect(
        await OperatorOnboardingRepository(runtime(ledger: false))
            .watchStart()
            .first,
        onboardingStartVmOf(reconnectReady: false, viewerTrack: false),
      );
      await expectLater(
        OperatorOnboardingRepository(runtime(ledger: false)).watchRestart(),
        emitsError(isA<UnsupportedError>()),
      );
    },
  );

  test('🔴 로그인 전(연결 전 · 세션 없음) = 로그인 자리 하나 · 원장 · 분기 0 · 망 0', () async {
    final RestartVm loggedOut = restartVmOf(
      const RestartFacts(signedIn: false),
    );
    for (final Map<String, String> v in <Map<String, String>>[
      _vault(connected: false, session: false),
      _vault(session: false),
    ]) {
      vault = MemorySecretVault(v);
      final RestartVm vm = await OperatorOnboardingRepository(runtime())
          .watchRestart()
          .first;
      expect(vm, loggedOut);
      expect(vm.loginSlotId, 'RECOVERY_LOGIN');
      expect(net.calls, isEmpty);
    }
  });

  test('🔴 로그인 뒤 · 구 폰이 리스를 쥠 = 원장 요약 · PASS · 계획 · 비상 · 승계 고지', () async {
    final DateTime now = clock.nowUtc();
    net
      ..devices = <Object?>[
        _device(
          'dev-old',
          '거실 폰',
          seen: now.subtract(const Duration(minutes: 3)),
        ),
        _device(_me, '운영 폰', status: 'PENDING'),
      ]
      ..lease = <Object?>[
        _leaseRow('dev-old', now.add(const Duration(minutes: 27))),
      ];
    final RestartVm vm = await OperatorOnboardingRepository(runtime())
        .watchRestart()
        .first;
    expect(vm.loginSlotId, isNull);
    expect(vm.ledgerLines, <String>[
      '구 폰: 거실 폰(Android)',
      '마지막 접속: 2026-12-08 08:57',
      '리스 남은 시간: 약 27분',
    ]);
    expect(vm.leaseGate!.state, GateState.pass);
    expect(_links(vm), <String>[
      AppRoutes.x1MigrationPlan,
      AppRoutes.x1MigrationEmergency,
    ]);
    expect(vm.inheritNotice, RestartTexts.inherit);
    // 🔴 읽기만(GET) · 쓰기 0.
    expect(
      net.calls
          .where((http.Request r) => r.url.path.startsWith('/rest/'))
          .map((http.Request r) => r.method)
          .toSet(),
      <String>{'GET'},
    );
  });

  test('🔴 리스 끝남 + 마지막 접속 갭 ≥ 운영 설정 기준(자산 7일) = 비상 이전 먼저(계약 v1.39 · 옛 폰 회수 뒤 새로 시작)', () async {
    final DateTime now = clock.nowUtc();
    expect(ops.resumeLadder!.backupGapDays, 7);
    net
      ..devices = <Object?>[
        _device('dev-old', '거실 폰', seen: now.subtract(const Duration(days: 9))),
      ]
      ..lease = <Object?>[
        _leaseRow('dev-old', now.subtract(const Duration(days: 9))),
      ];
    final RestartVm vm = await OperatorOnboardingRepository(runtime())
        .watchRestart()
        .first;
    expect(vm.leaseGate!.state, GateState.block);
    expect(vm.ledgerLines!.last, '마지막 접속 뒤 7일이 지났습니다');
    expect(_links(vm), <String>[AppRoutes.x1MigrationEmergency]);
    expect(vm.inheritNotice, RestartTexts.freshNotice);
  });

  test('🔴 신뢰 시각 모름 = 한 번 다시 잰다(잰 뒤 판정) · 못 재면 모름', () async {
    final DateTime now = clock.nowUtc();
    net
      ..devices = <Object?>[_device('dev-old', '거실 폰', seen: now)]
      ..lease = <Object?>[
        _leaseRow('dev-old', now.add(const Duration(minutes: 20))),
      ];
    trusted.at = null;
    final RestartVm unknown = await OperatorOnboardingRepository(
      runtime(
        refresh: () async {
          measures++;
          return false;
        },
      ),
    ).watchRestart().first;
    expect(measures, 1);
    expect(unknown.leaseGate!.state, GateState.unknown);
    expect(unknown.branches, isEmpty);
    final RestartVm known = await OperatorOnboardingRepository(
      runtime(
        refresh: () async {
          measures++;
          trusted.at = now;
          return true;
        },
      ),
    ).watchRestart().first;
    expect(measures, 2);
    expect(known.leaseGate!.state, GateState.pass);
  });

  test('🔴 이 폰이 쥠 — sim 비상 회수 기록이 있으면 «비상 이전 이어 하기» · 첫 클레임 기록만 = 분기 0 · 🆕 둘 다 0 = 이어 하기 + 안내(D-04)', () async {
    final DateTime now = clock.nowUtc();
    net
      ..devices = <Object?>[
        _device('dev-old', '거실 폰', status: 'REVOKED', seen: now),
        _device(_me, '운영 폰'),
      ]
      ..lease = <Object?>[_leaseRow(_me, now)];
    // 🆕 리뷰 3차 D-04(미결 236 ⓓ · R267) — 회수 응답 유실(서버 = 이 폰 · 이 폰 기록 0) = 막다른 길 대신 이어 하기 링크.
    final RestartVm lost = await OperatorOnboardingRepository(runtime())
        .watchRestart()
        .first;
    expect(lost.leaseGate!.state, GateState.pass);
    expect(_links(lost), <String>[AppRoutes.x1MigrationEmergency]);
    expect(lost.ledgerLines, contains(RestartTexts.revokeAnswerLost));
    SqliteRecoveryCardStore(files.sim, clock: clock).append(
      commandId: 'cmd-card-1',
      state: RecoveryCardState.claimed,
      hash: 'sha256:${'c' * 32}:${'d' * 64}',
      epoch: 3,
    );
    final RestartVm none = await OperatorOnboardingRepository(runtime())
        .watchRestart()
        .first;
    expect(none.leaseGate!.state, GateState.notApplicable);
    expect(none.branches, isEmpty);
    SqliteX1EmergencyStore(files.sim).recordRevoked(
      runId: 'rec-2026-12-08-1',
      decisionId: 'X1EMG-cmd-1',
      operatorEpoch: 3,
      revokedAtUtc: now,
      newCodeHash: 'sha256:${'a' * 32}:${'b' * 64}',
    );
    final RestartVm resume = await OperatorOnboardingRepository(runtime())
        .watchRestart()
        .first;
    expect(resume.leaseGate!.state, GateState.pass);
    expect(_links(resume), <String>[AppRoutes.x1MigrationEmergency]);
    expect(resume.branches.single.label, RestartTexts.branchEmergencyResume);
  });

  test('원장을 못 읽음(5xx) = 모름 · 분기 0', () async {
    net.status = 503;
    final RestartVm vm = await OperatorOnboardingRepository(runtime())
        .watchRestart()
        .first;
    expect(vm.ledgerLines, <String>[RestartTexts.ledgerUnread]);
    expect(vm.leaseGate!.state, GateState.unknown);
    expect(vm.branches, isEmpty);
  });

  test('🔴 poke = 다시 읽기 — 로그인 전 → (세션 생김) → 원장 요약', () async {
    final DateTime now = clock.nowUtc();
    net
      ..devices = <Object?>[_device('dev-old', '거실 폰', seen: now)]
      ..lease = <Object?>[
        _leaseRow('dev-old', now.add(const Duration(minutes: 10))),
      ];
    vault = MemorySecretVault(_vault(session: false));
    final OperatorOnboardingRepository repo = OperatorOnboardingRepository(
      runtime(),
    );
    final List<RestartVm> got = <RestartVm>[];
    final StreamSubscription<RestartVm> sub = repo.watchRestart().listen(
      got.add,
    );
    addTearDown(sub.cancel);
    Future<void> until(bool Function() ok) async {
      final Stopwatch w = Stopwatch()..start();
      while (!ok() && w.elapsed < const Duration(seconds: 5)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    await until(() => got.isNotEmpty);
    expect(got.single.loginSlotId, isNotNull);
    await vault.write(SupabaseSecretIds.refreshToken, 'ref-${'R' * 10}-9');
    repo.poke();
    await until(() => got.length > 1);
    expect(got.last.loginSlotId, isNull);
    expect(_links(got.last), <String>[
      AppRoutes.x1MigrationPlan,
      AppRoutes.x1MigrationEmergency,
    ]);
  });

  group('앱 안', () {
    late ProviderContainer container;

    Future<void> pump(WidgetTester tester, OperatorRuntime rt) async {
      container = ProviderContainer(overrides: operatorShellOverrides(rt));
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AutoAlphaQuantOperatorApp(shell: true),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    Future<void> open(WidgetTester tester, String link) async {
      container.read(shellLinkOpenerProvider).open(link);
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> done(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }

    testWidgets('🔴 O-00 링크 → R-01 · 연결 전 = ② 칸 + «연결 확인»', (
      WidgetTester tester,
    ) async {
      vault = MemorySecretVault(_vault(connected: false, session: false));
      await pump(tester, runtime());
      expect(find.byType(OnboardingStart), findsOneWidget);
      expect(tester.takeException(), isNull);
      await open(tester, AppRoutes.onboardingRestart);
      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingRestart), findsOneWidget);
      expect(find.text(RestartTexts.headline), findsOneWidget);
      expect(find.byType(RestartLoginSlot), findsOneWidget);
      expect(find.byType(SupabaseConnectField), findsOneWidget);
      expect(find.byType(SupabaseLoginPanel), findsNothing);
      expect(find.text('연결 확인'), findsOneWidget);
      expect(find.byKey(const Key('r01-branch-0')), findsNothing);
      await done(tester);
    });

    testWidgets('🔴 연결 뒤 = ③ 칸 + «로그인» · 제출 = 설정 동작 결과 글자(빈 칸 = 망 0)', (
      WidgetTester tester,
    ) async {
      vault = MemorySecretVault(_vault(session: false));
      await pump(tester, runtime());
      await open(tester, AppRoutes.onboardingRestart);
      expect(find.byType(SupabaseLoginPanel), findsOneWidget);
      expect(find.byType(SupabaseConnectField), findsNothing);
      await tester.tap(find.byKey(const Key('r01-login-submit')));
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('r01-login-result')), findsOneWidget);
      expect(net.calls, isEmpty);
      await done(tester);
    });
  });
}
