// C-33 내비게이션 계약 — 01 §4-4 · §7 표 C-33(🆕 계약 v1.1 · §8 미결 36 해소).
//
// 정의: 「픽스처(= 엔진이 내보낼 모양)의 모든 링크가 계약이 아는 목적지다」.
//   ① `aaq://` 링크는 전부 `AppRoutes.all` 의 패턴 하나와 일치한다.
//   ② 링크 필드에는 `aaq://`·`handbook://` 두 스킴만 온다(경로 조각·임의 문자열 금지).
//   ③ 라우트 목록 자체가 건강하다(중복 없음 · 06 §3-5 의 M5·X 라우트 10종 포함).
// 🔴 화면은 이 검사의 대상이 아니다 — 화면은 링크를 **만들지 않으므로** 검사할 것이 없고,
//    만들었다면 `tool/check_boundaries.sh` 의 `aaq://` 리터럴 스캔이 잡는다.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 링크를 싣는 JSON 키 — DTO 의 링크 필드 전수(snake_case).
const Set<String> _linkKeys = <String>{
  'deep_link',
  'detail_deep_link',
  'action_deep_link',
  'where_deep_link',
  'clear_deep_link',
  'route',
  'preview_route',
  'handoff_route',
  'resume_route',
};

/// `route` 라는 키는 링크가 아닌 **열거값**으로도 쓰인다(`LedgerDiffRow.route` =
/// `RepairRoute` — AUTO·APPROVAL). 대문자·밑줄뿐인 값은 링크 검사에서 뺀다.
final RegExp _enumLike = RegExp(r'^[A-Z][A-Z0-9_]*$');

void main() {
  group('C-33 내비게이션 계약 (01 §4-4)', () {
    test('C-33 ① 픽스처의 모든 링크가 등록된 목적지다', () {
      final List<String> bad = <String>[];
      int seen = 0;
      for (final String path in FixturePaths.all) {
        walkJson(jsonDecode(readFixture(path)), (
          String jsonPath,
          String key,
          Object? value,
        ) {
          if (!_linkKeys.contains(key) || value is! String) {
            return;
          }
          if (key == 'route' && _enumLike.hasMatch(value)) {
            return;
          }
          seen++;
          final int cut = value.indexOf('://');
          final String scheme = cut < 0 ? '' : value.substring(0, cut);
          if (!AppLinkSchemes.values.contains(scheme)) {
            bad.add('$path $jsonPath = $value (스킴 없음·미등록)');
            return;
          }
          if (scheme == AppLinkSchemes.app && !AppRoutes.isRegistered(value)) {
            bad.add('$path $jsonPath = $value (AppRoutes 에 없는 목적지)');
          }
        });
      }
      expect(seen, greaterThan(100), reason: '링크를 하나도 못 찾았다 — 키 목록이 낡았다.');
      expect(
        bad,
        isEmpty,
        reason:
            '엔진이 계약에 없는 목적지를 내보내면 셸이 갈 곳을 모른다. 라우트를 '
            '`AppRoutes` 에 등재하거나(M2) 픽스처를 고친다 — 화면이 이름을 지어 쓰지 않는다.',
      );
    });

    test('C-33 ② 링크처럼 생긴 문자열이 링크 키 밖에 숨어 있지 않다', () {
      final List<String> stray = <String>[];
      for (final String path in FixturePaths.all) {
        walkJson(jsonDecode(readFixture(path)), (
          String jsonPath,
          String key,
          Object? value,
        ) {
          if (value is! String || _linkKeys.contains(key)) {
            return;
          }
          if (value.startsWith('aaq://') || value.startsWith('handbook://')) {
            stray.add('$path $jsonPath ($key) = $value');
          }
        });
      }
      expect(
        stray,
        isEmpty,
        reason: '새 링크 필드가 생겼다 — `_linkKeys` 에 올려 ① 의 검사를 받게 한다.',
      );
    });

    test('C-33 ③ 라우트 목록에 중복이 없고 M5·X 소유 10종이 들어 있다', () {
      expect(AppRoutes.all.toSet().length, AppRoutes.all.length);
      const List<String> ownedByClaude = <String>[
        'aaq://m5/kill-switch',
        'aaq://m5/release-gate',
        'aaq://m5/block-board',
        'aaq://m5/intervention',
        'aaq://x2/resume-report',
        'aaq://x2/resume-gate',
        'aaq://x1/migration',
        'aaq://x5/repair-wizard',
        'aaq://m5/handover-gate',
        'aaq://m5/handover-wizard',
      ];
      for (final String route in ownedByClaude) {
        expect(AppRoutes.all, contains(route), reason: '06 §3-5 목록의 $route');
      }
      for (final String pattern in AppRoutes.all) {
        expect(
          pattern,
          startsWith('${AppLinkSchemes.app}://'),
          reason: pattern,
        );
      }
    });

    test('C-33 ④ 일치 규칙 — 파라미터는 비지 않고 쿼리·조각을 받지 않는다', () {
      expect(AppRoutes.isRegistered('aaq://journal/decision/d_1'), isTrue);
      expect(AppRoutes.isRegistered('aaq://journal/decision/'), isFalse);
      expect(AppRoutes.isRegistered('aaq://journal/decision/d_1?x=1'), isFalse);
      expect(AppRoutes.isRegistered('aaq://report/2026-08'), isTrue);
      expect(AppRoutes.isRegistered('aaq://report/archive'), isTrue);
      expect(AppRoutes.isRegistered('aaq://nowhere'), isFalse);
      expect(AppRoutes.isRegistered('m5/kill-switch'), isFalse);
    });
  });
}
