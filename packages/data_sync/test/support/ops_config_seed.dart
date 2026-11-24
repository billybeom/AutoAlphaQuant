// 🆕 리뷰 3차 H2-02(설계 13 §8 R265 · 미결 231 ⓑ) — 시험 받침: 지금 설정(P0S 판 등재 + 그 원장 모드의 개시 결정)을 심는다.
//
// 🔴 운영 경로 = 모의 개시(`SqliteOnboardingStore.declareSimOpening`) · simToAuto 커밋(`OPENING_BALANCE`) — 여기는 그 두 행의
//    꼴(사유 코드 = `openingReasonCodeOf(모드)`)만 심는다: 설정 원천만 보는 저장 시험(S5 고름 · 승격 등)용.
//    커밋 → 실전 잡 → 관찰 끝까지 = 앱 `operator_handover_test` A-1(손으로 심지 않는다).
import 'package:core_engine/core_engine.dart'
    show P0sHumanInputs, P0sOpsConfig, P0sStrategyIds, kstDateText;
import 'package:data_sync/data_sync.dart'
    show SqliteConfigVersionStore, openingReasonCodeOf;
import 'package:domain_contracts/domain_contracts.dart' show Clock, RunMode;
import 'package:sqlite3/sqlite3.dart';

/// 시험 계좌 대응(넷).
const Map<String, String> kSeedAccounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

/// 시험 P0S 설정 판 내용(사람 값 = A 종목 · 계좌 넷).
Map<String, Object?> seedP0sConfigContent({String aSymbol = '229200'}) =>
    P0sOpsConfig.of(
      P0sHumanInputs(aSymbol: aSymbol, accountByStrategy: kSeedAccounts),
    ).content();

/// [db] 에 [mode] 원장의 개시 결정을 심는다 — [hash] 없음 = P0S 판을 등재해 붙인다 · 붙인 지문을 돌려준다 ·
/// [reasonCode] = 다른 원장의 개시 코드를 일부러 심을 때만(행 모드 = [mode] 그대로 — 파일 DDL 검사).
String seedOpening(
  Database db,
  RunMode mode, {
  required Clock clock,
  String? hash,
  String decisionId = 'SEED-OPEN',
  String? reasonCode,
}) {
  final String h =
      hash ??
      SqliteConfigVersionStore(
        db,
        clock: clock,
      ).register(seedP0sConfigContent());
  final DateTime now = clock.nowUtc().toUtc();
  db.execute(
    'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
    "reason_code, config_hash) VALUES (?, ?, ?, ?, 'MANUAL', 'P0S', '시험 개시', ?, ?)",
    <Object?>[
      decisionId,
      now.toIso8601String(),
      kstDateText(now),
      mode.wire,
      reasonCode ?? openingReasonCodeOf(mode),
      h,
    ],
  );
  return h;
}
