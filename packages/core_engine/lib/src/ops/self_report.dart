// E11q-q6 — `L-3` 원장 실사(정기 · `periodicAudit`) 엔진 몫(앱 계약 01 §21-3 · §21-4 · 02 §3-10 · X7 B14 · B15 · A12).
//
// 🔴 한 실사 = 그 달 · 그 계좌(K7 · K36 ⓐ) · 세션 = 그 폰 한 대(K9) · 기준일 = 그 달의 마지막 KR 세션(K8 · 세션을 열 때 엔진이
//    정한다 · 원값은 VM 에 없다 — 글자만).
// 🔴 원장 현재값을 VM 에 싣지 않는다(앵커링 금지 · 02 §3-10 금지 ①) — 차이는 제출 집행 뒤 [SelfReportResult] 로만.
// 🔴 화면 검증 0(K4) — 빈칸 · 꼴 · 0 포함 전 종목(B14) · 확인값 = 여기서 거부(큐 적재 없이 `INPUT_INVALID` · 글자가 어느 칸인지
//    말한다) · 세션 밖 = `SELF_REPORT_OUTSIDE_SESSION`.
// 🔴 차이 = `ledger_diff(pair = CANON_SELF_REPORT)` · 심각도 = 쌍 규칙(`OBSERVATIONAL` — 차단은 실사의 «부재»에만 · A12) ·
//    실사 경로의 등급 상한 = `SELF_REPORTED`(실사만으로는 `RECONCILED` 에 닿지 않는다).
// 🔵 글자 = 표본(`m6/self_report_*`) 문장 그대로 · 표본 밖 갈래(세션을 열지 못한 까닭 · 칸별 거부) = 이 글자표.
// 🆕 R278(01 §8 미결 227 · 계약 v1.37 §46 K323 · K321 ④) — 현금 축: 계좌별 원장 현금(`cash_flow.account_alias` + 그 계좌
//    브로커 체결 대금 · 기준일 종가까지 = 수량 축과 같은 «그날») · 허용 오차 = 운영 설정 `self_report_cash_tolerance_krw`
//    (값 = 발주자 수치 대기 · 🔴 엔진 기본값 0) · `SELF_AUDIT_PATTERN_UNVERIFIED` 가 서 있으면 0원 · 둘 다 없음 = 대조 안 함 ·
//    계좌를 모르는 현금 · 체결이 기준일까지 있으면 = 모름(대조 안 함) · 차이 = 원 단위 대조(02 §3-10 «원 단위»).

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../calendar/exchange_calendar.dart';
import '../data/quote_feed.dart' show lastFinishedSession;
import '../orders/ledger_pairs.dart' show diffSeverityFor;
import '../orders/order_draft.dart' show P0sStrategyIds;
import '../sim/sim_internal_broker.dart'
    show SimExecution, SimOrder, simOrderableCashOf;
import '../whatif/what_if_config.dart' show WhatIfConfig, kP0sParkingSymbol;
import 'ledger_views.dart' show StoredLedgerDiff, ledgerDiffRowOf, kstDateText;
import 'p0s_ops_config.dart' show P0sOpsConfig, kP0sMappedStrategies;
import 'sim_opening_command.dart' show SimOpeningCommand, cashKrwOfText;

/// 실사 VM 기준의 신선 한도(표본 `stale_after_seconds` 93600 = 26시간).
const Duration kSelfReportStaleAfter = Duration(seconds: 93600);

/// 실사 글자표(표본 문장 그대로 · 표본 밖 갈래 = 엔진 문장).
abstract final class SelfReportTexts {
  /// «8월 정기 실사».
  static String title(int month) => '$month월 정기 실사';

  /// 달을 모를 때의 제목.
  static const String titleUnknown = '정기 실사';

  /// 세션 고지(B15).
  static const String notice =
      '실사 중에는 이 폰의 화면에서 보유 수량·금액이 가려집니다 · 원장 값은 제출 뒤에 보입니다';

  /// «2026-08-31 종가 기준으로 적으십시오».
  static String asOfTradeDate(String yyyyMmDd) => '$yyyyMmDd 종가 기준으로 적으십시오';

  /// 기준일을 정하지 못했을 때.
  static const String asOfUnknown = '기준일을 정하지 못했습니다';

  /// «연금저축 계좌» — 🔴 별칭 밖 글자를 지어내지 않는다(계좌 전체번호 금지).
  static String account(String alias) => '$alias 계좌';

  /// 현금 칸 힌트(02 §3-10 — 원 단위).
  static const String cashHint = '원화 현금 — 원 단위까지 적으십시오';

  /// 확인 1단계.
  static const String declareComplete = '이것이 전부입니다';

  /// 세션이 열려 있지 않다(시작 전 · 이탈 · 앱 재시작).
  static const String sessionClosed = '실사 세션이 닫혔습니다 · 다시 시작하려면 화면을 다시 여십시오';

  /// 세션을 열지 못함 — 자동 매매 운영.
  static const String closedAutoTrade =
      '자동 매매 운영에서는 원장 실사를 받지 않습니다 · 투자 안내 운영에서만 실사합니다';

  /// 세션을 열지 못함 — 계좌 대응 없음.
  static const String closedNoAccounts = '전략 → 계좌 대응이 아직 정해지지 않아 실사할 수 없습니다';

  /// 세션을 열지 못함 — 설정에 없는 별칭.
  static const String closedUnknownAccount =
      '설정된 계좌 별칭이 아닙니다 · 홈이나 알림의 실사 링크로 다시 들어오십시오';

  /// 세션을 열지 못함 — 달 꼴이 틀렸거나 달력 밖.
  static const String closedUnknownMonth =
      '실사할 달을 알아보지 못했습니다 · 홈이나 알림의 실사 링크로 다시 들어오십시오';

  /// 세션을 열지 못함 — 신뢰 시각 모름(E11k-a · 기기 시계로 대신하지 않는다).
  static const String closedTrustedTimeUnknown =
      '신뢰 시각을 확인하지 못해 실사 세션을 열지 않았습니다 · 서버 연결을 확인한 뒤 화면을 다시 여십시오';

  /// 세션을 열지 못함 — 기준일 종가가 아직 확정되지 않음.
  static String closedNotYet(String yyyyMmDd) =>
      '$yyyyMmDd 종가가 아직 확정되지 않았습니다 · 그날 18시 뒤에 실사하십시오';

  /// 세션을 열지 않음 — 이 달 이 계좌 실사가 이미 있다(결과만 보인다 · 동작 결과 글자).
  static const String alreadyAudited = '이 달 이 계좌 실사는 이미 기록했습니다 · 결과만 보입니다';

  /// 결과 — 차이 없음.
  static const String resultEmpty = '실사 결과가 원장과 맞습니다';

  /// 🆕 R278 결과 — 차이 없음 · 현금 미대조(허용 오차 값 · 표식 둘 다 없음 — 표본 `m6/self_report_cash_2` 둘째 행).
  static const String resultCashNoTolerance =
      '수량은 원장과 맞습니다 · 현금은 허용 오차가 정해지기 전이라 대조하지 않았습니다(적은 값은 기록에 남습니다)';

  /// 🆕 R278 결과 — 차이 없음 · 현금 미대조(그 계좌 원장 현금을 셀 수 없음 — 표본 밖 갈래 · K323 ①).
  static const String resultCashLedgerUnknown =
      '수량은 원장과 맞습니다 · 현금은 계좌별 원장 현금을 셀 수 없어 대조하지 않았습니다(적은 값은 기록에 남습니다)';

  /// 🆕 R278 차이 글자 «원화 현금이 기록과 다릅니다 (원장 412,300원 / 자가 보고 405,300원)»(L-1 엔진 사전 · 원 단위 정수).
  static String cashDelta(Decimal ledgerKrw, Decimal reportedKrw) =>
      '원화 현금이 기록과 다릅니다 (원장 ${_cashWon(ledgerKrw)} / 자가 보고 ${_cashWon(reportedKrw)})';

  /// 결과 — 해소 링크(→ `M5-13`).
  static const String resolve = '차이 해소하기';

  /// 🆕 R280(K320) — 자가 보고 차이의 경로 글자(관측 · 자동 재동기화도 승인 필요도 아니다 — 해소 = 다시 실사 0오차).
  static const String routeReaudit = '다시 실사로 해소';

  /// 🆕 R280(K320) — 자가 보고 차이 행의 폰 조치(그 달 · 그 계좌 `L-3`).
  static const String reaudit = '다시 실사하기';

  /// 결과 — 다음 계좌.
  static String nextAccount(String alias) => '다음 계좌 실사 — ${account(alias)}';

  /// 차이 글자 «133690 수량 −3주 (원장 245 / 자가 보고 242)».
  static String quantityDelta(String symbol, int ledger, int reported) {
    final int d = reported - ledger;
    final String signed = d < 0 ? '−${-d}' : '+$d';
    return '$symbol 수량 $signed주 (원장 $ledger / 자가 보고 $reported)';
  }

  /// 접수증 — 기록됨.
  static const String executed = '기록됨 — 실사 보고가 원장과 대조되었습니다';

  /// 접수증 — 세션 밖.
  static const String outsideSession =
      '거부됨 — 열린 실사 세션이 없습니다. 화면을 다시 열어 실사를 시작하십시오. 입력값은 그대로 남아 있습니다';

  /// 접수증 — 무결성 점검 중 보관.
  static const String held =
      '보류됨 — 원장 무결성 점검 중이라 보관했습니다. 복구 뒤 일괄 확정 단계에서 처리됩니다';

  /// 접수증 — 자동 매매 운영.
  static const String operatingModeMismatch =
      '거부됨 — 자동 매매 운영에서는 원장 실사를 받지 않습니다. 입력값은 그대로 남아 있습니다';

  /// 접수증 — 리스 봉인(B19 · 원장 재해석 계열).
  static const String leaseExpired =
      '거부됨 — 이 기기의 운영 리스가 봉인되어 실사를 기록하지 않았습니다. 입력값은 그대로 남아 있습니다';

  /// 접수증 — 신뢰 시각 모름.
  static const String trustedTimeUnknown =
      '거부됨 — 신뢰 시각을 확인하지 못해 실사를 기록하지 않았습니다. 입력값은 그대로 남아 있습니다';

  /// 접수증 — 로컬 거부(어느 칸인지).
  static String inputInvalid(String what) => '거부됨 — $what. 입력값은 그대로 남아 있습니다';

  /// 칸 — 현금 꼴(표본).
  static const String cashMalformed = '현금 칸을 숫자로 적으십시오';

  /// 칸 — 현금 음수.
  static const String cashNegative = '현금 칸에는 0 이상을 적으십시오';

  /// 칸 — 현금 원 미만.
  static const String cashFraction = '현금 칸은 원 단위까지만 적으십시오(소수 없이)';

  /// 칸 — 종목 수량 빈칸(B14 — 빈칸 ≠ 0).
  static String quantityBlank(String label) =>
      '$label 수량 칸이 비어 있습니다 — 보유하지 않으면 0 을 적으십시오';

  /// 칸 — 종목 수량 꼴.
  static String quantityMalformed(String label) =>
      '$label 수량 칸을 0 이상의 정수로 적으십시오';

  /// 칸 — 목록에 없는 종목 줄.
  static const String unknownLine = '실사 종목 목록에 없는 줄이 있습니다';

  /// 칸 — 확인 1단계를 누르지 않음.
  static const String notDeclared = '«이것이 전부입니다»를 확인하십시오';

  /// 칸 — 달이 없음.
  static const String monthMissing = '실사할 달이 없습니다';

  /// 칸 — 세션 계좌와 다른 계좌.
  static const String accountMismatch = '실사 계좌가 열린 세션의 계좌와 다릅니다';
}

/// 표본 신뢰 배지 글자(`m6/self_report_1` · `m7/ledger_trust_4` 둘째 행).
abstract final class SelfReportTrustTexts {
  /// 등급 이름.
  static const String label = '자가 보고';

  /// 까닭.
  static const String consequence = '브로커 대사 대신 사용자가 보고한 잔고입니다.';

  /// 올라가는 길.
  static const String upgradeHint = '증권사 연결을 마치면 대사 등급으로 올라갑니다.';
}

/// 실사 차이의 후보 원인(표본 `m6/self_report_diff_result`).
const List<String> kSelfReportDiffCandidates = <String>[
  OriginCodes.unrecordedFill,
  OriginCodes.selfReportCorrection,
];

/// 🆕 R278 현금 차이의 후보 원인(표본 `m6/self_report_cash_2` 차례 · K323 ⑤ — 사전 무변경).
const List<String> kSelfReportCashDiffCandidates = <String>[
  OriginCodes.externalCashflow,
  OriginCodes.unrecordedFill,
  OriginCodes.selfReportCorrection,
];

/// 원 단위 정수 글자 «412,300원» · 음수 = U+2212(수량 차이 글자와 같은 빼기).
String _cashWon(Decimal won) {
  final BigInt n = won.round().toBigInt();
  final String d = n.abs().toString();
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < d.length; i++) {
    if (i > 0 && (d.length - i) % 3 == 0) b.write(',');
    b.write(d[i]);
  }
  return '${n.isNegative ? '−' : ''}$b원';
}

final RegExp _yyyyMm = RegExp(r'^(\d{4})-(0[1-9]|1[0-2])$');
final RegExp _quantity = RegExp(r'^(?:\d+|\d{1,3}(?:,\d{3})+)$');

/// `yyyy-MM` 의 달(1~12) — 꼴이 틀리면 null.
int? selfReportMonthOf(String yyyyMm) {
  final RegExpMatch? m = _yyyyMm.firstMatch(yyyyMm);
  return m == null ? null : int.parse(m.group(2)!);
}

String _lastDayOf(String yyyyMm) {
  final int y = int.parse(yyyyMm.substring(0, 4));
  final int m = int.parse(yyyyMm.substring(5, 7));
  final int last = DateTime.utc(y, m + 1, 0).day;
  return '$yyyyMm-${last.toString().padLeft(2, '0')}';
}

/// 🔴 실사 기준일(K8) = 그 달의 마지막 KR 세션 — 꼴이 틀림 · 달력 밖 · 그 달에 세션 없음 = null(지어내지 않는다).
TradeDate? selfReportAsOfOf(String yyyyMm, ExchangeCalendar kr) {
  if (selfReportMonthOf(yyyyMm) == null) return null;
  String d = _lastDayOf(yyyyMm);
  try {
    while (d.startsWith(yyyyMm)) {
      if (kr.isSession(TradeDate(d))) return TradeDate(d);
      final DateTime prev = DateTime.parse('${d}T00:00:00Z')
          .subtract(const Duration(days: 1));
      d = prev.toIso8601String().substring(0, 10);
    }
  } on StateError {
    return null;
  }
  return null;
}

/// 계좌 별칭 차례(설정 `accountByStrategy` · 전략 차례 A → B → C → POT · 처음 나온 차례).
List<String> selfReportAccountsOf(Map<String, String> accountByStrategy) =>
    <String>{
      for (final String s in kP0sMappedStrategies)
        if (accountByStrategy[s] != null && accountByStrategy[s]!.isNotEmpty)
          accountByStrategy[s]!,
    }.toList(growable: false);

/// 그 계좌에 묶인 전략(설정 `accountByStrategy`).
List<String> selfReportStrategiesOf(
  Map<String, String> accountByStrategy,
  String alias,
) => <String>[
  for (final String s in kP0sMappedStrategies)
    if (accountByStrategy[s] == alias) s,
];

int _sleeveRank(SleeveId s) => switch (s) {
  SleeveId.a => 0,
  SleeveId.b => 1,
  SleeveId.c => 2,
  SleeveId.pot => 3,
  SleeveId.cash => 4,
  SleeveId.satellite => 5,
};

/// 전략 → 슬리브(P0S 전략 넷 · 모르는 전략 = null).
SleeveId? selfReportSleeveOfStrategy(String strategyId) => switch (strategyId) {
  P0sStrategyIds.sleeveA => SleeveId.a,
  P0sStrategyIds.sleeveB => SleeveId.b,
  P0sStrategyIds.sleeveC => SleeveId.c,
  P0sStrategyIds.pot => SleeveId.pot,
  _ => null,
};

/// 🔴 실사 종목(B14 «유니버스 전 종목» — 계좌와 무관하게 전부 · 그 계좌에 엉뚱하게 산 종목도 적게) = 설정의 KR 종목
/// (슬리브 A 종목 + 계획 종목 + 파킹) ∪ [held](원장에 남은 종목 → 슬리브 · 설정 밖 종목이 대조에서 빠지지 않게).
/// 슬리브 = 처음 맞는 차례(A 종목 → A · B 자산 · 파킹 → B · C 채권 · 금 → C — 금은 B 자산이 먼저) · 차례 = 슬리브 → 종목 코드.
List<SymbolOption> selfReportSymbolsOf(
  P0sOpsConfig cfg, {
  Map<String, SleeveId> held = const <String, SleeveId>{},
  WhatIfConfig? labels,
}) {
  final Map<String, String> names =
      (labels ?? WhatIfConfig.defaults).symbolLabels;
  final Map<String, SleeveId> sleeve = <String, SleeveId>{};
  void put(String s, SleeveId id) => sleeve.putIfAbsent(s, () => id);
  put(cfg.aSymbol, SleeveId.a);
  for (final (String s, _) in cfg.monthEnd.bAssets) {
    put(s, SleeveId.b);
  }
  put(kP0sParkingSymbol, SleeveId.b);
  put(cfg.monthEnd.cBondSymbol, SleeveId.c);
  put(cfg.monthEnd.cGoldSymbol, SleeveId.c);
  for (final String s in cfg.krSymbols) {
    put(s, SleeveId.b);
  }
  held.forEach(put);
  final List<String> order = sleeve.keys.toList()
    ..sort((String x, String y) {
      final int r = _sleeveRank(sleeve[x]!).compareTo(_sleeveRank(sleeve[y]!));
      return r != 0 ? r : x.compareTo(y);
    });
  return <SymbolOption>[
    for (final String s in order)
      SymbolOption(symbol: s, label: names[s] ?? s, sleeve: sleeve[s]!),
  ];
}

/// 세션을 열 수 있나 — 판정 결과.
sealed class SelfReportStartVerdict {
  const SelfReportStartVerdict();
}

/// 연다 — [asOf] = 기준일 · [startedAtUtc] = 신뢰 시각(B15 `sessionStartedAt`).
final class SelfReportStartOpen extends SelfReportStartVerdict {
  /// 만든다.
  const SelfReportStartOpen({required this.asOf, required this.startedAtUtc});

  /// 기준일.
  final TradeDate asOf;

  /// 세션 시작(UTC · 신뢰 시각).
  final DateTime startedAtUtc;
}

/// 열지 않는다 — [text] = 화면 문장(`sessionClosedText`) · [asOf] = 알면 기준일.
final class SelfReportStartRefused extends SelfReportStartVerdict {
  /// 만든다.
  const SelfReportStartRefused(this.text, {this.asOf});

  /// 문장.
  final String text;

  /// 기준일(알면).
  final TradeDate? asOf;
}

/// 🔴 세션 시작 판정(K8 · K9) — 차례 = 운영 방식 → 계좌 대응 → 별칭 → 달 → 신뢰 시각 → 기준일 종가 확정.
/// 신뢰 시각 = E11k-a 관문([trustedNowUtc] null = 열지 않는다 · 기기 시계로 대신하지 않는다).
SelfReportStartVerdict selfReportStartOf({
  required String yyyyMm,
  required String accountAlias,
  required OperatingMode? operatingMode,
  required Map<String, String> accountByStrategy,
  required DateTime? trustedNowUtc,
  required ExchangeCalendar kr,
}) {
  if (operatingMode != OperatingMode.advisory) {
    return const SelfReportStartRefused(SelfReportTexts.closedAutoTrade);
  }
  final List<String> accounts = selfReportAccountsOf(accountByStrategy);
  if (accounts.isEmpty) {
    return const SelfReportStartRefused(SelfReportTexts.closedNoAccounts);
  }
  if (!accounts.contains(accountAlias)) {
    return const SelfReportStartRefused(SelfReportTexts.closedUnknownAccount);
  }
  final TradeDate? asOf = selfReportAsOfOf(yyyyMm, kr);
  if (asOf == null) {
    return const SelfReportStartRefused(SelfReportTexts.closedUnknownMonth);
  }
  final DateTime? now = trustedNowUtc;
  if (now == null) {
    return SelfReportStartRefused(
      SelfReportTexts.closedTrustedTimeUnknown,
      asOf: asOf,
    );
  }
  final String finished;
  try {
    finished = lastFinishedSession(kr, now);
  } on StateError {
    return SelfReportStartRefused(
      SelfReportTexts.closedUnknownMonth,
      asOf: asOf,
    );
  }
  if (asOf.yyyyMmDd.compareTo(finished) > 0) {
    return SelfReportStartRefused(
      SelfReportTexts.closedNotYet(asOf.yyyyMmDd),
      asOf: asOf,
    );
  }
  return SelfReportStartOpen(asOf: asOf, startedAtUtc: now.toUtc());
}

/// 열린 세션 하나(그 달 · 그 계좌 · 그 폰).
class SelfReportOpenSession {
  /// 만든다.
  const SelfReportOpenSession({
    required this.yyyyMm,
    required this.accountAlias,
    required this.asOf,
    required this.startedAtUtc,
  });

  /// 그 달.
  final String yyyyMm;

  /// 그 계좌.
  final String accountAlias;

  /// 기준일.
  final TradeDate asOf;

  /// 시작(UTC · 신뢰 시각).
  final DateTime startedAtUtc;
}

/// 제출 → 와이어 결과.
sealed class SelfReportWireResult {
  const SelfReportWireResult();
}

/// 와이어가 섰다.
final class SelfReportWireReady extends SelfReportWireResult {
  /// 만든다.
  const SelfReportWireReady(this.wire);

  /// 와이어(엔진이 읽는 `SelfReportBalance` 그대로 · C-28 ⑥).
  final SelfReportBalance wire;
}

/// 원문이 틀렸다 — 큐 적재 없이 `INPUT_INVALID`.
final class SelfReportInputInvalid extends SelfReportWireResult {
  /// 만든다.
  const SelfReportInputInvalid(this.stateLabel);

  /// 어느 칸인지 말하는 접수증 글자.
  final String stateLabel;
}

/// 🔴 정기 실사 제출 → 와이어(01 §21-3 구현 의무 ① ②) — [submission] 은 `periodicAudit` 이어야 한다(아니면 [ArgumentError]).
///
/// 부르는 쪽이 먼저 세션을 찾는다(없으면 `SELF_REPORT_OUTSIDE_SESSION` — 여기 오지 않는다). 차례 = 계좌 → 줄(목록 밖 →
/// 목록 차례로 빈칸 · 꼴) → 현금(빈칸 · 꼴 · 음수 · 원 미만) → 확인. 줄 = [symbols] 차례 · 0 포함(B14).
SelfReportWireResult selfReportWireOf(
  SelfReportSubmission submission, {
  required SelfReportOpenSession session,
  required List<SymbolOption> symbols,
  required CommandContext context,
}) {
  if (submission.purpose != SelfReportPurpose.periodicAudit) {
    throw ArgumentError.value(submission.purpose, 'purpose', '정기 실사 제출이 아니다');
  }
  SelfReportInputInvalid bad(String what) =>
      SelfReportInputInvalid(SelfReportTexts.inputInvalid(what));
  final SelfReportInput input = submission.input;
  if (input.accountAlias != session.accountAlias) {
    return bad(SelfReportTexts.accountMismatch);
  }
  final Map<String, String> raw = <String, String>{
    for (final SelfReportLineInput l in input.lines) l.symbol: l.quantityText,
  };
  final Set<String> known = <String>{
    for (final SymbolOption s in symbols) s.symbol,
  };
  if (raw.keys.any((String s) => !known.contains(s))) {
    return bad(SelfReportTexts.unknownLine);
  }
  final List<SelfReportLine> lines = <SelfReportLine>[];
  for (final SymbolOption s in symbols) {
    final String t = (raw[s.symbol] ?? '').trim();
    if (t.isEmpty) return bad(SelfReportTexts.quantityBlank(s.label));
    if (!_quantity.hasMatch(t)) {
      return bad(SelfReportTexts.quantityMalformed(s.label));
    }
    final int? q = int.tryParse(t.replaceAll(',', ''));
    if (q == null) return bad(SelfReportTexts.quantityMalformed(s.label));
    lines.add(
      SelfReportLine(symbol: s.symbol, symbolLabel: s.label, quantity: q),
    );
  }
  if (input.cashKrwText.trim().isEmpty) {
    return bad(SelfReportTexts.cashMalformed);
  }
  final Decimal? cash = cashKrwOfText(input.cashKrwText);
  if (cash == null) return bad(SelfReportTexts.cashMalformed);
  if (cash < Decimal.zero) return bad(SelfReportTexts.cashNegative);
  if (cash != cash.floor()) return bad(SelfReportTexts.cashFraction);
  if (!submission.declaredComplete) return bad(SelfReportTexts.notDeclared);
  return SelfReportWireReady(
    SelfReportBalance(
      asOfTradeDate: session.asOf,
      purpose: SelfReportPurpose.periodicAudit,
      sessionStartedAt: session.startedAtUtc,
      lines: lines,
      cashKrw: cash,
      accountAlias: session.accountAlias,
      declaredComplete: true,
      context: context,
    ),
  );
}

/// `command_inbox.payload_digest` — 와이어 JSON 의 SHA-256 16진(🔴 원문 재저장 금지 · digest 만).
String selfReportPayloadDigestOf(SelfReportBalance wire) =>
    sha256.convert(utf8.encode(jsonEncode(wire.toJson()))).toString();

/// 수량 차이 한 줄(원장 ≠ 자가 보고).
class SelfReportQuantityDiff {
  /// 만든다.
  const SelfReportQuantityDiff({
    required this.symbol,
    required this.ledger,
    required this.reported,
  });

  /// 종목.
  final String symbol;

  /// 원장 수량(기준일).
  final int ledger;

  /// 자가 보고 수량.
  final int reported;

  @override
  bool operator ==(Object other) =>
      other is SelfReportQuantityDiff &&
      other.symbol == symbol &&
      other.ledger == ledger &&
      other.reported == reported;

  @override
  int get hashCode => Object.hash(symbol, ledger, reported);

  @override
  String toString() => 'SelfReportQuantityDiff($symbol, $ledger → $reported)';
}

/// 🔴 수량 대조 — [ledger] = 기준일 원장 수량(종목 → 수량 · 없음 = 0) · [reported] = 와이어 줄(차례 그대로) · 같으면 빠진다.
/// 🔵 현금 축 = [selfReportCashVerdictOf](R278 · 허용 오차가 없으면 대조하지 않는다 — 보고 값은 원장에 남긴다).
List<SelfReportQuantityDiff> selfReportQuantityDiffsOf({
  required Map<String, int> ledger,
  required List<SelfReportLine> reported,
}) => <SelfReportQuantityDiff>[
  for (final SelfReportLine l in reported)
    if ((ledger[l.symbol] ?? 0) != l.quantity)
      SelfReportQuantityDiff(
        symbol: l.symbol,
        ledger: ledger[l.symbol] ?? 0,
        reported: l.quantity,
      ),
];

/// `ledger_diff.diff_id` — 기준일 · 계좌 · 종목이 같으면 같은 id(그 달 그 계좌 실사는 한 번).
String selfReportDiffIdOf(TradeDate asOf, String alias, String symbol) =>
    'ld_sr_${sha256.convert(utf8.encode(jsonEncode(<String>[asOf.yyyyMmDd, alias, symbol]))).toString().substring(0, 12)}';

/// `ledger_diff.delta` — 계좌 · 종목 · 두 값 · 후보 원인(`L-1` 칩이 읽는다).
String selfReportDeltaOf(String alias, SelfReportQuantityDiff d) =>
    jsonEncode(<String, Object?>{
      'account': alias,
      'symbol': d.symbol,
      'ledger': d.ledger,
      'reported': d.reported,
      'candidates': kSelfReportDiffCandidates,
    });

/// `ledger_diff.delta` 의 계좌 별칭(실사 행이 아니면 null).
String? selfReportAccountOfDelta(String delta) {
  final Object? j = jsonDecode(delta);
  if (j is! Map<String, Object?>) return null;
  final Object? a = j['account'];
  return a is String ? a : null;
}

/// 저장할 차이 한 행(`ledger_diff`).
class SelfReportDiffRow {
  /// 만든다.
  const SelfReportDiffRow({
    required this.diffId,
    required this.axis,
    required this.delta,
    required this.deltaLabel,
    required this.severity,
  });

  /// id.
  final String diffId;

  /// 🆕 R278 축(수량 · 현금).
  final LedgerAxis axis;

  /// 원값 JSON.
  final String delta;

  /// 글자.
  final String deltaLabel;

  /// 심각도(쌍 규칙).
  final DiffSeverity severity;
}

/// 차이 → 저장 행(쌍 = `CANON_SELF_REPORT` · 축 = 수량 · 심각도 = 쌍 규칙).
List<SelfReportDiffRow> selfReportDiffRowsOf({
  required TradeDate asOf,
  required String alias,
  required List<SelfReportQuantityDiff> diffs,
}) => <SelfReportDiffRow>[
  for (final SelfReportQuantityDiff d in diffs)
    SelfReportDiffRow(
      diffId: selfReportDiffIdOf(asOf, alias, d.symbol),
      axis: LedgerAxis.quantity,
      delta: selfReportDeltaOf(alias, d),
      deltaLabel: SelfReportTexts.quantityDelta(d.symbol, d.ledger, d.reported),
      severity: diffSeverityFor(
        LedgerPair.canonSelfReport,
        LedgerAxis.quantity,
      ),
    ),
];

// ── 🆕 R278 현금 축(01 §8 미결 227 · 계약 v1.37 §46 K323) ─────────────────────────────

/// 계좌 원장 현금 원천(기준일 종가까지 · ds 가 원장에서 읽는다 — 🔴 원값은 VM 에 싣지 않는다).
class SelfReportCashFacts {
  /// 만든다.
  const SelfReportCashFacts({
    required this.cashFlowSum,
    required this.executions,
    required this.unattributed,
  });

  /// 그 계좌 원화 `cash_flow` 합(거래일 ≤ 기준일 · 들어오면 + · 나가면 −).
  final double cashFlowSum;

  /// 그 계좌(`order_intents.account`) KR 브로커 체결(집행일 ≤ 기준일 · `REVERSAL` = 수량 · 비용 음수).
  final List<SimExecution> executions;

  /// 기준일까지 계좌를 모르는 현금 · 체결이 있다(별칭 빈 `cash_flow` 행 · 계좌 빈 의도의 체결 · 살아 있는 수기 체결 — 수기 체결
  /// 행에는 계좌 칸이 없다) → 그 계좌 원장 현금 = 모름.
  final bool unattributed;
}

/// 🔴 기준일 계좌 원장 현금(원 · 정확값) — 모름 = null · 셈 = 시뮬레이터 · 보유 화면과 같은 한 셈(`simOrderableCashOf` ·
/// 매도 = 대금 − 비용 · 매수 = −(대금 + 비용) · 판정 전 주문 예약 0 — 원장에 적힌 것만).
Decimal? selfReportLedgerCashOf(SelfReportCashFacts f) => f.unattributed
    ? null
    : simOrderableCashOf(f.cashFlowSum, f.executions, const <SimOrder>[]);

/// 🔴 현금 축 허용 오차(원) — `SELF_AUDIT_PATTERN_UNVERIFIED` 가 서 있으면 0원(02 §3-10 «원 단위» · K323 ③) · 아니면 운영 설정
/// [configuredKrw](`operations.self_report_cash_tolerance_krw` · 값 = 발주자 수치 대기) · 둘 다 없음 = null(대조 안 함 — 🔴 엔진
/// 기본값 0) · 음수 = [ArgumentError](설정 꼴 틀림을 조용히 넘기지 않는다).
Decimal? selfReportCashToleranceOf({
  required int? configuredKrw,
  required bool patternMarker,
}) {
  if (configuredKrw != null && configuredKrw < 0) {
    throw ArgumentError.value(
      configuredKrw,
      'self_report_cash_tolerance_krw',
      '0 이상이어야',
    );
  }
  if (patternMarker) return Decimal.zero;
  return configuredKrw == null ? null : Decimal.fromInt(configuredKrw);
}

/// 현금 축을 대조하지 않은 까닭.
enum SelfReportCashSkip {
  /// 허용 오차 값도 표식도 없다(K323 ④).
  noTolerance,

  /// 그 계좌의 기준일 원장 현금을 셀 수 없다(K323 ① — 별칭 빈 행 · 계좌 모를 체결).
  ledgerUnknown,
}

/// 🔴 대조하지 않는 까닭(차례 = 허용 오차 → 원장 현금) — null = 대조한다. 🆕 R281 — 제출 순간 판정만 이 차례를 쓴다(결과 글자는
/// 실사 행에 적힌 판정 `cash_check` 를 읽는다 — [selfReportCashSkipOfCheck]).
SelfReportCashSkip? selfReportCashSkipOf({
  required Decimal? toleranceKrw,
  required bool ledgerKnown,
}) => toleranceKrw == null
    ? SelfReportCashSkip.noTolerance
    : !ledgerKnown
    ? SelfReportCashSkip.ledgerUnknown
    : null;

/// 현금 축 판정.
sealed class SelfReportCashVerdict {
  const SelfReportCashVerdict();
}

/// 대조하지 않았다(차이 행 0 · 결과 글자가 말한다).
final class SelfReportCashSkipped extends SelfReportCashVerdict {
  /// 만든다.
  const SelfReportCashSkipped(this.reason);

  /// 까닭.
  final SelfReportCashSkip reason;
}

/// 대조했고 허용 오차 안이다.
final class SelfReportCashWithin extends SelfReportCashVerdict {
  /// 만든다.
  const SelfReportCashWithin({required this.toleranceKrw});

  /// 적용한 허용 오차(🆕 R281 — 실사 행 `cash_tolerance_krw` 로 적는다).
  final Decimal toleranceKrw;
}

/// 대조했고 허용 오차를 넘었다(관측 차이 1행).
final class SelfReportCashMismatch extends SelfReportCashVerdict {
  /// 만든다.
  const SelfReportCashMismatch({
    required this.ledgerKrw,
    required this.reportedKrw,
    required this.toleranceKrw,
  });

  /// 원장 현금(원 단위로 반올림).
  final Decimal ledgerKrw;

  /// 자가 보고 현금(원 단위 — 와이어가 이미 막았다).
  final Decimal reportedKrw;

  /// 적용한 허용 오차.
  final Decimal toleranceKrw;
}

/// 🔴 현금 대조(K323) — 대조 안 함 = [selfReportCashSkipOf] · 원장 = 원 단위로 반올림해 대조(자가 보고는 원 단위 정수) ·
/// |원장 − 보고| ≤ 허용 오차 = 안 · 넘으면 차이.
SelfReportCashVerdict selfReportCashVerdictOf({
  required Decimal? toleranceKrw,
  required Decimal? ledgerKrw,
  required Decimal reportedKrw,
}) {
  final SelfReportCashSkip? skip = selfReportCashSkipOf(
    toleranceKrw: toleranceKrw,
    ledgerKnown: ledgerKrw != null,
  );
  if (skip != null) return SelfReportCashSkipped(skip);
  final Decimal ledger = ledgerKrw!.round();
  return (ledger - reportedKrw).abs() > toleranceKrw!
      ? SelfReportCashMismatch(
          ledgerKrw: ledger,
          reportedKrw: reportedKrw,
          toleranceKrw: toleranceKrw,
        )
      : SelfReportCashWithin(toleranceKrw: toleranceKrw);
}

/// 현금 차이 id — 기준일 · 계좌가 같으면 같은 id(종목 id 와 원문 꼴이 달라 겹치지 않는다 · 그 달 그 계좌 실사는 한 번).
String selfReportCashDiffIdOf(TradeDate asOf, String alias) =>
    'ld_sr_${sha256.convert(utf8.encode(jsonEncode(<String>[asOf.yyyyMmDd, alias]))).toString().substring(0, 12)}';

/// 🔴 현금 판정 → 저장 행(차이 = 1 · 그 밖 = 0) — 쌍 = `CANON_SELF_REPORT` · 축 = 현금 · 심각도 = 쌍 규칙(관측) · delta = 계좌 ·
/// 두 값 · 적용한 허용 오차 · 후보(표본 차례).
List<SelfReportDiffRow> selfReportCashDiffRowsOf({
  required TradeDate asOf,
  required String alias,
  required SelfReportCashVerdict verdict,
}) => switch (verdict) {
  SelfReportCashMismatch(
    :final Decimal ledgerKrw,
    :final Decimal reportedKrw,
    :final Decimal toleranceKrw,
  ) =>
    <SelfReportDiffRow>[
      SelfReportDiffRow(
        diffId: selfReportCashDiffIdOf(asOf, alias),
        axis: LedgerAxis.cash,
        delta: jsonEncode(<String, Object?>{
          'account': alias,
          'axis': LedgerAxis.cash.wire,
          'ledger_krw': ledgerKrw.toString(),
          'reported_krw': reportedKrw.toString(),
          'tolerance_krw': toleranceKrw.toString(),
          'candidates': kSelfReportCashDiffCandidates,
        }),
        deltaLabel: SelfReportTexts.cashDelta(ledgerKrw, reportedKrw),
        severity: diffSeverityFor(LedgerPair.canonSelfReport, LedgerAxis.cash),
      ),
    ],
  SelfReportCashSkipped() ||
  SelfReportCashWithin() => const <SelfReportDiffRow>[],
};

// ── 🆕 R281 판정 원장 기록(01 §8 미결 256 · 계약 v1.42 §51 · `self_report_balance.cash_check` · `cash_tolerance_krw`) ──

/// 🔴 판정 → 실사 행에 적을 두 칸 그대로(`cash_check` · `cash_tolerance_krw` REAL — 대조함 = 적용한 허용 오차(원 단위 정수라
/// 실수로 정확) · 대조 안 함 = 까닭 · 허용 오차 null) — 제출 순간 한 번만 정한다.
({SelfReportCashCheck check, double? toleranceKrw}) selfReportCashRecordOf(
  SelfReportCashVerdict verdict,
) => switch (verdict) {
  SelfReportCashWithin(:final Decimal toleranceKrw) ||
  SelfReportCashMismatch(:final Decimal toleranceKrw) => (
    check: SelfReportCashCheck.compared,
    toleranceKrw: toleranceKrw.toDouble(),
  ),
  SelfReportCashSkipped(reason: SelfReportCashSkip.noTolerance) => (
    check: SelfReportCashCheck.noTolerance,
    toleranceKrw: null,
  ),
  SelfReportCashSkipped(reason: SelfReportCashSkip.ledgerUnknown) => (
    check: SelfReportCashCheck.ledgerUnknown,
    toleranceKrw: null,
  ),
};

/// 🔴 실사 행에 적힌 판정 → 결과 빈 문장의 까닭(대조함 = null) — 🔴 나중에 바뀐 설정 · 표식으로 다시 정하지 않는다(R278 D9 닫음).
SelfReportCashSkip? selfReportCashSkipOfCheck(SelfReportCashCheck check) =>
    switch (check) {
      SelfReportCashCheck.compared => null,
      SelfReportCashCheck.noTolerance => SelfReportCashSkip.noTolerance,
      SelfReportCashCheck.ledgerUnknown => SelfReportCashSkip.ledgerUnknown,
    };

/// 🔴 0오차 실사(K321 ④ · M5-13 해제가 읽는다 — 미결 226) = 수량 축 전부 일치 ∧ 현금 축은 대조한 때만 센다(대조 안 함 = 세지
/// 않음 · 대조해 넘음 = 0오차 아님). 원장에서는 «그 실사가 남긴 차이 행 0»과 같다(현금 행은 대조해 넘은 때만 생긴다).
bool selfReportZeroErrorOf({
  required List<SelfReportQuantityDiff> quantity,
  required SelfReportCashVerdict cash,
}) => quantity.isEmpty && cash is! SelfReportCashMismatch;

String? _linkOf(String pattern, Map<String, String> args) {
  String out = pattern;
  for (final MapEntry<String, String> e in args.entries) {
    if (e.value.isEmpty || e.value.contains(RegExp(r'[/?#]'))) return null;
    out = out.replaceFirst(':${e.key}', e.value);
  }
  return out;
}

/// `L-3` 링크(그 달 · 그 계좌) — 🔴 별칭에 `/` · `?` · `#` 가 있으면 null(C-46 ⑮ — 링크를 짓지 않는다).
String? selfReportLinkOf(String yyyyMm, String alias) => _linkOf(
  AppRoutes.ledgerSelfReport,
  <String, String>{'yyyyMm': yyyyMm, 'accountAlias': alias},
);

/// 🔴 실사 결과(02 §3-10 «제출 후 = 엔진이 준 차이 목록만») — 행 = `L-1` 과 같은 엔진 사전(같은 차이가 두 화면에서 같게 읽힌다) ·
/// 행 `actionLink` = null(자기 자신으로 가는 고리 방지) · [resolveRegistered] = `M5-13` 본문이 있나(없으면 해소 링크 0 ·
/// 열린 차이가 있을 때만) · [nextAlias] = 이 달 아직 실사하지 않은 다음 계좌(없음 = 이 달 실사 끝) · 🆕 R278 [cashSkipped] = 현금 축을
/// 대조하지 않은 까닭(null = 대조함) — 차이 0 일 때 빈 문장이 말한다(K323 ④ · 표본 `m6/self_report_cash_2`).
SelfReportResult selfReportResultOf({
  required List<StoredLedgerDiff> diffs,
  required String yyyyMm,
  required String? nextAlias,
  required bool resolveRegistered,
  required SelfReportCashSkip? cashSkipped,
}) {
  final List<LedgerDiffRow> rows = <LedgerDiffRow>[
    for (final StoredLedgerDiff d in diffs)
      ledgerDiffRowOf(d).copyWith(actionLink: null),
  ];
  final bool open = diffs.any(
    (StoredLedgerDiff d) => d.status == DiffStatus.open,
  );
  final String? next = nextAlias == null
      ? null
      : selfReportLinkOf(yyyyMm, nextAlias);
  return SelfReportResult(
    diffs: rows,
    emptyLabel: rows.isNotEmpty
        ? null
        : switch (cashSkipped) {
            null => SelfReportTexts.resultEmpty,
            SelfReportCashSkip.noTolerance =>
              SelfReportTexts.resultCashNoTolerance,
            SelfReportCashSkip.ledgerUnknown =>
              SelfReportTexts.resultCashLedgerUnknown,
          },
    resolveLink: open && resolveRegistered
        ? const LinkAction(
            label: SelfReportTexts.resolve,
            deepLink: AppRoutes.m5SelfAuditResolve,
          )
        : null,
    nextAccountLink: next == null
        ? null
        : LinkAction(
            label: SelfReportTexts.nextAccount(nextAlias!),
            deepLink: next,
          ),
  );
}

/// 🆕 R280(01 §8 미결 226 · K320 «다시 실사») — 그 달 · 그 계좌 실사를 «이미 기록함 · 결과만»으로 닫나 = 실사가 있고 그 기준일 ·
/// 그 계좌의 열린 자가 보고 차이가 없을 때만. 열린 차이가 있으면 같은 달 · 같은 계좌를 다시 실사한다(세션을 연다 · 차이 행의
/// «다시 실사하기» 목적지 — 해소 = 다시 실사 0오차).
bool selfReportAlreadyAuditedOf({
  required bool audited,
  required bool openDiffs,
}) => audited && !openDiffs;

/// 이 달 아직 실사하지 않은 다음 계좌 — [accounts] 차례로 [current] 뒤 먼저 · 다음 앞쪽(없음 = null).
String? selfReportNextAccountOf({
  required List<String> accounts,
  required String current,
  required Set<String> audited,
}) {
  final int at = accounts.indexOf(current);
  for (int i = 1; i < accounts.length; i++) {
    final String a = accounts[(at + i) % accounts.length];
    if (a != current && !audited.contains(a)) return a;
  }
  return null;
}

/// 🔴 세션 VM 의 신뢰 배지 — 실사 경로의 상한 = `SELF_REPORTED`(실패가 아니라 정상 운영 상태) · [lastVerifiedOn] = 그 계좌의
/// 마지막 실사 기준일(없음 = null) · 링크 = null(이미 실사 화면).
LedgerTrustBadge selfReportTrustBadgeOf(TradeDate? lastVerifiedOn) =>
    LedgerTrustBadge(
      grade: LedgerTrustGrade.selfReported,
      level: UiLevel.info,
      label: SelfReportTrustTexts.label,
      consequenceLine: SelfReportTrustTexts.consequence,
      upgradeHint: SelfReportTrustTexts.upgradeHint,
      lastVerifiedOn: lastVerifiedOn,
    );

/// 🔴 `L-3` 세션 VM(01 §21-4) — 원장 현재값 0 · 기준일 원값 0(글자만).
///
/// [closedText] = 세션이 열려 있지 않은 까닭(null = 열림) · [result] = 이 달 이 계좌 실사 결과(있으면 폼 부재 · 결과만 —
/// 그때 [closedText] 는 싣지 않는다: 화면은 닫힘 문장을 먼저 본다) · [asOf] = 기준일(모르면 null) · 기준 `AsOf` 관측 =
/// [observedAtUtc](열린 세션 = 세션 시작 · 그 밖 = 지금 — 화면은 «관측 + 신선 한도» 가 지나면 폼을 그리지 않는다: 기준일
/// 종가가 아니라 세션을 연 때가 관측이다 · 같은 세션은 같은 값이라 주기마다 다시 내지 않는다).
SelfReportSession selfReportSessionVmOf({
  required String yyyyMm,
  required String accountAlias,
  required TradeDate? asOf,
  required List<SymbolOption> symbols,
  required String? closedText,
  required SelfReportResult? result,
  required TradeDate? lastVerifiedOn,
  required DateTime observedAtUtc,
}) {
  final int? month = selfReportMonthOf(yyyyMm);
  final String day = asOf?.yyyyMmDd ?? kstDateText(observedAtUtc);
  return SelfReportSession(
    titleText: month == null
        ? SelfReportTexts.titleUnknown
        : SelfReportTexts.title(month),
    noticeText: SelfReportTexts.notice,
    asOfTradeDateText: asOf == null
        ? SelfReportTexts.asOfUnknown
        : SelfReportTexts.asOfTradeDate(asOf.yyyyMmDd),
    symbols: symbols,
    accountLabel: SelfReportTexts.account(accountAlias),
    cashHintLabel: SelfReportTexts.cashHint,
    declareCompleteLabel: SelfReportTexts.declareComplete,
    sessionClosedText: result != null ? null : closedText,
    result: result,
    trust: selfReportTrustBadgeOf(lastVerifiedOn),
    asOf: AsOf(
      observedAt: observedAtUtc.toUtc(),
      tradeDate: TradeDate(day),
      source: AsOfSource.localSqlite,
      staleAfter: kSelfReportStaleAfter,
      label: '실사 기준 $day',
    ),
  );
}

/// 정기 실사 제출의 끝(접수증 갈래 — 로컬 거부 `INPUT_INVALID` 은 [SelfReportInputInvalid] 글자로 따로).
enum SelfReportOutcome {
  /// 기록 · 대조됨.
  executed,

  /// 무결성 점검 중 보관(B18 — 거부하지 않는다).
  held,

  /// 열린 세션 없음.
  outsideSession,

  /// 자동 매매 운영.
  operatingModeMismatch,

  /// 리스 봉인(B19).
  leaseExpired,

  /// 신뢰 시각 모름.
  trustedTimeUnknown,
}

/// 🔴 접수증 — 글자 · 사유 코드 = 엔진(표본 `m6/self_report_receipts_5` 글자 · 표본 밖 갈래 = 글자표) · 봉투 = [c].
CommandReceipt selfReportReceiptOf(SimOpeningCommand c, SelfReportOutcome o) {
  CommandReceipt reject(String label, String code) =>
      c.receipt(executed: false, stateLabel: label, rejectReasonCode: code);
  return switch (o) {
    SelfReportOutcome.executed => c.receipt(
      executed: true,
      stateLabel: SelfReportTexts.executed,
    ),
    SelfReportOutcome.held =>
      c
          .receipt(executed: true, stateLabel: SelfReportTexts.held)
          .copyWith(state: CommandState.heldForIntegrity),
    SelfReportOutcome.outsideSession => reject(
      SelfReportTexts.outsideSession,
      AdviceRejectCodes.selfReportOutsideSession,
    ),
    SelfReportOutcome.operatingModeMismatch => reject(
      SelfReportTexts.operatingModeMismatch,
      AdviceRejectCodes.operatingModeMismatch,
    ),
    SelfReportOutcome.leaseExpired => reject(
      SelfReportTexts.leaseExpired,
      AdviceRejectCodes.leaseExpired,
    ),
    SelfReportOutcome.trustedTimeUnknown => reject(
      SelfReportTexts.trustedTimeUnknown,
      SafetyCommonResultCodes.trustedTimeUnknown,
    ),
  };
}
