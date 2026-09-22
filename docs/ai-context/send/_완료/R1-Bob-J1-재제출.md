# 발송 패킷 R1-Bob-J1 — 재제출 (1회차 반려 · 2026-09-17)

> 만든 날 2026-09-17 · 1회차(2026-09-16 수신)의 C4 병합 검사 결과가 **반려**여서 만든 패킷입니다. 프롬프트·규칙은 이전과 같고(`docs/ai-context/prompt_M6.md`) 이 패킷은 **반려 사유 + 고칠 것 + 제출 절차**만 담았습니다. 07 원문은 다시 붙이지 않습니다(Bob 세션에 이미 있음).

## 0. 한 줄 목적

같은 브랜치 `ui/m6-j1-timeline`에서 반려 사유를 고쳐 **커밋·푸시·PR**까지 마치게 하기.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant`. 브랜치는 그대로.

## 2. 보내기 전에 발주자가 할 것 🔴

Claude 가 `main`에 올린 커밋(픽스처 `m6/journal_empty.json` · 골든 하네스 · 질문 답 · 문서 사본)이 **원격 `origin/main`에 있어야** Bob의 PR base 가 맞습니다. Claude에게 **「푸시해」** 한 번 → 그다음 이 패킷을 보냅니다.

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R1-Bob-J1 재제출 요청 — 1회차 판정: 반려(병합 불가). 사유와 고칠 것을 전부 아래에 적었습니다.
프롬프트·규칙은 이전(docs/ai-context/prompt_M6.md)과 같습니다. 범위는 여전히 J-1 하나입니다.

■ 왜 반려인가 (3가지)
1. 기계 검사 실패 — 저장소 루트의 `melos.bat run format`(CI «포맷» 게이트)이
   packages/ui_journal/lib/src/timeline.dart · packages/ui_journal/test/timeline_test.dart 2파일에서 실패합니다.
   (analyze · test:contracts · boundaries · labels 는 통과했습니다.)
2. 제출물 4종이 오지 않았습니다 — ① PR(커밋·푸시 자체가 없음) ② docs/ai-context/inbox/J1_questions.md
   (채팅 인라인으로만 보고) ③ 위젯 골든 PNG(하네스가 없다는 질문은 맞았고, 이제 제공됨) ④ 스크린샷 4장.
3. 계약이 값을 이미 주는데 화면이 그리지 않은 것과, 질문 목록에 적지 않고 추측한 것이 있습니다(아래 F2~F8).

■ 먼저 할 것 — 새 팩 받기 (같은 브랜치에서)
  git fetch origin
  git merge --ff-only origin/main
  ← Claude 가 main 에 올린 것: packages/domain_contracts/fixtures/m6/journal_empty.json ·
     packages/ui_journal/test/flutter_test_config.dart · test/golden/golden_support.dart ·
     test/golden/README.md(하네스 레시피 + j1_golden_test.dart 뼈대) · docs/ai-context/inbox/J1_questions.md(질문 답) ·
     docs/ai-context/01·02 문서 사본(팩 판 2026-09-17)
  그다음 읽을 것(이 순서): docs/ai-context/inbox/J1_questions.md 의 «답» 칸 → 02_화면명세 §3-1 「🔵 C4 R1 반영」
  → §2-1 「🔵 C4 R1 명확화」 → §2-2 「✅ 확정(2026-09-17)」 → packages/ui_journal/test/golden/README.md 「하네스」.

■ 고칠 것 — packages/ui_journal/lib/src/timeline.dart (번호는 J1_questions.md 의 A 번호와 같음)
F1  포맷: 저장소 루트에서 `melos.bat run format:fix` 실행 후 `melos.bat run format` 이 초록인지 확인.
F2  (A1) 맨 위 `const SizedBox(height: 56)` 삭제. 띠는 셸(M8)이 화면 바깥에 쌓습니다 — 화면은 부모가 주는 높이
    안에서 스크롤되게만 만들고 고정 높이를 예약하지 않습니다. (최상위 Column 도 불필요하면 걷어 내십시오.)
F3  (A4) 오래된 데이터 판정: `journalClockProvider = Provider<Clock>((Ref ref) => throw UnimplementedError())` 를
    공개하고, `result.asOf.observedAt.add(result.asOf.staleAfter).isBefore(clock.nowUtc())` 가 true 이면 배너.
    배너 제목 = labels.dart 정적 라벨 `staleBannerTitle = '오래된 데이터'`, 본문 = `asOf.staleLabel`(null 이면 제목만).
    🔴 `staleLabel != null` 만으로 판정하지 않습니다. `DateTime.now()` 는 여전히 금지 — 시계는 주입된 Clock 입니다.
F4  (A5) 차단 플래그:
    (a) `flag.flagId == 'LEDGER_INTEGRITY'` → `flag.flagId == FlagIds.ledgerIntegrity`(계약 상수).
    (b) `FlagIds.markerOnly.contains(flag.flagId)` 인 플래그는 경고 카드가 아니라 회색 «정보 칩» 줄에 그립니다(02 §2-2 표).
    (c) 배너 대상 플래그는 받은 순서 그대로(엔진이 정렬해 줌 — 재정렬 금지) 상위 2개만 카드, 3개 이상이면
        `'+${n - 2}'` 같은 개수 표기 하나(문장 금지).
    (d) LEDGER_INTEGRITY 일 때 숨기는 것은 «엔진이 계산한 값» — quantity · price · commission · tax 만.
        `side.wire` · `visibilityLabel` 문구는 남깁니다.
F5  (A6) 누락 요소 추가: `entry.deviation.isDeviation == true` 면 `deviation.label` 배지 · `accountAlias`(null 아니면) ·
    `statusTone == ChipTone.prevented` 행에 자물쇠 아이콘(Icons.lock_outline) · `mode.isSim` 행 회색조(색 매핑은 재량) ·
    에러 상태(_TimelineError)에 마지막 성공 값의 `asOf.label` 표기(`timeline.valueOrNull?.asOf.label`).
F6  (A3) 비용: `entry.commission` · `entry.tax` 를 각각 표시. 필드 이름은 labels.dart 정적 라벨
    `commission = '수수료'`, `tax = '세금'`. 🔴 두 값을 더하지 않습니다(C-4). 값은 `toString()` 원문(포맷 금지).
F7  (A2) 방향: `side.wire`(BUY/SELL) 원문 표시 유지. 🔴 labels.dart 에 매수/매도를 두고 side 로 고르지 마십시오
    (분기 생성 — 계약 결함으로 등록돼 M2 가 sideLabel 을 추가할 예정).
F8  정리: `JournalTimelineQuery.limit`·`withLimit` 은 쓰이지 않습니다 — 삭제하거나 limit 프로바이더 하나로 통일.
F9  만들지 마십시오(질문에 답함 — R1 범위 밖, 다음 라운드): 필터 UI · 행 탭→J-2 · 칩 탭→핸드북 딥링크 ·
    「확인 중 N건」 J-5 배지 · 「미이행 안내 n건」 배지. 자리표시자(비활성 버튼)도 두지 않습니다.

■ 골든 4종 × light/dark — packages/ui_journal/test/golden/README.md 「하네스」 절대로
  test/golden/j1_golden_test.dart 작성(뼈대는 README 에 있음) → 패키지 루트(packages/ui_journal)에서
  `flutter test --update-goldens test/golden` **한 번** → test/golden/goldens/j1_*_{light,dark}.png 8장 확인 → 커밋.
  입력은 전부 픽스처: normal = journal_30 + safety_states 0행 / blocked = journal_30 + safety_states 3행 /
  empty = m6/journal_empty.json / prevented = journal_30 의 status == prevented 슬라이스. 시계 = FixedClock(kGoldenNowUtc).
  🔴 flutter_test_config.dart · golden_support.dart · 픽스처는 고치지 않습니다.

■ 질문 파일
  docs/ai-context/inbox/J1_questions.md 에 Q1·Q2(답 포함)·A1~A9 가 이미 있습니다. 새로 막히는 것은 같은 표에 Q3 부터
  추가하십시오(형식 = inbox/README.md). 채팅으로만 묻지 마십시오.

■ 제출
1. 저장소 루트에서 `melos.bat run format` · `melos.bat run analyze` · `melos.bat run test:contracts` · `melos.bat run test`
   전부 초록.
2. `git add packages/ui_journal docs/ai-context/inbox/J1_questions.md` → 커밋(메시지 첫 줄 `[M6] J-1 매매일지 타임라인`).
   🔴 packages/domain_contracts · fixtures · docs/ai-context 의 다른 파일은 스테이징하지 않습니다(CODEOWNERS — 들어 있으면 자동 반려).
3. `git push -u origin ui/m6-j1-timeline`
4. PR 생성(GitHub → Compare & pull request · base = main): 제목 `[M6] J-1 매매일지 타임라인`, 본문은 5섹션 순서대로 —
   ① 구현한 화면 ID ② 자체 점검 10항 체크박스(전부 채움) ③ 스크린샷 4장(로딩·정상·빈·차단 · 폰 세로 — 골든 PNG
   8장 첨부로 대체 가능) ④ 질문 목록(J1_questions.md 링크 + 새 Q 요약) ⑤ 추측한 것 목록(없으면 «없음»).
5. 완료 문장(그대로): 「R1-Bob-J1 재제출: PR #<번호> — 병합 검사해 주세요」

■ 손대지 말 것
packages/domain_contracts/** · packages/domain_contracts/fixtures/** · packages/ui_journal/test/flutter_test_config.dart ·
packages/ui_journal/test/golden/golden_support.dart · docs/ai-context/**(inbox/J1_questions.md 에 새 행 추가만 예외) · 기존 골든 PNG.
```

---

## 3-1. 받아야 하는 것

① PR — 같은 브랜치 `ui/m6-j1-timeline`, 제목 `[M6] J-1 매매일지 타임라인`, 본문 5섹션 ② `docs/ai-context/inbox/J1_questions.md` 에 Q3~ 추가분(없으면 그대로) ③ 위젯 골든 PNG 8장(A 상태로 추가) + `test/golden/j1_golden_test.dart`.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R1-Bob-J1 재제출 결과: PR #<번호> — 병합 검사하고 질문 반영해줘
```

## 5. 주의

- 넘기기 전 5분 눈 검사 4항은 1회차와 같습니다 — ① 픽스처 문구와 화면 문구가 같은가 ② 타임라인에 손익 숫자가 없는가 ③ 명세에 없는 요약 숫자를 만들지 않았는가 ④ 킬스위치 같은 안전 화면을 그리지 않았는가.
- 추가 1항: PR 의 «Files changed» 에 `packages/domain_contracts/` 또는 `docs/ai-context/`(질문 파일 제외)가 보이면 그 자체로 반려입니다.
