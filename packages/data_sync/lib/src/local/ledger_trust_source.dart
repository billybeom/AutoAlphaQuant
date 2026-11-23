// E11q-q6c — X7 원장 신뢰 등급 · 실사 예정 · 기한 표식 원장 원천(앱 계약 01 §2-11 · §3-5 · 02 §2-2 · §3-10 · 04 §2-1 9b ·
// 엔진 = core `ops/ledger_trust.dart` · 설계 13 §8 R240).
//
// 🔴 마지막 실사 = `self_report_balance` 계좌별 최대 기준일(정기 실사만 이 표에 적힌다 — R234 · 차이가 있어도 실사 1회).
// 🔴 표식 = `trading_block` `SELF_AUDIT_DUE`(표식 · 차단 아님) · `SELF_AUDIT_OVERDUE`(신규 진입 안내 중단) — reason = 그 달 ·
//    그 계좌 `L-3` 링크(해제 · 알림 목적지의 원천). 세우기 · 내리기 · 알림 = 한 트랜잭션(되돌리면 같이 사라진다) · 알림 =
//    엔진 계획(반복 금지 — 서는 때 1회 + D-15 재고지 1회).
// 🔴 배지 읽기 = 부작용 0 · 쓰기 = [SqliteLedgerTrustSource.refreshSelfAudit] 한 곳(엔진 일정 `daily_data` 뒤 · 실사 기록 뒤).
// 🔴 자동 매매 배지 = 브로커 대사 원장 한 판정(월간 리포트와 같은 `reconLedgerTrustOf` · as-of = 지금).

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        LedgerTrustTexts,
        SelfAuditFlagPlan,
        SelfAuditStage,
        SelfAuditVerdict,
        kSelfAuditCheck,
        reconLedgerTrustOf,
        selfAuditFlagPlanOf,
        selfAuditLinkOfReason,
        selfAuditRenoticeStartUtc,
        selfAuditTrustBadgeOf,
        selfAuditVerdictOf;
import 'package:domain_contracts/domain_contracts.dart'
    show AlertCodes, Clock, FlagIds, LedgerTrustBadge, OperatingMode, TradeDate;
import 'package:sqlite3/sqlite3.dart' show Database, ResultSet, Row;

import '../market/market_store.dart' show inLedgerTransaction;
import 'alert_store.dart' show SqliteAlertSink;
import 'monthly_report_source.dart' show brokerReconChecksOf;

/// 지금 서 있는 실사 표식의 그 달 · 그 계좌 `L-3` 링크(예정 먼저 · 기한 초과 · 없음 = null) — 알림 목적지(`SELF_AUDIT_DUE`).
String? selfAuditFlagLinkOf(Database db) {
  for (final Row r in db.select(
    'SELECT flag_id, reason FROM trading_block WHERE cleared_at IS NULL AND flag_id IN (?, ?) '
    'ORDER BY flag_id',
    <Object?>[FlagIds.selfAuditDue, FlagIds.selfAuditOverdue],
  )) {
    final String? link = selfAuditLinkOfReason(r['reason'] as String?);
    if (link != null) return link;
  }
  return null;
}

/// 원장 신뢰 등급 · 실사 표식 원천.
class SqliteLedgerTrustSource {
  /// 만든다 — [clock] = 알림 발생 기록(기기 시계 · 알림 저장과 같다).
  SqliteLedgerTrustSource(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 감시 표(배지가 이 표들의 변화로 다시 선다 · 실사 갭은 시간만 흘러도 바뀐다 — 주기는 부르는 쪽).
  static const Set<String> watchedTables = <String>{
    'self_report_balance',
    'reconciliation_log',
  };

  /// 계좌 → 마지막 정기 실사 기준일.
  Map<String, TradeDate> lastVerifiedByAccount() => <String, TradeDate>{
    for (final Row r in _db.select(
      'SELECT account_alias, MAX(as_of_trade_date) AS d FROM self_report_balance '
      'GROUP BY account_alias ORDER BY account_alias',
    ))
      r['account_alias'] as String: TradeDate(r['d'] as String),
  };

  /// 🔴 실사 갭 판정 — [trustedNowUtc] = 신뢰 시각(기기 시계 금지).
  SelfAuditVerdict selfAuditVerdict({
    required List<String> accounts,
    required DateTime trustedNowUtc,
    required ExchangeCalendar kr,
  }) => selfAuditVerdictOf(
    accounts: accounts,
    lastVerified: lastVerifiedByAccount(),
    trustedNowUtc: trustedNowUtc,
    kr: kr,
  );

  /// 투자 안내의 지금 배지 — 신뢰 시각을 모르면 갭을 세지 않는다(기본 배지 · 확인 날 = 계좌 가운데 가장 오래된 기준일).
  LedgerTrustBadge selfAuditBadge({
    required List<String> accounts,
    required DateTime? trustedNowUtc,
    required ExchangeCalendar kr,
  }) {
    final DateTime? now = trustedNowUtc;
    if (now != null) {
      return selfAuditTrustBadgeOf(
        selfAuditVerdict(accounts: accounts, trustedNowUtc: now, kr: kr),
      );
    }
    final Map<String, TradeDate> last = lastVerifiedByAccount();
    TradeDate? oldest;
    for (final String a in accounts) {
      final TradeDate? d = last[a];
      if (d != null &&
          (oldest == null || d.yyyyMmDd.compareTo(oldest.yyyyMmDd) < 0)) {
        oldest = d;
      }
    }
    return selfAuditTrustBadgeOf(
      SelfAuditVerdict(stage: SelfAuditStage.noAnchor, lastVerifiedOn: oldest),
    );
  }

  /// 자동 매매의 지금 배지 = 브로커 대사 원장 한 판정(월간 리포트와 같은 함수 · 지금까지).
  LedgerTrustBadge reconBadge({bool Function(String route)? hasBody}) =>
      reconLedgerTrustOf(
        checks: brokerReconChecksOf(_db),
        throughDay: null,
        noReconLine: LedgerTrustTexts.noReconNowLine,
        hasBody: hasBody,
      );

  /// 🔴 실사 표식 · 알림을 판정대로 맞춘다(한 트랜잭션) — [verdict] null = 투자 안내가 아니다(둘 다 내림) · [nowUtc] = 신뢰
  /// 시각(표식 선 시각 · 내린 시각). 돌려준 계획 = 한 일.
  SelfAuditFlagPlan refreshSelfAudit({
    required SelfAuditVerdict? verdict,
    required DateTime nowUtc,
  }) => inLedgerTransaction(_db, () {
    final DateTime? start = verdict == null
        ? null
        : selfAuditRenoticeStartUtc(verdict);
    final bool alerted =
        start != null &&
        _db
            .select(
              'SELECT raised_at FROM alert_event WHERE code = ?',
              <Object?>[AlertCodes.selfAuditDue],
            )
            .any(
              (Row r) =>
                  !DateTime.parse(r['raised_at'] as String)
                      .toUtc()
                      .isBefore(start),
            );
    final SelfAuditFlagPlan plan = selfAuditFlagPlanOf(
      verdict: verdict,
      dueActive: _activeReason(FlagIds.selfAuditDue) != null,
      alertedSinceRenotice: alerted,
    );
    _apply(FlagIds.selfAuditDue, plan.due, plan.reason, nowUtc);
    _apply(FlagIds.selfAuditOverdue, plan.overdue, plan.reason, nowUtc);
    if (plan.alert) {
      SqliteAlertSink(
        _db,
        clock: _clock,
      ).emitInTransaction(kSelfAuditCheck, <String>{AlertCodes.selfAuditDue});
    }
    return plan;
  });

  /// 운영 방식까지 받아 맞춘다(엔진 일정 · 실사 기록 뒤가 같이 쓴다) — 투자 안내 = 실사 갭 판정 · 그 밖 = 둘 다 내림
  /// (자동 매매에는 실사 표식이 서지 않는다 — 전환 뒤 남은 표식도 내린다).
  SelfAuditFlagPlan refreshSelfAuditFor({
    required OperatingMode operatingMode,
    required List<String> accounts,
    required DateTime trustedNowUtc,
    required ExchangeCalendar kr,
  }) => refreshSelfAudit(
    verdict: operatingMode == OperatingMode.advisory
        ? selfAuditVerdict(
            accounts: accounts,
            trustedNowUtc: trustedNowUtc,
            kr: kr,
          )
        : null,
    nowUtc: trustedNowUtc,
  );

  String? _activeReason(String flag) {
    final ResultSet r = _db.select(
      'SELECT reason FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
      <Object?>[flag],
    );
    return r.isEmpty ? null : r.first['reason'] as String;
  }

  void _apply(String flag, bool on, String? reason, DateTime nowUtc) {
    final String? current = _activeReason(flag);
    final String at = nowUtc.toUtc().toIso8601String();
    if (on) {
      final String why = reason!;
      if (current == null) {
        // PK = flag_id — 내려간 옛 행은 새로 서는 값으로 덮는다.
        _db.execute(
          'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?) '
          'ON CONFLICT(flag_id) DO UPDATE SET set_at = excluded.set_at, '
          'reason = excluded.reason, origin_code = NULL, cleared_at = NULL, '
          'cleared_by = NULL, decision_id = NULL',
          <Object?>[flag, at, why],
        );
      } else if (current != why) {
        // 대상 달 · 계좌가 바뀌었다(다음 달이 닫힘 · 앞 계좌 실사) — 선 시각은 그대로.
        _db.execute(
          'UPDATE trading_block SET reason = ? WHERE flag_id = ? AND cleared_at IS NULL',
          <Object?>[why, flag],
        );
      }
    } else if (current != null) {
      _db.execute(
        'UPDATE trading_block SET cleared_at = ?, cleared_by = ? '
        'WHERE flag_id = ? AND cleared_at IS NULL',
        <Object?>[at, 'auto:$kSelfAuditCheck', flag],
      );
    }
  }
}
