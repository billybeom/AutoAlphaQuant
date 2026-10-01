// lib/src/planner/planner_providers.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<WhatIfApi> plannerWhatIfApiProvider = Provider<WhatIfApi>((ref) {
  throw UnimplementedError('plannerWhatIfApiProvider must be overridden');
});

final Provider<ConfigRepository> plannerConfigRepositoryProvider =
    Provider<ConfigRepository>((ref) {
      throw UnimplementedError(
        'plannerConfigRepositoryProvider must be overridden',
      );
    });

final Provider<CommandApi> plannerCommandApiProvider = Provider<CommandApi>((
  ref,
) {
  throw UnimplementedError('plannerCommandApiProvider must be overridden');
});

final AutoDisposeStreamProvider<ContributionSetting>
plannerContributionSettingProvider =
    StreamProvider.autoDispose<ContributionSetting>((ref) {
      return ref
          .watch(plannerConfigRepositoryProvider)
          .watchContributionSetting();
    });
