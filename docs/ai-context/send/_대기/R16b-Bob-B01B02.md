# 발송 패킷 R16b-Bob-B01B02 — B-01 전략 핸드북 목차 · B-02 핸드북 페이지 (계약 v1.17 전제 · R16 3장 중 2번째 · M8)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-11-04 조립 · 앱 `rec/r16`) · 선행 = ① ⬜ R16a 병합(PR `__R16A_PR__` · squash `__R16A_SQ__` · 시작 기준 N = R16a 병합본 실측) ② ⬜ **계약 v1.17 R16b 몫**(12 §3 «R16 선행 M2 v1.17 이름표» #7·#8·#10·#12 — 아래 «■ 계약 v1.17 이름표» · R16a 와 같은 PR · ⬜ 발주자 결정 · ▶ 금지) ③ ✅ 누적 드라이런 2번째(반영판 · 아래 «드라이런» 줄) ④ ⬜ 발주자 확인 ①~⑫ ⑤ ⬜ 「푸시해」 — 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R16a 브랜치(`ui/m8-d01-incident`)는 건드리지 않는다.
> 만든 날 2026-11-04 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R16-Bob-M8d` 행(🔀 3분할 — R16b 하위 행) + §3-0 + §3 공통 조문 + 이월 부록 «R16» 대상(R16a «6» 과 같은 표) · 화면 몫 원본 = `04_…` §8(목차 8항목 · 10페이지 · ② 슬리브 A/B/C · ⑥⑦⑧ 원고 대기 = «준비 중» · 새틀라이트 장 = «보관됨» → 목차에서 접음 · 라이브 바인딩 «현재 상태» 블록 · config_hash 정합 게이트 → «설명이 규칙보다 뒤처졌습니다» 배너 + P1 · 숨김 옵션 0 · `ReasonChip.detailDeepLink` → 페이지 앵커 · 본문 손익·화면 숫자 0 · 그림 16) · §12 미결 15·16 · `01_…` §2-6(`HandbookIndex`·`HandbookPage`) · §7 C-13 · 판독 메모 §6 G4·G4b·G12·G9.
> 사전 조건 — ⬜ **R16a 병합**(`__R16A_SQ__` · `ui_shell` = lib 23파일 · 라벨 37 · 배럴 20 · 주입 22 · PNG 80 — ⟦실측: R16a 병합본 · 앞 카드 병합 기록 때 채움 — 드라이런 기대 그대로⟧) · ⬜ 계약 v1.17 R16b 몫. 시작 기준 = R16a 병합본의 `flutter test`(packages/ui_shell) = **⟦실측: R16a 병합본 — 앞 카드 병합 기록 때 채움⟧**(드라이런 기대 = R16a 반영판 414 · 드라이런 2번째는 R16a 첫 판 흉내 411 위에서 쟀다) · 끝 기대 = N + **40**(✅ 드라이런 — 뷰 32 = `handbook_contents_test` 14 + `handbook_page_view_test` 18 · 골든 8 = `b01_*` 2 + `b02_*` 6).
> 🔀 **재분할 판정** — 새 `testWidgets(`·`test(` 줄 **21**(✅ 드라이런 — `handbook_contents_test` 9 · `handbook_page_view_test` 10 · 골든 2 · 재시도 = 상태 갈래와 따로 한 줄) · lib **+271 / −2**(드라이런 — 새 2파일 252 · 공용·셸 +19 · 추정 +400~500 보다 적음) · 새 PNG **8** · 원천 **2**(`watchIndex` · `watchPage`) → 임계 안. 🔴 이 카드는 R13a 셸 코드 두 자리(`shell_router.dart` 핸드북 분기 · `shell_scaffold.dart` 웹 사이드바 다섯째 자리)를 고친다 = «끝 절 더하기만» 밖 — 허용 자리를 글자로 못박고 정적 T08·T29 로 본다.
> 카드 기본값(⬜ 발주자 확인 ①~⑫ 가 확정 · 조립 단계 = 권고 = 카드 기본값): ⓐ 위젯 = `HandbookContents({super.key})`(`lib/src/handbook/handbook_contents.dart` · B-01 · `ConsumerWidget`) · `HandbookPageView({super.key, required String anchor})`(`lib/src/handbook/handbook_page_view.dart` · B-02 · `ConsumerWidget`) — 🔴 계약 DTO 이름(`HandbookIndex` · `HandbookPage`)과 겹치지 않게 ⓑ 원천 = 🆕 `HandbookRepository.watchIndex()` → `HandbookIndex` · `watchPage(anchor)` → `HandbookPage` · 쓰기 0 ⓒ 주입 1 = 🆕 `shellHandbookRepositoryProvider`(`HandbookRepository?` · **기본값 null = 자리표시자** — 기존 TR-09 handbook · `s02-handbook-slot` 테스트가 이 주입 없이 그대로 돈다) · 두 위젯 = 주입 null 이면 `ShellPlaceholder()` ⓓ 셸 연결 = ① `shell_router.dart` `ShellRouteBody.build` 의 핸드북 분기 한 곳 — `KeyedSubtree(key: const Key('s01-handbook-slot'), child: HandbookPageView(anchor: <handbook:// 뒤 글자 전부>))` ② `shell_scaffold.dart` `_WebBody` 다섯째 자리 — `const KeyedSubtree(key: Key('s02-handbook-slot'), child: HandbookContents())` + 두 파일 import 각 한 줄 + 라우터 분기 위 주석 한 줄(«// 1. handbook 스킴 → 핸드북 페이지» — 옛 «→ 자리표시자» 를 고침) — 그 밖 셸 줄·테스트·PNG 무변경 · 앵커 추출 = 라우터 한 곳(화면은 받은 앵커를 인자로만) ⓔ B-01 = 받은 차례 · 항목 수 = 받은 수(8 리터럴 0) · 상태 = `state`(ready · preparing · archived — 아이콘·색만) + `stateLabel`(엔진 «준비 중»·«보관됨») · 탭 = `deepLink`(null = 탭 부재 — 준비 중) · ② 자식 = `children`(받은 차례 · 들여쓰기) · 보관됨 = 엔진이 자식 0 · 상태 글자로 보낸다(화면 접기 판정 0) ⓕ B-02 = 뒤처짐 배너(`outdatedNotice` · 숨김 0) → 제목 → 모르는 앵커(`missingLabel`) → 블록(`text` · 라이브 값 `live` = 라벨 + 등급 아이콘 · 블록 링크 = 블록 탭 `deepLink`) ⓖ config_hash 비교 0(엔진이 `outdatedNotice` 를 싣는다 — 04 §8 그림 16 정정) ⓗ asOf 머리·오래됨 배너 = 0(문서 콘텐츠 · R16a ⑨ 와 같다 · 🔴 live 블록 = 발주자 확인 ⑨ 갈림) ⓘ 새 lib 파일 2 · 공용 3(주입 1 · 배럴 +2 · `test/shell_fakes.dart` 끝 절 — 끝 절 더하기만) + 셸 2파일 허용 자리 · 라벨 0 · Key 접두 `b01-`·`b02-` · 골든 4이름 8장(`b01_index` · `b02_page` · `b02_outdated` · `b02_missing`) ⓙ 픽스처 = v1.17 `m8/handbook_index`·`handbook_index_outdated`·`handbook_page_sleeve_b`(개정)·`handbook_page_outdated`·`handbook_page_missing`·`handbook_page_archived`.
> 🔴 **카드 덮개 필수 문장(04 §8 · prompt_M8 155~157)** — «핸드북 문안은 전부 M2 — 화면은 블록을 받은 차례대로 그릴 뿐 원고를 쓰거나 요약하지 않는다 · 본문 숫자 리터럴 0» · «⑥⑦⑧ 원고 대기 = «준비 중» 행만(엔진 글자) — 본문을 대신 쓰지 않는다 · 장 이름 = VM 글자(카드·화면이 장 이름을 쓰지 않는다)» · «설명이 규칙보다 뒤처지면 = 엔진이 준 고지 그대로 맨 위 · **숨김·닫기 0** · 화면이 config_hash 를 비교하지 않는다» · «목차 항목 수·차례 = 받은 그대로 · 접기 = 엔진이 자식 0 으로 보낸다» · «셸 핸드북 자리 두 곳의 Key·바깥 상자 유지 · 주입 null = 자리표시자 그대로».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 요구 6(핸드북) · 01 §7 C-13(config_hash 메타) · 01 §8 미결 76·81(M7 사유 칩 핸드북 연결 = R16b 병합 뒤 풀리는 M7 후속 · 이 카드 몫 아님) · 139(N-02 핸드북 앵커 = R16 밖).
> ⬜ **발주자 확인 12건(권고 = 카드 기본값)** — ① = R16a ①(분할·선행·차례 한 문항) ② 원천 = 🆕 `HandbookRepository{watchIndex() · watchPage(anchor)}` · 주입 `Provider<HandbookRepository?>` 기본값 null(셸 자리표시자 그대로 · 기존 TR-09 handbook · `shell_scaffold_test` s02 테스트 무수정 · 🔴 위험 = R16a ④ 와 같은 꼴 — 조립 앱이 배선을 빠뜨리면 핸드북이 자리표시자로 남는다 → 조립 앱 override 필수 + 조립 테스트 1줄 · 이름표 #8) · 대안 = throw 기본값 + 기존 테스트 수정(비권고) ③ 목차 상태 = `HandbookEntry.state`(🆕 enum `HandbookEntryState` ready · preparing · archived) + `stateLabel?` · 링크 = `deepLink?`(null = 탭 부재 — 화면이 `handbook://$anchor` 를 짓지 않는다 · 규칙 ③) · ② 슬리브 = `children`(A·B·C + 새틀 보관됨) · 항목 수 = 받은 수 ④ config_hash 게이트 = 엔진 `outdatedNotice`(목차·페이지 둘 다 · 화면 비교 0 · 04 §8 그림 16 «FeatureFlags.configHash 일치» 를 v1.17 설계서에서 정정 · P1 알림 = 엔진) · 숨김 옵션 0 · 🆕 C-13(«한 봉투 안 config_hash 는 전부 같은 값») 과의 관계 = 권고 ⓐ 뒤처짐 표본도 config_hash = meta 와 같게 두고 «outdatedNotice = 엔진이 낸 판정 결과 글자 · 해시 대조 = 엔진 내부» 를 C-13 주석·01 §7 에 명문화 · 대안 ⓑ 핸드북 메타 칸 따로(예 `handbookConfigHash`) + C-13 에 «outdatedNotice non-null ⇔ 두 해시 다름» — 이름표 #7·#12 · 뒤처짐 고지 모양 = 고정(아이콘 `Icons.warning_amber_outlined` · 색 `cs.error` · 등급 칸 없음 — 🆕 조립 판 «info 아이콘 + error 색» 은 뜻이 어긋나 고침 · 대안 = `outdatedNotice` 를 `{text, level}` 로) ⑤ 모르는 앵커 = `HandbookPage.missingLabel`(블록 0) — 표본 링크 대부분(`rebalance/monthly` · `plan/deposit` · `advice/record` 등)이 목차 밖이라 필수 ⑥ 라이브 «현재 상태» = 🆕 `HandbookBlock.live: HandbookLiveValue?{label, level}`(값·라벨 = 엔진 · 등급 = 아이콘·색만) · 블록 링크 = `deepLink`(블록 탭 — 버튼 글자 없음) ⑦ 셸 연결 = 라우터 핸드북 분기 1곳 + 웹 사이드바 1곳(같은 Key 바깥 상자 · 주입 null = 자리표시자) · 앵커 추출 = 라우터(`handbook://` 뒤 글자 전부) · 폰 «더보기» = 이 카드 밖(목차 진입 = 데이터 링크 `aaq://handbook`) ⑧ 라우트 = v1.17 `AppRoutes.handbookIndex = 'aaq://handbook'`(B-01 · 셸 가드 기본 open · 본문 등록 = 조립 앱 · 이 카드는 상수를 쓰지 않는다) ⑨ asOf = 0(문서 콘텐츠 · R16a ⑨ 한 문항) · 🔴 **갈림(명세 지적 · 권고 변경 후보)**: `B-02` live «현재 상태» 블록은 지금 값을 보이므로 조회 화면이다 — 엔진이 멈추면 지난 국면 배지가 신선해 보인다(04 §2-3 «죽은 엔진은 push 하지 않는다») · 권고 = v1.17 `HandbookPage.asOf?`(live 블록이 하나라도 있으면 non-null — 엔진 의무) + `B-02` 가 asOf 가 있으면 `ShellAsOfHeader` · 오래됨이면 `ShellStaleBanner`(Clock 판정 한 곳) · 테스트 +2(fresh · stale) — 고르면 이 카드를 펼칠 때 재조립(R14·R15 선례) · 대안 = live 블록도 asOf 0(위험을 받아들임) · 지금 카드 글자 = 조립 판(asOf 0) ⑩ N-02 «관련 핸드북(B-02 앵커)»(01 §8 미결 139) = R16 밖(v1 부재 유지 · 넣으려면 v1.17 `AlertDetailVm.handbookLink?` + `alert_detail.dart` 수정 + `n02_*` 4장 — 비권고) ⑪ ⑥⑦⑧ 원고 = «준비 중» 행만 · prompt 155 «⑥ 세후 읽는 법» 이름 = VM 글자로 덮음(04 «세후 표기 규약» · 06 HB-1 «세후는 어떻게 읽나» — 이름 셋) ⑫ 골든 4이름 8장 · 라벨 0 · 새 주입 1 · 이월(«6» = R16a 표와 같은 자리).
> 🔵 **판독 빈틈 → v1.17 권고(판독 메모 §6 G4·G4b·G12)**: 창구 0 · 목차 상태 칸 0 · 항목 링크 0 · ② 계층 0 · 뒤처짐 문장 0 · 모르는 앵커 문장 0 · 라이브 블록 0 · 목차 라우트 0 · 04 그림 16 «화면 비교» ↔ `handbook.dart:4~5` «화면이 비교하지 않는다» 충돌 → #7·#8·#10·#12. HB-1~HB-3 원고 미작성은 선행 아님(표본 «준비 중» 행이면 충분).
> 드라이런: ✅ 누적 2번째(2026-11-04 · 가지 `dry/r16-2` = `dry/r16-1` 첫 판 끝 `a2fc8fc` → R16a 병합 기록 흉내 + v1.17 R16b 흉내 `78458f2` → 권장 4커밋(`1813d93`·`09681bd`·`e6f0dab`·`955a9fe`) → 🆕 반영판 = 표본 고침 `54c446a`(자식 1-1 deepLink ≠ handbook://<anchor>) + 카드 고침 `8579ca6`(B02-01 style 단언)) · 시작 411 → 끝 451(N + 40) · 파일별 = contents «+14» · page_view «+18» · b01 «+2» · b02 «+6» · ⓡ 8 · 9 · ⓗ 2 · 1 · (전제) 3 · 3 · Key 12 · 정적(펼친 37줄) 172줄 · EXIT:1 22 · EXIT:0 15 · 사전검사 ① 🔴 0·🟡 0 · ② b01_ 🔴 0·🟡 1 · b02_ 🔴 0·🟡 1(둘 다 «덩어리로 셀 수 없어 대조하지 않았다») · 골든 dy b01_index 744 · b02_page 348 · b02_outdated 248 · b02_missing 116(light = dark · 머리 dy 0.0) · TR-09 handbook · `s02-handbook-slot` · `s01_*` PNG 무수정 통과 · numstat shell_router 7/1 · shell_scaffold 5/1 · shell_providers 5/0 · ui_shell.dart 2/0 · shell_fakes 70/0 · name-status 20줄 · 커밋 4줄. 변이(C4r15a-2): 예고 33 = KILLED 31 · 정적만 2(configHash 를 읽되 표본 동치 = T11 · 블록 kind 로 글자 굵게 = T11 → 🆕 B02-01 style 단언으로 KILLED) · 첫 판 생존 «링크 대신 handbook://$anchor 조립» = 표본 동치(모든 deepLink = handbook://anchor) → 🆕 표본 조건 + B01-03 자식 경우로 KILLED · 참고 13 = KILLED 10 · SURVIVED 3(제목 폴백 = 정적 T11 · order 정렬 = 표본 동치 · 정적 T11 · live 등급 ok·info 맞바꿈 = 표본 없음 · T09 글자만).
> 프롬프트 = `prompt_M8.md`(v2 183줄 · «이긴다» 15항이 범위·낡은 줄을 덮음 · 재조립 0). 🔴 Bob **새 대화** 전제.
> ⟦펼침: R16a 병합 기록 때 — R16a 카드 «3» 의 교훈 줄 · 규칙 10·12~14 · «보고 규칙» · «■ 골든» 공통 줄 · «■ 제출» · 정적 실행 꼴을 이 카드의 수·이름·파일로 펼친다(R15 승격 꼴) · 아래 본문은 이 카드 고유 글자만 담았다 · 펼칠 때 넣을 수(드라이런 기대) = 정적 172줄 · EXIT:1 22 · EXIT:0 15 · name-status 20 · 커밋 4 · ⓡ 8·9 · ⓗ 2·1 · (전제) 3·3 · 🟡 b01_ 1 · b02_ 1 · 꺼내기 범위·해시 = 승격 판에서 잰다⟧.

## 0. 한 줄 목적

`HandbookContents()` 가 `watchIndex()` 의 목차(받은 차례 · 상태 아이콘·글자 · ② 자식 · 링크 = 데이터 · 뒤처짐 고지)를, `HandbookPageView(anchor:)` 가 `watchPage(anchor)` 의 페이지(뒤처짐 고지 · 제목 · 모르는 앵커 문장 · 블록 · 라이브 값 · 블록 링크)를 받은 글자 그대로 그리고, 셸 핸드북 자리 두 곳에 같은 Key 로 꽂는(주입 없으면 자리표시자 그대로) `B-01`·`B-02` 를 계약 v1.17 그대로 짓기.

## 1. 어디에 보내나

**IBM Bob** — **새 브랜치 `ui/m8-b01-handbook`**(base = 최신 `origin/main` · `--no-track` · 분할 뒤 새 이름 · ⬜ 발주자 확인 ①) · PR 제목 = «[M8] B-01·B-02 전략 핸드북».

## 2. 보내기 전에 발주자가 할 것 🔴

⟦펼침: R16a «2» 와 같은 7걸음 — 파일 이름 `R16b-Bob-B01B02` · 저장 파일 `$env:TEMP\R16b-Bob-B01B02_submit.md` · 사전검사 ② 두 번(`b01_` · `b02_`) · `_완료/R16a*` 를 붙여넣지 않음⟧

## 3. 붙여넣을 본문 — ````text 다음 줄(«R16b-Bob-B01B02 — 범위»)부터 닫는 ```` 직전 줄까지 그대로

---

````text
R16b-Bob-B01B02 — 범위: B-01 전략 핸드북 목차(HandbookContents() — 뒤처짐 고지 · 항목(상태 아이콘 · 제목 · 상태 글자) · ② 자식 · 탭 = 링크) ·
  B-02 핸드북 페이지(HandbookPageView(anchor:) — 뒤처짐 고지 · 제목 · 모르는 앵커 문장 · 블록(라이브 값 · 블록 탭 = 링크)) + 새 주입 1 + 배럴 export 2줄 + 셸 핸드북 자리 두 곳 + 가짜 끝 절.
🔴 문안 = 전부 M2 — 블록을 받은 차례대로 그리기만 · 원고·요약·장 이름 0 · 본문 숫자 리터럴 0(대조군·세후 층·기대치 전부 엔진 문자열).
🔴 ⑥⑦⑧ = 엔진이 보낸 «준비 중» 행만 — 본문을 대신 쓰지 않는다 · 항목 수·차례 = 받은 그대로(8 리터럴 0) · 보관됨 = 엔진이 자식 0 으로 보낸다(화면이 접기 판정 0).
🔴 뒤처짐 = outdatedNotice 그대로 맨 위 — 숨김·닫기 0 · 화면이 config_hash 를 비교하지 않는다(configHash 읽기 0).
🔴 셸 = shell_router.dart 핸드북 분기 한 곳 · shell_scaffold.dart 웹 다섯째 자리 한 곳 + import 각 한 줄만 — 같은 Key 바깥 상자 · 주입 null = 자리표시자 그대로 · 그 밖 셸·R13~R16a 파일·테스트·PNG 무변경.
하지 않는 것: D-01~D-03(R16a · 병합됨) · H-03(R16c) · N-02 핸드북 앵커 · M7 사유 칩 연결 · 폰 «더보기» 탭 · 조립 앱 배선 · asOf 머리 · domain_contracts·pubspec 수정 · 다른 ui_* · 내보내기·공유·인쇄(04 §2-1 금지 5).
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 15항).

■ 0단계 — 대상 확인
이 카드는 R16a(병합됨)가 아닙니다. 지금 코드에는 packages/ui_shell/lib/src/handbook/ 이 없습니다.
  git branch --show-current
  git status --short            ← 비어 있어야 합니다
  git fetch origin --prune
  git checkout --no-track -b ui/m8-b01-handbook origin/main
  git grep -c "contractVersion = '⟦1.17.0⟧'" -- packages/domain_contracts/lib/src/contract_version.dart   ← ⟦실측: «…:1»⟧
  git grep -c "Stream<HandbookIndex> watchIndex();" -- packages/domain_contracts/lib/src/repositories   ← ⟦v1.17⟧ «…:1»
  git grep -c "Stream<HandbookPage> watchPage(String anchor);" -- packages/domain_contracts/lib/src/repositories   ← ⟦v1.17⟧ «…:1»
  git grep -c "enum HandbookEntryState" -- packages/domain_contracts/lib   ← ⟦v1.17⟧ «…:1»
  git grep -c "abstract class HandbookLiveValue" -- packages/domain_contracts/lib   ← ⟦v1.17⟧ «…:1»
  git grep -c "String? outdatedNotice," -- packages/domain_contracts/lib/src/dto/handbook.dart   ← ⟦v1.17 «…:2»(목차 · 페이지)⟧
  git grep -c "String? missingLabel," -- packages/domain_contracts/lib/src/dto/handbook.dart   ← ⟦v1.17⟧ «…:1»
  git grep -c "List<HandbookEntry> children" -- packages/domain_contracts/lib/src/dto/handbook.dart   ← ⟦v1.17⟧ «…:1»
  git grep -c "class UnimplementedHandbookRepository" -- packages/domain_contracts/lib/testing.dart   ← ⟦v1.17⟧ «…:1»
  git grep -c "static const String m8HandbookIndex =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart   ← ⟦v1.17⟧ «…:1»
  git grep -c "Key('s01-handbook-slot')" -- packages/ui_shell/lib/src/routing/shell_router.dart   ← «…:1»(R13a · 이 카드가 고치는 자리)
  git grep -c "Key('s02-handbook-slot')" -- packages/ui_shell/lib/src/shell_scaffold.dart   ← «…:1»(R13a · 이 카드가 고치는 자리)
  git grep -c "class IncidentBannerSlot" -- packages/ui_shell/lib/src/incident/incident_banner.dart   ← «…:1»(R16a 병합)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md
  ls docs/ai-context/send/R16b-Bob-B01B02.md
  ls docs/ai-context/inbox/B01B02_questions.md
  ls packages/domain_contracts/fixtures/m8/<이름>   ← ⟦v1.17⟧ 아래 6 이름마다 한 줄씩 · 전체 경로로(이름만 쓰면 저장소 뿌리에서 못 찾는다 · 드라이런) · 전부 보여야 함:
     handbook_index.json · handbook_index_outdated.json · handbook_page_sleeve_b.json · handbook_page_outdated.json · handbook_page_missing.json · handbook_page_archived.json
  반대(없어야 함): ls packages/ui_shell/lib/src/handbook
  반대(없어야 함): git grep -c HandbookContents -- packages/ui_shell/lib
  melos.bat bootstrap → melos.bat run build:gen → cd packages/ui_shell → flutter test ← 시작 기준 «⟦실측: R16a 병합본 — 앞 카드 병합 기록 때 채움 · 드라이런 기대 +414⟧: All tests passed!» → cd ../..

■ 계약 v1.17 이름표 — R16b 몫(🔴 코드가 정본 · ⟦v1.17⟧)
  🆕 enum HandbookEntryState { ready, preparing, archived }   — 아이콘·색만
  HandbookEntry += HandbookEntryState state(기본 ready) · String? stateLabel · String? deepLink(null = 탭 부재) · List<HandbookEntry> children(기본 [])   — anchor · title · order 기존(🔴 order = 읽지 않는다 · 받은 차례가 정본)
  HandbookIndex += String? outdatedNotice · HandbookPage += String? outdatedNotice · String? missingLabel · HandbookBlock += HandbookLiveValue? live · 🆕 HandbookLiveValue({required String label, required UiLevel level})
  🆕 HandbookRepository { Stream<HandbookIndex> watchIndex(); Stream<HandbookPage> watchPage(String anchor); } · testing.dart = UnimplementedHandbookRepository · AppRoutes.handbookIndex(이 카드는 상수를 쓰지 않는다)
  FixturePaths  m8HandbookIndex(항목 8 = entries[0..7] · entries[1] = ② 자식 4(children[0..2] ready · children[3] archived «보관됨») · entries[5..7] = ⑥⑦⑧ preparing(deepLink null · «준비 중») · 🆕 children[1].deepLink ≠ handbook://<anchor>(예 handbook://sleeves/sleeve-b — 드라이런: 모두 같으면 «링크 대신 handbook://$anchor 조립» 변이가 표본 동치) · outdatedNotice null) ·
                m8HandbookIndexOutdated(outdatedNotice non-null) ·
                m8HandbookPageSleeveB(개정 — 블록 5 · blocks[1] live non-null · blocks[3] CAUTION · deepLink non-null · outdated null) · m8HandbookPageOutdated(outdatedNotice non-null · 블록 링크 있음) · m8HandbookPageMissing(blocks 0 · missingLabel non-null) · m8HandbookPageArchived(보관됨 «왜 없앴나» 한 단락)
  🔵 C-13: 뒤처짐 표본도 config_hash = meta 와 같게(권고 ⓐ — outdatedNotice = 엔진 판정 결과 · 해시 대조 = 엔진 내부 · C-13 주석·01 §7 명문화 · 발주자 확인 ④) · 목차 빈 상태 = 갈래 0(엔진 의무 «목차 항목 ≥ 1» — 이름표 #7) · 하위 앵커 = 페이지 머리 착지(v1 · 블록 스크롤·⑥ 갈래 접힘 = 01 §8 미결 신설 후보)
  🔴 쓰지 않는 것: configHash(읽기 0 — C-13 은 계약 테스트 몫) · order · FeatureFlags · AlertDetailVm · ReasonChip · AppRoutes 상수.

■ 규칙 요약(이 카드 고유 — 나머지 = 펼침)
 1 고치는 곳 = packages/ui_shell + inbox/B01B02_questions.md 만. 새 파일 = lib/src/handbook/handbook_contents.dart · handbook_page_view.dart · test/handbook_contents_test.dart · test/handbook_page_view_test.dart · test/golden/b01_golden_test.dart · b02_golden_test.dart · 새 PNG 8.
   공용 3파일 끝 절 더하기만: shell_providers.dart 끝 R16b 절(final Provider<HandbookRepository?> shellHandbookRepositoryProvider = Provider<HandbookRepository?>((Ref ref) => null);) · ui_shell.dart export 두 줄(정렬 차례 — src/alerts/alert_detail.dart 뒤 · src/incident/… 앞: src/handbook/handbook_contents.dart · src/handbook/handbook_page_view.dart) · test/shell_fakes.dart 끝 R16b 절.
   🔴 셸 2파일 허용 자리만: ① lib/src/routing/shell_router.dart — import 한 줄 + 분기 위 주석 한 줄(«// 1. handbook 스킴 → 자리표시자» → «// 1. handbook 스킴 → 핸드북 페이지») + ShellRouteBody.build «// 1. handbook 스킴» 분기의 return 한 문장(format 이 여러 줄로 나눈다 — 드라이런 numstat 7 1) → return KeyedSubtree(key: const Key('s01-handbook-slot'), child: HandbookPageView(anchor: link.substring('${AppLinkSchemes.handbook}://'.length)));
     ② lib/src/shell_scaffold.dart — import 한 줄 + _WebBody 다섯째 자리 const ShellPlaceholder(key: Key('s02-handbook-slot')) → const KeyedSubtree(key: Key('s02-handbook-slot'), child: HandbookContents())(드라이런 numstat 5 1) · 그 밖 줄 0(정적 T08 · T29).
   🆕 테스트 import = R16a 차례 + 'package:ui_shell/src/common/shell_common.dart'(ui_shell.dart 앞 · ShellPlaceholder 는 배럴 밖 — 없으면 Undefined name · ops_rhythm_test 선례 · 드라이런).
 2 값 = entries[i].title · stateLabel · children[j].title · stateLabel · outdatedNotice · title · missingLabel · blocks[i].text · live.label 그대로 · 3 읽지 않는 필드: deepLink(open 인자로만) · state(아이콘 switch 로만) · live.level(아이콘 switch 로만) · kind(🔴 블록 종류로 문구·모양 고르기 0 — 04 C-5) · order · configHash · anchor(목차 행에서 그리지 않는다).
 4 이동 = AppLinkOpener.open(link) — 링크 = entries[i].deepLink · children[j].deepLink · blocks[i].deepLink 셋뿐 · 'handbook://'·'aaq://' 리터럴 0(라우터 분기 한 곳은 기존 AppLinkSchemes 상수) · 🔴 화면이 '${…}://$anchor' 조립 0.
 5 산술·판정 0 — 허용 = null 여부 · HandbookEntryState 3값 · UiLevel 5값 전수 switch · 🔴 항목·자식·블록을 세거나·고르거나·«0 이면 문장» 0 · 접기·펼치기 상태 0(로컬 상태 0 · setState 0).
 6 switch = HandbookEntryState 3(_stateLook) · UiLevel 5(_liveLook) · 둘뿐 · default 0 · 아이콘 = 재량 · 색 = _liveLook 은 R16a _levelColor 표 · _stateLook 은 재량 · 테스트 머리 wantState · wantLive = lib 사본(드라이런: ready menu_book_outlined · primary / preparing hourglass_empty · onSurfaceVariant / archived inventory_2_outlined · outline).
 9 새 주입 1 · 데이터 2(_handbookIndexProvider · _handbookPageProvider(family)) · 두 위젯 = 주입 null 이면 const ShellPlaceholder()(프로바이더 watch 0).
⟦펼침: 규칙 7·8·10~15 · 보고 규칙 — R16a 판 글자를 이 카드 수·이름으로(ⓡ 8 · 9 · ⓗ 2 · 1 · (전제) 3 · 3 — 드라이런 · 주석 금지 낱말 += configHash · FeatureFlags · AppLinkSchemes · 숨기기 · 접기)⟧

■ 프롬프트보다 이 카드가 이긴다 — 15항 (prompt_M8.md 183줄 판 v2)
 ① 2행·119행 → B-01 · B-02 ② 113~118행 → 이 카드 = B-01·B-02 · H-03 = R16c ③ 12~14행 → 추가 0 ④ 15~19행 → 그대로(링크 = 데이터 · 앵커 추출 = 셸 라우터 한 곳) ⑤ 20~23행 → 시계 미사용 ⑥ 24~31행 → 그대로 ⑦ 32~38행 → 라벨 0
 ⑧ 68~70행 수치 리터럴 0 → 그대로(핸드북 본문 숫자 전부 엔진) ⑨ 82~84행 → 그대로 ⑩ 87~105행 → ■ 제출 ⑪ 106~111행 → inbox/B01B02_questions.md ⑫ 127~128행 → ui/m8-b01-handbook · «[M8] B-01·B-02 전략 핸드북»
 ⑬ 🔴 155행 «목차는 8항목 · ⑥ 세후 읽는 법 …» → 항목 수 = 받은 수(8 리터럴 0 · 표본도 8 이지만 세지 않는다) · 장 이름 = VM 글자(카드·화면이 장 이름을 쓰지 않는다 — 04 «세후 표기 규약» · 06 HB-1 과 이름이 다르다) ⑭ 155~157행 → 그대로(«준비 중» 자리만 · 본문 대신 쓰지 않음) ⑮ 172~182행 → ■ 제출 ② 상자 + 괄호

■ 화면 1 — B-01: ListView(padding: EdgeInsets.zero)[ (outdatedNotice) Padding(key: const Key('b01-outdated'), Row(crossAxisAlignment: start)[ Icon(Icons.warning_amber_outlined, size: 24, color: cs.error) · SizedBox(width: 12) · Expanded(Text(notice)) ]) →
   for (i, e) in entries.indexed ListTile(key: ValueKey<String>('b01-entry-$i'), leading: Icon(_stateLook(e.state).$1, key: ValueKey<String>('b01-state-$i'), size: 24, color: _stateLook(e.state).$2), title: Text(e.title), subtitle: e.stateLabel == null ? null : Text(e.stateLabel!), onTap: e.deepLink == null ? null : () { open(e.deepLink!); }) ·
     for (j, c) in e.children.indexed ListTile(key: ValueKey<String>('b01-entry-$i-$j'), contentPadding: 들여쓰기(재량), leading: Icon(_stateLook(c.state)…, key: ValueKey<String>('b01-state-$i-$j')), title: Text(c.title), subtitle: ?stateLabel, onTap: ?deepLink) ]
 ■ 화면 2 — B-02: ListView(padding: EdgeInsets.zero)[ (outdatedNotice) Padding(key: const Key('b02-outdated'), Row(start)[ Icon(Icons.warning_amber_outlined, size: 24, color: cs.error) · SizedBox(width: 12) · Expanded(Text(notice)) ]) → Padding(key: const Key('b02-title'), Text(title)) →
   (missingLabel) Padding(key: const Key('b02-missing'), Text(missing)) → for (i, blk) in blocks.indexed InkWell(key: ValueKey<String>('b02-block-$i'), onTap: blk.deepLink == null ? null : () { open(blk.deepLink!); }, child: Padding(Column(crossAxisAlignment: start)[
     (live) Row(key: ValueKey<String>('b02-live-$i'), crossAxisAlignment: start)[ Icon(_liveLook(live.level).$1, size: 24, color: _liveLook(live.level).$2) · SizedBox(width: 8) · Expanded(Text(live.label)) ] · Text(blk.text) ])) ]
 Row 정렬(C4r15b-2) = Row 셋 모두 start · 아이콘 크기(C4r15d-4) = 24 · 여백 = 재량 · 뒤처짐 고지 아이콘 = warning_amber_outlined(드라이런 = info_outline 판 · 크기 같아 dy 같음).
 ■ 호출 표 — B-01: watchIndex() 한 번(재시도 = 한 번 더 · 🔵 웹 = 셸 시작 때 IndexedStack 이 다섯째 자리를 미리 지어 사이드바를 누르기 전에도 watchIndex 1회 — 드라이런) · B-02: watchPage(anchor) 한 번(인자 = 받은 앵커 그대로) · shellLinkOpenerProvider(탭 안).

■ Key 표 (b01- 5 · b02- 7 = 12 — ✅ 드라이런 12) — b01-loading · b01-fail · b01-outdated · b01-entry-$i(-$j) · b01-state-$i(-$j) · b02-loading · b02-fail · b02-outdated · b02-title · b02-missing · b02-block-$i · b02-live-$i
■ 할 일 — (1) lib 두 파일 + 주입 절 + 배럴 + 셸 두 자리 «[M8] R16b (1) B-01·B-02 화면 · 셸 핸드북 자리» (2) fakes + 두 테스트 «[M8] R16b (2) B-01·B-02 테스트» (3) 골든 «[M8] R16b (3) 골든 b01_* 2장 · b02_* 6장» (4) «[M8] R16b (4) format · 질문» · 커밋 제목 = 내용(C4r15c-3).
■ 정적 라벨 — 0개(labels.dart 무변경 · 37).

■ 테스트 최소 목록 (✅ 드라이런 — 수 = 실측)
 공통: test/shell_fakes.dart 끝 절 «// ── R16b — B-01·B-02 fakes ──» = class FakeShellHandbookRepository extends UnimplementedHandbookRepository(index · page 공장 · indexCalls · pageAnchors(List<String>)) · handbookOverrides({repo, opener}) · pumpHandbookContents · pumpHandbookPage(anchor) · handbookIndexAllowed · handbookPageAllowed.
 B-01 — test/handbook_contents_test.dart(줄 9 · 테스트 14 · (전제) 3)
 B01-01 항목 차례·글자(index · ⓗ expect(index.entries, hasLength(8))) → 항목마다 shownTexts(b01-entry-$i) == [title, ?stateLabel] · 자식 차례(② · ⓗ 둘째) · b01-outdated findsNothing · ⓡ.
 B01-02 상태 → 아이콘·색 — 세 경우(ready = entries[0] · preparing = entries[5] · archived = entries[1].children[3] — 드라이런 표본 차례 · v1.17 표본이 다르면 병합 기록 때 고친다 · 전제 = 그 항목 state // pre) → Key('b01-state-…') icon · color == wantState(cs, state) · ⓡ.
 B01-03 링크 있는 항목 탭 = deepLink(데이터 · 두 경우 — 최상위 entries[0] · 자식 entries[1].children[1](🆕 deepLink ≠ handbook://<anchor> 인 항목 — 표본 조건)) → opener.opened == [link] · ⓡ.
 B01-04 준비 중 = 탭 부재(데이터 · entries[5] · 전제 = 그 항목 deepLink null // pre · 탭 → opener.opened == [] · 양성 기준점 = 그 항목 Key findsOneWidget) · ⓡ.
 B01-05 뒤처짐 고지 = 데이터 · 맨 위(indexOutdated · 전제 outdatedNotice isNotNull // pre · shownTexts(b01-outdated) == [notice] · dy < b01-entry-0 · 닫기·숨김 버튼 0 = ButtonStyleButton findsNothing · IconButton findsNothing) · ⓡ.
 B01-06 주입 null = 자리표시자(양성 기준점 find.byType(ShellPlaceholder) findsOneWidget · b01-entry-0 findsNothing) · B01-07 상태 갈래 두 경우(한 줄 · 경우 for) · B01-07 재시도(따로 한 줄) · ⓡ · B01-08 화면 Text 전부 + 버튼 수 0 · 큰 글꼴 두 경우(index · indexOutdated) · ⓡ.
 B-02 — test/handbook_page_view_test.dart(줄 10 · 테스트 18 · (전제) 3)
 B02-01 블록 차례·글자(sleeveB · ⓗ expect(sleeveB.blocks, hasLength(5))) → 블록마다 shownTexts == [?live.label, text] · 🆕 블록마다 tester.widget<Text>(find.descendant(of: find.byKey(ValueKey<String>('b02-block-$i')), matching: find.text(blk.text))).style == 첫 블록 style(글자 모양 = 한 가지 · kind 로 고르지 않음 — 드라이런: «CAUTION 굵게» 변이를 이 단언이 잡음) · repo.pageAnchors == ['<받은 앵커>'] · ⓡ.
 B02-02 라이브 값 = 데이터 → 아이콘·색(두 경우 — live = blocks[1] · no_live = blocks[0] · 전제 live isNotNull // pre · icon · color == wantLive(cs, level)) · 없는 블록 = b02-live-$i findsNothing(양성 기준점 b02-block-$i) · ⓡ.
 B02-03 블록 탭 = deepLink(데이터) — 두 경우(link = blocks[3] → opener == [link] · no_link = blocks[0] 탭 → opener 무변경) · ⓡ.
 B02-04 뒤처짐 × 링크 — 🆕 C4r15d-2: 두 경우(outdated · 링크 있는 블록 있음 / sleeveB · 고지 없음) · 고지 = 맨 위 · 숨김·닫기 0 · 블록 링크 그대로 동작 · ⓡ.
 B02-05 모르는 앵커 = missingLabel(missing · 전제 둘(blocks isEmpty · missingLabel isNotNull // pre) · b02-block-0 findsNothing · 양성 기준점 b02-missing) · ⓡ.
 B02-06 보관됨 페이지 = 받은 단락 그대로(archived · 화면 접기 0) · ⓡ.
 B02-07 셸 라우터 연결 — 세 경우(주입 있음 + openLink('handbook://sleeve-b' 꼴 · 표본 앵커) → Key('s01-handbook-slot') findsOneWidget · 안에 b02-title · repo.pageAnchors == [앵커] / 주입 null → s01-handbook-slot 안 ShellPlaceholder · b02-title findsNothing / 웹 사이드바 다섯째 → s02-handbook-slot 안 b01-entry-0) · ⓡ.
   🔴 주입 꼴(드라이런): 셸 경우 = <Override>[...shellOverrides(...), shellHandbookRepositoryProvider.overrideWithValue(repo)] — handbookOverrides 를 쓰지 않는다(opener 를 RecordingLinkOpener 로 덮으면 openLink 가 이동하지 않아 s01-handbook-slot 이 안 나온다) · 주입 null 경우 = shellOverrides 만.
 B02-08 상태 갈래 두 경우(한 줄 · 경우 for) · B02-08 재시도(따로 한 줄) · ⓡ · B02-09 화면 Text 전부 + 버튼 수 0 · 큰 글꼴 세 경우(sleeveB · outdated · missing) · ⓡ.
🔴 예고 변이: 항목 하나 빼기 · 뒤집기 · 자식 안 그리기 · 상태 아이콘 고정(아이콘 · 색) · 준비 중에도 탭 · 링크 대신 handbook://$anchor 조립 · 뒤처짐 고지 빼기·아래로·닫기 버튼 · configHash 비교로 고지 그리기 · 블록 kind 로 모양 고르기 · 라이브 값 빼기·아이콘 고정 · 블록 링크 0 ·
   missing 에 빈 블록 · 보관됨을 화면이 접기 · 주입 null 에 스피너 · 라우터 분기 Key 바꾸기 · 웹 자리 Key 바꾸기 · 정적 글자 더하기 ·
   🔵 «configHash 를 읽되 표본 동치» 꼴 = 정적 T11(configHash) 이 잡는다 · 🔵 참고(드라이런 2번째 · 13꼴 = KILLED 10) — 표본 동치·정적만 3: 제목 폴백 글자(T11 `.isEmpty`) · order 로 정렬(T11 `.sort` · 표본이 이미 order 차례) · live 등급 ok·info 모양 맞바꿈(표본 live 등급 하나뿐 · T09 글자만 바뀜).

■ 정적 묶음 — ⟦펼침: R16a 37줄 꼴을 이 카드 파일·수로(T06 = watchIndex · watchPage 2 · T07 += IncidentRepository|RunbookRepository · T08 = s01-handbook-slot 1 + s02-handbook-slot 1 · T09 = HandbookEntryState 3 + UiLevel 5 · T10·T12·T28 = 비움(번호만 · EXIT:1) ·
   T11 += configHash|FeatureFlags|AppLinkSchemes|setState|\.substring|\.order\b|\.kind\b · T14 = 22줄 기대 · T15 = 23줄 기대(머리에 수를 두지 않는다 — «정확히» = R16c · 감사) · T23 += 접기|펼치기 · T29 = shell_router 7 1 · shell_scaffold 5 1(드라이런) + 공용 셋 둘째 수 0 · 얼림 목록 += R16a incident lib·테스트·골든 ·
   T33 8줄 A · T37 = «8»(b0[12]_* — 이 카드 PNG · 총수 «정확히» = R16c) · 드라이런 기대 출력 172줄 · EXIT:1 22 · EXIT:0 15) · 꺼내기 범위·해시 = 승격 때 잼⟧
■ 골든 — 4이름 × light/dark = 8장(golden README «🆕 R16» 표 그대로 · 크기 kGoldenPhoneSize · 높이 확장 ⓐ~ⓔ = R16a 글자)
    이름           입력          흐름    맨 아래 Key                         머리 Key
    b01_index      index         없음    ValueKey<String>('b01-entry-7')      ValueKey<String>('b01-entry-0')     dy 744.0
    b02_page       sleeveB       없음    ValueKey<String>('b02-block-4')      Key('b02-title')                    dy 348.0
    b02_outdated   outdated      없음    ValueKey<String>('b02-block-1')      Key('b02-outdated')                 dy 248.0
    b02_missing    missing       없음    Key('b02-missing')                   Key('b02-title')                    dy 116.0
  (dy = 드라이런 기대 · light = dark · 머리 dy 0.0)
  🔵 b01_index 는 8항목 + ② 자식 4 = 12행 — 드라이런 dy 744.0 = 들어간다(넘으면 Bob 은 멈추고 질문 · 카드가 맨 아래 Key 를 고친다) · 높이는 늘리지 않는다.
■ 질문 파일 — B01B02_questions.md · 접두 «B-01:» · «B-02:» · 측정 행 상자 4줄(A1~A4 · b01_index · b02_page · b02_outdated · b02_missing · 꼴 = R16a 상자 글자 그대로 · ⟦펼침⟧).
■ 제출 — ⟦펼침: R16a ■ 제출 글자를 이 카드 수·이름·파일로(사전검사 ② = b01_ --goldens 2 · b02_ --goldens 6 · ① 머리 «화면 ID: B-01 — 전략 핸드북 목차(HandbookContents()) · B-02 — 핸드북 페이지(HandbookPageView(anchor:)) · 주입 shellHandbookRepositoryProvider» · ② 괄호 10줄(이 카드 판) · ③ 견본(«B-01 목차» · «B-02 페이지» · «셸 핸드북 자리» · «로딩·에러» — 머리 = 견본 줄 수) ·
   파일별 끝 줄(드라이런 기대) = contents «+14» · page_view «+18» · b01 «+2» · b02 «+6» · 끝 = N + 40 · name-status 20줄 · 커밋 4줄 · 🟡 기대 b01_ 1 · b02_ 1 · 셈 단위 견본(드라이런 light) = b01_index «아이콘 · 글자 1줄 ×3 → 아이콘 · 글자 2줄 → 아이콘 · 글자 1줄 → 아이콘 · 글자 2줄 → 아이콘 · 글자 1줄 ×3 → 아이콘 · 글자 2줄 ×3 — 잘림 없음» · b02_page «글자 1줄 → 글자 2줄 → 아이콘 · 글자 3줄 → 글자 2줄 → 글자 2줄 → 글자 2줄 — 잘림 없음»)⟧
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-b01-handbook` · 커밋 권장 4 · lib 새 2 + 셸 2파일 허용 자리 · 주입 +1 · 배럴 +2 · test 새 4 + fakes 끝 절 · 새 PNG 8(`b0*`) · `B01B02_questions.md` A1~A4 · 라벨 37 · 🔵 배럴·주입·PNG 총수의 «정확히» = R16c(이 카드는 늘어난 몫 +2 · +1 · +8 만 본다) · 🔴 기존 TR-09 handbook · `s02-handbook-slot` 테스트 무수정 통과.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R16b-Bob-B01B02 결과: 브랜치 ui/m8-b01-handbook 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

## 5. 주의

- **5분 눈 검사**: 목차 항목 수 리터럴 · 장 이름·본문 글자 · 숫자 리터럴(대조군·세후·기대치) · `configHash` 읽기 · 뒤처짐 고지 닫기·숨김 · 화면의 `handbook://` 조립 · 접기 로컬 상태 · 셸 두 자리 밖 줄.
- 🔵 C4 사람 grep = R16a «5» 두 줄을 이 카드 테스트 파일로.
- ⬜ 남은 표식 ⟦…⟧ · 자리표시자 `__R16A_SQ__` · `__R16A_PR__`(R16a 병합 기록이 채운다 · 시작 기준 N · 0단계 병합본 실행 · «펼침» · 가벼운 확인).
- 범위 고지: 01 §8 미결 139(N-02 핸드북 앵커) · 76·81(M7 사유 칩 → 핸드북 · R16b 병합 뒤 M7 후속) · 폰 «더보기» 핸드북 진입 — 이 카드가 닫지 않는다.

## 6. R16 이월 반영 — R16a «6» 과 같은 표(B-01·B-02 자리)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r15c-1 «부재 쪽» 양성 기준점 | B01-04 · B01-06 · B02-02 · B02-05 · B02-07 | — |
| C4r15c-2 상태 아이콘 icon·color | B01-02(목차 상태 3) · B02-02(라이브 등급) · 예고 «아이콘 고정» | — |
| C4r15d-1 버튼 수 = 받은 수 | B01-08 · B02-09(둘 다 0 — 블록 링크 = 블록 탭) · B01-05(닫기·숨김 버튼 0) | — |
| C4r15d-2 데이터 칸 × 상태 조합 | B02-04(뒤처짐 × 블록 링크) · B01-02(상태 3 × 링크 있음/없음 = B01-03·04) | 표본이 갖지 않는 조합 = 질문 파일 |
| C4r15b-2 · C4r15d-4 Row 정렬 · 아이콘 크기 | «화면» 아래 한 줄(Row 셋 start · 24) | — |
| C4r15d-3 골든 높이 확장 ⓐ~ⓔ | «■ 골든» (R16a 글자 펼침) · b01_index 12행 맨 아래 Key 주의 | — |
| C4r15a-1 · C4r15c-3·-4·-6 · C4r15d-5 · C4r15b-1 · 공통 교훈 | ⟦펼침 — R16a 판 글자⟧ | — |
| C4r15a-2 · C4r15b-4 드라이런 변이 앵커 analyze 선확인 · «타입이 막음» 컴파일 확인 | 머리 «드라이런» 줄(✅ 누적 드라이런 2번째 · 46꼴 전부 실행 — 첫 판 8 · 재실행 39) | — |
