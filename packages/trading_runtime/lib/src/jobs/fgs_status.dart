// FGS 상태 재료 → `FgsStatus`(E11p3b-3 · 설계 13 §8 R93 · 06 M1-15 · 앱 04 §5-6 `F-01`).
//
// 🔴 레벨 · 문구를 새로 짓지 않는다 — 엔진 읽기 모델이 이미 만든 라벨(킬스위치 `stateLabel` · 브레이커 `breakerLabel` ·
//    P0 알림 `title` · 차단 플래그 `label`)을 고른다. 문장 조립은 `buildFgsNotice`(R43 B8) 몫.
// 🔴 R93 레벨 대응(명세 없음 → 추천):
//    · 킬스위치 발동 = BLOCKED
//    · 브레이커 NORMAL = OK · ALERT · REDUCED = WATCH · HALTED = ACT · STOPPED = BLOCKED
//    · 열린 P0 알림 = ACT(+ `ops_p0` 채널 · 탭 = 그 알림)
//    · 차단 플래그(하나라도) = ACT — 주문이 막혀 있다
//    · 🆕 리뷰 3차 H1-4(설계 13 §8 R261) hold(`SafetyState.holds` — 기동은 하되 배치를 멈춤 · 하나라도) = ACT — 문구 = 엔진 짝 문장
//      `holdLabels` 첫째(사전 차례 · 짓지 않는다)
//    가장 무거운 레벨을 고르고, 같으면 킬스위치 → 정지 · 중지 브레이커 → P0 → 플래그 → hold → 경고 · 축소 브레이커 차례.
// 🆕 E15g(R110) — 모드 · 운영 방식은 재료에서 그대로 넘긴다(표지 문장 = `buildFgsNotice`).

import 'package:core_engine/core_engine.dart'
    show ExchangeCalendar, NextRebalance, nextRegularRebalance;
import 'package:domain_contracts/domain_contracts.dart';

import 'fgs_notice.dart' show FgsStatus;

/// FGS 상태 재료(엔진 읽기 모델 그대로).
class FgsFacts {
  /// 만든다.
  const FgsFacts({
    required this.safety,
    required this.runMode,
    required this.operatingMode,
    this.openP0,
    this.lastReconAtUtc,
    this.nextRebalanceInSessions,
  });

  /// 안전 상태(`SafetyRepository`).
  final SafetyState safety;

  /// 🆕 E15g — 실행 모드(🔴 필수).
  final RunMode runMode;

  /// 🆕 E15g — 운영 방식.
  final OperatingMode operatingMode;

  /// 가장 이른 열린 P0 알림(없으면 null).
  final AlertItem? openP0;

  /// 마지막 브로커 대사 시각.
  final DateTime? lastReconAtUtc;

  /// 다음 리밸런싱까지 KR 세션 수.
  final int? nextRebalanceInSessions;
}

/// 브레이커 단계 → 레벨(R93).
UiLevel breakerUiLevel(BreakerLevel b) => switch (b) {
  BreakerLevel.normal => UiLevel.ok,
  BreakerLevel.alert => UiLevel.watch,
  BreakerLevel.reduced => UiLevel.watch,
  BreakerLevel.halted => UiLevel.act,
  BreakerLevel.stopped => UiLevel.blocked,
};

const List<UiLevel> _severity = <UiLevel>[
  UiLevel.ok,
  UiLevel.info,
  UiLevel.watch,
  UiLevel.act,
  UiLevel.blocked,
];

/// 🔴 재료 → FGS 입력(R93).
FgsStatus fgsStatusOf(FgsFacts f) {
  final List<(UiLevel, String, int)> c = <(UiLevel, String, int)>[];
  final SafetyState s = f.safety;
  if (s.killSwitch.active) c.add((UiLevel.blocked, s.killSwitch.stateLabel, 0));
  final UiLevel b = breakerUiLevel(s.breakerLevel);
  if (b != UiLevel.ok) {
    final bool hard =
        s.breakerLevel == BreakerLevel.halted ||
        s.breakerLevel == BreakerLevel.stopped;
    c.add((b, s.breakerLabel, hard ? 1 : 5));
  }
  final AlertItem? p0 = f.openP0;
  if (p0 != null) c.add((UiLevel.act, p0.title, 2));
  if (s.activeFlags.isNotEmpty) {
    final List<BlockFlag> flags = <BlockFlag>[...s.activeFlags]
      ..sort((BlockFlag x, BlockFlag y) {
        final int t = x.setAt.compareTo(y.setAt);
        return t != 0 ? t : x.flagId.compareTo(y.flagId);
      });
    c.add((UiLevel.act, flags.first.label, 3));
  }
  // 🆕 R261(H1-4) — hold 동안 배치가 멈춘다(04 H-01 배너와 같은 짝 문장) — FGS 가 «정상»으로 남지 않게.
  if (s.holdLabels.isNotEmpty) c.add((UiLevel.act, s.holdLabels.first, 4));
  if (c.isEmpty) {
    return FgsStatus(
      level: UiLevel.ok,
      runMode: f.runMode,
      operatingMode: f.operatingMode,
      lastReconAtUtc: f.lastReconAtUtc,
      nextRebalanceInSessions: f.nextRebalanceInSessions,
    );
  }
  c.sort((x, y) {
    final int v = _severity.indexOf(y.$1).compareTo(_severity.indexOf(x.$1));
    return v != 0 ? v : x.$3.compareTo(y.$3);
  });
  return FgsStatus(
    level: c.first.$1,
    runMode: f.runMode,
    operatingMode: f.operatingMode,
    headline: c.first.$2,
    lastReconAtUtc: f.lastReconAtUtc,
    nextRebalanceInSessions: f.nextRebalanceInSessions,
    p0AlertId: p0?.alertId,
  );
}

/// 다음 정기 리밸런싱 집행일까지 KR 세션 수(R93) — 집행일 당일 = 0 · 달력 밖 = null.
int? sessionsUntilNextRebalance(ExchangeCalendar kr, TradeDate today) {
  try {
    // 오늘이 집행일이면 «앞 세션 = 판정일»에서 찾아야 오늘이 나온다.
    final NextRebalance? n = nextRegularRebalance(
      kr,
      kr.nthSessionBefore(today, 1),
    );
    if (n == null) return null;
    int count = 0;
    TradeDate d = today;
    while (d.yyyyMmDd.compareTo(n.planned.yyyyMmDd) < 0) {
      d = kr.nextSession(d);
      count++;
    }
    return count;
  } on StateError {
    return null;
  }
}
