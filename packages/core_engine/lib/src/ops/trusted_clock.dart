// 신뢰 시각 포트(M1-13 · 설계 13 §8 R54 J1) · 🆕 E11k-a 서버 시각 기준점(설계 13 §8 R197 · R43 D13).
//
// 🔴 «모름»(null)은 «지금»이 아니다 — 신뢰 시각이 필요한 쓰기(운영 파라미터의 적용 시점 등)는 모르면 거부한다.
// 🆕 E11k-a — 실물 = 서버가 응답에 찍은 시각(초 내림)을 **기준점**으로 두고, 그 뒤 흐른 시간은 기기의 **단조 시계**로 더한다.
//    🔴 기기 벽시계는 시각의 원천이 아니다 — 단조 시계와 어긋나는지(잠듦 · 시계 바꿈)를 보는 감시값일 뿐이다.
// 🔴 판정 차례(어느 하나라도 걸리면 모름):
//    ① 기준점 없음(아직 못 잼 · 프로세스가 새로 떴다 — 기준점은 메모리에만 있다)
//    ② 기준점이 [kTrustedTimeMaxAge] 보다 낡음(단조 시계 기준)
//    ③ 그 사이 벽시계 경과 ↔ 단조 시계 경과가 [kTrustedTimeClockAgreement] 넘게 어긋남(잠들었다 · 시계를 바꿨다)
// 🔴 잴 때: 왕복이 [kTrustedTimeMaxRoundTrip] 넘으면 버린다(옛 기준점은 그대로 둔다 — 판정 ②③ 이 알아서 낡힌다).
// 🔵 받은 순간의 서버 시각은 «하한»을 쓴다(초 내림 값 그대로) — «아직 안 지났다» 쪽(48h · 냉각 30일)으로만 틀린다.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart' show Clock;

/// 신뢰 시각.
abstract interface class TrustedClock {
  /// 신뢰할 수 있는 지금(UTC) — 모르면 null.
  DateTime? trustedNowUtc();
}

/// 🆕 E11k-a — 서버 시각 원천(실물 = data_sync `SupabaseServerTime`).
abstract interface class ServerTimeSource {
  /// 서버가 응답에 찍은 시각(UTC · 초 내림) — 연결 전 · 실패 = null. 🔴 던지지 않는다(던져도 잰 것으로 치지 않는다).
  Future<DateTime?> serverTimeUtc();
}

/// 🆕 잰 표본을 받아 주는 왕복 상한 — 넘으면 그 표본을 버린다(R197 T2).
const Duration kTrustedTimeMaxRoundTrip = Duration(seconds: 5);

/// 🆕 기준점을 믿는 기한(단조 시계 기준 · R197 T3).
const Duration kTrustedTimeMaxAge = Duration(minutes: 10);

/// 🆕 벽시계 경과 ↔ 단조 시계 경과의 허용 어긋남(R197 T4).
const Duration kTrustedTimeClockAgreement = Duration(seconds: 2);

/// 🆕 서버 시각 기준점 — 서버 시각 하한 + 받은 순간의 단조 · 벽시계 읽음.
class TrustedTimeAnchor {
  /// 기준점을 만든다.
  TrustedTimeAnchor({
    required DateTime serverUtc,
    required this.monotonicAt,
    required DateTime wallAtUtc,
  }) : serverUtc = serverUtc.toUtc(),
       wallAtUtc = wallAtUtc.toUtc();

  /// 받은 순간의 서버 시각(하한).
  final DateTime serverUtc;

  /// 받은 순간의 단조 시계 읽음.
  final Duration monotonicAt;

  /// 받은 순간의 벽시계(감시값).
  final DateTime wallAtUtc;
}

/// 🆕 표본 → 기준점(순수) — 서버 시각 없음 · 왕복이 거꾸로 · [maxRoundTrip] 넘음 = null.
TrustedTimeAnchor? trustedTimeAnchorOf({
  required DateTime? serverUtc,
  required Duration sentAt,
  required Duration receivedAt,
  required DateTime wallAtUtc,
  Duration maxRoundTrip = kTrustedTimeMaxRoundTrip,
}) {
  if (serverUtc == null) return null;
  final Duration roundTrip = receivedAt - sentAt;
  if (roundTrip.isNegative || roundTrip > maxRoundTrip) return null;
  return TrustedTimeAnchor(
    serverUtc: serverUtc,
    monotonicAt: receivedAt,
    wallAtUtc: wallAtUtc,
  );
}

/// 🆕 기준점 → 지금(순수) — 판정 ①②③ 중 하나라도 걸리면 null.
DateTime? anchoredTrustedNow(
  TrustedTimeAnchor? anchor, {
  required Duration monotonicNow,
  required DateTime wallNowUtc,
  Duration maxAge = kTrustedTimeMaxAge,
  Duration agreement = kTrustedTimeClockAgreement,
}) {
  if (anchor == null) return null;
  final Duration mono = monotonicNow - anchor.monotonicAt;
  if (mono.isNegative || mono > maxAge) return null;
  final Duration wall = wallNowUtc.toUtc().difference(anchor.wallAtUtc);
  if ((wall - mono).abs() > agreement) return null;
  return anchor.serverUtc.add(mono);
}

/// 🆕 E11k-a — 서버 시각 기준점 + 단조 시계의 신뢰 시각.
///
/// [refresh] 가 서버 시각을 한 번 재 기준점을 바꾼다(겹쳐 불러도 한 번만 잰다) · [trustedNowUtc] 는 동기 판정만 한다.
class AnchoredTrustedClock implements TrustedClock {
  /// 만든다 — [source] = 서버 시각 원천 · [wall] = 기기 벽시계(감시값) · [monotonic] = 단조 시계(기본 = 이 객체가 만든 `Stopwatch`).
  AnchoredTrustedClock({
    required this._source,
    required this._wall,
    Duration Function()? monotonic,
    this.maxRoundTrip = kTrustedTimeMaxRoundTrip,
    this.maxAge = kTrustedTimeMaxAge,
    this.agreement = kTrustedTimeClockAgreement,
  }) : _monotonic = monotonic ?? _stopwatch();

  final ServerTimeSource _source;
  final Clock _wall;
  final Duration Function() _monotonic;

  /// 왕복 상한.
  final Duration maxRoundTrip;

  /// 기준점 기한.
  final Duration maxAge;

  /// 두 시계 허용 어긋남.
  final Duration agreement;

  TrustedTimeAnchor? _anchor;
  Future<bool>? _inFlight;

  static Duration Function() _stopwatch() {
    final Stopwatch s = Stopwatch()..start();
    return () => s.elapsed;
  }

  /// 지금 기준점(시험 · 진단용 · 없음 = null).
  TrustedTimeAnchor? get anchor => _anchor;

  @override
  DateTime? trustedNowUtc() => anchoredTrustedNow(
    _anchor,
    monotonicNow: _monotonic(),
    wallNowUtc: _wall.nowUtc(),
    maxAge: maxAge,
    agreement: agreement,
  );

  /// 서버 시각을 한 번 잰다 — 새 기준점을 세웠으면 true. 🔴 던지지 않는다 · 실패 = 옛 기준점 그대로.
  Future<bool> refresh() =>
      _inFlight ??= _measure().whenComplete(() => _inFlight = null);

  Future<bool> _measure() async {
    final Duration sentAt = _monotonic();
    final DateTime? server;
    try {
      // 🔵 원천이 시간 상한을 지키지 않아도 여기서 끊는다(넘었으면 어차피 버릴 표본이다).
      server = await _source.serverTimeUtc().timeout(maxRoundTrip * 2);
    } on Object {
      return false;
    }
    final TrustedTimeAnchor? next = trustedTimeAnchorOf(
      serverUtc: server,
      sentAt: sentAt,
      receivedAt: _monotonic(),
      wallAtUtc: _wall.nowUtc(),
      maxRoundTrip: maxRoundTrip,
    );
    if (next == null) return false;
    _anchor = next;
    return true;
  }
}
