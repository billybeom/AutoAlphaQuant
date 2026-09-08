// 01 §4-1 — X5 정합(원장 대조) 읽기 창구.

import '../dto/ledger.dart';
import '../dto/ledger_trust.dart';
import '../primitives/list_result.dart';

/// 열린 불일치 목록 · 시스템 밖 자산 목록.
abstract interface class LedgerRepository {
  /// 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도
  ///    주문을 막지 않는다**(01 §2-9).
  /// 🔴 `applicable == false` 인 칸은 «점검 안 함»으로 그린다 — 보드 칸 수는 모드와
  ///    무관하게 **5 고정**이다.
  Stream<ListResult<LedgerDiffRow>> watchOpenDiffs();

  /// 🆕 X7 — 시스템 밖 자산(`external_holding`).
  /// 🔴 이 목록은 표시 전용이며 파생 계산 경로가 읽지 않는다(C-23).
  Stream<ListResult<ExternalHoldingRow>> watchExternalHoldings();
}
