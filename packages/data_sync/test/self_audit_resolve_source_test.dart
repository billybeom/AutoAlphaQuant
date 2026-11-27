// 🆕 R280 — `M5-13` 원장 실사 해소 게이트 원장 원천(01 §8 미결 226 · 계약 v1.37 §46 K319 ~ K321) — 실 SQLite(live 원장).
//
// 🔴 다시 실사(K320) = 같은 기준일 · 계좌의 열린 차이가 남았을 때만 · 안 나온 행 = RESOLVED · 0오차 = 그 계좌 기준일까지 전부 RESOLVED ·
//    플래그 해제(K321 ④) = 실사 기록 트랜잭션 안 · 대응 계좌 전부 발동 뒤 기준일 0오차 · 보관 일괄 확정(K319) = 한 트랜잭션 ·
//    발동(K321 ①) = 문턱 값 없으면 0.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 10, 2, 3);

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

const CommandContext _ctx = CommandContext(
  runMode: RunMode.live,
  operatingMode: OperatingMode.advisory,
  leaseEpoch: 0,
  deviceId: 'dev-1',
);

const List<String> _accounts = <String>['일반', '연금저축'];

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

SelfReportBalance _wire(String alias, String asOf) => SelfReportBalance(
  asOfTradeDate: TradeDate(asOf),
  purpose: SelfReportPurpose.periodicAudit,
  sessionStartedAt: DateTime.utc(2026, 10, 2, 2),
  lines: const <SelfReportLine>[
    SelfReportLine(symbol: '133690', symbolLabel: '133690', quantity: 242),
  ],
  cashKrw: Decimal.fromInt(1250000),
  accountAlias: alias,
  declaredComplete: true,
  context: _ctx,
);

List<SelfReportDiffRow> _qty(String alias, String asOf, Map<String, int> d) =>
    selfReportDiffRowsOf(
      asOf: TradeDate(asOf),
      alias: alias,
      diffs: <SelfReportQuantityDiff>[
        for (final MapEntry<String, int> e in d.entries)
          SelfReportQuantityDiff(symbol: e.key, ledger: e.value, reported: 0),
      ],
    );

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  int seq = 0;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('r280_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    clock = _Clock(_t0);
    seq = 0;
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteSelfReportSource sr() => SqliteSelfReportSource(db, clock: clock);
  SqliteSelfAuditResolveSource gate() => SqliteSelfAuditResolveSource(db);

  void record(
    String alias,
    String asOf, {
    List<SelfReportDiffRow> diffs = const <SelfReportDiffRow>[],
    List<String> accounts = _accounts,
    DateTime? at,
    SelfReportCashCheck check = SelfReportCashCheck.noTolerance,
    double? tolerance,
  }) => sr().record(
    wire: _wire(alias, asOf),
    commandId: 'cmd-${++seq}',
    deviceId: 'dev-1',
    reportedAtUtc: at ?? _t0,
    diffs: diffs,
    cashCheck: check,
    cashToleranceKrw: tolerance,
    stateLabel: SelfReportTexts.executed,
    runMode: RunMode.live,
    operatingMode: OperatingMode.advisory,
    leaseEpoch: 0,
    accounts: accounts,
  );

  Map<String, String> statuses() => <String, String>{
    for (final Row r in db.select(
      'SELECT diff_id, status FROM ledger_diff ORDER BY diff_id',
    ))
      r['diff_id'] as String: r['status'] as String,
  };

  int count(String sql, [List<Object?> args = const <Object?>[]]) =>
      db.select(sql, args).first.columnAt(0) as int;

  void flag(String flagId, String setAt) => db.execute(
    'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
    <Object?>[flagId, setAt, 'test'],
  );

  group('다시 실사(K320)', () {
    test('🔴 열린 차이가 남은 기준일 · 계좌 = 다시 받는다 · 안 나온 행 RESOLVED · 다시 나온 행 = 같은 id 고쳐 씀 · 0오차 = 전부 RESOLVED', () {
      const String asOf = '2026-08-31';
      final List<SelfReportDiffRow> first = _qty('연금저축', asOf, <String, int>{
        '133690': 245,
        '069500': 7,
      });
      record('연금저축', asOf, diffs: first);
      expect(sr().openDiffsAt(const TradeDate(asOf), '연금저축'), isTrue);
      expect(sr().zeroErrorAudit(const TradeDate(asOf), '연금저축'), isFalse);
      final String gone = first.first.diffId; // 133690
      final String keep = first.last.diffId; // 069500
      clock.now = _t0.add(const Duration(hours: 1));
      record(
        '연금저축',
        asOf,
        diffs: _qty('연금저축', asOf, <String, int>{'069500': 8}),
        at: _t0.add(const Duration(hours: 1)),
      );
      expect(count('SELECT COUNT(*) FROM self_report_balance'), 2);
      expect(statuses(), <String, String>{keep: 'OPEN', gone: 'RESOLVED'});
      final Row row = db.select(
        'SELECT delta_label, detected_at FROM ledger_diff WHERE diff_id = ?',
        <Object?>[keep],
      ).single;
      expect(row['delta_label'], '069500 수량 −8주 (원장 8 / 자가 보고 0)');
      expect(row['detected_at'], '2026-10-02T04:00:00.000Z');
      // 닫힌 행이 다시 나오면 = 같은 id 를 다시 연다 · 이번에 안 나온 행 = 닫힌다.
      record(
        '연금저축',
        asOf,
        diffs: _qty('연금저축', asOf, <String, int>{'133690': 245}),
      );
      expect(statuses(), <String, String>{keep: 'RESOLVED', gone: 'OPEN'});
      record('연금저축', asOf);
      expect(statuses().values.toSet(), <String>{'RESOLVED'});
      expect(sr().openDiffsAt(const TradeDate(asOf), '연금저축'), isFalse);
      expect(sr().zeroErrorAudit(const TradeDate(asOf), '연금저축'), isTrue);
      expect(sr().latestZeroErrorByAccount(), <String, TradeDate>{
        '연금저축': const TradeDate(asOf),
      });
      // 열린 차이가 없으면 다시 받지 않는다(쓰기 0).
      expect(() => record('연금저축', asOf), throwsStateError);
      expect(count('SELECT COUNT(*) FROM self_report_balance'), 4);
      expect(count('SELECT COUNT(*) FROM command_inbox'), 4);
    });

    test('🔴 0오차 = 그 계좌 · 그 기준일까지만 RESOLVED(다른 계좌 · 더 늦은 기준일 = 그대로) · 차이 있는 실사 = 옛 행 그대로', () {
      final String aug = _qty('연금저축', '2026-08-31', <String, int>{
        '133690': 1,
      }).single.diffId;
      record(
        '연금저축',
        '2026-08-31',
        diffs: _qty('연금저축', '2026-08-31', <String, int>{'133690': 1}),
      );
      final String other = _qty('일반', '2026-08-31', <String, int>{
        '133690': 1,
      }).single.diffId;
      record(
        '일반',
        '2026-08-31',
        diffs: _qty('일반', '2026-08-31', <String, int>{'133690': 1}),
      );
      final String oct = _qty('연금저축', '2026-10-30', <String, int>{
        '133690': 1,
      }).single.diffId;
      record(
        '연금저축',
        '2026-10-30',
        diffs: _qty('연금저축', '2026-10-30', <String, int>{'133690': 1}),
      );
      expect(statuses(), <String, String>{
        aug: 'OPEN',
        other: 'OPEN',
        oct: 'OPEN',
      });
      // 9월 차이 있는 실사 = 8월 행 그대로.
      final String sep = _qty('연금저축', '2026-09-30', <String, int>{
        '069500': 1,
      }).single.diffId;
      record(
        '연금저축',
        '2026-09-30',
        diffs: _qty('연금저축', '2026-09-30', <String, int>{'069500': 1}),
      );
      expect(statuses()[aug], 'OPEN');
      // 9월 다시 실사 0오차 = 8월 · 9월만 닫는다.
      record('연금저축', '2026-09-30');
      expect(statuses(), <String, String>{
        aug: 'RESOLVED',
        other: 'OPEN',
        oct: 'OPEN',
        sep: 'RESOLVED',
      });
      expect(
        sr().zeroErrorAudit(const TradeDate('2026-08-31'), '연금저축'),
        isTrue,
      );
      expect(sr().latestZeroErrorByAccount(), <String, TradeDate>{
        '연금저축': const TradeDate('2026-09-30'),
      });
      expect(
        gate()
            .openSelfReportDiffs()
            .map((StoredLedgerDiff d) => d.diffId)
            .toSet(),
        <String>{other, oct},
      );
    });

    test(
      '🔴 R281 판정 칸 × 다시 실사 — 같은 기준일 · 계좌 실사가 여럿이면 가장 늦게 적은 실사의 현금 판정을 읽는다',
      () {
        const String asOf = '2026-08-31';
        record(
          '연금저축',
          asOf,
          diffs: _qty('연금저축', asOf, <String, int>{'133690': 1}),
        );
        expect(
          sr().cashCheckOf(const TradeDate(asOf), '연금저축'),
          SelfReportCashCheck.noTolerance,
        );
        record(
          '연금저축',
          asOf,
          at: _t0.add(const Duration(hours: 1)),
          check: SelfReportCashCheck.compared,
          tolerance: 1000,
        );
        expect(
          sr().cashCheckOf(const TradeDate(asOf), '연금저축'),
          SelfReportCashCheck.compared,
        );
        expect(count('SELECT COUNT(*) FROM self_report_balance'), 2);
      },
    );
  });

  group('플래그 해제(K321 ④)', () {
    test('🔴 대응 계좌 전부 발동한 날 이후 기준일 0오차 = 그 실사 트랜잭션에서 내림(수동 해제 0)', () {
      flag(FlagIds.adviceLedgerUnverified, '2026-09-01T00:30:00.000Z');
      expect(gate().unverifiedSetAt(), DateTime.utc(2026, 9, 1, 0, 30));
      record('일반', '2026-09-30');
      expect(gate().unverifiedSetAt(), isNotNull, reason: '연금저축 아직');
      record('연금저축', '2026-08-31');
      expect(gate().unverifiedSetAt(), isNotNull, reason: '기준일이 발동일 앞');
      record(
        '연금저축',
        '2026-09-30',
        diffs: _qty('연금저축', '2026-09-30', <String, int>{'133690': 1}),
      );
      expect(gate().unverifiedSetAt(), isNotNull, reason: '0오차 아님');
      record('연금저축', '2026-09-30', at: DateTime.utc(2026, 10, 2, 5));
      expect(gate().unverifiedSetAt(), isNull);
      final Row r = db.select(
        'SELECT cleared_at, cleared_by FROM trading_block WHERE flag_id = ?',
        <Object?>[FlagIds.adviceLedgerUnverified],
      ).single;
      expect(r['cleared_by'], 'auto:self_audit_resolve');
      expect(r['cleared_at'], '2026-10-02T05:00:00.000Z');
    });

    test('대응 계좌 0 = 풀지 않는다 · 플래그 없음 = 쓰기 0', () {
      flag(FlagIds.adviceLedgerUnverified, '2026-09-01T00:30:00.000Z');
      record('일반', '2026-09-30', accounts: const <String>[]);
      expect(gate().unverifiedSetAt(), isNotNull);
      expect(
        releaseAdviceLedgerUnverifiedIn(
          db,
          accounts: const <String>['일반'],
          nowUtc: _t0,
        ),
        isTrue,
      );
      expect(
        releaseAdviceLedgerUnverifiedIn(
          db,
          accounts: const <String>['일반'],
          nowUtc: _t0,
        ),
        isFalse,
      );
    });
  });

  group('보관 일괄 확정(K319)', () {
    void held(String id, String at, {String kind = 'SELF_REPORT_BALANCE'}) =>
        db.execute(
          'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
          "decision_id, run_mode, operating_mode, lease_epoch, payload_digest) VALUES (?, ?, ?, 'HELD_FOR_INTEGRITY', "
          "'보류됨', NULL, NULL, 'LIVE', 'ADVISORY', 0, 'd')",
          <Object?>[id, kind, at],
        );

    test('🔴 판정(인자 → 무결성 → 묶음) · 거부 = 쓰기 0 · 확정 = 묶음 전부 RECEIVED(엔진 글자 · 확정 시각) · 버림 0', () {
      held('cmd_b', '2026-09-02T01:31:00.000Z');
      held('cmd_a', '2026-09-02T01:14:00.000Z', kind: 'JOURNAL_DRAFT');
      final List<StoredHeldCommand> h = gate().heldCommands();
      final String id = heldReviewIdOf(h)!;
      final DateTime now = DateTime.utc(2026, 9, 2, 1, 40);
      HeldReviewWrite go(Map<String, String> a) =>
          gate().confirmHeld(args: a, nowUtc: now);
      expect(
        go(const <String, String>{'review_id': '그냥 다 확정'}).code,
        HeldReviewResultCodes.argsInvalid,
      );
      flag(FlagIds.ledgerIntegrity, '2026-09-02T00:00:00.000Z');
      expect(gate().integrityActive(), isTrue);
      expect(
        go(<String, String>{'review_id': id}).code,
        HeldReviewResultCodes.integrityActive,
      );
      db.execute(
        "UPDATE trading_block SET cleared_at = '2026-09-02T01:35:00.000Z' WHERE flag_id = ?",
        <Object?>[FlagIds.ledgerIntegrity],
      );
      expect(
        go(const <String, String>{'review_id': 'hr_000000000000'}).code,
        HeldReviewResultCodes.stale,
      );
      expect(
        count(
          "SELECT COUNT(*) FROM command_inbox WHERE state = 'HELD_FOR_INTEGRITY'",
        ),
        2,
      );
      final HeldReviewWrite ok = go(<String, String>{'review_id': id});
      expect((ok.code, ok.confirmed), (null, 2));
      expect(
        <(String, String, String)>[
          for (final Row r in db.select(
            'SELECT command_id, state, state_label FROM command_inbox ORDER BY command_id',
          ))
            (
              r['command_id'] as String,
              r['state'] as String,
              r['state_label'] as String,
            ),
        ],
        <(String, String, String)>[
          (
            'cmd_a',
            'RECEIVED',
            '접수됨 — 2026-09-02 10:40 보관 확정 · 보통 접수 규칙으로 처리합니다',
          ),
          (
            'cmd_b',
            'RECEIVED',
            '접수됨 — 2026-09-02 10:40 보관 확정 · 보통 접수 규칙으로 처리합니다',
          ),
        ],
      );
      expect(gate().heldCommands(), isEmpty);
      expect(
        go(<String, String>{'review_id': id}).code,
        HeldReviewResultCodes.stale,
      );
    });
  });

  group('미처리 갭 원천 · 발동(K321 ① ②)', () {
    void advice(
      String id, {
      required String from,
      required String until,
      String status = 'EXPIRED',
      String kind = 'ENTRY',
      String? account = '일반',
      String? close,
    }) => db.execute(
      'INSERT INTO advice (advice_id, batch_id, decision_id, mode, trade_date, valid_until_date, kind, sleeve, '
      'reason, reason_code, account_alias, status, close_reason_code, sizing_label, config_hash, created_at) '
      "VALUES (?, 'b1', 'd1', 'LIVE', ?, ?, ?, 'A', 'r', 'rc', ?, ?, ?, 's', 'cfg', '2026-09-01T00:00:00Z')",
      <Object?>[id, from, until, kind, account, status, close],
    );

    test('만료 = 저장 EXPIRED ∪ 마감 지난 OPEN · PARTIAL — 회수 · NO_ACTION 제외 · 창 = NO_ACTION 제외', () {
      advice('a1', from: '2026-08-25', until: '2026-09-01');
      advice(
        'a2',
        from: '2026-08-25',
        until: '2026-09-02',
        status: 'OPEN',
        account: null,
      );
      advice('a3', from: '2026-09-07', until: '2026-09-30', status: 'OPEN');
      advice('a4', from: '2026-08-25', until: '2026-09-01', kind: 'NO_ACTION');
      advice(
        'a5',
        from: '2026-08-25',
        until: '2026-09-01',
        status: 'REVOKED',
        close: 'HANDOVER_CLOSED',
      );
      advice(
        'a6',
        from: '2026-08-25',
        until: '2026-09-01',
        status: 'EXPIRED',
        close: 'HANDOVER_CLOSED',
      );
      advice('a7', from: '2026-08-25', until: '2026-09-01', status: 'FILLED');
      final List<LapsedAdvice> l = gate().lapsedAdvices(
        const TradeDate('2026-09-10'),
      );
      expect(
        l.map((LapsedAdvice a) => (a.deadline.yyyyMmDd, a.accountAlias)),
        <(String, String?)>[('2026-09-01', '일반'), ('2026-09-02', null)],
      );
      expect(gate().adviceWindows(), hasLength(6));
      expect(
        gate().unprocessedGap(
          accounts: _accounts,
          today: const TradeDate('2026-09-10'),
          kr: _kr,
        ),
        // 09-01 뒤 · 창이 열린 거래일 = 09-02(a2) · 09-07 · 08 · 09 · 10(a3) = 5.
        5,
      );
    });

    test(
      '🔴 문턱 null = 발동 0(미결 118 ⓐ) · 문턱 있음 ∧ 갭 ≥ 문턱 = 한 번 세움 · 이미 서 있음 = 그대로',
      () {
        advice('a1', from: '2026-08-25', until: '2026-09-01');
        advice('a3', from: '2026-09-02', until: '2026-09-30', status: 'OPEN');
        final DateTime now = DateTime.utc(2026, 9, 10, 9);
        bool refresh(int? t, {OperatingMode mode = OperatingMode.advisory}) =>
            gate().refreshUnverified(
              operatingMode: mode,
              accounts: _accounts,
              trustedNowUtc: now,
              kr: _kr,
              thresholdTradingDays: t,
            );
        expect(refresh(null), isFalse);
        expect(gate().unverifiedSetAt(), isNull);
        expect(refresh(3, mode: OperatingMode.autoTrade), isFalse);
        expect(refresh(100), isFalse);
        expect(refresh(3), isTrue);
        expect(gate().unverifiedSetAt(), now);
        expect(
          db.select(
            'SELECT reason FROM trading_block WHERE flag_id = ?',
            <Object?>[FlagIds.adviceLedgerUnverified],
          ).single['reason'],
          '미처리 갭 7거래일 — 강등 문턱 3거래일 이상',
        );
        expect(refresh(3), isFalse);
      },
    );
  });
}
