// 🆕 미결 220 ⓔⓕ — `J-3` 사전 저널 쓰기(순수 · 계약 v1.35 01 §44 K296 ~ K300 · 02 §3-3 · 설계 13 §8 R245).
//
// 🔴 J-3 키 = **저널 id**(`decision_journal.journal_id` · 안전 동작 `decision_id` 와 한 벌 · K296) — 화면은 키를 짓지 않는다.
// 🔴 제출 갈래 = 엔진이 키로 가른다(K297 · 화면 분기 0):
//    ⓐ 채우기 — 키 = 있는 저널 행 · 사전 3칸 중 빈 칸이 있다(SAF-408 미완성) → 빈 칸만 채운다(채워진 칸 덮지 않음 · kind 유지) ·
//       셋 다 찼다 = `JOURNAL_ALREADY_EXISTS`.
//    ⓑ 새 행 — 키 = 엔진이 발급한 새 저널 id(행 없음 · 목적 = 키에 싣는다 — [issueJournalDraftKey]) → 새 행(kind = 목적 ∈
//       `DecisionJournalKinds.draftPurposes` · `is_deviation` = 재량 1 · 서약 편집 0) · 같은 키 두 번째 = 이미 있음(채우기 갈래 · 셋 다 참).
//    둘 다 아님 = `JOURNAL_TARGET_UNKNOWN`.
// 🔴 입력 판정(K298) = 화면 «제출 가능 조건»(02 §3-3 ⓓ)과 같은 판정을 엔진이 다시 · 거부 = `JOURNAL_INPUT_INVALID` ·
//    인용 규칙 = 그 폼 선택지 코드만(`JournalRuleCitedCodes` · K300) · 문구 = 접수증 `stateLabel`(화면 분기 · 표시 0).
// 🔴 신뢰 시각 비의존(K299 · RECON 해제 선례) — 시각 = 기기 시계 UTC · 한국 날 · 순서 = 원장 트랜잭션 차례.
// 🔴 글자 = 표본(`m6/journal_draft_spec_*` · `journal_draft_receipts_5` · `journal_draft_receipts_reject_2`) 문장 그대로 + 표본 밖 = 엔진.
// 🔵 새 행 키를 화면에 싣는 VM 칸(재량 조정 · 서약 편집의 J-3 링크) = 다음 M5 계약 판(01 §8 미결 188 남은 몫) — 지금은 발급 함수만.

import 'dart:convert' show jsonEncode, utf8;
import 'dart:math' show Random;

import 'package:crypto/crypto.dart' show sha256;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        ChipTone,
        CommandKind,
        CommandReceipt,
        CommandState,
        DecisionJournalKinds,
        DeviationBadge,
        DeviationKindCodes,
        JournalDraft,
        JournalDraftFormSpec,
        JournalDraftRejectCodes,
        JournalRuleCitedCodes,
        ReasonChip,
        ReasonOption,
        TradeDate;

import '../safety/discretion.dart' show DiscretionBudget, kDiscretionMaxUses;
import 'alert_ack_command.dart' show newCommandId;
import 'journal_view.dart' show JournalTexts;
import 'ledger_views.dart' show kReconStaleAfter, kstDateText;

/// J-3 명령 TTL(알림 확인 · 실입금 등록 · 모의 개시와 같은 값 — 표본 `journal_draft_receipts_5` 의 요청 → 만료 30분).
const Duration kJournalDraftTtl = Duration(minutes: 30);

/// 근거 최소 글자(표본 `m6/journal_draft_spec_*` 의 `rationale_min_chars` 그대로 · 엔진 첫 값 · 화면은 글자로 안내하지 않는다).
const int kJournalRationaleMinChars = 40;

/// 새 행 키 접두(`JD-<목적>-<16 hex>` — 목적 = `DecisionJournalKinds.draftPurposes`).
const String kJournalDraftKeyPrefix = 'JD-';

final RegExp _nonce = RegExp(r'^[0-9a-f]{16}$');

/// 🆕 ⓕ — 새 저널 id 발급(목적을 키에 싣는다 — 표 0 · 스키마 0) · 목적 ∉ 새 행 목적 = [ArgumentError].
String issueJournalDraftKey({required String purpose, required Random random}) {
  if (!DecisionJournalKinds.draftPurposes.contains(purpose)) {
    throw ArgumentError.value(purpose, 'purpose', 'J-3 새 행 목적 아님');
  }
  final String nonce = <String>[
    for (int i = 0; i < 8; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
  return '$kJournalDraftKeyPrefix$purpose-$nonce';
}

/// 🆕 ⓕ — 새 행 키 → 목적(엔진이 낸 꼴이 아니면 null — `JOURNAL_TARGET_UNKNOWN`).
String? journalDraftPurposeOfKey(String key) {
  if (!key.startsWith(kJournalDraftKeyPrefix)) return null;
  final String rest = key.substring(kJournalDraftKeyPrefix.length);
  final int cut = rest.lastIndexOf('-');
  if (cut <= 0) return null;
  final String purpose = rest.substring(0, cut);
  if (!DecisionJournalKinds.draftPurposes.contains(purpose)) return null;
  return _nonce.hasMatch(rest.substring(cut + 1)) ? purpose : null;
}

/// J-3 글자(표본 문장 · 표본 밖 = 엔진).
abstract final class JournalDraftTexts {
  /// 폼 고지(표본 `notice_line`).
  static const String notice = '저장 후 수정할 수 없습니다. 정정은 새 글로 남습니다.';

  /// 기준 줄(표본 «저널 기준 2026-08-31»).
  static String asOfLabel(String day) => '저널 기준 $day';

  /// 접수증 — 저장(표본).
  static const String executed = '저장됨 — 사전 저널이 기록되었습니다';

  /// 접수증 — 보류(표본).
  static const String held =
      '보류됨 — 원장 무결성 점검 중이라 보관했습니다. 복구 뒤 일괄 확정 단계에서 처리됩니다';

  /// 접수증 — 이미 있음(표본).
  static const String alreadyExists =
      '거부됨 — 이 결정의 사전 저널이 이미 있습니다. 입력값은 그대로 남아 있습니다';

  /// 접수증 — 대상 없음(표본).
  static const String targetUnknown =
      '거부됨 — 이 저널 대상을 찾을 수 없습니다. 입력값은 그대로 남아 있습니다';

  /// 접수증 — 입력 조건(표본).
  static const String inputInvalid =
      '거부됨 — 근거 · 기대 결과 · 인용 규칙 · 메모 조건을 다시 확인하십시오. 입력값은 그대로 남아 있습니다';

  /// 목적 칩 — 재량 조정 요청(표본).
  static const String discretionChip = '재량 조정 요청';

  /// 목적 칩 — 서약 편집(엔진).
  static const String pledgeEditChip = '서약 편집';

  /// 배지 — 재량 조정(표본 «재량 조정 (롤링 12개월 4회 중 2회째)» · 신뢰 시각 모름 = 머리만).
  static String discretionBadge(DiscretionBudget? b) => b == null
      ? '재량 조정'
      : b.used >= b.max
      ? '재량 조정 (롤링 12개월 ${b.max}회 소진)'
      : '재량 조정 (롤링 12개월 ${b.max}회 중 ${b.used + 1}회째)';

  /// 배지 — 채우기 갈래(엔진 · 사전 3칸이 빈 이탈).
  static const String fillBadge = '사전 저널을 채워야 하는 이탈';
}

/// 인용 규칙 선택지(K300 · 표본 3 = 엔진 첫 목록 · 메모 필수 = `RULE_OTHER` 하나).
final List<ReasonOption> kJournalRuleCitedOptions =
    List<ReasonOption>.unmodifiable(<ReasonOption>[
      ReasonOption(
        code: JournalRuleCitedCodes.discretionBudget,
        label: '재량 예산(롤링 12개월 $kDiscretionMaxUses회) 안에서 조정',
        requiresNote: false,
      ),
      const ReasonOption(
        code: JournalRuleCitedCodes.reconCause,
        label: '대사 불일치 — 원인 코드 확인 후 해소',
        requiresNote: false,
      ),
      const ReasonOption(
        code: JournalRuleCitedCodes.other,
        label: '그 밖의 규칙(메모 필수)',
        requiresNote: true,
      ),
    ]);

/// 인용 규칙 글자(J-3R `ruleCitedLabel` — 코드면 선택지 글자 · 원문이면 원문 · K300).
String journalRuleCitedLabelOf(String? ruleCited) {
  if (ruleCited == null) return '';
  for (final ReasonOption o in kJournalRuleCitedOptions) {
    if (o.code == ruleCited) return o.label;
  }
  return ruleCited;
}

/// 재량 예산을 쓰는 목적(K300 — 서약 줄을 싣는다) · 그 밖 = 0줄.
const Set<String> kJournalPledgePurposes = <String>{
  DeviationKindCodes.discretion,
  DeviationKindCodes.manualOrder,
  DeviationKindCodes.manualEntry,
};

/// J-3 대상(키 해석 결과).
sealed class JournalDraftTarget {
  const JournalDraftTarget(this.key);

  /// J-3 키(저널 id).
  final String key;
}

/// ⓐ 채우기 — 있는 저널 행.
final class JournalDraftFill extends JournalDraftTarget {
  /// 만든다.
  const JournalDraftFill(
    super.key, {
    required this.isDeviation,
    this.kind,
    this.rationaleBefore,
    this.expectedOutcome,
    this.ruleCited,
  });

  /// 이탈 저널인가.
  final bool isDeviation;

  /// 저널 kind(옛 행 = null).
  final String? kind;

  /// 실행 전 근거(빈 칸 = null).
  final String? rationaleBefore;

  /// 기대 결과(빈 칸 = null).
  final String? expectedOutcome;

  /// 인용 규칙(빈 칸 = null).
  final String? ruleCited;

  /// 사전 3칸이 다 찼나(K297 — 다 찼으면 이미 있음).
  bool get complete =>
      rationaleBefore != null && expectedOutcome != null && ruleCited != null;
}

/// ⓑ 새 행 — 엔진이 발급한 새 키(행 없음).
final class JournalDraftNew extends JournalDraftTarget {
  /// 만든다.
  const JournalDraftNew(super.key, {required this.purpose});

  /// 목적(`DISCRETION` · `PLEDGE_EDIT`).
  final String purpose;

  /// 새 행의 이탈 여부(재량 1 · 서약 편집 0 — K297).
  bool get isDeviation => purpose == DecisionJournalKinds.discretion;
}

/// 키 해석(엔진) — [row] = 그 키의 저널 행(없음 = null) → 채우기 · 새 행 · 모름(null).
JournalDraftTarget? journalDraftTargetOf(String key, JournalDraftFill? row) {
  if (row != null) return row;
  final String? purpose = journalDraftPurposeOfKey(key);
  return purpose == null ? null : JournalDraftNew(key, purpose: purpose);
}

DeviationBadge _badgeOf(JournalDraftTarget t, DiscretionBudget? budget) =>
    switch (t) {
      JournalDraftNew(:final String purpose) =>
        purpose == DecisionJournalKinds.discretion
            ? DeviationBadge(
                isDeviation: true,
                kindCode: DeviationKindCodes.discretion,
                label: JournalDraftTexts.discretionBadge(budget),
              )
            : const DeviationBadge(
                isDeviation: false,
                label: JournalTexts.ruleBound,
              ),
      JournalDraftFill(:final bool isDeviation, :final String? kind) =>
        !isDeviation
            ? const DeviationBadge(
                isDeviation: false,
                label: JournalTexts.ruleBound,
              )
            : kind == DeviationKindCodes.discretion
            ? DeviationBadge(
                isDeviation: true,
                kindCode: kind,
                label: JournalDraftTexts.discretionBadge(budget),
              )
            : DeviationBadge(
                isDeviation: true,
                kindCode: DeviationKindCodes.values.contains(kind)
                    ? kind
                    : null,
                label: JournalDraftTexts.fillBadge,
              ),
    };

ReasonChip? _purposeChipOf(String? purpose) => switch (purpose) {
  DecisionJournalKinds.discretion => const ReasonChip(
    code: DecisionJournalKinds.discretion,
    label: JournalDraftTexts.discretionChip,
    tone: ChipTone.caution,
    detailDeepLink: 'handbook://safety/discretion',
  ),
  DecisionJournalKinds.pledgeEdit => const ReasonChip(
    code: DecisionJournalKinds.pledgeEdit,
    label: JournalDraftTexts.pledgeEditChip,
    tone: ChipTone.neutral,
  ),
  _ => null,
};

/// J-3 폼 스펙(K296 · K300) — [pledgeLines] = 지금 서약 판(서약 전 = 0줄) · [budget] = 재량 예산(신뢰 시각 모름 = null) ·
/// [nowUtc] = 기기 시계(K299).
/// 🔴 서약 줄 = 재량 예산을 쓰는 목적에만(배지 kind ∈ [kJournalPledgePurposes]) · 문맥 칩 = 목적 칩(사전에 있을 때) +
///    대상 문맥 0(사전 = 01 §8 미결 166 — 지어내지 않는다).
JournalDraftFormSpec journalDraftFormSpecOf(
  JournalDraftTarget t, {
  required List<String> pledgeLines,
  required DiscretionBudget? budget,
  required DateTime nowUtc,
}) {
  final DeviationBadge badge = _badgeOf(t, budget);
  final String? purpose = switch (t) {
    JournalDraftNew(:final String purpose) => purpose,
    JournalDraftFill(:final String? kind) => kind,
  };
  final ReasonChip? chip = _purposeChipOf(purpose);
  final String day = kstDateText(nowUtc);
  return JournalDraftFormSpec(
    decisionId: t.key,
    pledgeLines: kJournalPledgePurposes.contains(badge.kindCode)
        ? List<String>.unmodifiable(pledgeLines)
        : const <String>[],
    contextChips: <ReasonChip>[?chip],
    deviation: badge,
    ruleCitedOptions: kJournalRuleCitedOptions,
    rationaleMinChars: kJournalRationaleMinChars,
    noticeLine: JournalDraftTexts.notice,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(day),
      source: AsOfSource.localSqlite,
      staleAfter: kReconStaleAfter,
      label: JournalDraftTexts.asOfLabel(day),
    ),
  );
}

/// 입력 판정(K298 — 화면 «제출 가능 조건» 그대로) · 통과 = null · 거부 = `JOURNAL_INPUT_INVALID`.
String? journalDraftInputRejectOf(JournalDraft d) {
  ReasonOption? rule;
  for (final ReasonOption o in kJournalRuleCitedOptions) {
    if (o.code == d.ruleCited) rule = o;
  }
  final bool ok =
      rule != null &&
      d.rationaleBefore.trim().length >= kJournalRationaleMinChars &&
      d.expectedOutcome.trim().isNotEmpty &&
      (!rule.requiresNote || (d.note ?? '').trim().isNotEmpty);
  return ok ? null : JournalDraftRejectCodes.journalInputInvalid;
}

/// 갈래 판정(K297) — 통과 = null · 대상 없음 · 이미 있음 · 입력 조건.
String? journalDraftRejectOf(JournalDraftTarget? t, JournalDraft d) {
  if (t == null) return JournalDraftRejectCodes.journalTargetUnknown;
  if (t is JournalDraftFill && t.complete) {
    return JournalDraftRejectCodes.journalAlreadyExists;
  }
  return journalDraftInputRejectOf(d);
}

/// 접수증 문장(표본) — 거부 코드 · 보류 · 저장.
String journalDraftStateLabelOf({String? rejectCode, bool held = false}) {
  if (held) return JournalDraftTexts.held;
  return switch (rejectCode) {
    null => JournalDraftTexts.executed,
    JournalDraftRejectCodes.journalAlreadyExists =>
      JournalDraftTexts.alreadyExists,
    JournalDraftRejectCodes.journalTargetUnknown =>
      JournalDraftTexts.targetUnknown,
    JournalDraftRejectCodes.journalInputInvalid =>
      JournalDraftTexts.inputInvalid,
    final String c => throw ArgumentError.value(c, 'rejectCode', '모르는 J-3 거부'),
  };
}

/// J-3 명령(폰 발행 · 기기 시계 — K299).
class JournalDraftCommand {
  /// 만든다.
  const JournalDraftCommand({
    required this.commandId,
    required this.draft,
    required this.requestedAt,
    required this.expiresAt,
    required this.nonce,
    required this.issuedByDeviceId,
  });

  /// 명령 id.
  final String commandId;

  /// 제출 원문(원장에는 사전 3칸 · 메모만 — 수신함 = digest).
  final JournalDraft draft;

  /// 요청 시각(기기 시계 UTC).
  final DateTime requestedAt;

  /// 만료(TTL).
  final DateTime expiresAt;

  /// 1회용 값.
  final String nonce;

  /// 낸 기기.
  final String issuedByDeviceId;

  /// `command_inbox.payload_digest` — 페이로드 JSON 의 SHA-256 16진(원문 재저장 금지).
  String get payloadDigest =>
      sha256.convert(utf8.encode(jsonEncode(draft.toJson()))).toString();

  /// 접수증.
  CommandReceipt receipt({
    required CommandState state,
    required String stateLabel,
    String? rejectReasonCode,
  }) => CommandReceipt(
    commandId: commandId,
    kind: CommandKind.journalDraft,
    state: state,
    stateLabel: stateLabel,
    requestedAt: requestedAt,
    expiresAt: expiresAt,
    nonce: nonce,
    issuedByDeviceId: issuedByDeviceId,
    rejectReasonCode: rejectReasonCode,
  );
}

/// J-3 명령을 낸다 — [nowUtc] = 기기 시계(K299) · [random] = 명령 id · nonce 원천.
JournalDraftCommand issueJournalDraft({
  required JournalDraft draft,
  required DateTime nowUtc,
  required String deviceId,
  required Random random,
}) {
  final DateTime at = nowUtc.toUtc();
  return JournalDraftCommand(
    commandId: newCommandId(random),
    draft: draft,
    requestedAt: at,
    expiresAt: at.add(kJournalDraftTtl),
    nonce: <String>[
      for (int i = 0; i < 16; i++)
        random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join(),
    issuedByDeviceId: deviceId,
  );
}
