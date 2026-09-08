// 01 §2-5 — 리밸런싱 회차의 갈래(인벤토리 §2-6 · `rebalance_event.kind` CHECK).
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
