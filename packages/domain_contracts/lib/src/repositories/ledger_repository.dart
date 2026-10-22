// 01 §4-1 — X5 정합(원장 대조) 읽기 창구.

import '../dto/ledger.dart';
import '../dto/ledger_trust.dart';
import '../primitives/list_result.dart';

/// 열린 불일치 목록 · 시스템 밖 자산 목록 · 🆕 v1.12 정정 이력.
abstract interface class LedgerRepository {
  /// 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도
  ///    주문을 막지 않는다**(01 §2-9).
  /// 🔴 `applicable == false` 인 칸은 «점검 안 함»으로 그린다 — 보드 칸 수는 모드와
  ///    무관하게 **5 고정**이다.
  /// 🆕 v1.12 주석(01 §21 · G32) — 이름은 «열린» 이지만 **최근의 해소·수용된 차이도 온다**(`L-1` 이 resolved·
  ///    accepted 를 그린다 · 최근 차이 = 열린 것 + 해소·수용된 것). 이름 바꾸기는 파괴라 별도 창(W9).
  Stream<ListResult<LedgerDiffRow>> watchOpenDiffs();

  /// 🆕 X7 — 시스템 밖 자산(`external_holding`).
  /// 🔴 이 목록은 표시 전용이며 파생 계산 경로가 읽지 않는다(C-23).
  Stream<ListResult<ExternalHoldingRow>> watchExternalHoldings();

  /// 🆕 v1.12(01 §21 · K24) — `L-2` 정정 이력(append-only 표시판 · 순서 = 엔진(계단식 · K25) · 빈 = `emptyLabel`
  /// «정정 이력이 없습니다» · 뷰어 원천 0 = 01 §8 미결 117 — iOS·웹 = 셸 «폰에서만»).
  Stream<ListResult<LedgerRepairRow>> watchRepairs({int limit = 50});
}
