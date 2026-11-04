// trading_runtime — M1(실행 런타임)·X2(장기 미실행 재개)의 배럴.
//
// 🔴 «오늘 무엇을 실행할 차례인가»를 아는 유일한 자리다. 잡 스케줄·워치독·
//    재개 절차가 여기 모인다.
// 🔴 ui_*는 이 패키지를 의존하지 않는다(C-3). 재개 게이트 화면은 ui_safety다.
//
// 🆕 E11a(설계 13 §8 R42) — 잡 규약(01 §10) · 주문 잡(`kr_order` 오전 · 마감 · `daily_reconcile`).
// 🆕 E11b(설계 13 §8 R43 B1~B9) — 잡 표 · 회차 · 다음 발화 · 놓친 발화 · 3분법 판정 · `rid` · FGS 문구.
// 🆕 E11c(설계 13 §8 R45 C7~C9) — 워치독 보드(`WatchdogBoardVm` · 바깥 대조) · 바깥 체크 자기 점검.
//    healthchecks 어댑터 = data_sync `HealthchecksClient`(조립 앱이 잇는다).
//    알람 · FGS 서비스 · 알림 발송 · 재개(R0~R8)는 아직 없다.

// 🆕 E11c(R45 C1) — 하트비트 포트는 core_engine 에 있다(구현 = data_sync) · 같은 이름으로 다시 내보낸다.
export 'package:core_engine/core_engine.dart'
    show JobHeartbeat, PingStatus, TargetSource;

export 'src/jobs/fgs_notice.dart'
    show FgsChannel, FgsNotice, FgsStatus, buildFgsNotice, shouldRepostFgs;
export 'src/jobs/job_contract.dart'
    show
        AlertSink,
        JobBody,
        JobRun,
        JobStatus,
        kstDateOf,
        kstTimeOfDay,
        runIdFor,
        runJob,
        watchdogCheckName;
export 'src/jobs/job_schedule.dart'
    show
        JobCadence,
        JobCalendars,
        JobOccurrence,
        JobSpec,
        WakeAction,
        WakeDecision,
        jobSpecOf,
        kJobTable,
        nextOccurrence,
        occurrenceOn,
        occurrencesBetween,
        wakeDecisions;
export 'src/jobs/kr_order_jobs.dart'
    show
        DraftQuoteSource,
        KrJobs,
        KrOrderCloseReport,
        KrOrderConfig,
        KrOrderJobs,
        KrOrderOpenReport,
        kKrOrderCutoffKst,
        kKrOrderEarliestKst;
export 'src/jobs/watchdog_board.dart'
    show
        RemoteAuditFinding,
        RemoteAuditKind,
        WatchdogBoardInput,
        auditRemoteChecks,
        buildWatchdogBoard,
        kWatchdogEmptyLabel,
        kWatchdogHolidayNotice,
        kWatchdogLimitNotice,
        kWatchdogReceiptTolerance,
        kWatchdogStaleAfter;
export 'src/jobs/watchdog_judge.dart'
    show OccurrenceRecord, WatchdogState, WatchdogVerdict, judgeOccurrence;
