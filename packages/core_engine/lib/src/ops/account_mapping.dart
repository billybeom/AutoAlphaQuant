// E11p3d-5i — M9 `S03` 계좌 · 슬리브 매핑 VM 짓기(설계 13 §8 R151 · 앱 05 S03 · 01 §29 K20 · K29 · K35).
//
// 🔴 글자 = 엔진(표본 `m9/account_mapping*` 꼴) — 화면은 세지도 · 가리지도 · 고르지도 않는다.
// 🔴 계좌 = 지금 엔진에 있는 것만 — 모의 계좌(모의 키 세트 · 금고) 한 행은 늘 싣는다(1행 이상 · K29) ·
//    실전 계좌 별칭 = 지금 운영 설정(모의 개시 판)의 전략 → 계좌 별칭에서 — 번호 · 키 = 실전 키 세트 전이라 «등록 전».
// 🔴 번호 = 엔진 마스킹(`maskAccount` · 뒤 4 · SAF-906) · 원번호는 VM 에 싣지 않는다.
// 🔴 슬리브 칸 = A · B · C(POT = A 행의 한 줄 · 4번째 칸 아님 · K20) · 운영 설정이 없으면(사람 값 P0-① 전) = «미지정».
// 🔴 선택 · 전체 검증 버튼 = operator 동작 구현 전 + 실전 키 전 → 없음(누르면 실패하는 버튼을 만들지 않는다) · 잠김 = 생체 가드 전 → 없음.
// 🆕 E11p4e(R154) — 발주자가 정한 대응표(사람 값 자산 · R153)가 있고 운영 설정(모의 개시 판)이 아직 없으면 = 그 별칭을 싣되
//    «모의 개시 전» 한 줄 · INFO(정한 값 ≠ 지금 설정 — 주문은 아직 그 판으로 나가지 않는다) · 별칭 → 표시 글자(«isa» → «ISA»).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AccountMappingOption,
        AccountMappingVm,
        AccountRow,
        AsOf,
        AsOfSource,
        SleeveMappingRow,
        TradeDate,
        UiLevel;

import '../orders/order_draft.dart' show P0sStrategyIds;
import '../security/secret_mask.dart' show maskAccount;
import 'ledger_views.dart' show kstDateText;

/// 계좌 화면 신선도(표본 93600초 = 26시간).
const Duration kAccountMappingStaleAfter = Duration(hours: 26);

/// 슬리브 미지정 한 줄(표본 문장).
const String kSleeveUnmappedLine = '미지정 — 이 슬리브의 주문은 내지 않습니다.';

/// 🆕 R154 — 정한 대응표만 있고 모의 개시 판이 아직 없을 때의 한 줄.
const String kSleevePendingLine = '모의 개시 전 — 시작하면 이 계좌로 운영합니다.';

/// 모의 계좌 사실(금고의 모의 키 세트 · 마지막 검증).
class PaperAccountFacts {
  /// 사실을 만든다.
  const PaperAccountFacts({
    this.accountNo,
    this.productCode,
    this.verifiedAtUtc,
  });

  /// 계좌 번호 8자리(저장 안 됨 = null).
  final String? accountNo;

  /// 상품 코드 2자리(저장 안 됨 = null).
  final String? productCode;

  /// 마지막 검증 통과 시각(검증 = 모의 서버 잔고 조회 · 기록 없음 · 거절 = null).
  final DateTime? verifiedAtUtc;
}

/// 계좌 화면 사실.
class AccountMappingFacts {
  /// 사실을 만든다.
  const AccountMappingFacts({
    required this.paper,
    this.accountByStrategy,
    this.decidedByStrategy,
    this.accountLabels = const <String, String>{},
  });

  /// 모의 계좌.
  final PaperAccountFacts paper;

  /// 지금 운영 설정(모의 개시 판)의 전략 → 계좌 별칭(없음 = 운영 설정 없음).
  final Map<String, String>? accountByStrategy;

  /// 🆕 R154 — 발주자가 정한 전략 → 계좌 별칭(사람 값 자산 · 없음 = 아직 안 정함).
  final Map<String, String>? decidedByStrategy;

  /// 🆕 R154 — 별칭 → 화면 글자(없는 별칭 = 별칭 그대로).
  final Map<String, String> accountLabels;
}

String _two(int n) => n.toString().padLeft(2, '0');

String _kstShort(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  return '${_two(k.month)}-${_two(k.day)} ${_two(k.hour)}:${_two(k.minute)}';
}

AccountRow _paperRow(PaperAccountFacts p) {
  final String? no = p.accountNo;
  final DateTime? at = p.verifiedAtUtc;
  if (no == null) {
    return const AccountRow(
      label: '모의투자',
      kindLabel: '모의',
      maskedNumberText: '등록 전',
      checkText: '모의 키를 먼저 등록하세요(증권사 키)',
      badgeText: '실전 매핑 대상 아님',
      level: UiLevel.act,
    );
  }
  return AccountRow(
    label: '모의투자',
    kindLabel: '모의 ${p.productCode ?? '01'}',
    maskedNumberText: maskAccount(no),
    checkText: at == null
        ? '모의 서버 잔고 확인 기록 없음'
        : '모의 서버 잔고 확인 ${_kstShort(at)}',
    badgeText: '실전 매핑 대상 아님',
    level: at == null ? UiLevel.watch : UiLevel.info,
  );
}

const List<(String, String)> _sleeves = <(String, String)>[
  (P0sStrategyIds.sleeveA, '슬리브 A'),
  (P0sStrategyIds.sleeveB, '슬리브 B'),
  (P0sStrategyIds.sleeveC, '슬리브 C'),
];

/// 🔴 `S03` 계좌 · 슬리브 매핑.
AccountMappingVm accountMappingVmOf(
  AccountMappingFacts f, {
  required DateTime nowUtc,
}) {
  final Map<String, String>? map = f.accountByStrategy ?? f.decidedByStrategy;
  final bool pending =
      f.accountByStrategy == null && f.decidedByStrategy != null;
  String labelOf(String alias) => f.accountLabels[alias] ?? alias;
  final List<String> aliases = <String>[
    if (map != null)
      for (final (String id, String _) in _sleeves)
        if (map[id] != null) map[id]!,
    if (map != null && map[P0sStrategyIds.pot] != null)
      map[P0sStrategyIds.pot]!,
  ];
  final List<AccountRow> accounts = <AccountRow>[
    for (final String alias in <String>{...aliases})
      AccountRow(
        label: labelOf(alias),
        kindLabel: labelOf(alias),
        maskedNumberText: '등록 전',
        checkText: '실전 키 등록 전 — 잔고를 확인할 수 없습니다',
        level: UiLevel.watch,
      ),
    _paperRow(f.paper),
  ];
  final List<SleeveMappingRow> mappings = <SleeveMappingRow>[
    for (final (String id, String label) in _sleeves)
      if (map?[id] case final String alias)
        SleeveMappingRow(
          sleeveLabel: label,
          accountLabel: labelOf(alias),
          subbookLine:
              id == P0sStrategyIds.sleeveA && map![P0sStrategyIds.pot] == alias
              ? 'POT 서브북도 이 계좌에서 운용합니다.'
              : null,
          statusLine: pending ? kSleevePendingLine : null,
          level: pending ? UiLevel.info : UiLevel.ok,
          options: <AccountMappingOption>[
            AccountMappingOption(label: labelOf(alias), selected: true),
          ],
        )
      else
        SleeveMappingRow(
          sleeveLabel: label,
          statusLine: kSleeveUnmappedLine,
          level: UiLevel.act,
          options: const <AccountMappingOption>[],
        ),
  ];
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  return AccountMappingVm(
    accounts: accounts,
    mappings: mappings,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(kstDateText(nowUtc)),
      source: AsOfSource.localSqlite,
      staleAfter: kAccountMappingStaleAfter,
      label: '계좌 기준 ${kstDateText(nowUtc)} ${_two(k.hour)}:${_two(k.minute)}',
    ),
  );
}
