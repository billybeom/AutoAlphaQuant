// 바깥 감시 포트 가짜(🆕 E15f4b1 · 설계 13 §8 R105 AJ7) — 메모리 체크 · 호출 기록 · 실패 주입 · 상한 ·
// 실물과 같은 멈춤 규칙(`pausePermitted`) · 재개 = new.
//
// 🔴 테스트 전용 — 앱 코드(lib/)는 import 하지 않는다(배럴 `core_engine/testing.dart`).

import '../ops/watchdog_ports.dart';

/// 바깥 감시 가짜.
class FakeWatchdogRemote implements WatchdogRemote {
  /// 가짜를 만든다 — [limit] = 체크 상한(넘으면 생성 실패 · 기본 20 = 무료 요금제).
  FakeWatchdogRemote({
    this.limit = 20,
    Iterable<RemoteCheck> initial = const <RemoteCheck>[],
  }) {
    for (final RemoteCheck c in initial) {
      store[c.slug] = c;
    }
  }

  /// 체크 상한.
  final int limit;

  /// 슬러그 → 체크.
  final Map<String, RemoteCheck> store = <String, RemoteCheck>{};

  /// 호출 기록 — `checks` · `ensure:{slug}` · `pause:{slug}:{reason}` · `resume:{slug}`.
  final List<String> calls = <String>[];

  /// (동작, 슬러그) → 던질 것 — 동작 = `checks` · `ensure` · `pause` · `resume`(슬러그 `*` = 모두).
  final Map<(String, String), Exception> failOn =
      <(String, String), Exception>{};

  void _maybeFail(String op, String slug) {
    final Exception? e = failOn[(op, slug)] ?? failOn[(op, '*')];
    if (e != null) throw e;
  }

  @override
  Future<List<RemoteCheck>> checks() async {
    calls.add('checks');
    _maybeFail('checks', '*');
    return store.values.toList();
  }

  @override
  Future<EnsuredCheck> ensure(WatchdogCheckSpec spec) async {
    calls.add('ensure:${spec.slug}');
    _maybeFail('ensure', spec.slug);
    final RemoteCheck? old = store[spec.slug];
    if (old == null && store.length >= limit) {
      throw StateError('체크 상한 $limit');
    }
    final RemoteCheck now = RemoteCheck(
      slug: spec.slug,
      name: spec.name,
      status: old?.status ?? RemoteCheckStatus.fresh,
      started: old?.started ?? false,
      lastPingUtc: old?.lastPingUtc,
      nextPingUtc: old?.nextPingUtc,
      grace: spec.grace,
    );
    store[spec.slug] = now;
    return EnsuredCheck(
      now,
      old == null ? EnsureOutcome.created : EnsureOutcome.updated,
    );
  }

  @override
  Future<void> pause(
    String slug, {
    required PauseReason reason,
    String? toPrefix,
  }) async {
    calls.add('pause:$slug:${reason.name}');
    if (!pausePermitted(slug, reason, toPrefix: toPrefix)) {
      throw StateError('멈춤 거절: $slug');
    }
    _maybeFail('pause', slug);
    final RemoteCheck? c = store[slug];
    if (c == null) throw StateError('없는 체크: $slug');
    store[slug] = _with(c, RemoteCheckStatus.paused);
  }

  @override
  Future<bool> resume(String slug, {required PauseReason reason}) async {
    calls.add('resume:$slug');
    _maybeFail('resume', slug);
    final RemoteCheck? c = store[slug];
    if (c == null) throw StateError('없는 체크: $slug');
    if (c.status != RemoteCheckStatus.paused) return false;
    store[slug] = _with(c, RemoteCheckStatus.fresh);
    return true;
  }

  RemoteCheck _with(RemoteCheck c, RemoteCheckStatus s) => RemoteCheck(
    slug: c.slug,
    name: c.name,
    status: s,
    started: c.started,
    lastPingUtc: c.lastPingUtc,
    nextPingUtc: c.nextPingUtc,
    grace: c.grace,
  );
}
