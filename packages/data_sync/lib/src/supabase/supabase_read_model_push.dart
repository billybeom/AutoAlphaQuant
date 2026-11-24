// 🆕 E11l2b — 읽기 모델 push 클라이언트(설계 13 §8 R256 · 01 §8 미결 222 ⓒ ⓔ · 계약 v1.38 §47 `ReadModelPushRpc*` ·
// `ReadModelPushResultCodes` · 본문 = `sql/supabase_read_model_push_rpc.sql`(E11l2a · R254)).
//
// 🔵 RPC = `POST /rest/v1/rpc/rm_push`(공개 키 `apikey` + `Authorization: Bearer <접근 토큰>` · 본문 = 계약 인자 4) ·
//    반환 = 한 행(`code` · `epoch` · `accepted` · `skipped` — 배열 한 칸이어도 · 객체여도 받는다).
// 🔴 거부 = 서버가 돌려준 `code` 뿐(리스 공용 2 ∪ 고유 2) — HTTP 상태 · 오류 문장으로 코드를 짓지 않는다(리스 클라이언트와 같은 규칙).
// 🔴 **시크릿 관문 = 이 클라이언트 하나**(규칙 5조 ⑤ · R44 E7 · SAF-904) — 보낼 본문 전문을 금고 값 전부 + 패턴으로 먼저 훑고,
//    걸리면 망에 나가지 않는다(`secretBlocked` · 찾은 수만 · 값 · 발췌 0). 다시 시도하지 않는다 — P1 알림 = 부르는 쪽(E11l2c).
// 🔴 토큰 · 주소 · 키 · 행 값은 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다.

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show SecretVault, readAllSecretValues;
import 'package:domain_contracts/domain_contracts.dart'
    show
        LeaseRpcResultCodes,
        ReadModelPushResultCodes,
        ReadModelPushRpcColumns,
        ReadModelPushRpcNames,
        ReadModelPushRpcParams,
        ReadModelTable;
import 'package:http/http.dart' as http;

import '../security/secret_scan.dart' show SecretScanResult, scanForSecrets;
import 'supabase_auth.dart';
import 'supabase_server_time.dart';

/// push 가 서버 답을 받지 못한 까닭(서버 거부가 아닌 것).
enum ReadModelPushFailure {
  /// 보낼 본문에 시크릿이 보였다 — 망에 나가지 않았다.
  secretBlocked,

  /// 연결 칸 없음 · 꼴 아님 · 금고 실패.
  config,

  /// 로그인 세션 없음 · 잃음.
  notSignedIn,

  /// 401 · 403(토큰을 새로 받아 한 번 더 해도).
  unauthorized,

  /// 서버 오류(5xx).
  server,

  /// 그 밖의 HTTP · 응답 꼴 · 모르는 코드.
  badResponse,

  /// 망 · 시간 초과.
  network,
}

/// push 한 번의 결과 — 🔴 토큰 · 행 값 없음.
class ReadModelPushResult {
  /// 서버가 답했다(`code` = null 이면 성공).
  const ReadModelPushResult.answered({
    required this.code,
    required this.epoch,
    required this.accepted,
    required this.skipped,
  }) : failure = null,
       statusCode = null,
       secretFindings = 0;

  /// 답을 받지 못했다.
  const ReadModelPushResult.failed(
    ReadModelPushFailure this.failure, {
    this.statusCode,
    this.secretFindings = 0,
  }) : code = null,
       epoch = null,
       accepted = 0,
       skipped = 0;

  /// 거부 코드(리스 공용 2 ∪ `ReadModelPushResultCodes`) · 성공 = null.
  final String? code;

  /// 서버가 본 지금 리스 epoch(거부 · 실패면 null 일 수 있다).
  final int? epoch;

  /// 넣거나 바꾼 행 수.
  final int accepted;

  /// `row_version` 이 크지 않아 건너뛴 행 수.
  final int skipped;

  /// 답을 받지 못한 까닭.
  final ReadModelPushFailure? failure;

  /// HTTP 상태(있을 때).
  final int? statusCode;

  /// 시크릿 관문이 찾은 수(값 0).
  final int secretFindings;

  /// 서버가 받아들였다.
  bool get ok => failure == null && code == null;

  @override
  String toString() => failure != null
      ? 'ReadModelPushResult.failed(${failure!.name}'
            '${statusCode == null ? '' : ' · $statusCode'}'
            '${secretFindings == 0 ? '' : ' · 시크릿 $secretFindings'})'
      : 'ReadModelPushResult(${code ?? 'OK'} · epoch $epoch · $accepted/$skipped)';
}

/// 서버가 돌려줄 수 있는 거부 코드 전부.
final Set<String> kReadModelPushCodes = <String>{
  LeaseRpcResultCodes.lost,
  LeaseRpcResultCodes.deviceNotEligible,
  ...ReadModelPushResultCodes.values,
};

/// 🆕 E11l2c(R263) — push 포트(push 일이 HTTP 없이 시험되게 · 구현 = [SupabaseReadModelPush]).
abstract interface class ReadModelPusher {
  /// [table] 에 [rows] 를 올린다.
  Future<ReadModelPushResult> push({
    required String deviceId,
    required int epoch,
    required ReadModelTable table,
    required List<Map<String, Object?>> rows,
  });
}

/// 🆕 읽기 모델 push 클라이언트(계약 표 이름 · 인자 · 반환 칸 그대로 · 시크릿 관문 포함).
class SupabaseReadModelPush implements ReadModelPusher {
  /// 만든다 — 연결 칸 · 시크릿 정확 값 = [vault] · 접근 토큰 = [auth].
  SupabaseReadModelPush(
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

  /// [table] 에 [rows](`readModelRow` 출력)를 올린다 — 이 기기 [deviceId] · 쥔 리스 [epoch].
  @override
  Future<ReadModelPushResult> push({
    required String deviceId,
    required int epoch,
    required ReadModelTable table,
    required List<Map<String, Object?>> rows,
  }) async {
    final Map<String, Object?> args = <String, Object?>{
      ReadModelPushRpcParams.deviceId: deviceId,
      ReadModelPushRpcParams.epoch: epoch,
      ReadModelPushRpcParams.table: table.name,
      ReadModelPushRpcParams.rows: rows,
    };
    final String body = jsonEncode(args);
    final SecretScanResult scan;
    try {
      scan = scanForSecrets(
        body,
        exactValues: await readAllSecretValues(_vault),
        source: 'rm_push:${table.name}',
      );
    } on Object {
      return const ReadModelPushResult.failed(ReadModelPushFailure.config);
    }
    if (scan.blocked) {
      return ReadModelPushResult.failed(
        ReadModelPushFailure.secretBlocked,
        secretFindings: scan.findings.length,
      );
    }
    final (Uri, String)? cfg = await _config();
    if (cfg == null) {
      return const ReadModelPushResult.failed(ReadModelPushFailure.config);
    }
    final Uri uri = cfg.$1.replace(
      pathSegments: <String>['rest', 'v1', 'rpc', ReadModelPushRpcNames.push],
    );
    String? token = await _auth.accessToken();
    if (token == null) {
      return const ReadModelPushResult.failed(ReadModelPushFailure.notSignedIn);
    }
    http.Response? r = await _post(uri, cfg.$2, token, body);
    if (r != null && (r.statusCode == 401 || r.statusCode == 403)) {
      token = await _auth.accessToken(forceRefresh: true);
      if (token == null) {
        return const ReadModelPushResult.failed(
          ReadModelPushFailure.notSignedIn,
        );
      }
      r = await _post(uri, cfg.$2, token, body);
    }
    if (r == null) {
      return const ReadModelPushResult.failed(ReadModelPushFailure.network);
    }
    final int c = r.statusCode;
    if (c == 401 || c == 403) {
      return ReadModelPushResult.failed(
        ReadModelPushFailure.unauthorized,
        statusCode: c,
      );
    }
    if (c >= 500) {
      return ReadModelPushResult.failed(
        ReadModelPushFailure.server,
        statusCode: c,
      );
    }
    if (c != 200) {
      return ReadModelPushResult.failed(
        ReadModelPushFailure.badResponse,
        statusCode: c,
      );
    }
    return _parse(r) ??
        ReadModelPushResult.failed(
          ReadModelPushFailure.badResponse,
          statusCode: c,
        );
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

  /// 한 행(배열 한 칸 · 객체) → 결과 — 꼴 · 모르는 코드 = null.
  static ReadModelPushResult? _parse(http.Response r) {
    Object? body;
    try {
      body = jsonDecode(r.body);
    } on FormatException {
      return null;
    }
    if (body is List) {
      if (body.length != 1) return null;
      body = body.single;
    }
    if (body is! Map<String, Object?>) return null;
    final Object? code = body[ReadModelPushRpcColumns.code];
    final Object? epoch = body[ReadModelPushRpcColumns.epoch];
    final Object? accepted = body[ReadModelPushRpcColumns.accepted];
    final Object? skipped = body[ReadModelPushRpcColumns.skipped];
    if (code != null &&
        (code is! String || !kReadModelPushCodes.contains(code))) {
      return null;
    }
    if (epoch != null && epoch is! int) return null;
    if (accepted is! int || skipped is! int || accepted < 0 || skipped < 0) {
      return null;
    }
    // 성공 = epoch 가 있어야 한다 · 거부 = 0 · 0.
    if (code == null && epoch == null) return null;
    if (code != null && (accepted != 0 || skipped != 0)) return null;
    return ReadModelPushResult.answered(
      code: code as String?,
      epoch: epoch as int?,
      accepted: accepted,
      skipped: skipped,
    );
  }
}
