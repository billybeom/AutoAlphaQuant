// E11q-q4a — M6 매매일지 «읽기» VM(J-1 · 필터 · 배지 · J-2 · J-3R · 회차 범위 · 기간 프리셋 · 슬리브).
//
// 🔴 표본 대조 = 계약 표본 값 그대로(기간 프리셋 · 슬리브 · 필터 · 배지 · J-2 단계 넷 · 행 글자 · 가림 · J-3R ·
//    S7-6b 링크) · 표본 개정 0. 표본이 합성 시각 · id 로 쓴 칸은 같은 사실을 넣어 맞춘다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

final DateTime _now = DateTime.utc(2026, 8, 31, 9);
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

final WhatIfConfig _cfg = WhatIfConfig(
  planTtl: const Duration(hours: 24),
  pensionAnnualLimit: Decimal.fromInt(18000000),
  taxCreditBand: Decimal.fromInt(9000000),
  depositMin: Decimal.one,
  depositMax: Decimal.fromInt(1000000000),
  symbolLabels: const <String, String>{
    '069500': '069500 KODEX 200',
    '132030': '132030 KODEX 골드선물',
    '379810': '379810 KODEX 미국S&P500',
    '0085P0': '0085P0 KODEX 국고채30년',
    '411060': '411060 ACE 미국30년국채',
    '357870': '357870 파킹 ETF',
  },
);

Map<String, Object?> _fx(String path) =>
    jsonDecode(File('../domain_contracts/fixtures/$path').readAsStringSync())
        as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_fx(path)['rows']! as List<Object?>).cast<Map<String, Object?>>();

Map<String, Object?> _row(String path, String entryId) =>
    _rows(path)
        .firstWhere((Map<String, Object?> r) => r['entry_id'] == entryId);

DateTime _t(String iso) => DateTime.parse(iso).toUtc();

JournalFillFact _fill(
  String id, {
  required int qty,
  required String price,
  required String at,
  String commission = '0',
  String tax = '0',
  String origin = 'BROKER',
  String kind = 'ORIGINAL',
  String cost = 'BROKER',
  String? order,
}) => JournalFillFact(
  executionId: id,
  brokerOrderNo: order,
  executedAt: _t(at),
  quantity: qty,
  priceText: price,
  commissionText: commission,
  taxText: tax,
  originWire: origin,
  kindWire: kind,
  costSourceWire: cost,
);

JournalIntentFact _intent(
  String id, {
  required String decision,
  String status = 'FILLED',
  String strategy = P0sStrategyIds.sleeveB,
  String symbol = '379810',
  String side = 'BUY',
  int qty = 80,
  String trade = '2026-08-04',
  String created = '2026-08-03T23:41:00Z',
  String? updated,
  String mode = 'LIVE',
  String? limit = '17420',
  String? error,
  String account = 'pension',
  List<JournalOrderFact> orders = const <JournalOrderFact>[],
  List<JournalFillFact> fills = const <JournalFillFact>[],
}) => JournalIntentFact(
  intentId: id,
  decisionId: decision,
  createdAt: _t(created),
  updatedAt: _t(updated ?? created),
  tradeDate: TradeDate(trade),
  modeWire: mode,
  account: account,
  strategyId: strategy,
  symbol: symbol,
  sideWire: side,
  quantity: qty,
  statusWire: status,
  configHash: 'cfg_fake_0000000000000000',
  limitPriceText: limit,
  errorMessage: error,
  orders: orders,
  fills: fills,
);

JournalOrderFact _order(String no, String at) =>
    JournalOrderFact(brokerOrderNo: no, submittedAt: _t(at));

JournalDecisionFact _decision(
  String id, {
  String reason = '월간 정기 리밸런싱',
  String code = 'MONTHLY_REGULAR',
  String kind = 'REBALANCE',
  String created = '2026-08-03T23:40:00Z',
  String trade = '2026-08-04',
  String? journal,
  String? parent,
}) => JournalDecisionFact(
  decisionId: id,
  createdAt: _t(created),
  tradeDate: TradeDate(trade),
  kindWire: kind,
  reasonCode: code,
  reason: reason,
  configHash: 'cfg_fake_0000000000000000',
  journalId: journal,
  parentDecisionId: parent,
);

JournalFacts _facts({
  List<JournalIntentFact> intents = const <JournalIntentFact>[],
  List<JournalDecisionFact> decisions = const <JournalDecisionFact>[],
  List<JournalEventFact> events = const <JournalEventFact>[],
  List<JournalNoteFact> notes = const <JournalNoteFact>[],
  RunMode runMode = RunMode.live,
  bool Function(String)? hasBody,
  bool integrity = false,
  bool recon = false,
  WhatIfConfig? config,
}) => JournalFacts(
  runMode: runMode,
  intents: intents,
  decisions: <String, JournalDecisionFact>{
    for (final JournalDecisionFact d in decisions) d.decisionId: d,
  },
  events: events,
  notes: <String, JournalNoteFact>{
    for (final JournalNoteFact n in notes) n.journalId: n,
  },
  nowUtc: _now,
  kr: _kr,
  accountLabelOf: (String a) => switch (a) {
    'pension' => '연금저축',
    'general' => '일반',
    _ => a,
  },
  hasBody: hasBody ?? (String _) => true,
  integrityHidden: integrity,
  reconSuspect: recon,
  config: config ?? _cfg,
);

const DateRange _all = DateRange(
  from: TradeDate('2026-01-02'),
  to: TradeDate('2026-08-31'),
);

/// 표본 je_0002 꼴(월간 정기 · B 379810 · 브로커 체결 1).
JournalIntentFact _je0002() => _intent(
  'i_0002',
  decision: 'B-SMA-2026-07-31@2026-08-04',
  orders: <JournalOrderFact>[
    _order('2026-08-04:B0002', '2026-08-04T06:10:00Z'),
  ],
  fills: <JournalFillFact>[
    _fill(
      'X0002#1',
      qty: 80,
      price: '17420',
      commission: '209',
      at: '2026-08-04T06:13:01Z',
      order: '2026-08-04:B0002',
    ),
  ],
);

const JournalEventFact _monthly = JournalEventFact(
  eventId: 'REB-MONTHLY-2026-07-31',
  tradeDate: TradeDate('2026-07-31'),
  kindWire: 'MONTHLY_REGULAR',
  decisionId: 'MONTH-END-2026-07-31',
  logicalIds: <String>{
    'MONTH-END-2026-07-31',
    'B-SMA-2026-07-31',
    'C-REBAL-2026-07-31',
  },
);

Map<String, Object?> _pick(Map<String, Object?> m, List<String> keys) =>
    <String, Object?>{for (final String k in keys) k: m[k]};

const List<String> _textKeys = <String>[
  'mode',
  'trade_date',
  'symbol',
  'symbol_label',
  'sleeve',
  'side',
  'side_label',
  'quantity',
  'quantity_text',
  'price_text',
  'commission_text',
  'tax_text',
  'status',
  'status_label',
  'status_tone',
  'visibility',
  'visibility_label',
  'account_alias',
  'fill_origin',
  'fill_kind',
  'cost_source',
  'cost_source_label',
  'origin_label',
];

List<Map<String, Object?>> _chips(Object? reasons) => <Map<String, Object?>>[
  for (final Object? c in reasons! as List<Object?>)
    _pick(c! as Map<String, Object?>, <String>['code', 'label', 'tone']),
];

Map<String, Object?> _json(TradeJournalEntry e) =>
    jsonDecode(jsonEncode(e.toJson())) as Map<String, Object?>;

void main() {
  group('표본 대조(값 그대로 · 표본 개정 0)', () {
    test('기간 프리셋 = range_presets_4(거래일 달력 · 기본 = 최근 30일 하나)', () {
      expect(
        journalRangePresetsOf(
          kr: _kr,
          nowUtc: _now,
          firstLedgerDay: '2024-09-02',
        ),
        <DateRange>[
          for (final Map<String, Object?> r in _rows('range_presets_4.json'))
            DateRange.fromJson(r),
        ],
      );
    });

    test('슬리브 = sleeve_catalog_4(A · B · C · POT = A 소속 · 새틀라이트 0)', () {
      expect(
        journalSleeveCatalogOf(WhatIfConfig.defaults),
        <SleeveCatalogEntry>[
          for (final Map<String, Object?> r in _rows('sleeve_catalog_4.json'))
            SleeveCatalogEntry.fromJson(r),
        ],
      );
    });

    test(
      '필터 카탈로그 = m6/journal_filter_catalog(상태 7 · 출처 3 · 종목 = 슬리브 차례 → 코드)',
      () {
        final List<(String, String)> held = <(String, String)>[
          (P0sStrategyIds.pot, '357870'),
          (P0sStrategyIds.sleeveC, '411060'),
          (P0sStrategyIds.sleeveB, '379810'),
          (P0sStrategyIds.sleeveA, '069500'),
          (P0sStrategyIds.sleeveC, '0085P0'),
          (P0sStrategyIds.sleeveB, '132030'),
        ];
        final JournalFacts f = _facts(
          intents: <JournalIntentFact>[
            for (final (String st, String sym) in held)
              _intent('i_$sym', decision: 'D@$sym', strategy: st, symbol: sym),
          ],
        );
        expect(
          journalFilterCatalogOf(f),
          JournalFilterCatalog.fromJson(
            _rows('m6/journal_filter_catalog.json').single,
          ),
        );
      },
    );

    test('배지 = m6/journal_badges_2 첫 행(미해소 2건) · 리뷰 대기 = LIVE 큐 원천 0 → 없음', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          _intent('i_1', decision: 'D1@x', status: 'UNKNOWN'),
          _intent('i_2', decision: 'D2@x', status: 'UNKNOWN'),
          _intent('i_3', decision: 'D3@x'),
        ],
      );
      expect(journalTimelineBadgesOf(f), <JournalTimelineBadge>[
        JournalTimelineBadge.fromJson(_rows('m6/journal_badges_2.json').first),
      ]);
    });

    group('J-2 체인 6단계 = 표본 decision_detail_*', () {
      List<DecisionChainStep> steps(String file, {bool tradeTime = true}) =>
          <DecisionChainStep>[
            for (final Object? s
                in _rows('m6/$file').single['steps']! as List<Object?>)
              DecisionChainStep.fromJson(s! as Map<String, Object?>),
          ];

      test('full — 원장 반영 시각 원천 없음(TRADE 시각 = null · 나머지 그대로)', () {
        final JournalFacts f = _facts(
          intents: <JournalIntentFact>[
            _intent(
              'i_0001',
              decision: 'd_20260803_a_01',
              strategy: P0sStrategyIds.sleeveA,
              symbol: '069500',
              qty: 120,
              trade: '2026-08-03',
              created: '2026-08-02T23:41:00Z',
              orders: <JournalOrderFact>[
                _order('B0001', '2026-08-03T05:10:00Z'),
              ],
              fills: <JournalFillFact>[
                _fill(
                  'X0001#1',
                  qty: 120,
                  price: '38250',
                  at: '2026-08-03T05:12:00Z',
                ),
              ],
            ),
          ],
          decisions: <JournalDecisionFact>[
            _decision(
              'd_20260803_a_01',
              reason: '계절 진입 게이트 통과 · 추세 점수 0.62',
              code: 'SEASONAL_ENTRY',
              kind: 'ENTRY',
              created: '2026-08-02T23:40:00Z',
              trade: '2026-08-03',
            ),
          ],
        );
        final List<DecisionChainStep> want = steps('decision_detail_full.json');
        want[4] = want[4].copyWith(occurredAtText: null);
        final DecisionDetailVm vm = decisionDetailVmOf(f, 'd_20260803_a_01');
        expect(vm.steps, want);
        expect(vm.journalStateLabel, '규칙대로 — 저널 대상이 아닙니다');
        expect(vm.snapshot!.kindLabel, '진입');
        expect(vm.remainingText, isNull);
        expect(vm.rejectTraces, isEmpty);
      });

      test('partial — 3회 체결 · 잔여 · 체결 행 = 체결 1건씩(시간 순)', () {
        final JournalFacts f = _facts(
          intents: <JournalIntentFact>[
            _intent(
              'i_0006',
              decision: 'd_20260810_a_06',
              status: 'PARTIAL',
              strategy: P0sStrategyIds.sleeveA,
              symbol: '069500',
              qty: 100,
              trade: '2026-08-10',
              created: '2026-08-09T23:41:00Z',
              orders: <JournalOrderFact>[
                _order('B0006', '2026-08-10T05:39:00Z'),
              ],
              fills: <JournalFillFact>[
                _fill(
                  'X0006#3',
                  qty: 15,
                  price: '38410',
                  at: '2026-08-10T07:17:05Z',
                ),
                _fill(
                  'X0006#1',
                  qty: 25,
                  price: '38410',
                  at: '2026-08-10T05:41:10Z',
                ),
                _fill(
                  'X0006#2',
                  qty: 20,
                  price: '38410',
                  at: '2026-08-10T06:30:42Z',
                ),
              ],
            ),
          ],
          decisions: <JournalDecisionFact>[
            _decision(
              'd_20260810_a_06',
              reason: '밴드 이탈 · A 슬리브 비중 부족',
              code: 'REBALANCE_BAND',
              created: '2026-08-09T23:40:00Z',
              trade: '2026-08-10',
            ),
          ],
        );
        final DecisionDetailVm vm = decisionDetailVmOf(f, 'd_20260810_a_06');
        expect(vm.steps, steps('decision_detail_partial.json'));
        final Map<String, Object?> fx = _rows('m6/decision_detail_partial.json')
            .single;
        expect(vm.remainingText, fx['remaining_text']);
        expect(
          <(String, String, String)>[
            for (final TradeJournalEntry e in vm.fills)
              (e.entryId, e.quantityText, e.statusLabel),
          ],
          <(String, String, String)>[
            ('X0006#1', '25주', '부분 체결'),
            ('X0006#2', '20주', '부분 체결'),
            ('X0006#3', '15주', '부분 체결'),
          ],
        );
        expect(vm.entry.quantityText, '60주');
        expect(vm.entry.visibilityLabel, '반영 대기');
      });

      test('unknown — 전송됨 · 확인 중 · 미해소 고지(시각 = 엔진 일정 몫 · 표본 «(18:10)» 뺌)', () {
        final JournalFacts f = _facts(
          intents: <JournalIntentFact>[
            _intent(
              'i_0015',
              decision: 'd_20260821_a_15',
              status: 'UNKNOWN',
              strategy: P0sStrategyIds.sleeveA,
              symbol: '069500',
              qty: 70,
              trade: '2026-08-21',
              created: '2026-08-20T23:41:00Z',
              orders: <JournalOrderFact>[
                _order('B0015', '2026-08-21T05:02:00Z'),
              ],
            ),
          ],
          decisions: <JournalDecisionFact>[
            _decision(
              'd_20260821_a_15',
              reason: '월 정기 매수 · A 슬리브',
              created: '2026-08-20T23:40:00Z',
              trade: '2026-08-21',
            ),
          ],
        );
        final DecisionDetailVm vm = decisionDetailVmOf(f, 'd_20260821_a_15');
        expect(vm.steps, steps('decision_detail_unknown.json'));
        expect(vm.pendingNoticeText, '브로커 결과 확인 중 — 다음 배치에서 조회로 확정됩니다');
        expect(vm.entry.reasons.single.label, '브로커 응답이 확인되지 않았습니다');
      });

      test('rejected_saf309 — 브로커 전 거부 · 거부 추적(층 = 포트폴리오) 그대로', () {
        final JournalFacts f = _facts(
          intents: <JournalIntentFact>[
            _intent(
              'i_0009',
              decision: 'd_20260813_c_09',
              status: 'REJECTED',
              strategy: P0sStrategyIds.sleeveC,
              symbol: '0085P0',
              qty: 100,
              trade: '2026-08-13',
              created: '2026-08-12T23:41:00Z',
              updated: '2026-08-13T00:01:12Z',
              limit: '51500',
              error: 'SAF309_DENY_UNVERIFIED_FAIL_CLOSED',
            ),
          ],
          decisions: <JournalDecisionFact>[
            _decision(
              'd_20260813_c_09',
              reason: '월 정기 매수 · C 슬리브',
              created: '2026-08-12T23:40:00Z',
              trade: '2026-08-13',
            ),
          ],
        );
        final DecisionDetailVm vm = decisionDetailVmOf(f, 'd_20260813_c_09');
        expect(vm.steps, steps('decision_detail_rejected_saf309.json'));
        expect(vm.rejectTraces, <RejectTrace>[
          for (final Object? t
              in _rows('m6/decision_detail_rejected_saf309.json')
                      .single['reject_traces']!
                  as List<Object?>)
            RejectTrace.fromJson(t! as Map<String, Object?>),
        ]);
      });
    });

    test('일지 행 글자 = journal_30 je_0002(월간 정기 · 브로커 체결)', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[_je0002()],
        decisions: <JournalDecisionFact>[_decision('MONTH-END-2026-07-31')],
        events: const <JournalEventFact>[_monthly],
      );
      final TradeJournalEntry e = journalEntriesOf(f).single;
      final Map<String, Object?> fx = _row('journal_30.json', 'je_0002');
      expect(_pick(_json(e), _textKeys), _pick(fx, _textKeys));
      expect(_chips(_json(e)['reasons']), _chips(fx['reasons']));
      expect(
        e.deviation,
        DeviationBadge.fromJson(fx['deviation']! as Map<String, Object?>),
      );
      expect(e.backdate.label, '당일 기록');
      expect(e.rebalanceEventId, 'REB-MONTHLY-2026-07-31');
      expect(
        e.detailDeepLink,
        'aaq://journal/decision/B-SMA-2026-07-31@2026-08-04',
      );
      expect(e.decision.brokerOrderNo, '2026-08-04:B0002');
      expect(e.decision.executionId, 'X0002#1');
    });

    test('거부 · 미해소 · 실효 · 모의 거부 행 글자 = 표본(«(합성)»만 뺌)', () {
      final List<String> keys = <String>[
        'status',
        'status_label',
        'status_tone',
        'visibility',
        'visibility_label',
        'cost_source',
        'cost_source_label',
        'quantity_text',
      ];
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          _intent(
            'r309',
            decision: 'D9@x',
            status: 'REJECTED',
            qty: 100,
            error: 'SAF309_DENY_UNVERIFIED_FAIL_CLOSED',
          ),
          _intent(
            'unk',
            decision: 'D15@x',
            status: 'UNKNOWN',
            qty: 70,
            orders: <JournalOrderFact>[_order('B', '2026-08-04T05:00:00Z')],
          ),
          _intent(
            'exp',
            decision: 'D21@x',
            status: 'EXPIRED',
            qty: 12,
            orders: <JournalOrderFact>[_order('B2', '2026-08-04T05:00:00Z')],
          ),
          _intent(
            'sim',
            decision: 'DS@x',
            status: 'REJECTED',
            qty: 100,
            mode: 'SIM_INTERNAL',
            error: 'BROKER: SIM_INVALID_ORDER 수량 꼴',
          ),
        ],
      );
      final Map<String, TradeJournalEntry> by = <String, TradeJournalEntry>{
        for (final TradeJournalEntry e in journalEntriesOf(f)) e.entryId: e,
      };
      for (final (String id, Map<String, Object?> fx)
          in <(String, Map<String, Object?>)>[
            ('r309', _row('journal_30.json', 'je_0009')),
            ('unk', _row('journal_30.json', 'je_0015')),
            ('exp', _rows('m6/journal_expired_1.json').single),
            ('sim', _rows('m6/journal_sim_broker_reject.json').single),
          ]) {
        final Map<String, Object?> got = _json(by[id]!);
        expect(_pick(got, keys), _pick(fx, keys), reason: id);
        expect(_chips(got['reasons']), <Map<String, Object?>>[
          for (final Map<String, Object?> c in _chips(fx['reasons']))
            <String, Object?>{
              ...c,
              'label': (c['label']! as String).replaceFirst('(합성) ', ''),
            },
        ], reason: id);
      }
    });

    test('가림 — LEDGER_INTEGRITY = 수량 · 가격 · 비용 «숨김»(journal_masked_integrity) · RECON = 수량 끝 «?»', () {
      final List<String> keys = <String>[
        'quantity_text',
        'price_text',
        'commission_text',
        'tax_text',
      ];
      final TradeJournalEntry hidden = journalEntriesOf(
        _facts(intents: <JournalIntentFact>[_je0002()], integrity: true),
      ).single;
      expect(
        _pick(_json(hidden), keys),
        _pick(_row('m6/journal_masked_integrity.json', 'je_0002'), keys),
      );
      expect(hidden.quantity, 80);
      final TradeJournalEntry recon = journalEntriesOf(
        _facts(intents: <JournalIntentFact>[_je0002()], recon: true),
      ).single;
      expect((recon.quantityText, recon.priceText), ('80주?', '17,420원'));
    });

    test('빈 봉투 — 일지 0 = journal_empty 꼴(D-day = 홈과 같은 셈) · 모르는 회차 = journal_rebalance_unknown 문장', () {
      final ListResult<TradeJournalEntry> empty = journalTimelineOf(
        _facts(),
        range: _all,
      );
      final String? exec = nextRegularExecutionSession(_kr, _now);
      expect(
        empty.emptyLabel,
        '아직 기록된 거래가 없습니다 · 첫 주문은 리밸런싱일에 나갑니다 · 다음 리밸런싱 '
        '${opsDDayText('2026-08-31', exec!)}',
      );
      expect(
        (empty.rows.length, empty.emptyKind, empty.hasMore),
        (0, EmptyKind.noData, false),
      );
      expect(
        journalTimelineOf(
          _facts(intents: <JournalIntentFact>[_je0002()]),
          range: _all,
          rebalanceEventId: 're_none',
        ).emptyLabel,
        _fx('m6/journal_rebalance_unknown.json')['empty_label'],
      );
      expect(
        journalTimelineOf(
          _facts(intents: <JournalIntentFact>[_je0002()]),
          range: _all,
          symbol: '069500',
        ).emptyLabel,
        '조건에 맞는 기록이 없습니다',
      );
    });

    test(
      'J-3R = journal_read_written(본문 · 결정 링크) · 미작성 = body null · 모르는 결정 = 실패',
      () {
        final Map<String, Object?> fx = _rows('m6/journal_read_written.json')
            .single;
        final Map<String, Object?> body = fx['body']! as Map<String, Object?>;
        final JournalFacts f = _facts(
          intents: <JournalIntentFact>[
            _intent('i_31', decision: 'd_20260901_a_31'),
            _intent('i_27', decision: 'd_20260810_b_27'),
          ],
          decisions: <JournalDecisionFact>[
            _decision('d_20260901_a_31', journal: 'J-31'),
          ],
          notes: <JournalNoteFact>[
            JournalNoteFact(
              journalId: 'J-31',
              createdAt: _t('2026-08-31T00:12:00Z'),
              isDeviation: true,
              kind: 'DISCRETION',
              ruleCited: body['rule_cited_label']! as String,
              rationaleBefore: body['rationale_before']! as String,
              expectedOutcome: body['expected_outcome']! as String,
              note: body['note'] as String?,
            ),
          ],
        );
        expect(
          decisionJournalVmOf(f, 'd_20260901_a_31'),
          DecisionJournalVm.fromJson(fx),
        );
        final DecisionJournalVm not = decisionJournalVmOf(f, 'd_20260810_b_27');
        expect((not.journalStateLabel, not.body), ('저널 미작성', null));
        expect(
          () => decisionJournalVmOf(f, 'd_none'),
          throwsA(isA<StateError>()),
        );
        // 저널이 있는 결정 = J-2 저널 단계 «작성됨» · «저널 보기» → J-3R · 이탈 배지.
        final DecisionDetailVm d = decisionDetailVmOf(f, 'd_20260901_a_31');
        expect(d.journalStateLabel, '저널 작성됨');
        expect(d.journalLink!.deepLink, 'aaq://journal/read/d_20260901_a_31');
        expect(d.steps.last.stateLabel, '작성됨');
        expect(d.entry.deviation.isDeviation, true);
      },
    );

    test(
      'S7-6b «이 회차의 주문 n건» = m7_rebalance_detail_band 링크 · 행 0 · 미등록 = null',
      () {
        final Map<String, Object?> fx = _rows(
          'm7/m7_rebalance_detail_band.json',
        ).single;
        expect(
          journalTimelineLinkOf(
            fx['event_id']! as String,
            2,
            hasBody: (String _) => true,
          ),
          LinkAction.fromJson(
            fx['journal_timeline_link']! as Map<String, Object?>,
          ),
        );
        expect(
          journalTimelineLinkOf('re', 0, hasBody: (String _) => true),
          isNull,
        );
        expect(
          journalTimelineLinkOf(
            're',
            2,
            hasBody: (String r) => r != AppRoutes.journalRebalance,
          ),
          isNull,
        );
      },
    );
  });

  group('J-1 타임라인', () {
    JournalFacts many() => _facts(
      intents: <JournalIntentFact>[
        for (int i = 1; i <= 5; i++)
          _intent(
            'i_$i',
            decision: 'B-SMA-2026-07-31@2026-08-0$i',
            trade: '2026-08-0$i',
            created: '2026-08-0${i}T01:00:00Z',
            symbol: i.isOdd ? '379810' : '132030',
          ),
        _intent(
          'i_c',
          decision: 'C-REBAL-2026-07-31@2026-08-03',
          strategy: P0sStrategyIds.sleeveC,
          symbol: '0085P0',
          trade: '2026-08-03',
          created: '2026-08-03T02:00:00Z',
          status: 'REJECTED',
          error: 'KILL_SWITCH',
        ),
        _intent(
          'i_late',
          decision: 'X@2026-08-03',
          trade: '2026-08-03',
          created: '2026-08-03T01:00:00Z',
        ),
      ],
      events: const <JournalEventFact>[_monthly],
    );

    test('🔴 시간 역순(거래일 → 기록 시각 → 의도 id) · limit = 앞에서 · hasMore', () {
      final ListResult<TradeJournalEntry> r = journalTimelineOf(
        many(),
        range: _all,
        limit: 4,
      );
      expect(
        <String>[for (final TradeJournalEntry e in r.rows) e.entryId],
        <String>['i_5', 'i_4', 'i_c', 'i_late'],
      );
      expect((r.hasMore, r.emptyLabel), (true, null));
      final ListResult<TradeJournalEntry> all = journalTimelineOf(
        many(),
        range: _all,
      );
      expect(all.rows.length, 7);
      expect(all.hasMore, false);
      expect(all.rows.last.entryId, 'i_1');
      // 🔴 경계 — 행 수 = limit 이면 더 없다.
      expect(journalTimelineOf(many(), range: _all, limit: 7).hasMore, false);
      expect(all.asOf.label, '일지 기준 2026-08-31');
    });

    test('조건 = 기간(양 끝 포함) · 슬리브 · 종목 · 상태 · 출처 · 회차', () {
      List<String> ids(ListResult<TradeJournalEntry> r) => <String>[
        for (final TradeJournalEntry e in r.rows) e.entryId,
      ];
      expect(
        ids(
          journalTimelineOf(
            many(),
            range: const DateRange(
              from: TradeDate('2026-08-02'),
              to: TradeDate('2026-08-03'),
            ),
          ),
        ),
        <String>['i_c', 'i_late', 'i_3', 'i_2'],
      );
      expect(
        ids(journalTimelineOf(many(), range: _all, sleeve: SleeveId.c)),
        <String>['i_c'],
      );
      expect(
        ids(journalTimelineOf(many(), range: _all, symbol: '132030')),
        <String>['i_4', 'i_2'],
      );
      expect(
        ids(
          journalTimelineOf(
            many(),
            range: _all,
            status: JournalStatus.rejected,
          ),
        ),
        <String>['i_c'],
      );
      expect(
        ids(journalTimelineOf(many(), range: _all, origin: FillOrigin.manual)),
        isEmpty,
      );
      expect(
        ids(
          journalTimelineOf(
            many(),
            range: _all,
            rebalanceEventId: 'REB-MONTHLY-2026-07-31',
          ),
        ),
        <String>['i_5', 'i_4', 'i_c', 'i_3', 'i_2', 'i_1'],
      );
    });

    test('진행 중(예약 · 전송 · 접수 — 체결 0) = 미체결 축 + «접수 — 체결 대기» · 시장가 = «시장가»', () {
      final TradeJournalEntry e = journalEntriesOf(
        _facts(
          intents: <JournalIntentFact>[
            _intent('i', decision: 'D@x', status: 'SUBMITTED', limit: null),
          ],
        ),
      ).single;
      expect(
        (e.status, e.statusLabel, e.statusTone, e.visibilityLabel, e.priceText),
        (JournalStatus.partial, '접수 — 체결 대기', ChipTone.neutral, '반영 대기', '시장가'),
      );
      expect(e.executedAt, isNull);
      expect(e.costSourceLabel, '추정치');
    });

    test('리스 · 킬스위치 · 브로커 거부 사유 칩 · 건너뜀', () {
      final Map<String, TradeJournalEntry> by = <String, TradeJournalEntry>{
        for (final TradeJournalEntry e in journalEntriesOf(
          _facts(
            intents: <JournalIntentFact>[
              _intent(
                'a',
                decision: 'A@x',
                status: 'REJECTED',
                error: kLeaseInvalidCode,
              ),
              _intent(
                'b',
                decision: 'B@x',
                status: 'SKIPPED',
                error: kLeaseInvalidCode,
              ),
              _intent(
                'c',
                decision: 'C@x',
                status: 'REJECTED',
                error: 'BROKER: 40310000 잔고 부족',
              ),
              _intent(
                'd',
                decision: 'D@x',
                status: 'REJECTED',
                error: 'SAF-404: 화이트리스트 밖',
              ),
              _intent('e', decision: 'E@x', status: 'REJECTED'),
            ],
          ),
        ))
          e.entryId: e,
      };
      ReasonChip c(String id) => by[id]!.reasons.single;
      expect(
        (c('a').code, c('a').label, c('a').tone),
        ('LEASE_INVALID', '이 기기에 발주권이 없어 주문을 내지 않았습니다', ChipTone.blocked),
      );
      expect((by['b']!.statusLabel, c('b').tone), ('건너뜀', ChipTone.neutral));
      expect(
        (c('c').code, c('c').label),
        ('BROKER_REJECTED', '브로커가 주문을 거부했습니다'),
      );
      expect(
        (c('d').code, c('d').label),
        ('SAF-404', '주문 전 검사에 막혔습니다(SAF-404)'),
      );
      expect(c('e').code, 'REJECT_UNKNOWN');
    });

    test('모의 원장 — 출처 선택지 = «모의 체결만» · 체결 0 행 출처 = 모의 · 모드 = 행이 말한다', () {
      final JournalFacts f = _facts(
        runMode: RunMode.simInternal,
        intents: <JournalIntentFact>[
          _intent(
            's',
            decision: 'D@x',
            status: 'SUBMITTED',
            mode: 'SIM_INTERNAL',
          ),
          _intent(
            't',
            decision: 'E@x',
            mode: 'SIM_INTERNAL',
            fills: <JournalFillFact>[
              _fill(
                'S#1',
                qty: 80,
                price: '17420',
                at: '2026-08-04T06:00:00Z',
                origin: 'SIMULATED',
                cost: 'ESTIMATED',
              ),
            ],
          ),
        ],
      );
      expect(journalFilterCatalogOf(f).originOptions, const <FillOriginOption>[
        FillOriginOption(origin: FillOrigin.simulated, label: '모의 체결만'),
      ]);
      for (final TradeJournalEntry e in journalEntriesOf(f)) {
        expect(
          (e.mode, e.fillOrigin, e.originLabel),
          (RunMode.simInternal, FillOrigin.simulated, '모의 체결'),
        );
      }
      expect(
        journalTimelineOf(
          f,
          range: _all,
          origin: FillOrigin.simulated,
        ).rows.length,
        2,
      );
    });

    test('🔴 링크 = 등록된 화면만(상세 · 회차 · 저널 읽기 · 미해소 보드)', () {
      final JournalFacts none = _facts(
        intents: <JournalIntentFact>[
          _je0002(),
          _intent('u', decision: 'U@x', status: 'UNKNOWN'),
        ],
        decisions: <JournalDecisionFact>[
          _decision('MONTH-END-2026-07-31'),
          _decision('B-SMA-2026-07-31', journal: 'J'),
        ],
        events: const <JournalEventFact>[_monthly],
        notes: <JournalNoteFact>[
          JournalNoteFact(journalId: 'J', createdAt: _now, isDeviation: false),
        ],
        hasBody: (String _) => false,
      );
      expect(journalEntriesOf(none).first.detailDeepLink, isNull);
      expect(journalTimelineBadgesOf(none).single.deepLink, isNull);
      final DecisionDetailVm d = decisionDetailVmOf(
        none,
        'B-SMA-2026-07-31@2026-08-04',
      );
      expect(
        (d.rebalanceLink, d.journalLink, d.parentLink),
        (null, null, null),
      );
      expect(d.journalStateLabel, '저널 작성됨');
      final DecisionDetailVm on = decisionDetailVmOf(
        _facts(
          intents: <JournalIntentFact>[_je0002()],
          decisions: <JournalDecisionFact>[
            _decision('MONTH-END-2026-07-31', parent: 'MONTH-END-2026-06-30'),
          ],
          events: const <JournalEventFact>[_monthly],
        ),
        'B-SMA-2026-07-31@2026-08-04',
      );
      expect(
        on.rebalanceLink,
        const LinkAction(
          label: '이 회차 보기',
          deepLink: 'aaq://rebalance/event/REB-MONTHLY-2026-07-31',
        ),
      );
      expect(
        on.parentLink!.deepLink,
        'aaq://journal/decision/MONTH-END-2026-06-30',
      );
    });

    test(
      '🔴 결정 원천 없는 의도 = «이어지지 않은 주문» 칩(지어내지 않는다) · 귀속 불가 전략 · 모르는 결정 = 실패',
      () {
        final TradeJournalEntry e = journalEntriesOf(
          _facts(intents: <JournalIntentFact>[_intent('i', decision: 'Q@x')]),
        ).single;
        expect(e.reasons.single.code, 'DECISION_UNLINKED');
        expect(
          () => journalEntriesOf(
            _facts(
              intents: <JournalIntentFact>[
                _intent('i', decision: 'Q@x', strategy: 'P0S'),
              ],
            ),
          ),
          throwsA(isA<StateError>()),
        );
        expect(
          () => decisionDetailVmOf(_facts(), 'none'),
          throwsA(isA<StateError>()),
        );
      },
    );
  });

  test('🔴 재개 child 결정 id(`#`) — 링크 = `#` · `?` · `/` · `%` 만 퍼센트 꼴 · 라우트 조각으로 열면 같은 결정', () {
    const String id = 'B-SMA-2026-07-31#R2026-08-05@2026-08-05';
    final JournalFacts f = _facts(
      intents: <JournalIntentFact>[_intent('iR', decision: id)],
      events: const <JournalEventFact>[
        JournalEventFact(
          eventId: 'REB-MONTHLY-2026-07-31',
          tradeDate: TradeDate('2026-07-31'),
          kindWire: 'MONTHLY_REGULAR',
          decisionId: 'MONTH-END-2026-07-31',
          logicalIds: <String>{
            'MONTH-END-2026-07-31',
            'B-SMA-2026-07-31#R2026-08-05',
          },
        ),
      ],
    );
    final TradeJournalEntry e = journalEntriesOf(f).single;
    const String link =
        'aaq://journal/decision/B-SMA-2026-07-31%23R2026-08-05@2026-08-05';
    expect(e.detailDeepLink, link);
    expect(e.rebalanceEventId, 'REB-MONTHLY-2026-07-31');
    final String param = link.split('/').last;
    expect(param.contains('#'), false);
    expect(journalKeyOf(param), id);
    expect(decisionDetailVmOf(f, param).entry, e);
    expect(decisionJournalVmOf(f, param).decisionId, id);
    expect(decisionJournalVmOf(f, param).decisionLink!.deepLink, link);
    expect(journalKeyOf('100%'), '100%');
    expect(journalKeyOf('a%2Fb%3Fc%25'), 'a/b?c%');
  });

  group('회차 묶음 · 범위', () {
    const JournalEventFact seasonal = JournalEventFact(
      eventId: 'SEAS-2026-10-30',
      tradeDate: TradeDate('2026-10-30'),
      kindWire: 'SEASONAL',
      decisionId: 'SEAS-A-IN-2026-10-30',
      logicalIds: <String>{'SEAS-A-IN-2026-10-30', 'POT-LIQ-2026-10-30'},
    );

    test('논리 id 조각이 회차 묶음에 들면 그 회차(결합 · 재개 child · POT 청산) · 없으면 null', () {
      const List<JournalEventFact> ev = <JournalEventFact>[_monthly, seasonal];
      expect(
        journalEventIdOf('B-SMA-2026-07-31@2026-08-03', ev),
        'REB-MONTHLY-2026-07-31',
      );
      expect(
        journalEventIdOf('B-SMA-2026-07-31+POT-SMA-2026-07-31@2026-08-03', ev),
        'REB-MONTHLY-2026-07-31',
      );
      expect(
        journalEventIdOf('POT-LIQ-2026-10-30@2026-11-02', ev),
        'SEAS-2026-10-30',
      );
      expect(
        journalEventIdOf('SEAS-A-IN-2026-10-30@2026-11-03', ev),
        'SEAS-2026-10-30',
      );
      expect(journalEventIdOf('DEP-plan1@2026-08-03', ev), isNull);
    });

    test('범위 = 칩 글자 + 묶인 행 전부를 덮는 기간 · 행 0 = 회차 날 하루 · 모르는 회차 = null', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          _intent(
            'a',
            decision: 'B-SMA-2026-07-31@2026-08-03',
            trade: '2026-08-03',
          ),
          _intent(
            'b',
            decision: 'C-REBAL-2026-07-31@2026-08-05',
            trade: '2026-08-05',
            strategy: P0sStrategyIds.sleeveC,
            symbol: '0085P0',
          ),
          _intent('c', decision: 'Z@2026-08-20', trade: '2026-08-20'),
        ],
        events: const <JournalEventFact>[_monthly, seasonal],
      );
      expect(
        journalRebalanceScopeOf(f, 'REB-MONTHLY-2026-07-31'),
        const JournalRebalanceScope(
          rebalanceEventId: 'REB-MONTHLY-2026-07-31',
          label: '2026-07-31 월간 정기 회차',
          range: DateRange(
            from: TradeDate('2026-08-03'),
            to: TradeDate('2026-08-05'),
            label: '2026-08-03 ~ 2026-08-05',
          ),
        ),
      );
      final JournalRebalanceScope s = journalRebalanceScopeOf(
        f,
        'SEAS-2026-10-30',
      )!;
      expect(
        (s.label, s.range.from, s.range.to, s.range.isDefault),
        (
          '2026-10-30 계절 A 회차',
          const TradeDate('2026-10-30'),
          const TradeDate('2026-10-30'),
          false,
        ),
      );
      expect(journalRebalanceScopeOf(f, 'none'), isNull);
    });

    test('S7-6b 회차 VM = 묶인 의도 id · «이 회차의 주문 n건»(등록 · 행 있음만)', () {
      RebalanceEvent ev(List<String> ids, bool Function(String) hasBody) =>
          rebalanceEventsVmOf(
            <RebalanceEventFact>[
              RebalanceEventFact(
                eventId: 'REB-MONTHLY-2026-07-31',
                tradeDate: const TradeDate('2026-07-31'),
                modeWire: 'SIM_INTERNAL',
                kindWire: 'MONTHLY_REGULAR',
                configHash: 'cfg',
                trigger: const <String, Object?>{'targets': 2},
                weightsBefore: const <String, double>{},
                weightsAfter: const <String, double>{},
                createdAt: '2026-07-31T09:00:00Z',
                journalIntentIds: ids,
              ),
            ],
            nowUtc: _now,
            dataDate: const TradeDate('2026-08-31'),
            hasBody: hasBody,
          ).rows.single;
      final RebalanceEvent on = ev(<String>['i1', 'i2'], (String _) => true);
      expect(on.orderIntentIds, <String>['i1', 'i2']);
      expect(
        on.journalTimelineLink,
        const LinkAction(
          label: '이 회차의 주문 2건',
          deepLink: 'aaq://journal/rebalance/REB-MONTHLY-2026-07-31',
        ),
      );
      expect(
        ev(const <String>[], (String _) => true).journalTimelineLink,
        isNull,
      );
      expect(
        ev(<String>['i1'], (String _) => false).journalTimelineLink,
        isNull,
      );
    });
  });

  test('기간 프리셋 — 주말 · 원장 첫 날 없음 = 끝 날 · 첫 날이 끝보다 뒤 = 끝 날', () {
    final List<DateRange> p = journalRangePresetsOf(
      kr: _kr,
      nowUtc: DateTime.utc(2026, 8, 29, 3),
    );
    expect(
      <String>[
        for (final DateRange r in p) '${r.presetCode}:${r.from}~${r.to}',
      ],
      <String>[
        'LAST_30D:2026-07-29~2026-08-28',
        'THIS_MONTH:2026-08-03~2026-08-28',
        'THIS_YEAR:2026-01-02~2026-08-28',
        'ALL:2026-08-28~2026-08-28',
      ],
    );
    expect(p.where((DateRange r) => r.isDefault).length, 1);
    expect(
      journalRangePresetsOf(
        kr: _kr,
        nowUtc: _now,
        firstLedgerDay: '2026-09-15',
      ).last.from,
      const TradeDate('2026-08-31'),
    );
  });
}
