// X1-6 감시 유지보수 창 기록(설계 13 §8 R132 N9 · N10 · SPEC v2.45 04 §5-2 · 앱 06 X1-6).
//
// 🔴 append-only — 열기(OPENED · 멈춘 체크 목록 · `engine_alive` 0) · 넘김(OVERDUE · 창당 1건 + P1) · 재개 실패(RESUME_FAILED ·
//    부팅당 1건 + P0) · 닫기(CLOSED). 열린 창은 한 번에 하나.
// 🔴 시각 = 신뢰 시각 · 열린 시각보다 앞이면 열린 시각(정렬이 뒤집혀 `windowStateOf` 가 던지지 않게).
// 🟡 재개 실행 · 첫 핑 닫기 · 부팅 훅 = E16t.

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        MaintenanceWindowResultCodes,
        OperatingMode,
        RunMode,
        SafetyCommonResultCodes;
import 'package:sqlite3/sqlite3.dart';

import '../local/alert_store.dart' show SqliteAlertSink;
import '../market/market_store.dart' show inLedgerTransaction;

/// 창 저장 거부 코드(글자 = 계약 `MaintenanceWindowResultCodes` ∪ 공용 `SafetyCommonResultCodes` 참조 · 미결 212).
abstract final class WindowStoreCodes {
  /// 이미 열린 창이 있다.
  static const String alreadyOpen = MaintenanceWindowResultCodes.alreadyOpen;

  /// 신뢰 시각 모름.
  static const String trustedTimeUnknown =
      SafetyCommonResultCodes.trustedTimeUnknown;
}

/// 알림을 내는 곳 이름(묶음 키).
const String kMaintenanceWindowAlertSource = 'maintenance_window';

/// [windowId] 의 사건 행(시각 차례).
List<WindowEventRow> windowEventRowsOf(Database db, String windowId) =>
    <WindowEventRow>[
      for (final Row r in db.select(
        'SELECT window_id, event, at FROM maintenance_window WHERE window_id = ? ORDER BY at, rowid',
        <Object?>[windowId],
      ))
        WindowEventRow(
          windowId: r['window_id'] as String,
          event: r['event'] as String,
          atUtc: DateTime.parse(r['at'] as String).toUtc(),
        ),
    ];

/// 🔴 [at] 을 열린 시각 아래로 내려가지 않게.
DateTime _notBefore(DateTime at, DateTime opened) =>
    at.isBefore(opened) ? opened : at;

void _insertEvent(
  Database db, {
  required String windowId,
  required WindowEvent event,
  required DateTime atUtc,
  String? runId,
  String? checksJson,
  String? bootId,
}) => db.execute(
  'INSERT OR IGNORE INTO maintenance_window (event_id, window_id, run_id, event, checks_json, at) '
  'VALUES (?, ?, ?, ?, ?, ?)',
  <Object?>[
    windowEventIdOf(windowId, event, bootId: bootId),
    windowId,
    runId,
    event.wire,
    checksJson,
    atUtc.toUtc().toIso8601String(),
  ],
);

/// 🔴 [runId] 가 연 열린 창을 닫는다(바깥 트랜잭션 안 · 이전 중단 = R132 N10) — 닫은 창 수.
int closeOpenWindowsOfRun(Database db, String runId, DateTime atUtc) {
  if (db.autocommit) throw StateError('closeOpenWindowsOfRun 은 트랜잭션 안에서만');
  int n = 0;
  for (final Row r in db.select(
    "SELECT DISTINCT window_id FROM maintenance_window WHERE run_id = ? AND event = 'OPENED'",
    <Object?>[runId],
  )) {
    final String id = r['window_id'] as String;
    final WindowState s = windowStateOf(id, windowEventRowsOf(db, id));
    if (s.closed) continue;
    _insertEvent(
      db,
      windowId: id,
      event: WindowEvent.closed,
      atUtc: _notBefore(atUtc, s.openedAtUtc),
    );
    n++;
  }
  return n;
}

/// 유지보수 창 저장소(live 원장).
class SqliteMaintenanceWindowStore {
  /// 만든다 — [alerts] 는 같은 원장의 알림 저장소.
  SqliteMaintenanceWindowStore(
    this._db, {
    required this._trusted,
    required this._alerts,
  });

  final Database _db;
  final TrustedClock _trusted;
  final SqliteAlertSink _alerts;

  /// 지금 열린 창(없으면 null) — 둘 이상이면 [StateError].
  String? openWindowId() {
    final List<String> open = <String>[
      for (final Row r in _db.select(
        "SELECT DISTINCT window_id FROM maintenance_window WHERE event = 'OPENED' "
        "AND window_id NOT IN (SELECT window_id FROM maintenance_window WHERE event = 'CLOSED')",
      ))
        r['window_id'] as String,
    ];
    if (open.length > 1) throw StateError('열린 창이 둘 이상: $open');
    return open.isEmpty ? null : open.single;
  }

  /// 창 상태.
  WindowState stateOf(String windowId) =>
      windowStateOf(windowId, windowEventRowsOf(_db, windowId));

  /// 🆕 E16t1(R139 U6) — [windowId] 가 멈춘 체크(OPENED `checks_json` · 창 없음 = 빈 목록).
  List<String> pausedChecksOf(String windowId) {
    final ResultSet r = _db.select(
      "SELECT checks_json FROM maintenance_window WHERE window_id = ? AND event = 'OPENED'",
      <Object?>[windowId],
    );
    final Object? json = r.isEmpty ? null : r.single['checks_json'];
    if (json == null) return const <String>[];
    return <String>[
      for (final Object? x in jsonDecode(json as String) as List<Object?>)
        x! as String,
    ];
  }

  /// 🔴 창을 연다 — 멈춘 체크 = core `pausableChecksOf`(`engine_alive` 0) · 열린 창이 있으면 거부.
  ({String? windowId, String? rejectCode}) open({
    required Iterable<String> checkSlugs,
    required RunMode runMode,
    required OperatingMode operatingMode,
    String? runId,
  }) {
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) {
      return (windowId: null, rejectCode: WindowStoreCodes.trustedTimeUnknown);
    }
    return inLedgerTransaction(_db, () {
      if (openWindowId() != null) {
        return (windowId: null, rejectCode: WindowStoreCodes.alreadyOpen);
      }
      final int seq =
          (_db.select(
                'SELECT COUNT(DISTINCT window_id) AS n FROM maintenance_window WHERE window_id LIKE ?',
                <Object?>['mw-${kstDateText(now)}-%'],
              ).single['n']
              as int) +
          1;
      final String id = maintenanceWindowIdOf(now, seq);
      _insertEvent(
        _db,
        windowId: id,
        event: WindowEvent.opened,
        atUtc: now,
        runId: runId,
        checksJson: jsonEncode(
          pausableChecksOf(
            checkSlugs,
            runMode: runMode,
            operatingMode: operatingMode,
          ),
        ),
      );
      return (windowId: id, rejectCode: null);
    });
  }

  /// 🔴 열린 창 판정 — 넘김 = OVERDUE 행 + P1 한 트랜잭션(창당 1건) · 재개 시도는 돌려준다(실행 = E16t).
  ///
  /// [overdueAfter] = `operations.migration.maintenance_overdue_hours`(잠정 72 · 인자) · 열린 창 없음 = 빈 목록.
  List<WindowAction> tick({
    required Duration overdueAfter,
    required bool booting,
  }) {
    final DateTime? now = _trusted.trustedNowUtc();
    return inLedgerTransaction(_db, () {
      final String? id = openWindowId();
      if (id == null) return const <WindowAction>[];
      final List<WindowAction> actions = windowActionsOf(
        stateOf(id),
        trustedNowUtc: now,
        overdueAfter: overdueAfter,
        booting: booting,
      );
      for (final WindowAction a in actions) {
        if (a is WindowRaiseOverdue) {
          _insertEvent(
            _db,
            windowId: id,
            event: WindowEvent.overdue,
            atUtc: now!,
          );
          if (_db.updatedRows == 1) {
            _alerts.emitInTransaction(kMaintenanceWindowAlertSource, <String>{
              a.alertCode,
            });
          }
        }
      }
      return actions;
    });
  }

  /// 🔴 재개 실패 — RESUME_FAILED 행 + P0 한 트랜잭션(부팅당 1건) · 못 켠 체크 0 = 쓰기 0 · 적었으면 true.
  ///
  /// 신뢰 시각 모름 = 열린 시각으로 적는다(P0 를 잃지 않는다 · 사건 차례만 지킨다).
  bool recordResumeFailed({
    required String windowId,
    required String bootId,
    required Iterable<String> notResumed,
  }) {
    final String? eventId = resumeFailedEventIdOf(
      windowId,
      bootId: bootId,
      notResumed: notResumed,
    );
    if (eventId == null) return false;
    return inLedgerTransaction(_db, () {
      final WindowState s = stateOf(windowId);
      if (s.closed) throw StateError('닫힌 창 $windowId 에 재개 실패');
      _insertEvent(
        _db,
        windowId: windowId,
        event: WindowEvent.resumeFailed,
        atUtc: _notBefore(
          _trusted.trustedNowUtc() ?? s.openedAtUtc,
          s.openedAtUtc,
        ),
        bootId: bootId,
      );
      if (_db.updatedRows != 1) return false;
      _alerts.emitInTransaction(kMaintenanceWindowAlertSource, <String>{
        kWindowResumeFailedAlertCode,
      });
      return true;
    });
  }

  /// 창을 닫는다 — 닫았으면 null · 이미 닫힘 = null(쓰기 0) · 신뢰 시각 모름 = 거부 코드.
  String? close(String windowId) {
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) return WindowStoreCodes.trustedTimeUnknown;
    inLedgerTransaction(_db, () {
      final WindowState s = stateOf(windowId);
      if (s.closed) return;
      _insertEvent(
        _db,
        windowId: windowId,
        event: WindowEvent.closed,
        atUtc: _notBefore(now, s.openedAtUtc),
      );
    });
    return null;
  }
}
