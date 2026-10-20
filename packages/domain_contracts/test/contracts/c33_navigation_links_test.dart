// C-33 내비게이션 계약 — 01 §4-4 · §7 표 C-33(🆕 계약 v1.1 · §8 미결 36 해소).
//
// 정의: 「픽스처(= 엔진이 내보낼 모양)의 모든 링크가 계약이 아는 목적지다」.
//   ① `aaq://` 링크는 전부 `AppRoutes.all` 의 패턴 하나와 일치한다.
//   ② 링크 필드에는 `aaq://`·`handbook://` 두 스킴만 온다(경로 조각·임의 문자열 금지).
//   ③ 라우트 목록 자체가 건강하다(중복 없음 · 06 §3-5 의 M5·X 라우트 10종 포함).
//   🆕 v1.3(01 §13-7) — 동작 링크 `AppNavActions`(「돌아가기」)
//   ⑤ 동작 링크는 목적지가 아니다 — `AppRoutes.all` 과 겹치지 않고 등록된 목적지로 읽히지 않는다.
//   ⑥ 엔진·픽스처는 동작 링크를 싣지 않는다(화면 명세가 버튼을 명시한 자리에서 화면이 상수로 연다).
//   🆕 v1.4(01 §14-9 · 설계 Δ4 C-33) — 링크 키 +`goal_deep_link`(`MonthlyReport.goalDeepLink`) ·
//   라우트 **42**(`reportGoalPath` · `planWithdrawal` 은 인출 규칙 결정 뒤 첫 minor) ·
//   `DepositPreviewResult.blockedAction` 의 `deep_link` 는 기존 `deep_link` 키로 이미 덮인다
//   (③ 에 개수 · ④ 에 `report/goal/…` 일치 예시).
//   🆕 v1.5(01 §15-3) — 라우트 **43**(`journalRebalance`) · `_linkKeys` 무변경(`journal_timeline_link` 는
//   `LinkAction` 이라 안쪽 `deep_link` 로 덮인다 · `RebalanceEvent.detailDeepLink` 는 기존 `detail_deep_link`) ·
//   ⑦ 선언 순서 = 첫 일치.
//   🆕 v1.6(01 §15-4) — 라우트 **45**(`ledgerExecutionGapMonth` · `rebalanceHistory`) · `_linkKeys` 무변경
//   (`RebalancePreviewResult.blockedAction` 은 `LinkAction` 이라 안쪽 `deep_link` 로 덮인다) · ④ 에
//   `ledger/execution-gap/<yyyy-MM>`·`rebalance/history` 일치 예시 · ①② 가 새 링크(월간 ⑧ 그 달 ·
//   미리보기 차단 버튼)를 검사한다.
//   🆕 v1.8(01 §17) — 라우트 **48**(`holdingsOverview` · `holdingsDetail` · `holdingsAllocation`) · `_linkKeys` 무변경
//   (`HoldingRow.detailDeepLink` = 기존 `detail_deep_link` · `allocationLink`·`entryDecisionLink` 는 `LinkAction` 이라
//   안쪽 `deep_link`) · ④ 에 `holdings/detail/<id>`·`holdings/overview`·`holdings/allocation` 일치 예시.
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
  // 🆕 v1.4(01 §14-9) — `MonthlyReport.goalDeepLink`(«목표 경로 보기» · `aaq://report/goal/<yyyy-MM>`).
  //    `DepositPreviewResult.blockedAction.deep_link` 는 위 `deep_link` 로 이미 덮인다.
  'goal_deep_link',
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
      // 🆕 v1.4 — 41 → 42(`reportGoalPath`). 🆕 v1.5 — 42 → 43(`journalRebalance` · 01 §15-3).
      // 🆕 v1.6 — 43 → 45(`ledgerExecutionGapMonth` · `rebalanceHistory` · 01 §15-4).
      // 🆕 v1.8 — 45 → 48(`holdingsOverview` · `holdingsDetail` · `holdingsAllocation` · 01 §17).
      //    🔴 개수가 바뀌면 01 · 04 셸 라우트 문단을 같은 PR 에서 고친다
      //    (셸은 `all` 을 전량 등록한다 — C-17·C-18 의 모집단이 곧 이 목록이다).
      expect(
        AppRoutes.all,
        hasLength(48),
        reason: '라우트 수가 계약(01 §17 · v1.8 = 48)과 다르다.',
      );
      expect(AppRoutes.all, contains(AppRoutes.holdingsOverview));
      expect(AppRoutes.all, contains(AppRoutes.holdingsDetail));
      expect(AppRoutes.all, contains(AppRoutes.holdingsAllocation));
      expect(AppRoutes.all, contains(AppRoutes.ledgerExecutionGapMonth));
      expect(AppRoutes.all, contains(AppRoutes.rebalanceHistory));
      expect(AppRoutes.all, contains(AppRoutes.journalRebalance));
      expect(AppRoutes.all, contains(AppRoutes.reportGoalPath));
      expect(AppRoutes.all, contains(AppRoutes.planDeposit));
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
      // 🆕 v1.2 — `journalRead` 는 `journal/draft`·`journal/decision` 과 **둘째 고정 세그먼트**로 갈린다.
      expect(AppRoutes.isRegistered('aaq://journal/read/d_1'), isTrue);
      expect(AppRoutes.isRegistered('aaq://journal/decision/'), isFalse);
      expect(AppRoutes.isRegistered('aaq://journal/decision/d_1?x=1'), isFalse);
      expect(AppRoutes.isRegistered('aaq://report/2026-08'), isTrue);
      expect(AppRoutes.isRegistered('aaq://report/archive'), isTrue);
      // 🆕 v1.4 — `report/goal/:yyyyMm` 은 세그먼트 수가 달라 `report/:yyyyMm` 과 겹치지 않는다.
      expect(AppRoutes.isRegistered('aaq://report/goal/2026-08'), isTrue);
      expect(AppRoutes.isRegistered('aaq://report/goal/'), isFalse);
      expect(AppRoutes.isRegistered('aaq://report/goal/2026-08/x'), isFalse);
      // 🆕 v1.5 — `journal/rebalance/:rebalanceEventId` 는 경로 파라미터로만 회차를 싣는다(쿼리 거부).
      expect(AppRoutes.isRegistered('aaq://journal/rebalance/re_1'), isTrue);
      expect(AppRoutes.isRegistered('aaq://journal/rebalance/'), isFalse);
      expect(
        AppRoutes.isRegistered('aaq://journal/rebalance/re_1?x=1'),
        isFalse,
      );
      // 🆕 v1.6 — `ledger/execution-gap/:yyyyMm` 은 세그먼트 수가 달라 `ledger/execution-gap` 과 겹치지 않는다 ·
      //    `rebalance/history` 는 고정 2세그먼트(`rebalance/:x` 패턴은 없다).
      expect(
        AppRoutes.isRegistered('aaq://ledger/execution-gap/2026-08'),
        isTrue,
      );
      expect(AppRoutes.isRegistered('aaq://ledger/execution-gap/'), isFalse);
      expect(
        AppRoutes.isRegistered('aaq://ledger/execution-gap/2026-08?x=1'),
        isFalse,
      );
      expect(AppRoutes.isRegistered('aaq://rebalance/history'), isTrue);
      // 🆕 v1.8 — `holdings/detail/:holdingId` 는 세그먼트 수가 달라 `holdings/overview`·`allocation` 과 겹치지 않는다.
      expect(AppRoutes.isRegistered('aaq://holdings/detail/h_1'), isTrue);
      expect(AppRoutes.isRegistered('aaq://holdings/detail/'), isFalse);
      expect(AppRoutes.isRegistered('aaq://holdings/detail/h_1?x=1'), isFalse);
      expect(AppRoutes.isRegistered('aaq://holdings/overview'), isTrue);
      expect(AppRoutes.isRegistered('aaq://holdings/allocation'), isTrue);
      expect(AppRoutes.isRegistered('aaq://journal/timeline'), isTrue);
      expect(AppRoutes.isRegistered('aaq://nowhere'), isFalse);
      expect(AppRoutes.isRegistered('m5/kill-switch'), isFalse);
    });

    test('C-33 ⑦ 선언 순서 — 각 패턴의 표본이 처음 일치하는 패턴은 그 자신이다', () {
      // 🆕 v1.5(01 §15-3) — «고정 세그먼트가 파라미터보다 먼저 일치한다»(app_links.dart `AppRoutes` 머리)는
      //    `all` 의 **선언 순서**에만 기대고 있었다. 셸은 같은 순서로 디스패치하므로 순서가 틀리면
      //    `aaq://report/archive` 가 `report/:yyyyMm` 화면으로 간다. 그 실수를 기계로 막는다.
      // 🔴 «정확히 하나와 일치»가 아니다 — `report/archive`·`aftertax`·`annual` 표본은 `report/:yyyyMm`
      //    에도 일치한다(설계대로). 첫 일치가 자기 자신이면 된다.
      // `_matches` 는 private 이라 같은 규칙을 여기서 재현하고, 먼저 `isRegistered` 와 같은지 확인한다.
      bool matches(String pattern, String link) {
        final List<String> p = pattern.split('/');
        final List<String> l = link.split('/');
        if (p.length != l.length) {
          return false;
        }
        for (int i = 0; i < p.length; i++) {
          if (p[i].startsWith(':')) {
            if (l[i].isEmpty || l[i].contains('?') || l[i].contains('#')) {
              return false;
            }
          } else if (p[i] != l[i]) {
            return false;
          }
        }
        return true;
      }

      // 고정 세그먼트로 쓰이지 않는 더미 값.
      const String dummy = 'zz_sample_1';
      String sampleOf(String pattern) => pattern
          .split('/')
          .map((String seg) => seg.startsWith(':') ? dummy : seg)
          .join('/');

      for (final String pattern in AppRoutes.all) {
        final String sample = sampleOf(pattern);
        expect(
          AppRoutes.isRegistered(sample),
          isTrue,
          reason: '표본 $sample 이 등록되지 않았다 — 재현 규칙이 실물과 갈라졌다.',
        );
        expect(
          AppRoutes.all.where((String p) => matches(p, sample)),
          isNotEmpty,
          reason: '재현 규칙이 $sample 을 놓친다.',
        );
        final String first = AppRoutes.all.firstWhere(
          (String p) => matches(p, sample),
        );
        expect(
          first,
          pattern,
          reason:
              '$sample 이 먼저 $first 와 일치한다 — 고정 세그먼트 패턴을 `all` 에서 파라미터 패턴보다 '
              '앞에 둔다(셸 디스패치 순서 · 01 §15-3).',
        );
      }
      // 재현 규칙이 ④ 의 예시와도 같은 답을 내는지(거짓 일치·거짓 불일치 0).
      const List<String> probes = <String>[
        'aaq://journal/decision/d_1',
        'aaq://journal/decision/',
        'aaq://journal/decision/d_1?x=1',
        'aaq://report/2026-08',
        'aaq://report/archive',
        'aaq://report/goal/2026-08/x',
        'aaq://nowhere',
      ];
      for (final String probe in probes) {
        expect(
          AppRoutes.all.any((String p) => matches(p, probe)),
          AppRoutes.isRegistered(probe),
          reason: probe,
        );
      }
    });

    test('C-33 ⑤ 동작 링크는 목적지 목록과 겹치지 않는다', () {
      expect(AppNavActions.all, isNotEmpty);
      expect(AppNavActions.all, contains(AppNavActions.back));
      expect(
        AppNavActions.all.intersection(AppRoutes.all.toSet()),
        isEmpty,
        reason: '동작 링크는 목적지가 아니다 — 셸이 라우트 테이블에 올리지 않는다(01 §13-7).',
      );
      for (final String action in AppNavActions.all) {
        expect(
          action,
          startsWith('${AppLinkSchemes.app}://'),
          reason: '$action — 앱 스킴이다(`AppLinkOpener.open` 한 창구로 연다).',
        );
        expect(
          AppRoutes.isRegistered(action),
          isFalse,
          reason:
              '$action — 파라미터 패턴에 걸려 목적지로 읽힌다. 셸은 동작 링크를 '
              '`isRegistered` 보다 먼저 처리하지만, 겹치면 순서 하나에 뜻이 매달린다.',
        );
      }
    });

    test('C-33 ⑥ 픽스처는 동작 링크를 싣지 않는다', () {
      // 자체 검증 — 가짜 봉투에 실린 동작 링크는 걸린다(링크 키 · 링크 키 밖 · 목록 안 모두).
      expect(
        _navActionLeaks('fake', <String, Object?>{
          'rows': <Object?>[
            <String, Object?>{'route': AppNavActions.back},
          ],
        }),
        hasLength(1),
      );
      expect(
        _navActionLeaks('fake', <String, Object?>{
          'back_button': <String, Object?>{'note': AppNavActions.back},
        }),
        hasLength(1),
      );
      expect(
        _navActionLeaks('fake', <String, Object?>{
          'route': AppRoutes.performanceExplore,
          'label': '돌아가기',
        }),
        isEmpty,
      );

      final List<String> leaks = <String>[
        for (final String path in FixturePaths.all)
          ..._navActionLeaks(path, jsonDecode(readFixture(path))),
      ];
      expect(
        leaks,
        isEmpty,
        reason:
            '동작 링크는 DTO·픽스처에 실리지 않는다 — 「돌아가기」는 화면 명세가 명시한 버튼이고 '
            '화면이 `AppNavActions.back` 상수로 연다(01 §13-7).',
      );
    });
  });
}

/// [json] 안의 문자열 값 가운데 동작 링크(`AppNavActions.all`)인 것 — `경로 자리 = 값`.
List<String> _navActionLeaks(String path, Object? json) {
  final List<String> out = <String>[];
  walkJson(json, (String jsonPath, String key, Object? value) {
    if (value is String && AppNavActions.all.any(value.startsWith)) {
      out.add('$path $jsonPath = $value');
    }
  });
  return out;
}
