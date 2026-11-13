// lib/src/settings_providers.dart
//
// 주입 프로바이더 3.
//
// 🔴 프로바이더 기본값 = throw UnimplementedError(조립 앱이 주입).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Injection providers ────────────────────────────────────────────────────────

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
      (Ref ref) =>
          throw UnimplementedError('settingsRepositoryProvider must be overridden'),
    );

final Provider<Clock> settingsClockProvider = Provider<Clock>(
  (Ref ref) =>
      throw UnimplementedError('settingsClockProvider must be overridden'),
);

final Provider<AppLinkOpener> settingsLinkOpenerProvider =
    Provider<AppLinkOpener>(
      (Ref ref) =>
          throw UnimplementedError('settingsLinkOpenerProvider must be overridden'),
    );
