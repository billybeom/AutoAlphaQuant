// 🆕 E15e1 — M1-22 실전 드라이런 관찰 창(설계 13 §8 R89 AC2~AC8 · 앱 06 M1-22 · 01 §10-2 G-43).

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

/// 실전 커밋 = 01-12(화) 15:00(09:10 뒤 — 그날 회차 없음).
final DateTime _since = _k('2027-01-12', 15);

final LiveObservationConfig _two = LiveObservationConfig(
  requiredTradingDays: 2,
);

/// 그날 09:10 회차 + 09:20 대사.
List<LiveObservationRun> _runs(Iterable<String> days, {bool ok = true}) =>
    <LiveObservationRun>[
      for (final String d in days)
        LiveObservationRun(d, _k(d, 9, 10), succeeded: ok),
    ];
List<LiveObservationRecon> _recons(
  Iterable<String> days, {
  bool matched = true,
}) => <LiveObservationRecon>[
  for (final String d in days)
    LiveObservationRecon(_k(d, 9, 20), matched: matched),
];

LiveObservationFacts _facts({
  DateTime? asOf,
  RunMode? runMode = RunMode.live,
  ExecPolicy? exec = ExecPolicy.dryRun,
  DateTime? since,
  bool noSince = false,
  List<LiveObservationRun> runs = const <LiveObservationRun>[],
  List<LiveObservationRecon> recons = const <LiveObservationRecon>[],
  int unknown = 0,
  bool kill = false,
  List<String> flags = const <String>[],
}) => LiveObservationFacts(
  asOfUtc: asOf ?? _k('2027-01-14', 18),
  runMode: runMode,
  execPolicy: exec,
  currentSinceUtc: noSince ? null : (since ?? _since),
  runs: runs,
  recons: recons,
  unknownOrders: unknown,
  killSwitchActive: kill,
  blockingFlags: flags,
);

LiveObservationReport _judge(
  LiveObservationFacts f, [
  LiveObservationConfig? c,
]) => judgeLiveObservation(f, kr: _kr, config: c ?? _two);

const List<String> _two13 = <String>['2027-01-13', '2027-01-14'];

void main() {
  test('관찰 중 아님 — 모드 없음 · 실전 집행 · 모의 · 시작점 없음 = VM · 칩 줄 없음', () {
    for (final LiveObservationFacts f in <LiveObservationFacts>[
      _facts(runMode: null, exec: null),
      _facts(exec: ExecPolicy.execute),
      _facts(runMode: RunMode.simInternal, exec: ExecPolicy.execute),
      _facts(runMode: RunMode.simBroker),
      _facts(noSince: true),
    ]) {
      final LiveObservationReport r = _judge(
        LiveObservationFacts(
          asOfUtc: f.asOfUtc,
          runMode: f.runMode,
          execPolicy: f.execPolicy,
          currentSinceUtc: f.currentSinceUtc,
          runs: _runs(_two13),
          recons: _recons(_two13),
          unknownOrders: 0,
          killSwitchActive: false,
          blockingFlags: const <String>[],
        ),
      );
      expect(r.observing, isFalse);
      expect(r.promotionAvailable, isFalse);
      expect(r.vm, isNull);
      expect(r.promotionLabel, isNull);
    }
  });

  test('무결 이틀 = 승격 가능 · VM · 칩 줄 · 마감 문구 · «DRY_RUN» 글자 0', () {
    final LiveObservationReport r = _judge(
      _facts(runs: _runs(_two13), recons: _recons(_two13)),
    );
    expect(r.observing, isTrue);
    expect(r.observedTradingDays, 2);
    expect(r.promotionAvailable, isTrue);
    expect(r.block, isNull);
    expect(r.promotionLabel, '승격 가능 — 무결 거래일을 채웠습니다(2/2)');
    final LiveDryRunObservationVm vm = r.vm!;
    expect(vm.observedTradingDays, 2);
    expect(vm.requiredTradingDays, 2);
    expect(vm.progressText, '무결 거래일 2/2');
    expect(vm.promotionAvailable, isTrue);
    expect(
      vm.stateLabel,
      '실전 관찰 중 · 정기 리밸런싱 2027-02-01 09:10 전에 승격해야 첫 주문이 나갑니다',
    );
    for (final String s in <String>[
      vm.progressText,
      vm.stateLabel,
      r.promotionLabel!,
    ]) {
      expect(s, isNot(contains('DRY_RUN')));
    }
  });

  test('하루 = 승격 불가(픽스처 문구 1/2)', () {
    final LiveObservationReport r = _judge(
      _facts(runs: _runs(_two13.take(1)), recons: _recons(_two13.take(1))),
    );
    expect(r.promotionAvailable, isFalse);
    expect(r.block, LiveObservationBlock.notEnoughDays);
    expect(r.promotionLabel, '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)');
    expect(r.vm!.progressText, '무결 거래일 1/2');
    expect(r.vm!.promotionAvailable, isFalse);
  });

  test('오늘 회차가 아직 없으면 끊지 않는다', () {
    expect(
      _judge(
        _facts(
          asOf: _k('2027-01-14', 8),
          runs: _runs(_two13.take(1)),
          recons: _recons(_two13.take(1)),
        ),
      ).observedTradingDays,
      1,
    );
  });

  test('🔴 최근 연속 — 앞에서 채워도 한 세션 빠지면 다시 센다', () {
    const List<String> days = <String>[
      '2027-01-13',
      '2027-01-14',
      '2027-01-18',
    ];
    final LiveObservationReport r = _judge(
      _facts(
        asOf: _k('2027-01-18', 18),
        runs: _runs(days),
        recons: _recons(days),
      ),
    );
    expect(r.observedTradingDays, 1);
    expect(r.promotionAvailable, isFalse);
  });

  test('실패 회차 · 대사 불일치 · 대사 없음(15:00 뒤 배치 없음) = 무결 아님', () {
    final List<LiveObservationFacts> bad = <LiveObservationFacts>[
      _facts(
        runs: <LiveObservationRun>[
          ..._runs(_two13.take(1)),
          ..._runs(_two13.skip(1), ok: false),
        ],
        recons: _recons(_two13),
      ),
      _facts(
        runs: _runs(_two13),
        recons: <LiveObservationRecon>[
          ..._recons(_two13),
          LiveObservationRecon(_k('2027-01-14', 15, 45), matched: false),
        ],
      ),
      _facts(runs: _runs(_two13), recons: _recons(_two13.take(1))),
    ];
    for (final LiveObservationFacts f in bad) {
      final LiveObservationReport r = _judge(f);
      expect(r.observedTradingDays, 1);
      expect(r.promotionAvailable, isFalse);
    }
  });

  test('시작점 앞 회차 · 대사는 세지 않는다(같은 날 커밋 앞)', () {
    // 01-13 10:00 커밋 — 그날 09:10 회차 · 09:20 대사는 커밋 앞.
    final DateTime at = _k('2027-01-13', 10);
    final LiveObservationReport early = _judge(
      _facts(since: at, runs: _runs(_two13), recons: _recons(_two13)),
    );
    expect(early.observedTradingDays, 1);
    // 회차만 커밋 앞(대사는 뒤) — 역시 세지 않는다.
    final LiveObservationReport runOnly = _judge(
      _facts(
        since: at,
        runs: _runs(_two13),
        recons: <LiveObservationRecon>[
          LiveObservationRecon(_k('2027-01-13', 11), matched: true),
          ..._recons(_two13.skip(1)),
        ],
      ),
    );
    expect(runOnly.observedTradingDays, 1);
    // 대사만 커밋 앞(회차는 뒤) — 역시 세지 않는다.
    final LiveObservationReport reconOnly = _judge(
      _facts(
        since: at,
        runs: <LiveObservationRun>[
          LiveObservationRun(
            '2027-01-13',
            _k('2027-01-13', 10, 30),
            succeeded: true,
          ),
          ..._runs(_two13.skip(1)),
        ],
        recons: _recons(_two13),
      ),
    );
    expect(reconOnly.observedTradingDays, 1);
  });

  test('강등 뒤 = 현재 행 시각부터 다시(앞 무결 날 무시)', () {
    const List<String> days = <String>[
      '2027-01-13',
      '2027-01-14',
      '2027-01-15',
      '2027-01-19',
    ];
    final LiveObservationReport r = _judge(
      _facts(
        since: _k('2027-01-18', 10),
        asOf: _k('2027-01-19', 18),
        runs: _runs(days),
        recons: _recons(days),
      ),
    );
    expect(r.observedTradingDays, 1);
  });

  test('휴장 · 주말은 건너뛰고 끊지 않는다(설 02-08 · 02-09)', () {
    const List<String> days = <String>['2027-02-05', '2027-02-10'];
    final LiveObservationReport r = _judge(
      _facts(
        since: _k('2027-02-05', 8),
        asOf: _k('2027-02-10', 18),
        runs: _runs(days),
        recons: _recons(days),
      ),
    );
    expect(r.observedTradingDays, 2);
    expect(r.promotionAvailable, isTrue);
    expect(
      r.vm!.stateLabel,
      '실전 관찰 중 · 정기 리밸런싱 2027-03-02 09:10 전에 승격해야 첫 주문이 나갑니다',
    );
  });

  group('승격을 막는 사유(AC5 · 차례 = 킬스위치 → 플래그 → UNKNOWN → 일수)', () {
    LiveObservationReport blocked({
      bool kill = false,
      List<String> flags = const <String>[],
      int unknown = 0,
    }) => _judge(
      _facts(
        runs: _runs(_two13),
        recons: _recons(_two13),
        kill: kill,
        flags: flags,
        unknown: unknown,
      ),
    );

    test('킬스위치', () {
      final LiveObservationReport r = blocked(kill: true, unknown: 2);
      expect(r.promotionAvailable, isFalse);
      expect(r.vm!.promotionAvailable, isFalse);
      expect(r.block, LiveObservationBlock.killSwitch);
      expect(r.promotionLabel, '승격 불가 — 킬스위치가 켜져 있습니다');
    });

    test('주문 차단 플래그', () {
      final LiveObservationReport r = blocked(
        flags: <String>['RECON_MISMATCH'],
        unknown: 2,
      );
      expect(r.block, LiveObservationBlock.tradingBlock);
      expect(r.promotionLabel, '승격 불가 — 주문 차단 플래그 1개');
    });

    test('확인 안 된 주문', () {
      final LiveObservationReport r = blocked(unknown: 2);
      expect(r.block, LiveObservationBlock.unknownOrders);
      expect(r.promotionLabel, '승격 불가 — 확인 안 된 주문 2건');
      expect(r.observedTradingDays, 2);
    });
  });

  group('설정(AC6 — 기본값 없음 · 리터럴 grep 0)', () {
    test('일수 = 설정 값 · 넘친 날은 VM 수에만 · 문구는 n ≤ m', () {
      final LiveObservationReport three = _judge(
        _facts(runs: _runs(_two13), recons: _recons(_two13)),
        LiveObservationConfig(requiredTradingDays: 3),
      );
      expect(three.promotionAvailable, isFalse);
      expect(three.promotionLabel, '승격 불가 — 무결 거래일이 아직 모자랍니다(2/3)');
      final LiveObservationReport one = _judge(
        _facts(runs: _runs(_two13), recons: _recons(_two13)),
        LiveObservationConfig(requiredTradingDays: 1),
      );
      expect(one.observedTradingDays, 2);
      expect(one.vm!.observedTradingDays, 2);
      expect(one.vm!.progressText, '무결 거래일 1/1');
      expect(
        () => LiveObservationConfig(requiredTradingDays: 0),
        throwsArgumentError,
      );
    });

    test('🔴 lib 에 관찰 일수 숫자를 적지 않는다(06 M1-22 «리터럴 grep 0»)', () {
      final RegExp literal = RegExp(
        r'requiredTradingDays\s*[:=]\s*\d|live_dry_run_observation_trading_days\D{0,8}\d',
      );
      final List<String> hits = <String>[
        for (final FileSystemEntity e in Directory(
          'lib',
        ).listSync(recursive: true))
          if (e is File && e.path.endsWith('.dart'))
            for (final String line in e.readAsLinesSync())
              if (literal.hasMatch(line)) '${e.path}: $line',
      ];
      expect(hits, isEmpty);
      expect(
        kLiveDryRunObservationKey,
        'operations.live_dry_run_observation_trading_days',
      );
    });
  });

  test('오늘이 정기 집행일이면 오늘을 마감으로 말한다', () {
    expect(
      _judge(_facts(asOf: _k('2027-02-01', 8))).vm!.stateLabel,
      '실전 관찰 중 · 정기 리밸런싱 2027-02-01 09:10 전에 승격해야 첫 주문이 나갑니다',
    );
    expect(
      _judge(_facts(asOf: _k('2027-01-29', 18))).vm!.stateLabel,
      contains('2027-02-01'),
    );
  });

  test('달력 범위 끝 날(2027-12-30) — 다음 세션을 묻지 않고 답한다 · 마감 날짜 없음 문구', () {
    const List<String> days = <String>['2027-12-29', '2027-12-30'];
    final LiveObservationReport r = _judge(
      _facts(
        since: _k('2027-12-28', 16),
        asOf: _k('2027-12-30', 18),
        runs: _runs(days),
        recons: _recons(days),
      ),
    );
    expect(r.observedTradingDays, 2);
    expect(r.vm!.stateLabel, '실전 관찰 중');
  });
}
