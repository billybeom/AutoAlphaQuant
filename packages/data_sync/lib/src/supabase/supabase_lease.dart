// operator 리스 RPC 클라이언트 · 원격 리스 판정(E11k-e1 · 설계 13 §8 R215 · 06 M4-3 · X1-1 · R43 D3 · R70 D8 · R71 L3 ·
// 계약 v1.29 `schema/supabase_rpc.dart` · `LeaseRpcResultCodes`).
//
// 🔵 RPC = `POST /rest/v1/rpc/<이름>`(공개 키 `apikey` + `Authorization: Bearer <접근 토큰>` · 본문 = 계약 인자 이름) ·
//    반환 = 한 행(`code` · `epoch` · `expires_at` — 배열 한 칸이어도 · 객체여도 받는다). `code` = 계약 거부 사전 ∪ null(성공).
// 🔴 클라이언트는 HTTP 상태 · 오류 문장으로 거부 코드를 짓지 않는다(계약) — 거부 = 서버가 돌려준 `code` 뿐. HTTP 실패 = 모름 쪽.
// 🔴 판정(당겨 쓰는 리스 · 주문 직전 · R71 L1 · L2):
//    · 이 기기가 쥔 epoch(sync_state SUPABASE `operator_epoch`) > 0 → `lease_renew` · `LEASE_LOST` 면 `lease_claim` 한 번(만료 · 같은 기기 =
//      되찾음 · 다른 기기가 쥠 = `LEASE_HELD_BY_OTHER`).
//    · epoch 0(쥔 적 없음) → 클레임하지 않는다 = 무효(첫 클레임 = 복구 코드 해시가 드는 명시 흐름 · 다른 기기에서 넘어오기 = X1).
//    · 성공 = 유효 + sync_state SUPABASE 행(epoch · `last_ok_at` · OK) · 서버 거부 = 무효 · 망 · 인증 · 꼴 = 모름(🔴 둘 다 막는다).
// 🔴 이 판정은 실전 · 브로커 모의만 쓴다(`simInternal` = 로컬 단독 리스 그대로 · R70 D8) — 배선 = E11k-e3.
// 🔴 토큰 · 주소 · 키 · 복구 코드는 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다.
// 🆕 E11k-e3(설계 13 §8 R229) — ① 운영 기기 행 등록(`POST /rest/v1/app_device` · 계약 v1.34 RLS `device_insert_viewer_only` —
//    `auth_uid = owner_uid = 로그인 사용자` · viewer · PENDING · 201 = 넣음 · 409 = 이미 있음 → 둘 다 다음 · 승격 = 리스 RPC) ·
//    ② «쥔 epoch» = sync_state 행이 없거나 0 이면 이 기기의 첫 클레임 기록(`claimedEpoch` · 복구 카드 — 실전 원장은 simToAuto
//    때 처음 생겨 온보딩 첫 클레임을 그 원장에 적을 수 없다) · 🔴 기록이 0 이면 여전히 자동 클레임 0 ·
//    ③ 성공 기록이 SUPABASE 행의 상태(파생 FORK · PUSH_*)를 덮지 않는다(새 행만 OK · 같은 행 = 파생 대상 · 끈적 FORK).

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        LeaseRpcColumns,
        LeaseRpcNames,
        LeaseRpcParams,
        LeaseRpcResultCodes;
import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart';

import '../local/lease_store.dart' show kLeaseSyncTarget;
import 'supabase_auth.dart';
import 'supabase_server_time.dart';

/// 🆕 리스 RPC 실패(서버 거부가 아닌 것 — 전부 «모름» 쪽).
enum LeaseRpcFailure {
  /// 연결 칸 없음 · 꼴 아님 · 금고 실패.
  config,

  /// 로그인 세션 없음 · 잃음(접근 토큰 없음).
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

/// 🆕 리스 RPC 한 번의 결과 — 🔴 토큰 · 복구 코드 없음.
class LeaseRpcResult {
  /// 서버가 답했다(거부 코드 · null = 성공).
  const LeaseRpcResult.answered({
    required this.code,
    required this.epoch,
    required this.expiresAtUtc,
  }) : failure = null,
       statusCode = null;

  /// 답을 못 받았다.
  const LeaseRpcResult.failed(LeaseRpcFailure this.failure, {this.statusCode})
    : code = null,
      epoch = null,
      expiresAtUtc = null;

  /// 서버 거부 코드(`LeaseRpcResultCodes` · 성공 = null · 실패 = null).
  final String? code;

  /// 리스 epoch(서버 값).
  final int? epoch;

  /// 리스 만료 시각(서버 `now()` 기준).
  final DateTime? expiresAtUtc;

  /// 답을 못 받은 까닭(답했으면 null).
  final LeaseRpcFailure? failure;

  /// HTTP 상태(있으면).
  final int? statusCode;

  /// 리스를 얻었다 · 이어 쥐었다.
  bool get granted => failure == null && code == null && epoch != null;

  @override
  String toString() => failure != null
      ? 'LeaseRpcResult(${failure!.name}'
            '${statusCode == null ? '' : ' · HTTP $statusCode'})'
      : 'LeaseRpcResult(${code ?? 'OK'} · epoch $epoch)';
}

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

/// 🆕 리스 RPC 클라이언트(계약 표 이름 · 인자 · 반환 칸 그대로).
class SupabaseLeaseRpc {
  /// 만든다 — 연결 칸 = [vault] · 접근 토큰 = [auth].
  SupabaseLeaseRpc(
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

  /// 클레임(첫 클레임 = [recoveryCodeHash] 필수 · 그 밖 = null).
  Future<LeaseRpcResult> claim({
    required String deviceId,
    String? recoveryCodeHash,
  }) => _call(LeaseRpcNames.claim, <String, Object?>{
    LeaseRpcParams.deviceId: deviceId,
    LeaseRpcParams.recoveryCodeHash: recoveryCodeHash,
  });

  /// 갱신(보유 ∧ 같은 epoch ∧ 만료 전).
  Future<LeaseRpcResult> renew({
    required String deviceId,
    required int epoch,
  }) => _call(LeaseRpcNames.renew, <String, Object?>{
    LeaseRpcParams.deviceId: deviceId,
    LeaseRpcParams.epoch: epoch,
  });

  /// 🆕 E11k-e3(R229) — 운영 기기 행 등록(자기 기기 · viewer · PENDING — 승격 = [claim] 성공 때 서버) ·
  /// null = 넣음 · 이미 있음(409) · 그 밖 = 실패 종류(로그인 사용자 id 없음 = [LeaseRpcFailure.notSignedIn]).
  Future<LeaseRpcFailure?> registerDevice({
    required String deviceId,
    required String label,
    required String platform,
  }) async {
    final (Uri, String)? cfg = await _config();
    if (cfg == null) return LeaseRpcFailure.config;
    final Uri uri = cfg.$1.replace(
      pathSegments: const <String>['rest', 'v1', 'app_device'],
    );
    Map<String, Object?>? row(String? uid) => uid == null
        ? null
        : <String, Object?>{
            'device_id': deviceId,
            'label': label,
            'role': 'viewer',
            'status': 'PENDING',
            'platform': platform,
            'owner_uid': uid,
            'auth_uid': uid,
          };
    String? token = await _auth.accessToken();
    Map<String, Object?>? body = row(_auth.userId);
    if (token == null || body == null) return LeaseRpcFailure.notSignedIn;
    http.Response? r = await _post(uri, cfg.$2, token, body, minimal: true);
    if (r != null && (r.statusCode == 401 || r.statusCode == 403)) {
      token = await _auth.accessToken(forceRefresh: true);
      body = row(_auth.userId);
      if (token == null || body == null) return LeaseRpcFailure.notSignedIn;
      r = await _post(uri, cfg.$2, token, body, minimal: true);
    }
    if (r == null) return LeaseRpcFailure.network;
    final int c = r.statusCode;
    // 201 = 넣음 · 409 = 같은 기기 id 행이 이미 있다(기기 하나 = 행 하나 · 자격 판정 = 리스 RPC).
    if (c == 201 || c == 409) return null;
    if (c == 401 || c == 403) return LeaseRpcFailure.unauthorized;
    if (c >= 500) return LeaseRpcFailure.server;
    return LeaseRpcFailure.badResponse;
  }

  /// 비상 회수(X1-3 ① · 🔴 [recoveryCode] = 평문 — 이 호출에만 · 쥐지 않는다).
  Future<LeaseRpcResult> revoke({
    required String deviceId,
    required String recoveryCode,
    required String newRecoveryCodeHash,
  }) => _call(LeaseRpcNames.revoke, <String, Object?>{
    LeaseRpcParams.deviceId: deviceId,
    LeaseRpcParams.recoveryCode: recoveryCode,
    LeaseRpcParams.newRecoveryCodeHash: newRecoveryCodeHash,
  });

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
    Object body, {
    bool minimal = false,
  }) async {
    try {
      return await _http
          .post(
            uri,
            headers: <String, String>{
              'apikey': key,
              'authorization': 'Bearer $token',
              'content-type': 'application/json',
              // 넣은 행을 돌려받지 않는다(SELECT 정책과 무관하게 201).
              if (minimal) 'prefer': 'return=minimal',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on Exception {
      return null;
    }
  }

  Future<LeaseRpcResult> _call(String name, Map<String, Object?> args) async {
    final (Uri, String)? cfg = await _config();
    if (cfg == null) {
      return const LeaseRpcResult.failed(LeaseRpcFailure.config);
    }
    final Uri uri = cfg.$1.replace(
      pathSegments: <String>['rest', 'v1', 'rpc', name],
    );
    String? token = await _auth.accessToken();
    if (token == null) {
      return const LeaseRpcResult.failed(LeaseRpcFailure.notSignedIn);
    }
    http.Response? r = await _post(uri, cfg.$2, token, args);
    if (r != null && (r.statusCode == 401 || r.statusCode == 403)) {
      // 접근 토큰이 서버에서 먼저 죽었다 — 한 번만 새로 받아 다시.
      token = await _auth.accessToken(forceRefresh: true);
      if (token == null) {
        return const LeaseRpcResult.failed(LeaseRpcFailure.notSignedIn);
      }
      r = await _post(uri, cfg.$2, token, args);
    }
    if (r == null) return const LeaseRpcResult.failed(LeaseRpcFailure.network);
    final int c = r.statusCode;
    if (c == 401 || c == 403) {
      return LeaseRpcResult.failed(LeaseRpcFailure.unauthorized, statusCode: c);
    }
    if (c >= 500) {
      return LeaseRpcResult.failed(LeaseRpcFailure.server, statusCode: c);
    }
    if (c != 200) {
      return LeaseRpcResult.failed(LeaseRpcFailure.badResponse, statusCode: c);
    }
    return _parse(r) ??
        LeaseRpcResult.failed(LeaseRpcFailure.badResponse, statusCode: c);
  }

  /// 한 행(배열 한 칸 · 객체) → 결과 — 꼴 · 모르는 코드 = null.
  static LeaseRpcResult? _parse(http.Response r) {
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
    final Object? code = body[LeaseRpcColumns.code];
    final Object? epoch = body[LeaseRpcColumns.epoch];
    final Object? exp = body[LeaseRpcColumns.expiresAt];
    if (code != null &&
        (code is! String || !LeaseRpcResultCodes.values.contains(code))) {
      return null;
    }
    if (epoch != null && epoch is! int) return null;
    DateTime? expiresAt;
    if (exp != null) {
      if (exp is! String || !_offset.hasMatch(exp)) return null;
      expiresAt = DateTime.tryParse(exp)?.toUtc();
      if (expiresAt == null) return null;
    }
    // 성공 = epoch · 만료 둘 다 있어야 한다.
    if (code == null && (epoch == null || expiresAt == null)) return null;
    return LeaseRpcResult.answered(
      code: code as String?,
      epoch: epoch as int?,
      expiresAtUtc: expiresAt,
    );
  }
}

/// 🆕 원격 리스 판정(당겨 쓰는 리스 — `SqliteLeaseGate(remote:)` 자리 · R71 L3).
class SupabaseLeaseGate implements LeaseGate {
  /// 만든다 — [db] = 이 모드의 원장(sync_state SUPABASE 행) · [deviceId] = 이 기기(`app_device.device_id`) ·
  /// 🆕 R229 [claimedEpoch] = 이 기기의 첫 클레임 기록 epoch(복구 카드 · 없음 = 0 · 원장 행이 없을 때만 읽는다).
  SupabaseLeaseGate(
    this._rpc,
    this._db, {
    required this.deviceId,
    required this._clock,
    this._claimedEpoch,
  });

  final SupabaseLeaseRpc _rpc;
  final Database _db;
  final Clock _clock;
  final int Function()? _claimedEpoch;

  /// 이 기기 id.
  final String deviceId;

  /// 마지막 판정의 RPC 결과(진단 · 시험용 · 없음 = null).
  LeaseRpcResult? last;

  int _heldEpoch() {
    final ResultSet rs = _db.select(
      'SELECT operator_epoch FROM sync_state WHERE target = ?',
      <Object?>[kLeaseSyncTarget],
    );
    final int held = rs.isEmpty ? 0 : rs.first['operator_epoch'] as int;
    if (held > 0) return held;
    // 🆕 R229 — 이 원장에 쥔 기록이 없으면 이 기기의 첫 클레임 기록(복구 카드) · 없음 = 0(자동 클레임 0 그대로).
    final int Function()? claimed = _claimedEpoch;
    return claimed == null ? 0 : claimed();
  }

  void _record(int epoch) {
    final String now = _clock.nowUtc().toUtc().toIso8601String();
    // 🔴 봉인된 행은 바꾸지 않는다(봉인 해제 = X1 재클레임 흐름).
    // 🆕 R229 — 있는 행의 상태는 그대로(SUPABASE = 파생 대상 — FORK · PUSH_* 를 리스 성공이 지우지 않는다) · 새 행만 OK.
    _db.execute(
      'INSERT INTO sync_state (target, last_ok_at, status, operator_epoch, updated_at) '
      "VALUES (?, ?, 'OK', ?, ?) "
      'ON CONFLICT(target) DO UPDATE SET last_ok_at = excluded.last_ok_at, '
      'operator_epoch = excluded.operator_epoch, updated_at = excluded.updated_at '
      "WHERE sync_state.status <> 'SEALED'",
      <Object?>[kLeaseSyncTarget, now, epoch, now],
    );
  }

  LeaseVerdict _verdict(LeaseRpcResult r) {
    last = r;
    if (r.failure != null) return LeaseVerdict.unknown;
    if (r.granted) {
      _record(r.epoch!);
      return LeaseVerdict.valid;
    }
    return LeaseVerdict.invalid;
  }

  @override
  Future<LeaseVerdict> check() async {
    final int held = _heldEpoch();
    if (held <= 0) {
      // 쥔 적 없음 — 첫 클레임은 복구 코드가 드는 명시 흐름(자동 클레임 0).
      last = null;
      return LeaseVerdict.invalid;
    }
    final LeaseRpcResult renewed = await _rpc.renew(
      deviceId: deviceId,
      epoch: held,
    );
    if (renewed.code == LeaseRpcResultCodes.lost) {
      // 만료 · epoch 어긋남 — 한 번만 되찾기를 시도한다(다른 기기가 쥐었으면 서버가 거부).
      return _verdict(await _rpc.claim(deviceId: deviceId));
    }
    return _verdict(renewed);
  }
}
