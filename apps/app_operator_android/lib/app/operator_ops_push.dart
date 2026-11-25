// 🆕 미결 244 ⓐ ⓑ — 운영 폰 공유 표 push 배선 · 깨어남 뒤 실행(설계 13 §8 R271 O4 · O8 · 01 §8 미결 244 · R264 꼴).
//
// 🔵 한 번 = ① X2 미러 2표(`OpsMirrorPushJob` — 계획 미러 · 재개 회차 미러) ② X5 원격 사본 스탬프(`SupabaseStampSyncJob` — 대조 읽기 →
//    관계 → FORK 기록 · 재생성 · `op_push`). 원장 = 화면 상태의 원장 · 행 mode = 화면 상태의 실행 모드(`flags.runMode`).
// 🔴 리스 = 이 기기 id + 그 원장의 SUPABASE epoch(0 = 안 보낸다 — 모의 내부 · 첫 클레임 전) · 스탬프 재생성의 리스 판정 = 할 일이 있을 때만
//    `operatorLeaseGate(...).check()`(원격 = live · simBroker · 하루 한 번 꼴 — 화면 판정처럼 깨어남마다 RPC 를 부르지 않는다).
// 🔴 하루 재생성 상한 = 운영 설정 `migration.derived_resync_daily_cap`(못 읽음 = 스탬프 실행기 0 · 지어내지 않는다).
// 🔴 FORK 경보 = P0 `DERIVED_FORK`(바뀐 때만 · 출처 `derived_supabase`) · 🆕 push 실패 경보(미결 243 ⓒ · R273) = K344 P1
//    (낸 곳 `shared_push` · 읽기 모델 push 와 공용 · 한국 날 · 코드마다 한 건).

import 'package:core_engine/core_engine.dart' show LeaseVerdict;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' show RunMode;

import '../engine/lease_wiring.dart' show operatorLeaseGate;
import 'operator_runtime.dart';
import 'operator_view.dart';

/// 한 번의 보고(미러 · 스탬프).
class OperatorOpsPushReport {
  /// 만든다.
  const OperatorOpsPushReport({required this.mirrors, this.stamps});

  /// X2 미러 push.
  final OpsPushReport mirrors;

  /// X5 원격 사본 스탬프(읽기 포트 · 운영 설정이 없으면 null).
  final SupabaseStampReport? stamps;

  /// 사람이 볼 push 실패(미러 ∪ 스탬프 · 경보 = 미결 243 ⓒ).
  List<OpsTablePush> get failed => <OpsTablePush>[
    ...mirrors.failed,
    ...?stamps?.failed,
  ];
}

/// 🆕 한 번 push(포트 · 화면 상태가 다 있을 때만 · 없으면 null).
Future<OperatorOpsPushReport?> runOperatorOpsPush({
  required OperatorRuntime rt,
}) async {
  final OpsPusher? pusher = rt.opsPusher;
  final OperatorView? v = rt.view.value;
  if (pusher == null || v == null) return null;
  final RunMode mode = v.flags.runMode;
  final int epoch = SqliteLeaseGate(v.db, mode: mode, clock: rt.clock).epoch();
  final OpsPushReport mirrors = await OpsMirrorPushJob(
    pusher: pusher,
    status: SqliteResumeStatus(v.db, kr: rt.calendars.kr),
  ).run(deviceId: rt.deviceId, epoch: epoch, mode: mode);
  final LedgerStampReader? reader = rt.ledgerStampReader;
  final int? cap = rt.operations?.derivedResyncDailyCap;
  if (reader == null || cap == null || cap < 1) {
    return _alerted(rt, v, OperatorOpsPushReport(mirrors: mirrors));
  }
  final SupabaseStampReport stamps =
      await SupabaseStampSyncJob(
        v.db,
        clock: rt.clock,
        reader: reader,
        pusher: pusher,
        derivedResyncDailyCap: cap,
      ).run(
        deviceId: rt.deviceId,
        epoch: epoch,
        mode: mode,
        lease: () async {
          try {
            return await operatorLeaseGate(
              v.db,
              mode: mode,
              clock: rt.clock,
              remote: rt.leaseRemote,
            ).check();
          } on Object {
            return LeaseVerdict.unknown;
          }
        },
      );
  if (stamps.alerts.isNotEmpty) {
    await SqliteAlertSink(
      v.db,
      clock: rt.clock,
    ).emit(kSupabaseStampCheck, stamps.alerts);
  }
  return _alerted(
    rt,
    v,
    OperatorOpsPushReport(mirrors: mirrors, stamps: stamps),
  );
}

/// 🆕 미결 243 ⓒ(R273) — 사람이 볼 push 실패 → K344 P1(낸 곳 공용).
Future<OperatorOpsPushReport> _alerted(
  OperatorRuntime rt,
  OperatorView v,
  OperatorOpsPushReport report,
) async {
  final Set<String> alerts = sharedPushAlertCodes(ops: report.failed);
  if (alerts.isNotEmpty) {
    await SqliteAlertSink(
      v.db,
      clock: rt.clock,
    ).emit(kSharedPushAlertSource, alerts);
  }
  return report;
}
