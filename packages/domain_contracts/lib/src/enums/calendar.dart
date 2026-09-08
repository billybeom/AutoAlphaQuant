// 01 §2-8 «X4 캘린더» 축(인벤토리 §2-8).
//
// ⏸ X4 채택 자체가 미결이다(`m2-8_naming.md` J-5 · 01 §8-5 OAuth 동의화면 7일 만료).
//    🔴 **이름·타입은 등재하되 기능을 구현하지 않는다** — 이 파일은 그 등재분이다.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-8 · `calendar_event_log.origin` CHECK(G-28 배치 E 재작성).
/// 🔴 `MANUAL_ENTRY` 가 없으면 수기 체결 이벤트가 `QUARANTINED` 로 빠지고
///    `canonCalendar` 대사가 매일 불일치한다.
enum CalendarOrigin {
  @JsonValue('LIVE')
  live('LIVE'),
  @JsonValue('ARCHIVE')
  archive('ARCHIVE'),
  @JsonValue('BROKER_RECOVERED')
  brokerRecovered('BROKER_RECOVERED'),
  @JsonValue('INFERRED')
  inferred('INFERRED'),
  @JsonValue('MANUAL_ENTRY')
  manualEntry('MANUAL_ENTRY');

  const CalendarOrigin(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-8(C11) — 캘린더 이벤트의 갈래.
///
/// 🔴 정정 2행을 «체결» 3건으로 그리지 않는다 — 캘린더는 앱 밖에서 보는 통로라
///    「내가 3번 샀나」로 읽히고, 그 오인이 이중 매수를 부른다. `canonCalendar` 대사는
///    1:1 이라 감사로도 잡히지 않는다.
enum CalendarEventKind {
  @JsonValue('EXECUTION')
  execution('EXECUTION'),
  @JsonValue('ORDER_ACCEPTED')
  orderAccepted('ORDER_ACCEPTED'),
  @JsonValue('ORDER_REJECTED')
  orderRejected('ORDER_REJECTED'),
  @JsonValue('ORDER_CANCELLED')
  orderCancelled('ORDER_CANCELLED'),
  @JsonValue('REBALANCE')
  rebalance('REBALANCE'),
  @JsonValue('CASH_FLOW')
  cashFlow('CASH_FLOW'),
  @JsonValue('SAFETY')
  safety('SAFETY'),
  @JsonValue('SYSTEM')
  system('SYSTEM'),
  @JsonValue('DAILY_SUMMARY')
  dailySummary('DAILY_SUMMARY'),
  @JsonValue('ENGINE_DOWN')
  engineDown('ENGINE_DOWN'),
  @JsonValue('EXECUTION_CORRECTION')
  executionCorrection('EXECUTION_CORRECTION');

  const CalendarEventKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
