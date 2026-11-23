// E16j-a — X5 정정 마법사 operator 판(설계 13 §8 R227 · 01 §41 K249~K256 · 01 §8 미결 217) — 실 SQLite(sim 원장) ·
// 읽기 창구 · 안전 동작 5(단계 · 아무것도 안 하기 · 저널 · 정정 · 새 기준점) · 결과 = 엔진 글자.
//
// 🔴 정정 = 원문 파싱(엔진) → 대상의 열린 세션 → 실행 창 안이면 직전 재대사(런타임 훅 · 그 집행일) → 커밋(5단계) ·
//    재대사를 못 하면 «잠시 뒤 다시»(다시 시도 · 코드 0) · 다른 정정 중 = «잠시 뒤 다시» · 저널 id = `JIV-<명령 id>`.
// 🔴 엔진 판정의 갈래 전부는 data_sync · core 시험이 지킨다 — 여기는 조립(어느 원장 · 어느 세션 · 어떤 id · 어떤 결과)만.

import 'dart:math';

import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_repair.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operations_loader.dart';
import 'package:core_engine/core_engine.dart'
    show
        InterventionOutcome,
        OperationsConfig,
        P0sStrategyIds,
        RepairResultTexts,
        RepairWizardTexts,
        TrustedClock,
        kInterventionCooling;
import 'package:data_sync/data_sync.dart' show insertInterventionStep;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDownAll(deleteTempDirs);
  // 🆕 미결 220 ⓑ — 운영 설정 = 앱 자산 그대로(체인 상한 `operations.amend_chain_max`).
  late OperationsConfig assetOps;
  setUpAll(() async => assetOps = await loadOperationsConfig(rootBundle));
  late FakeClock clock;
  late _Trusted trusted;
  late LedgerFiles files;
  setUp(() {
    clock = FakeClock(kst(2027, 1, 14, 7, 20));
    trusted = _Trusted(clock.now);
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  final List<(OperatorView, TradeDate)> reconAsked =
      <(OperatorView, TradeDate)>[];
  Set<String>? reconAnswer;

  OperatorRuntime rt({
    bool view = true,
    bool recon = true,
    bool ops = true,
    OperationsConfig? operations,
  }) {
    reconAsked.clear();
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      trusted: trusted,
      operations: ops ? (operations ?? assetOps) : null,
      freshRecon: recon
          ? (OperatorView v, TradeDate d) async {
              reconAsked.add((v, d));
              return reconAnswer;
            }
          : null,
    );
    if (view) {
      r.view.value = OperatorView(
        db: files.sim,
        flags: const FeatureFlags(
          satelliteEnabled: false,
          webViewerEnabled: false,
          calendarEnabled: false,
          runMode: RunMode.simInternal,
          operatingMode: OperatingMode.autoTrade,
          configHash: '',
        ),
      );
    }
    return r;
  }

  OperatorSafetyActions actions(OperatorRuntime r) =>
      OperatorSafetyActions(r, random: Random(7));

  void diff(String id, {String status = 'OPEN'}) => files.sim.execute(
    'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, severity, origin_code, '
    "status, detected_at, applicable) VALUES (?, 'CANON_BROKER', 'QUANTITY', '2027-01-13', "
    '\'{"kind":"QTY","account":"pension","key":"133690","ledger":5,"broker":3,"candidates":["MANUAL_ORDER"]}\', '
    "'133690 보유 — 원장 5주 · 브로커 3주', 'BLOCKING', NULL, ?, '2027-01-13T22:05:00.000Z', 1)",
    <Object?>[id, status],
  );

  /// 실행 창 안 세션(1~4단계 통과 · 3단계 저널 [journal]).
  void executable(String sid, {String journal = 'JIV-x'}) {
    final DateTime now = trusted.at!;
    final DateTime j = now.subtract(
      kInterventionCooling + const Duration(hours: 1),
    );
    for (final (int stage, DateTime at, String? d)
        in <(int, DateTime, String?)>[
          (1, j.subtract(const Duration(minutes: 2)), null),
          (2, j.subtract(const Duration(minutes: 1)), null),
          (3, j, journal),
          (4, now.subtract(const Duration(minutes: 30)), null),
        ]) {
      insertInterventionStep(
        files.sim,
        sessionId: sid,
        stage: stage,
        atUtc: at,
        outcome: InterventionOutcome.passed,
        decisionId: d,
      );
    }
  }

  List<(Object?, Object?, Object?)> steps() => <(Object?, Object?, Object?)>[
    for (final Map<String, Object?> r in files.sim.select(
      'SELECT session_id, stage, outcome FROM intervention_step ORDER BY session_id, stage',
    ))
      (r['session_id'], r['stage'], r['outcome']),
  ];

  test('읽기 — 화면 상태 없음 = 오류 · 빈 원장 = 빈 허브 · diff = 대상 링크(본문 있을 때만)', () async {
    final OperatorRepairWizardRepository none = OperatorRepairWizardRepository(
      rt(view: false),
      hasBody: (String _) => true,
    );
    await expectLater(none.watchRepair().first, throwsStateError);
    final OperatorRuntime r = rt();
    final OperatorRepairWizardRepository repo = OperatorRepairWizardRepository(
      r,
      hasBody: (String _) => true,
    );
    expect(
      (await repo.watchRepair().first).headline,
      RepairWizardTexts.hubEmpty,
    );
    diff('ld-a');
    final RepairWizardVm hub = await repo.watchRepair().first;
    expect(hub.targetLinks.single.deepLink, 'aaq://x5/repair-wizard/ld-a');
    final RepairWizardVm noBody = await OperatorRepairWizardRepository(
      r,
      hasBody: (String route) => route != AppRoutes.x5RepairTarget,
    ).watchRepair().first;
    expect(noBody.targetLinks, isEmpty);
    final RepairWizardVm target = await repo
        .watchRepair(targetId: 'ld-a')
        .first;
    expect(target.diff!.diffId, 'ld-a');
  });

  test('🔴 단계 = 엔진 args 그대로 advance · 저널 = 살아 있는 세션에 JIV-<명령 id> · 아무것도 안 하기 = 세션 닫고 받아들임', () async {
    diff('ld-a');
    final OperatorSafetyActions a = actions(rt());
    final SafetyActionResult s1 = await a.run(
      SafetyActionId.interventionStep,
      args: <String, String>{
        'session_id': 'x5:ld-a:1',
        'stage': '1',
        'outcome': 'PASSED',
      },
    );
    expect(
      (s1.id, s1.level, s1.headline, s1.reasonCode),
      (
        SafetyActionId.interventionStep,
        UiLevel.ok,
        RepairResultTexts.stepPassed,
        null,
      ),
    );
    // 저널 = 2단계 차례 = 차례 밖(엔진 코드 원문).
    final SafetyActionResult early = await a.runInterventionJournal(
      const InterventionJournalSubmission(
        rationaleBefore: '근거',
        expectedOutcome: '기대',
        ruleCited: '규칙',
      ),
    );
    expect(early.reasonCode, 'INTERVENTION_STAGE_OUT_OF_ORDER');
    expect(early.headline, '지금은 저널 단계가 아닙니다');
    await a.run(
      SafetyActionId.interventionStep,
      args: <String, String>{
        'session_id': 'x5:ld-a:1',
        'stage': '2',
        'outcome': 'PASSED',
      },
    );
    final SafetyActionResult j = await a.runInterventionJournal(
      const InterventionJournalSubmission(
        rationaleBefore: '근거',
        expectedOutcome: '기대',
        ruleCited: '규칙',
      ),
    );
    expect(
      (j.id, j.reasonCode, j.headline),
      (SafetyActionId.interventionJournal, null, RepairResultTexts.journaled),
    );
    expect(
      files.sim
          .select(
            "SELECT decision_id FROM intervention_step WHERE session_id = 'x5:ld-a:1' AND stage = 3",
          )
          .single['decision_id'],
      'JIV-${j.actionRunId}',
    );
    final SafetyActionResult acc = await a.run(
      SafetyActionId.repairAccept,
      args: <String, String>{'diff_id': 'ld-a'},
    );
    expect(
      (acc.id, acc.reasonCode, acc.headline),
      (SafetyActionId.repairAccept, null, RepairResultTexts.accepted),
    );
    expect(steps().last, ('x5:ld-a:1', 4, 'DO_NOTHING'));
    expect(
      files.sim
          .select("SELECT status FROM ledger_diff WHERE diff_id = 'ld-a'")
          .single['status'],
      'ACCEPTED',
    );
    expect(await a.watch(acc.actionRunId).single, acc);
    expect(
      () => a.run(
        SafetyActionId.interventionStep,
        args: const <String, String>{},
      ),
      throwsArgumentError,
    );
    expect(
      () => a.run(SafetyActionId.repairAccept, args: const <String, String>{}),
      throwsArgumentError,
    );
  });

  test('🔴 신뢰 시각 모름 = 단계 거부(엔진 코드) · 화면 상태 없음 = 오류', () async {
    trusted.at = null;
    final SafetyActionResult r = await actions(rt()).run(
      SafetyActionId.interventionStep,
      args: <String, String>{
        'session_id': 'x5:ld-a:1',
        'stage': '1',
        'outcome': 'PASSED',
      },
    );
    expect((r.level, r.reasonCode), (UiLevel.watch, 'TRUSTED_TIME_UNKNOWN'));
    expect(
      () => actions(rt(view: false)).runRepairBaseline(
        const RepairBaselineSubmission(
          targetId: 'li-x',
          originCode: 'CHAIN_BROKEN',
        ),
      ),
      throwsStateError,
    );
  });

  test(
    '🔴 정정 — 원문 못 읽음 · 세션 없음 · 재대사 못 함(다시 시도) · 재대사 = 그 집행일 · delta 바뀜 · 체결 아님',
    () async {
      diff('ld-a');
      final OperatorSafetyActions a = actions(rt());
      RepairCorrectSubmission ask({bool voidFill = true, String? q}) =>
          RepairCorrectSubmission(
            targetId: 'ld-a',
            fillRef: 'ex-none',
            originCode: OriginCodes.manualOrder,
            voidFill: voidFill,
            quantityText: q,
            priceText: '9,850',
            commissionText: '0',
            taxText: '0',
          );
      final SafetyActionResult bad = await a.runRepairCorrect(
        ask(voidFill: false, q: '1.5'),
      );
      expect(bad.reasonCode, 'REPAIR_AMOUNT_INVALID');
      final SafetyActionResult noSession = await a.runRepairCorrect(ask());
      expect(noSession.reasonCode, 'INTERVENTION_STAGE_OUT_OF_ORDER');
      // 세션은 있으나 실행 창 밖(2단계 차례) = 증권사에 가지 않고 커밋 관문이 거부.
      insertInterventionStep(
        files.sim,
        sessionId: 'x5:ld-a:1',
        stage: 1,
        atUtc: trusted.at!.subtract(const Duration(minutes: 5)),
        outcome: InterventionOutcome.passed,
      );
      final SafetyActionResult early = await a.runRepairCorrect(ask());
      expect(early.reasonCode, 'INTERVENTION_STAGE_OUT_OF_ORDER');
      expect(reconAsked, isEmpty, reason: '실행 창 밖 = 증권사에 가지 않는다');
      insertInterventionStep(
        files.sim,
        sessionId: 'x5:ld-a:1',
        stage: 2,
        atUtc: trusted.at!.subtract(const Duration(minutes: 4)),
        outcome: InterventionOutcome.abandoned,
      );
      executable('x5:ld-a:2');
      reconAnswer = null;
      final SafetyActionResult hold = await a.runRepairCorrect(ask());
      expect(
        (hold.level, hold.reasonCode, hold.retryable, hold.headline),
        (UiLevel.watch, null, true, RepairResultTexts.reconUnavailable),
      );
      expect(reconAsked.single.$2, const TradeDate('2027-01-13'));
      reconAnswer = <String>{'ld-other'};
      expect(
        (await a.runRepairCorrect(ask())).reasonCode,
        'REPAIR_DELTA_CHANGED',
      );
      reconAnswer = <String>{'ld-a'};
      expect(
        (await a.runRepairCorrect(ask(voidFill: false, q: '3'))).reasonCode,
        'REPAIR_FILL_NOT_BROKER',
      );
      // 세션은 닫히지 않았다(거부 = 5단계 0).
      expect(
        steps().where(((Object?, Object?, Object?) s) => s.$2 == 5),
        isEmpty,
      );
      // 훅이 없는 조립(플랫폼 밖) = 다시 시도.
      final SafetyActionResult noHook = await actions(rt(recon: false))
          .runRepairCorrect(ask());
      expect(noHook.headline, RepairResultTexts.reconUnavailable);
    },
  );

  test('🆕 미결 220 ⓑ 체인 상한 = 운영 설정 — 자산 값 · 못 읽음 = 정정 0(증권사 0 · 5단계 0) · 값 그대로 엔진에(0 = 엔진 검사)', () async {
    expect(assetOps.amendChainMax, 2, reason: '01 §10-3 B6 문서값 = 자산');
    diff('ld-a');
    // 정정 대상 체결(브로커 체결 한 건 · 끝난 주문 · 포지션 = 그 체결).
    files.sim.execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
      'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
      "updated_at, mode) VALUES ('iA', 'k-iA', '2027-01-13T00:10:00.000Z', '2027-01-13', 'KR', 'pension', ?, "
      "'dA', '133690', 'BUY', 'LIMIT', 5, 20000, 'FILLED', 'cfg', '2027-01-13T00:10:00.000Z', 'SIM_INTERNAL')",
      <Object?>[P0sStrategyIds.sleeveB],
    );
    files.sim.execute(
      'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) '
      "VALUES ('2027-01-13:0001', 'iA', '2027-01-13T00:20:00.000Z', 'FILLED')",
    );
    files.sim.execute(
      'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, commission, tax, '
      "fill_origin, cost_source) VALUES ('X#5', '2027-01-13:0001', '2027-01-13T01:00:00.000Z', 5, 20000, 0, 0, "
      "'SIMULATED', 'ESTIMATED')",
    );
    executable('x5:ld-a:1');
    reconAnswer = <String>{'ld-a'};
    RepairCorrectSubmission ask() => const RepairCorrectSubmission(
      targetId: 'ld-a',
      fillRef: 'X#5',
      originCode: OriginCodes.manualOrder,
      voidFill: false,
      quantityText: '4',
      priceText: '20,000',
      commissionText: '0',
      taxText: '0',
    );
    // 못 읽음 = 오류(지어내지 않음) · 증권사에 가지 않는다 · 세션은 그대로.
    await expectLater(
      actions(rt(ops: false)).runRepairCorrect(ask()),
      throwsStateError,
    );
    expect(reconAsked, isEmpty, reason: '설정 없음 = 증권사 0');
    // 값은 그대로 엔진에 간다 — 0 = 엔진 검사(1 미만 = ArgumentError · 되돌림).
    await expectLater(
      actions(
        rt(
          operations: OperationsConfig.fromJson(<String, Object?>{
            'amend_chain_max': 0,
          }),
        ),
      ).runRepairCorrect(ask()),
      throwsArgumentError,
    );
    expect(reconAsked.single.$2, const TradeDate('2027-01-13'));
    expect(
      steps().where(((Object?, Object?, Object?) s) => s.$2 == 5),
      isEmpty,
    );
  });

  test('🔴 새 기준점 — 세션 없음 · 표시 없음 · 깨끗한 판정 = 엔진 코드 · 다른 정정 중 = 다시 시도', () async {
    final OperatorSafetyActions a = actions(rt());
    const RepairBaselineSubmission ask = RepairBaselineSubmission(
      targetId: 'li-x',
      originCode: 'CHAIN_BROKEN',
    );
    expect(
      (await a.runRepairBaseline(ask)).reasonCode,
      'INTERVENTION_STAGE_OUT_OF_ORDER',
    );
    executable('x5:li-x:1');
    expect(
      (await a.runRepairBaseline(ask)).reasonCode,
      'BASELINE_FLAG_NOT_SET',
    );
    files.sim.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>[FlagIds.ledgerIntegrity, '2027-01-13T22:05:00.000Z', 'test'],
    );
    // 스탬프 없는 원장 = 대조 깨끗 → 지금 무결성 대상 없음 → 엔진이 거부(X5 경계 아님).
    expect((await a.runRepairBaseline(ask)).reasonCode, 'BASELINE_NOT_X5');
    files.sim.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>[FlagIds.ledgerFix, '2027-01-13T22:05:00.000Z', 'left over'],
    );
    final SafetyActionResult busy = await a.runRepairBaseline(ask);
    expect(
      (busy.level, busy.reasonCode, busy.retryable, busy.headline),
      (UiLevel.watch, null, true, RepairResultTexts.busy),
    );
    expect(await a.watch(busy.actionRunId).single, busy);
  });
}
