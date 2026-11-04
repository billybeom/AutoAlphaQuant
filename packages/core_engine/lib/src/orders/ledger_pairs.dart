// X5 대조 쌍의 심각도 · 원인 코드 쓰기 화이트리스트(04 §3-5 v2.33 · 앱 계약 01 §2-9 · §3-4 · 설계 13 §8 R58 C7 · C8).
//
// 🔴 파생 불일치(Supabase · GitHub · 캘린더)는 **어떤 심각도에서도 주문을 막지 않는다** — 파생은 정본보다 먼저 바뀌지 않는다.
// 🔴 차단 후보 = `CANON_BROKER` 의 수량 · 체결 축뿐(현금 = 결제일 모델 전까지 관측) · 자가 보고 = 관측(차단은 «실사의 부재»에만).
// 🔴 `ledger_diff.origin_code` · `trading_block.origin_code` 에 쓰는 값은 이 집합 안에서만 — 열거 밖 자유 서술 거부.

import 'package:domain_contracts/domain_contracts.dart';

/// 쌍 · 축의 심각도(R58 C8).
DiffSeverity diffSeverityFor(LedgerPair pair, LedgerAxis axis) =>
    switch (pair) {
      LedgerPair.canonBroker => switch (axis) {
        LedgerAxis.quantity || LedgerAxis.executionRow => DiffSeverity.blocking,
        LedgerAxis.cash || LedgerAxis.chainHash => DiffSeverity.observational,
      },
      LedgerPair.canonSupabase ||
      LedgerPair.canonGithub ||
      LedgerPair.canonCalendar ||
      LedgerPair.canonSelfReport => DiffSeverity.observational,
    };

/// 브로커 계열(옛 `CORP_ACTION` 제외 — `CORPORATE_ACTION` 으로 통합 · R19 E9-4).
final Set<String> _brokerWritable = <String>{
  for (final String c in OriginCodes.broker)
    if (c != OriginCodes.corpActionLegacy) c,
};

/// 쌍마다 쓸 수 있는 원인 코드(R58 C7).
Set<String> writableOriginCodesFor(LedgerPair pair) => switch (pair) {
  LedgerPair.canonBroker => <String>{..._brokerWritable, ...OriginCodes.x7},
  LedgerPair.canonSupabase ||
  LedgerPair.canonGithub ||
  LedgerPair.canonCalendar => OriginCodes.derived,
  LedgerPair.canonSelfReport => OriginCodes.x7,
};
