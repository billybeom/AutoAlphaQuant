// C-40 회차↔일지 링크 정합 — 01 §15-3 · §8 미결 49(🆕 계약 v1.5).
//
// 정의: 「`S7-6b` 의 «이 회차의 … N건» 버튼(`RebalanceEvent.journalTimelineLink`)과 `J-1` 의 회차 조건
//   (`JournalRebalanceScope`)이 **같은 회차·같은 N·같은 범위**를 말한다」.
//   ① 버튼 링크 꼬리 == 그 행 `event_id`(목적지 = `AppRoutes.journalRebalance`) · 행 링크(`detail_deep_link`)
//      꼬리 == 그 행 `event_id`(목적지 = `AppRoutes.rebalanceEvent`)
//   ② 버튼 글자는 비어 있지 않고 링크를 담지 않는다
//   ③ 짝 정합(LIVE 세계) — scope 회차의 버튼 글자에 든 정수 == `journal_30` 에서 그 회차에 묶인 행 수
//      (N = 묶인 일지 행 전체 수 · 발주자 결정 ④ 2026-10-07)
//   ④ scope 글자는 식별자를 담지 않고 회차의 `kind_label`·`trade_date` 를 그대로 베끼지 않는다
//   ⑤ 버튼이 있는 행과 없는 행(= 부재 표본)이 둘 다 있다
//   ⑥ advisory 거울은 band 와 같은 회차이고 버튼 글자만 다르다(03 §11-d — 치환은 데이터에 있다)
//   ⑦ 모르는 회차의 봉투 문장은 일반 빈 일지 문장과 다르다(화면이 일반 문구로 때우면 골든이 가른다)
//   ⑧ ui 스캔 — `ui_journal/lib` 코드가 `orderIntentIds`·`RebalanceRepository` 를 말하지 않는다
//      (회차 조건은 서버측 인자 · 글자 조립·rows 거르기 금지 — 02 §7 검수 19 의 기계화)
//      🆕 2026-10-21 — `RebalanceRepository` 만 H6 대상(C-44 ⑫ 와 같은 집합: `holdings_overview.dart` ·
//      `holding_detail.dart` · `holdings_allocation.dart` + `lib/src/holdings/**`)을 뺀다(01 §17-8 — `H6-3` 이
//      기존 `watchNext()` 로 다음 회차를 읽는다). `orderIntentIds` 는 H6 대상까지 어디서나 금지 · 양성 자기 검사 동봉.
//   ⑨ scope 의 씨앗 기간이 그 회차에 묶인 행 전부를 덮고 프리셋이 아니다(발주자 결정 ⑥ 2026-10-07)
//   ⑩ `journal_30` 에 나오는 회차 id 는 전부 scope 픽스처가 안다(엔진 규칙 «scope null ⇒ 그 id 의 목록 0행»의
//      픽스처 쪽 짝 — 행은 있는데 칩이 조용히 부재하는 길을 막는다)
// 🔴 숫자를 이 파일에 적지 않는다 — 두 픽스처(데이터)를 맞댄다(§15-1 ⓙ 와 같은 방식).
// 🔴 ① 의 «패턴에 값을 끼운 기대값»은 **테스트 쪽 조립**이다 — 규칙 ③(화면이 패턴에 값을 끼우지 않는다)은
//    화면 lib 의 규칙이고, 여기서는 엔진(픽스처)이 완성한 링크를 검사하는 기준을 만든다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';
import 'support/fixture_io_t2.dart';

/// `RebalanceEvent` 를 싣는 픽스처 전부(코덱 `_rebalanceEvent` 와 같은 모집단).
/// 🆕 v1.6(01 §15-4) — `m7_rebalance_sim`(모의투자 회차 · 행 링크 꼬리 == `event_id` · 버튼 부재).
const List<String> _eventFixtures = <String>[
  FixturePaths.rebalance6,
  FixturePaths.m7M7RebalanceDetailBand,
  FixturePaths.m7M7RebalanceDetailAdvisory,
  FixturePaths.m7M7RebalanceEmpty,
  FixturePaths.m7M7RebalanceSim,
];

String _fill(String pattern, String value) {
  expect(pattern.split(':rebalanceEventId').length, 2, reason: pattern);
  return pattern.replaceFirst(':rebalanceEventId', value);
}

List<RebalanceEvent> _events(String path) =>
    fixtureRows(path).map(RebalanceEvent.fromJson).toList();

JournalRebalanceScope _scope() => JournalRebalanceScope.fromJson(
  fixtureRows(FixturePaths.m6JournalRebalanceScope1).single,
);

List<TradeJournalEntry> _journal30() =>
    fixtureRows(FixturePaths.journal30)
        .map(TradeJournalEntry.fromJson)
        .toList();

/// 글자 안의 정수 하나(«이 회차의 주문 3건» → 3). 정수가 정확히 하나여야 한다.
int _countIn(String label) {
  final List<RegExpMatch> m = RegExp(r'[0-9]+').allMatches(label).toList();
  expect(m, hasLength(1), reason: '버튼 글자에 정수가 하나여야 한다: «$label»');
  return int.parse(m.single.group(0)!);
}

// ─── ⑧ ui 스캔 — 금지 이름과 H6 예외 ─────────────────────────────────────────

/// ⑧ `ui_journal/lib` 어디서나(H6 대상 포함) 금지.
final RegExp _bannedEverywhere = RegExp(r'\borderIntentIds\b');

/// ⑧ H6 대상 밖에서만 금지 — 🆕 2026-10-21 발주자 결정: `H6-3` 은 01 §17-8 대로 기존
/// `RebalanceRepository.watchNext()` 로 다음 회차를 읽는다(일지 `J-1` 의 «회차 조건은 서버측 인자» 규칙은 그대로).
final RegExp _bannedOutsideH6 = RegExp(r'\bRebalanceRepository\b');

/// H6 대상 공개 파일 3(`ui_journal` 기준) — C-44 ⑫ 의 `_h6PublicFiles` 와 같은 집합(아래 ⑧ 이 맞댄다).
const List<String> _h6PublicFiles = <String>[
  'lib/src/holdings_overview.dart',
  'lib/src/holding_detail.dart',
  'lib/src/holdings_allocation.dart',
];

/// H6 내부 조각 폴더(`/` 로 끝난다 · 아래 전부) — C-44 ⑫ 의 `_h6InternalDir` 와 같다.
const String _h6InternalDir = 'lib/src/holdings/';

bool _isH6Target(String rel) =>
    _h6PublicFiles.contains(rel) || rel.startsWith(_h6InternalDir);

/// [rel](`ui_journal` 기준 경로) 의 [source] 가 ⑧ 에서 걸리는 이름(주석 속 언급은 통과).
List<String> _c40Hits(String rel, String source) {
  final String code = stripComments(source);
  return <String>[
    if (_bannedEverywhere.hasMatch(code)) 'orderIntentIds',
    if (!_isH6Target(rel) && _bannedOutsideH6.hasMatch(code))
      'RebalanceRepository',
  ];
}

void main() {
  group('C-40 회차↔일지 링크 정합 (01 §15-3 · 계약 v1.5)', () {
    test('C-40 ① 버튼·행 링크의 꼬리는 그 행 event_id 다', () {
      int links = 0;
      for (final String path in _eventFixtures) {
        for (final RebalanceEvent e in _events(path)) {
          final LinkAction? link = e.journalTimelineLink;
          if (link != null) {
            links++;
            expect(
              link.deepLink,
              _fill(AppRoutes.journalRebalance, e.eventId),
              reason: '$path ${e.eventId} — 버튼이 다른 회차·다른 목적지를 연다.',
            );
          }
          expect(
            e.detailDeepLink,
            _fill(AppRoutes.rebalanceEvent, e.eventId),
            reason: '$path ${e.eventId} — 행 링크가 없거나 다른 회차를 연다.',
          );
        }
      }
      expect(links, greaterThan(0), reason: '버튼 표본이 하나도 없다(검사가 공허하다).');
    });

    test('C-40 ② 버튼 글자는 비어 있지 않고 링크를 담지 않는다', () {
      for (final String path in _eventFixtures) {
        for (final RebalanceEvent e in _events(path)) {
          final LinkAction? link = e.journalTimelineLink;
          if (link == null) continue;
          expect(link.label.trim(), isNotEmpty, reason: '$path ${e.eventId}');
          expect(link.label, isNot(contains('aaq://')), reason: e.eventId);
          expect(link.label, isNot(contains(e.eventId)), reason: e.eventId);
        }
      }
    });

    test('C-40 ③ scope 회차의 버튼 N == journal_30 에서 그 회차에 묶인 행 수', () {
      final JournalRebalanceScope scope = _scope();
      final List<RebalanceEvent> live = _events(FixturePaths.rebalance6);
      final RebalanceEvent event = live.singleWhere(
        (RebalanceEvent e) => e.eventId == scope.rebalanceEventId,
        orElse: () =>
            fail('scope 회차 ${scope.rebalanceEventId} 가 rebalance_6 에 없다.'),
      );
      final int bound = _journal30()
          .where((TradeJournalEntry j) => j.rebalanceEventId == event.eventId)
          .length;
      expect(bound, greaterThan(0), reason: 'scope 회차에 묶인 일지 행이 없다.');
      expect(event.journalTimelineLink, isNotNull);
      expect(
        _countIn(event.journalTimelineLink!.label),
        bound,
        reason: '버튼의 N 과 링크가 여는 목록의 행 수가 다르다(N = 묶인 일지 행 전체 수).',
      );
    });

    test('C-40 ④ scope 글자는 식별자·다른 DTO 글자를 그대로 쓰지 않는다', () {
      final JournalRebalanceScope scope = _scope();
      final RebalanceEvent event = _events(
        FixturePaths.rebalance6,
      ).singleWhere((RebalanceEvent e) => e.eventId == scope.rebalanceEventId);
      expect(scope.label.trim(), isNotEmpty);
      expect(scope.label, isNot(contains(scope.rebalanceEventId)));
      expect(scope.label, isNot(event.kindLabel));
      expect(scope.label, isNot(event.tradeDate.yyyyMmDd));
    });

    test('C-40 ⑤ 버튼이 있는 행과 없는 행(부재 표본)이 둘 다 있다', () {
      final List<RebalanceEvent> rows = _events(FixturePaths.rebalance6);
      expect(
        rows.where((RebalanceEvent e) => e.journalTimelineLink != null),
        isNotEmpty,
      );
      expect(
        rows.where((RebalanceEvent e) => e.journalTimelineLink == null),
        isNotEmpty,
        reason: 'null = 버튼 부재 표본이 사라지면 화면의 «부재» 갈래를 증명할 입력이 없다.',
      );
    });

    test('C-40 ⑥ advisory 거울은 band 와 같은 회차이고 버튼 글자만 다르다', () {
      final RebalanceEvent band = _events(FixturePaths.m7M7RebalanceDetailBand)
          .single;
      final RebalanceEvent adv = _events(
        FixturePaths.m7M7RebalanceDetailAdvisory,
      ).single;
      expect(adv.eventId, band.eventId);
      expect(band.journalTimelineLink, isNotNull);
      expect(adv.journalTimelineLink, isNotNull);
      expect(
        adv.journalTimelineLink!.deepLink,
        band.journalTimelineLink!.deepLink,
      );
      expect(
        adv.journalTimelineLink!.label,
        isNot(band.journalTimelineLink!.label),
        reason: '03 §11-d — advisory 치환은 데이터(글자)에 있다. 같으면 화면 분기가 필요해진다.',
      );
      // 글자 밖의 필드는 같다(표지 = 라벨 글자뿐).
      final Map<String, Object?> a = Map<String, Object?>.of(adv.toJson())
        ..remove('journal_timeline_link');
      final Map<String, Object?> b = Map<String, Object?>.of(band.toJson())
        ..remove('journal_timeline_link');
      expect(jsonEncode(a), jsonEncode(b));
    });

    test('C-40 ⑦ 모르는 회차의 봉투 문장은 일반 빈 일지 문장과 다르다', () {
      final Map<String, Object?> unknown = fixtureJson(
        FixturePaths.m6JournalRebalanceUnknown,
      );
      final Map<String, Object?> empty = fixtureJson(
        FixturePaths.m6JournalEmpty,
      );
      expect(unknown['rows'], isEmpty);
      expect(unknown['empty_label'], isA<String>());
      expect(unknown['empty_label'], isNot(empty['empty_label']));
      // `S7-6a` 빈 타임라인도 문장이 있다(★ⓒ · 화면이 빈 상태 문구를 쓰지 않는다).
      final Map<String, Object?> s76a = fixtureJson(
        FixturePaths.m7M7RebalanceEmpty,
      );
      expect(s76a['rows'], isEmpty);
      expect(s76a['empty_label'], isA<String>());
    });

    test('C-40 ⑧ ui_journal 코드는 orderIntentIds 를 말하지 않고 RebalanceRepository 는 H6 대상만 말한다', () {
      const String pkg = 'packages/ui_journal';
      final Directory lib = Directory('${repoRoot.path}/$pkg/lib');
      expect(lib.existsSync(), isTrue, reason: lib.path);
      final List<String> hits = <String>[
        for (final File f in dartSourcesIn(lib))
          for (final String name in _c40Hits(
            shortPath(f).substring(pkg.length + 1),
            f.readAsStringSync(),
          ))
            '${shortPath(f)}: $name',
      ];
      expect(
        hits,
        isEmpty,
        reason:
            '회차 조건은 watchTimeline 의 서버측 인자이고 칩 글자는 watchRebalanceScope 가 준다 — '
            '`J-1` 이 회차 리포지토리를 끌어와 글자를 조립하거나 rows 를 거르면 반려(02 §7 검수 19). '
            'RebalanceRepository 는 H6 대상(01 §17-8 — H6-3 의 watchNext)만 · orderIntentIds 는 어디서나 금지.',
      );
      // H6 대상 집합 == C-44 ⑫ 의 대상(한쪽만 바뀌면 걸린다).
      final String c44 = File(
        '${repoRoot.path}/packages/domain_contracts/test/contracts/c44_holdings_test.dart',
      ).readAsStringSync();
      for (final String rel in <String>[..._h6PublicFiles, _h6InternalDir]) {
        expect(c44, contains("'$rel'"), reason: 'C-44 ⑫ 대상에 $rel 이 없다');
      }
      // 자체 검증 — 음성(통과해야 한다).
      expect(
        _c40Hits('lib/src/journal_timeline.dart', '// orderIntentIds 는 쓰지 않는다'),
        isEmpty,
      );
      expect(
        _c40Hits(
          'lib/src/holdings_overview.dart',
          'final RebalanceRepository r;',
        ),
        isEmpty,
      );
      expect(
        _c40Hits(
          'lib/src/holdings/next_rebalance.dart',
          'final RebalanceRepository r;',
        ),
        isEmpty,
      );
      // 자체 검증 — 양성(반드시 걸린다).
      expect(
        _c40Hits(
          'lib/src/journal_timeline.dart',
          'final x = e.orderIntentIds.length;',
        ),
        <String>['orderIntentIds'],
      );
      expect(
        _c40Hits(
          'lib/src/journal_timeline.dart',
          'final RebalanceRepository r;',
        ),
        <String>['RebalanceRepository'],
        reason: 'H6 대상 밖 ui_journal 파일의 RebalanceRepository 는 여전히 걸린다',
      );
      expect(
        _c40Hits(
          'lib/src/holdings_overview_extra.dart',
          'final RebalanceRepository r;',
        ),
        <String>['RebalanceRepository'],
        reason: '대상 파일 이름을 앞부분만 닮은 파일은 대상이 아니다',
      );
      expect(
        _c40Hits(
          'lib/src/holding_detail.dart',
          'final x = e.orderIntentIds.length;',
        ),
        <String>['orderIntentIds'],
        reason: 'H6 대상 파일이어도 orderIntentIds 는 걸린다',
      );
      expect(
        _c40Hits(
          'lib/src/holdings/next_rebalance.dart',
          'e.orderIntentIds; RebalanceRepository r;',
        ),
        <String>['orderIntentIds'],
      );
    });

    test('C-40 ⑨ scope 의 씨앗 기간은 그 회차에 묶인 행 전부를 덮고 프리셋이 아니다', () {
      final JournalRebalanceScope scope = _scope();
      final List<TradeJournalEntry> bound = _journal30()
          .where(
            (TradeJournalEntry j) =>
                j.rebalanceEventId == scope.rebalanceEventId,
          )
          .toList();
      expect(bound, isNotEmpty);
      for (final TradeJournalEntry j in bound) {
        expect(
          j.tradeDate.yyyyMmDd.compareTo(scope.range.from.yyyyMmDd) >= 0 &&
              j.tradeDate.yyyyMmDd.compareTo(scope.range.to.yyyyMmDd) <= 0,
          isTrue,
          reason:
              '${j.entryId} ${j.tradeDate.yyyyMmDd} 가 씨앗 기간 ${scope.range.from.yyyyMmDd}~${scope.range.to.yyyyMmDd} 밖이다 — '
              '«N건» 버튼이 N 보다 적게 연다.',
        );
      }
      expect(scope.range.isDefault, isFalse);
      expect(scope.range.presetCode, isNull);
      expect(scope.range.label, isNotNull);
    });

    test('C-40 ⑩ journal_30 의 회차 id 는 전부 scope 픽스처가 안다', () {
      final Set<String> scoped =
          fixtureRows(FixturePaths.m6JournalRebalanceScope1)
              .map(
                (Map<String, Object?> r) =>
                    JournalRebalanceScope.fromJson(r).rebalanceEventId,
              )
              .toSet();
      final Set<String> inJournal = _journal30()
          .map((TradeJournalEntry j) => j.rebalanceEventId)
          .whereType<String>()
          .toSet();
      expect(inJournal, isNotEmpty);
      expect(
        inJournal.difference(scoped),
        isEmpty,
        reason: '일지 행이 묶인 회차인데 scope 가 없다 — 칩이 조용히 부재한다(엔진 규칙 위반의 픽스처 꼴).',
      );
    });
  });
}
