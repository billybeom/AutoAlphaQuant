// ui_settings — M9(설정·자격증명·계좌·기기·연결) 화면 패키지의 배럴.
//
// 🔴 의존은 domain_contracts · Flutter · Riverpod **만**이다(C-3).
// 🔴 «적용»·«검증»·«백업»·«셀프테스트»는 화면이 수행하지 않는다. 주입된
//    SettingsActions.run()을 1회 부르고 결과의 handoffRoute로 넘긴다.
//    구현체가 주입되지 않은 빌드(뷰어)에서는 컨트롤을 **렌더하지 않는다**
//    — «비활성»이 아니라 **부재**다.
// 🔴 냉각 30일·12월 창·48h 대기·체크리스트 7항 UI를 화면이 만들면 반려다.
//
// 아직 비어 있다. 화면 위젯은 lib/src/ 아래로 들어오고 공개할 것만 여기에서
// export 한다.

export 'l10n/labels.dart';
export 'src/accounts.dart';
export 'src/annual_review.dart';
export 'src/backup.dart';
export 'src/connections.dart';
export 'src/contribution.dart';
export 'src/credentials.dart';
export 'src/devices.dart';
export 'src/diagnostics.dart';
export 'src/operations.dart';
export 'src/settings_home.dart';
export 'src/settings_providers.dart';
