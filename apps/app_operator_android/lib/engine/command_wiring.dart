// 🆕 E11m-a — 회차 앞 명령 소비 조립(설계 13 §8 R274 · R272 Y5 · Y6 · 01 §10-8 · 01 §8 미결 244 ⓒ).
//
// 🔴 소비 자리 = 원격 리스를 끼우는 모드(live · simBroker — `leaseRemoteApplies`)이고 원격 원천 · 당김 · ack 포트가 다 있을 때만 ·
//    모의 내부(simInternal) = 원격 리스 0 → 소비 0(뷰어 = `command_status` 가 리스 만료를 보고 NO_OPERATOR) · 막음 0.
// 🔴 원장 = 기동 판정이 고른 지금 모드의 원장(파일 경계 — 다른 모드 명령 = 그 원장에 쓰지 않고 거부 ack).
// 🔴 리스 세대 = 그 원장 `sync_state` SUPABASE 행(op_push 미러와 같은 값) · 리스 확인 = 주문 잡과 같은 판정(`operatorLeaseGate`).
// 🔴 킬스위치 미체결 취소 경로 = 폰 버튼과 같은 값(지금 = 비움 · 실계좌 취소 = 트랙 C) — 소비기가 따로 짓지 않는다.

import 'package:core_engine/core_engine.dart' show LeaseVerdict, TrustedClock;
import 'package:data_sync/data_sync.dart'
    show
        CommandConsumeJob,
        CommandConsumeReport,
        CommandOpenReader,
        OpsPusher,
        SqliteLeaseGate;
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:trading_runtime/trading_runtime.dart' show JobCalendars;

import 'engine_boot.dart' show EngineReady;
import 'lease_wiring.dart'
    show LeaseRemoteOf, leaseRemoteApplies, operatorLeaseGate;
import 'operator_engine.dart' show CommandConsumeHook;

/// 🆕 회차 앞 명령 소비 한 번 — 포트 · 원천 하나라도 없으면 null(조립 밖 · 시험 = 소비 0).
CommandConsumeHook? commandConsumeHookOf({
  required CommandOpenReader? reader,
  required OpsPusher? pusher,
  required LeaseRemoteOf? leaseRemote,
  required String? deviceId,
  required TrustedClock trusted,
  required Clock clock,
  required JobCalendars calendars,
}) {
  if (reader == null || pusher == null || leaseRemote == null) return null;
  return (EngineReady ready) async {
    if (!leaseRemoteApplies(ready.runMode)) return null;
    final int epoch = SqliteLeaseGate(
      ready.db,
      mode: ready.runMode,
      clock: clock,
    ).epoch();
    final CommandConsumeReport r =
        await CommandConsumeJob(
          ready.db,
          clock: clock,
          trusted: trusted,
          kr: calendars.kr,
          reader: reader,
          pusher: pusher,
        ).run(
          deviceId: deviceId,
          epoch: epoch,
          runMode: ready.runMode,
          lease: () async {
            try {
              return await operatorLeaseGate(
                ready.db,
                mode: ready.runMode,
                clock: clock,
                remote: leaseRemote,
              ).check();
            } on Object {
              return LeaseVerdict.unknown;
            }
          },
        );
    return r;
  };
}
