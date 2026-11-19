// 🆕 E11q-b1a — M5-1 킬스위치 화면 VM · 발동 뒤 기록 폼 · 제출 원문 읽기(설계 13 §8 R178 · 01 §34 K146~K151 · 미결 186 · 203 ·
// 표본 `m5/kill_switch_*`).
//
// 🔴 상태 · 문장 = 엔진(`killSwitchViewOf` — 머리 · 기록 상태 · 해제 시각 줄) · 화면은 받은 글자 · 차례 그대로(카운트다운 0).
// 🔴 발동 버튼 = 꺼짐만(켜짐 = 버튼 부재) · 잠김에도 남는다(끄기는 등급 밖 · K150) · 확인 대화 0.
// 🔴 기록 폼 = 켜짐 ∧ 기록 전 ∧ 잠김 아님 ∧ 쓰기 창구가 있을 때(폰 · 이 기기 id) · 기록 뒤 = 해제 시각 줄 + 게이트 링크(등록됐을 때만).
// 🔴 취소 보고 = 발동 뒤 마지막 취소 보고(건수 · 건별 결과 · 🔴 금액 · 수량 · 주문번호 · intent id 0) · 후보 읽기 실패 = 문장 하나.
// 🔵 엔진 글자(미결 203) = 계약 표본이 제안한 문장(«(합성)» 표지 뗌 · 발주자 위임 — 권고대로).

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        CommandKind,
        CommandReceipt,
        CommandState,
        AsOf,
        AsOfSource,
        KillActivationChoice,
        KillActivationFormVm,
        KillActivationItemRow,
        KillActivationReason,
        KillActivationScope,
        KillCancelRow,
        KillChecklistSubmission,
        KillSwitchScreenVm,
        KillSwitchView,
        LinkAction,
        TradeDate,
        UiLevel;

import '../ops/alert_ack_command.dart' show newCommandId;
import '../ops/ledger_views.dart' show kstDateText;
import 'kill_activation.dart'
    show KillCancelItem, KillCancelOutcome, KillCancelReport;
import 'kill_checklist.dart'
    show KillAckAnswers, KillActivationAnswers, KillReasonKind, KillScope;
import 'kill_switch.dart'
    show
        KillSwitchConfig,
        KillSwitchRecord,
        ResumeReadinessKind,
        kP0sKillSwitchConfig,
        killSwitchViewOf,
        resumeReadinessOf;

/// 킬스위치 화면 기준 오래됨(읽기 모델 — 홈과 같은 축).
const Duration kKillSwitchStaleAfter = Duration(hours: 26);

/// M5-1 글자(표본 제안 문장 그대로 · SPEC 04 §3-6 원문 문항).
abstract final class KillSwitchScreenTexts {
  /// 발동 버튼.
  static const String activate = '킬스위치 켜기 — 신규 주문을 바로 막습니다';

  /// 3중 경로 안내(차례).
  static const List<String> paths = <String>[
    '이 폰: 이 버튼 — 네트워크를 기다리지 않고 막습니다',
    '다른 기기: 뷰어·웹의 킬스위치 — 서버 명령으로 막습니다',
    '기기를 쓸 수 없을 때: 긴급정지 카드 절차',
  ];

  /// 게이트 링크.
  static const String gateLink = '재개 게이트 보기';

  /// 이 폰에서 발동했을 때의 기기 별칭(표본 «운영 폰» · 🔴 기기 id 원문 0).
  static const String operatorPhone = '운영 폰';

  /// 후보 읽기 실패.
  static const String cancelReadFailed =
      '미체결 주문을 읽지 못했습니다 — 신규 주문 차단은 그대로입니다. 증권사 앱에서 미체결을 확인하십시오.';

  /// 발동 줄 — «발동 12-23 10:02 · 운영 폰».
  static String activated(String mdHm, String? device) =>
      device == null || device.trim().isEmpty
      ? '발동 $mdHm'
      : '발동 $mdHm · ${device.trim()}';

  /// 취소 경로 없음(엔진 `NO_BROKER` — 이 기기에서 그 계좌의 취소를 부를 길이 없다 · 모의 = 가상 취소가 원장에 남지 않아 넘기지 않는다).
  static const String noBroker = '취소 경로 없음 — 이 미체결은 그대로 남습니다';

  /// 건별 결과 글자([code] = 엔진 거부 코드 · `NO_BROKER` 만 따로 말한다).
  static String outcome(KillCancelOutcome o, {String? code}) =>
      o == KillCancelOutcome.failed && code == 'NO_BROKER'
      ? noBroker
      : switch (o) {
          KillCancelOutcome.cancelled => '취소 접수',
          KillCancelOutcome.failed => '취소 실패 — 증권사 앱에서 확인하십시오',
          KillCancelOutcome.unknown => '취소 결과 불명 — 다시 부르지 않았습니다',
          KillCancelOutcome.notCancelledUnknownIntent =>
            '주문 결과 불명 — 취소하지 않고 보고만 했습니다',
          KillCancelOutcome.inFlight => '제출 중이던 주문 — 결과를 기다립니다',
        };

  /// 폼 고지.
  static const String formNotice =
      '이 기록은 주문을 내지 않습니다. 전량 청산을 골라도 앱은 팔지 않습니다 — 청산은 사람이 2단계로 확인합니다.';

  /// 6번(입력 없음).
  static const String fixed6 = '이 기록을 마친 시각이 시작 시각입니다 — 앱이 적습니다';

  /// 7번(입력 없음).
  static const String fixed7 = '기록을 마치면 저널이 함께 만들어집니다';

  /// 확인 3 · 1줄(표본 글자).
  static const String ackQueried = '미체결 주문을 조회했다';
  static const String ackCancelled = '전량 취소했다';
  static const String ackRemainingZero = '잔여 0 을 확인했다';
  static const String note = '1줄';

  /// 문항(SPEC 04 §3-6 카드 ④ (가) · 01 §30 K38 정규화 · 표본 글자).
  static const List<String> items = <String>[
    '규칙이 지시한 행동은 무엇인가',
    '지금 끄는 것이 규칙인가 감정인가(감정 · 강도 · 수면)',
    '사전에 문서화한 시나리오인가(W번호 · 트리거 ID)',
    '재개 조건을 지금 적을 수 있는가',
    '끄는 범위',
    '재개 최소 대기 시작 시각(48h)',
    '저널 작성 완료(decision_id)',
  ];

  /// 3번 · 5번 보탬 줄(종이 카드 원문 · K148).
  static const String hint3 = '해당 없으면, 이것은 새로운 상황이 아니라 대개 새로운 감정이다.';
  static const String hint5 = '전량 청산은 2단계 확인 + 대기 필요. 기본은 신규 진입 차단.';
}

String _mdHm(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(k.month)}-${two(k.day)} ${two(k.hour)}:${two(k.minute)}';
}

/// «미체결 3건 — 취소 1 · 결과 불명 1 · 제출 중 1. 불명은 다시 부르지 않았습니다.» · 0건 = «미체결 주문이 없었습니다.»
String killCancelHeadline(KillCancelReport r) {
  if (r.candidatesError != null) return KillSwitchScreenTexts.cancelReadFailed;
  if (r.items.isEmpty) return '미체결 주문이 없었습니다.';
  final int unknown =
      r.count(KillCancelOutcome.unknown) +
      r.count(KillCancelOutcome.notCancelledUnknownIntent);
  final List<String> parts = <String>[
    if (r.count(KillCancelOutcome.cancelled) > 0)
      '취소 ${r.count(KillCancelOutcome.cancelled)}',
    if (r.count(KillCancelOutcome.failed) > 0)
      '실패 ${r.count(KillCancelOutcome.failed)}',
    if (unknown > 0) '결과 불명 $unknown',
    if (r.count(KillCancelOutcome.inFlight) > 0)
      '제출 중 ${r.count(KillCancelOutcome.inFlight)}',
  ];
  return '미체결 ${r.items.length}건 — ${parts.join(' · ')}.'
      '${unknown > 0 ? ' 불명은 다시 부르지 않았습니다.' : ''}';
}

UiLevel _cancelLevel(KillCancelOutcome o) => switch (o) {
  KillCancelOutcome.cancelled => UiLevel.ok,
  KillCancelOutcome.failed => UiLevel.act,
  KillCancelOutcome.unknown ||
  KillCancelOutcome.notCancelledUnknownIntent ||
  KillCancelOutcome.inFlight => UiLevel.watch,
};

/// 발동 뒤 기록 폼(카드 ④ (가) 7 + 확인 3 + 1줄 · 예시 · 프리필 0).
KillActivationFormVm killActivationFormVm() => KillActivationFormVm(
  items: <KillActivationItemRow>[
    for (int i = 0; i < KillSwitchScreenTexts.items.length; i++)
      KillActivationItemRow(
        itemNo: i + 1,
        label: KillSwitchScreenTexts.items[i],
        hintText: switch (i + 1) {
          3 => KillSwitchScreenTexts.hint3,
          5 => KillSwitchScreenTexts.hint5,
          _ => null,
        },
        fixedText: switch (i + 1) {
          6 => KillSwitchScreenTexts.fixed6,
          7 => KillSwitchScreenTexts.fixed7,
          _ => null,
        },
        choices: switch (i + 1) {
          2 => const <KillActivationChoice>[
            KillActivationChoice(
              label: '규칙',
              reasonKind: KillActivationReason.rule,
            ),
            KillActivationChoice(
              label: '감정',
              reasonKind: KillActivationReason.emotion,
            ),
          ],
          5 => const <KillActivationChoice>[
            KillActivationChoice(
              label: '신규 진입 차단만',
              scope: KillActivationScope.newEntriesOnly,
            ),
            KillActivationChoice(
              label: '전량 청산',
              scope: KillActivationScope.liquidateAll,
            ),
          ],
          _ => const <KillActivationChoice>[],
        },
      ),
  ],
  ackQueriedLabel: KillSwitchScreenTexts.ackQueried,
  ackCancelledLabel: KillSwitchScreenTexts.ackCancelled,
  ackRemainingZeroLabel: KillSwitchScreenTexts.ackRemainingZero,
  noteLabel: KillSwitchScreenTexts.note,
  noticeText: KillSwitchScreenTexts.formNotice,
);

/// M5-1 한 화면 — [cancel] = 발동 뒤 마지막 취소 보고(없으면 null = 보고 부재) · [canRecord] = 기록 쓰기 창구가 있나(폰 · 기기 id) ·
/// [hasBody] = 조립 앱 등록 화면(게이트 링크) · [lockedLabel] = 운영 등급 생체 축소(지금 조립 = null).
KillSwitchScreenVm killSwitchScreenVmOf({
  required KillSwitchRecord record,
  required DateTime? trustedNowUtc,
  required DateTime nowUtc,
  required KillCancelReport? cancel,
  required bool canRecord,
  required bool Function(String route) hasBody,
  String? lockedLabel,
  KillSwitchConfig cfg = kP0sKillSwitchConfig,
}) {
  final String day = kstDateText(nowUtc);
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  final AsOf asOf = AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kKillSwitchStaleAfter,
    label:
        '안전 기준 $day ${k.hour.toString().padLeft(2, '0')}:${k.minute.toString().padLeft(2, '0')}',
  );
  final KillSwitchView view = killSwitchViewOf(record, trustedNowUtc, cfg: cfg);
  if (!view.active) {
    return KillSwitchScreenVm(
      stateLabel: view.stateLabel,
      level: UiLevel.ok,
      activateLabel: KillSwitchScreenTexts.activate,
      pathLines: KillSwitchScreenTexts.paths,
      lockedLabel: lockedLabel,
      asOf: asOf,
    );
  }
  final ResumeReadinessKind kind = resumeReadinessOf(
    record,
    trustedNowUtc,
    cfg: cfg,
  ).kind;
  final bool recorded = kind != ResumeReadinessKind.checklistNotConfirmed;
  return KillSwitchScreenVm(
    stateLabel: view.stateLabel,
    level: switch (kind) {
      ResumeReadinessKind.checklistNotConfirmed => UiLevel.act,
      ResumeReadinessKind.ready => UiLevel.info,
      ResumeReadinessKind.waiting ||
      ResumeReadinessKind.trustedTimeUnknown ||
      ResumeReadinessKind.inactive => UiLevel.watch,
    },
    activatedText: record.activatedAtUtc == null
        ? null
        : KillSwitchScreenTexts.activated(
            _mdHm(record.activatedAtUtc!),
            record.activatedByDeviceLabel,
          ),
    cancelHeadline: cancel == null ? null : killCancelHeadline(cancel),
    cancelRows: <KillCancelRow>[
      if (cancel != null)
        for (final KillCancelItem i in cancel.items)
          KillCancelRow(
            symbolText: i.symbol,
            outcomeCode: i.outcome.wire,
            outcomeLabel: KillSwitchScreenTexts.outcome(
              i.outcome,
              code: i.code,
            ),
            level: _cancelLevel(i.outcome),
          ),
    ],
    checklistStateLabel: view.checklistStateLabel,
    form: !recorded && canRecord && lockedLabel == null
        ? killActivationFormVm()
        : null,
    etaText: recorded ? view.releaseEtaText : null,
    gateLink: recorded && hasBody(AppRoutes.m5ReleaseGate)
        ? const LinkAction(
            label: KillSwitchScreenTexts.gateLink,
            deepLink: AppRoutes.m5ReleaseGate,
          )
        : null,
    lockedLabel: lockedLabel,
    asOf: asOf,
  );
}

/// 제출 원문 → 엔진 답(파싱 = 구현 · 01 §34 K147) — 고르지 않은 선택 · 숫자가 아닌 강도 · 수면 · 빈 시나리오(해당 없음 아님) =
/// null(큐 적재 없는 `KILL_CHECKLIST_ITEM_MISSING`). 내용 판정(빈 글 · 범위)은 엔진 `activationChecklistVerdict` 몫.
(KillActivationAnswers, KillAckAnswers)? killChecklistAnswersOf(
  KillChecklistSubmission s, {
  required String journalDecisionId,
}) {
  final KillActivationReason? reason = s.reasonKind;
  final KillActivationScope? scope = s.scope;
  if (reason == null || scope == null) return null;
  final bool emotion = reason == KillActivationReason.emotion;
  int? intensity;
  double? sleep;
  if (emotion) {
    intensity = int.tryParse((s.intensity ?? '').trim());
    sleep = double.tryParse((s.sleepHours ?? '').trim());
    if (intensity == null || sleep == null) return null;
  }
  if (!s.scenarioNone && (s.scenarioId ?? '').trim().isEmpty) return null;
  return (
    KillActivationAnswers(
      ruleAction: s.ruleAction,
      reasonKind: emotion ? KillReasonKind.emotion : KillReasonKind.rule,
      emotion: emotion ? s.emotion : null,
      intensity: intensity,
      sleepHours: sleep,
      scenarioId: s.scenarioNone ? null : s.scenarioId,
      scenarioNone: s.scenarioNone,
      resumeCondition: s.resumeCondition,
      scope: switch (scope) {
        KillActivationScope.newEntriesOnly => KillScope.newEntriesOnly,
        KillActivationScope.liquidateAll => KillScope.liquidateAll,
      },
      journalDecisionId: journalDecisionId,
    ),
    KillAckAnswers(
      openOrdersQueried: s.openOrdersQueried,
      openOrdersCancelled: s.openOrdersCancelled,
      remainingCountZero: s.remainingCountZero,
      note: s.note,
    ),
  );
}

/// 킬스위치 명령 접수증 글자(표본 `m5/kill_switch_activate_receipts` · `kill_checklist_receipts`).
abstract final class KillCommandTexts {
  /// 발동 — 실행됨(이 폰 로컬 단락).
  static const String activated = '켜짐 — 신규 주문을 막았습니다';

  /// 기록 확인 — 실행됨.
  static const String confirmed = '확인됨 — 지금부터 48시간을 셉니다';

  /// 거부 — 까닭(«거부됨 — » 뒤).
  static String rejected(String code) =>
      '거부됨 — ${switch (code) {
        'KILL_CHECKLIST_ITEM_MISSING' => '7항목 중 빈칸이 있습니다. 입력값은 그대로 남아 있습니다',
        'KILL_ACK_INCOMPLETE' => '확인 3항목을 모두 체크하십시오',
        'KILL_ACK_MISMATCH' => '엔진이 본 미체결 주문이 남아 있습니다. 다시 조회하십시오',
        'KILL_SWITCH_NOT_ACTIVE' => '킬스위치가 꺼져 있습니다',
        'TRUSTED_TIME_UNKNOWN' => '서버 시각을 확인하지 못했습니다. 잠시 뒤 다시 확인하십시오',
        'JOURNAL_ID_TAKEN' => '저널 번호가 이미 쓰였습니다',
        final String other => throw ArgumentError.value(other, 'code', '모르는 킬스위치 거부 코드'),
      }}';
}

/// 킬스위치 명령 TTL(명령 선례 30분 — 폰 안에서 바로 끝난다).
const Duration kKillCommandTtl = Duration(minutes: 30);

/// 명령 봉투 — 명령 id · nonce · 페이로드 요약(`command_inbox.payload_digest` — 원문 재저장 0).
({String commandId, String nonce, String payloadDigest}) issueKillCommand({
  required Map<String, Object?> payload,
  required Random random,
}) => (
  commandId: newCommandId(random),
  nonce: <String>[
    for (int i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join(),
  payloadDigest: sha256.convert(utf8.encode(jsonEncode(payload))).toString(),
);

/// 접수증 — [executed] = 실행됨 · 아니면 [reasonCode] 거부(글자 = [KillCommandTexts]).
CommandReceipt killCommandReceiptOf({
  required CommandKind kind,
  required String commandId,
  required String nonce,
  required DateTime requestedAtUtc,
  required String deviceId,
  required bool executed,
  String? reasonCode,
}) {
  if (!executed && reasonCode == null) {
    throw ArgumentError('거부에는 코드가 있다');
  }
  final DateTime at = requestedAtUtc.toUtc();
  return CommandReceipt(
    commandId: commandId,
    kind: kind,
    state: executed ? CommandState.executed : CommandState.rejected,
    stateLabel: executed
        ? (kind == CommandKind.killSwitchActivate
              ? KillCommandTexts.activated
              : KillCommandTexts.confirmed)
        : KillCommandTexts.rejected(reasonCode!),
    requestedAt: at,
    expiresAt: at.add(kKillCommandTtl),
    nonce: nonce,
    issuedByDeviceId: deviceId,
    rejectReasonCode: executed ? null : reasonCode,
  );
}
