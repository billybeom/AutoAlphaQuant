// ui_analytics — M7(성과·리밸런싱·플래너) 화면 패키지의 배럴.
//
// 🔴 의존은 domain_contracts · Flutter · Riverpod **만**이다(C-3).
// 🔴 TWR·MWR·누적곱을 화면이 계산하지 않는다. 누적/비누적 토글도 엔진이 두
//    시리즈를 주거나 cumulative 플래그로 재요청한다(C-4).
// 🔴 결측(value == null)은 **보간하지 않고 공백으로** 그린다(C-10).
// 🔴 손익 노출은 인터스티셜·격리·열람 기록 3종이 함께 있을 때만이다(결정 8).
//
// 아직 비어 있다. 화면 위젯은 lib/src/ 아래로 들어오고 공개할 것만 여기에서
// export 한다.

export 'l10n/labels.dart';
