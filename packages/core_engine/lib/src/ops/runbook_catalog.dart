// M8 `D-02` DR 런북 · `D-03` 오프라인 긴급정지 카드 — 원고 번들 · VM 짓기(E11q-d1 · 설계 13 §8 · 06 M4-12 ② · 04 §6 ·
// 앱 01 §26 K10 · K11 · 표본 `m8/runbook_*` · `m8/emergency_card*`).
//
// 🔴 글자 = 표본 제안 문장 그대로(원고 = 03_실행 §10-5 여섯 시나리오 · 04_안전장치 §5-5 — 폰 호스트판 문안은 표본이 처음 적었다).
// 🔴 원고가 없는 런북(기록 손상 · 증권사 장기 장애 · 계좌 접근 불가 · 키 유출)은 목록 행만 두고 상세 = «준비 중» 엔진 문장 —
//    단계를 지어내지 않는다(DR 절차 문안 = 원고 창 몫). 모르는 id = 표본 `runbook_missing` 문장.
// 🔴 긴급 카드 = 공개 고객센터 번호만(계좌번호 · 앱키 · 개인 연락처 0 — C-14 · C-51 ⑤) · 인쇄 = 빌드가 인쇄할 수 있을 때만
//    슬롯 이름(`EMERGENCY_CARD_PRINT`) — 없으면 null(버튼 부재).
// 🔴 원천 = 이 번들(원장 · 설정 · 시계 0) — 폰이 죽어도 · 온보딩 전에도 같은 글자(뷰어도 같은 번들 — 06 M4-12 ②).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        EmergencyCardVm,
        LinkAction,
        OpsSlotIds,
        RunbookIndexVm,
        RunbookRow,
        RunbookStep,
        RunbookVm;

/// M8 런북 · 긴급 카드 글자(표본 제안 문장 · 엔진 사유 문장).
abstract final class RunbookTexts {
  /// 상세 하단 고지(엔진이 늘 싣는다 · 표본 그대로).
  static const String localCheckNotice =
      '확인 표시는 이 화면에서만 보입니다. 저장되지 않고, 아무것도 실행하지 않습니다.';

  /// 모르는 id 의 제목(표본 `runbook_missing`).
  static const String missingTitle = '런북';

  /// 모르는 id(표본 `runbook_missing`).
  static const String missingLabel = '이 런북은 지금 목록에 없습니다. 런북 목록에서 다시 고르십시오.';

  /// 🆕 목록에 있지만 원고가 아직 없는 런북(엔진 사유 — 단계를 지어내지 않는다).
  static const String preparingLabel =
      '이 런북의 단계는 아직 준비 중입니다. 런북 목록에서 다른 런북을 고르십시오.';

  /// 행 0(표본 `runbook_index_empty`).
  static const String emptyLabel = '등록된 런북이 없습니다.';
}

/// 런북 한 편의 본문(원고).
class RunbookBody {
  /// 만든다.
  const RunbookBody({this.introText, required this.steps});

  /// 머리 한 문단(null = 없음).
  final String? introText;

  /// 번호 단계(차례 그대로 · 번호 = 글자).
  final List<RunbookStep> steps;
}

/// 런북 목록 한 행 + 상세 원고.
class RunbookEntry {
  /// 만든다.
  const RunbookEntry({
    required this.title,
    this.summaryText,
    required this.deepLink,
    this.runbookId,
    this.body,
  });

  /// 행 제목 = 상세 제목.
  final String title;

  /// 한 줄 요약(null = 줄 없음).
  final String? summaryText;

  /// 행 링크(엔진 완성).
  final String deepLink;

  /// 상세 id(`aaq://ops/runbooks/<id>`) — 긴급 카드로 여는 행 = null.
  final String? runbookId;

  /// 원고(null = 준비 중).
  final RunbookBody? body;
}

String _runbookLink(String id) =>
    AppRoutes.opsRunbook.replaceFirst(':runbookId', id);

/// 런북 원고 번들(표본 `runbook_index` 차례 · 글자 그대로 · 원고 = `host-lost` 하나).
final List<RunbookEntry> kRunbookCatalog = List<RunbookEntry>.unmodifiable(
  <RunbookEntry>[
    RunbookEntry(
      title: '운영 폰을 잃어버렸거나 고장 났을 때',
      summaryText: '주문을 먼저 멈추고 새 폰으로 옮깁니다',
      runbookId: 'host-lost',
      deepLink: _runbookLink('host-lost'),
      body: const RunbookBody(
        introText: '다시 세우기 전에 주문이 겹치지 않게 하는 것이 먼저입니다. 기록은 백업에서 되살립니다.',
        steps: <RunbookStep>[
          RunbookStep(orderText: '1.', text: '새 폰에 앱을 설치하고 복구 카드로 로그인합니다.'),
          RunbookStep(
            orderText: '2.',
            text: '예전 폰을 잃어버린 경우의 이전 절차를 시작하고, 예전 폰의 권한이 끊길 때까지 기다립니다.',
          ),
          RunbookStep(orderText: '2-1.', text: '증권사 앱키를 새 폰의 키 금고에 다시 넣습니다.'),
          RunbookStep(
            orderText: '3.',
            text: '백업에서 기록을 되살린 뒤 증권사 잔고와 맞춰 봅니다. 차이가 있으면 새 주문을 막아 둔 채로 둡니다.',
          ),
          RunbookStep(
            orderText: '4.',
            text: '하루 동안 모의 운영으로 돌려 본 다음 실제 주문을 다시 켭니다.',
          ),
        ],
      ),
    ),
    RunbookEntry(
      title: '기록이 깨졌을 때',
      runbookId: 'db-corrupt',
      deepLink: _runbookLink('db-corrupt'),
    ),
    RunbookEntry(
      title: '증권사 연결이 오래 끊겼을 때',
      summaryText: '정해 둔 시각이 지나면 손으로 주문합니다',
      runbookId: 'broker-outage',
      deepLink: _runbookLink('broker-outage'),
    ),
    RunbookEntry(
      title: '계좌에 접근할 수 없을 때',
      summaryText: '재발급 절차와 걸리는 날을 확인합니다',
      runbookId: 'account-access',
      deepLink: _runbookLink('account-access'),
    ),
    RunbookEntry(
      title: '키가 새어 나갔을 때',
      runbookId: 'secret-leak',
      deepLink: _runbookLink('secret-leak'),
    ),
    const RunbookEntry(
      title: '오래 자리를 비우거나 크게 아플 때',
      summaryText: '가족이 종이 카드로 멈춥니다',
      deepLink: AppRoutes.opsEmergencyCard,
    ),
  ],
);

/// `D-02` 목록 — 번들 차례 그대로 · 행 0 = 빈 문장.
RunbookIndexVm runbookIndexVmOf([List<RunbookEntry>? catalog]) {
  final List<RunbookEntry> c = catalog ?? kRunbookCatalog;
  return RunbookIndexVm(
    rows: <RunbookRow>[
      for (final RunbookEntry e in c)
        RunbookRow(
          title: e.title,
          summaryText: e.summaryText,
          deepLink: e.deepLink,
        ),
    ],
    emptyLabel: c.isEmpty ? RunbookTexts.emptyLabel : null,
  );
}

/// `D-02` 상세 — 원고 있음 = 단계 · 목록에 있으나 원고 없음 = «준비 중» · 모르는 id = 표본 문장(스트림 오류 아님).
RunbookVm runbookVmOf(String runbookId, [List<RunbookEntry>? catalog]) {
  RunbookEntry? hit;
  for (final RunbookEntry e in catalog ?? kRunbookCatalog) {
    if (e.runbookId != null && e.runbookId == runbookId) hit = e;
  }
  if (hit == null) {
    return const RunbookVm(
      title: RunbookTexts.missingTitle,
      steps: <RunbookStep>[],
      localCheckNotice: RunbookTexts.localCheckNotice,
      missingLabel: RunbookTexts.missingLabel,
    );
  }
  final RunbookBody? body = hit.body;
  if (body == null || body.steps.isEmpty) {
    return RunbookVm(
      title: hit.title,
      steps: const <RunbookStep>[],
      localCheckNotice: RunbookTexts.localCheckNotice,
      missingLabel: RunbookTexts.preparingLabel,
    );
  }
  return RunbookVm(
    title: hit.title,
    introText: body.introText,
    steps: List<RunbookStep>.unmodifiable(body.steps),
    localCheckNotice: RunbookTexts.localCheckNotice,
  );
}

/// 런북 상세 링크 — 그 런북의 원고가 있고 조립 앱에 상세 본문이 있을 때만(없으면 null = 링크 부재).
/// 🔵 S02 «키가 새어 나갔을 때»(`leakRunbookLink`)가 쓴다 — `secret-leak` 원고가 생기면 저절로 선다.
LinkAction? runbookLinkOf(
  String runbookId, {
  required bool Function(String route) hasBody,
  List<RunbookEntry>? catalog,
}) {
  if (!hasBody(AppRoutes.opsRunbook)) return null;
  for (final RunbookEntry e in catalog ?? kRunbookCatalog) {
    final RunbookBody? body = e.body;
    if (e.runbookId == runbookId && body != null && body.steps.isNotEmpty) {
      return LinkAction(label: e.title, deepLink: e.deepLink);
    }
  }
  return null;
}

/// 긴급 카드 글자(표본 `emergency_card` 그대로 · 04_안전장치 §5-5 · 가족용 — 전문 용어 0).
abstract final class EmergencyCardTexts {
  /// 제목.
  static const String title = '자동매매 긴급 정지 카드';

  /// 정지 단계.
  static const List<RunbookStep> steps = <RunbookStep>[
    RunbookStep(orderText: '1.', text: '증권사 앱에 로그인합니다.'),
    RunbookStep(orderText: '2.', text: '자동주문 설정이 켜져 있으면 끕니다.'),
    RunbookStep(orderText: '3.', text: '체결되지 않은 주문을 모두 취소합니다.'),
    RunbookStep(
      orderText: '3-1.',
      text: '가진 종목은 급히 팔지 않아도 됩니다. 멈추기만 해도 충분합니다.',
    ),
    RunbookStep(orderText: '4.', text: '그래도 주문이 나가면 고객센터에 전화해 자동주문 차단을 요청합니다.'),
  ];

  /// 연락처(공개 대표번호만 · 개인 연락처 = 종이에 손으로).
  static const String contactLine =
      '한국투자증권 고객센터 1544-5000 · 이 시스템을 아는 사람의 연락처는 종이에 직접 적어 둡니다.';

  /// 보관 고지(늘 싣는다).
  static const String keepOnPaperNotice =
      '이 카드는 인쇄해서 가족이 아는 곳에 종이로 보관하세요. 계좌번호와 앱키는 이 카드에 없습니다.';
}

/// `D-03` 카드 — [printable] = 이 빌드가 인쇄 · PDF 위젯을 끼울 수 있나(아니면 슬롯 이름 null = 버튼 부재).
EmergencyCardVm emergencyCardVmOf({required bool printable}) => EmergencyCardVm(
  title: EmergencyCardTexts.title,
  steps: EmergencyCardTexts.steps,
  contactLine: EmergencyCardTexts.contactLine,
  keepOnPaperNotice: EmergencyCardTexts.keepOnPaperNotice,
  printSlotId: printable ? OpsSlotIds.emergencyCardPrint : null,
);
