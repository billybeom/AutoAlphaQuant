// R-01 기존 계정에서 다시 시작 — `RestartVm` 짓기(E16 R-01 진입로 · 설계 13 §8 R248 · 04 §9-6 · 01 §25 K26 · 계약 v1.16 · v1.29 T8 ·
// v1.34 `app_device` RLS `device_select_own`).
//
// 🔴 글자 = 표본 `m8/restart_vm_*`(합성 표시 없음 — 그대로) + 표본에 없는 사실 문장([RestartTexts] 아래 칸).
// 🔴 차례 = ① 로그인 자리(`RECOVERY_LOGIN` · 로그인 전 = 원장 · 게이트 · 분기 · 고지 0) → ② 기기 원장 요약(Supabase
//    `app_device` · `operator_lease` · 구 폰 = 리스를 쥔 기기) → ③ 분기(엔진이 고른다 · 화면은 갭 일수를 세지 않는다).
// 🔴 판정: 원장 · 신뢰 시각 · 갭 기준 하나라도 모름 = 게이트 UNKNOWN + 분기 0 · 리스 살아 있음 또는 끝났지만 마지막 접속이
//    재개 사다리 백업 기준(달력일) 안 = 계획 이전 · 비상 이전 · 끝났고 기준 이상 = 신규 온보딩 + 잔고 승계(RECOVERY_FULL 과
//    같은 기준) · 리스 행 없음 = 이어받을 기기 없음(분기 0) · 이 폰이 쥠 = 이 폰에 비상 회수 기록(sim `X1_EMERGENCY_REVOKE`)이
//    있으면 «비상 이전 이어 하기» · 없으면 분기 0(첫 클레임으로 이미 운영 기기).
// 🆕 리뷰 3차 D-04(01 §8 미결 236 ⓓ · 설계 13 §8 R267) — 이 폰이 쥠 ∧ 비상 회수 기록 0 ∧ 첫 클레임 기록(복구 카드 실행됨 · 대기) 0 =
//    서버가 `lease_revoke` 를 커밋했는데 응답을 잃은 자리 → «비상 이전 이어 하기» + «방금 적은 새 카드로» 안내(전에는 분기 0 = 막다른 길).
// 🔵 리뷰 3차 C-1 · D-01(미결 236 ⓐ) — 서버 `lease_claim` 은 이제 만료된 남의 리스를 그 기기가 회수 · 은퇴되기 전에는 넘기지 않는다 →
//    «신규 온보딩 + 잔고 승계» 분기(표본 `restart_vm_gap7`)도 구 폰 회수(비상 이전) 뒤에야 ⑤ 첫 클레임이 선다(⑤ 거부 글자 = 엔진
//    `RecoveryCardTexts.heldByOther` 가 비상 이전으로 안내). 🆕 계약 v1.39(앱 01 §48 K349 ⑤ ⑥) — 갭 분기 = 비상 이전 먼저
//    ([RestartTexts.branchRevokeFirst] → `x1MigrationEmergency`) · 고지 = 새로 시작은 이어받지 않음([RestartTexts.freshNotice] — D-U1
//    승계 구현 0 · 거짓 고지 정정) · 계획 · 비상 분기 고지는 [RestartTexts.inherit] 그대로.
// 🔴 킬스위치 · 차단 플래그 = 켜진 그대로 승계(«초기화» 선택지 0) — 분기가 있으면 고지가 늘 붙는다(C-50 ⑬).
// 🔴 돈 · 안전 수치 새로 정함 0 — 갭 기준 = 운영 설정 `resume.backup_gap_days`(재개 사다리 · 잠정 7) 그대로.

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        GateBadge,
        GateState,
        LinkAction,
        OnboardingSlotIds,
        RestartVm;

import '../migration/gap_rebuild.dart' show backupGapDaysOf;
import '../ops/ledger_views.dart' show kstDateText, kstMinuteText;

/// 리스 게이트 코드(표본 `m8/restart_vm_*`).
const String kRestartLeaseGateCode = 'X3_LEASE';

/// `app_device.status` 회수됨(배치 D CHECK).
const String kDeviceStatusRevoked = 'REVOKED';

/// R-01 글자.
abstract final class RestartTexts {
  /// 머리(표본).
  static const String headline = '기존 계정에서 다시 시작합니다';

  /// 승계 고지(표본).
  static const String inherit = '킬스위치와 차단 플래그는 켜진 그대로 이어받습니다.';

  /// 게이트 — 리스 확인(표본).
  static const String gatePass = '리스를 확인했습니다';

  /// 게이트 — 리스 끝남 · 갭 기준 넘음(표본).
  static const String gateEnded = '리스가 끝나 이 경로로는 이어받을 수 없습니다';

  /// 게이트 — 모름(표본).
  static const String gateUnknown = '리스 상태를 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다';

  /// 분기 — 계획 이전(표본).
  static const String branchPlan = '구 폰이 옆에 있어요 — 계획 이전(QR)';

  /// 분기 — 비상 이전(표본).
  static const String branchEmergency = '잃어버렸어요 — 비상 이전';

  /// 분기 — 신규 온보딩 + 잔고 승계(옛 표본 · v1.38 까지 · 쓰는 곳 0 — 다음 손질 때 지운다).
  static const String branchFresh = '신규 온보딩으로 진행하고 잔고 이어받기';

  /// 🆕 계약 v1.39 분기 — 갭 넘음 = 옛 폰을 비상 이전으로 먼저 끊는다(표본 `restart_vm_gap7`).
  static const String branchRevokeFirst = '먼저 비상 이전으로 옛 폰을 끊고 새로 시작하기';

  /// 🆕 계약 v1.39 고지 — 새로 시작은 이어받지 않는다(표본 `restart_vm_gap7`).
  static const String freshNotice =
      '새로 시작하면 옛 폰의 킬스위치 · 차단 플래그 · 기록을 이어받지 않습니다 — 온보딩을 처음부터 다시 합니다.';

  /// 마지막 접속 모름(표본).
  static const String lastSeenUnknown = '마지막 접속: 확인하지 못함';

  /// 구 폰 줄(표본 꼴 `구 폰: 거실 폰(Android)`).
  static String oldPhone(String label, String? platform) {
    final String? p = platform == null ? null : _platformText(platform);
    return p == null ? '구 폰: $label' : '구 폰: $label($p)';
  }

  /// 마지막 접속 줄(한국 분 · 표본 꼴).
  static String lastSeen(DateTime? utc) =>
      utc == null ? lastSeenUnknown : '마지막 접속: ${kstMinuteText(utc)}';

  /// 리스 남은 시간 줄(표본 꼴 «약 3시간»).
  static String leaseLeft(Duration d) {
    final int m = d.inMinutes;
    final String t = m >= 60
        ? '약 ${m ~/ 60}시간'
        : m >= 1
        ? '약 $m분'
        : '1분 미만';
    return '리스 남은 시간: $t';
  }

  /// 갭 기준 넘음 줄(표본 꼴 — 기준 일수).
  static String gapPassed(int days) => '마지막 접속 뒤 $days일이 지났습니다';

  // ── 표본에 없는 사실 문장 ──

  /// 원장을 못 읽음.
  static const String ledgerUnread = '기기 원장을 읽지 못했습니다';

  /// 리스를 쥔 기기가 원장에 안 보임.
  static const String holderUnseen = '리스를 쥔 기기를 기기 원장에서 찾지 못했습니다';

  /// 리스 끝남.
  static const String leaseEnded = '리스 남은 시간: 끝남';

  /// 리스 행 없음.
  static const String noOperator = '이 계정에 운영 기기 기록이 없습니다';

  /// 게이트 — 리스 행 없음.
  static const String gateNoOperator =
      '이어받을 운영 기기가 없습니다 — 첫 화면의 «처음 시작하기»로 진행하십시오';

  /// 이 폰이 리스를 쥠.
  static const String thisPhoneHolds = '이 폰이 운영 리스를 쥐고 있습니다';

  /// 게이트 — 이 폰이 이미 운영 기기.
  static const String gateThisPhone = '이 폰이 이미 운영 기기입니다 — 이어받을 기기가 없습니다';

  /// 분기 — 비상 회수 뒤 이어 하기.
  static const String branchEmergencyResume = '비상 이전 이어 하기';

  /// 🆕 리뷰 3차 D-04(미결 236 ⓓ) — 이 폰이 쥐었는데 이 폰에 회수 · 첫 클레임 기록이 없음(회수 응답 유실).
  static const String revokeAnswerLost =
      '이 폰에 비상 회수 기록이 없는데 서버는 이 폰을 운영 기기로 적었습니다 — 비상 회수의 응답을 받지 못했을 수 있습니다. '
      '옛 복구 카드는 이제 맞지 않습니다 — 비상 회수 때 종이에 새로 적은 복구 코드로 비상 이전을 이어 하십시오.';

  static String _platformText(String p) => switch (p) {
    'android' => 'Android',
    'ios' => 'iOS',
    _ => p,
  };
}

/// 기기 원장 한 행(`app_device` — RLS `device_select_own` 으로 읽은 것).
class RestartDevice {
  /// 만든다.
  const RestartDevice({
    required this.deviceId,
    required this.label,
    required this.status,
    this.platform,
    this.lastSeenAtUtc,
  });

  /// 기기 id.
  final String deviceId;

  /// 표시 라벨.
  final String label;

  /// 상태(PENDING · ACTIVE · RETIRED · REVOKED).
  final String status;

  /// 플랫폼(없음 = null).
  final String? platform;

  /// 마지막 접속(리스 클레임 · 갱신 때 서버가 적는다 · 없음 = null).
  final DateTime? lastSeenAtUtc;
}

/// 운영 리스 행(`operator_lease` 단일 행).
class RestartLease {
  /// 만든다.
  const RestartLease({
    required this.deviceId,
    required this.epoch,
    required this.expiresAtUtc,
  });

  /// 쥔 기기 id.
  final String deviceId;

  /// 세대.
  final int epoch;

  /// 만료(서버 `now()` 기준).
  final DateTime expiresAtUtc;
}

/// 읽은 기기 원장(기기 행 · 리스 행 — 없음 = null).
class RestartLedger {
  /// 만든다.
  const RestartLedger({required this.devices, required this.lease});

  /// 기기 행.
  final List<RestartDevice> devices;

  /// 리스 행(없음 = 첫 클레임 전).
  final RestartLease? lease;
}

/// R-01 사실.
class RestartFacts {
  /// 만든다.
  const RestartFacts({
    required this.signedIn,
    this.ledger,
    this.thisDeviceId,
    this.trustedNowUtc,
    this.backupGapDays,
    this.emergencyStarted = false,
    this.firstClaimRecorded = false,
  });

  /// 이 기기에 Supabase 로그인 세션이 있다(접근 토큰을 얻었다).
  final bool signedIn;

  /// 읽은 원장(로그인 뒤 null = 읽지 못함).
  final RestartLedger? ledger;

  /// 이 기기 id(없음 = null).
  final String? thisDeviceId;

  /// 신뢰 시각(모름 = null).
  final DateTime? trustedNowUtc;

  /// 재개 사다리 백업 기준(달력일 · `ResumeLadder.backupGapDays` · 못 읽음 = null).
  final int? backupGapDays;

  /// 이 폰에 비상 회수 한 판 기록이 있다(sim `command_inbox` `X1_EMERGENCY_REVOKE` EXECUTED · R244).
  final bool emergencyStarted;

  /// 🆕 리뷰 3차 D-04(미결 236 ⓓ) — 이 폰에 첫 클레임 기록이 있다(sim `command_inbox` `ONBOARDING_RECOVERY_CARD` 마지막 행이
  /// 실행됨 · 대기 — O-04 ⑤ · R229). 없음(기본) = 이 폰이 리스를 쥔 까닭을 이 폰이 모른다.
  final bool firstClaimRecorded;
}

GateBadge _gate(GateState s, String label) =>
    GateBadge(code: kRestartLeaseGateCode, label: label, state: s);

RestartVm _unknown(List<String> lines) => RestartVm(
  headline: RestartTexts.headline,
  ledgerLines: lines,
  leaseGate: _gate(GateState.unknown, RestartTexts.gateUnknown),
  branches: const <LinkAction>[],
);

const List<LinkAction> _x1Branches = <LinkAction>[
  LinkAction(
    label: RestartTexts.branchPlan,
    deepLink: AppRoutes.x1MigrationPlan,
  ),
  LinkAction(
    label: RestartTexts.branchEmergency,
    deepLink: AppRoutes.x1MigrationEmergency,
  ),
];

RestartVm _x1(List<String> lines) => RestartVm(
  headline: RestartTexts.headline,
  ledgerLines: lines,
  leaseGate: _gate(GateState.pass, RestartTexts.gatePass),
  branches: _x1Branches,
  inheritNotice: RestartTexts.inherit,
);

/// 🔴 R-01 VM — 판정표는 파일 머리.
RestartVm restartVmOf(RestartFacts f) {
  if (!f.signedIn) {
    return const RestartVm(
      headline: RestartTexts.headline,
      loginSlotId: OnboardingSlotIds.recoveryLogin,
      branches: <LinkAction>[],
    );
  }
  final RestartLedger? l = f.ledger;
  if (l == null) return _unknown(const <String>[RestartTexts.ledgerUnread]);
  final RestartLease? lease = l.lease;
  if (lease == null) {
    return RestartVm(
      headline: RestartTexts.headline,
      ledgerLines: const <String>[RestartTexts.noOperator],
      leaseGate: _gate(GateState.notApplicable, RestartTexts.gateNoOperator),
      branches: const <LinkAction>[],
    );
  }
  final String? me = f.thisDeviceId;
  if (me != null && lease.deviceId == me) {
    return _mine(
      l,
      me,
      emergencyStarted: f.emergencyStarted,
      firstClaimRecorded: f.firstClaimRecorded,
    );
  }
  RestartDevice? old;
  for (final RestartDevice d in l.devices) {
    if (d.deviceId == lease.deviceId) old = d;
  }
  if (old == null) return _unknown(const <String>[RestartTexts.holderUnseen]);
  final List<String> head = <String>[
    RestartTexts.oldPhone(old.label, old.platform),
    RestartTexts.lastSeen(old.lastSeenAtUtc),
  ];
  final DateTime? now = f.trustedNowUtc;
  if (now == null) return _unknown(head);
  final Duration left = lease.expiresAtUtc.difference(now);
  if (left > Duration.zero) {
    return _x1(<String>[...head, RestartTexts.leaseLeft(left)]);
  }
  final DateTime? seen = old.lastSeenAtUtc;
  final int? n = f.backupGapDays;
  if (seen == null || n == null) return _unknown(head);
  final int days = backupGapDaysOf(
    backupAuthoredDate: kstDateText(seen),
    recoveryAtUtc: now,
  );
  if (days >= n) {
    return RestartVm(
      headline: RestartTexts.headline,
      ledgerLines: <String>[...head, RestartTexts.gapPassed(n)],
      leaseGate: _gate(GateState.block, RestartTexts.gateEnded),
      branches: const <LinkAction>[
        LinkAction(
          label: RestartTexts.branchRevokeFirst,
          deepLink: AppRoutes.x1MigrationEmergency,
        ),
      ],
      inheritNotice: RestartTexts.freshNotice,
    );
  }
  return _x1(<String>[...head, RestartTexts.leaseEnded]);
}

/// 이 폰이 리스를 쥠 — 이 폰의 비상 회수 기록이 있으면 비상 이전 이어 하기(구 폰 줄 = 회수된 다른 기기 가운데
/// 마지막 접속이 가장 늦은 것 · 없으면 줄 0) · 🆕 회수 · 첫 클레임 기록이 둘 다 없으면(회수 응답 유실 · D-04) 같은 링크 + 안내 줄 ·
/// 첫 클레임 기록이 있으면 분기 0(이미 운영 기기).
RestartVm _mine(
  RestartLedger l,
  String me, {
  required bool emergencyStarted,
  required bool firstClaimRecorded,
}) {
  if (!emergencyStarted && firstClaimRecorded) {
    return RestartVm(
      headline: RestartTexts.headline,
      ledgerLines: const <String>[RestartTexts.thisPhoneHolds],
      leaseGate: _gate(GateState.notApplicable, RestartTexts.gateThisPhone),
      branches: const <LinkAction>[],
    );
  }
  RestartDevice? revoked;
  for (final RestartDevice d in l.devices) {
    if (d.deviceId == me || d.status != kDeviceStatusRevoked) continue;
    final DateTime? a = d.lastSeenAtUtc;
    final DateTime? b = revoked?.lastSeenAtUtc;
    if (revoked == null || (a != null && (b == null || a.isAfter(b)))) {
      revoked = d;
    }
  }
  final RestartDevice? old = revoked;
  return RestartVm(
    headline: RestartTexts.headline,
    ledgerLines: <String>[
      if (old != null) ...<String>[
        RestartTexts.oldPhone(old.label, old.platform),
        RestartTexts.lastSeen(old.lastSeenAtUtc),
      ],
      RestartTexts.thisPhoneHolds,
      if (!emergencyStarted) RestartTexts.revokeAnswerLost,
    ],
    leaseGate: _gate(GateState.pass, RestartTexts.gatePass),
    branches: const <LinkAction>[
      LinkAction(
        label: RestartTexts.branchEmergencyResume,
        deepLink: AppRoutes.x1MigrationEmergency,
      ),
    ],
    inheritNotice: RestartTexts.inherit,
  );
}
