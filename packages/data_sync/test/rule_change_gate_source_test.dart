// E11q-c0 — 규칙 변경 «저널 함께 쓰기» 요청 + M5-9 게이트 원천(설계 13 §8 R188 · 01 §35 K178 · K180 · 미결 205 ⓐ · 206).
//
// 🔴 요청 + 사전 저널 = 한 트랜잭션(거부 = 저널 · 요청 0 · 명령 행만) · 신뢰 시각 모름 = 맨 먼저 거부 · 저널 세 칸 빈칸 =
//    `RULE_CHANGE_JOURNAL_MISSING` · 저널 id 겹침 = `JOURNAL_ID_TAKEN` · 같은 명령 재전달 = 처음 결과 · 후보 = 요청 뒤 사라진다.

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        RuleChangeCodes,
        RuleChangeType,
        TrustedClock,
        kJournalIdTaken,
        kNoApprovedConfig;
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
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 12, 10, 1, 5); // 한국 12-10 10:05

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;
  late String hash;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_rcg_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    hash = SqliteConfigVersionStore(
      db,
      clock: clock,
    ).register(<String, Object?>{'p0s': true, 'v': 1});
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteRuleChangeStore store() =>
      SqliteRuleChangeStore(db, clock: clock, trusted: trusted);

  SqliteRuleChangeGateSource src({String? current, bool canWrite = true}) =>
      SqliteRuleChangeGateSource(
        db,
        clock: clock,
        trusted: trusted,
        currentConfigHash: current ?? hash,
        canWrite: canWrite,
      );

  RuleChangeResult ask({
    String cmd = 'cmd-1',
    String journalId = 'JRC-1',
    String rationale = '첫 승인 근거',
    String after = '',
  }) => store().requestWithJournal(
    commandId: cmd,
    payloadDigest: 'd',
    changeType: RuleChangeType.strategyRule,
    hashBefore: kNoApprovedConfig,
    hashAfter: after.isEmpty ? hash : after,
    reason: '첫 승인',
    rollbackMethod: '이전 설정으로',
    journalId: journalId,
    rationaleBefore: rationale,
    expectedOutcome: '실전 기동 조건',
    ruleCited: '03 §6-4',
  );

  int count(String table) =>
      db.select('SELECT COUNT(*) AS n FROM $table').first['n']! as int;

  test('🔴 신뢰 시각 모름 = 맨 먼저 거부 · 저널 · 요청 0(명령 행만)', () {
    trusted.at = null;
    final RuleChangeResult r = ask();
    expect(
      (r.executed, r.reasonCode),
      (false, RuleChangeCodes.trustedTimeUnknown),
    );
    expect((count('decision_journal'), count('rule_change_request')), (0, 0));
    expect(
      db
          .select("SELECT state FROM command_inbox WHERE command_id = 'cmd-1'")
          .single['state'],
      'REJECTED',
    );
  });

  test('저널 세 칸 빈칸 = JOURNAL_MISSING · 등재 안 된 지문 = CONFIG_UNKNOWN · 저널 id 겹침 = JOURNAL_ID_TAKEN', () {
    expect(ask(rationale: '  ').reasonCode, RuleChangeCodes.journalMissing);
    expect(
      ask(cmd: 'cmd-2', after: 'not_registered_hash').reasonCode,
      RuleChangeCodes.configUnknown,
    );
    db.execute(
      'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
      "is_deviation, created_at) VALUES ('JRC-9', '2026-12-10', 'S', '{}', '{}', 0, '2026-12-10T01:00:00Z')",
    );
    expect(ask(cmd: 'cmd-3', journalId: 'JRC-9').reasonCode, kJournalIdTaken);
    expect(count('rule_change_request'), 0);
    expect(count('decision_journal'), 1);
  });

  test(
    '🔴 성공 = 저널(RULE_CHANGE_REQUEST · 세 칸) + 요청 한 트랜잭션 · 재전달 = 처음 결과 · 큐 1',
    () {
      final RuleChangeResult r = ask();
      expect((r.executed, r.requestId), (true, 'RC-JRC-1'));
      final Row j = db
          .select(
            "SELECT kind, rationale_before, expected_outcome, rule_cited FROM decision_journal WHERE journal_id = 'JRC-1'",
          )
          .single;
      expect(
        (
          j['kind'],
          j['rationale_before'],
          j['expected_outcome'],
          j['rule_cited'],
        ),
        ('RULE_CHANGE_REQUEST', '첫 승인 근거', '실전 기동 조건', '03 §6-4'),
      );
      final Row q = db
          .select(
            'SELECT config_hash_before, config_hash_after, change_type, decision_id FROM rule_change_request',
          )
          .single;
      expect(
        (
          q['config_hash_before'],
          q['config_hash_after'],
          q['change_type'],
          q['decision_id'],
        ),
        (kNoApprovedConfig, hash, 'STRATEGY_RULE', 'JRC-1'),
      );
      final RuleChangeResult again = ask();
      expect(
        (again.executed, again.replayed, again.requestId),
        (true, true, 'RC-JRC-1'),
      );
      expect(count('rule_change_request'), 1);
      expect(store().queue().single.requestId, 'RC-JRC-1');
    },
  );

  test(
    '게이트 원천 — 요청 전 = 후보 1(지금 지문) · 요청 뒤 = 후보 0 · 냉각 행 1 · 쓰기 창구 없음 = 후보 0',
    () {
      expect(src().candidate()?.candidateId, hash);
      final RuleChangeGateVm before = src().gate();
      expect(
        (before.headline, before.candidates.single.candidateId),
        ('승인된 설정이 없습니다 — 실전 기동 전에 첫 승인이 필요합니다', hash),
      );
      expect(src(canWrite: false).gate().candidates, isEmpty);
      expect(src(current: 'unregistered').candidate(), isNull);
      ask();
      expect(src().candidate(), isNull);
      final RuleChangeGateVm after = src().gate();
      expect(
        (after.headline, after.candidates.length, after.rows.single.requestId),
        ('첫 승인 요청이 냉각 중입니다', 0, 'RC-JRC-1'),
      );
      expect(after.rows.single.coolingText, '냉각 중 — 01-09 10:05 이후 승인');
      expect(after.rows.single.cancel?.args, <String, String>{
        'request_id': 'RC-JRC-1',
      });
    },
  );

  test('감시 표', () {
    expect(
      SqliteRuleChangeGateSource.watchedTables,
      containsAll(<String>[
        'rule_change_request',
        'rule_change_decision',
        'config_versions',
      ]),
    );
  });
}
