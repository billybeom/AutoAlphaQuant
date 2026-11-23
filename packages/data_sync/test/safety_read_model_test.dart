// E13e1 — 안전 상태 읽기 operator 판(설계 13 §8 R62 U1~U9).
//
// 🔵 잡는 것: ① 빈 원장 = NORMAL · 0 · 플래그 0 · 킬스위치 꺼짐 · 게이지 0 · L1 · 지금 기준 ② 채운 원장 = 최근 스냅숏 레벨 · 낙폭 ·
//    재생 자격 · 활성 플래그만(풀린 행 제외) · 저널 초안 링크(가장 오래된 빈 이탈 저널) · 검증 시각(마지막 INTEGRITY_OK) ·
//    원인 코드 · 킬스위치 + 냉각 게이지(신뢰 시각) · 램프 행 · 모드 ③ 구독 = 관계 표가 바뀔 때만.
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' as c show BreakerLevel;
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

final DateTime _t0 = DateTime.utc(2026, 10, 1, 1); // 한국 10-01 10:00

String _day(int i) => DateTime.utc(
  2026,
  9,
  1,
).add(Duration(days: i)).toIso8601String().substring(0, 10);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;
  late SqliteSafetyRepository repo;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_sf_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    repo = SqliteSafetyRepository(
      db,
      mode: RunMode.live,
      clock: clock,
      trusted: trusted,
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void seed(List<double> dds, String level, {int bullFrom = 1 << 30}) {
    for (final (int i, double dd) in dds.indexed) {
      db.execute(
        'INSERT OR REPLACE INTO equity_snapshot(trade_date, total_equity, cash_krw, cash_usd, fx_rate, positions_value, '
        "high_water_mark, drawdown, breaker_level, mode) VALUES (?, ?, ?, 0, NULL, 0, 100, ?, ?, 'LIVE')",
        <Object?>[_day(i), 100 * (1 + dd), 100 * (1 + dd), dd, level],
      );
      db.execute(
        'INSERT OR REPLACE INTO regime_score_daily(trade_date, status, direction_score, direction_state, config_hash) '
        "VALUES (?, 'OK', ?, ?, 'cfg')",
        <Object?>[
          _day(i),
          i >= bullFrom ? 60 : 40,
          i >= bullFrom ? 'BULL' : 'BEAR',
        ],
      );
    }
  }

  void flag(String id, String setAt, {String? origin, String? clearedAt}) =>
      db.execute(
        'INSERT INTO trading_block(flag_id, set_at, reason, origin_code, cleared_at) VALUES (?, ?, ?, ?, ?)',
        <Object?>[id, setAt, 'r', origin, clearedAt],
      );

  test('빈 원장 = NORMAL · 0 · 플래그 0 · 꺼짐 · 게이지 0 · L1 · 지금 기준', () {
    final SafetyState s = repo.state();
    expect(
      (
        s.breakerLevel,
        s.breakerLabel,
        s.drawdown,
        s.stoppedReleaseEligible,
        s.alertBlockSatEntry,
        s.rampLevel,
        s.mode,
      ),
      (
        c.BreakerLevel.normal,
        '정상',
        0.0,
        false,
        false,
        RampLevel.l1,
        RunMode.live,
      ),
    );
    expect(s.activeFlags, isEmpty);
    expect(s.releaseProgress, isEmpty);
    expect(s.killSwitch.active, isFalse);
    expect((s.asOf.label, s.asOf.observedAt), ('안전 상태 기준 2026-10-01', _t0));
  });

  test('채운 원장 — 최근 스냅숏 · 재생 자격 · 활성 플래그만 · 링크 · 검증 시각 · 킬스위치 냉각 · 램프', () {
    seed(
      <double>[
        -0.36,
        for (int i = 0; i < 19; i++) -0.30,
        for (int i = 0; i < 5; i++) -0.20,
      ],
      'STOPPED',
      bullFrom: 20,
    );
    flag(FlagIds.journalMissing, '2026-09-20T00:00:00.000Z');
    flag(FlagIds.reconMismatch, '2026-09-21T00:00:00.000Z', origin: 'FILL_LAG');
    flag(FlagIds.ledgerIntegrity, '2026-09-22T00:00:00.000Z');
    flag(
      FlagIds.tierBUnjudged,
      '2026-09-01T00:00:00.000Z',
      clearedAt: '2026-09-02T00:00:00.000Z',
    );
    for (final (String id, String at, Object? why)
        in <(String, String, Object?)>[
          ('J-NEW', '2026-09-23T00:00:00.000Z', null),
          ('J-OLD', '2026-09-10T00:00:00.000Z', null),
          ('J-DONE', '2026-09-01T00:00:00.000Z', 'ok'),
        ]) {
      db.execute(
        'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, is_deviation, '
        "rationale_before, expected_outcome, rule_cited, created_at) VALUES (?, '2026-09-10', 'P0S', '{}', '{}', 1, ?, ?, ?, ?)",
        <Object?>[id, why, why, why, at],
      );
    }
    for (final (String id, String at, String action)
        in <(String, String, String)>[
          ('li-0', '2026-09-20T09:10:00.000Z', 'INTEGRITY_OK'),
          ('li-1', '2026-09-29T09:10:00.000Z', 'INTEGRITY_OK'),
          ('li-2', '2026-09-30T09:10:00.000Z', 'INTEGRITY_FAILED'),
          ('rc-1', '2026-09-30T10:00:00.000Z', 'MATCHED'),
        ]) {
      db.execute(
        'INSERT INTO reconciliation_log(recon_id, run_at, matched, discrepancies, action_taken) VALUES (?, ?, 1, NULL, ?)',
        <Object?>[id, at, action],
      );
    }
    db.execute(
      "INSERT INTO kill_switch_state(id, activated_at, activated_by, checklist_confirmed_at) VALUES (1, '2026-09-30T00:00:00.000Z', '운영 폰', '2026-09-30T01:00:00.000Z')",
    );
    db.execute(
      "INSERT INTO ramp_state(id, level, pre_dst_level, updated_at) VALUES (1, 4, NULL, 't')",
    );

    final SafetyState s = repo.state();
    expect(
      (
        s.breakerLevel,
        s.breakerLabel,
        s.drawdown,
        s.stoppedReleaseEligible,
        s.alertBlockSatEntry,
        s.rampLevel,
      ),
      (c.BreakerLevel.stopped, '정지', -0.20, true, true, RampLevel.l4),
    );
    expect(s.asOf.label, '안전 상태 기준 2026-09-25');
    expect(
      s.activeFlags.map(
        (BlockFlag f) =>
            (f.flagId, f.clearDeepLink, f.originCode, f.checkpointLabel),
      ),
      <(String, String?, String?, String?)>[
        (
          FlagIds.ledgerIntegrity,
          'aaq://x5/repair-wizard',
          null,
          '마지막 검증 09-29 18:10',
        ),
        (FlagIds.reconMismatch, 'aaq://m5/block-board', 'FILL_LAG', null),
        (FlagIds.journalMissing, 'aaq://journal/draft/J-OLD', null, null),
      ],
    );
    expect(s.activeFlags.first.setAt, DateTime.utc(2026, 9, 22));
    expect(
      (s.killSwitch.active, s.killSwitch.activatedByDeviceLabel),
      (true, '운영 폰'),
    );
    expect(
      s.releaseProgress.map((GaugeProgress g) => (g.code, g.valueText)),
      <(String, String)>[
        ('DD_RECOVERY', '회복 완료'),
        ('HOLD', '유지 완료'),
        ('BULL_STREAK', 'BULL 연속 5/5일'),
        ('COOLDOWN', '남은 24시간'),
      ],
    );
    trusted.at = null;
    expect(repo.state().releaseProgress.last.valueText, '신뢰 시각 확인 중');
    // 결정 B 재개 행이 마지막 날에 있으면 재생 = HALTED → 자격 꺼짐(저장 스냅숏 레벨은 그대로 STOPPED).
    db.execute(
      "INSERT INTO breaker_release(release_id, trade_date, decision_id, created_at) VALUES ('BR-1', '2026-09-25', 'J-B', 't')",
    );
    final SafetyState after = repo.state();
    expect(
      (after.breakerLevel, after.stoppedReleaseEligible),
      (c.BreakerLevel.stopped, false),
    );
  });

  test('🆕 E11q-q6c 실사 표식 목적지 = reason 의 그 달 · 그 계좌 L-3(꼴 밖 = 부재)', () {
    const String l3 = 'aaq://ledger/self-report/2026-08/연금저축';
    db.execute(
      'INSERT INTO trading_block(flag_id, set_at, reason) VALUES (?, ?, ?), (?, ?, ?)',
      <Object?>[
        FlagIds.selfAuditDue,
        '2026-09-30T09:30:00.000Z',
        l3,
        FlagIds.selfAuditOverdue,
        '2026-09-30T09:30:00.000Z',
        '원장 실사 기한(목적지 없음 · 달 모름)',
      ],
    );
    expect(
      <String, String?>{
        for (final BlockFlag f in repo.state().activeFlags)
          f.flagId: f.clearDeepLink,
      },
      <String, String?>{
        FlagIds.selfAuditOverdue: null,
        FlagIds.selfAuditDue: l3,
      },
    );
  });

  test('모르는 플래그 행 = 스트림 오류', () async {
    flag('WHAT', '2026-09-01T00:00:00.000Z');
    await expectLater(repo.watchState().first, throwsStateError);
  });

  test('구독 — 구독 즉시 · 플래그가 서면 · 관계없는 표 = 조용', () async {
    final List<(int, RampLevel)> seen = <(int, RampLevel)>[];
    final sub = repo.watchState().listen(
      (SafetyState s) => seen.add((s.activeFlags.length, s.rampLevel)),
    );
    await pumpEventQueue();
    flag(FlagIds.dstWeek, '2026-09-01T00:00:00.000Z');
    await pumpEventQueue();
    db.execute(
      "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('GITHUB', NULL, 'OK', 0, 't')",
    );
    await pumpEventQueue();
    db.execute(
      "INSERT INTO ramp_state(id, level, pre_dst_level, updated_at) VALUES (1, 2, NULL, 't')",
    );
    await pumpEventQueue();
    await sub.cancel();
    // 관계없는 sync_state = 조용 · 램프가 바뀌면 다시 낸다.
    expect(seen, <(int, RampLevel)>[
      (0, RampLevel.l1),
      (1, RampLevel.l1),
      (1, RampLevel.l2),
    ]);
    expect(SqliteSafetyRepository.watchedTables, contains('ramp_state'));
  });
}
