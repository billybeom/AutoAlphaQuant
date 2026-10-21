// M3-2 계획 스냅샷 저장소 — 미리보기 결과를 등록 대조용으로 잡아 둔다(06 M3-2 · 01 §14-5 · §14-7 · §14-8).
//
// 🔴 «부작용 0»(06 M3-1 ⓔ)의 예외가 아니다 — 스냅샷은 원장·명령 테이블이 아니라 **엔진 로컬 캐시**다.
// 🔵 설계 13 §8 R18 D-13(발주자 2026-10-21 · 추천안): planId = `pl_<계산 시각의 한국 날짜 yyyyMMdd>_<그날 순번 두 자리>`
//    (픽스처 `pl_20260901_10` 꼴) · 메모리 구현은 앱을 다시 켜면 비어 `findPlan` 이 null 을 준다.
// 🆕 E7b1(설계 13 §8 R22 D1~D3) — 정본 구현은 data_sync 의 SQLite 판(`plan_snapshot` · 배치 B)이다.
//    [save] 는 계획(outputs = `DepositPlan.toJson()`)과 **계산 입력 원값**([PlanInputs] · inputs JSON v1)을 함께 받는다.
//    입금 순번은 저장본에서 파생한다(재시작 뒤 PK 충돌 0) · `re_` 키(리밸런싱 미리보기)는 저장하지 않으므로 메모리 순번이다.

import 'package:domain_contracts/domain_contracts.dart' show DepositPlan;

import 'plan_inputs.dart';

/// 계획 스냅샷 저장소.
abstract interface class PlanSnapshotStore {
  /// [kstDay](`yyyyMMdd`)의 다음 순번(1부터).
  Future<int> nextSequence(String kstDay);

  /// [plan] 과 그 계산 입력 원값 [inputs] 를 함께 저장한다.
  Future<void> save(DepositPlan plan, {required PlanInputs inputs});

  /// 없으면 null.
  Future<DepositPlan?> find(String planId);
}

/// 메모리 구현(시험 · 앱 재시작 뒤에는 비어 있다).
class InMemoryPlanSnapshotStore implements PlanSnapshotStore {
  final Map<String, int> _seq = <String, int>{};
  final Map<String, DepositPlan> _plans = <String, DepositPlan>{};

  /// 저장된 입력 원값(시험이 본다).
  final Map<String, PlanInputs> inputs = <String, PlanInputs>{};

  @override
  Future<int> nextSequence(String kstDay) async =>
      _seq[kstDay] = (_seq[kstDay] ?? 0) + 1;

  @override
  Future<void> save(DepositPlan plan, {required PlanInputs inputs}) async {
    _plans[plan.planId] = plan;
    this.inputs[plan.planId] = inputs;
  }

  @override
  Future<DepositPlan?> find(String planId) async => _plans[planId];
}

/// [utc] 의 한국 날짜(`yyyyMMdd` · UTC+9 · 일광절약 없음).
String kstDay(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${k.year}${two(k.month)}${two(k.day)}';
}

/// 입금 계획 id — `pl_<한국 날짜>_<순번 두 자리>`(D-13).
String depositPlanId(DateTime computedAtUtc, int sequence) {
  if (sequence < 1) {
    throw ArgumentError.value(sequence, 'sequence', '1 이상이어야 한다');
  }
  return 'pl_${kstDay(computedAtUtc)}_${sequence.toString().padLeft(2, '0')}';
}
