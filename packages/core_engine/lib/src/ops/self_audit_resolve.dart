// 🆕 R280 — `M5-13` 원장 실사 «해소» 게이트 엔진 몫(01 §8 미결 226 · 계약 v1.37 §46 K318~K322 · 06 M5-13 · X7-3 · B18 · B22 ·
// 설계 13 §8 R237 · R240 · R278 · R280).
//
// 🔴 해제 경로 = 실사 0오차 통과 하나(06 M5-13) — 수동 해제 0 · 버림 0(«명령은 사실을 잃지 않는다» 01 §10-8).
// 🔴 `CANON_SELF_REPORT` 차이 = 관측 · 정정 마법사 대상 아님(K320) — 해소 = 그 계좌 다시 실사 0오차(경로 글자 «다시 실사로 해소» ·
//    행 조치 «다시 실사하기» = 그 달 · 그 계좌 `L-3` — `ledgerDiffRowOf`).
// 🔴 두 카운터(K321 ② ③ · X7-3):
//    · 미처리 갭 = 미이행 · 미기록으로 닫힌(만료) 안내 가운데 아직 0오차 실사로 덮이지 않은 가장 이른 것의 마감 뒤 경과 거래일 ·
//      그날 열린 안내가 0건인 거래일은 세지 않는다(경보 피로 규칙) · 덮임 = 그 안내 계좌(계좌 없음 = 대응 계좌 전부)의 0오차 실사
//      기준일 ≥ 마감(그 실사가 마감 뒤 원장 상태를 대조했다) · 리셋 = 0오차 실사 통과만.
//    · 실사 갭 = 계좌별 마지막 실사 기준일 뒤 달력일(R240 그대로 · 리셋 = 실사 1회 — 차이 있어도) · 표시 = 가장 큰 계좌 한 줄.
//    · 오늘 = 신뢰 시각(모르면 세지 않는다 — 기기 시계로 대신하지 않는다) · 투자 안내 모드에서만 두 줄 · 그 밖 0줄.
// 🔴 플래그 `ADVICE_LEDGER_UNVERIFIED`(K321 ① ④):
//    · 발동 = 신뢰 등급이 `UNVERIFIABLE` 로 내려갈 때(미처리 갭 ≥ 강등 문턱) — 🔴 문턱 = 01 §8 미결 118 ⓐ 발주자 수치 대기 →
//      값이 없으면 발동 0(엔진 기본값 · 상수 0 — 새 수치를 짓지 않는다).
//    · 해제 = 발동한 날(한국 날) 이후 기준일의 실사가 대응 계좌 전부에서 0오차 — 실사를 적는 그 트랜잭션에서 내린다(ds `record`).
// 🔴 보관 명령(B18 · K319) 검토 = 일괄 확정 하나 — `review_id` = 지금 보관 묶음 스냅숏(접수 차례 명령 id 의 지문) ·
//    확정 = 그 묶음의 `HELD_FOR_INTEGRITY` 전부 → `RECEIVED`(상태 기계 무변경) · 그 뒤 = 보통 소비 규칙.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../calendar/exchange_calendar.dart';
import 'ledger_views.dart'
    show StoredLedgerDiff, kstDateText, kstMinuteText, ledgerDiffRowOf;
import 'self_report.dart'
    show
        SelfReportTexts,
        kSelfReportStaleAfter,
        selfReportAsOfOf,
        selfReportLinkOf;

/// 해소 게이트 글자표(표본 `m5/self_audit_resolve_*` · `m5/held_review_results` 문장 꼴 — «(합성)» 없이).
abstract final class SelfAuditResolveTexts {
  /// 머리 — 플래그 섬.
  static const String headlineFlag = '신규 진입 안내가 멈춰 있습니다 — 원장 실사가 필요합니다';

  /// 머리 — 보관 명령 · 무결성 점검 중.
  static String headlineHeldBlocked(int n) => '보관된 명령 $n건 — 무결성 점검 중';

  /// 머리 — 보관 명령 · 확정 기다림.
  static String headlineHeld(int n) => '보관된 명령 $n건 — 확정을 기다립니다';

  /// 머리 — 열린 자가 보고 차이.
  static String headlineDiffs(int n) => '열린 자가 보고 차이 $n건 — 다시 실사로 해소합니다';

  /// 머리 — 해소할 것 없음.
  static const String headlineClear = '원장 실사로 해소할 것이 없습니다';

  /// 플래그 줄 — «09-01부터».
  static String flagLine(String mmDd) =>
      '원장 미검증 · $mmDd부터 · 청산 · 방어 안내는 그대로 냅니다';

  /// 플래그 줄 — 없음.
  static const String flagNone = '원장 미검증 표식이 없습니다';

  /// 해제 규칙(수동 해제 0).
  static const String releaseRule =
      '대응 계좌의 실사가 모두 0오차로 통과하면 엔진이 스스로 풉니다 · 수동 해제는 없습니다';

  /// 미처리 갭.
  static String unprocessedGap(int n) => n == 0
      ? '미처리 갭 — 0거래일'
      : '미처리 갭 — 기록 없이 닫힌 안내 뒤 $n거래일(안내가 없던 날은 세지 않습니다)';

  /// 미처리 갭 — 신뢰 시각 · 달력 모름.
  static const String unprocessedUnknown =
      '미처리 갭 — 신뢰 시각이나 거래일 달력을 확인하지 못해 세지 않았습니다';

  /// 실사 갭 — 가장 큰 계좌.
  static String auditGap(String alias, int days) =>
      '실사 갭 — ${SelfReportTexts.account(alias)} 마지막 실사 뒤 $days일';

  /// 실사 갭 — 기록 0.
  static const String auditGapNone = '실사 갭 — 아직 실사 기록이 없습니다';

  /// 실사 갭 — 신뢰 시각 모름.
  static const String auditGapUnknown = '실사 갭 — 신뢰 시각을 확인하지 못해 세지 않았습니다';

  /// 열린 차이 없음.
  static const String diffsEmpty = '열린 자가 보고 차이가 없습니다';

  /// 실사 링크 «연금저축 계좌 실사 하기».
  static String auditLink(String alias) =>
      '${SelfReportTexts.account(alias)} 실사 하기';

  /// 보관 명령 없음.
  static const String heldEmpty = '보관된 명령이 없습니다';

  /// 확정 막힘(무결성 점검 중).
  static const String heldBlocked = '원장 무결성 점검이 끝나야 확정할 수 있습니다';

  /// 확정 버튼.
  static String confirm(int n) => '보관된 명령 $n건 확정';

  /// 보관 행 상태 글자(`CommandState` 짝).
  static const String heldState = '보관 — 무결성 점검 뒤 확정';

  /// 보관 행 접수 시각 «2026-09-02 10:14 접수».
  static String receivedAt(String kstMinute) => '$kstMinute 접수';

  /// 보관 행 요약 — 같은 명령이 다시 오면 처리하는 종류(사전 저널 · 사후 리뷰 점수 — 원문 = 낸 쪽이 다시 건넨다).
  static const String summaryReplay = '같은 명령이 다시 들어오면 그때 처리합니다';

  /// 보관 행 요약 — 원문을 원장에 남기지 않는 종류(정기 실사 · 실입금 · 열람 · 수기 기록 — 다시 제출 = 새 명령).
  static const String summaryResubmit =
      '원문은 낸 기기의 초안에 남아 있습니다 — 확정 뒤 다시 제출하십시오';

  /// 확정 뒤 수신함 상태 글자(`RECEIVED`).
  static String confirmedState(String kstMinute) =>
      '접수됨 — $kstMinute 보관 확정 · 보통 접수 규칙으로 처리합니다';

  /// 결과 — 확정.
  static String confirmed(int n) => '보관된 명령 $n건을 확정했습니다 — 보통 접수 규칙으로 처리합니다';

  /// 결과 — 그 사이 묶음이 바뀜.
  static const String stale = '그 사이 보관 명령이 바뀌었습니다 — 화면을 다시 읽고 확정하십시오';

  /// 결과 — 인자 꼴.
  static const String argsInvalid = '확정 요청의 꼴이 맞지 않습니다 — 화면의 확정 버튼만 받습니다';

  /// 플래그 `trading_block.reason`(발동 까닭 — 원장 글자).
  static String raiseReason(int gap, int threshold) =>
      '미처리 갭 $gap거래일 — 강등 문턱 $threshold거래일 이상';

  /// 명령 종류 글자(모르는 종류 = 일반 글자).
  static String kindLabel(String kindWire) {
    for (final CommandKind k in CommandKind.values) {
      if (k.wire == kindWire) {
        return switch (k) {
          CommandKind.killSwitchActivate => '킬스위치 발동',
          CommandKind.journalDraft => '사전 저널 기록',
          CommandKind.blindReviewScore => '사후 리뷰 점수',
          CommandKind.disclosureView => '공시 열람 기록',
          CommandKind.depositRegister => '실입금 등록',
          CommandKind.manualFillRecord => '수기 체결 기록',
          CommandKind.manualFillAmend => '수기 체결 정정',
          CommandKind.manualFillVoid => '수기 체결 무효',
          CommandKind.adviceSkip => '안내 미이행 기록',
          CommandKind.selfReportBalance => '정기 실사 제출',
          CommandKind.alertAck => '알림 확인',
          CommandKind.killChecklistConfirm => '킬스위치 점검 확인',
          CommandKind.ledgerEventRecord => '원장 사건 기록',
          CommandKind.adviceDeferConfirm => '만료 확인 미루기',
        };
      }
    }
    return '기록 명령';
  }
}

/// 같은 명령 id 가 다시 오면 처리기가 집행하는 종류(보관 → 확정 → 다시 건넴 · ds `JournalDraftStore` · `BlindReviewStore`).
const Set<String> kHeldReplayKinds = <String>{
  'JOURNAL_DRAFT',
  'BLIND_REVIEW_SCORE',
};

/// 만료(미이행 · 미기록)로 닫힌 안내 한 건 — 미처리 갭 원천(원장 `advice`).
class LapsedAdvice {
  /// 만든다.
  const LapsedAdvice({required this.deadline, this.accountAlias});

  /// 마감(`valid_until_date` · 거래일).
  final TradeDate deadline;

  /// 계좌(없음 = 대응 계좌 전부가 덮어야 한다).
  final String? accountAlias;
}

/// 안내가 열린 창(발행일 ~ 마감) — «그날 열린 안내» 판정 원천.
class AdviceWindow {
  /// 만든다.
  const AdviceWindow({required this.from, required this.until});

  /// 발행 거래일.
  final TradeDate from;

  /// 마감.
  final TradeDate until;
}

bool _covers(TradeDate? zero, TradeDate need) =>
    zero != null && zero.yyyyMmDd.compareTo(need.yyyyMmDd) >= 0;

String _nextDay(String yyyyMmDd) =>
    DateTime.parse('${yyyyMmDd}T00:00:00Z')
        .add(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

/// 🔴 미처리 갭(거래일 · K321 ②) — [latestZeroError] = 계좌 → 가장 늦은 0오차 실사 기준일 · [accounts] = 대응 계좌 차례 ·
/// [today] = 신뢰 시각의 한국 날. 덮이지 않은 만료 안내 없음 = 0 · 달력 밖 = null(세지 않는다).
int? selfAuditUnprocessedGapOf({
  required List<LapsedAdvice> lapsed,
  required List<AdviceWindow> windows,
  required Map<String, TradeDate> latestZeroError,
  required List<String> accounts,
  required TradeDate today,
  required ExchangeCalendar kr,
}) {
  String? start;
  for (final LapsedAdvice a in lapsed) {
    final String? alias = a.accountAlias;
    final bool covered = alias != null && alias.trim().isNotEmpty
        ? _covers(latestZeroError[alias], a.deadline)
        : accounts.isNotEmpty &&
              accounts.every(
                (String x) => _covers(latestZeroError[x], a.deadline),
              );
    if (covered) continue;
    if (start == null || a.deadline.yyyyMmDd.compareTo(start) < 0) {
      start = a.deadline.yyyyMmDd;
    }
  }
  if (start == null) return 0;
  int n = 0;
  try {
    for (
      String d = _nextDay(start);
      d.compareTo(today.yyyyMmDd) <= 0;
      d = _nextDay(d)
    ) {
      if (!kr.isSession(TradeDate(d))) continue;
      final bool open = windows.any(
        (AdviceWindow w) =>
            w.from.yyyyMmDd.compareTo(d) <= 0 &&
            d.compareTo(w.until.yyyyMmDd) <= 0,
      );
      if (open) n++;
    }
  } on StateError {
    return null;
  }
  return n;
}

/// 실사 갭 한 줄의 원천(가장 큰 계좌).
class SelfAuditGap {
  /// 만든다.
  const SelfAuditGap(this.accountAlias, this.days);

  /// 계좌.
  final String accountAlias;

  /// 마지막 실사 기준일 뒤 달력일.
  final int days;
}

/// 🔴 실사 갭(K321 ③ · R240 그대로) — 기록 있는 계좌 가운데 가장 큰 · 같으면 계좌 차례 앞 · 기록 0 = null.
SelfAuditGap? selfAuditGapOf({
  required List<String> accounts,
  required Map<String, TradeDate> lastVerified,
  required TradeDate today,
}) {
  SelfAuditGap? best;
  for (final String a in accounts) {
    final TradeDate? last = lastVerified[a];
    if (last == null) continue;
    final int days = DateTime.parse('${today.yyyyMmDd}T00:00:00Z')
        .difference(DateTime.parse('${last.yyyyMmDd}T00:00:00Z'))
        .inDays;
    if (best == null || days > best.days) best = SelfAuditGap(a, days);
  }
  return best;
}

/// 🔴 카운터 두 줄(K318 · K321) — 투자 안내 아님 = 0줄 · 신뢰 시각 모름 = 세지 않았다는 두 줄 · 차례 = 미처리 갭 → 실사 갭.
/// [unprocessed] null = 달력 밖(세지 않음).
List<String> selfAuditCounterLinesOf({
  required OperatingMode? operatingMode,
  required bool trustedKnown,
  required int? unprocessed,
  required SelfAuditGap? auditGap,
}) {
  if (operatingMode != OperatingMode.advisory) return const <String>[];
  if (!trustedKnown) {
    return const <String>[
      SelfAuditResolveTexts.unprocessedUnknown,
      SelfAuditResolveTexts.auditGapUnknown,
    ];
  }
  return <String>[
    unprocessed == null
        ? SelfAuditResolveTexts.unprocessedUnknown
        : SelfAuditResolveTexts.unprocessedGap(unprocessed),
    auditGap == null
        ? SelfAuditResolveTexts.auditGapNone
        : SelfAuditResolveTexts.auditGap(auditGap.accountAlias, auditGap.days),
  ];
}

/// 🔴 플래그 발동(K321 ①) — 투자 안내 ∧ 문턱 값 있음 ∧ 미처리 갭 ≥ 문턱. 🔴 [thresholdTradingDays] = 01 §8 미결 118 ⓐ 발주자 수치
/// 대기 → 지금 부르는 쪽 = null(발동 0 · 엔진 기본값 없음) · 0 이하 = [ArgumentError](설정 꼴 틀림을 조용히 넘기지 않는다).
bool adviceLedgerUnverifiedRaiseOf({
  required OperatingMode? operatingMode,
  required int? unprocessedGap,
  required int? thresholdTradingDays,
}) {
  final int? t = thresholdTradingDays;
  if (t != null && t <= 0) {
    throw ArgumentError.value(t, 'thresholdTradingDays', '1 이상이어야');
  }
  return operatingMode == OperatingMode.advisory &&
      t != null &&
      unprocessedGap != null &&
      unprocessedGap >= t;
}

/// 🔴 플래그 해제(K321 ④) — 대응 계좌 전부가 발동한 날([flagSetDay] · 한국 날) 이후 기준일의 0오차 실사를 가졌다 · 대응 계좌 0 =
/// 풀지 않는다(실사로 풀 길이 없으면 사람 해제도 없다 — 계좌 대응이 먼저).
bool adviceLedgerUnverifiedReleaseOf({
  required TradeDate flagSetDay,
  required List<String> accounts,
  required Map<String, TradeDate> latestZeroError,
}) =>
    accounts.isNotEmpty &&
    accounts.every((String a) => _covers(latestZeroError[a], flagSetDay));

String _monthAfter(String yyyyMm) {
  final int y = int.parse(yyyyMm.substring(0, 4));
  final int m = int.parse(yyyyMm.substring(5, 7));
  final DateTime n = DateTime.utc(y, m + 1);
  return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}';
}

/// 해제에 필요한 실사의 달 = 기준일(그 달 마지막 KR 세션)이 발동한 날 이후인 첫 달(달력 밖 = null).
String? selfAuditReleaseMonthOf(TradeDate flagSetDay, ExchangeCalendar kr) {
  String m = flagSetDay.yyyyMmDd.substring(0, 7);
  for (int i = 0; i < 3; i++) {
    final TradeDate? asOf = selfReportAsOfOf(m, kr);
    if (asOf != null && _covers(asOf, flagSetDay)) return m;
    m = _monthAfter(m);
  }
  return null;
}

/// 🔴 0오차 실사가 아직 필요한 계좌 링크(K318 `auditLinks`) — 플래그가 서 있을 때만 · 대응 계좌 차례 · 발동 뒤 기준일 0오차가
/// 없는 계좌 · 목적지 = 해제에 필요한 달의 그 계좌 `L-3` · [rowLinks] = 열린 차이 행이 이미 같은 목적지를 싣는다(겹치면 뺀다).
List<LinkAction> selfAuditLinksOf({
  required TradeDate? flagSetDay,
  required List<String> accounts,
  required Map<String, TradeDate> latestZeroError,
  required ExchangeCalendar kr,
  Set<String> rowLinks = const <String>{},
}) {
  final TradeDate? f = flagSetDay;
  if (f == null) return const <LinkAction>[];
  final String? month = selfAuditReleaseMonthOf(f, kr);
  if (month == null) return const <LinkAction>[];
  return <LinkAction>[
    for (final String a in accounts)
      if (!_covers(latestZeroError[a], f))
        if (selfReportLinkOf(month, a) case final String link
            when !rowLinks.contains(link))
          LinkAction(label: SelfAuditResolveTexts.auditLink(a), deepLink: link),
  ];
}

/// 수신함의 보관 명령 한 행(`command_inbox` · `HELD_FOR_INTEGRITY`).
class StoredHeldCommand {
  /// 만든다.
  const StoredHeldCommand({
    required this.commandId,
    required this.kind,
    required this.ingestedAtUtc,
  });

  /// 명령 id.
  final String commandId;

  /// 종류(와이어).
  final String kind;

  /// 접수 시각(UTC).
  final DateTime ingestedAtUtc;
}

/// 보관 명령 차례(접수 시각 → 명령 id).
List<StoredHeldCommand> heldCommandsInOrder(List<StoredHeldCommand> held) =>
    <StoredHeldCommand>[...held]
      ..sort((StoredHeldCommand a, StoredHeldCommand b) {
        final int t = a.ingestedAtUtc.compareTo(b.ingestedAtUtc);
        return t != 0 ? t : a.commandId.compareTo(b.commandId);
      });

/// 🔴 보관 묶음 스냅숏 id(K319 `review_id`) = 접수 차례 명령 id 목록의 SHA-256 앞 12자 · 빈 묶음 = null(확정할 것 없음).
String? heldReviewIdOf(List<StoredHeldCommand> held) {
  if (held.isEmpty) return null;
  final List<String> ids = <String>[
    for (final StoredHeldCommand c in heldCommandsInOrder(held)) c.commandId,
  ];
  return 'hr_${sha256.convert(utf8.encode(jsonEncode(ids))).toString().substring(0, 12)}';
}

/// `review_id` 꼴(엔진이 지은 것만 — 열거형 밖 자유 서술 거부 · 06 M5-13 검증 게이트).
final RegExp _reviewId = RegExp(r'^hr_[0-9a-f]{12}$');

/// 보관 명령 → 화면 행(엔진 글자 · `commandId` 화면 미참조).
HeldCommandRow heldCommandRowOf(StoredHeldCommand c) => HeldCommandRow(
  commandId: c.commandId,
  kindLabel: SelfAuditResolveTexts.kindLabel(c.kind),
  summaryText: kHeldReplayKinds.contains(c.kind)
      ? SelfAuditResolveTexts.summaryReplay
      : SelfAuditResolveTexts.summaryResubmit,
  receivedAtText: SelfAuditResolveTexts.receivedAt(
    kstMinuteText(c.ingestedAtUtc),
  ),
  stateLabel: SelfAuditResolveTexts.heldState,
);

/// 🔴 일괄 확정 거부 판정(K319) — 차례 = 인자 꼴(키 = {`review_id`} · 엔진 꼴) → 무결성 점검 중 → 묶음이 그 사이 바뀜(빈 묶음
/// 포함) · null = 확정한다. 신뢰 시각 비의존(RECON 해제 선례).
String? heldReviewRejectOf({
  required Map<String, String> args,
  required bool integrityActive,
  required String? currentReviewId,
}) {
  final String? id = args['review_id'];
  if (args.length != 1 || id == null || !_reviewId.hasMatch(id)) {
    return HeldReviewResultCodes.argsInvalid;
  }
  if (integrityActive) return HeldReviewResultCodes.integrityActive;
  if (currentReviewId == null || currentReviewId != id) {
    return HeldReviewResultCodes.stale;
  }
  return null;
}

/// 🔴 일괄 확정 결과(표본 `m5/held_review_results` 꼴) — [code] null = 확정([confirmed] = 옮긴 건수) · `STALE` = 다시 가능.
SafetyActionResult heldReviewResultOf({
  required String actionRunId,
  required String? code,
  int confirmed = 0,
}) {
  SafetyActionResult r(UiLevel level, String headline, {bool retry = false}) =>
      SafetyActionResult(
        actionRunId: actionRunId,
        id: SafetyActionId.heldCommandsConfirm,
        level: level,
        headline: headline,
        reasonCode: code,
        retryable: retry,
      );
  return switch (code) {
    null => r(UiLevel.ok, SelfAuditResolveTexts.confirmed(confirmed)),
    HeldReviewResultCodes.stale => r(
      UiLevel.watch,
      SelfAuditResolveTexts.stale,
      retry: true,
    ),
    HeldReviewResultCodes.integrityActive => r(
      UiLevel.blocked,
      SelfAuditResolveTexts.heldBlocked,
    ),
    HeldReviewResultCodes.argsInvalid => r(
      UiLevel.blocked,
      SelfAuditResolveTexts.argsInvalid,
    ),
    _ => throw ArgumentError.value(code, 'code', '보관 확정 사유가 아니다'),
  };
}

int _axisRank(LedgerAxis a) => LedgerAxis.values.indexOf(a);

/// 🔴 `M5-13` VM(K318 · 불변식 C-70 ②) — [flagSetAtUtc] = `ADVICE_LEDGER_UNVERIFIED` 가 서 있으면 선 시각(아니면 null) ·
/// [openDiffs] = 열린 `CANON_SELF_REPORT` 차이(다른 쌍 · 닫힌 행은 빠진다) · [held] = 보관 명령 · [integrityActive] =
/// `LEDGER_INTEGRITY` 서 있음 · [nowUtc] = 관측. 머리 차례 = 플래그 → 보관 → 차이 → 없음.
SelfAuditResolveVm selfAuditResolveVmOf({
  required DateTime? flagSetAtUtc,
  required List<String> counterLines,
  required List<StoredLedgerDiff> openDiffs,
  required List<LinkAction> auditLinks,
  required List<StoredHeldCommand> held,
  required bool integrityActive,
  required DateTime nowUtc,
}) {
  final List<StoredLedgerDiff> diffs =
      <StoredLedgerDiff>[
        for (final StoredLedgerDiff d in openDiffs)
          if (d.pair == LedgerPair.canonSelfReport &&
              d.status == DiffStatus.open)
            d,
      ]..sort((StoredLedgerDiff a, StoredLedgerDiff b) {
        final int t = a.authoredDate.yyyyMmDd.compareTo(
          b.authoredDate.yyyyMmDd,
        );
        if (t != 0) return t;
        final int x = _axisRank(a.axis).compareTo(_axisRank(b.axis));
        return x != 0 ? x : a.diffId.compareTo(b.diffId);
      });
  final List<StoredHeldCommand> h = heldCommandsInOrder(held);
  final String? reviewId = heldReviewIdOf(h);
  final DateTime? flagAt = flagSetAtUtc;
  final bool flag = flagAt != null;
  final (String headline, UiLevel level) = flag
      ? (SelfAuditResolveTexts.headlineFlag, UiLevel.act)
      : h.isNotEmpty
      ? (
          integrityActive
              ? SelfAuditResolveTexts.headlineHeldBlocked(h.length)
              : SelfAuditResolveTexts.headlineHeld(h.length),
          UiLevel.watch,
        )
      : diffs.isNotEmpty
      ? (SelfAuditResolveTexts.headlineDiffs(diffs.length), UiLevel.watch)
      : (SelfAuditResolveTexts.headlineClear, UiLevel.ok);
  final String today = kstDateText(nowUtc);
  return SelfAuditResolveVm(
    headline: headline,
    level: level,
    flagLine: flagAt != null
        ? SelfAuditResolveTexts.flagLine(kstDateText(flagAt).substring(5))
        : SelfAuditResolveTexts.flagNone,
    releaseRuleText: SelfAuditResolveTexts.releaseRule,
    counterLines: counterLines,
    diffs: <LedgerDiffRow>[
      for (final StoredLedgerDiff d in diffs) ledgerDiffRowOf(d),
    ],
    diffsEmptyLabel: diffs.isEmpty ? SelfAuditResolveTexts.diffsEmpty : null,
    auditLinks: auditLinks,
    heldCommands: <HeldCommandRow>[
      for (final StoredHeldCommand c in h) heldCommandRowOf(c),
    ],
    heldEmptyLabel: h.isEmpty ? SelfAuditResolveTexts.heldEmpty : null,
    confirmHeld: reviewId != null && !integrityActive
        ? SafetyActionCall(
            id: SafetyActionId.heldCommandsConfirm,
            args: <String, String>{'review_id': reviewId},
            label: SelfAuditResolveTexts.confirm(h.length),
          )
        : null,
    heldBlockedText: h.isNotEmpty && integrityActive
        ? SelfAuditResolveTexts.heldBlocked
        : null,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(today),
      source: AsOfSource.localSqlite,
      staleAfter: kSelfReportStaleAfter,
      label: '실사 기준 ${kstMinuteText(nowUtc)}',
    ),
  );
}
