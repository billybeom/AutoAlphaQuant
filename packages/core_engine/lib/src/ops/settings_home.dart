// E11p3d-5e — M9 `S01` 설정 홈(더보기) VM 짓기(설계 13 §8 R134 · 앱 05 S01 · 01 §27).
//
// 🔴 글자 = 엔진(표본 `m9/settings_home*` 꼴) — 화면은 세지도 · 묶지도 · 고르지도 않는다(05 S01 그림 4).
// 🔴 카드 = 원천 있는 상태 한 줄이 있거나 조립 앱에 본문이 등록된 화면만 — 둘 다 없으면 싣지 않는다(지어내지 않는다) ·
//    빈 묶음 = 뺀다(계약 «빈 묶음 = 엔진이 뺀다»).
// 🔴 링크 = 본문이 등록된 화면만([SettingsHomeFacts.hasBody]) — 없는 화면으로 보내지 않는다(05 S01 «route null = 탭 부재»).
// 🔵 상태 칩 = 실행 모드 × 운영 방식(표본 `operations_sim_*` 글자) · 골든벡터 셀프테스트(S10) 원천 없음 →
//    실전은 «골든벡터 판정 보류»(WATCH) · 모의는 판정 칸 없이 INFO(표본 그대로) · 승격 줄 = dry-run 관찰 원천 전 → 없음.
// 🔵 운영 묶음 머리 = «운영»(생체 가드 M5 전 — «들어갈 때 생체 인증»을 약속하지 않는다).
// 🔵 12월 연간 리뷰 카드 = 🆕 E11p4l(R168) 신뢰 시각 12월 · S12 본문 등록 때만(`annualReviewHomeLinkOf` · 시각 모름 = 부재).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        ContributionSetting,
        CredentialCardVm,
        CredentialListVm,
        EngineStatusChip,
        OperatingMode,
        RunMode,
        SettingTier,
        SettingsCard,
        SettingsGroup,
        SettingsHomeVm,
        TradeDate,
        UiLevel;

import 'annual_review_index.dart' show annualReviewHomeLinkOf;
import 'ledger_views.dart' show kstDateText;

/// 설정 홈 신선도(표본 `stale_after_seconds` 93600 = 26시간).
const Duration kSettingsHomeStaleAfter = Duration(hours: 26);

/// 설정 카드 코드(표본 사전과 같은 글자 · 🔴 화면 미참조).
abstract final class SettingsCardCodes {
  /// 일반(알림 · 방해금지 · 화면).
  static const String general = 'SET_GENERAL';

  /// 증권사 키.
  static const String credentials = 'SET_CREDENTIALS';

  /// 계좌 · 매핑.
  static const String accounts = 'SET_ACCOUNTS';

  /// 운용 관리.
  static const String operations = 'SET_OPERATIONS';

  /// 월 납입.
  static const String contribution = 'SET_CONTRIBUTION';

  /// 기기 · 접근.
  static const String devices = 'SET_DEVICES';

  /// 연결.
  static const String connections = 'SET_CONNECTIONS';

  /// 구글 캘린더.
  static const String calendar = 'SET_CALENDAR';

  /// 백업 · 복원.
  static const String backup = 'SET_BACKUP';

  /// 진단(골든벡터 · 무결성).
  static const String diagnostics = 'SET_DIAGNOSTICS';

  /// 전략 · 배분.
  static const String allocation = 'SET_ALLOCATION';
}

/// 전략 · 배분 카드 글자(정본 = P0S · SPEC v2.31).
const String kSettingsAllocationLabel = 'balanced(P0S)';

/// 운영 설정을 못 읽었을 때의 전략 · 배분 카드 글자.
const String kSettingsAllocationMissingLabel = '운영 설정을 읽지 못했습니다';

/// 설정 홈 사실.
class SettingsHomeFacts {
  /// 사실을 만든다.
  const SettingsHomeFacts({
    required this.runMode,
    required this.operatingMode,
    required this.credentials,
    required this.opsConfigReady,
    required this.hasBody,
    this.contribution,
    this.trustedNowUtc,
  });

  /// 🆕 R168 — 신뢰 시각(12월 연간 리뷰 카드 · 모르면 null = 카드 부재).
  final DateTime? trustedNowUtc;

  /// 지금 실행 모드.
  final RunMode runMode;

  /// 지금 운영 방식.
  final OperatingMode operatingMode;

  /// 키 목록(S02 와 같은 VM — 카드 한 줄은 이것을 줄인다).
  final CredentialListVm credentials;

  /// 월 납입 운영값(없으면 카드 상태 줄 없음).
  final ContributionSetting? contribution;

  /// 운영 설정(P0S)을 읽었나.
  final bool opsConfigReady;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;
}

String _two(int n) => n.toString().padLeft(2, '0');

String _runLabel(RunMode m) => switch (m) {
  RunMode.simInternal => '모의 · 내부 가상 체결',
  RunMode.simBroker => '모의 · KIS 모의투자 서버',
  RunMode.live => '실전',
};

String _operatingLabel(RunMode r, OperatingMode m) => switch (m) {
  OperatingMode.autoTrade => r == RunMode.live ? '자동 주문 중' : '자동 매매',
  OperatingMode.advisory => '투자 안내',
};

/// 상태 칩 — 실행 모드 × 운영 방식.
EngineStatusChip settingsStatusChipOf(RunMode run, OperatingMode op) {
  final String head = '${_runLabel(run)} · ${_operatingLabel(run, op)}';
  return run == RunMode.live
      ? EngineStatusChip(label: '$head · 골든벡터 판정 보류', level: UiLevel.watch)
      : EngineStatusChip(label: head, level: UiLevel.info);
}

/// 운용 관리 카드 한 줄(모의/실전 · 운영 방식).
String settingsOperationsLabelOf(RunMode run, OperatingMode op) =>
    '${run == RunMode.live ? '실전' : '모의'} · ${_operatingLabel(run, op)}';

int _rank(UiLevel l) => switch (l) {
  UiLevel.info => 0,
  UiLevel.ok => 1,
  UiLevel.watch => 2,
  UiLevel.act => 3,
  UiLevel.blocked => 4,
};

bool _needsAttention(CredentialCardVm c) =>
    c.level == UiLevel.act || c.level == UiLevel.blocked;

/// 증권사 키 카드 — 한 벌이면 «종류 상태» · 여러 벌이면 확인 필요 수 · 색 = 가장 나쁜 카드 · 배지 = 확인 필요 수.
SettingsCard? settingsCredentialsCardOf(
  CredentialListVm list, {
  required String? route,
}) {
  final List<CredentialCardVm> cards = list.cards;
  if (cards.isEmpty && route == null) return null;
  final int attention = cards.where(_needsAttention).length;
  UiLevel level = UiLevel.info;
  for (final CredentialCardVm c in cards) {
    if (_rank(c.level) > _rank(level)) level = c.level;
  }
  final String? status = cards.isEmpty
      ? null
      : cards.length == 1
      ? '${cards.single.kindLabel} ${cards.single.healthLabel}'
      : attention == 0
      ? '${cards.length}벌 모두 확인됨'
      : '${cards.length}벌 중 $attention벌 확인 필요';
  return SettingsCard(
    code: SettingsCardCodes.credentials,
    title: '증권사 키',
    level: level,
    statusLabel: status,
    attentionText: attention == 0 ? null : '$attention',
    route: route,
  );
}

/// 🔴 `S01` 설정 홈.
SettingsHomeVm settingsHomeVmOf(
  SettingsHomeFacts f, {
  required DateTime nowUtc,
}) {
  String? link(String route) => f.hasBody(route) ? route : null;

  // 원천 없는 화면 — 본문이 있을 때만 카드(상태 줄 없음 · INFO).
  SettingsCard? bare(String code, String title, String route) {
    final String? r = link(route);
    return r == null
        ? null
        : SettingsCard(code: code, title: title, level: UiLevel.info, route: r);
  }

  final ContributionSetting? contribution = f.contribution;
  final List<SettingsGroup> groups = <SettingsGroup>[
    for (final (SettingTier tier, String label, List<SettingsCard?> cards)
        in <(SettingTier, String, List<SettingsCard?>)>[
          (
            SettingTier.general,
            '일반',
            <SettingsCard?>[
              bare(
                SettingsCardCodes.general,
                '알림·방해금지·화면',
                AppRoutes.settingsGeneral,
              ),
            ],
          ),
          (
            SettingTier.operational,
            '운영',
            <SettingsCard?>[
              settingsCredentialsCardOf(
                f.credentials,
                route: link(AppRoutes.settingsCredentials),
              ),
              bare(
                SettingsCardCodes.accounts,
                '계좌·매핑',
                AppRoutes.settingsAccounts,
              ),
              SettingsCard(
                code: SettingsCardCodes.operations,
                title: '운용 관리',
                level: UiLevel.info,
                statusLabel: settingsOperationsLabelOf(
                  f.runMode,
                  f.operatingMode,
                ),
                route: link(AppRoutes.settingsOperations),
              ),
              if (contribution != null)
                SettingsCard(
                  code: SettingsCardCodes.contribution,
                  title: '월 납입',
                  level: UiLevel.info,
                  statusLabel: '월 ${contribution.amountText}',
                  route: link(AppRoutes.settingsContribution),
                )
              else
                bare(
                  SettingsCardCodes.contribution,
                  '월 납입',
                  AppRoutes.settingsContribution,
                ),
              bare(
                SettingsCardCodes.devices,
                '기기·접근',
                AppRoutes.settingsDevices,
              ),
              bare(
                SettingsCardCodes.connections,
                '연결',
                AppRoutes.settingsConnections,
              ),
              bare(
                SettingsCardCodes.calendar,
                '구글 캘린더',
                AppRoutes.settingsCalendar,
              ),
              bare(SettingsCardCodes.backup, '백업·복원', AppRoutes.settingsBackup),
              bare(
                SettingsCardCodes.diagnostics,
                '진단',
                AppRoutes.settingsDiagnostics,
              ),
            ],
          ),
          (
            SettingTier.rule,
            '규칙 · 12월 창에서만 적용',
            <SettingsCard?>[
              SettingsCard(
                code: SettingsCardCodes.allocation,
                title: '전략·배분',
                level: f.opsConfigReady ? UiLevel.ok : UiLevel.watch,
                statusLabel: f.opsConfigReady
                    ? kSettingsAllocationLabel
                    : kSettingsAllocationMissingLabel,
                route: link(AppRoutes.settingsAllocation),
              ),
            ],
          ),
        ])
      if (cards.whereType<SettingsCard>().isNotEmpty)
        SettingsGroup(
          tier: tier,
          label: label,
          cards: cards.whereType<SettingsCard>().toList(),
        ),
  ];
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  return SettingsHomeVm(
    statusChip: settingsStatusChipOf(f.runMode, f.operatingMode),
    annualReviewLink: annualReviewHomeLinkOf(
      trustedNowUtc: f.trustedNowUtc,
      hasBody: f.hasBody,
    ),
    groups: groups,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(kstDateText(nowUtc)),
      source: AsOfSource.localSqlite,
      staleAfter: kSettingsHomeStaleAfter,
      label: '설정 기준 ${kstDateText(nowUtc)} ${_two(k.hour)}:${_two(k.minute)}',
    ),
  );
}
