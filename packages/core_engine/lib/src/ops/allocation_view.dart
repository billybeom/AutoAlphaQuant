// 🆕 미결 192 — M9 `S04` 배분 화면 «첫 판 = 보기 전용»의 엔진 몫: 보기 VM 글자 · 뷰어 원천(`rm_config_view` S04 열)
// (설계 13 §8 R190 · 앱 01 §8 미결 192 · 발주자 결정 2026-11-19 미결 193 ⓐ · 194 ⓐ · 05 S04 머리 상자 ·
//  결정 한 장 `10_리뷰/2026-11-19_S04_결정한장_미결193_194.md`).
//
// ✅ E11q-s04a(설계 13 §8 R211 · 카드 `E11q-s04` · 01 §37) — 계약 v1.28 §37 VM(`AllocationEditorVm` · `AllocationProfileCard` ·
//    `AllocationReadOnlySection` · `AllocationReadOnlyRow`)을 직접 낸다. 행 코드 = 계약 `AllocationRowCodes` · 열 이름 = 계약
//    `AllocationReadModelColumns`(엔진 지역 꼴 6 퇴장 — 이름 겹침 회피(K80)가 사라졌다). 남는 엔진 이름 = [allocationViewOf] ·
//    [allocationEditorVmOfConfig] · [allocationViewColumns] · [kP0sBacktestText] · [kP0sHonestExpectationLine].
// 🔴 운영 경로는 [allocationEditorVmOfConfig](설정 필수 입구 · K206 — 설정을 못 읽었으면 부르지 않는다) · [allocationViewOf] 의
//    기본값 갈래(정본 P0S 판)는 시험 · 표본 대조용이다.
// 🔴 글자 = 엔진 — 비중 · 밴드 · 한도 · 기간 숫자는 운영 설정 객체 · 안전 상수에서 읽어 짓는다. 이 파일이 직접 적는 수치는
//    정본 백테스트 헤드라인 한 줄([kP0sBacktestText] · SPEC 00 v2.31~v2.32 11.1331/−12.5952)과 정직 기대 한 줄
//    ([kP0sHonestExpectationLine] · 온보딩과 같은 글자)뿐이다. 헤드라인 단독 인용 금지(00 «정직 기대치») → 카드에 함께 싣는다.
// 🔴 첫 판에 없는 것 = 칸 자체가 없다: 프리셋(defensive · aggressive — 193 ⓐ · `kAllocationProfiles` 를 읽지 않는다) ·
//    custom 슬라이더 · 합 판정 · MDD 경고 · 미리보기 · 적용(194 ⓐ) · 기각 등록부 링크(HB-3 채택 전).
// 🔴 금 상한 = 두 행(슬리브 C 안 하드 캡 · 총자산 감시선) — 하나로 합치지 않는다(05 S04 표).
// 🔴 뷰어도 같은 값 — [allocationViewColumns] 가 `rm_config_view`(모드별 1행)에 실을 S04 열을 짓는다(01 §6-4 «열 이름 =
//    엔진 배치» · G-22 «읽기 모델 열 ⊇ VM 칸»). 규칙 5조 ①의 4칸(`row_version` · `lease_epoch` · `pushed_at` · `mode`)과
//    버전 스탬프 3필드는 push 층의 몫이다. 열을 VM 으로 읽는 뷰어 함수 = `read_model_client`
//    `allocationEditorVmFromColumns`(그 패키지는 core 를 읽지 못한다 · 축약 타입 금지 — G-22).
// 🔴 새틀 «해당 없음» 고정 글자 = P0S 불변식(새틀라이트 0% · SPEC v2.31) — 새틀을 켜는 판이 생기면 이 행이 설정에서 읽어야 한다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AllocationEditorVm,
        AllocationProfileCard,
        AllocationReadModelColumns,
        AllocationReadOnlyRow,
        AllocationReadOnlySection,
        AllocationRowCodes,
        AsOf,
        AsOfSource,
        TradeDate;

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
import 'p0s_ops_config.dart' show P0sOpsConfig, p0sLimitConfig;
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

/// 비율 → `%` 앞 글자(소수 한 자리 반올림 · 뒤 0 없음 · 음수 = `−`).
String _pct(Decimal ratio) {
  final String s = (ratio * Decimal.fromInt(100)).round(scale: 1).toString();
  return s.startsWith('-') ? '−${s.substring(1)}' : s;
}

String _pctD(double ratio) => _pct(Decimal.parse(ratio.toString()));

/// 🆕 E11q-s04a — S04 첫 판 VM 을 **운영 설정 판에서만** 짓는다(설정 필수 입구 · K206 — 기본값 갈래 0).
///
/// 경고 문턱([P0sWarnConfig] · 방어 하한 · 금 감시선)은 설정 판에 칸이 없고 SPEC 상수뿐이라 [p0sWarnConfig] 를 쓴다 —
/// 기본값 대입이 아니다(판에 칸이 생기면 그 칸을 넘긴다).
/// 🔴 잔여 C(1 − A − B) 가 음수면 [ArgumentError].
AllocationEditorVm allocationEditorVmOfConfig(
  P0sOpsConfig config, {
  required DateTime nowUtc,
}) => allocationViewOf(
  nowUtc: nowUtc,
  monthEnd: config.monthEnd,
  limits: config.limits,
  breaker: config.breaker,
  warn: p0sWarnConfig(),
);

/// S04 첫 판 VM 을 짓는다 — 값의 원천 = 넘긴 설정(없는 칸 = 정본 P0S 판 · 🔴 운영 경로는 [allocationEditorVmOfConfig]).
///
/// 🔴 잔여 C(1 − A − B) 가 음수면 [ArgumentError](배분 설정 오류 — 정규화하지 않는다).
AllocationEditorVm allocationViewOf({
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

  final List<AllocationReadOnlySection> sections = <AllocationReadOnlySection>[
    AllocationReadOnlySection(
      title: '리밸런싱 밴드',
      rows: <AllocationReadOnlyRow>[
        AllocationReadOnlyRow(
          code: AllocationRowCodes.bandCoreB,
          label: '슬리브 B 코어 밴드',
          valueText: '목표 ${_pct(m.allocB)}% ± ${_pct(m.coreBand)}%p',
          noteText:
              '월 1회 판정합니다. 밴드를 벗어나면 목표 비중으로 되돌립니다. '
              '처음 ${m.rampMonths}개월 적립 기간에는 판정하지 않습니다.',
        ),
        AllocationReadOnlyRow(
          code: AllocationRowCodes.bandSleeveC,
          label: '슬리브 C 안 리밸런싱 문턱',
          valueText: '종목 목표의 ±${_pct(m.cRelativeBand)}%',
          noteText: '채권 · 금이 각자 목표에서 이 폭 안에 있으면 사고팔지 않습니다.',
        ),
        const AllocationReadOnlyRow(
          code: AllocationRowCodes.bandSatellite,
          label: '새틀라이트 밴드',
          valueText: '해당 없음',
          noteText: '새틀라이트를 쓰지 않아(0%) 밴드를 판정하지 않습니다.',
        ),
      ],
    ),
    AllocationReadOnlySection(
      title: '리스크 한도',
      rows: <AllocationReadOnlyRow>[
        AllocationReadOnlyRow(
          code: AllocationRowCodes.riskDrawdown,
          label: '낙폭 단계(서킷브레이커)',
          valueText: breakerText,
          noteText: '고점 대비 총자산 낙폭 기준입니다.',
        ),
        AllocationReadOnlyRow(
          code: AllocationRowCodes.riskDailyLoss,
          label: '하루 손실 한도',
          valueText: '−${_pctD(l.maxDailyLossPct)}%',
          noteText: '그날 손실이 이 선에 닿으면 그날 새 매수를 막습니다.',
        ),
        AllocationReadOnlyRow(
          code: AllocationRowCodes.riskExposure,
          label: '위험자산 비중 상한',
          valueText: '${_pctD(l.maxRiskExposure)}%',
          noteText: '매수 뒤 위험자산 비중이 이 선을 넘으면 그 매수를 막습니다.',
        ),
        AllocationReadOnlyRow(
          code: AllocationRowCodes.riskDefensiveFloor,
          label: '방어 비중 하한',
          valueText: '${_pctD(w.minDefensivePct)}%',
          noteText: '방어 자산(슬리브 C) 비중이 이 선 밑으로 내려가면 알림을 냅니다. 주문은 막지 않습니다.',
        ),
        AllocationReadOnlyRow(
          code: AllocationRowCodes.riskOrderCaps,
          label: '주문 한도',
          valueText:
              '하루 ${l.maxOrdersPerDay}건 · 한 건 ${holdingsManwonText(l.maxOrderValueKrw)}',
          noteText: '넘는 주문은 보내지 않습니다.',
        ),
      ],
    ),
    AllocationReadOnlySection(
      title: '금 상한',
      rows: <AllocationReadOnlyRow>[
        AllocationReadOnlyRow(
          code: AllocationRowCodes.goldSleeveCCap,
          label: '금 상한 — 슬리브 C 안',
          valueText: '총자산의 ${_pct(m.maxGoldPctOfTotal)}%',
          noteText: '하드 캡입니다. 넘는 몫은 금 대신 원화 현금성으로 둡니다. 슬리브 B 의 금은 세지 않습니다.',
        ),
        AllocationReadOnlyRow(
          code: AllocationRowCodes.goldTotalMonitor,
          label: '금 총비중 감시선',
          valueText: '총자산의 ${_pctD(w.goldTotalMonitorPct)}%',
          noteText:
              '하드 캡이 아니라 감시선입니다. 슬리브 B 몫까지 합친 금 전체가 이 선을 넘으면 알림을 냅니다. '
              '주문은 막지 않습니다.',
        ),
      ],
    ),
  ];

  return AllocationEditorVm(
    current: AllocationProfileCard(
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

/// S04 VM → `rm_config_view` S04 열(JSON 으로 옮길 수 있는 값만 · 🔴 손익 · 금액 원장 0).
Map<String, Object?> allocationViewColumns(AllocationEditorVm v) =>
    <String, Object?>{
      AllocationReadModelColumns.label: v.current.label,
      AllocationReadModelColumns.weightsText: v.current.weightsText,
      AllocationReadModelColumns.backtestText: v.current.backtestText,
      AllocationReadModelColumns.honestNoteText: v.current.honestNoteText,
      AllocationReadModelColumns.sections: <Map<String, Object?>>[
        for (final AllocationReadOnlySection s in v.sections)
          <String, Object?>{
            'title': s.title,
            'rows': <Map<String, Object?>>[
              for (final AllocationReadOnlyRow r in s.rows)
                <String, Object?>{
                  'code': r.code,
                  'label': r.label,
                  'value_text': r.valueText,
                  'note_text': r.noteText,
                },
            ],
          },
      ],
      AllocationReadModelColumns.changePathLines: List<String>.of(
        v.changePathLines,
      ),
      AllocationReadModelColumns.asOf: v.asOf.toJson(),
    };
