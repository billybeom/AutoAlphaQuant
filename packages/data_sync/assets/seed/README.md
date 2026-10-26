# 시드 — 동결 번들의 국면 부분집합(설계 13 §8 R23 D9 · R26 H2·H8 · E8c)

- 11파일 = `packages/core_engine/test/replay/data/` 의 같은 이름 파일과 **바이트가 같다**(E6 재현 번들 · 기준일 2026-08-14 ·
  발주자 2026-10-20 R3). 🔴 Yahoo 유래 데이터 포함 — 앱 자산 동봉은 발주자 2026-10-22 D9 결정.
- 고치지 않는다. 바꾸려면 번들(MANIFEST)과 `lib/src/market/seed_bundle.dart` `kSeedFiles` 의 sha256 을 함께 바꾸고
  `test/seed_bundle_test.dart` 가 참조 엔진 정답지와 다시 맞는지 본다.
- 앱에 싣는 일(자산 선언 · 첫 실행 적재)은 E11.
