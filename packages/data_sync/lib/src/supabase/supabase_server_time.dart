// Supabase 서버 시각 어댑터(E11k-a · 설계 13 §8 R197 · 06 M1-13 · R43 D2 · D13) — core `ServerTimeSource` 구현.
//
// 🔵 시각 = Supabase 게이트웨이가 응답에 찍는 HTTP `Date` 머리(RFC 9110 §6.6.1 · 초 내림) — 🔴 사용자가 SQL 편집기로
//    다시 정의할 수 있는 RPC(`server_now()` 등)가 아니다(발주자 본인 프로젝트라 함수 본문을 바꿀 수 있다 · R197 T1).
//    그래서 주소는 `https://<ref>.supabase.co` 꼴만 받는다(남의 서버 · 사용자 서버의 `Date` 를 믿지 않는다).
// 🔵 부르는 곳 = `GET /auth/v1/health`(공개 키 `apikey` 머리만 · 로그인 · 부트스트랩 SQL 과 무관) — 2xx 일 때만 시각을 쓴다.
// 🔴 프로젝트 주소 · 공개 키는 금고에만 있다(17 절차서 §6 o_07 ② · SPEC NR-5) — 부를 때마다 금고에서 읽는다(회전이 바로 먹게).
// 🔴 주소 · 키는 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다 — 종류 · HTTP 상태만.
// 🔴 비밀 키(`sb_secret_…`) · service_role JWT 는 받지 않는다 — 모든 RLS 를 건너뛰는 키다(설계상 어디에도 두지 않는다).

import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpDate;

import 'package:core_engine/core_engine.dart';
import 'package:http/http.dart' as http;

/// 🆕 Supabase 연결 금고 칸(o_07 ② — 프로젝트 주소 · 공개 키).
abstract final class SupabaseSecretIds {
  /// 프로젝트 주소(`https://<ref>.supabase.co`).
  static final SecretId projectUrl = SecretId('supabase.project_url');

  /// 공개 키(publishable `sb_publishable_…` 또는 옛 anon JWT).
  static final SecretId publishableKey = SecretId('supabase.publishable_key');

  /// 🆕 E11k-d1(R209) — Auth 새로고침 토큰(로그인 · 회전마다 덮어씀 · 접근 토큰 = 메모리만).
  static final SecretId refreshToken = SecretId('supabase.refresh_token');
}

/// 🆕 붙여넣은 연결 값의 문제(o_07 ② 입력 판정 · 문제 없음 = null) · 🆕 E11k-c [wire] = 계약 v1.29 `SupabaseInputResultCodes`
/// (01 §8 미결 213 — 엔진 글자 1:1 · 대조 = `test/e11k_contract_parity_test.dart`).
enum SupabaseInputProblem {
  /// 비었다.
  empty('SUPABASE_INPUT_EMPTY'),

  /// 빈칸 · 줄바꿈 · 따옴표가 섞였다.
  whitespace('SUPABASE_INPUT_WHITESPACE'),

  /// 프로젝트 주소 꼴(`https://<ref>.supabase.co`)이 아니다.
  notProjectUrl('SUPABASE_URL_INVALID'),

  /// 🔴 비밀 키(`sb_secret_…`)다.
  secretKey('SUPABASE_SECRET_KEY_REJECTED'),

  /// 🔴 service_role JWT 다.
  serviceRoleKey('SUPABASE_SERVICE_ROLE_REJECTED'),

  /// 공개 키 꼴이 아니다.
  notPublishableKey('SUPABASE_KEY_INVALID');

  const SupabaseInputProblem(this.wire);

  /// 와이어 글자(`ActionResult.reasonCode`).
  final String wire;
}

final RegExp _space = RegExp(r'''[\s"'`]''');
final RegExp _projectUrl = RegExp(
  r'^https://([a-z0-9]{16,40})\.supabase\.co/?$',
);
final RegExp _publishable = RegExp(r'^sb_publishable_[A-Za-z0-9_-]{8,}$');

SupabaseInputProblem? _common(String v) {
  if (v.isEmpty) return SupabaseInputProblem.empty;
  if (_space.hasMatch(v)) return SupabaseInputProblem.whitespace;
  return null;
}

/// 🆕 프로젝트 주소 판정 — [raw] 는 앞뒤 빈칸을 떼고 본다.
SupabaseInputProblem? supabaseProjectUrlProblem(String raw) {
  final String v = raw.trim();
  return _common(v) ??
      (_projectUrl.hasMatch(v) ? null : SupabaseInputProblem.notProjectUrl);
}

/// 🆕 프로젝트 주소 → 바탕 주소(끝 `/` 없음) — 꼴이 아니면 null.
Uri? supabaseProjectUri(String raw) {
  final String v = raw.trim();
  if (supabaseProjectUrlProblem(v) != null) return null;
  return Uri.parse(v.endsWith('/') ? v.substring(0, v.length - 1) : v);
}

/// 🆕 공개 키 판정 — publishable 키 또는 `role = anon` 인 옛 JWT 만. 🔴 비밀 키 · service_role 은 따로 짚는다(조치가 다르다).
SupabaseInputProblem? supabasePublishableKeyProblem(String raw) {
  final String v = raw.trim();
  final SupabaseInputProblem? c = _common(v);
  if (c != null) return c;
  if (v.startsWith('sb_secret_')) return SupabaseInputProblem.secretKey;
  if (v.startsWith('sb_publishable_')) {
    return _publishable.hasMatch(v)
        ? null
        : SupabaseInputProblem.notPublishableKey;
  }
  if (v.startsWith('eyJ')) {
    return switch (_jwtRole(v)) {
      'anon' => null,
      'service_role' => SupabaseInputProblem.serviceRoleKey,
      _ => SupabaseInputProblem.notPublishableKey,
    };
  }
  return SupabaseInputProblem.notPublishableKey;
}

String? _jwtRole(String jwt) {
  final List<String> parts = jwt.split('.');
  if (parts.length != 3) return null;
  try {
    final Object? body = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final Object? role = body is Map<String, Object?> ? body['role'] : null;
    return role is String ? role : null;
  } on FormatException {
    return null;
  }
}

/// 🆕 서버 시각 읽기 실패 종류 · 🆕 E11k-c [wire] = 계약 v1.29 `SupabaseTimeResultCodes`(미결 213).
enum SupabaseTimeFailure {
  /// 금고에 주소 · 키가 없다(o_07 ② 전) — 망에 가지 않았다.
  notConfigured('SUPABASE_NOT_CONFIGURED'),

  /// 금고 값이 꼴이 아니다(주소 · 키) — 망에 가지 않았다.
  badConfig('SUPABASE_CONFIG_INVALID'),

  /// 금고를 읽지 못했다.
  vault('SUPABASE_VAULT_UNREADABLE'),

  /// 키가 틀렸다(401 · 403).
  unauthorized('SUPABASE_UNAUTHORIZED'),

  /// 서버 오류(5xx).
  server('SUPABASE_SERVER_ERROR'),

  /// 그 밖의 HTTP 상태.
  badResponse('SUPABASE_BAD_RESPONSE'),

  /// 2xx 인데 `Date` 머리가 없거나 읽을 수 없다.
  noDate('SUPABASE_DATE_MISSING'),

  /// 망 · 시간 초과.
  network('SUPABASE_NETWORK');

  const SupabaseTimeFailure(this.wire);

  /// 와이어 글자(`ActionResult.reasonCode`).
  final String wire;
}

/// 🆕 서버 시각 한 번 읽은 결과 — 🔴 주소 · 키 없음(종류 · HTTP 상태만).
class SupabaseTimeRead {
  /// 성공.
  const SupabaseTimeRead.ok(DateTime this.serverUtc)
    : failure = null,
      statusCode = null;

  /// 실패.
  const SupabaseTimeRead.failed(
    SupabaseTimeFailure this.failure, {
    this.statusCode,
  }) : serverUtc = null;

  /// 서버 시각(UTC · 초 내림 · 실패 = null).
  final DateTime? serverUtc;

  /// 실패 종류(성공 = null).
  final SupabaseTimeFailure? failure;

  /// HTTP 상태(있으면).
  final int? statusCode;

  @override
  String toString() => failure == null
      ? 'SupabaseTimeRead(ok)'
      : 'SupabaseTimeRead(${failure!.name}'
            '${statusCode == null ? '' : ' · HTTP $statusCode'})';
}

/// 🆕 Supabase 서버 시각 — core [ServerTimeSource] 구현(E11k-a).
class SupabaseServerTime implements ServerTimeSource {
  /// 만든다 — 주소 · 키 = [vault] 의 [SupabaseSecretIds] 칸 · [timeout] = 한 번의 상한(넘으면 망 실패).
  SupabaseServerTime(
    this._http,
    this._vault, {
    this.timeout = kTrustedTimeMaxRoundTrip,
  });

  final http.Client _http;
  final SecretVault _vault;

  /// 한 번의 상한.
  final Duration timeout;

  /// 시각을 읽는 자리(공개 키만 · 로그인 무관).
  static const List<String> healthPath = <String>['auth', 'v1', 'health'];

  /// 한 번 읽는다 — 🔴 던지지 않는다.
  Future<SupabaseTimeRead> read() async {
    final String? url;
    final String? key;
    try {
      url = await _vault.read(SupabaseSecretIds.projectUrl);
      key = await _vault.read(SupabaseSecretIds.publishableKey);
    } on Object {
      return const SupabaseTimeRead.failed(SupabaseTimeFailure.vault);
    }
    if (url == null || url.isEmpty || key == null || key.isEmpty) {
      return const SupabaseTimeRead.failed(SupabaseTimeFailure.notConfigured);
    }
    return probe(url, key);
  }

  /// 🆕 E11k-c — 주어진 주소 · 키로 한 번 읽는다(금고를 읽지도 쓰지도 않는다 — o_07 ② «검증 뒤 저장»의 검증) ·
  /// 꼴이 아니면 망에 가지 않고 [SupabaseTimeFailure.badConfig] · 🔴 던지지 않는다.
  Future<SupabaseTimeRead> probe(String url, String key) async {
    final Uri? base = supabaseProjectUri(url);
    if (base == null || supabasePublishableKeyProblem(key) != null) {
      return const SupabaseTimeRead.failed(SupabaseTimeFailure.badConfig);
    }
    final http.Response r;
    try {
      r = await _http
          .get(
            base.replace(pathSegments: healthPath),
            headers: <String, String>{'apikey': key.trim()},
          )
          .timeout(timeout);
    } on Exception {
      // 🔵 시간 초과 · `ClientException` · 소켓 · TLS — 무엇이든 «망»(값을 싣지 않는다).
      return const SupabaseTimeRead.failed(SupabaseTimeFailure.network);
    }
    final int c = r.statusCode;
    if (c < 200 || c > 299) {
      return SupabaseTimeRead.failed(switch (c) {
        401 || 403 => SupabaseTimeFailure.unauthorized,
        >= 500 => SupabaseTimeFailure.server,
        _ => SupabaseTimeFailure.badResponse,
      }, statusCode: c);
    }
    final String? date = r.headers['date'];
    if (date == null) {
      return SupabaseTimeRead.failed(SupabaseTimeFailure.noDate, statusCode: c);
    }
    try {
      return SupabaseTimeRead.ok(HttpDate.parse(date).toUtc());
    } on Exception {
      return SupabaseTimeRead.failed(SupabaseTimeFailure.noDate, statusCode: c);
    }
  }

  @override
  Future<DateTime?> serverTimeUtc() async => (await read()).serverUtc;
}

/// 🆕 E11k-c — 연결 값을 금고에 둔다(o_07 ② 검증 통과 뒤에만 부른다) · 주소 = 끝 `/` 없는 바탕 주소 · 키 = 앞뒤 빈칸 뗌.
/// 🔴 꼴이 아니면 [ArgumentError](값 0 · 금고에 아무것도 쓰지 않는다) · 금고 실패 = 그대로 던진다.
Future<void> storeSupabaseConnection(
  SecretVault vault, {
  required String url,
  required String key,
}) async {
  final Uri? base = supabaseProjectUri(url);
  if (base == null) {
    throw ArgumentError('프로젝트 주소 꼴이 아니다(값 생략)');
  }
  if (supabasePublishableKeyProblem(key) != null) {
    throw ArgumentError('공개 키 꼴이 아니다(값 생략)');
  }
  await vault.write(SupabaseSecretIds.projectUrl, base.toString());
  await vault.write(SupabaseSecretIds.publishableKey, key.trim());
}
