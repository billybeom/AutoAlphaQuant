// KIS 세션 — 모드가 고르는 키 세트(금고) → 클라이언트 하나(E11p3c-1 · 설계 13 §8 R97 · R95 · R29 L3 · L4).
//
// 🔴 클라이언트는 키 한 벌에 하나 — 유량 문(`KisRateGate` · 모의 1건/초)이 클라이언트마다 따로라 둘을 만들면 유량을 넘는다.
//    같은 키면 다음 회차 · 다음 깨어남도 같은 클라이언트를 다시 쓴다.
// 🔴 토큰 보관 = 금고(`VaultKisTokenStore` · 기동 때 한 번 올림) — 프로세스가 다시 떠도 24h 안에는 재발급(알림톡)이 없다.
// 🔴 키는 회차마다 금고에서 다시 읽는다 — 사람이 키를 바꾸면(회전) 다음 회차부터 새 키다(지문으로만 비교 · 값을 들고 있지 않는다).
// 🔴 쓸 키가 없으면 [KisSessionUnavailable] — 회차가 실패한다(`job_run` FAILED + fail 핑 · 조용히 건너뛰지 않는다).
//    사유 = 칸 이름 · 세트 표기뿐(값 0).

import 'package:broker_gateway/broker_gateway.dart'
    show
        KisCredentialRead,
        KisCredentials,
        KisCredentialsMalformed,
        KisCredentialsMissing,
        KisCredentialsStored,
        KisKeySet,
        KisRestClient,
        KisTokenStore,
        VaultKisTokenStore,
        kisKeySetFor,
        readKisCredentials;
import 'package:core_engine/core_engine.dart'
    show SecretId, SecretVault, secretFingerprint;
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:http/http.dart' as http;

/// 쓸 KIS 키가 없다 — 🔴 사유에 값이 없다.
class KisSessionUnavailable implements Exception {
  /// 만든다.
  const KisSessionUnavailable(this.reason);

  /// 사유(세트 표기 · 칸 이름).
  final String reason;

  @override
  String toString() => 'KisSessionUnavailable: $reason';
}

/// KIS 세션 — 키 한 벌에 클라이언트 하나.
class KisSessions {
  /// 만든다 — [clientOf] = 시험이 클라이언트 만들기를 바꾸는 자리.
  KisSessions({
    required this._vault,
    required this._http,
    KisRestClient Function(
      http.Client http,
      KisCredentials credentials,
      KisTokenStore tokens,
    )?
    clientOf,
  }) : _clientOf = clientOf ?? _defaultClient;

  final SecretVault _vault;
  final http.Client _http;
  final KisRestClient Function(http.Client, KisCredentials, KisTokenStore)
  _clientOf;

  KisTokenStore? _tokens;
  KisRestClient? _client;
  String? _clientKey;

  static KisRestClient _defaultClient(
    http.Client h,
    KisCredentials c,
    KisTokenStore tokens,
  ) => KisRestClient(h, c, environment: c.environment, tokens: tokens);

  /// 🔴 [mode] 가 쓰는 클라이언트 — 키가 없거나 꼴이 아니면 [KisSessionUnavailable] · 금고를 못 열면 그 오류 그대로.
  Future<KisRestClient> clientFor(RunMode mode) async {
    final KisKeySet? set = kisKeySetFor(mode);
    if (set == null) {
      throw KisSessionUnavailable('${mode.name}: 키 세트가 아직 없다(계약 창 뒤)');
    }
    final KisCredentialRead read = await readKisCredentials(_vault, set);
    final KisCredentials credentials;
    switch (read) {
      case KisCredentialsStored(credentials: final KisCredentials c):
        credentials = c;
      case KisCredentialsMissing(missing: final List<SecretId> m):
        throw KisSessionUnavailable(
          '${set.wire}: 칸 없음 ${m.map((SecretId s) => s.value).join(', ')}',
        );
      case KisCredentialsMalformed(reason: final String r):
        throw KisSessionUnavailable(r);
    }
    final String key = _keyOf(credentials);
    final KisRestClient? have = _client;
    if (have != null && _clientKey == key) return have;
    final KisTokenStore tokens = _tokens ??= await VaultKisTokenStore.load(
      _vault,
    );
    final KisRestClient made = _clientOf(_http, credentials, tokens);
    _client = made;
    _clientKey = key;
    return made;
  }

  /// 키 한 벌의 지문(값 0 — 같은 키인지만 본다).
  static String _keyOf(KisCredentials c) => <String>[
    c.environment.name,
    secretFingerprint(c.appKey),
    secretFingerprint(c.appSecret),
    secretFingerprint(c.accountNo),
    c.productCode,
  ].join(':');
}
