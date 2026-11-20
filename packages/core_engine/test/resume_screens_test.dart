// E11q-b2a — X2 재개 화면 VM(설계 13 §8 R186 · 01 §31 K64 · §34 K156).
//
// 🔴 표본 `x2/resume_report_screen_*` · `x2/resume_gate_*` 와 글자 · 수준 · 차례가 같다(«(합성)» 표지 제외 · 머리 = 회차가 남긴
//    엔진 머리말) · C-59 ⑭(리포트 null ⇔ 빈 문장 · 리포트 ⇒ 시각 · 단계) · C-56(잠김 ⇒ 행 동작 0).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, Object?> _row(String f) =>
    ((jsonDecode(
                  File('../domain_contracts/fixtures/x2/$f.json')
                      .readAsStringSync(),
                ) as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;

String _plain(String s) => s.replaceFirst('(합성) ', '');

bool _all(String _) => true;

/// 표본 게이트 행 → 회차 항목(사유 · 결과 · 글자 그대로 · «(합성)» 은 원문에 그대로 둔다).
ResumeGateItem _item(ResumeGateRow r, String verdict) => ResumeGateItem(
  workId: r.workId,
  oneLine: r.oneLine,
  reasonCode: r.reasonCode,
  reasonLine: r.reasonLabel,
  verdictCode: verdict,
);

String _verdictOf(String reason) => switch (reason) {
  ResumeItemReasonCodes.duePassed => VerdictCodes.expired,
  ResumeItemReasonCodes.conservativeDefer => VerdictCodes.superseded,
  _ => VerdictCodes.blocked,
};

/// 표본 게이트와 비교(행 = 글자 그대로 · 동작 = id · 인자 · 글자).
void _sameGate(ResumeGateVm vm, ResumeGateVm fx, {bool headline = true}) {
  if (headline) expect(vm.headline, _plain(fx.headline));
  expect(vm.modeLabel, fx.modeLabel);
  expect(vm.level, fx.level);
  expect(vm.rows.length, fx.rows.length);
  for (final (int i, ResumeGateRow r) in fx.rows.indexed) {
    final ResumeGateRow g = vm.rows[i];
    expect(
      (g.workId, g.oneLine, g.reasonCode, g.reasonLabel, g.level),
      (r.workId, r.oneLine, r.reasonCode, r.reasonLabel, r.level),
    );
    expect(g.actions, <SafetyActionCall>[
      for (final SafetyActionCall a in r.actions)
        a.copyWith(label: _plain(a.label)),
    ]);
  }
  expect(vm.reportLink?.deepLink, fx.reportLink?.deepLink);
  expect(
    vm.reportLink?.label,
    fx.reportLink == null ? null : _plain(fx.reportLink!.label),
  );
  expect(vm.lockedLabel, fx.lockedLabel);
  expect(vm.asOf, fx.asOf);
}

ResumeGateVm _gateOf(
  ResumeGateVm fx, {
  bool incomplete = false,
  bool canChoose = true,
  String? locked,
  List<ResumeGateItem> extra = const <ResumeGateItem>[],
}) => resumeGateVmOf(
  run: ResumeGateRun(
    gapTradingDays: 2,
    mode: ResumeMode.normal,
    finished: true,
    headline: fx.headline,
    items: <ResumeGateItem>[
      ...extra,
      for (final ResumeGateRow r in fx.rows) _item(r, _verdictOf(r.reasonCode)),
    ],
  ),
  incomplete: incomplete,
  canChoose: canChoose,
  hasBody: _all,
  nowUtc: fx.asOf.observedAt,
  lockedLabel: locked,
);

void main() {
  group('리포트(K156)', () {
    for (final String f in <String>[
      'resume_report_screen_normal',
      'resume_report_screen_recovery_full',
      'resume_report_screen_empty',
    ]) {
      test('$f = 표본(리포트 그대로 · 시각 · 단계 · 빈 문장 · 기준)', () {
        final ResumeReportVm fx = ResumeReportVm.fromJson(_row(f));
        final ResumeReportVm vm = resumeReportVmOf(
          report: fx.report,
          nowUtc: fx.asOf.observedAt,
        );
        expect(vm.report, fx.report);
        expect(
          vm.periodText,
          fx.periodText == null ? null : _plain(fx.periodText!),
        );
        expect(
          vm.phaseLabel,
          fx.phaseLabel == null ? null : _plain(fx.phaseLabel!),
        );
        expect(
          vm.emptyLabel,
          fx.emptyLabel == null ? null : _plain(fx.emptyLabel!),
        );
        expect(vm.asOf, fx.asOf);
        // C-59 ⑭.
        expect(vm.report == null, vm.emptyLabel != null);
        if (vm.report != null) {
          expect((vm.periodText, vm.phaseLabel), isNot((null, null)));
        }
      });
    }

    test('시각 — 같은 날 = 끝 시각만 · 날이 다르면 날짜까지(한국 시각)', () {
      expect(
        resumePeriodText(
          DateTime.utc(2026, 12, 22, 0, 12),
          DateTime.utc(2026, 12, 22, 0, 41),
        ),
        '12-22 09:12 ~ 09:41',
      );
      expect(
        resumePeriodText(
          DateTime.utc(2026, 12, 22, 14, 50),
          DateTime.utc(2026, 12, 22, 15, 10),
        ),
        '12-22 23:50 ~ 12-23 00:10',
      );
    });

    test('단계 글자 = 아홉 단계 모두 · 서로 다르다', () {
      final List<String> l = <String>[
        for (final ResumePhase p in ResumePhase.values)
          ResumeScreenTexts.phase(p),
      ];
      expect(l.toSet(), hasLength(ResumePhase.values.length));
      expect(ResumeScreenTexts.phase(ResumePhase.r8), '재개 마침');
    });
  });

  group('게이트(K64)', () {
    test('계절 대기 = 표본 seasonal_pending(행마다 3택 · 수준 WATCH · 리포트 링크)', () {
      final ResumeGateVm fx = ResumeGateVm.fromJson(
        _row('resume_gate_seasonal_pending'),
      );
      _sameGate(_gateOf(fx), fx);
    });

    test('보수 미룸 = 표본 conservative_defer(회차 차례 그대로)', () {
      final ResumeGateVm fx = ResumeGateVm.fromJson(
        _row('resume_gate_conservative_defer'),
      );
      final ResumeGateVm vm = resumeGateVmOf(
        run: ResumeGateRun(
          gapTradingDays: 4,
          mode: ResumeMode.conservative,
          finished: true,
          headline: fx.headline,
          items: <ResumeGateItem>[
            for (final ResumeGateRow r in fx.rows)
              _item(r, _verdictOf(r.reasonCode)),
          ],
        ),
        incomplete: false,
        canChoose: true,
        hasBody: _all,
        nowUtc: fx.asOf.observedAt,
      );
      _sameGate(vm, fx);
    });

    test('재판정 실패 = 표본 reevaluation_failed(플래그 활성 = BLOCKED)', () {
      final ResumeGateVm fx = ResumeGateVm.fromJson(
        _row('resume_gate_reevaluation_failed'),
      );
      _sameGate(_gateOf(fx, incomplete: true), fx);
    });

    test('막힌 계획 0 = 표본 clear(집행 예정 항목은 행이 아니다 · OK)', () {
      final ResumeGateVm fx = ResumeGateVm.fromJson(_row('resume_gate_clear'));
      final ResumeGateVm vm = _gateOf(
        fx,
        extra: const <ResumeGateItem>[
          ResumeGateItem(
            workId: 'pw_done',
            oneLine: '슬리브 B 정기 리밸런싱',
            reasonCode: ResumeItemReasonCodes.reevaluated,
            reasonLine: '12월 22일 재판정 값으로 다음 주문 회차에 넘겼습니다',
            verdictCode: VerdictCodes.executedAsReevaluated,
          ),
        ],
      );
      _sameGate(vm, fx);
    });

    test('🔴 잠김 = 표본 locked(행 동작 0 · 행 · 글자는 그대로)', () {
      final ResumeGateVm fx = ResumeGateVm.fromJson(_row('resume_gate_locked'));
      final ResumeGateVm vm = _gateOf(fx, locked: fx.lockedLabel);
      _sameGate(vm, fx);
      for (final ResumeGateRow r in vm.rows) {
        expect(r.actions, isEmpty);
      }
    });

    test('🔴 고르는 창구 없음 = 동작 0 · 리포트 본문 없음 = 링크 0', () {
      final ResumeGateVm fx = ResumeGateVm.fromJson(
        _row('resume_gate_seasonal_pending'),
      );
      expect(
        _gateOf(
          fx,
          canChoose: false,
        ).rows.expand((ResumeGateRow r) => r.actions),
        isEmpty,
      );
      expect(
        resumeGateVmOf(
          run: null,
          incomplete: false,
          canChoose: true,
          hasBody: (String _) => false,
          nowUtc: fx.asOf.observedAt,
        ).reportLink,
        isNull,
      );
    });

    test('회차 0 · 열린 회차 — 머리 · 수준(플래그 = BLOCKED)', () {
      final DateTime now = DateTime.utc(2026, 12, 22, 0, 45);
      final ResumeGateVm none = resumeGateVmOf(
        run: null,
        incomplete: false,
        canChoose: true,
        hasBody: _all,
        nowUtc: now,
      );
      expect(
        (none.headline, none.modeLabel, none.level),
        (
          ResumeScreenTexts.gateNoRun,
          ResumeScreenTexts.gateNoRunMode,
          UiLevel.ok,
        ),
      );
      expect(none.rows, isEmpty);
      expect(
        resumeGateVmOf(
          run: null,
          incomplete: true,
          canChoose: true,
          hasBody: _all,
          nowUtc: now,
        ).level,
        UiLevel.blocked,
      );
      final ResumeGateVm open = resumeGateVmOf(
        run: const ResumeGateRun(
          gapTradingDays: 3,
          mode: ResumeMode.recoveryDry,
          finished: false,
          headline: null,
          items: <ResumeGateItem>[],
        ),
        incomplete: true,
        canChoose: true,
        hasBody: _all,
        nowUtc: now,
      );
      expect(
        (open.headline, open.modeLabel, open.level),
        (ResumeScreenTexts.gateInProgress, '3거래일 미실행 — 복구 관찰', UiLevel.blocked),
      );
      // 열린 회차는 행이 있어도 머리 = 진행 중(엔진 머리말이 아직 없다).
      final ResumeGateVm openRows = resumeGateVmOf(
        run: const ResumeGateRun(
          gapTradingDays: 3,
          mode: ResumeMode.normal,
          finished: false,
          headline: null,
          items: <ResumeGateItem>[
            ResumeGateItem(
              workId: 'w1',
              oneLine: '한 줄',
              reasonCode: ResumeItemReasonCodes.duePassed,
              reasonLine: '유효기한(12월 19일)이 지났습니다',
              verdictCode: VerdictCodes.expired,
            ),
          ],
        ),
        incomplete: false,
        canChoose: true,
        hasBody: _all,
        nowUtc: now,
      );
      expect(
        (openRows.headline, openRows.level),
        (ResumeScreenTexts.gateInProgress, UiLevel.info),
      );
    });

    test(
      '🔴 사유 → 수준 = 사유 사전 전부 짝(던지지 않는다) · 멈춤 = BLOCKED · 사람 = ACT · 관찰 = WATCH',
      () {
        for (final String c in ResumeItemReasonCodes.values) {
          expect(() => resumeGateRowLevel(c), returnsNormally, reason: c);
        }
        expect(
          <String, UiLevel>{
            for (final String c in ResumeItemReasonCodes.values)
              c: resumeGateRowLevel(c),
          },
          <String, UiLevel>{
            ResumeItemReasonCodes.duePassed: UiLevel.info,
            ResumeItemReasonCodes.advisoryPending: UiLevel.act,
            ResumeItemReasonCodes.safetyStop: UiLevel.blocked,
            ResumeItemReasonCodes.observing: UiLevel.watch,
            ResumeItemReasonCodes.reconMismatch: UiLevel.blocked,
            ResumeItemReasonCodes.unknownOrders: UiLevel.blocked,
            ResumeItemReasonCodes.residualOrders: UiLevel.blocked,
            ResumeItemReasonCodes.humanDecision: UiLevel.act,
            ResumeItemReasonCodes.conservativeDefer: UiLevel.info,
            ResumeItemReasonCodes.reevaluatedEmpty: UiLevel.info,
            ResumeItemReasonCodes.reevaluated: UiLevel.info,
            ResumeItemReasonCodes.humanSkip: UiLevel.info,
            ResumeItemReasonCodes.humanReduced: UiLevel.info,
            ResumeItemReasonCodes.humanAsIs: UiLevel.info,
            ResumeItemReasonCodes.reevaluationFailed: UiLevel.blocked,
          },
        );
        expect(resumeGateRowLevel('NOT_A_CODE'), UiLevel.info);
      },
    );
  });

  group('🆕 계절 3택 결과(R195 · K54)', () {
    test('표본 m5/safety_action_results_e13 의 계절 행 = 글자 · 수준 · 코드 그대로', () {
      final List<Object?> rows =
          (jsonDecode(
                File(
                  '../domain_contracts/fixtures/m5/safety_action_results_e13.json',
                ).readAsStringSync(),
              ) as Map<String, Object?>)['rows']!
              as List<Object?>;
      int n = 0;
      for (final Object? r in rows) {
        final SafetyActionResult fx = SafetyActionResult.fromJson(
          r! as Map<String, dynamic>,
        );
        if (fx.id != SafetyActionId.seasonalWindowChoice) continue;
        final SafetyActionResult got = seasonalChoiceResultOf(
          actionRunId: fx.actionRunId,
          code: fx.reasonCode,
        );
        expect(
          (got.id, got.level, got.headline, got.reasonCode, got.retryable),
          (fx.id, fx.level, _plain(fx.headline), fx.reasonCode, fx.retryable),
          reason: '${fx.reasonCode}',
        );
        n++;
      }
      expect(n, 4);
    });

    test(
      '🔴 거부 사전 = 계절 결과 코드 ∪ 계획 전이 코드 ∪ 멈춤 사유 7 ∪ 생체 전부 짝 · 모르는 코드 = 오류',
      () {
        for (final String c in <String>{
          ...SeasonalChoiceResultCodes.values,
          ...PlannedWorkRejectCodes.values,
          ResumeItemReasonCodes.advisoryPending,
          ResumeItemReasonCodes.safetyStop,
          ResumeItemReasonCodes.observing,
          ResumeItemReasonCodes.reconMismatch,
          ResumeItemReasonCodes.unknownOrders,
          ResumeItemReasonCodes.residualOrders,
          ResumeItemReasonCodes.reevaluationFailed,
          'BIOMETRIC_UNAVAILABLE',
        }) {
          expect(
            () => seasonalChoiceResultOf(actionRunId: 'r', code: c),
            returnsNormally,
            reason: c,
          );
        }
        expect(
          () => seasonalChoiceResultOf(actionRunId: 'r', code: 'NOPE'),
          throwsArgumentError,
        );
        expect(seasonalChoiceResultOf(actionRunId: 'r').level, UiLevel.ok);
      },
    );
  });
}
