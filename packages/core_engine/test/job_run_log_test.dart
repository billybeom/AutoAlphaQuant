// E14c1 — 잡 실행 기록 값 꼴(설계 13 §8 R73 K1 · K2 · 02 v2.42 `job_run`).
//
// 🔵 잡는 것: ① 글자 = 02 CHECK 4 ② «돈 것» = 실패 빼고 · «성공» = 성공 · 지연 ③ 지연 = 끝 > 유예 끝(같은 시각 = 성공) ·
//    유예 끝 없음 = 성공 ④ 가짜 = 담기 · 던지기(담지 않음)
import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

void main() {
  final DateTime t = DateTime.utc(2026, 11, 13, 1);

  test('글자 = 02 job_run.status CHECK 4', () {
    expect(
      JobRunStatus.values.map((JobRunStatus s) => s.wire).toList(),
      <String>['SUCCESS', 'LATE', 'FAILED', 'HOLIDAY'],
    );
  });

  test('«돈 것» = 실패 빼고 · «성공» = 성공 · 지연', () {
    expect(
      JobRunStatus.values.where((JobRunStatus s) => s.done).toList(),
      <JobRunStatus>[
        JobRunStatus.success,
        JobRunStatus.late,
        JobRunStatus.holiday,
      ],
    );
    expect(
      JobRunStatus.values.where((JobRunStatus s) => s.succeeded).toList(),
      <JobRunStatus>[JobRunStatus.success, JobRunStatus.late],
    );
  });

  test('지연 = 끝 > 유예 끝 · 같은 시각 = 성공 · 유예 끝 없음 = 성공', () {
    JobRunStatus s(DateTime? d) =>
        successStatusOf(finishedAtUtc: t, deadlineUtc: d);
    expect(s(t.subtract(const Duration(seconds: 1))), JobRunStatus.late);
    expect(s(t), JobRunStatus.success);
    expect(s(t.add(const Duration(minutes: 1))), JobRunStatus.success);
    expect(s(null), JobRunStatus.success);
  });

  test('가짜 — 차례대로 담기 · 던지면 담지 않음', () async {
    final FakeJobRunLog log = FakeJobRunLog();
    final JobRunEntry e = JobRunEntry(
      rid: 'r',
      checkName: 'live-auto-kr_order',
      sessionDay: const TradeDate('2026-11-13'),
      startedAtUtc: t,
      finishedAtUtc: t,
      status: JobRunStatus.success,
    );
    await log.record(e);
    log.throwing = Exception('x');
    await expectLater(log.record(e), throwsException);
    expect(log.entries, <JobRunEntry>[e]);
  });
}
