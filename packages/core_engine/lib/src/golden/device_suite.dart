// 기기판 G-GV 실행기 목록(E11o · 설계 13 §8 R161 · R162 · R163 · R164).
//
// 🔴 전 계열 이식 전 = `complete` 거짓(R161 O5 — 부분 실행으로 «통과»를 말하지 않는다 · 앱은 «판정 보류»).
// 🔴 계열을 더할 때 = 옛 시험을 `runFamily` 로 바꾸고 `golden_runner_test` 의 케이스 수 표를 함께 고친다.

import 'golden_runner.dart' show GoldenFamily, GoldenSuite;
import 'gv_breaker.dart' show Gv31Breaker;
import 'gv_costs_calendar.dart' show Gv11Costs, Gv12Calendar;
import 'gv_gates.dart' show Gv40dStartup, Gv40eDiscretion;
import 'gv_limits.dart' show Gv32Limits;
import 'gv_orders.dart'
    show Gv13SubmitCount, Gv30SplitExecution, Gv8Sizing, Gv9Idempotency;
import 'gv_regime.dart'
    show Gv1RegimeScore, Gv2Indicators, Gv3ExposureGate, Gv4Hysteresis;
import 'gv_sleeves.dart'
    show Gv20SleeveSignals, Gv22SleeveC, Gv37CoreBandDeposit, Gv42Allocation;

/// 🔴 기기판 G-GV 실행기 — 지금 = GV-1~4(E11o-a) · GV-8 · 9 · 11 · 12 · 13 · 30(E11o-b · 비용 계열에 19 · 24 포함)
/// · GV-20(+23 · 38) · 22(+35 · 36) · 31(+s_h5_1 · 18) · 32(+39 · 17) · 37(+28d) · 40d · 40e · 42(E11o-c1).
/// 🔴 «전량» 표시(`complete`)는 E11o-c2 — `test/golden/` 밖 GV 몫 · 05 계열 처리 구분 대조 뒤.
const GoldenSuite kDeviceGoldenSuite = GoldenSuite(<GoldenFamily>[
  Gv1RegimeScore(),
  Gv2Indicators(),
  Gv3ExposureGate(),
  Gv4Hysteresis(),
  Gv8Sizing(),
  Gv9Idempotency(),
  Gv11Costs(),
  Gv12Calendar(),
  Gv13SubmitCount(),
  Gv30SplitExecution(),
  Gv20SleeveSignals(),
  Gv22SleeveC(),
  Gv31Breaker(),
  Gv32Limits(),
  Gv37CoreBandDeposit(),
  Gv40dStartup(),
  Gv40eDiscretion(),
  Gv42Allocation(),
], complete: false);
