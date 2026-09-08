# toolchain_notes — domain_contracts 생성기 툴체인 확정본

> **읽는 사람**: `packages/domain_contracts` 에 DTO·픽스처·계약 테스트를 쓰는 사람(G3·G4).
> **이 문서가 하는 일**: 「어떤 버전을 쓰는가」와 「freezed 클래스를 정확히 어떻게 쓰는가」를 한 곳에 못 박는다. 여기 있는 템플릿을 **그대로** 복사해 쓰면 `melos run build:gen` → `melos run analyze --fatal-infos` → `melos run test` 가 통과한다.
> **근거**: 2026-09-08 실측. 임시 프로브 파일 1개를 만들어 실제로 컴파일·생성·분석·테스트한 뒤 지웠다.
> **상태**: `packages/domain_contracts/pubspec.yaml` 과 `packages/domain_contracts/build.yaml` 에 이미 반영돼 있다. 통합 담당이 재검증한다.

---

## §1. 실측 환경

| 항목 | 값 | 확인 방법 |
|---|---|---|
| Dart SDK | **3.13.2** (stable, 2026-08-25) | `dart --version` |
| Flutter | **3.47.2** (stable) | `flutter --version` |
| melos | 전역 8.6.0 / 저장소 안에서는 루트 pubspec의 `^6.0.0` → **6.3.3** (고전 `packages:` 글롭 방식) | SETUP.md §6 실측 기록 |
| 실행 방식 | Git Bash에서 `export PATH="/c/src/flutter/bin:/c/Users/BeomLee/AppData/Local/Pub/Cache/bin:$PATH"; cd "C:/Work/Bob/AutoAlphaQuant" && melos.bat run <script>` | — |

---

## §2. 확정 버전

`dart pub outdated` 의 **Resolvable** 열(= 이 SDK에서 실제로 맞물리는 최신 안정판)을 그대로 채택했다.

### 2-1. `packages/domain_contracts/pubspec.yaml` 변경 줄

```diff
 environment:
-  sdk: ^3.5.0
+  sdk: ^3.13.0

 dependencies:
-  decimal: ^3.0.0
-  freezed_annotation: ^2.4.0
-  json_annotation: ^4.9.0
-  meta: ^1.15.0
+  decimal: ^3.2.6
+  freezed_annotation: ^3.1.0
+  json_annotation: ^4.12.0
+  meta: ^1.19.0

 dev_dependencies:
-  build_runner: ^2.4.0
+  build_runner: ^2.16.1
   flutter_lints: ^5.0.0
-  freezed: ^2.5.0
-  json_serializable: ^6.8.0
-  test: ^1.25.0
+  freezed: ^4.0.1
+  json_serializable: ^6.14.1
+  test: ^1.32.0
```

실제로 잠긴 값(`pubspec.lock`, 미커밋): `decimal 3.2.6` · `rational 2.2.3` · `intl 0.20.3` · `freezed_annotation 3.1.0` · `json_annotation 4.12.0` · `meta 1.19.0` · `build_runner 2.16.1` · `freezed 4.0.1` · `json_serializable 6.14.1` · `test 1.32.0` · `analyzer 14.3.0` · `source_gen 4.3.0` · `build 4.0.11`.

### 2-2. 왜 이 버전인가 — 하나씩

| 결정 | 이유 |
|---|---|
| **`environment.sdk: ^3.5.0` → `^3.13.0`** | 🔴 이것이 이번 변경의 핵심이다. ① `freezed 4.0.1` 자체가 `sdk: ">=3.13.0"` 을 요구한다. ② `json_serializable 6.14.1` 은 **이 패키지의 언어 버전**이 `^3.9.0` 미만이면 빌드 중 `The language version (3.5.0) ... does not match the required range ^3.8.0` 경고를 내고 그 입력을 **skip** 한다 — 빌드는 «성공»으로 끝나는데 `*.g.dart` 만 조용히 안 나온다. 언어 버전은 설치된 SDK가 아니라 **`environment.sdk` 제약의 하한**에서 나오므로 여기를 올리는 것 말고 다른 방법이 없다. |
| **freezed `^2.5.0` → `^4.0.1`** | 3.x가 아니라 **4.x가 이 SDK의 짝**이다. freezed 4.0.0(2026-08-22)이 「Dart 3.13의 생성자 문법 변경」에 대응한 릴리스다. 3.x를 고르면 Dart 3.13에서 굳이 구버전 analyzer(≤13)에 묶인다. |
| **freezed_annotation `^2.4.0` → `^3.1.0`** | ⚠️ **숫자가 어긋나는 것이 정상이다.** generator만 4.x로 갔고 annotation은 3.x에 머물러 있다. freezed 4.0.1의 짝은 freezed_annotation **3.1.0**. 「메이저를 맞춰라」는 pubspec의 옛 주석을 문자 그대로 따르면 해결이 안 된다. |
| **json_serializable `^6.8.0` → `^6.14.1`** · **build_runner `^2.4.0` → `^2.16.1`** | freezed 4가 `analyzer >=13 <15` 를 끌어온다. 구버전 json_serializable·build_runner는 analyzer 7~8에 묶여 있어 **셋을 함께 올리지 않으면 해석 자체가 안 된다.** |
| **decimal `^3.0.0` → `^3.2.6`** | 3.x 최신. `intl(>=0.19 <0.21)`·`rational ^2.0.0` 을 끌어오며 둘 다 순수 Dart라 01 §1-1 「순수 Dart」 원칙을 깨지 않는다. |
| **test `^1.25.0` → `^1.32.0`** | 어차피 1.32.0으로 해석된다. 하한을 실측값에 맞춰 둔다(`pubspec.lock` 을 커밋하지 않으므로 하한이 유일한 재현 장치다). |
| **flutter_lints `^5.0.0` 유지** (6.0.0 있음) | 🔴 **올리지 않는다.** 저장소 13개 패키지가 모두 `^5.0.0` 이고, lint 기준선을 한 패키지만 다르게 두면 「어디서는 통과하고 어디서는 실패하는」 분석이 된다. 올린다면 루트에서 13개를 한 커밋에 — 이 회차의 일이 아니다. |

### 2-3. 🔴 통합 담당에게 넘기는 후속 1건

SETUP.md §4-6 은 **「13개 pubspec의 `environment.sdk` 를 같은 값으로, 한 커밋에서」** 를 규칙으로 두고 있다. 지금 `domain_contracts` 만 `^3.13.0` 이고 나머지 12개(루트 · `packages/*` · `apps/*`)는 `^3.5.0` 이다.

- 지금 당장은 **깨지지 않는다** — melos 6.x 고전 방식은 패키지마다 따로 `pub get` 을 돌리고, 실측으로 `melos run build:gen` · `melos run analyze` 가 13개 전부 SUCCESS 였다.
- 그러나 「한 곳만 다르면 해석이 조용히 갈린다」는 SETUP의 경고가 그대로 살아 있다. **나머지 12개도 `^3.13.0` 으로 올리는 커밋을 통합 단계에서 낼 것.**

---

## §3. freezed 4 클래스 작성 규칙 — 이 템플릿을 그대로 쓴다

🔴 **01 §1-2 의 코드 예시는 freezed 2.x 문법이다**(`@freezed class Money with _$Money`). 그대로 쓰면 빌드가 실패한다. 문서의 **이름·필드·규약**은 정본이고, **클래스 선언 문법만** 아래로 바꿔 읽는다.

### 3-1. 단일 생성자 DTO (대부분의 §2 DTO·뷰모델)

```dart
// packages/domain_contracts/lib/src/dto/plan_row.dart
// 01 §2-x — <이 DTO가 무엇인지 한 줄>.
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/sleeve_id.dart';
import '../primitives/converters.dart'; // DecimalStringConverter·RatioConverter·TradeDateConverter
import '../primitives/ratio.dart';      // extension type Ratio
import '../primitives/trade_date.dart'; // extension type TradeDate

part 'plan_row.freezed.dart';
part 'plan_row.g.dart';

@freezed
abstract class PlanRow with _$PlanRow {
  // 🔴 getter·메서드·추가 factory 를 둘 때는 이 private 생성자가 **필수**다.
  //    없으면 «The class doesn't have a constructor _» 로 생성이 실패한다.
  const PlanRow._();

  const factory PlanRow({
    required String orderId,
    required SleeveId sleeve,
    @DecimalStringConverter() required Decimal amount,
    @RatioConverter() required Ratio weight,
    @TradeDateConverter() required TradeDate asOf,
    @Default(<String>[]) List<String> reasonCodes,
    String? memo,
  }) = _PlanRow;

  factory PlanRow.fromJson(Map<String, dynamic> json) => _$PlanRowFromJson(json);

  // 파생 표시값이 아니라 «판정 없는 편의»만 둔다(01 §1-4 부작용 없음).
  bool get hasMemo => memo != null;
}
```

**규칙 6조**

1. 🔴 **`abstract class`** — freezed 3부터 `@freezed` 클래스는 `abstract` 또는 `sealed` 여야 한다. 그냥 `class` 로 쓰면 생성이 실패한다.
2. 🔴 **`with _$PlanRow`** 를 반드시 붙인다.
3. 🔴 getter·메서드·이름 있는 factory 를 하나라도 두면 **`const PlanRow._();`** 를 맨 위에 둔다. 필드만 있는 순수 DTO라면 생략해도 된다.
4. 🔴 **`part` 두 줄**(`.freezed.dart` · `.g.dart`). `fromJson` 이 없는 DTO는 `.g.dart` 줄을 **쓰지 않는다**(없는 파일을 part 하면 분석 오류).
5. 🔴 **`@Default(...)` 는 const 표현식**으로 — `@Default(<String>[])`. 빈 컬렉션 기본값은 타입을 명시해야 `strict-raw-types` 에 걸리지 않는다.
6. 🔴 `import 'package:freezed_annotation/freezed_annotation.dart';` **하나면 된다** — 이 패키지가 `json_annotation` 을 재수출하므로 `@JsonKey`·`@JsonValue`·`JsonConverter` 가 함께 들어온다. `json_annotation` 을 따로 import 하지 않는다(`directives_ordering` 소음).

### 3-2. 합집합(union) — §3 코드→문구 매핑의 결과 타입 등

```dart
@freezed
sealed class ExitOutcome with _$ExitOutcome {
  const factory ExitOutcome.filled(TradeDate at) = ExitFilled;
  const factory ExitOutcome.blocked(String reasonCode) = ExitBlocked;
}
```

🔴 **`map`/`when` 은 freezed 3에서 삭제됐다.** Dart 패턴 매칭으로 쓴다 — 그리고 이것이 오히려 C-12(열거·분기 누락 금지)에 유리하다. `default:` 를 적는 순간 컴파일러의 망라성 검사가 꺼진다는 규칙이 union 에도 그대로 적용된다.

```dart
final String label = switch (outcome) {
  ExitFilled(:final at) => exitFilledLabel(at),   // §3 매핑 사전만이 문구의 출처
  ExitBlocked(:final reasonCode) => exitBlockedLabel(reasonCode),
};
```

### 3-3. 컨버터 — `lib/src/primitives/converters.dart` (01 §1-2 그대로)

```dart
class DecimalStringConverter implements JsonConverter<Decimal, String> {
  const DecimalStringConverter();
  @override
  Decimal fromJson(String s) => Decimal.parse(s);
  @override
  String toJson(Decimal d) => d.toString();
}

class RatioConverter implements JsonConverter<Ratio, double> {
  const RatioConverter();
  @override
  Ratio fromJson(double v) => Ratio(v);
  @override
  double toJson(Ratio r) => r.value;
}

class TradeDateConverter implements JsonConverter<TradeDate, String> {
  const TradeDateConverter();
  @override
  TradeDate fromJson(String s) => TradeDate(s);
  @override
  String toJson(TradeDate d) => d.yyyyMmDd;
}
```

🔴 **extension type(`Ratio`·`TradeDate`)에는 컨버터가 반드시 필요하다.** json_serializable은 extension type 을 대표 타입(double·String)으로 자동 풀어 주지 않는다 — 애너테이션 없이 두면 «cannot handle» 로 생성이 실패한다. 애너테이션은 필드 앞에 `@RatioConverter()` 처럼 **직접** 붙인다(생성기가 `const RatioConverter().fromJson(...)` 로 펼치는 것을 실측 확인했다).

---

## §4. Decimal JSON 규약 (01 §1-2) — 실측으로 드러난 정정 1건

**규약**: JSON 표기는 **문자열**이다. 숫자로 쓰면 JSON 파서가 double 로 읽어 정밀도가 날아간다. `Decimal.parse` 로만 만들고 `Decimal.fromDouble` / `Decimal.parse(d.toString())` 우회는 금지(01 §1-2).

### 🔴 4-1. decimal 3.x는 값을 **정규화**한다 — 소수점 이하 0이 사라진다

```
Decimal.parse('38250.00').toString()  →  '38250'      (scale 0, isInteger true)
Decimal.parse('0.1000').toString()    →  '0.1'
Decimal.parse('-0.00').toString()     →  '0'
Decimal.parse('1e3').toString()       →  '1000'
Decimal.parse('38250.00') == Decimal.parse('38250')   →  true
```

01 §1-2의 주석 `// 🔴 JSON은 문자열 "38250.00"` 은 **「문자열이다」가 요점이고 「.00이 남는다」는 뜻이 아니다.** 따라서:

- ✅ **값 왕복은 안전하다** — `fromJson(toJson(d)) == d` 가 항상 성립한다.
- ❌ **문자열 왕복은 보장되지 않는다** — `"38250.00"` 을 읽어 다시 쓰면 `"38250"` 이 된다.
- 🔴 **픽스처(§5)의 금액 문자열은 정규형으로 적는다.** 즉 픽스처에 적는 값 `s` 는 `Decimal.parse(s).toString() == s` 를 만족해야 한다. 그렇지 않으면 「픽스처를 읽어 → DTO → 다시 JSON」 을 문자열로 비교하는 골든·C-15 가 **내용이 같은데도** 실패한다.
- 🔴 **표시용 자릿수(`38,250원`·`38250.00`)는 컨버터의 일이 아니다.** 화면 문자열은 전부 엔진 완성 문자열이므로(01 §1-5) 자릿수는 그 문자열 안에 이미 들어 있다. 컨버터가 `toStringAsFixed(2)` 를 하면 통화가 아닌 수량·비율 필드까지 2자리로 왜곡된다 — **하지 않는다.**

### 4-2. decimal 2.x → 3.x API 차이(pubspec 옛 주석의 실체)

- `Decimal.parse` · `Decimal.one` · `Decimal.zero` — 동일.
- 🔴 **나눗셈 `/` 의 반환형이 `Rational` 이다**(Decimal 아님). `Decimal` 로 되돌리려면 `(a / b).toDecimal(scaleOnInfinitePrecision: n)`. 01 §1-2 규약 5조 ④ 「곱셈 먼저, 나눗셈 나중」이 여기서 문자 그대로 필요해진다 — `(equity * riskPct) / riskPerShare` 는 마지막에 한 번만 `toDecimal(...)` 하면 된다.
- `-` `+` `*` 는 `Decimal` 반환. 규약 5조 ⑤ `Decimal.one - Decimal.parse('0.07')` → `0.93` 확인.
- 🔴 이 산술은 **`core_engine` 의 것이지 계약·화면의 것이 아니다**(01 §1-2 말미). `domain_contracts` 안에 Decimal 산술이 등장하면 그 자체가 설계 오류 신호다.

---

## §5. 알려진 함정

| # | 함정 | 증상 | 조치 |
|---|---|---|---|
| 1 | 🔴 **`@JsonSerializable(...)` 을 freezed 클래스에 붙이면 빌드가 깨진다** | `Cannot populate the required constructor argument: id.` — 생성기가 구현 클래스 `_PlanRow` 가 아니라 추상 클래스 `PlanRow` 를 대상으로 잡는다 | 클래스 단위 옵션(`fieldRename`·`explicitToJson`)을 **애너테이션으로 주지 않는다.** 전역은 `build.yaml`(아래 #2), 개별은 필드마다 `@JsonKey(name: 'as_of')` |
| 2 | JSON 키가 camelCase 로 나온다 | `'asOf'` 인데 픽스처·DDL은 `as_of` | **`packages/domain_contracts/build.yaml` 을 새로 두었다**(이번 회차 산출물). `field_rename: snake` + `explicit_to_json: true`. 실측 확인: `fixtureVersion → fixture_version`, `asOf → as_of`, 중첩 리스트는 `rows.map((e) => e.toJson())`. 🔴 열거값은 이 옵션의 영향을 받지 않는다 — SCREAMING_SNAKE 는 `@JsonValue('MONTHLY_REGULAR')` 로 **직접** 못 박는다(01 §1-2 enum 직렬화 규약) |
| 3 | 🔴 **`environment.sdk` 하한이 낮으면 `*.g.dart` 가 조용히 안 나온다** | 빌드는 SUCCESS인데 `_$XFromJson` 미정의 오류가 뒤늦게 뜬다. 로그에 `does not match the required range ^3.8.0` + `skipped` | §2-1 대로 `^3.13.0`. **`skipped` 개수를 로그에서 읽는 습관을 들일 것** — build_runner는 skip 을 실패로 치지 않는다 |
| 4 | `melos run build:gen` 이 경고를 뱉는다 | `W These options have been removed and were ignored: --delete-conflicting-outputs` | build_runner 2.16에서 그 플래그가 **제거**됐다. 동작은 정상(무시될 뿐)이고 SUCCESS 로 끝난다. `melos.yaml` 의 `build:gen` 에서 플래그를 지우면 깨끗해진다 — 🔴 melos.yaml 편집은 통합 담당 몫이라 여기서는 손대지 않았다 |
| 5 | `dart analyze --fatal-infos` 가 생성 파일에서 실패 | — | 루트 `analysis_options.yaml` 의 `exclude` 가 `**/*.g.dart`·`**/*.freezed.dart` 를 이미 뺀다. 실측에서 13개 패키지 **No issues found**. 🔴 새 exclude 를 추가하지 말 것 |
| 6 | `melos run format` 이 생성 파일 때문에 실패 | — | **일어나지 않는다.** freezed 4는 생성물 머리에 `// dart format off` 를 넣고, json_serializable 산출물도 SDK 포매터 형식 그대로다. 실측: `dart format --set-exit-if-changed .` 이 build:gen 직후에도 「8 files (0 changed)」 |
| 7 | `sort_pub_dependencies` 로 분석 실패 | `melos analyze` 가 `--fatal-infos` 라 **경고가 아니라 실패**다 | `dependencies:`·`dev_dependencies:` 를 각각 알파벳 순으로. 현재 순서: `decimal` → `freezed_annotation` → `json_annotation` → `meta`, `build_runner` → `flutter_lints` → `freezed` → `json_serializable` → `test` |
| 8 | `depend_on_referenced_packages: error` | 생성 코드가 쓰는 `collection` 을 손코드에서도 쓰면 실패 | 생성 파일은 분석 대상이 아니므로 문제없다. **손으로 쓴 파일**에서 `package:collection` 이 필요해지면 pubspec `dependencies` 에 넣어야 하고, 그것은 01 §1-1 허용 목록을 넓히는 결정이다 — 임의로 넣지 말고 계약 담당에게 올릴 것 |
| 9 | freezed 4에서 생성자 매개변수의 `final` | `no longer support 'final' keyword inside constructor parameter` | Dart 3.13 문법 변경 때문이다. `const factory X({required T a})` 안에 `final` 을 쓰지 않는다(원래 쓸 일도 없다) |
| 10 | `pubspec.lock` 이 없어 재현이 흔들린다 | — | 저장소 규칙상 lock 은 커밋하지 않는다(SETUP §6). 그래서 **하한 버전이 유일한 재현 장치**다 — §2-1 의 값을 임의로 낮추지 말 것 |
| 11 🆕 | 🟡 **`melos run test` 가 «가끔» 한 번 실패한다** — 재실행하면 통과 | `[ui_shell]: Flutter failed to read a file at "C:\src\flutter\bin\cache\engine.stamp"` + `PathNotFoundException`. 실패하는 패키지는 매번 다르다 | 🔴 **코드 결함이 아니라 경합이다.** `test:flutter` 가 5개 Flutter 패키지에서 `flutter test` 를 **동시에** 띄우는데, Flutter 툴이 그 순간 `bin/cache` 를 다시 쓰고 있으면 아직 없는 `engine.stamp` 를 읽는 프로세스가 생긴다. **조치 = 그대로 한 번 더 돌린다**(2026-09-08 실측: 실패 직후 재실행이 5패키지 전부 SUCCESS이고 `domain_contracts` 는 170 통과·34 skip 로 동일). 🔴 이것 때문에 검사를 끄거나 `test:flutter` 를 병렬에서 빼지 말 것. 🔴 CI 에서 반복되면 그때는 회피하지 말고 **테스트 전 `flutter precache` 1회**로 캐시를 먼저 데운다(원인 제거) |

---

## §6. 이번 회차 산출물 · 검증 기록

**바뀐 파일 2개**

- `packages/domain_contracts/pubspec.yaml` — §2-1 대로 수정(SDK 하한 + 의존 6종).
- `packages/domain_contracts/build.yaml` — **신규**.

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          field_rename: snake
          explicit_to_json: true
```

**검증 절차(임시 프로브 1개, 확인 후 삭제)** — freezed `abstract` 단일 생성자 + `sealed` union + `@Default` + nullable + private 생성자 + 커스텀 factory + 커스텀 getter + `Decimal`·`Ratio`·`TradeDate` 컨버터 3종 + `@JsonValue` 열거형 + 중첩 DTO 리스트를 한 파일에 담아 생성·왕복 테스트했다.

| 검사 | 결과 |
|---|---|
| `dart pub get` | ✅ |
| `dart run build_runner build` | ✅ `skipped 0`(SDK 하한을 올린 뒤), `.freezed.dart`·`.g.dart` 생성 |
| `dart analyze . --fatal-infos` (패키지) | ✅ No issues found |
| `dart test` (JSON 왕복 · snake_case 키 · `@JsonValue` · `copyWith` · union `switch`) | ✅ 2/2 |
| `dart format --set-exit-if-changed .` | ✅ 0 changed |
| `melos.bat run build:gen` (저장소 전체) | ✅ SUCCESS |
| `melos.bat run analyze` (저장소 전체 13패키지) | ✅ SUCCESS |

프로브 파일(`lib/src/toolchain_probe.dart` · `test/toolchain_probe_test.dart` · `tool/_probe_decimal.dart`)과 그 생성물은 **모두 삭제했다**. `git status` 에 남는 것은 위 2개 파일뿐이다.
