// E11q-c2 — M9 S09 백업·복원 operator 판(설계 13 §8 R201 · 01 §33 K110~K112 · K133 · 미결 199) — 실 SQLite(sim · live 원장) ·
// 실 X1 `take` · 실 아카이브 체크포인트.
//
// 🔴 읽기 = 엔진 `backupVmOf` · «지금 백업» = X1 `take`(기기 안 · 원장 폴더 `backup/`) · 결과 = 엔진 글자 ·
//    모의 = X1_LIVE_ONLY · 스탬프 0 · 아카이브 없음(E11n 전) = 버튼 부재 + 까닭 고지 · 만들면 화면이 다시 낸다 · 바깥 올리기 0.

import 'dart:async';
import 'dart:io';

import 'package:app_operator_android/app/operator_backup.dart';
import 'package:app_operator_android/app/operator_ops_status.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisRestClient;
import 'package:core_engine/core_engine.dart'
    show
        ArchiveCheckpoint,
        BackupRunTexts,
        BackupScreenTexts,
        MigrationStartCodes,
        RestoreReason,
        SnapshotCodes;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show LedgerArchiveWriter, LedgerHashStamper, ModeAxis, SqliteModeStore;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

Future<void> until(bool Function() ok) async {
  for (int i = 0; i < 300 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue);
}

const FeatureFlags _simFlags = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  configHash: '',
);

const FeatureFlags _liveFlags = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.live,
  operatingMode: OperatingMode.autoTrade,
  configHash: '',
);

List<String> _ls(Directory d) => d.existsSync()
    ? (<String>[
        for (final FileSystemEntity e in d.listSync()) e.uri.pathSegments.last,
      ]..sort())
    : const <String>[];

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;
  late LedgerFiles files;
  late Directory archiveRoot;
  setUp(() {
    // 한국 2027-01-14 07:20 — 01-13 까지 끝났다.
    clock = FakeClock(kst(2027, 1, 14, 7, 20));
    final Directory dir = tempLedgerDir();
    files = openFiles(dir, clock);
    archiveRoot = Directory('${dir.path}/archive_repo')..createSync();
  });
  tearDown(() => files.close());

  /// live 원장 — 이틀 전 모드 행(장부 기록) · [stampThrough] 까지 스탬프.
  Database live({String? stampThrough}) {
    final Database db = files.openLive();
    final DateTime now = clock.now;
    clock.now = kst(2027, 1, 12, 9, 0);
    final String? denied = SqliteModeStore(db, LedgerFile.live, clock: clock)
        .record(
          axis: ModeAxis.runMode,
          runMode: RunMode.live,
          execPolicy: ExecPolicy.dryRun,
          operatingMode: OperatingMode.autoTrade,
          handoverSessionValid: true,
          decisionId: 'D-LIVE',
        );
    if (denied != null) throw StateError(denied);
    // 해시 모집단 행 하나(스탬프 재료 · simToAuto 커밋의 live 몫 흉내 — support `writeLiveMode` 와 같은 꼴).
    db.execute(
      'INSERT INTO operating_mode_transition (transition_id, handover_session_id, from_mode, to_mode, decision_id, committed_at) '
      "VALUES ('OT-1', 'HS-1', ?, ?, 'D-LIVE', ?)",
      <Object?>[
        OperatingMode.autoTrade.wire,
        OperatingMode.autoTrade.wire,
        clock.nowUtc().toIso8601String(),
      ],
    );
    clock.now = now;
    if (stampThrough != null) {
      LedgerHashStamper(db, clock: clock).stampThrough(stampThrough);
    }
    return db;
  }

  LedgerArchiveWriter writer(Database db) => LedgerArchiveWriter(
    db,
    root: archiveRoot.path,
    mode: RunMode.live,
    clock: clock,
    writerDeviceId: 'dev-c2',
    operatorEpoch: 0,
  );

  OperatorRuntime runtime({
    Database? view,
    bool vault = true,
    String? deviceId = 'dev-c2',
  }) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      vault: vault ? MemorySecretVault() : null,
      kisHttp: vault
          ? MockClient((http.Request _) async => http.Response('{}', 500))
          : null,
      deviceId: deviceId,
    );
    if (view != null) {
      r.view.value = OperatorView(
        db: view,
        flags: view == files.sim ? _simFlags : _liveFlags,
      );
    }
    return r;
  }

  OperatorSettingsActions actions(OperatorRuntime r, OperatorBackup b) =>
      OperatorSettingsActions(
        secrets: r.secrets,
        vault: r.vault!,
        clientOf: (KisCredentials c) =>
            KisRestClient(r.kisHttp!, c, environment: c.environment),
        clock: clock,
        backup: b,
      );

  Future<BackupVm> first(OperatorOpsStatusRepository repo) =>
      repo.watchBackup().first;

  test(
    '🔴 화면 상태 없음(온보딩 전) = 읽기 오류 · 동작 오류(지어내지 않는다) · 백업 없는 조립 = 원천 없음',
    () async {
      final OperatorRuntime r = runtime();
      final OperatorBackup b = OperatorBackup(r);
      addTearDown(b.dispose);
      await expectLater(
        OperatorOpsStatusRepository(r, backup: b).watchBackup(),
        emitsError(isA<StateError>()),
      );
      expect(() => b.run('x', const <String, String>{}), throwsStateError);
      await expectLater(
        OperatorOpsStatusRepository(r).watchBackup(),
        emitsError(isA<UnsupportedError>()),
      );
    },
  );

  test(
    '🔴 모의 원장 = 버튼 · 링크 부재 + 모의 고지 · 눌러도 X1_LIVE_ONLY(엔진 거부) · 파일 0',
    () async {
      final OperatorRuntime r = runtime(view: files.sim);
      final OperatorBackup b = OperatorBackup(r);
      addTearDown(b.dispose);
      final BackupVm vm = await first(
        OperatorOpsStatusRepository(r, backup: b, hasBody: (_) => true),
      );
      expect(vm.runAction, isNull);
      expect(vm.migrationLink, isNull);
      expect(vm.noticeText, BackupScreenTexts.simNotice);
      expect(vm.lastBackupText, BackupScreenTexts.simNever);
      final ActionResult res = await actions(
        r,
        b,
      ).run(SettingsActionId.backupRunNow);
      expect(
        (res.id, res.level, res.headline, res.reasonCode),
        (
          SettingsActionId.backupRunNow,
          UiLevel.info,
          BackupRunTexts.liveOnly,
          MigrationStartCodes.liveOnly,
        ),
      );
      expect(_ls(b.dir), isEmpty);
    },
  );

  test(
    '🔴 live · 스탬프 0 = 버튼 부재 + «마감된 장부가 없어» · 눌러도 SNAPSHOT_NO_STAMP',
    () async {
      final Database db = live();
      final OperatorRuntime r = runtime(view: db);
      final OperatorBackup b = OperatorBackup(r);
      addTearDown(b.dispose);
      final BackupVm vm = await first(
        OperatorOpsStatusRepository(r, backup: b),
      );
      expect(vm.runAction, isNull);
      expect(vm.noticeText, BackupScreenTexts.noStampNotice);
      expect(vm.lastBackupText, BackupScreenTexts.never);
      expect(
        b.run('x', const <String, String>{}).reasonCode,
        SnapshotCodes.noStamp,
      );
      expect(_ls(b.dir), isEmpty);
    },
  );

  test('🔴 live · 스탬프 · 아카이브 체크포인트 없음(E11n 전 = 지금 기본) = 버튼 부재 + 아카이브 대기 고지(K133) · 눌러도 RESTORE_ROLLBACK · 파일 0', () async {
    final Database db = live(stampThrough: '2027-01-13');
    final OperatorRuntime r = runtime(view: db);
    final OperatorBackup b = OperatorBackup(r);
    addTearDown(b.dispose);
    final BackupVm vm = await first(OperatorOpsStatusRepository(r, backup: b));
    expect(vm.runAction, isNull);
    expect(vm.noticeText, BackupScreenTexts.archiveWaitNotice);
    final ActionResult res = await actions(
      r,
      b,
    ).run(SettingsActionId.backupRunNow);
    expect(
      (res.level, res.headline, res.reasonCode),
      (UiLevel.watch, BackupRunTexts.rollback, RestoreReason.rollback.wire),
    );
    expect(_ls(b.dir), isEmpty);
    expect(_ls(b.scratch), isEmpty);
  });

  test('🔴 live · 아카이브 IN_SYNC = 버튼 → 지금 백업 = 기기 안 지점 1(이름 = 만든 시각) · 화면이 다시 낸다(지점 · 마지막 백업 · 상태 줄) · '
      '같은 분 = SNAPSHOT_EXISTS · watch = 같은 결과', () async {
    final Database db = live(stampThrough: '2027-01-13');
    final LedgerArchiveWriter w = writer(db)..archiveStamped();
    final OperatorRuntime r = runtime(view: db);
    final OperatorBackup b = OperatorBackup(r, archive: w.readCheckpoint);
    addTearDown(b.dispose);
    final List<BackupVm> got = <BackupVm>[];
    final StreamSubscription<BackupVm> sub = OperatorOpsStatusRepository(
      r,
      backup: b,
    ).watchBackup().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(got.last.runAction?.id, SettingsActionId.backupRunNow);
    expect(got.last.noticeText, BackupScreenTexts.notice);
    expect(got.last.points, isEmpty);
    expect(got.last.migrationLink, isNull, reason: 'X1 본문 없음 = 링크 부재');

    final OperatorSettingsActions a = actions(r, b);
    final ActionResult ok = await a.run(SettingsActionId.backupRunNow);
    expect(
      (ok.level, ok.headline, ok.reasonCode, ok.retryable),
      (UiLevel.ok, BackupRunTexts.done, null, false),
    );
    expect(await a.watch(ok.actionRunId).first, ok);
    expect(_ls(b.dir), <String>[
      'bk_20270113T2220Z.manifest.json',
      'bk_20270113T2220Z.sqlite',
    ]);
    expect(_ls(b.scratch), isEmpty);
    await until(() => got.last.points.isNotEmpty);
    final BackupVm vm = got.last;
    expect(vm.lastBackupText, '마지막 백업 01-14 07:20');
    expect(vm.level, UiLevel.ok);
    final ArchiveCheckpoint cp = w.readCheckpoint()!;
    expect(vm.points.single.label, '01-14 07:20 만듦 · 01-13 장부까지');
    expect(vm.points.single.chainHashText, cp.chainHash.substring(0, 8));
    expect(vm.points.single.stateLabel, BackupScreenTexts.pointVerified);

    clock.now = clock.now.add(const Duration(seconds: 30));
    final ActionResult again = await a.run(SettingsActionId.backupRunNow);
    expect(again.reasonCode, SnapshotCodes.exists);
    expect(again.level, UiLevel.info);
    expect(_ls(b.dir), hasLength(2), reason: '덮지 않는다');
  });

  test(
    '🔴 창구 없음(금고 · 검증 HTTP · 기기 id) = 버튼 부재 · args ≠ {} = 거부(쓰기 0)',
    () async {
      final Database db = live(stampThrough: '2027-01-13');
      final LedgerArchiveWriter w = writer(db)..archiveStamped();
      for (final OperatorRuntime r in <OperatorRuntime>[
        runtime(view: db, vault: false),
        runtime(view: db, deviceId: null),
      ]) {
        final OperatorBackup b = OperatorBackup(r, archive: w.readCheckpoint);
        addTearDown(b.dispose);
        expect(
          (await first(OperatorOpsStatusRepository(r, backup: b))).runAction,
          isNull,
        );
      }
      final OperatorRuntime r = runtime(view: db);
      final OperatorBackup b = OperatorBackup(r, archive: w.readCheckpoint);
      addTearDown(b.dispose);
      await expectLater(
        actions(r, b).run(
          SettingsActionId.backupRunNow,
          args: const <String, String>{'name': 'x'},
        ),
        throwsArgumentError,
      );
      expect(_ls(b.dir), isEmpty);
    },
  );

  test('🔴 X1 기기 이전 본문이 있을 때만 링크(막다른 길 0) · 백업 없는 설정 동작 = 구현 없음', () async {
    final Database db = live(stampThrough: '2027-01-13');
    final LedgerArchiveWriter w = writer(db)..archiveStamped();
    final OperatorRuntime r = runtime(view: db);
    final OperatorBackup b = OperatorBackup(r, archive: w.readCheckpoint);
    addTearDown(b.dispose);
    final BackupVm vm = await first(
      OperatorOpsStatusRepository(
        r,
        backup: b,
        hasBody: (String route) => route == AppRoutes.x1Migration,
      ),
    );
    expect(vm.migrationLink?.deepLink, AppRoutes.x1Migration);
    expect(vm.migrationLink?.label, BackupScreenTexts.migration);
    await expectLater(
      OperatorSettingsActions(
        secrets: r.secrets,
        vault: r.vault!,
        clientOf: (KisCredentials c) =>
            KisRestClient(r.kisHttp!, c, environment: c.environment),
        clock: clock,
      ).run(SettingsActionId.backupRunNow),
      throwsUnsupportedError,
    );
  });
}
