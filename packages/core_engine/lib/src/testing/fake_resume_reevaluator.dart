// 재개 재판정 포트 가짜(🆕 E14d1 · 설계 13 §8 R75 N7) — 항목별 답 · 부른 차례 · 던지기 주입.
//
// 🔴 테스트 전용 — 앱 코드(lib/)는 import 하지 않는다(배럴 `core_engine/testing.dart`).

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import '../resume/resume_judge.dart' show ResumeWorkItem;
import '../resume/resume_reevaluator.dart';

/// 재판정 가짜.
class FakeResumeReevaluator implements ResumeReevaluator {
  /// `work_id` → 할 일 있음(없으면 [fallback]).
  final Map<String, bool> answers = <String, bool>{};

  /// 답이 없는 항목의 값.
  bool fallback = true;

  /// 던질 `work_id`.
  final Set<String> throwingFor = <String>{};

  /// 부른 (work_id · 날).
  final List<(String, TradeDate)> calls = <(String, TradeDate)>[];

  @override
  Future<bool> actionNeeded(ResumeWorkItem item, TradeDate today) async {
    calls.add((item.workId, today));
    if (throwingFor.contains(item.workId)) {
      throw StateError('재판정 자료 없음: ${item.workId}');
    }
    return answers[item.workId] ?? fallback;
  }
}
