// X5-3 정정 마법사 — VM 생산자 · 마찰 단계 문구 · 결과 글자 · 정정 원문 파싱(순수 · 01 §41 K247~K263 · 01 §8 미결 217 ⓑⓓⓔⓗ ·
// 설계 13 §8 R227 · 표본 `x5/repair_*`).
//
// 🔴 허브(`x5RepairWizard`) · 대상(`x5RepairTarget/:targetId`)이 같은 `RepairWizardVm` 을 쓴다 — 허브 = 열린 대상 링크만(동작 0).
// 🔴 경계 X1 = 정정이 아니다(안내 링크만 · 동작 0) · 잠김 · 끝 = 동작 0 · 정정 폼(diff 갈래) ↔ 새 기준점(무결성 갈래) 배타.
// 🔴 마찰 1~5 = 개입 세션(`intervention_step`) 재사용 — 표에 종류 칸이 없어 세션 id 에 대상을 싣는다(`x5:<대상 id>:<차례>`).
//    살아 있는 세션은 한 번에 하나(R65) · 단계 진행 = `interventionStep` · 3단계 = 저널 폼 · 5단계 = 정정 · 새 기준점 제출.
// 🔴 시각 = 신뢰 시각 — 모르면 단계 동작을 내지 않는다(엔진 거부를 화면에 미리 그리지 않는다).
// 🔴 글자 = 표본 문장에서 «(합성)»만 뗀 것 + 표본 밖 문장(엔진) · 냉각 · 실행 창 수치 = 엔진 상수(R65) · 체인 상한 = 운영 설정
//    `operations.amend_chain_max`(01 §10-3 B6 · 🆕 미결 220 ⓑ — 조립이 읽어 넘긴다).

import 'dart:convert' show jsonDecode;

import 'package:domain_contracts/domain_contracts.dart'
    show
        AdviceRejectCodes,
        AppRoutes,
        AsOf,
        AsOfSource,
        BaselineApplyResultCodes,
        BaselineResultCodes,
        DiffStatus,
        InterventionResultCodes,
        InterventionStepOutcome,
        LedgerPair,
        LinkAction,
        OriginCodes,
        RepairCorrectionForm,
        RepairFillChoice,
        RepairInputResultCodes,
        RepairOriginChoice,
        RepairResultCodes,
        RepairRoute,
        RepairStageRow,
        RepairWizardVm,
        SafetyActionCall,
        SafetyActionId,
        SafetyActionResult,
        SafetyCommonResultCodes,
        SettingsResultCodes,
        TradeDate,
        UiLevel;

import '../ops/derived_sync.dart' show DerivedRelation;
import '../ops/ledger_boundary.dart'
    show BoundaryPath, LedgerBoundaryVerdict, ledgerBoundaryOf;
import '../ops/ledger_integrity.dart' show LedgerIntegrityVerdict;
import '../ops/ledger_views.dart'
    show
        StoredLedgerDiff,
        kOriginLabels,
        kReconStaleAfter,
        kstDateText,
        kstMinuteText,
        ledgerDiffRowOf,
        routeOf;
import '../safety/intervention.dart'
    show
        InterventionOutcome,
        InterventionState,
        interventionExecutable,
        kCoolingStage,
        kExecuteStage,
        kInterventionStages,
        kJournalStage;
import 'baseline_plan.dart' show integrityDiffIdOf;
import 'repair_plan.dart'
    show
        RepairChoice,
        RepairDirection,
        defaultRepairChoiceOf,
        kBaselineOriginCodes,
        repairOriginCodesFor;

/// 🔴 정정 원문 거부 코드 — 🆕 미결 220 ⓐ(계약 v1.35 §44 K291) 계약 `RepairInputResultCodes` 참조(엔진 글자 0 · 대조 시험
/// `v135_contract_parity_test`) · 계획 판정 거울 `RepairResultCodes` 와 축이 다르다.
/// 🔵 정정 체인 상한 = 운영 설정 `operations.amend_chain_max`(K292 · 미결 220 ⓑ · 엔진 상수 0 — `OperationsConfig.amendChainMax`).
abstract final class RepairInputCodes {
  /// 수량 · 가격 · 수수료 · 세금 원문을 읽을 수 없다(빈칸 · 숫자 아님 · 범위 밖).
  static const String amountInvalid = RepairInputResultCodes.amountInvalid;

  /// 전량(계약 사전과 같은 벌).
  static const Set<String> values = <String>{amountInvalid};
}

/// 정정(diff 갈래) 원인 칩 — 표본 `repair_diff_*` 의 세 칩(앱 밖 주문 · 잘못 기록 · 증권사 오류) ∩ 엔진 쓰기 목록.
const List<String> kRepairCorrectOriginCodes = <String>[
  OriginCodes.misrecordedFill,
  OriginCodes.manualOrder,
  OriginCodes.brokerError,
];

/// 새 기준점(무결성 갈래) 원인 칩 차례 — {CHAIN_BROKEN · SCHEMA_SKEW · DB_ERROR} ∩ 경계 후보.
const List<String> kRepairBaselineOriginOrder = <String>[
  OriginCodes.chainBroken,
  OriginCodes.schemaSkew,
  OriginCodes.dbError,
];

/// 마법사 원인 칩 글자(표본 문장 · 표본 밖 = 엔진 사전 `kOriginLabels`).
const Map<String, String> kRepairOriginLabels = <String, String>{
  OriginCodes.misrecordedFill: '잘못 기록된 체결',
  OriginCodes.manualOrder: '앱 밖 수동 주문',
  OriginCodes.brokerError: '증권사 오류',
  OriginCodes.chainBroken: '스탬프 사슬 끊김',
  OriginCodes.dbError: '저장 오류',
};

/// 마법사 세션 id 접두 — `x5:<대상 id>:`.
String x5SessionPrefixOf(String targetId) => 'x5:$targetId:';

/// 마법사 세션 id — 같은 대상의 [seq] 번째 세션(1부터).
String x5SessionIdOf(String targetId, int seq) {
  if (seq < 1) throw ArgumentError.value(seq, 'seq', '1 이상');
  return '${x5SessionPrefixOf(targetId)}$seq';
}

/// 세션 id → 대상 id(마법사 세션이 아니면 null).
String? x5TargetOfSession(String sessionId) {
  if (!sessionId.startsWith('x5:')) return null;
  final int end = sessionId.lastIndexOf(':');
  return end <= 3 ? null : sessionId.substring(3, end);
}

/// 마법사 글자(표본 문장 · 엔진 문장).
abstract final class RepairWizardTexts {
  /// 고지.
  static const String notice = '정정은 되돌리지 않습니다 — 잘못 고치면 정정의 정정만 남습니다.';

  /// 이력 링크.
  static const String history = '정정 이력 보기';

  /// X1 안내 링크.
  static const String x1Guide = '새 폰 복구 안내 보기';

  /// X1 머리(경계 X1 = 정정이 아니다).
  static const String x1Headline = '원장 파일을 믿을 수 없습니다 — 정정이 아니라 새 폰 복구가 필요합니다';

  /// 허브 — 대상 없음.
  static const String hubEmpty = '정정할 대상이 없습니다';

  /// 허브 — 대상 없음(끝 문장).
  static const String hubEmptyDone = '열린 차이와 무결성 표시가 없습니다';

  /// 허브 — 대상 n 건.
  static String hubTargets(int n) => '정정할 대상 $n건 — 하나를 고르십시오';

  /// 허브 — 대상은 있는데 이 앱에 대상 화면이 없다.
  static String hubNoBody(int n) => '정정할 대상 $n건 — 이 앱에서는 열 수 없습니다';

  /// 허브 — 무결성 표시가 서 있으나 대조가 깨끗하다.
  static const String integrityCleanFlag =
      '무결성 표시가 서 있으나 지금 대조는 깨끗합니다 — 새 기준점을 세울 수 없습니다';

  /// 허브 — 첫 어긋난 날 모름.
  static const String integrityDateUnknown =
      '지난 기록이 스탬프와 다르나 처음 어긋난 날을 모릅니다 — 새 기준점을 세울 수 없습니다';

  /// 허브 링크 — 체결 차이(같은 글자가 둘이면 차이 문장을 붙인다).
  static String diffLink(StoredLedgerDiff d, {bool withDelta = false}) {
    final String base = '체결 차이 — ${_mmdd(kstDateText(d.detectedAtUtc))} 탐지';
    return withDelta ? '$base · ${d.deltaLabel}' : base;
  }

  /// 허브 링크 — 장부 무결성.
  static String integrityLink(String firstBadDate) =>
      '장부 무결성 — 첫 어긋난 날 ${_mmdd(firstBadDate)}';

  /// diff — 기본 = 아무것도 안 하기.
  static const String diffDefault = '체결 보고가 늦은 것으로 보입니다 — 기본은 아무것도 안 하기입니다';

  /// diff — 시작 전.
  static const String diffStart =
      '이 차이를 정정하려면 다섯 단계를 거칩니다 — 아무것도 안 하기도 고를 수 있습니다';

  /// 단계 진행 중.
  static String stageHeadline(int stage) =>
      '정정 마찰 $stage단계 — ${stageNames[stage - 1]}';

  /// diff — 실행 가능.
  static const String diffReady = '정정을 실행할 수 있습니다';

  /// 무결성 — 실행 가능.
  static const String integrityReady = '지난 기록이 스탬프와 다릅니다 — 새 기준점을 만들 수 있습니다';

  /// 체결 후보 n 건.
  static String fillCount(int n) => '고칠 체결 후보 $n건';

  /// 대상 요약 — «MM-DD 체결 n건 — 증권사 b주 · 장부 l주».
  static String diffSummary(
    String authoredDate,
    int n,
    int broker,
    int ledger,
  ) => '${_mmdd(authoredDate)} 체결 $n건 — 증권사 $broker주 · 장부 $ledger주';

  /// 체결 후보 없음.
  static const String noFills = '고칠 증권사 체결 후보가 없습니다 — 아무것도 안 하기만 고를 수 있습니다';

  /// 첫 어긋난 날.
  static String firstBadDate(String day) => '첫 어긋난 날 ${_mmdd(day)}';

  /// 끝 — 해소.
  static const String doneResolved = '정정을 마쳤습니다 — 이 차이는 해소됐습니다';

  /// 끝 — 받아들임.
  static const String doneAccepted = '받아들인 차이입니다 — 그대로 둡니다';

  /// 끝 — 정정 대상이 아닌 차이.
  static const String notRepairable = '이 차이는 정정 대상이 아닙니다 — 자동 재동기화 또는 관측 항목입니다';

  /// 모르는 대상.
  static const String unknownTarget = '이 대상은 정정 목록에 없습니다';

  /// 모르는 대상 · 바뀐 판정 — 끝 문장.
  static const String pickAgain = '목록에서 다시 고르십시오';

  /// 무결성 — 표시 없음.
  static const String integrityNone = '무결성 표시가 없습니다 — 새 기준점이 필요 없습니다';

  /// 무결성 — 판정이 바뀜.
  static const String integrityChanged = '무결성 판정이 바뀌었습니다';

  /// 잠김.
  static const String locked = '이 기기에서는 정정할 수 없습니다';

  /// 잠김 머리.
  static const String lockedHeadline = '정정 마법사는 운영 폰에서만 씁니다';

  /// 단계 이름(1~5).
  static const List<String> stageNames = <String>[
    '규칙 대비',
    '카드 · 서약 다시 읽기',
    '사전 저널',
    '냉각',
    '실행 창',
  ];

  /// 단계 머리글.
  static String stageTitle(int stage) => '$stage ${stageNames[stage - 1]}';

  /// 상태 — 통과.
  static const String passed = '통과';

  /// 상태 — 차례.
  static const String current = '차례';

  /// 상태 — 3단계 차례.
  static const String currentJournal = '차례 — 저널 세 칸을 적으십시오';

  /// 상태 — 냉각 중.
  static const String cooling = '냉각 중';

  /// 상태 — 5단계 차례.
  static const String currentExecute = '차례 — 실행할 수 있습니다';

  /// 상태 — 대기.
  static const String waiting = '대기';

  /// 1단계 줄 — diff.
  static const String ruleDiff = '규칙 대비 — 이 정정은 체결 기록을 바꿉니다';

  /// 1단계 줄 — 무결성.
  static const String ruleIntegrity = '규칙 대비 — 새 기준점은 첫 어긋난 날 이후 스탬프를 다시 씁니다';

  /// 2단계 줄 — 서약 없음.
  static const String noPledge = '서약이 아직 없습니다';

  /// 3단계 줄.
  static const String journalLine = '무엇을 왜 고치는지 · 기대 결과 · 근거 규칙';

  /// 3단계 줄 — 재량 예산 소진.
  static const String journalNeedsNote =
      '재량 예산을 다 써서 저널에 메모가 필요합니다 — 이 마법사의 저널로는 통과할 수 없습니다';

  /// 4단계 줄.
  static String coolingUntil(DateTime endUtc) => '${_mmddHm(endUtc)} 부터';

  /// 5단계 줄.
  static String executeUntil(DateTime endUtc) => '실행 창 — ${_mmddHm(endUtc)} 까지';

  /// 1단계 줄 — 다른 세션.
  static const String otherSession =
      '다른 개입 세션이 열려 있습니다 — 그 세션을 끝내거나 그만둔 뒤 시작할 수 있습니다';

  /// 신뢰 시각 모름.
  static const String trustedUnknown =
      '신뢰 시각을 모릅니다 — 시각을 확인할 때까지 단계를 진행하지 않습니다';

  /// 동작 — 다음.
  static const String confirm = '확인했습니다';

  /// 동작 — 냉각 끝.
  static const String cooled = '냉각을 마쳤습니다';

  /// 동작 — 그만두기.
  static const String abandon = '그만두기';

  /// 동작 — 아무것도 안 하기.
  static const String doNothing = '아무것도 안 하기';

  /// 정정 폼 머리.
  static const String correctionNotice = '무효로 하거나 수량 · 가격을 다시 적습니다';

  /// 새 기준점 버튼.
  static const String baseline = '새 기준점 만들기';
}

String _mmdd(String ymd) => ymd.length >= 10 ? ymd.substring(5, 10) : ymd;

String _mmddHm(DateTime utc) => kstMinuteText(utc).substring(5);

/// 정정할 체결 후보 한 칸(data_sync 가 고른다 — 브로커 체결 · 주문 끝남 · 되돌려지지 않음 · REVERSAL 아님).
class RepairFillCandidate {
  /// 만든다.
  const RepairFillCandidate({
    required this.fillId,
    required this.tradeDate,
    required this.side,
    required this.symbol,
    required this.quantity,
    required this.price,
    this.restated = false,
  });

  /// 체결 id.
  final String fillId;

  /// 의도 거래일(`YYYY-MM-DD`).
  final String tradeDate;

  /// 방향(BUY · SELL).
  final String side;

  /// 종목.
  final String symbol;

  /// 수량.
  final int quantity;

  /// 가격(원).
  final double price;

  /// 다시 적은 판(RESTATEMENT)인가.
  final bool restated;
}

String _won(double v) {
  final bool whole = v == v.roundToDouble();
  final String raw = whole ? v.round().toString() : v.toString();
  final List<String> parts = raw.split('.');
  final String head = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (Match _) => ',',
  );
  return parts.length == 2 ? '$head.${parts[1]}' : head;
}

/// 체결 후보 글자 — «MM-DD 매수 069500 10주 · 9,850원»(다시 적은 판 = «· 정정본»).
String repairFillLabelOf(RepairFillCandidate f) {
  final String side = f.side == 'SELL' ? '매도' : '매수';
  final String base =
      '${_mmdd(f.tradeDate)} $side ${f.symbol} ${f.quantity}주 · ${_won(f.price)}원';
  return f.restated ? '$base · 정정본' : base;
}

/// 정정 마법사 한 판의 사실(data_sync 가 모은다 · 대상 화면 몫 = [targetDiff] · [fills]).
class RepairWizardFacts {
  /// 만든다.
  const RepairWizardFacts({
    required this.openDiffs,
    required this.integrityFlag,
    required this.integrity,
    required this.sessions,
    required this.pledgeLines,
    required this.budgetExhausted,
    required this.trustedNowUtc,
    required this.nowUtc,
    required this.writable,
    required this.hasBody,
    this.archiveRelation,
    this.targetDiff,
    this.fills = const <RepairFillCandidate>[],
  });

  /// 열린 `CANON_BROKER` diff 전부(허브 목록 — 승인 경로만 고른다).
  final List<StoredLedgerDiff> openDiffs;

  /// `LEDGER_INTEGRITY` 가 서 있나.
  final bool integrityFlag;

  /// 자가 대조 판정(표시가 없으면 깨끗한 판정을 넘겨도 된다 — 경계 = 표시가 있을 때만 본다).
  final LedgerIntegrityVerdict integrity;

  /// 아카이브 관계(모름 = null).
  final DerivedRelation? archiveRelation;

  /// 개입 세션 전부(id → 상태 · 닫힌 것 포함 — 차례 세기).
  final Map<String, InterventionState> sessions;

  /// 지금 서약 문장(2단계 재생).
  final List<String> pledgeLines;

  /// 재량 예산 소진(3단계 저널에 메모가 필요하다).
  final bool budgetExhausted;

  /// 신뢰 시각(모름 = null).
  final DateTime? trustedNowUtc;

  /// 기기 시각(관측 시각).
  final DateTime nowUtc;

  /// 쓰기 창구가 있고 잠김이 아닌가.
  final bool writable;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 대상 화면의 diff(아무 상태 · 모름 = null).
  final StoredLedgerDiff? targetDiff;

  /// 대상 화면의 체결 후보.
  final List<RepairFillCandidate> fills;
}

/// 관측 시각 봉투 — «정정 기준 YYYY-MM-DD HH:mm».
AsOf repairAsOf(DateTime nowUtc) {
  final DateTime at = nowUtc.toUtc();
  return AsOf(
    observedAt: at,
    tradeDate: TradeDate(kstDateText(at)),
    source: AsOfSource.localSqlite,
    staleAfter: kReconStaleAfter,
    label: '정정 기준 ${kstMinuteText(at)}',
  );
}

/// 지금 경계 — 표시가 없으면 깨끗(경계 = 무결성 표시가 섰을 때만 본다).
LedgerBoundaryVerdict repairBoundaryOf(RepairWizardFacts f) => ledgerBoundaryOf(
  dbOpened: true,
  integrity: f.integrityFlag
      ? f.integrity
      : const LedgerIntegrityVerdict.ok(daysChecked: 0, checkedThrough: null),
  archiveRelation: f.integrityFlag ? f.archiveRelation : null,
);

/// 지금 무결성 대상 id(`li-…` — 표시 ∧ 경계 X5 ∧ 첫 어긋난 날 앎 · 아니면 null).
String? integrityTargetIdOf(RepairWizardFacts f) {
  final LedgerBoundaryVerdict b = repairBoundaryOf(f);
  if (!f.integrityFlag || b.path != BoundaryPath.x5Repair) return null;
  final String? day = b.firstBadDate;
  final String? reason = f.integrity.reason?.code;
  if (day == null || reason == null) return null;
  return integrityDiffIdOf(day, reason);
}

/// 허브 목록에 오르는 diff — OPEN `CANON_BROKER` 승인 경로(탐지 늦은 것 먼저 · id).
List<StoredLedgerDiff> repairableDiffsOf(Iterable<StoredLedgerDiff> rows) =>
    <StoredLedgerDiff>[
      for (final StoredLedgerDiff d in rows)
        if (_repairable(d)) d,
    ]..sort((StoredLedgerDiff a, StoredLedgerDiff b) {
      final int t = b.detectedAtUtc.compareTo(a.detectedAtUtc);
      return t != 0 ? t : a.diffId.compareTo(b.diffId);
    });

bool _repairable(StoredLedgerDiff d) =>
    d.status == DiffStatus.open &&
    d.pair == LedgerPair.canonBroker &&
    routeOf(d.severity) == RepairRoute.approval;

LinkAction? _historyOf(RepairWizardFacts f) =>
    f.hasBody(AppRoutes.ledgerRepairs)
    ? const LinkAction(
        label: RepairWizardTexts.history,
        deepLink: AppRoutes.ledgerRepairs,
      )
    : null;

String _targetLinkOf(String id) =>
    AppRoutes.x5RepairTarget.replaceFirst(':targetId', id);

RepairWizardVm _plain(
  RepairWizardFacts f, {
  required String headline,
  required UiLevel level,
  String? reasonCode,
  List<LinkAction> targetLinks = const <LinkAction>[],
  List<String> targetLines = const <String>[],
  String? doneLabel,
  String? lockedLabel,
  LinkAction? x1GuideLink,
  StoredLedgerDiff? diff,
}) => RepairWizardVm(
  headline: headline,
  level: level,
  reasonCode: reasonCode,
  targetLinks: targetLinks,
  diff: diff == null ? null : ledgerDiffRowOf(diff, phone: false),
  targetLines: targetLines,
  doNothingDefault: false,
  origins: const <RepairOriginChoice>[],
  stages: const <RepairStageRow>[],
  doneLabel: doneLabel,
  historyLink: _historyOf(f),
  x1GuideLink: x1GuideLink,
  lockedLabel: lockedLabel,
  asOf: repairAsOf(f.nowUtc),
);

/// 🔴 정정 마법사 VM — [targetId] null = 허브 · 값 = 대상 화면(`ld-` diff · `li-` 무결성 · 그 밖 = 모르는 대상).
RepairWizardVm repairWizardVmOf(RepairWizardFacts f, {String? targetId}) {
  final LedgerBoundaryVerdict boundary = repairBoundaryOf(f);
  if (boundary.path == BoundaryPath.x1Emergency) {
    return _plain(
      f,
      headline: RepairWizardTexts.x1Headline,
      level: UiLevel.blocked,
      reasonCode: boundary.reason.wire,
      x1GuideLink: f.hasBody(AppRoutes.x1MigrationEmergency)
          ? const LinkAction(
              label: RepairWizardTexts.x1Guide,
              deepLink: AppRoutes.x1MigrationEmergency,
            )
          : null,
    );
  }
  if (targetId == null) return _hub(f, boundary);
  if (targetId.startsWith('li-')) return _integrity(f, boundary, targetId);
  return _diffTarget(f, targetId);
}

RepairWizardVm _hub(RepairWizardFacts f, LedgerBoundaryVerdict boundary) {
  final List<StoredLedgerDiff> diffs = repairableDiffsOf(f.openDiffs);
  final String? li = integrityTargetIdOf(f);
  final Map<String, int> same = <String, int>{};
  for (final StoredLedgerDiff d in diffs) {
    final String l = RepairWizardTexts.diffLink(d);
    same[l] = (same[l] ?? 0) + 1;
  }
  final List<LinkAction> links = <LinkAction>[
    for (final StoredLedgerDiff d in diffs)
      LinkAction(
        label: RepairWizardTexts.diffLink(
          d,
          withDelta: same[RepairWizardTexts.diffLink(d)]! > 1,
        ),
        deepLink: _targetLinkOf(d.diffId),
      ),
    if (li != null)
      LinkAction(
        label: RepairWizardTexts.integrityLink(boundary.firstBadDate!),
        deepLink: _targetLinkOf(li),
      ),
  ];
  // 무결성 표시가 섰는데 새 기준점을 세울 수 없는 판(깨끗 · 날 모름) — 허브가 말한다.
  final String? stuck = !f.integrityFlag || li != null
      ? null
      : boundary.path == BoundaryPath.none
      ? BaselineResultCodes.notX5
      : BaselineResultCodes.firstBadDateUnknown;
  final List<String> stuckLines = <String>[
    if (stuck == BaselineResultCodes.notX5)
      RepairWizardTexts.integrityCleanFlag,
    if (stuck == BaselineResultCodes.firstBadDateUnknown)
      RepairWizardTexts.integrityDateUnknown,
  ];
  if (links.isNotEmpty) {
    if (!f.hasBody(AppRoutes.x5RepairTarget)) {
      return _plain(
        f,
        headline: RepairWizardTexts.hubNoBody(links.length),
        level: UiLevel.watch,
        targetLines: stuckLines,
      );
    }
    return _plain(
      f,
      headline: RepairWizardTexts.hubTargets(links.length),
      level: UiLevel.act,
      targetLinks: links,
      targetLines: stuckLines,
    );
  }
  if (stuck != null) {
    return _plain(
      f,
      headline: stuckLines.single,
      level: UiLevel.watch,
      reasonCode: stuck,
    );
  }
  return _plain(
    f,
    headline: RepairWizardTexts.hubEmpty,
    level: UiLevel.ok,
    doneLabel: RepairWizardTexts.hubEmptyDone,
  );
}

/// 이 대상의 세션 — 닫히지 않은 것 가운데 가장 늦게 연 것(없음 = null) · 다음 차례 번호.
({InterventionState? open, int nextSeq, bool otherLive}) _sessionsOf(
  RepairWizardFacts f,
  String targetId,
) {
  final String prefix = x5SessionPrefixOf(targetId);
  final DateTime? now = f.trustedNowUtc;
  InterventionState? open;
  int count = 0;
  bool otherLive = false;
  for (final InterventionState s in f.sessions.values) {
    if (s.sessionId.startsWith(prefix)) {
      count++;
      if (s.closed) continue;
      if (open == null ||
          s.steps.first.occurredAtUtc.isAfter(open.steps.first.occurredAtUtc) ||
          (s.steps.first.occurredAtUtc == open.steps.first.occurredAtUtc &&
              s.sessionId.compareTo(open.sessionId) > 0)) {
        open = s;
      }
    } else if (now != null && s.liveAt(now)) {
      otherLive = true;
    }
  }
  // 실행 창이 지난 세션 = 새로 시작한다(만료 세션은 새 세션을 막지 않는다 · R65).
  if (open != null && now != null && open.expiredAt(now)) open = null;
  return (open: open, nextSeq: count + 1, otherLive: otherLive);
}

SafetyActionCall _step(
  String sessionId,
  int stage,
  InterventionStepOutcome outcome,
  String label,
) => SafetyActionCall(
  id: SafetyActionId.interventionStep,
  args: <String, String>{
    'session_id': sessionId,
    'stage': '$stage',
    'outcome': outcome.wire,
  },
  label: label,
);

/// 마찰 5행(개입 세션 · 🔴 신뢰 시각 모름 = 동작 0 · 저널 폼 0).
List<RepairStageRow> repairStageRowsOf({
  required InterventionState? session,
  required String newSessionId,
  required bool otherLive,
  required DateTime? trustedNowUtc,
  required List<String> pledgeLines,
  required bool budgetExhausted,
  required bool integrity,
}) {
  final DateTime? now = trustedNowUtc;
  final int next = session?.nextStage ?? 1;
  final String id = session?.sessionId ?? newSessionId;
  final bool canAct = now != null && !(next == 1 && otherLive);
  return <RepairStageRow>[
    for (int k = 1; k <= kInterventionStages; k++)
      if (k < next)
        RepairStageRow(
          title: RepairWizardTexts.stageTitle(k),
          stateLabel: RepairWizardTexts.passed,
          level: UiLevel.ok,
          lines: const <String>[],
          actions: const <SafetyActionCall>[],
          journalForm: false,
        )
      else if (k > next)
        RepairStageRow(
          title: RepairWizardTexts.stageTitle(k),
          stateLabel: RepairWizardTexts.waiting,
          level: UiLevel.info,
          lines: const <String>[],
          actions: const <SafetyActionCall>[],
          journalForm: false,
        )
      else
        _currentRow(
          k,
          session: session,
          id: id,
          now: now,
          canAct: canAct,
          otherLive: otherLive,
          pledgeLines: pledgeLines,
          budgetExhausted: budgetExhausted,
          integrity: integrity,
        ),
  ];
}

RepairStageRow _currentRow(
  int k, {
  required InterventionState? session,
  required String id,
  required DateTime? now,
  required bool canAct,
  required bool otherLive,
  required List<String> pledgeLines,
  required bool budgetExhausted,
  required bool integrity,
}) {
  final DateTime? coolEnd = session?.coolingEndsAtUtc;
  final bool cooled = now != null && coolEnd != null && !now.isBefore(coolEnd);
  final SafetyActionCall abandon = _step(
    id,
    k,
    InterventionStepOutcome.abandoned,
    RepairWizardTexts.abandon,
  );
  final List<String> lines = <String>[
    if (k == 1)
      integrity ? RepairWizardTexts.ruleIntegrity : RepairWizardTexts.ruleDiff,
    if (k == 1 && otherLive) RepairWizardTexts.otherSession,
    if (k == 2)
      ...pledgeLines.isEmpty
          ? <String>[RepairWizardTexts.noPledge]
          : pledgeLines,
    if (k == kJournalStage) RepairWizardTexts.journalLine,
    if (k == kJournalStage && budgetExhausted)
      RepairWizardTexts.journalNeedsNote,
    if (k == kCoolingStage && coolEnd != null)
      RepairWizardTexts.coolingUntil(coolEnd),
    if (k == kExecuteStage && session?.executeWindowEndsAtUtc != null)
      RepairWizardTexts.executeUntil(session!.executeWindowEndsAtUtc!),
    if (now == null) RepairWizardTexts.trustedUnknown,
  ];
  final List<SafetyActionCall> actions = !canAct
      ? const <SafetyActionCall>[]
      : switch (k) {
          1 => <SafetyActionCall>[
            _step(
              id,
              1,
              InterventionStepOutcome.passed,
              RepairWizardTexts.confirm,
            ),
          ],
          kJournalStage => <SafetyActionCall>[abandon],
          kCoolingStage => <SafetyActionCall>[
            if (cooled)
              _step(
                id,
                k,
                InterventionStepOutcome.passed,
                RepairWizardTexts.cooled,
              ),
            abandon,
          ],
          // 실행 창 = 정정 · 새 기준점 제출이 5단계다(창이 지나면 저절로 만료 — 새 세션을 막지 않는다).
          kExecuteStage => const <SafetyActionCall>[],
          _ => <SafetyActionCall>[
            _step(
              id,
              k,
              InterventionStepOutcome.passed,
              RepairWizardTexts.confirm,
            ),
            abandon,
          ],
        };
  final (String state, UiLevel level) = switch (k) {
    kJournalStage => (RepairWizardTexts.currentJournal, UiLevel.act),
    kCoolingStage when !cooled => (RepairWizardTexts.cooling, UiLevel.watch),
    kExecuteStage when canAct => (RepairWizardTexts.passed, UiLevel.ok),
    kExecuteStage => (RepairWizardTexts.currentExecute, UiLevel.act),
    _ => (RepairWizardTexts.current, UiLevel.act),
  };
  return RepairStageRow(
    title: RepairWizardTexts.stageTitle(k),
    stateLabel: state,
    level: level,
    lines: lines,
    actions: actions,
    journalForm: k == kJournalStage && canAct,
  );
}

/// 원인 칩 — [order] 차례로 [allowed] 안의 것만(글자 = 마법사 글자 · 없으면 엔진 사전).
List<RepairOriginChoice> _originsOf(List<String> order, Set<String> allowed) =>
    <RepairOriginChoice>[
      for (final String c in order)
        if (allowed.contains(c))
          RepairOriginChoice(
            originCode: c,
            label: kRepairOriginLabels[c] ?? kOriginLabels[c]!,
          ),
    ];

/// diff 대상 요약 — delta 의 장부 · 증권사 수량을 읽을 수 있으면 «MM-DD 체결 n건 — 증권사 b주 · 장부 l주».
List<String> _diffLines(StoredLedgerDiff d, int fills, bool defaultNothing) {
  if (fills == 0) {
    return defaultNothing
        ? const <String>[RepairWizardTexts.noFills]
        : const <String>[];
  }
  final Object? j = jsonDecode(d.delta);
  final Object? b = j is Map<String, Object?> ? j['broker'] : null;
  final Object? l = j is Map<String, Object?> ? j['ledger'] : null;
  return <String>[
    b is int && l is int
        ? RepairWizardTexts.diffSummary(d.authoredDate.yyyyMmDd, fills, b, l)
        : RepairWizardTexts.fillCount(fills),
  ];
}

RepairWizardVm _diffTarget(RepairWizardFacts f, String targetId) {
  final StoredLedgerDiff? d = f.targetDiff;
  if (d == null || d.diffId != targetId) {
    return _plain(
      f,
      headline: RepairWizardTexts.unknownTarget,
      level: UiLevel.info,
      doneLabel: RepairWizardTexts.pickAgain,
    );
  }
  if (d.status != DiffStatus.open) {
    return _plain(
      f,
      headline: d.status == DiffStatus.resolved
          ? RepairWizardTexts.doneResolved
          : RepairWizardTexts.doneAccepted,
      level: UiLevel.ok,
      doneLabel: ledgerDiffRowOf(d, phone: false).statusLabel,
      diff: d,
    );
  }
  if (!_repairable(d)) {
    return _plain(
      f,
      headline: RepairWizardTexts.notRepairable,
      level: UiLevel.info,
      doneLabel: RepairWizardTexts.pickAgain,
      diff: d,
    );
  }
  if (!f.writable) {
    return _plain(
      f,
      headline: RepairWizardTexts.lockedHeadline,
      level: UiLevel.info,
      lockedLabel: RepairWizardTexts.locked,
      diff: d,
    );
  }
  final ({InterventionState? open, int nextSeq, bool otherLive}) s =
      _sessionsOf(f, targetId);
  final bool defaultNothing =
      defaultRepairChoiceOf(d) == RepairChoice.doNothing;
  final bool hasFills = f.fills.isNotEmpty;
  final bool executable =
      hasFills && interventionExecutable(s.open, f.trustedNowUtc);
  final List<RepairStageRow> stages = hasFills
      ? repairStageRowsOf(
          session: s.open,
          newSessionId: x5SessionIdOf(targetId, s.nextSeq),
          otherLive: s.otherLive,
          trustedNowUtc: f.trustedNowUtc,
          pledgeLines: f.pledgeLines,
          budgetExhausted: f.budgetExhausted,
          integrity: false,
        )
      : const <RepairStageRow>[];
  final String headline = !hasFills
      ? (defaultNothing
            ? RepairWizardTexts.diffDefault
            : RepairWizardTexts.noFills)
      : executable
      ? RepairWizardTexts.diffReady
      : s.open != null
      ? RepairWizardTexts.stageHeadline(s.open!.nextStage!)
      : defaultNothing
      ? RepairWizardTexts.diffDefault
      : RepairWizardTexts.diffStart;
  return RepairWizardVm(
    headline: headline,
    level: defaultNothing && s.open == null ? UiLevel.watch : UiLevel.act,
    targetLinks: const <LinkAction>[],
    diff: ledgerDiffRowOf(d, phone: false),
    targetLines: _diffLines(d, f.fills.length, defaultNothing),
    // 처음 고른 칸만 정한다(세션이 시작되면 고른 뒤다 — K251).
    doNothingDefault: defaultNothing && s.open == null,
    origins: hasFills
        ? _originsOf(
            kRepairCorrectOriginCodes,
            repairOriginCodesFor(
              RepairDirection.canonCorrect,
              LedgerPair.canonBroker,
            ),
          )
        : const <RepairOriginChoice>[],
    stages: stages,
    doNothingAction: SafetyActionCall(
      id: SafetyActionId.repairAccept,
      args: <String, String>{'diff_id': d.diffId},
      label: RepairWizardTexts.doNothing,
    ),
    correction: executable
        ? RepairCorrectionForm(
            fills: <RepairFillChoice>[
              for (final RepairFillCandidate c in f.fills)
                RepairFillChoice(
                  fillRef: c.fillId,
                  label: repairFillLabelOf(c),
                ),
            ],
            amendAllowed: true,
            noticeText: RepairWizardTexts.correctionNotice,
          )
        : null,
    noticeText: RepairWizardTexts.notice,
    historyLink: _historyOf(f),
    asOf: repairAsOf(f.nowUtc),
  );
}

RepairWizardVm _integrity(
  RepairWizardFacts f,
  LedgerBoundaryVerdict boundary,
  String targetId,
) {
  if (!f.integrityFlag) {
    return _plain(
      f,
      headline: RepairWizardTexts.integrityNone,
      level: UiLevel.ok,
      doneLabel: RepairWizardTexts.integrityNone,
    );
  }
  final String? li = integrityTargetIdOf(f);
  if (li != targetId) {
    return _plain(
      f,
      headline: RepairWizardTexts.integrityChanged,
      level: UiLevel.info,
      reasonCode: boundary.path == BoundaryPath.none
          ? BaselineResultCodes.notX5
          : boundary.firstBadDate == null
          ? BaselineResultCodes.firstBadDateUnknown
          : boundary.reason.wire,
      doneLabel: RepairWizardTexts.pickAgain,
    );
  }
  final String day = boundary.firstBadDate!;
  if (!f.writable) {
    return _plain(
      f,
      headline: RepairWizardTexts.lockedHeadline,
      level: UiLevel.info,
      reasonCode: boundary.reason.wire,
      targetLines: <String>[RepairWizardTexts.firstBadDate(day)],
      lockedLabel: RepairWizardTexts.locked,
    );
  }
  final ({InterventionState? open, int nextSeq, bool otherLive}) s =
      _sessionsOf(f, targetId);
  final bool executable = interventionExecutable(s.open, f.trustedNowUtc);
  return RepairWizardVm(
    headline: executable
        ? RepairWizardTexts.integrityReady
        : s.open != null
        ? RepairWizardTexts.stageHeadline(s.open!.nextStage!)
        : boundary.headline,
    level: UiLevel.act,
    reasonCode: boundary.reason.wire,
    targetLinks: const <LinkAction>[],
    targetLines: <String>[RepairWizardTexts.firstBadDate(day)],
    doNothingDefault: false,
    origins: _originsOf(
      kRepairBaselineOriginOrder,
      kBaselineOriginCodes.intersection(boundary.originCandidates.toSet()),
    ),
    stages: repairStageRowsOf(
      session: s.open,
      newSessionId: x5SessionIdOf(targetId, s.nextSeq),
      otherLive: s.otherLive,
      trustedNowUtc: f.trustedNowUtc,
      pledgeLines: f.pledgeLines,
      budgetExhausted: f.budgetExhausted,
      integrity: true,
    ),
    baselineLabel: executable ? RepairWizardTexts.baseline : null,
    noticeText: RepairWizardTexts.notice,
    historyLink: _historyOf(f),
    asOf: repairAsOf(f.nowUtc),
  );
}

// ── 정정 원문 파싱(ⓓ) ────────────────────────────────────────────────────

final RegExp _quantity = RegExp(r'^(\d{1,3}(,\d{3})+|\d+)$');
final RegExp _amount = RegExp(r'^(\d{1,3}(,\d{3})+|\d+)(\.\d+)?$');

int? _int(String? t) {
  final String s = (t ?? '').trim();
  if (!_quantity.hasMatch(s)) return null;
  return int.tryParse(s.replaceAll(',', ''));
}

double? _double(String? t) {
  final String s = (t ?? '').trim();
  if (!_amount.hasMatch(s)) return null;
  final double? v = double.tryParse(s.replaceAll(',', ''));
  return v == null || !v.isFinite ? null : v;
}

/// 정정 원문 4칸 → 값(수량 양의 정수 · 가격 양수 · 수수료 · 세금 0 이상 · 천 단위 쉼표 허용) · 못 읽으면
/// [RepairInputCodes.amountInvalid].
({int quantity, double price, double commission, double tax})?
parseRepairAmounts({
  required String? quantityText,
  required String? priceText,
  required String? commissionText,
  required String? taxText,
}) {
  final int? q = _int(quantityText);
  final double? p = _double(priceText);
  final double? c = _double(commissionText);
  final double? t = _double(taxText);
  if (q == null || q <= 0 || p == null || p <= 0 || c == null || t == null) {
    return null;
  }
  return (quantity: q, price: p, commission: c, tax: t);
}

// ── 결과 글자(ⓗ) ──────────────────────────────────────────────────────────

/// 코드 없는 막힘(구현의 «잠시 뒤 다시» — 계약 K257 `LedgerFixBusy` 코드 0).
enum RepairRunHold {
  /// 다른 정정(`LEDGER_FIX`)이 진행 중이다.
  busy,

  /// 직전 재대사를 하지 못했다(증권사 조회 실패 · 연결 없음).
  reconUnavailable,
}

/// 막힘 글자.
abstract final class RepairResultTexts {
  /// 받아들임.
  static const String accepted = '받아들였습니다 — 차이를 그대로 둡니다';

  /// 정정.
  static const String corrected = '정정을 기록했습니다 — 포지션을 다시 셌습니다';

  /// 새 기준점.
  static const String baselined = '새 기준점을 만들었습니다 — 무결성 표시를 풀었습니다';

  /// 저널.
  static const String journaled = '사전 저널을 남겼습니다';

  /// 단계 통과.
  static const String stepPassed = '단계를 기록했습니다';

  /// 단계 — 아무것도 안 하기.
  static const String stepDoNothing = '아무것도 하지 않기로 하고 세션을 닫았습니다';

  /// 단계 — 그만두기.
  static const String stepAbandoned = '그만두고 세션을 닫았습니다';

  /// 막힘 — 다른 정정.
  static const String busy = '다른 정정이 진행 중입니다 — 잠시 뒤 다시 하십시오';

  /// 막힘 — 재대사 실패.
  static const String reconUnavailable =
      '증권사 재조회를 하지 못해 정정하지 않았습니다 — 잠시 뒤 다시 하십시오';
}

(UiLevel, String) _rejectText(SafetyActionId id, String code) => switch (code) {
  RepairResultCodes.deltaChanged => (
    UiLevel.blocked,
    id == SafetyActionId.repairBaseline
        ? '무결성 판정이 바뀌었습니다 — 처음부터 다시 보십시오'
        : '방금 다시 대사한 결과가 달라졌습니다 — 처음부터 다시 보십시오',
  ),
  RepairResultCodes.targetNotImmutable => (
    UiLevel.blocked,
    '이 기록은 정정 대상이 아닙니다',
  ),
  RepairResultCodes.originNotAllowed => (
    UiLevel.blocked,
    '이 원인 코드로는 정정할 수 없습니다',
  ),
  RepairResultCodes.decisionRequired => (
    UiLevel.blocked,
    '결정 저널이 없어 정정하지 않았습니다',
  ),
  RepairResultCodes.noChange => (UiLevel.info, '바뀌는 것이 없어 정정하지 않았습니다'),
  RepairResultCodes.diffNotOpen => (UiLevel.info, '이 차이는 이미 닫혔습니다'),
  RepairResultCodes.fillNotBroker => (
    UiLevel.blocked,
    '증권사 체결이 아니거나 찾을 수 없습니다',
  ),
  RepairResultCodes.orderOpen => (
    UiLevel.watch,
    '주문이 아직 열려 있어 정정하지 않았습니다 — 주문이 끝난 뒤 다시 하십시오',
  ),
  RepairResultCodes.positionDrift => (
    UiLevel.blocked,
    '저장된 포지션이 체결 기록과 달라 정정하지 않았습니다',
  ),
  RepairResultCodes.positionNegative => (
    UiLevel.blocked,
    '정정하면 포지션이 중간에 음수가 됩니다 — 정정하지 않았습니다',
  ),
  BaselineResultCodes.notX5 => (UiLevel.blocked, '지금은 새 기준점을 세울 수 있는 상태가 아닙니다'),
  BaselineResultCodes.firstBadDateUnknown => (
    UiLevel.blocked,
    '처음 어긋난 날을 알 수 없습니다',
  ),
  BaselineApplyResultCodes.flagNotSet => (UiLevel.blocked, '무결성 표시가 서 있지 않습니다'),
  AdviceRejectCodes.amendTargetNotActive => (
    UiLevel.blocked,
    '이미 되돌린 체결이라 고칠 수 없습니다',
  ),
  AdviceRejectCodes.amendSymbolOrSideChange => (
    UiLevel.blocked,
    '종목이나 매수 · 매도는 바꿀 수 없습니다',
  ),
  AdviceRejectCodes.amendLimitExceeded => (
    UiLevel.blocked,
    '이 체결은 더 고칠 수 없습니다(정정 횟수 상한) — 원장 전체를 다시 보십시오',
  ),
  InterventionResultCodes.closed => (UiLevel.info, '이미 닫힌 세션입니다'),
  InterventionResultCodes.cooling => (UiLevel.watch, '냉각이 끝나지 않았습니다'),
  InterventionResultCodes.expired => (
    UiLevel.blocked,
    '실행 창이 지났습니다 — 처음부터 다시 시작하십시오',
  ),
  InterventionResultCodes.journalMissing => (UiLevel.act, '사전 저널이 연결되지 않았습니다'),
  InterventionResultCodes.outOfOrder => (
    UiLevel.blocked,
    id == SafetyActionId.interventionJournal
        ? '지금은 저널 단계가 아닙니다'
        : '지금은 그 단계 차례가 아닙니다',
  ),
  InterventionResultCodes.sessionOpen => (UiLevel.watch, '다른 개입 세션이 열려 있습니다'),
  SafetyCommonResultCodes.trustedTimeUnknown => (
    UiLevel.watch,
    '신뢰 시각을 몰라 기록하지 않았습니다',
  ),
  SafetyCommonResultCodes.journalIdTaken => (
    UiLevel.blocked,
    '같은 저널 번호가 이미 있어 기록하지 않았습니다',
  ),
  SettingsResultCodes.biometricUnavailable => (
    UiLevel.blocked,
    '생체 확인을 쓸 수 없습니다',
  ),
  RepairInputCodes.amountInvalid => (
    UiLevel.act,
    '수량 · 가격 · 수수료 · 세금을 읽을 수 없습니다 — 숫자로 다시 적으십시오',
  ),
  final String other => throw ArgumentError.value(
    other,
    'code',
    '모르는 정정 거부 코드',
  ),
};

String _okText(SafetyActionId id, InterventionStepOutcome? step) =>
    switch (id) {
      SafetyActionId.repairAccept => RepairResultTexts.accepted,
      SafetyActionId.repairCorrect => RepairResultTexts.corrected,
      SafetyActionId.repairBaseline => RepairResultTexts.baselined,
      SafetyActionId.interventionJournal => RepairResultTexts.journaled,
      SafetyActionId.interventionStep => switch (step) {
        InterventionStepOutcome.doNothing => RepairResultTexts.stepDoNothing,
        InterventionStepOutcome.abandoned => RepairResultTexts.stepAbandoned,
        _ => RepairResultTexts.stepPassed,
      },
      _ => throw ArgumentError.value(id, 'id', '정정 마법사 동작이 아니다'),
    };

/// 🔴 정정 마법사 동작 결과 — [code] null ∧ [hold] null = 성공 · 글자 = 엔진 · 모르는 코드 · 동작 = [ArgumentError] ·
/// [step] = `interventionStep` 성공 글자를 고르는 결과(통과 · 아무것도 안 하기 · 그만두기).
SafetyActionResult repairWizardResultOf({
  required SafetyActionId id,
  required String actionRunId,
  String? code,
  RepairRunHold? hold,
  InterventionStepOutcome? step,
}) {
  if (code != null && hold != null) {
    throw ArgumentError('code · hold 는 함께 올 수 없다');
  }
  final String ok = _okText(id, step);
  final (UiLevel level, String headline) = hold != null
      ? (
          UiLevel.watch,
          hold == RepairRunHold.busy
              ? RepairResultTexts.busy
              : RepairResultTexts.reconUnavailable,
        )
      : code == null
      ? (UiLevel.ok, ok)
      : _rejectText(id, code);
  return SafetyActionResult(
    actionRunId: actionRunId,
    id: id,
    level: level,
    headline: headline,
    reasonCode: code,
    retryable: hold != null,
  );
}

/// 개입 단계 결과 글자에 쓰는 결과 값 → 계약 값.
InterventionStepOutcome interventionStepOutcomeOf(InterventionOutcome o) =>
    switch (o) {
      InterventionOutcome.passed => InterventionStepOutcome.passed,
      InterventionOutcome.doNothing => InterventionStepOutcome.doNothing,
      InterventionOutcome.abandoned => InterventionStepOutcome.abandoned,
    };
