// E11q-j4s — J-4 blind 리뷰 채점 뒤(SPEC v2.47 02 §3-3 · 06 M1-25 ① ⑤ ⑥ · 13 §8 R257): 결과 문장 산식(로트 FIFO · 갈래 차례 ·
// 반올림 · 금액 0) · 큐 이탈 · 카드 결과 · 가림 · 명령 발급 · 답 JSON · 보관 접수증.
//
// 🔴 표본 대조 = `m6/blind_review_card_revealed*.json` 의 결과 글자 꼴 그대로(«결과: 수익률 +0.6% · 보유 12거래일» ·
//    «미청산 — 결과 미확정» · 과정 점수 4점 · 3점) · `blind_review_receipts_6` 보관 행 글자.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

/// 2026-09-01 09:00 KST — 8월이 닫힌 첫날.
final DateTime _now = DateTime.utc(2026, 9, 1);
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

Map<String, Object?> _fx(String path) =>
    jsonDecode(File('../domain_contracts/fixtures/$path').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _row0(String path) =>
    (_fx(path)['rows']! as List<Object?>).first! as Map<String, Object?>;

DateTime _t(String iso) => DateTime.parse(iso).toUtc();

JournalFillFact _fill(
  String id, {
  required String at,
  int qty = 10,
  String price = '38250',
  String commission = '57',
  String tax = '0',
  String kind = 'ORIGINAL',
  String? reverses,
}) => JournalFillFact(
  executionId: id,
  brokerOrderNo: 'B_$id',
  executedAt: _t(at),
  quantity: qty,
  priceText: price,
  commissionText: commission,
  taxText: tax,
  originWire: 'BROKER',
  kindWire: kind,
  costSourceWire: 'BROKER',
  reversesFillId: reverses,
);

JournalIntentFact _intent(
  String id, {
  required String decision,
  String side = 'BUY',
  String symbol = '0085P0',
  String strategy = P0sStrategyIds.sleeveC,
  String trade = '2026-08-11',
  String created = '2026-08-11T05:30:00Z',
  int qty = 10,
  List<JournalFillFact> fills = const <JournalFillFact>[],
}) => JournalIntentFact(
  intentId: id,
  decisionId: decision,
  createdAt: _t(created),
  updatedAt: _t(created),
  tradeDate: TradeDate(trade),
  modeWire: 'LIVE',
  account: 'pension',
  strategyId: strategy,
  symbol: symbol,
  sideWire: side,
  quantity: qty,
  statusWire: fills.isEmpty ? 'EXPIRED' : 'FILLED',
  configHash: 'cfg_fake_0000000000000000',
  limitPriceText: '38250',
  orders: <JournalOrderFact>[
    JournalOrderFact(
      brokerOrderNo: 'B_$id',
      submittedAt: _t(created).add(const Duration(minutes: 9)),
    ),
  ],
  fills: fills,
);

JournalDecisionFact _decision(String id, String journal, String trade) =>
    JournalDecisionFact(
      decisionId: id,
      createdAt: _t('${trade}T00:05:00Z'),
      tradeDate: TradeDate(trade),
      kindWire: 'MANUAL',
      reasonCode: 'MONTHLY_REGULAR',
      reason: '월간 정기 리밸런싱',
      configHash: 'cfg_fake_0000000000000000',
      journalId: journal,
    );

JournalNoteFact _note(String id, String created) => JournalNoteFact(
  journalId: id,
  createdAt: _t(created),
  isDeviation: true,
  kind: 'DISCRETION',
  rationaleBefore: '월간 정기 리밸런싱 주문이 나가지 않아 같은 수량을 수기로 넣는다.',
  expectedOutcome: '같은 거래일 안에 체결된다.',
  ruleCited: '재량 예산(롤링 12개월 4회) 안에서 조정',
);

JournalFacts _facts({
  required List<JournalIntentFact> intents,
  List<JournalDecisionFact> decisions = const <JournalDecisionFact>[],
  List<JournalNoteFact> notes = const <JournalNoteFact>[],
  Map<String, BlindReviewScoreFact> scores =
      const <String, BlindReviewScoreFact>{},
  List<JournalCorporateActionFact> actions =
      const <JournalCorporateActionFact>[],
  bool unattributed = false,
  bool hidden = false,
  bool Function(String)? hasBody,
  DateTime? now,
}) => JournalFacts(
  runMode: RunMode.live,
  intents: intents,
  decisions: <String, JournalDecisionFact>{
    for (final JournalDecisionFact d in decisions) d.decisionId: d,
  },
  events: const <JournalEventFact>[],
  notes: <String, JournalNoteFact>{
    for (final JournalNoteFact n in notes) n.journalId: n,
  },
  nowUtc: now ?? _now,
  kr: _kr,
  accountLabelOf: (String a) => a,
  hasBody: hasBody ?? (String _) => true,
  integrityHidden: hidden,
  blindReviewScores: scores,
  corporateActions: actions,
  unattributedFills: unattributed,
);

/// 결정 하나의 결과 글자(사실 → 산식 → 글자 · 가림 없음).
String _outcome(JournalFacts f, String decision) => blindReviewOutcomeTextOf(
  blindReviewOutcomeOf(
    decisionId: decision,
    fills: blindReviewFillsOf(f),
    corporateActionAxes: <(String, String)>{
      for (final JournalCorporateActionFact c in f.corporateActions)
        (c.account, c.symbol),
    },
    unattributedFills: f.unattributedFills,
    sessionsBetween: (String a, String b) => krSessionsBetween(f, a, b),
  ),
);

/// 표본 결과 행0 꼴 — 08-11 매수 10 @ 38,250(수수료 57) · 08-28 매도 10 @ 38,500(수수료 58) = +0.6% · 12거래일.
List<JournalIntentFact> _closedC28({String decision = 'd_c28'}) =>
    <JournalIntentFact>[
      _intent(
        'i_buy',
        decision: decision,
        fills: <JournalFillFact>[_fill('x_buy', at: '2026-08-11T05:50:00Z')],
      ),
      _intent(
        'i_sell',
        decision: 'd_rule_sell',
        side: 'SELL',
        trade: '2026-08-28',
        created: '2026-08-28T05:30:00Z',
        fills: <JournalFillFact>[
          _fill(
            'x_sell',
            at: '2026-08-28T05:50:00Z',
            price: '38500',
            commission: '58',
          ),
        ],
      ),
    ];

void main() {
  group('수익률 글자(02 §3-3 ② 5)', () {
    test(
      '소수 첫째 자리 · 절댓값 half-up · 양 «+» · 음 «−»(U+2212) · 반올림 뒤 0 = «0.0%»',
      () {
        String p(String r) => blindReviewPctText(Decimal.parse(r));
        expect(p('0.006234'), '+0.6%');
        expect(p('-0.012'), '−1.2%');
        expect(p('0'), '0.0%');
        expect(p('0.0004999'), '0.0%');
        expect(p('-0.0004999'), '0.0%');
        expect(p('0.0005'), '+0.1%');
        expect(p('-0.0005'), '−0.1%');
        expect(p('0.12345'), '+12.3%');
        expect(p('0.1235'), '+12.4%');
        expect(p('1.5'), '+150.0%');
        expect(p('-0.99'), '−99.0%');
      },
    );
  });

  group('결과 갈래 · 로트 FIFO(02 §3-3 ② ⓑ ~ ⓔ)', () {
    test(
      '🔴 ⓔ 표본 꼴 그대로 — 결정이 연 로트 전부 청산(다른 결정의 매도) = «결과: 수익률 +0.6% · 보유 12거래일»',
      () {
        final Map<String, Object?> fx = _row0(
          'm6/blind_review_card_revealed.json',
        );
        final String want =
            (fx['result']! as Map<String, Object?>)['outcome_text']! as String;
        expect(_outcome(_facts(intents: _closedC28()), 'd_c28'), want);
        expect(want, '결과: 수익률 +0.6% · 보유 12거래일');
      },
    );

    test('ⓓ 표본 꼴 그대로 — 청산 전 · 일부 청산 = «미청산 — 결과 미확정»', () {
      final String want =
          (_row0('m6/blind_review_card_revealed_open.json')['result']!
                  as Map<String, Object?>)['outcome_text']!
              as String;
      expect(
        _outcome(
          _facts(intents: <JournalIntentFact>[_closedC28().first]),
          'd_c28',
        ),
        want,
      );
      final List<JournalIntentFact> partial = <JournalIntentFact>[
        _closedC28().first,
        _intent(
          'i_sell',
          decision: 'd_rule_sell',
          side: 'SELL',
          trade: '2026-08-28',
          qty: 4,
          fills: <JournalFillFact>[
            _fill('x_sell', at: '2026-08-28T05:50:00Z', qty: 4, price: '38500'),
          ],
        ),
      ];
      expect(_outcome(_facts(intents: partial), 'd_c28'), want);
    });

    test('ⓑ 결정의 살아 있는 체결 0(실효 · 전부 되돌림) = «체결 없음 — 결과 없음»', () {
      expect(
        _outcome(
          _facts(intents: <JournalIntentFact>[_intent('i', decision: 'd')]),
          'd',
        ),
        '체결 없음 — 결과 없음',
      );
      final JournalFacts reversed = _facts(
        intents: <JournalIntentFact>[
          _intent(
            'i',
            decision: 'd',
            fills: <JournalFillFact>[
              _fill('x1', at: '2026-08-11T05:50:00Z'),
              _fill(
                'x1r',
                at: '2026-08-12T05:50:00Z',
                kind: 'REVERSAL',
                reverses: 'x1',
              ),
            ],
          ),
        ],
      );
      expect(_outcome(reversed, 'd'), '체결 없음 — 결과 없음');
    });

    test('🔴 정정 = 되돌린 원 체결 대신 새 판(RESTATEMENT) 가격으로 셈(X5-3 살아 있는 체결)', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          _intent(
            'i_buy',
            decision: 'd',
            fills: <JournalFillFact>[
              _fill('x1', at: '2026-08-11T05:50:00Z', price: '99999'),
              _fill(
                'x1r',
                at: '2026-08-12T05:50:00Z',
                kind: 'REVERSAL',
                price: '99999',
                reverses: 'x1',
              ),
              _fill('x1s', at: '2026-08-12T05:51:00Z', kind: 'RESTATEMENT'),
            ],
          ),
          _closedC28()[1],
        ],
      );
      expect(_outcome(f, 'd'), '결과: 수익률 +0.6% · 보유 12거래일');
    });

    test('🔴 FIFO — 앞선 로트부터 덜어낸다: 먼저 산 결정 = 청산 · 뒤에 산 결정 = 미청산', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          _intent(
            'i_a',
            decision: 'd_a',
            fills: <JournalFillFact>[_fill('xa', at: '2026-08-11T05:50:00Z')],
          ),
          _intent(
            'i_b',
            decision: 'd_b',
            trade: '2026-08-12',
            created: '2026-08-12T05:30:00Z',
            fills: <JournalFillFact>[
              _fill('xb', at: '2026-08-12T05:50:00Z', price: '38000'),
            ],
          ),
          _closedC28()[1],
        ],
      );
      expect(_outcome(f, 'd_a'), '결과: 수익률 +0.6% · 보유 12거래일');
      expect(_outcome(f, 'd_b'), '미청산 — 결과 미확정');
    });

    test('매도 결정 = 그 매도가 덜어낸 앞선 로트의 조각 · 보유 = 그 로트 취득일 → 매도일', () {
      final List<JournalIntentFact> i = _closedC28();
      final JournalFacts f = _facts(intents: i);
      expect(_outcome(f, 'd_rule_sell'), '결과: 수익률 +0.6% · 보유 12거래일');
    });

    test('같은 날 사고 팔기 = 보유 0거래일 · 비용 포함(같은 가격 = 음수 수익률)', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          _intent(
            'i_buy',
            decision: 'd',
            fills: <JournalFillFact>[
              _fill(
                'xb',
                at: '2026-08-11T05:50:00Z',
                price: '10000',
                commission: '15',
              ),
            ],
          ),
          _intent(
            'i_sell',
            decision: 'd',
            side: 'SELL',
            created: '2026-08-11T06:30:00Z',
            fills: <JournalFillFact>[
              _fill(
                'xs',
                at: '2026-08-11T06:50:00Z',
                price: '10000',
                commission: '15',
                tax: '20',
              ),
            ],
          ),
        ],
      );
      // 취득 100,015 · 청산 99,965 → −0.0499…% → 반올림 뒤 0.0%.
      expect(_outcome(f, 'd'), '결과: 수익률 0.0% · 보유 0거래일');
    });

    test('🔴 ⓒ 셀 수 없음 — 매도가 앞선 로트보다 많음 · 축의 기업 행사 · 축 모르는 수기 체결 · 달력 밖', () {
      const String want = '셀 수 없음 — 결과 미확정';
      final JournalFacts over = _facts(
        intents: <JournalIntentFact>[
          _intent(
            'i_sell',
            decision: 'd',
            side: 'SELL',
            fills: <JournalFillFact>[_fill('xs', at: '2026-08-11T05:50:00Z')],
          ),
        ],
      );
      expect(_outcome(over, 'd'), want);
      final JournalFacts ca = _facts(
        intents: _closedC28(),
        actions: <JournalCorporateActionFact>[
          const JournalCorporateActionFact(
            account: 'pension',
            symbol: '0085P0',
            effectiveDate: TradeDate('2026-08-20'),
          ),
        ],
      );
      expect(_outcome(ca, 'd_c28'), want);
      // 다른 계좌 · 다른 종목의 기업 행사 = 상관없음.
      final JournalFacts other = _facts(
        intents: _closedC28(),
        actions: <JournalCorporateActionFact>[
          const JournalCorporateActionFact(
            account: 'general',
            symbol: '0085P0',
            effectiveDate: TradeDate('2026-08-20'),
          ),
          const JournalCorporateActionFact(
            account: 'pension',
            symbol: '379810',
            effectiveDate: TradeDate('2026-08-20'),
          ),
        ],
      );
      expect(_outcome(other, 'd_c28'), '결과: 수익률 +0.6% · 보유 12거래일');
      expect(
        _outcome(_facts(intents: _closedC28(), unattributed: true), 'd_c28'),
        want,
      );
      expect(
        blindReviewOutcomeTextOf(
          blindReviewOutcomeOf(
            decisionId: 'd_c28',
            fills: blindReviewFillsOf(_facts(intents: _closedC28())),
            corporateActionAxes: const <(String, String)>{},
            unattributedFills: false,
            sessionsBetween: (String a, String b) => throw StateError('달력 밖'),
          ),
        ),
        want,
      );
    });

    test('🔴 비용 = 취득에 수수료 · 세금 더함 · 청산에서 수수료 · 세금 뺌(0.1% 칸을 넘는 비용)', () {
      JournalFacts f({
        String buyFee = '0',
        String sellFee = '0',
        String sellTax = '0',
      }) => _facts(
        intents: <JournalIntentFact>[
          _intent(
            'i_buy',
            decision: 'd',
            qty: 1,
            fills: <JournalFillFact>[
              _fill(
                'xb',
                at: '2026-08-11T05:50:00Z',
                qty: 1,
                price: '10000',
                commission: buyFee,
              ),
            ],
          ),
          _intent(
            'i_sell',
            decision: 'd_rule_sell',
            side: 'SELL',
            trade: '2026-08-12',
            created: '2026-08-12T05:30:00Z',
            qty: 1,
            fills: <JournalFillFact>[
              _fill(
                'xs',
                at: '2026-08-12T05:50:00Z',
                qty: 1,
                price: '10000',
                commission: sellFee,
                tax: sellTax,
              ),
            ],
          ),
        ],
      );
      expect(_outcome(f(), 'd'), '결과: 수익률 0.0% · 보유 1거래일');
      // 취득 10,100 · 청산 10,000 → −0.990…% → −1.0%.
      expect(_outcome(f(buyFee: '100'), 'd'), '결과: 수익률 −1.0% · 보유 1거래일');
      // 취득 10,000 · 청산 9,800 → −2.0%.
      expect(
        _outcome(f(sellFee: '120', sellTax: '80'), 'd'),
        '결과: 수익률 −2.0% · 보유 1거래일',
      );
      expect(_outcome(f(sellTax: '80'), 'd'), '결과: 수익률 −0.8% · 보유 1거래일');
    });

    test(
      '🔴 매도 넘침(앞선 로트 5 · 매도 10) = 그 축의 결정 모두 셀 수 없음(맞춘 몫만으로 결과를 짓지 않는다)',
      () {
        final JournalFacts f = _facts(
          intents: <JournalIntentFact>[
            _intent(
              'i_buy',
              decision: 'd_buy',
              qty: 5,
              fills: <JournalFillFact>[
                _fill('xb', at: '2026-08-11T05:50:00Z', qty: 5),
              ],
            ),
            _intent(
              'i_sell',
              decision: 'd_sell',
              side: 'SELL',
              trade: '2026-08-28',
              created: '2026-08-28T05:30:00Z',
              fills: <JournalFillFact>[
                _fill('xs', at: '2026-08-28T05:50:00Z', price: '38500'),
              ],
            ),
          ],
        );
        expect(_outcome(f, 'd_sell'), '셀 수 없음 — 결과 미확정');
        expect(_outcome(f, 'd_buy'), '셀 수 없음 — 결과 미확정');
      },
    );

    test('축 = (strategy_id, 종목) — 다른 슬리브의 같은 종목 매도는 이 결정의 로트를 덜지 않는다', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          _closedC28().first,
          _intent(
            'i_sell_a',
            decision: 'd_other',
            side: 'SELL',
            strategy: P0sStrategyIds.sleeveA,
            trade: '2026-08-28',
            fills: <JournalFillFact>[_fill('xa', at: '2026-08-28T05:50:00Z')],
          ),
        ],
      );
      expect(_outcome(f, 'd_c28'), '미청산 — 결과 미확정');
    });
  });

  group('큐 이탈 · 카드 결과(02 §3-3 ①-7 · ② · M1-25 ① · C-43 ④)', () {
    final List<JournalDecisionFact> decisions = <JournalDecisionFact>[
      _decision('d_c28', 'jr_28', '2026-08-11'),
      _decision('d_two', 'jr_two', '2026-08-12'),
    ];
    final List<JournalNoteFact> notes = <JournalNoteFact>[
      _note('jr_28', '2026-08-11T04:55:00Z'),
      _note('jr_two', '2026-08-12T04:55:00Z'),
    ];
    List<JournalIntentFact> intents() => <JournalIntentFact>[
      ..._closedC28(),
      _intent(
        'i_two',
        decision: 'd_two',
        symbol: '379810',
        trade: '2026-08-12',
        created: '2026-08-12T05:30:00Z',
        fills: <JournalFillFact>[_fill('x_two', at: '2026-08-12T05:50:00Z')],
      ),
    ];
    final BlindReviewScoreFact s28 = BlindReviewScoreFact(
      decisionId: 'd_c28',
      commandId: 'cmd_1',
      processScore: 4,
      scoredAt: _t('2026-09-01T00:10:00Z'),
    );

    test('🔴 채점된 결정 = 큐 · 배지에서 빠진다(n − 1) · 카드 1건 = 같은 카드 + 결과(표본 꼴) · 큐 행 결과 = 늘 null', () {
      final JournalFacts before = _facts(
        intents: intents(),
        decisions: decisions,
        notes: notes,
      );
      final JournalFacts after = _facts(
        intents: intents(),
        decisions: decisions,
        notes: notes,
        scores: <String, BlindReviewScoreFact>{'d_c28': s28},
      );
      final List<BlindReviewCard> q0 = blindReviewQueueOf(before).rows;
      expect(q0.map((BlindReviewCard c) => c.decisionId), <String>[
        'd_c28',
        'd_two',
      ]);
      final List<BlindReviewCard> q1 = blindReviewQueueOf(after).rows;
      expect(q1.map((BlindReviewCard c) => c.decisionId), <String>['d_two']);
      expect(q1.single.result, isNull);
      expect(
        journalTimelineBadgesOf(after)
            .where(
              (JournalTimelineBadge b) =>
                  b.badgeCode == JournalBadgeCodes.blindReviewPending,
            )
            .single
            .label,
        '리뷰 대기 1건',
      );
      final BlindReviewCard card = blindReviewCardOf(after, 'd_c28');
      expect(card.copyWith(result: null), q0.first);
      final Map<String, Object?> fx =
          _row0('m6/blind_review_card_revealed.json')['result']!
              as Map<String, Object?>;
      expect(card.result!.processScoreText, fx['process_score_text']);
      expect(card.result!.outcomeText, fx['outcome_text']);
      expect(card.result!.detailLines, isEmpty);
      expect(
        (card.result!.decisionLink!.label, card.result!.decisionLink!.deepLink),
        ('이 결정 보기', 'aaq://journal/decision/d_c28'),
      );
      // 채점 전 결정의 카드 1건 = 결과 없음.
      expect(blindReviewCardOf(after, 'd_two').result, isNull);
      // 전부 채점 = 배지 부재(«0건» 금지) · 큐 빈 문장.
      final JournalFacts all = _facts(
        intents: intents(),
        decisions: decisions,
        notes: notes,
        scores: <String, BlindReviewScoreFact>{
          'd_c28': s28,
          'd_two': BlindReviewScoreFact(
            decisionId: 'd_two',
            commandId: 'cmd_2',
            processScore: 3,
            scoredAt: _t('2026-09-01T00:20:00Z'),
          ),
        },
      );
      expect(
        journalTimelineBadgesOf(all).where(
          (JournalTimelineBadge b) =>
              b.badgeCode == JournalBadgeCodes.blindReviewPending,
        ),
        isEmpty,
      );
      expect(blindReviewQueueOf(all).emptyLabel, '리뷰할 결정이 없습니다');
      final BlindReviewResult two = blindReviewCardOf(all, 'd_two').result!;
      expect(
        (two.processScoreText, two.outcomeText),
        (
          (_row0('m6/blind_review_card_revealed_open.json')['result']!
              as Map<String, Object?>)['process_score_text'],
          '미청산 — 결과 미확정',
        ),
      );
    });

    test('🔴 가림(`LEDGER_INTEGRITY` · 실사 세션) = «결과: 숨김» · 과정 점수 · 링크는 그대로 · 본문 미등록 = 링크 부재', () {
      final BlindReviewResult hidden = blindReviewCardOf(
        _facts(
          intents: intents(),
          decisions: decisions,
          notes: notes,
          scores: <String, BlindReviewScoreFact>{'d_c28': s28},
          hidden: true,
        ),
        'd_c28',
      ).result!;
      expect(
        (hidden.processScoreText, hidden.outcomeText),
        ('과정 점수 4점 — 좋은 결정(4점 이상)', '결과: 숨김'),
      );
      expect(hidden.detailLines, isEmpty);
      expect(hidden.decisionLink, isNotNull);
      final BlindReviewResult noLink = blindReviewCardOf(
        _facts(
          intents: intents(),
          decisions: decisions,
          notes: notes,
          scores: <String, BlindReviewScoreFact>{'d_c28': s28},
          hasBody: (String r) => r != AppRoutes.journalDecision,
        ),
        'd_c28',
      ).result!;
      expect(noLink.decisionLink, isNull);
    });

    test('기업 행사 효력일 > 오늘 = 아직 셈에 걸리지 않는다(효력일 ≤ 오늘만)', () {
      JournalFacts at(String day) => _facts(
        intents: intents(),
        decisions: decisions,
        notes: notes,
        scores: <String, BlindReviewScoreFact>{'d_c28': s28},
        actions: <JournalCorporateActionFact>[
          JournalCorporateActionFact(
            account: 'pension',
            symbol: '0085P0',
            effectiveDate: TradeDate(day),
          ),
        ],
      );
      expect(
        blindReviewCardOf(at('2026-09-02'), 'd_c28').result!.outcomeText,
        '결과: 수익률 +0.6% · 보유 12거래일',
      );
      expect(
        blindReviewCardOf(at('2026-09-01'), 'd_c28').result!.outcomeText,
        '셀 수 없음 — 결과 미확정',
      );
    });

    test('🔴 금액(원) 0 — 결과 글자 어디에도 원 단위 없음(K6)', () {
      final RegExp won = RegExp(r'\d[\d,.]*\s*(억|만|천)?\s*원|₩');
      for (final String text in <String>[
        BlindReviewOutcomeTexts.hidden,
        BlindReviewOutcomeTexts.noFill,
        BlindReviewOutcomeTexts.uncountable,
        BlindReviewOutcomeTexts.open,
        BlindReviewOutcomeTexts.closed('+12.3%', 40),
        blindReviewCardOf(
          _facts(
            intents: intents(),
            decisions: decisions,
            notes: notes,
            scores: <String, BlindReviewScoreFact>{'d_c28': s28},
          ),
          'd_c28',
        ).result!.outcomeText,
      ]) {
        expect(won.hasMatch(text), isFalse, reason: text);
      }
    });
  });

  group('명령 · 기록 재료(02 §2-6 · §3-3 ①)', () {
    test('답 JSON = 키 이름 순(같은 답 = 같은 글자)', () {
      expect(
        blindReviewAnswersJsonOf(<String, int>{
          'WRITTEN_AT_DECISION': 0,
          'PIT_INFO_ONLY': 1,
          'RULE_FOLLOWED': 1,
        }),
        '{"PIT_INFO_ONLY":1,"RULE_FOLLOWED":1,"WRITTEN_AT_DECISION":0}',
      );
    });

    test(
      '명령 발급 — TTL 30분(표본 요청 → 만료) · 종류 · digest = 페이로드 JSON sha256 · 접수증 칸',
      () {
        final Map<String, Object?> fx = _row0(
          'm6/blind_review_receipts_6.json',
        );
        expect(
          _t(fx['expires_at']! as String)
              .difference(_t(fx['requested_at']! as String)),
          kBlindReviewTtl,
        );
        const BlindReviewScore score = BlindReviewScore(
          decisionId: 'd_c28',
          answers: <String, int>{'PIT_INFO_ONLY': 1},
        );
        final BlindReviewScoreCommand c = issueBlindReviewScore(
          score: score,
          nowUtc: _t('2026-08-31T09:20:00Z'),
          deviceId: 'dev_operator_01',
          random: Random(1),
        );
        final BlindReviewScoreCommand d = issueBlindReviewScore(
          score: score,
          nowUtc: _t('2026-08-31T09:20:00Z'),
          deviceId: 'dev_operator_01',
          random: Random(2),
        );
        expect(c.payloadDigest, d.payloadDigest);
        expect(c.commandId, isNot(d.commandId));
        expect(c.payloadDigest, hasLength(64));
        final CommandReceipt r = c.receipt(
          state: CommandState.executed,
          stateLabel: blindReviewStateLabelOf(null),
        );
        expect(
          (r.kind, r.requestedAt, r.expiresAt, r.issuedByDeviceId),
          (
            CommandKind.blindReviewScore,
            _t('2026-08-31T09:20:00Z'),
            _t('2026-08-31T09:50:00Z'),
            'dev_operator_01',
          ),
        );
      },
    );

    test('보관 접수증 = 표본 HELD_FOR_INTEGRITY 행 글자 그대로', () {
      final List<Object?> rows =
          _fx('m6/blind_review_receipts_6.json')['rows']! as List<Object?>;
      final Map<String, Object?> held = rows
          .cast<Map<String, Object?>>()
          .firstWhere(
            (Map<String, Object?> r) => r['state'] == 'HELD_FOR_INTEGRITY',
          );
      expect(blindReviewStateLabelOf(null, held: true), held['state_label']);
      // held 가 거부 코드보다 먼저(보관 = 판정 전).
      expect(
        blindReviewStateLabelOf(
          BlindReviewRejectCodes.alreadyScored,
          held: true,
        ),
        held['state_label'],
      );
    });
  });
}
