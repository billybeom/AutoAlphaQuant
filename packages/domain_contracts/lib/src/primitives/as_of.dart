// 01 §1-3 «시각·날짜·신선도» 원문.
//
// 🔴 화면 명세들이 부르는 «`AsOfStamp`»·«기준일 고지»는 전부 **이 `AsOf` 하나**이며
//    표시 문구는 `label` 이다. 별도 타입은 실재하지 않는다(01 §1-3 · 인벤토리 §1).
// 🔴 UTC `DateTime` 필드는 정렬·비교용이지 표시용이 아니다. 화면이 시각을 포맷하는 자리는
//    `TzInstant` 가 실린 필드뿐이다.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';

part 'as_of.freezed.dart';
part 'as_of.g.dart';

/// 01 §1-3 — 이 값이 어디서 왔는가.
/// 🔵 viewer 의 «엔진이 멈췄다» 는 push 된 상태값이 아니라 `observedAt` 신선도에서 **파생**한다
///    (계약 3조 ② · 청사진 X2 규칙) — 죽은 엔진은 「나 죽었다」를 보내 주지 않는다.
enum AsOfSource {
  @JsonValue('LOCAL_SQLITE')
  localSqlite('LOCAL_SQLITE'),
  @JsonValue('SUPABASE_MIRROR')
  supabaseMirror('SUPABASE_MIRROR'),
  @JsonValue('ARCHIVE')
  archive('ARCHIVE');

  const AsOfSource(this.wire);

  /// JSON·DDL 표기(01 §1-2). 🔴 바로 위 `@JsonValue` 와 같은 문자열이다.
  final String wire;
}

/// 01 §1-3 — 기준일 고지. 🔴 **빈 목록에도 실려 온다**(계약 3조 ③).
@freezed
abstract class AsOf with _$AsOf {
  const factory AsOf({
    /// UTC — 이 값이 만들어진 시각(정렬·신선도 판정용).
    required DateTime observedAt,

    /// 어느 거래일 기준인가.
    @TradeDateConverter() required TradeDate tradeDate,

    required AsOfSource source,

    /// 초과 시 「오래된 데이터」 배너(M4 신선도 계약).
    /// 🔴 JSON 키는 `stale_after_seconds` 다(01 §1-2 · §5 봉투 예시).
    @JsonKey(name: 'stale_after_seconds')
    @DurationSecondsConverter()
    required Duration staleAfter,

    /// 화면에 그대로 찍는 기준일 고지 문구 — **엔진 생성**(01 §1-5).
    /// 「잔고 기준 2026-09-05 종가」 · 「체결 반영 09:12」.
    required String label,

    /// 이미 stale 이면 그 사유 코드(문구는 01 §3 매핑 사전).
    /// ⚠️ 값 목록은 **엔진(M1) 확정 대기**다 — `m2-8_naming.md` A-2 의 권고 4값
    ///    (`ENGINE_DOWN`·`PUSH_LAG`·`BATCH_MISSING`·`CLOCK_SKEW`)은 역산이며 ⏸ 다.
    ///    🔴 그래서 이 필드는 열거형이 아니라 String 이다 — 화면이 코드→문구 매핑을 만들지 않는다.
    String? staleReasonCode,

    /// 그 사유의 배너 문구 — 엔진 생성.
    String? staleLabel,
  }) = _AsOf;

  factory AsOf.fromJson(Map<String, dynamic> json) => _$AsOfFromJson(json);
}

/// 01 §1-3 — 화면이 포맷해도 되는 **유일한** 시각 표현.
/// 화면은 `tzName` 으로만 포맷한다(⚠️ 표시 구현은 `package:timezone` · 이 패키지 밖).
@freezed
abstract class TzInstant with _$TzInstant {
  const factory TzInstant({
    required DateTime utc,
    @Default('Asia/Seoul') String tzName,
  }) = _TzInstant;

  factory TzInstant.fromJson(Map<String, dynamic> json) =>
      _$TzInstantFromJson(json);
}
