// M3-2 계획 스냅샷의 SQLite 판 — 로컬 원장 파일의 `plan_snapshot`(배치 B · 설계 13 §8 R22 D1~D3 · E7b1).
//
// 🔴 스냅샷은 원장이 아니라 **엔진 로컬 캐시**다 — day_hash·아카이브 모집단 밖이고 정리하지 않는다(R22 D12).
//    그래도 같은 원장 파일에 두므로 모의(`ledger_sim.sqlite`)에서 만든 계획은 실계좌 파일에서 보이지 않는다.
// 🔴 outputs = `DepositPlan.toJson()` 그대로(되살리면 같은 DTO) · inputs = `PlanInputs` JSON v1(R22 D2).
// 🔴 입금 순번은 저장본에서 파생한다 — 그날(`pl_<yyyyMMdd>_NN`) 저장된 최대 순번과 이 연결이 이미 나눠 준
//    순번 중 큰 값 + 1(R22 D3 · 재시작 뒤 PK 충돌 0). `re_` 키(리밸런싱 미리보기)는 저장하지 않으므로 메모리 순번이다.
// 🔴 바인딩(`consumed_by_decision_id`)은 등록 처리(E7b2)가 쓴다 — 이 저장소는 만들지도 지우지도 않는다.

import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show PlanInputs, PlanSnapshotStore;
import 'package:domain_contracts/domain_contracts.dart' show DepositPlan;
import 'package:sqlite3/sqlite3.dart';

/// `plan_snapshot` 을 쓰는 [PlanSnapshotStore].
final class SqlitePlanSnapshotStore implements PlanSnapshotStore {
  SqlitePlanSnapshotStore(this._db);

  final Database _db;
  final Map<String, int> _issued = <String, int>{};

  @override
  Future<int> nextSequence(String kstDay) async {
    // `re_` 키는 저장되는 계획이 없으므로 저장본 최대값이 늘 0 — 메모리 순번만 남는다.
    final int stored = _maxStoredSequence(kstDay);
    final int issued = _issued[kstDay] ?? 0;
    final int next = (stored > issued ? stored : issued) + 1;
    _issued[kstDay] = next;
    return next;
  }

  /// 그날 저장된 입금 계획의 최대 순번(없으면 0). `GLOB` 은 `_` 를 글자 그대로 본다(`LIKE` 와 다르다).
  int _maxStoredSequence(String kstDay) {
    int max = 0;
    final String prefix = 'pl_${kstDay}_';
    for (final Row r in _db.select(
      'SELECT plan_id FROM plan_snapshot WHERE plan_id GLOB ?',
      <Object>['$prefix*'],
    )) {
      final int? n = int.tryParse(
        (r['plan_id'] as String).substring(prefix.length),
      );
      if (n != null && n > max) max = n;
    }
    return max;
  }

  @override
  Future<void> save(DepositPlan plan, {required PlanInputs inputs}) async {
    _db.execute(
      'INSERT INTO plan_snapshot (plan_id, kind, computed_at, as_of_trade_date, '
      'expires_at, inputs, outputs, config_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      <Object>[
        plan.planId,
        'DEPOSIT',
        plan.computedAt.toUtc().toIso8601String(),
        plan.asOfTradeDate.yyyyMmDd,
        plan.expiresAt.toUtc().toIso8601String(),
        jsonEncode(inputs.toJson()),
        jsonEncode(plan.toJson()),
        plan.configHash,
      ],
    );
  }

  @override
  Future<DepositPlan?> find(String planId) async {
    final ResultSet rows = _db.select(
      "SELECT outputs FROM plan_snapshot WHERE plan_id = ? AND kind = 'DEPOSIT'",
      <Object>[planId],
    );
    if (rows.isEmpty) return null;
    return DepositPlan.fromJson(
      (jsonDecode(rows.single['outputs'] as String) as Map<String, Object?>)
          .cast<String, dynamic>(),
    );
  }

  /// 저장된 계산 입력 원값(없으면 null) — «계획 대비 실제»(E7b3)의 앵커.
  Future<PlanInputs?> findInputs(String planId) async {
    final ResultSet rows = _db.select(
      "SELECT inputs FROM plan_snapshot WHERE plan_id = ? AND kind = 'DEPOSIT'",
      <Object>[planId],
    );
    if (rows.isEmpty) return null;
    return PlanInputs.fromJson(
      jsonDecode(rows.single['inputs'] as String) as Map<String, Object?>,
    );
  }
}
