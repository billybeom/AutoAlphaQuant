// 🆕 미결 220 ⓔⓕ — J-3 사전 저널 쓰기 저장소(`JOURNAL_DRAFT` · 계약 v1.35 01 §44 K296 ~ K299) — 실 SQLite(live 원장).
//
// 🔵 잡는 것: ① 채우기 = 빈 칸만(채워진 칸 · kind 유지) → SAF-408 자동 해제 ② 다 찬 행 = 이미 있음(원장 그대로 · 접수 1행)
//    ③ 같은 명령 id = 처음 접수 그대로 ④ 모르는 키 · 결정 id = 대상 없음 · 입력 조건 = 입력 거부(원장 쓰기 0) ⑤ 새 행 = 키의 목적
//    (kind · 이탈 여부 · 코드 인용) · 두 번째 = 이미 있음 ⑥ 무결성 표시 = 보관(원장 쓰기 0) → 풀린 뒤 같은 명령 = 집행(접수 행 고쳐 씀).

import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
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
  final DateTime at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 23, 1); // 한국 11-23 10:00

const String _rationale = '근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거';

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late SqliteJournalDraftStore store;
  int n = 0;
  setUp(() {
    n = 0;
    dir = Directory.systemTemp.createTempSync('aaq_j3_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteJournalDraftStore(db, clock: clock);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  JournalDraftWriteResult submit(
    String key, {
    String rationale = _rationale,
    String expected = '기대 결과',
    String rule = JournalRuleCitedCodes.reconCause,
    String? note,
    String? commandId,
  }) => store.submit(
    commandId: commandId ?? 'cmd-${++n}',
    payloadDigest: 'digest',
    draft: JournalDraft(
      decisionId: key,
      rationaleBefore: rationale,
      expectedOutcome: expected,
      ruleCited: rule,
      note: note,
    ),
    runMode: RunMode.live,
    operatingMode: OperatingMode.autoTrade,
  );

  Map<String, Object?> journal(String id) {
    final Row r = db.select(
      'SELECT * FROM decision_journal WHERE journal_id = ?',
      <Object?>[id],
    ).single;
    return <String, Object?>{for (final String k in r.keys) k: r[k]};
  }

  Map<String, Object?> inbox(String id) {
    final Row r = db.select(
      'SELECT * FROM command_inbox WHERE command_id = ?',
      <Object?>[id],
    ).single;
    return <String, Object?>{for (final String k in r.keys) k: r[k]};
  }

  int count(String table) =>
      db.select('SELECT COUNT(*) AS c FROM $table').single['c'] as int;

  void incomplete(
    String id, {
    String? expected = '이미 쓴 기대',
    String kind = 'RECON_CLEAR',
  }) => db.execute(
    'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
    'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
    "VALUES (?, '2026-11-20', 'P0S', '{}', '{}', 1, NULL, ?, NULL, ?, NULL, '2026-11-20T01:00:00.000Z')",
    <Object?>[id, expected, kind],
  );

  SqliteOrderLedger ledger() => SqliteOrderLedger(
    db,
    mode: RunMode.live,
    clock: clock,
    kr: frozenExchangeCalendar(Market.kr),
  );

  test('① 채우기 = 빈 칸만(채워진 칸 · kind 유지) · 접수 = 저장 · SAF-408 자동 해제', () async {
    incomplete('J-R');
    expect(await ledger().journalMissing(), isTrue);
    final JournalDraftWriteResult r = submit('J-R', note: '  메모  ');
    expect(r.state, CommandState.executed);
    expect(r.stateLabel, '저장됨 — 사전 저널이 기록되었습니다');
    expect(r.replayed, isFalse);
    final Map<String, Object?> j = journal('J-R');
    expect(
      (
        j['rationale_before'],
        j['expected_outcome'],
        j['rule_cited'],
        j['kind'],
        j['is_deviation'],
        j['note'],
      ),
      (_rationale, '이미 쓴 기대', 'RULE_RECON_CAUSE', 'RECON_CLEAR', 1, '메모'),
    );
    expect(await ledger().journalMissing(), isFalse);
    final Map<String, Object?> c = inbox('cmd-1');
    expect(
      (
        c['kind'],
        c['state'],
        c['reject_reason_code'],
        c['decision_id'],
        c['run_mode'],
        c['payload_digest'],
      ),
      ('JOURNAL_DRAFT', 'EXECUTED', null, 'J-R', 'LIVE', 'digest'),
    );
  });

  test('② 다 찬 행 = 이미 있음 · 원장 그대로 · 접수 1행(거부)', () {
    incomplete('J-R');
    submit('J-R');
    final Map<String, Object?> before = journal('J-R');
    final JournalDraftWriteResult r = submit(
      'J-R',
      rationale: '$_rationale 다시',
    );
    expect(
      (r.state, r.rejectCode),
      (CommandState.rejected, 'JOURNAL_ALREADY_EXISTS'),
    );
    expect(r.stateLabel, startsWith('거부됨 — 이 결정의 사전 저널이 이미 있습니다'));
    expect(journal('J-R'), before);
    expect(
      (inbox('cmd-2')['state'], inbox('cmd-2')['decision_id']),
      ('REJECTED', null),
    );
  });

  test('③ 같은 명령 id = 처음 접수 그대로(쓰기 0)', () {
    incomplete('J-R');
    final JournalDraftWriteResult first = submit('J-R', commandId: 'same');
    final int inboxRows = count('command_inbox');
    final JournalDraftWriteResult again = submit(
      'J-R',
      commandId: 'same',
      rationale: '짧다',
    );
    expect(again.replayed, isTrue);
    expect(
      (again.state, again.stateLabel, again.rejectCode),
      (first.state, first.stateLabel, null),
    );
    expect(count('command_inbox'), inboxRows);
  });

  test('④ 모르는 키 · 결정 id · 엔진 꼴 밖 = 대상 없음 · 입력 조건 = 입력 거부 — 원장 쓰기 0', () {
    incomplete('J-R');
    final int journals = count('decision_journal');
    for (final String k in <String>[
      'nope',
      'B-SMA-2026-07-31@2026-08-04',
      'JD-RECON_CLEAR-0011223344556677',
    ]) {
      expect(submit(k).rejectCode, 'JOURNAL_TARGET_UNKNOWN', reason: k);
    }
    expect(submit('J-R', expected: '  ').rejectCode, 'JOURNAL_INPUT_INVALID');
    expect(
      submit('J-R', rule: 'RULE_OTHER').rejectCode,
      'JOURNAL_INPUT_INVALID',
    );
    expect(submit('J-R', rule: '03 §4-1').rejectCode, 'JOURNAL_INPUT_INVALID');
    expect(
      submit('J-R', rationale: _rationale.substring(1)).rejectCode,
      'JOURNAL_INPUT_INVALID',
    );
    expect(count('decision_journal'), journals);
    expect(journal('J-R')['rationale_before'], isNull);
    expect(inbox('cmd-1')['reject_reason_code'], 'JOURNAL_TARGET_UNKNOWN');
  });

  test('⑤ 새 행 = 키의 목적(재량 = 이탈 · 서약 편집 = 이탈 아님 · 코드 인용) · 두 번째 = 이미 있음', () {
    final Random rnd = Random(5);
    final String disc = issueJournalDraftKey(
      purpose: 'DISCRETION',
      random: rnd,
    );
    final String pledge = issueJournalDraftKey(
      purpose: 'PLEDGE_EDIT',
      random: rnd,
    );
    expect(
      submit(disc, rule: JournalRuleCitedCodes.discretionBudget).state,
      CommandState.executed,
    );
    expect(
      submit(pledge, rule: 'RULE_OTHER', note: '편집 사유').state,
      CommandState.executed,
    );
    final Map<String, Object?> d = journal(disc);
    expect(
      (
        d['kind'],
        d['is_deviation'],
        d['rule_cited'],
        d['trade_date'],
        d['strategy_id'],
        d['created_at'],
      ),
      (
        'DISCRETION',
        1,
        'RULE_DISCRETION_BUDGET',
        '2026-11-23',
        'P0S',
        _t0.toIso8601String(),
      ),
    );
    final Map<String, Object?> p = journal(pledge);
    expect(
      (p['kind'], p['is_deviation'], p['note']),
      ('PLEDGE_EDIT', 0, '편집 사유'),
    );
    expect(submit(disc).rejectCode, 'JOURNAL_ALREADY_EXISTS');
    // 서약 편집이 그 id 를 받는다(사전 3칸이 찬 저널 = 연결됨 — pledge_store 판정).
    expect(store.rowOf(pledge)!.complete, isTrue);
    // ⓕ 재량 조정(M5-7)이 그 id 를 받는다 — 저널 연결 판정 통과(kind DISCRETION · 사전 3칸) → 조정 반영.
    final DiscretionResult adj =
        SqliteDiscretionStore(
          db,
          clock: clock,
          trusted: _Trusted(_t0),
        ).requestAdjustment(
          commandId: 'adj-1',
          payloadDigest: 'd',
          deltaPct: 0.05,
          decisionId: disc,
        );
    expect(adj.reasonCodes, isEmpty);
    expect(adj.executed, isTrue);
  });

  test('⑥ 무결성 표시 = 보관(원장 쓰기 0) · 서 있는 동안 같은 명령 = 보관 그대로 · 풀린 뒤 같은 명령 = 집행(접수 행 고쳐 씀)', () {
    incomplete('J-R');
    db.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>[FlagIds.ledgerIntegrity, _t0.toIso8601String(), '시험'],
    );
    final JournalDraftWriteResult held = submit('J-R', commandId: 'h');
    expect(held.state, CommandState.heldForIntegrity);
    expect(held.stateLabel, startsWith('보류됨 — 원장 무결성 점검 중이라 보관했습니다'));
    expect(journal('J-R')['rationale_before'], isNull);
    expect(inbox('h')['state'], 'HELD_FOR_INTEGRITY');
    expect(submit('J-R', commandId: 'h').replayed, isTrue);
    db.execute(
      'UPDATE trading_block SET cleared_at = ?, cleared_by = ? WHERE flag_id = ?',
      <Object?>[_t0.toIso8601String(), 'test', FlagIds.ledgerIntegrity],
    );
    clock.at = _t0.add(const Duration(minutes: 5));
    final JournalDraftWriteResult done = submit('J-R', commandId: 'h');
    expect((done.state, done.replayed), (CommandState.executed, false));
    expect(journal('J-R')['rationale_before'], _rationale);
    expect(
      (inbox('h')['state'], inbox('h')['decision_id']),
      ('EXECUTED', 'J-R'),
    );
    expect(
      db
          .select(
            "SELECT COUNT(*) AS c FROM command_inbox WHERE command_id = 'h'",
          )
          .single['c'],
      1,
    );
  });
}
