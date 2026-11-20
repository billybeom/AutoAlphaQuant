// E11q-c1b — 실전 키 검증 사실(설계 13 §8 R196 · 미결 207 ⓑ).
//
// 🔴 별칭 → 세트(isa → KIS_ISA · general · pension → KIS_LIVE) · 대응표 밖 별칭 = 세트 모름(아직) ·
//    통과 = 필요한 세트 모두 OK · 실패 = 하나라도 INVALID · 그 밖 = null.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show CredentialKindCodes;
import 'package:test/test.dart';

CredentialHealthRecord _r(String kind, String health) => CredentialHealthRecord(
  kind: kind,
  health: health,
  lastVerifiedAtUtc: DateTime.utc(2026, 12, 21, 1),
);

const Map<String, String> _p0s = <String, String>{
  'P0S_A': 'isa',
  'P0S_B': 'pension',
  'P0S_C': 'general',
  'P0S_POT': 'isa',
};

void main() {
  test('별칭 → 세트 = 종합계좌 단위(위탁 · 연금저축 공유 · ISA 따로) · 기록 별칭 = 표본 글자', () {
    expect(kP0sLiveKeyKindOfAlias, <String, String>{
      'general': CredentialKindCodes.kisLive,
      'pension': CredentialKindCodes.kisLive,
      'isa': CredentialKindCodes.kisIsa,
    });
    // 🆕 R202 — 같은 종합계좌의 연금저축 = 상품코드 22(그 밖 = 저장된 세트 값).
    expect(kP0sLiveProductCodeOfAlias, <String, String>{'pension': '22'});
    expect(
      kSimToAutoWatchdogPrepareFailedHeadline,
      startsWith('바깥 감시를 준비하지 못해 전환하지 않았습니다'),
    );
    expect(kLiveKeyRegistryAlias, <String, String>{
      CredentialKindCodes.kisLive: 'kis_live',
      CredentialKindCodes.kisIsa: 'kis_isa',
    });
  });

  test('필요한 세트 = 대응표 별칭의 세트 · 공백은 다듬는다 · 대응표 밖 별칭 = null', () {
    expect(requiredLiveKeyKindsOf(_p0s), <String>{
      CredentialKindCodes.kisLive,
      CredentialKindCodes.kisIsa,
    });
    expect(
      requiredLiveKeyKindsOf(const <String, String>{'P0S_B': ' pension '}),
      <String>{CredentialKindCodes.kisLive},
    );
    expect(
      requiredLiveKeyKindsOf(const <String, String>{'P0S_A': 'irp'}),
      isNull,
    );
    expect(requiredLiveKeyKindsOf(const <String, String>{}), isEmpty);
  });

  test('🔴 사실 = 모두 OK 통과 · 하나라도 INVALID 실패 · 기록 없음 · UNKNOWN · 세트 모름 = 아직', () {
    final Set<String> both = requiredLiveKeyKindsOf(_p0s)!;
    bool? of(List<CredentialHealthRecord> rs, [Set<String>? req]) =>
        liveKeysVerifiedOf(required: req ?? both, records: rs);
    expect(
      of(<CredentialHealthRecord>[
        _r(CredentialKindCodes.kisLive, CredentialHealthCodes.ok),
        _r(CredentialKindCodes.kisIsa, CredentialHealthCodes.ok),
      ]),
      isTrue,
    );
    expect(
      of(<CredentialHealthRecord>[
        _r(CredentialKindCodes.kisLive, CredentialHealthCodes.ok),
      ]),
      isNull,
    );
    expect(
      of(<CredentialHealthRecord>[
        _r(CredentialKindCodes.kisLive, CredentialHealthCodes.invalid),
      ]),
      isFalse,
    );
    expect(
      of(<CredentialHealthRecord>[
        _r(CredentialKindCodes.kisLive, CredentialHealthCodes.ok),
        _r(CredentialKindCodes.kisIsa, CredentialHealthCodes.unknown),
      ]),
      isNull,
    );
    // 모의 세트 기록은 실전 판정에 들지 않는다.
    expect(
      of(<CredentialHealthRecord>[
        _r(CredentialKindCodes.kisPaper, CredentialHealthCodes.ok),
      ]),
      isNull,
    );
    expect(of(const <CredentialHealthRecord>[], <String>{}), isNull);
    expect(liveKeysVerifiedOf(required: null, records: const []), isNull);
  });
}
