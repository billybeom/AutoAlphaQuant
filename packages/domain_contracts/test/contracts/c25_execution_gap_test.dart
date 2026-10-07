// C-25 (01 §7 · §2-6 · 03 §3) — 이행 갭 손익 0 · 13항목 불변.
//
// 골든 대조(`S7-10` 골든 파일)는 골든이 선행한다(인벤토리 §9 C-25 = 🔵).
// 여기서는 **골든의 입력인 픽스처**가 두 규약을 지키는지 본다:
//   ① 이행 갭에 금액이 없다 — 단위는 bp 뿐이다(결정 8 침식 방지)
//   ② 월간 리포트 항목이 13 고정이다 — 반사실을 14번째로 늘리지 않는다
//
// 🔴 「안내대로 했으면 얼마 벌었을 텐데」는 반사실이고, 그것을 금액으로 그리는 순간
//    결정 8(홈에 손익을 두지 않는다)이 옆문으로 무너진다. 그래서 이행 갭은 **가격
//    괴리 bp** 로만 말한다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

/// 금액으로 읽히는 표기 — 숫자에 붙은 «원/만원/억원» 과 원화 기호.
/// 🔴 «브로커 원장» 처럼 숫자가 앞에 없는 «원» 은 금액이 아니다.
final RegExp _moneyPattern = RegExp(r'[0-9][0-9,.]*\s*(억원|만원|원)|₩');

const List<String> _gapFixtures = <String>[
  FixturePaths.m7ExecutionGap1,
  FixturePaths.m7ExecutionGapCant,
  FixturePaths.m7ExecutionGapWont,
  FixturePaths.m7ExecutionGapMixed,
];

void main() {
  group('C-25 X7 이행 갭 손익 0 (01 §7 · 03 §3)', () {
    test('C-25 ① 이행 갭 픽스처에 금액 표기가 0건이다 — bp 만', () {
      for (final String path in _gapFixtures) {
        final List<({String path, String value})> strings = collectStrings(
          withoutMeta(fixtureJson(path)),
        );
        for (final ({String path, String value}) entry in strings) {
          expect(
            _moneyPattern.hasMatch(entry.value),
            isFalse,
            reason: '$path · ${entry.path} 에 금액이 들어왔다: ${entry.value}',
          );
        }
      }
    });

    test('C-25 ② 가격 괴리는 bp 로 말한다', () {
      for (final String path in _gapFixtures) {
        final Map<String, Object?> row = fixtureRows(path).single;
        expect(
          row['price_gap_label'],
          contains('bp'),
          reason: '$path — 가격 괴리 단위가 bp 가 아니다.',
        );
      }
    });

    test('C-25 ③ 세 갈래(못 함·안 함·섞임)의 문구가 서로 다르다 (B21)', () {
      final List<String> lines =
          <String>[
            FixturePaths.m7ExecutionGapCant,
            FixturePaths.m7ExecutionGapWont,
            FixturePaths.m7ExecutionGapMixed,
          ].map((String path) {
            final Object? line = fixtureRows(path).single['mode_advice_line'];
            expect(line, isA<String>(), reason: '$path — modeAdviceLine 이 없다.');
            return line! as String;
          }).toList();

      expect(
        lines.toSet().length,
        lines.length,
        reason: '세 갈래가 같은 문장을 쓰면 「못 한 것」과 「안 한 것」이 구별되지 않는다.',
      );
    });

    test('C-25 ④ 월간 리포트 항목은 13 고정이다 (03 §3)', () {
      // 🔴 항목을 더하거나 빼지 않는다 — 결측에서도 자리를 유지한다.
      const int fixedItemCount = 13;
      for (final String path in <String>[
        FixturePaths.m7M7Monthly202608,
        FixturePaths.m7M7MonthlyGap,
        FixturePaths.m7M7MonthlyPending,
      ]) {
        final MonthlyReport report = MonthlyReport.fromJson(
          fixtureRows(path).single,
        );
        expect(report.items.length, fixedItemCount, reason: path);
        // 🔴 세후는 13항목 배열이 아니라 `afterTax` 로만 실어 나른다.
        final Map<String, dynamic> json = report.toJson();
        expect(json.containsKey('after_tax_pct'), isFalse);
      }
    });

    test(
      'C-25 ⑤ (R12 밖) S7-1 13항목 골든 대조 — S7-10 금액 리터럴은 C-42 ⑦',
      () {},
      skip: '골든 파일(`*.golden.json`)이 선행한다(인벤토리 §9 C-25 = 🔵).',
    );
  });
}
