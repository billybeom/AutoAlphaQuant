// test/golden/resume_golden_test.dart — X2 재개 리포트 · 게이트 골든(설계 13 §8 R186 · 설계서 v1.25 §5-4 `x2rr_*` · `x2rg_*` 권고).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/resume_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`x2/resume_report_screen_*` · `x2/resume_gate_*`) — 값을 고치지 않는다.
// 🔴 프레임이 지키는 것: ① 손익 숫자 0 ② 항목 · 행 = VM 차례 그대로 ③ 계절 3택 = 행이 준 버튼만(확인 대화 0).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1600);

class _Repo implements ResumeGateRepository {
  const _Repo({this.gate, this.report});

  final ResumeGateVm? gate;
  final ResumeReportVm? report;

  @override
  Stream<ResumeGateVm> watchGate() =>
      gate == null ? const Stream<ResumeGateVm>.empty() : Stream.value(gate!);

  @override
  Stream<ResumeReportVm> watchReport() => report == null
      ? const Stream<ResumeReportVm>.empty()
      : Stream.value(report!);
}

class _Links implements AppLinkOpener {
  @override
  void open(String link) {}
}

Widget _scope(Widget child, _Repo repo) => ProviderScope(
  overrides: <Override>[
    safetyResumeGateRepositoryProvider.overrideWithValue(repo),
    safetyLinkOpenerProvider.overrideWithValue(_Links()),
    safetyActionsProvider.overrideWithValue(UnimplementedSafetyActions()),
  ],
  child: child,
);

const Map<String, String> _reports = <String, String>{
  'x2rr_normal': 'resume_report_screen_normal',
  'x2rr_recovery': 'resume_report_screen_recovery_full',
  'x2rr_empty': 'resume_report_screen_empty',
};

const Map<String, String> _gates = <String, String>{
  'x2rg_seasonal': 'resume_gate_seasonal_pending',
  'x2rg_clear': 'resume_gate_clear',
};

void main() {
  for (final Brightness b in Brightness.values) {
    for (final MapEntry<String, String> e in _reports.entries) {
      testWidgets('X2 리포트 ${e.value} · ${brightnessSuffix(b)}', (
        WidgetTester t,
      ) async {
        await pumpForGolden(
          t,
          _scope(
            const ResumeReportScreen(),
            _Repo(
              report: singleFixture(
                'x2/${e.value}.json',
                ResumeReportVm.fromJson,
              ),
            ),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(t.takeException(), isNull);
        await expectGolden(e.key, b);
      });
    }
    for (final MapEntry<String, String> e in _gates.entries) {
      testWidgets('X2 게이트 ${e.value} · ${brightnessSuffix(b)}', (
        WidgetTester t,
      ) async {
        await pumpForGolden(
          t,
          _scope(
            const ResumeGateScreen(),
            _Repo(
              gate: singleFixture('x2/${e.value}.json', ResumeGateVm.fromJson),
            ),
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
