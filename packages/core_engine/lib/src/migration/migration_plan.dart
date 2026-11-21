// X1-2 계획 교체 — 이전 시작 판정 · 옛 폰 단계 상태기계 · 단계 완료 조건 · 동결 리스 합성
// (순수 · 설계 13 §8 R117 B1~B5 · B7 · SPEC v2.45 04 §3-1 ①②⑦ · 02 §2-6 `migration_run` · `migration_step`).
//
// 🔴 `D-03` 오프라인 긴급정지 카드 확인 = 이전 **시작 전** 필수(`migration_run.decision_id`) — 단계가 아니다(B2).
// 🔴 옛 폰 단계 9 — 동결 → 미체결 · UNKNOWN 정리 → 대사 0 → 체크섬 백업 → DEMOTED → 키 삭제 → RETIRED → 종료 → 티켓.
//    단계마다 ENTERED → DONE | FAILED · ENTERED 만 = 크래시 → 같은 단계 멱등 재개(02 «목록은 코드가 정본»).
// 🔴 되돌릴 수 없는 점 = DEMOTED — 그 앞 FAILED = 이 이전 중단(동결 풀림) · DEMOTED 부터 FAILED 행 = 깨진 저널(`StateError`).
// 🔴 시각 = 신뢰 시각 · 모르면 시작하지 않는다.

import 'package:domain_contracts/domain_contracts.dart'
    show
        OperatingMode,
        RunMode,
        SafetyCommonResultCodes,
        X1KindCodes,
        X1RoleCodes,
        X1StartResultCodes,
        X1StepBlockCodes,
        X1StepCodes,
        X1StepStateCodes;

import '../ops/lease_gate.dart' show LeaseVerdict;
import '../ops/ledger_views.dart' show kstDateText;

/// 이전 갈래(02 `migration_run.kind`).
enum MigrationKind {
  /// 계획 교체(X1-2 — 옛 폰이 옆에 있다).
  plan(X1KindCodes.plan),

  /// 비상(X1-3 — 옛 폰을 잃었다 · E16c).
  emergency(X1KindCodes.emergency);

  const MigrationKind(this.wire);

  /// 저장 글자.
  final String wire;
}

/// 이 파일 기기의 역할(02 `migration_run.role`).
enum MigrationRole {
  /// 옛 폰.
  oldDevice(X1RoleCodes.oldDevice),

  /// 새 폰.
  newDevice(X1RoleCodes.newDevice);

  const MigrationRole(this.wire);

  /// 저장 글자.
  final String wire;
}

/// 단계 행 상태(02 `migration_step.state`).
enum MigrationStepState {
  /// 들어감.
  entered(X1StepStateCodes.entered),

  /// 끝남.
  done(X1StepStateCodes.done),

  /// 실패(DEMOTED 앞에서만).
  failed(X1StepStateCodes.failed);

  const MigrationStepState(this.wire);

  /// 저장 글자.
  final String wire;

  /// 저장 글자 → 값(모르면 [FormatException]).
  static MigrationStepState parse(String w) => values.firstWhere(
    (MigrationStepState s) => s.wire == w,
    orElse: () => throw FormatException('migration_step.state', w),
  );
}

/// 옛 폰 계획 교체 단계(R117 B3 — 차례 = 선언 차례).
enum PlanStep {
  /// 신규 주문 동결(리스 합성 무효 · 감시 유지보수 창 개시).
  freeze(X1StepCodes.freeze),

  /// 미체결 0 ∧ UNKNOWN 0(터미널 상태 도달까지 잠금).
  ordersCleared(X1StepCodes.ordersCleared),

  /// 최종 대사 0오차.
  reconZero(X1StepCodes.reconZero),

  /// 체크섬 백업(매니페스트 chain = 지금 체인).
  backupChecksum(X1StepCodes.backupChecksum),

  /// 🔴 로컬 DEMOTED 표시(최선두 · 되돌릴 수 없는 점).
  demoted(X1StepCodes.demoted),

  /// 키 삭제.
  keysDeleted(X1StepCodes.keysDeleted),

  /// RETIRED 서명.
  retired(X1StepCodes.retired),

  /// 서비스 종료.
  serviceStopped(X1StepCodes.serviceStopped),

  /// 이전 티켓 발급(강등 끝난 뒤에만).
  ticketIssued(X1StepCodes.ticketIssued);

  const PlanStep(this.wire);

  /// 저장 글자(`migration_step.step`).
  final String wire;

  /// 실패를 적을 수 있나 — DEMOTED 앞만(R117 B4).
  bool get mayFail => index < PlanStep.demoted.index;

  /// 저장 글자 → 값(모르면 [FormatException]).
  static PlanStep parse(String w) => values.firstWhere(
    (PlanStep s) => s.wire == w,
    orElse: () => throw FormatException('migration_step.step', w),
  );
}

/// 이전 시작 거부 코드(R117 B2 · B5 — 글자 = 계약 `X1StartResultCodes` ∪ 공용 `SafetyCommonResultCodes` 참조 · 미결 212).
abstract final class MigrationStartCodes {
  /// live 파일이 아니다(D17 — 체험 중 폰 교체 = 모의 폐기 + 새 개시).
  static const String liveOnly = X1StartResultCodes.liveOnly;

  /// 안내 모드 기기 이전 = 조건 결정 대기 hold(D15).
  static const String advisoryPending = X1StartResultCodes.advisoryPending;

  /// 계획 교체인데 `D-03` 확인 결정이 없다.
  static const String d03NotConfirmed = X1StartResultCodes.d03NotConfirmed;

  /// 비상인데 선언 결정이 없다.
  static const String emergencyNotDeclared =
      X1StartResultCodes.emergencyNotDeclared;

  /// 신뢰 시각 모름.
  static const String trustedTimeUnknown =
      SafetyCommonResultCodes.trustedTimeUnknown;
}

/// 🔴 이전 시작 판정 — 거부 코드(차례대로 첫 하나) · 통과 = null.
String? migrationStartRejectCode({
  required MigrationKind kind,
  required RunMode runMode,
  required OperatingMode operatingMode,
  required String? decisionId,
  required DateTime? trustedNowUtc,
}) {
  if (runMode != RunMode.live) return MigrationStartCodes.liveOnly;
  if (operatingMode == OperatingMode.advisory) {
    return MigrationStartCodes.advisoryPending;
  }
  if (decisionId == null || decisionId.trim().isEmpty) {
    return switch (kind) {
      MigrationKind.plan => MigrationStartCodes.d03NotConfirmed,
      MigrationKind.emergency => MigrationStartCodes.emergencyNotDeclared,
    };
  }
  if (trustedNowUtc == null) return MigrationStartCodes.trustedTimeUnknown;
  return null;
}

/// 이전 id — `mig-{시작 한국 날}-{순번}`(02 §2-6).
String migrationRunIdOf(DateTime trustedNowUtc, int seq) {
  if (seq < 1) throw ArgumentError.value(seq, 'seq', '1 이상');
  return 'mig-${kstDateText(trustedNowUtc)}-$seq';
}

/// `migration_step` 한 행.
class MigrationStepRow {
  /// 만든다.
  const MigrationStepRow({
    required this.runId,
    required this.step,
    required this.state,
    required this.atUtc,
  });

  /// 이전 id.
  final String runId;

  /// 단계 글자.
  final String step;

  /// 상태 글자.
  final String state;

  /// 시각(UTC).
  final DateTime atUtc;
}

/// 옛 폰 이전 진행(저널을 읽은 결과).
class PlanProgress {
  const PlanProgress._({
    required this.runId,
    required this.lastDone,
    required this.inFlight,
    required this.failed,
  });

  /// 이전 id.
  final String runId;

  /// 마지막으로 끝난 단계(없음 = null).
  final PlanStep? lastDone;

  /// 들어갔지만 끝나지 않은 단계(크래시 · 진행 중).
  final PlanStep? inFlight;

  /// 실패한 단계(= 이 이전 중단).
  final PlanStep? failed;

  /// [step] 이 끝났나.
  bool isDone(PlanStep step) =>
      lastDone != null && lastDone!.index >= step.index;

  /// 동결이 걸려 있나 — FREEZE 들어감 ∧ 중단 아님.
  bool get frozen => failed == null && (lastDone != null || inFlight != null);

  /// 되돌릴 수 없는 점을 넘었나(DEMOTED 들어감).
  bool get pastNoReturn =>
      (inFlight != null && inFlight!.index >= PlanStep.demoted.index) ||
      (lastDone != null && lastDone!.index >= PlanStep.demoted.index);

  /// 끝까지 갔나(티켓 발급 끝).
  bool get complete => lastDone == PlanStep.ticketIssued;
}

/// 🔴 저널 → 진행 — 차례 · 구멍 · DONE 없이 다음 · DEMOTED 뒤 실패 = [StateError].
///
/// [rows] 는 이 기기의 이 이전([runId]) 행이어야 한다(다른 이전 행 = [StateError]).
PlanProgress planProgressOf(String runId, Iterable<MigrationStepRow> rows) {
  final Map<PlanStep, Set<MigrationStepState>> seen =
      <PlanStep, Set<MigrationStepState>>{};
  for (final MigrationStepRow r in rows) {
    if (r.runId != runId) {
      throw StateError('다른 이전의 단계 행이 섞였다: ${r.runId}');
    }
    final PlanStep s = PlanStep.parse(r.step);
    final MigrationStepState st = MigrationStepState.parse(r.state);
    if (!(seen[s] ??= <MigrationStepState>{}).add(st)) {
      throw StateError('같은 단계 같은 상태가 둘이다: ${s.wire} ${st.wire}');
    }
  }
  PlanStep? lastDone;
  PlanStep? inFlight;
  PlanStep? failed;
  for (final PlanStep s in PlanStep.values) {
    final Set<MigrationStepState>? st = seen[s];
    if (st == null) {
      final bool later = PlanStep.values
          .skip(s.index + 1)
          .any(seen.containsKey);
      if (later) throw StateError('이전 $runId 저널에 구멍: ${s.wire}');
      break;
    }
    if (inFlight != null || failed != null) {
      throw StateError('끝나지 않은 단계 뒤에 행이 있다: ${s.wire}');
    }
    if (!st.contains(MigrationStepState.entered)) {
      throw StateError('들어가지 않은 단계에 끝 · 실패 행: ${s.wire}');
    }
    final bool done = st.contains(MigrationStepState.done);
    final bool fail = st.contains(MigrationStepState.failed);
    if (done && fail) throw StateError('끝과 실패가 함께: ${s.wire}');
    if (fail) {
      if (!s.mayFail) {
        throw StateError('되돌릴 수 없는 점 뒤의 실패 행: ${s.wire}');
      }
      failed = s;
    } else if (done) {
      lastDone = s;
    } else {
      inFlight = s;
    }
  }
  return PlanProgress._(
    runId: runId,
    lastDone: lastDone,
    inFlight: inFlight,
    failed: failed,
  );
}

/// 다음에 할 일.
sealed class PlanNext {
  const PlanNext();
}

/// [step] 에 들어간다(ENTERED 를 먼저 적고 한다).
final class PlanEnter extends PlanNext {
  /// 만든다.
  const PlanEnter(this.step);

  /// 단계.
  final PlanStep step;
}

/// 크래시 — [step] 을 멱등으로 다시 한다(새 ENTERED 행 0).
final class PlanResume extends PlanNext {
  /// 만든다.
  const PlanResume(this.step);

  /// 단계.
  final PlanStep step;
}

/// 이 이전은 중단됐다(동결 풀림 · 다시 하려면 새 이전).
final class PlanAborted extends PlanNext {
  /// 만든다.
  const PlanAborted(this.failedStep);

  /// 실패한 단계.
  final PlanStep failedStep;
}

/// 끝 — 이전 티켓이 나갔다.
final class PlanComplete extends PlanNext {
  /// 만든다.
  const PlanComplete();
}

/// 진행 → 다음 할 일.
PlanNext planNextOf(PlanProgress p) {
  if (p.failed != null) return PlanAborted(p.failed!);
  if (p.inFlight != null) return PlanResume(p.inFlight!);
  if (p.complete) return const PlanComplete();
  final int next = p.lastDone == null ? 0 : p.lastDone!.index + 1;
  return PlanEnter(PlanStep.values[next]);
}

/// 단계 완료 조건의 재료(엔진 사실).
class PlanStepFacts {
  /// 만든다.
  const PlanStepFacts({
    required this.openOrders,
    required this.unknownOrders,
    required this.reconMismatches,
    required this.currentChainHash,
    this.backupChainHash,
  });

  /// 미체결 주문 수.
  final int openOrders;

  /// UNKNOWN 주문 수.
  final int unknownOrders;

  /// 마지막 대사 불일치 수.
  final int reconMismatches;

  /// 지금 정본 체인(마지막 스탬프 · 없으면 null).
  final String? currentChainHash;

  /// 만든 백업 매니페스트의 체인(없으면 null).
  final String? backupChainHash;
}

/// 단계 완료를 막는 이유 코드.
abstract final class PlanBlockCodes {
  /// 미체결이 남았다.
  static const String openOrders = X1StepBlockCodes.openOrders;

  /// UNKNOWN 이 남았다.
  static const String unknownOrders = X1StepBlockCodes.unknownOrders;

  /// 대사가 0오차가 아니다.
  static const String reconNotZero = X1StepBlockCodes.reconNotZero;

  /// 백업이 없다.
  static const String backupMissing = X1StepBlockCodes.backupMissing;

  /// 백업 체인이 지금 체인과 다르다.
  static const String backupChainMismatch =
      X1StepBlockCodes.backupChainMismatch;
}

/// 🔴 [step] 을 DONE 으로 적어도 되나 — 막는 이유(없음 = null). 사실이 필요 없는 단계 = 늘 null.
String? planStepBlockCode(PlanStep step, PlanStepFacts f) {
  switch (step) {
    case PlanStep.ordersCleared:
      if (f.openOrders > 0) return PlanBlockCodes.openOrders;
      if (f.unknownOrders > 0) return PlanBlockCodes.unknownOrders;
      return null;
    case PlanStep.reconZero:
      return f.reconMismatches == 0 ? null : PlanBlockCodes.reconNotZero;
    case PlanStep.backupChecksum:
      if (f.backupChainHash == null) return PlanBlockCodes.backupMissing;
      return f.backupChainHash == f.currentChainHash
          ? null
          : PlanBlockCodes.backupChainMismatch;
    case PlanStep.freeze:
    case PlanStep.demoted:
    case PlanStep.keysDeleted:
    case PlanStep.retired:
    case PlanStep.serviceStopped:
    case PlanStep.ticketIssued:
      return null;
  }
}

/// 🔴 동결 리스 합성(SPEC 04 §3-1 v2.45 ① · R117 B7) — 동결 중이면 주문용 리스 판정 = 무효.
///
/// 파생 쓰기(백업 커밋 · 아카이브)는 이 합성을 쓰지 않는다(원래 판정 그대로).
LeaseVerdict orderLeaseDuringMigration(LeaseVerdict base, PlanProgress? p) =>
    p != null && p.frozen ? LeaseVerdict.invalid : base;
