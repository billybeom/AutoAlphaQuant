// KIS 자격증명 금고 칸(E11p3b-4 · 설계 13 §8 R95 · 06 M4-4 · 05 S02 `CredentialCardVm.kind` · 01 §9-3 키 봉인).
//
// 🔴 값 하나 = 칸 하나 — 시크릿 스캔 · 가림은 금고 «값»을 그대로 찾는다(R44 E7 · 계좌 8자리도 여기서 잡힌다).
//    넷을 JSON 한 칸에 묶으면 앱키 하나만 샌 글을 스캔이 못 찾는다. 상품코드(`01`)는 8자 미만이라 스캔 · 가림이 무시한다.
// 🔴 칸 묶음이 환경을 정한다 — `kis.paper.*` 에서 읽은 키는 늘 모의 환경이다. SIM 기동은 이 묶음만 쓴다(01 §9-3).
// 🔴 세트는 «다 있거나 없다» — 쓰기 = 넷 다 지운 뒤 넷 다 쓴다. 도중에 끊기면 «없음»이지 옛 값 · 새 값이 섞인 세트가 아니다.
// 🔴 값은 `toString` · 오류 · 결과 어디에도 없다 — 칸 이름 · 사유만.
// 🔵 모의(`KIS_PAPER`) · 🆕 E11q-c1b(설계 13 §8 R196 · 미결 207 ⓑ) 실전 2(`KIS_LIVE` = 종합계좌 위탁 01 + 연금저축 22 공유 ·
//    `KIS_ISA` = ISA 종합계좌) — 등록 · 조회 검증(토큰 + 잔고 1회). 🆕 E11q-c1d(R207 · 실전 개시) [kisKeySetFor] live =
//    `KIS_LIVE`(모드 세트 = 시세 · 현재가 — 계좌와 무관) · 계좌별 주문 세트(별칭 → 세트 · 연금저축 22)는 조립 앱이 고른다.
//    대사 전용(`KIS_RECONCILE`)은 X7 창 뒤.

import 'package:core_engine/core_engine.dart' show SecretId, SecretVault;
import 'package:domain_contracts/domain_contracts.dart' show RunMode;

import 'kis_environment.dart';
import 'kis_run_mode.dart' show kisEnvironmentFor;

/// KIS 키 세트(표기 = 05 S02 `CredentialCardVm.kind`).
enum KisKeySet {
  /// 모의투자 — `KIS_PAPER`.
  paper('KIS_PAPER', 'kis.paper', KisEnvironment.mock),

  /// 🆕 R196 — 실전 종합계좌(위탁 01 · 연금저축 22 공유) — `KIS_LIVE`.
  live('KIS_LIVE', 'kis.live', KisEnvironment.live),

  /// 🆕 R196 — 실전 ISA 종합계좌 — `KIS_ISA`.
  isa('KIS_ISA', 'kis.isa', KisEnvironment.live);

  const KisKeySet(this.wire, this.slotPrefix, this.environment);

  /// 화면 · 기록 표기.
  final String wire;

  /// 금고 칸 이름 앞부분.
  final String slotPrefix;

  /// 이 세트가 발급된 KIS 환경.
  final KisEnvironment environment;
}

/// 세트 하나의 금고 칸 넷.
class KisCredentialSlots {
  KisCredentialSlots._(String p)
    : appKey = SecretId('$p.app_key'),
      appSecret = SecretId('$p.app_secret'),
      accountNo = SecretId('$p.account_no'),
      productCode = SecretId('$p.product_code');

  /// [set] 의 칸.
  factory KisCredentialSlots.of(KisKeySet set) =>
      KisCredentialSlots._(set.slotPrefix);

  /// 앱키 · 시크릿 · 종합계좌번호(8) · 상품코드(2).
  final SecretId appKey, appSecret, accountNo, productCode;

  /// 칸 넷(읽는 차례).
  List<SecretId> get all => <SecretId>[
    appKey,
    appSecret,
    accountNo,
    productCode,
  ];
}

/// 🔴 [mode] 가 쓰는 키 세트 — SIM 계열 = 모의 세트만(01 §9-3 · 내부 시뮬레이터도 시세는 모의 앱키 · ㉑) ·
/// 🆕 R207 live = 실전 종합계좌 세트(`KIS_LIVE` — 시세 · 현재가는 계좌와 무관 · 계좌별 주문 세트 = 조립 앱의 별칭 대응).
/// 🔴 실전 세트를 골라도 실주문은 따로 막힌다 — 승인(SAF-405) · 실키 검증(`LIVE_AWAITING_KEYS`) · 운영 리스(E11k 전 «모름») ·
/// 커밋 첫 판 `dryRun`(주문 0).
KisKeySet? kisKeySetFor(RunMode mode) => switch (mode) {
  RunMode.simInternal || RunMode.simBroker => KisKeySet.paper,
  RunMode.live => KisKeySet.live,
};

/// 🔴 기동 판정 `credentialEnvironmentOk`(R81 V6) — [mode] 가 쓰는 세트의 환경이 모드 환경과 같나.
///
/// 금고를 읽지 않는다 — 세트가 환경을 지니므로 «어느 세트를 고르나»가 곧 판정이다. 세트가 없는 모드(대응 함수가 null)는
/// «어긋남 없음» — 키 없음은 실행기에서 드러난다.
/// [setFor] = 시험이 잘못된 대응(live → 모의 세트)을 넣어 거부를 확인하는 자리(조립 앱은 기본값).
bool kisKeySetFits(
  RunMode mode, {
  KisKeySet? Function(RunMode mode) setFor = kisKeySetFor,
}) {
  final KisKeySet? set = setFor(mode);
  return set == null || set.environment == kisEnvironmentFor(mode);
}

/// 금고에서 읽은 세트.
sealed class KisCredentialRead {
  const KisCredentialRead();
}

/// 넷 다 있고 꼴이 맞다.
final class KisCredentialsStored extends KisCredentialRead {
  /// 만든다.
  const KisCredentialsStored(this.credentials);

  /// 자격증명(환경 = 세트의 환경).
  final KisCredentials credentials;

  @override
  String toString() =>
      'KisCredentialsStored(${credentials.environment.name} · <가림>)';
}

/// 비었거나 없는 칸이 있다 — 🔴 하나라도 없으면 세트 전체가 없다(섞인 세트를 쓰지 않는다).
final class KisCredentialsMissing extends KisCredentialRead {
  /// 만든다.
  const KisCredentialsMissing(this.missing);

  /// 비었거나 없는 칸(읽는 차례).
  final List<SecretId> missing;

  @override
  String toString() =>
      'KisCredentialsMissing(${missing.map((SecretId s) => s.value).join(', ')})';
}

/// 넷 다 있는데 꼴이 아니다(계좌 8자리 · 상품코드 2자리 등) — 🔴 사유에 값이 없다.
final class KisCredentialsMalformed extends KisCredentialRead {
  /// 만든다.
  const KisCredentialsMalformed(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'KisCredentialsMalformed($reason)';
}

/// [set] 을 금고에서 읽는다.
///
/// 🔴 못 엶(`SecretVaultError`)은 그대로 던진다 — «못 엶»을 «없음»으로 바꾸면 사람이 멀쩡한 키를 다시 넣으러 간다.
Future<KisCredentialRead> readKisCredentials(
  SecretVault vault,
  KisKeySet set,
) async {
  final KisCredentialSlots s = KisCredentialSlots.of(set);
  final Map<SecretId, String> got = <SecretId, String>{};
  final List<SecretId> missing = <SecretId>[];
  for (final SecretId id in s.all) {
    final String? v = await vault.read(id);
    if (v == null || v.isEmpty) {
      missing.add(id);
    } else {
      got[id] = v;
    }
  }
  if (missing.isNotEmpty) {
    return KisCredentialsMissing(List<SecretId>.unmodifiable(missing));
  }
  try {
    return KisCredentialsStored(
      KisCredentials(
        environment: set.environment,
        appKey: got[s.appKey]!,
        appSecret: got[s.appSecret]!,
        accountNo: got[s.accountNo]!,
        productCode: got[s.productCode]!,
      ),
    );
  } on ArgumentError catch (e) {
    return KisCredentialsMalformed('${set.wire}: ${e.message}');
  }
}

/// [credentials] 를 [set] 칸에 둔다(덮어쓴다).
///
/// 🔴 차례 = 넷 다 지운다 → 넷 다 쓴다(앱키가 마지막) — 어디서 끊겨도 읽으면 «없음»이다.
/// 🔴 다른 환경의 키 = [KisGuardError](실전 키를 모의 칸에 두지 않는다 · 칸을 건드리기 전에 막는다).
/// 🔵 키 회전 규칙(R44 E5 «검증 통과 전 구키 폐기 불가»)은 부르는 쪽 몫 — 새 키를 메모리에서 검증한 뒤에 부른다.
Future<void> storeKisCredentials(
  SecretVault vault,
  KisKeySet set,
  KisCredentials credentials,
) async {
  if (credentials.environment != set.environment) {
    throw KisGuardError(
      '${set.wire} 칸에 ${credentials.environment.name} 키를 둘 수 없다',
    );
  }
  final KisCredentialSlots s = KisCredentialSlots.of(set);
  await deleteKisCredentials(vault, set);
  await vault.write(s.accountNo, credentials.accountNo);
  await vault.write(s.productCode, credentials.productCode);
  await vault.write(s.appSecret, credentials.appSecret);
  await vault.write(s.appKey, credentials.appKey);
}

/// [set] 칸 넷을 지운다(없어도 성공).
Future<void> deleteKisCredentials(SecretVault vault, KisKeySet set) async {
  for (final SecretId id in KisCredentialSlots.of(set).all) {
    await vault.delete(id);
  }
}
