# `lib/src/labels/` — 코드→문구 매핑 사전

**정본**: `11_앱설계/01_M2_도메인계약_초안.md` **§3** (+ §2-2·§2-4·§6-2·§6-6 · `docs/contracts_inventory.md` §6)

## 🔴 이 폴더의 성격을 오해하지 말 것

**문구는 엔진(M2) 소유이고 런타임에 DTO 의 `label`·`actionLine`·`clearInstruction`·`headline`·`stateLabel` 필드에 실려 온다.** 여기 두는 것은 «어떤 **코드**가 오는가»의 목록·상수이지, 화면이 코드를 보고 문자열을 고르라는 사전이 아니다.

- 화면이 코드→문구 매핑을 만들면 §7 **C-5** 가 빌드를 실패시킨다.
- 화면의 정적 UI 라벨(「닫기」·「기간」)은 여기가 아니라 **각 `ui_*` 패키지의 `lib/l10n/labels.dart` 한 파일**에 있다(§1-5).
- 판단 기준: 데이터가 바뀌어도 글자가 같으면 정적 라벨, **데이터·상태에 따라 달라지면 사유 문구**다. `if 상태 then A else B` 처럼 **분기로 고르는 것은 정적 라벨이 아니라 생성**이다.
- 이 목록의 쓰임은 둘뿐이다: ① 픽스처·DDL 대조(**C-15**) ② 미등록 코드 조기 실패.

## 파일 (16)

| 파일 | 무엇 | 근거 |
|---|---|---|
| `exit_kind.dart` | `ExitKindCodes` 6 · 🆕 **v1.8** `StopTierCodes` 3(`TIER_1A`·`TIER_1B`·`TIER_2` — 사전 키 `stop_tier` · `StopLineNormalized.tierCode`) | §3-1 · §17 |
| `saf_codes.dart` | `SafBandCodes` 8(대역 7행) · `Saf309Codes` 6 | §3-2 |
| `verdict_codes.dart` | `VerdictCodes` 5 · `PlannedWorkKindCodes` 5(🆕 v1.22 `MONTHLY_PLAN`·`CARRY_OVER` 추가형) · `GapReasonCodes` 9(🆕 v1.3 `SIM_EXCLUDED` · v1.14 시세 5 · 🆕 v1.22 `SIM_BAR_MISSING`) · 🆕 **v1.22** `ResumeItemReasonCodes` 15(`resume_reason` · 🔴 이름 ≠ 엔진 · K49) · `SeasonalChoiceResultCodes` 4(`seasonal_choice_result`) · `PlannedWorkRejectCodes` 6(`planned_work_reject`) | §3-3 · §6-3 · §2-4 · §13-3 · §31 |
| 🆕 `disclosure_codes.dart` | **v1.3** `DisclosureSurfaceCodes` 1(`PERFORMANCE_EXPLORE` — 사전 키 `disclosure_surface`) | §13-6 |
| 🆕 `plan_codes.dart` | **v1.4** `PlannerReasonCodes` 1(`DEPOSIT_ROUTING` — 사전 키 `planner_reason`) · E7a3-2 `RebalanceReasonCodes` 4(`rebalance_reason`) · 🆕 **v1.11** `DepositRegisterRejectCodes` 6(`deposit_register_reject` · 판정 순서 `precedence`) | §14 · §2-6 · §15-4 · §20 |
| `origin_codes.dart` | `OriginCodes` 20(브로커 7 · 파생 7 · X7 6) | §3-4 |
| `flag_ids.dart` | `FlagIds` 12 · `SafetyHoldCodes` 1 → 🆕 **v1.30** 2(+ `MIGRATION_IN_PROGRESS` 표시 hold) | §3-5 · §9-5 ③ · §38 |
| `advice_codes.dart` | `AdviceRejectCodes` 18(🆕 v1.12 +3 `INPUT_INVALID`·`SELF_REPORT_OUTSIDE_SESSION`·`DEFER_ALREADY_USED`) · `AdviceTransitionCauseCodes` 9 · `DecisionReasonCodes` 12(🆕 v1.10 ㊲ +5 · v1.11 `DEPOSIT_REGISTERED` · 🆕 v1.19 `LIVE_EXECUTE_PROMOTION` — 엔진 E15e2 · 🆕 v1.22 `SIM_LEDGER_KEEP`·`SIM_LEDGER_DISCARD` — `LIVE_OPENING` 미등재 · K57) · `SeasonalEntryGateCodes` 3(+픽스처값 1) · 🆕 **v1.12** `AdviceRetryCodes` 2(`advice_retry`) · `ManualFillPrefillFields` 1(`manual_fill_prefill`) | §3-8 · §6-6 · §3-7 · §21 |
| `alert_codes.dart` | `AlertCodes` 36(🆕 v1.17 `STALE_ORDERS_HELD` · 엔진 D11 · 🆕 v1.18 엔진 등재형 `safety` 3 · `resume` 3 · 🆕 v1.27 엔진 등재형 `safetyWarn` 4 · `derivedSync` 1) | 04 §5-1b·§5-1c·§5-1d·§5-3 · §27 |
| `deviation_kind_codes.dart` | `DeviationKindCodes` 13 | §2-2 |
| `ledger_event_codes.dart` | `LedgerEventCodes` 1 · `OperatingParamKeys` 1 | §3-6 · §6-2 |
| `journal_codes.dart` | **v1.1** `DecisionChainStageCodes` 8 · `SafetyCheckLevelCodes` 4 · `UnknownResolutionStageCodes` 4 · `JournalBadgeCodes` 2 · `JournalDraftRejectCodes` 1 · 🆕 **v1.17** `JournalReasonCodes` 3(`journal_reason` · 엔진 D11 2 · 🆕 v1.18 `LEASE_INVALID` · 전수 아님) | §11 · 02 §3-2 · §26 · §27 |
| 🆕 `onboarding_codes.dart` | **v1.16** `OnboardingResultCodes` 4(`onboarding_result`) · `BrokerRawCodes` 4(`broker_raw` · 원문 표본 · 전수 아님 · 🆕 v1.22 모의 가상 체결 3 · K66) · `OnboardingSlotIds` 7(`onboarding_slot` · 🔒 슬롯 이름) · 🆕 **v1.29** +1 `SECRET_SUPABASE_CONNECT`(o_07 ②) · 🆕 **v1.31** +1 `SECRET_SUPABASE_LOGIN`(o_07 ③) | §25 · §39 · §40 |
| 🆕 `ops_codes.dart` | **v1.17** `OpsSlotIds` 1(`ops_slot` · `D-03` 인쇄 슬롯 이름 `EMERGENCY_CARD_PRINT`) | §26 · 🆕 **v1.25** +1 `KILL_SWITCH`(셸 킬스위치 자리 · 위젯 = `ui_safety` 발동 버튼 · 01 §34 K152) |
| 🆕 `safety_codes.dart` | **v1.21** 엔진 글자 1:1 — `KillSwitchResultCodes` 12(`kill_switch_result`) · `SafetyCommonResultCodes` 2(`safety_common_result` · `TRUSTED_TIME_UNKNOWN`·`JOURNAL_ID_TAKEN` 한 벌) · `PledgeResultCodes` 6(`pledge_result` · 공용 0) · `GaugeCodes` 4(`gauge` · `GaugeProgress.code` · 검사 = C-55 ⑭) · 🆕 **v1.22** E13 5 — `StoppedDecisionResultCodes` 7(`stopped_decision_result`) · `PostmortemResultCodes` 3(`postmortem_result`) · `InterventionResultCodes` 6(`intervention_result`) · `RuleChangeResultCodes` 11(`rule_change_result`) · `DiscretionResultCodes` 3(`discretion_result` · `JOURNAL_MISSING` = 문서화 중복 다섯째) | §30 · §31 · 🆕 **v1.25** `KillCancelOutcomeCodes` 5(`kill_cancel_outcome` · 엔진 `KillCancelOutcome` wire 1:1 · 01 §34 K151) · 🆕 **v1.26** `ReconClearResultCodes` 3(`recon_clear_result` · 엔진 예고 · 공용 2 따로 · 01 §35 K182) |
| 🆕 `settings_codes.dart` | **v1.18** `ConnectionTargetCodes` 6(`connection_target`) · `NotifyChannelCodes` 2(`notify_channel`) · `SettingsResultCodes` 5(`settings_result` · 전수 아님 · 🆕 v1.19 +2 `ENGINE_ALREADY_RUNNING`·`ENGINE_ALREADY_STOPPED`) · 🆕 **v1.19** `EngineStopReasonCodes` 2(`engine_stop_reason` · 🔵 잠정) · `SettingsResultCodes` 🆕 v1.20 +3 `WRONG_KEY_SET`·`MAPPING_VERIFY_FAILED`·`DEVICE_ALREADY_REVOKED`(→ 8) · 🆕 **v1.20** `CredentialKindCodes` 4(`credential_kind` · 엔진 `KisKeySet.wire` 겹침) · `SettingsSlotIds` 4(`settings_slot`) · 🆕 **v1.23** `ContributionResultCodes` 6(`contribution_result` · S13 월 납입 거부 · 엔진 `ContributionRejectCodes` 7 − 공용 `TRUSTED_TIME_UNKNOWN` · 🔴 이름 ≠ 엔진 · K80) · 🆕 **v1.24** `BackupResultCodes` 8(`backup_result` · S09 «지금 백업» = X1 스냅숏 `take` 경로 전수 · `RESTORE_ROLLBACK` = `origin_code` 문서 중복) · `LedgerIntegrityResultCodes` 7(`ledger_integrity_result` · S10 무결성 = E13c1 사유 · `CHAIN_BROKEN` = `origin_code` 문서 중복 · 🔴 이름 ≠ 엔진 · K119 · K132) | §27 · §28 · §29 · §32 · §33 |
| 🆕 `sim_codes.dart` | **v1.19** E15i 등재형(엔진 글자 1:1) — `SimTrialItemCodes` 5(`sim_trial_item`) · `SimTrialItemStateCodes` 4(`sim_trial_state`) · `LiveObservationBlockCodes` 4(`live_observation_block`) · `LivePromotionResultCodes` 5(`live_promotion_result` · E15e2) · `ModeStartupCodes` 2(`mode_startup`) · `SimOpeningResultCodes` 10(`sim_opening_result`) · 🆕 **v1.22** `SimToAutoResultCodes` 10(`sim_to_auto_result` · 상수 `windowBlocked` — K51) · `SimToAutoCommitResultCodes` 12(`sim_to_auto_commit_result` · 상수 `outcomeUnknown`) · `HandoverSessionResultCodes` 2(`handover_session_result`) · `SimToAutoStepIds` 7(`sim_to_auto_step` · `ordered`) · `ModeMarkerText` 4(표지 글자 · 사전 도메인 0) | §28 · §31 |
| 🆕 `supabase_codes.dart` | **v1.29** E11k-b — `SupabaseInputResultCodes` 6(`supabase_input_result`) · `SupabaseTimeResultCodes` 8(`supabase_time_result`) · `LeaseRpcResultCodes` 5(`lease_rpc_result`) · 🆕 **v1.31** `SupabaseAuthResultCodes` 6(`supabase_auth_result` · E11k-d2) · 🔴 타입 이름 ≠ 엔진 · `LEASE_INVALID` = `journal_codes.dart` 한 벌 | §39 · §6-4 |
| 🆕 `migration_codes.dart` | **v1.30** E16i 엔진 글자 1:1(X1 21무리 · 76 · 🔴 타입 이름 ≠ 엔진 · 공용 `TRUSTED_TIME_UNKNOWN` · `BackupResultCodes` 한 벌 몫 뺌) — 거부 · 막음 12무리(`x1_start_result` 4 · `x1_step_block` 5 · `x1_journal_result` 3 · `x1_boot_refusal` 2 · `x1_restore_result` 3 · `x1_fencing_result` 2 · `x1_reissue_result` 5 · `x1_recovery_result` 2 · `x1_order_seal` 2 · `x1_gate_reason` 8 · `maintenance_window_result` 1 · `x1_intent_reason` 1) · 열거 글자 9무리(`x1_plan_step` 9 · `x1_step_state` 3 · `x1_kind` 2 · `x1_role` 2 · `x1_reissue_item` 6 · `x1_recovery_step` 5 · `x1_gate_state` 4 · `x1_gap_violation` 3 · `maintenance_window_event` 4) · 🆕 **v1.33** `X1SlotIds` 4(`x1_slot` · 🔒 슬롯 이름 · E16j-b) | §38 · §42 |
| 🆕 `repair_codes.dart` | **v1.30** E16i 엔진 글자 1:1(X5 4무리 · 27) — `repair_result` 10 · `baseline_result` 2 · `ledger_boundary_reason` 8 · `derived_relation` 7 · 🆕 **v1.32** `BaselineApplyResultCodes` 1(`baseline_apply_result` · ds 새 기준점 저장 거부 · E16j-a) | §38 · §41 |
| `labels.dart` | §1-5 조문 · `AfterTaxStepCodes` 6 · ⏸ `StaleReasonCodes` 4 · **`ContractCodes` 배럴·단일 소스 조회** | §1-5 · §2-4 · §8-8 |

## 단일 소스 조회 — `ContractCodes`

```dart
ContractCodes.requireRegisteredIn('flag_id', code); // 🔴 미등록이면 UnregisteredContractCodeError
ContractCodes.requireRegistered(code);              // 도메인을 모를 때만
ContractCodes.byDomain['origin_code'];              // 도메인별 집합(픽스처·C-15 대조용)
```

🔴 **도메인을 아는 자리에서는 `requireRegisteredIn` 을 쓴다.** 전역 조회는 «`flag_id` 자리에 알림 코드가 들어온 것»을 잡지 못한다.

**집계(실측 2026-09-29 · v1.3 · `ContractCodes.byDomain`)**: 도메인 **26** · 등재 **164건** · 문자열 **160개**(중복 4쌍).
~~도메인 20 · 등재 143건 · 문자열 139개~~ 는 v1.0 의 값이다 — v1.1 `journal_codes.dart` 5도메인 19건 + v1.3 `disclosure_surface` 1도메인 1건 + `gap_reason_code` 1건(`SIM_EXCLUDED`)이 늘었다. 아래 «137 + 6» 풀이도 v1.0 기준이다.
인벤토리 §6 의 «총 137 코드» + 6 이며 차이는 ① SAF 접두 대역 7행 → 접두 **문자열** 8개(§3-2 표가 `SAF-8xx`·`SAF-9xx` 를 한 행으로 묶는다) ② 계절 게이트 픽스처값 `ENTRY_GATE_OCT` ③ ⏸ `staleReasonCode` 4다.
같은 문자열이 두 도메인에 있는 4쌍: `MANUAL_ORDER`(origin·deviation) · `RECON_MISMATCH`·`SELF_AUDIT_DUE`(flag·alert) · `PUSH_LAG`(origin·stale).

## ⚠️ 미결 — 임의 확정 금지

| 무엇 | 지금 상태 |
|---|---|
| `CORPORATE_ACTION`(X2) vs `CORP_ACTION`(X5) 중복 | ✅ **`CORPORATE_ACTION` 으로 통합**(계약 v1.9.0). `CORP_ACTION` 은 옛 기록용 상수로만 남고 픽스처·신규 코드는 `OriginCodes.writable`(19종)만 쓴다 |
| `AsOf.staleReasonCode` 값 목록 | ⏸ `StaleReasonCodes` 4값은 **역산**이며 엔진(M1) 확정 대기(M2-8 A-2) |
| 계절 게이트 «통과» 코드명 | ⏸ `F1_ENTRY_OK` 는 M2-3 등재 대기. 🔴 등재 전에는 픽스처의 `ENTRY_GATE_OCT` 를 **고치지 않는다** |
| 알림 24종의 **등급** | 🔴 코드만 등재했고 등급 사전은 만들지 않았다. 런타임 정본은 `AlertItem.level`, 최종 정본은 엔진 notify 등급이며 «대조 1회»(06 §4 ③) 전에는 유효하지 않다 |
| `SAF309_ACCOUNT_UNVERIFIED` | 인벤토리 §3-1 의 `ReasonChip` 예시에 있으나 진리표 6종에 **없다**. 임의로 추가하지 않았다 |
| ⏸ `LedgerEventKind` 4값 | 결정 ㊲ 채택 시에만 신설. `ledger_event_codes.dart` 말미에 **주석으로만** 있다 |
