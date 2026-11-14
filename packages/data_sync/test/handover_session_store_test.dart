// 🆕 E15f2 — simToAuto 전환 세션 저장(실전 파일 · 하나만 · 48h · 취소 · 만료 · 닫기 자리 · 냉각 알림 · 설계 13 §8 R96).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HandoverCloseCode,
        HandoverSessionCodes,
        HandoverSessionKind,
        HandoverSessionRecord,
        LiveObservationConfig,
        Market,
        P0sStrategyIds,
        SimLedgerFate,
        SimToAutoCodes,
        SimToAutoFacts,
        SimTrialCounters,
        SimTrialItemResult,
        SimTrialReport,
        TrustedClock,
        frozenExchangeCalendar,
        kHandoverCancelledHeadline,
        kHandoverCoolingCheck,
        kHandoverSessionTtl;
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

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

String _iso(DateTime t) => t.toUtc().toIso8601String();

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final LiveObservationConfig _two = LiveObservationConfig(
  requiredTradingDays: 2,
);

/// 생체 = 01-12(화) 10:00 · 기기 시계는 일부러 다르게(신뢰 시각이 판정한다).
final DateTime _t0 = _k('2027-01-12', 10);
final DateTime _device = _k('2027-01-12', 10, 7);

const SimTrialReport _done = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: true,
  needsWarning: false,
  counters: SimTrialCounters.zero,
  headline: '체험 5항목을 모두 채웠습니다.',
);
const SimTrialReport _open = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: false,
  needsWarning: true,
  counters: SimTrialCounters.zero,
  headline: '모의 체험 진행 중',
);

SimToAutoFacts _facts({
  RunMode? sim = RunMode.simInternal,
  SimTrialReport trial = _done,
  bool kill = false,
  DateTime? factsNow,
  DateTime? opened,
}) => SimToAutoFacts(
  trustedNowUtc: factsNow,
  simRunMode: sim,
  simClosed: false,
  operatingMode: OperatingMode.autoTrade,
  trial: trial,
  goldenVectorPassed: true,
  liveKeysVerified: true,
  accountByStrategy: const <String, String>{
    P0sStrategyIds.sleeveA: 'general',
    P0sStrategyIds.sleeveB: 'pension',
    P0sStrategyIds.sleeveC: 'general',
    P0sStrategyIds.pot: 'general',
  },
  fate: SimLedgerFate.keep,
  sessionOpenedAtUtc: opened,
  killSwitchActive: kill,
  blockingFlags: const <String>[],
);

int _count(Database db, [String where = '1=1']) =>
    db
            .select('SELECT COUNT(*) AS n FROM handover_session WHERE $where')
            .first['n']!
        as int;

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;
  late _Trusted trusted;
  late SqliteHandoverSessionStore store;

  HandoverSessionOutcome open({
    bool bio = true,
    SimToAutoFacts? facts,
    String device = 'device-1',
    int lease = 3,
  }) => store.openSimToAuto(
    biometricConfirmed: bio,
    facts: facts ?? _facts(),
    kr: _kr,
    observation: _two,
    deviceId: device,
    leaseEpoch: lease,
  );

  void raw(
    String id, {
    String kind = 'WIZARD_M5_11',
    String? path = 'SIM_TO_AUTO',
    required DateTime opened,
    DateTime? expires,
    DateTime? closed,
    String? code,
  }) => live.execute(
    'INSERT INTO handover_session (handover_session_id, kind, path, device_id, lease_epoch, '
    'opened_at, expires_at, closed_at, close_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      id,
      kind,
      path,
      'dev-0',
      0,
      _iso(opened),
      _iso(expires ?? opened.add(kHandoverSessionTtl)),
      closed == null ? null : _iso(closed),
      code,
    ],
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15f2_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_device);
    trusted = _Trusted(_t0);
    store = SqliteHandoverSessionStore(live, clock: clock, trusted: trusted);
  });

  tearDown(() {
    live.close();
    sim.close();
    dir.deleteSync(recursive: true);
  });

  test('🔴 실전 파일만 — 모의 파일 = StateError', () {
    expect(
      () => SqliteHandoverSessionStore(sim, clock: clock, trusted: trusted),
      throwsStateError,
    );
  });

  test('열기 — WIZARD_M5_11 · SIM_TO_AUTO · 신뢰 시각 · 48h · 기기 · 리스 · 문구', () {
    // 입력의 시각 · 세션 칸은 버린다(저장이 신뢰 시각으로 다시 판정).
    final HandoverSessionOutcome o = open(
      facts: _facts(factsNow: _k('2030-01-01', 0), opened: _k('2027-01-01', 0)),
    );
    expect(o.ok, isTrue);
    expect(o.sessionId, 'HS-20270112-100000');
    expect(
      o.headline,
      '생체 확인 완료 — 24시간 냉각 뒤 2027-01-13 10:00부터 2027-01-14 10:00 전까지 확정할 수 있습니다.',
    );
    final Row r = live.select('SELECT * FROM handover_session').single;
    expect(r['kind'], 'WIZARD_M5_11');
    expect(r['path'], 'SIM_TO_AUTO');
    expect(r['device_id'], 'device-1');
    expect(r['lease_epoch'], 3);
    expect(r['opened_at'], _iso(_t0));
    expect(r['expires_at'], _iso(_t0.add(const Duration(hours: 48))));
    expect(r['closed_at'], isNull);
    expect(r['close_code'], isNull);
    final HandoverSessionRecord s = store.session(o.sessionId!)!;
    expect(s.kind, HandoverSessionKind.wizard);
    expect(s.path, HandoverPath.simToAuto);
    expect(s.openedAtUtc, _t0);
    expect(store.simToAutoSession()!.sessionId, o.sessionId);
    // 모드는 건드리지 않는다.
    expect(
      live.select('SELECT COUNT(*) AS n FROM mode_transition').first['n'],
      0,
    );
  });

  test('거부 = 쓰기 0 — 생체 · 신뢰 시각 · 전제 · 체험 · 안전', () {
    expect(
      open(bio: false).reasonCode,
      HandoverSessionCodes.biometricUnavailable,
    );
    trusted.at = null;
    final HandoverSessionOutcome t = open();
    expect(t.reasonCode, SimToAutoCodes.trustedTimeUnavailable);
    expect(t.headline, '시각을 확인할 수 없어 전환을 시작하지 않았습니다.');
    trusted.at = _t0;
    expect(
      open(facts: _facts(sim: RunMode.live)).reasonCode,
      SimToAutoCodes.notSimAuto,
    );
    expect(
      open(facts: _facts(trial: _open)).reasonCode,
      SimToAutoCodes.trialIncomplete,
    );
    expect(
      open(facts: _facts(kill: true)).reasonCode,
      SimToAutoCodes.safetyBlock,
    );
    expect(_count(live), 0);
    expect(() => open(device: ' '), throwsArgumentError);
    expect(() => open(lease: -1), throwsArgumentError);
    expect(_count(live), 0);
  });

  test(
    '하나만 — 살아 있는 세션(종류 무관) = HANDOVER_SESSION_OPEN · 만료 행은 막지 않고 EXPIRED 로 닫는다',
    () {
      final String first = open().sessionId!;
      trusted.at = _t0.add(const Duration(hours: 1));
      final HandoverSessionOutcome busy = open();
      expect(busy.reasonCode, HandoverSessionCodes.sessionOpen);
      expect(busy.headline, '이미 열린 전환 세션이 있습니다 — 그 세션을 마치거나 취소한 뒤 다시 시작해 주세요.');
      expect(_count(live), 1);
      // 만료 직전 = 여전히 막힘.
      trusted.at = _t0
          .add(kHandoverSessionTtl)
          .subtract(const Duration(seconds: 1));
      expect(open().reasonCode, HandoverSessionCodes.sessionOpen);
      // 만료 = 새로 열 수 있고 옛 행은 EXPIRED(닫은 시각 = 새로 연 신뢰 시각).
      final DateTime later = _t0.add(kHandoverSessionTtl);
      trusted.at = later;
      final HandoverSessionOutcome second = open();
      expect(second.ok, isTrue);
      final HandoverSessionRecord old = store.session(first)!;
      expect(old.closeCode, HandoverCloseCode.expired);
      expect(old.closedAtUtc, later);
      expect(store.simToAutoSession()!.sessionId, second.sessionId);
      // 게이트 세션이 살아 있어도 막힌다.
      store.cancel(second.sessionId!);
      raw('HS-GATE', kind: 'GATE_M5_10', path: null, opened: later);
      trusted.at = later.add(const Duration(minutes: 1));
      expect(open().reasonCode, HandoverSessionCodes.sessionOpen);
    },
  );

  test('쓰기 실패 = 전부 되돌림(만료 정리 포함) — HANDOVER_SESSION_ROLLED_BACK', () {
    // 같은 id 가 이미 있다(닫힌 행이라 «하나만»은 통과) + 만료된 안 닫힌 행.
    raw(
      'HS-20270112-100000',
      opened: _k('2027-01-01', 0),
      closed: _k('2027-01-01', 1),
      code: 'CANCELLED',
    );
    raw('HS-STALE', opened: _k('2027-01-02', 0));
    final HandoverSessionOutcome o = open();
    expect(o.reasonCode, HandoverSessionCodes.rolledBack);
    expect(o.headline, '저장에 실패해 아무것도 바꾸지 않았습니다.');
    expect(store.session('HS-STALE')!.closed, isFalse);
    expect(_count(live), 2);
  });

  test('취소 — CANCELLED(기기 시계 · 신뢰 시각 없어도) · 닫힌 · 없는 세션 = INVALID', () {
    final String id = open().sessionId!;
    trusted.at = null;
    final HandoverSessionOutcome c = store.cancel(id);
    expect(c.ok, isTrue);
    expect(c.sessionId, id);
    expect(c.headline, kHandoverCancelledHeadline);
    final HandoverSessionRecord s = store.session(id)!;
    expect(s.closeCode, HandoverCloseCode.cancelled);
    expect(s.closedAtUtc, _device);
    expect(store.simToAutoSession(), isNull);
    final HandoverSessionOutcome again = store.cancel(id);
    expect(again.reasonCode, HandoverSessionCodes.sessionInvalid);
    expect(again.headline, '열려 있는 전환 세션이 아닙니다.');
    expect(
      store.cancel('HS-NONE').reasonCode,
      HandoverSessionCodes.sessionInvalid,
    );
    // 만료됐어도 안 닫혔으면 취소된다.
    raw('HS-OLD', opened: _k('2027-01-01', 0));
    expect(store.cancel('HS-OLD').ok, isTrue);
    expect(store.session('HS-OLD')!.closeCode, HandoverCloseCode.cancelled);
  });

  test('만료 정리 — 신뢰 시각으로 «안 닫힘 ∧ 만료» 만 · 경계 = 만료 시각에 닫음 · 시각 없음 = 0', () {
    raw('HS-A', opened: _k('2027-01-01', 0));
    raw('HS-B', kind: 'GATE_M5_10', path: null, opened: _t0);
    raw(
      'HS-C',
      opened: _k('2027-01-01', 0),
      closed: _k('2027-01-01', 1),
      code: 'CANCELLED',
    );
    trusted.at = null;
    expect(store.expireDue(), 0);
    expect(_count(live, 'closed_at IS NULL'), 2);
    trusted.at = _t0;
    expect(store.expireDue(), 1);
    expect(store.session('HS-A')!.closeCode, HandoverCloseCode.expired);
    expect(store.session('HS-A')!.closedAtUtc, _t0);
    expect(store.session('HS-B')!.closed, isFalse);
    expect(store.session('HS-C')!.closeCode, HandoverCloseCode.cancelled);
    trusted.at = _t0
        .add(kHandoverSessionTtl)
        .subtract(const Duration(milliseconds: 1));
    expect(store.expireDue(), 0);
    trusted.at = _t0.add(kHandoverSessionTtl);
    expect(store.expireDue(), 1);
    expect(store.session('HS-B')!.closeCode, HandoverCloseCode.expired);
  });

  test('🔴 닫기 자리(f3) — 바깥 트랜잭션 안에서만 · COMMITTED · ROLLED_BACK 만 · 안 닫힌 행만', () {
    final String id = open().sessionId!;
    final DateTime at = _t0.add(const Duration(hours: 30));
    expect(
      () =>
          store.closeInTransaction(id, HandoverCloseCode.committed, atUtc: at),
      throwsStateError,
    );
    live.execute('BEGIN');
    expect(
      () =>
          store.closeInTransaction(id, HandoverCloseCode.cancelled, atUtc: at),
      throwsArgumentError,
    );
    expect(
      () => store.closeInTransaction(id, HandoverCloseCode.expired, atUtc: at),
      throwsArgumentError,
    );
    expect(
      () => store.closeInTransaction(
        'HS-NONE',
        HandoverCloseCode.committed,
        atUtc: at,
      ),
      throwsStateError,
    );
    store.closeInTransaction(id, HandoverCloseCode.committed, atUtc: at);
    expect(
      () =>
          store.closeInTransaction(id, HandoverCloseCode.rolledBack, atUtc: at),
      throwsStateError,
    );
    live.execute('COMMIT');
    final HandoverSessionRecord s = store.session(id)!;
    expect(s.closeCode, HandoverCloseCode.committed);
    expect(s.closedAtUtc, at);
    raw('HS-RB', opened: _t0);
    live.execute('BEGIN');
    store.closeInTransaction('HS-RB', HandoverCloseCode.rolledBack, atUtc: at);
    live.execute('COMMIT');
    expect(store.session('HS-RB')!.closeCode, HandoverCloseCode.rolledBack);
  });

  test('읽기 — 가장 늦게 연 안 닫힌 simToAuto(만료 포함) · 게이트 · 다른 경로 · 닫힌 행 제외', () {
    expect(store.simToAutoSession(), isNull);
    raw('HS-1', opened: _k('2027-01-01', 0));
    raw('HS-2', opened: _k('2027-01-02', 0));
    raw('HS-3', kind: 'GATE_M5_10', path: null, opened: _k('2027-01-03', 0));
    raw('HS-4', path: 'FRESH_AUTO', opened: _k('2027-01-04', 0));
    raw(
      'HS-5',
      opened: _k('2027-01-05', 0),
      closed: _k('2027-01-05', 1),
      code: 'CANCELLED',
    );
    expect(store.simToAutoSession()!.sessionId, 'HS-2');
    // 같은 시각이면 id 가 큰 쪽.
    raw('HS-2b', opened: _k('2027-01-02', 0));
    expect(store.simToAutoSession()!.sessionId, 'HS-2b');
    expect(store.session('HS-NONE'), isNull);
  });

  test('🔴 시차 없는 시각 = FormatException', () {
    live.execute(
      'INSERT INTO handover_session (handover_session_id, kind, path, device_id, lease_epoch, '
      "opened_at, expires_at) VALUES ('HS-BARE', 'WIZARD_M5_11', 'SIM_TO_AUTO', 'd', 0, "
      "'2027-01-12T01:00:00', '2027-01-14T01:00:00')",
    );
    expect(() => store.session('HS-BARE'), throwsFormatException);
    expect(() => store.simToAutoSession(), throwsFormatException);
  });

  test('냉각 알림 — 열린 동안 24h · 기동 파일 알림 = 하루 1건 · 낸 곳 handover-cooling', () async {
    expect(store.coolingAlertCodes(), isEmpty);
    open();
    expect(store.coolingAlertCodes(), <String>{
      AlertCodes.handoverCoolingActive,
    });
    trusted.at = null;
    expect(store.coolingAlertCodes(), isEmpty);
    trusted.at = _t0.add(const Duration(hours: 23, minutes: 59));
    final SqliteAlertSink sink = SqliteAlertSink(sim, clock: clock);
    await sink.emit(kHandoverCoolingCheck, store.coolingAlertCodes());
    await sink.emit(kHandoverCoolingCheck, store.coolingAlertCodes());
    final ResultSet rows = sim.select(
      'SELECT code, source, level FROM alert_event',
    );
    expect(rows, hasLength(1));
    expect(rows.single['code'], 'HANDOVER_COOLING_ACTIVE');
    expect(rows.single['source'], 'handover-cooling');
    expect(rows.single['level'], 'P1');
    trusted.at = _t0.add(const Duration(hours: 24));
    expect(store.coolingAlertCodes(), isEmpty);
  });
}
