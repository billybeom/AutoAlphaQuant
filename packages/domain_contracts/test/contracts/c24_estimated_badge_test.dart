// C-24 (01 §7 · §2-11 · §2-2) — 소급 표시 + 추정 비용 배지.
//
// 「배지가 화면에 있는가」는 위젯 골든이 선행한다(인벤토리 §9 C-24 = 🟡).
// 🔴 그 앞에 계약이 먼저 지켜야 하는 것: **배지를 그릴 값이 실제로 실려 오는가.**
//    ① `costSource == estimated` 행이 픽스처에 있고 그 행의 `costSourceLabel` 이
//       비어 있지 않은가(= 문구를 화면이 짓지 않아도 되는가)
//    ② 소급 행에 `priceRangeSourceDate` 가 실려 있는가(B4 — 검증의 근거일)
//
// 🔴 추정치를 확정치처럼 그리지 않는다 — 구 `costsOverridden`(bool) 이 폐기된 이유는
//    하나로는 «브로커 확정»과 «엔진 추정»이 구별되지 않기 때문이다(C18).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

void main() {
  group('C-24 X7 추정 비용·소급 표시 (01 §7 · §2-2)', () {
    test('C-24 ① CostSource 는 3값이다 — bool 로 되돌아가지 않는다 (C18)', () {
      expect(CostSource.values.map((CostSource s) => s.wire).toList(), <String>[
        'BROKER',
        'USER_ENTERED',
        'ESTIMATED',
      ]);
    });

    test('C-24 ② estimated 행이 실재하고 그 행이 자기 문구를 싣는다', () {
      final List<TradeJournalEntry> rows = fixtureRows(FixturePaths.journal30)
          .map(TradeJournalEntry.fromJson)
          .toList();

      final List<TradeJournalEntry> estimated = rows
          .where((TradeJournalEntry e) => e.costSource == CostSource.estimated)
          .toList();

      expect(
        estimated,
        isNotEmpty,
        reason: 'estimated 행이 없으면 C-24 의 배지 검사는 입력 없이 통과한다.',
      );
      for (final TradeJournalEntry row in estimated) {
        expect(
          row.costSourceLabel,
          isNotEmpty,
          reason: '${row.entryId} — 화면이 «비용 추정치» 를 스스로 지어내게 된다(§1-5).',
        );
      }
    });

    test('C-24 ③ 소급 행에 근거일과 소급 라벨이 실린다 (B4)', () {
      final List<TradeJournalEntry> rows = <TradeJournalEntry>[
        ...fixtureRows(FixturePaths.m6ManualFills8)
            .map(TradeJournalEntry.fromJson),
        ...fixtureRows(FixturePaths.journal30).map(TradeJournalEntry.fromJson),
      ];

      final List<TradeJournalEntry> backdated = rows
          .where((TradeJournalEntry e) => e.backdate.isBackdated)
          .toList();
      expect(backdated, isNotEmpty, reason: '소급 행이 없으면 이 검사는 입력 없이 통과한다.');

      for (final TradeJournalEntry row in rows) {
        // 🔴 근거일은 소급 여부와 무관하게 **항상** 실린다 — 보이지 않으면 사람이
        //    그것을 조작 축으로 쓴다.
        expect(row.backdate.priceRangeSourceDate.yyyyMmDd, isNotEmpty);
        expect(row.backdate.label, isNotEmpty);
      }

      for (final TradeJournalEntry row in backdated) {
        expect(
          row.backdate.backdateTradingDays,
          greaterThan(0),
          reason: '${row.entryId} — 소급인데 거래일 차가 0 이다.',
        );
        if (row.backdate.crossesClosedPeriod) {
          expect(
            row.backdate.closedPeriodNote,
            isNotNull,
            reason: '${row.entryId} — 마감된 달을 넘는 소급인데 각주 문구가 없다.',
          );
        }
      }
    });

    test(
      'C-24 ④ costSource == estimated 배지·priceRangeSourceDate 라벨 렌더',
      () {},
      skip: 'ui_m6 위젯 골든이 선행한다(인벤토리 §9 C-24 = 🟡).',
    );
  });
}
