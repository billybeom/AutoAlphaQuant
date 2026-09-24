# `J2_questions.md` — J-2 거래 상세 질문·추측 접수표

> 형식 정본 = `inbox/README.md`. 한 화면의 질문은 라운드가 바뀌어도 **이 파일에 쌓인다**(새 파일 금지). 답이 달린 행은 지우지 않고 상태만 바꾼다.
> 🔴 «답» 칸은 결론이 아니라 **어느 문서 어느 절이 갱신됐는가**다. 표는 색인이지 정본이 아니다.
>
> **R2-Bob-J2J3 1회차(2026-09-24 · 브랜치 `ui/m6-j2-detail`)** — Bob 작성.

| 번호 | 카드ID | 종류 | 질문·추측 | 막힌 곳 | 제안 | 상태 | 답 |
|---|---|---|---|---|---|---|---|
| Q1 | J-2 | 추측 | `vm.asOf`가 신선도 판정의 기준이고 `entry.asOf`는 체결 당시라 골든 시각에 이미 오래됐다 — `JournalAsOfHeader`와 스테일 판정 모두 `vm.asOf`를 썼다 | asOf 기준 | vm.asOf 사용 | ⬜ 미확인 | |
| Q2 | J-2 | 추측 | 결정 체인 스텝 6개의 `Key`는 `ValueKey<String>('j2-step-$i')`(i = `vm.steps`에서 받은 순서)로 고정했다 — `stageCode`로 매핑하지 않음 | 스텝 Key | 순서 인덱스 | ⬜ 미확인 | |
| Q3 | J-2 | 추측 | `configHash`를 표시하는 위젯으로 `GestureDetector(onLongPress: …)` 안에 `Text` 사용 — 모노스페이스·1줄·ellipsis·길게 누르기 복사 | configHash UI | GestureDetector | ⬜ 미확인 | |
| Q4 | J-2 | 추측 | `SnackBar`는 이미 렌더된 `ScaffoldMessenger.of(context)`로 내보낸다 — `context.mounted` 검사를 `async` 사용 뒤에 추가함 | 복사 완료 알림 | ScaffoldMessenger | ⬜ 미확인 | |
| Q5 | J-2 | 추측 | 링크 버튼 4종(`parentLink`·`rebalanceLink`·`journalLink`·`amendLink`) 스타일을 `OutlinedButton`으로 구현 — 카드는 규정 없어 임의 선택 | 링크 버튼 스타일 | OutlinedButton | ⬜ 미확인 | |
| Q6 | J-2 | 추측 | `j2_amended` 골든 높이 1600px에서 `journalStateLabel`이 하단 안에 들어감 — 높이 조정 불필요 | 골든 뷰포트 높이 | 1600px 유지 | ⬜ 미확인 | |
