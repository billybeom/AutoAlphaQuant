// test/golden/block_board_golden_test.dart — M5-5 차단 보드 골든(설계 13 §8 R185 · 설계서 v1.25 §5-4 `m5bb_*` 권고).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/block_board_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`m5/block_board_*`) — 값을 고치지 않는다.
// 🔴 프레임이 지키는 것: ① 킬스위치 진입이 늘 위에 ② 행 · 게이지 · 사다리 = VM 차례 그대로 ③ 사다리 지금 단 = 색 + 글자 표지
//    ④ 해제 버튼 · 확인 대화 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 2000);

class _Repo implements BlockBoardRepository {
  const _Repo(this.vm);

  final BlockBoardVm vm;

  @override
  Stream<BlockBoardVm> watchBoard() => Stream<BlockBoardVm>.value(vm);
}

class _Links implements AppLinkOpener {
  @override
  void open(String link) {}
}

const List<String> _boards = <String>[
  'block_board_clear',
  'block_board_kill_active',
  'block_board_resume_incomplete',
  'block_board_stopped',
];

void main() {
  for (final Brightness b in Brightness.values) {
    for (final String f in _boards) {
      testWidgets('M5-5 $f · ${brightnessSuffix(b)}', (WidgetTester t) async {
        await pumpForGolden(
          t,
          ProviderScope(
            overrides: <Override>[
              safetyBlockBoardRepositoryProvider.overrideWithValue(
                _Repo(singleFixture('m5/$f.json', BlockBoardVm.fromJson)),
              ),
              safetyLinkOpenerProvider.overrideWithValue(_Links()),
            ],
            child: const BlockBoardScreen(),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(find.byType(Dialog), findsNothing);
        expect(t.takeException(), isNull);
        await expectGolden('m55_$f', b);
      });
    }
  }
}
