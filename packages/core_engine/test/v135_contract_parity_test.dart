// 🆕 미결 220 ⓐⓒⓓ(계약 v1.35 · 01 §44 K291 · K294 · K295) — core 엔진 글자 = 계약 사전 · 표본 문장.
//
// 🔴 두 배럴을 한 파일에서 import 한다 — 계약 이름이 엔진 이름과 같으면 여기서 `ambiguous_import` 로 깨진다(K80).
// ⓐ 정정 원문 거부 = `RepairInputResultCodes` 한 벌(계획 판정 거울 `RepairResultCodes` 와 서로소) ·
// ⓒ 재량 저널 kind = `DecisionJournalKinds.discretion` · ⓓ hold 짝 문장 사전 = `SafetyHoldCodes` 전량 · 문장 = 표본 글자 그대로
//    (S05 `RunModeCard.holdLabel` 과 한 벌) · `safetyStateOf` = 사전 차례 · 겹침 0 · 같은 길이 · 모르는 코드 = 거부.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' as c show BreakerLevel;
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

Map<String, Object?> _fixture(String rel) =>
    jsonDecode(File('../domain_contracts/fixtures/$rel').readAsStringSync())
        as Map<String, Object?>;

List<Map<String, Object?>> _rows(String rel) => <Map<String, Object?>>[
  for (final Object? r in _fixture(rel)['rows']! as List<Object?>)
    r! as Map<String, Object?>,
];

SafetyState _state(Iterable<String> holds) => safetyStateOf(
  level: BreakerLevel.normal,
  drawdown: 0,
  flags: const <BlockFlag>[],
  killSwitch: const KillSwitchView(active: false, stateLabel: 'x'),
  stoppedReleaseEligible: false,
  releaseProgress: const <GaugeProgress>[],
  rampLevel: RampLevel.l1,
  mode: RunMode.live,
  asOf: safetyAsOf(
    lastSnapshotDate: '2026-11-20',
    nowUtc: DateTime.utc(2026, 11, 20),
  ),
  holds: holds,
);

void main() {
  group('ⓐ 정정 원문 거부 — 엔진 = 계약 사전', () {
    test(
      'RepairInputCodes = RepairInputResultCodes(값 · 전량) · 계획 판정 거울과 서로소',
      () {
        expect(RepairInputCodes.values, RepairInputResultCodes.values);
        expect(
          RepairInputCodes.amountInvalid,
          RepairInputResultCodes.amountInvalid,
        );
        expect(
          RepairInputCodes.values.intersection(RepairResultCodes.values),
          isEmpty,
        );
      },
    );
  });

  group('ⓒ 저널 kind — 엔진 = 계약 사전', () {
    test(
      '재량 저널 kind = DecisionJournalKinds.discretion(동작 와이어와 다르다 · K294 예외)',
      () {
        expect(kDiscretionJournalKind, DecisionJournalKinds.discretion);
        expect(
          kDiscretionJournalKind,
          isNot(SafetyActionId.discretionAdjust.wire),
        );
      },
    );

    test('🔴 core lib 에 저널 kind 글자 0(SQL 따옴표 · 지역 상수) — 계약 참조만', () {
      final RegExp quoted = RegExp(
        "['\"](${DecisionJournalKinds.values.join('|')})['\"]",
      );
      final List<String> hits = <String>[
        for (final FileSystemEntity e in Directory(
          'lib',
        ).listSync(recursive: true))
          if (e is File && e.path.endsWith('.dart'))
            for (final (int i, String line) in e.readAsLinesSync().indexed)
              if (!line.trimLeft().startsWith('//') && quoted.hasMatch(line))
                '${e.path}:${i + 1}',
      ];
      expect(hits, isEmpty);
    });
  });

  group('ⓓ hold 짝 문장 — 엔진 사전 = 계약 코드 · 표본 문장', () {
    test('사전 키 = SafetyHoldCodes 전량 · 차례 = 키 · 이전', () {
      expect(kSafetyHoldLabels.keys.toSet(), SafetyHoldCodes.values);
      expect(kSafetyHoldLabels.keys.toList(), <String>[
        SafetyHoldCodes.liveAwaitingKeys,
        SafetyHoldCodes.migrationInProgress,
      ]);
    });

    test('문장 = 표본 safety_states_holds 짝 그대로 · 키 문장 = S05 RunModeCard.holdLabel(m9/operations_live_hold_keys)', () {
      final List<Map<String, Object?>> rows = _rows('safety_states_holds.json');
      expect(rows, hasLength(2));
      for (final Map<String, Object?> r in rows) {
        final List<Object?> holds = r['holds']! as List<Object?>;
        final List<Object?> labels = r['hold_labels']! as List<Object?>;
        expect(labels, hasLength(holds.length));
        for (int i = 0; i < holds.length; i++) {
          expect(safetyHoldLabelOf(holds[i]! as String), labels[i]);
        }
      }
      final Map<String, Object?> s05 = _rows(
        'm9/operations_live_hold_keys.json',
      ).single;
      final Map<String, Object?> mode = s05.values
          .whereType<Map<String, Object?>>()
          .firstWhere((Map<String, Object?> m) => m.containsKey('hold_label'));
      expect(
        safetyHoldLabelOf(SafetyHoldCodes.liveAwaitingKeys),
        mode['hold_label'],
      );
      for (final String label in kSafetyHoldLabels.values) {
        expect(label, isNot(contains('합성')));
      }
    });

    test(
      'safetyStateOf — 사전 차례 · 겹침 0 · 같은 길이 · 빈 = 빈 · 모르는 코드 = ArgumentError',
      () {
        final SafetyState both = _state(<String>[
          SafetyHoldCodes.migrationInProgress,
          SafetyHoldCodes.liveAwaitingKeys,
          SafetyHoldCodes.migrationInProgress,
        ]);
        expect(both.holds, <String>[
          SafetyHoldCodes.liveAwaitingKeys,
          SafetyHoldCodes.migrationInProgress,
        ]);
        expect(both.holdLabels, <String>[
          for (final String h in both.holds) kSafetyHoldLabels[h]!,
        ]);
        expect(both.breakerLevel, c.BreakerLevel.normal);
        final SafetyState none = _state(const <String>[]);
        expect(none.holds, isEmpty);
        expect(none.holdLabels, isEmpty);
        expect(() => _state(<String>['NOPE']), throwsArgumentError);
        expect(() => safetyHoldLabelOf('NOPE'), throwsArgumentError);
      },
    );
  });
}
