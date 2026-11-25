// 🆕 미결 244 ⓐ — 운영 폰 공유 표 push 클라이언트(설계 13 §8 R271 O1 · 01 §8 미결 244 · 계약 v1.40 §49 `OpsPushRpc*` ·
// `OpsPushTables` · `OpsPushResultCodes` · 본문 = `sql/supabase_ops_push_rpc.sql`(R270)).
//
// 🔵 RPC = `POST /rest/v1/rpc/op_push`(공개 키 `apikey` + `Authorization: Bearer <접근 토큰>` · 본문 = 계약 인자 4) ·
//    반환 = 한 행(`code` · `epoch` · `accepted` · `skipped` — 배열 한 칸이어도 · 객체여도 받는다).
// 🔵 `rm_push` 클라이언트(`SupabaseReadModelPush` · R256)와 같은 결 — 표 무리만 다르다(`OpsPushTables` 다섯 · 거부 `OPS_PUSH_*`).
//    🔵 E11m(명령 ack 쓰기 · `command_ack`)이 이 클라이언트 · [OpsPusher] 를 그대로 쓴다.
// 🔴 거부 = 서버가 돌려준 `code` 뿐(리스 공용 2 ∪ `OpsPushResultCodes` 2) — HTTP 상태 · 오류 문장으로 코드를 짓지 않는다(K357).
// 🔴 시크릿 관문(규칙 5조 ⑤ · R44 E7 · SAF-904) — 보낼 본문 전문을 금고 값 전부 + 패턴으로 먼저 훑고, 걸리면 망에 나가지 않는다
//    (`secretBlocked` · 찾은 수만 · 값 · 발췌 0). 다시 시도하지 않는다.
// 🔴 표 = [OpsPushTables.all] 밖이면 망 0 · [ArgumentError](부르는 쪽 결함 — 서버 거부 `OPS_PUSH_TABLE_UNKNOWN` 과 다른 축).
// 🔴 토큰 · 주소 · 키 · 행 값은 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다.

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show SecretVault, readAllSecretValues;
import 'package:domain_contracts/domain_contracts.dart'
    show
        LeaseRpcResultCodes,
        OpsPushResultCodes,
        OpsPushRpcColumns,
        OpsPushRpcNames,
        OpsPushRpcParams,
        OpsPushTables;
import 'package:http/http.dart' as http;

import '../security/secret_scan.dart' show SecretScanResult, scanForSecrets;
import 'supabase_auth.dart';
import 'supabase_server_time.dart';

/// op_push 가 서버 답을 받지 못한 까닭(서버 거부가 아닌 것).
enum OpsPushFailure {
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

/// op_push 한 번의 결과 — 🔴 토큰 · 행 값 없음.
class OpsPushResult {
  /// 서버가 답했다(`code` = null 이면 성공).
  const OpsPushResult.answered({
    required this.code,
    required this.epoch,
    required this.accepted,
    required this.skipped,
  }) : failure = null,
       statusCode = null,
       secretFindings = 0;

  /// 답을 받지 못했다.
  const OpsPushResult.failed(
    OpsPushFailure this.failure, {
    this.statusCode,
    this.secretFindings = 0,
  }) : code = null,
       epoch = null,
       accepted = 0,
       skipped = 0;

  /// 거부 코드(리스 공용 2 ∪ `OpsPushResultCodes`) · 성공 = null.
  final String? code;

  /// 서버가 본 지금 리스 epoch(거부 · 실패면 null 일 수 있다).
  final int? epoch;

  /// 넣거나 바꾼 행 수.
  final int accepted;

  /// 건너뛴 행 수(`command_ack` 같은 `ack_id` · `planned_work_mirror` `row_version` 이 크지 않음).
  final int skipped;

  /// 답을 받지 못한 까닭.
  final OpsPushFailure? failure;

  /// HTTP 상태(있을 때).
  final int? statusCode;

  /// 시크릿 관문이 찾은 수(값 0).
  final int secretFindings;

  /// 서버가 받아들였다.
  bool get ok => failure == null && code == null;

  @override
  String toString() => failure != null
      ? 'OpsPushResult.failed(${failure!.name}'
            '${statusCode == null ? '' : ' · $statusCode'}'
            '${secretFindings == 0 ? '' : ' · 시크릿 $secretFindings'})'
      : 'OpsPushResult(${code ?? 'OK'} · epoch $epoch · $accepted/$skipped)';
}

/// 서버가 돌려줄 수 있는 거부 코드 전부(리스 공용 2 ∪ 고유 2).
final Set<String> kOpsPushCodes = <String>{
  LeaseRpcResultCodes.lost,
  LeaseRpcResultCodes.deviceNotEligible,
  ...OpsPushResultCodes.values,
};

/// 🆕 op_push 포트(push 일이 HTTP 없이 시험되게 · 구현 = [SupabaseOpsPush] · 🔵 E11m 재사용).
abstract interface class OpsPusher {
  /// [table](`OpsPushTables` 값)에 [rows] 를 올린다.
  Future<OpsPushResult> push({
    required String deviceId,
    required int epoch,
    required String table,
    required List<Map<String, Object?>> rows,
  });
}

/// 🆕 운영 폰 공유 표 push 클라이언트(계약 이름 · 인자 · 반환 칸 그대로 · 시크릿 관문 포함).
class SupabaseOpsPush implements OpsPusher {
  /// 만든다 — 연결 칸 · 시크릿 정확 값 = [vault] · 접근 토큰 = [auth].
  SupabaseOpsPush(
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

  /// [table] 에 [rows](열 이름 → 와이어 값 · 배치 D 그 표 열)를 올린다 — 이 기기 [deviceId] · 쥔 리스 [epoch].
  ///
  /// [table] 이 [OpsPushTables.all] 밖이면 망 0 · [ArgumentError].
  @override
  Future<OpsPushResult> push({
    required String deviceId,
    required int epoch,
    required String table,
    required List<Map<String, Object?>> rows,
  }) async {
    if (!OpsPushTables.all.contains(table)) {
      throw ArgumentError.value(table, 'table', 'OpsPushTables 밖');
    }
    final Map<String, Object?> args = <String, Object?>{
      OpsPushRpcParams.deviceId: deviceId,
      OpsPushRpcParams.epoch: epoch,
      OpsPushRpcParams.table: table,
      OpsPushRpcParams.rows: rows,
    };
    final String body = jsonEncode(args);
    final SecretScanResult scan;
    try {
      scan = scanForSecrets(
        body,
        exactValues: await readAllSecretValues(_vault),
        source: 'op_push:$table',
      );
    } on Object {
      return const OpsPushResult.failed(OpsPushFailure.config);
    }
    if (scan.blocked) {
      return OpsPushResult.failed(
        OpsPushFailure.secretBlocked,
        secretFindings: scan.findings.length,
      );
    }
    final (Uri, String)? cfg = await _config();
    if (cfg == null) {
      return const OpsPushResult.failed(OpsPushFailure.config);
    }
    final Uri uri = cfg.$1.replace(
      pathSegments: <String>['rest', 'v1', 'rpc', OpsPushRpcNames.push],
    );
    String? token = await _auth.accessToken();
    if (token == null) {
      return const OpsPushResult.failed(OpsPushFailure.notSignedIn);
    }
    http.Response? r = await _post(uri, cfg.$2, token, body);
    if (r != null && (r.statusCode == 401 || r.statusCode == 403)) {
      token = await _auth.accessToken(forceRefresh: true);
      if (token == null) {
        return const OpsPushResult.failed(OpsPushFailure.notSignedIn);
      }
      r = await _post(uri, cfg.$2, token, body);
    }
    if (r == null) {
      return const OpsPushResult.failed(OpsPushFailure.network);
    }
    final int c = r.statusCode;
    if (c == 401 || c == 403) {
      return OpsPushResult.failed(OpsPushFailure.unauthorized, statusCode: c);
    }
    if (c >= 500) {
      return OpsPushResult.failed(OpsPushFailure.server, statusCode: c);
    }
    if (c != 200) {
      return OpsPushResult.failed(OpsPushFailure.badResponse, statusCode: c);
    }
    return _parse(r) ??
        OpsPushResult.failed(OpsPushFailure.badResponse, statusCode: c);
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
  static OpsPushResult? _parse(http.Response r) {
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
    final Object? code = body[OpsPushRpcColumns.code];
    final Object? epoch = body[OpsPushRpcColumns.epoch];
    final Object? accepted = body[OpsPushRpcColumns.accepted];
    final Object? skipped = body[OpsPushRpcColumns.skipped];
    if (code != null && (code is! String || !kOpsPushCodes.contains(code))) {
      return null;
    }
    if (epoch != null && epoch is! int) return null;
    if (accepted is! int || skipped is! int || accepted < 0 || skipped < 0) {
      return null;
    }
    // 성공 = epoch 가 있어야 한다 · 거부 = 0 · 0.
    if (code == null && epoch == null) return null;
    if (code != null && (accepted != 0 || skipped != 0)) return null;
    return OpsPushResult.answered(
      code: code as String?,
      epoch: epoch as int?,
      accepted: accepted,
      skipped: skipped,
    );
  }
}
