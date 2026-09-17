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

  /// `J-4` 사후 blind 리뷰.
  static const String journalBlindReview = 'aaq://journal/blind-review';

  /// `J-5` UNKNOWN 해소 보드 — `JournalTimelineBadge.deepLink` 가 준다.
  static const String journalUnknownBoard = 'aaq://journal/unknown-board';

  /// `A-1` 안내 인박스.
  static const String adviceInbox = 'aaq://advice/inbox';

  /// `A-2` 안내 상세.
  static const String adviceDetail = 'aaq://advice/detail/:adviceId';

  /// `A-3` 수기 체결 기록(폰 전용).
  static const String adviceFill = 'aaq://advice/fill';

  /// 안내 이력.
  static const String adviceHistory = 'aaq://advice/history';

  /// `L-3` 원장 실사(폰 전용).
  static const String ledgerSelfReport = 'aaq://ledger/self-report';

  /// 원장 신뢰 등급 설명.
  static const String ledgerTrust = 'aaq://ledger/trust';

  /// `S7-10` 이행 갭.
  static const String ledgerExecutionGap = 'aaq://ledger/execution-gap';

  // ── M7 성과·리밸런싱·플래너(03) ───────────────────────────────────────────
  /// `S7-1b` 리포트 아카이브.
  static const String reportArchive = 'aaq://report/archive';

  /// `S7-7` 세후 사다리.
  static const String reportAfterTax = 'aaq://report/aftertax';

  /// `S7-8` 연간 리뷰.
  static const String reportAnnual = 'aaq://report/annual';

  /// `S7-1` 월간 리포트(`yyyy-MM`).
  static const String reportMonthly = 'aaq://report/:yyyyMm';

  /// `S7-2` 성과 탐색(열람 게이트 뒤).
  static const String performanceExplore = 'aaq://performance/explore';

  /// `S7-3` 드로다운·TUW 컨텍스트.
  static const String performanceDrawdown = 'aaq://performance/drawdown';

  /// `S7-3b` 슬리브 기여 분해.
  static const String performanceContribution =
      'aaq://performance/contribution';

  /// `S7-4` 납입 플래너.
  static const String planDeposit = 'aaq://plan/deposit';

  /// `S7-6c` 리밸런싱 미리보기.
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

  /// 전량 — 셸 라우트 테이블과 C-33 의 모집단.
  static const List<String> all = <String>[
    journalTimeline,
    journalDecision,
    journalDraft,
    journalBlindReview,
    journalUnknownBoard,
    adviceInbox,
    adviceDetail,
    adviceFill,
    adviceHistory,
    ledgerSelfReport,
    ledgerTrust,
    ledgerExecutionGap,
    reportArchive,
    reportAfterTax,
    reportAnnual,
    reportMonthly,
    performanceExplore,
    performanceDrawdown,
    performanceContribution,
    planDeposit,
    rebalancePreview,
    rebalanceEvent,
    onboardingStep,
    opsArchive,
    opsMaintenance,
    opsWatchdog,
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
