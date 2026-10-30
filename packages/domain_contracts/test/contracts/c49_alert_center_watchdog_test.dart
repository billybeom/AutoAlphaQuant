// C-49 알림 센터·상세·워치독 보드 — 01 §24(🆕 계약 v1.15 · R14 선행 · 발주자 결정 2026-10-30 ①~④).
//
// 정의: 「알림 센터는 엔진이 묶은 봉투 VM 으로 오고(고정 P0 · 펼친 P1 · 접힌 P2 · 빈 문장), 상세는 모르는 id 도 값으로 오며,
//        P0 수신 확인 사다리는 P0(청산 긴급 제외)에만 실리고, 워치독 보드는 상태 모양(`level`)·고지·마지막 수신을 싣되
//        healthchecks 슬러그·ping URL·키는 어디에도 싣지 않는다」.
//   ① 허용 키 ② 칸막이 ③ 빈 ④ P0만 ⑤ 재발행 ⑥ ack 사다리(전 픽스처) ⑦ 표시 글자(전 픽스처) ⑧ 상세 ⑨ 접수증
//   ⑩ 워치독 키 ⑪ slug 0(전 픽스처) ⑫ 레벨 ⑬ 빈·고지 ⑭ 자기 링크 ⑮ 받침대.
//
// 🔴 픽스처 불변식만 본다 — `ui_shell` 화면 스캔은 R14 카드 정적 묶음 몫(01 §8 미결 144).
// 🔴 한국어 글자 단언 0 — 글자는 픽스처끼리 맞댄다(상수 리터럴 = 표본 id·키 이름·코드뿐).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

const List<String> _centers = <String>[
  FixturePaths.m8AlertCenterP0Ack,
  FixturePaths.m8AlertCenterDigest,
  FixturePaths.m8AlertCenterEmpty,
  FixturePaths.m8AlertCenterP0Only,
  FixturePaths.m8AlertCenterP0AckReordered,
];

const List<String> _details = <String>[
  FixturePaths.m8AlertDetailFull,
  FixturePaths.m8AlertDetailNoLink,
  FixturePaths.m8AlertDetailMissing,
];

const List<String> _boards = <String>[
  FixturePaths.m8WatchdogDelayed,
  FixturePaths.m8WatchdogHoliday,
  FixturePaths.m8WatchdogPaused,
  FixturePaths.m8WatchdogEmpty,
];

const Set<String> _centerKeys = <String>{
  'as_of',
  'pinned',
  'sections',
  'empty_label',
};
const Set<String> _sectionKeys = <String>{
  'header_text',
  'rows',
  'digest_label',
  'digest_rows',
};
const Set<String> _detailKeys = <String>{'as_of', 'item', 'missing_label'};
const Set<String> _boardKeys = <String>{
  'rows',
  'as_of',
  'empty_label',
  'holiday_notice',
  'limit_notice',
  'last_received_text',
};
const Set<String> _checkKeys = <String>{
  'check_id',
  'label',
  'state_code',
  'state_label',
  'level',
  'last_ping_text',
  'grace_text',
  'route',
};
const Set<String> _alertKeys = <String>{
  'alert_id',
  'level',
  'raised_at',
  'code',
  'title',
  'body_text',
  'action_line',
  'grouped_count',
  'deep_link',
  'ack',
  'raised_at_text',
  'grouped_text',
  'detail_deep_link',
};

/// K16 — 엔진 매핑(`state_code` → `level` 와이어).
const Map<String, String> _levelOfState = <String, String>{
  'OK': 'OK',
  'DELAYED': 'WATCH',
  'FAILED': 'BLOCKED',
  'PAUSED': 'INFO',
};

/// K17 — 슬러그 꼴(2축 합성 `{sim|live}-{auto|advisory}-`).
final RegExp _slugLike = RegExp(r'^(sim|live)-(auto|advisory)-');

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _maps(Object? list) =>
    (list! as List<Object?>).cast<Map<String, Object?>>();

/// VM 1행 봉투의 VM.
Map<String, Object?> _vm(String path) {
  final List<Map<String, Object?>> rows = _maps(_env(path)['rows']);
  expect(rows, hasLength(1), reason: '$path — VM 1행 봉투가 아니다');
  return rows.single;
}

List<Map<String, Object?>> _pinned(String path) => _maps(_vm(path)['pinned']);

List<Map<String, Object?>> _sections(String path) =>
    _maps(_vm(path)['sections']);

List<String> _ids(List<Map<String, Object?>> alerts) => <String>[
  for (final Map<String, Object?> a in alerts) a['alert_id']! as String,
];

/// JSON 트리 안의 알림 객체(`alert_id` 를 가진 객체) — 🔴 `AdviceItem`·`HoldingRow`·`RebalanceEvent` 는 `alert_id` 가 없다.
List<Map<String, Object?>> _alertObjects(Object? node) {
  final List<Map<String, Object?>> out = <Map<String, Object?>>[];
  void visit(Object? n) {
    if (n is Map<String, Object?>) {
      if (n.containsKey('alert_id')) {
        out.add(n);
      }
      n.values.forEach(visit);
    } else if (n is List<Object?>) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// JSON 트리에서 [key] 키가 나오는 경로.
List<String> _keyPaths(Object? node, String key) {
  final List<String> hits = <String>[];
  walkJson(node, (String path, String k, Object? _) {
    if (k == key) {
      hits.add(path);
    }
  });
  return hits;
}

void main() {
  group('C-49 알림 센터·상세·워치독 보드 (01 §24 · 계약 v1.15)', () {
    test('C-49 ① 허용 키 — 픽스처 키와 toJson() 키', () {
      for (final String path in _centers) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _centerKeys, reason: path);
        expect(AlertCenterVm.fromJson(vm).toJson().keys.toSet(), _centerKeys);
        for (final Map<String, Object?> s in _sections(path)) {
          expect(s.keys.toSet(), _sectionKeys, reason: path);
          expect(AlertSection.fromJson(s).toJson().keys.toSet(), _sectionKeys);
        }
      }
      for (final String path in _details) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _detailKeys, reason: path);
        expect(AlertDetailVm.fromJson(vm).toJson().keys.toSet(), _detailKeys);
      }
      for (final String path in _boards) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _boardKeys, reason: path);
        expect(WatchdogBoardVm.fromJson(vm).toJson().keys.toSet(), _boardKeys);
        for (final Map<String, Object?> r in _maps(vm['rows'])) {
          expect(_checkKeys.containsAll(r.keys), isTrue, reason: '$path $r');
          expect(WatchdogCheck.fromJson(r).toJson().keys.toSet(), _checkKeys);
        }
      }
      int alerts = 0;
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> a in _alertObjects(_env(path))) {
          alerts++;
          expect(
            _alertKeys.containsAll(a.keys),
            isTrue,
            reason: '$path ${a['alert_id']} — 알림 객체에 계약 밖 키가 있다',
          );
          expect(AlertItem.fromJson(a).toJson().keys.toSet(), _alertKeys);
        }
      }
      expect(alerts, greaterThanOrEqualTo(28));
    });

    test('C-49 ② 칸막이 — 고정 = P0 · 펼친 = P1 · 접힌 = P2 · 접힘 머리 ⇔ 접힌 행', () {
      for (final String path in _centers) {
        for (final Map<String, Object?> a in _pinned(path)) {
          expect(a['level'], 'P0', reason: '$path pinned ${a['alert_id']}');
        }
        for (final Map<String, Object?> s in _sections(path)) {
          final List<Map<String, Object?>> rows = _maps(s['rows']);
          final List<Map<String, Object?>> digest = _maps(s['digest_rows']);
          for (final Map<String, Object?> a in rows) {
            expect(a['level'], 'P1', reason: '$path rows ${a['alert_id']}');
          }
          for (final Map<String, Object?> a in digest) {
            expect(a['level'], 'P2', reason: '$path digest ${a['alert_id']}');
          }
          expect(
            s['digest_label'] != null,
            digest.isNotEmpty,
            reason: '$path — 접힘 머리와 접힌 행이 어긋난다',
          );
          expect(rows.length + digest.length, greaterThan(0), reason: path);
          expect((s['header_text']! as String).trim(), isNotEmpty);
        }
      }
    });

    test('C-49 ③ 빈 — empty_label ⇔ 고정 0 ∧ 섹션 0 · 빈 표본 1벌', () {
      int empties = 0;
      for (final String path in _centers) {
        final Map<String, Object?> vm = _vm(path);
        final bool empty = _pinned(path).isEmpty && _sections(path).isEmpty;
        expect(vm['empty_label'] != null, empty, reason: path);
        if (empty) {
          empties++;
          expect((vm['empty_label']! as String).trim(), isNotEmpty);
        }
      }
      expect(empties, 1);
      expect(_vm(FixturePaths.m8AlertCenterEmpty)['empty_label'], isNotNull);
    });

    test('C-49 ④ P0만 — 섹션 0 · 고정 = p0_ack 의 고정(값·차례)', () {
      expect(_sections(FixturePaths.m8AlertCenterP0Only), isEmpty);
      expect(
        _pinned(FixturePaths.m8AlertCenterP0Only),
        _pinned(FixturePaths.m8AlertCenterP0Ack),
      );
      expect(_pinned(FixturePaths.m8AlertCenterP0Only), isNotEmpty);
    });

    test('C-49 ⑤ 재발행 — 같은 집합 · 다른 차례 · [0] = p0_ack [1] · 섹션 같음', () {
      final List<Map<String, Object?>> base = _pinned(
        FixturePaths.m8AlertCenterP0Ack,
      );
      final List<Map<String, Object?>> re = _pinned(
        FixturePaths.m8AlertCenterP0AckReordered,
      );
      expect(_ids(re).toSet(), _ids(base).toSet());
      expect(_ids(re), isNot(_ids(base)));
      expect(re.first, base[1]);
      expect(
        _sections(FixturePaths.m8AlertCenterP0AckReordered),
        _sections(FixturePaths.m8AlertCenterP0Ack),
      );
    });

    test('C-49 ⑥ ack 사다리 — 전 픽스처: ack ⇒ P0 ∧ ≠ ADVICE_EXIT_URGENT', () {
      final List<String> bad = <String>[];
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> a in _alertObjects(_env(path))) {
          if (a['ack'] != null &&
              (a['level'] != 'P0' ||
                  a['code'] == AlertCodes.adviceExitUrgent)) {
            bad.add('$path ${a['alert_id']} (${a['level']} ${a['code']})');
          }
        }
      }
      expect(
        bad,
        isEmpty,
        reason: 'ack 사다리는 P0 만이고 청산 긴급엔 없다(04 §5-4).\n${bad.join('\n')}',
      );
      final List<Map<String, Object?>> pinned = <Map<String, Object?>>[
        for (final String path in _centers) ..._pinned(path),
      ];
      bool acked(Map<String, Object?> a) =>
          (a['ack']! as Map<String, Object?>)['acked']! as bool;
      expect(
        pinned.where((Map<String, Object?> a) => a['ack'] != null && !acked(a)),
        isNotEmpty,
        reason: '미확인 사다리 표본이 없다',
      );
      expect(
        pinned.where((Map<String, Object?> a) => a['ack'] != null && acked(a)),
        isNotEmpty,
        reason: '확인됨 표본이 없다',
      );
      expect(
        pinned.where(
          (Map<String, Object?> a) =>
              a['code'] == AlertCodes.adviceExitUrgent && a['ack'] == null,
        ),
        isNotEmpty,
        reason: '청산 긴급 ack 없음 표본이 없다',
      );
    });

    test('C-49 ⑦ 표시 글자 — 묶음 배지 · 상세 링크 꼴 · null 표본', () {
      final List<String> bad = <String>[];
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> a in _alertObjects(_env(path))) {
          final String id = a['alert_id']! as String;
          if (a['grouped_text'] != null && (a['grouped_count']! as int) <= 1) {
            bad.add('$path $id — grouped_text 인데 grouped_count ≤ 1');
          }
          final Object? link = a['detail_deep_link'];
          if (link != null &&
              (link != 'aaq://alerts/detail/$id' ||
                  !AppRoutes.isRegistered(link as String))) {
            bad.add('$path $id — detail_deep_link 꼴: $link');
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
      final List<Map<String, Object?>> v115 = <Map<String, Object?>>[
        for (final String path in <String>[..._centers, ..._details])
          ..._alertObjects(_vm(path)),
      ];
      expect(v115, isNotEmpty);
      for (final Map<String, Object?> a in v115) {
        if ((a['grouped_count']! as int) > 1) {
          expect(a['grouped_text'], isNotNull, reason: '${a['alert_id']}');
        }
      }
      for (final String key in <String>[
        'raised_at_text',
        'detail_deep_link',
        'deep_link',
      ]) {
        expect(
          v115.where((Map<String, Object?> a) => a[key] == null),
          isNotEmpty,
          reason: '$key null 표본이 없다',
        );
        expect(
          v115.where((Map<String, Object?> a) => a[key] != null),
          isNotEmpty,
          reason: '$key 값 표본이 없다',
        );
      }
    });

    test('C-49 ⑧ 상세 — item XOR missing_label · 센터의 같은 객체', () {
      for (final String path in _details) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          (vm['item'] == null) != (vm['missing_label'] == null),
          isTrue,
          reason: path,
        );
        final AlertDetailVm d = AlertDetailVm.fromJson(vm);
        expect((d.item == null) != (d.missingLabel == null), isTrue);
      }
      expect(
        _vm(FixturePaths.m8AlertDetailFull)['item'],
        _pinned(FixturePaths.m8AlertCenterP0Ack)[0],
      );
      expect(
        _vm(FixturePaths.m8AlertDetailNoLink)['item'],
        _maps(_sections(FixturePaths.m8AlertCenterDigest)[1]['digest_rows'])[2],
      );
      expect(_vm(FixturePaths.m8AlertDetailMissing)['item'], isNull);
      expect(
        _details.where((String p) => _vm(p)['missing_label'] != null),
        hasLength(1),
      );
    });

    test('C-49 ⑨ 접수증 — ALERT_ACK 3갈래 · REJECTED = INPUT_INVALID', () {
      final List<Map<String, Object?>> rows = _maps(
        _env(FixturePaths.m8AlertAckReceipts3)['rows'],
      );
      expect(rows, hasLength(3));
      for (final Map<String, Object?> r in rows) {
        expect(r['kind'], 'ALERT_ACK');
        for (final String k in <String>[
          'command_id',
          'nonce',
          'issued_by_device_id',
        ]) {
          expect(r[k], rows.first[k], reason: k);
        }
        CommandReceipt.fromJson(r);
      }
      expect(
        <Object?>[for (final Map<String, Object?> r in rows) r['state']],
        <String>['REQUESTED', 'EXECUTED', 'REJECTED'],
      );
      expect(rows[2]['reject_reason_code'], AdviceRejectCodes.inputInvalid);
      expect(rows[0]['reject_reason_code'], isNull);
      expect(rows[1]['reject_reason_code'], isNull);
    });

    test('C-49 ⑩ 워치독 키 — VM 1행 · 행 키 ⊆ 계약 · level ∈ UiLevel', () {
      final Set<String> wires = <String>{
        for (final UiLevel l in UiLevel.values) l.wire,
      };
      for (final String path in _boards) {
        final Map<String, Object?> vm = _vm(path);
        expect(_env(path)['as_of'], vm['as_of'], reason: path);
        for (final Map<String, Object?> r in _maps(vm['rows'])) {
          expect(_checkKeys.containsAll(r.keys), isTrue, reason: '$path $r');
          expect(wires, contains(r['level']), reason: '$path $r');
        }
        WatchdogBoardVm.fromJson(vm);
      }
    });

    test('C-49 ⑪ slug 0 — 전 픽스처 · check_id 꼴 · 보드 안 유일', () {
      // 자체 검증 — 견본의 slug 키는 걸린다.
      expect(
        _keyPaths(
          jsonDecode('{"rows":[{"slug":"x"}]}') as Map<String, Object?>,
          'slug',
        ),
        hasLength(1),
      );
      final List<String> hits = <String>[];
      for (final String rel in allFixtureFilesOnDisk()) {
        for (final String p in _keyPaths(
          jsonDecode(readFixture(rel)),
          'slug',
        )) {
          hits.add('$rel $p');
        }
      }
      expect(
        hits,
        isEmpty,
        reason: '워치독 슬러그는 DTO·픽스처에 오지 않는다(결정 ②(c)).\n${hits.join('\n')}',
      );
      for (final String path in _boards) {
        final List<String> ids = <String>[
          for (final Map<String, Object?> r in _maps(_vm(path)['rows']))
            r['check_id']! as String,
        ];
        expect(ids.toSet(), hasLength(ids.length), reason: path);
        for (final String id in ids) {
          expect(_slugLike.hasMatch(id), isFalse, reason: '$path $id');
          expect(id.contains('://'), isFalse, reason: '$path $id');
          expect(id.contains('hc-ping'), isFalse, reason: '$path $id');
        }
      }
      final WatchdogCheck c = WatchdogCheck.fromJson(<String, Object?>{
        'slug': 'live-auto-order',
        'check_id': 'wd_x',
        'label': 'l',
        'state_code': 'OK',
        'state_label': 's',
        'level': 'OK',
        'last_ping_text': 'p',
      });
      expect(c.toJson().containsKey('slug'), isFalse);
    });

    test('C-49 ⑫ 레벨 — state_code → level 사전 · 실패·일시정지 표본 · 휴장 = 성공 핑', () {
      final List<Map<String, Object?>> all = <Map<String, Object?>>[
        for (final String path in _boards) ..._maps(_vm(path)['rows']),
      ];
      for (final Map<String, Object?> r in all) {
        expect(
          _levelOfState.containsKey(r['state_code']),
          isTrue,
          reason: '$r',
        );
        expect(r['level'], _levelOfState[r['state_code']], reason: '$r');
      }
      expect(
        _maps(_vm(FixturePaths.m8WatchdogDelayed)['rows'])
            .where((Map<String, Object?> r) => r['state_code'] == 'FAILED'),
        isNotEmpty,
      );
      expect(
        _maps(_vm(FixturePaths.m8WatchdogPaused)['rows'])
            .where((Map<String, Object?> r) => r['state_code'] == 'PAUSED'),
        isNotEmpty,
      );
      final List<Map<String, Object?>> holiday = _maps(
        _vm(FixturePaths.m8WatchdogHoliday)['rows'],
      );
      expect(holiday, isNotEmpty);
      for (final Map<String, Object?> r in holiday) {
        expect(r['state_code'], 'OK', reason: '휴장 = 성공 핑 $r');
        expect(r['level'], 'OK', reason: '$r');
      }
    });

    test('C-49 ⑬ 빈·고지 — empty_label ⇔ 행 0 · limit_notice 늘 · holiday_notice = 휴장 1벌', () {
      for (final String path in _boards) {
        final Map<String, Object?> vm = _vm(path);
        final bool empty = _maps(vm['rows']).isEmpty;
        expect(vm['empty_label'] != null, empty, reason: path);
        expect(vm['limit_notice'], isNotNull, reason: path);
        expect(vm['last_received_text'] != null, !empty, reason: path);
      }
      expect(
        _boards.where((String p) => _vm(p)['holiday_notice'] != null),
        <String>[FixturePaths.m8WatchdogHoliday],
      );
      expect(_vm(FixturePaths.m8WatchdogEmpty)['rows'], isEmpty);
    });

    test('C-49 ⑭ 자기 링크 — delayed 의 route 2행 = W-01(표본 사실 · 미결 143)', () {
      final List<Object?> routes = <Object?>[
        for (final Map<String, Object?> r in _maps(
          _vm(FixturePaths.m8WatchdogDelayed)['rows'],
        ))
          if (r['route'] != null) r['route'],
      ];
      expect(routes, <String>[AppRoutes.opsWatchdog, AppRoutes.opsWatchdog]);
    });

    test('C-49 ⑮ 받침대 — 값을 지어내지 않는다(동기 throw)', () {
      final UnimplementedAlertRepository alerts =
          UnimplementedAlertRepository();
      final Matcher throwsUnimpl = throwsA(isA<UnimplementedError>());
      expect(alerts.watchInbox, throwsUnimpl);
      expect(() => alerts.watchCenter(p0Only: false), throwsUnimpl);
      expect(() => alerts.watchAlert('al_x'), throwsUnimpl);
      final UnimplementedOpsStatusRepository ops =
          UnimplementedOpsStatusRepository();
      expect(ops.watchWatchdog, throwsUnimpl);
      expect(ops.watchConnections, throwsUnimpl);
      expect(ops.watchDeviceAccess, throwsUnimpl);
      expect(ops.watchBackup, throwsUnimpl);
      expect(ops.watchDiagnostics, throwsUnimpl);
      expect(ops.watchAnnualReview, throwsUnimpl);
      expect(
        () => UnimplementedCommandApi().acknowledgeAlert('al_x'),
        throwsUnimpl,
      );
    });
  });
}
