// trading_runtime — M1(실행 런타임)·X2(장기 미실행 재개)의 배럴.
//
// 🔴 «오늘 무엇을 실행할 차례인가»를 아는 유일한 자리다. 잡 스케줄·워치독·
//    재개 절차가 여기 모인다.
// 🔴 ui_*는 이 패키지를 의존하지 않는다(C-3). 재개 게이트 화면은 ui_safety다.
//
// 🆕 E11a(설계 13 §8 R42) — 잡 규약(01 §10) · 주문 잡(`kr_order` 오전 · 마감 · `daily_reconcile`).
//    알람 · FGS · 실제 핑 · 알림 발송 · 재개(R0~R8)는 아직 없다.

export 'src/jobs/job_contract.dart'
    show
        AlertSink,
        JobBody,
        JobHeartbeat,
        JobRun,
        JobStatus,
        PingStatus,
        kstDateOf,
        kstTimeOfDay,
        runJob,
        watchdogCheckName;
export 'src/jobs/kr_order_jobs.dart'
    show
        DraftQuoteSource,
        KrJobs,
        KrOrderCloseReport,
        KrOrderConfig,
        KrOrderJobs,
        KrOrderOpenReport,
        TargetSource,
        kKrOrderCutoffKst,
        kKrOrderEarliestKst;
