// data_sync — M4(동기화·보안)·X1(기기 이전)·X4(캘린더)·X5(정합·복구)의 배럴.
//
// 🔴 domain_contracts가 «인터페이스»라면 이 패키지는 그 **구현체**다.
//    LocalSqliteReader(폰 · 정본 SQLite SELECT)와 SupabaseReadModel(viewer ·
//    RLS SELECT + Realtime) 둘 다 여기 있고, 계약 3조 ①에 따라 **같은 필드값**을 낸다.
// 🔴 ui_*는 이 패키지를 의존하지 않는다(C-3). 화면은 인터페이스만 보고,
//    구현체는 앱(apps/*)에서 주입된다.
//
// 구현은 lib/src/ 아래로 들어오고 공개할 것만 여기에서 export 한다.
// 🔵 E9-0 — 로컬 정본 SQLite 연결(`package:sqlite3`) · 🆕 E9c — 스키마 v1 · 두 파일 열기 · 🆕 E7b1 — 계획 스냅샷 저장소.
// 🆕 E8c — 시세·지표 저장(`daily_prices`·`market_series`) · 국면 행 · 결측 · 수집 기록 · 동결 번들 시드 · FRED·OFR 수집.
// 🆕 E8d2b — 일봉 시세 수집(`QuoteCollector` — core_engine 포트만 안다 · KIS 구현은 잡이 넣는다 · 끝난 세션만).
// 🆕 E11f3 — `seasonal_a` 본체 · `SeasonalTargetSource` · POT 현금 흐름(설계 13 §8 R49).
// 🆕 E11f2 — `monthly_rebalance` 본체 · 계획 보관 · `StoredPlanTargetSource`(설계 13 §8 R48).
// 🆕 E11f1 — 아침 · 저녁 잡 본체 넷(`DailyDataJob` · `UsDataJob` · `DailySignalJob` · `EquitySnapshotJob` · 설계 13 §8 R47).
// 🆕 E11e — 기기 로컬 암호화 저장소(`DeviceLocal` · 초안 `DeviceDraftStore` = `DraftStore` 구현 · 큐 ⓐ `LocalCommandQueue` · 설계 13 §8 R46).
// 🆕 E11k-a — Supabase 서버 시각(`SupabaseServerTime` = core `ServerTimeSource` 구현 · 연결 칸 · 입력 판정 · 설계 13 §8 R197).
// 🆕 E11c — healthchecks 어댑터(`HealthchecksClient` = core `JobHeartbeat` · `WatchdogRemote` 구현 · 설계 13 §8 R45).
// 🆕 E11d — 시크릿 스캔(정확 값 · 접두 · 시크릿 필드 · 8자리 숫자 패턴 없음). 금고 포트 · 마스킹은 core_engine `security/`.

export 'src/device/device_draft_store.dart';
export 'src/device/device_local.dart';
export 'src/device/local_command_queue.dart';
export 'src/jobs/daily_archive_job.dart';
export 'src/jobs/daily_jobs.dart';
export 'src/jobs/monthly_rebalance_job.dart';
export 'src/jobs/resume_job.dart';
export 'src/jobs/resume_reevaluator.dart';
export 'src/jobs/seasonal_a_job.dart';
export 'src/jobs/seasonal_choice.dart';
export 'src/jobs/tier_b_step.dart';
export 'src/local/alert_read_model.dart';
export 'src/local/alert_store.dart';
export 'src/local/biometric_sign_store.dart';
export 'src/local/config_version_store.dart';
// 🆕 E11q-c1b — 키 세트 검증 기록(값 0 · 설계 13 §8 R196).
export 'src/local/credential_registry_store.dart';
export 'src/local/deposit_ledger.dart';
export 'src/local/deposit_registrar.dart';
export 'src/local/derived_sync_store.dart';
export 'src/local/discretion_store.dart';
// 🆕 E11q-d1b — M8 핸드북 «현재 상태» 값(금 상한 · 읽을 때 짓기 · 설계 13 §8 R236).
export 'src/local/handbook_live_source.dart';
export 'src/local/handover_session_store.dart';
// 🆕 E11q-c1 — M5-11 simToAuto 위저드 원천(설계 13 §8 R191).
export 'src/local/handover_wizard_source.dart';
// 🆕 E11q1 — M6 H6-1 보유 현황 읽기(설계 13 §8 R171).
export 'src/local/holdings_overview_source.dart';
export 'src/local/incident_store.dart';
export 'src/local/intervention_store.dart';
export 'src/local/job_run_store.dart';
export 'src/local/journal_source.dart';
export 'src/local/kill_switch_screen_source.dart';
export 'src/local/kill_switch_store.dart';
export 'src/local/lease_store.dart';
export 'src/local/ledger_archive_writer.dart';
export 'src/local/ledger_database.dart';
export 'src/local/ledger_fix.dart';
export 'src/local/ledger_hash_stamper.dart';
export 'src/local/ledger_integrity_check.dart';
export 'src/local/ledger_read_model.dart';
// 🆕 E16f1 — X5 새 기준점 · 아무것도 안 하기(설계 13 §8 R126).
export 'src/local/ledger_repair_store.dart';
export 'src/local/ledger_schema.dart';
// 🆕 E11q-q6c(R240) — X7 신뢰 등급 · 실사 예정 · 기한 표식 원천.
export 'src/local/ledger_trust_source.dart';
export 'src/local/limit_inputs_source.dart';
export 'src/local/live_observation_facts.dart';
export 'src/local/live_promotion_store.dart';
export 'src/local/mode_anchor.dart';
export 'src/local/mode_store.dart';
// 🆕 미결 209 ⓔ-1 — 월간 리포트 원천(원장 → 엔진 입력 · 월 잡과 같은 노출 집계 · 설계 13 §8 R218).
export 'src/local/monthly_report_source.dart';
export 'src/local/onboarding_progress_store.dart';
export 'src/local/onboarding_store.dart';
export 'src/local/operating_param_store.dart';
export 'src/local/operations_config_source.dart';
export 'src/local/ops_config_source.dart';
// 🆕 E11p3d-2b — H-01 오늘 요약 · H-02 운영 리듬 사실(설계 13 §8 R133).
export 'src/local/ops_home_source.dart';
export 'src/local/order_ledger.dart';
export 'src/local/p0s_human_source.dart';
export 'src/local/performance_source.dart';
export 'src/local/plan_snapshot_store.dart';
export 'src/local/planned_work_store.dart';
export 'src/local/pledge_store.dart';
export 'src/local/rebalance_source.dart';
// 🆕 E11k-e3 — O-04 ⑤ 복구 카드 첫 클레임 기록(command_inbox · 해시만 · 설계 13 §8 R229).
export 'src/local/recovery_card_store.dart';
// 🆕 E16j-a — X5 정정 마법사 원천(설계 13 §8 R227 · 01 §8 미결 217).
export 'src/local/repair_wizard_source.dart';
export 'src/local/resume_read_model.dart';
export 'src/local/resume_screen_source.dart';
export 'src/local/resume_status.dart';
export 'src/local/resume_store.dart';
export 'src/local/rule_change_gate_source.dart';
export 'src/local/rule_change_store.dart';
export 'src/local/safety_read_model.dart';
export 'src/local/self_report_source.dart';
export 'src/local/sim_ledger_fate_store.dart';
export 'src/local/sim_ledger_view.dart';
export 'src/local/sim_to_auto_carry.dart';
export 'src/local/sim_to_auto_commit_store.dart';
export 'src/local/sim_to_auto_finish.dart';
export 'src/local/sim_trial_facts.dart';
export 'src/local/stopped_decision_store.dart';
export 'src/market/csv_table.dart';
export 'src/market/fetch_log.dart';
export 'src/market/gap_store.dart';
export 'src/market/http_fetch.dart';
export 'src/market/macro_collector.dart';
export 'src/market/market_ids.dart';
export 'src/market/market_store.dart';
export 'src/market/quote_collector.dart';
export 'src/market/regime_store.dart';
export 'src/market/seed_bundle.dart';
export 'src/market/series_clients.dart';
export 'src/migration/gap_rebuild_store.dart';
// 🆕 E11q-c2 — M9 S09 백업 지점 목록 · 화면 사실 · «지금 백업»(설계 13 §8 R201 · 미결 199).
export 'src/migration/ledger_backup_points.dart';
export 'src/migration/ledger_restore.dart';
export 'src/migration/ledger_snapshot.dart';
export 'src/migration/maintenance_window_runner.dart';
export 'src/migration/maintenance_window_store.dart';
export 'src/migration/migration_facts.dart';
export 'src/migration/migration_journal_store.dart';
export 'src/migration/migration_lease_gate.dart';
export 'src/migration/recovery_gate_store.dart';
export 'src/migration/recovery_journal_store.dart';
// 🆕 E16t3c(설계 13 §8 R244) — X1-3 비상 앞쪽 복원 전 기록(sim `command_inbox`) · 재발급 기록.
export 'src/migration/x1_emergency_store.dart';
export 'src/migration/x1_screen_source.dart';
export 'src/migration/x1_startup.dart';
// 🆕 E11d — 시크릿 스캔 게이트(설계 13 §8 R44 E7 · 06 M4-6).
export 'src/security/secret_scan.dart';
export 'src/supabase/supabase_auth.dart';
// 🆕 E11k-e2(설계 13 §8 R221) — o_07 ① 부트스트랩 SQL 묶음 · 복구 코드 해시 꼴(원문 조각 = 내부 생성 파일).
export 'src/supabase/supabase_bootstrap.dart';
export 'src/supabase/supabase_connect.dart';
// 🆕 E11k-e3 — O-04 ⑤ 첫 클레임 명시 흐름(복구 코드 발급 · 기기 행 · lease_claim · 설계 13 §8 R229).
export 'src/supabase/supabase_first_claim.dart';
export 'src/supabase/supabase_lease.dart';
export 'src/supabase/supabase_recovery_code.dart';
export 'src/supabase/supabase_server_time.dart';
// 🆕 E16t3c(설계 13 §8 R244) — X1-3 ① 비상 시작(새 복구 카드 · 종이 확인 · 기기 행 · lease_revoke).
export 'src/supabase/supabase_x1_emergency.dart';
export 'src/watchdog/healthchecks_client.dart';
