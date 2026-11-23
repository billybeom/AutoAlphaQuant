// M8 `B-01`·`B-02` 전략 핸드북 — 원고 번들 · 목차 · 쪽 VM 짓기(E11q-d1 · 설계 13 §8 · 06 M4-12 ① · 04 §8 ·
// 앱 01 §26 K13 · K14 · K16 · 표본 `m8/handbook_*`).
//
// 🔴 글자 = 표본 제안 문장 그대로(장 이름 · 슬리브 장 · 보관 장 «왜 없앴나» · 밴드 이탈 쪽 · 뒤처짐 · 없는 쪽 문장).
// 🔴 원고가 없는 장 = 목차 «준비 중»(`PREPARING` · 링크 0 — 04 §8 «본문을 대신 쓰지 마십시오») · 그 앵커로 열면 «준비 중» 쪽.
//    지금 원고 = 슬리브 B · 새틀라이트(보관) · 밴드 이탈 리밸런싱 셋(표본이 적은 쪽) — 나머지 장 = 원고 창 몫.
// 🔴 «현재 상태»(live) 블록 = 엔진이 읽은 값이 있을 때만 싣는다 — 값이 없으면 블록째 뺀다(지어내지 않는다) · 실린 블록이
//    있으면 쪽 `asOf` = 그 값의 기준(가장 이른 것 · 엔진 의무 — K20).
// 🔴 뒤처짐 판정(K14) = 엔진: 원고가 적힌 규칙 지문 ↔ 지금 규칙 지문(`p0sRuleFingerprint` — 사람 값 · SPEC 판 제외).
//    다르면 목차 · 원고 있는 쪽 머리에 표본 문장(숨김 · 닫기 0) · 보관 장 · 준비 중 · 없는 쪽 = 고지 없음(고칠 본문이 아니다).
// 🔴 앵커 별칭 해석 = 엔진(표본 목차 `handbook://sleeves/sleeve-b` → 쪽 `sleeve-b`) · 모르는 앵커 = 받은 앵커 그대로 + 표본 문장.
// 🔴 원천 = 이 번들 + 부르는 쪽이 준 설정 지문 · 규칙 지문(원장 0) — 온보딩 전에도 열린다(뷰어도 같은 번들 — 06 M4-12 ②).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppLinkSchemes,
        AsOf,
        HandbookBlock,
        HandbookEntry,
        HandbookEntryState,
        HandbookIndex,
        HandbookLiveValue,
        HandbookPage;

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

/// 블록 종류 코드(표본).
abstract final class HandbookBlockKinds {
  /// 문단.
  static const String paragraph = 'PARAGRAPH';

  /// «현재 상태».
  static const String live = 'LIVE';

  /// 주의.
  static const String caution = 'CAUTION';
}

/// 핸드북 원고 번들(표본 목차 · 쪽 글자 그대로 · 규칙 지문 = 이 판 `p0sRuleFingerprint()`).
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
          '금은 상한이 있습니다. 상한에 닿으면 신규 매수가 멈춥니다.',
          deepLink: 'handbook://rebalance/band',
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
