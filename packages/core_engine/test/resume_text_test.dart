// E14b — 재개 문장 · 집계 · 묶음 알림(설계 13 §8 R72 J8 · J9).
//
// 🔵 잡는 것: ① 모드 이름 · modeLabel ② verdict 라벨 5 · 모르는 코드 = 오류 ③ 계획 · 재판정 한 줄(사유 14 ·
//    날짜 0 채움 없음) ④ 리포트 항목 ⑤ 집계(복구 불가 = 항목 + 공백) · 모르는 코드 · 음수 ⑥ 머리말 꼬리(해제 2 ·
//    멈춤 6) ⑦ 홈 한 줄(null · 0 · n · 음수) ⑧ 🔴 손익 · «램프» · «실행» 0 ⑨ 묶음(배타 · 공백 더함) ·
//    접기(P0 안전 3 빼고) · 등급 · 문구 · 링크
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

const TradeDate _today = TradeDate('2026-11-20');
const TradeDate _due = TradeDate('2026-11-05');

const List<String> _reasons = <String>[
  ResumeReasonCodes.duePassed,
  ResumeReasonCodes.advisoryPending,
  ResumeReasonCodes.safetyStop,
  ResumeReasonCodes.observing,
  ResumeReasonCodes.reconMismatch,
  ResumeReasonCodes.unknownOrders,
  ResumeReasonCodes.residualOrders,
  ResumeReasonCodes.humanDecision,
  ResumeReasonCodes.conservativeDefer,
  ResumeReasonCodes.reevaluatedEmpty,
  ResumeReasonCodes.reevaluated,
  ResumeReasonCodes.humanSkip,
  ResumeReasonCodes.humanReduced,
  ResumeReasonCodes.humanAsIs,
];

const List<String?> _halts = <String?>[
  null,
  ResumeReasonCodes.observing,
  ResumeReasonCodes.safetyStop,
  ResumeReasonCodes.advisoryPending,
  ResumeReasonCodes.reconMismatch,
  ResumeReasonCodes.unknownOrders,
  ResumeReasonCodes.residualOrders,
];

String _line(String r) =>
    resumeReevaluatedLine(reasonCode: r, dueBy: _due, today: _today);

ResumeCounts _c({int e = 0, int x = 0, int s = 0, int b = 0, int u = 0}) =>
    ResumeCounts(
      executed: e,
      expired: x,
      superseded: s,
      blocked: b,
      unrecoverable: u,
    );

void main() {
  group('문장', () {
    test('모드 이름 · modeLabel', () {
      expect(ResumeMode.values.map(resumeModeName).toList(), <String>[
        '평상',
        '보수',
        '복구 관찰',
        '안전 정지',
      ]);
      expect(
        resumeModeLabel(gapSessions: 7, mode: ResumeMode.recoveryDry),
        '7거래일 미실행 — 복구 관찰',
      );
    });

    test('verdict 라벨 5 · 모르는 코드 = 오류', () {
      expect(VerdictCodes.values.map(resumeVerdictLabel).toSet(), <String>{
        '재판정 값으로 집행 예정',
        '만료',
        '대체됨',
        '차단',
        '복구 불가',
      });
      expect(
        resumeVerdictLabel(VerdictCodes.executedAsReevaluated),
        '재판정 값으로 집행 예정',
      );
      expect(resumeVerdictLabel(VerdictCodes.expired), '만료');
      expect(resumeVerdictLabel(VerdictCodes.superseded), '대체됨');
      expect(resumeVerdictLabel(VerdictCodes.blocked), '차단');
      expect(resumeVerdictLabel(VerdictCodes.unrecoverable), '복구 불가');
      expect(() => resumeVerdictLabel('DONE'), throwsArgumentError);
    });

    test('계획 · 재판정 한 줄 — 날짜 0 채움 없음 · 사유마다 다르다', () {
      expect(resumePlannedLine(const TradeDate('2026-01-09')), '1월 9일 계획됨');
      expect(resumePlannedLine(const TradeDate('2026-11-20')), '11월 20일 계획됨');
      expect(_line(ResumeReasonCodes.duePassed), '유효기한(11월 5일)이 지났습니다');
      expect(
        _line(ResumeReasonCodes.reevaluated),
        '11월 20일 재판정 값으로 다음 주문 회차에 넘겼습니다',
      );
      expect(
        _line(ResumeReasonCodes.reevaluatedEmpty),
        '11월 20일 재판정 결과 할 일이 없습니다',
      );
      expect(_line(ResumeReasonCodes.observing), '관찰 회차라 다음 회차에 재판정합니다');
      expect(_line(ResumeReasonCodes.safetyStop), '안전 정지 — 기기와 원장 검증이 먼저입니다');
      expect(_line(ResumeReasonCodes.advisoryPending), '안내 모드 재개 조건 결정을 기다립니다');
      expect(_line(ResumeReasonCodes.reconMismatch), '대사 불일치가 남아 있어 미뤄 둡니다');
      expect(
        _line(ResumeReasonCodes.unknownOrders),
        '결과를 모르는 주문이 남아 있어 미뤄 둡니다',
      );
      expect(_line(ResumeReasonCodes.residualOrders), '처리 중인 주문이 남아 있어 미뤄 둡니다');
      expect(_line(ResumeReasonCodes.humanDecision), '계절 진입은 직접 결정해야 합니다');
      expect(
        _line(ResumeReasonCodes.conservativeDefer),
        '보수 모드라 다음 정기 회차로 넘겼습니다',
      );
      expect(_line(ResumeReasonCodes.humanSkip), '직접 건너뛰었습니다');
      expect(_line(ResumeReasonCodes.humanReduced), '직접 축소 진입을 골랐습니다');
      expect(_line(ResumeReasonCodes.humanAsIs), '직접 그대로 진입을 골랐습니다');
      expect(_reasons.map(_line).toSet(), hasLength(_reasons.length));
      expect(() => _line('SOMETHING'), throwsArgumentError);
      expect(
        () => resumePlannedLine(const TradeDate('20261120')),
        throwsArgumentError,
      );
    });

    test('리포트 항목 = 한 줄 · 계획 · 재판정 · 코드 · 라벨', () {
      const ResumeWorkItem item = ResumeWorkItem(
        workId: 'pw_9',
        kind: ResumeWorkKinds.monthlyPlan,
        oneLine: '11월 정기 리밸런싱',
        state: PlannedWorkState.planned,
        plannedOn: TradeDate('2026-11-02'),
        dueBy: TradeDate('2026-11-05'),
        direction: ResumeDirection.rebalance,
        sell: false,
      );
      final ResumeItem r = resumeItemOf(
        item: item,
        judgement: const ResumeItemJudgement(
          nextState: PlannedWorkState.expired,
          verdictCode: VerdictCodes.expired,
          reasonCode: ResumeReasonCodes.duePassed,
        ),
        today: _today,
      );
      expect(
        r,
        const ResumeItem(
          workId: 'pw_9',
          oneLine: '11월 정기 리밸런싱',
          plannedLine: '11월 2일 계획됨',
          reevaluatedLine: '유효기한(11월 5일)이 지났습니다',
          verdictCode: 'EXPIRED',
          verdictLabel: '만료',
        ),
      );
    });

    test('집계 — verdict 마다 · 복구 불가 = 항목 + 공백 · 모르는 코드 · 음수', () {
      expect(
        resumeCountsOf(
          verdictCodes: <String>[
            VerdictCodes.executedAsReevaluated,
            VerdictCodes.executedAsReevaluated,
            VerdictCodes.expired,
            VerdictCodes.superseded,
            VerdictCodes.superseded,
            VerdictCodes.superseded,
            VerdictCodes.blocked,
            VerdictCodes.unrecoverable,
          ],
          unrecoverableGaps: 2,
        ),
        _c(e: 2, x: 1, s: 3, b: 1, u: 3),
      );
      expect(
        resumeCountsOf(verdictCodes: <String>[], unrecoverableGaps: 0),
        _c(),
      );
      expect(
        () => resumeCountsOf(
          verdictCodes: <String>['DONE'],
          unrecoverableGaps: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => resumeCountsOf(verdictCodes: <String>[], unrecoverableGaps: -1),
        throwsArgumentError,
      );
    });

    test('머리말 — 집계 + 꼬리(해제 2 · 멈춤 6)', () {
      String h(ResumeCounts c, String? halt) =>
          resumeHeadline(gapSessions: 7, counts: c, haltReason: halt);
      expect(
        h(_c(e: 4, x: 3, s: 2, b: 1, u: 2), null),
        '7거래일 미실행: 재판정 4 / 만료 3 / 대체 2 / 차단 1 / 복구 불가 2. '
        '주문은 다음 주문 회차가 냅니다.',
      );
      expect(h(_c(x: 1), null), endsWith('. 새로 낼 주문은 없습니다.'));
      expect(
        h(_c(b: 5), ResumeReasonCodes.observing),
        '7거래일 미실행: 재판정 0 / 만료 0 / 대체 0 / 차단 5 / 복구 불가 0. '
        '관찰 회차라 발주하지 않습니다.',
      );
      expect(
        h(_c(), ResumeReasonCodes.safetyStop),
        endsWith('. 안전 정지 — 매매하지 않습니다.'),
      );
      expect(
        h(_c(), ResumeReasonCodes.advisoryPending),
        endsWith('. 안내 모드 재개 조건 결정을 기다립니다.'),
      );
      expect(
        h(_c(), ResumeReasonCodes.reconMismatch),
        endsWith('. 대사 불일치가 풀릴 때까지 매매를 멈춰 둡니다.'),
      );
      expect(
        h(_c(), ResumeReasonCodes.unknownOrders),
        endsWith('. 결과를 모르는 주문이 풀릴 때까지 매매를 멈춰 둡니다.'),
      );
      expect(
        h(_c(), ResumeReasonCodes.residualOrders),
        endsWith('. 처리 중인 주문이 풀릴 때까지 매매를 멈춰 둡니다.'),
      );
      expect(
        _halts.map((String? r) => h(_c(), r)).toSet(),
        hasLength(_halts.length),
      );
      expect(
        () => h(_c(), ResumeReasonCodes.humanDecision),
        throwsArgumentError,
      );
    });

    test('홈 한 줄 — 기준 없음 = null · D+n · 대기 작업 없음 / n건 · 음수 = 오류', () {
      expect(resumeLineText(gapSessions: null, pendingWork: 0), isNull);
      expect(
        resumeLineText(gapSessions: 0, pendingWork: 0),
        '마지막 성공 거래일 D+0 · 대기 작업 없음',
      );
      expect(
        resumeLineText(gapSessions: 7, pendingWork: 3),
        '마지막 성공 거래일 D+7 · 대기 작업 3건',
      );
      expect(
        resumeLineText(gapSessions: 0, pendingWork: 1),
        '마지막 성공 거래일 D+0 · 대기 작업 1건',
      );
      expect(
        () => resumeLineText(gapSessions: null, pendingWork: -1),
        throwsArgumentError,
      );
      expect(
        () => resumeLineText(gapSessions: -1, pendingWork: 0),
        throwsArgumentError,
      );
    });

    test('🔴 손익 · «램프» · «실행» 낱말 0(재개는 주문을 내지 않는다)', () {
      final List<String> all = <String>[
        ...ResumeMode.values.map(resumeModeName),
        ...VerdictCodes.values.map(resumeVerdictLabel),
        ..._reasons.map(_line),
        for (final String? r in _halts)
          resumeHeadline(gapSessions: 3, counts: _c(e: 1), haltReason: r),
        resumeLineText(gapSessions: 2, pendingWork: 2)!,
        for (final String c in <String>[
          kResumeCompletedAlertCode,
          kResumeTradingHaltedAlertCode,
          kResumeDataGapAlertCode,
        ]) ...<String>[
          alertTextOf(c).title,
          alertTextOf(c).body,
          alertTextOf(c).action,
        ],
      ];
      // «미실행»(멈춰 있던 기간)은 괜찮다 — 재개가 «실행했다»고 말하지 않을 뿐.
      final RegExp didRun = RegExp('(?<!미)실행');
      final RegExp money = RegExp(r'\d\s*원');
      for (final String s in all) {
        expect(s.contains('램프'), isFalse, reason: s);
        expect(didRun.hasMatch(s), isFalse, reason: s);
        expect(money.hasMatch(s), isFalse, reason: s);
        expect(s.contains('%'), isFalse, reason: s);
        expect(s.contains('수익'), isFalse, reason: s);
        expect(s.contains('손실'), isFalse, reason: s);
      }
    });
  });

  group('묶음 알림', () {
    test('🔴 완료 · 정지 배타 · 복구 불가 공백이면 P2 더함', () {
      expect(
        resumeBundleAlerts(flagReleased: true, unrecoverableGaps: 0),
        <String>{kResumeCompletedAlertCode},
      );
      expect(
        resumeBundleAlerts(flagReleased: false, unrecoverableGaps: 0),
        <String>{kResumeTradingHaltedAlertCode},
      );
      expect(
        resumeBundleAlerts(flagReleased: true, unrecoverableGaps: 1),
        <String>{kResumeCompletedAlertCode, kResumeDataGapAlertCode},
      );
      expect(
        resumeBundleAlerts(flagReleased: false, unrecoverableGaps: 3),
        <String>{kResumeTradingHaltedAlertCode, kResumeDataGapAlertCode},
      );
      expect(
        () => resumeBundleAlerts(flagReleased: true, unrecoverableGaps: -1),
        throwsArgumentError,
      );
    });

    test('접기 — P0 안전 3코드만 개별 유지', () {
      expect(kResumeUnfoldedAlertCodes, <String>{
        'RECON_MISMATCH',
        'ORDER_OUTCOME_UNKNOWN',
        'BROKER_AUTH_FAILED',
      });
      for (final String c in kResumeUnfoldedAlertCodes) {
        expect(resumeFoldsAlert(c), isFalse, reason: c);
      }
      for (final String c in <String>[
        AlertCodes.dataSourceDown,
        AlertCodes.watchdogLate,
        AlertCodes.orderRejected,
        AlertCodes.maintenanceResumeFailed,
      ]) {
        expect(resumeFoldsAlert(c), isTrue, reason: c);
      }
    });

    test('등급 · 문구 · 링크 · 낸 곳', () {
      expect(kResumeAlertSource, 'RESUME');
      expect(kResumeCompletedAlertCode, 'RESUME_COMPLETED');
      expect(kResumeTradingHaltedAlertCode, 'RESUME_TRADING_HALTED');
      expect(kResumeDataGapAlertCode, 'RESUME_DATA_GAP');
      expect(alertLevelOf(kResumeCompletedAlertCode), AlertLevel.p1);
      expect(alertLevelOf(kResumeTradingHaltedAlertCode), AlertLevel.p0);
      expect(alertLevelOf(kResumeDataGapAlertCode), AlertLevel.p2);
      expect(
        alertTextOf(kResumeCompletedAlertCode).deepLink,
        AppRoutes.x2ResumeReport,
      );
      expect(
        alertTextOf(kResumeTradingHaltedAlertCode).deepLink,
        AppRoutes.x2ResumeGate,
      );
      expect(
        alertTextOf(kResumeDataGapAlertCode).deepLink,
        AppRoutes.x2ResumeReport,
      );
    });
  });
}
