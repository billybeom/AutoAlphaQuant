// E11k-a — 서버 시각 기준점 신뢰 시각(설계 13 §8 R197 T1~T6 · 06 M1-13 · R43 D13).
//
// 🔵 잡는 것: ① 기준점 = 서버 하한 + 단조 시계 경과(벽시계 아님) ② 왕복 상한 경계(5초 = 받음 · 넘음 = 버림 · 거꾸로 = 버림)
//    ③ 기한 경계(10분 = 믿음 · 넘음 = 모름) ④ 🔴 두 시계 어긋남(잠듦 = 벽시계만 감 · 시계 앞당김 · 되감음) = 모름
//    ⑤ 갱신 실패(원천 null · 던짐 · 늦음 · 끝없음) = false · 옛 기준점 그대로 ⑥ 겹친 갱신 = 한 번만 잰다.
import 'dart:async';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:test/test.dart';

class _Wall implements Clock {
  _Wall(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

class _Source implements ServerTimeSource {
  _Source(this.answer);
  Future<DateTime?> Function() answer;
  int calls = 0;
  @override
  Future<DateTime?> serverTimeUtc() {
    calls++;
    return answer();
  }
}

final DateTime _server = DateTime.utc(2026, 12, 8, 0, 0, 0);
final DateTime _wall0 = DateTime.utc(2026, 12, 8, 0, 3, 0); // 기기 시계 3분 빠름

class _Rig {
  _Rig({Duration roundTrip = const Duration(milliseconds: 300)}) {
    source = _Source(() async {
      mono += roundTrip;
      wall.now = wall.now.add(roundTrip);
      return _server;
    });
    clock = AnchoredTrustedClock(
      source: source,
      wall: wall,
      monotonic: () => mono,
    );
  }

  Duration mono = const Duration(hours: 1);
  final _Wall wall = _Wall(_wall0);
  late final _Source source;
  late final AnchoredTrustedClock clock;

  void pass(Duration d, {Duration? wallDelta}) {
    mono += d;
    wall.now = wall.now.add(wallDelta ?? d);
  }
}

void main() {
  group('표본 → 기준점', () {
    TrustedTimeAnchor? of(Duration rt, {DateTime? server}) =>
        trustedTimeAnchorOf(
          serverUtc: server,
          sentAt: const Duration(seconds: 10),
          receivedAt: const Duration(seconds: 10) + rt,
          wallAtUtc: _wall0,
        );

    test('서버 시각 없음 = null', () {
      expect(of(Duration.zero), isNull);
    });

    test('🔴 왕복 경계 — 5초 = 받음 · 5초 + 1µs = 버림 · 거꾸로 = 버림', () {
      final TrustedTimeAnchor? a = of(
        kTrustedTimeMaxRoundTrip,
        server: _server,
      );
      expect(a, isNotNull);
      expect(a!.serverUtc, _server);
      expect(a.monotonicAt, const Duration(seconds: 15));
      expect(a.wallAtUtc, _wall0);
      expect(
        of(
          kTrustedTimeMaxRoundTrip + const Duration(microseconds: 1),
          server: _server,
        ),
        isNull,
      );
      expect(of(const Duration(microseconds: -1), server: _server), isNull);
    });

    test('UTC 로 맞춘다', () {
      final TrustedTimeAnchor a = TrustedTimeAnchor(
        serverUtc: _server.toLocal(),
        monotonicAt: Duration.zero,
        wallAtUtc: _wall0.toLocal(),
      );
      expect(a.serverUtc.isUtc, isTrue);
      expect(a.wallAtUtc.isUtc, isTrue);
      expect(a.serverUtc, _server);
    });
  });

  group('기준점 → 지금', () {
    final TrustedTimeAnchor a = TrustedTimeAnchor(
      serverUtc: _server,
      monotonicAt: const Duration(minutes: 5),
      wallAtUtc: _wall0,
    );
    DateTime? now(Duration age, {Duration? wallAge}) => anchoredTrustedNow(
      a,
      monotonicNow: const Duration(minutes: 5) + age,
      wallNowUtc: _wall0.add(wallAge ?? age),
    );

    test('기준점 없음 = null', () {
      expect(
        anchoredTrustedNow(
          null,
          monotonicNow: Duration.zero,
          wallNowUtc: _wall0,
        ),
        isNull,
      );
    });

    test('🔴 서버 하한 + 단조 경과 — 기기 시계(3분 빠름)를 쓰지 않는다', () {
      expect(now(Duration.zero), _server);
      expect(
        now(const Duration(seconds: 90)),
        _server.add(const Duration(seconds: 90)),
      );
    });

    test('🔴 기한 경계 — 10분 = 믿음 · 10분 + 1µs = 모름 · 단조 거꾸로 = 모름', () {
      expect(now(kTrustedTimeMaxAge), _server.add(kTrustedTimeMaxAge));
      expect(now(kTrustedTimeMaxAge + const Duration(microseconds: 1)), isNull);
      expect(now(const Duration(microseconds: -1)), isNull);
    });

    test('🔴 두 시계 어긋남 경계 — 2초 = 믿음 · 넘음 = 모름(양쪽)', () {
      const Duration age = Duration(minutes: 1);
      expect(now(age, wallAge: age + kTrustedTimeClockAgreement), isNotNull);
      expect(now(age, wallAge: age - kTrustedTimeClockAgreement), isNotNull);
      expect(
        now(
          age,
          wallAge:
              age +
              kTrustedTimeClockAgreement +
              const Duration(milliseconds: 1),
        ),
        isNull,
        reason: '잠들었다(벽시계만 감) 또는 시계를 앞당겼다',
      );
      expect(
        now(
          age,
          wallAge:
              age -
              kTrustedTimeClockAgreement -
              const Duration(milliseconds: 1),
        ),
        isNull,
        reason: '시계를 되감았다',
      );
    });
  });

  group('AnchoredTrustedClock', () {
    test('잰 적 없음 = 모름', () {
      final _Rig r = _Rig();
      expect(r.clock.trustedNowUtc(), isNull);
      expect(r.clock.anchor, isNull);
      expect(r.source.calls, 0);
    });

    test('갱신 성공 = 서버 하한 + 그 뒤 단조 경과', () async {
      final _Rig r = _Rig();
      expect(await r.clock.refresh(), isTrue);
      expect(r.clock.trustedNowUtc(), _server);
      r.pass(const Duration(minutes: 3));
      expect(r.clock.trustedNowUtc(), _server.add(const Duration(minutes: 3)));
    });

    test('🔴 잠듦(단조 멈춤 · 벽시계 1시간) = 모름 → 다시 재면 믿음', () async {
      final _Rig r = _Rig();
      await r.clock.refresh();
      r.pass(Duration.zero, wallDelta: const Duration(hours: 1));
      expect(r.clock.trustedNowUtc(), isNull);
      expect(await r.clock.refresh(), isTrue);
      expect(r.clock.trustedNowUtc(), _server);
    });

    test('🔴 기기 시계 앞당김(48h) = 모름', () async {
      final _Rig r = _Rig();
      await r.clock.refresh();
      r.pass(const Duration(seconds: 1), wallDelta: const Duration(hours: 48));
      expect(r.clock.trustedNowUtc(), isNull);
    });

    test('🔴 10분 넘게 못 잼 = 모름', () async {
      final _Rig r = _Rig();
      await r.clock.refresh();
      r.pass(kTrustedTimeMaxAge + const Duration(seconds: 1));
      expect(r.clock.trustedNowUtc(), isNull);
    });

    test('🔴 왕복 6초 = 버림 · 옛 기준점 그대로', () async {
      final _Rig r = _Rig();
      await r.clock.refresh();
      final TrustedTimeAnchor? before = r.clock.anchor;
      r.source.answer = () async {
        r.pass(const Duration(seconds: 6));
        return _server.add(const Duration(hours: 1));
      };
      expect(await r.clock.refresh(), isFalse);
      expect(identical(r.clock.anchor, before), isTrue);
    });

    for (final (String name, Future<DateTime?> Function() answer)
        in <(String, Future<DateTime?> Function())>[
          ('원천 null(연결 전 · 실패)', () async => null),
          ('원천이 던짐', () async => throw StateError('망')),
        ]) {
      test('🔴 $name = false · 옛 기준점 그대로', () async {
        final _Rig r = _Rig();
        await r.clock.refresh();
        final TrustedTimeAnchor? before = r.clock.anchor;
        r.source.answer = answer;
        expect(await r.clock.refresh(), isFalse);
        expect(identical(r.clock.anchor, before), isTrue);
        expect(r.clock.trustedNowUtc(), _server);
      });
    }

    test('🔴 원천이 끝나지 않음 = 상한 두 배에서 끊음 · false', () async {
      final _Wall wall = _Wall(_wall0);
      final AnchoredTrustedClock c = AnchoredTrustedClock(
        source: _Source(() => Completer<DateTime?>().future),
        wall: wall,
        monotonic: () => Duration.zero,
        maxRoundTrip: const Duration(milliseconds: 5),
      );
      expect(await c.refresh(), isFalse);
      expect(c.trustedNowUtc(), isNull);
    });

    test('겹친 갱신 = 한 번만 잰다 · 끝나면 다시 잴 수 있다', () async {
      final _Rig r = _Rig();
      final Completer<DateTime?> gate = Completer<DateTime?>();
      r.source.answer = () => gate.future;
      final Future<bool> a = r.clock.refresh();
      final Future<bool> b = r.clock.refresh();
      expect(r.source.calls, 1);
      gate.complete(_server);
      expect(await a, isTrue);
      expect(await b, isTrue);
      r.source.answer = () async => _server;
      await r.clock.refresh();
      expect(r.source.calls, 2);
    });

    test('기본 단조 시계(Stopwatch)로도 선다', () async {
      final AnchoredTrustedClock c = AnchoredTrustedClock(
        source: _Source(() async => _server),
        wall: _Wall(_wall0),
      );
      expect(await c.refresh(), isTrue);
      final DateTime? t = c.trustedNowUtc();
      // 벽시계를 멈춰 둔 가짜라 단조 경과가 2초 안이면 믿는다.
      expect(t, isNotNull);
      expect(t!.isBefore(_server.add(kTrustedTimeClockAgreement)), isTrue);
    });
  });
}
