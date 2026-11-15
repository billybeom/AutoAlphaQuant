// E16b — X1-6 감시 유지보수 창 판정(설계 13 §8 R117 B8 · SPEC v2.45 04 §5-2 · 02 §2-6).
//
// 🔵 잡는 것: ① 창 id · 사건 id(재개 실패만 부팅 id) ② 멈출 체크 = 그 모드 접두 ∧ 엔진 생존 0
//    ③ 사건 행 → 상태(OPENED 하나 먼저 · CLOSED 뒤 0 · OVERDUE 하나 · 같은 시각 차례) ④ 넘김 경계 · 1회 · 시각 모름
//    ⑤ 부팅 = 재개 시도 · 실패 = 부팅마다 1건.
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _w = 'mw-2026-12-01-1';
final DateTime _open = DateTime.utc(2026, 12, 1, 1);
const Duration _t72 = Duration(hours: 72);

WindowEventRow _e(WindowEvent e, DateTime at, {String w = _w}) =>
    WindowEventRow(windowId: w, event: e.wire, atUtc: at);

WindowState _state(List<WindowEventRow> rows) => windowStateOf(_w, rows);

void main() {
  test('창 id = 한국 날 · 순번 · 사건 id — 재개 실패만 부팅 id', () {
    expect(maintenanceWindowIdOf(DateTime.utc(2026, 11, 30, 15), 1), _w);
    expect(() => maintenanceWindowIdOf(_open, 0), throwsArgumentError);
    expect(windowEventIdOf(_w, WindowEvent.opened), '$_w:OPENED');
    expect(windowEventIdOf(_w, WindowEvent.overdue), '$_w:OVERDUE');
    expect(
      windowEventIdOf(_w, WindowEvent.resumeFailed, bootId: 'b7'),
      '$_w:RESUME_FAILED:b7',
    );
    expect(
      () => windowEventIdOf(_w, WindowEvent.resumeFailed),
      throwsArgumentError,
    );
    expect(
      () => windowEventIdOf(_w, WindowEvent.closed, bootId: 'b7'),
      throwsArgumentError,
    );
  });

  test('🔴 멈출 체크 = 그 모드 접두 ∧ 엔진 생존 0 · 중복 0 · 이름 차례', () {
    final List<String> got = pausableChecksOf(
      <String>[
        'live-auto-kr_order_open',
        'live-auto-engine_alive',
        'live-auto-daily_reconcile',
        'sim-auto-kr_order_open',
        'live-advisory-kr_order_open',
        'kr_order_open',
        'live-auto-kr_order_open',
      ],
      runMode: RunMode.live,
      operatingMode: OperatingMode.autoTrade,
    );
    expect(got, <String>[
      'live-auto-daily_reconcile',
      'live-auto-kr_order_open',
    ]);
  });

  group('사건 행 → 상태', () {
    test('열림만 = 열린 창 · 넘김 안 냄', () {
      final WindowState s = _state(<WindowEventRow>[
        _e(WindowEvent.opened, _open),
      ]);
      expect((s.closed, s.overdueRaised, s.openedAtUtc), (false, false, _open));
    });

    test('열림 → 넘김 → 재개 실패 둘 → 닫힘', () {
      final WindowState s = _state(<WindowEventRow>[
        _e(WindowEvent.closed, _open.add(const Duration(hours: 80))),
        _e(WindowEvent.opened, _open),
        _e(WindowEvent.overdue, _open.add(_t72)),
        _e(WindowEvent.resumeFailed, _open.add(const Duration(hours: 73))),
        _e(WindowEvent.resumeFailed, _open.add(const Duration(hours: 74))),
      ]);
      expect((s.closed, s.overdueRaised), (true, true));
    });

    test('같은 시각 — 열림이 먼저 · 닫힘이 나중(주어진 차례와 무관)', () {
      final WindowState s = _state(<WindowEventRow>[
        _e(WindowEvent.closed, _open),
        _e(WindowEvent.overdue, _open),
        _e(WindowEvent.opened, _open),
      ]);
      expect((s.closed, s.overdueRaised), (true, true));
    });

    test('🔴 깨진 사건 = StateError', () {
      void broken(List<WindowEventRow> rows) =>
          expect(() => _state(rows), throwsStateError);
      broken(const <WindowEventRow>[]);
      broken(<WindowEventRow>[_e(WindowEvent.overdue, _open)]);
      broken(<WindowEventRow>[
        _e(WindowEvent.opened, _open),
        _e(WindowEvent.opened, _open.add(const Duration(hours: 1))),
      ]);
      broken(<WindowEventRow>[
        _e(WindowEvent.opened, _open),
        _e(WindowEvent.overdue, _open.add(_t72)),
        _e(WindowEvent.overdue, _open.add(const Duration(hours: 73))),
      ]);
      broken(<WindowEventRow>[
        _e(WindowEvent.opened, _open),
        _e(WindowEvent.closed, _open.add(const Duration(hours: 1))),
        _e(WindowEvent.resumeFailed, _open.add(const Duration(hours: 2))),
      ]);
      broken(<WindowEventRow>[_e(WindowEvent.opened, _open, w: 'mw-x')]);
    });

    test('모르는 사건 글자 = FormatException', () {
      expect(
        () => _state(<WindowEventRow>[
          WindowEventRow(windowId: _w, event: 'PAUSED', atUtc: _open),
        ]),
        throwsFormatException,
      );
    });
  });

  group('열린 창 판정', () {
    final WindowState open = _state(<WindowEventRow>[
      _e(WindowEvent.opened, _open),
    ]);

    List<WindowAction> act(
      WindowState w, {
      DateTime? now,
      bool unknown = false,
      bool booting = false,
    }) => windowActionsOf(
      w,
      trustedNowUtc: unknown ? null : now,
      overdueAfter: _t72,
      booting: booting,
    );

    test('🔴 넘김 경계 — T 1초 전 = 없음 · T = P1 1건', () {
      expect(
        act(open, now: _open.add(_t72 - const Duration(seconds: 1))),
        isEmpty,
      );
      final List<WindowAction> a = act(open, now: _open.add(_t72));
      expect(a, hasLength(1));
      expect((a.single as WindowRaiseOverdue).windowId, _w);
      expect(
        (a.single as WindowRaiseOverdue).alertCode,
        AlertCodes.maintenanceWindowOverdue,
      );
    });

    test('🔴 넘김은 창당 1건 — 이미 냈으면 다시 없음', () {
      final WindowState raised = _state(<WindowEventRow>[
        _e(WindowEvent.opened, _open),
        _e(WindowEvent.overdue, _open.add(_t72)),
      ]);
      expect(act(raised, now: _open.add(const Duration(days: 9))), isEmpty);
    });

    test('신뢰 시각 모름 = 넘김 판정 안 함 · 부팅이면 재개 시도는 한다', () {
      expect(act(open, unknown: true), isEmpty);
      final List<WindowAction> a = act(open, unknown: true, booting: true);
      expect(a.single, isA<WindowTryResume>());
      expect((a.single as WindowTryResume).windowId, _w);
    });

    test('부팅 + 넘김 = 둘 다 · 닫힌 창 = 할 일 0', () {
      final List<WindowAction> a = act(
        open,
        now: _open.add(const Duration(hours: 100)),
        booting: true,
      );
      expect(a.map((WindowAction x) => x.runtimeType), <Type>[
        WindowRaiseOverdue,
        WindowTryResume,
      ]);
      final WindowState closed = _state(<WindowEventRow>[
        _e(WindowEvent.opened, _open),
        _e(WindowEvent.closed, _open.add(const Duration(hours: 1))),
      ]);
      expect(
        act(closed, now: _open.add(const Duration(days: 9)), booting: true),
        isEmpty,
      );
    });

    test('넘김 기준 0 이하 = ArgumentError', () {
      expect(
        () => windowActionsOf(
          open,
          trustedNowUtc: _open,
          overdueAfter: Duration.zero,
          booting: false,
        ),
        throwsArgumentError,
      );
    });
  });

  test('🔴 재개 실패 = 부팅마다 1건(P0) · 다 켜면 없음', () {
    expect(
      resumeFailedEventIdOf(_w, bootId: 'b1', notResumed: const <String>[]),
      isNull,
    );
    expect(
      resumeFailedEventIdOf(
        _w,
        bootId: 'b1',
        notResumed: const <String>['live-auto-kr_order_open'],
      ),
      '$_w:RESUME_FAILED:b1',
    );
    expect(kWindowResumeFailedAlertCode, AlertCodes.maintenanceResumeFailed);
    expect(WindowEvent.values.map((WindowEvent e) => e.wire), <String>[
      'OPENED',
      'OVERDUE',
      'CLOSED',
      'RESUME_FAILED',
    ]);
  });
}
