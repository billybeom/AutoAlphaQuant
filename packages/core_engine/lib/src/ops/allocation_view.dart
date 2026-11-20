// 🆕 미결 192 — M9 `S04` 배분 화면 «첫 판 = 보기 전용»의 엔진 몫: 보기 VM 글자 · 뷰어 원천(`rm_config_view` S04 열)
// (설계 13 §8 R190 · 앱 01 §8 미결 192 · 발주자 결정 2026-11-19 미결 193 ⓐ · 194 ⓐ · 05 S04 머리 상자 ·
//  결정 한 장 `10_리뷰/2026-11-19_S04_결정한장_미결193_194.md`).
//
// 🔴 계약 0줄 — `AllocationEditorVm` 은 계약에 아직 없다(S04 계약 창 = 다음 번호 · 통합 담당). 이 파일의 꼴은 엔진 지역
//    꼴이고 창이 열리면 같은 칸이 계약 VM 으로 간다. 이름은 계약 잠정 이름(`AllocationEditorVm` · `AllocationProfileCard` ·
//    `AllocationReadOnlyRow`)과 겹치지 않게 `AllocationView…` 로 둔다(K80 «타입 이름 ≠ 엔진» · ambiguous_import).
// 🔴 글자 = 엔진 — 비중 · 밴드 · 한도 · 기간 숫자는 운영 설정 객체 · 안전 상수에서 읽어 짓는다. 이 파일이 직접 적는 수치는
//    정본 백테스트 헤드라인 한 줄([kP0sBacktestText] · SPEC 00 v2.31~v2.32 11.1331/−12.5952)과 정직 기대 한 줄
//    ([kP0sHonestExpectationLine] · 온보딩과 같은 글자)뿐이다. 헤드라인 단독 인용 금지(00 «정직 기대치») → 카드에 함께 싣는다.
// 🔴 첫 판에 없는 것 = 칸 자체가 없다: 프리셋(defensive · aggressive — 193 ⓐ · `kAllocationProfiles` 를 읽지 않는다) ·
//    custom 슬라이더 · 합 판정 · MDD 경고 · 미리보기 · 적용(194 ⓐ) · 기각 등록부 링크(HB-3 채택 전).
// 🔴 금 상한 = 두 행(슬리브 C 안 하드 캡 · 총자산 감시선) — 하나로 합치지 않는다(05 S04 표).
// 🔴 뷰어도 같은 값 — [allocationViewColumns] 가 `rm_config_view`(모드별 1행)에 실을 S04 열을 짓는다(01 §6-4 «열 이름 =
//    엔진 배치» · G-22 «읽기 모델 열 ⊇ VM 칸»). 규칙 5조 ①의 4칸(`row_version` · `lease_epoch` · `pushed_at` · `mode`)과
//    버전 스탬프 3필드는 push 층의 몫이다. 열을 VM 으로 읽는 뷰어 함수 = 계약 VM 이 생긴 뒤 `read_model_client`
//    (그 패키지는 core 를 읽지 못한다 · 축약 타입 금지 — G-22).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AsOf, AsOfSource, TradeDate;

import '../portfolio/month_end_plan.dart' show MonthEndConfig;
import '../portfolio/seasonal_a.dart' show kP0sAllocA;
import '../risk/breaker.dart' show BreakerConfig, BreakerLevel;
import '../risk/limits.dart' show LimitConfig;
import '../safety/discretion.dart' show kDiscretionMaxDelta, kDiscretionMaxUses;
import '../safety/rule_change.dart'
    show kRuleChangeCooling, kRuleChangeWindowMonth;
import '../safety/safety_text.dart' show breakerLabelOf;
import '../whatif/what_if_config.dart' show p0sMonthEndConfig;
import 'equity_snapshot.dart' show p0sBreakerConfig;
import 'holdings_overview.dart' show holdingsManwonText;
import 'ledger_views.dart' show kstDateText, kstMinuteText;
import 'p0s_ops_config.dart' show p0sLimitConfig;
import 'p0s_warn.dart' show P0sWarnConfig, p0sWarnConfig;
import 'settings_home.dart'
    show kSettingsAllocationLabel, kSettingsHomeStaleAfter;

/// 정본 P0S `balanced` 백테스트 헤드라인(SPEC 00 v2.31 실측 full 2000-01-03~2026-08-14 · v2.32 «헤드라인 불변» ·
/// 세금 전 점추정).
const String kP0sBacktestText =
    '백테스트 26.6년(2000~2026 · 세금 전) 연 11.13% · 최대 낙폭 −12.60%';

/// 정직 기대 줄(온보딩 `onboardingFinishVmOf` · `onboardingModeChoiceVmOf` 와 같은 글자 — 두 벌로 갈리지 않게 시험이 대조).
const String kP0sHonestExpectationLine =
    '규칙을 지켰을 때의 기대치는 전 계좌 세후 10.2% 안팎(최악 9.7%)입니다.';

/// S04 읽기 행 코드(🔴 화면 미참조 — 시험 · 열 대조 · 골든 Key 용).
abstract final class AllocationViewRowCodes {
  /// 슬리브 B 코어 밴드.
  static const String bandCoreB = 'BAND_CORE_B';

  /// 슬리브 C 안 리밸런싱 문턱.
  static const String bandSleeveC = 'BAND_SLEEVE_C';

  /// 새틀라이트 밴드(P0S = 해당 없음).
  static const String bandSatellite = 'BAND_SATELLITE';

  /// 낙폭 단계(서킷브레이커).
  static const String riskDrawdown = 'RISK_DRAWDOWN';

  /// 하루 손실 한도(SAF-403).
  static const String riskDailyLoss = 'RISK_DAILY_LOSS';

  /// 위험자산 비중 상한(SAF-301).
  static const String riskExposure = 'RISK_EXPOSURE';

  /// 방어 비중 하한(SAF-302 · 경고).
  static const String riskDefensiveFloor = 'RISK_DEFENSIVE_FLOOR';

  /// 주문 한도(SAF-401 · 402).
  static const String riskOrderCaps = 'RISK_ORDER_CAPS';

  /// 금 상한 — 슬리브 C 안 하드 캡(`sleeve_c.max_gold_pct_of_total`).
  static const String goldSleeveCCap = 'GOLD_SLEEVE_C_CAP';

  /// 금 총비중 감시선(`sleeve_c.gold_total_monitor_pct` · SAF-308).
  static const String goldTotalMonitor = 'GOLD_TOTAL_MONITOR';
}

/// 지금 배분 카드(정본 하나 — 193 ⓐ).
class AllocationViewCard {
  /// 만든다.
  const AllocationViewCard({
    required this.label,
    required this.weightsText,
    required this.backtestText,
    required this.honestNoteText,
  });

  /// 프로파일 글자(S01 카드 상태 줄과 같은 글자).
  final String label;

  /// 비중 한 줄.
  final String weightsText;

  /// 백테스트 근거 한 줄(M9 손익 금지의 유일한 예외 — 05 원칙 3).
  final String backtestText;

  /// 헤드라인과 함께 싣는 정직 기대 줄.
  final String honestNoteText;
}

/// 읽기 전용 행.
class AllocationViewRow {
  /// 만든다.
  const AllocationViewRow({
    required this.code,
    required this.label,
    required this.valueText,
    this.noteText,
  });

  /// 행 코드([AllocationViewRowCodes] · 화면 미참조).
  final String code;

  /// 이름.
  final String label;

  /// 값 글자.
  final String valueText;

  /// 덧붙임 한 줄(없으면 null).
  final String? noteText;
}

/// 읽기 전용 묶음(묶음은 엔진이 짓는다 — 화면은 받은 순서 그대로).
class AllocationViewSection {
  /// 만든다.
  const AllocationViewSection({required this.title, required this.rows});

  /// 묶음 머리.
  final String title;

  /// 행(받은 순서).
  final List<AllocationViewRow> rows;
}

/// S04 첫 판(보기 전용) VM — 폰 · 뷰어 같은 값.
class AllocationView {
  /// 만든다.
  const AllocationView({
    required this.current,
    required this.sections,
    required this.changePathLines,
    required this.asOf,
  });

  /// 지금 배분 카드.
  final AllocationViewCard current;

  /// 리밸런싱 밴드 · 리스크 한도 · 금 상한.
  final List<AllocationViewSection> sections;

  /// 바꾸는 길 안내(받은 순서).
  final List<String> changePathLines;

  /// 기준 시각.
  final AsOf asOf;
}

/// 비율 → `%` 앞 글자(소수 한 자리 반올림 · 뒤 0 없음 · 음수 = `−`).
String _pct(Decimal ratio) {
  final String s = (ratio * Decimal.fromInt(100)).round(scale: 1).toString();
  return s.startsWith('-') ? '−${s.substring(1)}' : s;
}

String _pctD(double ratio) => _pct(Decimal.parse(ratio.toString()));

/// S04 첫 판 VM 을 짓는다 — 값의 원천 = 운영 설정 객체(없으면 정본 P0S 판).
///
/// 🔴 잔여 C(1 − A − B) 가 음수면 [ArgumentError](배분 설정 오류 — 정규화하지 않는다).
AllocationView allocationViewOf({
  required DateTime nowUtc,
  MonthEndConfig? monthEnd,
  LimitConfig? limits,
  BreakerConfig? breaker,
  P0sWarnConfig? warn,
}) {
  final MonthEndConfig m = monthEnd ?? p0sMonthEndConfig();
  final LimitConfig l = limits ?? p0sLimitConfig();
  final BreakerConfig b = breaker ?? p0sBreakerConfig();
  final P0sWarnConfig w = warn ?? p0sWarnConfig();
  final DateTime t = nowUtc.toUtc();

  final Decimal a = kP0sAllocA;
  final Decimal c = Decimal.one - a - m.allocB;
  if (c < Decimal.zero) {
    throw ArgumentError.value(m.allocB, 'monthEnd.allocB', '잔여 C 가 음수다');
  }

  final String breakerText =
      <(BreakerLevel, double)>[
            (BreakerLevel.alert, b.alertDd),
            (BreakerLevel.reduced, b.reduceDd),
            (BreakerLevel.halted, b.haltDd),
            (BreakerLevel.stopped, b.stopDd),
          ]
          .map(
            ((BreakerLevel, double) e) =>
                '${breakerLabelOf(e.$1)} ${_pctD(e.$2)}%',
          )
          .join(' · ');

  final List<AllocationViewSection> sections = <AllocationViewSection>[
    AllocationViewSection(
      title: '리밸런싱 밴드',
      rows: <AllocationViewRow>[
        AllocationViewRow(
          code: AllocationViewRowCodes.bandCoreB,
          label: '슬리브 B 코어 밴드',
          valueText: '목표 ${_pct(m.allocB)}% ± ${_pct(m.coreBand)}%p',
          noteText:
              '월 1회 판정합니다. 밴드를 벗어나면 목표 비중으로 되돌립니다. '
              '처음 ${m.rampMonths}개월 적립 기간에는 판정하지 않습니다.',
        ),
        AllocationViewRow(
          code: AllocationViewRowCodes.bandSleeveC,
          label: '슬리브 C 안 리밸런싱 문턱',
          valueText: '종목 목표의 ±${_pct(m.cRelativeBand)}%',
          noteText: '채권 · 금이 각자 목표에서 이 폭 안에 있으면 사고팔지 않습니다.',
        ),
        const AllocationViewRow(
          code: AllocationViewRowCodes.bandSatellite,
          label: '새틀라이트 밴드',
          valueText: '해당 없음',
          noteText: '새틀라이트를 쓰지 않아(0%) 밴드를 판정하지 않습니다.',
        ),
      ],
    ),
    AllocationViewSection(
      title: '리스크 한도',
      rows: <AllocationViewRow>[
        AllocationViewRow(
          code: AllocationViewRowCodes.riskDrawdown,
          label: '낙폭 단계(서킷브레이커)',
          valueText: breakerText,
          noteText: '고점 대비 총자산 낙폭 기준입니다.',
        ),
        AllocationViewRow(
          code: AllocationViewRowCodes.riskDailyLoss,
          label: '하루 손실 한도',
          valueText: '−${_pctD(l.maxDailyLossPct)}%',
          noteText: '그날 손실이 이 선에 닿으면 그날 새 매수를 막습니다.',
        ),
        AllocationViewRow(
          code: AllocationViewRowCodes.riskExposure,
          label: '위험자산 비중 상한',
          valueText: '${_pctD(l.maxRiskExposure)}%',
          noteText: '매수 뒤 위험자산 비중이 이 선을 넘으면 그 매수를 막습니다.',
        ),
        AllocationViewRow(
          code: AllocationViewRowCodes.riskDefensiveFloor,
          label: '방어 비중 하한',
          valueText: '${_pctD(w.minDefensivePct)}%',
          noteText: '방어 자산(슬리브 C) 비중이 이 선 밑으로 내려가면 알림을 냅니다. 주문은 막지 않습니다.',
        ),
        AllocationViewRow(
          code: AllocationViewRowCodes.riskOrderCaps,
          label: '주문 한도',
          valueText:
              '하루 ${l.maxOrdersPerDay}건 · 한 건 ${holdingsManwonText(l.maxOrderValueKrw)}',
          noteText: '넘는 주문은 보내지 않습니다.',
        ),
      ],
    ),
    AllocationViewSection(
      title: '금 상한',
      rows: <AllocationViewRow>[
        AllocationViewRow(
          code: AllocationViewRowCodes.goldSleeveCCap,
          label: '금 상한 — 슬리브 C 안',
          valueText: '총자산의 ${_pct(m.maxGoldPctOfTotal)}%',
          noteText: '하드 캡입니다. 넘는 몫은 금 대신 원화 현금성으로 둡니다. 슬리브 B 의 금은 세지 않습니다.',
        ),
        AllocationViewRow(
          code: AllocationViewRowCodes.goldTotalMonitor,
          label: '금 총비중 감시선',
          valueText: '총자산의 ${_pctD(w.goldTotalMonitorPct)}%',
          noteText:
              '하드 캡이 아니라 감시선입니다. 슬리브 B 몫까지 합친 금 전체가 이 선을 넘으면 알림을 냅니다. '
              '주문은 막지 않습니다.',
        ),
      ],
    ),
  ];

  return AllocationView(
    current: AllocationViewCard(
      label: kSettingsAllocationLabel,
      weightsText:
          'A ${_pct(a)}% · B ${_pct(m.allocB)}% · C ${_pct(c)}%(나머지) · 새틀라이트 0%(꺼짐)',
      backtestText: kP0sBacktestText,
      honestNoteText: '백테스트 점추정이며 앞으로의 약속이 아닙니다. $kP0sHonestExpectationLine',
    ),
    sections: sections,
    changePathLines: <String>[
      '배분은 이 화면에서 바꾸지 않습니다. $kRuleChangeWindowMonth월 연간 리뷰에서 PC 백테스트 근거로 바꿉니다.',
      '바꾼 설정은 규칙 변경 승인을 거쳐야 쓰입니다'
          '(냉각 ${kRuleChangeCooling.inDays}일 · $kRuleChangeWindowMonth월 승인 창).',
      '급한 노출 조정은 배분이 아니라 재량 예산으로 합니다'
          '(한 번 ±${_pctD(kDiscretionMaxDelta)}%p · 12개월에 $kDiscretionMaxUses회).',
    ],
    asOf: AsOf(
      observedAt: t,
      tradeDate: TradeDate(kstDateText(t)),
      source: AsOfSource.localSqlite,
      staleAfter: kSettingsHomeStaleAfter,
      label: '설정 기준 ${kstMinuteText(t)}',
    ),
  );
}

/// `rm_config_view` S04 열 이름(엔진 배치 · 01 §6-4).
abstract final class RmConfigViewAllocationColumns {
  /// 카드 프로파일 글자(text).
  static const String label = 'allocation_label';

  /// 카드 비중 한 줄(text).
  static const String weightsText = 'allocation_weights_text';

  /// 카드 백테스트 한 줄(text).
  static const String backtestText = 'allocation_backtest_text';

  /// 카드 정직 기대 줄(text).
  static const String honestNoteText = 'allocation_honest_note_text';

  /// 읽기 묶음(jsonb — `[{title, rows: [{code, label, value_text, note_text}]}]` · 받은 순서).
  static const String sections = 'allocation_sections';

  /// 바꾸는 길 안내(jsonb — 글자 목록 · 받은 순서).
  static const String changePathLines = 'allocation_change_path_lines';

  /// 기준 시각(jsonb — 계약 `AsOf` 꼴).
  static const String asOf = 'allocation_as_of';

  /// 전부(이 차례).
  static const List<String> all = <String>[
    label,
    weightsText,
    backtestText,
    honestNoteText,
    sections,
    changePathLines,
    asOf,
  ];
}

/// S04 VM → `rm_config_view` S04 열(JSON 으로 옮길 수 있는 값만 · 🔴 손익 · 금액 원장 0).
Map<String, Object?> allocationViewColumns(AllocationView v) =>
    <String, Object?>{
      RmConfigViewAllocationColumns.label: v.current.label,
      RmConfigViewAllocationColumns.weightsText: v.current.weightsText,
      RmConfigViewAllocationColumns.backtestText: v.current.backtestText,
      RmConfigViewAllocationColumns.honestNoteText: v.current.honestNoteText,
      RmConfigViewAllocationColumns.sections: <Map<String, Object?>>[
        for (final AllocationViewSection s in v.sections)
          <String, Object?>{
            'title': s.title,
            'rows': <Map<String, Object?>>[
              for (final AllocationViewRow r in s.rows)
                <String, Object?>{
                  'code': r.code,
                  'label': r.label,
                  'value_text': r.valueText,
                  'note_text': r.noteText,
                },
            ],
          },
      ],
      RmConfigViewAllocationColumns.changePathLines: List<String>.of(
        v.changePathLines,
      ),
      RmConfigViewAllocationColumns.asOf: v.asOf.toJson(),
    };
