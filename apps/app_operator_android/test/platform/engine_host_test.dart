// E11p2 · P8 · P9 · P10 — 엔진 호스트 조립 · 알람 계획 · FGS «전이 때만» · 깨어남 직렬 처리.

import 'dart:async';

import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart'
    show Market, frozenExchangeCalendar;
import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode, UiLevel;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_runtime/trading_runtime.dart';

const MethodChannel _ch = MethodChannel(OperatorChannelNames.ops);

final JobCalendars _cals = JobCalendars(
  kr: frozenExchangeCalendar(Market.kr),
  us: frozenExchangeCalendar(Market.us),
);

/// Kotlin 흉내 — 부른 순서를 적는다.
class _Native {
  final List<String> log = <String>[];
  final List<Object?> armed = <Object?>[];
  final List<Map<Object?, Object?>> posted = <Map<Object?, Object?>>[];

  Future<Object?> handle(MethodCall c) async {
    log.add(c.method);
    switch (c.method) {
      case 'arm':
        armed.add((c.arguments as Map<Object?, Object?>)['items']);
        return true;
      case 'postFgs':
        posted.add(c.arguments as Map<Object?, Object?>);
    }
    return null;
  }
}

Future<void> _wakeFromNative(Map<String, Object?> wire) async {
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        OperatorChannelNames.ops,
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('onWake', wire),
        ),
        (_) {},
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Native native;
  final DateTime now = DateTime.utc(2026, 11, 16, 0, 30); // KST 월 09:30

  void install(Future<Object?> Function(MethodCall)? h) =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_ch, h);

  setUp(() {
    native = _Native();
    install(native.handle);
  });
  tearDown(() => install(null));

  group('알람 계획', () {
    test('잡마다 nextOccurrence 하나 · 예정 시각 순 · 꼬리표 = 잡@발화 날', () {
      final AlarmPlan p = alarmPlanFor(nowUtc: now, calendars: _cals);
      expect(p.unplannable, isEmpty);
      expect(p.items, hasLength(kJobTable.length));
      for (final JobSpec s in kJobTable) {
        final JobOccurrence o = nextOccurrence(s, _cals, now);
        final AlarmItem i = p.items.singleWhere(
          (AlarmItem i) => i.tag.startsWith('${s.job}@'),
        );
        expect(i.tag, '${s.job}@${o.fireDay.yyyyMmDd}');
        expect(i.atUtc, o.scheduledUtc);
        expect(i.atUtc.isAfter(now), isTrue);
      }
      final List<DateTime> at = p.items.map((AlarmItem i) => i.atUtc).toList();
      expect(at, List<DateTime>.of(at)..sort());
    });

    test('🔴 달력 범위 밖 = 조용히 빼지 않고 unplannable 로 돌려준다', () {
      final AlarmPlan p = alarmPlanFor(
        nowUtc: DateTime.utc(2200),
        calendars: _cals,
      );
      expect(p.items, isEmpty);
      expect(p.unplannable, kJobTable.map((JobSpec s) => s.job).toList());
    });
  });

  group('FGS 알림', () {
    test('🔴 전이 때만 다시 띄운다(같은 상태 = 0회)', () async {
      final List<FgsNotice> sent = <FgsNotice>[];
      final FgsPresenter f = FgsPresenter((FgsNotice n) async => sent.add(n));
      const FgsStatus ok = FgsStatus(
        runMode: RunMode.live,
        operatingMode: OperatingMode.autoTrade,
        level: UiLevel.ok,
      );
      expect(await f.show(ok), isTrue);
      expect(await f.show(ok), isFalse);
      expect(await f.show(ok), isFalse);
      const FgsStatus bad = FgsStatus(
        runMode: RunMode.live,
        operatingMode: OperatingMode.autoTrade,
        level: UiLevel.act,
        headline: '대사 차이 1건',
      );
      expect(await f.show(bad), isTrue);
      expect(await f.show(ok), isTrue);
      expect(sent, hasLength(3));
      expect(sent.first, buildFgsNotice(ok));
    });

    test('와이어 = 채널 id · 완성 문자열 · 레벨 글자 · 링크(조립 0)', () async {
      final FgsNotice n = buildFgsNotice(
        const FgsStatus(
          runMode: RunMode.live,
          operatingMode: OperatingMode.autoTrade,
          level: UiLevel.blocked,
          headline: '킬스위치',
          p0AlertId: 'a1',
        ),
      );
      await AndroidOps().postFgs(n);
      expect(native.posted.single, <String, Object?>{
        'channel': 'ops_p0',
        'text': n.text,
        'level': 'BLOCKED',
        'link': n.link,
      });
    });
  });

  group('엔진 호스트', () {
    OperatorEngineHost host({WakeHandler? onWake}) => OperatorEngineHost(
      ops: AndroidOps(),
      calendars: _cals,
      channelNames: kOpsChannelNames,
      nowUtc: () => now,
      onWake: onWake,
    );

    test('시작 순서 = 채널 → 알람 → 서비스 → 준비됨', () async {
      await host().start();
      expect(native.log, <String>[
        'ensureChannels',
        'arm',
        'startService',
        'ready',
      ]);
      expect(native.armed.single, hasLength(kJobTable.length));
    });

    test('🔴 처리기가 실패해도 다시 걸고 · 놓는다', () async {
      final OperatorEngineHost h = host(
        onWake: (_) async => throw StateError('x'),
      );
      await h.handleWake(WakeEvent(reason: WakeReason.alarm, firedAtUtc: now));
      expect(native.log, <String>['arm', 'idle']);
    });

    test('🔴 깨어남은 한 줄로 — 앞 처리가 끝나야 뒤가 시작한다', () async {
      final List<String> seen = <String>[];
      final Completer<void> gate = Completer<void>();
      final OperatorEngineHost h = host(
        onWake: (WakeEvent e) async {
          seen.add('start ${e.tag}');
          if (e.tag == 'a') await gate.future;
          seen.add('end ${e.tag}');
        },
      );
      await h.start();
      await _wakeFromNative(<String, Object?>{
        'reason': 'alarm',
        'tag': 'a',
        'firedAtMs': 1,
      });
      await _wakeFromNative(<String, Object?>{
        'reason': 'alarm',
        'tag': 'b',
        'firedAtMs': 2,
      });
      await pumpEventQueue();
      expect(seen, <String>['start a']);
      gate.complete();
      await pumpEventQueue();
      expect(seen, <String>['start a', 'end a', 'start b', 'end b']);
    });

    group('🆕 리뷰 3차 H1(R261) — 화면 동작 뒤 깨어남 wakeNow', () {
      test(
        '🔴 같은 줄 — 앞 알람 깨어남이 끝난 뒤 · 처리기 한 번(까닭 = app · 부팅 아님) · 재무장 · CPU 놓기 0',
        () async {
          final List<String> seen = <String>[];
          final Completer<void> gate = Completer<void>();
          final OperatorEngineHost h = host(
            onWake: (WakeEvent e) async {
              seen.add('start ${e.reason.wire}');
              if (e.reason == WakeReason.alarm) await gate.future;
              seen.add('end ${e.reason.wire}');
            },
          );
          await h.start();
          native.log.clear();
          await _wakeFromNative(<String, Object?>{
            'reason': 'alarm',
            'tag': 'a',
            'firedAtMs': 1,
          });
          bool done = false;
          final Future<void> w = h.wakeNow().then((_) => done = true);
          await pumpEventQueue();
          expect(seen, <String>['start alarm'], reason: '알람 처리 중엔 기다린다');
          expect(done, isFalse);
          gate.complete();
          await w;
          expect(seen, <String>[
            'start alarm',
            'end alarm',
            'start app',
            'end app',
          ]);
          // 알람 깨어남 몫(재무장 · 놓기) 하나뿐 — wakeNow 는 둘 다 하지 않는다.
          expect(native.log, <String>['arm', 'idle']);
          expect(
            wakeBootOf(WakeEvent(reason: WakeReason.app, firedAtUtc: now)),
            (booting: false, bootId: null),
          );
        },
      );

      test('🔴 합치기 — 아직 시작 안 한 화면 깨어남에 합친다 · 시작한 뒤 요청 = 새 깨어남', () async {
        final List<String> seen = <String>[];
        final Completer<void> gate = Completer<void>();
        final Completer<void> appGate = Completer<void>();
        final OperatorEngineHost h = host(
          onWake: (WakeEvent e) async {
            seen.add(e.reason.wire);
            if (e.reason == WakeReason.alarm) await gate.future;
            if (e.reason == WakeReason.app && seen.length == 2) {
              await appGate.future;
            }
          },
        );
        await h.start();
        await _wakeFromNative(<String, Object?>{
          'reason': 'alarm',
          'tag': 'a',
          'firedAtMs': 1,
        });
        final Future<void> w1 = h.wakeNow();
        final Future<void> w2 = h.wakeNow();
        final Future<void> w3 = h.wakeNow();
        expect(identical(w1, w2) && identical(w2, w3), isTrue);
        gate.complete();
        await pumpEventQueue();
        expect(seen, <String>['alarm', 'app'], reason: '셋이 한 번');
        // 시작한(처리 중) 화면 깨어남 뒤 요청 = 새 깨어남(그 뒤 쓰기를 보도록).
        final Future<void> w4 = h.wakeNow();
        expect(identical(w4, w1), isFalse);
        appGate.complete();
        await Future.wait(<Future<void>>[w1, w4]);
        expect(seen, <String>['alarm', 'app', 'app']);
      });

      test('🔴 처리기가 던져도 wakeNow 는 끝난다(던지지 않는다) · 뒤 깨어남은 돈다', () async {
        int calls = 0;
        final OperatorEngineHost h = host(
          onWake: (WakeEvent e) async {
            calls++;
            if (calls == 1) throw StateError('x');
          },
        );
        await h.wakeNow();
        await h.wakeNow();
        expect(calls, 2);
        expect(native.log, isEmpty);
      });

      test(
        '🔴 앞 알람 깨어남의 재무장이 던져도 줄이 멈추지 않는다(뒤 wakeNow · 알람 깨어남이 돈다)',
        () async {
          int armCalls = 0;
          install((MethodCall c) async {
            native.log.add(c.method);
            if (c.method == 'arm' && ++armCalls == 2) {
              throw PlatformException(code: 'arm');
            }
            return c.method == 'arm' ? true : null;
          });
          final List<String> seen = <String>[];
          final OperatorEngineHost h = host(
            onWake: (WakeEvent e) async => seen.add(e.tag ?? e.reason.wire),
          );
          await h.start();
          await _wakeFromNative(<String, Object?>{
            'reason': 'alarm',
            'tag': 'a',
            'firedAtMs': 1,
          });
          await h.wakeNow();
          await _wakeFromNative(<String, Object?>{
            'reason': 'alarm',
            'tag': 'b',
            'firedAtMs': 2,
          });
          await pumpEventQueue();
          expect(seen, <String>['a', 'app', 'b']);
        },
      );
    });
  });
}
