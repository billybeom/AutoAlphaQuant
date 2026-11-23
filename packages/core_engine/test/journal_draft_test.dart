// 🆕 미결 220 ⓔⓕ — J-3 사전 저널 쓰기(순수 · 계약 v1.35 01 §44 K296 ~ K300).
//
// 🔵 잡는 것: ① 새 행 키 발급 · 해석(목적 = 키 · 엔진 꼴 밖 = 모름) ② 키 → 갈래(채우기 · 새 행 · 모름) ③ 폼 스펙 = 표본 글자
//    (선택지 3 · 최소 글자 · 고지 · 재량 칩 · 재량 배지 «n회째») · 서약 줄 = 재량 예산 목적만 · 대상 문맥 칩 0 ④ 입력 판정 =
//    화면 «제출 가능 조건» ⑤ 갈래 판정(대상 없음 · 이미 있음 · 입력) ⑥ 접수증 글자 = 표본 · 명령(TTL · 종류 · digest).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, Object?> _row(String rel, [int i = 0]) =>
    ((jsonDecode(File('../domain_contracts/fixtures/$rel').readAsStringSync())
                as Map<String, Object?>)['rows']!
            as List<Object?>)[i]!
        as Map<String, Object?>;

List<Map<String, Object?>> _rows(String rel) => <Map<String, Object?>>[
  for (final Object? r
      in (jsonDecode(
            File('../domain_contracts/fixtures/$rel').readAsStringSync(),
          ) as Map<String, Object?>)['rows']!
          as List<Object?>)
    r! as Map<String, Object?>,
];

final DateTime _now = DateTime.utc(2026, 8, 31, 0, 40);

const String _rationale40 = '근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거';

JournalDraft _draft({
  String key = 'J-1',
  String rationale = _rationale40,
  String expected = '기대',
  String rule = JournalRuleCitedCodes.discretionBudget,
  String? note,
}) => JournalDraft(
  decisionId: key,
  rationaleBefore: rationale,
  expectedOutcome: expected,
  ruleCited: rule,
  note: note,
);

void main() {
  group('① 새 행 키(ⓕ)', () {
    test('발급 = JD-<목적>-<16 hex> · 해석 왕복 · 목적 밖 = ArgumentError', () {
      final Random r = Random(3);
      for (final String p in DecisionJournalKinds.draftPurposes) {
        final String k = issueJournalDraftKey(purpose: p, random: r);
        expect(k, matches(RegExp('^JD-$p-[0-9a-f]{16}\$')));
        expect(journalDraftPurposeOfKey(k), p);
      }
      expect(
        issueJournalDraftKey(purpose: 'DISCRETION', random: Random(1)),
        isNot(issueJournalDraftKey(purpose: 'DISCRETION', random: Random(2))),
      );
      expect(
        () => issueJournalDraftKey(
          purpose: DecisionJournalKinds.reconClear,
          random: r,
        ),
        throwsArgumentError,
      );
    });

    test('엔진 꼴 밖 = null(접두 · 목적 · nonce 길이 · 대문자 · 결정 id)', () {
      for (final String k in <String>[
        'DISCRETION-0011223344556677',
        'JD-RECON_CLEAR-0011223344556677',
        'JD-DISCRETION-00112233445566',
        'JD-DISCRETION-00112233445566778',
        'JD-DISCRETION-00112233445566AA',
        'JD-DISCRETION',
        'JD--0011223344556677',
        'B-SMA-2026-07-31@2026-08-04',
      ]) {
        expect(journalDraftPurposeOfKey(k), isNull, reason: k);
      }
      expect(
        journalDraftPurposeOfKey('JD-PLEDGE_EDIT-0011223344556677'),
        'PLEDGE_EDIT',
      );
    });
  });

  group('② 키 → 갈래(K297)', () {
    test('행 = 채우기 · 행 없음 + 엔진 키 = 새 행 · 그 밖 = 모름', () {
      const JournalDraftFill row = JournalDraftFill(
        'JIV-1',
        isDeviation: true,
        kind: 'INTERVENTION_JOURNAL',
      );
      expect(journalDraftTargetOf('JIV-1', row), same(row));
      final JournalDraftTarget? n = journalDraftTargetOf(
        'JD-DISCRETION-0011223344556677',
        null,
      );
      expect(n, isA<JournalDraftNew>());
      expect((n! as JournalDraftNew).purpose, 'DISCRETION');
      expect((n as JournalDraftNew).isDeviation, isTrue);
      expect(
        (journalDraftTargetOf('JD-PLEDGE_EDIT-0011223344556677', null)!
                as JournalDraftNew)
            .isDeviation,
        isFalse,
      );
      expect(journalDraftTargetOf('JIV-1', null), isNull);
    });
  });

  group('③ 폼 스펙 = 표본', () {
    final Map<String, Object?> disc = _row(
      'm6/journal_draft_spec_discretion.json',
    );
    final Map<String, Object?> recon = _row(
      'm6/journal_draft_spec_recon_clear.json',
    );
    const List<String> lines = <String>['하나', '둘', '셋'];
    const DiscretionBudget oneUsed = DiscretionBudget(
      used: 1,
      max: 4,
      nextRecoveryDate: '2027-03-01',
    );

    test('선택지 3 · 최소 글자 · 고지 = 표본 그대로(두 표본 같은 목록)', () {
      final JournalDraftFormSpec s = journalDraftFormSpecOf(
        const JournalDraftNew(
          'JD-DISCRETION-0011223344556677',
          purpose: 'DISCRETION',
        ),
        pledgeLines: lines,
        budget: oneUsed,
        nowUtc: _now,
      );
      for (final Map<String, Object?> fx in <Map<String, Object?>>[
        disc,
        recon,
      ]) {
        expect(<Map<String, Object?>>[
          for (final ReasonOption o in s.ruleCitedOptions)
            <String, Object?>{
              'code': o.code,
              'label': o.label,
              'requires_note': o.requiresNote,
            },
        ], fx['rule_cited_options']);
        expect(s.rationaleMinChars, fx['rationale_min_chars']);
      }
      expect(s.noticeLine, disc['notice_line']);
      expect(s.decisionId, 'JD-DISCRETION-0011223344556677');
      expect(s.asOf.label, '저널 기준 2026-08-31');
    });

    test('재량 새 행 = 서약 줄 · 재량 칩 · 배지 «n회째»(표본 글자) · 신뢰 시각 모름 = 머리만 · 소진', () {
      final JournalDraftFormSpec s = journalDraftFormSpecOf(
        const JournalDraftNew(
          'JD-DISCRETION-0011223344556677',
          purpose: 'DISCRETION',
        ),
        pledgeLines: lines,
        budget: oneUsed,
        nowUtc: _now,
      );
      expect(s.pledgeLines, lines);
      expect(
        s.contextChips.map((ReasonChip c) => c.toJson()).toList(),
        disc['context_chips'],
      );
      expect(
        s.deviation,
        DeviationBadge.fromJson(disc['deviation']! as Map<String, Object?>),
      );
      expect(
        journalDraftFormSpecOf(
          const JournalDraftNew('k', purpose: 'DISCRETION'),
          pledgeLines: lines,
          budget: null,
          nowUtc: _now,
        ).deviation.label,
        '재량 조정',
      );
      expect(
        journalDraftFormSpecOf(
          const JournalDraftNew('k', purpose: 'DISCRETION'),
          pledgeLines: lines,
          budget: const DiscretionBudget(
            used: 4,
            max: 4,
            nextRecoveryDate: '2027-03-01',
          ),
          nowUtc: _now,
        ).deviation.label,
        '재량 조정 (롤링 12개월 4회 소진)',
      );
    });

    test('서약 편집 새 행 = 서약 0줄 · 이탈 아님 · 목적 칩', () {
      final JournalDraftFormSpec s = journalDraftFormSpecOf(
        const JournalDraftNew('k', purpose: 'PLEDGE_EDIT'),
        pledgeLines: lines,
        budget: oneUsed,
        nowUtc: _now,
      );
      expect(s.pledgeLines, isEmpty);
      expect(s.deviation.isDeviation, isFalse);
      expect(s.deviation.kindCode, isNull);
      expect(s.contextChips.single.code, 'PLEDGE_EDIT');
      expect(s.contextChips.single.label, '서약 편집');
    });

    test('채우기 — RECON 해제 · 개입 = 서약 0줄(표본 recon_clear) · 대상 문맥 칩 0 · 재량 행 = 서약 줄 · 이탈 아님 행', () {
      final JournalDraftFormSpec r = journalDraftFormSpecOf(
        const JournalDraftFill(
          'J-R',
          isDeviation: true,
          kind: 'RECON_CLEAR',
          ruleCited: 'x',
        ),
        pledgeLines: lines,
        budget: oneUsed,
        nowUtc: _now,
      );
      expect(r.pledgeLines, recon['pledge_lines']);
      expect(r.deviation.kindCode, 'RECON_CLEAR');
      expect(r.deviation.label, '사전 저널을 채워야 하는 이탈');
      expect(r.contextChips, isEmpty);
      final JournalDraftFormSpec iv = journalDraftFormSpecOf(
        const JournalDraftFill(
          'JIV-1',
          isDeviation: true,
          kind: 'INTERVENTION_JOURNAL',
        ),
        pledgeLines: lines,
        budget: oneUsed,
        nowUtc: _now,
      );
      expect(iv.deviation.kindCode, isNull);
      expect(iv.pledgeLines, isEmpty);
      final JournalDraftFormSpec d = journalDraftFormSpecOf(
        const JournalDraftFill('J-D', isDeviation: true, kind: 'DISCRETION'),
        pledgeLines: lines,
        budget: oneUsed,
        nowUtc: _now,
      );
      expect(d.pledgeLines, lines);
      expect(d.deviation.label, '재량 조정 (롤링 12개월 4회 중 2회째)');
      expect(
        journalDraftFormSpecOf(
          const JournalDraftFill('J-N', isDeviation: false),
          pledgeLines: lines,
          budget: oneUsed,
          nowUtc: _now,
        ).deviation.isDeviation,
        isFalse,
      );
    });
  });

  group('④ 입력 판정(K298 — 화면 제출 가능 조건)', () {
    test('통과 · 근거 trim 글자 < 최소 · 기대 빈칸 · 선택지 밖 · RULE_OTHER 메모 빈칸', () {
      expect(journalDraftInputRejectOf(_draft()), isNull);
      expect(
        journalDraftInputRejectOf(
          _draft(rationale: '  ${_rationale40.substring(1)}  '),
        ),
        'JOURNAL_INPUT_INVALID',
      );
      expect(
        journalDraftInputRejectOf(_draft(expected: '   ')),
        'JOURNAL_INPUT_INVALID',
      );
      expect(
        journalDraftInputRejectOf(_draft(rule: '03 §4-1 원문')),
        'JOURNAL_INPUT_INVALID',
      );
      expect(
        journalDraftInputRejectOf(_draft(rule: 'RULE_OTHER', note: '  ')),
        'JOURNAL_INPUT_INVALID',
      );
      expect(
        journalDraftInputRejectOf(_draft(rule: 'RULE_OTHER', note: '메모')),
        isNull,
      );
      expect(
        journalDraftInputRejectOf(_draft(rule: 'RULE_RECON_CAUSE')),
        isNull,
      );
    });
  });

  group('⑤ 갈래 판정(K297 · K298)', () {
    test('대상 없음 · 다 찬 행 = 이미 있음(입력보다 먼저) · 빈 칸 행 · 새 행 = 입력 판정', () {
      expect(journalDraftRejectOf(null, _draft()), 'JOURNAL_TARGET_UNKNOWN');
      const JournalDraftFill full = JournalDraftFill(
        'J',
        isDeviation: true,
        rationaleBefore: 'a',
        expectedOutcome: 'b',
        ruleCited: 'c',
      );
      expect(
        journalDraftRejectOf(full, _draft(expected: '')),
        'JOURNAL_ALREADY_EXISTS',
      );
      const JournalDraftFill half = JournalDraftFill(
        'J',
        isDeviation: true,
        rationaleBefore: 'a',
        expectedOutcome: 'b',
      );
      expect(journalDraftRejectOf(half, _draft()), isNull);
      expect(
        journalDraftRejectOf(half, _draft(expected: '')),
        'JOURNAL_INPUT_INVALID',
      );
      expect(
        journalDraftRejectOf(
          const JournalDraftNew('k', purpose: 'DISCRETION'),
          _draft(),
        ),
        isNull,
      );
    });
  });

  group('⑥ 접수증 · 명령', () {
    test('접수증 글자 = 표본(저장 · 보류 · 거부 3) · 모르는 코드 = ArgumentError', () {
      final Map<String, String> byState = <String, String>{
        for (final Map<String, Object?> r in _rows(
          'm6/journal_draft_receipts_5.json',
        ))
          '${r['state']}/${r['reject_reason_code']}':
              r['state_label']! as String,
        for (final Map<String, Object?> r in _rows(
          'm6/journal_draft_receipts_reject_2.json',
        ))
          '${r['state']}/${r['reject_reason_code']}':
              r['state_label']! as String,
      };
      expect(journalDraftStateLabelOf(), byState['EXECUTED/null']);
      expect(
        journalDraftStateLabelOf(held: true),
        byState['HELD_FOR_INTEGRITY/null'],
      );
      for (final String c in JournalDraftRejectCodes.values) {
        expect(
          journalDraftStateLabelOf(rejectCode: c),
          byState['REJECTED/$c'],
          reason: c,
        );
      }
      expect(
        () => journalDraftStateLabelOf(rejectCode: 'NOPE'),
        throwsArgumentError,
      );
    });

    test('명령 = TTL 30분 · 종류 JOURNAL_DRAFT · digest = 페이로드 · 접수증 칸', () {
      final JournalDraftCommand c = issueJournalDraft(
        draft: _draft(),
        nowUtc: _now,
        deviceId: 'dev-1',
        random: Random(9),
      );
      expect(c.expiresAt.difference(c.requestedAt), kJournalDraftTtl);
      expect(kJournalDraftTtl, const Duration(minutes: 30));
      expect(c.requestedAt, _now);
      expect(c.nonce, matches(RegExp(r'^[0-9a-f]{32}$')));
      final JournalDraftCommand other = issueJournalDraft(
        draft: _draft(expected: '다른 기대'),
        nowUtc: _now,
        deviceId: 'dev-1',
        random: Random(9),
      );
      expect(other.commandId, c.commandId);
      expect(other.payloadDigest, isNot(c.payloadDigest));
      final CommandReceipt r = c.receipt(
        state: CommandState.rejected,
        stateLabel: 'x',
        rejectReasonCode: 'JOURNAL_TARGET_UNKNOWN',
      );
      expect(
        (r.kind, r.state, r.commandId, r.issuedByDeviceId, r.rejectReasonCode),
        (
          CommandKind.journalDraft,
          CommandState.rejected,
          c.commandId,
          'dev-1',
          'JOURNAL_TARGET_UNKNOWN',
        ),
      );
    });
  });
}
