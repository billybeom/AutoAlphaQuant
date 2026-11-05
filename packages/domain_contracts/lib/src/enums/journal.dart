// 01 §2-2 «TradeJournalEntry» · §2-1(X7) — 일지·체결 축(인벤토리 §2-4).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-2 — 체결 1행의 상태.
///
/// 🔴 `reversed`·`restated` 는 X7 §10-3 정정 규약(역분개 + 재기재)이다.
/// 🔴 `prevented` = «이중 발주 차단 작동» 이며 **성공으로 렌더**한다.
///    `unknown` 은 UNKNOWN 해소 보드로 딥링크한다.
/// 🔴 C-12(`default:` 없는 망라 switch)가 전 화면을 동시에 깨뜨리는 것이 **의도된 게이트**다.
/// 🆕 v1.17(엔진 D11 · 13 §8 R33 D5 · 04_안전장치 §3-1 ③) — `expired` = 일 마감 실효(🔴 취소 아님 · 잔량 = 다음 거래일 의도로 이월 · 근거 칩 `JournalReasonCodes.dayEndExpired`).
enum JournalStatus {
  @JsonValue('FILLED')
  filled('FILLED'),
  @JsonValue('PARTIAL')
  partial('PARTIAL'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('UNKNOWN')
  unknown('UNKNOWN'),
  @JsonValue('SKIPPED')
  skipped('SKIPPED'),
  @JsonValue('PREVENTED')
  prevented('PREVENTED'),
  @JsonValue('REVERSED')
  reversed('REVERSED'),
  @JsonValue('RESTATED')
  restated('RESTATED');

  const JournalStatus(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-2 — 「체결 → 표시 as-of 계약」의 3상태(청사진 §9-2).
/// ✅ `m2-8_naming.md` A-1 로 초안 지위 해제 — 값은 01 §2-2 원문 3값 그대로다.
enum FillVisibility {
  @JsonValue('SETTLED')
  settled('SETTLED'),
  @JsonValue('PENDING_BATCH')
  pendingBatch('PENDING_BATCH'),
  @JsonValue('AWAITING_CONFIRM')
  awaitingConfirm('AWAITING_CONFIRM');

  const FillVisibility(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 01 §2-1(X7) · `executions.fill_origin` CHECK — 체결 1행의 **출처**.
/// 🔴 원장은 한 스트림이고, [FillOrigin]·[FillKind] 두 값이 그 안에서 «누가·무엇을» 말한다.
enum FillOrigin {
  @JsonValue('BROKER')
  broker('BROKER'),
  @JsonValue('MANUAL')
  manual('MANUAL'),
  @JsonValue('SIMULATED')
  simulated('SIMULATED'),
  @JsonValue('BROKER_RECOVERED')
  brokerRecovered('BROKER_RECOVERED');

  const FillOrigin(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1(X7) · `executions.fill_kind` CHECK — 체결 1행의 **성격**.
/// 🔴 정정 1회 = `REVERSAL` + `RESTATEMENT` **2행**이며 UPDATE·DELETE 는 없다(C-21).
enum FillKind {
  @JsonValue('ORIGINAL')
  original('ORIGINAL'),
  @JsonValue('REVERSAL')
  reversal('REVERSAL'),
  @JsonValue('RESTATEMENT')
  restatement('RESTATEMENT');

  const FillKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1(X7 C18) · `executions.cost_source` CHECK — 비용의 출처.
///
/// 🔴 구 `costsOverridden`(bool) 은 **폐기**됐다 — 하나로는 «브로커 확정»과 «엔진 추정»이
///    구별되지 않는다. 추정치를 확정치처럼 그리지 않는다는 원칙을 비용에도 적용한 것이며,
///    `estimated` 배지의 존재는 C-24 가 검사한다.
enum CostSource {
  @JsonValue('BROKER')
  broker('BROKER'),
  @JsonValue('USER_ENTERED')
  userEntered('USER_ENTERED'),
  @JsonValue('ESTIMATED')
  estimated('ESTIMATED');

  const CostSource(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
