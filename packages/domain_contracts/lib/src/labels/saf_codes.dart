// 01 §3-2 — SAF 코드 접두 대역 + `SAF309_` 상세 6종.
//
// 🔴 개별 SAF 코드(37종)의 정본은 엔진 `06_시스템설계/04_안전장치.md` 다. 여기 두는 것은
//    ① 화면·픽스처가 만나는 **접두 대역**과 ② 주문 게이트 진리표가 내는 **SAF309_ 상세 6종**이다.
// 🔴 화면은 배지로만 쓴다 — 진리표는 주문 게이트의 사양 벡터이지 표시 분기가 아니다(01 §3-2 말미).
// 🔴 `ui_*` 소스에 `'SAF-'` 리터럴이 있으면 C-5 가 실패시킨다. 이 파일은 `domain_contracts` 이므로
//    C-5 의 대상이 아니지만, **여기서 문구를 만들지 않는다**는 규약은 같다.

/// SAF 코드의 접두 대역(01 §3-2).
abstract final class SafBandCodes {
  /// 포지션 리스크 한도.
  static const String band1xx = 'SAF-1xx';

  /// 슬리브 한도·종목 필터.
  static const String band2xx = 'SAF-2xx';

  /// 포트폴리오·세금 게이트.
  static const String band3xx = 'SAF-3xx';

  /// 시스템·주문 게이트.
  static const String band4xx = 'SAF-4xx';

  /// 드로다운 서킷브레이커. 🔵 v2.31 P0S 에서 대상 없음.
  static const String band5xx = 'SAF-5xx';

  /// 타임존·스케줄.
  static const String band7xx = 'SAF-7xx';

  /// 장애 대응. 🔴 §3-2 표는 8xx·9xx 를 **한 행**(장애·보안)으로 묶어 «7대역»이라 부른다 —
  ///    접두 **문자열**은 둘이므로 이 집합의 원소는 8개다(대역 수 7 ≠ 접두 문자열 수 8).
  static const String band8xx = 'SAF-8xx';

  /// 보안. §3-2 표에서 `SAF-8xx` 와 한 행이다.
  static const String band9xx = 'SAF-9xx';

  /// 전량 — 접두 문자열 8개(대역은 7행).
  static const Set<String> values = <String>{
    band1xx,
    band2xx,
    band3xx,
    band4xx,
    band5xx,
    band7xx,
    band8xx,
    band9xx,
  };
}

/// SAF-309(POT 주문 계좌 절세 게이트) 상세 사유 코드 6종.
///
/// 진리표 원본 = `09_백테스트/백테스트6/runs/H2_saf/saf309_vector.json` (05 GV-SAF-309).
/// 🔴 `SAF309_` 접두가 **코드 문자열의 일부**다(진리표의 `reason_codes` 키와 문자 그대로 일치).
/// 🔴 갈래는 계좌 배치가 정한다 — 화면·인자로 고르는 경로를 만들지 않는다.
abstract final class Saf309Codes {
  /// 등록 절세계좌 확인 — 주문 허용.
  static const String okTaxAdvantaged = 'SAF309_OK_TAX_ADVANTAGED';

  /// 일반계좌 — 실주문 거부.
  static const String denyTaxableAccount = 'SAF309_DENY_TAXABLE_ACCOUNT';

  /// 계좌 유형 확인 불가 — fail-closed 거부.
  static const String denyUnverifiedFailClosed =
      'SAF309_DENY_UNVERIFIED_FAIL_CLOSED';

  /// DRY_RUN·백테스트 — 일반계좌 경고.
  static const String warnTaxableAccount = 'SAF309_WARN_TAXABLE_ACCOUNT';

  /// DRY_RUN·백테스트 — 확인 불가 경고.
  static const String warnUnverified = 'SAF309_WARN_UNVERIFIED';

  /// 조회는 주문이 아님 — 게이트 대상 아님.
  static const String naQueryNotAnOrder = 'SAF309_NA_QUERY_NOT_AN_ORDER';

  /// 전량 6종.
  ///
  /// ⚠️ `contracts_inventory.md` §3-1 의 `ReasonChip.code` 예시 `'SAF309_ACCOUNT_UNVERIFIED'` 는
  ///    이 6종에 **없다**. 예시가 진리표와 어긋난 것이므로 임의로 추가하지 않는다(멈추고 보고).
  static const Set<String> values = <String>{
    okTaxAdvantaged,
    denyTaxableAccount,
    denyUnverifiedFailClosed,
    warnTaxableAccount,
    warnUnverified,
    naQueryNotAnOrder,
  };
}
