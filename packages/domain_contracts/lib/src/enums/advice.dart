// 01 §2-1(X7 신규 열거형) · §3-7(계절 진입 게이트) · §4-2 — 안내·기록·전환 축(인벤토리 §2-12).
//
// ✅ X7 13종은 `m2-8_naming.md` A-5 로 확정됐다 — 「X7 확정 식별자 목록 ③ 의 이름을 그대로
//    쓰고 이후 바꾸지 않는다」.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-1 · `advice.status` CHECK — 안내 1건의 생애.
///
/// 🔴 terminal 4종(`filled`·`skipped`·`expired`·`superseded`)과 `revoked` 는 **어떤 경로로도
///    되살아나지 않는다**(X2 원칙 ①과 동형). 전이 이력은 `advice_transition` 에 병행 append.
/// 🔴 저장값 `status` 는 배지·정렬에 쓰지 않는다 — 화면이 쓰는 유일한 값은
///    `AdviceItem.effectiveStatus` 다.
enum AdviceStatus {
  @JsonValue('OPEN')
  open('OPEN'),
  @JsonValue('PARTIAL')
  partial('PARTIAL'),
  @JsonValue('FILLED')
  filled('FILLED'),
  @JsonValue('SKIPPED')
  skipped('SKIPPED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('SUPERSEDED')
  superseded('SUPERSEDED'),
  @JsonValue('REVOKED')
  revoked('REVOKED');

  const AdviceStatus(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-1(G-08) · `advice.kind` CHECK.
///
/// `decision_log.kind` 와 같은 갈래 + `funding`(v2.32 `PENSION_FUNDING` 조달 단계 · §3-6).
/// 🔴 `noAction` — «오늘은 아무것도 하지 마십시오»(suppressed)와 «믿을 수 없는 원장의 방어
///    안내»를 표현하지 못하면 억제된 날의 홈 블록 3b·`J-1` 배지가 통째로 사라지고(C14),
///    그 침묵이 「엔진이 죽었다」와 구별되지 않는다.
/// 🔴 이 값이 붙은 행의 NULL 허용 범위는 §6-6 `advice` DDL 조문이 정한다(둘뿐이다).
enum AdviceKind {
  @JsonValue('ENTRY')
  entry('ENTRY'),
  @JsonValue('EXIT')
  exit('EXIT'),
  @JsonValue('REBALANCE')
  rebalance('REBALANCE'),
  @JsonValue('DEPOSIT')
  deposit('DEPOSIT'),
  @JsonValue('WITHDRAWAL')
  withdrawal('WITHDRAWAL'),
  @JsonValue('FUNDING')
  funding('FUNDING'),
  @JsonValue('NO_ACTION')
  noAction('NO_ACTION');

  const AdviceKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 — 사람이 «건너뜀»을 고를 때의 사유.
///
/// 🔴 자유 서술 거부(§3-4 X5 원인 코드 원칙 준용). `other` 를 고르면 1줄이 필수다.
/// 🔴 «유효기한 방치»는 **여기 없다** — 사람이 고르는 값이 아니라 엔진이 부여하는 전이다.
/// 🔴 `note` 가 필수인 것은 예산 코드 2종과 `other` 뿐이다(01 §5-4 `AdviceSkip` 조문).
enum AdviceSkipReason {
  @JsonValue('PRICE_UNACCEPTABLE')
  priceUnacceptable('PRICE_UNACCEPTABLE'),
  @JsonValue('CASH_SHORT')
  cashShort('CASH_SHORT'),
  @JsonValue('INTENTIONAL_PAUSE')
  intentionalPause('INTENTIONAL_PAUSE'),
  @JsonValue('BROKER_ISSUE')
  brokerIssue('BROKER_ISSUE'),
  @JsonValue('MISISSUED')
  misissued('MISISSUED'),
  @JsonValue('OTHER')
  other('OTHER');

  const AdviceSkipReason(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1(A8) — 버튼 노출·비활성의 **유일한** 근거.
/// 🔴 화면은 `status`·`onHold`·`suppressed` 를 조합해 버튼을 만들지 않는다(C-18).
///
/// ⚠️ 인벤토리 §2-12 는 이 열거형을 «뷰모델 전용 · JSON 표기 없음»(대응 DB 컬럼 없음)으로
///    적었다. 그래도 `@JsonValue` 를 붙이는 이유는 픽스처가 JSON 이고 「자동 변환 0건」이
///    규약이기 때문이다(인벤토리 §10-1 영역 A 체크리스트). 🔴 표기는 §1-2 규약대로
///    SCREAMING_SNAKE 이며 픽스처도 이 표기를 쓴다.
/// ✅ `deferConfirm` 흡수 여부는 `m2-8_naming.md` A-16 이 **3값 유지**로 확정했다 —
///    「내일 다시」는 `AdviceItem.deferAvailable`(bool) 필드로 남는다.
enum AdviceActionId {
  @JsonValue('RECORD')
  record('RECORD'),
  @JsonValue('SKIP')
  skip('SKIP'),
  @JsonValue('DETAIL')
  detail('DETAIL');

  const AdviceActionId(this.wire);

  /// JSON 표기(DDL 대응 컬럼 없음).
  final String wire;
}

/// 01 §2-1 · `rm_holding.scope` — «관리 대상»과 «시스템 밖 자산»을 한 목록에 섞지 않게 한다.
/// 🔴 `external` 행의 표시 UNION 은 `HoldingsRepository` **한 곳**에서만 만든다(C-23).
enum HoldingScope {
  @JsonValue('MANAGED')
  managed('MANAGED'),
  @JsonValue('EXTERNAL')
  external('EXTERNAL');

  const HoldingScope(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 · `handover_session.path` CHECK — 집행 주체 전환 위저드(`M5-11`)의 진입 상태.
/// 🔴 «안내 개시»는 여기 없다 — 별도 게이트 `M5-10` 이다.
enum HandoverPath {
  @JsonValue('SIM_TO_AUTO')
  simToAuto('SIM_TO_AUTO'),
  @JsonValue('FRESH_AUTO')
  freshAuto('FRESH_AUTO'),
  @JsonValue('ADOPT_LEDGER')
  adoptLedger('ADOPT_LEDGER'),
  @JsonValue('HANDBACK_MANUAL')
  handbackManual('HANDBACK_MANUAL');

  const HandoverPath(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 · `credential_registry.usage` CHECK — 키의 사용 범위.
/// 🔴 브로커가 주는 속성이 아니라 **앱 측 런타임 봉인 선언**이다(§9-3 「키 봉인」 재사용).
enum CredentialUse {
  @JsonValue('RECONCILE_ONLY')
  reconcileOnly('RECONCILE_ONLY'),
  @JsonValue('FULL')
  full('FULL');

  const CredentialUse(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §4-2(N-2) — 원장 실사의 목적. `m2-8_naming.md` A-10 확정.
///
/// 🔴 **기본값을 두지 않는다** — 목적이 없으면 엔진이 세 규약(세션 밖 제출 거부 ·
///    `lines` 전 종목 필수 · `ledger_diff` 개시)을 어디에 걸지 모른다.
/// 🔴 `simOpening` 의 완화 3가지는 `periodicAudit` 에 **하나도** 적용되지 않는다.
enum SelfReportPurpose {
  @JsonValue('PERIODIC_AUDIT')
  periodicAudit('PERIODIC_AUDIT'),
  @JsonValue('SIM_OPENING')
  simOpening('SIM_OPENING');

  const SelfReportPurpose(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §3-7(P 회차) — 슬리브 A 계절 진입 게이트의 상태. `m2-8_naming.md` A-8 확정.
///
/// 🔴 **상태 5 : 사유 코드 3 의 비대칭을 화면이 분기로 메우지 않는다** — 화면은 상태값으로
///    색·배지만 고르고 문구는 전부 `label` 을 쓴다.
///    (`octPassed` = ⏸ `F1_ENTRY_OK` · `deferredToNov`·`deferredToDec` = `F1_ENTRY_DEFER` ·
///     `enteredInNov`·`forcedEntryDec` = `F1_ENTRY_LATE`)
/// 🔴 임계값과 보류 상한을 화면·계약에 상수로 적지 않는다 — 엔진 config 키를 읽어 문자열로 받는다.
enum SeasonalEntryGateState {
  @JsonValue('OCT_PASSED')
  octPassed('OCT_PASSED'),
  @JsonValue('DEFERRED_TO_NOV')
  deferredToNov('DEFERRED_TO_NOV'),
  @JsonValue('ENTERED_IN_NOV')
  enteredInNov('ENTERED_IN_NOV'),
  @JsonValue('DEFERRED_TO_DEC')
  deferredToDec('DEFERRED_TO_DEC'),
  @JsonValue('FORCED_ENTRY_DEC')
  forcedEntryDec('FORCED_ENTRY_DEC');

  const SeasonalEntryGateState(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
