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

// ⏸ `LedgerEventKind { withdrawal, distribution, corporateAction, taxWithheld }`
//    → 'WITHDRAWAL'·'DISTRIBUTION'·'CORPORATE_ACTION'·'TAX_WITHHELD'
//
// 🔴 **결정 ㊲ 채택 시에만 신설한다.** 지금은 주석으로만 남기고 코드로 만들지 않는다
//    (01 §2-1 ⏸ 원문 · `m2-8_naming.md` A-15 · J-6 · 인벤토리 §2-9).
//    이름은 확정됐고 기능만 대기다 — 함께 대기 중인 것이 `CommandKind.ledgerEventRecord`·
//    `CommandApi.recordLedgerEvent(LedgerEventRecord)` 다.
// ⚠️ 채택되지 않으면 인출·분배금·기업행위·원천징수가 원장 밖에 남아 현금 추정이 단조적으로
//    어긋나고 그 위에서 안내 수량이 계산된다(J-6 조문).
// ✅ 결정 ㊲ 은 **채택**됐다(설계 13 §8 R19 E9-7). 다만 저장 자리·DTO 필드·거부 코드가 아직 없어
//    이 열거형과 명령은 **E9a2**(설계안 → 발주자 확인 · v1 동결 전 · R20 Q3)에서 함께 만든다.
// ✅ `CORPORATE_ACTION` vs `CORP_ACTION` = **`CORPORATE_ACTION` 으로 통합**(계약 v1.9.0 · R19 E9-4 ·
//    인벤토리 §10-2 ③ 해소). 픽스처·신규 코드는 `CORPORATE_ACTION` 만 쓴다.
