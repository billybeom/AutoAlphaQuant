// KIS 세션 — 모드가 고르는 키 세트(금고) → 클라이언트(E11p3c-1 · 설계 13 §8 R97 · R95 · R29 L3 · L4 · 🆕 E11q-c1d R207).
//
// 🔴 유량 문(`KisRateGate`)은 앱키 하나에 하나 — 유량은 앱키 단위라 문을 둘 만들면 유량을 넘는다. 🆕 R207 실전 종합계좌는
//    위탁(01) · 연금저축(22)이 앱키 하나를 같이 쓴다 → 클라이언트는 둘(상품코드가 다르다)이어도 문 · 토큰 보관은 하나.
//    같은 키면 다음 회차 · 다음 깨어남도 같은 클라이언트를 다시 쓴다.
// 🔴 토큰 보관 = 금고(`VaultKisTokenStore` · 기동 때 한 번 올림 · 토큰 키 = 환경 + 앱키 지문) — 프로세스가 다시 떠도 24h 안에는
//    재발급(알림톡)이 없다 · 같은 앱키의 두 클라이언트가 토큰 하나를 같이 쓴다(1분 1회 발급 제한).
// 🔴 키는 회차마다 금고에서 다시 읽는다 — 사람이 키를 바꾸면(회전) 다음 회차부터 새 키다(지문으로만 비교 · 값을 들고 있지 않는다).
// 🔴 쓸 키가 없으면 [KisSessionUnavailable] — 회차가 실패한다(`job_run` FAILED + fail 핑 · 조용히 건너뛰지 않는다).
//    사유 = 칸 이름 · 세트 표기 · 계좌 별칭뿐(값 0).
// 🆕 R207 실전 = 모드 세트(`KIS_LIVE` — 시세 · 현재가) + 계좌별 세트([liveAccountKeyOf] — 별칭 → 세트 · 연금저축 상품코드 22).
//    🔴 클라이언트가 있어도 실주문은 따로 막힌다(실키 검증 hold · 운영 리스 · 커밋 첫 판 dryRun).

import 'package:broker_gateway/broker_gateway.dart'
    show
        KisCredentialRead,
        KisCredentials,
        KisCredentialsMalformed,
        KisCredentialsMissing,
        KisCredentialsStored,
        KisEnvironment,
        KisKeySet,
        KisRateGate,
        KisRestClient,
        KisTokenStore,
        VaultKisTokenStore,
        kisKeySetFor,
        readKisCredentials;
import 'package:core_engine/core_engine.dart'
    show
        SecretId,
        SecretVault,
        kP0sLiveKeyKindOfAlias,
        kP0sLiveProductCodeOfAlias,
        secretFingerprint;
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:http/http.dart' as http;

/// 쓸 KIS 키가 없다 — 🔴 사유에 값이 없다.
class KisSessionUnavailable implements Exception {
  /// 만든다.
  const KisSessionUnavailable(this.reason);

  /// 사유(세트 표기 · 칸 이름 · 계좌 별칭).
  final String reason;

  @override
  String toString() => 'KisSessionUnavailable: $reason';
}

/// 🆕 R207 — 실전 계좌 하나의 키(세트 · 상품코드 덮어쓰기 — null = 금고 값 그대로).
typedef LiveAccountKey = ({KisKeySet set, String? productCode});

/// 🆕 R207 — 실전 계좌 별칭 → 키(P0S 대응 — `isa` → `KIS_ISA` · `general` → `KIS_LIVE` · `pension` → `KIS_LIVE` 상품코드 22) ·
/// 모르는 별칭 = null(🔴 다른 세트로 돌지 않는다).
LiveAccountKey? liveAccountKeyOf(String alias) {
  final String a = alias.trim();
  final String? kind = kP0sLiveKeyKindOfAlias[a];
  for (final KisKeySet s in KisKeySet.values) {
    if (s.wire == kind && s.environment == KisEnvironment.live) {
      return (set: s, productCode: kP0sLiveProductCodeOfAlias[a]);
    }
  }
  return null;
}

/// 🆕 R207 — [c] 의 상품코드만 [productCode] 로(null = 그대로).
KisCredentials kisCredentialsWithProduct(
  KisCredentials c,
  String? productCode,
) => productCode == null
    ? c
    : KisCredentials(
        environment: c.environment,
        appKey: c.appKey,
        appSecret: c.appSecret,
        accountNo: c.accountNo,
        productCode: productCode,
      );

/// 클라이언트 만들기(시험이 바꾸는 자리) — [gate] = 그 앱키의 유량 문(같은 앱키 = 같은 문).
typedef KisSessionClientOf = KisRestClient Function(
  http.Client http,
  KisCredentials credentials,
  KisTokenStore tokens,
  KisRateGate gate,
);

/// KIS 세션 — 키 한 벌에 클라이언트 하나 · 앱키 하나에 유량 문 하나.
class KisSessions {
  /// 만든다 — [clientOf] = 시험이 클라이언트 만들기를 바꾸는 자리.
  KisSessions({
    required this._vault,
    required this._http,
    KisSessionClientOf? clientOf,
  }) : _clientOf = clientOf ?? _defaultClient;

  final SecretVault _vault;
  final http.Client _http;
  final KisSessionClientOf _clientOf;

  KisTokenStore? _tokens;

  /// 자리(세트 · 상품코드) → (키 지문 · 클라이언트) — 키가 바뀌면 그 자리만 새로.
  final Map<String, ({String key, KisRestClient client})> _clients =
      <String, ({String key, KisRestClient client})>{};

  /// 환경 + 앱키 지문 → 유량 문.
  final Map<String, KisRateGate> _gates = <String, KisRateGate>{};

  static KisRestClient _defaultClient(
    http.Client h,
    KisCredentials c,
    KisTokenStore tokens,
    KisRateGate gate,
  ) => KisRestClient(
    h,
    c,
    environment: c.environment,
    tokens: tokens,
    gate: gate,
  );

  /// 🔴 [mode] 가 쓰는 클라이언트(모드 세트 — 시세 · 현재가) — 키가 없거나 꼴이 아니면 [KisSessionUnavailable] ·
  /// 금고를 못 열면 그 오류 그대로.
  Future<KisRestClient> clientFor(RunMode mode) async {
    final KisKeySet? set = kisKeySetFor(mode);
    if (set == null) {
      throw KisSessionUnavailable('${mode.name}: 키 세트가 없다');
    }
    return _clientOfSet(set, productCode: null);
  }

  /// 🆕 R207 — 실전 계좌 [alias] 의 클라이언트(별칭 → 세트 · 연금저축 = 같은 종합계좌 상품코드 22) — 모르는 별칭 ·
  /// 키 없음 · 꼴 아님 = [KisSessionUnavailable](모르는 별칭은 금고를 읽지 않는다) · 금고를 못 열면 그 오류 그대로.
  Future<KisRestClient> liveAccountClient(String alias) async {
    final LiveAccountKey? k = liveAccountKeyOf(alias);
    if (k == null) {
      throw KisSessionUnavailable('live: 계좌 별칭 «${alias.trim()}» 의 키 세트가 없다');
    }
    return _clientOfSet(k.set, productCode: k.productCode);
  }

  Future<KisRestClient> _clientOfSet(
    KisKeySet set, {
    required String? productCode,
  }) async {
    final KisCredentialRead read = await readKisCredentials(_vault, set);
    final KisCredentials stored;
    switch (read) {
      case KisCredentialsStored(credentials: final KisCredentials c):
        stored = c;
      case KisCredentialsMissing(missing: final List<SecretId> m):
        throw KisSessionUnavailable(
          '${set.wire}: 칸 없음 ${m.map((SecretId s) => s.value).join(', ')}',
        );
      case KisCredentialsMalformed(reason: final String r):
        throw KisSessionUnavailable(r);
    }
    final KisCredentials credentials = kisCredentialsWithProduct(
      stored,
      productCode,
    );
    final String slot = '${set.wire}/${credentials.productCode}';
    final String key = _keyOf(credentials);
    final ({String key, KisRestClient client})? have = _clients[slot];
    if (have != null && have.key == key) return have.client;
    final KisTokenStore tokens = _tokens ??= await VaultKisTokenStore.load(
      _vault,
    );
    final KisRateGate gate = _gates.putIfAbsent(
      '${credentials.environment.name}:${secretFingerprint(credentials.appKey)}',
      () => KisRateGate(credentials.environment.minInterval),
    );
    final KisRestClient made = _clientOf(_http, credentials, tokens, gate);
    _clients[slot] = (key: key, client: made);
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
