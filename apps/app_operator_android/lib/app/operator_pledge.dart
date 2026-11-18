// M5-8 서약 operator 판 — 읽기 창구(`PledgeRepository`) · 안전 동작(`SafetyActions` — 지금 = 서약만)(E11p4h · 설계 13 §8
// R157 · 01 §30 K6 · K31 · K32 · 엔진 R67 Z1 · Z2).
//
// 🔴 원장 = sim 파일(온보딩 ② 와 같은 갈래 — 마무리 사실 `pledged` 도 여기서 읽는다).
// 🔴 쓰기 = 엔진 `SqlitePledgeStore.writeFirst` · `edit`(같은 원장 · 한 트랜잭션 · `command_inbox` 멱등) · 결과 = 엔진
//    `pledgeActionResultOf`(등급 · 문장) — 앱이 문장을 짓지 않는다.
// 🔴 첫 판 저널 id = 명령 id(R67 Z1) · 편집 저널 id = 제출 그대로(사전 저널 원천 = 01 §8 미결 185 · 없으면 엔진 거부).
// 🔴 신뢰 시각 = `OperatorRuntime.trusted`(E11k 전 = 모름 → 엔진 `TRUSTED_TIME_UNKNOWN`).
// 🔴 서약 밖 안전 동작(재개 · STOPPED 결정 · 사후 검토 · 규칙 변경 · 재량 조정 · `run`) = operator 구현 전(오류 — 지어내지 않는다).

import 'dart:math';

import 'package:core_engine/core_engine.dart'
    show newCommandId, pledgeActionResultOf, pledgeSubmissionDigest, pledgeVmOf;
import 'package:data_sync/data_sync.dart'
    show PledgeResult, SqlitePledgeStore, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart';

import 'operator_runtime.dart';

SqlitePledgeStore _store(OperatorRuntime rt) =>
    SqlitePledgeStore(rt.files.sim, clock: rt.clock, trusted: rt.trusted);

/// 서약 읽기(operator) — `pledge` 표가 바뀔 때마다 다시 낸다.
class OperatorPledgeRepository implements PledgeRepository {
  /// 만든다.
  OperatorPledgeRepository(this._rt);

  final OperatorRuntime _rt;

  @override
  Stream<PledgeVm> watchPledge() => watchLedgerQuery<PledgeVm>(
    _rt.files.sim,
    const <String>{'pledge'},
    () => pledgeVmOf(
      current: _store(_rt).currentPledge(),
      trustedNowUtc: _rt.trusted.trustedNowUtc(),
      nowUtc: _rt.clock.nowUtc(),
    ),
  );
}

/// 안전 동작(operator) — 지금 = 서약 첫 판 · 편집.
class OperatorSafetyActions implements SafetyActions {
  /// 만든다 — [random] = 명령 id 원천(기본 = `Random.secure()`).
  OperatorSafetyActions(this._rt, {Random? random})
    : _random = random ?? Random.secure();

  final OperatorRuntime _rt;
  final Random _random;

  /// 이 인스턴스가 낸 동작의 결과(동작 id → 결과).
  final Map<String, SafetyActionResult> _done = <String, SafetyActionResult>{};

  static Future<SafetyActionResult> _none(String what) =>
      Future<SafetyActionResult>.error(
        UnsupportedError('$what: operator 구현 없음(R157)'),
      );

  @override
  Future<SafetyActionResult> runPledge(PledgeSubmission submission) async {
    final SafetyActionId id = submission.id;
    if (id != SafetyActionId.pledgeWrite && id != SafetyActionId.pledgeEdit) {
      throw ArgumentError.value(id, 'id', '서약 동작이 아니다');
    }
    final String commandId = newCommandId(_random);
    final String digest = pledgeSubmissionDigest(submission);
    final SqlitePledgeStore store = _store(_rt);
    final PledgeResult r = id == SafetyActionId.pledgeWrite
        ? store.writeFirst(
            commandId: commandId,
            payloadDigest: digest,
            sentences: submission.sentences,
            decisionId: commandId,
          )
        : store.edit(
            commandId: commandId,
            payloadDigest: digest,
            sentences: submission.sentences,
            decisionId: submission.decisionId ?? '',
          );
    if (!r.executed && r.reasonCode == null) {
      throw StateError('서약: 엔진이 사유 없이 거부했다');
    }
    final SafetyActionResult out = pledgeActionResultOf(
      actionRunId: commandId,
      id: id,
      reasonCode: r.executed ? null : r.reasonCode,
    );
    _done[commandId] = out;
    return out;
  }

  /// 이 인스턴스가 낸 동작만 — 폰 안에서 바로 끝나므로 결과 하나(모르는 id = 오류).
  @override
  Stream<SafetyActionResult> watch(String actionRunId) {
    final SafetyActionResult? r = _done[actionRunId];
    return r == null
        ? Stream<SafetyActionResult>.error(
            StateError('안전 동작 $actionRunId: 이 기기에서 낸 동작이 아님'),
          )
        : Stream<SafetyActionResult>.value(r);
  }

  @override
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  }) => _none('run(${id.wire})');

  @override
  Future<SafetyActionResult> runKillResumeItem(
    KillResumeItemSubmission submission,
  ) => _none('runKillResumeItem');

  @override
  Future<SafetyActionResult> runStoppedDecision(
    StoppedDecisionSubmission submission,
  ) => _none('runStoppedDecision');

  @override
  Future<SafetyActionResult> runPostmortem(PostmortemSubmission submission) =>
      _none('runPostmortem');

  @override
  Future<SafetyActionResult> runRuleChangeApproval(
    RuleChangeApprovalSubmission submission,
  ) => _none('runRuleChangeApproval');

  @override
  Future<SafetyActionResult> runDiscretionAdjust(
    DiscretionAdjustSubmission submission,
  ) => _none('runDiscretionAdjust');
}
