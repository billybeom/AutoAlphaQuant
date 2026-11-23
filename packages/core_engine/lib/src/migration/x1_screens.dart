// X1 기기 이전 화면 VM 생산 · 결과 글자(E16j-b · 01 §42 K264~K281 · 미결 218 ⓐ · 표본 `x1/*`).
//
// 🔴 글자 = 엔진(표본 문장에서 «(합성)»만 뺀 것) · 표본에 없는 막힘 문장 = 무엇이 없어서 막혔는지 사실만.
// 🔴 수치 새로 정함 0 — 관찰 n/m = 게이트 판정(`migrationGateOf`) 글자 · 감시 창 = 열린 시각만(넘김 시간 0) · 티켓 = 만료 절대 시각.
// 🔴 옛 폰 진행 = [kX1PlanOpenThrough](3단계 «대사 0»)까지만 연다 — 4단계(체크섬 백업)가 끝나면 그만두기 길이 사라지고(저널 R117 B4 ·
//    DEMOTED 앞 FAILED 만) 5단계 DEMOTED = 되돌릴 수 없는 점인데 그 뒤 길(새 폰이 백업 바이트를 받는 곳 D9 · RETIRED 서명 E11k ·
//    티켓 논스 ↔ `lease_claim` 미결 218 ⓕ)이 아직 없다 → 4단계 행 = 막힘 문장 + 그만두기만.
// 🔴 새 폰 = 복원 원천(D9) · 비상 펜싱 · 재발급 저장(E16t3c) · 새 복구 코드(E11k-e3) 전 = 막힘 문장 VM(시작 동작 · 슬롯 0).
// 🔴 동작 = 엔진이 완성한 `SafetyActionCall`(args 의 `run_id` = 저널) · 잠김 · 끝 = 동작 · 슬롯 0.

import 'package:domain_contracts/domain_contracts.dart';

import '../ops/ledger_views.dart' show kstDateText, kstMinuteText;
import 'backup_manifest.dart' show BackupManifest;
import 'migration_gate.dart' show MigrationGateState, MigrationGateVerdict;
import 'migration_plan.dart'
    show
        MigrationKind,
        PlanAborted,
        PlanComplete,
        PlanEnter,
        PlanNext,
        PlanProgress,
        PlanResume,
        PlanStep,
        PlanStepFacts,
        planNextOf,
        planStepBlockCode;
import 'recovery_steps.dart' show RecoveryStep;

/// 🔴 옛 폰에서 지금 열린 마지막 단계(그 뒤 = 막힘 행 · 동작 = 그만두기만).
///
/// 여는 조건(미결 218 ⓑ ⓔ ⓕ) — 새 폰 백업 바이트 원천(D9) · RETIRED 서명(E11k) · 티켓 논스 ↔ `lease_claim`이 생긴 뒤 한꺼번에
/// [PlanStep.ticketIssued] 로 올린다(4단계만 따로 열면 되돌릴 수 없는 점 앞에서 멈출 길이 없다).
const PlanStep kX1PlanOpenThrough = PlanStep.reconZero;

/// [step] 을 이 앱에서 진행할 수 있나.
bool x1PlanStepOpen(PlanStep step) => step.index <= kX1PlanOpenThrough.index;

/// 이전 화면 기준 유효 시간(표본 26시간).
const Duration kX1ScreenStaleAfter = Duration(hours: 26);

/// X1 화면 글자(엔진 · 표본 `x1/*` 에서 «(합성)»만 뺀 것 + 막힘 문장).
abstract final class X1ScreenTexts {
  // ── 옛 폰 ──
  /// 시작 전 머리.
  static const String d03Headline = '이전을 시작하기 전에 긴급정지 카드를 한 번 봅니다';

  /// 시작 버튼.
  static const String start = '봤습니다 — 이전 시작';

  /// 모의 거부.
  static const String liveOnly = '모의투자 중에는 기기 이전을 하지 않습니다 — 새 폰에서 새로 시작하십시오';

  /// 안내 모드 hold.
  static const String advisoryPending = '안내 모드의 기기 이전은 조건이 정해지지 않았습니다 — 기다립니다';

  /// 저널 깨짐.
  static const String journalBroken =
      '이전 기록을 읽을 수 없습니다 — 이 폰에서는 이전을 더 진행하지 않습니다';

  /// 기기 id 없음.
  static const String noDevice = '이 기기를 알아보지 못했습니다 — 기기 이전을 할 수 없습니다';

  /// 진행 중.
  static const String inProgress = '이전 중입니다 — 다음 단계를 진행하십시오';

  /// 강등 뒤.
  static const String demoted = '이 폰은 강등됐습니다 — 남은 단계를 마치십시오';

  /// 열린 단계를 다 마쳤다.
  static const String closedHeadline = '4단계부터는 아직 열리지 않았습니다 — 여기서 이전을 그만두십시오';

  /// 4단계 이후 막힘 줄.
  static const String closedLine =
      '체크섬 백업을 마치면 그만둘 수 없는데, 그 뒤 강등 · 은퇴 서명 · 티켓 · 새 폰 백업 받기 길이 아직 없습니다';

  /// 끝(티켓).
  static const String complete = '새 폰에서 이 QR 을 읽으십시오';

  /// 티켓 카드 머리.
  static const String ticketHeadline = '이전 티켓';

  /// 티켓 만료(절대 시각).
  static String ticketExpires(String hhmm) => '$hhmm 까지 유효';

  /// 티켓 줄.
  static String ticketLine(String backupDay, String chain8) =>
      '백업 $backupDay · 체인 $chain8';

  /// 단계 이름(차례 = [PlanStep]).
  static const List<String> planStepNames = <String>[
    '주문 동결',
    '미체결 정리',
    '대사 0',
    '백업 · 체크섬',
    '강등',
    '키 삭제',
    '은퇴 서명',
    '서비스 종료',
    '티켓 발급',
  ];

  /// 단계 제목.
  static String stepTitle(int n, String name) => '$n $name';

  /// 끝.
  static const String stateDone = '끝';

  /// 막힘.
  static const String stateBlocked = '막힘';

  /// 대기.
  static const String stateWaiting = '대기';

  /// 차례.
  static const String stateTurn = '차례';

  /// 실패.
  static const String stateFailed = '실패';

  /// DEMOTED 줄.
  static const String noReturn = '여기부터 되돌릴 수 없습니다';

  /// 단계 진행 버튼.
  static const String stepRun = '이 단계 진행';

  /// 그만두기 버튼.
  static const String abort = '이전 그만두기';

  /// 미체결 머리.
  static const String openOrdersHeadline = '미체결 주문이 남아 있습니다';

  /// 미체결 줄.
  static String openOrdersLine(int n) => '미체결 $n건 — 체결 또는 취소를 기다립니다';

  /// UNKNOWN 머리.
  static const String unknownOrdersHeadline = '결과를 모르는 주문이 남아 있습니다';

  /// UNKNOWN 줄.
  static String unknownOrdersLine(int n) => '확인 중 주문 $n건 — 결과가 정해지기를 기다립니다';

  /// 대사 머리.
  static const String reconHeadline = '증권사 대사가 맞지 않습니다';

  /// 대사 줄.
  static const String reconLine = '대사 불일치가 풀리기를 기다립니다';

  /// 감시 창(열린 시각만).
  static String window(String openedMinute) =>
      '감시 일시정지 — $openedMinute 열림 · 넘기면 알림';

  /// D6 유예 경고.
  static const String graceLine = '유예 안에 새 폰 복원을 마치십시오';

  /// 기준 글자.
  static String asOf(String minute) => '이전 기준 $minute';

  // ── 새 폰 ──
  /// 계획 갈래.
  static const String planKind = '계획 이전';

  /// 비상 갈래.
  static const String emergencyKind = '비상 이전';

  /// 받기 막힘 머리.
  static const String planBlocked = '새 폰 받기는 아직 열리지 않았습니다';

  /// 받기 막힘 고지.
  static const String planBlockedNotice =
      '옛 폰 백업을 이 폰으로 받아 올 길이 아직 없습니다 — 백업을 올리는 곳이 정해진 뒤 엽니다';

  /// 비상 막힘 머리.
  static const String emergencyBlocked = '비상 복구는 아직 열리지 않았습니다';

  /// 비상 막힘 고지.
  static const String emergencyBlockedNotice =
      '옛 폰 권한 회수 · 새 복구 코드 · 키 재발급 기록을 이을 곳과 백업을 받아 올 길이 아직 없습니다';

  /// 복원 카드 머리.
  static const String restored = '백업을 복원했습니다';

  /// 복원 카드 줄.
  static String restoreLine(BackupManifest m) =>
      '백업 ${m.authoredDate} · 스키마 판 ${m.schemaVersion} · 해시 판 ${m.hashFormatVersion} · epoch ${m.operatorEpoch}';

  /// RECOVERY_FULL 머리.
  static const String recoveryFull =
      '공백이 너무 길어 기록을 이어 붙일 수 없습니다 — 잔고를 이어받아 새로 시작합니다';

  /// RECOVERY_FULL 링크.
  static const String restart = '잔고를 이어받아 새로 시작하기';

  /// 새 폰 단계 이름(차례 = [RecoveryStep]).
  static const List<String> recoveryStepNames = <String>[
    '복원',
    '공백 다시 세기',
    '골든 자가시험',
    '확인 목록',
    '생체 확인',
  ];

  /// 갭 재구성 막힘 머리.
  static const String gapBlocked = '공백 다시 세기는 아직 열리지 않았습니다';

  /// 갭 재구성 막힘 줄.
  static const String gapBlockedLine = '공백 동안의 체결을 증권사에서 받아 올 연결이 아직 이 앱에 없습니다';

  /// 골든 실행기 없음 줄.
  static const String goldenAbsentLine = '이 폰에서 골든 자가시험을 돌릴 수 없습니다';

  /// 골든 실패 줄.
  static const String goldenFailedLine = '골든 자가시험이 실패했습니다 — 다시 돌릴 수 있습니다';

  /// 관찰 머리.
  static const String observingHeadline = '실거래 재개 전 관찰 중입니다';

  /// 생체 머리.
  static const String biometricHeadline = '마지막으로 생체 확인을 합니다';

  /// 체크리스트 머리.
  static const String checklistHeadline = '관찰을 마쳤습니다 — 확인 목록을 봅니다';

  /// 골든 아직 머리.
  static const String goldenNotRunHeadline = '골든 자가시험을 돌립니다';

  /// 골든 실패 머리.
  static const String goldenFailedHeadline = '골든 자가시험이 실패했습니다';

  /// 게이트 통과 머리.
  static const String passedHeadline = '실거래 재개 게이트를 통과했습니다';

  /// 게이트 상태 글자.
  static String gateStateLabel(MigrationGateState s) => switch (s) {
    MigrationGateState.blocked => '막힘',
    MigrationGateState.observing => '관찰 중',
    MigrationGateState.awaitingApproval => '승인 대기',
    MigrationGateState.passed => '통과',
  };

  /// 관찰 n/m.
  static String observe(int n, int m) => '$n/$m 거래일';

  /// 게이트 왜.
  static String gateWhy(String? code) => switch (code) {
    X1GateReasonCodes.goldenNotRun => '골든 자가시험을 아직 돌리지 않았습니다',
    X1GateReasonCodes.goldenFailed => '골든 자가시험이 실패했습니다',
    X1GateReasonCodes.reconNotZero => '증권사 대사가 맞지 않습니다',
    X1GateReasonCodes.unknownOrders => '결과를 모르는 주문이 남아 있습니다',
    X1GateReasonCodes.openOrders => '미체결 주문이 남아 있습니다',
    X1GateReasonCodes.observing => '새 폰에서 매매 없이 며칠 지켜봅니다',
    X1GateReasonCodes.checklistPending => '관찰을 마쳤습니다',
    X1GateReasonCodes.biometricPending => '관찰과 확인 목록을 마쳤습니다',
    _ => '실거래를 다시 열 수 있습니다',
  };

  /// 게이트 할 일.
  static String? gateAction(String? code) => switch (code) {
    X1GateReasonCodes.checklistPending => '확인 목록을 보고 확인합니다',
    X1GateReasonCodes.biometricPending => '생체 확인으로 실거래를 다시 엽니다',
    _ => null,
  };

  /// 체크리스트 줄(🔴 발주자 문안 전 — 게이트가 이미 보는 두 사실 · 미결 218 ⓗ).
  static const List<String> checklistLines = <String>[
    '보유 종목이 증권사와 같다',
    '미체결 주문이 없다',
  ];

  // ── 결과 ──
  /// 접수 글자.
  static String accepted(SafetyActionId id) => switch (id) {
    SafetyActionId.x1PlanStart => '이전을 시작했습니다',
    SafetyActionId.x1PlanStep => '단계를 마쳤습니다',
    SafetyActionId.x1PlanAbort => '이전을 그만뒀습니다',
    SafetyActionId.x1EmergencyStart => '비상 복구를 시작했습니다',
    SafetyActionId.x1ReissueRecord => '새 값을 기록했습니다',
    SafetyActionId.x1RecoveryStep => '복구 단계를 마쳤습니다',
    _ => throw ArgumentError.value(id, 'id', 'X1 동작이 아니다'),
  };

  /// 거부 글자(코드 → 문장 · 모르는 코드 = 일반 문장).
  static String rejected(String code) => switch (code) {
    X1StartResultCodes.liveOnly => '모의투자 중에는 기기 이전을 하지 않습니다',
    X1StartResultCodes.advisoryPending => advisoryPending,
    X1StartResultCodes.d03NotConfirmed => '긴급정지 카드 확인이 없습니다',
    X1StartResultCodes.emergencyNotDeclared => '비상 선언이 확인되지 않았습니다',
    SafetyCommonResultCodes.trustedTimeUnknown =>
      '믿을 수 있는 시각을 모릅니다 — 연결 뒤 다시 하십시오',
    X1JournalResultCodes.runExists => '이 폰에 끝나지 않은 이전이 있습니다',
    X1JournalResultCodes.stepOutOfOrder => '지금 차례의 단계가 아닙니다',
    X1JournalResultCodes.pastNoReturn => '강등 뒤에는 되돌릴 수 없습니다',
    X1StepBlockCodes.openOrders => openOrdersHeadline,
    X1StepBlockCodes.unknownOrders => unknownOrdersHeadline,
    X1StepBlockCodes.reconNotZero => reconHeadline,
    X1StepBlockCodes.backupMissing => '체크섬 백업이 없습니다',
    X1StepBlockCodes.backupChainMismatch => '백업이 지금 기록과 다릅니다',
    X1ReissueResultCodes.keyReused => '옛 키를 다시 쓸 수 없습니다 — 새로 발급하십시오',
    X1ReissueResultCodes.notApplicable => '이 계정에서 쓰지 않는 항목입니다',
    X1ReissueResultCodes.duplicate => '이미 받은 항목입니다',
    X1ReissueResultCodes.fingerprintRequired => '새 값이 필요합니다',
    X1ReissueResultCodes.fingerprintUnexpected => '값을 받지 않는 항목입니다',
    X1FencingResultCodes.notStarted => '옛 폰 권한 회수가 아직 없습니다',
    X1FencingResultCodes.waiting => '옛 폰 권한이 끝나기를 기다립니다',
    X1RecoveryResultCodes.notRestored => '아직 복원하지 않았습니다',
    X1RecoveryResultCodes.epochNotAdvanced => '새 리스 세대가 백업보다 앞서지 않습니다',
    X1RestoreResultCodes.liveExists => '이 폰에 이미 실전 기록이 있습니다',
    X1OrderSealCodes.inProgress => '공백 다시 세기가 끝나지 않았습니다',
    X1OrderSealCodes.full => recoveryFull,
    X1GateReasonCodes.goldenFailed => goldenFailedHeadline,
    BackupResultCodes.rollback => '이 백업은 쓸 수 없습니다',
    SettingsResultCodes.biometricUnavailable => '생체 확인을 쓸 수 없습니다',
    _ => '진행하지 않았습니다',
  };
}

/// 🔴 `D-03` 오프라인 긴급정지 카드 한 장(04 §6 · 표본 `m8/emergency_card` 글자 그대로 · 인쇄 = 자리 이름만).
const EmergencyCardVm kX1D03Card = EmergencyCardVm(
  title: '자동매매 긴급 정지 카드',
  steps: <RunbookStep>[
    RunbookStep(orderText: '1.', text: '증권사 앱에 로그인합니다.'),
    RunbookStep(orderText: '2.', text: '자동주문 설정이 켜져 있으면 끕니다.'),
    RunbookStep(orderText: '3.', text: '체결되지 않은 주문을 모두 취소합니다.'),
    RunbookStep(
      orderText: '3-1.',
      text: '가진 종목은 급히 팔지 않아도 됩니다. 멈추기만 해도 충분합니다.',
    ),
    RunbookStep(orderText: '4.', text: '그래도 주문이 나가면 고객센터에 전화해 자동주문 차단을 요청합니다.'),
  ],
  contactLine: '한국투자증권 고객센터 1544-5000 · 이 시스템을 아는 사람의 연락처는 종이에 직접 적어 둡니다.',
  keepOnPaperNotice: '이 카드는 인쇄해서 가족이 아는 곳에 종이로 보관하세요. 계좌번호와 앱키는 이 카드에 없습니다.',
  printSlotId: OpsSlotIds.emergencyCardPrint,
);

AsOf _asOf(DateTime nowUtc) => AsOf(
  observedAt: nowUtc.toUtc(),
  tradeDate: TradeDate(kstDateText(nowUtc)),
  source: AsOfSource.localSqlite,
  staleAfter: kX1ScreenStaleAfter,
  label: X1ScreenTexts.asOf(kstMinuteText(nowUtc)),
);

/// `MM-dd HH:mm`(한국).
String _monthMinute(DateTime utc) => kstMinuteText(utc).substring(5);

/// `HH:mm`(한국).
String _hourMinute(DateTime utc) => kstMinuteText(utc).substring(11);

/// 이전 티켓 표시 재료(🔴 페이로드 0 — 만료 · 백업 날 · 체인만).
class X1TicketFacts {
  /// 만든다.
  const X1TicketFacts({
    required this.expiresAtUtc,
    required this.backupAuthoredDate,
    required this.chainHash,
  });

  /// 만료.
  final DateTime expiresAtUtc;

  /// 백업 날.
  final String backupAuthoredDate;

  /// 체인(64자 — 화면엔 8자만).
  final String chainHash;
}

/// 옛 폰 마법사 재료(엔진 · 저장이 모은다).
class X1PlanWizardFacts {
  /// 만든다.
  const X1PlanWizardFacts({
    required this.runMode,
    required this.operatingMode,
    required this.deviceKnown,
    required this.nowUtc,
    this.journalBroken = false,
    this.runId,
    this.progress,
    this.stepFacts,
    this.windowOpenedAtUtc,
    this.ticket,
    this.lockedLabel,
  });

  /// 이 원장의 실행 모드.
  final RunMode runMode;

  /// 운영 방식.
  final OperatingMode operatingMode;

  /// 기기 id 를 아나(모르면 X1 꺼짐).
  final bool deviceKnown;

  /// 기준 시각(기기 시계 · 표시만).
  final DateTime nowUtc;

  /// 이 기기 이전 저널이 깨졌나.
  final bool journalBroken;

  /// 마지막 이전 id(없음 = null).
  final String? runId;

  /// 마지막 이전 진행(없음 = null).
  final PlanProgress? progress;

  /// 지금 단계 막음 재료(미체결 · UNKNOWN · 대사).
  final PlanStepFacts? stepFacts;

  /// 이 이전이 연 감시 창 열린 시각(열린 창 없음 = null).
  final DateTime? windowOpenedAtUtc;

  /// 티켓(발급 뒤만).
  final X1TicketFacts? ticket;

  /// 잠김 문장(생체 · 리스 · 뷰어).
  final String? lockedLabel;
}

SafetyActionCall _planStep(String runId, PlanStep s) => SafetyActionCall(
  id: SafetyActionId.x1PlanStep,
  args: <String, String>{'run_id': runId, 'step': s.wire},
  label: X1ScreenTexts.stepRun,
);

SafetyActionCall _planAbort(String runId, PlanStep s) => SafetyActionCall(
  id: SafetyActionId.x1PlanAbort,
  args: <String, String>{'run_id': runId, 'step': s.wire},
  label: X1ScreenTexts.abort,
);

/// 지금 단계 막음 줄(사실 = 엔진 · 막음 아님 = 빈 목록).
List<String> _blockLines(String code, PlanStepFacts f) => switch (code) {
  X1StepBlockCodes.openOrders => <String>[
    X1ScreenTexts.openOrdersLine(f.openOrders),
  ],
  X1StepBlockCodes.unknownOrders => <String>[
    X1ScreenTexts.unknownOrdersLine(f.unknownOrders),
  ],
  X1StepBlockCodes.reconNotZero => <String>[X1ScreenTexts.reconLine],
  _ => const <String>[],
};

String _blockHeadline(String code) => switch (code) {
  X1StepBlockCodes.openOrders => X1ScreenTexts.openOrdersHeadline,
  X1StepBlockCodes.unknownOrders => X1ScreenTexts.unknownOrdersHeadline,
  X1StepBlockCodes.reconNotZero => X1ScreenTexts.reconHeadline,
  _ => X1ScreenTexts.rejected(code),
};

X1PlanWizardVm _planEmpty(
  X1PlanWizardFacts f,
  String headline,
  UiLevel level,
  String? code,
) => X1PlanWizardVm(
  headline: headline,
  level: level,
  reasonCode: code,
  rows: const <X1StepRow>[],
  warningLines: const <String>[],
  lockedLabel: f.lockedLabel,
  asOf: _asOf(f.nowUtc),
);

/// 🔴 옛 폰 계획 교체 마법사 VM(`x1Migration`).
///
/// 차례 = 기기 id 없음 → 모의 → 안내 모드 → 저널 깨짐 → 이전 없음 · 중단 = `D-03` 한 장 + 시작 → 단계 9행.
X1PlanWizardVm x1PlanWizardVmOf(X1PlanWizardFacts f) {
  if (!f.deviceKnown) {
    return _planEmpty(f, X1ScreenTexts.noDevice, UiLevel.blocked, null);
  }
  if (f.runMode != RunMode.live) {
    return _planEmpty(
      f,
      X1ScreenTexts.liveOnly,
      UiLevel.info,
      X1StartResultCodes.liveOnly,
    );
  }
  if (f.operatingMode == OperatingMode.advisory) {
    return _planEmpty(
      f,
      X1ScreenTexts.advisoryPending,
      UiLevel.info,
      X1StartResultCodes.advisoryPending,
    );
  }
  if (f.journalBroken) {
    return _planEmpty(
      f,
      X1ScreenTexts.journalBroken,
      UiLevel.blocked,
      X1BootRefusalCodes.journalBroken,
    );
  }
  final PlanProgress? p = f.progress;
  final String? runId = f.runId;
  if (p == null || runId == null || p.failed != null) {
    final bool locked = f.lockedLabel != null;
    return X1PlanWizardVm(
      headline: X1ScreenTexts.d03Headline,
      level: UiLevel.act,
      d03Card: kX1D03Card,
      startAction: locked
          ? null
          : const SafetyActionCall(
              id: SafetyActionId.x1PlanStart,
              args: <String, String>{},
              label: X1ScreenTexts.start,
            ),
      rows: const <X1StepRow>[],
      warningLines: const <String>[],
      lockedLabel: f.lockedLabel,
      asOf: _asOf(f.nowUtc),
    );
  }
  final bool act = f.lockedLabel == null;
  final PlanNext next = planNextOf(p);
  final PlanStep? turn = switch (next) {
    PlanEnter(step: final PlanStep s) => s,
    PlanResume(step: final PlanStep s) => s,
    PlanAborted() || PlanComplete() => null,
  };
  final String? turnBlock = turn == null || !x1PlanStepOpen(turn)
      ? null
      : (f.stepFacts == null ? null : _previewBlock(turn, f.stepFacts!));
  final List<X1StepRow> rows = <X1StepRow>[
    for (final PlanStep s in PlanStep.values)
      _planRow(s, p, runId, turn, turnBlock, f.stepFacts, act),
  ];
  final (String headline, UiLevel level, String? code) = switch (next) {
    PlanComplete() => (X1ScreenTexts.complete, UiLevel.act, null),
    _ when turnBlock != null => (
      _blockHeadline(turnBlock),
      UiLevel.blocked,
      turnBlock,
    ),
    _ when p.pastNoReturn => (X1ScreenTexts.demoted, UiLevel.act, null),
    _ when turn != null && !x1PlanStepOpen(turn) => (
      X1ScreenTexts.closedHeadline,
      UiLevel.blocked,
      null,
    ),
    _ => (X1ScreenTexts.inProgress, UiLevel.act, null),
  };
  final X1TicketFacts? t = p.complete ? f.ticket : null;
  return X1PlanWizardVm(
    headline: headline,
    level: level,
    reasonCode: code,
    rows: rows,
    windowText: f.windowOpenedAtUtc == null
        ? null
        : X1ScreenTexts.window(_monthMinute(f.windowOpenedAtUtc!)),
    warningLines: p.pastNoReturn && !p.complete
        ? const <String>[X1ScreenTexts.graceLine]
        : const <String>[],
    ticket: t == null
        ? null
        : X1TicketCard(
            headline: X1ScreenTexts.ticketHeadline,
            ticketSlotId: act ? X1SlotIds.ticketQrDisplay : null,
            expiresText: X1ScreenTexts.ticketExpires(
              _hourMinute(t.expiresAtUtc),
            ),
            lines: <String>[
              X1ScreenTexts.ticketLine(
                t.backupAuthoredDate,
                t.chainHash.substring(0, 8),
              ),
            ],
          ),
    lockedLabel: f.lockedLabel,
    asOf: _asOf(f.nowUtc),
  );
}

/// 지금 단계를 끝낼 수 있나 미리 본다 — 백업 없음은 막음이 아니다(그 단계가 백업을 만든다).
String? _previewBlock(PlanStep s, PlanStepFacts f) {
  final String? c = planStepBlockCode(s, f);
  return c == X1StepBlockCodes.backupMissing ? null : c;
}

X1StepRow _planRow(
  PlanStep s,
  PlanProgress p,
  String runId,
  PlanStep? turn,
  String? turnBlock,
  PlanStepFacts? facts,
  bool act,
) {
  final String title = X1ScreenTexts.stepTitle(
    s.index + 1,
    X1ScreenTexts.planStepNames[s.index],
  );
  final List<String> noReturn = s == PlanStep.demoted
      ? const <String>[X1ScreenTexts.noReturn]
      : const <String>[];
  if (p.isDone(s)) {
    return X1StepRow(
      code: s.wire,
      title: title,
      stateLabel: X1ScreenTexts.stateDone,
      level: UiLevel.ok,
      lines: noReturn,
      actions: const <SafetyActionCall>[],
    );
  }
  if (s != turn) {
    return X1StepRow(
      code: s.wire,
      title: title,
      stateLabel: X1ScreenTexts.stateWaiting,
      level: UiLevel.info,
      lines: const <String>[],
      actions: const <SafetyActionCall>[],
    );
  }
  final bool mayAbort = act && s.mayFail;
  if (!x1PlanStepOpen(s)) {
    return X1StepRow(
      code: s.wire,
      title: title,
      stateLabel: X1ScreenTexts.stateBlocked,
      level: UiLevel.blocked,
      lines: <String>[X1ScreenTexts.closedLine, ...noReturn],
      actions: <SafetyActionCall>[if (mayAbort) _planAbort(runId, s)],
    );
  }
  if (turnBlock != null) {
    return X1StepRow(
      code: s.wire,
      title: title,
      stateLabel: X1ScreenTexts.stateBlocked,
      level: UiLevel.blocked,
      lines: _blockLines(turnBlock, facts!),
      blockCode: turnBlock,
      actions: <SafetyActionCall>[if (mayAbort) _planAbort(runId, s)],
    );
  }
  return X1StepRow(
    code: s.wire,
    title: title,
    stateLabel: X1ScreenTexts.stateTurn,
    level: UiLevel.act,
    lines: noReturn,
    actions: <SafetyActionCall>[
      if (act) _planStep(runId, s),
      if (mayAbort) _planAbort(runId, s),
    ],
  );
}

/// 새 폰 복구 한 판 재료(이 기기 · NEW_DEVICE 마지막 복구).
class X1RecoveryRunFacts {
  /// 만든다.
  const X1RecoveryRunFacts({
    required this.runId,
    required this.kind,
    required this.manifest,
    required this.gapRebuilt,
  });

  /// 이전 id.
  final String runId;

  /// 갈래.
  final MigrationKind kind;

  /// 복원한 매니페스트.
  final BackupManifest manifest;

  /// 갭 재구성이 끝났나.
  final bool gapRebuilt;
}

/// 새 폰 복구 화면 재료.
class X1RecoveryFacts {
  /// 만든다.
  const X1RecoveryFacts({
    required this.routeKind,
    required this.nowUtc,
    this.run,
    this.journalBroken = false,
    this.recoveryFull = false,
    this.goldenStates = const <String>{},
    this.gate,
    this.goldenRunnable = false,
    this.biometricRunnable = false,
    this.lockedLabel,
  });

  /// 들어온 라우트의 갈래(복구가 있으면 복구 갈래가 이긴다).
  final MigrationKind routeKind;

  /// 기준 시각.
  final DateTime nowUtc;

  /// 이 기기 마지막 복구(없음 = null).
  final X1RecoveryRunFacts? run;

  /// 복구 저널이 깨졌나.
  final bool journalBroken;

  /// 백업 갭이 재개 사다리 기준 이상(RECOVERY_FULL).
  final bool recoveryFull;

  /// 골든 단계 행 상태(`DONE` · `FAILED`).
  final Set<String> goldenStates;

  /// 재개 게이트 판정(갭 재구성 뒤만).
  final MigrationGateVerdict? gate;

  /// 골든 실행기가 있나.
  final bool goldenRunnable;

  /// 생체 확인을 띄울 수 있나.
  final bool biometricRunnable;

  /// 잠김 문장.
  final String? lockedLabel;
}

X1StepRow _recoveryRow(
  RecoveryStep s, {
  required String state,
  required UiLevel level,
  List<String> lines = const <String>[],
  String? blockCode,
  SafetyActionCall? action,
}) => X1StepRow(
  code: s.wire,
  title: X1ScreenTexts.stepTitle(
    s.index + 1,
    X1ScreenTexts.recoveryStepNames[s.index],
  ),
  stateLabel: state,
  level: level,
  lines: lines,
  blockCode: blockCode,
  actions: <SafetyActionCall>[?action],
);

SafetyActionCall _recoveryStep(String runId, RecoveryStep s) =>
    SafetyActionCall(
      id: SafetyActionId.x1RecoveryStep,
      args: <String, String>{'run_id': runId, 'step': s.wire},
      label: X1ScreenTexts.stepRun,
    );

/// 🔴 새 폰 복구 VM(`x1MigrationPlan` · `x1MigrationEmergency` 공용).
///
/// 차례 = 복구 없음 → 갈래별 막힘 문장 · 저널 깨짐 → RECOVERY_FULL(링크) → 단계 5행 + 게이트.
X1RecoveryVm x1RecoveryVmOf(X1RecoveryFacts f) {
  final AsOf asOf = _asOf(f.nowUtc);
  final X1RecoveryRunFacts? r = f.run;
  final MigrationKind kind = r?.kind ?? f.routeKind;
  final String kindLabel = kind == MigrationKind.plan
      ? X1ScreenTexts.planKind
      : X1ScreenTexts.emergencyKind;
  if (f.journalBroken) {
    return X1RecoveryVm(
      headline: X1ScreenTexts.journalBroken,
      level: UiLevel.blocked,
      reasonCode: X1BootRefusalCodes.journalBroken,
      kindLabel: kindLabel,
      reissue: const <X1ReissueRow>[],
      steps: const <X1StepRow>[],
      lockedLabel: f.lockedLabel,
      asOf: asOf,
    );
  }
  if (r == null) {
    final bool plan = kind == MigrationKind.plan;
    return X1RecoveryVm(
      headline: plan
          ? X1ScreenTexts.planBlocked
          : X1ScreenTexts.emergencyBlocked,
      level: UiLevel.blocked,
      kindLabel: kindLabel,
      reissue: const <X1ReissueRow>[],
      steps: const <X1StepRow>[],
      noticeText: plan
          ? X1ScreenTexts.planBlockedNotice
          : X1ScreenTexts.emergencyBlockedNotice,
      lockedLabel: f.lockedLabel,
      asOf: asOf,
    );
  }
  final X1RestoreCard restore = X1RestoreCard(
    headline: X1ScreenTexts.restored,
    level: UiLevel.ok,
    lines: <String>[X1ScreenTexts.restoreLine(r.manifest)],
    chainHashText: r.manifest.chainHash.substring(0, 8),
  );
  if (f.recoveryFull) {
    return X1RecoveryVm(
      headline: X1ScreenTexts.recoveryFull,
      level: UiLevel.blocked,
      reasonCode: X1OrderSealCodes.full,
      kindLabel: kindLabel,
      reissue: const <X1ReissueRow>[],
      restore: restore,
      steps: const <X1StepRow>[],
      restartLink: f.lockedLabel != null
          ? null
          : const LinkAction(
              label: X1ScreenTexts.restart,
              deepLink: AppRoutes.onboardingRestart,
            ),
      lockedLabel: f.lockedLabel,
      asOf: asOf,
    );
  }
  final bool act = f.lockedLabel == null;
  final MigrationGateVerdict? g = r.gapRebuilt ? f.gate : null;
  final String? gc = g?.code;
  final bool goldenDone = f.goldenStates.contains('DONE');
  final bool goldenFailed = !goldenDone && f.goldenStates.contains('FAILED');
  final bool checklistDone =
      g != null &&
      (g.state == MigrationGateState.passed ||
          gc == X1GateReasonCodes.biometricPending);
  final bool biometricDone = g?.state == MigrationGateState.passed;
  X1StepRow waiting(RecoveryStep s) =>
      _recoveryRow(s, state: X1ScreenTexts.stateWaiting, level: UiLevel.info);
  X1StepRow done(RecoveryStep s) =>
      _recoveryRow(s, state: X1ScreenTexts.stateDone, level: UiLevel.ok);
  final List<X1StepRow> steps = <X1StepRow>[
    done(RecoveryStep.restored),
    if (r.gapRebuilt)
      done(RecoveryStep.gapRebuilt)
    else
      _recoveryRow(
        RecoveryStep.gapRebuilt,
        state: X1ScreenTexts.stateBlocked,
        level: UiLevel.blocked,
        lines: const <String>[X1ScreenTexts.gapBlockedLine],
      ),
    if (!r.gapRebuilt)
      waiting(RecoveryStep.goldenSelfTest)
    else if (goldenDone)
      done(RecoveryStep.goldenSelfTest)
    else
      _recoveryRow(
        RecoveryStep.goldenSelfTest,
        state: goldenFailed
            ? X1ScreenTexts.stateFailed
            : X1ScreenTexts.stateTurn,
        level: goldenFailed ? UiLevel.blocked : UiLevel.act,
        lines: <String>[
          if (goldenFailed) X1ScreenTexts.goldenFailedLine,
          if (!f.goldenRunnable) X1ScreenTexts.goldenAbsentLine,
        ],
        blockCode: goldenFailed ? X1GateReasonCodes.goldenFailed : null,
        action: act && f.goldenRunnable
            ? _recoveryStep(r.runId, RecoveryStep.goldenSelfTest)
            : null,
      ),
    if (checklistDone)
      done(RecoveryStep.checklistConfirmed)
    else if (goldenDone && g != null && g.state != MigrationGateState.blocked)
      _recoveryRow(
        RecoveryStep.checklistConfirmed,
        state: X1ScreenTexts.stateTurn,
        level: UiLevel.act,
        action: act && gc == X1GateReasonCodes.checklistPending
            ? _recoveryStep(r.runId, RecoveryStep.checklistConfirmed)
            : null,
      )
    else
      waiting(RecoveryStep.checklistConfirmed),
    if (biometricDone)
      done(RecoveryStep.biometricConfirmed)
    else if (gc == X1GateReasonCodes.biometricPending)
      _recoveryRow(
        RecoveryStep.biometricConfirmed,
        state: X1ScreenTexts.stateTurn,
        level: UiLevel.act,
        action: act && f.biometricRunnable
            ? _recoveryStep(r.runId, RecoveryStep.biometricConfirmed)
            : null,
      )
    else
      waiting(RecoveryStep.biometricConfirmed),
  ];
  final (String headline, UiLevel level, String? code) = !r.gapRebuilt
      ? (X1ScreenTexts.gapBlocked, UiLevel.blocked, X1OrderSealCodes.inProgress)
      : switch (gc) {
          null when g?.state == MigrationGateState.passed => (
            X1ScreenTexts.passedHeadline,
            UiLevel.ok,
            null,
          ),
          X1GateReasonCodes.goldenNotRun => (
            X1ScreenTexts.goldenNotRunHeadline,
            UiLevel.act,
            gc,
          ),
          X1GateReasonCodes.goldenFailed => (
            X1ScreenTexts.goldenFailedHeadline,
            UiLevel.blocked,
            gc,
          ),
          X1GateReasonCodes.observing => (
            X1ScreenTexts.observingHeadline,
            UiLevel.watch,
            gc,
          ),
          X1GateReasonCodes.checklistPending => (
            X1ScreenTexts.checklistHeadline,
            UiLevel.act,
            gc,
          ),
          X1GateReasonCodes.biometricPending => (
            X1ScreenTexts.biometricHeadline,
            UiLevel.act,
            gc,
          ),
          final String c? => (X1ScreenTexts.gateWhy(c), UiLevel.blocked, c),
          null => (X1ScreenTexts.goldenNotRunHeadline, UiLevel.act, null),
        };
  return X1RecoveryVm(
    headline: headline,
    level: level,
    reasonCode: code,
    kindLabel: kindLabel,
    reissue: const <X1ReissueRow>[],
    restore: restore,
    steps: steps,
    gate: g == null ? null : _gateCard(g),
    lockedLabel: f.lockedLabel,
    asOf: asOf,
  );
}

X1GateCard _gateCard(MigrationGateVerdict g) => X1GateCard(
  stateLabel: X1ScreenTexts.gateStateLabel(g.state),
  level: switch (g.state) {
    MigrationGateState.blocked => UiLevel.blocked,
    MigrationGateState.observing => UiLevel.watch,
    MigrationGateState.awaitingApproval => UiLevel.act,
    MigrationGateState.passed => UiLevel.ok,
  },
  gateStateCode: g.state.wire,
  code: g.code,
  observeText: X1ScreenTexts.observe(
    g.observedTradingDays,
    g.requiredTradingDays,
  ),
  whyLine: X1ScreenTexts.gateWhy(g.code),
  actionLine: X1ScreenTexts.gateAction(g.code),
  checklistLines:
      g.code == X1GateReasonCodes.checklistPending ||
          g.code == X1GateReasonCodes.biometricPending
      ? X1ScreenTexts.checklistLines
      : const <String>[],
);

/// 거부 코드 가운데 다시 하면 풀릴 수 있는 것(사실이 바뀌기를 기다리는 막음).
const Set<String> _retryable = <String>{
  X1StepBlockCodes.openOrders,
  X1StepBlockCodes.unknownOrders,
  X1StepBlockCodes.reconNotZero,
  SafetyCommonResultCodes.trustedTimeUnknown,
};

/// 🔴 X1 동작 결과 — 접수(코드 null) · 거부(코드 · 글자 = 엔진) · 모의 거부 = INFO.
SafetyActionResult x1ActionResultOf({
  required SafetyActionId id,
  required String actionRunId,
  required String? code,
}) {
  final String accepted = X1ScreenTexts.accepted(id);
  if (code == null) {
    return SafetyActionResult(
      actionRunId: actionRunId,
      id: id,
      level: UiLevel.ok,
      headline: accepted,
      retryable: false,
    );
  }
  return SafetyActionResult(
    actionRunId: actionRunId,
    id: id,
    level: code == X1StartResultCodes.liveOnly ? UiLevel.info : UiLevel.blocked,
    headline: X1ScreenTexts.rejected(code),
    reasonCode: code,
    retryable: _retryable.contains(code),
  );
}
