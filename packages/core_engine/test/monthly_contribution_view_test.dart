// E11q3 — M9 S13 월 납입 VM · 바꾸기 결과 · 실입금 등록 발행(설계 13 §8 R174).
//
// 🔴 VM = `ContributionSetting` 1:1 투영 + 버튼 글자 · 결과 = 엔진 거부 문장 그대로 + 표본 수준 · 표본 `m9/contribution_action_results`
//    와 글자 · 수준이 같다(생체 = 이 조각 밖 · 접수 문장의 «(합성)» 표지 제외).
// 🔴 등록 발행 = TTL 30분 · 신뢰 시각 모름 = 거부 접수증(`TRUSTED_TIME_UNKNOWN` · «거부됨 — » 머리).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, Object?> _fx(String path) =>
    jsonDecode(File('../domain_contracts/fixtures/$path').readAsStringSync())
        as Map<String, Object?>;

void main() {
  test('S13 VM = ContributionSetting 1:1 투영 · 버튼 글자 = 표본 monthly_contribution · 버튼 = 쓰기 창구가 있을 때만', () {
    final Map<String, Object?> sj = _fx('m9/contribution_setting_default.json');
    final ContributionSetting s = ContributionSetting.fromJson(
      (sj['rows'] is List<Object?>
              ? (sj['rows']! as List<Object?>).first
              : sj['data'] ?? sj)!
          as Map<String, Object?>,
    );
    final MonthlyContributionVm vm = monthlyContributionVmOf(
      s,
      canChange: true,
    );
    final Map<String, Object?> want =
        (_fx('m9/monthly_contribution.json')['rows']! as List<Object?>).first!
            as Map<String, Object?>;
    final MonthlyContributionVm fx = MonthlyContributionVm.fromJson(want);
    // 두 표본은 기준일이 다른 합성이라 쌍이 아니다 — 투영은 입력과, 버튼 글자 · 편집 여부는 표본과 대조한다.
    expect(vm.amountText, s.amountText);
    expect(vm.amountInputText, s.amountInputText);
    expect(vm.equivalentNoteText, s.equivalentNoteText);
    expect(vm.appliesFromText, s.appliesFromText);
    expect(vm.lastChangedText, s.lastChangedText);
    expect(vm.pensionLimitNoteText, s.pensionLimitNoteText);
    expect(vm.changeLabel, fx.changeLabel);
    expect(vm.editable, fx.editable);
    expect(vm.lockedLabel, isNull);
    expect(vm.asOf, s.asOf);
    final MonthlyContributionVm off = monthlyContributionVmOf(
      s,
      canChange: false,
    );
    expect(off.changeLabel, isNull);
    expect(off.editable, isFalse);
  });

  test(
    '바꾸기 결과 = 표본 contribution_action_results 글자 · 수준(생체 제외) · 엔진 판정 문장 그대로',
    () {
      final List<Object?> rows =
          _fx('m9/contribution_action_results.json')['rows']! as List<Object?>;
      int checked = 0;
      for (final Object? o in rows) {
        final ActionResult fx = ActionResult.fromJson(
          o! as Map<String, Object?>,
        );
        if (fx.reasonCode == 'BIOMETRIC_UNAVAILABLE') continue;
        final ActionResult got = contributionUpdateResultOf(
          actionRunId: fx.actionRunId,
          reasonCode: fx.reasonCode,
          rejectedText: fx.reasonCode == null ? null : fx.headline,
        );
        expect(got.level, fx.level, reason: '${fx.reasonCode}');
        expect(got.id, fx.id);
        expect(got.retryable, fx.retryable);
        expect(got.handoffRoute, isNull);
        expect(
          got.headline,
          fx.headline.replaceFirst('(합성) ', ''),
          reason: '${fx.reasonCode}',
        );
        checked++;
      }
      expect(checked, 8);
      // 엔진 판정 문장이 표본 문장과 같다(신뢰 시각 모름).
      final ContributionDecision d = decideContributionChange(
        amountInput: '200000',
        actionRunId: 'ar_1',
        rows: const <ContributionParamRow>[],
        trustedNowUtc: null,
        kr: frozenExchangeCalendar(Market.kr),
        config: p0sContributionConfig(),
      );
      final ActionResult t = contributionUpdateResultOf(
        actionRunId: 'ar_1',
        reasonCode: d.reasonCode,
        rejectedText: d.rejectedText,
      );
      expect(t.level, UiLevel.blocked);
      expect(t.headline, '서버 시각을 확인하지 못해 지금은 바꿀 수 없습니다. 연결을 확인한 뒤 다시 시도해 주세요.');
      expect(
        () => contributionUpdateResultOf(
          actionRunId: 'x',
          reasonCode: 'NOPE',
          rejectedText: '?',
        ),
        throwsArgumentError,
      );
      expect(
        () => contributionUpdateResultOf(
          actionRunId: 'x',
          reasonCode: ContributionRejectCodes.blank,
          rejectedText: null,
        ),
        throwsArgumentError,
      );
    },
  );

  test('실입금 등록 발행 = TTL 30분 · 신뢰 시각 모름 = 거부 접수증(«거부됨 — » + 서버 시각 문장)', () {
    final DateTime at = DateTime.utc(2026, 11, 20, 9);
    final DepositRegisterCommand c = issueDepositRegister(
      planId: 'pv_dep_20261120_01',
      requestedAtUtc: at,
      deviceId: 'dev-1',
      random: Random(7),
    );
    expect(c.planId, 'pv_dep_20261120_01');
    expect(c.requestedAt, at);
    expect(c.expiresAt, at.add(kDepositRegisterTtl));
    expect(kDepositRegisterTtl, const Duration(minutes: 30));
    expect(c.issuedByDeviceId, 'dev-1');
    expect(c.nonce, hasLength(32));
    expect(
      issueDepositRegister(
        planId: 'p',
        requestedAtUtc: at,
        deviceId: 'd',
        random: Random(8),
      ).commandId,
      isNot(c.commandId),
    );
    final CommandReceipt r = depositTrustedTimeUnknownReceipt(c);
    expect(r.state, CommandState.rejected);
    expect(r.kind, CommandKind.depositRegister);
    expect(r.rejectReasonCode, 'TRUSTED_TIME_UNKNOWN');
    expect(
      r.stateLabel,
      '${DepositRegisterTexts.rejectedHead}${DepositIssueTexts.trustedTimeUnknown}',
    );
    expect(r.commandId, c.commandId);
  });
}
