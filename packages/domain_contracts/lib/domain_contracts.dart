// domain_contracts — M2 도메인 계약의 공개 진입점(배럴).
//
// 🔴 화면(ui_*)이 import 하는 파일은 이것 하나다. lib/src/ 아래를 직접 import
//    하지 않는다 — 내부 구조를 바꿀 때 화면이 조용히 깨진다.
//
// 지금 노출하는 것은 계약 버전 상수뿐이다. DTO·열거형·리포지토리 인터페이스·
// 명령 API는 G3(계약 확정)에서 lib/src/ 아래로 들어오고 여기에서 export 된다.
// 01_M2_도메인계약 §2·§4가 그 목록이다.

export 'src/contract_version.dart';
