// 온보딩 마무리(O-04) 6단계 VM 짓기 · 모의 운영 시작 결과 문장(E11p4c · 설계 13 §8 R127 · 앱 01 §25 K23 · K24 · 04 §9 O-04).
//
// 🔴 단계 = 6 · 차례 고정 · 건너뛰기 0 — ① P0S 프로파일 ② 본인 서약 ③ 생체 서명 ④ 골든벡터 셀프테스트 ⑤ 복구 카드 ⑥ 모의 운영 시작.
// 🔴 글자 = v1.16 표본(`m8/onboarding_finish*` · `_finish_results`) 그대로 · 표본에 없는 «원천 없음» 게이트 글자 = 표본 꼴
//    («…을 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다»)을 따른다(R127 F4).
// 🔴 K23 — 기대치 줄 = ①만 · 슬롯 = ②~⑤ 이고 그 단계가 열려 있을 때만 · 링크 · 동작 = ⑥만(링크 ⇒ 동작 없음 · 동작 ⇒ ①~⑤ VERIFIED) ·
//    끝(committed_at) ⇔ 점검 목록 있음 · 끝 = 전 단계 VERIFIED · 링크 · 동작 · 슬롯 0.
// 🔴 사실이 없는 단계(③ 생체 · ④ 셀프테스트 · ⑤ 복구 카드 — 원천 0) = 게이트(앞 단계 막힘 > 원천 없음) — 지어내지 않는다.
// 🆕 E11k-e3(R229) — ⑤ 복구 카드 = 열린 동안에만 카드 줄을 부른다(🔴 부를 때 발급 · 평문 = 그 줄에만) · 종이 확인 뒤 등록 남음 =
//    진행 중(칸 그대로 — «등록 다시 시도») · 끝 = 코드 없는 줄.

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        GateBadge,
        GateState,
        LinkAction,
        OnboardingAction,
        OnboardingFinishCheck,
        OnboardingFinishStage,
        OnboardingFinishVm,
        OnboardingSlotIds,
        OperatingMode,
        SettingsActionId,
        StepState;

/// 마무리 사실.
class OnboardingFinishFacts {
  /// 사실을 만든다.
  const OnboardingFinishFacts({
    required this.mode,
    required this.committed,
    required this.pledged,
    required this.openingDeclared,
    this.configHash,
    this.biometricSigned,
    this.selftest,
    this.recoveryCardDone,
    this.recoveryCardPending = false,
    this.recoveryCardLines = const <String>[],
    this.recoveryCardIssue,
    this.advisoryOpeningAlias,
  });

  /// 운영 방식(`onboarding_choice`).
  final OperatingMode mode;

  /// `committed_at` 이 찼나(모의 운영 시작 뒤).
  final bool committed;

  /// 서약이 있나(② · `pledge`).
  final bool pledged;

  /// 시작 상태를 선언했나(⑥ · 개시 결정).
  final bool openingDeclared;

  /// 설정 해시(모의 개시 뒤 정해진다 · 없으면 줄 없음).
  final String? configHash;

  /// ③ 생체 서명(null = 원천 없음).
  final bool? biometricSigned;

  /// ④ 셀프테스트 (통과, 전체)(null = 원천 없음).
  final (int, int)? selftest;

  /// ⑤ 복구 카드(null = 원천 없음).
  final bool? recoveryCardDone;

  /// 🆕 R229 — ⑤ 종이 확인됨 · 서버 등록 남음(진행 중 · 칸 = 다시 시도).
  final bool recoveryCardPending;

  /// 🆕 R229 — ⑤ 끝 · 진행 중 줄(엔진 `RecoveryCardTexts` · 🔴 코드 0).
  final List<String> recoveryCardLines;

  /// 🆕 R229 — ⑤ 가 열려 있고 진행 중이 아닐 때만 부르는 카드 줄(🔴 부를 때 발급 · 메모리 · 코드 = 이 줄에만) · null = 줄 없음.
  final List<String> Function()? recoveryCardIssue;

  /// 투자 안내 ⑥ 시작 선언 계좌(null = 계좌 대응 원천 없음).
  final String? advisoryOpeningAlias;
}

/// 모의 운영 시작 접수(표본 `_finish_results`).
const String kOnboardingDryRunStartedText = '모의 운영을 시작했습니다.';

/// 모의 운영 시작 되돌림(표본 · `DRY_RUN_START_ROLLED_BACK`).
const String kOnboardingDryRunRolledBackText = '시작하지 못해 운영 방식 확정도 함께 되돌렸습니다.';

const String _orderLabel = '앞 단계를 마치면 열립니다';
const GateBadge _order = GateBadge(
  code: 'STAGE_ORDER',
  label: _orderLabel,
  state: GateState.block,
);

GateBadge _unknown(String code, String what) => GateBadge(
  code: code,
  label: '$what을 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다',
  state: GateState.unknown,
);

/// 🔴 `O-04` 마무리 6단계.
OnboardingFinishVm onboardingFinishVmOf(OnboardingFinishFacts f) {
  final bool done = f.committed;
  // ① P0S 프로파일 — 엔진 고정 프로파일(표본 글자) · 설정 해시 = 모의 개시 뒤.
  final String? hash = f.configHash;
  final OnboardingFinishStage s1 = OnboardingFinishStage(
    title: 'P0S 프로파일 확인',
    state: StepState.verified,
    lines: <String>[
      '배분 A 20% · B 42% · 새틀라이트 0%(꺼짐) · 나머지 C',
      '금 상한 8%(설정값)',
      if (hash != null) '설정 해시 $hash',
    ],
    expectationLine: '규칙을 지켰을 때의 기대치는 전 계좌 세후 10.2% 안팎(최악 9.7%)입니다.',
  );
  // ② 서약.
  final bool v2 = done || f.pledged;
  final OnboardingFinishStage s2 = OnboardingFinishStage(
    title: '본인 서약문 3문장',
    state: v2 ? StepState.verified : StepState.notStarted,
    lines: const <String>[],
    slotId: v2 ? null : OnboardingSlotIds.pledgeWrite,
  );
  // ③ 생체 서명 — 앞(②) 막힘 > 원천 없음 > 슬롯.
  final bool v3 = done || (f.biometricSigned ?? false);
  final OnboardingFinishStage s3 = OnboardingFinishStage(
    title: '생체 서명',
    state: v3 ? StepState.verified : StepState.notStarted,
    gate: v3
        ? null
        : !v2
        ? _order
        : f.biometricSigned == null
        ? _unknown('BIOMETRIC_SIGN', '생체 서명 상태')
        : null,
    lines: const <String>[],
    slotId: !v3 && v2 && f.biometricSigned != null
        ? OnboardingSlotIds.biometricSign
        : null,
  );
  // ④ 셀프테스트 — 원천 없음 = 게이트 UNKNOWN(표본 글자) · 통과 n/m.
  final (int, int)? st = f.selftest;
  final bool v4 = done || (st != null && st.$2 > 0 && st.$1 == st.$2);
  final OnboardingFinishStage s4 = OnboardingFinishStage(
    title: '골든벡터 셀프테스트',
    state: v4 ? StepState.verified : StepState.notStarted,
    gate: v4
        ? null
        : st == null
        ? const GateBadge(
            code: 'SELFTEST_READY',
            label: '셀프테스트 준비 상태를 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다',
            state: GateState.unknown,
          )
        : !v3
        ? _order
        : null,
    lines: <String>[if (st != null) '통과 ${st.$1}/전체 ${st.$2}'],
    slotId: !v4 && st != null && v3 ? OnboardingSlotIds.selftestRun : null,
  );
  // ⑤ 복구 카드 — 원천 없음 = 게이트 UNKNOWN · 🆕 R229 열림 = 카드 줄(그때 발급) · 진행 중 = 등록 남음.
  final bool v5 = done || (f.recoveryCardDone ?? false);
  final bool open5 = !v5 && f.recoveryCardDone != null && v4;
  final OnboardingFinishStage s5 = OnboardingFinishStage(
    title: '복구 카드 발급',
    state: v5
        ? StepState.verified
        : open5 && f.recoveryCardPending
        ? StepState.inProgress
        : StepState.notStarted,
    gate: v5
        ? null
        : f.recoveryCardDone == null
        ? _unknown('RECOVERY_CARD', '복구 카드 상태')
        : !v4
        ? _order
        : null,
    // 🔴 닫힌 단계엔 줄 0(코드를 미리 내지 않는다).
    lines: open5 && !f.recoveryCardPending
        ? (f.recoveryCardIssue?.call() ?? const <String>[])
        : v5 || open5
        ? f.recoveryCardLines
        : const <String>[],
    slotId: open5 ? OnboardingSlotIds.recoveryChecksum : null,
  );
  // ⑥ 모의 운영 시작 — ①~⑤ 전부 VERIFIED 일 때만 링크 · 동작.
  final bool ready = v2 && v3 && v4 && v5;
  final String endLine = switch (f.mode) {
    OperatingMode.autoTrade => '종착: 모의 · 자동 매매 · 실행',
    OperatingMode.advisory => '종착: 모의 · 투자 안내 · 실행',
  };
  final List<String> lines6 = <String>[
    '운영 램프 L1 · 모의투자(내부 시뮬레이션)',
    endLine,
    if (f.openingDeclared || done) '시작 상태를 선언했습니다',
  ];
  LinkAction? link;
  OnboardingAction? action;
  GateBadge? gate6;
  if (!done) {
    if (!ready) {
      gate6 = _order;
    } else if (f.openingDeclared) {
      action = const OnboardingAction(
        id: SettingsActionId.onboardingDryRunStart,
        args: <String, String>{},
        label: '모의 운영 시작',
      );
    } else {
      switch (f.mode) {
        case OperatingMode.autoTrade:
          link = const LinkAction(
            label: '가상 초기금 넣기',
            deepLink: AppRoutes.m5SimOpeningCash,
          );
        case OperatingMode.advisory:
          final String? alias = f.advisoryOpeningAlias;
          if (alias == null) {
            gate6 = _unknown('OPENING_ACCOUNT', '시작 선언 계좌');
          } else {
            link = LinkAction(
              label: '시작 보유·현금 선언하기',
              deepLink: AppRoutes.ledgerSimOpening.replaceFirst(
                ':accountAlias',
                alias,
              ),
            );
          }
      }
    }
  }
  final OnboardingFinishStage s6 = OnboardingFinishStage(
    title: '모의 운영(DRY_RUN) 시작',
    state: done ? StepState.verified : StepState.notStarted,
    gate: gate6,
    lines: lines6,
    link: link,
    action: action,
  );
  return OnboardingFinishVm(
    headline: '마무리 여섯 단계를 순서대로 진행합니다.',
    stages: <OnboardingFinishStage>[s1, s2, s3, s4, s5, s6],
    doneLabel: done ? '모의투자를 시작했습니다. 이제 앱은 모의투자 모드로 돕니다.' : null,
    checks: done
        ? const <OnboardingFinishCheck>[
            // 🔴 끝 뒤 점검 = 서버 판정(K23) — 원천이 서기 전 = 시작 전.
            OnboardingFinishCheck(
              label: '전 키 1회 호출',
              state: StepState.notStarted,
            ),
            OnboardingFinishCheck(
              label: '워치독 첫 핑',
              state: StepState.notStarted,
            ),
            OnboardingFinishCheck(
              label: '워치독 체크 active 확인',
              state: StepState.notStarted,
            ),
            OnboardingFinishCheck(
              label: 'GitHub 첫 커밋',
              state: StepState.notStarted,
            ),
            OnboardingFinishCheck(
              label: '상시 알림(FGS) 생존',
              state: StepState.notStarted,
            ),
          ]
        : const <OnboardingFinishCheck>[],
  );
}
