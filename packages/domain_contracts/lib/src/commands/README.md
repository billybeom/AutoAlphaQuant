# `lib/src/commands/` — 명령 API 인터페이스 (G3 예정)

정본: 01_M2_도메인계약 **§4-2 명령 API · §4-3 설정·진단 주입 콜백**

| 예정 파일 | 담을 것 |
|---|---|
| `command_api.dart` | `CommandApi` · `CommandReceipt` · `CommandKind` · `CommandState` · `DepositRegistration` |
| `payloads.dart` | ~~⚠️ `JournalDraft` · `BlindReviewScore` · `DisclosureViewEvent` — **필드 미확정**. 이것이 없으면 명령 5종 중 3종을 호출할 수 없다(M2-8 최우선)~~ ✅ `JournalDraft`(H-1) · `BlindReviewScore`(H-2 · 🆕 v1.7 주석 — 점수 = 고른 `BlindReviewChoice.score` 그대로 · 01 §16) · `DisclosureViewEvent`(H-3) — 필드 확정 |
| 🆕 `safety_actions.dart` | **v1.21** 넷째 쓰기 창구 `SafetyActions`(M5 폰 로컬 · 폰 전용 · `ui_safety` 만 · 표면 `run`·`runKillResumeItem`·`runPledge`·`watch` 넷 = C-7) · `SafetyActionResult` · `SafetyActionCall`(1.21.0 사용처 0) · 제출 DTO `KillResumeItemSubmission`(숫자 = 원문 · 저널 id 칸 0)·`PledgeSubmission` · `SafetyActionId` 3(`enums/command.dart` · `run` 화이트리스트 0 — 1.22.0) · `payloads_x7.dart` `KillChecklistAck` += `activation`(🆕 `KillActivationRecord` · 한 명령 `KILL_CHECKLIST_CONFIRM`) |
| `settings_actions.dart` | `SettingsActions` · `SettingsActionId`(32종 — 🆕 v1.12 +2 `selfReportSessionStart`·`selfReportSessionStop` · 🔵 옛 «20종» 은 실물 27과 어긋난 오기였다 · 🆕 v1.19 +1 `runtimeLivePromotion` · 🔵 옛 «29종» 은 v1.16·v1.18 추가분을 빠뜨린 실물 31 의 오기였다) · 🆕 v1.19 `S05` args 화이트리스트 5(`settings_actions.dart` 머리) · 🆕 v1.20 `S02`·`S06`·`S03` args 화이트리스트 5 + 화면 미호출 1(`credentialRegister` · 값 0 추가) · `ActionResult` |

## 이 폴더가 지는 규칙

- 🔴 **앱은 DB에 쓰지 않는다**(경계 규칙 ②). Supabase **append-only** 명령 테이블에 INSERT하고 엔진이 구독·검증·집행한다. 반환값은 «요청 접수»이지 «집행 완료»가 아니다 — 화면이 `state`를 낙관 갱신하면 이 계약의 목적이 사라진다.
- 🔴 ~~**뷰어가 쓸 수 있는 것은 5종이 전부다** — 킬스위치 발동 · 저널 초안 · blind 리뷰 점수 · 열람 기록 · 입금 등록.~~
  🆕 v1.4(01 §14-2) — **뷰어가 쓸 수 있는 것은 앞 4종이 전부다** — 킬스위치 발동 · 저널 초안 · blind 리뷰 점수 · 열람 기록. 입금 등록(`registerDeposit` · `DEPOSIT_REGISTER`)은 폰(operator) 전용이다.
- 🔴 **킬스위치 «해제» 명령은 없다.** 해제는 폰 M5 재개 게이트 전용이다(결정 6). `deactivate` 추가 제안은 **거절이 기본값**이다.
- 🔴 **인자가 2개를 넘는 명령은 전부 DTO로 받는다** — `@DecimalStringConverter()`는 필드 어노테이션이라 메서드 인자에 붙여도 아무 일도 하지 않고, 직렬화 규약이 사라진 payload가 만들어진다.
- 🆕 v1.21 — `SafetyActions`(M5) 도 **`CommandApi`가 아니다**(01 §30). 재개는 7문항을 한 문항씩 통과한 결과이고, 킬스위치 «해제» 명령은 여전히 없다.
- 🔴 `SettingsActions`는 **`CommandApi`가 아니다**(§4-3). 시크릿이 관여하므로 폰(operator) 빌드에만 구현체가 주입되고, 뷰어 빌드에서는 `null`이며 그때 화면은 컨트롤을 **렌더하지 않는다**(«비활성»이 아니라 **부재**).
- 🔴 **명령 구현은 `command_queue`에 UPDATE·DELETE를 부르지 않는다**(C-16).
