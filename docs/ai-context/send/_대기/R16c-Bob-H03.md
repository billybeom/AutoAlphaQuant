# 발송 패킷 R16c-Bob-H03 — H-03 물리 리스크 점검 상세 (계약 v1.17 전제 · R16 3장 중 3번째 · M8 · «정확히 N» 소유)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-11-04 조립 · 🆕 2026-11-05 v1.17 반영 재조립 · 앱 `rec/r16`) · 선행 = ① ⬜ R16b 병합(PR `__R16B_PR__` · squash `__R16B_SQ__` · 시작 기준 N = R16b 병합본 실측) ② ✅ **계약 v1.17 병합**(R16c 몫 = 12 §3 «R16 선행 M2 v1.17 이름표» #9·#10·#12·#13 · 01 §8 미결 123 계약 ✅ · R16a 와 같은 PR — 가지 `m2/v117-r16` `f4b51ca` → PR #123 · `'1.17.0'` · squash `0249f61` · 2026-11-05 · CI 3/3 · ✅ 발주자 결정 2026-11-04 · 아래 «■ 계약 v1.17 이름표» = v1.17 실제 글자 · ~~▶ 금지~~ ✅ 병합) ③ ✅ 누적 드라이런 3번째(흉내 위 반영판 · 아래 «드라이런» 줄) · ✅ 누적 재드라이런·지적 반영(2026-11-05 · v1.17 실물 위 · 가지 `dry/r16v2-3` 반영판 `c1c9eca` · 시작 456 → +472) ④ ✅ 발주자 확인 ①~⑨ 확정(2026-11-04) ⑤ ⬜ 「푸시해」 — 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 순서대로(R16a → R16b → R16c · 결정 ①) — «정확히 N» = 이 카드.
> 만든 날 2026-11-04 · 원문 = 12 §3 `R16-Bob-M8d` 행(🔀 3분할 — R16c 하위 행) + §3-0 + §3 공통 조문 + 이월 부록 «R16» 대상 · 화면 몫 원본 = `04_…` §4-6 «블록 9 물리 리스크 카드» · 그림 8(`H-03` 상세 — 저장공간 임계 · 로그 로테이션 · 배터리 열화 · OS 보안 지원 종료일 · 항목별 현재값·임계·조치·마지막 점검 시각 · «비상 복구가 아니라 계획 교체» 안내 = 엔진 문구 · 로그 정리·백업 실행 버튼 = M9 삽입 자리 · 없으면 비움) · §2-5(H-03 = Android 에서만) · §2-3(조회 화면 asOf · 오래됨) · `01_…` §8 미결 123 · 127 · 판독 메모 §6 G5 · 🆕 v1.17 재조립(2026-11-05) 원본 = 설계서 `10_리뷰/2026-11-04_R16선행_계약v1.17_설계서.md` §3 K17·K18·K24 · §5-3 · §8 · 01 §26 · M2 가지 `m2/v117-r16` `f4b51ca` 코드.
> 사전 조건 — ⬜ R16b 병합(`__R16B_SQ__` · `ui_shell` = 라벨 37 · 배럴 22 · 주입 23 · PNG 88 — ⟦실측: R16b 병합본 · 앞 카드 병합 기록 때 채움 — 드라이런 기대 그대로⟧) · ✅ 계약 v1.17 병합(R16c 몫 · PR #123 `0249f61`). 시작 기준 = **⟦실측: R16b 병합본 — 앞 카드 병합 기록 때 채움⟧**(✅ 재드라이런 기대 456 = R16a 414 + R16b 42 · 실측 «00:24 +456» — R16b ⑨ asOf 갈래 +2 · 드라이런 3번째는 첫 판 흉내 451 위에서 쟀다) · 끝 기대 = N + **16**(✅ 드라이런 · 재드라이런 «00:24 +472» — 뷰 12 = `device_risk_board_test` · 골든 4 = `h03_*`).
> 🔀 **재분할 판정** — 새 줄 **9**(✅ 드라이런 — `device_risk_board_test` 8 · 골든 1) · lib **+111 / −0**(드라이런 — 새 1파일 110 · 배럴 +1 · 추정 +150~200 보다 적음) · 새 PNG **4** · 원천 **1**(`watchDeviceRisk`) → 임계 안 · 🔴 이 카드가 «정확히 N» 을 **소유**한다(R16 마지막 — 라벨 37 · 배럴 23 · 주입 23 · PNG 92).
> 카드 기본값(✅ 발주자 확인 ①~⑨ 확정(2026-11-04) = 카드 기본값 · 이름 = v1.17 실물): ⓐ 위젯 = `DeviceRiskBoard({super.key})`(`lib/src/device_risk_board.dart` · `ConsumerWidget` · W-01 `watchdog_board.dart` 꼴) ⓑ 원천 = 🆕 `OpsStatusRepository.watchDeviceRisk()`(`repositories/ops_repository.dart` · 추가형) → `DeviceRiskVm`(`dto/ops.dart`) · 주입 = 기존 `shellOpsStatusRepositoryProvider`(새 주입 0) · 쓰기 0 ⓒ 머리 = `ShellAsOfHeader` · 오래됨 = `ShellStaleBanner`(`observedAt + staleAfter < clock.nowUtc()` — W-01 꼴) · 행 = 항목마다 등급 아이콘 + 다섯 칸(이름 · 현재값 · 임계 · 조치 · 마지막 점검 — 전부 엔진 글자) · 빈 = `emptyLabel`(있으면) · 맨 아래 «계획 교체» 안내 = `guidanceText` ⓓ 조작 버튼(로그 정리·백업 실행) = 부재(M9 슬롯 이름 0) ⓔ 셸 가드 무변경(Android 전용 = 조립 앱 레지스트리가 iOS·웹에 본문을 주지 않는다 · 01 §8 미결 127 · R15 꼴) ⓕ H-01 블록 9 = 이 카드 밖(`ops_home.dart` 무변경) ⓖ 새 lib 파일 1 · 공용 2(배럴 +1 · `test/shell_fakes.dart` 끝 절) · 라벨 0 · Key 접두 `h03-` · 골든 2이름 4장(`h03_items` · `h03_empty`).
> 🔴 **카드 덮개 필수 문장(04 §4-6 · 그림 8)** — «항목 목록·순서·수 = 받은 그대로(저장공간·로그·배터리·OS 넷을 코드에 두지 않는다)» · «현재값·임계·조치·마지막 점검 시각 = 엔진 글자 — 화면이 비교·계산·남은 일수 0 · 등급 = level 로 아이콘·색만» · ««비상 복구가 아니라 계획 교체» 안내 = 엔진 문구 그대로» · «로그 정리·백업 실행 = M9 삽입 자리 — 이 판 = 부재(버튼 0)» · «셸·홈(H-01)·R13~R16b 파일·테스트·PNG 무변경».
> ✅ **확정(2026-11-04 · 발주자 · ① 3분할 + v1.17(엔진 D11 한 PR) 선행 · ② R16a ③~⑨ 권고대로 · ③ D-02·D-03 뷰어 노출 · ④ R16b ②④⑩ · R16c ③⑤ 권고대로 + R16b ⑨ live asOf 붙임)** — 발주자 확인 9건(아래 = 확정 글자) — ① = R16a ①(3분할 · 순서대로 — 이 카드 = 마지막) ② 원천 = 🆕 `OpsStatusRepository.watchDeviceRisk()`(`repositories/ops_repository.dart` · 추가형 · 받침대 `UnimplementedOpsStatusRepository` 6 → 7 · 기존 가짜는 상속이라 무변경) → `DeviceRiskVm{rows, guidanceText, emptyLabel?, asOf}` · `DeviceRiskItem{label, currentText, thresholdText, actionText, lastCheckedText, level}`(`dto/ops.dart` · 표본 `device_risk_items` = 5행 · 등급 5값 전수 — 드라이런: 4행 · BLOCKED 없음이면 blocked 갈래 모양 변이가 표본 동치) · 측정(저장공간·배터리·OS 지원 종료) = 플랫폼·엔진 몫 ③ Android 전용 = 셸 가드 무변경(조립 앱 레지스트리 · 01 §8 미결 127 · `AppRoutes.opsDeviceRisk` 본문 = Android operator 빌드만 — 06 `M4-12`) ④ 조작 버튼(로그 정리·백업 실행) = 부재(슬롯 이름 0 · 04 «없으면 비움» · 01 §8 미결 161) ⑤ H-01 블록 9 = R16c 밖(`ops_home.dart`·`homeOverrides` 무변경 · 다음 홈 손질 카드 · 미결 123 = 계약 ✅ · 렌더 ⬜) ⑥ asOf 머리 + 오래됨 배너(측정값 · 04 §2-3 · asOf 0 예외 밖 — 설계서 K20) · 시계 = `shellClockProvider` ⑦ «정확히 N» = 이 카드(라벨 37 · 배럴 23 · 주입 23 · PNG 92) ⑧ 골든 2이름 4장(`h03_items` · `h03_empty` · 04 에 이름 없음 · 카드가 지음) ⑨ 이월(«6» = R16a 표 꼴).
> 🔵 **판독 빈틈 → v1.17 권고 → ✅ v1.17 반영(G5 · 설계서 K17·K18 · 01 §26)**: `DeviceRiskItem` 계약 0(01 §8 미결 123) → ✅ `dto/ops.dart` `DeviceRiskItem`·`DeviceRiskVm` · `OpsStatusRepository.watchDeviceRisk()` · 표본 2(5행 · 등급 5값) · 라우트 0 → ✅ `AppRoutes.opsDeviceRisk = 'aaq://ops/device-risk'`(이 카드는 상수를 쓰지 않는다).
> 드라이런: ✅ 누적 3번째(2026-11-04 · 🔵 v1.17 **흉내** 위 — 실물 v1.17 표본 = 흉내 글자 그대로(설계서 §5-3 · dy 불변 기대) · 시작 N 만 R16b ⑨ 로 +2 → 재드라이런이 확인 · 가지 `dry/r16-3` = `dry/r16-2` 첫 판 끝 `955a9fe` → R16b 병합 기록 흉내 + v1.17 R16c 흉내 `56d2664` → 권장 4커밋(`dc7f813`·`9c5a61c`·`40fa46b`·`89931f8`) → 🆕 반영판 `236b9a6`(표본 5행 · H03-01 hasLength(5) · H03-05 InkWell 0)) · 시작 451 → 끝 467(N + 16) · 파일별 = board «+12» · h03 «+4» · 줄 9 · ⓡ 7 · ⓗ 1 · (전제) 3 · Key 8 · 정적(펼친 37줄) 147줄 · EXIT:1 24 · EXIT:0 13 · S05 = 0줄 · «정확히» T13 37 · T14 23 · T15 23 · T37 92 · T29 = ui_shell.dart 1/0 · shell_fakes 48/0 만 · 사전검사 ① 🔴 0·🟡 0 · ② h03_ 🔴 0·🟡 1(«덩어리로 셀 수 없어 대조하지 않았다» — h03_items) · 골든 dy h03_items 784(반영판 5행 · 첫 판 4행 660) · h03_empty 196(light = dark · 머리 dy 0.0) · name-status 10줄 · 커밋 4줄. 변이: 예고 20(짝·갈래 나눔) = 전부 KILLED · 참고 12 = 첫 판 KILLED 8 · SURVIVED 4(blocked 모양 맞바꿈 = 표본 동치 → 🆕 표본 5행으로 KILLED · 항목 이름 하드코딩 = 정적 T17·T23 · 빈 문장을 행 수로 = 정적 T11 · 안내 탭 링크 = 정적 S05·T04·T07) · 킬스위치 InkWell = 첫 판 골든·정적만 → 🆕 H03-05 InkWell 0 으로 뷰 테스트도 잡음. 🆕 ✅ 누적 재드라이런(2026-11-05 · v1.17 **실물** 위 · 가지 `dry/r16v2-3` = R16b 재드라이런 끝(= R16b 병합본 흉내) → 권장 4커밋 = 반영판 `c1c9eca` · 실물 표본 = 흉내 행 글자 그대로(바깥 meta as_of 만 다름)) · 시작 456 → +472(파일별 board «+12» · h03 «+4») · 줄 9 · lib +111/−0 · ⓡ 7 · ⓗ 1 · (전제) 3 · Key 8 · 정적(아래 37줄) 147줄 · EXIT:1 24 · EXIT:0 13 · S05 0줄 · «정확히» T13 37 · T14 23 · T15 23 · T37 92 · T29 = ui_shell.dart 1/0 · shell_fakes 48/0 만 · 사전검사 ① 🔴 0·🟡 0 · ② h03_ 🔴 0·🟡 1 · 골든 dy h03_items 784 · h03_empty 196(light = dark · 머리 0.0 · PNG 4장 = 드라이런 3번째와 바이트 같음) · name-status 10 · 커밋 4 · test:contracts 0 FAILED · 변이(분리 worktree · 38꼴): 예고 20(짝·갈래 나눔) = KILLED 20 · 참고 18 = KILLED 14 · 🔴 생존 분류 고침 — 정적·사람만 잡는 넷: 항목 이름·안내 글자 하드코딩(R05 넷 하드코딩 KILLED 는 5행 표본의 RangeError 덕 · 다섯 다 하드코딩하면 정적 T17·T23 만 · 안내 글자 = T17 만) · 빈 문장을 행 수로(T11 `.isEmpty`) · 늘 참 단언 + 아이콘 고정(H03-02 를 `isNotNull` + `find.byType(Icon)` findsWidgets 로 약화 = 뷰 테스트 통과 · 골든 h03_items · «5» grep 1·3 만 · 사전검사 🔴 0) · nullable 흐름 칸(골든 `_Flow.steps` nullable + `?.call` = 테스트·정적·사전검사 전부 통과 — «5» grep 2 만) · 안내 탭 링크 = 🆕 H03-05 InkWell 로 KILLED(첫 판 정적만) · else 없는 if = 사전검사 T1 🔴.
> ⟦펼침: R16b 병합 기록 때 — R16b(= R16a 펼침) 판 글자를 이 카드 수·이름·파일로(교훈 줄 · 규칙 7·8·10~15 · 보고 규칙 · ■ 골든 공통 · ■ 제출 · 정적 실행 꼴) · 🔴 그대로 옮기면 안 되는 글자(드라이런 — 이 화면은 조회 화면이다): 규칙 7 = «asOf 머리 = ShellAsOfHeader · 오래됨 = ShellStaleBanner(vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc()) — W-01 글자) · 시계 = shellClockProvider · 스피너 금지» · 규칙 8 길 = lib/src/device_risk_board.dart · 규칙 9 주입 읽기 = shellOpsStatusRepositoryProvider · shellClockProvider(shellLinkOpenerProvider 0) · 테스트 import = R16a 차례에서 'package:domain_contracts/testing.dart' 를 뺀다(이 카드 테스트는 RecordingLinkOpener 를 안 쓴다 — 남기면 unused_import · shell_fakes 만 쓴다) · ■ 제출 S05 = «S05 결과:» 다음 줄에 정확히 «없음»(기대 0줄 — 이 화면에 링크 없음) · ✅ 정적 37줄 = 아래 «■ 정적 묶음» 에 이미 실음(재드라이런 글자 · T11 밑동 = R16a 목록 + Platform|kIsWeb|setState|\.compareTo — R16b 의 configHash 류는 넣지 않는다) · 🔴 승격(R16b 병합 기록) 차례 = ① `git mv docs/ai-context/send/_대기/R16c-Bob-H03.md docs/ai-context/send/`(재드라이런: 승격 전엔 0단계 `ls send/R16c…` 실패 — 기대) ② 자리표시자 `__R16B_PR__`·`__R16B_SQ__`(✅ v1.17 squash 자리 = `0249f61` · 2026-11-05 v1.17 병합 기록이 채움) · 시작 N · 사전 조건 수 ③ 펼침(실행 꼴 · 규칙 · 보고 규칙 · ② 상자 · 질문 상자) ④ 꺼내기 범위·해시 잼 ⑤ 가벼운 확인⟧.

## 0. 한 줄 목적

`DeviceRiskBoard()` 가 `watchDeviceRisk()` 의 물리 리스크 항목(등급 아이콘 · 이름 · 현재값 · 임계 · 조치 · 마지막 점검 시각)과 «계획 교체» 안내를 받은 차례·글자 그대로 그리고(비교·계산 0 · 조작 버튼 0) asOf 머리·오래됨 배너를 붙이는 `H-03` 을 계약 v1.17 그대로 짓고, R16 공용 파일의 «정확히 N» 을 닫기.

## 1. 어디에 보내나

**IBM Bob** — **새 브랜치 `ui/m8-h03-device-risk`**(base = 최신 `origin/main` · `--no-track`) · PR 제목 = «[M8] H-03 물리 리스크 점검».

## 2. 보내기 전에 발주자가 할 것 🔴

⟦펼침: R16a «2» 와 같은 7걸음 — `R16c-Bob-H03` · `$env:TEMP\R16c-Bob-H03_submit.md` · 사전검사 ② 한 번(`h03_`) · `_완료/R16a*`·`R16b*` 를 붙여넣지 않음⟧

## 3. 붙여넣을 본문 — ````text 다음 줄(«R16c-Bob-H03 — 범위»)부터 닫는 ```` 직전 줄까지 그대로

---

````text
R16c-Bob-H03 — 범위: H-03 물리 리스크 점검 상세(DeviceRiskBoard() — asOf 머리 · 오래됨 배너 · 항목(등급 아이콘 + 다섯 칸) · 빈 문장 · «계획 교체» 안내) + 배럴 export 1줄 + 가짜 끝 절 · 🔴 «정확히 N» 소유(R16 마지막).
🔴 항목 목록·순서·수 = 받은 그대로 — 저장공간·로그·배터리·OS 넷을 코드에 두지 않는다 · 현재값·임계·조치·점검 시각 = 엔진 글자 · 비교·계산·남은 일수 0 · level = 아이콘·색만.
🔴 «비상 복구가 아니라 계획 교체» 안내 = guidanceText 그대로 · 로그 정리·백업 실행 버튼 0(M9 삽입 자리 · 이 판 = 부재).
🔴 셸(가드 포함)·홈(H-01 블록 9)·R13~R16b 파일·테스트·PNG 는 고치지 않는다 — Android 전용은 조립 앱 레지스트리 몫.
하지 않는 것: H-01 블록 9 · 셸 가드 · 측정 구현(플랫폼) · 새 주입 · 새 라벨 · domain_contracts·pubspec 수정 · 다른 ui_* · 내보내기·공유·인쇄.
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 13항).

■ 0단계 — 대상 확인
  git branch --show-current
  git status --short            ← 비어 있어야 합니다
  git fetch origin --prune
  git checkout --no-track -b ui/m8-h03-device-risk origin/main
  git grep -c "contractVersion = '1.17.0'" -- packages/domain_contracts/lib/src/contract_version.dart   ← «…contract_version.dart:1»(계약 v1.17 · PR #123 0249f61 병합본 실측 «:1» 2026-11-05)
  git grep -c "Stream<DeviceRiskVm> watchDeviceRisk();" -- packages/domain_contracts/lib/src/repositories/ops_repository.dart   ← «…ops_repository.dart:1»(v1.17)
  git grep -c "Stream<DeviceRiskVm> watchDeviceRisk()" -- packages/domain_contracts/lib/testing.dart   ← «…testing.dart:1»(v1.17 받침대 `UnimplementedOpsStatusRepository` 7메서드)
  git grep -c "abstract class DeviceRiskVm" -- packages/domain_contracts/lib   ← «…dto/ops.dart:1»(v1.17)
  git grep -c "abstract class DeviceRiskItem" -- packages/domain_contracts/lib   ← «…dto/ops.dart:1»(v1.17)
  git grep -c "static const String m8DeviceRiskItems =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart   ← «…fixture_paths.dart:1»(v1.17)
  git grep -c "class HandbookContents" -- packages/ui_shell/lib/src/handbook/handbook_contents.dart   ← «…:1»(R16b 병합)
  git grep -c "class WatchdogBoard" -- packages/ui_shell/lib/src/watchdog_board.dart   ← «…:1»(R14b · 읽기만 · 꼴 본보기)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md
  ls docs/ai-context/send/R16c-Bob-H03.md
  ls docs/ai-context/inbox/H03_questions.md
  ls packages/domain_contracts/fixtures/m8/device_risk_items.json   ← v1.17 표본
  ls packages/domain_contracts/fixtures/m8/device_risk_empty.json   ← v1.17 표본
  반대(없어야 함): ls packages/ui_shell/lib/src/device_risk_board.dart
  melos.bat bootstrap → melos.bat run build:gen → cd packages/ui_shell → flutter test ← 시작 기준 «⟦실측: R16b 병합본 — 앞 카드 병합 기록 때 채움 · 재드라이런 기대 +456(✅ 실측 · R16b ⑨ +2)⟧: All tests passed!» → cd ../..

■ 계약 v1.17 이름표 — R16c 몫(0단계가 확인한 것 · 🔴 코드가 정본 — 아래와 다르면 멈추고 질문 파일에 · ✅ v1.17 실제 글자 = M2 가지 `m2/v117-r16` `f4b51ca` → 병합 PR #123 squash `0249f61` · 설계서 §4-4·§4-5 · 01 §26)
  🆕 dto/ops.dart  DeviceRiskItem({required String label, required String currentText, required String thresholdText, required String actionText, required String lastCheckedText, required UiLevel level})
  🆕 dto/ops.dart  DeviceRiskVm({required List<DeviceRiskItem> rows, required String guidanceText, String? emptyLabel, required AsOf asOf}) · repositories/ops_repository.dart  OpsStatusRepository += Stream<DeviceRiskVm> watchDeviceRisk()(추가형 · testing.dart 받침대 7메서드) · AppRoutes.opsDeviceRisk = 'aaq://ops/device-risk'(라우트 64 → 69 · 이 카드는 상수를 쓰지 않는다)
  FixturePaths  m8DeviceRiskItems(rows 5 — 등급 5값 전수(v1.17 실물 차례 = watch · ok · act · info · blocked) · 항목 이름 = 엔진 글자 · emptyLabel null · asOf.staleLabel 있음 · kGoldenNowUtc 기준 신선) · m8DeviceRiskEmpty(rows 0 · emptyLabel non-null)
  🔴 쓰지 않는 것: watchWatchdog · watchDiagnostics · watchBackup(다른 화면) · SettingsActions · AppRoutes.opsDeviceRisk(링크 = 데이터) · Platform·kIsWeb.

■ 규칙 요약(이 카드 고유 — 나머지 = 펼침)
 1 고치는 곳 = packages/ui_shell + inbox/H03_questions.md 만. 새 파일 = lib/src/device_risk_board.dart · test/device_risk_board_test.dart · test/golden/h03_golden_test.dart · 새 PNG 4.
   공용 2파일 끝 절 더하기만: lib/ui_shell.dart export 한 줄(정렬 차례 — src/alerts/alert_detail.dart 뒤 · src/handbook/… 앞: src/device_risk_board.dart) · test/shell_fakes.dart 끝 R16c 절 · 🔴 shell_providers.dart 무변경(새 주입 0).
 2 값 = rows[i].label · currentText · thresholdText · actionText · lastCheckedText · emptyLabel · guidanceText · asOf.label · staleLabel 그대로 · 3 읽지 않는 필드: level(아이콘 switch 로만) · asOf.observedAt·staleAfter(오래됨 판정 식 한 곳만).
 5 산술·판정 0 — 허용 = null 여부 · UiLevel 5값 전수 switch · 오래됨 판정 식 한 줄(W-01 글자) · 🔴 행을 세거나·고르거나·정렬 0 · 임계 비교·남은 일수 0.
 6 switch = UiLevel 5(_levelLook) 하나 · default 0. 9 새 주입 0 · 데이터 1(_deviceRiskProvider) · 주입 읽기 = shellOpsStatusRepositoryProvider · shellClockProvider.
⟦펼침: 규칙 7·8·10~15 · 보고 규칙 — R16b 판 글자를 이 카드 수로(주석 금지 낱말 += 저장공간 · 배터리 · 로그 정리 · 백업 실행 · Platform)⟧

■ 프롬프트보다 이 카드가 이긴다 — 13항 (prompt_M8.md 183줄 판 v2)
 ① 2행·119행 → H-03 ② 113~118행 → 이 카드 = H-03 · D-01~D-03·B-01·B-02 = 병합됨 ③ 12~14행 → 추가 0 ④ 18~19행 «플랫폼 가드는 셸 한 곳» → 셸 가드도 무변경(레지스트리 · 미결 127) ⑤ 20~23행 → 그대로(오래됨 = Clock + asOf)
 ⑥ 24~31행 → 그대로(임계 비교·남은 일수 0) ⑦ 32~38행 → 라벨 0 · 빈 = emptyLabel 이 있으면 ⑧ 41~47행 → 그대로(로그 정리·백업 실행 = 삽입 자리 · 이 판 부재) ⑨ 87~105행 → ■ 제출 ⑩ 106~111행 → inbox/H03_questions.md
 ⑪ 127~128행 → ui/m8-h03-device-risk · «[M8] H-03 물리 리스크 점검» ⑫ 169~171행 «홈 블록 구성» → 홈(블록 9) = 이 카드 밖 ⑬ 172~182행 → ■ 제출 ② 상자 + 괄호

■ 화면 — H-03: ListView(padding: EdgeInsets.zero)[ ShellAsOfHeader(key: const Key('h03-asof'), asOf: vm.asOf) → (stale) ShellStaleBanner(key: const Key('h03-stale'), asOf: vm.asOf) →
   for (i, r) in rows.indexed Padding(key: ValueKey<String>('h03-row-$i'), Row(crossAxisAlignment: start)[ Icon(_levelLook(cs, r.level).$1, key: ValueKey<String>('h03-level-$i'), size: 24, color: _levelLook(cs, r.level).$2) · SizedBox(width: 12) ·
     Expanded(Column(crossAxisAlignment: start)[ Text(r.label) · Text(r.currentText) · Text(r.thresholdText) · Text(r.actionText) · Text(r.lastCheckedText) ]) ]) → (emptyLabel) Padding(key: const Key('h03-empty'), Text(empty)) → Padding(key: const Key('h03-guidance'), Text(guidanceText)) ]
 Row 정렬 = start · 아이콘 크기 = 24 · 여백 = 재량 · final ColorScheme cs = Theme.of(context).colorScheme; · _levelLook(ColorScheme cs, UiLevel l) 꼴(W-01 _checkLook 선례 · 드라이런).
 ■ 상태 표 — hasError → ShellErrorView(key: const Key('h03-fail'), onRetry: () { ref.invalidate(_deviceRiskProvider); }, lastAsOfLabel: risk.valueOrNull?.asOf.label) · 값 전 → const ShellSkeleton(key: Key('h03-loading')) · 값 → 위 나무(W-01 꼴 · 드라이런).
■ Key 표 (h03- 8 — ✅ 드라이런 8) — h03-loading · h03-fail · h03-asof · h03-stale · h03-row-$i · h03-level-$i · h03-empty · h03-guidance
■ 할 일 — (1) lib 한 파일 + 배럴 «[M8] R16c (1) H-03 화면» (2) fakes + 테스트 «[M8] R16c (2) H-03 테스트» (3) 골든 «[M8] R16c (3) 골든 h03_* 4장» (4) «[M8] R16c (4) format · 질문» · 커밋 제목 = 내용(C4r15c-3).
■ 정적 라벨 — 0개(🔴 «정확히» 37).

■ 테스트 최소 목록 (✅ 드라이런 — 수 = 실측)
 공통: test/shell_fakes.dart 끝 절 «// ── R16c — H-03 fakes ──» = class FakeShellDeviceRiskRepository extends UnimplementedOpsStatusRepository(deviceRisk 공장 · deviceRiskCalls) · deviceRiskOverrides({ops, clock}) · deviceRiskAllowed(DeviceRiskVm v) ·
   pumpDeviceRiskBoard(tester, {required overrides}) = 기존 R16a _pumpIncidentBody(tester, overrides: overrides, body: const DeviceRiskBoard()) 재사용(같은 파일 private · 기존 줄 수정 0 — 끝 절 더하기만 · 드라이런 shell_fakes 48/0).
 H-03 — test/device_risk_board_test.dart(줄 8 · 테스트 12 계획)
 H03-01 행 차례·글자(items · ⓗ expect(items.rows, hasLength(5))) → 행마다 shownTexts(h03-row-$i) == [label, currentText, thresholdText, actionText, lastCheckedText] · 사슬 dy h03-asof → h03-row-0 … h03-row-4 → h03-guidance · ValueKey<String>('h03-row-5') findsNothing(받은 수 뒤 행 0) · 맨 아래 h03-guidance == [guidanceText] · h03-empty findsNothing · ⓡ.
 H03-02 등급 → 아이콘·색(🔴 테스트 하나 · 행 루프 — 경우 for 아님 · 표본 5행 = 등급 5값 — C4r15c-2 · 전제 = 등급 둘 이상 섞임 // pre) → 행마다 ValueKey<String>('h03-level-$i') icon · color == wantLevel(cs, level) · ⓡ.
 H03-03 빈 = emptyLabel(데이터 · empty · 전제 둘(rows isEmpty · emptyLabel isNotNull // pre) · h03-row-0 findsNothing · 양성 기준점 h03-empty · h03-guidance 그대로) · ⓡ.
 H03-04 asOf 머리 · 오래됨 두 경우(fresh = h03-stale findsNothing(양성 기준점 h03-asof) · stale = clock 을 staleAfter 너머로 → h03-stale findsOneWidget) · ⓡ.
 H03-05 조작 버튼 0 · 버튼 수 = 0(C4r15d-1 · ButtonStyleButton findsNothing · IconButton findsNothing · 🆕 InkWell findsNothing(이 화면에 탭 자리 0 — 드라이런: 킬스위치를 InkWell + 아이콘으로 지은 변이를 뷰 테스트가 잡음) · 두 경우 items · empty) · ⓡ.
 H03-06 상태 갈래 두 경우 · H03-07 재시도 · ⓡ · H03-08 화면 Text 전부 · 큰 글꼴 두 경우 · ⓡ.
🔴 예고 변이: 행 하나 빼기 · 뒤집기 · 등급 아이콘 고정(아이콘 · 색) · 다섯 칸 중 하나 빼기 · 안내 빼기·위로 · 빈 문장 대신 정적 글자 · 오래됨 배너 빼기·늘 그리기 · 조작 버튼 더하기(엔진 글자 재사용) · 임계 비교로 색 고르기 · 에러를 스켈레톤 · 재시도 invalidate 0 ·
   🔵 참고(✅ 재드라이런 · 18꼴 = KILLED 14) — 정적·사람만 잡는 넷: 항목 이름·안내 글자 하드코딩(다섯 이름 전부 = 정적 T17·T23 · 안내 = T17 — 넷만 하드코딩하면 5행 표본에서 RangeError 로 죽을 뿐) · 빈 문장을 행 수로(T11 `.isEmpty`) · 늘 참 단언 + 아이콘 고정(골든 h03_items · «5» grep 1·3) · 골든 흐름 칸 nullable(«5» grep 2 만) · 나머지 KILLED(blocked 모양 맞바꿈 = 표본 5행 · 킬스위치 InkWell · 안내 탭 링크 · 행 안 InkWell = H03-05 · 기기 시계로 오래됨 판정 = H03-04 fresh · else 없는 if = 사전검사 T1).

■ 정적 묶음 — 아래 37줄(✅ 재드라이런 실측 글자 · 머리 «## T01» ~ «## T37» · T05 자리 = «## S05» · T08·T10·T12·T28 = 번호만(EXIT:1) · 🔴 T13 «37» · T14 «23» · T15 «23» · T37 «92» = «정확히»(머리에 수) · 출력 줄 수(EXIT 줄 포함) = 147 · EXIT:1 = 24 · EXIT:0 = 13 · ⟦펼침: 실행 꼴(파일로 꺼내 Git Bash · 꺼내기 줄 · 해시 · EXIT 확인 · ② 에 붙이기) = R16b(= R16a) 글자를 이 카드 이름(r16c_static.sh)으로 · 꺼내기 범위·해시 = 승격 때 잼⟧)
echo "## T01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/device_risk_board_test.dart test/golden/h03_golden_test.dart; echo "EXIT:$?"
echo "## T02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/device_risk_board_test.dart test/golden/h03_golden_test.dart; echo "EXIT:$?"
echo "## T03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/device_risk_board_test.dart test/golden/h03_golden_test.dart; echo "EXIT:$?"
echo "## T04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://|'https?://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/device_risk_board.dart; echo "EXIT:$?"
echo "## T06 source lines (1)"; git grep -nE "watchDeviceRisk\(" -- lib/src/device_risk_board.dart; echo "EXIT:$?"
echo "## T07 commands and other sources 0"; git grep -nE "SettingsActions|CommandApi|watchWatchdog|watchConnections|watchDeviceAccess|watchBackup|watchDiagnostics|watchAnnualReview|shellLinkOpenerProvider|Platform|kIsWeb" -- lib/src/device_risk_board.dart; echo "EXIT:$?"
echo "## T08 (unused)"; echo "EXIT:1"
echo "## T09 UiLevel arms (5)"; git grep -nE "UiLevel\.(ok|info|watch|act|blocked) =>" -- lib/src/device_risk_board.dart; echo "EXIT:$?"
echo "## T10 (unused)"; echo "EXIT:1"
echo "## T11 forbidden words in new file 0"; git grep -nE "AppRoutes|AppLinkSchemes|m5KillSwitch|DateTime\.now|Duration|\.length|\.where\(|\.sort|\.take\(|\.isEmpty|\.isNotEmpty|\.every\(|\.any\(|TextField|print\(|Dismissible|onDismissed|SharedPreferences|IconButton|Platform|kIsWeb|setState|\.compareTo" -- lib/src/device_risk_board.dart; echo "EXIT:$?"
echo "## T12 (unused)"; echo "EXIT:1"
echo "## T13 shell labels (37)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## T14 barrel exports (23)"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## T15 shell providers (23)"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## T16 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## T17 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## T18 figures 0"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05|2\.75|22\.5)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## T19 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## T20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/device_risk_board_test.dart; echo "EXIT:$?"
echo "## T21 H lines (hasLength)"; git grep -c "hasLength(" -- test/device_risk_board_test.dart; echo "EXIT:$?"
echo "## T22 h03 key names"; git grep -noP "h03-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/device_risk_board.dart; echo "EXIT:$?"
echo "## T23 banned vocabulary in code 0"; git grep -nE "권장|추천|권유|자문|시그널|대부분|건너뛰|닫기|다시 보지|숨기기|인쇄|공유|저장|일단|해외|접기|펼치기|배터리|로그 정리|백업 실행" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## T24 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## T25 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib; echo "EXIT:$?"
echo "## T26 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## T27 Scaffold AppBar Navigator in new file 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/device_risk_board.dart; echo "EXIT:$?"
echo "## T28 (unused)"; echo "EXIT:1"
echo "## T29 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/src/shell_providers.dart lib/src/routing lib/src/shell_scaffold.dart lib/src/handbook lib/l10n/labels.dart lib/src/onboarding lib/src/common lib/src/incident lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts lib/src/watchdog_board.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/alert_center_test.dart test/alert_detail_test.dart test/watchdog_board_test.dart test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/onboarding_finish_test.dart test/onboarding_restart_test.dart test/viewer_pairing_test.dart test/golden/s01_golden_test.dart test/golden/h01_golden_test.dart test/golden/h02_golden_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart test/golden/w01_golden_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart test/golden/o04_golden_test.dart test/golden/r01_golden_test.dart test/golden/v01_golden_test.dart test/golden/d01_golden_test.dart test/golden/d02_golden_test.dart test/golden/d03_golden_test.dart test/handbook_contents_test.dart test/handbook_page_view_test.dart test/golden/b01_golden_test.dart test/golden/b02_golden_test.dart; echo "EXIT:$?"
echo "## T30 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/device_risk_board_test.dart test/golden/h03_golden_test.dart; echo "EXIT:$?"
echo "## T31 copyWith in tests 0"; git grep -n "copyWith(" -- test/device_risk_board_test.dart test/golden/h03_golden_test.dart; echo "EXIT:$?"
echo "## T32 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/device_risk_board_test.dart test/golden/h03_golden_test.dart; echo "EXIT:$?"
echo "## T33 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## T34 precondition marks (pre)"; git grep -c "// pre$" -- test/device_risk_board_test.dart; echo "EXIT:$?"
echo "## T35 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/device_risk_board_test.dart; echo "EXIT:$?"
echo "## T36 input print share widgets in new file 0"; git grep -niE "textfield|textformfield|editabletext|secretfield|url_launcher|launchUrl|printing|share_plus|path_provider|file_picker|pdf" -- lib/src/device_risk_board.dart; echo "EXIT:$?"
echo "## T37 golden PNG total (92)"; git ls-files -- "test/golden/goldens/*.png" | wc -l; echo "EXIT:$?"
  (줄의 뜻과 기대(✅ 재드라이런 실측) — T01·T02 = 0 · T03 = 2줄(device_risk_board_test 8 · golden/h03_golden_test 1 = 9) · T04 = 0 · S05 = 0줄(EXIT:1 — 이 화면에 링크 없음) · T06 = 1 · 🔴 T07 = 0(R16a 글자의 OpsStatusRepository 는 뺐다 — 이 화면이 그 창구를 정당하게 읽는다 · 드라이런) · T08 = 번호만 · T09 = 5줄(UiLevel 5) · T10 = 번호만 · T11 = 0 · T12 = 번호만 ·
   🔴 T13 «lib/l10n/labels.dart:37» · T14 = 23줄 · T15 = 23줄(정확히) · T16~T19 = 0 · T20 = 한 줄(device_risk_board_test 7) · T21 = 한 줄(1) · T22 Key 이름 8 · T23 = 0(🆕 += 배터리|로그 정리|백업 실행 — «저장공간» 은 밑동 «저장» 이 이미 잡는다) · T24~T27 = 0 · T28 = 번호만 ·
   🔴 T29 = 두 줄(lib/ui_shell.dart 1 0 · test/shell_fakes.dart 48 0 — shell_providers.dart · ops_home.dart · routing · R16a·R16b 파일 줄 0) · T30~T32 = 0 · T33 PNG 4줄 «A» · T34 = 한 줄(3) · T35·T36 = 0 · 🔴 T37 «92»(정확히 · 총수))
■ 골든 — 2이름 × light/dark = 4장(크기 kGoldenPhoneSize · 시계 = FixedClock(kGoldenNowUtc) · 높이 확장 ⓐ~ⓔ = R16a 글자)
    이름         입력     흐름    맨 아래 Key            머리 Key
    h03_items    items    없음    Key('h03-guidance')    Key('h03-asof')    dy 784.0(반영판 5행)
    h03_empty    empty    없음    Key('h03-guidance')    Key('h03-asof')    dy 196.0
  (dy = 드라이런 기대 · light = dark · 머리 dy 0.0 · 셈 단위 견본(light) = h03_items «글자 1줄 → 아이콘 · 글자 5줄 → 아이콘 · 글자 5줄 → 아이콘 · 글자 6줄 → 아이콘 · 글자 6줄 → 아이콘 · 글자 5줄 → 글자 3줄 — 잘림 없음» · h03_empty «글자 1줄 → 글자 2줄 → 글자 3줄 — 잘림 없음»)
■ 질문 파일 — H03_questions.md · 접두 «H-03:» · 측정 행 상자 2줄(A1 h03_items · A2 h03_empty · 꼴 = R16a 상자 글자 그대로 · ⟦펼침⟧).
■ 제출 — ⟦펼침: R16b 판 ■ 제출 글자를 이 카드로(사전검사 ② = h03_ --goldens 4 · ① 머리 «화면 ID: H-03 — 물리 리스크 점검 상세(DeviceRiskBoard())» · ② 괄호 10줄 · ③ 견본(«H-03 정상» · «H-03 로딩·에러») · S05 결과 = 정확히 «없음» ·
   파일별 끝 줄(드라이런·재드라이런 기대) = board «00:00 +12» · h03 «00:00 +4» · 끝 = N + 16 · name-status 10줄 · 커밋 4줄 · 🟡 기대 h03_ 1(h03_items «덩어리로 셀 수 없어 대조하지 않았다») · 🆕 ③ 견본 2줄(✅ 재드라이런 — 코드 배치와 같음 · 승격 때 이 글자 그대로): «H-03 정상» = ListView → ShellAsOfHeader(Key('h03-asof')) → ShellStaleBanner(Key('h03-stale'))(있을 때) → ValueKey<String>('h03-row-$i')(있을 때 · 안에 ValueKey<String>('h03-level-$i')) → Key('h03-empty')(있을 때) → Key('h03-guidance') / «H-03 로딩·에러» = ShellSkeleton(Key('h03-loading')) · ShellErrorView(Key('h03-fail')) · 🆕 ② 붙일 괄호(✅ 재드라이런 모의 제출 · 승격 때 R16a «붙일 괄호» 꼴로): 1 = «정적 묶음 T16 — 허용 밖 import 0줄 · T36 입력·인쇄·공유 패키지 0 · pubspec 무변경(T29)» · 2 = «산술 = null 여부 · UiLevel switch 하나(T09) · 오래됨 판정 식 한 줄(W-01 꼴) · 임계 비교·남은 일수·행 수 계산 0(T11) · 수치 리터럴 0(T18·T19)» · 3 = «DateTime.now 0(T11) · 시계 = shellClockProvider» · 4 = «이 카드 범위 밖(5탭·홈 블록 9·F-01) · 손익 0» · 5 = «이 카드 범위 밖(알림 = R14) · 등급 = 받은 level 로 아이콘·색만(H03-02)» · 6 = «이 카드 범위 밖(DND UI = M9)» · 7 = «이 카드 범위 밖(워치독 = R14b)» · 8 = «시크릿 입력 0 · 입력 위젯 0(T36) · 로컬 상태 0(T11 setState 0)» · 9 = «이 카드 범위 밖(온보딩 = R15)» · 10 = «킬스위치·게이트 자리 0 · 조작 버튼 0(H03-05) · 앱 잠금 = 이 카드 범위 밖(M5)» · ⑤ = «없음»)⟧
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-h03-device-risk` · 커밋 권장 4 · lib 새 1 · 배럴 +1 · test 새 2 + fakes 끝 절 · PNG 4 · `H03_questions.md` A1~A2 · 🔴 «정확히 N» = 라벨 37 · 배럴 23 · 주입 23 · PNG 92 · 셸·홈 무변경.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R16c-Bob-H03 결과: 브랜치 ui/m8-h03-device-risk 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

## 5. 주의

- **5분 눈 검사**: 항목 넷 하드코딩 · 임계 비교·남은 일수 · 로그 정리·백업 버튼 · 셸 가드·`ops_home.dart` 손대기 · `Platform`·`kIsWeb`.
- 🔵 C4 사람 grep(R16a «5» 세 줄을 이 카드 테스트 파일로 · 셋 다 출력 0 이어야 · 🔴 반드시 돌린다 — 재드라이런: 늘 참 단언 + 아이콘 고정(R13) · 골든 흐름 칸 nullable(R15) = 사전검사 🔴 0 · 테스트 쪽 변이 판정 = 임시 커밋 위): `git grep -nE "findsWidgets|findsAtLeast" -- packages/ui_shell/test/device_risk_board_test.dart` · `git grep -nE "Function\(WidgetTester [A-Za-z_]*\)\?" -- packages/ui_shell/test/` · `git grep -nE "isNotNull\)" -- packages/ui_shell/test/device_risk_board_test.dart | grep -v "// pre$"` · 🔵 infra 후속 = 사전검사 T3 에 «Key·descendant 없는 find.byType(X) + findsWidgets/findsOneWidget» 꼴(12 §3 이월).
- 🔵 R16 마지막 카드 — 병합 기록이 R16 완료(🏁)를 적는다 · 다음 = 12 §6 큐(R6-Bob-M9a 이후) · R16 test-only 묶음(있으면).
- ⬜ 남은 표식 ⟦…⟧ — ✅ «v1.17» 이름표 표식 0(2026-11-05 · v1.17 실제 글자) · ✅ «실측: 재드라이런» 채움(2026-11-05 · `dry/r16v2-3` `c1c9eca`) · 남은 «실측» = R16b 병합본 몫(시작 N · 사전 조건 수) · «펼침»(R16b 병합 기록 — ✅ 정적 37줄·③ 견본·② 괄호는 이미 실음 · 차례 = 머리 «펼침» 끝 ①~⑤) · ✅ v1.17 squash 자리표시자 → `0249f61`(2026-11-05 v1.17 병합 기록) · 자리표시자 `__R16B_SQ__` · `__R16B_PR__`(R16b 병합 기록이 채운다).
- 범위 고지: 01 §8 미결 123(블록 9 렌더 = 다음 홈 손질 카드) · 127(뷰어 가드 = 조립 앱) — 이 카드가 닫지 않는다.

## 6. R16 이월 반영 — R16a «6» 과 같은 표(H-03 자리)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r15c-1 «부재 쪽» 양성 기준점 | H03-03 · H03-04 fresh | — |
| C4r15c-2 상태 아이콘 icon·color | H03-02 · 예고 «등급 아이콘 고정» | — |
| C4r15d-1 버튼 수 = 받은 수 | H03-05(0) | — |
| C4r15d-2 데이터 칸 × 상태 조합 | H03-04(오래됨 × 행 있음) · H03-03(빈 × 안내) | 표본이 갖지 않는 조합 = 질문 파일 |
| C4r15b-2 · C4r15d-4 Row 정렬 · 아이콘 크기 | «화면» 아래 한 줄 | — |
| C4r15d-3 골든 높이 확장 ⓐ~ⓔ · 공통 교훈 · C4r15a-1 · C4r15c-3·-4·-6 · C4r15d-5 | ⟦펼침 — R16b(= R16a) 판 글자⟧ | — |
