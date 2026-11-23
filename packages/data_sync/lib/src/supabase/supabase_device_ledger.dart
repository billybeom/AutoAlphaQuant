// R-01 기기 원장 읽기(E16 R-01 진입로 · 설계 13 §8 R248 · 04 §9-6 ② · 배치 D `app_device` · `operator_lease` ·
// 계약 v1.34 RLS `device_select_own` · `lease_select`).
//
// 🔵 PostgREST 읽기 둘 = `GET /rest/v1/app_device?select=…`(소유자 = 자기 기기 전부 · 뷰어 = 자기 행) ·
//    `GET /rest/v1/operator_lease?select=…`(단일 행 · 인증 사용자 전부 읽기) · 머리 = 공개 키 `apikey` + `Authorization: Bearer
//    <접근 토큰>` · 401 · 403 = 토큰을 새로 받아 한 번 더.
// 🔴 쓰기 0 — 새 폰은 여기서 아무것도 바꾸지 않는다(기기 행 등록 · 리스 = X1 흐름 몫).
// 🔴 실패는 종류만(«모름» 쪽 — 엔진이 게이트 UNKNOWN · 분기 0 으로 그린다) · 로그인 전 = [DeviceLedgerFailure.notSignedIn]
//    (엔진 = 로그인 자리) · 세션은 금고에 있는데 토큰을 못 받음 = 로그인 전이 아니다(망 · 서버 — 로그인 칸을 다시 보이지 않는다).
// 🔴 토큰 · 주소 · 키는 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다.

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show RestartDevice, RestartLease, RestartLedger, SecretVault;
import 'package:http/http.dart' as http;

import 'supabase_auth.dart';
import 'supabase_server_time.dart';

/// 기기 원장 읽기 실패 종류.
enum DeviceLedgerFailure {
  /// 금고에 연결 칸이 없다 · 꼴 아님 · 금고 실패(o_07 ② 전) — 망 0.
  config,

  /// 로그인 세션이 없다(금고 새로고침 토큰 없음 · 서버가 세션을 끊음) — 망 0 또는 새로고침 거부 뒤.
  notSignedIn,

  /// 세션은 있는데 접근 토큰을 새로 받지 못했다(망 · 서버).
  tokenRefresh,

  /// 401 · 403(토큰을 새로 받아 한 번 더 해도).
  unauthorized,

  /// 서버 오류(5xx).
  server,

  /// 그 밖의 HTTP · 응답 꼴.
  badResponse,

  /// 망 · 시간 초과.
  network,
}

/// 기기 원장 읽기 한 번의 결과 — 🔴 토큰 없음.
class DeviceLedgerRead {
  /// 읽었다.
  const DeviceLedgerRead.ok(RestartLedger this.ledger)
    : failure = null,
      statusCode = null;

  /// 못 읽었다.
  const DeviceLedgerRead.failed(
    DeviceLedgerFailure this.failure, {
    this.statusCode,
  }) : ledger = null;

  /// 읽은 원장(실패 = null).
  final RestartLedger? ledger;

  /// 실패 종류(읽었으면 null).
  final DeviceLedgerFailure? failure;

  /// HTTP 상태(있으면).
  final int? statusCode;

  /// 로그인 세션이 있다(로그인 전 · 연결 전이 아니다).
  bool get signedIn =>
      failure != DeviceLedgerFailure.notSignedIn &&
      failure != DeviceLedgerFailure.config;

  @override
  String toString() => failure == null
      ? 'DeviceLedgerRead(기기 ${ledger!.devices.length} · 리스 ${ledger!.lease == null ? '없음' : '있음'})'
      : 'DeviceLedgerRead(${failure!.name}'
            '${statusCode == null ? '' : ' · HTTP $statusCode'})';
}

/// `app_device` 상태(배치 D CHECK).
const Set<String> _statuses = <String>{
  'PENDING',
  'ACTIVE',
  'RETIRED',
  'REVOKED',
};

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

/// 읽는 열(배치 D 이름 그대로).
const String kDeviceLedgerDeviceColumns =
    'device_id,label,status,platform,last_seen_at';

/// 읽는 열(리스).
const String kDeviceLedgerLeaseColumns = 'device_id,epoch,expires_at';

/// R-01 기기 원장 읽기(읽기만).
class SupabaseDeviceLedger {
  /// 만든다 — 연결 칸 = [vault] · 접근 토큰 = [auth].
  SupabaseDeviceLedger(
    this._http,
    this._vault,
    this._auth, {
    this.timeout = const Duration(seconds: 10),
  });

  final http.Client _http;
  final SecretVault _vault;
  final SupabaseAuth _auth;

  /// 한 번의 상한.
  final Duration timeout;

  Future<(Uri, String)?> _config() async {
    try {
      final String? url = await _vault.read(SupabaseSecretIds.projectUrl);
      final String? key = await _vault.read(SupabaseSecretIds.publishableKey);
      if (url == null || key == null) return null;
      final Uri? base = supabaseProjectUri(url);
      if (base == null || supabasePublishableKeyProblem(key) != null) {
        return null;
      }
      return (base, key.trim());
    } on Object {
      return null;
    }
  }

  /// 금고에 쓸 수 있는 연결 칸(주소 · 공개 키)이 있다 — 망 0(R-01 로그인 자리의 ② · ③ 지점 사실).
  Future<bool> connected() async => await _config() != null;

  Future<http.Response?> _get(Uri uri, String key, String token) async {
    try {
      return await _http
          .get(
            uri,
            headers: <String, String>{
              'apikey': key,
              'authorization': 'Bearer $token',
              'accept': 'application/json',
            },
          )
          .timeout(timeout);
    } on Exception {
      return null;
    }
  }

  /// 한 표 읽기 — (본문 배열 | 실패).
  Future<(List<Object?>?, DeviceLedgerRead?)> _table(
    (Uri, String) cfg,
    String table,
    String columns,
    String token,
  ) async {
    final Uri uri = cfg.$1.replace(
      pathSegments: <String>['rest', 'v1', table],
      queryParameters: <String, String>{'select': columns},
    );
    http.Response? r = await _get(uri, cfg.$2, token);
    if (r != null && (r.statusCode == 401 || r.statusCode == 403)) {
      // 접근 토큰이 서버에서 먼저 죽었다 — 한 번만 새로 받아 다시.
      final String? fresh = await _auth.accessToken(forceRefresh: true);
      if (fresh == null) return (null, await _noToken());
      r = await _get(uri, cfg.$2, fresh);
    }
    if (r == null) {
      return (null, const DeviceLedgerRead.failed(DeviceLedgerFailure.network));
    }
    final int c = r.statusCode;
    if (c == 401 || c == 403) {
      return (
        null,
        DeviceLedgerRead.failed(
          DeviceLedgerFailure.unauthorized,
          statusCode: c,
        ),
      );
    }
    if (c >= 500) {
      return (
        null,
        DeviceLedgerRead.failed(DeviceLedgerFailure.server, statusCode: c),
      );
    }
    // 🔴 JSON = UTF-8(머리 charset 이 빠져도 한글 라벨이 깨지지 않게 바이트로 푼다).
    final List<Object?>? rows = c == 200 ? _array(r.bodyBytes) : null;
    if (rows == null) {
      return (
        null,
        DeviceLedgerRead.failed(DeviceLedgerFailure.badResponse, statusCode: c),
      );
    }
    return (rows, null);
  }

  /// 토큰을 못 받음 — 세션이 금고에 남아 있으면 망 · 서버(로그인 전이 아니다) · 없으면 로그인 전.
  Future<DeviceLedgerRead> _noToken() async {
    bool held;
    try {
      held = await _auth.hasSession();
    } on Object {
      held = false;
    }
    return DeviceLedgerRead.failed(
      held ? DeviceLedgerFailure.tokenRefresh : DeviceLedgerFailure.notSignedIn,
    );
  }

  static List<Object?>? _array(List<int> body) {
    try {
      final Object? v = jsonDecode(utf8.decode(body));
      return v is List<Object?> ? v : null;
    } on FormatException {
      return null;
    }
  }

  static DateTime? _time(Object? v) {
    if (v is! String || !_offset.hasMatch(v)) return null;
    return DateTime.tryParse(v)?.toUtc();
  }

  static RestartDevice? _device(Object? row) {
    if (row is! Map<String, Object?>) return null;
    final Object? id = row['device_id'];
    final Object? label = row['label'];
    final Object? status = row['status'];
    final Object? platform = row['platform'];
    final Object? seen = row['last_seen_at'];
    if (id is! String || id.isEmpty || label is! String) return null;
    if (status is! String || !_statuses.contains(status)) return null;
    if (platform != null && platform is! String) return null;
    final DateTime? seenAt = seen == null ? null : _time(seen);
    if (seen != null && seenAt == null) return null;
    return RestartDevice(
      deviceId: id,
      label: label,
      status: status,
      platform: platform as String?,
      lastSeenAtUtc: seenAt,
    );
  }

  static RestartLease? _lease(Object? row) {
    if (row is! Map<String, Object?>) return null;
    final Object? id = row['device_id'];
    final Object? epoch = row['epoch'];
    final DateTime? exp = _time(row['expires_at']);
    if (id is! String || id.isEmpty || epoch is! int || epoch < 1) return null;
    if (exp == null) return null;
    return RestartLease(deviceId: id, epoch: epoch, expiresAtUtc: exp);
  }

  /// 🔴 기기 원장 읽기(기기 행 → 리스 행).
  Future<DeviceLedgerRead> read() async {
    final (Uri, String)? cfg = await _config();
    if (cfg == null) {
      return const DeviceLedgerRead.failed(DeviceLedgerFailure.config);
    }
    final String? token = await _auth.accessToken();
    if (token == null) return _noToken();
    final (List<Object?>? devRows, DeviceLedgerRead? devFail) = await _table(
      cfg,
      'app_device',
      kDeviceLedgerDeviceColumns,
      token,
    );
    if (devFail != null) return devFail;
    final List<RestartDevice> devices = <RestartDevice>[];
    for (final Object? row in devRows!) {
      final RestartDevice? d = _device(row);
      if (d == null) {
        return const DeviceLedgerRead.failed(DeviceLedgerFailure.badResponse);
      }
      devices.add(d);
    }
    // 첫 표에서 토큰을 새로 받았을 수 있다 — 지금 토큰으로.
    final String? now = await _auth.accessToken();
    if (now == null) return _noToken();
    final (List<Object?>? leaseRows, DeviceLedgerRead? leaseFail) =
        await _table(cfg, 'operator_lease', kDeviceLedgerLeaseColumns, now);
    if (leaseFail != null) return leaseFail;
    if (leaseRows!.length > 1) {
      return const DeviceLedgerRead.failed(DeviceLedgerFailure.badResponse);
    }
    RestartLease? lease;
    if (leaseRows.isNotEmpty) {
      lease = _lease(leaseRows.single);
      if (lease == null) {
        return const DeviceLedgerRead.failed(DeviceLedgerFailure.badResponse);
      }
    }
    return DeviceLedgerRead.ok(RestartLedger(devices: devices, lease: lease));
  }
}
