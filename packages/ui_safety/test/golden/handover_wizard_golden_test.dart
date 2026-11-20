// test/golden/handover_wizard_golden_test.dart — M5-11 simToAuto 위저드 골든(설계 13 §8 R191 · 카드 E11q-c1 골든 권고).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/handover_wizard_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`m5/handover_wizard_*`) — 값을 고치지 않는다.
// 🔴 프레임이 지키는 것: ① 냉각 · 기한 · 창 · 상태 글자 = VM 그대로(카운트다운 0) ② 버튼 = 행이 준 동작만(확정됨 = 0)
//    ③ 색 = 행 level(시각 모름 = WATCH · «아직» = INFO — 빨강 아님) ④ 확인 대화 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1600);

class _Repo implements HandoverRepository {
  const _Repo(this.vm);

  final HandoverWizardVm vm;

  @override
  Stream<HandoverWizardVm> watchWizard() => Stream<HandoverWizardVm>.value(vm);
}

const Map<String, String> _wizards = <String, String>{
  'trial_incomplete': FixturePaths.m5HandoverWizardTrialIncomplete,
  'fate_pending': FixturePaths.m5HandoverWizardFatePending,
  'cooling': FixturePaths.m5HandoverWizardCooling,
  'commit_ready': FixturePaths.m5HandoverWizardCommitReady,
  'time_unknown': FixturePaths.m5HandoverWizardTimeUnknown,
  'committed': FixturePaths.m5HandoverWizardCommitted,
};

void main() {
  for (final Brightness b in Brightness.values) {
    for (final MapEntry<String, String> f in _wizards.entries) {
      testWidgets('M5-11 ${f.key} · ${brightnessSuffix(b)}', (
        WidgetTester t,
      ) async {
        await pumpForGolden(
          t,
          ProviderScope(
            overrides: <Override>[
              safetyHandoverRepositoryProvider.overrideWithValue(
                _Repo(singleFixture(f.value, HandoverWizardVm.fromJson)),
              ),
              safetySettingsActionsProvider.overrideWithValue(
                UnimplementedSettingsActions(),
              ),
              safetyLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
            ],
            child: const HandoverWizardScreen(),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(find.byType(Dialog), findsNothing);
        expect(t.takeException(), isNull);
        await expectGolden('m511_${f.key}', b);
      });
    }
  }
}
