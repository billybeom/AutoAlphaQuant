// test/golden/rule_change_golden_test.dart — M5-9 규칙 변경 게이트 «첫 승인 최소판» 골든(설계 13 §8 R188 · 카드 E11q-c0 골든 권고).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/rule_change_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`m5/rule_change_gate_*`) — 값을 고치지 않는다.
// 🔴 프레임이 지키는 것: ① 냉각 · 상태 글자 = VM 그대로(카운트다운 0) ② 승인 버튼 = approveLabel 행만 ③ 확인 대화 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1200);

class _Repo implements RuleChangeGateRepository {
  const _Repo(this.vm);

  final RuleChangeGateVm vm;

  @override
  Stream<RuleChangeGateVm> watchGate() => Stream<RuleChangeGateVm>.value(vm);
}

const List<String> _gates = <String>[
  'first_candidate',
  'cooling',
  'approvable',
];

void main() {
  for (final Brightness b in Brightness.values) {
    for (final String f in _gates) {
      testWidgets('M5-9 $f · ${brightnessSuffix(b)}', (WidgetTester t) async {
        await pumpForGolden(
          t,
          ProviderScope(
            overrides: <Override>[
              safetyRuleChangeGateRepositoryProvider.overrideWithValue(
                _Repo(
                  singleFixture(
                    'm5/rule_change_gate_$f.json',
                    RuleChangeGateVm.fromJson,
                  ),
                ),
              ),
              safetyActionsProvider.overrideWithValue(
                UnimplementedSafetyActions(),
              ),
            ],
            child: const RuleChangeGateScreen(),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(find.byType(Dialog), findsNothing);
        expect(t.takeException(), isNull);
        await expectGolden('m59_$f', b);
      });
    }
  }
}
