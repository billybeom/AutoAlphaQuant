// X1-6 감시 유지보수 창 실행기(설계 13 §8 R139 U4~U6 · SPEC v2.45 04 §5-2 · core `WatchdogRemote`).
//
// 🔴 열기 = 바깥 체크 목록 → 창 열기(core `pausableChecksOf` · `engine_alive` 0) → 창의 멈춘 목록을 하나씩 pause ·
//    멈춤 실패 = 돌려준다(창은 열린 채 — 감시가 더 울리는 쪽이 안전) · 체크 목록 못 받음 = 던진다(창 0).
// 🔴 깨어남 = tick(넘김 P1 = 저장소) → 재개 시도 = 멈춘 목록 resume · 하나라도 실패(거짓 · 던짐) = RESUME_FAILED
//    (P0 부팅당 1건) · 창은 열린 채 · 전부 성공 = 닫기(신뢰 시각 모름 = 닫지 못함 — 결과에 실린다).
// 🟡 부팅 훅 · 새 폰 첫 핑 · bootId 원천 = E16t2.

import 'package:core_engine/core_engine.dart'
    show
        PauseReason,
        RemoteCheck,
        WatchdogRemote,
        WindowAction,
        WindowRaiseOverdue,
        WindowTryResume;
import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode;

import 'maintenance_window_store.dart' show SqliteMaintenanceWindowStore;

/// 창 열기 결과.
typedef WindowOpenReport = ({
  String? windowId,
  String? rejectCode,
  List<String> pauseFailed,
});

/// 깨어남 결과(열린 창 없음 = 빈 결과).
typedef WindowWakeReport = ({
  String? windowId,
  bool overdue,
  List<String> resumed,
  List<String> notResumed,
  bool closed,
  String? closeRejectCode,
  bool resumeFailedRecorded,
});

/// 유지보수 창 실행기.
class MaintenanceWindowRunner {
  /// 만든다.
  MaintenanceWindowRunner(this._store, {required this._remote});

  final SqliteMaintenanceWindowStore _store;
  final WatchdogRemote _remote;

  /// 🔴 창을 열고 멈춘다.
  Future<WindowOpenReport> open({
    required RunMode runMode,
    required OperatingMode operatingMode,
    String? runId,
  }) async {
    final List<RemoteCheck> checks = await _remote.checks();
    final ({String? windowId, String? rejectCode}) r = _store.open(
      checkSlugs: <String>[for (final RemoteCheck c in checks) c.slug],
      runMode: runMode,
      operatingMode: operatingMode,
      runId: runId,
    );
    final String? id = r.windowId;
    if (id == null) {
      return (
        windowId: null,
        rejectCode: r.rejectCode,
        pauseFailed: const <String>[],
      );
    }
    final List<String> failed = <String>[];
    for (final String slug in _store.pausedChecksOf(id)) {
      try {
        await _remote.pause(slug, reason: PauseReason.maintenanceWindow);
      } on Object {
        failed.add(slug);
      }
    }
    return (windowId: id, rejectCode: null, pauseFailed: failed);
  }

  /// 🔴 깨어남 — 넘김 · 재개 시도 · 닫기 또는 재개 실패 기록.
  Future<WindowWakeReport> onWake({
    required Duration overdueAfter,
    required bool booting,
    required String bootId,
  }) async {
    final List<WindowAction> actions = _store.tick(
      overdueAfter: overdueAfter,
      booting: booting,
    );
    String? windowId;
    bool overdue = false;
    final List<String> resumed = <String>[];
    final List<String> notResumed = <String>[];
    bool closed = false;
    String? closeReject;
    bool recorded = false;
    for (final WindowAction a in actions) {
      switch (a) {
        case WindowRaiseOverdue(windowId: final String id):
          windowId = id;
          overdue = true;
        case WindowTryResume(windowId: final String id):
          windowId = id;
          for (final String slug in _store.pausedChecksOf(id)) {
            bool ok;
            try {
              ok = await _remote.resume(
                slug,
                reason: PauseReason.maintenanceWindow,
              );
            } on Object {
              ok = false;
            }
            (ok ? resumed : notResumed).add(slug);
          }
          if (notResumed.isEmpty) {
            closeReject = _store.close(id);
            closed = closeReject == null;
          } else {
            recorded = _store.recordResumeFailed(
              windowId: id,
              bootId: bootId,
              notResumed: notResumed,
            );
          }
      }
    }
    return (
      windowId: windowId,
      overdue: overdue,
      resumed: resumed,
      notResumed: notResumed,
      closed: closed,
      closeRejectCode: closeReject,
      resumeFailedRecorded: recorded,
    );
  }
}
