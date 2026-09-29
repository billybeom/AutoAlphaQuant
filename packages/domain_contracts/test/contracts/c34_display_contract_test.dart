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
//   🆕 v1.3(01 §13-8)
//   ⑩ 아카이브(`S7-1b`)는 엔진이 정렬·묶어서 준다 — 최신 달부터 · 행 키 7개 이하 · 미생성 달은
//      목적지 없이 까닭을 싣는다 · 목적지가 없는 행은 까닭이 있다 · 빈 목록은 문구를 싣는다 ·
//      머리글(`section_label`)은 비지 않고 첫 행에는 꼭 있다.
//      (④ 는 v1.3 의 새 키 `x_normalized`·`y_normalized`·`start_normalized`·`end_normalized`·
//       눈금 `normalized` 도 코드 변경 없이 덮는다 — 키가 `normalized` 로 끝난다.)

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

final RegExp _digit = RegExp('[0-9]');

/// ⑩ 계약 v1.3 이 아는 아카이브 픽스처(2건). 검사는 **모양으로 찾은 것**을 본다.
const List<String> _knownArchiveFixtures = <String>[
  FixturePaths.m7M7ReportArchive18,
  FixturePaths.m7M7ReportArchiveEmpty,
];

/// ⑩ 아카이브 행의 허용 키 **목록**(7개) — 🔴 수치 필드가 없는 월 목록이다.
/// 필드를 더하려면 01 §13-8 개정이 먼저다.
const Set<String> _archiveRowKeys = <String>{
  'yyyy_mm',
  'label',
  'generated',
  'mode_label',
  'reason_label',
  'route',
  'section_label',
};

final RegExp _yyyyMm = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

/// 전 픽스처에서 아카이브 VM 을 **모양으로** 찾는다 — 행이 `rows` 목록과 `empty_label` 키를 갖는다.
Map<String, Map<String, Object?>> _archiveVms() {
  final Map<String, Map<String, Object?>> out =
      <String, Map<String, Object?>>{};
  for (final String path in FixturePaths.all) {
    for (final Map<String, Object?> row in decodeEnvelope(
      readFixture(path),
    ).rows) {
      final Object? inner = row['rows'];
      if (inner is! List<Object?> || !row.containsKey('empty_label')) {
        continue;
      }
      final bool archiveShaped = inner.every(
        (Object? r) => r is Map<String, Object?> && r.containsKey('yyyy_mm'),
      );
      if (archiveShaped &&
          (inner.isNotEmpty || _knownArchiveFixtures.contains(path))) {
        out[path] = row;
      }
    }
  }
  return out;
}

/// ⑩ 아카이브 VM 1건의 위반(빈 목록 = 통과).
List<String> _archiveViolations(String where, Map<String, Object?> vmJson) {
  final List<String> bad = <String>[];
  final ReportArchiveVm vm = ReportArchiveVm.fromJson(vmJson);
  final List<Map<String, Object?>> rawRows = (vmJson['rows']! as List<Object?>)
      .cast<Map<String, Object?>>();

  if (vm.rows.isEmpty && (vm.emptyLabel ?? '').trim().isEmpty) {
    bad.add('$where — 빈 목록인데 empty_label 이 없다(화면이 문구를 짓게 된다)');
  }
  if (vm.rows.isNotEmpty && vm.rows.first.sectionLabel == null) {
    bad.add('$where — 첫 행에 section_label 이 없다(첫 묶음의 머리글이 빠진다)');
  }
  for (int i = 0; i < vm.rows.length; i++) {
    final ReportArchiveRow r = vm.rows[i];
    final String at = '$where rows[$i] ${r.yyyyMm}';
    if (!_yyyyMm.hasMatch(r.yyyyMm)) {
      bad.add('$at — yyyy_mm 꼴이 아니다');
    }
    if (i > 0 && r.yyyyMm.compareTo(vm.rows[i - 1].yyyyMm) >= 0) {
      bad.add('$at — 앞 행(${vm.rows[i - 1].yyyyMm})보다 이르지 않다(최신 달부터다)');
    }
    final Set<String> extra = rawRows[i].keys.toSet().difference(
      _archiveRowKeys,
    );
    if (extra.isNotEmpty) {
      bad.add('$at — 허용 목록 밖 키 $extra');
    }
    final bool hasReason = (r.reasonLabel ?? '').trim().isNotEmpty;
    if (!r.generated && r.route != null) {
      bad.add('$at — 미생성인데 route 가 있다');
    }
    if (!r.generated && !hasReason) {
      bad.add('$at — 미생성인데 reason_label 이 없다');
    }
    if (r.route == null && !hasReason) {
      bad.add('$at — route 가 없는데 reason_label 도 없다(왜 못 여는지 말하지 않는다)');
    }
    if (r.reasonLabel != null && !hasReason) {
      bad.add('$at — reason_label 이 빈 글자다');
    }
    if (r.sectionLabel != null && r.sectionLabel!.trim().isEmpty) {
      bad.add('$at — section_label 이 빈 글자다');
    }
  }
  return bad;
}

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
        // 🆕 v1.2 검증 반영 — 미작성 픽스처는 2행(b_27 · a_31 = executed 직후 «미작성 → 본문» 전환 표본)이다.
        final List<Map<String, Object?>> rows = decodeEnvelope(
          readFixture(path),
        ).rows;
        expect(rows, isNotEmpty, reason: path);
        for (final Map<String, Object?> row in rows) {
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
      }
      // 전환 표본 — 작성됨 픽스처의 결정이 미작성 픽스처에도 있다(`J-3` executed 직후 «미작성 → 본문»을
      // 같은 결정으로 흘려 보는 테스트의 입력 · 테스트가 한국어 VM 을 짓지 않게).
      final Object? writtenId = decodeEnvelope(
        readFixture(FixturePaths.m6JournalReadWritten),
      ).rows.single['decision_id'];
      expect(
        decodeEnvelope(readFixture(FixturePaths.m6JournalReadNotWritten)).rows
            .map((Map<String, Object?> r) => r['decision_id']),
        contains(writtenId),
        reason: '미작성 픽스처에 작성됨 픽스처와 같은 결정의 «미작성» 행이 없다 — 전환 표본이 사라졌다.',
      );
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

    test('C-34 ⑩ 아카이브는 최신 달부터 오고 행마다 열 수 있는지·왜 못 여는지를 싣는다', () {
      final Map<String, Map<String, Object?>> archives = _archiveVms();
      expect(archives.keys, containsAll(_knownArchiveFixtures));
      final List<String> bad = <String>[
        for (final MapEntry<String, Map<String, Object?>> e in archives.entries)
          ..._archiveViolations(e.key, e.value),
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));

      // 입력 확인 — 빈 목록 · 미생성 행 · 목적지 없는 생성 행(모의) · 머리글 여럿이 모두 있다.
      final List<ReportArchiveVm> vms = archives.values
          .map(ReportArchiveVm.fromJson)
          .toList();
      expect(vms.where((ReportArchiveVm v) => v.rows.isEmpty), isNotEmpty);
      final List<ReportArchiveRow> rows = vms
          .expand((ReportArchiveVm v) => v.rows)
          .toList();
      expect(rows.where((ReportArchiveRow r) => !r.generated), isNotEmpty);
      expect(
        rows.where((ReportArchiveRow r) => r.generated && r.route == null),
        isNotEmpty,
      );
      expect(
        rows.where((ReportArchiveRow r) => r.sectionLabel != null).length,
        greaterThanOrEqualTo(3),
      );
    });

    test('C-34 ⑩ 자체 검증 — 망가뜨린 아카이브는 검사에 걸린다', () {
      final Map<String, Map<String, Object?>> archives = _archiveVms();
      final Map<String, Object?> full =
          archives[FixturePaths.m7M7ReportArchive18]!;
      final Map<String, Object?> empty =
          archives[FixturePaths.m7M7ReportArchiveEmpty]!;
      expect(_archiveViolations('full', full), isEmpty);
      expect(_archiveViolations('empty', empty), isEmpty);

      Map<String, Object?> broken(
        Map<String, Object?> base,
        void Function(Map<String, Object?> vm, List<Map<String, Object?>> rows)
        edit,
      ) {
        final Map<String, Object?> copy =
            jsonDecode(jsonEncode(base)) as Map<String, Object?>;
        edit(
          copy,
          (copy['rows']! as List<Object?>).cast<Map<String, Object?>>(),
        );
        return copy;
      }

      final Map<String, Map<String, Object?>> mutations =
          <String, Map<String, Object?>>{
            '오래된 달부터(뒤집힘)': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              final List<Map<String, Object?>> reversed = rows.reversed
                  .toList();
              // 머리글 규칙에 먼저 걸리지 않게 첫 행에 머리글을 준다 — 순서만 망가뜨린다.
              reversed.first['section_label'] = '2025년 · 모의투자';
              vm['rows'] = reversed;
            }),
            '같은 달 두 번': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              rows[4]['yyyy_mm'] = rows[3]['yyyy_mm'];
            }),
            '허용 목록 밖 키(수치 필드)': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              rows[3]['return_text'] = '1.42%';
            }),
            '미생성인데 목적지가 있다': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              rows[1]['route'] = 'aaq://report/2026-07';
            }),
            '미생성인데 까닭이 없다': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              rows[1].remove('reason_label');
            }),
            '목적지가 없는데 까닭도 없다(모의)': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              rows.last.remove('reason_label');
            }),
            '까닭이 빈 글자': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              rows.last['reason_label'] = '';
            }),
            '빈 목록인데 문구가 없다': broken(empty, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              vm['empty_label'] = null;
            }),
            '빈 목록인데 문구가 빈 글자': broken(empty, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              vm['empty_label'] = ' ';
            }),
            '머리글이 빈 글자': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              rows[8]['section_label'] = '';
            }),
            '첫 행에 머리글이 없다': broken(full, (
              Map<String, Object?> vm,
              List<Map<String, Object?>> rows,
            ) {
              rows.first.remove('section_label');
            }),
          };
      for (final MapEntry<String, Map<String, Object?>> m
          in mutations.entries) {
        expect(
          _archiveViolations(m.key, m.value),
          isNotEmpty,
          reason: '${m.key} — 망가뜨렸는데 검사가 통과한다(검사가 늘 참이다).',
        );
      }
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
