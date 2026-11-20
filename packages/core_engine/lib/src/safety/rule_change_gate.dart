// 🆕 E11q-c0 — M5-9 규칙 변경 게이트 «첫 승인 최소판» VM · 후보 · 결과 글자(설계 13 §8 R188 · 01 §35 K177~K180 · 미결 205 ⓐⓑ ·
// 표본 `m5/rule_change_gate_*` · `m5/rule_change_request_results` · `m5/safety_action_results_e13`).
//
// 🔴 안전 수치 무변경 — 냉각 30일 · SAF-405 · 첫 승인 면제(12월 창 · DD 락뿐) = `rule_change.dart` 그대로. 승인 가능 판정 = 엔진
//    `ruleChangeApproveRejectCode` 를 사람 칸만 채운 꼴로 불러 «냉각 · 창 · DD · 신뢰 시각»에 걸리지 않을 때만 `approveLabel`.
// 🔴 후보 = 승인 config 0 ∧ 지금 config 등재 ∧ 그 config 의 열린 요청 0 → 1(유형 = 전략 규칙 · 전 = `NONE` · 후 = 지금 지문 —
//    자기 신고 0 · K178) · 둘째 승인부터(승인 있음 ∧ 지금 ≠ 승인) = 다음 판(K179 · 후보 0 · 문장으로만 말한다).
// 🔴 요청 · 승인 · 취소 = 쓰기 창구가 있고 잠김이 아닐 때만(잠김 ⇒ 0 · C-60 ⑦) · 신뢰 시각 모름 = 자리는 그대로 두고 결과 원문으로 거부(K176).
// 🔵 엔진 글자(미결 203 결) = 계약 표본이 제안한 문장(«(합성)» 표지 뗌 · 발주자 위임 — 권고대로).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        RuleChangeCandidateRow,
        RuleChangeGateVm,
        RuleChangeQueueRow,
        SafetyActionCall,
        SafetyActionId,
        SafetyActionResult,
        TradeDate,
        UiLevel;

import '../ops/ledger_views.dart' show kstDateText;
import 'rule_change.dart';

/// 게이트 기준 오래됨(읽기 모델 — 홈과 같은 축).
const Duration kRuleChangeGateStaleAfter = Duration(hours: 26);

/// M5-9 글자(표본 제안 문장 · 엔진 사전 밖 몫).
abstract final class RuleChangeGateTexts {
  /// 머리 — 승인 0 · 후보 있음.
  static const String headlineFirst = '승인된 설정이 없습니다 — 실전 기동 전에 첫 승인이 필요합니다';

  /// 머리 — 열린 요청이 냉각 중.
  static const String headlineCooling = '첫 승인 요청이 냉각 중입니다';

  /// 머리 — 승인할 수 있는 요청 있음.
  static const String headlineApprovable = '냉각이 끝났습니다 — 승인할 수 있습니다';

  /// 머리 — 승인 config 로 돈다.
  static const String headlineApproved = '승인된 설정으로 돌고 있습니다';

  /// 머리 — 승인 0 · 등재된 지금 설정 0(모의 시작 전).
  static const String headlineNoConfig =
      '승인된 설정이 없습니다 — 모의 시작을 마치면 지금 설정의 첫 승인을 요청할 수 있습니다';

  /// 머리 — 지금 설정이 승인된 설정과 다르다(둘째 승인 = 다음 판).
  static const String headlineDiffers =
      '지금 설정이 승인된 설정과 다릅니다 — 둘째 승인부터는 다음 판에서 엽니다';

  /// 창 — 첫 승인.
  static const String windowFirst =
      '첫 승인은 12월 창 밖에서도 요청할 수 있습니다 — 냉각 30일은 그대로입니다';

  /// 빈 문장 — 승인됨.
  static const String emptyApproved = '열린 요청이 없습니다 — 지금 설정은 승인되어 있습니다';

  /// 빈 문장 — 지금 설정 0.
  static const String emptyNoConfig =
      '요청할 설정이 없습니다 — 모의 시작에서 설정이 등재되면 여기에 후보가 섭니다';

  /// 빈 문장 — 지금 ≠ 승인.
  static const String emptyDiffers = '열린 요청이 없습니다 — 지금 설정은 아직 승인되지 않았습니다';

  /// 후보 이름 · 요청 버튼 · 고지.
  static const String candidateLabel = '지금 쓰는 설정 — 첫 승인';
  static const String requestLabel = '첫 승인 요청';
  static const String candidateNotice = '요청 뒤 30일 냉각이 끝나야 승인할 수 있습니다';

  /// 해시 전 = 승인 없음.
  static const String noApproved = '승인 없음';

  /// 변경 유형 글자.
  static String category(RuleChangeType t) => switch (t) {
    RuleChangeType.infra => '인프라',
    RuleChangeType.strategyRule => '전략 규칙',
    RuleChangeType.bugfix => '버그 수정',
  };

  /// «승인 없음 → 3f2a9c1d» · «a1b2c3d4 → 3f2a9c1d».
  static String hash(String before, String after) =>
      '${before == kNoApprovedConfig ? noApproved : _head8(before)} → ${_head8(after)}';

  /// «MM-DD HH:mm 요청».
  static String requested(DateTime utc) => '${_mdHm(utc)} 요청';

  /// 냉각 글자.
  static String coolingUntil(DateTime endUtc) =>
      '냉각 중 — ${_mdHm(endUtc)} 이후 승인';
  static const String coolingDone = '냉각 끝';
  static String coolingUnknown(DateTime endUtc) =>
      '서버 시각을 확인하지 못했습니다 — ${_mdHm(endUtc)} 이후 승인';

  /// 상태 글자.
  static const String stateCooling = '냉각 중';
  static const String stateApprovable = '승인할 수 있습니다';
  static const String stateTimeUnknown = '서버 시각 확인 대기';
  static const String stateBlocked = '지금은 승인할 수 없습니다';

  /// 승인 · 취소 버튼.
  static const String approveLabel = '승인하기';
  static const String cancelLabel = '요청 거두기';
}

String _head8(String h) => h.length <= 8 ? h : h.substring(0, 8);

String _mdHm(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(k.month)}-${two(k.day)} ${two(k.hour)}:${two(k.minute)}';
}

/// 기준 «규칙 변경 기준 YYYY-MM-DD HH:mm»(관측 = 기기 시각).
AsOf ruleChangeGateAsOf(DateTime nowUtc) {
  final String day = kstDateText(nowUtc);
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kRuleChangeGateStaleAfter,
    label: '규칙 변경 기준 $day ${two(k.hour)}:${two(k.minute)}',
  );
}

/// 첫 승인 후보(엔진 분류 · 자기 신고 0).
class RuleChangeCandidate {
  /// 후보를 만든다.
  const RuleChangeCandidate({required this.hashAfter});

  /// 유형(첫 승인 = 전략 규칙 · 미결 205 ⓑ 권고).
  RuleChangeType get changeType => RuleChangeType.strategyRule;

  /// 전 hash(승인 0 = `NONE`).
  String get hashBefore => kNoApprovedConfig;

  /// 후 hash(지금 config 지문).
  final String hashAfter;

  /// 후보 id = 후 hash(제출 때 엔진이 다시 셈해 맞춰 본다 — 다르면 `RULE_CHANGE_BASE_STALE`).
  String get candidateId => hashAfter;
}

/// 열린 요청 한 줄(원장 `queue()` 그대로 — 엔진 입력).
class RuleChangeGateItem {
  /// 줄을 만든다.
  const RuleChangeGateItem({
    required this.requestId,
    required this.changeType,
    required this.hashBefore,
    required this.hashAfter,
    required this.requestedAtUtc,
  });

  /// 요청 id.
  final String requestId;

  /// 유형.
  final RuleChangeType changeType;

  /// hash 전 · 후.
  final String hashBefore, hashAfter;

  /// 요청 시각(신뢰 시각).
  final DateTime requestedAtUtc;
}

/// 첫 승인 후보(미결 205 ⓐ) — 승인 0 ∧ 지금 등재 ∧ 그 지문의 열린 요청 0 → 후보 · 그 밖 = null.
RuleChangeCandidate? ruleChangeCandidateOf({
  required String approvedHash,
  required String? currentHash,
  required bool currentRegistered,
  required Iterable<RuleChangeGateItem> open,
}) {
  final String? cur = currentHash?.trim();
  if (!isFirstApproval(approvedHash) || cur == null || cur.isEmpty) {
    return null;
  }
  if (!currentRegistered) return null;
  if (open.any((RuleChangeGateItem i) => i.hashAfter == cur)) return null;
  return RuleChangeCandidate(hashAfter: cur);
}

/// 지금 승인할 수 있나(사람 칸만 채워 엔진 판정을 부른다 — 냉각 · 창 · DD · 신뢰 시각 · 결정됨 · 기준).
bool ruleChangeApprovable({
  required RuleChangeGateItem item,
  required String approvedHash,
  required double drawdown,
  required DateTime? trustedNowUtc,
}) =>
    ruleChangeApproveRejectCode(
      nowUtc: trustedNowUtc,
      request: RuleChangeRequestFacts(
        requestedAtUtc: item.requestedAtUtc,
        hashBefore: item.hashBefore,
        decided: false,
      ),
      currentApproved: approvedHash,
      drawdown: drawdown,
      goldenChanged: false,
      approver: '-',
      thirdPartyNotified: true,
    ) ==
    null;

/// M5-9 한 화면 — [canWrite] = 요청 · 승인 · 취소를 낼 창구가 있나 · [lockedLabel] = 운영 등급 생체 축소(지금 조립 = null).
RuleChangeGateVm ruleChangeGateVmOf({
  required String approvedHash,
  required String? currentHash,
  required bool currentRegistered,
  required List<RuleChangeGateItem> open,
  required double drawdown,
  required DateTime? trustedNowUtc,
  required DateTime nowUtc,
  required bool canWrite,
  String? lockedLabel,
}) {
  final bool act = canWrite && lockedLabel == null;
  final bool first = isFirstApproval(approvedHash);
  final RuleChangeCandidate? cand = ruleChangeCandidateOf(
    approvedHash: approvedHash,
    currentHash: currentHash,
    currentRegistered: currentRegistered,
    open: open,
  );
  final List<RuleChangeQueueRow> rows = <RuleChangeQueueRow>[
    for (final RuleChangeGateItem i in open)
      () {
        final DateTime end = i.requestedAtUtc.add(kRuleChangeCooling);
        final bool approvable = ruleChangeApprovable(
          item: i,
          approvedHash: approvedHash,
          drawdown: drawdown,
          trustedNowUtc: trustedNowUtc,
        );
        final bool cooling =
            trustedNowUtc != null && trustedNowUtc.isBefore(end);
        return RuleChangeQueueRow(
          requestId: i.requestId,
          categoryLabel: RuleChangeGateTexts.category(i.changeType),
          hashText: RuleChangeGateTexts.hash(i.hashBefore, i.hashAfter),
          requestedText: RuleChangeGateTexts.requested(i.requestedAtUtc),
          coolingText: trustedNowUtc == null
              ? RuleChangeGateTexts.coolingUnknown(end)
              : cooling
              ? RuleChangeGateTexts.coolingUntil(end)
              : RuleChangeGateTexts.coolingDone,
          stateLabel: approvable
              ? RuleChangeGateTexts.stateApprovable
              : trustedNowUtc == null
              ? RuleChangeGateTexts.stateTimeUnknown
              : cooling
              ? RuleChangeGateTexts.stateCooling
              : RuleChangeGateTexts.stateBlocked,
          level: approvable
              ? UiLevel.act
              : trustedNowUtc == null || cooling
              ? UiLevel.watch
              : UiLevel.blocked,
          approveLabel: approvable && act
              ? RuleChangeGateTexts.approveLabel
              : null,
          cancel: act
              ? SafetyActionCall(
                  id: SafetyActionId.ruleChangeCancel,
                  args: <String, String>{'request_id': i.requestId},
                  label: RuleChangeGateTexts.cancelLabel,
                )
              : null,
        );
      }(),
  ];
  final bool anyApprovable = rows.any(
    (RuleChangeQueueRow r) =>
        r.stateLabel == RuleChangeGateTexts.stateApprovable,
  );
  final String? cur = currentHash?.trim();
  final bool differs =
      !first && cur != null && cur.isNotEmpty && cur != approvedHash;
  final (String headline, UiLevel level) = rows.isNotEmpty
      ? (anyApprovable
            ? (RuleChangeGateTexts.headlineApprovable, UiLevel.act)
            : (RuleChangeGateTexts.headlineCooling, UiLevel.watch))
      : cand != null
      ? (RuleChangeGateTexts.headlineFirst, UiLevel.act)
      : first
      ? (RuleChangeGateTexts.headlineNoConfig, UiLevel.info)
      : differs
      ? (RuleChangeGateTexts.headlineDiffers, UiLevel.watch)
      : (RuleChangeGateTexts.headlineApproved, UiLevel.ok);
  return RuleChangeGateVm(
    headline: headline,
    level: level,
    windowText: first ? RuleChangeGateTexts.windowFirst : null,
    candidates: <RuleChangeCandidateRow>[
      if (cand != null && act)
        RuleChangeCandidateRow(
          candidateId: cand.candidateId,
          label: RuleChangeGateTexts.candidateLabel,
          categoryLabel: RuleChangeGateTexts.category(cand.changeType),
          hashText: RuleChangeGateTexts.hash(cand.hashBefore, cand.hashAfter),
          requestLabel: RuleChangeGateTexts.requestLabel,
          noticeText: RuleChangeGateTexts.candidateNotice,
        ),
    ],
    rows: rows,
    emptyLabel: rows.isNotEmpty || cand != null
        ? null
        : first
        ? RuleChangeGateTexts.emptyNoConfig
        : differs
        ? RuleChangeGateTexts.emptyDiffers
        : RuleChangeGateTexts.emptyApproved,
    lockedLabel: lockedLabel,
    asOf: ruleChangeGateAsOf(nowUtc),
  );
}

/// 결과 글자(표본 제안 문장) — (수준, 문장).
(UiLevel, String) _resultText(SafetyActionId id, String? code) {
  const String timeReq = '서버 시각을 확인하지 못해 요청하지 않았습니다.';
  const String timeAppr = '서버 시각을 확인하지 못해 승인하지 않았습니다.';
  const String timeCancel = '서버 시각을 확인하지 못해 거두지 않았습니다.';
  const String decided = '이 요청은 이미 결정됐습니다.';
  const String notFound = '이 요청을 찾지 못했습니다.';
  const String stale = '승인된 설정이 그 사이 바뀌었습니다 — 화면을 다시 열어 주십시오.';
  const String bio = '생체 확인을 할 수 없어 진행하지 않았습니다.';
  if (id == SafetyActionId.ruleChangeRequest) {
    return switch (code) {
      null => (UiLevel.ok, '첫 승인을 요청했습니다 — 30일 냉각 뒤 승인할 수 있습니다.'),
      RuleChangeCodes.fieldsMissing => (UiLevel.act, '사유와 되돌리는 방법을 적어 주십시오.'),
      RuleChangeCodes.journalMissing => (UiLevel.act, '결정 저널 세 칸을 채워 주십시오.'),
      RuleChangeCodes.configUnknown => (UiLevel.blocked, '이 설정 기록을 찾지 못했습니다.'),
      RuleChangeCodes.baseStale => (UiLevel.watch, stale),
      RuleChangeCodes.trustedTimeUnknown => (UiLevel.blocked, timeReq),
      kJournalIdTaken => (UiLevel.blocked, '같은 저널 번호가 이미 있어 요청하지 않았습니다.'),
      kBiometricUnavailable => (UiLevel.blocked, bio),
      final String other => throw ArgumentError.value(
        other,
        'code',
        '모르는 요청 거부 코드',
      ),
    };
  }
  if (id == SafetyActionId.ruleChangeCancel) {
    return switch (code) {
      null => (UiLevel.ok, '규칙 변경 요청을 거두었습니다.'),
      RuleChangeCodes.decided => (UiLevel.info, decided),
      RuleChangeCodes.notFound => (UiLevel.info, notFound),
      RuleChangeCodes.trustedTimeUnknown => (UiLevel.blocked, timeCancel),
      kBiometricUnavailable => (UiLevel.blocked, bio),
      final String other => throw ArgumentError.value(
        other,
        'code',
        '모르는 취소 거부 코드',
      ),
    };
  }
  if (id == SafetyActionId.ruleChangeApprove) {
    return switch (code) {
      null => (UiLevel.ok, '규칙 변경을 승인했습니다 — 정해진 때부터 적용됩니다.'),
      RuleChangeCodes.cooling => (
        UiLevel.watch,
        '아직 기다리는 기간입니다 — 기간이 끝난 뒤 승인할 수 있습니다.',
      ),
      RuleChangeCodes.ddLocked => (UiLevel.blocked, '낙폭이 커서 규칙 변경을 잠가 두었습니다.'),
      RuleChangeCodes.thirdPartyMissing => (UiLevel.act, '제3자에게 알렸는지 확인하십시오.'),
      RuleChangeCodes.approvalFieldsMissing => (
        UiLevel.act,
        '골든 영향과 승인자를 적어 주십시오.',
      ),
      RuleChangeCodes.outOfWindow => (UiLevel.blocked, '12월 창 밖이라 승인할 수 없습니다.'),
      RuleChangeCodes.decided => (UiLevel.info, decided),
      RuleChangeCodes.notFound => (UiLevel.info, notFound),
      RuleChangeCodes.baseStale => (UiLevel.watch, stale),
      RuleChangeCodes.trustedTimeUnknown => (UiLevel.blocked, timeAppr),
      kBiometricUnavailable => (UiLevel.blocked, bio),
      final String other => throw ArgumentError.value(
        other,
        'code',
        '모르는 승인 거부 코드',
      ),
    };
  }
  throw ArgumentError.value(id, 'id', '규칙 변경 동작이 아니다');
}

/// 저널 번호 겹침(계약 `JOURNAL_ID_TAKEN`).
const String kJournalIdTaken = 'JOURNAL_ID_TAKEN';

/// 생체 확인 불가(계약 `BIOMETRIC_UNAVAILABLE`).
const String kBiometricUnavailable = 'BIOMETRIC_UNAVAILABLE';

/// 규칙 변경 동작 결과 — [code] null = 실행됨 · 글자 = 엔진(표본 제안 문장).
SafetyActionResult ruleChangeActionResultOf({
  required SafetyActionId id,
  required String actionRunId,
  String? code,
}) {
  final (UiLevel level, String headline) = _resultText(id, code);
  return SafetyActionResult(
    actionRunId: actionRunId,
    id: id,
    level: level,
    headline: headline,
    reasonCode: code,
    retryable: false,
  );
}
