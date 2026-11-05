// E13g1 — 규칙 변경 요청 큐 · 취소 · 승인 · CHANGELOG · SAF-405 읽기(설계 13 §8 R66 Y2~Y8).
//
// 🔵 잡는 것: ① 첫 승인(NONE → h0 · 냉각 30일만 · 12월 · DD 무관) ② 변경 승인 = 결정 행 + 🔴 승인 목록 하나
//    ③ 요청 = 언제든(깊은 DD · 12월 밖에도 접수) · 칸 · 기준 낡음 · config 없음 · 저널 3갈래(없음 · 빈칸 · 이미 씀)
//    ④ 취소 = 새 입력 0 · 결정 뒤 승인 불가 ⑤ 승인 거부(냉각 · 12월 · DD 락 · 제3자) = 명령만 ⑥ 신뢰 시각 모름
//    ⑦ 재전달 = 처음 결과 ⑧ 한 트랜잭션 ⑨ 큐 · CHANGELOG 10칸 ⑩ SAF-405 = 행 읽기 ⑪ 승인 둘 = 오류.
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show RuleChangeType, StartupGate, TrustedClock;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 1, 1);
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 1, 5);

void main() {
  late Directory dir;
  late Database db;
  late _Trusted trusted;
  late SqliteRuleChangeStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_rc_');
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteRuleChangeStore(db, clock: _Clock(), trusted: trusted);
    for (final String h in <String>['h0', 'h1', 'h2']) {
      db.execute(
        "INSERT INTO config_versions(config_hash, created_at, content, approved) VALUES (?, '2026-01-01T00:00:00.000Z', 'yaml', 0)",
        <Object?>[h],
      );
    }
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void journal(String id, {String? rule = 'RULE_OTHER'}) => db.execute(
    'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, is_deviation, '
    "rationale_before, expected_outcome, rule_cited, kind, note, created_at) VALUES (?, '2026-01-05', 'P0S', '{}', '{}', 0, '근거', '기대', ?, NULL, NULL, '2026-01-05T00:00:00.000Z')",
    <Object?>[id, rule],
  );

  void dd(String date, double v) => db.execute(
    'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
    "VALUES (?, 100, 0, 100, 120, ?, 'LIVE')",
    <Object?>[date, v],
  );

  int n = 0;
  RuleChangeResult ask(
    String before,
    String after,
    String j, {
    String reason = '  사유  ',
    String? cmd,
  }) => store.request(
    commandId: cmd ?? 'q-${n++}',
    payloadDigest: 'dg',
    changeType: RuleChangeType.strategyRule,
    hashBefore: before,
    hashAfter: after,
    reason: reason,
    rollbackMethod: ' 되돌린다 ',
    decisionId: j,
  );

  RuleChangeResult approve(
    String id, {
    bool? golden = false,
    String? approver = '본인',
    bool third = true,
    String? cmd,
  }) => store.approve(
    commandId: cmd ?? 'a-${n++}',
    payloadDigest: 'dg',
    requestId: id,
    goldenChanged: golden,
    approver: approver,
    thirdPartyNotified: third,
  );

  void at(DateTime t) => trusted.at = t;

  List<Object?> approvedRows() => db
      .select(
        'SELECT config_hash, approved FROM config_versions ORDER BY config_hash',
      )
      .map((Row r) => r['approved'])
      .toList();

  /// 첫 승인: NONE → h0(3월 · DD −50% — 12월 · DD 무관).
  void firstApprove() {
    journal('J0');
    expect(ask('NONE', 'h0', 'J0').executed, isTrue);
    at(DateTime.utc(2026, 3, 1));
    dd('2026-02-27', -0.5);
    expect(approve('RC-J0').executed, isTrue);
  }

  test('🔴 첫 승인 = 냉각 30일만(12월 · DD 무관) · 승인 목록 = h0 하나', () {
    journal('J0');
    expect(store.approvedConfigHash(), 'NONE');
    final RuleChangeResult r = ask('NONE', 'h0', 'J0');
    expect((r.executed, r.requestId), (true, 'RC-J0'));
    at(DateTime.utc(2026, 2, 3, 23, 59));
    expect(approve('RC-J0').reasonCode, 'RULE_CHANGE_COOLING');
    at(DateTime.utc(2026, 3, 1));
    dd('2026-02-27', -0.5);
    expect(
      approve('RC-J0', third: false).reasonCode,
      'RULE_CHANGE_THIRD_PARTY_MISSING',
    );
    expect(approve('RC-J0').executed, isTrue);
    expect(store.approvedConfigHash(), 'h0');
    expect(approvedRows(), <Object?>[1, 0, 0]);
    expect(approve('RC-J0').reasonCode, 'RULE_CHANGE_DECIDED');
  });

  test('🔴 변경 승인 = 12월 · DD 락 안 · 승인 목록 하나(h0 → h1 이면 h0 = 0)', () {
    firstApprove();
    journal('J1');
    at(DateTime.utc(2026, 10, 1));
    expect(ask('h0', 'h1', 'J1').executed, isTrue);
    at(DateTime.utc(2026, 11, 15));
    expect(approve('RC-J1').reasonCode, 'RULE_CHANGE_OUT_OF_WINDOW');
    at(DateTime.utc(2026, 12, 10));
    dd('2026-12-09', -0.10);
    expect(approve('RC-J1').reasonCode, 'RULE_CHANGE_DD_LOCKED');
    dd('2026-12-10', -0.04);
    expect(
      approve('RC-J1', golden: null).reasonCode,
      'RULE_CHANGE_APPROVAL_FIELDS_MISSING',
    );
    expect(approve('RC-J1', golden: true, approver: '  본인 ').executed, isTrue);
    expect(store.approvedConfigHash(), 'h1');
    expect(approvedRows(), <Object?>[0, 1, 0]);
    expect(
      db
          .select(
            "SELECT decided_at, outcome, golden_changed, approver, approval_dd, third_party_notified, decision_id FROM rule_change_decision WHERE request_id = 'RC-J1'",
          )
          .single
          .values,
      <Object?>[
        DateTime.utc(2026, 12, 10).toIso8601String(),
        'APPROVED',
        1,
        '본인',
        -0.04,
        1,
        'J1',
      ],
    );
  });

  test('🔴 요청 = 언제든(깊은 DD · 12월 밖) · 칸 · 기준 낡음 · config 없음 · 저널 3갈래', () {
    firstApprove();
    at(DateTime.utc(2026, 4, 1));
    dd('2026-03-31', -0.3);
    journal('J1');
    journal('J2', rule: ' ');
    journal('J3');
    expect(ask('h0', 'h1', 'J1').executed, isTrue);
    expect(ask('h0', 'h0', 'J3').reasonCode, 'RULE_CHANGE_FIELDS_MISSING');
    expect(
      ask('h0', 'h1', 'J3', reason: ' ').reasonCode,
      'RULE_CHANGE_FIELDS_MISSING',
    );
    expect(ask('NONE', 'h1', 'J3').reasonCode, 'RULE_CHANGE_BASE_STALE');
    expect(ask('h0', 'h9', 'J3').reasonCode, 'RULE_CHANGE_CONFIG_UNKNOWN');
    expect(ask('h0', 'h2', 'NONE').reasonCode, 'RULE_CHANGE_JOURNAL_MISSING');
    expect(ask('h0', 'h2', 'J2').reasonCode, 'RULE_CHANGE_JOURNAL_MISSING');
    expect(ask('h0', 'h2', 'J1').reasonCode, 'RULE_CHANGE_JOURNAL_MISSING');
    expect(
      db
          .select(
            "SELECT reason, rollback_method, requested_at FROM rule_change_request WHERE request_id = 'RC-J1'",
          )
          .single
          .values,
      <Object?>['사유', '되돌린다', DateTime.utc(2026, 4, 1).toIso8601String()],
    );
    expect(
      db
          .select(
            "SELECT COUNT(*) AS n FROM command_inbox WHERE kind = 'RULE_CHANGE_REQUEST' AND state = 'REJECTED'",
          )
          .single['n'],
      7,
    );
  });

  test('🔴 기준 낡음 — 같은 기준의 두 요청 중 하나가 승인되면 나머지는 승인 불가', () {
    firstApprove();
    journal('J1');
    journal('J2');
    at(DateTime.utc(2026, 10, 1));
    expect(ask('h0', 'h1', 'J1').executed, isTrue);
    expect(ask('h0', 'h2', 'J2').executed, isTrue);
    at(DateTime.utc(2026, 12, 10));
    dd('2026-12-09', -0.01);
    expect(approve('RC-J1').executed, isTrue);
    expect(approve('RC-J2').reasonCode, 'RULE_CHANGE_BASE_STALE');
  });

  test('취소 = 새 입력 0 · decision_id = 요청 저널 · 취소 뒤 승인 · 다시 취소 불가', () {
    journal('J0');
    expect(ask('NONE', 'h0', 'J0').executed, isTrue);
    final RuleChangeResult c = store.cancel(
      commandId: 'c-1',
      payloadDigest: 'dg',
      requestId: 'RC-J0',
    );
    expect((c.executed, c.requestId), (true, 'RC-J0'));
    expect(
      db
          .select(
            "SELECT * FROM rule_change_decision WHERE request_id = 'RC-J0'",
          )
          .single
          .values,
      <Object?>[
        'RC-J0',
        _t0.toIso8601String(),
        'CANCELLED',
        null,
        null,
        null,
        null,
        'J0',
      ],
    );
    at(DateTime.utc(2026, 3, 1));
    expect(approve('RC-J0').reasonCode, 'RULE_CHANGE_DECIDED');
    expect(
      store
          .cancel(commandId: 'c-2', payloadDigest: 'dg', requestId: 'RC-J0')
          .reasonCode,
      'RULE_CHANGE_DECIDED',
    );
    expect(
      store
          .cancel(commandId: 'c-3', payloadDigest: 'dg', requestId: 'RC-NONE')
          .reasonCode,
      'RULE_CHANGE_NOT_FOUND',
    );
    expect(approve('RC-NONE').reasonCode, 'RULE_CHANGE_NOT_FOUND');
    expect(store.approvedConfigHash(), 'NONE');
  });

  test('신뢰 시각 모름 = 요청 · 취소 · 승인 모두 거부(행 0)', () {
    journal('J0');
    trusted.at = null;
    expect(ask('NONE', 'h0', 'J0').reasonCode, 'TRUSTED_TIME_UNKNOWN');
    trusted.at = _t0;
    expect(ask('NONE', 'h0', 'J0').executed, isTrue);
    trusted.at = null;
    expect(
      store
          .cancel(commandId: 'c', payloadDigest: 'dg', requestId: 'RC-J0')
          .reasonCode,
      'TRUSTED_TIME_UNKNOWN',
    );
    expect(approve('RC-J0').reasonCode, 'TRUSTED_TIME_UNKNOWN');
    expect(db.select('SELECT 1 FROM rule_change_decision'), isEmpty);
  });

  test('같은 command_id 재전달 = 처음 결과 · 새 행 0', () {
    journal('J0');
    expect(ask('NONE', 'h0', 'J0', cmd: 'q').executed, isTrue);
    final RuleChangeResult again = ask('NONE', 'h1', 'J0', cmd: 'q');
    expect(
      (again.executed, again.replayed, again.requestId),
      (true, true, 'RC-J0'),
    );
    final RuleChangeResult a1 = approve('RC-J0', cmd: 'a');
    final RuleChangeResult a2 = approve('RC-J0', cmd: 'a');
    expect((a1.replayed, a1.reasonCode), (false, 'RULE_CHANGE_COOLING'));
    expect(
      (a2.executed, a2.replayed, a2.reasonCode, a2.requestId),
      (false, true, 'RULE_CHANGE_COOLING', null),
    );
    expect(
      db.select('SELECT COUNT(*) AS n FROM rule_change_request').single['n'],
      1,
    );
  });

  test('🔴 한 트랜잭션 — 명령 기록이 실패하면 결정 · 승인 목록도 그대로', () {
    journal('J0');
    expect(ask('NONE', 'h0', 'J0').executed, isTrue);
    at(DateTime.utc(2026, 3, 1));
    db.execute(
      "CREATE TRIGGER no_cmd BEFORE INSERT ON command_inbox BEGIN SELECT RAISE(ABORT, 'x'); END",
    );
    expect(() => approve('RC-J0'), throwsA(isA<SqliteException>()));
    expect(db.select('SELECT 1 FROM rule_change_decision'), isEmpty);
    expect(store.approvedConfigHash(), 'NONE');
    expect(db.autocommit, isTrue);
  });

  test('큐(미결정 · 요청 시각 차례 · 첫 승인 표시) · CHANGELOG 10칸(승인만 · 승인일 차례)', () {
    firstApprove();
    journal('J1');
    journal('J2');
    journal('J3');
    // 요청 시각 차례(J2 → J1)가 id 차례(J1 → J2)와 다르게.
    at(DateTime.utc(2026, 10, 2));
    expect(ask('h0', 'h1', 'J1').executed, isTrue);
    at(DateTime.utc(2026, 10, 1));
    expect(ask('h0', 'h2', 'J2').executed, isTrue);
    at(DateTime.utc(2026, 10, 3));
    expect(ask('h0', 'h1', 'J3').executed, isTrue);
    expect(
      store
          .cancel(commandId: 'c', payloadDigest: 'dg', requestId: 'RC-J3')
          .executed,
      isTrue,
    );
    final List<RuleChangeQueueItem> q = store.queue();
    expect(q.map((RuleChangeQueueItem i) => i.requestId), <String>[
      'RC-J2',
      'RC-J1',
    ]);
    expect(
      (
        q.first.changeType,
        q.first.hashBefore,
        q.first.hashAfter,
        q.first.firstApproval,
      ),
      (RuleChangeType.strategyRule, 'h0', 'h2', false),
    );
    expect(q.first.coolingEndsAtUtc, DateTime.utc(2026, 10, 31));
    at(DateTime.utc(2026, 12, 10));
    dd('2026-12-09', -0.02);
    expect(approve('RC-J2').executed, isTrue);
    final List<ChangelogEntry> log = store.changelog();
    expect(log.map((ChangelogEntry e) => e.decisionId), <String>['J0', 'J2']);
    final ChangelogEntry e = log.first;
    expect(
      (
        e.decidedAtUtc,
        e.changeType,
        e.goldenChanged,
        e.hashBefore,
        e.hashAfter,
        e.reason,
        e.approver,
        e.requestedAtUtc,
        e.approvalDd,
        e.rollbackMethod,
        e.decisionId,
      ),
      (
        DateTime.utc(2026, 3, 1),
        RuleChangeType.strategyRule,
        false,
        'NONE',
        'h0',
        '사유',
        '본인',
        _t0,
        -0.5,
        '되돌린다',
        'J0',
      ),
    );
    expect(
      (log.last.decidedAtUtc, log.last.approvalDd),
      (DateTime.utc(2026, 12, 10), -0.02),
    );
  });

  test('스냅숏 없음 = DD 0 — 승인 시점 DD 칸 = 0', () {
    journal('J0');
    expect(ask('NONE', 'h0', 'J0').executed, isTrue);
    at(DateTime.utc(2026, 3, 1));
    expect(approve('RC-J0').executed, isTrue);
    expect(store.changelog().single.approvalDd, 0.0);
  });

  test('SAF-405 = 행 읽기 — live 미승인 · 행 없음 = 기동 거부 · 승인 = 기동 · 모의 = 기동', () {
    StartupGate g(String h, RunMode m) => store.startupGate(h, m);
    expect(g('h0', RunMode.live).start, isFalse);
    expect(g('h9', RunMode.live).triggered, <String>['SAF-405']);
    expect(g('h0', RunMode.simInternal).start, isTrue);
    firstApprove();
    expect(g('h0', RunMode.live).start, isTrue);
    expect(g('h1', RunMode.live).start, isFalse);
  });

  test('오프셋 없는 시각 = 형식 오류(기기 지역 시각으로 읽지 않는다)', () {
    db.execute(
      'INSERT INTO rule_change_request(request_id, requested_at, change_type, config_hash_before, '
      "config_hash_after, reason, rollback_method, decision_id) VALUES ('RC-x', '2026-01-05T00:00:00', 'INFRA', 'NONE', 'h0', 'r', 'b', 'x')",
    );
    expect(store.queue, throwsFormatException);
  });

  test('🔴 승인 둘 = 원장 오류(승인 목록 = 하나)', () {
    db.execute(
      "UPDATE config_versions SET approved = 1 WHERE config_hash IN ('h0', 'h1')",
    );
    expect(store.approvedConfigHash, throwsStateError);
  });
}
