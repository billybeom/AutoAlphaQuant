// 시세·지표 GET — 타임아웃 · 재시도 · 본문 sha256(설계 13 §8 R23 D10 · R26 H6 · E8c).
//
// 🔴 시세 GET 은 재시도해도 안전하다(재시도 금지는 주문 한정 · 02 §5-1). 타임아웃 10s · 백오프 1→2→4s(최대 3회 더 ·
//    06 M1-8 꼴). 다시 해 볼 만한 실패만 다시 한다: 타임아웃 · 연결 실패 · HTTP 429 · 5xx. 그 밖의 4xx 는 바로 실패
//    (요청이 틀렸다 — 같은 요청을 되풀이해도 같다).
// 🔴 오류 문장에 주소를 넣지 않는다 — FRED 주소에는 `api_key` 가 들어간다([HttpFetchError.reason] = 엔진 문장).

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// 기다리기(시험은 바로 돌아오는 것을 넣는다).
typedef FetchSleep = Future<void> Function(Duration);

/// 재시도 규칙.
class HttpRetryPolicy {
  const HttpRetryPolicy({
    this.timeout = const Duration(seconds: 10),
    this.backoff = const <Duration>[
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  });

  /// 시도 한 번의 상한.
  final Duration timeout;

  /// 재시도 전 기다림(길이 = 최대 재시도 수).
  final List<Duration> backoff;
}

/// 받은 본문.
class HttpBody {
  const HttpBody({
    required this.text,
    required this.sha256Hex,
    required this.attempts,
  });

  final String text;

  /// 본문 바이트의 sha256(`fetch_log.body_sha256`).
  final String sha256Hex;

  /// 시도 수(1 = 첫 시도에 받음).
  final int attempts;
}

/// 끝내 받지 못함.
class HttpFetchError implements Exception {
  const HttpFetchError(this.reason, {required this.attempts});

  /// 엔진 문장(주소·키 없음) — 예 «HTTP 503» · «타임아웃 10s».
  final String reason;
  final int attempts;

  @override
  String toString() => 'HttpFetchError($reason · 시도 $attempts)';
}

/// [uri] 를 GET 한다 — 2xx 본문(UTF-8)을 돌려주거나 [HttpFetchError].
Future<HttpBody> getWithRetry(
  http.Client client,
  Uri uri, {
  Map<String, String>? headers,
  HttpRetryPolicy policy = const HttpRetryPolicy(),
  FetchSleep? sleep,
}) async {
  String reason = '';
  for (int attempt = 1; ; attempt++) {
    bool retryable;
    try {
      final http.Response r = await client
          .get(uri, headers: headers)
          .timeout(policy.timeout);
      if (r.statusCode >= 200 && r.statusCode < 300) {
        try {
          return HttpBody(
            text: utf8.decode(r.bodyBytes),
            sha256Hex: sha256.convert(r.bodyBytes).toString(),
            attempts: attempt,
          );
        } on FormatException {
          throw HttpFetchError('본문이 UTF-8 이 아니다', attempts: attempt);
        }
      }
      reason = 'HTTP ${r.statusCode}';
      retryable = r.statusCode == 429 || r.statusCode >= 500;
    } on TimeoutException {
      reason = '타임아웃 ${policy.timeout.inSeconds}s';
      retryable = true;
    } on http.ClientException {
      reason = '연결 실패';
      retryable = true;
    }
    if (!retryable || attempt > policy.backoff.length) {
      throw HttpFetchError(reason, attempts: attempt);
    }
    await (sleep ?? _realSleep)(policy.backoff[attempt - 1]);
  }
}

Future<void> _realSleep(Duration d) => Future<void>.delayed(d);
