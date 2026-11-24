// O-04 ⑤ 복구 카드 발급 · 첫 클레임 글자 · 결과(E11k-e3 · 설계 13 §8 R229 · 04 §9-5 ⑤ · 06 M4-10 · M4-3 · 계약 v1.16 K2 슬롯
// `RECOVERY_CHECKSUM` · v1.29 리스 RPC 표 · v1.34 `app_device` RLS).
//
// 🔴 뜻 = 이 폰이 운영 리스를 처음 쥐는 명시 흐름 — 복구 코드(기기가 뽑는 무작위)를 종이 카드에 옮겨 적게 하고, 종이를 보고 다시
//    입력한 코드가 맞으면(해시 대조) 기기 행을 등록하고 `lease_claim` 에 그 해시를 실어 보낸다(서버 = 같은 트랜잭션에서 해시만 저장).
// 🔴 평문 = 종이 카드에만 — 이 글자는 ⑤ 가 열려 있는 동안 화면 한 줄로만 보인다(확인 뒤 줄 0 · 원장 · 금고 · 로그 0 ·
//    PDF · 공유 · 캡처 0 = 조립 앱 FLAG_SECURE).
// 🔴 글자 = 엔진(카드 안내 · 결과) — 조립 앱 칸은 문장을 짓지 않는다(③ 생체 `BiometricSignTexts` 선례).

/// `command_inbox.kind` — ⑤ 복구 카드 첫 클레임 기록(스키마 무변경 · ③ `ONBOARDING_BIOMETRIC_SIGN` 선례).
const String kRecoveryCardKind = 'ONBOARDING_RECOVERY_CARD';

/// 운영 기기 행 라벨(`app_device.label` — 엔진이 지은 별칭 · 기기 모델 · 이름 0).
const String kOperatorDeviceLabel = '운영 폰';

/// 첫 클레임 한 번의 결과(조립 앱 → 문장).
enum FirstClaimOutcome {
  /// 서버가 이 해시로 첫 리스를 줬다(epoch 1) — 카드 발급 끝.
  claimed,

  /// 리스는 얻었지만 계정에 이미 예전 복구 카드가 있다(epoch > 1 — 이 해시는 서버에 없다).
  existingCard,

  /// 다시 입력한 코드가 카드와 다르다(다시 입력).
  mismatch,

  /// 보여 줄 카드가 없다(이미 끝 · 대기 중).
  noCard,

  /// 다른 기기가 리스를 쥐고 있다(`LEASE_HELD_BY_OTHER` — 만료됐어도 그 기기가 회수 · 은퇴 전 · 기기 이전 X1 · 비상 이전).
  heldByOther,

  /// 이 기기를 운영 기기로 쓸 수 없다(`LEASE_DEVICE_NOT_ELIGIBLE` 등 서버 거부).
  refused,

  /// Supabase 연결 칸 · 로그인이 없다(o_07 먼저).
  notConnected,

  /// 망 · 서버 · 인증 · 응답 꼴 — 종이의 코드는 확인됐고 등록만 남았다(다시 시도).
  retryLater,
}

/// ⑤ 복구 카드 글자(엔진).
abstract final class RecoveryCardTexts {
  /// 칸 버튼 — 확인.
  static const String confirmButton = '복구 코드 확인';

  /// 칸 버튼 — 등록 다시 시도.
  static const String retryButton = '등록 다시 시도';

  /// 칸 입력 이름.
  static const String inputLabel = '종이에 적은 복구 코드';

  /// 칸 안내(늘).
  static const String inputGuide =
      '종이를 보고 직접 입력하십시오. 하이픈 · 띄어쓰기 · 대소문자는 상관없습니다. 입력한 값은 확인에만 쓰고 저장하지 않습니다.';

  /// 마친 단계 줄(🔴 코드 줄 0).
  static const String doneLine = '복구 카드를 발급했습니다 — 복구 코드는 종이 카드에만 있습니다.';

  /// 마친 단계 줄 — 예전 카드.
  static const String existingLine =
      '이 계정에는 예전 복구 카드가 있습니다 — 방금 적은 종이는 버리고 예전 카드를 보관하십시오.';

  /// 대기 줄(확인됨 · 등록 남음).
  static const String pendingLine =
      '종이의 복구 코드를 확인했습니다 — 서버 등록이 남았습니다. 종이는 그대로 보관하십시오.';

  /// 앞 카드가 거부돼 새로 낸 카드의 머리 줄.
  static const String reissuedLine =
      '앞서 적은 종이는 등록되지 않았습니다 — 버리고 아래 새 코드를 적으십시오.';

  /// 결과 — 발급 끝.
  static const String claimed = '복구 카드를 발급했습니다. 이 폰이 운영 기기로 등록됐습니다.';

  /// 결과 — 예전 카드.
  static const String existing = existingLine;

  /// 결과 — 다름.
  static const String mismatch = '카드의 복구 코드와 다릅니다 — 종이와 화면을 다시 맞춰 보고 입력하십시오.';

  /// 결과 — 카드 없음.
  static const String noCard = '지금 확인할 복구 카드가 없습니다.';

  /// 결과 — 다른 기기(🆕 리뷰 3차 C-1 · D-01 · 01 §8 미결 236 ⓐ · R267 — 서버는 만료된 리스도 그 기기를 회수 · 은퇴하기 전에는
  /// 넘기지 않는다 → 옛 폰이 없으면 비상 이전 · 예전 복구 카드가 길이다).
  static const String heldByOther =
      '다른 기기가 운영 기기로 남아 있어 등록하지 못했습니다 — 그 기기가 옆에 있으면 그 기기에서 기기 이전으로, '
      '잃었으면 첫 화면 «기존 계정에서 다시 시작»의 비상 이전(예전 복구 카드)으로 옮기십시오. 이 종이는 버리십시오.';

  /// 결과 — 서버 거부.
  static const String refused = '서버가 이 기기의 운영 등록을 받지 않았습니다 — 이 종이는 버리십시오.';

  /// 결과 — 연결 · 로그인 없음.
  static const String notConnected = 'Supabase 연결과 로그인(o_07)을 먼저 마치십시오.';

  /// 결과 — 잠시 뒤.
  static const String retryLater =
      '종이의 복구 코드는 확인했지만 서버 등록을 마치지 못했습니다 — 잠시 뒤 «등록 다시 시도»를 누르십시오.';
}

/// 열린 ⑤ 의 카드 줄(🔴 [code] = 이 줄에만 · 다른 문자열에 싣지 않는다) — [reissued] = 앞 카드가 거부돼 새로 냈다.
List<String> recoveryCardIssueLines(String code, {bool reissued = false}) =>
    <String>[
      if (reissued) RecoveryCardTexts.reissuedLine,
      '복구 코드: $code',
      '준비 때 종이에 적어 둔 프로젝트 ref · 계정 이메일 · 데이터 저장소 주소를 이 코드와 함께 복구 카드에 손으로 옮겨 적으십시오. 공개 키는 적지 않습니다.',
      '종이에만 적으십시오 — 사진 · 캡처 · 메모 앱에 남기지 않습니다.',
      '확인을 마치기 전에 앱을 닫으면 새 코드가 나옵니다 — 그때는 이 종이를 버리십시오.',
    ];

/// 결과 → 문장(엔진).
String firstClaimResultText(FirstClaimOutcome o) => switch (o) {
  FirstClaimOutcome.claimed => RecoveryCardTexts.claimed,
  FirstClaimOutcome.existingCard => RecoveryCardTexts.existing,
  FirstClaimOutcome.mismatch => RecoveryCardTexts.mismatch,
  FirstClaimOutcome.noCard => RecoveryCardTexts.noCard,
  FirstClaimOutcome.heldByOther => RecoveryCardTexts.heldByOther,
  FirstClaimOutcome.refused => RecoveryCardTexts.refused,
  FirstClaimOutcome.notConnected => RecoveryCardTexts.notConnected,
  FirstClaimOutcome.retryLater => RecoveryCardTexts.retryLater,
};
