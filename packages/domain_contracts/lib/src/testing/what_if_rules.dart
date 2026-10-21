// What-if 미리보기 표시 계약의 판정 함수 — C-38 ①~⑧(입금) · C-41 ①②(리밸런싱). 01 §7 표 · §14 · §15-4-12.
//
// 왜 여기 있는가(설계 13 §8 R18 D-12 · E7a0): 같은 판정을 **픽스처**(계약 테스트 c38 · c41)와 **실엔진 출력**
//   (core_engine 의 What-if 구현 시험)에 똑같이 걸어야 한다. 판정이 `test/` 안의 비공개 함수로만 있으면
//   엔진 쪽이 사본을 만들게 되고 두 판이 갈라진다 — 그래서 테스트 전용 배럴(`testing.dart`)로 낸다.
// 🔴 `lib/` 의 화면 코드에서 import 하지 않는다(받침대와 같은 규칙 · `testing.dart` 머리).
// 🔴 함수는 판정만 한다 — 위반 문장 목록을 돌려주고 빈 목록 = 통과. 값을 고치거나 지어내지 않는다.
// 🔴 픽스처 전용 단언(갈래 표본 수 · 행 순서 · 밴드 표본 정합 · 접수증 ⑨)은 계약 테스트에 남는다 —
//    실엔진 출력에는 참이 아닐 수 있다(예: B 신호·C·POT 는 밴드 안에서도 초안을 만든다).

import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../../domain_contracts.dart';

/// C-38 ③ · C-41 ② — 미리보기 고지 문장의 머리.
const String kPreviewNoticeHead = '미리보기입니다';

/// C-38 ① — 래퍼는 `plan` · `inputRejectedText` · `blockedText` 가운데 **정확히 하나** non-null ·
/// `blockedAction` 은 `blockedText` 가 있을 때만 · 실린 글자는 비지 않는다.
List<String> depositPreviewResultViolations(
  String where,
  DepositPreviewResult r,
) {
  final List<String> bad = <String>[];
  final int n = <Object?>[
    r.plan,
    r.inputRejectedText,
    r.blockedText,
  ].where((Object? x) => x != null).length;
  if (n != 1) {
    bad.add(
      '$where — plan·input_rejected_text·blocked_text 가 $n개 non-null(정확히 하나여야 한다)',
    );
  }
  if (r.blockedAction != null && r.blockedText == null) {
    bad.add('$where — blocked_text 없이 blocked_action 이 있다');
  }
  for (final (String key, String? text) in <(String, String?)>[
    ('input_rejected_text', r.inputRejectedText),
    ('blocked_text', r.blockedText),
    ('blocked_action.label', r.blockedAction?.label),
  ]) {
    if (text != null && text.trim().isEmpty) {
      bad.add('$where — $key 가 빈 글자다');
    }
  }
  return bad;
}

/// C-38 ② — 표시 글자(`label` · `*_label` · `*_text` · 제목 · 고지 · 근거)가 비지 않는다 ·
/// `residualKrwCashText == null ⇔ residualKrwCash == 0` · `ordersEmptyText != null ⇔ 빈 초안` ·
/// `limitPriceText == null ⇔ limitPrice == null`.
List<String> depositPlanTextViolations(String where, DepositPlan p) {
  final List<String> bad = <String>[];
  _walkJson(jsonDecode(jsonEncode(p.toJson())), (
    String jsonPath,
    String key,
    Object? value,
  ) {
    final bool textKey =
        key == 'label' ||
        key.endsWith('_label') ||
        key.endsWith('_text') ||
        key == 'order_drafts_title' ||
        key == 'preview_notice' ||
        key == 'basis_note';
    if (textKey && value is String && value.trim().isEmpty) {
      bad.add('$where $jsonPath — 빈 글자다');
    }
  });
  for (int i = 0; i < p.warningLines.length; i++) {
    if (p.warningLines[i].trim().isEmpty) {
      bad.add('$where warning_lines[$i] — 빈 글자다');
    }
  }
  final bool zeroResidual = p.residualKrwCash == Decimal.zero;
  if ((p.residualKrwCashText == null) != zeroResidual) {
    bad.add(
      '$where — residual_krw_cash ${p.residualKrwCash} · residual_krw_cash_text '
      '${p.residualKrwCashText == null ? '없음' : '있음'}(null ⇔ 잔여 0)',
    );
  }
  bad.addAll(_draftListViolations(where, p.orderDrafts, p.ordersEmptyText));
  return bad;
}

/// C-38 ③ — 계획 **여럿**에 걸친다: 모든 `previewNotice` 가 «미리보기입니다»로 시작하고 같은 문자열이다
/// (고지 전용 — 경고·만료를 싣지 않는다 · 01 §14-5). 엔진 시험은 시나리오 출력 전부를 한 목록으로 넘긴다.
List<String> depositPreviewNoticeViolations(List<(String, DepositPlan)> plans) {
  final List<String> bad = <String>[];
  final Set<String> distinct = <String>{};
  for (final (String where, DepositPlan p) in plans) {
    distinct.add(p.previewNotice);
    if (!p.previewNotice.startsWith(kPreviewNoticeHead)) {
      bad.add(
        '$where — preview_notice 가 «$kPreviewNoticeHead»로 시작하지 않는다: ${p.previewNotice}',
      );
    }
  }
  if (distinct.length > 1) {
    bad.add('preview_notice 가 같은 문자열이 아니다(고지 전용 — 경고·만료를 싣지 않는다): $distinct');
  }
  return bad;
}

/// C-38 ④ — `fundingSteps` 는 null 이거나 비지 않는다 · `order` 1부터 연속 · `expectedProceeds > 0`.
List<String> depositFundingViolations(String where, DepositPlan p) {
  final List<FundingStep>? steps = p.fundingSteps;
  if (steps == null) {
    return const <String>[];
  }
  if (steps.isEmpty) {
    return <String>['$where — funding_steps 가 빈 목록이다(null 이거나 비지 않아야 한다)'];
  }
  final List<String> bad = <String>[];
  for (int i = 0; i < steps.length; i++) {
    if (steps[i].order != i + 1) {
      bad.add(
        '$where funding_steps[$i] — order ${steps[i].order} ≠ ${i + 1}(1부터 연속)',
      );
    }
    if (steps[i].expectedProceeds <= Decimal.zero) {
      bad.add(
        '$where funding_steps[$i] — expected_proceeds ${steps[i].expectedProceeds} ≤ 0(0원 단계 금지)',
      );
    }
  }
  return bad;
}

/// C-38 ⑤ — Σ `allocations.amount` + `residualKrwCash` == `depositAmount`(Decimal 정확히).
List<String> depositSumViolations(String where, DepositPlan p) {
  final Decimal sum = p.allocations.fold(
    p.residualKrwCash,
    (Decimal acc, SleeveAllocation a) => acc + a.amount,
  );
  return <String>[
    if (sum != p.depositAmount)
      '$where — 충당 합 + 잔여 $sum ≠ 입금액 ${p.depositAmount}',
  ];
}

/// C-38 ⑥ — 슬리브별 Σ(지정가 × 수량, 매수 초안) ≤ 그 슬리브 충당액 · 지정가 없는 매수 초안 = 위반.
List<String> depositBuyWithinAllocationViolations(String where, DepositPlan p) {
  final List<String> bad = <String>[];
  final Map<SleeveId, Decimal> buys = <SleeveId, Decimal>{};
  for (int i = 0; i < p.orderDrafts.length; i++) {
    final OrderDraft o = p.orderDrafts[i];
    if (o.side != OrderSide.buy) {
      continue;
    }
    if (o.limitPrice == null) {
      bad.add(
        '$where order_drafts[$i] — 매수 초안에 지정가가 없다(슬리브 ${o.sleeve.wire} 합을 볼 수 없다)',
      );
      continue;
    }
    buys[o.sleeve] =
        (buys[o.sleeve] ?? Decimal.zero) +
        o.limitPrice! * Decimal.fromInt(o.quantity);
  }
  for (final MapEntry<SleeveId, Decimal> e in buys.entries) {
    final Decimal allocated = p.allocations
        .where((SleeveAllocation a) => a.sleeve == e.key)
        .fold(
          Decimal.zero,
          (Decimal acc, SleeveAllocation a) => acc + a.amount,
        );
    if (e.value > allocated) {
      bad.add('$where — 슬리브 ${e.key.wire} 매수 초안 합 ${e.value} > 충당액 $allocated');
    }
  }
  return bad;
}

/// C-38 ⑦ — 슬리브 B 행(충당·초안)의 별칭 ∈ [pensionAliases] · 모든 별칭 ∈ [allAliases].
/// 계약 테스트는 픽스처 별칭 표(`fixtures/README.md`)를, 엔진 시험은 계좌 매핑을 넘긴다.
List<String> depositAccountViolations(
  String where,
  DepositPlan p, {
  required Set<String> pensionAliases,
  required Set<String> allAliases,
}) {
  final List<String> bad = <String>[];
  final List<(String, SleeveId, String?)> aliases =
      <(String, SleeveId, String?)>[
        for (final (int i, SleeveAllocation a) in p.allocations.indexed)
          ('allocations[$i]', a.sleeve, a.accountAlias),
        for (final (int i, OrderDraft o) in p.orderDrafts.indexed)
          ('order_drafts[$i]', o.sleeve, o.accountAlias),
      ];
  for (final (String at, SleeveId sleeve, String? alias) in aliases) {
    if (sleeve == SleeveId.b && !pensionAliases.contains(alias)) {
      bad.add('$where $at — 슬리브 B 가 연금 계좌가 아니다: $alias(SPEC v2.23 가드)');
    }
    if (alias != null && !allAliases.contains(alias)) {
      bad.add('$where $at — 계좌 별칭 표 밖 별칭: $alias');
    }
  }
  return bad;
}

/// C-38 ⑧ — 사유 칩 코드 ∈ `ContractCodes`.
List<String> depositReasonCodeViolations(String where, DepositPlan p) =>
    <String>[
      for (final (int i, OrderDraft o) in p.orderDrafts.indexed)
        for (final ReasonChip c in o.reasons)
          if (!ContractCodes.isRegistered(c.code))
            '$where order_drafts[$i] — 사유 코드 ${c.code} 가 ContractCodes 에 없다',
    ];

/// C-38 ②④⑤⑥⑦⑧ 를 한 계획에 한꺼번에(③ 은 여럿에 걸쳐 [depositPreviewNoticeViolations] 로 따로).
List<String> depositPlanViolations(
  String where,
  DepositPlan p, {
  required Set<String> pensionAliases,
  required Set<String> allAliases,
}) => <String>[
  ...depositPlanTextViolations(where, p),
  ...depositFundingViolations(where, p),
  ...depositSumViolations(where, p),
  ...depositBuyWithinAllocationViolations(where, p),
  ...depositAccountViolations(
    where,
    p,
    pensionAliases: pensionAliases,
    allAliases: allAliases,
  ),
  ...depositReasonCodeViolations(where, p),
];

/// C-41 ① — `preview` · `blockedText` 정확히 하나 · `blockedAction` ⇒ `blockedText` · 실린 글자는 비지 않는다.
List<String> rebalancePreviewResultViolations(
  String where,
  RebalancePreviewResult r,
) {
  final List<String> bad = <String>[];
  if ((r.preview != null) == (r.blockedText != null)) {
    bad.add('$where — preview·blocked_text 가 둘 다 있거나 둘 다 없다(화면이 갈래를 고르게 된다)');
  }
  if (r.blockedAction != null && r.blockedText == null) {
    bad.add('$where — blocked_text 없이 blocked_action 이 있다(문장 없는 버튼)');
  }
  for (final (String key, String? text) in <(String, String?)>[
    ('blocked_text', r.blockedText),
    ('blocked_action.label', r.blockedAction?.label),
  ]) {
    if (text != null && text.trim().isEmpty) {
      bad.add('$where — $key 가 빈 글자다');
    }
  }
  return bad;
}

/// C-41 ② — 초안이 스스로 갖출 것: `asOf` == [asOf](계약 테스트 = 봉투 · 엔진 = 계산에 쓴 as-of) ·
/// `plannedDateText`·`orderDraftsTitle` 비지 않음 · 고지 머리 · `ordersEmptyText != null ⇔ 빈 초안` ·
/// 지정가 짝 · `sideLabel`·`quantityText` 비지 않음 · 별칭 ∈ [allAliases] · 슬리브 B ∈ [pensionAliases].
/// 🔴 «초안이 있으면 before 에 밴드 밖 슬리브가 있다»는 픽스처 표본 정합이지 엔진 불변식이 아니다 — 넣지 않는다.
List<String> rebalancePreviewViolations(
  String where,
  RebalancePreview p, {
  required AsOf asOf,
  required Set<String> pensionAliases,
  required Set<String> allAliases,
}) {
  final List<String> bad = <String>[];
  if (p.asOf != asOf) {
    bad.add('$where — 초안 기준 시각(as_of)이 ${p.asOf.label} — 기대 ${asOf.label}');
  }
  for (final (String key, String text) in <(String, String)>[
    ('planned_date_text', p.plannedDateText),
    ('order_drafts_title', p.orderDraftsTitle),
  ]) {
    if (text.trim().isEmpty) {
      bad.add('$where — $key 가 빈 글자다');
    }
  }
  if (!p.previewNotice.startsWith(kPreviewNoticeHead)) {
    bad.add(
      '$where — preview_notice 가 «$kPreviewNoticeHead»로 시작하지 않는다: ${p.previewNotice}',
    );
  }
  bad.addAll(_draftListViolations(where, p.orderDrafts, p.ordersEmptyText));
  for (final (int i, OrderDraft d) in p.orderDrafts.indexed) {
    for (final (String key, String text) in <(String, String)>[
      ('side_label', d.sideLabel),
      ('quantity_text', d.quantityText),
    ]) {
      if (text.trim().isEmpty) {
        bad.add('$where order_drafts[$i] — $key 가 빈 글자다');
      }
    }
    if (!allAliases.contains(d.accountAlias)) {
      bad.add('$where order_drafts[$i] — 계좌 별칭 표 밖 별칭: ${d.accountAlias}');
    }
    if (d.sleeve == SleeveId.b && !pensionAliases.contains(d.accountAlias)) {
      bad.add(
        '$where order_drafts[$i] — 슬리브 B 가 연금 계좌가 아니다: ${d.accountAlias}',
      );
    }
  }
  return bad;
}

/// 빈 초안 문장 ⇔ 빈 목록 · 지정가 글자 ⇔ 지정가(입금·리밸런싱 공통 — 인출 초안은 대상 아님).
List<String> _draftListViolations(
  String where,
  List<OrderDraft> drafts,
  String? ordersEmptyText,
) {
  final List<String> bad = <String>[];
  if ((ordersEmptyText != null) != drafts.isEmpty) {
    bad.add(
      '$where — order_drafts ${drafts.length}건 · orders_empty_text '
      '${ordersEmptyText == null ? '없음' : '있음'}(non-null ⇔ 빈 목록)',
    );
  }
  for (int i = 0; i < drafts.length; i++) {
    final OrderDraft o = drafts[i];
    if ((o.limitPriceText == null) != (o.limitPrice == null)) {
      bad.add(
        '$where order_drafts[$i] — limit_price ${o.limitPrice} · limit_price_text '
        '${o.limitPriceText}(둘은 함께 비거나 함께 온다)',
      );
    }
  }
  return bad;
}

/// JSON 트리를 훑으며 `(키 경로, 키, 값)` 을 넘긴다 — 계약 테스트 `c00_support.walkJson` 과 같은 순서.
void _walkJson(
  Object? node,
  void Function(String path, String key, Object? value) visit, {
  String path = '',
}) {
  if (node is Map<String, Object?>) {
    for (final MapEntry<String, Object?> e in node.entries) {
      final String childPath = path.isEmpty ? e.key : '$path.${e.key}';
      visit(childPath, e.key, e.value);
      _walkJson(e.value, visit, path: childPath);
    }
  } else if (node is List<Object?>) {
    for (int i = 0; i < node.length; i++) {
      _walkJson(node[i], visit, path: '$path[$i]');
    }
  }
}
