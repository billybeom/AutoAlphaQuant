// C-51 장애 배너·런북·긴급 카드·핸드북·기기 리스크·엔진 D11 — 01 §26(🆕 계약 v1.17 · R16 선행 + 엔진 E10 D11 ·
// 발주자 결정 2026-11-04 ①~④).
//
// 정의: 「M8 장애·DR·핸드북·기기 리스크 화면은 엔진이 완성한 VM 으로 온다 — 배너는 최대 1건(고르기·정렬 = 엔진 ·
//        종류 = 아이콘만 · 모르는 종류 = other) · 런북·카드·목차는 문서 VM(asOf 칸 0 · 모르는 id·앵커도 값 ·
//        번호 = 글자 · 링크 = 데이터) · 핸드북 뒤처짐 = 엔진 글자(해시 대조 = 엔진 내부) · live 블록이 있으면 asOf ·
//        기기 리스크 = 측정값(asOf 있음) — 그리고 엔진 D11 네 글자(실효 · PREVENTED 근거 · 다음 날 가드 알림 코드)가
//        표본과 맞는다」.
//   ① 허용 키 ② 배너 ③ 런북 목록 ④ 런북 상세 ⑤ 긴급 카드 ⑥ 핸드북 목차 ⑦ 핸드북 페이지 ⑧ 뒤처짐 해시(C-13 ⓐ)
//   ⑨ 기기 리스크 ⑩ D11 실효 ⑪ D11 PREVENTED 근거 ⑫ D11 알림 코드 ⑬ 받침대 ⑭ 라우트.
//
// 🔴 픽스처 불변식만 본다 — `ui_shell` 화면 스캔은 R16 카드 정적 묶음 몫(01 §8 미결 144).
// 🔴 한국어 글자 단언 0 — 상수 리터럴 = 표본 id·키 이름·코드·라우트 상수·`FixturePaths` 뿐.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_fixture_registry.dart';
import 'c00_support.dart';

const List<String> _banners = <String>[
  FixturePaths.m8IncidentBannerTokenExpired,
  FixturePaths.m8IncidentBannerOrderRejected,
  FixturePaths.m8IncidentBannerNetworkDown,
  FixturePaths.m8IncidentBannerPhoneDown,
  FixturePaths.m8IncidentBannerOther,
  FixturePaths.m8IncidentBannerNone,
];

const List<String> _runbookIndexes = <String>[
  FixturePaths.m8RunbookIndex,
  FixturePaths.m8RunbookIndexEmpty,
];

const List<String> _runbooks = <String>[
  FixturePaths.m8RunbookHostLost,
  FixturePaths.m8RunbookMissing,
];

const List<String> _cards = <String>[
  FixturePaths.m8EmergencyCard,
  FixturePaths.m8EmergencyCardNoPrint,
];

const List<String> _hbIndexes = <String>[
  FixturePaths.m8HandbookIndex,
  FixturePaths.m8HandbookIndexOutdated,
];

/// live 블록이 없는 페이지(문서 VM · asOf 0 — K20).
const List<String> _hbDocPages = <String>[
  FixturePaths.m8HandbookPageOutdated,
  FixturePaths.m8HandbookPageMissing,
  FixturePaths.m8HandbookPageArchived,
];

const List<String> _hbPages = <String>[
  FixturePaths.m8HandbookPageSleeveB,
  ..._hbDocPages,
];

const List<String> _devices = <String>[
  FixturePaths.m8DeviceRiskItems,
  FixturePaths.m8DeviceRiskEmpty,
];

/// K20 — 문서·지속 상태 VM(asOf 칸 0).
const List<String> _docVms = <String>[
  ..._banners,
  ..._runbookIndexes,
  ..._runbooks,
  ..._cards,
  ..._hbIndexes,
  ..._hbDocPages,
];

/// 원고 id 꼴(K10 · 엔진 의무).
final RegExp _runbookId = RegExp(r'^[a-z][a-z0-9-]*$');

/// 개인 전화번호 꼴(C-51 ⑤ · 공개 고객센터 대표번호 «1544-5000» 꼴은 걸리지 않는다).
final RegExp _personalPhone = RegExp(r'01[016-9]-?[0-9]{3,4}-?[0-9]{4}');

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _maps(Object? list) =>
    (list! as List<Object?>).cast<Map<String, Object?>>();

List<Map<String, Object?>> _rows(String path) => _maps(_env(path)['rows']);

/// VM 1행 봉투의 VM.
Map<String, Object?> _vm(String path) {
  final List<Map<String, Object?>> rows = _rows(path);
  expect(rows, hasLength(1), reason: '$path — VM 1행 봉투가 아니다');
  return rows.single;
}

Map<String, Object?>? _map(Object? v) => v as Map<String, Object?>?;

Set<String> _keys(Map<String, Object?> m) => m.keys.toSet();

/// 런북 상세 링크의 앞부분(`aaq://ops/runbooks/`) — 라우트 상수에서 만든다.
final String _runbookPrefix = AppRoutes.opsRunbook.replaceFirst(
  ':runbookId',
  '',
);

/// 문자열 값 전부.
List<String> _strings(Object? node) {
  final List<String> out = <String>[];
  void visit(Object? n) {
    if (n is String) {
      out.add(n);
    } else if (n is Map) {
      n.values.forEach(visit);
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// 목차 항목 전부(자식 포함 · 받은 차례).
List<Map<String, Object?>> _allEntries(List<Map<String, Object?>> entries) =>
    <Map<String, Object?>>[
      for (final Map<String, Object?> e in entries) ...<Map<String, Object?>>[
        e,
        ..._allEntries(_maps(e['children'] ?? <Object?>[])),
      ],
    ];

/// 등록부가 `TradeJournalEntry` 로 묶은 표본 전부의 행.
List<(String, Map<String, Object?>)> _journalRows() =>
    <(String, Map<String, Object?>)>[
      for (final MapEntry<String, FixtureBinding> b in fixtureBindings.entries)
        if (b.value.rows.typeName == 'TradeJournalEntry')
          for (final Map<String, Object?> r in _rows(b.key)) (b.key, r),
    ];

List<String> _reasonCodes(Map<String, Object?> row) => <String>[
  for (final Map<String, Object?> c in _maps(row['reasons']))
    c['code']! as String,
];

void main() {
  group('C-51 장애 배너·런북·긴급 카드·핸드북·기기 리스크·엔진 D11 (01 §26 · 계약 v1.17)', () {
    test('C-51 ① 허용 키 — 표본 키 = toJson() 키 · 핸드북 ⊆ · 문서 VM 에 as_of 0', () {
      for (final String path in _banners) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          _keys(vm),
          IncidentBannerVm.fromJson(vm).toJson().keys.toSet(),
          reason: path,
        );
        final Map<String, Object?>? banner = _map(vm['banner']);
        if (banner != null) {
          expect(
            _keys(banner),
            IncidentBanner.fromJson(banner).toJson().keys.toSet(),
            reason: path,
          );
        }
      }
      for (final String path in _runbookIndexes) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          _keys(vm),
          RunbookIndexVm.fromJson(vm).toJson().keys.toSet(),
          reason: path,
        );
        for (final Map<String, Object?> r in _maps(vm['rows'])) {
          expect(
            _keys(r),
            RunbookRow.fromJson(r).toJson().keys.toSet(),
            reason: path,
          );
        }
      }
      final List<Map<String, Object?>> steps = <Map<String, Object?>>[];
      for (final String path in _runbooks) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          _keys(vm),
          RunbookVm.fromJson(vm).toJson().keys.toSet(),
          reason: path,
        );
        steps.addAll(_maps(vm['steps']));
      }
      for (final String path in _cards) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          _keys(vm),
          EmergencyCardVm.fromJson(vm).toJson().keys.toSet(),
          reason: path,
        );
        steps.addAll(_maps(vm['steps']));
      }
      expect(steps, isNotEmpty);
      for (final Map<String, Object?> s in steps) {
        expect(_keys(s), RunbookStep.fromJson(s).toJson().keys.toSet());
      }
      for (final String path in _devices) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          _keys(vm),
          DeviceRiskVm.fromJson(vm).toJson().keys.toSet(),
          reason: path,
        );
        for (final Map<String, Object?> r in _maps(vm['rows'])) {
          expect(
            _keys(r),
            DeviceRiskItem.fromJson(r).toJson().keys.toSet(),
            reason: path,
          );
        }
      }
      // 핸드북 4타입 — 표본 키 ⊆ toJson() 키(옛 블록은 부분집합 허용).
      int liveCount = 0;
      for (final String path in _hbIndexes) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          HandbookIndex.fromJson(vm)
              .toJson()
              .keys
              .toSet()
              .containsAll(_keys(vm)),
          isTrue,
          reason: path,
        );
        for (final Map<String, Object?> e in _allEntries(
          _maps(vm['entries']),
        )) {
          expect(
            HandbookEntry.fromJson(e)
                .toJson()
                .keys
                .toSet()
                .containsAll(_keys(e)),
            isTrue,
            reason: '$path ${e['anchor']}',
          );
        }
      }
      for (final String path in _hbPages) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          HandbookPage.fromJson(vm)
              .toJson()
              .keys
              .toSet()
              .containsAll(_keys(vm)),
          isTrue,
          reason: path,
        );
        for (final Map<String, Object?> b in _maps(vm['blocks'])) {
          expect(
            HandbookBlock.fromJson(b)
                .toJson()
                .keys
                .toSet()
                .containsAll(_keys(b)),
            isTrue,
            reason: path,
          );
          final Map<String, Object?>? live = _map(b['live']);
          if (live != null) {
            liveCount++;
            expect(
              _keys(live),
              HandbookLiveValue.fromJson(live).toJson().keys.toSet(),
              reason: path,
            );
          }
        }
      }
      expect(liveCount, greaterThanOrEqualTo(1));
      // K20 — 문서·지속 상태 VM 에 as_of 칸 0(봉투에만).
      for (final String path in _docVms) {
        expect(
          _vm(path)['as_of'],
          isNull,
          reason: '$path — 문서 VM 에 asOf 를 되살렸다(01 §26 K20 · 결정 ②).',
        );
      }
    });

    test('C-51 ② 배너 — 최대 1건 · 종류 5 전수 · OK 0 · 조치 있음/없음 · 모르는 종류 = other', () {
      final List<String> kinds = <String>[];
      final List<Object?> actions = <Object?>[];
      final List<String> noneBanner = <String>[];
      for (final String path in _banners) {
        final List<Map<String, Object?>> rows = _rows(path);
        expect(rows, hasLength(1), reason: '$path — 배너는 VM 1건(최대 1건 = 엔진).');
        final Map<String, Object?>? banner = _map(rows.single['banner']);
        if (banner == null) {
          noneBanner.add(path);
          continue;
        }
        kinds.add(banner['kind']! as String);
        expect(
          <String>{
            UiLevel.blocked.wire,
            UiLevel.act.wire,
            UiLevel.watch.wire,
            UiLevel.info.wire,
          },
          contains(banner['level']),
          reason: '$path — 배너 = 이상 상태(OK 는 오지 않는다).',
        );
        actions.add(banner['action_link']);
      }
      expect(noneBanner, <String>[FixturePaths.m8IncidentBannerNone]);
      expect(
        kinds..sort(),
        (IncidentKind.values.map((IncidentKind k) => k.wire).toList()..sort()),
        reason: '종류 5값 전수 · 각 1벌 — 아이콘 갈래가 표본 동치가 되지 않게.',
      );
      expect(actions.any((Object? a) => a != null), isTrue);
      expect(actions.any((Object? a) => a == null), isTrue);
      final Map<String, Object?> copy = jsonDecode(
        jsonEncode(_vm(FixturePaths.m8IncidentBannerOther)),
      ) as Map<String, Object?>;
      (copy['banner']! as Map<String, Object?>)['kind'] = 'NEW_KIND_X';
      expect(
        IncidentBannerVm.fromJson(copy).banner!.kind,
        IncidentKind.other,
        reason: '엔진이 종류를 늘려도 화면이 죽지 않는다(unknownEnumValue).',
      );
    });

    test('C-51 ③ 런북 목록 — 6행 · id 꼴 · ⑥ = 카드 · 요약 null · 빈 문장 조건', () {
      final Map<String, Object?> index = _vm(FixturePaths.m8RunbookIndex);
      final List<Map<String, Object?>> rows = _maps(index['rows']);
      expect(rows, hasLength(6));
      expect(index['empty_label'], isNull);
      final List<String> ids = <String>[];
      for (final Map<String, Object?> r in rows) {
        final String link = r['deep_link']! as String;
        expect(AppRoutes.isRegistered(link), isTrue, reason: link);
        if (link == AppRoutes.opsEmergencyCard) {
          continue;
        }
        expect(link.startsWith(_runbookPrefix), isTrue, reason: link);
        final String id = link.substring(_runbookPrefix.length);
        expect(_runbookId.hasMatch(id), isTrue, reason: link);
        ids.add(id);
      }
      expect(ids.toSet(), hasLength(ids.length), reason: '런북 id 가 겹친다.');
      expect(
        rows.where(
          (Map<String, Object?> r) =>
              r['deep_link'] == AppRoutes.opsEmergencyCard,
        ),
        hasLength(1),
        reason: '⑥ 행 = D-03 카드(K7 ⓓ).',
      );
      expect(
        rows.any((Map<String, Object?> r) => r['summary_text'] == null),
        isTrue,
      );
      final Map<String, Object?> empty = _vm(FixturePaths.m8RunbookIndexEmpty);
      expect(_maps(empty['rows']), isEmpty);
      expect(empty['empty_label'], isNotNull);
    });

    test('C-51 ④ 런북 상세 — 번호 = 글자(비순번) · 목록과 짝 · 모르는 id = 값', () {
      final Map<String, Object?> host = _vm(FixturePaths.m8RunbookHostLost);
      final List<Map<String, Object?>> steps = _maps(host['steps']);
      expect(steps, isNotEmpty);
      expect(host['missing_label'], isNull);
      expect(host['intro_text'], isNotNull);
      expect(
        <int>[
          for (int i = 0; i < steps.length; i++)
            if (steps[i]['order_text'] != '${i + 1}.') i,
        ],
        isNotEmpty,
        reason: '번호가 전부 i + 1 이면 화면이 번호를 지어내도 표본이 같다.',
      );
      final List<String> links = <String>[
        for (final Map<String, Object?> r in _maps(
          _vm(FixturePaths.m8RunbookIndex)['rows'],
        ))
          r['deep_link']! as String,
      ];
      expect(links, contains('${_runbookPrefix}host-lost'));
      final Map<String, Object?> missing = _vm(FixturePaths.m8RunbookMissing);
      expect(_maps(missing['steps']), isEmpty);
      expect(missing['intro_text'], isNull);
      expect(missing['missing_label'], isNotNull);
      for (final String path in _runbooks) {
        expect(_vm(path)['local_check_notice'], isNotEmpty, reason: path);
        RunbookVm.fromJson(_vm(path));
      }
    });

    test('C-51 ⑤ 긴급 카드 — 인쇄 갈래 · 비순번 · 계좌·앱키·개인 연락처 0', () {
      for (final String path in _cards) {
        final Map<String, Object?> vm = _vm(path);
        expect(_maps(vm['steps']), isNotEmpty, reason: path);
        expect(vm['contact_line'], isNotEmpty, reason: path);
        expect(vm['keep_on_paper_notice'], isNotEmpty, reason: path);
        expect(
          scanForSecrets(readFixture(path)),
          isEmpty,
          reason: '$path — 계좌번호·앱키 꼴(C-14 패턴).',
        );
        for (final String s in _strings(vm)) {
          expect(
            _personalPhone.hasMatch(s),
            isFalse,
            reason: '$path — 개인 전화번호 꼴: $s',
          );
          expect(scanForSecrets('"$s"'), isEmpty, reason: '$path — $s');
        }
      }
      final Map<String, Object?> card = _vm(FixturePaths.m8EmergencyCard);
      expect(card['print_slot_id'], OpsSlotIds.emergencyCardPrint);
      expect(_vm(FixturePaths.m8EmergencyCardNoPrint)['print_slot_id'], isNull);
      final List<Map<String, Object?>> steps = _maps(card['steps']);
      expect(<int>[
        for (int i = 0; i < steps.length; i++)
          if (steps[i]['order_text'] != '${i + 1}.') i,
      ], isNotEmpty);
    });

    test('C-51 ⑥ 핸드북 목차 — 8 · 차례 · 자식 4(보관됨) · 준비 중 · 링크 = 데이터 · 뒤처짐 한 벌', () {
      final List<String> entriesJson = <String>[];
      for (final String path in _hbIndexes) {
        final Map<String, Object?> vm = _vm(path);
        final List<Map<String, Object?>> entries = _maps(vm['entries']);
        expect(entries, hasLength(8), reason: path);
        expect(
          <Object?>[for (final Map<String, Object?> e in entries) e['order']],
          <int>[1, 2, 3, 4, 5, 6, 7, 8],
          reason: path,
        );
        final List<Map<String, Object?>> children = _maps(
          entries[1]['children'],
        );
        expect(children, hasLength(4), reason: path);
        expect(children[3]['state'], HandbookEntryState.archived.wire);
        expect(children[3]['state_label'], isNotNull);
        for (final Map<String, Object?> e in entries.sublist(5, 8)) {
          expect(e['state'], HandbookEntryState.preparing.wire, reason: path);
          expect(e['deep_link'], isNull, reason: path);
          expect(e['state_label'], isNotNull, reason: path);
        }
        for (final Map<String, Object?> e in _allEntries(entries)) {
          if (e['state'] == HandbookEntryState.ready.wire) {
            expect(e['state_label'], isNull, reason: '$path ${e['anchor']}');
            expect(e['deep_link'], isNotNull, reason: '$path ${e['anchor']}');
          }
          final Object? link = e['deep_link'];
          if (link != null) {
            expect(
              (link as String).startsWith('${AppLinkSchemes.handbook}://'),
              isTrue,
              reason: link,
            );
          }
        }
        expect(
          children[1]['deep_link'],
          isNot('${AppLinkSchemes.handbook}://${children[1]['anchor']}'),
          reason: '화면이 handbook://<앵커> 를 지어내도 표본이 같으면 잡지 못한다.',
        );
        entriesJson.add(jsonEncode(entries));
      }
      expect(_vm(FixturePaths.m8HandbookIndex)['outdated_notice'], isNull);
      expect(
        _vm(FixturePaths.m8HandbookIndexOutdated)['outdated_notice'],
        isNotNull,
      );
      expect(entriesJson[0], entriesJson[1], reason: '두 벌은 뒤처짐 고지만 다르다.');
      for (final String path in _hbIndexes) {
        HandbookIndex.fromJson(_vm(path));
      }
    });

    test('C-51 ⑦ 핸드북 페이지 — 모르는 앵커 ⇔ 본문 0 · live ⇔ as_of · sleeve_b 형태', () {
      for (final String path in _hbPages) {
        final Map<String, Object?> vm = _vm(path);
        final List<Map<String, Object?>> blocks = _maps(vm['blocks']);
        expect(vm['missing_label'] != null, blocks.isEmpty, reason: path);
        expect(
          blocks.any((Map<String, Object?> b) => b['live'] != null),
          vm['as_of'] != null,
          reason: '$path — live 블록이 있으면 asOf non-null · 없으면 null(결정 ④ R16b ⑨).',
        );
        expect(
          vm['outdated_notice'] != null,
          path == FixturePaths.m8HandbookPageOutdated,
          reason: path,
        );
        HandbookPage.fromJson(vm);
      }
      final Map<String, Object?> sleeveB = _vm(
        FixturePaths.m8HandbookPageSleeveB,
      );
      final List<Map<String, Object?>> blocks = _maps(sleeveB['blocks']);
      expect(blocks, hasLength(5));
      expect(blocks[1]['live'], isNotNull);
      expect(blocks[3]['deep_link'], isNotNull);
      expect(
        _env(FixturePaths.m8HandbookPageSleeveB).containsKey('index'),
        isFalse,
      );
      final List<Map<String, Object?>> children = _maps(
        _maps(_vm(FixturePaths.m8HandbookIndex)['entries'])[1]['children'],
      );
      expect(
        _vm(FixturePaths.m8HandbookPageArchived)['anchor'],
        children[3]['anchor'],
      );
    });

    test('C-51 ⑧ 뒤처짐 해시(C-13 ⓐ) — 핸드북 6벌 행 config_hash = 봉투 meta', () {
      for (final String path in <String>[..._hbIndexes, ..._hbPages]) {
        final Map<String, Object?> env = _env(path);
        final Map<String, Object?> meta = env['meta']! as Map<String, Object?>;
        expect(
          _vm(path)['config_hash'],
          meta['config_hash'],
          reason: '$path — 뒤처짐은 글자(outdated_notice)로 온다 · 해시 대조 = 엔진 내부.',
        );
      }
    });

    test('C-51 ⑨ 기기 리스크 — 5행 · 등급 5값 전수 · 안내 늘 · 빈 문장 조건 · as_of 있음', () {
      final Map<String, Object?> items = _vm(FixturePaths.m8DeviceRiskItems);
      final List<Map<String, Object?>> rows = _maps(items['rows']);
      expect(rows, hasLength(5));
      expect(
        rows.map((Map<String, Object?> r) => r['level']).toSet(),
        UiLevel.values.map((UiLevel l) => l.wire).toSet(),
      );
      for (final Map<String, Object?> r in rows) {
        for (final String key in <String>[
          'label',
          'current_text',
          'threshold_text',
          'action_text',
          'last_checked_text',
        ]) {
          expect(r[key], isNotEmpty, reason: key);
        }
      }
      expect(items['guidance_text'], isNotEmpty);
      expect(items['empty_label'], isNull);
      final Map<String, Object?> empty = _vm(FixturePaths.m8DeviceRiskEmpty);
      expect(_maps(empty['rows']), isEmpty);
      expect(empty['empty_label'], isNotNull);
      expect(empty['guidance_text'], isNotNull);
      for (final String path in _devices) {
        expect(
          DeviceRiskVm.fromJson(_vm(path)).asOf.label,
          isNotEmpty,
          reason: path,
        );
      }
    });

    test(
      'C-51 ⑩ D11 실효 — JournalStatus.expired · 칩 DAY_END_EXPIRED 는 실효 행에만',
      () {
        expect(JournalStatus.values, contains(JournalStatus.expired));
        expect(JournalStatus.expired.wire, 'EXPIRED');
        final List<Map<String, Object?>> rows = _rows(
          FixturePaths.m6JournalExpired1,
        );
        expect(rows, hasLength(1));
        final Map<String, Object?> row = rows.single;
        expect(row['status'], JournalStatus.expired.wire);
        expect(row['executed_at'], isNull);
        expect(
          _reasonCodes(row)
              .where((String c) => c == JournalReasonCodes.dayEndExpired),
          hasLength(1),
        );
        final TradeJournalEntry entry = TradeJournalEntry.fromJson(row);
        expect(entry.status, JournalStatus.expired);
        for (final (String path, Map<String, Object?> r) in _journalRows()) {
          if (r['status'] != JournalStatus.expired.wire) {
            expect(
              _reasonCodes(r),
              isNot(contains(JournalReasonCodes.dayEndExpired)),
              reason: '$path ${r['entry_id']} — 실효 근거 칩이 실효 아닌 행에 있다.',
            );
          }
        }
      },
    );

    test('C-51 ⑪ D11 PREVENTED 근거 — 칩 DUPLICATE_ORDER_PREVENTED 1 · 원 의도 intent_id', () {
      int prevented = 0;
      for (final (String path, Map<String, Object?> r) in _journalRows()) {
        final List<String> codes = _reasonCodes(r);
        if (r['status'] == JournalStatus.prevented.wire) {
          prevented++;
          expect(
            codes.where(
              (String c) => c == JournalReasonCodes.duplicateOrderPrevented,
            ),
            hasLength(1),
            reason: '$path ${r['entry_id']}',
          );
          expect(
            codes,
            isNot(contains('DUPLICATE_SUSPECTED')),
            reason: '$path — 뜻이 다른 X7 코드를 빌렸다(G15).',
          );
          final Map<String, Object?> decision =
              r['decision']! as Map<String, Object?>;
          expect(
            decision['intent_id'],
            isNotNull,
            reason: '$path — 근거 = 원 의도.',
          );
        } else {
          expect(
            codes,
            isNot(contains(JournalReasonCodes.duplicateOrderPrevented)),
            reason: '$path ${r['entry_id']}',
          );
        }
      }
      expect(prevented, greaterThanOrEqualTo(1));
    });

    test('C-51 ⑫ D11 알림 코드 — STALE_ORDERS_HELD · 자동 매매 · P1 표본', () {
      expect(AlertCodes.staleOrdersHeld, 'STALE_ORDERS_HELD');
      expect(AlertCodes.autoTrade, contains(AlertCodes.staleOrdersHeld));
      expect(AlertCodes.values, contains(AlertCodes.staleOrdersHeld));
      final List<Map<String, Object?>> rows = _rows(
        FixturePaths.m8AlertsStaleOrdersHeld,
      );
      expect(rows, hasLength(1));
      expect(rows.single['code'], AlertCodes.staleOrdersHeld);
      expect(rows.single['level'], AlertLevel.p1.wire);
      AlertItem.fromJson(rows.single);
    });

    test('C-51 ⑬ 받침대 — 값을 지어내지 않는다(동기 throw)', () {
      final Matcher throwsUnimpl = throwsA(isA<UnimplementedError>());
      expect(UnimplementedIncidentRepository().watchIncident, throwsUnimpl);
      final UnimplementedRunbookRepository runbook =
          UnimplementedRunbookRepository();
      expect(runbook.watchRunbookIndex, throwsUnimpl);
      expect(() => runbook.watchRunbook('host-lost'), throwsUnimpl);
      expect(runbook.watchEmergencyCard, throwsUnimpl);
      final UnimplementedHandbookRepository handbook =
          UnimplementedHandbookRepository();
      expect(handbook.watchIndex, throwsUnimpl);
      expect(() => handbook.watchPage('sleeve-b'), throwsUnimpl);
      expect(UnimplementedOpsStatusRepository().watchDeviceRisk, throwsUnimpl);
    });

    test('C-51 ⑭ 라우트 — 5 상수 · 등록 · 첫 일치 · opsRhythm 뒤 차례', () {
      expect(AppRoutes.opsRunbooks, 'aaq://ops/runbooks');
      expect(AppRoutes.opsRunbook, 'aaq://ops/runbooks/:runbookId');
      expect(AppRoutes.opsEmergencyCard, 'aaq://ops/emergency-card');
      expect(AppRoutes.opsDeviceRisk, 'aaq://ops/device-risk');
      expect(AppRoutes.handbookIndex, 'aaq://handbook');
      expect(AppRoutes.isRegistered('aaq://ops/runbooks/host-lost'), isTrue);
      expect(AppRoutes.isRegistered('aaq://ops/runbooks/'), isFalse);
      expect(
        AppRoutes.isRegistered('aaq://ops/runbooks/host-lost?x=1'),
        isFalse,
      );
      expect(AppRoutes.isRegistered('aaq://handbook'), isTrue);
      expect(AppRoutes.isRegistered('aaq://handbook/x'), isFalse);
      final int at = AppRoutes.all.indexOf(AppRoutes.opsRhythm);
      expect(at, isNonNegative);
      expect(AppRoutes.all.sublist(at + 1, at + 6), <String>[
        AppRoutes.opsRunbooks,
        AppRoutes.opsRunbook,
        AppRoutes.opsEmergencyCard,
        AppRoutes.opsDeviceRisk,
        AppRoutes.handbookIndex,
      ]);
    });
  });
}
