// 로컬 원장 두 파일 · SIM 판 파생 — 01 §6-0 · §9-2 · 설계 13 §8 R19 E9-2 · R20 Q1.
//
// 🔵 `ddl/*.sql` 전체의 두 파일 대조는 C-15 몫이다. 여기서는 `ledgerDdlFor` 의 규칙
//    (태그 = 코드 줄 끝 · LIVE 식 정확히 1번 · 모르는 종류 거부)과 `LedgerFile` 을 본다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('LedgerFile.of — SIM 계열은 ledger_sim.sqlite · LIVE 는 ledger.sqlite', () {
    expect(LedgerFile.of(RunMode.live), LedgerFile.live);
    expect(LedgerFile.of(RunMode.simInternal), LedgerFile.sim);
    expect(LedgerFile.of(RunMode.simBroker), LedgerFile.sim);
    expect(LedgerFile.live.fileName, 'ledger.sqlite');
    expect(LedgerFile.sim.fileName, 'ledger_sim.sqlite');
  });

  test('application_id — 두 파일이 다르고 SQLite 의 32비트 부호 있는 정수 안이다', () {
    expect(LedgerFile.live.applicationId, isNot(LedgerFile.sim.applicationId));
    for (final LedgerFile f in LedgerFile.values) {
      expect(f.applicationId, inInclusiveRange(1, 0x7FFFFFFF));
    }
  });

  test('LIVE 판은 입력 그대로 · SIM 판은 태그 줄만 바뀐다', () {
    const String sql =
        'CREATE TABLE t (\n'
        "    mode TEXT NOT NULL CHECK (mode = 'LIVE'),   -- @sim ledger\n"
        "    cal  TEXT NOT NULL CHECK (mode = 'LIVE'),   -- @sim calendar\n"
        "    note TEXT CHECK (note = 'LIVE')\n"
        ');';
    expect(ledgerDdlFor(LedgerFile.live, sql), sql);
    final List<String> sim = ledgerDdlFor(LedgerFile.sim, sql).split('\n');
    expect(sim[1], contains("CHECK (mode IN ('SIM_INTERNAL','SIM_BROKER'))"));
    expect(sim[2], contains("CHECK (mode = 'SIM')"));
    expect(sim[3], "    note TEXT CHECK (note = 'LIVE')");
  });

  test('intent-operating-mode — SIM 판에서 simBroker × advisory 를 막는 식이 붙는다', () {
    const String line =
        "  CHECK (operating_mode IN ('AUTO_TRADE','ADVISORY'));   -- @sim intent-operating-mode";
    expect(
      ledgerDdlFor(LedgerFile.sim, line),
      contains(
        "CHECK (operating_mode IN ('AUTO_TRADE','ADVISORY') AND "
        "(operating_mode = 'AUTO_TRADE' OR mode = 'SIM_INTERNAL'))",
      ),
    );
  });

  test('설명 주석 속 @sim 낱말은 태그가 아니다', () {
    const String sql =
        '-- 🔴 `-- @sim ledger` 가 붙은 줄은 바뀐다\n'
        '--   · `@sim advice` — 안내 표 -- @sim advice\n'
        "x CHECK (mode = 'LIVE')";
    expect(ledgerDdlFor(LedgerFile.sim, sql), sql);
  });

  test('모르는 종류 · LIVE 식이 없거나 두 번인 태그 줄은 FormatException', () {
    for (final String bad in <String>[
      "a CHECK (mode = 'LIVE')   -- @sim nope",
      "a CHECK (mode IN ('LIVE'))   -- @sim ledger",
      "a CHECK (mode = 'LIVE') OR (mode = 'LIVE')   -- @sim ledger",
    ]) {
      expect(
        () => ledgerDdlFor(LedgerFile.sim, bad),
        throwsA(isA<FormatException>()),
        reason: bad,
      );
      // LIVE 판도 같은 규칙으로 검사한다 — 잘못된 태그를 한쪽 판에서만 잡지 않는다.
      expect(
        () => ledgerDdlFor(LedgerFile.live, bad),
        throwsA(isA<FormatException>()),
        reason: bad,
      );
    }
  });
}
