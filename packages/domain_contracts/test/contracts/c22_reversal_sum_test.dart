// C-22 (01 §7 · §10-3) — 역분개 산술.
//
// 검사의 요점 한 줄: **「필터 없는 단순 SUM」이 최종 수량·금액과 일치해야 한다.**
// 정정을 「원본을 지우고 다시 적기」가 아니라 「상쇄 + 재기재」로 표현한 이유가
// 이것이다 — 파생 계산(포지션·현금·성과·대사)이 `is_active` 같은 필터를 하나라도
// 빠뜨리면 원장이 조용히 갈라지는데, 상쇄 행이 정확히 원본을 지우면 **필터가 아예
// 필요 없다**. 그 성질을 픽스처에서 확인한다.
//
// 🔴 여기서 산술을 하는 것은 테스트다 — `domain_contracts/lib` 안에는 Decimal 산술이
//    없어야 한다(01 §1-2 · money.dart 머리 조문). 화면도 하지 않는다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

/// 방향을 반영한 수량(01 §2-2 — `side` 가 부호다).
int _signedQuantity(TradeJournalEntry e) =>
    e.side == OrderSide.sell ? -e.quantity : e.quantity;

void main() {
  group('C-22 X7 역분개 산술 (01 §7 · §10-3)', () {
    late List<TradeJournalEntry> rows;

    setUp(() {
      rows = fixtureRows(FixturePaths.m6ManualFills8)
          .map(TradeJournalEntry.fromJson)
          .toList();
    });

    test('C-22 ① 필터 없는 단순 SUM = 정정 반영 뒤의 수량 (종목별)', () {
      final Map<String, int> plainSum = <String, int>{};
      for (final TradeJournalEntry e in rows) {
        plainSum[e.symbol] = (plainSum[e.symbol] ?? 0) + _signedQuantity(e);
      }

      final Map<String, int> activeSum = <String, int>{};
      for (final TradeJournalEntry e in _activeView(rows)) {
        activeSum[e.symbol] = (activeSum[e.symbol] ?? 0) + _signedQuantity(e);
      }

      expect(
        plainSum,
        activeSum,
        reason: '상쇄 행이 원본을 정확히 지우지 못한다 — 파생 계산이 필터를 요구하게 된다.',
      );
    });

    test('C-22 ② 필터 없는 단순 SUM = 정정 반영 뒤의 비용 (수수료·세금)', () {
      Decimal plain = Decimal.zero;
      for (final TradeJournalEntry e in rows) {
        plain += e.commission + e.tax;
      }

      Decimal active = Decimal.zero;
      for (final TradeJournalEntry e in _activeView(rows)) {
        active += e.commission + e.tax;
      }

      expect(plain, active, reason: '상쇄 행의 비용 부호가 원본과 맞지 않는다.');
    });

    test('C-22 ③ 상쇄 행은 원본과 정확히 반대 부호다', () {
      final Map<String, TradeJournalEntry> byId = <String, TradeJournalEntry>{
        for (final TradeJournalEntry e in rows) e.entryId: e,
      };
      final Iterable<TradeJournalEntry> reversals = rows.where(
        (TradeJournalEntry e) => e.fillKind == FillKind.reversal,
      );

      expect(reversals, isNotEmpty);
      for (final TradeJournalEntry reversal in reversals) {
        final TradeJournalEntry origin = byId[reversal.deviation.journalId]!;
        expect(
          _signedQuantity(reversal) + _signedQuantity(origin),
          0,
          reason: '${reversal.entryId} 가 ${origin.entryId} 를 지우지 못한다.',
        );
        expect(
          reversal.commission + origin.commission,
          Decimal.zero,
          reason: '${reversal.entryId} 의 수수료 상쇄가 맞지 않는다.',
        );
      }
    });

    test('C-22 ④ 정정 뒤 최종 수량이 재기재 행의 값이다', () {
      // 「SUM 이 맞으니 됐다」가 아니라 «무엇이 최종인가»도 함께 본다(A14 의 이웃).
      final Map<String, TradeJournalEntry> byId = <String, TradeJournalEntry>{
        for (final TradeJournalEntry e in rows) e.entryId: e,
      };
      for (final TradeJournalEntry restatement in rows.where(
        (TradeJournalEntry e) => e.fillKind == FillKind.restatement,
      )) {
        final TradeJournalEntry origin = byId[restatement.deviation.journalId]!;
        final int finalQty = rows
            .where((TradeJournalEntry e) => e.symbol == origin.symbol)
            .map(_signedQuantity)
            .fold(0, (int a, int b) => a + b);
        expect(
          finalQty,
          _signedQuantity(restatement),
          reason: '${origin.symbol} 의 최종 수량이 재기재 값과 다르다.',
        );
      }
    });
  });
}

/// 「정정을 반영한 뷰」 — 상쇄된 원본과 상쇄 행을 뺀 나머지.
///
/// 🔴 이것은 **검사의 반대편 계산**이지 앱이 쓰는 경로가 아니다. 앱·엔진은
///    [C-22 ①] 이 보장하는 「필터 없는 단순 SUM」을 쓴다.
List<TradeJournalEntry> _activeView(List<TradeJournalEntry> rows) {
  final Set<String> amendedIds = rows
      .where((TradeJournalEntry e) => e.fillKind == FillKind.reversal)
      .map((TradeJournalEntry e) => e.deviation.journalId)
      .whereType<String>()
      .toSet();

  return rows
      .where(
        (TradeJournalEntry e) =>
            e.fillKind != FillKind.reversal && !amendedIds.contains(e.entryId),
      )
      .toList();
}
