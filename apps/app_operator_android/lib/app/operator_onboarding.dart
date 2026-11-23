// 온보딩 읽기 모델 operator 판(E11p4b · 설계 13 §8 R125 · 앱 01 §25 · 06 M4-11 ②⑥⑦ · 01 §8 미결 155 · 158).
//
// 🔴 원장 = sim 파일(온보딩은 모의에서 시작한다 · 화면 상태가 없는 동안에도 읽는다 — `operatorDbProvider` 와 같은 갈래).
// 🔴 VM 짓기 · 글자 = 엔진(core `onboardingStartVmOf` · `onboardingModeChoiceVmOf` · `onboardingStepsVmOf` · `onboardingStepDetailVmOf`)
//    · 여기는 사실만 모은다 — 진척 행(`SqliteOnboardingProgressStore`) + Android 실측(알림 권한 o_05 · 배터리 예외 o_06).
// 🔴 다시 낸다 = 들을 때 · 진척 · 선택 표 변경(같은 연결) · [OperatorOnboardingRepository.tick] 마다(실측 다시 · 날짜 넘김) · 바뀐 값만.
// 🆕 R248 — 재시작(R-01) = 엔진 `restartVmOf` · 사실 = Supabase 기기 원장 읽기(`SupabaseDeviceLedger` · 읽기만) + 신뢰 시각 +
//    재개 사다리 백업 기준(운영 설정) + 이 폰의 비상 회수 기록(sim `X1_EMERGENCY_REVOKE`) · 첫 화면 링크 = 읽기 조립이 있을 때만.
//    다시 읽기 = 진척 · 받은편지 표 변경(연결 · 로그인 · 비상 기록) · 로그인 자리의 `poke` · 주기(리스 남은 시간).
// 🆕 E11p4c(R127) — 마무리(O-04) = 엔진 `onboardingFinishVmOf` · 사실 = 선택 · 서약(`pledge`) · 시작 선언(개시 결정) ·
//    설정 해시(모의 개시 뒤) · ③ 생체 · ④ 셀프테스트 · ⑤ 복구 카드 = 원천 0(null — 엔진이 막힘으로 그린다) · 고르기 전 = 오류.
// 🔴 첫 실행 판정(미결 158) = [watchOnboardingDone] — `committed_at` 전이면 조립 앱 루트가 온보딩을 띄운다.

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show
        OnboardingFinishFacts,
        OnboardingStepFact,
        kOnboardingStageSignedIn,
        goldenSelftestFactOf,
        kDeviceGoldenSuite,
        RestartFacts,
        onboardingFinishVmOf,
        onboardingModeChoiceVmOf,
        onboardingStartVmOf,
        onboardingStepDetailVmOf,
        onboardingStepsVmOf,
        restartVmOf;
import 'package:data_sync/data_sync.dart'
    show
        DeviceLedgerRead,
        OnboardingChoice,
        OpsConfigRead,
        OpsConfigReady,
        RecoveryCardFact,
        SqliteOnboardingProgressStore,
        SqliteOnboardingStore,
        SqlitePledgeStore,
        SqliteX1EmergencyStore,
        SupabaseDeviceLedger,
        SupabaseFirstClaim,
        currentP0sOpsConfig,
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

import 'operator_biometric.dart';
import 'operator_golden.dart' show OperatorGolden;
import 'operator_runtime.dart';

/// 온보딩 실측(Android) — 모르면 null.
class OnboardingProbe {
  /// 만든다.
  const OnboardingProbe({
    required this.notificationsEnabled,
    required this.batteryExempt,
    this.supabaseSignedIn = false,
  });

  /// 알림 권한(o_05).
  final bool notificationsEnabled;

  /// 배터리 최적화 예외(o_06).
  final bool batteryExempt;

  /// 🆕 E11k-d2(R216) — 이 기기에 Supabase Auth 세션이 있다(금고 새로고침 토큰 · o_07 ③ 로그인됨).
  final bool supabaseSignedIn;
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
    // 🆕 E11k-d2(R216) — o_07 진행 중(② 통과)에서 로그인됨 = 안쪽 지점만(상태 · 슬롯 그대로 · 확인 글자 = 엔진).
    //    원천 = 실측(금고 세션) 또는 이 프로세스의 로그인(실측 주기 전에도 바로 보이게).
    final OnboardingStepFact? o7 = f['o_07'];
    final bool signedIn =
        (p?.supabaseSignedIn ?? false) || _rt.supabaseAuth?.userId != null;
    if (o7 != null && o7.state == StepState.inProgress && signedIn) {
      f['o_07'] = OnboardingStepFact(
        state: o7.state,
        verifiedUntil: o7.verifiedUntil,
        failureReasonCode: o7.failureReasonCode,
        stage: kOnboardingStageSignedIn,
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
  Stream<T> _live<T>(
    T Function() build, {
    Set<String> tables = SqliteOnboardingProgressStore.watchedTables,
    bool golden = false,
  }) {
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
      // 🆕 R167 — 마무리 ④ = 골든 자산 지문 · 전체 수(처음 한 번 · 못 읽으면 원천 없음).
      if (golden) {
        try {
          await _rt.golden?.prepare();
        } on Object {
          // 원천 없음 그대로(④ 게이트 UNKNOWN).
        }
      }
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
          tables,
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
    // 🆕 R248 — 재시작(R-01) 링크 = 기기 원장 읽기가 조립돼 있을 때만(생산자 있음) · 조회 전용 카드 = operator 앱엔 없음.
    onboardingStartVmOf(
      reconnectReady: _rt.deviceLedger != null,
      viewerTrack: false,
    ),
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

  /// 🆕 R127 — 마무리가 다시 읽는 표(선택 · 서약 · 개시 결정 · 설정 판).
  static const Set<String> finishTables = <String>{
    'onboarding_choice',
    'pledge',
    'decision_log',
    'config_versions',
    // 🆕 R159 — ③ 생체 서명 기록.
    'command_inbox',
    // 🆕 R167 — ④ 골든 셀프테스트 기록.
    'reconciliation_log',
  };

  /// 🆕 R127 — 마무리 사실(고르기 전 = [StateError]).
  OnboardingFinishFacts _finishFacts() {
    final SqliteOnboardingStore store = SqliteOnboardingStore(
      _db,
      clock: _rt.clock,
    );
    final OnboardingChoice? c = store.choice();
    if (c == null) throw StateError('마무리: 운영 방식을 먼저 고르십시오');
    final OpsConfigRead cfg = currentP0sOpsConfig(_db);
    // 🆕 E11k-e3(R229) — ⑤ 복구 카드 = 첫 클레임 흐름(없음 = 원천 없음 · 카드 줄 = 열렸을 때만 엔진이 부른다 — 그때 발급).
    final SupabaseFirstClaim? claim = _rt.firstClaim;
    final RecoveryCardFact? card = claim?.fact();
    return OnboardingFinishFacts(
      mode: c.operatingMode,
      committed: c.committed,
      pledged:
          SqlitePledgeStore(
            _db,
            clock: _rt.clock,
            trusted: _rt.trusted,
          ).currentPledge() !=
          null,
      openingDeclared: store.openingDecisionId() != null,
      configHash: cfg is OpsConfigReady ? cfg.configHash : null,
      // 🆕 R159 — ③ 생체 서명(기기 id 없음 = 원천 없음 · 서약 없음 = 아직).
      biometricSigned: OperatorBiometricSign(_rt).fact(),
      // 🆕 R167 — ④ 골든 셀프테스트 = 지금 지문과 같은 마지막 기록(없으면 0/전체) · 실행기 «전량» 전 · 자산 전 = 원천 없음.
      selftest: kDeviceGoldenSuite.complete
          ? goldenSelftestFactOf(
              currentDigest: _rt.golden?.prepared?.digest,
              total: _rt.golden?.prepared?.total,
              last: OperatorGolden.lastRecord(_db),
            )
          : null,
      recoveryCardDone: card?.done,
      recoveryCardPending: card?.pending ?? false,
      recoveryCardLines: card?.lines ?? const <String>[],
      recoveryCardIssue: claim?.issueLines,
    );
  }

  @override
  Stream<OnboardingFinishVm> watchFinish() => _live<OnboardingFinishVm>(
    () => onboardingFinishVmOf(_finishFacts()),
    tables: finishTables,
    golden: true,
  );

  /// 🆕 R248 — R-01 이 다시 읽는 표(o_07 진척 = 연결 · 로그인 · 비상 회수 기록 = 받은편지).
  static const Set<String> restartTables = <String>{
    ...SqliteOnboardingProgressStore.watchedTables,
    'command_inbox',
  };

  final StreamController<void> _pokes = StreamController<void>.broadcast();

  /// 🆕 R248 — R-01 을 지금 다시 읽게 한다(로그인 자리의 연결 · 로그인 동작이 끝난 뒤).
  void poke() => _pokes.add(null);

  /// 🆕 R248 — R-01 사실(망 = 기기 원장 읽기 · 원장을 읽었는데 신뢰 시각 모름 = 한 번 다시 잰다).
  Future<RestartFacts> restartFacts(SupabaseDeviceLedger ledger) async {
    final DeviceLedgerRead read = await ledger.read();
    if (!read.signedIn) return const RestartFacts(signedIn: false);
    DateTime? now = _rt.trusted.trustedNowUtc();
    final Future<bool> Function()? measure = _rt.refreshTrusted;
    if (now == null && read.ledger != null && measure != null) {
      try {
        await measure();
      } on Object {
        // 못 잼 = 모름 그대로(엔진이 게이트 UNKNOWN).
      }
      now = _rt.trusted.trustedNowUtc();
    }
    bool emergency;
    try {
      emergency = SqliteX1EmergencyStore(_db).latest() != null;
    } on FormatException {
      // 기록은 있는데 꼴이 깨졌다 — 이어 하기 링크를 주고 X1 화면이 깨짐을 말한다.
      emergency = true;
    }
    return RestartFacts(
      signedIn: true,
      ledger: read.ledger,
      thisDeviceId: _rt.deviceId,
      trustedNowUtc: now,
      backupGapDays: _rt.operations?.resumeLadder?.backupGapDays,
      emergencyStarted: emergency,
    );
  }

  @override
  Stream<RestartVm> watchRestart() {
    final SupabaseDeviceLedger? ledger = _rt.deviceLedger;
    if (ledger == null) {
      // 첫 화면 링크도 없다(같은 조건) — 지어내지 않는다.
      return Stream<RestartVm>.error(
        UnsupportedError('watchRestart: 기기 원장 읽기 조립 없음'),
      );
    }
    late final StreamController<RestartVm> c;
    StreamSubscription<int>? changes;
    StreamSubscription<void>? pokes;
    Timer? timer;
    bool running = false;
    bool again = false;
    bool has = false;
    RestartVm? last;
    int seq = 0;

    // 겹쳐 부르면 한 번 더만(망 읽기는 한 줄로).
    Future<void> refresh() async {
      if (running) {
        again = true;
        return;
      }
      running = true;
      try {
        do {
          again = false;
          try {
            final RestartVm vm = restartVmOf(await restartFacts(ledger));
            if (c.isClosed) return;
            if (!has || vm != last) {
              has = true;
              last = vm;
              c.add(vm);
            }
          } on Object catch (e, st) {
            if (!c.isClosed) c.addError(e, st);
          }
        } while (again && !c.isClosed);
      } finally {
        running = false;
      }
    }

    c = StreamController<RestartVm>(
      onListen: () {
        // 처음 한 번(들을 때) + 표 변경마다.
        changes = watchLedgerQuery<int>(
          _db,
          restartTables,
          () => seq++,
        ).listen((_) => unawaited(refresh()), onError: c.addError);
        pokes = _pokes.stream.listen((_) => unawaited(refresh()));
        timer = Timer.periodic(tick, (_) => unawaited(refresh()));
      },
      onCancel: () async {
        timer?.cancel();
        await changes?.cancel();
        await pokes?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  @override
  Stream<List<OnboardingStep>> watchSteps(OnboardingTrack track) =>
      Stream<List<OnboardingStep>>.error(
        UnsupportedError('watchSteps: 옛 창구 — v1.16 화면은 watchStepList(미결 149)'),
      );
}
