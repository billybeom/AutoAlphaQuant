// 01 §2-1 — 표시 공통 축(인벤토리 §2-3).
//
// 🔴 이 파일의 네 열거형은 **뷰모델 전용**이라 DDL `CHECK` 대응 컬럼이 없다.
//    그래도 `@JsonValue` 를 붙인다 — 픽스처가 JSON 이고, 자동 변환 0건이 규약이다(인벤토리 §10-1 A).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-1 — 사유 칩의 색조.
/// 🔴 `prevented` 는 **실패가 아니라 방어**다(이중 발주 차단 작동 = 성공으로 렌더).
enum ChipTone {
  @JsonValue('NEUTRAL')
  neutral('NEUTRAL'),
  @JsonValue('CAUTION')
  caution('CAUTION'),
  @JsonValue('BLOCKED')
  blocked('BLOCKED'),
  @JsonValue('PREVENTED')
  prevented('PREVENTED');

  const ChipTone(this.wire);

  /// JSON 표기(01 §1-2).
  final String wire;
}

/// 01 §2-1 — 게이트 판정.
/// 🔴 `unknown` 은 `notApplicable` 과 뜻이 다르다 — X3 리스·기기 원장 판정의 «모름»이며
///    **진행 차단**이다(04 §9-8).
enum GateState {
  @JsonValue('PASS')
  pass('PASS'),
  @JsonValue('BLOCK')
  block('BLOCK'),
  @JsonValue('NOT_APPLICABLE')
  notApplicable('NOT_APPLICABLE'),
  @JsonValue('UNKNOWN')
  unknown('UNKNOWN');

  const GateState(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 01 §2-1 — 색·아이콘의 유일한 근거.
/// 🔴 **값의 부호로 색을 고르지 않는다**(음수=빨강은 손익 은유다).
enum UiLevel {
  @JsonValue('OK')
  ok('OK'),
  @JsonValue('INFO')
  info('INFO'),
  @JsonValue('WATCH')
  watch('WATCH'),
  @JsonValue('ACT')
  act('ACT'),
  @JsonValue('BLOCKED')
  blocked('BLOCKED');

  const UiLevel(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 01 §2-1 — 빈 상태 3분. «없는 것»·«못 받은 것»·«해당 없음» 은 다르다(계약 3조 ③).
enum EmptyKind {
  @JsonValue('NO_DATA')
  noData('NO_DATA'),
  @JsonValue('NOT_LOADED')
  notLoaded('NOT_LOADED'),
  @JsonValue('NOT_APPLICABLE')
  notApplicable('NOT_APPLICABLE');

  const EmptyKind(this.wire);

  /// JSON 표기.
  final String wire;
}
