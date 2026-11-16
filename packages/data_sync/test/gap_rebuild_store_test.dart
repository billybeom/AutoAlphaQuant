// E16h1 — X1-4 새 폰 복구 저널 · 갭 재구성 적용 · 백업 갭 원천(설계 13 §8 R137 N1~N12).
//
// 🔵 잡는 것: ① 복구 시작 거부 차례(core → epoch → 이미 있음) · RESTORED = 매니페스트 정규 글자 · 기기 · 역할 필터 · 깨진 저널
//    ② 백업 갭 = 매니페스트 날 ~ RESTORED 시각(고정) · 봉인 원천 ③ 갭 재구성 — 창 세션만 조회 · 알려진 번호 · 취소 행 빼기 ·
//    의도 · 주문 · 체결 칸(BROKER_RECOVERED · executed_at = 주문 시각 · authored_at = 지금) · 씨앗 재생 포지션 · GAP_REBUILT · 멱등
//    ④ 위반(어긋남 · 중간 음수 · 대응 없음 · 둘 이상 = 대응 없음) = 대사 차단 · 복구 행 0 · 한 계좌 위반 = 전 계좌 0 · 빈 창 보유 대조.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 11, 16, 1);
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final ExchangeCalendar _kr = ExchangeCalendar(
  market: Market.kr,
  sessions: <TradeDate>[
    for (final String d in <String>[
      '2026-11-09',
      '2026-11-10',
      '2026-11-12',
      '2026-11-13',
      '2026-11-16',
      '2026-11-17',
    ])
      TradeDate(d),
  ],
  coverageStart: const TradeDate('2026-11-01'),
  coverageEnd: const TradeDate('2026-11-30'),
);

/// 복원 = 11-16 10:00 한국.
final DateTime _restoredAt = DateTime.utc(2026, 11, 16, 1);

/// 재구성 = 11-16 10:30 한국.
final DateTime _now = DateTime.utc(2026, 11, 16, 1, 30);

const Map<String, String> _accounts = <String, String>{
  'P0S_A': 'isa',
  'P0S_B': 'pension',
  'P0S_C': 'pension',
};

const FillCostRates _costs = FillCostRates(
  commissionRate: 0.0001,
  sellTaxRate: 0.002,
);

BackupManifest _manifest({String date = '2026-11-10', int epoch = 0}) =>
    BackupManifest(
      sha256: 'a' * 64,
      chainHash: 'b' * 64,
      authoredDate: date,
      schemaVersion: 1,
      hashFormatVersion: 1,
      operatorEpoch: epoch,
      writerDeviceId: 'dev-old',
    );

DailyFillRow _row(
  String date,
  String odno, {
  OrderSide side = OrderSide.buy,
  String symbol = '069500',
  int qty = 5,
  int? cum,
  int remaining = 0,
  bool cancelRow = false,
  String? time = '093015',
}) => DailyFillRow(
  orderDate: TradeDate(date),
  odno: odno,
  isCancelRow: cancelRow,
  symbol: symbol,
  side: side,
  orderQty: qty,
  cumFilledQty: cum ?? qty,
  cumFilledAmount: Decimal.fromInt((cum ?? qty) * 35000),
  remainingQty: remaining,
  orderPrice: Decimal.fromInt(35000),
  orderTime: time,
);

void main() {
  late Directory dir;
  late Database db;
  late _Trusted trusted;
  late SqliteOrderLedger ledger;
  late FakeOrderBroker pension;
  late FakeOrderBroker isa;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_gap_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _restoredAt);
    trusted = _Trusted(_restoredAt);
    ledger = SqliteOrderLedger(
      db,
      mode: RunMode.live,
      clock: _Clock(),
      kr: _kr,
    );
    pension = FakeOrderBroker();
    isa = FakeOrderBroker();
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteRecoveryJournal journal({String device = 'dev-new'}) =>
      SqliteRecoveryJournal(db, deviceId: device, trusted: trusted);

  ({String? runId, String? rejectCode}) start({
    MigrationKind kind = MigrationKind.emergency,
    OperatingMode mode = OperatingMode.autoTrade,
    String? decision = 'dec-x1',
    int epoch = 1,
    BackupManifest? manifest,
    String device = 'dev-new',
  }) => journal(device: device).start(
    kind: kind,
    operatingMode: mode,
    decisionId: decision,
    operatorEpoch: epoch,
    manifest: manifest ?? _manifest(),
  );

  void position(
    String strategy,
    String symbol,
    int qty, {
    double avg = 30000,
    String? decision = 'B@2026-11-02',
  }) => db.execute(
    'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, '
    "updated_at, entry_decision_id) VALUES ('KR', ?, ?, ?, ?, '2026-11-02', 'x', ?)",
    <Object?>[symbol, strategy, qty, avg, decision],
  );

  void intent(String id, String strategy, String account, String symbol) =>
      db.execute(
        'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
        "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
        "'2026-11-02', 'KR', ?, ?, 'X@2026-11-02', ?, 'BUY', 'LIMIT', 1, 'SKIPPED', 'c', 'x', 'LIVE')",
        <Object?>[id, 'k-$id', account, strategy, symbol],
      );

  SqliteGapRebuild rebuild() => SqliteGapRebuild(
    db,
    deviceId: 'dev-new',
    trusted: trusted,
    kr: _kr,
    ledger: ledger,
  );

  Future<GapRebuildReport> run() => rebuild().run(
    brokers: <String, AccountBroker>{'pension': pension, 'isa': isa},
    accountByStrategy: _accounts,
    configHash: 'cfg-1',
    operatingMode: OperatingMode.autoTrade,
    costs: _costs,
  );

  int count(String table) =>
      db.select('SELECT COUNT(*) AS n FROM $table').single['n'] as int;

  Row? positionOf(String strategy, String symbol) {
    final ResultSet r = db.select(
      "SELECT * FROM positions WHERE market = 'KR' AND strategy_id = ? AND symbol = ?",
      <Object?>[strategy, symbol],
    );
    return r.isEmpty ? null : r.single;
  }

  group('SqliteRecoveryJournal — 새 폰 복구 저널', () {
    test(
      '🔴 시작 = NEW_DEVICE run + RESTORED(매니페스트 정규 글자) · 백업 갭 = 매니페스트 날 ~ 복원 시각',
      () {
        final BackupManifest m = _manifest();
        final ({String? runId, String? rejectCode}) s = start(manifest: m);
        expect(s.rejectCode, isNull);
        expect(s.runId, 'mig-2026-11-16-1');
        final Row run = db.select('SELECT * FROM migration_run').single;
        expect(run['role'], 'NEW_DEVICE');
        expect(run['device_id'], 'dev-new');
        expect(run['kind'], 'EMERGENCY');
        expect(run['operator_epoch'], 1);
        expect(run['decision_id'], 'dec-x1');
        final Row step = db.select('SELECT * FROM migration_step').single;
        expect(step['step'], 'RESTORED');
        expect(step['state'], 'DONE');
        expect(step['detail_json'], m.toCanonicalJson());
        expect(step['at'], _restoredAt.toIso8601String());
        final RecoveryRun r = journal().latest()!;
        expect(r.runId, s.runId);
        expect(r.kind, MigrationKind.emergency);
        expect(r.operatorEpoch, 1);
        expect(r.decisionId, 'dec-x1');
        expect(r.manifest.toCanonicalJson(), m.toCanonicalJson());
        expect(r.restoredAtUtc, _restoredAt);
        expect(r.gapRebuilt, isFalse);
        expect(r.gapRebuiltAtUtc, isNull);
        expect(r.backupGapDays, 6);
        // 🔴 복구 시각 = RESTORED 행 — 지금 시각이 흘러도 갭은 그대로.
        trusted.at = DateTime.utc(2026, 11, 20);
        expect(recoveryBackupGapDaysOf(db, 'dev-new'), 6);
        expect(gapRebuildDoneOf(db, 'dev-new'), isFalse);
      },
    );

    test('복구 없음 = 갭 null · 봉인 원천 true(복구 중 아님)', () {
      expect(recoveryBackupGapDaysOf(db, 'dev-new'), isNull);
      expect(gapRebuildDoneOf(db, 'dev-new'), isTrue);
      expect(journal().latest(), isNull);
    });

    test('거부 차례 — core(결정 · 안내 모드 · 신뢰 시각) → epoch → 이미 있음', () {
      expect(start(decision: null).rejectCode, 'EMERGENCY_NOT_DECLARED');
      expect(
        start(kind: MigrationKind.plan, decision: null).rejectCode,
        'D03_NOT_CONFIRMED',
      );
      expect(
        start(mode: OperatingMode.advisory).rejectCode,
        'X1_ADVISORY_PENDING',
      );
      expect(start(epoch: 0).rejectCode, 'X1_EPOCH_NOT_ADVANCED');
      expect(
        start(epoch: 3, manifest: _manifest(epoch: 3)).rejectCode,
        'X1_EPOCH_NOT_ADVANCED',
      );
      trusted.at = null;
      expect(start(epoch: 0).rejectCode, 'TRUSTED_TIME_UNKNOWN');
      trusted.at = _restoredAt;
      expect(count('migration_run'), 0);
      expect(start(epoch: 4, manifest: _manifest(epoch: 3)).rejectCode, isNull);
      expect(start().rejectCode, 'X1_RUN_EXISTS');
      // 다른 기기는 제 복구를 시작한다 · 순번이 이어진다.
      final ({String? runId, String? rejectCode}) other = start(
        device: 'dev-other',
      );
      expect(other.runId, 'mig-2026-11-16-2');
      expect(journal().latest()!.operatorEpoch, 4);
    });

    test('모의 파일 = X1_LIVE_ONLY', () {
      final Database sim = openLocalLedger(
        dir.path,
        RunMode.simInternal,
        clock: () => _restoredAt,
      );
      addTearDown(sim.close);
      expect(
        SqliteRecoveryJournal(sim, deviceId: 'dev-new', trusted: trusted)
            .start(
              kind: MigrationKind.emergency,
              operatingMode: OperatingMode.autoTrade,
              decisionId: 'dec-x1',
              operatorEpoch: 1,
              manifest: _manifest(),
            )
            .rejectCode,
        'X1_LIVE_ONLY',
      );
    });

    test('옛 폰 행(OLD_DEVICE · 다른 기기)은 복구가 아니다 · RESTORED 없는 복구 = 깨진 저널', () {
      db.execute(
        'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
        "VALUES ('mig-2026-11-15-1', 'PLAN', 'OLD_DEVICE', 'dev-new', 0, 'd', '2026-11-15T01:00:00.000Z')",
      );
      expect(journal().latest(), isNull);
      db.execute(
        'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
        "VALUES ('mig-2026-11-15-2', 'EMERGENCY', 'NEW_DEVICE', 'dev-new', 1, 'd', '2026-11-15T02:00:00.000Z')",
      );
      expect(() => journal().latest(), throwsStateError);
      expect(() => gapRebuildDoneOf(db, 'dev-new'), throwsStateError);
    });

    test('🔴 이 기기의 옛 폰 행(OLD_DEVICE)은 복구 시작을 막지 않는다', () {
      db.execute(
        'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
        "VALUES ('mig-2026-11-15-1', 'PLAN', 'OLD_DEVICE', 'dev-new', 0, 'd', '2026-11-15T01:00:00.000Z')",
      );
      final ({String? runId, String? rejectCode}) s = start();
      expect(s.rejectCode, isNull);
      expect(s.runId, 'mig-2026-11-16-1');
    });

    test('마지막 복구 = 시작 시각 차례(글자 차례 아님)', () {
      for (final (String id, String at) in <(String, String)>[
        ('mig-2026-11-16-10', '2026-11-16T02:00:00.000Z'),
        ('mig-2026-11-16-9', '2026-11-16T01:00:00.000Z'),
      ]) {
        db.execute(
          'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
          "VALUES (?, 'EMERGENCY', 'NEW_DEVICE', 'dev-new', 1, 'd', ?)",
          <Object?>[id, at],
        );
        db.execute(
          "INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, 'RESTORED', 'DONE', ?, ?)",
          <Object?>[id, _manifest().toCanonicalJson(), at],
        );
      }
      expect(journal().latest()!.runId, 'mig-2026-11-16-10');
    });

    test('recordGapRebuilt = 트랜잭션 밖이면 StateError', () {
      expect(
        () => recordGapRebuilt(db, 'x', _now, const <String, Object?>{}),
        throwsStateError,
      );
    });
  });

  group('SqliteGapRebuild — 갭 재구성 적용', () {
    test('복원 없음 = X1_NOT_RESTORED · 신뢰 시각 모름 = 거부 · 브로커 0', () async {
      final GapRebuildReport a = await run();
      expect(a.rejectCode, 'X1_NOT_RESTORED');
      expect(a.done, isFalse);
      start();
      trusted.at = null;
      final GapRebuildReport b = await run();
      expect(b.rejectCode, 'TRUSTED_TIME_UNKNOWN');
      expect(pension.fillReads, 0);
      expect(count('migration_step'), 1);
    });

    test(
      '🔴 복구 행 · 씨앗 재생 포지션 · GAP_REBUILT — 창 세션만 · 알려진 번호 · 취소 행 · 체결 0 빼기',
      () async {
        position('P0S_B', '069500', 10);
        start();
        trusted.at = _now;
        // 이미 원장에 있는 주문 번호(복원 스냅숏에 실려 온 것).
        intent('known', 'P0S_B', 'pension', '069500');
        db.execute(
          'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status, filled_qty, remaining_qty) '
          "VALUES ('2026-11-10:0009', 'known', 'x', 'FILLED', 1, 0)",
        );
        pension.fills['2026-11-10'] = <DailyFillRow>[
          _row('2026-11-10', '0009', qty: 1),
        ];
        pension.fills['2026-11-12'] = <DailyFillRow>[
          _row('2026-11-12', '0001'),
          _row('2026-11-12', '0003', cum: 0, remaining: 5),
          _row('2026-11-12', '0001', cancelRow: true),
        ];
        pension.fills['2026-11-13'] = <DailyFillRow>[
          _row(
            '2026-11-13',
            '0002',
            side: OrderSide.sell,
            qty: 3,
            time: '101500',
          ),
        ];
        // 창 밖(복구 날) — 조회하지 않는다.
        pension.fills['2026-11-16'] = <DailyFillRow>[
          _row('2026-11-16', '0099'),
        ];
        pension.holdings['069500'] = 12;
        final GapRebuildReport r = await run();
        expect(r.rejectCode, isNull);
        expect(r.blocked, isFalse);
        expect(r.done, isTrue);
        expect(r.sessions, 3);
        expect(r.recovered, <String, List<String>>{
          'pension': <String>['rcv-2026-11-12:0001', 'rcv-2026-11-13:0002'],
        });
        expect(pension.fillReads, 3);
        expect(isa.fillReads, 3);

        final Row buy = db
            .select(
              "SELECT * FROM order_intents WHERE intent_id = 'rcv-2026-11-12:0001'",
            )
            .single;
        expect(buy['status'], 'FILLED');
        expect(buy['error_message'], 'X1_RECOVERED');
        expect(buy['dry_run'], 0);
        expect(buy['order_type'], 'LIMIT');
        expect(buy['limit_price'], 35000.0);
        expect(buy['account'], 'pension');
        expect(buy['strategy_id'], 'P0S_B');
        expect(buy['decision_id'], 'dec-x1@2026-11-12');
        expect(buy['config_hash'], 'cfg-1');
        expect(buy['mode'], 'LIVE');
        expect(buy['operating_mode'], OperatingMode.autoTrade.wire);
        expect(buy['created_at'], _now.toIso8601String());
        expect(buy['updated_at'], _now.toIso8601String());
        expect(buy['trade_date'], '2026-11-12');

        final Row bo = db
            .select(
              "SELECT * FROM broker_orders WHERE broker_order_no = '2026-11-12:0001'",
            )
            .single;
        expect(bo['intent_id'], 'rcv-2026-11-12:0001');
        expect(bo['status'], 'FILLED');
        expect(bo['filled_qty'], 5);
        expect(bo['remaining_qty'], 0);
        expect(bo['avg_fill_price'], 35000.0);
        expect(bo['submitted_at'], '2026-11-12T00:30:15.000Z');
        expect(
          jsonDecode(bo['raw_response'] as String),
          isA<Map<String, dynamic>>(),
        );

        final Row ex = db
            .select(
              "SELECT * FROM executions WHERE broker_order_no = '2026-11-13:0002'",
            )
            .single;
        expect(ex['execution_id'], '2026-11-13:0002#3');
        expect(ex['fill_origin'], 'BROKER_RECOVERED');
        expect(ex['cost_source'], 'ESTIMATED');
        expect(ex['executed_at'], '2026-11-13T01:15:00.000Z');
        expect(ex['authored_at'], _now.toIso8601String());
        expect(ex['quantity'], 3);
        expect(ex['price'], 35000.0);
        expect(
          (ex['commission'] as num).toDouble(),
          closeTo(3 * 35000 * 0.0001, 1e-9),
        );
        expect((ex['tax'] as num).toDouble(), closeTo(3 * 35000 * 0.002, 1e-9));
        final Row exBuy = db
            .select(
              "SELECT tax FROM executions WHERE broker_order_no = '2026-11-12:0001'",
            )
            .single;
        expect((exBuy['tax'] as num).toDouble(), 0);
        expect(count('executions'), 2);

        // 씨앗(10 @ 30000) + 매수 5 @ 35000 − 매도 3 = 12 · 평단 = (10×30000 + 5×35000)/15.
        final Row p = positionOf('P0S_B', '069500')!;
        expect(p['quantity'], 12);
        expect((p['avg_price'] as num).toDouble(), closeTo(475000 / 15, 1e-6));
        expect(p['entry_date'], '2026-11-02');
        expect(p['entry_decision_id'], 'B@2026-11-02');
        expect(p['updated_at'], _now.toIso8601String());

        final Row step = db
            .select("SELECT * FROM migration_step WHERE step = 'GAP_REBUILT'")
            .single;
        expect(step['state'], 'DONE');
        expect(step['at'], _now.toIso8601String());
        expect(jsonDecode(step['detail_json'] as String), <String, Object?>{
          'from': '2026-11-10',
          'to': '2026-11-15',
          'sessions': 3,
          'recovered': <String, Object?>{'pension': 2},
        });
        final RecoveryRun rr = journal().latest()!;
        expect(rr.gapRebuilt, isTrue);
        expect(rr.gapRebuiltAtUtc, _now);
        expect(gapRebuildDoneOf(db, 'dev-new'), isTrue);
        expect(count('reconciliation_log'), 0);

        // 멱등 — 이미 끝남 = 브로커를 부르지 않는다 · 쓰기 0.
        final GapRebuildReport again = await run();
        expect(again.alreadyDone, isTrue);
        expect(again.done, isTrue);
        expect(pension.fillReads, 3);
        expect(count('executions'), 2);
      },
    );

    test('새 포지션(의도 이력으로 전략 · 결정 없는 씨앗 없음) · 0 으로 판 포지션 = 지움 · 시장가', () async {
      position('P0S_B', '069500', 10, decision: null);
      intent('h-1', 'P0S_A', 'isa', '360750');
      start();
      trusted.at = _now;
      isa.fills['2026-11-12'] = <DailyFillRow>[
        DailyFillRow(
          orderDate: const TradeDate('2026-11-12'),
          odno: '0005',
          isCancelRow: false,
          symbol: '360750',
          side: OrderSide.buy,
          orderQty: 2,
          cumFilledQty: 2,
          cumFilledAmount: Decimal.fromInt(40000),
          remainingQty: 0,
          orderTime: '100000',
        ),
      ];
      isa.holdings['360750'] = 2;
      pension.fills['2026-11-13'] = <DailyFillRow>[
        _row('2026-11-13', '0006', side: OrderSide.sell, qty: 10),
      ];
      final GapRebuildReport r = await run();
      expect(r.done, isTrue);
      final Row a = positionOf('P0S_A', '360750')!;
      expect(a['quantity'], 2);
      expect((a['avg_price'] as num).toDouble(), 20000);
      expect(a['entry_date'], '2026-11-12');
      expect(a['entry_decision_id'], 'dec-x1@2026-11-12');
      expect(positionOf('P0S_B', '069500'), isNull);
      expect(
        db
            .select(
              "SELECT order_type, limit_price FROM order_intents WHERE intent_id = 'rcv-2026-11-12:0005'",
            )
            .single
            .values,
        <Object?>['MARKET', null],
      );
    });

    test('🔴 씨앗 결정이 없으면(NULL) 더 사도 NULL 그대로 · 보유 전략으로 대응(의도 이력 없어도)', () async {
      position('P0S_B', '069500', 10, decision: null);
      start();
      trusted.at = _now;
      pension.fills['2026-11-12'] = <DailyFillRow>[_row('2026-11-12', '0001')];
      pension.holdings['069500'] = 15;
      final GapRebuildReport r = await run();
      expect(r.done, isTrue);
      final Row p = positionOf('P0S_B', '069500')!;
      expect(p['quantity'], 15);
      expect(p['entry_date'], '2026-11-02');
      expect(p['entry_decision_id'], isNull);
    });

    test('🔴 같은 날은 주문 시각 차례로 재생(번호 차례 아님)', () async {
      intent('h-1', 'P0S_A', 'isa', '360750');
      start();
      trusted.at = _now;
      // 번호 차례로는 판 뒤에 산다(음수) — 시각 차례로는 산 뒤에 판다.
      isa.fills['2026-11-12'] = <DailyFillRow>[
        _row(
          '2026-11-12',
          '0001',
          side: OrderSide.sell,
          symbol: '360750',
          qty: 3,
          time: '140000',
        ),
        _row('2026-11-12', '0002', symbol: '360750', qty: 3, time: '090000'),
      ];
      final GapRebuildReport r = await run();
      expect(r.done, isTrue);
      expect(r.recovered['isa'], <String>[
        'rcv-2026-11-12:0002',
        'rcv-2026-11-12:0001',
      ]);
      expect(positionOf('P0S_A', '360750'), isNull);
    });

    test('빈 창(백업 = 복구 날) = 조회 0 · 보유 대조는 한다', () async {
      position('P0S_B', '069500', 10);
      start(manifest: _manifest(date: '2026-11-16'));
      trusted.at = _now;
      pension.holdings['069500'] = 10;
      final GapRebuildReport ok = await run();
      expect(ok.done, isTrue);
      expect(ok.sessions, 0);
      expect(pension.fillReads, 0);
      expect(
        jsonDecode(
          db
                  .select(
                    "SELECT detail_json FROM migration_step WHERE step = 'GAP_REBUILT'",
                  )
                  .single['detail_json']
              as String,
        ),
        <String, Object?>{
          'from': null,
          'to': null,
          'sessions': 0,
          'recovered': <String, Object?>{},
        },
      );
    });

    test('빈 창에서도 보유가 다르면 차단', () async {
      position('P0S_B', '069500', 10);
      start(manifest: _manifest(date: '2026-11-16'));
      trusted.at = _now;
      pension.holdings['069500'] = 9;
      final GapRebuildReport r = await run();
      expect(r.blocked, isTrue);
      expect(r.violations['pension']!.single.kind, GapViolationKind.mismatch);
    });

    test('🔴 어긋남 = 대사 차단(diff · RECON_MISMATCH · 위반 글자) · 복구 행 0 · GAP_REBUILT 0 · 다시 돌리면 다시 센다', () async {
      position('P0S_B', '069500', 10);
      start();
      trusted.at = _now;
      pension.fills['2026-11-12'] = <DailyFillRow>[_row('2026-11-12', '0001')];
      pension.holdings['069500'] = 16;
      final GapRebuildReport r = await run();
      expect(r.blocked, isTrue);
      expect(r.done, isFalse);
      expect(r.reconId, isNotNull);
      expect(r.recovered, isEmpty);
      final GapViolation v = r.violations['pension']!.single;
      expect(v.kind, GapViolationKind.mismatch);
      expect(v.ledgerAfter, 15);
      expect(v.broker, 16);
      expect(r.violations.containsKey('isa'), isFalse);
      final Row log = db.select('SELECT * FROM reconciliation_log').single;
      expect(log['recon_id'], r.reconId);
      expect(log['matched'], 0);
      expect(log['action_taken'], 'BLOCKED');
      final Map<String, dynamic> d =
          jsonDecode(log['discrepancies'] as String) as Map<String, dynamic>;
      expect(d['kind'], 'X1_GAP_REBUILD');
      expect(d['window'], <String, Object?>{
        'from': '2026-11-10',
        'to': '2026-11-15',
      });
      expect(d['violations'], <Object?>[
        <String, Object?>{
          'account': 'pension',
          'kind': 'GAP_HOLDING_MISMATCH',
          'symbol': '069500',
          'ledger_after': 15,
          'broker': 16,
        },
      ]);
      final Row diff = db.select('SELECT * FROM ledger_diff').single;
      expect(diff['pair'], 'CANON_BROKER');
      expect(diff['axis'], 'QUANTITY');
      expect(diff['severity'], 'BLOCKING');
      expect(diff['status'], 'OPEN');
      expect(diff['authored_date'], '2026-11-16');
      final Map<String, dynamic> delta =
          jsonDecode(diff['delta'] as String) as Map<String, dynamic>;
      expect(
        <Object?>[
          delta['account'],
          delta['kind'],
          delta['key'],
          delta['ledger'],
          delta['broker'],
        ],
        <Object?>['pension', 'QTY', '069500', 15, 16],
      );
      expect(
        db.select(
          "SELECT 1 FROM trading_block WHERE flag_id = 'RECON_MISMATCH' AND cleared_at IS NULL",
        ),
        hasLength(1),
      );
      expect(count('order_intents'), 0);
      expect(count('executions'), 0);
      expect(positionOf('P0S_B', '069500')!['quantity'], 10);
      expect(gapRebuildDoneOf(db, 'dev-new'), isFalse);
      // 다시 돌리면 다시 센다(브로커를 다시 부른다).
      final GapRebuildReport again = await run();
      expect(again.blocked, isTrue);
      expect(pension.fillReads, 6);
    });

    test('중간 음수 = QTY 차단(끝 수량이 맞아도)', () async {
      position('P0S_B', '069500', 10);
      start();
      trusted.at = _now;
      pension.fills['2026-11-12'] = <DailyFillRow>[
        _row('2026-11-12', '0001', side: OrderSide.sell, qty: 15),
      ];
      pension.fills['2026-11-13'] = <DailyFillRow>[_row('2026-11-13', '0002')];
      pension.holdings['069500'] = 0;
      final GapRebuildReport r = await run();
      expect(r.violations['pension']!.single.kind, GapViolationKind.oversold);
      expect(
        db.select('SELECT axis FROM ledger_diff').single['axis'],
        'QUANTITY',
      );
      expect(count('executions'), 0);
    });

    test(
      '대응 없음(이력 없음 · 둘 이상) = UNMAPPED_STRATEGY 차단 · ledger/broker = 계좌 보유',
      () async {
        position('P0S_B', '411060', 4);
        position('P0S_C', '411060', 6);
        start();
        trusted.at = _now;
        pension.fills['2026-11-12'] = <DailyFillRow>[
          _row('2026-11-12', '0001', symbol: '411060', qty: 2),
          _row('2026-11-12', '0002', symbol: '999999', qty: 1),
        ];
        pension.holdings['411060'] = 12;
        pension.holdings['999999'] = 1;
        final GapRebuildReport r = await run();
        expect(r.blocked, isTrue);
        final List<GapViolation> v = r.violations['pension']!;
        expect(
          v.map((GapViolation g) => '${g.kind.wire}:${g.symbol}'),
          <String>[
            'GAP_UNMAPPED_STRATEGY:411060',
            'GAP_UNMAPPED_STRATEGY:999999',
          ],
        );
        // 411060: 복원 10(4 + 6) · 브로커 12 / 999999: 복원 0 · 브로커 1.
        final List<List<Object?>> deltas =
            <List<Object?>>[
              for (final Row x in db.select('SELECT delta FROM ledger_diff'))
                () {
                  final Map<String, dynamic> m =
                      jsonDecode(x['delta'] as String) as Map<String, dynamic>;
                  return <Object?>[
                    m['key'],
                    m['kind'],
                    m['ledger'],
                    m['broker'],
                  ];
                }(),
            ]..sort(
              (List<Object?> a, List<Object?> b) =>
                  (a[0]! as String).compareTo(b[0]! as String),
            );
        expect(deltas, <List<Object?>>[
          <Object?>['411060', 'UNMAPPED_STRATEGY', 10, 12],
          <Object?>['999999', 'UNMAPPED_STRATEGY', 0, 1],
        ]);
        expect(count('executions'), 0);
      },
    );

    test('🔴 한 계좌만 위반이어도 다른 계좌 복구 행 0', () async {
      position('P0S_B', '069500', 10);
      start();
      trusted.at = _now;
      pension.fills['2026-11-12'] = <DailyFillRow>[_row('2026-11-12', '0001')];
      pension.holdings['069500'] = 15;
      isa.holdings['360750'] = 3;
      final GapRebuildReport r = await run();
      expect(r.blocked, isTrue);
      expect(r.violations.keys, <String>['isa']);
      expect(count('order_intents'), 0);
      expect(count('executions'), 0);
      expect(positionOf('P0S_B', '069500')!['quantity'], 10);
    });
  });
}
