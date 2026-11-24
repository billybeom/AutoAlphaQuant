// E11q-s05 — M9 `S05` 운용 관리 VM 짓기(설계 13 §8 R252 · 앱 01 §28 K2~K20 · 05 S05 · 미결 168 · 177).
//
// 🔴 글자 = 엔진(표본 `m9/operations_*` 꼴) — 화면은 세지도 · 판정하지도 · 키를 짓지도 · 토글하지도 않는다(01 §28-1).
// 🔴 버튼 = 엔진이 `id`·`args` 까지 완성한 호출뿐 · 조립 앱 구현이 없는 동작은 싣지 않는다(빈 목록 · null = 부재 — 지어내지 않는다):
//    · 실전 전환 요청(`runtimeModeSwitchRequest{run_mode: LIVE}`) = 모의일 때 ∧ [OperationsFacts.canRequestSwitch](위저드 본문 · 동작 창구).
//    · 승격(`runtimeLivePromotion{}`) = 관찰 중 ∧ 승격 가능 ∧ [OperationsFacts.canPromote](생체 · 관찰 설정 · 동작 창구).
//    · 운영 방식 전환 · 엔진 시작 · 중지 = 구현 원천 없음(미결 173 · M5-11 위저드 = simToAuto 갈래만 — K174) → 버튼 0.
// 🔴 원천 없는 칸 = 비운다 — 업데이트 게이트 · 지난 요청 줄 = null(미결 174) · 램프 승급 조건 = 빈 + 까닭 글자(미결 172).
// 🔴 상태 칩 = `S01` 과 같은 생산(`settingsStatusChipOf` · v1.18 K-o) — 승격 줄 = 관찰 판정의 칩 문구(관찰 중일 때만).
// 🔴 «DRY_RUN» 글자 0 · 손익 성격 글자 0(G-63) · 킬스위치 칸 0(엔진 중지 ≠ 킬스위치).

import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        AppRoutes,
        AsOf,
        AsOfSource,
        EngineControl,
        GateBadge,
        GateState,
        JobRow,
        LedgerTrustBadge,
        OperatingMode,
        OperatingModeView,
        OperationsVm,
        RampBoard,
        RunMode,
        RunModeCard,
        SettingsActionCall,
        SettingsActionId,
        TradeDate,
        UiLevel;

import '../mode/handover_wizard.dart' show simTrialCardOf;
import '../mode/live_observation.dart'
    show LiveObservationBlock, LiveObservationReport;
import '../mode/live_promotion.dart' show LivePromotionCodes;
import '../onboarding/onboarding_choice.dart' show onboardingModeChoiceVmOf;
import '../safety/safety_text.dart' show kSafetyHoldLabels, rampLevelOf;
import '../sim/sim_trial.dart' show SimTrialReport;
import 'lease_gate.dart' show kLeaseInvalidCode;
import 'ledger_views.dart' show kstDateText;
import 'settings_home.dart' show settingsStatusChipOf;

/// 운용 관리 신선도(표본 `stale_after_seconds` 93600 = 26시간).
const Duration kOperationsStaleAfter = Duration(hours: 26);

/// 램프 단계 → 투자 비중(정본 03 §9-2 «L1 5% ~ L5 100%» · 🔴 표시 글자일 뿐 — 사이징은 이 표를 읽지 않는다).
const Map<int, int> kOpsRampPercent = <int, int>{
  1: 5,
  2: 15,
  3: 40,
  4: 70,
  5: 100,
};

/// 운용 관리 글자(표본 `m9/operations_*` · 엔진 정본).
abstract final class OperationsTexts {
  /// 실전 전환 요청 버튼.
  static const String switchToLive = '실전 전환 요청';

  /// 실전 전환 부작용 고지(표본 그대로).
  static const String switchNotice =
      '실전 전환을 요청하면 기존 계획이 무효화되고 다음 정규 사이클에 재계산됩니다.';

  /// 승격 버튼.
  static const String promote = '실전 집행으로 올리기';

  /// 실전 전환 요청 접수 → 위저드(표본 `ar_s05_01`).
  static const String switchRequested = '실전 전환 요청을 받았습니다. 실전 전환 위저드로 넘어갑니다.';

  /// 운영 방식 전환 위저드 게이트 이름(표본 `M5_11_WIZARD`).
  static const String wizardGate = '운영 방식 전환 위저드';

  /// 모의 램프 빈 까닭(표본 그대로).
  static const String rampSimEmpty =
      '모의 계좌에서는 승급 조건을 세지 않습니다. 실전으로 바꾸면 L1 부터 셉니다.';

  /// 🆕 실전 램프 빈 까닭 — 승급 조건 집계 원천 전(미결 172).
  static const String rampLiveEmpty = '승급 조건 집계는 아직 준비 중입니다. 지금 단계를 그대로 둡니다.';

  /// DST 표식(표본 그대로 · 🔴 주문 차단이 아니다).
  static const String rampDstNotice =
      '미국 서머타임 전환 주간이라 램프를 한 단계 낮춰 두었습니다. 주문 차단이 아니라 상태 표식입니다.';

  /// 엔진 돎 — 다음 잡(표본 꼴).
  static String running(String? nextJob) =>
      nextJob == null ? '돌고 있음' : '돌고 있음 — 다음 잡: $nextJob';

  /// 🆕 hold — 기동은 했지만 배치를 멈춘 동안(사유 = 모드 카드 줄).
  static const String heldBatches = '돌고 있음 — 위 사유가 풀릴 때까지 배치를 돌리지 않습니다';

  /// 🆕 기동 거부 — 잡을 하나도 돌리지 않는다(사유 = 엔진 거부 코드 차례 그대로).
  static String rejected(List<String> codes) =>
      '멈춤 — 기동 판정이 시작을 거부했습니다(${codes.join(' · ')})';
}

/// 운용 관리 사실(조립 앱이 모은다 · 🔴 판정 · 글자 = 이 파일).
class OperationsFacts {
  /// 사실을 만든다.
  const OperationsFacts({
    required this.runMode,
    required this.operatingMode,
    required this.trust,
    required this.jobs,
    required this.nowUtc,
    this.holds = const <String>{},
    this.rejected = const <String>[],
    this.observation,
    this.trial,
    this.rampLevel,
    this.preDstRampLevel,
    this.nextJobText,
    this.canRequestSwitch = false,
    this.canPromote = false,
  });

  /// 지금 실행 모드(화면 상태).
  final RunMode runMode;

  /// 지금 운영 방식(화면 상태).
  final OperatingMode operatingMode;

  /// 마지막 기동 판정의 hold(`SafetyHoldCodes` · 기동은 하되 배치를 멈춤).
  final Set<String> holds;

  /// 마지막 기동 판정이 거부했으면 그 사유(엔진 차례 · 빈 = 기동함).
  final List<String> rejected;

  /// 실전 관찰 판정(실전 파일 · 관찰 설정이 있을 때만 · 없으면 null).
  final LiveObservationReport? observation;

  /// 모의 체험 판정(모의일 때만 · 없으면 null).
  final SimTrialReport? trial;

  /// `ramp_state.level`(행 없음 = null = L1).
  final int? rampLevel;

  /// `ramp_state.pre_dst_level`(DST 주간 진입 전 단계 · 없으면 null).
  final int? preDstRampLevel;

  /// 잡 행(엔진 잡 표 × `job_run` — trading_runtime `operationsJobRowsOf`).
  final List<JobRow> jobs;

  /// 다음 잡 한 줄(«오늘 18:30 국내 시세 수집» · 모름 = null).
  final String? nextJobText;

  /// 지금 원장 신뢰 배지(홈 9b 와 같은 판정).
  final LedgerTrustBadge trust;

  /// 실전 전환 요청을 받을 창구가 있나(위저드 본문 ∧ 설정 동작).
  final bool canRequestSwitch;

  /// 승격을 받을 창구가 있나(설정 동작 ∧ 생체 ∧ 관찰 설정).
  final bool canPromote;

  /// 지금(기기 시계 — 읽기).
  final DateTime nowUtc;
}

String _two(int n) => n.toString().padLeft(2, '0');

/// hold 코드 → 한 줄(사전 차례 · 모르는 코드 = [ArgumentError] — 지어내지 않는다).
String? _holdLine(Set<String> holds) {
  if (holds.isEmpty) return null;
  final Set<String> unknown = holds.difference(kSafetyHoldLabels.keys.toSet());
  if (unknown.isNotEmpty) {
    throw ArgumentError.value(unknown, 'holds', '모르는 hold 코드');
  }
  return <String>[
    for (final MapEntry<String, String> e in kSafetyHoldLabels.entries)
      if (holds.contains(e.key)) e.value,
  ].join(' ');
}

bool _observing(OperationsFacts f) =>
    f.runMode == RunMode.live && (f.observation?.observing ?? false);

RunModeCard _modeCard(OperationsFacts f, String? hold) {
  final bool observing = _observing(f);
  final LiveObservationReport? obs = f.observation;
  final bool live = f.runMode == RunMode.live;
  final String label = switch (f.runMode) {
    RunMode.simInternal => '모의 · 내부 가상 체결',
    RunMode.simBroker => '모의 · KIS 모의투자 서버',
    RunMode.live =>
      observing
          ? '실전 · 관찰 중'
          : switch (f.operatingMode) {
              OperatingMode.autoTrade => '실전 · 자동 주문',
              OperatingMode.advisory => '실전 · 실계좌',
            },
  };
  final bool canSwitch = !live && f.canRequestSwitch;
  return RunModeCard(
    label: label,
    level: !live
        ? UiLevel.info
        : (hold != null || observing)
        ? UiLevel.watch
        : UiLevel.ok,
    holdLabel: hold,
    observation: observing ? obs?.vm : null,
    promotionAction:
        observing && (obs?.promotionAvailable ?? false) && f.canPromote
        ? SettingsActionCall(
            id: SettingsActionId.runtimeLivePromotion,
            args: const <String, String>{},
            label: OperationsTexts.promote,
          )
        : null,
    switchNoticeText: canSwitch ? OperationsTexts.switchNotice : null,
    switchActions: canSwitch
        ? <SettingsActionCall>[
            SettingsActionCall(
              id: SettingsActionId.runtimeModeSwitchRequest,
              args: <String, String>{'run_mode': RunMode.live.wire},
              label: OperationsTexts.switchToLive,
            ),
          ]
        : const <SettingsActionCall>[],
  );
}

OperatingModeView _operatingMode(OperationsFacts f) {
  final OperatingMode op = f.operatingMode;
  return OperatingModeView(
    current: op,
    label: switch (op) {
      OperatingMode.autoTrade => '자동 매매',
      OperatingMode.advisory => '투자 안내(수동 매매)',
    },
    explainLine: switch (op) {
      OperatingMode.autoTrade =>
        _observing(f)
            ? '규칙이 정한 대로 앱이 주문을 냅니다. 관찰 중에는 주문을 내지 않습니다.'
            : '규칙이 정한 대로 앱이 주문을 냅니다.',
      OperatingMode.advisory => '무엇을 살지 알려 드리고 주문은 직접 내십니다.',
    },
    // 🔴 O-00b 와 같은 카드(엔진 한 벌) · 기본 선택 칸 없음(카드에 버튼 0 — K8).
    options: onboardingModeChoiceVmOf(selected: op, committed: false).options,
    trust: f.trust,
    // 🔴 운영 방식 전환 = 이 판에 구현 없음(M5-11 위저드 = simToAuto 갈래 · K174) — 해당 없음 표시 · 버튼 0.
    switchGates: const <GateBadge>[
      GateBadge(
        code: 'M5_11_WIZARD',
        label: OperationsTexts.wizardGate,
        state: GateState.notApplicable,
      ),
    ],
  );
}

/// 램프 단계 글자(모의 = 비중 없음 · 실전 = 03 §9-2 비중).
String _rampLabel(int level, {required bool live}) {
  final String edge = level == 1
      ? ' · 최저 단계'
      : level == 5
      ? ' · 최고 단계'
      : '';
  return live ? 'L$level · ${kOpsRampPercent[level]}%$edge' : 'L$level$edge';
}

/// 🔴 램프 보드 — 레벨 = `ramp_state`(행 없음 = L1 · 1~5 밖 = [RangeError]) · DST = `pre_dst_level` 이 지금보다 높을 때 ·
/// 승급 조건 = 원천 전(미결 172) → 빈 + 까닭.
RampBoard operationsRampOf({
  required RunMode runMode,
  int? level,
  int? preDstLevel,
}) {
  rampLevelOf(level); // 범위 검사(1~5 · 행 없음 = L1).
  final int l = level ?? 1;
  if (runMode != RunMode.live) {
    return RampBoard(
      levelLabel: _rampLabel(l, live: false),
      level: UiLevel.info,
      emptyLabel: OperationsTexts.rampSimEmpty,
    );
  }
  final int? pre = preDstLevel;
  if (pre != null) rampLevelOf(pre);
  final bool dst = pre != null && pre > l;
  return RampBoard(
    levelLabel: dst
        ? 'L$l · ${kOpsRampPercent[l]}% — DST 주간이라 한 단계 낮춤(원래 L$pre)'
        : _rampLabel(l, live: true),
    level: dst ? UiLevel.watch : UiLevel.info,
    emptyLabel: OperationsTexts.rampLiveEmpty,
    dstNoticeText: dst ? OperationsTexts.rampDstNotice : null,
  );
}

EngineControl _control(OperationsFacts f) {
  if (f.rejected.isNotEmpty) {
    return EngineControl(
      stateLabel: OperationsTexts.rejected(f.rejected),
      level: UiLevel.blocked,
    );
  }
  if (f.holds.isNotEmpty) {
    return const EngineControl(
      stateLabel: OperationsTexts.heldBatches,
      level: UiLevel.watch,
    );
  }
  // 🔴 시작 · 중지 버튼 = 엔진 구현 전(미결 173) → 부재.
  return EngineControl(
    stateLabel: OperationsTexts.running(f.nextJobText),
    level: UiLevel.ok,
  );
}

/// 🔴 `S05` 운용 관리.
OperationsVm operationsVmOf(OperationsFacts f) {
  final String? hold = _holdLine(f.holds);
  final DateTime now = f.nowUtc.toUtc();
  final DateTime k = now.add(const Duration(hours: 9));
  final bool live = f.runMode == RunMode.live;
  final SimTrialReport? trial = f.trial;
  return OperationsVm(
    statusChip: settingsStatusChipOf(
      f.runMode,
      f.operatingMode,
      promotionLabel: _observing(f) ? f.observation?.promotionLabel : null,
    ),
    mode: _modeCard(f, hold),
    operatingMode: _operatingMode(f),
    trial: !live && trial != null ? simTrialCardOf(trial) : null,
    ramp: operationsRampOf(
      runMode: f.runMode,
      level: f.rampLevel,
      preDstLevel: f.preDstRampLevel,
    ),
    jobs: f.jobs,
    control: _control(f),
    asOf: AsOf(
      observedAt: now,
      tradeDate: TradeDate(kstDateText(now)),
      source: AsOfSource.localSqlite,
      staleAfter: kOperationsStaleAfter,
      label: '운용 기준 ${kstDateText(now)} ${_two(k.hour)}:${_two(k.minute)}',
    ),
  );
}

/// 🔴 실전 전환 요청 접수 → M5-11 위저드로 넘김(표본 `ar_s05_01` · M9 는 한 번 부르고 넘긴다 · 상태 변경 0 — 판정 · 생체 = 위저드).
ActionResult runModeSwitchRequestedResultOf({required String actionRunId}) =>
    ActionResult(
      actionRunId: actionRunId,
      id: SettingsActionId.runtimeModeSwitchRequest,
      level: UiLevel.info,
      headline: OperationsTexts.switchRequested,
      handoffRoute: AppRoutes.m5HandoverWizard,
      retryable: false,
    );

/// 승격 결과 레벨(표본 `ar_s05_10~13` 짝 · 성공 = OK · 관찰 일수 · 미확인 주문 = WATCH · 관찰 아님 · 자동 매매 아님 = INFO ·
/// 그 밖 막힘 = BLOCKED).
UiLevel livePromotionResultLevel(String? code) {
  if (code == null) return UiLevel.ok;
  if (code == LiveObservationBlock.notEnoughDays.code ||
      code == LiveObservationBlock.unknownOrders.code) {
    return UiLevel.watch;
  }
  if (code == LivePromotionCodes.notObserving ||
      code == LivePromotionCodes.notAutoTrade) {
    return UiLevel.info;
  }
  return UiLevel.blocked;
}

/// 🔴 승격 결과(엔진 저장 `SqliteLivePromotionStore.promote` 의 코드 · 문구 그대로) — 되돌림만 다시 시도 가능.
ActionResult livePromotionActionResultOf({
  required String actionRunId,
  required String? code,
  required String headline,
}) => ActionResult(
  actionRunId: actionRunId,
  id: SettingsActionId.runtimeLivePromotion,
  level: livePromotionResultLevel(code),
  headline: headline,
  reasonCode: code,
  retryable: code == LivePromotionCodes.rolledBack,
);

/// 승격을 막는 코드 전부(시험 · 레벨 짝 전수 대조용).
Set<String> get livePromotionResultCodes => <String>{
  LivePromotionCodes.biometricUnavailable,
  LivePromotionCodes.sessionInvalid,
  LivePromotionCodes.notObserving,
  LivePromotionCodes.notAutoTrade,
  LivePromotionCodes.clockBehind,
  LivePromotionCodes.rolledBack,
  kLeaseInvalidCode,
  for (final LiveObservationBlock b in LiveObservationBlock.values) b.code,
};
