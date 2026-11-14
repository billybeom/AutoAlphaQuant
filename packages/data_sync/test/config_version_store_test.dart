// E11p3b-1 — 설정 등재 · 승인 읽기(설계 13 §8 R90 · 02 §2 `config_versions` · 04 §1 SAF-405).

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.now);

  DateTime now;

  @override
  DateTime nowUtc() => now;
}

/// 시험용 사람 값(실제 값 아님).
P0sOpsConfig _config({String a = '999990'}) => P0sOpsConfig.of(
  P0sHumanInputs(
    aSymbol: a,
    accountByStrategy: <String, String>{
      P0sStrategyIds.sleeveA: 'acct_x',
      P0sStrategyIds.sleeveB: 'acct_pension',
      P0sStrategyIds.sleeveC: 'acct_general',
      P0sStrategyIds.pot: 'acct_x',
    },
  ),
);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late SqliteConfigVersionStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('cfgv_');
    clock = _Clock(DateTime.utc(2026, 11, 14, 1));
    db = openLocalLedger(dir.path, RunMode.live, clock: () => clock.now);
    store = SqliteConfigVersionStore(db, clock: clock);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  int rows() =>
      db.select('SELECT COUNT(*) AS n FROM config_versions').first['n'] as int;

  test('🔴 등재 = 지문 · 정규 JSON · 승인 0(등재는 승인이 아니다)', () {
    final P0sOpsConfig c = _config();
    final String h = store.register(c.content());
    expect(h, c.configHash);
    final Row r = db.select(
      'SELECT * FROM config_versions WHERE config_hash = ?',
      <Object?>[h],
    ).single;
    expect(r['content'], canonicalConfigJson(c.content()));
    expect(r['approved'], 0);
    expect(r['created_at'], '2026-11-14T01:00:00.000Z');
    expect(store.approvalOf(h), 0);
    expect(
      SqliteRuleChangeStore(
        db,
        clock: clock,
        trusted: const _NoTrusted(),
      ).approvedConfigHash(),
      kNoApprovedConfig,
    );
  });

  test('같은 내용 다시 등재 = 그대로(행 1 · 처음 시각)', () {
    final String h = store.register(_config().content());
    clock.now = clock.now.add(const Duration(days: 1));
    expect(store.register(_config().content()), h);
    expect(rows(), 1);
    expect(
      db.select('SELECT created_at FROM config_versions').single['created_at'],
      '2026-11-14T01:00:00.000Z',
    );
  });

  test('🔴 같은 지문에 다른 내용 = StateError(덮어쓰지 않는다)', () {
    final String h = store.register(_config().content());
    db.execute(
      "UPDATE config_versions SET content = '{}' WHERE config_hash = ?",
      <Object?>[h],
    );
    expect(() => store.register(_config().content()), throwsStateError);
    expect(
      db.select('SELECT content FROM config_versions').single['content'],
      '{}',
    );
  });

  test('승인 읽기 = 행 없음 null · 승인 뒤 1 → SAF-405 기동 판정 입력', () {
    final String h = store.register(_config().content());
    expect(store.approvalOf('0000000000000000'), isNull);
    expect(
      startupConfigGate(
        runMode: RunMode.live,
        approved: store.approvalOf(h),
      ).start,
      false,
    );
    db.execute(
      'UPDATE config_versions SET approved = 1 WHERE config_hash = ?',
      <Object?>[h],
    );
    expect(store.approvalOf(h), 1);
    expect(
      startupConfigGate(
        runMode: RunMode.live,
        approved: store.approvalOf(h),
      ).start,
      true,
    );
  });

  test('다른 사람 값 = 다른 지문 · 행 둘', () {
    store.register(_config().content());
    store.register(_config(a: '999991').content());
    expect(rows(), 2);
  });
}

class _NoTrusted implements TrustedClock {
  const _NoTrusted();

  @override
  DateTime? trustedNowUtc() => null;
}
