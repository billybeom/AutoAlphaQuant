// C-29 (01 §7 · §10-3 · §2-11) — 소급 정정의 시계열 재계산.
//
// 본체(「`trade_date` 기준 재계산 후 `equity_snapshot` 시계열이 **정확히 정정분만큼**
// 다르고 대응 `ledger_repair` 행이 **정확히 1개**」)는 엔진의 재계산 경로가 선행한다
// (인벤토리 §9 C-29 = 🟡). 픽스처에는 `equity_snapshot`·`ledger_repair` 가 없다.
//
// 🔴 A14 — 「SUM 이 맞으니 됐다」는 **잘못된 안심**이다. C-22 가 보는 것은 «최종 합»
//    이고, 소급 정정이 바꾸는 것은 «그날 이후 전 구간의 시계열»이다. 두 검사는 서로를
//    대신하지 못한다.
// 🔴 여기서 지키는 것은 그 재계산의 **입력**이다: 소급 행이 「기록일 ≠ 거래일」을
//    한 자리(`BackdateStamp`)에서 말하고 있는가 — 화면이 두 날짜를 빼지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

void main() {
  group('C-29 X7 소급 정정의 시계열 재계산 (01 §7 · §10-3)', () {
    late List<TradeJournalEntry> rows;

    setUp(() {
      rows = fixtureRows(FixturePaths.m6ManualFills8)
          .map(TradeJournalEntry.fromJson)
          .toList();
    });

    test('C-29 ① 재계산의 기준은 거래일이다 — 기록일이 아니다', () {
      for (final TradeJournalEntry row in rows) {
        expect(
          row.backdate.tradeDate.yyyyMmDd,
          row.tradeDate.yyyyMmDd,
          reason: '${row.entryId} — 소급 도장의 거래일이 행의 거래일과 다르다.',
        );
      }
    });

    test('C-29 ② 소급 행은 기록 시각이 거래일보다 뒤다', () {
      final List<TradeJournalEntry> backdated = rows
          .where((TradeJournalEntry e) => e.backdate.isBackdated)
          .toList();
      expect(
        backdated,
        isNotEmpty,
        reason: '소급 행이 없으면 C-29 는 재계산할 것이 없는 채로 통과한다.',
      );

      for (final TradeJournalEntry row in backdated) {
        final String authoredDay = row.backdate.authoredAt
            .toUtc()
            .toIso8601String()
            .substring(0, 10);
        expect(
          authoredDay.compareTo(row.tradeDate.yyyyMmDd),
          greaterThan(0),
          reason: '${row.entryId} — 소급인데 기록일이 거래일보다 뒤가 아니다.',
        );
      }
    });

    test('C-29 ③ 마감된 달을 넘는 소급은 그 사실을 문장으로 싣는다 (G-97)', () {
      // 🔴 마감된 달을 **재계산하지 않고** 각주로 말한다 — 월간 리포트가 조용히
      //    바뀌면 사람은 자기가 본 숫자를 다시 믿지 못한다.
      final Iterable<TradeJournalEntry> crossing = rows.where(
        (TradeJournalEntry e) => e.backdate.crossesClosedPeriod,
      );
      expect(crossing, isNotEmpty);
      for (final TradeJournalEntry row in crossing) {
        expect(row.backdate.isBackdated, isTrue, reason: row.entryId);
        expect(row.backdate.closedPeriodNote, isNotNull, reason: row.entryId);
        expect(row.backdate.closedPeriodNote, isNotEmpty, reason: row.entryId);
      }

      // 그 각주는 리포트 쪽에도 자리가 있다.
      final MonthlyReport report = MonthlyReport.fromJson(
        fixtureRows(FixturePaths.m7M7MonthlyGap).single,
      );
      expect(report.backdateFootnote, isNotNull);
    });

    test('C-29 ④ 소급 행에도 이탈 배지가 붙는다 — 조용히 지나가지 않는다', () {
      for (final TradeJournalEntry row in rows.where(
        (TradeJournalEntry e) => e.backdate.isBackdated,
      )) {
        expect(row.deviation.isDeviation, isTrue, reason: row.entryId);
        expect(row.deviation.kindCode, isNotNull, reason: row.entryId);
        expect(
          DeviationKindCodes.values,
          contains(row.deviation.kindCode),
          reason:
              '${row.entryId} 의 이탈 코드가 §3 사전에 없다: ${row.deviation.kindCode}',
        );
      }
    });

    test(
      'C-29 ⑤ trade_date 기준 재계산 후 equity_snapshot 차이 = 정정분 · ledger_repair 1행',
      () {},
      skip: '엔진 재계산 경로와 `ledger_repair` 표가 선행한다(인벤토리 §9 C-29 = 🟡).',
    );
  });
}
