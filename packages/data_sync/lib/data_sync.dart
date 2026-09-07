// data_sync — M4(동기화·보안)·X1(기기 이전)·X4(캘린더)·X5(정합·복구)의 배럴.
//
// 🔴 domain_contracts가 «인터페이스»라면 이 패키지는 그 **구현체**다.
//    LocalSqliteReader(폰 · 정본 SQLite SELECT)와 SupabaseReadModel(viewer ·
//    RLS SELECT + Realtime) 둘 다 여기 있고, 계약 3조 ①에 따라 **같은 필드값**을 낸다.
// 🔴 ui_*는 이 패키지를 의존하지 않는다(C-3). 화면은 인터페이스만 보고,
//    구현체는 앱(apps/*)에서 주입된다.
//
// 아직 비어 있다. 구현은 lib/src/ 아래로 들어오고 공개할 것만 여기에서
// export 한다.
