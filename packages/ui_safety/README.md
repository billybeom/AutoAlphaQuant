# ui_safety — M5 안전·마찰 화면 (X1 기기 이전 · X2 재개 게이트 · X5 정정 마법사)

> **owner(사양·결정)**: Claude · **코드 담당**: **Claude — 렌더링까지**
> **청사진 카드**: **M5** safety-control · **X1** device-migration(마법사) · **X2** catch-up-ledger(재개 게이트) · **X5** ledger-integrity(정정 마법사)
> **정본**: 청사진 결정 6 · `06_시스템설계/04_안전장치.md` · 01_M2_도메인계약 **§2-10 소유 경계표**

## 🔴 왜 별도 패키지인가

M5·X1·X5의 마법사 렌더는 Claude 소유인데, `ui_shell/lib/safety/` 하위 디렉터리로 두면 **다른 AI가 같은 패키지를 만지게 되어 CODEOWNERS에 의존**하게 된다. 패키지를 나누면 소유 경계가 **파일 경로로** 드러나고 검수가 기계적으로 끝난다(00_README §4 권고 채택).

**다른 AI는 이 패키지의 파일을 편집하지 않는다.** PR에 이 경로가 섞여 있으면 **즉시 반려**다(07 §9 기계 검사 3).

## 무엇을 담나

킬스위치 발동·상태 화면 · **해제 게이트**(48h 대기 + 체크리스트 7항 순차 + 저널) · 재개 게이트와 `ResumeReport` **원본 화면** · 기기 이전 마법사(리스 이양) · 원장 정정 마법사 · 플래그 **해제 조작**.

## 의존 — 허용 (01 §1-1 — 다른 ui_*와 동일)

`domain_contracts` · Flutter · `flutter_riverpod`.

## 의존 — 🔴 금지

`core_engine` · **`decimal`** · `broker_gateway` · `trading_runtime` · `data_sync` · `sqflite` · `supabase_flutter` · `http`.

> **소유자가 Claude여도 예외가 아니다.** 안전 화면이 엔진을 직접 부르면 «화면이 판정한다»가 되고, 그것이 가장 위험한 형태다. 킬스위치 발동조차 `CommandApi`를 통해 나간다.

## 이 패키지가 지는 규칙 5개

1. **불편이 사양이다**(경계 규칙 ③). 킬스위치는 **발동 즉시(확인 대화 없음)**, 해제는 **48h 대기 + 체크리스트 7항 순차 + 저널**이다. 「끄기는 쉽게, 켜기는 어렵게」의 비대칭이 설계이며, **«UX 개선» 제안은 거절이 기본값**이다.
2. **게이트를 확인 대화상자로 대체하지 않는다.** 단계를 건너뛸 수 있으면 그것은 게이트가 아니다.
3. **마찰 시간을 로컬 시계로 계산하지 않는다.** 신뢰 시각은 **Supabase 서버 시각**이고(리스 TTL·48h·냉각 30일), 화면은 `SafetyState.releaseProgress`를 **그대로 표시**한다. 폰 시계는 신뢰 대상이 아니다.
4. **해제 경로는 플래그마다 다르다.** `RECON_MISMATCH`는 원인 코드 + `decision_id`가 필요하고 `/resume`으로 풀리지 않는다. `JOURNAL_MISSING`은 **수동 해제 버튼이 존재하지 않는다**. `LEDGER_FIX`는 자동·수동 해제가 **둘 다 없다**(트랜잭션 종료 시 소멸). 문구는 `clearInstruction`을 쓴다 — 조치가 다르면 다르게 말한다.
5. **킬스위치 «해제» 명령은 계약에 없다**(결정 6). 해제는 폰의 이 게이트 전용이며, `deactivate` 추가 제안은 거절이 기본값이다.

## 다른 ui_*에 허용된 것 vs 여기만 되는 것 (01 §2-10)

경계는 «상태를 보였나»가 아니라 **«상태를 바꾸는 경로를 만들었나»**다.

| 그리는 것 | 어디 |
|---|---|
| `breakerLabel` 한 줄 · `BlockFlag` 배너(`label`·`clearInstruction`) + `clearRoute` 딥링크 · `LedgerDiffRow` 읽기 목록·상세 | 다른 ui_*도 ✅ |
| `killSwitch` · `releaseProgress` 게이지 · `stoppedReleaseEligible` 판정 UI · `ResumeReport` **원본** · 정정 마법사 · 플래그 **해제 조작** | 🔒 **여기만** |

## 지금 상태 — 🟡 스캐폴드

배럴과 빈 `labels.dart`만 있다. **⚠️ 이 PC에는 Flutter·Dart·melos가 없다**(2026-09-06).
