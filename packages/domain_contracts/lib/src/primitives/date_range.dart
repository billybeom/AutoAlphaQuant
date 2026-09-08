// 01 §2-1 «조회 구간» 원문.
//
// 🔴 화면이 날짜 산술로 만들지 않는다 — 프리셋의 창구는
//    `ConfigRepository.watchRangePresets()` **하나**다(G-38 · 01 §4-1).
//    화면이 `presetCode` 문자열을 코드에 나열하거나 `DateTime` 산술로 from·to 를 만들지 않는다.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';

part 'date_range.freezed.dart';
part 'date_range.g.dart';

@freezed
abstract class DateRange with _$DateRange {
  const factory DateRange({
    @TradeDateConverter() required TradeDate from,
    @TradeDateConverter() required TradeDate to,

    /// 엔진이 준 프리셋의 식별자. 화면이 값을 나열하지 않는다.
    String? presetCode,

    /// 「최근 30일」 — 엔진 생성(01 §1-5).
    String? label,
  }) = _DateRange;

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);
}
