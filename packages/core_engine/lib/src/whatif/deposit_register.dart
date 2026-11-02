// M3-4 실입금 등록 — 판정 순수 함수 · 원장에 남길 값 · 연금 납입 누계 · 계획 대비 실제
// (설계 13 §8 R22 D4·D5·D6·D7·D8·D9·D10·D11·D13 · 01 §20 · E7b2 · E7b3).
//
// 🔴 판정 순서 = `DepositRegisterRejectCodes.precedence` — 없음 → 이미 등록 → (보류) 무결성 → 대조 > 정정 > 만료 → 한도.
//    대조·정정·만료·한도의 순서는 `depositRegisterBlockedText`(화면 문장)와 같다 — 문장과 거부 코드가 엇갈리지 않는다.
// 🔴 한도 재검사(D13) = **지금 남은 연금 납입 한도 < 계획의 B 몫**이면 거부 — 그사이 다른 등록·신고로 한도가 줄었거나
//    해가 바뀐 경우를 등록 순간에 잡는다(세금 사고). 전략 `config_hash` 가 바뀐 것은 거부하지 않는다.
// 🔴 연금 납입 누계(D7) = 원장의 연금 계좌 입금(`cash_flow` DEPOSIT) 합 + 시스템 밖 신고값(포트 · 기본 0 · §8 미결 112).
//    연도 = **등록 처리 시점**의 KST 연도(`recorded_at` — 기준일 `trade_date` 는 휴장 보정이라 연말 휴장(12-31)에
//    넣은 돈이 다음 해로 넘어간다). ⏸ 월말 C→B 납입은 E10 이 기록처를 정할 때 이 합에 더한다.
// 🔴 거부는 **계획 바인딩의 거부**이지 입금 사실의 거부가 아니다 — 돈은 계좌에 남고 새 planId 로 다시 등록한다.
// 🔴 만료는 명령의 **서버 `requested_at`** 으로 잰다(D9) — 엔진 처리 시각이 아니다(오프라인 큐·재시작 지연으로
//    만료 전에 누른 등록을 거부하지 않는다).
// 🔴 금액은 스냅샷에서 · 기준일은 등록 시점(D10 — `requested_at` 의 KST 날짜 · 거래일이 아니면 다음 KR 거래일).
// 🔴 계좌는 스냅샷의 계좌 매핑(`PlanInputs`)에서 — B 몫 → 연금 · 나머지(A · C · 원화 대기) → 일반(D6).
// 🔴 등록은 기록만 한다(D11) — 파킹 매수·안내·`rebalance_event` 는 E10·E18.
// 🔵 명령 TTL(30분) 만료와 «보류는 TTL 을 쓰지 않는다»는 수송(E11 · M4-3)의 몫이다 — 여기는 받은 명령의 판정만.
// ✅ 형식(설계 13 §8 R12 DEPOSIT 행 · 발주자 확정 2026-10-22 · 🆕 E10a 부터 `DecisionIds.deposit`): decision_id = `DEP-{plan_id}`(계획 하나에
//    결정 하나 — 시각·난수 없음 · 다시 돌려도 같은 값) · strategy_id = `P0S` · flow_id = `{decision_id}-PENSION|GENERAL`.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../calendar/exchange_calendar.dart';
import '../orders/idempotency.dart';
import 'plan_inputs.dart';
import 'what_if_gates.dart';
import 'what_if_state.dart';
import 'what_if_text.dart';

/// 수송(E11)이 `command_queue` 행에서 만드는 등록 명령 한 건.
class DepositRegisterCommand {
  const DepositRegisterCommand({
    required this.commandId,
    required this.planId,
    required this.requestedAt,
    required this.expiresAt,
    required this.nonce,
    required this.issuedByDeviceId,
  });

  final String commandId;
  final String planId;

  /// 서버 시각(`command_queue.requested_at`).
  final DateTime requestedAt;

  /// 명령 TTL.
  final DateTime expiresAt;
  final String nonce;
  final String issuedByDeviceId;

  /// `command_inbox.payload_digest` — 페이로드(`DepositRegistration`) JSON 의 SHA-256 16진(원문 재저장 금지).
  String get payloadDigest => sha256
      .convert(
        utf8.encode(jsonEncode(DepositRegistration(planId: planId).toJson())),
      )
      .toString();
}

/// 시스템 밖 연금 납입 신고값(D7 — 다른 증권사·직접 납입 · 설정 키 = §8 미결 112 · M9 창).
abstract interface class PensionDeclarationSource {
  /// [year](KST 연도)에 시스템 밖에서 이미 넣은 연금 납입액(원 · 없으면 0).
  Future<Decimal> declaredOutside(int year);
}

/// 신고값이 아직 없다(M9 설정 창 전) — 늘 0.
/// 🔴 과소 추정이면 한도 재검사가 늦게 막는다 — 그 한계는 화면 고지 몫이다(§8 미결 112).
final class NoPensionDeclaration implements PensionDeclarationSource {
  const NoPensionDeclaration();

  @override
  Future<Decimal> declaredOutside(int year) async => Decimal.zero;
}

/// 저장된 계획 한 건 — 계획 · 계산 입력 원값 · 바인딩.
class DepositPlanSnapshot {
  const DepositPlanSnapshot({
    required this.plan,
    required this.inputs,
    this.consumedByDecisionId,
  });

  final DepositPlan plan;
  final PlanInputs inputs;

  /// 이미 등록됐으면 그 결정 id.
  final String? consumedByDecisionId;
}

/// 접수증 문장(`CommandReceipt.stateLabel` · 엔진 문장 — 기록·보류는 픽스처 `m7_deposit_register_receipts_5` 그대로).
abstract final class DepositRegisterTexts {
  static const String executed = '기록됨 — 실입금 등록이 원장에 남았습니다';
  static const String held = '보류됨 — 원장 무결성 점검 중이라 보관했습니다';
  static const String rejectedHead = '거부됨 — ';
  static const String notFound = '이 계획을 찾을 수 없습니다. 다시 계산해 새 계획을 받아 주세요.';
  static const String alreadyRegistered =
      '이 계획은 이미 등록되었습니다. 같은 입금을 두 번 기록하지 않습니다.';
}

/// 입금 결정의 전략 id(13 §8 R12 확정 · 입금은 슬리브를 가로지르는 포트폴리오 단위).
const String kDepositStrategyId = 'P0S';

/// 입금 결정 id = `DEP-{plan_id}`(13 §8 R12 확정 — `DEP-{trade_date}` 는 하루 두 입금이면 겹친다).
/// 🆕 E10a — 형식은 [DecisionIds.deposit] 한 곳에 있다(04 §3-2 v2.38 표 · 구성 요소 검사 포함).
String depositDecisionId(String planId) => DecisionIds.deposit(planId);

/// 등록 판정.
sealed class DepositRegisterOutcome {
  const DepositRegisterOutcome();

  CommandState get state;
  String get stateLabel;
}

/// 기록한다 — [entry] 를 한 트랜잭션으로 남긴다.
final class DepositRegisterExecuted extends DepositRegisterOutcome {
  const DepositRegisterExecuted(this.entry);

  final DepositLedgerEntry entry;

  @override
  CommandState get state => CommandState.executed;

  @override
  String get stateLabel => DepositRegisterTexts.executed;
}

/// 거부한다 — 쓰는 것은 명령 감사 1행뿐이다.
final class DepositRegisterRejected extends DepositRegisterOutcome {
  const DepositRegisterRejected(this.code, this.text);

  /// `DepositRegisterRejectCodes` 의 값.
  final String code;

  /// 까닭 문장(«거부됨 — » 뒤).
  final String text;

  @override
  CommandState get state => CommandState.rejected;

  @override
  String get stateLabel => '${DepositRegisterTexts.rejectedHead}$text';
}

/// 보류한다(원장 무결성 점검 중) — 아무것도 쓰지 않는다(수송이 다시 건넨다).
final class DepositRegisterHeld extends DepositRegisterOutcome {
  const DepositRegisterHeld();

  @override
  CommandState get state => CommandState.heldForIntegrity;

  @override
  String get stateLabel => DepositRegisterTexts.held;
}

/// 현금 행 하나(`cash_flow` · kind `DEPOSIT`).
class DepositCashRow {
  const DepositCashRow({
    required this.flowId,
    required this.accountAlias,
    required this.amount,
  });

  /// 원장 열 꼴(`cash_flow.flow_id` · `account_alias` · `amount` REAL)에서.
  factory DepositCashRow.fromColumns({
    required String flowId,
    required String? accountAlias,
    required num amount,
  }) => DepositCashRow(
    flowId: flowId,
    accountAlias: accountAlias,
    amount: _ledgerAmount(amount),
  );

  final String flowId;

  /// 계좌 별칭 — 스냅샷 매핑에 없으면 null(일반 계좌 미지정).
  final String? accountAlias;

  /// 원(> 0).
  final Decimal amount;
}

/// 등록이 남기는 값 — `decision_log` 1행 + 계좌별 `cash_flow` + 바인딩.
class DepositLedgerEntry {
  const DepositLedgerEntry({
    required this.decisionId,
    required this.planId,
    required this.tradeDate,
    required this.configHash,
    required this.reason,
    required this.cash,
  });

  final String decisionId;
  final String planId;

  /// 기준일 = 등록 시점의 KR 거래일(D10).
  final TradeDate tradeDate;

  /// 계획의 전략 해시(전략이 그 뒤 바뀌어도 «그때 계산» — R22 D13).
  final String configHash;

  /// 결정 문장(`decision_log.reason`).
  final String reason;
  final List<DepositCashRow> cash;

  String get strategyId => kDepositStrategyId;
  String get reasonCode => DecisionReasonCodes.depositRegistered;
}

/// 등록 판정(순수) — [snapshot] null = 이 파일에 그 계획이 없다 · [pensionRemaining] = 지금 남은 연금 납입 한도
/// (연 한도 − [pensionUsedInYear] · 처리 시점 KST 연도).
///
/// 기록 갈래는 [state] 의 KR 달력이 필요하다 — 없거나 범위 밖이면 [StateError](모르는 날을 지어내지 않는다).
DepositRegisterOutcome judgeDepositRegistration({
  required DepositRegisterCommand command,
  required DepositPlanSnapshot? snapshot,
  required WhatIfState state,
  required Decimal pensionRemaining,
}) {
  if (snapshot == null || snapshot.plan.planId != command.planId) {
    return const DepositRegisterRejected(
      DepositRegisterRejectCodes.planNotFound,
      DepositRegisterTexts.notFound,
    );
  }
  if (snapshot.consumedByDecisionId != null) {
    return const DepositRegisterRejected(
      DepositRegisterRejectCodes.planAlreadyRegistered,
      DepositRegisterTexts.alreadyRegistered,
    );
  }
  if (state.flag(FlagIds.ledgerIntegrity) != null) {
    return const DepositRegisterHeld();
  }
  if (state.flag(FlagIds.reconMismatch) != null) {
    return const DepositRegisterRejected(
      DepositRegisterRejectCodes.reconPending,
      DepositGateTexts.registerRecon,
    );
  }
  if (state.flag(FlagIds.ledgerFix) != null) {
    return const DepositRegisterRejected(
      DepositRegisterRejectCodes.ledgerFixPending,
      DepositGateTexts.registerLedgerFix,
    );
  }
  if (!command.requestedAt.toUtc().isBefore(snapshot.plan.expiresAt)) {
    return const DepositRegisterRejected(
      DepositRegisterRejectCodes.planExpired,
      DepositGateTexts.registerExpired,
    );
  }
  if (pensionRemaining < depositPensionShare(snapshot.plan)) {
    return const DepositRegisterRejected(
      DepositRegisterRejectCodes.pensionQuotaChanged,
      DepositGateTexts.registerPensionQuota,
    );
  }
  final ExchangeCalendar? kr = state.krCalendar;
  if (kr == null) {
    throw StateError('KR 거래소 달력이 없다 — 입금 기준일을 정할 수 없다');
  }
  return DepositRegisterExecuted(
    depositLedgerEntry(snapshot, depositTradeDate(command.requestedAt, kr)),
  );
}

/// 입금 기준일 — [requestedAt] 의 KST 날짜 · 거래일이 아니면 다음 KR 거래일(D10).
TradeDate depositTradeDate(DateTime requestedAt, ExchangeCalendar kr) {
  final DateTime k = requestedAt.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  final TradeDate day = TradeDate('${k.year}-${two(k.month)}-${two(k.day)}');
  return kr.isSession(day) ? day : kr.nextSession(day);
}

/// 계획의 B 몫(연금 계좌로 가는 돈 · 원).
Decimal depositPensionShare(DepositPlan plan) => plan.allocations
    .where((SleeveAllocation a) => a.sleeve == SleeveId.b)
    .fold(Decimal.zero, (Decimal s, SleeveAllocation a) => s + a.amount);

/// 계획의 계좌별 금액 — B 몫 → 연금 별칭 · 나머지(A · C · 원화 대기) → 일반 별칭(스냅샷 매핑 · 0 인 계좌는 뺀다).
List<DepositAccountAmount> depositAccountSplit(DepositPlanSnapshot snapshot) {
  final DepositPlan plan = snapshot.plan;
  final Decimal pension = depositPensionShare(plan);
  final Decimal general = plan.depositAmount - pension;
  if (pension < Decimal.zero || general < Decimal.zero) {
    throw StateError('${plan.planId} — 계좌 몫이 음수다(연금 $pension · 일반 $general)');
  }
  return <DepositAccountAmount>[
    if (pension > Decimal.zero)
      DepositAccountAmount(
        role: DepositAccountRole.pension,
        accountAlias: snapshot.inputs.pensionAlias,
        amount: pension,
      ),
    if (general > Decimal.zero)
      DepositAccountAmount(
        role: DepositAccountRole.general,
        accountAlias: snapshot.inputs.generalAlias,
        amount: general,
      ),
  ];
}

/// 입금이 가는 계좌의 역할.
enum DepositAccountRole {
  pension('PENSION'),
  general('GENERAL');

  const DepositAccountRole(this.suffix);

  /// flow_id 꼬리(`{decision_id}-PENSION|GENERAL` · R12).
  final String suffix;
}

/// 계좌 하나의 금액.
class DepositAccountAmount {
  const DepositAccountAmount({
    required this.role,
    required this.accountAlias,
    required this.amount,
  });

  final DepositAccountRole role;
  final String? accountAlias;
  final Decimal amount;
}

/// 원장에 남길 값 — 금액은 스냅샷 · 계좌는 스냅샷 매핑 · 기준일은 [tradeDate].
DepositLedgerEntry depositLedgerEntry(
  DepositPlanSnapshot snapshot,
  TradeDate tradeDate,
) {
  final DepositPlan plan = snapshot.plan;
  final String decisionId = depositDecisionId(plan.planId);
  final List<DepositCashRow> cash = <DepositCashRow>[
    for (final DepositAccountAmount a in depositAccountSplit(snapshot))
      DepositCashRow(
        flowId: '$decisionId-${a.role.suffix}',
        accountAlias: a.accountAlias,
        amount: a.amount,
      ),
  ];
  final String split = <String>[
    for (final DepositCashRow r in cash)
      '${r.accountAlias ?? '계좌 미지정'} ${wonText(r.amount)}',
  ].join(' · ');
  return DepositLedgerEntry(
    decisionId: decisionId,
    planId: plan.planId,
    tradeDate: tradeDate,
    configHash: plan.configHash,
    reason: '실입금 ${wonText(plan.depositAmount)} 등록 — 계획 ${plan.planId}($split)',
    cash: cash,
  );
}

/// 접수증 — [command] 의 봉투 + [outcome] 의 상태·문장·사유 코드.
CommandReceipt depositReceipt(
  DepositRegisterCommand command,
  DepositRegisterOutcome outcome,
) => CommandReceipt(
  commandId: command.commandId,
  kind: CommandKind.depositRegister,
  state: outcome.state,
  stateLabel: outcome.stateLabel,
  requestedAt: command.requestedAt,
  expiresAt: command.expiresAt,
  nonce: command.nonce,
  issuedByDeviceId: command.issuedByDeviceId,
  rejectReasonCode: switch (outcome) {
    DepositRegisterRejected(:final String code) => code,
    DepositRegisterExecuted() || DepositRegisterHeld() => null,
  },
);

/// 원장 현금 행 한 줄(누계 계산의 입력 · `cash_flow` 의 필요한 칸만).
class LedgerCashRow {
  const LedgerCashRow({
    required this.kind,
    required this.accountAlias,
    required this.amount,
    required this.tradeDate,
    this.recordedAt,
  });

  /// 원장 열 꼴(`cash_flow` 의 `kind` · `account_alias` · `amount` REAL · `trade_date` · `recorded_at` ISO UTC)에서.
  factory LedgerCashRow.fromColumns({
    required String kind,
    required String? accountAlias,
    required num amount,
    required String tradeDate,
    String? recordedAt,
  }) => LedgerCashRow(
    kind: CashFlowKind.values.firstWhere((CashFlowKind k) => k.wire == kind),
    accountAlias: accountAlias,
    amount: _ledgerAmount(amount),
    tradeDate: TradeDate(tradeDate),
    recordedAt: recordedAt == null ? null : DateTime.parse(recordedAt).toUtc(),
  );

  final CashFlowKind kind;
  final String? accountAlias;
  final Decimal amount;
  final TradeDate tradeDate;

  /// 엔진이 기록한 시각(UTC) — 없으면(옛 행) 기준일의 해로 센다.
  final DateTime? recordedAt;
}

/// `cash_flow.amount`(REAL) → 원. 🔴 원장 금액은 정수 원만 쓴다(소수점 아래를 기록하지 않는다).
Decimal _ledgerAmount(num v) => Decimal.parse(v.toString());

/// [utc] 의 KST 연도.
int kstYear(DateTime utc) => utc.toUtc().add(const Duration(hours: 9)).year;

/// 연금 납입 누계(D7) — [year](KST) 에 [pensionAlias] 계좌로 들어온 입금(`DEPOSIT`) 합 + [declaredOutside].
///
/// 🔴 연도는 등록 처리 시점(`recorded_at`)으로 센다 — 기준일(`trade_date`)은 휴장 보정이라 연말에 넣은 돈이 다음
///    해로 넘어갈 수 있다. 출금·분배금·원천징수는 납입이 아니다(빼지 않는다 — 한도는 «넣은 돈»의 합이다).
Decimal pensionUsedInYear(
  Iterable<LedgerCashRow> rows, {
  required String pensionAlias,
  required int year,
  required Decimal declaredOutside,
}) {
  Decimal sum = declaredOutside;
  for (final LedgerCashRow r in rows) {
    if (r.kind != CashFlowKind.deposit || r.accountAlias != pensionAlias) {
      continue;
    }
    final int y = r.recordedAt != null
        ? kstYear(r.recordedAt!)
        : int.parse(r.tradeDate.yyyyMmDd.substring(0, 4));
    if (y == year) sum += r.amount;
  }
  return sum;
}

/// 계좌 하나의 계획 대비 실제 차이(D8).
class DepositAccountGap {
  const DepositAccountGap({
    required this.accountAlias,
    required this.planned,
    required this.actual,
  });

  final String? accountAlias;
  final Decimal planned;
  final Decimal actual;

  /// 실제 − 계획(+ = 더 들어왔다).
  Decimal get gap => actual - planned;
}

/// «계획 대비 실제»(D8) — 계획의 계좌별 금액과 [actualByAlias](실제 계좌별 현금 증가) 를 맞대 **다른 계좌만** 돌려준다
/// (빈 목록 = 계획대로 들어왔다). 계획에 없는 계좌에 들어온 돈도 차이다.
///
/// 🔴 «실제»의 공급은 이 함수 밖이다 — 자동 모드는 브로커 잔고 대조(E10) · 안내 모드는 수기 기록(E18).
///    등록이 남긴 `cash_flow` 는 계획 금액 그대로라(«기록») 그것과 맞대면 늘 0 이다 — 넣지 않는다.
/// 🔴 표시 DTO 는 §8 미결 111 — 여기는 판정만.
List<DepositAccountGap> depositPlanVsActual(
  DepositPlanSnapshot snapshot,
  Map<String?, Decimal> actualByAlias,
) {
  final Map<String?, Decimal> planned = <String?, Decimal>{
    for (final DepositAccountAmount a in depositAccountSplit(snapshot))
      a.accountAlias: (Decimal.zero) + a.amount,
  };
  final List<String?> order = <String?>[
    ...planned.keys,
    ...(actualByAlias.keys
        .where((String? k) => !planned.containsKey(k))
        .toList()
      ..sort((String? a, String? b) => (a ?? '').compareTo(b ?? ''))),
  ];
  return <DepositAccountGap>[
    for (final String? alias in order)
      if ((actualByAlias[alias] ?? Decimal.zero) !=
          (planned[alias] ?? Decimal.zero))
        DepositAccountGap(
          accountAlias: alias,
          planned: planned[alias] ?? Decimal.zero,
          actual: actualByAlias[alias] ?? Decimal.zero,
        ),
  ];
}
