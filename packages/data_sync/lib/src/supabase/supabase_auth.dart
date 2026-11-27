// Supabase Auth 어댑터 — 이메일 + 비밀번호 로그인 · 새로고침 토큰 회전 · 로그아웃(E11k-d1 · 설계 13 §8 R209 · R197 T8 ·
// 계약 v1.29 R-01 주석 «이메일 + 비밀번호» · 지도 D18).
//
// 🔵 GoTrue 창구(공개 키 `apikey` 머리 + JSON):
//    로그인 = `POST /auth/v1/token?grant_type=password` {email, password} · 새로고침 = `?grant_type=refresh_token` {refresh_token} ·
//    로그아웃 = `POST /auth/v1/logout?scope=local|global`(머리 `Authorization: Bearer <접근 토큰>`).
// 🔴 비밀번호 = 로그인 한 번에만 쓰고 쥐지 않는다(필드 · 금고 · 문자열 0) · 접근 토큰 = 메모리만(D18) ·
//    새로고침 토큰 = 금고(`supabase.refresh_token`)에만 — 🔴 회전: 새 토큰을 받으면 **금고에 먼저 쓰고** 그 뒤 새 세션을 쓴다.
// 🔴 새로고침은 겹쳐 부르지 않는다(한 번만 날림) — 같은 새로고침 토큰을 두 번 쓰면 서버가 재사용으로 보고 세션 전체를 끊는다.
// 🔴 새로고침 거부(400) = 세션 잃음 → 금고 칸을 지운다(다시 로그인) · 로그아웃 = 서버 결과와 무관하게 금고 칸을 지운다.
// 🔴 이메일 · 비밀번호 · 토큰 · 주소 · 키는 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다 — 종류 · HTTP 상태만.
// 🆕 E11k-d2(R216) — 와이어 = enum `wire`(계약 v1.31) · 로그인 결과 글자 = `supabase_connect.dart` `supabaseSignInOutcome`.

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:http/http.dart' as http;

import 'supabase_server_time.dart';

/// 🆕 인증 실패 종류(E11k-d1) · 🆕 E11k-d2 [wire] = 계약 v1.31(01 §40 K240 · 미결 215): 전송 6 = `SupabaseTimeResultCodes` 글자 한 벌 ·
/// 인증 고유 6 = `SupabaseAuthResultCodes`(대조 = `test/e11k_contract_parity_test.dart`).
enum SupabaseAuthFailure {
  /// 금고에 주소 · 공개 키가 없다(o_07 ② 전) — 망에 가지 않았다.
  notConfigured('SUPABASE_NOT_CONFIGURED'),

  /// 금고 값이 꼴이 아니다 — 망에 가지 않았다.
  badConfig('SUPABASE_CONFIG_INVALID'),

  /// 금고를 읽거나 쓰지 못했다(🔴 시각 쪽 «읽기만»과 다른 글자).
  vault('SUPABASE_AUTH_VAULT_FAILED'),

  /// 이메일 · 비밀번호 꼴이 아니다(빈칸 등) — 망에 가지 않았다.
  badInput('SUPABASE_AUTH_INPUT_INVALID'),

  /// 로그인한 적이 없다(금고에 새로고침 토큰 없음) — 망에 가지 않았다.
  notSignedIn('SUPABASE_NOT_SIGNED_IN'),

  /// 이메일 · 비밀번호가 틀렸다(로그인 400).
  invalidCredentials('SUPABASE_CREDENTIALS_REJECTED'),

  /// 세션을 잃었다(새로고침 400 — 만료 · 재사용 · 철회) — 금고 칸을 지웠다 · 다시 로그인.
  sessionLost('SUPABASE_SESSION_LOST'),

  /// 공개 키가 거절됐다(401 · 403).
  unauthorized('SUPABASE_UNAUTHORIZED'),

  /// 과속(429).
  rateLimited('SUPABASE_RATE_LIMITED'),

  /// 서버 오류(5xx).
  server('SUPABASE_SERVER_ERROR'),

  /// 그 밖의 HTTP · 응답 꼴이 틀렸다.
  badResponse('SUPABASE_BAD_RESPONSE'),

  /// 망 · 시간 초과.
  network('SUPABASE_NETWORK');

  const SupabaseAuthFailure(this.wire);

  /// 와이어 글자(`ActionResult.reasonCode`).
  final String wire;
}

/// 🆕 인증 한 번의 결과 — 🔴 이메일 · 토큰 없음(종류 · HTTP 상태 · 사용자 id 만).
class SupabaseAuthResult {
  /// 성공.
  const SupabaseAuthResult.ok(String this.userId)
    : failure = null,
      statusCode = null;

  /// 실패.
  const SupabaseAuthResult.failed(
    SupabaseAuthFailure this.failure, {
    this.statusCode,
  }) : userId = null;

  /// 성공했나.
  bool get ok => failure == null;

  /// 인증 사용자 id(`auth.users.id` · 성공 = 값).
  final String? userId;

  /// 실패 종류(성공 = null).
  final SupabaseAuthFailure? failure;

  /// HTTP 상태(있으면).
  final int? statusCode;

  @override
  String toString() => ok
      ? 'SupabaseAuthResult(ok)'
      : 'SupabaseAuthResult(${failure!.name}'
            '${statusCode == null ? '' : ' · HTTP $statusCode'})';
}

/// 🆕 미결 243 ⓔ(설계 13 §8 R276 · 계약 v1.39 K349 ④ · 리뷰 3차 C-2) — o_07 ③ 공개 가입 확인 한 번의 결과
/// (🔴 주소 · 키 · 응답 본문 없음 — 닫힘 · 열림 · 실패 종류 · HTTP 상태만).
class SupabaseSignupRead {
  /// 가입이 꺼져 있다(`disable_signup == true`).
  const SupabaseSignupRead.closed()
    : signupOpen = false,
      failure = null,
      statusCode = null;

  /// 가입이 열려 있다(`disable_signup == false`).
  const SupabaseSignupRead.open()
    : signupOpen = true,
      failure = null,
      statusCode = null;

  /// 읽지 못했다(🔴 모름 = 닫힘 아님).
  const SupabaseSignupRead.failed(
    SupabaseAuthFailure this.failure, {
    this.statusCode,
  }) : signupOpen = null;

  /// 열려 있나(읽지 못함 = null).
  final bool? signupOpen;

  /// 실패 종류(읽었음 = null).
  final SupabaseAuthFailure? failure;

  /// HTTP 상태(있으면).
  final int? statusCode;

  @override
  String toString() => failure == null
      ? 'SupabaseSignupRead(${signupOpen! ? 'open' : 'closed'})'
      : 'SupabaseSignupRead(${failure!.name}'
            '${statusCode == null ? '' : ' · HTTP $statusCode'})';
}

/// 메모리 세션(🔴 문자열에 토큰 0).
class _Session {
  _Session(this.accessToken, this.expiresAtUtc, this.userId);
  final String accessToken;
  final DateTime expiresAtUtc;
  final String userId;

  @override
  String toString() => '_Session(…)';
}

final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// 🆕 E11k-d2(R216) — 이메일 꼴인가(앞뒤 빈칸은 떼고 본다 · 로그인 칸의 붙여넣기 판정 = [SupabaseAuth.signIn] 과 같은 꼴).
bool supabaseEmailLooksValid(String raw) => _email.hasMatch(raw.trim());

/// 🆕 Supabase Auth — 이메일 + 비밀번호 · 새로고침 토큰 회전 · 로그아웃(E11k-d1).
class SupabaseAuth {
  /// 만든다 — 주소 · 공개 키 · 새로고침 토큰 = [vault] · [clock] = 접근 토큰 만료 판정(기기 시계로 충분 — 서버가 다시 거른다).
  SupabaseAuth(
    this._http,
    this._vault, {
    required this._clock,
    this.timeout = const Duration(seconds: 10),
    this.refreshMargin = const Duration(minutes: 5),
  });

  final http.Client _http;
  final SecretVault _vault;
  final Clock _clock;

  /// 한 번의 상한.
  final Duration timeout;

  /// 접근 토큰을 이만큼 남기고 미리 새로고침한다.
  final Duration refreshMargin;

  _Session? _session;
  Future<SupabaseAuthResult>? _refreshing;

  /// 지금 메모리 세션의 사용자 id(없음 = null).
  String? get userId => _session?.userId;

  /// 금고에 새로고침 토큰이 있나(= 로그인한 적이 있다 · 망 0).
  Future<bool> hasSession() async {
    try {
      final String? t = await _vault.read(SupabaseSecretIds.refreshToken);
      return t != null && t.isNotEmpty;
    } on Object {
      return false;
    }
  }

  /// 연결 칸(바탕 주소 · 공개 키) — 실패 = 종류.
  Future<(Uri, String)?> _config(
    void Function(SupabaseAuthFailure) fail,
  ) async {
    final String? url;
    final String? key;
    try {
      url = await _vault.read(SupabaseSecretIds.projectUrl);
      key = await _vault.read(SupabaseSecretIds.publishableKey);
    } on Object {
      fail(SupabaseAuthFailure.vault);
      return null;
    }
    if (url == null || url.isEmpty || key == null || key.isEmpty) {
      fail(SupabaseAuthFailure.notConfigured);
      return null;
    }
    final Uri? base = supabaseProjectUri(url);
    if (base == null || supabasePublishableKeyProblem(key) != null) {
      fail(SupabaseAuthFailure.badConfig);
      return null;
    }
    return (base, key.trim());
  }

  static Uri _token(Uri base, String grant) => base.replace(
    pathSegments: const <String>['auth', 'v1', 'token'],
    queryParameters: <String, String>{'grant_type': grant},
  );

  Future<http.Response?> _post(
    Uri uri,
    String key, {
    Object? body,
    String? bearer,
  }) async {
    try {
      return await _http
          .post(
            uri,
            headers: <String, String>{
              'apikey': key,
              'content-type': 'application/json',
              if (bearer != null) 'authorization': 'Bearer $bearer',
            },
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);
    } on Exception {
      return null;
    }
  }

  static SupabaseAuthFailure _httpFailure(
    int code, {
    required SupabaseAuthFailure on400,
  }) => switch (code) {
    400 => on400,
    401 || 403 => SupabaseAuthFailure.unauthorized,
    429 => SupabaseAuthFailure.rateLimited,
    >= 500 => SupabaseAuthFailure.server,
    _ => SupabaseAuthFailure.badResponse,
  };

  /// 토큰 응답 → 새 세션 + 새로고침 토큰(꼴이 틀리면 null).
  (_Session, String)? _parse(http.Response r) {
    final Object? body;
    try {
      body = jsonDecode(r.body);
    } on FormatException {
      return null;
    }
    if (body is! Map<String, Object?>) return null;
    final Object? access = body['access_token'];
    final Object? refresh = body['refresh_token'];
    final Object? expiresIn = body['expires_in'];
    final Object? user = body['user'];
    final Object? id = user is Map<String, Object?> ? user['id'] : null;
    if (access is! String ||
        access.isEmpty ||
        refresh is! String ||
        refresh.isEmpty ||
        expiresIn is! int ||
        expiresIn <= 0 ||
        id is! String ||
        id.isEmpty) {
      return null;
    }
    final DateTime exp = _clock.nowUtc().toUtc().add(
      Duration(seconds: expiresIn),
    );
    return (_Session(access, exp, id), refresh);
  }

  /// 🔴 회전 — 새 새로고침 토큰을 금고에 먼저 쓰고 그 뒤 새 세션을 쓴다. 금고 실패 = 메모리 세션은 쓴다(다음 기동 = 다시 로그인).
  Future<SupabaseAuthResult> _adopt(_Session s, String refresh) async {
    _session = s;
    try {
      await _vault.write(SupabaseSecretIds.refreshToken, refresh);
    } on Object {
      return const SupabaseAuthResult.failed(SupabaseAuthFailure.vault);
    }
    return SupabaseAuthResult.ok(s.userId);
  }

  /// 이메일 + 비밀번호로 로그인한다 — 🔴 비밀번호는 이 호출에만 쓰고 쥐지 않는다 · 던지지 않는다.
  Future<SupabaseAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final String e = email.trim();
    if (!_email.hasMatch(e) || password.isEmpty) {
      return const SupabaseAuthResult.failed(SupabaseAuthFailure.badInput);
    }
    SupabaseAuthFailure? cfgFail;
    final (Uri, String)? cfg = await _config((SupabaseAuthFailure f) {
      cfgFail = f;
    });
    if (cfg == null) return SupabaseAuthResult.failed(cfgFail!);
    final http.Response? r = await _post(
      _token(cfg.$1, 'password'),
      cfg.$2,
      body: <String, String>{'email': e, 'password': password},
    );
    if (r == null) {
      return const SupabaseAuthResult.failed(SupabaseAuthFailure.network);
    }
    if (r.statusCode != 200) {
      return SupabaseAuthResult.failed(
        _httpFailure(
          r.statusCode,
          on400: SupabaseAuthFailure.invalidCredentials,
        ),
        statusCode: r.statusCode,
      );
    }
    final (_Session, String)? p = _parse(r);
    if (p == null) {
      return SupabaseAuthResult.failed(
        SupabaseAuthFailure.badResponse,
        statusCode: r.statusCode,
      );
    }
    return _adopt(p.$1, p.$2);
  }

  /// 🆕 미결 243 ⓔ(설계 13 §8 R276 · 계약 v1.39 K349 ④) — 공개 가입이 꺼져 있나 — `GET /auth/v1/settings` 1회(공개 키 머리만 ·
  /// 접근 토큰 0 · 설정 바꾸기 0) · 🔴 던지지 않는다.
  /// `disable_signup == true` 만 닫힘 · `false` = 열림 · 칸 없음 · 꼴 아님 = [SupabaseAuthFailure.badResponse](모름 = 닫힘 아님) ·
  /// HTTP 실패 = 전송 글자(400 = 응답 꼴 · 401 · 403 = 키 · 429 = 과속 · 5xx = 서버) · 망 · 시간 초과 = 망.
  Future<SupabaseSignupRead> readSignup() async {
    SupabaseAuthFailure? cfgFail;
    final (Uri, String)? cfg = await _config((SupabaseAuthFailure f) {
      cfgFail = f;
    });
    if (cfg == null) return SupabaseSignupRead.failed(cfgFail!);
    final http.Response r;
    try {
      r = await _http
          .get(
            cfg.$1.replace(
              pathSegments: const <String>['auth', 'v1', 'settings'],
            ),
            headers: <String, String>{'apikey': cfg.$2},
          )
          .timeout(timeout);
    } on Exception {
      return const SupabaseSignupRead.failed(SupabaseAuthFailure.network);
    }
    if (r.statusCode != 200) {
      return SupabaseSignupRead.failed(
        _httpFailure(r.statusCode, on400: SupabaseAuthFailure.badResponse),
        statusCode: r.statusCode,
      );
    }
    Object? body;
    try {
      body = jsonDecode(r.body);
    } on FormatException {
      body = null;
    }
    final Object? disabled = body is Map<String, Object?>
        ? body['disable_signup']
        : null;
    if (disabled is! bool) {
      return SupabaseSignupRead.failed(
        SupabaseAuthFailure.badResponse,
        statusCode: r.statusCode,
      );
    }
    return disabled
        ? const SupabaseSignupRead.closed()
        : const SupabaseSignupRead.open();
  }

  /// 새로고침한다(금고의 새로고침 토큰 · 겹쳐 불러도 한 번만) — 🔴 던지지 않는다.
  Future<SupabaseAuthResult> refresh() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<SupabaseAuthResult> _refresh() async {
    SupabaseAuthFailure? cfgFail;
    final (Uri, String)? cfg = await _config((SupabaseAuthFailure f) {
      cfgFail = f;
    });
    if (cfg == null) return SupabaseAuthResult.failed(cfgFail!);
    final String? token;
    try {
      token = await _vault.read(SupabaseSecretIds.refreshToken);
    } on Object {
      return const SupabaseAuthResult.failed(SupabaseAuthFailure.vault);
    }
    if (token == null || token.isEmpty) {
      _session = null;
      return const SupabaseAuthResult.failed(SupabaseAuthFailure.notSignedIn);
    }
    final http.Response? r = await _post(
      _token(cfg.$1, 'refresh_token'),
      cfg.$2,
      body: <String, String>{'refresh_token': token},
    );
    if (r == null) {
      return const SupabaseAuthResult.failed(SupabaseAuthFailure.network);
    }
    if (r.statusCode != 200) {
      final SupabaseAuthFailure f = _httpFailure(
        r.statusCode,
        on400: SupabaseAuthFailure.sessionLost,
      );
      if (f == SupabaseAuthFailure.sessionLost) await _forget();
      return SupabaseAuthResult.failed(f, statusCode: r.statusCode);
    }
    final (_Session, String)? p = _parse(r);
    if (p == null) {
      return SupabaseAuthResult.failed(
        SupabaseAuthFailure.badResponse,
        statusCode: r.statusCode,
      );
    }
    return _adopt(p.$1, p.$2);
  }

  /// 메모리 세션 · 금고 칸을 지운다(금고 실패는 삼킨다 — 다음 새로고침이 거부되어 다시 지운다).
  Future<void> _forget() async {
    _session = null;
    try {
      await _vault.delete(SupabaseSecretIds.refreshToken);
    } on Object {
      // 지우지 못해도 그 토큰은 서버에서 이미 죽었다.
    }
  }

  /// 쓸 수 있는 접근 토큰 — 만료 [refreshMargin] 전이면 새로고침 · [forceRefresh] = 서버가 401 을 준 뒤.
  /// 로그인 전 · 새로고침 실패 = null(까닭 = [refresh] 결과). 🔴 값을 기록하지 않는다.
  Future<String?> accessToken({bool forceRefresh = false}) async {
    final _Session? s = _session;
    final DateTime now = _clock.nowUtc().toUtc();
    if (!forceRefresh &&
        s != null &&
        s.expiresAtUtc.difference(now) > refreshMargin) {
      return s.accessToken;
    }
    final SupabaseAuthResult r = await refresh();
    final _Session? after = _session;
    if (after == null) return null;
    // 금고 쓰기만 실패한 새로고침 = 메모리 세션은 새것이다.
    return r.ok || r.failure == SupabaseAuthFailure.vault
        ? after.accessToken
        : null;
  }

  /// 로그아웃 — [everywhere] = 이 사용자의 모든 기기 세션 철회(재발급 체크리스트 «원격 세션 철회») · 아니면 이 기기만.
  /// 🔴 서버 결과와 무관하게 메모리 세션 · 금고 칸을 지운다(이 기기는 늘 로그아웃) · 결과 = 서버 철회가 됐나.
  Future<SupabaseAuthResult> signOut({bool everywhere = false}) async {
    final String? id = _session?.userId;
    String? access = _session?.accessToken;
    if (access == null && await hasSession()) {
      // 기동 직후(메모리 세션 없음) — 철회하려면 접근 토큰이 있어야 한다.
      access = await accessToken();
    }
    SupabaseAuthFailure? cfgFail;
    final (Uri, String)? cfg = await _config((SupabaseAuthFailure f) {
      cfgFail = f;
    });
    if (access == null || cfg == null) {
      await _forget();
      return SupabaseAuthResult.failed(
        cfgFail ?? SupabaseAuthFailure.notSignedIn,
      );
    }
    final http.Response? r = await _post(
      cfg.$1.replace(
        pathSegments: const <String>['auth', 'v1', 'logout'],
        queryParameters: <String, String>{
          'scope': everywhere ? 'global' : 'local',
        },
      ),
      cfg.$2,
      bearer: access,
    );
    await _forget();
    if (r == null) {
      return const SupabaseAuthResult.failed(SupabaseAuthFailure.network);
    }
    // 204(· 200) = 철회됨 · 그 밖 = 서버 철회 실패(이 기기는 이미 로그아웃 — «모든 기기» 철회는 다시 해야 한다).
    if (r.statusCode == 204 || r.statusCode == 200) {
      return SupabaseAuthResult.ok(id ?? '');
    }
    return SupabaseAuthResult.failed(
      _httpFailure(r.statusCode, on400: SupabaseAuthFailure.badResponse),
      statusCode: r.statusCode,
    );
  }
}
