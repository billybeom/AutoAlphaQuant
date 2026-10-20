// M2-9 ⓔ · M3-5 — 엔진이 조립한 세후 사다리(`buildAfterTaxLadder`)가 계약 픽스처
// `domain_contracts/fixtures/m7/aftertax_ladder_1.json`(정본 갈래 + 반사실 38.5%)과 DTO 째로 같은가 ·
// 네 갈래 모두 C-30(층 순서·관계·글자 반올림) · C-41 ⑦(참고치 표지)을 지키는가.
//
// 🔵 입력 = 골든 `aftertax_full_S7`(4자리) — 앱이 §8 미결 18 확정 전에 내는 «골든 참고 사다리»의 원천.
//    재현 S7(Dart)에서 다시 계산한 값이 같은 블록과 글자까지 같다는 것은 `replay/replay_aftertax_test.dart` 가 본다.

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Future<Map<String, Object?>> _fixture() async {
  final Uri lib = (await Isolate.resolvePackageUri(
    Uri.parse('package:domain_contracts/domain_contracts.dart'),
  ))!;
  final File f = File.fromUri(
    lib.resolve('../fixtures/m7/aftertax_ladder_1.json'),
  );
  return jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
}

void main() {
  late Map<String, Object?> envelope;
  late AfterTaxLadder wantSpec, wantCf;
  final AfterTaxFull golden = AfterTaxFull.fromGoldenJson(
    (jsonDecode(File('test/golden/vectors/golden_p0s.json').readAsStringSync())
            as Map<String, Object?>)['aftertax_full_S7']!
        as Map<String, Object?>,
  );

  setUpAll(() async {
    envelope = await _fixture();
    wantSpec = AfterTaxLadder.fromJson(
      (envelope['rows']! as List<Object?>).single! as Map<String, Object?>,
    );
    wantCf = AfterTaxLadder.fromJson(
      envelope['counterfactual']! as Map<String, Object?>,
    );
  });

  AfterTaxLadder build(TaxLadderBranch b) => buildAfterTaxLadder(
    golden,
    b,
    asOf: wantSpec.asOf,
    configHash: wantSpec.configHash,
  );

  test('정본 갈래(POT 절세계좌) — 픽스처 rows[0] 과 DTO 째로 같다(라벨·글자·대조 값·문장)', () {
    expect(build(TaxLadderBranch.specPotTaxFree), wantSpec);
  });

  test('반사실 38.5% — 픽스처 counterfactual 과 DTO 째로 같다', () {
    expect(build(TaxLadderBranch.cfPotTaxableComp38), wantCf);
  });

  group('네 갈래 — C-30 · C-41 ⑦', () {
    for (final TaxLadderBranch b in TaxLadderBranch.values) {
      test(
        '${b.wire} — 층 사전 순서 그대로 · 글자 = 대조 값 둘째 자리 · 층이 내려갈수록 오르지 않는다 · 참고치 표지',
        () {
          final AfterTaxLadder l = build(b);
          expect(
            l.steps.map((AfterTaxStep s) => s.stepCode).toList(),
            AfterTaxStepCodes.values.toList(),
          );
          double? prev;
          for (final AfterTaxStep s in l.steps) {
            expect(s.label, isNotEmpty);
            if (s.stepCode == AfterTaxStepCodes.honest) {
              expect(s.cagrPct, isNull);
              expect(s.endMult, isNull);
              expect(s.valueText, endsWith('% 안팎'));
              continue;
            }
            expect(s.valueText, '연 ${s.cagrPct!.toStringAsFixed(2)}%');
            if (prev != null) expect(s.cagrPct, lessThanOrEqualTo(prev));
            prev = s.cagrPct;
          }
          final AfterTaxStep pre = l.steps.first, pot = l.steps[1];
          if (b == TaxLadderBranch.specPotTaxFree) {
            expect(pot.cagrPct, pre.cagrPct, reason: '절세계좌 — 파킹 과세 0');
          } else {
            expect(
              pot.cagrPct,
              lessThan(pre.cagrPct!),
              reason: '반사실 — 파킹 과세가 층을 낮춘다',
            );
          }
          expect(l.isReferenceOnly, isTrue);
          expect(l.referenceOnlyLabel, isNotNull);
          expect(l.branchLabel, isNotEmpty);
          expect(l.honestExpectationLine, isNotEmpty);
          expect(l.basisNote, isNotEmpty);
        },
      );
    }

    test('네 갈래가 같은 «세금 전»에서 출발하고 라벨은 서로 다르다', () {
      final List<AfterTaxLadder> all = <AfterTaxLadder>[
        for (final TaxLadderBranch b in TaxLadderBranch.values) build(b),
      ];
      expect(
        all.map((AfterTaxLadder l) => l.steps.first.cagrPct).toSet(),
        hasLength(1),
      );
      expect(
        all.map((AfterTaxLadder l) => l.branchLabel).toSet(),
        hasLength(all.length),
      );
    });
  });

  test('정직 기대 = 16.5% 인출 층 − 낙관 감액 0.47%p 를 한 자리로(«안팎»)', () {
    for (final TaxLadderBranch b in TaxLadderBranch.values) {
      final AfterTaxLadder l = build(b);
      final double wd = l.steps
          .firstWhere(
            (AfterTaxStep s) => s.stepCode == AfterTaxStepCodes.wd16p5,
          )
          .cagrPct!;
      expect(
        l.steps.last.valueText,
        '연 ${(wd - kHonestHaircutPctPoints).toStringAsFixed(1)}% 안팎',
      );
    }
  });

  test('계산에 없는 갈래는 조립하지 않는다', () {
    final AfterTaxFull one = AfterTaxFull(<TaxLadderBranch, AfterTaxBranch>{
      TaxLadderBranch.specPotTaxFree:
          golden.branches[TaxLadderBranch.specPotTaxFree]!,
    }, null);
    expect(
      () => buildAfterTaxLadder(
        one,
        TaxLadderBranch.cfPotTaxableFlat,
        asOf: wantSpec.asOf,
        configHash: 'x',
      ),
      throwsArgumentError,
    );
  });
}
