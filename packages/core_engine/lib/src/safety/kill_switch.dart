// 킬스위치 활성 판정 · 재개 준비 · 화면 문장(SPEC v2.40 04 §3-6 · 설계 13 §8 R56 K1 · K2 · 발주자 결정 2026-11-04).
//
// 🔴 48h 기준 = 체크리스트 확인 시각(발동 시각이 아니다) · 확인 전에는 카운트다운이 없다.
// 🔴 활성 = 발동 있음 ∧ (해제 없음 ∨ 결정 없음 ∨ 해제 − 확인 < 48h) — 손으로 고친 행은 풀지 못한다.
// 🔴 시각 = 신뢰 시각 — 모르면 재개를 막는다(발동 · 기록은 막지 않는다).

import 'package:domain_contracts/domain_contracts.dart' show KillSwitchView;

/// 킬스위치 config(02 §4 `kill_switch`).
class KillSwitchConfig {
  /// config 를 만든다.
  const KillSwitchConfig({
    this.resumeMinWait = const Duration(hours: 48),
    this.resumeChecklistItems = 7,
  });

  /// 최소 대기(체크리스트 확인부터).
  final Duration resumeMinWait;

  /// 재개판 문항 수.
  final int resumeChecklistItems;
}

/// P0S 기본값.
const KillSwitchConfig kP0sKillSwitchConfig = KillSwitchConfig();

/// `kill_switch_state` 한 행.
class KillSwitchRecord {
  /// 행을 만든다.
  const KillSwitchRecord({
    this.activatedAtUtc,
    this.checklistConfirmedAtUtc,
    this.clearedAtUtc,
    this.decisionId,
    this.activatedByDeviceLabel,
  });

  /// 발동 시각.
  final DateTime? activatedAtUtc;

  /// 발동 뒤 기록 확인 시각(48h 기준).
  final DateTime? checklistConfirmedAtUtc;

  /// 해제 시각.
  final DateTime? clearedAtUtc;

  /// 재개 저널.
  final String? decisionId;

  /// 발동 기기 별칭(원문 식별자 아님).
  final String? activatedByDeviceLabel;
}

/// 유효한 확인 시각 — 발동보다 앞선 확인은 «확인 없음»(K1 방어).
DateTime? effectiveChecklistConfirmedAt(KillSwitchRecord r) {
  final DateTime? a = r.activatedAtUtc;
  final DateTime? c = r.checklistConfirmedAtUtc;
  if (a == null || c == null || c.isBefore(a)) return null;
  return c;
}

/// 활성 판정(SPEC v2.40 04 §3-6 ② · K1).
bool killSwitchActive(
  KillSwitchRecord r, {
  KillSwitchConfig cfg = kP0sKillSwitchConfig,
}) {
  if (r.activatedAtUtc == null) return false;
  final DateTime? cleared = r.clearedAtUtc;
  final DateTime? confirmed = effectiveChecklistConfirmedAt(r);
  if (cleared == null || r.decisionId == null || confirmed == null) return true;
  // 해제가 확인보다 앞서면 차이가 음수 = 48h 미만 = 활성(따로 볼 필요 없다).
  return cleared.difference(confirmed) < cfg.resumeMinWait;
}

/// 재개 준비 상태(K2).
enum ResumeReadinessKind {
  /// 꺼져 있다.
  inactive,

  /// 발동 뒤 기록을 아직 확인하지 않았다(카운트다운 없음).
  checklistNotConfirmed,

  /// 신뢰 시각 모름.
  trustedTimeUnknown,

  /// 48h 대기 중.
  waiting,

  /// 재개 체크리스트를 시작할 수 있다.
  ready,
}

/// 재개 준비.
class ResumeReadiness {
  /// 준비 상태를 만든다.
  const ResumeReadiness(this.kind, {this.etaUtc, this.remaining});

  /// 상태.
  final ResumeReadinessKind kind;

  /// 해제 가능 예정 시각(확인 + 48h).
  final DateTime? etaUtc;

  /// 남은 시간(대기 중일 때).
  final Duration? remaining;
}

/// 재개 준비(K2) — [trustedNowUtc] = 신뢰 시각(모르면 null).
ResumeReadiness resumeReadinessOf(
  KillSwitchRecord r,
  DateTime? trustedNowUtc, {
  KillSwitchConfig cfg = kP0sKillSwitchConfig,
}) {
  if (!killSwitchActive(r, cfg: cfg)) {
    return const ResumeReadiness(ResumeReadinessKind.inactive);
  }
  final DateTime? confirmed = effectiveChecklistConfirmedAt(r);
  if (confirmed == null) {
    return const ResumeReadiness(ResumeReadinessKind.checklistNotConfirmed);
  }
  final DateTime eta = confirmed.add(cfg.resumeMinWait);
  if (trustedNowUtc == null) {
    return ResumeReadiness(ResumeReadinessKind.trustedTimeUnknown, etaUtc: eta);
  }
  if (trustedNowUtc.isBefore(eta)) {
    return ResumeReadiness(
      ResumeReadinessKind.waiting,
      etaUtc: eta,
      remaining: eta.difference(trustedNowUtc),
    );
  }
  return ResumeReadiness(ResumeReadinessKind.ready, etaUtc: eta);
}

String _kstMdHm(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(k.month)}-${two(k.day)} ${two(k.hour)}:${two(k.minute)}';
}

/// 화면 문장(K2 · 계약 `KillSwitchView` · 🔴 «해제» 버튼 필드는 없다).
KillSwitchView killSwitchViewOf(
  KillSwitchRecord r,
  DateTime? trustedNowUtc, {
  KillSwitchConfig cfg = kP0sKillSwitchConfig,
}) {
  final ResumeReadiness ready = resumeReadinessOf(r, trustedNowUtc, cfg: cfg);
  if (ready.kind == ResumeReadinessKind.inactive) {
    return const KillSwitchView(active: false, stateLabel: '킬스위치 꺼짐');
  }
  final DateTime? confirmed = effectiveChecklistConfirmedAt(r);
  return KillSwitchView(
    active: true,
    stateLabel: '킬스위치 작동 중 — 신규 주문을 막고 있습니다',
    activatedAt: r.activatedAtUtc,
    activatedByDeviceLabel: r.activatedByDeviceLabel,
    checklistStateLabel: confirmed == null
        ? '체크리스트를 먼저 마치십시오 — 마친 때부터 48시간을 셉니다'
        : '체크리스트 확인 ${_kstMdHm(confirmed)}',
    releaseEtaText: switch (ready.kind) {
      ResumeReadinessKind.checklistNotConfirmed => null,
      ResumeReadinessKind.trustedTimeUnknown =>
        '서버 시각을 확인하지 못해 해제 시각을 셀 수 없습니다',
      ResumeReadinessKind.waiting => '해제 가능 예정 ${_kstMdHm(ready.etaUtc!)}',
      ResumeReadinessKind.ready => '해제 가능 — 재개 체크리스트를 진행하십시오',
      ResumeReadinessKind.inactive => null,
    },
  );
}
