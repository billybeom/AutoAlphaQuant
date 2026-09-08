// 01 §2-2 — `DeviationBadge.kindCode` 13종(기존 4 + X7 9).
//
// 🔴 이 목록의 **정본은 이 파일**이다(인벤토리 §3-2 말미 조문). `DeviationBadge` 자체는
//    영역 B 의 `dto/journal.dart` 가 만들고, 여기는 그 `kindCode` 가 가질 수 있는 값의 집합이다.
// 🔴 「예산 차감」·「저널 필요」 여부는 주석으로만 적는다 — 판정은 엔진이고
//    화면은 `DeviationBadge.label` 을 그대로 그린다.

/// `DeviationBadge.kindCode` 값 13종(01 §2-2).
abstract final class DeviationKindCodes {
  // ── 기존 4 ────────────────────────────────────────────────────────────────
  /// 재량 행사(예산 차감).
  static const String discretion = 'DISCRETION';

  /// 수동 주문. 🔴 자동 모드의 규칙 이탈 — 저널 + SEV2 postmortem 이 함께 열린다.
  static const String manualOrder = 'MANUAL_ORDER';

  /// 대사 불일치 해제.
  static const String reconClear = 'RECON_CLEAR';

  /// 킬스위치 해제 후 재개.
  static const String killSwitchResume = 'KILL_SWITCH_RESUME';

  // ── X7 9 ─────────────────────────────────────────────────────────────────
  /// 안내 유효기한 경과(미이행). 🔴 **예산 미차감**.
  static const String adviceLapse = 'ADVICE_LAPSE';

  /// 사람이 미이행을 선언.
  static const String adviceSkip = 'ADVICE_SKIP';

  /// 만료 뒤 지연 이행. 🔴 **예산 미차감 · 정식 저널 불요**.
  static const String adviceLateFill = 'ADVICE_LATE_FILL';

  /// 안내와 무관한 수기 신규. 🔴 **예산 차감 · `M5-6`**.
  static const String manualEntry = 'MANUAL_ENTRY';

  /// 안내 가격대 밖 체결.
  static const String advicePriceDeviation = 'ADVICE_PRICE_DEVIATION';

  /// 안내 수량과 다른 체결.
  static const String adviceQtyDeviation = 'ADVICE_QTY_DEVIATION';

  /// 청산 안내를 피함.
  static const String adviceExitAvoided = 'ADVICE_EXIT_AVOIDED';

  /// 기록 정정(상쇄 + 재기재).
  static const String fillAmended = 'FILL_AMENDED';

  /// 소급 기재.
  static const String backdatedFill = 'BACKDATED_FILL';

  /// 기존 4종.
  static const Set<String> legacy = <String>{
    discretion,
    manualOrder,
    reconClear,
    killSwitchResume,
  };

  /// X7 9종.
  static const Set<String> x7 = <String>{
    adviceLapse,
    adviceSkip,
    adviceLateFill,
    manualEntry,
    advicePriceDeviation,
    adviceQtyDeviation,
    adviceExitAvoided,
    fillAmended,
    backdatedFill,
  };

  /// 전량 13종.
  static const Set<String> values = <String>{...legacy, ...x7};
}
