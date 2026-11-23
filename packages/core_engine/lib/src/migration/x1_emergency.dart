// X1-3 비상 복구 앞쪽 — 복원 전 기록 재료 · 재발급 적용 항목 · 체크리스트 다시 세우기(순수 · E16t3c · 설계 13 §8 R244 ·
// 01 §8 미결 218 ⓒ ⓓ · 06 X1-3 · 08 그림 9-2).
//
// 🔴 새 폰은 복원 전에 live 원장이 없다(복원 = live 없음일 때만 · `X1_LIVE_EXISTS`) → 비상 시작(`lease_revoke`) · 재발급 기록은
//    늘 열려 있는 sim 원장의 `command_inbox` 에 덧붙인다(O-04 ⑤ 첫 클레임 기록 R229 F5 선례 · 스키마 0 · 해시 · 지문만).
// 🔴 REVOKED 시각 = 서버가 `lease_revoke` 에서 돌려준 즉시 만료 시각(서버 `now()` — 기기 시계 0) · 펜싱 대기 끝 = 그 시각 + 펜싱 설정.
// 🔴 재발급 적용 항목 = 이 앱이 값을 쥐거나 로그인하는 서비스만(코드 사실) — 새 폰은 복원 전에 옛 폰 금고를 볼 수 없다.
// 🔴 수치 새로 정함 0 — 펜싱 마진 · 잔존 = 운영 설정(`operations.migration` 잠정 값) 읽기만.

import '../ops/ledger_views.dart' show kstDateText;
import 'reissue_checklist.dart' show ReissueChecklist, ReissueItem;

/// sim 원장 `command_inbox.kind` — 비상 회수(`lease_revoke`) 한 판의 기록.
const String kX1EmergencyRevokeKind = 'X1_EMERGENCY_REVOKE';

/// sim 원장 `command_inbox.kind` — 재발급 항목 하나의 기록(`command_id` = `{run_id}:{항목}`).
const String kX1ReissueRecordKind = 'X1_REISSUE_RECORD';

/// 🔴 재발급 적용 항목(KIS 앱키는 [ReissueChecklist.start] 가 늘 넣는다) — 이 앱이 값을 쥐거나 로그인하는 서비스만.
///
/// 감시 핑 키 = 바깥 감시 healthchecks(`healthchecks.ping_key` · 온보딩 o_10 필수) · Supabase 로그인 = 리스 · 신뢰 시각(o_07 필수 ·
/// 확인만). 메신저 토큰 · 구글 접근 = 이 앱에 값을 쥐는 자리 0 · 깃허브 토큰 = 아카이브 · 백업 올리기(E11n · D9) 전이라 값을
/// 쥐는 자리 0 → 셋 다 «해당 없음»(그 자리가 생기면 여기에 더한다).
const Set<ReissueItem> kX1ReissueUsedServices = <ReissueItem>{
  ReissueItem.watchdogPingKey,
  ReissueItem.supabaseSession,
};

/// 비상 복구 한 판의 이름(`rec-{시작 한국 날}-{순번}`).
String x1EmergencyRunIdOf(DateTime trustedNowUtc, int seq) {
  if (seq < 1) throw ArgumentError.value(seq, 'seq', '1 이상');
  return 'rec-${kstDateText(trustedNowUtc)}-$seq';
}

/// 저장된 재발급 항목 하나(🔴 값 0 — 지문만).
class X1ReissueRecord {
  /// 만든다.
  const X1ReissueRecord({
    required this.item,
    required this.fingerprint,
    required this.atUtc,
  });

  /// 항목.
  final ReissueItem item;

  /// 새 값 지문(확인만 항목 = null).
  final String? fingerprint;

  /// 받은 신뢰 시각.
  final DateTime atUtc;
}

/// 🔴 저장된 항목으로 체크리스트를 다시 세운다(저장 차례 · 저장 때 이미 판정 — 옛 지문 대조 0) · 어긋난 기록 = [FormatException].
ReissueChecklist reissueChecklistOf(Iterable<X1ReissueRecord> records) {
  ReissueChecklist c = ReissueChecklist.start(kX1ReissueUsedServices);
  for (final X1ReissueRecord r in records) {
    final (ReissueChecklist? next, String? code) = c.accept(
      r.item,
      fingerprint: r.fingerprint,
      priorFingerprints: const <String>{},
      trustedNowUtc: r.atUtc,
    );
    if (next == null) {
      throw FormatException('재발급 기록이 어긋났다($code)', r.item.wire);
    }
    c = next;
  }
  return c;
}

/// 비상 회수 한 판(새 폰 · 복원 전 · 🔴 평문 0).
class X1EmergencyFacts {
  /// 만든다.
  const X1EmergencyFacts({
    required this.runId,
    required this.operatorEpoch,
    required this.revokedAtUtc,
    required this.checklist,
  });

  /// 이 판(`rec-…`).
  final String runId;

  /// 회수로 얻은 epoch(옛 보유 epoch + 1 · 복원 뒤 새 폰 저널 `operator_epoch`).
  final int operatorEpoch;

  /// 🔴 REVOKED 시각(서버 `now()`).
  final DateTime revokedAtUtc;

  /// 재발급 진행.
  final ReissueChecklist checklist;
}
