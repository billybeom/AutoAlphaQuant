// C-7 안전 화면 소유권 — 01 §7 표 C-7 · 인벤토리 §9(🟡 부분).
//
// 정의: 「`ui_*`(`ui_safety` 제외)에 ① `killSwitch`·`releaseProgress`·`ResumeReport`
//   **원본** 렌더 ② 플래그 해제·게이트 통과·재개·정정 성격의 **조작 위젯**
//   ③ `CommandApi`·`SettingsActions` 밖의 쓰기 호출이 있으면 실패.
//   §2-10 표의 ✅ 항목(배너·읽기 목록·딥링크)은 통과」.
//
// 🟡 위젯 검사는 `ui_*` 선행이다. 지금 고정할 수 있는 것은 **경계의 뼈대**다 —
//    ① 소유 경로가 CODEOWNERS 에 파일 경로로 적혀 있고(07 §9 기계 검사 3)
//    ② 리포지토리에 쓰기 메서드가 하나도 없으며(01 §4-1)
//    ③ 쓰기 창구가 `CommandApi`·`SettingsActions` 둘뿐이다(01 §4-2·§4-3).

import 'dart:io';

import 'package:test/test.dart';

import 'c00_support.dart';

/// 01 §7 C-7 이 이름으로 지목한 «원본» 필드·타입.
const List<String> _safetyOwnedSymbols = <String>[
  'killSwitch',
  'releaseProgress',
  'ResumeReport',
];

/// CODEOWNERS 에 **파일 경로로** 적혀 있어야 하는 Claude 소유 경로(07 §9 기계 검사 3).
const List<String> _claudeOwnedPaths = <String>[
  '/packages/domain_contracts/',
  '/packages/core_engine/',
  '/packages/broker_gateway/',
  '/packages/trading_runtime/',
  '/packages/data_sync/',
  '/packages/ui_safety/',
];

/// 쓰기로 읽히는 메서드 이름 접두(01 §1-4).
final RegExp _writeVerb = RegExp(
  r'\b(save|write|submit|send|insert|update|delete|apply|commit)[A-Z_]',
);

void main() {
  group('C-7 안전 화면 소유권 (01 §7)', () {
    test('C-7 CODEOWNERS 가 있고 소유 경로 6개를 파일 경로로 적고 있다', () {
      final File codeowners = File('${repoRoot.path}/CODEOWNERS');
      expect(
        codeowners.existsSync(),
        isTrue,
        reason:
            '「소유 경계」는 검수 대화의 주제가 아니라 파일 경로여야 한다'
            '(00_README §5 경계 규칙 ③ · 07 §9).',
      );
      final String text = codeowners.readAsStringSync();
      for (final String path in _claudeOwnedPaths) {
        expect(
          text.contains(path),
          isTrue,
          reason: 'CODEOWNERS 에 $path 행이 없다 — 그 경로의 변경이 리뷰어 지정 없이 지나간다.',
        );
      }
    });

    test('C-7 ui_safety 패키지가 실재한다(C-7 이 전제하는 경로)', () {
      // ✅ 01 §7 각주 — 「C-7 이 전제하던 `ui_safety` 패키지는 2026-09-06 에 신설로
      //    확정됐다」. 경로가 없으면 「ui_safety 제외」라는 예외가 공허해진다.
      expect(
        Directory('${repoRoot.path}/packages/ui_safety').existsSync(),
        isTrue,
      );
      expect(
        File('${repoRoot.path}/packages/ui_safety/pubspec.yaml').existsSync(),
        isTrue,
      );
    });

    test('C-7 계약의 읽기 리포지토리에 쓰기 메서드가 0건이다', () {
      final List<String> offenders = <String>[];
      for (final File f in dartSourcesIn(
        Directory('${libDir.path}/src/repositories'),
      )) {
        final String code = stripCommentsAndStrings(f.readAsStringSync());
        for (final RegExpMatch m in _writeVerb.allMatches(code)) {
          offenders.add('${shortPath(f)}: ${m.group(0)}');
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '리포지토리는 읽기 전용이다 — 쓰기는 §4-2 명령 API 인터페이스뿐이고 '
            '구현체는 data_sync 다(01 §1-4 · §4-1).',
      );
    });

    test('C-7 쓰기 이름이 나오는 파일은 CommandApi 하나다', () {
      final List<String> writeSurfaces = <String>[];
      for (final File f in dartSourcesIn(libDir)) {
        final String code = stripCommentsAndStrings(f.readAsStringSync());
        if (!_writeVerb.hasMatch(code)) {
          continue;
        }
        writeSurfaces.add(shortPath(f));
      }
      expect(
        writeSurfaces.toSet(),
        <String>{'packages/domain_contracts/lib/src/commands/command_api.dart'},
        reason:
            '계약에서 쓰기 이름이 나오는 파일이 늘었다. 늘어야 한다면 01 §4-2 를 '
            '먼저 고치고 그 커밋에서 이 목록을 고친다.',
      );
    });

    test('C-7 둘째 쓰기 창구 SettingsActions 의 표면은 run·watch 둘뿐이다', () {
      // 🔴 `SettingsActions` 는 `CommandApi` 가 **아니다**(01 §4-3) — 그래서 동사
      //    이름의 메서드를 두지 않고 `run(SettingsActionId, args)` 하나로 받는다.
      //    동작이 늘어도 **표면은 늘지 않는** 것이 이 계약의 형태이며, 여기서
      //    표면이 늘어나는 것을 막는다.
      final String code = stripCommentsAndStrings(
        File('${libDir.path}/src/commands/settings_actions.dart')
            .readAsStringSync(),
      );
      final String surface = RegExp(
        r'abstract interface class SettingsActions \{(.*?)\n\}',
        dotAll: true,
      ).firstMatch(code)!.group(1)!;
      final List<String> methods = RegExp(r'\b(\w+)\s*\(')
          .allMatches(surface)
          .map((RegExpMatch m) => m.group(1)!)
          .toList();
      expect(
        methods.toSet(),
        <String>{'run', 'watch'},
        reason:
            '01 §4-3 — «동작»만이다(G-29). 상태 구독은 리포지토리 쪽이고, 여기에 '
            '메서드를 더하면 화면이 run() 을 폴링해 상태를 만들기 시작한다.',
      );
    });

    test('C-7 안전 화면이 소유한 이름이 계약에 실재한다', () {
      final String safetySource = File('${libDir.path}/src/dto/safety.dart')
          .readAsStringSync();
      expect(safetySource, contains('killSwitch'));
      expect(safetySource, contains('releaseProgress'));
      expect(
        File('${libDir.path}/src/dto/resume.dart').readAsStringSync(),
        contains('ResumeReport'),
      );
    });

    test('C-7 ui_*(ui_safety 제외) 소스에 안전 원본 렌더가 0건이다', () {
      // ⚠️ 지금은 스텁이라 통과가 쉽다 — 자리를 비워 두지 않는다.
      final List<String> offenders = <String>[];
      for (final String name in uiPackageNames) {
        if (name == 'ui_safety') {
          continue;
        }
        for (final File f in dartSourcesIn(
          Directory('${repoRoot.path}/packages/$name/lib'),
        )) {
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final String symbol in _safetyOwnedSymbols) {
            if (RegExp('\\b$symbol\\b').hasMatch(code)) {
              offenders.add('${shortPath(f)}: $symbol');
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '🔴 §2-10 표의 ✅ 항목(배너·읽기 목록·딥링크)은 통과다 — 여기서 잡는 것은 '
            '**원본 렌더**다(01 §7 C-7).',
      );
    });

    test(
      'C-7 조작 위젯·쓰기 호출 검사(위젯트리)',
      () {},
      skip:
          '「플래그 해제·게이트 통과·재개·정정 성격의 조작 위젯」은 위젯 종류를 봐야 '
          '판정할 수 있어 소스 문자열 검사로 대신하지 않는다. ✅ 2026-09-17: ui_journal '
          'J-1 은 원본 심볼 0건(위 검사) + 사람 검사 ④(C4 R1)로 통과 — 위젯트리 자동 '
          '판정은 M5 화면(ui_safety) 착수 시 그 패키지 테스트로 넣는다.',
    );
  });
}
