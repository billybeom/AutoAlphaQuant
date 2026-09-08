// 01 §4-2 · §5-1 — 앱이 호출할 수 있는 **전부**.
//
// 🔴 경계 규칙 ②. 앱은 DB 에 쓰지 않는다. Supabase append-only 명령 테이블에 INSERT 하고
//    엔진이 구독·검증·집행한다. 반환값은 «요청 접수»이지 «집행 완료»가 아니다.
// 🔴 구현은 `command_queue` 에 UPDATE·DELETE 를 부르지 않는다(C-16).
// 🔴 **킬스위치 «해제» 명령은 없다**(결정 6). 해제는 폰 M5 재개 게이트 전용이며
//    `deactivate` 추가 제안은 **거절이 기본값**이다.
// 🔴 **뷰어가 쓸 수 있는 것은 앞 5종이 전부다.** X7 7종은 전량 폰(operator) 전용이라
//    뷰어 화이트리스트를 건드리지 않는다. ⏸ `ALERT_ACK` 의 뷰어 허용만 §8-10 미결이고
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

  /// 사전 작성(폰) / 초안(viewer).
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft);

  /// 사후 blind 리뷰(결정 9b).
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score);

  /// 열람 기록(결정 8).
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event);

  Future<CommandReceipt> registerDeposit(DepositRegistration registration);

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

  // ⏸ `recordLedgerEvent(LedgerEventRecord)` — 🔴 **결정 ㊲ 채택 시에만** 8번째로 신설(J-6).
}
