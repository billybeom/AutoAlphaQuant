// 🆕 계약 v1.17(01 §26 · K8) — M8 `D-01` 장애 배너 종류.
import 'package:freezed_annotation/freezed_annotation.dart';

/// `D-01` 장애 종류 — 🔴 화면은 **아이콘 선택에만** 쓴다(문구·조치는 [IncidentBanner] 가 완성해 준다 · 04 §6).
/// 🔴 모르는 wire 값 = [other](`IncidentBanner.kind` 의 `unknownEnumValue` · 엔진이 종류를 늘려도 화면이 죽지 않는다).
/// 원천: [phoneDown] = 뷰어가 rm_* 신선도로 파생(죽은 폰은 push 못 한다 · 04 §2-3) · 그 밖 = 엔진 `incidents` 표(06 숙제).
enum IncidentKind {
  @JsonValue('PHONE_DOWN')
  phoneDown('PHONE_DOWN'),
  @JsonValue('NETWORK_DOWN')
  networkDown('NETWORK_DOWN'),
  @JsonValue('TOKEN_EXPIRED')
  tokenExpired('TOKEN_EXPIRED'),
  @JsonValue('ORDER_REJECTED')
  orderRejected('ORDER_REJECTED'),
  @JsonValue('OTHER')
  other('OTHER');

  const IncidentKind(this.wire);

  /// JSON 표기.
  final String wire;
}
