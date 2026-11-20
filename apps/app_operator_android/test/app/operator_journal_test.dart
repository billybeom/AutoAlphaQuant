// E11q-q4a — M6 매매일지 «읽기» 조립(J-1 · J-2 · J-3R · 회차 범위 · 기간 프리셋 · 슬리브) — 실 SQLite(sim 원장).
//
// 🔴 화면 상태의 원장 → data_sync 원천 → 엔진 VM · 🔴 감시 표 빠짐 없이(표마다 쓰면 다시 낸다) · 링크 = 셸이 실제로 쓰는
//    레지스트리에 본문이 있는 화면만 · 원장 한 파일(모드 인자 무시 · 01 §8 미결 89) · 쓰기 · 보드 = 원천 없음(q4b).

import 'dart:async';

import 'package:app_operator_android/app/operator_journal.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show Market, P0sStrategyIds, frozenExchangeCalendar, routePatternOf;
import 'package:data_sync/data_sync.dart' show SqliteJournalSource;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

OperatorView _viewOf(Database db) => OperatorView(
  db: db,
  flags: const FeatureFlags(
    satelliteEnabled: false,
    webViewerEnabled: false,
    calendarEnabled: false,
    runMode: RunMode.simInternal,
    operatingMode: OperatingMode.autoTrade,
    configHash: 'cfg_test',
  ),
);

Future<void> until(bool Function() ok, [String? what]) async {
  for (int i = 0; i < 300 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue, reason: what);
}

const DateRange _all = DateRange(
  from: TradeDate('2026-01-02'),
  to: TradeDate('2026-08-31'),
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2026, 8, 31, 18, 0));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  Database db() => files.sim;

  OperatorRuntime rt({bool view = true}) {
    final OperatorRuntime r = OperatorRuntime(files: files, clock: clock);
    if (view) r.view.value = _viewOf(db());
    return r;
  }

  OperatorJournalRepository repo(
    OperatorRuntime r, {
    Duration tick = const Duration(hours: 1),
  }) => OperatorJournalRepository(
    r,
    hasBody: kOperatorRouteBodies.byPattern.containsKey,
    tick: tick,
  );

  void intent(
    String id,
    String decision, {
    String status = 'FILLED',
    String trade = '2026-08-03',
  }) => db().execute(
    'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
    'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
    "updated_at, mode) VALUES (?, ?, '2026-08-03T00:10:00.000Z', ?, 'KR', 'pension', ?, ?, '133690', 'BUY', "
    "'LIMIT', 10, 20000, ?, 'cfg', '2026-08-03T00:10:00.000Z', 'SIM_INTERNAL')",
    <Object?>[id, 'k-$id', trade, P0sStrategyIds.sleeveB, decision, status],
  );

  test('🔴 레지스트리 = 일지 읽기 넷(J-1 · J-2 · J-3R · 회차 조건) · 쓰기 · 보드 = 아직(q4b)', () {
    for (final String r in <String>[
      AppRoutes.journalTimeline,
      AppRoutes.journalDecision,
      AppRoutes.journalRead,
      AppRoutes.journalRebalance,
    ]) {
      expect(kOperatorRouteBodies.byPattern.containsKey(r), true, reason: r);
    }
    for (final String r in <String>[
      AppRoutes.journalDraft,
      AppRoutes.journalUnknownBoard,
      AppRoutes.journalBlindReview,
    ]) {
      expect(kOperatorRouteBodies.byPattern.containsKey(r), false, reason: r);
    }
  });

  test('빈 원장 = 엔진 빈 문장 · 필터 출처 = 모의 · 배지 없음', () async {
    final OperatorJournalRepository r = repo(rt());
    final ListResult<TradeJournalEntry> t = await r
        .watchTimeline(range: _all)
        .first;
    expect(t.rows, isEmpty);
    expect(t.emptyLabel, startsWith('아직 기록된 거래가 없습니다'));
    expect(
      (await r.watchFilterCatalog().first).originOptions.single.origin,
      FillOrigin.simulated,
    );
    expect(await r.watchTimelineBadges().first, isEmpty);
  });

  test(
    '🔴 감시 표 빠짐 없이 — 표마다 쓰면 J-1 이 다시 낸다(의도 · 주문 · 체결 · 결정 · 회차 · 계획 · 저널 · 차단)',
    () async {
      expect(SqliteJournalSource.watchedTables, <String>{
        'order_intents',
        'broker_orders',
        'executions',
        'decision_log',
        'decision_journal',
        'rebalance_event',
        'plan_snapshot',
        'trading_block',
      });
      final List<ListResult<TradeJournalEntry>> got =
          <ListResult<TradeJournalEntry>>[];
      final StreamSubscription<ListResult<TradeJournalEntry>> sub = repo(rt())
          .watchTimeline(range: _all)
          .listen(got.add);
      addTearDown(sub.cancel);
      TradeJournalEntry? row([String id = 'iB']) {
        if (got.isEmpty) return null;
        for (final TradeJournalEntry e in got.last.rows) {
          if (e.entryId == id) return e;
        }
        return null;
      }

      await until(() => got.isNotEmpty, 'first');
      // order_intents
      intent('iB', 'B-SMA-2026-07-31@2026-08-03', status: 'PARTIAL');
      await until(() => row()?.entryId == 'iB', 'order_intents');
      // broker_orders
      db().execute(
        'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) '
        "VALUES ('2026-08-03:0001', 'iB', '2026-08-03T00:20:00.000Z', 'SUBMITTED')",
      );
      await until(
        () => row()?.decision.brokerOrderNo == '2026-08-03:0001',
        'broker_orders',
      );
      // executions
      db().execute(
        'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, commission, tax, '
        "fill_origin, cost_source) VALUES ('X#4', '2026-08-03:0001', '2026-08-03T01:00:00.000Z', 4, 20000, 0, 0, "
        "'SIMULATED', 'ESTIMATED')",
      );
      await until(() => row()?.quantityText == '4주', 'executions');
      // decision_log(논리 id 결정 — 사유 칩 · 저널 id)
      db().execute(
        'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
        "reason_code, config_hash, journal_id) VALUES ('B-SMA-2026-07-31', '2026-07-31T09:00:00.000Z', "
        "'2026-07-31', 'SIM_INTERNAL', 'REBALANCE', 'P0S_B', '밴드', 'REBALANCE_BAND', 'cfg', 'J1')",
      );
      await until(
        () => row()?.reasons.single.code == 'REBALANCE_BAND',
        'decision_log',
      );
      // rebalance_event(회차 결정 = 그 논리 id → 묶인다)
      db().execute(
        'INSERT INTO rebalance_event (event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
        "weights_before, weights_after, config_hash, created_at) VALUES ('REB-MONTHLY-2026-07-31', '2026-07-31', "
        "'SIM_INTERNAL', 'MONTHLY_REGULAR', 'B-SMA-2026-07-31', '{}', '[]', '[]', 'cfg', "
        "'2026-07-31T09:00:00.000Z')",
      );
      await until(
        () => row()?.rebalanceEventId == 'REB-MONTHLY-2026-07-31',
        'rebalance_event',
      );
      // plan_snapshot(그 달 계획 대상 → 다른 논리 id 의 의도가 묶인다)
      intent('iC', 'C-REBAL-2026-07-31@2026-08-03');
      await until(() => row('iC') != null, 'order_intents 2');
      expect(row('iC')!.rebalanceEventId, isNull);
      db().execute(
        'INSERT INTO plan_snapshot (plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, '
        "config_hash) VALUES ('REBAL-2026-07-31', 'REBALANCE', '2026-07-31T09:00:00.000Z', '2026-07-31', "
        "'2026-08-31', '{}', '{\"targets\":[{\"logical_decision_id\":\"C-REBAL-2026-07-31\"}]}', 'cfg')",
      );
      await until(
        () => row('iC')?.rebalanceEventId == 'REB-MONTHLY-2026-07-31',
        'plan_snapshot',
      );
      // decision_journal(이탈 저널 → 이탈 배지)
      db().execute(
        'INSERT INTO decision_journal (journal_id, trade_date, strategy_id, signal_value, action_taken, '
        "is_deviation, created_at) VALUES ('J1', '2026-08-03', 'P0S_B', '{}', '{}', 1, '2026-08-03T00:05:00.000Z')",
      );
      await until(
        () => row()?.deviation.isDeviation ?? false,
        'decision_journal',
      );
      // trading_block
      db().execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-08-31T00:00:00.000Z', 'x')",
      );
      await until(() => row()?.quantityText == '숨김', 'trading_block');
    },
  );

  test(
    'J-2 · J-3R · 회차 범위 = 같은 원장 · 링크 = 레지스트리 · 모르는 결정 = 오류 · 모르는 회차 = null',
    () async {
      intent('iB', 'B-SMA-2026-07-31@2026-08-03');
      intent('iU', 'X@2026-08-04', status: 'UNKNOWN', trade: '2026-08-04');
      final OperatorJournalRepository r = repo(rt());
      final TradeJournalEntry row =
          (await r.watchTimeline(range: _all).first).rows.last;
      expect(
        row.detailDeepLink,
        'aaq://journal/decision/B-SMA-2026-07-31@2026-08-03',
      );
      expect(routePatternOf(row.detailDeepLink!), AppRoutes.journalDecision);
      final DecisionDetailVm d = await r
          .watchDecisionDetail('B-SMA-2026-07-31@2026-08-03')
          .first;
      expect(d.entry, row);
      expect(d.steps.length, 6);
      final DecisionJournalVm j = await r
          .watchDecisionJournal('B-SMA-2026-07-31@2026-08-03')
          .first;
      expect((j.journalStateLabel, j.body), ('저널 미작성', null));
      expect(
        j.decisionLink!.deepLink,
        'aaq://journal/decision/B-SMA-2026-07-31@2026-08-03',
      );
      await expectLater(
        r.watchDecisionDetail('none'),
        emitsError(isA<StateError>()),
      );
      await expectLater(
        r.watchDecisionJournal('none'),
        emitsError(isA<StateError>()),
      );
      expect(await r.watchRebalanceScope('none').first, isNull);
      // 미해소 보드(q4b) 미등록 = 배지 탭 반응 없음.
      final JournalTimelineBadge b =
          (await r.watchTimelineBadges().first).single;
      expect((b.label, b.deepLink), ('확인 중 1건', null));
    },
  );

  test(
    '🔵 원장 한 파일 — 모드 인자(J-1 은 늘 LIVE 로 부른다 · 미결 89)로 거르지 않는다 · 행이 모드를 말한다',
    () async {
      intent('iB', 'B-SMA-2026-07-31@2026-08-03');
      final ListResult<TradeJournalEntry> t = await repo(rt())
          .watchTimeline(range: _all, mode: RunMode.live)
          .first;
      expect(t.rows.single.mode, RunMode.simInternal);
    },
  );

  test('🔴 화면 상태 없음 = 오류 · 쓰기 · 보드 · 조각 조회 = 원천 없음(지어내지 않는다)', () async {
    final OperatorJournalRepository none = repo(rt(view: false));
    await expectLater(
      none.watchTimeline(range: _all),
      emitsError(isA<StateError>()),
    );
    final OperatorJournalRepository r = repo(rt());
    await expectLater(
      r.watchUnknownBoard(),
      emitsError(isA<UnsupportedError>()),
    );
    await expectLater(
      r.watchBlindReviewQueue(),
      emitsError(isA<UnsupportedError>()),
    );
    await expectLater(
      r.watchBlindReviewCard('d'),
      emitsError(isA<UnsupportedError>()),
    );
    await expectLater(r.draftFormSpec('d'), throwsA(isA<UnsupportedError>()));
    await expectLater(
      r.findByDecisionId('d'),
      throwsA(isA<UnsupportedError>()),
    );
    await expectLater(r.chainOf('d'), throwsA(isA<UnsupportedError>()));
    await expectLater(r.fillChain('e'), throwsA(isA<UnsupportedError>()));
  });

  group('셸 설정 원천 — 기간 프리셋 · 슬리브', () {
    OperatorConfigRepository cfg(
      OperatorRuntime r, {
      Duration tick = const Duration(milliseconds: 20),
    }) => OperatorConfigRepository(
      r.view,
      clock: clock,
      kr: frozenExchangeCalendar(Market.kr),
      tick: tick,
    );

    test('프리셋 = 엔진 거래일 달력(기본 하나) · 슬리브 = 4(POT = A 소속)', () async {
      final List<DateRange> p = await cfg(rt()).watchRangePresets().first;
      expect(
        <String?>[for (final DateRange d in p) d.presetCode],
        <String?>['LAST_30D', 'THIS_MONTH', 'THIS_YEAR', 'ALL'],
      );
      expect(p.where((DateRange d) => d.isDefault).length, 1);
      expect(p.first.from, const TradeDate('2026-07-31'));
      final List<SleeveCatalogEntry> s = await cfg(rt()).watchSleeves().first;
      expect(
        <SleeveId>[for (final SleeveCatalogEntry e in s) e.sleeve],
        <SleeveId>[SleeveId.a, SleeveId.b, SleeveId.c, SleeveId.pot],
      );
      expect(s.last.rollsUpTo, SleeveId.a);
    });

    test('🔴 같은 프리셋은 다시 내지 않는다(주기 · 무관한 쓰기 — J-1 기본 조건이 다시 서지 않게) · 첫 의도 = 전체 기간이 바뀐다', () async {
      final List<List<DateRange>> got = <List<DateRange>>[];
      final StreamSubscription<List<DateRange>> sub = cfg(rt())
          .watchRangePresets()
          .listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      db().execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('RECON_MISMATCH', '2026-08-31T00:00:00.000Z', 'x')",
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(got.length, 1);
      expect(got.single.last.from, const TradeDate('2026-08-31'));
      intent('iB', 'B@2026-08-03');
      await until(() => got.length == 2);
      expect(got.last.last.from, const TradeDate('2026-08-03'));
    });

    test('화면 상태 없음 = 오류', () async {
      await expectLater(
        cfg(rt(view: false)).watchRangePresets(),
        emitsError(isA<StateError>()),
      );
    });
  });
}
