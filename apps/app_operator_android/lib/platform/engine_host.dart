// operator 엔진 호스트 — 채널 · 알람 계획 · 깨어남 · FGS 알림의 조립(E11p2 · 설계 e11p-map P8 · P9 · P11 · 06 M1-11).
//
// 🔴 조립만 한다 — 알람 시각 = `nextOccurrence` · 문구 = `buildFgsNotice` · 갱신 = `shouldRepostFgs`(trading_runtime).
// 🔴 깨어나면: 주입된 [WakeHandler] 를 부르고(실제 잡 실행 = E11p3 조립) → 알람을 다시 건다 → CPU 붙잡기를 놓는다.
//    처리가 실패해도 재무장 · 놓기는 한다(다음 회차를 잃지 않게).

import 'dart:async';

import 'package:trading_runtime/trading_runtime.dart'
    show
        FgsNotice,
        FgsStatus,
        JobCalendars,
        JobOccurrence,
        JobSpec,
        buildFgsNotice,
        kJobTable,
        nextOccurrence,
        shouldRepostFgs;

import 'android_ops.dart';

/// 깨어남 처리기(E11p3 가 잡 실행기를 넣는다).
typedef WakeHandler = Future<void> Function(WakeEvent e);

/// 알람 계획 — 잡마다 다음 회차 1개(예정 시각 순).
class AlarmPlan {
  /// 만든다.
  const AlarmPlan(this.items, this.unplannable);

  /// 걸 알람.
  final List<AlarmItem> items;

  /// 달력 범위 밖 등으로 회차를 못 정한 잡 — 🔴 조용히 빼지 않고 돌려준다(부르는 쪽이 알린다).
  final List<String> unplannable;
}

/// [nowUtc] 뒤 잡마다 다음 회차(R43 B4 `nextOccurrence`) → 알람 목록.
AlarmPlan alarmPlanFor({
  required DateTime nowUtc,
  required JobCalendars calendars,
  List<JobSpec> specs = kJobTable,
}) {
  final List<AlarmItem> items = <AlarmItem>[];
  final List<String> missing = <String>[];
  for (final JobSpec s in specs) {
    try {
      final JobOccurrence o = nextOccurrence(s, calendars, nowUtc);
      items.add(
        AlarmItem(tag: '${s.job}@${o.fireDay.yyyyMmDd}', atUtc: o.scheduledUtc),
      );
    } on StateError {
      missing.add(s.job);
    } on ArgumentError {
      missing.add(s.job);
    }
  }
  items.sort((AlarmItem a, AlarmItem b) => a.atUtc.compareTo(b.atUtc));
  return AlarmPlan(items, missing);
}

/// FGS 알림 — 🔴 전이 때만 다시 띄운다(앱 04 §5-6 ③).
class FgsPresenter {
  /// 만든다.
  FgsPresenter(this._post);

  final Future<void> Function(FgsNotice n) _post;
  FgsNotice? _shown;

  /// [s] 를 띄운다 — 실제로 다시 띄웠으면 true.
  Future<bool> show(FgsStatus s) async {
    final FgsNotice n = buildFgsNotice(s);
    if (!shouldRepostFgs(_shown, n)) return false;
    await _post(n);
    _shown = n;
    return true;
  }
}

/// 엔진 호스트.
class OperatorEngineHost {
  /// 만든다.
  OperatorEngineHost({
    required AndroidOps ops,
    required JobCalendars calendars,
    required Map<String, String> channelNames,
    DateTime Function()? nowUtc,
    WakeHandler? onWake,
    void Function(String link)? onLink,
    List<JobSpec> specs = kJobTable,
  }) : _ops = ops,
       _cals = calendars,
       _names = channelNames,
       _now = nowUtc ?? (() => DateTime.now().toUtc()),
       _handler = onWake,
       _linkSink = onLink,
       _jobSpecs = specs,
       fgs = FgsPresenter(ops.postFgs);

  final AndroidOps _ops;
  final JobCalendars _cals;
  final Map<String, String> _names;
  final DateTime Function() _now;
  final WakeHandler? _handler;
  final void Function(String link)? _linkSink;
  final List<JobSpec> _jobSpecs;

  /// FGS 알림(엔진 상태가 바뀔 때 부른다).
  final FgsPresenter fgs;

  /// 마지막 계획(시험 · 진단).
  AlarmPlan? lastPlan;

  Future<void> _tail = Future<void>.value();

  /// 채널 → 계획 → 서비스 → 받기 시작(모아 둔 깨어남이 이때 온다).
  Future<void> start() async {
    await _ops.ensureChannels(_names);
    await rearm();
    await _ops.startService();
    await _ops.listen(
      onWake: _enqueue,
      onLink: (String l) => _linkSink?.call(l),
    );
  }

  /// 알람을 다시 건다.
  Future<AlarmPlan> rearm() async {
    final AlarmPlan p = alarmPlanFor(
      nowUtc: _now(),
      calendars: _cals,
      specs: _jobSpecs,
    );
    await _ops.arm(p.items);
    lastPlan = p;
    return p;
  }

  /// 🔴 깨어남은 한 줄로 차례대로 — 두 처리가 겹치지 않는다(원장 단일 쓰기).
  void _enqueue(WakeEvent e) {
    _chain(() => handleWake(e));
  }

  /// 줄 끝에 [task] 를 잇는다 — 🆕 R261 앞 처리가 던졌어도(재무장 실패 등) 뒤 처리는 돈다(줄이 멈추지 않게).
  Future<void> _chain(Future<void> Function() task) {
    final Future<void> next = _tail.then(
      (_) => task(),
      onError: (Object _) => task(),
    );
    _tail = next;
    return next;
  }

  /// 🆕 리뷰 3차 H1-1~H1-3(설계 13 §8 R261 · 01 §8 미결 235) — 화면 동작(온보딩 마무리 · 모의 개시 · simToAuto 커밋 · 승격 ·
  /// 안전 명령) 뒤 깨어남 한 번을 **같은 줄**에 넣는다(알람 깨어남과 겹치지 않게 · 원장 단일 쓰기) — 처리기(기동 판정 → 회차 →
  /// FGS → 화면 상태)만 부르고 끝나면(성공 · 실패) 완료 · 던지지 않는다(실패의 기록 · 알림 = 처리기 몫).
  /// 🔴 재무장 · CPU 놓기 0 — 이 깨어남은 Kotlin 이 CPU 를 붙잡아 건넨 것이 아니다(그 사이 온 알람 깨어남의 붙잡기를 끊지 않게 ·
  ///    알람 계획은 모드와 무관).
  /// 🔴 합치기 — 줄에 아직 시작 안 한 화면 깨어남이 있으면 그것을 돌려준다(그 깨어남이 지금까지의 쓰기를 본다 · 연속 확인 ·
  ///    재개 문항에도 깨어남 · 신뢰 시각 잼 한 번).
  Future<void> wakeNow() {
    final Future<void>? queued = _queuedApp;
    if (queued != null) return queued;
    final Future<void> mine = _chain(() async {
      _queuedApp = null;
      try {
        await _handler?.call(
          WakeEvent(reason: WakeReason.app, firedAtUtc: _now()),
        );
      } on Object {
        // 처리 실패의 기록 · 알림은 처리기(잡 규약 `runJob`) 몫.
      }
    });
    return _queuedApp = mine;
  }

  /// 줄에 있으나 아직 시작 안 한 화면 깨어남(없음 = null).
  Future<void>? _queuedApp;

  /// 깨어남 한 건 — 처리기 → 재무장 → 놓기(실패해도 뒤 둘은 한다).
  Future<void> handleWake(WakeEvent e) async {
    try {
      await _handler?.call(e);
    } on Object {
      // 처리 실패의 기록 · 알림은 처리기(잡 규약 `runJob`) 몫 — 여기서는 다음 회차를 지킨다.
    } finally {
      try {
        await rearm();
      } finally {
        await _ops.idle();
      }
    }
  }
}
