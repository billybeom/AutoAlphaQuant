// R12 화면 역할 표 — C-42 의 대상(🆕 계약 v1.6 · 01 §15-4 · 보강안 §2-5 · §4-2).
//
// 🔴 이 파일에는 **테스트가 없다**(`_test.dart` 접미가 없다). 여기 있는 것은 «어느 파일이 어느 화면
//    역할인가»(역할 표) · 파일 읽기 · providers 파일의 R12 절 자르기 · 계약 창구 메서드 이름 읽기뿐이다.
//    무엇을 금지하는가(정규식)와 통과/실패 판정은 C-42(`c42_r12_screen_scan_test.dart`)에 있다.
// 🔴 역할 표 = 01 §15-4 «공개 위젯 · 파일 자리» 표(보강안 §2-5)와 **같은 표**다 — 한쪽을 고치면 다른 쪽도
//    같은 커밋에서 고친다(한쪽만 바꾸면 C-42 가 옛 경로를 보고 공허 통과한다).
// 🔴 역할끼리 공유 위젯 파일을 두지 않는다(공유가 필요하면 역할 폴더마다 둔다 — 역할 표가 단순해야
//    거짓 양성이 없다). 재사용 위젯은 기존 `lib/src/widgets/**` 를 import 만 한다(대상 밖).
// 🔴 경로는 전부 `packages/ui_analytics` 기준 상대 경로(`/` 구분)다.

import 'dart:io';

import '../c00_support.dart';

/// R12 화면 역할(§2-5 표 한 행 = 한 값).
///
/// 대상 = [publicFile] 하나 + [internalDir] 아래 전부. 셸 배선(R13)·Bob 의 화면 코드는 이 자리에만 둔다.
enum R12Role {
  /// `S7-6a` 리밸런싱 회차 타임라인.
  s76a(
    id: 'S7-6a',
    widget: 'RebalanceTimelineScreen()',
    routes: <String>['rebalanceHistory'],
    publicFile: 'lib/src/screens/rebalance_timeline_screen.dart',
    internalDir: 'lib/src/rebalance/timeline/',
    card: 'R12a',
  ),

  /// `S7-6b` 리밸런싱 회차 상세(v1.5 위젯 이름).
  s76b(
    id: 'S7-6b',
    widget: 'RebalanceEventScreen({required String rebalanceEventId})',
    routes: <String>['rebalanceEvent'],
    publicFile: 'lib/src/screens/rebalance_event_screen.dart',
    internalDir: 'lib/src/rebalance/event/',
    card: 'R12a',
  ),

  /// `S7-6c` 다음 리밸런싱 예고 + 초안 미리보기.
  s76c(
    id: 'S7-6c',
    widget: 'RebalancePreviewScreen()',
    routes: <String>['rebalancePreview'],
    publicFile: 'lib/src/screens/rebalance_preview_screen.dart',
    internalDir: 'lib/src/rebalance/preview/',
    card: 'R12b',
  ),

  /// `S7-7` 연간 리뷰.
  s77(
    id: 'S7-7',
    widget: 'AnnualReviewScreen()',
    routes: <String>['reportAnnual'],
    publicFile: 'lib/src/screens/annual_review_screen.dart',
    internalDir: 'lib/src/annual_review/',
    card: 'R12c',
  ),

  /// `S7-10` 이행 갭(두 라우트 · 한 위젯).
  s710(
    id: 'S7-10',
    widget: 'ExecutionGapScreen({String? yyyyMm})',
    routes: <String>['ledgerExecutionGap', 'ledgerExecutionGapMonth'],
    publicFile: 'lib/src/screens/execution_gap_screen.dart',
    internalDir: 'lib/src/execution_gap/',
    card: 'R12d',
  );

  const R12Role({
    required this.id,
    required this.widget,
    required this.routes,
    required this.publicFile,
    required this.internalDir,
    required this.card,
  });

  /// 화면 번호(03 · 실패 메시지에 쓴다).
  final String id;

  /// 공개 위젯(생성자 = key + 셸 파라미터만 · 이름 = M2).
  final String widget;

  /// 셸이 이 위젯으로 배선하는 `AppRoutes` 상수 이름(설명용 — 이 파일은 상수를 참조하지 않는다).
  final List<String> routes;

  /// 공개 파일(배럴이 export 하는 것).
  final String publicFile;

  /// 내부 위젯 폴더(`/` 로 끝난다 · 아래 전부가 대상).
  final String internalDir;

  /// 짓는 카드.
  final String card;

  /// [rel] 이 이 역할의 대상인가.
  bool owns(String rel) => rel == publicFile || rel.startsWith(internalDir);
}

/// `packages/ui_analytics` (저장소 루트 기준).
const String r12PackagePath = 'packages/ui_analytics';

/// providers 파일 — R12 절(⑬)이 여기 끝에 붙는다(규칙 3 «끝 절 더하기만»).
const String r12ProvidersFile = 'lib/src/providers/analytics_providers.dart';

/// providers R12 절의 표식 머리 — 이 글자로 **시작하는** 첫 줄부터 파일 끝까지가 R12 절이다
/// (선례 `// ── 🆕 R10b — S7-2G ───` · `// ── 🆕 R11b — S7-9 ──` · R12a~d 표식도 이 머리로 시작한다).
const String r12ProvidersMarker = '// ── 🆕 R12';

/// [rel] 을 대상으로 갖는 역할(없으면 null).
R12Role? r12RoleOf(String rel) {
  for (final R12Role r in R12Role.values) {
    if (r.owns(rel)) {
      return r;
    }
  }
  return null;
}

/// `packages/ui_analytics/lib` 전 파일(`packages/ui_analytics` 기준 상대 경로 → 원문).
Map<String, String> uiAnalyticsLibSources() {
  final Directory root = Directory('${repoRoot.path}/$r12PackagePath');
  return <String, String>{
    for (final File f in dartSourcesIn(Directory('${root.path}/lib')))
      _relativeTo(root, f): f.readAsStringSync(),
  };
}

/// 역할별 대상 파일(역할 → 상대 경로 → 원문). 대상이 없는 역할은 빈 지도다(공허 통과).
Map<R12Role, Map<String, String>> r12RoleSources(
  Map<String, String> libSources,
) => <R12Role, Map<String, String>>{
  for (final R12Role r in R12Role.values)
    r: <String, String>{
      for (final MapEntry<String, String> e in libSources.entries)
        if (r.owns(e.key)) e.key: e.value,
    },
};

/// providers 파일을 R12 표식 줄에서 가른다.
///
/// [above] = 표식 위 본문(표식이 없으면 파일 전체) · [section] = 표식 줄부터 파일 끝(없으면 null) ·
/// [sectionLines] = 그 절의 줄 수(없으면 0).
({String above, String? section, int sectionLines}) splitR12Providers(
  String source,
) {
  final List<String> lines = source.split('\n');
  final int at = lines.indexWhere(
    (String l) => l.trimLeft().startsWith(r12ProvidersMarker),
  );
  if (at < 0) {
    return (above: source, section: null, sectionLines: 0);
  }
  final List<String> tail = lines.sublist(at);
  // 파일 끝 줄바꿈이 만드는 빈 꼬리 한 칸은 줄로 세지 않는다.
  final int count = tail.isNotEmpty && tail.last.isEmpty
      ? tail.length - 1
      : tail.length;
  return (
    above: lines.sublist(0, at).join('\n'),
    section: tail.join('\n'),
    sectionLines: count,
  );
}

/// ⑫ 대상 — `ui_analytics` 를 뺀 `packages/ui_*/lib` + `apps/*/lib`(저장소 기준 경로 → 원문).
Map<String, String> afterTaxGuardSources() {
  final List<Directory> dirs = <Directory>[
    for (final String p in uiPackageNames)
      if (p != 'ui_analytics') Directory('${repoRoot.path}/packages/$p/lib'),
    for (final String a in appNames) Directory('${repoRoot.path}/apps/$a/lib'),
  ];
  return <String, String>{
    for (final Directory d in dirs)
      for (final File f in dartSourcesIn(d)) shortPath(f): f.readAsStringSync(),
  };
}

/// ④⑬ 계약 창구 메서드 — `domain_contracts/lib/src` 의 `abstract interface class …Repository`·`…Api` 가
/// 선언한 메서드 이름 → 인터페이스 이름(소스에서 읽는다 · 창구가 늘면 따라 는다).
///
/// providers R12 절이 읽기 창구 5종 밖을 부르는지 볼 때 C-42 가 쓴다. `SettingsActions`·`DraftStore`·
/// `AppLinkOpener`·`Clock` 은 창구(리포지토리·API)가 아니라 넣지 않는다(`watch`·`load` 같은 이름이
/// `ref.watch` 와 겹친다).
Map<String, String> contractWindowMethods() {
  final RegExp head = RegExp(
    r'abstract\s+interface\s+class\s+(\w+(?:Repository|Api))\b[^{]*\{',
  );
  final RegExp methodName = RegExp(r'\b([a-z]\w*)\s*(?:<[^()]*?>)?\s*\(');
  final Map<String, String> out = <String, String>{};
  for (final File f in dartSourcesIn(Directory('${libDir.path}/src'))) {
    final String code = stripCommentsAndStrings(f.readAsStringSync());
    for (final RegExpMatch m in head.allMatches(code)) {
      for (final String statement in _topLevelStatements(code, m.end)) {
        final RegExpMatch? name = methodName.firstMatch(statement);
        if (name != null) {
          out[name.group(1)!] = m.group(1)!;
        }
      }
    }
  }
  return out;
}

/// [start](여는 `{` 바로 뒤)부터 짝 `}` 까지의 본문을 깊이 0 의 `;` 로 나눈 선언들.
List<String> _topLevelStatements(String code, int start) {
  final List<String> out = <String>[];
  final StringBuffer current = StringBuffer();
  int depth = 0;
  for (int i = start; i < code.length; i++) {
    final String c = code[i];
    if (c == '}' && depth == 0) {
      break;
    }
    if (c == '(' || c == '{' || c == '[') {
      depth++;
    } else if (c == ')' || c == '}' || c == ']') {
      depth--;
    }
    if (c == ';' && depth == 0) {
      out.add(current.toString());
      current.clear();
    } else {
      current.write(c);
    }
  }
  return out;
}

String _relativeTo(Directory root, File f) {
  final String base = root.path.replaceAll(r'\', '/');
  final String p = f.path.replaceAll(r'\', '/');
  return p.startsWith('$base/') ? p.substring(base.length + 1) : p;
}
