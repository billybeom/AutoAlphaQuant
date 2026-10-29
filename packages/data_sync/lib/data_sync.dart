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

export 'src/local/deposit_ledger.dart';
export 'src/local/deposit_registrar.dart';
export 'src/local/ledger_database.dart';
export 'src/local/ledger_schema.dart';
export 'src/local/plan_snapshot_store.dart';
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
