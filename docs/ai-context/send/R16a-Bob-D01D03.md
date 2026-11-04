# 발송 패킷 R16a-Bob-D01D03 — D-01 장애 배너 · D-02 DR 런북 · D-03 오프라인 긴급정지 카드 (계약 v1.17 전제 · R16 3장 중 1번째 · M8)

> ⬜ **조립됨 — 드라이런 대기**(2026-11-04 · 앱 `rec/r16`) · 🔴 **선행 1 = 계약 v1.17 R16 몫(R16 선행 M2 보강 — 아래 «■ 계약 v1.17 이름표» · 12 §3 «R16 선행 M2 v1.17 이름표» #1~#6·#10~#12 · ⬜ 발주자 결정 · ▶ 금지)** · ⬜ 누적 드라이런(v1.17 흉내 위) · ⬜ 발주자 확인 ①~⑫ · ⬜ 「푸시해」 — 넷이 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R15 브랜치(`ui/m8-o00-mode-pick` · `ui/m8-o01-steps` · `ui/m8-o04-finish` · `ui/m8-r01-restart` · 병합됨)는 건드리지 않는다.
> 만든 날 2026-11-04 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R16-Bob-M8d` 행(386행 · 🔀 3분할 권고 — 아래 «재분할 판정») + §3-0 사전검사 블록 + §3 공통 조문(strict 나눔 · PR 본문은 통합 담당 · 커밋 = 제목만 맞추기 · 🆕 골든 높이 = 재량 + 기록 확장 ⓐ~ⓔ — R16 부터 · 재제출 = 전체판 + 상자) + 이월 부록 «R16» 대상(R15a~R15d C4 이월 부록 · «R15 test-only PR 묶음» 의 «(조립 체크리스트)» 몫 — 아래 «6») · 화면 몫 원본 = `04_…` §6(`D-01` 슬롯 2 최대 1건 · 닫기 0 · `D-02` 6종 · 체크 = 로컬 · `D-03` 인쇄·PDF 예외 · 그림 14) · §2-4(전역 슬롯 ① 게이트 → ② 장애 배너 → ③ 오래됨 → ④ 본문) · §2-1 금지 5(내보내기·공유·인쇄 0 — `D-03` 만 예외) · §5-1c(`BROKER_AUTH_FAILED` P0 · `ORDER_REJECTED` P1 · `DATA_SOURCE_DOWN` P1 — 배너 ≠ 알림) · `03_실행/03_운영과_의사결정_프로토콜.md` §10-5(여섯 시나리오 런북 · 시나리오 ⑥ 오프라인 1페이지 정지 절차 — 원고 출처 · M2 몫) · `06_시스템설계/04_안전장치.md` §5-5 · 판독 메모(통합 담당 스크래치 `r16/read_memo.md` · 2026-11-04 · 앱 `origin/main` `a29e3d3` → 다시 fetch `125d9bc`(엔진 E11h2 병합 · `domain_contracts`·`ui_shell`·`docs` 무변경) · 설계 `ac64f96`).
> 사전 조건 — ✅ R15 병합(R15a #99 `940082c` · R15b #103 `a79f620` · R15c #107 `0e96ed3` · R15d #110 `4b31603` · R15 test-only #113 `69afd33` · `ui_shell` = lib 19파일 · 라벨 37 · 배럴 export 16줄 · 셸 주입 19줄 · PNG 70 · 라우트 64) · ⬜ **선행 1 계약 v1.17**(R16 선행 M2 보강 PR — R16a 몫 + R16b·R16c 몫 · 아래 이름표 · 병합 squash = `__R16V117_SQ__`) · ✅ 프롬프트 v2(183줄). 시작 기준 = 계약 v1.17 병합본의 `flutter test`(packages/ui_shell) = **⟦실측: v1.17 병합본 — 기대 357(R15 test-only 병합본 `69afd33` 기록 · v1.17 이 `ui_shell` 테스트·가짜를 바꾸지 않으면 그대로 · 새 라우트는 TR 루프가 목록을 돌아 수 불변 · 받침대 `UnimplementedOpsStatusRepository` +1 은 가짜가 상속이라 무변경)⟧** · 이 카드 끝 기대 = 시작 기준 N + **54**(계획 — 뷰 44 = `incident_banner_test` 17 + `runbook_list_test` 9 + `runbook_detail_test` 9 + `emergency_stop_card_test` 9 · 골든 10 = `d01_*` 4 + `d02_*` 4 + `d03_*` 2) · 끝 = ⟦실측: 드라이런 «+411» 기대⟧.
> 🔀 **재분할 판정(12 §3 공통 임계 = 새 `testWidgets(`·`test(` 줄 > 33 · lib > +900 · 새 PNG > 16 · K35 새 원천·쓰기 ≤ 5)** — R16 한 장(D-01~D-03 · B-01 · B-02 · H-03 · M2 보강 뒤 추정) = 줄 ~52~61 · lib +990~1,320 · PNG ~20~24 · 원천 7(쓰기 0) → **네 축 전부 초과** → **3분할 권고**(발주자 확인 ①): 이 카드 = `D-01`·`D-02`·`D-03`(카드 계획 = 줄 **32**(`incident_banner_test` 10 · `runbook_list_test` 6 · `runbook_detail_test` 7 · `emergency_stop_card_test` 6 · 골든 3) · lib ⟦실측: 드라이런 — 추정 +500~620⟧ · 새 PNG **10** · 원천 **4**(`watchIncident` · `watchRunbookIndex` · `watchRunbook` · `watchEmergencyCard`) · 쓰기 0) → `send/_대기/R16b-Bob-B01B02.md`(B-01·B-02 핸드북 · 줄 ~20 · PNG 8 · 원천 2) → `send/_대기/R16c-Bob-H03.md`(H-03 물리 리스크 · 줄 ~9 · PNG 4 · 원천 1 · «정확히 N» 소유). 까닭 = ⓐ 임계 네 축 ⓑ 카드마다 선행 소유자가 다르다(R16a = 엔진 장애 원천 + 런북 원고(03_실행 §10-5) + 인쇄 플랫폼 슬롯 · R16b = 핸드북 원고(HB-1~HB-3) + config_hash 게이트 정정(04 §8) + 라우터 핸드북 분기 · R16c = DeviceRisk + Android 전용 + H-01 블록 9 창) ⓒ strict 반려 1회의 되돌림 폭 ⓓ Bob 이미지 20장 한도(이 카드 PNG 열람 5장). 🔴 이 카드는 R13a 셸 틀(`shell_scaffold.dart` `body:` 두 곳)을 고친다 = «끝 절 더하기만» 밖 — 허용 자리를 글자로 못박고 정적 T08·T29 로 본다.
> 카드 기본값(카드 권한 — ⬜ 아래 «발주자 확인» ①~⑫ 가 확정 · 조립 단계 = 권고 = 카드 기본값): ⓐ 위젯 = `IncidentBannerSlot({super.key})`(`lib/src/incident/incident_banner.dart` · `ConsumerWidget`) · `RunbookList({super.key})`(`lib/src/incident/runbook_list.dart` · `ConsumerWidget`) · `RunbookDetail({super.key, required String runbookId})`(`lib/src/incident/runbook_detail.dart` · `ConsumerStatefulWidget` — 로컬 체크 `Set<int>` 하나) · `EmergencyStopCard({super.key})`(`lib/src/incident/emergency_stop_card.dart` · `ConsumerWidget`) ⓑ D-01 셸 배선 = `lib/src/shell_scaffold.dart` 의 `_PhoneHome`·`_WebBody` `body:` 두 곳만(`Column(crossAxisAlignment: stretch, children: [const IncidentBannerSlot(), Expanded(child: IndexedStack(…그대로…))])`) + import 한 줄 — 그 밖 셸 파일·셸 테스트·s01 PNG 무변경 ⓒ 원천 = 🆕 `IncidentRepository.watchIncident()` → `IncidentBannerVm` · 🆕 `RunbookRepository.watchRunbookIndex()` → `RunbookIndexVm` · `watchRunbook(runbookId)` → `RunbookVm` · `watchEmergencyCard()` → `EmergencyCardVm` · 쓰기 0 ⓓ 주입 3 = 🆕 `shellIncidentRepositoryProvider`(`IncidentRepository?` · **기본값 null = 배너 부재** — 기존 셸 테스트·골든이 이 주입 없이 그대로 돈다) · 🆕 `shellRunbookRepositoryProvider`(throw 기본값) · 🆕 `shellOpsSlotBuilderProvider`(`ShellSlotBuilder?` · throw 기본값 · D-03 인쇄 = 플랫폼 슬롯) ⓔ D-01 = 최대 1건(VM 이 고른 것) · 아이콘 = `kind` · 색 = `level` · 조치 = `action`(`LinkAction?` — 버튼 0/1) · 닫기·«다시 보지 않기»·스와이프 0 · 값 전 = 부재 · 에러 = `ShellErrorView` ⓕ D-02 = 목록(행 탭 = `deepLink`) → 상세(번호 = `orderText` · 단계마다 «확인» `Checkbox` = **화면 로컬 상태 · 저장 0 · 명령 0** · 하단 고지 = `localCheckNotice`) · «지금 실행» 0 ⓖ D-03 = 한 장(단계 · 연락처 줄 · «종이로 보관하세요» 고지 · 인쇄 = `printSlotId` + 슬롯 빌더 — 둘 중 하나라도 없으면 부재) · 계좌번호·앱키·전화번호 리터럴 0 ⓗ asOf 머리·오래됨 배너 = 0(이 카드 VM 에 asOf 없음 — 문서 콘텐츠 · ⑨) · `shellClockProvider` 미사용 ⓘ 새 lib 파일 4 · 공용 3(`shell_providers.dart` 끝 절 주입 3 · 배럴 +4 · `test/shell_fakes.dart` 끝 절 — 전부 **끝 절 더하기만**) + 셸 틀 1(`shell_scaffold.dart` 허용 자리만) · 라벨 0 · Key 접두 `d01-`·`d02-`·`d03-` · 골든 5이름 10장(`d01_token_expired` · `d01_network_down` · `d02_list` · `d02_detail` · `d03_card` · 크기 = `kGoldenPhoneSize`(390 × 844 · dy ⟦실측⟧)) ⓙ copyWith 0 · implements 가짜 0(v1.17 받침대 `UnimplementedIncidentRepository` · `UnimplementedRunbookRepository` extends) ⓚ 픽스처 = v1.17 의 `m8/incident_banner_*` 4 · `m8/runbook_*` 4 · `m8/emergency_card*` 2 — 12 §3 원 행의 `m8/incident_token_expired`(봉투 = `ConnectionsVm` · 형제 키 = `AlertItem`) · `m8/recon_board_diff`(`DiagnosticsVm` · H-01 블록 6)는 **쓰지 않는다**.
> 🔴 **카드 덮개 필수 문장(04 §6 · §2-1 금지 5 · §2-4 · prompt_M8 151~154)** — «`D-01` 은 전역 슬롯 2 에 **최대 1건** — 고르기·정렬 = 엔진 · 문구·조치는 이미 완성돼 온다 · 종류 코드는 **아이콘 선택에만** · 배너는 **닫을 수 없다**(원인 해소 = 데이터에서 사라짐) · «다시 보지 않기» 0» · «`D-02` 는 읽기 전용 절차서 — 단계 «확인» 체크는 **로컬 진행 표시일 뿐 어떤 상태도 바꾸지 않는다**(저장 0 · 명령 0 · 그 사실 = 하단 고지 엔진 글자) · «지금 실행» 류 = M5·M9 삽입 자리 · 이 판 = 부재» · «`D-03` 은 가족용 한 장 — 문안 = 데이터 · 인쇄·PDF 저장 = 플랫폼 슬롯(내보내기 금지의 **유일한 예외**) · **계좌번호·앱키는 카드에 없다**» · «킬스위치·게이트는 삽입 자리만 — 이 카드는 그 자리도 만들지 않는다(엔진이 링크를 실으면 그 링크를 연다)» · «셸 틀은 `body:` 두 곳만 · 그 밖 셸·R13~R15 파일·테스트·PNG 는 고치지 않는다». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» 에 있습니다.
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 결정 7c(알림 등급 = 엔진 — 배너 ≠ 알림) · K35(새 원천·쓰기 ≤ 5) · 01 §8 미결 144(`ui_shell` 화면 스캔 = 카드 정적 묶음).
> ⬜ **발주자 확인 12건(권고 = 카드 기본값 · 이의 없으면 그대로 · 🔴 확인 전 ▶ 금지)** — ① **분할 · 선행 · 차례를 한 문항으로**: R16 = 3장(이 카드 `D-01`~`D-03` → `R16b-Bob-B01B02` → `R16c-Bob-H03` «정확히 N») · 선행 = 계약 v1.17 «R16 선행» M2 보강(카드별 몫 = 12 §3 «R16 선행 M2 v1.17 이름표» · 이 카드 = #1~#6·#10~#12) · 차례 = 행 차례 D → B → H · 대안 = 2분할(D+H / B · 줄 ~33~37 · PNG 12~16 = 경계 · 비권고) · H-03 후순위(Android 전용 · 미결 123·127 이 M9 와 얽힘) · 비권고 = 한 장(임계 네 축 초과) ② **계약 번호** — `contract_version.dart` 가 1.17.0 을 엔진 E10 D11 4건(`JournalStatus.EXPIRED` · «지난 날 주문 잔존» 알림 코드 · PREVENTED 근거 자리)으로 예약해 두었다(13 R33 D11 «Bob 카드 사이 창») · 권고 = **한 M2 PR 로 1.17.0 묶음**(R16 선행 + D11 · 엔진 세션과 조율) · 대안 = 엔진이 1.17.0 먼저 → R16 = 1.18.0(이 카드의 «1.17» 글자를 병합 기록이 고친다) · PR 직전 `git fetch` · 버전 줄 실측 ③ `D-01` 원천 = 🆕 `IncidentRepository.watchIncident()` → `IncidentBannerVm{banner?}` · `IncidentBanner{kind, level, title, bodyText, action?}` · 종류 = 🆕 enum `IncidentKind`(phoneDown · networkDown · tokenExpired · orderRejected · other — 아이콘에만 · 모르는 wire = other) · 조치 = `LinkAction?` · 대안 = `OpsStatusRepository` 에 메서드 추가(셸 틀이 기존 throw 주입을 타 기존 셸 테스트 25줄이 깨짐 · 비권고) ④ `D-01` 셸 배선 = 폰 `_PhoneHome` · 웹 `_WebBody` `body:` 두 곳(탭 본문 위 · 밀어 넣은 화면(`ShellRouteBody` 새 쪽)의 배너 = 이 카드 밖 → 01 §8 미결 신설 후보) · 주입 = `Provider<IncidentRepository?>` **기본값 null**(= 배너 부재 · 기존 `shell_scaffold_test` 13줄 · `shell_router_test` 12줄 · `s01_*` PNG 4장 무변경) · 대안 = throw 기본값 + `shellOverrides` 선택 인자(기존 함수 수정 · 비권고) ⑤ `D-01` 상태 = 값 전 = 부재(스켈레톤 0 — 셸 틀을 흔들지 않는다) · 에러 = `ShellErrorView`(재시도 · 원천 실패를 숨기지 않는다 — 배너 원천이 죽으면 P0 장애를 못 본다) · 대안 = 에러도 부재 ⑥ `m8/incident_token_expired` = R16 이 쓰지 않는다 · `incident_alert.code` `MAINTENANCE_RESUME_FAILED` → `BROKER_AUTH_FAILED`(04 §5-1c P0 · 제목 «토큰 만료»와 맞춤 · 01 §21-10-2 R22 «R16 조립 때 교체 여부») · R16 행 픽스처 = 새 배너 표본 4 · `m8/recon_board_diff` = 행에서 뺌(H-01 블록 6 · R13b 가 이미 씀) ⑦ `D-02` 원천 = 🆕 `RunbookRepository.watchRunbookIndex()` · `watchRunbook(runbookId)` · 원고 = Claude(M2 · 03_실행 §10-5 여섯 시나리오) · «확인» 체크 = 화면 로컬 상태(저장 0 · 명령 0 · `localCheckNotice` = 엔진 글자 · 04 §2-3 «탭 = 조회» 의 **이 카드만의 예외**) · «지금 실행» = 부재(05·계약에 슬롯 이름 0 · 04 «없으면 비움») ⑧ `D-03` 원천 = 🆕 `watchEmergencyCard()` → `EmergencyCardVm` · 인쇄·PDF = 플랫폼 슬롯(`printSlotId` + 🆕 `shellOpsSlotBuilderProvider` · 조립 앱 · 06 M4-11 류) — 이름·빌더 없으면 부재 · 04 §2-1 금지 5 의 유일한 예외 · 계좌번호·앱키·전화번호 리터럴 0(정적 T28) ⑨ 문서 콘텐츠 화면(`D-02`·`D-03`) asOf = 0(시점 없는 절차서 · R15 온보딩 꼴 · 04 §2-3 «모든 조회 화면» 의 예외 — 01 §8 미결 신설 후보) · 대안 = asOf 머리 ⑩ 라우트 = v1.17 `opsRunbooks`(`aaq://ops/runbooks`) · `opsRunbook`(`aaq://ops/runbooks/:runbookId`) · `opsEmergencyCard`(`aaq://ops/emergency-card`)(셸 가드 기본 open · 본문 등록 = 조립 앱 레지스트리 · 🔴 이 카드는 상수를 쓰지 않는다) ⑪ 정적 라벨 0 · 새 주입 3 · 골든 5이름 10장(04 에 이름 없음 · 카드가 지음) ⑫ 이월 반영(아래 «6»).
> 🔵 **판독 빈틈 → v1.17 권고(판독 메모 §6 · 12 §3 «R16 선행 M2 v1.17 이름표»)**: G1 `IncidentBanner` DTO·창구·표본 0(`domain_contracts.dart:17~19` «이름 미확정 · 화면이 대신 지어내지 않는다») → #1·#2 · G1b `incident_token_expired` 미매핑·코드 어긋남 → #11 · G2 `Runbook` DTO·라우트·원고 0 → #3·#5·#6 · G3 `D-03` VM·라우트 0 · 인쇄 = 플랫폼 → #4·#5·#6 · G6 «지금 실행» 슬롯 이름 0 → v1 = 부재(선행 0) · G7 엔진 레인 몫(장애 원천 `incidents` 표 · VM 산출 · 뷰어 rm_*) → 06 변경 이력 · 화면 카드를 막지 않음(픽스처 고정 모드) · G8 번호 → ②. 🟡 화면 스캔 빈틈(01 §8 미결 144 — `ui_shell` 은 C-47·경계 [5b][5c] 밖) → 이 카드 정적 묶음이 메운다(닫기·다시 보지 않기 · 인쇄·공유 위젯 · 전화번호·계좌번호 꼴 · `setState` 자리).
> 🚫 **플랫폼·엔진 몫 = 화면 밖** — 인쇄·PDF 저장(D-03 · 조립 앱 슬롯) · 장애 감지·정렬·최대 1건 고르기(엔진 · data_sync `incidents` 표) · 런북·카드 원고(M2) · 밀어 넣은 화면 위 배너(이 카드 밖) · 전역 슬롯 ① 스키마 게이트(R16 몫 아님 — ② 를 본문 위 첫 자리로 둔다).
> 드라이런: ⬜ ⟦실측: 누적 드라이런 1번째 — worktree `C:/Work/AAQ-claude-r16dry` · 가지 `dry/r16-1`(= `origin/main` → 이 기록 커밋 ff → v1.17 흉내 커밋(이름표 그대로 · dry 가지 전용) → 권장 4커밋) · 시작 · 끝 · 파일별 · 정적 출력 줄 수 · EXIT 수 · 사전검사 ① ② · 골든 dy · s01 PNG 바이트 같음 · `shell_scaffold.dart` numstat · lib 줄 · 변이 KILLED/SURVIVED(🆕 C4r15a-2 — 변이 앵커는 적용 뒤 `dart analyze` 로 컴파일 먼저 · 무효 변이는 같은 뜻의 대체 앵커로 표에)⟧.
> 프롬프트 = `docs/ai-context/prompt_M8.md`(**v2 판 183줄** · 2행 `{{범위}}` = `S-01` · 119행 «이번 과제 범위: S-01» · 128행 PR 제목 = 형식만 → 이 카드가 덮는다(«이긴다» ①⑫) · 재조립 0 · 🔵 낡은 줄 = 150행 «PDF 저장·공유·스크린샷 버튼 금지»(복구 카드 몫 — D-03 예외는 프롬프트에 없음 · «이긴다» ⑬)). 🔴 Bob **새 대화** 전제 — R15 대화를 기억하지 못합니다. 0단계·규칙 요약·본받지 않는 것·스케치·테스트 목록은 본문에 담았습니다.
> R4·R13·R5·R14·R15 교훈 반영: PNG 열람 = 이름마다 light 1장(5장 — 이미지 20장 한도) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 같을 때만) · 구독마다 «로딩·에러 × 갈래»(C4r3-1) · 갈래마다 배너·짝(C4r5e-3 · 이 카드 = 상태 갈래 짝 · D-01 은 «있음 × 조치 있음/없음» 짝) · 경우 for 는 testWidgets **밖**(C4r14b-1) · 흐름 칸 non-null 클로저(C4r14b-2) · 경우 이름 = 레코드 `name` 칸(C4r14a-4) · 쓰기 조각 두 방향(C4r14a-5 · 이 카드 = 쓰기 0) · «부재 = 데이터» 테스트 = 주입은 그대로 · 데이터만 바꿈(C4r14a-6) · 전제는 if 밖·`// pre`(C4r4b-1·2) · 커밋마다 `git add <파일>` + `git show --stat HEAD`(C4r5a-3) · 제네릭 위젯 술어 = `tester.widget<T>(find.byKey(…))` · `find.descendant(of: find.byKey(…), matching: find.byType(T))` 만(`find.byType(Icon)` 단독 = 늘 참 금지 · C4r5a-4) · 저장 파일로 받기 · 채팅 두 줄(C4r5a-1) · 저장 파일 = UTF-8 BOM 없이 `[IO.File]::WriteAllText` · ① 붙이기 = 파일로 받은 출력 그대로(C4r14b-5) · 정적 묶음 = 파일로 꺼내 Git Bash 전체 경로 · EXIT 0/1 밖이면 다시(C4r5a-2 · C4L-4) · 정적 머리 ASCII · `Get-Content -Encoding UTF8` · `[Console]::OutputEncoding`(C4r5e-5) · 골든 칸 셈 단위 «이어진 글자 행 = 한 덩어리»(C4r14a-3) · 파일별 기대 글자에 시각 머리(C4r14a-2) · G1 🟡 조문(C4r5d-1) · ③ 표 구분 줄 · ④ «+»(C4r5d-8) · 단언 없는 `takeException` 0(C4r5d-6) · «자리 바꿈» 견본 = 글자 그대로 · 입력 칸 = 파일 이름만(C4r5e-7) · ③ 서술 = 견본 차례·줄 수 · «» 까지 견본 글자 그대로(C4r15a-1) · 화면 나무에 적힌 Row 정렬 = 그대로(C4r15b-2) · 커밋 제목 = 내용(C4r15c-3) · 질문 파일 «측정:» 행 = 카드 상자 글자 그대로(C4r15c-4) · ② 상자 뒤 빈 줄 한 줄(C4r15c-6) · 🆕 «부재 쪽» 경우마다 양성 기준점 Key = 최소 목록 글자(C4r15c-1) · 🆕 상태 아이콘 자리마다 icon·color 단언 + 예고 «그 아이콘 고정»(C4r15c-2) · 🆕 버튼 그리는 화면마다 «화면 Text 전부» 항목에 «버튼 수 = 받은 수»(C4r15d-1) · 🆕 데이터 칸 × 상태 조합마다 «있는 쪽» 경우(C4r15d-2) · 🆕 골든 높이 확장 ⓐ~ⓔ(C4r15d-3) · 🆕 화면 나무에 아이콘 크기(C4r15d-4) · 🆕 «5» C4 사람 grep 1 확장(C4r15d-5).

## 0. 한 줄 목적

`IncidentBannerSlot()` 이 `watchIncident()` 의 배너 0/1건을 셸 탭 본문 위에 받은 글자·종류 아이콘·등급 색 그대로 그리고(닫기 0 · 조치 = 링크) 주입이 없으면 아무것도 그리지 않으며, `RunbookList()`·`RunbookDetail(runbookId:)` 가 런북 목록과 번호 단계를 그리고 단계 «확인» 체크를 저장·명령 없이 화면 안에서만 켜고 끄며, `EmergencyStopCard()` 가 가족용 한 장(단계 · 연락처 · 보관 고지)과 플랫폼 인쇄 슬롯만 그리는 `D-01`~`D-03` 을 계약 v1.17 그대로 짓기(셸 틀은 `body:` 두 곳만).

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m8-d01-incident`**(base = 최신 `origin/main` · `--no-track` · 이름 = 12 §3 R16 원 행 글자 그대로) · PR 제목 = «[M8] D-01~D-03 장애 배너·DR 런북·긴급정지 카드»(원 행 «[M8] D-01~D-03·B-01·B-02·H-03» 은 한 장 판 글자 · ⬜ 발주자 확인 ①).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — 지금은 ⬜(선행 계약 v1.17 · 드라이런 · 발주자 확인 · 「푸시해」가 남음 · v1.17 병합 기록이 표식을 채운다).
2. Bob 에 R15 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R16a-Bob-D01D03.md> (🔴 `C:\Work\AAQ-claude\` 와 Bob 폴더의 사본은 최신이 아닐 수 있습니다 · `send/_대기/` 판은 보내지 않습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R16a-Bob-D01D03 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 바깥 울타리 = 백틱 네 개 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R15*-Bob-*.md` · 다음 장 `_대기/R16b-Bob-B01B02.md`·`R16c-Bob-H03.md` 를 붙여넣지 않습니다.
6. 🔴 **받는 법(C4r5a-1 · R15 와 같은 꼴)** — Bob 은 보고 글 전문을 채팅에 내지 않고 `$env:TEMP\R16a-Bob-D01D03_submit.md`(UTF-8 **BOM 없이** — C4r14b-5)에 저장한 뒤 사전검사 ② 를 세 번(`d01_` · `d02_` · `d03_`) 돌리고, 채팅에는 두 줄(«…저장했음: <경로>» · 사전검사 ② 끝 줄 셋을 « / » 로 이은 한 줄)만 냅니다. 받은 뒤에는 아래 «4» 대로 **그 파일을 열어** 통째로 붙여 넣습니다.
7. 🔵 Bob 의 이전 창은 닫은 뒤 새 대화를 엽니다 — 그 창이 띄운 `flutter_tester` 는 창과 함께 끝납니다. 작업 관리자 등에서 `flutter_tester` 를 직접 끝내지 마세요(다른 세션 것도 있습니다 · C4r5a-9 ⑥).

## 3. 붙여넣을 본문 — ````text 다음 줄(«R16a-Bob-D01D03 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R16a-Bob-D01D03 — 범위: D-01 장애 배너(IncidentBannerSlot() — 종류 아이콘 · 제목 · 본문 · 조치 버튼 0/1 · 셸 탭 본문 위 두 곳) ·
  D-02 DR 런북(RunbookList() 목록 · RunbookDetail(runbookId:) 번호 단계 + 로컬 «확인» 체크 + 하단 고지) · D-03 오프라인 긴급정지 카드(EmergencyStopCard() — 단계 · 연락처 · 보관 고지 · 인쇄 = 플랫폼 슬롯)
  + 새 주입 3 + 배럴 export 4줄 + 셸 틀 body: 두 곳 + 가짜 끝 절.
🔴 D-01 = 최대 1건(엔진이 고른 것) · 문구·조치는 완성돼 온다 · kind = 아이콘에만 · level = 색에만 · 닫기·«다시 보지 않기»·스와이프 0 · 원인 해소 = 데이터에서 사라짐 · 주입 없음(null) = 아무것도 그리지 않음.
🔴 D-02 = 읽기 전용 — «확인» 체크 = 화면 로컬 상태(저장 0 · 명령 0 · 다시 부르기 0) · 그 사실 = 하단 고지(엔진 글자) · «지금 실행» 버튼 0 · 번호 = orderText(계산 0).
🔴 D-03 = 가족용 한 장 — 문안 = 데이터 · 인쇄·PDF = 슬롯 빌더(플랫폼)만 · 화면이 인쇄·공유·PDF 위젯을 만들거나 import 0 · 계좌번호·앱키·전화번호 리터럴 0.
🔴 킬스위치·게이트 = 삽입 자리만 — 이 카드는 그 자리도 만들지 않는다(엔진이 조치 링크를 실으면 그 링크를 연다 · AppRoutes 상수 0).
🔴 셸 틀 = lib/src/shell_scaffold.dart 의 _PhoneHome · _WebBody body: 두 곳 + import 한 줄만 · 그 밖 셸·R13~R15 파일·테스트·PNG 는 고치지 않는다.
하지 않는 것: B-01·B-02 핸드북(R16b) · H-03 물리 리스크(R16c) · H-01 블록 9 · 밀어 넣은 화면 위 배너 · 전역 슬롯 ① 게이트 · 알림(N-01·N-02) · 인쇄 구현 · 조립 앱 배선 ·
  asOf 머리·오래됨 배너(이 카드 VM 에 asOf 없음) · domain_contracts·pubspec 수정 · 다른 ui_* 수정 · 내보내기·공유(04 §2-1 금지 5 — D-03 인쇄 슬롯만 예외).
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 17항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R15a~R15d(병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-* · ui/m8-*)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 packages/ui_shell/lib/src/incident/ 이 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m8-r01-restart(R15d) 일 것입니다 — 다른 ui/m6-*·ui/m8-* 여도 멈추지 않음
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m8-d01-incident origin/main      ← 🔴 git checkout main 금지(다른 worktree 에 체크아웃돼 있어 거부)
  git grep -c "contractVersion = '⟦1.17.0⟧'" -- packages/domain_contracts/lib/src/contract_version.dart                        ← ⟦실측: v1.17 병합본 «…contract_version.dart:1» — 엔진과 한 PR 이면 1.17.0 · 엔진이 먼저면 1.18.0⟧
  git grep -c "Stream<IncidentBannerVm> watchIncident();" -- packages/domain_contracts/lib/src/repositories                     ← ⟦v1.17 · 파일 자리 = 보강 PR 이 정함⟧ «…:1»
  git grep -c "Stream<RunbookIndexVm> watchRunbookIndex();" -- packages/domain_contracts/lib/src/repositories                   ← ⟦v1.17⟧ «…:1»
  git grep -c "Stream<RunbookVm> watchRunbook(String runbookId);" -- packages/domain_contracts/lib/src/repositories              ← ⟦v1.17⟧ «…:1»
  git grep -c "Stream<EmergencyCardVm> watchEmergencyCard();" -- packages/domain_contracts/lib/src/repositories                 ← ⟦v1.17⟧ «…:1»
  git grep -c "abstract class IncidentBanner with" -- packages/domain_contracts/lib · git grep -c "abstract class IncidentBannerVm" -- packages/domain_contracts/lib   ← ⟦v1.17⟧ 각 «…:1»
  git grep -c "abstract class RunbookVm" -- packages/domain_contracts/lib · git grep -c "abstract class EmergencyCardVm" -- packages/domain_contracts/lib            ← ⟦v1.17⟧ 각 «…:1»
  git grep -c "enum IncidentKind" -- packages/domain_contracts/lib                                                            ← ⟦v1.17⟧ «…:1»
  git grep -c "LinkAction? action," -- packages/domain_contracts/lib                                                          ← ⟦v1.17⟧ «…:1»(조치 = 링크 하나 또는 없음)
  git grep -c "class UnimplementedIncidentRepository" -- packages/domain_contracts/lib/testing.dart                           ← ⟦v1.17⟧ «…testing.dart:1»
  git grep -c "class UnimplementedRunbookRepository" -- packages/domain_contracts/lib/testing.dart                            ← ⟦v1.17⟧ «…testing.dart:1»
  git grep -c "static const String m8IncidentBannerTokenExpired =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart    ← ⟦v1.17⟧ «…fixture_paths.dart:1»
  git grep -c "static const String m8EmergencyCard =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart                 ← ⟦v1.17⟧ «…fixture_paths.dart:1»
  git grep -c "body: IndexedStack(" -- packages/ui_shell/lib/src/shell_scaffold.dart                                           ← «…shell_scaffold.dart:2»(R13a · 이 카드가 고치는 두 자리)
  git grep -c "typedef ShellSlotBuilder" -- packages/ui_shell/lib/src/shell_providers.dart                                     ← «…shell_providers.dart:1»(R15b)
  git grep -c "class FakeShellSlotRecorder" -- packages/ui_shell/test/shell_fakes.dart                                         ← «…shell_fakes.dart:1»(R15b 가짜 슬롯 빌더)
  git grep -c "List<String?> shownTexts" -- packages/ui_shell/test/shell_fakes.dart                                            ← «…shell_fakes.dart:1»(R13a 도우미)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md                                                                       ← «…prompt_M8.md:1»(아래 줄 번호가 이 판 기준 · 없으면 멈춤)
  ls docs/ai-context/send/R16a-Bob-D01D03.md                         ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/D01D03_questions.md                       ← 보여야 함(빈 표가 이미 있다)
  ls packages/domain_contracts/fixtures/m8/incident_banner_token_expired.json · incident_banner_order_rejected.json · incident_banner_network_down.json · incident_banner_none.json ·
     runbook_index.json · runbook_index_empty.json · runbook_host_lost.json · runbook_missing.json · emergency_card.json · emergency_card_no_print.json   ← ⟦v1.17⟧ 전부 보여야 함(한 줄에 하나)
  반대(없어야 함): ls packages/ui_shell/lib/src/incident · git grep -c IncidentBannerSlot -- packages/ui_shell/lib
  melos.bat bootstrap → melos.bat run build:gen → cd packages/ui_shell → flutter test ← 시작 기준 «⟦실측: +357⟧: All tests passed!»(줄 머리 시각은 실행마다 다름 · 끝 줄의 수를 «시작 기준 N» 으로 · 다르면 PR 본문에 까닭 한 줄 · 실패가 있으면 멈추고 끝 20줄을 채팅으로) → cd ../..

■ 계약 v1.17 이름표 — R16a 몫(🔴 코드가 정본 · ⟦v1.17⟧ = M2 보강 PR 이 다른 글자를 정하면 병합 기록 때 이 카드 글자를 그 글자로 고친다)
  🆕 enum IncidentKind { phoneDown, networkDown, tokenExpired, orderRejected, other }   — 아이콘 선택에만 · 모르는 wire 값 = other
  🆕 IncidentBanner({required IncidentKind kind, required UiLevel level, required String title, required String bodyText, LinkAction? action})
  🆕 IncidentBannerVm({IncidentBanner? banner})   — 최대 1건 · 고르기·정렬 = 엔진 · null = 배너 없음
  🆕 IncidentRepository { Stream<IncidentBannerVm> watchIncident(); }
  🆕 RunbookIndexVm({required List<RunbookRow> rows, String? emptyLabel}) · RunbookRow({required String title, String? summaryText, required String deepLink})
  🆕 RunbookVm({required String title, String? introText, required List<RunbookStep> steps, required String localCheckNotice, String? missingLabel}) · RunbookStep({required String orderText, required String text})
  🆕 EmergencyCardVm({required String title, required List<RunbookStep> steps, required String contactLine, required String keepOnPaperNotice, String? printSlotId})
  🆕 RunbookRepository { Stream<RunbookIndexVm> watchRunbookIndex(); Stream<RunbookVm> watchRunbook(String runbookId); Stream<EmergencyCardVm> watchEmergencyCard(); }
  🆕 OpsSlotIds.emergencyCardPrint = 'EMERGENCY_CARD_PRINT'(슬롯 이름 사전) · AppRoutes.opsRunbooks · opsRunbook · opsEmergencyCard(이 카드는 상수를 쓰지 않는다)
  LinkAction{label, deepLink} · UiLevel(기존 · dto/common.dart · enums/ui.dart) · testing.dart = UnimplementedIncidentRepository · UnimplementedRunbookRepository(🆕)
  FixturePaths  m8IncidentBannerTokenExpired(kind tokenExpired · level blocked · action non-null — 링크 = 설정 연결 화면) · m8IncidentBannerOrderRejected(orderRejected · act · action non-null) ·
                m8IncidentBannerNetworkDown(networkDown · watch · action null) · m8IncidentBannerNone(banner null) ·
                m8RunbookIndex(rows 6 · emptyLabel null) · m8RunbookIndexEmpty(rows 0 · emptyLabel non-null) · m8RunbookHostLost(steps 5 · introText non-null · missingLabel null) · m8RunbookMissing(steps 0 · introText null · missingLabel non-null) ·
                m8EmergencyCard(steps 5 · printSlotId EMERGENCY_CARD_PRINT) · m8EmergencyCardNoPrint(printSlotId null)
  🔴 쓰지 않는 것: m8/incident_token_expired(행 = ConnectionsVm · 형제 키 = AlertItem) · m8/recon_board_diff(DiagnosticsVm) · OpsStatusRepository · AlertRepository · SettingsActions · CommandApi · AppRoutes 상수 전부(m5KillSwitch 포함 — 링크 = 데이터).

■ 규칙 요약 (전문 = prompt_M8.md · 우선순위 = 코드 > 이 카드 > 01 §26(계약 v1.17) > 04 §6·§2-4·§2-1 > prompt_M8 · 정본 = 이 카드의 글자 — 앞 카드를 찾지 않는다)
 1 고치는 곳 = packages/ui_shell + inbox/D01D03_questions.md 만. 새 파일 = lib/src/incident/incident_banner.dart · runbook_list.dart · runbook_detail.dart · emergency_stop_card.dart ·
   test/incident_banner_test.dart · test/runbook_list_test.dart · test/runbook_detail_test.dart · test/emergency_stop_card_test.dart · test/golden/d01_golden_test.dart · d02_golden_test.dart · d03_golden_test.dart · 새 PNG 10.
   공용 3파일 끝 절 더하기만: lib/src/shell_providers.dart 끝 R16a 절(🆕 주입 3 — 아래 «주입 구조») · lib/ui_shell.dart export 네 줄(정렬 차례 — src/alerts/alert_detail.dart 뒤 · src/onboarding/onboarding_finish.dart 앞에
     src/incident/emergency_stop_card.dart · src/incident/incident_banner.dart · src/incident/runbook_detail.dart · src/incident/runbook_list.dart) · test/shell_fakes.dart 끝 R16a 절.
   🔴 셸 틀 1파일 허용 자리만: lib/src/shell_scaffold.dart — ① import 한 줄(import 'incident/incident_banner.dart';) ② _PhoneHome 의 body: ③ _WebBody 의 body: — 둘 다
     body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[const IncidentBannerSlot(), Expanded(child: IndexedStack(…안의 글자 그대로…))])
     (IndexedStack 안 글자·차례·Key 무변경 · format 이 들여쓰기만 바꾼다 · 그 밖 줄 0 — 정적 T08 · T29).
   고치면 반려: 그 밖 ui_shell 파일 전부(특히 lib/src/routing · lib/src/common · labels.dart · ops_home · 기존 테스트 · 기존 PNG) · domain_contracts/** · apps/** · 다른 ui_*.
 2 화면은 받은 글자와 null 여부만 본다 — 값 = banner.title · bodyText · action.label · rows[i].title · summaryText · emptyLabel · title · introText · steps[i].orderText · steps[i].text ·
   localCheckNotice · missingLabel · contactLine · keepOnPaperNotice 그대로 · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 0(라벨도 새로 0) · 🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표 금지(백틱).
 3 읽지 않는 필드: action.deepLink · rows[i].deepLink(🔴 open 인자로만) · printSlotId(빌더 인자로만) · kind(아이콘 switch 로만) · level(색 switch 로만).
 4 이동 = AppLinkOpener.open(link) — 링크 = banner.action.deepLink · rows[i].deepLink 둘뿐 · 'aaq://' 리터럴 0 · AppRoutes 0.
 5 산술·판정 0 — 허용 = null 여부 · IncidentKind 5값 · UiLevel 5값 전수 switch · Set<int> 안 넣기·빼기(로컬 체크) · 🔴 rows·steps 를 세거나·고르거나·«0 이면 문장» 0(emptyLabel·missingLabel 이 있으면 그린다 — 수를 보지 않는다) ·
   번호를 i + 1 로 짓기 0(orderText) · 체크 수 세기·«다 했음» 문장 0 · 여러 배너 고르기 0.
 6 switch = IncidentKind 5(_kindIcon) · UiLevel 5(_levelColor) · 둘뿐 · default 0.
 7 공통 조각 = ShellSkeleton · ShellErrorView 재사용 · asOf 머리·오래됨 배너 0(VM 에 asOf 없음) · 새 공용 조각 0 · 스피너 금지 · 시계 미사용 · 🔴 D-01 값 전 = 아무것도 그리지 않음(SizedBox.shrink — 스켈레톤 0).
 8 본문이다 — Scaffold·AppBar·SafeArea·Navigator 0(lib/src/incident) · 부모 높이 안 ListView(padding: EdgeInsets.zero)(D-02·D-03) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 · 간격·크기 = 정수·N.0 · 배너 높이 예약 0.
 9 새 주입 3(shellIncidentRepositoryProvider · shellRunbookRepositoryProvider · shellOpsSlotBuilderProvider) · 데이터 4(_incidentProvider · _runbookIndexProvider · _runbookProvider(family) · _emergencyCardProvider) · 주입 읽기 = 그 셋 + shellLinkOpenerProvider · 탭 안 ref.read.
10 테스트 = 받침대 extends(UnimplementedIncidentRepository · UnimplementedRunbookRepository) · 🔴 implements 가짜 0(정적 T30) · 받은 인자 전부 기록 · 호출마다 새 Stream · 가짜 공장 = 받은 call 로 삼항(C4r4b-7) · 따로 세는 변수 = 호출 수 칸뿐 ·
   공장 안 early-return if 0 · 픽스처 = main() 머리에서 final 로 한 번 읽는다(setUpAll + late 금지 · C4r4b-6) · 🔴 전제는 expect 로 · 경우를 가르기 전(if 밖)에 둔다(C4r4b-1) — 자리 = testWidgets 본문 첫머리
     (main() 바로 아래의 expect 는 테스트 밖이라 파일 적재가 OutsideTestException 으로 실패한다) · 전제 문장마다 끝에 `// pre`(ASCII · 정적 T34 가 센다 = 최소 목록의 «(전제)» 수) · 동작은 UI 를 실제로 눌러서 ·
   🔴 경우 for 는 testWidgets 밖(C4r14b-1): for (final _Case c in cases) { testWidgets('<번호> <요지> ${c.name}', (WidgetTester tester) async { … }); } · 경우 칸 name 은 테스트 이름에 쓴다(안 쓰는 칸 0 · 테스트 수 = 경우 수) ·
     경우 이름 = 레코드 name 칸 글자(비교식·삼항으로 짓지 않는다 · C4r14a-4) · 흐름 = 클로저 칸 non-null — 흐름이 없는 경우도 (WidgetTester t) async {} 를 넣고 본문은 if 없이 await c.flow(tester); 한 줄(C4r14b-2) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(ShellLabels.retry), findsNothing) + 양성 기준점 1 · DTO 를 지어 넣지 않는다(전부 픽스처 · copyWith 0 — 정적 T31) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 · 가짜의 호출 기록은 목록 == 목록 · 픽스처마다 갈리는 단언은 if/else 양쪽에 또는 expect(finder, want ? findsOneWidget : findsNothing) 한 꼴 ·
   🔴 «부재 = 데이터» 테스트(배너 없음 · 조치 없음 · 빈 목록 · 모르는 런북 · 인쇄 이름 없음)는 주입을 그대로 둔 채 데이터만 바꾼다(주입 null·빌더 null 로 띄우면 부재 단언이 공허 — 주입 null 은 따로 경우 D01-07 · D03-02 · C4r14a-6) ·
   🆕 «부재 쪽» 경우마다 양성 기준점 Key 를 최소 목록 글자대로(C4r15c-1) · 테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII · «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2) ·
   🔴 반려 꼴: bool 칸 + if 로 경우 흐름 가르기 · nullable 흐름 칸(Function(…)? flow) + if (c.flow != null) · c.name == / flow.name == 비교 · opened[0] 만 보기 · expect(a || b, isTrue) · 괄호 단언(«X 0(Y 0)» — 단언마다 따로) ·
     단언 없는 tester.takeException();(쓰면 expect(tester.takeException(), isNull) 꼴 · 정적 T35) ·
   제네릭 위젯 술어 = tester.widget<Icon>(find.byKey(const Key('d01-icon'))) · tester.widget<Checkbox>(find.byKey(const ValueKey<String>('d02-check-0'))) 꼴만 — 아이콘 단언 = icon · color 두 줄(🔴 find.byType(Icon)·find.byType(Checkbox) 류를 findsWidgets 로 세면 늘 참 · C4r5a-4) ·
     버튼 수 = find.byWidgetPredicate((Widget w) => w is ButtonStyleButton) + findsNWidgets(n) · findsNothing(🆕 C4r15d-1 — 화면마다 «화면 Text 전부» 항목에 한 줄) ·
   스켈레톤 1 = expect(find.byKey(const Key('d02-loading')), findsOneWidget) 꼴 · Key 를 단 묶음(Material·Padding·Row·ListTile)의 글자 = shownTexts(tester, find.byKey(…)) == 기대 목록(R13a 도우미 · 트리 순서) ·
   🔴 Key 가 Text 자체에 붙은 자리는 shownTexts 가 [] 를 낸다(find.descendant 는 뿌리를 세지 않는다) → 이 카드는 Key 를 Text 에 달지 않는다(전부 Material·Padding·Row·ListTile·Icon·Checkbox·TextButton · 아래 «Key 표»).
   🔴 🔒 자리(D-03 인쇄) 테스트 = R15b 가짜 슬롯 빌더 FakeShellSlotRecorder(slotId 를 받아 ValueKey<String>('fake-slot-<slotId>') 단 SizedBox 를 낸다 · 받은 slotId 를 기록 · 고치지 않는다 · 새 가짜 0)로만 ·
   🆕 기다리는 동안 두 번 누름(C4r15b-1) = 이 카드 해당 없음(쓰기 버튼 0 · 체크는 명령이 아니다) — 쓰기 버튼이 생기면 멈추고 질문 파일에 ·
   ⓡ = 정상 상태 테스트마다 expect(find.text(ShellLabels.retry), findsNothing); 한 줄(자리 = 아래 최소 목록의 «ⓡ») · ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(n)); 한 줄(n = 정수 리터럴 — 이 카드 = 6 · 5 · 5) · 🔴 전제에 hasLength 0 ·
      정적 T20·T21 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(계획 = incident_banner_test ⓡ 9 · ⓗ 0 · runbook_list_test ⓡ 5 · ⓗ 1 · runbook_detail_test ⓡ 6 · ⓗ 1 · emergency_stop_card_test ⓡ 5 · ⓗ 1 · ⟦실측: 드라이런⟧) ·
      (전제) = 계획 7 · 2 · 3 · 2(⟦실측: 드라이런 — 나눔은 최소 목록 줄마다⟧).
   «없는 쪽» 견본 · «화면 Text 전부» 견본 = 아래 글자 꼴(이 카드에 다 담았다 — 앞 카드를 찾지 않는다):
        final LinkAction? action = c.v.banner?.action;     // 경우 칸 = 표본(present = tokenExpired · absent = networkDown)
        if (action != null) {
          expect(shownTexts(tester, find.byKey(const Key('d01-action'))), <String?>[action.label]);
        } else {
          expect(find.byKey(const Key('d01-action')), findsNothing);
          expect(find.text(tokenExpired.banner!.action!.label), findsNothing);
          expect(find.byKey(const Key('d01-banner')), findsOneWidget);   // 양성 기준점
        }
        🔴 반려 꼴: if (action != null) { expect(…); }(else 없음) · if (x != null) { expect(x, isNotNull); … }(if 안의 전제 = 늘 참)
        «화면 Text 전부»(R13a T02-07 꼴 · allowed = incidentAllowed(c.v) · runbookIndexAllowed(c.v) · runbookAllowed(c.v) · emergencyCardAllowed(c.v) · 🔴 견본 뒤 ⓡ 는 테스트 끝 한 줄만 — 견본 안에 ⓡ 를 두지 않는다):
        final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
        expect(shown, isNotEmpty);
        for (final String? data in shown) {
          expect(data, isIn(allowed));
        }
        expect(find.byWidgetPredicate((Widget w) => w is ButtonStyleButton), findsNWidgets(<받은 버튼 수 — D-01 = action 이 있으면 1 · 아니면 0 · D-02·D-03 = 0>));
11 골든 = 새 PNG d01_* 4 · d02_* 4 · d03_* 2 · 높이 844 고정(dy ⟦실측: 드라이런⟧) · --update-goldens 는 d01_golden_test.dart · d02_golden_test.dart · d03_golden_test.dart 만 · 기존 PNG(70장) 재생성 0(🔴 s01_* 4장 포함 — 셸 틀을 고쳐도 배너 주입 없음이면 바이트 그대로여야 한다) · golden:approved 안 붙임 · 🔴 높이(844)는 늘리지 않는다.
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다(5분 넘게 출력이 없으면 끊고 패키지별 flutter test) ·
   패키지 테스트는 packages/ui_shell 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference · close_sinks · prefer_final_locals.
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(이 화면에는 산술이 없다).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·URL·전화번호 0 · PR·라벨·병합은 통합 담당.
15 주석 금지 낱말: AppRoutes · m5KillSwitch · OpsStatusRepository · SettingsActions · DateTime.now · Duration · 닫기 · 다시 보지 · 숨기기 · 인쇄 · 공유 · PDF · 저장 · 추천 · 권유 · 자문 · 시그널 · 해외(🔵 인쇄 슬롯은 «슬롯» 으로만 적는다).
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려** · 카드 구멍 = 반려 근거 아님.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다).
   PNG 는 이름마다 light 한 장만 연다(5장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 금지) · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 n줄» = PNG 의 글자 **행** 수(이어진 글자 행은 한 덩어리 «글자 n줄» — 쪼개지 않는다 · C4r14a-3) · «상자» = 테두리·모서리가 보이는 덩어리 · «버튼 글자» = 글자 버튼 하나 · «체크 칸» = 단계 앞 네모 하나 ·
     «아이콘» = 글자 줄 안의 작은 표식 — 상자로 세지 않는다 · 🔴 글자 줄 덩어리의 괄호 안에도 «상자» 낱말을 쓰지 않는다(사전검사 G1 은 «상자» 가 든 덩어리를 상자 하나로 센다).
     사전검사 G1 은 TextButton·Checkbox 를 «상자» 로 읽을 수 있다 — 표 칸은 이 카드 단위 그대로 · 드라이런 기대 🟡 = ⟦실측: 드라이런 — 이름·까닭⟧(그대로 둔다 · 다시 열지 않음 · 칸을 고치지 않는다 · 헛경보 · C4r5b-4 꼴).
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 제출 글은 저장 파일로) · S05 결과 줄 = 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»(사전검사 R4 · 출력 줄 수만큼 · 이 카드 기대 2줄) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M8.md 173~182행 10항) 그대로 + [x] 와 괄호만([—] 금지) · ③ = 위젯·Key 이름 나열(요약어 금지 · 상태 이름을 감싼 «» 까지 견본 글자 그대로 — C4r15a-1) · 질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외 — 꼴 = 아래 «■ 질문 파일» 상자 · C4r15c-4).

■ 프롬프트보다 이 카드가 이긴다 — 17항 (prompt_M8.md 183줄 판 v2)
 ① 2행·119행 범위 → D-01 · D-02 · D-03 ② 113~118행 → 이 카드 = D-01~D-03 · B-01·B-02 = R16b · H-03 = R16c · 나머지 = 병합됨 ③ 12~14행 → 추가 0 ④ 15~19행 링크 = 데이터 → 그대로(조치 · 런북 행) · AppRoutes 0 ⑤ 20~23행 → 그대로(시계 미사용 — VM 에 asOf 없음)
 ⑥ 24~31행 → 그대로(번호·단계 수·체크 수 계산 0) ⑦ 32~38행 → 라벨 0 · 배너 없음 = 그리지 않음(«아무 일 없음» 문장 0) ⑧ 41~47행 → 🔴 킬스위치·게이트 자리도 만들지 않는다(조치 링크만 연다) ⑨ 82~86행 → 계좌번호·앱키·전화번호 리터럴 0(정적 T28) ⑩ 87~105행 → ■ 제출
 ⑪ 106~111행 → inbox/D01D03_questions.md ⑫ 127~128행 → ui/m8-d01-incident · «[M8] D-01~D-03 장애 배너·DR 런북·긴급정지 카드» ⑬ 150행 «PDF 저장·공유·스크린샷 버튼 금지»(복구 카드) + 04 §2-1 금지 5 → 🔴 이 카드의 예외 = D-03 인쇄 하나 — 슬롯 빌더만 · 화면이 인쇄·PDF·공유 위젯을 만들거나 import 0
 ⑭ 151~152행 → 그대로(장애 배너·런북·카드 문구 = M2) ⑮ 153~154행 → 그대로(삽입 자리만 · 앱 잠금 중 킬스위치 진입 = 이 카드 범위 밖) ⑯ 172~182행 → ■ 제출 ② 상자 + 괄호
 ⑰ 🆕 04 §2-3 «탭 = 조회» → D-02 «확인» 체크만 화면 로컬 상태(저장 0 · 명령 0 · 상태 무변경 고지 = 데이터) — 이 카드에서만 · 다른 로컬 상태 0(setState 1곳 — 정적 T12)

■ 먼저 읽을 것 — ① prompt_M8.md ② 04 §6 · §2-4 · §2-1(금지 5) · §5-1c ③ 01 §26(계약 v1.17 — R16 몫) ④ domain_contracts — dto/incident.dart ⟦v1.17 · 파일 자리⟧ · dto/common.dart(LinkAction) · repositories/incident_repository.dart ⟦v1.17⟧ · testing.dart
  ⑤ ui_shell — lib/src/shell_scaffold.dart(_PhoneHome · _WebBody — 고칠 두 자리) · lib/src/common/shell_common.dart · lib/src/onboarding/viewer_pairing.dart(_resultLook · 슬롯 꼴) · lib/src/watchdog_board.dart(목록 꼴) — 읽기만 ⑥ inbox/D01D03_questions.md 머리말

■ 본받지 않는 것
 · 배너 오른쪽 × · «다시 보지 않기» · Dismissible·스와이프 · 종류 코드로 제목·본문 고르기 · 여러 배너를 화면이 고르기·정렬 · 배너 위 «자세히» 정적 글자 · 배너 자리 높이 예약(SizedBox(height: n)) · 값 전 스켈레톤으로 셸 틀 밀기
 · 런북 체크를 저장(SharedPreferences·상태 프로바이더·파일) · 체크 다 하면 «완료» 문장 · 런북 «지금 실행» 버튼 · 단계 번호를 i + 1 로 · 런북 행 탭으로 다른 런북 상수 열기
 · 카드에 계좌번호·앱키·전화번호 리터럴 · printing·share_plus·path_provider import · 화면이 인쇄 버튼을 직접 · 킬스위치 버튼을 배너·런북·카드에 상수로 · 셸 틀의 다른 줄 손대기

■ 주입 구조 — incident_banner.dart = IncidentBannerSlot(공개 · ConsumerWidget) · _incidentProvider · _kindIcon · _levelColor / runbook_list.dart = RunbookList(공개) · _runbookIndexProvider /
  runbook_detail.dart = RunbookDetail(공개 · ConsumerStatefulWidget · State 안 final Set<int> _checked = <int>{};) · _runbookProvider(StreamProvider.family<RunbookVm, String>) / emergency_stop_card.dart = EmergencyStopCard(공개) · _emergencyCardProvider ·
  🆕 shell_providers.dart 끝 R16a 절(절 머리 «// ── R16a — D-01~D-03 injection providers ──») =
    final Provider<IncidentRepository?> shellIncidentRepositoryProvider = Provider<IncidentRepository?>((Ref ref) => null);   ← 🔴 기본값 null(= 배너 부재 · 기존 셸 테스트 무수정 · 조립 앱이 구현을 준다)
    final Provider<RunbookRepository> shellRunbookRepositoryProvider = … throw UnimplementedError('shellRunbookRepositoryProvider must be overridden') …
    final Provider<ShellSlotBuilder?> shellOpsSlotBuilderProvider = … throw UnimplementedError('shellOpsSlotBuilderProvider must be overridden') …(R15b shellOnboardingSlotBuilderProvider 꼴)
  _incidentProvider = StreamProvider<IncidentBannerVm>((Ref ref) => ref.watch(shellIncidentRepositoryProvider)!.watchIncident()) — 🔴 IncidentBannerSlot 이 주입 null 을 먼저 보고 null 이면 이 프로바이더를 watch 하지 않는다 ·
  import 차례 = domain_contracts → material → flutter_riverpod → ../common/shell_common.dart → ../routing/shell_router.dart → ../shell_providers.dart · 테스트 import = 'dart:async' → domain_contracts.dart → 'package:domain_contracts/testing.dart'(RecordingLinkOpener) → material → flutter_riverpod → flutter_test → ui_shell.dart → golden/golden_support.dart → shell_fakes.dart.

■ 호출 표 — D-01: 주입 null → 부르지 않음 · 주입 있음 → watchIncident() 한 번(재시도 = 한 번 더) · shellLinkOpenerProvider(조치 탭 안) · 부르지 않는 것: OpsStatusRepository · AlertRepository · RunbookRepository.
  D-02: watchRunbookIndex() 한 번 · watchRunbook(runbookId) 한 번(인자 = 받은 runbookId 그대로 · 체크해도 다시 부르지 않음) · shellLinkOpenerProvider(행 탭 안) · D-03: watchEmergencyCard() 한 번 · 슬롯 빌더(printSlotId) · 부르지 않는 것: SettingsActions · CommandApi · IncidentRepository.

■ 상태 표 — incident: 주입 null → SizedBox.shrink() · 값 전 → SizedBox.shrink() · hasError → ShellErrorView(key: const Key('d01-fail'), onRetry: () { ref.invalidate(_incidentProvider); }) · banner null → SizedBox.shrink() ·
  runbook index: Key('d02-list-loading') · Key('d02-list-fail') · runbook: Key('d02-loading') · Key('d02-fail') · card: Key('d03-loading') · Key('d03-fail')(hasError → ShellErrorView · 값 전 → ShellSkeleton — R15 꼴).

■ 화면 1 — D-01: Material(key: const Key('d01-banner'), color: cs.surfaceContainerHighest, child: Padding(all(12), Row(crossAxisAlignment: start)[ Icon(_kindIcon(b.kind), key: const Key('d01-icon'), size: 24, color: _levelColor(cs, b.level)) · SizedBox(width: 12) ·
   Expanded(Column(crossAxisAlignment: start)[ Text(b.title) · Text(b.bodyText) · (action) TextButton(key: const Key('d01-action'), onPressed: () { open(a.deepLink); }, child: Text(a.label)) ]) ]))(final LinkAction? a = b.action;)
 ■ 화면 2 — D-02 목록: ListView(padding: EdgeInsets.zero)[ for (i, r) in rows.indexed ListTile(key: ValueKey<String>('d02-list-row-$i'), title: Text(r.title), subtitle: r.summaryText == null ? null : Text(r.summaryText!), onTap: () { open(r.deepLink); }) ·
   (emptyLabel) Padding(key: const Key('d02-list-empty'), Text(emptyLabel)) ]
 ■ 화면 3 — D-02 상세: ListView(padding: EdgeInsets.zero)[ Padding(key: const Key('d02-title'), Text(title)) → (introText) Padding(key: const Key('d02-intro'), Text(intro)) →
   for (i, s) in steps.indexed Row(key: ValueKey<String>('d02-step-$i'), crossAxisAlignment: start)[ Checkbox(key: ValueKey<String>('d02-check-$i'), value: _checked.contains(i), onChanged: (bool? v) { setState(() { … }); }) · Text(s.orderText) · SizedBox(width: 8) · Expanded(Text(s.text)) ] →
   (missingLabel) Padding(key: const Key('d02-missing'), Text(missing)) → Padding(key: const Key('d02-notice'), Text(localCheckNotice)) ](🔴 고지 = 늘 맨 아래 · 체크해도 무변경)
 ■ 화면 4 — D-03: ListView(padding: EdgeInsets.zero)[ Padding(key: const Key('d03-title'), Text(title)) → for (i, s) in steps.indexed Row(key: ValueKey<String>('d03-step-$i'), crossAxisAlignment: start)[ Text(s.orderText) · SizedBox(width: 8) · Expanded(Text(s.text)) ] →
   Padding(key: const Key('d03-contact'), Text(contactLine)) → Padding(key: const Key('d03-notice'), Text(keepOnPaperNotice)) → (printSlotId && builder) Padding(key: const Key('d03-print'), builder(id)) ]
 🆕 Row 정렬(C4r15b-2) = 이 카드의 Row 셋(d01-banner 안 · d02-step · d03-step) 모두 crossAxisAlignment: CrossAxisAlignment.start(여러 줄 엔진 글자 옆 아이콘·번호·체크가 위에 붙는다) · Column 둘(d01 안) = start ·
   🆕 아이콘 크기(C4r15d-4) = d01-icon size: 24(드라이런 글자 · 다르게 적으면 줄 수가 바뀌어 PNG 덩어리가 드라이런과 갈린다) · 여백 값 = 재량(나무가 정하지 않음 — 처음 잰 dy 뒤 바꾸면 «측정:» 전·후 행 · 아래 «■ 골든»).

■ Key 표 (d01- 4 · d02- 12 · d03- 7 = 23 — ⟦실측: 드라이런⟧) — d01-banner · d01-icon · d01-action · d01-fail · d02-list-loading · d02-list-fail · d02-list-row-$i · d02-list-empty · d02-loading · d02-fail · d02-title · d02-intro · d02-step-$i · d02-check-$i · d02-missing · d02-notice ·
  d03-loading · d03-fail · d03-title · d03-step-$i · d03-contact · d03-notice · d03-print

■ 할 일 — (1) lib 네 파일 + shell_providers R16a 절 + 배럴 + 셸 틀 두 자리 «[M8] R16a (1) D-01~D-03 화면 · 셸 틀 배선» (2) fakes 끝 절 + 네 테스트 «[M8] R16a (2) D-01~D-03 테스트»
 (3) 골든 10장 «[M8] R16a (3) 골든 d01_* 4장 · d02_* 4장 · d03_* 2장» (4) format · 질문(A1~A5 dy) «[M8] R16a (4) format · 질문» · (4) 뒤 (5) 하나만.
 🆕 커밋 제목 = 내용(C4r15c-3): (3) 에서 화면 파일(lib/)을 고치면(여백 등) 그 커밋 제목 끝에 « · 화면 여백» 을 붙인다 · 위 권장 제목 글자는 그대로 두고 덧붙이기만(12 §3 «커밋 = 제목만 맞추기» · 화면 파일이 든 커밋의 제목에 «화면» 이 없으면 안 된다).

■ 정적 라벨 — 0개(🔴 labels.dart 무변경 · 총수 37 = 정적 T13 · 재시도 = 기존 ShellLabels.retry).

■ 테스트 최소 목록 (계획 — ⟦실측: 드라이런 첫 판이 «정확히» 로 확정⟧)
 공통(이 이름 그대로): test/shell_fakes.dart 끝 절 «// ── R16a — D-01~D-03 fakes ──» = class FakeShellIncidentRepository extends UnimplementedIncidentRepository(incident 공장 · incidentCalls) ·
   class FakeShellRunbookRepository extends UnimplementedRunbookRepository(index · runbook · card 공장 · indexCalls · runbookIds(List<String>) · cardCalls) ·
   List<Override> incidentOverrides({repo, opener}) · List<Override> runbookOverrides({repo, slots, opener}) · Future<void> pumpIncidentBanner / pumpRunbookList / pumpRunbookDetail(id) / pumpEmergencyCard(WidgetTester tester, {required List<Override> overrides})(R15 pump 꼴) ·
   Set<String> incidentAllowed(IncidentBannerVm v)(= ?banner?.title · ?banner?.bodyText · ?banner?.action?.label) · runbookIndexAllowed(RunbookIndexVm v)(= rows 마다 title · ?summaryText · ?emptyLabel) ·
   runbookAllowed(RunbookVm v)(= title · ?introText · steps 마다 orderText · text · ?missingLabel · localCheckNotice) · emergencyCardAllowed(EmergencyCardVm v)(= title · steps 마다 orderText · text · contactLine · keepOnPaperNotice) ·
   테스트 파일 머리(main() 밖 · 파일마다): incident_banner_test = valueThenFail · wantKind(IncidentKind) · wantLevel(cs, UiLevel)(R15b _resultLook 색 표 사본) / 다른 셋 = valueThenFail.
 D-01 — test/incident_banner_test.dart(줄 10 · 테스트 17 · (전제) 7 계획)
 D01-01 배너 블록 차례·글자(tokenExpired · 전제 하나(expect(tokenExpired.banner?.action, isNotNull); // pre)) → shownTexts(d01-banner) == [title, bodyText, action.label] · 사슬 dy d01-icon 머리 ≤ 제목 · ButtonStyleButton findsNWidgets(1) · ⓡ.
 D01-02 종류 → 아이콘 · 등급 → 색 — 세 경우(tokenExpired · orderRejected · networkDown) · 전제 셋(expect(tokenExpired.banner?.kind, IncidentKind.tokenExpired); // pre · orderRejected · networkDown 같은 꼴) → Key('d01-icon') 의 icon == wantKind(kind) · color == wantLevel(cs, level) · ⓡ.
 D01-03 조치 탭 = action.deepLink(데이터) — 두 경우(tokenExpired · orderRejected) → tap d01-action → opener.opened == [action.deepLink] · repo.incidentCalls == 1 · ⓡ.
 D01-04 조치 없음 = 버튼 0(networkDown · 전제 하나(expect(networkDown.banner?.action, isNull); // pre) · «없는 쪽» 견본 · ButtonStyleButton findsNothing · 양성 기준점 Key('d01-banner') findsOneWidget) · ⓡ.
 D01-05 배너 없음 = 데이터(셸 틀 · none · 전제 하나(expect(none.banner, isNull); // pre) · pumpShell(androidOperator · shellOverrides + incidentOverrides) → d01-banner findsNothing · d01-fail findsNothing · 양성 기준점 Key('s01-tabs') findsOneWidget) · ⓡ.
 D01-06 셸 틀 배선 — 두 경우(androidOperator · web · tokenExpired · 전제 하나(expect(tokenExpired.banner, isNotNull); // pre)) → d01-banner findsOneWidget · getTopLeft(d01-banner).dy < getTopLeft(Key('s01-home-slot')).dy(탭 본문 위) · ⓡ.
 D01-07 주입 없음(null) = 배너 부재 · 셸 그대로(shellOverrides 만 · incident override 0 · repo 호출 0) → d01-banner findsNothing · d01-fail findsNothing · 양성 기준점 Key('s01-tabs') findsOneWidget · ⓡ.
 D01-08 상태 갈래 두 경우(값 전 = 아무것도 그리지 않음(d01-banner · d01-fail findsNothing · ShellSkeleton 0) · 에러 = d01-fail findsOneWidget) · D01-09 재시도(valueThenFail 반대 꼴 — 실패 → retry 탭 → 두 번째 값 = tokenExpired 배너 · incidentCalls == 2) · ⓡ.
 D01-10 화면 Text 전부 + 버튼 수 = action 수 · 큰 글꼴 세 경우(tokenExpired · orderRejected · networkDown · textScaler 2.0 · overflow 0) · ⓡ.
 D-02 목록 — test/runbook_list_test.dart(줄 6 · 테스트 9 · (전제) 2 계획)
 D02-01 행 차례·글자(index · ⓗ expect(index.rows, hasLength(6))) → 행마다 shownTexts(d02-list-row-$i) == [title, ?summaryText] · d02-list-empty findsNothing · ⓡ.
 D02-02 행 탭 = deepLink — 두 경우(첫 행 · 끝 행) → opener.opened == [rows[i].deepLink] · ⓡ.
 D02-03 빈 목록 = emptyLabel(데이터 · empty · 전제 둘(expect(empty.rows, isEmpty); // pre · expect(empty.emptyLabel, isNotNull); // pre) · shownTexts(d02-list-empty) == [emptyLabel] · d02-list-row-0 findsNothing · 양성 기준점 = d02-list-empty) · ⓡ.
 D02-04 상태 갈래 두 경우 · D02-05 재시도 · ⓡ · D02-06 화면 Text 전부 + 버튼 수 0 · 큰 글꼴 두 경우(index · empty) · ⓡ.
 D-02 상세 — test/runbook_detail_test.dart(줄 7 · 테스트 9 · (전제) 3 계획)
 D02-11 단계 차례·글자(hostLost · 전제 하나(expect(hostLost.introText, isNotNull); // pre) · ⓗ expect(hostLost.steps, hasLength(5))) → 사슬 dy title → intro → step-0 … step-4 → notice · step 마다 shownTexts == [orderText, text] · repo.runbookIds == ['<받은 id>'] · ⓡ.
 D02-12 «확인» 체크 = 로컬만 — tap d02-check-0 → Checkbox(value) == true · 다시 tap → false · d02-check-1 은 false 그대로 · repo.runbookIds 길이 1 그대로(다시 부르지 않음 · 목록 == 목록) · opener.opened == [] · shownTexts(d02-notice) 그대로 · ⓡ.
 D02-13 하단 고지 = 데이터 · 맨 아래(getTopLeft(d02-notice).dy > getTopLeft(ValueKey('d02-step-4')).dy · shownTexts == [localCheckNotice]) · ⓡ.
 D02-14 모르는 런북 = missingLabel(missing · 전제 둘(expect(missing.steps, isEmpty); // pre · expect(missing.missingLabel, isNotNull); // pre) · d02-step-0 findsNothing · d02-check-0 findsNothing · d02-intro findsNothing · 양성 기준점 Key('d02-missing') findsOneWidget) · ⓡ.
 D02-15 상태 갈래 두 경우 · D02-16 재시도 · ⓡ · D02-17 화면 Text 전부 + 버튼 수 0(«지금 실행» 0) · 큰 글꼴 두 경우(hostLost · missing) · ⓡ.
 D-03 — test/emergency_stop_card_test.dart(줄 6 · 테스트 9 · (전제) 2 계획)
 D03-01 블록 차례·글자(card · 전제 하나(expect(card.printSlotId, isNotNull); // pre) · ⓗ expect(card.steps, hasLength(5))) → 사슬 dy title → step-0 … step-4 → contact → notice → print · step 마다 shownTexts == [orderText, text] · ⓡ.
 D03-02 인쇄 = 슬롯 빌더 — 두 경우(빌더 있음 → d03-print findsOneWidget · slots.slotIds == [card.printSlotId!] · 빌더 null → d03-print findsNothing · 양성 기준점 Key('d03-notice') findsOneWidget) · ⓡ.
 D03-03 인쇄 이름 없음 = 부재(데이터 · noPrint · 전제 하나(expect(noPrint.printSlotId, isNull); // pre) · 빌더 있음 그대로 → d03-print findsNothing · slots.slotIds == [] · 양성 기준점 Key('d03-notice') findsOneWidget) · ⓡ.
 D03-04 상태 갈래 두 경우 · D03-05 재시도 · ⓡ · D03-06 화면 Text 전부 + 버튼 수 0 · 큰 글꼴 두 경우(card · noPrint) · ⓡ.
🔴 예고 변이: 배너 닫기 버튼 더하기 · Dismissible 로 감싸기 · 종류로 제목 고르기(엔진 글자 재사용) · 아이콘 고정(아이콘 · 색) · kind 와 level 바꿔 쓰기 · 조치 버튼 빼기 · 조치 없는데 버튼 · 다른 링크 · 배너 none 인데 빈 상자 · 주입 null 에 스켈레톤 · 에러를 부재로 · 재시도 invalidate 0 ·
   셸 틀 한 곳만 배선(웹 빼기) · 배너를 본문 아래에 · 런북 행 하나 빼기 · 행 뒤집기 · 행 탭 0 · 빈 목록에 행 · emptyLabel 빼기 · 단계 번호를 i + 1 로 · 체크 탭이 다시 부르기 · 체크가 다른 단계도 켜기 · 고지 빼기 · 고지를 위로 · missing 에 체크 칸 ·
   «지금 실행» 버튼 더하기(엔진 글자 재사용) · 연락처 줄 빼기 · 보관 고지 빼기 · 인쇄 자리 대신 FilledButton · printSlotId null 인데 인쇄 자리 · 에러를 스켈레톤 · 정적 글자 더하기 ·
   🔵 참고(표본 동치 후보 — 드라이런이 가린다): ⟦실측: 드라이런 — «조치 있으면 level 무시» 류 · 표본이 갈래를 갖지 않아 생존하는 변이⟧ · 🆕 C4r15a-2 — 변이 앵커는 적용 뒤 dart analyze 로 컴파일을 먼저 보고, 무효 변이는 같은 뜻의 대체 앵커로 표에 적는다 · C4r15b-4 — «타입이 막음» 이라 적을 변이는 드라이런에서 실제로 컴파일되는지 확인하고 되면 «테스트 + 정적이 잡음».

■ 정적 묶음 — 아래 37줄(머리 «## T01» ~ «## T37» · T05 자리 = «## S05»)을 파일로 꺼내 Git Bash 로 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다(대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 머리 ASCII · «EXIT:1» = 출력 없음 · 출력 줄 수(EXIT 줄 포함) = ⟦실측: 드라이런 — 줄 수 · EXIT:1 수 · EXIT:0 수⟧ — 붙이기 전에 세어 같은지 본다)
  🔴 터미널에 붙여 넣어 돌리지 않는다(대화형 bash 는 ! 든 줄을 건너뛸 수 있다 · bash 라고만 치면 이 PC 에서는 WSL)
  실행 꼴(packages/ui_shell 에서 · PowerShell · 손으로 옮겨 쓰지 않는다):
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R16a-Bob-D01D03.md' | sed -n '271,307p' > ../../build/r16a_static.sh"
  git hash-object ../../build/r16a_static.sh   ← b074f4441d2df344316fb771507bb3c9c4ef1bd2(= 아래 37줄 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r16a_static.sh > ../../build/r16a_static_out.txt"
  Select-String -Path ..\..\build\r16a_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음이어야 한다(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r16a_static_out.txt).Count   ← ⟦실측⟧(EXIT 줄 37 포함) · (Select-String -Path ..\..\build\r16a_static_out.txt -Pattern '^EXIT:1$').Count ← ⟦실측⟧ · -Pattern '^EXIT:0$' ← ⟦실측⟧
  ② 에 붙일 출력 = Get-Content -Encoding UTF8 ..\..\build\r16a_static_out.txt 전부(build/ 는 .gitignore 대상 — git status 는 빈 채 · 커밋 0 · 할 일의 «미리 돌리기» 도 이 꼴)
echo "## T01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart test/golden/d01_golden_test.dart test/golden/d02_golden_test.dart test/golden/d03_golden_test.dart; echo "EXIT:$?"
echo "## T02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart test/golden/d01_golden_test.dart test/golden/d02_golden_test.dart test/golden/d03_golden_test.dart; echo "EXIT:$?"
echo "## T03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart test/golden/d01_golden_test.dart test/golden/d02_golden_test.dart test/golden/d03_golden_test.dart; echo "EXIT:$?"
echo "## T04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://|'https?://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/incident; echo "EXIT:$?"
echo "## T06 source lines (4)"; git grep -nE "watchIncident\(|watchRunbookIndex\(|watchRunbook\(|watchEmergencyCard\(" -- lib/src/incident; echo "EXIT:$?"
echo "## T07 commands and other repositories 0"; git grep -nE "SettingsActions|CommandApi|OpsStatusRepository|AlertRepository" -- lib/src/incident; echo "EXIT:$?"
echo "## T08 banner slot in shell frame (2)"; git grep -n "IncidentBannerSlot()" -- lib/src/shell_scaffold.dart; echo "EXIT:$?"
echo "## T09 IncidentKind UiLevel arms (5 5)"; git grep -nE "IncidentKind\.(phoneDown|networkDown|tokenExpired|orderRejected|other)|UiLevel\.(ok|info|watch|act|blocked)" -- lib/src/incident; echo "EXIT:$?"
echo "## T10 slot builder lines (1)"; git grep -n "shellOpsSlotBuilderProvider" -- lib/src/incident; echo "EXIT:$?"
echo "## T11 forbidden words in new files 0"; git grep -nE "AppRoutes|m5KillSwitch|DateTime\.now|Duration\(|\.length|\.where\(|\.sort|\.take\(|\.isEmpty|\.isNotEmpty|\.every\(|\.any\(|TextField|print\(|Dismissible|onDismissed|SharedPreferences|IconButton" -- lib/src/incident; echo "EXIT:$?"
echo "## T12 local state lines (1)"; git grep -n "setState(" -- lib/src/incident; echo "EXIT:$?"
echo "## T13 shell labels (37)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## T14 barrel exports (20)"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## T15 shell providers (22)"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## T16 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## T17 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## T18 figures 0"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05|2\.75|22\.5)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## T19 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## T20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart; echo "EXIT:$?"
echo "## T21 H lines (hasLength)"; git grep -c "hasLength(" -- test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart; echo "EXIT:$?"
echo "## T22 d01 d02 d03 key names"; git grep -noP "(d01|d02|d03)-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/incident; echo "EXIT:$?"
echo "## T23 banned vocabulary in code 0"; git grep -nE "권장|추천|권유|자문|시그널|대부분|건너뛰|닫기|다시 보지|숨기기|인쇄|공유|일단|해외" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## T24 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## T25 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib; echo "EXIT:$?"
echo "## T26 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## T27 Scaffold AppBar Navigator in incident 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/incident; echo "EXIT:$?"
echo "## T28 phone account key literals 0"; git grep -nP "\d{2,4}-\d{3,4}-\d{4}|(?<!\d)1[56]\d{2}(?!\d)|\d{8,}" -- lib/src/incident; echo "EXIT:$?"
echo "## T29 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/src/shell_providers.dart lib/src/shell_scaffold.dart lib/l10n/labels.dart lib/src/onboarding lib/src/routing lib/src/common lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts lib/src/watchdog_board.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/alert_center_test.dart test/alert_detail_test.dart test/watchdog_board_test.dart test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/onboarding_finish_test.dart test/onboarding_restart_test.dart test/viewer_pairing_test.dart test/golden/s01_golden_test.dart test/golden/h01_golden_test.dart test/golden/h02_golden_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart test/golden/w01_golden_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart test/golden/o04_golden_test.dart test/golden/r01_golden_test.dart test/golden/v01_golden_test.dart; echo "EXIT:$?"
echo "## T30 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart test/golden/d01_golden_test.dart test/golden/d02_golden_test.dart test/golden/d03_golden_test.dart; echo "EXIT:$?"
echo "## T31 copyWith in tests 0"; git grep -n "copyWith(" -- test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart test/golden/d01_golden_test.dart test/golden/d02_golden_test.dart test/golden/d03_golden_test.dart; echo "EXIT:$?"
echo "## T32 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart test/golden/d01_golden_test.dart test/golden/d02_golden_test.dart test/golden/d03_golden_test.dart; echo "EXIT:$?"
echo "## T33 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## T34 precondition marks (pre)"; git grep -c "// pre$" -- test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart; echo "EXIT:$?"
echo "## T35 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/incident_banner_test.dart test/runbook_list_test.dart test/runbook_detail_test.dart test/emergency_stop_card_test.dart; echo "EXIT:$?"
echo "## T36 input print share widgets in incident 0"; git grep -niE "textfield|textformfield|editabletext|secretfield|url_launcher|launchUrl|printing|share_plus|path_provider|file_picker|pdf" -- lib/src/incident; echo "EXIT:$?"
echo "## T37 golden PNG total (80)"; git ls-files -- "test/golden/goldens/*.png" | wc -l; echo "EXIT:$?"
  (줄의 뜻과 기대 — T01·T02 = 0 · T03 = 7줄(d01_golden 1 · d02_golden 1 · d03_golden 1 · emergency_stop_card_test 6 · incident_banner_test 10 · runbook_detail_test 7 · runbook_list_test 6 — 계획 ⟦실측⟧ · git grep 차례 = 경로 사전순) · T04 = 0 ·
   S05 = 2줄(조치 · 행 — 줄마다 탭 콜백 안 · incident_banner.dart · runbook_list.dart) · T06 = 4 · T07 = 0 · 🔴 T08 = 2줄(_PhoneHome · _WebBody 의 body: — 정확히) · T09 = 10줄(IncidentKind 5 · UiLevel 5) · T10 = 1줄 · T11 = 0 · 🔴 T12 = 1줄(runbook_detail.dart 체크) ·
   T13 «lib/l10n/labels.dart:37»(무변경) · T14 20줄(R15 16 + R16a 4 · 차례 = l10n/labels.dart · alerts 2 · incident 4(emergency_stop_card · incident_banner · runbook_detail · runbook_list) · onboarding 7 · ops_home · ops_rhythm · routing/shell_router · shell_providers · shell_scaffold · watchdog_board) ·
   T15 22줄(R15 19 + R16a 3) · T16~T19 = 0 · T20 = 네 줄(계획 9 · 5 · 6 · 5 ⟦실측⟧) · T21 = 세 줄(계획 1 · 1 · 1 — incident_banner_test 는 0 이라 줄로 나오지 않는다) · T22 Key 이름 23(계획 ⟦실측⟧) · T23 금지 어휘 0 · T24~T28 = 0 ·
   🔴 T29 = 네 줄(shell_providers · ui_shell · shell_fakes = 둘째 수 0 · shell_scaffold = ⟦실측: 드라이런 numstat — body: 두 곳 들여쓰기 + import 한 줄⟧ · 그 밖 파일 줄 0) · T30~T32 = 0 · T33 PNG 10줄 «A» · T37 PNG 총수 «80»(R15 70 + 이 카드 10) · T34 (pre) = 계획 7 · 2 · 3 · 2 ⟦실측⟧ · T35 = 0 · T36 = 0)
  (🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다(T21 의 incident_banner_test 가 그 꼴) · T11 · T23 · T28 · T36 은 주석 줄도 센다(규칙 15) · T28 = 전화번호·4자리 대표번호·8자리 이상 숫자 꼴 — 계좌번호·앱키 꼴을 막는다)

■ 골든 — 5이름 × light/dark = 10장(전부 신규 · golden README «🆕 R16» 절 표 그대로)
  d01 — test/golden/d01_golden_test.dart · 크기 = kGoldenPhoneSize(390 × 844 · light = dark) · 저장소 = FakeShellIncidentRepository(incident: (int call) => one(flow.fixture))(🔴 testWidgets 안에서 새로 · _Flow 칸에 인스턴스 0) · 위젯 = IncidentBannerSlot() ·
    이름 d01_token_expired(tokenExpired · 맨 아래 Key('d01-action') — dy ⟦실측⟧) · d01_network_down(networkDown · 맨 아래 Key('d01-banner') — dy ⟦실측⟧) · 머리 Key('d01-banner') dy 0.0
  d02 — test/golden/d02_golden_test.dart · 저장소 = FakeShellRunbookRepository(index · runbook 공장) · 위젯 = RunbookList() · RunbookDetail(runbookId: '<표본 id>') ·
    이름 d02_list(index · 맨 아래 ValueKey<String>('d02-list-row-5') · 머리 ValueKey<String>('d02-list-row-0') dy 0.0) · d02_detail(hostLost · 맨 아래 Key('d02-notice') · 머리 Key('d02-title') dy 0.0) — dy ⟦실측⟧
  d03 — test/golden/d03_golden_test.dart · 저장소 = FakeShellRunbookRepository(card 공장) · 슬롯 = FakeShellSlotRecorder().build · 위젯 = EmergencyStopCard() · 이름 d03_card(card · 맨 아래 Key('d03-print') · 머리 Key('d03-title') dy 0.0 — dy ⟦실측⟧)
  🔴 높이 844 는 늘리지 않는다 · 넘으면 멈추고 dy 를 질문 파일에 · 탭을 찍는 골든 0(체크 켠 모습은 뷰 테스트 D02-12 가 본다).
  표(이름 · 입력 · 흐름 · 맨 아래 Key · 머리 Key):
    이름                 입력          흐름    맨 아래 Key                               머리 Key
    d01_token_expired    tokenExpired  없음    Key('d01-action')                         Key('d01-banner')
    d01_network_down     networkDown   없음    Key('d01-banner')                         Key('d01-banner')
    d02_list             index         없음    ValueKey<String>('d02-list-row-5')        ValueKey<String>('d02-list-row-0')
    d02_detail           hostLost      없음    Key('d02-notice')                         Key('d02-title')
    d03_card             card          없음    Key('d03-print')                          Key('d03-title')
  모양 = r01_golden_test.dart · v01_golden_test.dart 와 같은 (이름, 입력, 맨 아래 Key, 흐름) 목록(private class _Flow · 흐름 칸 = Future<void> Function(WidgetTester t) — non-null) × Brightness.values · 흐름 없는 이름 = (WidgetTester t) async {}(C4r14a-4) ·
  테스트 이름 '${flow.name} ${brightnessSuffix(b)}' · 주입 = pumpForGolden(tester, const IncidentBannerSlot(), brightness: b, logicalSize: kGoldenPhoneSize, wrapApp: (Widget app) => ProviderScope(overrides: incidentOverrides(repo: …, opener: RecordingLinkOpener()), child: app))(d02·d03 = runbookOverrides) →
    await tester.pump(); → await flow.steps(tester); → await tester.pumpAndSettle(); → 위치 전제 둘 → expectGolden(flow.name, b).
  위치 전제 둘 = 이 코드 글자 꼴(흐름 뒤 · expectGolden 앞 · 머리 Key = 표의 머리 Key):
    expect(tester.getBottomLeft(find.byKey(flow.bottom)).dy, lessThan(kGoldenPhoneSize.height));
    expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);
  명령(packages/ui_shell): flutter test --update-goldens test/golden/d01_golden_test.dart test/golden/d02_golden_test.dart test/golden/d03_golden_test.dart → flutter test(옵션 없이 · (3) 커밋 전 git status 에 새 PNG 10 · 새 골든 테스트 3만 ?? · M 0 — 🔴 s01_* 가 M 이면 셸 틀 배선이 틀린 것 · 멈춤).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다 · 🔴 높이는 늘리지 않는다(카드 확정값) · 머리 dy == 0 전제가 실패하면 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 ·
     🆕 골든 높이 = 카드 확정값 + 여백 재량(12 §3 확장 ⓐ~ⓔ · C4r15d-3): ⓐ 카드의 dy 기대 = 드라이런 기록 ⓑ 질문 «측정:» 행 = 잰 값 ⓒ 여백·아이콘 크기 = 재량(나무가 글자로 정한 것은 그대로) ⓓ 처음 잰 dy 뒤에 여백을 바꿨으면(늘렸든 줄였든) «측정:» 전·후 dy 행 ·
       ⓔ C4 의 PNG 바이트 대조는 가벼운 확인에만 · Bob 판 PNG 는 덩어리 대조 · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.
  dy = 이름·밝기마다 직접 잰다(lessThan(0) 임시 수정 → «Actual: <숫자>» → 되돌리기 · 커밋 0).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개 · C4r15c-4 — 행 꼴을 이 카드에 글자로 싣는다)
· D01D03_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다 · 다른 질문 파일 수정 0 · 표 끝에 새 행만 · 새 행 상태 «⬜ 미답»(«⬜» 까지 — inbox/README.md 상태 넷 중 하나) · 답 칸 비움(병합 때 통합 담당이 갱신된 문서 절을 적는다) · 칸 안 세로 막대 금지 ·
  행 앞 접두 = «D-01:» · «D-02:» · «D-03:»(🔵 예외 = 골든 dy «측정:» 행 — 접두 없이 «측정:» 으로 시작) · 파일 끝 = 표 마지막 행 뒤 줄바꿈 하나(빈 줄 0).
· 꼭 적을 것: 골든 dy — 이름마다 한 행(A1~A5 = 위 골든 표 차례 · 종류 «추측» · 첫머리 «측정:») — 이 복사 상자 5줄을 그대로 붙이고 <값> 자리에만 잰 수를 넣는다(높이 = 리터럴):
      ┌── 측정 행 복사 시작(다음 줄부터 · 5줄)
| A1 | R16a-Bob-D01D03 | 추측 | 측정: d01_token_expired dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A2 | R16a-Bob-D01D03 | 추측 | 측정: d01_network_down dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A3 | R16a-Bob-D01D03 | 추측 | 측정: d02_list dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A4 | R16a-Bob-D01D03 | 추측 | 측정: d02_detail dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A5 | R16a-Bob-D01D03 | 추측 | 측정: d03_card dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
      └── 측정 행 복사 끝(이 줄 앞까지 · 괄호는 light·dark 두 값만 감싸고 «< 높이» 는 괄호 밖 · 🔴 상태 칸 «⬜ 미답» · 답 칸 비움 그대로 — 제출 때 채우지 않는다)
  여백을 바꿨으면 A6 부터 «측정:» 전·후 행 · 더 필요해 보인 정적 라벨(🔴 만들지 말고 행으로) · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 0 · 읽지 않는 필드 · 배치 순서 · 아이콘 모양 · 골든 이름·입력 · 재량(여백) · 셸 틀 두 자리.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다 · «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋한다.

■ 제출
  (할 일 (1)~(4) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋(또는 (5)))
  cd packages/ui_shell
  flutter test test/incident_banner_test.dart   ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +17: All tests passed!» · ⟦실측⟧ · 시각은 실행마다 다름 · C4r14a-2)
  flutter test test/runbook_list_test.dart   ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +9: All tests passed!» · ⟦실측⟧)
  flutter test test/runbook_detail_test.dart   ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +9: All tests passed!» · ⟦실측⟧)
  flutter test test/emergency_stop_card_test.dart   ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +9: All tests passed!» · ⟦실측⟧)
  flutter test test/golden/d01_golden_test.dart · test/golden/d02_golden_test.dart · test/golden/d03_golden_test.dart(한 파일씩)   ← 끝 줄 그대로(기대 «+4» · «+4» · «+2» · ⟦실측⟧)
  flutter test   ← 옵션 없이 전부 통과 — 끝 줄 그대로 — 줄 머리 시각까지(기대 = 시작 기준 N + 54 — ⟦실측: 357 → «00:nn +411: All tests passed!»⟧ · N 이 다르면 N + 54)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← Git Bash 전체 경로(C4r5a-2) · 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건은 이 카드와 무관 — 그대로 둔다
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · test:contracts 의 domain_contracts 끝 줄 «⟦실측: v1.17 병합본 +n ~30⟧: All tests passed!»(이 카드 몫 0) · 🔴 melos.bat run test 가 5분 넘게 출력이 없으면 Ctrl+C 로 끊고
     packages/ui_shell 에서 flutter test(위 줄) + melos.bat run test:contracts 만 — 끊은 사실을 ② 끝에 한 줄로 · «Some tests failed»·«FAILED» 0건 · format 0 changed(&& 가 안 되면 한 줄씩 · 🔴 백그라운드·파이프 금지)
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_shell/): A lib/src/incident/emergency_stop_card.dart · A lib/src/incident/incident_banner.dart · A lib/src/incident/runbook_detail.dart · A lib/src/incident/runbook_list.dart ·
        M lib/src/shell_providers.dart · M lib/src/shell_scaffold.dart · M lib/ui_shell.dart · A test/emergency_stop_card_test.dart · A test/golden/d01_golden_test.dart · A test/golden/d02_golden_test.dart · A test/golden/d03_golden_test.dart ·
        A test/golden/goldens/d01_*.png 4장 · d02_*.png 4장 · d03_*.png 2장 · A test/incident_banner_test.dart · A test/runbook_detail_test.dart · A test/runbook_list_test.dart · M test/shell_fakes.dart · M docs/ai-context/inbox/D01D03_questions.md ·
        그 밖의 줄(특히 M lib/l10n/labels.dart · M lib/src/routing/** · M lib/src/common/** · M lib/src/ops_home.dart · M test/shell_scaffold_test.dart · M test/shell_router_test.dart · M PNG(s01_* 포함) · apps/** · packages/domain_contracts/** · 다른 ui_*) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번(C4r5e-5)
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) → 새 커밋 하나(«[M8] R16a (5) 사전검사 지적 수정» · amend 금지 · format:fix 먼저 · analyze·format 실패를 고칠 때도 이 (5) 하나) → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님.
  git push -u origin ui/m8-d01-incident
  ① 에 붙일 출력 — 파일로 받아 그 글자를 그대로(C4r14b-5 · 화면 복사·문자열 안 "$x" 배열 0):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     git -c core.quotePath=false diff --name-status origin/main...HEAD | Out-File -Encoding utf8 $env:TEMP\r16a_ns.txt
     git log --oneline origin/main..HEAD | Out-File -Encoding utf8 $env:TEMP\r16a_log.txt
     (Get-Content -Encoding UTF8 $env:TEMP\r16a_ns.txt).Count · (Get-Content -Encoding UTF8 $env:TEMP\r16a_log.txt).Count   ← 줄 수 = git 출력 줄 수(한 줄로 이어 붙었으면 다시 · 권장대로면 바뀐 파일 29줄 · 커밋 4줄 — ⟦실측: 드라이런⟧)
  cd packages/ui_shell → 위 «정적 묶음» 의 실행 꼴(파일로 꺼내 Git Bash · EXIT 확인) → cd ../..   ← ② 에 그대로 붙일 출력(r16a_static_out.txt 전부)
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M8] D-01~D-03 장애 배너·DR 런북·긴급정지 카드
  🔴 제출 글 = 아래 ①~⑤ 의 **전문**(재료·요약·«출력은 위와 같음» 이 아님) + 끝 flutter test 한 줄 — 채팅에 내지 않고 저장 파일 $env:TEMP\R16a-Bob-D01D03_submit.md 로(C4r5a-1) ·
     저장 = UTF-8 **BOM 없이** · 줄바꿈 그대로(C4r14b-5) — 편집기 도구로 쓰면 «UTF-8(BOM 없음)» · PowerShell 로 쓰면 이 꼴만: [IO.File]::WriteAllText("$env:TEMP\R16a-Bob-D01D03_submit.md", $text + "`n", (New-Object Text.UTF8Encoding($false)))
       ($text = 줄을 -join "`n" 으로 이은 글 · Set-Content · Out-File · > · 화면 복사로 저장 파일을 쓰지 않는다) ·
     🔴 채팅 답 = 두 줄뿐: «R16a-Bob-D01D03 제출 글 저장했음: <(Resolve-Path $env:TEMP\R16a-Bob-D01D03_submit.md).Path 출력>» · 사전검사 ② 끝 줄 셋(d01_ · d02_ · d03_ — « / » 로 이은 한 줄) · 대화 요약(Previous conversation summary)을 내지 않는다.
  PR 본문 5섹션을 저장 파일로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로 — 아래 자체 점검 상자는 10줄이지만 머리 글자는 사전검사가 정한다 · 🔴 «10항» 으로 고치면 🔴 R1):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 저장 파일 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지).
      🔴 N3 — 내기 전 사전검사 ② 세 번 — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일($env:TEMP\R16a-Bob-D01D03_submit.md · BOM 없이 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R16a-Bob-D01D03_submit.md --golden-prefix d01_ --goldens 4 | Out-File -Encoding utf8 $env:TEMP\r16a_pre2_d01.txt; Get-Content -Encoding UTF8 $env:TEMP\r16a_pre2_d01.txt | Select-Object -Last 1
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R16a-Bob-D01D03_submit.md --golden-prefix d02_ --goldens 4 | Out-File -Encoding utf8 $env:TEMP\r16a_pre2_d02.txt; Get-Content -Encoding UTF8 $env:TEMP\r16a_pre2_d02.txt | Select-Object -Last 1
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R16a-Bob-D01D03_submit.md --golden-prefix d03_ --goldens 2 | Out-File -Encoding utf8 $env:TEMP\r16a_pre2_d03.txt; Get-Content -Encoding UTF8 $env:TEMP\r16a_pre2_d03.txt | Select-Object -Last 1
        ← 🔴 세 출력 끝 줄 «── 결과: 🔴 0 · …» 를 눈으로 확인한 뒤에만 낸다(🔴 1 이상이면 글을 고쳐 다시 돌린다) · 출력은 채팅에 붙이지 않는다 ·
          🔵 🟡 [G1] 은 멈춤이 아니다(드라이런 기대 🟡 = ⟦실측: 드라이런 — 이름·밝기·까닭⟧ — 그 행은 그대로 낸다 · PNG 를 다시 열지 않는다 · 칸을 고치지 않는다) · 🟡 [G1] 이 그 밖의 행에서 **상자 수·덩어리 차례**를 다르게 읽으면 그 이름의 light PNG 를 다시 열어 표를 맞춘다(안 줄 수만 다른 🟡 · «덩어리로 셀 수 없어 대조하지 않았다» 🟡 는 그대로 · C4r5b-4) ·
          🔴 🟡 수가 카드 기대보다 많으면 늘어난 🟡 행의 light PNG 를 다시 열어 표를 맞춘다 — 다시 열지 않고 그대로 내면 ② 반려(C4r5d-1).
   ① 아래 «① 머리 복사 상자» 한 줄 그대로 + «바뀐 파일:» + $env:TEMP\r16a_ns.txt 글자 그대로(코드 블록 하나) + «커밋 목록:» + $env:TEMP\r16a_log.txt 글자 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: D-01 — 장애 배너(IncidentBannerSlot()) · D-02 — DR 런북(RunbookList() · RunbookDetail(runbookId:)) · D-03 — 오프라인 긴급정지 카드(EmergencyStopCard()) · 주입 shellIncidentRepositoryProvider · shellRunbookRepositoryProvider · shellOpsSlotBuilderProvider
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 10항(머리는 «12항») — 아래 복사 상자 10줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 10줄 그대로인지 «10항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다 ·
     꼴 = «N. <prompt 글자> [x] ( )» — [x] 는 글자 뒤 · 이 카드에 다 담았다 — 앞 카드를 찾지 않는다):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «정적 묶음 T16 — 허용 밖 import 0줄 · T36 인쇄·공유 패키지 0 · pubspec 무변경(T29)»
        2번 = «산술 = null 여부 · 열거 switch 둘(T09) · 번호·단계 수·체크 수 계산 0(T11) · 수치 리터럴 0(T18·T19)»
        3번 = «DateTime.now 0(T11)»
        4번 = «이 카드 범위 밖(5탭·홈·F-01) · 손익 0»
        5번 = «이 카드 범위 밖(알림 = R14) · 배너 = 받은 1건만 · 배너 없음 = 그리지 않음(D01-05)»
        6번 = «이 카드 범위 밖(DND UI = M9)»
        7번 = «이 카드 범위 밖(워치독 = R14b)»
        8번 = «시크릿 입력 0 · 입력 위젯 0(T36 · 확인 체크 = 로컬 Checkbox · setState 1곳 T12)»
        9번 = «이 카드 범위 밖(온보딩 = R15)»
        10번 = «킬스위치·게이트 자리 0 · «지금 실행» 0(D02-17) · 조치 = 받은 링크만(D01-03) · 앱 잠금 = 이 카드 범위 밖(M5)»
      ┌── 복사 시작(다음 줄부터 · 10줄)
 1. `ui_shell`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] ( )
 2. 화면 코드에 산술이 없는가 — 편차%p·진행률·경과 시간·D-day·건수 합계를 내가 만들지 않았는가 [x] ( )
 3. `DateTime.now()` 기반 카운트다운이 없는가 (신뢰 시각은 서버 값) [x] ( )
 4. 5탭에 수익률 탭이 없는가 / 홈·F-01·위젯의 손익 숫자가 0개인가 [x] ( )
 5. 알림 등급을 화면이 재분류·재정렬·재묶기하지 않는가 / 정상일 때 조용한가 [x] ( )
 6. DND UI가 P0를 끌 수 있게 보이지 않는가 [x] ( )
 7. 워치독 키·슬러그·ping URL이 화면·로그·PR 어디에도 없는가 [x] ( )
 8. 시크릿 입력을 `SecretField` 삽입으로만 처리했는가 / 자체 입력 위젯·임시 저장·확인 필드가 없는가 [x] ( )
 9. 온보딩에 «건너뛰기» 경로나 «해외주식» 항목이 없는가 / 검증 실패 문구를 의역하지 않았는가 [x] ( )
10. 🔒 삽입 자리(킬스위치·게이트·마법사)를 직접 구현하지 않았는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] ( )
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M8.md 173~182행과 같습니다)
      빈 줄 한 줄(C4r15c-6) — ② 복사 상자 10줄 바로 뒤에 빈 줄을 하나 두고 아래 «10항 줄 수» 상자를 붙인다(빈 줄이 없으면 GitHub 렌더에서 «10항 줄 수:» 가 10항 목록에 붙어 그려진다).
      10항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r16a_box2.txt)에 저장 → (Get-Content -Encoding UTF8 $env:TEMP\r16a_box2.txt).Count → 출력 한 줄을 아래 «10항 줄 수» 상자 글자 틀 그대로(코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 10):
      ┌── 10항 줄 수 복사 시작(다음 줄부터 · 4줄)
10항 줄 수:
```
<출력 한 줄>
```
      └── 10항 줄 수 복사 끝(이 줄 앞까지)
      이어서 «정적 묶음 출력:» + 37줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄부터 정확히 «<파일>:<줄> — 탭 콜백 안» 줄들(S05 출력 줄마다 한 줄 · 같은 차례 · 기대 2줄) +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(T20·T21 출력 줄 그대로 복사) + «테스트 파일별:» + 위 flutter test 일곱 파일 끝 줄 그대로(incident_banner · runbook_list · runbook_detail · emergency_stop_card · d01_golden · d02_golden · d03_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = T20 출력:
<T20 출력 줄 그대로>
ⓗ = T21 출력:
<T21 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지 · 출력이 여러 줄이면 그 줄 전부)
   ③ 스크린샷 서술 — D-01 배너 · D-01 셸 틀 · D-02 목록 · D-02 상세 · D-03 카드 · 로딩·에러 5줄(= 아래 견본 6줄 중 앞 5줄 + 로딩·에러 한 줄 · 머리와 견본이 같은 차례·줄 수 — C4r15a-1) + 골든 표 10행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2) — 이 견본 글자 그대로(상태 이름을 감싼 «» · «=» 앞뒤 띄어쓰기 · «·» 까지 한 글자도 바꾸지 않는다 · 줄을 나누거나 합치지 않는다 — C4r15a-1 · ⟦실측: 드라이런 뒤 견본 6줄 확정⟧):
         «D-01 배너» = Key('d01-banner') → Key('d01-icon') → Text(제목) → Text(본문) → Key('d01-action')(있을 때)
         «D-01 셸 틀» = Scaffold body Column → IncidentBannerSlot() → Expanded(IndexedStack)
         «D-02 목록» = ListView → ValueKey<String>('d02-list-row-$i')(있을 때) → Key('d02-list-empty')(있을 때)
         «D-02 상세» = ListView → Key('d02-title') → Key('d02-intro')(있을 때) → ValueKey<String>('d02-step-$i')(있을 때 · 안에 ValueKey<String>('d02-check-$i')) → Key('d02-missing')(있을 때) → Key('d02-notice')
         «D-03 카드» = ListView → Key('d03-title') → ValueKey<String>('d03-step-$i') → Key('d03-contact') → Key('d03-notice') → Key('d03-print')(있을 때)
         «로딩·에러» = ShellSkeleton(Key('d02-list-loading') · Key('d02-loading') · Key('d03-loading')) · ShellErrorView(Key('d01-fail') · Key('d02-list-fail') · Key('d02-fail') · Key('d03-fail'))
      골든 표 10행(한 표 · 한 행 한 줄): «| 이름 | 입력 픽스처 | 주입 | 크기 | 위치 전제 dy | 배치·잘림 |» + 바로 다음 줄 구분 줄 «|---|---|---|---|---|---|»(없으면 표로 그려지지 않는다 · C4r5d-8) · 이름 칸 = «d01_token_expired light» 꼴 ·
        입력 = 파일 이름만(경로 앞머리 없이 · C4r5e-7 — incident_banner_token_expired.json · incident_banner_network_down.json · runbook_index.json · runbook_host_lost.json · emergency_card.json) · 주입 = d03 = «슬롯 빌더» · 나머지 = «없음» · 크기 = 390×844 ·
        dy = 이름·밝기마다 잰 값 · 배치·잘림 = 이름마다 light PNG 한 장만 연다(5장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 버튼 글자 · 체크 칸 · 아이콘> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(10행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 · 🔴 사전검사 G1 출력을 옮기지 않는다) ·
        셈 단위 견본 = ⟦실측: 드라이런 PNG 2행 — d01_token_expired light · d03_card light · 드라이런 여백일 때의 값(C4r15d-4) · 꼴만 본뜬다 · 🔴 견본과 같은 이름의 행은 꼬리까지 견본 글자 그대로 — PNG 가 견본과 다르게 보이면 칸을 바꾸지 말고 질문 파일에 · C4r5d-1⟧.
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/D01D03_questions.md 출력에서 «+|» 로 시작하는 줄 전부(코드 블록 하나 · 순서 그대로 · 줄머리 «+» 까지 출력 그대로 — 지우지 않는다 · C4r5d-8 · 손으로 만들지 않는다)
   ⑤ 추측한 것 = D01D03_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(🔴 없으면 정확히 «없음» 한 낱말)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_shell 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 54 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-d01-incident` · 커밋 권장 4 · lib 새 4 + 셸 틀 1(`body:` 두 곳) · 주입 +3 · 배럴 +4 · test 새 7 + fakes 끝 절 · PNG 10 · `D01D03_questions.md` A1~A5 · `flutter test` = N + 54(⟦실측: N = v1.17 병합본 · 기대 357 → 411⟧) · 라벨 37 · 배럴 20 · 주입 22 · PNG 80 · 🔴 `s01_*` PNG 바이트 그대로 · 기존 셸 테스트 무수정.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R16a-Bob-D01D03 결과: 브랜치 ui/m8-d01-incident 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

## 5. 주의

- **5분 눈 검사**: 배너 × 버튼·스와이프 · 배너 자리 높이 예약 · 셸 틀 다른 줄 · `s01_*` PNG `M` · 체크 저장·다시 부르기 · «지금 실행» 버튼 · 번호 계산 · 카드의 숫자 리터럴(전화·계좌) · 인쇄·공유 패키지 · `AppRoutes`·`m5KillSwitch` 상수.
- 🔵 C4 사람 grep(🆕 C4r15d-5 확장 — 새 테스트 파일의 `findsWidgets|findsAtLeast` 전부 · byKey 꼴 포함 · 화면 카드 새 테스트는 0 이 기본 · C4r15a-3 · C4r14b-3 infra 후속): `git grep -nE "findsWidgets|findsAtLeast" -- packages/ui_shell/test/incident_banner_test.dart packages/ui_shell/test/runbook_list_test.dart packages/ui_shell/test/runbook_detail_test.dart packages/ui_shell/test/emergency_stop_card_test.dart` · `git grep -nE "Function\(WidgetTester [A-Za-z_]*\)\?" -- packages/ui_shell/test/` · 둘 다 출력 0 이어야 · 테스트 쪽 변이 판정 = 임시 커밋 위.
- 🔵 C4 셸 틀 확인: `git diff origin/main...HEAD -- packages/ui_shell/lib/src/shell_scaffold.dart` 를 눈으로 — `body:` 두 곳(IndexedStack 안 글자 무변경 · 들여쓰기만) + import 한 줄 밖 0 · `s01_*` PNG `git diff --stat` 0.
- ⬜ 남은 표식 ⟦…⟧ — ⓐ «v1.17» 이름표·0단계 grep·픽스처(병합 기록 때 실제 글자로 · 번호가 1.18.0 이면 그 글자) ⓑ «실측»(누적 드라이런 1번째가 채움 — 시작·끝 N · 파일별 · ⓡⓗ·(전제) · Key 수 · 정적 출력 줄 수·EXIT 수 · 🟡 기대 · dy · numstat · ③ 견본) ⓒ 자리표시자 `__R16V117_SQ__`(v1.17 병합 squash · 병합 기록이 채움) · 정적 꺼내기 범위 271~307 · 해시 `b074f44`(조립 판 = 이 기록 커밋이 잼 · 이 파일 앞쪽 줄 수나 37줄 글자가 바뀌면 다시 잰다).
- 범위 고지: 01 §8 미결 144(`ui_shell` 화면 스캔 = 카드 정적 묶음) · 밀어 넣은 화면 위 배너(미결 신설 후보) · 전역 슬롯 ① 게이트(R16 밖) — 이 카드가 닫지 않는다.

## 6. R16 이월 반영 — 12 §3 «R15a~R15d C4 이월 부록» · «R15 test-only PR 묶음» 의 «(조립 체크리스트)» 몫

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r15a-1 ③ 머리 = 견본 차례·줄 수 · «» 까지 견본 글자 그대로 | ■ 제출 ③ 머리(견본 6줄 · 상태 차례 = 견본 차례) · «보고 규칙» ③ | 견본 글자 = 드라이런 뒤 확정(⟦실측⟧) |
| C4r15a-2 드라이런 변이 앵커 = analyze 선확인 · 무효 변이 대체 앵커 | 머리 «드라이런» 줄 · 예고 변이 끝 줄 | 드라이런 변이 표(누적 드라이런 1번째) |
| C4r15a-3 사전검사 T3/T1 표본 보강 | «5» C4 사람 grep 1·2 그대로 싣기 | infra(다음 infra 창) |
| C4r15a-4 inbox README «측정» 종류 | — | 문서(다음 infra·README 창 · 바뀌면 «■ 질문 파일» 글자도) |
| C4r15b-1 «(조립 체크리스트)» 기다리는 동안 두 번 = 버튼마다 · 숨김 구현이면 Key findsNothing 또는 같은 자리 tapAt + 호출 수 — 무엇을 썼는지 | 규칙 10 «🆕 기다리는 동안 두 번 누름 = 이 카드 해당 없음(쓰기 버튼 0)» 한 줄 | 쓰기 버튼이 생기면 멈추고 질문 |
| C4r15b-2 아이콘 옆 여러 줄 글자 Row 정렬 = 카드 나무에 | «화면» 아래 «🆕 Row 정렬» 줄(Row 셋 = start · Column = start) | 여백 값 = 재량(C4r15d-3) |
| C4r15b-3 만료 글자 있는 상세 표본 | — | 다음 M2 창(v1.17 에 같이 실을 후보 · 카드 몫 아님) |
| C4r15b-4 «타입이 막음» = 컴파일 확인 | 예고 변이 끝 줄 | 드라이런 |
| C4r15c-1 «(조립 체크리스트)» «부재 쪽» 경우마다 양성 기준점 Key | 규칙 10 🆕 줄 · 최소 목록 D01-04 · D01-05 · D01-07 · D02-03 · D02-14 · D03-02 · D03-03 | — |
| C4r15c-2 «(조립 체크리스트)» 상태 아이콘 icon·color 단언 + 예고 «그 아이콘 고정» | D01-02(종류 아이콘 · 등급 색 세 경우) · 예고 «아이콘 고정(아이콘 · 색)» | — |
| C4r15c-3 커밋 제목 = 내용 | «할 일» 아래 «🆕 커밋 제목 = 내용» 한 줄 | infra(사전검사 lib/ 커밋 «화면» 점검) |
| C4r15c-4 질문 파일 행 꼴 상자 | «■ 질문 파일» 상자(측정 행 5줄 · «⬜ 미답» · 답 칸 비움 · 접두 «D-01:» 류 + «측정:» 예외 · 파일 끝 빈 줄 0) | — |
| C4r15c-5 · C4r15d-3 골든 높이 = 재량 + 기록 확장 ⓐ~ⓔ(R16 부터) | «■ 골든» «🆕 골든 높이» 줄 ⓐ~ⓔ · 규칙 11 · «■ 질문 파일» «여백을 바꿨으면» 줄 | — |
| C4r15c-6 ■ 제출 ② 상자 뒤 빈 줄 | ■ 제출 ② «빈 줄 한 줄» 줄 | — |
| C4r15d-1 «(조립 체크리스트)» 버튼 그리는 화면마다 «버튼 수 = 받은 수» | 규칙 10 견본 끝 줄 · 최소 목록 D01-01 · D01-04 · D01-10 · D02-06 · D02-17 · D03-06 | — |
| C4r15d-2 «(조립 체크리스트)» 데이터 칸 × 상태 조합 «있는 쪽» 경우 | D01-02(세 종류 × 세 등급) · D01-03(조치 있음 두 경우) · D02-14(모르는 런북 = 단계 0 · intro 0) | 표본이 갖지 않는 조합 = 질문 파일 |
| C4r15d-4 화면 나무에 아이콘 크기 | «화면» 아래 «🆕 아이콘 크기» 줄(d01-icon size 24) | — |
| C4r15d-5 «5» C4 사람 grep 1 확장 | «5» 첫 grep(새 테스트 파일 `findsWidgets|findsAtLeast` 전부) | infra(사전검사 T3) |
| 공통 교훈(R14·R5) | 머리 교훈 줄 · 규칙 10 · ■ 제출 · 정적 실행 꼴(R15d 판 글자를 이 카드 수·이름·파일로) | — |
