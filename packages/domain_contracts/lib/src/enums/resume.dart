// 01 §2-7 «X2 재개» 축(인벤토리 §2-7).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-7 · `planned_work.state` CHECK.
/// 🔴 X2 원칙 ① — 종단 상태는 어떤 경로로도 되살아나지 않는다.
enum PlannedWorkState {
  @JsonValue('PLANNED')
  planned('PLANNED'),
  @JsonValue('REEVALUATED')
  reevaluated('REEVALUATED'),
  @JsonValue('SUPERSEDED')
  superseded('SUPERSEDED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('DONE')
  done('DONE'),
  @JsonValue('BLOCKED')
  blocked('BLOCKED');

  const PlannedWorkState(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-7 · `resume_run.mode` CHECK.
enum ResumeMode {
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('CONSERVATIVE')
  conservative('CONSERVATIVE'),
  @JsonValue('RECOVERY_DRY')
  recoveryDry('RECOVERY_DRY'),
  @JsonValue('RECOVERY_FULL')
  recoveryFull('RECOVERY_FULL');

  const ResumeMode(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-7 · `resume_run.phase`.
/// 🔴 DDL 에 `CHECK` 가 없다 — **값 도메인의 정본이 이 열거형**이다(인벤토리 §2-7).
enum ResumePhase {
  @JsonValue('R0')
  r0('R0'),
  @JsonValue('R1')
  r1('R1'),
  @JsonValue('R2')
  r2('R2'),
  @JsonValue('R3')
  r3('R3'),
  @JsonValue('R4')
  r4('R4'),
  @JsonValue('R5')
  r5('R5'),
  @JsonValue('R6')
  r6('R6'),
  @JsonValue('R7')
  r7('R7'),
  @JsonValue('R8')
  r8('R8');

  const ResumePhase(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 🆕 v1.22(01 §31 · K10 · K49) — X2 재개 게이트 계절 A 진입 3택(엔진 core `SeasonalWindowChoice` ·
/// `resume/resume_judge.dart:345` · 값 1:1 · 🔴 타입 이름 ≠ 엔진(`ambiguous_import`) · 엔진 enum 에 wire 0 → 와이어 = 값 이름의
/// 기계적 SCREAMING_SNAKE · 엔진이 따른다 · «아무것도 안 하기» = 고르지 않음(1월 만료)).
enum SeasonalEntryChoice {
  @JsonValue('SKIP')
  skip('SKIP'),
  @JsonValue('REDUCED')
  reduced('REDUCED'),
  @JsonValue('AS_IS')
  asIs('AS_IS');

  const SeasonalEntryChoice(this.wire);

  /// JSON 표기.
  final String wire;
}
