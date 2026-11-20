// E11q-c4 — M5-5 RECON 해제 operator 판(설계 13 §8 R189 · 01 §35 K180~K182) — 실 SQLite(sim 원장) · 엔진 «저널 함께 쓰기» ·
// 보드 읽기 창구 · 결과 = 엔진 글자.
//
// 🔴 해제 = 사전 저널 `RECON_CLEAR`(id `JRCL-<명령 id>`) + 플래그 해제 한 트랜잭션 · 해제한 사람 = «운영 폰» · 신뢰 시각 없이도 ·
//    거부 = 엔진 코드 원문(쓰기 0) · `run(reconClear)` = ArgumentError · 보드 = RECON 행만 폼(쓰기 창구일 때만) · 풀면 행이 빠진다.

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_block_board.dart';
import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show KillSwitchScreenTexts, ReconClearTexts, reconClearFormOf;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

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
  setUp(() {
    clock = FakeClock(kst(2027, 1, 14, 7, 20));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  // 🔴 신뢰 시각 주입 0(= `UnknownTrustedClock`) — RECON 해제는 신뢰 시각에 기대지 않는다.
  OperatorRuntime rt({bool view = true}) {
    final OperatorRuntime r = OperatorRuntime(files: files, clock: clock);
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

  void block() => files.sim.execute(
    'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
    <Object?>[FlagIds.reconMismatch, '2027-01-13T22:05:00.000Z', 'test'],
  );

  int count(String table) =>
      files.sim.select('SELECT COUNT(*) AS n FROM $table').first['n']! as int;

  ReconClearSubmission ask({
    String origin = OriginCodes.fillLag,
    String rationale = '체결 보고가 늦게 왔다',
  }) => ReconClearSubmission(
    originCode: origin,
    rationaleBefore: rationale,
    expectedOutcome: '다음 대사에서 맞는다',
    ruleCited: '04 §3-5 ②',
  );

  test('🔴 해제 = 사전 저널 + 해제 한 번 · 해제한 사람 «운영 폰» · 신뢰 시각 없이도 · 결과 = 엔진 글자 · watch = 같은 결과', () async {
    block();
    final OperatorSafetyActions a = actions(rt());
    final SafetyActionResult r = await a.runReconClear(ask());
    expect(
      (r.id, r.level, r.headline, r.reasonCode, r.retryable),
      (
        SafetyActionId.reconClear,
        UiLevel.ok,
        ReconClearTexts.cleared,
        null,
        false,
      ),
    );
    final Map<String, Object?> f = files.sim
        .select(
          "SELECT cleared_at, cleared_by, decision_id, origin_code FROM trading_block WHERE flag_id = 'RECON_MISMATCH'",
        )
        .single;
    expect(f['cleared_by'], KillSwitchScreenTexts.operatorPhone);
    expect(f['origin_code'], OriginCodes.fillLag);
    expect(f['cleared_at'], clock.nowUtc().toIso8601String());
    expect(f['decision_id'], 'JRCL-${r.actionRunId}');
    final Map<String, Object?> j = files.sim.select(
      'SELECT kind, is_deviation, rationale_before FROM decision_journal WHERE journal_id = ?',
      <Object?>[f['decision_id']],
    ).single;
    expect(
      (j['kind'], j['is_deviation'], j['rationale_before']),
      ('RECON_CLEAR', 1, '체결 보고가 늦게 왔다'),
    );
    expect(
      files.sim
          .select(
            'SELECT kind, state FROM command_inbox WHERE command_id = ?',
            <Object?>[r.actionRunId],
          )
          .single
          .values
          .toList(),
      <Object?>['RECON_CLEAR', 'EXECUTED'],
    );
    expect(await a.watch(r.actionRunId).single, r);
  });

  test('🔴 거부 = 엔진 코드 원문(막힘 없음 · 선택지 밖 · 저널 빈칸) · 쓰기 = 명령 행만', () async {
    final OperatorSafetyActions a = actions(rt());
    final SafetyActionResult none = await a.runReconClear(ask());
    expect(
      (none.level, none.headline, none.reasonCode),
      (
        UiLevel.info,
        ReconClearTexts.notBlocked,
        ReconClearResultCodes.notBlocked,
      ),
    );
    block();
    final SafetyActionResult advisory = await a.runReconClear(
      ask(origin: OriginCodes.advisoryFill),
    );
    expect(
      (advisory.level, advisory.reasonCode),
      (UiLevel.blocked, ReconClearResultCodes.originNotAllowed),
    );
    final SafetyActionResult blank = await a.runReconClear(
      ask(rationale: '  '),
    );
    expect(
      (blank.level, blank.headline, blank.reasonCode),
      (
        UiLevel.act,
        ReconClearTexts.journalMissing,
        ReconClearResultCodes.journalMissing,
      ),
    );
    for (final SafetyActionResult r in <SafetyActionResult>[
      none,
      advisory,
      blank,
    ]) {
      expect(r.id, SafetyActionId.reconClear);
    }
    expect(count('decision_journal'), 0);
    expect(count('command_inbox'), 3);
    expect(
      files.sim
          .select(
            "SELECT cleared_at FROM trading_block WHERE flag_id = 'RECON_MISMATCH'",
          )
          .single['cleared_at'],
      isNull,
    );
  });

  test('🔴 run(reconClear) = ArgumentError(화이트리스트 밖) · 화면 상태 없음 = StateError(쓰기 0)', () async {
    block();
    await expectLater(
      actions(rt()).run(
        SafetyActionId.reconClear,
        args: const <String, String>{
          'origin_code': OriginCodes.fillLag,
          'decision_id': 'J-1',
        },
      ),
      throwsArgumentError,
    );
    await expectLater(
      actions(rt(view: false)).runReconClear(ask()),
      throwsStateError,
    );
    expect(count('command_inbox'), 0);
    expect(count('decision_journal'), 0);
  });

  test('🔴 보드 = RECON 행만 해제 폼(쓰기 창구일 때만) · 풀면 다시 내고 행이 빠진다', () async {
    block();
    final OperatorRuntime r = rt();
    final List<BlockBoardVm> got = <BlockBoardVm>[];
    final StreamSubscription<BlockBoardVm> sub = OperatorBlockBoardRepository(
      r,
      hasBody: (String _) => true,
      reconClearable: true,
    ).watchBoard().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    final BlockBoardRow row = got.last.rows.singleWhere(
      (BlockBoardRow x) => x.rowId == FlagIds.reconMismatch,
    );
    expect(row.reconClear, reconClearFormOf());
    expect(
      got.last.rows.where((BlockBoardRow x) => x.reconClear != null),
      hasLength(1),
    );

    final List<BlockBoardVm> ro = <BlockBoardVm>[];
    final StreamSubscription<BlockBoardVm> sub2 = OperatorBlockBoardRepository(
      r,
      hasBody: (String _) => true,
      reconClearable: false,
    ).watchBoard().listen(ro.add);
    addTearDown(sub2.cancel);
    await until(() => ro.isNotEmpty);
    expect(
      ro.last.rows.where((BlockBoardRow x) => x.reconClear != null),
      isEmpty,
    );

    await actions(r).runReconClear(ask(origin: OriginCodes.corporateAction));
    await until(
      () => got.last.rows.every(
        (BlockBoardRow x) => x.rowId != FlagIds.reconMismatch,
      ),
    );
  });
}
