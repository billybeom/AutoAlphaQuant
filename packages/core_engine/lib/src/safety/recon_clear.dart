// 🆕 E11q-c4 — M5-5 차단 보드 RECON 해제 폼 · 판정 · 결과 글자(설계 13 §8 R189 · 01 §35 K180~K182 · 미결 206 RECON 몫 ·
// 표본 `m5/block_board_recon_mismatch` · `m5/recon_clear_results`).
//
// 🔴 선택지 = 엔진 쓰기 화이트리스트(`writableOriginCodesFor(canonBroker)`) ∩ 해제 원인 코드(`kReconClearOriginCodes`) ∩ 자동 갈래
//    (브로커 계열 — X7 계열 = 안내 갈래 몫 · 옛 `CORP_ACTION` 뺌) · 차례 = 계약 `OriginCodes.broker` 차례 · 글자 = `kOriginLabels`.
// 🔴 판정 차례 = 막힘 없음 → 원인 코드(선택지 밖) → 저널 세 칸 → 저널 id 겹침 — 상태가 먼저(킬스위치 재개 · 규칙 변경 요청 선례).
//    판정은 원장 트랜잭션 안에서 부른다(data_sync `clearReconWithJournal`).
// 🔴 신뢰 시각 비의존(K181 — 해제 = 막는 쪽을 푸는 사람 결정 · 시각 = 기기 시계) · 확인 대화 0 · 생체 = 구현(미결 169).
// 🔵 엔진 글자(미결 203 결) = 계약 표본이 제안한 문장(«(합성)» 표지 뗌 · 발주자 위임 — 권고대로).

import 'package:domain_contracts/domain_contracts.dart'
    show
        LedgerPair,
        OriginCodes,
        ReconClearForm,
        ReconClearResultCodes,
        ReconOriginChoice,
        SafetyActionId,
        SafetyActionResult,
        SafetyCommonResultCodes,
        SettingsResultCodes,
        UiLevel;

import '../ops/ledger_views.dart' show kOriginLabels;
import '../orders/ledger_pairs.dart' show writableOriginCodesFor;
import '../orders/reconcile.dart' show kReconClearOriginCodes;

/// RECON 해제 글자(표본 제안 문장 · 엔진 사전 밖 몫).
abstract final class ReconClearTexts {
  /// 폼 고지.
  static const String notice = '해제는 결정 저널과 함께 기록됩니다 — 주문을 내지 않습니다';

  /// 결과 — 풀었다.
  static const String cleared = '대사 불일치 표시를 풀었습니다 — 결정 저널이 함께 남았습니다.';

  /// 결과 — 풀 것이 없다.
  static const String notBlocked = '풀 대사 불일치 표시가 없습니다.';

  /// 결과 — 선택지 밖 원인 코드.
  static const String originNotAllowed = '이 원인 코드로는 풀 수 없습니다.';

  /// 결과 — 저널 세 칸 빈칸.
  static const String journalMissing = '결정 저널 세 칸을 채워 주십시오.';

  /// 결과 — 저널 번호 겹침.
  static const String journalIdTaken = '같은 저널 번호가 이미 있어 풀지 않았습니다.';

  /// 결과 — 생체 확인 불가.
  static const String biometric = '생체 확인을 할 수 없어 진행하지 않았습니다.';
}

/// 자동 갈래 해제 선택지(차례 = 계약 `OriginCodes.broker` · 쓰기 화이트리스트 ∩ 해제 원인 코드).
final List<String> kReconClearChoiceCodes = List<String>.unmodifiable(<String>[
  for (final String c in OriginCodes.broker)
    if (writableOriginCodesFor(LedgerPair.canonBroker).contains(c) &&
        kReconClearOriginCodes.contains(c))
      c,
]);

/// RECON 행 해제 폼(보드 행 `reconClear` — 쓰기 창구 ∧ 잠김 아님일 때만 붙인다).
ReconClearForm reconClearFormOf() => ReconClearForm(
  choices: <ReconOriginChoice>[
    for (final String c in kReconClearChoiceCodes)
      ReconOriginChoice(originCode: c, label: kOriginLabels[c]!),
  ],
  noticeText: ReconClearTexts.notice,
);

/// 해제 거부 코드 — null = 해제한다. [blocked] = RECON_MISMATCH 가 서 있나 · [journalIdTaken] = 새 저널 id 가 이미 있나.
String? reconClearRejectCode({
  required bool blocked,
  required String originCode,
  required String rationaleBefore,
  required String expectedOutcome,
  required String ruleCited,
  required bool journalIdTaken,
}) {
  if (!blocked) return ReconClearResultCodes.notBlocked;
  if (!kReconClearChoiceCodes.contains(originCode)) {
    return ReconClearResultCodes.originNotAllowed;
  }
  if (rationaleBefore.trim().isEmpty ||
      expectedOutcome.trim().isEmpty ||
      ruleCited.trim().isEmpty) {
    return ReconClearResultCodes.journalMissing;
  }
  if (journalIdTaken) return SafetyCommonResultCodes.journalIdTaken;
  return null;
}

/// RECON 해제 결과 — [code] null = 풀었다 · 글자 = 엔진(표본 제안 문장) · 모르는 코드 = [ArgumentError].
SafetyActionResult reconClearActionResultOf({
  required String actionRunId,
  String? code,
}) {
  final (UiLevel level, String headline) = switch (code) {
    null => (UiLevel.ok, ReconClearTexts.cleared),
    ReconClearResultCodes.notBlocked => (
      UiLevel.info,
      ReconClearTexts.notBlocked,
    ),
    ReconClearResultCodes.originNotAllowed => (
      UiLevel.blocked,
      ReconClearTexts.originNotAllowed,
    ),
    ReconClearResultCodes.journalMissing => (
      UiLevel.act,
      ReconClearTexts.journalMissing,
    ),
    SafetyCommonResultCodes.journalIdTaken => (
      UiLevel.blocked,
      ReconClearTexts.journalIdTaken,
    ),
    SettingsResultCodes.biometricUnavailable => (
      UiLevel.blocked,
      ReconClearTexts.biometric,
    ),
    final String other => throw ArgumentError.value(
      other,
      'code',
      '모르는 RECON 해제 거부 코드',
    ),
  };
  return SafetyActionResult(
    actionRunId: actionRunId,
    id: SafetyActionId.reconClear,
    level: level,
    headline: headline,
    reasonCode: code,
    retryable: false,
  );
}
