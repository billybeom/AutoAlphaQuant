// 운영 설정 읽기 모델(설계 13 §8 R148 Z3~Z5).

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

Map<String, Object?> _full() => <String, Object?>{
  'live_dry_run_observation_trading_days': 2,
  'migration': <String, Object?>{
    'maintenance_overdue_hours': 72,
    'fencing_margin_minutes': 10,
    'broker_token_residual_hours': null,
    'observation_trading_days': <String, Object?>{'plan': 2, 'emergency': 5},
    'ticket_ttl_minutes': 15,
    'derived_resync_daily_cap': 3,
    'backup_upload': false,
  },
  'other': <String, Object?>{'kept': true},
};

void main() {
  test('값 읽기 · 원문 보관(고칠 수 없음)', () {
    final OperationsConfig c = OperationsConfig.fromJson(_full());
    expect(c.liveDryRunObservationTradingDays, 2);
    expect(c.maintenanceOverdueHours, 72);
    expect(c.fencingMarginMinutes, 10);
    expect(c.brokerTokenResidualHours, isNull);
    expect(c.planObservationTradingDays, 2);
    expect(c.emergencyObservationTradingDays, 5);
    expect(c.ticketTtlMinutes, 15);
    expect(c.derivedResyncDailyCap, 3);
    expect(c.backupUpload, isFalse);
    expect((c.raw['other']! as Map<String, Object?>)['kept'], isTrue);
    expect(() => c.raw['x'] = 1, throwsUnsupportedError);
  });

  test('변환 — 창 넘김 · X1-5 관찰 · M1-22 관찰 · 펜싱(잔존 null = core 가정)', () {
    final OperationsConfig c = OperationsConfig.fromJson(_full());
    expect(c.maintenanceOverdue, const Duration(hours: 72));
    final MigrationObservationConfig o = c.migrationObservation!;
    expect(o.planTradingDays, 2);
    expect(o.emergencyTradingDays, 5);
    expect(c.liveObservation!.requiredTradingDays, 2);
    final FencingConfig f = c.fencing!;
    expect(f.margin, const Duration(minutes: 10));
    expect(f.brokerTokenResidual, isNull);
    final Map<String, Object?> m = _full();
    (m['migration']! as Map<String, Object?>)['broker_token_residual_hours'] =
        6;
    expect(
      OperationsConfig.fromJson(m).fencing!.brokerTokenResidual,
      const Duration(hours: 6),
    );
  });

  test('🆕 R150 재개 사다리 — 둘 다 있을 때만 · 꼴 틀림 · 사다리 검사 그대로', () {
    Map<String, Object?> resume(Object? gaps, Object? backup) =>
        <String, Object?>{
          'resume': <String, Object?>{
            'gap_ladder_trading_days': gaps,
            'backup_gap_days': backup,
          },
        };
    final OperationsConfig c = OperationsConfig.fromJson(
      resume(<Object?>[2, 5, 10], 7),
    );
    expect(c.gapLadderTradingDays, <int>[2, 5, 10]);
    expect(c.backupGapDays, 7);
    final ResumeLadder l = c.resumeLadder!;
    expect(l.gapLadderTradingDays, <int>[2, 5, 10]);
    expect(l.backupGapDays, 7);
    expect(
      OperationsConfig.fromJson(resume(<Object?>[1, 3, 9], 4))
          .resumeLadder!
          .gapLadderTradingDays,
      <int>[1, 3, 9],
    );
    expect(
      OperationsConfig.fromJson(resume(<Object?>[1, 3, 9], 4))
          .resumeLadder!
          .backupGapDays,
      4,
    );
    expect(OperationsConfig.fromJson(resume(null, 7)).resumeLadder, isNull);
    expect(
      OperationsConfig.fromJson(resume(<Object?>[2, 5, 10], null)).resumeLadder,
      isNull,
    );
    expect(OperationsConfig.fromJson(<String, Object?>{}).resumeLadder, isNull);
    expect(
      () =>
          OperationsConfig.fromJson(resume(<Object?>[2, '5', 10], 7))
              .gapLadderTradingDays,
      throwsFormatException,
    );
    expect(
      () => OperationsConfig.fromJson(resume(2, 7)).gapLadderTradingDays,
      throwsFormatException,
    );
    expect(
      () =>
          OperationsConfig.fromJson(resume(<Object?>[5, 2, 10], 7))
              .resumeLadder,
      throwsArgumentError,
    );
  });

  test('🆕 미결 220 ⓑ 정정 체인 상한 = 최상위 amend_chain_max(정수 · 없음 = null · 꼴 틀림 = FormatException)', () {
    expect(OperationsConfig.fromJson(_full()).amendChainMax, isNull);
    expect(
      OperationsConfig.fromJson(<String, Object?>{'amend_chain_max': 3})
          .amendChainMax,
      3,
    );
    expect(
      OperationsConfig.fromJson(<String, Object?>{'amend_chain_max': null})
          .amendChainMax,
      isNull,
    );
    // 다른 블록 안의 같은 이름은 읽지 않는다(최상위 키 하나 — X5 · X7 공용).
    expect(
      OperationsConfig.fromJson(<String, Object?>{
        'migration': <String, Object?>{'amend_chain_max': 2},
      }).amendChainMax,
      isNull,
    );
    expect(
      () =>
          OperationsConfig.fromJson(<String, Object?>{'amend_chain_max': '2'})
              .amendChainMax,
      throwsFormatException,
    );
  });

  test('🔴 키 없음 · 값 null = null(기능 꺼짐 · 지어내지 않음)', () {
    final OperationsConfig empty = OperationsConfig.fromJson(
      <String, Object?>{},
    );
    expect(empty.maintenanceOverdueHours, isNull);
    expect(empty.maintenanceOverdue, isNull);
    expect(empty.migrationObservation, isNull);
    expect(empty.liveObservation, isNull);
    expect(empty.fencing, isNull);
    expect(empty.backupUpload, isNull);
    final Map<String, Object?> half = _full();
    (half['migration']! as Map<String, Object?>)['observation_trading_days'] =
        <String, Object?>{'plan': 2};
    expect(OperationsConfig.fromJson(half).migrationObservation, isNull);
    final Map<String, Object?> nul = _full();
    nul['live_dry_run_observation_trading_days'] = null;
    expect(OperationsConfig.fromJson(nul).liveObservation, isNull);
  });

  test('🔴 꼴 틀림 = FormatException(조용히 넘어가지 않음)', () {
    expect(() => OperationsConfig.fromJson(<Object?>[]), throwsFormatException);
    expect(() => OperationsConfig.fromJson(null), throwsFormatException);
    Map<String, Object?> bad(String key, Object? v) {
      final Map<String, Object?> m = _full();
      (m['migration']! as Map<String, Object?>)[key] = v;
      return m;
    }

    expect(
      () =>
          OperationsConfig.fromJson(bad('maintenance_overdue_hours', '72'))
              .maintenanceOverdueHours,
      throwsFormatException,
    );
    expect(
      () =>
          OperationsConfig.fromJson(bad('maintenance_overdue_hours', 72.5))
              .maintenanceOverdueHours,
      throwsFormatException,
    );
    expect(
      () => OperationsConfig.fromJson(bad('backup_upload', 'no')).backupUpload,
      throwsFormatException,
    );
    expect(
      () =>
          OperationsConfig.fromJson(bad('observation_trading_days', 3))
              .planObservationTradingDays,
      throwsFormatException,
    );
    expect(
      () =>
          OperationsConfig.fromJson(<String, Object?>{'migration': 'x'})
              .maintenanceOverdueHours,
      throwsFormatException,
    );
  });

  test('core 설정 검사를 그대로 거친다(0 이하 · 1 미만 = ArgumentError)', () {
    Map<String, Object?> with_(String key, Object? v) {
      final Map<String, Object?> m = _full();
      (m['migration']! as Map<String, Object?>)[key] = v;
      return m;
    }

    expect(
      () =>
          OperationsConfig.fromJson(with_('maintenance_overdue_hours', 0))
              .maintenanceOverdue,
      throwsArgumentError,
    );
    expect(
      () => OperationsConfig.fromJson(<String, Object?>{
        'migration': <String, Object?>{
          'observation_trading_days': <String, Object?>{
            'plan': 0,
            'emergency': 5,
          },
        },
      }).migrationObservation,
      throwsArgumentError,
    );
    expect(
      () => OperationsConfig.fromJson(<String, Object?>{
        'live_dry_run_observation_trading_days': 0,
      }).liveObservation,
      throwsArgumentError,
    );
    expect(
      () =>
          OperationsConfig.fromJson(with_('fencing_margin_minutes', -1))
              .fencing,
      throwsArgumentError,
    );
  });
}
