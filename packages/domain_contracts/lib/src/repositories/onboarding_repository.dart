// 01 §4-1 — X3 온보딩 읽기 창구. 🆕 v1.16(01 §25 · K29) — 한 화면 VM 창구 6(추가형 · `watchSteps` 무변경).

import '../dto/onboarding.dart';
import '../dto/safety.dart';
import '../enums/onboarding.dart';

/// 온보딩 읽기 창구(폰 · 엔진 로컬). 🔴 읽기 전용 — 쓰기 = `SettingsActions`·`CommandApi`.
abstract interface class OnboardingRepository {
  /// 🆕 G-01 — 🔴 **갈래별(자동 매매 / 투자 안내) 준비물 목록의 근거는 `onboarding_choice`**
  ///    이며 화면이 `OperatingMode` 를 **인자로 넘기지 않는다**. 선택 전에는 공통 단계만
  ///    오고, `O-00b` 가 선택을 저장한 뒤부터 갈래 단계가 목록에 나타난다.
  /// 🔵 v1.16 — R15 화면은 부르지 않는다(`O-01` = [watchStepList]) · 존폐 = 01 §8 미결 149.
  Stream<List<OnboardingStep>> watchSteps(OnboardingTrack t);

  /// 🆕 v1.16 — `O-00` 첫 실행 갈래.
  Stream<OnboardingStartVm> watchStart();

  /// 🆕 v1.16 — `O-00b` 운영 방식 선택(🔴 기본값 없음 = `selected` null).
  Stream<OnboardingModeChoiceVm> watchModeChoice();

  /// 🆕 v1.16 — `O-01` 단계 목록(🔴 갈래 인자 0 — 엔진이 `onboarding_choice` 로 고른다).
  Stream<OnboardingStepsVm> watchStepList();

  /// 🆕 v1.16 — `O-02`·`O-03` 단계 상세. 모르는·지난 [stepId] = `step` null + `missingLabel`(값 · 에러 아님).
  Stream<OnboardingStepDetailVm> watchStep(String stepId);

  /// 🆕 v1.16 — `O-04` 마무리 6단계.
  Stream<OnboardingFinishVm> watchFinish();

  /// 🆕 v1.16 — `R-01` 기존 계정에서 다시 시작(분기까지).
  Stream<RestartVm> watchRestart();
}
