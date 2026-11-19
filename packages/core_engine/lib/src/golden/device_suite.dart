// 기기판 G-GV 실행기 목록(E11o · 설계 13 §8 R161 · R162 · R163).
//
// 🔴 전 계열 이식 전 = `complete` 거짓(R161 O5 — 부분 실행으로 «통과»를 말하지 않는다 · 앱은 «판정 보류»).
// 🔴 계열을 더할 때 = 옛 시험을 `runFamily` 로 바꾸고 `golden_runner_test` 의 케이스 수 표를 함께 고친다.

import 'golden_runner.dart' show GoldenFamily, GoldenSuite;
import 'gv_costs_calendar.dart' show Gv11Costs, Gv12Calendar;
import 'gv_orders.dart'
    show Gv13SubmitCount, Gv30SplitExecution, Gv8Sizing, Gv9Idempotency;
import 'gv_regime.dart'
    show Gv1RegimeScore, Gv2Indicators, Gv3ExposureGate, Gv4Hysteresis;

/// 🔴 기기판 G-GV 실행기 — 지금 = GV-1~4(E11o-a) · GV-8 · 9 · 11 · 12 · 13 · 30(E11o-b · 비용 계열에 19 · 24 포함).
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
], complete: false);
