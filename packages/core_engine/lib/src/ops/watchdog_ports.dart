// 워치독 포트 · 값 꼴(설계 13 §8 R45 C1 · C5 · C6 · 06 M1-12 · X1-6 · 앱 04 §7 `W-01`).
//
// 🔴 여기에 두는 까닭 — 구현(healthchecks 어댑터)은 data_sync 에 있고(D1 · `http` 허용) 잡 규약 · 보드는
//    trading_runtime 에 있다. data_sync → trading_runtime 은 broker_gateway 를 끌어와 01 §1-1 을 어기므로,
//    둘 다 이미 의존하는 core_engine 에 포트를 둔다(E11d `SecretVault` · E10 `OrderPathLedger` 와 같은 수).
//    trading_runtime 은 [PingStatus] · [JobHeartbeat] 를 같은 이름으로 다시 내보낸다(E11a · E11b 그대로).
// 🔴 체크 uuid 는 담지 않는다 — `hc-ping.com/<uuid>` 가 곧 핑 URL 이라 알면 «살아있음»을 위조할 수 있다(R45 C5).
// 🆕 E15f4b1(R105) — 체크 이름 · 접두(trading_runtime 에서 옮김 · 같은 이름으로 다시 내보낸다) · 생성(`ensure`) ·
//    멈춤 규칙(`pausePermitted` — SPEC 04 :925 `engine_alive` 예외).

import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode, RunModeIsSim;

/// 2축 접두 넷(04 §5-2).
const Set<String> kWatchdogPrefixes = <String>{
  'sim-auto',
  'sim-advisory',
  'live-auto',
  'live-advisory',
};

/// 체크 접두(04 §5-2 2축) — `{sim|live}-{auto|advisory}`.
String watchdogCheckPrefix(RunMode run, OperatingMode op) {
  final String r = run.isSim ? 'sim' : 'live';
  final String o = switch (op) {
    OperatingMode.autoTrade => 'auto',
    OperatingMode.advisory => 'advisory',
  };
  return '$r-$o';
}

/// 체크 이름(04 §5-2 2축 접두) — `{sim|live}-{auto|advisory}-{잡}`.
String watchdogCheckName(RunMode run, OperatingMode op, String job) =>
    '${watchdogCheckPrefix(run, op)}-$job';

/// [slug] 의 2축 접두(알려진 넷 가운데 하나 · 아니면 null).
String? watchdogPrefixOf(String slug) {
  final List<String> parts = slug.split('-');
  if (parts.length < 3) return null;
  final String p = '${parts[0]}-${parts[1]}';
  return kWatchdogPrefixes.contains(p) ? p : null;
}

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

/// 🆕 E15f4b1(R105 AJ2 · SPEC 04 :925) — [slug] 를 [reason] 으로 멈춰도 되나.
///
/// 유지보수 창 = 엔진 생존 체크만 거절(그 밖은 그대로).
/// 모드 전환 커밋 = 새 접두 [toPrefix] 가 알려진 넷 가운데 하나 ∧ 체크에 접두가 있고 ∧ 그 접두 ≠ 새 접두일 때만
/// (옛 모드의 엔진 생존 체크도 이때는 멈춘다 — 옛 엔진은 실제로 멈췄으므로 남기면 영구 경보) ·
/// 새 접두와 같은 체크 · 접두 없는 체크 · 새 접두 없음 = 거절(새 모드를 멈추는 사고 방지).
bool pausePermitted(String slug, PauseReason reason, {String? toPrefix}) {
  switch (reason) {
    case PauseReason.maintenanceWindow:
      return !isNeverPauseSlug(slug);
    case PauseReason.modeSwitchCommit:
      if (toPrefix == null || !kWatchdogPrefixes.contains(toPrefix)) {
        return false;
      }
      final String? prefix = watchdogPrefixOf(slug);
      return prefix != null && prefix != toPrefix;
  }
}

/// 🆕 E15f4b1(R105 AJ1) — 만들 체크의 꼴(healthchecks `POST /api/v3/checks/` 필드 · uuid 없음).
class WatchdogCheckSpec {
  /// 꼴을 만든다 — 🔴 [cron] · [timeout] 은 정확히 하나 · 유예 · 주기는 60초 이상.
  WatchdogCheckSpec({
    required this.slug,
    required this.grace,
    this.cron,
    this.timeout,
    this.tz = 'Asia/Seoul',
    this.tags = const <String>[],
  }) {
    if ((cron == null) == (timeout == null)) {
      throw ArgumentError('cron · timeout 가운데 정확히 하나: $slug');
    }
    if (grace < const Duration(seconds: 60)) {
      throw ArgumentError.value(grace, 'grace', '60초 이상');
    }
    final Duration? t = timeout;
    if (t != null && t < const Duration(seconds: 60)) {
      throw ArgumentError.value(t, 'timeout', '60초 이상');
    }
  }

  /// 슬러그(= 이름).
  final String slug;

  /// 이름(healthchecks 표시용 · 슬러그와 같다).
  String get name => slug;

  /// 유예.
  final Duration grace;

  /// cron 식(있으면 [tz] 기준).
  final String? cron;

  /// 주기(cron 이 없을 때).
  final Duration? timeout;

  /// cron 시간대.
  final String tz;

  /// 태그.
  final List<String> tags;
}

/// 🆕 E15f4b1 — 생성 결과.
enum EnsureOutcome {
  /// 새로 만들었다(201).
  created,

  /// 같은 슬러그가 있어 고쳤다(200).
  updated,
}

/// 🆕 E15f4b1 — 생성 결과 한 벌(🔴 uuid 없음).
class EnsuredCheck {
  /// 결과를 만든다.
  const EnsuredCheck(this.check, this.outcome);

  /// 만든 뒤 체크(상태가 paused 면 재개는 부르는 쪽).
  final RemoteCheck check;

  /// 새로 · 고침.
  final EnsureOutcome outcome;
}

/// 바깥 감시 포트(R45 C5 · C6) — 구현 = data_sync `HealthchecksClient` · 시험 = core testing `FakeWatchdogRemote`.
abstract interface class WatchdogRemote {
  /// 프로젝트의 체크 전부.
  Future<List<RemoteCheck>> checks();

  /// 🆕 E15f4b1 — [spec] 체크를 만든다(같은 슬러그가 있으면 고친다 · 멱등).
  Future<EnsuredCheck> ensure(WatchdogCheckSpec spec);

  /// [slug] 를 멈춘다 — 🔴 [reason] 필수 · [pausePermitted] 거절이면 망에 가기 전에 거절 ·
  /// 모드 전환 커밋은 새 접두 [toPrefix] 가 있어야 한다(🆕 E15f4b1).
  Future<void> pause(
    String slug, {
    required PauseReason reason,
    String? toPrefix,
  });

  /// [slug] 를 다시 켠다(상태 = new) — 이미 켜져 있었으면 false.
  Future<bool> resume(String slug, {required PauseReason reason});
}
