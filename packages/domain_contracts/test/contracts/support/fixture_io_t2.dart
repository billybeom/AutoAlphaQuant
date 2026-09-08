// 계약 회귀 테스트 T2(01 §7 C-17~C-31 · 픽스처 규약)의 파일 읽기 보조.
//
// 🔴 `lib/src/fixtures/fixture_loader.dart` 는 순수 Dart 라 **파일을 읽지 않는다**
//    (01 §5 · 인벤토리 §8-5) — 「문자열 → DTO」까지가 그 파일의 일이고, 디스크에서
//    문자열을 가져오는 것은 호출자인 테스트의 일이다. 그 자리가 여기다.
// 🔴 이 파일은 판정하지 않는다 — 「어느 값이 맞는가」는 전부 각 C-n 테스트에 있다.
//
// ⚠️ 이름 끝의 `_t2` — 같은 창에서 C-1~C-16 조가 같은 성격의 보조 파일을 만들 수
//    있어 경로 충돌을 피한 것이다. 통합 단계에서 둘이 같으면 한쪽으로 합친다.

import 'dart:convert';
import 'dart:io';

/// 픽스처 파일 1건의 원문(UTF-8).
///
/// [relative] 는 `FixturePaths` 상수 그대로다(`'m6/advice_12.json'`).
String fixtureText(String relative) {
  final File file = File('${fixturesDir().path}/$relative');
  if (!file.existsSync()) {
    throw StateError('픽스처가 없다: ${file.path}');
  }
  return file.readAsStringSync();
}

/// 픽스처 1건을 JSON 객체로 읽는다.
Map<String, Object?> fixtureJson(String relative) {
  final Object? decoded = jsonDecode(fixtureText(relative));
  if (decoded is! Map<String, Object?>) {
    throw StateError('픽스처 최상위가 객체가 아니다: $relative');
  }
  return decoded;
}

/// 봉투의 `rows` 배열.
List<Map<String, Object?>> fixtureRows(String relative) {
  final Object? rows = fixtureJson(relative)['rows'];
  if (rows is! List) {
    throw StateError('픽스처에 rows 배열이 없다: $relative');
  }
  return rows.cast<Map<String, Object?>>();
}

/// `fixtures/` 디렉터리.
Directory fixturesDir() => Directory('${_packageRoot().path}/fixtures');

/// 디스크에 실재하는 픽스처의 상대 경로 전량(정렬).
///
/// 🔴 `FixturePaths.all` 과의 대조가 이 목록의 쓰임이다 — 목록에 없는 파일이
///    생기면 C-14·C-15 스캔이 그 파일을 **건너뛴 채** 통과한다.
List<String> fixtureFilesOnDisk() {
  final Directory root = fixturesDir();
  final int prefix = root.path.length + 1;
  final List<String> found = <String>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.json')) {
      found.add(entity.path.substring(prefix).replaceAll(r'\', '/'));
    }
  }
  found.sort();
  return found;
}

/// JSON 트리 안의 문자열을 경로와 함께 모은다.
///
/// 경로 표기는 `rows[3].reasons[0].label` 꼴이다 — 실패 메시지가 어느 칸인지
/// 말하지 못하면 테스트가 「어딘가 틀렸다」밖에 알려 주지 못한다.
List<({String path, String value})> collectStrings(
  Object? node, {
  String path = '',
}) {
  final List<({String path, String value})> found =
      <({String path, String value})>[];
  if (node is String) {
    found.add((path: path, value: node));
  } else if (node is Map<String, Object?>) {
    node.forEach((String key, Object? value) {
      found.addAll(
        collectStrings(value, path: path.isEmpty ? key : '$path.$key'),
      );
    });
  } else if (node is List) {
    for (int i = 0; i < node.length; i++) {
      found.addAll(collectStrings(node[i], path: '$path[$i]'));
    }
  }
  return found;
}

/// 봉투에서 `meta` 를 뺀 부분 — 화면이 실제로 그리는 값만 훑을 때 쓴다.
Map<String, Object?> withoutMeta(Map<String, Object?> envelope) {
  final Map<String, Object?> copy = Map<String, Object?>.of(envelope);
  copy.remove('meta');
  return copy;
}

Directory _packageRoot() {
  Directory dir = Directory.current;
  for (int i = 0; i < 8; i++) {
    if (_looksLikePackage(dir)) {
      return dir;
    }
    final Directory parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }
  // 저장소 루트에서 돌린 경우의 마지막 시도.
  final Directory nested = Directory(
    '${Directory.current.path}/packages/domain_contracts',
  );
  if (_looksLikePackage(nested)) {
    return nested;
  }
  throw StateError(
    'domain_contracts 패키지 루트를 찾지 못했다(현재: ${Directory.current.path}).',
  );
}

bool _looksLikePackage(Directory dir) =>
    File('${dir.path}/pubspec.yaml').existsSync() &&
    Directory('${dir.path}/fixtures').existsSync();
