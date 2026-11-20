// E11p3d-1 화면 상태 · 셸 설정 원천 · 딥링크 중계(설계 13 §8 R104) — 실 SQLite.

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show Market, TrustedClock, frozenExchangeCalendar, p0sContributionConfig;
import 'package:data_sync/data_sync.dart'
    show ContributionChangeResult, ContributionSettingSource;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppLinkOpener,
        ContributionSetting,
        FeatureFlags,
        OperatingMode,
        RunMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.clock);
  final FakeClock clock;
  @override
  DateTime? trustedNowUtc() => clock.nowUtc();
}

class _Opener implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;

  OperatorConfigRepository configOf(
    OperatorRuntime rt, {
    Duration tick = const Duration(minutes: 1),
  }) => OperatorConfigRepository(
    rt.view,
    clock: rt.clock,
    kr: rt.calendars.kr,
    tick: tick,
  );

  setUp(() => clock = FakeClock(kst(2026, 12, 22, 9, 30)));

  group('기동 판정 → 화면 상태', () {
    test('🔴 온보딩 미완 = 모른다(null)', () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      addTearDown(f.close);
      expect(operatorViewOf(await bootEngine(f, clock: clock), f), isNull);
    });

    test('🔴 준비 = 그 원장(엔진과 같은 연결) · 모드 · 고정 플래그 · 설정 없으면 지문 빈 글자', () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      addTearDown(f.close);
      writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
      final OperatorView v = operatorViewOf(
        await bootEngine(f, clock: clock),
        f,
      )!;
      expect(identical(v.db, f.sim), true);
      expect(v.flags.runMode, RunMode.simInternal);
      expect(v.flags.operatingMode, OperatingMode.autoTrade);
      expect(v.flags.satelliteEnabled, false);
      expect(v.flags.webViewerEnabled, false);
      expect(v.flags.calendarEnabled, false);
      expect(v.flags.configHash, '');
    });

    test('🔴 거부(live) = live 원장 · live 모드(접두가 «모의»로 남지 않게)', () async {
      final dir = tempLedgerDir();
      final LedgerFiles f = openFiles(dir, clock);
      addTearDown(f.close);
      writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
      final Database live = writeLiveMode(dir, clock);
      addTearDown(live.close);
      final EngineBoot b = await bootEngine(f, clock: clock);
      expect(b, isA<EngineRejected>());
      final OperatorView v = operatorViewOf(b, f)!;
      expect(identical(v.db, f.liveIfExists()), true);
      expect(v.flags.runMode, RunMode.live);
      expect(v.flags.operatingMode, OperatingMode.autoTrade);
    });
  });

  group('셸 설정 원천', () {
    test('🔴 플래그 = 화면 상태 — 없으면 기다리고 바뀌면 다시 낸다', () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      addTearDown(f.close);
      final OperatorRuntime rt = OperatorRuntime(files: f, clock: clock);
      final List<FeatureFlags> got = <FeatureFlags>[];
      final sub = configOf(rt).watchFlags().listen(got.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);
      expect(got, isEmpty);
      writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
      rt.view.value = operatorViewOf(await bootEngine(f, clock: clock), f);
      await Future<void>.delayed(Duration.zero);
      expect(got.single.runMode, RunMode.simInternal);
    });

    test('🔴 이미 상태가 있으면 듣자마자 낸다', () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      addTearDown(f.close);
      writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
      final OperatorRuntime rt = OperatorRuntime(files: f, clock: clock);
      rt.view.value = operatorViewOf(await bootEngine(f, clock: clock), f);
      await expectLater(
        configOf(rt).watchFlags(),
        emits(
          isA<FeatureFlags>().having(
            (FeatureFlags x) => x.runMode,
            'runMode',
            RunMode.simInternal,
          ),
        ),
      );
    });

    // 🆕 E11q-q4a — 슬리브 · 기간 프리셋 = 엔진 원천이 섰다(오류 → 값 · 기간 = 화면 상태 원장 · 없으면 오류).
    test('🔴 슬리브 = 엔진 P0S 목록 · 기간 프리셋 = 화면 상태가 없으면 오류(지어내지 않는다)', () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      addTearDown(f.close);
      final OperatorConfigRepository c = configOf(
        OperatorRuntime(files: f, clock: clock),
      );
      expect((await c.watchSleeves().first).length, 4);
      await expectLater(c.watchRangePresets(), emitsError(isA<StateError>()));
    });

    group('🆕 월 납입(R120 — 엔진 운영값)', () {
      Future<OperatorRuntime> readyRt(LedgerFiles f) async {
        final OperatorRuntime rt = OperatorRuntime(files: f, clock: clock);
        writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
        rt.view.value = operatorViewOf(await bootEngine(f, clock: clock), f);
        return rt;
      }

      ContributionChangeResult change(
        LedgerFiles f,
        String amount,
        String run,
      ) => ContributionSettingSource(
        f.sim,
        trusted: _Trusted(clock),
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
        deviceId: 'test-device',
      ).change(amountInput: amount, actionRunId: run);

      Future<void> until(bool Function() ok) async {
        final Stopwatch w = Stopwatch()..start();
        while (!ok() && w.elapsed < const Duration(seconds: 5)) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      }

      test('🔴 화면 상태 없음(온보딩 전) = 오류 · 지어내지 않는다', () async {
        final LedgerFiles f = openFiles(tempLedgerDir(), clock);
        addTearDown(f.close);
        await expectLater(
          configOf(OperatorRuntime(files: f, clock: clock))
              .watchContributionSetting(),
          emitsError(isA<StateError>()),
        );
      });

      test('🔴 기록 없음 = P0S 기본값 · 기록하면 다시 낸다(같은 연결)', () async {
        final LedgerFiles f = openFiles(tempLedgerDir(), clock);
        addTearDown(f.close);
        final OperatorRuntime rt = await readyRt(f);
        final List<ContributionSetting> got = <ContributionSetting>[];
        final sub = configOf(rt).watchContributionSetting().listen(got.add);
        addTearDown(sub.cancel);
        await pumpEventQueue();
        expect(got, hasLength(1));
        expect(got.single.amount, p0sContributionConfig().defaultAmount);
        expect(change(f, '150000', 'run-1').ok, true);
        await pumpEventQueue();
        expect(got, hasLength(2));
        expect(got.last.lastChangedText, isNot(got.first.lastChangedText));
      });

      test('🔴 시간만 흘러도 주기마다 다시 계산 · 같은 값은 다시 내지 않는다', () async {
        final LedgerFiles f = openFiles(tempLedgerDir(), clock);
        addTearDown(f.close);
        final OperatorRuntime rt = await readyRt(f);
        final List<ContributionSetting> got = <ContributionSetting>[];
        final sub = configOf(
          rt,
          tick: const Duration(milliseconds: 10),
        ).watchContributionSetting().listen(got.add);
        addTearDown(sub.cancel);
        await pumpEventQueue();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(got, hasLength(1));
        clock.now = clock.now.add(const Duration(minutes: 1));
        await until(() => got.length >= 2);
        expect(got, hasLength(2));
        expect(got.last.asOf.observedAt, clock.nowUtc());
      });

      test('🔴 화면 상태를 따라간다(없어짐 = 오류 · 다시 서면 값)', () async {
        final LedgerFiles f = openFiles(tempLedgerDir(), clock);
        addTearDown(f.close);
        final OperatorRuntime rt = await readyRt(f);
        final OperatorView v = rt.view.value!;
        final List<Object> got = <Object>[];
        final sub = configOf(rt)
            .watchContributionSetting()
            .listen(got.add, onError: got.add);
        addTearDown(sub.cancel);
        await pumpEventQueue();
        expect(got.single, isA<ContributionSetting>());
        rt.view.value = null;
        await pumpEventQueue();
        expect(got.last, isA<StateError>());
        rt.view.value = v;
        await pumpEventQueue();
        expect(got.last, isA<ContributionSetting>());
      });
    });
  });

  group('딥링크 중계', () {
    test('🔴 화면이 서기 전 = 쥔다(맨 마지막 하나) · 서면 한 번 연다', () {
      final _Opener o = _Opener();
      bool ready = false;
      final LinkRelay r = LinkRelay(opener: () => o, ready: () => ready);
      r.receive('aaq://alerts/inbox');
      r.receive('aaq://alerts/detail/a1');
      expect(o.opened, isEmpty);
      expect(r.pending, 'aaq://alerts/detail/a1');
      r.deliver();
      expect(o.opened, isEmpty);
      ready = true;
      r.deliver();
      r.deliver();
      expect(o.opened, <String>['aaq://alerts/detail/a1']);
      expect(r.pending, isNull);
    });

    test('섰으면 바로 연다', () {
      final _Opener o = _Opener();
      LinkRelay(opener: () => o, ready: () => true).receive('aaq://x');
      expect(o.opened, <String>['aaq://x']);
    });
  });

  test('🔴 기기 id(R142) = 조립이 넣은 값 그대로 · 넣지 않으면 없음(플랫폼 밖 · 지어내지 않는다)', () {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    addTearDown(f.close);
    expect(OperatorRuntime(files: f, clock: clock).deviceId, isNull);
    expect(
      OperatorRuntime(
        files: f,
        clock: clock,
        deviceId: '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e',
      ).deviceId,
      '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e',
    );
  });
}
