// C-20 (01 §7 · §10-2 · §9-5 ①③) — advisory 주문 경로 봉인.
//
// 본체 3갈래(브로커 주문 호출 0건 · advisory 런타임에서 `ExecPolicy` 쓰기 0건 ·
// `operatingMode` 쓰기가 M5 게이트·위저드 커밋 경로 밖에 0건)는 엔진·`ui_*` 가
// 선행한다(인벤토리 §9 C-20 = 🟡).
//
// 🔴 계약 면에서 지금 봉인할 수 있는 것은 **«화면이 강등·모드 전환의 손잡이를 아예
//    쥐지 못하게 하는 것»** 이다:
//    ① `ExecPolicy` 가 `FeatureFlags` 에 없다(§10-1) — 있으면 화면이 3축을 곱해 분기한다
//    ② `operatingMode` 를 바꾸는 식별자가 `SettingsActions` 쪽에만 있고
//       `CommandKind`(명령 5+7종)에는 **없다** — 명령 큐로 모드를 바꿀 경로가 없다

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

void main() {
  group('C-20 X7 advisory 주문 경로 봉인 (01 §7 · §10-1)', () {
    test('C-20 ① FeatureFlags 는 ExecPolicy 를 싣지 않는다 (01 §10-1)', () {
      const FeatureFlags flags = FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.live,
        operatingMode: OperatingMode.advisory,
        configHash: 'cfg_fake_0000000000000000',
      );
      final Map<String, dynamic> json = flags.toJson();

      expect(
        json.containsKey('exec_policy'),
        isFalse,
        reason: '넣는 순간 화면이 RunMode×OperatingMode×ExecPolicy 를 곱해 분기한다.',
      );
      // 🔴 강등이 모드를 덮지 않게 — 화면이 보는 축은 둘뿐이다.
      expect(json.keys, contains('run_mode'));
      expect(json.keys, contains('operating_mode'));
    });

    test('C-20 ② ExecPolicy 는 2값이며 3값으로 넓히지 않는다 (§10-1)', () {
      // 🔴 넓히면 재검증 실패의 `dryRun` 강등이 발주자가 고른 운영 방식을 덮어써
      //    지우고, 복구 시 원래 값을 알 수 없어 그림자 필드가 필요해진다(§8-7 이 닫은
      //    이중 정본의 부활).
      expect(ExecPolicy.values.map((ExecPolicy p) => p.wire).toList(), <String>[
        'DRY_RUN',
        'EXECUTE',
      ]);
    });

    test('C-20 ③ operatingMode 를 바꾸는 경로는 SettingsActions 뿐이다 (B23)', () {
      // 🔴 값을 바꾸는 유일한 경로는 M5 게이트(`M5-10`)·위저드(`M5-11`)이고
      //    그 창구는 `SettingsActions` 다(§4-3). 명령 큐에는 그 종류가 없다.
      final Set<String> settingsWires = SettingsActionId.values
          .map((SettingsActionId id) => id.wire)
          .toSet();
      expect(
        settingsWires,
        containsAll(<String>[
          'ONBOARDING_OPERATING_MODE_SELECT',
          'RUNTIME_OPERATING_MODE_SWITCH_REQUEST',
          'HANDOVER_COMMIT',
        ]),
      );

      final Iterable<String> commandWires = CommandKind.values.map(
        (CommandKind k) => k.wire,
      );
      for (final String wire in commandWires) {
        expect(
          wire.contains('OPERATING_MODE'),
          isFalse,
          reason: '명령 큐로 운영 모드를 바꾸는 경로가 생겼다: $wire',
        );
        expect(
          wire.contains('EXEC_POLICY') || wire.contains('DRY_RUN'),
          isFalse,
          reason: '명령 큐로 집행 정책을 바꾸는 경로가 생겼다: $wire',
        );
      }
    });

    test(
      'C-20 ④ 강등 코드는 advisory 에서 suppressed 발행 경로를 부른다',
      () {},
      skip: '엔진 강등 함수(core_engine)가 선행한다(인벤토리 §9 C-20 = 🟡).',
    );

    test(
      'C-20 ⑤ advisory 런타임에서 브로커 주문 호출 0건',
      () {},
      skip: '엔진 런타임·브로커 어댑터가 선행한다 — 이 패키지에는 호출부가 없다.',
    );
  });
}
