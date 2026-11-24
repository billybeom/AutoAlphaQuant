// 🆕 E15e2 — M1-22 승격 커밋 쓰기(실전 파일 · 한 트랜잭션 · 설계 13 §8 R91 AD2~AD6).
// 🆕 리뷰 3차 H2-02(R265) — 승격 결정의 설정 지문 = 저장이 읽는 실전 개시 판(커밋이 쓰는 `OPENING_BALANCE` 행 꼴 그대로 심는다 ·
//    커밋 → 잡 → 관찰 끝까지 = 앱 `operator_handover_test` A-1) · 못 읽음 = 거부 · 쓰기 0.

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
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
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

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;
  late String liveHash;

  int promotions() =>
      _count(live, 'decision_log', "reason_code = '$kLivePromotionReasonCode'");

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
    // 🆕 R265 — 실전 개시 결정(커밋이 쓰는 꼴 · 승인 판을 붙인다) + 그 판.
    liveHash = SqliteConfigVersionStore(live, clock: clock).register(
      P0sOpsConfig.of(
        P0sHumanInputs(aSymbol: '229200', accountByStrategy: _accounts),
      ).content(),
    );
    live.execute(
      'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
      "reason_code, config_hash) VALUES ('OPEN-LIVE', ?, '2027-01-12', 'LIVE', 'MANUAL', 'P0S', '실전 개시', "
      "'OPENING_BALANCE', ?)",
      <Object?>[_iso(_commit), liveHash],
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
    kr: _kr,
    config: LiveObservationConfig(requiredTradingDays: 2),
    lease: lease,
    handoverSessionId: session,
  );

  void nothingWritten() {
    expect(promotions(), 0);
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
    final Row d = live.select(
      'SELECT * FROM decision_log WHERE reason_code = ?',
      <Object?>[kLivePromotionReasonCode],
    ).single;
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
        liveHash,
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
    expect(promotions(), 1);
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

    test('🆕 리뷰 3차 H2-02(R265) — 실전 개시 판을 못 읽음 = CONFIG_UNAVAILABLE · 쓰기 0 · 리스 거부 뒤 · 관찰 재판정 앞', () {
      void unavailable({String? because}) {
        final LivePromotionOutcome o = promote();
        expect(
          o.reasonCode,
          LivePromotionCodes.configUnavailable,
          reason: because,
        );
        expect(o.headline, startsWith('지금 운영 설정을 읽지 못해 올리지 않았습니다'));
        nothingWritten();
      }

      // 판이 바뀜(SPEC 판 칸이 맞지 않음) = DRIFT → 거부.
      live.execute(
        "UPDATE config_versions SET content = replace(content, '\"spec\":', '\"spec_old\":')",
      );
      unavailable(because: '내용 꼴 오류');
      // 무결 하루(관찰 부족)여도 설정 사유가 먼저 — «일수 부족»이 진짜 사유를 가리지 않는다.
      clock.at = _k('2027-01-13', 18);
      unavailable(because: '관찰 부족보다 먼저');
      // 리스 거부가 먼저(판정 차례).
      expect(promote(lease: LeaseVerdict.unknown).reasonCode, 'LEASE_INVALID');
      clock.at = _promoteAt;
      // 판 미등재.
      live.execute('DELETE FROM config_versions');
      unavailable(because: '미등재');
      // 실전 개시 없음 · 모의 개시 행만 = 개시 없음(다른 원장 판을 빌리지 않는다).
      live.execute(
        "UPDATE decision_log SET reason_code = 'SIM_OPENING_BALANCE' WHERE decision_id = 'OPEN-LIVE'",
      );
      unavailable(because: '모의 개시 행만');
      expect(modes().current()!.execPolicy, ExecPolicy.dryRun);
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
    expect(_count(live, 'decision_log'), 2, reason: '개시 + 미리 넣은 충돌 행');
    expect(_count(live, 'mode_transition'), 1);
    expect(modes().current()!.execPolicy, ExecPolicy.dryRun);
  });

  test('거래일 = 한국 날(01-15 08:00 = UTC 01-14 23:00)', () {
    clock.at = _k('2027-01-15', 8);
    final LivePromotionOutcome o = promote();
    expect(o.decisionId, 'PROMOTE-20270115-080000');
    expect(
      live.select(
        'SELECT trade_date FROM decision_log WHERE reason_code = ?',
        <Object?>[kLivePromotionReasonCode],
      ).single['trade_date'],
      '2027-01-15',
    );
  });
}
