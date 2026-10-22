// C-18 (01 §7 · §10-1 · §10-5) — X7 «투자 안내» 타이틀 전수 + 접두 순서.
//
// 렌더 갈래(전 라우트 · 띠 1개 · 접두 순서 «모의투자 · 투자 안내 · 제목» · `A-1`
// 위젯 트리의 조건 분기 0건 · `autoTrade` 픽스처의 가드 리다이렉트)는 `ui_*` 가
// 선행한다(인벤토리 §9 C-18 = 🟡). 아래에서 자리를 남기고 `skip` 한다.
//
// 🔴 이 패키지 안에서 지금 지킬 수 있는 것은 **「화면이 판정할 수단을 갖지 못하게
//    하는」 계약 면**이다:
//    ① `OperatingMode` 축이 `RunMode`·`ExecPolicy` 와 직교한 별도 값인가(§10-1)
//    ② `AdviceItem` 이 `mode`·`operatingMode` 를 **싣지 않는가**(A7) — 실으면
//       화면이 모드를 읽어 문구를 고르기 시작한다
//    ③ 버튼의 근거가 `actions` 하나인가(A8) — `status`·`onHold`·`suppressed` 를
//       조합해 만들 수 없도록 목록이 **행마다** 실려 있는가

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

/// 안내 행을 싣는 픽스처(01 §5 · 인벤토리 §8-4).
const List<String> _adviceFixtures = <String>[
  FixturePaths.m6Advice12,
  FixturePaths.m6AdviceBlocked,
  FixturePaths.m6AdviceDetailOnhold,
  FixturePaths.m6AdviceDetailPartial,
  FixturePaths.m6AdviceExpiredConfirm,
  FixturePaths.m6AdviceNoAction,
  FixturePaths.m6AdviceViewer4,
];

void main() {
  group('C-18 X7 투자 안내 타이틀 (01 §7 · §10-1)', () {
    test(
      'C-18 ① OperatingMode 는 2값이고 RunMode·ExecPolicy 와 직교한다 (01 §10-1)',
      () {
        expect(
          OperatingMode.values.map((OperatingMode m) => m.wire).toList(),
          <String>['AUTO_TRADE', 'ADVISORY'],
        );
        // 🔴 세 축이 서로를 대체하지 않는다 — 표기 문자열이 겹치면 DDL CHECK 가
        //    어느 축의 값인지 구별하지 못한다.
        final Set<String> runWires = RunMode.values
            .map((RunMode m) => m.wire)
            .toSet();
        final Set<String> execWires = ExecPolicy.values
            .map((ExecPolicy m) => m.wire)
            .toSet();
        final Set<String> opWires = OperatingMode.values
            .map((OperatingMode m) => m.wire)
            .toSet();
        expect(runWires.intersection(opWires), isEmpty);
        expect(execWires.intersection(opWires), isEmpty);
        expect(runWires.intersection(execWires), isEmpty);
      },
    );

    test('C-18 ② advisory 픽스처가 실재한다 — 전 라우트 렌더의 입력', () {
      final Map<String, Object?> onboarding = fixtureJson(
        FixturePaths.m8OnboardingFreshAdvisory,
      );
      expect(onboarding['operating_mode'], OperatingMode.advisory.wire);
    });

    test('C-18 ③ AdviceItem 은 mode·operatingMode 를 싣지 않는다 (A7)', () {
      // 🔴 모드가 표시에 영향을 주는 자리는 셸의 띠 하나뿐이고 그것은
      //    `FeatureFlags` 가 담당한다. 안내 행이 모드를 실으면 목록·상세가 각자
      //    분기하기 시작한다.
      final AdviceItem item = AdviceItem.fromJson(
        fixtureRows(FixturePaths.m6Advice12).first,
      );
      final Map<String, dynamic> json = item.toJson();
      expect(json.containsKey('mode'), isFalse);
      expect(json.containsKey('operating_mode'), isFalse);
      expect(json.containsKey('exec_policy'), isFalse);
    });

    test('C-18 ④ 버튼의 근거는 actions 목록 하나다 (A8)', () {
      for (final String path in _adviceFixtures) {
        for (final Map<String, Object?> row in fixtureRows(path)) {
          final AdviceItem item = AdviceItem.fromJson(row);
          // `actions` 는 «없으면 버튼을 만들지 않는다» 이므로 빈 목록도 정상이다 —
          // 없는 것은 **키의 부재**이며 그것이 화면의 조합을 부른다.
          expect(
            row.containsKey('actions'),
            isTrue,
            reason: '$path · ${item.adviceId} 에 actions 키가 없다.',
          );
          for (final AdviceAction action in item.actions) {
            expect(
              action.label,
              isNotEmpty,
              reason: '$path · ${item.adviceId}',
            );
            if (!action.enabled) {
              expect(
                action.disabledReasonLabel,
                isNotNull,
                reason: '$path · ${item.adviceId} — 비활성 버튼에 사유 문구가 없다.',
              );
            }
          }
        }
      }
    });

    test(
      'C-18 ⑤ advisory 픽스처 전 라우트 렌더 · 띠 1개 · 접두 순서 «모의투자 · 투자 안내 · 제목»',
      () {},
      skip: 'ui_shell·골든 스냅샷 선행(인벤토리 §9 C-18 = 🟡).',
    );

    test(
      'C-18 ⑥ A-1 위젯 트리에 AdviceStatus·onHold·suppressed 조건 분기 0건 (A8)',
      () {},
      skip:
          '🆕 v1.12(01 §21) — C-46 ⑰⑱ 가 맡는다(`A-1` 대상 파일 `ui_journal/lib/src/advice_inbox.dart`·'
          '`lib/src/advice/**` 소스 스캔). 여기는 이름만 남긴다.',
    );

    test(
      'C-18 ⑦ autoTrade 픽스처에서 A-3·A-4·L-3 가 가드 리다이렉트 (C5)',
      () {},
      skip: 'ui_shell 라우트 가드 선행 — 라우트는 정적으로 전량 등록된다.',
    );
  });
}
