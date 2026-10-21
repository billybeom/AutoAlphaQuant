// 01 §3-4 — X5 대사·정합 원인 코드 20종 (🔴 자유 서술 거부).
//
// 소비처: `trading_block.origin_code`(RECON_MISMATCH 전용) · `ledger_diff.origin_code` ·
//        `ledger_repair.origin_code` · `LedgerDiffRow.candidateOriginCodes` · `BlockFlag.originCode`.
// 🔴 `reasonCode` 는 자유 서술을 거부한다 — `note` 는 그 위의 한 줄이지 사유 코드의 대체가 아니다.

/// X5 대사·정합 원인 코드(01 §3-4).
abstract final class OriginCodes {
  // ── 브로커 계열 7 (04 §3-5 기존 4 + X2·X5 확장) ────────────────────────────
  /// 체결 보고 지연.
  static const String fillLag = 'FILL_LAG';

  /// 수동 주문. ⚠️ 이 코드로 해제하면 **저널과 SEV2 postmortem(7일)이 동시에 열린다**(04 §3-5) —
  /// 화면은 이 분기를 만들지 말고 정정 마법사(M5)로 넘긴다.
  static const String manualOrder = 'MANUAL_ORDER';

  /// 로컬 DB 오류.
  static const String dbError = 'DB_ERROR';

  /// 브로커 API 오류.
  static const String brokerError = 'BROKER_ERROR';

  /// 시스템 밖 입출금.
  static const String externalCashflow = 'EXTERNAL_CASHFLOW';

  /// 기업행위. 🔴 X2 계열이 먼저 등재된 이름이며 **픽스처·신규 코드는 이 이름만 쓴다**.
  static const String corporateAction = 'CORPORATE_ACTION';

  /// 기업행위(X5 계열의 옛 표기). ✅ **`corporateAction` 으로 통합됐다**(계약 v1.9.0 · 01 §8-6 ·
  /// 인벤토리 §10-2 ③ 해소) — 옛 기록을 읽기 위한 **상수로만** 남고 픽스처·신규 코드에 쓰지 않는다.
  static const String corpActionLegacy = 'CORP_ACTION';

  // ── 파생 계열 7 (X5 신설) ─────────────────────────────────────────────────
  /// Supabase push 지연.
  static const String pushLag = 'PUSH_LAG';

  /// Supabase push 실패.
  static const String pushFailed = 'PUSH_FAILED';

  /// GitHub 아카이브 적체.
  static const String archiveLag = 'ARCHIVE_LAG';

  /// 캘린더 쓰기 실패.
  static const String calWriteFailed = 'CAL_WRITE_FAILED';

  /// 스키마 어긋남.
  static const String schemaSkew = 'SCHEMA_SKEW';

  /// 해시 체인 단절.
  static const String chainBroken = 'CHAIN_BROKEN';

  /// 복원 롤백.
  static const String restoreRollback = 'RESTORE_ROLLBACK';

  // ── X7 계열 6 (01 §10) ────────────────────────────────────────────────────
  /// 🔴 안내 모드의 **정상** 수기 체결. 이 코드가 없으면 advisory 의 모든 체결이
  /// `MANUAL_ORDER` 로 들어가 「저널 + SEV2 postmortem 7일」을 매일 연다(경보 피로 규칙 정면 위반).
  static const String advisoryFill = 'ADVISORY_FILL';

  /// 체결이 있었는데 기록되지 않음.
  static const String unrecordedFill = 'UNRECORDED_FILL';

  /// 잘못 기록된 체결. 🔴 소급 정정이 `ledger_repair(direction='DERIVED_RESYNC')` 1행을
  /// 낳는 원인 코드다(C-29).
  static const String misrecordedFill = 'MISRECORDED_FILL';

  /// 원장 실사(자가보고)에서 나온 정정.
  static const String selfReportCorrection = 'SELF_REPORT_CORRECTION';

  /// 시스템 밖 자산.
  static const String externalHolding = 'EXTERNAL_HOLDING';

  /// 🔴 D11 — 대사 키가 있으면 계좌별 잔고 대조로 교차검증하고, 불일치는
  /// `SELF_REPORT_CORRECTION` 이 아니라 **이 코드**로 `ledger_diff` 를 연다.
  static const String accountMisdeclared = 'ACCOUNT_MISDECLARED';

  /// 브로커 계열 7종.
  static const Set<String> broker = <String>{
    fillLag,
    manualOrder,
    dbError,
    brokerError,
    externalCashflow,
    corporateAction,
    corpActionLegacy,
  };

  /// 파생 계열 7종.
  static const Set<String> derived = <String>{
    pushLag,
    pushFailed,
    archiveLag,
    calWriteFailed,
    schemaSkew,
    chainBroken,
    restoreRollback,
  };

  /// X7 계열 6종.
  static const Set<String> x7 = <String>{
    advisoryFill,
    unrecordedFill,
    misrecordedFill,
    selfReportCorrection,
    externalHolding,
    accountMisdeclared,
  };

  /// 전량 20종.
  static const Set<String> values = <String>{...broker, ...derived, ...x7};

  /// 픽스처·신규 코드가 쓸 수 있는 것 — 옛 표기 `CORP_ACTION` 을 뺀 19종.
  ///
  /// ✅ 인벤토리 §10-2 ③ 해소(계약 v1.9.0) — 쓰는 이름은 `CORPORATE_ACTION` 하나다.
  static const Set<String> writable = <String>{
    fillLag,
    manualOrder,
    dbError,
    brokerError,
    externalCashflow,
    corporateAction,
    ...derived,
    ...x7,
  };
}
