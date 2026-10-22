// 01 §4-1 · §10 — 🆕 X7 원장 신뢰 등급 읽기 창구.

import '../dto/ledger_trust.dart';

/// 원장 신뢰 등급 배지.
/// 🔴 `LedgerTrustGrade.selfReported` 는 **실패가 아니라 정상 운영 상태**다(01 §2-1 X7).
abstract interface class LedgerTrustRepository {
  Stream<LedgerTrustBadge> watchGrade();

  /// 🆕 v1.12(01 §21 · K8 · K36 ⓐ) — `L-3` 세션(키 = 라우트 두 값 그대로 — 그 달 `yyyy-MM` · 그 계좌 별칭).
  /// 🔴 세션을 여닫지 않는다(K9 — `SettingsActions` `selfReportSessionStart`·`Stop`) · 부작용 0(01 §1-4 «읽기»).
  Stream<SelfReportSession> watchSelfReportSession(
    String yyyyMm,
    String accountAlias,
  );
}
