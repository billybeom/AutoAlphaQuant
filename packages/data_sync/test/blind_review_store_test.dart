// E11q-j4s — J-4 blind 리뷰 채점 기록기(`SqliteBlindReviewStore` · SPEC v2.47 02 §2-6 · §3-3 ① · 13 §8 R257) ·
// 결과 재료 읽기(되돌림 대상 · 기업 행사 · 축 모르는 수기 체결).
//
// 🔴 실제 v1 스키마(LIVE · sim 두 파일) 위 — 한 트랜잭션(채점 1행 + 수신함 1행) · 거부 · 보관 = 수신함 1행만 · 멱등 · 보관 해제 뒤 집행 ·
//    같은 갱신에서 큐 · 배지 이탈 + 카드 결과.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show Market, P0sStrategyIds, frozenExchangeCalendar, heldReviewIdOf;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

/// 2026-09-01 09:00 KST — 8월이 닫힌 첫날.
final DateTime _t0 = DateTime.utc(2026, 9, 1);

void main() {
  late Directory dir;
  late Database live;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('j4s_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    clock = _Clock(_t0);
  });

  tearDown(() {
    live.close();
    dir.deleteSync(recursive: true);
  });

  SqliteJournalSource src(Database d, RunMode m) => SqliteJournalSource(
    d,
    clock: clock,
    kr: frozenExchangeCalendar(Market.kr),
    runMode: m,
    accountLabels: const <String, String>{},
    hasBody: (String _) => true,
  );

  SqliteBlindReviewStore store(Database d, RunMode m) =>
      SqliteBlindReviewStore(d, source: src(d, m), clock: clock);

  void intent(
    Database d,
    String id, {
    required String decision,
    String side = 'BUY',
    String day = '2026-08-11',
    String at = '2026-08-11T05:30:00.000Z',
    String mode = 'LIVE',
  }) {
    d.execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
      'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
      "updated_at, mode) VALUES (?, ?, ?, ?, 'KR', 'pension', ?, ?, '0085P0', ?, 'LIMIT', 10, 38250, "
      "'FILLED', 'cfg', ?, ?)",
      <Object?>[
        id,
        'k$id',
        at,
        day,
        P0sStrategyIds.sleeveC,
        decision,
        side,
        at,
        mode,
      ],
    );
    d.execute(
      'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) '
      "VALUES (?, ?, ?, 'FILLED')",
      <Object?>['$day:B$id', id, at],
    );
  }

  void fill(
    Database d,
    String id,
    String intentId,
    String day, {
    String price = '38250',
    int commission = 57,
    String kind = 'ORIGINAL',
    String? reverses,
    String? at,
  }) => d.execute(
    'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, commission, tax, '
    'fill_kind, reverses_fill_id) VALUES (?, ?, ?, 10, ?, ?, 0, ?, ?)',
    <Object?>[
      id,
      '$day:B$intentId',
      at ?? '${day}T05:50:00.000Z',
      num.parse(price),
      commission,
      kind,
      reverses,
    ],
  );

  /// 이탈 결정 D28(08-11 매수 10 · 저널 작성) + 규칙대로 매도(08-28 · 전량 청산).
  void seed(Database d, {String mode = 'LIVE'}) {
    d.execute(
      'INSERT INTO decision_journal (journal_id, trade_date, strategy_id, signal_value, action_taken, '
      "is_deviation, rationale_before, expected_outcome, rule_cited, note, created_at) VALUES ('J28', "
      "'2026-08-11', 'P0S', '{}', '{}', 1, '근거', '기대', '재량 예산', NULL, '2026-08-11T04:55:00.000Z')",
    );
    d.execute(
      'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
      "reason_code, config_hash, journal_id) VALUES ('D28', '2026-08-11T00:05:00.000Z', '2026-08-11', "
      "?, 'MANUAL', 'P0S', '월간 정기 리밸런싱', 'MONTHLY_REGULAR', 'cfg', 'J28')",
      <Object?>[mode],
    );
    intent(d, 'i28', decision: 'D28', mode: mode);
    fill(d, 'x28', 'i28', '2026-08-11');
    intent(
      d,
      'iS',
      decision: 'DS',
      side: 'SELL',
      day: '2026-08-28',
      at: '2026-08-28T05:30:00.000Z',
      mode: mode,
    );
    fill(d, 'xS', 'iS', '2026-08-28', price: '38500', commission: 58);
  }

  Map<String, int> answers(BlindReviewCard c, {int no = 1}) => <String, int>{
    for (final (int i, BlindReviewQuestion q) in c.questions.indexed)
      q.questionId: i < no ? 0 : 1,
  };

  BlindReviewWriteResult submit(
    Database d,
    BlindReviewScore s, {
    String commandId = 'c1',
    RunMode mode = RunMode.live,
  }) => store(d, mode).submit(
    commandId: commandId,
    payloadDigest: 'digest-$commandId',
    score: s,
    runMode: mode,
    operatingMode: OperatingMode.autoTrade,
    leaseEpoch: 3,
  );

  int count(Database d, String table) =>
      d.select('SELECT count(*) AS n FROM $table').first['n'] as int;

  test('스키마 v1 — blind_review_score 제약(결정 PK · 명령 UNIQUE · 과정 점수 1~5 · NOT NULL) · 두 파일 모두 있음', () {
    bool accepts(String d, String c, int score) {
      try {
        live.execute(
          'INSERT INTO blind_review_score(decision_id, command_id, answers_json, process_score, scored_at) '
          "VALUES (?, ?, '{}', ?, '2026-09-01T00:00:00.000Z')",
          <Object?>[d, c, score],
        );
        return true;
      } on SqliteException {
        return false;
      }
    }

    expect(accepts('d1', 'c1', 1), isTrue);
    expect(accepts('d1', 'c2', 3), isFalse, reason: '결정 PK');
    expect(accepts('d2', 'c1', 3), isFalse, reason: '명령 UNIQUE');
    expect(accepts('d3', 'c3', 0), isFalse, reason: 'CHECK 하한');
    expect(accepts('d4', 'c4', 6), isFalse, reason: 'CHECK 상한');
    expect(accepts('d5', 'c5', 5), isTrue);
    final Database sim = openLocalLedger(
      dir.path,
      RunMode.simInternal,
      clock: () => _t0,
    );
    addTearDown(sim.close);
    expect(
      sim
          .select(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'blind_review_score'",
          )
          .length,
      1,
    );
  });

  test('🔴 집행 — 채점 1행(키 이름 순 답 · 과정 점수 · 기기 시계) + 수신함 EXECUTED(결정 NULL) · 같은 갱신 큐 · 배지 이탈 + 카드 결과', () {
    seed(live);
    final BlindReviewCard c = src(
      live,
      RunMode.live,
    ).blindReviewQueue().rows.single;
    expect(src(live, RunMode.live).badges().single.label, '리뷰 대기 1건');
    clock.at = DateTime.utc(2026, 9, 1, 0, 10);
    final BlindReviewWriteResult r = submit(
      live,
      BlindReviewScore(decisionId: c.decisionId, answers: answers(c)),
    );
    expect(
      (r.state, r.stateLabel, r.rejectCode, r.replayed),
      (CommandState.executed, '기록됨 — 과정 점수가 저장되었습니다', null, false),
    );
    final Row s = live.select('SELECT * FROM blind_review_score').single;
    expect(
      (s['decision_id'], s['command_id'], s['process_score'], s['scored_at']),
      ('D28', 'c1', 4, '2026-09-01T00:10:00.000Z'),
    );
    expect(
      (jsonDecode(s['answers_json'] as String) as Map<String, Object?>).keys,
      <String>[
        'FALSIFIER_WRITTEN',
        'PIT_INFO_ONLY',
        'PIT_INPUT',
        'RULE_FOLLOWED',
        'WRITTEN_AT_DECISION',
      ],
    );
    final Row inbox = live.select('SELECT * FROM command_inbox').single;
    expect(
      (
        inbox['kind'],
        inbox['state'],
        inbox['decision_id'],
        inbox['run_mode'],
        inbox['operating_mode'],
        inbox['lease_epoch'],
        inbox['payload_digest'],
      ),
      (
        'BLIND_REVIEW_SCORE',
        'EXECUTED',
        null,
        'LIVE',
        'AUTO_TRADE',
        3,
        'digest-c1',
      ),
    );
    final SqliteJournalSource after = src(live, RunMode.live);
    expect(after.blindReviewQueue().rows, isEmpty);
    expect(after.badges(), isEmpty);
    final BlindReviewCard card = after.blindReviewCard('D28');
    expect(card.copyWith(result: null, asOf: c.asOf), c);
    expect(
      (card.result!.processScoreText, card.result!.outcomeText),
      ('과정 점수 4점 — 좋은 결정(4점 이상)', '결과: 수익률 +0.6% · 보유 12거래일'),
    );
  });

  test('🔴 멱등 · 이미 채점(답보다 먼저) · 원장 쓰기 0', () {
    seed(live);
    final BlindReviewCard c = src(
      live,
      RunMode.live,
    ).blindReviewQueue().rows.single;
    final BlindReviewScore ok = BlindReviewScore(
      decisionId: c.decisionId,
      answers: answers(c, no: 0),
    );
    submit(live, ok);
    final BlindReviewWriteResult again = submit(live, ok);
    expect((again.state, again.replayed), (CommandState.executed, true));
    final BlindReviewWriteResult second = submit(
      live,
      const BlindReviewScore(decisionId: 'D28', answers: <String, int>{}),
      commandId: 'c2',
    );
    expect(
      (second.state, second.rejectCode, second.stateLabel),
      (
        CommandState.rejected,
        BlindReviewRejectCodes.alreadyScored,
        '거부됨 — 이 결정은 이미 채점되었습니다. 먼저 기록된 채점이 유지됩니다',
      ),
    );
    expect(count(live, 'blind_review_score'), 1);
    expect(
      live
          .select('SELECT process_score FROM blind_review_score')
          .single['process_score'],
      5,
    );
    expect(count(live, 'command_inbox'), 2);
  });

  test('🔴 ANSWERS_INVALID — 빠진 문항 · 선택지 밖 점수 · 대상 아님(모르는 결정 · 규칙대로) · sim 원장(K24) = 수신함 1행만', () {
    seed(live);
    final BlindReviewCard c = src(
      live,
      RunMode.live,
    ).blindReviewQueue().rows.single;
    final Map<String, int> missing = answers(c)..remove('PIT_INPUT');
    final Map<String, int> outOfRange = answers(c)..['PIT_INPUT'] = 2;
    int n = 0;
    for (final BlindReviewScore s in <BlindReviewScore>[
      BlindReviewScore(decisionId: 'D28', answers: missing),
      BlindReviewScore(decisionId: 'D28', answers: outOfRange),
      BlindReviewScore(decisionId: 'none', answers: answers(c)),
      BlindReviewScore(decisionId: 'DS', answers: answers(c)),
    ]) {
      final BlindReviewWriteResult r = submit(live, s, commandId: 'c${n++}');
      expect(
        (r.state, r.rejectCode, r.stateLabel),
        (
          CommandState.rejected,
          BlindReviewRejectCodes.answersInvalid,
          '거부됨 — 답이 카드의 문항과 맞지 않습니다. 고른 답은 그대로 남아 있습니다',
        ),
        reason: s.decisionId,
      );
    }
    expect(count(live, 'blind_review_score'), 0);
    expect(count(live, 'command_inbox'), 4);
    // K24 — 모의 원장(같은 꼴 사실) = 큐 빈 · 대상 아님.
    final Database sim = openLocalLedger(
      dir.path,
      RunMode.simInternal,
      clock: () => _t0,
    );
    addTearDown(sim.close);
    seed(sim, mode: 'SIM_INTERNAL');
    final BlindReviewWriteResult r = submit(
      sim,
      BlindReviewScore(decisionId: 'D28', answers: answers(c)),
      mode: RunMode.simInternal,
    );
    expect(r.rejectCode, BlindReviewRejectCodes.answersInvalid);
    expect(count(sim, 'blind_review_score'), 0);
  });

  test(
    '🔴 LEDGER_INTEGRITY = 보관(원장 쓰기 0 · 표본 글자) → 해제 뒤 같은 명령 = 집행(수신함 행 고쳐 씀)',
    () {
      seed(live);
      final BlindReviewCard c = src(
        live,
        RunMode.live,
      ).blindReviewQueue().rows.single;
      live.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
        <Object?>[FlagIds.ledgerIntegrity, _t0.toIso8601String(), '시험'],
      );
      final BlindReviewScore s = BlindReviewScore(
        decisionId: c.decisionId,
        answers: answers(c),
      );
      final BlindReviewWriteResult held = submit(live, s, commandId: 'h');
      expect(
        (held.state, held.stateLabel),
        (
          CommandState.heldForIntegrity,
          '보류됨 — 원장 무결성 점검 중이라 보관했습니다. 복구 뒤 일괄 확정 단계에서 처리됩니다',
        ),
      );
      expect(count(live, 'blind_review_score'), 0);
      // 서 있는 동안 다시 = 보관 그대로.
      expect(submit(live, s, commandId: 'h').replayed, isTrue);
      // 가림 = 결과 숨김(채점 전이라 카드 결과 없음 — 큐는 그대로).
      expect(src(live, RunMode.live).blindReviewQueue().rows, hasLength(1));
      live.execute(
        'UPDATE trading_block SET cleared_at = ?, cleared_by = ? WHERE flag_id = ?',
        <Object?>[_t0.toIso8601String(), 'test', FlagIds.ledgerIntegrity],
      );
      final BlindReviewWriteResult done = submit(live, s, commandId: 'h');
      expect((done.state, done.replayed), (CommandState.executed, false));
      expect(count(live, 'command_inbox'), 1);
      expect(
        live
            .select("SELECT state FROM command_inbox WHERE command_id = 'h'")
            .single['state'],
        'EXECUTED',
      );
      // 다시 서면 채점된 카드의 결과 문장 = 숨김.
      live.execute(
        'UPDATE trading_block SET cleared_at = NULL WHERE flag_id = ?',
        <Object?>[FlagIds.ledgerIntegrity],
      );
      expect(
        src(live, RunMode.live).blindReviewCard('D28').result!.outcomeText,
        '결과: 숨김',
      );
    },
  );

  test('🆕 R280 보관 → M5-13 일괄 확정(RECEIVED) 뒤 같은 명령 = 집행(보통 소비 규칙)', () {
    seed(live);
    final BlindReviewCard c = src(
      live,
      RunMode.live,
    ).blindReviewQueue().rows.single;
    live.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>[FlagIds.ledgerIntegrity, _t0.toIso8601String(), '시험'],
    );
    final BlindReviewScore s = BlindReviewScore(
      decisionId: c.decisionId,
      answers: answers(c),
    );
    expect(
      submit(live, s, commandId: 'm').state,
      CommandState.heldForIntegrity,
    );
    live.execute(
      'UPDATE trading_block SET cleared_at = ?, cleared_by = ? WHERE flag_id = ?',
      <Object?>[_t0.toIso8601String(), 'test', FlagIds.ledgerIntegrity],
    );
    final SqliteSelfAuditResolveSource gate = SqliteSelfAuditResolveSource(
      live,
    );
    expect(
      gate
          .confirmHeld(
            args: <String, String>{
              'review_id': heldReviewIdOf(gate.heldCommands())!,
            },
            nowUtc: _t0,
          )
          .code,
      isNull,
    );
    final BlindReviewWriteResult done = submit(live, s, commandId: 'm');
    expect((done.state, done.replayed), (CommandState.executed, false));
    expect(count(live, 'blind_review_score'), 1);
  });

  test(
    '결과 재료 읽기 — 되돌림 · 정정 = 살아 있는 체결 · 되돌린 기업 행사 = 없음 · 축 모르는 수기 체결 = 셀 수 없음',
    () {
      seed(live);
      final BlindReviewCard c = src(
        live,
        RunMode.live,
      ).blindReviewQueue().rows.single;
      submit(live, BlindReviewScore(decisionId: 'D28', answers: answers(c)));
      String outcome() =>
          src(live, RunMode.live).blindReviewCard('D28').result!.outcomeText;
      // 매도를 되돌리면 = 미청산.
      fill(
        live,
        'xSr',
        'iS',
        '2026-08-28',
        kind: 'REVERSAL',
        reverses: 'xS',
        at: '2026-08-31T05:50:00.000Z',
      );
      expect(outcome(), '미청산 — 결과 미확정');
      // 정정 판 = 다시 청산.
      fill(
        live,
        'xSs',
        'iS',
        '2026-08-28',
        at: '2026-08-31T05:51:00.000Z',
        price: '38500',
        commission: 58,
        kind: 'RESTATEMENT',
      );
      live.execute(
        "UPDATE executions SET restates_fill_id = 'xS' WHERE execution_id = 'xSs'",
      );
      expect(outcome(), '결과: 수익률 +0.6% · 보유 12거래일');
      // 기업 행사(효력일 ≤ 오늘 · 같은 계좌 · 종목) = 셀 수 없음 → 되돌리면 다시 셈.
      void event(String id, String entry, {String? reverses}) => live.execute(
        'INSERT INTO ledger_event (event_id, kind, entry_kind, reverses_event_id, effective_date, '
        'account_alias, symbol, action_type, ratio_from, ratio_to, decision_id, command_id, '
        'authored_by_device_id, authored_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          id,
          'CORPORATE_ACTION',
          entry,
          reverses,
          '2026-08-20',
          'pension',
          '0085P0',
          'SPLIT',
          1,
          2,
          'dca',
          'cca$id',
          'dev',
          '2026-08-20T00:00:00.000Z',
        ],
      );
      event('ca1', 'ORIGINAL');
      expect(outcome(), '셀 수 없음 — 결과 미확정');
      event('ca1r', 'REVERSAL', reverses: 'ca1');
      expect(outcome(), '결과: 수익률 +0.6% · 보유 12거래일');
      // 의도에 닿지 않는 살아 있는 수기 체결 = 셀 수 없음 → 되돌리면 다시 셈.
      live.execute(
        'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, fill_origin) '
        "VALUES ('m1', NULL, '2026-08-29T05:00:00.000Z', 1, 100, 'MANUAL')",
      );
      expect(outcome(), '셀 수 없음 — 결과 미확정');
      live.execute(
        'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, fill_origin, '
        "fill_kind, reverses_fill_id) VALUES ('m1r', NULL, '2026-08-29T06:00:00.000Z', 1, 100, 'MANUAL', "
        "'REVERSAL', 'm1')",
      );
      expect(outcome(), '결과: 수익률 +0.6% · 보유 12거래일');
    },
  );
}
