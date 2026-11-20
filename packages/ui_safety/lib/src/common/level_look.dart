// ui_safety 공용 — 수준 → 아이콘 · 색(홈 셀과 같은 짝 · 🔴 배럴에 내보내지 않는다).

import 'package:domain_contracts/domain_contracts.dart' show UiLevel;
import 'package:flutter/material.dart';

/// 수준 → (아이콘, 색).
(IconData, Color) safetyLevelLook(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};
