// 🆕 E11q-c0 — M5-9 규칙 변경 게이트 읽기 창구 operator 판(설계 13 §8 R188 · 01 §35 K177~K179 · 06 `M4-12` ⑪ ⓐ).
//
// 🔴 화면 상태의 원장(모의 기간 = 모의 파일) → data_sync 원천 → 엔진 VM(`ruleChangeGateVmOf`) · 지금 설정 지문 = 화면 상태의
//    기능 표지(`currentP0sOpsConfig` → `FeatureFlags.configHash` · 빈 글자 = 설정 없음) · 원장 변경 · 주기마다 다시 낸다
//    (냉각이 끝나면 새 VM — 화면 카운트다운 0) · 같은 값 = 다시 내지 않음.
// 🔴 신뢰 시각 = 런타임 시계(E11k 전 = 모름 → 냉각 글자 = «확인하지 못했습니다» · 승인 0 · 요청 = 결과 원문 거부).
// 🔴 쓰기 창구 = 폰(안전 동작 한 인스턴스 · 늘 주입) → 후보 · 승인 · 취소가 선다(잠김 = 미결 169 · 지금 조립 null).

import 'package:data_sync/data_sync.dart'
    show SqliteRuleChangeGateSource, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show RuleChangeGateRepository, RuleChangeGateVm;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 지금 설정 지문(빈 글자 = 없음 → null).
String? operatorConfigHashOf(OperatorView v) {
  final String h = v.flags.configHash.trim();
  return h.isEmpty ? null : h;
}

/// M5-9 게이트 원천(읽기 · 요청 경로가 같은 꼴로 후보를 다시 셈한다).
SqliteRuleChangeGateSource operatorRuleChangeGateSourceOf(
  OperatorRuntime rt,
  OperatorView v,
) => SqliteRuleChangeGateSource(
  v.db,
  clock: rt.clock,
  trusted: rt.trusted,
  currentConfigHash: operatorConfigHashOf(v),
  canWrite: true,
);

/// 규칙 변경 게이트 읽기(operator).
class OperatorRuleChangeGateRepository implements RuleChangeGateRepository {
  /// 만든다 — [tick] = 시간만 흐를 때 다시 읽는 주기(냉각 끝 · 관측 시각).
  OperatorRuleChangeGateRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 다시 읽는 주기.
  final Duration tick;

  RuleChangeGateVm _read(OperatorView v) =>
      operatorRuleChangeGateSourceOf(_rt, v).gate();

  @override
  Stream<RuleChangeGateVm> watchGate() => followView<RuleChangeGateVm>(
    view: _rt.view,
    changes: (OperatorView v) => watchLedgerQuery<RuleChangeGateVm>(
      v.db,
      SqliteRuleChangeGateSource.watchedTables,
      () => _read(v),
    ),
    now: _read,
    tick: tick,
    noView: () => StateError('규칙 변경: 화면 상태 없음(온보딩 전)'),
  );
}
