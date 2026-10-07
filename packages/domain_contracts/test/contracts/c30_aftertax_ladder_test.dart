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
//
// 🆕 01 §8 미결 77(2026-10-01) — 픽스처의 층이 한 칸씩 밀리고 16.5% 인출 층이 빠진 채로
//    ⓐ~ⓔ 가 통과했다(값이 한 칸 내려앉아도 코드·순서의 양 끝은 멀쩡하다). 그래서 ⓖ~ⓘ 를
//    더한다 — 숫자는 여전히 적지 않고 **층 사이의 관계**만 본다:
//    ⓖ 사전(§6-13)의 층이 **순서대로 빠짐없이** 실려 오는가(본문·반사실 모두)
//    ⓗ 정본 갈래는 파킹이 절세계좌라 «세금 전»과 «파킹 과세 뒤»가 같은가 · 반사실은 내려가는가
//    ⓘ 층을 내려갈수록 대조 값이 오르지 않는가 · 두 갈래가 같은 «세금 전»에서 출발하는가
//    ⓙ 대조 값(`cagrPct`·`endMult`)·환급 문장의 수치가 골든 사본과 같은가(관계 단언만으로는
//       «AFTER_POT 아래에서 시작한 밀림»이 샜다 — 적대 검증 실측 · 01 §15-1)
//    ⓚ 표시 글자 `valueText` 가 대조 값의 둘째 자리 반올림과 같은가(사용자가 보는 것은 글자다)
//    🔴 ⓙ 의 숫자는 **코드가 아니라 데이터 파일**에 있다 — `support/golden/aftertax_full_S7.json`
//       (정본 = 설계 저장소 `09_백테스트/백테스트6/runs/N2_golden/golden_p0s.json` 의 같은 이름
//       블록을 글자 그대로 복사한 것 · 정본이 바뀌면 사본을 다시 복사한다). 01 §2-4 의 «인용처는
//       픽스처와 골든뿐»에서 이 파일은 «골든» 쪽이다.
//    ⓖ 의 «빠짐없이»는 길이를 사전에서 끌어온다 — 숫자 리터럴이 아니다(머리 원칙과 한 뜻).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

/// 골든 사본(`aftertax_full_S7`)을 읽는다 — 패키지 루트 기준.
Map<String, Object?> _goldenAfterTaxFull() {
  final File file = File(
    '${fixturesDir().parent.path}/test/contracts/support/golden/aftertax_full_S7.json',
  );
  if (!file.existsSync()) {
    throw StateError('골든 사본이 없다: ${file.path}');
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}

/// 갈래 → 골든 블록 키. 🔴 `wire` 소문자가 아니다(`SPEC_POT_TAX_FREE` → `spec_pot_taxfree`).
const Map<TaxLadderBranch, String> _goldenBranchKey = <TaxLadderBranch, String>{
  TaxLadderBranch.specPotTaxFree: 'spec_pot_taxfree',
  TaxLadderBranch.cfPotTaxableComp26: 'cf_pot_taxable_comp26',
  TaxLadderBranch.cfPotTaxableComp38: 'cf_pot_taxable_comp38',
  TaxLadderBranch.cfPotTaxableFlat: 'cf_pot_taxable_flat',
};

/// 층 코드 → 골든 키. «정직 기대»는 골든에 없다(16.5% 층 − 낙관 감액 · «안팎»).
const Map<String, String> _goldenStepKey = <String, String>{
  AfterTaxStepCodes.pretax: 'pretax',
  AfterTaxStepCodes.afterPot: 'after_pot',
  AfterTaxStepCodes.afterPotC: 'after_pot_c',
  AfterTaxStepCodes.wd5p5: 'wd_5p5',
  AfterTaxStepCodes.wd16p5: 'wd_16p5',
};

AfterTaxStep _stepOf(AfterTaxLadder l, String code) => l.steps.firstWhere(
  (AfterTaxStep s) => s.stepCode == code,
  orElse: () => fail('${l.branch.wire} — 층이 없다: $code'),
);

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
      // 🔴 층 수는 고정하지 않는다 — 여기서는 양 끝(「세전」·「정직 기대」)만 본다.
      //    전량·순서 일치는 ⓖ 가 사전에서 끌어와 본다.
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
      'C-30 ⓕ (R12 밖 `ui_analytics` 화면) cagrPct·endMult 참조 0건 · 숫자 리터럴 0건 — '
      'R12 화면 = C-42 ③⑥ · `ui_analytics` 밖 세후 필드 = C-42 ⑫',
      () {},
      skip: 'ui_m7 소스 정적 스캔이 필요하다 — 패키지 선행(인벤토리 §9 C-30 = 🟡).',
    );

    test('C-30 ⓖ 본문·반사실 모두 사전의 층을 순서대로 빠짐없이 싣는다 (§8 미결 77)', () {
      // 🔴 숫자와 비교하지 않는다 — 사전(`AfterTaxStepCodes.values` · 순서 = 층 순서)과
      //    비교한다. 사전에 층이 늘면 픽스처도 함께 늘어야 하고, 한 층이 빠지면 여기서 걸린다
      //    (정직 기대는 16.5% 인출 층에서 낙관 감액을 뺀 값이라 그 층 없이 설 수 없다 · 01 §2-4).
      // `values` 는 const 집합 리터럴 — Dart 는 선언 순서 반복을 보장한다(labels.dart «순서 = 층 순서»).
      final List<String> registry = AfterTaxStepCodes.values.toList();
      final AfterTaxLadder cf = AfterTaxLadder.fromJson(
        envelope['counterfactual']! as Map<String, Object?>,
      );
      for (final AfterTaxLadder l in <AfterTaxLadder>[ladder, cf]) {
        expect(
          l.steps.map((AfterTaxStep s) => s.stepCode).toList(),
          registry,
          reason: '${l.branch.wire} — 층이 빠졌거나 순서가 사전과 다르다.',
        );
      }
    });

    test('C-30 ⓗ 정본 갈래는 «세금 전»과 «파킹 과세 뒤»가 같고 반사실은 내려간다 (§8 미결 77)', () {
      // 🔴 정본 갈래는 파킹을 절세계좌에 둔다 — 그 층에서 빠지는 세금이 없다(01 §2-4).
      //    층이 한 칸 밀리면 이 두 줄이 달라진다. 값은 적지 않고 «같은가»만 본다.
      final AfterTaxStep pretax = _stepOf(ladder, AfterTaxStepCodes.pretax);
      final AfterTaxStep afterPot = _stepOf(ladder, AfterTaxStepCodes.afterPot);
      expect(pretax.cagrPct, isNotNull);
      expect(afterPot.valueText, pretax.valueText);
      expect(afterPot.cagrPct, pretax.cagrPct);
      expect(afterPot.endMult, pretax.endMult);

      // 반사실은 파킹을 일반계좌에 둔 갈래다 — 같은 층에서 세금이 빠져야 한다.
      final AfterTaxLadder cf = AfterTaxLadder.fromJson(
        envelope['counterfactual']! as Map<String, Object?>,
      );
      final AfterTaxStep cfPretax = _stepOf(cf, AfterTaxStepCodes.pretax);
      expect(cfPretax.cagrPct, isNotNull, reason: '반사실 «세금 전»에 대조 값이 없다.');
      expect(
        _stepOf(cf, AfterTaxStepCodes.afterPot).cagrPct,
        lessThan(cfPretax.cagrPct!),
        reason: '반사실의 «파킹 과세 뒤»가 «세금 전»과 같으면 본문을 베낀 것이다.',
      );
    });

    test('C-30 ⓘ 층을 내려갈수록 대조 값이 오르지 않고 두 갈래는 같은 «세금 전»에서 출발한다', () {
      // 🔴 `cagrPct`·`endMult` 는 골든 대조·회귀 전용이다 — 여기(계약 테스트)가 그 자리다.
      //    «정직 기대»는 골든에 값이 없어(«안팎») 두 필드를 싣지 않는다 — null 은 건너뛴다.
      final AfterTaxLadder cf = AfterTaxLadder.fromJson(
        envelope['counterfactual']! as Map<String, Object?>,
      );
      for (final AfterTaxLadder l in <AfterTaxLadder>[ladder, cf]) {
        // 두 필드는 같은 층에 함께 있거나 함께 없다 — «정직 기대»만 둘 다 없다.
        for (final AfterTaxStep s in l.steps) {
          expect(
            s.cagrPct == null,
            s.endMult == null,
            reason: '${l.branch.wire} ${s.stepCode} — 대조 값이 한쪽만 있다.',
          );
          expect(
            s.cagrPct == null,
            s.stepCode == AfterTaxStepCodes.honest,
            reason: '${l.branch.wire} ${s.stepCode} — 대조 값은 «정직 기대»에만 없다.',
          );
        }
        final List<double> cagrs = l.steps
            .map((AfterTaxStep s) => s.cagrPct)
            .whereType<double>()
            .toList();
        final List<double> mults = l.steps
            .map((AfterTaxStep s) => s.endMult)
            .whereType<double>()
            .toList();
        expect(cagrs, isNotEmpty, reason: l.branch.wire);
        for (int i = 1; i < cagrs.length; i++) {
          expect(
            cagrs[i],
            lessThanOrEqualTo(cagrs[i - 1]),
            reason: '${l.branch.wire} — 세금을 뺀 층이 앞 층보다 높다.',
          );
          expect(
            mults[i],
            lessThanOrEqualTo(mults[i - 1]),
            reason: '${l.branch.wire} — 세금을 뺀 층이 앞 층보다 높다.',
          );
        }
      }
      expect(cf.steps.first.valueText, ladder.steps.first.valueText);
      expect(cf.steps.first.cagrPct, ladder.steps.first.cagrPct);
    });

    test('C-30 ⓙ 대조 값·환급 문장 수치가 골든 사본과 같다 (§8 미결 77 · 01 §15-1)', () {
      // 🔴 숫자는 이 파일에 없다 — 골든 사본(데이터)과 픽스처(데이터)를 맞댄다.
      //    관계 단언(ⓖⓗⓘ)만으로는 «AFTER_POT 아래에서 시작한 밀림»·«반사실을 다른 갈래 값으로
      //    바꿔치기»가 통과했다(적대 검증 실측). 이 단언이 그 길을 막는다.
      final Map<String, Object?> golden = _goldenAfterTaxFull();
      final AfterTaxLadder cf = AfterTaxLadder.fromJson(
        envelope['counterfactual']! as Map<String, Object?>,
      );
      for (final AfterTaxLadder l in <AfterTaxLadder>[ladder, cf]) {
        final Map<String, Object?> block =
            golden[_goldenBranchKey[l.branch]!]! as Map<String, Object?>;
        for (final AfterTaxStep s in l.steps) {
          final String? key = _goldenStepKey[s.stepCode];
          if (key == null) continue; // «정직 기대» — 골든에 없다(ⓘ 가 null 을 본다)
          final Map<String, Object?> g = block[key]! as Map<String, Object?>;
          expect(
            s.cagrPct,
            g['cagr_pct'],
            reason: '${l.branch.wire} ${s.stepCode} cagr',
          );
          expect(
            s.endMult,
            g['end_mult'],
            reason: '${l.branch.wire} ${s.stepCode} end_mult',
          );
          // 인출 층의 환급 문장(명목 합산 · 재투자)은 골든의 짝 키와 같은 둘째 자리 값을 담는다.
          if (s.stepCode == AfterTaxStepCodes.wd5p5 ||
              s.stepCode == AfterTaxStepCodes.wd16p5) {
            final Map<String, Object?> nominal =
                block['${key}_refund_nominal']! as Map<String, Object?>;
            final Map<String, Object?> reinvested =
                block['${key}_refund_reinvested']! as Map<String, Object?>;
            expect(
              s.noteLine,
              isNotNull,
              reason: '${l.branch.wire} ${s.stepCode} 환급 문장',
            );
            expect(
              s.noteLine,
              contains(
                '연 ${(nominal['cagr_pct']! as num).toStringAsFixed(2)}%',
              ),
            );
            expect(
              s.noteLine,
              contains(
                '연 ${(reinvested['cagr_pct']! as num).toStringAsFixed(2)}%',
              ),
            );
          }
        }
      }
    });

    test('C-30 ⓚ 표시 글자 valueText 는 대조 값의 둘째 자리 반올림과 같다 (01 §15-1)', () {
      // 사용자가 보는 것은 `valueText` 다 — 대조 값만 맞고 글자가 밀리면 화면이 틀린다.
      // 🔴 이 반올림은 **테스트가 픽스처를 검사**하는 것이지 화면이 포맷하는 것이 아니다(C-30 ⓑ).
      final RegExp pct = RegExp(r'^연 (\d+\.\d{2})%$');
      final AfterTaxLadder cf = AfterTaxLadder.fromJson(
        envelope['counterfactual']! as Map<String, Object?>,
      );
      for (final AfterTaxLadder l in <AfterTaxLadder>[ladder, cf]) {
        for (final AfterTaxStep s in l.steps) {
          if (s.stepCode == AfterTaxStepCodes.honest) {
            expect(s.valueText, contains('안팎'), reason: '«정직 기대»는 점값이 아니다.');
            continue;
          }
          final RegExpMatch? m = pct.firstMatch(s.valueText);
          expect(
            m,
            isNotNull,
            reason: '${l.branch.wire} ${s.stepCode} «${s.valueText}»',
          );
          expect(
            m!.group(1),
            s.cagrPct!.toStringAsFixed(2),
            reason: '${l.branch.wire} ${s.stepCode} — 글자와 대조 값이 다르다.',
          );
        }
      }
    });
  });
}
