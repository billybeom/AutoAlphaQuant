// 온보딩 읽기 모델 operator 판(E11p4b · 설계 13 §8 R125 · 앱 01 §25 · 06 M4-11 ②⑥⑦ · 01 §8 미결 155 · 158).
//
// 🔴 원장 = sim 파일(온보딩은 모의에서 시작한다 · 화면 상태가 없는 동안에도 읽는다 — `operatorDbProvider` 와 같은 갈래).
// 🔴 VM 짓기 · 글자 = 엔진(core `onboardingStartVmOf` · `onboardingModeChoiceVmOf` · `onboardingStepsVmOf` · `onboardingStepDetailVmOf`)
//    · 여기는 사실만 모은다 — 진척 행(`SqliteOnboardingProgressStore`) + Android 실측(알림 권한 o_05 · 배터리 예외 o_06).
// 🔴 다시 낸다 = 들을 때 · 진척 · 선택 표 변경(같은 연결) · [OperatorOnboardingRepository.tick] 마다(실측 다시 · 날짜 넘김) · 바뀐 값만.
// 🔴 마무리(O-04) · 재시작(R-01) = 다음 조각(4c · 4d) — 그 전 = 오류(라우트도 미등록 · 재시작 카드 링크 없음).
// 🔴 첫 실행 판정(미결 158) = [watchOnboardingDone] — `committed_at` 전이면 조립 앱 루트가 온보딩을 띄운다.

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show
        OnboardingStepFact,
        onboardingModeChoiceVmOf,
        onboardingStartVmOf,
        onboardingStepDetailVmOf,
        onboardingStepsVmOf;
import 'package:data_sync/data_sync.dart'
    show
        OnboardingChoice,
        SqliteOnboardingProgressStore,
        SqliteOnboardingStore,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        OnboardingFinishVm,
        OnboardingModeChoiceVm,
        OnboardingRepository,
        OnboardingStartVm,
        OnboardingStep,
        OnboardingStepDetailVm,
        OnboardingStepsVm,
        OnboardingTrack,
        RestartVm,
        StepState;
import 'package:sqlite3/sqlite3.dart' show Database;

import 'operator_runtime.dart';

/// 온보딩 실측(Android) — 모르면 null.
class OnboardingProbe {
  /// 만든다.
  const OnboardingProbe({
    required this.notificationsEnabled,
    required this.batteryExempt,
  });

  /// 알림 권한(o_05).
  final bool notificationsEnabled;

  /// 배터리 최적화 예외(o_06).
  final bool batteryExempt;
}

/// 🔴 첫 실행 판정 — 온보딩이 끝났나(`onboarding_choice.committed_at`) · 같은 연결로 바뀔 때마다.
Stream<bool> watchOnboardingDone(OperatorRuntime rt) => watchLedgerQuery<bool>(
  rt.files.sim,
  const <String>{'onboarding_choice'},
  () =>
      SqliteOnboardingStore(
        rt.files.sim,
        clock: rt.clock,
      ).choice()?.committed ??
      false,
);

/// 온보딩 읽기 모델(operator).
class OperatorOnboardingRepository implements OnboardingRepository {
  /// 만든다 — [tick] = 실측 · 날짜를 다시 보는 주기.
  OperatorOnboardingRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 다시 보는 주기.
  final Duration tick;

  OnboardingProbe? _probe;

  Database get _db => _rt.files.sim;

  OnboardingChoice? _choice() =>
      SqliteOnboardingStore(_db, clock: _rt.clock).choice();

  /// 사실 — 진척 행 + 실측(실측이 이긴다 · 실측 모름 = 진척 행 그대로).
  Map<String, OnboardingStepFact> _facts() {
    final Map<String, OnboardingStepFact> f = <String, OnboardingStepFact>{
      ...SqliteOnboardingProgressStore(_db, clock: _rt.clock).facts(),
    };
    final OnboardingProbe? p = _probe;
    if (p != null) {
      f['o_05'] = OnboardingStepFact(
        state: p.notificationsEnabled
            ? StepState.verified
            : StepState.notStarted,
      );
      f['o_06'] = OnboardingStepFact(
        state: p.batteryExempt ? StepState.verified : StepState.notStarted,
      );
    }
    return f;
  }

  Future<void> _measure() async {
    final Future<OnboardingProbe?> Function()? probe = _rt.onboardingProbe;
    if (probe == null) return;
    try {
      _probe = await probe();
    } on Object {
      _probe = null;
    }
  }

  /// 진척 · 선택 표 + 실측 + 주기를 따라 다시 짓는 흐름(바뀐 값만).
  Stream<T> _live<T>(T Function() build) {
    late final StreamController<T> c;
    StreamSubscription<T>? sub;
    Timer? timer;
    bool has = false;
    T? last;

    void put(T v) {
      if (c.isClosed || (has && v == last)) return;
      has = true;
      last = v;
      c.add(v);
    }

    Future<void> refresh() async {
      await _measure();
      if (c.isClosed) return;
      try {
        put(build());
      } on Object catch (e, st) {
        if (!c.isClosed) c.addError(e, st);
      }
    }

    c = StreamController<T>(
      onListen: () {
        sub = watchLedgerQuery<T>(
          _db,
          SqliteOnboardingProgressStore.watchedTables,
          build,
        ).listen(put, onError: c.addError);
        timer = Timer.periodic(tick, (_) => unawaited(refresh()));
        unawaited(refresh());
      },
      onCancel: () async {
        timer?.cancel();
        await sub?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  @override
  Stream<OnboardingStartVm> watchStart() => Stream<OnboardingStartVm>.value(
    // 🔴 재시작(R-01) = 4d 전 → 그 카드의 링크 없음 · 조회 전용 카드 = operator 앱엔 없음.
    onboardingStartVmOf(reconnectReady: false, viewerTrack: false),
  );

  @override
  Stream<OnboardingModeChoiceVm> watchModeChoice() =>
      watchLedgerQuery<OnboardingModeChoiceVm>(
        _db,
        const <String>{'onboarding_choice'},
        () {
          final OnboardingChoice? c = _choice();
          return onboardingModeChoiceVmOf(
            selected: c?.operatingMode,
            committed: c?.committed ?? false,
          );
        },
      );

  @override
  Stream<OnboardingStepsVm> watchStepList() => _live<OnboardingStepsVm>(
    () => onboardingStepsVmOf(
      mode: _choice()?.operatingMode,
      facts: _facts(),
      nowUtc: _rt.clock.nowUtc(),
    ),
  );

  @override
  Stream<OnboardingStepDetailVm> watchStep(String stepId) =>
      _live<OnboardingStepDetailVm>(
        () => onboardingStepDetailVmOf(
          stepId: stepId,
          mode: _choice()?.operatingMode,
          facts: _facts(),
          nowUtc: _rt.clock.nowUtc(),
        ),
      );

  @override
  Stream<OnboardingFinishVm> watchFinish() => Stream<OnboardingFinishVm>.error(
    UnsupportedError('watchFinish: 4c 전(R125)'),
  );

  @override
  Stream<RestartVm> watchRestart() =>
      Stream<RestartVm>.error(UnsupportedError('watchRestart: 4d 전(R125)'));

  @override
  Stream<List<OnboardingStep>> watchSteps(OnboardingTrack track) =>
      Stream<List<OnboardingStep>>.error(
        UnsupportedError('watchSteps: 옛 창구 — v1.16 화면은 watchStepList(미결 149)'),
      );
}
