// 서약 읽기 모델 · 서약 동작 결과(M5-8 · O-04 ② · 01 §30 K16 · 설계 13 §8 R67 · R157).
//
// 🔴 [pledgeVmOf] = 지금 판 원문 그대로 · 엔진 글자가 없는 칸(`statusLine` · `replayNotice` · `lockedLabel`) = null(K16).
//    `editable` = 판 있음 ∧ 신뢰 시각으로 본 한국 12월(R67 Z2 — 화면이 달력으로 판정하지 않는다 · 시각 모름 = 거짓).
// 🔴 [pledgeActionResultOf] = 엔진 저장소 결과 코드 → 결과(등급 · 문장) — 문장은 계약 표본
//    (`m5/safety_action_results`)과 같은 글자 · 모르는 코드 = [StateError](조용히 일반 문구로 넘기지 않는다).

import 'dart:convert' show jsonEncode, utf8;

import 'package:crypto/crypto.dart' show sha256;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        PledgeSubmission,
        PledgeVm,
        SafetyActionId,
        SafetyActionResult,
        TradeDate,
        UiLevel;

import '../ops/ledger_views.dart' show kstDateText;
import 'pledge.dart' show Pledge, PledgeCodes;
import 'rule_change.dart' show kRuleChangeWindowMonth;

/// 서약 읽기 모델의 기준 유효 시간(다른 안전 화면 표본과 같은 26시간).
const Duration kPledgeStaleAfter = Duration(hours: 26);

/// 서약 동작 결과 문장(엔진 글자 · 표본 `m5/safety_action_results` 와 같다).
abstract final class PledgeResultTexts {
  /// 첫 판 저장.
  static const String written = '서약 첫 판을 저장했습니다.';

  /// 편집 저장.
  static const String edited = '서약을 고쳤습니다 — 새 판을 저장했습니다.';

  /// 세 문장 중 빈칸.
  static const String sentencesMissing = '세 문장을 모두 적어야 저장합니다.';

  /// 12월 창 밖.
  static const String outOfWindow = '서약은 12월에만 고칠 수 있습니다 — 지금 판을 그대로 둡니다.';

  /// 지금 판과 같음.
  static const String unchanged = '지금 판과 같습니다 — 새 판을 만들지 않았습니다.';

  /// 신뢰 시각 모름.
  static const String trustedTimeUnknown = '서버 시각을 확인하지 못해 저장하지 않았습니다.';

  /// 첫 판이 이미 있음.
  static const String alreadyWritten = '서약 첫 판이 이미 있습니다 — 원문은 한 번만 씁니다.';

  /// 편집 저널 없음.
  static const String journalMissing = '고치기 전에 적는 저널이 연결되지 않아 저장하지 않았습니다.';

  /// 첫 판 없음(편집할 것이 없다).
  static const String notWritten = '서약 첫 판이 없어 고칠 것이 없습니다.';
}

/// `command_inbox.payload_digest` — 제출 JSON 의 SHA-256 16진(원문 재저장 금지 — 알림 확인 · 실입금 등록 선례).
String pledgeSubmissionDigest(PledgeSubmission submission) =>
    sha256.convert(utf8.encode(jsonEncode(submission.toJson()))).toString();

/// 서약 읽기 모델 기준(관측 = 지금 · 거래일 = 한국 오늘).
AsOf pledgeAsOf(DateTime nowUtc) {
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  final String day = kstDateText(nowUtc);
  return AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kPledgeStaleAfter,
    label: '서약 기준 $day ${two(k.hour)}:${two(k.minute)}',
  );
}

/// 🔴 서약 읽기 모델 — [current] = 지금 판(없으면 0줄) · [trustedNowUtc] = 신뢰 시각(모르면 null) · [nowUtc] = 기기 시각(기준 줄).
PledgeVm pledgeVmOf({
  required Pledge? current,
  required DateTime? trustedNowUtc,
  required DateTime nowUtc,
}) {
  final DateTime? t = trustedNowUtc;
  final bool editable =
      current != null &&
      t != null &&
      int.parse(kstDateText(t).substring(5, 7)) == kRuleChangeWindowMonth;
  return PledgeVm(
    lines: current?.lines ?? const <String>[],
    editable: editable,
    asOf: pledgeAsOf(nowUtc),
  );
}

/// 🔴 서약 동작 결과 — [reasonCode] null = 실행 · 그 밖 = 거부(등급 · 문장 = 엔진) · 모르는 코드 = [StateError].
SafetyActionResult pledgeActionResultOf({
  required String actionRunId,
  required SafetyActionId id,
  required String? reasonCode,
}) {
  if (id != SafetyActionId.pledgeWrite && id != SafetyActionId.pledgeEdit) {
    throw ArgumentError.value(id, 'id', '서약 동작이 아니다');
  }
  final (UiLevel, String) look = switch (reasonCode) {
    null => (
      UiLevel.ok,
      id == SafetyActionId.pledgeWrite
          ? PledgeResultTexts.written
          : PledgeResultTexts.edited,
    ),
    PledgeCodes.sentencesMissing => (
      UiLevel.act,
      PledgeResultTexts.sentencesMissing,
    ),
    PledgeCodes.outOfWindow => (UiLevel.watch, PledgeResultTexts.outOfWindow),
    PledgeCodes.unchanged => (UiLevel.info, PledgeResultTexts.unchanged),
    PledgeCodes.trustedTimeUnknown => (
      UiLevel.blocked,
      PledgeResultTexts.trustedTimeUnknown,
    ),
    PledgeCodes.alreadyWritten => (
      UiLevel.info,
      PledgeResultTexts.alreadyWritten,
    ),
    PledgeCodes.journalMissing => (
      UiLevel.act,
      PledgeResultTexts.journalMissing,
    ),
    PledgeCodes.notWritten => (UiLevel.act, PledgeResultTexts.notWritten),
    _ => throw StateError('서약 결과 코드 $reasonCode: 문장 없음'),
  };
  return SafetyActionResult(
    actionRunId: actionRunId,
    id: id,
    level: look.$1,
    headline: look.$2,
    reasonCode: reasonCode,
    retryable: false,
  );
}
