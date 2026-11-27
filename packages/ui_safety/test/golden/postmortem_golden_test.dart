// test/golden/postmortem_golden_test.dart — `M5-4` 안전 사건 postmortem 골든(설계 13 §8 R282 · 미결 243 ⓐ · 계약 v1.39 K345).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/postmortem_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`m5/postmortem_list_*`) — 값을 고치지 않는다.
// 🔴 프레임이 지키는 것: ① 기한 · 상태 글자 = VM 그대로(카운트다운 0) ② 쓰기 칸 = `form` 행만(쓴 SEV1 = 읽기 전용 + STOPPED 결정 링크)
//    ③ 확인 대화 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1200);

class _Repo implements PostmortemRepository {
  const _Repo(this.vm);

  final PostmortemListVm vm;

  @override
  Stream<PostmortemListVm> watchPostmortems() =>
      Stream<PostmortemListVm>.value(vm);
}

const List<String> _lists = <String>['empty', 'due', 'written_overdue'];

void main() {
  for (final Brightness b in Brightness.values) {
    for (final String f in _lists) {
      testWidgets('M5-4 $f · ${brightnessSuffix(b)}', (WidgetTester t) async {
        await pumpForGolden(
          t,
          ProviderScope(
            overrides: <Override>[
              safetyPostmortemRepositoryProvider.overrideWithValue(
                _Repo(
                  singleFixture(
                    'm5/postmortem_list_$f.json',
                    PostmortemListVm.fromJson,
                  ),
                ),
              ),
              safetyActionsProvider.overrideWithValue(
                UnimplementedSafetyActions(),
              ),
            ],
            child: const PostmortemScreen(),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(find.byType(Dialog), findsNothing);
        expect(t.takeException(), isNull);
        await expectGolden('m54_postmortem_$f', b);
      });
    }
  }
}
