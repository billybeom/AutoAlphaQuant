// simToAuto 2단 커밋 1단계(실전 파일) 순수 몫 — 게이트 · 개시 현금 · 결정 id · 모의 기록 처리(S5) · 코드 · 문구
// (02 :692 §2-7 v2.44 ⓑ · 06 :242 · 04 :401 · 01 :3388 · 설계 13 §8 R93 AE1 f3 · R98 AG1~AG11).
//
// 🔴 판정만 한다 — 실전 파일 쓰기는 data_sync `SqliteSimToAutoCommitStore` · 모의 CLOSE · 지움 · 복구 = f3b.
// 🔴 보유 0 · 오늘 브로커 활동 0 · 5분 안 조회만 개시한다(커밋 당일 매도분이 대사에서 «원장에 없는 주문»이 되지 않게).
// 🔴 개시 현금 = D+2 주문가능 예수금(AG4 · ⬜ 발주자 확인) · 원 단위 · 0원 계좌 행 없음.
// 🔵 코드 · 문구 = 엔진 문자열(계약 등재 = 1.20.0 후보).

import 'package:domain_contracts/domain_contracts.dart' show HandoverPath;

import 'handover_session.dart'
    show HandoverSessionCodes, HandoverSessionKind, HandoverSessionRecord;
import 'sim_to_auto.dart'
    show
        SimLedgerFate,
        SimToAutoCodes,
        SimToAutoReport,
        kHandoverPlanStaleAfter;

/// 실전 계좌 한 곳의 조회 결과(AG9 — 부르는 쪽이 브로커 잔고 포트로 채운다).
class LiveAccountProbe {
  /// 조회를 만든다.
  const LiveAccountProbe({
    required this.alias,
    required this.holdingsCount,
    required this.orderableCashKrw,
    required this.activityToday,
    required this.fetchedAtUtc,
  });

  /// 계좌 별칭(설정 `accountByStrategy` 의 값).
  final String alias;

  /// 수량이 있는 보유 종목 수(전 종목 — AG3 · ⬜ 범위 확인).
  final int holdingsCount;

  /// D+2 주문가능 예수금(원 · 모름 = null).
  final int? orderableCashKrw;

  /// 오늘 브로커 주문 · 체결 수.
  final int activityToday;

  /// 조회 시각.
  final DateTime fetchedAtUtc;
}

/// 1단계 거부 · 결과 코드(R98).
abstract final class SimToAutoCommitCodes {
  /// 실전 파일에 이미 모드 행이 있다.
  static const String alreadyCommitted = 'SIM_TO_AUTO_ALREADY_COMMITTED';

  /// 대응 계좌 가운데 조회가 없는 곳이 있다.
  static const String probeMissing = 'SIM_TO_AUTO_ACCOUNT_PROBE_MISSING';

  /// 조회가 5분보다 오래됐거나 미래 시각이다.
  static const String snapshotStale = 'SIM_TO_AUTO_SNAPSHOT_STALE';

  /// 실전 계좌에 보유 종목이 있다.
  static const String holdingsNotZero = 'SIM_TO_AUTO_HOLDINGS_NOT_ZERO';

  /// 오늘 브로커 주문 · 체결이 있다.
  static const String brokerActivityToday = 'SIM_TO_AUTO_BROKER_ACTIVITY_TODAY';

  /// 예수금을 알 수 없다.
  static const String cashUnknown = 'SIM_TO_AUTO_CASH_UNKNOWN';

  /// 예수금 합계가 0원이다(⬜ 발주자 확인).
  static const String zeroCash = 'SIM_TO_AUTO_ZERO_CASH';

  /// 쓰기 실패 — 전부 되돌리고 세션을 닫았다.
  static const String rolledBack = 'SIM_TO_AUTO_COMMIT_ROLLED_BACK';

  /// 닫힌 모의 파일에는 S5 고름을 적지 않는다.
  static const String simClosed = 'SIM_LEDGER_FATE_SIM_CLOSED';
}

/// 실전 개시 결정의 `decision_log.reason`(엔진 문구).
const String kLiveOpeningReason = '실전 개시 — 보유 0 확인 · 주문가능 예수금 기록';

/// 실전 시딩 사유(`strategy_state_log.reason`).
const String kLiveOpeningSeedReason = 'LIVE_OPENING';

/// 커밋 알림을 내는 곳(`alert_event.source`).
const String kHandoverCommitCheck = 'handover-commit';

/// S5 보관 고름의 `decision_log.reason_code`.
const String kSimLedgerKeepCode = 'SIM_LEDGER_KEEP';

/// S5 지움 고름의 `decision_log.reason_code`.
const String kSimLedgerDiscardCode = 'SIM_LEDGER_DISCARD';

/// 고름 → 사유 코드.
String simLedgerFateReasonCode(SimLedgerFate f) => switch (f) {
  SimLedgerFate.keep => kSimLedgerKeepCode,
  SimLedgerFate.discard => kSimLedgerDiscardCode,
};

/// 사유 코드 → 고름(다른 코드 = null).
SimLedgerFate? simLedgerFateOfReasonCode(String code) => switch (code) {
  kSimLedgerKeepCode => SimLedgerFate.keep,
  kSimLedgerDiscardCode => SimLedgerFate.discard,
  _ => null,
};

String _two(int n) => n.toString().padLeft(2, '0');

String _kstStamp(DateTime nowUtc) {
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  return '${k.year.toString().padLeft(4, '0')}${_two(k.month)}${_two(k.day)}'
      '-${_two(k.hour)}${_two(k.minute)}${_two(k.second)}';
}

/// 실전 개시 결정 id — `LIVEOPEN-{한국 YYYYMMDD-HHmmss}`.
String liveOpeningDecisionId(DateTime nowUtc) =>
    'LIVEOPEN-${_kstStamp(nowUtc)}';

/// S5 고름 결정 id — `SIMFATE-{한국 YYYYMMDD-HHmmss}-{순번 3자리}`(같은 초 두 번 = 순번).
String simLedgerFateDecisionId(DateTime nowUtc, int seq) =>
    'SIMFATE-${_kstStamp(nowUtc)}-${seq.toString().padLeft(3, '0')}';

/// 세션이 simToAuto 확정에 쓰일 수 있나 — 위저드 ∧ SIM_TO_AUTO ∧ 안 닫힘 ∧ 만료 전.
bool simToAutoSessionUsable(HandoverSessionRecord? s, DateTime nowUtc) =>
    s != null &&
    s.kind == HandoverSessionKind.wizard &&
    s.path == HandoverPath.simToAuto &&
    s.liveAt(nowUtc);

/// 대응 계좌별 개시 현금(0원 계좌 제외 · 별칭 순).
Map<String, int> liveOpeningCash(
  Iterable<LiveAccountProbe> probes,
  Set<String> aliases,
) {
  final Map<String, int> out = <String, int>{};
  for (final LiveAccountProbe p in probes) {
    if (!aliases.contains(p.alias)) continue;
    final int c = p.orderableCashKrw ?? 0;
    if (c > 0) out[p.alias] = c;
  }
  return Map<String, int>.fromEntries(
    out.entries.toList()..sort(
      (MapEntry<String, int> a, MapEntry<String, int> b) =>
          a.key.compareTo(b.key),
    ),
  );
}

/// 1단계 게이트(AG3) — 통과 = null · 아니면 거부 코드.
///
/// [report] = 실전 세션 시각 · 신뢰 시각으로 다시 낸 판정(세션 · 시각이 없으면 null).
/// [aliases] = 설정 `accountByStrategy` 의 값들.
String? simToAutoCommitReject({
  required DateTime? trustedNowUtc,
  required HandoverSessionRecord? session,
  required int liveModeRows,
  required SimToAutoReport? report,
  required Set<String> aliases,
  required List<LiveAccountProbe> probes,
}) {
  final DateTime? now = trustedNowUtc;
  if (now == null) return SimToAutoCodes.trustedTimeUnavailable;
  if (!simToAutoSessionUsable(session, now)) {
    return HandoverSessionCodes.sessionInvalid;
  }
  if (liveModeRows > 0) return SimToAutoCommitCodes.alreadyCommitted;
  if (report == null || !report.readyToCommit) {
    return report?.code ?? SimToAutoCodes.notSimAuto;
  }
  final Map<String, LiveAccountProbe> byAlias = <String, LiveAccountProbe>{
    for (final LiveAccountProbe p in probes) p.alias: p,
  };
  final List<String> sorted = aliases.toList()..sort();
  if (sorted.isEmpty) return SimToAutoCommitCodes.probeMissing;
  final List<LiveAccountProbe> mine = <LiveAccountProbe>[];
  for (final String a in sorted) {
    final LiveAccountProbe? p = byAlias[a];
    if (p == null) return SimToAutoCommitCodes.probeMissing;
    mine.add(p);
  }
  for (final LiveAccountProbe p in mine) {
    final DateTime at = p.fetchedAtUtc.toUtc();
    if (at.isAfter(now) || now.difference(at) > kHandoverPlanStaleAfter) {
      return SimToAutoCommitCodes.snapshotStale;
    }
  }
  if (mine.any((LiveAccountProbe p) => p.holdingsCount > 0)) {
    return SimToAutoCommitCodes.holdingsNotZero;
  }
  if (mine.any((LiveAccountProbe p) => p.activityToday > 0)) {
    return SimToAutoCommitCodes.brokerActivityToday;
  }
  if (mine.any(
    (LiveAccountProbe p) =>
        p.orderableCashKrw == null || p.orderableCashKrw! < 0,
  )) {
    return SimToAutoCommitCodes.cashUnknown;
  }
  if (liveOpeningCash(mine, aliases).isEmpty) {
    return SimToAutoCommitCodes.zeroCash;
  }
  return null;
}

String _won(int v) {
  final String s = v.toString();
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '$b원';
}

/// 1단계 문구(엔진 문자열 · 화면은 그대로 그린다) — 성공은 [cash] 를 준다.
String simToAutoCommitHeadline(String? code, {Map<String, int>? cash}) {
  if (code == null) {
    final Map<String, int> c = cash ?? const <String, int>{};
    final int total = c.values.fold(0, (int a, int b) => a + b);
    return '실전 자동 매매로 옮겼습니다 — 계좌 ${c.length}곳 예수금 ${_won(total)}으로 개시했습니다. '
        '실전은 주문 없이 관찰부터 시작합니다.';
  }
  return switch (code) {
    SimToAutoCodes.trustedTimeUnavailable => '시각을 확인할 수 없어 확정하지 않았습니다.',
    HandoverSessionCodes.sessionInvalid =>
      '전환 세션이 열려 있지 않거나 기한이 지났습니다 — 처음부터 다시 진행해 주세요.',
    SimToAutoCommitCodes.alreadyCommitted => '이미 실전으로 옮겼습니다.',
    SimToAutoCommitCodes.probeMissing => '연결한 실전 계좌 가운데 조회하지 못한 곳이 있습니다.',
    SimToAutoCommitCodes.snapshotStale => '계좌 조회가 오래됐습니다 — 다시 조회한 뒤 확정해 주세요.',
    SimToAutoCommitCodes.holdingsNotZero =>
      '실전 계좌에 보유 종목이 있어 확정하지 않았습니다 — 기존 보유를 넘겨받는 경로로 진행해 주세요.',
    SimToAutoCommitCodes.brokerActivityToday =>
      '오늘 실전 계좌에 주문 · 체결이 있어 확정하지 않았습니다 — 다음 거래일에 다시 확정해 주세요.',
    SimToAutoCommitCodes.cashUnknown => '실전 계좌 예수금을 알 수 없어 확정하지 않았습니다.',
    SimToAutoCommitCodes.zeroCash => '실전 계좌 예수금이 0원이라 확정하지 않았습니다.',
    SimToAutoCommitCodes.rolledBack =>
      '저장에 실패해 아무것도 바꾸지 않았습니다 — 전환 세션을 닫았으니 처음부터 다시 진행해 주세요.',
    _ => '아직 확정할 수 없습니다 — 전환 단계를 확인해 주세요.',
  };
}
