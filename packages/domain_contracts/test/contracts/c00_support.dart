// 계약 회귀 테스트 공용 도우미 — 01 §7 · 인벤토리 §9(영역 F).
//
// 🔴 이 파일에는 **테스트가 없다**(`_test.dart` 접미가 없으므로 러너가 직접
//    실행하지 않는다). C-1~C-16 이 공유하는 «파일을 찾고 읽는» 일만 한다.
// 🔴 판정은 각 C-n 파일이 한다 — 여기서 「통과/실패」를 정하지 않는다.
// 🔴 `lib/` 는 순수 Dart 라 `dart:io` 를 쓸 수 없지만(01 §1-1) **테스트는 쓸 수
//    있다**. 픽스처 파일을 읽고 소스를 훑는 것이 계약 검사의 절반이다.

import 'dart:io';

/// `packages/domain_contracts` 디렉터리.
///
/// 🔴 절대 경로를 코드에 적지 않는다(01 §5) — 실행 위치에서 거슬러 올라가 찾는다.
/// `dart test`(패키지 루트) · `melos run test:dart`(패키지 루트) · 저장소 루트에서
/// 부른 경우 셋 다 같은 값을 준다.
final Directory packageRoot = _locatePackageRoot();

/// 저장소 루트(`packages/domain_contracts` → `packages` → 루트).
final Directory repoRoot = packageRoot.parent.parent;

/// `packages/domain_contracts/fixtures`.
final Directory fixturesDir = Directory('${packageRoot.path}/fixtures');

/// `packages/domain_contracts/lib`.
final Directory libDir = Directory('${packageRoot.path}/lib');

/// `packages/domain_contracts/ddl`.
final Directory ddlDir = Directory('${packageRoot.path}/ddl');

/// 화면 패키지 목록(01 §1-1 표의 `ui_*` 행). 🔴 `ui_safety` 도 화면이다.
const List<String> uiPackageNames = <String>[
  'ui_analytics',
  'ui_journal',
  'ui_safety',
  'ui_settings',
  'ui_shell',
];

/// 조립 앱 목록(`apps/`). 화면 코드를 담으면 `ui_*` 와 같은 규약을 진다.
const List<String> appNames = <String>[
  'app_operator_android',
  'app_viewer_ios',
  'app_viewer_web',
];

/// 픽스처 원문(UTF-8).
///
/// [relPath] 는 `FixturePaths` 의 값(`'m6/advice_12.json'`)을 그대로 넘긴다.
String readFixture(String relPath) =>
    File('${fixturesDir.path}/$relPath').readAsStringSync();

/// 픽스처 파일이 실제로 있는가.
bool fixtureExists(String relPath) =>
    File('${fixturesDir.path}/$relPath').existsSync();

/// `fixtures/` 아래의 모든 `.json` 을 [fixturesDir] 기준 상대 경로로 돌려준다.
///
/// 경로 구분자는 `/` 로 정규화한다 — `FixturePaths` 의 표기와 맞춘다.
List<String> allFixtureFilesOnDisk() {
  final List<String> out = <String>[];
  for (final FileSystemEntity e in fixturesDir.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.json')) {
      continue;
    }
    out.add(_relativeTo(fixturesDir, e.path));
  }
  out.sort();
  return out;
}

/// [dir] 아래의 손으로 쓴 Dart 소스(생성물 제외).
///
/// 🔴 `*.g.dart`·`*.freezed.dart` 는 우리가 쓴 코드가 아니므로 계약 검사 대상이
///    아니다(루트 `analysis_options.yaml` 의 exclude 와 같은 목록).
List<File> dartSourcesIn(Directory dir) {
  if (!dir.existsSync()) {
    return const <File>[];
  }
  final List<File> out = <File>[];
  for (final FileSystemEntity e in dir.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) {
      continue;
    }
    final String p = e.path.replaceAll(r'\', '/');
    if (p.endsWith('.g.dart') ||
        p.endsWith('.freezed.dart') ||
        p.endsWith('.mocks.dart') ||
        p.contains('/.dart_tool/') ||
        p.contains('/build/')) {
      continue;
    }
    out.add(e);
  }
  out.sort((File a, File b) => a.path.compareTo(b.path));
  return out;
}

/// `packageRoot` 기준 상대 경로(표시용 — 실패 메시지에 절대 경로를 싣지 않는다).
String shortPath(File f) => _relativeTo(repoRoot, f.path);

/// 주석과 문자열 리터럴을 지운 소스.
///
/// 🔴 계약 검사는 «코드가 무엇을 참조하는가»를 보는 것이라 **한국어 주석은 대상이
///    아니다**(주석은 문서 절 번호를 인용하라는 것이 규약이다 — 인벤토리 §0-3).
///    주석을 지우지 않으면 「`HoldingPnl` 을 참조하지 말라」는 주석 자체가 위반으로
///    잡힌다(경보 피로).
/// ⚠️ 완전한 파서가 아니다 — 문자열 보간 안의 코드도 문자열로 읽는다(과탐이 아니라
///    미탐 방향이며, 계약 타입 참조는 보간 안에 나오지 않는다).
String stripCommentsAndStrings(String source) {
  final StringBuffer out = StringBuffer();
  int i = 0;
  final int n = source.length;
  while (i < n) {
    final String c = source[i];
    final String next = i + 1 < n ? source[i + 1] : '';

    if (c == '/' && next == '/') {
      while (i < n && source[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '/' && next == '*') {
      i += 2;
      while (i < n &&
          !(source[i] == '*' && i + 1 < n && source[i + 1] == '/')) {
        i++;
      }
      i += 2;
      continue;
    }
    if (c == "'" || c == '"') {
      final bool triple = i + 2 < n && source[i + 1] == c && source[i + 2] == c;
      final String terminator = triple ? c * 3 : c;
      i += terminator.length;
      while (i < n) {
        if (source[i] == r'\') {
          i += 2;
          continue;
        }
        if (source.startsWith(terminator, i)) {
          i += terminator.length;
          break;
        }
        if (!triple && source[i] == '\n') {
          break;
        }
        i++;
      }
      // 문자열은 통째로 지운다 — 자리만 공백으로 남긴다.
      out.write(' ');
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

/// 주석만 지운 소스(문자열 리터럴은 남긴다).
///
/// 문자열 상수 목록을 파싱해야 하는 검사(C-5)가 쓴다.
String stripComments(String source) {
  final StringBuffer out = StringBuffer();
  int i = 0;
  final int n = source.length;
  while (i < n) {
    final String c = source[i];
    final String next = i + 1 < n ? source[i + 1] : '';
    if (c == '/' && next == '/') {
      while (i < n && source[i] != '\n') {
        i++;
      }
      out.write('\n');
      continue;
    }
    if (c == '/' && next == '*') {
      i += 2;
      while (i < n &&
          !(source[i] == '*' && i + 1 < n && source[i + 1] == '/')) {
        i++;
      }
      i += 2;
      continue;
    }
    if (c == "'" || c == '"') {
      final bool triple = i + 2 < n && source[i + 1] == c && source[i + 2] == c;
      final String terminator = triple ? c * 3 : c;
      final int start = i;
      i += terminator.length;
      while (i < n) {
        if (source[i] == r'\') {
          i += 2;
          continue;
        }
        if (source.startsWith(terminator, i)) {
          i += terminator.length;
          break;
        }
        if (!triple && source[i] == '\n') {
          break;
        }
        i++;
      }
      out.write(source.substring(start, i > n ? n : i));
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

/// pubspec 의 `dependencies:`·`dev_dependencies:` 블록에 적힌 **패키지 이름**.
///
/// 🔴 `yaml` 패키지를 의존에 더하지 않는다 — 계약 패키지의 허용 의존 목록(01 §1-1)을
///    검사하려고 그 목록을 늘리는 것은 앞뒤가 맞지 않는다. 그래서 줄 기반으로 읽는다.
/// 주석 줄(`#`)은 세지 않는다 — 「Q-D 확정 시 살릴 목록」처럼 **주석으로 적어 둔**
/// 의존은 아직 의존이 아니다.
Map<String, List<String>> pubspecDependencyNames(File pubspec) {
  final List<String> lines = pubspec.readAsLinesSync();
  final Map<String, List<String>> out = <String, List<String>>{
    'dependencies': <String>[],
    'dev_dependencies': <String>[],
  };
  String? section;
  for (final String raw in lines) {
    final String line = raw.replaceAll('\t', '  ');
    final String trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    if (!line.startsWith(' ')) {
      final String key = trimmed.split(':').first;
      section = out.containsKey(key) ? key : null;
      continue;
    }
    if (section == null) {
      continue;
    }
    // 의존 이름은 정확히 2칸 들여쓰기 + `이름:` 형태다.
    final RegExpMatch? m = RegExp(r'^  ([a-z_][a-z0-9_]*):').firstMatch(line);
    if (m != null) {
      out[section]!.add(m.group(1)!);
    }
  }
  return out;
}

/// SQL 파일의 `CHECK (컬럼 IN ('A','B'))` 를 컬럼 → 허용값 목록으로 모은다.
///
/// 같은 컬럼 이름이 여러 표에 나오면 **목록에 여러 항목**으로 남긴다 —
/// 「어느 표의 CHECK 인가」가 C-15 의 판정에 필요하기 때문이다.
List<CheckConstraint> parseCheckConstraints(File sql) =>
    parseCheckConstraintsText(
      sql.readAsStringSync(),
      sql.uri.pathSegments.last,
    );

/// [parseCheckConstraints] 의 문자열판 — `ledgerDdlFor` 로 만든 SIM 판을 읽을 때 쓴다.
///
/// 🆕 v1.9 — `CHECK (col = 'A')`(1값 꼴 · 파일별 `mode` CHECK)도 읽는다.
List<CheckConstraint> parseCheckConstraintsText(String sql, String file) {
  // 🔴 SQL 줄주석을 먼저 지운다 — 주석 안의 따옴표·괄호가 값 목록을 끊는다
  //    (batch_d 의 `check (kind in (…  -- (`manualFillRecord` ↔ 'RECORD_MANUAL_FILL')`).
  final String text = sql
      .split('\n')
      .map((String line) => line.replaceAll(RegExp('--.*'), ''))
      .join('\n');
  final List<CheckConstraint> out = <CheckConstraint>[];
  final RegExp inList = RegExp(
    r'CHECK\s*\(\s*([A-Za-z_0-9]+)\s+IN\s*\(([^)]*)\)',
    caseSensitive: false,
  );
  final RegExp equals = RegExp(
    r"CHECK\s*\(\s*([A-Za-z_0-9]+)\s*=\s*'([^']*)'",
    caseSensitive: false,
  );
  for (final RegExpMatch m in inList.allMatches(text)) {
    out.add(
      CheckConstraint(
        file: file,
        table: _enclosingTable(text, m.start),
        column: m.group(1)!,
        values: RegExp("'([^']*)'")
            .allMatches(m.group(2)!)
            .map((RegExpMatch v) => v.group(1)!)
            .toList(),
      ),
    );
  }
  for (final RegExpMatch m in equals.allMatches(text)) {
    out.add(
      CheckConstraint(
        file: file,
        table: _enclosingTable(text, m.start),
        column: m.group(1)!,
        values: <String>[m.group(2)!],
      ),
    );
  }
  return out;
}

/// `CHECK (col IN (...))` 또는 `CHECK (col = '…')` 하나.
class CheckConstraint {
  const CheckConstraint({
    required this.file,
    required this.table,
    required this.column,
    required this.values,
  });

  /// 배치 파일 이름(`batch_a_decision_mode.sql`).
  final String file;

  /// 이 CHECK 가 달린 표(찾지 못하면 `'?'`).
  final String table;

  final String column;
  final List<String> values;

  @override
  String toString() => '$file:$table.$column ${values.toList()}';
}

String _enclosingTable(String sql, int offset) {
  final RegExp re = RegExp(
    r'(?:CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?|ALTER\s+TABLE)\s+([A-Za-z_0-9."]+)',
    caseSensitive: false,
  );
  String table = '?';
  for (final RegExpMatch m in re.allMatches(sql)) {
    if (m.start > offset) {
      break;
    }
    table = m.group(1)!.replaceAll('"', '');
  }
  return table;
}

/// JSON 트리를 훑으며 `(키 경로, 값)` 을 모두 넘긴다.
///
/// 리스트 원소의 키 경로는 `rows[0].price` 처럼 인덱스를 포함한다.
void walkJson(
  Object? node,
  void Function(String path, String key, Object? value) visit, {
  String path = '',
}) {
  if (node is Map<String, Object?>) {
    for (final MapEntry<String, Object?> e in node.entries) {
      final String childPath = path.isEmpty ? e.key : '$path.${e.key}';
      visit(childPath, e.key, e.value);
      walkJson(e.value, visit, path: childPath);
    }
  } else if (node is List<Object?>) {
    for (int i = 0; i < node.length; i++) {
      walkJson(node[i], visit, path: '$path[$i]');
    }
  }
}

String _relativeTo(Directory base, String path) {
  final String b = base.path.replaceAll(r'\', '/');
  final String p = path.replaceAll(r'\', '/');
  return p.startsWith('$b/') ? p.substring(b.length + 1) : p;
}

Directory _locatePackageRoot() {
  Directory dir = Directory.current;
  for (int i = 0; i < 12; i++) {
    if (_isPackageRoot(dir)) {
      return dir;
    }
    final Directory nested = Directory('${dir.path}/packages/domain_contracts');
    if (_isPackageRoot(nested)) {
      return nested;
    }
    final Directory parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }
  throw StateError(
    'domain_contracts 패키지 루트를 찾지 못했다(실행 위치: ${Directory.current.path}). '
    '`cd packages/domain_contracts && dart test` 또는 `melos run test:dart` 로 실행한다.',
  );
}

bool _isPackageRoot(Directory d) {
  final File p = File('${d.path}/pubspec.yaml');
  if (!p.existsSync()) {
    return false;
  }
  return p.readAsStringSync().contains('name: domain_contracts');
}
