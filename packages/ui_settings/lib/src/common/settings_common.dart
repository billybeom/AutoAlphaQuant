// lib/src/common/settings_common.dart
//
// 공용 조각 — SettingsAsOfLine · SettingsStaleBanner · SettingsSkeleton ·
// SettingsErrorView · settingsLevelLook.
//
// 🔴 배럴(lib/ui_settings.dart)에 export 하지 않는다 — 화면 파일이 상대 경로로 import.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

import '../../l10n/labels.dart';

// ── Level look ─────────────────────────────────────────────────────────────────

/// UiLevel 5값 → (아이콘, 색) 쌍.
(IconData, Color) settingsLevelLook(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

// ── As-of line ─────────────────────────────────────────────────────────────────

/// 기준일 고지 — 맨 아래 흐린 글씨(05 §0-4).
class SettingsAsOfLine extends StatelessWidget {
  const SettingsAsOfLine({super.key, required this.asOf});

  final AsOf asOf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Text(
        asOf.label,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

// ── Stale banner ───────────────────────────────────────────────────────────────

/// 오래된 데이터 배너 — 맨 위.
class SettingsStaleBanner extends StatelessWidget {
  const SettingsStaleBanner({super.key, required this.asOf});

  final AsOf asOf;

  @override
  Widget build(BuildContext context) {
    final String? staleLabel = asOf.staleLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(SettingsLabels.staleBannerTitle),
          if (staleLabel != null) Text(staleLabel),
        ],
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────────

/// 로딩 스켈레톤 — 스피너 없음.
class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) => const Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SizedBox(height: 72),
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────────

/// 에러 상태 — 재시도 버튼 + 선택적 기준일 레이블.
class SettingsErrorView extends StatelessWidget {
  const SettingsErrorView({
    super.key,
    required this.onRetry,
    this.lastAsOfLabel,
  });

  final VoidCallback onRetry;
  final String? lastAsOfLabel;

  @override
  Widget build(BuildContext context) {
    final String? label = lastAsOfLabel;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (label != null) Text(label),
          FilledButton(onPressed: onRetry, child: Text(SettingsLabels.retry)),
        ],
      ),
    );
  }
}
