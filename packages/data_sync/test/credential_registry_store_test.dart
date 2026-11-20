// 🆕 E11q-c1b — 키 세트 검증 기록(`credential_registry` · 설계 13 §8 R196 · 미결 207 ⓑ).
//
// 🔴 값 0(별칭 · 접두 꼴 검사) · 통과 = OK · 거절 = INVALID · 같은 별칭 = 고쳐 쓴다 · 시각 = 기기 · 시차 없는 시각 = 오류 ·
//    simToAuto 커밋 옮김 = 실전 세트 행만(모의 세트 0) · 실전 파일에 같은 별칭이 있으면 모의 파일 행이 이긴다.

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show CredentialHealthCodes, CredentialHealthRecord;
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

void main() {
  late Directory dir;
  late Database sim;
  late Database live;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_creg_');
    final DateTime t0 = DateTime.utc(2026, 12, 21, 1);
    clock = _Clock(t0);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => t0);
    live = openLocalLedger(dir.path, RunMode.live, clock: () => t0);
  });

  tearDown(() {
    sim.close();
    live.close();
    dir.deleteSync(recursive: true);
  });

  SqliteCredentialRegistry reg([Database? db]) =>
      SqliteCredentialRegistry(db ?? sim, clock: clock);

  void ok(String alias, String kind, String ref, {bool passed = true}) =>
      reg().recordVerification(
        alias: alias,
        kind: kind,
        keystoreRef: ref,
        passed: passed,
      );

  test('통과 = OK · 거절 = INVALID · 같은 별칭 = 고쳐 쓴다(시각 = 기기) · 별칭 차례', () {
    ok('kis_live', CredentialKindCodes.kisLive, 'kis.live', passed: false);
    ok('kis_isa', CredentialKindCodes.kisIsa, 'kis.isa');
    clock.at = DateTime.utc(2026, 12, 22, 2);
    ok('kis_live', CredentialKindCodes.kisLive, 'kis.live');
    final List<CredentialHealthRecord> rs = reg().records();
    expect(
      <String>[for (final CredentialHealthRecord r in rs) r.kind],
      <String>[CredentialKindCodes.kisIsa, CredentialKindCodes.kisLive],
    );
    expect(
      <String>[for (final CredentialHealthRecord r in rs) r.health],
      <String>[CredentialHealthCodes.ok, CredentialHealthCodes.ok],
    );
    expect(rs.last.lastVerifiedAtUtc, DateTime.utc(2026, 12, 22, 2));
    expect(rs.first.lastVerifiedAtUtc, DateTime.utc(2026, 12, 21, 1));
    expect(
      sim
          .select(
            'SELECT keystore_ref, usage, expires_at FROM credential_registry WHERE alias = ?',
            <Object?>['kis_live'],
          )
          .single
          .values,
      <Object?>['kis.live', 'FULL', null],
    );
    expect(credentialRecordsOf(sim), hasLength(2));
    expect(credentialRecordsOf(live), isEmpty);
    expect(SqliteCredentialRegistry.watchedTables, <String>{
      'credential_registry',
    });
  });

  test('🔴 값 0 — 별칭 · 접두 · 세트 꼴이 아니면 ArgumentError(값을 글에 싣지 않는다)', () {
    for (final (String a, String k, String r) in <(String, String, String)>[
      ('PS1234567890', CredentialKindCodes.kisLive, 'kis.live'),
      ('kis_live', CredentialKindCodes.kisLive, '12345678-01'),
      ('kis_live', 'kis_live', 'kis.live'),
      ('', CredentialKindCodes.kisLive, 'kis.live'),
    ]) {
      expect(
        () => reg().recordVerification(
          alias: a,
          kind: k,
          keystoreRef: r,
          passed: true,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.invalidValue,
            'invalidValue',
            '<가림>',
          ),
        ),
      );
    }
    expect(reg().records(), isEmpty);
  });

  test('시각에 시차가 없으면 FormatException', () {
    sim.execute(
      'INSERT INTO credential_registry (alias, kind, keystore_ref, last_verified_at, health) '
      "VALUES ('kis_live', 'KIS_LIVE', 'kis.live', '2026-12-21T01:00:00', 'OK')",
    );
    expect(() => reg().records(), throwsFormatException);
  });

  test('🔴 커밋 옮김 = 실전 세트 행만 · 실전 파일에 같은 별칭이 있으면 모의 파일 행이 이긴다', () {
    ok('kis_live', CredentialKindCodes.kisLive, 'kis.live');
    ok('kis_isa', CredentialKindCodes.kisIsa, 'kis.isa', passed: false);
    ok('kis_paper', CredentialKindCodes.kisPaper, 'kis.paper');
    final SimToAutoCarry carry = readSimToAutoCarry(sim);
    expect(
      <String?>[
        for (final SimToAutoCarriedRow r in carry.of('credential_registry'))
          r.values['alias'] as String?,
      ],
      <String>['kis_isa', 'kis_live'],
    );
    expect(SimToAutoCarry.tables.last, 'credential_registry');
    // 실전 파일에 낡은 행(거절)이 이미 있다.
    reg(live).recordVerification(
      alias: 'kis_live',
      kind: CredentialKindCodes.kisLive,
      keystoreRef: 'kis.live',
      passed: false,
    );
    live.execute('BEGIN IMMEDIATE');
    writeSimToAutoCarryInTransaction(live, carry);
    live.execute('COMMIT');
    final List<CredentialHealthRecord> rs = credentialRecordsOf(live);
    expect(
      <String>[
        for (final CredentialHealthRecord r in rs) '${r.kind}:${r.health}',
      ],
      <String>[
        '${CredentialKindCodes.kisIsa}:${CredentialHealthCodes.invalid}',
        '${CredentialKindCodes.kisLive}:${CredentialHealthCodes.ok}',
      ],
    );
  });
}
