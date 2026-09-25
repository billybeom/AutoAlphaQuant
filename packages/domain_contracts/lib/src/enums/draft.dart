// 01 §12-1 — 🆕 계약 v1.2. 기기 로컬 초안 포트(`DraftStore`)의 «종류» 축.
//
// 🔴 이 열거형은 **영역 A 가 소유**하고 `lib/src/commands/` 는 import 만 한다(command.dart 머리와 같은 규칙).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 초안을 둘 수 있는 입력 폼의 종류.
///
/// 🔴 **Dart 이름과 JSON 표기가 [CommandKind] 의 같은 이름 값과 똑같다**(C-35 ②) — 초안은 그 명령의
///    전 단계다. X7 4종의 어순 비대칭(`manualFillRecord` ↔ `'RECORD_MANUAL_FILL'`)도 그대로 물려받는다.
/// 🔴 **영구 제외 6종** — `BLIND_REVIEW_SCORE`(`J-4` 는 «제출 전 뒤로가기 = 점수 미저장»이 수용 기준 ·
///    02 §3-4 (b)) · `KILL_SWITCH_ACTIVATE` · `DISCLOSURE_VIEW` · `DEPOSIT_REGISTER` · `ALERT_ACK` ·
///    `KILL_CHECKLIST_CONFIRM`(확인·즉시성 명령). C-35 ② 가 막는다.
/// ⏸ `M5-12` 정정·무효(`manualFillAmend`·`manualFillVoid`)는 M5 창이 본문 DTO 와 함께 더한다.
enum DraftKind {
  @JsonValue('JOURNAL_DRAFT')
  journalDraft('JOURNAL_DRAFT'),
  @JsonValue('RECORD_MANUAL_FILL')
  manualFillRecord('RECORD_MANUAL_FILL'),
  @JsonValue('SKIP_ADVICE')
  adviceSkip('SKIP_ADVICE'),
  @JsonValue('SELF_REPORT_BALANCE')
  selfReportBalance('SELF_REPORT_BALANCE');

  const DraftKind(this.wire);

  /// JSON 표기. 🔴 `CommandKind.values.byName(name).wire` 와 같다(C-35 ②).
  final String wire;
}
