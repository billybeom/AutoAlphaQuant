// 🆕 E16j-a — 정정 직전 재대사(01 §8 미결 217 ⓒ · 설계 13 §8 R227 · core `freshReconDiffIds`).
//
// 🔴 한 판 · 재확인 대기 0 · 쓰기 0(대사 기록 · 플래그 · diff 행 0) — 정정 커밋의 «delta 같음» 재료만 낸다.
// 🔴 원장 · 모드 = 화면 상태 · 브로커 = 주문 잡과 같은 조립(`cashBrokersFor` — simInternal = 가상 체결 · live = KIS 계좌) ·
//    계좌 맵 = 지금 설정 · 그 날 = 정정할 diff 의 집행일(diff id 가 그 날로 만들어진다).
// 🔴 못 하면 null(모름) — 설정 없음 · 브로커 미조립(simBroker) · 조회 실패 · 예외. 정정 쪽이 «잠시 뒤 다시»(지어내지 않는다).

import 'package:core_engine/core_engine.dart'
    show AccountBroker, BrokerBalanceSource, OrderBroker, freshReconDiffIds;
import 'package:data_sync/data_sync.dart'
    show OpsConfigRead, OpsConfigReady, SqliteOrderLedger, currentP0sOpsConfig;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, RunMode, TradeDate;
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart' show JobCalendars;

import 'data_job_runners.dart' show JobParts;
import 'ledger_job_runners.dart' show cashBrokersFor;

/// 잡 이름(브로커 미조립 사유에 실린다).
const String kRepairReconJob = 'x5_repair_recon';

/// 🔴 정정 직전 재대사 — [tradeDate] 의 diff id 들 · 못 하면 null.
Future<Set<String>?> operatorFreshReconIds({
  required Database db,
  required RunMode runMode,
  required Clock clock,
  required JobCalendars calendars,
  required JobParts parts,
  required TradeDate tradeDate,
}) async {
  try {
    final OpsConfigRead r = currentP0sOpsConfig(db, runMode);
    if (r is! OpsConfigReady) return null;
    final Map<String, AccountBroker> brokers = cashBrokersFor(
      db: db,
      runMode: runMode,
      clock: clock,
      parts: parts,
      cfg: r.config,
      job: kRepairReconJob,
    );
    return await freshReconDiffIds(
      ledger: SqliteOrderLedger(
        db,
        mode: runMode,
        clock: clock,
        kr: calendars.kr,
      ),
      brokers: <String, OrderBroker>{...brokers},
      balances: <String, BrokerBalanceSource>{...brokers},
      accountByStrategy: r.config.human.accountByStrategy,
      tradeDate: tradeDate,
    );
  } on Object {
    return null;
  }
}
