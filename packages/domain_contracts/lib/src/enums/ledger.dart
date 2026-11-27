// 01 §2-9 «X5 정합» · §2-1(X7 신뢰) 축(인벤토리 §2-9).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-9 · `ledger_diff.pair` CHECK **재작성 N-01**(4값 → 5값).
///
/// 🔴 재작성 없이 `applicable = 0` 의 `CANON_SELF_REPORT` 행을 넣으면 CHECK 위반으로
///    보드가 4칸으로 퇴화한다. 🔴 보드 칸 수는 모드와 무관하게 **5 고정**이다.
/// 🔵 `canonSelfReport` 의 기본 심각도는 `observational` 이다(A12) — 차단은 «차이의 크기»가
///    아니라 «실사의 부재»(`SELF_AUDIT_OVERDUE`)에만 건다.
/// 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도
///    주문을 막지 않는다**.
enum LedgerPair {
  @JsonValue('CANON_BROKER')
  canonBroker('CANON_BROKER'),
  @JsonValue('CANON_SUPABASE')
  canonSupabase('CANON_SUPABASE'),
  @JsonValue('CANON_GITHUB')
  canonGithub('CANON_GITHUB'),
  @JsonValue('CANON_CALENDAR')
  canonCalendar('CANON_CALENDAR'),
  @JsonValue('CANON_SELF_REPORT')
  canonSelfReport('CANON_SELF_REPORT');

  const LedgerPair(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-9 · `ledger_diff.axis` CHECK.
enum LedgerAxis {
  @JsonValue('QUANTITY')
  quantity('QUANTITY'),
  @JsonValue('EXECUTION_ROW')
  executionRow('EXECUTION_ROW'),
  @JsonValue('CASH')
  cash('CASH'),
  @JsonValue('CHAIN_HASH')
  chainHash('CHAIN_HASH');

  const LedgerAxis(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-9 · `ledger_diff.severity` CHECK.
enum DiffSeverity {
  @JsonValue('BLOCKING')
  blocking('BLOCKING'),
  @JsonValue('OBSERVATIONAL')
  observational('OBSERVATIONAL');

  const DiffSeverity(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-9 · `ledger_diff.status` CHECK.
enum DiffStatus {
  @JsonValue('OPEN')
  open('OPEN'),
  @JsonValue('RESOLVED')
  resolved('RESOLVED'),
  @JsonValue('ACCEPTED')
  accepted('ACCEPTED');

  const DiffStatus(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-9 — 복구 경로. DDL 대응 컬럼이 없는 **뷰모델 파생값**이다.
/// 🔴 `x1Emergency` ↔ `'X1_EMERGENCY'` — 숫자를 낀 camelCase 의 표기 규약을 여기서 못 박는다
///    (`m2-8_naming.md` B-5 · `X_1_EMERGENCY` 가 아니다).
enum RepairRoute {
  @JsonValue('AUTO')
  auto('AUTO'),
  @JsonValue('APPROVAL')
  approval('APPROVAL'),
  @JsonValue('X1_EMERGENCY')
  x1Emergency('X1_EMERGENCY');

  const RepairRoute(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 01 §2-1(X7) — 원장을 얼마나 믿을 수 있는가.
///
/// 🔴 배너·리포트 헤더·안내 발행 범위의 유일한 근거다.
/// 🔴 `selfReported` 는 **실패가 아니라 정상 운영 상태**다 — 키 없이 도는 것이 요구의 핵심이다.
enum LedgerTrustGrade {
  @JsonValue('RECONCILED')
  reconciled('RECONCILED'),
  @JsonValue('SELF_REPORTED')
  selfReported('SELF_REPORTED'),
  @JsonValue('DRIFTING')
  drifting('DRIFTING'),
  @JsonValue('UNVERIFIABLE')
  unverifiable('UNVERIFIABLE');

  const LedgerTrustGrade(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 🆕 v1.42(01 §51 · 미결 256) — `L-3` 정기 실사 한 건의 **현금 축 판정**(`self_report_balance.cash_check`).
///
/// 🔴 제출 순간 엔진이 정해 실사 행에 같이 적는다 — 결과 빈 문장 · 0오차는 이 값을 읽는다(나중 설정 · 표식으로
///    다시 정하지 않는다). 화면 · VM · 표본 = 0(엔진 · 원장 전용).
enum SelfReportCashCheck {
  /// 허용 오차로 대조했다(차이가 넘으면 `CASH` 관측 차이 행이 같이 선다).
  @JsonValue('COMPARED')
  compared('COMPARED'),

  /// 허용 오차 값도 `SELF_AUDIT_PATTERN_UNVERIFIED` 표식도 없어 대조하지 않았다.
  @JsonValue('NO_TOLERANCE')
  noTolerance('NO_TOLERANCE'),

  /// 그 계좌의 기준일 원장 현금을 셀 수 없어 대조하지 않았다(계좌 모를 현금 · 체결).
  @JsonValue('LEDGER_UNKNOWN')
  ledgerUnknown('LEDGER_UNKNOWN');

  const SelfReportCashCheck(this.wire);

  /// DDL 표기.
  final String wire;
}

/// 01 §2-1 · X7 ㊲ — **매매가 아닌데 원장을 바꾸는 사실**(계약 v1.10 · 설계 13 §8 R21 · `m2-8_naming.md`
/// A-15 · J-6 이름 그대로).
///
/// 🔴 네 값의 효과가 다르다 — 인출 = 현금 − · TWR 외부 흐름 / 분배금 = 현금 + · 수익 /
///    원천징수 = 현금 − · 비용 / 기업행위 = 수량 × 비율(현금 없음 · 병합 단주 대금만).
///    현금 효과는 엔진이 같은 트랜잭션에서 `cash_flow` 로 투영한다([CashFlowKind] · R21 L1).
/// 🔴 채택되지 않았다면 인출·분배금·기업행위·원천징수가 원장 밖에 남아 현금 추정이 단조적으로
///    어긋나고 그 위에서 안내 수량이 계산된다(J-6 조문).
enum LedgerEventKind {
  @JsonValue('WITHDRAWAL')
  withdrawal('WITHDRAWAL'),
  @JsonValue('DISTRIBUTION')
  distribution('DISTRIBUTION'),
  @JsonValue('CORPORATE_ACTION')
  corporateAction('CORPORATE_ACTION'),
  @JsonValue('TAX_WITHHELD')
  taxWithheld('TAX_WITHHELD');

  const LedgerEventKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// ㊲ 기업행위의 v1 범위 — **분할·병합만**(설계 13 §8 R21 L5).
///
/// 🔴 합병·상장폐지·권리는 종목 자체가 바뀌므로 `CORPORATE_ACTION_UNSUPPORTED` 로 거부하고
///    `L-3` 실사로 원장을 다시 세운다.
enum CorporateActionType {
  @JsonValue('SPLIT')
  split('SPLIT'),
  @JsonValue('REVERSE_SPLIT')
  reverseSplit('REVERSE_SPLIT');

  const CorporateActionType(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// `cash_flow.kind` — 매매가 아닌 현금 이동 전부(설계 13 §8 R21 L1 · 계약 v1.10).
///
/// 🔴 **현금 = `Σ cash_flow + Σ executions`** 두 갈래로 순진한 SUM 이 옳다 — 원장 사건의 현금 효과를
///    별도 표에 두지 않는 이유다(현금이 틀리면 안내 수량이 조용히 줄어든다).
/// 🔴 대가: TWR·MWR 의 **외부 흐름**은 이 중 일부뿐이다 — 판정은 [CashFlowKindIsExternal.isExternal]
///    **하나로만** 한다(분배금·원천징수·단주 대금은 수익·비용이지 외부 흐름이 아니다).
enum CashFlowKind {
  @JsonValue('DEPOSIT')
  deposit('DEPOSIT'),
  @JsonValue('WITHDRAWAL')
  withdrawal('WITHDRAWAL'),
  @JsonValue('DISTRIBUTION')
  distribution('DISTRIBUTION'),
  @JsonValue('TAX_WITHHELD')
  taxWithheld('TAX_WITHHELD'),
  @JsonValue('CASH_IN_LIEU')
  cashInLieu('CASH_IN_LIEU');

  const CashFlowKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// TWR·MWR 의 «외부 현금흐름» 판정의 **유일한** 창구(설계 13 §8 R21 L1).
///
/// 🔴 `default:` 없는 망라 switch 다 — 값이 늘면 컴파일이 깨져 판정을 다시 하게 만든다(C-12).
extension CashFlowKindIsExternal on CashFlowKind {
  bool get isExternal => switch (this) {
    CashFlowKind.deposit || CashFlowKind.withdrawal => true,
    CashFlowKind.distribution ||
    CashFlowKind.taxWithheld ||
    CashFlowKind.cashInLieu => false,
  };
}

// ✅ `CORPORATE_ACTION` vs `CORP_ACTION` = **`CORPORATE_ACTION` 으로 통합**(계약 v1.9.0 · R19 E9-4 ·
//    인벤토리 §10-2 ③ 해소). 픽스처·신규 코드는 `CORPORATE_ACTION` 만 쓴다.
