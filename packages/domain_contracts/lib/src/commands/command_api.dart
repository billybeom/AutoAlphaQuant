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
//    과 일치). X7 7종도 전량 폰 전용이라 뷰어 화이트리스트를 건드리지 않는다. ⏸ `ALERT_ACK` 의 뷰어 허용만 §8-10 미결이고
//    현행 4종 화이트리스트를 유지한다(J-3).
// 🔴 화면은 `CommandReceipt.state` 를 스스로 낙관 갱신하지 않는다.
// 🔴 **`OperatingMode` 전환은 여기 없다** — `SettingsActionId.runtimeOperatingModeSwitchRequest`
//    1종이며 반환 `ActionResult.handoffRoute` 로 위저드에 넘긴다(§4-3).

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
  /// 화면: 스트림 에러 = 마지막 접수증 유지(01 §8 미결 51 ③) · 복원 재구독의 첫 접수증 전 에러·완료 =
  /// 잠금 유지 + 정적 «다시 시도»(01 §12-4). 명령 메서드 `Future` 의 에러는 «접수 실패»다(01 §4-2).
  Stream<CommandReceipt> watchCommand(String commandId);

  // ───── 🆕 X7(§10) 7종 — 🔴 전량 폰(operator) 전용 ─────

  /// 사실 추가.
  Future<CommandReceipt> recordManualFill(ManualFillRecord record);

  /// 정정 = 상쇄 + 재기재.
  Future<CommandReceipt> amendManualFill(ManualFillAmendment amendment);

  /// 무효 = 상쇄만.
  Future<CommandReceipt> voidManualFill(ManualFillVoid v);

  /// 미이행 + 사유 코드.
  Future<CommandReceipt> skipAdvice(AdviceSkip skip);

  /// 원장 실사.
  Future<CommandReceipt> submitSelfReportBalance(SelfReportBalance b);

  /// 🔴 효력 없는 «수신 확인».
  Future<CommandReceipt> acknowledgeAlert(AlertAck ack);

  /// 🔴 48h 해제 카운트다운 개시의 유일한 방아쇠.
  Future<CommandReceipt> confirmKillChecklist(KillChecklistAck ack);

  /// 🆕 v1.10 · ㊲ — 매매가 아닌데 원장을 바꾸는 사실(인출 · 분배금 · 기업행위 · 원천징수) 1건 ·
  /// `voidsEventId` 가 있으면 무효(상쇄만). 🔴 폰(operator) 전용 · 자동·안내 둘 다(설계 13 §8 R21 L3).
  Future<CommandReceipt> recordLedgerEvent(LedgerEventRecord record);
}
