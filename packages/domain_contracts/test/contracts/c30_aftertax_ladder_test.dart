// C-30 (01 §7 · §2-4 · P 회차) — 세후 사다리 렌더.
//
// 렌더 갈래(ⓐ `ui_*` 위젯트리에 `cagrPct`·`endMult` 참조 0건 ⓑ 숫자 리터럴 0건)는
// `ui_*` 가 선행한다(인벤토리 §9 C-30 = 🟡).
//
// 🔴 이 검사가 막는 사고: **층을 접어 «인출세 미포함»을 «세후»로 되살리는 것**
//    (구 «10.4%» 사고). 그래서 계약 면에서 지키는 것은 넷이다:
//    ⓐ 층이 순서대로 **전부** 실려 오는가 · 층 코드가 §6-13 사전에 있는가
//    ⓑ 표시의 정본이 `valueText` 인가(화면이 double 을 포맷하지 않아도 되는가)
//    ⓒ 본문 갈래가 **정확히 1개** 인가(반사실은 접혀 있다)
//    ⓓ `isReferenceOnly` 가 유지되는가(§8 미결 18 — 실계좌 세후를 «실측»으로 표기 금지)
//
// 🔴 층 수를 **코드로 고정하지 않는다** — 층이 늘면 UI 가 저절로 는다. 그래서 이
//    테스트도 `steps.length` 를 특정 숫자와 비교하지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

void main() {
  group('C-30 P 세후 사다리 (01 §7 · §2-4)', () {
    late Map<String, Object?> envelope;
    late AfterTaxLadder ladder;

    setUp(() {
      envelope = fixtureJson(FixturePaths.m7AftertaxLadder1);
      ladder = AfterTaxLadder.fromJson(
        fixtureRows(FixturePaths.m7AftertaxLadder1).single,
      );
    });

    test('C-30 ⓐ 층 코드는 §6-13 사전에 등재된 값이고 중복이 없다', () {
      expect(ladder.steps, isNotEmpty);
      final List<String> codes = ladder.steps
          .map((AfterTaxStep s) => s.stepCode)
          .toList();
      for (final String code in codes) {
        expect(
          AfterTaxStepCodes.values,
          contains(code),
          reason: '등재되지 않은 층 코드: $code',
        );
      }
      expect(codes.toSet().length, codes.length, reason: '같은 층이 두 번 실렸다.');
      // 🔴 층 수는 고정하지 않는다 — 「세전」과 「정직 기대」가 함께 있는지만 본다.
      expect(codes.first, AfterTaxStepCodes.pretax);
      expect(codes.last, AfterTaxStepCodes.honest);
    });

    test('C-30 ⓑ 표시의 정본은 valueText 다 — double 은 골든 대조 전용이다', () {
      for (final AfterTaxStep step in ladder.steps) {
        expect(step.valueText, isNotEmpty, reason: step.stepCode);
        expect(step.label, isNotEmpty, reason: step.stepCode);
      }
      expect(ladder.honestExpectationLine, isNotEmpty);
      expect(ladder.basisNote, isNotEmpty);
    });

    test('C-30 ⓒ 본문 갈래는 정확히 1개이고 반사실은 접혀 있다', () {
      expect(
        fixtureRows(FixturePaths.m7AftertaxLadder1).length,
        1,
        reason: '본문 갈래가 둘이면 화면이 「어느 쪽이 내 계좌인가」를 고르게 된다.',
      );
      expect(ladder.branch, TaxLadderBranch.specPotTaxFree);

      final Object? counterfactual = envelope['counterfactual'];
      expect(counterfactual, isA<Map<String, Object?>>());
      final AfterTaxLadder cf = AfterTaxLadder.fromJson(
        counterfactual! as Map<String, Object?>,
      );
      expect(
        cf.branch,
        isNot(ladder.branch),
        reason: '반사실이 본문과 같은 갈래면 비교가 성립하지 않는다.',
      );
      expect(
        envelope['counterfactual_collapsed'],
        isTrue,
        reason: '🔴 화면은 본문 갈래를 하나만 편다(C-25 의 반사실 부활 방지와 한 사안).',
      );
    });

    test('C-30 ⓓ isReferenceOnly 는 참이다 (§8 미결 18)', () {
      // 🔴 보정판 산식이 확정될 때까지 고정 — 실계좌 세후를 «실측»으로 표기하지 않는다.
      // 🔴 SIM 에서도 이 라벨을 유지한다(01 §9-4).
      expect(ladder.isReferenceOnly, isTrue);

      final AfterTaxLadder cf = AfterTaxLadder.fromJson(
        envelope['counterfactual']! as Map<String, Object?>,
      );
      expect(cf.isReferenceOnly, isTrue);
    });

    test('C-30 ⓔ 갈래는 계좌 배치가 정한다 — 화면·인자로 고르는 값이 아니다 (SAF-309)', () {
      expect(ladder.branchLabel, isNotEmpty);
      expect(ladder.configHash, startsWith('cfg_fake_'));
      // 🔴 «정직 기대» 수치를 코드·라벨·주석에 옮기지 않는다 — 인용처는 픽스처와
      //    골든뿐이다. 그래서 여기서도 값을 단언하지 않고 «있는가»만 본다.
      expect(
        ladder.steps
            .firstWhere(
              (AfterTaxStep s) => s.stepCode == AfterTaxStepCodes.honest,
            )
            .valueText,
        isNotEmpty,
      );
    });

    test(
      'C-30 ⓕ ui_* 위젯트리에 cagrPct·endMult 참조 0건 · 숫자 리터럴 0건',
      () {},
      skip: 'ui_m7 소스 정적 스캔이 필요하다 — 패키지 선행(인벤토리 §9 C-30 = 🟡).',
    );
  });
}
