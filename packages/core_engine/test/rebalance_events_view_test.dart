// E11q2 — M7 S7-6a 회차 목록 · S7-6b 회차 1건 VM(설계 13 §8 R173).
//
// 🔴 원천 = 원장 `rebalance_event` 그대로(지어낸 행 0 · 원천 없는 종류 = 실패) · 전후 비중 = 미리보기와 같은 세 줄 ·
//    C-41 ④ 불변식(봉투 · 행 asOf 같음 · «자료 기준» · `%` 라벨 · 회계 기준 · 모의 배지 ⇔ LIVE 밖 · 머리글 = 첫 행).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const TradeDate _data = TradeDate('2026-08-31');
final DateTime _now = DateTime.utc(2026, 8, 31, 9);

const Map<String, double> _before = <String, double>{
  'A': 0.16,
  'B': 0.478,
  'C': 0.322,
  'POT': 0.04,
};
const Map<String, double> _after = <String, double>{
  'A': 0.16,
  'B': 0.42,
  'C': 0.38,
  'POT': 0.04,
};

RebalanceEventFact _monthly(
  String day, {
  String mode = 'SIM_INTERNAL',
  String created = '2026-08-01T23:00:00Z',
  Map<String, Object?>? trigger,
  String? exec = '2026-08-03',
}) => RebalanceEventFact(
  eventId: 'REB-MONTHLY-$day',
  tradeDate: TradeDate(day),
  modeWire: mode,
  kindWire: 'MONTHLY_REGULAR',
  configHash: 'cfg_t',
  trigger:
      trigger ??
      <String, Object?>{
        'regime_state': 'BULL',
        'month_index': 2,
        'sleeve_b_held': false,
        'targets': 2,
      },
  weightsBefore: _before,
  weightsAfter: _after,
  createdAt: created,
  executionDate: exec,
);

RebalanceEventFact _seasonal(
  String day,
  Map<String, Object?> trigger, {
  String created = '2026-08-01T00:00:00Z',
}) => RebalanceEventFact(
  eventId: 'REB-SEAS-$day',
  tradeDate: TradeDate(day),
  modeWire: 'SIM_INTERNAL',
  kindWire: 'SEASONAL',
  configHash: 'cfg_t',
  trigger: trigger,
  weightsBefore: const <String, double>{},
  weightsAfter: const <String, double>{},
  createdAt: created,
);

ListResult<RebalanceEvent> _list(
  List<RebalanceEventFact> f, {
  bool Function(String)? hasBody,
}) => rebalanceEventsVmOf(
  f,
  nowUtc: _now,
  dataDate: _data,
  hasBody: hasBody ?? (String r) => r == AppRoutes.rebalanceEvent,
);

void main() {
  test('빈 목록 = 표본 m7_rebalance_empty 문장 · 봉투 «자료 기준» · 더 없음', () {
    final ListResult<RebalanceEvent> r = _list(const <RebalanceEventFact>[]);
    expect(r.rows, isEmpty);
    expect(r.emptyLabel, '아직 리밸런싱 회차가 없습니다');
    expect(r.emptyKind, EmptyKind.noData);
    expect(r.hasMore, isFalse);
    expect(r.asOf.label, '자료 기준 2026-08-31');
    expect(r.asOf.tradeDate, _data);
    expect(r.asOf.observedAt, _now);
  });

  test(
    '월말 회차(모의) — 배지 · 머리글 · 세 줄(A = POT 포함 · B 코어 밴드) · 요약 · 상세 링크 · C-41 ④',
    () {
      final ListResult<RebalanceEvent> r = _list(<RebalanceEventFact>[
        _monthly('2026-07-31'),
        _monthly('2026-06-30', created: '2026-07-01T23:00:00Z', exec: null),
      ]);
      expect(r.emptyLabel, isNull);
      final RebalanceEvent e = r.rows.first;
      expect(e.eventId, 'REB-MONTHLY-2026-07-31');
      expect(e.kind, RebalanceKind.monthlyRegular);
      expect(e.kindLabel, '월간 정기');
      expect(e.mode, RunMode.simInternal);
      expect(e.modeLabel, '모의');
      expect(e.sectionLabel, '모의투자 회차');
      expect(r.rows[1].sectionLabel, isNull, reason: '머리글 = 묶음의 첫 행에만');
      expect(r.rows[1].modeLabel, '모의');
      expect(e.before.map((SleeveWeight w) => w.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.b,
        SleeveId.c,
      ]);
      expect(e.before[0].label, 'A 20.0% (목표 20.0%, 편차 0.0%p)');
      expect(
        e.before[1].label,
        'B 47.8% (목표 42.0%, 편차 +5.8%p, 밴드 상단 2.8%p 초과)',
      );
      expect(e.after[1].label, 'B 42.0% (목표 42.0%, 편차 0.0%p, 밴드 여유 3.0%p)');
      expect(e.before[2].label, 'C 32.2% (목표 38.0%, 편차 −5.8%p)');
      for (final RebalanceEvent x in r.rows) {
        expect(x.asOf, r.asOf, reason: '행 asOf = 봉투(C-41 ④)');
        for (final SleeveWeight w in <SleeveWeight>[...x.before, ...x.after]) {
          expect(w.label, contains('%'));
          expect(w.basis, AllocationBasis.accounting);
        }
        expect(x.thresholds, isEmpty);
        expect(x.trigger.thresholdRegistered, isNull);
      }
      expect(
        e.trigger.summary,
        '월간 정기 판정(2026-07-31 종가)으로 2026-08-03 모의투자 회차를 계획했습니다 — 주문 대상 2건.',
      );
      expect(
        r.rows[1].trigger.summary,
        '월간 정기 판정(2026-06-30 종가)으로 모의투자 회차를 계획했습니다 — 주문 대상 2건.',
        reason: '집행일을 모르면 말하지 않는다',
      );
      expect(e.trigger.configHash, 'cfg_t');
      expect(e.trigger.rawValues['regime_state'], 'BULL');
      expect(e.trigger.rawValues['month_index'], '2');
      expect(e.detailDeepLink, 'aaq://rebalance/event/REB-MONTHLY-2026-07-31');
      expect(e.orderIntentIds, isEmpty, reason: '회차 ↔ 주문 묶음 = q4');
      expect(e.journalTimelineLink, isNull);
      expect(e.quality, isNull);
    },
  );

  test('국면 판정 불가 월말 = B 보류 문장 · LIVE = 배지 · 머리글 0 · 미등록 = 상세 링크 0', () {
    final RebalanceEvent e = _list(<RebalanceEventFact>[
      _monthly(
        '2026-07-31',
        mode: 'LIVE',
        trigger: <String, Object?>{'sleeve_b_held': true, 'targets': 0},
      ),
    ], hasBody: (String _) => false).rows.single;
    expect(e.modeLabel, isNull);
    expect(e.sectionLabel, isNull);
    expect(e.detailDeepLink, isNull);
    expect(
      e.trigger.summary,
      '월간 정기 판정(2026-07-31 종가)으로 2026-08-03 회차를 계획했습니다 — 주문 대상 0건. '
      '시장 국면을 판정할 수 없어 슬리브 B 추세 조정은 보류했습니다.',
    );
  });

  test('정렬 = 거래일 내림차순 · 같은 날 = 기록 시각 내림차순', () {
    final List<String> ids = _list(<RebalanceEventFact>[
      _monthly('2026-06-30', created: '2026-07-01T23:00:00Z'),
      _seasonal('2026-07-31', <String, Object?>{'outcome': 'nothing'}),
      _monthly('2026-07-31', created: '2026-08-01T23:00:00Z'),
    ]).rows.map((RebalanceEvent e) => e.eventId).toList();
    expect(ids, <String>[
      'REB-MONTHLY-2026-07-31',
      'REB-SEAS-2026-07-31',
      'REB-MONTHLY-2026-06-30',
    ]);
  });

  test('계절 A — 판정별 요약 · 저장 비중 없음 = 빈 줄(지어내지 않는다)', () {
    String sum(Map<String, Object?> t) =>
        _list(<RebalanceEventFact>[_seasonal('2026-10-01', t)])
            .rows
            .single
            .trigger
            .summary;
    expect(
      sum(<String, Object?>{
        'outcome': 'enter',
        'side': 'BUY',
        'target_shares': 120,
      }),
      '계절 A 진입 판정 — 매수 120주.',
    );
    expect(
      sum(<String, Object?>{
        'outcome': 'lateEnter',
        'side': 'BUY',
        'target_shares': 30,
      }),
      '계절 A 연기 뒤 진입 판정 — 매수 30주.',
    );
    expect(
      sum(<String, Object?>{
        'outcome': 'exit',
        'side': 'SELL',
        'target_shares': 120,
        'liquidate_pot': true,
      }),
      '계절 A 청산 판정 — 매도 120주 · POT 청산.',
    );
    expect(
      sum(<String, Object?>{'outcome': 'defer', 'target_shares': 0}),
      '계절 A 진입 연기 — 주문 없음.',
    );
    expect(
      sum(<String, Object?>{'outcome': 'breakerSkip'}),
      '계절 A 브레이커로 건너뜀 — 주문 없음.',
    );
    final RebalanceEvent e = _list(<RebalanceEventFact>[
      _seasonal('2026-10-01', <String, Object?>{
        'outcome': 'enter',
        'side': 'BUY',
        'target_shares': 120,
        'execution_days': <String>['2026-10-01', '2026-10-02'],
      }),
    ]).rows.single;
    expect(e.kind, RebalanceKind.seasonal);
    expect(e.kindLabel, '계절 A');
    expect(e.before, isEmpty);
    expect(e.after, isEmpty);
    expect(
      e.trigger.rawValues['execution_days'],
      '["2026-10-01","2026-10-02"]',
    );
  });

  test('회차 1건 = 목록과 같은 행 · 모르는 id · 원천 없는 종류 · 모르는 판정 = 실패', () {
    final List<RebalanceEventFact> f = <RebalanceEventFact>[
      _monthly('2026-07-31'),
      _monthly('2026-06-30', created: '2026-07-01T23:00:00Z'),
    ];
    RebalanceEvent one(String id, List<RebalanceEventFact> f) =>
        rebalanceEventVmOf(
          f,
          id,
          nowUtc: _now,
          dataDate: _data,
          hasBody: (String r) => r == AppRoutes.rebalanceEvent,
        );
    expect(one('REB-MONTHLY-2026-06-30', f), _list(f).rows[1]);
    expect(() => one('REB-MONTHLY-2099-01-31', f), throwsStateError);
    final RebalanceEventFact band = RebalanceEventFact(
      eventId: 'x',
      tradeDate: _data,
      modeWire: 'SIM_INTERNAL',
      kindWire: 'BAND',
      configHash: 'cfg_t',
      trigger: const <String, Object?>{},
      weightsBefore: _before,
      weightsAfter: _after,
      createdAt: '2026-08-31T00:00:00Z',
    );
    expect(() => _list(<RebalanceEventFact>[band]), throwsStateError);
    expect(
      () => _list(<RebalanceEventFact>[
        _seasonal('2026-10-01', <String, Object?>{'outcome': 'maybe'}),
      ]),
      throwsStateError,
    );
    expect(
      () => _list(<RebalanceEventFact>[
        RebalanceEventFact(
          eventId: 'y',
          tradeDate: _data,
          modeWire: 'SIM_INTERNAL',
          kindWire: 'MONTHLY_REGULAR',
          configHash: 'cfg_t',
          trigger: const <String, Object?>{},
          weightsBefore: const <String, double>{'A': 0.5, 'B': 0.5},
          weightsAfter: _after,
          createdAt: '2026-08-31T00:00:00Z',
        ),
      ]),
      throwsStateError,
      reason: '저장 비중이 빠지면 0 을 채우지 않는다',
    );
  });
}
