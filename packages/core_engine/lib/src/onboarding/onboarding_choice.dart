// 온보딩 첫 화면 · 운영 방식 선택 VM 짓기 · 선택 결과 문장(E11p4b · 설계 13 §8 R125 · 앱 01 §25 K11 · K12 · K13 · 04 §9 O-00 · O-00b).
//
// 🔴 글자 = v1.16 표본(`m8/onboarding_start*` · `_mode_*` · `_mode_select_results`) 그대로 — 엔진 정본(R122 O1 · O2 와 같은 원칙).
// 🔴 첫 화면 트랙 = FRESH · RECONNECT 둘뿐 · 조회 전용 트랙은 따로([viewerTrack] · null = 숨김) · 운영 방식은 트랙이 아니다(K11).
// 🔴 운영 방식 = 기본값 없음 — 고른 것 = `onboarding_choice` · 고름 ∧ 확정 전 = 다음 링크 · 확정(committed_at) = 잠김 글자 · 다음 링크 없음(K12).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        OnboardingModeChoiceVm,
        OnboardingStartVm,
        OnboardingTrack,
        OnboardingTrackCard,
        OperatingMode,
        OperatingModeOption;

/// 운영 방식 선택 접수(표본 `_mode_select_results`).
const String kOnboardingModeSelectedText = '운영 방식을 기록했습니다. 다음 단계 목록이 바뀝니다.';

/// 확정 뒤 선택 거부(표본 · `ONBOARDING_CHOICE_COMMITTED`).
const String kOnboardingModeCommittedText =
    '온보딩을 마쳐 여기서는 바꿀 수 없습니다. 바꾸려면 설정의 전환 절차를 거칩니다.';

const String _startHeadline = '이 폰을 어떻게 쓸지 고르십시오.';

/// 🔴 `O-00` 첫 화면 — [reconnectReady] = 재시작(R-01) 화면이 서 있나(아니면 그 카드의 링크 없음) ·
/// [viewerTrack] = 조회 전용 카드를 보이나(operator 앱 = 아니오).
OnboardingStartVm onboardingStartVmOf({
  required bool reconnectReady,
  required bool viewerTrack,
}) => OnboardingStartVm(
  headline: _startHeadline,
  tracks: <OnboardingTrackCard>[
    const OnboardingTrackCard(
      track: OnboardingTrack.fresh,
      title: '처음 시작하기',
      estimatedText: '약 60~90분',
      deepLink: AppRoutes.onboardingModePick,
    ),
    OnboardingTrackCard(
      track: OnboardingTrack.reconnect,
      title: '기존 계정에서 다시 시작하기',
      estimatedText: '약 15분 + 대기',
      deepLink: reconnectReady ? AppRoutes.onboardingRestart : null,
    ),
  ],
  viewerTrack: viewerTrack
      ? const OnboardingTrackCard(
          track: OnboardingTrack.viewerPairing,
          title: '이 폰은 조회만 할 거예요',
          estimatedText: 'QR 스캔 약 2분',
          deepLink: AppRoutes.onboardingPairing,
        )
      : null,
);

const List<OperatingModeOption> _options = <OperatingModeOption>[
  OperatingModeOption(
    mode: OperatingMode.autoTrade,
    title: '자동으로 맡기기',
    body: '규칙이 정한 대로 앱이 직접 주문을 냅니다.',
    prepLine: '증권사 주문 권한과 새벽 배치가 필요합니다.',
    honestyLine: '사람이 개입할 자리가 줄어드는 대신 기기가 멈추면 아무것도 돌지 않습니다.',
  ),
  OperatingModeOption(
    mode: OperatingMode.advisory,
    title: '안내만 받기',
    body: '무엇을 살지 알려 주고 주문은 사람이 냅니다.',
    prepLine: '잔고 읽기 권한만 있으면 됩니다.',
    honestyLine: '손으로 하는 만큼 빠뜨리거나 고르게 됩니다. 그 흔적이 이행 갭으로 남습니다.',
  ),
];

/// 🔴 `O-00b` 운영 방식 선택 — [selected] = `onboarding_choice`(null = 고르기 전) · [committed] = `committed_at` 이 찼나.
OnboardingModeChoiceVm onboardingModeChoiceVmOf({
  required OperatingMode? selected,
  required bool committed,
}) {
  if (committed && selected == null) {
    throw ArgumentError('확정됐는데 고른 방식이 없다');
  }
  return OnboardingModeChoiceVm(
    headline: '운영 방식을 고르십시오. 고른 방식에 따라 다음 준비물 목록이 달라집니다.',
    options: _options,
    selected: selected,
    recordGapNotice: '투자 안내에서는 앱이 계좌를 읽지 못하므로, 기록하지 않은 매매는 시스템이 알 수 없습니다.',
    honestyText:
        '규칙을 지켰을 때의 기대치는 전 계좌 세후 10.2% 안팎(최악 9.7%)입니다. 규칙 없이 사서 들고만 있었을 때'
        '(8.38% · 최대 낙폭 −35.05%)와 비교해 연 +2.75%p · 낙폭 22.5%p 차이가 규칙의 값입니다. '
        '투자 안내에서는 그 값을 지키는 주체가 사람입니다.',
    nextDeepLink: selected != null && !committed
        ? AppRoutes.onboardingSteps
        : null,
    lockedLabel: committed
        ? '온보딩을 마쳐 운영 방식이 확정되었습니다. 바꾸려면 설정의 전환 절차를 거칩니다.'
        : null,
  );
}
