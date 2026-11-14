// 01 §4-2 · §5-1 — 앱이 호출할 수 있는 **전부**.
//
// 🔴 경계 규칙 ②. 앱은 DB 에 쓰지 않는다. Supabase append-only 명령 테이블에 INSERT 하고
//    엔진이 구독·검증·집행한다. 반환값은 «요청 접수»이지 «집행 완료»가 아니다.
// 🔴 구현은 `command_queue` 에 UPDATE·DELETE 를 부르지 않는다(C-16).
// 🔴 **킬스위치 «해제» 명령은 없다**(결정 6). 해제는 폰 M5 재개 게이트 전용이며
//    `deactivate` 추가 제안은 **거절이 기본값**이다.
// 🔴 **뷰어가 쓸 수 있는 것은 앞 4종이 전부다**(킬스위치·사전 저널·blind 리뷰·열람 기록).
//    🆕 v1.4 정정(01 §14-2) — 구 «앞 5종»의 다섯째 `registerDeposit`(`DEPOSIT_REGISTER`)는
//    **폰(operator) 전용**이다(RLS 01 §6-4 `command_insert_viewer` · DDL `batch_d_supabase.sql`
//    과 일치). X7 8종(+ `LEDGER_EVENT_RECORD`)도 전량 폰 전용이라 뷰어 화이트리스트를 건드리지 않는다. ⏸ `ALERT_ACK` 의 뷰어 허용만 §8-10 미결이고
//    현행 4종 화이트리스트를 유지한다(J-3).
// 🔴 화면은 `CommandReceipt.state` 를 스스로 낙관 갱신하지 않는다.
// 🔴 **`OperatingMode` 전환은 여기 없다** — `SettingsActionId.runtimeOperatingModeSwitchRequest`
//    1종이며 반환 `ActionResult.handoffRoute` 로 위저드에 넘긴다(§4-3).
// 🆕 v1.12(01 §21 · K4) — X7 기록 3종(`recordManualFill`·`skipAdvice`·`submitSelfReportBalance`)의 인자 = «화면 제출»
//    DTO(원문 · `payloads_x7.dart`). 화면은 와이어 DTO·`CommandContext` 를 만들지 않는다 — 파싱·맥락 부착·세션 시각은
//    이 인터페이스의 구현이 한다(실패 = 큐 적재 없는 `rejected` 접수증 `INPUT_INVALID`).
// 🆕 v1.15(01 §24 · K12) — `acknowledgeAlert` 인자 = `String alertId`(와이어 `AlertAck` = 구현이 만든다).

import 'command_receipt.dart';
import 'payloads.dart';
import 'payloads_x7.dart';

/// 명령 발행 창구.
abstract interface class CommandApi {
  Future<CommandReceipt> activateKillSwitch({
    required String reasonFreeText,
    required String deviceId,
  });

  /// 사전 저널 제출(폰 · `J-3`). viewer 경로를 그리는 화면은 없다(`J-3` = 폰 전용 · 01 §11-10).
  /// 🔴 🆕 v1.2 부터 «초안»은 제출 **전** 기기 로컬 입력 원문(`DraftStore` · 01 §12-1)을 뜻한다 —
  ///    이 메서드는 그것이 아니라 **제출**이다(인자 이름 `JournalDraft` 는 그대로).
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft);

  /// 사후 blind 리뷰(결정 9b).
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score);

  /// 열람 기록(결정 8).
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event);

  /// 실입금 등록 — 🔴 폰(operator) 전용(01 §14-2). 🆕 v1.4 인자 = `planId` 하나.
  /// 1회 호출 · 이후 상태는 [watchCommand] 의 `stateLabel` 로만 안다(01 §14 · D7).
  Future<CommandReceipt> registerDeposit(DepositRegistration registration);

  /// 명령 1건의 접수증 흐름 — 화면이 `state` 를 갱신하는 **유일한** 경로(낙관 갱신 금지).
  ///
  /// 🔴 구현 의무(🆕 v1.2 · 시그니처 무변경 · 01 §4-2 · §12-1-6 ⑦) — `DraftStore.load` 가 복원한
  ///    `lastCommandId` 의 재구독이 잠긴 채 멈추지 않게:
  ///    ① 로컬 내구 큐 ⓐ 에만 있는 명령도 첫 값(`requested` — «전송 대기»)을 **곧바로** 낸다.
  ///    ② 종단 상태(`executed`·`rejected`·`expired`) 전에는 **완료하지 않는다**(값 없이 끝나지 않는다).
  ///    ③ 모르는 [commandId] 는 스트림 **에러**로 알린다(침묵·빈 완료 금지).
  ///    🆕 v1.12 ④(01 §21 · K42) — 이 구현이 큐 적재 없이 낸 **로컬 거부 접수증**(`INPUT_INVALID`·
  ///    `SELF_REPORT_OUTSIDE_SESSION`)의 id 도 종단 `rejected` 1값을 곧바로 다시 낸다(기기 로컬 보관 — ③ 의
  ///    «모르는 id» 가 아니다 · 복원 재구독이 잠금에 갇히지 않게).
  /// 화면: 스트림 에러 = 마지막 접수증 유지(01 §8 미결 51 ③) · 복원 재구독의 첫 접수증 전 에러·완료 =
  /// 잠금 유지 + 정적 «다시 시도»(01 §12-4). 명령 메서드 `Future` 의 에러는 «접수 실패»다(01 §4-2).
  Stream<CommandReceipt> watchCommand(String commandId);

  // ───── 🆕 X7(§10) 7종 + 🆕 v1.12 `deferAdviceConfirm` — 🔴 전량 폰(operator) 전용 ─────

  /// 사실 추가. 🆕 v1.12 인자 교체(구 `ManualFillRecord` — 와이어는 구현이 만든다 · K4).
  Future<CommandReceipt> recordManualFill(ManualFillSubmission submission);

  /// 정정 = 상쇄 + 재기재.
  Future<CommandReceipt> amendManualFill(ManualFillAmendment amendment);

  /// 무효 = 상쇄만.
  Future<CommandReceipt> voidManualFill(ManualFillVoid v);

  /// 미이행 + 사유 코드. 🆕 v1.12 인자 교체(구 `AdviceSkip`).
  Future<CommandReceipt> skipAdvice(AdviceSkipSubmission submission);

  /// 원장 실사. 🆕 v1.12 인자 교체(구 `SelfReportBalance` — 세션 시각·기준일은 구현이 붙인다 · 세션 밖 =
  /// `SELF_REPORT_OUTSIDE_SESSION` · K9).
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  );

  /// 🔴 효력 없는 «수신 확인»(P0 승급 사다리 정지만 · `SafetyState` 무영향 · A5).
  /// 🆕 v1.15(01 §24 · K12) 인자 교체(구 `AlertAck ack` — 화면은 `CommandContext` 를 만들지 않는다 · G-19 · C-28 ⑨) ·
  /// 와이어 = [AlertAck](구현이 맥락을 붙인다 · [deferAdviceConfirm] 선례) · 🔴 폰(operator) 전용
  /// (뷰어 = 주입 없음 = 버튼 부재 · §8-10).
  /// 구현 의무 ⓐ [alertId] 단위 멱등 — 이미 확인된 알림의 두 번째 확인은 거부가 아니라 `executed`(효과 0)
  /// ⓑ 모르는 id · 사다리 없는 알림(`ack == null`) = 큐 적재 없는 `rejected`(`INPUT_INVALID` · [watchCommand] 의무 ④).
  Future<CommandReceipt> acknowledgeAlert(String alertId);

  /// 🔴 48h 해제 카운트다운 개시의 유일한 방아쇠.
  /// 🆕 v1.21(01 §30 · K9 · K40) — 인자 `activation` = 발동 뒤 기록 7(엔진 한 명령). 거부 = `KillSwitchResultCodes` ∪
  /// `SafetyCommonResultCodes`(C-16 · `m5/kill_checklist_receipts`) · 인자 교체(제출 DTO) = 01 §8 미결 183(1.22.0 판단).
  Future<CommandReceipt> confirmKillChecklist(KillChecklistAck ack);

  /// 🆕 v1.10 · ㊲ — 매매가 아닌데 원장을 바꾸는 사실(인출 · 분배금 · 기업행위 · 원천징수) 1건 ·
  /// `voidsEventId` 가 있으면 무효(상쇄만). 🔴 폰(operator) 전용 · 자동·안내 둘 다(설계 13 §8 R21 L3).
  Future<CommandReceipt> recordLedgerEvent(LedgerEventRecord record);

  /// 🆕 v1.12(01 §21 · K14 ⓐ) — 만료 확인 카드 「내일 다시」(폰 전용 · `AdviceItem.deferAvailable` 이 true 일 때만
  /// 버튼이 있다 · 02:947 «버튼은 명령을 직접 부르지 않는다» 의 예외 1건). 와이어 = [AdviceDeferConfirm](구현이 맥락을
  /// 붙인다) · 거부 = `DEFER_ALREADY_USED`.
  Future<CommandReceipt> deferAdviceConfirm(String adviceId);
}
