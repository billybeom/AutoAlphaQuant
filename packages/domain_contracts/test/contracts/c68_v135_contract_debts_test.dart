// C-68 쌓인 계약 숙제 창 — 01 §44
// (🆕 계약 v1.35 · 발주자 위임 2026-11-14 — 권고대로 · K290~K302).
//
// 정의: 「X5 정정 원문 거부 = 따로 사전(엔진 계획 판정 거울과 축이 다르다) · L-1 조치 링크 = 대상 라우트 ·
//        원장 `decision_journal.kind` = 사전 8(글자 = 쓰는 동작 id · 예외 둘) · `SafetyState.holds` ↔ `holdLabels` 같은 차례 · 같은 길이 ·
//        J-3 키 = 저널 id · 거부 3 · 인용 규칙 코드 사전 · 화면은 코드 축을 보지 않는다」.
//   ① 판 · 표본 ② 정정 원문 거부 ③ 저널 kind ④ J-3 거부 ⑤ 인용 규칙 ⑥ hold 짝 문장 ⑦ L-1 조치 링크 ⑧ 화면 경계 ⑨ 글자 꼴.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_env(path)['rows']! as List).cast<Map<String, Object?>>();

const List<String> _newFixtures = <String>[
  FixturePaths.safetyStatesHolds,
  FixturePaths.m6JournalDraftReceiptsReject2,
  FixturePaths.x5RepairInputResults,
];

void main() {
  group('C-68 쌓인 계약 숙제 창 (01 §44)', () {
    // 🔵 v1.36(01 §45) — 판 글자 고정 = 최신 창 시험(C-69 ①)만 · 여기는 «봉투 판 = 계약 판».
    test('C-68 ① 판 · 표본 — 신설 3 = 전량 목록 · 디스크 · 봉투 판 · 393', () {
      for (final String path in _newFixtures) {
        expect(FixturePaths.all, contains(path));
        expect(fixtureExists(path), isTrue, reason: path);
        final Map<String, Object?> meta =
            _env(path)['meta']! as Map<String, Object?>;
        expect(meta['contract_version'], contractVersion, reason: path);
      }
      expect(FixturePaths.all, hasLength(393));
      expect(allFixtureFilesOnDisk(), hasLength(393));
    });

    test('C-68 ② 정정 원문 거부 — 사전 1 · 도메인 · 계획 판정 거울과 서로소 · 결과 표본 · 이름 ≠ 엔진', () {
      expect(RepairInputResultCodes.values, <String>{'REPAIR_AMOUNT_INVALID'});
      expect(
        ContractCodes.byDomain['repair_input_result'],
        RepairInputResultCodes.values,
      );
      expect(
        RepairInputResultCodes.values.intersection(RepairResultCodes.values),
        isEmpty,
        reason: '엔진 repair_plan 10 의 거울(RepairResultCodes)에 섞지 않는다(K291).',
      );
      final List<SafetyActionResult> rs = _rows(
        FixturePaths.x5RepairInputResults,
      ).map(SafetyActionResult.fromJson).toList();
      expect(rs, hasLength(1));
      final SafetyActionResult r = rs.single;
      expect(r.id, SafetyActionId.repairCorrect);
      expect(r.reasonCode, RepairInputResultCodes.amountInvalid);
      expect(r.level, UiLevel.blocked);
      expect(r.retryable, isFalse);
      expect(r.headline.trim(), isNotEmpty);
      expect(r.handoffRoute, isNull);
      final String src = File('${libDir.path}/src/labels/repair_codes.dart')
          .readAsStringSync();
      expect(
        RegExp(r'class RepairInputCodes\b').hasMatch(src),
        isFalse,
        reason: '타입 이름 ≠ 엔진(core RepairInputCodes · K80).',
      );
    });

    test(
      'C-68 ③ 저널 kind — 8 · 도메인 · 글자 = 동작 id(예외 둘) · 배지 축 겹침 셋 · J-3 새 행 목적 둘',
      () {
        expect(DecisionJournalKinds.values, <String>{
          'KILL_SWITCH_CHECKLIST',
          'KILL_SWITCH_RESUME',
          'STOPPED_DECISION',
          'RECON_CLEAR',
          'RULE_CHANGE_REQUEST',
          'INTERVENTION_JOURNAL',
          'DISCRETION',
          'PLEDGE_EDIT',
        });
        expect(
          ContractCodes.byDomain['decision_journal_kind'],
          DecisionJournalKinds.values,
        );
        final Set<String> actionWires = <String>{
          for (final SafetyActionId id in SafetyActionId.values) id.wire,
        };
        const Set<String> exceptions = <String>{
          DecisionJournalKinds.killSwitchChecklist,
          DecisionJournalKinds.discretion,
        };
        expect(
          DecisionJournalKinds.values
              .difference(exceptions)
              .difference(actionWires),
          isEmpty,
          reason: '글자 = 그 저널을 쓰는 안전 동작 id 와이어(K294).',
        );
        expect(
          exceptions.intersection(actionWires),
          isEmpty,
          reason: '예외 둘은 동작 와이어가 아니다(기존 엔진 · SPEC 글자).',
        );
        expect(
          DecisionJournalKinds.interventionJournal,
          SafetyActionId.interventionJournal.wire,
        );
        expect(
          DecisionJournalKinds.values.intersection(DeviationKindCodes.values),
          <String>{'DISCRETION', 'RECON_CLEAR', 'KILL_SWITCH_RESUME'},
          reason: '같은 글자 다른 축 셋(C-5 문서 쌍).',
        );
        for (final String c in <String>[
          'DISCRETION',
          'RECON_CLEAR',
          'KILL_SWITCH_RESUME',
        ]) {
          expect(ContractCodes.domainsOf(c), <String>{
            'deviation_kind',
            'decision_journal_kind',
          });
        }
        expect(DecisionJournalKinds.draftPurposes, <String>{
          DecisionJournalKinds.discretion,
          DecisionJournalKinds.pledgeEdit,
        });
        expect(
          DecisionJournalKinds.values.containsAll(
            DecisionJournalKinds.draftPurposes,
          ),
          isTrue,
        );
      },
    );

    test('C-68 ④ J-3 거부 — 사전 3 · 거부 표본 2 = 새 두 사유 · 기존 receipts_5 무변경', () {
      expect(JournalDraftRejectCodes.values, <String>{
        'JOURNAL_ALREADY_EXISTS',
        'JOURNAL_TARGET_UNKNOWN',
        'JOURNAL_INPUT_INVALID',
      });
      expect(
        ContractCodes.byDomain['journal_draft_reject'],
        JournalDraftRejectCodes.values,
      );
      final List<CommandReceipt> rs = _rows(
        FixturePaths.m6JournalDraftReceiptsReject2,
      ).map(CommandReceipt.fromJson).toList();
      expect(rs, hasLength(2));
      expect(rs.map((CommandReceipt r) => r.commandId).toSet(), hasLength(2));
      for (final CommandReceipt r in rs) {
        expect(r.kind, CommandKind.journalDraft);
        expect(r.state, CommandState.rejected);
        expect(r.stateLabel.trim(), isNotEmpty);
        expect(r.expiresAt.isAfter(r.requestedAt), isTrue);
      }
      expect(rs.map((CommandReceipt r) => r.rejectReasonCode).toSet(), <String>{
        JournalDraftRejectCodes.journalTargetUnknown,
        JournalDraftRejectCodes.journalInputInvalid,
      });
      final Set<String?> legacy = <String?>{
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m6JournalDraftReceipts5,
        ))
          if (r['state'] == 'REJECTED') r['reject_reason_code'] as String?,
      };
      expect(legacy, <String>{JournalDraftRejectCodes.journalAlreadyExists});
    });

    test('C-68 ⑤ 인용 규칙 — 사전 3 · J-3 폼 표본 선택지 ⊆ 사전 · 메모 필수 = RULE_OTHER 하나', () {
      expect(JournalRuleCitedCodes.values, <String>{
        'RULE_DISCRETION_BUDGET',
        'RULE_RECON_CAUSE',
        'RULE_OTHER',
      });
      expect(
        ContractCodes.byDomain['journal_rule_cited'],
        JournalRuleCitedCodes.values,
      );
      for (final String path in <String>[
        FixturePaths.m6JournalDraftSpecDiscretion,
        FixturePaths.m6JournalDraftSpecReconClear,
      ]) {
        final JournalDraftFormSpec spec = JournalDraftFormSpec.fromJson(
          _rows(path).single,
        );
        expect(
          spec.ruleCitedOptions.map((ReasonOption o) => o.code).toSet(),
          JournalRuleCitedCodes.values,
          reason: path,
        );
        expect(
          <String>{
            for (final ReasonOption o in spec.ruleCitedOptions)
              if (o.requiresNote) o.code,
          },
          <String>{JournalRuleCitedCodes.other},
          reason: path,
        );
      }
    });

    test('C-68 ⑥ hold 짝 문장 — 전 표본 holds ↔ hold_labels 같은 길이 · 사전 · 새 표본 2 · 키 문장 = S05 한 벌 · 기본값', () {
      int pairs = 0;
      for (final String path in FixturePaths.all) {
        walkJson(_env(path), (String at, String key, Object? value) {
          if (key != 'holds' || value is! List) {
            return;
          }
          final String parent = at.substring(0, at.length - '.holds'.length);
          Object? node = _env(path);
          // 부모 객체를 다시 찾는다(walkJson 은 값만 준다).
          for (final String seg in _segments(parent)) {
            node = seg.startsWith('[')
                ? (node! as List)[int.parse(seg.substring(1, seg.length - 1))]
                : (node! as Map<String, Object?>)[seg];
          }
          final Map<String, Object?> obj = node! as Map<String, Object?>;
          if (!obj.containsKey('breaker_level')) {
            return; // SafetyState 가 아닌 holds(없음 — 방어).
          }
          final List<Object?> labels =
              (obj['hold_labels'] as List<Object?>?) ?? const <Object?>[];
          expect(labels, hasLength(value.length), reason: '$path $at');
          for (final Object? c in value) {
            expect(SafetyHoldCodes.values, contains(c), reason: '$path $at');
          }
          for (final Object? l in labels) {
            expect((l! as String).trim(), isNotEmpty, reason: '$path $at');
          }
          pairs += value.length;
        });
      }
      expect(pairs, 2, reason: '짝 표본 = safety_states_holds 2행(공허 방지).');
      final List<SafetyState> rows = _rows(FixturePaths.safetyStatesHolds)
          .map(SafetyState.fromJson)
          .toList();
      expect(rows.map((SafetyState s) => s.holds).toList(), <List<String>>[
        <String>[SafetyHoldCodes.liveAwaitingKeys],
        <String>[SafetyHoldCodes.migrationInProgress],
      ]);
      final Map<String, Object?> mode =
          _rows(FixturePaths.m9OperationsLiveHoldKeys).single['mode']!
              as Map<String, Object?>;
      expect(
        rows.first.holdLabels.single,
        mode['hold_label'],
        reason: '키 hold 문장 = S05 RunModeCard.holdLabel 과 한 벌(K295).',
      );
      final Map<String, dynamic> json = rows.first.toJson();
      expect(json.keys, containsAll(<String>['holds', 'hold_labels']));
      final Map<String, dynamic> stripped = Map<String, dynamic>.of(json)
        ..remove('holds')
        ..remove('hold_labels');
      final SafetyState bare = SafetyState.fromJson(
        jsonDecode(jsonEncode(stripped)) as Map<String, dynamic>,
      );
      expect(bare.holds, isEmpty);
      expect(bare.holdLabels, isEmpty);
    });

    test(
      'C-68 ⑦ L-1 조치 링크 — ledger_diffs_4 승인 행 = 대상 라우트(그 diff) · 등록 · 허브 글자 0',
      () {
        final List<LedgerDiffRow> rows = _rows(FixturePaths.ledgerDiffs4)
            .map(LedgerDiffRow.fromJson)
            .toList();
        final List<LedgerDiffRow> linked = rows
            .where((LedgerDiffRow r) => r.actionLink != null)
            .toList();
        expect(linked, hasLength(1));
        final LedgerDiffRow r = linked.single;
        expect(
          r.actionLink!.deepLink,
          AppRoutes.x5RepairTarget.replaceFirst(':targetId', r.diffId),
        );
        expect(AppRoutes.isRegistered(r.actionLink!.deepLink), isTrue);
        expect(
          readFixture(FixturePaths.ledgerDiffs4),
          isNot(contains('"aaq://x5/repair-wizard"')),
        );
      },
    );

    test('C-68 ⑧ 화면 경계 — ui_* 소스에 hold 코드 · 저널 kind · 정정 원문 거부 · J-3 거부 · 인용 규칙 사전 0', () {
      const List<String> symbols = <String>[
        'SafetyHoldCodes',
        'DecisionJournalKinds',
        'RepairInputResultCodes',
        'JournalDraftRejectCodes',
        'JournalRuleCitedCodes',
      ];
      final RegExp holdsRead = RegExp(r'\.holds\b');
      final List<String> offenders = <String>[];
      for (final String name in uiPackageNames) {
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) {
          continue;
        }
        for (final File f in dartSourcesIn(lib)) {
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final String symbol in symbols) {
            if (RegExp('\\b$symbol\\b').hasMatch(code)) {
              offenders.add('${shortPath(f)}: $symbol');
            }
          }
          if (holdsRead.hasMatch(code)) {
            offenders.add('${shortPath(f)}: .holds');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: '🔴 화면은 hold 문장(holdLabels) · stateLabel · headline 만 그린다(01 §1-5 · K295 · K298).',
      );
    });

    test('C-68 ⑨ 글자 꼴 — 새 사전 상수 = 대문자 · 숫자 · _ 만(문구 · 수치 0)', () {
      final RegExp wire = RegExp(r'^[A-Z][A-Z0-9_]*$');
      for (final String c in <String>{
        ...RepairInputResultCodes.values,
        ...DecisionJournalKinds.values,
        ...JournalRuleCitedCodes.values,
        ...JournalDraftRejectCodes.values,
      }) {
        expect(c, matches(wire));
      }
    });
  });
}

/// `a.b[0].c` → [`a`, `b`, `[0]`, `c`].
List<String> _segments(String path) => <String>[
  for (final RegExpMatch m in RegExp(r'[^.\[\]]+|\[\d+\]').allMatches(path))
    m.group(0)!,
];
