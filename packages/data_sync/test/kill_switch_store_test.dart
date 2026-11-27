// E13b — 킬스위치 저장 · 집행(SPEC v2.40 04 §3-6 · 설계 13 §8 R57 B1~B8).
//
// 🔵 잡는 것: ① 발동 저장 멱등(첫 시각 유지 · 누를 때마다 이력) · 꺼진 뒤 새 발동 ② 확인 = 신뢰 시각만 · 한 트랜잭션 ·
//    다시 확인해도 48h 불변 · 엔진 미체결 대조(P0) ③ 재개 · 48h 전 거부 ④ 명령 재전달 멱등 ⑤ 판정식 교체(손으로 고친 행) ·
//    🔴 별도 커넥션 ⑥ 취소 후보(오늘 · 잔량 · UNKNOWN 제외) ⑦ operator 로컬 단락.
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
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 4, 1); // 한국 11-04 10:00
const TradeDate _exec = TradeDate('2026-11-04');

const KillActivationAnswers _answers = KillActivationAnswers(
  ruleAction: '월말 정기 리밸런싱만',
  reasonKind: KillReasonKind.emotion,
  emotion: '불안',
  intensity: 7,
  sleepHours: 4,
  scenarioId: 'W-03',
  resumeCondition: 'DD 가 −10% 위로 회복',
  scope: KillScope.newEntriesOnly,
  journalDecisionId: 'J-KILL-1',
);
const KillAckAnswers _ack = KillAckAnswers(
  openOrdersQueried: true,
  openOrdersCancelled: true,
  remainingCountZero: true,
  note: '증권사 앱 0건',
);

ResumeChecklist _resume({String journal = 'J-RESUME-1'}) {
  ResumeChecklist c = ResumeChecklist.empty;
  for (final ResumeItemAnswer a in <ResumeItemAnswer>[
    const ResumeItemAnswer(1, text: '월말 정기 리밸런싱'),
    const ResumeItemAnswer(2, emotion: '평온', intensity: 2, sleepHours: 7),
    const ResumeItemAnswer(3, scenario: ScenarioStatus.resolved),
    const ResumeItemAnswer(4, condition: ResumeConditionStatus.met),
    const ResumeItemAnswer(5, acknowledged: true),
    const ResumeItemAnswer(6, acknowledged: true),
    ResumeItemAnswer(
      7,
      decisionId: journal,
      rationaleBefore: '조건 충족',
      expectedOutcome: '규칙대로',
      ruleCited: '04 §3-6',
    ),
  ]) {
    c = c.accept(a).$1!;
  }
  return c;
}

OrderIntentDraft _draft(String logical, {String symbol = '133690'}) =>
    OrderIntentDraft(
      executionDate: _exec,
      account: 'pension',
      strategyId: P0sStrategyIds.sleeveB,
      symbol: symbol,
      side: OrderSide.buy,
      quantity: 5,
      orderType: OrderTypes.limit,
      limitPrice: Decimal.parse('174180'),
      sizingPrice: Decimal.parse('174180'),
      logicalDecisionId: logical,
      decisionId: DecisionIds.forExecution(logical, _exec),
      instrument: InstrumentKind.etf,
    );

int _count(Database db, String table, [String where = '1 = 1']) =>
    db.select('SELECT COUNT(*) AS n FROM $table WHERE $where').first['n']
        as int;

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;
  late SqliteKillSwitchStore store;
  late SqliteOrderLedger ledger;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_ks_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteKillSwitchStore(db, clock: clock, trusted: trusted);
    ledger = SqliteOrderLedger(
      db,
      mode: RunMode.live,
      clock: clock,
      kr: frozenExchangeCalendar(Market.kr),
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  Future<String> submitted(String logical, {String no = '1'}) async {
    final IntentRow r = IntentRow.fromDraft(
      _draft(logical),
      status: IntentStatus.reserved,
      configHash: 'cfg',
      execPolicy: ExecPolicy.execute,
      operatingMode: OperatingMode.autoTrade,
    );
    await ledger.insertIntent(r);
    await ledger.markSubmitting(r.intentId);
    await ledger.markSubmitted(r.intentId, '2026-11-04:$no');
    return r.intentId;
  }

  Future<String> unknown(String logical) async {
    final IntentRow r = IntentRow.fromDraft(
      _draft(logical),
      status: IntentStatus.reserved,
      configHash: 'cfg',
      execPolicy: ExecPolicy.execute,
      operatingMode: OperatingMode.autoTrade,
    );
    await ledger.insertIntent(r);
    await ledger.markSubmitting(r.intentId);
    await ledger.markUnknown(r.intentId, 'timeout');
    return r.intentId;
  }

  Future<void> activate({String channel = 'app'}) => store.activate(
    atUtc: trusted.at ?? clock.at,
    channel: channel,
    deviceLabel: '내 폰',
  );

  group('발동 저장(B1)', () {
    test('새 발동 · 다시 누름 = 첫 시각 유지 · 누를 때마다 이력', () async {
      await activate();
      KillSwitchRecord r = readKillSwitchRecord(db);
      expect(
        (r.activatedAtUtc, r.activatedByDeviceLabel, r.checklistConfirmedAtUtc),
        (_t0, '내 폰', null),
      );
      expect(killSwitchActive(r), isTrue);
      trusted.at = _t0.add(const Duration(hours: 1));
      await activate(channel: 'viewer');
      r = readKillSwitchRecord(db);
      expect(r.activatedAtUtc, _t0);
      final List<Row> ev = db
          .select(
            'SELECT kind, channel, summary FROM kill_switch_event ORDER BY occurred_at',
          )
          .toList();
      expect(
        ev.map((Row e) => (e['kind'], e['channel'], e['summary'])),
        <(Object?, Object?, Object?)>[
          ('ACTIVATED', 'app', '{"repeat":false}'),
          ('ACTIVATED', 'viewer', '{"repeat":true}'),
        ],
      );
    });

    test('꺼진 뒤 = 새 발동(확인 · 해제 · 결정 비움)', () async {
      db.execute(
        'INSERT INTO kill_switch_state(id, activated_at, activated_by, checklist_confirmed_at, cleared_at, decision_id) '
        "VALUES (1, '2026-10-01T00:00:00.000Z', 'app', '2026-10-01T01:00:00.000Z', '2026-10-05T00:00:00.000Z', 'J-OLD')",
      );
      expect(killSwitchActive(readKillSwitchRecord(db)), isFalse);
      await activate();
      final KillSwitchRecord r = readKillSwitchRecord(db);
      expect(
        (
          r.activatedAtUtc,
          r.checklistConfirmedAtUtc,
          r.clearedAtUtc,
          r.decisionId,
        ),
        (_t0, null, null, null),
      );
    });

    test('🔴 신뢰 시각 모름이어도 발동은 된다(기기 시계)', () async {
      trusted.at = null;
      clock.at = _t0.add(const Duration(minutes: 3));
      await activate();
      expect(
        readKillSwitchRecord(db).activatedAtUtc,
        _t0.add(const Duration(minutes: 3)),
      );
    });

    test('🔴 시차 없는 · 깨진 시각 = 던진다(지역 시각으로 읽혀 48h 가 밀리지 않게)', () {
      db.execute(
        "INSERT INTO kill_switch_state(id, activated_at, activated_by) VALUES (1, '2026-11-04T10:00:00', 'app')",
      );
      expect(() => readKillSwitchRecord(db), throwsFormatException);
      db.execute("UPDATE kill_switch_state SET activated_at = 't0'");
      expect(() => readKillSwitchRecord(db), throwsFormatException);
      db.execute(
        "UPDATE kill_switch_state SET activated_at = '2026-11-04T10:00:00+09:00'",
      );
      expect(readKillSwitchRecord(db).activatedAtUtc, _t0);
    });
  });

  group('확인(B2)', () {
    test('통과 = 한 트랜잭션: 저널 · 확인 시각 · 이력 · 명령', () async {
      await activate();
      trusted.at = _t0.add(const Duration(minutes: 30));
      final KillCommandResult r = store.confirmChecklist(
        commandId: 'cmd-1',
        payloadDigest: 'd1',
        answers: _answers,
        ack: _ack,
      );
      expect(
        (r.executed, r.replayed, r.reasonCode, r.decisionId, r.p0),
        (true, false, null, 'J-KILL-1', false),
      );
      final Row j = db
          .select(
            "SELECT * FROM decision_journal WHERE journal_id = 'J-KILL-1'",
          )
          .single;
      expect(
        (
          j['kind'],
          j['trade_date'],
          j['strategy_id'],
          j['is_deviation'],
          j['rationale_before'],
          j['expected_outcome'],
          j['rule_cited'],
          j['note'],
        ),
        (
          'KILL_SWITCH_CHECKLIST',
          '2026-11-04',
          P0sStrategyIds.deposit,
          1,
          '감정: 불안 (강도 7 · 수면 4.0시간)',
          'DD 가 −10% 위로 회복',
          'W-03',
          '증권사 앱 0건',
        ),
      );
      final Map<String, dynamic> sig =
          jsonDecode(j['signal_value'] as String) as Map<String, dynamic>;
      expect(sig['scope'], 'newEntriesOnly');
      expect(
        (sig['ack'] as Map<String, dynamic>)['remaining_count_zero'],
        isTrue,
      );
      expect(
        readKillSwitchRecord(db).checklistConfirmedAtUtc,
        _t0.add(const Duration(minutes: 30)),
      );
      expect(
        _count(
          db,
          'kill_switch_event',
          "kind = 'CHECKLIST_CONFIRMED' AND decision_id = 'J-KILL-1'",
        ),
        1,
      );
      final Row c = db
          .select("SELECT * FROM command_inbox WHERE command_id = 'cmd-1'")
          .single;
      expect(
        (
          c['kind'],
          c['state'],
          c['decision_id'],
          c['payload_digest'],
          c['run_mode'],
        ),
        ('KILL_CHECKLIST_CONFIRM', 'EXECUTED', 'J-KILL-1', 'd1', null),
      );
    });

    test('🔴 다시 확인해도 48h 기준은 첫 확인 그대로', () async {
      await activate();
      store.confirmChecklist(
        commandId: 'cmd-1',
        payloadDigest: 'd',
        answers: _answers,
        ack: _ack,
      );
      trusted.at = _t0.add(const Duration(hours: 5));
      final KillCommandResult again = store.confirmChecklist(
        commandId: 'cmd-2',
        payloadDigest: 'd',
        answers: const KillActivationAnswers(
          ruleAction: 'x',
          reasonKind: KillReasonKind.rule,
          scenarioNone: true,
          resumeCondition: 'y',
          scope: KillScope.newEntriesOnly,
          journalDecisionId: 'J-KILL-2',
        ),
        ack: _ack,
      );
      expect(again.executed, isTrue);
      expect(readKillSwitchRecord(db).checklistConfirmedAtUtc, _t0);
      final Row j2 = db
          .select(
            "SELECT is_deviation, rationale_before, rule_cited FROM decision_journal WHERE journal_id = 'J-KILL-2'",
          )
          .single;
      expect(
        (j2['is_deviation'], j2['rationale_before'], j2['rule_cited']),
        (0, '규칙: x', '해당 없음'),
      );
    });

    test('거부 — 신뢰 시각 모름 · 꺼짐 · 빈칸 · 저널 id 중복 · 명령 기록 REJECTED', () async {
      expect(
        store
            .confirmChecklist(
              commandId: 'c0',
              payloadDigest: 'd',
              answers: _answers,
              ack: _ack,
            )
            .reasonCode,
        'KILL_SWITCH_NOT_ACTIVE',
      );
      await activate();
      trusted.at = null;
      expect(
        store
            .confirmChecklist(
              commandId: 'c1',
              payloadDigest: 'd',
              answers: _answers,
              ack: _ack,
            )
            .reasonCode,
        'TRUSTED_TIME_UNKNOWN',
      );
      trusted.at = _t0;
      expect(
        store
            .confirmChecklist(
              commandId: 'c2',
              payloadDigest: 'd',
              answers: const KillActivationAnswers(
                ruleAction: '',
                reasonKind: KillReasonKind.rule,
                scenarioNone: true,
                resumeCondition: 'y',
                scope: KillScope.newEntriesOnly,
                journalDecisionId: 'J-X',
              ),
              ack: _ack,
            )
            .reasonCode,
        'KILL_CHECKLIST_ITEM_MISSING',
      );
      db.execute(
        'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, created_at) '
        "VALUES ('J-KILL-1', '2026-11-04', 'P0S', '{}', '{}', 't')",
      );
      expect(
        store
            .confirmChecklist(
              commandId: 'c3',
              payloadDigest: 'd',
              answers: _answers,
              ack: _ack,
            )
            .reasonCode,
        'JOURNAL_ID_TAKEN',
      );
      expect(readKillSwitchRecord(db).checklistConfirmedAtUtc, isNull);
      expect(_count(db, 'command_inbox', "state = 'REJECTED'"), 4);
      expect(
        db
            .select(
              "SELECT reject_reason_code, state_label FROM command_inbox WHERE command_id = 'c1'",
            )
            .single
            .values,
        <Object?>['TRUSTED_TIME_UNKNOWN', '거부됨 — TRUSTED_TIME_UNKNOWN'],
      );
      // 거부된 명령의 재전달 = 처음 거부 그대로(지금 다시 판정하지 않는다).
      final KillCommandResult again = store.confirmChecklist(
        commandId: 'c1',
        payloadDigest: 'd',
        answers: _answers,
        ack: _ack,
      );
      expect(
        (again.executed, again.replayed, again.reasonCode),
        (false, true, 'TRUSTED_TIME_UNKNOWN'),
      );
    });

    test('저널 날짜 = 한국 날짜(UTC 11-03 15:30 = 한국 11-04 00:30)', () async {
      trusted.at = DateTime.utc(2026, 11, 3, 15, 30);
      await activate();
      store.confirmChecklist(
        commandId: 'c',
        payloadDigest: 'd',
        answers: _answers,
        ack: _ack,
      );
      expect(
        db
            .select('SELECT trade_date FROM decision_journal')
            .single['trade_date'],
        '2026-11-04',
      );
    });

    test('🔴 «잔여 0» 인데 엔진에 미체결이 있으면 무효 + P0', () async {
      await submitted('B-1');
      await activate();
      final KillCommandResult r = store.confirmChecklist(
        commandId: 'c',
        payloadDigest: 'd',
        answers: _answers,
        ack: _ack,
      );
      expect(
        (r.reasonCode, r.p0, r.executed),
        ('KILL_ACK_MISMATCH', true, false),
      );
      expect(readKillSwitchRecord(db).checklistConfirmedAtUtc, isNull);
      // 🆕 미결 243 ⓒ(R276 · K348) — 낼 경보 = P0 코드 한 건(확인 결과 코드와 다른 축) · 낸 곳 = 킬스위치.
      expect(r.alertCodes, <String>{'KILL_SWITCH_ACK_MISMATCH'});
      expect(r.alertCodes, isNot(contains(r.reasonCode)));
      expect(kKillSwitchAlertSource, 'kill_switch');
      // 그 밖 거부 · 실행 = 경보 0.
      expect(
        const KillCommandResult(
          executed: false,
          reasonCode: 'KILL_ACK_INCOMPLETE',
        ).alertCodes,
        isEmpty,
      );
      expect(const KillCommandResult(executed: true).alertCodes, isEmpty);
    });

    test('같은 command_id 재전달 = 처음 결과 그대로 · 새 행 0', () async {
      await activate();
      store.confirmChecklist(
        commandId: 'cmd-1',
        payloadDigest: 'd',
        answers: _answers,
        ack: _ack,
      );
      final KillCommandResult again = store.confirmChecklist(
        commandId: 'cmd-1',
        payloadDigest: 'd',
        answers: _answers,
        ack: _ack,
      );
      expect(
        (again.executed, again.replayed, again.decisionId),
        (true, true, 'J-KILL-1'),
      );
      expect(_count(db, 'decision_journal'), 1);
      expect(_count(db, 'command_inbox'), 1);
    });
  });

  group('재개(B3) · 판정식(B6)', () {
    Future<void> armed() async {
      await activate();
      store.confirmChecklist(
        commandId: 'cmd-1',
        payloadDigest: 'd',
        answers: _answers,
        ack: _ack,
      );
    }

    test('48h 전 = 거부 · 지나면 한 트랜잭션: 저널 · 해제 · 이력 · 명령 · 원장 판정 = 꺼짐', () async {
      await armed();
      trusted.at = _t0.add(const Duration(hours: 47, minutes: 59));
      expect(
        store
            .resume(commandId: 'r0', payloadDigest: 'd', checklist: _resume())
            .reasonCode,
        'RESUME_TOO_SOON',
      );
      expect(await ledger.killSwitchActive(), isTrue);
      trusted.at = _t0.add(const Duration(hours: 48));
      final KillCommandResult ok = store.resume(
        commandId: 'r1',
        payloadDigest: 'd',
        checklist: _resume(),
      );
      expect((ok.executed, ok.decisionId), (true, 'J-RESUME-1'));
      final KillSwitchRecord r = readKillSwitchRecord(db);
      expect(
        (r.clearedAtUtc, r.decisionId),
        (_t0.add(const Duration(hours: 48)), 'J-RESUME-1'),
      );
      final Row j = db
          .select(
            "SELECT * FROM decision_journal WHERE journal_id = 'J-RESUME-1'",
          )
          .single;
      expect(
        (
          j['kind'],
          j['trade_date'],
          j['is_deviation'],
          j['rationale_before'],
          j['expected_outcome'],
          j['rule_cited'],
        ),
        ('KILL_SWITCH_RESUME', '2026-11-06', 0, '조건 충족', '규칙대로', '04 §3-6'),
      );
      expect(
        (jsonDecode(j['signal_value'] as String) as List<dynamic>).length,
        7,
      );
      expect(_count(db, 'kill_switch_event', "kind = 'RESUMED'"), 1);
      expect(await ledger.killSwitchActive(), isFalse);
      // 같은 명령 재전달.
      expect(
        store
            .resume(commandId: 'r1', payloadDigest: 'd', checklist: _resume())
            .replayed,
        isTrue,
      );
      // 저널 id 중복.
      await activate();
      store.confirmChecklist(
        commandId: 'cmd-9',
        payloadDigest: 'd',
        answers: const KillActivationAnswers(
          ruleAction: 'x',
          reasonKind: KillReasonKind.rule,
          scenarioNone: true,
          resumeCondition: 'y',
          scope: KillScope.newEntriesOnly,
          journalDecisionId: 'J-KILL-9',
        ),
        ack: _ack,
      );
      trusted.at = trusted.at!.add(const Duration(hours: 49));
      expect(
        store
            .resume(commandId: 'r2', payloadDigest: 'd', checklist: _resume())
            .reasonCode,
        'JOURNAL_ID_TAKEN',
      );
    });

    test('확인 없이 = 거부 · 신뢰 시각 모름 = 거부', () async {
      await activate();
      trusted.at = _t0.add(const Duration(hours: 100));
      expect(
        store
            .resume(commandId: 'a', payloadDigest: 'd', checklist: _resume())
            .reasonCode,
        'RESUME_CHECKLIST_NOT_CONFIRMED',
      );
      store.confirmChecklist(
        commandId: 'cmd-1',
        payloadDigest: 'd',
        answers: _answers,
        ack: _ack,
      );
      trusted.at = null;
      expect(
        store
            .resume(commandId: 'b', payloadDigest: 'd', checklist: _resume())
            .reasonCode,
        'RESUME_TRUSTED_TIME_UNKNOWN',
      );
    });

    test('🔴 손으로 고친 행은 못 푼다 — 원장 판정 = v2.40 식', () async {
      await armed();
      db.execute(
        "UPDATE kill_switch_state SET cleared_at = '2026-11-04T02:00:00.000Z' WHERE id = 1",
      );
      expect(await ledger.killSwitchActive(), isTrue);
      db.execute(
        "UPDATE kill_switch_state SET decision_id = 'J-FAKE' WHERE id = 1",
      );
      expect(await ledger.killSwitchActive(), isTrue); // 확인 + 48h 전 해제
    });

    test('🔴 별도 커넥션 — 한 연결의 발동이 다른 연결의 주문 판정을 막는다', () async {
      final Database other = openLocalLedger(
        dir.path,
        RunMode.live,
        clock: () => _t0,
      );
      try {
        final SqliteOrderLedger otherLedger = SqliteOrderLedger(
          other,
          mode: RunMode.live,
          clock: clock,
          kr: frozenExchangeCalendar(Market.kr),
        );
        expect(await otherLedger.killSwitchActive(), isFalse);
        await activate();
        expect(await otherLedger.killSwitchActive(), isTrue);
      } finally {
        other.close();
      }
    });
  });

  group('취소 후보(B5) · 로컬 단락(B7)', () {
    test('오늘 · 의도별 가장 최근 주문 잔량 · UNKNOWN = 보고만', () async {
      final String a = await submitted('B-1', no: '11');
      final String u = await unknown('B-2');
      final List<KillCancelCandidate> c = store.cancelCandidates();
      expect(
        c.map(
          (KillCancelCandidate x) => (
            x.intentId,
            x.status,
            x.brokerOrderNo,
            x.remainingQty,
            x.account,
          ),
        ),
        <(String, IntentStatus, String?, int, String)>[
          if (a.compareTo(u) <
              0) ...<(String, IntentStatus, String?, int, String)>[
            (a, IntentStatus.submitted, '2026-11-04:11', 5, 'pension'),
            (u, IntentStatus.unknown, null, 0, 'pension'),
          ] else ...<(String, IntentStatus, String?, int, String)>[
            (u, IntentStatus.unknown, null, 0, 'pension'),
            (a, IntentStatus.submitted, '2026-11-04:11', 5, 'pension'),
          ],
        ],
      );
      expect(store.openOrderCount(), 1);
      // 다른 날의 의도는 보지 않는다.
      trusted.at = _t0.add(const Duration(days: 1));
      expect(store.cancelCandidates(), isEmpty);
    });

    test('🔴 날짜 = 한국 날짜 · 다시 낸 주문이 있으면 가장 최근 것의 잔량', () async {
      final String a = await submitted('B-1', no: '11');
      // 한국 11-04 00:30 = UTC 11-03 15:30 — UTC 날짜로 고르면 빠진다.
      trusted.at = DateTime.utc(2026, 11, 3, 15, 30);
      expect(
        store.cancelCandidates().map((KillCancelCandidate x) => x.intentId),
        <String>[a],
      );
      db.execute(
        'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status, filled_qty, remaining_qty) '
        "VALUES ('2026-11-04:12', ?, '2099-01-01T00:00:00.000Z', 'FILLED', 5, 0)",
        <Object?>[a],
      );
      final KillCancelCandidate c = store.cancelCandidates().single;
      expect((c.brokerOrderNo, c.remainingQty), ('2026-11-04:12', 0));
      expect(store.openOrderCount(), 0);
    });

    test('operator 로컬 단락 — 저장 + 취소 즉시 · 명령 기록 · 재전달 = 다시 취소하지 않음', () async {
      await submitted('B-1', no: '11');
      final FakeOrderBroker broker = FakeOrderBroker();
      final KillCommandResult r = await store.activateLocal(
        commandId: 'k-1',
        payloadDigest: 'dk',
        brokers: <String, OrderBroker>{'pension': broker},
        channel: 'app',
        deviceLabel: '내 폰',
      );
      expect(r.executed, isTrue);
      expect(broker.cancelled, <String>['2026-11-04:11']);
      expect(r.activation!.report.count(KillCancelOutcome.cancelled), 1);
      expect(killSwitchActive(readKillSwitchRecord(db)), isTrue);
      expect(_count(db, 'kill_switch_event', "kind = 'CANCEL_REPORT'"), 1);
      expect(
        db
            .select(
              "SELECT kind, state FROM command_inbox WHERE command_id = 'k-1'",
            )
            .single
            .values,
        <Object?>['KILL_SWITCH_ACTIVATE', 'EXECUTED'],
      );
      final KillCommandResult again = await store.activateLocal(
        commandId: 'k-1',
        payloadDigest: 'dk',
        brokers: <String, OrderBroker>{'pension': broker},
        channel: 'app',
      );
      expect((again.replayed, again.activation), (true, null));
      expect(broker.cancelled, hasLength(1));
      expect(_count(db, 'kill_switch_event', "kind = 'ACTIVATED'"), 1);
    });
  });
}
