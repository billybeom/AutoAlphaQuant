// GV-40a 일간 · GV-40b 월간 · GV-40c 리밸런싱 경고 한도(AC-B28 27건 · 설계 13 §8 R166 · E3c).
//
// 정답지(vectors/SOURCES.md): gv40_saf_warn.json — 파일럿5 원본 통째 · 이 판은 a 12 · b 8 · c 7 을 본다(d · e = gv40d · gv40e 시험).
// 🔵 05 발주자 대기 세부(208 분모 · 205↔204 순서 · 306 산식) = 참조 생성기 판(엔진 `risk/warn_limits.dart` 머리말).
// 🔴 한 정본(E11o · R161) — 판정은 엔진 lib `Gv40aDailyWarn` · `Gv40bMonthlyWarn` · `Gv40cRebalanceWarn` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv40aDailyWarn());
  runFamily(const Gv40bMonthlyWarn());
  runFamily(const Gv40cRebalanceWarn());
}
