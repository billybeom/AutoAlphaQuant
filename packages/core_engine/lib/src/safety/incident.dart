// 안전 사건(`incidents`) 꼴 · MANUAL_ORDER SEV2 · postmortem 판정(SPEC 04 §3-5 ④ · 03_운영 카드 ⑤ · 설계 13 §8 R63 V1~V3).
//
// 🔴 건 = 금액 0(날 · 원인 · 절차만).
// 🔴 postmortem 은 한 번만 쓴다(감사 기록은 덮지 않는다 — 고칠 일이 있으면 새 저널).
// 🔴 SEV2 · SEV3 = postmortem 이 건을 닫는다 · SEV1(STOPPED) = 열린 채(STOPPED 결정이 닫는다 — E13d2).

import 'package:domain_contracts/domain_contracts.dart' show OriginCodes;

import '../ops/ledger_views.dart' show kstDateText;

/// 안전 사건 한 건(`incidents` 꼴).
class SafetyIncident {
  /// 건을 만든다.
  const SafetyIncident({
    required this.incidentId,
    required this.severity,
    required this.category,
    required this.description,
    required this.occurredAtUtc,
    required this.dueAtUtc,
  });

  /// id(같은 사건 = 같은 id — 다시 써도 1건).
  final String incidentId;

  /// `SEV1` · `SEV2` · `SEV3`.
  final String severity;

  /// 분류.
  final String category;

  /// 설명(금액 0).
  final String description;

  /// 연 시각 · postmortem 기한.
  final DateTime occurredAtUtc, dueAtUtc;
}

/// STOPPED SEV1 의 꼴(E13d1 이름 — 같은 꼴).
typedef StoppedIncident = SafetyIncident;

/// MANUAL_ORDER 해제 뒤 SEV2 postmortem 기한(04 §3-5 ④ · 카드 ⑤).
const Duration kManualOrderPostmortemDue = Duration(days: 7);

/// MANUAL_ORDER 대사 해제의 SEV2(R63 V1) — id = 저널 id(해제 한 번 = 건 하나).
SafetyIncident manualOrderIncidentOf({
  required String decisionId,
  required DateTime clearedAtUtc,
}) => SafetyIncident(
  incidentId: 'SEV2-${OriginCodes.manualOrder}-$decisionId',
  severity: 'SEV2',
  category: OriginCodes.manualOrder,
  description:
      '${kstDateText(clearedAtUtc)} 대사 해제 — 원인 MANUAL_ORDER(수동 주문 = 규칙 이탈) · '
      'postmortem 7일 · 03_운영 카드 ⑤ · 저널 $decisionId',
  occurredAtUtc: clearedAtUtc.toUtc(),
  dueAtUtc: clearedAtUtc.toUtc().add(kManualOrderPostmortemDue),
);

/// postmortem 거부 코드(R63 V2 · 차례 = 이 선언 차례).
abstract final class PostmortemCodes {
  /// 건이 없다.
  static const String notFound = 'INCIDENT_NOT_FOUND';

  /// 글이 비었다.
  static const String blank = 'POSTMORTEM_BLANK';

  /// 이미 썼다.
  static const String alreadyRecorded = 'POSTMORTEM_ALREADY_RECORDED';
}

/// postmortem 판정(R63 V2) — 통과 = null.
String? postmortemRejectCode({
  required bool incidentExists,
  required String? existingPostmortem,
  required String text,
}) {
  if (!incidentExists) return PostmortemCodes.notFound;
  if (text.trim().isEmpty) return PostmortemCodes.blank;
  if (existingPostmortem != null && existingPostmortem.trim().isNotEmpty) {
    return PostmortemCodes.alreadyRecorded;
  }
  return null;
}

/// 🔴 postmortem 이 건을 닫는가(R63 V2) — SEV1 은 결정이 닫는다.
bool postmortemClosesIncident(String severity) => severity != 'SEV1';

/// 기한을 넘겼나(R63 V3) — postmortem 빈칸 ∧ 기한 < 지금.
bool postmortemOverdue({
  required DateTime? dueAtUtc,
  required String? postmortem,
  required DateTime nowUtc,
}) =>
    dueAtUtc != null &&
    (postmortem == null || postmortem.trim().isEmpty) &&
    dueAtUtc.isBefore(nowUtc);
