// 🆕 미결 244 ⓑ — X5 `canonSupabase` 대조 읽기(설계 13 §8 R271 O5 · 01 §8 미결 244 · 배치 D `ledger_stamp` · 계약 v1.40 K358 select 본문).
//
// 🔵 PostgREST 읽기 하나 = `GET /rest/v1/ledger_stamp?select=authored_date,chain_hash,operator_epoch&mode=eq.<모드>
//    &order=authored_date.desc&limit=1`(그 모드의 마지막 스탬프 한 행 · 없음 = 비었다) · 머리 = 공개 키 `apikey` +
//    `Authorization: Bearer <접근 토큰>` · 401 · 403 = 토큰을 새로 받아 한 번 더.
// 🔴 읽기만(쓰기 = `op_push`) · 실패는 종류만(«모름» — 파생 판정을 하지 않고 다음 깨어남에 다시 · FORK 로 읽지 않는다).
// 🔴 행 꼴이 틀리면(날 · 체인 · epoch) = badResponse(지어내지 않는다 · FORK 아님).
// 🔴 토큰 · 주소 · 키는 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다.

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart' show DerivedStamp, SecretVault;
import 'package:domain_contracts/domain_contracts.dart'
    show OpsPushTables, RunMode;
import 'package:http/http.dart' as http;

import 'supabase_auth.dart';
import 'supabase_server_time.dart';

/// 원격 스탬프 읽기 실패 종류.
enum LedgerStampReadFailure {
  /// 연결 칸 없음 · 꼴 아님 · 금고 실패 — 망 0.
  config,

  /// 로그인 세션 없음 · 잃음.
  notSignedIn,

  /// 401 · 403(토큰을 새로 받아 한 번 더 해도).
  unauthorized,

  /// 서버 오류(5xx).
  server,

  /// 그 밖의 HTTP · 응답 꼴 · 행 꼴.
  badResponse,

  /// 망 · 시간 초과.
  network,
}

/// 원격 스탬프 읽기 한 번 — 🔴 토큰 없음.
class LedgerStampRead {
  /// 읽었다([stamp] = null 이면 그 모드 스탬프 0행).
  const LedgerStampRead.ok(this.stamp) : failure = null, statusCode = null;

  /// 못 읽었다.
  const LedgerStampRead.failed(
    LedgerStampReadFailure this.failure, {
    this.statusCode,
  }) : stamp = null;

  /// 마지막 스탬프(없음 · 실패 = null).
  final DerivedStamp? stamp;

  /// 실패 종류(읽었으면 null).
  final LedgerStampReadFailure? failure;

  /// HTTP 상태(있으면).
  final int? statusCode;

  @override
  String toString() => failure == null
      ? 'LedgerStampRead(${stamp == null ? '없음' : '${stamp!.authoredDate} · epoch ${stamp!.operatorEpoch}'})'
      : 'LedgerStampRead(${failure!.name}${statusCode == null ? '' : ' · HTTP $statusCode'})';
}

/// 🆕 원격 스탬프 읽기 포트(실행기가 HTTP 없이 시험되게 · 구현 = [SupabaseLedgerStampRead]).
abstract interface class LedgerStampReader {
  /// [mode] 의 마지막 원격 스탬프.
  Future<LedgerStampRead> lastStamp(RunMode mode);
}

/// 읽는 열(배치 D 이름 그대로).
const String kLedgerStampReadColumns =
    'authored_date,chain_hash,operator_epoch';

/// 🆕 `ledger_stamp` 마지막 한 행 읽기(읽기만).
class SupabaseLedgerStampRead implements LedgerStampReader {
  /// 만든다 — 연결 칸 = [vault] · 접근 토큰 = [auth].
  SupabaseLedgerStampRead(
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

  @override
  Future<LedgerStampRead> lastStamp(RunMode mode) async {
    final (Uri, String)? cfg = await _config();
    if (cfg == null) {
      return const LedgerStampRead.failed(LedgerStampReadFailure.config);
    }
    final Uri uri = cfg.$1.replace(
      pathSegments: <String>['rest', 'v1', OpsPushTables.ledgerStamp],
      queryParameters: <String, String>{
        'select': kLedgerStampReadColumns,
        'mode': 'eq.${mode.wire}',
        'order': 'authored_date.desc',
        'limit': '1',
      },
    );
    String? token = await _auth.accessToken();
    if (token == null) {
      return const LedgerStampRead.failed(LedgerStampReadFailure.notSignedIn);
    }
    http.Response? r = await _get(uri, cfg.$2, token);
    if (r != null && (r.statusCode == 401 || r.statusCode == 403)) {
      token = await _auth.accessToken(forceRefresh: true);
      if (token == null) {
        return const LedgerStampRead.failed(LedgerStampReadFailure.notSignedIn);
      }
      r = await _get(uri, cfg.$2, token);
    }
    if (r == null) {
      return const LedgerStampRead.failed(LedgerStampReadFailure.network);
    }
    final int c = r.statusCode;
    if (c == 401 || c == 403) {
      return LedgerStampRead.failed(
        LedgerStampReadFailure.unauthorized,
        statusCode: c,
      );
    }
    if (c >= 500) {
      return LedgerStampRead.failed(
        LedgerStampReadFailure.server,
        statusCode: c,
      );
    }
    if (c != 200) {
      return LedgerStampRead.failed(
        LedgerStampReadFailure.badResponse,
        statusCode: c,
      );
    }
    final List<Object?>? rows = _array(r.bodyBytes);
    if (rows == null || rows.length > 1) {
      return LedgerStampRead.failed(
        LedgerStampReadFailure.badResponse,
        statusCode: c,
      );
    }
    if (rows.isEmpty) return const LedgerStampRead.ok(null);
    final DerivedStamp? s = _stamp(rows.single);
    return s == null
        ? LedgerStampRead.failed(
            LedgerStampReadFailure.badResponse,
            statusCode: c,
          )
        : LedgerStampRead.ok(s);
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

  static List<Object?>? _array(List<int> body) {
    try {
      final Object? v = jsonDecode(utf8.decode(body));
      return v is List<Object?> ? v : null;
    } on FormatException {
      return null;
    }
  }

  static DerivedStamp? _stamp(Object? row) {
    if (row is! Map<String, Object?>) return null;
    final Object? date = row['authored_date'];
    final Object? chain = row['chain_hash'];
    final Object? epoch = row['operator_epoch'];
    if (date is! String || chain is! String || epoch is! int) return null;
    try {
      return DerivedStamp(
        authoredDate: date,
        chainHash: chain,
        operatorEpoch: epoch,
      );
    } on ArgumentError {
      return null;
    }
  }
}
