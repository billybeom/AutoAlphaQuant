// 01 §2-10 «X3 온보딩» 축(인벤토리 §2-11).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-10 · `onboarding_progress.track` CHECK.
/// 🔴 갈래별 준비물의 근거는 `onboarding_choice` 이며 `OnboardingRepository.watchSteps` 에
///    `OperatingMode` 를 인자로 넘기지 않는다(G-01).
enum OnboardingTrack {
  @JsonValue('FRESH')
  fresh('FRESH'),
  @JsonValue('RECONNECT')
  reconnect('RECONNECT'),
  @JsonValue('VIEWER_PAIRING')
  viewerPairing('VIEWER_PAIRING');

  const OnboardingTrack(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-10 — 단계의 필수도.
///
/// 🔴 `required_` 의 트레일링 언더스코어는 **Dart 예약어 회피**이며 표기에 새지 않는다 —
///    `@JsonValue('REQUIRED')` 로 못 박는다(`m2-8_naming.md` B-2). 기계 변환하면
///    `REQUIRED_` 가 되어 픽스처와 갈린다.
enum StepRequirement {
  @JsonValue('REQUIRED')
  required_('REQUIRED'),
  @JsonValue('RECOMMENDED')
  recommended('RECOMMENDED'),
  @JsonValue('OPTIONAL')
  optional('OPTIONAL');

  const StepRequirement(this.wire);

  /// JSON·DDL 표기. 🔴 `required_` 의 표기는 `'REQUIRED'` 다(언더스코어 없음).
  final String wire;
}

/// 01 §2-10 · `onboarding_progress.state` CHECK.
enum StepState {
  @JsonValue('NOT_STARTED')
  notStarted('NOT_STARTED'),
  @JsonValue('IN_PROGRESS')
  inProgress('IN_PROGRESS'),
  @JsonValue('VERIFIED')
  verified('VERIFIED'),
  @JsonValue('FAILED')
  failed('FAILED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED');

  const StepState(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
