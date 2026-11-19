// 🆕 E11q2 — 원장 사실 → What-if 상태(설계 13 §8 R173 · R18 D-4 «실데이터 어댑터 = E11» · q2 · q3 공유).
//
// 🔴 순수 조립이다(조회 · 저장 0) — 원장 원문은 data_sync 가 모은다(금액 = 글자 · 01 §1-1).
// 🔴 회계 상태 = 월말 잡과 같은 함수(`monthEndStateFromLedger`) · 같은 입력 꼴(보유 · as-of 원가 종가 · 계좌 현금 · POT 현금 ·
//    연금 누계 · 회차 번호 · 국면 · 달마다 마지막 수정 종가 · 다음 세션 유무) — 보유 현황(H6-1 · `HoldingsOverviewFacts`)이
//    모은 장부를 그대로 쓴다(세 화면 + 미리보기 = 한 장부).
// 🔴 슬리브 평가액 = 미리보기 비중과 같은 회계 셈([accountingSleeveValuesOf] — A = POT 포함 · C = 원화 현금 · 채권 · 금 ·
//    재분류 파킹).
// 🔴 기준일 = 장부 기준일(보유 종목 마지막 원가 종가의 가장 이른 날) · 지정가 기준 = 그날 원가 종가.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AsOfSource, BlockFlag;

import '../calendar/exchange_calendar.dart';
import '../ops/holdings_overview.dart'
    show HoldingPositionFact, HoldingsOverviewFacts;
import '../ops/month_end_inputs.dart' show monthEndStateFromLedger;
import '../orders/reconcile.dart' show LedgerHolding;
import '../portfolio/month_end_plan.dart';
import '../signals/regime_states.dart' show DirectionState;
import 'deposit_register.dart' show LedgerCashRow, pensionUsedInYear;
import 'rebalance_preview.dart' show accountingSleeveValuesOf;
import 'what_if_state.dart';

/// 원장 사실 → 미리보기 상태 — [facts] = 보유 현황 장부(현금 포함) · [pensionOutsideText] = 시스템 밖 연금 납입 신고(원 · 글자).
/// 귀속 · 종가 · 현금 실패 = `MonthEndInputError`(Future 에러 = «계산을 못 했다»).
WhatIfState whatIfStateFromLedger({
  required HoldingsOverviewFacts facts,
  required Iterable<LedgerCashRow> pensionRows,
  required int monthIndex,
  required DirectionState? regimeState,
  required Map<String, List<double>> monthlyCloses,
  required bool hasNextKrSession,
  required bool hasNextUsSession,
  required String configHash,
  required List<BlockFlag> activeFlags,
  required bool recovery,
  required WhatIfAccounts accounts,
  required ExchangeCalendar krCalendar,
  String pensionOutsideText = '0',
  Set<String> unknownSymbols = const <String>{},
}) {
  final Decimal? outside = Decimal.tryParse(pensionOutsideText);
  if (outside == null || outside < Decimal.zero) {
    throw ArgumentError.value(pensionOutsideText, 'pensionOutsideText');
  }
  final String? pension = accounts.pensionAlias;
  final Decimal used = pension == null
      ? outside
      : pensionUsedInYear(
          pensionRows,
          pensionAlias: pension,
          year: int.parse(facts.closeDate.yyyyMmDd.substring(0, 4)),
          declaredOutside: outside,
        );
  final MonthEndState st = monthEndStateFromLedger(
    holdings: <LedgerHolding>[
      for (final HoldingPositionFact p in facts.positions)
        if (p.quantity > 0) LedgerHolding(p.strategyId, p.symbol, p.quantity),
    ],
    closes: facts.closes,
    cashKrw: facts.cashKrw,
    potCash: facts.potCash,
    reservedKrw: facts.reservedKrw ?? Decimal.zero,
    pensionUsedThisYear: used,
    monthIndex: monthIndex,
    regimeState: regimeState,
    monthlyCloses: monthlyCloses,
    hasNextKrSession: hasNextKrSession,
    hasNextUsSession: hasNextUsSession,
    config: facts.config.monthEnd,
    parkingSymbol: facts.config.parkingSymbol,
  );
  return WhatIfState(
    asOfTradeDate: facts.closeDate,
    configHash: configHash,
    activeFlags: activeFlags,
    recovery: recovery,
    accounts: accounts,
    pensionUsedThisYear: used,
    observedAt: facts.nowUtc.toUtc(),
    source: AsOfSource.localSqlite,
    sleeveValues: accountingSleeveValuesOf(st),
    prices: facts.closes,
    unknownSymbols: unknownSymbols,
    monthEnd: st,
    krCalendar: krCalendar,
  );
}
