// 모의 개시 — 가상 초기금 나눔 · 전략 시딩 목록 · 체험 시작 문(SPEC v2.44 02 §2-7 ⓐ · 앱 06 X6-5 ⓑ ·
// 설계 13 §8 R80 D7 · D8 · R85 AA3 · AA4).
//
// 🔴 나눔 = P0S 목표 비중(A · B · C)을 전략 → 계좌 대응으로 모은 비율 · 원 단위 내림 · 나머지 원은 비중이 가장 큰 계좌
//    (동률 = 별칭 순) — 다계좌 전략의 예수금이 0 으로 줄지 않게 한다(«실전과 같은 코드»).
// 🔴 계층 B 카드가 등록되기 전에는 체험을 시작하지 않는다(D8) — 시딩된 전략은 카드 없이 월말 뒤 신규 매수가 막힌다.
// 🔵 거부 코드 = 엔진 문자열(계약 등재 = 1.19.0 창 후보 · `safety/alert_text.dart` 선례).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show SleeveId, TradeDate;

import '../ops/tier_b.dart' show TierBCard;
import '../orders/order_draft.dart' show P0sStrategyIds;

/// 모의 개시 · 온보딩 커밋 거부 코드(R85).
abstract final class SimOpeningCodes {
  /// 금액이 0 이하.
  static const String notPositive = 'SIM_OPENING_NOT_POSITIVE';

  /// 금액에 원 미만 자리가 있다.
  static const String notWholeWon = 'SIM_OPENING_NOT_WHOLE_WON';

  /// 비중이 있는 전략의 계좌가 설정에 없다.
  static const String accountUnmapped = 'SIM_OPENING_ACCOUNT_UNMAPPED';

  /// 자동 매매 개시에 보유 줄이 왔다(금액 1칸만 받는다).
  static const String linesNotAllowed = 'SIM_OPENING_LINES_NOT_ALLOWED';

  /// 정기 실사 등 다른 목적의 제출.
  static const String wrongPurpose = 'SIM_OPENING_WRONG_PURPOSE';

  /// 이미 선언했다(append-only — 고치려면 모의 원장 폐기 후 새 개시).
  static const String alreadyDeclared = 'SIM_OPENING_ALREADY_DECLARED';

  /// 커밋 전에 가상 초기금 선언이 없다.
  static const String notDeclared = 'SIM_OPENING_NOT_DECLARED';

  /// 운영 방식 선택(O-00b)이 없다.
  static const String choiceMissing = 'ONBOARDING_CHOICE_MISSING';

  /// 투자 안내 갈래의 모의 개시(보유 선언 · L-3 폼) = E18.
  static const String advisoryNotReady = 'SIM_OPENING_ADVISORY_NOT_READY';

  /// 계층 B 카드 미등록 — 체험 시작 금지(D8).
  static const String tierBCardMissing = 'TIER_B_CARD_MISSING';
}

/// 🔴 커밋이 시딩하는 P0S 전략 — SAF-406 이 주문마다 보는 전략 전부(입금 `P0S` 는 전략이 아니다).
const List<String> kP0sSeedStrategies = <String>[
  P0sStrategyIds.sleeveA,
  P0sStrategyIds.sleeveB,
  P0sStrategyIds.sleeveC,
  P0sStrategyIds.pot,
];

/// 시딩 상태(계층 B 가 ACTIVE → PROBATION 으로 옮긴다).
const String kSeedStrategyState = 'ACTIVE';

/// 시딩 상한 비율(1 = 전부 · 계층 B 가 절반 · STOPPED 가 0 으로 낮춘다).
const double kSeedCapitalCap = 1.0;

/// 개시 결정 id(하루 하나 · 파일당 한 번만 쓴다).
String simOpeningDecisionId(TradeDate asOf) => 'SIMOPEN-${asOf.yyyyMmDd}';

/// 슬리브 → P0S 전략(나눔 대상 슬리브만 · 나머지 = null).
String? p0sStrategyOfSleeve(SleeveId s) => switch (s) {
  SleeveId.a => P0sStrategyIds.sleeveA,
  SleeveId.b => P0sStrategyIds.sleeveB,
  SleeveId.c => P0sStrategyIds.sleeveC,
  SleeveId.pot || SleeveId.cash || SleeveId.satellite => null,
};

/// 가상 초기금 나눔 결과 — 거부면 [reject] 만, 아니면 계좌 별칭 → 원(양수만).
class SimOpeningSplit {
  const SimOpeningSplit._(this.byAccount, this.reject);

  /// 계좌별 금액.
  final Map<String, int> byAccount;

  /// 거부 코드(없으면 null).
  final String? reject;
}

/// 🔴 가상 초기금 [cashKrw] 를 계좌별로 나눈다(R85 AA3).
SimOpeningSplit simOpeningSplit({
  required Decimal cashKrw,
  required Map<SleeveId, Decimal> weights,
  required Map<String, String> accountByStrategy,
}) {
  SimOpeningSplit no(String code) =>
      SimOpeningSplit._(const <String, int>{}, code);
  if (cashKrw <= Decimal.zero) return no(SimOpeningCodes.notPositive);
  if (cashKrw.floor() != cashKrw) return no(SimOpeningCodes.notWholeWon);
  final Map<String, Decimal> weightOf = <String, Decimal>{};
  for (final MapEntry<SleeveId, Decimal> e in weights.entries) {
    if (e.value <= Decimal.zero) continue;
    final String? strategy = p0sStrategyOfSleeve(e.key);
    final String? alias = strategy == null ? null : accountByStrategy[strategy];
    if (alias == null) return no(SimOpeningCodes.accountUnmapped);
    weightOf[alias] = (weightOf[alias] ?? Decimal.zero) + e.value;
  }
  if (weightOf.isEmpty) return no(SimOpeningCodes.accountUnmapped);
  final List<String> aliases = weightOf.keys.toList()..sort();
  final int total = cashKrw.toBigInt().toInt();
  final Map<String, int> out = <String, int>{
    for (final String a in aliases)
      a: (cashKrw * weightOf[a]!).floor().toBigInt().toInt(),
  };
  final int rest = total - out.values.fold(0, (int s, int v) => s + v);
  String top = aliases.first;
  for (final String a in aliases) {
    if (weightOf[a]! > weightOf[top]!) top = a;
  }
  out[top] = out[top]! + rest;
  out.removeWhere((String _, int v) => v <= 0);
  return SimOpeningSplit._(Map<String, int>.unmodifiable(out), null);
}

/// 🔴 체험 시작 문(D8) — 계층 B 카드가 없으면 거부 코드.
String? simTrialStartReject({required TierBCard? card}) =>
    card == null ? SimOpeningCodes.tierBCardMissing : null;
