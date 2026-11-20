// E11p3d-5e — M9 S01 설정 홈 VM(설계 13 §8 R134) · 표본 = domain_contracts `m9/settings_home*` · `operations_sim_*`.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, Object?> _row(String name) {
  final Map<String, Object?> env = jsonDecode(
    File('../domain_contracts/fixtures/m9/$name.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return (env['rows']! as List<Object?>).first! as Map<String, Object?>;
}

// 2026-08-31 09:00 KST.
final DateTime _now = DateTime.utc(2026, 8, 31);

CredentialListVm _creds({
  bool stored = true,
  StepState? last = StepState.verified,
  RunMode run = RunMode.simInternal,
}) => credentialListVmOf(
  runMode: run,
  paper: PaperCredentialFacts(
    stored: stored,
    lastState: last,
    lastAtUtc: last == null ? null : DateTime.utc(2026, 8, 30, 23, 42),
  ),
  nowUtc: _now,
);

final ContributionSetting _contribution = ContributionSetting.fromJson(
  _row('contribution_setting_default'),
);

bool _onlyS02(String r) => r == AppRoutes.settingsCredentials;
bool _all(String _) => true;
bool _none(String _) => false;

SettingsHomeVm _vm({
  RunMode run = RunMode.simInternal,
  OperatingMode op = OperatingMode.autoTrade,
  CredentialListVm? creds,
  ContributionSetting? contribution,
  bool contributionGiven = true,
  bool config = true,
  bool Function(String) hasBody = _onlyS02,
}) => settingsHomeVmOf(
  SettingsHomeFacts(
    runMode: run,
    operatingMode: op,
    credentials: creds ?? _creds(run: run),
    contribution: contributionGiven ? (contribution ?? _contribution) : null,
    opsConfigReady: config,
    hasBody: hasBody,
  ),
  nowUtc: _now,
);

List<String> _codes(SettingsHomeVm vm) => <String>[
  for (final SettingsGroup g in vm.groups)
    for (final SettingsCard c in g.cards) c.code,
];

SettingsCard _card(SettingsHomeVm vm, String code) => vm.groups
    .expand((SettingsGroup g) => g.cards)
    .singleWhere((SettingsCard c) => c.code == code);

void main() {
  test('🔴 상태 칩 — 모의 = 표본 `operations_sim_auto` · `operations_sim_complete` 그대로(INFO · 승격 줄 없음)', () {
    expect(
      settingsStatusChipOf(RunMode.simInternal, OperatingMode.autoTrade),
      EngineStatusChip.fromJson(
        _row('operations_sim_auto')['status_chip']! as Map<String, Object?>,
      ),
    );
    expect(
      settingsStatusChipOf(RunMode.simBroker, OperatingMode.autoTrade),
      EngineStatusChip.fromJson(
        _row('operations_sim_complete')['status_chip']! as Map<String, Object?>,
      ),
    );
    expect(
      settingsStatusChipOf(RunMode.simInternal, OperatingMode.advisory),
      const EngineStatusChip(
        label: '모의 · 내부 가상 체결 · 투자 안내',
        level: UiLevel.info,
      ),
    );
  });

  test('🔴 상태 칩 — 실전 = 골든벡터 셀프테스트 원천 없음 → «판정 보류» WATCH(«통과»를 지어내지 않는다)', () {
    expect(
      settingsStatusChipOf(RunMode.live, OperatingMode.autoTrade),
      const EngineStatusChip(
        label: '실전 · 자동 주문 중 · 골든벡터 판정 보류',
        level: UiLevel.watch,
      ),
    );
    expect(
      settingsStatusChipOf(RunMode.live, OperatingMode.advisory).label,
      '실전 · 투자 안내 · 골든벡터 판정 보류',
    );
  });

  test(
    '🔴 S02 만 등록 = 운영(키 · 운용 · 월 납입) + 규칙(전략) · 링크 = 키만 · 일반 묶음 = 빈 묶음이라 뺀다',
    () {
      final SettingsHomeVm vm = _vm();
      expect(
        vm.groups.map((SettingsGroup g) => (g.tier, g.label)).toList(),
        <(SettingTier, String)>[
          (SettingTier.operational, '운영'),
          (SettingTier.rule, '규칙 · 12월 창에서만 적용'),
        ],
      );
      expect(_codes(vm), <String>[
        SettingsCardCodes.credentials,
        SettingsCardCodes.operations,
        SettingsCardCodes.contribution,
        SettingsCardCodes.allocation,
      ]);
      expect(
        _card(vm, SettingsCardCodes.credentials),
        const SettingsCard(
          code: 'SET_CREDENTIALS',
          title: '증권사 키',
          level: UiLevel.ok,
          statusLabel: '모의투자 정상',
          route: AppRoutes.settingsCredentials,
        ),
      );
      expect(
        _card(vm, SettingsCardCodes.operations),
        const SettingsCard(
          code: 'SET_OPERATIONS',
          title: '운용 관리',
          level: UiLevel.info,
          statusLabel: '모의 · 자동 매매',
        ),
      );
      expect(
        _card(vm, SettingsCardCodes.contribution),
        const SettingsCard(
          code: 'SET_CONTRIBUTION',
          title: '월 납입',
          level: UiLevel.info,
          statusLabel: '월 10만원',
        ),
      );
      expect(
        _card(vm, SettingsCardCodes.allocation),
        const SettingsCard(
          code: 'SET_ALLOCATION',
          title: '전략·배분',
          level: UiLevel.ok,
          statusLabel: 'balanced(P0S)',
        ),
      );
      // 12월 연간 리뷰 = S12 본문 · 창 판정 원천 전 → 부재.
      expect(vm.annualReviewLink, isNull);
    },
  );

  test('🔴 모든 본문이 있으면 카드 11장 = 표본 `settings_home` 의 차례 · 묶음 그대로 · 원천 없는 카드 = 상태 줄 없음 INFO', () {
    final SettingsHomeVm vm = _vm(hasBody: _all);
    final SettingsHomeVm fx = SettingsHomeVm.fromJson(_row('settings_home'));
    expect(_codes(vm), _codes(fx));
    expect(
      vm.groups.map((SettingsGroup g) => g.tier).toList(),
      fx.groups.map((SettingsGroup g) => g.tier).toList(),
    );
    for (final SettingsGroup g in fx.groups) {
      for (final SettingsCard c in g.cards) {
        final SettingsCard ours = _card(vm, c.code);
        expect(ours.title, c.title, reason: c.code);
        expect(ours.route, c.route, reason: c.code);
      }
    }
    for (final String bare in <String>[
      SettingsCardCodes.general,
      SettingsCardCodes.accounts,
      SettingsCardCodes.devices,
      SettingsCardCodes.connections,
      SettingsCardCodes.calendar,
      SettingsCardCodes.backup,
      SettingsCardCodes.diagnostics,
    ]) {
      final SettingsCard c = _card(vm, bare);
      expect(c.statusLabel, isNull, reason: bare);
      expect(c.attentionText, isNull, reason: bare);
      expect(c.level, UiLevel.info, reason: bare);
    }
    expect(vm.groups.first.label, '일반');
  });

  test('🔴 본문이 하나도 없으면 링크 0 · 원천 있는 카드만(키 · 운용 · 월 납입 · 전략)', () {
    final SettingsHomeVm vm = _vm(hasBody: _none);
    expect(_codes(vm), <String>[
      SettingsCardCodes.credentials,
      SettingsCardCodes.operations,
      SettingsCardCodes.contribution,
      SettingsCardCodes.allocation,
    ]);
    expect(
      vm.groups
          .expand((SettingsGroup g) => g.cards)
          .map((SettingsCard c) => c.route),
      everyElement(isNull),
    );
  });

  test('🔴 월 납입 원천 없음 = 본문 없으면 카드 부재 · 본문 있으면 상태 줄 없는 카드', () {
    expect(
      _codes(_vm(contributionGiven: false)),
      isNot(contains(SettingsCardCodes.contribution)),
    );
    expect(
      _card(
        _vm(contributionGiven: false, hasBody: _all),
        SettingsCardCodes.contribution,
      ),
      const SettingsCard(
        code: 'SET_CONTRIBUTION',
        title: '월 납입',
        level: UiLevel.info,
        route: AppRoutes.settingsContribution,
      ),
    );
  });

  test('🔴 운영 설정을 못 읽음 = 전략 카드 WATCH «운영 설정을 읽지 못했습니다»(P0S 를 지어내지 않는다)', () {
    final SettingsCard c = _card(
      _vm(config: false),
      SettingsCardCodes.allocation,
    );
    expect(c.level, UiLevel.watch);
    expect(c.statusLabel, '운영 설정을 읽지 못했습니다');
  });

  test('🔴 키 카드 — 미등록(모의 = 필수) ACT · 배지 1 · 실패 ACT · 기록 없음 WATCH(배지 없음)', () {
    final SettingsCard missing = _card(
      _vm(creds: _creds(stored: false, last: null)),
      SettingsCardCodes.credentials,
    );
    expect(missing.statusLabel, '모의투자 미등록');
    expect(missing.level, UiLevel.act);
    expect(missing.attentionText, '1');
    final SettingsCard failed = _card(
      _vm(creds: _creds(last: StepState.failed)),
      SettingsCardCodes.credentials,
    );
    expect(failed.statusLabel, '모의투자 검증 실패');
    expect(failed.level, UiLevel.act);
    expect(failed.attentionText, '1');
    final SettingsCard unknown = _card(
      _vm(creds: _creds(last: null)),
      SettingsCardCodes.credentials,
    );
    expect(unknown.statusLabel, '모의투자 검증 기록 없음');
    expect(unknown.level, UiLevel.watch);
    expect(unknown.attentionText, isNull);
    // 실전 = 모의 키 «선택» → 미등록은 INFO(경고 아님).
    final SettingsCard optional = _card(
      _vm(
        run: RunMode.live,
        creds: _creds(stored: false, last: null, run: RunMode.live),
      ),
      SettingsCardCodes.credentials,
    );
    expect(optional.level, UiLevel.info);
    expect(optional.attentionText, isNull);
  });

  test('🔴 키 카드 — 여러 벌 = 확인 필요 수 · 색 = 가장 나쁜 카드(INFO < OK < WATCH < ACT < BLOCKED) · 0벌', () {
    final CredentialCardVm ok = _creds().cards.single;
    CredentialListVm list(List<UiLevel> levels) => _creds().copyWith(
      cards: <CredentialCardVm>[
        for (final UiLevel l in levels) ok.copyWith(level: l),
      ],
    );
    SettingsCard of(List<UiLevel> levels) =>
        settingsCredentialsCardOf(list(levels), route: null)!;
    expect(of(<UiLevel>[UiLevel.ok, UiLevel.act]).statusLabel, '2벌 중 1벌 확인 필요');
    expect(of(<UiLevel>[UiLevel.ok, UiLevel.act]).level, UiLevel.act);
    expect(of(<UiLevel>[UiLevel.ok, UiLevel.act]).attentionText, '1');
    expect(of(<UiLevel>[UiLevel.blocked, UiLevel.act]).level, UiLevel.blocked);
    expect(of(<UiLevel>[UiLevel.blocked, UiLevel.act]).attentionText, '2');
    expect(of(<UiLevel>[UiLevel.ok, UiLevel.info]).statusLabel, '2벌 모두 확인됨');
    expect(of(<UiLevel>[UiLevel.ok, UiLevel.info]).level, UiLevel.ok);
    expect(of(<UiLevel>[UiLevel.info, UiLevel.ok]).level, UiLevel.ok);
    expect(of(<UiLevel>[UiLevel.ok, UiLevel.watch]).level, UiLevel.watch);
    expect(of(<UiLevel>[UiLevel.ok, UiLevel.watch]).attentionText, isNull);
    expect(of(<UiLevel>[UiLevel.watch, UiLevel.ok]).level, UiLevel.watch);
    expect(of(<UiLevel>[UiLevel.act, UiLevel.watch]).level, UiLevel.act);
    expect(settingsCredentialsCardOf(list(<UiLevel>[]), route: null), isNull);
    expect(
      settingsCredentialsCardOf(
        list(<UiLevel>[]),
        route: AppRoutes.settingsCredentials,
      ),
      const SettingsCard(
        code: 'SET_CREDENTIALS',
        title: '증권사 키',
        level: UiLevel.info,
        route: AppRoutes.settingsCredentials,
      ),
    );
  });

  test('🔴 운용 관리 한 줄 = 모의/실전 · 운영 방식', () {
    expect(
      settingsOperationsLabelOf(RunMode.simBroker, OperatingMode.advisory),
      '모의 · 투자 안내',
    );
    expect(
      settingsOperationsLabelOf(RunMode.live, OperatingMode.autoTrade),
      '실전 · 자동 주문 중',
    );
    expect(
      _card(
        _vm(run: RunMode.live, op: OperatingMode.advisory),
        SettingsCardCodes.operations,
      ).statusLabel,
      '실전 · 투자 안내',
    );
  });

  test('기준 시각 = 지금 · 26시간 · KST 글자', () {
    final AsOf a = _vm().asOf;
    expect(a.observedAt, _now);
    expect(a.tradeDate, const TradeDate('2026-08-31'));
    expect(a.source, AsOfSource.localSqlite);
    expect(a.staleAfter, const Duration(hours: 26));
    expect(a.label, '설정 기준 2026-08-31 09:00');
    expect(kSettingsHomeStaleAfter, const Duration(seconds: 93600));
  });

  test('표본과 같은 꼴 — VM · 묶음 · 카드 · 칩 JSON 키가 `settings_home` 과 같다(글자는 엔진)', () {
    final Map<String, Object?> fx = _row('settings_home');
    final Map<String, Object?> ours = jsonDecode(
      jsonEncode(_vm(hasBody: _all).toJson()),
    ) as Map<String, Object?>;
    expect(ours.keys.toSet(), fx.keys.toSet());
    Map<String, Object?> first(Map<String, Object?> m, String k) =>
        (m[k]! as List<Object?>).first! as Map<String, Object?>;
    expect(
      first(ours, 'groups').keys.toSet(),
      first(fx, 'groups').keys.toSet(),
    );
    expect(
      first(first(ours, 'groups'), 'cards').keys.toSet(),
      first(first(fx, 'groups'), 'cards').keys.toSet(),
    );
    expect(
      (ours['status_chip']! as Map<String, Object?>).keys.toSet(),
      (fx['status_chip']! as Map<String, Object?>).keys.toSet(),
    );
  });

  test('🆕 R196 — 키 카드 여러 벌: 확인 필요 0 이어도 미등록이 있으면 «n벌 중 k벌 미등록»(SIM 실전 · ISA = INFO · 색 = 가장 나쁜 카드)', () {
    final CredentialListVm list = credentialListVmOf(
      runMode: RunMode.simInternal,
      paper: PaperCredentialFacts(
        stored: true,
        lastState: StepState.verified,
        lastAtUtc: DateTime.utc(2026, 12, 21),
      ),
      nowUtc: DateTime.utc(2026, 12, 22),
      live: const <LiveCredentialFacts>[
        LiveCredentialFacts(kind: CredentialKindCodes.kisLive, stored: false),
        LiveCredentialFacts(kind: CredentialKindCodes.kisIsa, stored: false),
      ],
    );
    final SettingsCard? c = settingsCredentialsCardOf(
      list,
      route: AppRoutes.settingsCredentials,
    );
    expect(
      (c?.statusLabel, c?.level, c?.attentionText),
      ('3벌 중 2벌 미등록', UiLevel.ok, null),
    );
  });
}
