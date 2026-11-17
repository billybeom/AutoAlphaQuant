// 운영 설정 원천 — 자산 = SPEC 02 §4 `operations` 블록 그대로(설계 13 §8 R148 Z2 · Z4).
//
// 🔵 잡는 것: 자산이 SPEC 의 잠정 값을 그대로 싣는다(바꾸려면 SPEC 과 함께 — 발주자 확정) · 글자 → 읽기 · 꼴 틀림.

import 'dart:io';

import 'package:core_engine/core_engine.dart' show OperationsConfig;
import 'package:data_sync/data_sync.dart';
import 'package:test/test.dart';

void main() {
  test('🔴 자산 = SPEC 02 §4 operations 잠정 값(v2.45)', () {
    final OperationsConfig c = operationsConfigFromText(
      File(kOperationsAssetPath).readAsStringSync(),
    );
    expect(c.liveDryRunObservationTradingDays, 2);
    expect(c.maintenanceOverdueHours, 72);
    expect(c.fencingMarginMinutes, 10);
    expect(c.brokerTokenResidualHours, isNull);
    expect(c.planObservationTradingDays, 2);
    expect(c.emergencyObservationTradingDays, 5);
    expect(c.ticketTtlMinutes, 15);
    expect(c.derivedResyncDailyCap, 3);
    expect(c.backupUpload, isFalse);
    expect(c.maintenanceOverdue, const Duration(hours: 72));
    expect(
      c.raw.keys,
      containsAll(<String>[
        'contribution_day',
        'rule_change',
        'pledge',
        'intervention',
        'resume',
        'migration',
      ]),
    );
  });

  test('자산 키 = 패키지 자산 규약', () {
    expect(kOperationsAssetPath, 'assets/config/operations.json');
    expect(
      kOperationsAssetKey,
      'packages/data_sync/assets/config/operations.json',
    );
  });

  test('글자 꼴 틀림 = FormatException', () {
    expect(() => operationsConfigFromText('not json'), throwsFormatException);
    expect(() => operationsConfigFromText('[1]'), throwsFormatException);
  });
}
