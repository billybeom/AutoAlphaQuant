// NR-1 2단계 «집합 판정»의 묶음 — `06_시스템설계/04_안전장치.md` §3-1 v2.33 ① 표 · 설계 13 §8 R34 U10.
//
// 🔴 열거의 정본은 계약 `FlagIds`(blocking 7 · markerOnly 4)다. 이 파일은 그 7개를 **효과별 세 묶음**으로 나눌
//    뿐이고, 세 묶음의 합 = `FlagIds.blocking` · 서로 겹치지 않음을 시험이 단언한다(묶음에 새 플래그를 빠뜨리면 실패).
// 🔴 `LEDGER_FIX` 는 X5 정정 트랜잭션의 뮤텍스라 판정 집합 밖이고, 표식 4종은 막지 않는다.
// 🔴 판정 SQL(`SELECT flag_id FROM trading_block WHERE cleared_at IS NULL AND flag_id IN (…묶음…)`)은 원장
//    쪽(data_sync · E10c)이 돌린다 — 여기는 «활성 플래그 집합 → 이 주문을 막는 플래그»의 순수 판정만.
// 🟡 «방어 매수 안내»(진입이 아닌 매수 — 청산·방어 안내는 유지)의 구분은 안내 모듈(E18) 몫 — 이 판은 안내
//    모드의 매수 = 진입으로 본다.

import 'package:domain_contracts/domain_contracts.dart';

/// 2단계 묶음(04 §3-1 v2.33 ①).
abstract final class BlockBundles {
  /// 전 주문 차단 — 모든 주문 · 안내 거부.
  static const Set<String> allOrders = <String>{
    FlagIds.reconMismatch,
    FlagIds.resumeIncomplete,
    FlagIds.ledgerIntegrity,
  };

  /// 신규 매수 차단 — 매수만 거부(청산 허용).
  static const Set<String> newBuys = <String>{
    FlagIds.journalMissing,
    FlagIds.tierBUnjudged,
  };

  /// 신규 진입 안내 중단(안내 모드) — 진입 안내만 내지 않는다(청산 · 방어 안내 유지).
  static const Set<String> entryAdvice = <String>{
    FlagIds.adviceLedgerUnverified,
    FlagIds.selfAuditOverdue,
  };
}

/// 활성 플래그([active] — `cleared_at IS NULL`) 가운데 이 주문을 막는 것(정렬). 비면 통과.
///
/// [advisory] = `operating_mode = 'ADVISORY'`(안내 모드). 묶음 밖 플래그(표식 · `LEDGER_FIX` · 모르는 값)는
/// 판정 SQL 이 읽지 않으므로 여기서도 보지 않는다.
List<String> blockingFlagsFor(
  Iterable<String> active, {
  required bool isBuy,
  required bool advisory,
}) {
  final Set<String> hits = <String>{
    for (final String f in active)
      if (BlockBundles.allOrders.contains(f) ||
          (isBuy && BlockBundles.newBuys.contains(f)) ||
          (isBuy && advisory && BlockBundles.entryAdvice.contains(f)))
        f,
  };
  return hits.toList()..sort();
}
