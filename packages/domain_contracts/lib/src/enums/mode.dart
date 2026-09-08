// 01 §2-1 · §9(X6 모의투자) · §10(X7 투자 안내) — **직교하는 3축**(인벤토리 §2-2).
//
// 🔴 세 축은 서로를 대체하지 않는다:
//    `RunMode`        = 어느 계좌·어느 서버인가
//    `OperatingMode`  = 누가 주문을 집행하는가
//    `ExecPolicy`     = 엔진이 이번 배치에 바깥으로 무엇을 내보내는가
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-1 · §9-1 — X6 모의투자 모드의 축(Q-E).
///
/// ✅ 적대 검증 완료(2026-09-07 · §9-5)로 초안 지위 해제 · `m2-8_naming.md` A-3 확정.
/// 🔴 화면은 세 값을 개별 분기하지 말고 뷰모델이 준 라벨·배지를 그린다. 「모의냐」 판정이 꼭
///    필요하면 [RunModeIsSim.isSim] 만 쓴다(01 §2-1 주석 원문).
/// 🔴 화면은 이 값으로 타이틀 접두를 만들지 않는다 — 셸이 주입하고 C-17 이 강제한다.
/// ⚠️ 배치 A·B 의 기존 `CHECK (mode IN ('SIM','LIVE'))` 를 3값으로 넓히는 것은
///    **열린 물음**이다(인벤토리 §10-2 ② · `m2-8_naming.md` I-3 ⏸ = 3값 + 파일별 CHECK 권고).
enum RunMode {
  @JsonValue('SIM_INTERNAL')
  simInternal('SIM_INTERNAL'),
  @JsonValue('SIM_BROKER')
  simBroker('SIM_BROKER'),
  @JsonValue('LIVE')
  live('LIVE');

  const RunMode(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 — 「SIM 계열 = {simInternal, simBroker}」의 **유일한** 판정 창구.
///
/// 🔴 `default:` 없는 망라 switch 다 — 값이 늘면 컴파일이 깨진다(C-12 의 의도된 게이트).
extension RunModeIsSim on RunMode {
  bool get isSim => switch (this) {
    RunMode.simInternal || RunMode.simBroker => true,
    RunMode.live => false,
  };
}

/// 01 §9-5 ① · §10-1 — 「이번 배치가 어디까지 가는가」.
/// `m2-8_naming.md` A-4 확정.
///
/// 🔴 **`FeatureFlags` 에 넣지 않는다**(01 §2-1 조문) — 넣는 순간 화면이 3축을 곱해 분기한다.
/// 🔴 **3값으로 넓히지 않는다**(§10-1) — 넓히면 골든벡터 재검증 실패의 `dryRun` 강등이
///    발주자가 고른 운영 방식을 덮어써 지우고, 복구 시 원래 값을 알 수 없어 그림자 필드가
///    필요해지며, 그것이 §8-7 이 닫은 이중 정본의 부활이다.
/// ⚠️ 구 `order_intents.dry_run` 의 «이름만 바꾼 것»이며 **컬럼은 그대로 둔다**
///    (인벤토리 §10-2 ④ · `m2-8_naming.md` I-5 ⏸).
enum ExecPolicy {
  @JsonValue('DRY_RUN')
  dryRun('DRY_RUN'),
  @JsonValue('EXECUTE')
  execute('EXECUTE');

  const ExecPolicy(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 · §10-1(X7) — 「누가 주문을 집행하는가」.
///
/// 🔴 값을 바꾸는 유일한 경로는 M5 게이트(`M5-10`)·위저드(`M5-11`)다.
/// 🔴 **엔진의 어떤 안전 강등도 이 값을 건드리지 않는다** — 강등은 [ExecPolicy] 전용이다
///    (§9-5 ①③ · C-20 이 검사한다).
/// 🔴 화면은 이 값으로 문구를 고르지 않는다 — 라벨은 뷰모델, 접두·띠는 셸 주입(§10-5 · C-18).
enum OperatingMode {
  @JsonValue('AUTO_TRADE')
  autoTrade('AUTO_TRADE'),
  @JsonValue('ADVISORY')
  advisory('ADVISORY');

  const OperatingMode(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
