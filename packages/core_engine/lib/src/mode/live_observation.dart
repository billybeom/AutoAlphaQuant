// M1-22 실전 드라이런 관찰 창 — 연속 무결 거래일 · 승격 가능 판정 · VM 문구(앱 06 M1-22 · 01 §10-2 G-43 ·
// SPEC v2.44 04 §3-1 ① · 02 §2-6 · 설계 13 §8 R89 AC2~AC8).
//
// 🔴 관찰 일수는 설정에서 온다 — 기본값 없음 · lib 에 숫자를 적지 않는다(06 M1-22 «리터럴 grep 0»).
// 🔴 판정만 한다 — 승격 커밋(EXEC_POLICY 전이 · 생체 1회)은 따로(E15e2) · 자동 승격 0.
// 🔴 «연속» = 최근 연속(지금 건강해야 승격) · 오늘 행이 아직 없으면 끊지 않는다.
// 🔴 문구에 «DRY_RUN» 글자 0(G-63) · 표시의 정본 = 엔진 문구(화면이 n/m 을 조립하지 않는다).

import 'dart:math' as math;

import 'package:domain_contracts/domain_contracts.dart'
    show ExecPolicy, LiveDryRunObservationVm, RunMode, TradeDate;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar;
import '../calendar/next_rebalance.dart' show nextRegularExecutionSession;
import '../ops/ledger_views.dart' show kstDateText;

/// 관찰 일수 설정 키(02 §5 `operations.*` · 값 = 설정 원천).
const String kLiveDryRunObservationKey =
    'operations.live_dry_run_observation_trading_days';

/// 관찰하는 배치의 체크 이름(`live × autoTrade` 의 `kr_order`).
const String kLiveObservationBatchCheck = 'live-auto-kr_order';

/// 관찰 설정(R89 AC6 — 🔴 기본값 없음).
class LiveObservationConfig {
  /// 설정을 만든다 — 1 미만 = [ArgumentError].
  LiveObservationConfig({required this.requiredTradingDays}) {
    if (requiredTradingDays < 1) {
      throw ArgumentError.value(
        requiredTradingDays,
        'requiredTradingDays',
        '1 이상',
      );
    }
  }

  /// 필요한 연속 무결 거래일.
  final int requiredTradingDays;
}

/// `kr_order` 회차 1건(실전 파일).
class LiveObservationRun {
  /// 기록을 만든다.
  const LiveObservationRun(
    this.sessionDay,
    this.startedAtUtc, {
    required this.succeeded,
  });

  /// 세션일(`YYYY-MM-DD`).
  final String sessionDay;

  /// 시작 시각.
  final DateTime startedAtUtc;

  /// SUCCESS · LATE 인가.
  final bool succeeded;
}

/// 대사 1회(`reconciliation_log` 의 `rc-` · 해제 행 제외).
class LiveObservationRecon {
  /// 기록을 만든다.
  const LiveObservationRecon(this.runAtUtc, {required this.matched});

  /// 돈 시각.
  final DateTime runAtUtc;

  /// 맞았나(MATCHED 만 — TRANSIENT · UNAVAILABLE = 아니다).
  final bool matched;
}

/// 판정 입력 — 실전 파일의 원 기록.
class LiveObservationFacts {
  /// 입력을 만든다.
  const LiveObservationFacts({
    required this.asOfUtc,
    required this.runMode,
    required this.execPolicy,
    required this.currentSinceUtc,
    required this.runs,
    required this.recons,
    required this.unknownOrders,
    required this.killSwitchActive,
    required this.blockingFlags,
  });

  /// 읽은 시각.
  final DateTime asOfUtc;

  /// 현재 행의 모드(없으면 null).
  final RunMode? runMode;

  /// 현재 행의 집행 정책(없으면 null).
  final ExecPolicy? execPolicy;

  /// 현재 행의 커밋 시각(없으면 null).
  final DateTime? currentSinceUtc;

  /// `live-auto-kr_order` 회차 전부.
  final List<LiveObservationRun> runs;

  /// 대사 기록 전부.
  final List<LiveObservationRecon> recons;

  /// 지금 UNKNOWN 의도 수.
  final int unknownOrders;

  /// 킬스위치가 켜져 있나.
  final bool killSwitchActive;

  /// 주문 차단 플래그(`DST_WEEK` 제외).
  final List<String> blockingFlags;
}

/// 판정 입력 포트(`SimTrialFactsSource` 선례 · 🔴 예외 = 판정 없음).
abstract interface class LiveObservationFactsSource {
  /// 지금의 입력.
  Future<LiveObservationFacts> facts();
}

/// 승격을 막는 사유(차례 = 판정 차례 · R89 AC5).
enum LiveObservationBlock {
  /// 킬스위치 켜짐.
  killSwitch('LIVE_OBSERVATION_KILL_SWITCH'),

  /// 주문 차단 플래그.
  tradingBlock('LIVE_OBSERVATION_TRADING_BLOCK'),

  /// 확인 안 된 주문.
  unknownOrders('LIVE_OBSERVATION_UNKNOWN_ORDERS'),

  /// 연속 무결 거래일 모자람.
  notEnoughDays('LIVE_OBSERVATION_NOT_ENOUGH_DAYS');

  const LiveObservationBlock(this.code);

  /// 엔진 코드.
  final String code;
}

/// 판정 결과.
class LiveObservationReport {
  /// 결과를 만든다.
  const LiveObservationReport({
    required this.observing,
    required this.observedTradingDays,
    required this.promotionAvailable,
    required this.block,
    required this.vm,
    required this.promotionLabel,
  });

  /// 관찰 중 아님(현재 행이 `live × dryRun` 이 아니다).
  static const LiveObservationReport notObserving = LiveObservationReport(
    observing: false,
    observedTradingDays: 0,
    promotionAvailable: false,
    block: null,
    vm: null,
    promotionLabel: null,
  );

  /// 관찰 중인가.
  final bool observing;

  /// 최근 연속 무결 거래일(실제 수).
  final int observedTradingDays;

  /// 승격 가능(사람 생체 1회가 남는다 — 자동 승격 0).
  final bool promotionAvailable;

  /// 막는 사유(가능하면 null).
  final LiveObservationBlock? block;

  /// 화면 VM(관찰 중일 때만).
  final LiveDryRunObservationVm? vm;

  /// 엔진 상태 칩 한 줄(관찰 중일 때만 · `EngineStatusChip.promotionLabel`).
  final String? promotionLabel;
}

String _firstSessionOnOrAfter(ExchangeCalendar kr, String day) {
  final TradeDate d = TradeDate(day);
  return kr.isSession(d) ? day : kr.nextSession(d).yyyyMmDd;
}

/// M1-22 관찰 판정(R89 AC2~AC8).
LiveObservationReport judgeLiveObservation(
  LiveObservationFacts f, {
  required ExchangeCalendar kr,
  required LiveObservationConfig config,
}) {
  final DateTime? since = f.currentSinceUtc;
  if (f.runMode != RunMode.live ||
      f.execPolicy != ExecPolicy.dryRun ||
      since == null) {
    return LiveObservationReport.notObserving;
  }
  final int m = config.requiredTradingDays;
  final String startDay = kstDateText(since);
  final String today = kstDateText(f.asOfUtc);

  // 무결 = 그날 kr_order 정상(시작점 뒤) ∧ 그날 대사(시작점 뒤) ≥ 1 ∧ 전부 일치(AC3).
  final Set<String> okRuns = <String>{
    for (final LiveObservationRun r in f.runs)
      if (r.succeeded && !r.startedAtUtc.isBefore(since)) r.sessionDay,
  };
  final Map<String, bool> reconClean = <String, bool>{};
  for (final LiveObservationRecon r in f.recons) {
    if (r.runAtUtc.isBefore(since)) continue;
    final String d = kstDateText(r.runAtUtc);
    reconClean[d] = (reconClean[d] ?? true) && r.matched;
  }

  // 최근 연속 — 오늘이 아직 무결이 아니면 끊지 않는다(AC4).
  // 🔴 오늘에서 멈춘다 — 오늘 다음 세션은 묻지 않는다(달력 범위 끝 날에도 답한다).
  int run = 0;
  for (
    String day = _firstSessionOnOrAfter(kr, startDay);
    day.compareTo(today) <= 0;
    day = kr.nextSession(TradeDate(day)).yyyyMmDd
  ) {
    if (okRuns.contains(day) && (reconClean[day] ?? false)) {
      run++;
    } else if (day != today) {
      run = 0;
    }
    if (day == today) break;
  }

  final LiveObservationBlock? block = f.killSwitchActive
      ? LiveObservationBlock.killSwitch
      : f.blockingFlags.isNotEmpty
      ? LiveObservationBlock.tradingBlock
      : f.unknownOrders > 0
      ? LiveObservationBlock.unknownOrders
      : run < m
      ? LiveObservationBlock.notEnoughDays
      : null;
  final int shown = math.min(run, m);
  final String label = switch (block) {
    null => '승격 가능 — 무결 거래일을 채웠습니다($shown/$m)',
    LiveObservationBlock.killSwitch => '승격 불가 — 킬스위치가 켜져 있습니다',
    LiveObservationBlock.tradingBlock =>
      '승격 불가 — 주문 차단 플래그 ${f.blockingFlags.length}개',
    LiveObservationBlock.unknownOrders =>
      '승격 불가 — 확인 안 된 주문 ${f.unknownOrders}건',
    LiveObservationBlock.notEnoughDays => '승격 불가 — 무결 거래일이 아직 모자랍니다($shown/$m)',
  };
  // 🔵 E15f1 정정 — 그 집행 09:10 이 아직 오지 않은 다음 정기 집행(월말 뒤 주말에도 그 집행일).
  final String? exec = nextRegularExecutionSession(kr, f.asOfUtc);
  final String state = exec == null
      ? '실전 관찰 중'
      : '실전 관찰 중 · 정기 리밸런싱 $exec 09:10 전에 승격해야 첫 주문이 나갑니다';
  return LiveObservationReport(
    observing: true,
    observedTradingDays: run,
    promotionAvailable: block == null,
    block: block,
    vm: LiveDryRunObservationVm(
      observedTradingDays: run,
      requiredTradingDays: m,
      progressText: '무결 거래일 $shown/$m',
      promotionAvailable: block == null,
      stateLabel: state,
    ),
    promotionLabel: label,
  );
}
