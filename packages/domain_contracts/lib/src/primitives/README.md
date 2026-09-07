# `lib/src/primitives/` — 값 객체 (G3 예정)

정본: 01_M2_도메인계약 **§1-2 금액 · §1-3 시각·날짜·신선도**

| 예정 파일 | 담을 것 |
|---|---|
| `money.dart` | `Currency` · `Money`(⚠️ 예약 타입 — 1차 릴리스 DTO에서는 쓰지 않는다) · `Ratio` · `TradeDate` · `Clock` · `DecimalStringConverter` · `DurationSecondsConverter` |
| `as_of.dart` | `AsOfSource` · `AsOf`(`label`·`staleLabel` 포함) · `TzInstant` |

## 이 폴더가 지는 규칙

- 🔴 **금액의 유일한 생성 경로는 문자열이다.** `Decimal.fromDouble` / `Decimal.parse(d.toString())` 우회 금지. JSON도 문자열(`"38250.00"`)이며 숫자 리터럴은 C-8이 잡는다.
- 🔴 **`TradeDate`에 날짜 산술이 없다.** «다음 거래일»·«D-6»은 거래소 캘린더를 아는 엔진만 판정한다.
- 🔴 **화면이 현재 시각을 쓰는 자리는 전 앱에서 하나뿐이다** — `observedAt + staleAfter < clock.nowUtc()`(신선도 배너). 카운트다운·경과·D-day·TTL 잔여는 엔진이 문자열로 준다.
- 🔴 **신뢰 시각은 Supabase 서버 시각이다**(리스 TTL·킬스위치 48h·냉각 30일). 폰 시계로 마찰을 계산하지 않는다.
