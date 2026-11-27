// 🆕 미결 243 ⓐ — `M5-4` postmortem 조립(설계 13 §8 R282 · R243 P4 · 계약 v1.39 K345) — 실 SQLite(sim 원장).
//
// 🔴 읽기 = 화면 원장의 열린 의무 건 → 엔진 VM(차례 · 글자 · 기한) · 사건 표가 바뀌면 다시 낸다 · 쓰기 = 안전 동작 `runPostmortem`
//    (엔진 저장 · 판정 · 결과 글자) · SEV2 = 쓰면 닫혀 목록 · 배너에서 빠진다 · SEV1 = 쓴 채 남는다 · 배너 «postmortem 쓰기» =
//    레지스트리에 `M5-4` 본문이 있어서 선다.

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_incident.dart';
import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_postmortem.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show PostmortemTexts, postmortemAsOf, postmortemListVmOf;
import 'package:data_sync/data_sync.dart' show openIncidentsOf;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

const FeatureFlags _simFlags = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  configHash: 'cfg_test',
);

bool _registry(String route) =>
    kOperatorRouteBodies.byPattern.containsKey(route);

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

  setUp(() {
    clock = FakeClock(kst(2026, 9, 1, 18, 0));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  OperatorRuntime rt() {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: 'dev-1',
    );
    r.view.value = OperatorView(db: files.sim, flags: _simFlags);
    return r;
  }

  void incident(
    Database db,
    String id,
    String severity,
    String category, {
    required String at,
    required String due,
  }) => db.execute(
    'INSERT INTO incidents(incident_id, occurred_at, severity, category, description, due_at) '
    "VALUES (?, ?, ?, ?, 'd', ?)",
    <Object?>[id, at, severity, category, due],
  );

  void seed(Database db) {
    incident(
      db,
      'SEV2-MANUAL_ORDER-J1',
      'SEV2',
      'MANUAL_ORDER',
      at: '2026-09-01T01:12:00.000Z',
      due: '2026-09-08T01:12:00.000Z',
    );
    incident(
      db,
      'SEV1-BREAKER_STOPPED-2026-08-28',
      'SEV1',
      'BREAKER_STOPPED',
      at: '2026-08-28T05:02:00.000Z',
      due: '2026-08-31T05:02:00.000Z',
    );
  }

  test('🔴 레지스트리 = M5-4 본문 등록(D-01 배너 · 셸 링크 목적지)', () {
    expect(_registry(AppRoutes.m5Postmortem), isTrue);
  });

  test('🔴 읽기 = 엔진 VM(화면 원장 · 차례 · 기한) → 쓰기(SEV2) = 닫혀 목록 · 배너에서 빠짐 · SEV1 = 쓴 채 남음 · 결과 = 엔진 글자', () async {
    seed(files.sim);
    final OperatorRuntime r = rt();
    int wakes = 0;
    r.attachWake(() async => wakes++);
    final List<PostmortemListVm> got = <PostmortemListVm>[];
    final StreamSubscription<PostmortemListVm> sub =
        OperatorPostmortemRepository(
          r,
          hasBody: _registry,
          tick: const Duration(hours: 1),
        ).watchPostmortems().listen(got.add);
    addTearDown(sub.cancel);
    final List<IncidentBannerVm> banners = <IncidentBannerVm>[];
    final StreamSubscription<IncidentBannerVm> bsub =
        OperatorIncidentRepository(
          r,
          hasBody: _registry,
        ).watchIncident().listen(banners.add);
    addTearDown(bsub.cancel);
    await until(() => got.isNotEmpty && banners.isNotEmpty);
    final DateTime now = clock.nowUtc();
    expect(
      got.last,
      postmortemListVmOf(
        openIncidentsOf(files.sim),
        nowUtc: now,
        asOf: postmortemAsOf(now),
        canWrite: true,
        hasBody: _registry,
      ),
    );
    // SEV1(기한 넘김) → SEV2 차례 · 둘 다 쓸 차례 · 칸.
    expect(got.last.rows.map((PostmortemRow x) => x.incidentId), <String>[
      'SEV1-BREAKER_STOPPED-2026-08-28',
      'SEV2-MANUAL_ORDER-J1',
    ]);
    expect(got.last.headline, PostmortemTexts.headlineOverdue(1));
    // 배너 = 가장 급한 SEV1 «써야 할 postmortem» · 조치 = M5-4(레지스트리 본문 있음).
    expect(banners.last.banner?.actionLink?.deepLink, AppRoutes.m5Postmortem);

    final OperatorSafetyActions a = OperatorSafetyActions(r, random: Random(4));
    final SafetyActionResult blank = await a.runPostmortem(
      const PostmortemSubmission(
        incidentId: 'SEV2-MANUAL_ORDER-J1',
        text: '   ',
      ),
    );
    expect(
      (blank.id, blank.reasonCode, blank.headline),
      (
        SafetyActionId.postmortemRecord,
        'POSTMORTEM_BLANK',
        PostmortemTexts.blank,
      ),
    );
    expect(wakes, 0, reason: '거부 = 전이 아님');
    final SafetyActionResult sev2 = await a.runPostmortem(
      const PostmortemSubmission(
        incidentId: 'SEV2-MANUAL_ORDER-J1',
        text: '원인 · 영향 · 바꿀 것',
      ),
    );
    expect(
      (sev2.reasonCode, sev2.level, sev2.headline),
      (null, UiLevel.ok, PostmortemTexts.saved),
    );
    expect(await a.watch(sev2.actionRunId).first, sev2);
    expect(wakes, 1);
    await until(() => got.last.rows.length == 1);
    expect(got.last.rows.single.incidentId, 'SEV1-BREAKER_STOPPED-2026-08-28');
    final SafetyActionResult sev1 = await a.runPostmortem(
      const PostmortemSubmission(
        incidentId: 'SEV1-BREAKER_STOPPED-2026-08-28',
        text: '정지 원인',
      ),
    );
    expect(sev1.reasonCode, isNull);
    await until(() => got.last.rows.single.writtenText == '정지 원인');
    final PostmortemRow written = got.last.rows.single;
    expect(
      (written.form, written.stateLabel, written.nextLink),
      (null, PostmortemTexts.stateWrittenStopped, null),
      reason: 'M5-3 STOPPED 결정 본문 없음 = 링크 0',
    );
    // 쓴 SEV1 = 배너는 기존 other 글자(조치 0).
    await until(() => banners.last.banner?.actionLink == null);
    // 다시 쓰기 = 이미 있음 · 모르는 건 = 건 없음.
    expect(
      (await a.runPostmortem(
        const PostmortemSubmission(
          incidentId: 'SEV1-BREAKER_STOPPED-2026-08-28',
          text: '또',
        ),
      )).reasonCode,
      'POSTMORTEM_ALREADY_RECORDED',
    );
    expect(
      (await a.runPostmortem(
        const PostmortemSubmission(incidentId: 'NOPE', text: '글'),
      )).reasonCode,
      'INCIDENT_NOT_FOUND',
    );
  });

  test('화면 상태 없음 = 읽기 오류 · 쓰기 오류(지어내지 않는다)', () async {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: 'dev-1',
    );
    await expectLater(
      OperatorPostmortemRepository(
        r,
        hasBody: _registry,
      ).watchPostmortems().first,
      throwsA(isA<StateError>()),
    );
    await expectLater(
      OperatorSafetyActions(
        r,
        random: Random(4),
      ).runPostmortem(const PostmortemSubmission(incidentId: 'X', text: '글')),
      throwsA(isA<StateError>()),
    );
  });
}
