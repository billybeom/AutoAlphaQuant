// lib/src/screens/performance_explore_screen.dart
// S7-2G 열람 게이트 + S7-2 수익률 탐색 화면의 합성 — 공개 위젯 1개.
//
// 언제나 게이트로 시작하고, 「그래도 보기」를 눌러 통과하면 같은 위젯 안에서
// PerformanceExploreBody 로 바뀐다.
//
// 🔴 통과 사실은 이 State 에만 둔다 — 전역 프로바이더·정적 변수·세션 캐시 금지.
// 🔴 위젯이 새로 만들어지면 언제나 게이트부터.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/analytics_providers.dart';
import 'explore/disclosure_gate_view.dart';
import 'explore/performance_explore_body.dart';

/// S7-2G 열람 게이트 + S7-2 수익률 탐색 화면 합성.
///
/// 생성자에는 [key] 뿐 — 내부 상태가 게이트 통과 여부를 관리한다.
class PerformanceExploreScreen extends ConsumerStatefulWidget {
  const PerformanceExploreScreen({super.key});

  @override
  ConsumerState<PerformanceExploreScreen> createState() =>
      _PerformanceExploreScreenState();
}

class _PerformanceExploreScreenState
    extends ConsumerState<PerformanceExploreScreen> {
  // ── 상태 ─────────────────────────────────────────────────────────────────

  /// null = 아직 게이트 / non-null = 통과한 접수증
  CommandReceipt? _receipt;

  bool _submitting = false;
  bool _notAccepted = false;

  // ── 명령 ─────────────────────────────────────────────────────────────────

  /// 「그래도 보기」 탭 — 01 §13-6 · §12-3 5원칙.
  Future<void> _continue() async {
    setState(() {
      _submitting = true;
      _notAccepted = false;
    });
    final CommandReceipt receipt;
    try {
      receipt = await ref
          .read(analyticsCommandApiProvider)
          .recordDisclosureView(
            DisclosureViewEvent(
              surfaceCode: DisclosureSurfaceCodes.performanceExplore,
              viewedAt: ref.read(analyticsClockProvider).nowUtc(),
            ),
          );
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'ui_analytics',
        ),
      );
      if (mounted) {
        setState(() {
          _submitting = false;
          _notAccepted = true;
        });
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _receipt = receipt;
      _submitting = false;
    });
  }

  // ── 빌드 ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    if (receipt == null) {
      return DisclosureGateView(
        onContinue: _continue,
        submitting: _submitting,
        notAccepted: _notAccepted,
      );
    }
    return PerformanceExploreBody(receipt: receipt);
  }
}
