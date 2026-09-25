// C-34 표시 계약 — 01 §7 표 C-34(🆕 계약 v1.1 · §8 미결 33·34·35·38·42·45).
//
// 정의: 「화면이 계산·판정 없이 그릴 수 있게, 엔진이 보내는 모양이 스스로 완결돼 있다」.
//   ① 구간 프리셋의 기본은 정확히 하나다(미결 33).
//   ② 일지 행의 표시 문자열 5종이 비어 있지 않다(미결 34·35).
//   ③ 가림 픽스처에 숫자가 새지 않는다(미결 42 — M4 읽기 경로 테스트의 선행 고정).
//   ④ `*normalized` 는 0.0~1.0 이다(화면의 `clamp` 는 렌더 가드일 뿐 — 잡는 곳은 여기다).
//   ⑤ `J-2` 체인은 언제나 6칸이고 등재된 단계 코드만 쓴다.
//   ⑥ 산출 불가 기여 행은 폭 0.0 + 사유 문구를 함께 싣는다(미결 45).
//   🆕 v1.2(01 §12-2 · 미결 48)
//   ⑧ 사전 저널 읽기 VM 은 결과·손익 없이 표시 문자열을 싣는다(허용 키 목록 — 필드 추가 = 01 개정 먼저).
//   ⑨ `J-2` 저널 링크는 그 결정의 읽기·작성 목적지다(엔진이 고른다 — 화면 분기 0).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

final RegExp _digit = RegExp('[0-9]');

void main() {
  group('C-34 표시 계약 (01 §7 · 계약 v1.1)', () {
    test('C-34 ① 구간 프리셋의 isDefault 는 정확히 1건이다', () {
      final ListResult<DateRange> presets = decodeList<DateRange>(
        readFixture(FixturePaths.rangePresets4),
        DateRange.fromJson,
      );
      expect(presets.rows.where((DateRange r) => r.isDefault), hasLength(1));
      for (final DateRange r in presets.rows) {
        expect(r.label, isNotNull, reason: '프리셋은 문구를 싣고 온다.');
        expect(r.presetCode, isNotNull);
      }
    });

    test('C-34 ② 일지 행의 표시 문자열 5종이 전 행에 실려 있다', () {
      const List<String> journalFixtures = <String>[
        FixturePaths.journal30,
        FixturePaths.m6ManualFills8,
        FixturePaths.m6JournalMaskedIntegrity,
      ];
      for (final String path in journalFixtures) {
        final ListResult<TradeJournalEntry> list =
            decodeList<TradeJournalEntry>(
              readFixture(path),
              TradeJournalEntry.fromJson,
            );
        for (final TradeJournalEntry e in list.rows) {
          for (final String text in <String>[
            e.sideLabel,
            e.quantityText,
            e.priceText,
            e.commissionText,
            e.taxText,
          ]) {
            expect(text, isNotEmpty, reason: '$path ${e.entryId}');
          }
          expect(e.detailDeepLink, isNotNull, reason: '$path ${e.entryId}');
        }
      }
    });

    test('C-34 ② 정정 행은 «매매로 읽히는 표현»을 쓰지 않는다', () {
      final ListResult<TradeJournalEntry> list = decodeList<TradeJournalEntry>(
        readFixture(FixturePaths.m6ManualFills8),
        TradeJournalEntry.fromJson,
      );
      final Set<String> tradeWords = <String>{
        for (final TradeJournalEntry e in list.rows)
          if (e.fillKind == FillKind.original) e.sideLabel,
      };
      for (final TradeJournalEntry e in list.rows) {
        if (e.fillKind != FillKind.original) {
          expect(
            tradeWords,
            isNot(contains(e.sideLabel)),
            reason: '${e.entryId} — 역분개·재기재 행이 매수·매도로 읽힌다(02 §3-2).',
          );
        }
      }
    });

    test('C-34 ③ LEDGER_INTEGRITY 가림 픽스처에 숫자가 새지 않는다', () {
      final ListResult<TradeJournalEntry> journal =
          decodeList<TradeJournalEntry>(
            readFixture(FixturePaths.m6JournalMaskedIntegrity),
            TradeJournalEntry.fromJson,
          );
      for (final TradeJournalEntry e in journal.rows) {
        for (final String text in <String>[
          e.quantityText,
          e.priceText,
          e.commissionText,
          e.taxText,
        ]) {
          expect(_digit.hasMatch(text), isFalse, reason: '${e.entryId}: $text');
        }
      }

      final MonthlyReport report = MonthlyReport.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m7M7MonthlyMaskedIntegrity))
            .rows
            .single,
      );
      expect(report.items, hasLength(13), reason: '가려도 13칸은 유지한다(C-25).');
      for (final ReportItem item in report.items) {
        expect(
          _digit.hasMatch(item.valueText),
          isFalse,
          reason: '${item.code}: ${item.valueText}',
        );
        expect(item.detailDeepLink, isNull, reason: '가린 항목에 상세 링크를 달지 않는다.');
      }
      expect(_digit.hasMatch(report.goalLine), isFalse);
    });

    test('C-34 ④ 모든 *normalized 값이 0.0~1.0 이다', () {
      final List<String> bad = <String>[];
      for (final String path in FixturePaths.all) {
        walkJson(jsonDecode(readFixture(path)), (
          String jsonPath,
          String key,
          Object? value,
        ) {
          if (!key.endsWith('normalized') || value is! num) {
            return;
          }
          if (value < 0 || value > 1) {
            bad.add('$path $jsonPath = $value');
          }
        });
      }
      expect(bad, isEmpty, reason: '폭 전용 정규값이 범위를 벗어났다.');
    });

    test('C-34 ⑤ J-2 체인은 언제나 6칸이고 등재된 단계 코드만 쓴다', () {
      const List<String> details = <String>[
        FixturePaths.m6DecisionDetailAmended,
        FixturePaths.m6DecisionDetailFull,
        FixturePaths.m6DecisionDetailPartial,
        FixturePaths.m6DecisionDetailReevaluatedChild,
        FixturePaths.m6DecisionDetailRejectedSaf309,
        FixturePaths.m6DecisionDetailUnknown,
        // 🆕 v1.2 — `journalLink` 목적지 2갈래(amended 사본).
        FixturePaths.m6DecisionDetailJournalWritten,
        FixturePaths.m6DecisionDetailJournalDraftLink,
      ];
      for (final String path in details) {
        final DecisionDetailVm vm = DecisionDetailVm.fromJson(
          decodeEnvelope(readFixture(path)).rows.single,
        );
        expect(vm.steps, hasLength(6), reason: '$path — 결측 단계도 자리를 유지한다.');
        for (final DecisionChainStep s in vm.steps) {
          expect(
            DecisionChainStageCodes.values,
            contains(s.stageCode),
            reason: path,
          );
          expect(s.stageLabel, isNotEmpty);
          expect(s.stateLabel, isNotEmpty);
        }
        // 스냅샷이 없으면 그 사실을 말하는 문구가 온다(화면이 추정 재구성하지 않는다).
        expect(
          vm.snapshot != null || vm.snapshotMissingLabel != null,
          isTrue,
          reason: path,
        );
        for (final RejectTrace t in vm.rejectTraces) {
          expect(SafetyCheckLevelCodes.values, contains(t.stageCode));
        }
      }
    });

    test('C-34 ⑤ J-5 단계는 4칸이고 등재된 단계 코드다', () {
      final UnknownBoardVm board = UnknownBoardVm.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m6UnknownBoard2)).rows.single,
      );
      expect(board.items, isNotEmpty);
      for (final UnknownResolutionItem item in board.items) {
        expect(item.steps, hasLength(4));
        for (final UnknownResolutionStep s in item.steps) {
          expect(UnknownResolutionStageCodes.values, contains(s.stepId));
        }
        expect(item.entry.status, JournalStatus.unknown);
      }
      final UnknownBoardVm empty = UnknownBoardVm.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m6UnknownBoardEmpty))
            .rows
            .single,
      );
      expect(empty.items, isEmpty);
      expect(empty.emptyLabel, isNotNull, reason: '빈 보드도 문구를 싣고 온다.');
    });

    test('C-34 ⑥ 산출 불가 기여 행은 폭 0.0 과 사유 문구를 함께 싣는다', () {
      final ContributionVm vm = ContributionVm.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m7M7ContribPartial))
            .rows
            .single,
      );
      final List<ContributionRow> unavailable = vm.rows
          .where((ContributionRow r) => r.unavailableLabel != null)
          .toList();
      expect(unavailable, isNotEmpty);
      for (final ContributionRow r in unavailable) {
        expect(r.normalized, 0.0);
        expect(_digit.hasMatch(r.contributionText), isFalse);
      }
    });

    test('C-34 ⑧ 사전 저널 읽기 VM 은 결과·손익 없이 표시 문자열을 싣는다', () {
      // 🔴 허용 키 **목록**이다(금지 목록이 아니다) — `J-3` 안에 그려지므로 «작성 중 손익 노출
      //    금지»(02 §3-3 금지 ③)를 물려받고 `J-4` blind 리뷰(미결 46)가 본문을 재사용한다.
      const Set<String> vmKeys = <String>{
        'decision_id',
        'journal_state_label',
        'body',
        'decision_link',
        'as_of',
      };
      const Set<String> bodyKeys = <String>{
        'written_at_text',
        'rule_cited_label',
        'rationale_before',
        'expected_outcome',
        'note',
      };
      const Map<String, bool> reads = <String, bool>{
        // 픽스처 → body 가 있어야 하는가
        FixturePaths.m6JournalReadWritten: true,
        FixturePaths.m6JournalReadNoNote: true,
        FixturePaths.m6JournalReadNotWritten: false,
      };
      for (final MapEntry<String, bool> e in reads.entries) {
        final String path = e.key;
        final Map<String, Object?> row = decodeEnvelope(readFixture(path))
            .rows
            .single;
        expect(
          row.keys.toSet().difference(vmKeys),
          isEmpty,
          reason:
              '$path — DecisionJournalVm 에 허용 목록 밖 키가 있다(01 §12-2 개정이 먼저다).',
        );
        final DecisionJournalVm vm = DecisionJournalVm.fromJson(row);
        expect(vm.journalStateLabel, isNotEmpty, reason: path);
        expect(
          vm.body != null,
          e.value,
          reason: '$path — «미작성»은 body null 인 값이다(미작성 픽스처만 null).',
        );
        final Object? rawBody = row['body'];
        if (rawBody is Map<String, Object?>) {
          expect(
            rawBody.keys.toSet().difference(bodyKeys),
            isEmpty,
            reason: '$path — DecisionJournalBody 에 결과·손익 류 키가 붙었다.',
          );
        }
        final DecisionJournalBody? body = vm.body;
        if (body != null) {
          expect(body.writtenAtText, isNotEmpty, reason: path);
          expect(body.ruleCitedLabel, isNotEmpty, reason: path);
          expect(body.rationaleBefore, isNotEmpty, reason: path);
          expect(body.expectedOutcome, isNotEmpty, reason: path);
        }
        final LinkAction? link = vm.decisionLink;
        if (link != null) {
          expect(
            link.deepLink,
            'aaq://journal/decision/${vm.decisionId}',
            reason: '$path — 「이 결정 보기」는 그 결정의 J-2 다.',
          );
          expect(link.label, isNotEmpty, reason: path);
        }
      }
    });

    test('C-34 ⑨ J-2 저널 링크는 그 결정의 읽기·작성 목적지다', () {
      const List<String> details = <String>[
        FixturePaths.m6DecisionDetailJournalWritten,
        FixturePaths.m6DecisionDetailJournalDraftLink,
      ];
      final Set<String> seen = <String>{};
      for (final String path in details) {
        final DecisionDetailVm vm = DecisionDetailVm.fromJson(
          decodeEnvelope(readFixture(path)).rows.single,
        );
        final LinkAction? link = vm.journalLink;
        expect(link, isNotNull, reason: '$path — 저널 링크 갈래 픽스처다.');
        expect(link!.label, isNotEmpty, reason: path);
        expect(vm.journalStateLabel, isNotEmpty, reason: path);
        final String id = vm.entry.decision.decisionId;
        final String read = 'aaq://journal/read/$id';
        final String draft = 'aaq://journal/draft/$id';
        expect(
          <String>{read, draft},
          contains(link.deepLink),
          reason:
              '$path — journalLink 는 그 결정의 읽기(작성됨) 또는 작성(미작성) 목적지다(01 §12-2 표).',
        );
        seen.add(link.deepLink == read ? 'read' : 'draft');
      }
      expect(seen, <String>{'read', 'draft'}, reason: '두 갈래가 모두 덮여야 한다.');
    });

    test('C-34 미생성 월간 리포트는 D-day 를 행 안의 문장으로 싣는다(미결 40)', () {
      final MonthlyReport pending = MonthlyReport.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m7M7MonthlyPending))
            .rows
            .single,
      );
      expect(pending.pendingNoticeText, isNotNull);
      expect(pending.generatedAtText, isNull);
      final MonthlyReport normal = MonthlyReport.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m7M7Monthly202608)).rows.single,
      );
      expect(normal.pendingNoticeText, isNull);
      expect(normal.generatedAtText, isNotNull);
      expect(normal.configHash, startsWith('cfg_fake_'));
      expect(
        normal.items.where((ReportItem i) => i.detailDeepLink != null),
        isNotEmpty,
      );
    });
  });
}
