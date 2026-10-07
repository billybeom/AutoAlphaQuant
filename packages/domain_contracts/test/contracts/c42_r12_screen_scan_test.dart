// C-42 R12 화면 소스 스캔 — 01 §15-4 · §7 표 C-42(🆕 계약 v1.6 · 보강안 §4-2).
//
// 정의: 「R12 다섯 화면(`S7-6a`·`S7-6b`·`S7-6c`·`S7-7`·`S7-10`)이 **받은 글자를 받은 순서대로** 그리기만
//        한다 — 원값으로 포맷·비교·분기하지 않고, 남의 창구를 부르지 않고, 셸·시계·플랫폼을 건드리지 않는다」.
// 대상 = 역할 표(`support/r12_targets.dart` · 01 §15-4 «공개 위젯 · 파일 자리» 표와 같은 표) — 역할마다
//   공개 파일 1 + 내부 폴더 · 그리고 providers 파일의 R12 절(첫 `// ── 🆕 R12` 표식 줄부터 파일 끝).
// 소스는 `stripComments`(줄 끝·블록 주석까지 지우고 **문자열 리터럴은 남긴다** — ⑥ 의 `%`·⑦ 의 금액 꼴
//   문자열 검사에 필요)를 거친 뒤 본다. 원값 정규식은 모두 `(?<!Labels)\.` 꼴(라벨 상수 `AnalyticsLabels.total` 제외).
//   ① 역할 표 · 대상 0 = 공허 통과 · 역할별 대상 파일 수와 providers R12 절 줄 수를 출력한다(카드 0단계·C4 확인용).
//   ② 공통 원값 0 — 비중·밴드·임계 원값·`mode`·`kind`·`hasMore`·`emptyKind`·칩 `code`·`wire` · `TradeDate` 재포맷 ·
//      `.sleeve`(역할 전부 + providers R12 절).
//   ③ 역할별 원값 0 — S7-6c 초안·비용 원값 · `journalTimelineLink` = S7-6b 만 · `detailDeepLink` = S7-6a 만 ·
//      S7-7 사다리 원값·창 코드·연도 · S7-10 int 9종·범위·신뢰 등급.
//   ③' 패턴 분해로 읽는 원값 0(점이 없어 ②③ 이 못 잡는 길 · C-38 ⑩ 둘째 정규식 선례).
//   ④ 호출 역할 표 — 창구마다 부르는 역할이 하나다 · providers R12 절은 `previewRebalance` 0 ·
//      전 역할·절에서 비용·계획·입출금 시뮬·롤링·등급·사다리·운영 상태·명령·일지 범위 창구 0.
//   ⑤ 분기·셸·포맷 낱말 0(운영 모드·플랫폼·시계·Scaffold·숫자 포맷·플래너 import).
//   ⑥ 소수부가 0 이 아닌 소수 리터럴 0 + `%` 를 품은 문자열 0(구 C-30 ⓕ 의 R12 몫 · `N.0`·정수 레이아웃 상수 허용).
//   ⑦ S7-10 — `Money`·`Decimal`·`KrwAmount` 0 + 금액 꼴 문자열 0(구 C-25 ⑤ 의 S7-10 몫 · 결정 8 옆문).
//   ⑧ S7-6a·6b·6c — `SleeveId.` 0 + 비중 double·`.sleeve` 0(구 C-31 ⓓ 의 R12 몫 · `A + POT` 산술).
//   ⑨ 문자열 가공·정렬·거르기 0(받은 순서 그대로 · `.indexed`·`.map`·`.length` 는 허용).
//   ⑩ 가드 — `ui_analytics/lib` 에서 R12 전용 이름을 말하는 파일 ⊆ 역할 대상 ∪ providers R12 절(늘 실행).
//   ⑪ 자체 검증 — 양성은 걸리고(걸린 조항 번호 출력) 음성은 통과한다.
//   ⑫ 세후 유출 경로 가드 — `ui_analytics` 밖 `ui_*`·`apps` lib 에 세후 수치 필드 참조 0(늘 실행 · 결정 8 · K25).
//   ⑬ providers R12 절 — ②⑤⑨ + 기간·일자 타입 0 + 읽기 창구 인자 0 + `previewRebalance` 0 · 표식 위 본문은 R12
//      전용 이름을 말하지 않는다(표식이 없으면 파일 전체가 «표식 위»다).
// 🔴 대상 파일이 아직 없으면(R12a~d 전) ②~⑨·⑬ 의 절 검사는 통과한다 — 없는 파일로 실패시키지 않는다.
//    ⑩·⑫ 는 지금도 실대상을 본다.
// 🔴 구 skip 셋(C-25 ⑤ · C-30 ⓕ · C-31 ⓓ)은 지우지 않는다 — 제목을 «R12 밖»으로 좁혀 남은 할 일로 둔다.
//    여기서는 그 R12 몫만 가져온다(보강안 §4-3).
// 🔴 숫자(세후·운영 금액)를 이 파일에 적지 않는다 — 자체 검증 스니펫의 수치는 뜻 없는 자리표시자다.

import 'package:test/test.dart';

import 'c00_support.dart';
import 'support/r12_targets.dart';

// ─── 정규식 ──────────────────────────────────────────────────────────────────

/// ②③' 공통 금지 필드(② 의 원값 15종 + `tradeDate`·`sleeve`).
const List<String> _commonFields = <String>[
  'weight',
  'targetWeight',
  'bandLow',
  'bandHigh',
  'rawValues',
  'thresholdRegistered',
  'triggerPrice',
  'metricKey',
  'orderIntentIds',
  'mode',
  'kind',
  'hasMore',
  'emptyKind',
  'code',
  'wire',
  'tradeDate',
  'sleeve',
];

/// ② 공통 원값(`tradeDate`·`sleeve` 는 따로 — `tradeDate` 는 `.yyyyMmDd` 로만 읽는다).
final List<RegExp> _rawCommon = <RegExp>[
  RegExp(
    r'(?<!Labels)\.(weight|targetWeight|bandLow|bandHigh|rawValues|thresholdRegistered|'
    r'triggerPrice|metricKey|orderIntentIds|mode|kind|hasMore|emptyKind|code|wire)\b',
  ),
  RegExp(r'(?<!Labels)\.tradeDate\b(?!\.yyyyMmDd)'),
  RegExp(r'(?<!Labels)\.sleeve\b'),
];

/// ③ S7-6c 초안·비용 원값(`\b` 때문에 `quantityText`·`sideLabel`·`totalText`·`sourceLabel`·
/// `limitPriceText` 는 걸리지 않는다).
const List<String> _s76cFields = <String>[
  'planId',
  'plannedDate',
  'before',
  'after',
  'fundingSteps',
  'quantity',
  'limitPrice',
  'side',
  'commission',
  'tax',
  'total',
  'source',
  'expectedKind',
  'previewRoute',
  'detailDeepLink',
];

/// ③ S7-7 사다리 원값·창 코드·연도(`afterTax`·`afterTaxCounterfactual`·`yearLabel` 은 걸리지 않는다).
const List<String> _s77Fields = <String>[
  'stepCode',
  'cagrPct',
  'endMult',
  'branch',
  'isReferenceOnly',
  'configHash',
  'windowStateCode',
  'year',
];

/// ③ S7-10 int 9종·범위·신뢰 등급(`grade`·`level` 은 `TrustBadgeView` 안쪽 — widgets · 대상 밖 — 만 읽는다).
const List<String> _s710Fields = <String>[
  'issued',
  'filled',
  'partial',
  'skipped',
  'lapsed',
  'revoked',
  'lateFilled',
  'backdatedCount',
  'selfReportCorrectionCount',
  'range',
  'grade',
  'level',
  'lastVerifiedOn',
];

/// ③ 역할별 금지 필드 — `journalTimelineLink` 는 S7-6b 만 · `detailDeepLink` 는 S7-6a 만 읽는다.
List<String> _roleFields(R12Role role) => switch (role) {
  R12Role.s76a => const <String>['journalTimelineLink'],
  R12Role.s76b => const <String>['detailDeepLink'],
  R12Role.s76c => const <String>[..._s76cFields, 'journalTimelineLink'],
  R12Role.s77 => const <String>[
    ..._s77Fields,
    'journalTimelineLink',
    'detailDeepLink',
  ],
  R12Role.s710 => const <String>[
    ..._s710Fields,
    'journalTimelineLink',
    'detailDeepLink',
  ],
};

/// ③ 점 접근.
RegExp _fieldRef(List<String> fields) =>
    RegExp('(?<!Labels)\\.(${fields.join('|')})\\b');

/// ③' 패턴 분해 — `case OrderDraft(quantity: final q)` · `final RebalanceEvent(:mode) = e` ·
/// `case ListResult<RebalanceEvent>(:final emptyKind)`(타입 인자 허용).
const String _patternTypes =
    'RebalanceEvent|SleeveWeight|TriggerSnapshot|ListResult|NextRebalanceVm|'
    'RebalancePreviewResult|RebalancePreview|OrderDraft|CostEstimate|ReasonChip|'
    'AnnualReviewVm|AnnualReviewSection|AfterTaxLadder|AfterTaxStep|'
    'ExecutionGapResult|ExecutionGapReport|LedgerTrustBadge';

RegExp _fieldPattern(List<String> fields) => RegExp(
  '\\b($_patternTypes)\\s*(?:<[^()]*?>)?\\s*\\([^)]*\\b(${fields.join('|')})\\b',
);

/// ④ 창구 → 그 창구를 부르는 유일한 역할(역할 파일 기준 · 01 §15-4 호출 표).
final List<(R12Role, RegExp)> _roleCalls = <(R12Role, RegExp)>[
  (R12Role.s76c, RegExp('previewRebalance')),
  (R12Role.s76a, RegExp('watchEvents')),
  (R12Role.s76b, RegExp(r'watchEvent\b')),
  (R12Role.s76c, RegExp('watchNext')),
  (R12Role.s77, RegExp('annualReview')),
  (R12Role.s710, RegExp(r'\.monthly\(')),
];

/// ④ 전 역할·절에서 부르지 않는 창구(주입 이름 `analyticsCommandApiProvider` 까지 걸리게 `\b` 없이).
final RegExp _forbiddenCalls = RegExp(
  'estimateCosts|findPlan|simulateDeposit|simulateWithdrawal|watchRolling|'
  'watchGrade|afterTaxLadder|OpsStatusRepository|CommandApi|watchRebalanceScope',
);

/// ④⑬ providers R12 절 — 미리보기 결과는 State 다(프로바이더로 두지 않는다 · 규칙 5).
final RegExp _sectionPreview = RegExp(r'\bpreviewRebalance\b');

/// ⑤ 분기·셸·포맷 낱말.
final RegExp _branchWords = RegExp(
  r'operatingMode|OperatingMode|RunMode|runMode|FeatureFlags|kIsWeb|Platform\.|'
  r'DateTime\.now|Scaffold|AppBar|SafeArea|AppLinkSchemes|toStringAsFixed|'
  r'toStringAsPrecision|NumberFormat|package:ui_analytics/planner',
);

/// ⑥ 소수부가 0 이 아닌 소수 리터럴(`16.0`·`0.0`·`1.0`·정수는 통과).
final RegExp _decimalLiteral = RegExp(r'(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])');

/// ⑦ 금액 타입.
final RegExp _moneyType = RegExp(r'\b(Money|Decimal|KrwAmount)\b');

/// ⑦ 금액 꼴 문자열(C-25 `_moneyPattern` 과 같은 식 — 숫자에 붙은 «원/만원/억원» · 원화 기호).
final RegExp _moneyLiteral = RegExp(r'[0-9][0-9,.]*\s*(억원|만원|원)|₩');

/// ⑧ 슬리브 열거 접근 + 비중 double·`.sleeve`(② 와 겹친다 — ⑧ 은 S7-6a·6b·6c 의 몫을 따로 보인다).
final List<RegExp> _sleeveMath = <RegExp>[
  RegExp(r'SleeveId\.'),
  RegExp(r'(?<!Labels)\.(weight|targetWeight|bandLow|bandHigh|sleeve)\b'),
];

/// ⑨ 문자열 가공 · 정렬·거르기 · 역순 목록.
final List<RegExp> _reshape = <RegExp>[
  RegExp(
    r'(?<!Labels)\.(substring|split|replaceAll|replaceFirst|contains|startsWith|'
    r'endsWith|indexOf|padLeft|padRight)\(',
  ),
  RegExp(
    r'(?<!Labels)\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|'
    r'singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b',
  ),
  RegExp(r'\breverse:\s*true\b'),
];

/// ⑩ R12 전용 이름(공유 타입 `SleeveWeight`·`TriggerSnapshot`·`AfterTaxLadder`·`AfterTaxStep` 은 넣지 않는다 —
/// R12 밖 화면이 같은 이름을 쓴다 · v1.5 리뷰 F05).
final RegExp _r12Name = RegExp(
  r'\b(RebalancePreviewResult|RebalancePreview|NextRebalanceVm|RebalanceEvent|'
  r'AnnualReviewVm|AnnualReviewSection|ExecutionGapResult|ExecutionGapReport|'
  r'RebalanceRepository|ExecutionGapRepository)\b',
);

/// ⑫ 세후 수치 필드(`ui_analytics` 밖).
final RegExp _afterTaxField = RegExp(
  r'(?<!Labels)\.(afterTax|afterTaxCounterfactual|cagrPct|endMult)\b',
);

/// ⑬ providers R12 절 — 기간·일자 타입 · 인자를 받은 읽기 창구.
final RegExp _sectionDateWords = RegExp(r'\b(DateRange|TradeDate|DateTime)\b');
final RegExp _sectionArgCall = RegExp(
  r'\b(watchEvents|watchNext|annualReview)\(\s*[^)\s]',
);

// ─── 규칙 묶음 ────────────────────────────────────────────────────────────────

class _Rule {
  const _Rule(this.clause, this.re);
  final String clause;
  final RegExp re;
}

class _Hit {
  const _Hit(this.clause, this.text);
  final String clause;
  final String text;

  @override
  String toString() => '$clause «$text»';
}

List<_Rule> _buildRoleRules(R12Role role) {
  final List<String> fields = _roleFields(role);
  return <_Rule>[
    for (final RegExp re in _rawCommon) _Rule('②', re),
    _Rule('③', _fieldRef(fields)),
    _Rule("③'", _fieldPattern(<String>[..._commonFields, ...fields])),
    for (final (R12Role owner, RegExp re) in _roleCalls)
      if (owner != role) _Rule('④', re),
    _Rule('④', _forbiddenCalls),
    _Rule('⑤', _branchWords),
    _Rule('⑥', _decimalLiteral),
    if (role == R12Role.s710) _Rule('⑦', _moneyType),
    if (role == R12Role.s76a || role == R12Role.s76b || role == R12Role.s76c)
      for (final RegExp re in _sleeveMath) _Rule('⑧', re),
    for (final RegExp re in _reshape) _Rule('⑨', re),
  ];
}

final Map<R12Role, List<_Rule>> _roleRules = <R12Role, List<_Rule>>{
  for (final R12Role r in R12Role.values) r: _buildRoleRules(r),
};

/// providers R12 절 규칙(②④⑤⑨ + ⑬ 고유).
final List<_Rule> _sectionRules = <_Rule>[
  for (final RegExp re in _rawCommon) _Rule('②', re),
  _Rule('④', _sectionPreview),
  _Rule('④', _forbiddenCalls),
  _Rule('⑤', _branchWords),
  for (final RegExp re in _reshape) _Rule('⑨', re),
  _Rule('⑬', _sectionDateWords),
  _Rule('⑬', _sectionArgCall),
];

/// 역할 파일 한 벌의 위반(주석만 지운 소스 — 문자열 보간 안 참조까지 본다).
List<_Hit> _scanRole(R12Role role, String source) {
  final String code = stripComments(source);
  return <_Hit>[
    for (final _Rule r in _roleRules[role]!)
      for (final RegExpMatch m in r.re.allMatches(code))
        _Hit(r.clause, m.group(0)!),
    for (final String lit in _stringLiterals(code)) ...<_Hit>[
      if (lit.contains('%')) _Hit('⑥', lit),
      if (role == R12Role.s710 && _moneyLiteral.hasMatch(lit)) _Hit('⑦', lit),
    ],
  ];
}

/// providers R12 절의 위반.
List<_Hit> _scanSection(String section) {
  final String code = stripComments(section);
  return <_Hit>[
    for (final _Rule r in _sectionRules)
      for (final RegExpMatch m in r.re.allMatches(code))
        _Hit(r.clause, m.group(0)!),
  ];
}

/// ⑬ 표식 위 본문(표식이 없으면 파일 전체)이 말하는 R12 전용 이름.
List<String> _namesAboveMarker(String providersSource) => <String>[
  for (final RegExpMatch m in _r12Name.allMatches(
    stripComments(splitR12Providers(providersSource).above),
  ))
    m.group(0)!,
];

/// ⑩ 가드 — R12 전용 이름을 말하는데 역할 대상도 providers R12 절도 아닌 파일.
List<String> _r12MentionsOutside(Map<String, String> sources) => <String>[
  for (final MapEntry<String, String> e in sources.entries)
    if (r12RoleOf(e.key) == null &&
        (e.key == r12ProvidersFile
            ? _namesAboveMarker(e.value).isNotEmpty
            : _r12Name.hasMatch(stripComments(e.value))))
      e.key,
];

/// ⑫ 세후 수치 필드를 참조하는 파일.
List<String> _afterTaxLeaks(Map<String, String> sources) => <String>[
  for (final MapEntry<String, String> e in sources.entries)
    for (final RegExpMatch m in _afterTaxField.allMatches(
      stripComments(e.value),
    ))
      '${e.key}: ⑫ «${m.group(0)}»',
];

/// 주석을 지운 소스의 문자열 리터럴(따옴표 포함 · c00 `stripComments` 와 같은 토큰 규칙).
List<String> _stringLiterals(String code) {
  final List<String> out = <String>[];
  int i = 0;
  final int n = code.length;
  while (i < n) {
    final String c = code[i];
    if (c != "'" && c != '"') {
      i++;
      continue;
    }
    final bool triple = i + 2 < n && code[i + 1] == c && code[i + 2] == c;
    final String terminator = triple ? c * 3 : c;
    final int start = i;
    i += terminator.length;
    while (i < n) {
      if (code[i] == r'\') {
        i += 2;
        continue;
      }
      if (code.startsWith(terminator, i)) {
        i += terminator.length;
        break;
      }
      if (!triple && code[i] == '\n') {
        break;
      }
      i++;
    }
    out.add(code.substring(start, i > n ? n : i));
  }
  return out;
}

// ─── 실대상 ───────────────────────────────────────────────────────────────────

/// `ui_analytics/lib` 전 파일(한 번만 읽는다).
final Map<String, String> _lib = uiAnalyticsLibSources();

final Map<R12Role, Map<String, String>> _roleSources = r12RoleSources(_lib);

/// providers R12 절(표식이 없으면 null).
String? get _section => splitR12Providers(_lib[r12ProvidersFile] ?? '').section;

/// [clause] 의 실대상 위반 — 역할 파일 전부(+ [section] 이면 providers R12 절).
List<String> _violations(String clause, {bool section = false}) {
  final List<String> out = <String>[
    for (final MapEntry<R12Role, Map<String, String>> r in _roleSources.entries)
      for (final MapEntry<String, String> f in r.value.entries)
        for (final _Hit h in _scanRole(r.key, f.value))
          if (h.clause == clause) '${r.key.id} ${f.key}: $h',
  ];
  final String? s = _section;
  if (section && s != null) {
    for (final _Hit h in _scanSection(s)) {
      if (h.clause == clause) {
        out.add('providers R12 절: $h');
      }
    }
  }
  return out;
}

/// 출력(카드 0단계·C4 가 «대상 N파일»을 확인한다).
void _say(String line) {
  // ignore: avoid_print
  print(line);
}

// ─── ⑪ 자체 검증 스니펫 ──────────────────────────────────────────────────────

/// 양성 — (역할 · null = 역할 전부, 스니펫, 반드시 걸려야 하는 조항).
const List<(R12Role?, String, String)>
_positives = <(R12Role?, String, String)>[
  (R12Role.s76c, 'p.orderDrafts.first.quantity', '③'),
  (R12Role.s76b, 'w.weight', '②'),
  (R12Role.s77, 'ladder.cagrPct', '③'),
  (R12Role.s710, 'report.issued', '③'),
  (null, "Text('연 1.23%')", '⑥'),
  (null, r"Text('${v}%')", '⑥'),
  (null, 'const double k = 0.42;', '⑥'),
  (null, 'final t = DateTime.now();', '⑤'),
  (null, 'Scaffold(body: b)', '⑤'),
  (null, "import 'package:ui_analytics/planner.dart';", '⑤'),
  (R12Role.s76b, 'repo.watchEvents()', '④'),
  (R12Role.s76a, 'ref.read(analyticsCommandApiProvider)', '④'),
  (R12Role.s710, 'final d = Decimal.parse(x);', '⑦'),
  (R12Role.s710, "Text('1,000원')", '⑦'),
  (R12Role.s76c, 'case OrderDraft(quantity: final q):', "③'"),
  (R12Role.s76a, 'final RebalanceEvent(:mode) = e;', "③'"),
  (R12Role.s77, 'final AnnualReviewVm(:windowStateCode) = vm;', "③'"),
  (R12Role.s76a, 'case ListResult<RebalanceEvent>(:final emptyKind):', "③'"),
  (R12Role.s76a, 'rows.reversed', '⑨'),
  (R12Role.s76a, 'a.tradeDate.yyyyMmDd.compareTo(b.tradeDate.yyyyMmDd)', '⑨'),
  (null, 'ListView(reverse: true, children: c)', '⑨'),
  (R12Role.s710, 'report.trust.level', '③'),
  (R12Role.s76a, 'page.emptyKind', '②'),
  (R12Role.s76b, 'Text(ev.tradeDate.toString())', '②'),
  (R12Role.s76b, 'w.sleeve == SleeveId.pot', '⑧'),
  (R12Role.s76b, 'opener.open(chip.detailDeepLink!)', '③'),
  (R12Role.s76a, 'opener.open(e.journalTimelineLink!.deepLink)', '③'),
];

/// 음성 — (역할 · null = 역할 전부, 스니펫). 어느 조항에도 걸리지 않아야 한다.
const List<(R12Role?, String)> _negatives = <(R12Role?, String)>[
  (null, 'Text(d.quantityText)'),
  (null, 'Text(ev.tradeDate.yyyyMmDd)'),
  (R12Role.s77, 'final AfterTaxLadder? t = vm.afterTax;'),
  (R12Role.s77, 'final AfterTaxLadder? c = vm.afterTaxCounterfactual;'),
  (R12Role.s77, 'Text(vm.yearLabel)'),
  (R12Role.s76b, 'event.before.map((w) => Text(w.label))'),
  (R12Role.s76b, 'final RebalanceEvent(:before, :after) = e;'),
  (R12Role.s76b, 'opener.open(e.journalTimelineLink!.deepLink)'),
  (R12Role.s76a, 'opener.open(e.detailDeepLink!)'),
  (null, 'for (final (i, s) in vm.sections.indexed) {}'),
  (null, 'const EdgeInsets.all(16.0)'),
  (null, 'v.clamp(0.0, 1.0)'),
  (null, 'Card(child: c)'),
  (null, 'Text(AnalyticsLabels.total)'),
  (null, 'async.when(data: d, error: e, loading: l)'),
  (null, 'Text(w.label); // w.weight 는 읽지 않는다'),
  (null, '/* DateTime.now() 금지 */ const SizedBox(height: 12)'),
  (null, 'final ReasonChip(:label, :tone) = chip;'),
];

/// providers 자체 검증 본문 — 표식 위 = 기존 프로바이더 꼴 · 표식 아래 = R12 절.
const String _providersAbove =
    'final Provider<Clock> analyticsClockProvider = Provider<Clock>((ref) {\n'
    "  throw UnimplementedError('x');\n"
    '});\n';
const String _providersMarker = '// ── 🆕 R12a — S7-6a ──\n';
const String _providersGood =
    'final p = StreamProvider.autoDispose<ListResult<RebalanceEvent>>((ref) {\n'
    '  return ref.watch(rebalanceRepositoryProvider).watchEvents();\n'
    '});\n';

void main() {
  group('C-42 R12 화면 소스 스캔 (01 §15-4 · 계약 v1.6)', () {
    test('C-42 ① 역할 표 — 대상 파일 수와 providers R12 절 줄 수(대상 0 = 공허 통과)', () {
      expect(
        <String>[for (final R12Role r in R12Role.values) r.id],
        <String>['S7-6a', 'S7-6b', 'S7-6c', 'S7-7', 'S7-10'],
        reason: '역할 표 = 01 §15-4 «공개 위젯 · 파일 자리» 표의 다섯 행.',
      );
      for (final R12Role r in R12Role.values) {
        expect(r.publicFile, startsWith('lib/src/screens/'), reason: r.id);
        expect(r.publicFile, endsWith('_screen.dart'), reason: r.id);
        expect(r.internalDir, startsWith('lib/src/'), reason: r.id);
        expect(r.internalDir, endsWith('/'), reason: r.id);
        expect(r12RoleOf(r.publicFile), r, reason: r.id);
        expect(r12RoleOf('${r.internalDir}a/b.dart'), r, reason: r.id);
        for (final R12Role o in R12Role.values) {
          if (o != r) {
            expect(
              o.internalDir.startsWith(r.internalDir),
              isFalse,
              reason: '${o.id} 의 내부 폴더가 ${r.id} 의 폴더 안에 있다 — 역할이 겹친다.',
            );
          }
        }
      }
      // 대상 고르기 — 정확히 그 파일 · 그 폴더 아래만.
      for (final String rel in <String>[
        r12ProvidersFile,
        'lib/src/widgets/trust_badge_view.dart',
        'lib/src/rebalance/shared_row.dart',
        'lib/src/screens/rebalance_timeline_screen_body.dart',
        'lib/src/screens/monthly_report_screen.dart',
        'lib/ui_analytics.dart',
        'lib/l10n/labels.dart',
      ]) {
        expect(r12RoleOf(rel), isNull, reason: rel);
      }
      expect(
        _lib,
        isNotEmpty,
        reason: 'ui_analytics/lib 를 못 읽었다 — 경로가 낡았다(빈 입력은 늘 통과한다).',
      );
      expect(
        _lib.keys,
        contains(r12ProvidersFile),
        reason: 'providers 파일이 옮겨졌다 — ⑬ 이 공허 통과한다. 역할 표의 경로를 고친다.',
      );

      int total = 0;
      for (final R12Role r in R12Role.values) {
        final List<String> files = _roleSources[r]!.keys.toList()..sort();
        total += files.length;
        _say(
          'C-42 ① 대상 ${r.id}(${r.card}) ${files.length}파일 — '
          '${r.publicFile} + ${r.internalDir}**'
          '${files.isEmpty ? '' : '\n    ${files.join('\n    ')}'}',
        );
      }
      final int lines = splitR12Providers(_lib[r12ProvidersFile]!).sectionLines;
      _say(
        'C-42 ① 역할 대상 합 $total파일 · providers R12 절 $lines줄'
        '${lines == 0 ? '(표식 «$r12ProvidersMarker» 없음)' : ''}'
        '${total == 0 ? ' — ②~⑨ 공허 통과' : ''}',
      );
    });

    test('C-42 ② 공통 원값 0 — 비중·밴드·임계·mode·kind·emptyKind·code·TradeDate 재포맷', () {
      final List<String> bad = _violations('②', section: true);
      expect(
        bad,
        isEmpty,
        reason:
            'R12 화면은 엔진이 만든 `label`·`*Text` 만 그린다 — 비중 포맷·밴드 비교·`mode`/`kind`/`emptyKind`/칩 '
            '`code` 분기·`TradeDate` 재포맷은 하지 않는다(01 §15-4 · 보강안 §2-7).\n${bad.join('\n')}',
      );
    });

    test('C-42 ③ 역할별 원값 0', () {
      final List<String> bad = _violations('③');
      expect(
        bad,
        isEmpty,
        reason:
            'S7-6c 는 초안·비용 원값을 · S7-7 은 사다리 원값·창 코드·연도를 · S7-10 은 건수 int·범위·등급을 '
            '읽지 않는다 · `journalTimelineLink` = S7-6b 만 · `detailDeepLink` = S7-6a 만(보강안 §4-2 ③).'
            '\n${bad.join('\n')}',
      );
    });

    test("C-42 ③' 패턴 분해로 읽는 원값 0", () {
      final List<String> bad = _violations("③'");
      expect(
        bad,
        isEmpty,
        reason:
            '`case OrderDraft(quantity: …)`·`final RebalanceEvent(:mode) = e` 처럼 점 없이 원값을 읽어도 '
            '같은 위반이다(C-38 ⑩ 둘째 정규식 선례).\n${bad.join('\n')}',
      );
    });

    test('C-42 ④ 호출 역할 표 — 창구마다 부르는 역할은 하나', () {
      final List<String> bad = _violations('④', section: true);
      expect(
        bad,
        isEmpty,
        reason:
            '`watchEvents` = S7-6a · `watchEvent` = S7-6b · `watchNext`·`previewRebalance` = S7-6c · '
            '`annualReview` = S7-7 · `monthly` = S7-10 · providers R12 절은 `previewRebalance` 0 · '
            '비용·계획·입출금 시뮬·롤링·등급·사다리·운영 상태·명령·일지 범위 창구는 아무도 부르지 '
            '않는다(01 §15-4 호출 표).\n${bad.join('\n')}',
      );
    });

    test('C-42 ⑤ 분기·셸·포맷 낱말 0', () {
      final List<String> bad = _violations('⑤', section: true);
      expect(
        bad,
        isEmpty,
        reason:
            '운영 모드·플랫폼 분기 · 시계 직접 · Scaffold/AppBar(셸 소유) · 숫자 포맷 · 플래너 import 는 '
            'R12 화면에 없다 — 갈래는 엔진 글자와 주입 null 여부로만 정한다.\n${bad.join('\n')}',
      );
    });

    test('C-42 ⑥ 소수 리터럴·% 문자열 0 (구 C-30 ⓕ 의 R12 몫)', () {
      final List<String> bad = _violations('⑥');
      expect(
        bad,
        isEmpty,
        reason:
            '세후·이행률 수치와 단위는 엔진 글자로 온다 — 화면에 소수 리터럴(`N.0` 제외)·`%` 문자열을 '
            '적지 않는다(01 §2-6 · 결정 8).\n${bad.join('\n')}',
      );
    });

    test('C-42 ⑦ S7-10 금액 타입·금액 꼴 문자열 0 (구 C-25 ⑤ 의 S7-10 몫)', () {
      final List<String> bad = _violations('⑦');
      expect(
        bad,
        isEmpty,
        reason:
            '이행 갭은 bp·건수 글자로만 말한다 — 원화로 바꾸는 순간 결정 8 이 옆문으로 무너진다(C-25).'
            '\n${bad.join('\n')}',
      );
    });

    test('C-42 ⑧ S7-6a·6b·6c 슬리브 산술 0 (구 C-31 ⓓ 의 R12 몫)', () {
      final List<String> bad = _violations('⑧');
      expect(
        bad,
        isEmpty,
        reason:
            '슬리브 비중은 `SleeveWeight.label` 로만 그린다 — `SleeveId` 로 거르기·더하기(`A + POT`)·비중 '
            'double 산술은 하지 않는다(C-31).\n${bad.join('\n')}',
      );
    });

    test('C-42 ⑨ 문자열 가공·정렬·거르기 0 — 받은 순서 그대로', () {
      final List<String> bad = _violations('⑨', section: true);
      expect(
        bad,
        isEmpty,
        reason:
            '엔진 글자를 잘라 붙이거나 해석하지 않고, 목록을 다시 정렬·거르지 않는다(«거르기·정렬·세기도 '
            '판정» · `.indexed`·`.map`·`.length` 는 허용).\n${bad.join('\n')}',
      );
    });

    test('C-42 ⑩ 가드 — R12 전용 이름은 역할 대상과 providers R12 절에만', () {
      final List<String> bad = _r12MentionsOutside(_lib);
      expect(
        bad,
        isEmpty,
        reason:
            'R12 전용 DTO·창구(`RebalanceEvent`·`NextRebalanceVm`·`RebalancePreview(Result)`·'
            '`AnnualReviewVm`·`AnnualReviewSection`·`ExecutionGapResult`·`ExecutionGapReport`·'
            '`RebalanceRepository`·`ExecutionGapRepository`)를 말하는 `ui_analytics/lib` 파일은 역할 표의 '
            '대상과 providers 파일의 R12 절(첫 «$r12ProvidersMarker» 표식 아래)에만 둔다 — 밖에 두면 '
            '②~⑨ 가 그 파일을 보지 않는다.\n${bad.join('\n')}',
      );
    });

    test('C-42 ⑪ 자체 검증 — 양성은 걸리고 음성은 통과한다', () {
      // 양성(걸린 조항 번호를 출력한다).
      for (final (R12Role? role, String snippet, String clause) in _positives) {
        final List<R12Role> roles = role == null
            ? R12Role.values
            : <R12Role>[role];
        final Set<String> union = <String>{};
        for (final R12Role r in roles) {
          final Set<String> got = <String>{
            for (final _Hit h in _scanRole(r, snippet)) h.clause,
          };
          expect(
            got,
            contains(clause),
            reason: '양성 스니펫을 ${r.id} 에서 못 잡았다($clause): $snippet',
          );
          union.addAll(got);
        }
        _say(
          'C-42 ⑪ 양성 [${role?.id ?? '전 역할'}] $snippet → '
          '${(union.toList()..sort()).join('')}',
        );
      }
      // 음성.
      for (final (R12Role? role, String snippet) in _negatives) {
        final List<R12Role> roles = role == null
            ? R12Role.values
            : <R12Role>[role];
        for (final R12Role r in roles) {
          expect(
            _scanRole(r, snippet),
            isEmpty,
            reason: '음성 스니펫을 ${r.id} 에서 잘못 잡았다: $snippet',
          );
        }
      }
      // ⑥ 문자열 추출 — 주석 속 `%` 는 대상이 아니고 문자열 속 `%` 는 대상이다.
      expect(
        _stringLiterals(stripComments("// 10% 아님\nText('a%b');\n")),
        <String>["'a%b'"],
      );

      // ⑬ providers R12 절 — 표식 가르기 · 인자 없는 읽기 창구는 통과 · 인자 = 실패.
      final ({String above, String? section, int sectionLines}) none =
          splitR12Providers(_providersAbove);
      expect(none.section, isNull);
      expect(none.sectionLines, 0);
      final ({String above, String? section, int sectionLines}) split =
          splitR12Providers('$_providersAbove$_providersMarker$_providersGood');
      expect(split.sectionLines, 4);
      expect(split.above.contains('analyticsClockProvider'), isTrue);
      expect(_scanSection(split.section!), isEmpty);
      expect(
        _namesAboveMarker('$_providersAbove$_providersMarker$_providersGood'),
        isEmpty,
      );
      for (final (String body, String clause) in <(String, String)>[
        ('ref.watch(rebalanceRepositoryProvider).watchEvents(range: r)', '⑬'),
        ('repo.annualReview(year: y)', '⑬'),
        ('final DateRange r = x;', '⑬'),
        ('final x = await api.previewRebalance();', '④'),
        ('ref.watch(analyticsCommandApiProvider)', '④'),
        ('rows.where((e) => e.mode == m)', '⑨'),
        ('final now = DateTime.now();', '⑤'),
        ('page.hasMore', '②'),
      ]) {
        final Set<String> got = <String>{
          for (final _Hit h in _scanSection('$_providersMarker$body\n'))
            h.clause,
        };
        expect(got, contains(clause), reason: 'providers R12 절 양성: $body');
        _say(
          'C-42 ⑪ 양성 [providers R12 절] $body → '
          '${(got.toList()..sort()).join('')}',
        );
      }
      // 표식 위 본문의 R12 이름 = 실패 · 표식이 없는데 R12 이름 = 실패(⑩⑬).
      expect(
        _namesAboveMarker(
          '${_providersAbove}final r = Provider<RebalanceRepository>((ref) => '
          'throw UnimplementedError());\n$_providersMarker',
        ),
        <String>['RebalanceRepository'],
      );
      expect(_namesAboveMarker('void f(RebalanceEvent e) {}\n'), <String>[
        'RebalanceEvent',
      ]);
      _say('C-42 ⑪ 양성 [providers 표식 위] RebalanceEvent → ⑩⑬');

      // ⑩ 가드 — 대상 밖 경로만 걸린다(주석 속 언급 · 공유 타입은 통과).
      expect(
        _r12MentionsOutside(<String, String>{
          'lib/src/annual_review/a.dart': 'void f(AnnualReviewVm vm) {}\n',
          R12Role.s710.publicFile: 'void f(ExecutionGapResult r) {}\n',
          'lib/src/widgets/x.dart': 'void f(AnnualReviewVm vm) {}\n',
          'lib/src/screens/c.dart': '// RebalanceEvent 는 R12 만 말한다\n',
          'lib/src/screens/d.dart':
              'void f(SleeveWeight w, AfterTaxLadder l) {}\n',
          r12ProvidersFile: '$_providersAbove$_providersMarker$_providersGood',
        }),
        <String>['lib/src/widgets/x.dart'],
      );
      expect(
        _r12MentionsOutside(<String, String>{
          r12ProvidersFile: 'void f(RebalanceEvent e) {}\n',
        }),
        <String>[r12ProvidersFile],
      );

      // ⑫ 세후 유출 — `ui_analytics` 밖 화면의 세후 필드 참조만 걸린다.
      expect(
        _afterTaxLeaks(<String, String>{
          'packages/ui_settings/lib/a.dart': 'Text(vm.afterTax!.basisNote)\n',
          'packages/ui_shell/lib/b.dart':
              'final x = report.afterTaxCounterfactual;\n',
          'apps/app_viewer_web/lib/c.dart': 'final v = s.cagrPct;\n',
          'packages/ui_journal/lib/d.dart':
              '// vm.afterTax 는 읽지 않는다\nText(AnalyticsLabels.afterTax);\n'
              'Text(vm.afterTaxText);\n',
        }),
        hasLength(3),
      );
      _say('C-42 ⑪ 양성 [ui_settings] vm.afterTax → ⑫');
    });

    test('C-42 ⑫ 세후 유출 경로 가드 — ui_analytics 밖 화면·앱에 세후 수치 필드 0', () {
      final Map<String, String> sources = afterTaxGuardSources();
      expect(
        sources.keys.where((String p) => p.startsWith('packages/ui_journal/')),
        isNotEmpty,
        reason: 'ui_journal/lib 를 못 읽었다 — 경로가 낡았다(빈 입력은 늘 통과한다).',
      );
      expect(
        sources.keys.where(
          (String p) => p.startsWith('packages/ui_analytics/'),
        ),
        isEmpty,
      );
      _say('C-42 ⑫ 대상 ${sources.length}파일(ui_analytics 밖 ui_* lib + apps lib)');
      final List<String> bad = _afterTaxLeaks(sources);
      expect(
        bad,
        isEmpty,
        reason:
            '세후 수치(`afterTax`·`afterTaxCounterfactual`·`cagrPct`·`endMult`)는 `ui_analytics` 의 S7-1·S7-7 '
            '만 그린다 — 홈·설정·셸·앱이 같은 VM 을 받아도 세후 블록을 그리지 않는다(결정 8 · K25).'
            '\n${bad.join('\n')}',
      );
    });

    test('C-42 ⑬ providers R12 절 — 읽기 창구 인자 0 · previewRebalance 0 · 표식 위 R12 이름 0', () {
      final String providers = _lib[r12ProvidersFile]!;
      final List<String> above = _namesAboveMarker(providers);
      expect(
        above,
        isEmpty,
        reason:
            'R12 프로바이더는 providers 파일 끝의 «$r12ProvidersMarker» 표식 아래에만 더한다(규칙 3 «끝 절 '
            '더하기만») — 표식 위(또는 표식 없이) R12 이름을 말하면 ⑬ 스캔이 그 줄을 보지 않는다.'
            '\n${above.join('\n')}',
      );
      final String? section = _section;
      final List<String> bad = <String>[
        if (section != null)
          for (final _Hit h in _scanSection(section)) 'providers R12 절: $h',
      ];
      expect(
        bad,
        isEmpty,
        reason:
            'providers R12 절은 읽기 창구 5종(`watchEvents`·`watchEvent`·`watchNext`·`annualReview`·`monthly`)을 '
            '**인자 없이**(`watchEvent`·`monthly` 는 생성자 값 그대로) 부르기만 한다 — 기간·일자 타입·정렬·'
            '시계·`previewRebalance`(미리보기 결과는 State) 0(01 §15-4 호출 표).\n${bad.join('\n')}',
      );
    });
  });
}
