// E11p4h — 서약 읽기 모델 · 동작 결과(설계 13 §8 R157) — 기대값 = 계약 표본(`m5/pledge_*` · `m5/safety_action_results`).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

List<Map<String, dynamic>> _rows(String name) {
  final Map<String, dynamic> j = jsonDecode(
    File('../domain_contracts/fixtures/m5/$name').readAsStringSync(),
  ) as Map<String, dynamic>;
  return <Map<String, dynamic>>[
    for (final Object? r in j['rows'] as List<Object?>)
      r! as Map<String, dynamic>,
  ];
}

PledgeVm _vm(String name) => PledgeVm.fromJson(_rows(name).single);

final DateTime _now = DateTime.utc(2026, 11, 16, 3);

Pledge _pledge(List<String> lines) =>
    Pledge(version: 1, lines: lines, writtenAtUtc: DateTime.utc(2026, 11, 1));

void main() {
  test('🔴 표본 그대로 — 첫 판 없음 = 0줄 · 판 있음(11월) = 세 줄 · 12월 신뢰 시각 = 편집 가능', () {
    expect(
      pledgeVmOf(current: null, trustedNowUtc: _now, nowUtc: _now),
      _vm('pledge_not_written.json'),
    );
    final PledgeVm written = _vm('pledge_written.json');
    final Pledge p = _pledge(written.lines);
    expect(pledgeVmOf(current: p, trustedNowUtc: _now, nowUtc: _now), written);
    final DateTime dec = DateTime.utc(2026, 12, 3, 3);
    expect(
      pledgeVmOf(current: p, trustedNowUtc: dec, nowUtc: dec),
      _vm('pledge_edit_window.json'),
    );
  });

  test('🔴 편집 가능 = 판 있음 ∧ 신뢰 시각의 한국 12월(경계 · 시각 모름 · 판 없음)', () {
    final Pledge p = _pledge(<String>['가', '나', '다']);
    bool editable(Pledge? c, DateTime? t) =>
        pledgeVmOf(current: c, trustedNowUtc: t, nowUtc: _now).editable;
    expect(editable(p, DateTime.utc(2026, 11, 30, 14, 59)), isFalse);
    expect(editable(p, DateTime.utc(2026, 11, 30, 15)), isTrue);
    expect(editable(p, DateTime.utc(2026, 12, 31, 14, 59)), isTrue);
    expect(editable(p, DateTime.utc(2026, 12, 31, 15)), isFalse);
    expect(editable(p, null), isFalse);
    expect(editable(null, DateTime.utc(2026, 12, 2)), isFalse);
    final PledgeVm vm = pledgeVmOf(
      current: p,
      trustedNowUtc: DateTime.utc(2026, 12, 2),
      nowUtc: _now,
    );
    expect(vm.statusLine, isNull);
    expect(vm.replayNotice, isNull);
    expect(vm.lockedLabel, isNull);
    expect(vm.lines, <String>['가', '나', '다']);
  });

  test('🔴 제출 지문 = 제출 JSON 의 SHA-256(문장 · 동작이 다르면 다르다)', () {
    const PledgeSubmission a = PledgeSubmission(
      id: SafetyActionId.pledgeWrite,
      sentences: <String>['가', '나', '다'],
    );
    final String d = pledgeSubmissionDigest(a);
    expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(d), isTrue, reason: d);
    expect(pledgeSubmissionDigest(a), d);
    expect(
      pledgeSubmissionDigest(
        const PledgeSubmission(
          id: SafetyActionId.pledgeWrite,
          sentences: <String>['가', '나', '라'],
        ),
      ),
      isNot(d),
    );
    expect(
      pledgeSubmissionDigest(
        const PledgeSubmission(
          id: SafetyActionId.pledgeEdit,
          sentences: <String>['가', '나', '다'],
        ),
      ),
      isNot(d),
    );
  });

  test('🔴 기준 줄 = 한국 시각(분까지) · 26시간', () {
    final AsOf a = pledgeAsOf(DateTime.utc(2026, 11, 30, 15, 7));
    expect(a.label, '서약 기준 2026-12-01 00:07');
    expect(a.tradeDate, const TradeDate('2026-12-01'));
    expect(a.source, AsOfSource.localSqlite);
    expect(a.staleAfter, const Duration(hours: 26));
    expect(a.observedAt, DateTime.utc(2026, 11, 30, 15, 7));
  });

  test('🔴 결과 = 표본 행 그대로(서약 동작 전부 · 등급 · 문장 · 코드)', () {
    int seen = 0;
    for (final Map<String, dynamic> r in _rows('safety_action_results.json')) {
      final SafetyActionResult want = SafetyActionResult.fromJson(r);
      if (want.id != SafetyActionId.pledgeWrite &&
          want.id != SafetyActionId.pledgeEdit) {
        continue;
      }
      seen++;
      expect(
        pledgeActionResultOf(
          actionRunId: want.actionRunId,
          id: want.id,
          reasonCode: want.reasonCode,
        ),
        want,
        reason: '${want.id} ${want.reasonCode}',
      );
    }
    expect(seen, greaterThanOrEqualTo(5), reason: '표본 서약 행(공허 방지)');
  });

  test(
    '🔴 서약 코드 전부 문장이 있다 · 모르는 코드 = StateError · 서약 아닌 동작 = ArgumentError',
    () {
      for (final String c in <String>[
        PledgeCodes.alreadyWritten,
        PledgeCodes.journalMissing,
        PledgeCodes.notWritten,
        PledgeCodes.outOfWindow,
        PledgeCodes.sentencesMissing,
        PledgeCodes.unchanged,
        PledgeCodes.trustedTimeUnknown,
      ]) {
        final SafetyActionResult r = pledgeActionResultOf(
          actionRunId: 'a',
          id: SafetyActionId.pledgeWrite,
          reasonCode: c,
        );
        expect(r.headline, isNotEmpty, reason: c);
        expect(r.level, isNot(UiLevel.ok), reason: c);
        expect(r.reasonCode, c);
        expect(r.retryable, isFalse);
        expect(r.handoffRoute, isNull);
      }
      expect(
        pledgeActionResultOf(
          actionRunId: 'a',
          id: SafetyActionId.pledgeEdit,
          reasonCode: null,
        ).headline,
        PledgeResultTexts.edited,
      );
      expect(
        () => pledgeActionResultOf(
          actionRunId: 'a',
          id: SafetyActionId.pledgeWrite,
          reasonCode: 'X',
        ),
        throwsStateError,
      );
      expect(
        () => pledgeActionResultOf(
          actionRunId: 'a',
          id: SafetyActionId.killSwitchResume,
          reasonCode: null,
        ),
        throwsArgumentError,
      );
    },
  );
}
