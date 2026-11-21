// test/golden/repair_wizard_golden_test.dart — X5 정정 마법사 골든(설계 13 §8 R227 · 01 §41 K260 표본 `x5/repair_*` 7벌).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/repair_wizard_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`x5/repair_*`) — 값을 고치지 않는다.
// 🔴 프레임이 지키는 것: ① 허브 = 대상 링크만 ② 마찰 다섯 행 · 3단계만 저널 폼 ③ 정정 폼 ↔ 새 기준점 배타
//    ④ 경계 X1 = 안내 링크만(동작 0) ⑤ 확인 대화 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1600);

class _Repo implements RepairWizardRepository {
  const _Repo(this.vm);

  final RepairWizardVm vm;

  @override
  Stream<RepairWizardVm> watchRepair({String? targetId}) => Stream.value(vm);
}

class _Links implements AppLinkOpener {
  @override
  void open(String link) {}
}

const Map<String, (String, String?)> _cases = <String, (String, String?)>{
  'x5r_hub_targets': ('repair_hub_targets', null),
  'x5r_hub_empty': ('repair_hub_empty', null),
  'x5r_diff_default': ('repair_diff_default', 'ld_0001'),
  'x5r_diff_stage3': ('repair_diff_stage3', 'ld_0001'),
  'x5r_diff_ready': ('repair_diff_ready', 'ld_0001'),
  'x5r_integrity_ready': ('repair_integrity_ready', 'li_0001'),
  'x5r_boundary_x1': ('repair_boundary_x1', 'ld_0001'),
};

void main() {
  for (final Brightness b in Brightness.values) {
    for (final MapEntry<String, (String, String?)> e in _cases.entries) {
      testWidgets('X5 ${e.value.$1} · ${brightnessSuffix(b)}', (
        WidgetTester t,
      ) async {
        await pumpForGolden(
          t,
          ProviderScope(
            overrides: <Override>[
              safetyRepairWizardRepositoryProvider.overrideWithValue(
                _Repo(
                  singleFixture(
                    'x5/${e.value.$1}.json',
                    RepairWizardVm.fromJson,
                  ),
                ),
              ),
              safetyLinkOpenerProvider.overrideWithValue(_Links()),
              safetyActionsProvider.overrideWithValue(
                UnimplementedSafetyActions(),
              ),
            ],
            child: RepairWizardScreen(targetId: e.value.$2),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(find.byType(Dialog), findsNothing);
        expect(t.takeException(), isNull);
        await expectGolden(e.key, b);
      });
    }
  }
}
