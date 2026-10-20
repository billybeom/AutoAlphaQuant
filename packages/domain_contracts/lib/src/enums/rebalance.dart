// 01 §2-5 — 리밸런싱 회차의 갈래(인벤토리 §2-6 · `rebalance_event.kind` CHECK).
// 🆕 v1.8(01 §17) — `SleeveBandState`(밴드 내 · 경계 근접 · 이탈 — `H6-1` 카드 머리 · `H6-3` 행 색의 원천).
import 'package:freezed_annotation/freezed_annotation.dart';

enum RebalanceKind {
  @JsonValue('MONTHLY_REGULAR')
  monthlyRegular('MONTHLY_REGULAR'),
  @JsonValue('SEASONAL')
  seasonal('SEASONAL'),
  @JsonValue('BAND')
  band('BAND'),
  @JsonValue('REGIME')
  regime('REGIME'),
  @JsonValue('DEPOSIT')
  deposit('DEPOSIT');

  const RebalanceKind(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 🆕 v1.8(01 §17) — 슬리브 밴드 상태. 🔴 판정은 엔진 · 화면은 색만(C-12 exhaustive switch · `default:` 금지).
/// 🔴 파킹은 상태가 아니다 — 신호 미점등 파킹분으로 `outOfBand`·경고색을 만들지 않는다(02 §4-3 «파킹 상태»).
enum SleeveBandState {
  @JsonValue('IN_BAND')
  inBand('IN_BAND'),
  @JsonValue('NEAR_EDGE')
  nearEdge('NEAR_EDGE'),
  @JsonValue('OUT_OF_BAND')
  outOfBand('OUT_OF_BAND');

  const SleeveBandState(this.wire);

  final String wire;
}
