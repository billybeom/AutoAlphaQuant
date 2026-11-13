// 재개 재판정 포트(06 X2-3 · 04 §3-1 v2.42 ③ · 청사진 X2 보강 (e) · 설계 13 §8 R75 N7).
//
// 🔴 재판정에 전략 판단이 없다 — 계획기 · 계절 판정을 재개일 as-of 로 다시 돌린 결과(할 일 있음 · 없음)만 돌려준다.
// 🔴 실물(월말 계획기 · 계절 판정 재실행 · child 계획을 다음 `kr_order` 가 읽는 대상 원천) = E14d2.
// 🔴 던지면 실행기는 그 항목을 건드리지 않고 «재판정 실패»로 세며 `RESUME_INCOMPLETE` 를 풀지 않는다.

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import 'resume_judge.dart' show ResumeWorkItem;

/// 재판정 포트 — 구현 = E14d2 · 시험 = `FakeResumeReevaluator`.
abstract interface class ResumeReevaluator {
  /// [item] 을 [today] as-of 로 다시 판정 — true = 할 일 있음(child 위임) · false = 할 일 없음.
  Future<bool> actionNeeded(ResumeWorkItem item, TradeDate today);
}
