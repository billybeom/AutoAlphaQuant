// E11p2 · P8 · P9 · P10 — 엔진 호스트 조립 · 알람 계획 · FGS «전이 때만» · 깨어남 직렬 처리.

import 'dart:async';

import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart'
    show Market, frozenExchangeCalendar;
import 'package:domain_contracts/domain_contracts.dart' show UiLevel;
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
      const FgsStatus ok = FgsStatus(level: UiLevel.ok);
      expect(await f.show(ok), isTrue);
      expect(await f.show(ok), isFalse);
      expect(await f.show(ok), isFalse);
      const FgsStatus bad = FgsStatus(level: UiLevel.act, headline: '대사 차이 1건');
      expect(await f.show(bad), isTrue);
      expect(await f.show(ok), isTrue);
      expect(sent, hasLength(3));
      expect(sent.first, buildFgsNotice(ok));
    });

    test('와이어 = 채널 id · 완성 문자열 · 레벨 글자 · 링크(조립 0)', () async {
      final FgsNotice n = buildFgsNotice(
        const FgsStatus(
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
  });
}
