// KIS REST 핵심 — 토큰 · 유량 문 · 조회 재시도(설계 13 §8 R29 L2~L5 · M1-8).
//
// 🔴 이 클라이언트는 주문(E10)과 시세(E8d)가 **같이** 쓴다 — 앱키 하나에 [KisRateGate] 하나(유량은 앱키 단위).
// 🔴 조회 GET 의 재시도(R23 D10)와 주문 POST 의 재시도는 다르다 — 주문은 [KisRestClient.postOrder] 가 04 §3-3 v2.38 표대로만
//    다시 보낸다(유량 · 토큰 무효 = «접수 안 됨 확인»뿐 · 결과 불명은 0회 · 설계 13 §8 R37 Y2).
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
  const KisResponse(
    this.status,
    this.body,
    this.attempts, [
    this.text,
    this.trCont,
  ]);

  /// HTTP 상태.
  final int status;

  /// JSON 본문(아니면 null).
  final Map<String, Object?>? body;

  /// 보낸 횟수(재시도 포함).
  final int attempts;

  /// 🆕 본문 원문(받지 못했으면 null) — 수집 기록의 sha256 재료(설계 13 §8 R30 N6). 기록에 원문을 남기지 않는다.
  final String? text;

  /// 🆕 E10d — 응답 머리 `tr_cont`(F · M = 다음 쪽 있음 · R37 Y6).
  final String? trCont;

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

  /// 토큰 보관 키 — (환경 · 앱키 지문 · R44 E8 · X11).
  late final KisTokenKey tokenKey = KisTokenKey.of(credentials);
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
    final KisToken? t = _tokens.read(tokenKey);
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
    _tokens.write(tokenKey, fresh);
    return fresh;
  }

  /// 조회 GET — 재시도·토큰 무효 처리를 한다. 업무 거절은 그대로 돌려준다([KisResponse.ok] 로 본다).
  Future<KisResponse> get(
    String path,
    String trId,
    Map<String, String> query, {
    String trCont = '',
  }) async {
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
      String? text;
      String? cont;
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
                'tr_cont': trCont,
              },
            )
            .timeout(timeout);
        status = r.statusCode;
        body = _json(r.bodyBytes);
        text = utf8.decode(r.bodyBytes, allowMalformed: true);
        cont = r.headers['tr_cont'];
      } on TimeoutException {
        failure = '시간 초과';
      } on http.ClientException {
        failure = '연결 실패';
      } on SocketException {
        failure = '연결 실패';
      }
      final KisResponse res = KisResponse(
        status ?? 0,
        body,
        attempts,
        text,
        cont,
      );
      if (status != null &&
          !refreshed &&
          kKisTokenInvalidCodes.contains(res.msgCd)) {
        _tokens.clear(tokenKey);
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

  /// 🆕 E10d — 주문 POST(매수 · 매도 · 취소 · 04 §3-3 v2.38 · 설계 13 §8 R37 Y2). 결과는 값이다(예외 아님).
  ///
  /// 판정 순서 = 전송 예외 → 본문 JSON 여부 → 본문 코드(유량 · 토큰 무효 먼저) → HTTP 상태.
  /// 🔴 결과 불명(전송 예외 · 5xx · 200 비JSON)은 다시 보내지 않는다 — 허용 재시도(유량 1→2→4s · 토큰 1회) 중에 불명이
  ///    나와도 즉시 [KisOrderUnknown] 이다(F-14b S10). 관측점은 전송된 요청 수 — 이 함수 밖에 재시도를 두지 않는다.
  Future<KisOrderPost> postOrder(
    String path,
    String trId,
    Map<String, String> body,
  ) async {
    final Uri u = _uri(path);
    int attempts = 0;
    int rateRetries = 0;
    bool refreshed = false;
    while (true) {
      final KisToken t;
      try {
        t = await token();
      } on KisTokenError catch (e) {
        // 보내기 전이다 — 접수 안 됨이 확실하다.
        return KisOrderRefused('TOKEN', e.toString(), attempts);
      }
      await gate.pass();
      attempts++;
      calls++;
      final http.Response r;
      try {
        r = await _http
            .post(
              u,
              headers: <String, String>{
                'content-type': 'application/json; charset=utf-8',
                'authorization': 'Bearer ${t.accessToken}',
                'appkey': credentials.appKey,
                'appsecret': credentials.appSecret,
                'tr_id': trId,
                'custtype': 'P',
              },
              body: jsonEncode(body),
            )
            .timeout(timeout);
      } on TimeoutException {
        return KisOrderUnknown('시간 초과', attempts);
      } on Object {
        // 🔴 Dart `http` 는 «보내기 전 실패»와 «보낸 뒤 끊김»을 가르지 않는다 — 전부 결과 불명(02 §5-1 · 04 v2.38).
        return KisOrderUnknown('연결 예외', attempts);
      }
      final int status = r.statusCode;
      final Map<String, Object?>? b = _json(r.bodyBytes);
      if (b == null) {
        if (status == 401) {
          if (refreshed) return KisOrderRefused('HTTP_401', '토큰 무효', attempts);
          _tokens.clear(tokenKey);
          refreshed = true;
          continue;
        }
        if (status >= 400 && status < 500) {
          return KisOrderRefused('HTTP_$status', '비JSON 거절', attempts);
        }
        return KisOrderUnknown('HTTP $status 비JSON', attempts);
      }
      final KisResponse res = KisResponse(status, b, attempts);
      final String? code = res.msgCd;
      if (code != null && kKisRateCodes.contains(code)) {
        // 접수 안 됨 확인 — 재시도는 의무(FR-405 · F-14b S08 · S09).
        if (rateRetries >= kKisGetBackoff.length) {
          return KisOrderRefused(code, res.msg1 ?? '', attempts);
        }
        await _sleep(kKisGetBackoff[rateRetries++]);
        continue;
      }
      if (status == 401 || kKisTokenInvalidCodes.contains(code)) {
        if (refreshed) {
          return KisOrderRefused(code ?? 'HTTP_401', res.msg1 ?? '', attempts);
        }
        _tokens.clear(tokenKey);
        refreshed = true;
        continue;
      }
      if (status >= 500) {
        // 서버에 없는 TR 만 분명한 거절이다(07 §6-2 · §6-3) — 그 밖 5xx 는 접수 여부를 모른다(F-14b S02).
        return code == kKisNoSuchTrCode
            ? KisOrderRefused(kKisNoSuchTrCode, res.msg1 ?? '', attempts)
            : KisOrderUnknown('HTTP $status ${code ?? ''}'.trim(), attempts);
      }
      if (status >= 400) {
        return KisOrderRefused(
          code ?? 'HTTP_$status',
          res.msg1 ?? '',
          attempts,
        );
      }
      if (status == 200) {
        final String? rt = res.rtCd;
        if (rt == null) return KisOrderUnknown('rt_cd 없음', attempts);
        return rt == '0'
            ? KisOrderAccepted(res, attempts)
            : KisOrderRefused(code ?? 'RT_CD_$rt', res.msg1 ?? '', attempts);
      }
      return KisOrderUnknown('HTTP $status', attempts);
    }
  }
}

/// 서버에 없는 TR(모의 서버에 실전 TR 등 — HTTP 500 + JSON · 07 §6-2).
const String kKisNoSuchTrCode = 'EGW02006';

/// 주문 POST 결과(R37 Y2) — [attempts] = 보낸 주문 요청 수(토큰 발급 제외).
sealed class KisOrderPost {
  const KisOrderPost(this.attempts);

  /// 보낸 주문 요청 수.
  final int attempts;
}

/// 접수(HTTP 200 · `rt_cd` 0).
final class KisOrderAccepted extends KisOrderPost {
  const KisOrderAccepted(this.response, int attempts) : super(attempts);

  /// 응답(`output.ODNO` 등).
  final KisResponse response;
}

/// 분명한 거절 — 접수 안 됨이 확실하다(다시 보내지 않는다).
final class KisOrderRefused extends KisOrderPost {
  const KisOrderRefused(this.code, this.message, int attempts)
    : super(attempts);

  /// 브로커 코드(`msg_cd`) 또는 `TOKEN` · `HTTP_4xx` 등.
  final String code;

  /// 브로커 문구(키 · 토큰 · 계좌번호 없음).
  final String message;
}

/// 결과 불명 — 🔴 나갔는지 모른다(재주문 금지 · NR-2).
final class KisOrderUnknown extends KisOrderPost {
  const KisOrderUnknown(this.reason, int attempts) : super(attempts);

  /// 사유(주소 · 키 없음).
  final String reason;
}

Map<String, Object?>? _json(List<int> bytes) {
  try {
    final Object? v = jsonDecode(utf8.decode(bytes));
    return v is Map<String, Object?> ? v : null;
  } on FormatException {
    return null;
  }
}
