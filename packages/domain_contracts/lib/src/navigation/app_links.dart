// 01 §4-4 «내비게이션 계약» — 🆕 계약 v1.1(2026-09-17 · §8 미결 36 해소).
//
// 한 문장: **링크는 데이터로 온다.** 화면은 링크 문자열을 만들지도 해석하지도 않는다 —
// DTO 가 실어 온 문자열을 그대로 [AppLinkOpener.open] 에 넘긴다. 여는 일(라우트 테이블 ·
// 가드 리다이렉트 · 핸드북 뷰어)은 셸(M8)의 몫이다(04 §1-2 「라우트 테이블은 정적으로 전
// 라우트를 등록하고 «부재»는 가드 리다이렉트」).
//
// 🔴 화면 규칙 4조
//   ① 링크 필드가 null 이면 그 진입점은 **부재**다(비활성 버튼·자리표시자를 그리지 않는다).
//   ② 링크 문자열을 파싱·분기하지 않는다(`startsWith('aaq://m5')` 같은 코드 = 판정).
//   ③ [AppRoutes] 의 **패턴**(`:param` 이 든 것)에 값을 끼워 링크를 조립하지 않는다 —
//      파라미터가 든 링크는 언제나 엔진이 완성해서 준다.
//   ④ 파라미터 없는 고정 목적지는 화면 명세가 그 버튼을 **명시한 경우에만** [AppRoutes]
//      상수를 그대로 넘길 수 있다. 목록에 없는 목적지가 필요하면 멈추고 질문한다.
//      🆕 v1.3 — [AppNavActions].* 도 같다.
// 🔴 엔진·픽스처 규칙: `aaq://` 링크는 전부 [AppRoutes.all] 의 패턴 하나와 일치해야 한다
//    (계약 테스트 C-33). `handbook://` 는 핸드북 앵커이며 도착지는 `HandbookPage` 다.
// 🔴 이 파일은 순수 Dart 다(Flutter import 없음 — 01 §1-1). 구현체는 `ui_shell` 이 준다.

/// 화면이 링크를 여는 **유일한** 창구. 구현은 셸(M8)이 주입한다.
///
/// 화면 패키지는 `Provider<AppLinkOpener>((_) => throw UnimplementedError(...))` 를 두고
/// 조립 앱(`apps/*/lib/main.dart`)이 override 한다(01 §4-1 주입 규약과 같은 모양).
/// 테스트는 넘어온 문자열을 기록하는 가짜 구현으로 «DTO 의 링크가 그대로 전달되는가»를 본다.
abstract interface class AppLinkOpener {
  /// [link] 는 DTO 가 준 문자열 **그대로**다(`aaq://…` · `handbook://…`).
  void open(String link);
}

/// 링크의 스킴 2종.
abstract final class AppLinkSchemes {
  /// 앱 안의 화면.
  static const String app = 'aaq';

  /// 핸드북 앵커(`ReasonChip.detailDeepLink` 의 도착지).
  static const String handbook = 'handbook';

  static const Set<String> values = <String>{app, handbook};
}

/// 🆕 v1.3 · 01 §13-7 — **동작 링크**. 목적지가 아니라 «지금 화면을 닫는다»는 뜻이다.
/// 셸(M8)의 [AppLinkOpener] 구현이 뜻을 정한다: 닫을 화면이 있으면 닫고,
/// 없으면(링크로 바로 들어온 경우) 그 플랫폼의 첫 화면으로 간다.
/// 🔴 동작 링크는 `back` 하나다 — 더하는 것은 계약 버전 사안이다.
/// 🔴 화면 명세가 그 버튼을 **명시한 경우에만** 쓴다(규칙 ④ 와 같다).
/// 🔴 [AppRoutes.all] 에 넣지 않는다(목적지가 아니다). DTO·픽스처에 실리지 않는다
///    (C-33 이 검사한다).
abstract final class AppNavActions {
  /// 「돌아가기」 — 지금 화면을 닫는다.
  static const String back = 'aaq://nav/back';

  /// 전량 1종.
  static const Set<String> all = <String>{back};
}

/// 앱 라우트 **정본 목록**. 셸은 [all] 을 전량 라우트 테이블에 등록한다(04 §1-2).
///
/// `:name` 세그먼트는 파라미터다(빈 문자열 불가). 고정 세그먼트가 파라미터보다 먼저
/// 일치한다(`aaq://report/archive` 는 `reportArchive` 이지 `reportMonthly` 가 아니다).
/// 🔴 목록은 회차마다 **M2 가** 늘린다 — 화면·엔진이 이름을 지어 쓰지 않는다.
abstract final class AppRoutes {
  // ── M6 매매일지·안내·원장(02) ─────────────────────────────────────────────
  /// `J-1` 매매일지 타임라인.
  static const String journalTimeline = 'aaq://journal/timeline';

  /// `J-2` 거래 상세 — `TradeJournalEntry.detailDeepLink` 가 완성해서 준다.
  static const String journalDecision = 'aaq://journal/decision/:decisionId';

  /// `J-3` 사전 저널 작성(폰 전용) — `DecisionDetailVm.journalLink` 등이 준다.
  static const String journalDraft = 'aaq://journal/draft/:decisionId';

  /// `J-3` 사전 저널 **읽기**(`J-3R` · 🆕 v1.2) — `DecisionDetailVm.journalLink`(작성됨)가 준다.
  /// 등록 = 전 플랫폼(`all`) · 본문 = Android·iOS `JournalReadView` · 웹 = Q-D 전 셸 «부재» 가드(01 §12-2 · 04 §1-2).
  static const String journalRead = 'aaq://journal/read/:decisionId';

  /// 🆕 v1.5(01 §15-3 · §8 미결 49) — `J-1` 매매일지 타임라인을 **회차 조건으로** 연다.
  /// `RebalanceEvent.journalTimelineLink` 가 완성해서 준다(`S7-6b` 하단 버튼).
  /// 셸 본문 = `JournalTimeline(key: ValueKey(id), rebalanceEventId: id)` · 등록 = 전 플랫폼 ·
  /// 웹 가드 = `journalTimeline` 과 같다. `journal/decision`·`draft`·`read` 와 세그먼트 수가 같고
  /// 둘째 고정 세그먼트로 갈린다(v1.2 `journalRead` 선례) · `journalTimeline` 과는 세그먼트 수가 다르다.
  static const String journalRebalance =
      'aaq://journal/rebalance/:rebalanceEventId';

  /// `J-4` 사후 blind 리뷰.
  /// 🆕 v1.7 — 셸 본문 = `JournalBlindReview()`(대기 목록의 머리 카드 · 01 §16).
  static const String journalBlindReview = 'aaq://journal/blind-review';

  /// `J-5` UNKNOWN 해소 보드 — `JournalTimelineBadge.deepLink` 가 준다.
  static const String journalUnknownBoard = 'aaq://journal/unknown-board';

  /// 🆕 v1.8(01 §17) — `H6-1` 보유현황(`HoldingsOverview()`). 등록 = 전 플랫폼 · 본문 = Android·iOS · 웹 = Q-D 전 셸 «부재» 가드.
  static const String holdingsOverview = 'aaq://holdings/overview';

  /// 🆕 v1.8 — `H6-2` 종목 상세(`HoldingDetail(holdingId:)`) — `HoldingRow.detailDeepLink` 가 준다(엔진 완성).
  static const String holdingsDetail = 'aaq://holdings/detail/:holdingId';

  /// 🆕 v1.8 — `H6-3` 슬리브·비중(`HoldingsAllocation()`) — `HoldingsOverviewVm.allocationLink` · 홈 블록 4 탭(R13).
  static const String holdingsAllocation = 'aaq://holdings/allocation';

  /// `A-1` 안내 인박스.
  static const String adviceInbox = 'aaq://advice/inbox';

  /// `A-2` 안내 상세.
  static const String adviceDetail = 'aaq://advice/detail/:adviceId';

  /// `A-3` 수기 체결 기록(폰 전용). 🆕 v1.12(01 §21 · §8 미결 52 ①) — `:adviceId` · `AdviceAction.deepLink`(RECORD)가
  /// 완성해서 준다. 등록 = 전 플랫폼 · 본문 = Android `ManualFillForm(adviceId:)`(operator 라이브러리) · iOS 뷰어 셸 =
  /// «폰에서만» 부재 안내 · 웹 = `ui_journal` 없음(TARGETS T-3) — 셸 가드(선례 `journalDraft`).
  /// 🔵 v1.12 교체(구 `aaq://advice/fill` — 파라미터 없는 `A-3` 은 02 에 없다 · 안내 밖 매매 = `M5-6`).
  static const String adviceFill = 'aaq://advice/fill/:adviceId';

  /// 🆕 v1.12(01 §21 · 미결 52 ②) — `A-4` 미이행 사유 1탭(폰 전용) · `AdviceAction.deepLink`(SKIP) ·
  /// 본문 `AdviceSkipForm(adviceId:)` · 가드 = [adviceFill] 과 같다. `advice/fill`·`detail` 과 세그먼트 수가 같고
  /// **둘째 고정 세그먼트**로 갈린다(v1.2 `journalRead` 선례).
  static const String adviceSkip = 'aaq://advice/skip/:adviceId';

  /// 안내 이력.
  static const String adviceHistory = 'aaq://advice/history';

  /// `L-3` 원장 실사(폰 전용). 🆕 v1.12(01 §21 · 미결 52 ⑧ · K7 · K36 ⓐ) — 그 달(`yyyy-MM`) · 그 계좌 별칭
  /// (🔴 계좌 전체번호 아님)의 정기 실사. 엔진이 완성해서 준다(`LedgerTrustBadge.actionDeepLink` · `SELF_AUDIT_DUE`
  /// 알림·플래그 `clearDeepLink` · `H-02` 리듬 행 · `LedgerDiffRow.actionLink`(canonSelfReport) ·
  /// `SelfReportResult.nextAccountLink`). 본문 = `SelfReportForm(yyyyMm:, accountAlias:)` · 가드 = [adviceFill] 과 같다.
  /// `'/'` 로 쪼갠 조각 수(6)가 `ledger/*` 다른 라우트와 달라 겹치지 않는다. 🔵 v1.12 교체(구 `aaq://ledger/self-report`).
  /// 🔴 별칭에 `/`·`?`·`#` 가 없게 하는 것은 엔진 의무다(C-46 ⑮).
  static const String ledgerSelfReport =
      'aaq://ledger/self-report/:yyyyMm/:accountAlias';

  /// 원장 신뢰 등급 설명.
  static const String ledgerTrust = 'aaq://ledger/trust';

  /// 🆕 v1.12(01 §21 · K27) — `L-1` 차이 상세(읽기 · `LedgerDiffs()`). 홈 블록 6 탭 = 이 상수(04 §4-5 · 규칙 ④).
  /// 등록 = 전 플랫폼 · 본문 = Android·iOS(`rm_ledger_diff` v1 필수) · 웹 = Q-D 전 셸 «부재» 가드.
  static const String ledgerDiffs = 'aaq://ledger/diffs';

  /// 🆕 v1.12(01 §21 · K27) — `L-2` 정정 이력·감사(읽기 · `LedgerRepairs()`). `L-1` 하단 = 이 상수(02 §5-2 · 규칙 ④).
  /// 등록 = 전 플랫폼 · 본문 = **Android 만** · iOS·웹 = 셸 «폰에서만» 부재 안내(`rm_ledger_repair` 없음 · 01 §8 미결 117).
  static const String ledgerRepairs = 'aaq://ledger/repairs';

  /// `S7-10` 이행 갭 — 🆕 v1.6 주석: `S7-10` 은 **M7(03 §14-b) 화면**이다 · 이 묶음 표기는 역사적(H63).
  /// 인자 없는 진입(「계획」 탭 ⑤) = 엔진 기본 달 · 셸 본문 = `ExecutionGapScreen()`.
  static const String ledgerExecutionGap = 'aaq://ledger/execution-gap';

  /// 🆕 v1.6(01 §15-4 · K1) — `S7-10` 의 **그 달**(`yyyy-MM`). `MonthlyReport` ⑧ `D3_EXECUTION.detailDeepLink`
  /// 를 엔진이 완성해서 준다. 셸 본문 = `ExecutionGapScreen(key: ValueKey(m), yyyyMm: m)` — **두 라우트 · 한 위젯**
  /// (v1.5 `journalRebalance` 다음 두 번째 사례). 세그먼트 수가 달라 [ledgerExecutionGap] 과 겹치지 않는다.
  static const String ledgerExecutionGapMonth =
      'aaq://ledger/execution-gap/:yyyyMm';

  // ── M7 성과·리밸런싱·플래너(03) ───────────────────────────────────────────
  /// `S7-1b` 리포트 아카이브.
  static const String reportArchive = 'aaq://report/archive';

  /// 세후 사다리 단독 보기 — 03 §12 `S7-7` 세후 카드와 같은 `AfterTaxLadder`(03 에 별도 화면 ID 없음).
  /// 🆕 v1.4 주석 정정 — 구 «`S7-7` 세후 사다리»·«`S7-8` 연간 리뷰»는 오기였다
  /// (`S7-7` = 12월 연간 리뷰 · `S7-8` = X2 재개 리포트 읽기 사본 · 03 §2).
  /// 🆕 v1.6 — 03 에 화면 없음 · R12 밖 · `S7-7` 세후는 VM `afterTax` 블록.
  static const String reportAfterTax = 'aaq://report/aftertax';

  /// `S7-7` 12월 연간 리뷰 패키지. 🆕 v1.6 — 셸 본문 = `AnnualReviewScreen()`.
  static const String reportAnnual = 'aaq://report/annual';

  /// `S7-1` 월간 리포트(`yyyy-MM`).
  static const String reportMonthly = 'aaq://report/:yyyyMm';

  /// 🆕 v1.4(01 §14-9) — `S7-9` 목표 경로(`yyyy-MM`) — `MonthlyReport.goalDeepLink` 가 완성해서 준다.
  /// 세그먼트 수가 [reportMonthly] 와 달라 겹치지 않는다(고정 `goal` + 파라미터).
  static const String reportGoalPath = 'aaq://report/goal/:yyyyMm';

  /// `S7-2` 성과 탐색(열람 게이트 뒤).
  static const String performanceExplore = 'aaq://performance/explore';

  /// `S7-3` 드로다운·TUW 컨텍스트.
  static const String performanceDrawdown = 'aaq://performance/drawdown';

  /// `S7-3b` 슬리브 기여 분해.
  static const String performanceContribution =
      'aaq://performance/contribution';

  /// `S7-4` 납입 플래너.
  /// 🆕 v1.4(01 §14-1) — **operator 전용 화면**(`package:ui_analytics/planner.dart` · 배럴 밖).
  /// viewer 셸도 [all] 대로 등록하되 목적지는 «폰에서만 쓸 수 있습니다» 부재 안내다(셸 몫 · 01 §14 ·
  /// 선례 = `journalDraft` 의 iOS 셸 가드).
  /// ⏸ `planWithdrawal`(S7-5) 은 인출 규칙 결정(01 §8 미결 79) 뒤 첫 minor 에서 더한다(01 §14-15 · §15-3).
  static const String planDeposit = 'aaq://plan/deposit';

  // M7 묶음 — `all` 에서도 rebalancePreview 앞
  /// 🆕 v1.6(01 §15-4 · K5) — `S7-6a` 리밸런싱 회차 타임라인(`RebalanceTimelineScreen()`).
  static const String rebalanceHistory = 'aaq://rebalance/history';

  /// `S7-6c` 리밸런싱 미리보기. 🆕 v1.6 — 셸 본문 = `RebalancePreviewScreen()`.
  static const String rebalancePreview = 'aaq://rebalance/preview';

  /// `S7-6b` 리밸런싱 회차 상세 — `DecisionDetailVm.rebalanceLink` 등이 준다.
  static const String rebalanceEvent =
      'aaq://rebalance/event/:rebalanceEventId';

  // ── M8 셸·운영·온보딩 · M9 설정(04 · 05) ─────────────────────────────────
  /// 온보딩·재연결 단계(`o_00`~ · `r_00`~).
  static const String onboardingStep = 'aaq://onboarding/:stepId';
  static const String opsArchive = 'aaq://ops/archive';
  static const String opsMaintenance = 'aaq://ops/maintenance';
  static const String opsWatchdog = 'aaq://ops/watchdog';

  /// 🆕 v1.12(01 §21 · K43) — `H-02` 운영 리듬 표(`OpsRhythm()` · `ui_shell`). 홈 블록 7·8 탭·«더 보기» = 이 상수
  /// (04 §4-6 · 규칙 ④). 등록 = 전 플랫폼 · 본문 = 전 플랫폼(`rm_ops_summary` v1 필수 · N-07).
  static const String opsRhythm = 'aaq://ops/rhythm';

  /// 🆕 v1.15(01 §24 · K7) — `N-01` 알림 센터(`AlertCenter()` · `ui_shell`). 등록 = 전 플랫폼 · 가드 = 기본 open
  /// (뷰어 = 조회 · 확인 버튼 부재). 진입 = 데이터 링크·푸시·FGS 탭(셸 진입 UI 0 · K22).
  static const String alertsInbox = 'aaq://alerts/inbox';

  /// 🆕 v1.15 — `N-02` 알림 상세(`AlertDetail(alertId:)`) · 들어오는 링크 = `AlertItem.detailDeepLink`(데이터) ·
  /// 푸시·FGS 탭(엔진).
  static const String alertDetail = 'aaq://alerts/detail/:alertId';
  static const String settingsContribution = 'aaq://settings/contribution';
  static const String settingsCredentials = 'aaq://settings/credentials';
  static const String handoverStatus = 'aaq://handover/status';

  // ── M5 · X1 · X2 · X5 소유(06 §3-5 목록 — 위젯은 Claude, 등록은 셸) ────────
  static const String m5KillSwitch = 'aaq://m5/kill-switch';
  static const String m5ReleaseGate = 'aaq://m5/release-gate';
  static const String m5BlockBoard = 'aaq://m5/block-board';
  static const String m5Intervention = 'aaq://m5/intervention';
  static const String m5HandoverGate = 'aaq://m5/handover-gate';
  static const String m5HandoverWizard = 'aaq://m5/handover-wizard';

  /// `M5-13` 원장 실사 해소·격리 검토.
  static const String m5SelfAuditResolve = 'aaq://m5/self-audit-resolve';
  static const String x1Migration = 'aaq://x1/migration';
  static const String x2ResumeReport = 'aaq://x2/resume-report';
  static const String x2ResumeGate = 'aaq://x2/resume-gate';

  /// `X5-3`·`M5-12` 정합 복구·수기 체결 정정 마법사.
  static const String x5RepairWizard = 'aaq://x5/repair-wizard';

  /// 전량 — 셸 라우트 테이블과 C-33 의 모집단(🆕 v1.5 = 43 · `journalRebalance` ·
  /// 🆕 v1.6 = 45 · `ledgerExecutionGapMonth`·`rebalanceHistory` · 🆕 v1.8 = 48 · `holdingsOverview`·
  /// `holdingsDetail`·`holdingsAllocation` · 🆕 v1.12 = **52** · `adviceSkip`·`ledgerDiffs`·`ledgerRepairs`·`opsRhythm`
  /// + 교체 2 `adviceFill`·`ledgerSelfReport`). 순서 = 첫 일치(C-33 ⑦ · 겹침 0) — `adviceSkip` 은 `adviceFill` 뒤 ·
  /// `ledgerDiffs`·`ledgerRepairs` 는 `ledgerTrust` 뒤 · `opsRhythm` 은 `opsWatchdog` 뒤.
  static const List<String> all = <String>[
    journalTimeline,
    journalDecision,
    journalDraft,
    journalRead,
    journalRebalance,
    journalBlindReview,
    journalUnknownBoard,
    holdingsOverview,
    holdingsDetail,
    holdingsAllocation,
    adviceInbox,
    adviceDetail,
    adviceFill,
    adviceSkip,
    adviceHistory,
    ledgerSelfReport,
    ledgerTrust,
    ledgerDiffs,
    ledgerRepairs,
    ledgerExecutionGap,
    ledgerExecutionGapMonth,
    reportArchive,
    reportAfterTax,
    reportAnnual,
    reportMonthly,
    reportGoalPath,
    performanceExplore,
    performanceDrawdown,
    performanceContribution,
    planDeposit,
    rebalanceHistory,
    rebalancePreview,
    rebalanceEvent,
    onboardingStep,
    opsArchive,
    opsMaintenance,
    opsWatchdog,
    opsRhythm,
    alertsInbox,
    alertDetail,
    settingsContribution,
    settingsCredentials,
    handoverStatus,
    m5KillSwitch,
    m5ReleaseGate,
    m5BlockBoard,
    m5Intervention,
    m5HandoverGate,
    m5HandoverWizard,
    m5SelfAuditResolve,
    x1Migration,
    x2ResumeReport,
    x2ResumeGate,
    x5RepairWizard,
  ];

  /// [link] 가 [all] 의 패턴 하나와 일치하는가.
  ///
  /// 🔴 **화면은 부르지 않는다**(규칙 ② — 해석 금지). 쓰는 곳은 셸의 라우트 등록 검증과
  ///    계약 테스트 C-33 둘이다. 쿼리·프래그먼트가 붙은 링크는 일치하지 않는다(링크에
  ///    개인 정보·상태를 싣지 않는다).
  static bool isRegistered(String link) {
    for (final String pattern in all) {
      if (_matches(pattern, link)) {
        return true;
      }
    }
    return false;
  }

  static bool _matches(String pattern, String link) {
    final List<String> p = pattern.split('/');
    final List<String> l = link.split('/');
    if (p.length != l.length) {
      return false;
    }
    for (int i = 0; i < p.length; i++) {
      final bool isParam = p[i].startsWith(':');
      if (isParam) {
        if (l[i].isEmpty || l[i].contains('?') || l[i].contains('#')) {
          return false;
        }
      } else if (p[i] != l[i]) {
        return false;
      }
    }
    return true;
  }
}
