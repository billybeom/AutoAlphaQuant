// 🆕 E11q-d1b — M8 `B-02` 핸드북 «현재 상태» 값 원천(설계 13 §8 R236 · 06 M4-12 ① · 04 §8 «라이브 바인딩»).
//
// 🔴 읽을 때 짓기 · 저장 0 — 금 상한(SAF-308 총자산 금 비중 · 04 §1 Level 3 v2.27 · v2.46) = 가장 최근 평가 행의 날 기준:
//    그날 보유(지금 원장 보유 − 그 뒤 집행일 체결 · `holdingsBeforeFills`) · 그날 저장 종가 · 그 행의 원화 현금 →
//    일간 잡 경고 단계(`EquitySnapshotJob` · E3d-2)와 같은 셈 · 같은 판정(월 잡 307 집계 `ledgerExposureTallyOf` 와 같은 길).
// 🔴 원천이 없으면 값 0(키 없음) → 엔진이 그 블록을 뺀다(지어내지 않는다): 평가 행 없음 · 원장 재생 실패 · 종가 없음 ·
//    총자산 0 이하(`RiskCheckUnavailable`).
// 🔴 경고만 — 이 값은 주문을 막지 않는다(SAF-308 = 모니터링 규칙).

import 'package:core_engine/core_engine.dart'
    show
        EquitySnapshotRow,
        HandbookLiveKeys,
        HandbookLiveReading,
        LedgerHolding,
        P0sExposure,
        P0sWarnInputs,
        P0sWarnSetup,
        RiskCheckUnavailable,
        goldCapLiveReadingOf,
        holdingsBeforeFills,
        p0sExposureOf;
import 'package:domain_contracts/domain_contracts.dart' show RunMode, TradeDate;
import 'package:sqlite3/sqlite3.dart';

import '../jobs/daily_jobs.dart' show SqliteEquitySnapshotStore;
import 'monthly_report_source.dart' show ledgerCloseTextsOf;
import 'position_replay_sql.dart' show krSignedFillsAfter;

/// 핸드북 «현재 상태» 값이 읽는 표(바뀌면 다시 짓는다 — `watchLedgerQuery`).
const Set<String> kHandbookLiveWatchedTables = <String>{
  'equity_snapshot',
  'positions',
  'daily_prices',
  'executions',
  'broker_orders',
  'order_intents',
};

/// 원장 KR 보유(전략 · 종목 · 수량 — 0 행 포함 · 일간 잡의 보유와 같은 표).
List<LedgerHolding> _krHoldingsOf(Database db) => <LedgerHolding>[
  for (final Row r in db.select(
    "SELECT strategy_id, symbol, quantity FROM positions WHERE market = 'KR' "
    'ORDER BY strategy_id, symbol',
  ))
    LedgerHolding(
      r['strategy_id'] as String,
      r['symbol'] as String,
      r['quantity'] as int,
    ),
];

/// 🔴 «현재 상태» 값(키 → 값) — [setup] null(설정 못 읽음) · 원천 없음 = 빈 맵(블록 부재).
Map<String, HandbookLiveReading> ledgerHandbookLiveOf(
  Database db, {
  required RunMode mode,
  required P0sWarnSetup? setup,
  required DateTime nowUtc,
}) {
  final P0sWarnSetup? s = setup;
  if (s == null) return const <String, HandbookLiveReading>{};
  final EquitySnapshotRow? row = SqliteEquitySnapshotStore(
    db,
    mode: mode,
  ).latest();
  if (row == null) return const <String, HandbookLiveReading>{};
  final String d = row.tradeDate;
  try {
    final List<LedgerHolding> before = holdingsBeforeFills(
      _krHoldingsOf(db),
      krSignedFillsAfter(db, d),
    );
    final P0sWarnInputs i = P0sWarnInputs.fromTexts(
      holdings: before,
      closeTexts: ledgerCloseTextsOf(db, d, <String>{
        for (final LedgerHolding h in before) h.symbol,
      }),
      cashKrw: row.cashKrw,
    );
    final P0sExposure e = p0sExposureOf(
      holdings: i.holdings,
      closes: i.closes,
      cashKrw: i.cashKrw,
      cashUsdKrw: i.cashUsdKrw,
      map: s.map,
    );
    return <String, HandbookLiveReading>{
      HandbookLiveKeys.goldCap: goldCapLiveReadingOf(
        exposure: e,
        config: s.config,
        closeDate: TradeDate(d),
        nowUtc: nowUtc,
      ),
    };
  } on RiskCheckUnavailable {
    return const <String, HandbookLiveReading>{};
  }
}
