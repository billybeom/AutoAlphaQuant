// E11q-c0 — M5-9 규칙 변경 operator 판(설계 13 §8 R188) — 실 SQLite(sim 원장) · 엔진 «저널 함께 쓰기» 요청 · 승인 · 취소 ·
// 게이트 읽기 · 결과 = 엔진 글자.
//
// 🔴 신뢰 시각 모름 = `TRUSTED_TIME_UNKNOWN` 원문(쓰기 0) · 후보 id 가 지금 후보와 다르면 `RULE_CHANGE_BASE_STALE` · 냉각 30일 전
//    승인 = `RULE_CHANGE_COOLING` · 냉각 뒤 첫 승인 = 승인 목록 = 지금 지문 하나(SAF-405 기동 조건) · `run` = 취소만.

import 'dart:math';

import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_rule_change.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show RuleChangeCodes, RuleChangeGateTexts, TrustedClock, kRuleChangeCooling;
import 'package:data_sync/data_sync.dart' show SqliteConfigVersionStore;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;
  late String hash;
  setUp(() {
    clock = FakeClock(kst(2026, 12, 10, 10, 5));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(DateTime.utc(2026, 12, 10, 1, 5));
    hash = SqliteConfigVersionStore(
      files.sim,
      clock: clock,
    ).register(<String, Object?>{'p0s': true, 'v': 1});
  });
  tearDown(() => files.close());

  OperatorRuntime rt({bool withTrusted = true}) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      trusted: withTrusted ? trusted : null,
    );
    r.view.value = OperatorView(
      db: files.sim,
      flags: FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        configHash: hash,
      ),
    );
    return r;
  }

  OperatorSafetyActions actions({bool withTrusted = true}) =>
      OperatorSafetyActions(rt(withTrusted: withTrusted), random: Random(7));

  RuleChangeRequestSubmission ask(String candidateId) =>
      RuleChangeRequestSubmission(
        candidateId: candidateId,
        reason: '첫 승인',
        rollbackMethod: '이전 설정으로',
        rationaleBefore: '모의 체험 결과',
        expectedOutcome: '실전 기동 조건',
        ruleCited: '03 §6-4',
      );

  int count(String table) =>
      files.sim.select('SELECT COUNT(*) AS n FROM $table').first['n']! as int;

  Future<RuleChangeGateVm> gate({bool withTrusted = true}) =>
      OperatorRuleChangeGateRepository(rt(withTrusted: withTrusted))
          .watchGate()
          .first;

  test('게이트 = 승인 0 · 지금 지문 등재 → 첫 승인 후보(후보 id = 지문)', () async {
    final RuleChangeGateVm g = await gate();
    expect(g.headline, RuleChangeGateTexts.headlineFirst);
    expect(g.candidates.single.candidateId, hash);
    expect(g.windowText, RuleChangeGateTexts.windowFirst);
  });

  test(
    '🔴 신뢰 시각 모름 = TRUSTED_TIME_UNKNOWN 원문 · 저널 · 요청 0 · 결과 watch 같은 값',
    () async {
      final OperatorSafetyActions a = actions(withTrusted: false);
      final SafetyActionResult r = await a.runRuleChangeRequest(ask(hash));
      expect(
        (r.id, r.level, r.reasonCode, r.headline),
        (
          SafetyActionId.ruleChangeRequest,
          UiLevel.blocked,
          'TRUSTED_TIME_UNKNOWN',
          '서버 시각을 확인하지 못해 요청하지 않았습니다.',
        ),
      );
      expect((count('decision_journal'), count('rule_change_request')), (0, 0));
      expect(await a.watch(r.actionRunId).toList(), <SafetyActionResult>[r]);
    },
  );

  test('🔴 후보 id 가 지금 후보와 다르다 = BASE_STALE(유형 · 해시는 엔진 후보에서만)', () async {
    final SafetyActionResult r = await actions().runRuleChangeRequest(
      ask('다른지문'),
    );
    expect(r.reasonCode, RuleChangeCodes.baseStale);
    expect(count('rule_change_request'), 0);
  });

  test(
    '🔴 요청 = 저널(JRC-명령 id) + 요청 한 트랜잭션 → 냉각 행 · 후보 0 → 취소 = 큐 0 · 후보 다시',
    () async {
      final OperatorSafetyActions a = actions();
      final SafetyActionResult r = await a.runRuleChangeRequest(ask(hash));
      expect((r.level, r.reasonCode), (UiLevel.ok, null));
      final String jid = 'JRC-${r.actionRunId}';
      expect(
        files.sim.select(
          'SELECT kind FROM decision_journal WHERE journal_id = ?',
          <Object?>[jid],
        ).single['kind'],
        'RULE_CHANGE_REQUEST',
      );
      final RuleChangeGateVm cooling = await gate();
      expect(cooling.candidates, isEmpty);
      final RuleChangeQueueRow row = cooling.rows.single;
      expect(
        (row.requestId, row.stateLabel, row.approveLabel),
        ('RC-$jid', RuleChangeGateTexts.stateCooling, null),
      );
      final SafetyActionResult c = await a.run(
        row.cancel!.id,
        args: row.cancel!.args,
      );
      expect((c.id, c.reasonCode), (SafetyActionId.ruleChangeCancel, null));
      final RuleChangeGateVm after = await gate();
      expect(after.rows, isEmpty);
      expect(after.candidates.single.candidateId, hash);
    },
  );

  test(
    '🔴 냉각 30일 전 승인 = COOLING · 냉각 뒤 첫 승인 = 승인 목록 = 지금 지문 하나(SAF-405)',
    () async {
      final OperatorSafetyActions a = actions();
      final SafetyActionResult r = await a.runRuleChangeRequest(ask(hash));
      final String rid = (await gate()).rows.single.requestId;
      RuleChangeApprovalSubmission approve() => RuleChangeApprovalSubmission(
        requestId: rid,
        goldenChanged: false,
        approver: '발주자',
        thirdPartyNotified: true,
      );
      final SafetyActionResult early = await a.runRuleChangeApproval(approve());
      expect(early.reasonCode, RuleChangeCodes.cooling);
      trusted.at = DateTime.utc(2026, 12, 10, 1, 5).add(kRuleChangeCooling);
      final RuleChangeGateVm ready = await gate();
      expect(ready.rows.single.approveLabel, RuleChangeGateTexts.approveLabel);
      final SafetyActionResult ok = await a.runRuleChangeApproval(approve());
      expect(
        (ok.id, ok.level, ok.reasonCode),
        (SafetyActionId.ruleChangeApprove, UiLevel.ok, null),
      );
      expect(
        files.sim
            .select(
              'SELECT config_hash FROM config_versions WHERE approved = 1',
            )
            .single['config_hash'],
        hash,
      );
      final RuleChangeGateVm done = await gate();
      expect(
        (
          done.headline,
          done.rows.length,
          done.candidates.length,
          done.windowText,
        ),
        (RuleChangeGateTexts.headlineApproved, 0, 0, null),
      );
      expect(r.reasonCode, isNull);
    },
  );

  test(
    '🔴 run = 취소만 · request_id 없음 = ArgumentError · 그 밖 id = 구현 전(오류)',
    () async {
      final OperatorSafetyActions a = actions();
      await expectLater(
        a.run(SafetyActionId.ruleChangeCancel),
        throwsArgumentError,
      );
      await expectLater(
        a.run(SafetyActionId.interventionStep),
        throwsA(isA<UnsupportedError>()),
      );
      // 🆕 R189 — RECON 해제 = 화이트리스트 밖(`runReconClear` 로).
      await expectLater(a.run(SafetyActionId.reconClear), throwsArgumentError);
    },
  );
}
