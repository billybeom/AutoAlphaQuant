# `J2_questions.md` — J-2 거래 상세 질문·추측 접수표

> 형식 정본 = `inbox/README.md`. 한 화면의 질문은 라운드가 바뀌어도 **이 파일에 쌓인다**(새 파일 금지). 답이 달린 행은 지우지 않고 상태만 바꾼다.
> 🔴 «답» 칸은 결론이 아니라 **어느 문서 어느 절이 갱신됐는가**다. 표는 색인이지 정본이 아니다.
>
> **R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 작성.
> **C4 R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 행 Q1~Q6 은 전부 종류 «추측»인데 `Q` 번호로 붙었다(규약 = 추측은 `A`). PR 본문이 번호로 참조하므로 **번호는 바꾸지 않는다 — 종류 칸이 정본**. C4 발견 행 = A1~A5 · 재제출 추측 행 = A6~. 다음 번호 = Q7·A6.

| 번호 | 카드ID | 종류 | 질문·추측 | 막힌 곳 | 제안 | 상태 | 답 |
|---|---|---|---|---|---|---|---|
| Q1 | J-2 | 추측 | `vm.asOf`가 신선도 판정의 기준이고 `entry.asOf`는 체결 당시라 골든 시각에 이미 오래됐다 — `JournalAsOfHeader`와 스테일 판정 모두 `vm.asOf`를 썼다 | asOf 기준 | vm.asOf 사용 | ✅ 답함 | 맞다 — 머리·신선도·**에러**의 asOf = `vm.asOf`(카드 (4) · 02 §3-2 ⓗ · 01 §11-10 «봉투 없는 VM 의 공통 상태»). 에러 상태의 `lastAsOfLabel` 누락은 A1(재제출 G9) |
| Q2 | J-2 | 추측 | 결정 체인 스텝 6개의 `Key`는 `ValueKey<String>('j2-step-$i')`(i = `vm.steps`에서 받은 순서)로 고정했다 — `stageCode`로 매핑하지 않음 | 스텝 Key | 순서 인덱스 | ✅ 답함 | 맞다 — `ValueKey('j2-step-$i')`(받은 순서) · `stageCode` 매핑 금지(카드 (4) · 02 §3-2 ⓑ) |
| Q3 | J-2 | 추측 | `configHash`를 표시하는 위젯으로 `GestureDetector(onLongPress: …)` 안에 `Text` 사용 — 모노스페이스·1줄·ellipsis·길게 누르기 복사 | configHash UI | GestureDetector | ✅ 답함 | 값·모양은 카드 (4) 그대로 · 길게 누름을 받는 위젯(`GestureDetector`)은 재량 |
| Q4 | J-2 | 추측 | `SnackBar`는 이미 렌더된 `ScaffoldMessenger.of(context)`로 내보낸다 — `context.mounted` 검사를 `async` 사용 뒤에 추가함 | 복사 완료 알림 | ScaffoldMessenger | ✅ 답함 | 카드 (4) 원문 그대로 · SnackBar 는 셸 Scaffold 가 띄운다(테스트의 `Scaffold(body:)` 는 흉내) |
| Q5 | J-2 | 추측 | 링크 버튼 4종(`parentLink`·`rebalanceLink`·`journalLink`·`amendLink`) 스타일을 `OutlinedButton`으로 구현 — 카드는 규정 없어 임의 선택 | 링크 버튼 스타일 | OutlinedButton | ✅ 답함 | 존재 규칙(non-null · `label` · 콜백 안 `open` · Key 4종)이 정본 · `OutlinedButton` 은 재량. 「이 결정의 저널」 위치는 별개 — A2 |
| Q6 | J-2 | 추측 | `j2_amended` 골든 높이 1600px에서 `journalStateLabel`이 하단 안에 들어감 — 높이 조정 불필요 | 골든 뷰포트 높이 | 1600px 유지 | 🔴 반려(재제출 G4) | 1600 은 모자라다 — `journalStateLabel` 을 상단에 둬 전제가 늘 참이 됐고 `j2_partial`·`j2_amended` 가 잘렸다. 02 §3-2 ⓖ «하단» · 카드 (6) «넘치면 높이를 올리고 값을 적는다» · 02 §3-2 ⓖ·ⓙ «(C4 R2 · 2026-09-24)» 문장 |
| A1 | J-2 | 추측 | (R2 1회차 · C4 발견) 에러 상태에 마지막 성공 `asOf.label` 을 넘기지 않는다(`decision_detail.dart:55-58`) | 공통 상태 — 에러 | — | 🔴 반려(재제출 G9) | 카드 (4) · 01 §11-10 공통 · 02 §3-2 ⓗ |
| A2 | J-2 | 추측 | (C4 발견) 「이 결정의 저널」(`journalStateLabel`)을 상단에 둬 골든 전제가 늘 참 — `j2_partial`·`j2_amended` 4장이 1600 에서 잘림 | 배치 · 골든 전제 | — | 🔴 반려(재제출 G4) | 02 §3-2 ⓖ «하단» + ⓖ·ⓙ «(C4 R2 · 2026-09-24)» |
| A3 | J-2 | 추측 | (C4 발견) 거부 추적 `reasonCode`(SAF 원문) 미표시 + 테스트가 늘 참인 단언(탭 뒤 `reasonLabel` ≥ 1)으로 가림 | 계약 값 누락 · 테스트 | — | 🔴 반려(재제출 G1) | 01 §11-10 J-2 «SAF 원문» · 02 §3-2 ⓔ 수용 (c) · ⓔ «(C4 R2 · 2026-09-24)» |
| A4 | J-2 | 추측 | (C4 발견) 임계 행 `passed`(체크/회색) 미표시 · `verdictLabel` 이 Row 안에서 Flexible 없음 | 계약 값 누락 · 390px | — | 🔴 반려(재제출 G2·G9) | 02 §3-2 ⓓ + «(C4 R2 · 2026-09-24)» |
| A5 | J-2 | 추측 | (C4 발견) 테스트 최소 목록 미달(6 픽스처 단계·링크 행렬·toString 부재·빈 테스트) · 골든 오프너 주입 · dark 칩 대비 | 테스트 · 골든 · 색 | — | 🔴 반려(재제출 G7·G8·G9) | 카드 테스트 목록 J-2 · 규칙 10·11 |
| A6 | J-2 | 추측 | (R2 재제출) 임계 `passed` 아이콘 = `Icons.check`(true) · `Icons.remove`(false) · 체인 `occurredAtText` = `Flexible` · 상태·단계 칩 글자색 = `ChipTone` 4값 exhaustive switch | G2·G9 모양 선택 | Icons.check/remove · Flexible | ✅ 구현 완료 | G2·G9 재제출에서 결정 — `Icons.check` / `Icons.remove`(gray=`cs.onSurfaceVariant`) · 체인 칩을 `Wrap`으로 · `occurredAtText`에 `Flexible` |
