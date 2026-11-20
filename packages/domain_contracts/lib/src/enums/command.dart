// 01 §4-2 «명령 API» · §4-3 «설정 동작» 축(인벤토리 §2-13).
//
// 🔴 이 네 열거형은(🆕 v1.21 `SafetyActionId`) **영역 A 가 소유**하고 `lib/src/commands/`(영역 D)는 import 만 한다 —
//    열거형이 두 영역에 흩어지면 `@JsonValue` 규약의 소유자가 둘이 된다(인벤토리 §2 서문).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §4-2 · §6-6 `command_queue.kind` CHECK.
///
/// 🔴 **X7 4종은 Dart 이름과 DB 값의 어순이 뒤집혀 있다**(`manualFillRecord` ↔
///    `'RECORD_MANUAL_FILL'`) — 기계 변환에 맡기면 CHECK 위반이 런타임에 터진다.
///    Dart 이름은 §4-2 열거형이, DB 값은 `command_queue.kind` CHECK 가 각각 정본이고
///    **둘 다 바꾸지 않는다**(`m2-8_naming.md` B-3). C-15 가 이 비대칭을 검사한다.
/// 🔴 뒤 3종(`selfReportBalance`·`alertAck`·`killChecklistConfirm`)은 기계 변환과 일치한다 —
///    그래서 위 4종과 섞이면 더 위험하다(B-4).
/// 🔴 X7 8종(+ `LEDGER_EVENT_RECORD`)은 **전량 폰(operator) 전용**이며 뷰어 화이트리스트(앞 4종)를 건드리지 않는다.
///    🆕 v1.12(01 §21 · K14 ⓐ) — 8번째 = `DEFER_ADVICE_CONFIRM`(만료 확인 카드 「내일 다시」).
/// 🆕 v1.4 정정(01 §14-2) — `depositRegister` 도 폰 전용이다(구 «앞 5종» → 4종).
/// 🔴 킬스위치 «해제» 명령은 없다(결정 6).
enum CommandKind {
  @JsonValue('KILL_SWITCH_ACTIVATE')
  killSwitchActivate('KILL_SWITCH_ACTIVATE'),
  @JsonValue('JOURNAL_DRAFT')
  journalDraft('JOURNAL_DRAFT'),
  @JsonValue('BLIND_REVIEW_SCORE')
  blindReviewScore('BLIND_REVIEW_SCORE'),
  @JsonValue('DISCLOSURE_VIEW')
  disclosureView('DISCLOSURE_VIEW'),
  @JsonValue('DEPOSIT_REGISTER')
  depositRegister('DEPOSIT_REGISTER'),

  // ── X7 7종 · 🔴 전량 operator 전용 ──
  @JsonValue('RECORD_MANUAL_FILL')
  manualFillRecord('RECORD_MANUAL_FILL'),
  @JsonValue('AMEND_MANUAL_FILL')
  manualFillAmend('AMEND_MANUAL_FILL'),
  @JsonValue('VOID_MANUAL_FILL')
  manualFillVoid('VOID_MANUAL_FILL'),
  @JsonValue('SKIP_ADVICE')
  adviceSkip('SKIP_ADVICE'),
  @JsonValue('SELF_REPORT_BALANCE')
  selfReportBalance('SELF_REPORT_BALANCE'),
  @JsonValue('ALERT_ACK')
  alertAck('ALERT_ACK'),
  @JsonValue('KILL_CHECKLIST_CONFIRM')
  killChecklistConfirm('KILL_CHECKLIST_CONFIRM'),

  // ── 🆕 v1.10 · X7 ㊲ 원장 사건(8번째) · 🔴 operator 전용 · 기록 계열 TTL(㊵) ──
  @JsonValue('LEDGER_EVENT_RECORD')
  ledgerEventRecord('LEDGER_EVENT_RECORD'),

  // ── 🆕 v1.12(01 §21 · K14 ⓐ) — 만료 확인 카드 「내일 다시」 · 🔴 폰 전용 · 초안 영구 제외(C-35 ②) ──
  //    엔진 = `advice_transition(cause_code='DEFER_CONFIRM')` 1행 · 거부 = `DEFER_ALREADY_USED`.
  @JsonValue('DEFER_ADVICE_CONFIRM')
  adviceDeferConfirm('DEFER_ADVICE_CONFIRM');

  const CommandKind(this.wire);

  /// JSON·DDL 표기(01 §1-2). 🔴 Dart 이름과 어순이 다른 값이 넷 있다 — 위 조문 참조.
  final String wire;
}

/// 01 §4-2 · §6-2 `command_inbox.state` CHECK(G-30).
///
/// ```
/// requested ──▶ received ──┬──▶ executed        (종단)
///                          ├──▶ rejected        (종단 · rejectReasonCode 필수)
///                          └──▶ expired         (종단 · 서버 expires_at)
/// requested/received ──┬──▶ staleContext        ┐
///                      ├──▶ heldForIntegrity    ├ 🔴 보류 3(+1)상태 — TTL 을 소비하지 않는다
///                      ├──▶ pendingLeaseConfirm ┘
///                      └──▶ noOperator
/// ```
///
/// 🔴 **보류는 거부가 아니다.** 무결성 차단·리스 만료·오프라인·맥락 불일치에서 기록 명령을
///    거부하지 않고 보류한다.
/// 🔴 화면이 `state` 를 낙관 갱신하지 않는다 — 「요청됨」과 「집행됨」의 구별이 이 계약의 목적이다.
/// 🔴 `noOperator` 는 「요청됨」이 «껐다»로 읽히는 것을 막는 유일한 값이며, 표시 문구는
///    M2 가 사전 공급한 **고정 카탈로그**에서 고른다(앱이 상태를 조합해 문장을 만들지 않는다).
/// ✅ DDL 자리 = `command_inbox.state` = `command_ack.state` = **[requested] 를 뺀 8값**
///    (계약 v1.9.0 · 설계 13 §8 R19 E9-6 · R20 · 인벤토리 §10-2 ① 해소 · G-30). `command_queue` 에는
///    state 칸이 없다 — [requested] 는 기기 쪽 내구 큐의 상태라 엔진 표에 오지 않는다.
enum CommandState {
  @JsonValue('REQUESTED')
  requested('REQUESTED'),
  @JsonValue('RECEIVED')
  received('RECEIVED'),
  @JsonValue('EXECUTED')
  executed('EXECUTED'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('STALE_CONTEXT')
  staleContext('STALE_CONTEXT'),
  @JsonValue('HELD_FOR_INTEGRITY')
  heldForIntegrity('HELD_FOR_INTEGRITY'),
  @JsonValue('PENDING_LEASE_CONFIRM')
  pendingLeaseConfirm('PENDING_LEASE_CONFIRM'),
  @JsonValue('NO_OPERATOR')
  noOperator('NO_OPERATOR');

  const CommandState(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §4-3 — `SettingsActions.run(id, args:)` 가 받는 동작 식별자.
///
/// 🔴 **개수를 숫자로 적지 않는다**(G-91 · §8-17 — 골든벡터 총계와 같은 이유).
/// 🔴 `M9` 가 부르는 값은 05 §7 이 정본이고 행이 늘면 여기가 따라온다. 그러나
///    **`M5`·`M8` 전용 5값**(`onboardingOperatingModeSelect`·`handoverAdoptionSet`·
///    `handoverExternalRegister`·`handoverCommit` · 🆕 v1.16 `onboardingDryRunStart`)은 **이 파일이 정본**이며 05 §7 표에
///    나타나지 않는 것이 설계다 — 🔴 05 §7 에 없다는 이유로 지우지 않는다. 지우면 G-01·G-03
///    이 닫은 구멍(위저드·온보딩의 쓰기 경로 부재)이 되살아난다.
/// 🔴 DDL `CHECK` 대응 컬럼은 없다. 표기는 §1-2 규약대로 SCREAMING_SNAKE 다.
enum SettingsActionId {
  /// ⏸ v1.24(01 §33 · K106) — `S11` = ⏸ R9e(엔진 원천 뒤 · 01 §8 미결 197) · args 미정.
  @JsonValue('SETTINGS_GENERAL_UPDATE')
  settingsGeneralUpdate('SETTINGS_GENERAL_UPDATE'),

  /// 🆕 v1.20(01 §29 K6) — `S02` 1단(통과 = 구현이 저장) · args `{kind ∈ CredentialKindCodes}`.
  @JsonValue('CREDENTIAL_VERIFY')
  credentialVerify('CREDENTIAL_VERIFY'),

  /// 🆕 v1.20 — 🔴 화면 미호출(1단) · 조립·엔진 내부(`M4-4` 회전 마법사 등) · args 미정.
  @JsonValue('CREDENTIAL_REGISTER')
  credentialRegister('CREDENTIAL_REGISTER'),

  /// 🆕 v1.20 — `S03` 전체 검증 · args = `settings_actions.dart` 머리.
  @JsonValue('ACCOUNT_VERIFY_MAPPING')
  accountVerifyMapping('ACCOUNT_VERIFY_MAPPING'),

  /// 🆕 v1.20 — `S03` 슬리브↔계좌 원자 저장 · args = `settings_actions.dart` 머리.
  @JsonValue('ACCOUNT_MAP_SLEEVE')
  accountMapSleeve('ACCOUNT_MAP_SLEEVE'),
  @JsonValue('STRATEGY_PREVIEW')
  strategyPreview('STRATEGY_PREVIEW'),
  @JsonValue('STRATEGY_APPLY_REQUEST')
  strategyApplyRequest('STRATEGY_APPLY_REQUEST'),

  /// 🆕 G-01 — 🔴 온보딩 `O-00b` 의 **최초 선택 전용**이다. 전환이 아니므로 M5 게이트를
  /// 거치지 않으며, `O-04` 완료 후에는 이 동작이 거부되고 아래 전환 요청으로만 바뀐다.
  @JsonValue('ONBOARDING_OPERATING_MODE_SELECT')
  onboardingOperatingModeSelect('ONBOARDING_OPERATING_MODE_SELECT'),

  /// 🆕 v1.16(01 §25 · K24) — 🔴 온보딩 `O-04` ⑥ «DRY_RUN 시작» 전용(M8). 첫 `onboarding_choice.committed_at` 을
  /// **같은 트랜잭션**에서 채운다(01 §8-23) — 실패하면 둘 다 되돌린다. `runtimeEngineStart`(M9 운용 관리 ·
  /// 온보딩을 마친 엔진의 시작)와 다르다. args = `{}`.
  @JsonValue('ONBOARDING_DRY_RUN_START')
  onboardingDryRunStart('ONBOARDING_DRY_RUN_START'),

  @JsonValue('RUNTIME_MODE_SWITCH_REQUEST')
  runtimeModeSwitchRequest('RUNTIME_MODE_SWITCH_REQUEST'),
  @JsonValue('RUNTIME_OPERATING_MODE_SWITCH_REQUEST')
  runtimeOperatingModeSwitchRequest('RUNTIME_OPERATING_MODE_SWITCH_REQUEST'),

  /// 🆕 G-03 X7 — 귀속 1건의 처분 제출(편입/제외). `M5-11` 위저드 안에서만 호출된다.
  @JsonValue('HANDOVER_ADOPTION_SET')
  handoverAdoptionSet('HANDOVER_ADOPTION_SET'),

  /// 🆕 G-03 X7 — 시스템 밖 자산 등록·해제(`released_at`).
  @JsonValue('HANDOVER_EXTERNAL_REGISTER')
  handoverExternalRegister('HANDOVER_EXTERNAL_REGISTER'),

  /// 🆕 G-03 X7 — 위저드 커밋 1회.
  @JsonValue('HANDOVER_COMMIT')
  handoverCommit('HANDOVER_COMMIT'),

  /// 🆕 v1.22(01 §31 · K56) — `M5-11` simToAuto 위저드 6단계 생체 확인 = 전환 세션 열기(`{path}` · 1.22.0 화이트리스트 =
  /// `SIM_TO_AUTO` 하나 · ds `handover_session_store.dart:159` · 🔴 이름에 `OPEN` 을 쓰지 않는다 — 거부 코드 `HANDOVER_SESSION_OPEN` 과 겹침).
  @JsonValue('HANDOVER_SESSION_START')
  handoverSessionStart('HANDOVER_SESSION_START'),

  /// 🆕 v1.22 — 전환 세션 물러나기(`{handover_session_id}` · ds `:242` · 시각 = 기기 시계).
  @JsonValue('HANDOVER_SESSION_CANCEL')
  handoverSessionCancel('HANDOVER_SESSION_CANCEL'),

  /// 🆕 v1.22(K56) — 위저드 5단계 모의 기록 보관·지움(`{fate ∈ KEEP|DISCARD}` · 🔴 **세션 전** — `handover_session_id` 0 ·
  /// ds `sim_ledger_fate_store.dart:51` · 결정 사유 `SIM_LEDGER_KEEP`·`SIM_LEDGER_DISCARD`).
  @JsonValue('HANDOVER_SIM_LEDGER_FATE')
  handoverSimLedgerFate('HANDOVER_SIM_LEDGER_FATE'),

  @JsonValue('RUNTIME_ENGINE_START')
  runtimeEngineStart('RUNTIME_ENGINE_START'),
  @JsonValue('RUNTIME_ENGINE_STOP')
  runtimeEngineStop('RUNTIME_ENGINE_STOP'),

  /// 🆕 v1.19(01 §28 · K6) — `S05` 첫 실전 주문 승격(`live × autoTrade × dryRun` → `execute` · 06 `M1-22` · 13 R91).
  /// args = `{}`(엔진이 `RunModeCard.promotionAction` 에 완성 · 관찰 중 ∧ 승격 가능일 때만) · 🔴 생체 1회 = operator 구현이
  /// 기존 M5 게이트 다이얼로그로 받는다(새 라우트·새 화면 0 · `handoffRoute` null) · 자동 승격 0.
  @JsonValue('RUNTIME_LIVE_PROMOTION')
  runtimeLivePromotion('RUNTIME_LIVE_PROMOTION'),

  /// 🆕 v1.12(01 §21 · K9) — `L-3` 실사 세션 열기(폰 로컬 · `args` = {yyyy_mm, account_alias} ·
  /// 그 폰의 원장 파생 표시를 가린다 — 뷰어는 가리지 않는다). `L-3` 이 `initState` 에서 부른다.
  @JsonValue('SELF_REPORT_SESSION_START')
  selfReportSessionStart('SELF_REPORT_SESSION_START'),

  /// 🆕 v1.12 — 닫기(`L-3` `dispose` · `initState` 에서 잡아 둔 인스턴스로 · 세션 만료는 엔진이 스스로 닫는다).
  @JsonValue('SELF_REPORT_SESSION_STOP')
  selfReportSessionStop('SELF_REPORT_SESSION_STOP'),

  /// 🆕 v1.20 — `S06` viewer QR 티켓 발급(🔴 `deviceAppLockSet` 만들지 않음 — K17).
  @JsonValue('DEVICE_PAIRING_TICKET_CREATE')
  devicePairingTicketCreate('DEVICE_PAIRING_TICKET_CREATE'),

  /// 🆕 v1.20 — `S06` viewer 연결 끊기 · args `{device_id}`.
  @JsonValue('DEVICE_TOKEN_REVOKE')
  deviceTokenRevoke('DEVICE_TOKEN_REVOKE'),
  @JsonValue('CONNECTION_TEST')
  connectionTest('CONNECTION_TEST'),
  @JsonValue('CONNECTION_SYNC_NOW')
  connectionSyncNow('CONNECTION_SYNC_NOW'),

  /// 🆕 v1.18(01 §27 · K-s · 05 §7 C22) — `S07` 알림 채널 선택(운영 등급 · 🔴 `settingsGeneralUpdate` 로 태우지 않는다 —
  /// 채널은 안전장치의 일부). args = `{channel ∈ NotifyChannelCodes}`(엔진이 `NotifyChannelOption.selectAction` 에 완성).
  @JsonValue('NOTIFY_CHANNEL_SELECT')
  notifyChannelSelect('NOTIFY_CHANNEL_SELECT'),

  /// ⏸ v1.24(01 §33 · K107) — X4 = R9 밖(⏸ R9d · 01 §8 미결 5 · 196) · args 미정.
  @JsonValue('CALENDAR_SYNC_NOW')
  calendarSyncNow('CALENDAR_SYNC_NOW'),
  @JsonValue('CALENDAR_REBACKFILL')
  calendarRebackfill('CALENDAR_REBACKFILL'),

  /// 🆕 v1.24(01 §33 · K112) — `S09` «지금 백업» · args `{}`(엔진 완성 `BackupVm.runAction`) · 결과 `BackupResultCodes`.
  @JsonValue('BACKUP_RUN_NOW')
  backupRunNow('BACKUP_RUN_NOW'),

  /// 🆕 v1.24(01 §33 · K111) — 🔴 화면 미호출(복원 = X1 마법사 · 같은 폰 = 엔진 `X1_LIVE_EXISTS`) · args 미정 유지(`credentialRegister` 선례).
  @JsonValue('BACKUP_RESTORE_START')
  backupRestoreStart('BACKUP_RESTORE_START'),

  /// 🆕 v1.24(01 §33 · K114) — `S10` 골든벡터 셀프테스트 · args `{}` · 실행기 = E11o(전 = 버튼 부재).
  @JsonValue('SELFTEST_GOLDEN_RUN')
  selftestGoldenRun('SELFTEST_GOLDEN_RUN'),

  /// 🆕 v1.24(01 §33 · K115) — `S10` 무결성 자가진단(정본 자가 대조 권고 · 불일치 = `LEDGER_INTEGRITY`) · args `{}` · 결과 `LedgerIntegrityResultCodes`.
  @JsonValue('SELFTEST_INTEGRITY_RUN')
  selftestIntegrityRun('SELFTEST_INTEGRITY_RUN'),

  /// ⏸ `m2-8_naming.md` A-13(G-45) — 월 납입 운영값 변경.
  /// 🔴 **«운영 등급»이며 `settingsGeneralUpdate` 로 태우지 않는다** — 일반 등급이면
  /// 「즉시 반영」이 되어 「다음 납입 주기부터 적용」이 깨지고 생체 재인증도 건너뛴다.
  /// ✅ v1.23(01 §32 · K77) — 05 §1 등급표 «운영 — 월 납입» 행 있음 · 제출 경로 = `SettingsActions.runContributionUpdate`(`ContributionUpdateSubmission`) · `run` 화이트리스트 밖 · 화면 = M9 `S13`.
  @JsonValue('SETTINGS_CONTRIBUTION_UPDATE')
  settingsContributionUpdate('SETTINGS_CONTRIBUTION_UPDATE'),

  /// ⏸ `m2-8_naming.md` A-14(G-64) — 캘린더 재연결.
  /// ⏸ 사유 = X4 채택 자체가 미결이다(§8-5). **이름만 등재**한다.
  /// ⏸ v1.24 — R9d(E17 뒤).
  @JsonValue('CALENDAR_RECONNECT')
  calendarReconnect('CALENDAR_RECONNECT');

  const SettingsActionId(this.wire);

  /// JSON 표기(DDL 대응 컬럼 없음).
  final String wire;
}

/// 🆕 v1.21(01 §30 · K5 · K39) — `SafetyActions`(M5 · 폰 로컬)의 동작 식별자.
///
/// 🔴 와이어 = 엔진 data_sync 명령 kind 글자 그대로(`kill_switch_store.dart:352` · `pledge_store.dart:15`) —
///    `command_queue.kind` CHECK 대응 아님(폰 로컬 · DDL 0).
/// 🔴 같은 글자 다른 축 — `KILL_SWITCH_RESUME` = `DeviationKindCodes.killSwitchResume`(배지 종류 사전) ·
///    `PLEDGE_WRITE` = `OnboardingSlotIds.pledgeWrite`(슬롯 이름 사전). 열거 와이어 ↔ 사전 값이라 C-5 충돌 아님.
/// 🔴 1.21.0 의 값은 전부 **제출 DTO 경로**(`runKillResumeItem` · `runPledge`)이고 `run(id, args)` 가 받는 값은 0 이다
///    (화이트리스트 = 1.22.0 · K39). 개수를 숫자로 적지 않는다(G-91).
/// 🆕 v1.22(01 §31 · K52) — `run(id, args)` 화이트리스트 = `interventionStep` · `ruleChangeCancel` · `reconClear` ·
///    `seasonalWindowChoice`(엔진이 `SafetyActionCall` 에 완성) · 그 밖 값 = 제출 DTO 경로(`run…` 메서드).
/// 🆕 v1.26(01 §35 · K178 · K181) — `reconClear` 를 `run` 화이트리스트에서 뺐다(`runReconClear` · 값은 결과 id 로 남는다) ·
///    `ruleChangeRequest` 추가(`runRuleChangeRequest` 전용).
enum SafetyActionId {
  /// 킬스위치 재개 게이트(M5-2) 문항 제출의 결과 id — 7번 통과 = 해제.
  @JsonValue('KILL_SWITCH_RESUME')
  killSwitchResume('KILL_SWITCH_RESUME'),

  /// 서약 첫 판(`O-04` ② · 언제든 · 한 번만 — 엔진 R67 Z1).
  @JsonValue('PLEDGE_WRITE')
  pledgeWrite('PLEDGE_WRITE'),

  /// 서약 편집(새 판 · 12월 창만 — 엔진 R67 Z2 · M5-8).
  @JsonValue('PLEDGE_EDIT')
  pledgeEdit('PLEDGE_EDIT'),

  /// 🆕 v1.22(01 §31 · K52 · K53) — `M5-3` STOPPED 결정 A·B·C(제출 `runStoppedDecision` · 엔진 ds `stopped_decision_store.dart:19`).
  @JsonValue('STOPPED_DECISION')
  stoppedDecision('STOPPED_DECISION'),

  /// 🆕 v1.22 — `M5-3`·`M5-4` 사건 postmortem 쓰기(제출 `runPostmortem` · ds `incident_store.dart:13`).
  @JsonValue('INCIDENT_POSTMORTEM')
  postmortemRecord('INCIDENT_POSTMORTEM'),

  /// 🆕 v1.22(K55) — `M5-5` 대사 불일치 해제(`run{origin_code, decision_id}` · 🔵 엔진 명령 kind 0 → 계약이 짓는다 ·
  /// `DeviationKindCodes.reconClear` 배지 사전 · 저널 kind 와 같은 글자 = 축 다름).
  @JsonValue('RECON_CLEAR')
  reconClear('RECON_CLEAR'),

  /// 🆕 v1.22 — `M5-6` 수동 개입 한 단계(`run{session_id, stage, outcome, decision_id?}` · ds `intervention_store.dart:16` ·
  /// «아무것도 안 하기» 도 같은 동작 · outcome 만 다르다 — 메모 K17).
  @JsonValue('INTERVENTION_STEP')
  interventionStep('INTERVENTION_STEP'),

  /// 🆕 v1.22 — `M5-6`·`M5-7` 재량 조정(제출 `runDiscretionAdjust` · ds `discretion_store.dart:15`).
  @JsonValue('DISCRETION_ADJUST')
  discretionAdjust('DISCRETION_ADJUST'),

  /// 🆕 v1.26(01 §35 · K178) — `M5-9` 규칙 변경 요청(첫 승인 포함 · 제출 `runRuleChangeRequest` 전용 — `run` 으로 받지 않는다 ·
  /// ds `rule_change_store.dart` `kRuleChangeRequestKind` 와 같은 글자).
  @JsonValue('RULE_CHANGE_REQUEST')
  ruleChangeRequest('RULE_CHANGE_REQUEST'),

  /// 🆕 v1.22 — `M5-9` 규칙 변경 요청 취소(`run{request_id}` · ds `rule_change_store.dart:17` · 요청 = 🆕 v1.26 M5-9 `ruleChangeRequest`(`runRuleChangeRequest`) · M9 `strategyApplyRequest` = S04 편집기 판).
  @JsonValue('RULE_CHANGE_CANCEL')
  ruleChangeCancel('RULE_CHANGE_CANCEL'),

  /// 🆕 v1.22 — `M5-9` 규칙 변경 승인(제출 `runRuleChangeApproval` · ds `rule_change_store.dart:18`).
  @JsonValue('RULE_CHANGE_APPROVE')
  ruleChangeApprove('RULE_CHANGE_APPROVE'),

  /// 🆕 v1.22(K54) — X2 재개 게이트 계절 A 진입 3택(`run{work_id, choice}` · 🔵 엔진 명령 kind 0 → 계약이 짓는다 ·
  /// ds `jobs/resume_job.dart:399` `applySeasonalChoice` · `decision_id` = 구현이 짓는다).
  @JsonValue('SEASONAL_WINDOW_CHOICE')
  seasonalWindowChoice('SEASONAL_WINDOW_CHOICE');

  const SafetyActionId(this.wire);

  /// 표기(01 §1-2).
  final String wire;
}
