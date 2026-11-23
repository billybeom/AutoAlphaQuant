// 🆕 E11-viewer-223 — 뷰어 읽기 창구 주입(화면 패키지 저장소 칸 22 ← `ViewerReadModels`).

import 'package:app_viewer_ios/viewer_read_models.dart';
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_model_client/read_model_client.dart';
import 'package:ui_analytics/ui_analytics.dart';
import 'package:ui_journal/ui_journal.dart';
import 'package:ui_settings/ui_settings.dart';
import 'package:ui_shell/ui_shell.dart';

/// 원천 — 주입만 보므로 부르면 실패.
final class _NoSource implements ReadModelSource {
  @override
  Future<List<ReadModelRow>> select(ReadModelQuery query) =>
      throw UnimplementedError('select');

  @override
  Stream<List<ReadModelRow>> watch(ReadModelQuery query) =>
      throw UnimplementedError('watch');
}

void main() {
  test('저장소 칸 22 = 뷰어 묶음의 같은 인스턴스(칸마다 한 번 · 원천 호출 0)', () {
    final ViewerReadModels m = ViewerReadModels(
      source: _NoSource(),
      mode: RunMode.live,
    );
    final List<Override> overrides = viewerReadModelOverrides(m);
    final ProviderContainer c = ProviderContainer(overrides: overrides);
    addTearDown(c.dispose);
    final List<(Object, Object)> want = <(Object, Object)>[
      (c.read(shellConfigRepositoryProvider), m.config),
      (c.read(shellAlertRepositoryProvider), m.alerts),
      (c.read(shellOpsStatusRepositoryProvider), m.opsStatus),
      (c.read(shellOpsSummaryRepositoryProvider), m.opsSummary),
      (c.read(shellAdviceRepositoryProvider), m.advice),
      (c.read(shellHoldingsRepositoryProvider), m.holdings),
      (c.read(shellLedgerTrustRepositoryProvider), m.ledgerTrust),
      (c.read(shellSafetyRepositoryProvider), m.safety),
      (c.read(settingsRepositoryProvider), m.settings),
      (c.read(settingsOpsStatusRepositoryProvider), m.opsStatus),
      (c.read(journalTimelineRepositoryProvider), m.journal),
      (c.read(journalConfigRepositoryProvider), m.config),
      (c.read(journalAdviceRepositoryProvider), m.advice),
      (c.read(journalHoldingsRepositoryProvider), m.holdings),
      (c.read(journalRebalanceRepositoryProvider), m.rebalance),
      (c.read(journalLedgerRepositoryProvider), m.ledger),
      (c.read(journalLedgerTrustRepositoryProvider), m.ledgerTrust),
      (c.read(journalSafetyRepositoryProvider), m.safety),
      (c.read(safetyRepositoryProvider), m.safety),
      (c.read(rebalanceRepositoryProvider), m.rebalance),
      (c.read(performanceRepositoryProvider), m.performance),
      (c.read(executionGapRepositoryProvider), m.executionGap),
    ];
    expect(overrides, hasLength(want.length));
    for (final (int i, (Object got, Object exp)) in want.indexed) {
      expect(identical(got, exp), isTrue, reason: '칸 $i');
    }
  });
}
