// M8 `B-01`·`B-02` 전략 핸드북 — 원고 번들 · 목차 · 쪽 VM 짓기(E11q-d1 · 설계 13 §8 · 06 M4-12 ① · 04 §8 ·
// 앱 01 §26 K13 · K14 · K16 · 표본 `m8/handbook_*`).
//
// 🔴 글자 = 표본 제안 문장 그대로(장 이름 · 슬리브 장 · 보관 장 «왜 없앴나» · 밴드 이탈 쪽 · 뒤처짐 · 없는 쪽 문장).
// 🔴 원고가 없는 장 = 목차 «준비 중»(`PREPARING` · 링크 0 — 04 §8 «본문을 대신 쓰지 마십시오») · 그 앵커로 열면 «준비 중» 쪽.
//    표본이 적은 쪽 = 슬리브 B · 새틀라이트(보관) · 밴드 이탈 리밸런싱 셋 · 🆕 E11q-d1b(R236) 원고 창 = ① 구조 · ② 묶음 ·
//    슬리브 A · C · ③ 매매 · ④ 안전장치 · ⑤ 용어(원천 = 06 00_SPEC · 03_알고리즘 · 04_안전장치 P0S 현행 · 발주자 확정본) ·
//    ⑥⑦⑧ = HB-1~HB-3 원고(06 §3-11) 전이라 «준비 중» 그대로.
// 🔴 원고 글자에 숫자 리터럴 0(04 §8 — 비중 · 기간 · 문턱 같은 수치는 엔진 설정 · «현재 상태» 값이 말한다).
// 🔴 «현재 상태»(live) 블록 = 엔진이 읽은 값이 있을 때만 싣는다 — 값이 없으면 블록째 뺀다(지어내지 않는다) · 실린 블록이
//    있으면 쪽 `asOf` = 그 값의 기준(가장 이른 것 · 엔진 의무 — K20) · 🆕 E11q-d1b 금 상한 값 = [goldCapLiveReadingOf].
// 🆕 E11q-d1b — 슬리브 B 주의 블록 = 표본 글자(«상한에 닿으면 신규 매수가 멈춥니다»)가 SAF-308(경고만 · 주문 무차단)과
//    달라 정정한 글(발주자 확정) — 표본 정정은 계약 창 몫.
// 🔴 뒤처짐 판정(K14) = 엔진: 원고가 적힌 규칙 지문 ↔ 지금 규칙 지문(`p0sRuleFingerprint` — 사람 값 · SPEC 판 제외).
//    다르면 목차 · 원고 있는 쪽 머리에 표본 문장(숨김 · 닫기 0) · 보관 장 · 준비 중 · 없는 쪽 = 고지 없음(고칠 본문이 아니다).
// 🔴 앵커 별칭 해석 = 엔진(표본 목차 `handbook://sleeves/sleeve-b` → 쪽 `sleeve-b`) · 모르는 앵커 = 받은 앵커 그대로 + 표본 문장.
// 🔴 원천 = 이 번들 + 부르는 쪽이 준 설정 지문 · 규칙 지문(원장 0) — 온보딩 전에도 열린다(뷰어도 같은 번들 — 06 M4-12 ②).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppLinkSchemes,
        AsOf,
        AsOfSource,
        HandbookBlock,
        HandbookEntry,
        HandbookEntryState,
        HandbookIndex,
        HandbookLiveValue,
        HandbookPage,
        TradeDate,
        UiLevel;

import 'p0s_warn.dart' show P0sExposure, P0sWarnConfig, judgeP0sDailyWarnings;

/// M8 핸드북 글자(표본 제안 문장 · 엔진 사유 문장).
abstract final class HandbookTexts {
  /// 목차 «준비 중»(표본).
  static const String preparing = '준비 중';

  /// 목차 «보관됨»(표본).
  static const String archived = '보관됨';

  /// 뒤처짐 고지(표본 `handbook_index_outdated` · `handbook_page_outdated`).
  static const String outdatedNotice =
      '설명이 규칙보다 뒤처졌습니다. 규칙이 바뀐 뒤 아직 고치지 않은 장이 있습니다 — 본문보다 지금 설정이 먼저입니다.';

  /// 모르는 앵커의 제목(표본 `handbook_page_missing`).
  static const String missingTitle = '핸드북';

  /// 모르는 앵커(표본 `handbook_page_missing`).
  static const String missingLabel = '이 장은 핸드북에 없습니다. 목차에서 다른 장을 고르십시오.';

  /// 🆕 목차에 있지만 원고가 아직 없는 장(엔진 사유 — 본문을 지어내지 않는다).
  static const String preparingLabel = '이 장은 아직 준비 중입니다. 목차에서 다른 장을 고르십시오.';
}

/// «현재 상태» 값 키(원고 블록 ↔ 엔진이 읽은 값).
abstract final class HandbookLiveKeys {
  /// 금 비중 ↔ 상한(슬리브 B 쪽).
  static const String goldCap = 'GOLD_CAP';
}

/// 목차 한 항목(원고 번들 · 차례 = 목록 차례).
class HandbookChapter {
  /// 만든다.
  const HandbookChapter({
    required this.anchor,
    required this.title,
    this.linkAnchor,
    this.archived = false,
    this.children = const <HandbookChapter>[],
  });

  /// 쪽 앵커.
  final String anchor;

  /// 장 이름.
  final String title;

  /// 탭 링크의 앵커(별칭 · null = [anchor]).
  final String? linkAnchor;

  /// 보관 장(목차 접힘 · «왜 없앴나» 한 단락).
  final bool archived;

  /// 하위 항목(차례 그대로).
  final List<HandbookChapter> children;
}

/// 원고 블록 한 개.
class HandbookManuscriptBlock {
  /// 만든다.
  const HandbookManuscriptBlock(
    this.kind,
    this.text, {
    this.deepLink,
    this.liveKey,
  });

  /// 블록 종류 코드(화면 = 모양만).
  final String kind;

  /// 글자.
  final String text;

  /// 링크(null = 없음).
  final String? deepLink;

  /// «현재 상태» 값 키(null = 일반 블록) — 값이 없으면 블록째 뺀다.
  final String? liveKey;
}

/// 원고 한 쪽.
class HandbookManuscriptPage {
  /// 만든다.
  const HandbookManuscriptPage({
    required this.anchor,
    required this.title,
    required this.blocks,
  });

  /// 앵커.
  final String anchor;

  /// 제목.
  final String title;

  /// 블록(차례 그대로).
  final List<HandbookManuscriptBlock> blocks;
}

/// 핸드북 원고 번들.
class HandbookManuscript {
  /// 만든다.
  const HandbookManuscript({
    required this.ruleFingerprint,
    required this.chapters,
    required this.pages,
    this.aliases = const <String, String>{},
  });

  /// 원고가 적힌 규칙 지문(`p0sRuleFingerprint` 꼴) — 지금 규칙 지문과 다르면 «뒤처짐».
  final String ruleFingerprint;

  /// 목차(차례 그대로).
  final List<HandbookChapter> chapters;

  /// 원고가 있는 쪽.
  final List<HandbookManuscriptPage> pages;

  /// 앵커 별칭 → 쪽 앵커.
  final Map<String, String> aliases;
}

/// 엔진이 읽은 «현재 상태» 값 한 개.
class HandbookLiveReading {
  /// 만든다.
  const HandbookLiveReading({required this.value, required this.asOf});

  /// 라벨 · 등급.
  final HandbookLiveValue value;

  /// 그 값의 기준.
  final AsOf asOf;
}

/// 🆕 E11q-d1b — «현재 상태» 값의 신선도(보유 화면과 같은 축 — 엔진 일 1회 배치).
const Duration kHandbookLiveStaleAfter = Duration(hours: 26);

/// 🆕 E11q-d1b — «현재 상태» 값이 오래됐을 때의 문장(표본 `handbook_page_sleeve_b` 그대로).
const String kHandbookLiveStaleLabel = '현재 상태 값이 오래됐습니다. 엔진이 다시 보내면 바뀝니다.';

String _livePct(double x) {
  final String s = (x * 100).toStringAsFixed(1);
  return '${s.endsWith('.0') ? s.substring(0, s.length - 2) : s}%';
}

/// 🆕 E11q-d1b — 슬리브 B «현재 상태»(금 상한) = SAF-308 총자산 금 비중 감시(04 §1 Level 3 v2.27 · v2.46).
///
/// 🔴 판정 = 일간 경고 단계와 같은 규칙([judgeP0sDailyWarnings] — 감시선 초과 = 엄격) · 🔴 경고만 — 주문을 막지 않는다
///    (SAF-308 = 모니터링 규칙 · 강제 매도 0). 값 = [closeDate] 종가 기준 노출([exposure]) · 감시선 = [config].
HandbookLiveReading goldCapLiveReadingOf({
  required P0sExposure exposure,
  required P0sWarnConfig config,
  required TradeDate closeDate,
  required DateTime nowUtc,
}) {
  final bool over = judgeP0sDailyWarnings(exposure, config).goldHigh;
  final String share = _livePct(exposure.goldSharePct);
  final String line = _livePct(config.goldTotalMonitorPct);
  return HandbookLiveReading(
    value: HandbookLiveValue(
      label: over
          ? '금 비중 $share — 감시선 $line를 넘었습니다. 알림만 하고 주문은 막지 않습니다.'
          : '금 비중 $share — 감시선 $line 안쪽입니다.',
      level: over ? UiLevel.watch : UiLevel.ok,
    ),
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: closeDate,
      source: AsOfSource.localSqlite,
      staleAfter: kHandbookLiveStaleAfter,
      label: '현재 상태 기준 ${closeDate.yyyyMmDd} 종가',
      staleLabel: kHandbookLiveStaleLabel,
    ),
  );
}

/// 블록 종류 코드(표본).
abstract final class HandbookBlockKinds {
  /// 문단.
  static const String paragraph = 'PARAGRAPH';

  /// «현재 상태».
  static const String live = 'LIVE';

  /// 주의.
  static const String caution = 'CAUTION';
}

/// 핸드북 원고 번들(표본 목차 · 쪽 글자 그대로 + 🆕 E11q-d1b 장 여섯 쪽 · 규칙 지문 = 이 판 `p0sRuleFingerprint()`).
const HandbookManuscript kHandbookManuscript = HandbookManuscript(
  ruleFingerprint: '35aaa3719a81591a',
  chapters: <HandbookChapter>[
    HandbookChapter(anchor: 'structure', title: '① 전략 구조'),
    HandbookChapter(
      anchor: 'sleeves',
      title: '② 슬리브별 편입 메커니즘',
      children: <HandbookChapter>[
        HandbookChapter(anchor: 'sleeve-a', title: '슬리브 A — 국내 지수 ETF'),
        HandbookChapter(
          anchor: 'sleeve-b',
          title: '슬리브 B — 해외 지수·금 ETF',
          linkAnchor: 'sleeves/sleeve-b',
        ),
        HandbookChapter(anchor: 'sleeve-c', title: '슬리브 C — 방어 자산'),
        HandbookChapter(
          anchor: 'satellite',
          title: '새틀라이트 — 지금은 쓰지 않음',
          archived: true,
        ),
      ],
    ),
    HandbookChapter(anchor: 'trading', title: '③ 매매 메커니즘'),
    HandbookChapter(anchor: 'safety', title: '④ 안전장치 설명'),
    HandbookChapter(anchor: 'glossary', title: '⑤ 용어 사전'),
    HandbookChapter(anchor: 'after-tax', title: '⑥ 세후 표기 규약'),
    HandbookChapter(anchor: 'rejected-ideas', title: '⑦ 기각 등록부'),
    HandbookChapter(anchor: 'rule-value', title: '⑧ 규칙의 가치와 기대치의 한계'),
  ],
  aliases: <String, String>{'sleeves/sleeve-b': 'sleeve-b'},
  pages: <HandbookManuscriptPage>[
    HandbookManuscriptPage(
      anchor: 'sleeve-b',
      title: '슬리브 B — 해외 지수·금 ETF',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 B 는 해외 지수와 금을 담습니다. 목표 비중은 엔진 설정에서 옵니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.live,
          '현재 상태 — 엔진이 지금 보고 있는 값입니다.',
          liveKey: HandbookLiveKeys.goldCap,
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          'SMA 신호가 편입을 정하고, 밴드를 벗어나면 리밸런싱이 걸립니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '금은 총자산에서 차지하는 비중을 따로 지켜봅니다. 감시선을 넘으면 알림만 하고, 매수를 멈추거나 팔지는 않습니다.',
          deepLink: 'handbook://safety',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '환헤지를 하지 않습니다. 원화 환산 결과에는 환율이 섞여 있습니다.',
        ),
      ],
    ),
    HandbookManuscriptPage(
      anchor: 'satellite',
      title: '새틀라이트 — 지금은 쓰지 않음',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '왜 없앴나 — 새틀라이트는 실측에서 수익을 보태지 못하고 위험과 규칙만 늘려 정본에서 뺐습니다. 이 장은 기록으로만 남깁니다.',
        ),
      ],
    ),
    HandbookManuscriptPage(
      anchor: 'rebalance/band',
      title: '밴드 이탈 리밸런싱',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '목표 비중에서 밴드만큼 벗어나면 리밸런싱이 걸립니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '밴드 폭은 엔진 설정이 정합니다. 이 장의 설명이 설정보다 늦을 수 있습니다.',
          deepLink: 'handbook://safety',
        ),
      ],
    ),
    // 🆕 E11q-d1b(R236) — 장 여섯 쪽(① 구조 · ② 묶음 · 슬리브 A · C · ③ 매매 · ④ 안전장치 · ⑤ 용어) — 발주자 확정본.
    HandbookManuscriptPage(
      anchor: 'structure',
      title: '① 전략 구조',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '이 시스템은 돈을 역할이 다른 세 칸(슬리브)으로 나눠 굴립니다. 슬리브 A 는 국내 주식 지수를 계절에 맞춰 사고팔고, 슬리브 B 는 해외 지수와 금을 추세에 따라 담고, 슬리브 C 는 국채와 금으로 버팀목을 맡습니다.',
          deepLink: 'handbook://sleeves',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '칸마다 몫(목표 비중)이 정해져 있고, 그 값은 엔진 설정에서 옵니다. 이 핸드북은 숫자를 적지 않습니다. 지금 값은 설정과 각 화면이 보여 줍니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 A 가 쉬는 철에는 그 돈을 놀리지 않고 슬리브 B 와 같은 방식으로 굴립니다. 이 몫을 POT 라고 부르며, 절세계좌에서만 주문합니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '모든 매매 판단은 정해진 규칙이 합니다. 사람이 끼어들면 그 사유가 일지에 남고, 확인할 수 없는 상황이면 거래하지 않습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '주문은 국내에 상장된 ETF 로만 냅니다. 해외 주식을 직접 사지 않고, 빚을 내거나 파생상품을 쓰지 않습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '새틀라이트(해외 주도주) 칸은 지금 쓰지 않습니다. 규칙은 기록으로만 남아 있습니다.',
          deepLink: 'handbook://satellite',
        ),
      ],
    ),
    HandbookManuscriptPage(
      anchor: 'sleeves',
      title: '② 슬리브별 편입 메커니즘',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브마다 언제 담고 언제 비우는지가 다릅니다. 이 장은 세 슬리브의 차이를 한눈에 보이고, 자세한 규칙은 각 장에 있습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 A — 달력이 정합니다. 가을 끝에 사서 봄 끝에 팝니다.',
          deepLink: 'handbook://sleeve-a',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 B — 추세가 정합니다. 달마다 한 번, 값이 최근 평균보다 위에 있는지를 봅니다.',
          deepLink: 'handbook://sleeves/sleeve-b',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 C — 늘 담아 둡니다. 국채와 금을 정해 둔 비율로 들고, 따로 쓸 곳이 정해지지 않은 돈도 여기로 모입니다.',
          deepLink: 'handbook://sleeve-c',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '새틀라이트 — 지금은 쓰지 않습니다. 기록으로만 남아 있습니다.',
          deepLink: 'handbook://satellite',
        ),
      ],
    ),
    HandbookManuscriptPage(
      anchor: 'sleeve-a',
      title: '슬리브 A — 국내 지수 ETF',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 A 는 코스닥 지수 ETF 하나를 계절에 맞춰 사고팝니다. 가을 끝에 사서 봄 끝에 파는 규칙이며, 이 철에 주가가 상대적으로 강했던 기록에 기댄 것입니다. 앞으로도 그렇다는 보장은 없습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '가을 끝에 들어갈지 판정합니다. 국내 시장의 추세 점수가 약하면 진입을 미루고, 다음 달 끝에 다시 봅니다. 미루는 데에는 끝이 있어서, 정해진 마지막 달에는 그대로 들어갑니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '들어갈 때는 며칠에 나눠 삽니다. 다 채우지 못한 몫은 마지막 날에 모아서 마저 삽니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '봄 끝에는 전부 팝니다. 늦게 들어갔어도 파는 날은 같습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '쉬는 철에는 그 돈을 POT 로 굴리고, 다시 들어가는 날 POT 를 비워 매수 재원으로 씁니다.',
          deepLink: 'handbook://sleeves/sleeve-b',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '하락 단계가 깊으면 진입 판정과 상관없이 새로 사지 않습니다.',
          deepLink: 'handbook://safety',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '판정 날을 놓치면 앱이 대신 정하지 않습니다. 건너뛸지, 줄여 들어갈지, 그대로 들어갈지를 사람이 정합니다. 파는 날을 놓치면 다시 판정한 뒤 자동으로 팝니다.',
        ),
      ],
    ),
    HandbookManuscriptPage(
      anchor: 'sleeve-c',
      title: '슬리브 C — 방어 자산',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 C 는 버팀목입니다. 미국 국채 ETF 와 금 ETF 를 정해 둔 비율로 담아, 주식이 흔들릴 때 전체가 덜 흔들리게 합니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '두 자산 모두 국내에 상장된 ETF 로 삽니다. 환헤지를 하지 않아 원화 환산 값에는 환율이 섞입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '따로 쓸 곳이 정해지지 않은 원화는 슬리브 C 로 들어가 국채와 금으로 나뉩니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '슬리브 C 안의 금에는 따로 상한이 있어, 상한을 넘는 몫은 금을 더 사지 않고 원화로 둡니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '이와 별개로 엔진은 총자산에서 금이 차지하는 비중을 매일 지켜봅니다. 감시선을 넘으면 알림만 하고 주문은 막지 않습니다.',
          deepLink: 'handbook://sleeves/sleeve-b',
        ),
      ],
    ),
    HandbookManuscriptPage(
      anchor: 'trading',
      title: '③ 매매 메커니즘',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '엔진은 하루 일과를 정해 둔 순서로 돕니다. 장이 열리기 전에 장부와 증권사 잔고를 맞춰 보고, 장중에 그날 낼 주문을 내고, 장이 끝난 뒤 체결을 확인하고 그날의 평가를 남깁니다. 장중에 시세를 지켜보며 사고파는 일은 없습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '큰 판단은 달마다 한 번입니다. 월말 종가로 슬리브 B 의 비율과 슬리브 C 의 재조정, 비중 되돌리기를 다음 거래일 아침에 판정하고 그날 냅니다. 슬리브 A 는 계절 판정 날에만 움직입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '주문을 내기 전에 엔진은 차례로 확인합니다. 이 폰에 주문 권한이 있는지, 킬스위치나 정지 단계나 차단 표시가 없는지, 한도 안인지를 봅니다. 하나라도 걸리면 그 주문은 내지 않습니다.',
          deepLink: 'handbook://safety',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '주문은 먼저 장부에 이 주문을 내겠다고 적고 저장한 다음에 증권사로 보냅니다. 그래서 중간에 폰이 꺼져도 같은 주문이 두 번 나가지 않습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '주문이 나갔는지 모르는 상태가 되면 다시 보내지 않습니다. 증권사 조회로 확인될 때까지 그 종목의 새 주문을 막습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '파는 주문을 먼저 내고 체결을 확인한 뒤, 남은 돈 안에서 사는 주문을 냅니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '그날 다 채워지지 않은 주문은 장이 끝나면 실효로 적고, 다음 거래일에 새 주문으로 넘깁니다. 넘기는 날 수에는 끝이 있고, 그래도 남은 차이는 다음 월말 판정에서 맞춥니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 B 의 몫이 목표에서 밴드만큼 벗어나면 벗어난 만큼을 자동으로 옮깁니다.',
          deepLink: 'handbook://rebalance/band',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '매달 넣는 돈은 목표보다 가장 모자란 슬리브부터 채웁니다. 납입만으로 비중 되돌리기가 걸리지는 않습니다.',
        ),
      ],
    ),
    HandbookManuscriptPage(
      anchor: 'safety',
      title: '④ 안전장치 설명',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '안전장치는 모르면 거래하지 않는다는 한 원칙에서 나옵니다. 확인할 수 없는 것이 있으면 엔진은 주문을 내지 않는 쪽을 고릅니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '하락 단계 — 전체 자산이 최고점에서 얼마나 내려왔는지에 따라 단계가 오릅니다. 깊은 단계에서는 슬리브 A 의 새 매수를 멈추고, 가장 깊은 정지 단계에서는 새 주문을 모두 멈춥니다. 가진 종목을 자동으로 팔지는 않습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '단계는 나빠질 때는 바로 오르고, 좋아질 때는 정해진 기간을 기다린 뒤 한 계단씩만 내려옵니다. 정지 단계는 저절로 풀리지 않고 사람이 결정해야 풀립니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '킬스위치 — 사람이 누르는 긴급 정지입니다. 누르면 확인 없이 새 주문을 바로 막고, 체결되지 않은 주문의 취소를 시도합니다. 다시 켜려면 체크리스트를 마치고 정해진 대기 시간이 지나야 합니다. 감정이 격한 순간에 끄고 켜기를 되풀이하지 않게 하려는 장치입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '대사 — 매일 장부와 증권사 잔고를 맞춰 봅니다. 다시 맞춰 봐도 어긋나면 모든 주문을 막고, 사람이 원인을 골라 기록해야 풀립니다. 엔진이 어긋남을 스스로 고치지 않습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '한도 — 하루 주문 수, 한 번에 내는 금액, 위험자산 비중 같은 한도를 넘는 주문은 내지 않습니다. 한도를 확인할 수 없을 때도 내지 않습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '감시선 — 방어 몫이 너무 적을 때, 총자산에서 금 비중이 높을 때, 한 해 금융소득이 과세 기준을 넘을 때는 넘은 첫날 알림을 보내지만 주문은 막지 않습니다. 채택한 성적에 이미 이런 때가 들어 있어서, 막으면 다른 전략이 됩니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '규칙과 다르게 움직였다면 일지를 써야 새 매수가 다시 열립니다. 일지를 채우면 저절로 풀립니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.caution,
          '폰을 쓸 수 없을 때는 가족이 종이 긴급 정지 카드로 멈출 수 있습니다. 카드는 런북 목록에서 엽니다.',
        ),
      ],
    ),
    HandbookManuscriptPage(
      anchor: 'glossary',
      title: '⑤ 용어 사전',
      blocks: <HandbookManuscriptBlock>[
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '슬리브 — 돈을 역할별로 나눈 칸입니다. A 는 계절, B 는 추세, C 는 방어를 맡습니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '목표 비중 — 슬리브마다 정해 둔 몫입니다. 값은 엔진 설정에서 옵니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          'POT — 슬리브 A 가 쉬는 철에 그 돈을 슬리브 B 방식으로 굴리는 작은 장부입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '이동평균(SMA) — 최근 몇 달의 월말 종가를 평균한 값입니다. 값이 이보다 위에 있으면 오르는 추세로 봅니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '트랜치 — 슬리브 B 의 돈을 세 몫으로 나눠, 몫마다 다른 기간의 이동평균으로 따로 판단하는 단위입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '국면 — 미국 시장 지표로 본 시장의 상태입니다. 강세·중립·약세로 나누고, 약세면 슬리브 B 를 줄입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '파킹 — 슬리브 B 에서 빠진 돈을 같은 연금계좌 안의 아주 짧은 채권 ETF 에 두는 것입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '밴드 — 목표 비중 둘레에 둔 허용 폭입니다. 이 폭을 벗어나야 비중 되돌리기가 걸립니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '진입 게이트 — 국내 추세가 약하면 슬리브 A 의 가을 진입을 미루는 관문입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '분할 매수 — 한 번에 다 사지 않고 며칠에 나눠 사는 것입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '실효와 이월 — 그날 다 채워지지 않은 주문을 그날로 끝내고, 다음 거래일에 새 주문으로 내는 것입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '결과 불명 — 주문이 증권사에 들어갔는지 모르는 상태입니다. 다시 보내지 않고 조회로 확인합니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '대사 — 앱의 장부와 증권사 잔고를 맞춰 보는 일입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '하락 단계(서킷브레이커) — 자산이 최고점에서 내려온 정도에 따라 매매를 줄이거나 멈추는 계단입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '킬스위치 — 사람이 누르는 긴급 정지입니다. 다시 켜려면 체크리스트와 대기 시간을 거칩니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '일지 — 사람이 규칙에 끼어든 이유를 남기는 기록입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '감시선 — 넘으면 알림만 하고 주문은 막지 않는 경고 기준입니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '모의 운영 — 실제 돈 대신 가상으로 주문해 보는 운영입니다. 실제 주문 전에 먼저 돌려 봅니다.',
        ),
        HandbookManuscriptBlock(
          HandbookBlockKinds.paragraph,
          '알림 등급 — 지금 바로 개입할 것, 오늘 안에 확인할 것, 기록만 하는 것의 세 단계입니다.',
        ),
      ],
    ),
  ],
);

String _handbookLink(String anchor) => '${AppLinkSchemes.handbook}://$anchor';

HandbookManuscriptPage? _pageOf(HandbookManuscript m, String anchor) {
  for (final HandbookManuscriptPage p in m.pages) {
    if (p.anchor == anchor) return p;
  }
  return null;
}

HandbookChapter? _chapterOf(List<HandbookChapter> cs, String anchor) {
  for (final HandbookChapter c in cs) {
    if (c.anchor == anchor) return c;
    final HandbookChapter? hit = _chapterOf(c.children, anchor);
    if (hit != null) return hit;
  }
  return null;
}

bool _outdated(HandbookManuscript m, String ruleFingerprint) =>
    ruleFingerprint != m.ruleFingerprint;

HandbookEntry _entryOf(HandbookManuscript m, HandbookChapter c, int order) {
  final String link = _handbookLink(c.linkAnchor ?? c.anchor);
  final List<HandbookEntry> children = <HandbookEntry>[
    for (final (int i, HandbookChapter k) in c.children.indexed)
      _entryOf(m, k, i + 1),
  ];
  if (c.archived) {
    return HandbookEntry(
      anchor: c.anchor,
      title: c.title,
      order: order,
      state: HandbookEntryState.archived,
      stateLabel: HandbookTexts.archived,
      deepLink: link,
      children: children,
    );
  }
  final bool ready = _pageOf(m, c.anchor) != null;
  return HandbookEntry(
    anchor: c.anchor,
    title: c.title,
    order: order,
    state: ready ? HandbookEntryState.ready : HandbookEntryState.preparing,
    stateLabel: ready ? null : HandbookTexts.preparing,
    deepLink: ready ? link : null,
    children: children,
  );
}

/// `B-01` 목차 — 원고 번들 차례 · [configHash] = 지금 설정 지문(없으면 빈 글자) · [ruleFingerprint] = 지금 규칙 지문.
HandbookIndex handbookIndexOf({
  required String configHash,
  required String ruleFingerprint,
  HandbookManuscript manuscript = kHandbookManuscript,
}) => HandbookIndex(
  entries: <HandbookEntry>[
    for (final (int i, HandbookChapter c) in manuscript.chapters.indexed)
      _entryOf(manuscript, c, i + 1),
  ],
  configHash: configHash,
  outdatedNotice: _outdated(manuscript, ruleFingerprint)
      ? HandbookTexts.outdatedNotice
      : null,
);

/// `B-02` 쪽 — [anchor] = `handbook://` 뒤 글자 전부(별칭 = 엔진이 푼다) · [live] = 엔진이 읽은 «현재 상태» 값(키 → 값).
HandbookPage handbookPageOf(
  String anchor, {
  required String configHash,
  required String ruleFingerprint,
  Map<String, HandbookLiveReading> live = const <String, HandbookLiveReading>{},
  HandbookManuscript manuscript = kHandbookManuscript,
}) {
  final String canonical = manuscript.aliases[anchor] ?? anchor;
  final HandbookChapter? chapter = _chapterOf(manuscript.chapters, canonical);
  final HandbookManuscriptPage? page = _pageOf(manuscript, canonical);
  if (page == null) {
    return HandbookPage(
      anchor: chapter == null ? anchor : canonical,
      title: chapter?.title ?? HandbookTexts.missingTitle,
      blocks: const <HandbookBlock>[],
      configHash: configHash,
      missingLabel: chapter == null
          ? HandbookTexts.missingLabel
          : HandbookTexts.preparingLabel,
    );
  }
  AsOf? asOf;
  final List<HandbookBlock> blocks = <HandbookBlock>[];
  for (final HandbookManuscriptBlock b in page.blocks) {
    final String? key = b.liveKey;
    if (key == null) {
      blocks.add(
        HandbookBlock(kind: b.kind, text: b.text, deepLink: b.deepLink),
      );
      continue;
    }
    final HandbookLiveReading? r = live[key];
    if (r == null) continue;
    blocks.add(
      HandbookBlock(
        kind: b.kind,
        text: b.text,
        deepLink: b.deepLink,
        live: r.value,
      ),
    );
    final AsOf? was = asOf;
    if (was == null || r.asOf.observedAt.isBefore(was.observedAt)) {
      asOf = r.asOf;
    }
  }
  final bool archived = chapter?.archived ?? false;
  return HandbookPage(
    anchor: canonical,
    title: page.title,
    blocks: List<HandbookBlock>.unmodifiable(blocks),
    configHash: configHash,
    outdatedNotice: !archived && _outdated(manuscript, ruleFingerprint)
        ? HandbookTexts.outdatedNotice
        : null,
    asOf: asOf,
  );
}
