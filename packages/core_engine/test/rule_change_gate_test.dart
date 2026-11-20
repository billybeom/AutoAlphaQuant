// E11q-c0 — M5-9 규칙 변경 게이트 «첫 승인 최소판»(설계 13 §8 R188 · 01 §35 K177~K180).
//
// 🔴 표본 `m5/rule_change_gate_*` 와 글자 · 수준 · 차례가 같다(«(합성)» 표지 제외 · 후보 id = 엔진 지문) · 결과 표본
//    `m5/rule_change_request_results` · `m5/safety_action_results_e13` 글자 같음 · 잠김 · 쓰기 창구 없음 = 동작 0 · 안전 수치 그대로.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

List<Map<String, Object?>> _rows(String f) => <Map<String, Object?>>[
  for (final Object? r
      in (jsonDecode(
            File('../domain_contracts/fixtures/m5/$f.json').readAsStringSync(),
          ) as Map<String, Object?>)['rows']!
          as List<Object?>)
    r! as Map<String, Object?>,
];

String _plain(String s) => s.replaceFirst('(합성) ', '');

const String _hash = '3f2a9c1d00aa11bb22cc33dd';
final DateTime _requested = DateTime.utc(2026, 12, 10, 1, 5); // 10:05 KST

RuleChangeGateItem _item({String before = kNoApprovedConfig}) =>
    RuleChangeGateItem(
      requestId: 'rc_req_1210',
      changeType: RuleChangeType.strategyRule,
      hashBefore: before,
      hashAfter: _hash,
      requestedAtUtc: _requested,
    );

RuleChangeGateVm _vm({
  String approved = kNoApprovedConfig,
  String? current = _hash,
  bool registered = true,
  List<RuleChangeGateItem> open = const <RuleChangeGateItem>[],
  double dd = 0,
  DateTime? trusted,
  required DateTime now,
  bool canWrite = true,
  String? locked,
}) => ruleChangeGateVmOf(
  approvedHash: approved,
  currentHash: current,
  currentRegistered: registered,
  open: open,
  drawdown: dd,
  trustedNowUtc: trusted,
  nowUtc: now,
  canWrite: canWrite,
  lockedLabel: locked,
);

/// 표본과 비교(글자 = «(합성)» 뗌 · 후보 id 는 엔진 지문이라 비교 밖).
void _same(RuleChangeGateVm vm, RuleChangeGateVm fx) {
  expect(vm.headline, _plain(fx.headline));
  expect(vm.level, fx.level);
  expect(vm.windowText, fx.windowText == null ? null : _plain(fx.windowText!));
  expect(vm.candidates.length, fx.candidates.length);
  for (final (int i, RuleChangeCandidateRow c) in fx.candidates.indexed) {
    final RuleChangeCandidateRow g = vm.candidates[i];
    expect(
      (g.label, g.categoryLabel, g.hashText, g.requestLabel, g.noticeText),
      (
        _plain(c.label),
        _plain(c.categoryLabel),
        _plain(c.hashText),
        _plain(c.requestLabel),
        c.noticeText == null ? null : _plain(c.noticeText!),
      ),
    );
  }
  expect(vm.rows.length, fx.rows.length);
  for (final (int i, RuleChangeQueueRow r) in fx.rows.indexed) {
    final RuleChangeQueueRow g = vm.rows[i];
    expect(
      (
        g.requestId,
        g.categoryLabel,
        g.hashText,
        g.requestedText,
        g.coolingText,
        g.stateLabel,
        g.level,
        g.approveLabel,
      ),
      (
        r.requestId,
        _plain(r.categoryLabel),
        _plain(r.hashText),
        _plain(r.requestedText),
        _plain(r.coolingText),
        _plain(r.stateLabel),
        r.level,
        r.approveLabel == null ? null : _plain(r.approveLabel!),
      ),
    );
    expect(g.cancel, r.cancel?.copyWith(label: _plain(r.cancel!.label)));
  }
  expect(vm.emptyLabel, fx.emptyLabel == null ? null : _plain(fx.emptyLabel!));
  expect(vm.lockedLabel, fx.lockedLabel);
  expect(vm.asOf, fx.asOf);
}

RuleChangeGateVm _fx(String f) =>
    RuleChangeGateVm.fromJson(_rows('rule_change_gate_$f').first);

void main() {
  group('게이트 = 표본', () {
    test(
      'first_candidate — 승인 0 · 지금 등재 · 요청 0 → 후보 1(전략 규칙 · 승인 없음 → 지문)',
      () {
        final RuleChangeGateVm fx = _fx('first_candidate');
        final RuleChangeGateVm vm = _vm(
          now: fx.asOf.observedAt,
          trusted: fx.asOf.observedAt,
        );
        _same(vm, fx);
        expect(vm.candidates.single.candidateId, _hash);
      },
    );

    test('cooling — 첫 승인 요청 냉각 중(후보 0 · 취소만)', () {
      final RuleChangeGateVm fx = _fx('cooling');
      _same(
        _vm(
          open: <RuleChangeGateItem>[_item()],
          now: fx.asOf.observedAt,
          trusted: fx.asOf.observedAt,
        ),
        fx,
      );
    });

    test('approvable — 냉각 끝 · 승인 폼 글자 · 첫 승인 = 12월 창 · DD 락 면제', () {
      final RuleChangeGateVm fx = _fx('approvable');
      _same(
        _vm(
          open: <RuleChangeGateItem>[_item()],
          dd: -0.30,
          now: fx.asOf.observedAt,
          trusted: fx.asOf.observedAt,
        ),
        fx,
      );
    });

    test('empty — 지금 설정이 승인됨 · 열린 요청 0(창 글자 0)', () {
      final RuleChangeGateVm fx = _fx('empty');
      _same(
        _vm(
          approved: _hash,
          now: fx.asOf.observedAt,
          trusted: fx.asOf.observedAt,
        ),
        fx,
      );
    });

    test('🔴 locked — 잠김 = 요청 · 승인 · 취소 0(행 글자는 그대로)', () {
      final RuleChangeGateVm fx = _fx('locked');
      _same(
        _vm(
          open: <RuleChangeGateItem>[_item()],
          now: fx.asOf.observedAt,
          trusted: fx.asOf.observedAt,
          locked: fx.lockedLabel,
        ),
        fx,
      );
    });
  });

  group('판정', () {
    final DateTime now = DateTime.utc(2027, 1, 9, 3);

    test('🔴 쓰기 창구 없음 = 후보 · 승인 · 취소 0 · 잠김에 후보도 0', () {
      final RuleChangeGateVm none = _vm(
        now: now,
        trusted: now,
        canWrite: false,
      );
      expect(none.candidates, isEmpty);
      expect(none.headline, RuleChangeGateTexts.headlineFirst);
      final RuleChangeGateVm rows = _vm(
        open: <RuleChangeGateItem>[_item()],
        now: now,
        trusted: now,
        canWrite: false,
      );
      expect(
        (rows.rows.single.approveLabel, rows.rows.single.cancel),
        (null, null),
      );
      expect(_vm(now: now, trusted: now, locked: '잠김').candidates, isEmpty);
    });

    test('🔴 신뢰 시각 모름 = 승인 0 · 냉각 글자 = 확인 못 함 · 취소 자리는 남는다(결과로 거부)', () {
      final RuleChangeQueueRow r = _vm(
        open: <RuleChangeGateItem>[_item()],
        now: now,
      ).rows.single;
      expect(
        (r.coolingText, r.stateLabel, r.level, r.approveLabel),
        (
          '서버 시각을 확인하지 못했습니다 — 01-09 10:05 이후 승인',
          RuleChangeGateTexts.stateTimeUnknown,
          UiLevel.watch,
          null,
        ),
      );
      expect(r.cancel, isNotNull);
    });

    test('후보 = 승인 0 ∧ 등재 ∧ 그 지문의 열린 요청 0 · 지금 설정 0 · 지금 ≠ 승인 = 문장', () {
      expect(_vm(now: now, registered: false).candidates, isEmpty);
      final RuleChangeGateVm noCfg = _vm(now: now, current: null);
      expect(
        (noCfg.headline, noCfg.level, noCfg.emptyLabel, noCfg.windowText),
        (
          RuleChangeGateTexts.headlineNoConfig,
          UiLevel.info,
          RuleChangeGateTexts.emptyNoConfig,
          RuleChangeGateTexts.windowFirst,
        ),
      );
      final RuleChangeGateVm differs = _vm(approved: 'a1b2c3d4ffff', now: now);
      expect(
        (differs.headline, differs.level, differs.emptyLabel),
        (
          RuleChangeGateTexts.headlineDiffers,
          UiLevel.watch,
          RuleChangeGateTexts.emptyDiffers,
        ),
      );
      expect(differs.candidates, isEmpty);
      // 다른 지문의 열린 요청은 후보를 막지 않는다.
      expect(
        ruleChangeCandidateOf(
          approvedHash: kNoApprovedConfig,
          currentHash: _hash,
          currentRegistered: true,
          open: <RuleChangeGateItem>[
            RuleChangeGateItem(
              requestId: 'x',
              changeType: RuleChangeType.strategyRule,
              hashBefore: kNoApprovedConfig,
              hashAfter: 'otherhash',
              requestedAtUtc: _requested,
            ),
          ],
        )?.candidateId,
        _hash,
      );
    });

    test('🔴 둘째 승인 — 12월 창 밖 · DD 락 = 승인 0 · BLOCKED(첫 승인 면제는 첫 승인뿐)', () {
      final RuleChangeGateItem second = _item(before: 'a1b2c3d4ffff');
      final RuleChangeQueueRow out = _vm(
        approved: 'a1b2c3d4ffff',
        open: <RuleChangeGateItem>[second],
        now: now,
        trusted: now,
      ).rows.single;
      expect(
        (out.stateLabel, out.level, out.approveLabel, out.hashText),
        (
          RuleChangeGateTexts.stateBlocked,
          UiLevel.blocked,
          null,
          'a1b2c3d4 → 3f2a9c1d',
        ),
      );
      final DateTime dec = DateTime.utc(2027, 12, 20, 3);
      expect(
        ruleChangeApprovable(
          item: second,
          approvedHash: 'a1b2c3d4ffff',
          drawdown: -0.10,
          trustedNowUtc: dec,
        ),
        false,
      );
      expect(
        ruleChangeApprovable(
          item: second,
          approvedHash: 'a1b2c3d4ffff',
          drawdown: -0.05,
          trustedNowUtc: dec,
        ),
        true,
      );
      // 냉각 30일 그대로 — 끝나기 1분 전은 승인 0.
      expect(
        ruleChangeApprovable(
          item: _item(),
          approvedHash: kNoApprovedConfig,
          drawdown: 0,
          trustedNowUtc: _requested
              .add(kRuleChangeCooling)
              .subtract(const Duration(minutes: 1)),
        ),
        false,
      );
    });
  });

  group('결과 글자 = 표본', () {
    for (final String f in <String>[
      'rule_change_request_results',
      'safety_action_results_e13',
    ]) {
      test(f, () {
        int n = 0;
        for (final Map<String, Object?> row in _rows(f)) {
          final SafetyActionResult fx = SafetyActionResult.fromJson(row);
          if (!<SafetyActionId>{
            SafetyActionId.ruleChangeRequest,
            SafetyActionId.ruleChangeCancel,
            SafetyActionId.ruleChangeApprove,
          }.contains(fx.id)) {
            continue;
          }
          final SafetyActionResult got = ruleChangeActionResultOf(
            id: fx.id,
            actionRunId: fx.actionRunId,
            code: fx.reasonCode,
          );
          expect(
            (got.level, got.headline, got.reasonCode, got.retryable),
            (fx.level, _plain(fx.headline), fx.reasonCode, fx.retryable),
            reason: '${fx.id.wire} ${fx.reasonCode}',
          );
          n++;
        }
        expect(n, greaterThan(0));
      });
    }

    test('🔴 결과 사전 = 계약 결과 코드 전부 짝(요청 · 승인) · 모르는 코드 = 오류', () {
      for (final String c in <String>[
        RuleChangeCodes.fieldsMissing,
        RuleChangeCodes.journalMissing,
        RuleChangeCodes.configUnknown,
        RuleChangeCodes.baseStale,
        RuleChangeCodes.trustedTimeUnknown,
        kJournalIdTaken,
        kBiometricUnavailable,
      ]) {
        expect(
          () => ruleChangeActionResultOf(
            id: SafetyActionId.ruleChangeRequest,
            actionRunId: 'r',
            code: c,
          ),
          returnsNormally,
          reason: c,
        );
      }
      for (final String c in <String>[
        RuleChangeCodes.cooling,
        RuleChangeCodes.ddLocked,
        RuleChangeCodes.thirdPartyMissing,
        RuleChangeCodes.approvalFieldsMissing,
        RuleChangeCodes.outOfWindow,
        RuleChangeCodes.decided,
        RuleChangeCodes.notFound,
        RuleChangeCodes.baseStale,
        RuleChangeCodes.trustedTimeUnknown,
      ]) {
        expect(
          () => ruleChangeActionResultOf(
            id: SafetyActionId.ruleChangeApprove,
            actionRunId: 'r',
            code: c,
          ),
          returnsNormally,
          reason: c,
        );
      }
      expect(
        () => ruleChangeActionResultOf(
          id: SafetyActionId.ruleChangeRequest,
          actionRunId: 'r',
          code: 'NOPE',
        ),
        throwsArgumentError,
      );
      expect(
        () => ruleChangeActionResultOf(
          id: SafetyActionId.pledgeWrite,
          actionRunId: 'r',
        ),
        throwsArgumentError,
      );
    });
  });
}
