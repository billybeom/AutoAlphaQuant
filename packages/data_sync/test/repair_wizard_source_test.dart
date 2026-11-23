// 🆕 E16j-a — X5 정정 마법사 원천(01 §8 미결 217 ⓑⓔ · 계약 v1.32 K249).
//
// 🔵 잡는 것: ① 허브 = 원장의 열린 CANON_BROKER 승인 diff · 무결성 표시가 서면 `li-` 대상 · 표시가 없으면 판정 0
//    ② 대상 = 그 diff · 체결 후보(원장 체결) · 세션 행 · 서약 문장 · 재량 예산 ③ 신뢰 시각 모름 = 단계 동작 0
//    ④ 끝 · 모르는 대상 ⑤ 감시 표 = 마법사가 읽는 표 전부 ⑥ 새 기준점 끝까지(원천 → 세션 → 커밋 → 허브 빈 판).
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'support/intervention_seed.dart';
import 'support/ledger_golden.dart';

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

// 2026-11-04T15:00Z = 한국 11-05 00:00.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 15);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_rw_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0.add(const Duration(hours: 1)));
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteRepairWizardSource source({
    bool writable = true,
    List<String> pledge = const <String>['하나', '둘', '셋'],
  }) => SqliteRepairWizardSource(
    db,
    clock: clock,
    trusted: trusted,
    writable: writable,
    hasBody: (String _) => true,
    pledgeLines: () => pledge,
  );

  void diff(
    String id, {
    String status = 'OPEN',
    String pair = 'CANON_BROKER',
    String detected = '2026-11-04T01:00:00.000Z',
  }) => db.execute(
    'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, severity, origin_code, '
    "status, detected_at, applicable) VALUES (?, ?, 'QUANTITY', '2026-11-04', "
    '\'{"kind":"QTY","account":"pension","key":"133690","ledger":5,"broker":3,"candidates":["MANUAL_ORDER"]}\', '
    "'133690 보유 — 원장 5주 · 브로커 3주', 'BLOCKING', NULL, ?, ?, 1)",
    <Object?>[id, pair, status, detected],
  );

  /// 골든 · 스탬프 → 지난날(11-02) 손으로 고침 → 무결성 검사 = LEDGER_INTEGRITY.
  void broken() {
    loadLedgerGolden(db);
    LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
    db.execute(
      "UPDATE decision_log SET reason = reason || '.' WHERE decision_id = 'D-1'",
    );
    expect(LedgerIntegrityCheck(db, clock: clock).run().flagRaised, isTrue);
  }

  test('① 빈 원장 = 빈 허브 · 끝 문장', () {
    final RepairWizardVm vm = source().vm();
    expect(
      (vm.headline, vm.level, vm.doneLabel),
      (RepairWizardTexts.hubEmpty, UiLevel.ok, RepairWizardTexts.hubEmptyDone),
    );
  });

  test('① 허브 = 열린 CANON_BROKER 승인 diff 만(닫힌 · 파생 쌍 빠짐) · 링크 = 대상 라우트', () {
    diff('ld-a');
    diff('ld-b', status: 'RESOLVED');
    diff('ld-c', pair: 'CANON_GITHUB');
    final RepairWizardVm vm = source().vm();
    expect(vm.targetLinks.map((LinkAction l) => l.deepLink), <String>[
      'aaq://x5/repair-wizard/ld-a',
    ]);
    expect(vm.targetLinks.single.label, '체결 차이 — 11-04 탐지');
  });

  test('② 대상 = diff · 후보 없음(원장 체결 0) = 아무것도 안 하기만 · 근거 행', () {
    diff('ld-a');
    final RepairWizardVm vm = source().vm(targetId: 'ld-a');
    expect(vm.diff!.diffId, 'ld-a');
    expect(vm.stages, isEmpty);
    expect(vm.doNothingAction!.args, <String, String>{'diff_id': 'ld-a'});
    expect(vm.headline, RepairWizardTexts.noFills);
  });

  test('② 대상 + 세션 행 = 단계 · 서약 재생 · 🔴 신뢰 시각 모름 = 동작 0', () {
    diff('ld-a');
    // 후보 없이도 세션 판을 보려고 체결 후보 원천을 쓰지 않는 무결성 대상 대신 — 세션 2단계 차례를 행으로 만든다.
    seedSessionSteps(db, 'x5:ld-a:1', <(int, DateTime, String?)>[
      (1, trusted.at!.subtract(const Duration(minutes: 5)), null),
    ]);
    final RepairWizardFacts f = source().facts(targetId: 'ld-a');
    expect(f.sessions.keys, <String>['x5:ld-a:1']);
    expect(f.pledgeLines, <String>['하나', '둘', '셋']);
    expect(f.budgetExhausted, isFalse);
    expect(f.targetDiff!.diffId, 'ld-a');
    expect(f.integrityFlag, isFalse);
    trusted.at = null;
    expect(source().facts(targetId: 'ld-a').trustedNowUtc, isNull);
  });

  test('④ 끝 · 모르는 대상 · 잠김', () {
    diff('ld-a', status: 'ACCEPTED');
    expect(
      source().vm(targetId: 'ld-a').headline,
      RepairWizardTexts.doneAccepted,
    );
    expect(
      source().vm(targetId: 'ld-zz').headline,
      RepairWizardTexts.unknownTarget,
    );
    diff('ld-b');
    expect(
      source(writable: false).vm(targetId: 'ld-b').lockedLabel,
      RepairWizardTexts.locked,
    );
  });

  test('⑤ 감시 표 = 마법사가 읽는 표 전부(스키마에 있다)', () {
    final Set<String> tables = <String>{
      for (final Row r in db.select(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      ))
        r['name'] as String,
    };
    expect(tables, containsAll(SqliteRepairWizardSource.watchedTables));
    expect(
      SqliteRepairWizardSource.watchedTables,
      containsAll(<String>[
        'ledger_diff',
        'trading_block',
        'intervention_step',
        'decision_journal',
        'ledger_daily_hash',
        'executions',
        'discretion_adjustment',
      ]),
    );
  });

  test('① 무결성 표시 = `li-` 대상 → ⑥ 세션 실행 창 → 새 기준점 커밋 → 허브 빈 판', () {
    broken();
    final RepairWizardVm hub = source().vm();
    final String link = hub.targetLinks.single.deepLink;
    expect(link, startsWith('aaq://x5/repair-wizard/li-'));
    final String li = link.substring('aaq://x5/repair-wizard/'.length);
    expect(li, integrityTargetIdOf(source().facts()));
    final RepairWizardVm start = source().vm(targetId: li);
    expect(start.reasonCode, 'CONTENT_MISMATCH');
    expect(start.targetLines, <String>['첫 어긋난 날 11-02']);
    expect(start.baselineLabel, isNull);
    final String sid = start.stages.first.actions.single.args['session_id']!;
    expect(sid, x5SessionIdOf(li, 1));
    seedExecutableSession(db, sid, nowUtc: trusted.at!, journalId: 'JIV-1');
    final RepairWizardVm ready = source().vm(targetId: li);
    expect(ready.baselineLabel, RepairWizardTexts.baseline);
    expect(ready.origins.map((RepairOriginChoice o) => o.originCode), <String>[
      'CHAIN_BROKEN',
      'DB_ERROR',
    ]);
    final BaselineResult r = SqliteLedgerRepairStore(db, trusted: trusted)
        .applyBaseline(
          repairId: 'rp-1',
          sessionId: sid,
          originCode: 'CHAIN_BROKEN',
          clearedBy: '운영 폰',
        );
    expect(r.applied, isTrue);
    expect(source().vm().headline, RepairWizardTexts.hubEmpty);
    expect(
      source().vm(targetId: li).doneLabel,
      RepairWizardTexts.integrityNone,
    );
  });
}
