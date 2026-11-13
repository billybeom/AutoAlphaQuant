// 잡 실행 기록 포트 · 값 꼴(02 v2.42 `job_run` · 04 §3-1 v2.42 ④ · 설계 13 §8 R70 D4 · R73 K1).
//
// 🔴 여기에 두는 까닭 — 기록하는 쪽(`runJob`)은 trading_runtime, 구현(SQLite)은 data_sync 다. data_sync →
//    trading_runtime 은 01 §1-1 을 어기므로 둘 다 의존하는 core_engine 에 포트를 둔다(하트비트 포트와 같은 수).
// 🔴 append-only · 회차가 끝날 때 1행(끝나지 않은 회차 = 행 없음 = 성공 아님) · 해시 모집단 밖.

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

/// 회차 결과(02 `job_run.status` CHECK 글자).
enum JobRunStatus {
  /// 유예 안에 성공.
  success('SUCCESS'),

  /// 유예를 넘겨 성공(워치독 «지연»).
  late('LATE'),

  /// 실패(본체 예외 · 알림 발송 실패 · 달력 범위 밖 · 기록 실패).
  failed('FAILED'),

  /// KR 비세션 — 본체를 돌리지 않았다.
  holiday('HOLIDAY');

  const JobRunStatus(this.wire);

  /// DDL 글자.
  final String wire;

  /// «돈 것»인가(놓친 회차 판정 · 성공 · 지연 · 휴장).
  bool get done => this != JobRunStatus.failed;

  /// 성공인가(성공 · 지연 — 갭의 «마지막 성공 거래일»).
  bool get succeeded =>
      this == JobRunStatus.success || this == JobRunStatus.late;
}

/// 회차 1행.
class JobRunEntry {
  /// 행을 만든다.
  const JobRunEntry({
    required this.rid,
    required this.checkName,
    required this.sessionDay,
    required this.startedAtUtc,
    required this.finishedAtUtc,
    required this.status,
  });

  /// 회차 id(시작 · 끝 핑과 같은 값).
  final String rid;

  /// 체크 이름(`{sim|live}-{auto|advisory}-{잡}`).
  final String checkName;

  /// 그 잡의 세션일.
  final TradeDate sessionDay;

  /// 시작 시각.
  final DateTime startedAtUtc;

  /// 끝 시각.
  final DateTime finishedAtUtc;

  /// 결과.
  final JobRunStatus status;
}

/// 성공 회차의 결과 — 끝 > 유예 끝이면 지연(같은 시각 = 성공) · 유예 끝 없음 = 성공.
JobRunStatus successStatusOf({
  required DateTime finishedAtUtc,
  required DateTime? deadlineUtc,
}) => deadlineUtc != null && finishedAtUtc.isAfter(deadlineUtc)
    ? JobRunStatus.late
    : JobRunStatus.success;

/// 잡 실행 기록 포트 — 구현 = data_sync `SqliteJobRunLog` · 시험 = `FakeJobRunLog`.
abstract interface class JobRunLog {
  /// 회차 1행을 남긴다(실패하면 예외 — 잡이 FAILED 로 바꾼다).
  Future<void> record(JobRunEntry entry);
}
