// FGS 상태 원천(E11p3c-4 · 설계 13 §8 R102 · R94 · 앱 04 §5-6 `F-01`) — 깨어남이 끝날 때 상시 알림에 띄울 상태.
//
// 🔴 레벨 · 문구를 새로 짓지 않는다 — 재료는 엔진 읽기 모델 그대로(안전 상태 `SqliteSafetyRepository` · 알림 인박스 ·
//    마지막 브로커 대사 · 다음 리밸런싱) → `fgsStatusOf`(R94).
// 🔴 기동 거부 = BLOCKED · 문구 = 엔진 거부 코드 그대로(`SAF-405` 등) — 앞 깨어남의 «정상»이 남지 않게. 사람이 읽는 거부
//    문장은 엔진 몫(코어 글자 표 · 여기서 짓지 않는다).
// 🔴 온보딩 미완 = 띄우지 않는다(아직 아무것도 돌지 않았다 · Kotlin 이 앱 이름만 띄운다 · E11p2).
// 🔵 신뢰 시각 = 모름(E11k 전) — 해제 진행 게이지가 «모름»으로 나온다(지어내지 않는다).

import 'package:core_engine/core_engine.dart' show TrustedClock, alertInboxOf;
import 'package:data_sync/data_sync.dart'
    show SqliteSafetyRepository, lastBrokerReconUtc, storedAlerts;
import 'package:domain_contracts/domain_contracts.dart'
    show AlertItem, AlertLevel, Clock, UiLevel;
import 'package:trading_runtime/trading_runtime.dart'
    show
        FgsFacts,
        FgsStatus,
        JobCalendars,
        fgsStatusOf,
        kstDateOf,
        sessionsUntilNextRebalance;

import 'engine_boot.dart' show EngineReady, EngineRejected;

/// 신뢰 시각 «모름»(E11k 전).
class UnknownTrustedClock implements TrustedClock {
  /// 만든다.
  const UnknownTrustedClock();

  @override
  DateTime? trustedNowUtc() => null;
}

/// 🔴 가장 이른 **열린**(수신 확인 전) P0 — 없으면 null.
AlertItem? earliestOpenP0(Iterable<AlertItem> inbox) {
  AlertItem? best;
  for (final AlertItem a in inbox) {
    if (a.level != AlertLevel.p0) continue;
    if (a.ack?.acked ?? false) continue;
    final AlertItem? b = best;
    if (b == null ||
        a.raisedAt.isBefore(b.raisedAt) ||
        (a.raisedAt == b.raisedAt && a.alertId.compareTo(b.alertId) < 0)) {
      best = a;
    }
  }
  return best;
}

/// 🔴 준비된 원장의 FGS 상태(R94 재료 그대로).
FgsStatus fgsStatusForReady(
  EngineReady ready, {
  required JobCalendars calendars,
  required Clock clock,
}) {
  final DateTime now = clock.nowUtc();
  return fgsStatusOf(
    FgsFacts(
      safety: SqliteSafetyRepository(
        ready.db,
        mode: ready.runMode,
        clock: clock,
        trusted: const UnknownTrustedClock(),
      ).state(),
      openP0: earliestOpenP0(
        alertInboxOf(
          rows: storedAlerts(ready.db),
          nowUtc: now.toUtc(),
          min: AlertLevel.p0,
        ),
      ),
      lastReconAtUtc: lastBrokerReconUtc(ready.db),
      nextRebalanceInSessions: sessionsUntilNextRebalance(
        calendars.kr,
        kstDateOf(now),
      ),
    ),
  );
}

/// 🔴 기동 거부의 FGS 상태 — BLOCKED · 문구 = 엔진 거부 코드(차례 그대로).
FgsStatus fgsStatusForRejected(EngineRejected rejected) =>
    FgsStatus(level: UiLevel.blocked, headline: rejected.triggered.join(' · '));
