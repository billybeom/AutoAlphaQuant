// E13h1 — 알림 등급 · 묶음 키 · P0 ack 사다리 · 확인 판정(설계 13 §8 R68 H2~H5).
//
// 🔵 잡는 것: ① 등급 표 = 04 §5-3 표 그대로(P0 7 · P1 12 · P2 5) + 계약 잠정 1 + 제안 6(🆕 E14b 재개 3) · 계약 코드 전부 덮음
//    ② 모르는 코드 = 오류 ③ 사다리 = P0 ∧ 손절 안내 아님 ④ 묶음 키 · id = 한국 날(15:00Z 경계)
//    ⑤ 사다리 경계(15분 · 60분) · 건너뛰기 0 · 확인 = 멈춤 ⑥ 확인 판정.
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AlertCodes, AlertLevel;
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 11, 5, 1);

List<int> _due(
  Duration elapsed, {
  Set<int> done = const <int>{},
  bool acked = false,
}) => dueEscalationSteps(
  raisedAtUtc: _t0,
  nowUtc: _t0.add(elapsed),
  acked: acked,
  done: done,
);

void main() {
  test(
    '🔴 등급 표 = 04 §5-3 그대로 + 계약 잠정 1 + 제안 6 + 🆕 v1.27 등재 5(파생 FORK 1 · E3d 4)',
    () {
      List<String> of(AlertLevel l) =>
          (kAlertLevels.entries
              .where((MapEntry<String, AlertLevel> e) => e.value == l)
              .map((MapEntry<String, AlertLevel> e) => e.key)
              .toList()
            ..sort());
      expect(of(AlertLevel.p0), <String>[
        'ADVICE_EXIT_URGENT',
        'ADVICE_REVOKED',
        'ADVICE_SUPPRESSED',
        'BREAKER_STOPPED',
        'BROKER_AUTH_FAILED',
        'DERIVED_FORK',
        'LEDGER_INTEGRITY_BROKEN',
        'MAINTENANCE_RESUME_FAILED',
        'ORDER_OUTCOME_UNKNOWN',
        'RECON_MISMATCH',
        'RESUME_TRADING_HALTED',
      ]);
      expect(of(AlertLevel.p1), <String>[
        'ADVICE_DUE_SOON',
        'ADVICE_ISSUED',
        'BACKUP_STALE',
        'DATA_SOURCE_DOWN',
        'DEFENSIVE_FLOOR_BREACHED',
        'FINANCIAL_INCOME_CAP_EXCEEDED',
        'GOLD_SHARE_HIGH',
        'HANDOVER_COMMITTED',
        'HANDOVER_COOLING_ACTIVE',
        'LEDGER_TRUST_DOWNGRADE',
        'MAINTENANCE_WINDOW_OVERDUE',
        'MANUAL_FILL_REJECTED',
        'ORDER_REJECTED',
        'READ_MODEL_PUSH_REJECTED',
        'READ_MODEL_PUSH_SECRET_BLOCKED',
        'REBALANCE_D1',
        'RESUME_COMPLETED',
        'STALE_ORDERS_HELD',
        'STOPPED_RELEASE_ELIGIBLE',
        'WATCHDOG_LATE',
      ]);
      expect(of(AlertLevel.p2), <String>[
        'ADVICE_EXPIRED',
        'CONTRIBUTION_CHANGED',
        'DEPOSIT_REMINDER',
        'KRW_LIQUIDITY_LOW',
        'REBALANCE_D7',
        'RESUME_DATA_GAP',
        'SELF_AUDIT_DUE',
      ]);
      // 계약 코드 전부 등급이 있다 · 🆕 v1.18(앱 01 §27 · K-z) — 제안 6 = 계약 등재 → 표 밖 0.
      // 🆕 E16f3a — 등재 대기 제안 1 = `DERIVED_FORK`(R130 L6) · E3d 제안 4(R177) — 🆕 계약 v1.27(01 §36 K188) 등재 → 표 밖 0.
      // 🆕 계약 v1.39(앱 01 §48 K344 · K348) — 계약 먼저 등재한 묶음 2(킬스위치 확인 · push) = 엔진 등급 · 글자 대기(미결 243).
      // 🆕 미결 243 ⓒ(R273) — push 2 = 등급 · 글자 실림 → 예외 = 킬스위치 확인 1만(B-03 · 실전 커밋 창 전).
      expect(
        AlertCodes.values
            .difference(<String>{...AlertCodes.killSwitch})
            .every(kAlertLevels.containsKey),
        isTrue,
      );
      expect(AlertCodes.readModelPush.every(kAlertLevels.containsKey), isTrue);
      expect(
        kAlertLevels.containsKey(AlertCodes.killSwitchAckMismatch),
        isFalse,
      );
      expect(
        kAlertLevels.keys.where((String c) => !AlertCodes.values.contains(c)),
        isEmpty,
      );
      // 엔진 상수 = 계약 상수 글자(K190 — 엔진은 제 상수를 그대로 둔다).
      expect(kDerivedForkAlertCode, AlertCodes.derivedFork);
      expect(kDefensiveFloorAlertCode, AlertCodes.defensiveFloorBreached);
      expect(kGoldShareAlertCode, AlertCodes.goldShareHigh);
      expect(kFinancialIncomeAlertCode, AlertCodes.financialIncomeCapExceeded);
      expect(kKrwLiquidityAlertCode, AlertCodes.krwLiquidityLow);
    },
  );

  test('🔴 모르는 코드 = 오류(등급을 지어내지 않는다)', () {
    expect(alertLevelOf('ORDER_REJECTED'), AlertLevel.p1);
    expect(() => alertLevelOf('SOMETHING_NEW'), throwsArgumentError);
    expect(() => alertHasLadder('SOMETHING_NEW'), throwsArgumentError);
  });

  test('사다리 = P0 ∧ 손절 안내 아님', () {
    expect(alertHasLadder('ORDER_OUTCOME_UNKNOWN'), isTrue);
    expect(alertHasLadder('BREAKER_STOPPED'), isTrue);
    expect(alertHasLadder('RESUME_TRADING_HALTED'), isTrue);
    expect(alertHasLadder('RESUME_COMPLETED'), isFalse);
    expect(alertHasLadder('ADVICE_EXIT_URGENT'), isFalse);
    expect(alertHasLadder('ORDER_REJECTED'), isFalse);
    expect(alertHasLadder('ADVICE_EXPIRED'), isFalse);
  });

  test('묶음 키 · id = 한국 날 · 낸 곳 · 코드(15:00Z 경계)', () {
    final DateTime before = DateTime.utc(2026, 11, 5, 14, 59);
    final DateTime after = DateTime.utc(2026, 11, 5, 15);
    expect(
      alertDedupeKey(
        code: 'WATCHDOG_LATE',
        source: 'kr_order',
        raisedAtUtc: before,
      ),
      '2026-11-05|kr_order|WATCHDOG_LATE',
    );
    expect(
      alertDedupeKey(
        code: 'WATCHDOG_LATE',
        source: 'kr_order',
        raisedAtUtc: after,
      ),
      '2026-11-06|kr_order|WATCHDOG_LATE',
    );
    expect(
      alertIdOf(code: 'WATCHDOG_LATE', source: 'kr_order', raisedAtUtc: before),
      'AL-2026-11-05-kr_order-WATCHDOG_LATE',
    );
    expect(
      alertIdOf(code: 'WATCHDOG_LATE', source: 'kr_order', raisedAtUtc: after),
      'AL-2026-11-06-kr_order-WATCHDOG_LATE',
    );
  });

  test('🔴 사다리 경계 · 건너뛰기 0 · 확인 = 멈춤', () {
    const Duration ms = Duration(milliseconds: 1);
    expect(_due(const Duration(minutes: 15) - ms), isEmpty);
    expect(_due(const Duration(minutes: 15)), <int>[1]);
    expect(_due(const Duration(minutes: 60) - ms), <int>[1]);
    expect(_due(const Duration(minutes: 60)), <int>[1, 2]);
    expect(_due(const Duration(hours: 9)), <int>[1, 2]);
    expect(_due(const Duration(minutes: 60), done: <int>{1}), <int>[2]);
    expect(_due(const Duration(minutes: 60), done: <int>{1, 2}), isEmpty);
    expect(_due(const Duration(minutes: 30), done: <int>{1}), isEmpty);
    expect(_due(const Duration(hours: 9), acked: true), isEmpty);
    // 시계가 뒤로 가도(음수 경과) 오르지 않는다.
    expect(_due(const Duration(minutes: -5)), isEmpty);
    expect(kAckLadder, <Duration>[
      const Duration(minutes: 15),
      const Duration(minutes: 60),
    ]);
  });

  test('확인 판정 = 사다리가 걸린 알림만 · 아니면 INPUT_INVALID', () {
    expect(alertAckRejectCode(code: 'RECON_MISMATCH'), isNull);
    for (final String? c in <String?>[
      null,
      'ADVICE_EXIT_URGENT',
      'ORDER_REJECTED',
      'REBALANCE_D7',
    ]) {
      expect(alertAckRejectCode(code: c), 'INPUT_INVALID', reason: c);
    }
  });
}
