# 발송 패킷 R1b-Bob-J1 — J-1 매매일지 타임라인 «완성» (계약 v1.1)

> 만든 날 2026-09-17 · 원문 = `11_앱설계/12_AI별_요청_스크립트.md`(카드 R1b-Bob-J1) · 사전 조건 «R1-Bob-J1 병합»(PR #1 ✅) + «계약 v1.1 이 `origin/main` 에 있음»(아래 2번).
> 프롬프트·규칙은 R1 과 같습니다(`docs/ai-context/prompt_M6.md` · 범위 = J-1). 07 원문은 다시 붙이지 않습니다(Bob 세션에 이미 있음).

## 0. 한 줄 목적

R1 에서 «계약이 아직 없어서» 미뤄 둔 J-1 의 나머지 — **표시 문자열 전환 · 필터 · 배지 · 이동** — 를 계약 v1.1 위에서 마무리해 PR 로 받기.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant`. **새 브랜치** `ui/m6-j1-complete`(base = 최신 `main`).

## 2. 보내기 전에 발주자가 할 것 🔴

✅ **충족(2026-09-17)** — 계약 v1.1 은 PR #4(squash `7b5018c`)로 `origin/main` 에 병합돼 있습니다. **발주자가 따로 할 것은 없습니다 — 바로 보내면 됩니다.**

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R1b-Bob-J1 — J-1 매매일지 타임라인 «완성» 라운드입니다. 프롬프트·규칙은 R1(docs/ai-context/prompt_M6.md)과 같고 범위도 J-1 하나입니다.
R1 에서 «계약이 없어서» 미뤄 둔 것들이 계약 v1.1 로 전부 풀렸습니다. 새 화면(J-2·J-5 등)은 만들지 않습니다 — J-1 에서 그쪽으로 «가는 링크»만 겁니다.

■ 먼저 할 것 — 새 계약 받기
  git checkout main && git pull --ff-only origin main
  git checkout -b ui/m6-j1-complete
  melos.bat bootstrap
  읽을 것(이 순서):
   ① docs/ai-context/01_M2_도메인계약_초안.md 의 **§11**(계약 v1.1 — 11-1 내비게이션 · 11-2 표시 문자열 · 11-3 J-1 필터·배지 · 11-4 BlockFlag · 11-7 테스트 받침대)
   ② docs/ai-context/02_화면명세_M6_매매일지_보유현황.md §3-1 의 「🆕 계약 v1.1 — J-1 R1b 범위가 열렸다」 ⓐ~ⓕ
   ③ packages/ui_journal/test/golden/README.md 끝의 「🆕 계약 v1.1」 절
   ④ 코드: packages/domain_contracts/lib/src/navigation/app_links.dart · lib/src/dto/journal.dart(TradeJournalEntry 새 필드 · JournalFilterCatalog ·
      JournalTimelineBadge) · lib/src/repositories/journal_repository.dart · lib/testing.dart

■ 할 일 6가지 (02 §3-1 ⓐ~ⓕ 와 1:1)
ⓐ 표시 전환 — 방향은 `entry.sideLabel`, 값은 `entry.quantityText`·`priceText`·`commissionText`·`taxText` 를 **그대로** 그립니다.
   `entry.side.wire` · `entry.quantity.toString()` · `entry.price.toString()` · `'${...}: ${entry.commission}'` 식의 원값 표시는 **전부 삭제**합니다
   (원값 4종은 v1.1 부터 표시용이 아닙니다). 수수료·세금은 여전히 두 값 각각(정적 라벨 «수수료»·«세금» 유지) — 더하지 않습니다.
ⓑ 화면측 가림 삭제 — `FlagIds.ledgerIntegrity` 를 보고 값을 숨기던 분기(timeline.dart 의 «hides engine-computed values» 부분)를 **지웁니다**.
   가림은 엔진이 `*Text` 안에서 끝내서 줍니다(「숨김」·「120주?」). 화면은 배너만 얹습니다. 플래그를 보고 값을 바꾸거나 감추는 코드는 v1.1 부터 반려입니다.
   (표식 플래그/차단 플래그를 `FlagIds.markerOnly` 로 가르는 것은 그대로 유지.)
ⓒ 필터 5축 — 기간 = `ConfigRepository.watchRangePresets()`(첫 값은 목록에서 `isDefault == true` 인 항목 — 날짜를 만들지 않습니다) ·
   슬리브 = `ConfigRepository.watchSleeves()` · 상태·출처·종목 = `JournalRepository.watchFilterCatalog()`.
   선택지의 목록·순서·문구는 받은 그대로. 「전체」(필터 없음) = 인자 null — 그 버튼 문구와 「필터」·「적용」·「초기화」 같은 글자는 정적 라벨(labels.dart).
   고른 값은 `watchTimeline(range:, sleeve:, symbol:, status:, origin:)` 인자로 **그대로** 넘깁니다. 🔴 화면이 rows 를 거르지 않습니다(거르기도 판정).
   `ConfigRepository` 주입 프로바이더를 하나 더합니다(`journalConfigRepositoryProvider` — 기존 주입 프로바이더와 같은 모양: throw UnimplementedError).
   R1 의 `JournalTimelineQuery`/`journalTimelineQueryProvider` 는 «사용자가 고른 필터 상태»를 담는 Notifier/StateProvider 로 바꿔도 됩니다(초기값 = 기본 프리셋).
   폰 폭(390px)에서 필터는 한 줄 칩 바 + 바텀시트 또는 가로 스크롤 — 레이아웃은 재량이되 어떤 픽스처 문자열도 넘치지 않아야 합니다.
ⓓ 배지 — `JournalRepository.watchTimelineBadges()` 의 각 배지를 `label` 그대로 그립니다. 색은 `tone`(ChipTone — 기존 상태 배지와 같은 매핑).
   탭 = `deepLink`(null 이면 탭 반응 없음). 목록이 비면 배지 줄 자체가 없습니다. 🔴 rows 를 세어 건수를 만들지 않습니다.
ⓔ 이동 — 전부 `AppLinkOpener.open(link)` 하나로. 주입 프로바이더 `journalLinkOpenerProvider`(Provider<AppLinkOpener>, throw UnimplementedError)를 둡니다.
   · 행 탭 = `entry.detailDeepLink`(null 이면 무반응) · 사유 칩 탭 = `chip.detailDeepLink`(null 이면 무반응)
   · 차단 배너의 이동 화살표 = `flag.clearDeepLink`(🔴 null 이면 화살표 **부재** — 비활성으로 그리지 않음) · 배너 보조 줄 = `flag.checkpointLabel`(null 이면 없음)
   🔴 화면은 링크 문자열을 만들지도 해석하지도 않습니다 — `'aaq://…'`·`'handbook://…'` 리터럴, `startsWith`, 문자열 보간으로 링크 조립 = 전부 반려
   (tool/check_boundaries.sh [5] 가 lib/ 의 링크 리터럴을 실패로 잡습니다). `AppRoutes.*` 상수도 이번 범위에서는 쓸 일이 없습니다.
ⓕ 테스트·골든
   · 가짜 리포지토리는 `import 'package:domain_contracts/testing.dart';` 후 `extends UnimplementedJournalRepository`·`UnimplementedConfigRepository`
     (필요한 메서드만 override). 기존 두 테스트 파일의 가짜는 M2 가 이미 그렇게 바꿔 두었습니다.
   · 링크 확인은 `RecordingLinkOpener` 주입 → 탭 → `expect(opener.opened, <String>[entry.detailDeepLink!])` 처럼 **픽스처에서 읽은 값**과 비교. 테스트에도 링크 리터럴 금지.
   · 입력 픽스처(golden_support.dart 의 `listFixture`·`singleFixture`·`fixtureEnvelope` 사용):
       필터 = FixturePaths.m6JournalFilterCatalog(1행) · rangePresets4 · sleeveCatalog4 / 배지 = m6JournalBadges2 /
       무결성 가림 = m6JournalMaskedIntegrity + safetyFixtureRow(4)
   · 단위 테스트 최소: ① 값이 `*Text` 그대로 보인다(원값 문자열이 위젯 트리에 없다 — 예 find.text(entry.price.toString()) findsNothing 은 값이 같은 경우가 있으니
     «priceText 가 보인다» 쪽으로) ② 기본 프리셋(isDefault)이 첫 구독의 range 로 넘어간다(가짜가 받은 인자를 기록) ③ 필터를 고르면 그 값이 watchTimeline 인자로 간다
     ④ 배지 label·탭 링크 ⑤ 배지 0건이면 배지 줄 없음 ⑥ 행 탭·칩 탭·배너 화살표 링크 ⑦ clearDeepLink == null 인 플래그에 화살표 없음 ⑧ checkpointLabel 표시
   · 골든: 기존 4종(`j1_normal`·`j1_blocked`·`j1_empty`·`j1_prevented`)은 표시가 바뀌므로 **이 PR 에서 다시 찍습니다**(M2 승인 — PR 본문에 「계약 v1.1 표시 전환으로 재생성」 명시).
     (CI «골든 스냅샷» 잡은 기존 골든 수정을 실패로 잡습니다 — 정상입니다. 통합 담당이 확인 후 `golden:approved` 라벨로 통과시킵니다. 라벨을 직접 붙이지 마십시오.)
     새로 3종: `j1_masked_integrity`(가림 픽스처 + safety 4행) · `j1_badges`(journal30 + 배지 2건) · `j1_filter_open`(필터 UI 가 펼쳐진 상태). × light/dark.
     `flutter test --update-goldens test/golden/j1_golden_test.dart` 1회 → 이후 `flutter test` 로 통과 확인.

■ 그대로인 것
본문 위젯만(Scaffold·AppBar 금지) · 신선도 판정은 주입 Clock · activeFlags 는 받은 순서 상위 2 + '+N' · 손익 없음 · 한국어 리터럴은 labels.dart 에만 ·
의존 3패키지 · 픽스처·하네스·pubspec 은 고치지 않음. 「미이행 안내 n건」 배지는 이번에도 범위 밖(X7 R5).

■ 제출
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS 확인
  git push -u origin ui/m6-j1-complete  →  PR 제목 `[M6] J-1 매매일지 타임라인 완성(계약 v1.1)` (PR 생성이 막히면 R1 처럼 브랜치 푸시 + PR 본문을 채팅으로)
  PR 본문 5섹션(① 화면 ID ② 자체 점검 — 코드에 실제로 있는 것만 [x] ③ 스크린샷 서술 ④ 질문 표 ⑤ 추측한 것) ·
  질문은 docs/ai-context/inbox/J1_questions.md 에 이어서(Q3 부터).
```

---

## 3-1. 받아야 하는 것

PR 1개(`ui/m6-j1-complete`) — `timeline.dart`(또는 분리한 파일들) · `labels.dart` · 테스트 · 골든 14장(기존 8 재생성 + 신규 6) · `inbox/J1_questions.md` 갱신.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R1b-Bob-J1 결과: PR #<번호> — 병합 검사하고 질문 반영해줘
```

(Bob 이 PR 을 못 만들면: `R1b-Bob-J1 결과: 브랜치 ui/m6-j1-complete 푸시됨 — PR 만들고 병합 검사해줘` + Bob 이 준 PR 본문을 아래에 붙여넣기)

## 5. 주의

- 5분 눈 검사 추가 2항: ① 화면 코드에 `aaq://` 글자가 없을 것 ② 차단 상태에서 값을 감추는 `if` 가 없을 것(배너만).
- 기존 골든 8장이 바뀌는 것은 이번에 한해 정상입니다(표시 문자열 전환). 다음 라운드부터는 다시 «골든이 바뀌면 위조 의심»입니다.
- 그래서 CI 의 «골든 스냅샷» 잡이 **처음에는 빨간색으로 실패하는 것이 정상**입니다(기존 골든 수정 탐지). Claude 가 병합 검사에서 바뀐 그림을 확인한 뒤 PR 에 `golden:approved` 라벨을 붙여 통과시킵니다 — Bob·발주자는 라벨을 붙이지 않습니다.
