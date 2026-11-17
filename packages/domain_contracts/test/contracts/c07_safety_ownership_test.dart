// C-7 안전 화면 소유권 — 01 §7 표 C-7 · 인벤토리 §9(🟡 부분).
//
// 정의: 「`ui_*`(`ui_safety` 제외)에 ① `killSwitch`·`releaseProgress`·`ResumeReport`
//   **원본** 렌더 ② 플래그 해제·게이트 통과·재개·정정 성격의 **조작 위젯**
//   ③ `CommandApi`·`SettingsActions`·`DraftStore`(기기 로컬 초안) 밖의 쓰기 호출이 있으면 실패.
//   §2-10 표의 ✅ 항목(배너·읽기 목록·딥링크)은 통과」.
//
// 🟡 위젯 검사는 `ui_*` 선행이다. 지금 고정할 수 있는 것은 **경계의 뼈대**다 —
//    ① 소유 경로가 CODEOWNERS 에 파일 경로로 적혀 있고(07 §9 기계 검사 3)
//    ② 리포지토리에 쓰기 메서드가 하나도 없으며(01 §4-1)
//    ③ 쓰기 창구가 `CommandApi`·`SettingsActions` 둘 + 🆕 v1.2 예외 1 `DraftStore`(기기 로컬
//       입력 초안 · 원장·명령 쓰기가 아니다 — 01 §1-4 · §12-1) + 🆕 v1.21 `SafetyActions`(M5 폰 로컬 · 01 §30)뿐이다
//       (01 §4-2·§4-3).

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

/// 🆕 v1.19(01 §7 C-7 · §28 K17 · K27) — 쓰기 동사로 시작하지만 **읽기 표시 칸**인 이름(파일별 · 이름 정확히).
/// `OperationsVm.updateGate` = 엔진 버전 전환 게이트 카드(강행 칸 0) — 쓰기 표면이 아니다. 이 이름만 걸러내고
/// 그 파일의 다른 쓰기 이름은 그대로 잡는다(파일 통째 예외 0).
const Map<String, Set<String>> _readOnlyFieldNames = <String, Set<String>>{
  'packages/domain_contracts/lib/src/dto/operations.dart': <String>{
    'updateGate',
  },
};

/// 🆕 v1.2 — 접미 없는 **맨** 쓰기 동사 메서드(`save(`·`delete(` …). [_writeVerb] 는 `…[A-Z_]` 만
/// 보므로 `DraftStore.save(` 는 거기에 걸리지 않는다 — 그 구멍을 이름으로 허용해 닫는다(C-7 ⑥).
final RegExp _bareWriteVerbCall = RegExp(
  r'\b(save|write|submit|send|insert|update|delete|apply|commit)\s*\(',
);

/// 인터페이스 본문 [surface](주석·문자열 제거 뒤 `{ … }` 안)가 **정확히** [names] 의 메서드 선언만으로
/// 이뤄졌는가 — `Future<…>`/`Stream<…>` 반환 메서드 선언을 지우고 남는 것이 공백뿐이어야 한다.
/// getter·필드·다른 반환형 메서드가 끼면 글자가 남아 실패한다(🆕 v1.2 검증 반영 · C-7 ⑤ — 이름
/// 추출 `이름(` 만으로는 `Stream<…> get everything;` 추가가 초록으로 지나갔다 · 변이 M13).
void _expectSurfaceIsExactly(
  String surface,
  String typeName,
  Set<String> names,
) {
  final RegExp decl = RegExp(
    r'(?:Future|Stream)<[^;{}]*>\s+(\w+)\s*\([^;]*?\)\s*;',
    dotAll: true,
  );
  final List<String> declared =
      decl.allMatches(surface).map((RegExpMatch m) => m.group(1)!).toList()
        ..sort();
  expect(
    declared,
    names.toList()..sort(),
    reason: '$typeName — 선언된 메서드가 ${names.join('·')} 각 1개가 아니다.',
  );
  final String rest = surface.replaceAll(decl, '').trim();
  expect(
    rest,
    isEmpty,
    reason:
        '$typeName 표면에 메서드 선언 밖의 것이 있다(getter·필드·다른 반환형) — '
        '표면이 늘었다: «$rest»',
  );
}

/// [path] 의 코드(주석·문자열 제외)에 나오는 쓰기 이름 전체(예: `submitJournalDraft`).
Set<String> _writeNamesIn(String path) {
  final String code = stripCommentsAndStrings(File(path).readAsStringSync());
  return RegExp(
    r'\b((?:save|write|submit|send|insert|update|delete|apply|commit)[A-Z_]\w*)',
  ).allMatches(code).map((RegExpMatch m) => m.group(1)!).toSet();
}

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
        final Set<String>? readOnly = _readOnlyFieldNames[shortPath(f)];
        if (readOnly != null && readOnly.containsAll(_writeNamesIn(f.path))) {
          continue;
        }
        writeSurfaces.add(shortPath(f));
      }
      expect(
        writeSurfaces.toSet(),
        <String>{
          'packages/domain_contracts/lib/src/commands/command_api.dart',
          // 🆕 v1.1 R2 준비(2026-09-23 · 01 §11-10) — `UnimplementedCommandApi` 받침대
          //    (배럴 밖 · test 전용). CommandApi 를 그대로 비추고 전부 던질 뿐이라 새 쓰기
          //    창구가 아니다 — 바로 아래 검사가 «CommandApi 에 없는 쓰기 이름 0건»으로 못 박는다.
          'packages/domain_contracts/lib/testing.dart',
        },
        reason:
            '계약에서 쓰기 이름이 나오는 파일이 늘었다. 늘어야 한다면 01 §4-2 를 '
            '먼저 고치고 그 커밋에서 이 목록을 고친다.',
      );
      final Set<String> apiNames = _writeNamesIn(
        '${libDir.path}/src/commands/command_api.dart',
      );
      final Set<String> mirrorNames = _writeNamesIn(
        '${libDir.path}/testing.dart',
      );
      expect(apiNames, isNotEmpty, reason: 'CommandApi 의 쓰기 이름을 못 읽었다.');
      expect(
        mirrorNames.difference(apiNames),
        isEmpty,
        reason:
            'lib/testing.dart 는 CommandApi 의 받침대다 — CommandApi 에 없는 쓰기 '
            '이름이 나오면 test 전용 파일이 둘째 쓰기 창구가 된 것이다.',
      );
    });

    test('C-7 둘째 쓰기 창구 SettingsActions 의 표면은 '
        'run·runContributionUpdate·watch 셋이다', () {
      // 🔴 `SettingsActions` 는 `CommandApi` 가 **아니다**(01 §4-3) — 그래서 동사
      //    이름의 메서드를 두지 않고 `run(SettingsActionId, args)` 하나로 받는다.
      //    동작이 늘어도 **표면은 늘지 않는** 것이 이 계약의 형태이며, 여기서
      //    표면이 늘어나는 것을 막는다.
      // 🆕 v1.23(01 §32 · K77) — K7(사람 글·수 = 제출 DTO)이 표면 고정을 이긴다(v1.22 K52 선례) — 사람이 친 금액 1
      //    (`runContributionUpdate(ContributionUpdateSubmission)`) · 엔진이 완성하는 동작은 여전히 `run` 화이트리스트.
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
        <String>{'run', 'runContributionUpdate', 'watch'},
        reason:
            '01 §4-3 — «동작»만이다(G-29). 상태 구독은 리포지토리 쪽이고, 여기에 '
            '메서드를 더하면 화면이 run() 을 폴링해 상태를 만들기 시작한다 '
            '(🆕 v1.23 K77 — 사람이 친 금액 제출 1 만 예외).',
      );
      // 🆕 v1.2 검증 반영 — getter·필드도 표면이다(선언 전체 대조).
      _expectSurfaceIsExactly(surface, 'SettingsActions', <String>{
        'run',
        'runContributionUpdate',
        'watch',
      });
    });

    test('C-7 넷째 쓰기 창구 SafetyActions 의 표면은 run·runKillResumeItem·runPledge·runStoppedDecision·runPostmortem·'
        'runRuleChangeApproval·runDiscretionAdjust·watch 여덟이다', () {
      // 🆕 v1.21(01 §30 · K5 · K31 · K39) — M5 폰 로컬 안전 동작. `CommandApi` 가 **아니다** — 동사 이름 메서드 0
      //    (`submit…` 은 위 «쓰기 이름 파일» 검사에 걸린다) · 제출 DTO 갈래 + 엔진이 완성한 호출 `run` + 결과 구독 `watch`.
      // 🆕 v1.22(01 §31 · K52) — K7(사람 글·수 = 제출 DTO)이 v1.21 K39(표면 고정)를 이긴다 — 제출 메서드 +4
      //    (STOPPED 결정 · postmortem · 규칙 변경 승인 · 재량 조정). 엔진이 완성하는 동작은 여전히 `run` 화이트리스트.
      final String code = stripCommentsAndStrings(
        File('${libDir.path}/src/commands/safety_actions.dart')
            .readAsStringSync(),
      );
      final String surface = RegExp(
        r'abstract interface class SafetyActions \{(.*?)\n\}',
        dotAll: true,
      ).firstMatch(code)!.group(1)!;
      _expectSurfaceIsExactly(surface, 'SafetyActions', <String>{
        'run',
        'runKillResumeItem',
        'runPledge',
        'runStoppedDecision',
        'runPostmortem',
        'runRuleChangeApproval',
        'runDiscretionAdjust',
        'watch',
      });
    });

    test('C-7 셋째 쓰기 창구 DraftStore 의 표면은 load·save·clear 셋뿐이다', () {
      // 🆕 v1.2(01 §1-4 예외 1 · §12-1) — 기기 로컬 입력 초안. 원장·명령·공유 저장소 쓰기가
      //    아니며 표면은 01 §8 미결 47 원문의 세 동사로 **고정**한다(SettingsActions 선례).
      final String code = stripCommentsAndStrings(
        File('${libDir.path}/src/commands/draft_store.dart').readAsStringSync(),
      );
      final String surface = RegExp(
        r'abstract interface class DraftStore \{(.*?)\n\}',
        dotAll: true,
      ).firstMatch(code)!.group(1)!;
      final List<String> methods = RegExp(r'\b(\w+)\s*\(')
          .allMatches(surface)
          .map((RegExpMatch m) => m.group(1)!)
          .toList();
      expect(
        methods.toSet(),
        <String>{'load', 'save', 'clear'},
        reason:
            '01 §12-1 — 초안 포트는 load·save·clear 셋이다. 메서드를 더하면 원장·명령 쓰기가 '
            '«초안»이라는 이름으로 새 창구를 얻는다(01 §1-4 예외 1 의 범위를 넘는다).',
      );
      // 🆕 v1.2 검증 반영 — getter·필드(`Stream<…> get everything;`)도 표면이다. 세 선언을 지우고
      //    남는 것이 없어야 한다.
      _expectSurfaceIsExactly(surface, 'DraftStore', <String>{
        'load',
        'save',
        'clear',
      });
    });

    test('C-7 맨 쓰기 동사 메서드는 DraftStore 와 그 받침대에만 있다', () {
      // 🔴 사유 — 위 `_writeVerb` 는 `…[A-Z_]` 만 봐서 `save(`·`delete(` 같은 맨 동사를 못 잡는다.
      //    정규식 구멍을 **명시 허용**으로 닫는다: 맨 동사가 나오는 파일은 초안 포트와 받침대뿐이다.
      const Set<String> allowed = <String>{
        'packages/domain_contracts/lib/src/commands/draft_store.dart',
        'packages/domain_contracts/lib/testing.dart',
      };
      final Set<String> found = <String>{};
      for (final File f in dartSourcesIn(libDir)) {
        final String code = stripCommentsAndStrings(f.readAsStringSync());
        if (_bareWriteVerbCall.hasMatch(code)) {
          found.add(shortPath(f));
        }
      }
      expect(
        found.difference(allowed),
        isEmpty,
        reason:
            '맨 쓰기 동사 메서드가 초안 포트 밖에 생겼다 — 새 쓰기 창구다. 늘어야 한다면 01 §1-4 를 '
            '먼저 고치고 그 커밋에서 이 목록을 고친다.',
      );
      expect(
        found,
        contains('packages/domain_contracts/lib/src/commands/draft_store.dart'),
        reason: '정규식이 DraftStore.save( 를 못 읽었다 — 검사가 공허해진다.',
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
