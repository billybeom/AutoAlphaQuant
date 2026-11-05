// ui_shell — M8(셸·운영 홈·알림·핸드북)·X3(온보딩) 화면 패키지의 배럴.
//
// 🔴 의존은 domain_contracts · Flutter · Riverpod **만**이다(C-3).
// 🔴 홈·알림·위젯에 **손익 숫자가 없다**(결정 8). 홈에 두는 숫자는 슬리브별
//    목표 대비 편차·밴드 여유·과정 지표 3개다. HoldingPnl·PerformanceSeries를
//    이 패키지의 홈·알림 위젯트리에서 참조하면 C-6이 실패한다.
// 🔴 알림 등급 P0/P1/P2를 **표시 계층이 사적으로 재분류하지 않는다**(결정 7c).
//    등급은 조치 기준이며 엔진이 한 번만 정의한다.
//
// 아직 비어 있다. 화면 위젯은 lib/src/ 아래로 들어오고 공개할 것만 여기에서
// export 한다.

export 'l10n/labels.dart';
export 'src/alerts/alert_center.dart';
export 'src/alerts/alert_detail.dart';
export 'src/incident/emergency_stop_card.dart';
export 'src/incident/incident_banner.dart';
export 'src/incident/runbook_detail.dart';
export 'src/incident/runbook_list.dart';
export 'src/onboarding/onboarding_finish.dart';
export 'src/onboarding/onboarding_mode_pick.dart';
export 'src/onboarding/onboarding_restart.dart';
export 'src/onboarding/onboarding_start.dart';
export 'src/onboarding/onboarding_step_detail.dart';
export 'src/onboarding/onboarding_step_list.dart';
export 'src/onboarding/viewer_pairing.dart';
export 'src/ops_home.dart';
export 'src/ops_rhythm.dart';
export 'src/routing/shell_router.dart';
export 'src/shell_providers.dart';
export 'src/shell_scaffold.dart';
export 'src/watchdog_board.dart';
