// core_engine/testing.dart — 🆕 E10b · **테스트 전용** 받침대(설계 13 §8 R33 D13 · R35 V9).
//
// 주문 경로 포트(`OrderBroker` · `OrderLedger` · `AdviceSink`)의 결정론 가짜. core_engine · data_sync ·
// broker_gateway 시험이 같이 쓴다(선례 `domain_contracts/testing.dart`). 🔴 앱 코드(lib/)는 이것을 import 하지 않는다.
// 🔴 예외 하나(E11o-b · 설계 13 §8 R163) — core_engine `src/golden/`(기기 골든 실행기)이 GV-13 «발주 횟수»를 05 가 정한
//    «mock» 그대로 이 가짜로 돈다(실제 브로커 0). 그 밖의 lib 는 `src/testing/` 을 import 하지 않는다(경계 시험).
//
// 받침대 목록 — `FakeOrderBroker`(각본 `FakeAccept` · `FakeReject` · `FakeUnknown` · `FakeThrow` · 제출 기록 ·
//   제출 순간 걸이 · 체결조회 · 예수금) · `FakeOrderLedger`(메모리 · UNIQUE · 엄격한 상태 전이 · 실패 주입) ·
//   `RecordingAdviceSink`.

// 🆕 E14a — 리스 포트 가짜(설계 13 §8 R71 L8).
export 'src/testing/fake_golden_self_test.dart' show FakeGoldenSelfTest;
export 'src/testing/fake_job_run_log.dart' show FakeJobRunLog;
export 'src/testing/fake_lease_gate.dart' show FakeLeaseGate;
// 🆕 E15a — 모드 판정 입력 가짜(설계 13 §8 R81 V5).
export 'src/testing/fake_mode_facts.dart' show FakeModeFacts;
export 'src/testing/fake_order_broker.dart'
    show
        FakeAccept,
        FakeOrderBroker,
        FakeReject,
        FakeSubmitStep,
        FakeThrow,
        FakeUnknown;
export 'src/testing/fake_order_ledger.dart'
    show FakeIntentRecord, FakeOrderLedger, RecordingAdviceSink;
// 🆕 E11d — 키 금고 · 봉함 가짜(설계 13 §8 R44 E2 · E6 · 🔴 암호가 아니다).
export 'src/testing/fake_planned_work_ledger.dart' show FakePlannedWorkLedger;
export 'src/testing/fake_resume_reevaluator.dart' show FakeResumeReevaluator;
export 'src/testing/fake_secret_vault.dart'
    show FakeSealedBox, MemorySecretVault;
// 🆕 E15f4b1 — 바깥 감시 포트 가짜(설계 13 §8 R105 AJ7).
export 'src/testing/fake_watchdog_remote.dart' show FakeWatchdogRemote;
// 🆕 E11o-b — 주문 경로 공용 받침(옛 test/order_path_fixture.dart · 골든 GV-13 도 쓴다 · 설계 13 §8 R163).
export 'src/testing/order_path_fixture.dart'
    show ctxOf, draftOf, kExec, kLimitConfig, ledgerOf, portfolioOk;
