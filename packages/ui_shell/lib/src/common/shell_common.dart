// lib/src/common/shell_common.dart
//
// 공용 조각 — ShellAsOfHeader · ShellStaleBanner · ShellSkeleton ·
// ShellErrorView · ShellPlaceholder.
//
// 🔴 배럴(lib/ui_shell.dart)에 export 하지 않는다 — R13b 가 상대 경로로 import.
// 🔴 Scaffold·AppBar·SafeArea 없음(OpsRhythm 본문 규칙).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

import '../../l10n/labels.dart';

// ── As-of header ───────────────────────────────────────────────────────────────

/// 기준일 고지 — 맨 위(M6 JournalAsOfHeader 같은 모양).
class ShellAsOfHeader extends StatelessWidget {
  const ShellAsOfHeader({super.key, required this.asOf});

  final AsOf asOf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(asOf.label),
    );
  }
}

// ── Stale banner ───────────────────────────────────────────────────────────────

/// 오래된 데이터 배너.
class ShellStaleBanner extends StatelessWidget {
  const ShellStaleBanner({super.key, required this.asOf});

  final AsOf asOf;

  @override
  Widget build(BuildContext context) {
    final String? staleLabel = asOf.staleLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(ShellLabels.staleBannerTitle),
          if (staleLabel != null) Text(staleLabel),
        ],
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────────

/// 로딩 스켈레톤 — 스피너 없음.
class ShellSkeleton extends StatelessWidget {
  const ShellSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) => const Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SizedBox(height: 132),
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────────

/// 에러 상태 — 재시도 버튼 + 선택적 기준일 레이블.
class ShellErrorView extends StatelessWidget {
  const ShellErrorView({super.key, required this.onRetry, this.lastAsOfLabel});

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
          FilledButton(
            onPressed: onRetry,
            child: const Text(ShellLabels.retry),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder ────────────────────────────────────────────────────────────────

/// 빈 자리 — 글자 없는 SizedBox.expand().
class ShellPlaceholder extends StatelessWidget {
  const ShellPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
