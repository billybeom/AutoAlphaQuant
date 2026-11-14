// E11p3d-1 화면 상태 · 셸 설정 원천 · 딥링크 중계(설계 13 §8 R104) — 실 SQLite.

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AppLinkOpener, FeatureFlags, OperatingMode, RunMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Opener implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;

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
      final sub = OperatorConfigRepository(rt.view)
          .watchFlags()
          .listen(got.add);
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
        OperatorConfigRepository(rt.view).watchFlags(),
        emits(
          isA<FeatureFlags>().having(
            (FeatureFlags x) => x.runMode,
            'runMode',
            RunMode.simInternal,
          ),
        ),
      );
    });

    test('🔴 원천 없는 흐름 = 오류(지어내지 않는다)', () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      addTearDown(f.close);
      final OperatorConfigRepository c = OperatorConfigRepository(
        OperatorRuntime(files: f, clock: clock).view,
      );
      await expectLater(c.watchSleeves(), emitsError(isA<UnsupportedError>()));
      await expectLater(
        c.watchRangePresets(),
        emitsError(isA<UnsupportedError>()),
      );
      await expectLater(
        c.watchContributionSetting(),
        emitsError(isA<UnsupportedError>()),
      );
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
}
