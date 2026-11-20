// M9 S09 백업·복원 operator 판(E11q-c2 · 설계 13 §8 R201 · 01 §33 K110~K112 · K133 · 미결 199 · 06 M4-12 ⑨).
//
// 🔴 읽기 = 엔진 `backupVmOf`(사실 = ds `backupScreenFactsOf` — 화면 원장 · 백업 폴더 · 아카이브 체크포인트 · epoch).
// 🔴 «지금 백업»(`backupRunNow{}`) = X1 스냅숏 `take`(ds `takeLedgerBackup`) · 결과 글자 = 엔진 `backupRunResultOf` ·
//    대상 = 지금 화면 원장(모의 = `X1_LIVE_ONLY` 그대로 — 엔진이 거부한다) · 만든 뒤 [revision] 을 올려 화면을 다시 낸다.
// 🔴 자리 = 원장 폴더 아래 `backup/`(스냅숏 · 매니페스트) · `backup_scratch/`(검증 사본 — 끝나면 비운다) — 앱 사설 저장소 ·
//    Android 클라우드 백업 · 기기 간 이전 = 전 도메인 제외(data_extraction_rules) → «이 폰 안에만».
// 🟡 바깥 올리기(`backup_upload` · GitHub 등) = 발주자 수치 D9 미정 → 칸 없음(지어내지 않는다).
// 🟡 아카이브 체크포인트 = 일일 아카이브 잡 등록(E11n · 원격 커밋과 함께) 전엔 없음 → `IN_SYNC` 아님 → 엔진이 버튼을 비운다(K133).
//    잡이 서면 [archive] 하나만 바꾼다.
// 🔵 생체 = 운영 등급 진입 관문(미결 169 — S10 R160 선례 · 동작마다 묻지 않는다 · 잠김 = 0).

import 'dart:io' show Directory;

import 'package:core_engine/core_engine.dart'
    show ArchiveCheckpoint, BackupScreenFacts, backupRunResultOf;
import 'package:data_sync/data_sync.dart'
    show
        SnapshotTakeResult,
        SqliteLeaseGate,
        backupScreenFactsOf,
        takeLedgerBackup;
import 'package:domain_contracts/domain_contracts.dart'
    show ActionResult, AppRoutes;
import 'package:flutter/foundation.dart' show ValueNotifier;

import 'operator_runtime.dart';
import 'operator_view.dart';

/// 백업 폴더 이름(원장 폴더 아래).
const String kOperatorBackupDir = 'backup';

/// 검증 사본 폴더 이름(원장 폴더 아래).
const String kOperatorBackupScratchDir = 'backup_scratch';

ArchiveCheckpoint? _noArchive() => null;

/// S09 백업 operator 판.
class OperatorBackup {
  /// 만든다 — [archive] = 지금 아카이브 체크포인트(기본 = 없음 · E11n 전).
  OperatorBackup(this._rt, {ArchiveCheckpoint? Function()? archive})
    : _archive = archive ?? _noArchive;

  final OperatorRuntime _rt;
  final ArchiveCheckpoint? Function() _archive;

  /// 백업을 만들 때마다 오른다(화면 다시 냄).
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// 백업 폴더.
  Directory get dir => Directory('${_rt.files.directory}/$kOperatorBackupDir');

  /// 검증 사본 폴더.
  Directory get scratch =>
      Directory('${_rt.files.directory}/$kOperatorBackupScratchDir');

  /// «지금 백업»을 낼 창구가 있나 — 설정 동작(금고 · 검증 HTTP — `operatorSettingsActionsProvider` 와 같은 조건) ∧ 이 기기 id.
  bool get canRun =>
      _rt.vault != null && _rt.kisHttp != null && _rt.deviceId != null;

  int _epoch(OperatorView v) =>
      SqliteLeaseGate(v.db, mode: v.flags.runMode, clock: _rt.clock).epoch();

  /// 🔴 지금 화면 사실(화면 상태 없음 = 오류).
  BackupScreenFacts facts({required bool Function(String route) hasBody}) {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('백업: 화면 상태 없음(온보딩 전)');
    return backupScreenFactsOf(
      v.db,
      dir: dir,
      archive: _archive(),
      operatorEpoch: _epoch(v),
      canRun: canRun,
      migrationLinkable: hasBody(AppRoutes.x1Migration),
      nowUtc: _rt.clock.nowUtc(),
    );
  }

  /// 🔴 «지금 백업» — args `{}` · 결과 = 엔진 글자 · 만들었으면 [revision] 올림.
  ActionResult run(String actionRunId, Map<String, String> args) {
    if (args.isNotEmpty) throw ArgumentError('backupRunNow args = {}');
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('백업: 화면 상태 없음(온보딩 전)');
    final String? id = _rt.deviceId;
    if (id == null) throw StateError('백업: 기기 id 없음');
    final SnapshotTakeResult r = takeLedgerBackup(
      v.db,
      dir: dir,
      scratch: scratch,
      archive: _archive(),
      deviceId: id,
      operatorEpoch: _epoch(v),
      nowUtc: _rt.clock.nowUtc(),
    );
    final ActionResult out = backupRunResultOf(
      actionRunId: actionRunId,
      rejectCode: r.rejectCode,
    );
    if (r.snapshot != null) revision.value++;
    return out;
  }

  /// 닫는다.
  void dispose() => revision.dispose();
}
