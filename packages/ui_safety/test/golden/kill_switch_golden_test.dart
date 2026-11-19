// test/golden/kill_switch_golden_test.dart — M5-1 킬스위치 · M5-2 재개 게이트 골든(설계 13 §8 R180 · README «여기 골든이 지켜야 할 것»).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/kill_switch_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`m5/kill_switch_*` · `m5/kill_resume_gate_*` · `m5/pledge_written`) — 값을 고치지 않는다.
// 🔴 프레임이 지키는 것: ① 게이트 단계가 순차(받을 문항 하나에만 칸 · 확인 버튼) ② 발동에 확인 대화 0(버튼 하나) ③ 시각 ·
//    남은 시간 글자 = VM 그대로.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 2400);

class _Repo implements KillSwitchGateRepository {
  _Repo({this.screen, this.gate});

  final KillSwitchScreenVm? screen;
  final KillResumeGateVm? gate;

  @override
  Stream<KillSwitchScreenVm> watchKillSwitch() =>
      screen == null ? const Stream.empty() : Stream.value(screen!);

  @override
  Stream<KillResumeGateVm> watchResumeGate() =>
      gate == null ? const Stream.empty() : Stream.value(gate!);
}

class _Pledge implements PledgeRepository {
  const _Pledge(this.vm);

  final PledgeVm vm;

  @override
  Stream<PledgeVm> watchPledge() => Stream<PledgeVm>.value(vm);
}

class _Links implements AppLinkOpener {
  @override
  void open(String link) {}
}

Widget _scope(Widget child, _Repo repo) => ProviderScope(
  overrides: <Override>[
    safetyKillSwitchGateRepositoryProvider.overrideWithValue(repo),
    safetyKillCommandApiProvider.overrideWithValue(UnimplementedCommandApi()),
    safetyLinkOpenerProvider.overrideWithValue(_Links()),
    safetyActionsProvider.overrideWithValue(UnimplementedSafetyActions()),
    safetyPledgeRepositoryProvider.overrideWithValue(
      _Pledge(singleFixture('m5/pledge_written.json', PledgeVm.fromJson)),
    ),
  ],
  child: child,
);

const List<String> _screens = <String>[
  'kill_switch_off',
  'kill_switch_active_unrecorded',
  'kill_switch_cancel_read_failed',
  'kill_switch_recorded_waiting',
  'kill_switch_recorded_ready',
  'kill_switch_locked',
  'kill_switch_active_locked',
];

const List<String> _gates = <String>[
  'kill_resume_gate_off',
  'kill_resume_gate_not_confirmed',
  'kill_resume_gate_time_unknown',
  'kill_resume_gate_waiting',
  'kill_resume_gate_ready',
  'kill_resume_gate_in_progress',
  'kill_resume_gate_condition_unmet',
  'kill_resume_gate_locked',
];

void main() {
  for (final Brightness b in Brightness.values) {
    for (final String f in _screens) {
      testWidgets('M5-1 $f · ${brightnessSuffix(b)}', (WidgetTester t) async {
        await pumpForGolden(
          t,
          _scope(
            const KillSwitchScreen(),
            _Repo(
              screen: singleFixture('m5/$f.json', KillSwitchScreenVm.fromJson),
            ),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(find.byType(Dialog), findsNothing);
        await expectGolden('m51_$f', b);
      });
    }
    for (final String f in _gates) {
      testWidgets('M5-2 $f · ${brightnessSuffix(b)}', (WidgetTester t) async {
        final KillResumeGateVm vm = singleFixture(
          'm5/$f.json',
          KillResumeGateVm.fromJson,
        );
        await pumpForGolden(
          t,
          _scope(const KillResumeGateScreen(), _Repo(gate: vm)),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        // 순차: 확인 버튼 = 받을 문항이 있을 때만 정확히 하나.
        expect(
          find.byKey(const Key('m52-confirm')),
          vm.nextItemNo == null ? findsNothing : findsOneWidget,
        );
        await expectGolden('m52_$f', b);
      });
    }
  }
}
