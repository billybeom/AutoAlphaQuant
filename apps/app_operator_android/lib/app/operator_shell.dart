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
// 🆕 E11p3d-2c(R136) — H-03 물리 리스크 점검 본문(기기 측정 = `OperatorRuntime.deviceProbe` · 판정 = 엔진) — Android 전용 = 이 레지스트리.
// 🆕 E11p3d-5e(R134) — 더보기 본문 = M9 S01 설정 홈(`OperatorSettingsRepository.watchHome` · 링크 = 레지스트리에 본문이 있는 화면만).
// 🔵 일지 · 보유 · 장애 배너 · 핸드북은 원천(읽기 모델 · 명령)이 서는 조각에서 더한다(R104 나눔).
//    🔴 M4-12 ① «장애 · 핸드북 override 의무»는 아직 못 지킨다 — 실물 저장소가 없다(R104 남김 · d6).

import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisKeySet, KisRestClient;
import 'package:data_sync/data_sync.dart'
    show SqliteAlertRepository, SqliteLedgerRepository;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AlertRepository,
        AppRoutes,
        CommandApi,
        LedgerRepository,
        SettingsActions;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:ui_analytics/ui_analytics.dart'
    show
        analyticsClockProvider,
        analyticsLinkOpenerProvider,
        safetyRepositoryProvider;
import 'package:ui_journal/ui_journal.dart'
    show
        LedgerDiffs,
        LedgerRepairs,
        journalClockProvider,
        journalLedgerRepositoryProvider,
        journalLinkOpenerProvider,
        journalSafetyRepositoryProvider;
import 'package:ui_settings/ui_settings.dart'
    show
        Credentials,
        SettingsHome,
        settingsActionsProvider,
        settingsClockProvider,
        settingsLinkOpenerProvider,
        settingsOpsStatusRepositoryProvider,
        settingsRepositoryProvider,
        settingsSlotBuilderProvider;
import 'package:ui_shell/ui_shell.dart';

import '../secret/kis_key_set_field.dart';
import '../secret/secret_handoff.dart';
import 'operator_onboarding.dart';
import 'operator_ops_status.dart';
import 'operator_ops_summary.dart';
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

/// 🆕 R113 — 운영 상태(셸 · 설정 = 한 인스턴스 — 바깥 목록 캐시를 같이 쓴다).
final Provider<OperatorOpsStatusRepository> operatorOpsStatusProvider =
    Provider<OperatorOpsStatusRepository>(
      (Ref ref) =>
          OperatorOpsStatusRepository(ref.watch(operatorRuntimeProvider)),
    );

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
      );
    });

/// 🆕 R115 — 온보딩 슬롯 빌더(M4-11 ①) — 엔진에 있는 키 세트의 시크릿 칸만 · 나머지 = 자리 부재(크기 0 · 키 `m4-slot-absent`).
ShellSlotBuilder operatorSlotBuilder(OperatorRuntime rt) => (String slotId) {
  final KisKeySet? set = kisKeySetOfSlot(slotId);
  if (set == null) return const SizedBox.shrink(key: Key('m4-slot-absent'));
  return KisKeySetField(
    set: set,
    handoff: rt.secrets,
    janitor: rt.clipboard,
    secure: rt.secure,
  );
};

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
  // 🆕 E11p3d-5d(R129) — M9 S02 증권사 키(캡처 막기 = `kSecureRoutePatterns` · 키 칸 = 설정 슬롯 빌더).
  AppRoutes.settingsCredentials: _settingsCredentials,
  // 🆕 E11p3d-5e(R134) — M9 S01 설정 홈(더보기 탭 본문).
  AppRoutes.settingsHome: _settingsHome,
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
  // 확인(ack) = 명령 API 전 — null = 버튼 부재(셸 규약).
  shellAlertCommandApiProvider.overrideWithValue(null as CommandApi?),
  // 🆕 R109 — 운영 상태(감시 보드 · 진단 = 실물 · 나머지 = 원천 없음).
  shellOpsStatusRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorOpsStatusProvider),
  ),
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
  shellHoldingsRepositoryProvider.overrideWithValue(
    const OperatorHoldingsRepository(),
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
  settingsClockProvider.overrideWithValue(runtime.clock),
  settingsLinkOpenerProvider.overrideWith(
    (Ref ref) => ref.watch(shellLinkOpenerProvider),
  ),
  settingsOpsStatusRepositoryProvider.overrideWith(
    (Ref ref) => ref.watch(operatorOpsStatusProvider),
  ),
];
