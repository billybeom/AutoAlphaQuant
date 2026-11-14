// operator 셸 주입(E11p3d-1 · 설계 13 §8 R104 · 06 M4-11 ⑥ · M4-12 · 01 §2 셸 주입).
//
// 🔴 실물이 있는 칸만 주입하고, 실물이 있는 화면만 레지스트리에 올린다 — 올리지 않은 라우트는 셸이 «자리 부재»
//    (`s01-placeholder`)로 그린다(빈 칸 · 크래시가 아니다 · M4-11 머리 «미주입 = 자리 부재»).
// 🔴 이번 조각 = 셸 뼈대 + 알림 센터 · 상세(실물 = `SqliteAlertRepository`) · 확인 버튼 = 명령 API 전이라 부재(null).
// 🆕 E11p3d-5(R107) — 캡처 막기 라우트 감싸기 · https 링크 = 브라우저.
// 🔵 홈(H-01) · 일지 · 보유 · 더보기 본문 · 온보딩 · 장애 배너 · 핸드북은 원천(읽기 모델 · 명령)이 서는 조각에서 더한다(R104 나눔).
//    🔴 M4-12 ① «장애 · 핸드북 override 의무»는 아직 못 지킨다 — 실물 저장소가 없다(R104 남김 · d6).

import 'package:data_sync/data_sync.dart' show SqliteAlertRepository;
import 'package:domain_contracts/domain_contracts.dart'
    show AlertRepository, AppRoutes, CommandApi;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:ui_shell/ui_shell.dart';

import 'operator_runtime.dart';
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

Widget _alertCenter(Map<String, String> _) => const AlertCenter();

Widget _alertDetail(Map<String, String> p) =>
    AlertDetail(alertId: p['alertId'] ?? '');

/// 🔴 본문 레지스트리 — 실물이 있는 화면만(R104 d1).
const ShellRouteBodies kOperatorRouteBodies = ShellRouteBodies(
  <String, ShellBodyBuilder>{
    AppRoutes.alertsInbox: _alertCenter,
    AppRoutes.alertDetail: _alertDetail,
  },
);

/// 🔴 operator 셸 주입 — 실물 있는 칸.
List<Override> operatorShellOverrides(OperatorRuntime runtime) => <Override>[
  operatorRuntimeProvider.overrideWithValue(runtime),
  shellPlatformProvider.overrideWithValue(ShellPlatform.androidOperator),
  shellClockProvider.overrideWithValue(runtime.clock),
  shellConfigRepositoryProvider.overrideWithValue(
    OperatorConfigRepository(runtime.view),
  ),
  shellAlertRepositoryProvider.overrideWith(
    (Ref ref) => SqliteAlertRepository(
      ref.watch(operatorDbProvider),
      clock: runtime.clock,
    ) as AlertRepository,
  ),
  // 확인(ack) = 명령 API 전 — null = 버튼 부재(셸 규약).
  shellAlertCommandApiProvider.overrideWithValue(null as CommandApi?),
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
];
