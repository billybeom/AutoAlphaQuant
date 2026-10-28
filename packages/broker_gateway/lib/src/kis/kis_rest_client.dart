// KIS REST 핵심 — 토큰 · 유량 문 · 조회 재시도(설계 13 §8 R29 L2~L5 · M1-8).
//
// 🔴 이 클라이언트는 주문(E10)과 시세(E8d)가 **같이** 쓴다 — 앱키 하나에 [KisRateGate] 하나(유량은 앱키 단위).
// 🔴 재시도는 조회 GET 만이다(R23 D10). 주문 POST 는 다시 보내지 않는다(02 §5-1 «재시도 금지» · E10 몫).
// 🔴 업무 거절(JSON `rt_cd ≠ 0`)은 다시 보내지 않는다 — 고칠 것은 요청이다. 토큰 무효면 새 토큰으로 1회.
// 🔴 오류 문구에는 주소·키·시크릿·계좌번호·토큰이 들어가지 않는다(코드와 서버 문구만).

import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import 'kis_environment.dart';
import 'kis_token.dart';

/// 기다리기(시험에서 바꾼다).
typedef KisSleep = Future<void> Function(Duration d);

Future<void> _realSleep(Duration d) => Future<void>.delayed(d);
DateTime _realNow() => DateTime.now().toUtc();

/// 요청 사이 최소 간격을 지키는 문 — 앱키 하나에 하나(R29 L4). 여러 호출이 겹치면 줄을 세운다.
class KisRateGate {
  KisRateGate(this.minInterval, {DateTime Function()? now, KisSleep? sleep})
    : _now = now ?? _realNow,
      _sleep = sleep ?? _realSleep;

  final Duration minInterval;
  final DateTime Function() _now;
  final KisSleep _sleep;
  DateTime? _last;
  Future<void> _tail = Future<void>.value();

  /// 차례가 오면 끝난다.
  Future<void> pass() {
    final Future<void> next = _tail.then((_) async {
      final DateTime? last = _last;
      if (last != null) {
        final Duration wait = minInterval - _now().difference(last);
        if (wait > Duration.zero) await _sleep(wait);
      }
      _last = _now();
    });
    _tail = next;
    return next;
  }
}

/// 조회 재시도 간격(R23 D10 — 1 → 2 → 4초 · 최대 3회).
const List<Duration> kKisGetBackoff = <Duration>[
  Duration(seconds: 1),
  Duration(seconds: 2),
  Duration(seconds: 4),
];

/// 유량 초과 응답 코드(02 §5-1 · `03_실행/01` §1-1).
const Set<String> kKisRateCodes = <String>{'EGW00201', 'EGW00215'};

/// 토큰 무효 응답 코드 — 🟡 실측 전(02 §5-1 «토큰 만료 = 재발급 후 1회 재시도»).
const Set<String> kKisTokenInvalidCodes = <String>{'EGW00121', 'EGW00123'};

/// 토큰 발급 1분 1회 제한 코드(체크리스트 §5-1 6단계).
const String kKisTokenRateCode = 'EGW00133';

/// 응답 하나.
class KisResponse {
  const KisResponse(this.status, this.body, this.attempts);

  /// HTTP 상태.
  final int status;

  /// JSON 본문(아니면 null).
  final Map<String, Object?>? body;

  /// 보낸 횟수(재시도 포함).
  final int attempts;

  String? _s(String k) => body?[k] is String ? body![k]! as String : null;

  /// `rt_cd` · `msg_cd` · `msg1`.
  String? get rtCd => _s('rt_cd');
  String? get msgCd => _s('msg_cd');
  String? get msg1 => _s('msg1')?.trim();

  /// 정상(HTTP 200 · `rt_cd` = 0).
  bool get ok => status == 200 && rtCd == '0';
}

/// 토큰을 받지 못했다.
class KisTokenError implements Exception {
  const KisTokenError(this.status, this.errorCode, this.description);

  final int? status;
  final String? errorCode, description;

  /// 1분 1회 제한에 걸렸나(다시 보내지 말고 1분 뒤).
  bool get rateLimited => errorCode == kKisTokenRateCode;

  @override
  String toString() =>
      'KisTokenError: HTTP ${status ?? '-'} ${errorCode ?? ''} ${description ?? ''}'
          .trim();
}

/// 원천이 응답하지 않는다(재시도를 다 썼다) — 수집은 `DATA_SOURCE_DOWN` 쪽(R23 D10).
class KisUnavailable implements Exception {
  const KisUnavailable(this.reason, this.attempts);

  final String reason;
  final int attempts;

  @override
  String toString() => 'KisUnavailable: $reason(시도 $attempts)';
}

/// KIS REST 클라이언트(조회 · 토큰).
class KisRestClient {
  KisRestClient(
    this._http,
    this.credentials, {
    required this.environment,
    KisTokenStore? tokens,
    KisRateGate? gate,
    DateTime Function()? now,
    KisSleep? sleep,
    this.timeout = const Duration(seconds: 10),
  }) : _tokens = tokens ?? MemoryKisTokenStore(),
       _now = now ?? _realNow,
       _sleep = sleep ?? _realSleep,
       gate =
           gate ??
           KisRateGate(environment.minInterval, now: now, sleep: sleep) {
    if (credentials.environment != environment) {
      throw KisGuardError(
        '키 세트(${credentials.environment.name})와 접속 환경(${environment.name})이 다르다',
      );
    }
  }

  final http.Client _http;

  /// 키 세트 · 접속 환경(둘이 같아야 만들어진다).
  final KisCredentials credentials;
  final KisEnvironment environment;

  /// 유량 문(주문과 나눠 쓴다).
  final KisRateGate gate;

  /// 요청 하나의 제한 시간(R23 D10).
  final Duration timeout;

  final KisTokenStore _tokens;
  final DateTime Function() _now;
  final KisSleep _sleep;

  /// 보낸 요청 수(토큰 발급 포함 · 재시도 포함).
  int calls = 0;

  Uri _uri(String path, [Map<String, String>? query]) {
    final Uri u = environment.uri(path, query);
    if (u.host != environment.host || u.port != environment.port) {
      throw const KisGuardError('환경 밖 호스트로 가는 요청을 막았다');
    }
    return u;
  }

  /// 쓸 수 있는 토큰(보관된 것이 만료 5분 전이 아니면 그대로 · 아니면 새로).
  Future<KisToken> token() async {
    final KisToken? t = _tokens.read(environment);
    if (t != null && t.usableAt(_now())) return t;
    await gate.pass();
    calls++;
    final http.Response r;
    try {
      r = await _http
          .post(
            _uri('/oauth2/tokenP'),
            headers: <String, String>{
              'content-type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(<String, String>{
              'grant_type': 'client_credentials',
              'appkey': credentials.appKey,
              'appsecret': credentials.appSecret,
            }),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const KisTokenError(null, null, '시간 초과');
    } on http.ClientException {
      throw const KisTokenError(null, null, '연결 실패');
    } on SocketException {
      throw const KisTokenError(null, null, '연결 실패');
    }
    final Map<String, Object?>? b = _json(r.bodyBytes);
    final Object? access = b?['access_token'];
    if (r.statusCode != 200 || access is! String || access.isEmpty) {
      throw KisTokenError(
        r.statusCode,
        b?['error_code'] as String?,
        b?['error_description'] as String?,
      );
    }
    final int seconds = switch (b?['expires_in']) {
      final int n => n,
      final String s => int.tryParse(s) ?? 86400,
      _ => 86400,
    };
    final KisToken fresh = KisToken(
      access,
      _now().add(Duration(seconds: seconds)),
    );
    _tokens.write(environment, fresh);
    return fresh;
  }

  /// 조회 GET — 재시도·토큰 무효 처리를 한다. 업무 거절은 그대로 돌려준다([KisResponse.ok] 로 본다).
  Future<KisResponse> get(
    String path,
    String trId,
    Map<String, String> query,
  ) async {
    final Uri u = _uri(path, query);
    int attempts = 0;
    bool refreshed = false;
    while (true) {
      String? failure;
      final KisToken t = await token();
      await gate.pass();
      attempts++;
      calls++;
      int? status;
      Map<String, Object?>? body;
      try {
        final http.Response r = await _http
            .get(
              u,
              headers: <String, String>{
                'content-type': 'application/json; charset=utf-8',
                'authorization': 'Bearer ${t.accessToken}',
                'appkey': credentials.appKey,
                'appsecret': credentials.appSecret,
                'tr_id': trId,
                'custtype': 'P',
                'tr_cont': '',
              },
            )
            .timeout(timeout);
        status = r.statusCode;
        body = _json(r.bodyBytes);
      } on TimeoutException {
        failure = '시간 초과';
      } on http.ClientException {
        failure = '연결 실패';
      } on SocketException {
        failure = '연결 실패';
      }
      final KisResponse res = KisResponse(status ?? 0, body, attempts);
      if (status != null &&
          !refreshed &&
          kKisTokenInvalidCodes.contains(res.msgCd)) {
        _tokens.clear(environment);
        refreshed = true;
        continue;
      }
      final bool again =
          status == null ||
          status == 429 ||
          status == 502 ||
          status == 503 ||
          status == 504 ||
          (status == 500 && body == null) ||
          kKisRateCodes.contains(res.msgCd);
      if (!again) return res;
      if (attempts > kKisGetBackoff.length) {
        throw KisUnavailable(
          failure ?? 'HTTP $status ${res.msgCd ?? ''}'.trim(),
          attempts,
        );
      }
      await _sleep(kKisGetBackoff[attempts - 1]);
    }
  }
}

Map<String, Object?>? _json(List<int> bytes) {
  try {
    final Object? v = jsonDecode(utf8.decode(bytes));
    return v is Map<String, Object?> ? v : null;
  } on FormatException {
    return null;
  }
}
