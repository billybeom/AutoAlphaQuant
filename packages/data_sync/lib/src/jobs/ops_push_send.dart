// 🆕 미결 244 — 운영 폰 공유 표 한 표 보내기 · 결과 갈래(설계 13 §8 R271 O1 · O9 · 01 §8 미결 244 · 계약 v1.40 §49 K356 · K357).
//
// 🔵 한 표의 행을 [kOpsPushChunk] 행씩 **차례 그대로** `op_push` 로 보낸다(한 호출 = 한 트랜잭션 · 앞 묶음만 들어갈 수 있다 —
//    날 오름차순으로 넘기면 부분 성공 = 앞쪽만 · 다음 판정이 이어 간다). 빈 행 = 호출 0 · OK.
// 🔵 갈래 = 읽기 모델 push(R263 C3 · K344)와 같은 결 — 사람이 볼 실패(failed) = 시크릿 차단 · `OPS_PUSH_ROWS_INVALID` ·
//    `OPS_PUSH_TABLE_UNKNOWN` · 응답 꼴(조치 = 원인 확인 · 앱 업데이트 · 부트스트랩 다시) / 다음 깨어남에 다시(lag) = 망 · 서버 ·
//    로그인 · 연결 칸 · 리스 거부(경보 0 — 경보 피로).
// 🔵 🆕 E11m(`command_ack`)이 [sendOpsRows] · [OpsTablePush] 를 그대로 쓴다.

import 'package:domain_contracts/domain_contracts.dart'
    show LeaseRpcResultCodes, OpsPushResultCodes;

import '../supabase/supabase_ops_push.dart';

/// 한 번에 보내는 행 수 상한(`rm_push` 와 같은 값).
const int kOpsPushChunk = 200;

/// 표 하나의 결과 갈래.
enum OpsPushOutcome {
  /// 받아들여짐(빈 행 포함).
  ok,

  /// 다음에 다시(망 · 서버 · 로그인 · 연결 칸 · 리스 · 원천 아직).
  lag,

  /// 사람이 볼 일(시크릿 차단 · 행 틀림 · 표 모름 · 응답 꼴 · 행을 못 만듦).
  failed,

  /// 리스 거부 뒤라 시도하지 않음.
  notTried,
}

/// 표 하나의 결과(🔴 행 값 0).
class OpsTablePush {
  /// 만든다.
  const OpsTablePush(
    this.table,
    this.outcome, {
    this.rows = 0,
    this.accepted = 0,
    this.skipped = 0,
    this.reason,
  });

  /// 표 이름(`OpsPushTables` 값).
  final String table;

  /// 갈래.
  final OpsPushOutcome outcome;

  /// 보낸(보내려던) 행 수.
  final int rows;

  /// 넣거나 바꾼 행 수(합).
  final int accepted;

  /// 건너뛴 행 수(합).
  final int skipped;

  /// 사유(서버 코드 · 실패 이름 · 빌더 사유 — 🔴 값 0).
  final String? reason;

  /// 리스 거부로 멈췄다(뒤 표 = 시도 0).
  bool get leaseRejected => isOpsLeaseCode(reason);

  @override
  String toString() =>
      '$table ${outcome.name}${reason == null ? '' : ' $reason'} $accepted/$skipped';
}

/// 리스 거부 코드인가(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`).
bool isOpsLeaseCode(String? reason) =>
    reason == LeaseRpcResultCodes.lost ||
    reason == LeaseRpcResultCodes.deviceNotEligible;

/// 사람이 볼 실패인가(나머지 = 다음 깨어남에 다시 · 경보 0).
bool isOpsPushFailure(OpsPushResult r) {
  if (r.code != null) return OpsPushResultCodes.values.contains(r.code);
  return r.failure == OpsPushFailure.secretBlocked ||
      r.failure == OpsPushFailure.badResponse;
}

/// 🆕 한 표를 [chunk] 행씩 차례대로 보낸다 — 첫 거부 · 실패에서 멈춘다(앞 묶음은 이미 들어갔을 수 있다).
Future<OpsTablePush> sendOpsRows(
  OpsPusher pusher, {
  required String deviceId,
  required int epoch,
  required String table,
  required List<Map<String, Object?>> rows,
  int chunk = kOpsPushChunk,
}) async {
  if (chunk < 1) throw ArgumentError.value(chunk, 'chunk');
  int accepted = 0;
  int skipped = 0;
  for (int i = 0; i < rows.length; i += chunk) {
    final OpsPushResult r = await pusher.push(
      deviceId: deviceId,
      epoch: epoch,
      table: table,
      rows: rows.sublist(i, i + chunk > rows.length ? rows.length : i + chunk),
    );
    if (r.ok) {
      accepted += r.accepted;
      skipped += r.skipped;
      continue;
    }
    return OpsTablePush(
      table,
      isOpsPushFailure(r) ? OpsPushOutcome.failed : OpsPushOutcome.lag,
      rows: rows.length,
      accepted: accepted,
      skipped: skipped,
      reason: r.code ?? r.failure!.name,
    );
  }
  return OpsTablePush(
    table,
    OpsPushOutcome.ok,
    rows: rows.length,
    accepted: accepted,
    skipped: skipped,
  );
}
