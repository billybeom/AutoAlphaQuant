// M3-1 What-if 입력 포트 — 미리보기가 읽는 상태 한 벌(설계 13 §8 R18 D-4 · 발주자 2026-10-21 · 추천안).
//
// 🔴 미리보기는 **읽기만** 한다(06 M3-1 «부작용 0» = 원장·명령 테이블 쓰기 0). 이 포트가 상태를 주고, 쓰는 곳은
//    계획 스냅샷 저장소 하나다(E7a2-3).
// 🔵 원천은 아직 정하지 않고 필드로만 받는다 — 실데이터 어댑터는 E8(데이터) · E11(런타임) 몫이다(D-4):
//    `recovery` = 열린 재개가 복구 모드(`ResumeMode.recoveryDry` · `recoveryFull`)인가 ·
//    `accounts.pensionAlias == null` = «계좌 매핑 미완»(슬리브 B 의 연금저축 계좌 미지정) ·
//    `pensionUsedThisYear` = 올해 연금 합산 납입 누계(원장 C→B 납입 + 시스템 밖 납입 신고값).
// 🔵 보유·가격·슬리브 평가(배분 계산의 입력)는 E7a2-2 가 이 상태에 더한다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show BlockFlag, TradeDate;

/// 계좌 매핑 — 별칭만 싣는다(계좌 번호는 엔진 밖으로 내지 않는다 · 01 §5).
class WhatIfAccounts {
  const WhatIfAccounts({
    required this.pensionAlias,
    required this.generalAlias,
  });

  /// 슬리브 B 가 서는 연금 계좌 별칭(03 §2-7-1 — 연금저축 · IRP 는 주문 불가). null = 매핑 미완.
  final String? pensionAlias;

  /// 과세(일반) 계좌 별칭 — 연금 한도가 소진되면 B 몫 밖 금액이 여기로 간다.
  final String? generalAlias;
}

/// 미리보기가 읽는 상태.
class WhatIfState {
  const WhatIfState({
    required this.asOfTradeDate,
    required this.configHash,
    required this.activeFlags,
    required this.recovery,
    required this.accounts,
    required this.pensionUsedThisYear,
    this.unknownSymbols = const <String>{},
  });

  /// 입력 기준 거래일(그날 종가로 계산한다).
  final TradeDate asOfTradeDate;

  /// 전략 config 해시(M1 config 로더가 생기기 전까지 포트로 받는다 · D-5).
  final String configHash;

  /// 켜져 있는 차단 플래그(`SafetyState.activeFlags` 와 같은 꼴).
  final List<BlockFlag> activeFlags;

  /// 열린 재개가 복구 모드인가.
  final bool recovery;
  final WhatIfAccounts accounts;

  /// 올해 연금 합산 납입 누계(원 · 이번 입금 전).
  final Decimal pensionUsedThisYear;

  /// 체결 확인 중(UNKNOWN)인 직전 주문이 남은 종목 — 초안의 `pendingNoteText`(E7a2-2).
  final Set<String> unknownSymbols;

  /// [flagId] 플래그가 켜져 있으면 그 플래그.
  BlockFlag? flag(String flagId) {
    for (final BlockFlag f in activeFlags) {
      if (f.flagId == flagId) return f;
    }
    return null;
  }
}

/// 상태 공급자 — 실데이터 어댑터(E8 · E11)와 시험이 구현한다.
abstract interface class WhatIfStateSource {
  Future<WhatIfState> load();
}
