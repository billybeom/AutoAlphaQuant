// 01 §4-1 — X3 온보딩 읽기 창구.

import '../dto/safety.dart';
import '../enums/onboarding.dart';

/// 온보딩 단계 목록.
abstract interface class OnboardingRepository {
  /// 🆕 G-01 — 🔴 **갈래별(자동 매매 / 투자 안내) 준비물 목록의 근거는 `onboarding_choice`**
  ///    이며 화면이 `OperatingMode` 를 **인자로 넘기지 않는다**. 선택 전에는 공통 단계만
  ///    오고, `O-00b` 가 선택을 저장한 뒤부터 갈래 단계가 목록에 나타난다.
  Stream<List<OnboardingStep>> watchSteps(OnboardingTrack t);
}
