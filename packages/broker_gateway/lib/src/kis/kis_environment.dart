// KIS 접속 환경 · 자격증명(설계 13 §8 R29 L2 · M1-8 «실전·모의 단일 스위치»).
//
// 🔴 환경 하나가 도메인을 정한다. 주문 TR 접두(실전 T/J · 모의 V)도 같은 스위치에서 나온다(E10).
//    도메인만 바꾸고 TR 을 안 바꾸면 실주문이 나간다(`03_실행/01` §1-1 경고) — 그래서 사람이 두 곳을 고치지 않게 한다.
// 🔴 자격증명이 환경을 **지닌다**. 클라이언트 환경과 다르면 요청을 만들기 전에 거절한다(잘못된 키 세트로 실전 전환 차단).
// 🔴 키·시크릿·계좌번호는 `toString`·오류에 나오지 않는다.

/// KIS 접속 환경.
enum KisEnvironment {
  /// 모의투자 — `openapivts.koreainvestment.com:29443` · 유량 1건/초(2026-04-20 공지).
  mock('openapivts.koreainvestment.com', 29443, Duration(milliseconds: 1100)),

  /// 실전투자 — `openapi.koreainvestment.com:9443` · 유량 18건/초(2026-04-20 공지 · 보수값).
  live('openapi.koreainvestment.com', 9443, Duration(microseconds: 55556));

  const KisEnvironment(this.host, this.port, this.minInterval);

  /// 이 환경의 호스트 · 포트 — 요청은 여기로만 간다.
  final String host;
  final int port;

  /// 요청 사이 최소 간격(R29 L4 · 앱키 하나 기준).
  final Duration minInterval;

  /// [path] 와 [query] 로 이 환경의 주소를 만든다.
  Uri uri(String path, [Map<String, String>? query]) => Uri(
    scheme: 'https',
    host: host,
    port: port,
    path: path,
    queryParameters: query == null || query.isEmpty ? null : query,
  );
}

/// 신규 앱키는 신청 뒤 3일간 초당 3건(체크리스트 §5-1 4단계) — 그 동안 쓰는 간격(선택).
const Duration kKisNewKeyInterval = Duration(milliseconds: 340);

/// KIS 앱키 한 벌 — 어느 환경의 것인지 함께 지닌다.
class KisCredentials {
  KisCredentials({
    required this.environment,
    required this.appKey,
    required this.appSecret,
    required this.accountNo,
    this.productCode = '01',
  }) {
    if (appKey.isEmpty || appSecret.isEmpty) {
      throw ArgumentError('앱키·시크릿이 비었다');
    }
    if (accountNo.length != 8 || int.tryParse(accountNo) == null) {
      throw ArgumentError('계좌번호는 숫자 8자리(종합계좌)여야 한다');
    }
    if (productCode.length != 2 || int.tryParse(productCode) == null) {
      throw ArgumentError('상품코드는 숫자 2자리여야 한다');
    }
  }

  /// 이 키 세트가 발급된 환경.
  final KisEnvironment environment;

  /// 앱키 · 시크릿 · 종합계좌번호(8) · 상품코드(2).
  final String appKey, appSecret, accountNo, productCode;

  /// 오류·기록에 섞이면 안 되는 값들.
  List<String> get secrets => <String>[appKey, appSecret, accountNo];

  @override
  String toString() => 'KisCredentials(${environment.name} · <가림>)';
}

/// 안전 장치가 막은 요청(환경 불일치 · 다른 호스트).
class KisGuardError implements Exception {
  const KisGuardError(this.message);

  final String message;

  @override
  String toString() => 'KisGuardError: $message';
}
