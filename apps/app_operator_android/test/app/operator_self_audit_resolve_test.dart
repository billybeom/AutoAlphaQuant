// 🆕 R280 — `M5-13` 원장 실사 해소 게이트 operator 조립(01 §8 미결 226 ⓖ · 계약 v1.37 §46 K318 ~ K321) — 실 SQLite(sim 원장 ·
// 투자 안내 화면 상태).
//
// 🔴 VM = 엔진(플래그 · 카운터 2 · 열린 자가 보고 차이 · 실사 링크 · 보관 · 확정) · 흐름 = 원장 변경 · 주기 · 확정 = 안전 동작 `run` ·
//    해제 = 실사 기록 트랜잭션(대응 계좌 전부 · 발동 뒤 기준일 0오차) · 수동 해제 0 · 레지스트리 = 본문.

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_self_audit_resolve.dart';
import 'package:app_operator_android/app/operator_self_report.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        P0sHumanInputs,
        P0sStrategyIds,
        SelfAuditResolveTexts,
        TrustedClock,
        heldReviewIdOf;
import 'package:data_sync/data_sync.dart'
    show P0sHumanDecision, SqliteSelfAuditResolveSource;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: '일반',
  P0sStrategyIds.sleeveB: '연금저축',
  P0sStrategyIds.sleeveC: '일반',
  P0sStrategyIds.pot: '연금저축',
};

OperatorView _viewOf(Database db, OperatingMode mode) => OperatorView(
  db: db,
  flags: FeatureFlags(
    satelliteEnabled: false,
    webViewerEnabled: false,
    calendarEnabled: false,
    runMode: RunMode.simInternal,
    operatingMode: mode,
    configHash: 'cfg_test',
  ),
);

SelfReportSubmission _sub(String alias, {String b = '245'}) =>
    SelfReportSubmission(
      purpose: SelfReportPurpose.periodicAudit,
      yyyyMm: '2026-08',
      input: SelfReportInput(
        lines: <SelfReportLineInput>[
          const SelfReportLineInput(symbol: '069500', quantityText: '0'),
          SelfReportLineInput(symbol: '133690', quantityText: b),
          const SelfReportLineInput(symbol: '214980', quantityText: '0'),
          const SelfReportLineInput(symbol: '411060', quantityText: '0'),
          const SelfReportLineInput(symbol: '0085P0', quantityText: '0'),
        ],
        cashKrwText: '1,000,000',
        accountAlias: alias,
      ),
      declaredComplete: true,
    );

Future<void> until(bool Function() ok) async {
  for (int i = 0; i < 300 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue);
}

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;
  late OperatorRuntime rt;
  late OperatorSelfAuditResolveRepository repo;
  late OperatorSelfReport sr;

  setUp(() {
    clock = FakeClock(kst(2026, 9, 2, 10, 0));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(kst(2026, 9, 2, 10, 0));
    rt = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: 'dev-op-1',
      trusted: trusted,
      humanDecision: P0sHumanDecision(
        inputs: P0sHumanInputs(aSymbol: '069500', accountByStrategy: _accounts),
        accountLabels: const <String, String>{},
        decisionRef: 'test',
      ),
    );
    rt.view.value = _viewOf(files.sim, OperatingMode.advisory);
    repo = OperatorSelfAuditResolveRepository(
      rt,
      tick: const Duration(milliseconds: 20),
    );
    sr = OperatorSelfReport(
      rt,
      hasBody: (String _) => true,
      tick: const Duration(milliseconds: 20),
    );
    files.sim.execute(
      'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at) '
      "VALUES ('KR', '133690', 'P0S_B', 245, 1000, '2026-08-03', '2026-08-03T00:00:00Z')",
    );
  });
  tearDown(() {
    sr.sessions.dispose();
    files.close();
  });

  void flag(String id, String setAt) => files.sim.execute(
    'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
    <Object?>[id, setAt, 'test'],
  );

  void held(String id, String at) => files.sim.execute(
    'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
    "decision_id, run_mode, operating_mode, lease_epoch, payload_digest) VALUES (?, 'SELF_REPORT_BALANCE', ?, "
    "'HELD_FOR_INTEGRITY', '보류됨', NULL, NULL, 'SIM_INTERNAL', 'ADVISORY', 0, 'd')",
    <Object?>[id, at],
  );

  String? unverified() =>
      SqliteSelfAuditResolveSource(files.sim)
          .unverifiedSetAt()
          ?.toIso8601String();

  test('🔴 해소할 것 없음 = OK · 카운터 2(투자 안내 · 신뢰 시각) · 빈 문장 둘 · 확정 0', () {
    final SelfAuditResolveVm v = repo.resolveOf(rt.view.value!);
    expect(v.level, UiLevel.ok);
    expect(v.headline, SelfAuditResolveTexts.headlineClear);
    expect(v.flagLine, SelfAuditResolveTexts.flagNone);
    expect(v.counterLines, <String>['미처리 갭 — 0거래일', '실사 갭 — 아직 실사 기록이 없습니다']);
    expect(v.diffsEmptyLabel, SelfAuditResolveTexts.diffsEmpty);
    expect(v.heldEmptyLabel, SelfAuditResolveTexts.heldEmpty);
    expect(v.confirmHeld, isNull);
    expect(v.auditLinks, isEmpty);
    trusted.at = null;
    expect(repo.resolveOf(rt.view.value!).counterLines, <String>[
      SelfAuditResolveTexts.unprocessedUnknown,
      SelfAuditResolveTexts.auditGapUnknown,
    ]);
    rt.view.value = _viewOf(files.sim, OperatingMode.autoTrade);
    expect(repo.resolveOf(rt.view.value!).counterLines, isEmpty);
  });

  test(
    '🔴 실사 차이 → 행(다시 실사로 해소 · 다시 실사하기) · 다시 실사 0오차 → 빈 문장(흐름이 다시 낸다)',
    () async {
      final List<SelfAuditResolveVm> seen = <SelfAuditResolveVm>[];
      final StreamSubscription<SelfAuditResolveVm> sub = repo
          .watchResolve()
          .listen(seen.add);
      await until(() => seen.isNotEmpty);
      const Map<String, String> args = <String, String>{
        'yyyy_mm': '2026-08',
        'account_alias': '연금저축',
      };
      sr.start('a1', args);
      expect(
        sr.submit(_sub('연금저축', b: '242'), random: Random(1)).state,
        CommandState.executed,
      );
      await until(() => seen.last.diffs.isNotEmpty);
      final LedgerDiffRow r = seen.last.diffs.single;
      expect(seen.last.headline, '열린 자가 보고 차이 1건 — 다시 실사로 해소합니다');
      expect(r.routeLabel, '다시 실사로 해소');
      expect(
        r.actionLink,
        const LinkAction(
          label: '다시 실사하기',
          deepLink: 'aaq://ledger/self-report/2026-08/연금저축',
        ),
      );
      expect(seen.last.counterLines.last, '실사 갭 — 연금저축 계좌 마지막 실사 뒤 2일');
      sr.start('a2', args);
      expect(
        sr.submit(_sub('연금저축'), random: Random(2)).state,
        CommandState.executed,
      );
      await until(() => seen.last.diffs.isEmpty);
      expect(seen.last.diffsEmptyLabel, SelfAuditResolveTexts.diffsEmpty);
      await sub.cancel();
    },
  );

  test('🔴 플래그 해제 = 대응 계좌 전부 발동 뒤 기준일 0오차(실사 기록 트랜잭션) · 실사 링크 = 아직 남은 계좌 · 수동 해제 0', () {
    flag(FlagIds.adviceLedgerUnverified, '2026-08-20T01:00:00.000Z');
    SelfAuditResolveVm v = repo.resolveOf(rt.view.value!);
    expect(v.level, UiLevel.act);
    expect(v.headline, SelfAuditResolveTexts.headlineFlag);
    expect(v.flagLine, '원장 미검증 · 08-20부터 · 청산 · 방어 안내는 그대로 냅니다');
    expect(v.auditLinks.map((LinkAction l) => l.deepLink), <String>[
      'aaq://ledger/self-report/2026-08/일반',
      'aaq://ledger/self-report/2026-08/연금저축',
    ]);
    sr.start('a1', const <String, String>{
      'yyyy_mm': '2026-08',
      'account_alias': '일반',
    });
    sr.submit(_sub('일반', b: '0'), random: Random(1));
    expect(unverified(), isNotNull, reason: '연금저축 아직');
    v = repo.resolveOf(rt.view.value!);
    expect(v.auditLinks.map((LinkAction l) => l.label), <String>[
      '연금저축 계좌 실사 하기',
    ]);
    sr.start('a2', const <String, String>{
      'yyyy_mm': '2026-08',
      'account_alias': '연금저축',
    });
    sr.submit(_sub('연금저축', b: '242'), random: Random(2));
    expect(unverified(), isNotNull, reason: '0오차 아님');
    v = repo.resolveOf(rt.view.value!);
    // 차이 행이 같은 목적지를 실으면 실사 링크에서 뺀다.
    expect(v.auditLinks, isEmpty);
    expect(
      v.diffs.single.actionLink?.deepLink,
      'aaq://ledger/self-report/2026-08/연금저축',
    );
    sr.start('a3', const <String, String>{
      'yyyy_mm': '2026-08',
      'account_alias': '연금저축',
    });
    sr.submit(_sub('연금저축'), random: Random(3));
    expect(unverified(), isNull);
    v = repo.resolveOf(rt.view.value!);
    expect(v.flagLine, SelfAuditResolveTexts.flagNone);
    expect(v.level, UiLevel.ok);
  });

  test('🔴 보관 일괄 확정 = 안전 동작 run(엔진 완성 호출 그대로) · 무결성 점검 중 = 막힘 · 거부 = 쓰기 0 · 결과 = 엔진 글자', () async {
    held('cmd_1', '2026-09-02T01:14:00.000Z');
    flag(FlagIds.ledgerIntegrity, '2026-09-02T00:00:00.000Z');
    SelfAuditResolveVm v = repo.resolveOf(rt.view.value!);
    expect(v.headline, '보관된 명령 1건 — 무결성 점검 중');
    expect(v.confirmHeld, isNull);
    expect(v.heldBlockedText, SelfAuditResolveTexts.heldBlocked);
    expect(v.heldCommands.single.kindLabel, '정기 실사 제출');
    expect(v.heldCommands.single.receivedAtText, '2026-09-02 10:14 접수');
    final OperatorSafetyActions actions = OperatorSafetyActions(
      rt,
      random: Random(7),
    );
    final String id = heldReviewIdOf(
      SqliteSelfAuditResolveSource(files.sim).heldCommands(),
    )!;
    final SafetyActionResult blocked = await actions.run(
      SafetyActionId.heldCommandsConfirm,
      args: <String, String>{'review_id': id},
    );
    expect(blocked.reasonCode, HeldReviewResultCodes.integrityActive);
    expect(blocked.level, UiLevel.blocked);
    files.sim.execute(
      "UPDATE trading_block SET cleared_at = '2026-09-02T01:20:00.000Z' WHERE flag_id = ?",
      <Object?>[FlagIds.ledgerIntegrity],
    );
    v = repo.resolveOf(rt.view.value!);
    expect(v.heldBlockedText, isNull);
    final SafetyActionCall call = v.confirmHeld!;
    expect(call.label, '보관된 명령 1건 확정');
    final SafetyActionResult bad = await actions.run(
      call.id,
      args: const <String, String>{'review_id': '전부 확정'},
    );
    expect(bad.reasonCode, HeldReviewResultCodes.argsInvalid);
    final SafetyActionResult ok = await actions.run(call.id, args: call.args);
    expect(
      (ok.id, ok.level, ok.reasonCode),
      (SafetyActionId.heldCommandsConfirm, UiLevel.ok, null),
    );
    expect(ok.headline, SelfAuditResolveTexts.confirmed(1));
    expect(await actions.watch(ok.actionRunId).single, ok);
    expect(
      files.sim
          .select("SELECT state FROM command_inbox WHERE command_id = 'cmd_1'")
          .single['state'],
      'RECEIVED',
    );
    final SafetyActionResult again = await actions.run(
      call.id,
      args: call.args,
    );
    expect(
      (again.reasonCode, again.retryable),
      (HeldReviewResultCodes.stale, true),
    );
    expect(
      repo.resolveOf(rt.view.value!).heldEmptyLabel,
      SelfAuditResolveTexts.heldEmpty,
    );
  });

  test('🔴 레지스트리 = M5-13 본문(뒤집은 단언 R234 · R237 Q1) · 화면 상태 없음 = 오류', () async {
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.m5SelfAuditResolve),
      isTrue,
    );
    rt.view.value = null;
    await expectLater(repo.watchResolve().first, throwsStateError);
    await expectLater(
      OperatorSafetyActions(rt, random: Random(1)).run(
        SafetyActionId.heldCommandsConfirm,
        args: const <String, String>{'review_id': 'hr_000000000000'},
      ),
      throwsStateError,
    );
  });
}
