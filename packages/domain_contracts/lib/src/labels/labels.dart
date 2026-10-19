// 01 §1-5 조문 + §3 코드 사전의 **단일 소스**.
//
// ════════════════════════════════════════════════════════════════════════════
// §1-5 화면 문자열 규약 — «사유 문구»와 «정적 라벨»의 경계 (조문)
// ════════════════════════════════════════════════════════════════════════════
// 금지 2항은 «한국어를 한 글자도 쓰지 말라»가 아니라
// **«상태를 설명하는 문장을 화면이 만들지 말라»** 이다.
//
//   | 갈래                | 누가 만드나                | 어디에 두나                          |
//   |---------------------|---------------------------|--------------------------------------|
//   | 사유·상태·판정 문구 | 🔴 엔진(M2)               | DTO 의 label·actionLine·             |
//   |                     |                           | clearInstruction·headline·           |
//   |                     |                           | stateLabel·statusLabel·emptyLabel·   |
//   |                     |                           | disclosureNote — 화면 코드에         |
//   |                     |                           | 리터럴로 존재하지 않는다             |
//   | 정적 UI 라벨        | 화면 담당                 | `<패키지>/lib/l10n/labels.dart`       |
//   |                     |                           | **한 파일에만** 상수로               |
//
// - **판단 기준**: 데이터가 바뀌어도 글자가 그대로면 정적 라벨,
//   데이터·상태에 따라 달라지면 사유 문구다.
//   `if 상태 then A else B` 처럼 **분기로 고르는 것은 정적 라벨이 아니라 생성**이다.
// - 그래서 열거값에는 짝이 되는 `*Label` 문자열 필드가 반드시 붙는다
//   (`status`↔`statusLabel` · `visibility`↔`visibilityLabel` · `state`↔`stateLabel`).
//   짝이 없는 열거값을 발견하면 화면이 문구를 지어내지 말고 **계약 결함으로 보고**한다.
// - C-5 는 `lib/l10n/labels.dart` 를 제외한 `ui_*` 전 파일에서 한글 리터럴 0건을 요구한다.
//   `labels.dart` 안에서도 §3 의 사유 문구를 베껴 적으면 위반이다.
//   (보조 스캐너 = `tool/check_labels.sh`)
//
// 🔴 **이 폴더의 성격** — 여기 두는 것은 «어떤 **코드**가 오는가»의 상수 목록이지
//    화면이 코드를 보고 문자열을 고르라는 사전이 **아니다**. 화면이 매핑을 만들면 C-5 가
//    빌드를 실패시킨다. 이 목록의 쓰임은 ① 픽스처·DDL 대조(C-15) ② 미등록 코드 조기 실패다.
// 🔴 C-32 — 이 파일도 예외가 아니다. 월 납입 금액으로 읽힐 숫자·문자열을 적지 않는다.

import 'advice_codes.dart';
import 'alert_codes.dart';
import 'deviation_kind_codes.dart';
import 'disclosure_codes.dart';
import 'exit_kind.dart';
import 'flag_ids.dart';
import 'journal_codes.dart';
import 'ledger_event_codes.dart';
import 'origin_codes.dart';
import 'plan_codes.dart';
import 'saf_codes.dart';
import 'verdict_codes.dart';

export 'advice_codes.dart';
export 'alert_codes.dart';
export 'deviation_kind_codes.dart';
export 'disclosure_codes.dart';
export 'exit_kind.dart';
export 'flag_ids.dart';
export 'journal_codes.dart';
export 'ledger_event_codes.dart';
export 'origin_codes.dart';
export 'plan_codes.dart';
export 'saf_codes.dart';
export 'verdict_codes.dart';

/// 세후 사다리 층 코드 6종(01 §2-4 `AfterTaxStep.stepCode` · M2-8 A-7).
///
/// 🔴 **층을 합치거나 건너뛰지 않는다** — `AfterTaxLadder.steps` 의 순서 그대로 그린다.
/// 🔴 «정직 기대»·사다리 4자리 수치를 **코드·라벨·주석에 옮기지 않는다**(C-30).
///    인용처는 픽스처 `aftertax_ladder_1.json` 과 골든 `aftertax_full_S7` 뿐이다.
/// 🔴 표시의 정본은 `AfterTaxStep.valueText` 이고 `cagrPct`·`endMult` 는 골든 대조 전용이다.
abstract final class AfterTaxStepCodes {
  /// 세전.
  static const String pretax = 'PRETAX';

  /// POT 반영 후.
  static const String afterPot = 'AFTER_POT';

  /// POT + C 반영 후.
  static const String afterPotC = 'AFTER_POT_C';

  /// 인출세 5.5% 적용.
  static const String wd5p5 = 'WD_5P5';

  /// 인출세 16.5% 적용.
  static const String wd16p5 = 'WD_16P5';

  /// 정직 기대.
  static const String honest = 'HONEST';

  /// 전량 6종(순서 = 사다리 층 순서).
  static const Set<String> values = <String>{
    pretax,
    afterPot,
    afterPotC,
    wd5p5,
    wd16p5,
    honest,
  };
}

/// ⏸ `AsOf.staleReasonCode` 최소 카탈로그 4값(M2-8 A-2 · 01 §8-8).
///
/// ⏸ **엔진(M1) 확정 대기.** 문서 전체를 통틀어 이 필드의 값이 한 번도 열거되지 않았고,
/// 아래 4값은 §1-3·§2-11 `staleLabel` 용례에서 **역산**한 것이다.
/// 🔴 그래도 상수로 둔다 — 자유 문자열로 두면 화면이 코드→문구 매핑을 만들고
///    그것이 C-5 위반의 입구다. 🔴 값이 확정되면 **이 목록을 고치고 픽스처를 함께 고친다**.
abstract final class StaleReasonCodes {
  /// 엔진 정지.
  static const String engineDown = 'ENGINE_DOWN';

  /// push 지연. 🔴 [OriginCodes.pushLag] 와 **문자열이 같고 축이 다르다**.
  static const String pushLag = 'PUSH_LAG';

  /// 배치 미수행.
  static const String batchMissing = 'BATCH_MISSING';

  /// 시계 어긋남.
  static const String clockSkew = 'CLOCK_SKEW';

  /// 전량 4종(⏸).
  static const Set<String> values = <String>{
    engineDown,
    pushLag,
    batchMissing,
    clockSkew,
  };
}

/// 등재되지 않은 코드가 사전 조회에 들어왔을 때 던진다.
///
/// 🔴 «모르는 코드를 조용히 통과시키는 것»이 이 계약이 가장 막고 싶은 것이다 —
///    통과하면 화면이 그 코드를 보고 자기 나름의 문구·아이콘·색을 고르기 시작한다.
final class UnregisteredContractCodeError extends Error {
  UnregisteredContractCodeError(this.code, {this.domain});

  /// 등재되지 않은 코드.
  final String code;

  /// 조회 대상 도메인(전역 조회면 null).
  final String? domain;

  @override
  String toString() => domain == null
      ? 'UnregisteredContractCodeError: "$code" is not in the 01 §3 code dictionary'
      : 'UnregisteredContractCodeError: "$code" is not registered in domain "$domain"';
}

/// 01 §3 코드 사전의 **단일 소스**(인벤토리 §6 «전 목록 배럴»).
///
/// 집계: 문서 137 + 6 =
///   ① SAF 접두 대역 7행 → 접두 **문자열** 8개(§3-2 표가 `SAF-8xx`·`SAF-9xx` 를 한 행으로 묶는다)
///   ② 계절 게이트 픽스처값 `ENTRY_GATE_OCT` 1개(⏸ 코드명 확정 전까지 픽스처가 쓰는 값)
///   ③ ⏸ `AsOf.staleReasonCode` 4개(M2-8 A-2 · 엔진 확정 대기)
/// 🔴 도메인이 다르면 **같은 문자열이 두 번 등재될 수 있다**
///    (`MANUAL_ORDER`·`RECON_MISMATCH`·`SELF_AUDIT_DUE`·`PUSH_LAG` 네 쌍) —
///    그래서 [all] 의 크기는 등재 건수보다 작다. 전역 조회보다 [requireRegisteredIn] 을 쓴다.
abstract final class ContractCodes {
  /// 도메인 → 코드 집합. 🔴 키 이름은 01 §3·§6 의 절 제목에서 따온다.
  static const Map<String, Set<String>> byDomain = <String, Set<String>>{
    'exit_kind': ExitKindCodes.values,
    'saf_band': SafBandCodes.values,
    'saf309': Saf309Codes.values,
    'verdict_code': VerdictCodes.values,
    'planned_work_kind': PlannedWorkKindCodes.values,
    'gap_reason_code': GapReasonCodes.values,
    'origin_code': OriginCodes.values,
    'flag_id': FlagIds.values,
    'safety_hold': SafetyHoldCodes.values,
    'advice_reject': AdviceRejectCodes.values,
    'advice_transition_cause': AdviceTransitionCauseCodes.values,
    'decision_reason': DecisionReasonCodes.values,
    'seasonal_entry_gate': SeasonalEntryGateCodes.values,
    'seasonal_entry_gate_fixture': <String>{
      SeasonalEntryGateCodes.fixtureEntryGatePass,
    },
    'alert_code': AlertCodes.values,
    'deviation_kind': DeviationKindCodes.values,
    'ledger_event': LedgerEventCodes.values,
    'operating_param_key': OperatingParamKeys.values,
    'aftertax_step': AfterTaxStepCodes.values,
    'stale_reason': StaleReasonCodes.values,
    // 🆕 v1.1 — J-2 체인 단계 · 전수 검사 층 · J-5 해소 단계 · J-1 배지
    'decision_chain_stage': DecisionChainStageCodes.values,
    'safety_check_level': SafetyCheckLevelCodes.values,
    'unknown_resolution_stage': UnknownResolutionStageCodes.values,
    'journal_badge': JournalBadgeCodes.values,
    // 🆕 v1.1 R2 준비(2026-09-23) — J-3 사전 저널 제출의 거부 사유
    //    (`CommandReceipt.rejectReasonCode` — X7 의 `advice_reject` 와 다른 축)
    'journal_draft_reject': JournalDraftRejectCodes.values,
    // 🆕 v1.3(R10 선행) — 성과 열람 기록의 화면 코드(`DisclosureViewEvent.surfaceCode`)
    'disclosure_surface': DisclosureSurfaceCodes.values,
    // 🆕 v1.4(R11 선행) — 플래너 주문 초안의 사유 칩(`OrderDraft.reasons[].code`)
    'planner_reason': PlannerReasonCodes.values,
    // 🆕 v1.7(J-4 선행) — blind 리뷰 점수 제출의 거부 사유(`CommandReceipt.rejectReasonCode`)
    'blind_review_reject': BlindReviewRejectCodes.values,
  };

  /// 전 도메인의 코드 합집합(중복 문자열은 한 번만 남는다).
  static final Set<String> all = <String>{
    for (final Set<String> codes in byDomain.values) ...codes,
  };

  /// 이 도메인이 사전에 있는가.
  static bool hasDomain(String domain) => byDomain.containsKey(domain);

  /// 어느 도메인에든 등재된 코드인가.
  static bool isRegistered(String code) => all.contains(code);

  /// 이 도메인에 등재된 코드인가. 도메인 자체가 없으면 false.
  static bool isRegisteredIn(String domain, String code) =>
      byDomain[domain]?.contains(code) ?? false;

  /// 이 코드가 속한 도메인 전부(중복 등재가 있으므로 **집합**을 돌려준다).
  static Set<String> domainsOf(String code) => <String>{
    for (final MapEntry<String, Set<String>> e in byDomain.entries)
      if (e.value.contains(code)) e.key,
  };

  /// 🔴 **미등록이면 실패한다** — 도메인을 지정한 조회(권장).
  ///
  /// 반환값은 입력 [code] 그대로이므로 파이프라인 안에서 그대로 쓸 수 있다.
  /// Throws [UnregisteredContractCodeError].
  static String requireRegisteredIn(String domain, String code) {
    if (!byDomain.containsKey(domain)) {
      throw UnregisteredContractCodeError(code, domain: domain);
    }
    if (!byDomain[domain]!.contains(code)) {
      throw UnregisteredContractCodeError(code, domain: domain);
    }
    return code;
  }

  /// 🔴 **미등록이면 실패한다** — 도메인을 모를 때의 전역 조회.
  ///
  /// 🔴 도메인을 아는 자리에서는 [requireRegisteredIn] 을 쓴다.
  /// 전역 조회는 «`flag_id` 자리에 알림 코드가 들어온 것»을 잡지 못한다.
  /// Throws [UnregisteredContractCodeError].
  static String requireRegistered(String code) {
    if (!all.contains(code)) {
      throw UnregisteredContractCodeError(code);
    }
    return code;
  }
}
