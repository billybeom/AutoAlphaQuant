// E11p3b-3 — 첫 회차 하한(모드 시작) · 시드 적재 여부 · 마지막 브로커 대사(설계 13 §8 R93).

import 'dart:io';

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

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('fgsa_');
    clock = _Clock(DateTime.utc(2026, 11, 16, 1));
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => clock.now);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  group('모드 시작 시각', () {
    SqliteModeStore store() =>
        SqliteModeStore(db, LedgerFile.sim, clock: clock);

    String? rec(ModeAxis axis, ExecPolicy exec) => store().record(
      axis: axis,
      runMode: RunMode.simInternal,
      execPolicy: exec,
      operatingMode: OperatingMode.autoTrade,
      handoverSessionValid: false,
      decisionId: 'D-${axis.wire}',
    );

    test('모드 행 없음 = null', () {
      expect(modeStartedAtUtc(db), isNull);
    });

    test('🔴 = 가장 이른 RUN_MODE 커밋 — 집행 정책 전이 · CLOSE 는 보지 않는다', () {
      // 시험 조합 = sim × 자동 매매 × 집행(허용 칸) — 축만 바꿔 쓴다.
      expect(rec(ModeAxis.runMode, ExecPolicy.execute), isNull);
      final DateTime first = clock.now;
      clock.now = clock.now.add(const Duration(days: 3));
      expect(rec(ModeAxis.execPolicy, ExecPolicy.execute), isNull);
      clock.now = clock.now.add(const Duration(days: 3));
      // 같은 파일의 두 번째 RUN_MODE 행 — 시작은 여전히 첫 행이다.
      expect(rec(ModeAxis.runMode, ExecPolicy.execute), isNull);
      clock.now = clock.now.add(const Duration(days: 3));
      store().close(decisionId: 'D-CLOSE');
      expect(modeStartedAtUtc(db), first);
    });
  });

  group('시드 적재 여부', () {
    test('🔴 빈 원장 = false · 적재 뒤 = true(적재 판정과 같다)', () {
      expect(seedBundleImported(db), false);
      final SeedImportReport r = importSeedBundle(db, <String, List<int>>{
        for (final SeedFile f in kSeedFiles)
          f.fileName: File('assets/seed/${f.fileName}').readAsBytesSync(),
      }, importedAt: '2026-11-16T01:00:00.000Z');
      expect(r.alreadyImported, false);
      expect(seedBundleImported(db), true);
      expect(
        importSeedBundle(
          db,
          const <String, List<int>>{},
          importedAt: '2026-11-16T02:00:00.000Z',
        ).alreadyImported,
        true,
      );
    });
  });

  group('마지막 브로커 대사', () {
    void recon(String id, String at) => db.execute(
      'INSERT INTO reconciliation_log (recon_id, run_at, matched, action_taken) VALUES (?, ?, 1, ?)',
      <Object?>[id, at, 'OK'],
    );

    test('없음 = null', () {
      expect(lastBrokerReconUtc(db), isNull);
    });

    test('🔴 rc- 행의 마지막 · 해제 행(rc-clear-) · 다른 대조는 보지 않는다', () {
      recon('rc-2026-11-13', '2026-11-13T00:05:00Z');
      recon('rc-2026-11-16', '2026-11-16T00:05:00Z');
      recon('rc-clear-2026-11-16', '2026-11-16T03:00:00Z');
      recon('int-2026-11-16', '2026-11-16T04:00:00Z');
      expect(lastBrokerReconUtc(db), DateTime.utc(2026, 11, 16, 0, 5));
    });
  });
}
