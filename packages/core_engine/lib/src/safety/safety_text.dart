// 안전 상태 조립 — 순수(앱 계약 01 §2-10 · §3-5 · 02 화면 M6 §2-2 플래그 표 · 설계 13 §8 R62 U2~U8).
//
// 🔴 글자 · 차례 · 목적지 = 엔진이 정한다 — 화면은 `flagId` · `clearRoute` 로 문구나 목적지를 고르지 않는다.
// 🔴 해제 지시문은 플래그마다 다르다(경보 피로 규칙 — 하나의 문장으로 뭉치지 않는다).
// 🔴 목적지가 null 이면 배너에 이동 버튼이 없다(`LEDGER_FIX` · `TIER_B_UNJUDGED` · 표식).
// 🔴 `RampLevel.l0` 은 내지 않는다(스키마 1~5 · 행 없음 = L1 · D19).

import 'package:domain_contracts/domain_contracts.dart' as c show BreakerLevel;
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;

import '../ops/equity_snapshot.dart' show BreakerReplay, p0sBreakerConfig;
import '../ops/ledger_trust.dart' show selfAuditLinkOfReason;
import '../ops/ledger_views.dart' show kstDateText, kReconStaleAfter;
import '../risk/breaker.dart';
import 'kill_switch.dart';

/// 플래그 사전 한 칸.
class FlagEntry {
  /// 칸을 만든다.
  const FlagEntry(this.label, this.route, this.instruction, this.rank);

  /// 배너 글자.
  final String label;

  /// 해제의 성격(02 §2-2).
  final ClearRoute route;

  /// 해제 지시문(플래그마다 다르다).
  final String instruction;

  /// 표시 차례 무리(작을수록 먼저).
  final int rank;
}

/// 플래그 12 사전(R62 U3 · 픽스처 5종 글자 그대로 + 초안 7).
const Map<String, FlagEntry> kFlagDictionary = <String, FlagEntry>{
  FlagIds.ledgerIntegrity: FlagEntry(
    '원장 무결성 점검이 필요합니다',
    ClearRoute.wizardOnly,
    '복구 위저드에서만 해소됩니다.',
    0,
  ),
  FlagIds.reconMismatch: FlagEntry(
    '브로커 원장과 어긋납니다',
    ClearRoute.causeCodeRequired,
    '원인 코드를 골라 해소하십시오. /resume 으로는 풀리지 않습니다.',
    1,
  ),
  FlagIds.resumeIncomplete: FlagEntry(
    '재개 점검이 끝나지 않았습니다',
    ClearRoute.automatic,
    '재개 점검이 끝나면 자동으로 풀립니다.',
    2,
  ),
  FlagIds.ledgerFix: FlagEntry(
    '정정 진행 중 — 기록이 바뀔 수 있습니다',
    ClearRoute.noManualPath,
    '정정이 끝나면 저절로 사라집니다. 직접 풀 수 없습니다.',
    3,
  ),
  FlagIds.adviceLedgerUnverified: FlagEntry(
    '원장 실사가 확인되지 않았습니다',
    ClearRoute.wizardOnly,
    '원장 실사 해소 · 격리 검토에서만 풀립니다. 청산 · 방어 안내는 계속 나갑니다.',
    4,
  ),
  FlagIds.selfAuditOverdue: FlagEntry(
    '원장 실사 기한이 지났습니다',
    ClearRoute.automatic,
    '실사를 한 번 마치면 자동으로 풀립니다.',
    4,
  ),
  FlagIds.journalMissing: FlagEntry(
    '일지가 비어 있습니다',
    ClearRoute.automatic,
    '일지를 채우면 자동으로 풀립니다.',
    5,
  ),
  FlagIds.tierBUnjudged: FlagEntry(
    'TIER B 판정이 남아 있습니다',
    ClearRoute.automatic,
    '판정이 끝나면 자동으로 풀립니다.',
    5,
  ),
  FlagIds.dstWeek: FlagEntry(
    '미국 서머타임 전환 주간입니다',
    ClearRoute.automatic,
    '주간이 끝나면 자동으로 사라집니다. 주문을 막지 않습니다.',
    5,
  ),
  FlagIds.selfAuditDue: FlagEntry(
    '분기 실사 기한이 다가옵니다',
    ClearRoute.automatic,
    '실사를 마치면 자동으로 풀립니다.',
    5,
  ),
  FlagIds.selfAuditPatternUnverified: FlagEntry(
    '실사 오차 0 이 이어졌습니다',
    ClearRoute.automatic,
    '다음 실사에서 원 단위 현금을 적으면 사라집니다. 주문을 막지 않습니다.',
    5,
  ),
  FlagIds.adviceSelectiveExecution: FlagEntry(
    '진입 · 청산 이행률이 기울어 있습니다',
    ClearRoute.automatic,
    '월간 리포트에서 확인하십시오. 주문을 막지 않습니다.',
    5,
  ),
};

/// 저장된 `trading_block` 활성 행.
class StoredBlockFlag {
  /// 행을 만든다.
  const StoredBlockFlag(
    this.flagId,
    this.setAtUtc, {
    this.originCode,
    this.reason,
  });

  /// 플래그.
  final String flagId;

  /// 선 시각.
  final DateTime setAtUtc;

  /// 원인 코드(있으면).
  final String? originCode;

  /// 🆕 E11q-q6c — `trading_block.reason`(실사 표식 = 그 달 · 그 계좌 `L-3` 링크 · 그 밖 = 읽지 않는다).
  final String? reason;
}

String _two(int n) => n.toString().padLeft(2, '0');

/// «마지막 검증 MM-DD HH:mm»(한국).
String checkpointLabelOf(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  return '마지막 검증 ${_two(k.month)}-${_two(k.day)} ${_two(k.hour)}:${_two(k.minute)}';
}

/// 활성 플래그 → 표시 차례대로(R62 U3) — 🔴 모르는 플래그 = [StateError](지어내지 않는다).
List<BlockFlag> blockFlagsOf(
  List<StoredBlockFlag> rows, {
  String? journalDraftId,
  DateTime? lastIntegrityOkUtc,
}) {
  for (final StoredBlockFlag r in rows) {
    if (!kFlagDictionary.containsKey(r.flagId)) {
      throw StateError('모르는 차단 플래그: ${r.flagId}');
    }
  }
  final List<StoredBlockFlag> sorted = rows.toList()
    ..sort((StoredBlockFlag a, StoredBlockFlag b) {
      final int r = kFlagDictionary[a.flagId]!.rank.compareTo(
        kFlagDictionary[b.flagId]!.rank,
      );
      if (r != 0) return r;
      final int t = a.setAtUtc.compareTo(b.setAtUtc);
      return t != 0 ? t : a.flagId.compareTo(b.flagId);
    });
  return <BlockFlag>[
    for (final StoredBlockFlag r in sorted)
      BlockFlag(
        flagId: r.flagId,
        label: kFlagDictionary[r.flagId]!.label,
        setAt: r.setAtUtc,
        clearRoute: kFlagDictionary[r.flagId]!.route,
        clearInstruction: kFlagDictionary[r.flagId]!.instruction,
        originCode: r.originCode,
        checkpointLabel:
            r.flagId == FlagIds.ledgerIntegrity && lastIntegrityOkUtc != null
            ? checkpointLabelOf(lastIntegrityOkUtc)
            : null,
        clearDeepLink: switch (r.flagId) {
          FlagIds.reconMismatch => AppRoutes.m5BlockBoard,
          FlagIds.ledgerIntegrity => AppRoutes.x5RepairWizard,
          FlagIds.adviceLedgerUnverified => AppRoutes.m5SelfAuditResolve,
          // 🆕 E11q-b3(R185 · 01 §34 K155) — 재개 미완 = X2 재개 화면(06 라우트 표 «x2/resume-gate 주 진입점 = 재개 미완 배너»).
          FlagIds.resumeIncomplete => AppRoutes.x2ResumeGate,
          // 🆕 E11q-q6c(R240 · K45 · 02 §3-10) — 실사 예정 · 기한 = 엔진이 세울 때 적은 그 달 · 그 계좌 `L-3`(꼴 밖 = 부재).
          FlagIds.selfAuditDue ||
          FlagIds.selfAuditOverdue => selfAuditLinkOfReason(r.reason),
          FlagIds.journalMissing when journalDraftId != null =>
            AppRoutes.journalDraft.replaceFirst(':decisionId', journalDraftId),
          _ => null,
        },
      ),
  ];
}

/// 브레이커 라벨(픽스처).
String breakerLabelOf(BreakerLevel l) => switch (l) {
  BreakerLevel.normal => '정상',
  BreakerLevel.alert => '경보',
  BreakerLevel.reduced => '축소 운용',
  BreakerLevel.halted => '중지',
  BreakerLevel.stopped => '정지',
};

/// core 레벨 → 계약 레벨.
c.BreakerLevel contractBreakerLevelOf(BreakerLevel l) =>
    c.BreakerLevel.values.firstWhere((c.BreakerLevel x) => x.wire == l.code);

/// 게이지 코드(제안 — 계약 = E13i1 · R62 U5).
abstract final class GaugeCodes {
  /// 드로다운 회복.
  static const String ddRecovery = 'DD_RECOVERY';

  /// 유지 기간(20거래일).
  static const String hold = 'HOLD';

  /// BULL 연속.
  static const String bullStreak = 'BULL_STREAK';

  /// 킬스위치 48h 냉각.
  static const String cooldown = 'COOLDOWN';
}

double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

/// 해제 진행 게이지(R62 U5) — [drawdown] = 지금 낙폭 · [replay] = 지금 재생(유지 봉 · bull).
List<GaugeProgress> releaseProgressOf({
  required BreakerLevel level,
  required double drawdown,
  required BreakerReplay replay,
  required KillSwitchRecord killSwitch,
  required DateTime? trustedNowUtc,
  BreakerConfig? config,
  KillSwitchConfig killSwitchConfig = kP0sKillSwitchConfig,
}) {
  final BreakerConfig cfg = config ?? p0sBreakerConfig();
  final List<GaugeProgress> out = <GaugeProgress>[];
  final (double, double)? span = switch (level) {
    BreakerLevel.normal => null,
    BreakerLevel.alert => (cfg.alertDd, cfg.alertReleaseDd),
    BreakerLevel.reduced => (cfg.reduceDd, cfg.reduceReleaseDd),
    BreakerLevel.halted => (cfg.haltDd, cfg.haltReleaseDd),
    BreakerLevel.stopped => (cfg.stopDd, cfg.stopReleaseDd),
  };
  if (span != null) {
    final (double trigger, double release) = span;
    final double ratio = _clamp01((drawdown - trigger) / (release - trigger));
    out.add(
      GaugeProgress(
        code: GaugeCodes.ddRecovery,
        label: '드로다운 회복',
        normalized: ratio,
        valueText: ratio + 1e-9 >= 1
            ? '회복 완료'
            : '회복 ${(ratio * 100 + 1e-9).floor()}% 진행',
      ),
    );
    final int need = cfg.recoverHoldBars;
    final int held = replay.heldBars < need ? replay.heldBars : need;
    out.add(
      GaugeProgress(
        code: GaugeCodes.hold,
        label: '유지 기간',
        normalized: held / need,
        valueText: held >= need ? '유지 완료' : '$held/$need거래일',
      ),
    );
    final int? bullNeed = switch (level) {
      BreakerLevel.halted => cfg.haltReleaseBullStreak,
      BreakerLevel.stopped => cfg.stopReleaseBullStreak,
      _ => null,
    };
    if (bullNeed != null) {
      final int b = replay.bullStreak < bullNeed ? replay.bullStreak : bullNeed;
      out.add(
        GaugeProgress(
          code: GaugeCodes.bullStreak,
          label: 'BULL 연속',
          normalized: b / bullNeed,
          valueText: 'BULL 연속 $b/$bullNeed일',
        ),
      );
    }
  }
  final DateTime? confirmed = effectiveChecklistConfirmedAt(killSwitch);
  if (killSwitchActive(killSwitch, cfg: killSwitchConfig) &&
      confirmed != null) {
    final Duration wait = killSwitchConfig.resumeMinWait;
    if (trustedNowUtc == null) {
      out.add(
        const GaugeProgress(
          code: GaugeCodes.cooldown,
          label: '냉각 기간',
          normalized: 0,
          valueText: '신뢰 시각 확인 중',
        ),
      );
    } else {
      final Duration elapsed = trustedNowUtc.toUtc().difference(confirmed);
      final double ratio = _clamp01(
        elapsed.inMicroseconds / wait.inMicroseconds,
      );
      final Duration left = wait - elapsed;
      final int hours = (left.inMinutes + 59) ~/ 60;
      out.add(
        GaugeProgress(
          code: GaugeCodes.cooldown,
          label: '냉각 기간',
          normalized: ratio,
          valueText: ratio + 1e-9 >= 1 ? '냉각 완료' : '남은 $hours시간',
        ),
      );
    }
  }
  return out;
}

/// `ramp_state.level` → `RampLevel`(R62 U7) — 행 없음 = L1 · 🔴 L0 은 내지 않는다.
RampLevel rampLevelOf(int? level) {
  if (level == null) return RampLevel.l1;
  if (level < 1 || level > 5) {
    throw RangeError.range(level, 1, 5, 'ramp_state.level');
  }
  return RampLevel.values[level];
}

/// 안전 상태 기준(R62 U8) — 관측 = 지금 · 거래일 = 최근 스냅숏(없으면 한국 오늘).
AsOf safetyAsOf({required String? lastSnapshotDate, required DateTime nowUtc}) {
  final String day = lastSnapshotDate ?? kstDateText(nowUtc);
  return AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kReconStaleAfter,
    label: '안전 상태 기준 $day',
  );
}

/// `SafetyState` 조립(R62 U2 · U6) — `alertBlockSatEntry` = 레벨 ≥ ALERT(P0 스위치 켜짐) · 🆕 E16j-b [holds] = 표시 hold(미결 212 ② ·
/// 막지 않는다 · 막는 정본 = 리스 · 모드 판정).
SafetyState safetyStateOf({
  required BreakerLevel level,
  required double drawdown,
  required List<BlockFlag> flags,
  required KillSwitchView killSwitch,
  required bool stoppedReleaseEligible,
  required List<GaugeProgress> releaseProgress,
  required RampLevel rampLevel,
  required RunMode mode,
  required AsOf asOf,
  List<String> holds = const <String>[],
}) => SafetyState(
  breakerLevel: contractBreakerLevelOf(level),
  breakerLabel: breakerLabelOf(level),
  drawdown: drawdown,
  activeFlags: flags,
  killSwitch: killSwitch,
  stoppedReleaseEligible: stoppedReleaseEligible,
  releaseProgress: releaseProgress,
  alertBlockSatEntry: level.index >= BreakerLevel.alert.index,
  rampLevel: rampLevel,
  mode: mode,
  asOf: asOf,
  holds: holds,
);
