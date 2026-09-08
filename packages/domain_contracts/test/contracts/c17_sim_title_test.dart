// C-17 (01 §7 · §9-3) — X6 «모의투자» 타이틀 전수.
//
// 문서가 요구하는 검사의 본체는 「`FeatureFlags.runMode` 가 SIM 계열인 픽스처로
// **모든 라우트**를 렌더 → 각 골든 스냅샷 텍스트에 «모의투자» 가 포함되는지」다.
// 라우트 테이블은 셸(`ui_shell`)에 있고 골든은 위젯 렌더라 이 패키지 안에서는 돌 수
// 없다 — 그 갈래는 아래에서 자리를 남기고 `skip` 한다(인벤토리 §9 C-17 = 🟡).
//
// 🔴 그러나 **입력이 없으면 그 검사는 나중에 «입력 없이 자동 통과»한다.** 그래서 이
//    파일이 지금 지키는 것은 두 가지다:
//    ① SIM 계열 판정 창구가 하나뿐이고 열거형 전수를 덮는가(01 §2-1 · `RunModeIsSim`)
//    ② SIM 계열 값을 실은 픽스처가 실재하는가(= C-17 이 렌더할 것이 있는가)

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

void main() {
  group('C-17 X6 모의 타이틀 (01 §7 · §9-3)', () {
    test('C-17 ① SIM 계열 판정 창구는 RunMode 전수를 덮는다 (01 §2-1)', () {
      // 🔴 화면이 「모의냐」를 판정하는 자리는 `isSim` 하나다. 값이 늘면 이 표가
      //    먼저 깨져야 하고, 그 자리에서 셸의 띠·접두를 함께 손보게 된다.
      final Map<RunMode, bool> expected = <RunMode, bool>{
        RunMode.simInternal: true,
        RunMode.simBroker: true,
        RunMode.live: false,
      };

      expect(
        expected.keys.toSet(),
        RunMode.values.toSet(),
        reason: 'RunMode 값이 늘거나 줄었다 — C-17 의 SIM 계열 정의를 함께 고칠 것.',
      );
      for (final RunMode mode in RunMode.values) {
        expect(mode.isSim, expected[mode], reason: '${mode.wire} 의 SIM 계열 판정');
      }
    });

    test('C-17 ② RunMode 의 JSON·DDL 표기는 3값이며 SIM 계열이 2값이다 (01 §9-1)', () {
      expect(RunMode.values.map((RunMode m) => m.wire).toList(), <String>[
        'SIM_INTERNAL',
        'SIM_BROKER',
        'LIVE',
      ]);
      expect(RunMode.values.where((RunMode m) => m.isSim).length, 2);
    });

    test('C-17 ③ FeatureFlags 가 runMode 를 필수로 싣는다 (01 §2-1)', () {
      // 🔴 셸이 띠·접두를 만들 근거는 이 필드 하나다. 필드가 사라지면 화면이 모드를
      //    다른 곳에서 유추하기 시작한다.
      const FeatureFlags flags = FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg_fake_0000000000000000',
      );

      final Map<String, dynamic> json = flags.toJson();
      expect(json['run_mode'], 'SIM_INTERNAL');
      expect(FeatureFlags.fromJson(json), flags);
    });

    test('C-17 ④ SIM 계열 값을 실은 픽스처가 실재한다 — C-17 의 입력', () {
      // 🔴 인벤토리 §10-2 ② ⓐ — 봉투 `meta.mode` 는 77 픽스처 전량 `LIVE` 지만
      //    **행 필드**는 다르다. 봉투만 보고 「SIM 픽스처가 없다」고 판정하면 안 된다.
      final Set<String> simWires = RunMode.values
          .where((RunMode m) => m.isSim)
          .map((RunMode m) => m.wire)
          .toSet();

      final List<String> carriers = <String>[];
      for (final String path in FixturePaths.all) {
        final bool hasSimRow = collectStrings(fixtureJson(path)).any(
          (({String path, String value}) e) =>
              e.path.contains('mode') && simWires.contains(e.value),
        );
        if (hasSimRow) {
          carriers.add(path);
        }
      }

      expect(
        carriers,
        isNotEmpty,
        reason: 'SIM 계열 행을 실은 픽스처가 하나도 없으면 C-17 은 입력 없이 통과한다.',
      );
      expect(carriers, contains(FixturePaths.journal30));
    });

    test(
      'C-17 ⑤ SIM 계열 픽스처로 전 라우트를 렌더해 «모의투자» 접두를 확인한다',
      () {},
      skip:
          'ui_shell 라우트 테이블과 위젯 골든이 선행한다(인벤토리 §9 C-17 = 🟡). '
          '라우트 표본이 아니라 전수여야 하므로 이 패키지 안에서 흉내 내지 않는다.',
    );
  });
}
