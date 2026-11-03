// 잡 규약 — 01 §10 의 Dart 이식(설계 13 §8 R42 S3 · 06 M1-16 의 잡 규약 몫 · 04 §5-2).
//
// 🔴 잡 하나 = start 핑 → 본체 → success | fail. 휴장(KR 비세션)은 성공 핑 + 메모 «휴장»(M1-12 — 비거래일에 핑이
//    끊기면 바깥 워치독이 «안 왔다»로 운다).
// 🔴 본체 예외는 fail 핑으로 남기고 결과에 담는다 — 다시 던지지 않는다(잡을 부르는 쪽 = 알람 · FGS 가 죽지 않게).
// 🔴 핑 실패는 잡 결과를 바꾸지 않는다 — 감시는 바깥(healthchecks · M1-12) 몫이고, 핑이 안 가면 그쪽이 지연을 본다.
// 🔴 알림 발송이 실패하면 fail 핑 — P0 가 안 갔을 수 있다(바깥이 알린다 · 결과는 남긴다).
// 🔵 잡 실패 알림 코드는 두지 않는다 — fail 핑을 바깥 워치독이 알린다(경보 피로 규칙 · 같은 사고에 알림 둘을 내지 않는다).
// 🆕 E11b(R43 B7) — 달력은 시장별(`calendar`) · 세션일 함수(`us_data` = KST 날 − 1) · 회차 `rid`(start · 끝 핑이 같은 값 —
//    바깥이 한 회차의 시작과 끝을 짝짓는다 · 결정적 UUID 꼴).

import 'package:core_engine/core_engine.dart' show ExchangeCalendar;
import 'package:domain_contracts/domain_contracts.dart';

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

/// 하트비트 포트 — 구현 = healthchecks.io 어댑터(M1-12 · E11 다음 조각) · 시험 기록기.
abstract interface class JobHeartbeat {
  /// [check] 에 [status] 를 보낸다(실패하면 예외 — 잡은 세기만 한다). [rid] = 회차 id(start · 끝이 같다).
  Future<void> ping(
    String check,
    PingStatus status, {
    String? note,
    String? rid,
  });
}

/// 알림 포트 — 엔진이 정한 코드만 넘긴다(등급 · 발송은 받는 쪽 · M5 · E13).
abstract interface class AlertSink {
  /// [check] 잡이 낸 알림 코드.
  Future<void> emit(String check, Set<String> codes);
}

/// 잡 결과 상태.
enum JobStatus {
  /// 본체가 끝났다.
  success,

  /// KR 비세션 — 본체를 돌리지 않았다.
  holiday,

  /// 본체 예외 · 알림 발송 실패 · 달력 범위 밖.
  failed,
}

/// 잡 본체가 돌려주는 것.
class JobBody<T> {
  /// 본체 결과를 만든다.
  const JobBody(this.report, {this.alerts = const <String>{}, this.note});

  /// 본체 보고.
  final T report;

  /// 알림 코드.
  final Set<String> alerts;

  /// 성공 핑 메모.
  final String? note;
}

/// 잡 한 번의 결과(R42 S8).
class JobRun<T> {
  /// 결과를 만든다.
  const JobRun({
    required this.check,
    required this.status,
    required this.sessionDay,
    required this.rid,
    required this.report,
    required this.alerts,
    required this.note,
    required this.error,
    required this.pingFailures,
  });

  /// 체크 이름.
  final String check;

  /// 상태.
  final JobStatus status;

  /// 세션일(KR 잡 = KST 날 · `us_data` = 앞 날).
  final TradeDate sessionDay;

  /// 회차 id(핑에 실은 값).
  final String rid;

  /// 본체 보고(휴장 · 본체 실패면 null).
  final T? report;

  /// 낸 알림 코드.
  final Set<String> alerts;

  /// 핑 메모.
  final String? note;

  /// 실패 까닭.
  final Object? error;

  /// 보내지 못한 핑 수.
  final int pingFailures;
}

/// 체크 이름(04 §5-2 2축 접두) — `{sim|live}-{auto|advisory}-{잡}`.
String watchdogCheckName(RunMode run, OperatingMode op, String job) {
  final String r = run.isSim ? 'sim' : 'live';
  final String o = switch (op) {
    OperatingMode.autoTrade => 'auto',
    OperatingMode.advisory => 'advisory',
  };
  return '$r-$o-$job';
}

/// UTC 시각의 KST 날짜.
TradeDate kstDateOf(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return TradeDate('${k.year}-${two(k.month)}-${two(k.day)}');
}

/// UTC 시각의 KST 하루 중 시각.
Duration kstTimeOfDay(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  return Duration(hours: k.hour, minutes: k.minute, seconds: k.second);
}

int _fnv1a64(String s) {
  // 64비트 FNV-1a — 의존을 더하지 않는 결정적 해시(암호용 아님 · 회차 짝짓기용).
  int h = 0xcbf29ce484222325;
  for (final int c in s.codeUnits) {
    h ^= c;
    h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return h;
}

String _hex16(int v) => v.toUnsigned(64).toRadixString(16).padLeft(16, '0');

/// 회차 id(R43 B7) — (체크 · 시작 시각)의 결정적 UUID 꼴(버전 4 자리 · 변형 8).
String runIdFor(String check, DateTime startUtc) {
  final String seed = '$check|${startUtc.toUtc().toIso8601String()}';
  final String h = _hex16(_fnv1a64(seed)) + _hex16(_fnv1a64('$seed#2'));
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-4${h.substring(13, 16)}-'
      '8${h.substring(17, 20)}-${h.substring(20, 32)}';
}

String _short(Object e) {
  final String s = '$e';
  return s.length <= 200 ? s : '${s.substring(0, 200)}…';
}

/// 잡 규약 실행(R42 S3 · R43 B7) — 휴장 = 성공 핑만 · 아니면 start → [body] → success | fail.
///
/// [calendar] = 잡 시장의 달력 · [sessionDayOf] = 지금 → 다루는 세션일(기본 = KST 날 · `us_data` = 앞 날).
Future<JobRun<T>> runJob<T>({
  required String check,
  required JobHeartbeat heartbeat,
  required AlertSink alerts,
  required ExchangeCalendar calendar,
  required DateTime nowUtc,
  required Future<JobBody<T>> Function(TradeDate sessionDay) body,
  TradeDate Function(DateTime nowUtc) sessionDayOf = kstDateOf,
}) async {
  int pingFailures = 0;
  final String rid = runIdFor(check, nowUtc);
  Future<void> ping(PingStatus s, [String? note]) async {
    try {
      await heartbeat.ping(check, s, note: note, rid: rid);
    } on Object {
      pingFailures++;
    }
  }

  final TradeDate today = sessionDayOf(nowUtc);
  JobRun<T> failed(
    Object e, {
    T? report,
    Set<String> codes = const <String>{},
  }) => JobRun<T>(
    check: check,
    status: JobStatus.failed,
    sessionDay: today,
    rid: rid,
    report: report,
    alerts: codes,
    note: _short(e),
    error: e,
    pingFailures: pingFailures,
  );

  final bool session;
  try {
    session = calendar.isSession(today);
  } on Object catch (e) {
    // 달력 범위 밖 — 무엇도 판정할 수 없다(fail-closed).
    await ping(PingStatus.start);
    await ping(PingStatus.fail, _short(e));
    return failed(e);
  }
  if (!session) {
    await ping(PingStatus.success, '휴장');
    return JobRun<T>(
      check: check,
      status: JobStatus.holiday,
      sessionDay: today,
      rid: rid,
      report: null,
      alerts: const <String>{},
      note: '휴장',
      error: null,
      pingFailures: pingFailures,
    );
  }
  await ping(PingStatus.start);
  final JobBody<T> b;
  try {
    b = await body(today);
  } on Object catch (e) {
    await ping(PingStatus.fail, _short(e));
    return failed(e);
  }
  if (b.alerts.isNotEmpty) {
    try {
      await alerts.emit(check, b.alerts);
    } on Object catch (e) {
      await ping(PingStatus.fail, '알림 발송 실패 — ${_short(e)}');
      return failed(e, report: b.report, codes: b.alerts);
    }
  }
  await ping(PingStatus.success, b.note);
  return JobRun<T>(
    check: check,
    status: JobStatus.success,
    sessionDay: today,
    rid: rid,
    report: b.report,
    alerts: b.alerts,
    note: b.note,
    error: null,
    pingFailures: pingFailures,
  );
}
