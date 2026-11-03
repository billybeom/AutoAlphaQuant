// broker_gateway — M1 브로커 경계의 공개 진입점(배럴).
//
// 🔴 브로커를 호출하는 코드는 전부 이 패키지 안에 있다. 다른 패키지가 KIS를
//    직접 부르면 유량 제어·멱등키가 우회된다.
// 🔴 ui_*는 이 패키지를 의존하지 않는다(C-3).
// 🔴 웹·데스크탑 타깃에서는 이 패키지가 **빌드에서 제외**된다(경계 규칙 ③).
//    코드 리뷰로 대체하지 않는다.
//
// 구현은 lib/src/ 아래로 들어오고 공개할 것만 여기에서 export 한다.
// 🆕 E8d2a(설계 13 §8 R29) — KIS REST 핵심(환경 · 자격증명 · 토큰 · 유량 문 · 조회 재시도)과 시세 6종.
//    주문(E10)은 같은 클라이언트·유량 문 위에 얹는다.
// 🆕 E8d2b(설계 13 §8 R30) — core_engine 일봉 원천 포트 구현(`KisQuoteFeed` · 저장 이름 → KIS 코드 · 오류 → `QuoteFeedDown`).

export 'src/kis/kis_environment.dart';
export 'src/kis/kis_orders.dart';
export 'src/kis/kis_quote_feed.dart';
export 'src/kis/kis_quotes.dart';
export 'src/kis/kis_rest_client.dart';
export 'src/kis/kis_token.dart';
