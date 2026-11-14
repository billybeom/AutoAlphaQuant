// 운영 채널 어댑터 — FGS 알림 · 정확 알람 · 깨어남 · 자가진단(E11p2 · 설계 e11p-map P8 · P10 · P12 · 06 M1-11 · M1-15).
//
// 실물 = Kotlin `OpsChannel` · `EngineService` · `AlarmPlanner` · `OpsNotifications`.
// 🔴 판정 · 문구 0 — 알림 문구는 `buildFgsNotice`, 알람 시각은 `nextOccurrence`, 놓친 발화는 `wakeDecisions`(trading_runtime).

import 'package:flutter/services.dart';
import 'package:trading_runtime/trading_runtime.dart' show FgsNotice;

import 'operator_channels.dart';

/// 깨어난 까닭(Kotlin `Wake` 의 글자).
enum WakeReason {
  /// 정확 알람.
  alarm('alarm'),

  /// 부팅 완료.
  boot('boot'),

  /// 앱 갱신 설치.
  packageReplaced('package_replaced'),

  /// 시각 변경.
  timeSet('time_set'),

  /// 시간대 변경.
  timezone('timezone'),

  /// 서비스 시작(화면 · 콜드 스타트).
  start('start'),

  /// 모르는 글자(새 Kotlin · 낡은 Dart) — 버리지 않고 «깨어남»으로 다룬다.
  unknown('?');

  const WakeReason(this.wire);

  /// 와이어 글자.
  final String wire;

  /// 글자 → 까닭.
  static WakeReason of(String? w) => WakeReason.values.firstWhere(
    (WakeReason r) => r.wire == w,
    orElse: () => WakeReason.unknown,
  );
}

/// 깨어남 한 건.
class WakeEvent {
  /// 만든다.
  const WakeEvent({
    required this.reason,
    required this.firedAtUtc,
    this.tag,
    this.scheduledAtUtc,
  });

  /// 와이어 → 사건(꼴이 틀리면 null).
  static WakeEvent? fromWire(Object? raw) {
    if (raw is! Map) return null;
    final Object? fired = raw['firedAtMs'];
    if (fired is! int) return null;
    final Object? sched = raw['scheduledAtMs'];
    final Object? tag = raw['tag'];
    return WakeEvent(
      reason: WakeReason.of(raw['reason'] as String?),
      firedAtUtc: DateTime.fromMillisecondsSinceEpoch(fired, isUtc: true),
      tag: tag is String ? tag : null,
      scheduledAtUtc: sched is int
          ? DateTime.fromMillisecondsSinceEpoch(sched, isUtc: true)
          : null,
    );
  }

  /// 까닭.
  final WakeReason reason;

  /// 알람 꼬리표(알람만).
  final String? tag;

  /// 예정 시각(알람만).
  final DateTime? scheduledAtUtc;

  /// 실제 시각.
  final DateTime firedAtUtc;

  /// 늦은 정도(알람만) — 실측(D11) 재료.
  Duration? get delay =>
      scheduledAtUtc == null ? null : firedAtUtc.difference(scheduledAtUtc!);
}

/// 알람 한 개.
class AlarmItem {
  /// 만든다.
  const AlarmItem({required this.tag, required this.atUtc});

  /// 꼬리표(잡@발화 날).
  final String tag;

  /// 울릴 시각.
  final DateTime atUtc;
}

/// 자가진단 사실(06 M1-15 «Android 생존 자가진단») — 🔴 사실만 · 문구는 엔진.
class SurvivalFacts {
  /// 만든다.
  const SurvivalFacts({
    required this.notificationsEnabled,
    required this.exactAlarm,
    required this.batteryExempt,
    required this.p0BypassDnd,
    required this.fgsRunning,
    required this.fgsStartDenied,
  });

  /// 와이어 → 사실 — 🔴 모르는 칸 · 꼴 틀림 = false(«좋음»으로 지어내지 않는다).
  factory SurvivalFacts.fromWire(Object? raw) {
    final Map<Object?, Object?> m = raw is Map
        ? raw
        : const <Object?, Object?>{};
    bool b(String k) => m[k] == true;
    final Object? d = m['fgsStartDenied'];
    return SurvivalFacts(
      notificationsEnabled: b('notificationsEnabled'),
      exactAlarm: b('exactAlarm'),
      batteryExempt: b('batteryExempt'),
      p0BypassDnd: b('p0BypassDnd'),
      fgsRunning: b('fgsRunning'),
      fgsStartDenied: d is int ? d : 0,
    );
  }

  /// 알림 허용.
  final bool notificationsEnabled;

  /// 정확 알람 가능.
  final bool exactAlarm;

  /// 배터리 최적화 제외.
  final bool batteryExempt;

  /// P0 채널 방해금지 관통.
  final bool p0BypassDnd;

  /// FGS 실행 중.
  final bool fgsRunning;

  /// 백그라운드 FGS 시작이 막힌 횟수(누적).
  final int fgsStartDenied;
}

/// 앱 전용 폴더(E11p3a Q1).
class OperatorPaths {
  /// 만든다.
  const OperatorPaths({required this.files, required this.noBackup});

  /// 채널 값 → 폴더 · 꼴이 아니면 null.
  static OperatorPaths? fromWire(Object? w) {
    if (w is! Map<Object?, Object?>) return null;
    final Object? f = w['files'];
    final Object? n = w['noBackup'];
    if (f is! String || n is! String || f.isEmpty || n.isEmpty) return null;
    return OperatorPaths(files: f, noBackup: n);
  }

  /// `filesDir`.
  final String files;

  /// `noBackupFilesDir`.
  final String noBackup;

  /// 엔진 원장 폴더(`noBackup/engine`).
  String get engineDir => '$noBackup/engine';
}

/// 운영 채널 어댑터.
class AndroidOps {
  /// 만든다 — [channel] 은 시험용 대체.
  AndroidOps({MethodChannel? channel})
    : _ch = channel ?? const MethodChannel(OperatorChannelNames.ops);

  final MethodChannel _ch;

  /// 깨어남 · 링크 받기를 시작하고 Kotlin 에 «준비됨»을 알린다(모아 둔 것이 그때 온다).
  Future<void> listen({
    required void Function(WakeEvent e) onWake,
    required void Function(String link) onLink,
  }) async {
    _ch.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onWake':
          final WakeEvent? e = WakeEvent.fromWire(call.arguments);
          if (e != null) onWake(e);
        case 'onLink':
          final Object? l = call.arguments;
          if (l is String) onLink(l);
      }
      return null;
    });
    await _ch.invokeMethod<void>('ready');
  }

  /// 채널 둘을 만든다 — [names] = 채널 id → 표시 이름.
  Future<void> ensureChannels(Map<String, String> names) => _ch
      .invokeMethod<void>('ensureChannels', <String, Object?>{'names': names});

  /// FGS 알림을 띄운다 — 🔴 부르는 쪽이 «전이 때만» 부른다(`FgsPresenter`).
  Future<void> postFgs(FgsNotice n) =>
      _ch.invokeMethod<void>('postFgs', <String, Object?>{
        'channel': n.channel.id,
        'text': n.text,
        'level': n.level.wire,
        'link': n.link,
      });

  /// FGS 를 띄운다(이미 돌면 아무 일 없음).
  Future<void> startService() => _ch.invokeMethod<void>('startService');

  /// 알람 계획을 통째로 바꾼다 — 정확하게 걸렸으면 true.
  Future<bool> arm(List<AlarmItem> items) async =>
      await _ch.invokeMethod<bool>('arm', <String, Object?>{
        'items': <Map<String, Object?>>[
          for (final AlarmItem i in items)
            <String, Object?>{
              'tag': i.tag,
              'atMs': i.atUtc.toUtc().millisecondsSinceEpoch,
            },
        ],
      }) ??
      false;

  /// 자가진단 사실.
  Future<SurvivalFacts> diagnose() async =>
      SurvivalFacts.fromWire(await _ch.invokeMethod<Object?>('diagnose'));

  /// 깨어남 처리 끝 — CPU 붙잡기를 놓는다.
  Future<void> idle() => _ch.invokeMethod<void>('idle');

  /// 앱 전용 폴더(E11p3a Q1) — 꼴이 아니면 [StateError](경로를 지어내지 않는다).
  Future<OperatorPaths> paths() async {
    final OperatorPaths? p = OperatorPaths.fromWire(
      await _ch.invokeMethod<Object?>('paths'),
    );
    if (p == null) throw StateError('paths: 채널 응답 꼴이 아니다');
    return p;
  }

  /// 알림 탭으로 열렸으면 그 링크(한 번만).
  Future<String?> takeLaunchLink() =>
      _ch.invokeMethod<String>('takeLaunchLink');
}
