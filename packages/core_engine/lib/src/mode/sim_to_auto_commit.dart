// simToAuto 2단 커밋 1단계(실전 파일) 순수 몫 — 게이트 · 개시 현금 · 결정 id · 모의 기록 처리(S5) · 코드 · 문구
// (02 :692 §2-7 v2.44 ⓑ · 06 :242 · 04 :401 · 01 :3388 · 설계 13 §8 R93 AE1 f3 · R98 AG1~AG11).
//
// 🔴 판정만 한다 — 실전 파일 쓰기는 data_sync `SqliteSimToAutoCommitStore` · 모의 CLOSE · 지움 · 복구 = f3b.
// 🔴 보유 0 · 오늘 브로커 활동 0 · 5분 안 조회만 개시한다(커밋 당일 매도분이 대사에서 «원장에 없는 주문»이 되지 않게).
// 🔴 개시 현금 = D+2 주문가능 예수금(AG4 · ⬜ 발주자 확인) · 원 단위 · 0원 계좌 행 없음.
// 🔴 🆕 R192(미결 205 ⓓ · 01 §35 K177) — 지금 설정이 모의 파일에서 규칙 변경 승인을 받지 않았으면 개시하지 않는다
//    (실전 기동 = `approved == 1` · SAF-405 — 승인 없는 실전 원장을 만들지 않는다 · 냉각 30일 · SAF-405 수치 무변경).
// 🔵 코드 · 문구 = 엔진 문자열(계약 등재 = 1.20.0 후보 · `SIM_TO_AUTO_CONFIG_NOT_APPROVED` = 1.27.0+ 창).
// 🔴 🆕 R262(미결 233 ⓐ · 리뷰 3차 A-2) — 서로 다른 별칭이 같은 (종합계좌 · 상품코드)를 가리키면 개시하지 않는다
//    (`SIM_TO_AUTO_ACCOUNT_DUPLICATE` — 한 계좌의 예수금을 두 번 개시 현금으로 적고 한 별칭의 주문이 남의 계좌로 가는 길) ·
//    🔵 엔진 안 예약(계약 `SimToAutoCommitResultCodes` 등재 = 다음 계약 창 · 그 전 화면 = headline 만).

import 'package:domain_contracts/domain_contracts.dart' show HandoverPath;

import '../ops/lease_gate.dart' show LeaseVerdict, kLeaseInvalidCode;
import '../security/secret_mask.dart' show secretFingerprint;
import 'handover_session.dart'
    show HandoverSessionCodes, HandoverSessionKind, HandoverSessionRecord;
import 'sim_to_auto.dart'
    show
        SimLedgerFate,
        SimToAutoCodes,
        SimToAutoReport,
        kHandoverPlanStaleAfter;

/// 🆕 R262(A-2) — 계좌 표지 = 종합계좌번호 지문 + 상품코드(값 0 — «같은 계좌인가»만 본다 · 화면 · 기록 · 로그에 싣지 않는다).
String liveAccountMark({
  required String accountNo,
  required String productCode,
}) => '${secretFingerprint(accountNo.trim())}-${productCode.trim()}';

/// 실전 계좌 한 곳의 조회 결과(AG9 — 부르는 쪽이 브로커 잔고 포트로 채운다).
class LiveAccountProbe {
  /// 조회를 만든다.
  const LiveAccountProbe({
    required this.alias,
    required this.accountMark,
    required this.holdingsCount,
    required this.orderableCashKrw,
    required this.activityToday,
    required this.fetchedAtUtc,
  });

  /// 계좌 별칭(설정 `accountByStrategy` 의 값).
  final String alias;

  /// 🆕 R262(A-2) — 조회한 계좌의 표지([liveAccountMark] — 실제로 부른 종합계좌 · 상품코드 · 값 0).
  final String accountMark;

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

  /// 🆕 E15f4a — 세션을 연 기기 · 리스 세대가 지금과 다르다(R103 AI2).
  static const String leaseMismatch = 'SIM_TO_AUTO_LEASE_MISMATCH';

  /// 닫힌 모의 파일에는 S5 고름을 적지 않는다.
  static const String simClosed = 'SIM_LEDGER_FATE_SIM_CLOSED';

  /// 🆕 리뷰 3차 H2-02(미결 231 ⓑ · 설계 13 §8 R265) — 모의 파일의 지금 설정(모의 개시 판)을 못 읽어 S5 고름을 적지 않는다
  /// (빈 지문으로 결정을 남기지 않는다 · 쓰기 0).
  /// 🔵 엔진 안 예약 — 계약 등재(`settings_actions` S5 결과 코드 목록) = 다음 계약 창 · 그 전 화면 = headline 만.
  static const String fateConfigUnavailable =
      'SIM_LEDGER_FATE_CONFIG_UNAVAILABLE';

  /// 🆕 미결 205 ⓓ(설계 13 §8 R192 · 01 §35 K177) — 지금 설정(실전 개시에 붙일 판)이 규칙 변경 승인을 받지 않았다
  /// (모의 파일 승인 config 0 · 승인 기록 없음 · 다른 판이 승인됨).
  /// 🔵 엔진 안 예약 — 계약 `SimToAutoCommitResultCodes` 등재 = 다음 계약 창(1.27.0+) · 그 전 화면 = headline 만.
  static const String configNotApproved = 'SIM_TO_AUTO_CONFIG_NOT_APPROVED';

  /// 🆕 R262(미결 233 ⓐ · 리뷰 3차 A-2) — 서로 다른 별칭이 같은 계좌(종합계좌 · 상품코드)를 가리킨다.
  /// 🔵 엔진 안 예약 — 계약 `SimToAutoCommitResultCodes` 등재 = 다음 계약 창 · 그 전 화면 = headline 만.
  static const String accountDuplicate = 'SIM_TO_AUTO_ACCOUNT_DUPLICATE';
}

/// 🆕 미결 205 ⓓ — SAF-405 승인 config 재확인(R192) — 통과 = null.
///
/// [approvedConfigHash] = 모의 파일의 승인 config(승인 기록과 맞는 것만 · 없음 = null) ·
/// [configHash] = 실전 개시 결정에 붙일 지금 설정. 🔴 둘이 같아야 실전 기동(SAF-405 · `approved == 1`)이 선다.
String? simToAutoConfigApprovalReject({
  required String? approvedConfigHash,
  required String configHash,
}) => approvedConfigHash != null && approvedConfigHash == configHash
    ? null
    : SimToAutoCommitCodes.configNotApproved;

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

/// 🆕 E15f4a — 커밋 직전 리스 스냅숏(R103 AI3 — 리스 읽기는 async 라 트랜잭션 앞에서 잡아 넘긴다).
class LeaseSnapshot {
  /// 스냅숏을 만든다.
  const LeaseSnapshot({
    required this.verdict,
    required this.epoch,
    required this.deviceId,
  });

  /// 운영 중인 파일의 리스 판정.
  final LeaseVerdict verdict;

  /// 지금 리스 세대(`sync_state.operator_epoch` · 행 없음 = 0).
  final int epoch;

  /// 이 기기 id.
  final String deviceId;
}

/// 🆕 E15f4a — 리스 재확인(R103 AI2 · 06 :242 ⓑ) — 통과 = null · epoch 는 올리지 않는다.
///
/// 유효 아님 = `LEASE_INVALID` · 세션을 연 세대 · 기기가 지금과 다름 = `SIM_TO_AUTO_LEASE_MISMATCH`.
String? simToAutoLeaseReject(
  LeaseSnapshot lease,
  HandoverSessionRecord session,
) {
  if (lease.verdict != LeaseVerdict.valid) return kLeaseInvalidCode;
  if (session.leaseEpoch != lease.epoch || session.deviceId != lease.deviceId) {
    return SimToAutoCommitCodes.leaseMismatch;
  }
  return null;
}

/// 1단계 게이트(AG3 · 🆕 리스 = R103 AI4 · 🆕 승인 config = R192) — 통과 = null · 아니면 거부 코드.
///
/// [report] = 실전 세션 시각 · 신뢰 시각으로 다시 낸 판정(세션 · 시각이 없으면 null).
/// [aliases] = 설정 `accountByStrategy` 의 값들.
/// 🆕 [approvedConfigHash] · [configHash] = [simToAutoConfigApprovalReject](차례 = 이미 커밋 뒤 · 재판정 앞 —
/// 냉각 30일이 걸리는 막힘이라 24h 냉각 · 계좌 조회보다 먼저 말한다).
String? simToAutoCommitReject({
  required DateTime? trustedNowUtc,
  required HandoverSessionRecord? session,
  required LeaseSnapshot lease,
  required int liveModeRows,
  required String? approvedConfigHash,
  required String configHash,
  required SimToAutoReport? report,
  required Set<String> aliases,
  required List<LiveAccountProbe> probes,
}) {
  final DateTime? now = trustedNowUtc;
  if (now == null) return SimToAutoCodes.trustedTimeUnavailable;
  if (session == null || !simToAutoSessionUsable(session, now)) {
    return HandoverSessionCodes.sessionInvalid;
  }
  final String? leaseCode = simToAutoLeaseReject(lease, session);
  if (leaseCode != null) return leaseCode;
  if (liveModeRows > 0) return SimToAutoCommitCodes.alreadyCommitted;
  final String? configCode = simToAutoConfigApprovalReject(
    approvedConfigHash: approvedConfigHash,
    configHash: configHash,
  );
  if (configCode != null) return configCode;
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
  // 🆕 R262(A-2) — 서로 다른 별칭 = 서로 다른 계좌(같은 계좌 두 번 개시 · 남의 계좌로 가는 주문 0).
  final Set<String> marks = <String>{};
  for (final LiveAccountProbe p in mine) {
    if (!marks.add(p.accountMark)) return SimToAutoCommitCodes.accountDuplicate;
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
    SimToAutoCommitCodes.accountDuplicate => '연결한 실전 계좌 두 곳이 같은 계좌를 가리켜 확정하지 않았습니다 — 키 관리에서 실전(위탁 01) · ISA 계좌번호를 다시 확인해 주세요.',
    SimToAutoCommitCodes.snapshotStale => '계좌 조회가 오래됐습니다 — 다시 조회한 뒤 확정해 주세요.',
    SimToAutoCommitCodes.holdingsNotZero =>
      '실전 계좌에 보유 종목이 있어 확정하지 않았습니다 — 기존 보유를 넘겨받는 경로로 진행해 주세요.',
    SimToAutoCommitCodes.brokerActivityToday =>
      '오늘 실전 계좌에 주문 · 체결이 있어 확정하지 않았습니다 — 다음 거래일에 다시 확정해 주세요.',
    SimToAutoCommitCodes.cashUnknown => '실전 계좌 예수금을 알 수 없어 확정하지 않았습니다.',
    SimToAutoCommitCodes.zeroCash => '실전 계좌 예수금이 0원이라 확정하지 않았습니다.',
    SimToAutoCommitCodes.rolledBack =>
      '저장에 실패해 아무것도 바꾸지 않았습니다 — 전환 세션을 닫았으니 처음부터 다시 진행해 주세요.',
    kLeaseInvalidCode => '이 기기의 발주권(리스)을 확인할 수 없어 확정하지 않았습니다.',
    SimToAutoCommitCodes.leaseMismatch =>
      '전환을 시작한 기기 · 발주권이 지금과 달라 확정하지 않았습니다 — 처음부터 다시 진행해 주세요.',
    SimToAutoCommitCodes.configNotApproved => '지금 설정이 규칙 변경 승인을 받지 않아 확정하지 않았습니다 — 규칙 변경 게이트에서 승인(냉각 30일)을 받은 뒤 확정해 주세요.',
    _ => '아직 확정할 수 없습니다 — 전환 단계를 확인해 주세요.',
  };
}
