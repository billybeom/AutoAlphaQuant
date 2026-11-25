// 🆕 E11m-a — 명령 표 당김 클라이언트(설계 13 §8 R274 · R272 Y5 · 계약 v1.41 §50 `CommandReadRpcNames.open` ·
// `CommandReadRpcParams.limit` · `CommandOpenColumns` · 본문 = `sql/supabase_command_pairing_rpc.sql` `command_open`).
//
// 🔵 RPC = `POST /rest/v1/rpc/command_open`(공개 키 `apikey` + `Authorization: Bearer <접근 토큰>` · 본문 = `{p_limit}`) ·
//    반환 = `command_queue` 행 배열(security invoker · RLS = 부른 사용자의 ACTIVE 기기가 그 명령 소유자의 기기 · 종단 ack 없는 것 ·
//    킬스위치 먼저 → `requested_at`).
// 🔴 리스 판정은 서버가 하지 않는다 — 부르는 쪽(소비 일)이 리스 원격 확인을 통과한 뒤에만 부른다(계약 dartdoc · 소비 주체 = 하나).
// 🔴 읽기라 시크릿 관문 0(보내는 본문 = 상한 숫자 하나) · 🔴 토큰 · 주소 · 키 · 행 값은 어떤 문자열에도 나오지 않는다.

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart' show SecretVault;
import 'package:domain_contracts/domain_contracts.dart'
    show CommandReadLimits, CommandReadRpcNames, CommandReadRpcParams;
import 'package:http/http.dart' as http;

import 'supabase_auth.dart';
import 'supabase_server_time.dart';

/// command_open 이 행을 받지 못한 까닭.
enum CommandOpenFailure {
  /// 연결 칸 없음 · 꼴 아님 · 금고 실패.
  config,

  /// 로그인 세션 없음 · 잃음.
  notSignedIn,

  /// 401 · 403(토큰을 새로 받아 한 번 더 해도).
  unauthorized,

  /// 서버 오류(5xx).
  server,

  /// 그 밖의 HTTP · 응답 꼴(함수 없음 = 404 · 부트스트랩 옛 판 포함).
  badResponse,

  /// 망 · 시간 초과.
  network,
}

/// 당김 한 번의 결과 — 🔴 토큰 없음 · 행 값은 [rows] 에만(기록 금지).
class CommandOpenResult {
  /// 받았다.
  const CommandOpenResult.rows(List<Map<String, Object?>> this.rows)
    : failure = null,
      statusCode = null;

  /// 받지 못했다.
  const CommandOpenResult.failed(
    CommandOpenFailure this.failure, {
    this.statusCode,
  }) : rows = null;

  /// 행(받았을 때).
  final List<Map<String, Object?>>? rows;

  /// 받지 못한 까닭.
  final CommandOpenFailure? failure;

  /// HTTP 상태(있을 때).
  final int? statusCode;

  /// 받았다.
  bool get ok => failure == null;

  @override
  String toString() => ok
      ? 'CommandOpenResult(${rows!.length}행)'
      : 'CommandOpenResult.failed(${failure!.name}'
            '${statusCode == null ? '' : ' · $statusCode'})';
}

/// 🆕 명령 당김 포트(소비 일이 HTTP 없이 시험되게 · 구현 = [SupabaseCommandOpen]).
abstract interface class CommandOpenReader {
  /// 종단 ack 없는 명령을 [limit] 행까지.
  Future<CommandOpenResult> open({int limit = CommandReadLimits.openMax});
}

/// 🆕 명령 표 당김 클라이언트(계약 이름 · 인자 그대로).
class SupabaseCommandOpen implements CommandOpenReader {
  /// 만든다 — 연결 칸 = [vault] · 접근 토큰 = [auth].
  SupabaseCommandOpen(
    this._http,
    this._vault,
    this._auth, {
    this.timeout = const Duration(seconds: 20),
  });

  final http.Client _http;
  final SecretVault _vault;
  final SupabaseAuth _auth;

  /// 한 번의 상한.
  final Duration timeout;

  @override
  Future<CommandOpenResult> open({
    int limit = CommandReadLimits.openMax,
  }) async {
    final (Uri, String)? cfg = await _config();
    if (cfg == null) {
      return const CommandOpenResult.failed(CommandOpenFailure.config);
    }
    final Uri uri = cfg.$1.replace(
      pathSegments: <String>['rest', 'v1', 'rpc', CommandReadRpcNames.open],
    );
    final String body = jsonEncode(<String, Object?>{
      CommandReadRpcParams.limit: limit,
    });
    String? token = await _auth.accessToken();
    if (token == null) {
      return const CommandOpenResult.failed(CommandOpenFailure.notSignedIn);
    }
    http.Response? r = await _post(uri, cfg.$2, token, body);
    if (r != null && (r.statusCode == 401 || r.statusCode == 403)) {
      token = await _auth.accessToken(forceRefresh: true);
      if (token == null) {
        return const CommandOpenResult.failed(CommandOpenFailure.notSignedIn);
      }
      r = await _post(uri, cfg.$2, token, body);
    }
    if (r == null) {
      return const CommandOpenResult.failed(CommandOpenFailure.network);
    }
    final int c = r.statusCode;
    if (c == 401 || c == 403) {
      return CommandOpenResult.failed(
        CommandOpenFailure.unauthorized,
        statusCode: c,
      );
    }
    if (c >= 500) {
      return CommandOpenResult.failed(CommandOpenFailure.server, statusCode: c);
    }
    if (c != 200) {
      return CommandOpenResult.failed(
        CommandOpenFailure.badResponse,
        statusCode: c,
      );
    }
    final List<Map<String, Object?>>? rows = _parse(r.body);
    return rows == null
        ? CommandOpenResult.failed(
            CommandOpenFailure.badResponse,
            statusCode: c,
          )
        : CommandOpenResult.rows(rows);
  }

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

  Future<http.Response?> _post(
    Uri uri,
    String key,
    String token,
    String body,
  ) async {
    try {
      return await _http
          .post(
            uri,
            headers: <String, String>{
              'apikey': key,
              'authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
            body: body,
          )
          .timeout(timeout);
    } on Exception {
      return null;
    }
  }

  /// 배열(행마다 객체) → 행 — 꼴이 아니면 null(한 행이라도 객체가 아니면 전부 버린다).
  static List<Map<String, Object?>>? _parse(String text) {
    Object? body;
    try {
      body = jsonDecode(text);
    } on FormatException {
      return null;
    }
    if (body is! List) return null;
    final List<Map<String, Object?>> out = <Map<String, Object?>>[];
    for (final Object? row in body) {
      if (row is! Map<String, Object?>) return null;
      out.add(row);
    }
    return out;
  }
}
