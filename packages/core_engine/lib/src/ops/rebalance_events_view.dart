// 🆕 E11q2 — 리밸런싱 회차 목록 · 회차 1건 VM(설계 13 §8 R173 · `S7-6a` · `S7-6b` · 01 §15-3 · §15-4 · 표본 `m7/m7_rebalance_*`).
//
// 🔴 원천 = 원장 `rebalance_event`(월말 잡 `MONTHLY_REGULAR` · 계절 A 잡 `SEASONAL`) — 행을 지어내지 않는다 · 원천 없는
//    종류(BAND · REGIME · DEPOSIT — 쓰는 잡 0)가 오면 실패한다.
// 🔴 전후 비중 = 월말 잡이 저장한 회계 비중(A · B · C · POT) → 미리보기와 같은 세 줄(A = POT 포함 · B = 코어 밴드 · C = 원화 현금 ·
//    채권 · 금 · 재분류 파킹) · 같은 문장 함수(`sleeveWeightOf`). 계절 A = 저장한 비중 없음 → 빈 줄(지어내지 않는다).
// 🔴 정렬 = 거래일 내림차순(같은 날 = 기록 시각 · id 내림차순) · 모의 배지 = LIVE 밖 · 머리글 = 첫 행에만(한 원장 = 한 모드).
// 🔴 asOf = 읽기 모델 관측 시각(지금 — 봉투와 행이 같은 값 · C-41 ④) · 기준일 = 원장의 마지막 KR 봉 날 · «자료 기준 ‹날›».
// 🔴 상세 링크 = 조립 앱에 본문이 등록됐을 때만(S01 원칙).
// 🆕 E11q-q4a — 주문 의도 id · 일지 링크(«이 회차의 주문 n건») = 일지와 같은 묶음(`journalEventIdOf` · 원천이 의도 id 를
//    넣는다) · 묶인 행 0 · `journalRebalance` 미등록 = null(버튼 부재). 실행 품질 = null(패널 부재) · 임계 대조 = 등록 임계
//    없음 → 0행.

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        EmptyKind,
        ListResult,
        RebalanceEvent,
        RebalanceKind,
        RunMode,
        SleeveId,
        SleeveWeight,
        ThresholdCompare,
        TradeDate,
        TriggerSnapshot;

import '../portfolio/seasonal_a.dart' show SeasonalAOutcome;
import '../portfolio/sleeve_weight_view.dart' show sleeveWeightOf;
import '../whatif/what_if_config.dart' show WhatIfConfig;
import 'journal_view.dart' show journalTimelineLinkOf;
import 'ops_home.dart' show kOpsHomeStaleAfter;

/// 회차 글자(표본에 있는 것은 글자 그대로).
abstract final class RebalanceEventTexts {
  /// 빈 목록(표본 `m7_rebalance_empty`).
  static const String empty = '아직 리밸런싱 회차가 없습니다';

  /// 모의 배지(표본 `m7_rebalance_sim`).
  static const String simBadge = '모의';

  /// 모의 묶음 머리글(표본 `m7_rebalance_sim`).
  static const String simSection = '모의투자 회차';

  /// 월간 정기(표본).
  static const String monthlyRegular = '월간 정기';

  /// 🆕 계절 A.
  static const String seasonal = '계절 A';

  /// 봉투 · 행 기준 라벨(C-41 ④ «자료 기준»).
  static String asOfLabel(String day) => '자료 기준 $day';
}

/// 원장 회차 한 줄(`rebalance_event` — 비중 = 저장한 회계 비중 · 계절 A = 빈 맵).
class RebalanceEventFact {
  /// 만든다.
  const RebalanceEventFact({
    required this.eventId,
    required this.tradeDate,
    required this.modeWire,
    required this.kindWire,
    required this.configHash,
    required this.trigger,
    required this.weightsBefore,
    required this.weightsAfter,
    required this.createdAt,
    this.executionDate,
    this.journalIntentIds = const <String>[],
  });

  /// 회차 id.
  final String eventId;

  /// 회차 거래일(월말 = 판정한 월말 · 계절 A = 판정일).
  final TradeDate tradeDate;

  /// 실행 모드 글자.
  final String modeWire;

  /// 종류 글자.
  final String kindWire;

  /// 설정 지문.
  final String configHash;

  /// 판정 근거 원문(`trigger_snapshot` JSON).
  final Map<String, Object?> trigger;

  /// 슬리브 → 비중(A · B · C · POT — 회계 · 월말 잡 `sleeveWeightsOf`).
  final Map<String, double> weightsBefore, weightsAfter;

  /// 기록 시각(ISO UTC — 같은 날 정렬).
  final String createdAt;

  /// 월말 회차의 집행일(다음 KR 세션 · 모르면 null).
  final String? executionDate;

  /// 🆕 E11q-q4a — 이 회차에 묶인 주문 의도(= 일지 행 · `journalEventIdOf` 묶음 · 원장 순).
  final List<String> journalIntentIds;
}

/// `S7-6a` 회차 목록 — [dataDate] = 원장의 마지막 KR 봉 날 · [hasBody] = 조립 앱 등록 화면.
ListResult<RebalanceEvent> rebalanceEventsVmOf(
  List<RebalanceEventFact> facts, {
  required DateTime nowUtc,
  required TradeDate dataDate,
  required bool Function(String route) hasBody,
  WhatIfConfig? config,
}) {
  final AsOf asOf = AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: dataDate,
    source: AsOfSource.localSqlite,
    staleAfter: kOpsHomeStaleAfter,
    label: RebalanceEventTexts.asOfLabel(dataDate.yyyyMmDd),
  );
  final List<RebalanceEventFact> sorted = facts.toList()
    ..sort((RebalanceEventFact x, RebalanceEventFact y) {
      final int d = y.tradeDate.yyyyMmDd.compareTo(x.tradeDate.yyyyMmDd);
      if (d != 0) return d;
      final int c = y.createdAt.compareTo(x.createdAt);
      return c != 0 ? c : y.eventId.compareTo(x.eventId);
    });
  final WhatIfConfig cfg = config ?? WhatIfConfig.defaults;
  final List<RebalanceEvent> rows = <RebalanceEvent>[
    for (int i = 0; i < sorted.length; i++)
      _event(sorted[i], first: i == 0, asOf: asOf, cfg: cfg, hasBody: hasBody),
  ];
  return ListResult<RebalanceEvent>(
    rows: rows,
    asOf: asOf,
    emptyKind: EmptyKind.noData,
    emptyLabel: rows.isEmpty ? RebalanceEventTexts.empty : null,
    hasMore: false,
  );
}

/// `S7-6b` 회차 1건 — 목록과 **같은 행**(C-41 ⑤) · 모르는 id = [StateError](스트림 에러 · 01 §15-3 잠정).
RebalanceEvent rebalanceEventVmOf(
  List<RebalanceEventFact> facts,
  String eventId, {
  required DateTime nowUtc,
  required TradeDate dataDate,
  required bool Function(String route) hasBody,
  WhatIfConfig? config,
}) {
  for (final RebalanceEvent e in rebalanceEventsVmOf(
    facts,
    nowUtc: nowUtc,
    dataDate: dataDate,
    hasBody: hasBody,
    config: config,
  ).rows) {
    if (e.eventId == eventId) return e;
  }
  throw StateError('리밸런싱 회차가 없다: $eventId');
}

RebalanceEvent _event(
  RebalanceEventFact f, {
  required bool first,
  required AsOf asOf,
  required WhatIfConfig cfg,
  required bool Function(String route) hasBody,
}) {
  final RunMode mode = RunMode.values.firstWhere(
    (RunMode m) => m.wire == f.modeWire,
    orElse: () => throw StateError('모르는 실행 모드: ${f.modeWire}'),
  );
  final RebalanceKind kind = RebalanceKind.values.firstWhere(
    (RebalanceKind k) => k.wire == f.kindWire,
    orElse: () => throw StateError('모르는 회차 종류: ${f.kindWire}'),
  );
  final bool sim = mode != RunMode.live;
  final (String label, String summary) = switch (kind) {
    RebalanceKind.monthlyRegular => (
      RebalanceEventTexts.monthlyRegular,
      _monthlySummary(f, sim),
    ),
    RebalanceKind.seasonal => (
      RebalanceEventTexts.seasonal,
      _seasonalSummary(f.trigger),
    ),
    RebalanceKind.band ||
    RebalanceKind.regime ||
    RebalanceKind.deposit => throw StateError('원천 없는 회차 종류: ${kind.wire}'),
  };
  return RebalanceEvent(
    eventId: f.eventId,
    mode: mode,
    tradeDate: f.tradeDate,
    kind: kind,
    kindLabel: label,
    before: _weights(f.weightsBefore, cfg),
    after: _weights(f.weightsAfter, cfg),
    trigger: TriggerSnapshot(
      configHash: f.configHash,
      rawValues: <String, String>{
        for (final MapEntry<String, Object?> e in f.trigger.entries)
          if (e.value != null)
            e.key: e.value is String ? e.value! as String : jsonEncode(e.value),
      },
      summary: summary,
    ),
    orderIntentIds: List<String>.unmodifiable(f.journalIntentIds),
    asOf: asOf,
    thresholds: const <ThresholdCompare>[],
    modeLabel: sim ? RebalanceEventTexts.simBadge : null,
    sectionLabel: sim && first ? RebalanceEventTexts.simSection : null,
    journalTimelineLink: journalTimelineLinkOf(
      f.eventId,
      f.journalIntentIds.length,
      hasBody: hasBody,
    ),
    detailDeepLink: hasBody(AppRoutes.rebalanceEvent)
        ? '${AppRoutes.rebalanceEvent.split('/:').first}/${f.eventId}'
        : null,
  );
}

/// «월간 정기 판정(2026-07-31 종가)으로 2026-08-03 모의투자 회차를 계획했습니다 — 주문 대상 2건.»
String _monthlySummary(RebalanceEventFact f, bool sim) {
  final Object? n = f.trigger['targets'];
  final String day = f.tradeDate.yyyyMmDd;
  final String exec = f.executionDate == null ? '' : '${f.executionDate} ';
  final String held = f.trigger['sleeve_b_held'] == true
      ? ' 시장 국면을 판정할 수 없어 슬리브 B 추세 조정은 보류했습니다.'
      : '';
  return '월간 정기 판정($day 종가)으로 $exec${sim ? '모의투자 ' : ''}회차를 계획했습니다'
      '${n is int ? ' — 주문 대상 $n건' : ''}.$held';
}

/// «계절 A 진입 판정 — 매수 120주.» · «계절 A 진입 연기 — 주문 없음.»
String _seasonalSummary(Map<String, Object?> t) {
  final Object? name = t['outcome'];
  final SeasonalAOutcome o = SeasonalAOutcome.values.firstWhere(
    (SeasonalAOutcome x) => x.name == name,
    orElse: () => throw StateError('모르는 계절 A 판정: $name'),
  );
  final String what = switch (o) {
    SeasonalAOutcome.nothing => '할 일 없음',
    SeasonalAOutcome.defer => '진입 연기',
    SeasonalAOutcome.enter => '진입 판정',
    SeasonalAOutcome.lateEnter => '연기 뒤 진입 판정',
    SeasonalAOutcome.exit => '청산 판정',
    SeasonalAOutcome.breakerSkip => '브레이커로 건너뜀',
  };
  final Object? side = t['side'];
  final Object? shares = t['target_shares'];
  final String order =
      (side == 'BUY' || side == 'SELL') && shares is int && shares > 0
      ? '${side == 'BUY' ? '매수' : '매도'} $shares주'
      : '주문 없음';
  final String pot = t['liquidate_pot'] == true ? ' · POT 청산' : '';
  return '계절 A $what — $order$pot.';
}

/// 저장한 회계 비중 → 미리보기와 같은 세 줄(A = POT 포함 · 밴드 = B 코어 밴드) · 빈 맵 = 빈 줄.
List<SleeveWeight> _weights(Map<String, double> w, WhatIfConfig cfg) {
  if (w.isEmpty) return const <SleeveWeight>[];
  Decimal d(String k) {
    final double? v = w[k];
    if (v == null || v.isNaN || !v.isFinite) {
      throw StateError('저장한 비중이 없다: $k');
    }
    return Decimal.parse(v.toString());
  }

  Decimal t(SleeveId x) => cfg.targetWeights[x] ?? Decimal.zero;
  return <SleeveWeight>[
    sleeveWeightOf(
      SleeveId.a,
      d('A') + d('POT'),
      Decimal.one,
      t(SleeveId.a),
      null,
    ),
    sleeveWeightOf(
      SleeveId.b,
      d('B'),
      Decimal.one,
      t(SleeveId.b),
      cfg.monthEnd.coreBand,
    ),
    sleeveWeightOf(SleeveId.c, d('C'), Decimal.one, t(SleeveId.c), null),
  ];
}
