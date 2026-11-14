// 🆕 E15f2 — 전환 세션 순수 몫(48h · id · 열기 사전 판정 · 냉각 알림 · 문구 · 설계 13 §8 R96 AF2~AF12).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final LiveObservationConfig _two = LiveObservationConfig(
  requiredTradingDays: 2,
);

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

const SimTrialReport _done = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: true,
  needsWarning: false,
  counters: SimTrialCounters.zero,
  headline: '체험 5항목을 모두 채웠습니다.',
);
const SimTrialReport _warn = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: true,
  needsWarning: true,
  counters: SimTrialCounters.zero,
  headline: '경고 후 진행',
);
const SimTrialReport _open = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: false,
  needsWarning: true,
  counters: SimTrialCounters.zero,
  headline: '모의 체험 진행 중',
);

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

final DateTime _now = _k('2027-01-12', 10);

SimToAutoReport _report({
  RunMode? sim = RunMode.simInternal,
  SimTrialReport trial = _done,
  bool? golden = true,
  bool? keys = true,
  Map<String, String> accounts = _accounts,
  SimLedgerFate? fate = SimLedgerFate.keep,
  DateTime? opened,
  bool kill = false,
  List<String> flags = const <String>[],
}) => judgeSimToAuto(
  SimToAutoFacts(
    trustedNowUtc: _now,
    simRunMode: sim,
    simClosed: false,
    operatingMode: OperatingMode.autoTrade,
    trial: trial,
    goldenVectorPassed: golden,
    liveKeysVerified: keys,
    accountByStrategy: accounts,
    fate: fate,
    sessionOpenedAtUtc: opened,
    killSwitchActive: kill,
    blockingFlags: flags,
  ),
  kr: _kr,
  observation: _two,
);

String? _reject(SimToAutoReport r, {bool bio = true, bool noNow = false}) =>
    simToAutoOpenReject(
      biometricConfirmed: bio,
      trustedNowUtc: noNow ? null : _now,
      report: r,
    );

HandoverSessionRecord _rec({
  HandoverSessionKind kind = HandoverSessionKind.wizard,
  HandoverPath? path = HandoverPath.simToAuto,
  DateTime? opened,
  DateTime? closed,
}) {
  final DateTime o = opened ?? _now;
  return HandoverSessionRecord(
    sessionId: 'HS-1',
    kind: kind,
    path: path,
    deviceId: 'device-1',
    leaseEpoch: 1,
    openedAtUtc: o,
    expiresAtUtc: o.add(kHandoverSessionTtl),
    closedAtUtc: closed,
    closeCode: closed == null ? null : HandoverCloseCode.cancelled,
  );
}

void main() {
  test('48h = 냉각 + 확정 기한 · 알림 낸 곳 · 글자', () {
    expect(kHandoverSessionTtl, kHandoverCooling + kHandoverCommitWindow);
    expect(kHandoverSessionTtl, const Duration(hours: 48));
    expect(kHandoverCoolingCheck, 'handover-cooling');
    expect(HandoverSessionKind.gate.wire, 'GATE_M5_10');
    expect(HandoverSessionKind.wizard.wire, 'WIZARD_M5_11');
    expect(
      HandoverCloseCode.values.map((HandoverCloseCode c) => c.wire),
      <String>['COMMITTED', 'CANCELLED', 'EXPIRED', 'ROLLED_BACK'],
    );
    expect(
      HandoverSessionKind.fromWire('GATE_M5_10'),
      HandoverSessionKind.gate,
    );
    expect(HandoverCloseCode.fromWire('EXPIRED'), HandoverCloseCode.expired);
    expect(() => HandoverSessionKind.fromWire('X'), throwsFormatException);
    expect(() => HandoverCloseCode.fromWire('X'), throwsFormatException);
    expect(
      HandoverSessionCodes.biometricUnavailable,
      SettingsResultCodes.biometricUnavailable,
    );
    expect(
      HandoverSessionCodes.sessionInvalid,
      LivePromotionCodes.sessionInvalid,
    );
  });

  test('id = HS-{한국 YYYYMMDD-HHmmss}', () {
    expect(handoverSessionIdOf(_k('2027-01-12', 10, 5)), 'HS-20270112-100500');
    // 한국 자정 넘김(UTC 15:30 = 한국 다음 날 00:30).
    expect(
      handoverSessionIdOf(DateTime.utc(2027, 1, 12, 15, 30, 7)),
      'HS-20270113-003007',
    );
  });

  test('사전 판정 차례 — 생체 → 시각 → 전제 → 안전 → S1~S5 → 이미 세션', () {
    // 생체가 맨 앞(다른 것이 다 틀려도).
    expect(
      _reject(_report(sim: RunMode.live), bio: false, noNow: true),
      HandoverSessionCodes.biometricUnavailable,
    );
    expect(
      _reject(_report(sim: RunMode.live), noNow: true),
      SimToAutoCodes.trustedTimeUnavailable,
    );
    expect(_reject(_report(sim: RunMode.live)), SimToAutoCodes.notSimAuto);
    expect(
      _reject(_report(kill: true, trial: _open)),
      SimToAutoCodes.safetyBlock,
    );
    expect(
      _reject(_report(flags: <String>['TRADING_BLOCK'])),
      SimToAutoCodes.safetyBlock,
    );
    expect(_reject(_report(trial: _open)), SimToAutoCodes.trialIncomplete);
    expect(_reject(_report(golden: false)), SimToAutoCodes.goldenVectorFailed);
    expect(_reject(_report(keys: false)), SimToAutoCodes.liveKeysFailed);
    expect(
      _reject(_report(accounts: <String, String>{})),
      SimToAutoCodes.accountUnmapped,
    );
    // 아직(unknown) = 막힘 코드 없음 → 단계 id.
    expect(_reject(_report(golden: null)), 'SIM_TO_AUTO_S2');
    expect(_reject(_report(keys: null)), 'SIM_TO_AUTO_S3');
    expect(_reject(_report(fate: null)), 'SIM_TO_AUTO_S5');
    // S1 이 먼저(S2 도 막혀도).
    expect(
      _reject(_report(trial: _open, golden: false)),
      SimToAutoCodes.trialIncomplete,
    );
    expect(_reject(_report(opened: _now)), HandoverSessionCodes.sessionOpen);
  });

  test('통과 — S1~S5 통과 · 세션 없음(② 미경험 = 경고 후 진행도 통과)', () {
    expect(_reject(_report()), isNull);
    expect(_reject(_report(trial: _warn)), isNull);
    expect(_reject(_report(fate: SimLedgerFate.discard)), isNull);
    expect(_reject(_report(sim: RunMode.simBroker)), isNull);
  });

  test('유효 = 안 닫힘 ∧ 만료 전(경계 = 만료 시각에 무효)', () {
    final HandoverSessionRecord s = _rec();
    expect(s.closed, isFalse);
    expect(s.liveAt(_now), isTrue);
    expect(
      s.liveAt(
        _now.add(kHandoverSessionTtl).subtract(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    expect(s.liveAt(_now.add(kHandoverSessionTtl)), isFalse);
    final HandoverSessionRecord c = _rec(closed: _now);
    expect(c.closed, isTrue);
    expect(c.liveAt(_now), isFalse);
  });

  test('냉각 알림 — simToAuto 안 닫힘 ∧ [열림, 열림 + 24h) 만', () {
    const Set<String> on = <String>{AlertCodes.handoverCoolingActive};
    final HandoverSessionRecord s = _rec();
    expect(handoverCoolingAlertCodes(s, trustedNowUtc: _now), on);
    expect(
      handoverCoolingAlertCodes(
        s,
        trustedNowUtc: _now.add(const Duration(hours: 23, minutes: 59)),
      ),
      on,
    );
    expect(
      handoverCoolingAlertCodes(s, trustedNowUtc: _now.add(kHandoverCooling)),
      isEmpty,
    );
    expect(
      handoverCoolingAlertCodes(
        s,
        trustedNowUtc: _now.subtract(const Duration(minutes: 1)),
      ),
      isEmpty,
    );
    expect(handoverCoolingAlertCodes(s, trustedNowUtc: null), isEmpty);
    expect(handoverCoolingAlertCodes(null, trustedNowUtc: _now), isEmpty);
    expect(
      handoverCoolingAlertCodes(_rec(closed: _now), trustedNowUtc: _now),
      isEmpty,
    );
    expect(
      handoverCoolingAlertCodes(
        _rec(path: HandoverPath.freshAuto),
        trustedNowUtc: _now,
      ),
      isEmpty,
    );
    expect(
      handoverCoolingAlertCodes(
        _rec(kind: HandoverSessionKind.gate, path: null),
        trustedNowUtc: _now,
      ),
      isEmpty,
    );
    // 계약 코드 = 등급 표 · 문구 사전에 있다(«계약 밖 0» 유지).
    expect(alertLevelOf(AlertCodes.handoverCoolingActive), AlertLevel.p1);
    expect(alertTextOf(AlertCodes.handoverCoolingActive).title, isNotEmpty);
  });

  test('문구 — 열림 = 냉각 끝 · 기한(한국 분) · 거부마다 · DRY_RUN 글자 0', () {
    expect(
      handoverSessionHeadline(null, openedAtUtc: _now),
      '생체 확인 완료 — 24시간 냉각 뒤 2027-01-13 10:00부터 2027-01-14 10:00 전까지 확정할 수 있습니다.',
    );
    expect(handoverSessionHeadline(null), '전환 세션을 열었습니다.');
    final List<String> codes = <String>[
      HandoverSessionCodes.biometricUnavailable,
      SimToAutoCodes.trustedTimeUnavailable,
      HandoverSessionCodes.sessionOpen,
      HandoverSessionCodes.sessionInvalid,
      HandoverSessionCodes.rolledBack,
      SimToAutoCodes.notSimAuto,
      SimToAutoCodes.safetyBlock,
      SimToAutoCodes.trialIncomplete,
    ];
    final Set<String> texts = <String>{
      for (final String c in codes) handoverSessionHeadline(c),
    };
    expect(texts, hasLength(codes.length));
    expect(
      handoverSessionHeadline('SIM_TO_AUTO_S2'),
      handoverSessionHeadline(SimToAutoCodes.trialIncomplete),
    );
    for (final String t in <String>[...texts, kHandoverCancelledHeadline]) {
      expect(t.contains('DRY_RUN'), isFalse);
    }
  });
}
