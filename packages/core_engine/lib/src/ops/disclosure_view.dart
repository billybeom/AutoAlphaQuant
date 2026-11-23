// 🆕 E11q-q5b — M7 `S7-2G` 열람 게이트 VM · `recordDisclosureView` 명령 봉투(설계 13 §8 R223 · 03 §5 S7-2G ⓐ~ⓙ ·
// 01 §13-5~§13-7 · 표본 `m7/m7_disclosure_gate*` · `m7/m7_disclosure_view_receipts_4`).
//
// 🔴 게이트 = 엔진이 지금 진입을 허용하는가 — 원장 무결성 점검 중(`LEDGER_INTEGRITY` 깃발) = 닫힘(머리 = 닫힌 까닭 · 마찰 줄 ·
//    링크 0) · 그 밖 = 열림(링크 = 탐색 · `gateOpen == (route != null)` C-37 ①).
// 🔴 열람 횟수 = 명령 기록(`command_inbox` kind `DISCLOSURE_VIEW` · append-only)의 이번 달(한국) 집계 — 화면이 세지 않는다(G-42) ·
//    집계 월 = 엔진이 접수한 시각(`ingested_at`)의 한국 달(화면이 넣은 `viewedAt` 아님).
// 🔴 마찰 줄 = 0회 = 없음(표본 `_first`) · 1~4회 = 기록 고지 · 🆕 5회 이상 = «자주 볼수록»(표본 `_frequent` · 문턱 = 엔진이 정한다 —
//    발주자 위임 — 권고대로) · 닫힘 = 없음.
// 🔴 명령 = 폰 안에서 바로 끝난다 — 무결성 점검 중 = «보류됨»(보관 · 집계에 든다 — 열람은 일어났다) · 그 밖 = «기록됨».

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        CommandKind,
        CommandReceipt,
        CommandState,
        DisclosureGateVm,
        DisclosureSurfaceCodes,
        DisclosureViewEvent,
        TradeDate;

import 'alert_ack_command.dart' show newCommandId;
import 'ledger_views.dart' show kstDateText;
import 'monthly_report.dart' show MonthlyReportTexts;

/// 게이트 기준 유효 시간(표본 93600초 = 26시간).
const Duration kDisclosureGateStaleAfter = Duration(hours: 26);

/// 🆕 «자주 볼수록» 문턱 — 이번 달 이만큼 이상 열었으면 마찰 줄이 바뀐다(발주자 위임 — 권고대로 · 표본 5회).
const int kDisclosureFrequentViews = 5;

/// 열람 기록 명령 TTL(알림 확인 · 실입금 등록 선례 — 폰 안에서 바로 끝난다).
const Duration kDisclosureViewTtl = Duration(minutes: 30);

/// 게이트 · 명령 글자(표본 그대로).
abstract final class DisclosureGateTexts {
  /// 열린 게이트 머리.
  static const String openHeadline = '수익률은 결과이지 목표가 아닙니다.';

  /// 닫힌 게이트 머리 — 닫힌 까닭(원장 무결성 점검).
  static const String closedHeadline = '원장 점검이 끝날 때까지 수익률 화면을 열 수 없습니다.';

  /// 이번 달 0회.
  static const String noViewsYet = '이번 달에는 아직 열어 보지 않으셨습니다';

  /// 기록 고지(1~4회).
  static const String friction = '이 화면을 여는 것도 기록으로 남습니다.';

  /// 잦은 열람(5회 이상).
  static const String frictionFrequent =
      '자주 볼수록 규칙을 버리기 쉽습니다. 이 화면을 여는 것도 기록으로 남습니다.';

  /// 게이트 기준.
  static String asOfLabel(String day) => '게이트 기준 $day';

  /// 접수증 — 기록됨.
  static const String recorded = '기록됨 — 열람 기록이 남았습니다';

  /// 접수증 — 보류됨(원장 무결성 점검 중).
  static const String held = '보류됨 — 원장 무결성 점검 중이라 보관했습니다';
}

/// 이번 달 열람 횟수 글자(0 = 아직 · n = 월간 리포트와 같은 글자).
String disclosureViewCountText(int n) {
  if (n < 0) throw ArgumentError.value(n, 'n', '음수');
  return n == 0
      ? DisclosureGateTexts.noViewsYet
      : MonthlyReportTexts.disclosureViews(n);
}

/// 집계 달(한국 `YYYY-MM`) — 접수 시각 기준.
String disclosureMonthOf(DateTime utc) => kstDateText(utc).substring(0, 7);

/// 🔴 `S7-2G` 게이트 VM — [viewCountThisMonth] = 이번 달 열람 기록 수 · [integrityHidden] = 원장 무결성 점검 중.
DisclosureGateVm disclosureGateVmOf({
  required int viewCountThisMonth,
  required bool integrityHidden,
  required DateTime nowUtc,
}) {
  final String day = kstDateText(nowUtc);
  final bool open = !integrityHidden;
  return DisclosureGateVm(
    gateOpen: open,
    headline: open
        ? DisclosureGateTexts.openHeadline
        : DisclosureGateTexts.closedHeadline,
    viewCountText: disclosureViewCountText(viewCountThisMonth),
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(day),
      source: AsOfSource.localSqlite,
      staleAfter: kDisclosureGateStaleAfter,
      label: DisclosureGateTexts.asOfLabel(day),
    ),
    frictionLine: !open || viewCountThisMonth == 0
        ? null
        : (viewCountThisMonth >= kDisclosureFrequentViews
              ? DisclosureGateTexts.frictionFrequent
              : DisclosureGateTexts.friction),
    route: open ? AppRoutes.performanceExplore : null,
  );
}

String _hex(Random r, int bytes) => <String>[
  for (int i = 0; i < bytes; i++)
    r.nextInt(256).toRadixString(16).padLeft(2, '0'),
].join();

/// 열람 기록 명령 한 건(폰 안 — 낸 자리에서 바로 기록한다).
class DisclosureViewCommand {
  /// 명령을 만든다(직접 — 시험 · 재구성).
  const DisclosureViewCommand({
    required this.commandId,
    required this.nonce,
    required this.requestedAt,
    required this.expiresAt,
    required this.event,
    required this.deviceId,
  });

  /// 지금 낸다 — [random] = 명령 id · nonce 원천(운영 = `Random.secure()`) · 알 수 없는 화면 코드 = 인자 오류.
  factory DisclosureViewCommand.issue({
    required DisclosureViewEvent event,
    required String deviceId,
    required DateTime nowUtc,
    required Random random,
  }) {
    if (!DisclosureSurfaceCodes.values.contains(event.surfaceCode)) {
      throw ArgumentError.value(event.surfaceCode, 'surfaceCode', '모르는 열람 화면');
    }
    final DateTime at = nowUtc.toUtc();
    return DisclosureViewCommand(
      commandId: newCommandId(random),
      nonce: _hex(random, 16),
      requestedAt: at,
      expiresAt: at.add(kDisclosureViewTtl),
      event: event,
      deviceId: deviceId,
    );
  }

  /// 명령 id.
  final String commandId;

  /// 1회용 값.
  final String nonce;

  /// 낸 시각(UTC).
  final DateTime requestedAt;

  /// TTL 끝(UTC).
  final DateTime expiresAt;

  /// 와이어(화면 코드 · 누른 시각 · 머문 시간 0).
  final DisclosureViewEvent event;

  /// 낸 기기.
  final String deviceId;

  /// `command_inbox.payload_digest` — 와이어 JSON 의 SHA-256 16진(원문 재저장 금지).
  String get payloadDigest =>
      sha256.convert(utf8.encode(jsonEncode(event.toJson()))).toString();

  /// 기록 결과 → 접수증 — [held] = 무결성 점검 중 보관.
  CommandReceipt receipt({required bool held}) => CommandReceipt(
    commandId: commandId,
    kind: CommandKind.disclosureView,
    state: held ? CommandState.heldForIntegrity : CommandState.executed,
    stateLabel: held ? DisclosureGateTexts.held : DisclosureGateTexts.recorded,
    requestedAt: requestedAt,
    expiresAt: expiresAt,
    nonce: nonce,
    issuedByDeviceId: deviceId,
  );
}
