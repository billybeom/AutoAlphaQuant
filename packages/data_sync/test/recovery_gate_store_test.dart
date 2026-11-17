// E16h2 — X1-5 LIVE 재개 게이트 원천(설계 13 §8 R138 Q2~Q9).
//
// 🔵 잡는 것: ① 복구 없음 · 재구성 전 = 붙잡음 코드(판정 · 골든 · 승인 다) ② 골든 = 아직 · 실패 · 통과(DONE 이 이긴다) ·
//    이미 통과 = 포트 0 · 신뢰 시각 모름 = 포트 0 · 포트가 던지면 쓰기 0 ③ 관찰 = 재구성 끝 뒤 연속 무결일(그 전 배치 · 대사 제외 ·
//    불일치 날 끊김) · 갈래별 필요 일수 ④ 승인 = 그 차례일 때만 · 이미 = 쓰기 0 · 결정 필수 · 생체는 체크리스트 뒤 → 통과.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
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

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

/// 한국 시각.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

final MigrationObservationConfig _config = MigrationObservationConfig(
  planTradingDays: 2,
  emergencyTradingDays: 3,
);

void main() {
  late Directory dir;
  late Database db;
  late _Trusted trusted;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_gate_');
    db = openLocalLedger(
      dir.path,
      RunMode.live,
      clock: () => _k('2026-11-16', 10),
    );
    trusted = _Trusted(_k('2026-11-16', 10));
    clock = _Clock(_k('2026-11-16', 11));
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteRecoveryGate gate() => SqliteRecoveryGate(
    db,
    deviceId: 'dev-new',
    trusted: trusted,
    clock: clock,
    kr: _kr,
  );

  void restore({MigrationKind kind = MigrationKind.emergency}) => expect(
    SqliteRecoveryJournal(db, deviceId: 'dev-new', trusted: trusted)
        .start(
          kind: kind,
          operatingMode: OperatingMode.autoTrade,
          decisionId: 'dec-x1',
          operatorEpoch: 1,
          manifest: BackupManifest(
            sha256: 'a' * 64,
            chainHash: 'b' * 64,
            authoredDate: '2026-11-16',
            schemaVersion: 1,
            hashFormatVersion: 1,
            operatorEpoch: 0,
            writerDeviceId: 'dev-old',
          ),
        )
        .rejectCode,
    isNull,
  );

  /// 재구성 끝 = 11-16 10:30 한국(빈 창 · 계좌 0).
  Future<void> rebuild() async {
    trusted.at = _k('2026-11-16', 10, 30);
    final GapRebuildReport r =
        await SqliteGapRebuild(
          db,
          deviceId: 'dev-new',
          trusted: trusted,
          kr: _kr,
          ledger: SqliteOrderLedger(
            db,
            mode: RunMode.live,
            clock: clock,
            kr: _kr,
          ),
        ).run(
          brokers: const <String, AccountBroker>{},
          accountByStrategy: const <String, String>{},
          configHash: 'cfg',
          operatingMode: OperatingMode.autoTrade,
          costs: const FillCostRates(commissionRate: 0, sellTaxRate: 0),
        );
    expect(r.done, isTrue);
  }

  void batch(String day, {int h = 9, int m = 10, bool ok = true}) =>
      SqliteJobRunLog(db).record(
        JobRunEntry(
          rid: 'kr-$day-$h$m',
          checkName: kLiveObservationBatchCheck,
          sessionDay: TradeDate(day),
          startedAtUtc: _k(day, h, m),
          finishedAtUtc: _k(day, h, m + 1),
          status: ok ? JobRunStatus.success : JobRunStatus.failed,
        ),
      );

  void recon(String day, {int h = 15, int m = 50, bool matched = true}) =>
      db.execute(
        'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
        "VALUES (?, ?, ?, '[]', 'NONE')",
        <Object?>[
          'rc-$day-$h$m',
          _k(day, h, m).toIso8601String(),
          matched ? 1 : 0,
        ],
      );

  void clean(String day) {
    batch(day);
    recon(day);
  }

  RecoveryGateView view() => gate().view(config: _config);

  String? code() => view().gate?.code ?? view().holdCode;

  int steps(String step) =>
      db.select(
            'SELECT COUNT(*) AS n FROM migration_step WHERE step = ?',
            <Object?>[step],
          ).single['n']
          as int;

  group('붙잡음 — 복구 전 · 재구성 전', () {
    test('복구 없음 = X1_NOT_RESTORED(판정 · 골든 · 승인)', () async {
      expect(view().holdCode, 'X1_NOT_RESTORED');
      expect(view().gate, isNull);
      expect(gate().factsOf(), isNull);
      final FakeGoldenSelfTest port = FakeGoldenSelfTest(<Object>[true]);
      final ({bool? passed, String? rejectCode}) g = await gate()
          .runGoldenSelfTest(port);
      expect(g.rejectCode, 'X1_NOT_RESTORED');
      expect(g.passed, isNull);
      expect(port.runs, 0);
      expect(
        gate().confirmChecklist(decisionId: 'd', config: _config),
        'X1_NOT_RESTORED',
      );
    });

    test('재구성 전 = X1_RECOVERY_IN_PROGRESS', () async {
      restore();
      expect(view().holdCode, 'X1_RECOVERY_IN_PROGRESS');
      expect(gate().factsOf(), isNull);
      final FakeGoldenSelfTest port = FakeGoldenSelfTest(<Object>[true]);
      expect(
        (await gate().runGoldenSelfTest(port)).rejectCode,
        'X1_RECOVERY_IN_PROGRESS',
      );
      expect(port.runs, 0);
      expect(
        gate().confirmBiometric(decisionId: 'd', config: _config),
        'X1_RECOVERY_IN_PROGRESS',
      );
    });
  });

  group('골든 자가검사', () {
    setUp(() async {
      restore();
      await rebuild();
    });

    test('아직 = X1_GOLDEN_NOT_RUN · 사실 = 아직 · 관찰 0 · 승인 0', () {
      expect(view().gate!.state, MigrationGateState.blocked);
      expect(code(), 'X1_GOLDEN_NOT_RUN');
      final MigrationGateFacts f = gate().factsOf()!;
      expect(f.goldenPassed, isNull);
      expect(f.observedTradingDays, 0);
      expect(f.reconMismatches, 0);
      expect(f.unknownOrders, 0);
      expect(f.openOrders, 0);
      expect(f.checklistConfirmed, isFalse);
      expect(f.biometricConfirmed, isFalse);
    });

    test(
      '실패 = FAILED · X1_GOLDEN_FAILED → 다시 통과 = DONE 이 이긴다 → 이미 통과 = 포트 0',
      () async {
        final FakeGoldenSelfTest port = FakeGoldenSelfTest(<Object>[
          false,
          true,
        ]);
        final ({bool? passed, String? rejectCode}) a = await gate()
            .runGoldenSelfTest(port);
        expect(a.passed, isFalse);
        expect(a.rejectCode, isNull);
        expect(code(), 'X1_GOLDEN_FAILED');
        final Row failed = db
            .select(
              "SELECT * FROM migration_step WHERE step = 'GOLDEN_SELF_TEST'",
            )
            .single;
        expect(failed['state'], 'FAILED');
        expect(failed['at'], _k('2026-11-16', 10, 30).toIso8601String());
        final ({bool? passed, String? rejectCode}) b = await gate()
            .runGoldenSelfTest(port);
        expect(b.passed, isTrue);
        expect(gate().factsOf()!.goldenPassed, isTrue);
        expect(code(), 'X1_OBSERVING');
        expect(steps('GOLDEN_SELF_TEST'), 2);
        final ({bool? passed, String? rejectCode}) c = await gate()
            .runGoldenSelfTest(port);
        expect(c.passed, isTrue);
        expect(port.runs, 2);
      },
    );

    test('신뢰 시각 모름 = 거부 · 포트 0 · 포트가 던지면 쓰기 0 · 그대로 던진다', () async {
      trusted.at = null;
      final FakeGoldenSelfTest port = FakeGoldenSelfTest(<Object>[true]);
      expect(
        (await gate().runGoldenSelfTest(port)).rejectCode,
        'TRUSTED_TIME_UNKNOWN',
      );
      expect(port.runs, 0);
      trusted.at = _k('2026-11-16', 11);
      final FakeGoldenSelfTest broken = FakeGoldenSelfTest(<Object>[
        const FormatException('기기 골든 실행기 없음'),
      ]);
      await expectLater(
        gate().runGoldenSelfTest(broken),
        throwsA(isA<FormatException>()),
      );
      expect(steps('GOLDEN_SELF_TEST'), 0);
      expect(code(), 'X1_GOLDEN_NOT_RUN');
    });
  });

  group('관찰 · 막는 사실', () {
    setUp(() async {
      restore();
      await rebuild();
      await gate().runGoldenSelfTest(FakeGoldenSelfTest(<Object>[true]));
    });

    test('대사 · UNKNOWN · 미체결 = 차례대로 막는다', () {
      db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
        <Object?>[FlagIds.reconMismatch, 'x', 'r'],
      );
      expect(code(), 'X1_RECON_NOT_ZERO');
      db.execute(
        "UPDATE trading_block SET cleared_at = 'y' WHERE flag_id = ?",
        <Object?>[FlagIds.reconMismatch],
      );
      void intent(String id, String status) => db.execute(
        'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
        "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
        "'2026-11-16', 'KR', 'pension', 'P0S_B', 'B@2026-11-16', '133690', 'BUY', 'LIMIT', 1, ?, 'c', 'x', 'LIVE')",
        <Object?>[id, 'k-$id', status],
      );
      intent('u', 'UNKNOWN');
      expect(code(), 'X1_UNKNOWN_ORDERS_REMAIN');
      db.execute("UPDATE order_intents SET status = 'EXPIRED'");
      intent('o', 'SUBMITTED');
      expect(code(), 'X1_OPEN_ORDERS_REMAIN');
    });

    test('🔴 관찰 = 재구성 끝 뒤 연속 무결일 · 그 전 배치 · 대사 제외 · 불일치 날 끊김 · 비상 3일', () {
      // 🔴 복원(10:00) 뒤 · 재구성(10:30) 전 배치 · 대사 = 세지 않는다(관찰 시작 = 재구성 끝).
      batch('2026-11-16', h: 10, m: 10);
      recon('2026-11-16', h: 10, m: 20);
      clock.at = _k('2026-11-16', 16);
      expect(gate().factsOf()!.observedTradingDays, 0);
      clean('2026-11-17');
      batch('2026-11-18');
      recon('2026-11-18', matched: false);
      clean('2026-11-19');
      clock.at = _k('2026-11-19', 16);
      expect(gate().factsOf()!.observedTradingDays, 1);
      clean('2026-11-20');
      clean('2026-11-23');
      clock.at = _k('2026-11-23', 16);
      expect(gate().factsOf()!.observedTradingDays, 3);
      expect(code(), 'X1_CHECKLIST_PENDING');
      final MigrationGateVerdict g = view().gate!;
      expect(g.state, MigrationGateState.awaitingApproval);
      expect(g.observedTradingDays, 3);
      expect(g.requiredTradingDays, 3);
    });
  });

  group('승인 2단계', () {
    setUp(() async {
      restore(kind: MigrationKind.plan);
      await rebuild();
      await gate().runGoldenSelfTest(FakeGoldenSelfTest(<Object>[true]));
    });

    test('🔴 차례일 때만 적는다 — 관찰 중 · 생체 먼저 = 그 판정 코드 · 쓰기 0', () {
      clean('2026-11-17');
      clock.at = _k('2026-11-17', 16);
      expect(code(), 'X1_OBSERVING');
      expect(
        gate().confirmChecklist(decisionId: 'd-c', config: _config),
        'X1_OBSERVING',
      );
      clean('2026-11-18');
      clock.at = _k('2026-11-18', 16);
      expect(
        gate().confirmBiometric(decisionId: 'd-b', config: _config),
        'X1_CHECKLIST_PENDING',
      );
      expect(steps('CHECKLIST_CONFIRMED'), 0);
      expect(steps('BIOMETRIC_CONFIRMED'), 0);
    });

    test(
      '체크리스트 → 생체 → PASSED · 이미 = null · 쓰기 0 · 결정 = detail · 시각 = 신뢰 시각',
      () {
        clean('2026-11-17');
        clean('2026-11-18');
        clock.at = _k('2026-11-18', 16);
        trusted.at = _k('2026-11-18', 17);
        expect(
          gate().confirmChecklist(decisionId: 'd-c', config: _config),
          isNull,
        );
        final Row c = db
            .select(
              "SELECT * FROM migration_step WHERE step = 'CHECKLIST_CONFIRMED'",
            )
            .single;
        expect(c['state'], 'DONE');
        expect(jsonDecode(c['detail_json'] as String), <String, Object?>{
          'decision_id': 'd-c',
        });
        expect(c['at'], _k('2026-11-18', 17).toIso8601String());
        expect(code(), 'X1_BIOMETRIC_PENDING');
        expect(
          gate().confirmChecklist(decisionId: 'd-c2', config: _config),
          isNull,
        );
        expect(steps('CHECKLIST_CONFIRMED'), 1);
        expect(
          gate().confirmBiometric(decisionId: 'd-b', config: _config),
          isNull,
        );
        final MigrationGateVerdict g = view().gate!;
        expect(g.state, MigrationGateState.passed);
        expect(g.code, isNull);
        expect(gate().factsOf()!.biometricConfirmed, isTrue);
        expect(
          gate().confirmBiometric(decisionId: 'd-b2', config: _config),
          isNull,
        );
        expect(steps('BIOMETRIC_CONFIRMED'), 1);
      },
    );

    test('막힘 중 승인 = 막는 코드 · 쓰기 0', () {
      clean('2026-11-17');
      clean('2026-11-18');
      clock.at = _k('2026-11-18', 16);
      db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
        <Object?>[FlagIds.reconMismatch, 'x', 'r'],
      );
      expect(
        gate().confirmChecklist(decisionId: 'd-c', config: _config),
        'X1_RECON_NOT_ZERO',
      );
      expect(steps('CHECKLIST_CONFIRMED'), 0);
    });

    test('결정 비움 = ArgumentError · 신뢰 시각 모름 = 거부', () {
      expect(
        () => gate().confirmChecklist(decisionId: ' ', config: _config),
        throwsArgumentError,
      );
      trusted.at = null;
      expect(
        gate().confirmChecklist(decisionId: 'd', config: _config),
        'TRUSTED_TIME_UNKNOWN',
      );
    });
  });
}
