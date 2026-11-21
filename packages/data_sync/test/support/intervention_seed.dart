// 🆕 E16j-a — 시험 받침: 개입 세션 행을 바로 넣는다(정정 · 새 기준점 커밋 = 5단계 관문 · 01 §8 미결 217 ⓐ).
import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart' show insertInterventionStep;
import 'package:sqlite3/sqlite3.dart';

/// 실행 창 안 세션(1~4단계 통과 · 3단계 저널 [journalId]) — [nowUtc] 기준 냉각 끝 1시간 뒤 · 실행 창 끝 23시간 앞.
void seedExecutableSession(
  Database db,
  String sessionId, {
  required DateTime nowUtc,
  String journalId = 'DEC-1',
}) {
  final DateTime journalAt = nowUtc.toUtc().subtract(
    kInterventionCooling + const Duration(hours: 1),
  );
  seedSessionSteps(db, sessionId, <(int, DateTime, String?)>[
    (1, journalAt.subtract(const Duration(minutes: 2)), null),
    (2, journalAt.subtract(const Duration(minutes: 1)), null),
    (kJournalStage, journalAt, journalId),
    (kCoolingStage, nowUtc.toUtc().subtract(const Duration(minutes: 30)), null),
  ]);
}

/// 통과 행들을 넣는다(단계 · 시각 · 결정).
void seedSessionSteps(
  Database db,
  String sessionId,
  List<(int, DateTime, String?)> passed, {
  InterventionOutcome last = InterventionOutcome.passed,
}) {
  for (int i = 0; i < passed.length; i++) {
    final (int stage, DateTime at, String? decision) = passed[i];
    insertInterventionStep(
      db,
      sessionId: sessionId,
      stage: stage,
      atUtc: at,
      outcome: i == passed.length - 1 ? last : InterventionOutcome.passed,
      decisionId: decision,
    );
  }
}
