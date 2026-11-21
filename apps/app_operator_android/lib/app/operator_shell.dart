// operator 셸 주입(E11p3d-1 · 설계 13 §8 R104 · 06 M4-11 ⑥ · M4-12 · 01 §2 셸 주입).
//
// 🔴 실물이 있는 칸만 주입하고, 실물이 있는 화면만 레지스트리에 올린다 — 올리지 않은 라우트는 셸이 «자리 부재»
//    (`s01-placeholder`)로 그린다(빈 칸 · 크래시가 아니다 · M4-11 머리 «미주입 = 자리 부재»).
// 🔴 이번 조각 = 셸 뼈대 + 알림 센터 · 상세(실물 = `SqliteAlertRepository`) · 확인 버튼 = 명령 API 전이라 부재(null).
// 🆕 E11p3d-5(R107) — 캡처 막기 라우트 감싸기 · https 링크 = 브라우저.
// 🆕 E11p3d-3b(R113) — 안전 상태(셸 · 일지 · 분석 = 한 인스턴스) · 분석 · 설정 패키지의 실물 칸(시계 · 링크 · 운영 상태) 미리 주입.
//    🔴 주입 의무 = 실물이 있는 칸은 전부 — 빠진 칸은 화면이 `valueOrNull` 로 삼켜 배너가 소리 없이 사라진다(시험이 표로 지킨다).
// 🆕 E11p3d-5b(R115) — 온보딩 슬롯 빌더(M4-11 ①): `SECRET_KIS_MOCK` = KIS 키 세트 시크릿 칸(M4-4) · 나머지 슬롯 = 자리 부재(크기 0).
// 🆕 E11p3d-5c(R118) — 설정 · 온보딩 «동작» = `OperatorSettingsActions`(첫 칸 = 키 검증 1단) · 🔴 operator 빌드 주입 의무(M4-12 ⑤ · 비-null 단언 시험).
// 🆕 E11p4b(R125) — 온보딩 읽기 모델(`OperatorOnboardingRepository`) · 본문 4(첫 화면 · 운영 방식 · 단계 목록 · 단계 상세) ·
//    동작에 sim 파일(운영 방식 선택 · 키 검증 → 진척 기록). 마무리 · 재시작 = 4c · 4d.
// 🆕 E11p3d-2b(R133) — 홈(H-01) 본문 · 운영 리듬(H-02) = `OperatorOpsSummaryRepository`(오늘 요약 · 리듬) + 이미 있는 안전 상태 ·
//    진단 · 원천 없는 셋(안내 요약 · 슬리브 비중 · 원장 실사 배지 = «원천 없음» 오류 — 블록 부재 · 다시 시도).
// 🆕 E11p3d-5i(R151) — M9 S03 계좌 · 매핑 본문(읽기만 · 선택 · 검증 = 동작 · 실전 키 전 · 운영 설정 없음 = 슬리브 미지정).
// 🆕 E11p3d-4a(R147) — 알림 «확인했습니다» = `OperatorCommandApi.acknowledgeAlert`(엔진 `SqliteAlertSink.acknowledge` · 맥락 = 이 기기 id) ·
//    기기 id 가 없으면 주입하지 않는다(버튼 부재) · 알림 화면에만 주입(나머지 명령 = operator 구현 전).
// 🆕 E11p3d-5h(R146) — M9 S06 기기 · 접근 본문(캡처 막기 = `kSecureRoutePatterns` 이미 · 링크 = 레지스트리에 본문이 있는 화면만).
// 🆕 E11p3d-5f(R140) — M9 S07 연결 본문(`OperatorOpsStatusRepository.watchConnections` · 링크 = 레지스트리에 본문이 있는 화면만).
// 🆕 E11p3d-2c(R136) — H-03 물리 리스크 점검 본문(기기 측정 = `OperatorRuntime.deviceProbe` · 판정 = 엔진) — Android 전용 = 이 레지스트리.
// 🆕 E11p3d-5e(R134) — 더보기 본문 = M9 S01 설정 홈(`OperatorSettingsRepository.watchHome` · 링크 = 레지스트리에 본문이 있는 화면만).
// 🆕 E11q-q4a — M6 매매일지 «읽기» 넷(J-1 타임라인 = «일지» 탭 본문 · J-2 거래 상세 · J-3R 사전 저널 읽기 · J-1 회차 조건) ·
//    읽기 = `OperatorJournalRepository`(원장 한 파일) · 기간 프리셋 · 슬리브 = 셸 설정 원천 한 인스턴스.
// 🆕 E11q-q4b — J-5 미해소 보드(같은 저장소) · J-3 사전 저널 쓰기 = 계약 창 · M5-6 조립 뒤(지금 엔진이 J-3 로 보내는 길 0).
// 🆕 E11q-q5a(R220) — M7 S7-7 연간 리뷰 · S7-10 이행 갭(인자 없음 · 그 달 = 한 위젯) = `OperatorPerformanceRepository` ·
//    `OperatorExecutionGapRepository` → S12 목차 두 행 · 월간 리포트 ⑧ 링크 목적지가 열린다.
// 🔵 장애 배너 · 핸드북은 원천(읽기 모델 · 명령)이 서는 조각에서 더한다(R104 나눔).
//    🔴 M4-12 ① «장애 · 핸드북 override 의무»는 아직 못 지킨다 — 실물 저장소가 없다(R104 남김 · d6).

import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisKeySet, KisRestClient;
import 'package:data_sync/data_sync.dart'
    show
        ContributionSettingSource,
        SqliteAlertRepository,
        SqliteLedgerRepository;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AlertRepository,
        AppRoutes,
        CommandApi,
        LedgerRepository,
        OnboardingSlotIds,
        OpsSlotIds,
        SettingsActions;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:ui_analytics/planner.dart'
    show
        DepositPlannerScreen,
        plannerCommandApiProvider,
        plannerConfigRepositoryProvider,
        plannerWhatIfApiProvider;
import 'package:ui_analytics/ui_analytics.dart'
    show
        AnnualReviewScreen,
        ExecutionGapScreen,
        RebalanceEventScreen,
        RebalancePreviewScreen,
        RebalanceTimelineScreen,
        analyticsClockProvider,
        analyticsLinkOpenerProvider,
        analyticsWhatIfApiProvider,
        executionGapRepositoryProvider,
        performanceRepositoryProvider,
        rebalanceRepositoryProvider,
        safetyRepositoryProvider;
import 'package:ui_journal/ui_journal.dart'
    show
        HoldingDetail,
        HoldingsAllocation,
        HoldingsOverview,
        JournalDecisionDetail,
        JournalReadView,
        JournalTimeline,
        JournalUnknownBoard,
        LedgerDiffs,
        LedgerRepairs,
        journalClockProvider,
        journalConfigRepositoryProvider,
        journalHoldingsRepositoryProvider,
        journalLedgerRepositoryProvider,
        journalLinkOpenerProvider,
        journalRebalanceRepositoryProvider,
        journalSafetyRepositoryProvider,
        journalTimelineRepositoryProvider;
import 'package:ui_safety/sim_opening.dart'
    show SimOpeningCash, safetySimOpeningCommandApiProvider;
import 'package:ui_safety/ui_safety.dart'
    show
        BlockBoardScreen,
        HandoverWizardScreen,
        KillResumeGateScreen,
        KillSwitchScreen,
        KillSwitchSlot,
        PledgePanel,
        ResumeGateScreen,
        ResumeReportScreen,
        RuleChangeGateScreen,
        safetyActionsProvider,
        safetyBlockBoardRepositoryProvider,
        safetyHandoverRepositoryProvider,
        safetyKillCommandApiProvider,
        safetyKillSwitchGateRepositoryProvider,
        safetyLinkOpenerProvider,
        safetyPledgeRepositoryProvider,
        safetyResumeGateRepositoryProvider,
        safetyRuleChangeGateRepositoryProvider,
        safetySettingsActionsProvider;
import 'package:ui_settings/ui_settings.dart'
    show
        Accounts,
        AnnualReviewEntry,
        BackupRestore,
        Connections,
        Credentials,
        Devices,
        Diagnostics,
        MonthlyContribution,
        SettingsHome,
        settingsActionsProvider,
        settingsClockProvider,
        settingsLinkOpenerProvider,
        settingsOpsStatusRepositoryProvider,
        settingsRepositoryProvider,
        settingsSlotBuilderProvider;
import 'package:ui_shell/ui_shell.dart';

import '../safety/biometric_sign_field.dart';
import '../safety/golden_selftest_field.dart';
import '../secret/kis_key_set_field.dart';
import '../secret/secret_handoff.dart';
import '../secret/supabase_connect_field.dart';
import '../secret/supabase_login_field.dart';
import 'operator_backup.dart';
import 'operator_biometric.dart';
import 'operator_block_board.dart';
import 'operator_command_api.dart';
import 'operator_golden.dart' show OperatorGolden;
import 'operator_handover.dart';
import 'operator_journal.dart';
import 'operator_kill_switch.dart';
import 'operator_onboarding.dart';
import 'operator_ops_status.dart';
import 'operator_ops_summary.dart';
import 'operator_performance.dart';
import 'operator_pledge.dart';
import 'operator_resume.dart';
import 'operator_rule_change.dart';
import 'operator_runtime.dart';
import 'operator_safety.dart';
import 'operator_settings_actions.dart';
import 'operator_settings_repository.dart';
import 'operator_view.dart';
import 'secure_screen.dart';

/// 실행 묶음(조립 앱이 주입).
final Provider<OperatorRuntime> operatorRuntimeProvider =
    Provider<OperatorRuntime>(
      (Ref ref) => throw UnimplementedError(
        'operatorRuntimeProvider must be overridden',
      ),
    );

/// 화면 상태(깨어남마다 바뀐다).
final ChangeNotifierProvider<ValueNotifier<OperatorView?>>
operatorViewProvider = ChangeNotifierProvider<ValueNotifier<OperatorView?>>(
  (Ref ref) => ref.watch(operatorRuntimeProvider).view,
);

/// 🔴 화면이 읽는 원장 — 기동 판정이 고른 파일(첫 깨어남 전 · 온보딩 미완 = sim 파일).
final Provider<Database> operatorDbProvider = Provider<Database>(
  (Ref ref) =>
      ref.watch(operatorViewProvider).value?.db ??
      ref.watch(operatorRuntimeProvider).files.sim,
);

/// 🆕 E11q-c2(R201) — M9 S09 백업(한 인스턴스 — 읽기 · «지금 백업» 동작이 같은 것을 쓴다 · 만들면 읽기가 다시 낸다).
final Provider<OperatorBackup> operatorBackupProvider =
    Provider<OperatorBackup>((Ref ref) {
      final OperatorBackup b = OperatorBackup(
        ref.watch(operatorRuntimeProvider),
      );
      ref.onDispose(b.dispose);
      return b;
    });

/// 🆕 R113 — 운영 상태(셸 · 설정 = 한 인스턴스 — 바깥 목록 캐시를 같이 쓴다).
final Provider<OperatorOpsStatusRepository> operatorOpsStatusProvider =
    Provider<OperatorOpsStatusRepository>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorOpsStatusRepository(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
        // 🆕 R201 — S09 백업.
        backup: ref.watch(operatorBackupProvider),
      );
    });

/// 🆕 R147 — 명령 API(알림 화면 주입 · 한 인스턴스 — 낸 명령의 접수증을 쥔다).
final Provider<OperatorCommandApi> operatorCommandApiProvider =
    Provider<OperatorCommandApi>(
      (Ref ref) => OperatorCommandApi(ref.watch(operatorRuntimeProvider)),
    );

/// 🆕 R171 — 보유(H6-1 · 한 인스턴스 · 링크 = 셸이 실제로 쓰는 레지스트리에 본문이 있는 화면만).
final Provider<OperatorHoldingsRepository> operatorHoldingsProvider =
    Provider<OperatorHoldingsRepository>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorHoldingsRepository(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
      );
    });

/// 🆕 E11q-q4a — 매매일지 읽기(J-1 · J-2 · J-3R · 회차 범위 · 한 인스턴스 · 링크 = 레지스트리에 본문이 있을 때만).
final Provider<OperatorJournalRepository> operatorJournalProvider =
    Provider<OperatorJournalRepository>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorJournalRepository(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
      );
    });

/// 🆕 R172 — 리밸런싱(다음 회차 · H6-3 하단 · 한 인스턴스 · 미리보기 링크 = 레지스트리에 본문이 있을 때만).
final Provider<OperatorRebalanceRepository> operatorRebalanceProvider =
    Provider<OperatorRebalanceRepository>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorRebalanceRepository(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
      );
    });

/// 🆕 E11q-q5a(R220) — M7 성과 창구(S7-7 연간 리뷰 · A 행 탐색 링크 = 레지스트리에 본문이 있을 때만).
final Provider<OperatorPerformanceRepository> operatorPerformanceProvider =
    Provider<OperatorPerformanceRepository>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorPerformanceRepository(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
      );
    });

/// 🆕 E11q-q5a(R220) — S7-10 이행 갭(운영 방식 = 화면 상태).
final Provider<OperatorExecutionGapRepository> operatorExecutionGapProvider =
    Provider<OperatorExecutionGapRepository>(
      (Ref ref) =>
          OperatorExecutionGapRepository(ref.watch(operatorRuntimeProvider)),
    );

/// 🆕 R180 — M5-2 재개판 초안(이 앱 실행 동안 · 문항 제출과 게이트 읽기가 같이 쓴다).
final Provider<OperatorKillResumeDraft> operatorKillResumeDraftProvider =
    Provider<OperatorKillResumeDraft>((Ref ref) {
      final OperatorKillResumeDraft d = OperatorKillResumeDraft();
      ref.onDispose(d.dispose);
      return d;
    });

/// 🆕 R178 — M5-1 킬스위치 읽기(한 인스턴스 · 게이트 링크 = 레지스트리에 본문이 있을 때만).
final Provider<OperatorKillSwitchGateRepository>
operatorKillSwitchGateProvider = Provider<OperatorKillSwitchGateRepository>((
  Ref ref,
) {
  final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
  return OperatorKillSwitchGateRepository(
    ref.watch(operatorRuntimeProvider),
    hasBody: bodies.byPattern.containsKey,
    // 🆕 R180 — M5-2 게이트 = 문항 제출과 같은 초안.
    draft: ref.watch(operatorKillResumeDraftProvider),
  );
});

/// 🆕 R185 — M5-5 차단 보드 읽기(한 인스턴스 · 행 링크 · 재개 결정 링크 = 레지스트리에 본문이 있을 때만).
final Provider<OperatorBlockBoardRepository> operatorBlockBoardProvider =
    Provider<OperatorBlockBoardRepository>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorBlockBoardRepository(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
        // 🆕 R189 — 폰 = 안전 동작 창구 늘 주입(`safetyActionsProvider`) · 잠김(미결 169) = 아직 0 → RECON 해제 폼을 낸다.
        reconClearable: true,
      );
    });

/// 🆕 R186 — X2 재개 리포트 · 게이트 읽기(한 인스턴스 · 리포트 링크 = 레지스트리에 본문이 있을 때만 · 🆕 R195 계절 3택 = 켜짐).
final Provider<OperatorResumeGateRepository> operatorResumeGateProvider =
    Provider<OperatorResumeGateRepository>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorResumeGateRepository(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
      );
    });

/// 🆕 R188 — M5-9 규칙 변경 게이트 읽기(한 인스턴스 · 쓰기 = 안전 동작 인스턴스 — 요청 · 승인 · 취소).
final Provider<OperatorRuleChangeGateRepository>
operatorRuleChangeGateProvider = Provider<OperatorRuleChangeGateRepository>(
  (Ref ref) =>
      OperatorRuleChangeGateRepository(ref.watch(operatorRuntimeProvider)),
);

/// 🆕 R191 — M5-11 위저드 원천 · 동작(한 인스턴스 — 읽기 · 설정 동작 인스턴스가 같은 것을 쓴다).
final Provider<OperatorHandover> operatorHandoverProvider =
    Provider<OperatorHandover>((Ref ref) {
      final OperatorHandover h = OperatorHandover(
        ref.watch(operatorRuntimeProvider),
      );
      ref.onDispose(h.close);
      return h;
    });

/// 🆕 R191 — M5-11 위저드 읽기(`m5HandoverWizard` · `handoverStatus` 같은 흐름 · 쓰기 창구 없음 = 행 동작 0).
final Provider<OperatorHandoverRepository> operatorHandoverRepositoryProvider =
    Provider<OperatorHandoverRepository>(
      (Ref ref) => OperatorHandoverRepository(
        ref.watch(operatorRuntimeProvider),
        ref.watch(operatorHandoverProvider),
        canAct: ref.watch(operatorSettingsActionsProvider) != null,
      ),
    );

/// 🆕 R173 — S7-6c «지금 기준 초안 보기»(엔진 What-if · 원장 상태 어댑터 · 리밸런싱 미리보기만).
final Provider<OperatorWhatIfApi> operatorWhatIfApiProvider =
    Provider<OperatorWhatIfApi>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorWhatIfApi(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
      );
    });

/// 🆕 R133 — 홈 오늘 요약 · 운영 리듬(한 인스턴스).
final Provider<OperatorOpsSummaryRepository> operatorOpsSummaryProvider =
    Provider<OperatorOpsSummaryRepository>(
      (Ref ref) =>
          OperatorOpsSummaryRepository(ref.watch(operatorRuntimeProvider)),
    );

/// 🆕 R113 — 안전 상태(셸 · 일지 · 분석 = 한 인스턴스).
final Provider<OperatorSafetyRepository> operatorSafetyProvider =
    Provider<OperatorSafetyRepository>(
      (Ref ref) => OperatorSafetyRepository(ref.watch(operatorRuntimeProvider)),
    );

/// 🆕 R118 — 설정 · 온보딩 «동작»(금고 · 검증 HTTP 가 없으면 null = 컨트롤 부재 — 시험 · 화면 없는 조립).
final Provider<SettingsActions?> operatorSettingsActionsProvider =
    Provider<SettingsActions?>((Ref ref) {
      final OperatorRuntime rt = ref.watch(operatorRuntimeProvider);
      final vault = rt.vault;
      final net = rt.kisHttp;
      if (vault == null || net == null) return null;
      return OperatorSettingsActions(
        secrets: rt.secrets,
        vault: vault,
        clientOf: (KisCredentials c) =>
            KisRestClient(net, c, environment: c.environment),
        clock: rt.clock,
        sim: rt.files.sim,
        // 🆕 R160 — S10 무결성 자가진단 = 지금 화면이 읽는 원장.
        ledger: () => rt.view.value?.db,
        // 🆕 R167 — S10 골든벡터 셀프테스트(같은 원장에 기록).
        golden: rt.golden,
        // 🆕 R174 — S13 월 납입 쓰기(지금 화면 원장 · 신뢰 시각 · 이 기기 id · 없으면 null).
        contribution: () {
          final OperatorView? v = rt.view.value;
          final String? id = rt.deviceId;
          if (v == null || id == null) return null;
          return ContributionSettingSource(
            v.db,
            trusted: rt.trusted,
            clock: rt.clock,
            kr: rt.calendars.kr,
            deviceId: id,
          );
        },
        // 🆕 R191 — M5-11 위저드 동작 4(S5 고름 · 세션 시작 · 취소 · 확정 관문).
        handover: ref.watch(operatorHandoverProvider),
        // 🆕 R201 — S09 «지금 백업»(X1 `take` · 기기 안만).
        backup: ref.watch(operatorBackupProvider),
        // 🆕 E11k-c(R206) — o_07 ② 연결 확인 · 저장 뒤 신뢰 시각 바로 잼.
        supabaseTime: rt.supabaseTime,
        refreshTrusted: rt.refreshTrusted,
        // 🆕 E11k-d2(R216) — o_07 ③ 로그인.
        supabaseAuth: rt.supabaseAuth,
      );
    });

/// 🆕 R157 — 안전 동작(한 인스턴스 — 지금 = 서약).
final Provider<OperatorSafetyActions> operatorSafetyActionsProvider =
    Provider<OperatorSafetyActions>(
      (Ref ref) => OperatorSafetyActions(
        ref.watch(operatorRuntimeProvider),
        draft: ref.watch(operatorKillResumeDraftProvider),
      ),
    );

/// 🆕 R115 — 온보딩 슬롯 빌더(M4-11 ①) — 엔진에 있는 키 세트의 시크릿 칸 · 🆕 R157 O-04 ② 서약(M5-8) · 🆕 R159 ③ 생체 서명 ·
/// 🆕 R167 ④ 골든벡터 셀프테스트 · 🆕 R206 o_07 ② Supabase 연결 칸 · 🆕 R216 ③ 로그인 칸 ·
/// 나머지 = 자리 부재(크기 0 · 키 `m4-slot-absent`).
ShellSlotBuilder operatorSlotBuilder(OperatorRuntime rt) => (String slotId) {
  if (slotId == OnboardingSlotIds.pledgeWrite) return const PledgePanel();
  // 🆕 R206 — o_07 ② 주소 · 공개 키 붙여넣기(KIS 칸과 같은 넘김 · 클립보드 정리 · 캡처 막기).
  if (slotId == OnboardingSlotIds.supabaseConnect) {
    return SupabaseConnectField(
      handoff: rt.secrets,
      janitor: rt.clipboard,
      secure: rt.secure,
    );
  }
  // 🆕 R216 — o_07 ③ 이메일 · 비밀번호 붙여넣기(② 통과 뒤 같은 단계 · 엔진 상세 VM 이 슬롯을 바꾼다).
  if (slotId == OnboardingSlotIds.supabaseLogin) {
    return SupabaseLoginPanel(
      handoff: rt.secrets,
      janitor: rt.clipboard,
      secure: rt.secure,
    );
  }
  // 🆕 R167 — O-04 ④ 골든벡터 셀프테스트(조립 앱 칸 · S10 과 같은 실행기 · 기록 = sim 파일).
  final OperatorGolden? golden = rt.golden;
  if (slotId == OnboardingSlotIds.selftestRun && golden != null) {
    return GoldenSelfTestField(run: () => golden.runHeadline(rt.files.sim));
  }
  // 🆕 R159 — O-04 ③ 생체 서명(플랫폼 몫 · 조립 앱 칸).
  if (slotId == OnboardingSlotIds.biometricSign) {
    return BiometricSignField(sign: OperatorBiometricSign(rt).sign);
  }
  final KisKeySet? set = kisKeySetOfSlot(slotId);
  if (set == null) return const SizedBox.shrink(key: Key('m4-slot-absent'));
  return KisKeySetField(
    set: set,
    handoff: rt.secrets,
    janitor: rt.clipboard,
    secure: rt.secure,
  );
};

/// 🆕 R182 — M8 운영 슬롯 빌더(01 §26 K19 · §34 K152) — 셸 킬스위치 자리(폰 홈 앱바 · 링크 화면 앱바) = `ui_safety`
/// `KillSwitchSlot`(꺼짐 = 발동 버튼 · 켜짐 = 상태 칩 → M5-1) · 🔴 셸은 자리만(확인 대화 · 핸들러 감싸기 0 — 04 §3-2) ·
/// 긴급정지 카드 인쇄(`emergencyCardPrint`) = 이 폰에 인쇄 원천 없음 → 자리 부재(크기 0 · 키 `m8-slot-absent`).
Widget operatorOpsSlot(String slotId) {
  if (slotId == OpsSlotIds.killSwitch) return const KillSwitchSlot();
  return const SizedBox.shrink(key: Key('m8-slot-absent'));
}

/// 🆕 R125 — 온보딩 읽기 모델(한 인스턴스 — 실측 캐시를 같이 쓴다).
final Provider<OperatorOnboardingRepository> operatorOnboardingProvider =
    Provider<OperatorOnboardingRepository>(
      (Ref ref) =>
          OperatorOnboardingRepository(ref.watch(operatorRuntimeProvider)),
    );

/// 🆕 R125 — 첫 실행 판정(미결 158) — 온보딩이 끝났나(`committed_at`).
final StreamProvider<bool> operatorOnboardingDoneProvider =
    StreamProvider<bool>(
      (Ref ref) => watchOnboardingDone(ref.watch(operatorRuntimeProvider)),
    );

/// 🆕 R125 — 셸 내비게이터 키.
final Provider<GlobalKey<NavigatorState>> operatorShellNavigatorKeyProvider =
    Provider<GlobalKey<NavigatorState>>(
      (Ref ref) => GlobalKey<NavigatorState>(debugLabel: 'shell'),
    );

/// 🆕 R125 — 온보딩 내비게이터 키.
final Provider<GlobalKey<NavigatorState>>
operatorOnboardingNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (Ref ref) => GlobalKey<NavigatorState>(debugLabel: 'onboarding'),
);

Widget _alertCenter(Map<String, String> _) => const AlertCenter();

Widget _onboardingStart(Map<String, String> _) => const OnboardingStart();

Widget _onboardingMode(Map<String, String> _) => const OnboardingModePick();

Widget _onboardingSteps(Map<String, String> _) => const OnboardingStepList();

Widget _onboardingFinish(Map<String, String> _) => const OnboardingFinish();

Widget _settingsCredentials(Map<String, String> _) => const Credentials();

Widget _settingsHome(Map<String, String> _) => const SettingsHome();

Widget _settingsConnections(Map<String, String> _) => const Connections();

Widget _settingsDevices(Map<String, String> _) => const Devices();

Widget _settingsAccounts(Map<String, String> _) => const Accounts();

Widget _simOpeningCash(Map<String, String> _) => const SimOpeningCash();

Widget _settingsDiagnostics(Map<String, String> _) => const Diagnostics();

Widget _settingsBackup(Map<String, String> _) => const BackupRestore();

Widget _settingsAnnualReview(Map<String, String> _) =>
    const AnnualReviewEntry();

Widget _holdingsOverview(Map<String, String> _) => const HoldingsOverview();

Widget _holdingDetail(Map<String, String> p) =>
    HoldingDetail(holdingId: p['holdingId'] ?? '');

Widget _holdingsAllocation(Map<String, String> _) => const HoldingsAllocation();

Widget _planDeposit(Map<String, String> _) => const DepositPlannerScreen();

Widget _journalTimeline(Map<String, String> _) => const JournalTimeline();

Widget _journalDecision(Map<String, String> p) =>
    JournalDecisionDetail(decisionId: p['decisionId'] ?? '');

Widget _journalRead(Map<String, String> p) =>
    JournalReadView(decisionId: p['decisionId'] ?? '');

Widget _journalUnknownBoard(Map<String, String> _) =>
    const JournalUnknownBoard();

Widget _journalRebalance(Map<String, String> p) {
  final String id = p['rebalanceEventId'] ?? '';
  return JournalTimeline(key: ValueKey<String>(id), rebalanceEventId: id);
}

Widget _killSwitch(Map<String, String> _) => const KillSwitchScreen();

Widget _releaseGate(Map<String, String> _) => const KillResumeGateScreen();

Widget _blockBoard(Map<String, String> _) => const BlockBoardScreen();

Widget _resumeReport(Map<String, String> _) => const ResumeReportScreen();

Widget _resumeGate(Map<String, String> _) => const ResumeGateScreen();

Widget _ruleChangeGate(Map<String, String> _) => const RuleChangeGateScreen();

Widget _handoverWizard(Map<String, String> _) => const HandoverWizardScreen();

Widget _settingsContribution(Map<String, String> _) =>
    const MonthlyContribution();

Widget _rebalancePreview(Map<String, String> _) =>
    const RebalancePreviewScreen();

Widget _rebalanceHistory(Map<String, String> _) =>
    const RebalanceTimelineScreen();

Widget _rebalanceEvent(Map<String, String> p) {
  final String id = p['rebalanceEventId'] ?? '';
  return RebalanceEventScreen(key: ValueKey<String>(id), rebalanceEventId: id);
}

Widget _reportAnnual(Map<String, String> _) => const AnnualReviewScreen();

Widget _executionGap(Map<String, String> _) => const ExecutionGapScreen();

/// 두 라우트 · 한 위젯(계약 v1.6 — 그 달 = 받은 달 그대로).
Widget _executionGapMonth(Map<String, String> p) {
  final String m = p['yyyyMm'] ?? '';
  return ExecutionGapScreen(key: ValueKey<String>(m), yyyyMm: m);
}

/// 🆕 R129 — 설정 읽기 모델(첫 칸 = S02 키 목록) · 🆕 R134 설정 홈 링크 = 셸이 실제로 쓰는 레지스트리에 본문이 있는 화면만.
final Provider<OperatorSettingsRepository> operatorSettingsRepositoryProvider =
    Provider<OperatorSettingsRepository>((Ref ref) {
      final ShellRouteBodies bodies = ref.watch(shellRouteBodiesProvider);
      return OperatorSettingsRepository(
        ref.watch(operatorRuntimeProvider),
        hasBody: bodies.byPattern.containsKey,
      );
    });

Widget _onboardingStep(Map<String, String> p) =>
    OnboardingStepDetail(stepId: p['stepId'] ?? '');

Widget _alertDetail(Map<String, String> p) =>
    AlertDetail(alertId: p['alertId'] ?? '');

Widget _watchdog(Map<String, String> _) => const WatchdogBoard();

Widget _opsRhythm(Map<String, String> _) => const OpsRhythm();

Widget _deviceRisk(Map<String, String> _) => const DeviceRiskBoard();

Widget _home(BuildContext _) => const OpsHome();

Widget _ledgerDiffs(Map<String, String> _) => const LedgerDiffs();

Widget _ledgerRepairs(Map<String, String> _) => const LedgerRepairs();

/// 🔴 본문 레지스트리 — 실물이 있는 화면만(R104 d1).
const ShellRouteBodies
kOperatorRouteBodies = ShellRouteBodies(<String, ShellBodyBuilder>{
  AppRoutes.alertsInbox: _alertCenter,
  AppRoutes.alertDetail: _alertDetail,
  // 🆕 E11p3d-2(R109) — 감시 보드(로컬 판정 + 바깥 대조).
  AppRoutes.opsWatchdog: _watchdog,
  // 🆕 E11p3d-3a(R111) — 원장 대조 · 수리 기록(실물 = `SqliteLedgerRepository` · 같은 원장).
  AppRoutes.ledgerDiffs: _ledgerDiffs,
  AppRoutes.ledgerRepairs: _ledgerRepairs,
  // 🆕 E11p4b(R125) — 온보딩 넷(첫 화면 · 운영 방식 · 단계 목록 · 단계 상세 — 키 칸 = 슬롯 빌더 · 캡처 막기 = 칸이 스스로).
  AppRoutes.onboardingStart: _onboardingStart,
  AppRoutes.onboardingModePick: _onboardingMode,
  AppRoutes.onboardingSteps: _onboardingSteps,
  AppRoutes.onboardingStep: _onboardingStep,
  // 🆕 E11p4c(R127) — 마무리(O-04).
  AppRoutes.onboardingFinish: _onboardingFinish,
  // 🆕 E11p4g(R156) — M5-14 가상 초기금(O-04 ⑥ 자동 매매 갈래 링크 목적지 · 제출 = `OperatorCommandApi` · R155).
  AppRoutes.m5SimOpeningCash: _simOpeningCash,
  // 🆕 E11p3d-5d(R129) — M9 S02 증권사 키(캡처 막기 = `kSecureRoutePatterns` · 키 칸 = 설정 슬롯 빌더).
  AppRoutes.settingsCredentials: _settingsCredentials,
  // 🆕 E11p3d-5e(R134) — M9 S01 설정 홈(더보기 탭 본문).
  AppRoutes.settingsHome: _settingsHome,
  // 🆕 E11p3d-5f(R140) — M9 S07 연결.
  AppRoutes.settingsConnections: _settingsConnections,
  // 🆕 E11p3d-5h(R146) — M9 S06 기기 · 접근.
  AppRoutes.settingsDevices: _settingsDevices,
  // 🆕 E11p3d-5i(R151) — M9 S03 계좌 · 매핑.
  AppRoutes.settingsAccounts: _settingsAccounts,
  // 🆕 E11p4k(R160) — M9 S10 진단(골든 = 실행기 전 판정 보류 · 무결성 = 정본 자가 대조).
  AppRoutes.settingsDiagnostics: _settingsDiagnostics,
  // 🆕 E11q-c2(R201) — M9 S09 백업·복원(«지금 백업» = X1 스냅숏 `take` · 기기 안만 · 바깥 올리기 = D9 미정 ·
  //    아카이브 IN_SYNC 전 = 엔진이 버튼을 비운다 K133 · 복원 = X1 마법사 몫 — 링크는 본문이 생기면).
  AppRoutes.settingsBackup: _settingsBackup,
  // 🆕 R168 — M9 S12 12월 연간 리뷰 목차(S01 카드 = 신뢰 시각 12월 · 목차 = 등록된 M7 화면만).
  AppRoutes.settingsAnnualReview: _settingsAnnualReview,
  // 🆕 E11q1(R171) — M6 H6-1 보유 현황(원장 · 모의 = 가상 현금 · 상세 · 배분 링크 = 등록되면).
  AppRoutes.holdingsOverview: _holdingsOverview,
  // 🆕 E11q1b(R172) — H6-2 종목 상세 · H6-3 슬리브 배분(= 홈 블록 4 탭 목적지 · 하단 다음 리밸런싱).
  AppRoutes.holdingsDetail: _holdingDetail,
  AppRoutes.holdingsAllocation: _holdingsAllocation,
  // 🆕 E11q2(R173) — M7 S7-6c 다음 리밸런싱 · 지금 기준 초안 · S7-6a 회차 목록 · S7-6b 회차 상세(원장 `rebalance_event`).
  AppRoutes.rebalancePreview: _rebalancePreview,
  AppRoutes.rebalanceHistory: _rebalanceHistory,
  AppRoutes.rebalanceEvent: _rebalanceEvent,
  // 🆕 E11q-q5a(R220) — M7 S7-7 연간 리뷰(S12 목차 «한 해의 결과» 목적지) · S7-10 이행 갭(S12 목차 · 월간 리포트 ⑧ 그 달).
  AppRoutes.reportAnnual: _reportAnnual,
  AppRoutes.ledgerExecutionGap: _executionGap,
  AppRoutes.ledgerExecutionGapMonth: _executionGapMonth,
  // 🆕 E11q-q4a — M6 매매일지 읽기 넷(J-1 = «일지» 탭 본문 · J-2 = 일지 행 · H6-2 «매수 결정 보기» 목적지 ·
  //    J-3R = J-2 «저널 보기» 목적지 · J-1 회차 조건 = S7-6b «이 회차의 주문 n건» 목적지).
  AppRoutes.journalTimeline: _journalTimeline,
  AppRoutes.journalDecision: _journalDecision,
  AppRoutes.journalRead: _journalRead,
  AppRoutes.journalRebalance: _journalRebalance,
  // 🆕 E11q-q4b — J-5 미해소 보드(J-1 «확인 중 n건» 배지 · `ORDER_OUTCOME_UNKNOWN` 알림 목적지 · 읽기만).
  AppRoutes.journalUnknownBoard: _journalUnknownBoard,
  // 🆕 E11q3(R174) — M7 S7-4 납입 플래너(미리보기 = 엔진 What-if · 등록 = 신뢰 시각 관문) · M9 S13 월 납입 설정.
  AppRoutes.planDeposit: _planDeposit,
  // 🆕 E11q-b1a(R178) — M5-1 킬스위치(발동 버튼 · 취소 보고 · 발동 뒤 기록 폼 · 체험 ⑤).
  AppRoutes.m5KillSwitch: _killSwitch,
  // 🆕 E11q-b1b(R180) — M5-2 재개 게이트(7문항 순차 · 서약 재생 · 7번 = 해제) → M5-1 게이트 링크가 저절로 열린다.
  AppRoutes.m5ReleaseGate: _releaseGate,
  // 🆕 E11q-b3(R185) — M5-5 차단 보드(홈 블록 1 · 3 · 알림 3종 · 대사 불일치 목적지 · 킬스위치 둘째 길 · 읽기만).
  AppRoutes.m5BlockBoard: _blockBoard,
  // 🆕 E11q-b2a(R186) — X2 재개 리포트 · 게이트(재개 미완 배너 · 차단 보드 재개 미완 행 · 알림 RESUME_COMPLETED 목적지 ·
  //    🆕 R195 계절 3택 쓰기 = 안전 동작 `run(seasonalWindowChoice)`).
  AppRoutes.x2ResumeReport: _resumeReport,
  AppRoutes.x2ResumeGate: _resumeGate,
  // 🆕 E11q-c0(R188) — M5-9 규칙 변경 게이트 «첫 승인 최소판»(SAF-405 첫 승인 요청 · 냉각 · 승인 · 취소).
  AppRoutes.m5RuleChangeGate: _ruleChangeGate,
  // 🆕 E11q-c1(R191) — M5-11 simToAuto 위저드 · `handoverStatus` = 같은 본문(K173 · 알림 냉각 · 확정 목적지) ·
  //    M5-10 `m5HandoverGate` = 범위 밖 빈 자리(K174).
  AppRoutes.m5HandoverWizard: _handoverWizard,
  AppRoutes.handoverStatus: _handoverWizard,
  AppRoutes.settingsContribution: _settingsContribution,
  // 🆕 E11p3d-2b(R133) — H-02 운영 리듬(홈 블록 8 탭).
  AppRoutes.opsRhythm: _opsRhythm,
  // 🆕 E11p3d-2c(R136) — H-03 물리 리스크 점검(Android 전용 · 진입 = 딥링크 · 홈 블록 9 = 화면 레인 다음 홈 카드).
  AppRoutes.opsDeviceRisk: _deviceRisk,
}, home: _home);

/// 🔴 operator 셸 주입 — 실물 있는 칸.
List<Override> operatorShellOverrides(OperatorRuntime runtime) => <Override>[
  operatorRuntimeProvider.overrideWithValue(runtime),
  shellPlatformProvider.overrideWithValue(ShellPlatform.androidOperator),
  shellClockProvider.overrideWithValue(runtime.clock),
  shellConfigRepositoryProvider.overrideWithValue(
    OperatorConfigRepository(
      runtime.view,
      clock: runtime.clock,
      kr: runtime.calendars.kr,
    ),
  ),
  shellAlertRepositoryProvider.overrideWith(
    (Ref ref) => SqliteAlertRepository(
      ref.watch(operatorDbProvider),
      clock: runtime.clock,
    ) as AlertRepository,
  ),
  // 🆕 R147 — 확인(ack) = 명령 API(한 인스턴스) · 기기 id 없음 = null = 버튼 부재(셸 규약).
  shellAlertCommandApiProvider.overrideWith(
    (Ref ref) => runtime.deviceId == null
        ? null
        : ref.watch(operatorCommandApiProvider) as CommandApi,
  ),
  // 🆕 R157 — M5-8 서약(읽기 = sim 원장 · 쓰기 = 안전 동작 한 인스턴스 · 폰 = 늘 주입).
  safetyPledgeRepositoryProvider.overrideWith(
    (Ref ref) => OperatorPledgeRepository(ref.watch(operatorRuntimeProvider)),
  ),
  safetyActionsProvider.overrideWith(
    (Ref ref) => ref.watch(operatorSafetyActionsProvider),
  ),
  // 🆕 R178 — M5-1 킬스위치 읽기 · 발동 · 기록 = 같은 명령 API 인스턴스(기기 id 없음 = null = 버튼 · 제출 부재) · 링크 = 셸.
  safetyKillSwitchGateRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorKillSwitchGateProvider),
  ),
  safetyKillCommandApiProvider.overrideWith(
    (Ref ref) => runtime.deviceId == null
        ? null
        : ref.watch(operatorCommandApiProvider) as CommandApi,
  ),
  safetyLinkOpenerProvider.overrideWith(
    (Ref ref) => ref.watch(shellLinkOpenerProvider),
  ),
  // 🆕 R185 — M5-5 차단 보드 읽기(링크 = 위 셸 링크 열기 그대로).
  safetyBlockBoardRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorBlockBoardProvider),
  ),
  // 🆕 R186 — X2 재개 리포트 · 게이트 읽기(링크 = 위 셸 링크 열기 · 계절 3택 쓰기 = 위 안전 동작 인스턴스 — R195).
  safetyResumeGateRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorResumeGateProvider),
  ),
  // 🆕 R188 — M5-9 규칙 변경 게이트 읽기(요청 · 승인 · 취소 = 위 안전 동작 인스턴스).
  safetyRuleChangeGateRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorRuleChangeGateProvider),
  ),
  // 🆕 R191 — M5-11 위저드 읽기 · 동작(= 설정 동작 인스턴스 — 없으면 null = 버튼 부재 · 링크 = 위 셸 링크 열기).
  safetyHandoverRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorHandoverRepositoryProvider),
  ),
  safetySettingsActionsProvider.overrideWith(
    (Ref ref) => ref.watch(operatorSettingsActionsProvider),
  ),
  // 🆕 R156 — M5-14 가상 초기금 제출 = 같은 명령 API 인스턴스 · 기기 id 없음 = null = 제출 버튼 부재.
  safetySimOpeningCommandApiProvider.overrideWith(
    (Ref ref) => runtime.deviceId == null
        ? null
        : ref.watch(operatorCommandApiProvider) as CommandApi,
  ),
  // 🆕 R109 — 운영 상태(감시 보드 · 진단 = 실물 · 나머지 = 원천 없음).
  shellOpsStatusRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorOpsStatusProvider),
  ),
  // 🆕 R182 — M8 운영 슬롯 빌더(셸 킬스위치 자리 = `ui_safety` 발동 버튼 · 켜짐 칩 — 위 R178 주입을 그대로 쓴다).
  shellOpsSlotBuilderProvider.overrideWithValue(operatorOpsSlot),
  // 🆕 R115 — 온보딩 슬롯 빌더(본문 = 온보딩 원천이 서는 조각에서 등록 · 빌더는 미리).
  shellOnboardingSlotBuilderProvider.overrideWithValue(
    operatorSlotBuilder(runtime),
  ),
  // 🆕 R125 — 지금 서 있는 내비게이터의 키(온보딩 중 = 온보딩 · 뒤 = 셸) — 🔴 둘이 키를 나눠 쓰면 끝날 때
  //    온보딩 쪽 내비게이터(쌓인 화면째)가 셸 자리로 옮겨 붙는다(GlobalKey 재부착). 링크 열기 · 딥링크 중계 = 이 키를 따른다.
  shellNavigatorKeyProvider.overrideWith(
    (Ref ref) => ref.watch(operatorOnboardingDoneProvider).valueOrNull == false
        ? ref.watch(operatorOnboardingNavigatorKeyProvider)
        : ref.watch(operatorShellNavigatorKeyProvider),
  ),
  // 🆕 R125 — 온보딩 읽기 모델.
  shellOnboardingRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorOnboardingProvider),
  ),
  // 🆕 R118 — 설정 · 온보딩 «동작» = 한 인스턴스(검증 진행 중 겹침을 한 곳에서 막는다).
  shellOnboardingActionsProvider.overrideWith(
    (Ref ref) => ref.watch(operatorSettingsActionsProvider),
  ),
  settingsActionsProvider.overrideWith(
    (Ref ref) => ref.watch(operatorSettingsActionsProvider),
  ),
  // 🆕 R129 — 설정 읽기 모델 · 🔴 설정 슬롯 빌더 = 온보딩과 같은 빌더(M4-12 ⑦ 주입 의무 · `SecretField` 한 벌 — 05 §4-1).
  settingsRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorSettingsRepositoryProvider),
  ),
  settingsSlotBuilderProvider.overrideWithValue(operatorSlotBuilder(runtime)),
  // 🆕 R133 — H-01 오늘 요약 · H-02 리듬(실물) · 홈의 나머지 셋 = 원천 없음(지어내지 않는다).
  shellOpsSummaryRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorOpsSummaryProvider),
  ),
  shellAdviceRepositoryProvider.overrideWithValue(
    const OperatorAdviceRepository(),
  ),
  // 🆕 R171 — 보유(H6-1 = 원장 · 셸 홈 블록 4 · 일지 패키지 = 한 인스턴스).
  shellHoldingsRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorHoldingsProvider),
  ),
  shellLedgerTrustRepositoryProvider.overrideWithValue(
    const OperatorLedgerTrustRepository(),
  ),
  // 🆕 R113 — 안전 상태 = 셸(H-01) · 일지 · 분석 한 인스턴스.
  shellSafetyRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorSafetyProvider),
  ),
  // 🆕 R107 — 시크릿 · QR · 복구 라우트 = 캡처 막기(본문이 서 있는 동안).
  shellRouteBodiesProvider.overrideWithValue(
    secureRouteBodies(kOperatorRouteBodies, runtime.secure),
  ),
  // 🆕 R107 — https 링크 = 브라우저 · 앱 링크 = 셸(셸 기본 열기와 같은 내비게이터 · 홈 복귀).
  shellLinkOpenerProvider.overrideWith(
    (Ref ref) => OperatorLinkOpener(
      inner: ShellLinkOpener(
        navigatorKey: ref.watch(shellNavigatorKeyProvider),
        onHome: () => ref.read(shellTabIndexProvider.notifier).state = 0,
      ),
      external: runtime.openExternal,
    ),
  ),
  // 🆕 R111 — 일지 패키지 주입: 원장 읽기(화면이 고른 원장) · 시계 · 링크 열기 = 셸과 같은 것(https = 바깥).
  journalLedgerRepositoryProvider.overrideWith(
    (Ref ref) => SqliteLedgerRepository(
      ref.watch(operatorDbProvider),
      clock: runtime.clock,
    ) as LedgerRepository,
  ),
  journalClockProvider.overrideWithValue(runtime.clock),
  // 🆕 E11q-q4a — 일지 읽기(J-1 · J-2 · J-3R · 회차 범위) · 기간 프리셋 · 슬리브 = 셸 설정 원천 한 인스턴스.
  journalTimelineRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorJournalProvider),
  ),
  journalConfigRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(shellConfigRepositoryProvider),
  ),
  journalHoldingsRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorHoldingsProvider),
  ),
  // 🆕 R172 — H6-3 하단 다음 리밸런싱(나머지 = 원천 없음 · q2).
  journalRebalanceRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorRebalanceProvider),
  ),
  journalLinkOpenerProvider.overrideWith(
    (Ref ref) => ref.watch(shellLinkOpenerProvider),
  ),
  // 🆕 R113 — 일지 화면의 차단 배너(원장 대조 · 수리 기록이 이미 읽는다).
  journalSafetyRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorSafetyProvider),
  ),
  // 🆕 R113 — 분석 · 설정 패키지의 실물 칸(본문은 원천이 서는 조각에서 등록 · 칸은 미리).
  safetyRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorSafetyProvider),
  ),
  analyticsClockProvider.overrideWithValue(runtime.clock),
  analyticsLinkOpenerProvider.overrideWith(
    (Ref ref) => ref.watch(shellLinkOpenerProvider),
  ),
  // 🆕 R173 — M7 리밸런싱 칸(일지 칸과 한 인스턴스) · 초안 창구.
  rebalanceRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorRebalanceProvider),
  ),
  // 🆕 E11q-q5a(R220) — M7 성과 창구(연간 리뷰만 원천 · 나머지 = «원천 없음») · 이행 갭.
  performanceRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorPerformanceProvider),
  ),
  executionGapRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorExecutionGapProvider),
  ),
  analyticsWhatIfApiProvider.overrideWith(
    (Ref ref) => ref.watch(operatorWhatIfApiProvider),
  ),
  // 🆕 R174 — S7-4 플래너 칸 = 같은 What-if · 셸 설정 원천 · 명령 API 인스턴스.
  plannerWhatIfApiProvider.overrideWith(
    (Ref ref) => ref.watch(operatorWhatIfApiProvider),
  ),
  plannerConfigRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(shellConfigRepositoryProvider),
  ),
  plannerCommandApiProvider.overrideWith(
    (Ref ref) => ref.watch(operatorCommandApiProvider),
  ),
  settingsClockProvider.overrideWithValue(runtime.clock),
  settingsLinkOpenerProvider.overrideWith(
    (Ref ref) => ref.watch(shellLinkOpenerProvider),
  ),
  settingsOpsStatusRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorOpsStatusProvider),
  ),
];
