// E13e1 — 안전 상태 조립 순수(설계 13 §8 R62 U2~U8).
//
// 🔵 잡는 것: ① 픽스처 `safety_states` 의 플래그 5종 · 브레이커 라벨 · ALERT 차단 스위치 글자 그대로(실사 링크 = E18)
//    ② 정렬(무리 → 선 시각 → id) · 모르는 플래그 = 실패 · 목적지(차단 보드 · 저널 초안 · 위저드 · 실사 검토 · 없음)
//    ③ 검증 시각 = 무결성 플래그에만 · 원인 코드 그대로 ④ 게이지 전 갈래(회복 · 유지 · BULL · 냉각 · 경계 · 신뢰 시각 모름)
//    ⑤ 램프 사상(L0 없음) ⑥ 기준 시각 ⑦ 계약 레벨 사상.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' as c show BreakerLevel;
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

List<Map<String, dynamic>> _fixtureRows() =>
    ((jsonDecode(
              File('../domain_contracts/fixtures/safety_states.json')
                  .readAsStringSync(),
            ) as Map<String, dynamic>)['rows']
            as List<dynamic>)
        .cast<Map<String, dynamic>>();

BreakerReplay _replay({int held = 0, int bull = 0, double dd = 0}) =>
    BreakerReplay(
      BreakerState(level: BreakerLevel.normal, barsSinceChange: held),
      releaseEligibleToday: false,
      bullStreak: bull,
      lastDrawdown: dd,
    );

const KillSwitchRecord _off = KillSwitchRecord();

void main() {
  group('플래그(R62 U3)', () {
    test('🔵 픽스처 플래그 5종 · 브레이커 라벨 · ALERT 이상 = 새틀 진입 중단 스위치 — 글자 그대로', () {
      int checked = 0;
      for (final Map<String, dynamic> row in _fixtureRows()) {
        final SafetyState want = SafetyState.fromJson(row);
        final BreakerLevel level = BreakerLevel.fromCode(
          want.breakerLevel.wire,
        );
        expect(breakerLabelOf(level), want.breakerLabel);
        expect(contractBreakerLevelOf(level), want.breakerLevel);
        expect(
          level.index >= BreakerLevel.alert.index,
          want.alertBlockSatEntry,
        );
        final List<BlockFlag> got = blockFlagsOf(
          <StoredBlockFlag>[
            for (final BlockFlag f in want.activeFlags)
              StoredBlockFlag(f.flagId, f.setAt, originCode: f.originCode),
          ],
          journalDraftId: 'd_20260810_b_27',
          lastIntegrityOkUtc: DateTime.utc(2026, 8, 30, 9, 10),
        );
        for (final (int i, BlockFlag f) in want.activeFlags.indexed) {
          final BlockFlag g = got[i];
          // 🟡 실사 목적지(yyyy-MM · 별칭)는 생산자 판(E18) — 지금은 null.
          final String? link = f.flagId == FlagIds.selfAuditDue
              ? null
              : f.clearDeepLink;
          expect(g, f.copyWith(clearDeepLink: link), reason: f.flagId);
          checked++;
        }
      }
      expect(checked, 5);
    });

    test('🔴 정렬 = 무결성 > 대사 > 재개 > 정정 > X7 차단 2 > 나머지 · 같은 무리 = 선 시각 · id', () {
      final DateTime t = DateTime.utc(2026, 11, 1);
      final List<String> ids = FlagIds.values.toList()..shuffle();
      final List<BlockFlag> got = blockFlagsOf(<StoredBlockFlag>[
        for (final (int i, String id) in ids.indexed)
          StoredBlockFlag(
            id,
            t.add(
              Duration(minutes: id == FlagIds.selfAuditOverdue ? -1 : i % 3),
            ),
          ),
      ]);
      final List<String> order = got.map((BlockFlag f) => f.flagId).toList();
      expect(order.take(6), <String>[
        FlagIds.ledgerIntegrity,
        FlagIds.reconMismatch,
        FlagIds.resumeIncomplete,
        FlagIds.ledgerFix,
        FlagIds.selfAuditOverdue,
        FlagIds.adviceLedgerUnverified,
      ]);
      expect(order.toSet(), FlagIds.values);
      final List<BlockFlag> tie = blockFlagsOf(<StoredBlockFlag>[
        StoredBlockFlag(FlagIds.tierBUnjudged, t),
        StoredBlockFlag(FlagIds.journalMissing, t),
        StoredBlockFlag(
          FlagIds.dstWeek,
          t.subtract(const Duration(seconds: 1)),
        ),
      ]);
      expect(tie.map((BlockFlag f) => f.flagId), <String>[
        FlagIds.dstWeek,
        FlagIds.journalMissing,
        FlagIds.tierBUnjudged,
      ]);
    });

    test('모르는 플래그 = 실패 · 사전 = 12 전부 · 지시문은 플래그마다 다르다', () {
      expect(
        () => blockFlagsOf(<StoredBlockFlag>[
          StoredBlockFlag('WHAT', DateTime.utc(2026)),
        ]),
        throwsStateError,
      );
      expect(kFlagDictionary.keys.toSet(), FlagIds.values);
      expect(
        kFlagDictionary.values.map((FlagEntry e) => e.instruction).toSet(),
        hasLength(12),
      );
      expect(
        kFlagDictionary[FlagIds.ledgerFix]!.route,
        ClearRoute.noManualPath,
      );
    });

    test('목적지 · 검증 시각 · 원인 코드', () {
      final DateTime t = DateTime.utc(2026, 11, 1);
      Map<String, BlockFlag> of({String? draft, DateTime? ok}) =>
          <String, BlockFlag>{
            for (final BlockFlag f in blockFlagsOf(
              <StoredBlockFlag>[
                for (final String id in FlagIds.values)
                  StoredBlockFlag(
                    id,
                    t,
                    originCode: id == FlagIds.reconMismatch ? 'FILL_LAG' : null,
                  ),
              ],
              journalDraftId: draft,
              lastIntegrityOkUtc: ok,
            ))
              f.flagId: f,
          };
      final Map<String, BlockFlag> m = of(
        draft: 'J-9',
        ok: DateTime.utc(2026, 10, 31, 15, 5),
      );
      expect(
        <String, String?>{
          for (final MapEntry<String, BlockFlag> e in m.entries)
            e.key: e.value.clearDeepLink,
        },
        <String, String?>{
          FlagIds.reconMismatch: 'aaq://m5/block-board',
          FlagIds.journalMissing: 'aaq://journal/draft/J-9',
          FlagIds.tierBUnjudged: null,
          FlagIds.dstWeek: null,
          FlagIds.resumeIncomplete: null,
          FlagIds.ledgerFix: null,
          FlagIds.ledgerIntegrity: 'aaq://x5/repair-wizard',
          FlagIds.adviceLedgerUnverified: 'aaq://m5/self-audit-resolve',
          FlagIds.selfAuditOverdue: null,
          FlagIds.selfAuditDue: null,
          FlagIds.selfAuditPatternUnverified: null,
          FlagIds.adviceSelectiveExecution: null,
        },
      );
      expect(m[FlagIds.ledgerIntegrity]!.checkpointLabel, '마지막 검증 11-01 00:05');
      expect(
        m.values.where((BlockFlag f) => f.checkpointLabel != null),
        hasLength(1),
      );
      expect(m[FlagIds.reconMismatch]!.originCode, 'FILL_LAG');
      final Map<String, BlockFlag> none = of();
      expect(
        (
          none[FlagIds.journalMissing]!.clearDeepLink,
          none[FlagIds.ledgerIntegrity]!.checkpointLabel,
        ),
        (null, null),
      );
    });
  });

  group('게이지(R62 U5)', () {
    final DateTime now = DateTime.utc(2026, 11, 5, 12);
    List<(String, double, String)> g(
      BreakerLevel l, {
      double dd = 0,
      int held = 0,
      int bull = 0,
      KillSwitchRecord ks = _off,
      DateTime? trusted,
    }) => <(String, double, String)>[
      for (final GaugeProgress x in releaseProgressOf(
        level: l,
        drawdown: dd,
        replay: _replay(held: held, bull: bull, dd: dd),
        killSwitch: ks,
        trustedNowUtc: trusted,
      ))
        (x.code, x.normalized, x.valueText),
    ];

    test('NORMAL = 없음 · ALERT = 회복 + 유지 · HALTED · STOPPED = + BULL', () {
      expect(g(BreakerLevel.normal, dd: -0.05), isEmpty);
      final List<(String, double, String)> a = g(
        BreakerLevel.alert,
        dd: -0.14,
        held: 12,
      );
      expect(a.map(((String, double, String) x) => x.$1), <String>[
        'DD_RECOVERY',
        'HOLD',
      ]);
      expect(a[0].$2, closeTo(0.5, 1e-9));
      expect((a[0].$3, a[1].$2, a[1].$3), ('회복 50% 진행', 0.6, '12/20거래일'));
      expect(g(BreakerLevel.reduced, dd: -0.16).first.$3, '회복 50% 진행');
      final List<(String, double, String)> h = g(
        BreakerLevel.halted,
        dd: -0.20,
        held: 20,
        bull: 2,
      );
      expect(
        h.map(((String, double, String) x) => (x.$1, x.$3)),
        <(String, String)>[
          ('DD_RECOVERY', '회복 50% 진행'),
          ('HOLD', '유지 완료'),
          ('BULL_STREAK', 'BULL 연속 2/3일'),
        ],
      );
      expect(h[1].$2, 1.0);
      final List<(String, double, String)> s = g(
        BreakerLevel.stopped,
        dd: -0.25,
        held: 25,
        bull: 7,
      );
      expect(
        s.map(((String, double, String) x) => (x.$2, x.$3)),
        <(double, String)>[
          (1.0, '회복 완료'),
          (1.0, '유지 완료'),
          (1.0, 'BULL 연속 5/5일'),
        ],
      );
      final List<(String, double, String)> deep = g(
        BreakerLevel.stopped,
        dd: -0.40,
      );
      expect(
        (deep[0].$2, deep[0].$3, deep[2].$3),
        (0.0, '회복 0% 진행', 'BULL 연속 0/5일'),
      );
      expect(g(BreakerLevel.stopped, dd: -0.3001).first.$3, '회복 49% 진행');
    });

    test('냉각 = 킬스위치 확인 뒤만 · 신뢰 시각 모름 · 남은 시간(올림) · 완료', () {
      final DateTime act = DateTime.utc(2026, 11, 4);
      final KillSwitchRecord confirmed = KillSwitchRecord(
        activatedAtUtc: act,
        checklistConfirmedAtUtc: act.add(const Duration(hours: 1)),
      );
      final KillSwitchRecord unconfirmed = KillSwitchRecord(
        activatedAtUtc: act,
      );
      expect(g(BreakerLevel.normal, ks: unconfirmed, trusted: now), isEmpty);
      expect(g(BreakerLevel.normal, ks: confirmed), <(String, double, String)>[
        ('COOLDOWN', 0.0, '신뢰 시각 확인 중'),
      ]);
      final (String, double, String) q = g(
        BreakerLevel.normal,
        ks: confirmed,
        trusted: act.add(const Duration(hours: 13)),
      ).single;
      expect((q.$1, q.$3), ('COOLDOWN', '남은 36시간'));
      expect(q.$2, closeTo(0.25, 1e-9));
      expect(
        g(
          BreakerLevel.normal,
          ks: confirmed,
          trusted: act.add(const Duration(hours: 48, minutes: 30)),
        ).single.$3,
        '남은 1시간',
      );
      expect(
        g(
          BreakerLevel.normal,
          ks: confirmed,
          trusted: act.add(const Duration(hours: 49)),
        ).single,
        ('COOLDOWN', 1.0, '냉각 완료'),
      );
      // 해제됐으면(48h 지나 · 결정 있음) 게이지 없음.
      final KillSwitchRecord cleared = KillSwitchRecord(
        activatedAtUtc: act,
        checklistConfirmedAtUtc: act,
        clearedAtUtc: act.add(const Duration(hours: 49)),
        decisionId: 'J',
      );
      expect(
        g(
          BreakerLevel.halted,
          ks: cleared,
          trusted: now,
        ).map(((String, double, String) x) => x.$1),
        <String>['DD_RECOVERY', 'HOLD', 'BULL_STREAK'],
      );
    });
  });

  test('램프 · 기준 시각 · 조립', () {
    expect(rampLevelOf(null), RampLevel.l1);
    expect(
      <RampLevel>[for (int i = 1; i <= 5; i++) rampLevelOf(i)],
      <RampLevel>[
        RampLevel.l1,
        RampLevel.l2,
        RampLevel.l3,
        RampLevel.l4,
        RampLevel.l5,
      ],
    );
    expect(() => rampLevelOf(0), throwsRangeError);
    expect(() => rampLevelOf(6), throwsRangeError);
    final AsOf a = safetyAsOf(
      lastSnapshotDate: '2026-11-04',
      nowUtc: DateTime.utc(2026, 11, 5, 16),
    );
    expect(
      (a.label, a.tradeDate, a.observedAt, a.staleAfter, a.source),
      (
        '안전 상태 기준 2026-11-04',
        const TradeDate('2026-11-04'),
        DateTime.utc(2026, 11, 5, 16),
        const Duration(hours: 26),
        AsOfSource.localSqlite,
      ),
    );
    expect(
      safetyAsOf(
        lastSnapshotDate: null,
        nowUtc: DateTime.utc(2026, 11, 5, 16),
      ).label,
      '안전 상태 기준 2026-11-06',
    );
    final SafetyState s = safetyStateOf(
      level: BreakerLevel.reduced,
      drawdown: -0.21,
      flags: const <BlockFlag>[],
      killSwitch: const KillSwitchView(active: false, stateLabel: 'x'),
      stoppedReleaseEligible: false,
      releaseProgress: const <GaugeProgress>[],
      rampLevel: RampLevel.l2,
      mode: RunMode.simInternal,
      asOf: a,
    );
    expect(
      (
        s.breakerLevel,
        s.breakerLabel,
        s.drawdown,
        s.alertBlockSatEntry,
        s.rampLevel,
        s.mode,
      ),
      (
        c.BreakerLevel.reduced,
        '축소 운용',
        -0.21,
        true,
        RampLevel.l2,
        RunMode.simInternal,
      ),
    );
    expect(
      safetyStateOf(
        level: BreakerLevel.normal,
        drawdown: 0,
        flags: const <BlockFlag>[],
        killSwitch: const KillSwitchView(active: false, stateLabel: 'x'),
        stoppedReleaseEligible: false,
        releaseProgress: const <GaugeProgress>[],
        rampLevel: RampLevel.l1,
        mode: RunMode.live,
        asOf: a,
      ).alertBlockSatEntry,
      isFalse,
    );
    // ALERT 부터 켜진다(경계).
    expect(
      safetyStateOf(
        level: BreakerLevel.alert,
        drawdown: -0.15,
        flags: const <BlockFlag>[],
        killSwitch: const KillSwitchView(active: false, stateLabel: 'x'),
        stoppedReleaseEligible: false,
        releaseProgress: const <GaugeProgress>[],
        rampLevel: RampLevel.l1,
        mode: RunMode.live,
        asOf: a,
      ).alertBlockSatEntry,
      isTrue,
    );
  });
}
