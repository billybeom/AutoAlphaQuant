// E11q-q6c(설계 13 §8 R240) — X7 원장 신뢰 등급 · 실사 예정 · 기한 표식 원천(`SqliteLedgerTrustSource`).
//
// 🔵 잡는 것: ① 마지막 실사 = 계좌별 최대 기준일 ② 한 달 주기(8/31 예정 + 알림 → 9/14 재고지 알림 → 9/29 기한 초과 · DUE
//    내림 · 알림 0 → 실사 1회 = 둘 다 내림) · 같은 날 · 서 있는 동안 다시 돌려도 알림 0(반복 금지) ③ reason = 그 달 · 그 계좌
//    L-3 · 대상이 바뀌면 reason 만 고침 ④ 투자 안내가 아니면 내린다 ⑤ 알림 목적지 = 서 있는 표식의 L-3 · 내려가면 사전 링크
//    ⑥ 배지 — 실사 갭 · 신뢰 시각 모름 = 갭 0 · 자동 매매 = 대사 한 판정 ⑦ 되돌림 = 전부.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 8, 31, 9, 30);

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

/// 한국 [m]-[d] 18:30(`daily_data`).
DateTime _kst(int m, int d) => DateTime.utc(2026, m, d, 9, 30);

const String _l3Aug = 'aaq://ledger/self-report/2026-08/연금저축';

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  final ExchangeCalendar kr = frozenExchangeCalendar(Market.kr);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e11q_q6c_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    clock = _Clock(_t0);
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteLedgerTrustSource src() => SqliteLedgerTrustSource(db, clock: clock);

  void audit(String alias, String asOf) => db.execute(
    'INSERT INTO self_report_balance (report_id, as_of_trade_date, account_alias, session_started_at, cash_krw, '
    "declared_complete, device_id, command_id, reported_at, cash_check) VALUES (?, ?, ?, ?, 0, 1, ?, ?, ?, 'NO_TOLERANCE')",
    <Object?>[
      'sr-$alias-$asOf',
      asOf,
      alias,
      '2026-09-01T00:00:00Z',
      'dev-1',
      'c-$alias-$asOf',
      '2026-09-01T00:00:00Z',
    ],
  );

  /// 서 있는 표식 → reason.
  Map<String, String> flags() => <String, String>{
    for (final Row r in db.select(
      'SELECT flag_id, reason FROM trading_block WHERE cleared_at IS NULL ORDER BY flag_id',
    ))
      r['flag_id'] as String: r['reason'] as String,
  };

  int alerts() =>
      db.select(
            'SELECT COUNT(*) AS n FROM alert_event WHERE code = ? AND source = ?',
            <Object?>[AlertCodes.selfAuditDue, kSelfAuditCheck],
          ).first['n']
          as int;

  SelfAuditFlagPlan run(
    DateTime now, {
    OperatingMode mode = OperatingMode.advisory,
  }) {
    clock.now = now;
    return src().refreshSelfAuditFor(
      operatingMode: mode,
      accounts: const <String>['일반', '연금저축'],
      trustedNowUtc: now,
      kr: kr,
    );
  }

  test('마지막 실사 = 계좌별 최대 기준일', () {
    audit('연금저축', '2026-06-30');
    audit('연금저축', '2026-07-31');
    audit('일반', '2026-08-31');
    expect(src().lastVerifiedByAccount(), <String, TradeDate>{
      '연금저축': TradeDate('2026-07-31'),
      '일반': TradeDate('2026-08-31'),
    });
    expect(SqliteLedgerTrustSource.watchedTables, <String>{
      'self_report_balance',
      'reconciliation_log',
    });
  });

  test('🔴 한 주기 — 예정(알림 1) → 같은 날 · 이튿날 0 → 재고지(알림 1) → 기한 초과(DUE 내림 · 알림 0) → 실사 1회 = 둘 다 내림', () {
    audit('일반', '2026-08-31');
    audit('연금저축', '2026-07-31');
    // 8/31 17:30 = 8월이 아직 닫히지 않았다.
    expect(run(DateTime.utc(2026, 8, 31, 8, 30)).due, isFalse);
    expect(flags(), isEmpty);
    expect(alerts(), 0);

    expect(run(_kst(8, 31)).alert, isTrue);
    expect(flags(), <String, String>{FlagIds.selfAuditDue: _l3Aug});
    expect(alerts(), 1);
    final String setAt =
        db.select(
              'SELECT set_at FROM trading_block WHERE flag_id = ?',
              <Object?>[FlagIds.selfAuditDue],
            ).first['set_at']
            as String;
    expect(DateTime.parse(setAt), _kst(8, 31));

    run(_kst(8, 31).add(const Duration(hours: 2)));
    run(_kst(9, 1));
    run(_kst(9, 13));
    expect(alerts(), 1);

    expect(run(_kst(9, 14)).alert, isTrue);
    expect(alerts(), 2);
    run(_kst(9, 15));
    run(_kst(9, 28));
    expect(alerts(), 2);

    final SelfAuditFlagPlan over = run(_kst(9, 29));
    expect((over.due, over.overdue, over.alert), (false, true, false));
    expect(flags(), <String, String>{FlagIds.selfAuditOverdue: _l3Aug});
    expect(alerts(), 2);
    // 9월이 닫히면 목적지만 9월로 · 선 시각 그대로.
    run(_kst(9, 30));
    expect(flags(), <String, String>{
      FlagIds.selfAuditOverdue: 'aaq://ledger/self-report/2026-09/연금저축',
    });
    expect(
      DateTime.parse(
        db.select(
              'SELECT set_at FROM trading_block WHERE flag_id = ?',
              <Object?>[FlagIds.selfAuditOverdue],
            ).first['set_at']
            as String,
      ),
      _kst(9, 29),
    );

    // 실사 1회(9월 기준일 — 차이가 있어도) = 둘 다 내림 · 내린 쪽 = 엔진 자동.
    audit('연금저축', '2026-09-30');
    audit('일반', '2026-09-30');
    expect(run(_kst(10, 2)).overdue, isFalse);
    expect(flags(), <String, String>{});
    expect(
      db.select(
        'SELECT cleared_by FROM trading_block WHERE flag_id = ?',
        <Object?>[FlagIds.selfAuditOverdue],
      ).first['cleared_by'],
      'auto:self_audit',
    );
    expect(alerts(), 2);
  });

  test('다른 계좌가 남으면 DUE 는 서 있고 목적지만 그 계좌로 — 알림 0', () {
    audit('일반', '2026-07-31');
    audit('연금저축', '2026-07-31');
    run(_kst(8, 31));
    expect(
      (flags()[FlagIds.selfAuditDue], alerts()),
      ('aaq://ledger/self-report/2026-08/일반', 1),
    );
    audit('일반', '2026-08-31');
    run(_kst(9, 2));
    expect((flags()[FlagIds.selfAuditDue], alerts()), (_l3Aug, 1));
  });

  test('🔴 투자 안내가 아니면 내린다(전환 뒤 남은 표식) · 알림 0', () {
    audit('연금저축', '2026-07-31');
    run(_kst(9, 29));
    expect(flags().keys, <String>[FlagIds.selfAuditOverdue]);
    final SelfAuditFlagPlan p = run(_kst(9, 29), mode: OperatingMode.autoTrade);
    expect((p.due, p.overdue, p.alert), (false, false, false));
    expect(flags(), <String, String>{});
  });

  test('🔴 알림 목적지 = 서 있는 실사 표식의 L-3 · 내려가면 사전 링크', () async {
    audit('연금저축', '2026-07-31');
    audit('일반', '2026-08-31');
    run(_kst(8, 31));
    final SqliteAlertRepository repo = SqliteAlertRepository(db, clock: clock);
    List<AlertItem> due() => <AlertItem>[
      for (final AlertItem a in alertInboxOf(
        rows: storedAlerts(db),
        nowUtc: clock.now,
      ))
        if (a.code == AlertCodes.selfAuditDue) a,
    ];
    expect(due().single.deepLink, _l3Aug);
    expect(
      (await repo.watchInbox().first)
          .where((AlertItem a) => a.code == AlertCodes.selfAuditDue)
          .single
          .deepLink,
      _l3Aug,
    );
    expect(selfAuditFlagLinkOf(db), _l3Aug);
    audit('연금저축', '2026-08-31');
    run(_kst(9, 1));
    expect(selfAuditFlagLinkOf(db), isNull);
    expect(due().single.deepLink, AppRoutes.ledgerTrust);
  });

  test('배지 — 실사 갭(표본 글자) · 신뢰 시각 모름 = 갭을 세지 않는다 · 기록 없음 = 기본', () {
    expect(
      src().selfAuditBadge(
        accounts: const <String>['연금저축'],
        trustedNowUtc: _kst(8, 31),
        kr: kr,
      ),
      selfReportTrustBadgeOf(null),
    );
    audit('연금저축', '2026-07-31');
    audit('일반', '2026-06-30');
    final LedgerTrustBadge due = src().selfAuditBadge(
      accounts: const <String>['연금저축'],
      trustedNowUtc: _kst(8, 31),
      kr: kr,
    );
    expect(
      (due.grade, due.consequenceLine, due.actionDeepLink),
      (
        LedgerTrustGrade.selfReported,
        '마지막 실사 후 31일 경과 — 이번 달 실사 1회로 등급이 유지됩니다',
        _l3Aug,
      ),
    );
    expect(
      src().selfAuditBadge(
        accounts: const <String>['연금저축', '일반'],
        trustedNowUtc: null,
        kr: kr,
      ),
      selfReportTrustBadgeOf(TradeDate('2026-06-30')),
    );
  });

  test('자동 매매 배지 = 브로커 대사 한 판정(지금까지) · 대사 0 = «아직»', () {
    expect(src().reconBadge().consequenceLine, LedgerTrustTexts.noReconNowLine);
    db.execute(
      'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
      "VALUES ('rc-1', '2026-09-01T22:00:00Z', 1, NULL, 'MATCHED')",
    );
    final LedgerTrustBadge b = src().reconBadge();
    expect(
      (b.grade, b.lastVerifiedOn),
      (LedgerTrustGrade.reconciled, TradeDate('2026-09-02')),
    );
  });

  test('되돌림 — 알림을 못 적으면 표식도 서지 않는다(한 트랜잭션)', () {
    audit('연금저축', '2026-07-31');
    db.execute(
      'CREATE TRIGGER no_alert BEFORE INSERT ON alert_event BEGIN SELECT RAISE(ABORT, \'x\'); END',
    );
    expect(() => run(_kst(8, 31)), throwsA(isA<SqliteException>()));
    expect(flags(), <String, String>{});
  });
}
