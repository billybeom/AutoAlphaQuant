// 규칙 변경 게이트(M5-9) · SAF-405 기동 통제
// (03_운영 §6-4 드로다운 락 · §6-5 ③~⑤ · §6-8 CHANGELOG 10칸 · 04 §1 SAF-405 · 02 §2 · §4 `operations.rule_change` ·
//  05 AC-S18 GV-40d · 설계 13 §8 R66).
//
// 🔴 요청은 언제든(큐에 줄 세운다 — DD · 12월 무관) · 취소는 쉽게 · 승인만 막는다.
// 🔴 발주자 결정(2026-11-05): 승인 목록 = 하나 · 유형 셋 같은 게이트 · 제3자 통지 필수 ·
//    첫 승인(승인 목록이 비었을 때) = 냉각 30일만(12월 창 · DD 락 제외).
// 🔴 자동 적용 0 — 승인은 `config_versions.approved` 만 바꾼다(엔진이 쓰는 config 는 M9 «적용»).
// 🔴 SAF-405 = live 만: 미승인 · 행 없음 = 기동 거부(경고 강등 금지).

import 'package:domain_contracts/domain_contracts.dart' show RunMode;

import '../ops/ledger_views.dart' show kstDateText;

/// 냉각(02 §4 `operations.rule_change.cooling_off_days: 30` · §6-5 ③).
const Duration kRuleChangeCooling = Duration(days: 30);

/// 승인 창 달(02 §4 `window_month: 12`).
const int kRuleChangeWindowMonth = 12;

/// 드로다운 락(02 §4 `drawdown_lock_dd: -0.10` · 🔴 경계 포함 = 03_운영 §6-4 «DD ≥ 임계치»).
const double kRuleChangeDrawdownLock = -0.10;

/// 승인 목록이 비었을 때의 «전 hash».
const String kNoApprovedConfig = 'NONE';

/// SAF-405.
const String kSaf405 = 'SAF-405';

/// 변경 유형(02 §2 CHECK · §6-8).
enum RuleChangeType {
  /// 인프라.
  infra('INFRA'),

  /// 전략 규칙.
  strategyRule('STRATEGY_RULE'),

  /// 버그 수정.
  bugfix('BUGFIX');

  const RuleChangeType(this.wire);

  /// 저장 값.
  final String wire;

  /// 저장 값에서 — 모르는 값 = 형식 오류.
  static RuleChangeType fromWire(String wire) {
    for (final RuleChangeType t in values) {
      if (t.wire == wire) return t;
    }
    throw FormatException('모르는 변경 유형', wire);
  }
}

/// 규칙 변경 거부 코드(R66).
abstract final class RuleChangeCodes {
  /// 승인 칸(골든 영향 · 승인자) 빈칸.
  static const String approvalFieldsMissing =
      'RULE_CHANGE_APPROVAL_FIELDS_MISSING';

  /// 전 hash 가 지금 승인된 것이 아니다.
  static const String baseStale = 'RULE_CHANGE_BASE_STALE';

  /// 후 hash 가 `config_versions` 에 없다.
  static const String configUnknown = 'RULE_CHANGE_CONFIG_UNKNOWN';

  /// 냉각 30일 전.
  static const String cooling = 'RULE_CHANGE_COOLING';

  /// 드로다운 락.
  static const String ddLocked = 'RULE_CHANGE_DD_LOCKED';

  /// 이미 결정됐다(취소 · 승인).
  static const String decided = 'RULE_CHANGE_DECIDED';

  /// 요청 칸 빈칸 · 전후 같음.
  static const String fieldsMissing = 'RULE_CHANGE_FIELDS_MISSING';

  /// 저널 미연결.
  static const String journalMissing = 'RULE_CHANGE_JOURNAL_MISSING';

  /// 요청 없음.
  static const String notFound = 'RULE_CHANGE_NOT_FOUND';

  /// 12월 창 밖.
  static const String outOfWindow = 'RULE_CHANGE_OUT_OF_WINDOW';

  /// 제3자 통지 없음.
  static const String thirdPartyMissing = 'RULE_CHANGE_THIRD_PARTY_MISSING';

  /// 신뢰 시각 모름(E11j 코드 재사용).
  static const String trustedTimeUnknown = 'TRUSTED_TIME_UNKNOWN';
}

bool _blank(String? v) => v == null || v.trim().isEmpty;

/// 🔴 저널 연결(R66 Y2) — 행 있음 ∧ 사전 3필드(SAF-408 열) ∧ 요청 하나 = 저널 하나.
bool ruleChangeJournalLinked({
  required bool exists,
  required String? rationaleBefore,
  required String? expectedOutcome,
  required String? ruleCited,
  required bool alreadyUsed,
}) =>
    exists &&
    !_blank(rationaleBefore) &&
    !_blank(expectedOutcome) &&
    !_blank(ruleCited) &&
    !alreadyUsed;

/// 요청 판정(R66 Y2) — 통과 = null · 🔴 DD · 12월은 보지 않는다(줄 세우기).
String? ruleChangeRequestRejectCode({
  required DateTime? nowUtc,
  required String hashBefore,
  required String hashAfter,
  required String reason,
  required String rollbackMethod,
  required String currentApproved,
  required bool afterKnown,
  required bool journalLinked,
}) {
  if (nowUtc == null) return RuleChangeCodes.trustedTimeUnknown;
  if (_blank(hashBefore) ||
      _blank(hashAfter) ||
      hashBefore == hashAfter ||
      _blank(reason) ||
      _blank(rollbackMethod)) {
    return RuleChangeCodes.fieldsMissing;
  }
  if (hashBefore != currentApproved) return RuleChangeCodes.baseStale;
  if (!afterKnown) return RuleChangeCodes.configUnknown;
  if (!journalLinked) return RuleChangeCodes.journalMissing;
  return null;
}

/// 저장된 요청의 사실.
class RuleChangeRequestFacts {
  /// 사실을 만든다.
  const RuleChangeRequestFacts({
    required this.requestedAtUtc,
    required this.hashBefore,
    required this.decided,
  });

  /// 요청 시각(신뢰 시각 · 냉각 시작점).
  final DateTime requestedAtUtc;

  /// 전 hash.
  final String hashBefore;

  /// 이미 결정(취소 · 승인)됐나.
  final bool decided;

  /// 냉각 끝.
  DateTime get coolingEndsAtUtc => requestedAtUtc.add(kRuleChangeCooling);
}

/// 취소 판정(R66 Y3 · 쉽게 — 있음 ∧ 미결정).
String? ruleChangeCancelRejectCode({
  required DateTime? nowUtc,
  required RuleChangeRequestFacts? request,
}) {
  if (nowUtc == null) return RuleChangeCodes.trustedTimeUnknown;
  if (request == null) return RuleChangeCodes.notFound;
  if (request.decided) return RuleChangeCodes.decided;
  return null;
}

/// 첫 승인인가 — 승인 목록이 비었다(발주자 결정 ⓓ).
bool isFirstApproval(String currentApproved) =>
    currentApproved == kNoApprovedConfig;

/// 승인 판정(R66 Y4) — 통과 = null.
String? ruleChangeApproveRejectCode({
  required DateTime? nowUtc,
  required RuleChangeRequestFacts? request,
  required String currentApproved,
  required double drawdown,
  required bool? goldenChanged,
  required String? approver,
  required bool thirdPartyNotified,
}) {
  if (nowUtc == null) return RuleChangeCodes.trustedTimeUnknown;
  if (request == null) return RuleChangeCodes.notFound;
  if (request.decided) return RuleChangeCodes.decided;
  if (request.hashBefore != currentApproved) return RuleChangeCodes.baseStale;
  if (nowUtc.isBefore(request.coolingEndsAtUtc)) {
    return RuleChangeCodes.cooling;
  }
  if (!isFirstApproval(currentApproved)) {
    final int month = int.parse(kstDateText(nowUtc).substring(5, 7));
    if (month != kRuleChangeWindowMonth) return RuleChangeCodes.outOfWindow;
    if (drawdown <= kRuleChangeDrawdownLock) return RuleChangeCodes.ddLocked;
  }
  if (goldenChanged == null || _blank(approver)) {
    return RuleChangeCodes.approvalFieldsMissing;
  }
  if (!thirdPartyNotified) return RuleChangeCodes.thirdPartyMissing;
  return null;
}

/// SAF-405 기동 판정 결과(GV-40d).
class StartupGate {
  /// 결과를 만든다.
  const StartupGate({required this.start, required this.triggered});

  /// 기동하나.
  final bool start;

  /// 걸린 규칙(기동 거부 = `SAF-405`).
  final List<String> triggered;
}

/// 🔴 SAF-405(04 §1 · 02 검증 9) — live 만 `approved == 1` 이어야 기동 · 0 · 행 없음 = 기동 거부 · 모의 = 기동.
StartupGate startupConfigGate({
  required RunMode runMode,
  required int? approved,
}) {
  if (runMode != RunMode.live || approved == 1) {
    return const StartupGate(start: true, triggered: <String>[]);
  }
  return const StartupGate(start: false, triggered: <String>[kSaf405]);
}
