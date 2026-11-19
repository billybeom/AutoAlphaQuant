// E13d1 — 브레이커 소비(SPEC v2.40 04 §2 · §3-1 NR-1 1.5 · 설계 13 §8 R60 B1 · B3~B7).
//
// 🔵 잡는 것: ① test_stopped_blocks_all_new_orders — STOPPED = 매수 · 매도 · 안내 모두 REJECTED BREAKER_STOPPED · 제출 0 ·
//    2단계 전에 멈춤 · HALTED 이하 = 통과 · 읽기 실패 = 원장 불가 · 집행일을 넘긴다
//    ② test_stopped_never_auto_liquidates — lib 어디도 `exposureMultiplier` 를 부르지 않는다(정적)
//    ③ test_decision_b_releases_to_halted_once — 재생: 재개 날 걸음 뒤 HALTED · 한 에피소드 한 번 · STOPPED 아닌 날 = 무시
//    ④ GV-31 s_h5_1 `on` = 실제 `replayBreaker` + 재개 날로 전이 전부 ⑤ 게이지 원천(유지 봉 · bull · dd · 자격 지속 · 진입)
//    ⑥ 재개 날짜 → 재생 날(이상인 첫 날 · 미래 = 없음) ⑦ SEV1 건(id · 기한 3일 · 금액 0).
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

import 'golden/golden_vectors.dart';

class _DateLedger extends FakeOrderLedger {
  _DateLedger()
    : super(
        registeredStrategies: <String>{
          P0sStrategyIds.sleeveB,
          P0sStrategyIds.sleeveC,
        },
      );
  final List<TradeDate> seen = <TradeDate>[];
  @override
  Future<BreakerLevel> breakerLevel(TradeDate executionDate) {
    seen.add(executionDate);
    return super.breakerLevel(executionDate);
  }
}

List<double> _linspace(double start, double stop, int num) {
  final double step = (stop - start) / (num - 1);
  return <double>[
    for (int i = 0; i < num; i++) i == num - 1 ? stop : i * step + start,
  ];
}

BreakerDay _d(
  double dd, {
  bool bull = false,
  bool release = false,
  double? score = 40,
}) => BreakerDay(
  drawdown: dd,
  directionScore: score,
  bull: bull,
  release: release,
);

void main() {
  final BreakerConfig cfg = p0sBreakerConfig();

  group('test_stopped_blocks_all_new_orders(NR-1 1.5 · R60 B1)', () {
    test(
      'STOPPED = 매수 · 매도 · 안내 모두 REJECTED BREAKER_STOPPED · 제출 0 · 2단계 전에 멈춤',
      () async {
        final _DateLedger ledger = _DateLedger()
          ..breaker = BreakerLevel.stopped;
        final FakeOrderBroker broker = FakeOrderBroker();
        final RecordingAdviceSink sink = RecordingAdviceSink();
        final List<String> steps = <String>[];
        final ExecutionOutcome buy = await executeIntent(
          draftOf(executionDate: const TradeDate('2026-11-06')),
          portfolioOk(),
          ctxOf(ledger, broker),
          steps: steps,
        );
        final ExecutionOutcome sell = await executeIntent(
          draftOf(side: OrderSide.sell, logical: 'S-1'),
          portfolioOk(),
          ctxOf(ledger, broker),
        );
        final ExecutionOutcome adv = await executeIntent(
          draftOf(logical: 'A-1'),
          portfolioOk(),
          ctxOf(ledger, broker, mode: OperatingMode.advisory, advice: sink),
        );
        for (final ExecutionOutcome o in <ExecutionOutcome>[buy, sell, adv]) {
          expect(
            (o.status, o.message),
            (ExecutionStatus.rejected, 'BREAKER_STOPPED'),
          );
        }
        expect(broker.submitCount, 0);
        expect(sink.published, isEmpty);
        expect(steps, <String>['0', '1', '1.5']);
        expect(ledger.seen.first, const TradeDate('2026-11-06'));
        expect(
          ledger.records.values
              .map((FakeIntentRecord r) => (r.status, r.errorMessage))
              .toSet(),
          <(IntentStatus, String?)>{(IntentStatus.rejected, 'BREAKER_STOPPED')},
        );
      },
    );

    test(
      'HALTED 이하 = 이 단계 통과 · 킬스위치가 먼저 · 읽기 실패 = 원장 불가(fail-closed)',
      () async {
        for (final BreakerLevel l in <BreakerLevel>[
          BreakerLevel.normal,
          BreakerLevel.alert,
          BreakerLevel.reduced,
          BreakerLevel.halted,
        ]) {
          final FakeOrderLedger ledger = ledgerOf()..breaker = l;
          final ExecutionOutcome o = await executeIntent(
            draftOf(),
            portfolioOk(),
            ctxOf(ledger, FakeOrderBroker()),
          );
          expect(o.status, ExecutionStatus.submitted, reason: l.code);
        }
        final FakeOrderLedger both = ledgerOf()
          ..breaker = BreakerLevel.stopped
          ..killSwitch = true;
        expect(
          (await executeIntent(
            draftOf(),
            portfolioOk(),
            ctxOf(both, FakeOrderBroker()),
          )).message,
          'KILL_SWITCH',
        );
        final FakeOrderLedger failing = ledgerOf()
          ..failOn = (String m) =>
              m == 'breakerLevel' ? StateError('디스크') : null;
        final ExecutionOutcome f = await executeIntent(
          draftOf(),
          portfolioOk(),
          ctxOf(failing, FakeOrderBroker()),
        );
        expect(f.status, ExecutionStatus.rejected);
        expect(f.message, startsWith('RISK_UNAVAILABLE: 원장 확인 불가'));
      },
    );
  });

  test('test_stopped_never_auto_liquidates — lib 에서 exposureMultiplier 를 부르는 곳 0(정의 하나뿐)', () {
    final List<String> hits = <String>[
      for (final FileSystemEntity f in Directory(
        'lib',
      ).listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart'))
          for (final (int i, String line) in f.readAsLinesSync().indexed)
            if (line.contains('exposureMultiplier(') &&
                !line.trimLeft().startsWith('//'))
              '${f.path}:${i + 1}'.replaceAll(r'\', '/'),
    ];
    // 🔵 E11o-c1(설계 13 §8 R164) — 기기 골든 실행기의 GV-18 판정(정답지 값 대조)은 소비가 아니다.
    //    그 한 파일만 따로 세고, 나머지(운영 lib)는 정의 하나뿐이어야 한다.
    final List<String> golden = <String>[
      for (final String h in hits)
        if (h.contains('lib/src/golden/')) h,
    ];
    final List<String> rest = <String>[
      for (final String h in hits)
        if (!golden.contains(h)) h,
    ];
    expect(rest, hasLength(1));
    expect(rest.single, contains('lib/src/risk/breaker.dart'));
    expect(
      golden.map((String h) => h.substring(0, h.lastIndexOf(':'))).toSet(),
      <String>{'lib/src/golden/gv_breaker.dart'},
    );
  });

  group('test_decision_b_releases_to_halted_once(재생 · R60 B3)', () {
    final List<BreakerDay> stopped = <BreakerDay>[
      for (int i = 0; i < 25; i++) _d(-0.36),
    ];

    test(
      '재개 날 걸음 뒤 HALTED(유지 0) · 같은 에피소드 두 번째 재개 = 무시 · STOPPED 아닌 날 = 무시',
      () {
        BreakerReplay r = replayBreaker(<BreakerDay>[
          ...stopped,
          _d(-0.20, release: true),
        ], cfg);
        expect((r.state.level, r.heldBars), (BreakerLevel.halted, 0));
        r = replayBreaker(<BreakerDay>[
          ...stopped,
          _d(-0.20, release: true),
          _d(-0.20, release: true),
          _d(-0.20),
        ], cfg);
        expect((r.state.level, r.heldBars), (BreakerLevel.halted, 2));
        r = replayBreaker(<BreakerDay>[
          _d(-0.05, release: true),
          _d(-0.05),
        ], cfg);
        expect(r.state.level, BreakerLevel.normal);
        // 재개 없이는 영원히 STOPPED.
        expect(
          replayBreaker(<BreakerDay>[
            ...stopped,
            for (int i = 0; i < 40; i++) _d(-0.01, bull: true, score: 90),
          ], cfg).state.level,
          BreakerLevel.stopped,
        );
        // 재개 뒤 다시 −35% 아래 = 다시 STOPPED(새 에피소드).
        r = replayBreaker(<BreakerDay>[
          ...stopped,
          _d(-0.20, release: true),
          _d(-0.40),
        ], cfg);
        expect(
          (r.state.level, r.stoppedEnteredToday),
          (BreakerLevel.stopped, true),
        );
      },
    );

    test('게이지 원천 — bull 연속 · 마지막 dd · 유지 봉 · 진입 날 · 🔴 자격 지속(에피소드 동안)', () {
      BreakerReplay r = replayBreaker(<BreakerDay>[_d(-0.10), _d(-0.36)], cfg);
      expect(
        (
          r.stoppedEnteredToday,
          r.lastDrawdown,
          r.heldBars,
          r.stoppedReleaseEligible,
        ),
        (true, -0.36, 0, false),
      );
      r = replayBreaker(<BreakerDay>[_d(-0.36), _d(-0.36)], cfg);
      expect(r.stoppedEnteredToday, isFalse);
      final List<BreakerDay> eligible = <BreakerDay>[
        _d(-0.36),
        for (int i = 0; i < 19; i++) _d(-0.30),
        for (int i = 0; i < 5; i++) _d(-0.20, bull: true, score: 60),
      ];
      r = replayBreaker(eligible, cfg);
      expect(
        (r.releaseEligibleToday, r.stoppedReleaseEligible, r.bullStreak),
        (true, true, 5),
      );
      r = replayBreaker(<BreakerDay>[...eligible, _d(-0.21, bull: false)], cfg);
      expect(
        (
          r.releaseEligibleToday,
          r.stoppedReleaseEligible,
          r.bullStreak,
          r.lastDrawdown,
        ),
        (false, true, 0, -0.21),
      );
      r = replayBreaker(<BreakerDay>[
        ...eligible,
        _d(-0.21, release: true),
      ], cfg);
      expect(
        (r.state.level, r.stoppedReleaseEligible),
        (BreakerLevel.halted, false),
      );
      expect(replayBreaker(const <BreakerDay>[], cfg).lastDrawdown, 0);
    });

    test('🔵 GV-31 s_h5_1 on = 실제 replayBreaker + 자격 날 재개로 전이 전부', () {
      final Map<String, Object?> vectorB = asObject(
        loadVector('gv31_s_h5_1_J1_stopped.json')['vectorB_deterministic'],
      );
      final List<double> ddv = <double>[
        ..._linspace(0.0, -0.36, 21),
        ..._linspace(-0.36, -0.24, 20),
        ..._linspace(-0.24, -0.10, 30),
        for (int d = 71; d <= 129; d++) -0.05,
      ];
      final int releaseDay = asInt(
        asObjectList(asObject(vectorB['off'])['eligible_events']).single['day'],
      );
      final List<BreakerDay> days = <BreakerDay>[
        for (int d = 0; d < ddv.length; d++)
          BreakerDay(
            drawdown: ddv[d],
            directionScore: 60,
            bull: d >= 50,
            release: d == releaseDay,
          ),
      ];
      final List<(int, String)> moves = <(int, String)>[];
      BreakerLevel prev = BreakerLevel.normal;
      for (int n = 1; n <= days.length; n++) {
        final BreakerLevel now = replayBreaker(
          days.take(n).toList(),
          cfg,
        ).state.level;
        if (now != prev) moves.add((n - 1, '${prev.code} -> ${now.code}'));
        prev = now;
      }
      final List<Map<String, Object?>> want = asObjectList(
        asObject(vectorB['on'])['transitions'],
      );
      expect(moves, <(int, String)>[
        for (final Map<String, Object?> w in want)
          (asInt(w['day']), asString(w['move'])),
      ]);
      expect(prev.code, asString(asObject(vectorB['on'])['final_level']));
    });

    test('재개 날짜 → 재생 날 = 그 날짜 이상인 첫 날(휴일) · 미래 = 없음 · 스냅숏 행에 HALTED', () {
      List<EquitySnapshotRow> hist(int n) => <EquitySnapshotRow>[
        for (int i = 0; i < n; i++)
          EquitySnapshotRow(
            tradeDate: '2026-10-${(i + 1).toString().padLeft(2, '0')}',
            totalEquity: 60,
            cashKrw: 60,
            positionsValue: 0,
            highWaterMark: 100,
            drawdown: -0.40,
            breakerLevel: BreakerLevel.stopped,
          ),
      ];
      EquitySnapshotStep step(List<String> releases) => nextEquitySnapshot(
        tradeDate: '2026-10-28',
        positionsValue: Decimal.zero,
        cashKrw: Decimal.fromInt(60),
        history: hist(25),
        regimeOf: (String _) => (null, false),
        releaseDates: releases,
      );
      expect(step(const <String>[]).row.breakerLevel, BreakerLevel.stopped);
      expect(
        step(const <String>['2026-10-28']).row.breakerLevel,
        BreakerLevel.halted,
      );
      // 10-27 이 휴일이어도(행 없음) 다음 날 10-28 에 반영 — 단, 여기는 10-26 다음이 10-28.
      final EquitySnapshotStep s = nextEquitySnapshot(
        tradeDate: '2026-10-28',
        positionsValue: Decimal.zero,
        cashKrw: Decimal.fromInt(60),
        history: <EquitySnapshotRow>[
          ...hist(25),
          ...hist(26).skip(25),
        ].where((EquitySnapshotRow r) => r.tradeDate != '2026-10-26').toList(),
        regimeOf: (String _) => (null, false),
        releaseDates: const <String>['2026-10-26'],
      );
      expect(s.row.breakerLevel, BreakerLevel.halted);
      expect(s.replay!.heldBars, 0);
      expect(
        step(const <String>['2026-10-29']).row.breakerLevel,
        BreakerLevel.stopped,
      );
      // 이미 앞에서 재개됐으면 그 뒤로 HALTED → 오늘(dd −40%) 다시 STOPPED 진입.
      final EquitySnapshotStep again = step(const <String>['2026-10-10']);
      expect(
        (again.row.breakerLevel, again.replay!.stoppedEnteredToday),
        (BreakerLevel.stopped, false),
      );
      // 지난날(10-10) 재개 → 10-11 다시 진입 → 오늘까지 유지 15봉 · 재개 없으면 25봉.
      expect(again.replay!.heldBars, 15);
      expect(step(const <String>[]).replay!.heldBars, 25);
    });
  });

  test('SEV1 건 — id = 그날 · 기한 3일 · 설명 = 날 · 낙폭 % · 절차(금액 0) · 알림 코드', () {
    final StoppedIncident i = stoppedIncidentOf(
      tradeDate: '2026-11-05',
      drawdown: -0.3512,
      nowUtc: DateTime.utc(2026, 11, 5, 11, 30),
    );
    expect(
      (i.incidentId, i.severity, i.category, i.occurredAtUtc, i.dueAtUtc),
      (
        'SEV1-BREAKER_STOPPED-2026-11-05',
        'SEV1',
        'BREAKER_STOPPED',
        DateTime.utc(2026, 11, 5, 11, 30),
        DateTime.utc(2026, 11, 8, 11, 30),
      ),
    );
    expect(i.description, startsWith('2026-11-05 드로다운 -35.12% — STOPPED 진입'));
    expect(i.description, contains('03_운영 §6-4b'));
    expect(kStoppedPostmortemDue, const Duration(days: 3));
    expect(
      (kBreakerStoppedAlertCode, kStoppedReleaseEligibleAlertCode),
      ('BREAKER_STOPPED', 'STOPPED_RELEASE_ELIGIBLE'),
    );
  });
}
