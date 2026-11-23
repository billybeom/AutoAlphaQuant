// M8 `D-01` 장애 배너 — 열린 안전 사건 → 배너 VM(E11q-d2 · 설계 13 §8 · 06 M4-12 ① · 04 §6 · 앱 01 §26 K8 · K9 ·
// 01 §8 미결 164 · 표본 `m8/incident_banner_*`).
//
// 🔴 원천 = 엔진 `incidents` 의 열린 건(`resolved_at` 빈칸). 원인이 풀려 건이 닫히면(SEV2 · SEV3 = postmortem · SEV1 STOPPED =
//    결정) 배너가 사라진다 — 닫기 · «다시 보지 않기» 0. 여러 건이면 정렬해 첫 건 하나(최대 1건).
// 🔴 종류 = 지금 엔진이 `incidents` 에 쓰는 분류 둘(STOPPED SEV1 `BREAKER_STOPPED` · 대사 해제 SEV2 `MANUAL_ORDER`)은 네 종류
//    어디에도 맞지 않는다 → `other`. 토큰 만료 · 네트워크 단절 · 주문 거부는 원인의 수명(토큰을 다시 받으면 · 연결이 돌아오면 ·
//    그날)이 사건의 수명(postmortem 이 닫는다)과 달라 이 표에서 끌어오지 않는다 — 살아 있는 상태 원천이 서는 조각에서 더한다
//    (지어내지 않는다). 폰 사망 = 뷰어 파생(미결 164 · 죽은 폰은 자기 죽음을 못 낸다).
// 🔴 등급 = 심각도(03_운영 §4-6 · 카드 ⑤): SEV1(자금 손실 · 의도치 않은 체결 · STOPPED = 전 시스템 정지) = blocked ·
//    SEV2(postmortem 7일 필수) = act · SEV3(선택 · 월말 일괄) = info · 🔴 ok 는 오지 않는다.
// 🔴 글자 = 표본 제안 문장 그대로(종류마다 한 벌 · 뷰어도 같은 번들) · 조치 링크 = 조립 앱에 그 목적지의 본문이 있을 때만
//    (`hasBody` · 없으면 null = 버튼 부재).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        IncidentBanner,
        IncidentBannerVm,
        IncidentKind,
        LinkAction,
        UiLevel;

import 'block_board.dart' show routePatternOf;

/// 열린 안전 사건 한 건(`incidents` 의 `resolved_at` 빈 행 — 배너 원천 · 금액 0).
class OpenIncident {
  /// 건을 만든다.
  const OpenIncident({
    required this.incidentId,
    required this.severity,
    required this.category,
    required this.occurredAtUtc,
    this.dueAtUtc,
  });

  /// id · `SEV1` · `SEV2` · `SEV3` · 분류.
  final String incidentId, severity, category;

  /// 연 시각.
  final DateTime occurredAtUtc;

  /// postmortem 기한(v2.40 전 행 = 없음).
  final DateTime? dueAtUtc;
}

/// 배너 한 종류의 글자 한 벌.
class IncidentBannerCopy {
  /// 만든다.
  const IncidentBannerCopy({
    required this.title,
    required this.bodyText,
    this.action,
  });

  /// 제목 · 본문(표본 제안 문장).
  final String title, bodyText;

  /// 조치(글자 + 목적지 · 본문이 없는 빌드에서는 빠진다).
  final LinkAction? action;
}

/// `D-01` 배너 글자(표본 `m8/incident_banner_*` 제안 문장 그대로).
abstract final class IncidentBannerTexts {
  /// 종류마다 한 벌(5종 전부 — 폰 사망 = 뷰어가 같은 번들을 쓴다).
  static const Map<IncidentKind, IncidentBannerCopy> byKind =
      <IncidentKind, IncidentBannerCopy>{
        IncidentKind.phoneDown: IncidentBannerCopy(
          title: '폰 엔진 신호가 끊겼습니다',
          bodyText: '폰이 꺼졌거나 앱이 멈췄을 수 있습니다. 폰을 확인하세요. 자동 매매는 멈춘 상태로 봅니다.',
        ),
        IncidentKind.networkDown: IncidentBannerCopy(
          title: '네트워크 연결이 끊겼습니다',
          bodyText: '연결이 돌아오면 자동으로 다시 맞춥니다. 지금 할 일은 없습니다.',
        ),
        IncidentKind.tokenExpired: IncidentBannerCopy(
          title: '증권사 접근 토큰이 만료되었습니다',
          bodyText: '주문이 멈춰 있습니다. 연결 설정에서 토큰을 다시 받으면 이어서 진행합니다.',
          action: LinkAction(
            label: '연결 설정 열기',
            deepLink: AppRoutes.settingsCredentials,
          ),
        ),
        IncidentKind.orderRejected: IncidentBannerCopy(
          title: '주문 한 건이 거부되었습니다',
          bodyText: '증권사가 오늘 주문 한 건을 받지 않았습니다. 알림에서 원인을 확인하세요.',
          action: LinkAction(label: '알림 보기', deepLink: AppRoutes.alertsInbox),
        ),
        IncidentKind.other: IncidentBannerCopy(
          title: '확인이 필요한 일이 있습니다',
          bodyText: '자세한 내용은 운영 화면에서 확인하세요.',
        ),
      };
}

/// 종류 · 등급 → 배너 한 건 — 글자 = 번들 · 조치 = 조립 앱에 그 목적지의 본문이 있을 때만([hasBody] = 계약 라우트 패턴).
/// 🔴 [level] = [UiLevel.ok] 은 배너에 오지 않는다(던진다).
IncidentBanner incidentBannerOf(
  IncidentKind kind,
  UiLevel level, {
  required bool Function(String route) hasBody,
}) {
  if (level == UiLevel.ok) {
    throw ArgumentError.value(level, 'level', 'D-01 배너에 OK 는 오지 않는다');
  }
  final IncidentBannerCopy copy = IncidentBannerTexts.byKind[kind]!;
  return IncidentBanner(
    kind: kind,
    level: level,
    title: copy.title,
    bodyText: copy.bodyText,
    actionLink: _actionOf(copy.action, hasBody),
  );
}

LinkAction? _actionOf(LinkAction? a, bool Function(String route) hasBody) {
  if (a == null) return null;
  final String? pattern = routePatternOf(a.deepLink);
  return pattern != null && hasBody(pattern) ? a : null;
}

/// 사건 분류 → 배너 종류 — 지금 엔진이 쓰는 분류(`BREAKER_STOPPED` · `MANUAL_ORDER`)와 모르는 분류 = 늘 [IncidentKind.other]
/// (머리 주석 — 토큰 · 네트워크 · 주문 거부는 사건 표에서 끌어오지 않는다).
IncidentKind incidentKindOf(String category) => IncidentKind.other;

/// 심각도 → 배너 등급 — 🔴 모르는 값(스키마 CHECK 가 막는다) = 가장 무거운 쪽(가리지 않는다).
UiLevel incidentLevelOf(String severity) => switch (severity) {
  'SEV2' => UiLevel.act,
  'SEV3' => UiLevel.info,
  _ => UiLevel.blocked,
};

int _rank(String severity) => switch (severity) {
  'SEV2' => 1,
  'SEV3' => 2,
  _ => 0,
};

/// 열린 사건 → `D-01` VM — 없음 = `banner: null` · 여러 건 = 심각도(무거운 쪽) → 기한(이른 쪽 · 없음 = 뒤) → 연 시각 → id 차례의
/// 첫 건 하나.
IncidentBannerVm incidentBannerVmOf(
  Iterable<OpenIncident> open, {
  required bool Function(String route) hasBody,
}) {
  final List<OpenIncident> all = open.toList()..sort(compareIncidentUrgency);
  if (all.isEmpty) return const IncidentBannerVm();
  final OpenIncident first = all.first;
  return IncidentBannerVm(
    banner: incidentBannerOf(
      incidentKindOf(first.category),
      incidentLevelOf(first.severity),
      hasBody: hasBody,
    ),
  );
}

/// 배너 차례(앞 = 먼저) — 심각도(무거운 쪽) → 기한(이른 쪽 · 없음 = 뒤) → 연 시각(이른 쪽) → id.
int compareIncidentUrgency(OpenIncident a, OpenIncident b) {
  final int s = _rank(a.severity).compareTo(_rank(b.severity));
  if (s != 0) return s;
  final DateTime? da = a.dueAtUtc, db = b.dueAtUtc;
  if (da != null && db == null) return -1;
  if (da == null && db != null) return 1;
  if (da != null && db != null) {
    final int d = da.compareTo(db);
    if (d != 0) return d;
  }
  final int o = a.occurredAtUtc.compareTo(b.occurredAtUtc);
  return o != 0 ? o : a.incidentId.compareTo(b.incidentId);
}
