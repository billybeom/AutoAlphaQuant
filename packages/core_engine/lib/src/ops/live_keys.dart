// 🆕 E11q-c1b — 실전 키 검증 사실(설계 13 §8 R196 · 미결 207 ⓑ · 05 S02 · 그림 24 W3 «실키 등록 · 검증»).
//
// 🔴 판정 = 계좌 대응표가 쓰는 실전 키 세트가 모두 «마지막 조회 검증 통과»인가 — 검증 = 토큰 + 잔고 1회(조회만 · 조립 앱 몫) ·
//    기록 = `credential_registry`(값 0 · 별칭 · 세트 · 건강 · 마지막 검증 시각).
// 🔴 별칭 → 세트(05 S02 «KIS 앱키 = 종합계좌 단위» · 13 R153 대응표): `isa` → `KIS_ISA` · `general` · `pension` → `KIS_LIVE`
//    (위탁 01 + 연금저축 22 공유). 대응표 밖 별칭 = 세트를 모른다 → «아직»(통과로 세지 않는다).
// 🔴 만료 · 신선도 수치 0(새 안전 수치를 만들지 않는다) — 커밋 직전 계좌 조회(207 ⓖ)가 따로 다시 본다.

import 'package:domain_contracts/domain_contracts.dart'
    show CredentialKindCodes;

/// 계좌 별칭 → 실전 키 세트(`CredentialKindCodes`).
const Map<String, String> kP0sLiveKeyKindOfAlias = <String, String>{
  'general': CredentialKindCodes.kisLive,
  'pension': CredentialKindCodes.kisLive,
  'isa': CredentialKindCodes.kisIsa,
};

/// 실전 세트 → 기록 별칭(`credential_registry.alias` · 표본 `m9/credentials` 와 같은 글자).
const Map<String, String> kLiveKeyRegistryAlias = <String, String>{
  CredentialKindCodes.kisLive: 'kis_live',
  CredentialKindCodes.kisIsa: 'kis_isa',
};

/// 기록 건강 글자(DDL `credential_registry.health` 가운데 검증이 쓰는 셋).
abstract final class CredentialHealthCodes {
  /// 마지막 검증 통과.
  static const String ok = 'OK';

  /// 마지막 검증 거절.
  static const String invalid = 'INVALID';

  /// 기록은 있으나 판정 없음.
  static const String unknown = 'UNKNOWN';
}

/// 키 세트 기록 한 줄(값 0).
class CredentialHealthRecord {
  /// 만든다.
  const CredentialHealthRecord({
    required this.kind,
    required this.health,
    required this.lastVerifiedAtUtc,
  });

  /// 세트(`CredentialKindCodes`).
  final String kind;

  /// 건강(`CredentialHealthCodes`).
  final String health;

  /// 마지막 검증 시각(없음 = null).
  final DateTime? lastVerifiedAtUtc;
}

/// 계좌 대응표가 요구하는 실전 세트 — 대응표 밖 별칭이 하나라도 있으면 null(«아직» — 세트를 모른다).
Set<String>? requiredLiveKeyKindsOf(Map<String, String> accountByStrategy) {
  final Set<String> out = <String>{};
  for (final String alias in accountByStrategy.values) {
    final String? kind = kP0sLiveKeyKindOfAlias[alias.trim()];
    if (kind == null) return null;
    out.add(kind);
  }
  return out;
}

/// 🔴 S3 «실전 키 확인» 사실 — 통과 = 필요한 세트가 모두 OK · 실패 = 하나라도 INVALID · 그 밖(기록 없음 · 세트 모름) = null(아직).
bool? liveKeysVerifiedOf({
  required Set<String>? required,
  required List<CredentialHealthRecord> records,
}) {
  if (required == null || required.isEmpty) return null;
  final Map<String, CredentialHealthRecord> byKind =
      <String, CredentialHealthRecord>{
        for (final CredentialHealthRecord r in records) r.kind: r,
      };
  bool all = true;
  for (final String kind in required) {
    final String? h = byKind[kind]?.health;
    if (h == CredentialHealthCodes.invalid) return false;
    if (h != CredentialHealthCodes.ok) all = false;
  }
  return all ? true : null;
}
