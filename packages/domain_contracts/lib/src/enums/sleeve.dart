// 01 §2-1 «공통 값 객체» — 슬리브·기준 축(인벤토리 §2-1).
//
// 🔴 열거값의 JSON·DDL 표기는 `@JsonValue` 로 못 박는다(01 §1-2 enum 직렬화 규약).
//    자동 변환에 맡기면 픽스처(§5)·DDL `CHECK`(§6)와 갈라지고 §7 C-15 가 실패한다.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-1 · §6-1 `decision_log.sleeve`·`advice.sleeve` CHECK.
///
/// 🔴 `satellite` ↔ `'SAT'` 은 **기계적 대문자 변환이 아니다**(m2-8_naming B-1).
/// 🔵 v2.31 P0S 에서 `satellite` 는 **열거값 보존·화면 미노출**이다
///    (`satellite_enabled = false`). 🔴 화면이 `SleeveId` 를 순회하며 `satellite` 를 걸러내는
///    코드를 쓰지 않게 슬리브 목록은 `SleeveCatalogEntry` 로 온다 — 거르는 규칙이 화면에
///    생기면 그것이 판정이다.
enum SleeveId {
  @JsonValue('A')
  a('A'),
  @JsonValue('B')
  b('B'),
  @JsonValue('C')
  c('C'),
  @JsonValue('POT')
  pot('POT'),
  @JsonValue('CASH')
  cash('CASH'),
  @JsonValue('SAT')
  satellite('SAT');

  const SleeveId(this.wire);

  /// JSON·DDL 표기. 🔴 바로 위 `@JsonValue` 와 **같은 문자열**이며 한쪽만 고치지 않는다.
  final String wire;
}

/// 01 §2-1(P 회차 K §6 ⑪) — 같은 «비중»에 기준이 둘이다.
/// 섞으면 슬리브 A 가 8.1% 로도 20.2% 로도 보인다.
///
/// - `engineColumn` = 엔진 원장 열(POT 잔액이 C 에 합산됨)
/// - `accounting` = 회계 소속(POT → A, 03 §2-9-3)
///
/// 🔴 목표 배분·밴드 판정과 비교할 수 있는 것은 **`accounting` 하나뿐**이다.
/// 🔴 화면은 `basis` 로 분기하지 않는다 — `SleeveWeight.basis` 는 `accounting` 외 값을 갖지
///    않으며(엔진 쪽 계약), `engineColumn` 행은 진단 전용 별도 창구로만 온다. 혼합은 C-31 이 잡는다.
enum AllocationBasis {
  @JsonValue('ENGINE_COLUMN')
  engineColumn('ENGINE_COLUMN'),
  @JsonValue('ACCOUNTING')
  accounting('ACCOUNTING');

  const AllocationBasis(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
