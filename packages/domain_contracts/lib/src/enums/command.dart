// 01 §4-2 «명령 API» · §4-3 «설정 동작» 축(인벤토리 §2-13).
//
// 🔴 이 세 열거형은 **영역 A 가 소유**하고 `lib/src/commands/`(영역 D)는 import 만 한다 —
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
/// 🔴 X7 7종은 **전량 폰(operator) 전용**이며 뷰어 화이트리스트(앞 5종)를 건드리지 않는다.
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
  killChecklistConfirm('KILL_CHECKLIST_CONFIRM');

  // ⏸ `ledgerEventRecord` → 'LEDGER_EVENT_RECORD' — 결정 ㊲ 채택 시에만 8번째로 신설한다
  //    (01 §4-2 ⏸ 원문 · `m2-8_naming.md` J-6). 지금은 만들지 않는다.

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
/// ⚠️ **열린 물음** — `NO_OPERATOR` 는 현행 `command_inbox.state`·`command_ack.state`
///    CHECK 어디에도 없다. 「셋 중 어디까지 넓히는가」는 이름 문제가 아니라 스키마 결정이며
///    영역 E(DDL)가 확정 전까지 이 값을 실은 픽스처를 만들면 CHECK 위반이 된다
///    (인벤토리 §10-2 ① · `m2-8_naming.md` K-1 · A-11 은 **이름만** 확정했다).
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
///    **`M5`·`M8` 전용 4값**(`onboardingOperatingModeSelect`·`handoverAdoptionSet`·
///    `handoverExternalRegister`·`handoverCommit`)은 **이 파일이 정본**이며 05 §7 표에
///    나타나지 않는 것이 설계다 — 🔴 05 §7 에 없다는 이유로 지우지 않는다. 지우면 G-01·G-03
///    이 닫은 구멍(위저드·온보딩의 쓰기 경로 부재)이 되살아난다.
/// 🔴 DDL `CHECK` 대응 컬럼은 없다. 표기는 §1-2 규약대로 SCREAMING_SNAKE 다.
enum SettingsActionId {
  @JsonValue('SETTINGS_GENERAL_UPDATE')
  settingsGeneralUpdate('SETTINGS_GENERAL_UPDATE'),
  @JsonValue('CREDENTIAL_VERIFY')
  credentialVerify('CREDENTIAL_VERIFY'),
  @JsonValue('CREDENTIAL_REGISTER')
  credentialRegister('CREDENTIAL_REGISTER'),
  @JsonValue('ACCOUNT_VERIFY_MAPPING')
  accountVerifyMapping('ACCOUNT_VERIFY_MAPPING'),
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

  @JsonValue('RUNTIME_ENGINE_START')
  runtimeEngineStart('RUNTIME_ENGINE_START'),
  @JsonValue('RUNTIME_ENGINE_STOP')
  runtimeEngineStop('RUNTIME_ENGINE_STOP'),
  @JsonValue('DEVICE_PAIRING_TICKET_CREATE')
  devicePairingTicketCreate('DEVICE_PAIRING_TICKET_CREATE'),
  @JsonValue('DEVICE_TOKEN_REVOKE')
  deviceTokenRevoke('DEVICE_TOKEN_REVOKE'),
  @JsonValue('CONNECTION_TEST')
  connectionTest('CONNECTION_TEST'),
  @JsonValue('CONNECTION_SYNC_NOW')
  connectionSyncNow('CONNECTION_SYNC_NOW'),
  @JsonValue('CALENDAR_SYNC_NOW')
  calendarSyncNow('CALENDAR_SYNC_NOW'),
  @JsonValue('CALENDAR_REBACKFILL')
  calendarRebackfill('CALENDAR_REBACKFILL'),
  @JsonValue('BACKUP_RUN_NOW')
  backupRunNow('BACKUP_RUN_NOW'),
  @JsonValue('BACKUP_RESTORE_START')
  backupRestoreStart('BACKUP_RESTORE_START'),
  @JsonValue('SELFTEST_GOLDEN_RUN')
  selftestGoldenRun('SELFTEST_GOLDEN_RUN'),
  @JsonValue('SELFTEST_INTEGRITY_RUN')
  selftestIntegrityRun('SELFTEST_INTEGRITY_RUN'),

  /// ⏸ `m2-8_naming.md` A-13(G-45) — 월 납입 운영값 변경.
  /// 🔴 **«운영 등급»이며 `settingsGeneralUpdate` 로 태우지 않는다** — 일반 등급이면
  /// 「즉시 반영」이 되어 「다음 납입 주기부터 적용」이 깨지고 생체 재인증도 건너뛴다.
  /// ⏸ 사유 = 05 §1 등급표에 «운영 등급» 행이 신설되어야 성립한다. **이름만 등재**한다.
  @JsonValue('SETTINGS_CONTRIBUTION_UPDATE')
  settingsContributionUpdate('SETTINGS_CONTRIBUTION_UPDATE'),

  /// ⏸ `m2-8_naming.md` A-14(G-64) — 캘린더 재연결.
  /// ⏸ 사유 = X4 채택 자체가 미결이다(§8-5). **이름만 등재**한다.
  @JsonValue('CALENDAR_RECONNECT')
  calendarReconnect('CALENDAR_RECONNECT');

  const SettingsActionId(this.wire);

  /// JSON 표기(DDL 대응 컬럼 없음).
  final String wire;
}
