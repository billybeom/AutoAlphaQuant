// packages/domain_contracts/lib/src/dto/calendar.dart
//
// 01 §2-8 «CalendarEventDto — X4(화이트리스트 필드만)» + m2-8 D-8(`CalendarSyncStatus`)
// · 인벤토리 §3-5 · §3-14(영역 B).
//
// ⏸ m2-8 J-5 — X4 채택 자체가 미결(01 §8-5, OAuth 동의화면 7일 만료 스모크)이다.
//    **이름·타입은 등재하되 기능(동기·재백필)은 구현하지 않는다.**
// 🔴 **화이트리스트 직렬화** — 블랙리스트 정규식이 아니라 «허용 필드만 있는 타입»으로
//    강제한다. 타입에 아예 없음: 손익·수익률·평가액·잔고·계좌 전체번호·시크릿.
// 🔴 **미래 시각 이벤트를 만들지 않는다**(예정 리밸런싱·월 납입 예정 금지).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/calendar.dart';
import '../primitives/money.dart';

part 'calendar.freezed.dart';
part 'calendar.g.dart';

/// 캘린더 이벤트 1건(01 §2-8).
///
/// `kind ↔ source_table ↔ aaq_key` 매핑 9행은 01 §2-8 표가 정본이다.
/// 🔴 `advice`·`advice_batch`·`self_report_balance` 는 캘린더에 내지 않는다.
/// 🔴 extendedProperties 는 **6키**(`aaq_key`·`kind`·`decision_id`·`origin`·`config_hash`
///    + `chain_hash`) — 타입에 없는 필드는 나갈 수 없다.
@freezed
abstract class CalendarEventDto with _$CalendarEventDto {
  const factory CalendarEventDto({
    /// 'exec.{execution_id}' 등 멱등 원문 키
    required String aaqKey,
    required CalendarEventKind kind,
    required DateTime startUtc,
    DateTime? endUtc,
    required bool allDay,

    /// "체결 · 매수 069500" — 엔진 생성
    required String title,

    /// 수량·체결가·수수료·비중%·사유 코드·계좌 별칭까지만 — 엔진 생성
    required String body,
    required CalendarOrigin origin,
    String? decisionId,
    required String configHash,

    /// 🆕 G-09(X5) — 🔴 `dailySummary`(종일 요약) 이벤트에만 싣는다.
    /// 정본 `ledger_daily_hash.chain_hash` 앞 N자(축약 규칙은 X5-1 정규 직렬화와
    /// **같은 골든벡터**). 🔴 이 한 필드가 `canonCalendar` 대조를 O(1) 로 만든다.
    String? chainHash,
  }) = _CalendarEventDto;

  factory CalendarEventDto.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventDtoFromJson(json);
}

/// 캘린더 동기 상태 — `calendar_sync_status` 컬럼 + G-34(m2-8 D-8).
///
/// 🔴 «사용자 삭제 n건»은 불일치가 아니라 **별도 수치**다(G-34) — 대조 모집단에서
///    빠지며 되살리기는 기간 재배치의 `resurrect` 하나뿐이다.
/// 🔴 `modeCode` 는 캘린더 축의 **계열 2값**(`LIVE`·`SIM`)이며 `RunMode` 3값이 아니다
///    (G-32 · 🔵 v1 은 `LIVE` 행 하나).
@freezed
abstract class CalendarSyncStatus with _$CalendarSyncStatus {
  const factory CalendarSyncStatus({
    required String modeCode,
    @TradeDateConverter() TradeDate? lastOkDate,
    required String statusCode,
    required String statusLabel,
    required int quarantinedCount,
    required int userDeletedCount,
    String? actionDeepLink,
  }) = _CalendarSyncStatus;

  factory CalendarSyncStatus.fromJson(Map<String, dynamic> json) =>
      _$CalendarSyncStatusFromJson(json);
}
