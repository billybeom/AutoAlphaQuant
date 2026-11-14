// lib/src/settings_providers.dart
//
// 주입 프로바이더 3.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Injection providers ────────────────────────────────────────────────────────

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
      (Ref ref) => throw UnimplementedError(
        'settingsRepositoryProvider must be overridden',
      ),
    );

final Provider<Clock> settingsClockProvider = Provider<Clock>(
  (Ref ref) =>
      throw UnimplementedError('settingsClockProvider must be overridden'),
);

final Provider<AppLinkOpener> settingsLinkOpenerProvider =
    Provider<AppLinkOpener>(
      (Ref ref) => throw UnimplementedError(
        'settingsLinkOpenerProvider must be overridden',
      ),
    );

// ── R6b — M9 S07 injection providers ──────────────────────────────────────────

final Provider<OpsStatusRepository> settingsOpsStatusRepositoryProvider =
    Provider<OpsStatusRepository>(
      (Ref ref) => throw UnimplementedError(
        'settingsOpsStatusRepositoryProvider must be overridden',
      ),
    );

final Provider<SettingsActions?> settingsActionsProvider =
    Provider<SettingsActions?>((Ref ref) => null);
