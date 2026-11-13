// C-6 결정 8 게이트(손익 타입 격리) — 01 §7 표 C-6 · 인벤토리 §9(🟡 부분).
//
// 정의: 「홈·알림·위젯 위젯트리에 `HoldingPnl`·`PerformanceSeries` 타입 참조 금지」.
// 잡는 것: **홈 손익 노출**.
//
// 🟡 위젯트리 검사는 `ui_*` 선행이다. 여기서는 그보다 **앞의 방벽**을 고정한다 —
//    홈·알림 DTO 가 애초에 손익 타입을 **필드로 갖지 않는다**. 계약이 손익을 홈까지
//    실어 보내지 않으면 화면은 그릴 수가 없다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 결정 8 이 홈에서 막는 타입.
const List<String> _pnlTypes = <String>['HoldingPnl', 'PerformanceSeries'];

/// 홈·알림·셸 계열 DTO — 「위젯트리」의 계약 쪽 대응물.
const List<String> _homeTypes = <String>[
  'OpsDailySummary',
  'OpsRhythmRow',
  'ShellVm',
  'ShellChip',
  'AlertItem',
  'AckState',
  'FeatureFlags',
];

/// 손익으로 읽히는 JSON 키.
const List<String> _pnlJsonKeys = <String>[
  'pnl',
  'unrealized_pnl',
  'realized_pnl',
  'pnl_pct',
  'return_pct',
];

void main() {
  group('C-6 결정 8 게이트 (01 §7)', () {
    test('C-6 홈·알림·셸 DTO 가 손익 타입을 필드로 갖지 않는다', () {
      final Map<String, String> bodies = _freezedBodies();
      for (final String type in _homeTypes) {
        final String? body = bodies[type];
        expect(body, isNotNull, reason: '$type 이 계약에 없다 — 이름을 확인한다.');
        for (final String pnl in _pnlTypes) {
          expect(
            RegExp('\\b$pnl\\b').hasMatch(body!),
            isFalse,
            reason: '$type 이 $pnl 을 싣는다 — 홈이 손익을 그릴 수 있게 된다(결정 8).',
          );
        }
      }
    });

    test('C-6 홈 픽스처에 손익 키가 0건이다', () {
      const List<String> homeFixtures = <String>[
        FixturePaths.m8OpsHomeNormal,
        FixturePaths.m8OpsHomeBlocked,
        FixturePaths.m8OpsHomeAdviceOpen,
        FixturePaths.m8OpsHomeAdviceSuppressedDue,
        FixturePaths.m8OpsHomeAdviceZero,
        FixturePaths.m8OpsHomeResumeGap7,
        FixturePaths.alerts12,
        FixturePaths.m8AlertsDigest,
        FixturePaths.m8AlertsP0Ack,
        FixturePaths.m8AlertsAdvice9codes,
        // 🆕 v1.15(01 §24) — 알림 센터 5 · 상세 3(접수증 = 명령이라 뺀다).
        FixturePaths.m8AlertCenterP0Ack,
        FixturePaths.m8AlertCenterDigest,
        FixturePaths.m8AlertCenterEmpty,
        FixturePaths.m8AlertCenterP0Only,
        FixturePaths.m8AlertCenterP0AckReordered,
        FixturePaths.m8AlertDetailFull,
        FixturePaths.m8AlertDetailNoLink,
        FixturePaths.m8AlertDetailMissing,
        // 🆕 v1.16(01 §25) — 온보딩 VM 29(O-00·O-00b·O-01·O-02·O-04·R-01·V-01 · 결과 3 = 명령 결과라 뺀다).
        FixturePaths.m8OnboardingStart,
        FixturePaths.m8OnboardingStartNoViewer,
        FixturePaths.m8OnboardingModeUnselected,
        FixturePaths.m8OnboardingModeAuto,
        FixturePaths.m8OnboardingModeAdvisory,
        FixturePaths.m8OnboardingModeLocked,
        FixturePaths.m8OnboardingStepsFresh,
        FixturePaths.m8OnboardingStepsAdvisory,
        FixturePaths.m8OnboardingStepsFinishReady,
        FixturePaths.m8OnboardingStepsFinishReadyWarn,
        FixturePaths.m8OnboardingStepsAllVerifiedLocked,
        FixturePaths.m8OnboardingStepsEmpty,
        FixturePaths.m8OnboardingStepDetailKisMock,
        FixturePaths.m8OnboardingStepDetailNoVerify,
        FixturePaths.m8OnboardingStepDetailMissing,
        FixturePaths.m8OnboardingFinishAuto,
        FixturePaths.m8OnboardingFinishAutoReady,
        FixturePaths.m8OnboardingFinishAutoDeclared,
        FixturePaths.m8OnboardingFinishAdvisory,
        FixturePaths.m8OnboardingFinishAdvisoryDeclared,
        FixturePaths.m8OnboardingFinishNoExpectation,
        FixturePaths.m8OnboardingFinishDone,
        FixturePaths.m8RestartVmLostPhone,
        FixturePaths.m8RestartVmLoggedOut,
        FixturePaths.m8RestartVmGap7,
        FixturePaths.m8RestartVmUnknown,
        FixturePaths.m8PairingWaiting,
        FixturePaths.m8PairingOk,
        FixturePaths.m8PairingFail,
        // 🆕 v1.17(01 §26) — 배너 6 · 런북 4 · 카드 2 · 핸드북 6 · 기기 2 · 알림 1.
        FixturePaths.m8IncidentBannerTokenExpired,
        FixturePaths.m8IncidentBannerOrderRejected,
        FixturePaths.m8IncidentBannerNetworkDown,
        FixturePaths.m8IncidentBannerPhoneDown,
        FixturePaths.m8IncidentBannerOther,
        FixturePaths.m8IncidentBannerNone,
        FixturePaths.m8RunbookIndex,
        FixturePaths.m8RunbookIndexEmpty,
        FixturePaths.m8RunbookHostLost,
        FixturePaths.m8RunbookMissing,
        FixturePaths.m8EmergencyCard,
        FixturePaths.m8EmergencyCardNoPrint,
        FixturePaths.m8HandbookIndex,
        FixturePaths.m8HandbookIndexOutdated,
        FixturePaths.m8HandbookPageSleeveB,
        FixturePaths.m8HandbookPageOutdated,
        FixturePaths.m8HandbookPageMissing,
        FixturePaths.m8HandbookPageArchived,
        FixturePaths.m8DeviceRiskItems,
        FixturePaths.m8DeviceRiskEmpty,
        FixturePaths.m8AlertsStaleOrdersHeld,
        // 🆕 v1.18(01 §27) — S01 3 · S07 3 · 결과 1 · 알림 1.
        FixturePaths.m9SettingsHome,
        FixturePaths.m9SettingsHomeNoReview,
        FixturePaths.m9SettingsHomeViewer,
        FixturePaths.m9Connections,
        FixturePaths.m9ConnectionsTelegram,
        FixturePaths.m9ConnectionsLocked,
        FixturePaths.m9SettingsActionResults,
        FixturePaths.m8AlertsSafetyResume,
      ];
      final List<String> offenders = <String>[];
      for (final String path in homeFixtures) {
        walkJson(jsonDecode(readFixture(path)), (
          String jsonPath,
          String key,
          Object? value,
        ) {
          if (_pnlJsonKeys.contains(key) && value != null) {
            offenders.add('$path $jsonPath');
          }
        });
      }
      expect(
        offenders,
        isEmpty,
        reason: '홈·알림 픽스처가 손익을 싣는다 — 계약이 이미 결정 8 을 어긴 것이다.',
      );
    });

    test('C-6 손익은 보유현황에서 «요청한 행»에만 실린다', () {
      // 인벤토리 §8-2 — holdings_6.json 은 6행 중 `pnl` 이 **3건만** 있다.
      // 🔴 「전 행에 실려 오는데 화면이 가린다」가 아니라 「엔진이 주지 않는다」가
      //    결정 8 의 형태다.
      final FixtureEnvelope envelope = decodeEnvelope(
        readFixture(FixturePaths.holdings6),
      );
      final List<HoldingRow> rows = envelope.rows
          .map(HoldingRow.fromJson)
          .toList();
      expect(rows, hasLength(6));
      final int withPnl = rows.where((HoldingRow r) => r.pnl != null).length;
      expect(withPnl, 3, reason: '보유현황 픽스처의 손익 건수가 인벤토리 §8-2(3건)와 다르다.');
      expect(
        rows.where((HoldingRow r) => r.pnl == null),
        isNotEmpty,
        reason: 'pnl 은 nullable 이어야 한다 — 없는 것을 0 으로 만들지 않는다.',
      );
    });

    test('C-6 손익 타입은 여전히 계약에 있다(격리이지 삭제가 아니다)', () {
      final Map<String, String> bodies = _freezedBodies();
      for (final String type in _pnlTypes) {
        expect(
          bodies.containsKey(type),
          isTrue,
          reason: '$type 이 계약에서 사라졌다 — C-6 은 «홈에서 격리»이지 «삭제»가 아니다.',
        );
      }
      // 손익을 싣는 자리는 보유현황 상세와 성과 화면이다.
      expect(bodies['HoldingRow'], contains('HoldingPnl'));
    });

    test(
      'C-6 홈·알림·위젯 위젯트리의 타입 참조 검사',
      () {},
      skip:
          'ui_shell·홈 위젯이 아직 없다. 계약 쪽 방벽(위 4건)은 «엔진이 안 준다»를 '
          '고정하고, 위젯트리 검사는 화면이 들어오는 PR 에서 채운다 — 둘 다 필요하다'
          '(화면은 다른 화면의 DTO 를 import 할 수 있다).',
    );
  });
}

Map<String, String> _freezedBodies() {
  final Map<String, String> out = <String, String>{};
  final RegExp re = RegExp(
    r'abstract class (\w+) with _\$\w+[^{]*\{(.*?)\n\}',
    dotAll: true,
  );
  for (final File f in dartSourcesIn(libDir)) {
    final String source = stripComments(f.readAsStringSync());
    for (final RegExpMatch m in re.allMatches(source)) {
      out[m.group(1)!] = m.group(2)!;
    }
  }
  return out;
}
