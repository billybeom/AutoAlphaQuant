// 🆕 R280 — `M5-13` 원장 실사 해소 게이트 엔진 몫(01 §8 미결 226 · 계약 v1.37 §46 K318~K322 · 표본 `m5/self_audit_resolve_*` ·
// `m5/held_review_results`).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden/calendar_fixture.dart';

List<Map<String, dynamic>> _rows(String rel) => <Map<String, dynamic>>[
  for (final Object? r
      in (jsonDecode(
            File('../domain_contracts/fixtures/$rel').readAsStringSync(),
          ) as Map<String, dynamic>)['rows']
          as List<dynamic>)
    r! as Map<String, dynamic>,
];

final ExchangeCalendar _kr = frozenCalendar(Market.kr);

const List<String> _accounts = <String>['일반', '연금저축'];

String _strip(String s) => s.replaceFirst('(합성) ', '');

StoredLedgerDiff _diff(
  String id, {
  LedgerAxis axis = LedgerAxis.quantity,
  String alias = '연금저축',
  String asOf = '2026-08-31',
  DiffStatus status = DiffStatus.open,
  LedgerPair pair = LedgerPair.canonSelfReport,
}) => StoredLedgerDiff(
  diffId: id,
  pair: pair,
  axis: axis,
  authoredDate: TradeDate(asOf),
  delta: jsonEncode(<String, Object?>{
    'account': alias,
    'candidates': kSelfReportDiffCandidates,
  }),
  deltaLabel: '133690 수량 −3주 (원장 245 / 자가 보고 242)',
  severity: DiffSeverity.observational,
  status: status,
  detectedAtUtc: DateTime.utc(2026, 8, 31, 3, 10),
  applicable: true,
);

StoredHeldCommand _held(
  String id,
  int minute, {
  String kind = 'RECORD_MANUAL_FILL',
}) => StoredHeldCommand(
  commandId: id,
  kind: kind,
  ingestedAtUtc: DateTime.utc(2026, 9, 2, 1, minute),
);

final DateTime _now = DateTime.utc(2026, 9, 1, 9);

void main() {
  group('ⓕ 자가 보고 차이 행(K320)', () {
    test(
      '경로 = AUTO 그대로 · 글자 «다시 실사로 해소» · 폰 조치 «다시 실사하기» = 그 달 · 그 계좌 L-3',
      () {
        final LedgerDiffRow r = ledgerDiffRowOf(_diff('ld_sr_1'));
        expect(r.route, RepairRoute.auto);
        expect(r.routeLabel, '다시 실사로 해소');
        expect(r.actionLink?.label, '다시 실사하기');
        expect(r.actionLink?.deepLink, 'aaq://ledger/self-report/2026-08/연금저축');
        expect(r.actionLink!.deepLink, isNot(contains('repair-wizard')));
      },
    );

    test('뷰어 · 닫힌 행 · 별칭 없음 · 링크 못 지음 = 조치 0(글자는 같다)', () {
      expect(ledgerDiffRowOf(_diff('a'), phone: false).actionLink, isNull);
      final LedgerDiffRow closed = ledgerDiffRowOf(
        _diff('b', status: DiffStatus.resolved),
      );
      expect(closed.actionLink, isNull);
      expect(closed.routeLabel, '다시 실사로 해소');
      expect(ledgerDiffRowOf(_diff('c', alias: 'a/b')).actionLink, isNull);
      final StoredLedgerDiff noAlias = StoredLedgerDiff(
        diffId: 'd',
        pair: LedgerPair.canonSelfReport,
        axis: LedgerAxis.quantity,
        authoredDate: const TradeDate('2026-08-31'),
        delta: '{}',
        deltaLabel: 'x',
        severity: DiffSeverity.observational,
        status: DiffStatus.open,
        detectedAtUtc: _now,
        applicable: true,
      );
      expect(ledgerDiffRowOf(noAlias).actionLink, isNull);
    });

    test('다른 쌍 = 옛 글자 그대로(관측 = «자동 재동기화» · 링크 0)', () {
      final LedgerDiffRow r = ledgerDiffRowOf(
        _diff('x', pair: LedgerPair.canonBroker),
      );
      expect(r.routeLabel, '자동 재동기화');
      expect(r.actionLink, isNull);
    });

    test('L-3 결과 안 = 행 링크 0(자기 자신으로 가는 고리 방지) · 경로 글자는 같다', () {
      final SelfReportResult res = selfReportResultOf(
        diffs: <StoredLedgerDiff>[_diff('ld_sr_1')],
        yyyyMm: '2026-08',
        nextAlias: null,
        resolveRegistered: true,
        cashSkipped: null,
      );
      expect(res.diffs.single.actionLink, isNull);
      expect(res.diffs.single.routeLabel, '다시 실사로 해소');
      expect(res.resolveLink?.deepLink, AppRoutes.m5SelfAuditResolve);
    });

    test('ⓗ 정정한 옛 표본 `m6/self_report_diff_result` = 엔진 경로 · 글자와 같다', () {
      final Map<String, dynamic> d =
          ((_rows(FixturePaths.m6SelfReportDiffResult).single['result']
                          as Map<String, dynamic>)['diffs']
                      as List<dynamic>)
                  .single
              as Map<String, dynamic>;
      final LedgerDiffRow r = ledgerDiffRowOf(_diff('ld_sr_0001'));
      expect(d['route'], r.route.wire);
      expect(d['route_label'], r.routeLabel);
    });
  });

  group('다시 실사(K320)', () {
    test('결과만 = 실사 있음 ∧ 열린 차이 없음 · 열린 차이 있으면 다시 연다', () {
      expect(
        selfReportAlreadyAuditedOf(audited: false, openDiffs: false),
        isFalse,
      );
      expect(
        selfReportAlreadyAuditedOf(audited: true, openDiffs: false),
        isTrue,
      );
      expect(
        selfReportAlreadyAuditedOf(audited: true, openDiffs: true),
        isFalse,
      );
      expect(
        selfReportAlreadyAuditedOf(audited: false, openDiffs: true),
        isFalse,
      );
    });
  });

  group('ⓑ 두 카운터(K321 ② ③)', () {
    test('미처리 갭 = 덮이지 않은 가장 이른 만료 마감 뒤 · 안내가 열린 거래일만', () {
      // 마감 09-01 뒤 거래일 = 09-02 · 03 · 04 · 07 · 08 · 09 · 10 — 안내가 열린 날 = 09-04 · 07 · 08(창 둘째)만.
      final int? n = selfAuditUnprocessedGapOf(
        lapsed: const <LapsedAdvice>[
          LapsedAdvice(deadline: TradeDate('2026-09-01'), accountAlias: '일반'),
        ],
        windows: const <AdviceWindow>[
          AdviceWindow(
            from: TradeDate('2026-08-25'),
            until: TradeDate('2026-09-01'),
          ),
          AdviceWindow(
            from: TradeDate('2026-09-04'),
            until: TradeDate('2026-09-08'),
          ),
        ],
        latestZeroError: const <String, TradeDate>{},
        accounts: _accounts,
        today: const TradeDate('2026-09-10'),
        kr: _kr,
      );
      expect(n, 3);
    });

    test('0오차 실사 기준일 ≥ 마감 = 덮임 → 0 · 계좌 없는 안내 = 대응 계좌 전부가 덮어야', () {
      const List<AdviceWindow> w = <AdviceWindow>[
        AdviceWindow(
          from: TradeDate('2026-08-03'),
          until: TradeDate('2026-09-30'),
        ),
      ];
      int? gap(Map<String, TradeDate> z, String? alias) =>
          selfAuditUnprocessedGapOf(
            lapsed: <LapsedAdvice>[
              LapsedAdvice(
                deadline: const TradeDate('2026-08-20'),
                accountAlias: alias,
              ),
            ],
            windows: w,
            latestZeroError: z,
            accounts: _accounts,
            today: const TradeDate('2026-08-31'),
            kr: _kr,
          );
      expect(
        gap(const <String, TradeDate>{'일반': TradeDate('2026-08-20')}, '일반'),
        0,
      );
      expect(
        gap(const <String, TradeDate>{'일반': TradeDate('2026-07-31')}, '일반'),
        7,
      );
      expect(
        gap(const <String, TradeDate>{'연금저축': TradeDate('2026-08-31')}, '일반'),
        7,
      );
      expect(
        gap(const <String, TradeDate>{'일반': TradeDate('2026-08-31')}, null),
        7,
      );
      expect(
        gap(const <String, TradeDate>{
          '일반': TradeDate('2026-08-31'),
          '연금저축': TradeDate('2026-08-31'),
        }, null),
        0,
      );
    });

    test('🔴 덮이지 않은 만료가 여럿 = 가장 이른 마감부터 센다', () {
      // 마감 09-01 · 09-07(둘 다 일반 · 덮임 0) · 창 = 09-02 ~ 09-10 → 09-01 뒤 = 09-02 · 03 · 04 · 07 · 08 · 09 · 10 = 7
      // (09-07 부터면 08 · 09 · 10 = 3).
      expect(
        selfAuditUnprocessedGapOf(
          lapsed: const <LapsedAdvice>[
            LapsedAdvice(deadline: TradeDate('2026-09-07'), accountAlias: '일반'),
            LapsedAdvice(deadline: TradeDate('2026-09-01'), accountAlias: '일반'),
          ],
          windows: const <AdviceWindow>[
            AdviceWindow(
              from: TradeDate('2026-09-02'),
              until: TradeDate('2026-09-10'),
            ),
          ],
          latestZeroError: const <String, TradeDate>{},
          accounts: _accounts,
          today: const TradeDate('2026-09-10'),
          kr: _kr,
        ),
        7,
      );
    });

    test('만료 안내 0 = 0 · 달력 밖 = null(세지 않는다)', () {
      expect(
        selfAuditUnprocessedGapOf(
          lapsed: const <LapsedAdvice>[],
          windows: const <AdviceWindow>[],
          latestZeroError: const <String, TradeDate>{},
          accounts: _accounts,
          today: const TradeDate('2026-09-10'),
          kr: _kr,
        ),
        0,
      );
      expect(
        selfAuditUnprocessedGapOf(
          lapsed: const <LapsedAdvice>[
            LapsedAdvice(deadline: TradeDate('2026-09-01'), accountAlias: '일반'),
          ],
          windows: const <AdviceWindow>[
            AdviceWindow(
              from: TradeDate('2026-09-01'),
              until: TradeDate('2099-12-31'),
            ),
          ],
          latestZeroError: const <String, TradeDate>{},
          accounts: _accounts,
          today: const TradeDate('2099-12-31'),
          kr: _kr,
        ),
        isNull,
      );
    });

    test('실사 갭 = 가장 큰 계좌 · 같으면 계좌 차례 앞 · 기록 0 = null', () {
      final SelfAuditGap? g = selfAuditGapOf(
        accounts: _accounts,
        lastVerified: const <String, TradeDate>{
          '일반': TradeDate('2026-06-30'),
          '연금저축': TradeDate('2026-07-31'),
        },
        today: const TradeDate('2026-09-01'),
      );
      expect((g?.accountAlias, g?.days), ('일반', 63));
      final SelfAuditGap? tie = selfAuditGapOf(
        accounts: _accounts,
        lastVerified: const <String, TradeDate>{
          '일반': TradeDate('2026-08-31'),
          '연금저축': TradeDate('2026-08-31'),
        },
        today: const TradeDate('2026-09-01'),
      );
      expect((tie?.accountAlias, tie?.days), ('일반', 1));
      expect(
        selfAuditGapOf(
          accounts: _accounts,
          lastVerified: const <String, TradeDate>{},
          today: const TradeDate('2026-09-01'),
        ),
        isNull,
      );
    });

    test('카운터 줄 = 투자 안내 2줄(차례 미처리 → 실사) · 그 밖 0줄 · 신뢰 시각 모름 = 세지 않았다는 2줄', () {
      final List<String> l = selfAuditCounterLinesOf(
        operatingMode: OperatingMode.advisory,
        trustedKnown: true,
        unprocessed: 6,
        auditGap: const SelfAuditGap('일반', 63),
      );
      expect(l, <String>[
        '미처리 갭 — 기록 없이 닫힌 안내 뒤 6거래일(안내가 없던 날은 세지 않습니다)',
        '실사 갭 — 일반 계좌 마지막 실사 뒤 63일',
      ]);
      expect(
        selfAuditCounterLinesOf(
          operatingMode: OperatingMode.advisory,
          trustedKnown: true,
          unprocessed: 0,
          auditGap: null,
        ),
        <String>['미처리 갭 — 0거래일', '실사 갭 — 아직 실사 기록이 없습니다'],
      );
      expect(
        selfAuditCounterLinesOf(
          operatingMode: OperatingMode.autoTrade,
          trustedKnown: true,
          unprocessed: 6,
          auditGap: const SelfAuditGap('일반', 1),
        ),
        isEmpty,
      );
      expect(
        selfAuditCounterLinesOf(
          operatingMode: null,
          trustedKnown: true,
          unprocessed: 0,
          auditGap: null,
        ),
        isEmpty,
      );
      expect(
        selfAuditCounterLinesOf(
          operatingMode: OperatingMode.advisory,
          trustedKnown: false,
          unprocessed: 3,
          auditGap: const SelfAuditGap('일반', 1),
        ),
        <String>[
          SelfAuditResolveTexts.unprocessedUnknown,
          SelfAuditResolveTexts.auditGapUnknown,
        ],
      );
      expect(
        selfAuditCounterLinesOf(
          operatingMode: OperatingMode.advisory,
          trustedKnown: true,
          unprocessed: null,
          auditGap: null,
        ).first,
        SelfAuditResolveTexts.unprocessedUnknown,
      );
    });
  });

  group('ⓒ 플래그 발동 · 해제(K321 ① ④)', () {
    test('🔴 문턱 null(미결 118 ⓐ 대기) = 발동 0 · 투자 안내 ∧ 갭 ≥ 문턱만', () {
      for (final int gap in <int>[0, 5, 1000]) {
        expect(
          adviceLedgerUnverifiedRaiseOf(
            operatingMode: OperatingMode.advisory,
            unprocessedGap: gap,
            thresholdTradingDays: null,
          ),
          isFalse,
        );
      }
      expect(
        adviceLedgerUnverifiedRaiseOf(
          operatingMode: OperatingMode.advisory,
          unprocessedGap: 3,
          thresholdTradingDays: 3,
        ),
        isTrue,
      );
      expect(
        adviceLedgerUnverifiedRaiseOf(
          operatingMode: OperatingMode.advisory,
          unprocessedGap: 2,
          thresholdTradingDays: 3,
        ),
        isFalse,
      );
      expect(
        adviceLedgerUnverifiedRaiseOf(
          operatingMode: OperatingMode.autoTrade,
          unprocessedGap: 9,
          thresholdTradingDays: 3,
        ),
        isFalse,
      );
      expect(
        adviceLedgerUnverifiedRaiseOf(
          operatingMode: OperatingMode.advisory,
          unprocessedGap: null,
          thresholdTradingDays: 3,
        ),
        isFalse,
      );
      expect(
        () => adviceLedgerUnverifiedRaiseOf(
          operatingMode: OperatingMode.advisory,
          unprocessedGap: 1,
          thresholdTradingDays: 0,
        ),
        throwsArgumentError,
      );
    });

    test('해제 = 대응 계좌 전부 발동한 날 이후 기준일 0오차 · 계좌 0 = 풀지 않음', () {
      bool rel(Map<String, TradeDate> z, {List<String> accounts = _accounts}) =>
          adviceLedgerUnverifiedReleaseOf(
            flagSetDay: const TradeDate('2026-09-01'),
            accounts: accounts,
            latestZeroError: z,
          );
      expect(rel(const <String, TradeDate>{}), isFalse);
      expect(
        rel(const <String, TradeDate>{
          '일반': TradeDate('2026-09-30'),
          '연금저축': TradeDate('2026-08-31'),
        }),
        isFalse,
      );
      expect(
        rel(const <String, TradeDate>{
          '일반': TradeDate('2026-09-30'),
          '연금저축': TradeDate('2026-09-30'),
        }),
        isTrue,
      );
      expect(
        rel(const <String, TradeDate>{
          '일반': TradeDate('2026-09-01'),
          '연금저축': TradeDate('2026-09-01'),
        }),
        isTrue,
      );
      expect(
        rel(const <String, TradeDate>{}, accounts: const <String>[]),
        isFalse,
      );
    });

    test(
      '해제에 필요한 달 = 기준일 ≥ 발동일인 첫 달 · 실사 링크 = 아직 0오차 없는 계좌 · 행 링크와 겹치면 뺀다',
      () {
        expect(
          selfAuditReleaseMonthOf(const TradeDate('2026-09-01'), _kr),
          '2026-09',
        );
        // 08-31(월) = 8월 마지막 세션 → 8월 기준일 = 발동일 → 8월.
        expect(
          selfAuditReleaseMonthOf(const TradeDate('2026-08-31'), _kr),
          '2026-08',
        );
        // 토요일 발동(10-31) → 10월 기준일(10-30) < 발동일 → 11월.
        expect(
          selfAuditReleaseMonthOf(const TradeDate('2026-10-31'), _kr),
          '2026-11',
        );
        final List<LinkAction> links = selfAuditLinksOf(
          flagSetDay: const TradeDate('2026-09-01'),
          accounts: _accounts,
          latestZeroError: const <String, TradeDate>{
            '연금저축': TradeDate('2026-09-30'),
          },
          kr: _kr,
        );
        expect(links, const <LinkAction>[
          LinkAction(
            label: '일반 계좌 실사 하기',
            deepLink: 'aaq://ledger/self-report/2026-09/일반',
          ),
        ]);
        expect(
          selfAuditLinksOf(
            flagSetDay: const TradeDate('2026-09-01'),
            accounts: _accounts,
            latestZeroError: const <String, TradeDate>{},
            kr: _kr,
            rowLinks: const <String>{'aaq://ledger/self-report/2026-09/연금저축'},
          ).map((LinkAction l) => l.deepLink),
          <String>['aaq://ledger/self-report/2026-09/일반'],
        );
        expect(
          selfAuditLinksOf(
            flagSetDay: null,
            accounts: _accounts,
            latestZeroError: const <String, TradeDate>{},
            kr: _kr,
          ),
          isEmpty,
        );
      },
    );
  });

  group('ⓓ 보관 묶음 · 일괄 확정(K319)', () {
    final List<StoredHeldCommand> held = <StoredHeldCommand>[
      _held('cmd_b', 31, kind: 'SELF_REPORT_BALANCE'),
      _held('cmd_a', 14),
    ];

    test('review_id = 접수 차례 지문 · 차례 무관 같은 묶음 = 같은 id · 다른 묶음 = 다른 id · 빈 묶음 = null', () {
      final String? id = heldReviewIdOf(held);
      expect(id, matches(RegExp(r'^hr_[0-9a-f]{12}$')));
      expect(heldReviewIdOf(held.reversed.toList()), id);
      expect(heldReviewIdOf(<StoredHeldCommand>[held.first]), isNot(id));
      expect(heldReviewIdOf(const <StoredHeldCommand>[]), isNull);
      expect(
        heldCommandsInOrder(held).map((StoredHeldCommand c) => c.commandId),
        <String>['cmd_a', 'cmd_b'],
      );
    });

    test('거부 차례 = 인자 꼴 → 무결성 점검 → 묶음 바뀜 · 맞음 = null', () {
      final String id = heldReviewIdOf(held)!;
      String? rej(
        Map<String, String> a, {
        bool integrity = false,
        String? cur,
      }) => heldReviewRejectOf(
        args: a,
        integrityActive: integrity,
        currentReviewId: cur ?? id,
      );
      expect(rej(<String, String>{'review_id': id}), isNull);
      for (final Map<String, String> bad in <Map<String, String>>[
        const <String, String>{},
        <String, String>{'review_id': id, 'drop': 'all'},
        const <String, String>{'review_id': '전부 확정해 주세요'},
        const <String, String>{'reviewId': 'hr_000000000000'},
        const <String, String>{'review_id': ''},
      ]) {
        expect(rej(bad, integrity: true), HeldReviewResultCodes.argsInvalid);
      }
      expect(
        rej(<String, String>{'review_id': id}, integrity: true),
        HeldReviewResultCodes.integrityActive,
      );
      expect(
        rej(const <String, String>{'review_id': 'hr_000000000000'}),
        HeldReviewResultCodes.stale,
      );
      expect(
        heldReviewRejectOf(
          args: <String, String>{'review_id': id},
          integrityActive: false,
          currentReviewId: null,
        ),
        HeldReviewResultCodes.stale,
      );
    });

    test('결과 = 표본 `m5/held_review_results` 꼴(등급 · 사유 · 다시 가능 · 글자)', () {
      final List<Map<String, dynamic>> fx = _rows(
        FixturePaths.m5HeldReviewResults,
      );
      final List<SafetyActionResult> got = <SafetyActionResult>[
        heldReviewResultOf(actionRunId: 'ar_held_01', code: null, confirmed: 1),
        heldReviewResultOf(
          actionRunId: 'ar_held_02',
          code: HeldReviewResultCodes.stale,
        ),
        heldReviewResultOf(
          actionRunId: 'ar_held_03',
          code: HeldReviewResultCodes.integrityActive,
        ),
        heldReviewResultOf(
          actionRunId: 'ar_held_04',
          code: HeldReviewResultCodes.argsInvalid,
        ),
      ];
      for (int i = 0; i < fx.length; i++) {
        final SafetyActionResult want = SafetyActionResult.fromJson(fx[i]);
        expect(got[i].id, want.id);
        expect(got[i].level, want.level);
        expect(got[i].reasonCode, want.reasonCode);
        expect(got[i].retryable, want.retryable);
        expect(got[i].handoffRoute, isNull);
        expect(got[i].headline, _strip(want.headline));
      }
      expect(
        () => heldReviewResultOf(actionRunId: 'x', code: 'NOPE'),
        throwsArgumentError,
      );
    });

    test('보관 행 글자 = 종류 · 요약(다시 건넴 · 다시 제출) · 접수 시각 · 상태', () {
      final HeldCommandRow r = heldCommandRowOf(_held('cmd_a', 14));
      expect(r.kindLabel, '수기 체결 기록');
      expect(r.receivedAtText, '2026-09-02 10:14 접수');
      expect(r.stateLabel, '보관 — 무결성 점검 뒤 확정');
      expect(r.summaryText, SelfAuditResolveTexts.summaryResubmit);
      expect(
        heldCommandRowOf(_held('j', 1, kind: 'JOURNAL_DRAFT')).summaryText,
        SelfAuditResolveTexts.summaryReplay,
      );
      expect(
        SelfAuditResolveTexts.kindLabel('SELF_REPORT_BALANCE'),
        '정기 실사 제출',
      );
      expect(SelfAuditResolveTexts.kindLabel('NOT_A_KIND'), '기록 명령');
      for (final CommandKind k in CommandKind.values) {
        expect(SelfAuditResolveTexts.kindLabel(k.wire), isNot('기록 명령'));
      }
    });
  });

  group('ⓐ `M5-13` VM(K318 · 불변식 C-70 ②)', () {
    void invariants(SelfAuditResolveVm v) {
      expect(v.diffsEmptyLabel != null, v.diffs.isEmpty);
      expect(v.heldEmptyLabel != null, v.heldCommands.isEmpty);
      if (v.confirmHeld != null) {
        expect(v.heldCommands, isNotEmpty);
        expect(v.heldBlockedText, isNull);
        expect(v.confirmHeld!.id, SafetyActionId.heldCommandsConfirm);
        expect(v.confirmHeld!.args.keys.toSet(), <String>{'review_id'});
      }
      if (v.heldBlockedText != null) {
        expect(v.confirmHeld, isNull);
        expect(v.heldCommands, isNotEmpty);
      }
      expect(<int>{0, 2}, contains(v.counterLines.length));
      for (final LedgerDiffRow r in v.diffs) {
        expect(r.pair, LedgerPair.canonSelfReport);
        expect(r.status, DiffStatus.open);
      }
      for (final LinkAction l in v.auditLinks) {
        expect(l.deepLink, startsWith('aaq://ledger/self-report/'));
      }
      expect(v.releaseRuleText, contains('수동 해제는 없습니다'));
    }

    test('표본 open 꼴 — 플래그 · 카운터 2 · 차이(수량 → 현금) · 실사 링크 · 보관 1 · 확정', () {
      final SelfAuditResolveVm want = SelfAuditResolveVm.fromJson(
        _rows(FixturePaths.m5SelfAuditResolveOpen).single,
      );
      final List<String> counters = selfAuditCounterLinesOf(
        operatingMode: OperatingMode.advisory,
        trustedKnown: true,
        unprocessed: 6,
        auditGap: const SelfAuditGap('일반', 63),
      );
      final SelfAuditResolveVm v = selfAuditResolveVmOf(
        flagSetAtUtc: DateTime.utc(2026, 9, 1, 0, 30),
        counterLines: counters,
        openDiffs: <StoredLedgerDiff>[
          _diff('ld_sr_cash', axis: LedgerAxis.cash),
          _diff('ld_sr_qty'),
          _diff('ld_sr_closed', status: DiffStatus.resolved),
          _diff('ld_broker', pair: LedgerPair.canonBroker),
        ],
        auditLinks: const <LinkAction>[
          LinkAction(
            label: '일반 계좌 실사 하기',
            deepLink: 'aaq://ledger/self-report/2026-09/일반',
          ),
        ],
        held: <StoredHeldCommand>[_held('cmd_20260902_0101', 14)],
        integrityActive: false,
        nowUtc: _now,
      );
      invariants(v);
      expect(v.headline, _strip(want.headline));
      expect(v.level, want.level);
      expect(v.flagLine, _strip(want.flagLine));
      expect(v.releaseRuleText, _strip(want.releaseRuleText));
      expect(v.diffs.map((LedgerDiffRow r) => r.axis), <LedgerAxis>[
        LedgerAxis.quantity,
        LedgerAxis.cash,
      ]);
      expect(
        v.diffs.map((LedgerDiffRow r) => (r.routeLabel, r.actionLink?.label)),
        everyElement((
          want.diffs.first.routeLabel,
          want.diffs.first.actionLink!.label,
        )),
      );
      expect(
        v.heldCommands.single.stateLabel,
        want.heldCommands.single.stateLabel,
      );
      expect(
        v.heldCommands.single.receivedAtText,
        want.heldCommands.single.receivedAtText,
      );
      expect(
        v.heldCommands.single.kindLabel,
        want.heldCommands.single.kindLabel,
      );
      expect(v.confirmHeld?.label, want.confirmHeld?.label);
      expect(v.asOf.label, '실사 기준 2026-09-01 18:00');
      expect(v.asOf.label, want.asOf.label);
      expect(v.asOf.staleAfter, want.asOf.staleAfter);
    });

    test(
      '표본 held_blocked 꼴 — 무결성 점검 중 = 확정 null · 막힘 문장 · 머리 = 보관 · WATCH',
      () {
        final SelfAuditResolveVm want = SelfAuditResolveVm.fromJson(
          _rows(FixturePaths.m5SelfAuditResolveHeldBlocked).single,
        );
        final SelfAuditResolveVm v = selfAuditResolveVmOf(
          flagSetAtUtc: null,
          counterLines: selfAuditCounterLinesOf(
            operatingMode: OperatingMode.advisory,
            trustedKnown: true,
            unprocessed: 0,
            auditGap: const SelfAuditGap('일반', 1),
          ),
          openDiffs: const <StoredLedgerDiff>[],
          auditLinks: const <LinkAction>[],
          held: <StoredHeldCommand>[
            _held('cmd_20260902_0102', 31, kind: 'SELF_REPORT_BALANCE'),
            _held('cmd_20260902_0101', 14),
          ],
          integrityActive: true,
          nowUtc: _now,
        );
        invariants(v);
        expect(v.headline, _strip(want.headline));
        expect(v.level, want.level);
        expect(v.flagLine, _strip(want.flagLine));
        expect(v.confirmHeld, isNull);
        expect(v.heldBlockedText, _strip(want.heldBlockedText!));
        expect(v.diffsEmptyLabel, _strip(want.diffsEmptyLabel!));
        expect(
          v.heldCommands.map((HeldCommandRow h) => (h.commandId, h.kindLabel)),
          <(String, String)>[
            for (final HeldCommandRow h in want.heldCommands)
              (h.commandId, h.kindLabel),
          ],
        );
        expect(v.counterLines.first, want.counterLines.first);
      },
    );

    test('표본 clear 꼴 — 빈 문장 둘 · OK · 확정 · 막힘 0', () {
      final SelfAuditResolveVm want = SelfAuditResolveVm.fromJson(
        _rows(FixturePaths.m5SelfAuditResolveClear).single,
      );
      final SelfAuditResolveVm v = selfAuditResolveVmOf(
        flagSetAtUtc: null,
        counterLines: const <String>[],
        openDiffs: const <StoredLedgerDiff>[],
        auditLinks: const <LinkAction>[],
        held: const <StoredHeldCommand>[],
        integrityActive: false,
        nowUtc: _now,
      );
      invariants(v);
      expect(v.headline, _strip(want.headline));
      expect(v.level, want.level);
      expect(v.heldEmptyLabel, _strip(want.heldEmptyLabel!));
      expect(v.diffsEmptyLabel, _strip(want.diffsEmptyLabel!));
      expect(v.confirmHeld, isNull);
      expect(v.heldBlockedText, isNull);
    });

    test('머리 차례 = 플래그 → 보관(확정 기다림) → 차이 → 없음 · 플래그 섬에도 보관 확정은 선다', () {
      SelfAuditResolveVm vm({
        DateTime? flag,
        List<StoredHeldCommand> held = const <StoredHeldCommand>[],
        List<StoredLedgerDiff> diffs = const <StoredLedgerDiff>[],
      }) => selfAuditResolveVmOf(
        flagSetAtUtc: flag,
        counterLines: const <String>[],
        openDiffs: diffs,
        auditLinks: const <LinkAction>[],
        held: held,
        integrityActive: false,
        nowUtc: _now,
      );
      final SelfAuditResolveVm heldOnly = vm(
        held: <StoredHeldCommand>[_held('a', 1)],
      );
      expect(heldOnly.headline, '보관된 명령 1건 — 확정을 기다립니다');
      expect(heldOnly.level, UiLevel.watch);
      expect(heldOnly.confirmHeld?.label, '보관된 명령 1건 확정');
      final SelfAuditResolveVm diffOnly = vm(
        diffs: <StoredLedgerDiff>[_diff('d')],
      );
      expect(diffOnly.headline, '열린 자가 보고 차이 1건 — 다시 실사로 해소합니다');
      expect(diffOnly.level, UiLevel.watch);
      final SelfAuditResolveVm flagged = vm(
        flag: DateTime.utc(2026, 9, 1, 0, 30),
        held: <StoredHeldCommand>[_held('a', 1)],
      );
      expect(flagged.level, UiLevel.act);
      expect(flagged.confirmHeld, isNotNull);
      invariants(flagged);
    });

    test('🔴 보관 0 = 무결성 점검 중이어도 막힘 문장 0 · 확정 0(불변식 — 막힘 ⇒ 보관 있음)', () {
      final SelfAuditResolveVm v = selfAuditResolveVmOf(
        flagSetAtUtc: null,
        counterLines: const <String>[],
        openDiffs: const <StoredLedgerDiff>[],
        auditLinks: const <LinkAction>[],
        held: const <StoredHeldCommand>[],
        integrityActive: true,
        nowUtc: _now,
      );
      invariants(v);
      expect(v.heldBlockedText, isNull);
      expect(v.confirmHeld, isNull);
      expect(v.heldEmptyLabel, SelfAuditResolveTexts.heldEmpty);
    });

    test('🔴 수동 해제 칸 0 — VM 키 = 계약 13키(해제 · 버림 동작 키 없음)', () {
      final Map<String, Object?> j = selfAuditResolveVmOf(
        flagSetAtUtc: _now,
        counterLines: const <String>[],
        openDiffs: const <StoredLedgerDiff>[],
        auditLinks: const <LinkAction>[],
        held: <StoredHeldCommand>[_held('a', 1)],
        integrityActive: false,
        nowUtc: _now,
      ).toJson();
      expect(
        j.keys.any(
          (String k) => k.contains('release') && k != 'release_rule_text',
        ),
        isFalse,
      );
      expect(
        j.keys.any((String k) => k.contains('discard') || k.contains('drop')),
        isFalse,
      );
    });
  });
}
