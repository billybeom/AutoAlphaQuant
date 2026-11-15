// 온보딩 단계 목록 · 상세 VM 짓기(E11p4a · 설계 13 §8 R122 · 앱 01 §25 K15 · K17 · K18 · C-50 ⑥⑦ · 04 §9 O-01 · O-02).
//
// 🔴 카탈로그 = v1.16 표본(`m8/onboarding_steps_fresh` · `_advisory`)의 id · 차례 · 필수도 · 글자 그대로 — 엔진 정본(R122 O1).
//    문구는 표본에 있는 글자만 쓴다 · 표본에 없는 칸(where · how 대부분) = null(지어내지 않는다).
// 🔴 고르기 전(onboarding_choice 없음) = 행 0 + 빈 문장(표본 `_steps_empty`) · 고른 뒤 = 그 방식의 카탈로그.
// 🔴 사실 = 진척 행(`onboarding_progress`) · 조립 앱의 실측(권한 등)을 [OnboardingStepFact] 로 받는다 —
//    원천이 없는 필수 단계 = 게이트 UNKNOWN(막힘 — 마무리로 못 간다 · 표본 `CONNECTION_STATE` · `DEVICE_LEDGER`).
// 🔴 마무리 링크 = 필수 전부 VERIFIED ∧ 게이트 전부 null · PASS · NOT_APPLICABLE(K17).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        CredentialKindCodes,
        GateBadge,
        GateState,
        OnboardingAction,
        OnboardingSlotIds,
        OnboardingStep,
        OnboardingStepDetailVm,
        OnboardingStepsVm,
        OnboardingTrack,
        OperatingMode,
        SettingsActionId,
        StepRequirement,
        StepState;

import '../ops/ledger_views.dart' show kstDateText;

/// 단계 하나의 사실(진척 행 · 실측).
class OnboardingStepFact {
  /// 사실을 만든다.
  const OnboardingStepFact({
    required this.state,
    this.verifiedUntil,
    this.failureReasonCode,
  });

  /// 🔴 원천이 없다(확인할 길이 아직 없다) — 필수면 게이트 UNKNOWN.
  const OnboardingStepFact.unknown()
    : state = null,
      verifiedUntil = null,
      failureReasonCode = null;

  /// 상태(null = 원천 없음).
  final StepState? state;

  /// 유효 기한.
  final DateTime? verifiedUntil;

  /// 실패 원문 코드.
  final String? failureReasonCode;
}

/// 방식 하나에서의 자리(필수도 · 차례).
class _Place {
  const _Place(this.need, this.order, {this.title, this.why, this.outOfScope});
  final StepRequirement need;
  final int order;
  final String? title;
  final String? why;

  /// 이 방식에서는 해당 없음(게이트 TRACK_SCOPE · NOT_APPLICABLE) 문장.
  final String? outOfScope;
}

/// 카탈로그 한 단계.
class _Spec {
  const _Spec({
    required this.id,
    required this.title,
    required this.why,
    required this.seconds,
    required this.estimatedText,
    this.auto,
    this.advisory,
    this.verificationLabel,
    this.unknownGate,
    this.after,
    this.hasDetail = true,
    this.whereText,
    this.howText,
    this.verify,
    this.secretSlotId,
    this.failureTexts = const <String, String>{},
  });

  final String id;
  final String title;
  final String why;
  final int seconds;
  final String estimatedText;
  final _Place? auto;
  final _Place? advisory;
  final String? verificationLabel;

  /// 원천 없음 게이트(code, label) — 필수일 때만 붙는다.
  final (String, String)? unknownGate;

  /// 앞 단계(id, 짧은 이름) — 그 단계가 VERIFIED 여야 열린다.
  final (String, String)? after;
  final bool hasDetail;
  final String? whereText;
  final String? howText;
  final OnboardingAction? verify;
  final String? secretSlotId;
  final Map<String, String> failureTexts;
}

const String _connUnknown = '연결 상태를 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다';
const (String, String) _conn = ('CONNECTION_STATE', _connUnknown);

/// 🔴 카탈로그(v1.16 표본 그대로 · R122 O1).
const List<_Spec> _catalogue = <_Spec>[
  _Spec(
    id: 'o_01',
    title: '기기 등록',
    why: '이 폰을 운영 기기로 등록합니다.',
    seconds: 180,
    estimatedText: '약 3분',
    auto: _Place(StepRequirement.required_, 1),
    advisory: _Place(StepRequirement.required_, 1),
    verificationLabel: '이 폰을 운영 기기로 등록함',
    unknownGate: ('DEVICE_LEDGER', '기기 원장을 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다'),
  ),
  _Spec(
    id: 'o_02',
    title: 'KIS 모의 앱키 등록',
    why: '시세와 모의 주문에 쓰는 키입니다. 실전 키는 지금 넣지 않습니다.',
    seconds: 900,
    estimatedText: '약 15분',
    auto: _Place(StepRequirement.required_, 2),
    advisory: _Place(
      StepRequirement.required_,
      2,
      title: 'KIS 모의 앱키(시세)',
      why: '수기 기록의 가격 범위 검증에 시세가 필요합니다.',
    ),
    verificationLabel: '토큰 발급 + 모의 잔고 조회 1회',
    whereText: '한국투자증권 KIS Developers 누리집의 모의투자 메뉴에서 앱키와 앱시크릿을 발급받습니다.',
    howText: '토큰을 한 번 발급하고 모의 잔고를 한 번 조회해 확인합니다.',
    verify: OnboardingAction(
      id: SettingsActionId.credentialVerify,
      args: <String, String>{'kind': CredentialKindCodes.kisPaper},
      label: '검증 실행',
    ),
    secretSlotId: OnboardingSlotIds.secretKisMock,
  ),
  _Spec(
    id: 'o_03',
    title: '계좌 매핑 · 절세계좌 판정',
    why: '슬리브와 계좌를 잇고 절세계좌 판정을 한 번 통과합니다.',
    seconds: 600,
    estimatedText: '약 10분',
    auto: _Place(StepRequirement.required_, 3),
    advisory: _Place(StepRequirement.required_, 3),
    unknownGate: _conn,
    after: ('o_02', '모의 앱키'),
  ),
  _Spec(
    id: 'o_05',
    title: '알림 권한',
    why: '안내와 경보를 놓치지 않게 합니다.',
    seconds: 120,
    estimatedText: '약 2분',
    auto: _Place(StepRequirement.recommended, 4),
    advisory: _Place(StepRequirement.recommended, 5),
    failureTexts: <String, String>{
      'PERMISSION_DENIED': '알림 권한이 꺼져 있습니다. 휴대폰 설정에서 켠 뒤 다시 확인하십시오.',
    },
  ),
  _Spec(
    id: 'o_06',
    title: '배터리 최적화 예외',
    why: '새벽 배치가 잠들지 않게 합니다.',
    seconds: 240,
    estimatedText: '약 4분',
    auto: _Place(StepRequirement.recommended, 5),
    whereText: '휴대폰 설정 → 배터리 → 앱 최적화 제외에서 이 앱을 고릅니다.',
    howText: '다음 새벽 배치가 깨어나면 엔진이 확인합니다.',
  ),
  _Spec(
    id: 'o_07',
    title: 'Supabase 연결',
    why: '다른 기기가 읽을 기록을 올립니다.',
    seconds: 600,
    estimatedText: '약 10분',
    auto: _Place(StepRequirement.required_, 6),
    advisory: _Place(StepRequirement.required_, 6),
    unknownGate: _conn,
  ),
  _Spec(
    id: 'o_08',
    title: 'GitHub 데이터 저장소',
    why: '매일 기록을 보관합니다.',
    seconds: 600,
    estimatedText: '약 10분',
    auto: _Place(StepRequirement.required_, 7),
    advisory: _Place(StepRequirement.required_, 7),
    verificationLabel: '토큰으로 빈 커밋 1회',
    unknownGate: _conn,
    failureTexts: <String, String>{
      'TOKEN_EXPIRED': '저장소 토큰이 만료되었습니다. 새로 발급해 다시 검증하십시오.',
    },
  ),
  _Spec(
    id: 'o_09',
    title: '알림 채널 · 워치독 채널',
    why: '안내를 못 받는 것도 사고입니다.',
    seconds: 480,
    estimatedText: '약 8분',
    auto: _Place(StepRequirement.required_, 8),
    advisory: _Place(StepRequirement.required_, 8),
    unknownGate: _conn,
  ),
  _Spec(
    id: 'o_10',
    title: 'healthchecks.io 연결',
    why: '폰이 멈추면 바깥에서 알려 줍니다.',
    seconds: 300,
    estimatedText: '약 5분',
    auto: _Place(StepRequirement.required_, 9),
    advisory: _Place(StepRequirement.required_, 9),
    unknownGate: _conn,
  ),
  _Spec(
    id: 'o_11',
    title: 'Android 권한 실측',
    why: '상시 알림 5분 생존과 정확 알람 1회를 확인합니다.',
    seconds: 420,
    estimatedText: '약 7분',
    auto: _Place(StepRequirement.required_, 10),
    advisory: _Place(
      StepRequirement.recommended,
      10,
      why: '무인 발주가 없어 위험이 낮지만, 배치가 안 돌면 안내도 나오지 않습니다.',
    ),
    unknownGate: _conn,
  ),
  _Spec(
    id: 'o_12',
    title: 'KIS 대사 전용 키',
    why: '잔고 대조에만 쓰는 키입니다.',
    seconds: 600,
    estimatedText: '약 10분',
    auto: _Place(
      StepRequirement.optional,
      11,
      outOfScope: '자동 매매에서는 필요하지 않습니다',
    ),
    advisory: _Place(
      StepRequirement.recommended,
      4,
      why: '등록하지 않으면 원장 신뢰 등급이 자기 보고로 고정됩니다. 진행은 막지 않습니다.',
    ),
  ),
  _Spec(
    id: 'o_13',
    title: 'Google 캘린더(선택)',
    why: '일정에 기록을 남깁니다.',
    seconds: 300,
    estimatedText: '약 5분',
    auto: _Place(StepRequirement.optional, 12),
    hasDetail: false,
  ),
];

/// 카탈로그의 단계 id(차례 = 자동 매매 표).
List<String> get onboardingStepIds => <String>[
  for (final _Spec s in _catalogue) s.id,
];

/// 고르기 전 빈 문장(표본 `_steps_empty`).
const String kOnboardingStepsEmptyLabel =
    '받은 준비물 목록이 없습니다. 운영 방식을 고른 뒤 다시 여십시오.';

/// 목록에 없는 단계(표본 `_step_detail_missing`).
const String kOnboardingStepMissingLabel =
    '이 단계는 지금 목록에 없습니다. 단계 목록에서 다시 고르십시오.';

/// 권장 경고(표본).
const String kOnboardingRecommendedWarning = '권장 단계가 남았습니다 — 진행은 막지 않습니다';

/// 실패 문장 — 단계 사전에 없는 코드(표본 밖 · 조치 = 다시 확인).
const String kOnboardingFailureFallback = '확인에 실패했습니다. 안내를 따라 다시 확인하십시오.';

String _needLabel(StepRequirement r) => switch (r) {
  StepRequirement.required_ => '필수',
  StepRequirement.recommended => '권장',
  StepRequirement.optional => '선택',
};

_Place? _placeOf(_Spec s, OperatingMode mode) => switch (mode) {
  OperatingMode.autoTrade => s.auto,
  OperatingMode.advisory => s.advisory,
};

/// 그 방식의 카탈로그(차례대로).
List<(_Spec, _Place)> _rowsFor(OperatingMode mode) {
  final List<(_Spec, _Place)> out = <(_Spec, _Place)>[
    for (final _Spec s in _catalogue)
      if (_placeOf(s, mode) case final _Place p) (s, p),
  ];
  out.sort(((_Spec, _Place) a, (_Spec, _Place) b) => a.$2.order - b.$2.order);
  return out;
}

OnboardingStep _stepOf(
  _Spec s,
  _Place p,
  int order,
  Map<String, OnboardingStepFact> facts,
  DateTime nowUtc,
) {
  final OnboardingStepFact fact =
      facts[s.id] ?? const OnboardingStepFact.unknown();
  final StepState state = fact.state ?? StepState.notStarted;
  final bool known = fact.state != null;
  final DateTime? until = fact.verifiedUntil;
  String? untilText;
  if (until != null) {
    final bool over =
        state == StepState.expired || !until.toUtc().isAfter(nowUtc.toUtc());
    untilText = '${kstDateText(until)}${over ? '에 만료됨' : '까지'}';
  }
  final String? code = fact.failureReasonCode;
  final bool failed = state == StepState.failed || code != null;
  GateBadge? gate;
  final (String, String)? after = s.after;
  final String? outOfScope = p.outOfScope;
  if (outOfScope != null) {
    gate = GateBadge(
      code: 'TRACK_SCOPE',
      label: outOfScope,
      state: GateState.notApplicable,
    );
  } else if (after != null) {
    final bool open = facts[after.$1]?.state == StepState.verified;
    gate = open
        ? const GateBadge(
            code: 'STEP_OPEN',
            label: '열렸습니다',
            state: GateState.pass,
          )
        : GateBadge(
            code: 'STEP_ORDER',
            label: '앞 단계(${after.$2})가 끝나야 열립니다',
            state: GateState.block,
          );
  }
  final (String, String)? unknownGate = s.unknownGate;
  if (!known &&
      p.need == StepRequirement.required_ &&
      unknownGate != null &&
      (gate == null || gate.state != GateState.block)) {
    gate = GateBadge(
      code: unknownGate.$1,
      label: unknownGate.$2,
      state: GateState.unknown,
    );
  }
  return OnboardingStep(
    stepId: s.id,
    track: OnboardingTrack.fresh,
    order: order,
    title: p.title ?? s.title,
    whyLine: p.why ?? s.why,
    estimated: Duration(seconds: s.seconds),
    estimatedText: s.estimatedText,
    requirement: p.need,
    state: state,
    verificationLabel: state == StepState.notStarted
        ? null
        : s.verificationLabel,
    verifiedUntil: until,
    failureReasonCode: code,
    requirementLabel: _needLabel(p.need),
    warningLabel:
        p.need == StepRequirement.recommended && state != StepState.verified
        ? kOnboardingRecommendedWarning
        : null,
    verifiedUntilText: untilText,
    failureText: failed
        ? (code == null ? null : s.failureTexts[code]) ??
              kOnboardingFailureFallback
        : null,
    gate: gate,
    detailDeepLink: s.hasDetail
        ? AppRoutes.onboardingStep.replaceFirst(':stepId', s.id)
        : null,
  );
}

/// 🔴 `O-01` 단계 목록 — [mode] = `onboarding_choice`(null = 고르기 전 → 행 0 + 빈 문장).
OnboardingStepsVm onboardingStepsVmOf({
  required OperatingMode? mode,
  required Map<String, OnboardingStepFact> facts,
  required DateTime nowUtc,
}) {
  if (mode == null) {
    return const OnboardingStepsVm(
      progressText: '0/0 완료',
      rows: <OnboardingStep>[],
      emptyLabel: kOnboardingStepsEmptyLabel,
    );
  }
  final List<(_Spec, _Place)> spec = _rowsFor(mode);
  final List<OnboardingStep> rows = <OnboardingStep>[
    for (int i = 0; i < spec.length; i++)
      _stepOf(spec[i].$1, spec[i].$2, i + 1, facts, nowUtc),
  ];
  final int done = rows
      .where((OnboardingStep r) => r.state == StepState.verified)
      .length;
  final bool requiredDone = rows
      .where((OnboardingStep r) => r.requirement == StepRequirement.required_)
      .every((OnboardingStep r) => r.state == StepState.verified);
  final bool gatesOpen = rows.every(
    (OnboardingStep r) =>
        r.gate == null ||
        r.gate!.state == GateState.pass ||
        r.gate!.state == GateState.notApplicable,
  );
  return OnboardingStepsVm(
    progressText: '$done/${rows.length} 완료',
    rows: rows,
    finishDeepLink: requiredDone && gatesOpen
        ? AppRoutes.onboardingFinish
        : null,
  );
}

/// 🔴 `O-02`·`O-03` 단계 상세 — 목록과 같은 객체 · 목록에 없는 id = 빈 문장만(K18).
OnboardingStepDetailVm onboardingStepDetailVmOf({
  required String stepId,
  required OperatingMode? mode,
  required Map<String, OnboardingStepFact> facts,
  required DateTime nowUtc,
}) {
  final OnboardingStepsVm list = onboardingStepsVmOf(
    mode: mode,
    facts: facts,
    nowUtc: nowUtc,
  );
  OnboardingStep? step;
  for (final OnboardingStep r in list.rows) {
    if (r.stepId == stepId) step = r;
  }
  if (step == null || step.detailDeepLink == null) {
    return const OnboardingStepDetailVm(
      missingLabel: kOnboardingStepMissingLabel,
    );
  }
  final _Spec s = _catalogue.singleWhere((_Spec x) => x.id == stepId);
  final bool blocked = step.gate?.state == GateState.block;
  return OnboardingStepDetailVm(
    step: step,
    whereText: s.whereText,
    howText: s.howText,
    verify: blocked ? null : s.verify,
    secretSlotId: blocked ? null : s.secretSlotId,
  );
}
