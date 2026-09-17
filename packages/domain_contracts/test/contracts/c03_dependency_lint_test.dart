// C-3 의존 규칙 lint — 01 §7 표 C-3 · §1-1 의존성 규칙 표 · 인벤토리 §9(🟡 부분).
//
// 정의: 「`ui_*` 의 pubspec·import 그래프 — `core_engine`·`decimal`·`sqflite`·
//        `supabase_flutter` 금지」. 잡는 것: 경계 규칙 ①② 우회.
// 🟡 import 그래프 전수는 `ui_*` 에 화면 코드가 생겨야 실효가 있다(스텁 3파일뿐).
//    **pubspec 파싱은 지금도 가능**하므로 그쪽을 여기서 고정한다.
// 🔵 저장소 루트의 `tool/check_boundaries.sh` 가 같은 검사를 셸에서 한 번 더 한다
//    (`melos run check:boundaries`). 두 곳에 있는 이유는 CI 와 테스트 러너가 서로를
//    대신하지 못하기 때문이고, **금지 목록은 01 §1-1 한 곳이 정본**이다.

import 'dart:io';

import 'package:test/test.dart';

import 'c00_support.dart';

/// 01 §1-1 — `domain_contracts` 의 허용 의존 4개.
const Set<String> _contractAllowedDeps = <String>{
  'decimal',
  'freezed_annotation',
  'json_annotation',
  'meta',
};

/// 01 §1-1 — `ui_*` 가 넣으면 안 되는 것(+ `check_boundaries.sh` 의 같은 목록).
const Set<String> _forbiddenForUi = <String>{
  'broker_gateway',
  'core_engine',
  'data_sync',
  'decimal',
  'dio',
  'http',
  'sqflite',
  'supabase',
  'supabase_flutter',
  'trading_runtime',
};

/// 01 §1-1 — 계약 패키지가 의존하면 안 되는 것.
const Set<String> _forbiddenForContracts = <String>{
  'broker_gateway',
  'core_engine',
  'data_sync',
  'flutter',
  'sqflite',
  'supabase',
  'supabase_flutter',
};

void main() {
  group('C-3 의존 규칙 (01 §7 · §1-1)', () {
    test('C-3 domain_contracts 의 dependencies 는 허용 4개가 전부다', () {
      final Map<String, List<String>> deps = pubspecDependencyNames(
        File('${packageRoot.path}/pubspec.yaml'),
      );
      expect(
        deps['dependencies']!.toSet(),
        _contractAllowedDeps,
        reason:
            '01 §1-1 의 허용 목록과 다르다. 여기에 flutter·core_engine·sqflite·'
            'supabase 를 넣는 순간 계약이 플랫폼에 묶이고 viewer 빌드가 깨진다.',
      );
      expect(
        deps['dependencies']!,
        orderedEquals(deps['dependencies']!.toList()..sort()),
        reason:
            'pubspec 의존은 알파벳 순이다(루트 sort_pub_dependencies + --fatal-infos).',
      );
    });

    test('C-3 domain_contracts 는 Flutter·엔진·DB 를 의존하지 않는다(순수 Dart)', () {
      final Map<String, List<String>> deps = pubspecDependencyNames(
        File('${packageRoot.path}/pubspec.yaml'),
      );
      final Set<String> all = <String>{
        ...deps['dependencies']!,
        // dev 쪽의 flutter_lints 는 규칙 YAML 만 담은 순수 Dart 패키지라 허용이다
        // (루트 analysis_options.yaml 머리 주석). `flutter` 자체와는 다르다.
        ...deps['dev_dependencies']!.where((String d) => d != 'flutter_lints'),
      };
      expect(
        all.intersection(_forbiddenForContracts),
        isEmpty,
        reason: '01 §1-1 — 계약은 순수 Dart 다.',
      );
    });

    test(
      'C-3 domain_contracts 의 lib/ 는 Flutter·dart:io·dart:ui 를 import 하지 않는다',
      () {
        final RegExp forbidden = RegExp(
          r"import\s+'(package:flutter[^']*|dart:io|dart:ui)'",
        );
        final List<String> offenders = <String>[];
        for (final File f in dartSourcesIn(libDir)) {
          // 🔴 주석만 지운다 — import 대상은 문자열 리터럴이라 지우면 안 된다.
          if (forbidden.hasMatch(stripComments(f.readAsStringSync()))) {
            offenders.add(shortPath(f));
          }
        }
        expect(
          offenders,
          isEmpty,
          reason:
              '계약 패키지가 Flutter·플랫폼 API 를 끌어왔다 — web viewer 빌드가 깨진다'
              '(01 §1-1 · 인벤토리 §8-5).',
        );
      },
    );

    test('C-3 ui_* 의 pubspec 에 금지 의존이 없다', () {
      // 🔴 대상은 01 §1-1 표의 `ui_*` 행이다. `apps/*` 는 **조립 층**이라 구현체
      //    (`data_sync`·`trading_runtime`)를 배선하는 것이 사양이며 같은 목록으로
      //    재지 않는다 — 대신 아래 viewer 규칙이 따로 있다.
      final List<String> offenders = <String>[];
      for (final String name in uiPackageNames) {
        offenders.addAll(
          _forbiddenIn(
            name,
            File('${repoRoot.path}/packages/$name/pubspec.yaml'),
          ),
        );
      }
      expect(
        offenders,
        isEmpty,
        reason: '🔴 `decimal` 이 없어야 화면이 금액 산술을 아예 할 수 없다(01 §1-1 · C-4).',
      );
    });

    test('C-3 viewer 앱은 엔진·브로커·런타임을 싣지 않는다', () {
      // 근거: apps/app_operator_android/pubspec.yaml 주석 —
      //   「trading_runtime 이 core_engine·broker_gateway 를 전이로 끌고 온다.
      //     viewer 에 들어가는 순간 브로커 키·주문 코드가 뷰어 바이너리에 컴파일된다.」
      const Set<String> forbiddenForViewer = <String>{
        'broker_gateway',
        'core_engine',
        'trading_runtime',
      };
      for (final String name in <String>['app_viewer_ios', 'app_viewer_web']) {
        final Map<String, List<String>> deps = pubspecDependencyNames(
          File('${repoRoot.path}/apps/$name/pubspec.yaml'),
        );
        expect(
          deps['dependencies']!.toSet().intersection(forbiddenForViewer),
          isEmpty,
          reason: '$name — viewer 타깃에 엔진이 들어갔다.',
        );
      }
    });

    test('C-3 ui_* 는 domain_contracts 를 의존한다(계약이 유일한 창구)', () {
      for (final String name in uiPackageNames) {
        final Map<String, List<String>> deps = pubspecDependencyNames(
          File('${repoRoot.path}/packages/$name/pubspec.yaml'),
        );
        expect(
          deps['dependencies'],
          contains('domain_contracts'),
          reason: '$name — 화면은 계약 패키지 하나로만 값을 받는다(01 §1-1).',
        );
      }
    });

    test('C-3 경계 검사 스크립트가 저장소에 있다', () {
      expect(
        File('${repoRoot.path}/tool/check_boundaries.sh').existsSync(),
        isTrue,
        reason: 'tool/check_boundaries.sh 가 없으면 CI 쪽 경계 검사가 통째로 빠진다.',
      );
    });

    test('C-3 ui_* 의 import 그래프 전수 — 허용 3패키지 + dart: 만 (01 §1-1)', () {
      // ✅ 2026-09-17(C4 R1) — ui_journal J-1 이 들어와 실효가 생겼다. 전이 의존은
      //    pubspec 검사(위)가 막고, 여기서는 «lib/ 가 실제로 import 하는 패키지»를 본다.
      //    🔴 `package:ui_journal/...` 자기 참조는 허용(상대 import 대신 쓴 경우).
      final List<String> offenders = <String>[];
      final RegExp importRe = RegExp(
        r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
        multiLine: true,
      );
      for (final String name in uiPackageNames) {
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        for (final File f in dartSourcesIn(lib)) {
          final String code = stripComments(f.readAsStringSync());
          for (final RegExpMatch m in importRe.allMatches(code)) {
            final String uri = m.group(1)!;
            if (uri.startsWith('dart:')) {
              continue;
            }
            if (!uri.startsWith('package:')) {
              continue; // 상대 import — 같은 패키지 안
            }
            final String pkg = uri
                .substring('package:'.length)
                .split('/')
                .first;
            const Set<String> allowed = <String>{
              'flutter',
              'flutter_riverpod',
              'domain_contracts',
            };
            if (pkg == name || allowed.contains(pkg)) {
              continue;
            }
            offenders.add('${shortPath(f)}: $uri');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'ui_* 는 flutter·flutter_riverpod·domain_contracts 만 import 한다(01 §1-1 · C-3).',
      );
    });
  });
}

List<String> _forbiddenIn(String label, File pubspec) {
  if (!pubspec.existsSync()) {
    return <String>['$label: pubspec.yaml 이 없다'];
  }
  final Map<String, List<String>> deps = pubspecDependencyNames(pubspec);
  final Set<String> named = <String>{
    ...deps['dependencies']!,
    ...deps['dev_dependencies']!,
  };
  return named
      .intersection(_forbiddenForUi)
      .map((String d) => '$label: $d')
      .toList();
}
