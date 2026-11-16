// 영역 D 재수출 창구 — 읽기 리포지토리 인터페이스(`lib/src/repositories/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다(인벤토리 §0).
// 🔴 리포지토리는 **읽기 전용**이다. 쓰기는 `CommandApi`·`SettingsActions`
//    (🆕 v1.2 `DraftStore` · 🆕 v1.21 `SafetyActions`)뿐이며 `save_`/`write_`/`submit_`/`send_` 이름은 계약에 존재하지
//    않는다(01 §1-4 · 인벤토리 §0-2 3조).
//
// 근거: 01 §4-1 · 인벤토리 §5.

export 'repositories/advice_repository.dart';
export 'repositories/alert_repository.dart';
export 'repositories/calendar_repository.dart';
export 'repositories/config_repository.dart';
export 'repositories/execution_gap_repository.dart';
export 'repositories/handbook_repository.dart';
export 'repositories/holdings_repository.dart';
export 'repositories/incident_repository.dart';
export 'repositories/journal_repository.dart';
export 'repositories/kill_switch_gate_repository.dart';
export 'repositories/ledger_repository.dart';
export 'repositories/ledger_trust_repository.dart';
export 'repositories/onboarding_repository.dart';
export 'repositories/ops_repository.dart';
export 'repositories/pairing_repository.dart';
export 'repositories/performance_repository.dart';
export 'repositories/pledge_repository.dart';
export 'repositories/rebalance_repository.dart';
export 'repositories/resume_repository.dart';
export 'repositories/runbook_repository.dart';
export 'repositories/safety_repository.dart';
export 'repositories/settings_repository.dart';
export 'repositories/what_if_api.dart';
