// E11q-j4 — M6 J-4 사후 blind 리뷰 VM(대상 · 큐 · 카드 · 배지) · 점수 제출 판정 · 과정 점수 · 접수증 글자.
//
// 🔴 표본 대조 = 계약 표본 글자 그대로(안내 · 문항 · 선택지 · 빈 문장 · 기준 줄 꼴 · 머리 꼴 · 근거 줄 꼴 · 과정 점수 · 접수증 ·
//    배지) · 표본 개정 0. 표본 `as_of`(08-31)는 골든 시계 축이라 K3 ⓑ(그 달 리포트 발행 뒤)를 재현하지 않는다 — 여기 시계 = 09-01.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

/// 2026-09-01 09:00 KST — 8월(마지막 세션 08-31)이 닫힌 첫날.
final DateTime _now = DateTime.utc(2026, 9, 1);
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

final WhatIfConfig _cfg = WhatIfConfig(
  planTtl: const Duration(hours: 24),
  pensionAnnualLimit: Decimal.fromInt(18000000),
  taxCreditBand: Decimal.fromInt(9000000),
  depositMin: Decimal.one,
  depositMax: Decimal.fromInt(1000000000),
  symbolLabels: const <String, String>{
    '0085P0': '0085P0 KODEX 국고채30년',
    '379810': '379810 KODEX 미국S&P500',
    '411060': '411060 ACE 미국30년국채',
  },
);

Map<String, Object?> _fx(String path) =>
    jsonDecode(File('../domain_contracts/fixtures/$path').readAsStringSync())
        as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_fx(path)['rows']! as List<Object?>).cast<Map<String, Object?>>();

DateTime _t(String iso) => DateTime.parse(iso).toUtc();

JournalIntentFact _intent(
  String id, {
  required String decision,
  String symbol = '0085P0',
  String side = 'BUY',
  String trade = '2026-08-11',
  String created = '2026-08-11T05:30:00Z',
  String status = 'FILLED',
  String mode = 'LIVE',
  List<JournalOrderFact> orders = const <JournalOrderFact>[],
}) => JournalIntentFact(
  intentId: id,
  decisionId: decision,
  createdAt: _t(created),
  updatedAt: _t(created),
  tradeDate: TradeDate(trade),
  modeWire: mode,
  account: 'pension',
  strategyId: P0sStrategyIds.sleeveC,
  symbol: symbol,
  sideWire: side,
  quantity: 10,
  statusWire: status,
  configHash: 'cfg_fake_0000000000000000',
  limitPriceText: '38250',
  orders: orders,
  fills: <JournalFillFact>[
    if (status == 'FILLED')
      JournalFillFact(
        executionId: 'X_$id',
        brokerOrderNo: orders.isEmpty ? null : orders.first.brokerOrderNo,
        executedAt: _t(created).add(const Duration(minutes: 20)),
        quantity: 10,
        priceText: '38250',
        commissionText: '57',
        taxText: '0',
        originWire: 'BROKER',
        kindWire: 'ORIGINAL',
        costSourceWire: 'BROKER',
      ),
  ],
);

JournalOrderFact _order(String no, String at) =>
    JournalOrderFact(brokerOrderNo: no, submittedAt: _t(at));

JournalDecisionFact _decision(
  String id, {
  String? journal,
  String created = '2026-08-11T00:05:00Z',
  String trade = '2026-08-11',
}) => JournalDecisionFact(
  decisionId: id,
  createdAt: _t(created),
  tradeDate: TradeDate(trade),
  kindWire: 'MANUAL',
  reasonCode: 'MONTHLY_REGULAR',
  reason: '월간 정기 리밸런싱',
  configHash: 'cfg_fake_0000000000000000',
  journalId: journal,
);

JournalNoteFact _note(
  String id, {
  bool deviation = true,
  String created = '2026-08-11T04:55:00Z',
  String? rationale = '월간 정기 리밸런싱 주문이 나가지 않아 같은 수량을 수기로 넣는다.',
  String? expected = '같은 거래일 안에 체결된다. 다음 거래일까지 확인되지 않으면 틀린 것으로 본다.',
  String? rule = '재량 예산(롤링 12개월 4회) 안에서 조정',
  String? note = '다음 정기 회차 전에 원인을 적는다.',
}) => JournalNoteFact(
  journalId: id,
  createdAt: _t(created),
  isDeviation: deviation,
  kind: 'DISCRETION',
  rationaleBefore: rationale,
  expectedOutcome: expected,
  ruleCited: rule,
  note: note,
);

JournalFacts _facts({
  List<JournalIntentFact> intents = const <JournalIntentFact>[],
  List<JournalDecisionFact> decisions = const <JournalDecisionFact>[],
  List<JournalNoteFact> notes = const <JournalNoteFact>[],
  RunMode runMode = RunMode.live,
  DateTime? now,
  bool Function(String)? hasBody,
}) => JournalFacts(
  runMode: runMode,
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
  config: _cfg,
);

/// 표본 행0(`d_20260811_c_28`) 꼴 — 08-11 0085P0 매수 · 저널 13:55 · 주문 14:39(KST).
const String _c28 = 'd_20260811_c_28';

List<JournalIntentFact> _c28Intents({String mode = 'LIVE'}) =>
    <JournalIntentFact>[
      _intent(
        'i_0028',
        decision: _c28,
        mode: mode,
        orders: <JournalOrderFact>[
          _order('2026-08-11:B0028', '2026-08-11T05:39:00Z'),
        ],
      ),
    ];

/// 세 결정(오래된 것부터 c_28 → mf_0002 → mf_0004 · 표본 큐 차례) + 규칙대로 하나 + 미완성 이탈 하나 + 9월 이탈 하나.
JournalFacts _three({
  RunMode runMode = RunMode.live,
  DateTime? now,
  bool Function(String)? hasBody,
}) => _facts(
  runMode: runMode,
  now: now,
  hasBody: hasBody,
  intents: <JournalIntentFact>[
    ..._c28Intents(mode: runMode == RunMode.live ? 'LIVE' : 'SIM_INTERNAL'),
    _intent(
      'i_mf_0004',
      decision: 'd_mf_0004',
      symbol: '411060',
      side: 'SELL',
      trade: '2026-08-27',
      created: '2026-08-27T05:20:00Z',
    ),
    _intent(
      'i_mf_0002',
      decision: 'd_mf_0002',
      symbol: '379810',
      trade: '2026-08-25',
      created: '2026-08-25T05:20:00Z',
    ),
    _intent('i_rule', decision: 'd_rule', trade: '2026-08-12'),
    _intent('i_open', decision: 'd_open', trade: '2026-08-13'),
    _intent('i_sep', decision: 'd_sep', trade: '2026-09-01'),
  ],
  decisions: <JournalDecisionFact>[
    _decision(_c28, journal: 'jr_28'),
    _decision(
      'd_mf_0004',
      journal: 'jr_mf4',
      created: '2026-08-27T00:00:00Z',
      trade: '2026-08-27',
    ),
    _decision(
      'd_mf_0002',
      journal: 'jr_mf2',
      created: '2026-08-25T00:00:00Z',
      trade: '2026-08-25',
    ),
    _decision('d_rule'),
    _decision('d_open', journal: 'jr_open'),
    _decision('d_sep', journal: 'jr_sep', trade: '2026-09-01'),
  ],
  notes: <JournalNoteFact>[
    _note('jr_28'),
    _note('jr_mf4', created: '2026-08-27T04:50:00Z'),
    _note('jr_mf2', created: '2026-08-25T11:10:00Z', note: null),
    _note('jr_open', rationale: null),
    _note('jr_sep', created: '2026-09-01T00:30:00Z'),
  ],
);

final RegExp _money = RegExp(r'\d[\d,.]*\s*(억|만|천)?\s*원|₩');
final RegExp _pct = RegExp(r'\d+(\.\d+)?\s*%');
final RegExp _pnl = RegExp('손익|수익|평가액');

Iterable<String> _strings(Object? j) sync* {
  if (j is String) {
    yield j;
  } else if (j is Map) {
    for (final Object? v in j.values) {
      yield* _strings(v);
    }
  } else if (j is List) {
    for (final Object? v in j) {
      yield* _strings(v);
    }
  }
}

void main() {
  group('대상(06 M1-25 ② ③ · K3 · K4 · K24)', () {
    test('🔴 이탈 · 작성된 저널 · 닫힌 달만 — 규칙대로 · 미완성(K3 ⓓ) · 아직 닫히지 않은 달 = 제외 · 결정 시각 오름차순', () {
      expect(
        <String>[
          for (final BlindReviewTarget t in blindReviewTargetsOf(_three()))
            t.decisionId,
        ],
        <String>[_c28, 'd_mf_0002', 'd_mf_0004'],
      );
    });

    test('🔴 K24 — 모의 원장 = 0 · 큐 = 해당 없음(표본 빈 문장) · 배지 부재', () {
      final JournalFacts sim = _three(runMode: RunMode.simInternal);
      expect(blindReviewTargetsOf(sim), isEmpty);
      final ListResult<BlindReviewCard> q = blindReviewQueueOf(sim);
      expect(q.rows, isEmpty);
      expect(q.emptyKind, EmptyKind.notApplicable);
      expect(
        q.emptyLabel,
        _fx('m6/blind_review_queue_empty.json')['empty_label'],
      );
      expect(
        journalTimelineBadgesOf(sim).where(
          (JournalTimelineBadge b) =>
              b.badgeCode == JournalBadgeCodes.blindReviewPending,
        ),
        isEmpty,
      );
      expect(() => blindReviewCardOf(sim, _c28), throwsStateError);
    });

    test('🔴 LIVE 원장이어도 SIM 큐 인자 = 해당 없음(SIM 리뷰 = 미결 99)', () {
      final ListResult<BlindReviewCard> q = blindReviewQueueOf(
        _three(),
        mode: RunMode.simInternal,
      );
      expect(q.rows, isEmpty);
      expect(q.emptyKind, EmptyKind.notApplicable);
    });

    test('K3 ⓑ 경계 — 월말 세션 날(한국) = 아직 · 다음 날 = 발행 뒤', () {
      // 2026-08-31(월) = 8월 마지막 KR 세션 · 23:59 KST = 아직.
      expect(
        blindReviewTargetsOf(_three(now: DateTime.utc(2026, 8, 31, 14, 59))),
        isEmpty,
      );
      expect(
        blindReviewTargetsOf(_three(now: DateTime.utc(2026, 8, 31, 15))),
        hasLength(3),
      );
    });

    test('한 결정 여러 의도 = 카드 1장(머리 = 첫 의도 · 첫 주문 = 가장 이른 전송)', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          _intent(
            'i_b',
            decision: _c28,
            created: '2026-08-11T05:31:00Z',
            orders: <JournalOrderFact>[
              _order('2026-08-11:B0029', '2026-08-11T05:35:00Z'),
            ],
          ),
          ..._c28Intents(),
        ],
        decisions: <JournalDecisionFact>[_decision(_c28, journal: 'jr_28')],
        notes: <JournalNoteFact>[_note('jr_28')],
      );
      final List<BlindReviewTarget> t = blindReviewTargetsOf(f);
      expect(t.single.entry.entryId, 'i_0028');
      expect(t.single.firstOrderAt, _t('2026-08-11T05:35:00Z'));
    });

    test('저널 is_deviation = 0 · 결정 기록만 있고 주문 없음 = 대상 아님', () {
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[..._c28Intents()],
        decisions: <JournalDecisionFact>[
          _decision(_c28, journal: 'jr_28'),
          _decision('d_noorder', journal: 'jr_x'),
        ],
        notes: <JournalNoteFact>[
          _note('jr_28', deviation: false),
          _note('jr_x'),
        ],
      );
      expect(blindReviewTargetsOf(f), isEmpty);
    });
  });

  group('큐 · 카드(01 §16 · C-43 데이터 쪽)', () {
    final Map<String, Object?> row0 = _rows('m6/blind_review_queue_3.json')[0];
    final ListResult<BlindReviewCard> q = blindReviewQueueOf(_three());

    test('표본 글자 — 머리 · 안내 · 저널 상태 · 문항 키 · 글자 · 선택지 · 기준 줄 꼴 · 근거 줄 ② ⑤ 꼴', () {
      final BlindReviewCard c = q.rows.first;
      final Map<String, Object?> j = c.toJson();
      expect(j['title_text'], row0['title_text']);
      expect(j['prompt_text'], row0['prompt_text']);
      expect(j['journal_state_label'], row0['journal_state_label']);
      final List<Map<String, Object?>> fq =
          (row0['questions']! as List<Object?>).cast<Map<String, Object?>>();
      final List<Map<String, Object?>> eq = (j['questions']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(eq.map((Map<String, Object?> x) => x['question_id']), <Object?>[
        for (final Map<String, Object?> x in fq) x['question_id'],
      ]);
      expect(eq.map((Map<String, Object?> x) => x['text']), <Object?>[
        for (final Map<String, Object?> x in fq) x['text'],
      ]);
      expect(
        jsonEncode(<Object?>[
          for (final Map<String, Object?> x in eq) x['choices'],
        ]),
        jsonEncode(<Object?>[
          for (final Map<String, Object?> x in fq) x['choices'],
        ]),
      );
      // ⑤ = 표본 글자 그대로(같은 시각) · ② = «이탈 기록: » + 이탈 배지 글자 · ①③④ = 원장 원천 없음 → 줄 부재.
      expect(eq[4]['evidence_text'], fq[4]['evidence_text']);
      expect(eq[1]['evidence_text'], '이탈 기록: ${c.deviation.label}');
      expect(
        <Object?>[
          eq[0]['evidence_text'],
          eq[2]['evidence_text'],
          eq[3]['evidence_text'],
        ],
        <Object?>[null, null, null],
      );
      expect(c.asOf.label, '리뷰 기준 2026-09-01');
      expect(
        (row0['as_of']! as Map<String, Object?>)['label'],
        '리뷰 기준 2026-08-31',
      );
      expect(c.asOf.staleAfter, kJournalStaleAfter);
    });

    test('🔴 행 결과 = 늘 null · 행 asOf = 봉투 · hasMore false · 빈 문장 없음(행 있음) · 행 수 = 배지 n', () {
      expect(q.rows.every((BlindReviewCard c) => c.result == null), true);
      expect(q.rows.every((BlindReviewCard c) => c.asOf == q.asOf), true);
      expect(
        (q.hasMore, q.emptyLabel, q.emptyKind),
        (false, null, EmptyKind.noData),
      );
      final JournalTimelineBadge b = journalTimelineBadgesOf(_three()).single;
      expect(b.label, '리뷰 대기 ${q.rows.length}건');
    });

    test(
      '🔴 blind — 채점 전 카드 전 문자열에 금액 · 백분율 · 손익 낱말 0 · 앱 안 링크 0(K8 · C-43 ③ ⑥)',
      () {
        for (final BlindReviewCard c in q.rows) {
          for (final String s in _strings(jsonDecode(jsonEncode(c)))) {
            expect(_money.hasMatch(s), false, reason: s);
            expect(_pct.hasMatch(s), false, reason: s);
            expect(_pnl.hasMatch(s), false, reason: s);
            expect(s.startsWith('aaq://'), false, reason: s);
          }
        }
      },
    );

    test('🔴 문맥 = J-1 일지 행 칩 · 이탈 배지 그대로(C-43 ⑦ⓒ) · 저널 = J-3R 본문 그대로(⑦ⓑ)', () {
      final JournalFacts f = _three();
      final Map<String, TradeJournalEntry> rows = <String, TradeJournalEntry>{
        for (final TradeJournalEntry e in journalEntriesOf(f))
          e.decision.decisionId: e,
      };
      for (final BlindReviewCard c in q.rows) {
        final TradeJournalEntry e = rows[c.decisionId]!;
        expect(c.contextChips, e.reasons);
        expect(c.deviation, e.deviation);
        expect(c.journal, decisionJournalVmOf(f, c.decisionId).body);
        expect(c.journal, isNotNull);
      }
      expect(q.rows[1].journal!.note, isNull);
    });

    test('카드 1건 = 큐 행 그대로(C-43 ④) · 모르는 · 대상 아닌 결정 = 실패', () {
      final JournalFacts f = _three();
      for (final BlindReviewCard c in q.rows) {
        expect(blindReviewCardOf(f, c.decisionId), c);
      }
      expect(() => blindReviewCardOf(f, 'd_none'), throwsStateError);
      expect(() => blindReviewCardOf(f, 'd_rule'), throwsStateError);
      expect(() => blindReviewCardOf(f, 'd_open'), throwsStateError);
      expect(() => blindReviewCardOf(f, 'd_sep'), throwsStateError);
    });

    test('주문 없는 결정 = ⑤ 근거 줄 부재 · 매도 머리 = «매도 결정»', () {
      final BlindReviewCard mf4 = q.rows[2];
      expect(mf4.titleText, '2026-08-27 · 411060 ACE 미국30년국채 · 매도 결정');
      expect(mf4.questions[4].evidenceText, isNull);
    });

    test('빈 LIVE 큐 = 표본 빈 문장 그대로(NO_DATA)', () {
      final ListResult<BlindReviewCard> e = blindReviewQueueOf(_facts());
      final Map<String, Object?> fx = _fx('m6/blind_review_queue_empty.json');
      expect(e.rows, isEmpty);
      expect(
        (e.emptyKind.wire, e.emptyLabel, e.hasMore),
        (fx['empty_kind'], fx['empty_label'], fx['has_more']),
      );
    });
  });

  group('J-1 배지(06 M1-25 ① · 표본 journal_badges_2)', () {
    test('🔴 미해소 2 + 리뷰 대기 3 = 표본 두 행 그대로(차례 · 글자 · 색 · 링크)', () {
      final JournalFacts base = _three();
      final JournalFacts f = _facts(
        intents: <JournalIntentFact>[
          ...base.intents,
          _intent('i_u1', decision: 'D_u1', status: 'UNKNOWN'),
          _intent('i_u2', decision: 'D_u2', status: 'UNKNOWN'),
        ],
        decisions: base.decisions.values.toList(),
        notes: base.notes.values.toList(),
      );
      expect(journalTimelineBadgesOf(f), <JournalTimelineBadge>[
        for (final Map<String, Object?> r in _rows('m6/journal_badges_2.json'))
          JournalTimelineBadge.fromJson(r),
      ]);
    });

    test('본문 미등록 = 배지는 있고 링크 없음 · 대상 0 = 리뷰 배지 부재(«0건» 금지)', () {
      final JournalFacts f = _three(
        hasBody: (String r) => r != AppRoutes.journalBlindReview,
      );
      expect(journalTimelineBadgesOf(f).single.deepLink, isNull);
      expect(journalTimelineBadgesOf(_facts(intents: _c28Intents())), isEmpty);
    });
  });

  group('점수 제출 판정 · 과정 점수 · 접수증 글자(06 M1-25 ④ ⑤ · 03_실행 §8-3)', () {
    final BlindReviewCard c = blindReviewQueueOf(_three()).rows.first;
    Map<String, int> all(int s) => <String, int>{
      for (final BlindReviewQuestion q in c.questions) q.questionId: s,
    };
    BlindReviewScore score(Map<String, int> a, {String? id}) =>
        BlindReviewScore(decisionId: id ?? c.decisionId, answers: a);

    test('받음 = 전 문항 · 선택지 점수', () {
      expect(
        blindReviewRejectOf(c, score(all(1)), alreadyScored: false),
        isNull,
      );
      expect(
        blindReviewRejectOf(
          c,
          score(<String, int>{...all(0), BlindReviewQuestionIds.pitInput: 1}),
          alreadyScored: false,
        ),
        isNull,
      );
    });

    test('🔴 ANSWERS_INVALID — 빠진 · 모르는 문항 · 선택지에 없는 점수 · 다른 결정', () {
      final Map<String, int> missing = all(1)
        ..remove(BlindReviewQuestionIds.writtenAtDecision);
      for (final BlindReviewScore s in <BlindReviewScore>[
        score(missing),
        score(<String, int>{...missing, 'EMOTION': 1}),
        score(<String, int>{...all(1), BlindReviewQuestionIds.pitInput: 2}),
        score(all(1), id: 'd_mf_0002'),
        score(const <String, int>{}),
      ]) {
        expect(
          blindReviewRejectOf(c, s, alreadyScored: false),
          BlindReviewRejectCodes.answersInvalid,
          reason: '${s.answers}',
        );
      }
    });

    test('🔴 ALREADY_SCORED = 답보다 먼저(먼저 집행된 채점이 이긴다 · K12)', () {
      expect(
        blindReviewRejectOf(c, score(all(1)), alreadyScored: true),
        BlindReviewRejectCodes.alreadyScored,
      );
      expect(
        blindReviewRejectOf(
          c,
          score(const <String, int>{}),
          alreadyScored: true,
        ),
        BlindReviewRejectCodes.alreadyScored,
      );
    });

    test('과정 점수 = 충족 개수 매핑(5 → 5 · … · 0~1 → 1) · 글자 = 표본(4점 · 3점)', () {
      final List<String> ids = <String>[
        for (final BlindReviewQuestion q in c.questions) q.questionId,
      ];
      expect(
        <int>[
          for (int met = 0; met <= 5; met++)
            blindReviewProcessScoreOf(<String, int>{
              for (int i = 0; i < ids.length; i++) ids[i]: i < met ? 1 : 0,
            }),
        ],
        <int>[1, 1, 2, 3, 4, 5],
      );
      String pst(String file) =>
          (_rows('m6/$file').single['result']!
                  as Map<String, Object?>)['process_score_text']!
              as String;
      expect(
        BlindReviewTexts.processScore(4),
        pst('blind_review_card_revealed.json'),
      );
      expect(
        BlindReviewTexts.processScore(3),
        pst('blind_review_card_revealed_open.json'),
      );
      expect(kBlindReviewGoodScore, 4);
    });

    test('접수증 글자 = 표본 receipts_6(기록 · 거부 두 사유) · 사전 밖 = 실패', () {
      final List<Map<String, Object?>> r = _rows(
        'm6/blind_review_receipts_6.json',
      );
      String label(String state, [String? code]) =>
          r.firstWhere(
                (Map<String, Object?> x) =>
                    x['state'] == state && x['reject_reason_code'] == code,
              )['state_label']!
              as String;
      expect(blindReviewStateLabelOf(null), label('EXECUTED'));
      for (final String code in BlindReviewRejectCodes.values) {
        expect(blindReviewStateLabelOf(code), label('REJECTED', code));
      }
      expect(
        () => blindReviewStateLabelOf('JOURNAL_ALREADY_EXISTS'),
        throwsArgumentError,
      );
    });
  });
}
