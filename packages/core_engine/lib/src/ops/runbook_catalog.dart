// M8 `D-02` DR 런북 · `D-03` 오프라인 긴급정지 카드 — 원고 번들 · VM 짓기(E11q-d1 · 설계 13 §8 · 06 M4-12 ② · 04 §6 ·
// 앱 01 §26 K10 · K11 · 표본 `m8/runbook_*` · `m8/emergency_card*`).
//
// 🔴 글자 = 표본 제안 문장 그대로(원고 = 03_실행 §10-5 여섯 시나리오 · 04_안전장치 §5-5 — 폰 호스트판 문안은 표본이 처음 적었다).
// 🆕 E11q-d1b(R236) — 런북 넷(기록 손상 · 증권사 장기 장애 · 계좌 접근 불가 · 키 유출) 폰 호스트판 원고 = 03_실행 §10-5
//    ②③④⑤ 를 폰 앱 기능(킬스위치 · 증권사 키 · 백업·복원 · 정정 · 새 폰 복구 · 연결)으로 옮긴 글(발주자 확정본) ·
//    본문 숫자 0(번호 글자 빼고) · 목록 행 제목·요약 = 표본 그대로. 원고가 없는 런북 = 상세 «준비 중» 엔진 문장(단계를
//    지어내지 않는다 — 지금 번들에는 없다 · 갈래는 남긴다). 모르는 id = 표본 `runbook_missing` 문장.
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

/// 런북 원고 번들(표본 `runbook_index` 차례 · 글자 그대로 · 원고 = `host-lost` + 🆕 E11q-d1b 넷 — 긴급 카드 행은 카드로 연다).
final List<RunbookEntry>
kRunbookCatalog = List<RunbookEntry>.unmodifiable(<RunbookEntry>[
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
    body: const RunbookBody(
      introText: '기록이 깨지면 앱은 어제까지 무엇을 샀는지 믿을 수 없어 주문을 스스로 멈춥니다. 맞는 값은 증권사 계좌의 잔고이니, 서두르지 말고 깨진 기록 위에서는 아무 주문도 내지 않는 것이 먼저입니다.',
      steps: <RunbookStep>[
        RunbookStep(
          orderText: '1.',
          text: '앱이 기록을 믿을 수 없다고 알리면 주문은 이미 막혀 있습니다. 막힘을 억지로 풀지 않습니다.',
        ),
        RunbookStep(
          orderText: '2.',
          text: '앱의 정정 화면을 엽니다. 앱이 정정으로 고칠 수 있는지, 새 폰 복구가 필요한지를 먼저 알려 줍니다.',
        ),
        RunbookStep(
          orderText: '3.',
          text: '정정으로 고칠 수 있다고 나오면, 정정 마법사가 보여 주는 차이를 증권사 앱의 잔고·체결 내역과 하나씩 맞춰 보고 원인을 골라 바로잡습니다.',
        ),
        RunbookStep(
          orderText: '3-1.',
          text: '원인이 확실하지 않으면 «아무것도 안 하기»를 고르고 다음 거래일에 다시 봅니다. 체결 반영이 늦어 생긴 차이는 대개 저절로 풀립니다.',
        ),
        RunbookStep(
          orderText: '4.',
          text: '새 폰 복구가 필요하다고 나오면, 같은 폰이라도 앱이 보여 주는 새 폰 복구 안내를 따릅니다. «운영 폰을 잃어버렸거나 고장 났을 때» 런북과 같은 절차입니다.',
        ),
        RunbookStep(
          orderText: '5.',
          text: '바로잡거나 되살린 뒤에는 앱이 증권사 잔고와 다시 맞춰 봅니다. 어긋남이 남아 있으면 새 주문을 막아 둔 채로 둡니다.',
        ),
        RunbookStep(
          orderText: '6.',
          text: '평소에 «백업·복원» 화면에서 백업이 쌓이고 있는지 가끔 확인합니다. 지금 백업은 이 폰 안에만 있어서, 폰을 잃으면 백업도 함께 잃습니다.',
        ),
      ],
    ),
  ),
  RunbookEntry(
    title: '증권사 연결이 오래 끊겼을 때',
    summaryText: '정해 둔 시각이 지나면 손으로 주문합니다',
    runbookId: 'broker-outage',
    deepLink: _runbookLink('broker-outage'),
    body: const RunbookBody(
      introText: '증권사 연결이 끊기면 앱은 주문을 내지 못하고 그날 주문을 미룹니다. 연결이 돌아오면 앱이 그때 다시 판정해서 내므로, 대부분은 기다리는 것이 맞습니다. 정해 둔 시각은 앱이 그날 주문을 낼 수 있는 마지막 시각이고, 손으로 주문하는 것은 그 시각이 지난 뒤의 마지막 수단입니다.',
      steps: <RunbookStep>[
        RunbookStep(
          orderText: '1.',
          text: '앱의 장애 배너와 알림으로 증권사 연결이 끊긴 것인지 확인합니다. 증권사 홈페이지의 점검 공지도 함께 봅니다.',
        ),
        RunbookStep(
          orderText: '2.',
          text: '정해 둔 시각까지는 기다립니다. 그사이 증권사 앱으로 따로 주문하지 않습니다. 따로 주문하면 연결이 돌아왔을 때 앱의 기록과 계좌가 어긋나 모든 주문이 멈춥니다.',
        ),
        RunbookStep(
          orderText: '3.',
          text: '정해 둔 시각이 지나도 끊겨 있고 그날 앱이 팔려던 주문이 있을 때만 손으로 냅니다. 사는 주문은 손으로 내지 않습니다. 연결이 돌아온 뒤 앱이 다시 판정합니다.',
        ),
        RunbookStep(
          orderText: '3-1.',
          text: '손으로 내기 전에 앱의 킬스위치를 켜 둡니다. 연결이 돌아온 순간 앱이 같은 주문을 또 내지 않게 합니다.',
        ),
        RunbookStep(
          orderText: '3-2.',
          text: '앱이 보여 주는 그날 주문의 종목·수량 그대로만 냅니다. 새로 판단해서 더 팔거나 덜 팔지 않습니다.',
        ),
        RunbookStep(
          orderText: '4.',
          text: '연결이 돌아오면 앱이 증권사 잔고와 맞춰 봅니다. 손으로 낸 주문 때문에 어긋남이 뜨면 원인으로 «수동 주문»을 골라 해소하고, 앱이 여는 일지에 왜 손으로 냈는지 적습니다.',
        ),
        RunbookStep(
          orderText: '5.',
          text: '킬스위치를 켰다면 재개 절차(체크리스트와 대기 시간)를 거쳐 끕니다. 여러 날 끊겼다면 앱은 지난 계획을 그대로 내지 않고 다시 판정하며, 오래 끊겼으면 한동안 지켜보기만 할 수 있습니다.',
        ),
      ],
    ),
  ),
  RunbookEntry(
    title: '계좌에 접근할 수 없을 때',
    summaryText: '재발급 절차와 걸리는 날을 확인합니다',
    runbookId: 'account-access',
    deepLink: _runbookLink('account-access'),
    body: const RunbookBody(
      introText: '인증서나 보안 매체를 잃어버렸거나 증권사 앱키가 만료·해지되면 앱은 증권사에 접속하지 못해 아무 주문도 내지 못합니다. 재발급에는 며칠이 걸릴 수 있지만, 그동안 가진 종목은 그대로 있습니다.',
      steps: <RunbookStep>[
        RunbookStep(
          orderText: '1.',
          text: '앱의 알림과 «증권사 키» 화면에서 어느 계좌의 어떤 키가 막혔는지 확인합니다.',
        ),
        RunbookStep(
          orderText: '2.',
          text: '증권사 앱이나 홈페이지에 직접 로그인되는지 봅니다. 로그인도 안 되면 인증서·보안 매체부터, 로그인은 되는데 이 앱만 막혔으면 앱키부터 다시 받습니다.',
        ),
        RunbookStep(
          orderText: '3.',
          text: '인증서나 보안 매체를 잃어버렸다면 증권사 고객센터나 지점에서 분실 신고와 재발급을 합니다. 남이 쓸 수 있었다면 «키가 새어 나갔을 때» 런북을 먼저 따릅니다.',
        ),
        RunbookStep(
          orderText: '4.',
          text: '앱키가 만료되거나 해지됐다면 증권사 개발자 센터에서 새 앱키를 받고, 앱의 «증권사 키» 화면에서 새 키를 넣고 검증합니다.',
        ),
        RunbookStep(
          orderText: '4-1.',
          text: '해지했다가 다시 신청한 앱키는 처음 며칠 동안 증권사가 주문 속도를 낮춥니다. 이 시스템의 주문 수로는 대개 문제없지만, 그동안 오류 알림이 오면 확인합니다.',
        ),
        RunbookStep(
          orderText: '5.',
          text: '다시 연결되면 앱이 증권사 잔고와 맞춰 본 뒤 이어서 주문합니다. 며칠 끊겼다면 앱은 지난 계획을 그대로 내지 않고 다시 판정합니다.',
        ),
        RunbookStep(
          orderText: '6.',
          text:
              '평소에 «증권사 키» 화면에서 앱키 만료일을 보고, 가까워지면 미리 바꿉니다. 인증서 유효기간도 함께 챙깁니다.',
        ),
      ],
    ),
  ),
  RunbookEntry(
    title: '키가 새어 나갔을 때',
    runbookId: 'secret-leak',
    deepLink: _runbookLink('secret-leak'),
    body: const RunbookBody(
      introText: '앱키가 남에게 새어 나가면 남이 내 계좌로 주문을 낼 수 있습니다. 원인을 따지기 전에 먼저 멈추고, 그다음 열쇠를 바꾸는 순서가 중요합니다. 한 번이라도 밖에 드러난 키는 새어 나간 것으로 봅니다.',
      steps: <RunbookStep>[
        RunbookStep(
          orderText: '1.',
          text: '앱의 킬스위치를 먼저 켭니다. 이 폰을 쓸 수 없으면 다른 기기의 킬스위치나 긴급 정지 카드 절차를 씁니다.',
        ),
        RunbookStep(
          orderText: '2.',
          text:
              '증권사 개발자 센터에서 새어 나간 앱키를 폐기하고 새로 발급받습니다. 폐기한 키로는 누구도 주문할 수 없습니다.',
        ),
        RunbookStep(orderText: '3.', text: '앱의 «증권사 키» 화면에서 새 키로 바꾸고 검증합니다.'),
        RunbookStep(
          orderText: '4.',
          text: '같은 곳에 있던 다른 열쇠도 새어 나갔다고 보고 차례로 바꿉니다. 알림 채널 토큰, 미러와 아카이브 접속 토큰, 생존 신호 키가 여기에 듭니다.',
        ),
        RunbookStep(
          orderText: '5.',
          text: '새어 나간 동안의 주문을 확인합니다. 증권사 앱의 주문·체결 내역을 앱의 일지와 맞춰 보고, 앱이 내지 않은 주문이 있으면 증권사 고객센터에 바로 알립니다.',
        ),
        RunbookStep(
          orderText: '6.',
          text: '모르는 주문 때문에 앱이 어긋남을 알리면, 증권사 확인이 끝날 때까지 해소하지 않고 막아 둔 채로 둡니다.',
        ),
        RunbookStep(
          orderText: '7.',
          text: '열쇠를 다 바꾸고 확인이 끝나면 킬스위치를 재개 절차(체크리스트와 대기 시간)로 끕니다.',
        ),
      ],
    ),
  ),
  const RunbookEntry(
    title: '오래 자리를 비우거나 크게 아플 때',
    summaryText: '가족이 종이 카드로 멈춥니다',
    deepLink: AppRoutes.opsEmergencyCard,
  ),
]);

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
/// 🔵 S02 «키가 새어 나갔을 때»(`leakRunbookLink`)가 쓴다 — 🆕 E11q-d1b `secret-leak` 원고로 선다.
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
