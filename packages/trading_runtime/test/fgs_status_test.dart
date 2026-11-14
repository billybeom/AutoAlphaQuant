// E11p3b-3 — FGS 상태 재료 → 입력(설계 13 §8 R93) · 계약 표본(`safety_states.json` · `alerts_12.json`)으로 연다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show Market, frozenExchangeCalendar;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

List<Map<String, dynamic>> _rows(String name) =>
    ((jsonDecode(File('../domain_contracts/fixtures/$name').readAsStringSync())
                as Map<String, dynamic>)['rows']
            as List<dynamic>)
        .cast<Map<String, dynamic>>();

void main() {
  final List<SafetyState> safety = <SafetyState>[
    for (final Map<String, dynamic> r in _rows('safety_states.json'))
      SafetyState.fromJson(r),
  ];
  final AlertItem p0 = AlertItem.fromJson(
    _rows('alerts_12.json').firstWhere((r) => r['level'] == 'P0'),
  );
  final DateTime recon = DateTime.utc(2026, 11, 16, 0, 5);

  FgsStatus of(SafetyState s, {AlertItem? alert}) => fgsStatusOf(
    FgsFacts(
      runMode: RunMode.live,
      operatingMode: OperatingMode.autoTrade,
      safety: s,
      openP0: alert,
      lastReconAtUtc: recon,
      nextRebalanceInSessions: 3,
    ),
  );

  test('표본 차례 = NORMAL · ALERT · REDUCED · HALTED · STOPPED(킬스위치)', () {
    expect(safety.map((s) => s.breakerLevel), <BreakerLevel>[
      BreakerLevel.normal,
      BreakerLevel.alert,
      BreakerLevel.reduced,
      BreakerLevel.halted,
      BreakerLevel.stopped,
    ]);
    expect(safety[4].killSwitch.active, true);
  });

  test('🔴 정상 = OK · 문구 없음 · 대사 · D-n 그대로 → 정상 알림', () {
    final FgsStatus s = of(safety[0]);
    expect(s.level, UiLevel.ok);
    expect(s.headline, isNull);
    expect(s.p0AlertId, isNull);
    expect(s.lastReconAtUtc, recon);
    expect(s.nextRebalanceInSessions, 3);
    expect(buildFgsNotice(s).text, '정상 · 마지막 대사 09:05 · 다음 리밸런싱 D-3');
  });

  test('브레이커 단계 대응(R93)', () {
    expect(breakerUiLevel(BreakerLevel.normal), UiLevel.ok);
    expect(breakerUiLevel(BreakerLevel.alert), UiLevel.watch);
    expect(breakerUiLevel(BreakerLevel.reduced), UiLevel.watch);
    expect(breakerUiLevel(BreakerLevel.halted), UiLevel.act);
    expect(breakerUiLevel(BreakerLevel.stopped), UiLevel.blocked);
  });

  test('🔴 플래그(ACT)가 경보 브레이커(WATCH)보다 무겁다 — 문구 = 플래그 라벨', () {
    final FgsStatus s = of(safety[1]);
    expect(s.level, UiLevel.act);
    expect(s.headline, '분기 실사 기한이 다가옵니다');
  });

  test('🔴 같은 ACT 면 중지 브레이커가 P0 · 플래그보다 먼저 — P0 는 채널 · 링크로 남는다', () {
    final FgsStatus s = of(safety[3], alert: p0);
    expect(s.level, UiLevel.act);
    expect(s.headline, '중지');
    expect(s.p0AlertId, p0.alertId);
    expect(buildFgsNotice(s).channel, FgsChannel.opsP0);
  });

  test('P0 가 플래그보다 먼저(같은 ACT)', () {
    final FgsStatus s = of(safety[1], alert: p0);
    expect(s.headline, p0.title);
  });

  test('플래그 여럿 = 가장 이른 것(같은 시각 = id 차례)', () {
    final SafetyState noBreaker = safety[3].copyWith(
      breakerLevel: BreakerLevel.normal,
    );
    expect(of(noBreaker).headline, '일지가 비어 있습니다');
  });

  test('🔴 킬스위치 = BLOCKED · 문구 = 킬스위치 라벨(정지 브레이커보다 먼저)', () {
    final FgsStatus s = of(safety[4]);
    expect(s.level, UiLevel.blocked);
    expect(s.headline, '작동 중');
    final SafetyState off = safety[4].copyWith(
      killSwitch: safety[4].killSwitch.copyWith(active: false),
    );
    expect(of(off).level, UiLevel.blocked);
    expect(of(off).headline, '정지');
  });

  test('P0 만 있어도 ACT · 문구 = 알림 제목', () {
    final FgsStatus s = of(safety[0], alert: p0);
    expect(s.level, UiLevel.act);
    expect(s.headline, p0.title);
  });

  group('다음 리밸런싱까지 세션 수', () {
    final kr = frozenExchangeCalendar(Market.kr);
    int? d(String day) => sessionsUntilNextRebalance(kr, TradeDate(day));

    test('🔴 집행일 당일 = 0 · 판정일(월 마지막 세션) = 1 · 그 앞 = 세션 수', () {
      expect(d('2026-12-01'), 0); // 11-30(월) 판정 → 12-01 집행
      expect(d('2026-11-30'), 1);
      expect(d('2026-11-27'), 2);
    });

    test('주말 = 다음 세션부터 센다', () {
      expect(d('2026-11-28'), 2);
      expect(d('2026-11-29'), 2);
    });

    test('집행일 다음 날 = 다음 달 회차', () {
      expect(d('2026-12-02'), greaterThan(15));
    });

    test('달력 밖 = null', () {
      expect(d('2099-06-15'), isNull);
    });
  });
}
