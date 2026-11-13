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
export 'src/jobs/tier_b_step.dart';
export 'src/local/alert_read_model.dart';
export 'src/local/alert_store.dart';
export 'src/local/deposit_ledger.dart';
export 'src/local/deposit_registrar.dart';
export 'src/local/discretion_store.dart';
export 'src/local/incident_store.dart';
export 'src/local/intervention_store.dart';
export 'src/local/job_run_store.dart';
export 'src/local/kill_switch_store.dart';
export 'src/local/lease_store.dart';
export 'src/local/ledger_archive_writer.dart';
export 'src/local/ledger_database.dart';
export 'src/local/ledger_fix.dart';
export 'src/local/ledger_hash_stamper.dart';
export 'src/local/ledger_integrity_check.dart';
export 'src/local/ledger_read_model.dart';
export 'src/local/ledger_schema.dart';
export 'src/local/operating_param_store.dart';
export 'src/local/order_ledger.dart';
export 'src/local/plan_snapshot_store.dart';
export 'src/local/planned_work_store.dart';
export 'src/local/pledge_store.dart';
export 'src/local/resume_store.dart';
export 'src/local/rule_change_store.dart';
export 'src/local/safety_read_model.dart';
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
// 🆕 E11d — 시크릿 스캔 게이트(설계 13 §8 R44 E7 · 06 M4-6).
export 'src/security/secret_scan.dart';
export 'src/watchdog/healthchecks_client.dart';
