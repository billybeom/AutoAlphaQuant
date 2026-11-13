// 잡 실행 기록 포트 가짜(🆕 E14c1 · 설계 13 §8 R73 K1) — 받은 행을 차례대로 담는다 · 던지기 주입.
//
// 🔴 테스트 전용 — 앱 코드(lib/)는 import 하지 않는다(배럴 `core_engine/testing.dart`).

import '../ops/job_run_log.dart';

/// 잡 실행 기록 가짜.
class FakeJobRunLog implements JobRunLog {
  /// 받은 행(차례대로).
  final List<JobRunEntry> entries = <JobRunEntry>[];

  /// 다음 기록에 던질 것(null = 안 던짐 · 던지면 행을 담지 않는다).
  Exception? throwing;

  @override
  Future<void> record(JobRunEntry entry) async {
    final Exception? t = throwing;
    if (t != null) throw t;
    entries.add(entry);
  }
}
