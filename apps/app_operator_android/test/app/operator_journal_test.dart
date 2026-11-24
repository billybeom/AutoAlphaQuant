// E11q-q4a — M6 매매일지 «읽기» 조립(J-1 · J-2 · J-3R · 회차 범위 · 기간 프리셋 · 슬리브) — 실 SQLite(sim 원장).
//
// 🔴 화면 상태의 원장 → data_sync 원천 → 엔진 VM · 🔴 감시 표 빠짐 없이(표마다 쓰면 다시 낸다) · 링크 = 셸이 실제로 쓰는
//    레지스트리에 본문이 있는 화면만 · 원장 한 파일(모드 인자 무시 · 01 §8 미결 89) · 쓰기 = 원천 없음(계약 창).
// 🆕 E11q-q4b — J-5 미해소 보드(등록 · 배지 링크가 선다 · UNKNOWN 이 풀리면 카드가 빠진다).

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_journal.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        Market,
        P0sStrategyIds,
        frozenExchangeCalendar,
        issueJournalDraftKey,
        routePatternOf;
import 'package:data_sync/data_sync.dart' show SqliteJournalSource;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database, Row;
import 'package:ui_shell/ui_shell.dart' show ShellRouteMatch, matchShellRoute;

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

  test('🔴 레지스트리 = 일지 읽기 넷 + J-5 미해소 보드 + J-3 사전 저널 쓰기(미결 220 ⓔ) + 🆕 J-4 blind 리뷰(E11q-j4)', () {
    for (final String r in <String>[
      AppRoutes.journalTimeline,
      AppRoutes.journalDecision,
      AppRoutes.journalRead,
      AppRoutes.journalRebalance,
      AppRoutes.journalUnknownBoard,
      AppRoutes.journalDraft,
      AppRoutes.journalBlindReview,
    ]) {
      expect(kOperatorRouteBodies.byPattern.containsKey(r), true, reason: r);
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
        // 🆕 E11q-j4s — J-4 채점(큐 이탈 · 카드 결과 — J-4 시험이 다시 냄을 본다) · 기업 행사(결과 «셀 수 없음»).
        'blind_review_score',
        'ledger_event',
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
      // 🆕 q4b — 미해소 보드 등록 = 배지 탭이 J-5 로 간다.
      final JournalTimelineBadge b =
          (await r.watchTimelineBadges().first).single;
      expect((b.label, b.deepLink), ('확인 중 1건', AppRoutes.journalUnknownBoard));
    },
  );

  test(
    '🆕 q4b J-5 미해소 보드 — UNKNOWN 의도 = 카드(J-2 링크) · 풀리면 같은 흐름에서 빠지고 빈 문장',
    () async {
      intent('iU', 'B-SMA-2026-07-31@2026-08-03', status: 'UNKNOWN');
      intent('iB', 'C-REBAL-2026-07-31@2026-08-03');
      final List<UnknownBoardVm> got = <UnknownBoardVm>[];
      final StreamSubscription<UnknownBoardVm> sub = repo(rt())
          .watchUnknownBoard()
          .listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty, 'first');
      final UnknownResolutionItem item = got.last.items.single;
      expect(item.entry.entryId, 'iU');
      expect(
        item.entry.detailDeepLink,
        'aaq://journal/decision/B-SMA-2026-07-31@2026-08-03',
      );
      expect(item.elapsedText, startsWith('발생 08-03 09:10 · '));
      expect(got.last.emptyLabel, isNull);
      db().execute(
        "UPDATE order_intents SET status = 'FILLED' WHERE intent_id = 'iU'",
      );
      await until(() => got.last.items.isEmpty, 'resolved');
      expect(got.last.emptyLabel, '미해소 건이 없습니다');
    },
  );

  test(
    '🔴 재개 child 결정 id(`#`) — 셸 라우터가 링크를 맞추고 그 조각으로 J-2 · J-3R 이 열린다',
    () async {
      intent('iR', 'B-SMA-2026-07-31#R2026-08-05@2026-08-05');
      final OperatorJournalRepository r = repo(rt());
      final TradeJournalEntry row =
          (await r.watchTimeline(range: _all).first).rows.single;
      final ShellRouteMatch m = matchShellRoute(row.detailDeepLink!)!;
      expect(m.pattern, AppRoutes.journalDecision);
      final String param = m.params['decisionId']!;
      expect((await r.watchDecisionDetail(param).first).entry, row);
      expect(
        (await r.watchDecisionJournal(param).first).decisionId,
        'B-SMA-2026-07-31#R2026-08-05@2026-08-05',
      );
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
    await expectLater(none.watchUnknownBoard(), emitsError(isA<StateError>()));
    // 🆕 E11q-j4 — J-4 원천이 섰다: 화면 상태 없음 · 모르는 결정 = 오류 · 모의 원장 = 해당 없음 빈 문장(K24).
    await expectLater(
      none.watchBlindReviewQueue(),
      emitsError(isA<StateError>()),
    );
    final ListResult<BlindReviewCard> simQueue = await r
        .watchBlindReviewQueue()
        .first;
    expect(simQueue.rows, isEmpty);
    expect(
      (simQueue.emptyKind, simQueue.emptyLabel),
      (EmptyKind.notApplicable, '리뷰할 결정이 없습니다'),
    );
    await expectLater(
      r.watchBlindReviewCard('d'),
      emitsError(isA<StateError>()),
    );
    // 🆕 미결 220 ⓔ — 폼 스펙 원천이 섰다: 모르는 키 · 화면 상태 없음 = 오류(지어내지 않는다).
    await expectLater(r.draftFormSpec('d'), throwsA(isA<StateError>()));
    await expectLater(none.draftFormSpec('d'), throwsA(isA<StateError>()));
    await expectLater(
      r.findByDecisionId('d'),
      throwsA(isA<UnsupportedError>()),
    );
    await expectLater(r.chainOf('d'), throwsA(isA<UnsupportedError>()));
    await expectLater(r.fillChain('e'), throwsA(isA<UnsupportedError>()));
  });

  test('🆕 E11q-j4 J-4 — LIVE 원장 · 이탈 저널 · 닫힌 달 = 큐 · 카드 · «리뷰 대기 n건» 배지(링크 = 등록 본문) · 저널 쓰기 = 다시 냄 · 🆕 j4s 제출 = 채점 기록 → 큐 · 배지 이탈 + 카드 결과 · 다시 = 이미 채점', () async {
    final Database live = files.openLive();
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: 'dev-1',
    );
    r.view.value = OperatorView(
      db: live,
      flags: const FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.live,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg_test',
      ),
    );
    void deviation(String d, String j, String day, String at) {
      live.execute(
        'INSERT INTO decision_journal (journal_id, trade_date, strategy_id, signal_value, action_taken, '
        "is_deviation, rationale_before, expected_outcome, rule_cited, note, created_at) VALUES (?, ?, 'P0S', "
        "'{}', '{}', 1, '근거', '기대', '재량 예산', NULL, ?)",
        <Object?>[j, day, at],
      );
      live.execute(
        'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
        "reason_code, config_hash, journal_id) VALUES (?, ?, ?, 'LIVE', 'MANUAL', 'P0S', '월간 정기 리밸런싱', "
        "'MONTHLY_REGULAR', 'cfg', ?)",
        <Object?>[d, at, day, j],
      );
      live.execute(
        'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
        'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
        "updated_at, mode) VALUES (?, ?, ?, ?, 'KR', 'pension', ?, ?, '0085P0', 'BUY', 'LIMIT', 10, 38250, "
        "'SUBMITTED', 'cfg', ?, 'LIVE')",
        <Object?>['i$d', 'k$d', at, day, P0sStrategyIds.sleeveC, d, at],
      );
    }

    deviation('D28', 'J28', '2026-08-11', '2026-08-11T04:55:00.000Z');
    clock.now = kst(2026, 9, 1, 9, 0);
    final OperatorJournalRepository j = repo(r);
    final List<ListResult<BlindReviewCard>> seen =
        <ListResult<BlindReviewCard>>[];
    final StreamSubscription<ListResult<BlindReviewCard>> sub = j
        .watchBlindReviewQueue()
        .listen(seen.add);
    addTearDown(sub.cancel);
    await until(() => seen.isNotEmpty, '큐 첫 값');
    final BlindReviewCard c = seen.last.rows.single;
    expect((c.decisionId, c.result), ('D28', null));
    expect(await j.watchBlindReviewCard('D28').first, c);
    // K24 — LIVE 원장이어도 SIM 인자 = 해당 없음(SIM 리뷰 = 미결 99).
    expect(
      (await j.watchBlindReviewQueue(mode: RunMode.simInternal).first).rows,
      isEmpty,
    );
    final JournalTimelineBadge b = (await j.watchTimelineBadges().first).single;
    expect(
      (b.badgeCode, b.label, b.deepLink),
      (
        JournalBadgeCodes.blindReviewPending,
        '리뷰 대기 1건',
        AppRoutes.journalBlindReview,
      ),
    );
    // 감시 표(결정 로그 · 저널 · 의도)에 쓰면 다시 낸다 — 둘째 이탈 결정.
    deviation('D29', 'J29', '2026-08-12', '2026-08-12T04:55:00.000Z');
    await until(() => seen.last.rows.length == 2, '쓰기 뒤 다시 냄');
    expect(seen.last.rows.map((BlindReviewCard x) => x.decisionId), <String>[
      'D28',
      'D29',
    ]);
    // 🆕 E11q-j4s — 채점 기록(SPEC v2.47 02 §3-3 ①) → 같은 갱신에서 큐 · 배지 이탈 + 카드 결과(체결 0 = «체결 없음 — 결과 없음»).
    final OperatorCommandApi api = OperatorCommandApi(r, random: Random(7));
    final BlindReviewScore all = BlindReviewScore(
      decisionId: 'D28',
      answers: <String, int>{
        for (final BlindReviewQuestion q in c.questions) q.questionId: 1,
      },
    );
    final CommandReceipt ok = await api.submitBlindReviewScore(all);
    expect(
      (ok.kind, ok.state, ok.stateLabel, ok.rejectReasonCode),
      (
        CommandKind.blindReviewScore,
        CommandState.executed,
        '기록됨 — 과정 점수가 저장되었습니다',
        null,
      ),
    );
    await until(() => seen.last.rows.length == 1, '채점 뒤 큐 이탈');
    expect(seen.last.rows.single.decisionId, 'D29');
    expect((await j.watchTimelineBadges().first).single.label, '리뷰 대기 1건');
    final BlindReviewCard scored = await j.watchBlindReviewCard('D28').first;
    expect(scored.copyWith(result: null, asOf: c.asOf), c);
    expect(
      (scored.result!.processScoreText, scored.result!.outcomeText),
      ('과정 점수 5점 — 좋은 결정(4점 이상)', '체결 없음 — 결과 없음'),
    );
    expect(scored.result!.detailLines, isEmpty);
    final List<Row> scores = live.select(
      'SELECT decision_id, process_score FROM blind_review_score',
    );
    expect(scores, hasLength(1));
    expect(
      (scores.single['decision_id'], scores.single['process_score']),
      ('D28', 5),
    );
    // 다시 = 이미 채점(먼저 집행된 채점이 이긴다 · 원장 쓰기 0).
    final CommandReceipt again = await api.submitBlindReviewScore(all);
    expect(
      (again.state, again.rejectReasonCode),
      (CommandState.rejected, BlindReviewRejectCodes.alreadyScored),
    );
    expect(live.select('SELECT 1 FROM blind_review_score'), hasLength(1));
  });

  test('🆕 미결 220 ⓔⓕ J-3 — 미완성 저널 폼 스펙 → 제출(엔진 · 접수증) → J-3R(저널 id) 작성됨 · 다시 = 이미 있음 · 새 행 키 · 모르는 키', () async {
    db().execute(
      'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
      'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
      "VALUES ('JIV-1', '2026-08-31', 'P0S', '{}', '{}', 1, NULL, NULL, NULL, 'INTERVENTION_JOURNAL', NULL, "
      "'2026-08-31T08:00:00.000Z')",
    );
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: 'dev-1',
    )..view.value = _viewOf(db());
    final OperatorJournalRepository j = repo(r);
    final OperatorCommandApi api = OperatorCommandApi(r, random: Random(4));
    final JournalDraftFormSpec spec = await j.draftFormSpec('JIV-1');
    expect(spec.decisionId, 'JIV-1');
    expect(spec.pledgeLines, isEmpty);
    expect(spec.ruleCitedOptions, hasLength(3));
    expect(
      (await j.watchDecisionJournal('JIV-1').first).journalStateLabel,
      '저널 미작성',
    );
    JournalDraft draft(String key) => JournalDraft(
      decisionId: key,
      rationaleBefore: '근' * spec.rationaleMinChars,
      expectedOutcome: '기대',
      ruleCited: spec.ruleCitedOptions.first.code,
    );
    final CommandReceipt ok = await api.submitJournalDraft(draft('JIV-1'));
    expect(
      (ok.kind, ok.state, ok.issuedByDeviceId, ok.rejectReasonCode),
      (CommandKind.journalDraft, CommandState.executed, 'dev-1', null),
    );
    expect(ok.stateLabel, '저장됨 — 사전 저널이 기록되었습니다');
    expect(await api.watchCommand(ok.commandId).first, ok);
    final DecisionJournalVm read = await j.watchDecisionJournal('JIV-1').first;
    expect(read.journalStateLabel, '저널 작성됨');
    expect(read.body!.ruleCitedLabel, spec.ruleCitedOptions.first.label);
    expect(
      (await api.submitJournalDraft(draft('JIV-1'))).rejectReasonCode,
      'JOURNAL_ALREADY_EXISTS',
    );
    expect(
      (await api.submitJournalDraft(draft('nope'))).rejectReasonCode,
      'JOURNAL_TARGET_UNKNOWN',
    );
    final String key = issueJournalDraftKey(
      purpose: 'DISCRETION',
      random: Random(8),
    );
    final JournalDraftFormSpec disc = await j.draftFormSpec(key);
    expect(
      (disc.deviation.kindCode, disc.deviation.label),
      ('DISCRETION', '재량 조정'),
    );
    expect(
      (await api.submitJournalDraft(draft(key))).state,
      CommandState.executed,
    );
    expect(
      db()
          .select(
            'SELECT kind, is_deviation FROM decision_journal WHERE journal_id = ?',
            <Object?>[key],
          )
          .single
          .values,
      <Object?>['DISCRETION', 1],
    );
    await expectLater(
      OperatorCommandApi(
        OperatorRuntime(files: files, clock: clock)..view.value = _viewOf(db()),
      ).submitJournalDraft(draft(key)),
      throwsStateError,
    );
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
