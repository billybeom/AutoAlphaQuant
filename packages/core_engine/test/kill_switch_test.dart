// E13a — 킬스위치 · 재개(SPEC v2.40 04 §3-6 · 03운 카드 ④ · ④-R · 설계 13 §8 R56 K1~K8).
//
// 🔵 04 §3-6 시험 이름을 그대로 쓴다(앱판): test_resume_before_min_wait_blocked · test_resume_without_checklist_blocked ·
//    test_kill_file_deleted_but_wait_not_elapsed_still_blocked(→ 행 직접 수정) · test_kill_switch_cancels_open_orders ·
//    test_kill_switch_cancel_failure_keeps_block · v2.40 6종.
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final DateTime _act = DateTime.utc(2026, 11, 4, 1); // 한국 11-04 10:00
final DateTime _conf = DateTime.utc(2026, 11, 4, 1, 30); // 한국 10:30
final DateTime _eta = _conf.add(const Duration(hours: 48)); // 한국 11-06 10:30

KillSwitchRecord _rec({
  DateTime? activated,
  DateTime? confirmed,
  DateTime? cleared,
  String? decision,
  bool on = true,
}) => KillSwitchRecord(
  activatedAtUtc: on ? (activated ?? _act) : null,
  checklistConfirmedAtUtc: confirmed,
  clearedAtUtc: cleared,
  decisionId: decision,
  activatedByDeviceLabel: '내 폰',
);

ResumeChecklist _full({
  ResumeConditionStatus cond = ResumeConditionStatus.met,
}) {
  final List<ResumeItemAnswer> answers = <ResumeItemAnswer>[
    const ResumeItemAnswer(1, text: '월말 정기 리밸런싱'),
    const ResumeItemAnswer(2, emotion: '평온', intensity: 2, sleepHours: 7),
    const ResumeItemAnswer(3, scenario: ScenarioStatus.resolved),
    ResumeItemAnswer(4, condition: cond),
    const ResumeItemAnswer(5, acknowledged: true),
    const ResumeItemAnswer(6, acknowledged: true),
    const ResumeItemAnswer(
      7,
      decisionId: 'J-RESUME-1',
      rationaleBefore: '조건 충족',
      expectedOutcome: '규칙대로 운용',
      ruleCited: '04 §3-6',
    ),
  ];
  ResumeChecklist c = ResumeChecklist.empty;
  for (final ResumeItemAnswer a in answers) {
    final (ResumeChecklist? next, String? err) = c.accept(a);
    if (next == null) {
      expect(err, 'RESUME_CONDITION_UNMET');
      return c;
    }
    c = next;
  }
  return c;
}

class _Store implements KillSwitchStore {
  KillSwitchRecord row = const KillSwitchRecord();
  final List<(KillCancelReport, DateTime)> reports =
      <(KillCancelReport, DateTime)>[];
  bool failActivate = false;
  bool failReport = false;
  final List<String> calls = <String>[];

  @override
  Future<KillSwitchRecord> read() async => row;

  @override
  Future<KillSwitchRecord> activate({
    required DateTime atUtc,
    required String channel,
    String? deviceLabel,
  }) async {
    calls.add('activate');
    if (failActivate) throw StateError('disk');
    row = KillSwitchRecord(
      activatedAtUtc: row.activatedAtUtc ?? atUtc,
      checklistConfirmedAtUtc: row.checklistConfirmedAtUtc,
      activatedByDeviceLabel: row.activatedByDeviceLabel ?? deviceLabel,
    );
    return row;
  }

  @override
  Future<void> recordCancelReport(
    KillCancelReport report,
    DateTime atUtc,
  ) async {
    calls.add('report');
    if (failReport) throw StateError('disk');
    reports.add((report, atUtc));
  }
}

class _Broker implements OrderBroker {
  _Broker(this.script);
  final Map<String, Object> script; // 주문번호 → 결과 · 예외
  final List<String> cancelled = <String>[];

  @override
  Future<BrokerSubmitResult> cancel(String brokerOrderNo) async {
    cancelled.add(brokerOrderNo);
    final Object r =
        script[brokerOrderNo] ??
        BrokerAccepted(
          odno: 'C-$brokerOrderNo',
          orderDate: const TradeDate('2026-11-04'),
        );
    if (r is BrokerSubmitResult) return r;
    Error.throwWithStackTrace(r, StackTrace.current);
  }

  @override
  Future<BrokerSubmitResult> submit(BrokerOrderRequest request) =>
      throw UnimplementedError();

  @override
  Future<List<DailyFillRow>> dailyFills(TradeDate orderDate) =>
      throw UnimplementedError();

  @override
  Future<Decimal> orderableCashKrw() => throw UnimplementedError();
}

KillCancelCandidate _cand(
  String id,
  IntentStatus st, {
  String account = 'main',
  String? no,
  int rem = 1,
}) => KillCancelCandidate(
  intentId: id,
  account: account,
  symbol: '133690',
  status: st,
  brokerOrderNo: no ?? '20261104:$id',
  remainingQty: rem,
);

void main() {
  group('활성 판정(K1 · v2.40 식)', () {
    test('꺼짐 · 발동만 · 확인만 = 활성', () {
      expect(killSwitchActive(_rec(on: false)), isFalse);
      expect(killSwitchActive(_rec()), isTrue);
      expect(killSwitchActive(_rec(confirmed: _conf)), isTrue);
    });

    test('정상 해제 = 확인 + 48h 이후 · 결정 있음', () {
      expect(
        killSwitchActive(
          _rec(confirmed: _conf, cleared: _eta, decision: 'J-1'),
        ),
        isFalse,
      );
    });

    test('test_kill_file_deleted_but_wait_not_elapsed_still_blocked — 🔴 손으로 고친 행은 풀지 못한다', () {
      // 해제 시각만 채움(결정 없음).
      expect(killSwitchActive(_rec(confirmed: _conf, cleared: _eta)), isTrue);
      // 확인 없이 해제.
      expect(killSwitchActive(_rec(cleared: _eta, decision: 'J-1')), isTrue);
      // 48h 전에 해제.
      expect(
        killSwitchActive(
          _rec(
            confirmed: _conf,
            cleared: _eta.subtract(const Duration(seconds: 1)),
            decision: 'J-1',
          ),
        ),
        isTrue,
      );
      // 해제가 확인보다 앞섬.
      expect(
        killSwitchActive(
          _rec(
            confirmed: _conf,
            cleared: _conf.subtract(const Duration(hours: 1)),
            decision: 'J-1',
          ),
        ),
        isTrue,
      );
      // 확인이 발동보다 앞섬 = 확인 없음.
      expect(
        killSwitchActive(
          _rec(
            confirmed: _act.subtract(const Duration(hours: 100)),
            cleared: _eta,
            decision: 'J-1',
          ),
        ),
        isTrue,
      );
      expect(
        effectiveChecklistConfirmedAt(
          _rec(confirmed: _act.subtract(const Duration(minutes: 1))),
        ),
        isNull,
      );
      expect(effectiveChecklistConfirmedAt(_rec(confirmed: _act)), _act);
    });

    test('🔴 48h 는 발동이 아니라 확인부터 — 발동 + 48h 로 해제하면 아직 활성', () {
      expect(
        killSwitchActive(
          _rec(
            confirmed: _conf,
            cleared: _act.add(const Duration(hours: 48)),
            decision: 'J-1',
          ),
        ),
        isTrue,
      );
    });

    test('config 대기 시간', () {
      const KillSwitchConfig c = KillSwitchConfig(
        resumeMinWait: Duration(hours: 1),
      );
      expect(
        killSwitchActive(
          _rec(
            confirmed: _conf,
            cleared: _conf.add(const Duration(hours: 1)),
            decision: 'J-1',
          ),
          cfg: c,
        ),
        isFalse,
      );
      expect(kP0sKillSwitchConfig.resumeMinWait, const Duration(hours: 48));
      expect(kP0sKillSwitchConfig.resumeChecklistItems, 7);
    });
  });

  group('재개 준비 · 화면 문장(K2)', () {
    test('5상태', () {
      expect(
        resumeReadinessOf(_rec(on: false), _eta).kind,
        ResumeReadinessKind.inactive,
      );
      expect(
        resumeReadinessOf(_rec(), _eta).kind,
        ResumeReadinessKind.checklistNotConfirmed,
      );
      final ResumeReadiness unk = resumeReadinessOf(
        _rec(confirmed: _conf),
        null,
      );
      expect(
        (unk.kind, unk.etaUtc),
        (ResumeReadinessKind.trustedTimeUnknown, _eta),
      );
      final ResumeReadiness w = resumeReadinessOf(
        _rec(confirmed: _conf),
        _eta.subtract(const Duration(minutes: 90)),
      );
      expect(
        (w.kind, w.remaining, w.etaUtc),
        (ResumeReadinessKind.waiting, const Duration(minutes: 90), _eta),
      );
      expect(
        resumeReadinessOf(_rec(confirmed: _conf), _eta).kind,
        ResumeReadinessKind.ready,
      );
    });

    test('KillSwitchView — 꺼짐 · 확인 전 · 대기 · 모름 · 준비', () {
      final KillSwitchView off = killSwitchViewOf(_rec(on: false), _eta);
      expect(
        (
          off.active,
          off.stateLabel,
          off.activatedAt,
          off.releaseEtaText,
          off.checklistStateLabel,
        ),
        (false, '킬스위치 꺼짐', null, null, null),
      );
      final KillSwitchView pre = killSwitchViewOf(_rec(), _eta);
      expect(pre.active, isTrue);
      expect(pre.stateLabel, '킬스위치 작동 중 — 신규 주문을 막고 있습니다');
      expect((pre.activatedAt, pre.activatedByDeviceLabel), (_act, '내 폰'));
      expect(pre.checklistStateLabel, '체크리스트를 먼저 마치십시오 — 마친 때부터 48시간을 셉니다');
      expect(pre.releaseEtaText, isNull);
      final KillSwitchView wait = killSwitchViewOf(
        _rec(confirmed: _conf),
        _conf,
      );
      expect(wait.checklistStateLabel, '체크리스트 확인 11-04 10:30');
      expect(wait.releaseEtaText, '해제 가능 예정 11-06 10:30');
      expect(
        killSwitchViewOf(_rec(confirmed: _conf), null).releaseEtaText,
        '서버 시각을 확인하지 못해 해제 시각을 셀 수 없습니다',
      );
      expect(
        killSwitchViewOf(_rec(confirmed: _conf), _eta).releaseEtaText,
        '해제 가능 — 재개 체크리스트를 진행하십시오',
      );
    });
  });

  group('(가) 발동 뒤 기록(K3)', () {
    KillActivationAnswers ans({
      String rule = '월말 정기 리밸런싱만',
      KillReasonKind kind = KillReasonKind.rule,
      String? emotion,
      int? intensity,
      double? sleep,
      String? scenario = 'W-03',
      bool none = false,
      String cond = 'DD 가 −10% 위로 회복',
      String journal = 'J-KILL-1',
    }) => KillActivationAnswers(
      ruleAction: rule,
      reasonKind: kind,
      emotion: emotion,
      intensity: intensity,
      sleepHours: sleep,
      scenarioId: scenario,
      scenarioNone: none,
      resumeCondition: cond,
      scope: KillScope.newEntriesOnly,
      journalDecisionId: journal,
    );
    const KillAckAnswers ack = KillAckAnswers(
      openOrdersQueried: true,
      openOrdersCancelled: true,
      remainingCountZero: true,
      note: '증권사 앱에서 0건 확인',
    );

    test('통과', () {
      expect(
        activationChecklistVerdict(ans(), ack, engineOpenOrders: 0).passed,
        isTrue,
      );
      expect(
        activationChecklistVerdict(
          ans(scenario: null, none: true),
          ack,
          engineOpenOrders: 0,
        ).passed,
        isTrue,
      );
      expect(
        activationChecklistVerdict(
          ans(
            kind: KillReasonKind.emotion,
            emotion: '불안',
            intensity: 8,
            sleep: 4,
          ),
          ack,
          engineOpenOrders: 0,
        ).passed,
        isTrue,
      );
    });

    test('빈칸 항목 번호', () {
      int? item(KillActivationAnswers a) =>
          activationChecklistVerdict(a, ack, engineOpenOrders: 0).itemNo;
      expect(item(ans(rule: '  ')), 1);
      expect(item(ans(kind: KillReasonKind.emotion)), 2);
      expect(
        item(
          ans(
            kind: KillReasonKind.emotion,
            emotion: '불안',
            intensity: 11,
            sleep: 4,
          ),
        ),
        2,
      );
      expect(
        item(
          ans(
            kind: KillReasonKind.emotion,
            emotion: '불안',
            intensity: 5,
            sleep: 25,
          ),
        ),
        2,
      );
      expect(
        item(
          ans(
            kind: KillReasonKind.emotion,
            emotion: '불안',
            intensity: -1,
            sleep: 4,
          ),
        ),
        2,
      );
      expect(
        item(
          ans(
            kind: KillReasonKind.emotion,
            emotion: '불안',
            intensity: 5,
            sleep: -0.5,
          ),
        ),
        2,
      );
      expect(item(ans(scenario: '')), 3);
      expect(item(ans(cond: '')), 4);
      expect(item(ans(journal: '')), 7);
      expect(
        activationChecklistVerdict(
          ans(rule: ''),
          ack,
          engineOpenOrders: 0,
        ).code,
        'KILL_CHECKLIST_ITEM_MISSING',
      );
    });

    test('확인 3 — 빠짐 · 🔴 엔진 미체결과 어긋남 = 무효 + P0', () {
      for (final KillAckAnswers bad in <KillAckAnswers>[
        const KillAckAnswers(
          openOrdersQueried: false,
          openOrdersCancelled: true,
          remainingCountZero: true,
          note: 'n',
        ),
        const KillAckAnswers(
          openOrdersQueried: true,
          openOrdersCancelled: false,
          remainingCountZero: true,
          note: 'n',
        ),
        const KillAckAnswers(
          openOrdersQueried: true,
          openOrdersCancelled: true,
          remainingCountZero: false,
          note: 'n',
        ),
        const KillAckAnswers(
          openOrdersQueried: true,
          openOrdersCancelled: true,
          remainingCountZero: true,
          note: ' ',
        ),
      ]) {
        final KillChecklistVerdict v = activationChecklistVerdict(
          ans(),
          bad,
          engineOpenOrders: 0,
        );
        expect((v.code, v.p0, v.itemNo), ('KILL_ACK_INCOMPLETE', false, null));
      }
      final KillChecklistVerdict m = activationChecklistVerdict(
        ans(),
        ack,
        engineOpenOrders: 1,
      );
      expect((m.code, m.p0, m.passed), ('KILL_ACK_MISMATCH', true, false));
    });
  });

  group('(나) 재개판 순차(K4)', () {
    test('순서 밖 · 빈칸 · 일괄 = 거부 · 다 마치면 complete', () {
      final (ResumeChecklist? _, String? e1) = ResumeChecklist.empty.accept(
        const ResumeItemAnswer(2, emotion: 'x', intensity: 1, sleepHours: 1),
      );
      expect(e1, 'RESUME_ITEM_OUT_OF_ORDER');
      final (ResumeChecklist? _, String? e2) = ResumeChecklist.empty.accept(
        const ResumeItemAnswer(1, text: ' '),
      );
      expect(e2, 'RESUME_ITEM_MISSING');
      final ResumeChecklist c = _full();
      expect((c.complete, c.next, c.conditionUnmet), (true, 8, false));
      expect(c.journal!.decisionId, 'J-RESUME-1');
      final (ResumeChecklist? _, String? e3) = c.accept(
        const ResumeItemAnswer(8),
      );
      expect(e3, 'RESUME_CHECKLIST_DONE');
      expect(ResumeChecklist.empty.journal, isNull);
    });

    test('항목별 빈칸', () {
      ResumeChecklist upTo(int n) {
        ResumeChecklist c = ResumeChecklist.empty;
        for (final ResumeItemAnswer a in _full().accepted.take(n - 1)) {
          c = c.accept(a).$1!;
        }
        return c;
      }

      final List<ResumeItemAnswer> bad = <ResumeItemAnswer>[
        const ResumeItemAnswer(1),
        const ResumeItemAnswer(2, emotion: '평온', intensity: 2),
        const ResumeItemAnswer(2, emotion: '평온', intensity: 11, sleepHours: 7),
        const ResumeItemAnswer(2, emotion: '평온', intensity: -1, sleepHours: 7),
        const ResumeItemAnswer(2, emotion: '평온', intensity: 2, sleepHours: 25),
        const ResumeItemAnswer(2, emotion: '평온', intensity: 2, sleepHours: -1),
        const ResumeItemAnswer(3),
        const ResumeItemAnswer(4),
        const ResumeItemAnswer(5),
        const ResumeItemAnswer(6),
        const ResumeItemAnswer(
          7,
          decisionId: 'J',
          rationaleBefore: 'a',
          expectedOutcome: 'b',
        ),
        const ResumeItemAnswer(
          7,
          rationaleBefore: 'a',
          expectedOutcome: 'b',
          ruleCited: 'c',
        ),
        const ResumeItemAnswer(
          7,
          decisionId: 'J',
          expectedOutcome: 'b',
          ruleCited: 'c',
        ),
        const ResumeItemAnswer(
          7,
          decisionId: 'J',
          rationaleBefore: 'a',
          ruleCited: 'c',
        ),
      ];
      for (final ResumeItemAnswer a in bad) {
        expect(
          upTo(a.itemNo).accept(a).$2,
          'RESUME_ITEM_MISSING',
          reason: '${a.itemNo}',
        );
      }
      expect(
        upTo(1).accept(const ResumeItemAnswer(9)).$2,
        'RESUME_ITEM_OUT_OF_ORDER',
      );
    });

    test('🔴 4번 미충족 = 그 뒤 진행 불가', () {
      final ResumeChecklist c = _full(cond: ResumeConditionStatus.unmet);
      expect(
        (c.conditionUnmet, c.complete, c.accepted.length),
        (true, false, 4),
      );
      expect(
        c.accept(const ResumeItemAnswer(5, acknowledged: true)).$2,
        'RESUME_CONDITION_UNMET',
      );
    });
  });

  group('tryResume(K5)', () {
    final KillSwitchRecord ready = _rec(confirmed: _conf);

    test('test_resume_before_min_wait_blocked', () {
      expect(
        tryResume(
          ready,
          _eta.subtract(const Duration(seconds: 1)),
          _full(),
        ).code,
        'RESUME_TOO_SOON',
      );
    });

    test('test_resume_without_checklist_blocked', () {
      expect(
        tryResume(ready, _eta, ResumeChecklist.empty).code,
        'RESUME_CHECKLIST_INCOMPLETE',
      );
    });

    test('재개판을 절반만 마침 = 미완', () {
      ResumeChecklist part = ResumeChecklist.empty;
      for (final ResumeItemAnswer a in _full().accepted.take(3)) {
        part = part.accept(a).$1!;
      }
      expect(tryResume(ready, _eta, part).code, 'RESUME_CHECKLIST_INCOMPLETE');
    });

    test(
      'test_resume_countdown_starts_at_checklist_confirm — 발동 + 48h 는 아직',
      () {
        final DateTime t = _act.add(const Duration(hours: 48));
        expect(t.isBefore(_eta), isTrue);
        expect(tryResume(ready, t, _full()).code, 'RESUME_TOO_SOON');
        expect(tryResume(ready, _eta, _full()).allowed, isTrue);
      },
    );

    test('test_resume_without_checklist_confirm_blocked', () {
      expect(
        tryResume(_rec(), _eta, _full()).code,
        'RESUME_CHECKLIST_NOT_CONFIRMED',
      );
    });

    test('test_resume_condition_unmet_blocked', () {
      expect(
        tryResume(ready, _eta, _full(cond: ResumeConditionStatus.unmet)).code,
        'RESUME_CONDITION_UNMET',
      );
    });

    test('test_resume_trusted_time_unknown_blocked · 꺼짐', () {
      expect(
        tryResume(ready, null, _full()).code,
        'RESUME_TRUSTED_TIME_UNKNOWN',
      );
      expect(
        tryResume(_rec(on: false), _eta, _full()).code,
        'KILL_SWITCH_NOT_ACTIVE',
      );
    });

    test('통과 = 해제 값(신뢰 시각 · 저널) · 그 값으로 만든 행 = 꺼짐', () {
      final DateTime now = _eta.add(const Duration(hours: 3));
      final ResumeDecision d = tryResume(ready, now, _full());
      expect(
        (d.allowed, d.code, d.clearedAtUtc, d.decisionId),
        (true, null, now, 'J-RESUME-1'),
      );
      final KillSwitchRecord after = KillSwitchRecord(
        activatedAtUtc: ready.activatedAtUtc,
        checklistConfirmedAtUtc: ready.checklistConfirmedAtUtc,
        clearedAtUtc: d.clearedAtUtc,
        decisionId: d.decisionId,
      );
      expect(killSwitchActive(after), isFalse);
    });

    test('🔴 시계 조작 — 신뢰 시각만 본다(기기 시계를 앞당겨도 소용없다)', () {
      // 기기 시계가 49h 뒤라고 우겨도 신뢰 시각이 47h 뒤면 막힌다.
      final DateTime trusted = _conf.add(const Duration(hours: 47));
      expect(tryResume(ready, trusted, _full()).code, 'RESUME_TOO_SOON');
    });
  });

  group('발동 순서기(K6)', () {
    test(
      '계획 — SUBMITTED · PARTIAL 잔량 > 0 만 취소 · UNKNOWN · 제출 중 = 보고만 · 나머지 무시',
      () {
        final (
          List<KillCancelCandidate> c,
          List<KillCancelItem> r,
        ) = planKillCancels(<KillCancelCandidate>[
          _cand('a', IntentStatus.submitted),
          _cand('b', IntentStatus.partial),
          _cand('c', IntentStatus.submitted, rem: 0),
          _cand('d', IntentStatus.unknown),
          _cand('e', IntentStatus.reserved),
          _cand('f', IntentStatus.submitting),
          _cand('g', IntentStatus.filled),
          _cand('h', IntentStatus.cancelled),
          KillCancelCandidate(
            intentId: 'i',
            account: 'main',
            symbol: 's',
            status: IntentStatus.submitted,
            brokerOrderNo: null,
            remainingQty: 3,
          ),
        ]);
        expect(c.map((KillCancelCandidate x) => x.intentId), <String>[
          'a',
          'b',
        ]);
        expect(
          r.map((KillCancelItem x) => (x.intentId, x.outcome)),
          <(String, KillCancelOutcome)>[
            ('d', KillCancelOutcome.notCancelledUnknownIntent),
            ('e', KillCancelOutcome.inFlight),
            ('f', KillCancelOutcome.inFlight),
          ],
        );
      },
    );

    test(
      'test_kill_switch_cancels_open_orders — 차단이 먼저 · 건별 보고 · 금액 0',
      () async {
        final _Store store = _Store();
        final _Broker main = _Broker(<String, Object>{});
        final _Broker pension = _Broker(<String, Object>{});
        final KillActivationResult r = await activateKillSwitch(
          store: store,
          brokers: <String, OrderBroker>{'main': main, 'pension': pension},
          candidates: () async => <KillCancelCandidate>[
            _cand('a', IntentStatus.submitted),
            _cand('b', IntentStatus.partial, account: 'pension'),
            _cand('d', IntentStatus.unknown),
          ],
          nowUtc: _act,
          channel: 'app',
          deviceLabel: '내 폰',
        );
        expect(store.calls, <String>['activate', 'report']);
        expect(killSwitchActive(r.record), isTrue);
        expect(r.record.activatedAtUtc, _act);
        expect(main.cancelled, <String>['20261104:a']);
        expect(pension.cancelled, <String>['20261104:b']);
        expect(r.report.count(KillCancelOutcome.cancelled), 2);
        expect(r.report.count(KillCancelOutcome.notCancelledUnknownIntent), 1);
        expect(r.report.clean, isFalse);
        expect(r.reportRecorded, isTrue);
        expect(store.reports.single.$2, _act);
        final String j = r.report.summaryJson();
        expect(j, contains('"outcome":"CANCELLED"'));
        expect(j, contains('"outcome":"NOT_CANCELLED_UNKNOWN_INTENT"'));
        expect(j, isNot(contains('amount')));
      },
    );

    test('test_kill_switch_cancel_failure_keeps_block — 거절 · 불명 · 예외 · 브로커 없음 · 재시도 0', () async {
      final _Store store = _Store();
      final _Broker b = _Broker(<String, Object>{
        '20261104:r': const BrokerRejected(code: '40580000', message: 'x'),
        '20261104:u': const OrderOutcomeUnknown('timeout'),
        '20261104:x': StateError('boom'),
      });
      final KillActivationResult res = await activateKillSwitch(
        store: store,
        brokers: <String, OrderBroker>{'main': b},
        candidates: () async => <KillCancelCandidate>[
          _cand('r', IntentStatus.submitted),
          _cand('u', IntentStatus.submitted),
          _cand('x', IntentStatus.submitted),
          _cand('n', IntentStatus.submitted, account: 'nowhere'),
        ],
        nowUtc: _act,
        channel: 'viewer',
      );
      expect(killSwitchActive(res.record), isTrue);
      expect(b.cancelled, <String>['20261104:r', '20261104:u', '20261104:x']);
      expect(
        res.report.items.map(
          (KillCancelItem i) => (i.intentId, i.outcome, i.code),
        ),
        <(String, KillCancelOutcome, String?)>[
          ('r', KillCancelOutcome.failed, '40580000'),
          ('u', KillCancelOutcome.unknown, null),
          ('x', KillCancelOutcome.failed, 'StateError'),
          ('n', KillCancelOutcome.failed, 'NO_BROKER'),
        ],
      );
      expect(res.report.clean, isFalse);
    });

    test('test_kill_switch_unknown_not_cancelled', () async {
      final _Broker b = _Broker(<String, Object>{});
      await activateKillSwitch(
        store: _Store(),
        brokers: <String, OrderBroker>{'main': b},
        candidates: () async => <KillCancelCandidate>[
          _cand('u', IntentStatus.unknown),
        ],
        nowUtc: _act,
        channel: 'app',
      );
      expect(b.cancelled, isEmpty);
    });

    test('후보 읽기 실패 · 보고 저장 실패 = 차단은 그대로 · 발동 기록 실패 = 던진다', () async {
      final _Store s1 = _Store();
      final KillActivationResult r1 = await activateKillSwitch(
        store: s1,
        brokers: const <String, OrderBroker>{},
        candidates: () async => throw StateError('db'),
        nowUtc: _act,
        channel: 'app',
      );
      expect(killSwitchActive(r1.record), isTrue);
      expect(r1.report.candidatesError, 'StateError');
      expect(r1.report.clean, isFalse);
      expect(r1.report.summaryJson(), contains('candidates_error'));
      final _Store s2 = _Store()..failReport = true;
      final KillActivationResult r2 = await activateKillSwitch(
        store: s2,
        brokers: const <String, OrderBroker>{},
        candidates: () async => const <KillCancelCandidate>[],
        nowUtc: _act,
        channel: 'app',
      );
      expect(
        (r2.reportRecorded, killSwitchActive(r2.record), r2.report.clean),
        (false, true, true),
      );
      final _Store s3 = _Store()..failActivate = true;
      await expectLater(
        activateKillSwitch(
          store: s3,
          brokers: const <String, OrderBroker>{},
          candidates: () async => const <KillCancelCandidate>[],
          nowUtc: _act,
          channel: 'app',
        ),
        throwsStateError,
      );
      expect(s3.calls, <String>['activate']);
    });

    test('다시 누름 = 첫 발동 시각 유지(저장 멱등)', () async {
      final _Store s = _Store();
      Future<KillActivationResult> press(DateTime at) => activateKillSwitch(
        store: s,
        brokers: const <String, OrderBroker>{},
        candidates: () async => const <KillCancelCandidate>[],
        nowUtc: at,
        channel: 'app',
      );
      await press(_act);
      final KillActivationResult again = await press(
        _act.add(const Duration(hours: 2)),
      );
      expect(again.record.activatedAtUtc, _act);
      expect(s.reports.map((r) => r.$2), <DateTime>[
        _act,
        _act.add(const Duration(hours: 2)),
      ]);
    });
  });

  test('🔴 정적 검사(SC-2 판) — core lib 에 게이트 없는 해제 이름 0', () {
    final RegExp bad = RegExp(
      r'\b(deactivate\w*|clearKill\w*|releaseKill\w*|unlockKill\w*)\s*\(',
      caseSensitive: false,
    );
    final List<String> hits = <String>[
      for (final FileSystemEntity f in Directory(
        'lib',
      ).listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart'))
          for (final String line in f.readAsLinesSync())
            if (!line.trimLeft().startsWith('//') && bad.hasMatch(line))
              '${f.path}: $line',
    ];
    expect(hits, isEmpty);
  });
}
