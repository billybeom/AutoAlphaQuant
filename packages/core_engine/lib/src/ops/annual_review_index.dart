// M9 S12 12월 연간 리뷰 목차 VM · 12월 창 판정(E11p4l · 설계 13 §8 R168 · 01 §33 K118 · K131 · K139 · 01 §8 미결 202).
//
// 🔴 창 판정 = 신뢰 시각(기기 시계 아님 · 서약 편집 창과 같은 원천 — `pledgeVmOf` · R67 Z2)으로 본 한국 12월 →
//    OPEN · 신뢰 시각 모름 = «확인하지 못했습니다»(OPEN 을 지어내지 않는다 — 서약 링크 · S01 카드 부재).
// 🔴 연도 = 12월 = 그해 · 1~11월 = 지난해(마지막으로 끝난 12월 창의 해) · 그 해가 운영 첫 해보다 앞이면 «첫 해»(올해 · 비교 대상 없음).
// 🔴 목차 행 = M7 화면 링크만 · 조립 앱에 본문이 등록된 화면만(S01 원칙 — 없는 화면으로 보내지 않는다) · 받은 차례 그대로 ·
//    0 이면 행 0(K139) · 기각 등록부 행 = HB-3 채택 전 0. 서약 링크 = OPEN 이고 서약 화면이 등록됐을 때만.
// 🔴 세후 · 수익률 · 평가액 · 연도 원값 · 창 원값 칸 0(타입에 없다 · 결정 8).
// 🔴 글자 = 표본(`m9/annual_review_index_*` · `m9/settings_home`) 그대로 · «확인하지 못했습니다» 만 새 글자(표본 4종 밖 상태).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AnnualReviewIndexVm,
        AppRoutes,
        AsOf,
        AsOfSource,
        LinkAction,
        TradeDate;

import '../safety/rule_change.dart' show kRuleChangeWindowMonth;
import 'ledger_views.dart' show kstDateText;

/// S12 기준 유효 시간(표본 26시간).
const Duration kAnnualReviewStaleAfter = Duration(hours: 26);

/// 12월 창 상태.
enum AnnualReviewWindow {
  /// 신뢰 시각 모름.
  unknown,

  /// 12월(규칙 변경 창).
  open,

  /// 창 밖(1~11월).
  closed,
}

/// S12 글자(엔진).
abstract final class AnnualReviewTexts {
  /// 창 열림.
  static const String open = '연간 점검 창이 열려 있습니다';

  /// 창 닫힘.
  static const String closed = '연간 점검 창이 닫혀 있습니다. 자료는 읽기만 됩니다.';

  /// 첫 해.
  static const String firstYear = '첫 해라 비교 대상이 없습니다';

  /// 신뢰 시각 모름.
  static const String unknown =
      '연간 점검 창을 확인하지 못했습니다 — 믿을 수 있는 시각을 아직 받지 못했습니다.';

  /// 서약 링크.
  static const String pledge = '본인 서약문 편집하기';

  /// S01 카드.
  static const String homeCard = '12월 연간 리뷰가 열렸습니다';

  /// 연도 줄.
  static String yearLabel(int year) => '$year년 연간 리뷰';
}

/// 목차 행(차례 = 표본) — M7 화면.
const List<LinkAction> kAnnualReviewEntries = <LinkAction>[
  LinkAction(label: '한 해의 결과 — 연간 리뷰', deepLink: AppRoutes.reportAnnual),
  LinkAction(label: '이행 갭', deepLink: AppRoutes.ledgerExecutionGap),
  LinkAction(label: '리밸런싱 회차', deepLink: AppRoutes.rebalanceHistory),
  LinkAction(label: '하락 구간 맥락', deepLink: AppRoutes.performanceDrawdown),
];

/// 첫 해 목차(표본 `_first_year` — 비교가 필요한 두 행은 없다).
const Set<String> _firstYearRoutes = <String>{
  AppRoutes.reportAnnual,
  AppRoutes.ledgerExecutionGap,
};

int _kstYear(DateTime utc) => int.parse(kstDateText(utc).substring(0, 4));
int _kstMonth(DateTime utc) => int.parse(kstDateText(utc).substring(5, 7));

/// 🔴 12월 창 — 신뢰 시각으로만(모름 = unknown).
AnnualReviewWindow annualReviewWindowOf(DateTime? trustedNowUtc) {
  final DateTime? t = trustedNowUtc;
  if (t == null) return AnnualReviewWindow.unknown;
  return _kstMonth(t) == kRuleChangeWindowMonth
      ? AnnualReviewWindow.open
      : AnnualReviewWindow.closed;
}

/// S01 연간 카드 — OPEN 이고 S12 본문이 등록됐을 때만(표본 `m9/settings_home` 글자).
LinkAction? annualReviewHomeLinkOf({
  required DateTime? trustedNowUtc,
  required bool Function(String route) hasBody,
}) =>
    annualReviewWindowOf(trustedNowUtc) == AnnualReviewWindow.open &&
        hasBody(AppRoutes.settingsAnnualReview)
    ? const LinkAction(
        label: AnnualReviewTexts.homeCard,
        deepLink: AppRoutes.settingsAnnualReview,
      )
    : null;

/// S12 사실.
class AnnualReviewIndexFacts {
  /// 만든다.
  const AnnualReviewIndexFacts({
    required this.trustedNowUtc,
    required this.firstOperatingYear,
    required this.hasBody,
    required this.nowUtc,
  });

  /// 신뢰 시각(모르면 null — E11k 전).
  final DateTime? trustedNowUtc;

  /// 운영을 시작한 해(한국 · 모르면 null = 첫 해로 본다).
  final int? firstOperatingYear;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 기기 시각(기준 줄 · 신뢰 시각 모를 때 연도 줄).
  final DateTime nowUtc;
}

/// 🔴 S12 목차 VM.
AnnualReviewIndexVm annualReviewIndexVmOf(AnnualReviewIndexFacts f) {
  final AnnualReviewWindow w = annualReviewWindowOf(f.trustedNowUtc);
  // 연도 = 12월 → 그해 · 그 밖 → 지난해(신뢰 시각 모름 = 기기 시각으로 연도 줄만 · 창은 «모름»).
  final DateTime basis = f.trustedNowUtc ?? f.nowUtc;
  final int shown = _kstMonth(basis) == kRuleChangeWindowMonth
      ? _kstYear(basis)
      : _kstYear(basis) - 1;
  final int? first = f.firstOperatingYear;
  final bool firstYear =
      w != AnnualReviewWindow.open && (first == null || shown < first);
  final int year = firstYear ? _kstYear(basis) : shown;
  final String state = switch (w) {
    AnnualReviewWindow.open => AnnualReviewTexts.open,
    AnnualReviewWindow.unknown => AnnualReviewTexts.unknown,
    AnnualReviewWindow.closed =>
      firstYear ? AnnualReviewTexts.firstYear : AnnualReviewTexts.closed,
  };
  final String day = kstDateText(f.nowUtc);
  return AnnualReviewIndexVm(
    yearLabel: AnnualReviewTexts.yearLabel(year),
    windowStateLabel: state,
    entries: <LinkAction>[
      for (final LinkAction e in kAnnualReviewEntries)
        if (f.hasBody(e.deepLink) &&
            (!firstYear || _firstYearRoutes.contains(e.deepLink)))
          e,
    ],
    pledgeLink: w == AnnualReviewWindow.open && f.hasBody(AppRoutes.m5Pledge)
        ? const LinkAction(
            label: AnnualReviewTexts.pledge,
            deepLink: AppRoutes.m5Pledge,
          )
        : null,
    asOf: AsOf(
      observedAt: f.nowUtc.toUtc(),
      tradeDate: TradeDate(day),
      source: AsOfSource.localSqlite,
      staleAfter: kAnnualReviewStaleAfter,
      label: '연간 점검 기준 $day',
    ),
  );
}
