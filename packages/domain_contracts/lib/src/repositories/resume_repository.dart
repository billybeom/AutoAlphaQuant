// 01 §4-1 — X2 재개 읽기 창구.

import '../dto/resume.dart';

/// 최근 재개 리포트 · 계획된 작업 목록.
abstract interface class ResumeRepository {
  /// 🔴 `ResumeReport` 에는 손익 필드가 없다(01 §2-7).
  Stream<ResumeReport?> watchLatest();

  Stream<List<PlannedWorkSummary>> watchPlannedWork();
}
