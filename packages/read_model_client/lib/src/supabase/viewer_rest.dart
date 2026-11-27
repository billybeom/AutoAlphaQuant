// 🆕 R277(설계 13 §8 R277 VC1 · VC2 · 01 §1-1 «Supabase 순수 Dart 클라이언트(지도 D2 · E11l2 · E11m 때)») — 뷰어 PostgREST 얇은 호출기.
//
// 🔵 꼴 = data_sync `SupabaseCommandOpen` · `SupabaseDeviceLedger` 와 같다 — `http` 하나 · 머리 = 공개 키 `apikey` +
//    `Authorization: Bearer <접근 토큰>` · 401 · 403 = 토큰을 새로 받아 **한 번만** 더 · 그 밖 상태 = 부르는 쪽이 가른다.
// 🔴 이 호출기는 상태 코드로 계약 코드를 짓지 않는다(01 §50 K365) — 받은 상태 · 본문을 그대로 돌려준다.
// 🔴 토큰 · 주소 · 키 · 본문(행 값)은 어떤 문자열(toString · 오류)에도 나오지 않는다.
// 🔴 실 프로젝트 호출 = 조립 앱이 실제 `http.Client` 를 넣을 때뿐 — 시험 = `MockClient`(가짜 HTTP).

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'viewer_session.dart';

/// 서버에 닿지 못한 까닭.
enum ViewerRestFailure {
  /// 주소 · 공개 키 없음(페어링 전 · 보관 실패).
  notPaired,

  /// 접근 토큰 없음(세션 없음 · 새로고침 실패).
  notSignedIn,

  /// 망 · 시간 초과.
  network,
}

/// 한 번의 호출 결과 — 🔴 본문 = 행 값(기록 금지 · [toString] 에 0).
final class ViewerRestResult {
  /// 응답을 받았다.
  const ViewerRestResult.response(int this.statusCode, String this.body)
    : failure = null;

  /// 서버에 닿지 못했다.
  const ViewerRestResult.failed(ViewerRestFailure this.failure)
    : statusCode = null,
      body = null;

  /// HTTP 상태(응답을 받았을 때).
  final int? statusCode;

  /// 본문(응답을 받았을 때).
  final String? body;

  /// 닿지 못한 까닭.
  final ViewerRestFailure? failure;

  /// 본문 = 객체 배열이면 행 · 아니면 null(한 행이라도 객체가 아니면 전부 버린다).
  List<Map<String, Object?>>? get rows {
    final String? text = body;
    if (text == null) return null;
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      return null;
    }
    if (decoded is! List) return null;
    final List<Map<String, Object?>> out = <Map<String, Object?>>[];
    for (final Object? row in decoded) {
      if (row is! Map<String, Object?>) return null;
      out.add(row);
    }
    return out;
  }

  @override
  String toString() => failure != null
      ? 'ViewerRestResult.failed(${failure!.name})'
      : 'ViewerRestResult($statusCode)';
}

/// 뷰어 PostgREST 호출기.
final class ViewerRest {
  /// 만든다 — [http] = 조립 앱이 넣는 클라이언트(시험 = `MockClient`) · [session] = 페어링 세션.
  ViewerRest(
    this._http,
    this._session, {
    this.timeout = const Duration(seconds: 20),
  });

  final http.Client _http;
  final ViewerSession _session;

  /// 이 호출기의 세션(기기 id 를 읽는 창구가 같은 세션을 쓰게).
  ViewerSession get session => _session;

  /// 한 번의 상한.
  final Duration timeout;

  /// `GET /rest/v1/<table>?<query>` — [query] = PostgREST 꼴(`col=eq.값` · `select=a,b`).
  Future<ViewerRestResult> select(String table, Map<String, String> query) =>
      _send(<String>['rest', 'v1', table], query: query);

  /// `POST /rest/v1/<table>` 한 행 넣기 — `Prefer: return=representation`(넣은 행을 돌려받는다 · RLS select 정책이 통과시킬 때).
  Future<ViewerRestResult> insert(String table, Map<String, Object?> row) =>
      _send(
        <String>['rest', 'v1', table],
        body: jsonEncode(row),
        prefer: 'return=representation',
      );

  /// `POST /rest/v1/rpc/<name>` — 인자 = 계약 이름.
  Future<ViewerRestResult> rpc(String name, Map<String, Object?> args) =>
      _send(<String>['rest', 'v1', 'rpc', name], body: jsonEncode(args));

  Future<ViewerRestResult> _send(
    List<String> path, {
    Map<String, String>? query,
    String? body,
    String? prefer,
  }) async {
    final ViewerEndpoint? ep;
    try {
      ep = await _session.endpoint();
    } on Object {
      return const ViewerRestResult.failed(ViewerRestFailure.notPaired);
    }
    if (ep == null) {
      return const ViewerRestResult.failed(ViewerRestFailure.notPaired);
    }
    final Uri uri = ep.base.replace(
      pathSegments: path,
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    String? token = await _token();
    if (token == null) {
      return const ViewerRestResult.failed(ViewerRestFailure.notSignedIn);
    }
    http.Response? r = await _once(uri, ep.publishableKey, token, body, prefer);
    if (r != null && (r.statusCode == 401 || r.statusCode == 403)) {
      token = await _token(forceRefresh: true);
      if (token == null) {
        return const ViewerRestResult.failed(ViewerRestFailure.notSignedIn);
      }
      r = await _once(uri, ep.publishableKey, token, body, prefer);
    }
    if (r == null) {
      return const ViewerRestResult.failed(ViewerRestFailure.network);
    }
    // 🔴 JSON = 늘 UTF-8(RFC 8259 §8.1) — `Response.body` 는 머리에 charset 이 없으면 latin1 로 풀어 한글 엔진 글자가 깨진다(시험 실측).
    String text;
    try {
      text = utf8.decode(r.bodyBytes);
    } on FormatException {
      text = ''; // UTF-8 아님 = 꼴 아님(행 null).
    }
    return ViewerRestResult.response(r.statusCode, text);
  }

  Future<String?> _token({bool forceRefresh = false}) async {
    try {
      final String? t = await _session.accessToken(forceRefresh: forceRefresh);
      return t == null || t.isEmpty ? null : t;
    } on Object {
      return null;
    }
  }

  Future<http.Response?> _once(
    Uri uri,
    String key,
    String token,
    String? body,
    String? prefer,
  ) async {
    final Map<String, String> headers = <String, String>{
      'apikey': key,
      'authorization': 'Bearer $token',
      'content-type': 'application/json',
      'prefer': ?prefer,
    };
    try {
      return await (body == null
              ? _http.get(uri, headers: headers)
              : _http.post(uri, headers: headers, body: body))
          .timeout(timeout);
    } on Exception {
      return null;
    }
  }
}
