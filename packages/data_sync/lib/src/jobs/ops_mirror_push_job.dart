// 🆕 미결 244 ⓐ — X2 미러 push 일(설계 13 §8 R271 O3 · O4 · 01 §8 미결 244 · 06 X2-7 · 13 R79 U3 · 계약 v1.40 §49 K356).
//
// 🔵 한 번 = `planned_work_mirror`(전 행 · 서버가 `row_version` 큰 쪽만 반영 · 같은 판 = 건너뜀) → `resume_run_mirror`(전 행 · 덮음 —
//    `updated_at` = 서버 시각이 뷰어 «정지» 판정의 신선도 · X2-7). 행 = `SqliteResumeStatus.mirrorPayload`(R79 U3 · 원문 0).
// 🔵 시점 = 운영 앱이 깨어남마다(읽기 모델 push 뒤 같은 칸) — `planned_work` · 재개 회차(R8 «리포트 · 미러 · 아카이브»)는 깨어남 안의
//    잡만 바꾸므로 «바뀔 때» = 그 깨어남 뒤 · 실패 = 다음 깨어남(지연 T=6h 수용 · 청사진 X2 ⑤ 권고 a).
// 🔴 리스가 없으면(기기 id 없음 · epoch 0) 아무것도 하지 않는다. 리스 거부 = 그 자리에서 멈춘다(뒤 표 = 시도 0).
// 🔴 로컬 상태 표 0(스키마 0) — 뷰어 신선도 = 서버 `updated_at` · 실패 = 보고서(경보 = 미결 243 ⓒ 자리 · K344 결).

import 'package:domain_contracts/domain_contracts.dart'
    show OpsPushTables, RunMode;

import '../local/resume_status.dart';
import '../supabase/supabase_ops_push.dart';
import 'ops_push_send.dart';

/// 한 번의 보고서(운영 폰 공유 표).
class OpsPushReport {
  /// 만든다.
  const OpsPushReport(this.tables, {this.noLease = false});

  /// 리스가 없어 하지 않았다.
  final bool noLease;

  /// 표마다(차례 = 보낸 차례).
  final List<OpsTablePush> tables;

  /// 사람이 볼 실패.
  List<OpsTablePush> get failed => <OpsTablePush>[
    for (final OpsTablePush t in tables)
      if (t.outcome == OpsPushOutcome.failed) t,
  ];

  @override
  String toString() =>
      noLease ? 'OpsPushReport(리스 없음)' : 'OpsPushReport($tables)';
}

/// 🆕 X2 미러 push 일.
class OpsMirrorPushJob {
  /// 만든다 — [status] = 이 원장의 재개 상태 원천.
  OpsMirrorPushJob({
    required this.pusher,
    required this.status,
    this.chunk = kOpsPushChunk,
  });

  /// push 포트.
  final OpsPusher pusher;

  /// 미러 행 원천.
  final SqliteResumeStatus status;

  /// 한 번에 보내는 행 수 상한.
  final int chunk;

  /// 한 번 돈다 — 이 기기 [deviceId] · 쥔 리스 [epoch] · 행 mode = [mode](화면 상태의 실행 모드).
  Future<OpsPushReport> run({
    required String? deviceId,
    required int epoch,
    required RunMode mode,
  }) async {
    if (deviceId == null || deviceId.isEmpty || epoch <= 0) {
      return const OpsPushReport(<OpsTablePush>[], noLease: true);
    }
    final ResumeMirrorPayload p;
    try {
      // 원격 epoch 은 묻지 않는다 — 서버가 같은 문장으로 리스를 다시 본다(낮은 epoch = LEASE_LOST).
      p = status.mirrorPayload(
        mode: mode,
        leaseEpoch: epoch,
        remoteEpoch: null,
      );
    } on Object catch (e) {
      return OpsPushReport(<OpsTablePush>[
        for (final String t in _tables)
          OpsTablePush(
            t,
            OpsPushOutcome.failed,
            reason: 'ROW:${e.runtimeType}',
          ),
      ]);
    }
    final List<OpsTablePush> out = <OpsTablePush>[];
    bool leaseGone = false;
    for (final (String table, List<Map<String, Object?>> rows)
        in <(String, List<Map<String, Object?>>)>[
          (OpsPushTables.plannedWorkMirror, p.plannedWork),
          (OpsPushTables.resumeRunMirror, p.resumeRuns),
        ]) {
      if (leaseGone) {
        out.add(OpsTablePush(table, OpsPushOutcome.notTried));
        continue;
      }
      final OpsTablePush r = await sendOpsRows(
        pusher,
        deviceId: deviceId,
        epoch: epoch,
        table: table,
        rows: rows,
        chunk: chunk,
      );
      out.add(r);
      if (r.leaseRejected) leaseGone = true;
    }
    return OpsPushReport(out);
  }

  static const List<String> _tables = <String>[
    OpsPushTables.plannedWorkMirror,
    OpsPushTables.resumeRunMirror,
  ];
}
