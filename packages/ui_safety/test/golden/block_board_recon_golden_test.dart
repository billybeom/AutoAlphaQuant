// test/golden/block_board_recon_golden_test.dart — M5-5 차단 보드 RECON 해제 폼 골든(설계 13 §8 R189 · 설계서 v1.26 §8 골든 권고 19).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/block_board_recon_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`m5/block_board_recon_mismatch`) — 값을 고치지 않는다 · 쓰기 주입 = 폰(가짜 · 제출 0).
// 🔴 프레임 = 행 안 «원인 코드 고르기»를 연 뒤. 지키는 것: ① 해제 폼 = RECON 행 안에만(일지 행 0) ② 원인 코드 = 엔진 선택지
//    받은 차례 · 고르기 전 확인 꺼짐 ③ 사전 저널 세 칸 ④ 킬스위치 진입이 늘 위에 ⑤ 확인 대화 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
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

void main() {
  for (final Brightness b in Brightness.values) {
    testWidgets('M5-5 block_board_recon_mismatch · ${brightnessSuffix(b)}', (
      WidgetTester t,
    ) async {
      await pumpForGolden(
        t,
        ProviderScope(
          overrides: <Override>[
            safetyBlockBoardRepositoryProvider.overrideWithValue(
              _Repo(
                singleFixture(
                  'm5/block_board_recon_mismatch.json',
                  BlockBoardVm.fromJson,
                ),
              ),
            ),
            safetyLinkOpenerProvider.overrideWithValue(_Links()),
            safetyActionsProvider.overrideWithValue(
              UnimplementedSafetyActions(),
            ),
          ],
          child: const BlockBoardScreen(),
        ),
        brightness: b,
        logicalSize: _kTallPhone,
      );
      await t.pump();
      expect(find.byKey(const Key('m55-recon-form')), findsOneWidget);
      await t.tap(find.byKey(const Key('m55-recon-open')));
      await t.pump();
      expect(find.byType(Dialog), findsNothing);
      expect(t.takeException(), isNull);
      await expectGolden('m55_block_board_recon_mismatch', b);
    });
  }
}
