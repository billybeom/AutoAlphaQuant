// 🆕 E11q-b3 — M5-5 차단 보드 VM(설계 13 §8 R185 · 01 §34 K154 · K155 · 미결 188 M5-5 읽기 몫 · 203 · 표본 `m5/block_board_*`).
//
// 🔴 원천 = 홈과 같은 `SafetyState` 한 장(브레이커 · 플래그 · 킬스위치 · 게이지 · 재개 자격 · 기준) — 보드가 따로 읽지 않는다
//    (홈 블록 1 · 3 이 보드로 오므로 둘이 어긋나면 안 된다).
// 🔴 행 = 켜진 킬스위치 먼저 + 표식 아닌 플래그(홈 블록 3 과 같은 거름 · 엔진 차례 그대로) · 행 레벨 = 주문 판정 묶음
//    (`BlockBundles` — 전 주문 = BLOCKED · 신규 매수 · 진입 안내 = ACT · 정정 뮤텍스 = WATCH).
// 🔴 링크 = 엔진 목적지 중 조립 앱에 본문이 있는 것만(`hasBody` — 없는 화면으로 보내지 않는다) · 대사 불일치 = 이 보드 자신 → 행 링크 0
//    · 킬스위치 진입 = 늘(끄는 길은 언제나).
// 🔴 해제 버튼 0 · 카운트다운 0(게이지 = `releaseProgress` 글자 그대로) — 🆕 E11q-c4(R189 · 01 §35 K181) 하나 예외: RECON_MISMATCH 행만
//    해제 폼(`reconClear` = `reconClearFormOf` · 원인 코드 선택지 = 엔진) · 쓰기 창구 ∧ 잠김 아님(`reconClearable`)일 때만 · 그 밖 행 = null.
// 🔵 엔진 글자(미결 203) = 계약 표본이 제안한 문장(«(합성)» 표지 뗌 · 발주자 위임 — 권고대로) · 브레이커 머리 = 사다리 조치 글자.

import 'package:domain_contracts/domain_contracts.dart' as c show BreakerLevel;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        BlockBoardRow,
        BlockBoardVm,
        BlockFlag,
        BreakerLadderRow,
        BreakerLadderVm,
        ClearRoute,
        FlagIds,
        LinkAction,
        SafetyState,
        UiLevel;

import '../orders/block_bundles.dart' show BlockBundles;
import '../risk/breaker.dart';
import 'breaker_ladder.dart' show BreakerLadderStep, breakerLadderOf;
import 'recon_clear.dart' show reconClearFormOf;

/// M5-5 글자(표본 제안 문장 · 엔진 사전 밖 몫).
abstract final class BlockBoardTexts {
  /// 킬스위치 행 id(계약 `BlockBoardRow.rowId` ∈ `FlagIds.values` ∪ {이것}).
  static const String killSwitchRowId = 'KILL_SWITCH';

  /// 막힌 것 0 · 정상.
  static const String clearHeadline = '막힌 것 없음 — 규칙대로 돌고 있습니다';

  /// 빈 문장(행 0 ∧ 브레이커 정상).
  static const String empty = '지금 막힌 것이 없습니다';

  /// 킬스위치 진입(늘).
  static const String killSwitchLink = '킬스위치';

  /// 킬스위치 행 링크.
  static const String killSwitchRowLink = '킬스위치 보기';

  /// 킬스위치 행 해제 성격.
  static const String killSwitchClearKind = '재개 게이트로만 풀립니다';

  /// STOPPED 재개 결정.
  static const String stoppedDecision = '재개 결정하기';

  /// 머리 짧은 이름(킬스위치).
  static const String killSwitchShort = '킬스위치';

  /// «막힌 것 N — 이름 · 이름» · 브레이커가 정상이 아니면 « · 서킷브레이커 {단} 단계».
  static String rowsHeadline(List<String> names, String? breakerLabel) =>
      '막힌 것 ${names.length} — ${names.join(' · ')}'
      '${breakerLabel == null ? '' : ' · 서킷브레이커 $breakerLabel 단계'}';

  /// 행 0 ∧ 브레이커 정상 아님 — «서킷브레이커 {단} 단계 — {사다리 조치}».
  static String breakerHeadline(String label, String action) =>
      '서킷브레이커 $label 단계 — $action';

  /// «MM-DD HH:mm부터»(한국).
  static String setAt(DateTime utc) {
    final DateTime k = utc.toUtc().add(const Duration(hours: 9));
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(k.month)}-${two(k.day)} ${two(k.hour)}:${two(k.minute)}부터';
  }

  /// 해제 성격(`ClearRoute` 짝 글자).
  static String clearKind(ClearRoute r) => switch (r) {
    ClearRoute.automatic => '자동으로 풀립니다',
    ClearRoute.causeCodeRequired => '원인 코드를 골라야 풀립니다',
    ClearRoute.noManualPath => '직접 풀 수 없습니다',
    ClearRoute.wizardOnly => '복구 절차에서만 풀립니다',
  };

  /// 머리 짧은 이름(플래그 — 표본 «재개 점검 · 일지» 꼴).
  static const Map<String, String> flagShort = <String, String>{
    FlagIds.ledgerIntegrity: '원장 무결성',
    FlagIds.reconMismatch: '대사 불일치',
    FlagIds.resumeIncomplete: '재개 점검',
    FlagIds.ledgerFix: '정정',
    FlagIds.adviceLedgerUnverified: '원장 실사',
    FlagIds.selfAuditOverdue: '실사 기한',
    FlagIds.journalMissing: '일지',
    FlagIds.tierBUnjudged: 'TIER B 판정',
  };

  /// 행 링크 글자(목적지 → 글자).
  static const Map<String, String> linkLabel = <String, String>{
    AppRoutes.x2ResumeGate: '재개 화면 보기',
    AppRoutes.journalDraft: '일지 쓰기',
    AppRoutes.x5RepairWizard: '복구 절차 열기',
    AppRoutes.m5SelfAuditResolve: '실사 해소 열기',
  };
}

/// 엔진 목적지(구체 링크) → 계약 라우트 패턴(`:이름` 칸 = 빈 아닌 한 마디) · 없으면 null.
String? routePatternOf(String link) {
  final List<String> want = link.split('/');
  for (final String p in AppRoutes.all) {
    final List<String> seg = p.split('/');
    if (seg.length != want.length) continue;
    bool ok = true;
    for (int i = 0; i < seg.length && ok; i++) {
      ok = seg[i].startsWith(':') ? want[i].isNotEmpty : seg[i] == want[i];
    }
    if (ok) return p;
  }
  return null;
}

/// 행 레벨(주문 판정 묶음).
UiLevel _flagLevel(String flagId) {
  if (BlockBundles.allOrders.contains(flagId)) return UiLevel.blocked;
  if (BlockBundles.newBuys.contains(flagId) ||
      BlockBundles.entryAdvice.contains(flagId)) {
    return UiLevel.act;
  }
  return UiLevel.watch;
}

/// 브레이커 레벨 → 보드 레벨.
UiLevel _breakerLevel(BreakerLevel l) => switch (l) {
  BreakerLevel.normal => UiLevel.ok,
  BreakerLevel.alert => UiLevel.watch,
  BreakerLevel.reduced => UiLevel.act,
  BreakerLevel.halted || BreakerLevel.stopped => UiLevel.blocked,
};

/// 사다리 VM(M5-4 감싸기 — 엔진 `breakerLadderOf` 글자 그대로).
BreakerLadderVm breakerLadderVmOf(
  List<BreakerLadderStep> steps,
  SafetyState state,
) => BreakerLadderVm(
  rows: <BreakerLadderRow>[
    for (final BreakerLadderStep s in steps)
      BreakerLadderRow(
        level: c.BreakerLevel.values.firstWhere(
          (c.BreakerLevel x) => x.wire == s.level.code,
        ),
        label: s.label,
        triggerText: s.triggerText,
        releaseText: s.releaseText,
        actionText: s.actionText,
        current: s.current,
      ),
  ],
  asOf: state.asOf,
);

/// M5-5 한 화면 — [state] = 홈과 같은 안전 상태 · [hasBody] = 조립 앱에 그 라우트 본문이 있나 ·
/// [config] · [satelliteActive] = 사다리 글자(`breakerLadderOf` 와 같은 뜻) ·
/// 🆕 [reconClearable] = RECON 해제를 낼 쓰기 창구가 있고 잠김이 아닌가(R189 — 거짓 = 폼 0 · 뷰어 · 잠김).
BlockBoardVm blockBoardVmOf({
  required SafetyState state,
  required bool Function(String route) hasBody,
  BreakerConfig? config,
  bool satelliteActive = false,
  bool reconClearable = false,
}) {
  final BreakerLevel level = BreakerLevel.fromCode(state.breakerLevel.wire);
  final List<BreakerLadderStep> steps = breakerLadderOf(
    current: level,
    config: config,
    satelliteActive: satelliteActive,
  );
  final List<BlockBoardRow> rows = <BlockBoardRow>[
    if (state.killSwitch.active)
      BlockBoardRow(
        rowId: BlockBoardTexts.killSwitchRowId,
        label: state.killSwitch.stateLabel,
        setAtText: state.killSwitch.activatedAt == null
            ? null
            : BlockBoardTexts.setAt(state.killSwitch.activatedAt!),
        clearKindLabel: BlockBoardTexts.killSwitchClearKind,
        clearInstruction:
            state.killSwitch.releaseEtaText ??
            state.killSwitch.checklistStateLabel ??
            BlockBoardTexts.killSwitchClearKind,
        level: UiLevel.blocked,
        link: hasBody(AppRoutes.m5KillSwitch)
            ? const LinkAction(
                label: BlockBoardTexts.killSwitchRowLink,
                deepLink: AppRoutes.m5KillSwitch,
              )
            : null,
      ),
    for (final BlockFlag f in state.activeFlags)
      if (!FlagIds.markerOnly.contains(f.flagId))
        BlockBoardRow(
          rowId: f.flagId,
          label: f.label,
          setAtText: BlockBoardTexts.setAt(f.setAt),
          clearKindLabel: BlockBoardTexts.clearKind(f.clearRoute),
          clearInstruction: f.clearInstruction,
          level: _flagLevel(f.flagId),
          link: _rowLink(f, hasBody),
          reconClear: reconClearable && f.flagId == FlagIds.reconMismatch
              ? reconClearFormOf()
              : null,
        ),
  ];
  final bool normal = level == BreakerLevel.normal;
  final BreakerLadderStep current = steps.firstWhere(
    (BreakerLadderStep s) => s.current,
  );
  final List<String> names = <String>[
    for (final BlockBoardRow r in rows)
      r.rowId == BlockBoardTexts.killSwitchRowId
          ? BlockBoardTexts.killSwitchShort
          : BlockBoardTexts.flagShort[r.rowId] ?? r.label,
  ];
  final UiLevel level0 = _breakerLevel(level);
  return BlockBoardVm(
    headline: rows.isNotEmpty
        ? BlockBoardTexts.rowsHeadline(names, normal ? null : current.label)
        : normal
        ? BlockBoardTexts.clearHeadline
        : BlockBoardTexts.breakerHeadline(current.label, current.actionText),
    level: <UiLevel>[
      level0,
      for (final BlockBoardRow r in rows) r.level,
    ].reduce((UiLevel a, UiLevel b) => a.index >= b.index ? a : b),
    breakerLabel: state.breakerLabel,
    rows: rows,
    gauges: state.releaseProgress,
    ladder: breakerLadderVmOf(steps, state),
    stoppedDecisionLink:
        level == BreakerLevel.stopped &&
            state.stoppedReleaseEligible &&
            hasBody(AppRoutes.m5StoppedDecision)
        ? const LinkAction(
            label: BlockBoardTexts.stoppedDecision,
            deepLink: AppRoutes.m5StoppedDecision,
          )
        : null,
    killSwitchLink: const LinkAction(
      label: BlockBoardTexts.killSwitchLink,
      deepLink: AppRoutes.m5KillSwitch,
    ),
    emptyLabel: rows.isEmpty && normal ? BlockBoardTexts.empty : null,
    asOf: state.asOf,
  );
}

/// 행 링크 — 엔진 목적지 · 본문 없음 = 0 · 계약 밖 목적지 · 글자 없는 목적지 = 0(던지지 않는다 — 보드는 킬스위치 둘째 길이라
/// 읽기 실패로 사라지면 안 된다 · 보드 밖 엔진 목적지마다 글자가 있음은 시험이 지킨다) · 🔴 이 보드 자신(대사 불일치) = 글자 표에
/// 없음 → 0(해제 = 행 폼 `reconClear` · R189).
LinkAction? _rowLink(BlockFlag f, bool Function(String route) hasBody) {
  final String? link = f.clearDeepLink;
  if (link == null) return null;
  final String? pattern = routePatternOf(link);
  final String? label = pattern == null
      ? null
      : BlockBoardTexts.linkLabel[pattern];
  if (label == null || !hasBody(pattern!)) return null;
  return LinkAction(label: label, deepLink: link);
}
