// 워치독 포트 · 값 꼴(설계 13 §8 R45 C1 · C5 · C6 · 06 M1-12 · X1-6 · 앱 04 §7 `W-01`).
//
// 🔴 여기에 두는 까닭 — 구현(healthchecks 어댑터)은 data_sync 에 있고(D1 · `http` 허용) 잡 규약 · 보드는
//    trading_runtime 에 있다. data_sync → trading_runtime 은 broker_gateway 를 끌어와 01 §1-1 을 어기므로,
//    둘 다 이미 의존하는 core_engine 에 포트를 둔다(E11d `SecretVault` · E10 `OrderPathLedger` 와 같은 수).
//    trading_runtime 은 [PingStatus] · [JobHeartbeat] 를 같은 이름으로 다시 내보낸다(E11a · E11b 그대로).
// 🔴 체크 uuid 는 담지 않는다 — `hc-ping.com/<uuid>` 가 곧 핑 URL 이라 알면 «살아있음»을 위조할 수 있다(R45 C5).

/// 핑 상태(01 §10 · 04 §5-2).
enum PingStatus {
  /// 시작.
  start('start'),

  /// 성공(휴장 포함).
  success('success'),

  /// 실패.
  fail('fail');

  const PingStatus(this.wire);

  /// 전송 표기.
  final String wire;
}

/// 하트비트 포트 — 구현 = data_sync `HealthchecksClient`(R45) · 시험 기록기.
abstract interface class JobHeartbeat {
  /// [check] 에 [status] 를 보낸다(실패하면 예외 — 잡은 세기만 한다). [rid] = 회차 id(start · 끝이 같다).
  Future<void> ping(
    String check,
    PingStatus status, {
    String? note,
    String? rid,
  });
}

/// 바깥 감시(healthchecks)가 보는 체크 상태.
enum RemoteCheckStatus {
  /// 만들고 한 번도 못 받음.
  fresh('new'),

  /// 제때 받고 있음.
  up('up'),

  /// 예정을 넘겨 유예 안.
  grace('grace'),

  /// 유예도 넘김(경보 발송).
  down('down'),

  /// 일시정지.
  paused('paused'),

  /// 모르는 값(던지지 않는다).
  unknown('?');

  const RemoteCheckStatus(this.wire);

  /// 응답 표기.
  final String wire;

  /// 응답 표기 → 상태(모르면 [unknown]).
  static RemoteCheckStatus parse(Object? wire) {
    for (final RemoteCheckStatus s in values) {
      if (s != unknown && s.wire == wire) return s;
    }
    return unknown;
  }
}

/// 바깥 감시의 체크 한 개(R45 C5) — 🔴 uuid · 핑 URL · 키 없음.
class RemoteCheck {
  /// 체크를 만든다.
  const RemoteCheck({
    required this.slug,
    required this.status,
    this.name = '',
    this.started = false,
    this.lastPingUtc,
    this.nextPingUtc,
    this.grace,
  });

  /// 슬러그.
  final String slug;

  /// 이름(healthchecks 표시용).
  final String name;

  /// 상태.
  final RemoteCheckStatus status;

  /// start 를 받고 끝을 아직 못 받았나.
  final bool started;

  /// 마지막으로 받은 핑(종류 무관 · UTC).
  final DateTime? lastPingUtc;

  /// 다음 예정(UTC).
  final DateTime? nextPingUtc;

  /// 바깥 쪽 유예.
  final Duration? grace;

  @override
  String toString() =>
      'RemoteCheck($slug · ${status.wire}${started ? ' · started' : ''})';
}

/// 일시정지 · 재개 이유 — 🔴 부르는 자리는 이 둘뿐이다(06 M1-12 · G-71 · X1-6). 그 밖의 호출은 «무경보 구간»을 만든다.
enum PauseReason {
  /// 모드 전환 커밋(M5-11) — 옛 모드 슬러그를 멈추고 새 모드 슬러그를 켠다.
  modeSwitchCommit,

  /// X1 유지보수 창(X1-6).
  maintenanceWindow,
}

/// 엔진 생존 체크 이름(슬러그 끝) — 🔴 유지보수 창에도 멈추지 않는다(X1-6 ⓑ) · 🟡 이름 잠정(R45 C6).
const Set<String> kNeverPauseChecks = <String>{'engine_alive'};

/// [slug] 가 멈추면 안 되는 체크인가 — 2축 합성(`{sim|live}-{auto|advisory}-{체크}`)이면 끝 이름으로 본다.
bool isNeverPauseSlug(String slug) {
  final List<String> parts = slug.split('-');
  final String check = parts.length >= 3 ? parts.sublist(2).join('-') : slug;
  return kNeverPauseChecks.contains(check);
}

/// 바깥 감시 포트(R45 C5 · C6) — 구현 = data_sync `HealthchecksClient`.
abstract interface class WatchdogRemote {
  /// 프로젝트의 체크 전부.
  Future<List<RemoteCheck>> checks();

  /// [slug] 를 멈춘다 — 🔴 [reason] 필수 · 엔진 생존 체크는 거절.
  Future<void> pause(String slug, {required PauseReason reason});

  /// [slug] 를 다시 켠다 — 이미 켜져 있었으면 false.
  Future<bool> resume(String slug, {required PauseReason reason});
}
