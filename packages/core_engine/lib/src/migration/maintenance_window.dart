// X1-6 감시 유지보수 창 판정(순수 · 설계 13 §8 R117 B8 · SPEC v2.45 04 §5-2 · 02 §2-6 `maintenance_window`).
//
// 🔴 멈출 체크 = 그 모드 접두 ∧ `pausePermitted(maintenanceWindow)` — 엔진 생존 체크는 멈추지 않는다.
// 🔴 사건 = OPENED 하나 먼저 · CLOSED 뒤 사건 0 · 넘김(P1) = 창당 1건 · 재개 실패(P0) = 부팅 id 마다 1건.
// 🔴 넘김 판정 = 신뢰 시각 − 열림 ≥ T(인자 · 값 = `maintenance_overdue_hours`) · 시각 모름 = 판정하지 않는다.

import 'package:domain_contracts/domain_contracts.dart'
    show AlertCodes, MaintenanceWindowEventCodes, OperatingMode, RunMode;

import '../ops/ledger_views.dart' show kstDateText;
import '../ops/watchdog_ports.dart'
    show PauseReason, pausePermitted, watchdogCheckPrefix, watchdogPrefixOf;

/// 창 사건(02 `maintenance_window.event`).
enum WindowEvent {
  /// 열림.
  opened(MaintenanceWindowEventCodes.opened),

  /// 넘김(P1 · 창당 1건).
  overdue(MaintenanceWindowEventCodes.overdue),

  /// 닫힘.
  closed(MaintenanceWindowEventCodes.closed),

  /// 부팅 때 재개 실패(P0 · 부팅당 1건).
  resumeFailed(MaintenanceWindowEventCodes.resumeFailed);

  const WindowEvent(this.wire);

  /// 저장 글자.
  final String wire;

  /// 저장 글자 → 값(모르면 [FormatException]).
  static WindowEvent parse(String w) => values.firstWhere(
    (WindowEvent e) => e.wire == w,
    orElse: () => throw FormatException('maintenance_window.event', w),
  );
}

/// 창 id — `mw-{열린 한국 날}-{순번}`.
String maintenanceWindowIdOf(DateTime trustedNowUtc, int seq) {
  if (seq < 1) throw ArgumentError.value(seq, 'seq', '1 이상');
  return 'mw-${kstDateText(trustedNowUtc)}-$seq';
}

/// 사건 id — `{창}:{사건}` · 재개 실패만 `{창}:RESUME_FAILED:{부팅 id}`(부팅 id 필수).
String windowEventIdOf(String windowId, WindowEvent e, {String? bootId}) {
  if (e == WindowEvent.resumeFailed) {
    if (bootId == null || bootId.isEmpty) {
      throw ArgumentError.notNull('bootId');
    }
    return '$windowId:${e.wire}:$bootId';
  }
  if (bootId != null) {
    throw ArgumentError.value(bootId, 'bootId', '재개 실패에만');
  }
  return '$windowId:${e.wire}';
}

/// 🔴 창을 열 때 멈출 체크 — 그 모드 접두 ∧ 멈춰도 되는 것(엔진 생존 0) · 이름 차례.
List<String> pausableChecksOf(
  Iterable<String> slugs, {
  required RunMode runMode,
  required OperatingMode operatingMode,
}) {
  final String prefix = watchdogCheckPrefix(runMode, operatingMode);
  return slugs
      .where(
        (String s) =>
            watchdogPrefixOf(s) == prefix &&
            pausePermitted(s, PauseReason.maintenanceWindow),
      )
      .toSet()
      .toList()
    ..sort();
}

/// `maintenance_window` 한 행.
class WindowEventRow {
  /// 만든다.
  const WindowEventRow({
    required this.windowId,
    required this.event,
    required this.atUtc,
  });

  /// 창 id.
  final String windowId;

  /// 사건 글자.
  final String event;

  /// 시각(UTC).
  final DateTime atUtc;
}

/// 창 하나의 상태.
class WindowState {
  const WindowState._({
    required this.windowId,
    required this.openedAtUtc,
    required this.overdueRaised,
    required this.closed,
  });

  /// 창 id.
  final String windowId;

  /// 열린 시각.
  final DateTime openedAtUtc;

  /// 넘김을 이미 냈나.
  final bool overdueRaised;

  /// 닫혔나.
  final bool closed;
}

/// 🔴 사건 행 → 창 상태 — OPENED 하나 먼저 · 하나만 · CLOSED 뒤 사건 = [StateError].
///
/// [rows] 는 한 창의 행이어야 한다(다른 창 = [StateError]) · 시각 차례로 읽는다.
WindowState windowStateOf(String windowId, Iterable<WindowEventRow> rows) {
  // 같은 시각이면 열림 → 넘김 → 재개 실패 → 닫힘 차례(정렬이 안정하지 않아도 같은 답).
  int rank(WindowEventRow x) => switch (WindowEvent.parse(x.event)) {
    WindowEvent.opened => 0,
    WindowEvent.overdue => 1,
    WindowEvent.resumeFailed => 2,
    WindowEvent.closed => 3,
  };
  final List<WindowEventRow> r = rows.toList()
    ..sort((WindowEventRow a, WindowEventRow b) {
      final int t = a.atUtc.compareTo(b.atUtc);
      return t != 0 ? t : rank(a).compareTo(rank(b));
    });
  if (r.isEmpty) throw StateError('창 $windowId 사건 0');
  DateTime? opened;
  bool overdue = false;
  bool closed = false;
  for (final WindowEventRow x in r) {
    if (x.windowId != windowId) {
      throw StateError('다른 창의 사건이 섞였다: ${x.windowId}');
    }
    final WindowEvent e = WindowEvent.parse(x.event);
    if (closed) throw StateError('닫힌 창 $windowId 뒤 사건: ${e.wire}');
    if (opened == null) {
      if (e != WindowEvent.opened) {
        throw StateError('창 $windowId 첫 사건이 OPENED 가 아니다: ${e.wire}');
      }
      opened = x.atUtc;
      continue;
    }
    switch (e) {
      case WindowEvent.opened:
        throw StateError('창 $windowId OPENED 가 둘');
      case WindowEvent.overdue:
        if (overdue) throw StateError('창 $windowId OVERDUE 가 둘');
        overdue = true;
      case WindowEvent.closed:
        closed = true;
      case WindowEvent.resumeFailed:
        break;
    }
  }
  return WindowState._(
    windowId: windowId,
    openedAtUtc: opened!,
    overdueRaised: overdue,
    closed: closed,
  );
}

/// 창 판정이 시키는 일.
sealed class WindowAction {
  const WindowAction();
}

/// 넘김 — P1 `MAINTENANCE_WINDOW_OVERDUE` 1건 + OVERDUE 행.
final class WindowRaiseOverdue extends WindowAction {
  /// 만든다.
  const WindowRaiseOverdue(this.windowId);

  /// 창.
  final String windowId;

  /// 알림 코드.
  String get alertCode => AlertCodes.maintenanceWindowOverdue;
}

/// 부팅 때 열린 창 — 멈춘 체크 재개를 시도한다.
final class WindowTryResume extends WindowAction {
  /// 만든다.
  const WindowTryResume(this.windowId);

  /// 창.
  final String windowId;
}

/// 🔴 열린 창 판정 — 닫힌 창 = 할 일 0 · 넘김(신뢰 시각 − 열림 ≥ [overdueAfter] ∧ 아직 안 냄) · 부팅 = 재개 시도.
List<WindowAction> windowActionsOf(
  WindowState w, {
  required DateTime? trustedNowUtc,
  required Duration overdueAfter,
  required bool booting,
}) {
  if (overdueAfter <= Duration.zero) {
    throw ArgumentError.value(overdueAfter, 'overdueAfter', '0 보다 커야');
  }
  if (w.closed) return const <WindowAction>[];
  return <WindowAction>[
    if (!w.overdueRaised &&
        trustedNowUtc != null &&
        trustedNowUtc.difference(w.openedAtUtc) >= overdueAfter)
      WindowRaiseOverdue(w.windowId),
    if (booting) WindowTryResume(w.windowId),
  ];
}

/// 재개 시도 결과 → 재개 실패 사건 id(실패 = P0 `MAINTENANCE_RESUME_FAILED` 1건 · 성공 = null).
///
/// [notResumed] = 다시 켜지 못한 체크 이름(비면 성공).
String? resumeFailedEventIdOf(
  String windowId, {
  required String bootId,
  required Iterable<String> notResumed,
}) => notResumed.isEmpty
    ? null
    : windowEventIdOf(windowId, WindowEvent.resumeFailed, bootId: bootId);

/// 재개 실패 알림 코드(P0).
const String kWindowResumeFailedAlertCode = AlertCodes.maintenanceResumeFailed;
