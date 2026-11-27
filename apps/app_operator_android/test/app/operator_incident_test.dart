// 🆕 E11q-d2 — M8 `D-01` 장애 배너 창구 조립(06 M4-12 ① 장애 override 의무) — 실 SQLite(sim · live 원장).
//
// 🔴 원천 = 화면 원장의 열린 사건 → 엔진 VM · 온보딩 전 = sim 원장(매매 전 = 배너 없음 · 오류 0) · 건이 열리면 배너 ·
//    닫히면 사라짐 · 가장 무거운 건 하나 · 바뀐 값만 · 화면 상태가 바뀌면 새 원장으로 옮긴다 · 못 읽음 = 오류 ·
//    조치 링크 = 레지스트리에 본문이 있을 때만(엔진 몫 — 여기선 주입만 본다).

import 'dart:async';

import 'package:app_operator_android/app/operator_incident.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart' show IncidentBannerTexts;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database, sqlite3;

import '../engine/support.dart';

OperatorView _viewOf(Database db) => OperatorView(
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

void _open(Database db, String id, String severity, {String? category}) =>
    db.execute(
      'INSERT INTO incidents(incident_id, occurred_at, severity, category, description, resolved_at, postmortem, due_at) '
      "VALUES (?, '2026-11-20T06:00:00.000Z', ?, ?, '설명', NULL, NULL, '2026-11-27T06:00:00.000Z')",
      <Object?>[id, severity, category ?? 'BREAKER_STOPPED'],
    );

void _close(Database db, String id) => db.execute(
  "UPDATE incidents SET resolved_at = '2026-11-22T00:00:00.000Z', postmortem = '정리' WHERE incident_id = ?",
  <Object?>[id],
);

const IncidentBannerVm _none = IncidentBannerVm();

/// 🆕 R282(미결 243 ⓐ · K345) — 기한 있는 미작성 건 = «써야 할 postmortem» 글자 · 조치 = `M5-4`(본문 있음) — 기한 = `_open` 의
/// 2026-11-27T06:00Z = 한국 11-27 15:00.
IncidentBannerVm _due(UiLevel level, String label) => IncidentBannerVm(
  banner: IncidentBanner(
    kind: IncidentKind.other,
    level: level,
    title: IncidentBannerTexts.postmortemDueTitle,
    bodyText: IncidentBannerTexts.postmortemDueBody(label, '11-27 15:00'),
    actionLink: IncidentBannerTexts.postmortemAction,
  ),
);

IncidentBannerVm _other(UiLevel level) => IncidentBannerVm(
  banner: IncidentBanner(
    kind: IncidentKind.other,
    level: level,
    title: IncidentBannerTexts.byKind[IncidentKind.other]!.title,
    bodyText: IncidentBannerTexts.byKind[IncidentKind.other]!.bodyText,
  ),
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 23, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  OperatorRuntime rt() => OperatorRuntime(files: files, clock: clock);

  bool all(String _) => true;

  test(
    '🔴 온보딩 전(화면 상태 없음) = sim 원장 · 열린 사건 0 → 배너 없음(오류 0) · 건이 열리면 배너 · 닫히면 사라짐',
    () async {
      final OperatorRuntime r = rt();
      expect(r.view.value, isNull);
      final List<IncidentBannerVm> got = <IncidentBannerVm>[];
      final List<Object> errors = <Object>[];
      final StreamSubscription<IncidentBannerVm> sub =
          OperatorIncidentRepository(
            r,
            hasBody: all,
          ).watchIncident().listen(got.add, onError: errors.add);
      await pumpEventQueue();
      expect(got, <IncidentBannerVm>[_none]);
      _open(
        files.sim,
        'SEV2-MANUAL_ORDER-d1',
        'SEV2',
        category: 'MANUAL_ORDER',
      );
      await pumpEventQueue();
      expect(got.last, _due(UiLevel.act, '수동 주문'));
      _close(files.sim, 'SEV2-MANUAL_ORDER-d1');
      await pumpEventQueue();
      expect(got, <IncidentBannerVm>[_none, _due(UiLevel.act, '수동 주문'), _none]);
      expect(errors, isEmpty);
      await sub.cancel();
    },
  );

  test('🔴 최대 1건 = 가장 무거운 건 · 바뀐 값만(가벼운 건이 더 열려도 다시 내지 않음)', () async {
    final OperatorRuntime r = rt();
    r.view.value = _viewOf(files.sim);
    final List<IncidentBannerVm> got = <IncidentBannerVm>[];
    final StreamSubscription<IncidentBannerVm> sub = OperatorIncidentRepository(
      r,
      hasBody: all,
    ).watchIncident().listen(got.add);
    await pumpEventQueue();
    _open(files.sim, 'SEV1-BREAKER_STOPPED-20261120', 'SEV1');
    await pumpEventQueue();
    _open(files.sim, 'SEV3-X', 'SEV3', category: 'X');
    await pumpEventQueue();
    _open(files.sim, 'SEV2-Y', 'SEV2', category: 'MANUAL_ORDER');
    await pumpEventQueue();
    expect(got, <IncidentBannerVm>[
      _none,
      _due(UiLevel.blocked, '서킷브레이커 STOPPED'),
    ]);
    // SEV1 이 닫히면(STOPPED 결정) 다음 무거운 건.
    _close(files.sim, 'SEV1-BREAKER_STOPPED-20261120');
    await pumpEventQueue();
    expect(got.last, _due(UiLevel.act, '수동 주문'));
    _close(files.sim, 'SEV2-Y');
    await pumpEventQueue();
    expect(got.last, _due(UiLevel.info, '안전 사건'));
    await sub.cancel();
  });

  test(
    '🔴 화면 상태가 바뀌면 새 원장으로 옮긴다(옛 원장 쓰기는 더 보지 않는다) · 같은 원장 = 감시 그대로',
    () async {
      final OperatorRuntime r = rt();
      r.view.value = _viewOf(files.sim);
      final List<IncidentBannerVm> got = <IncidentBannerVm>[];
      final StreamSubscription<IncidentBannerVm> sub =
          OperatorIncidentRepository(
            r,
            hasBody: all,
          ).watchIncident().listen(got.add);
      await pumpEventQueue();
      _open(files.sim, 'SEV1-sim', 'SEV1');
      await pumpEventQueue();
      expect(got.last, _due(UiLevel.blocked, '서킷브레이커 STOPPED'));
      r.view.value = _viewOf(files.sim); // 깨어남(같은 원장).
      await pumpEventQueue();
      expect(got, hasLength(2));
      final Database live = files.openLive();
      r.view.value = _viewOf(live);
      await pumpEventQueue();
      expect(got.last, _none);
      _close(files.sim, 'SEV1-sim');
      _open(files.sim, 'SEV2-sim', 'SEV2');
      await pumpEventQueue();
      expect(got.last, _none);
      _open(live, 'SEV2-live', 'SEV2');
      await pumpEventQueue();
      expect(got.last, _due(UiLevel.act, '서킷브레이커 STOPPED'));
      // 다른 원장으로 옮겨도 값이 같으면(둘 다 열린 SEV2) 다시 내지 않는다.
      final int n = got.length;
      r.view.value = _viewOf(files.sim);
      await pumpEventQueue();
      expect(got, hasLength(n));
      _close(files.sim, 'SEV2-sim');
      await pumpEventQueue();
      expect(got.last, _none);
      await sub.cancel();
    },
  );

  test('🔴 원장을 못 읽음 = 오류(지어내지 않는다 · 셸이 다시 시도 자리를 그린다)', () async {
    final Database broken = sqlite3.openInMemory();
    addTearDown(broken.close);
    final OperatorRuntime r = rt();
    r.view.value = _viewOf(files.sim);
    final List<Object> errors = <Object>[];
    final List<IncidentBannerVm> got = <IncidentBannerVm>[];
    final StreamSubscription<IncidentBannerVm> sub = OperatorIncidentRepository(
      r,
      hasBody: all,
    ).watchIncident().listen(got.add, onError: errors.add);
    await pumpEventQueue();
    expect(got, <IncidentBannerVm>[_none]);
    r.view.value = _viewOf(broken);
    await pumpEventQueue();
    expect(got, hasLength(1));
    expect(errors, hasLength(1));
    // 화면 상태가 고쳐지면 다시 값 — 오류 앞의 값과 같아도 다시 낸다(셸이 오류 자리를 걷는다).
    r.view.value = _viewOf(files.sim);
    await pumpEventQueue();
    expect(got, <IncidentBannerVm>[_none, _none]);
    await sub.cancel();
  });

  test('조치 링크 판정 = 주입한 hasBody 를 엔진에 넘긴다 — 🆕 R282 쓸 차례 = `M5-4` 를 묻는다 · 쓴 건 = 조치 없는 종류(묻지 않는다)', () async {
    final List<String> asked = <String>[];
    final OperatorRuntime r = rt();
    _open(files.sim, 'SEV1-a', 'SEV1');
    final OperatorIncidentRepository repo = OperatorIncidentRepository(
      r,
      hasBody: (String route) {
        asked.add(route);
        return false;
      },
    );
    final IncidentBannerVm v = await repo.watchIncident().first;
    expect(v.banner!.title, IncidentBannerTexts.postmortemDueTitle);
    expect(v.banner!.actionLink, isNull, reason: '본문 없음 = 조치 0');
    expect(asked, <String>[AppRoutes.m5Postmortem]);
    asked.clear();
    files.sim.execute(
      "UPDATE incidents SET postmortem = '썼다' WHERE incident_id = 'SEV1-a'",
    );
    expect(await repo.watchIncident().first, _other(UiLevel.blocked));
    expect(asked, isEmpty);
  });
}
