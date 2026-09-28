// 01 §1-2 «금액 — Decimal 문자열 승격» · §1-3 «시각·날짜·신선도»의 원시타입 원문.
// 🔴 이름·필드·규약은 01 §1-2 가 정본이고, **클래스 선언 문법만** freezed 4 로 바꿔 읽는다
//    (docs/toolchain_notes.md §3-1 — 01 의 코드 예시는 freezed 2.x 문법이다).
// 🔴 이 파일에는 산술이 없다. `domain_contracts` 안에 Decimal 산술이 등장하면
//    그 자체가 설계 오류 신호다(toolchain_notes §4-2 말미 · 01 §1-2 규약 5조 말미).
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';
part 'money.g.dart';

/// 01 §1-2 — 통화 축.
///
/// 🔵 v2.31 P0S 1차 자동화는 국내상장 ETF 만이라 전 금액이 KRW 다. 통화가 섞이는 시점
///    (미국 직접주문 부활)에 상위 DTO 의 `currency` 축이 이 값을 싣는다.
enum Currency {
  @JsonValue('KRW')
  krw('KRW'),
  @JsonValue('USD')
  usd('USD');

  const Currency(this.wire);

  /// JSON·DDL 표기(01 §1-2 enum 직렬화 규약). 🔴 바로 위 `@JsonValue` 와 **같은 문자열**이며
  /// 한쪽만 고치지 않는다 — 갈라지면 픽스처·DDL `CHECK` 와 어긋나고 §7 C-15 가 실패한다.
  final String wire;
}

/// ⚠️ **예약 타입 — 1차 릴리스 DTO 에서는 쓰지 않는다**(인벤토리 §1 · 01 §1-2 주석 원문).
///
/// P0S 는 전 금액이 KRW 라 §2 의 금액 필드는 `Decimal` 하나로 쓰고 통화는 상위 DTO
/// (계좌·플랜)의 `currency` 축으로 표현한다. 지금 전면 도입하면 값 객체 한 겹이
/// 화면·픽스처·골든에 그대로 비용으로 남는다.
/// 🔴 화면의 산술 차단은 `Money` 유무가 아니라 §7 C-4(`Decimal` 필드까지 탐지)가 한다.
@freezed
abstract class Money with _$Money {
  // 🔴 이름 있는 factory 를 두므로 private 생성자가 필수다(toolchain_notes §3-1 규칙 3).
  const Money._();

  const factory Money({
    @DecimalStringConverter() required Decimal amount,
    required Currency currency,
  }) = _Money;

  /// 🔴 유일한 생성 경로는 **문자열**이다.
  /// `Decimal.fromDouble` / `Decimal.parse(d.toString())` 우회 금지(01 §1-2).
  factory Money.krw(String v) =>
      Money(amount: Decimal.parse(v), currency: Currency.krw);

  factory Money.usd(String v) =>
      Money(amount: Decimal.parse(v), currency: Currency.usd);

  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);
}

/// 01 §1-2 — 비율·스코어는 `double`.
/// 🔴 산술 연산자를 정의하지 않는다(인벤토리 §1) — 정의하는 순간 화면이 비율을 곱할 수 있게 된다.
extension type const Ratio(double value) {}

/// 01 §1-2 — 해당 시장 **현지** 거래일 `'YYYY-MM-DD'`(US 는 ET · KST 환산 금지).
/// 🔴 **날짜 산술 없음** — 「다음 거래일」·「D-6」 은 거래소 캘린더를 아는 엔진만 판정한다(M1-6).
extension type const TradeDate(String yyyyMmDd) {}

/// 01 §1-2·§1-3 — 화면이 `DateTime.now()` 를 부르지 않게 하는 유일한 통로.
/// 구현체 주입은 `data_sync`.
///
/// 🔴 화면이 이 값을 쓰는 자리는 **둘이다**(🆕 v1.3 · 01 §13-6) —
///    ① 신선도 비교 `observedAt + staleAfter < clock.nowUtc()`(신선도 배너)
///    ② 명령 페이로드의 관측 시각(`DisclosureViewEvent.viewedAt`) — 판정이 아니며
///       집계 월은 엔진이 접수·서버 시각으로 확정한다.
///    카운트다운·경과·D-day·TTL 잔여는 엔진이 문자열 필드로 준다.
/// 🔴 신뢰 시각(리스 TTL·킬스위치 48h·냉각 30일)은 **Supabase 서버 시각**이다.
///    로컬 시계로 마찰 카운트다운을 만들지 않는다.
abstract interface class Clock {
  DateTime nowUtc();
}

/// 01 §1-2 — 금액의 JSON 표기는 **문자열**이다(`"38250.00"`). 숫자로 쓰면 파서가 double 로 읽어
/// 정밀도가 날아간다.
///
/// 🔴 **필드 어노테이션이다** — 메서드 인자에 붙여도 아무 일도 하지 않는다(01 §4-2 조문).
///    그래서 인자가 2개를 넘는 명령은 전부 DTO 로 받는다.
/// ⚠️ decimal 3.x 는 값을 정규화한다 — `Decimal.parse('38250.00').toString() == '38250'`.
///    값 왕복(`fromJson(toJson(d)) == d`)은 안전하지만 **문자열 왕복은 보장되지 않는다**
///    (toolchain_notes §4-1). 픽스처의 금액 문자열은 정규형으로 적는다.
/// 🔴 표시용 자릿수는 컨버터의 일이 아니다 — 화면 문자열은 전부 엔진 완성 문자열이다(01 §1-5).
class DecimalStringConverter implements JsonConverter<Decimal, String> {
  const DecimalStringConverter();

  @override
  Decimal fromJson(String s) => Decimal.parse(s);

  @override
  String toJson(Decimal d) => d.toString();
}

/// 01 §1-2 — `Duration` 의 JSON 표기는 **초(int)** 이고 키는 `*_seconds` 다.
/// 키 이름은 필드마다 `@JsonKey(name: '..._seconds')` 로 직접 적는다
/// (build.yaml 의 `field_rename: snake` 는 `_seconds` 접미를 붙여 주지 않는다).
class DurationSecondsConverter implements JsonConverter<Duration, int> {
  const DurationSecondsConverter();

  @override
  Duration fromJson(int s) => Duration(seconds: s);

  @override
  int toJson(Duration d) => d.inSeconds;
}

/// docs/toolchain_notes.md §3-3 — 🔴 extension type 에는 컨버터가 **반드시** 필요하다.
/// json_serializable 은 extension type 을 대표 타입(double)으로 자동으로 풀어 주지 않는다 —
/// 애너테이션 없이 두면 «cannot handle» 로 생성이 실패한다.
class RatioConverter implements JsonConverter<Ratio, double> {
  const RatioConverter();

  @override
  Ratio fromJson(double v) => Ratio(v);

  @override
  double toJson(Ratio r) => r.value;
}

/// docs/toolchain_notes.md §3-3 — `TradeDate` 의 대표 타입(String) 풀이.
class TradeDateConverter implements JsonConverter<TradeDate, String> {
  const TradeDateConverter();

  @override
  TradeDate fromJson(String s) => TradeDate(s);

  @override
  String toJson(TradeDate d) => d.yyyyMmDd;
}
