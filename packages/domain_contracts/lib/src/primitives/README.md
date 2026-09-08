# `lib/src/primitives/` — 값 객체

정본: 01_M2_도메인계약 **§1-2 금액 · §1-3 시각·날짜·신선도 · §2-1 봉투·구간** · `docs/contracts_inventory.md` §1

| 파일 | 담는 것 |
|---|---|
| `money.dart` | `Currency` · `Money`(⚠️ 예약 타입 — 1차 릴리스 DTO에서는 쓰지 않는다) · `Ratio` · `TradeDate` · `Clock` · `DecimalStringConverter` · `DurationSecondsConverter` · `RatioConverter` · `TradeDateConverter` |
| `converters.dart` | 🔴 **선언 없음** — 위 컨버터 4종의 재수출 창구다(`docs/toolchain_notes.md` §3-3 이 부르는 경로) |
| `as_of.dart` | `AsOfSource` · `AsOf`(`label`·`staleLabel` 포함) · `TzInstant` |
| `list_result.dart` | `ListResult<T>` — 🔴 `fromJson` 없음(봉투 조립은 영역 F 로더가 한다) |
| `date_range.dart` | `DateRange` |

## 이 폴더가 지는 규칙

- 🔴 **금액의 유일한 생성 경로는 문자열이다.** `Decimal.fromDouble` / `Decimal.parse(d.toString())` 우회 금지. JSON도 문자열(`"38250.00"`)이며 숫자 리터럴은 C-8이 잡는다.
  - ⚠️ decimal 3.x는 값을 정규화한다 — 값 왕복은 안전하지만 **문자열 왕복은 보장되지 않는다**(`toolchain_notes` §4-1). 픽스처의 금액 문자열은 정규형으로 적는다.
- 🔴 **`TradeDate`에 날짜 산술이 없다.** «다음 거래일»·«D-6»은 거래소 캘린더를 아는 엔진만 판정한다.
- 🔴 **`Ratio`·`TradeDate`(extension type)에는 컨버터가 반드시 붙는다** — json_serializable이 대표 타입으로 자동으로 풀어 주지 않는다(`@RatioConverter()`·`@TradeDateConverter()`를 필드에 직접).
- 🔴 **화면이 현재 시각을 쓰는 자리는 전 앱에서 하나뿐이다** — `observedAt + staleAfter < clock.nowUtc()`(신선도 배너). 카운트다운·경과·D-day·TTL 잔여는 엔진이 문자열로 준다.
- 🔴 **신뢰 시각은 Supabase 서버 시각이다**(리스 TTL·킬스위치 48h·냉각 30일). 폰 시계로 마찰을 계산하지 않는다.
- 🔴 **`AsOfStamp`라는 타입은 실재하지 않는다** — 화면 명세들의 «기준일 고지»는 전부 `AsOf` 하나이며 표시 문구는 `label`이다.
