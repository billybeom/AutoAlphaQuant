// C-21 (01 §7 · §10-3) — 수기 기록 append-only.
//
// 「UPDATE/DELETE 0회」의 실측은 `data_sync` 구현체가 선행한다(인벤토리 §9 C-21 =
// 🟡, 픽스처 대조분은 🟢). 아래는 **픽스처 대조분**이다:
//   · 정정 1회 = `REVERSAL` + `RESTATEMENT` **2행**이고 원본 행이 그대로 남아 있는가
//   · 두 행의 `symbol`·`side` 가 원본과 같은가(A13 — 종목 대체 금지)
//   · 정정 체인이 상한(2회) 안에 있는가(B6 — 무한 정정 금지)
//
// 🔴 「원본을 고쳤다」와 「상쇄하고 다시 적었다」는 다른 사건이고, 원장이 그 둘을
//    구별하지 못하면 소급 정정이 감사로도 잡히지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

/// 01 §10-3 · B6 — 정정 체인 상한. 🔴 숫자를 화면·계약에 두는 것이 아니라
/// **검사 조건**으로만 쓴다(엔진 config 가 정본이며 초과 시 `AMEND_LIMIT_EXCEEDED`).
const int _amendChainLimit = 2;

void main() {
  group('C-21 X7 수기 기록 append-only (01 §7 · §10-3)', () {
    late List<TradeJournalEntry> rows;

    setUp(() {
      rows = fixtureRows(FixturePaths.m6ManualFills8)
          .map(TradeJournalEntry.fromJson)
          .toList();
    });

    test('C-21 ① 행은 덮어써지지 않는다 — entry_id 가 유일하다', () {
      final Set<String> ids = rows
          .map((TradeJournalEntry e) => e.entryId)
          .toSet();
      expect(
        ids.length,
        rows.length,
        reason: '같은 entry_id 가 두 번 나오면 그것이 UPDATE 다.',
      );
    });

    test('C-21 ② 정정 1회 = REVERSAL + RESTATEMENT 2행이다', () {
      final List<TradeJournalEntry> reversals = rows
          .where((TradeJournalEntry e) => e.fillKind == FillKind.reversal)
          .toList();
      final List<TradeJournalEntry> restatements = rows
          .where((TradeJournalEntry e) => e.fillKind == FillKind.restatement)
          .toList();

      expect(
        reversals,
        isNotEmpty,
        reason: '정정 갈래가 없는 픽스처면 C-21 은 입력 없이 통과한다(01 §5 manual_fills_8).',
      );
      expect(
        restatements.length,
        reversals.length,
        reason: '상쇄만 있고 재기재가 없으면 수량이 사라진다.',
      );
    });

    test('C-21 ③ 정정 행은 원본을 가리키고 원본은 그대로 남아 있다', () {
      final Map<String, TradeJournalEntry> byId = <String, TradeJournalEntry>{
        for (final TradeJournalEntry e in rows) e.entryId: e,
      };

      for (final TradeJournalEntry row in rows.where(
        (TradeJournalEntry e) => e.fillKind != FillKind.original,
      )) {
        final String? targetId = row.deviation.journalId;
        expect(
          targetId,
          isNotNull,
          reason: '${row.entryId} — 정정 행이 원본을 가리키지 않으면 «덮어씀»과 구별되지 않는다.',
        );
        expect(
          byId.containsKey(targetId),
          isTrue,
          reason: '${row.entryId} 가 가리키는 원본 $targetId 가 원장에서 사라졌다.',
        );
        expect(byId[targetId]!.fillKind, FillKind.original);
      }
    });

    test('C-21 ④ 정정 두 행의 symbol·side 가 원본과 같다 (A13)', () {
      // 🔴 종목·방향 변경은 amend 가 아니라 `void` + 새 `record` 2명령이다
      //    (거부 코드 `AMEND_SYMBOL_OR_SIDE_CHANGE`).
      final Map<String, TradeJournalEntry> byId = <String, TradeJournalEntry>{
        for (final TradeJournalEntry e in rows) e.entryId: e,
      };

      for (final TradeJournalEntry row in rows.where(
        (TradeJournalEntry e) => e.fillKind != FillKind.original,
      )) {
        final TradeJournalEntry origin = byId[row.deviation.journalId]!;
        expect(
          row.symbol,
          origin.symbol,
          reason: '${row.entryId} 의 종목이 원본과 다르다.',
        );
        expect(row.side, origin.side, reason: '${row.entryId} 의 방향이 원본과 다르다.');
      }
    });

    test('C-21 ⑤ 정정 체인이 상한 안에 있다 (B6)', () {
      final Map<String, int> roundsPerTarget = <String, int>{};
      for (final TradeJournalEntry row in rows.where(
        (TradeJournalEntry e) => e.fillKind == FillKind.restatement,
      )) {
        final String target = row.deviation.journalId!;
        roundsPerTarget[target] = (roundsPerTarget[target] ?? 0) + 1;
      }
      roundsPerTarget.forEach((String target, int rounds) {
        expect(
          rounds,
          lessThanOrEqualTo(_amendChainLimit),
          reason: '$target 의 정정 라운드가 상한을 넘었다 — AMEND_LIMIT_EXCEEDED 대상이다.',
        );
      });
    });

    test('C-21 ⑥ 거부 사유 코드 2종이 §3-8 사전에 등재되어 있다', () {
      expect(
        AdviceRejectCodes.values,
        containsAll(<String>[
          AdviceRejectCodes.amendSymbolOrSideChange,
          AdviceRejectCodes.amendLimitExceeded,
          AdviceRejectCodes.amendTargetNotActive,
        ]),
      );
    });

    test(
      'C-21 ⑦ 수기 기록 UPDATE/DELETE 호출 0회',
      () {},
      skip: 'data_sync 구현체(SQLite 쓰기 경로)가 선행한다(인벤토리 §9 C-21 = 🟡).',
    );

    test(
      'C-21 ⑧ 정정 체인 상한 초과 제출 → 엔진 거부',
      () {},
      skip: '엔진 런타임이 선행한다 — 픽스처는 거부된 상태를 표현하지 않는다.',
    );
  });
}
