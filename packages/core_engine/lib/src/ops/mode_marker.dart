// 모드 표지 — OS 표면(알림 · 다이제스트) 제목 접두 · 표지 글자(설계 13 §8 R110 AO7 · 01 :3393 · 04 :309 · :379).
//
// 🔴 앱 안 화면은 셸 띠가 덮는다 — 이 접두를 `alertItemOf` 같은 앱 안 VM 에 걸지 않는다(이중 표지 · 픽스처 1:1).
// 🔴 `[모의]` 가 왼쪽 · `[안내]`(X7 투자 안내)와 함께 쓴다 · 실전 × 자동 매매 = 빈 글자.
// 🔵 글자는 엔진 상수(계약 상수 승격 = E15i 후보).

import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode, RunModeIsSim;

/// 모의 표지 글자.
const String kSimMarker = '모의투자';

/// 투자 안내(X7) 표지 글자.
const String kAdvisoryMarker = '투자 안내';

/// OS 알림 · 다이제스트 제목 접두 — `[모의]` · `[안내]` · `[모의][안내]` · 실전 × 자동 매매 = 빈 글자.
String alertOsTitlePrefix(RunMode run, OperatingMode op) =>
    '${run.isSim ? '[모의]' : ''}'
    '${op == OperatingMode.advisory ? '[안내]' : ''}';
