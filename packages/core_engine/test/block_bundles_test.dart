// NR-1 2단계 묶음(04 §3-1 v2.33 ① · 설계 13 §8 R34 U10) — 계약 열거와의 정합 · 효과별 판정.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

void main() {
  group('계약 FlagIds 와의 정합', () {
    test('세 묶음의 합 = FlagIds.blocking(빠뜨림 · 군더더기 0)', () {
      expect(<String>{
        ...BlockBundles.allOrders,
        ...BlockBundles.newBuys,
        ...BlockBundles.entryAdvice,
      }, FlagIds.blocking);
    });

    test('묶음끼리 겹치지 않는다', () {
      expect(
        BlockBundles.allOrders.length +
            BlockBundles.newBuys.length +
            BlockBundles.entryAdvice.length,
        FlagIds.blocking.length,
      );
    });

    test('표식 · LEDGER_FIX 는 어느 묶음에도 없다', () {
      final Set<String> all = <String>{
        ...BlockBundles.allOrders,
        ...BlockBundles.newBuys,
        ...BlockBundles.entryAdvice,
      };
      expect(all.intersection(FlagIds.markerOnly), isEmpty);
      expect(all.contains(FlagIds.ledgerFix), isFalse);
    });
  });

  group('판정', () {
    test('전 주문 차단 — 매수 · 매도 · 안내 모두', () {
      for (final bool isBuy in <bool>[true, false]) {
        for (final bool advisory in <bool>[true, false]) {
          expect(
            blockingFlagsFor(
              <String>[FlagIds.reconMismatch],
              isBuy: isBuy,
              advisory: advisory,
            ),
            <String>[FlagIds.reconMismatch],
          );
        }
      }
    });

    test('신규 매수 차단 — 매수만(청산 허용)', () {
      final List<String> active = <String>[FlagIds.journalMissing];
      expect(blockingFlagsFor(active, isBuy: true, advisory: false), active);
      expect(blockingFlagsFor(active, isBuy: true, advisory: true), active);
      expect(blockingFlagsFor(active, isBuy: false, advisory: false), isEmpty);
    });

    test('진입 안내 중단 — 안내 모드의 매수만 · 자동 모드 주문은 막지 않는다', () {
      final List<String> active = <String>[FlagIds.adviceLedgerUnverified];
      expect(blockingFlagsFor(active, isBuy: true, advisory: true), active);
      expect(blockingFlagsFor(active, isBuy: false, advisory: true), isEmpty);
      expect(blockingFlagsFor(active, isBuy: true, advisory: false), isEmpty);
    });

    test('표식 · LEDGER_FIX · 모르는 값은 보지 않는다(판정 SQL 과 같다)', () {
      expect(
        blockingFlagsFor(
          <String>[...FlagIds.markerOnly, FlagIds.ledgerFix, 'UNKNOWN_FLAG'],
          isBuy: true,
          advisory: true,
        ),
        isEmpty,
      );
    });

    test('막는 플래그는 정렬 · 중복 없이', () {
      expect(
        blockingFlagsFor(
          <String>[
            FlagIds.tierBUnjudged,
            FlagIds.reconMismatch,
            FlagIds.tierBUnjudged,
            FlagIds.selfAuditOverdue,
          ],
          isBuy: true,
          advisory: true,
        ),
        <String>[
          FlagIds.reconMismatch,
          FlagIds.selfAuditOverdue,
          FlagIds.tierBUnjudged,
        ]..sort(),
      );
    });
  });
}
