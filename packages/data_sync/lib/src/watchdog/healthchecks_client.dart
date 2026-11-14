// healthchecks.io 어댑터(설계 13 §8 R45 C2~C6 · 06 M1-12 · X1-6 · 앱 04 §7 `W-01`).
//
// 🔵 healthchecks 문서(2026-11-04 직접 확인): 슬러그 핑 `hc-ping.com/<ping-key>/<slug>[/start|/fail]` · `rid` = 정규 UUID ·
//    슬러그 핑 404 = 체크 없음 · 409 = 슬러그 겹침 · 429 = 과속 · 관리 API v3 `X-Api-Key` · `GET /api/v3/checks/` ·
//    `POST /api/v3/checks/<uuid>/pause|resume`(resume 409 = 멈춰 있지 않음) · 읽기 전용 키는 `uuid` 가 없다.
// 🔴 `create=1` 은 절대 붙이지 않는다 — 오타 슬러그가 조용히 새 체크가 되면 진짜 체크는 «안 왔다»로 운다(자동 생성 = M5-11).
// 🔴 핑 URL · 키 · 체크 uuid 는 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다 — 알면 «살아있음»을 위조할 수 있다.
// 🔴 키는 부를 때마다 금고에서 읽는다(E11d 회전이 재기동 없이 먹게).
// 🔵 재시도 = 망 · 시간 초과 · 429 · 5xx 만(같은 핑을 두 번 보내도 해가 없다 — 성공 둘 = 성공 · start 둘 = 시간만 다시 잰다).
// 🆕 E15f4b1(R105 AJ3 · 문서 2026-11-14 확인) — 생성 `POST /api/v3/checks/` · `unique: ["slug"]`(같은 슬러그 = 고침 ·
//    재시도해도 하나) · 201 = 새로 · 200 = 고침 · 403 = 체크 상한 · 새 체크엔 연동이 안 붙으므로 `channels: "*"`.

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:http/http.dart' as http;

/// 실패 종류(R45 C2).
enum HealthchecksErrorKind {
  /// 금고에 키가 없다.
  missingKey,

  /// 슬러그 꼴이 아니다(망에 가지 않았다).
  badSlug,

  /// 체크가 없다(슬러그 핑 404 · 관리 API 0개).
  unknownCheck,

  /// 같은 슬러그가 여럿(409 · 관리 API 2개 이상).
  ambiguousSlug,

  /// 과속(429).
  rateLimited,

  /// 요청 꼴이 틀렸다(400).
  badRequest,

  /// 키가 틀렸다(401 · 403).
  unauthorized,

  /// 읽기 전용 키로 pause · resume 을 부르려 했다.
  readOnlyKey,

  /// 멈춤 규칙(core `pausePermitted` · SPEC 04 :925)이 거절했다 — 엔진 생존 체크 · 새 모드 체크 · 사유 없는 전환(X1-6 ⓑ).
  refusedPause,

  /// 🆕 E15f4b1 — 체크 상한(생성 403 · 무료 20).
  checkLimit,

  /// 서버 오류(5xx).
  server,

  /// 망 · 시간 초과.
  network,

  /// 그 밖의 HTTP · 응답 꼴이 틀렸다.
  badResponse,
}

/// healthchecks 실패 — 🔴 URL · 키 · uuid 없음(종류 · HTTP 상태 · 시도 수만).
class HealthchecksError implements Exception {
  /// 실패를 만든다.
  const HealthchecksError(this.kind, {this.statusCode, this.attempts = 1});

  /// 종류.
  final HealthchecksErrorKind kind;

  /// HTTP 상태(있으면).
  final int? statusCode;

  /// 시도 수.
  final int attempts;

  @override
  String toString() =>
      'HealthchecksError(${kind.name}'
      '${statusCode == null ? '' : ' · HTTP $statusCode'}'
      '${attempts > 1 ? ' · 시도 $attempts' : ''})';
}

/// 기다리기(시험은 바로 돌아오는 것을 넣는다).
typedef HealthchecksSleep = Future<void> Function(Duration);

Future<void> _realSleep(Duration d) => Future<void>.delayed(d);

final RegExp _slugShape = RegExp(r'^[a-z0-9_-]{1,100}$');
final RegExp _uuidShape = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

/// 핑 메모 상한(자).
const int kHealthchecksNoteLimit = 1000;

/// healthchecks.io 어댑터 — [JobHeartbeat] · [WatchdogRemote] 구현(R45).
class HealthchecksClient implements JobHeartbeat, WatchdogRemote {
  /// 어댑터를 만든다 — 키는 [vault] 의 [pingKeyId] · [apiKeyId].
  HealthchecksClient(
    this._http,
    this._vault, {
    Uri? pingBase,
    Uri? apiBase,
    this.timeout = const Duration(seconds: 10),
    this.backoff = const <Duration>[Duration(seconds: 1), Duration(seconds: 2)],
    HealthchecksSleep? sleep,
  }) : pingBase = pingBase ?? Uri.parse('https://hc-ping.com'),
       apiBase = apiBase ?? Uri.parse('https://healthchecks.io'),
       _sleep = sleep ?? _realSleep {
    for (final Uri u in <Uri>[this.pingBase, this.apiBase]) {
      if (u.scheme != 'https' || u.host.isEmpty) {
        throw ArgumentError('healthchecks 주소는 https 여야 한다');
      }
    }
  }

  final http.Client _http;
  final SecretVault _vault;
  final HealthchecksSleep _sleep;

  /// 핑 주소 바탕.
  final Uri pingBase;

  /// 관리 API 바탕.
  final Uri apiBase;

  /// 시도 한 번의 상한.
  final Duration timeout;

  /// 재시도 전 기다림(길이 = 최대 재시도 수).
  final List<Duration> backoff;

  /// 프로젝트 핑 키 칸.
  static final SecretId pingKeyId = SecretId('healthchecks.ping_key');

  /// 관리 API 키 칸.
  static final SecretId apiKeyId = SecretId('healthchecks.api_key');

  Future<String> _key(SecretId id) async {
    final String? v = await _vault.read(id);
    if (v == null || v.isEmpty) {
      throw const HealthchecksError(HealthchecksErrorKind.missingKey);
    }
    return v;
  }

  static void _checkSlug(String slug) {
    if (!_slugShape.hasMatch(slug)) {
      throw ArgumentError.value(slug.length, 'slug', '슬러그 꼴이 아니다(길이)');
    }
  }

  Uri _join(Uri base, List<String> segments, [Map<String, String>? query]) =>
      base.replace(
        pathSegments: <String>[
          ...base.pathSegments.where((String s) => s.isNotEmpty),
          ...segments,
        ],
        queryParameters: query == null || query.isEmpty ? null : query,
      );

  static bool _retryable(int code) => code == 429 || code >= 500;

  /// 보내고 받는다 — 망 · 시간 초과 · 429 · 5xx 는 [backoff] 만큼 다시. 마지막 응답 또는 망 실패.
  Future<(http.Response?, int)> _send(
    Future<http.Response> Function() call,
  ) async {
    for (int attempt = 1; ; attempt++) {
      http.Response? r;
      try {
        r = await call().timeout(timeout);
      } on TimeoutException {
        r = null;
      } on http.ClientException {
        r = null;
      }
      final bool again = r == null || _retryable(r.statusCode);
      if (!again || attempt > backoff.length) return (r, attempt);
      await _sleep(backoff[attempt - 1]);
    }
  }

  static HealthchecksError _errorOf(
    http.Response? r,
    int attempts, {
    bool slugPing = false,
  }) {
    if (r == null) {
      return HealthchecksError(
        HealthchecksErrorKind.network,
        attempts: attempts,
      );
    }
    final int c = r.statusCode;
    final HealthchecksErrorKind kind = switch (c) {
      400 => HealthchecksErrorKind.badRequest,
      401 || 403 => HealthchecksErrorKind.unauthorized,
      404 when slugPing => HealthchecksErrorKind.unknownCheck,
      409 when slugPing => HealthchecksErrorKind.ambiguousSlug,
      429 => HealthchecksErrorKind.rateLimited,
      >= 500 => HealthchecksErrorKind.server,
      _ => HealthchecksErrorKind.badResponse,
    };
    return HealthchecksError(kind, statusCode: c, attempts: attempts);
  }

  /// 핑(R45 C2 · C3) — `POST {핑 바탕}/{핑 키}/{슬러그}[/start|/fail]` · `rid` 는 UUID 꼴일 때만 · 🔴 `create` 없음.
  @override
  Future<void> ping(
    String check,
    PingStatus status, {
    String? note,
    String? rid,
  }) async {
    _checkSlug(check);
    final String key = await _key(pingKeyId);
    final Uri uri = _join(
      pingBase,
      <String>[key, check, if (status != PingStatus.success) status.wire],
      <String, String>{
        if (rid != null && _uuidShape.hasMatch(rid.toLowerCase()))
          'rid': rid.toLowerCase(),
      },
    );
    String body = note ?? '';
    if (body.length > kHealthchecksNoteLimit) {
      body = '${body.substring(0, kHealthchecksNoteLimit)}…';
    }
    body = redactSecrets(body, <String>[key, ...await _knownApiKey()]);
    final (http.Response? r, int attempts) = await _send(
      () => _http.post(
        uri,
        headers: const <String, String>{
          'content-type': 'text/plain; charset=utf-8',
        },
        body: utf8.encode(body),
      ),
    );
    if (r != null && r.statusCode == 200) return;
    throw _errorOf(r, attempts, slugPing: true);
  }

  Future<List<String>> _knownApiKey() async {
    try {
      final String? v = await _vault.read(apiKeyId);
      return v == null ? const <String>[] : <String>[v];
    } on Object {
      return const <String>[];
    }
  }

  Future<List<Map<String, Object?>>> _listRaw({String? slug}) async {
    final String key = await _key(apiKeyId);
    final Uri uri = _join(
      apiBase,
      const <String>['api', 'v3', 'checks', ''],
      <String, String>{'slug': ?slug},
    );
    final (http.Response? r, int attempts) = await _send(
      () => _http.get(uri, headers: <String, String>{'X-Api-Key': key}),
    );
    if (r == null || r.statusCode != 200) throw _errorOf(r, attempts);
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException {
      throw HealthchecksError(
        HealthchecksErrorKind.badResponse,
        statusCode: 200,
        attempts: attempts,
      );
    }
    final Object? list = decoded is Map<String, Object?>
        ? decoded['checks']
        : null;
    if (list is! List<Object?> ||
        list.any((Object? e) => e is! Map<String, Object?>)) {
      throw HealthchecksError(
        HealthchecksErrorKind.badResponse,
        statusCode: 200,
        attempts: attempts,
      );
    }
    return list.cast<Map<String, Object?>>();
  }

  static DateTime? _time(Object? v) =>
      v is String ? DateTime.tryParse(v)?.toUtc() : null;

  static RemoteCheck? _checkOf(Map<String, Object?> m) {
    final Object? slug = m['slug'];
    if (slug is! String || slug.isEmpty) return null;
    final Object? grace = m['grace'];
    final Object? name = m['name'];
    return RemoteCheck(
      slug: slug,
      name: name is String ? name : '',
      status: RemoteCheckStatus.parse(m['status']),
      started: m['started'] == true,
      lastPingUtc: _time(m['last_ping']),
      nextPingUtc: _time(m['next_ping']),
      grace: grace is int ? Duration(seconds: grace) : null,
    );
  }

  /// 프로젝트의 체크 전부(R45 C5) — 슬러그 없는 행은 뺀다 · 🔴 uuid 는 담지 않는다.
  @override
  Future<List<RemoteCheck>> checks() async => <RemoteCheck>[
    for (final Map<String, Object?> m in await _listRaw()) ?_checkOf(m),
  ];

  /// 그때 다시 찾아 uuid 를 얻는다(R45 C6) — 0개 · 여럿 · uuid 없음(읽기 전용 키)은 실패.
  Future<String> _uuidOf(String slug) async {
    final List<Map<String, Object?>> hits = <Map<String, Object?>>[
      for (final Map<String, Object?> m in await _listRaw(slug: slug))
        if (m['slug'] == slug) m,
    ];
    if (hits.isEmpty) {
      throw const HealthchecksError(HealthchecksErrorKind.unknownCheck);
    }
    if (hits.length > 1) {
      throw const HealthchecksError(HealthchecksErrorKind.ambiguousSlug);
    }
    final Object? uuid = hits.single['uuid'];
    if (uuid is! String || !_uuidShape.hasMatch(uuid)) {
      throw const HealthchecksError(HealthchecksErrorKind.readOnlyKey);
    }
    return uuid;
  }

  Future<http.Response?> _post(String uuid, String action) async {
    final String key = await _key(apiKeyId);
    final Uri uri = _join(apiBase, <String>[
      'api',
      'v3',
      'checks',
      uuid,
      action,
    ]);
    final (http.Response? r, int attempts) = await _send(
      () => _http.post(uri, headers: <String, String>{'X-Api-Key': key}),
    );
    if (r != null && (r.statusCode == 200 || r.statusCode == 409)) return r;
    throw _errorOf(r, attempts);
  }

  /// 🆕 E15f4b1 — 만든다(같은 슬러그가 있으면 고친다 · R105 AJ3) — 먼저 슬러그로 찾아 여럿 = `ambiguousSlug` ·
  /// uuid 없음(읽기 전용 키) = `readOnlyKey` 이면 POST 하지 않는다 · 🔴 `unique` 없는 생성은 없다.
  @override
  Future<EnsuredCheck> ensure(WatchdogCheckSpec spec) async {
    _checkSlug(spec.slug);
    final List<Map<String, Object?>> hits = <Map<String, Object?>>[
      for (final Map<String, Object?> m in await _listRaw(slug: spec.slug))
        if (m['slug'] == spec.slug) m,
    ];
    if (hits.length > 1) {
      throw const HealthchecksError(HealthchecksErrorKind.ambiguousSlug);
    }
    if (hits.length == 1) {
      final Object? uuid = hits.single['uuid'];
      if (uuid is! String || !_uuidShape.hasMatch(uuid)) {
        throw const HealthchecksError(HealthchecksErrorKind.readOnlyKey);
      }
    }
    final String key = await _key(apiKeyId);
    final Uri uri = _join(apiBase, const <String>['api', 'v3', 'checks', '']);
    final String? cron = spec.cron;
    final String body = jsonEncode(<String, Object?>{
      'name': spec.name,
      'slug': spec.slug,
      'tags': spec.tags.join(' '),
      'grace': spec.grace.inSeconds,
      if (cron != null) ...<String, Object?>{'schedule': cron, 'tz': spec.tz},
      if (cron == null) 'timeout': spec.timeout!.inSeconds,
      'channels': '*',
      'unique': const <String>['slug'],
    });
    final (http.Response? r, int attempts) = await _send(
      () => _http.post(
        uri,
        headers: <String, String>{
          'X-Api-Key': key,
          'content-type': 'application/json',
        },
        body: utf8.encode(body),
      ),
    );
    if (r != null && (r.statusCode == 200 || r.statusCode == 201)) {
      final Object? decoded;
      try {
        decoded = jsonDecode(utf8.decode(r.bodyBytes));
      } on FormatException {
        throw HealthchecksError(
          HealthchecksErrorKind.badResponse,
          statusCode: r.statusCode,
          attempts: attempts,
        );
      }
      final RemoteCheck? c = decoded is Map<String, Object?>
          ? _checkOf(decoded)
          : null;
      if (c == null || c.slug != spec.slug) {
        throw HealthchecksError(
          HealthchecksErrorKind.badResponse,
          statusCode: r.statusCode,
          attempts: attempts,
        );
      }
      return EnsuredCheck(
        c,
        r.statusCode == 201 ? EnsureOutcome.created : EnsureOutcome.updated,
      );
    }
    if (r != null && r.statusCode == 403) {
      throw HealthchecksError(
        HealthchecksErrorKind.checkLimit,
        statusCode: 403,
        attempts: attempts,
      );
    }
    throw _errorOf(r, attempts);
  }

  /// 멈춘다(R45 C6) — 🔴 멈춤 규칙(`pausePermitted`)이 거절하면 망에 가기 전에 거절(🆕 E15f4b1 — 모드 전환 커밋은 새 접두 [toPrefix] 필수 · 옛 모드 엔진 생존 체크는 이때만 멈춘다).
  @override
  Future<void> pause(
    String slug, {
    required PauseReason reason,
    String? toPrefix,
  }) async {
    _checkSlug(slug);
    if (!pausePermitted(slug, reason, toPrefix: toPrefix)) {
      throw const HealthchecksError(HealthchecksErrorKind.refusedPause);
    }
    final http.Response? r = await _post(await _uuidOf(slug), 'pause');
    if (r!.statusCode != 200) {
      throw HealthchecksError(
        HealthchecksErrorKind.badResponse,
        statusCode: r.statusCode,
      );
    }
  }

  /// 다시 켠다(R45 C6) — 409(멈춰 있지 않았다) = false.
  @override
  Future<bool> resume(String slug, {required PauseReason reason}) async {
    _checkSlug(slug);
    final http.Response? r = await _post(await _uuidOf(slug), 'resume');
    return r!.statusCode == 200;
  }

  @override
  String toString() => 'HealthchecksClient(${pingBase.host} · ${apiBase.host})';
}
