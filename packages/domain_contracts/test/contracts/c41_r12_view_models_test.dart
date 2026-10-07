// C-41 R12 표시 계약 — 01 §15-4 · R12 선행 계약 v1.6 보강안 §4-1(🆕 계약 v1.6).
//
// 정의: 「R12 다섯 화면(`S7-6a/b/c` · `S7-7` · `S7-10`)이 **엔진이 완성한 글자와 null 여부만 보고** 그릴 수
//   있게, v1.6 픽스처·DTO 가 스스로 완결되고 서로 맞는다」.
//   ① `RebalancePreviewResult` — `preview`·`blockedText` 정확히 하나 · `blockedAction` ⇒ `blockedText` ·
//      차단 표본에 버튼 있는 행과 없는 행이 둘 다 있다
//   ② `RebalancePreview` — `asOf` == 봉투 · 머리 글자 · 고지 머리 · `ordersEmptyText != null ⇔ 빈 초안` ·
//      지정가 짝 · 계좌 별칭
//   ③ `NextRebalanceVm` — 카운트다운 = 두 글자 + 예고 링크 · 예정 없음 = 문장만 · 행 `asOf` == 봉투
//   ④ `RebalanceEvent` — 대조 표 ⇔ 등록 임계 · 행 `asOf` == 봉투(관측 시각 · 라벨 포함) · 비중 라벨 `%` ·
//      basis · 모드 배지 ⇔ 비 LIVE · 머리글 = SIM 단독 봉투의 첫 행 하나
//   ⑤ `rebalance_6` 거래일 엄격 내림차순 · 같은 회차 행 == `detail_band` 행(JSON 전체)
//   ⑥ `AnnualReviewVm` — 세후 두 갈래 == 사다리 원천(JSON) · 갈 곳 없는 섹션 버튼 0 · 연도 글자 ·
//      창 밖 표본 = 기본 연도 규칙(마지막 완결 연도)
//   ⑦ `AfterTaxLadder.referenceOnlyLabel != null ⇔ isReferenceOnly`(예외 고정 목록 = 미결 79)
//   ⑧ `ExecutionGapResult` — report·emptyLabel 정확히 하나 · emptyKind ⇔ emptyLabel · 빈·해당없음 갈래 ·
//      asOf 정합 · 게이지 폭 범위 · 가림 표본 · int ↔ 문장 정합
//   ⑨ 정상·섞인 달 제안 줄 부재 · R12 픽스처 전 문자열 금지어 0
//   ⑩ 월간 ⑧ 링크 = 그 달의 `S7-10`(`ledgerExecutionGapMonth`) · 가림·미생성 = 링크 없음
// 🔴 숫자를 이 파일에 적지 않는다 — 픽스처끼리 맞댄다(C-40 선례). «패턴에 값을 끼운 기대값»·«n건» 토큰
//    분해는 **테스트 쪽 조립**이다(화면 lib 규칙 ③ 은 화면의 규칙 · C-33 ⑦ 선례).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_accounts.dart';
import 'support/fixture_io_t2.dart';

/// 미리보기 결과를 싣는 픽스처(초안 2벌 + 차단).
const String _pvDefault = FixturePaths.m7M7RebalancePreviewDefault;
const String _pvInBand = FixturePaths.m7M7RebalancePreviewInBand;
const String _pvBlocked = FixturePaths.m7M7RebalancePreviewBlocked;

/// `RebalanceEvent` 를 싣는 R12 픽스처(빈 타임라인 0행 봉투는 행 단언 대상이 아니다).
const List<String> _eventFixtures = <String>[
  FixturePaths.rebalance6,
  FixturePaths.m7M7RebalanceDetailBand,
  FixturePaths.m7M7RebalanceDetailAdvisory,
  FixturePaths.m7M7RebalanceSim,
];

const List<String> _annualFixtures = <String>[
  FixturePaths.m7M7Annual2026,
  FixturePaths.m7M7AnnualFirstYear,
  FixturePaths.m7M7AnnualOffwindow,
];

/// 이행 갭 결과 7벌 — 리포트 4벌 · 가림 1 · 빈 1 · 해당없음 1.
const List<String> _gapReports = <String>[
  FixturePaths.m7ExecutionGap1,
  FixturePaths.m7ExecutionGapCant,
  FixturePaths.m7ExecutionGapWont,
  FixturePaths.m7ExecutionGapMixed,
];
const List<String> _gapFixtures = <String>[
  ..._gapReports,
  FixturePaths.m7ExecutionGapMaskedRecon,
  FixturePaths.m7ExecutionGapEmpty,
  FixturePaths.m7ExecutionGapNotApplicable,
];

/// 월간 리포트 5벌 — ⑧ 링크가 있는 3벌 · 없는 2벌(가림 · 미생성).
const List<String> _monthlyLinked = <String>[
  FixturePaths.m7M7Monthly202608,
  FixturePaths.m7M7MonthlyGap,
  FixturePaths.m7M7MonthlyMaskedRecon,
];
const List<String> _monthlyUnlinked = <String>[
  FixturePaths.m7M7MonthlyMaskedIntegrity,
  FixturePaths.m7M7MonthlyPending,
];

/// ⑦ 예외 고정 목록 — 인출 규칙 결정(§8 미결 79) 뒤 첫 minor 재생성 전까지 표지 글자를 싣지 않는다.
const Set<String> _referenceLabelExceptions = <String>{
  FixturePaths.m7M7WithdrawalPensionPenalty,
};

/// ⑨ R12 신설·개정 픽스처(신설 9 · 개정 14 — 개명 1 포함).
const List<String> _r12Fixtures = <String>[
  _pvDefault,
  _pvInBand,
  _pvBlocked,
  FixturePaths.m7M7NextRebalanceCountdown,
  FixturePaths.m7M7NextRebalanceNone,
  FixturePaths.rebalance6,
  FixturePaths.m7M7RebalanceDetailBand,
  FixturePaths.m7M7RebalanceDetailAdvisory,
  FixturePaths.m7M7RebalanceSim,
  FixturePaths.m7AftertaxLadder1,
  ..._annualFixtures,
  ..._gapFixtures,
  ..._monthlyLinked,
];

/// ⑨ 금지어(01 §10-1 · 03 §15).
final RegExp _forbidden = RegExp('추천|권유|자문|시그널');

/// ⑧ «라벨 n건» 토큰(` · ` 로 나눈 한 조각).
final RegExp _countToken = RegExp(r'^(.+) ([0-9]+)건$');

AsOf _envelopeAsOf(String path) =>
    AsOf.fromJson(fixtureJson(path)['as_of']! as Map<String, Object?>);

List<RebalancePreviewResult> _previews(String path) =>
    fixtureRows(path).map(RebalancePreviewResult.fromJson).toList();

List<RebalanceEvent> _events(String path) =>
    fixtureRows(path).map(RebalanceEvent.fromJson).toList();

ExecutionGapResult _gap(String path) =>
    ExecutionGapResult.fromJson(fixtureRows(path).single);

/// `ledgerExecutionGapMonth` 에 그 달을 끼운 기대값(테스트 쪽 조립).
String _gapMonthLink(String yyyyMm) {
  const String pattern = AppRoutes.ledgerExecutionGapMonth;
  expect(pattern.split(':yyyyMm'), hasLength(2), reason: pattern);
  return pattern.replaceFirst(':yyyyMm', yyyyMm);
}

/// 줄들을 ` · ` 로 나눠 «라벨 → 정수» 로 읽는다(테스트 쪽 조립).
Map<String, int> _countsIn(List<String> lines, String where) {
  final Map<String, int> out = <String, int>{};
  for (final String line in lines) {
    for (final String token in line.split(' · ')) {
      final RegExpMatch? m = _countToken.firstMatch(token);
      expect(m, isNotNull, reason: '$where — «라벨 n건» 꼴이 아니다: «$token»');
      expect(out.containsKey(m!.group(1)), isFalse, reason: '$where «$token»');
      out[m.group(1)!] = int.parse(m.group(2)!);
    }
  }
  return out;
}

/// `is_reference_only` 를 싣는 객체를 경로와 함께 모은다.
void _collectLadders(
  Object? node,
  String path,
  List<(String, Map<String, Object?>)> out,
) {
  if (node is Map<String, Object?>) {
    if (node.containsKey('is_reference_only')) {
      out.add((path, node));
    }
    node.forEach((String k, Object? v) => _collectLadders(v, '$path.$k', out));
  } else if (node is List) {
    for (int i = 0; i < node.length; i++) {
      _collectLadders(node[i], '$path[$i]', out);
    }
  }
}

void main() {
  group('C-41 R12 표시 계약 (01 §15-4 · 계약 v1.6)', () {
    test('C-41 ① 미리보기 결과는 초안·차단 중 정확히 하나이고 버튼은 차단에만 붙는다', () {
      for (final String path in <String>[_pvDefault, _pvInBand, _pvBlocked]) {
        final List<RebalancePreviewResult> rows = _previews(path);
        expect(rows, isNotEmpty, reason: path);
        for (final RebalancePreviewResult r in rows) {
          expect(
            (r.preview != null) != (r.blockedText != null),
            isTrue,
            reason:
                '$path — preview·blockedText 가 둘 다 있거나 둘 다 없다(화면이 갈래를 고르게 된다).',
          );
          if (r.blockedAction != null) {
            expect(r.blockedText, isNotNull, reason: '$path — 문장 없는 버튼.');
          }
        }
      }
      for (final String path in <String>[_pvDefault, _pvInBand]) {
        expect(
          _previews(path)
              .every((RebalancePreviewResult r) => r.preview != null),
          isTrue,
          reason: path,
        );
      }
      final List<RebalancePreviewResult> blocked = _previews(_pvBlocked);
      expect(
        blocked.every((RebalancePreviewResult r) => r.blockedText != null),
        isTrue,
      );
      expect(
        blocked.where((RebalancePreviewResult r) => r.blockedAction != null),
        isNotEmpty,
        reason: '버튼 표본이 사라지면 차단 카드의 이동 버튼을 증명할 입력이 없다.',
      );
      expect(
        blocked.where((RebalancePreviewResult r) => r.blockedAction == null),
        isNotEmpty,
        reason: '버튼 부재 표본(골든 입력)이 사라지면 «null = 부재» 갈래를 증명할 입력이 없다.',
      );
    });

    test('C-41 ② 초안은 봉투 기준 시각·머리 글자·고지·빈 초안 문장·지정가 짝을 스스로 갖춘다', () {
      for (final String path in <String>[_pvDefault, _pvInBand]) {
        final AsOf envelope = _envelopeAsOf(path);
        for (final RebalancePreviewResult r in _previews(path)) {
          final RebalancePreview p = r.preview!;
          expect(p.asOf, envelope, reason: '$path — 초안 기준 시각이 봉투와 다르다.');
          expect(p.plannedDateText.trim(), isNotEmpty, reason: path);
          expect(p.orderDraftsTitle.trim(), isNotEmpty, reason: path);
          expect(p.previewNotice, startsWith('미리보기입니다'), reason: path);
          expect(
            p.ordersEmptyText != null,
            p.orderDrafts.isEmpty,
            reason: '$path — ordersEmptyText 는 빈 초안일 때만(그때는 반드시) 있다.',
          );
          for (final OrderDraft d in p.orderDrafts) {
            expect(
              d.limitPriceText != null,
              d.limitPrice != null,
              reason: '$path ${d.symbol} — 지정가 글자와 원값의 짝이 깨졌다.',
            );
            expect(d.sideLabel.trim(), isNotEmpty, reason: d.symbol);
            expect(d.quantityText.trim(), isNotEmpty, reason: d.symbol);
            expect(kFixtureAccountAliases, contains(d.accountAlias));
            if (d.sleeve == SleeveId.b) {
              expect(kFixturePensionAccountAliases, contains(d.accountAlias));
            }
          }
        }
      }
      expect(_previews(_pvDefault).single.preview!.orderDrafts, isNotEmpty);
      expect(_previews(_pvInBand).single.preview!.orderDrafts, isEmpty);
    });

    test('C-41 ③ 다음 회차 — 카운트다운과 예정 없음이 섞이지 않고 행 asOf 가 봉투와 같다', () {
      final NextRebalanceVm countdown = NextRebalanceVm.fromJson(
        fixtureRows(FixturePaths.m7M7NextRebalanceCountdown).single,
      );
      expect(countdown.emptyLabel, isNull);
      expect(countdown.expectedDateText, isNotNull);
      expect(countdown.expectedDateText!.trim(), isNotEmpty);
      expect(countdown.dDayText, isNotNull);
      expect(countdown.dDayText!.trim(), isNotEmpty);
      expect(countdown.previewRoute, AppRoutes.rebalancePreview);

      final NextRebalanceVm none = NextRebalanceVm.fromJson(
        fixtureRows(FixturePaths.m7M7NextRebalanceNone).single,
      );
      expect(none.emptyLabel, isNotNull);
      expect(none.emptyLabel!.trim(), isNotEmpty);
      expect(
        <Object?>[
          none.expectedDateText,
          none.dDayText,
          none.expectedKind,
          none.kindLabel,
          none.previewRoute,
          none.noticeText,
        ].every((Object? v) => v == null),
        isTrue,
        reason: '예정 없음인데 카운트다운 글자·예고 링크가 함께 오면 화면이 무엇을 그릴지 고르게 된다.',
      );

      for (final String path in <String>[
        FixturePaths.m7M7NextRebalanceCountdown,
        FixturePaths.m7M7NextRebalanceNone,
      ]) {
        expect(
          NextRebalanceVm.fromJson(fixtureRows(path).single).asOf,
          _envelopeAsOf(path),
          reason: path,
        );
      }
    });

    test('C-41 ④ 회차 — 대조 표·관측 시각·비중 라벨·모드 배지·머리글이 정합한다', () {
      int compared = 0;
      int simRows = 0;
      for (final String path in _eventFixtures) {
        final AsOf envelope = _envelopeAsOf(path);
        expect(envelope.label, startsWith('자료 기준'), reason: path);
        final List<RebalanceEvent> rows = _events(path);
        expect(rows, isNotEmpty, reason: path);
        for (final RebalanceEvent e in rows) {
          final String where = '$path ${e.eventId}';
          expect(
            e.thresholds.isNotEmpty,
            e.trigger.thresholdRegistered != null,
            reason: '$where — 등록 임계가 있으면 대조 표가 있고, 없으면 표도 없다.',
          );
          for (final ThresholdCompare t in e.thresholds) {
            compared++;
            for (final String s in <String>[
              t.metricLabel,
              t.observedText,
              t.thresholdText,
              t.verdictLabel,
            ]) {
              expect(s.trim(), isNotEmpty, reason: where);
            }
          }
          expect(
            e.asOf,
            envelope,
            reason: '$where — 행 asOf 는 읽기 모델 관측 시각(봉투)이다 · 회차 시각이면 늘 «오래됨».',
          );
          for (final SleeveWeight w in <SleeveWeight>[
            ...e.before,
            ...e.after,
          ]) {
            expect(
              w.label,
              contains('%'),
              reason: '$where — 이름만 실린 라벨: ${w.label}',
            );
            expect(w.basis, AllocationBasis.accounting, reason: where);
          }
          expect(
            e.modeLabel != null,
            e.mode != RunMode.live,
            reason: '$where — 모드 배지 글자는 비 LIVE 행에만(화면이 mode 로 고르지 않게).',
          );
          if (e.mode != RunMode.live) {
            simRows++;
          }
        }
        final List<RebalanceEvent> headed = rows
            .where((RebalanceEvent e) => e.sectionLabel != null)
            .toList();
        if (path == FixturePaths.m7M7RebalanceSim) {
          // SIM 단독 봉투 한정(섞인 목록의 정렬 키 = §8 미결 89).
          expect(
            rows.every((RebalanceEvent e) => e.mode != RunMode.live),
            isTrue,
            reason: '$path 는 SIM 단독 봉투여야 한다.',
          );
          expect(headed, hasLength(1), reason: '$path — 머리글은 묶음의 첫 행 하나에만.');
          expect(headed.single, rows.first, reason: path);
        } else {
          expect(headed, isEmpty, reason: '$path — LIVE 행에 머리글.');
        }
      }
      expect(compared, greaterThan(0), reason: '대조 표 표본이 사라졌다(수용 (a)).');
      expect(simRows, greaterThan(0), reason: '모의투자 회차 표본이 사라졌다.');
    });

    test('C-41 ⑤ rebalance_6 은 거래일 엄격 내림차순이고 상세 픽스처와 같은 행을 싣는다', () {
      final List<RebalanceEvent> rows = _events(FixturePaths.rebalance6);
      for (int i = 1; i < rows.length; i++) {
        expect(
          rows[i - 1].tradeDate.yyyyMmDd.compareTo(rows[i].tradeDate.yyyyMmDd),
          greaterThan(0),
          reason:
              '${rows[i - 1].eventId} → ${rows[i].eventId} — 시간 역순(03 §11-a)이 아니다 '
              '(골든 `s76a_list` 가 명세 반대로 굳는다).',
        );
      }
      final Map<String, Object?> band = fixtureRows(
        FixturePaths.m7M7RebalanceDetailBand,
      ).single;
      final Map<String, Object?> same = fixtureRows(FixturePaths.rebalance6)
          .singleWhere(
            (Map<String, Object?> r) => r['event_id'] == band['event_id'],
            orElse: () => fail('${band['event_id']} 가 rebalance_6 에 없다.'),
          );
      expect(
        same,
        equals(band),
        reason: '목록 행과 상세 행이 다르면 S7-6a 와 S7-6b 가 같은 회차를 다르게 말한다(H47).',
      );
    });

    test('C-41 ⑥ 연간 리뷰 — 세후 원천 하나 · 갈 곳 없는 버튼 0 · 연도 글자 · 기본 연도 표본', () {
      final Map<String, Object?> ladderEnv = fixtureJson(
        FixturePaths.m7AftertaxLadder1,
      );
      final Map<String, Object?> ladderRow = fixtureRows(
        FixturePaths.m7AftertaxLadder1,
      ).single;
      final String gapMonthPrefix = AppRoutes.ledgerExecutionGapMonth.substring(
        0,
        AppRoutes.ledgerExecutionGapMonth.indexOf(':yyyyMm'),
      );
      for (final String path in _annualFixtures) {
        final Map<String, Object?> raw = fixtureRows(path).single;
        final AnnualReviewVm vm = AnnualReviewVm.fromJson(raw);
        expect(
          raw['after_tax'],
          equals(ladderRow),
          reason: '$path — 본문 사다리 사본.',
        );
        expect(
          raw['after_tax_counterfactual'],
          equals(ladderEnv['counterfactual']),
          reason: '$path — 반사실 사다리 사본.',
        );
        if (vm.afterTaxCounterfactual != null) {
          expect(vm.afterTax, isNotNull, reason: '$path — 반사실만 있는 세후 블록.');
        }
        for (final AnnualReviewSection s in vm.sections) {
          final String? route = s.route;
          if (route == null) continue;
          expect(
            <String>[AppRoutes.reportAfterTax, AppRoutes.ledgerExecutionGap],
            isNot(contains(route)),
            reason: '$path ${s.code} — 갈 곳 없는 버튼 · ㉟ 제3 진입(K16).',
          );
          expect(route, isNot(startsWith(gapMonthPrefix)), reason: path);
        }
        expect(vm.windowStateLabel.trim(), isNotEmpty, reason: path);
        expect(vm.yearLabel.trim(), isNotEmpty, reason: path);
        expect(
          vm.yearLabel,
          contains(vm.year),
          reason: '$path — 연도 글자가 고른 해를 말하지 않는다.',
        );
      }
      final AnnualReviewVm off = AnnualReviewVm.fromJson(
        fixtureRows(FixturePaths.m7M7AnnualOffwindow).single,
      );
      expect(off.windowStateCode, isNot('OPEN'));
      expect(
        off.year.compareTo(off.asOf.tradeDate.yyyyMmDd.substring(0, 4)),
        lessThan(0),
        reason: '창 밖 표본은 마지막 완결 연도여야 한다(기본 연도 규칙 · K24).',
      );
    });

    test('C-41 ⑦ 참고치 표지 글자는 isReferenceOnly 와 짝이다(예외 = 미결 79 고정 목록)', () {
      int seen = 0;
      for (final String path in FixturePaths.all) {
        final List<(String, Map<String, Object?>)> ladders =
            <(String, Map<String, Object?>)>[];
        _collectLadders(withoutMeta(fixtureJson(path)), path, ladders);
        for (final (String where, Map<String, Object?> l) in ladders) {
          final bool reference = l['is_reference_only'] == true;
          final bool labelled = l['reference_only_label'] != null;
          if (_referenceLabelExceptions.contains(path)) {
            expect(
              labelled,
              isFalse,
              reason: '$where — 예외 목록이 낡았다(표지 글자가 생겼으면 목록에서 지운다).',
            );
            continue;
          }
          seen++;
          expect(
            labelled,
            reference,
            reason: '$where — referenceOnlyLabel 이 isReferenceOnly 와 짝이 아니다.',
          );
        }
      }
      expect(seen, greaterThan(0));
      for (final String path in _referenceLabelExceptions) {
        final List<(String, Map<String, Object?>)> ladders =
            <(String, Map<String, Object?>)>[];
        _collectLadders(withoutMeta(fixtureJson(path)), path, ladders);
        expect(ladders, isNotEmpty, reason: '$path — 예외 목록이 낡았다(사다리가 없다).');
      }
      // 원천(사다리 픽스처)과 연간 3벌의 사본이 대상에 들어 있다.
      final AfterTaxLadder ladder = AfterTaxLadder.fromJson(
        fixtureRows(FixturePaths.m7AftertaxLadder1).single,
      );
      expect(ladder.isReferenceOnly, isTrue);
      expect(ladder.referenceOnlyLabel, isNotNull);
      for (final String path in _annualFixtures) {
        final AnnualReviewVm vm = AnnualReviewVm.fromJson(
          fixtureRows(path).single,
        );
        expect(vm.afterTax?.referenceOnlyLabel, isNotNull, reason: path);
        expect(
          vm.afterTaxCounterfactual?.referenceOnlyLabel,
          isNotNull,
          reason: path,
        );
      }
    });

    test('C-41 ⑧ 이행 갭 결과 — 갈래 하나 · 빈/해당없음 · asOf · 게이지 · 가림 · int ↔ 문장', () {
      for (final String path in _gapFixtures) {
        final ExecutionGapResult r = _gap(path);
        expect(
          (r.report != null) != (r.emptyLabel != null),
          isTrue,
          reason: '$path — report·emptyLabel 이 둘 다 있거나 둘 다 없다.',
        );
        expect(
          r.emptyKind != null,
          r.emptyLabel != null,
          reason: '$path — emptyKind ⇔ emptyLabel.',
        );
        final ExecutionGapReport? rep = r.report;
        if (rep == null) continue;
        expect(r.asOf, rep.asOf, reason: path);
        expect(rep.countLines, isNotEmpty, reason: path);
        final double? g = rep.complianceRateNormalized;
        if (g != null) {
          expect(g, inInclusiveRange(0, 1), reason: path);
        }
      }
      expect(
        _gap(FixturePaths.m7ExecutionGapEmpty).emptyKind,
        EmptyKind.noData,
      );
      expect(
        _gap(FixturePaths.m7ExecutionGapNotApplicable).emptyKind,
        EmptyKind.notApplicable,
      );

      // 가림 — 게이지 부재 · 글자에 아라비아 숫자 0 · «?» 포함(03 §14-b RECON_MISMATCH).
      final ExecutionGapReport masked = _gap(
        FixturePaths.m7ExecutionGapMaskedRecon,
      ).report!;
      expect(
        masked.complianceRateNormalized,
        isNull,
        reason: '가림 달에 0.0 막대가 오면 «0%»로 읽힌다.',
      );
      for (final String s in <String>[
        ...masked.countLines,
        ...masked.correctionLines,
        masked.complianceRateLabel,
        masked.medianDelayLabel,
        masked.priceGapLabel,
      ]) {
        expect(s, isNot(matches(RegExp('[0-9]'))), reason: '가림 글자에 숫자: «$s»');
        expect(s, contains('?'), reason: '가림 글자에 «?» 가 없다: «$s»');
      }

      // 가림 아닌 4벌 — int 9종이 줄 안에 «라벨 n건» 으로(교정 2종은 둘 다 0 이면 절 부재).
      for (final String path in _gapReports) {
        final ExecutionGapReport rep = _gap(path).report!;
        expect(_countsIn(rep.countLines, path), <String, int>{
          '안내': rep.issued,
          '이행': rep.filled,
          '부분 이행': rep.partial,
          '지연 이행': rep.lateFilled,
          '건너뜀': rep.skipped,
          '만료': rep.lapsed,
          '철회': rep.revoked,
        }, reason: '$path — 건수 줄과 int 가 다르다.');
        final Map<String, int> corrections = _countsIn(
          rep.correctionLines,
          path,
        );
        if (rep.backdatedCount == 0 && rep.selfReportCorrectionCount == 0) {
          expect(corrections, isEmpty, reason: '$path — 둘 다 0 이면 절 부재.');
        } else {
          expect(corrections, <String, int>{
            '소급 기록': rep.backdatedCount,
            '자가 보고 정정': rep.selfReportCorrectionCount,
          }, reason: path);
        }
      }
    });

    test('C-41 ⑨ 정상·섞인 달은 제안 줄이 없고 R12 픽스처에 금지어가 0건이다', () {
      for (final String path in <String>[
        FixturePaths.m7ExecutionGap1,
        FixturePaths.m7ExecutionGapMixed,
      ]) {
        expect(
          _gap(path).report!.modeAdviceLine,
          isNull,
          reason: '$path — ⓒ·정상 달 = 줄 부재(03 §14-b).',
        );
      }
      for (final String path in _r12Fixtures) {
        for (final ({String path, String value}) s in collectStrings(
          withoutMeta(fixtureJson(path)),
        )) {
          expect(
            _forbidden.hasMatch(s.value),
            isFalse,
            reason: '$path ${s.path} — 금지어: ${s.value}',
          );
        }
      }
    });

    test('C-41 ⑩ 월간 ⑧ 링크는 그 달의 S7-10 이고 가림·미생성 달은 링크가 없다', () {
      ReportItem execution(MonthlyReport r) =>
          r.items.singleWhere((ReportItem i) => i.code == 'D3_EXECUTION');
      for (final String path in _monthlyLinked) {
        final MonthlyReport r = MonthlyReport.fromJson(
          fixtureRows(path).single,
        );
        expect(
          execution(r).detailDeepLink,
          _gapMonthLink(r.yyyyMm),
          reason: '$path — 지난 달 ⑧ 이 다른 달(또는 기본 달)을 연다.',
        );
      }
      for (final String path in _monthlyUnlinked) {
        final MonthlyReport r = MonthlyReport.fromJson(
          fixtureRows(path).single,
        );
        expect(execution(r).detailDeepLink, isNull, reason: path);
      }
    });
  });
}
