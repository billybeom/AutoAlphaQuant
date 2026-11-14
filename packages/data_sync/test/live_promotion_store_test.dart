// 🆕 E15e2 — M1-22 승격 커밋 쓰기(실전 파일 · 한 트랜잭션 · 설계 13 §8 R91 AD2~AD6).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        JobRunEntry,
        JobRunStatus,
        LeaseVerdict,
        LiveObservationConfig,
        LivePromotionCodes,
        Market,
        frozenExchangeCalendar,
        kLivePromotionReason,
        kLivePromotionReasonCode;
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

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

String _iso(DateTime t) => t.toUtc().toIso8601String();

/// 실전 dryRun 커밋 = 01-12(화) 15:00 · 무결 01-13 · 01-14 · 승격 = 01-14 18:00.
final DateTime _commit = _k('2027-01-12', 15);
final DateTime _promoteAt = _k('2027-01-14', 18);
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

int _count(Database db, String table, [String where = '1=1']) =>
    db.select('SELECT COUNT(*) AS n FROM $table WHERE $where').first['n']!
        as int;

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;

  SqliteModeStore modes() =>
      SqliteModeStore(live, LedgerFile.live, clock: clock);

  Future<void> cleanDay(String d) async {
    await SqliteJobRunLog(live).record(
      JobRunEntry(
        rid: 'live-auto-kr_order-$d',
        checkName: 'live-auto-kr_order',
        sessionDay: TradeDate(d),
        startedAtUtc: _k(d, 9, 10),
        finishedAtUtc: _k(d, 9, 11),
        status: JobRunStatus.success,
      ),
    );
    live.execute(
      'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
      "VALUES (?, ?, 1, '[]', 'NONE')",
      <Object?>['rc-$d', _iso(_k(d, 9, 20))],
    );
  }

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('e15e2_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _commit);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _commit);
    clock = _Clock(_commit);
    expect(
      modes().record(
        axis: ModeAxis.runMode,
        runMode: RunMode.live,
        execPolicy: ExecPolicy.dryRun,
        operatingMode: OperatingMode.autoTrade,
        handoverSessionValid: false,
        decisionId: 'D-LIVE',
      ),
      isNull,
    );
    live.execute(
      'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
      <Object?>[OperatingMode.autoTrade.wire, _iso(_commit), _iso(_commit)],
    );
    await cleanDay('2027-01-13');
    await cleanDay('2027-01-14');
    clock.at = _promoteAt;
  });

  tearDown(() {
    live.close();
    sim.close();
    dir.deleteSync(recursive: true);
  });

  LivePromotionOutcome promote({
    bool bio = true,
    String? session,
    LeaseVerdict lease = LeaseVerdict.valid,
  }) => SqliteLivePromotionStore(live, clock: clock).promote(
    biometricConfirmed: bio,
    configHash: 'cfg-ops-1',
    kr: _kr,
    config: LiveObservationConfig(requiredTradingDays: 2),
    lease: lease,
    handoverSessionId: session,
  );

  void nothingWritten() {
    expect(_count(live, 'decision_log'), 0);
    expect(_count(live, 'mode_transition'), 1);
    expect(modes().current()!.execPolicy, ExecPolicy.dryRun);
  }

  void openSession(String id, {DateTime? expires, bool closed = false}) =>
      live.execute(
        'INSERT INTO handover_session (handover_session_id, kind, path, device_id, lease_epoch, opened_at, '
        "expires_at, closed_at, close_code) VALUES (?, 'GATE_M5_10', NULL, 'dev-1', 1, ?, ?, ?, ?)",
        <Object?>[
          id,
          _iso(_k('2027-01-14', 17, 50)),
          _iso(expires ?? _k('2027-01-14', 18, 10)),
          closed ? _iso(_k('2027-01-14', 17, 55)) : null,
          closed ? 'CANCELLED' : null,
        ],
      );

  test('🔴 실전 파일만 — 모의 원장으로는 만들지 않는다', () {
    expect(
      () => SqliteLivePromotionStore(sim, clock: clock),
      throwsA(isA<StateError>()),
    );
  });

  test('승격 = decision_log MANUAL + EXEC_POLICY 행 한 트랜잭션 · 다시 부르면 관찰 중 아님', () {
    final LivePromotionOutcome o = promote();
    expect(o.ok, isTrue);
    expect(o.decisionId, 'PROMOTE-20270114-180000');
    expect(o.headline, '실전 집행으로 올렸습니다 — 다음 회차부터 실제 주문을 냅니다.');
    final Row d = live.select('SELECT * FROM decision_log').single;
    expect(
      <Object?>[
        d['decision_id'],
        d['created_at'],
        d['trade_date'],
        d['mode'],
        d['kind'],
        d['strategy_id'],
        d['reason'],
        d['reason_code'],
        d['config_hash'],
      ],
      <Object?>[
        'PROMOTE-20270114-180000',
        _iso(_promoteAt),
        '2027-01-14',
        'LIVE',
        'MANUAL',
        'P0S',
        kLivePromotionReason,
        kLivePromotionReasonCode,
        'cfg-ops-1',
      ],
    );
    final Row m = live
        .select('SELECT * FROM mode_transition ORDER BY transition_id DESC')
        .first;
    expect(
      <Object?>[
        m['axis'],
        m['mode'],
        m['exec_policy'],
        m['from_mode'],
        m['from_exec_policy'],
        m['decision_id'],
        m['handover_session_id'],
      ],
      <Object?>[
        'EXEC_POLICY',
        'LIVE',
        'EXECUTE',
        'LIVE',
        'DRY_RUN',
        'PROMOTE-20270114-180000',
        null,
      ],
    );
    expect(modes().current()!.execPolicy, ExecPolicy.execute);

    clock.at = _promoteAt.add(const Duration(minutes: 1));
    final LivePromotionOutcome again = promote();
    expect(again.reasonCode, LivePromotionCodes.notObserving);
    expect(_count(live, 'decision_log'), 1);
    expect(_count(live, 'mode_transition'), 2);
  });

  group('거부 = 아무것도 쓰지 않는다(AD4)', () {
    test('🆕 E15f5 실전 리스 모름 · 무효 = LEASE_INVALID(E11k 전 승격 막음)', () {
      for (final LeaseVerdict v in <LeaseVerdict>[
        LeaseVerdict.unknown,
        LeaseVerdict.invalid,
      ]) {
        final LivePromotionOutcome o = promote(lease: v);
        expect(o.reasonCode, 'LEASE_INVALID');
        expect(o.headline, '이 기기의 발주권(리스)을 확인할 수 없어 올리지 않았습니다.');
        nothingWritten();
      }
    });

    test('생체 없음', () {
      final LivePromotionOutcome o = promote(bio: false);
      expect(o.ok, isFalse);
      expect(o.decisionId, isNull);
      expect(o.reasonCode, LivePromotionCodes.biometricUnavailable);
      expect(o.headline, '생체 확인이 없어 올리지 않았습니다.');
      nothingWritten();
    });

    test('무결 하루 = 관찰 사유 코드 · 칩 문구', () {
      clock.at = _k('2027-01-13', 18);
      final LivePromotionOutcome o = promote();
      expect(o.reasonCode, 'LIVE_OBSERVATION_NOT_ENOUGH_DAYS');
      expect(o.headline, '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)');
      nothingWritten();
    });

    test('킬스위치 켜짐 = 재판정이 막는다', () {
      live.execute(
        "INSERT INTO kill_switch_state (id, activated_at, activated_by) VALUES (1, ?, 'app')",
        <Object?>[_iso(_k('2027-01-14', 10))],
      );
      expect(promote().reasonCode, 'LIVE_OBSERVATION_KILL_SWITCH');
      nothingWritten();
    });

    test('운영 방식 = 투자 안내 · 없음 = 자동 매매 아님', () {
      live.execute(
        'UPDATE onboarding_choice SET operating_mode = ? WHERE id = 1',
        <Object?>[OperatingMode.advisory.wire],
      );
      expect(promote().reasonCode, LivePromotionCodes.notAutoTrade);
      live.execute('DELETE FROM onboarding_choice');
      expect(promote().reasonCode, LivePromotionCodes.notAutoTrade);
      nothingWritten();
    });

    test('기기 시각이 관찰 시작 앞 = 시각 거부', () {
      clock.at = _k('2027-01-12', 14);
      expect(promote().reasonCode, LivePromotionCodes.clockBehind);
      nothingWritten();
    });
  });

  group('세션(AD2 — 선택 인자)', () {
    test('없는 · 닫힌 · 만료된 세션 = 거부', () {
      expect(
        promote(session: 'HS-none').reasonCode,
        LivePromotionCodes.sessionInvalid,
      );
      openSession('HS-closed', closed: true);
      expect(
        promote(session: 'HS-closed').reasonCode,
        LivePromotionCodes.sessionInvalid,
      );
      openSession('HS-old', expires: _k('2027-01-14', 18));
      expect(
        promote(session: 'HS-old').reasonCode,
        LivePromotionCodes.sessionInvalid,
      );
      nothingWritten();
    });

    test('열린 세션 = 행에 기록 · 세션은 닫지 않는다(주인 = E15f)', () {
      openSession('HS-1');
      final LivePromotionOutcome o = promote(session: 'HS-1');
      expect(o.ok, isTrue);
      expect(
        live
            .select(
              "SELECT handover_session_id FROM mode_transition WHERE axis = 'EXEC_POLICY'",
            )
            .single['handover_session_id'],
        'HS-1',
      );
      expect(
        live
            .select(
              "SELECT closed_at FROM handover_session WHERE handover_session_id = 'HS-1'",
            )
            .single['closed_at'],
        isNull,
      );
    });

    test('세션 만료 시각에 시차가 없으면 FormatException · 아무것도 쓰지 않는다', () {
      live.execute(
        'INSERT INTO handover_session (handover_session_id, kind, path, device_id, lease_epoch, opened_at, '
        "expires_at, closed_at, close_code) VALUES ('HS-x', 'GATE_M5_10', NULL, 'dev-1', 1, ?, '2027-01-14T10:00:00', NULL, NULL)",
        <Object?>[_iso(_k('2027-01-14', 17, 50))],
      );
      expect(() => promote(session: 'HS-x'), throwsFormatException);
      nothingWritten();
    });
  });

  test('저장 실패 = 전부 되돌림(LIVE_PROMOTION_ROLLED_BACK)', () {
    live.execute(
      'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
      "reason_code, config_hash) VALUES ('PROMOTE-20270114-180000', 'x', '2027-01-14', 'LIVE', 'MANUAL', "
      "'P0S', 'r', 'c', 'h')",
    );
    final LivePromotionOutcome o = promote();
    expect(o.reasonCode, LivePromotionCodes.rolledBack);
    expect(o.headline, '실전 집행으로 올리지 못했습니다 — 바뀐 것은 없습니다. 다시 시도해 주세요.');
    expect(_count(live, 'decision_log'), 1);
    expect(_count(live, 'mode_transition'), 1);
    expect(modes().current()!.execPolicy, ExecPolicy.dryRun);
  });

  test('거래일 = 한국 날(01-15 08:00 = UTC 01-14 23:00)', () {
    clock.at = _k('2027-01-15', 8);
    final LivePromotionOutcome o = promote();
    expect(o.decisionId, 'PROMOTE-20270115-080000');
    expect(
      live.select('SELECT trade_date FROM decision_log').single['trade_date'],
      '2027-01-15',
    );
  });
}
