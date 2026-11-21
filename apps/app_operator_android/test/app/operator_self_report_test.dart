// E11q-q6 — `L-3` 정기 실사 operator 조립(01 §21-3 · §21-4 · 02 §3-10) — 실 SQLite(sim 원장 · 투자 안내 화면 상태).
//
// 🔴 세션 = 이 폰 메모리(설정 동작 start/stop · 동기) · 판정 · 글자 = 엔진 · VM 흐름 = 원장 변경 · 세션 바뀜마다 ·
//    제출 = 엔진 판정 → 원장 한 트랜잭션 → 세션 닫음 · 접수증 = 엔진 글자(명령 API 가 다시 낸다) · 레지스트리 = L-3 본문.

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_ops_summary.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_self_report.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        P0sHumanInputs,
        P0sStrategyIds,
        SelfReportTexts,
        TrustedClock,
        routePatternOf;
import 'package:data_sync/data_sync.dart' show P0sHumanDecision;
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

const String _dev = 'dev-op-1';

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

const Map<String, String> _args = <String, String>{
  'yyyy_mm': '2026-08',
  'account_alias': '연금저축',
};

SelfReportSubmission _sub({
  String? m = '2026-08',
  String alias = '연금저축',
  String b = '242',
  String cash = '1,000,000',
}) => SelfReportSubmission(
  purpose: SelfReportPurpose.periodicAudit,
  yyyyMm: m,
  input: SelfReportInput(
    lines: <SelfReportLineInput>[
      const SelfReportLineInput(symbol: '069500', quantityText: '0'),
      SelfReportLineInput(symbol: '133690', quantityText: b),
      const SelfReportLineInput(symbol: '214980', quantityText: '0'),
      const SelfReportLineInput(symbol: '411060', quantityText: '0'),
      const SelfReportLineInput(symbol: '0085P0', quantityText: '0'),
    ],
    cashKrwText: cash,
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
  late OperatorSelfReport sr;
  bool resolveBody = false;

  setUp(() {
    clock = FakeClock(kst(2026, 9, 2, 10, 0));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(kst(2026, 9, 2, 10, 0));
    rt = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: _dev,
      trusted: trusted,
      humanDecision: P0sHumanDecision(
        inputs: P0sHumanInputs(aSymbol: '069500', accountByStrategy: _accounts),
        accountLabels: const <String, String>{},
        decisionRef: 'test',
      ),
    );
    rt.view.value = _viewOf(files.sim, OperatingMode.advisory);
    resolveBody = false;
    sr = OperatorSelfReport(
      rt,
      hasBody: (String r) =>
          r == AppRoutes.m5SelfAuditResolve ? resolveBody : true,
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

  int count(String sql) => files.sim.select(sql).first.columnAt(0) as int;

  group('세션 여닫기 · VM 흐름', () {
    test(
      '🔴 start = 동기로 연다(곧바로 읽어도 열림) · VM = 폼(원장 값 0 · 전 종목) · stop = 닫힘 문장',
      () async {
        final ActionResult r = sr.start('ar1', _args);
        expect(r.level, UiLevel.ok);
        expect(r.id, SettingsActionId.selfReportSessionStart);
        expect(sr.sessions.anyOpen(), isTrue);
        final SelfReportSession vm = sr.sessionOf(
          rt.view.value!,
          '2026-08',
          '연금저축',
        );
        expect(vm.sessionClosedText, isNull);
        expect(vm.result, isNull);
        expect(vm.titleText, '8월 정기 실사');
        expect(vm.accountLabel, '연금저축 계좌');
        expect(vm.asOfTradeDateText, '2026-08-31 종가 기준으로 적으십시오');
        expect(
          <String>[for (final SymbolOption s in vm.symbols) s.symbol],
          <String>['069500', '133690', '214980', '411060', '0085P0'],
        );
        expect(vm.asOf.observedAt, kst(2026, 9, 2, 10, 0));
        expect(vm.trust.grade, LedgerTrustGrade.selfReported);
        expect(vm.trust.lastVerifiedOn, isNull);

        // 주기 = 1시간(주기로는 다시 읽지 않는다 — 세션 바뀜 kick 만이 다시 낸다).
        final OperatorSelfReport slow = OperatorSelfReport(
          rt,
          hasBody: (String _) => true,
          sessions: sr.sessions,
          tick: const Duration(hours: 1),
        );
        final List<SelfReportSession> seen = <SelfReportSession>[];
        final StreamSubscription<SelfReportSession> sub = slow
            .watch('2026-08', '연금저축')
            .listen(seen.add);
        await until(() => seen.isNotEmpty);
        expect(seen.last.sessionClosedText, isNull);
        final ActionResult stop = sr.stop('ar2', _args);
        expect(stop.headline, SelfReportTexts.sessionClosed);
        await until(
          () => seen.last.sessionClosedText == SelfReportTexts.sessionClosed,
        );
        expect(sr.sessions.anyOpen(), isFalse);
        sr.start('ar3', _args);
        await until(() => seen.last.sessionClosedText == null);
        await sub.cancel();
      },
    );

    test('🔴 열지 못한 까닭 = 엔진 문장(신뢰 시각 모름 · 자동 매매 · 모르는 별칭) · 가림 0', () {
      trusted.at = null;
      final ActionResult r = sr.start('ar1', _args);
      expect(r.level, UiLevel.blocked);
      expect(r.headline, SelfReportTexts.closedTrustedTimeUnknown);
      expect(sr.sessions.anyOpen(), isFalse);
      expect(
        sr.sessionOf(rt.view.value!, '2026-08', '연금저축').sessionClosedText,
        SelfReportTexts.closedTrustedTimeUnknown,
      );
      trusted.at = kst(2026, 9, 2, 10, 0);
      rt.view.value = _viewOf(files.sim, OperatingMode.autoTrade);
      expect(sr.start('ar2', _args).headline, SelfReportTexts.closedAutoTrade);
      rt.view.value = _viewOf(files.sim, OperatingMode.advisory);
      expect(
        sr.start('ar3', <String, String>{
          'yyyy_mm': '2026-08',
          'account_alias': '없는계좌',
        }).headline,
        SelfReportTexts.closedUnknownAccount,
      );
      expect(sr.sessions.anyOpen(), isFalse);
    });

    test('🔴 args 화이트리스트(yyyy_mm · account_alias 둘) · 화면 상태 없음 = 오류', () {
      expect(
        () => sr.start('ar', const <String, String>{'yyyy_mm': '2026-08'}),
        throwsArgumentError,
      );
      expect(
        () => sr.stop('ar', <String, String>{..._args, 'x': '1'}),
        throwsArgumentError,
      );
      rt.view.value = null;
      expect(() => sr.start('ar', _args), throwsStateError);
    });
  });

  group('제출', () {
    test('🔴 집행 = 원장 한 트랜잭션 · 세션 닫음 · VM = 결과(차이 · 해소 링크 = 본문 있을 때만 · 다음 계좌)', () async {
      sr.start('ar1', _args);
      final List<SelfReportSession> seen = <SelfReportSession>[];
      final StreamSubscription<SelfReportSession> sub = sr
          .watch('2026-08', '연금저축')
          .listen(seen.add);
      await until(() => seen.isNotEmpty);
      final CommandReceipt r = sr.submit(_sub(), random: Random(3));
      expect(r.state, CommandState.executed);
      expect(r.stateLabel, '기록됨 — 실사 보고가 원장과 대조되었습니다');
      expect(r.kind, CommandKind.selfReportBalance);
      expect(r.issuedByDeviceId, _dev);
      expect(sr.sessions.anyOpen(), isFalse, reason: '원장 값은 제출 뒤에 보인다');
      expect(count('SELECT COUNT(*) FROM self_report_balance'), 1);
      expect(count('SELECT COUNT(*) FROM self_report_line'), 5);
      expect(
        files.sim
            .select(
              'SELECT reported_at, session_started_at FROM self_report_balance',
            )
            .single
            .values,
        <Object?>[
          kst(2026, 9, 2, 10, 0).toIso8601String(),
          kst(2026, 9, 2, 10, 0).toIso8601String(),
        ],
      );
      await until(() => seen.last.result != null);
      final SelfReportResult res = seen.last.result!;
      expect(seen.last.sessionClosedText, isNull);
      expect(res.diffs.single.deltaLabel, '133690 수량 −3주 (원장 245 / 자가 보고 242)');
      expect(res.diffs.single.actionLink, isNull);
      expect(res.resolveLink, isNull, reason: 'M5-13 본문 없음 = 링크 0');
      expect(res.nextAccountLink?.label, '다음 계좌 실사 — 일반 계좌');
      expect(
        res.nextAccountLink?.deepLink,
        'aaq://ledger/self-report/2026-08/일반',
      );
      expect(seen.last.trust.lastVerifiedOn, const TradeDate('2026-08-31'));
      resolveBody = true;
      expect(
        sr.sessionOf(rt.view.value!, '2026-08', '연금저축').result?.resolveLink,
        const LinkAction(
          label: '차이 해소하기',
          deepLink: 'aaq://m5/self-audit-resolve',
        ),
      );
      // 같은 달 다시 열기 = 열지 않는다(결과만).
      expect(sr.start('ar2', _args).headline, SelfReportTexts.alreadyAudited);
      expect(sr.sessions.anyOpen(), isFalse);
      expect(
        sr.submit(_sub(), random: Random(4)).rejectReasonCode,
        'SELF_REPORT_OUTSIDE_SESSION',
      );
      await sub.cancel();
    });

    test('🔴 차이 0 = 맞음 문장 · 마지막 계좌 = 다음 링크 0', () {
      sr.start('ar1', <String, String>{
        'yyyy_mm': '2026-08',
        'account_alias': '일반',
      });
      expect(
        sr
            .submit(
              _sub(alias: '일반', b: '0'),
              random: Random(1),
            )
            .state,
        CommandState.executed,
      );
      sr.start('ar2', _args);
      expect(
        sr.submit(_sub(b: '245'), random: Random(2)).state,
        CommandState.executed,
      );
      final SelfReportResult res = sr
          .sessionOf(rt.view.value!, '2026-08', '연금저축')
          .result!;
      expect(res.diffs, isEmpty);
      expect(res.emptyLabel, '실사 결과가 원장과 맞습니다');
      expect(res.nextAccountLink, isNull);
    });

    test(
      '🔴 거부 차례 — 달 없음 → 세션 밖 · 다른 계좌 세션 → 자동 매매 → 원문 → 신뢰 시각 → 리스 → 무결성 보관',
      () {
        String? code(CommandReceipt r) => r.rejectReasonCode;
        expect(
          code(sr.submit(_sub(m: null), random: Random(1))),
          'INPUT_INVALID',
        );
        expect(
          code(sr.submit(_sub(), random: Random(1))),
          'SELF_REPORT_OUTSIDE_SESSION',
        );
        sr.start('ar1', <String, String>{
          'yyyy_mm': '2026-08',
          'account_alias': '일반',
        });
        final CommandReceipt other = sr.submit(_sub(), random: Random(1));
        expect(code(other), 'INPUT_INVALID');
        expect(
          other.stateLabel,
          SelfReportTexts.inputInvalid(SelfReportTexts.accountMismatch),
        );
        sr.start('ar2', _args);
        rt.view.value = _viewOf(files.sim, OperatingMode.autoTrade);
        expect(
          code(sr.submit(_sub(), random: Random(1))),
          'OPERATING_MODE_MISMATCH',
        );
        rt.view.value = _viewOf(files.sim, OperatingMode.advisory);
        final CommandReceipt bad = sr.submit(_sub(b: ''), random: Random(1));
        expect(code(bad), 'INPUT_INVALID');
        expect(bad.stateLabel, contains('133690 TIGER 미국나스닥100 수량 칸이 비어 있습니다'));
        expect(
          sr.sessions.of('2026-08', '연금저축'),
          isNotNull,
          reason: '거부 = 세션 그대로',
        );
        trusted.at = null;
        expect(
          code(sr.submit(_sub(), random: Random(1))),
          'TRUSTED_TIME_UNKNOWN',
        );
        trusted.at = kst(2026, 9, 2, 10, 0);
        files.sim.execute(
          'INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) '
          "VALUES ('SUPABASE', NULL, 'SEALED', 3, '2026-09-01T00:00:00.000Z')",
        );
        expect(code(sr.submit(_sub(), random: Random(1))), 'LEASE_EXPIRED');
        files.sim.execute(
          "UPDATE sync_state SET status = 'OK' WHERE target = 'SUPABASE'",
        );
        files.sim.execute(
          "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-09-01T00:00:00Z', 'x')",
        );
        final CommandReceipt held = sr.submit(_sub(), random: Random(1));
        expect(held.state, CommandState.heldForIntegrity);
        expect(
          held.stateLabel,
          '보류됨 — 원장 무결성 점검 중이라 보관했습니다. 복구 뒤 일괄 확정 단계에서 처리됩니다',
        );
        expect(count('SELECT COUNT(*) FROM self_report_balance'), 0);
        expect(
          count(
            "SELECT COUNT(*) FROM command_inbox WHERE state = 'HELD_FOR_INTEGRITY'",
          ),
          1,
        );
        expect(count('SELECT COUNT(*) FROM ledger_diff'), 0);
        expect(
          files.sim
              .select(
                "SELECT lease_epoch FROM command_inbox WHERE state = 'HELD_FOR_INTEGRITY'",
              )
              .single['lease_epoch'],
          3,
          reason: '발행 맥락 = 지금 리스 세대',
        );
      },
    );

    test(
      '🔴 명령 API = 정기 실사를 이 조립으로 · 접수증을 다시 낸다(watchCommand) · 바인딩 없음 = 구현 없음',
      () async {
        final OperatorCommandApi api = OperatorCommandApi(
          rt,
          random: Random(5),
          selfReport: sr,
        );
        sr.start('ar1', _args);
        final CommandReceipt r = await api.submitSelfReportBalance(_sub());
        expect(r.state, CommandState.executed);
        expect(await api.watchCommand(r.commandId).first, r);
        final CommandReceipt local = await api.submitSelfReportBalance(
          _sub(m: null),
        );
        expect(local.rejectReasonCode, 'INPUT_INVALID');
        expect(await api.watchCommand(local.commandId).first, local);
        await expectLater(
          OperatorCommandApi(rt).submitSelfReportBalance(_sub()),
          throwsA(isA<UnsupportedError>()),
        );
        rt = OperatorRuntime(files: files, clock: clock, trusted: trusted);
        rt.view.value = _viewOf(files.sim, OperatingMode.advisory);
        expect(
          () => OperatorSelfReport(
            rt,
            hasBody: (String _) => true,
          ).submit(_sub(), random: Random(1)),
          throwsStateError,
          reason: '기기 id 없음',
        );
      },
    );
  });

  group('주입', () {
    test('🔴 설정 동작(실사 화면 주입) = 세션 둘만 · 결과 기록 · 그 밖 = 오류', () async {
      final OperatorSelfReportActions a = OperatorSelfReportActions(
        sr,
        clock: clock,
      );
      final Future<ActionResult> f = a.run(
        SettingsActionId.selfReportSessionStart,
        args: _args,
      );
      expect(sr.sessions.anyOpen(), isTrue, reason: '부른 자리에서 동기로');
      final ActionResult r = await f;
      expect(await a.watch(r.actionRunId).first, r);
      await a.run(SettingsActionId.selfReportSessionStop, args: _args);
      expect(sr.sessions.anyOpen(), isFalse);
      await expectLater(
        a.run(SettingsActionId.backupRunNow),
        throwsA(isA<UnsupportedError>()),
      );
      await expectLater(
        a.run(SettingsActionId.selfReportSessionStart),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(a.watch('없음').first, throwsStateError);
    });

    test('🔴 신뢰 창구 = 배지 원천 없음 그대로 · 실사 세션 = 이 조립', () async {
      final OperatorLedgerTrustRepository t = OperatorLedgerTrustRepository(
        selfReport: sr,
      );
      sr.start('ar1', _args);
      expect(
        (await t.watchSelfReportSession('2026-08', '연금저축').first)
            .sessionClosedText,
        isNull,
      );
      await expectLater(t.watchGrade().first, throwsA(isA<UnsupportedError>()));
      await expectLater(
        const OperatorLedgerTrustRepository()
            .watchSelfReportSession('2026-08', '연금저축')
            .first,
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('🔴 레지스트리 = L-3 본문(뒤집은 단언 — R228 까지 = 자리 부재) · `SELF_AUDIT_DUE` 링크 꼴이 본문으로 간다', () {
      expect(
        kOperatorRouteBodies.byPattern.containsKey(AppRoutes.ledgerSelfReport),
        isTrue,
      );
      expect(
        routePatternOf('aaq://ledger/self-report/2026-08/연금저축'),
        AppRoutes.ledgerSelfReport,
      );
      expect(
        kOperatorRouteBodies.byPattern.containsKey(
          AppRoutes.m5SelfAuditResolve,
        ),
        isFalse,
        reason: 'M5-13 = 아직(해소 링크 0)',
      );
    });

    test('🔴 kick 합류 — 원천 값 그대로 · kick 마다 지금 값 · 던지면 오류 · 취소 = 둘 다', () async {
      final StreamController<int> src = StreamController<int>();
      final StreamController<void> kicks = StreamController<void>.broadcast();
      int n = 100;
      final List<Object> got = <Object>[];
      final StreamSubscription<int> s = mergeKicks<int>(
        src.stream,
        kicks.stream,
        () => n == 0 ? throw StateError('x') : n++,
      ).listen(got.add, onError: got.add);
      src.add(1);
      kicks.add(null);
      await until(() => got.length == 2);
      expect(got, <Object>[1, 100]);
      n = 0;
      kicks.add(null);
      await until(() => got.length == 3);
      expect(got.last, isA<StateError>());
      await s.cancel();
      expect(kicks.hasListener, isFalse);
      unawaited(src.close());
      await kicks.close();
    });
  });
}
